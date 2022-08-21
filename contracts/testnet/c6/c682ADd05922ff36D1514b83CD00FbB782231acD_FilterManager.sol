/**
 *Submitted for verification at BscScan.com on 2022-08-20
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
    function transferFrom(address, address, uint) external returns (bool);
    function approve(address, uint) external;
}

contract FilterManager {
    bool public isInitialized;

    address public managerAddress = address(this);
    address public adminAddress;
    address public feeToAddress;
    address public factoryAddress;
    address public routerAddress;
    address public deployerAddress;
    address public wethAddress;

    bool public tokenCreationAllowed;
    bool public verificationRequestsAllowed;
    bool public presaleCreationAllowed; 

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

    mapping(uint => presaleData) public presaleInfo;
    mapping(uint => mapping(address => uint)) public userPresaleInvestments;
    mapping(address => uint[]) public userBoughtPresales;

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

    modifier onlyAdminOrContracts() {
        require(msg.sender == adminAddress || msg.sender == factoryAddress || msg.sender == routerAddress || msg.sender == deployerAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyRouter() {
        require(msg.sender == routerAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier onlyContracts() {
        require(msg.sender == factoryAddress || msg.sender == routerAddress || msg.sender == deployerAddress, "FilterManager: FORBIDDEN");
        _;
    }

    modifier untilInitialized() {
        require(!isInitialized, "FilterManager: ALREADY_INITIALIZED");
        _;
    }

    // **** VIEW FUNCTIONS ****

    function isLiquidityLocked(address _liquidityProviderAddress, address _pairAddress) public view returns (bool) {
        return block.timestamp < liquidityUnlockTimes[_liquidityProviderAddress][_pairAddress] ? true : false;
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

    function setAdminAddress(address _adminAddress) public onlyAdmin {
        require(msg.sender == adminAddress, "FilterManager: FORBIDDEN");
        adminAddress = _adminAddress;
    }

    function setFeeToAddress(address _feeToAddress) public onlyAdmin {
        feeToAddress = _feeToAddress;
    }

    // **** ADMIN FUNCTIONS (router) ****

    function setMinLiquidityLockTime(uint _minLiquidityLockTime) public onlyAdmin {
        minLiquidityLockTime = _minLiquidityLockTime;
    }

    function setTokenVerified(address _tokenAddress) public onlyAdminOrContracts {
        isTokenVerified[_tokenAddress] = true;
    }

    function setLiquidityUnlockTime(address _userAddress, address _pairAddress, uint _liquidityLockTime) public onlyContracts {
        liquidityUnlockTimes[_userAddress][_pairAddress] = _liquidityLockTime;
    }

    function imposeLiquidityLock(address _userAddress, address _pairAddress, uint _liquidityLockTime) public onlyRouter {
        require(_liquidityLockTime >= minLiquidityLockTime, "FilterRouter: LOCKTIME_TOO_SHORT");

        if (liquidityUnlockTimes[_userAddress][_pairAddress] == 0) {
            setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);
        }

        else if (liquidityUnlockTimes[_userAddress][_pairAddress] < block.timestamp) {
            setLiquidityUnlockTime(_userAddress, _pairAddress, block.timestamp + _liquidityLockTime);
        }
    }

    function removeLiquidityLock(address _userAddress, address _pairAddress) public onlyAdmin {
        liquidityUnlockTimes[_userAddress][_pairAddress] = 0;
    }

    // **** ADMIN FUNCTIONS (deployer) ****

    function setTokenCreationAllowed(bool _tokenCreationAllowed) public onlyAdmin {
        tokenCreationAllowed = _tokenCreationAllowed;
    }

    function setTokenMintFee(uint _tokenMintFee) public onlyAdmin {
        tokenMintFee = _tokenMintFee;
    }

    function addTokenTemplate(address _templateAddress) public onlyAdmin {
        tokenTemplateAddresses[numTokenTemplates] = _templateAddress;
        numTokenTemplates++;
    }

    function removeTokenTemplate(uint _templateIndex) public onlyAdmin {
        tokenTemplateAddresses[_templateIndex] = address(0);
        numTokenTemplates--;
    }

    function setMaxOwnerShare(uint _maxOwnerShare) public onlyAdmin {
        maxOwnerShare = _maxOwnerShare;
    }

    // **** ADMIN FUNCTIONS (presale) ****

    function setPresaleCreationAllowed(bool _presaleCreationAllowed) public onlyAdmin {
        presaleCreationAllowed = _presaleCreationAllowed;
    }

    function setPresaleFee(uint _presaleFee) public onlyAdmin {
        presaleFee = _presaleFee;
    }

    function setMinPresaleDuration(uint _minPresaleDuration) public onlyAdmin {
        minPresaleDuration = _minPresaleDuration;
    }

    function setMaxPresaleDuration(uint _maxPresaleDuration) public onlyAdmin {
        maxPresaleDuration = _maxPresaleDuration;
    }

    function setMaxPresaleFinalizeTime(uint _maxPresaleFinalizeTime) public onlyAdmin {
        maxPresaleFinalizeTime = _maxPresaleFinalizeTime;
    }

    // **** ADMIN FUNCTIONS (verification requests) ****

    function setVerificationRequestsAllowed(bool _verificationRequestsAllowed) public onlyAdmin {
        verificationRequestsAllowed = _verificationRequestsAllowed;
    }

    function setVerificationRequestFee(uint _verificationRequestFee) public onlyAdmin {
        verificationRequestFee = _verificationRequestFee;
    }

    function setVerificationRequestDeadline(uint _verificationRequestDeadline) public onlyAdmin {
        verificationRequestDeadline = _verificationRequestDeadline;
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

    // **** VERIFICATION REQUEST FUNCTIONS ****

    function makeVerificationRequest(address _tokenAddress) public payable {
        require(verificationRequestsAllowed, "FilterManager: NEW_REQUESTS_NOT_ALLOWED");
        require(verificationRequestStatuses[_tokenAddress] == 0 || verificationRequestStatuses[_tokenAddress] == 4, "FilterManager: ALREADY_SUBMITTED");
        require(!isTokenVerified[_tokenAddress], "FilterManager: ALREADY_VERIFIED");    
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

    // **** PRESALE FUNCTIONS ****

    function createPresale(
            uint _tokenType, 
            string memory _tokenName, 
            string memory _tokenSymbol, 
            bytes32[] memory _tokenArgs,
            uint[] memory _presaleArgs, // presalePrice, launchPrice, softCap, hardCap, minContributionAmount, maxContributionAmount, liquidityPercentage, presaleStartTime, presaleEndTime
            address _baseTokenAddress,
            uint _ownerShare,
            uint _liquidityLockTime
        ) public {
        require(presaleCreationAllowed, "FilterManager: PRESALE_CREATION_NOT_ALLOWED");

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
    }

    function investInPresale(uint _presaleID, uint _buyAmount) public payable {
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
            IERC20(tokenAddress).transfer(msg.sender, userTokenAmount);
        }

        else {
            require(_buyAmount > 0, "FilterManager: INSUFFICIENT_INPUT_AMOUNT");
            userContributedAmount = _buyAmount;

            if (userContributedAmount >= remainingInvestableAmount) {
                userContributedAmount = remainingInvestableAmount;
                IERC20(tokenAddress).transfer(msg.sender, _buyAmount - remainingInvestableAmount);
                presaleInfo[_presaleID].presaleStatus = 1;
            }

            uint userTokenAmount = (userContributedAmount * presaleInfo[_presaleID].presaleArgs[0]) / 1e18;
            IERC20(tokenAddress).transfer(msg.sender, userTokenAmount);
        }

        presaleInfo[_presaleID].totalFundsRaised += userContributedAmount;
        presaleInfo[_presaleID] = presaleInfo[_presaleID];

        userPresaleInvestments[_presaleID][msg.sender] += userContributedAmount;
        userBoughtPresales[msg.sender].push(_presaleID);
    }

    function processPresaleETH(uint _presaleID) private {
        uint totalTokenLiquidity = presaleInfo[_presaleID].totalFundsRaised;
        uint presaleLiquidityFee = (totalTokenLiquidity * presaleFee) / 10000;
        payable(feeToAddress).transfer(presaleLiquidityFee);

        IERC20(presaleInfo[_presaleID].tokenAddress).approve(routerAddress, type(uint).max);

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

    function processPresaleAltPair(uint _presaleID) private {
        uint totalTokenLiquidity = presaleInfo[_presaleID].totalFundsRaised;
        uint presaleLiquidityFee = (totalTokenLiquidity * presaleFee) / 10000;
        IERC20(presaleInfo[_presaleID].baseTokenAddress).transfer(feeToAddress, presaleLiquidityFee);

        //verify token 
        IERC20(presaleInfo[_presaleID].tokenAddress).approve(routerAddress, type(uint).max);

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

    function finalizePresale(uint _presaleID) public {
        require(msg.sender == presaleInfo[_presaleID].presaleCreator, "FilterManager: FORBIDDEN");
        require(block.timestamp >= presaleInfo[_presaleID].presaleArgs[7], "FilterManager: PRESALE_NOT_STARTED");      
        require(presaleInfo[_presaleID].totalFundsRaised >= presaleInfo[_presaleID].presaleArgs[2], "FilterManager: SOFTCAP_NOT_REACHED");
        require(presaleInfo[_presaleID].presaleStatus <= 1, "FilterManager: CANNOT_BE_FINALIZED");

        address tokenAddress = presaleInfo[_presaleID].tokenAddress;
        bool isBaseETH = presaleInfo[_presaleID].baseTokenAddress == wethAddress ? true : false;

        isTokenVerified[tokenAddress] = true;

        if (presaleInfo[_presaleID].presaleStatus == 0) {
            presaleInfo[_presaleID].presaleStatus = 1;
        }

        if (isBaseETH) {
            processPresaleETH(_presaleID);
        }

        else {
            processPresaleAltPair(_presaleID);
        }

        //send owner his share of tokens
        IERC20(tokenAddress).transfer(presaleInfo[_presaleID].presaleCreator, ((presaleInfo[_presaleID].ownerShare * IERC20(tokenAddress).totalSupply()) / 100));

        //burn any remaining tokens
        uint currentContractBalance = IERC20(tokenAddress).balanceOf(address(this));
        if (currentContractBalance > 0) {
            IERC20(tokenAddress).transfer(address(0), currentContractBalance);
        }

        //mark as successful presale
        presaleInfo[_presaleID].presaleStatus == 2;
    }

    function cancelPresale(uint _presaleID) public {
        require(msg.sender == presaleInfo[_presaleID].presaleCreator, "FilterManager: FORBIDDEN");
        require(presaleInfo[_presaleID].presaleStatus <= 1, "FilterManager: CANNOT_BE_CANCELLED");

        presaleInfo[_presaleID].presaleStatus = 3; //cancelled status, users can claim back refund
    }

    function claimRefund(uint _presaleID) public {
        require(userPresaleInvestments[_presaleID][msg.sender] > 0, "FilterManager: NOTHING_TO_CLAIM");

        if(presaleInfo[_presaleID].presaleStatus <= 1 && block.timestamp > (presaleInfo[_presaleID].presaleArgs[8] + maxPresaleFinalizeTime)) {
            presaleInfo[_presaleID].presaleStatus == 3; // presale creator has not finalized, cancel presale
        }

        require(presaleInfo[_presaleID].presaleStatus == 3, "FilterManager: CANNOT_CLAIM_REFUND");

        bool isBaseETH = presaleInfo[_presaleID].baseTokenAddress == wethAddress ? true : false;

        if (isBaseETH) {
            payable(msg.sender).transfer(userPresaleInvestments[_presaleID][msg.sender]);
        }

        else {
            IERC20(presaleInfo[_presaleID].tokenAddress).transfer(msg.sender, userPresaleInvestments[_presaleID][msg.sender]);
        }

        userPresaleInvestments[_presaleID][msg.sender] = 0;
    }
}