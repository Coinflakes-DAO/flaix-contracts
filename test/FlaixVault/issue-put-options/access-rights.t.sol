// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./IssuePutOptionsBase.t.sol";

contract AccessRights_Test is IssuePutOptionsBase_Test {
    function test_whenUserIsNotAdmin_revert() public {
        vm.prank(users.alice);
        vm.expectRevert(IFlaixVault.OnlyAllowedForAdmin.selector);
        vault.issuePutOptions(
            "FLAIX Put Options 2023-01-01",
            "putFLAIX-230101",
            1000e18,
            users.alice,
            address(tokens.dai),
            1000e18,
            block.timestamp + 3 days
        );
    }
}
