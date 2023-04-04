// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "../Base.t.sol";
import {FlaixVault} from "@src/FlaixVault.sol";

contract FlaixVault_Test is Base_Test {
    FlaixVault public vault;

    function setUp() public virtual override {
        Base_Test.setUp();
        vm.prank(users.deployer);
        vault = new FlaixVault("Test Vault", "VAULT");
        setUp_UserRoles();
    }

    function setUp_UserRoles() public {
        vm.prank(vault.admin());
        vault.changeAdmin(users.admin);
    }
}
