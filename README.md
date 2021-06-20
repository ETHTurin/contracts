# Contracts

## CMORegistry

This smart contract has mainly two functions:

- It keeps track of all the registered copyrights with associated info about the owners and their shares.
- By inheritance of the TipJar contract, it sends special tokens to the payers of the copyright.

## TipJar

This smart contract implements the ERC1155 standard and sets a series of range in which
some special tokens are sent to the payer of the rights.

# How to test

In order to test the contracts compile them using

```javascript
npx hardhat compile
```

at the same time on another terminal run a local Hardhat node instance using

```javascript
npx hardhat node
```

Now in order to deploy the previously compiled contracts run the script

```javascript
npx hardhat run --network local scripts/deploy.js
```

Now it's all set to be tested using the Hardhat console or via our [frontend](https://github.com/HackDeLaMusique/frontend)
