// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./IssuePutOptionsBase.t.sol";

contract AssetAllowList_Test is IssuePutOptionsBase_Test {
    function test_whenUserHasNotEnoughShares_revert()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasApprovedShares(1000e18)
        whenAdminHasShares(1000e18 - 1)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        vault.issuePutOptions(
            "FLAIX Put Options 2023-01-01",
            "putFLAIX-230101",
            1000e18,
            users.admin,
            address(tokens.dai),
            1000e18,
            block.timestamp + limit
        );
    }

    function test_whenUserHasNotApprovedEnoughShares_revert()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasApprovedShares(1000e18 - 1)
        whenAdminHasShares(1000e18)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vm.expectRevert("ERC20: insufficient allowance");
        vault.issuePutOptions(
            "FLAIX Put Options 2023-01-01",
            "putFLAIX-230101",
            1000e18,
            users.admin,
            address(tokens.dai),
            1000e18,
            block.timestamp + limit
        );
    }
}
