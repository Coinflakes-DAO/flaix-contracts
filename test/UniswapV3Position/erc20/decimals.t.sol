// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract DecimalsTest is UniswapV3PositionBaseTest {
    function test_position_decimals_returns_18() public {
        assertEq(position.decimals(), 18);
    }
}
