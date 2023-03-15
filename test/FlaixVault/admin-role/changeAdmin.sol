// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./AdminRole.t.sol";

contract FlaixVault_changeAmin_Test is AdminRole_Test {
    function test_whenUserIsNotAdmin_revert() public whenUserIsNotAdmin {
        vm.prank(users.admin);
        vm.expectRevert(IFlaixVault.OnlyAllowedForAdmin.selector);
        vault.changeAdmin(users.alice);
    }

    function test_whenUserIsAdmin_changeAdminAccount() public whenUserIsAdmin {
        vm.prank(users.admin);
        vault.changeAdmin(users.alice);
        assertEq(vault.admin(), users.alice);
    }

    event AdminChanged(address newAdmin, address oldAdmin);

    function test_whenUserIsAdmin_emitsAdminChanged() public whenUserIsAdmin {
        vm.prank(users.admin);
        vm.expectEmit(true, true, false, false);
        emit AdminChanged(users.bob, users.admin);
        vault.changeAdmin(users.bob);
    }
}
