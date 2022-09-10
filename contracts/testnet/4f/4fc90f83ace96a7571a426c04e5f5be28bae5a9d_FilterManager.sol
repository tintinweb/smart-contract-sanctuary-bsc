/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

contract FilterManager {
    bool public isInitialized;

    address public adminAddress;
    address public treasuryAddress;
    address public factoryAddress;
    address public routerAddress;
    address public deployerAddress;
    address public verifierAddress;
    address public distributorAddress;
    address public wethAddress;
    address public governanceToken;

    uint public governanceVoteDeadline;
    uint public maxGovernanceVotingPower;
    uint public minGovernanceVotesRequired;

    // **** ROUTER SPECIFIC ****

    mapping(address => mapping(address => uint)) public liquidityUnlockTimes;
    mapping(address => bool) public isTokenVerified;

    uint public minLiquidityLockTime;

    // **** DEPLOYER SPECIFIC ****

    uint public tokenMintFee;

    mapping(uint => address) public tokenTemplateAddresses;

    uint public maxOwnerShare;
    uint public numTokenTemplates;

    // **** VERIFICATION REQUEST SPECIFIC ****

    uint public verificationRequestFee;
    uint public verificationRequestDeadline;

    // **** PRESALE SPECIFIC ****

    uint public presaleFee; // in basis points  

    uint public minPresaleDuration;
    uint public maxPresaleDuration;
    uint public maxPresaleFinalizeTime;

    uint public minPresaleTokenPercentage;

    // **** CONSTRUCTOR, FALLBACK & MODIFIERS ****

    constructor() {
        adminAddress = msg.sender;
    }

    receive() external payable {}

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyContracts() {
        require(
            msg.sender == adminAddress || 
            msg.sender == deployerAddress || 
            msg.sender == verifierAddress || 
            msg.sender == distributorAddress, 
            "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyRouter() {
        require(msg.sender == routerAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier untilInitialized() {
        require(!isInitialized, "FilterManager: ALREADY_INITIALIZED");
        _;
    }

    // **** VIEW FUNCTIONS ****

    function isLiquidityLocked(address _liquidityProviderAddress, address _pairAddress) external view returns (bool) {
        return block.timestamp < liquidityUnlockTimes[_liquidityProviderAddress][_pairAddress] ? true : false;
    }

    // **** ONE-TIME FUNCTIONS ****

    function setFactoryAddress(address _factoryAddress) external onlyAdmin untilInitialized {
        factoryAddress = _factoryAddress;
    }

    function setRouterAddress(address _routerAddress) external onlyAdmin untilInitialized {
        routerAddress = _routerAddress;
    }

    function setDeployerAddress(address _deployerAddress) external onlyAdmin untilInitialized {
        deployerAddress = _deployerAddress;
    }

    function setVerifierAddress(address _verifierAddress) external onlyAdmin untilInitialized {
        verifierAddress = _verifierAddress;
    }

    function setDistributorAddress(address _distributorAddress) external onlyAdmin untilInitialized {
        distributorAddress = _distributorAddress;
    }

    function setWethAddress(address _wethAddress) external onlyAdmin untilInitialized {
        wethAddress = _wethAddress;
        isTokenVerified[wethAddress] = true;
    }

    function confirmInitialization() external onlyAdmin untilInitialized {
        isInitialized = true;
    }

    // **** ADMIN FUNCTIONS (general) ****

    function setAdminAddress(address _adminAddress) external onlyAdmin {
        adminAddress = _adminAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyAdmin {
        treasuryAddress = _treasuryAddress;
    }

    function verifyToken(address _tokenAddress) external onlyContracts {
        isTokenVerified[_tokenAddress] = true;
    }

    function unverifyToken(address _tokenAddress) external onlyContracts {
        isTokenVerified[_tokenAddress] = false;
    }

    // **** ADMIN FUNCTIONS (governance)

    function setGovernanceToken(address _governanceToken) external onlyAdmin {
        governanceToken = _governanceToken;
    }

    function setGovernanceVoteDeadline(uint _governanceVoteDeadline) external onlyAdmin {
        governanceVoteDeadline = _governanceVoteDeadline;
    }

    function setMaxGovernanceVotingPower(uint _maxGovernanceVotingPower) external onlyAdmin {
        maxGovernanceVotingPower = _maxGovernanceVotingPower;
    }

    // **** ADMIN FUNCTIONS (router) ****

    function setMinLiquidityLockTime(uint _minLiquidityLockTime) external onlyAdmin {
        minLiquidityLockTime = _minLiquidityLockTime;
    }

    function setLiquidityUnlockTime(address _holderAddress, address _pairAddress, uint _liquidityLockTime) private {
        liquidityUnlockTimes[_holderAddress][_pairAddress] = _liquidityLockTime;
    }

    function imposeLiquidityLock(address _holderAddress, address _pairAddress, uint _liquidityLockTime) external onlyRouter {
        require(_liquidityLockTime >= minLiquidityLockTime, "FilterRouter: LOCKTIME_TOO_SHORT");

        if (liquidityUnlockTimes[_holderAddress][_pairAddress] == 0) setLiquidityUnlockTime(_holderAddress, _pairAddress, block.timestamp + _liquidityLockTime);

        else if (liquidityUnlockTimes[_holderAddress][_pairAddress] < block.timestamp) setLiquidityUnlockTime(_holderAddress, _pairAddress, block.timestamp + _liquidityLockTime);
    }

    function removeLiquidityLock(address _holderAddress, address _pairAddress) external onlyAdmin {
        liquidityUnlockTimes[_holderAddress][_pairAddress] = 0;
    }

    // **** ADMIN FUNCTIONS (deployer) ****

    function setTokenMintFee(uint _tokenMintFee) external onlyAdmin {
        tokenMintFee = _tokenMintFee;
    }

    function addTokenTemplate(address _templateAddress) external onlyAdmin {
        tokenTemplateAddresses[numTokenTemplates] = _templateAddress;
        numTokenTemplates++;
    }

    function removeTokenTemplate(uint _templateIndex) external onlyAdmin {
        require(tokenTemplateAddresses[_templateIndex] != address(0));
        tokenTemplateAddresses[_templateIndex] = address(0);
        numTokenTemplates--;
    }

    function setMaxOwnerShare(uint _maxOwnerShare) external onlyAdmin {
        maxOwnerShare = _maxOwnerShare;
    }

    // **** ADMIN FUNCTIONS (presale) ****

    function setPresaleFee(uint _presaleFee) external onlyAdmin {
        presaleFee = _presaleFee;
    }

    function setMinPresaleDuration(uint _minPresaleDuration) external onlyAdmin {
        minPresaleDuration = _minPresaleDuration;
    }

    function setMaxPresaleDuration(uint _maxPresaleDuration) external onlyAdmin {
        maxPresaleDuration = _maxPresaleDuration;
    }

    function setMaxPresaleFinalizeTime(uint _maxPresaleFinalizeTime) external onlyAdmin {
        maxPresaleFinalizeTime = _maxPresaleFinalizeTime;
    }

    function setMinPresaleTokenPercentage(uint _minPresaleTokenPercentage) external onlyAdmin {
        minPresaleTokenPercentage = _minPresaleTokenPercentage;
    }

    // **** ADMIN FUNCTIONS (verification requests) ****

    function setVerificationRequestFee(uint _verificationRequestFee) external onlyAdmin {
        verificationRequestFee = _verificationRequestFee;
    }

    function setVerificationRequestDeadline(uint _verificationRequestDeadline) external onlyAdmin {
        verificationRequestDeadline = _verificationRequestDeadline;
    }
}