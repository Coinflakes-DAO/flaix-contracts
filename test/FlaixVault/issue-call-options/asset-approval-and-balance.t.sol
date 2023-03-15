// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./IssueCallOptionsBase.t.sol";

contract AssetAllowList_Test is IssueCallOptionsBase_Test {
    function test_whenUserHasNotEnoughAssets_revert()
        public
        whenDaiIsAllowed
        whenAdminHasDai(999e18)
        whenAdminHasApprovedDai(1000e18)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
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

    function test_whenUserHasNotApprovedEnoughAssets_revert()
        public
        whenDaiIsAllowed
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(999e18)
    {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        vm.expectRevert("ERC20: insufficient allowance");
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
}
