// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract NameTest is UniswapV3PositionBaseTest {
    function test_name_returns_Uniswap_V3_Test_Position() public {
        assertEq(position.name(), "Uniswap V3 Test Position");
    }
}
