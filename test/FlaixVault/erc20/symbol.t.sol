// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract Symbol_Test is FlaixVault_Test {
    function test_symbol() public {
        assertEq(vault.symbol(), "FLAIX");
    }
}
