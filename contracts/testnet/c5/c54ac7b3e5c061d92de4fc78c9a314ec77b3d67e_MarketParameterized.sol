/**
 *Submitted for verification at BscScan.com on 2022-09-26
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
    function synchronizeRewardNotification(address rewardee, bool predictionQualified, bool liquidityQualified, bool managementQualified) external;
}

interface IWOLFPACKStakingManager {
    function synchronizeRewardNotification(uint256 received) external;
}

interface IMarketUtility {
    function getBasicMarketData() external view returns (uint256, uint256, uint256, uint256, address, address);
    function getChainLinkLatestPricesUSD(address _feedAddress0, address _feedAddress1) external view returns (uint256, uint256);
    function calculateMarketWinnerOraclized (uint256 option0InitPrice, address option0Feed, uint256 option1InitPrice, address option1Feed) external view returns (bool, uint256, uint256);
    function calulateMarketWinnerParameterized(uint256 option0InitPrice, uint256 option1InitPrice, uint256 option0SettlementPrice, uint256 option1SettlementPrice) external view returns (bool);
}

/// @title MarketParameterized
/// @author LONEWOLF
///
/// Prediction market contract that works with parameterized assets that have no oraclized price feeds available. 

contract MarketParameterized is Ownable, ReentrancyGuard {

    enum MarketStatus {
      Live,
      InSettlement
    }

    struct PredictionData {
        uint256 marketUuid;
        bool option;
        uint256 timeframe;
        uint256 balance;
        uint256 leverage;
        uint256 size;
        uint256 riskOn;
        bool settled;
        uint256 index;
    }

    struct MarketData {
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
        uint256 index;
    }

    struct Timebox {
        MarketStatus status;
        uint256 gracePeriod;
    }

    mapping(uint256 => mapping(address => PredictionData)) private predictions; 
           //marketID
    mapping(uint256 => MarketData) private markets;
           //timeframe/period
    mapping(uint256 => Timebox) private timeboxData;

    uint256[] private predictionIndex;
    uint256[] private marketIndex;

    uint256 constant MAXLEVERAGE = 5;
    uint256 private marketId;
    uint256 private predictionId;
    uint256 public liquidity;
    uint256 public settlementPeriod;
    uint256 public predictionQualifier;
    uint256 public liquidityQualifier;
    uint256 public mrt;
    uint256[] public timeboxedMarkets = [1 hours, 4 hours, 12 hours, 1 days, 1 weeks];

    address public marketCurrency = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; 
    address public marketUtility = 0x6F5fD34AbB29C7e590572E262cCa2E80E595b9B9; 
    address public WPACKRewardManagerAddr;
    address public WPACKStakingManagerAddr;
    address[] private wPredictors;
    address[] private liquidityProviders;

    bool private initialized;

    mapping(address => uint256) private lpBalances;
   
    IERC20 marketToken = IERC20(marketCurrency);

    event PredictionPlaced(address indexed predictor, bool option, uint256 timeframe, uint256 leverage, uint256 stake);
    event PredictionChanged(address indexed predictor, bool increase, uint256 change);
    event PredictionWithdrawn(address indexed predictor, uint256 withdrawalAmount);
    event PredictionSettled(address indexed predictor, bool win, uint256 roi);
    event PredictionReverted(address indexed predictor, uint256 balanceReverted);
    event LiquidityAdded(address indexed liquidityProvider, uint256 amount);
    event LiquidityWithdrawn(address indexed liquidityProvider, uint256 withdrawalAmount);
    event MarketRestarted(address indexed caller, uint256 marketTimebox, uint256 timestamp);
    event MarketSettled(address indexed caller, uint256 marketTimebox, uint256 timestamp);

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
    }

    // one-time call from owner to initialize markets
    function initialize(uint256 initPrice0, uint256 initPrice1) external onlyOwner {
        (
            settlementPeriod, 
            predictionQualifier, 
            liquidityQualifier, 
            mrt, 
            WPACKRewardManagerAddr, 
            WPACKStakingManagerAddr
        ) = IMarketUtility(marketUtility).getBasicMarketData();

        for (uint256 i; i < timeboxedMarkets.length; i++) {
            marketId++;
            marketIndex.push(marketId);
            markets[marketId].index = marketIndex.length - 1;
            markets[marketId].initializationTimestamp = block.timestamp;
            markets[marketId].option0InitPrice = initPrice0;
            markets[marketId].option1InitPrice = initPrice1;
            uint256 timebox = timeboxedMarkets[i];
            timeboxData[timebox].status = MarketStatus.Live;
        }

        timeboxData[1 hours].gracePeriod = 20 minutes;
        timeboxData[4 hours].gracePeriod = 1.5 hours;
        timeboxData[12 hours].gracePeriod = 4 hours;
        timeboxData[1 days].gracePeriod = 8 hours;
        timeboxData[1 weeks].gracePeriod = 2 days;

        initialized = true;
    }

    function synchroniseGovernanceUpgrades() external onlyOwner {
        (settlementPeriod, predictionQualifier, liquidityQualifier, mrt, WPACKRewardManagerAddr, WPACKStakingManagerAddr) = IMarketUtility(marketUtility).getBasicMarketData();
    }

    function predict(uint256 marketUuid, bool option, uint256 timebox, uint256 leverage, uint256 _stake) external returns (uint256) {
        require(initialized, "prediction: market not initialized");
        require(liquidity > 0, "prediction: zero liquidity");
        require(marketIndex[markets[marketUuid].index] == marketUuid, "market not found");
        bool verified = verifyTimebox(timebox);
        require(verified, "prediction: not a timebox");
        require(_stake > 0, "prediction: invalid amount");
        require(leverage <= MAXLEVERAGE && leverage >= 1, "prediction: invalid leverage");
        require(timeboxData[timebox].status == MarketStatus.Live, "prediction: market not live");
        require(markets[marketUuid].settled == false, "prediction: market settled");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[timebox].gracePeriod, "prediction: grace period exceeded");
        predictionId++;
        if (_stake > predictionQualifier) {
            notifyWOLFPACKRewardManager(msg.sender, true, false, false);
        }
        uint256 fee = _stake / 100;
        uint256 stake = _stake - fee;
        uint256 size = stake * leverage;
        uint256 riskOn = size / 5;
        // store market stats
        markets[marketUuid].optionSize[option] += size;
        markets[marketUuid].optionRisk[option] += riskOn;
        //store prediction data
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
        emit PredictionPlaced(msg.sender, option, timebox, leverage, _stake);
        // for client to store
        return predictionId;
    }

    function increasePredictionValue(uint256 predictionUuid, uint256 amount) external {
        require(predictionIndex[predictions[predictionUuid][msg.sender].index] == predictionUuid, "prediction not found");
        require(amount > 0, "prediction: invalid amount");
        ( uint256 marketUuid, bool opt, uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market in settlement");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, uint256 lev, uint256 siz, uint256 risked ) = getTradingPredictionData(predictionUuid);
        uint256 newBal = bal + amount;
        uint256 newSiz = newBal * lev;
        uint256 newRisk = newSiz / 5;

        // integrity
        updatePredictionTradingData(predictionUuid, newBal, newSiz, newRisk);
        updateMarketData(marketUuid, opt, newSiz - siz, newRisk - risked, true);

        marketToken.transferFrom(msg.sender, address(this), amount);
        emit PredictionChanged(msg.sender, true, amount);
    }

    // user wants to withdraw from their prediction balance (for this particular prediction)
    function decreasePredictionValue(uint256 predictionUuid, uint256 amount) external {
        require(predictionIndex[predictions[predictionUuid][msg.sender].index] == predictionUuid, "prediction not found");
        require(amount > 0, "prediction: invalid amount");
        ( uint256 marketUuid, bool opt, uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market in settlement");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, uint256 lev, uint256 siz, uint256 risked ) = getTradingPredictionData(predictionUuid);

        uint256 newBal = bal - amount;
        uint256 newSiz = newBal * lev;
        uint256 newRisk = newSiz / 5;

        uint256 sizeDec = siz - newSiz;
        uint256 riskDec = risked - newRisk;

        // integrity
        updatePredictionTradingData(predictionUuid, newBal, newSiz, newRisk);
        updateMarketData(marketUuid, opt, sizeDec, riskDec, false);

        marketToken.transfer(msg.sender, amount);
        emit PredictionChanged(msg.sender, false, amount);
    }

    function predictionReturn(uint256 predictionUuid) external nonReentrant returns (uint256, bool) { 
        require(predictionIndex[predictions[predictionUuid][msg.sender].index] == predictionUuid, "prediction not found");
        ( uint256 marketUuid, bool option, uint256 period, ) = getMarketPredictionData(predictionUuid);
        require(timeboxData[period].status == MarketStatus.InSettlement, "prediction return: market is live");
        require(predictions[predictionUuid][msg.sender].settled == false, "prediction return: already settled");
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
            roi = (payout * perc) / 100; //+
            ret = bal + ret;
        }
        else {
            // lose
            roi = ris; //-
            ret = bal - ris;  
        }
        settlePrediction(predictionUuid);
        marketToken.transfer(msg.sender, ret);
        emit PredictionSettled(msg.sender, marketResult, roi);
        return (roi, marketResult);
        // @NOTE - STORE AS A PREVIOUS RESULT IN POSITIONS -> return and store roi (difference between original bal and new bal) in client
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

    function revertPrediction(uint256 predictionUuid) external {
        ( uint256 marketUuid, , uint256 period, ) = getMarketPredictionData(predictionUuid);   
        require(timeboxData[period].status == MarketStatus.Live, "prediction: market in settlement");
        require(block.timestamp < markets[marketUuid].initializationTimestamp + timeboxData[period].gracePeriod, "prediction: grace period exceeded");
        ( uint256 bal, , , ) = getTradingPredictionData(predictionUuid);
        delete predictions[predictionUuid][msg.sender];
        marketToken.transfer(msg.sender, bal);
        emit PredictionReverted(msg.sender, bal);
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

    function calcAndDistributePredictionFee(uint256 _fee) private {
        uint256 len = liquidityProviders.length;
        // 0.1, 0.55, 0.35
        uint256 ownerDividend = _fee / 10;
        uint256 wolfpackStakersDividend = (_fee * 550) / 100;
        uint256 lpDividend = (_fee * 350) / 100;

        for (uint256 i; i < len; i++) {
            address lp = liquidityProviders[i];
            uint256 perc = (lpBalances[lp] * 100) / liquidity;
            uint256 allocation = (perc * lpDividend) / 100;
            lpBalances[lp] += allocation;
        }

        marketToken.transfer(owner(), ownerDividend);
        notifyWOLFPACKStakingManager(wolfpackStakersDividend);
    }
    
    function addLiquidity(uint256 amount) external {
        require(amount > 0, "liquidity: amount < 0");
        if (amount > liquidityQualifier) {
            notifyWOLFPACKRewardManager(msg.sender, false, true, false);
        }
        lpBalances[msg.sender] += amount;
        liquidityProviders.push(msg.sender);
        liquidity += amount;
        marketToken.transferFrom(msg.sender, address(this), amount);

        emit LiquidityAdded(msg.sender, amount);
    }

    function getLiquidityBalance(address account) external view returns (uint256) {
        return lpBalances[account];
    }

    function withdrawLiquidity(uint256 amount) external nonReentrant {
        uint256 lpBalance = lpBalances[msg.sender];
        require(amount > 0 && amount <= lpBalance, "liquidity: insufficient balance");
        // require that all timeboxedMarkets are NOT inSettlement
        for (uint256 i; i < timeboxedMarkets.length; i++) {
            uint256 timebox = timeboxedMarkets[i];
            if (timeboxData[timebox].status == MarketStatus.InSettlement) {
                revert("liquidity: markets in settlement");
            }
        }
        uint256 fee = amount / 100; // 1%
        calcAndDistributeLiquidityWithdrawalFee(fee);
        uint256 withdrawal = amount - fee;
        if (amount == lpBalance) {
            removeLp(msg.sender);
        }
        liquidity -= amount;
        lpBalances[msg.sender] -= amount;
        marketToken.transfer(msg.sender, withdrawal);

        emit LiquidityWithdrawn(msg.sender, amount);
    }

    function removeLp(address lp) private {
        uint256 len = liquidityProviders.length;
        for (uint256 i; i < len - 1; i++) {
            while (liquidityProviders[i] == lp) {
                // shift index to last, remove. 
                liquidityProviders[i] = liquidityProviders[i+1];   
            }
        }
        liquidityProviders.pop();
    }

    function calcAndDistributeLiquidityWithdrawalFee(uint256 fee) private {
        uint256 dividend = fee / 2;
        marketToken.transfer(owner(), dividend);
        marketToken.transfer(WPACKStakingManagerAddr, dividend);
    }

    function resetTimebox(uint256 marketUuid, uint256 initPrice0, uint256 initPrice1) external returns (uint256) {
        uint256 tf = markets[marketUuid].timebox;
        require(timeboxData[tf].status == MarketStatus.InSettlement, "timeboxedMarket: invalid market status");
        require(block.timestamp > markets[marketUuid].settlementTimestamp + settlementPeriod, "timeboxedMarket: settlement not over");

        marketId++;
        marketIndex.push(marketId);
        markets[marketId].index = marketIndex.length - 1;
        markets[marketId].initializationTimestamp = block.timestamp;
        markets[marketId].option0InitPrice = initPrice0;
        markets[marketId].option1InitPrice = initPrice1;
        timeboxData[tf].status = MarketStatus.Live;

        notifyWOLFPACKRewardManager(msg.sender, false, false, true);

        emit MarketRestarted(msg.sender, tf, block.timestamp);
        return marketId;
    }

    function settleMarket(uint256 marketUuid, uint256 settlePrice0, uint256 settlePrice1) external {
        uint256 tf = markets[marketUuid].timebox;
        require(timeboxData[tf].status == MarketStatus.Live, "timeboxedMarket: invalid market status");
        require(block.timestamp >  markets[marketUuid].initializationTimestamp + tf, "timeboxedMarket: timebox not completed");

        bool winner = executeSettlement(marketUuid, settlePrice0, settlePrice1);

        timeboxData[tf].status = MarketStatus.InSettlement;
        markets[marketUuid].settled = true;
        markets[marketUuid].settlementTimestamp = block.timestamp;
        markets[marketUuid].option0SettlementPrice = settlePrice0;
        markets[marketUuid].option1SettlementPrice = settlePrice1;
        markets[marketUuid].winningOption = winner;

        notifyWOLFPACKRewardManager(msg.sender, false, false, true);

        emit MarketSettled(msg.sender, tf, block.timestamp);
    }

    function executeSettlement(uint256 marketUuid, uint256 currentPrice0, uint256 currentPrice1) private returns (bool) {
        uint256 pool;
        uint256 payoutThreshold;
        uint256 diff;
        uint256 toPay;
        // get/set result   
        bool winner = IMarketUtility(marketUtility).calulateMarketWinnerParameterized(markets[marketUuid].option0InitPrice, markets[marketUuid].option1InitPrice, currentPrice0, currentPrice1);
        markets[marketUuid].winningOption = winner;
        // update data
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
            liquidity -= diff;
            toPay = pool + diff;
            markets[marketUuid].payoutPool = toPay; 
        }
        else {
            markets[marketUuid].payoutPool = pool;
        }
        return winner;
    }

    function estimateWin(uint256 predictionUuid) external view returns (uint256, uint256) {
        uint256 optRisk;
        // get the prediction via ID, get predictor's option size %, get payoutPool (total risk on opposite side), apply % to payoutPool & return
        ( , , uint256 siz , ) = getTradingPredictionData(predictionUuid);
        ( uint256 marketUuid, bool opt, , ) = getMarketPredictionData(predictionUuid);

        uint256 optSize = markets[marketUuid].optionSize[opt];

        // payout is totalRisk on opposite option to predictors selection
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

    // 'stack too deep'
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

    function notifyWOLFPACKRewardManager(address rewardee, bool rewardForPrediction, bool rewardForLP, bool rewardForManagement) private {
        if (rewardForPrediction == true) {
            IWOLFPACKRewardManager(WPACKRewardManagerAddr).synchronizeRewardNotification(rewardee, true, false, false);
        }
        else if (rewardForLP == true) {
            IWOLFPACKRewardManager(WPACKRewardManagerAddr).synchronizeRewardNotification(rewardee, false, true, false);
        }
        else if (rewardForManagement == true) {
            IWOLFPACKRewardManager(WPACKRewardManagerAddr).synchronizeRewardNotification(rewardee, false, false, true);
        }
        else {
            revert('WOLFPACK rewards: not eligible');
        }
    }

    function notifyWOLFPACKStakingManager(uint256 distribution) private {
        IWOLFPACKStakingManager(WPACKStakingManagerAddr).synchronizeRewardNotification(distribution);
        marketToken.transfer(WPACKStakingManagerAddr, distribution);
    }

}