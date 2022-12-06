// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AssetData {

    address private owner;
    address private controller;

    // number of assets/vaults created
    uint256 public assetLength;
    // number of assets/vaults created minus deleted vaults/assets
    uint256 public totalAssets;

    mapping(address => address) assetsFromVaults;
    mapping(address => address) vaultsFromAssets;

    function getVaultUsingAddress(address _assetAddress) public view returns (address) {
        return vaultsFromAssets[_assetAddress];
    }

    function getAssetUsingVault(address _vaultAddress) public view returns (address) {
        return assetsFromVaults[_vaultAddress];
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only available to the owner"); 
        _;
    }

    modifier onlyController() {
        require(msg.sender == controller, "Only available to the assetController"); 
        _;
    }

    modifier onlyNew(address _assetAddress) {
        require(getVaultUsingAddress(_assetAddress) == address(0), "Must be a new asset being added");
        _;
    }

    function addAsset(address _aa, address _va) external onlyController onlyNew(_aa) {
        // _aa = assetAddress, _va = vaultAddress
        assetsFromVaults[_va] = _aa;
        vaultsFromAssets[_aa] = _va;
        assetLength++;
        totalAssets++;
    }

    function deleteAsset(address _assetAddress, address _vaultAddress) external onlyController { 
        if (_assetAddress != address(0)) {
            delete assetsFromVaults[getVaultUsingAddress(_assetAddress)];
            delete vaultsFromAssets[_assetAddress];
        } else {
            delete vaultsFromAssets[getAssetUsingVault(_vaultAddress)];
            delete assetsFromVaults[_vaultAddress];
        }
        totalAssets--;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setAssetController(address _assetController) public onlyOwner {
        controller = _assetController;
    }

}