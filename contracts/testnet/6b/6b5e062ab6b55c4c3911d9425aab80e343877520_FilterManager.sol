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

    uint public verificationRequestFee;
    uint public verificationRequestDeadline;
    mapping(address => address) public verificationRequestMaker;
    mapping(address => uint) public verificationRequestStatuses;
    mapping(address => uint) public verificationRequestDeadlines;
    bool public verificationRequestsAccepted = true;

    event requestSubmitted(address);

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
        require(_verificationRequestFee <= 1 ether);
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
        require(_tokenMintFee <= 10); // 1%
        tokenMintFee = _tokenMintFee;
    }

    function setMaxOwnerShare(uint _maxOwnerShare) public onlyAdmin {
        maxOwnerShare = _maxOwnerShare;
    }

    // **** VERIFICATION REQUEST FUNCTIONS ****

    /* STATUS MEANING

    0 = not submitted
    1 = awaiting verification
    2 = submitted and rejected (user can resubmit or contact FilterSwap team on Telegram)
    3 = submitted and accepted
    4 = not processed within correct timeframe (user is allowed to resubmit)

    User must pay a fee for a verification request eg. 1 BNB.

    Verification requests must be processed by the FilterSwap team within a deadline eg 1 week.

    Scenarios:
    - User pays for verification request but FilterSwap team fails to review request within deadline: 100% refund issued
    - User pays for verification request but FilterSwap rejects token: 50% refund issued
    - User pays for verification request and FilterSwap accepts token: no refund

    */

    function makeVerificationRequest(address _tokenAddress) public payable {
        require(verificationRequestStatuses[_tokenAddress] == 0 || verificationRequestStatuses[_tokenAddress] == 4, "FilterManager: ALREADY_SUBMITTED");
        require(!isTokenVerified[_tokenAddress], "FilterManager: ALREADY_VERIFIED");
        require(verificationRequestsAccepted, "FilterManager: REQUESTS_NOT_ALLOWED");

        payable(address(this)).transfer(verificationRequestFee);

        verificationRequestStatuses[_tokenAddress] = 1;
        verificationRequestDeadlines[_tokenAddress] = block.timestamp + verificationRequestDeadline;
        verificationRequestMaker[_tokenAddress] = msg.sender;

        emit requestSubmitted(_tokenAddress);
    }

    function rejectVerificationRequest(address _tokenAddress) public onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] != 3); //require not already accepted
        verificationRequestStatuses[_tokenAddress] = 2;
        verificationRequestDeadlines[_tokenAddress] = 0;

        //process refund

        payable(verificationRequestMaker[_tokenAddress]).transfer(verificationRequestFee / 2);
        payable(feeToAddress).transfer(verificationRequestFee / 2);
    }

    function acceptVerificationRequest(address _tokenAddress) public onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] != 3); //require not already accepted

        verificationRequestStatuses[_tokenAddress] = 3;
        verificationRequestDeadlines[_tokenAddress] = 0;

        payable(feeToAddress).transfer(verificationRequestFee);

        isTokenVerified[_tokenAddress] = true;
    }

    function claimExpiredRequestFee(address _tokenAddress) public {
        require(msg.sender == verificationRequestMaker[_tokenAddress], "FilterManager: NOT_REQUEST_MAKER");
        require(verificationRequestStatuses[_tokenAddress] == 1, "FilterManager: CANNOT_CLAIM");
        require(verificationRequestDeadlines[_tokenAddress] < block.timestamp + verificationRequestDeadline, "FilterManager: NOT_EXPIRED_YET");

        verificationRequestStatuses[_tokenAddress] = 4;

        payable(verificationRequestMaker[_tokenAddress]).transfer(verificationRequestFee);
    }

    receive() external payable {}
}