// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFeeCollector {
    event FeesReceived(
        address indexed sender,
        address indexed token0,
        address indexed token1,
        uint256 amount0,
        uint256 amount1
    );

    function onFeesReceived(address token0, address token1, uint256 amount0, uint256 amount1) external returns (bytes4);
}
