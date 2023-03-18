[![Unit Tests](https://github.com/Coinflakes-DAO/flaix-contracts/actions/workflows/test.yml/badge.svg)](https://github.com/Coinflakes-DAO/flaix-contracts/actions/workflows/test.yml)

[![Slither Analysis](https://github.com/Coinflakes-DAO/flaix-contracts/actions/workflows/slither.yml/badge.svg)](https://github.com/Coinflakes-DAO/flaix-contracts/actions/workflows/slither.yml)

# Coinflakes DAO

## Investment Vault: Decentralized AI & Crypto Projects

## Overview

The Investment Vault is a suite of Solidity smart contracts designed to
facilitate investments in upcoming AI projects leveraging
cryptocurrencies. Our mission is to create a fully decentralized
investment platform in the future. However, to ensure stability and
growth during the initial phase, the project is managed by a dedicated
governance team.

The governance team's primary responsibility is to decide which tokens
to invest in, based on thorough research and analysis of the AI and
crypto landscape. This empowers investors to benefit from the rapid
growth in these sectors while minimizing risk through a curated
selection of projects.

## Features

- **Secure and Transparent Investments**: The Investment Vault utilizes
  smart contracts on the Ethereum blockchain to guarantee secure and
  transparent transactions.
- **Governance Team**: A dedicated team of experts with deep knowledge
  in AI and crypto industries manages the initial investment decisions.
- **Decentralized Future**: Our goal is to transition to a fully
  decentralized platform, empowering the community to have a say in the
  investment decisions.
- **AI & Crypto-Focused**: The Investment Vault exclusively invests in
  AI projects that leverage cryptocurrencies, ensuring our investments
  are focused on the most promising and innovative projects in these
  sectors.

## How It Works

1. **Token Allocation**: The governance team researches and selects the
   most promising AI and crypto projects to invest in. They then allocate
   the funds accordingly, purchasing tokens in the chosen projects.
2. **Invest**: The Vault employs a distinctive investment approach,
   providing investors with a transparent and secure method to
   participate in the Investment Vault. This is achieved by issuing
   purchase options for vault shares, which ensures a fair and
   equitable opportunity for all investors, sharing risk between
   investors and the governance team. (see below for details)
3. **Vault Tokens**: Investors receive Vault Tokens (FLAIX) representing
   their share in the Investment Vault. The value of FLAIX is tied to the
   performance of the underlying investments.
4. **Exit**: Investors have the option to redeem their shares, which
   entitles them to a proportional share of the underlying tokens.
   Furthermore, the governance team issues sell options for vault
   shares, enabling investors to sell their shares back to the
   governance team in exchange for specific assets from the vault.

## Unique investment approach

### Motivation for using options instead of directly selling shares in the Investment Vault

In the initial phase, the Investment Vault is managed by a dedicated governance
team because decentralized methods of managing investment decisions are not yet
efficient due to the limited number of participants. The governance team's
decisions should be informed by participants' discussions within the project's
Discord server, but the team should also retain the final say in investment
decisions. This is why the governance team will issue purchase options for
vault shares, ensuring a fair and equitable opportunity for all investors and
sharing risk between investors and the governance team.

### Purchase Options (CALL Options)

When the team issues purchase options, they must first buy the underlying
asset upfront using their own funds and encapsulate the acquired asset within
the options contract. Investors can then purchase these options. Neither
investors nor the team can exercise the options before they mature. Upon
maturity, options can either be exercised or revoked by their holders.

If a purchase option is exercised, it is exchanged for vault shares, and a
proportional size of the underlying asset is transferred into the vault. If a
purchase option is revoked, the underlying asset is transferred back to the
options holder, and no vault shares are issued.

This mechanism allows investors to decide whether they want to participate in
the investment or not, based on the value of the underlying asset. If the
underlying asset is worth less than the purchase price of the option, investors
can exercise the option and receive vault shares. If the underlying asset is
worth more than the purchase price of the option, investors can revoke the
option and receive their underlying asset back.

### Sell Options (PUT Options)

Sell options are issued by the team, each containing a fixed amount of a specific vault asset, and are made available for sale on the open market. Upon maturity, the options holder has the choice to either exercise or revoke the option. If the option is exercised, the vault transfers a proportional amount of the underlying asset to the options holder and burns a corresponding portion of the vault shares. Conversely, if the option is revoked, the vault reclaims the underlying asset, and the options are burned.

This mechanism enables the team to efficiently rebalance the vault's assets by selectively selling undesired assets from the vault. When the team decides to sell a particular asset, they can issue sell options for that asset, streamlining the process.

To divest assets from the vault, the team must determine a fair and attractive
market value for the underlying asset, which incentivizes investors to purchase
the options. Investors can profit by exercising the options and subsequently
selling the underlying assets, or they can trade the options on the open market
for a profit.

## Project Structure

The project is based on [Foundry](https://github.com/foundry-rs/foundry), a framework for building and deploying smart contracts on the Ethereum blockchain.

- [src/](src) - smart contracts.
  - [interfaces/](src/interfaces) - interfaces for the inclusion in other projects.
- [scripts/](scripts) - scripts for deployment on different networks.
- [test/](test) - unit tests for the smart contracts.

### Project UI

This GitHub repository contains the source code for the project's smart
contracts only. There is no UI, and the team leaves the UI implementation to
the community. If you are interested in building a UI, please contact us on
Discord (see below).

### Project Deployments

#### Ethereum Mainnet

FlaixVault (FLAIX Token): [0xA3dcc50358239De3b09F2733e1F62c0419FA6909](https://etherscan.io/address/0xa3dcc50358239de3b09f2733e1f62c0419fa6909)

:point_right: Please check Discord if you want to purchase FLAIX tokens.

#### Sepolia Testnet

The project is deployed on the Sepolia testnet. The addresses of the deployed contracts are:

FlaixVault: [0xBf24F7580c99Aae5A4872639E97C1083Fee70AD7](https://sepolia.etherscan.io/address/0xBf24F7580c99Aae5A4872639E97C1083Fee70AD7)

To get access to the admin functions of the contract, you can use the test governance
contract `FlaixTestGov` but you need to be added to the list of authorized testers first. If you want to be added, please do not hesitate to contact us on Discord (see below). The address of the test governance contract is:

FlaixTestGov: [0x03A3Db793913F8Ae464eDC950556D1A2Af174CAe](https://sepolia.etherscan.io/address/0x03A3Db793913F8Ae464eDC950556D1A2Af174CAe)

There are some ERC20 token implementations deployed on the Sepolia testnet, which can be used as an underlying asset for testing. The addresses of the deployed tokens are:

alphaAI: [0xF6a05F0eE5a6F03094c4445F073d4F3C5A73527C](https://sepolia.etherscan.io/address/0xF6a05F0eE5a6F03094c4445F073d4F3C5A73527C)

betaAI: [0x57330b118Cd86E0Cd826A200aE084a2743042E7E](https://sepolia.etherscan.io/address/0x57330b118Cd86E0Cd826A200aE084a2743042E7E)

gammaAI: [0xdd3a30199A2dA74c0991f3BEc391ACcA24BbF1D9](https://sepolia.etherscan.io/address/0xdd3a30199A2dA74c0991f3BEc391ACcA24BbF1D9)

`mint()` and `burn()` functions can be used without permission to mint/burn tokens
for/from any address.

## Getting involved

The project is currently seeking AI experts for consulting and community
managers. If you are interested in joining the team, please contact us on
Discord (see below).

Feel free to join the Discord server as an investor or just for fun and discuss the project with the team.

## Discord

Join the Discord and give be a DM (NedAlbo):
[Discord](https://discord.gg/zWsC6tSpAN)

## License

[2023 - MIT License](LICENSE)
