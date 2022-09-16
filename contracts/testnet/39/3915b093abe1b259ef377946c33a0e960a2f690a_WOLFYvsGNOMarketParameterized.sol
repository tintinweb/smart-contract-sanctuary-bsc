/**
 *Submitted for verification at BscScan.com on 2022-09-15
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

contract WOLFYvsGNOMarketParameterized is Ownable, ReentrancyGuard {

    enum MarketStatus {
      Live,
      InSettlement
    }

    struct UserPredictionData {
        address predictor;
        uint256 id;
        bool option;
        uint256 timeframe;
        uint256 stake;
        uint256 leverage;
        uint256 size;
    }

    UserPredictionData[] private predictions;

    uint256 constant MAXLEVERAGE = 5;
    uint256 private initializationTime;
    uint256 private predictionId;
    uint256 public totalPredicted;
    uint256 public liquidity;
    uint256 private payoutPool;
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

    bool private initialized = false;

    mapping(uint256 => MarketStatus) private timeboxedMarketStatus;
    mapping(uint256 => uint256) private timeboxedMarketGracePeriods;
    mapping(uint256 => uint256) private timeboxedMarketInitializationTimestamps;
    mapping(uint256 => uint256) private timeboxedMarketSettlementTimestamps;
    mapping(address => mapping(uint256 => mapping(bool => uint256))) private riskOnOption;
    mapping(uint256 => mapping(bool => uint256)) private totalRisk;
    mapping(address => mapping(uint256 => mapping(bool => uint256))) private predictionBalance;
    mapping(uint256 => uint256) public option0InitializationPrice;
    mapping(uint256 => uint256) public option1InitializationPrice;
    mapping(uint256 => uint256) public option0SettlementPrice;
    mapping(uint256 => uint256) public option1SettlementPrice;
    mapping(address => uint256) private lpBalances;
    mapping(uint256 => mapping(bool => uint256)) private optionSize;
    mapping(uint256 => bool) private timeboxedMarketWinner;
   
    IERC20 marketToken = IERC20(marketCurrency);

    event PredictionPlaced(address indexed predictor, bool option, uint256 timeframe, uint256 leverage, uint256 stake);
    event PredictionWithdrawn(address indexed predictor, uint256 withdrawalAmount);
    event LiquidityAdded(address indexed liquidityProvider, uint256 amount);
    event LiquidityWithdrawn(address indexed liquidityProvider, uint256 withdrawalAmount);
    event MarketRestarted(address indexed caller, uint256 marketTimebox, uint256 timestamp);
    event MarketSettled(address indexed caller, uint256 marketTimebox, uint256 timestamp);

    // in case of governance change - market instantly initializes
    function addTimeboxedMarket(uint256 newTimeboxedMarket, uint256 gracePeriod, uint256 initPrice0, uint256 initPrice1) external onlyOwner {
        timeboxedMarkets.push(newTimeboxedMarket);
        timeboxedMarketGracePeriods[newTimeboxedMarket] = gracePeriod;
        timeboxedMarketInitializationTimestamps[newTimeboxedMarket] = block.timestamp;
        timeboxedMarketStatus[newTimeboxedMarket] = MarketStatus.Live;
        option0InitializationPrice[newTimeboxedMarket] = initPrice0;
        option1InitializationPrice[newTimeboxedMarket] = initPrice1;
    }

    // one-time call from owner to initialize a market and set vars
    function initialize(uint256 initPrice0, uint256 initPrice1) external onlyOwner {

        (settlementPeriod, predictionQualifier, liquidityQualifier, mrt, WPACKRewardManagerAddr, WPACKStakingManagerAddr) = IMarketUtility(marketUtility).getBasicMarketData();

        for (uint256 i; i < timeboxedMarkets.length; i++) {
            uint256 timebox = timeboxedMarkets[i];
            timeboxedMarketInitializationTimestamps[timebox] = block.timestamp;
            timeboxedMarketStatus[timebox] = MarketStatus.Live;
            option0InitializationPrice[timebox] = initPrice0;
            option1InitializationPrice[timebox] = initPrice1;
        }

        timeboxedMarketGracePeriods[1 hours] = 20 minutes;
        timeboxedMarketGracePeriods[4 hours] = 1.5 hours;
        timeboxedMarketGracePeriods[12 hours] = 4 hours;
        timeboxedMarketGracePeriods[1 days] = 8 hours;
        timeboxedMarketGracePeriods[1 weeks] = 2 days;

        initialized = true;
    }

    function predict(bool option, uint256 timeframe, uint256 leverage, uint256 _stake) external returns(uint256) {
        require(initialized, "prediction: market not initialized");
        require(liquidity > 0, "prediction: zero liquidity");
        bool verified = verifyTimebox(timeframe);
        require(verified, "prediction: not a timebox");
        require(_stake > 0, "prediction: stake < 0");
        require(leverage <= MAXLEVERAGE && leverage >= 1, "prediction: invalid leverage");
        require(timeboxedMarketStatus[timeframe] == MarketStatus.Live, "prediction: market not LIVE");
        require(block.timestamp < timeboxedMarketInitializationTimestamps[timeframe] + timeboxedMarketGracePeriods[timeframe], "prediction: grace period exceeded");
        predictionId++;
        totalPredicted += _stake;
        if (_stake > predictionQualifier) {
            notifyWOLFPACKRewardManager(msg.sender, true, false, false);
        }
        uint256 fee = _stake / 100;
        uint256 stake = _stake - fee;
        uint256 size = stake * leverage;
        uint256 riskOn = size / 5;
        riskOnOption[msg.sender][timeframe][option] += riskOn;
        totalRisk[timeframe][option] += riskOn;
        predictionBalance[msg.sender][timeframe][option] += stake;
        predictions.push(UserPredictionData(msg.sender, predictionId, option, timeframe, stake, leverage, size));
        optionSize[timeframe][option] += size;
        marketToken.transferFrom(msg.sender, address(this), _stake);
        calcAndDistributePredictionFee(fee);     
        emit PredictionPlaced(msg.sender, option, timeframe, leverage, _stake);
        return predictionId;
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
        // 10%, 55%, 35%
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

    function getPrediction(uint256 id) public view returns (address, uint256, bool, uint256, uint256, uint256, uint256) {
        for (uint256 i; i < predictions.length; i++) {
            if (predictions[i].id == id && predictions[i].predictor == msg.sender) {
                return (predictions[i].predictor, predictions[i].id, predictions[i].option, predictions[i].timeframe, predictions[i].stake, predictions[i].leverage, predictions[i].size);
            }
        }
    }

    function withdrawPredictionPosition(uint256 id, uint256 amount) external nonReentrant {
        ( , , bool opt, uint256 tf, , , uint256 sz ) = getPrediction(id);
        require(amount > 0 && amount <= predictionBalance[msg.sender][tf][opt], "withdraw prediction: insufficient balance");

        // withdraw only when markets are inSettlement or when LIVE but gracePeriod is active
        if (timeboxedMarketStatus[tf] == MarketStatus.Live) {
            require(block.timestamp < timeboxedMarketInitializationTimestamps[tf] + timeboxedMarketGracePeriods[tf], "prediction: grace period exceeded");
        } 

        uint256 riskOn = sz / 5;
        
        if (amount == predictionBalance[msg.sender][tf][opt]) {  
            delete riskOnOption[msg.sender][tf][opt];           
            delete predictionBalance[msg.sender][tf][opt];
            removePrediction(id);
        }
        else {
            riskOnOption[msg.sender][tf][opt] -= riskOn;
            predictionBalance[msg.sender][tf][opt] -= amount;
        }
        totalRisk[tf][opt] -= riskOn;
        optionSize[tf][opt] -= sz;
        totalPredicted -= amount;

        marketToken.transfer(msg.sender, amount);

        emit PredictionWithdrawn(msg.sender, amount);
    }

    function getPredictionData() external view returns (uint256, uint256, uint256) {
        uint256 len = timeboxedMarkets.length;
        uint256 size0;
        uint256 size1;
        for (uint256 i; i < len; i++) {
            // sentiment
            uint256 timebox = timeboxedMarkets[i];
            size0 += optionSize[timebox][true];
            size1 += optionSize[timebox][false];            
        }  
        return (totalPredicted, size0, size1);     
    }

    function getTimeboxedMarketData(uint256 timeframe) external view returns (uint256, uint256, MarketStatus tfStatus, uint256, uint256) {       
        return (option0InitializationPrice[timeframe], option1InitializationPrice[timeframe], timeboxedMarketStatus[timeframe], timeboxedMarketGracePeriods[timeframe], timeboxedMarketInitializationTimestamps[timeframe]);
    }
    
    function getSettledMarketData(uint256 timeframe) external view returns (uint256, uint256, uint256, uint256, bool) {
        return (option0InitializationPrice[timeframe], option1InitializationPrice[timeframe], option0SettlementPrice[timeframe], option1SettlementPrice[timeframe], timeboxedMarketWinner[timeframe]);
    }

    function removePrediction(uint256 id) private {
        uint256 len = predictions.length;
        for (uint256 i; i < len - 1; i++) {
            while (predictions[i].id == id) {
                // shift index to last, remove. 
                predictions[i] = predictions[i+1];   
            }
        }
        predictions.pop();
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
            if (timeboxedMarketStatus[timebox] == MarketStatus.InSettlement) {
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

    function restartTimeboxedMarket(uint256 tf, uint256 initPrice0, uint256 initPrice1) external {
        require(timeboxedMarketStatus[tf] == MarketStatus.InSettlement, "timeboxedMarket: invalid market status");
        require(block.timestamp > timeboxedMarketSettlementTimestamps[tf] + settlementPeriod, "timeboxedMarket: settlement not over");

        // clear storage for the next round
        for (uint256 i=0; i<predictions.length; i++) {
            if (predictions[i].timeframe == tf) {
                delete predictions[i];
            }           
        } 

        delete totalRisk[tf][false];
        delete totalRisk[tf][true];
        delete optionSize[tf][false];
        delete optionSize[tf][true];
        delete option0InitializationPrice[tf];
        delete option1InitializationPrice[tf];
        delete option0SettlementPrice[tf];
        delete option1SettlementPrice[tf];
        delete timeboxedMarketWinner[tf];

        // refresh init 
        option0InitializationPrice[tf] = initPrice0;
        option1InitializationPrice[tf] = initPrice1;
        timeboxedMarketStatus[tf] = MarketStatus.Live;
        timeboxedMarketInitializationTimestamps[tf] = block.timestamp;

        notifyWOLFPACKRewardManager(msg.sender, false, false, true);

        emit MarketRestarted(msg.sender, tf, block.timestamp);
    }

    function settleTimeboxedMarket(uint256 tf, uint256 settlePrice0, uint256 settlePrice1) external {
        require(timeboxedMarketStatus[tf] == MarketStatus.Live, "timeboxedMarket: invalid market status");
        require(block.timestamp > timeboxedMarketInitializationTimestamps[tf] + tf, "timeboxedMarket: timebox not completed");

        timeboxedMarketStatus[tf] = MarketStatus.InSettlement;
        timeboxedMarketSettlementTimestamps[tf] = block.timestamp;

        executeSettlement(tf, settlePrice0, settlePrice1);
        notifyWOLFPACKRewardManager(msg.sender, false, false, true);

        emit MarketSettled(msg.sender, tf, block.timestamp);
    }

    function executeSettlement(uint256 tf, uint256 currentPrice0, uint256 currentPrice1) private {
        address lPredictor;
        address wPredictor;            
        bool w = IMarketUtility(marketUtility).calulateMarketWinnerParameterized(option0InitializationPrice[tf], option1InitializationPrice[tf], currentPrice0, currentPrice1);

        if (w = true) {
            // loop through prediction data and assign all winning/losing addresses for that tf
            for (uint256 i=0; i<predictions.length; i++) {
                while (predictions[i].timeframe == tf) {
                    // sort losers
                    if (predictions[i].option == false) {
                        lPredictor = predictions[i].predictor;
                        // update predictionBalance: 
                        predictionBalance[lPredictor][tf][false] -= riskOnOption[lPredictor][tf][false];
                        // add riskOnOption to winning pool:
                        payoutPool += riskOnOption[lPredictor][tf][false];
                        // reset riskOn for next round
                        delete riskOnOption[lPredictor][tf][false];                       
                    }
                    // sort winners
                    else if (predictions[i].option == true) {
                        wPredictors.push(predictions[i].predictor);
                    }
                } 
            }
            // if payoutPool < MRT then take diff from totalLiquidity 
            uint256 minPayout = totalRisk[tf][true] / mrt;
            if (payoutPool < minPayout) { 
                uint256 diff = minPayout - payoutPool;
                liquidity -= diff;
                payoutPool += diff;
            }
            // winners
            for (uint256 i=0; i<wPredictors.length; i++) {
                wPredictor = wPredictors[i];
                for (uint256 j=0; j<predictions.length; j++) {
                    while (predictions[i].predictor == wPredictor) {
                        uint256 pId = predictions[i].id;
                        ( , , , , , , uint256 sz ) = getPrediction(pId);
                        uint256 perc =  (sz * 100) / optionSize[tf][true];
                        uint256 wAmount = (payoutPool * perc) / 100;
                        // add to predictionBalance
                        predictionBalance[wPredictor][tf][true] += wAmount;
                        // delete riskOn 
                        delete riskOnOption[wPredictor][tf][true];
                    }
                }
            }
            timeboxedMarketWinner[tf] = true;
        }
        else if (w = false) {
            // loop through 
            for (uint256 i=0; i<predictions.length; i++) {
                while (predictions[i].timeframe == tf) {
                    // sort losers
                    if (predictions[i].option == true) {
                        lPredictor = predictions[i].predictor;
                        // update predictionBalance: 
                        predictionBalance[lPredictor][tf][true] -= riskOnOption[lPredictor][tf][true];
                        // add riskOnOption to winners:
                        payoutPool += riskOnOption[lPredictor][tf][true];
                        // reset riskOn for next round
                        delete riskOnOption[lPredictor][tf][true];                       
                    }
                    // sort winners
                    else if (predictions[i].option == false) {
                        wPredictors.push(predictions[i].predictor);
                    }
                } 
            }
            // if payoutPool < MRT then take diff from totalLiquidity 
            uint256 minPayout = totalRisk[tf][false] / mrt;
            if (payoutPool < minPayout) { 
                uint256 diff = minPayout - payoutPool;
                liquidity -= diff;
                payoutPool += diff;
            }
            // winners
            for (uint256 i=0; i<wPredictors.length; i++) {
                wPredictor = wPredictors[i];
                for (uint256 j=0; j<predictions.length; j++) {
                    while (predictions[i].predictor == wPredictor) {
                        uint256 pId = predictions[i].id;
                        ( , , , , , , uint256 sz ) = getPrediction(pId);
                        uint256 perc =  (sz * 100) / optionSize[tf][false];
                        uint256 wAmount = (payoutPool * perc) / 100;
                        // add to predictionBalance
                        predictionBalance[wPredictor][tf][false] += wAmount;
                        // delete riskOn 
                        delete riskOnOption[wPredictor][tf][false];
                    }
                }
            }
            timeboxedMarketWinner[tf] = false;
        }  
        option0SettlementPrice[tf] = currentPrice0;   
        option1SettlementPrice[tf] = currentPrice1;   
    }

    function estimateWin(uint256 id) external view returns (uint256, uint256) {

        ( , , bool option, uint256 tf, , , uint256 sz ) = getPrediction(id);

        if (option == true) {
            uint256 positionPerc = (sz * 100) / optionSize[tf][true];
            uint256 rewardPool = totalRisk[tf][false];
            uint256 winEstimate = (rewardPool * positionPerc) / 100;
            return (positionPerc, winEstimate);
        }
        else if (option == false) {
            uint256 positionPerc = (sz * 100) / optionSize[tf][false];
            uint256 rewardPool = totalRisk[tf][true];
            uint256 winEstimate = (rewardPool * positionPerc) / 100;
            return (positionPerc, winEstimate);
        }       
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