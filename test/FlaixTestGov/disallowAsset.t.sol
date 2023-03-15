// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@src/FlaixTestGov.sol";
import {FlaixTestGovBase_Test} from "./FlaixTestGovBase.t.sol";

contract DisallowAsset_Test is FlaixTestGovBase_Test {
    function setUp() public virtual override {
        FlaixTestGovBase_Test.setUp();
    }

    function test_disallowAsset_whenUserIsTester_removesAsset()
        public
        whenUserIsTester(govTester)
        whenAssetIsAllowed(tokens.dai)
    {
        vm.prank(govTester);
        flaixTestGov.disallowAsset(address(tokens.dai));
        assertFalse(flaixTestGov.isAssetAllowed(address(tokens.dai)));
    }

    function test_disallowAsset_whenUserIsTester_removesAssetAllowance()
        public
        whenUserIsTester(govTester)
        whenAssetIsAllowed(tokens.dai)
    {
        vm.prank(govTester);
        flaixTestGov.disallowAsset(address(tokens.dai));
        assertEq(tokens.dai.allowance(address(flaixTestGov), address(vault)), 0);
    }

    function test_disallowAsset_whenUserIsNotTester_reverts() public {
        vm.prank(users.admin);
        vm.expectRevert();
        flaixTestGov.disallowAsset(address(tokens.dai));
    }
}
