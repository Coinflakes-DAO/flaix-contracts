// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IFlaixVault is IERC20Metadata {
    /// @notice Emitted when admin account is changed.
    event AdminChanged(address newAdmin, address oldAdmin);

    /// @notice Emitted when an asset is added to the allow list.
    event AssetAllowed(address asset);

    /// @notice Emitted when an asset is added to the allow list.
    event AssetDisallowed(address asset);

    /// @notice This function burns shares from the sender and in exchange, sends the
    ///         recipient a proportional amount of each vault asset.
    /// @param amount The amount of shares to burn.
    /// @param recipient The address to send the vault assets to.
    function redeemShares(uint256 amount, address recipient) external;

    function emergencyExit(uint256 amount, address recipient) external;

    /// @notice Burns shares from the sender.
    /// @param amount The amount of shares to burn.
    function burn(uint256 amount) external;

    /// @notice Mints shares to the recipient. Minting shares is only possible
    ///         if the sender has a minting budget which is equal or greater than the amount.
    function mint(uint amount, address recipient) external;
}
