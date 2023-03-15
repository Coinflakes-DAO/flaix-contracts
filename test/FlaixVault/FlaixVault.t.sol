// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "../Base.t.sol";
import {FlaixVault} from "@src/FlaixVault.sol";
import {FlaixCallOption} from "@src/FlaixCallOption.sol";
import {FlaixPutOption} from "@src/FlaixPutOption.sol";
import {FlaixOptionFactory} from "@src/FlaixOptionFactory.sol";

contract FlaixVault_Test is Base_Test {
    FlaixVault public vault;

    function setUp() public virtual override {
        Base_Test.setUp();
        vm.prank(users.deployer);
        address callOptionImplementation = address(new FlaixCallOption());
        address putOptionImplementation = address(new FlaixPutOption());
        address optionFactory = address(new FlaixOptionFactory(callOptionImplementation, putOptionImplementation));
        vault = new FlaixVault(optionFactory);
        setUp_UserRoles();
    }

    function setUp_UserRoles() public {
        vm.prank(vault.admin());
        vault.changeAdmin(users.admin);
    }
}
