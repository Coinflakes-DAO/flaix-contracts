// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConvertToAssetsBase_Test} from "./ConvertToAssetsBase.t.sol";

contract ConvertToAssets_Test is ConvertToAssetsBase_Test {
  function test_whenCalled_returns_numberOfAssetsPerOption(uint256 optionsAmount) public {
    vm.assume(optionsAmount > 0);
    vm.assume(optionsAmount <= 1000e18);
    assertEq(options.convertToAssets(optionsAmount), optionsAmount);
  }
}
