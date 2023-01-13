/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
    function getBasicMarketData() external view returns (uint256, uint256, uint256, address payable, address payable, address payable); 
    function getChainLinkLatestPricesUSD(address _feedAddress0, address _feedAddress1) external view returns (uint256, uint256);
    function calculateMarketWinnerOraclized (uint256 option0InitPrice, address option0Feed, uint256 option1InitPrice, address option1Feed) external view returns (bool, uint256, uint256);
}

interface IMarketLiquidity {
    function notifyReward(uint256 amount) external;
    function requestMarketPayout(uint256 payout) external returns (uint256);
    function getMarketPayout(uint256 amount) external;
}

/// @title MarketOraclized
/// @author 'LONEWOLF'
///
/// Prediction Market Contract that works with oraclized assets that have chainlink price feeds available. 
/// ETH, or network native coin used as market currency. 

contract MarketOraclized is Ownable, ReentrancyGuard {

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
    mapping(uint256 => uint256) public activeTimeboxedMarkets;
    uint256 constant MAXLEVERAGE = 5;
    uint256 private marketId;
    uint256 private predictionId;
    uint256 public settlementPeriod;
    uint256 public predictionQualifier;
    uint256 public mrt;
    uint256[] public timeboxedMarkets = [1 hours, 4 hours, 12 hours, 1 days, 1 weeks];
    uint256[] private predictionIndex;
    uint256[] private marketIndex;
    /// price feeds
    uint256 public latestPriceUsd0;
    uint256 public latestPriceUsd1;

    address public marketUtility = 0x6aDc5d007708e4d4c5E8252e4aaC752Fa9e3DEAc; 
    address payable public marketLiquidity;
    address public WPACKRewardManager;
    address payable public WPACKStakingManager;
    address option0PriceFeed;
    address option1PriceFeed;

    bool private initialized;

    string public marketName;
    
    event PredictionPlaced(address indexed predictor, uint256 predictionId, bool option, uint256 timeframe, uint256 leverage, uint256 stake);
    event PredictionChanged(address indexed predictor, bool increase, uint256 change);
    event PredictionReverted(address indexed predictor, uint256 balanceReverted);
    event PredictionSettled(address indexed predictor, bool win, uint256 roi);
    event TimeboxReset(address caller, uint256 marketTimebox, uint256 timestamp);
    event MarketSettled(address caller, uint256 marketTimebox, uint256 timestamp);

    constructor(address _option0PriceFeed, address _option1PriceFeed, string memory _marketName) {
        option0PriceFeed = _option0PriceFeed;
        option1PriceFeed = _option1PriceFeed;
        marketName = _marketName;
    }

    // in case of governance change
    function modifyUtility(address _marketUtility) external onlyOwner {
        marketUtility = _marketUtility;
    }

    // in case of governance change - getBasicMarketData() needs recall
    // dependency contracts changed in MarketUtility.sol
    function basicMarketDataUpdated() external onlyOwner {
        (
            settlementPeriod, 
            predictionQualifier, 
            mrt, 
            WPACKRewardManager, 
            WPACKStakingManager,
            marketLiquidity
        ) = IMarketUtility(marketUtility).getBasicMarketData();
    }

    // in case of governance change - market instantly initializes
    function addTimeboxedMarket(uint256 newTimebox, uint256 gracePeriod) external onlyOwner {
        (uint256 initPrice0, uint256 initPrice1) = IMarketUtility(marketUtility).getChainLinkLatestPricesUSD(option0PriceFeed, option1PriceFeed);
        marketId++;
        timeboxedMarkets.push(newTimebox);
        marketIndex.push(marketId);
        markets[marketId].index = marketIndex.length - 1;
        markets[marketId].timebox = newTimebox;
        markets[marketId].initializationTimestamp = block.timestamp;
        markets[marketId].option0InitPrice = initPrice0;
        latestPriceUsd0 = initPrice0;
        markets[marketId].option1InitPrice = initPrice1;
        latestPriceUsd1 = initPrice1;
        timeboxData[newTimebox].status = MarketStatus.Live;
        timeboxData[newTimebox].gracePeriod = gracePeriod;
        activeTimeboxedMarkets[newTimebox] = marketId;
    }

    // one-time call from owner to initialize markets
    function initialize() external onlyOwner {
        require(!initialized, "markets already initialized");
        (
            settlementPeriod, 
            predictionQualifier, 
            mrt, 
            WPACKRewardManager, 
            WPACKStakingManager,
            marketLiquidity
        ) = IMarketUtility(marketUtility).getBasicMarketData();
        (uint256 initPrice0, uint256 initPrice1) = IMarketUtility(marketUtility).getChainLinkLatestPricesUSD(option0PriceFeed, option1PriceFeed);
        for (uint256 i; i < timeboxedMarkets.length; i++) {
            uint256 timebox = timeboxedMarkets[i];
            marketId++;
            marketIndex.push(marketId);
            markets[marketId].index = marketIndex.length - 1;
            markets[marketId].initializationTimestamp = block.timestamp;
            markets[marketId].option0InitPrice = initPrice0;
            markets[marketId].option1InitPrice = initPrice1;
            timeboxData[timebox].status = MarketStatus.Live;
            activeTimeboxedMarkets[timebox] = marketId;
            latestPriceUsd0 = initPrice0;
            latestPriceUsd1 = initPrice1;
        }
        timeboxData[1 hours].gracePeriod = 20 minutes;
        timeboxData[4 hours].gracePeriod = 1.5 hours;
        timeboxData[12 hours].gracePeriod = 4 hours;
        timeboxData[1 days].gracePeriod = 8 hours;
        timeboxData[1 weeks].gracePeriod = 2 days;
        initialized = true;
    }

    function predict(uint256 marketUuid, bool option, uint256 timebox, uint256 leverage, uint256 _stake) external payable {
        require(initialized, "prediction: market not initialized");
        require(verifyMarket(marketUuid), "prediction: market not found");
        require(verifyTimebox(timebox), "prediction: not a timebox");
        require(_stake > 0 && _stake == msg.value, "prediction: invalid stake");
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
        calcAndDistributePredictionFee(fee);
        emit PredictionPlaced(msg.sender, predictionId, option, timebox, leverage, _stake);
    }

    function increasePredictionValue(uint256 predictionUuid, uint256 amount) external payable {
        require(verifyPrediction(predictionUuid), "prediction: not found");
        require(amount > 0 && amount == msg.value, "prediction: invalid amount");
        ( uint256 marketUuid, bool opt, uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market not LIVE");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, uint256 lev, uint256 siz, uint256 risked ) = getTradingPredictionData(predictionUuid);
        uint256 newBal = bal + amount;
        uint256 newSiz = newBal * lev;
        uint256 newRisk = newSiz / 5;
        updatePredictionTradingData(predictionUuid, newBal, newSiz, newRisk);
        updateMarketData(marketUuid, opt, newSiz - siz, newRisk - risked, true);
        emit PredictionChanged(msg.sender, true, amount);
    }

    function decreasePredictionValue(uint256 predictionUuid, uint256 amount) external nonReentrant {
        require(verifyPrediction(predictionUuid), "prediction: not found");
        require(amount > 0 && amount < address(this).balance, "prediction: invalid amount");
        ( uint256 marketUuid, bool opt, uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market in settlement");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, uint256 lev, uint256 siz, uint256 risked ) = getTradingPredictionData(predictionUuid);
        require(amount <= bal, "prediction: invalid amount");
        uint256 newBal = bal - amount;
        uint256 newSiz = newBal * lev;
        uint256 newRisk = newSiz / 5;
        updatePredictionTradingData(predictionUuid, newBal, newSiz, newRisk);
        updateMarketData(marketUuid, opt, siz - newSiz, risked - newRisk, false);
        address payable recipient = payable(msg.sender);
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "transfer failed");
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
        address payable recipient = payable(msg.sender);
        (bool success, ) = recipient.call{value: bal}("");
        require(success, "transfer failed");
        emit PredictionReverted(msg.sender, bal);
    }

    function predictionReturn(uint256 predictionUuid) public view returns(uint256 retrn, bool win) { 
        ( uint256 marketUuid, bool option, , ) = getMarketPredictionData(predictionUuid);
        ( uint256 bal, , uint256 siz, uint ris ) = getTradingPredictionData(predictionUuid);
        uint256 payout = markets[marketUuid].payoutPool;
        uint256 optSize;
        uint256 ret;
        bool isWin;
        bool marketResult = markets[marketUuid].winningOption;
        // win
        if (option == marketResult) {
            isWin = true;
            if (option == true) {
                // TT
                optSize = markets[marketUuid].optionSize[true];
            }
            else {
                // FF
                optSize = markets[marketUuid].optionSize[false];
            }
            uint256 perc = (siz * 100) / optSize;
            uint256 roi = (payout * perc) / 100; 
            ret = bal + roi;
        } 
        // lose
        else {
            ret = bal - ris;  
            isWin = false;
        }
        return (ret, isWin);
    }

    function settlePrediction(uint256 predictionUuid) external nonReentrant {
        require(verifyPrediction(predictionUuid), "prediction return: prediction not found");
        ( , , uint256 period, ) = getMarketPredictionData(predictionUuid);
        require(timeboxData[period].status == MarketStatus.InSettlement, "prediction return: market is live");
        require(!predictions[predictionUuid][msg.sender].settled, "prediction return: already settled");
        predictions[predictionUuid][msg.sender].settled = true;
        (uint256 predictionRtrn, bool isWin) = predictionReturn(predictionUuid);
        // losers on 5x leverage do not get a return
        if (predictionRtrn > 0) { 
            address payable recipient = payable(msg.sender);
            (bool success, ) = recipient.call{value: predictionRtrn}("");
            require(success, "failed to send ether");
        }
        emit PredictionSettled(msg.sender, isWin, predictionRtrn);
    }

    function calcAndDistributePredictionFee(uint256 _fee) private {
        uint256 ownerDividend = _fee / 10; // 10%
        uint256 wolfpackStakerDividend = (_fee * 40) / 100; // 40%
        uint256 lpDividend = _fee / 2; // 50%

        IMarketLiquidity(marketLiquidity).notifyReward(lpDividend);
        IWOLFPACKStakingManager(WPACKStakingManager).notifyReward(wolfpackStakerDividend);

        marketLiquidity.transfer(lpDividend);
        WPACKStakingManager.transfer(wolfpackStakerDividend);
        address payable o = payable(owner());
        o.transfer(ownerDividend);        
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

    function resetTimebox(uint256 marketUuid) external {
        require(block.timestamp > markets[marketUuid].settlementTimestamp + settlementPeriod, "timeboxedMarket: settlement not over");
        uint256 timebox = markets[marketUuid].timebox;
        require(timeboxData[timebox].status == MarketStatus.InSettlement, "timeboxedMarket: invalid market status");
        (uint256 initPrice0, uint256 initPrice1) = IMarketUtility(marketUtility).getChainLinkLatestPricesUSD(option0PriceFeed, option1PriceFeed);
        latestPriceUsd0 = initPrice0;
        latestPriceUsd1 = initPrice1;
        marketId++;
        marketIndex.push(marketId);
        markets[marketId].index = marketIndex.length - 1;
        markets[marketId].initializationTimestamp = block.timestamp;
        markets[marketId].option0InitPrice = initPrice0;
        markets[marketId].option1InitPrice = initPrice1;
        activeTimeboxedMarkets[timebox] = marketId;
        timeboxData[timebox].status = MarketStatus.Live;
        notifyWOLFPACKReward(msg.sender, false, true);
        emit TimeboxReset(msg.sender, timebox, block.timestamp);
    }


    function settleMarket(uint256 marketUuid) external {
        uint256 timebox = markets[marketUuid].timebox;
        require(timeboxData[timebox].status == MarketStatus.Live, "timeboxedMarket: invalid market status");
        require(block.timestamp >  markets[marketUuid].initializationTimestamp + timebox, "timeboxedMarket: timebox not completed");
        uint256 pool;
        uint256 payoutThreshold;
        uint256 diff;
        uint256 liquidityReserve;
        timeboxData[timebox].status = MarketStatus.InSettlement;
        markets[marketUuid].settlementTimestamp = block.timestamp;
        (bool winner, uint256 currentPrice0, uint256 currentPrice1) = IMarketUtility(marketUtility).calculateMarketWinnerOraclized
        (
            markets[marketUuid].option0InitPrice, 
            option0PriceFeed,
            markets[marketUuid].option1InitPrice, 
            option1PriceFeed
        );
        markets[marketUuid].winningOption = winner;  
        markets[marketUuid].option0SettlementPrice = currentPrice0;   
        markets[marketUuid].option1SettlementPrice = currentPrice1;   
        latestPriceUsd0 = currentPrice0;
        latestPriceUsd1 = currentPrice1;
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
            liquidityReserve = IMarketLiquidity(marketLiquidity).requestMarketPayout(diff);
            IMarketLiquidity(marketLiquidity).getMarketPayout(liquidityReserve);
            markets[marketUuid].payoutPool = liquidityReserve + pool; 
        }
        else {
            markets[marketUuid].payoutPool = pool;
        }
        markets[marketUuid].settled = true;
        notifyWOLFPACKReward(msg.sender, false, true);
        emit MarketSettled(msg.sender, timebox, block.timestamp);
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

    function isMarketSettled(uint256 id) external view returns (bool) {
        return markets[id].settled;
    }

    function getLatestPriceUsd(address feed0, address feed1) external view returns (uint256, uint256) {
        (uint256 price0, uint256 price1) = IMarketUtility(marketUtility).getChainLinkLatestPricesUSD(feed0, feed1);
        return (price0, price1);
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

    receive() external payable {}

}