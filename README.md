# AgroChain
This project showcases a smart contract that can be used to implement a transparent supply chain with no trusted central authority.

This is a submission to Smart India Hackathon 2025 problem statement SIH25045.

## Technical Overview
A technical overview of the smart contract can be found [here](technical_details.pdf).

## Specification

A formal specification of the smart contract in TLA<sup>+</sup> [can be  found here](supply_chain.pdf).

## Frontend Design

The frontend design of the application can be found [here](https://www.figma.com/site/Q70y5vFrlnL0XYa6i5ScSD/).

## Project Overview

This project includes
- A supply chain [smart contract](contracts/SupplyChain.sol).
- Foundry-compatible Solidity unit tests.
- TypeScript integration tests using [`node:test`](nodejs.org/api/test.html), the new Node.js native test runner, and [`viem`](https://viem.sh/).

## Usage

### Running Tests

To run all the tests in the project, execute the following command:

```shell
npx hardhat test
```

You can also selectively run the Solidity or `node:test` tests:

```shell
npx hardhat test solidity
npx hardhat test nodejs
```

### Make a deployment to Sepolia

You can deploy this module to a locally simulated chain or to Sepolia.

To run the deployment to a local chain:

```shell
npx hardhat ignition deploy ignition/modules/SupplyChain.ts
```

To run the deployment to Sepolia, you need an account with funds to send the transaction. The provided Hardhat configuration includes a Configuration Variable called `SEPOLIA_PRIVATE_KEY`, which you can use to set the private key of the account you want to use.

You can set the `SEPOLIA_PRIVATE_KEY` variable using the `hardhat-keystore` plugin or by setting it as an environment variable.

To set the `SEPOLIA_PRIVATE_KEY` config variable using `hardhat-keystore`:

```shell
npx hardhat keystore set SEPOLIA_PRIVATE_KEY
```

After setting the variable, you can run the deployment with the Sepolia network:

```shell
npx hardhat ignition deploy --network sepolia ignition/modules/SupplyChain.ts
```
