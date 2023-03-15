// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract AssetsAllowList_Test is FlaixVault_Test {
    modifier whenDaiIsAllowed() {
        vm.prank(users.admin);
        vault.allowAsset(address(tokens.dai));
        _;
    }

    modifier whenDaiIsNotAllowed() {
        vm.prank(users.admin);
        if (vault.isAssetAllowed(address(tokens.dai))) vault.disallowAsset(address(tokens.dai));
        _;
    }

    modifier whenDaiAndUsdcAllowed() {
        vm.startPrank(users.admin);
        vault.allowAsset(address(tokens.dai));
        vault.allowAsset(address(tokens.usdc));
        vm.stopPrank();
        _;
    }
}
