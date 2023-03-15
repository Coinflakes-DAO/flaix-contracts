// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DefaultValueBase_Test} from "./DefaultValueBase.t.sol";

contract Erc20MetaData_Test is DefaultValueBase_Test {
  function test_whenCalled_returnsName() public {
    assertEq(options.name(), "Flaix Options");
  }

  function test_whenCalled_returnsSymbol() public {
    assertEq(options.symbol(), "optFLAIX");
  }

  function test_whenCalled_returnsDecimals() public {
    assertEq(options.decimals(), 18);
  }
}
