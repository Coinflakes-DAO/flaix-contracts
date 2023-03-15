// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DefaultValueBase_Test} from "./DefaultValueBase.t.sol";

contract Asset_Test is DefaultValueBase_Test {
  function test_whenCalled_returns_assetAddress() public {
    assertEq(options.asset(), address(tokens.dai));
  }
}
