// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MinimalOptionsMaturity.t.sol";

contract DefaultValues_Test is MinimalOptionsMaturity_Test {
  function test_defaultValue() public {
    assertEq(vault.minimalOptionsMaturity(), 3 days);
  }
}
