// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFlaixOption} from "@src/interfaces/IFlaixOption.sol";
import {ExerciseBase_Test} from "./ExerciseBase.t.sol";

contract Exercise_Test is ExerciseBase_Test {
  function test_whenExerciseAmountIsZero_nothingIsTransfered() public whenOptionIsMatured {
    vm.prank(users.admin);
    options.exercise(0, users.admin);
    assertEq(options.balanceOf(users.admin), 1000e18);
    assertEq(tokens.dai.balanceOf(address(options)), 1000e18);
    assertEq(vault.balanceOf(address(options)), 0);
    assertEq(vault.minterBudgetOf(address(options)), 1000e18);
  }

  function test_whenExerciseAmountIsValid_assetsAreTransferedToVault(uint256 optionsAmount) public whenOptionIsMatured {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= options.balanceOf(users.admin));
    vm.prank(users.admin);
    options.exercise(optionsAmount, users.admin);
    assertEq(tokens.dai.balanceOf(address(options)), 1000e18 - optionsAmount);
    assertEq(tokens.dai.balanceOf(address(vault)), optionsAmount);
  }

  function test_whenExerciseAmountIsValid_sharesAreTransferedToUser(uint256 optionsAmount) public whenOptionIsMatured {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= options.balanceOf(users.admin));
    vm.prank(users.admin);
    options.exercise(optionsAmount, users.admin);
    assertEq(vault.balanceOf(address(options)), 0);
    assertEq(vault.balanceOf(users.admin), optionsAmount);
  }

  function test_whenExerciseAmountIsValid_minterBudgetIsReduced(uint256 optionsAmount) public whenOptionIsMatured {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= options.balanceOf(users.admin));
    vm.prank(users.admin);
    options.exercise(optionsAmount, users.admin);
    assertEq(vault.minterBudgetOf(address(options)), 1000e18 - optionsAmount);
  }

  function test_whenExerciseAmountIsValid_optionsAreBurnt(uint256 optionsAmount) public whenOptionIsMatured {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= options.balanceOf(users.admin));
    vm.prank(users.admin);
    options.exercise(optionsAmount, users.admin);
    assertEq(options.balanceOf(users.admin), 1000e18 - optionsAmount);
    assertEq(options.totalSupply(), 1000e18 - optionsAmount);
  }

  event Exercise(address indexed recipient, uint256 amount, uint256 assetAmount);

  function test_whenExerciseAmountIsValid_emitsEvent() public whenOptionIsMatured {
    vm.prank(users.admin);
    vm.expectEmit(true, false, false, true);
    emit Exercise(users.admin, 500e18, 500e18);
    options.exercise(500e18, users.admin);
  }

  function test_whenOptionsIsNotMatured_reverts() public whenOptionIsNotMatured {
    vm.prank(users.admin);
    vm.expectRevert(IFlaixOption.OptionNotMaturedYet.selector);
    options.exercise(500e18, users.admin);
  }
}
