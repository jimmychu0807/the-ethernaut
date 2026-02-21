import process from "node:process";
import { existsSync } from "node:fs";
import { writeFile } from "node:fs/promises";
import assert from "node:assert/strict";
import { Buffer } from "node:buffer";
import { readFile } from "fs/promises";

const JUMPDEST_OPCODE: number = 0x5B;
const PUSH1_OPCODE: number = 0x60;
const PUSH2_OPCODE: number = 0x61;
const JUMP_OPCODE: number = 0x56;
const JUMPI_OPCODE: number = 0x57;

async function main() {
  const [craftedBCPath, deployedBCPath, outputPath] = process.argv.slice(2);

  if ([craftedBCPath, deployedBCPath].some((path) => !existsSync(path))) {
    throw new Error("One of the input files doesn't exists");
  }

  const [craftedBytes, deployedBytes] = await readByteCodes([craftedBCPath, deployedBCPath]);

  // For the main bytecode, when you find a PUSH2 opcode
  console.log(`craftedBytes byte len: ${craftedBytes.length}`);
  console.log(`deployedBytes byte len: ${deployedBytes.length}`);

  const craftedByteLen = craftedBytes.length;
  let outputBuffer = Buffer.concat([craftedBytes, deployedBytes]);

  let adjustedTimes = 0;

  // go thru the outputBuffer. If
  // - PUSH2 (2 bytes) JUMP
  // - PUSH2 (2 bytes) JUMPI
  // if the 2 bytes pointed to the previous JUMPDEST_OPCODE, then add offset
  for (let pc = craftedByteLen; pc < outputBuffer.length - 3; pc++) {
    const byte0 = outputBuffer[pc];

    if (byte0 !== PUSH1_OPCODE && byte0 !== PUSH2_OPCODE) continue;
    const dataLen = byte0 - PUSH1_OPCODE + 1;

    const nextOpCode = outputBuffer[pc + dataLen + 1];
    if (nextOpCode !== JUMPI_OPCODE && nextOpCode !== JUMP_OPCODE) continue;

    // read the value
    const jumpOffset = dataLen == 1
      ? outputBuffer.readUint8(pc + 1)
      : outputBuffer.readUint16BE(pc + 1);

    if (dataLen == 1) {
      outputBuffer.writeUint8(jumpOffset + craftedByteLen, pc + 1);
    } else {
      outputBuffer.writeUint16BE(jumpOffset + craftedByteLen, pc + 1);
    }
    adjustedTimes += 1;

    console.log(`offset ${pc+1}: updated from ${jumpOffset} to ${jumpOffset + craftedByteLen} / ${dataLen}`);
  }

  // output
  const output = `0x${outputBuffer.toString("hex")}`;
  if (outputPath) {
    await writeFile(outputPath, output, "utf-8");
  } else {
    console.log(`Updated deployed bytecode:\n${output}`);
  }

  console.log(`output byte len: ${outputBuffer.length}`);
  console.log(`adjusted times: ${adjustedTimes}`);
}

async function readByteCodes(filepaths: string[]): Promise<Buffer[]> {
  // check if the first two file paths exists
  let content = await Promise.all(filepaths.map((filepath) => readFile(filepath, "utf8")));
  content = content.map((bc) => bc.trim().replace(/^0x/, ""));

  // Assert length is an even number
  content.forEach((bc) => {
    assert(bc.length % 2 === 0, "Unexpected byte code with uneven string length.");
  });

  return content.map((bc) => Buffer.from(bc, "hex"));
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
