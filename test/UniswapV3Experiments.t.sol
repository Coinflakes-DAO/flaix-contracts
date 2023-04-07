// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@mock-tokens/interfaces/IWETH.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@src/interfaces/uniswapv3/INonfungiblePositionManager.sol";
import "@src/interfaces/uniswapv3/IUniswapV3Pool.sol";
import "@src/interfaces/uniswapv3/IMulticall.sol";

import "@src/libraries/uniswapv3/PoolHelper.sol";

import "./Base.t.sol";

contract UniswapV3Experiments_Test is Base_Test {
    using Math for uint256;
    using SafeERC20 for IERC20;

    address POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public override {
        super.setUp();
    }

    function test_uniswapv3_CRV_vs_eth_only() public {
        IWETH weth = IWETH(WETH);
        IERC20 crv = IERC20(CRV);
        uint24 poolFee = 3000;

        PoolHelper poolHelper = new PoolHelper(POSITION_MANAGER, WETH, CRV, poolFee);

        uint256 amountWeth = 0.1 ether;
        uint256 amountCrv = poolHelper.convertTokenAmountAtSpotPrice(WETH, amountWeth);
        console.log("WETH amount: ", amountWeth);
        console.log("CRV amount: ", amountCrv);

        vm.startPrank(users.alice);
        deal(users.alice, 1 ether + amountWeth);
        weth.deposit{value: amountWeth}();
        deal(CRV, users.alice, amountCrv, true);

        IERC20(WETH).safeApprove(address(poolHelper), amountWeth);
        crv.safeApprove(address(poolHelper), amountCrv);

        (uint256 tokenId, uint128 liquidity, uint256 amount0Used, uint256 amount1Used) = poolHelper.addLiquidity(
            WETH,
            amountWeth,
            amountCrv,
            100,
            users.alice
        );
        console.log("=>");
        console.log("tokenId: ", tokenId);
        console.log("liquidity: ", liquidity);
        console.log("amount0Used: ", amount0Used);
        console.log("amount1Used: ", amount1Used);
        vm.stopPrank();
    }
}
