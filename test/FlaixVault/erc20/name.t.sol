// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract Name_Test is FlaixVault_Test {
    function test_name_returns_Test_Vault() public {
        assertEq(vault.name(), "Test Vault");
    }
}
