/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

contract FilterManager {
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
    uint public governanceMaxVotingPower;
    uint public governanceMinVotesRequired;

    uint public swapLiquidityProviderFee;
    uint public swapTreasuryFee;

    mapping(address => bool) public isTokenVerified;

    uint public deployerMaxOwnerShare;

    // **** ROUTER SPECIFIC ****

    mapping(address => mapping(address => uint)) public liquidityUnlockTimes;
    uint public liquidityMinLockTime;

    // **** DEPLOYER SPECIFIC ****

    uint public deployerMintFee;
    uint public numTokenTemplates;
    mapping(uint => address) public tokenTemplateAddresses; 

    // **** VERIFICATION REQUEST SPECIFIC ****

    uint public verificationRequestFee;
    uint public verificationRequestDeadline;

    // **** PRESALE SPECIFIC ****

    uint public presaleFee;

    uint public presaleMinDuration;
    uint public presaleMaxDuration;
    uint public presaleMaxFinalizeTime;

    uint public presaleMinTokenPercentage;

    // **** CONSTRUCTOR & MODIFIER FUNCTIONS ****

    constructor() {
        adminAddress = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyAdminOrContracts() {
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
        if (wethAddress != address(0) && factoryAddress != address(0) && routerAddress != address(0)) revert("FilterManager: ALREADY_INITIALIZED");
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

    function setWethAddress(address _wethAddress) external onlyAdmin untilInitialized {
        wethAddress = _wethAddress;
        isTokenVerified[wethAddress] = true;
    }

    // **** ADMIN FUNCTIONS (general) ****

    function setAdminAddress(address _adminAddress) external onlyAdmin {
        adminAddress = _adminAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyAdmin {
        treasuryAddress = _treasuryAddress;
    }

    function setDeployerAddress(address _deployerAddress) external onlyAdmin {
        deployerAddress = _deployerAddress;
    }

    function setVerifierAddress(address _verifierAddress) external onlyAdmin {
        verifierAddress = _verifierAddress;
    }

    function setDistributorAddress(address _distributorAddress) external onlyAdmin {
        distributorAddress = _distributorAddress;
    }

    function verifyToken(address _tokenAddress) external onlyAdminOrContracts {
        isTokenVerified[_tokenAddress] = true;
    }

    function unverifyToken(address _tokenAddress) external onlyAdminOrContracts {
        isTokenVerified[_tokenAddress] = false;
    }

    function setSwapLiquidityProviderFee(uint _swapLiquidityProviderFee) external onlyAdminOrContracts {
        swapLiquidityProviderFee = _swapLiquidityProviderFee;
    }

    function setSwapTreasuryFee(uint _swapTreasuryFee) external onlyAdminOrContracts {
        swapTreasuryFee = _swapTreasuryFee;
    }

    // **** ADMIN FUNCTIONS (governance)

    function setGovernanceToken(address _governanceToken) external onlyAdmin {
        governanceToken = _governanceToken;
    }

    function setGovernanceVoteDeadline(uint _governanceVoteDeadline) external onlyAdmin {
        governanceVoteDeadline = _governanceVoteDeadline;
    }

    function setGovernanceMaxVotingPower(uint _governanceMaxVotingPower) external onlyAdmin {
        governanceMaxVotingPower = _governanceMaxVotingPower;
    }

    function setGovernanceMinVotesRequired(uint _governanceMinVotesRequired) external onlyAdmin {
        governanceMinVotesRequired = _governanceMinVotesRequired;
    }

    // **** ADMIN FUNCTIONS (router) ****

    function setLiquidityMinLockTime(uint _liquidityMinLockTime) external onlyAdmin {
        liquidityMinLockTime = _liquidityMinLockTime;
    }

    function setLiquidityUnlockTime(address _holderAddress, address _pairAddress, uint _liquidityLockTime) private {
        liquidityUnlockTimes[_holderAddress][_pairAddress] = _liquidityLockTime;
    }

    function imposeLiquidityLock(address _holderAddress, address _pairAddress, uint _liquidityLockTime) external onlyRouter {
        require(_liquidityLockTime >= liquidityMinLockTime, "FilterManager: LOCKTIME_TOO_SHORT");

        if (liquidityUnlockTimes[_holderAddress][_pairAddress] == 0) setLiquidityUnlockTime(_holderAddress, _pairAddress, block.timestamp + _liquidityLockTime);

        else if (liquidityUnlockTimes[_holderAddress][_pairAddress] < block.timestamp) setLiquidityUnlockTime(_holderAddress, _pairAddress, block.timestamp + _liquidityLockTime);
    }

    function removeLiquidityLock(address _holderAddress, address _pairAddress) external onlyAdmin {
        liquidityUnlockTimes[_holderAddress][_pairAddress] = 0;
    }

    // **** ADMIN FUNCTIONS (deployer) ****

    function setDeployerMintFee(uint _deployerMintFee) external onlyAdmin {
        deployerMintFee = _deployerMintFee;
    }

    function addTokenTemplate(address _templateAddress) external onlyAdmin {
        tokenTemplateAddresses[numTokenTemplates] = _templateAddress;
        numTokenTemplates++;
    }

    function removeTokenTemplate(uint _templateIndex) external onlyAdmin {
        tokenTemplateAddresses[_templateIndex] = address(0);
        numTokenTemplates--;
    }

    function setDeployerMaxOwnerShare(uint _deployerMaxOwnerShare) external onlyAdmin {
        deployerMaxOwnerShare = _deployerMaxOwnerShare;
    }

    // **** ADMIN FUNCTIONS (presale) ****

    function setPresaleFee(uint _presaleFee) external onlyAdmin {
        presaleFee = _presaleFee;
    }

    function setPresaleMinDuration(uint _presaleMinDuration) external onlyAdmin {
        presaleMinDuration = _presaleMinDuration;
    }

    function setPresaleMaxDuration(uint _presaleMaxDuration) external onlyAdmin {
        presaleMaxDuration = _presaleMaxDuration;
    }

    function setPresaleMaxFinalizeTime(uint _presaleMaxFinalizeTime) external onlyAdmin {
        presaleMaxFinalizeTime = _presaleMaxFinalizeTime;
    }

    function setPresaleMinTokenPercentage(uint _presaleMinTokenPercentage) external onlyAdmin {
        presaleMinTokenPercentage = _presaleMinTokenPercentage;
    }

    // **** ADMIN FUNCTIONS (verification requests) ****

    function setVerificationRequestFee(uint _verificationRequestFee) external onlyAdmin {
        verificationRequestFee = _verificationRequestFee;
    }

    function setVerificationRequestDeadline(uint _verificationRequestDeadline) external onlyAdmin {
        verificationRequestDeadline = _verificationRequestDeadline;
    }
}