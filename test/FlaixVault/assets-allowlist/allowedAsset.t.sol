// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./AssetsAllowList.t.sol";

contract AllowedAsset_Test is AssetsAllowList_Test {
    function test_whenDaiIsAllowed_allowedAssetAt0_isDai() public whenDaiIsAllowed {
        assertEq(vault.allowedAsset(0), address(tokens.dai));
    }

    function test_whenDaiAndUsdcAreAllowed_allowedAssetAt0_isDai() public whenDaiAndUsdcAllowed {
        assertEq(vault.allowedAsset(0), address(tokens.dai));
    }

    function test_whenDaiAndUsdcAreAllowed_allowedAssetAt1_isUsdc() public whenDaiAndUsdcAllowed {
        assertEq(vault.allowedAsset(1), address(tokens.usdc));
    }

    function test_whenDaiAndUsdcAreAllowed_allowedAssetAt2_reverts() public whenDaiAndUsdcAllowed {
        vm.expectRevert(bytes("FlaixVault: index out of bounds"));
        vault.allowedAsset(2);
    }
}
