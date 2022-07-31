/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

contract FilterManager {

    bool public isInitialized;

    // **** GENERAL ****

    address public adminAddress;
    address public feeToAddress;

    address public factoryAddress;
    address public routerAddress;
    address public deployerAddress;
    address public strainerAddress;
    address public managerAddress = address(this);

    address public wethAddress;

    // **** ROUTER SPECIFIC ****

    mapping(address => mapping(address => uint)) public liquidityUnlockTimes;
    mapping(address => bool) public isVerifiedSafe;
    mapping(address => bool) public isFlaggedAsScam;

    uint public minLiquidityLockTime;

    // **** DEPLOYER SPECIFIC ****

    address[] public tokenTemplateAddresses;

    uint public tokenMintFee; // out of 1000, eg. 1 = 0.1%
    uint public maxOwnerShare;

    // **** STRAINER SPECIFIC ****

    uint public strainerRecoveryFee; // out of 1000, eg. 1 = 0.1%

    // **** CONSTRUCTOR ****

    constructor() {
        adminAddress = msg.sender;
    }

    // **** MODIFIERS ****

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyAdminOrContracts() {
        require(msg.sender == adminAddress    ||
                msg.sender == factoryAddress  ||
                msg.sender == routerAddress   ||
                msg.sender == deployerAddress ||
                msg.sender == strainerAddress, 
                "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyNotInitialized() {
        require(!isInitialized, "FilterManager: ALREADY_INITIALIZED");
        _;
    }

    // **** VIEW FUNCTIONS ****

    function getLiquidityUnlockTime(address _userAddress, address _tokenAddress) public view returns (uint) {
        return liquidityUnlockTimes[_userAddress][_tokenAddress];
    }

    function tokenTemplateAddress(uint _templateIndex) public view returns (address) {
        return tokenTemplateAddresses[_templateIndex];
    }

    function numTemplates() public view returns (uint) {
        return tokenTemplateAddresses.length;
    }

    // **** ONE-TIME FUNCTIONS ****

    function setFactoryAddress(address _factoryAddress) public onlyNotInitialized {
        factoryAddress = _factoryAddress;
    }

    function setRouterAddress(address _routerAddress) public onlyNotInitialized {
        routerAddress = _routerAddress;
    }

    function setWethAddress(address _wethAddress) public onlyNotInitialized {
        wethAddress = _wethAddress;
    }

    function confirmInitialization() public onlyNotInitialized {
        isInitialized = true;
    }

    // **** ADMIN FUNCTIONS (general) ****

    function setAdminAddress(address _adminAddress) public {
        if (adminAddress == address(0)) {
            adminAddress = _adminAddress;
        } 

        else {
            require(msg.sender == adminAddress, "FilterManager: FORBIDDEN");
            adminAddress = _adminAddress;
        }
    }

    function setFeeToAddress(address _feeToAddress) public onlyAdmin {
        feeToAddress = _feeToAddress;
    }

    function setDeployerAddress(address _deployerAddress) public onlyAdmin {
        deployerAddress = _deployerAddress;
    }

    function setStrainerAddress(address _strainerAddress) public onlyAdmin {
        strainerAddress = _strainerAddress;
    }

    function setLiquidityUnlockTime(address _userAddress, address _tokenAddress, uint _liquidityLockTime) public onlyAdminOrContracts {
        liquidityUnlockTimes[_userAddress][_tokenAddress] = _liquidityLockTime;
    }

    // **** ADMIN FUNCTIONS (router) ****

    function setMinLiquidityLockTime(uint _minLiquidityLockTime) public onlyAdmin {
        minLiquidityLockTime = _minLiquidityLockTime;
    }

    function setVerifiedSafe(address _tokenAddress) public onlyAdminOrContracts {
        isVerifiedSafe[_tokenAddress] = true;
    }

    function setFlaggedAsScam(address _tokenAddress) public onlyAdminOrContracts {
        isFlaggedAsScam[_tokenAddress] = true;
    }

    // **** ADMIN FUNCTIONS (deployer) ****

    function addDeployerTokenTemplate(address _templateAddress) public onlyAdmin {
        tokenTemplateAddresses.push(_templateAddress);
    }

    function setTokenMintFee(uint _tokenMintFee) public onlyAdmin {
        tokenMintFee = _tokenMintFee;
    }

    function setMaxOwnerShare(uint _maxOwnerShare) public onlyAdmin {
        maxOwnerShare = _maxOwnerShare;
    }

    // **** ADMIN FUNCTIONS (strainer) ****

    function setStrainerRecoveryFee(uint _strainerRecoveryFee) public onlyAdmin {
        strainerRecoveryFee = _strainerRecoveryFee;
    }
}