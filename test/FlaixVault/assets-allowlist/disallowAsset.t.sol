// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./AssetsAllowList.t.sol";

contract AllowAsset_Test is AssetsAllowList_Test {
    function test_whenAssetIsAllowed_disallowAsset_removesAssetFromAllowList() public whenDaiIsAllowed {
        vm.prank(users.admin);
        vault.disallowAsset(address(tokens.dai));
        assertEq(vault.allowedAssets(), 0);
        assertFalse(vault.isAssetAllowed(address(tokens.dai)));
    }

    event AssetDisallowed(address asset);

    function test_whenAssetIsAllowed_disallowAsset_emitsEvent() public whenDaiIsAllowed {
        vm.prank(users.admin);
        vm.expectEmit(true, false, false, false);
        emit AssetDisallowed(address(tokens.dai));
        vault.disallowAsset(address(tokens.dai));
    }

    function test_whenAssetIsNotAllowed_disallowAsset_reverts() public whenDaiIsNotAllowed {
        vm.prank(users.admin);
        vm.expectRevert(IFlaixVault.AssetNotOnAllowList.selector);
        vault.disallowAsset(address(tokens.dai));
    }

    function test_whenNullAddressIsPassed_allowAsset_reverts() public {
        vm.prank(users.admin);
        vm.expectRevert(IFlaixVault.AssetNotOnAllowList.selector);
        vault.disallowAsset(address(0));
    }
}
