/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_stake := mload(returndata)
                    revert(add(32, returndata), returndata_stake)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeERC20: decreased allowance below zero"
            );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional

            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier validAddress(address addr) {


    require(addr != address(0), "Address cannot be 0x0");
    require(addr != address(this), "Address cannot be contract address");
    _;
    }
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

   
    function transferOwnership(address newOwner) public virtual onlyOwner validAddress(newOwner) {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    
     function decimals() external view returns (uint256);
     
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

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
    function getBasicMarketData() external view returns (uint256, uint256, uint256, uint256, address, address, address);
    function getChainLinkLatestPricesUSD(address _feedAddress0, address _feedAddress1) external view returns (uint256, uint256);
    function calculateMarketWinnerOraclized (uint256 option0InitPrice, address option0Feed, uint256 option1InitPrice, address option1Feed) external view returns (bool, uint256, uint256);
    function calulateMarketWinnerParameterized(uint256 option0InitPrice, uint256 option1InitPrice, uint256 option0SettlementPrice, uint256 option1SettlementPrice) external view returns (bool);
}

contract MarketOraclized is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

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

    UserPredictionData[] predictions;

    string public marketName;

    uint256 constant MAXLEVERAGE = 5;
    uint256 initializationTime;
    uint256 predictionId;
    uint256 totalPredicted;
    uint256 public liquidity;
    uint256 payoutPool;
    uint256 settlementPeriod;
    uint256 predictionQualifier;
    uint256 liquidityQualifier;
    uint256 mrt;
    uint256[] timeboxedMarkets = [1 hours, 4 hours, 12 hours, 1 days, 1 weeks];

    address public option0PriceFeed;
    address public option1PriceFeed;
    address marketCurr = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // testnet BUSD, 
    address marketUtility = 0x5035d192bA39973f8efea004D440E73f136fB7c5; // testnet
    address WPACKRewardManagerAddr;
    address WPACKStakingManagerAddr;
    address operator;
    address[] wPredictors;
    address[] liquidityProviders;

    bool initialized = false;

    mapping(uint256 => MarketStatus) timeboxedMarketStatus;
    mapping(uint256 => uint256) timeboxedMarketGracePeriods;
    mapping(uint256 => uint256) timeboxedMarketInitializationTimestamps;
    mapping(uint256 => uint256) timeboxedMarketSettlementTimestamps;
    mapping(address => mapping(uint256 => mapping(bool => uint256))) riskOnOption;
    mapping(uint256 => mapping(bool => uint256)) totalRisk;
    mapping(address => mapping(uint256 => mapping(bool => uint256))) predictionBalance;
    mapping(uint256 => uint256) public option0InitializationPrice;
    mapping(uint256 => uint256) public option1InitializationPrice;
    mapping(uint256 => uint256) public option0SettlementPrice;
    mapping(uint256 => uint256) public option1SettlementPrice;
    mapping(address => uint256) lpBalances;
    mapping(uint256 => mapping(bool => uint256)) optionSize;
    mapping(uint256 => bool) timeboxedMarketWinner;
   
    IERC20 marketCurrency = IERC20(marketCurr);

    event PredictionPlaced(address indexed predictor, bool option, uint256 timeframe, uint256 leverage, uint256 stake);
    event PredictionWithdrawn(address indexed predictor, uint256 withdrawalAmount);
    event LiquidityAdded(address indexed liquidityProvider, uint256 amount);
    event LiquidityWithdrawn(address indexed liquidityProvider, uint256 withdrawalAmount);
    event MarketRestarted(address caller, uint256 marketTimebox, uint256 timestamp);
    event MarketSettled(address caller, uint256 marketTimebox, uint256 timestamp);

    // option0 = ETH, option1 = BNB
    constructor(address _option0PriceFeed, address _option1PriceFeed, string memory _marketName) {
        option0PriceFeed = _option0PriceFeed;
        option1PriceFeed = _option1PriceFeed;
        marketName = _marketName;
    }

    // in case of governance change
    function changeMarketCurrency(address _newCurr) external onlyOwner {
        marketCurr = _newCurr;
    }
    // in case of governance change
    function addTimeboxedMarket(uint256 newTimeboxedMarket, uint256 gracePeriod) external onlyOwner {
        timeboxedMarkets.push(newTimeboxedMarket);
        timeboxedMarketGracePeriods[newTimeboxedMarket] == gracePeriod;
    }

    // one-time call from owner to initialize market 0 and set constant vars
    function initialize(address _feed0, address _feed1) external onlyOwner {

        (uint256 initPrice0, uint256 initPrice1) = IMarketUtility(marketUtility).getChainLinkLatestPricesUSD(_feed0, _feed1);

        (settlementPeriod, predictionQualifier, liquidityQualifier, mrt, WPACKRewardManagerAddr, WPACKStakingManagerAddr, operator) = IMarketUtility(marketUtility).getBasicMarketData();

        for (uint256 i; i < timeboxedMarkets.length; i++) {
            timeboxedMarketInitializationTimestamps[i] = block.timestamp;
            timeboxedMarketStatus[i] = MarketStatus.Live;
            option0InitializationPrice[i] = initPrice0;
            option1InitializationPrice[i] = initPrice1;
        }

        timeboxedMarketGracePeriods[1 hours] = 15 minutes;
        timeboxedMarketGracePeriods[4 hours] = 1 hours;
        timeboxedMarketGracePeriods[12 hours] = 3 hours;
        timeboxedMarketGracePeriods[1 days] = 6 hours;
        timeboxedMarketGracePeriods[1 weeks] = 1 days;

        initialized = true;
    }

    function predict(bool option, uint256 timeframe, uint256 leverage, uint256 _stake) external {
        require(_stake > 0, "prediction: stake < 0");
        require(leverage <= MAXLEVERAGE && leverage >= 1, "prediction: invalid leverage");
        require(timeboxedMarketStatus[timeframe] == MarketStatus.Live, "marketStatus: market not LIVE");
        require(block.timestamp < timeboxedMarketInitializationTimestamps[timeframe] + timeboxedMarketGracePeriods[timeframe], "prediction: grace period exceeded");
        require(initialized, "market not initialized");
        predictionId++;
        totalPredicted += _stake;
        if (_stake > predictionQualifier) {
            notifyWOLFPACKRewardManager( _msgSender(), true, false, false);
        }
        // check timeframe is intended
        uint256 len = timeboxedMarkets.length;
        for (uint256 i; i < len; i++) {
            if (timeframe == timeboxedMarkets[i]) {
                uint256 fee = _stake / 100;
                uint256 stake = _stake - fee;
                uint256 size = stake * leverage;
                uint256 baselineRisk = stake / 5;
                uint256 riskOn = baselineRisk * leverage;
                riskOnOption[_msgSender()][timeframe][option] += riskOn;
                totalRisk[timeframe][option] += riskOn;
                predictionBalance[_msgSender()][timeframe][option] += stake;
                predictions.push(UserPredictionData(_msgSender(), predictionId, option, timeframe, stake, leverage, size));
                optionSize[timeframe][option] += size;
                marketCurrency.safeTransferFrom(_msgSender(), address(this), _stake);
                calcAndDistributePredictionFee(fee);     
            }
            else {
                revert("timeboxedMarkets: timeframe does not exist");
            }
        }
        emit PredictionPlaced(_msgSender(), option, timeframe, leverage, _stake);
    }

    function withdrawPredictionBalance(uint256 timeframe, bool option, uint256 amount) external nonReentrant {
        require(amount > 0 && amount <= predictionBalance[_msgSender()][timeframe][option], "withdraw prediction: insufficient balance");
        // withdraw only when markets are inSettlement or when LIVE but gracePeriod is active
        if (timeboxedMarketStatus[timeframe] == MarketStatus.Live) {
            require(block.timestamp < timeboxedMarketInitializationTimestamps[timeframe] + timeboxedMarketGracePeriods[timeframe], "prediction: grace period exceeded");
        }   
        // update the balance
        predictionBalance[_msgSender()][timeframe][option] -= amount;
        totalPredicted -= amount;
        marketCurrency.safeTransferFrom(address(this), _msgSender(), amount);

        emit PredictionWithdrawn(_msgSender(), amount);
    }

    function getPrediction(uint256 id) public view returns (address prdctr, uint256 prId, bool opt, uint256 tf, uint256 st, uint256 lev, uint256 sz) {
        for (uint256 i; i < predictions.length; i++) {
            if (predictions[i].id == id && predictions[i].predictor == _msgSender()) {
                return (predictions[i].predictor, predictions[i].id, predictions[i].option, predictions[i].timeframe, predictions[i].stake, predictions[i].leverage, predictions[i].size);
            }
        }
    }

    function calcAndDistributePredictionFee(uint256 _fee) private {
        uint256 len = liquidityProviders.length;
        // 10%, 55%, 35%
        uint256 operatorDividend = _fee / 10;
        uint256 wolfpackStakersDividend = (_fee * 550) / 100;
        uint256 lpDividend = (_fee * 350) / 100;

        for (uint256 i; i < len; i++) {
            address lp = liquidityProviders[i];
            uint256 perc = (lpBalances[lp] * 100) / liquidity;
            uint256 allocation = (perc * lpDividend) / 100;
            lpBalances[lp] += allocation;
        }

        marketCurrency.safeTransferFrom(address(this), operator, operatorDividend);
        notifyWOLFPACKStakingManager(wolfpackStakersDividend);
    }

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "liquidity: amount < 0");
        if (amount > liquidityQualifier) {
            notifyWOLFPACKRewardManager(_msgSender(), false, true, false);
        }
        lpBalances[_msgSender()] += amount;
        liquidityProviders.push(_msgSender());
        liquidity += amount;
        marketCurrency.safeTransferFrom(_msgSender(), address(this), amount);

        emit LiquidityAdded(_msgSender(), amount);
    }

    function getLiquidityBalance() external view returns (uint256 balance) {
        return lpBalances[_msgSender()];
    }

    function withdrawLiquidity(uint256 amount) external nonReentrant {
        uint256 lpBalance = lpBalances[_msgSender()];
        require(amount > 0 && amount <= lpBalance, "liquidity: insufficient balance");
        // require that all timeboxedMarkets are NOT inSettlement
        for (uint256 i; i < timeboxedMarkets.length; i++) {
            if (timeboxedMarketStatus[i] == MarketStatus.InSettlement) {
                revert("liquidity: markets in settlement");
            }
        }
        uint256 fee = amount / 100; // 1%
        calcAndDistributeLiquidityWithdrawalFee(fee);
        uint256 withdrawal = amount - fee;
        if (amount == lpBalance) {
            removeLp(_msgSender());
        }
        liquidity -= amount;
        lpBalances[_msgSender()] -= amount;
        marketCurrency.safeTransferFrom(address(this), _msgSender(), withdrawal);

        emit LiquidityWithdrawn(_msgSender(), amount);
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
        marketCurrency.safeTransferFrom(address(this), operator, dividend);
        marketCurrency.safeTransferFrom(address(this), WPACKStakingManagerAddr, dividend);
    }

    function getMarketData() external view returns (uint256 usdPredicted, uint256 sentimentA, uint256 sentimentB) {
        uint256 len = timeboxedMarkets.length;
        
        for (uint256 i; i < len; i++) {
            // sentiment
            uint256 size0 = optionSize[i][true];
            uint256 size1 = optionSize[i][false];

            return (totalPredicted, size0, size1);
        }      
    }

    function getTimeboxedMarketData(uint256 timeframe) external view returns (uint256 initPrice0, uint256 initPrice1, MarketStatus tfStatus, uint256 gp, uint256 init) {       
        return (option0InitializationPrice[timeframe], option1InitializationPrice[timeframe], timeboxedMarketStatus[timeframe], timeboxedMarketGracePeriods[timeframe], timeboxedMarketInitializationTimestamps[timeframe]);
    }
    
    function getSettledMarketData(uint256 timeframe) external view returns (uint256 initPrice0, uint256 initPrice1, uint256 settlePrice0, uint256 settlePrice1, bool w) {
        return (option0InitializationPrice[timeframe], option1InitializationPrice[timeframe], option0SettlementPrice[timeframe], option1SettlementPrice[timeframe], timeboxedMarketWinner[timeframe]);
    }

    function restartTimeboxedMarket(uint256 tf, address _feed0, address _feed1) external {
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
        (uint256 initPrice0, uint256 initPrice1) = IMarketUtility(marketUtility).getChainLinkLatestPricesUSD(_feed0, _feed1);
        option0InitializationPrice[tf] = initPrice0;
        option1InitializationPrice[tf] = initPrice1;
        timeboxedMarketStatus[tf] = MarketStatus.Live;
        timeboxedMarketInitializationTimestamps[tf] = block.timestamp;

        notifyWOLFPACKRewardManager(_msgSender(), false, false, true);

        emit MarketRestarted(_msgSender(), tf, block.timestamp);
    }

    function settleTimeboxedMarket(uint256 tf) external {
        require(timeboxedMarketStatus[tf] == MarketStatus.Live, "timeboxedMarket: invalid market status");
        require(block.timestamp > timeboxedMarketInitializationTimestamps[tf] + tf, "timeboxedMarket: timebox not completed");

        timeboxedMarketStatus[tf] = MarketStatus.InSettlement;
        timeboxedMarketSettlementTimestamps[tf] = block.timestamp;

        executeSettlement(tf);
        notifyWOLFPACKRewardManager(_msgSender(), false, false, true);

        emit MarketSettled(_msgSender(), tf, block.timestamp);
    }

    function executeSettlement(uint256 tf) private {
        address lPredictor;
        address wPredictor;            
        bool w = getMarketWinner(tf);

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
            // 20% of winner
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
            // 20% of winner
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
    }

    function getMarketWinner(uint256 tf) private returns (bool winner) {
        uint256 initPrice0 = option0InitializationPrice[tf];
        uint256 initPrice1 = option1InitializationPrice[tf];
        
        (bool w, uint256 sett0, uint256 sett1) = IMarketUtility(marketUtility).calculateMarketWinnerOraclized(initPrice0, option0PriceFeed, initPrice1, option1PriceFeed);

        option0SettlementPrice[tf] = sett0;
        option1SettlementPrice[tf] = sett1;

        return w;
    }

    function estimateWin(uint256 id) external view returns (uint256 sizePerc, uint256 winEst) {

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
        marketCurrency.safeTransferFrom(address(this), WPACKStakingManagerAddr, distribution);
    }

}