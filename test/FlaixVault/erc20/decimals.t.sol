// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract Decimals_Test is FlaixVault_Test {
    function test_flaixvault_decimals_returns_18() public {
        assertEq(vault.decimals(), 18);
    }
}
