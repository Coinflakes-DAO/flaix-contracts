// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@src/interfaces/uniswapv3/INonfungiblePositionManager.sol";
import "@src/interfaces/uniswapv3/IUniswapV3Pool.sol";
import "@mock-tokens/interfaces/IWETH.sol";

contract PoolHelper {
    using Math for uint256;
    using SafeERC20 for IERC20;

    int24 internal constant MAX_TICK_DEFAULT = 887272;
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    INonfungiblePositionManager public positionManager;

    IUniswapV3Pool public pool;
    int24 public tickLower;
    int24 public tickUpper;

    IWETH public immutable WETH9;

    constructor(address nonfungiblePositionManager, address token0, address token1, uint256 poolFee) {
        positionManager = INonfungiblePositionManager(nonfungiblePositionManager);
        WETH9 = IWETH(positionManager.WETH9());

        if (token0 > token1) (token0, token1) = (token1, token0);
        address factory = positionManager.factory();
        address poolAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encode(token0, token1, poolFee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
        pool = IUniswapV3Pool(poolAddress);
        int24 tickSpacing = pool.tickSpacing();
        tickUpper = tickSpacing * (MAX_TICK_DEFAULT / tickSpacing);
        tickLower = -tickUpper;
    }

    function getSpotPrice() public view returns (address token0, address token1, uint256 price0, uint256 price1) {
        token0 = pool.token0();
        token1 = pool.token1();
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint256 decimals0 = IERC20Metadata(token0).decimals();
        uint256 decimals1 = IERC20Metadata(token1).decimals();
        uint256 price = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        uint256 oneToken0 = 10 ** decimals0;
        uint256 oneToken1 = 10 ** decimals1;
        price0 = price.mulDiv(oneToken0, 1 << 192);
        price1 = oneToken1.mulDiv(price0, oneToken0);
    }

    function convertTokenAmountAtSpotPrice(address tokenA, uint256 amountA) public view returns (uint256 amountB) {
        (address token0, address token1, uint256 price0, uint256 price1) = getSpotPrice();
        require(tokenA == token0 || tokenA == token1, "UniswapV3Helper: INVALID_TOKEN");
        if (tokenA == token0) {
            amountB = amountA.mulDiv(price1, 10 ** IERC20Metadata(token0).decimals());
        } else {
            amountB = amountA.mulDiv(10 ** IERC20Metadata(token1).decimals(), price0, Math.Rounding.Up);
        }
    }

    function addLiquidity(
        address tokenA,
        uint256 amountA,
        uint256 amountB,
        uint256 maxSlippageBps,
        address recipient
    ) public returns (uint256 tokenId, uint128 liquidity, uint256 amount0Used, uint256 amount1Used) {
        address token0 = pool.token0();
        address token1 = pool.token1();
        require(tokenA == token0 || tokenA != token1, "UniswapV3Helper: INVALID_TOKEN_A");

        uint256 amount0 = tokenA == token0 ? amountA : amountB;
        uint256 amount1 = tokenA == token0 ? amountB : amountA;

        uint256 amount0Min = amount0.mulDiv(10000 - maxSlippageBps, 10000);
        uint256 amount1Min = amount1.mulDiv(10000 - maxSlippageBps, 10000);

        IERC20(token0).safeTransferFrom(msg.sender, address(this), amount0);
        IERC20(token1).safeTransferFrom(msg.sender, address(this), amount1);

        IERC20(token0).safeApprove(address(positionManager), amount0);
        IERC20(token1).safeApprove(address(positionManager), amount1);

        (tokenId, liquidity, amount0Used, amount1Used) = positionManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: pool.fee(),
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                recipient: recipient,
                deadline: block.timestamp
            })
        );
        if (amount0Used < amount0) {
            IERC20(token0).safeTransfer(msg.sender, amount0 - amount0Used);
        }
        if (amount1Used < amount1) {
            IERC20(token1).safeTransfer(msg.sender, amount1 - amount1Used);
        }
    }
}
