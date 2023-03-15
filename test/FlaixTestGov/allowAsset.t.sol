// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@src/FlaixTestGov.sol";
import {FlaixTestGovBase_Test} from "./FlaixTestGovBase.t.sol";

contract OnlyGov_Test is FlaixTestGovBase_Test {
    function setUp() public virtual override {
        FlaixTestGovBase_Test.setUp();
    }

    function test_allowAsset_whenUserIsTester_addsAsset() public whenUserIsTester(govTester) {
        vm.prank(govTester);
        flaixTestGov.allowAsset(address(tokens.dai));
        assertTrue(flaixTestGov.isAssetAllowed(address(tokens.dai)));
    }

    function test_allowAsset_whenUserIsTester_setsInfiniteAssetAllowance() public whenUserIsTester(govTester) {
        vm.prank(govTester);
        flaixTestGov.allowAsset(address(tokens.dai));
        assertEq(tokens.dai.allowance(address(flaixTestGov), address(vault)), type(uint256).max);
    }

    function test_allowAsset_whenUserIsNotTester_reverts() public {
        vm.prank(users.alice);
        vm.expectRevert();
        flaixTestGov.allowAsset(address(tokens.dai));
    }
}
