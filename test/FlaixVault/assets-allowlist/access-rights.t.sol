// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./AssetsAllowList.t.sol";

contract AccessRights_Test is AssetsAllowList_Test {
  function test_whenUserIsAdmin_allowAsset_DoesNotRevert() public whenDaiIsNotAllowed {
    vm.prank(users.admin);
    vault.allowAsset(address(tokens.dai));
  }

  function test_whenUserIsNotAdmin_allowAsset_reverts() public whenDaiIsNotAllowed {
    vm.prank(users.alice);
    vm.expectRevert(IFlaixVault.OnlyAllowedForAdmin.selector);
    vault.allowAsset(address(tokens.dai));
  }

  function test_whenUserIsAdmin_disallowAsset_DoesNotRevert() public whenDaiIsAllowed {
    vm.prank(users.admin);
    vault.disallowAsset(address(tokens.dai));
  }

  function test_whenUserIsNotAdmin_disallowAsset_reverts() public whenDaiIsAllowed {
    vm.prank(users.alice);
    vm.expectRevert(IFlaixVault.OnlyAllowedForAdmin.selector);
    vault.disallowAsset(address(tokens.dai));
  }
}
