// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract GetRequirdAmount1Test is UniswapV3PositionBaseTest {
    function test_getRequiredAmount1(uint256 amount0) public {
        vm.assume(amount0 < 10 * (10 ** 8));
        // Token 0: WBTC
        // Token 1: USDC
        // Test: Required USDC amount for 2 BTC
        // Expected: 60000 USDC (@ 30000 USD/BTC)
        //           60000 * 10 ** 6 = 60000000000
        // priceUsd has 8 decimals, same as wbtcToken
        assertEq(position.pool().token0(), WBTC);
        assertEq(position.pool().token1(), USDC);
        uint256 amount1 = position.getRequiredAmount1(amount0);
        uint256 priceUsd = uint256(btcPrice);
        uint256 amountUsd = (amount0 * priceUsd * 10 ** usdcToken.decimals()) / (10 ** (wbtcToken.decimals() * 2));
        // ~ Tolerance of 10% ~
        assertLe(amount1, amountUsd + amountUsd / 10);
        assertGe(amount1, amountUsd - amountUsd / 10);
    }

    function test_getRequiredAmount1_withZero_returnsZero() public {
        uint256 amount1 = position.getRequiredAmount1(0);
        assertEq(amount1, 0);
    }
}
