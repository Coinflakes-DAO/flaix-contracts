// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/uniswapv3/UniswapV3Position.sol";

contract UniswapV3WethPosition is UniswapV3Position {
    IWETH public WETH9;
    IERC20Metadata public asset;

    bool private isToken0Weth;

    constructor(
        string memory name,
        string memory symbol,
        address uniswapPositionManager,
        address uniswapPool,
        address feeCollectorAddress
    ) UniswapV3Position(name, symbol, uniswapPositionManager, uniswapPool, feeCollectorAddress) {
        isToken0Weth = pool.token0() == address(WETH9);
        WETH9 = IWETH(isToken0Weth ? pool.token0() : pool.token1());
        asset = IERC20Metadata(isToken0Weth ? pool.token1() : pool.token0());
    }

    function getRequiredAssetAmount(uint256 wethAmount) public view returns (uint256 assetAmount) {
        return isToken0Weth ? getRequiredAmount1(wethAmount) : getRequiredAmount0(wethAmount);
    }

    function getRequiredWethAmount(uint256 assetAmount) public view returns (uint256 wethAmount) {
        return isToken0Weth ? getRequiredAmount0(assetAmount) : getRequiredAmount1(assetAmount);
    }

    function addLiquidity(
        uint256 wethAmount,
        uint256 assetAmount,
        uint256 wethAmountMin,
        uint256 assetAmountMin,
        address recipient,
        uint256 deadline
    ) public virtual override returns (uint256 liquidityAdded, uint256 wethAmountAdded, uint256 assetAmountAdded) {
        if (isToken0Weth) {
            (liquidityAdded, wethAmountAdded, assetAmountAdded) = super.addLiquidity(
                wethAmount,
                assetAmount,
                wethAmountMin,
                assetAmountMin,
                recipient,
                deadline
            );
        } else {
            (liquidityAdded, assetAmountAdded, wethAmountAdded) = super.addLiquidity(
                assetAmount,
                wethAmount,
                assetAmountMin,
                wethAmountMin,
                recipient,
                deadline
            );
        }
    }

    function addLiquidityEth(
        uint256 assetAmount,
        uint256 wethAmountMin,
        uint256 assetAmountMin,
        address recipient,
        uint256 deadline
    ) public payable nonReentrant returns (uint256 liquidityAdded, uint256 wethAmountAdded, uint256 assetAmountAdded) {
        uint256 wethAmount = msg.value;
        WETH9.deposit{value: wethAmount}();
        (liquidityAdded, wethAmountAdded, assetAmountAdded) = addLiquidity(
            wethAmount,
            assetAmount,
            wethAmountMin,
            assetAmountMin,
            recipient,
            deadline
        );
    }

    function removeLiquidity(
        uint256 liquidity,
        uint256 wethAmountMin,
        uint256 assetAmountMin,
        address recipient,
        uint256 deadline
    ) public virtual override nonReentrant returns (uint256 wethAmount, uint256 assetAmount) {
        if (isToken0Weth) {
            (wethAmount, assetAmount) = super.removeLiquidity(
                liquidity,
                wethAmountMin,
                assetAmountMin,
                recipient,
                deadline
            );
        } else {
            (assetAmount, wethAmount) = super.removeLiquidity(
                liquidity,
                assetAmountMin,
                wethAmountMin,
                recipient,
                deadline
            );
        }
    }
}
