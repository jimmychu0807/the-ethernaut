// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Forta, LegacyToken, CryptoVault, DoubleEntryPoint} from "./DoubleEntryPoint.sol";
import {DetectionBot} from "./SolveDoubleEntryPoint.sol";

contract SolveDoubleEntryPointTest is Test {
    CryptoVault cryptoVault;
    Forta forta;
    LegacyToken LET;
    DoubleEntryPoint DET;
    address vaultOwner;

    function setUp() public {
        vaultOwner = makeAddr("vaultOwner");
        vm.startPrank(vaultOwner);

        cryptoVault = new CryptoVault(vaultOwner);
        forta = new Forta();
        LET = new LegacyToken();

        DET = new DoubleEntryPoint(address(LET), address(cryptoVault), address(forta), vaultOwner);

        // set underlying asset
        cryptoVault.setUnderlying(address(DET));

        // mint 10 legacyToken
        LET.mint(address(cryptoVault), 1 ether);
        LET.delegateToNewContract(DET);
    }

    function testDetectionBot() public {
        vm.startPrank(vaultOwner);

        DetectionBot bot = new DetectionBot(address(forta));
        forta.setDetectionBot(address(bot));

        vm.expectRevert("Alert has been triggered, reverting");
        cryptoVault.sweepToken(LET);
    }
}
