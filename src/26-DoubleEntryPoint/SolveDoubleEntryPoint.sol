// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDetectionBot, IForta} from "./DoubleEntryPoint.sol";

contract DetectionBot is IDetectionBot {
    /// storage
    IForta public forta;

    constructor(address _fortaAddr) {
        require(_fortaAddr.code.length > 0, "_fortaAddr is not a contract");

        forta = IForta(_fortaAddr);
    }

    // function _transfer(address from, address to, uint256 value) external {}
    function delegateTransfer(address to, uint256 value, address origSender) external {}

    function handleTransaction(address user, bytes calldata msgData) external {
        if (msgData.length < 4) return;

        // casting to 'bytes4' is safe because as the length is checked above.
        // forge-lint: disable-next-line(unsafe-typecast)
        bytes4 first4Bytes = bytes4(msgData);
        bytes4 transferSel = this.delegateTransfer.selector;

        if (transferSel != first4Bytes) return;

        forta.raiseAlert(user);
    }
}
