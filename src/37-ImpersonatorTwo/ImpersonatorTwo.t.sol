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

    // nonce: 0, switchLock()
    bytes32 constant S0 = hex"70026fc30e4e02a15468de57155b080f405bd5b88af05412a9c3217e028537e3";

    // nonce: 1, setAdmin()
    bytes32 constant S1 = hex"4c3ac03b268ae1d2aca1201e8a936adf578a8b95a49986d54de87cd0ccb68a79";

    bytes32 constant R = hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40";

    function setUp() public {
        instance = new ImpersonatorTwo();
    }

    function testSigning() public {
        (address alice, uint256 aliceSk) = makeAddrAndKey("alice");
        bytes32 hash = keccak256("Signed by Alice");

        uint256 nonce = 0;
        string memory m0 = string(abi.encodePacked("lock", nonce.toString()));
        bytes32 z0 = instance.hash_message(m0);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(aliceSk, z0);
        console.logBytes32(r);
        console.logBytes32(s);
        console.log(v);

        nonce++;
        string memory m1 = string(abi.encodePacked("admin", nonce.toString()));
        bytes32 z1 = instance.hash_message(m1);

        (v, r, s) = vm.sign(aliceSk, z1);
        console.logBytes32(r);
        console.logBytes32(s);
        console.log(v);
    }

    function testSolveImpersonatorTwo() public view {
        // Solving for k = (z0 − z1)⋅(s0 − s1)^(-1) mod n
        // z0
        uint256 nonce = 0;
        string memory m0 = string(abi.encodePacked("lock", nonce.toString()));
        bytes32 z0 = instance.hash_message(m0);
        console.log("m0: %s", m0);
        console.logBytes32(z0);

        // z1
        nonce++;
        string memory m1 = string(abi.encodePacked("admin", nonce.toString()));
        bytes32 z1 = instance.hash_message(m1);
        console.log("m1: %s", m1);
        console.logBytes32(z1);

        uint256 zdiff = submod(uint256(z0), uint256(z1), N);
        console.log("zdiff: %s", zdiff);

        uint256 sdiff = submod(uint256(S0), uint256(S1), N);
        console.log("sdiff: %s", sdiff);

        uint256 k = mulmod(zdiff, modInv(sdiff, N), N);
        console.log("k: %s", k);

        // Now, solving for sk (private key) = (s0⋅k − z0)⋅r^(-1) mod n
        uint256 lp = submod(mulmod(uint256(S0), k, N), uint256(z0), N);
        uint256 rp = modInv(uint256(R), N);
        uint256 sk = mulmod(lp, rp, N);
        console.log("sk: %s", sk);

        // Use this owner secret key to create more signature
        address owner = vm.addr(sk);
        console.log("owner: %s", owner);
    }

    function submod(uint256 v1, uint256 v2, uint256 n) internal pure returns (uint256 result) {
        uint256 v1n = v1 % n;
        uint256 v2n = v2 % n;

        if (v1n > v2n) {
            result = v1n - v2n;
        } else {
            result = v2n - v1n;
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
