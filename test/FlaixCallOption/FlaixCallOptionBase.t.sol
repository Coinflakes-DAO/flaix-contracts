// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "../Base.t.sol";
import {FlaixVault} from "@src/FlaixVault.sol";
import {FlaixCallOption} from "@src/FlaixCallOption.sol";
import {FlaixPutOption} from "@src/FlaixPutOption.sol";
import {FlaixOptionFactory} from "@src/FlaixOptionFactory.sol";

contract FlaixCallOptionBase_Test is Base_Test {
    FlaixVault public vault;
    FlaixCallOption public options;

    function setUp() public override {
        super.setUp();
        setUp_vault();
        setUp_issueCallOptions();
    }

    function setUp_vault() public {
        address callOptionImplementation = address(new FlaixCallOption());
        address putOptionImplementation = address(new FlaixPutOption());
        address optionFactory = address(new FlaixOptionFactory(callOptionImplementation, putOptionImplementation));
        vault = new FlaixVault(optionFactory);
        vm.prank(vault.admin());
        vault.changeAdmin(users.admin);
    }

    function setUp_issueCallOptions() public {
        deal(address(tokens.dai), users.admin, 1000e18, true);
        vm.startPrank(users.admin);
        tokens.dai.approve(address(vault), 1000e18);
        vault.allowAsset(address(tokens.dai));
        options = FlaixCallOption(
            vault.issueCallOptions(
                "Flaix Options",
                "optFLAIX",
                1000e18,
                users.admin,
                address(tokens.dai),
                1000e18,
                block.timestamp + 3 days
            )
        );
        vm.stopPrank();
    }

    modifier whenOptionIsNotMatured() {
        vm.warp(options.maturityTimestamp() - 1 seconds);
        _;
    }

    modifier whenOptionIsMatured() {
        vm.warp(options.maturityTimestamp() + 1 seconds);
        _;
    }
}
