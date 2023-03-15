// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./IssueCallOptionsBase.t.sol";

contract AccessRights_Test is IssueCallOptionsBase_Test {
    function test_whenUserIsNotAdmin_revert() public {
        vm.prank(users.alice);
        vm.expectRevert(IFlaixVault.OnlyAllowedForAdmin.selector);
        vault.issueCallOptions(
            "FLAIX Call Options 2023-01-01",
            "callFLAIX-230101",
            1000e18,
            users.alice,
            address(tokens.dai),
            1000e18,
            block.timestamp + 3 days
        );
    }
}
