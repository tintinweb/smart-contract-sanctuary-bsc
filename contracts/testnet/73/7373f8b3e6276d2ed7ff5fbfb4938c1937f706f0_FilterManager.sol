/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

contract FilterManager {
    // **** GENERAL ****

    bool public isInitialized;

    address public managerAddress = address(this);
    address public adminAddress;
    address public feeToAddress;
    address public factoryAddress;
    address public routerAddress;
    address public deployerAddress;
    address public wethAddress;

    // **** ROUTER SPECIFIC ****

    mapping(address => mapping(address => uint)) public liquidityUnlockTimes;
    mapping(address => bool) public isTokenVerified;

    uint public minLiquidityLockTime;

    // **** DEPLOYER SPECIFIC ****

    mapping(uint => address) public tokenTemplateAddresses;

    uint public tokenMintFee; // out of 1000, eg. 1 = 0.1%
    uint public maxOwnerShare;

    uint public numTokenTemplates;

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
        require(msg.sender == adminAddress || msg.sender == factoryAddress || msg.sender == routerAddress || msg.sender == deployerAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier untilInitialized() {
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

    // **** ONE-TIME FUNCTIONS ****

    function setFactoryAddress(address _factoryAddress) public untilInitialized {
        factoryAddress = _factoryAddress;
    }

    function setRouterAddress(address _routerAddress) public untilInitialized {
        routerAddress = _routerAddress;
    }

    function setDeployerAddress(address _deployerAddress) public untilInitialized {
        deployerAddress = _deployerAddress;
    }

    function setWethAddress(address _wethAddress) public untilInitialized {
        wethAddress = _wethAddress;
    }

    function confirmInitialization() public untilInitialized {
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

    function setLiquidityUnlockTime(address _userAddress, address _tokenAddress, uint _liquidityLockTime) public onlyAdminOrContracts {
        liquidityUnlockTimes[_userAddress][_tokenAddress] = _liquidityLockTime;
    }

    // **** ADMIN FUNCTIONS (router) ****

    function setMinLiquidityLockTime(uint _minLiquidityLockTime) public onlyAdmin {
        minLiquidityLockTime = _minLiquidityLockTime;
    }

    function setTokenVerified(address _tokenAddress) public onlyAdminOrContracts {
        isTokenVerified[_tokenAddress] = true;
    }

    // **** ADMIN FUNCTIONS (deployer) ****

    function addDeployerTokenTemplate(address _templateAddress) public onlyAdmin {
        tokenTemplateAddresses[numTokenTemplates] = _templateAddress;
        numTokenTemplates++;
    }

    function removeTokenTemplate(uint _templateIndex) public onlyAdmin {
        tokenTemplateAddresses[_templateIndex] = address(0);
        numTokenTemplates--;
    }

    function setTokenMintFee(uint _tokenMintFee) public onlyAdmin {
        require(_tokenMintFee <= 1 ether);
        tokenMintFee = _tokenMintFee;
    }

    function setMaxOwnerShare(uint _maxOwnerShare) public onlyAdmin {
        maxOwnerShare = _maxOwnerShare;
    }
}