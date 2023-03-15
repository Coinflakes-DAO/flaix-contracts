// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFlaixOption} from "@src/interfaces/IFlaixOption.sol";
import {RevokeBase_Test} from "./RevokeBase.t.sol";

contract Exercise_Test is RevokeBase_Test {
  function test_whenRevokeAmountIsZero_nothingIsTransfered() public whenOptionIsMatured {
    vm.prank(users.admin);
    options.revoke(0, users.admin);
    assertEq(options.balanceOf(users.admin), 1000e18);
    assertEq(tokens.dai.balanceOf(address(options)), 1000e18);
    assertEq(vault.balanceOf(address(options)), 0);
    assertEq(vault.minterBudgetOf(address(options)), 1000e18);
  }

  function test_whenRevokeAmountIsValid_assetsAreTransferedToRecipient(uint256 optionsAmount)
    public
    whenOptionIsMatured
  {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= options.balanceOf(users.admin));
    vm.prank(users.admin);
    options.revoke(optionsAmount, users.admin);
    assertEq(tokens.dai.balanceOf(address(options)), 1000e18 - optionsAmount);
    assertEq(tokens.dai.balanceOf(users.admin), optionsAmount);
  }

  function test_whenExerciseAmountIsValid_minter_budget_is_reduced(uint256 optionsAmount) public whenOptionIsMatured {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= options.balanceOf(users.admin));
    vm.prank(users.admin);
    options.revoke(optionsAmount, users.admin);
    assertEq(vault.minterBudgetOf(address(options)), 1000e18 - optionsAmount);
  }

  function test_whenExerciseAmountIsValid_optionsAreBurnt(uint256 optionsAmount) public whenOptionIsMatured {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= options.balanceOf(users.admin));
    vm.prank(users.admin);
    options.revoke(optionsAmount, users.admin);
    assertEq(options.balanceOf(users.admin), 1000e18 - optionsAmount);
    assertEq(options.totalSupply(), 1000e18 - optionsAmount);
  }

  event Revoke(address indexed recipient, uint256 amount);

  function test_whenExerciseAmountIsValid_emitsEvent() public whenOptionIsMatured {
    vm.prank(users.admin);
    vm.expectEmit(true, false, false, true);
    emit Revoke(users.admin, 500e18);
    options.revoke(500e18, users.admin);
  }

  function test_whenOptionsIsNotMatured_reverts() public whenOptionIsNotMatured {
    vm.prank(users.admin);
    vm.expectRevert(IFlaixOption.OptionNotMaturedYet.selector);
    options.revoke(500e18, users.admin);
  }
}
