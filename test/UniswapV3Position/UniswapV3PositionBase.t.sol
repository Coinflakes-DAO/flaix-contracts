// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/Base.t.sol";
import "@src/uniswapv3/UniswapV3Position.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract UniswapV3PositionBaseTest is Base_Test {
    UniswapV3Position public position;

    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant POOL = 0x99ac8cA7087fA4A2A1FB6357269965A2014ABc35;
    address public constant UNISWAP_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    IERC20Metadata fraxToken = IERC20Metadata(WBTC);
    IERC20Metadata usdcToken = IERC20Metadata(USDC);

    function setUp() public override {
        super.setUp();
        setUp_tokens();
        setUp_userFunds();
        setUp_Position();
    }

    function setUp_userFunds() public {
        deal(WBTC, users.alice, 10 * 10 ** 8, true);
        deal(USDC, users.alice, 10000 * 10 ** 6, true);
    }

    function setUp_Position() public {
        position = new UniswapV3Position("Uniswap V3 Test Position", "UNIV3-TEST-POS", UNISWAP_POSITION_MANAGER, POOL);
    }
}
