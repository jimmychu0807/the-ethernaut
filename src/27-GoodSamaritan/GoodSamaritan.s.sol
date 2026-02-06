// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {SolveGoodSamaritan} from "./SolveGoodSamaritan.sol";

contract SolveGoodSamaritanScript is Script {
    SolveGoodSamaritan solution;

    uint64 ASK_TIMES = 3000;

    function run(address samAddr, address solAddr) public {
        require(samAddr.code.length > 0, "samAddr is not a contract");
        require(solAddr.code.length > 0, "solAddr is not a contract");

        solution = SolveGoodSamaritan(solAddr);

        vm.startBroadcast();

        solution.requestDonation(samAddr);

        vm.stopBroadcast();
    }
}
