// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract IssuePutOptionsBase_Test is FlaixVault_Test {
    modifier whenAdminHasShares(uint256 sharesAmount) {
        deal(address(vault), users.admin, sharesAmount, true);
        _;
    }

    modifier whenVaultHasDai(uint256 daiAmount) {
        deal(address(tokens.dai), address(vault), daiAmount, true);
        _;
    }

    modifier whenAdminHasApprovedShares(uint256 sharesAmount) {
        vm.prank(users.admin);
        vault.approve(address(vault), sharesAmount);
        _;
    }

    modifier whenDaiIsAllowed() {
        vm.prank(users.admin);
        vault.allowAsset(address(tokens.dai));
        _;
    }
}
