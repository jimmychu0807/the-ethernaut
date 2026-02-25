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

    // msg: "lock0"
    bytes32 constant S0 = hex"699e057dbf38b13e6a90e051497abf3d85292299e17d0e4168ff7e834f2b645f";

    // msg: "admin1"
    bytes32 constant S1 = hex"65465d0b92ce24ef57eb7e3ccd20aa49df50c4626e53d1e7361da1afa5e19c2d";

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
        string memory m0 = "lock0";
        string memory m1 = "admin1";
        bytes32 z0 = instance.hash_message(m0);
        bytes32 z1 = instance.hash_message(m1);

        uint256 zdiff = submod(uint256(z0), uint256(z1), N);
        uint256 sdiff = submod(uint256(S0), uint256(S1), N);
        uint256 ssum = addmod(uint256(S0), uint256(S1), N);
        uint256 k1 = normalized(mulmod(zdiff, modInv(sdiff, N), N), N);
        uint256 k2 = normalized(mulmod(zdiff, modInv(ssum, N), N), N);
        console.log("k1: %s", k1);
        console.log("k2: %s", k2);

        // Now, solving for sk (private key) = (s0⋅k − z0)⋅r^(-1) mod n
        uint256 lp1k1 = submod(mulmod(uint256(S0), k1, N), uint256(z0), N);
        uint256 lp2k1 = submod(mulmod(submod(N, uint256(S0), N), k1, N), uint256(z0), N);
        uint256 lp1k2 = submod(mulmod(uint256(S0), k2, N), uint256(z0), N);
        uint256 lp2k2 = submod(mulmod(submod(N, uint256(S0), N), k2, N), uint256(z0), N);

        uint256 rp = modInv(uint256(R), N);
        uint256 sklp1k1 = mulmod(lp1k1, rp, N);
        uint256 sklp2k1 = mulmod(lp2k1, rp, N);
        uint256 sklp1k2 = mulmod(lp1k2, rp, N);
        uint256 sklp2k2 = mulmod(lp2k2, rp, N);

        console.log("sklp1k1: %s", sklp1k1);
        console.log("addr (sklp1k1): %s", vm.addr(sklp1k1));

        console.log("sklp2k1: %s", sklp2k1);
        console.log("addr (sklp2k1): %s", vm.addr(sklp2k1));

        console.log("sklp1k2: %s", sklp1k2);
        console.log("addr (sklp1k2): %s", vm.addr(sklp1k2));

        console.log("sklp2k2: %s", sklp2k2);
        console.log("addr (sklp2k2): %s", vm.addr(sklp2k2));
    }

    function normalized(uint256 v, uint256 n) internal pure returns (uint256 result) {
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
