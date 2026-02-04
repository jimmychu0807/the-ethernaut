// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceSender {
    constructor() payable {} // fund this contract on deployment
    receive() external payable {} // or fund later

    function forceSend(address payable target) external {
        selfdestruct(target); // sends all ETH to target, no fallback/receive called
    }
}
