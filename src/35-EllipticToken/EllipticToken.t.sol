// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {EllipticToken} from "./EllipticToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// forge-lint: disable-next-item(asm-keccak256)
contract SolveEllipticToken is Test {
    EllipticToken token;
    address aliceAddr = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;
    uint256 amount = 0x8ac7230489e80000;
    bytes32 usedSalt = hex"04a078de06d9d2ebd86ab2ae9c2b872b26e345d33f988d6d5d875f94e9c8ee1e";
    uint256 internal sk = 0x1;

    function setUp() public {
        address deployer = makeAddr("deployer");
        vm.startPrank(deployer);
        token = new EllipticToken();
    }

    function testSolveEllipticToken() public {
        address player = vm.addr(sk);
        console.log("player: %s", player);
        vm.startPrank(player);

        bytes32 voucherHash = keccak256(abi.encodePacked(amount, aliceAddr, usedSalt));
        uint256 targetAmt = uint256(voucherHash);
        console.log("target Amt: %s", targetAmt);

        bytes memory aliceSig =
            hex"ab1dcd2a2a1c697715a62eb6522b7999d04aa952ffa2619988737ee675d9494f2b50ecce40040bcb29b5a8ca1da875968085f22b7c0a50f29a4851396251de121c";

        require(ECDSA.recover(bytes32(targetAmt), aliceSig) == aliceAddr, "Recovery failed");

        bytes32 permitAcceptHash = keccak256(abi.encodePacked(aliceAddr, player, targetAmt));
        console.log("permitAcceptHash");
        console.logBytes32(permitAcceptHash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sk, permitAcceptHash);
        bytes memory playerSig = abi.encodePacked(r, s, v);
        console.log("playerSig");
        console.logBytes(playerSig);

        // Test for Approval event
        vm.expectEmit(true, true, true, true);
        emit IERC20.Approval(aliceAddr, player, targetAmt);
        token.permit(targetAmt, player, aliceSig, playerSig);
    }
}
