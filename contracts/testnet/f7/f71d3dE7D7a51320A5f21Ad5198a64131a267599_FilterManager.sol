/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

contract FilterManager {
    bool public isInitialized;

    address public managerAddress = address(this);
    address public adminAddress;
    address public feeToAddress;
    address public factoryAddress;
    address public routerAddress;
    address public deployerAddress;
    address public wethAddress;

    uint public verificationRequestFee;
    uint public verificationRequestDeadline;
    bool public verificationRequestsAccepted = true;

    mapping(address => address) public verificationRequestMaker;
    mapping(address => uint) public verificationRequestStatuses;
    mapping(address => uint) public verificationRequestDeadlines;
    
    event requestSubmitted(address, uint);

    // **** ROUTER SPECIFIC ****

    mapping(address => mapping(address => uint)) public liquidityUnlockTimes;
    mapping(address => bool) public isTokenVerified;

    uint public minLiquidityLockTime;

    // **** DEPLOYER SPECIFIC ****

    mapping(uint => address) public tokenTemplateAddresses;

    uint public tokenMintFee;
    uint public maxOwnerShare;

    uint public numTokenTemplates;

    // **** CONSTRUCTOR ****

    constructor() {
        adminAddress = msg.sender;
    }

    // **** FALLBACK ****

    receive() external payable {}

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

    function isLiquidityLocked(address _liquidityProviderAddress, address _pairAddress) public view returns (bool) {
        return block.timestamp < getLiquidityUnlockTime(_liquidityProviderAddress, _pairAddress) ? true : false;
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
        isTokenVerified[wethAddress] = true;
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

    function setVerificationRequestFee(uint _verificationRequestFee) public onlyAdmin {
        verificationRequestFee = _verificationRequestFee;
    }

    function setVerificationRequestDeadline(uint _verificationRequestDeadline) public onlyAdmin {
        verificationRequestDeadline = _verificationRequestDeadline;
    }

    function setVerificationRequestsAccepted(bool _verificationRequestsAccepted) public onlyAdmin {
        verificationRequestsAccepted = _verificationRequestsAccepted;
    }

    function setLiquidityUnlockTime(address _userAddress, address _tokenAddress, uint _liquidityLockTime) public onlyAdminOrContracts {
        liquidityUnlockTimes[_userAddress][_tokenAddress] = _liquidityLockTime;
    }

    function rejectVerificationRequest(address _tokenAddress) public onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] != 3);
        verificationRequestStatuses[_tokenAddress] = 2;
        verificationRequestDeadlines[_tokenAddress] = 0;

        payable(verificationRequestMaker[_tokenAddress]).transfer(verificationRequestFee / 2);
        payable(feeToAddress).transfer(verificationRequestFee / 2);
    }

    function acceptVerificationRequest(address _tokenAddress) public onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] != 3);

        verificationRequestStatuses[_tokenAddress] = 3;
        verificationRequestDeadlines[_tokenAddress] = 0;

        payable(feeToAddress).transfer(verificationRequestFee);

        isTokenVerified[_tokenAddress] = true;
    }

    // **** ADMIN FUNCTIONS (router) ****

    function setMinLiquidityLockTime(uint _minLiquidityLockTime) public onlyAdmin {
        minLiquidityLockTime = _minLiquidityLockTime;
    }

    function setTokenVerified(address _tokenAddress) public onlyAdminOrContracts {
        isTokenVerified[_tokenAddress] = true;
    }

    function imposeLiquidityLock(address _userAddress, address _pairAddress, uint _liquidityLockTime) public {
        require(msg.sender == routerAddress);
        require(_liquidityLockTime >= minLiquidityLockTime, "FilterRouter: LOCKTIME_TOO_SHORT");

        if (getLiquidityUnlockTime(_userAddress, _pairAddress) == 0) {
            setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);
        }

        else if (getLiquidityUnlockTime(_userAddress, _pairAddress) < block.timestamp) {
            setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);
        }
    }

    // **** ADMIN FUNCTIONS (deployer) ****

    function addTokenTemplate(address _templateAddress) public onlyAdmin {
        tokenTemplateAddresses[numTokenTemplates] = _templateAddress;
        numTokenTemplates++;
    }

    function removeTokenTemplate(uint _templateIndex) public onlyAdmin {
        tokenTemplateAddresses[_templateIndex] = address(0);
        numTokenTemplates--;
    }

    function setTokenMintFee(uint _tokenMintFee) public onlyAdmin {
        tokenMintFee = _tokenMintFee;
    }

    function setMaxOwnerShare(uint _maxOwnerShare) public onlyAdmin {
        maxOwnerShare = _maxOwnerShare;
    }

    // **** VERIFICATION REQUEST FUNCTIONS ****

    function makeVerificationRequest(address _tokenAddress) public payable {
        require(verificationRequestStatuses[_tokenAddress] == 0 || verificationRequestStatuses[_tokenAddress] == 4, "FilterManager: ALREADY_SUBMITTED");
        require(!isTokenVerified[_tokenAddress], "FilterManager: ALREADY_VERIFIED");
        require(verificationRequestsAccepted, "FilterManager: REQUESTS_NOT_ALLOWED");
        require(msg.value >= verificationRequestFee, "FilterManager: FEE_TOO_LOW");

        uint feeTip = 0;

        if (msg.value > verificationRequestFee) {
            payable(feeToAddress).transfer(msg.value - verificationRequestFee);
            feeTip = msg.value - verificationRequestFee;
        }

        verificationRequestStatuses[_tokenAddress] = 1;
        verificationRequestDeadlines[_tokenAddress] = block.timestamp + verificationRequestDeadline;
        verificationRequestMaker[_tokenAddress] = msg.sender;

        emit requestSubmitted(_tokenAddress, feeTip);
    }

    function claimExpiredRequestFee(address _tokenAddress) public {
        require(msg.sender == verificationRequestMaker[_tokenAddress], "FilterManager: NOT_REQUEST_MAKER");
        require(verificationRequestStatuses[_tokenAddress] == 1, "FilterManager: CANNOT_CLAIM");
        require(verificationRequestDeadlines[_tokenAddress] < block.timestamp + verificationRequestDeadline, "FilterManager: NOT_EXPIRED_YET");

        verificationRequestStatuses[_tokenAddress] = 4;

        payable(verificationRequestMaker[_tokenAddress]).transfer(verificationRequestFee);
    }
}