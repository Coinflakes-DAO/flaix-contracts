// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./MinimalOptionsMaturity.t.sol";

contract AccessRights_Test is MinimalOptionsMaturity_Test {
    function whenUserIsAdmin_changesValue() public {
        vm.prank(users.admin);
        vault.changeMinimalOptionsMaturity(4 days);
    }

    function whenUserIsNotAdmin_revert() public {
        vm.prank(users.alice);
        vm.expectRevert(IFlaixVault.OnlyAllowedForAdmin.selector);
        vault.changeMinimalOptionsMaturity(4 days);
    }
}
