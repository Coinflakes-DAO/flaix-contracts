// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DefaultValueBase_Test} from "./DefaultValueBase.t.sol";

contract Balances_Test is DefaultValueBase_Test {
  function test_totalSupply_returns_1000e18() public {
    assertEq(options.totalSupply(), 1000e18);
  }

  function test_numberOfShares_returns_0() public {
    assertEq(vault.balanceOf(address(options)), 0);
  }

  function test_minterBudget_returns_1000e18() public {
    assertEq(vault.minterBudgetOf(address(options)), 1000e18);
  }

  function test_numberOfAssets_returns_1000e18() public {
    assertEq(tokens.dai.balanceOf(address(options)), 1000e18);
  }
}
