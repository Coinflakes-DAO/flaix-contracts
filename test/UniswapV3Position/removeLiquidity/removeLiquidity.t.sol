// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract RemoveLiquidityTest is UniswapV3PositionBaseTest {
    using Math for uint256;

    function test_removeLiquidity_burnsLPTokens(
        uint256 lpTokens
    ) public whenUserHasAddedLiquidity(users.alice, 1 * 10 ** 8) whenUserHasApprovedLiquidity(users.alice) {
        vm.assume(lpTokens <= position.balanceOf(users.alice));
        vm.assume(lpTokens > 0);
        uint256 lpTokensBefore = position.balanceOf(users.alice);
        uint256 wbtcAmount = 1 * 10 ** 8;
        uint256 amount0Min = withSlippage(wbtcAmount, 1000 /* bps */);
        amount0Min = amount0Min.mulDiv(lpTokens, lpTokensBefore);
        uint256 usdcAmount = position.getRequiredAmount1(wbtcAmount);
        uint256 amount1Min = withSlippage(usdcAmount, 1000 /* bps */);
        amount1Min = amount1Min.mulDiv(lpTokens, lpTokensBefore);
        vm.prank(users.alice);
        position.removeLiquidity(lpTokens, amount0Min, amount1Min, users.alice, block.timestamp);
        assertEq(
            position.balanceOf(users.alice),
            lpTokensBefore - lpTokens,
            "balanceOf(alice) == lpTokensBefore - lpTokens"
        );
    }

    function test_removeLiquidity_transfersTokensToSender(
        uint256 lpTokens
    )
        public
        whenUserHasAddedLiquidity(users.alice, 1 * 10 ** 8)
        whenUserHasApprovedLiquidity(users.alice)
        whenUserHasUsdc(users.alice, 0)
        whenUserHasWbtc(users.alice, 0)
    {
        vm.assume(lpTokens <= position.balanceOf(users.alice));
        vm.assume(lpTokens > 0);

        uint256 amount0Min = withSlippage(1 * 10 ** 8, 1000 /* bps */);
        uint256 amount1Min = withSlippage(position.getRequiredAmount1(1 * 10 ** 8), 1000 /* bps */);

        uint256 lpTokensBefore = position.balanceOf(users.alice);
        amount0Min = amount0Min.mulDiv(lpTokens, lpTokensBefore);
        amount1Min = amount1Min.mulDiv(lpTokens, lpTokensBefore);

        vm.prank(users.alice);
        (uint256 wbtcAmountRemoved, uint256 usdcAmountRemoved) = position.removeLiquidity(
            lpTokens,
            amount0Min,
            amount1Min,
            users.alice,
            block.timestamp
        );
        assertEq(wbtcToken.balanceOf(users.alice), wbtcAmountRemoved, "wbtcAmountRemoved == wbtc.balanceOf(alice)");
        assertEq(usdcToken.balanceOf(users.alice), usdcAmountRemoved, "usdcAmountRemoved == usdc.balanceOf(alice)");
        assertGe(wbtcToken.balanceOf(users.alice), amount0Min, "wbtcAmountRemoved >= amount0Min");
        assertGe(usdcToken.balanceOf(users.alice), amount1Min, "usdcAmountRemoved >= amount1Min");
    }

    event RemoveLiquidity(
        address indexed sender,
        address indexed recipient,
        uint256 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    function test_removeLiquidity_sendsEvents()
        public
        whenUserHasAddedLiquidity(users.alice, 1 * 10 ** 8)
        whenUserHasApprovedLiquidity(users.alice)
    {
        uint256 lpTokens = position.balanceOf(users.alice);
        uint256 amount0Min = withSlippage(1 * 10 ** 8, 1000 /* bps */);
        uint256 amount1Min = withSlippage(position.getRequiredAmount1(1 * 10 ** 8), 1000 /* bps */);
        vm.startPrank(users.alice);
        vm.expectEmit(true, true, false, false, address(position));
        emit RemoveLiquidity(users.alice, users.alice, 0, 0, 0);
        position.removeLiquidity(lpTokens, amount0Min, amount1Min, users.alice, block.timestamp);
        vm.stopPrank();
    }

    function test_removeLiquidity_collectsFees()
        public
        whenUserHasAddedLiquidity(users.alice, 1 * 10 ** 8)
        whenUserHasApprovedLiquidity(users.alice)
    {
        deal(USDC, address(position), 100 * 10 ** 6, true);
        deal(WBTC, address(position), 1 * 10 ** 6, true);
        vm.prank(users.alice);
        position.removeLiquidity(0, 0, 0, users.alice, block.timestamp);
        assertEq(usdcToken.balanceOf(position.feeCollector()), 100 * 10 ** 6, "feeCollector has received usdc fees");
        assertEq(wbtcToken.balanceOf(position.feeCollector()), 1 * 10 ** 6, "feeCollector has received wbtc fees");
    }

    event FeesCollected(
        address indexed sender,
        address indexed feeCollector,
        address indexed feeToken,
        uint256 feeAmount
    );

    function test_removeLiquidity_emits_FeesCollected_event()
        public
        whenUserHasAddedLiquidity(users.alice, 1 * 10 ** 8)
        whenUserHasApprovedLiquidity(users.alice)
    {
        deal(USDC, address(position), 100 * 10 ** 6, true);
        deal(WBTC, address(position), 1 * 10 ** 6, true);
        vm.startPrank(users.alice);
        vm.expectEmit(true, true, true, false, address(position));
        emit FeesCollected(users.alice, position.feeCollector(), WBTC, 0);
        vm.expectEmit(true, true, true, false, address(position));
        emit FeesCollected(users.alice, position.feeCollector(), USDC, 0);
        position.removeLiquidity(0, 0, 0, users.alice, block.timestamp);
        vm.stopPrank();
    }
}
