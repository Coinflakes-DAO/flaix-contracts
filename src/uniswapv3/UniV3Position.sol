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

import "@src/interfaces/IFlaixVault.sol";

contract UniV3Position is ERC20 {
    using Math for uint256;
    using SafeERC20 for IERC20Metadata;

    int24 internal constant MAX_TICK_DEFAULT = 887272;
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

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

        pool = IUniswapV3Pool(uniswapPool);
        token0 = pool.token0();
        token1 = pool.token1();
        poolFee = pool.fee();
        int24 tickSpacing = pool.tickSpacing();
        tickUpper = tickSpacing * (MAX_TICK_DEFAULT / tickSpacing);
        tickLower = -tickUpper;
    }

    function getRequiredAmount1(uint256 amount0) public view returns (uint256 amount1) {
        (uint256 price0, ) = _getSpotPrice();
        amount1 = amount0.mulDiv(price0, 10 ** IERC20Metadata(token0).decimals());
    }

    function getRequiredAmount0(uint256 amount1) public view returns (uint256 amount0) {
        (, uint256 price1) = _getSpotPrice();
        amount0 = amount1.mulDiv(price1, 10 ** IERC20Metadata(token1).decimals());
    }

    function addLiquidity(
        uint256 amount0,
        uint256 amount1,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient
    ) public virtual returns (uint256 amount0Added, uint256 amount1Added) {
        require(amount0 > 0 || amount1 > 0, "UniswapV3PositionMinter: amount is zero");
        require(recipient != address(0), "UniswapV3PositionMinter: recipient is the zero address");
        IERC20Metadata(token0).safeTransferFrom(msg.sender, address(this), amount0);
        IERC20Metadata(token1).safeTransferFrom(msg.sender, address(this), amount1);
        IERC20Metadata(token0).safeApprove(address(positionManager), amount0);
        IERC20Metadata(token1).safeApprove(address(positionManager), amount1);
        uint256 liquidity = 0;
        if (positionId == 0) {
            (positionId, liquidity, amount0Added, amount1Added) = _mintPosition(
                amount0,
                amount1,
                amount0Min,
                amount1Min,
                recipient,
                block.timestamp
            );
            emit MintPosition(msg.sender, recipient, positionId);
        } else {
            (liquidity, amount0Added, amount1Added) = _increaseLiquidity(
                amount0,
                amount1,
                amount0Min,
                amount1Min,
                recipient,
                block.timestamp
            );
        }
        if (amount0Added < amount0) IERC20Metadata(token0).safeTransfer(msg.sender, amount0 - amount0Added);
        if (amount1Added < amount1) IERC20Metadata(token1).safeTransfer(msg.sender, amount1 - amount1Added);
        emit IncreaseLiquidity(msg.sender, recipient, liquidity, amount0Added, amount1Added);
    }

    function removeLiquidity(
        uint256 liquidity,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline
    ) public virtual returns (uint256 amount0, uint256 amount1) {
        require(liquidity > 0, "UniswapV3PositionMinter: liquidity is zero");
        require(recipient != address(0), "UniswapV3PositionMinter: recipient is the zero address");

        IERC20Metadata(this).safeTransferFrom(msg.sender, address(this), liquidity);
        (amount0, amount1) = _removeLiquidity(liquidity, amount0Min, amount1Min, deadline);
        IERC20Metadata(token0).safeTransfer(recipient, amount0);
        IERC20Metadata(token1).safeTransfer(recipient, amount1);
        emit DecreaseLiquidity(msg.sender, recipient, liquidity, amount0, amount1);
    }

    function _mintPosition(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline
    ) internal returns (uint256 newPositionId, uint256 liquidityCreated, uint256 amount0Added, uint256 amount1Added) {
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
        (uint256 tokenId, uint256 liquidity, uint256 amount0Added_, uint256 amount1Added_) = positionManager.mint(
            params
        );
        amount0Added = amount0Added_;
        amount1Added = amount1Added_;
        newPositionId = tokenId;
        liquidityCreated = liquidity;
        _mint(recipient, liquidity);
    }

    function _increaseLiquidity(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline
    ) internal returns (uint256 liquidity, uint256 amount0Added, uint256 amount1Added) {
        INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
            .IncreaseLiquidityParams({
                tokenId: positionId,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                deadline: deadline
            });
        (liquidity, amount0Added, amount1Added) = positionManager.increaseLiquidity(params);
        _mint(recipient, liquidity);
    }

    function _removeLiquidity(
        uint256 liquidity,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 deadline
    ) internal returns (uint256 amount0, uint256 amount1) {
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

    function _getSpotPrice() internal view returns (uint256 price0, uint256 price1) {
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint256 decimals0 = IERC20Metadata(token0).decimals();
        uint256 decimals1 = IERC20Metadata(token1).decimals();
        uint256 price = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        uint256 oneToken0 = 10 ** decimals0;
        uint256 oneToken1 = 10 ** decimals1;
        price0 = price.mulDiv(oneToken0, 1 << 192);
        price1 = oneToken1.mulDiv(price0, oneToken0);
    }
}
