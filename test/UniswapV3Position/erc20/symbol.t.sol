// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@test/UniswapV3Position/UniswapV3PositionBase.t.sol";

contract SymbolTest is UniswapV3PositionBaseTest {
    function test_symbol_returns_UNIV3_TEST_POS() public {
        assertEq(position.symbol(), "UNIV3-TEST-POS");
    }
}
