import * as secp from '@noble/secp256k1';

export type Hex = string;
export type Bytes = Uint8Array;

const CURVE_N: bigint = BigInt(secp.Point.CURVE().n);
const HALF_N: bigint = CURVE_N / 2n;

function stripHexPrefix(hex: string): string {
  return hex.startsWith('0x') || hex.startsWith('0X') ? hex.slice(2) : hex;
}

function hexToBytes(hex: Hex): Bytes {
  const clean = stripHexPrefix(hex);
  if (clean.length % 2 !== 0) {
    throw new Error('Invalid hex string length');
  }
  const out = new Uint8Array(clean.length / 2);
  for (let i = 0; i < out.length; i++) {
    out[i] = parseInt(clean.slice(i * 2, i * 2 + 2), 16);
  }
  return out;
}

function bytesToHex(bytes: Bytes): Hex {
  return '0x' + Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
}

function toBytes(input: Hex | Bytes): Bytes {
  if (input instanceof Uint8Array) return input;
  return hexToBytes(input);
}

function bytesToBigInt(b: Bytes): bigint {
  let result = 0n;
  for (const byte of b) {
    result = (result << 8n) | BigInt(byte);
  }
  return result;
}

function bigIntTo32Bytes(x: bigint): Bytes {
  const out = new Uint8Array(32);
  let v = x;
  for (let i = 31; i >= 0; i--) {
    out[i] = Number(v & 0xffn);
    v >>= 8n;
  }
  return out;
}

function mod(a: bigint, m: bigint): bigint {
  const res = a % m;
  return res >= 0n ? res : res + m;
}

function egcd(a: bigint, b: bigint): { g: bigint; x: bigint; y: bigint } {
  if (b === 0n) return { g: a, x: 1n, y: 0n };
  const { g, x, y } = egcd(b, a % b);
  return { g, x: y, y: x - (a / b) * y };
}

function modInv(a: bigint, m: bigint): bigint {
  const { g, x } = egcd(mod(a, m), m);
  if (g !== 1n) {
    throw new Error('Inverse does not exist');
  }
  return mod(x, m);
}

function normalizeHashToZ(hash: Bytes): bigint {
  // For secp256k1, just interpret the hash as a big-endian integer and reduce mod n.
  const h = bytesToBigInt(hash);
  return mod(h, CURVE_N);
}

function normalizePrivateKey(priv: Hex | Bytes | bigint): bigint {
  let d: bigint;
  if (typeof priv === 'bigint') {
    d = priv;
  } else {
    d = bytesToBigInt(toBytes(priv));
  }
  d = mod(d, CURVE_N);
  if (d === 0n) {
    throw new Error('Invalid private key (zero)');
  }
  return d;
}

function normalizeK(k: Hex | Bytes | bigint): bigint {
  let kBig: bigint;
  if (typeof k === 'bigint') {
    kBig = k;
  } else {
    kBig = bytesToBigInt(toBytes(k));
  }
  kBig = mod(kBig, CURVE_N);
  if (kBig === 0n) {
    throw new Error('Invalid nonce k (zero)');
  }
  return kBig;
}

export interface EcdsaSignature {
  r: bigint;
  s: bigint;
  v: number; // Ethereum-style recovery id (27/28)
  rHex: Hex;
  sHex: Hex;
}

/**
 * Sign a 32-byte message hash with a custom nonce k.
 *
 * WARNING: Only use this for research / testing. If you ever reuse k or make it
 * predictable, you will leak the private key.
 */
export async function signWithCustomK(
  msgHash: Hex,
  privKey: Hex,
  k: bigint
): Promise<Hex> {
  const hashBytes = toBytes(msgHash);
  if (hashBytes.length !== 32) {
    throw new Error('msgHash must be 32 bytes (pre-hashed)');
  }

  const z = normalizeHashToZ(hashBytes);
  const d = normalizePrivateKey(privKey);
  const kBig = normalizeK(k);

  const R = secp.Point.BASE.multiply(kBig);
  const r = mod(R.x, CURVE_N);
  if (r === 0n) {
    throw new Error('Invalid nonce k produced r = 0');
  }

  const kInv = modInv(kBig, CURVE_N);
  const sRaw = mod(kInv * mod(z + r * d, CURVE_N), CURVE_N);
  if (sRaw === 0n) {
    throw new Error('Invalid parameters produced s = 0');
  }

  let s = sRaw;
  let recovery = R.y & 1n; // 0n or 1n

  // Low-S normalization as in Ethereum
  if (s > HALF_N) {
    s = CURVE_N - s;
    recovery ^= 1n;
  }

  const v = 27 + Number(recovery);

  // convert the last byte: recId (0/1) -> v (27/28)
  const rsv = new Uint8Array(65);
  rsv.set(bigIntTo32Bytes(r), 0);
  rsv.set(bigIntTo32Bytes(s), 32);
  rsv[64] = Number(recovery);

  return bytesToHex(rsv);
}

/**
 * Safe wrapper around noble-secp256k1.sign using its deterministic nonce.
 * Returns Ethereum-style (r, s, v) with low-S normalization.
 */
export async function signWithDefaultK(
  msgHash: Hex,
  privKey: Hex
): Promise<Hex> {
  const hashBytes = toBytes(msgHash);
  if (hashBytes.length !== 32) {
    throw new Error('msgHash must be 32 bytes (pre-hashed)');
  }

  let privBytes: Bytes = toBytes(privKey);

  const sig = await secp.signAsync(hashBytes, privBytes, {
    format: "recovered",
    prehash: false
  });

  if (!(sig instanceof Uint8Array) || sig.length !== 65) {
    throw new Error('Expected 65-byte recoverable signature from noble');
  }

  // convert the last byte: recId (0/1) -> v (27/28)
  const rsv = new Uint8Array(65);
  rsv.set(sig.subarray(1, 65), 0);
  rsv[64] = 27 + sig[0]!;

  return bytesToHex(rsv);
}
