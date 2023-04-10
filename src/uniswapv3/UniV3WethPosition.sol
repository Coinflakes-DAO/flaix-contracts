// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@src/interfaces/uniswapv3/IUniswapV3Pool.sol";
import "@src/interfaces/uniswapv3/INonfungiblePositionManager.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@mock-tokens/interfaces/IWETH.sol";

contract UniV3WethPosition is ERC20 {
    using Math for uint256;
    using SafeERC20 for IERC20Metadata;

    int24 internal constant MAX_TICK_DEFAULT = 887272;
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    IERC20Metadata public immutable WETH9;
    IERC20Metadata public asset;

    INonfungiblePositionManager public immutable positionManager;
    IUniswapV3Pool public pool;

    uint256 public positionId = 0;

    int24 private tickLower;
    int24 private tickUpper;

    address private token0;
    address private token1;
    uint24 private poolFee;

    event MintPosition(address indexed sender, address indexed recipient, uint256 indexed positionId);

    event IncreaseLiquidity(
        address indexed sender,
        address indexed recipient,
        uint256 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    event DecreaseLiquidity(
        address indexed sender,
        address indexed recipient,
        uint256 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    constructor(
        string memory name,
        string memory symbol,
        address uniswapPositionManager,
        address uniswapPool
    ) ERC20(name, symbol) {
        require(
            uniswapPositionManager != address(0),
            "UniswapV3PositionMinter: nonfungiblePositionManager is the zero address"
        );

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
        asset = pool.token0() == wethAddress ? IERC20Metadata(pool.token1()) : IERC20Metadata(pool.token0());
        int24 tickSpacing = pool.tickSpacing();
        tickUpper = tickSpacing * (MAX_TICK_DEFAULT / tickSpacing);
        tickLower = -tickUpper;
    }

    function getRequiredWethAmount(uint256 amount) internal view returns (uint256 wethAmount) {
        uint256 wethPerVaultToken = _getSpotPrice();
        wethAmount = amount.mulDiv(wethPerVaultToken, 10 ** asset.decimals());
    }

    function addLiquidity(
        uint256 assetAmount,
        uint256 wethAmount,
        uint256 assetAmountMin,
        uint256 wethAmountMin,
        address recipient
    ) public returns (uint256 assetAmountAdded, uint256 wethAmountAdded) {
        require(assetAmount > 0 || wethAmount > 0, "UniswapV3PositionMinter: amount is zero");
        require(recipient != address(0), "UniswapV3PositionMinter: recipient is the zero address");
        WETH9.safeTransferFrom(msg.sender, address(this), wethAmount);
        asset.safeTransferFrom(msg.sender, address(this), assetAmount);
        WETH9.safeApprove(address(positionManager), wethAmount);
        asset.safeApprove(address(positionManager), assetAmount);
        uint256 liquidityCreated = 0;
        if (positionId == 0) {
            (positionId, liquidityCreated, assetAmountAdded, wethAmountAdded) = _mintPosition(
                assetAmount,
                wethAmount,
                assetAmountMin,
                wethAmountMin,
                recipient,
                block.timestamp
            );
            emit MintPosition(msg.sender, recipient, positionId);
        } else {
            (liquidityCreated, assetAmountAdded, wethAmountAdded) = _increaseLiquidity(
                assetAmount,
                wethAmount,
                assetAmountMin,
                wethAmountMin,
                recipient,
                block.timestamp
            );
        }
        if (assetAmountAdded < assetAmount) asset.safeTransfer(msg.sender, assetAmount - assetAmountAdded);
        if (wethAmountAdded < wethAmount) WETH9.safeTransfer(msg.sender, wethAmount - wethAmountAdded);
        emit IncreaseLiquidity(msg.sender, recipient, liquidityCreated, assetAmountAdded, wethAmountAdded);
    }

    function removeLiquidity(
        uint256 liquidity,
        uint256 assetAmountMin,
        uint256 wethAmountMin,
        address recipient,
        uint256 deadline
    ) public returns (uint256 amount0, uint256 amount1) {
        require(liquidity > 0, "UniswapV3PositionMinter: liquidity is zero");
        require(recipient != address(0), "UniswapV3PositionMinter: recipient is the zero address");

        IERC20Metadata(this).safeTransferFrom(msg.sender, address(this), liquidity);
        (amount0, amount1) = _removeLiquidity(liquidity, assetAmountMin, wethAmountMin, deadline);
        if (token0 == address(WETH9)) {
            WETH9.safeTransfer(recipient, amount0);
        } else {
            asset.safeTransfer(recipient, amount0);
        }
        if (token1 == address(WETH9)) {
            WETH9.safeTransfer(recipient, amount1);
        } else {
            asset.safeTransfer(recipient, amount1);
        }
        emit DecreaseLiquidity(msg.sender, recipient, liquidity, amount0, amount1);
    }

    function _mintPosition(
        uint256 assetAmount,
        uint256 wethAmount,
        uint256 assetAmountMin,
        uint256 wethAmountMin,
        address recipient,
        uint256 deadline
    )
        private
        returns (uint256 newPositionId, uint256 liquidityCreated, uint256 assetAmountAdded, uint256 wethAmountAdded)
    {
        uint256 amount0Desired = token0 == address(WETH9) ? wethAmount : assetAmount;
        uint256 amount1Desired = token1 == address(WETH9) ? wethAmount : assetAmount;
        uint256 amount0Min = token0 == address(WETH9) ? wethAmountMin : assetAmountMin;
        uint256 amount1Min = token1 == address(WETH9) ? wethAmountMin : assetAmountMin;
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: poolFee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: recipient,
            deadline: deadline
        });
        (uint256 tokenId, uint256 liquidity, uint256 amount0Added, uint256 amount1Added) = positionManager.mint(params);
        newPositionId = tokenId;
        liquidityCreated = liquidity;
        assetAmountAdded = token0 == address(WETH9) ? amount1Added : amount0Added;
        wethAmountAdded = token0 == address(WETH9) ? amount0Added : amount1Added;
        _mint(recipient, liquidity);
    }

    function _increaseLiquidity(
        uint256 assetAmount,
        uint256 wethAmount,
        uint256 assetAmountMin,
        uint256 wethAmountMin,
        address recipient,
        uint256 deadline
    ) private returns (uint256 liquidityCreated, uint256 assetAmountAdded, uint256 wethAmountAdded) {
        uint256 amount0Desired = token0 == address(WETH9) ? wethAmount : assetAmount;
        uint256 amount1Desired = token1 == address(WETH9) ? wethAmount : assetAmount;
        uint256 amount0Min = token0 == address(WETH9) ? wethAmountMin : assetAmountMin;
        uint256 amount1Min = token1 == address(WETH9) ? wethAmountMin : assetAmountMin;
        INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
            .IncreaseLiquidityParams({
                tokenId: positionId,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                deadline: deadline
            });
        (uint256 liquidity, uint256 amount0Added, uint256 amount1Added) = positionManager.increaseLiquidity(params);
        liquidityCreated = liquidity;
        assetAmountAdded = token0 == address(WETH9) ? amount1Added : amount0Added;
        wethAmountAdded = token0 == address(WETH9) ? amount0Added : amount1Added;
        _mint(recipient, liquidity);
    }

    function _removeLiquidity(
        uint256 liquidity,
        uint256 assetAmountMin,
        uint256 wethAmountMin,
        uint256 deadline
    ) private returns (uint256 amount0, uint256 amount1) {
        uint256 amount0Min = token0 == address(WETH9) ? wethAmountMin : assetAmountMin;
        uint256 amount1Min = token1 == address(WETH9) ? wethAmountMin : assetAmountMin;

        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager
            .DecreaseLiquidityParams({
                tokenId: positionId,
                liquidity: uint128(liquidity),
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                deadline: deadline
            });
        (amount0, amount1) = positionManager.decreaseLiquidity(params);
        _burn(address(this), liquidity);
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
