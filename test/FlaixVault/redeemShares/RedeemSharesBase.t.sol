// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract RedeemSharesBase_Test is FlaixVault_Test {
    modifier whenVaultHoldsDai(uint256 daiBalance) {
        vm.startPrank(users.admin);
        vault.allowAsset(address(tokens.dai));
        vm.stopPrank();
        deal(address(tokens.dai), address(vault), 1000e18, true);
        _;
    }

    modifier whenVaultHoldsUsdc(uint256 usdcBalance) {
        vm.startPrank(users.admin);
        vault.allowAsset(address(tokens.usdc));
        vm.stopPrank();
        deal(address(tokens.usdc), address(vault), 2000e6, true);
        _;
    }

    modifier whenAliceHasNoShares() {
        assertEq(vault.balanceOf(users.alice), 0);
        _;
    }

    modifier whenBobHasNoShares() {
        assertEq(vault.balanceOf(users.bob), 0);
        _;
    }

    modifier whenAliceHasShares(uint256 alicesShares) {
        deal(address(vault), users.alice, 1000e18, true);
        _;
    }

    modifier whenBobHasShares(uint256 bobsShares) {
        deal(address(vault), users.bob, bobsShares, true);
        _;
    }
}
