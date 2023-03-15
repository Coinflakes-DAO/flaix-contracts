// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract IssueCallOptionsBase_Test is FlaixVault_Test {
    modifier whenAdminHasDai(uint256 daiAmount) {
        deal(address(tokens.dai), users.admin, daiAmount, true);
        _;
    }

    modifier whenAdminHasApprovedDai(uint256 daiAmount) {
        vm.prank(users.admin);
        tokens.dai.approve(address(vault), daiAmount);
        _;
    }

    modifier whenDaiIsAllowed() {
        vm.prank(users.admin);
        vault.allowAsset(address(tokens.dai));
        _;
    }
}
