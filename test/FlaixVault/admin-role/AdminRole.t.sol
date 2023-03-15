// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract AdminRole_Test is FlaixVault_Test {
    modifier whenUserIsAdmin() {
        vm.prank(vault.admin());
        vault.changeAdmin(users.admin);
        assertTrue(vault.admin() == users.admin, "Pre-condition failed: test user should be admin");
        _;
    }

    modifier whenUserIsNotAdmin() {
        vm.prank(vault.admin());
        vault.changeAdmin(users.deployer);
        assertFalse(vault.admin() == users.admin, "Pre-condition failed: test user should not be admin");
        _;
    }
}
