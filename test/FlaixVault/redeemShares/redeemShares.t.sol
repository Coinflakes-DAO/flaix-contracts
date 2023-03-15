// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RedeemSharesBase.t.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

contract RedeemShares_Test is RedeemSharesBase_Test {
    using Math for uint256;

    function test_whenUserRedeemsAll_allSharesAreBurned()
        public
        whenAliceHasShares(1000e18)
        whenVaultHoldsDai(1000e18)
        whenVaultHoldsUsdc(2000e6)
    {
        vm.prank(users.alice);
        vault.redeemShares(1000e18, users.alice);
        assertEq(vault.balanceOf(users.alice), 0);
        assertEq(vault.totalSupply(), 0);
    }

    function test_whenUserRedeemsShares_assetsAreTransferredToRecipient(
        uint256 sharesToRedeem
    ) public whenAliceHasShares(1000e18) whenVaultHoldsDai(1000e18) whenVaultHoldsUsdc(2000e6) {
        vm.assume(sharesToRedeem > 0);
        vm.assume(sharesToRedeem <= 1000e18);
        vm.prank(users.alice);
        vault.redeemShares(sharesToRedeem, users.alice);
        uint256 daiToTransfer = uint256(1000e18).mulDiv(sharesToRedeem, 1000e18);
        uint256 usdcToTransfer = (2000e6 * sharesToRedeem) / 1000e18;
        assertEq(tokens.dai.balanceOf(users.alice), daiToTransfer);
        assertEq(tokens.usdc.balanceOf(users.alice), usdcToTransfer);
    }

    function test_whenUserRedeemsSomeShares_sharesAreBurntProRata(
        uint256 sharesToRedeem
    ) public whenAliceHasShares(1000e18) whenVaultHoldsDai(1000e18) whenVaultHoldsUsdc(2000e6) {
        vm.assume(sharesToRedeem <= 1000e18);
        vm.prank(users.alice);
        vault.redeemShares(sharesToRedeem, users.alice);
        assertEq(vault.balanceOf(users.alice), 1000e18 - sharesToRedeem);
        assertEq(vault.totalSupply(), 1000e18 - sharesToRedeem);
    }

    function test_transfersNoAssetsToRecipient()
        public
        whenAliceHasNoShares
        whenVaultHoldsDai(1000e18)
        whenVaultHoldsUsdc(2000e6)
    {
        vm.prank(users.alice);
        vault.redeemShares(1000e18, users.alice);
        assertEq(tokens.dai.balanceOf(users.alice), 0);
        assertEq(tokens.usdc.balanceOf(users.alice), 0);
    }

    function test_whenMultipleUsersRedeem_sharesAreBurntProRataPerUser()
        public
        whenAliceHasShares(1000e18)
        whenBobHasShares(3000e18)
        whenVaultHoldsDai(1000e18)
        whenVaultHoldsUsdc(2000e6)
    {
        vm.prank(users.alice);
        vault.redeemShares(1000e18, users.alice);
        assertEq(vault.balanceOf(users.alice), 0);
        assertEq(vault.balanceOf(users.bob), 3000e18);
        assertEq(vault.totalSupply(), 3000e18);
        vm.prank(users.bob);
        vault.redeemShares(3000e18, users.bob);
        assertEq(vault.balanceOf(users.alice), 0);
        assertEq(vault.balanceOf(users.bob), 0);
        assertEq(vault.totalSupply(), 0);
    }

    function test_whenMultipleUsersRedeem_assetsAreTransferedProRataPerUser()
        public
        whenAliceHasShares(1000e18)
        whenBobHasShares(3000e18)
        whenVaultHoldsDai(1000e18)
        whenVaultHoldsUsdc(2000e6)
    {
        vm.prank(users.alice);
        vault.redeemShares(1000e18, users.alice);
        assertEq(tokens.dai.balanceOf(users.alice), 250e18);
        assertEq(tokens.usdc.balanceOf(users.alice), 500e6);
        vm.prank(users.bob);
        vault.redeemShares(3000e18, users.bob);
        assertEq(tokens.dai.balanceOf(users.bob), 750e18);
        assertEq(tokens.usdc.balanceOf(users.bob), 1500e6);
    }
}
