// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./MinimalOptionsMaturity.t.sol";

contract ChangeMinimalOptionsMaturity_Test is MinimalOptionsMaturity_Test {
    function test_whenValueIsValid_changesValue() public {
        vm.prank(users.admin);
        vault.changeMinimalOptionsMaturity(4 days);
        assertEq(vault.minimalOptionsMaturity(), 4 days);
    }

    function test_whenValueIsBelowMinimum_reverts() public {
        vm.prank(users.admin);
        vm.expectRevert(IFlaixVault.MaturityChangeBelowLimit.selector);
        vault.changeMinimalOptionsMaturity(3 days - 1);
    }
}
