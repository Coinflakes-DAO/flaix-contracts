// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./IssuePutOptionsBase.t.sol";

contract IssueCallOptions_Test is IssuePutOptionsBase_Test {
    function issuePutOptionsWithValidParams(uint256 amount) private returns (address) {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        return
            vault.issuePutOptions(
                "FLAIX Put Options 2023-01-01",
                "putFLAIX-230101",
                amount,
                users.admin,
                address(tokens.dai),
                amount,
                block.timestamp + limit
            );
    }

    function test_whenCalledWithValidParameters_returnsAddress()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
    {
        vm.prank(users.admin);
        address options = issuePutOptionsWithValidParams(1000e18);
        assertFalse(options == address(0));
    }

    event IssuePutOptions(
        address indexed options,
        address indexed recipient,
        string name,
        string symbol,
        uint256 amount,
        address indexed asset,
        uint256 assetAmount,
        uint256 maturity
    );

    function test_whenCalledWithValidParameters_emitsEvent()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
    {
        vm.prank(users.admin);
        vm.expectEmit(false, false, false, false);
        emit IssuePutOptions(
            address(0),
            users.admin,
            "FLAIX Put Options 2023-01-01",
            "putFLAIX-230101",
            1000e18,
            address(tokens.dai),
            1000e18,
            0
        );
        issuePutOptionsWithValidParams(1000e18);
    }

    function test_whenCalledWithValidParameters_burnsSharesFromUser()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
    {
        vm.prank(users.admin);
        issuePutOptionsWithValidParams(1000e18);
        assertEq(vault.balanceOf(users.admin), 0);
    }

    function test_whenCalledWithValidParameters_setsMinterBudget()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
    {
        vm.prank(users.admin);
        address options = issuePutOptionsWithValidParams(1000e18);
        assertEq(vault.minterBudgetOf(address(options)), 1000e18);
    }

    function test_whenCalledWithValidParameters_transfersAssetsToOptions()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
    {
        vm.prank(users.admin);
        address options = issuePutOptionsWithValidParams(1000e18);
        assertEq(tokens.dai.balanceOf(address(vault)), 0);
        assertEq(tokens.dai.balanceOf(options), 1000e18);
    }

    function test_whenCalledWithValidParameters_erc20MetaDataIsSet()
        public
        whenDaiIsAllowed
        whenVaultHasDai(1000e18)
        whenAdminHasShares(1000e18)
        whenAdminHasApprovedShares(1000e18)
    {
        vm.prank(users.admin);
        address options = issuePutOptionsWithValidParams(1000e18);
        assertEq(IERC20Metadata(options).name(), "FLAIX Put Options 2023-01-01");
        assertEq(IERC20Metadata(options).symbol(), "putFLAIX-230101");
        assertEq(IERC20Metadata(options).decimals(), 18);
    }
}
