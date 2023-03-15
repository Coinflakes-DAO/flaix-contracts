// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./IssueCallOptionsBase.t.sol";

contract IssueCallOptions_Test is IssueCallOptionsBase_Test {
    function issueCallOptionsWithValidParams(uint256 amount) private returns (address) {
        uint limit = vault.minimalOptionsMaturity();
        vm.prank(users.admin);
        return
            vault.issueCallOptions(
                "FLAIX Call Options 2023-01-01",
                "callFLAIX-230101",
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
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(1000e18)
    {
        vm.prank(users.admin);
        address options = issueCallOptionsWithValidParams(1000e18);
        assertFalse(options == address(0));
    }

    event IssueCallOptions(
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
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(1000e18)
    {
        vm.prank(users.admin);
        vm.expectEmit(false, false, false, false);
        emit IssueCallOptions(
            address(0),
            users.admin,
            "FLAIX Call Options 2023-01-01",
            "callFLAIX-230101",
            1000e18,
            address(tokens.dai),
            1000e18,
            0
        );
        issueCallOptionsWithValidParams(1000e18);
    }

    function test_whenCalledWithValidParameters_setsMinterBudget()
        public
        whenDaiIsAllowed
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(1000e18)
    {
        vm.prank(users.admin);
        address options = issueCallOptionsWithValidParams(1000e18);
        assertEq(vault.minterBudgetOf(address(options)), 1000e18);
    }

    function test_whenCalledWithValidParameters_transfersAssetsToOptions()
        public
        whenDaiIsAllowed
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(1000e18)
    {
        vm.prank(users.admin);
        address options = issueCallOptionsWithValidParams(1000e18);
        assertEq(tokens.dai.balanceOf(users.admin), 0);
        assertEq(tokens.dai.balanceOf(options), 1000e18);
    }

    function test_whenCalledWithValidParameters_erc20MetaDataIsSet()
        public
        whenDaiIsAllowed
        whenAdminHasDai(1000e18)
        whenAdminHasApprovedDai(1000e18)
    {
        vm.prank(users.admin);
        address options = issueCallOptionsWithValidParams(1000e18);
        assertEq(IERC20Metadata(options).name(), "FLAIX Call Options 2023-01-01");
        assertEq(IERC20Metadata(options).symbol(), "callFLAIX-230101");
        assertEq(IERC20Metadata(options).decimals(), 18);
        assertEq(tokens.dai.balanceOf(options), 1000e18);
    }
}
