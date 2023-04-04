// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./AssetsAllowList.t.sol";

contract AllowAsset_Test is AssetsAllowList_Test {
    function test_whenAssetIsNotAllowed_allowAsset_addsAssetToAllowList() public whenDaiIsNotAllowed {
        vm.prank(users.admin);
        vault.allowAsset(address(tokens.dai));
        assertEq(vault.allowedAssets(), 1);
        assertEq(vault.isAssetAllowed(address(tokens.dai)), true);
    }

    event AssetAllowed(address asset);

    function test_whenAssetIsNotAllowed_allowAsset_emitsEvent() public whenDaiIsNotAllowed {
        vm.prank(users.admin);
        vm.expectEmit(true, false, false, false);
        emit AssetAllowed(address(tokens.dai));
        vault.allowAsset(address(tokens.dai));
    }

    function test_whenAssetIsAlreadyAllowed_allowAsset_reverts() public whenDaiIsAllowed {
        vm.prank(users.admin);
        vm.expectRevert(bytes("FlaixVault: asset already allowed"));
        vault.allowAsset(address(tokens.dai));
    }

    function test_whenNullAddressIsPassed_allowAsset_reverts() public {
        vm.prank(users.admin);
        vm.expectRevert(bytes("FlaixVault: asset address cannot be null"));
        vault.allowAsset(address(0));
    }
}
