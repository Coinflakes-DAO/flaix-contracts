// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "../Base.t.sol";
import {FlaixVault} from "@src/FlaixVault.sol";
import {FlaixCallOption} from "@src/FlaixCallOption.sol";
import {FlaixPutOption} from "@src/FlaixPutOption.sol";
import {FlaixOptionFactory} from "@src/FlaixOptionFactory.sol";

contract FlaixPutOptionBase_Test is Base_Test {
    FlaixVault public vault;
    FlaixPutOption public options;

    function setUp() public override {
        super.setUp();
        setUp_vault();
        setUp_issuePutOptions();
    }

    function setUp_vault() public {
        address callOptionImplementation = address(new FlaixCallOption());
        address putOptionImplementation = address(new FlaixPutOption());
        address optionFactory = address(new FlaixOptionFactory(callOptionImplementation, putOptionImplementation));
        vault = new FlaixVault(optionFactory);

        vm.prank(vault.admin());
        vault.changeAdmin(users.admin);
        vm.prank(users.admin);
        vault.allowAsset(address(tokens.dai));
        deal(address(tokens.dai), address(vault), 1000e18, true);
        deal(address(vault), users.admin, 1000e18, true);
    }

    function setUp_issuePutOptions() public {
        vm.startPrank(users.admin);
        vault.approve(address(vault), 1000e18);
        options = FlaixPutOption(
            vault.issuePutOptions(
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
