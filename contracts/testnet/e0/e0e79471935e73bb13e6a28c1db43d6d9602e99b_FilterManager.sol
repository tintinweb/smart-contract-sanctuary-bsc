/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

interface IFilterDeployer {
    function createPresaleToken(uint, string memory, string memory, bytes32[] memory, address) external returns (address);
}

interface IFilterRouter {
    function addLiquidity(address, address, uint, uint, uint, uint, address, uint, uint) external returns (uint, uint, uint);
    function addLiquidityETH(address, uint, uint, uint, address, uint, uint) external payable returns (uint, uint, uint);
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function approve(address, uint) external returns (bool);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        require(IERC20(token).approve(to, value), "FilterManager: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        require(IERC20(token).transfer(to, value), "FilterManager: TRANSFER_FAILED");
    }
}

contract FilterManager {
    bool public isInitialized;

    address public managerAddress = address(this);
    address public adminAddress;
    address public treasuryAddress;
    address public factoryAddress;
    address public routerAddress;
    address public deployerAddress;
    address public wethAddress;
    address public governanceToken;

    bool public verificationRequestsAllowed;

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

    mapping(address => address) public verificationRequestMaker;
    mapping(address => uint) public verificationRequestStatuses;
    mapping(address => uint) public verificationRequestDeadlines;
    
    event requestSubmitted(address, uint);

    // **** PRESALE SPECIFIC ****

    uint public presaleFee; // in basis points  

    struct presaleData {
        address tokenAddress;
        address baseTokenAddress;
        address presaleCreator;
        uint ownerShare;
        uint[] presaleArgs;
        uint totalFundsRaised;
        uint liquidityLockTime;
        uint presaleStatus; // 0 = created, 1 = awaiting finalization, 2 = success, 3 = fail
    }

    uint public minPresaleDuration;
    uint public maxPresaleDuration;
    uint public maxPresaleFinalizeTime;

    mapping(uint => presaleData) private presaleInfo;
    mapping(uint => mapping(address => uint)) public userPresaleInvestments;

    mapping(address => uint[]) public userBoughtPresales;
    mapping(address => uint[]) public userCreatedPresales;

    uint public numPresalesCreated;

    // **** CONSTRUCTOR, FALLBACK & MODIFIERS ****

    constructor() {
        adminAddress = msg.sender;
    }

    receive() external payable {}

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyAdminOrManager() {
        require(msg.sender == adminAddress || msg.sender == deployerAddress, "FilterManager: FORBIDDEN");
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

    function getPresaleInfo(uint _presaleID) external view returns (presaleData memory) {
        return presaleInfo[_presaleID];
    }

    // **** ONE-TIME FUNCTIONS ****

    function setFactoryAddress(address _factoryAddress) external untilInitialized {
        factoryAddress = _factoryAddress;
    }

    function setRouterAddress(address _routerAddress) external untilInitialized {
        routerAddress = _routerAddress;
    }

    function setDeployerAddress(address _deployerAddress) external untilInitialized {
        deployerAddress = _deployerAddress;
    }

    function setWethAddress(address _wethAddress) external untilInitialized {
        wethAddress = _wethAddress;
        isTokenVerified[wethAddress] = true;
    }

    function confirmInitialization() external untilInitialized {
        isInitialized = true;
    }

    // **** ADMIN FUNCTIONS (general) ****

    function setAdminAddress(address _adminAddress) external onlyAdmin {
        adminAddress = _adminAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyAdmin {
        treasuryAddress = _treasuryAddress;
    }

    function setVerificationRequestsAllowed(bool _verificationRequestsAllowed) external onlyAdmin {
        verificationRequestsAllowed = _verificationRequestsAllowed;
    }

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

    function verifyToken(address _tokenAddress) external onlyAdminOrManager {
        isTokenVerified[_tokenAddress] = true;
    }

    function setLiquidityUnlockTime(address _userAddress, address _pairAddress, uint _liquidityLockTime) private {
        liquidityUnlockTimes[_userAddress][_pairAddress] = _liquidityLockTime;
    }

    function imposeLiquidityLock(address _userAddress, address _pairAddress, uint _liquidityLockTime) external onlyRouter {
        require(_liquidityLockTime >= minLiquidityLockTime, "FilterRouter: LOCKTIME_TOO_SHORT");

        if (liquidityUnlockTimes[_userAddress][_pairAddress] == 0) setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);

        else if (liquidityUnlockTimes[_userAddress][_pairAddress] < block.timestamp) setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);
    }

    function removeLiquidityLock(address _userAddress, address _pairAddress) external onlyAdmin {
        liquidityUnlockTimes[_userAddress][_pairAddress] = 0;
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

    // **** ADMIN FUNCTIONS (verification requests) ****

    function setVerificationRequestFee(uint _verificationRequestFee) external onlyAdmin {
        verificationRequestFee = _verificationRequestFee;
    }

    function setVerificationRequestDeadline(uint _verificationRequestDeadline) external onlyAdmin {
        verificationRequestDeadline = _verificationRequestDeadline;
    }

    function rejectVerificationRequest(address _tokenAddress) external onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] != 3);
        verificationRequestStatuses[_tokenAddress] = 2;
        verificationRequestDeadlines[_tokenAddress] = 0;

        payable(verificationRequestMaker[_tokenAddress]).transfer(verificationRequestFee / 2);
        payable(treasuryAddress).transfer(verificationRequestFee / 2);
    }

    function acceptVerificationRequest(address _tokenAddress) external onlyAdmin {
        require(verificationRequestStatuses[_tokenAddress] != 3);

        verificationRequestStatuses[_tokenAddress] = 3;
        verificationRequestDeadlines[_tokenAddress] = 0;

        payable(treasuryAddress).transfer(verificationRequestFee);

        isTokenVerified[_tokenAddress] = true;
    }

    // **** VERIFICATION REQUEST FUNCTIONS ****

    function makeVerificationRequest(address _tokenAddress) external payable {
        require(verificationRequestsAllowed, "FilterManager: REQUESTS_NOT_PERMITTED");
        require(verificationRequestStatuses[_tokenAddress] == 0 || verificationRequestStatuses[_tokenAddress] == 4, "FilterManager: ALREADY_SUBMITTED");
        require(!isTokenVerified[_tokenAddress], "FilterManager: ALREADY_VERIFIED");    
        require(msg.value >= verificationRequestFee, "FilterManager: FEE_TOO_LOW");

        uint feeTip = 0;

        if (msg.value > verificationRequestFee) {
            payable(treasuryAddress).transfer(msg.value - verificationRequestFee);
            feeTip = msg.value - verificationRequestFee;
        }

        verificationRequestStatuses[_tokenAddress] = 1;
        verificationRequestDeadlines[_tokenAddress] = block.timestamp + verificationRequestDeadline;
        verificationRequestMaker[_tokenAddress] = msg.sender;

        emit requestSubmitted(_tokenAddress, feeTip);
    }

    function claimExpiredRequestFee(address _tokenAddress) external {
        require(msg.sender == verificationRequestMaker[_tokenAddress], "FilterManager: NOT_REQUEST_MAKER");
        require(verificationRequestStatuses[_tokenAddress] == 1, "FilterManager: CANNOT_CLAIM");
        require(verificationRequestDeadlines[_tokenAddress] < block.timestamp + verificationRequestDeadline, "FilterManager: NOT_EXPIRED_YET");

        verificationRequestStatuses[_tokenAddress] = 4;

        payable(verificationRequestMaker[_tokenAddress]).transfer(verificationRequestFee);
    }

    // **** PRESALE FUNCTIONS ****

    function createPresaleFromTemplate(
            uint _tokenType,
            string memory _tokenName, 
            string memory _tokenSymbol, 
            bytes32[] memory _tokenArgs,
            uint[] memory _presaleArgs, // presalePrice, launchPrice, softCap, hardCap, minContributionAmount, maxContributionAmount, liquidityPercentage, presaleStartTime, presaleEndTime
            address _baseTokenAddress,
            uint _ownerShare,
            uint _liquidityLockTime
        ) external {
        require(_presaleArgs[2] * 2 >= _presaleArgs[3], "FilterManager: SOFTCAP_TOO_LOW");
        require(_presaleArgs[2] < _presaleArgs[3], "FilterManager: SOFTCAP_TOO_HIGH");
        require(_presaleArgs[6] >= 50, "FilterManager: LIQUIDITY_PERCENTAGE_TOO_LOW");
        require(_presaleArgs[7] >= block.timestamp, "FilterManager: START_TIME_TOO_EARLY");

        require(isTokenVerified[_baseTokenAddress], "FilterManager: BASE_TOKEN_NOT_VERIFIED");

        uint presaleDuration = _presaleArgs[8] - _presaleArgs[7];
        require(presaleDuration >= minPresaleDuration, "FilterManager: PRESALE_DURATION_TOO_SHORT");
        require(presaleDuration <= maxPresaleDuration, "FilterManager: PRESALE_DURATION_TOO_LONG");

        require(_ownerShare <= maxOwnerShare, "FilterManager: OWNER_SHARE_TOO_HIGH");
        require(_liquidityLockTime >= minLiquidityLockTime, "FilterManager: LOCKTIME_TOO_SHORT");
        require(tokenTemplateAddresses[_tokenType] != address(0), "FilterManager: INVALID_TOKEN_TYPE");

        uint presaleBuyersShare = 100 - _presaleArgs[6] - _ownerShare;
        require(presaleBuyersShare >= _ownerShare, "FilterManager: OWNER_SHARE_TOO_HIGH");
        require(_presaleArgs[6] >= _ownerShare, "FilterManager: OWNER_SHARE_TOO_HIGH");

        uint tokenTotalSupply = uint(bytes32(_tokenArgs[0]));

        uint totalTokensRequired = (_presaleArgs[0] * _presaleArgs[3]) + ((_presaleArgs[1] * _presaleArgs[3] * _presaleArgs[6]) / 100) + ((_ownerShare * tokenTotalSupply * 1e36) / 100) / 1e36;
        require(tokenTotalSupply >= totalTokensRequired, "FilterManager: TOKEN_SUPPLY_TOO_LOW");

        address deployedTokenAddress = IFilterDeployer(deployerAddress).createPresaleToken(_tokenType, _tokenName, _tokenSymbol, _tokenArgs, msg.sender);

        presaleInfo[numPresalesCreated] = presaleData(deployedTokenAddress, _baseTokenAddress, msg.sender, _ownerShare, _presaleArgs, 0, _liquidityLockTime, 0);
        numPresalesCreated++;

        userCreatedPresales[msg.sender].push(numPresalesCreated);
    }

    function createPresaleFromToken(
            address _tokenAddress,
            uint[] memory _presaleArgs, // presalePrice, launchPrice, softCap, hardCap, minContributionAmount, maxContributionAmount, liquidityPercentage, presaleStartTime, presaleEndTime
            address _baseTokenAddress,
            uint _ownerShare,
            uint _liquidityLockTime
        ) external {
        require(_presaleArgs[2] < _presaleArgs[3], "FilterManager: SOFTCAP_TOO_HIGH");
        require(_presaleArgs[6] >= 50, "FilterManager: LIQUIDITY_PERCENTAGE_TOO_LOW");
        require(_presaleArgs[7] >= block.timestamp, "FilterManager: START_TIME_TOO_EARLY");

        require(isTokenVerified[_baseTokenAddress], "FilterManager: BASE_TOKEN_NOT_VERIFIED");
        require(isTokenVerified[_tokenAddress], "FilterManager: TOKEN_NOT_VERIFIED");

        isTokenVerified[_tokenAddress] = false; //set token to not be verified until presale is finalized

        uint presaleDuration = _presaleArgs[8] - _presaleArgs[7];
        require(presaleDuration >= minPresaleDuration, "FilterManager: PRESALE_DURATION_TOO_SHORT");
        require(presaleDuration <= maxPresaleDuration, "FilterManager: PRESALE_DURATION_TOO_LONG");

        require(_ownerShare <= maxOwnerShare, "FilterManager: OWNER_SHARE_TOO_HIGH");
        require(_liquidityLockTime >= minLiquidityLockTime, "FilterManager: LOCKTIME_TOO_SHORT");

        uint presaleBuyersShare = 100 - _presaleArgs[6] - _ownerShare;
        require(presaleBuyersShare >= _ownerShare, "FilterManager: OWNER_SHARE_TOO_HIGH");
        require(_presaleArgs[6] >= _ownerShare, "FilterManager: OWNER_SHARE_TOO_HIGH");

        uint tokenTotalSupply = IERC20(_tokenAddress).totalSupply();

        uint totalTokensRequired = (_presaleArgs[0] * _presaleArgs[3]) + ((_presaleArgs[1] * _presaleArgs[3] * _presaleArgs[6]) / 100) + ((_ownerShare * tokenTotalSupply * 1e36) / 100) / 1e36;
        require(tokenTotalSupply >= totalTokensRequired, "FilterManager: TOKEN_SUPPLY_TOO_LOW");

        TransferHelper.safeTransfer(_tokenAddress, managerAddress, tokenTotalSupply);

        presaleInfo[numPresalesCreated] = presaleData(_tokenAddress, _baseTokenAddress, msg.sender, _ownerShare, _presaleArgs, 0, _liquidityLockTime, 0);
        numPresalesCreated++;

        userCreatedPresales[msg.sender].push(numPresalesCreated);
    }

    function investInPresale(uint _presaleID, uint _buyAmount) external payable {
        require(presaleInfo[_presaleID].presaleStatus == 0, "FilterManager: PRESALE_NOT_INVESTABLE");
        require(block.timestamp >= presaleInfo[_presaleID].presaleArgs[7], "FilterManager: PRESALE_NOT_STARTED");
        require(block.timestamp < presaleInfo[_presaleID].presaleArgs[8], "FilterManager: PRESALE_ENDED");
        require(msg.value >= presaleInfo[_presaleID].presaleArgs[4], "FilterManager: CONTRIBUTION_TOO_LOW");
        require(msg.value <= presaleInfo[_presaleID].presaleArgs[5], "FilterManager: CONTRIBUTION_TOO_HIGH");

        address tokenAddress = presaleInfo[_presaleID].tokenAddress;
        uint remainingInvestableAmount = presaleInfo[_presaleID].presaleArgs[3] - presaleInfo[_presaleID].totalFundsRaised;
        bool isBaseETH = presaleInfo[_presaleID].baseTokenAddress == wethAddress ? true : false;
        uint userContributedAmount;

        if (isBaseETH) {
            require(msg.value > 0, "FilterManager: INSUFFICIENT_INPUT_AMOUNT");
            userContributedAmount = msg.value;

            if (userContributedAmount >= remainingInvestableAmount) {
                userContributedAmount = remainingInvestableAmount;
                payable(msg.sender).transfer(msg.value - remainingInvestableAmount);
                presaleInfo[_presaleID].presaleStatus = 1;
            }

            uint userTokenAmount = (userContributedAmount * presaleInfo[_presaleID].presaleArgs[0]) / 1e18;
            TransferHelper.safeTransfer(tokenAddress, msg.sender, userTokenAmount);
        }

        else {
            require(_buyAmount > 0, "FilterManager: INSUFFICIENT_INPUT_AMOUNT");
            userContributedAmount = _buyAmount;

            if (userContributedAmount >= remainingInvestableAmount) {
                userContributedAmount = remainingInvestableAmount;
                TransferHelper.safeTransfer(tokenAddress, msg.sender, _buyAmount - remainingInvestableAmount);
                presaleInfo[_presaleID].presaleStatus = 1;
            }

            uint userTokenAmount = (userContributedAmount * presaleInfo[_presaleID].presaleArgs[0]) / 1e18;
            TransferHelper.safeTransfer(tokenAddress, msg.sender, userTokenAmount);
        }

        presaleInfo[_presaleID].totalFundsRaised += userContributedAmount;
        presaleInfo[_presaleID] = presaleInfo[_presaleID];

        userPresaleInvestments[_presaleID][msg.sender] += userContributedAmount;
        userBoughtPresales[msg.sender].push(_presaleID);
    }

    function processPresale(uint _presaleID) private {
        uint totalTokenLiquidity = presaleInfo[_presaleID].totalFundsRaised;
        uint presaleLiquidityFee = (totalTokenLiquidity * presaleFee) / 10000;
        TransferHelper.safeTransfer(presaleInfo[_presaleID].baseTokenAddress, treasuryAddress, presaleLiquidityFee);

        TransferHelper.safeApprove(presaleInfo[_presaleID].tokenAddress, routerAddress, type(uint).max);

        //add liquidity
        uint tokensForLiquidity = ((presaleInfo[_presaleID].presaleArgs[1] * presaleInfo[_presaleID].presaleArgs[3] * presaleInfo[_presaleID].presaleArgs[6]) / 100) / 1e18;
        
        //(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline, uint liquidityLockTime)
        IFilterRouter(routerAddress).addLiquidity(
            presaleInfo[_presaleID].baseTokenAddress,
            presaleInfo[_presaleID].tokenAddress,
            totalTokenLiquidity - presaleLiquidityFee,
            tokensForLiquidity,
            0,
            0,
            msg.sender,
            block.timestamp,
            presaleInfo[_presaleID].liquidityLockTime
        );
    }

    function processPresaleETH(uint _presaleID) private {
        uint totalTokenLiquidity = presaleInfo[_presaleID].totalFundsRaised;
        uint presaleLiquidityFee = (totalTokenLiquidity * presaleFee) / 10000;
        payable(treasuryAddress).transfer(presaleLiquidityFee);

        TransferHelper.safeApprove(presaleInfo[_presaleID].tokenAddress, routerAddress, type(uint).max);

        //add liquidity
        uint tokensForLiquidity = ((presaleInfo[_presaleID].presaleArgs[1] * presaleInfo[_presaleID].presaleArgs[3] * presaleInfo[_presaleID].presaleArgs[6]) / 100) / 1e18;
        
        IFilterRouter(routerAddress).addLiquidityETH{value: totalTokenLiquidity - presaleLiquidityFee}(
            presaleInfo[_presaleID].tokenAddress, 
            tokensForLiquidity, 
            0, 
            0, 
            msg.sender, 
            block.timestamp, 
            presaleInfo[_presaleID].liquidityLockTime
        );
    }

    function finalizePresale(uint _presaleID) external {
        require(msg.sender == presaleInfo[_presaleID].presaleCreator, "FilterManager: FORBIDDEN");
        require(block.timestamp >= presaleInfo[_presaleID].presaleArgs[7], "FilterManager: PRESALE_NOT_STARTED");      
        require(presaleInfo[_presaleID].totalFundsRaised >= presaleInfo[_presaleID].presaleArgs[2], "FilterManager: SOFTCAP_NOT_REACHED");
        require(presaleInfo[_presaleID].presaleStatus <= 1, "FilterManager: CANNOT_BE_FINALIZED");

        address tokenAddress = presaleInfo[_presaleID].tokenAddress;
        bool isBaseETH = presaleInfo[_presaleID].baseTokenAddress == wethAddress ? true : false;

        isTokenVerified[tokenAddress] = true;

        if (presaleInfo[_presaleID].presaleStatus == 0) presaleInfo[_presaleID].presaleStatus = 1;

        if (isBaseETH) processPresaleETH(_presaleID);
        else processPresale(_presaleID);


        //send owner his share of tokens
        TransferHelper.safeTransfer(tokenAddress, presaleInfo[_presaleID].presaleCreator, (presaleInfo[_presaleID].ownerShare * IERC20(tokenAddress).totalSupply()) / 100);

        //send any remaining tokens to treasury
        uint currentContractBalance = IERC20(tokenAddress).balanceOf(managerAddress);
        if (currentContractBalance > 0) TransferHelper.safeTransfer(tokenAddress, treasuryAddress, currentContractBalance);

        //mark as successful presale
        presaleInfo[_presaleID].presaleStatus == 2;
    }

    function cancelPresale(uint _presaleID) external {
        require(msg.sender == presaleInfo[_presaleID].presaleCreator, "FilterManager: FORBIDDEN");
        require(presaleInfo[_presaleID].presaleStatus <= 1, "FilterManager: CANNOT_BE_CANCELLED");

        presaleInfo[_presaleID].presaleStatus = 3; //cancelled status, users can claim back refund
        isTokenVerified[presaleInfo[_presaleID].tokenAddress] = true;
    }

    function claimRefund(uint _presaleID) external {
        require(userPresaleInvestments[_presaleID][msg.sender] > 0, "FilterManager: NOTHING_TO_CLAIM");

        if (presaleInfo[_presaleID].presaleStatus <= 1 && block.timestamp > (presaleInfo[_presaleID].presaleArgs[8] + maxPresaleFinalizeTime)) presaleInfo[_presaleID].presaleStatus == 3; // presale creator has not finalized, cancel presale

        require(presaleInfo[_presaleID].presaleStatus == 3, "FilterManager: CANNOT_CLAIM_REFUND");
        bool isBaseETH = presaleInfo[_presaleID].baseTokenAddress == wethAddress ? true : false;

        if (isBaseETH) payable(msg.sender).transfer(userPresaleInvestments[_presaleID][msg.sender]);
        else TransferHelper.safeTransfer(presaleInfo[_presaleID].tokenAddress, msg.sender, userPresaleInvestments[_presaleID][msg.sender]);

        userPresaleInvestments[_presaleID][msg.sender] = 0;
    }
}