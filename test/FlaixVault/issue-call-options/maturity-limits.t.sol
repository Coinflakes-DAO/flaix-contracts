// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./IssueCallOptionsBase.t.sol";

contract MaturityLimits_Test is IssueCallOptionsBase_Test {
    function test_whenMaturityIsBelowLimit_revert() public whenDaiIsAllowed {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vm.expectRevert(IFlaixVault.MaturityTooLow.selector);
        vault.issueCallOptions(
            "FLAIX Call Options 2023-01-01",
            "callFLAIX-230101",
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
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(1000e18)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vault.issueCallOptions(
            "FLAIX Call Options 2023-01-01",
            "callFLAIX-230101",
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
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(1000e18)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vault.issueCallOptions(
            "FLAIX Call Options 2023-01-01",
            "callFLAIX-230101",
            1000e18,
            users.admin,
            address(tokens.dai),
            1000e18,
            block.timestamp + limit + 1 seconds
        );
    }
}
