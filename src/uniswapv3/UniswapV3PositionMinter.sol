// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@src/interfaces/uniswapv3/IUniswapV3Pool.sol";
import "@src/interfaces/uniswapv3/INonfungiblePositionManager.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@mock-tokens/interfaces/IWETH.sol";

import "@src/interfaces/IFlaixVault.sol";

contract UniswapV3PositionMinter {
    using Math for uint256;
    using SafeERC20 for IERC20Metadata;

    int24 internal constant MAX_TICK_DEFAULT = 887272;
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    IERC20Metadata public immutable WETH9;
    IERC20Metadata public vaultAsset;

    IFlaixVault public immutable vault;
    INonfungiblePositionManager public immutable positionManager;
    IUniswapV3Pool public pool;

    uint256 public positionId = 0;

    int24 private tickLower;
    int24 private tickUpper;

    address private token0;
    address private token1;
    uint24 private poolFee;

    constructor(address flaixVault, address uniswapPositionManager, address uniswapPool) {
        require(
            uniswapPositionManager != address(0),
            "UniswapV3PositionMinter: nonfungiblePositionManager is the zero address"
        );
        require(flaixVault != address(0), "UniswapV3PositionMinter: flaixVault is the zero address");

        vault = IFlaixVault(flaixVault);
        positionManager = INonfungiblePositionManager(uniswapPositionManager);
        address wethAddress = positionManager.WETH9();
        WETH9 = IWETH(wethAddress);
        pool = IUniswapV3Pool(uniswapPool);
        token0 = pool.token0();
        token1 = pool.token1();
        poolFee = pool.fee();
        require(
            token0 == address(WETH9) || pool.token1() == address(WETH9),
            "UniswapV3PositionMinter: WETH9 is not a pool token"
        );
        vaultAsset = pool.token0() == wethAddress ? IERC20Metadata(pool.token1()) : IERC20Metadata(pool.token0());
        int24 tickSpacing = pool.tickSpacing();
        tickUpper = tickSpacing * (MAX_TICK_DEFAULT / tickSpacing);
        tickLower = -tickUpper;
    }

    function getRequiredWethAmount(uint256 amount) internal view returns (uint256 wethAmount) {
        uint256 wethPerVaultToken = _getSpotPrice();
        wethAmount = amount.mulDiv(wethPerVaultToken, 10 ** vaultAsset.decimals());
    }

    function addLiquidity(
        uint256 assetAmount,
        uint256 wethAmount,
        address recipient,
        uint256 slippageBps
    ) public returns (uint256 assetAmountAdded, uint256 wethAmountAdded) {
        require(assetAmount > 0 || wethAmount > 0, "UniswapV3PositionMinter: amount is zero");
        WETH9.safeTransferFrom(msg.sender, address(this), wethAmount);
        vaultAsset.safeTransferFrom(msg.sender, address(this), assetAmount);
        WETH9.safeApprove(address(positionManager), wethAmount);
        vaultAsset.safeApprove(address(positionManager), assetAmount);
        if (positionId == 0) {
            (positionId, assetAmountAdded, wethAmountAdded) = _mintPosition(
                assetAmount,
                wethAmount,
                recipient,
                slippageBps,
                block.timestamp
            );
        } else {
            (assetAmountAdded, wethAmountAdded) = _increaseLiquidity(
                assetAmount,
                wethAmount,
                slippageBps,
                block.timestamp
            );
        }
        if (assetAmountAdded < assetAmount) vaultAsset.safeTransfer(msg.sender, assetAmount - assetAmountAdded);
        if (wethAmountAdded < wethAmount) WETH9.safeTransfer(msg.sender, wethAmount - wethAmountAdded);
    }

    function _mintPosition(
        uint256 assetAmount,
        uint256 wethAmount,
        address recipient,
        uint256 slippageBps,
        uint256 deadline
    ) private returns (uint256 newPositionId, uint256 assetAmountAdded, uint256 wethAmountAdded) {
        uint256 amount0Desired = token0 == address(WETH9) ? wethAmount : assetAmount;
        uint256 amount1Desired = token1 == address(WETH9) ? wethAmount : assetAmount;
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: amount0Desired.mulDiv(10000 - slippageBps, 10000),
            amount1Min: amount1Desired.mulDiv(10000 - slippageBps, 10000),
            recipient: recipient,
            deadline: deadline
        });
        (uint256 tokenId, , uint256 amount0Added, uint256 amount1Added) = positionManager.mint(params);
        newPositionId = tokenId;
        assetAmountAdded = token0 == address(WETH9) ? amount1Added : amount0Added;
        wethAmountAdded = token0 == address(WETH9) ? amount0Added : amount1Added;
    }

    function _increaseLiquidity(
        uint256 assetAmount,
        uint256 wethAmount,
        uint256 slippageBps,
        uint256 deadline
    ) private returns (uint256 assetAmountAdded, uint256 wethAmountAdded) {
        uint256 amount0Desired = token0 == address(WETH9) ? wethAmount : assetAmount;
        uint256 amount1Desired = token1 == address(WETH9) ? wethAmount : assetAmount;
        INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
            .IncreaseLiquidityParams({
                tokenId: positionId,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: amount0Desired.mulDiv(10000 - slippageBps, 10000),
                amount1Min: amount1Desired.mulDiv(10000 - slippageBps, 10000),
                deadline: deadline
            });
        (, uint256 amount0Added, uint256 amount1Added) = positionManager.increaseLiquidity(params);
        assetAmountAdded = token0 == address(WETH9) ? amount1Added : amount0Added;
        wethAmountAdded = token0 == address(WETH9) ? amount0Added : amount1Added;
    }

    function _getSpotPrice() public view returns (uint256 wethPerVaultToken) {
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint256 decimals0 = IERC20Metadata(token0).decimals();
        uint256 decimals1 = IERC20Metadata(token1).decimals();
        uint256 price = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        uint256 oneToken0 = 10 ** decimals0;
        uint256 oneToken1 = 10 ** decimals1;
        uint256 price0 = price.mulDiv(oneToken0, 1 << 192);
        uint256 price1 = oneToken1.mulDiv(price0, oneToken0);
        wethPerVaultToken = token0 == address(WETH9) ? price0 : price1;
    }
}
