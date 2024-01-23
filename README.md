
# Onomy Protocol Validator Setup Guide

## Introduction

### Onomy Protocol: Bridging Forex and DeFi

Onomy Protocol is an innovative Layer-1 ecosystem uniquely designed to integrate the worlds of Forex and decentralized finance (DeFi). It's powered by the Onomy Network, a proof-of-stake blockchain developed using the Cosmos SDK framework. Key features include the Arc Bridge Hub, facilitating interoperability with EVM, non-EVM, and IBC chains, and a global network of validators. As a Cosmos Tendermint-based chain, the network operates on a Proof of Stake consensus mechanism using NOM as the native coin (ANOM 10^18).

### Interchain Security

As the second parent chain in the Interchain Ecosystem, after the Cosmos Hub, Onomy Network focuses on being the hub for Forex and Real World Assets (RWAs). This enables new app chains to launch as consumer chains, secured by Onomy's validator set and offering immediate interoperability with the Onomy Exchange (ONEX) and other consumer chains.

## Prerequisites

Before installing the Onomy Validator Software, ensure you meet the following requirements:

- Hardware: 16 core CPU, 32GB RAM, 500GB enterprise SSD.
- Network: 1+ GBPS dedicated internet connection.
- Storage: Sufficient capacity for full nodes of integrated bridges and other blockchain data (1TB recommended for ETH Mainnet).

## Installation of Onomy Validator Software

### Validator Operations

As a validator, you will run:

- An Onomy Network validator node and full node.
- Full nodes for all integrated bridges to the Arc Bridge Hub (if active / required).
- Optional sentry, seed, and full / statesync public nodes.

### Installation Steps

#### How to install Onomy Validator Software

- [Mainnet](#)
- [Testnet](#)

#### Running a Full Node

- [StateSync Node Setup](#)
- [IBC Relayer Paths](#)
- [Example Configs](#)

### Networking

- Seed Nodes are provided by existing validators with public nodes.
- Full Nodes are provided by existing validators with public nodes, may be used for StateSync.

### IBC Relaying

- Run relayer nodes between parent and consumer chains.
- [Hermes Documentation](https://hermes.informal.systems/)
- [Example Hermes File](#)

### Interchain Security

- [ICS Background Information](#)
- [Bootstrapping Documentation](#)


## Documentation for Contributors

For those interested in contributing to the Onomy Protocol, please refer to our comprehensive [Contributor Documentation](#).
