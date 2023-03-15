// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IFlaixVault.sol";
import "./interfaces/IFlaixGovernance.sol";

/// @title FlaixTestGov
/// @notice Governance Contract of FlaixVault for testing purposes only.
/// A designated group of testers are allowed to call admin only functions of the
/// vault contract. The contract owner can add or remove testers. THIS CONTRACT
/// SHOULD NOT BE USED IN PRODUCTION.
contract FlaixTestGov is IFlaixGovernance, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    /// @notice Error when the caller is not a tester.
    error OnlyAllowedForTesters();

    /// @notice Emitted when a tester is added.
    event TesterAdded(address tester);

    /// @notice Emitted when a tester is removed.
    event TesterRemoved(address tester);

    /// @notice Address of the FlaixVault contract.
    IFlaixVault public immutable vault;

    EnumerableSet.AddressSet internal testers;

    modifier onlyTesters() {
        if (!isTester(msg.sender)) revert OnlyAllowedForTesters();
        _;
    }

    /// @dev Constructor
    /// @param flaixVault Address of the FlaixVault contract.
    constructor(address flaixVault) {
        vault = IFlaixVault(flaixVault);
    }

    /// @notice Allows the owner to add a tester.
    /// @param tester Address of the tester.
    function addTester(address tester) public onlyOwner {
        if (testers.add(tester)) emit TesterAdded(tester);
    }

    /// @notice Allows the owner to remove a tester.
    /// @param tester Address of the tester.
    function removeTester(address tester) external onlyOwner {
        if (testers.remove(tester)) emit TesterRemoved(tester);
    }

    /// @notice Returns true if the address is a tester.
    /// @param tester Address of the tester.
    /// @return True if the address is a tester.
    function isTester(address tester) public view returns (bool) {
        return testers.contains(tester);
    }

    /// @notice Returns the number of testers.
    /// @return Number of testers.
    function testersLength() public view returns (uint256) {
        return testers.length();
    }

    /// @notice Returns the address of a tester at a certain index.
    /// @param index Index of the tester.
    /// @return Address of the tester.
    function testerAt(uint256 index) public view returns (address) {
        return testers.at(index);
    }

    /// @notice Returns the address of the admin of the vault.
    /// @return Address of the admin.
    function admin() external view returns (address) {
        return vault.admin();
    }

    /// @inheritdoc IFlaixGovernance
    function minimalOptionsMaturity() external view returns (uint) {
        return vault.minimalOptionsMaturity();
    }

    /// @inheritdoc IFlaixGovernance
    function changeMinimalOptionsMaturity(uint newMaturity) external onlyTesters {
        vault.changeMinimalOptionsMaturity(newMaturity);
    }

    /// @inheritdoc IFlaixGovernance
    function changeAdmin(address newAdmin) external onlyOwner {
        vault.changeAdmin(newAdmin);
    }

    /// @inheritdoc IFlaixGovernance
    function allowAsset(address assetAddress) external onlyTesters {
        vault.allowAsset(assetAddress);
        IERC20(assetAddress).safeApprove(address(vault), type(uint256).max);
    }

    /// @inheritdoc IFlaixGovernance
    function disallowAsset(address assetAddress) external onlyTesters {
        vault.disallowAsset(assetAddress);
        IERC20(assetAddress).safeApprove(address(vault), 0);
    }

    /// @inheritdoc IFlaixGovernance
    function isAssetAllowed(address assetAddress) external view returns (bool) {
        return vault.isAssetAllowed(assetAddress);
    }

    /// @inheritdoc IFlaixGovernance
    function allowedAssets() external view returns (uint256) {
        return vault.allowedAssets();
    }

    /// @inheritdoc IFlaixGovernance
    function allowedAsset(uint256 index) external view returns (address) {
        return vault.allowedAsset(index);
    }

    /// @inheritdoc IFlaixGovernance
    function issueCallOptions(
        string memory name,
        string memory symbol,
        uint256 sharesAmount,
        address recipient,
        address asset,
        uint256 assetAmount,
        uint256 maturityTimestamp
    ) public onlyTesters returns (address) {
        IERC20(asset).safeTransferFrom(msg.sender, address(this), assetAmount);
        return vault.issueCallOptions(name, symbol, sharesAmount, recipient, asset, assetAmount, maturityTimestamp);
    }

    /// @inheritdoc IFlaixGovernance
    function issuePutOptions(
        string memory name,
        string memory symbol,
        uint256 sharesAmount,
        address recipient,
        address asset,
        uint256 assetAmount,
        uint maturityTimestamp
    ) public onlyTesters returns (address) {
        return vault.issuePutOptions(name, symbol, sharesAmount, recipient, asset, assetAmount, maturityTimestamp);
    }
}
