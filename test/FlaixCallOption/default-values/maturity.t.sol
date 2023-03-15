// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DefaultValueBase_Test} from "./DefaultValueBase.t.sol";

contract Maturity_Test is DefaultValueBase_Test {
  function test_whenCalled_returns_3days() public {
    assertEq(options.maturityTimestamp(), block.timestamp + 3 days);
  }
}
