// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IUniswapV3Pool {
    function slot0() external view returns (uint160, int24, uint16, uint16, uint16, uint8, bool);

    function feeGrowthGlobal0X128() external view returns (uint256);

    function feeGrowthGlobal1X128() external view returns (uint256);

    function protocolFees() external view returns (uint128, uint128);

    function liquidity() external view returns (uint128);

    function ticks(int24 tick) external view returns (uint128, int128, uint256, uint256, int56, uint160, uint32, bool);

    function tickBitmap(int16 wordPosition) external view returns (uint256);

    function positions(bytes32 key) external view returns (uint128, uint256, uint256, uint128, uint128);

    function observations(uint256 index) external view returns (uint32, int56, uint160, bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function tickSpacing() external view returns (int24);

    function fee() external view returns (uint24);
}
