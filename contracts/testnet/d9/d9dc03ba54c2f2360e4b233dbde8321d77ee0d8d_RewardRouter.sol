// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IESBT {
    // function updateIncreaseLogForAccount(address _account, address _collateralToken, 
            // uint256 _collateralSize,uint256 _positionSize, bool /*_isLong*/ ) external returns (bool);

    function scorePara(uint256 _paraId) external view returns (uint256);
    function createTime(address _account) external view returns (uint256);
    // function tradingKey(address _account, bytes32 key) external view returns (bytes32);
    function nickName(address _account) external view returns (string memory);


    function getReferralForAccount(address _account) external view returns (address[] memory , address[] memory);
    function userSizeSum(address _account) external view returns (uint256);
    // function updateFeeDiscount(address _account, uint256 _discount, uint256 _rebate) external;
    function updateFee(address _account, uint256 _origFee) external returns (uint256);
    // function calFeeDiscount(address _account, uint256 _amount) external view returns (uint256);

    function getESBTAddMpUintetRoles(address _mpaddress, bytes32 _key) external view returns (uint256[] memory);
    function updateClaimVal(address _account) external ;
    function userClaimable(address _account) external view returns (uint256, uint256);

    // function updateScoreForAccount(address _account, uint256 _USDamount, uint16 _opeType) external;
    function updateScoreForAccount(address _account, address /*_vault*/, uint256 _amount, uint256 _reasonCode) external;
    function updateTradingScoreForAccount(address _account, address _vault, uint256 _amount, uint256 _refCode) external;
    function updateSwapScoreForAccount(address _account, address _vault, uint256 _amount) external;
    function updateAddLiqScoreForAccount(address _account, address _vault, uint256 _amount, uint256 _refCode) external;
    // function updateStakeEDEScoreForAccount(address _account, uint256 _amount) external ;
    function getScore(address _account) external view returns (uint256);
    function getRefCode(address _account) external view returns (string memory);
    function accountToDisReb(address _account) external view returns (uint256, uint256);
    function rank(address _account) external view returns (uint256);
    function addressToTokenID(address _account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IElpManager {
    function cooldownDuration() external returns (uint256);
    function lastAddedAt(address _account) external returns (uint256);
    function addLiquidity(address _token, uint256 _amount, uint256 _minUsdx, uint256 _minElp) external returns (uint256);
    function removeLiquidity(address _tokenOut, uint256 _elpAmount, uint256 _minOut, address _receiver) external returns (uint256);
    // function removeLiquidityForAccount(address _account, address _tokenOut, uint256 _elpAmount, uint256 _minOut, address _receiver) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../DID/interfaces/IESBT.sol";

interface IVault {
    function isInitialized() external view returns (bool);
    function isSwapEnabled() external view returns (bool);
    function isLeverageEnabled() external view returns (bool);

    function setVaultUtils(address _vaultUtils) external;
    // function setError(uint256 _errorCode, string calldata _error) external;

    function router() external view returns (address);
    function usdx() external view returns (address);

    function whitelistedTokenCount() external view returns (uint256);

    function fundingInterval() external view returns (uint256);
    function totalTokenWeights() external view returns (uint256);
    function getTargetUsdxAmount(address _token) external view returns (uint256);

    function inManagerMode() external view returns (bool);
    function inPrivateLiquidationMode() external view returns (bool);

    function usdxSupply() external view returns (uint256);

    function approvedRouters(address _account, address _router) external view returns (bool);
    function isLiquidator(address _account) external view returns (bool);
    function isManager(address _account) external view returns (bool);

    function minProfitBasisPoints(address _token) external view returns (uint256);
    function tokenBalances(address _token) external view returns (uint256);
    function lastFundingTimes(address _token) external view returns (uint256);

    function setInManagerMode(bool _inManagerMode) external;
    function setManager(address _manager, bool _isManager) external;
    function setIsSwapEnabled(bool _isSwapEnabled) external;
    function setIsLeverageEnabled(bool _isLeverageEnabled) external;
    function setUsdxAmount(address _token, uint256 _amount) external;
    function setBufferAmount(address _token, uint256 _amount) external;
    function setMaxGlobalShortSize(address _token, uint256 _amount) external;
    function setInPrivateLiquidationMode(bool _inPrivateLiquidationMode) external;
    function setLiquidator(address _liquidator, bool _isActive) external;

    function setFundingRate(uint256 _fundingInterval, uint256 _fundingRateFactor, uint256 _stableFundingRateFactor) external;

    function setTokenConfig(
        address _token,
        uint256 _tokenDecimals,
        uint256 _redemptionBps,
        uint256 _minProfitBps,
        uint256 _maxUSDAmount,
        bool _isStable,
        bool _isShortable
    ) external;

    function setPriceFeed(address _priceFeed) external;
    function setRouter(address _router) external;
    function directPoolDeposit(address _token) external;
    function buyUSDX(address _token, address _receiver) external returns (uint256);
    function sellUSDX(address _token, address _receiver, uint256 _usdxAmount) external returns (uint256);
    function claimFeeToken(address _token) external returns (uint256);
    function swap(address _tokenIn, address _tokenOut, address _receiver) external returns (uint256);
    function increasePosition(address _account, address _collateralToken, address _indexToken, uint256 _sizeDelta, bool _isLong) external;
    function decreasePosition(address _account, address _collateralToken, address _indexToken, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external returns (uint256);
    function liquidatePosition(address _account, address _collateralToken, address _indexToken, bool _isLong, address _feeReceiver) external;
    function tokenToUsdMin(address _token, uint256 _tokenAmount) external view returns (uint256);
    function usdToTokenMax(address _token, uint256 _usdAmount) external view returns (uint256);
    function usdToTokenMin(address _token, uint256 _usdAmount) external view returns (uint256);

    function priceFeed() external view returns (address);
    function fundingRateFactor() external view returns (uint256);
    function stableFundingRateFactor() external view returns (uint256);
    function cumulativeFundingRates(address _token) external view returns (uint256);
    function getNextFundingRate(address _token) external view returns (uint256);
    // function getFeeBasisPoints(address _token, uint256 _usdxDelta, uint256 _feeBasisPoints, uint256 _taxBasisPoints, bool _increment) external view returns (uint256);



    function allWhitelistedTokensLength() external view returns (uint256);
    function allWhitelistedTokens(uint256) external view returns (address);
    function whitelistedTokens(address _token) external view returns (bool);
    function stableTokens(address _token) external view returns (bool);
    function shortableTokens(address _token) external view returns (bool);
    function feeReserves(address _token) external view returns (uint256);
    
    function globalShortSizes(address _token) external view returns (uint256);
    function globalShortAveragePrices(address _token) external view returns (uint256);
    function maxGlobalShortSizes(address _token) external view returns (uint256);
    function tokenDecimals(address _token) external view returns (uint256);
    function tokenWeights(address _token) external view returns (uint256);
    function guaranteedUsd(address _token) external view returns (uint256);
    function poolAmounts(address _token) external view returns (uint256);
    function bufferAmounts(address _token) external view returns (uint256);
    function reservedAmounts(address _token) external view returns (uint256);
    function usdxAmounts(address _token) external view returns (uint256);
    function maxUSDAmounts(address _token) external view returns (uint256);
    function getRedemptionAmount(address _token, uint256 _usdxAmount) external view returns (uint256);
    function getMaxPrice(address _token) external view returns (uint256);
    function getMinPrice(address _token) external view returns (uint256);
    
    function getDelta(address _indexToken, uint256 _size, uint256 _averagePrice, bool _isLong, uint256 _lastIncreasedTime) external view returns (bool, uint256);
    
    function getPosition(address _account, address _collateralToken, address _indexToken, bool _isLong) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);
    function getPositionByKey(bytes32 _key) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, bool, uint256);

 
    function tokenUtilization(address _token) external view returns (uint256);
    function claimFeeReserves( ) external returns (uint256) ;
    function claimableFeeReserves( )  external view returns (uint256);
    function feeSold (address _token)  external view returns (uint256);
    function feeReservesUSD() external view returns (uint256);

    function feeReservesRecord(uint256 _day) external view returns (uint256);
    function vaultUtilsAddress() external view returns (address);

    function feeClaimedUSD() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVaultPriceFeedV2 {
    function adjustmentBasisPoints(address _token) external view returns (uint256);
    function isAdjustmentAdditive(address _token) external view returns (bool);
    function setAdjustment(address _token, bool _isAdditive, uint256 _adjustmentBps) external;
    function setUseV2Pricing(bool _useV2Pricing) external;
    function setIsAmmEnabled(bool _isEnabled) external;
    function setIsSecondaryPriceEnabled(bool _isEnabled) external;
    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints) external;
    function setSpreadThresholdBasisPoints(uint256 _spreadThresholdBasisPoints) external;
    function setFavorPrimaryPrice(bool _favorPrimaryPrice) external;
    function setPriceSampleSpace(uint256 _priceSampleSpace) external;
    function setMaxStrictPriceDeviation(uint256 _maxStrictPriceDeviation) external;
    function getPrice(address _token, bool _maximise,bool,bool) external view returns (uint256);
    function getOrigPrice(address _token) external view returns (uint256);
    
    function getLatestPrimaryPrice(address _token) external view returns (uint256);
    function getPrimaryPrice(address _token, bool _maximise) external view returns (uint256, bool);
    function setTokenChainlink( address _token, address _chainlinkContract) external;
    function setTokenConfig(
        address _token,
        address _priceFeed,
        uint256 _priceDecimals,
        bool _isStrictStable
    ) external;
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/IRewardTracker.sol";
import "../core/interfaces/IElpManager.sol";
import "../core/interfaces/IVaultPriceFeedV2.sol";
import "../core/interfaces/IVault.sol";
import "../tokens/interfaces/IMintable.sol";
import "../tokens/interfaces/IWETH.sol";
import "../tokens/interfaces/IELP.sol";
import "../utils/EnumerableValues.sol";
import "../DID/interfaces/IESBT.sol";


contract RewardRouter is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address payable;

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.AddressSet;

    uint256 public cooldownDuration = 1 hours;
    mapping (address => uint256) public latestOperationTime;

    uint256 public constant PRICE_TO_EUSD = 10 ** 12; //ATTENTION: must be same as vault.
    uint256 public base_fee_point;  //using LVT_PRECISION
    uint256 public constant LVT_PRECISION = 10000;
    uint256 public constant LVT_MINFEE = 50;
    uint256 public constant PRICE_PRECISION = 10 ** 30; //ATTENTION: must be same as vault.
    uint256 public constant SWAP_THRESHOLD = 100 * (10 ** 30); //ATTENTION: must be same as vault.


    mapping(address => uint256) public claimedESBTRebate;
    mapping(address => uint256) public claimedESBTDiscount;


    bool public isInitialized;
    // address public weth;
    address public rewardToken;
    address public eusd;
    address public weth;
    address public esbt;

    // address[] public allWhitelistedToken;
    // mapping (address => bool) public whitelistedToken;
    EnumerableSet.AddressSet internal allToken;
    mapping (address => bool) public swapToken;
    mapping (address => bool) public isStable;
    mapping (address => bool) public swapStatus;
    mapping (address => EnumerableSet.AddressSet) internal ELPnContainsToken;
    mapping (address => address) ELPnStableTokens;

    address public pricefeed;
    uint256 public totalELPnWeights;
    EnumerableSet.AddressSet allWhitelistedELPn;
    address[] public whitelistedELPn;
    mapping (address => uint256) public rewardELPnWeights;
    mapping (address => address) public stakedELPnTracker;
    mapping (address => address) public stakedELPnVault;
    mapping (address => uint256) public tokenDecimals;


    event StakeElp(address account, uint256 amount);
    event UnstakeElp(address account, uint256 amount);

    //===
    event UserStakeElp(address account, uint256 amount);
    event UserUnstakeElp(address account, uint256 amount);

    event Claim(address receiver, uint256 amount);

    event BuyEUSD(
        address account,
        address token,
        uint256 amount,
        uint256 fee
    );

    event SellEUSD(
        address account,
        address token,
        uint256 amount,
        uint256 fee
    );
    event ClaimESBTEUSD(address _account, uint256 claimAmount);


    receive() external payable {
        require(msg.sender == weth, "Router: invalid sender");
    }
    
    function initialize(
        address _rewardToken,
        address _eusd,
        address _weth,
        address _pricefeed,
        uint256 _base_fee_point
    ) external onlyOwner {
        require(!isInitialized, "RewardTracker: already initialized");
        isInitialized = true;
        eusd = _eusd;
        weth = _weth;
        rewardToken = _rewardToken;
        pricefeed = _pricefeed;
        base_fee_point = _base_fee_point;
        tokenDecimals[eusd] = 18;//(eusd).decimals()
    }
    
    function setRewardToken(address _rewardToken)external onlyOwner {
        rewardToken = _rewardToken;
    }

    function setPriceFeed(address _pricefeed)  external onlyOwner {
        pricefeed = _pricefeed;
    }

    function adjustProfit(address _account, uint256 val_1, uint256 val_2 ) external onlyOwner {
        claimedESBTDiscount[_account] = val_1;
        claimedESBTRebate[_account] = val_2;
    }

    function setESBT(address _esbt)  external onlyOwner {
        esbt = _esbt;
    }

    function setPriceFeed(address _token, bool _status)  external onlyOwner {
        swapToken[_token] = _status;
    }

    function setBaseFeePoint(uint256 _base_fee_point) external onlyOwner {
        base_fee_point = _base_fee_point;
    }
    
    function setCooldownDuration(uint256 _setCooldownDuration)  external onlyOwner {
        cooldownDuration = _setCooldownDuration;
    }

    function setTokenConfig(
        address _token,
        uint256 _token_decimal,
        address _elp_n,
        bool _isStable
    ) external onlyOwner {
        if (!allToken.contains(_token)){
            allToken.add(_token);
        }
        tokenDecimals[_token] = _token_decimal;

        if (!ELPnContainsToken[_elp_n].contains(_token))
            ELPnContainsToken[_elp_n].add(_token);
        if (_isStable){
            ELPnStableTokens[_elp_n] = _token;
            isStable[_token] = true;
        }
    }

    function delToken(
        address _token,
        address _elp_n
    ) external onlyOwner {
        if (allToken.contains(_token)){
            allToken.remove(_token);
        } 
        if (ELPnContainsToken[_elp_n].contains(_token))
            ELPnContainsToken[_elp_n].remove(_token);
    }

    function setSwapToken(address _token, bool _status) external onlyOwner{
        swapStatus[_token] = _status;
    }

    function setELPn(
        address _elp_n,
        uint256 _elp_n_weight,
        address _stakedELPnVault,
        uint256 _elp_n_decimal,
        address _stakedElpTracker
    ) external onlyOwner {
        if (!allWhitelistedELPn.contains(_elp_n)) {

            allWhitelistedELPn.add(_elp_n);
        }

        uint256 _totalELPnWeights = totalELPnWeights;
        _totalELPnWeights = _totalELPnWeights.sub(rewardELPnWeights[_elp_n]);      
        totalELPnWeights = totalELPnWeights.add(_elp_n_weight);
        rewardELPnWeights[_elp_n] = _elp_n_weight;
        tokenDecimals[_elp_n] = _elp_n_decimal;
        stakedELPnTracker[_elp_n] = _stakedElpTracker;
        stakedELPnVault[_elp_n] = _stakedELPnVault;   
        whitelistedELPn = allWhitelistedELPn.valuesAt(0, allWhitelistedELPn.length());
    }

    function clearELPn(address _elp_n) external onlyOwner {
        require(allWhitelistedELPn.contains(_elp_n), "not included");
        totalELPnWeights = totalELPnWeights.sub(rewardELPnWeights[_elp_n]);
        allWhitelistedELPn.remove(_elp_n);

        delete rewardELPnWeights[_elp_n];
        delete stakedELPnTracker[_elp_n];

        whitelistedELPn = allWhitelistedELPn.valuesAt(0, allWhitelistedELPn.length());
    }


    // to help users who accidentally send their tokens to this contract
    function withdrawToken(address _token, address _account, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(_account, _amount);
    }

    function stakedELPnAmount() external view returns (address[] memory, uint256[] memory, uint256[] memory) {
        uint256 poolLength = whitelistedELPn.length;
        uint256[] memory _stakedAmount = new uint256[](poolLength);
        address[] memory _stakedELPn = new address[](poolLength);
        uint256[] memory _poolRewardRate = new uint256[](poolLength);

        for (uint80 i = 0; i < poolLength; i++) {
            _stakedELPn[i] = whitelistedELPn[i];
            _stakedAmount[i] = IRewardTracker(stakedELPnTracker[whitelistedELPn[i]]).poolStakedAmount();
            _poolRewardRate[i] = IRewardTracker(stakedELPnTracker[whitelistedELPn[i]]).poolTokenRewardPerInterval();
        }
        return (_stakedELPn, _stakedAmount, _poolRewardRate);
    }


    function stakeELPn(address _elp_n, uint256 _elpAmount) external nonReentrant returns (uint256) {
        require(_elpAmount > 0, "RewardRouter: invalid _amount");
        require(allWhitelistedELPn.contains(_elp_n), "RewardTracker: invalid stake ELP Token"); 
        address account = msg.sender;

        latestOperationTime[account] = block.timestamp;

        IRewardTracker(stakedELPnTracker[_elp_n]).stakeForAccount(account, account, _elp_n, _elpAmount);
        

        emit UserStakeElp(account, _elpAmount);

        return _elpAmount;
    }

    function unstakeELPn(address _elp_n, uint256 _tokenInAmount) external nonReentrant returns (uint256) {
        address account = msg.sender;
        require(block.timestamp.sub(latestOperationTime[account]) > cooldownDuration, "Cooldown Time Required.");
        latestOperationTime[account] = block.timestamp;

        require(_tokenInAmount > 0, "RewardRouter: invalid _elpAmount");
        require(allWhitelistedELPn.contains(_elp_n), "RewardTracker: invalid stake Token");
        IRewardTracker(stakedELPnTracker[_elp_n]).unstakeForAccount(account, _elp_n, _tokenInAmount, account);

        emit UserUnstakeElp(account, _tokenInAmount);

        return _tokenInAmount;
    }

    function claimEDEForAccount(address _account) external nonReentrant returns (uint256) {
        address account =_account == address(0) ? msg.sender : _account;
        return _claimEDE(account);
    }
    function claimEDE() external nonReentrant returns (uint256) {
        address account = msg.sender;
        return _claimEDE(account);
    }

    function claimEUSDForAccount(address _account) public nonReentrant returns (uint256) {
        address account =_account == address(0) ? msg.sender : _account;
        return _claimEUSD(account);
    }
    function claimEUSD() public nonReentrant returns (uint256) {
        address account = msg.sender;
        return _claimEUSD(account);
    }

    function claimEE(address[] memory _ELPlist) public nonReentrant returns (uint256, uint256) {
        address account = msg.sender;
        return _claimEEforAccount(account, _ELPlist);
    }

    function _claimEEforAccount(address _account, address[] memory _ELPlist)  internal returns (uint256, uint256) {
        require(block.timestamp.sub(latestOperationTime[_account]) > cooldownDuration, "Cooldown Time Required.");
        for (uint80 i = 0; i < _ELPlist.length; i++) {
            require(allWhitelistedELPn.contains(_ELPlist[i]), "invalid elp");
        }

        uint256 eusdClaimReward = 0;
        for (uint80 i = 0; i < _ELPlist.length; i++) {
            uint256 this_reward  = IRewardTracker(stakedELPnTracker[_ELPlist[i]]).claimForAccount(_account, _account);
            eusdClaimReward = eusdClaimReward.add(this_reward);
        }
        require(IERC20(rewardToken).balanceOf(address(this)) > eusdClaimReward, "insufficient EDE");
        IERC20(rewardToken).safeTransfer(_account, eusdClaimReward);
        address account =_account == address(0) ? msg.sender : _account;        
        uint256 edeClaimReward = 0;
        for (uint80 i = 0; i < _ELPlist.length; i++) {
            uint256 this_reward  = IELP(_ELPlist[i]).claimForAccount(account);
            edeClaimReward = edeClaimReward.add(this_reward);
        }
        return (edeClaimReward, eusdClaimReward);
    }


    function claimableEUSDForAccount(address _account) external view returns (uint256) {
        address account =_account == address(0) ? msg.sender : _account;
        uint256 totalClaimReward = 0;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            uint256 this_reward  = IELP(whitelistedELPn[i]).claimable(account);
            totalClaimReward = totalClaimReward.add(this_reward);
        }
        return totalClaimReward;        
    }
    function claimableEUSD() external view returns (uint256) {
        address account = msg.sender;
        uint256 totalClaimReward = 0;
        
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            uint256 this_reward  = IELP(whitelistedELPn[i]).claimable(account);
            totalClaimReward = totalClaimReward.add(this_reward);
        }
        return totalClaimReward;        
    }
    

    function claimableEUSDListForAccount(address _account) external view returns (address[] memory, uint256[] memory) {
        
        uint256 poolLength = whitelistedELPn.length;
        address account =_account == address(0) ? msg.sender : _account;
        address[] memory _stakedELPn = new address[](poolLength);
        uint256[] memory _rewardList = new uint256[](poolLength);
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            _rewardList[i] = IELP(whitelistedELPn[i]).claimable(account);
            _stakedELPn[i] = whitelistedELPn[i];
        }
        return (_stakedELPn, _rewardList);
    }
    function claimableEUSDList() external view returns (address[] memory, uint256[] memory) {
        
        uint256 poolLength = whitelistedELPn.length;
        address account = msg.sender;
        address[] memory _stakedELPn = new address[](poolLength);
        uint256[] memory _rewardList = new uint256[](poolLength);
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            _rewardList[i] = IELP(whitelistedELPn[i]).claimable(account);
            _stakedELPn[i] = whitelistedELPn[i];
        }
        return (_stakedELPn, _rewardList);
    }

    function claimAllForAccount(address _account) external nonReentrant returns ( uint256[] memory) {
        address account =_account == address(0) ? msg.sender : _account;
        uint256[] memory reward = new uint256[](2);
        reward[0] = _claimEDE(account);
        reward[1] = _claimEUSD(account);
        return reward;
    }
    function claimAll() external nonReentrant returns ( uint256[] memory) {
        address account = msg.sender ;
        uint256[] memory reward = new uint256[](2);
        reward[0] = _claimEDE(account);
        reward[1] = _claimEUSD(account);
        return reward;
    }

    function _claimEUSD(address _account) private returns (uint256) {
        address account =_account == address(0) ? msg.sender : _account;
        require(block.timestamp.sub(latestOperationTime[account]) > cooldownDuration, "Cooldown Time Required.");
        
        
        uint256 totalClaimReward = 0;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            uint256 this_reward  = IELP(whitelistedELPn[i]).claimForAccount(account);
            totalClaimReward = totalClaimReward.add(this_reward);
        }
        return totalClaimReward;
    }


    function _claimEDE(address _account) private returns (uint256) {
        require(block.timestamp.sub(latestOperationTime[_account]) > cooldownDuration, "Cooldown Time Required.");

        uint256 totalClaimReward = 0;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            uint256 this_reward  = IRewardTracker(stakedELPnTracker[whitelistedELPn[i]]).claimForAccount(_account, _account);
            totalClaimReward = totalClaimReward.add(this_reward);
        }

        require(IERC20(rewardToken).balanceOf(address(this)) > totalClaimReward, "insufficient EDE");
        IERC20(rewardToken).safeTransfer(_account, totalClaimReward);

        return totalClaimReward;
    }


    function claimableEDEListForAccount(address _account) external view returns (address[] memory, uint256[] memory) {
        
        uint256 poolLength = whitelistedELPn.length;
        address[] memory _stakedELPn = new address[](poolLength);
        uint256[] memory _rewardList = new uint256[](poolLength);
        address account =_account == address(0) ? msg.sender : _account;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            _rewardList[i] = IRewardTracker(stakedELPnTracker[whitelistedELPn[i]]).claimable(account);
            _stakedELPn[i] = whitelistedELPn[i];
        }
        return (_stakedELPn, _rewardList);
    }
    function claimableEDEList() external view returns (address[] memory, uint256[] memory) {
        
        address account = msg.sender ;
        uint256 poolLength = whitelistedELPn.length;
        address[] memory _stakedELPn = new address[](poolLength);
        uint256[] memory _rewardList = new uint256[](poolLength);
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            _rewardList[i] = IRewardTracker(stakedELPnTracker[whitelistedELPn[i]]).claimable(account);
            _stakedELPn[i] = whitelistedELPn[i];
        }
        return (_stakedELPn, _rewardList);
    }

    function claimableEDEForAccount(address _account) external view returns (uint256) {
        uint256 _rewardList = 0;
        address account =_account == address(0) ? msg.sender : _account;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            _rewardList = _rewardList.add(IRewardTracker(stakedELPnTracker[whitelistedELPn[i]]).claimable(account));
        }
        return _rewardList;
    }
    function claimableEDE() external view returns (uint256) {
        uint256 _rewardList = 0;
        address account = msg.sender;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            _rewardList = _rewardList.add(IRewardTracker(stakedELPnTracker[whitelistedELPn[i]]).claimable(account));
        }
        return _rewardList;
    }

    function withdrawToEDEPool() external {
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            IELP(whitelistedELPn[i]).withdrawToEDEPool();
        }       
    }


    function claimableESBTEUSD(address _account) external view returns (uint256, uint256)  {
        if (esbt == address(0)) return (0, 0);
        (uint256 accumReb, uint256 accumDis) = IESBT(esbt).userClaimable(_account);

        accumDis = claimedESBTDiscount[_account] > accumDis? 0 :  accumDis.sub(claimedESBTDiscount[_account]);
        accumReb = claimedESBTRebate[_account] > accumReb ? 0 : accumReb.sub(claimedESBTRebate[_account]);
        accumReb = accumReb.div(PRICE_TO_EUSD);
        accumDis = accumDis.div(PRICE_TO_EUSD);
        return  (accumDis,accumReb);
    }

    function claimESBTEUSD( ) public nonReentrant returns (uint256) {
        address _account = msg.sender;  
        if (esbt == address(0)) return (0);
        (uint256 accumReb, uint256 accumDis) = IESBT(esbt).userClaimable(_account);        
        uint256 claimAmount = accumDis.add(accumReb);
        emit ClaimESBTEUSD(_account, claimAmount);
        return claimAmount;
    }


    //------ EUSD Part 
    function _USDbyFee() internal view returns (uint256){
        uint256 feeUSD = 0;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            feeUSD = feeUSD.add( IELP(whitelistedELPn[i]).USDbyFee() );
        }
        return feeUSD;   
    }

    function _collateralAmount(address token) internal view returns (uint256) {
        uint256 colAmount = 0;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            colAmount = colAmount.add(IELP(whitelistedELPn[i]).TokenFeeReserved(token) );
        }    

        colAmount = colAmount.add(IERC20(token).balanceOf(address(this)));
        return colAmount;
    }

    function EUSDCirculation() public view returns (uint256) {
        uint256 _EUSDSupply = _USDbyFee().div(PRICE_TO_EUSD);
        return  _EUSDSupply.sub(IERC20(eusd).balanceOf(address(this)));
    }

    function feeAUM() public view returns (uint256) {
        uint256 aum = 0;

        address[] memory allWhitelistedToken = allToken.valuesAt(0, allToken.length());
        for (uint80 i = 0; i < allWhitelistedToken.length; i++) {
            uint256 price = IVaultPriceFeedV2(pricefeed).getOrigPrice(allWhitelistedToken[i]);
            uint256 poolAmount = _collateralAmount(allWhitelistedToken[i]);
            uint256 _decimalsTk = tokenDecimals[allWhitelistedToken[i]];
            aum = aum.add(poolAmount.mul(price).div(10 ** _decimalsTk));
        }
        return aum;
    }

    function lvt() public view returns (uint256) {
        uint256 _aumToEUSD = feeAUM().div(PRICE_TO_EUSD);
        uint256 _EUSDSupply = EUSDCirculation();
        return _aumToEUSD.mul(LVT_PRECISION).div(_EUSDSupply);
    }

    function _buyEUSDFee(uint256 _aumToEUSD, uint256 _EUSDSupply) internal view returns (uint256) {        
        uint256 fee_count = _aumToEUSD > _EUSDSupply ? base_fee_point : 0;
        return fee_count;
    }

    function _sellEUSDFee(uint256 _aumToEUSD, uint256 _EUSDSupply) internal view returns (uint256) {        
        uint256 fee_count = _aumToEUSD > _EUSDSupply ? base_fee_point : base_fee_point.add(_EUSDSupply.sub(_aumToEUSD).mul(LVT_PRECISION).div(_EUSDSupply) );
        return fee_count;
    }

    function buyEUSD( address _token, uint256 _amount) external nonReentrant returns (uint256)  {
        address _account = msg.sender;
        require(allToken.contains(_token), "Invalid Token");
        require(_amount > 0, "invalid amount");
        IERC20(_token).transferFrom(_account, address(this), _amount);
        uint256 buyAmount = _buyEUSD(_account, _token, _amount);
        return buyAmount;
    }

    function buyEUSDNative( ) external nonReentrant payable returns (uint256)  {
        address _account = msg.sender;
        uint256 _amount = msg.value;
        address _token = weth;
        require(allToken.contains(_token), "Invalid Token");
        require(_amount > 0, "invalid amount");

        IWETH(weth).deposit{value: msg.value}();
        uint256 buyAmount = _buyEUSD(_account, _token, _amount);

        return buyAmount;
    }



    function _buyEUSD(address _account, address _token, uint256 _amount) internal returns (uint256)  {
        uint256 _aumToEUSD = feeAUM().div(PRICE_TO_EUSD);
        uint256 _EUSDSupply = EUSDCirculation();

        uint256 fee_count = _buyEUSDFee(_aumToEUSD, _EUSDSupply);
        uint256 price = IVaultPriceFeedV2(pricefeed).getOrigPrice(_token);
        uint256 buyEusdAmount = _amount.mul(price).div(10 ** tokenDecimals[_token]).mul(10 ** tokenDecimals[eusd]).div(PRICE_PRECISION);
        uint256 fee_cut = buyEusdAmount.mul(fee_count).div(LVT_PRECISION);
        buyEusdAmount = buyEusdAmount.sub(fee_cut);
        
        require(buyEusdAmount < IERC20(eusd).balanceOf(address(this)), "insufficient EUSD");
        IERC20(eusd).safeTransfer(_account, buyEusdAmount);
        
        emit BuyEUSD(_account, _token, buyEusdAmount, fee_count); 
        return buyEusdAmount;
    }

    function claimGeneratedFee(address _token) public returns (uint256) {
        uint256 claimedTokenAmount = 0;
        for (uint80 i = 0; i < whitelistedELPn.length; i++) {
            claimedTokenAmount = claimedTokenAmount.add(IVault(stakedELPnVault[whitelistedELPn[i]]).claimFeeToken(_token) );
        }
        return claimedTokenAmount;
    }

    function swapCollateral() public {
        for (uint256 i = 0; i < whitelistedELPn.length; i++) {
            if (whitelistedELPn[i] == address(0)) continue;
            if (ELPnStableTokens[whitelistedELPn[i]] == address(0)) continue;
            address[] memory _wToken = ELPnContainsToken[whitelistedELPn[i]].valuesAt(0,ELPnContainsToken[whitelistedELPn[i]].length());
 
            for (uint80 k = 0; k < _wToken.length; k++) {
                // if (isStable[_wToken[k]]) continue;
                if (!swapStatus[_wToken[k]]) continue;

                if (IVault(stakedELPnVault[whitelistedELPn[i]]).tokenToUsdMin(_wToken[k], IERC20(_wToken[k]).balanceOf(address(this)))
                    < SWAP_THRESHOLD)
                    break;
                IVault(stakedELPnVault[whitelistedELPn[i]]).swap(_wToken[k], ELPnStableTokens[whitelistedELPn[i]], address(this));
            }
        }
    }

    function sellEUSD(address _token, uint256 _EUSDamount) public nonReentrant returns (uint256)  {
        require(allToken.contains(_token), "Invalid Token");
        require(_EUSDamount > 0, "invalid amount");
        address _account = msg.sender;
        uint256 sellTokenAmount = _sellEUSD(_account, _token, _EUSDamount);

        IERC20(_token).transfer(_account, sellTokenAmount);

        return sellTokenAmount;
    }

    function sellEUSDNative(uint256 _EUSDamount) public nonReentrant returns (uint256)  {
        address _token = weth;
        require(allToken.contains(_token), "Invalid Token");
        require(_EUSDamount > 0, "invalid amount");
        address _account = msg.sender;
        uint256 sellTokenAmount = _sellEUSD(_account, _token, _EUSDamount);

        IWETH(weth).withdraw(sellTokenAmount);
        payable(_account).sendValue(sellTokenAmount);

        return sellTokenAmount;
    }

    function _sellEUSD(address _account, address _token, uint256 _EUSDamount) internal returns (uint256)  {
        uint256 _aumToEUSD = feeAUM().div(PRICE_TO_EUSD);
        uint256 _EUSDSupply = EUSDCirculation();
        
        uint256 fee_count = _sellEUSDFee(_aumToEUSD, _EUSDSupply);
        uint256 price = IVaultPriceFeedV2(pricefeed).getOrigPrice(_token);
        uint256 sellTokenAmount = _EUSDamount.mul(PRICE_PRECISION).div(10 ** tokenDecimals[eusd]).mul(10 ** tokenDecimals[_token]).div(price);
        uint256 fee_cut = sellTokenAmount.mul(fee_count).div(LVT_PRECISION);
        sellTokenAmount = sellTokenAmount.sub(fee_cut);
        claimGeneratedFee(_token);
        require(IERC20(_token).balanceOf(address(this)) > sellTokenAmount, "insufficient sell token");
       
        IERC20(eusd).transferFrom(_account, address(this), _EUSDamount);
       
        uint256 burnEUSDAmount = _EUSDamount.mul(fee_count).div(LVT_PRECISION);
        if (burnEUSDAmount > 0){
            IMintable(eusd).burn(address(this), burnEUSDAmount);     
        }

        return sellTokenAmount;
    }



    function getEUSDPoolInfo() external view returns (uint256[] memory) {
        uint256[] memory _poolInfo = new uint256[](6);
        _poolInfo[0] = feeAUM();
        _poolInfo[1] = EUSDCirculation().add(IERC20(eusd).balanceOf(address(this)));
        _poolInfo[2] = EUSDCirculation();
        _poolInfo[3] = base_fee_point;
        _poolInfo[4] = _buyEUSDFee(_poolInfo[0].div(PRICE_TO_EUSD), _poolInfo[2]);
        _poolInfo[5] = _sellEUSDFee(_poolInfo[0].div(PRICE_TO_EUSD), _poolInfo[2]);
        return _poolInfo;
    }

    function getEUSDCollateralDetail() external view returns (address[] memory, uint256[] memory, uint256[] memory) {
        address[] memory allWhitelistedToken = allToken.valuesAt(0, allToken.length());
        uint256 _length = allWhitelistedToken.length;
        address[] memory _collateralToken = new address[](_length);
        uint256[] memory _collageralAmount = new uint256[](_length);
        uint256[] memory _collageralUSD  = new uint256[](_length);

        for (uint256 i = 0; i < allWhitelistedToken.length; i++) {
            uint256 price = IVaultPriceFeedV2(pricefeed).getOrigPrice(allWhitelistedToken[i]);
            _collateralToken[i] = allWhitelistedToken[i];
            _collageralAmount[i] =  _collateralAmount(allWhitelistedToken[i]);
            uint256 _decimalsTk = tokenDecimals[allWhitelistedToken[i]];
            _collageralUSD[i] = _collageralAmount[i].mul(price).div(10 ** _decimalsTk);
        }

        return (_collateralToken, _collageralAmount, _collageralUSD);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRewardTracker {
    // function depositBalances(address _account, address _depositToken) external view returns (uint256);
    function stakedAmounts(address _account) external view returns (uint256);
    function updateRewardsForUser(address _account) external;
    function poolStakedAmount() external view returns (uint256);
    
    function stake(address _depositToken, uint256 _amount) external;
    function stakeForAccount(address _fundingAccount, address _account, address _depositToken, uint256 _amount) external;
    function unstake(address _depositToken, uint256 _amount) external;
    function unstakeForAccount(address _account, address _depositToken, uint256 _amount, address _receiver) external;
    // function tokensPerInterval() external view returns (uint256);
    function claim(address _receiver) external returns (uint256);
    function claimForAccount(address _account, address _receiver) external returns (uint256);
    function claimable(address _account) external view returns (uint256);
    function averageStakedAmounts(address _account) external view returns (uint256);
    function cumulativeRewards(address _account) external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);

    function poolTokenRewardPerInterval() external view returns (uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IELP {
    // function mint(address _account, uint256 _amount) external;
    // function burn(address _account, uint256 _amount) external;
    function updateStakingAmount(address _account, uint256 _amount) external;
    function claimForAccount(address _account) external returns (uint256);
    function claimable(address _account) external view returns (uint256);
    function USDbyFee( ) external  view returns (uint256);
    function TokenFeeReserved( address _token) external  view returns (uint256);
    function withdrawToEDEPool() external  returns (uint256);
    function vault() external  returns (address);
    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMintable {
    function isMinter(address _account) external returns (bool);
    function setMinter(address _minter, bool _isActive) external;
    function mint(address _account, uint256 _amount) external;
    function burn(address _account, uint256 _amount) external;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library EnumerableValues {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    function valuesAt(EnumerableSet.Bytes32Set storage set, uint256 start, uint256 end) internal view returns (bytes32[] memory) {
        uint256 max = set.length();
        if (end > max) { end = max; }

        bytes32[] memory items = new bytes32[](end - start);
        for (uint256 i = start; i < end; i++) {
            items[i - start] = set.at(i);
        }

        return items;
    }


    function valuesAt(EnumerableSet.AddressSet storage set, uint256 start, uint256 end) internal view returns (address[] memory) {
        uint256 max = set.length();
        if (end > max) { end = max; }

        address[] memory items = new address[](end - start);
        for (uint256 i = start; i < end; i++) {
            items[i - start] = set.at(i);
        }

        return items;
    }


    function valuesAt(EnumerableSet.UintSet storage set, uint256 start, uint256 end) internal view returns (uint256[] memory) {
        uint256 max = set.length();
        if (end > max) { end = max; }

        uint256[] memory items = new uint256[](end - start);
        for (uint256 i = start; i < end; i++) {
            items[i - start] = set.at(i);
        }

        return items;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}