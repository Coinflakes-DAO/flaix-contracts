// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import "./AssetsAllowList.t.sol";

contract DefaultValues_Test is AssetsAllowList_Test {
    function test_whenVaultIsDeployed_assetAllowListIsEmpty() public {
        assertEq(vault.allowedAssets(), 0);
    }
}
