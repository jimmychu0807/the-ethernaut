// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {ECDSA} from "oz-v4/contracts/utils/cryptography/ECDSA.sol";
import {Strings} from "oz-v4/contracts/utils/Strings.sol";
import {ImpersonatorTwo} from "./ImpersonatorTwo.sol";

contract AttackScript is Script {
    using Strings for uint256;

    /// constants
    uint256 SK = uint256(0x10a6891de55baf453d66c5faede86eabccf93f3d284540d205f24207670855cc);
    address INSTANCE_ADDR = 0x82f91050F5785EEce6530f55772e50D82974c0Bc;

    function run() public {
        ImpersonatorTwo target = ImpersonatorTwo(INSTANCE_ADDR);

        uint256 nonce = target.nonce();

        string memory message = string(abi.encodePacked("lock", nonce.toString()));
        bytes32 hsh = target.hash_message(message);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SK, hsh);
    }
}
