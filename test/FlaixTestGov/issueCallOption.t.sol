// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@src/FlaixTestGov.sol";
import {FlaixTestGovBase_Test} from "./FlaixTestGovBase.t.sol";

contract IssueCallOption_Test is FlaixTestGovBase_Test {
    function setUp() public virtual override {
        FlaixTestGovBase_Test.setUp();
    }

    function test_issueCallOption_whenUserIsTesterAndHasAsset_transfersAsset()
        public
        whenUserIsTester(govTester)
        whenAssetIsAllowed(tokens.dai)
        whenUserHasAsset(govTester, tokens.dai, 1000e18)
    {
        vm.startPrank(govTester);
        tokens.dai.approve(address(flaixTestGov), 1000e18);
        address options = flaixTestGov.issueCallOptions(
            "Flaix Call Option",
            "FCO",
            1000e18,
            govTester,
            address(tokens.dai),
            1000e18,
            block.timestamp + 4 days
        );
        vm.stopPrank();
        assertEq(tokens.dai.balanceOf(govTester), 0);
        assertEq(tokens.dai.balanceOf(options), 1000e18);
    }

    function test_issueCallOption_whenUserIsNotTester_reverts() public {
        vm.prank(users.admin);
        vm.expectRevert();
        flaixTestGov.issueCallOptions(
            "Flaix Call Option",
            "FCO",
            1000e18,
            govTester,
            address(tokens.dai),
            1000e18,
            block.timestamp + 4 days
        );
    }
}
