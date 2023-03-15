// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./IssuePutOptionsBase.t.sol";

contract MaturityLimits_Test is IssuePutOptionsBase_Test {
    function test_whenMaturityIsBelowLimit_revert() public whenDaiIsAllowed {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vm.expectRevert(IFlaixVault.MaturityTooLow.selector);
        vault.issuePutOptions(
            "FLAIX Put Options 2023-01-01",
            "putFLAIX-230101",
            1000e18,
            users.admin,
            address(tokens.dai),
            1000e18,
            block.timestamp + limit - 1 seconds
        );
    }

    function test_whenMaturityIsAtLimit_doesNotRevert()
        public
        whenDaiIsAllowed
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
        whenVaultHasDai(1000e18)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
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

    function test_whenMaturityIsAboveLimit_doesNotRevert()
        public
        whenDaiIsAllowed
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
        whenVaultHasDai(1000e18)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vault.issuePutOptions(
            "FLAIX Put Options 2023-01-01",
            "putFLAIX-230101",
            1000e18,
            users.admin,
            address(tokens.dai),
            1000e18,
            block.timestamp + limit + 1 seconds
        );
    }
}
