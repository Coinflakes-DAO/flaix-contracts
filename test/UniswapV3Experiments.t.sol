// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@mock-tokens/interfaces/IWETH.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@src/interfaces/uniswapv3/INonFungiblePositionManager.sol";
import "@src/interfaces/uniswapv3/IUniswapV3Pool.sol";
import "@src/interfaces/uniswapv3/IMulticall.sol";

import "@src/libraries/uniswapv3/PoolAddress.sol";

import "./Base.t.sol";

contract UniswapV3Experiments_Test is Base_Test {
    using Math for uint256;

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    INonFungiblePositionManager public immutable nftManager =
        INonFungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    address CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public override {
        super.setUp();
    }

    function test_uniswapv3_CRV_vs_eth_only() public {

        address token0 = WETH;
        address token1 = CRV;
        uint24 poolFee = 3000;

        uint8 decimals0 = IERC20Metadata(token0).decimals();
        
        address poolAddress = PoolAddress.computeAddress(
            nftManager.factory(),
            PoolAddress.PoolKey({token0: token0, token1: token1, fee: poolFee})
        );
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        int24 tickSpacing = pool.tickSpacing();
        
        (uint160 sqrtPriceX96, , , , , ,) = pool.slot0();
        console.log("Pool Address: ", poolAddress);
        console.log("sqrtPriceX96: ", sqrtPriceX96);
        uint256 amount0 = 10 * (10 ** decimals0);
        uint256 numerator1 = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        uint256 numerator2 = 10 ** decimals0;
        uint256 price0 = numerator1.mulDiv(numerator2, 1 << 192);
        
        uint amount1 = amount0.mulDiv(price0, 10 ** decimals0);
        console.log("amount0", amount0);
        console.log("amount1", amount1);

        deal(CRV, users.alice, amount1, true);
        deal(users.alice, 100 ether);

        vm.startPrank(users.alice);
        IERC20Metadata(CRV).approve(address(nftManager), amount1);
        IWETH(WETH).deposit{value: amount0}();
        IERC20Metadata(WETH).approve(address(nftManager), amount0);

        int24 tickLower = (MIN_TICK / tickSpacing) * tickSpacing;
        int24 tickUpper = -tickLower;

        INonFungiblePositionManager.MintParams memory params = INonFungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: 1000,
            amount1Min: 1000,
            recipient: users.alice,
            deadline: block.timestamp
        });

/*        bytes memory call0 = abi.encodeWithSelector(nftManager.mint.selector, params);
        bytes[] memory calls = new bytes[](1);
        calls[0] = call0;
        IMulticall(address(nftManager)).multicall(calls);*/
        nftManager.mint{value: amount0}(params);
        vm.stopPrank();
        
    }

    /*function getLiquidityForAmounts(
        address token0,
        address token1,
        uint24 fee,
        uint256 amount0Desired,
        int24 tickLower,
        int24 tickUpper
    ) public view returns (uint256 amount0, uint256 amount1) {
        (uint160 sqrtRatioX96, , , , , , ) = IUniswapV3Pool(
            PoolAddress.computeAddress(
                nftManager.factory(),
                PoolAddress.PoolKey({token0: token0, token1: token1, fee: fee})
            )
        ).slot0();

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmount0(
            TickMath.getSqrtRatioAtTick(tickLower),
            TickMath.getSqrtRatioAtTick(tickUpper),
            amount0Desired
        );
        return
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                liquidity
            );
    }*/
}

/*function test_uniswapV3_stables() public {
        uint256 amountDai = 1000 * (10 ** 18);
        uint256 amountUsdc = 1000 * (10 ** 6);

        vm.startPrank(users.alice);
        NFTCustodian custodian = new NFTCustodian();
        address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        deal(DAI, users.alice, amountDai, true);
        deal(USDC, users.alice, amountUsdc, true);
        IERC20Metadata(DAI).approve(address(custodian), amountDai);
        IERC20Metadata(USDC).approve(address(custodian), amountUsdc);

        custodian.mintNewPosition(DAI, amountDai, USDC, amountUsdc, 3000);
        vm.stopPrank();
    }

    function test_uniswapV3_CRV_and_eth() public {
        vm.startPrank(users.alice);
        NFTCustodian custodian = new NFTCustodian();

        address factory = custodian.nonfungiblePositionManager().factory();
        PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(CRV, WETH, 10000);
        address poolAddress = PoolAddress.computeAddress(factory, poolKey);
        console.log("Pool Address: ", poolAddress);

        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);

        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint price = sqrtPriceX96ToUint(sqrtPriceX96, IERC20Metadata(pool.token0()).decimals());
        console.log("Pool price: ", price);

        IERC20Metadata CRVToken = IERC20Metadata(CRV);
        IERC20Metadata wethToken = IERC20Metadata(WETH);

        uint256 amountCRV = 529 * (10 ** 18);
        uint256 amountWeth = amountCRV.mulDiv(price, 10 ** 18);
        console.log("Amount CRV: ", amountCRV);
        console.log("Amount WETH: ", amountWeth);

        CRVToken.approve(address(custodian), amountCRV);
        wethToken.approve(address(custodian), amountWeth);

        custodian.mintNewPosition(CRV, amountCRV, WETH, amountWeth, poolFee);

        vm.stopPrank();
    }

    function sqrtPriceX96ToUint(uint160 sqrtPriceX96, uint8 decimalsToken0) internal pure returns (uint256) {
        uint256 numerator1 = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        uint256 numerator2 = 10 ** decimalsToken0;
        return numerator1.mulDiv(numerator2, 1 << 192);
    }
*/
