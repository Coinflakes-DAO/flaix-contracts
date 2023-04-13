// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract AddLiquidityTest is UniswapV3PositionBaseTest {
    function test_addLiquidity_createsNewPositionId()
        public
        whenUserHasApprovedWbtc(users.alice)
        whenUserHasApprovedUsdc(users.alice)
        whenUserHasWbtc(users.alice, 3 * 10 ** 8)
        whenUserHasEnoughUsdc(users.alice, 3 * 10 ** 8)
        whenToken0IsWbtc
        whenToken1IsUsdc
    {
        uint256 amount0 = 2 * (10 ** 8);
        uint256 amount1 = position.getRequiredAmount1(amount0);
        assertEq(position.positionId(), 0);
        vm.startPrank(users.alice);
        uint256 amount0Min = withSlippage(amount0, 1000 /* bps */);
        uint256 amount1Min = withSlippage(amount1, 1000 /* bps */);
        position.addLiquidity(amount0, amount1, amount0Min, amount1Min, users.alice, block.timestamp);
        vm.stopPrank();

        assertGt(position.positionId(), 0);
        assertEq(position.positionManager().ownerOf(position.positionId()), address(position));
    }

    function test_addLiquidity_mintsNewLPs()
        public
        whenUserHasApprovedWbtc(users.alice)
        whenUserHasApprovedUsdc(users.alice)
        whenUserHasWbtc(users.alice, 3 * 10 ** 8)
        whenUserHasEnoughUsdc(users.alice, 3 * 10 ** 8)
        whenToken0IsWbtc
        whenToken1IsUsdc
    {
        uint256 amount0 = 2 * (10 ** 8);
        uint256 amount1 = position.getRequiredAmount1(amount0);
        assertEq(position.balanceOf(users.alice), 0);
        vm.startPrank(users.alice);
        uint256 amount0Min = withSlippage(amount0, 1000 /* bps */);
        uint256 amount1Min = withSlippage(amount1, 1000 /* bps */);
        position.addLiquidity(amount0, amount1, amount0Min, amount1Min, users.alice, block.timestamp);
        vm.stopPrank();
        assertGt(position.balanceOf(users.alice), 0);
    }

    function test_addLiquidity_usesSamePositionId()
        public
        whenUserHasApprovedWbtc(users.alice)
        whenUserHasApprovedUsdc(users.alice)
        whenUserHasWbtc(users.alice, 3 * 10 ** 8)
        whenUserHasEnoughUsdc(users.alice, 3 * 10 ** 8)
        whenToken0IsWbtc
        whenToken1IsUsdc
    {
        uint256 amount0 = 1 * (10 ** 8);
        uint256 amount1 = position.getRequiredAmount1(amount0);
        assertEq(position.positionId(), 0);
        vm.startPrank(users.alice);
        uint256 amount0Min = withSlippage(amount0, 1000 /* bps */);
        uint256 amount1Min = withSlippage(amount1, 1000 /* bps */);
        position.addLiquidity(amount0, amount1, amount0Min, amount1Min, users.alice, block.timestamp);
        vm.stopPrank();
        assertGt(position.positionId(), 0);

        amount0 = 1 * (10 ** 8);
        amount1 = position.getRequiredAmount1(amount0);
        uint256 positionId = position.positionId();
        vm.startPrank(users.alice);
        amount0Min = withSlippage(amount0, 1000 /* bps */);
        amount1Min = withSlippage(amount1, 1000 /* bps */);
        position.addLiquidity(amount0, amount1, amount0Min, amount1Min, users.alice, block.timestamp);
        vm.stopPrank();
        assertEq(position.positionId(), positionId);
    }

    event MintPosition(address indexed sender, address indexed recipient, uint256 indexed positionId);
    event IncreaseLiquidity(
        address indexed sender,
        address indexed recipient,
        uint256 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    function test_addLiquidity_emitsMintAndIncreaseLiquidityEvents()
        public
        whenUserHasApprovedWbtc(users.alice)
        whenUserHasApprovedUsdc(users.alice)
        whenUserHasWbtc(users.alice, 3 * 10 ** 8)
        whenUserHasEnoughUsdc(users.alice, 3 * 10 ** 8)
        whenToken0IsWbtc
        whenToken1IsUsdc
    {
        uint256 amount0 = 1 * (10 ** 8);
        uint256 amount1 = position.getRequiredAmount1(amount0);
        vm.startPrank(users.alice);
        vm.expectEmit(true, true, false, false, address(position));
        emit MintPosition(users.alice, users.alice, 0);
        vm.expectEmit(true, true, false, false, address(position));
        emit IncreaseLiquidity(users.alice, users.alice, 0, 0, 0);
        position.addLiquidity(amount0, amount1, 0, 0, users.alice, block.timestamp);
        vm.stopPrank();
    }

    function test_addLiquidity_transfersReturnedTokenAmounts()
        public
        whenUserHasApprovedWbtc(users.alice)
        whenUserHasApprovedUsdc(users.alice)
        whenUserHasWbtc(users.alice, 3 * 10 ** 8)
        whenUserHasEnoughUsdc(users.alice, 3 * 10 ** 8)
        whenToken0IsWbtc
        whenToken1IsUsdc
    {
        uint256 amount0Desired = 1 * (10 ** 8);
        uint256 amount1Desired = position.getRequiredAmount1(amount0Desired);
        uint256 amount0Min = withSlippage(amount0Desired, 1000 /* bps */);
        uint256 amount1Min = withSlippage(amount1Desired, 1000 /* bps */);
        uint256 amount0Before = wbtcToken.balanceOf(users.alice);
        uint256 amount1Before = usdcToken.balanceOf(users.alice);
        vm.startPrank(users.alice);
        (, uint256 amount0Added, uint256 amount1Added) = position.addLiquidity(
            amount0Desired,
            amount1Desired,
            amount0Min,
            amount1Min,
            users.alice,
            block.timestamp
        );
        vm.stopPrank();
        uint256 amount0After = wbtcToken.balanceOf(users.alice);
        uint256 amount1After = usdcToken.balanceOf(users.alice);
        assertEq(amount0After, amount0Before - amount0Added);
        assertEq(amount1After, amount1Before - amount1Added);
    }

    function test_addLiquidity_reverts_whenUserHasNotEnoughToken0Balance()
        public
        whenUserHasApprovedWbtc(users.alice)
        whenUserHasApprovedUsdc(users.alice)
        whenUserHasEnoughUsdc(users.alice, 3 * 10 ** 8)
        whenToken0IsWbtc
        whenToken1IsUsdc
    {
        uint256 amount0Desired = 1 * (10 ** 8);
        uint256 amount1Desired = position.getRequiredAmount1(amount0Desired);
        vm.startPrank(users.alice);
        vm.expectRevert();
        position.addLiquidity(amount0Desired, amount1Desired, 0, 0, users.alice, block.timestamp);
        vm.stopPrank();
    }

    function test_addLiquidity_reverts_whenUserHasNotEnoughToken1Balance()
        public
        whenUserHasApprovedWbtc(users.alice)
        whenUserHasApprovedUsdc(users.alice)
        whenUserHasWbtc(users.alice, 3 * 10 ** 8)
        whenToken0IsWbtc
        whenToken1IsUsdc
    {
        uint256 amount0Desired = 1 * (10 ** 8);
        uint256 amount1Desired = position.getRequiredAmount1(amount0Desired);
        vm.startPrank(users.alice);
        vm.expectRevert();
        position.addLiquidity(amount0Desired, amount1Desired, 0, 0, users.alice, block.timestamp);
        vm.stopPrank();
    }
}
