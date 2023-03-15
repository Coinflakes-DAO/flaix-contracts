// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./AssetsAllowList.t.sol";

contract AllowedAssets_Test is AssetsAllowList_Test {
  function test_whenDaiIsAllowed_allowedAssets_returns_1() public whenDaiIsAllowed {
    assertEq(vault.allowedAssets(), 1);
  }

  function test_whenDaiAndUsdcAreAllowed_allowedAssets_returns_2() public whenDaiAndUsdcAllowed {
    assertEq(vault.allowedAssets(), 2);
  }

  function test_whenDaiIsANotllowed_allowedAssets_returns_0() public whenDaiIsNotAllowed {
    assertEq(vault.allowedAssets(), 0);
  }
}
