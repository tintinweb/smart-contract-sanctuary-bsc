/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

interface IFilterDeployer {
    function createPresaleToken(uint, string memory, string memory, uint[] memory, address) external returns (address);
}

interface IFilterFactory {
    function getPair(address, address) external view returns (address);
}

interface IFilterRouter {
    function addLiquidity(address, address, uint, uint, uint, uint, address, uint, uint) external returns (uint, uint, uint);
    function addLiquidityETH(address, uint, uint, uint, address, uint, uint) external payable returns (uint, uint, uint);
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
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

    uint public verificationRequestFee; // fixed amount in ETH
    uint public verificationRequestDeadline;

    mapping(address => address) public verificationRequestMaker;
    mapping(address => uint) public verificationRequestStatuses;
    mapping(address => uint) public verificationRequestDeadlines;
    
    event requestSubmitted(address, uint);

    bool public verificationRequestsAllowed;
    bool public tokenCreationAllowed;

    // **** ROUTER SPECIFIC ****

    mapping(address => mapping(address => uint)) public liquidityUnlockTimes;
    mapping(address => bool) public isTokenVerified;

    uint public minLiquidityLockTime;

    // **** DEPLOYER SPECIFIC ****

    mapping(uint => address) public tokenTemplateAddresses;

    uint public tokenMintFee; // in basis points
    uint public presaleFee; // in basis points
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

    modifier onlyContracts() {
        require(msg.sender == factoryAddress || msg.sender == routerAddress || msg.sender == deployerAddress, "FilterManager: FORBIDDEN");
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

    function setPresaleFee(uint _presaleFee) public onlyAdmin {
        presaleFee = _presaleFee;
    }

    function setVerificationRequestDeadline(uint _verificationRequestDeadline) public onlyAdmin {
        verificationRequestDeadline = _verificationRequestDeadline;
    }

    function removeLiquidityLock(address _userAddress, address _tokenAddress) public onlyAdmin {
        liquidityUnlockTimes[_userAddress][_tokenAddress] = 0;
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

    function setVerificationRequestsAllowed(bool _verificationRequestsAllowed) public onlyAdmin {
        verificationRequestsAllowed = _verificationRequestsAllowed;
    }

    function settokenCreationAllowed(bool _tokenCreationAllowed) public onlyAdmin {
        tokenCreationAllowed = _tokenCreationAllowed;
    }

    // **** ADMIN FUNCTIONS (router) ****

    function setMinLiquidityLockTime(uint _minLiquidityLockTime) public onlyAdmin {
        minLiquidityLockTime = _minLiquidityLockTime;
    }

    function setTokenVerified(address _tokenAddress) public onlyAdminOrContracts {
        isTokenVerified[_tokenAddress] = true;
    }

    function setLiquidityUnlockTime(address _userAddress, address _tokenAddress, uint _liquidityLockTime) public onlyContracts {
        liquidityUnlockTimes[_userAddress][_tokenAddress] = _liquidityLockTime;
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
        //require claim is done within 30 days, or funds go back to developers
        require(msg.sender == verificationRequestMaker[_tokenAddress], "FilterManager: NOT_REQUEST_MAKER");
        require(verificationRequestStatuses[_tokenAddress] == 1, "FilterManager: CANNOT_CLAIM");
        require(verificationRequestDeadlines[_tokenAddress] < block.timestamp + verificationRequestDeadline, "FilterManager: NOT_EXPIRED_YET");

        verificationRequestStatuses[_tokenAddress] = 4;

        payable(verificationRequestMaker[_tokenAddress]).transfer(verificationRequestFee);
    }

    // **** PRESALE FUNCTIONS ****


    bool public presaleCreationAllowed;

    function setPresaleCreationAllowed(bool _presaleCreationAllowed) public onlyAdmin {
        presaleCreationAllowed = _presaleCreationAllowed;
    }


        /* 
        PRESALE PARAMETERS

        (0) uint presalePrice
        (1) uint launchPrice
        (2) uint softCap
        (3) uint hardCap
        (4) uint minContributionAmount
        (5) uint maxContributionAmount
        (6) uint liquidityPercentage
        (7) uint presaleStartTime
        (8) uint presaleEndTime
        (9) uint launchTime
        */

    struct presaleData {
        address tokenAddress;
        address baseTokenAddress;
        address presaleCreator;
        uint ownerShare;
        uint[] presaleArgs;
        uint totalFundsRaised;
        uint liquidityLockTime;
        uint presaleStatus; //0 = created, 1 = awaiting start, 2 = success, 3 = fail
    }

    uint public minPresaleDuration = 86400;
    uint public maxPresaleDuration = 86400 * 30;
    uint public presaleMaxFinalizeTime = 86400;

    mapping(uint => presaleData) public presaleInfo;
    mapping(uint => mapping(address => uint)) public userPresaleInvestments;

    uint public numPresalesCreated;



    /*
        When presale is created: token is created, X amount goes to owner, X amount is held by this contract (to go to PCS liquidity later on), and remaining held by this contract

        Token is not verified safe yet, so no one can add liquidity yet

        When user investInPresale(), they get their share of tokens

        Total tokens required for presale = (presale price * hardcap) + (launch price * hardcap * (liquidity percentage / 100)) + ownerShare
        
    */

    function createPresale(
            uint _tokenType, 
            string memory _tokenName, 
            string memory _tokenSymbol, 
            uint[] memory _tokenArgs,
            uint[] memory _presaleArgs,
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

        uint presaleFinalizeTime = _presaleArgs[9] - _presaleArgs[8];
        require(presaleFinalizeTime <= presaleMaxFinalizeTime, "FilterManager: FINALIZE_TIME_TOO_LONG");

        require(_ownerShare <= maxOwnerShare, "FilterManager: DEV_SHARE_TOO_HIGH");
        require(_liquidityLockTime >= minLiquidityLockTime, "FilterManager: LOCKTIME_TOO_SHORT");
        require(tokenTemplateAddresses[_tokenType] != address(0), "FilterManager: INVALID_TOKEN_TYPE");

        uint presaleBuyersShare = 100 - _presaleArgs[6] - _ownerShare;
        require(presaleBuyersShare >= _ownerShare, "FilterManager: OWNER_SHARE_TOO_HIGH");

        uint totalTokensRequired = (_presaleArgs[0] * _presaleArgs[3]) + ((_presaleArgs[1] * _presaleArgs[3] * _presaleArgs[6]) / 100) + ((_ownerShare * _tokenArgs[0]) / 100);
        require(_tokenArgs[0] >= totalTokensRequired, "FilterManager: TOKEN_SUPPLY_TOO_LOW");
        
        //Token Allocation: Owner share | Tokens to presale buyers | Tokens into liquidity
        //all good, now create a presale

        address deployedTokenAddress = IFilterDeployer(deployerAddress).createPresaleToken(_tokenType, _tokenName, _tokenSymbol, _tokenArgs, msg.sender);

        //owner has his share, address(this) has lions share

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
        uint remainingInvestableAmount = presaleInfo[_presaleID].presaleArgs[5] - presaleInfo[_presaleID].totalFundsRaised;
        bool isBaseETH = presaleInfo[_presaleID].baseTokenAddress == wethAddress ? true : false;
        uint userContributedAmount;

        if (isBaseETH) {
            userContributedAmount = msg.value;

            if (remainingInvestableAmount >= userContributedAmount) {
                userContributedAmount = remainingInvestableAmount - msg.value;
                payable(msg.sender).transfer(msg.value - remainingInvestableAmount);
                presaleInfo[_presaleID].presaleStatus = 1;
            }

            uint userTokenAmount = userContributedAmount * presaleInfo[_presaleID].presaleArgs[0]; // assuming 18 decimals!!!
            IERC20(tokenAddress).transfer(msg.sender, userTokenAmount);
        }

        else {
            userContributedAmount = _buyAmount;

            if (remainingInvestableAmount >= _buyAmount) {
                userContributedAmount = remainingInvestableAmount - _buyAmount;
                IERC20(tokenAddress).transfer(msg.sender, _buyAmount - remainingInvestableAmount);
                presaleInfo[_presaleID].presaleStatus = 1;
            }

            uint userTokenAmount = userContributedAmount * presaleInfo[_presaleID].presaleArgs[0]; // assuming 18 decimals!!!
            IERC20(tokenAddress).transfer(msg.sender, userTokenAmount);
        }

        presaleInfo[_presaleID].totalFundsRaised += userContributedAmount;
        presaleInfo[_presaleID] = presaleInfo[_presaleID];

        userPresaleInvestments[_presaleID][msg.sender] += userContributedAmount;
    }

    function processPresaleETH(uint _presaleID) internal {
        uint totalTokenLiquidity = presaleInfo[_presaleID].totalFundsRaised;
        uint presaleLiquidityFee = (totalTokenLiquidity * presaleFee) / 10000;
        payable(feeToAddress).transfer(presaleLiquidityFee);

        IERC20(presaleInfo[_presaleID].tokenAddress).approve(routerAddress, type(uint).max);

        //add liquidity
        uint tokensForLiquidity = (presaleInfo[_presaleID].presaleArgs[1] * presaleInfo[_presaleID].presaleArgs[3] * presaleInfo[_presaleID].presaleArgs[6]) / 100;
        
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

    function processPresaleAltPair(uint _presaleID) internal {
        uint totalTokenLiquidity = presaleInfo[_presaleID].totalFundsRaised;
        uint presaleLiquidityFee = (totalTokenLiquidity * presaleFee) / 10000;
        IERC20(presaleInfo[_presaleID].baseTokenAddress).transfer(feeToAddress, presaleLiquidityFee);

        //verify token 
        IERC20(presaleInfo[_presaleID].tokenAddress).approve(routerAddress, type(uint).max);

        //add liquidity
        uint tokensForLiquidity = (presaleInfo[_presaleID].presaleArgs[1] * presaleInfo[_presaleID].presaleArgs[3] * presaleInfo[_presaleID].presaleArgs[6]) / 100;
        
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
        require(block.timestamp >= presaleInfo[_presaleID].presaleArgs[7], "FilterManager: PRESALE_NOT_STARTED");
        require(msg.sender == presaleInfo[_presaleID].presaleCreator, "FilterManager: FORBIDDEN");
        require(presaleInfo[_presaleID].totalFundsRaised >= presaleInfo[_presaleID].presaleArgs[2], "FilterManager: SOFTCAP_NOT_REACHED");
        require(presaleInfo[_presaleID].presaleStatus <= 1, "FilterManager: CANNOT_BE_FINALIZED");

        if (presaleInfo[_presaleID].presaleStatus == 0) {
            presaleInfo[_presaleID].presaleStatus = 1;
        }
        address tokenAddress = presaleInfo[_presaleID].tokenAddress;
        bool isBaseETH = presaleInfo[_presaleID].baseTokenAddress == wethAddress ? true : false;

        isTokenVerified[tokenAddress] = true;

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
        require(presaleInfo[_presaleID].presaleStatus == 3, "FilterManager: CANNOT_CLAIM_REFUND");
        require(userPresaleInvestments[_presaleID][msg.sender] > 0, "FilterManager: NOTHING_TO_CLAIM");

        payable(msg.sender).transfer(userPresaleInvestments[_presaleID][msg.sender]);
        userPresaleInvestments[_presaleID][msg.sender] = 0;
    }
}