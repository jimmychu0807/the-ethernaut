import assert from 'node:assert/strict';

// Use viem to sign the hash
import { type Hex, recoverMessageAddress, hashMessage } from 'viem';
import { privateKeyToAccount, signMessage } from 'viem/accounts';

import { signWithDefaultK, signWithCustomK } from "./customKSigner";

type MySignatureType = {
  r: Hex,
  s: Hex,
  v: number,
}

async function main() {
  const privateKey: bigint = BigInt(1);
  // Convert bigint to 32-byte hex string (0x-prefixed)
  const privateKeyHex = ('0x' + privateKey.toString(16).padStart(64, '0')) as Hex;
  const account = privateKeyToAccount(privateKeyHex);
  console.log(`sk: ${privateKeyHex}`);
  console.log(`addr: ${account.address}`);

  // signing message
  const message = "lock0";

  // by viem
  const signatureViem = await getViemSignature(message, privateKeyHex);
  let {r, s, v} = intoRSV(signatureViem);
  console.log(`signatureViem:\nr: ${r}\ns: ${s}\nv:${v}`);

  // confirm it can be recover to signer acct
  let recoveredAddr = await recoverMessageAddress({ message, signature: signatureViem });
  assert(recoveredAddr === account.address, "Viem signature doesn't recover expected address");

  // self-implemented default K
  const signatureDefaultK = (await signWithDefaultK(hashMessage(message), privateKeyHex)) as Hex;
  ({ r, s, v } = intoRSV(signatureDefaultK)); // wrap destructuring assignment in parentheses!
  console.log(`signatureDefaultK:\nr: ${r}\ns: ${s}\nv:${v}`);

  // confirm it can be recover to signer acct
  recoveredAddr = await recoverMessageAddress({ message, signature: signatureDefaultK });
  assert(recoveredAddr === account.address, "signWithDefaultK signature doesn't recover expected address");
}

async function getViemSignature(message: string, privateKey: any) {
  return await signMessage({ message, privateKey });
}

function intoRSV(signature: Hex): MySignatureType {
  // Remove "0x" prefix if present
  const sig = signature.startsWith('0x') ? signature.slice(2) : signature;
  if (sig.length !== 130) {
    throw new Error("Signature must be 65 bytes/130 hex chars with 0x prefix removed");
  }
  const r = ('0x' + sig.slice(0, 64)) as Hex;
  const s = ('0x' + sig.slice(64, 128)) as Hex;

  // 'v' is the last byte, usually 0x1b (27) or 0x1c (28) for Ethereum
  const vHex = sig.slice(128, 130);
  let v = parseInt(vHex, 16);
  // Some libraries return v as 0 or 1, so adjust to Ethereum's 27 or 28 if needed
  if (v === 0 || v === 1) v += 27;

  return { r, s, v };
}

main().catch((err) => {
  console.error("Fatal error in main:", err);
  // Ensure non‑zero exit code in Node
  process.exitCode = 1;
});
