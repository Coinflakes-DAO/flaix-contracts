// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract RemoveLiquidityTest is UniswapV3PositionBaseTest {
    function test_removeLiquidity_burnsLPTokens()
        public
        whenUserHasAddedLiquidity(users.alice, 1 * 10 ** 8)
        whenUserHasApprovedLiquidity(users.alice)
    {
        uint256 lpTokens = position.balanceOf(users.alice);
        uint256 wbtcAmount = 1 * 10 ** 8;
        uint256 amount0Min = withSlippage(wbtcAmount, 1000 /* bps */);
        uint256 usdcAmount = position.getRequiredAmount1(wbtcAmount);
        uint256 amount1Min = withSlippage(usdcAmount, 1000 /* bps */);
        vm.prank(users.alice);
        position.removeLiquidity(lpTokens, amount0Min, amount1Min, users.alice, block.timestamp);
        assertEq(position.balanceOf(users.alice), 0);
    }
}
