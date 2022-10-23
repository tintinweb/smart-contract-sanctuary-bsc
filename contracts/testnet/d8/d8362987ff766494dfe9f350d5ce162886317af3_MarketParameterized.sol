/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
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
        // On the first call to nonReentrant, _notEntered will be true
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


interface IWOLFPACKRewardManager {
    function notifyReward(address rewardee, bool predictionQualified, bool liquidityQualified, bool managementQualified) external;
}

interface IWOLFPACKStakingManager {
    function notifyReward(uint256 amount) external;
}

interface IMarketUtility {
    function getBasicMarketData() external view returns (uint256, uint256, uint256, address, address, address); 
    function getChainLinkLatestPricesUSD(address _feedAddress0, address _feedAddress1) external view returns (uint256, uint256);
    function calculateMarketWinnerOraclized (uint256 option0InitPrice, address option0Feed, uint256 option1InitPrice, address option1Feed) external view returns (bool, uint256, uint256);
    function calulateMarketWinnerParameterized(uint256 option0InitPrice, uint256 option1InitPrice, uint256 option0SettlementPrice, uint256 option1SettlementPrice) external view returns (bool);
}

interface IMarketLiquidity {
    function notifyReward(uint256 amount) external;
    function requestMarketPayout(uint256 payout) external returns (uint256);
}

/// @title MarketParameterized
/// @author LONEWOLF
///
/// Prediction market contract that works with any two parameterized assets that have no oraclized price feeds available. 

contract MarketParameterized is Ownable, ReentrancyGuard {

    enum MarketStatus {
      Live,
      InSettlement
    }

    struct PredictionData {
        uint256 index;
        uint256 marketUuid;
        bool option;
        uint256 timeframe;
        uint256 balance;
        uint256 leverage;
        uint256 size;
        uint256 riskOn;
        bool settled;
    }

    struct MarketData {
        uint256 index;
        uint256 timebox;
        uint256 initializationTimestamp;
        uint256 settlementTimestamp;
        uint256 payoutPool;
        uint256 option0InitPrice;
        uint256 option1InitPrice;
        uint256 option0SettlementPrice;
        uint256 option1SettlementPrice;
        bool winningOption;
        bool settled;
        mapping(bool => uint256) optionSize;
        mapping(bool => uint256) optionRisk;
    }

    struct Timebox {
        MarketStatus status;
        uint256 gracePeriod;
    }

    mapping(uint256 => mapping(address => PredictionData)) private predictions; 
    mapping(uint256 => MarketData) private markets;
    mapping(uint256 => Timebox) private timeboxData;
    mapping(uint256 => uint256) activeTimeboxedMarkets;

    uint256 constant MAXLEVERAGE = 5;
    uint256 private marketId;
    uint256 private predictionId;
    uint256 public settlementPeriod;
    uint256 public predictionQualifier;
    uint256 public mrt;
    uint256[] public timeboxedMarkets = [1 hours, 4 hours, 12 hours, 1 days, 1 weeks];
    uint256[] private predictionIndex;
    uint256[] private marketIndex;

    address public marketCurrency = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; 
    address public marketUtility = 0x55425307BAe7Ec2b5b941fB479407927E82b8ebb; 
    address public marketLiquidity;
    address public WPACKRewardManager;
    address public WPACKStakingManager;

    bool private initialized;
   
    IERC20 marketToken = IERC20(marketCurrency);

    event PredictionPlaced(address indexed predictor, uint256 predictionId, bool option, uint256 timeframe, uint256 leverage, uint256 stake);
    event PredictionChanged(address indexed predictor, bool increase, uint256 change);
    event PredictionReverted(address indexed predictor, uint256 balanceReverted);
    event PredictionSettled(address indexed predictor, bool win, uint256 roi);
    event TimeboxReset(address caller, uint256 newMarketId, uint256 marketTimebox, uint256 timestamp);
    event MarketSettled(address caller, uint256 marketTimebox, uint256 timestamp);

    // in case of governance change
    function modifyToken(address _marketToken) external onlyOwner {
        marketToken = IERC20(_marketToken);
    }
    // in case of governance change
    function modifyUtility(address _marketUtility) external onlyOwner {
        marketUtility = _marketUtility;
    }
    // in case of governance change - market instantly initializes
    function addTimeboxedMarket(uint256 newTimebox, uint256 gracePeriod, uint256 initPrice0, uint256 initPrice1) external onlyOwner {
        marketId++;
        timeboxedMarkets.push(newTimebox);
        marketIndex.push(marketId);
        markets[marketId].index = marketIndex.length - 1;
        markets[marketId].timebox = newTimebox;
        markets[marketId].initializationTimestamp = block.timestamp;
        markets[marketId].option0InitPrice = initPrice0;
        markets[marketId].option1InitPrice = initPrice1;
        timeboxData[newTimebox].status = MarketStatus.Live;
        timeboxData[newTimebox].gracePeriod = gracePeriod;
        activeTimeboxedMarkets[newTimebox] = marketId;
    }
    // one-time call from owner to initialize markets
    function initialize(uint256 initPrice0, uint256 initPrice1) external onlyOwner {
        require(!initialized, "markets already initialized");
        (
            settlementPeriod, 
            predictionQualifier, 
            mrt, 
            WPACKRewardManager, 
            WPACKStakingManager,
            marketLiquidity
        ) = IMarketUtility(marketUtility).getBasicMarketData();
        for (uint256 i; i < timeboxedMarkets.length; i++) {
            uint256 timebox = timeboxedMarkets[i];
            marketId++;
            marketIndex.push(marketId);
            markets[marketId].index = marketIndex.length - 1;
            markets[marketId].initializationTimestamp = block.timestamp;
            markets[marketId].option0InitPrice = initPrice0;
            markets[marketId].option1InitPrice = initPrice1;
            markets[marketId].timebox = timebox;
            timeboxData[timebox].status = MarketStatus.Live;
            activeTimeboxedMarkets[timebox] = marketId;
        }
        timeboxData[1 hours].gracePeriod = 20 minutes;
        timeboxData[4 hours].gracePeriod = 1.5 hours;
        timeboxData[12 hours].gracePeriod = 4 hours;
        timeboxData[1 days].gracePeriod = 8 hours;
        timeboxData[1 weeks].gracePeriod = 2 days;
        initialized = true;
    }

    function predict(uint256 marketUuid, bool option, uint256 timebox, uint256 leverage, uint256 _stake) external {
        require(initialized, "prediction: market not initialized");
        require(verifyMarket(marketUuid), "prediction: market not found");
        require(verifyTimebox(timebox), "prediction: not a timebox");
        require(_stake > 0, "prediction: stake < 0");
        require(leverage <= MAXLEVERAGE && leverage >= 1, "prediction: invalid leverage");
        require(activeTimeboxedMarkets[timebox] == marketUuid, "prediction: marketId not active for given timebox");
        require(timeboxData[timebox].status == MarketStatus.Live, "prediction: market not LIVE");
        require(!markets[marketUuid].settled, "prediction: market settled");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[timebox].gracePeriod, "prediction: grace period exceeded");
        predictionId++;
        if (_stake >= predictionQualifier) {
            notifyWOLFPACKReward(msg.sender, true, false);
        }
        uint256 fee = _stake / 125; // 0.8%
        uint256 stake = _stake - fee;
        uint256 size = stake * leverage;
        uint256 riskOn = size / 5;
        markets[marketUuid].optionSize[option] += size;
        markets[marketUuid].optionRisk[option] += riskOn;
        predictionIndex.push(predictionId);
        predictions[predictionId][msg.sender].index = predictionIndex.length - 1;
        predictions[predictionId][msg.sender].marketUuid = marketUuid;
        predictions[predictionId][msg.sender].option = option;
        predictions[predictionId][msg.sender].timeframe = timebox;
        predictions[predictionId][msg.sender].balance = stake;
        predictions[predictionId][msg.sender].leverage = leverage;
        predictions[predictionId][msg.sender].size = size;
        predictions[predictionId][msg.sender].riskOn = riskOn;
        marketToken.transferFrom(msg.sender, address(this), _stake);
        calcAndDistributePredictionFee(fee);
        emit PredictionPlaced(msg.sender, predictionId, option, timebox, leverage, _stake);
    }

    function increasePredictionValue(uint256 predictionUuid, uint256 amount) external {
        require(verifyPrediction(predictionUuid), "prediction: not found");
        require(amount > 0, "prediction: invalid amount");
        ( uint256 marketUuid, bool opt, uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market not LIVE");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, uint256 lev, uint256 siz, uint256 risked ) = getTradingPredictionData(predictionUuid);
        uint256 newBal = bal + amount;
        uint256 newSiz = newBal * lev;
        uint256 newRisk = newSiz / 5;
        updatePredictionTradingData(predictionUuid, newBal, newSiz, newRisk);
        updateMarketData(marketUuid, opt, newSiz - siz, newRisk - risked, true);
        marketToken.transferFrom(msg.sender, address(this), amount);
        emit PredictionChanged(msg.sender, true, amount);
    }

    function decreasePredictionValue(uint256 predictionUuid, uint256 amount) external nonReentrant {
        require(verifyPrediction(predictionUuid), "prediction: not found");
        require(amount > 0, "prediction: invalid amount");
        ( uint256 marketUuid, bool opt, uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market in settlement");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, uint256 lev, uint256 siz, uint256 risked ) = getTradingPredictionData(predictionUuid);
        uint256 newBal = bal - amount;
        uint256 newSiz = newBal * lev;
        uint256 newRisk = newSiz / 5;
        updatePredictionTradingData(predictionUuid, newBal, newSiz, newRisk);
        updateMarketData(marketUuid, opt, siz - newSiz, risked - newRisk, false);
        marketToken.transfer(msg.sender, amount);
        emit PredictionChanged(msg.sender, false, amount);
    }

    function revertPrediction(uint256 predictionUuid) external nonReentrant {
        require(verifyPrediction(predictionUuid), "prediction return: prediction not found");
        ( uint256 marketUuid, bool opt, uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market in settlement");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, , uint256 siz, uint256 risked ) = getTradingPredictionData(predictionUuid);
        updateMarketData(marketUuid, opt, siz, risked, false);
        delete predictions[predictionUuid][msg.sender];
        marketToken.transfer(msg.sender, bal);
        emit PredictionReverted(msg.sender, bal);
    }

    function predictionReturn(uint256 predictionUuid) external nonReentrant returns (uint256, bool) { 
        require(verifyPrediction(predictionUuid), "prediction return: prediction not found");
        ( uint256 marketUuid, bool option, uint256 period, ) = getMarketPredictionData(predictionUuid);
        require(timeboxData[period].status == MarketStatus.InSettlement, "prediction return: market is live");
        require(!predictions[predictionUuid][msg.sender].settled, "prediction return: already settled");
        ( uint256 bal, , uint256 siz, uint ris ) = getTradingPredictionData(predictionUuid);
        uint256 payout;
        uint256 perc;
        uint256 optSize;
        uint256 ret;
        uint256 roi;
        bool marketResult = markets[marketUuid].winningOption;
        // win
        if (option == marketResult) {
            if (option == true) {
                // TT
                payout = markets[marketUuid].optionRisk[false];
                optSize = markets[marketUuid].optionSize[true];
            }
            else {
                // FF
                payout = markets[marketUuid].optionRisk[true];
                optSize = markets[marketUuid].optionSize[false];
            }
            perc = (siz * 100) / optSize;
            roi = (payout * perc) / 100; 
            ret = bal + ret;
        }
        else {
            // lose
            roi = ris; 
            ret = bal - ris;  
        }
        settlePrediction(predictionUuid);
        marketToken.transfer(msg.sender, ret);
        emit PredictionSettled(msg.sender, marketResult, roi);
        return (roi, marketResult);
    }

    function calcAndDistributePredictionFee(uint256 _fee) private {
        uint256 ownerDividend = _fee / 10;
        uint256 wolfpackStakerDividend = (_fee * 400) / 100;
        uint256 lpDividend = (_fee * 500) / 100;

        IMarketLiquidity(marketLiquidity).notifyReward(lpDividend);
        IWOLFPACKStakingManager(WPACKStakingManager).notifyReward(wolfpackStakerDividend);
        
        marketToken.transfer(marketLiquidity, lpDividend);
        marketToken.transfer(WPACKStakingManager, wolfpackStakerDividend);
        marketToken.transfer(owner(), ownerDividend);
    }

    function settlePrediction(uint256 id) private {
        predictions[id][msg.sender].settled = true;
    }

    function updatePredictionTradingData(uint id, uint bal, uint siz, uint risk) private {
        predictions[id][msg.sender].balance = bal;
        predictions[id][msg.sender].size = siz;
        predictions[id][msg.sender].riskOn = risk;
    }

    function updateMarketData(uint id, bool opt, uint siz, uint risk, bool inc) private {
        if (inc) {
            markets[id].optionSize[opt] += siz;
            markets[id].optionRisk[opt] += risk;
        }
        else {
            markets[id].optionSize[opt] -= siz;
            markets[id].optionRisk[opt] -= risk;
        }  
    }

    function verifyTimebox(uint256 timebox) private view returns(bool) {
        bool v;
        uint256 len = timeboxedMarkets.length;
        for (uint256 i; i < len; i++) {
            uint tbox = timeboxedMarkets[i];
            if (timebox == tbox) {
                v = true;
            }
        }
        return v;
    }
    
    function resetTimebox(uint256 marketUuid, uint256 initPrice0, uint256 initPrice1) external {
        require(block.timestamp > markets[marketUuid].settlementTimestamp + settlementPeriod, "timeboxedMarket: settlement not over");
        uint256 timebox = markets[marketUuid].timebox;
        require(timeboxData[timebox].status == MarketStatus.InSettlement, "timeboxedMarket: invalid market status");
        marketId++;
        marketIndex.push(marketId);
        markets[marketId].index = marketIndex.length - 1;
        markets[marketId].initializationTimestamp = block.timestamp;
        markets[marketId].option0InitPrice = initPrice0;
        markets[marketId].option1InitPrice = initPrice1;
        delete activeTimeboxedMarkets[timebox];
        activeTimeboxedMarkets[timebox] = marketId;
        timeboxData[timebox].status = MarketStatus.Live;
        notifyWOLFPACKReward(msg.sender, false, true);
        emit TimeboxReset(msg.sender, marketId, timebox, block.timestamp);
    }

    function settleMarket(uint256 marketUuid, uint256 currentPrice0, uint256 currentPrice1) external {
        uint256 timebox = markets[marketUuid].timebox;
        require(block.timestamp > markets[marketUuid].initializationTimestamp + timebox, "timeboxedMarket: timebox not completed");
        require(timeboxData[timebox].status == MarketStatus.Live, "timeboxedMarket: invalid market status");
        uint256 pool;
        uint256 payoutThreshold;
        uint256 diff;
        uint256 toPay;
        timeboxData[timebox].status = MarketStatus.InSettlement;
        markets[marketUuid].settlementTimestamp = block.timestamp;
        markets[marketUuid].option0SettlementPrice = currentPrice0;
        markets[marketUuid].option1SettlementPrice = currentPrice1;   
        bool winner = IMarketUtility(marketUtility).calulateMarketWinnerParameterized
        (
            markets[marketUuid].option0InitPrice, 
            markets[marketUuid].option1InitPrice, 
            currentPrice0, 
            currentPrice1
        );
        markets[marketUuid].winningOption = winner;     
        if (winner) {
            pool = markets[marketUuid].optionRisk[false];
            payoutThreshold = markets[marketUuid].optionRisk[true] / mrt;
        }
        else {
            pool = markets[marketUuid].optionRisk[true];
            payoutThreshold = markets[marketUuid].optionRisk[false] / mrt;
        }
        if (pool < payoutThreshold) {
            diff = payoutThreshold - pool; 
            toPay = IMarketLiquidity(marketLiquidity).requestMarketPayout(diff);
            markets[marketUuid].payoutPool = toPay; 
        }
        else {
            markets[marketUuid].payoutPool = pool;
        }
        notifyWOLFPACKReward(msg.sender, false, true);
        emit MarketSettled(msg.sender, timebox, block.timestamp);
    }

    function estimateWin(uint256 predictionUuid) external view returns (uint256, uint256) {
        uint256 optRisk;
        ( , , uint256 siz , ) = getTradingPredictionData(predictionUuid);
        ( uint256 marketUuid, bool opt, , ) = getMarketPredictionData(predictionUuid);
        uint256 optSize = markets[marketUuid].optionSize[opt];

        if (opt == true) {
            optRisk = markets[marketUuid].optionRisk[false];
        }
        else {
            optRisk = markets[marketUuid].optionRisk[true];
        }

        uint256 perc = (siz * 100) / optSize;
        uint256 estimate = (perc * optRisk) / 100;
        return (perc, estimate);
    }

    function verifyPrediction(uint256 id) public view returns (bool) {
        if (predictionIndex.length == 0) return false;
        return (predictionIndex[predictions[id][msg.sender].index] == id);
    }

    function verifyMarket(uint256 id) public view returns (bool) {
        if (marketIndex.length == 0) return false;
        return (marketIndex[markets[id].index] == id);
    }

    function getTradingPredictionData(uint256 predictionUuid) public view returns (uint, uint, uint, uint) {
        return (
            predictions[predictionUuid][msg.sender].balance, 
            predictions[predictionUuid][msg.sender].leverage, 
            predictions[predictionUuid][msg.sender].size, 
            predictions[predictionUuid][msg.sender].riskOn
        );
    }

    function getMarketPredictionData(uint256 predictionUuid) public view returns (uint, bool, uint, bool) {
        return (
            predictions[predictionUuid][msg.sender].marketUuid,
            predictions[predictionUuid][msg.sender].option,
            predictions[predictionUuid][msg.sender].timeframe,
            predictions[predictionUuid][msg.sender].settled
        );
    }

    function getMarketGeneralData(uint256 id) external view returns (uint, uint, uint, bool, MarketStatus) {
        uint256 tf = markets[id].timebox;
        return (
            markets[id].initializationTimestamp,
            markets[id].settlementTimestamp,
            markets[id].payoutPool,
            markets[id].winningOption,
            timeboxData[tf].status
        );
    }

    function getMarketSentimentData(uint256 id) external view returns (uint, uint, uint, uint) {
        uint s0 = markets[id].optionSize[true];
        uint s1 = markets[id].optionSize[false];
        uint r0 = markets[id].optionRisk[true];
        uint r1 = markets[id].optionRisk[false];
        return (s0, s1, r0, r1);
    }

    function getMarketPriceData(uint256 id) external view returns (uint, uint, uint, uint) {
        return (
            markets[id].option0InitPrice,
            markets[id].option1InitPrice,
            markets[id].option0SettlementPrice,
            markets[id].option1SettlementPrice
        );
    }

    function notifyWOLFPACKReward(address rewardee, bool rewardForPrediction, bool rewardForManagement) private {
        if (rewardForPrediction == true) {
            IWOLFPACKRewardManager(WPACKRewardManager).notifyReward(rewardee, true, false, false);
        }
        else if (rewardForManagement == true) {
            IWOLFPACKRewardManager(WPACKRewardManager).notifyReward(rewardee, false, false, true);
        }
        else {
            revert('WOLFPACK rewards: not eligible');
        }
    }

}