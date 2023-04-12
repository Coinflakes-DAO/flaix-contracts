// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract GetRequirdAmount0Test is UniswapV3PositionBaseTest {
    function test_getRequiredAmount0(uint256 amount1) public {
        // Token 0: WBTC
        // Token 1: USDC
        // Test: Required WBTC amount for 10000 USDC
        // Expected: 0.3 WBTC (@ 30000 USD/BTC)
        //           0.3 * 10 ** 8 = 30000000
        // priceUsd has 8 decimals, same as wbtcToken
        vm.assume(amount1 < 10 * (10 ** 8));
        //uint256 amount1 = 10000 * (10 ** 6);
        assertEq(position.pool().token0(), WBTC);
        assertEq(position.pool().token1(), USDC);
        uint256 amount0 = position.getRequiredAmount0(amount1);
        uint256 priceUsd = uint256(btcPrice);
        uint256 amountUsd = (amount1 * 10 ** wbtcToken.decimals() * 10 ** wbtcToken.decimals()) /
            priceUsd /
            10 ** usdcToken.decimals();
        // ~ Tolerance of 10% ~
        assertLe(amount0, amountUsd + amountUsd / 10);
        assertGe(amount0, amountUsd - amountUsd / 10);
    }
}
