# Ethernaut

- https://ethernaut.openzeppelin.com/
- player: [0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7](https://sepolia.etherscan.io/address/0xB0fD5a878DBF3F9358A251caF9b6Fc692A999cA7)
- Sepolia Network
- `_ethers.version` == **5.7.2**


## Problem 2: Fallback

contract addr: [0x119fBFcF1b46DcCB3EEae3f40A06bf29f79e3d57](https://sepolia.etherscan.io/address/0x119fBFcF1b46DcCB3EEae3f40A06bf29f79e3d57)

Solutions

1. Run:
   ```ts
   await contract.contribute({value: _ethers.utils.parseEther("0.0001") })
   ```
   - you are not allowed to contribute 0.001 ether or more to the contract

2. Send 0.0001 tokens to your practice contract from wallet

   - you have became the owner by this point.

3. Run:
   ```ts
   await contract.withdraw()
   ```

4. Submit the contract

Note: beware the max gas limit restricted on Sepolia that metamask won't automatically detect.

## Problem 3: Fallout

contract addr: [0x25d51fC62EfE411ffe273434D1aE20a1a513022d](https://sepolia.etherscan.io/address/0x25d51fC62EfE411ffe273434D1aE20a1a513022d)

Solutions

1. Run:

   ```ts
   await contract.Fal1out()
   ```

   Everyone can call this function and claim the ownership of the contract

## Problem 4: Coin Flip

- **CoinFlip** contract addr: [0xFb9BcE79EbE63c7551A9EB856b03Eb9E56742dCb](https://sepolia.etherscan.io/address/0xFb9BcE79EbE63c7551A9EB856b03Eb9E56742dCb)
- **SolveCoinFlip** contract addr: [0x8A7BC0BBD97bcDeAf5456E42259e191Fc761A176](https://eth-sepolia.blockscout.com/address/0x8A7BC0BBD97bcDeAf5456E42259e191Fc761A176)
- You can't use typescript js to do this. You need to deploy a contract to attack this contract

## Problem 5: Telephone

- **Telephone** contract addr: [0x92385004C0Af2AE55764d9DD34e747971B4CEb2D](https://sepolia.etherscan.io/address/0x92385004C0Af2AE55764d9DD34e747971B4CEb2D)
- **SolveTelephone** contract addr: [0x399981F8FB9398378a5f9D2E4713dfed803e2a10](https://sepolia.etherscan.io/address/0x399981F8FB9398378a5f9D2E4713dfed803e2a10)
