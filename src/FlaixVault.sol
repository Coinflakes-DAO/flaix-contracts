// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/IFlaixVault.sol";

contract FlaixVault is ERC20, IFlaixVault, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Math for uint256;

    EnumerableSet.AddressSet private _allowedAssets;

    EnumerableSet.AddressSet private _minters;
    EnumerableSet.AddressSet private _burners;

    address public admin;

    event MinterAdded(address minter);
    event MinterRemoved(address minter);

    event BurnerAdded(address burner);
    event BurnerRemoved(address burner);

    modifier onlyAdmin() {
        require(msg.sender == admin, "FlaixVault: only allowed for admin");
        _;
    }

    /// @dev Constructor
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        admin = _msgSender();
        emit AdminChanged(admin, address(0));
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "FlaixVault: new admin cannot be null address");
        emit AdminChanged(newAdmin, admin);
        admin = newAdmin;
    }

    function allowAsset(address assetAddress) public onlyAdmin {
        require(assetAddress != address(0), "FlaixVault: asset address cannot be null");
        require(!_allowedAssets.contains(assetAddress), "FlaixVault: asset already allowed");
        _allowedAssets.add(assetAddress);
        emit AssetAllowed(assetAddress);
    }

    function disallowAsset(address assetAddress) public onlyAdmin {
        require(assetAddress != address(0), "FlaixVault: asset address cannot be null");
        require(_allowedAssets.contains(assetAddress), "FlaixVault: asset not allowed");
        _allowedAssets.remove(assetAddress);
        emit AssetDisallowed(assetAddress);
    }

    function isAssetAllowed(address assetAddress) public view returns (bool) {
        return _allowedAssets.contains(assetAddress);
    }

    function allowedAssets() public view returns (uint256) {
        return _allowedAssets.length();
    }

    function allowedAsset(uint256 index) public view returns (address) {
        require(index < _allowedAssets.length(), "FlaixVault: index out of bounds");
        return _allowedAssets.at(index);
    }

    function redeemShares(uint256 amount, address recipient) public nonReentrant {
        if (amount == 0) return;
        if (totalSupply() == 0) return;
        require(recipient != address(0), "FlaixVault: recipient cannot be null address");
        for (uint256 i = 0; i < _allowedAssets.length(); i++) {
            address asset = _allowedAssets.at(i);
            //slither-disable-next-line calls-loop
            uint256 assetBalance = IERC20(asset).balanceOf(address(this));
            uint256 assetAmount = assetBalance.mulDiv(amount, totalSupply(), Math.Rounding.Down);
            //slither-disable-next-line calls-loop
            IERC20(asset).safeTransfer(recipient, assetAmount);
        }
        _burn(msg.sender, amount);
    }

    function emergencyExit(uint256 amount, address recipient) public nonReentrant {
        if (amount == 0) return;
        if (totalSupply() == 0) return;
        require(recipient != address(0), "FlaixVault: recipient cannot be null address");
        for (uint256 i = 0; i < _allowedAssets.length(); i++) {
            address asset = _allowedAssets.at(i);
            //slither-disable-next-line calls-loop
            uint256 assetBalance = IERC20(asset).balanceOf(address(this));
            uint256 assetAmount = assetBalance.mulDiv(amount, totalSupply(), Math.Rounding.Down);
            //slither-disable-next-line calls-loop
            try IERC20(asset).transfer(recipient, assetAmount) {} catch (bytes memory /*lowLevelData*/) {
                // ignore any errors and just continue to get out as much as possible
            }
        }
        _burn(msg.sender, amount);
    }

    function addMinter(address minter) public onlyAdmin {
        require(minter != address(0), "FlaixVault: minter cannot be null address");
        require(!_minters.contains(minter), "FlaixVault: minter already added");
        _minters.add(minter);
        emit MinterAdded(minter);
    }

    function removeMinter(address minter) public onlyAdmin {
        require(minter != address(0), "FlaixVault: minter cannot be null address");
        require(_minters.contains(minter), "FlaixVault: minter not added");
        _minters.remove(minter);
        emit MinterRemoved(minter);
    }

    function isMinter(address minter) public view returns (bool) {
        return _minters.contains(minter);
    }

    function minters() public view returns (uint256) {
        return _minters.length();
    }

    function minterAt(uint256 index) public view returns (address) {
        require(index < _minters.length(), "FlaixVault: index out of bounds");
        return _minters.at(index);
    }

    function addBurner(address burner) public onlyAdmin {
        require(burner != address(0), "FlaixVault: burner cannot be null address");
        require(!_burners.contains(burner), "FlaixVault: burner already added");
        _burners.add(burner);
        emit BurnerAdded(burner);
    }

    function removeBurner(address burner) public onlyAdmin {
        require(burner != address(0), "FlaixVault: burner cannot be null address");
        require(_burners.contains(burner), "FlaixVault: burner not added");
        _burners.remove(burner);
        emit BurnerRemoved(burner);
    }

    function isBurner(address burner) public view returns (bool) {
        return _burners.contains(burner);
    }

    function burners() public view returns (uint256) {
        return _burners.length();
    }

    function burnerAt(uint256 index) public view returns (address) {
        require(index < _burners.length(), "FlaixVault: index out of bounds");
        return _burners.at(index);
    }

    function burn(uint256 amount) public {
        require(_burners.contains(msg.sender), "FlaixVault: only allowed for burners");
        _burn(msg.sender, amount);
    }

    function mint(uint amount, address recipient) public {
        require(_minters.contains(msg.sender), "FlaixVault: only allowed for minters");
        _mint(recipient, amount);
    }
}
