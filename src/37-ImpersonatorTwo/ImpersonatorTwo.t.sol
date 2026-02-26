// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {ECDSA} from "oz-v4/contracts/utils/cryptography/ECDSA.sol";
import {Strings} from "oz-v4/contracts/utils/Strings.sol";
import {ImpersonatorTwo} from "./ImpersonatorTwo.sol";

contract ImpersonatorTwoTest is Test {
    using Strings for uint256;
    ImpersonatorTwo instance;

    uint256 constant N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    bytes32 constant R = hex"24acb1c19b6dfc25defb01c2e2681ae82deacc0ff21ae8ff01f82f37a6a2147f";
    // bytes32 constant R = hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40";

    string constant M0 = "lock0";
    bytes32 constant S0 = hex"699e057dbf38b13e6a90e051497abf3d85292299e17d0e4168ff7e834f2b645f";
    // bytes32 constant S0 = hex"70026fc30e4e02a15468de57155b080f405bd5b88af05412a9c3217e028537e3";

    string constant M1 = "admin1";
    bytes32 constant S1 = hex"65465d0b92ce24ef57eb7e3ccd20aa49df50c4626e53d1e7361da1afa5e19c2d";
    // bytes32 constant S1 = hex"4c3ac03b268ae1d2aca1201e8a936adf578a8b95a49986d54de87cd0ccb68a79";

    function setUp() public {
        instance = new ImpersonatorTwo();
    }

    function testSigning() public view {
        uint256 sk = 1;
        address tester = vm.addr(sk);
        string memory message = "lock0";

        bytes32 hsh0 = instance.hash_message(message);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sk, hsh0);
        console.log("user: %s", tester);
        console.log("r: %s", vm.toString(r));
        console.log("s: %s", vm.toString(s));
        console.log("v: %s", v);
    }

    function testSolveImpersonatorTwo() public view {
        // Solving for k = (z0 − z1)⋅(s0 − s1)^(-1) mod n
        bytes32 z0 = instance.hash_message(M0);
        bytes32 z1 = instance.hash_message(M1);

        (uint256 kdiff, uint256 ksum) = _compute2k(z0, z1, S0, S1, N);

        console.log("kdiff: %s", kdiff);
        console.log("ksum: %s\n", ksum);

        (uint256 sk0, uint256 sk1) = _compute2SecretKeys(S0, z0, R, kdiff, N);
        (uint256 sk2, uint256 sk3) = _compute2SecretKeys(S0, z0, R, ksum, N);
        (uint256 sk4, uint256 sk5) = _compute2SecretKeys(S1, z1, R, kdiff, N);
        (uint256 sk6, uint256 sk7) = _compute2SecretKeys(S1, z1, R, ksum, N);

        uint256[] memory sks = new uint256[](8);
        sks[0] = sk0;
        sks[1] = sk1;
        sks[2] = sk2;
        sks[3] = sk3;
        sks[4] = sk4;
        sks[5] = sk5;
        sks[6] = sk6;
        sks[7] = sk7;

        uint256[] memory filtered = _findDuplicates(sks);

        _printSkAndAddr(filtered, true, true);
    }

    function _findDuplicates(uint256[] memory arr) internal pure returns (uint256[] memory) {
        if (arr.length < 2) {
            return new uint256[](0);
        }

        // Step 1: Sort the array (bubble sort for simplicity, can optimize with quicksort)
        uint256[] memory sorted = _sort(arr);

        // Step 2: Find duplicates by comparing adjacent elements
        // First pass: count unique duplicates
        uint256 duplicateCount = 0;
        for (uint256 i = 1; i < sorted.length; i++) {
            if (sorted[i] == sorted[i-1]) {
                duplicateCount++;
                // Skip all consecutive duplicates of the same value
                while (i < sorted.length && sorted[i] == sorted[i-1]) {
                    i++;
                }
            }
        }

        // Step 3: Second pass: collect the duplicate values
        uint256[] memory result = new uint256[](duplicateCount);
        uint256 resultIndex = 0;
        for (uint256 i = 1; i < sorted.length; i++) {
            if (sorted[i] == sorted[i-1]) {
                result[resultIndex] = sorted[i];
                resultIndex++;
                // Skip all consecutive duplicates of the same value
                while (i < sorted.length && sorted[i] == sorted[i-1]) {
                    i++;
                }
            }
        }

        return result;
    }

    // Simple bubble sort (O(n^2) - can be replaced with quicksort for better performance)
    function _sort(uint256[] memory arr) internal pure returns (uint256[] memory) {
        uint256[] memory sorted = new uint256[](arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            sorted[i] = arr[i];
        }

        for (uint256 i = 0; i < sorted.length; i++) {
            for (uint256 j = i + 1; j < sorted.length; j++) {
                if (sorted[i] > sorted[j]) {
                    (sorted[i], sorted[j]) = (sorted[j], sorted[i]);
                }
            }
        }

        return sorted;
    }

    function _compute2k(bytes32 z0B, bytes32 z1B, bytes32 s0B, bytes32 s1B, uint256 n)
        internal
        pure
        returns (uint256 kdiff, uint256 ksum)
    {
        (uint256 z0, uint256 z1, uint256 s0, uint256 s1) = (uint256(z0B), uint256(z1B), uint256(s0B), uint256(s1B));

        uint256 zdiff = submod(z0, z1, n);
        uint256 sdiff = submod(s0, s1, n);
        uint256 ssum = addmod(s0, s1, n);
        kdiff = normalize(mulmod(zdiff, modInv(sdiff, n), n), n);
        ksum = normalize(mulmod(zdiff, modInv(ssum, n), n), n);
    }

    function _compute2SecretKeys(bytes32 sB, bytes32 zB, bytes32 rB, uint256 k, uint256 n)
        internal
        pure
        returns (uint256 sk, uint256 skInv)
    {
        (uint256 s, uint256 z, uint256 r) = (uint256(sB), uint256(zB), uint256(rB));

        // Now, solving for sk(private key) = (s0⋅k − z0)⋅r^(-1) mod n
        uint256 rp = modInv(r, n);
        uint256 lp = submod(mulmod(s, k, n), z, n);
        uint256 lpInv = submod(mulmod(submod(n, s, n), k, n), z, n);
        sk = mulmod(lp, rp, n);
        skInv = mulmod(lpInv, rp, n);
    }

    function _printSkAndAddr(uint256[] memory sks, bool printSk, bool printAddr) internal pure {
        for (uint256 i = 0; i < sks.length; i++) {
            uint256 sk = sks[i];
            address addr = vm.addr(sk);
            if (printSk) console.log("sk: %s", sk);
            if (printAddr) console.log("addr: %s", addr);
        }
    }

    function normalize(uint256 v, uint256 n) internal pure returns (uint256 result) {
        uint256 vInverse = n - (v % n);
        if (v > vInverse) {
            result = vInverse;
        } else {
            result = v;
        }
    }

    function submod(uint256 v1, uint256 v2, uint256 n) internal pure returns (uint256 result) {
        uint256 v1n = v1 % n;
        uint256 v2n = v2 % n;

        if (v1n > v2n) {
            result = v1n - v2n;
        } else {
            unchecked {
                result = v1n + n - v2n;
            }
        }
    }

    function modInv(uint256 a, uint256 p) internal pure returns (uint256) {
        // requires a % p != 0
        return _modExp(a, p - 2, p);
    }

    function _modExp(uint256 base, uint256 exp, uint256 m) internal pure returns (uint256 result) {
        result = 1;
        uint256 x = base % m;
        while (exp > 0) {
            if (exp & 1 == 1) {
                result = mulmod(result, x, m);
            }
            x = mulmod(x, x, m);
            exp >>= 1;
        }
    }
}
