// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "../interfaces/ITrancheIndexV2.sol";

abstract contract FundRolesV2 is ITrancheIndexV2 {
    event PrimaryMarketUpdateProposed(
        address indexed newPrimaryMarket,
        uint256 minTimestamp,
        uint256 maxTimestamp
    );
    event PrimaryMarketUpdated(
        address indexed previousPrimaryMarket,
        address indexed newPrimaryMarket
    );
    event StrategyUpdateProposed(
        address indexed newStrategy,
        uint256 minTimestamp,
        uint256 maxTimestamp
    );
    event StrategyUpdated(address indexed previousStrategy, address indexed newStrategy);

    uint256 private constant ROLE_UPDATE_MIN_DELAY = 3 days;
    uint256 private constant ROLE_UPDATE_MAX_DELAY = 15 days;

    address internal immutable _tokenQ;
    address internal immutable _tokenB;
    address internal immutable _tokenR;

    address internal _primaryMarket;
    address internal _proposedPrimaryMarket;
    uint256 internal _proposedPrimaryMarketTimestamp;

    address internal _strategy;
    address internal _proposedStrategy;
    uint256 internal _proposedStrategyTimestamp;

    constructor(
        address tokenQ_,
        address tokenB_,
        address tokenR_,
        address primaryMarket_,
        address strategy_
    ) public {
        _tokenQ = tokenQ_;
        _tokenB = tokenB_;
        _tokenR = tokenR_;
        _primaryMarket = primaryMarket_;
        _strategy = strategy_;
        emit PrimaryMarketUpdated(address(0), primaryMarket_);
        emit StrategyUpdated(address(0), strategy_);
    }

    function _getTranche(address share) internal view returns (uint256) {
        if (share == _tokenQ) {
            return TRANCHE_Q;
        } else if (share == _tokenB) {
            return TRANCHE_B;
        } else if (share == _tokenR) {
            return TRANCHE_R;
        } else {
            revert("Only share");
        }
    }

    function _getShare(uint256 tranche) internal view returns (address) {
        if (tranche == TRANCHE_Q) {
            return _tokenQ;
        } else if (tranche == TRANCHE_B) {
            return _tokenB;
        } else if (tranche == TRANCHE_R) {
            return _tokenR;
        } else {
            revert("Invalid tranche");
        }
    }

    modifier onlyPrimaryMarket() {
        require(msg.sender == _primaryMarket, "Only primary market");
        _;
    }

    function _proposePrimaryMarketUpdate(address newPrimaryMarket) internal {
        require(newPrimaryMarket != _primaryMarket);
        _proposedPrimaryMarket = newPrimaryMarket;
        _proposedPrimaryMarketTimestamp = block.timestamp;
        emit PrimaryMarketUpdateProposed(
            newPrimaryMarket,
            block.timestamp + ROLE_UPDATE_MIN_DELAY,
            block.timestamp + ROLE_UPDATE_MAX_DELAY
        );
    }

    function _applyPrimaryMarketUpdate(address newPrimaryMarket) internal {
        require(_proposedPrimaryMarket == newPrimaryMarket, "Proposed address mismatch");
        require(
            block.timestamp >= _proposedPrimaryMarketTimestamp + ROLE_UPDATE_MIN_DELAY &&
                block.timestamp < _proposedPrimaryMarketTimestamp + ROLE_UPDATE_MAX_DELAY,
            "Not ready to update"
        );
        emit PrimaryMarketUpdated(_primaryMarket, newPrimaryMarket);
        _primaryMarket = newPrimaryMarket;
        _proposedPrimaryMarket = address(0);
        _proposedPrimaryMarketTimestamp = 0;
    }

    modifier onlyStrategy() {
        require(msg.sender == _strategy, "Only strategy");
        _;
    }

    function _proposeStrategyUpdate(address newStrategy) internal {
        require(newStrategy != _strategy);
        _proposedStrategy = newStrategy;
        _proposedStrategyTimestamp = block.timestamp;
        emit StrategyUpdateProposed(
            newStrategy,
            block.timestamp + ROLE_UPDATE_MIN_DELAY,
            block.timestamp + ROLE_UPDATE_MAX_DELAY
        );
    }

    function _applyStrategyUpdate(address newStrategy) internal {
        require(_proposedStrategy == newStrategy, "Proposed address mismatch");
        require(
            block.timestamp >= _proposedStrategyTimestamp + ROLE_UPDATE_MIN_DELAY &&
                block.timestamp < _proposedStrategyTimestamp + ROLE_UPDATE_MAX_DELAY,
            "Not ready to update"
        );
        emit StrategyUpdated(_strategy, newStrategy);
        _strategy = newStrategy;
        _proposedStrategy = address(0);
        _proposedStrategyTimestamp = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

/// @notice Amounts of QUEEN, BISHOP and ROOK are sometimes stored in a `uint256[3]` array.
///         This contract defines index of each tranche in this array.
///
///         Solidity does not allow constants to be defined in interfaces. So this contract follows
///         the naming convention of interfaces but is implemented as an `abstract contract`.
abstract contract ITrancheIndexV2 {
    uint256 internal constant TRANCHE_Q = 0;
    uint256 internal constant TRANCHE_B = 1;
    uint256 internal constant TRANCHE_R = 2;

    uint256 internal constant TRANCHE_COUNT = 3;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../utils/SafeDecimalMath.sol";
import "../utils/CoreUtility.sol";

import "../interfaces/IPrimaryMarketV3.sol";
import "../interfaces/IFundV3.sol";
import "../interfaces/IShareV2.sol";
import "../interfaces/ITwapOracleV2.sol";
import "../interfaces/IAprOracle.sol";
import "../interfaces/IBallot.sol";
import "../interfaces/IVotingEscrow.sol";

import "./FundRolesV2.sol";

contract FundV3 is IFundV3, Ownable, ReentrancyGuard, FundRolesV2, CoreUtility {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event ProfitReported(uint256 profit, uint256 performanceFee);
    event LossReported(uint256 loss);
    event DailyProtocolFeeRateUpdated(uint256 newDailyProtocolFeeRate);
    event TwapOracleUpdated(address newTwapOracle);
    event AprOracleUpdated(address newAprOracle);
    event BallotUpdated(address newBallot);
    event FeeCollectorUpdated(address newFeeCollector);
    event ActivityDelayTimeUpdated(uint256 delayTime);
    event SplitRatioUpdated(uint256 newSplitRatio);
    event FeeDebtPaid(uint256 amount);
    event TotalDebtUpdated(uint256 newTotalDebt);

    uint256 private constant UNIT = 1e18;
    uint256 private constant MAX_INTEREST_RATE = 0.2e18; // 20% daily
    uint256 private constant MAX_DAILY_PROTOCOL_FEE_RATE = 0.05e18; // 5% daily rate

    /// @notice Upper bound of `NAV_R / NAV_B` to trigger a rebalance.
    uint256 public immutable upperRebalanceThreshold;

    /// @notice Lower bound of `NAV_R / NAV_B` to trigger a rebalance.
    uint256 public immutable lowerRebalanceThreshold;

    /// @notice Address of the underlying token.
    address public immutable override tokenUnderlying;

    /// @notice A multipler that normalizes an underlying balance to 18 decimal places.
    uint256 public immutable override underlyingDecimalMultiplier;

    /// @notice Daily protocol fee rate.
    uint256 public dailyProtocolFeeRate;

    /// @notice TwapOracle address for the underlying asset.
    ITwapOracleV2 public override twapOracle;

    /// @notice AprOracle address.
    IAprOracle public aprOracle;

    /// @notice Address of the interest rate ballot.
    IBallot public ballot;

    /// @notice Fee Collector address.
    address public override feeCollector;

    /// @notice End timestamp of the current trading day.
    ///         A trading day starts at UTC time `SETTLEMENT_TIME` of a day (inclusive)
    ///         and ends at the same time of the next day (exclusive).
    uint256 public override currentDay;

    /// @notice The amount of BISHOP received by splitting one QUEEN.
    ///         This ratio changes on every rebalance.
    uint256 public override splitRatio;

    /// @dev Mapping of rebalance version => splitRatio.
    mapping(uint256 => uint256) private _historicalSplitRatio;

    /// @notice Start timestamp of the current primary market activity window.
    uint256 public override fundActivityStartTime;

    uint256 public activityDelayTimeAfterRebalance;

    /// @dev Historical rebalances. Rebalances are often accessed in loops with bounds checking.
    ///      So we store them in a fixed-length array, in order to make compiler-generated
    ///      bounds checking on every access cheaper. The actual length of this array is stored in
    ///      `_rebalanceSize` and should be explicitly checked when necessary.
    Rebalance[65535] private _rebalances;

    /// @dev Historical rebalance count.
    uint256 private _rebalanceSize;

    /// @dev Total share supply of the three tranches. They are always rebalanced to the latest
    ///      version.
    uint256[TRANCHE_COUNT] private _totalSupplies;

    /// @dev Mapping of account => share balance of the three tranches.
    ///      Rebalance versions are stored in a separate mapping `_balanceVersions`.
    mapping(address => uint256[TRANCHE_COUNT]) private _balances;

    /// @dev Rebalance version mapping for `_balances`.
    mapping(address => uint256) private _balanceVersions;

    /// @dev Mapping of owner => spender => share allowance of the three tranches.
    ///      Rebalance versions are stored in a separate mapping `_allowanceVersions`.
    mapping(address => mapping(address => uint256[TRANCHE_COUNT])) private _allowances;

    /// @dev Rebalance version mapping for `_allowances`.
    mapping(address => mapping(address => uint256)) private _allowanceVersions;

    /// @dev Mapping of trading day => NAV of BISHOP.
    mapping(uint256 => uint256) private _historicalNavB;

    /// @dev Mapping of trading day => NAV of ROOK.
    mapping(uint256 => uint256) private _historicalNavR;

    /// @notice Mapping of trading day => equivalent BISHOP supply.
    ///
    ///         Key is the end timestamp of a trading day. Value is the total supply of BISHOP,
    ///         as if all QUEEN are split.
    mapping(uint256 => uint256) public override historicalEquivalentTotalB;

    /// @notice Mapping of trading day => underlying assets in the fund.
    ///
    ///         Key is the end timestamp of a trading day. Value is the underlying assets in
    ///         the fund after settlement of that trading day.
    mapping(uint256 => uint256) public override historicalUnderlying;

    /// @notice Mapping of trading week => interest rate of BISHOP.
    ///
    ///         Key is the end timestamp of a trading day. Value is the interest rate captured
    ///         after settlement of that day, which will be effective in the following trading day.
    mapping(uint256 => uint256) public historicalInterestRate;

    /// @notice Amount of fee not transfered to the fee collector yet.
    uint256 public feeDebt;

    /// @notice Amount of redemption underlying that the fund owes the primary market
    uint256 public redemptionDebt;

    /// @dev Sum of the fee debt and redemption debts of all primary markets.
    uint256 private _totalDebt;

    uint256 private _strategyUnderlying;

    struct ConstructorParameters {
        address tokenUnderlying;
        uint256 underlyingDecimals;
        address tokenQ;
        address tokenB;
        address tokenR;
        address primaryMarket;
        address strategy;
        uint256 dailyProtocolFeeRate;
        uint256 upperRebalanceThreshold;
        uint256 lowerRebalanceThreshold;
        address twapOracle;
        address aprOracle;
        address ballot;
        address feeCollector;
    }

    constructor(ConstructorParameters memory params)
        public
        Ownable()
        FundRolesV2(
            params.tokenQ,
            params.tokenB,
            params.tokenR,
            params.primaryMarket,
            params.strategy
        )
    {
        tokenUnderlying = params.tokenUnderlying;
        require(params.underlyingDecimals <= 18, "Underlying decimals larger than 18");
        underlyingDecimalMultiplier = 10**(18 - params.underlyingDecimals);
        _updateDailyProtocolFeeRate(params.dailyProtocolFeeRate);
        upperRebalanceThreshold = params.upperRebalanceThreshold;
        lowerRebalanceThreshold = params.lowerRebalanceThreshold;
        _updateTwapOracle(params.twapOracle);
        _updateAprOracle(params.aprOracle);
        _updateBallot(params.ballot);
        _updateFeeCollector(params.feeCollector);
        _updateActivityDelayTime(30 minutes);
    }

    function initialize(
        uint256 newSplitRatio,
        uint256 lastNavB,
        uint256 lastNavR,
        uint256 strategyUnderlying
    ) external onlyOwner {
        require(splitRatio == 0 && currentDay == 0, "Already initialized");
        require(
            newSplitRatio != 0 && lastNavB >= UNIT && !_shouldTriggerRebalance(lastNavB, lastNavR),
            "Invalid parameters"
        );
        currentDay = endOfDay(block.timestamp);
        splitRatio = newSplitRatio;
        _historicalSplitRatio[0] = newSplitRatio;
        emit SplitRatioUpdated(newSplitRatio);
        uint256 lastDay = currentDay - 1 days;
        uint256 lastDayPrice = twapOracle.getTwap(lastDay);
        require(lastDayPrice != 0, "Price not available"); // required to do the first creation
        _historicalNavB[lastDay] = lastNavB;
        _historicalNavR[lastDay] = lastNavR;
        _strategyUnderlying = strategyUnderlying;
        uint256 lastInterestRate = _updateInterestRate(lastDay);
        historicalInterestRate[lastDay] = lastInterestRate;
        emit Settled(lastDay, lastNavB, lastNavR, lastInterestRate);
        fundActivityStartTime = lastDay;
    }

    /// @notice UTC time of a day when the fund settles.
    function settlementTime() external pure returns (uint256) {
        return SETTLEMENT_TIME;
    }

    /// @notice Return end timestamp of the trading day containing a given timestamp.
    ///
    ///         A trading day starts at UTC time `SETTLEMENT_TIME` of a day (inclusive)
    ///         and ends at the same time of the next day (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading day.
    function endOfDay(uint256 timestamp) public pure override returns (uint256) {
        return ((timestamp.add(1 days) - SETTLEMENT_TIME) / 1 days) * 1 days + SETTLEMENT_TIME;
    }

    /// @notice Return end timestamp of the trading week containing a given timestamp.
    ///
    ///         A trading week starts at UTC time `SETTLEMENT_TIME` on a Thursday (inclusive)
    ///         and ends at the same time of the next Thursday (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading week.
    function endOfWeek(uint256 timestamp) external pure returns (uint256) {
        return _endOfWeek(timestamp);
    }

    function tokenQ() external view override returns (address) {
        return _tokenQ;
    }

    function tokenB() external view override returns (address) {
        return _tokenB;
    }

    function tokenR() external view override returns (address) {
        return _tokenR;
    }

    function tokenShare(uint256 tranche) external view override returns (address) {
        return _getShare(tranche);
    }

    function primaryMarket() external view override returns (address) {
        return _primaryMarket;
    }

    function primaryMarketUpdateProposal() external view override returns (address, uint256) {
        return (_proposedPrimaryMarket, _proposedPrimaryMarketTimestamp);
    }

    function strategy() external view override returns (address) {
        return _strategy;
    }

    function strategyUpdateProposal() external view override returns (address, uint256) {
        return (_proposedStrategy, _proposedStrategyTimestamp);
    }

    /// @notice Return the status of the fund contract.
    /// @param timestamp Timestamp to assess
    /// @return True if the fund contract is active
    function isFundActive(uint256 timestamp) public view override returns (bool) {
        return timestamp >= fundActivityStartTime;
    }

    function getTotalUnderlying() public view override returns (uint256) {
        uint256 hot = IERC20(tokenUnderlying).balanceOf(address(this));
        return hot.add(_strategyUnderlying).sub(_totalDebt);
    }

    function getStrategyUnderlying() external view override returns (uint256) {
        return _strategyUnderlying;
    }

    function getTotalDebt() external view override returns (uint256) {
        return _totalDebt;
    }

    /// @notice Equivalent BISHOP supply, as if all QUEEN are split.
    function getEquivalentTotalB() public view override returns (uint256) {
        return _totalSupplies[TRANCHE_Q].multiplyDecimal(splitRatio).add(_totalSupplies[TRANCHE_B]);
    }

    /// @notice Equivalent QUEEN supply, as if all BISHOP and ROOK are merged.
    function getEquivalentTotalQ() external view override returns (uint256) {
        return _totalSupplies[TRANCHE_B].divideDecimal(splitRatio).add(_totalSupplies[TRANCHE_Q]);
    }

    /// @notice Return the rebalance matrix at a given index. A zero struct is returned
    ///         if `index` is out of bound.
    /// @param index Rebalance index
    /// @return A rebalance matrix
    function getRebalance(uint256 index) external view override returns (Rebalance memory) {
        return _rebalances[index];
    }

    /// @notice Return timestamp of the transaction triggering the rebalance at a given index.
    ///         Zero is returned if `index` is out of bound.
    /// @param index Rebalance index
    /// @return Timestamp of the rebalance
    function getRebalanceTimestamp(uint256 index) external view override returns (uint256) {
        return _rebalances[index].timestamp;
    }

    /// @notice Return the number of historical rebalances.
    function getRebalanceSize() external view override returns (uint256) {
        return _rebalanceSize;
    }

    /// @notice Return split ratio at a given version.
    ///         Zero is returned if `version` is invalid.
    /// @param version Rebalance version
    /// @return Split ratio of the version
    function historicalSplitRatio(uint256 version) external view override returns (uint256) {
        return _historicalSplitRatio[version];
    }

    /// @notice Return NAV of BISHOP and ROOK of the given trading day.
    /// @param day End timestamp of a trading day
    /// @return navB NAV of BISHOP
    /// @return navR NAV of ROOK
    function historicalNavs(uint256 day)
        external
        view
        override
        returns (uint256 navB, uint256 navR)
    {
        return (_historicalNavB[day], _historicalNavR[day]);
    }

    /// @notice Estimate the current NAV of all tranches, considering underlying price change,
    ///         accrued protocol fee and accrued interest since the previous settlement.
    ///
    ///         The extrapolation uses simple interest instead of daily compound interest in
    ///         calculating protocol fee and BISHOP's interest. There may be significant error
    ///         in the returned values when `timestamp` is far beyond the last settlement.
    /// @param price Price of the underlying asset (18 decimal places)
    /// @return navSum Sum of the estimated NAV of BISHOP and ROOK
    /// @return navB Estimated NAV of BISHOP
    /// @return navROrZero Estimated NAV of ROOK, or zero if the NAV is negative
    function extrapolateNav(uint256 price)
        external
        view
        override
        returns (
            uint256 navSum,
            uint256 navB,
            uint256 navROrZero
        )
    {
        uint256 settledDay = currentDay - 1 days;
        uint256 underlying = getTotalUnderlying();
        uint256 protocolFee =
            underlying.multiplyDecimal(dailyProtocolFeeRate).mul(block.timestamp - settledDay).div(
                1 days
            );
        underlying = underlying.sub(protocolFee);
        return
            _extrapolateNav(block.timestamp, settledDay, price, getEquivalentTotalB(), underlying);
    }

    function _extrapolateNav(
        uint256 timestamp,
        uint256 settledDay,
        uint256 price,
        uint256 equivalentTotalB,
        uint256 underlying
    )
        private
        view
        returns (
            uint256 navSum,
            uint256 navB,
            uint256 navROrZero
        )
    {
        navB = _historicalNavB[settledDay];
        if (equivalentTotalB > 0) {
            navSum = price.mul(underlying.mul(underlyingDecimalMultiplier)).div(equivalentTotalB);
            navB = navB.multiplyDecimal(
                historicalInterestRate[settledDay].mul(timestamp - settledDay).div(1 days).add(UNIT)
            );
            navROrZero = navSum >= navB ? navSum - navB : 0;
        } else {
            // If the fund is empty, use NAV in the last day
            navROrZero = _historicalNavR[settledDay];
            navSum = navB + navROrZero;
        }
    }

    /// @notice Transform share amounts according to the rebalance at a given index.
    ///         This function performs no bounds checking on the given index. A non-existent
    ///         rebalance transforms anything to a zero vector.
    /// @param amountQ Amount of QUEEN before the rebalance
    /// @param amountB Amount of BISHOP before the rebalance
    /// @param amountR Amount of ROOK before the rebalance
    /// @param index Rebalance index
    /// @return newAmountQ Amount of QUEEN after the rebalance
    /// @return newAmountB Amount of BISHOP after the rebalance
    /// @return newAmountR Amount of ROOK after the rebalance
    function doRebalance(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 index
    )
        public
        view
        override
        returns (
            uint256 newAmountQ,
            uint256 newAmountB,
            uint256 newAmountR
        )
    {
        Rebalance storage rebalance = _rebalances[index];
        newAmountQ = amountQ.add(amountB.multiplyDecimal(rebalance.ratioB2Q)).add(
            amountR.multiplyDecimal(rebalance.ratioR2Q)
        );
        uint256 ratioBR = rebalance.ratioBR; // Gas saver
        newAmountB = amountB.multiplyDecimal(ratioBR);
        newAmountR = amountR.multiplyDecimal(ratioBR);
    }

    /// @notice Transform share amounts according to rebalances in a given index range,
    ///         This function performs no bounds checking on the given indices. The original amounts
    ///         are returned if `fromIndex` is no less than `toIndex`. A zero vector is returned
    ///         if `toIndex` is greater than the number of existing rebalances.
    /// @param amountQ Amount of QUEEN before the rebalance
    /// @param amountB Amount of BISHOP before the rebalance
    /// @param amountR Amount of ROOK before the rebalance
    /// @param fromIndex Starting of the rebalance index range, inclusive
    /// @param toIndex End of the rebalance index range, exclusive
    /// @return newAmountQ Amount of QUEEN after the rebalance
    /// @return newAmountB Amount of BISHOP after the rebalance
    /// @return newAmountR Amount of ROOK after the rebalance
    function batchRebalance(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 fromIndex,
        uint256 toIndex
    )
        external
        view
        override
        returns (
            uint256 newAmountQ,
            uint256 newAmountB,
            uint256 newAmountR
        )
    {
        for (uint256 i = fromIndex; i < toIndex; i++) {
            (amountQ, amountB, amountR) = doRebalance(amountQ, amountB, amountR, i);
        }
        newAmountQ = amountQ;
        newAmountB = amountB;
        newAmountR = amountR;
    }

    /// @notice Transform share balance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshBalance(address account, uint256 targetVersion) external override {
        if (targetVersion > 0) {
            require(targetVersion <= _rebalanceSize, "Target version out of bound");
        }
        _refreshBalance(account, targetVersion);
    }

    /// @notice Transform allowance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param owner Owner of the allowance to rebalance
    /// @param spender Spender of the allowance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) external override {
        if (targetVersion > 0) {
            require(targetVersion <= _rebalanceSize, "Target version out of bound");
        }
        _refreshAllowance(owner, spender, targetVersion);
    }

    function trancheBalanceOf(uint256 tranche, address account)
        external
        view
        override
        returns (uint256)
    {
        uint256 amountQ = _balances[account][TRANCHE_Q];
        uint256 amountB = _balances[account][TRANCHE_B];
        uint256 amountR = _balances[account][TRANCHE_R];

        if (tranche == TRANCHE_Q) {
            if (amountQ == 0 && amountB == 0 && amountR == 0) return 0;
        } else if (tranche == TRANCHE_B) {
            if (amountB == 0) return 0;
        } else {
            if (amountR == 0) return 0;
        }

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _balanceVersions[account]; i < size; i++) {
            (amountQ, amountB, amountR) = doRebalance(amountQ, amountB, amountR, i);
        }

        if (tranche == TRANCHE_Q) {
            return amountQ;
        } else if (tranche == TRANCHE_B) {
            return amountB;
        } else {
            return amountR;
        }
    }

    /// @notice Return all three share balances transformed to the latest rebalance version.
    /// @param account Owner of the shares
    function trancheAllBalanceOf(address account)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 amountQ = _balances[account][TRANCHE_Q];
        uint256 amountB = _balances[account][TRANCHE_B];
        uint256 amountR = _balances[account][TRANCHE_R];

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _balanceVersions[account]; i < size; i++) {
            (amountQ, amountB, amountR) = doRebalance(amountQ, amountB, amountR, i);
        }

        return (amountQ, amountB, amountR);
    }

    function trancheBalanceVersion(address account) external view override returns (uint256) {
        return _balanceVersions[account];
    }

    function trancheAllowance(
        uint256 tranche,
        address owner,
        address spender
    ) external view override returns (uint256) {
        uint256 allowanceQ = _allowances[owner][spender][TRANCHE_Q];
        uint256 allowanceB = _allowances[owner][spender][TRANCHE_B];
        uint256 allowanceR = _allowances[owner][spender][TRANCHE_R];

        if (tranche == TRANCHE_Q) {
            if (allowanceQ == 0) return 0;
        } else if (tranche == TRANCHE_B) {
            if (allowanceB == 0) return 0;
        } else {
            if (allowanceR == 0) return 0;
        }

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _allowanceVersions[owner][spender]; i < size; i++) {
            (allowanceQ, allowanceB, allowanceR) = _rebalanceAllowance(
                allowanceQ,
                allowanceB,
                allowanceR,
                i
            );
        }

        if (tranche == TRANCHE_Q) {
            return allowanceQ;
        } else if (tranche == TRANCHE_B) {
            return allowanceB;
        } else {
            return allowanceR;
        }
    }

    function trancheAllowanceVersion(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowanceVersions[owner][spender];
    }

    function trancheTransfer(
        uint256 tranche,
        address recipient,
        uint256 amount,
        uint256 version
    ) external override onlyCurrentVersion(version) {
        _refreshBalance(msg.sender, version);
        _refreshBalance(recipient, version);
        _transfer(tranche, msg.sender, recipient, amount);
    }

    function trancheTransferFrom(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount,
        uint256 version
    ) external override onlyCurrentVersion(version) {
        _refreshAllowance(sender, msg.sender, version);
        uint256 newAllowance =
            _allowances[sender][msg.sender][tranche].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            );
        _approve(tranche, sender, msg.sender, newAllowance);
        _refreshBalance(sender, version);
        _refreshBalance(recipient, version);
        _transfer(tranche, sender, recipient, amount);
    }

    function trancheApprove(
        uint256 tranche,
        address spender,
        uint256 amount,
        uint256 version
    ) external override onlyCurrentVersion(version) {
        _refreshAllowance(msg.sender, spender, version);
        _approve(tranche, msg.sender, spender, amount);
    }

    function trancheTotalSupply(uint256 tranche) external view override returns (uint256) {
        return _totalSupplies[tranche];
    }

    function primaryMarketMint(
        uint256 tranche,
        address account,
        uint256 amount,
        uint256 version
    ) external override onlyPrimaryMarket onlyCurrentVersion(version) {
        _refreshBalance(account, version);
        _mint(tranche, account, amount);
    }

    function primaryMarketBurn(
        uint256 tranche,
        address account,
        uint256 amount,
        uint256 version
    ) external override onlyPrimaryMarket onlyCurrentVersion(version) {
        _refreshBalance(account, version);
        _burn(tranche, account, amount);
    }

    function shareTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) public override {
        uint256 tranche = _getTranche(msg.sender);
        if (tranche != TRANCHE_Q) {
            require(isFundActive(block.timestamp), "Transfer is inactive");
        }
        _refreshBalance(sender, _rebalanceSize);
        _refreshBalance(recipient, _rebalanceSize);
        _transfer(tranche, sender, recipient, amount);
    }

    function shareTransferFrom(
        address spender,
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (uint256 newAllowance) {
        uint256 tranche = _getTranche(msg.sender);
        shareTransfer(sender, recipient, amount);
        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].sub(
            amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(tranche, sender, spender, newAllowance);
    }

    function shareApprove(
        address owner,
        address spender,
        uint256 amount
    ) external override {
        uint256 tranche = _getTranche(msg.sender);
        _refreshAllowance(owner, spender, _rebalanceSize);
        _approve(tranche, owner, spender, amount);
    }

    function shareIncreaseAllowance(
        address sender,
        address spender,
        uint256 addedValue
    ) external override returns (uint256 newAllowance) {
        uint256 tranche = _getTranche(msg.sender);
        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].add(addedValue);
        _approve(tranche, sender, spender, newAllowance);
    }

    function shareDecreaseAllowance(
        address sender,
        address spender,
        uint256 subtractedValue
    ) external override returns (uint256 newAllowance) {
        uint256 tranche = _getTranche(msg.sender);
        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].sub(subtractedValue);
        _approve(tranche, sender, spender, newAllowance);
    }

    function _transfer(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender][tranche] = _balances[sender][tranche].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient][tranche] = _balances[recipient][tranche].add(amount);
        IShareV2(_getShare(tranche)).fundEmitTransfer(sender, recipient, amount);
    }

    function _mint(
        uint256 tranche,
        address account,
        uint256 amount
    ) private {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupplies[tranche] = _totalSupplies[tranche].add(amount);
        _balances[account][tranche] = _balances[account][tranche].add(amount);
        IShareV2(_getShare(tranche)).fundEmitTransfer(address(0), account, amount);
    }

    function _burn(
        uint256 tranche,
        address account,
        uint256 amount
    ) private {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account][tranche] = _balances[account][tranche].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        IShareV2(_getShare(tranche)).fundEmitTransfer(account, address(0), amount);
    }

    function _approve(
        uint256 tranche,
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender][tranche] = amount;
        IShareV2(_getShare(tranche)).fundEmitApproval(owner, spender, amount);
    }

    /// @notice Settle the current trading day. Settlement includes the following changes
    ///         to the fund.
    ///
    ///         1. Charge protocol fee of the day.
    ///         2. Settle all pending creations and redemptions from the primary market.
    ///         3. Calculate NAV of the day and trigger rebalance if necessary.
    ///         4. Capture new interest rate for BISHOP.
    function settle() external nonReentrant {
        uint256 day = currentDay;
        require(day != 0, "Not initialized");
        require(block.timestamp >= day, "The current trading day does not end yet");
        uint256 price = twapOracle.getTwap(day);
        require(price != 0, "Underlying price for settlement is not ready yet");

        _collectFee();

        IPrimaryMarketV3(_primaryMarket).settle(day);

        _payFeeDebt();

        // Calculate NAV
        uint256 equivalentTotalB = getEquivalentTotalB();
        uint256 underlying = getTotalUnderlying();
        (uint256 navSum, uint256 navB, uint256 navR) =
            _extrapolateNav(day, day - 1 days, price, equivalentTotalB, underlying);

        if (_shouldTriggerRebalance(navB, navR)) {
            uint256 newSplitRatio = splitRatio.multiplyDecimal(navSum) / 2;
            _triggerRebalance(day, navSum, navB, navR, newSplitRatio);
            navB = UNIT;
            navR = UNIT;
            equivalentTotalB = getEquivalentTotalB();
            fundActivityStartTime = day + activityDelayTimeAfterRebalance;
        } else {
            fundActivityStartTime = day;
        }

        uint256 interestRate = _updateInterestRate(day);
        historicalInterestRate[day] = interestRate;

        historicalEquivalentTotalB[day] = equivalentTotalB;
        historicalUnderlying[day] = underlying;
        _historicalNavB[day] = navB;
        _historicalNavR[day] = navR;
        currentDay = day + 1 days;

        emit Settled(day, navB, navR, interestRate);
    }

    function transferToStrategy(uint256 amount) external override onlyStrategy {
        _strategyUnderlying = _strategyUnderlying.add(amount);
        IERC20(tokenUnderlying).safeTransfer(_strategy, amount);
    }

    function transferFromStrategy(uint256 amount) external override onlyStrategy {
        _strategyUnderlying = _strategyUnderlying.sub(amount);
        IERC20(tokenUnderlying).safeTransferFrom(_strategy, address(this), amount);
        _payFeeDebt();
    }

    function primaryMarketTransferUnderlying(
        address recipient,
        uint256 amount,
        uint256 fee
    ) external override onlyPrimaryMarket {
        IERC20(tokenUnderlying).safeTransfer(recipient, amount);
        feeDebt = feeDebt.add(fee);
        _updateTotalDebt(_totalDebt.add(fee));
    }

    function primaryMarketAddDebt(uint256 amount, uint256 fee) external override onlyPrimaryMarket {
        redemptionDebt = redemptionDebt.add(amount);
        feeDebt = feeDebt.add(fee);
        _updateTotalDebt(_totalDebt.add(amount).add(fee));
    }

    function primaryMarketPayDebt(uint256 amount) external override onlyPrimaryMarket {
        redemptionDebt = redemptionDebt.sub(amount);
        _updateTotalDebt(_totalDebt.sub(amount));
        IERC20(tokenUnderlying).safeTransfer(msg.sender, amount);
    }

    function reportProfit(uint256 profit, uint256 performanceFee) external override onlyStrategy {
        require(profit >= performanceFee, "Performance fee cannot exceed profit");
        _strategyUnderlying = _strategyUnderlying.add(profit);
        feeDebt = feeDebt.add(performanceFee);
        _updateTotalDebt(_totalDebt.add(performanceFee));
        emit ProfitReported(profit, performanceFee);
    }

    function reportLoss(uint256 loss) external override onlyStrategy {
        _strategyUnderlying = _strategyUnderlying.sub(loss);
        emit LossReported(loss);
    }

    function proposePrimaryMarketUpdate(address newPrimaryMarket) external onlyOwner {
        _proposePrimaryMarketUpdate(newPrimaryMarket);
    }

    function applyPrimaryMarketUpdate(address newPrimaryMarket) external onlyOwner {
        require(
            IPrimaryMarketV3(_primaryMarket).canBeRemovedFromFund(),
            "Cannot update primary market"
        );
        _applyPrimaryMarketUpdate(newPrimaryMarket);
    }

    function proposeStrategyUpdate(address newStrategy) external onlyOwner {
        _proposeStrategyUpdate(newStrategy);
    }

    function applyStrategyUpdate(address newStrategy) external onlyOwner {
        require(_totalDebt == 0, "Cannot update strategy with debt");
        _applyStrategyUpdate(newStrategy);
    }

    function _updateDailyProtocolFeeRate(uint256 newDailyProtocolFeeRate) private {
        require(
            newDailyProtocolFeeRate <= MAX_DAILY_PROTOCOL_FEE_RATE,
            "Exceed max protocol fee rate"
        );
        dailyProtocolFeeRate = newDailyProtocolFeeRate;
        emit DailyProtocolFeeRateUpdated(newDailyProtocolFeeRate);
    }

    function updateDailyProtocolFeeRate(uint256 newDailyProtocolFeeRate) external onlyOwner {
        _updateDailyProtocolFeeRate(newDailyProtocolFeeRate);
    }

    function _updateTwapOracle(address newTwapOracle) private {
        twapOracle = ITwapOracleV2(newTwapOracle);
        emit TwapOracleUpdated(newTwapOracle);
    }

    function updateTwapOracle(address newTwapOracle) external onlyOwner {
        _updateTwapOracle(newTwapOracle);
    }

    function _updateAprOracle(address newAprOracle) private {
        aprOracle = IAprOracle(newAprOracle);
        emit AprOracleUpdated(newAprOracle);
    }

    function updateAprOracle(address newAprOracle) external onlyOwner {
        _updateAprOracle(newAprOracle);
    }

    function _updateBallot(address newBallot) private {
        ballot = IBallot(newBallot);
        emit BallotUpdated(newBallot);
    }

    function updateBallot(address newBallot) external onlyOwner {
        _updateBallot(newBallot);
    }

    function _updateFeeCollector(address newFeeCollector) private {
        feeCollector = newFeeCollector;
        emit FeeCollectorUpdated(newFeeCollector);
    }

    function updateFeeCollector(address newFeeCollector) external onlyOwner {
        _updateFeeCollector(newFeeCollector);
    }

    function _updateActivityDelayTime(uint256 delayTime) private {
        require(
            delayTime >= 30 minutes && delayTime <= 12 hours,
            "Exceed allowed delay time range"
        );
        activityDelayTimeAfterRebalance = delayTime;
        emit ActivityDelayTimeUpdated(delayTime);
    }

    function updateActivityDelayTime(uint256 delayTime) external onlyOwner {
        _updateActivityDelayTime(delayTime);
    }

    /// @dev Transfer protocol fee of the current trading day to the fee collector.
    ///      This function should be called before creation and redemption on the same day
    ///      are settled.
    function _collectFee() private {
        uint256 currentUnderlying = getTotalUnderlying();
        uint256 fee = currentUnderlying.multiplyDecimal(dailyProtocolFeeRate);
        if (fee > 0) {
            feeDebt = feeDebt.add(fee);
            _updateTotalDebt(_totalDebt.add(fee));
        }
    }

    function _payFeeDebt() private {
        uint256 total = _totalDebt;
        if (total == 0) {
            return;
        }
        uint256 hot = IERC20(tokenUnderlying).balanceOf(address(this));
        if (hot == 0) {
            return;
        }
        uint256 fee = feeDebt;
        if (fee > 0) {
            uint256 amount = hot.min(fee);
            feeDebt = fee - amount;
            _updateTotalDebt(total - amount);
            // Call `feeCollector.checkpoint()` without errors.
            // This is a intended behavior because `feeCollector` may not have `checkpoint()`.
            (bool success, ) = feeCollector.call(abi.encodeWithSignature("checkpoint()"));
            if (!success) {
                // ignore
            }
            IERC20(tokenUnderlying).safeTransfer(feeCollector, amount);
            emit FeeDebtPaid(amount);
        }
    }

    /// @dev Check whether a new rebalance should be triggered. Rebalance is triggered if
    ///      ROOK's NAV over BISHOP's NAV is greater than the upper threshold or
    ///      less than the lower threshold.
    /// @param navB BISHOP's NAV before the rebalance
    /// @param navROrZero ROOK's NAV before the rebalance or zero if the NAV is negative
    /// @return Whether a new rebalance should be triggered
    function _shouldTriggerRebalance(uint256 navB, uint256 navROrZero) private view returns (bool) {
        uint256 rOverB = navROrZero.divideDecimal(navB);
        return rOverB < lowerRebalanceThreshold || rOverB > upperRebalanceThreshold;
    }

    /// @dev Create a new rebalance that resets NAV of all tranches to 1. Total supplies are
    ///      rebalanced immediately.
    /// @param day Trading day that triggers this rebalance
    /// @param navSum Sum of BISHOP and ROOK's NAV
    /// @param navB BISHOP's NAV before this rebalance
    /// @param navROrZero ROOK's NAV before this rebalance or zero if the NAV is negative
    /// @param newSplitRatio The new split ratio after this rebalance
    function _triggerRebalance(
        uint256 day,
        uint256 navSum,
        uint256 navB,
        uint256 navROrZero,
        uint256 newSplitRatio
    ) private {
        Rebalance memory rebalance = _calculateRebalance(navSum, navB, navROrZero, newSplitRatio);
        uint256 oldSize = _rebalanceSize;
        splitRatio = newSplitRatio;
        _historicalSplitRatio[oldSize + 1] = newSplitRatio;
        emit SplitRatioUpdated(newSplitRatio);
        _rebalances[oldSize] = rebalance;
        _rebalanceSize = oldSize + 1;
        emit RebalanceTriggered(
            oldSize,
            day,
            navSum,
            navB,
            navROrZero,
            rebalance.ratioB2Q,
            rebalance.ratioR2Q,
            rebalance.ratioBR
        );

        (
            _totalSupplies[TRANCHE_Q],
            _totalSupplies[TRANCHE_B],
            _totalSupplies[TRANCHE_R]
        ) = doRebalance(
            _totalSupplies[TRANCHE_Q],
            _totalSupplies[TRANCHE_B],
            _totalSupplies[TRANCHE_R],
            oldSize
        );
        _refreshBalance(address(this), oldSize + 1);
    }

    /// @dev Create a new rebalance matrix that resets given NAVs to (1, 1).
    ///
    ///      Note that ROOK's NAV can be negative before the rebalance when the underlying price
    ///      drops dramatically in a single trading day, in which case zero should be passed to
    ///      this function instead of the negative NAV.
    /// @param navSum Sum of BISHOP and ROOK's NAV
    /// @param navB BISHOP's NAV before the rebalance
    /// @param navROrZero ROOK's NAV before the rebalance or zero if the NAV is negative
    /// @param newSplitRatio The new split ratio after this rebalance
    /// @return The rebalance matrix
    function _calculateRebalance(
        uint256 navSum,
        uint256 navB,
        uint256 navROrZero,
        uint256 newSplitRatio
    ) private view returns (Rebalance memory) {
        uint256 ratioBR;
        uint256 ratioB2Q;
        uint256 ratioR2Q;
        if (navROrZero <= navB) {
            // Lower rebalance
            ratioBR = navROrZero;
            ratioB2Q = (navSum / 2 - navROrZero).divideDecimal(newSplitRatio);
            ratioR2Q = 0;
        } else {
            // Upper rebalance
            ratioBR = UNIT;
            ratioB2Q = (navB - UNIT).divideDecimal(newSplitRatio) / 2;
            ratioR2Q = (navROrZero - UNIT).divideDecimal(newSplitRatio) / 2;
        }
        return
            Rebalance({
                ratioB2Q: ratioB2Q,
                ratioR2Q: ratioR2Q,
                ratioBR: ratioBR,
                timestamp: block.timestamp
            });
    }

    function _updateInterestRate(uint256 week) private returns (uint256) {
        uint256 baseInterestRate = MAX_INTEREST_RATE.min(aprOracle.capture());
        uint256 floatingInterestRate = ballot.count(week).div(365);
        uint256 rate = baseInterestRate.add(floatingInterestRate);

        emit InterestRateUpdated(baseInterestRate, floatingInterestRate);

        return rate;
    }

    function _updateTotalDebt(uint256 newTotalDebt) private {
        _totalDebt = newTotalDebt;
        emit TotalDebtUpdated(newTotalDebt);
    }

    /// @dev Transform share balance to a given rebalance version, or to the latest version
    ///      if `targetVersion` is zero. This function does no bound check on `targetVersion`.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function _refreshBalance(address account, uint256 targetVersion) private {
        if (targetVersion == 0) {
            targetVersion = _rebalanceSize;
        }
        uint256 oldVersion = _balanceVersions[account];
        if (oldVersion >= targetVersion) {
            return;
        }

        uint256[TRANCHE_COUNT] storage balanceTuple = _balances[account];
        uint256 balanceQ = balanceTuple[TRANCHE_Q];
        uint256 balanceB = balanceTuple[TRANCHE_B];
        uint256 balanceR = balanceTuple[TRANCHE_R];
        _balanceVersions[account] = targetVersion;

        if (balanceQ == 0 && balanceB == 0 && balanceR == 0) {
            // Fast path for an empty account
            return;
        }

        for (uint256 i = oldVersion; i < targetVersion; i++) {
            (balanceQ, balanceB, balanceR) = doRebalance(balanceQ, balanceB, balanceR, i);
        }
        balanceTuple[TRANCHE_Q] = balanceQ;
        balanceTuple[TRANCHE_B] = balanceB;
        balanceTuple[TRANCHE_R] = balanceR;

        emit BalancesRebalanced(account, targetVersion, balanceQ, balanceB, balanceR);
    }

    /// @dev Transform allowance to a given rebalance version, or to the latest version
    ///      if `targetVersion` is zero. This function does no bound check on `targetVersion`.
    /// @param owner Owner of the allowance to rebalance
    /// @param spender Spender of the allowance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function _refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) private {
        if (targetVersion == 0) {
            targetVersion = _rebalanceSize;
        }
        uint256 oldVersion = _allowanceVersions[owner][spender];
        if (oldVersion >= targetVersion) {
            return;
        }

        uint256[TRANCHE_COUNT] storage allowanceTuple = _allowances[owner][spender];
        uint256 allowanceQ = allowanceTuple[TRANCHE_Q];
        uint256 allowanceB = allowanceTuple[TRANCHE_B];
        uint256 allowanceR = allowanceTuple[TRANCHE_R];
        _allowanceVersions[owner][spender] = targetVersion;

        if (allowanceQ == 0 && allowanceB == 0 && allowanceR == 0) {
            // Fast path for an empty allowance
            return;
        }

        for (uint256 i = oldVersion; i < targetVersion; i++) {
            (allowanceQ, allowanceB, allowanceR) = _rebalanceAllowance(
                allowanceQ,
                allowanceB,
                allowanceR,
                i
            );
        }
        allowanceTuple[TRANCHE_Q] = allowanceQ;
        allowanceTuple[TRANCHE_B] = allowanceB;
        allowanceTuple[TRANCHE_R] = allowanceR;

        emit AllowancesRebalanced(
            owner,
            spender,
            targetVersion,
            allowanceQ,
            allowanceB,
            allowanceR
        );
    }

    function _rebalanceAllowance(
        uint256 allowanceQ,
        uint256 allowanceB,
        uint256 allowanceR,
        uint256 index
    )
        private
        view
        returns (
            uint256 newAllowanceQ,
            uint256 newAllowanceB,
            uint256 newAllowanceR
        )
    {
        Rebalance storage rebalance = _rebalances[index];

        /// @dev using saturating arithmetic to avoid unconscious overflow revert
        newAllowanceQ = allowanceQ;
        newAllowanceB = allowanceB.saturatingMultiplyDecimal(rebalance.ratioBR);
        newAllowanceR = allowanceR.saturatingMultiplyDecimal(rebalance.ratioBR);
    }

    modifier onlyCurrentVersion(uint256 version) {
        require(_rebalanceSize == version, "Only current version");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

library SafeDecimalMath {
    using SafeMath for uint256;

    /* Number of decimal places in the representations. */
    uint256 private constant decimals = 18;
    uint256 private constant highPrecisionDecimals = 27;

    /* The number representing 1.0. */
    uint256 private constant UNIT = 10**uint256(decimals);

    /* The number representing 1.0 for higher fidelity numbers. */
    uint256 private constant PRECISE_UNIT = 10**uint256(highPrecisionDecimals);
    uint256 private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR =
        10**uint256(highPrecisionDecimals - decimals);

    /**
     * @return The result of multiplying x and y, interpreting the operands as fixed-point
     * decimals.
     *
     * @dev A unit factor is divided out after the product of x and y is evaluated,
     * so that product must be less than 2**256. As this is an integer division,
     * the internal division always rounds down. This helps save on gas. Rounding
     * is more expensive on gas.
     */
    function multiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y).div(UNIT);
    }

    function multiplyDecimalPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y).div(PRECISE_UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is a high
     * precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and UNIT must be less than 2**256. As
     * this is an integer division, the result is always rounded down.
     * This helps save on gas. Rounding is more expensive on gas.
     */
    function divideDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(UNIT).div(y);
    }

    function divideDecimalPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(PRECISE_UNIT).div(y);
    }

    /**
     * @dev Convert a standard decimal representation to a high precision one.
     */
    function decimalToPreciseDecimal(uint256 i) internal pure returns (uint256) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    /**
     * @dev Convert a high precision decimal to a standard decimal representation.
     */
    function preciseDecimalToDecimal(uint256 i) internal pure returns (uint256) {
        uint256 quotientTimesTen = i.mul(10).div(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen = quotientTimesTen.add(10);
        }

        return quotientTimesTen.div(10);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, and the max value of
     * uint256 on overflow.
     */
    function saturatingMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c / a != b ? type(uint256).max : c;
    }

    function saturatingMultiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return saturatingMul(x, y).div(UNIT);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

abstract contract CoreUtility {
    using SafeMath for uint256;

    /// @dev UTC time of a day when the fund settles.
    uint256 internal constant SETTLEMENT_TIME = 14 hours;

    /// @dev Return end timestamp of the trading week containing a given timestamp.
    ///
    ///      A trading week starts at UTC time `SETTLEMENT_TIME` on a Thursday (inclusive)
    ///      and ends at the same time of the next Thursday (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading week.
    function _endOfWeek(uint256 timestamp) internal pure returns (uint256) {
        return ((timestamp.add(1 weeks) - SETTLEMENT_TIME) / 1 weeks) * 1 weeks + SETTLEMENT_TIME;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./IFundV3.sol";

interface IPrimaryMarketV3 {
    function fund() external view returns (IFundV3);

    function getCreation(uint256 underlying) external view returns (uint256 outQ);

    function getCreationForQ(uint256 minOutQ) external view returns (uint256 underlying);

    function getRedemption(uint256 inQ) external view returns (uint256 underlying, uint256 fee);

    function getRedemptionForUnderlying(uint256 minUnderlying) external view returns (uint256 inQ);

    function getSplit(uint256 inQ) external view returns (uint256 outB);

    function getSplitForB(uint256 minOutB) external view returns (uint256 inQ);

    function getMerge(uint256 inB) external view returns (uint256 outQ, uint256 feeQ);

    function getMergeForQ(uint256 minOutQ) external view returns (uint256 inB);

    function canBeRemovedFromFund() external view returns (bool);

    function create(
        address recipient,
        uint256 minOutQ,
        uint256 version
    ) external returns (uint256 outQ);

    function redeem(
        address recipient,
        uint256 inQ,
        uint256 minUnderlying,
        uint256 version
    ) external returns (uint256 underlying);

    function redeemAndUnwrap(
        address recipient,
        uint256 inQ,
        uint256 minUnderlying,
        uint256 version
    ) external returns (uint256 underlying);

    function queueRedemption(
        address recipient,
        uint256 inQ,
        uint256 minUnderlying,
        uint256 version
    ) external returns (uint256 underlying, uint256 index);

    function claimRedemptions(address account, uint256[] calldata indices)
        external
        returns (uint256 underlying);

    function claimRedemptionsAndUnwrap(address account, uint256[] calldata indices)
        external
        returns (uint256 underlying);

    function split(
        address recipient,
        uint256 inQ,
        uint256 version
    ) external returns (uint256 outB);

    function merge(
        address recipient,
        uint256 inB,
        uint256 version
    ) external returns (uint256 outQ);

    function settle(uint256 day) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "./ITwapOracleV2.sol";

interface IFundV3 {
    /// @notice A linear transformation matrix that represents a rebalance.
    ///
    ///         ```
    ///             [        1        0        0 ]
    ///         R = [ ratioB2Q  ratioBR        0 ]
    ///             [ ratioR2Q        0  ratioBR ]
    ///         ```
    ///
    ///         Amounts of the three tranches `q`, `b` and `r` can be rebalanced by multiplying the matrix:
    ///
    ///         ```
    ///         [ q', b', r' ] = [ q, b, r ] * R
    ///         ```
    struct Rebalance {
        uint256 ratioB2Q;
        uint256 ratioR2Q;
        uint256 ratioBR;
        uint256 timestamp;
    }

    function tokenUnderlying() external view returns (address);

    function tokenQ() external view returns (address);

    function tokenB() external view returns (address);

    function tokenR() external view returns (address);

    function tokenShare(uint256 tranche) external view returns (address);

    function primaryMarket() external view returns (address);

    function primaryMarketUpdateProposal() external view returns (address, uint256);

    function strategy() external view returns (address);

    function strategyUpdateProposal() external view returns (address, uint256);

    function underlyingDecimalMultiplier() external view returns (uint256);

    function twapOracle() external view returns (ITwapOracleV2);

    function feeCollector() external view returns (address);

    function endOfDay(uint256 timestamp) external pure returns (uint256);

    function trancheTotalSupply(uint256 tranche) external view returns (uint256);

    function trancheBalanceOf(uint256 tranche, address account) external view returns (uint256);

    function trancheAllBalanceOf(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function trancheBalanceVersion(address account) external view returns (uint256);

    function trancheAllowance(
        uint256 tranche,
        address owner,
        address spender
    ) external view returns (uint256);

    function trancheAllowanceVersion(address owner, address spender)
        external
        view
        returns (uint256);

    function trancheTransfer(
        uint256 tranche,
        address recipient,
        uint256 amount,
        uint256 version
    ) external;

    function trancheTransferFrom(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount,
        uint256 version
    ) external;

    function trancheApprove(
        uint256 tranche,
        address spender,
        uint256 amount,
        uint256 version
    ) external;

    function getRebalanceSize() external view returns (uint256);

    function getRebalance(uint256 index) external view returns (Rebalance memory);

    function getRebalanceTimestamp(uint256 index) external view returns (uint256);

    function currentDay() external view returns (uint256);

    function splitRatio() external view returns (uint256);

    function historicalSplitRatio(uint256 version) external view returns (uint256);

    function fundActivityStartTime() external view returns (uint256);

    function isFundActive(uint256 timestamp) external view returns (bool);

    function getEquivalentTotalB() external view returns (uint256);

    function getEquivalentTotalQ() external view returns (uint256);

    function historicalEquivalentTotalB(uint256 timestamp) external view returns (uint256);

    function historicalNavs(uint256 timestamp) external view returns (uint256 navB, uint256 navR);

    function extrapolateNav(uint256 price)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function doRebalance(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 index
    )
        external
        view
        returns (
            uint256 newAmountQ,
            uint256 newAmountB,
            uint256 newAmountR
        );

    function batchRebalance(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 fromIndex,
        uint256 toIndex
    )
        external
        view
        returns (
            uint256 newAmountQ,
            uint256 newAmountB,
            uint256 newAmountR
        );

    function refreshBalance(address account, uint256 targetVersion) external;

    function refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) external;

    function primaryMarketMint(
        uint256 tranche,
        address account,
        uint256 amount,
        uint256 version
    ) external;

    function primaryMarketBurn(
        uint256 tranche,
        address account,
        uint256 amount,
        uint256 version
    ) external;

    function shareTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function shareTransferFrom(
        address spender,
        address sender,
        address recipient,
        uint256 amount
    ) external returns (uint256 newAllowance);

    function shareIncreaseAllowance(
        address sender,
        address spender,
        uint256 addedValue
    ) external returns (uint256 newAllowance);

    function shareDecreaseAllowance(
        address sender,
        address spender,
        uint256 subtractedValue
    ) external returns (uint256 newAllowance);

    function shareApprove(
        address owner,
        address spender,
        uint256 amount
    ) external;

    function historicalUnderlying(uint256 timestamp) external view returns (uint256);

    function getTotalUnderlying() external view returns (uint256);

    function getStrategyUnderlying() external view returns (uint256);

    function getTotalDebt() external view returns (uint256);

    function transferToStrategy(uint256 amount) external;

    function transferFromStrategy(uint256 amount) external;

    function reportProfit(uint256 profit, uint256 performanceFee) external;

    function reportLoss(uint256 loss) external;

    function primaryMarketTransferUnderlying(
        address recipient,
        uint256 amount,
        uint256 fee
    ) external;

    function primaryMarketAddDebt(uint256 amount, uint256 fee) external;

    function primaryMarketPayDebt(uint256 amount) external;

    event RebalanceTriggered(
        uint256 indexed index,
        uint256 indexed day,
        uint256 navSum,
        uint256 navB,
        uint256 navROrZero,
        uint256 ratioB2Q,
        uint256 ratioR2Q,
        uint256 ratioBR
    );
    event Settled(uint256 indexed day, uint256 navB, uint256 navR, uint256 interestRate);
    event InterestRateUpdated(uint256 baseInterestRate, uint256 floatingInterestRate);
    event BalancesRebalanced(
        address indexed account,
        uint256 version,
        uint256 balanceQ,
        uint256 balanceB,
        uint256 balanceR
    );
    event AllowancesRebalanced(
        address indexed owner,
        address indexed spender,
        uint256 version,
        uint256 allowanceQ,
        uint256 allowanceB,
        uint256 allowanceR
    );
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IShareV2 is IERC20 {
    function fundEmitTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function fundEmitApproval(
        address owner,
        address spender,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./ITwapOracle.sol";

interface ITwapOracleV2 is ITwapOracle {
    function getLatest() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface IAprOracle {
    function capture() external returns (uint256 dailyRate);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface IBallot {
    struct Voter {
        uint256 amount;
        uint256 unlockTime;
        uint256 weight;
    }

    function count(uint256 timestamp) external view returns (uint256);

    function syncWithVotingEscrow(address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

interface IVotingEscrow {
    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }

    function token() external view returns (address);

    function maxTime() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOfAtTimestamp(address account, uint256 timestamp)
        external
        view
        returns (uint256);

    function getTimestampDropBelow(address account, uint256 threshold)
        external
        view
        returns (uint256);

    function getLockedBalance(address account) external view returns (LockedBalance memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface ITwapOracle {
    enum UpdateType {PRIMARY, SECONDARY, OWNER, CHAINLINK, UNISWAP_V2}

    function getTwap(uint256 timestamp) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/CoreUtility.sol";
import "../interfaces/IFundV2.sol";
import "../../fund/FundV3.sol";
import "../../fund/ShareStaking.sol";
import "../interfaces/IPrimaryMarketV2.sol";
import "../../interfaces/ITwapOracle.sol";
import "../../interfaces/IAprOracle.sol";
import "../../interfaces/IBallot.sol";
import "../interfaces/ITrancheIndex.sol";

interface IOldExchange {
    function protocolUpgrade(address account)
        external
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 claimedRewards
        );
}

interface IDailyProtocolFeeRate {
    function dailyProtocolFeeRate() external view returns (uint256);
}

/// @notice This is the core contract for the upgrade to Tranchess V2. It replaces the following
///         contracts of the Tranchess protocol during the upgrade process:
///
///         * TwapOracle of the old Fund
///         * PrimaryMarket of the old Fund
///         * PrimaryMarket of the new Fund
/// @dev The upgrade procedure consists of the following stages:
///
///      *STAGE_START*. The owner of the old Fund changes both primary market and TWAP oracle
///      to this contract. As a primary market, it records the old tranche tokens' total supplies
///      and asks the old Fund to transfer all underlying tokens but one unit to this contract when
///      the old Fund settles. As a TWAP oracle, it returns a special value to ensure the total value
///      of the old Fund does not change after almost all underlying tokens are transferred out,
///      so that no rebalance is triggered.
///
///      * Change Fund's primary market to this contract
contract UpgradeTool is
    ITwapOracle,
    IAprOracle,
    IBallot,
    IPrimaryMarketV2,
    ITrancheIndex,
    CoreUtility,
    Ownable
{
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event Upgraded(
        address account,
        uint256 oldM,
        uint256 oldA,
        uint256 oldB,
        uint256 newM,
        uint256 newA,
        uint256 newB,
        uint256 claimedRewards
    );

    uint256 private constant STAGE_START = 0;
    uint256 private constant STAGE_SETTLED = 1;
    uint256 private constant STAGE_UPGRADED = 2;

    IFund public immutable oldFund;
    ITwapOracle public immutable originTwapOracle;
    IERC20 public immutable tokenUnderlying;
    IERC20 public immutable oldTokenM;
    IERC20 public immutable oldTokenA;
    IERC20 public immutable oldTokenB;
    uint256 public immutable oldFundVersion;

    IOldExchange public immutable oldExchange;

    FundV3 public immutable newFund;
    ShareStaking public immutable newStaking;

    uint256 public immutable upgradeTimestamp;

    uint256 public stage;

    /// @notice Total amount of underlying tokens managed by the old Fund right before this upgrade.
    uint256 public upgradeUnderlying;

    /// @notice Initial split ratio of the new Fund.
    uint256 public initialSplitRatio;

    constructor(
        address oldFund_,
        uint256 oldFundVersion_,
        address oldExchange_,
        address newFund_,
        address newStaking_,
        uint256 upgradeTimestamp_
    ) public {
        oldFund = IFund(oldFund_);
        originTwapOracle = ITwapOracle(IFund(oldFund_).twapOracle());
        tokenUnderlying = IERC20(IFund(oldFund_).tokenUnderlying());
        oldTokenM = IERC20(IFund(oldFund_).tokenM());
        oldTokenA = IERC20(IFund(oldFund_).tokenA());
        oldTokenB = IERC20(IFund(oldFund_).tokenB());
        oldFundVersion = oldFundVersion_;

        oldExchange = IOldExchange(oldExchange_);

        newFund = FundV3(newFund_);
        require(IFund(oldFund_).tokenUnderlying() == IFund(newFund_).tokenUnderlying());
        newStaking = ShareStaking(newStaking_);
        require(address(ShareStaking(newStaking_).fund()) == newFund_);

        require(upgradeTimestamp_ + 1 weeks == _endOfWeek(upgradeTimestamp_));
        upgradeTimestamp = upgradeTimestamp_;
    }

    modifier onlyStage(uint256 expectedStage) {
        require(stage == expectedStage, "Incorrect stage");
        _;
    }

    /// @dev This is used by 3rd-party tools to calculate TVL in the SETTLED stage.
    function currentCreatingUnderlying() external view returns (uint256) {
        return
            stage <= STAGE_SETTLED ? upgradeUnderlying : tokenUnderlying.balanceOf(address(this));
    }

    /// @notice As a special TWAP oracle of the old Fund, it returns the same value as the original
    ///         oracle before the protocol upgrade. After the upgrade, it constantly returns the
    ///         total value of the Fund at the time of the upgrade, which keeps NAV of the Fund
    ///         constant forever.
    function getTwap(uint256 timestamp) external view override returns (uint256) {
        if (timestamp < upgradeTimestamp) {
            return originTwapOracle.getTwap(timestamp);
        } else {
            uint256 underlying = upgradeUnderlying;
            if (underlying == 0) {
                // We are in stage STAGE_START and all underlying tokens are still in the old Fund.
                underlying = oldFundVersion == 2
                    ? IFundV2(address(oldFund)).getTotalUnderlying()
                    : tokenUnderlying.balanceOf(address(oldFund));
                uint256 protocolFee =
                    underlying.multiplyDecimal(
                        IDailyProtocolFeeRate(address(oldFund)).dailyProtocolFeeRate()
                    );
                underlying = underlying.sub(protocolFee);
            }
            return originTwapOracle.getTwap(upgradeTimestamp).mul(underlying);
        }
    }

    /// @notice As a special APR oracle of the old Fund, it always returns zero to keep
    ///         Tranche A's NAV unchanged.
    function capture() external override returns (uint256) {
        return 0;
    }

    /// @notice As a special interest rate ballot of the old Fund, it always returns zero to keep
    ///         Tranche A's NAV unchanged.
    function count(uint256) external view override returns (uint256) {
        return 0;
    }

    /// @dev For IBallot.
    function syncWithVotingEscrow(address account) external override {}

    /// @dev For IPrimaryMarketV2.
    function claim(address) external override returns (uint256, uint256) {
        revert("Not allowed");
    }

    /// @dev For IPrimaryMarketV2.
    function claimAndUnwrap(address) external override returns (uint256, uint256) {
        revert("Not allowed");
    }

    /// @dev For IPrimaryMarketV2.
    function updateDelayedRedemptionDay() external override {}

    /// @dev For IPrimaryMarketV3.
    function canBeRemovedFromFund() external view returns (bool) {
        return stage == STAGE_UPGRADED;
    }

    /// @dev For IPrimaryMarketV3.
    function settle(uint256) external {}

    function settle(
        uint256 day,
        uint256, // fundTotalShares
        uint256 fundUnderlying,
        uint256, // underlyingPrice
        uint256 // previousNav
    )
        external
        override
        returns (
            uint256 sharesToMint,
            uint256 sharesToBurn,
            uint256 creationUnderlying,
            uint256 redemptionUnderlying,
            uint256 fee
        )
    {
        require(oldFund.twapOracle() == this, "Not TWAP oracle of the old fund");
        require(msg.sender == address(oldFund), "Only old fund");
        if (day < upgradeTimestamp) {
            return (0, 0, 0, 0, 0);
        }
        if (stage == STAGE_START) {
            upgradeUnderlying = fundUnderlying;
            stage = STAGE_SETTLED;
        }

        // Fetch all but 1 unit of underlying tokens from the Fund. This guarantees that there's
        // only 1 unit of underlying token left in the old Fund at each settlement after the upgrade,
        // so that the NAVs remain the same and no rebalance will be triggered. In case that someone
        // transfers underlying tokens directly to the old Fund, these tokens will be transferred to
        // and forever locked in this contract.
        redemptionUnderlying = fundUnderlying.sub(1);
    }

    /// @notice Transfer all underlying tokens to the new Fund and mint all new tranche tokens.
    ///         When this function is called, this contract should be the primary market of the
    ///         new Fund and the new Fund should be empty.
    function createNewTokens() external onlyOwner onlyStage(STAGE_SETTLED) {
        (, uint256 navA, uint256 navB) = oldFund.historicalNavs(upgradeTimestamp);
        uint256 splitRatio =
            originTwapOracle.getTwap(upgradeTimestamp).divideDecimal(navA.add(navB));
        initialSplitRatio = splitRatio;
        uint256 hotBalance = tokenUnderlying.balanceOf(address(this));
        newFund.initialize(splitRatio, navA, navB, upgradeUnderlying.sub(hotBalance));
        newFund.transferOwnership(owner());

        tokenUnderlying.safeTransfer(address(newFund), hotBalance);
        newFund.primaryMarketMint(
            TRANCHE_M,
            address(this),
            oldFund.shareTotalSupply(TRANCHE_M).divideDecimal(splitRatio.mul(2)),
            0
        );
        newFund.primaryMarketMint(TRANCHE_A, address(this), oldFund.shareTotalSupply(TRANCHE_A), 0);
        newFund.primaryMarketMint(TRANCHE_B, address(this), oldFund.shareTotalSupply(TRANCHE_B), 0);
        stage = STAGE_UPGRADED;
    }

    /// @notice Transfer all underlying tokens back to the old Fund in case of emergency rollback.
    function rollback() external onlyOwner onlyStage(STAGE_SETTLED) {
        tokenUnderlying.safeTransfer(address(oldFund), tokenUnderlying.balanceOf(address(this)));
    }

    /// @notice Transfer the new fund's ownership back to admin in case that `createNewTokens()`
    ///         fails unexpectedly.
    function transferNewFundOwnership() external onlyOwner {
        newFund.transferOwnership(owner());
    }

    function protocolUpgrade(address account)
        external
        onlyStage(STAGE_UPGRADED)
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 claimedRewards
        )
    {
        if (Address.isContract(account)) {
            // It is unsafe to upgrade for a smart contract. Such operation is only allowed by
            // the contract itself or the owner.
            require(
                msg.sender == account || msg.sender == owner(),
                "Smart contracts can only be upgraded by itself or admin"
            );
        }

        // Burn unstaked old tokens
        (uint256 oldBalanceM, uint256 oldBalanceA, uint256 oldBalanceB) =
            oldFund.allShareBalanceOf(account);
        if (oldBalanceM > 0) {
            oldFund.burn(TRANCHE_M, account, oldBalanceM);
        }
        if (oldBalanceA > 0) {
            oldFund.burn(TRANCHE_A, account, oldBalanceA);
        }
        if (oldBalanceB > 0) {
            oldFund.burn(TRANCHE_B, account, oldBalanceB);
        }

        // Burn staked old tokens
        {
            uint256 stakedM;
            uint256 stakedA;
            uint256 stakedB;
            (stakedM, stakedA, stakedB, claimedRewards) = oldExchange.protocolUpgrade(account);
            if (stakedM > 0) {
                oldFund.burn(TRANCHE_M, address(oldExchange), stakedM);
                oldBalanceM = oldBalanceM.add(stakedM);
            }
            if (stakedA > 0) {
                oldFund.burn(TRANCHE_A, address(oldExchange), stakedA);
                oldBalanceA = oldBalanceA.add(stakedA);
            }
            if (stakedB > 0) {
                oldFund.burn(TRANCHE_B, address(oldExchange), stakedB);
                oldBalanceB = oldBalanceB.add(stakedB);
            }
        }

        // Mint all collected old tokens so that their total supplies do not change
        if (oldBalanceM > 0) {
            oldFund.mint(TRANCHE_M, address(this), oldBalanceM);
        }
        if (oldBalanceA > 0) {
            oldFund.mint(TRANCHE_A, address(this), oldBalanceA);
        }
        if (oldBalanceB > 0) {
            oldFund.mint(TRANCHE_B, address(this), oldBalanceB);
        }

        uint256 newVersion = newFund.getRebalanceSize();
        amountM = oldBalanceM.divideDecimal(initialSplitRatio.mul(2));
        amountA = oldBalanceA;
        amountB = oldBalanceB;
        if (newVersion > 0) {
            (amountM, amountA, amountB) = newFund.batchRebalance(
                amountM,
                amountA,
                amountB,
                0,
                newVersion
            );
        }

        newFund.trancheTransfer(TRANCHE_M, address(newStaking), amountM, newVersion);
        newStaking.deposit(TRANCHE_M, amountM, account, newVersion);
        newFund.trancheTransfer(TRANCHE_A, address(newStaking), amountA, newVersion);
        newStaking.deposit(TRANCHE_A, amountA, account, newVersion);
        newFund.trancheTransfer(TRANCHE_B, address(newStaking), amountB, newVersion);
        newStaking.deposit(TRANCHE_B, amountB, account, newVersion);

        emit Upgraded(
            account,
            oldBalanceM,
            oldBalanceA,
            oldBalanceB,
            amountM,
            amountA,
            amountB,
            claimedRewards
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "./IFund.sol";

interface IFundV2 is IFund {
    function historicalUnderlying(uint256 timestamp) external view returns (uint256);

    function getTotalUnderlying() external view returns (uint256);

    function getStrategyUnderlying() external view returns (uint256);

    function getTotalDebt() external view returns (uint256);

    function transferToStrategy(uint256 amount) external;

    function transferFromStrategy(uint256 amount) external;

    function reportProfit(uint256 profit, uint256 performanceFee) external;

    function reportLoss(uint256 loss) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../utils/SafeDecimalMath.sol";
import "../utils/CoreUtility.sol";

import "../interfaces/IFundV3.sol";
import "../interfaces/IChessController.sol";
import "../interfaces/IChessSchedule.sol";
import "../interfaces/ITrancheIndexV2.sol";
import "../interfaces/IVotingEscrow.sol";

contract ShareStaking is ITrancheIndexV2, CoreUtility {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event Deposited(uint256 tranche, address account, uint256 amount);
    event Withdrawn(uint256 tranche, address account, uint256 amount);

    uint256 private constant MAX_ITERATIONS = 500;

    uint256 private constant REWARD_WEIGHT_B = 2;
    uint256 private constant REWARD_WEIGHT_R = 1;
    uint256 private constant REWARD_WEIGHT_Q = 3;
    uint256 private constant MAX_BOOSTING_FACTOR = 3e18;
    uint256 private constant MAX_BOOSTING_FACTOR_MINUS_ONE = MAX_BOOSTING_FACTOR - 1e18;

    IFundV3 public immutable fund;

    /// @notice The Chess release schedule contract.
    IChessSchedule public immutable chessSchedule;

    /// @notice The controller contract.
    IChessController public immutable chessController;

    IVotingEscrow private immutable _votingEscrow;

    /// @notice Timestamp when rewards start.
    uint256 public immutable rewardStartTimestamp;

    /// @dev Per-fund CHESS emission rate. The product of CHESS emission rate
    ///      and weekly percentage of the fund
    uint256 private _rate;

    /// @dev Total amount of user shares, i.e. sum of all entries in `_balances`.
    uint256[TRANCHE_COUNT] private _totalSupplies;

    /// @dev Rebalance version of `_totalSupplies`.
    uint256 private _totalSupplyVersion;

    /// @dev Amount of shares staked by each user.
    mapping(address => uint256[TRANCHE_COUNT]) private _balances;

    /// @dev Rebalance version mapping for `_balances`.
    mapping(address => uint256) private _balanceVersions;

    /// @dev Mapping of rebalance version => split ratio.
    mapping(uint256 => uint256) private _historicalSplitRatio;

    /// @dev 1e27 * ∫(rate(t) / totalWeight(t) dt) from the latest rebalance till checkpoint.
    uint256 private _invTotalWeightIntegral;

    /// @dev Final `_invTotalWeightIntegral` before each rebalance.
    ///      These values are accessed in a loop in `_userCheckpoint()` with bounds checking.
    ///      So we store them in a fixed-length array, in order to make compiler-generated
    ///      bounds checking on every access cheaper. The actual length of this array is stored in
    ///      `_historicalIntegralSize` and should be explicitly checked when necessary.
    uint256[65535] private _historicalIntegrals;

    /// @dev Actual length of the `_historicalIntegrals` array, which always equals to the number of
    ///      historical rebalances after `checkpoint()` is called.
    uint256 private _historicalIntegralSize;

    /// @dev Timestamp when checkpoint() is called.
    uint256 private _checkpointTimestamp;

    /// @dev Snapshot of `_invTotalWeightIntegral` per user.
    mapping(address => uint256) private _userIntegrals;

    /// @dev Mapping of account => claimable rewards.
    mapping(address => uint256) private _claimableRewards;

    uint256 private _workingSupply;
    mapping(address => uint256) private _workingBalances;

    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address votingEscrow_,
        uint256 rewardStartTimestamp_
    ) public {
        fund = IFundV3(fund_);
        chessSchedule = IChessSchedule(chessSchedule_);
        chessController = IChessController(chessController_);
        _votingEscrow = IVotingEscrow(votingEscrow_);
        rewardStartTimestamp = rewardStartTimestamp_;
        _checkpointTimestamp = block.timestamp;
    }

    function getRate() external view returns (uint256) {
        return _rate / 1e18;
    }

    /// @notice Return weight of given balance with respect to rewards.
    /// @param amountQ Amount of QUEEN
    /// @param amountB Amount of BISHOP
    /// @param amountR Amount of ROOK
    /// @param splitRatio Split ratio
    /// @return Rewarding weight of the balance
    function weightedBalance(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 splitRatio
    ) public pure returns (uint256) {
        return
            amountQ
                .mul(REWARD_WEIGHT_Q)
                .multiplyDecimal(splitRatio)
                .add(amountB.mul(REWARD_WEIGHT_B))
                .add(amountR.mul(REWARD_WEIGHT_R))
                .div(REWARD_WEIGHT_Q);
    }

    function totalSupply(uint256 tranche) external view returns (uint256) {
        uint256 totalSupplyQ = _totalSupplies[TRANCHE_Q];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];
        uint256 totalSupplyR = _totalSupplies[TRANCHE_R];

        uint256 version = _totalSupplyVersion;
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (totalSupplyQ, totalSupplyB, totalSupplyR) = _fundBatchRebalance(
                totalSupplyQ,
                totalSupplyB,
                totalSupplyR,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_Q) {
            return totalSupplyQ;
        } else if (tranche == TRANCHE_B) {
            return totalSupplyB;
        } else {
            return totalSupplyR;
        }
    }

    function trancheBalanceOf(uint256 tranche, address account) external view returns (uint256) {
        uint256 amountQ = _balances[account][TRANCHE_Q];
        uint256 amountB = _balances[account][TRANCHE_B];
        uint256 amountR = _balances[account][TRANCHE_R];

        if (tranche == TRANCHE_Q) {
            if (amountQ == 0 && amountB == 0 && amountR == 0) return 0;
        } else if (tranche == TRANCHE_B) {
            if (amountB == 0) return 0;
        } else {
            if (amountR == 0) return 0;
        }

        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (amountQ, amountB, amountR) = _fundBatchRebalance(
                amountQ,
                amountB,
                amountR,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_Q) {
            return amountQ;
        } else if (tranche == TRANCHE_B) {
            return amountB;
        } else {
            return amountR;
        }
    }

    function balanceVersion(address account) external view returns (uint256) {
        return _balanceVersions[account];
    }

    function workingSupply() external view returns (uint256) {
        uint256 version = _totalSupplyVersion;
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (uint256 totalSupplyQ, uint256 totalSupplyB, uint256 totalSupplyR) =
                _fundBatchRebalance(
                    _totalSupplies[TRANCHE_Q],
                    _totalSupplies[TRANCHE_B],
                    _totalSupplies[TRANCHE_R],
                    version,
                    rebalanceSize
                );
            return weightedBalance(totalSupplyQ, totalSupplyB, totalSupplyR, fund.splitRatio());
        } else {
            return _workingSupply;
        }
    }

    function workingBalanceOf(address account) external view returns (uint256) {
        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        uint256 workingBalance = _workingBalances[account]; // gas saver
        if (version < rebalanceSize || workingBalance == 0) {
            uint256[TRANCHE_COUNT] storage balance = _balances[account];
            uint256 amountQ = balance[TRANCHE_Q];
            uint256 amountB = balance[TRANCHE_B];
            uint256 amountR = balance[TRANCHE_R];
            if (version < rebalanceSize) {
                (amountQ, amountB, amountR) = _fundBatchRebalance(
                    amountQ,
                    amountB,
                    amountR,
                    version,
                    rebalanceSize
                );
            }
            return weightedBalance(amountQ, amountB, amountR, fund.splitRatio());
        } else {
            return workingBalance;
        }
    }

    function _fundRebalanceSize() internal view returns (uint256) {
        return fund.getRebalanceSize();
    }

    function _fundDoRebalance(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 index
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return fund.doRebalance(amountQ, amountB, amountR, index);
    }

    function _fundBatchRebalance(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 fromIndex,
        uint256 toIndex
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return fund.batchRebalance(amountQ, amountB, amountR, fromIndex, toIndex);
    }

    /// @dev Stake share tokens. A user could send QUEEN before deposit().
    ///      The contract first measures how much tranche share it has received,
    ///      then transfer the rest from the user
    /// @param tranche Tranche of the share
    /// @param amount The amount to deposit
    /// @param recipient Address that receives deposit
    /// @param version The current rebalance version
    function deposit(
        uint256 tranche,
        uint256 amount,
        address recipient,
        uint256 version
    ) external {
        _checkpoint(version);
        _userCheckpoint(recipient, version);
        _balances[recipient][tranche] = _balances[recipient][tranche].add(amount);
        uint256 oldTotalSupply = _totalSupplies[tranche];
        _totalSupplies[tranche] = oldTotalSupply.add(amount);
        _updateWorkingBalance(recipient, version);
        uint256 spareAmount = fund.trancheBalanceOf(tranche, address(this)).sub(oldTotalSupply);
        if (spareAmount < amount) {
            // Retain the rest of share token (version is checked by the fund)
            fund.trancheTransferFrom(
                tranche,
                msg.sender,
                address(this),
                amount - spareAmount,
                version
            );
        } else {
            require(version == _fundRebalanceSize(), "Invalid version");
        }
        emit Deposited(tranche, recipient, amount);
    }

    /// @notice Unstake tranche tokens.
    /// @param tranche Tranche of the share
    /// @param amount The amount to withdraw
    /// @param version The current rebalance version
    function withdraw(
        uint256 tranche,
        uint256 amount,
        uint256 version
    ) external {
        _checkpoint(version);
        _userCheckpoint(msg.sender, version);
        _balances[msg.sender][tranche] = _balances[msg.sender][tranche].sub(
            amount,
            "Insufficient balance to withdraw"
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        _updateWorkingBalance(msg.sender, version);
        // version is checked by the fund
        fund.trancheTransfer(tranche, msg.sender, amount, version);
        emit Withdrawn(tranche, msg.sender, amount);
    }

    /// @notice Transform share balance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshBalance(address account, uint256 targetVersion) external {
        uint256 rebalanceSize = _fundRebalanceSize();
        if (targetVersion == 0) {
            targetVersion = rebalanceSize;
        } else {
            require(targetVersion <= rebalanceSize, "Target version out of bound");
        }
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, targetVersion);
    }

    /// @notice Return claimable rewards of an account till now.
    ///
    ///         This function should be call as a "view" function off-chain to get
    ///         the return value, e.g. using `contract.claimableRewards.call(account)` in web3
    ///         or `contract.callStatic.claimableRewards(account)` in ethers.js.
    /// @param account Address of an account
    /// @return Amount of claimable rewards
    function claimableRewards(address account) external returns (uint256) {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        return _claimableRewards[account];
    }

    /// @notice Claim the rewards for an account.
    /// @param account Account to claim its rewards
    function claimRewards(address account) external {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        uint256 amount = _claimableRewards[account];
        _claimableRewards[account] = 0;
        chessSchedule.mint(account, amount);
        _updateWorkingBalance(account, rebalanceSize);
    }

    /// @notice Synchronize an account's locked Chess with `VotingEscrow`
    ///         and update its working balance.
    /// @param account Address of the synchronized account
    function syncWithVotingEscrow(address account) external {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _updateWorkingBalance(account, rebalanceSize);
    }

    /// @dev Transform total supplies to the latest rebalance version and make a global reward checkpoint.
    /// @param rebalanceSize The number of existing rebalances. It must be the same as
    ///                       `fund.getRebalanceSize()`.
    function _checkpoint(uint256 rebalanceSize) private {
        uint256 timestamp = _checkpointTimestamp;
        if (timestamp >= block.timestamp) {
            return;
        }

        uint256 integral = _invTotalWeightIntegral;
        uint256 endWeek = _endOfWeek(timestamp);
        uint256 version = _totalSupplyVersion;
        uint256 rebalanceTimestamp;
        if (version < rebalanceSize) {
            rebalanceTimestamp = fund.getRebalanceTimestamp(version);
        } else {
            rebalanceTimestamp = type(uint256).max;
        }
        uint256 rate = _rate;
        uint256 totalSupplyQ = _totalSupplies[TRANCHE_Q];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];
        uint256 totalSupplyR = _totalSupplies[TRANCHE_R];
        uint256 weight = _workingSupply;
        uint256 timestamp_ = timestamp; // avoid stack too deep

        for (uint256 i = 0; i < MAX_ITERATIONS && timestamp_ < block.timestamp; i++) {
            uint256 endTimestamp = rebalanceTimestamp.min(endWeek).min(block.timestamp);

            if (weight > 0 && endTimestamp > rewardStartTimestamp) {
                integral = integral.add(
                    rate
                        .mul(endTimestamp.sub(timestamp_.max(rewardStartTimestamp)))
                        .decimalToPreciseDecimal()
                        .div(weight)
                );
            }

            if (endTimestamp == rebalanceTimestamp) {
                uint256 oldSize = _historicalIntegralSize;
                _historicalIntegrals[oldSize] = integral;
                _historicalIntegralSize = oldSize + 1;

                integral = 0;
                (totalSupplyQ, totalSupplyB, totalSupplyR) = _fundDoRebalance(
                    totalSupplyQ,
                    totalSupplyB,
                    totalSupplyR,
                    version
                );

                version++;
                {
                    // Reset total weight boosting after the first rebalance
                    uint256 splitRatio = fund.historicalSplitRatio(version);
                    weight = weightedBalance(totalSupplyQ, totalSupplyB, totalSupplyR, splitRatio);
                    _historicalSplitRatio[version] = splitRatio;
                }

                if (version < rebalanceSize) {
                    rebalanceTimestamp = fund.getRebalanceTimestamp(version);
                } else {
                    rebalanceTimestamp = type(uint256).max;
                }
            }
            if (endTimestamp == endWeek) {
                rate = chessSchedule.getRate(endWeek).mul(
                    chessController.getFundRelativeWeight(address(this), endWeek)
                );
                if (endWeek < rewardStartTimestamp && endWeek + 1 weeks > rewardStartTimestamp) {
                    // Rewards start in the middle of the next week. We adjust the rate to
                    // compensate for the period between `endWeek` and `rewardStartTimestamp`.
                    rate = rate.mul(1 weeks).div(endWeek + 1 weeks - rewardStartTimestamp);
                }
                endWeek += 1 weeks;
            }

            timestamp_ = endTimestamp;
        }

        _checkpointTimestamp = block.timestamp;
        _invTotalWeightIntegral = integral;
        _rate = rate;
        if (_totalSupplyVersion != rebalanceSize) {
            _totalSupplies[TRANCHE_Q] = totalSupplyQ;
            _totalSupplies[TRANCHE_B] = totalSupplyB;
            _totalSupplies[TRANCHE_R] = totalSupplyR;
            _totalSupplyVersion = rebalanceSize;
            // Reset total working weight before any boosting if rebalance ever triggered
            _workingSupply = weight;
        }
    }

    /// @dev Transform a user's balance to a given rebalance version and update this user's rewards.
    ///
    ///      In most cases, the target version is the latest version and this function cumulates
    ///      rewards till now. When this function is called from `refreshBalance()`,
    ///      `targetVersion` can be an older version, in which case rewards are cumulated till
    ///      the end of that version (i.e. timestamp of the transaction triggering the rebalance
    ///      with index `targetVersion`).
    ///
    ///      This function should always be called after `_checkpoint()` is called, so that
    ///      the global reward checkpoint is guarenteed up to date.
    /// @param account Account to update
    /// @param targetVersion The target rebalance version
    function _userCheckpoint(address account, uint256 targetVersion) private {
        uint256 oldVersion = _balanceVersions[account];
        if (oldVersion > targetVersion) {
            return;
        }
        uint256 userIntegral = _userIntegrals[account];
        uint256 integral;
        // This scope is to avoid the "stack too deep" error.
        {
            // We assume that this function is always called immediately after `_checkpoint()`,
            // which guarantees that `_historicalIntegralSize` equals to the number of historical
            // rebalances.
            uint256 rebalanceSize = _historicalIntegralSize;
            integral = targetVersion == rebalanceSize
                ? _invTotalWeightIntegral
                : _historicalIntegrals[targetVersion];
        }
        if (userIntegral == integral && oldVersion == targetVersion) {
            // Return immediately when the user's rewards have already been updated to
            // the target version.
            return;
        }

        uint256 rewards = _claimableRewards[account];
        uint256[TRANCHE_COUNT] storage balance = _balances[account];
        uint256 weight = _workingBalances[account];
        uint256 balanceQ = balance[TRANCHE_Q];
        uint256 balanceB = balance[TRANCHE_B];
        uint256 balanceR = balance[TRANCHE_R];
        for (uint256 i = oldVersion; i < targetVersion; i++) {
            rewards = rewards.add(
                weight.multiplyDecimalPrecise(_historicalIntegrals[i].sub(userIntegral))
            );
            if (balanceQ != 0 || balanceB != 0 || balanceR != 0) {
                (balanceQ, balanceB, balanceR) = _fundDoRebalance(balanceQ, balanceB, balanceR, i);
            }
            userIntegral = 0;

            // Reset per-user weight boosting after the first rebalance
            weight = weightedBalance(balanceQ, balanceB, balanceR, _historicalSplitRatio[i + 1]);
        }
        rewards = rewards.add(weight.multiplyDecimalPrecise(integral.sub(userIntegral)));
        address account_ = account; // Fix the "stack too deep" error
        _claimableRewards[account_] = rewards;
        _userIntegrals[account_] = integral;

        if (oldVersion < targetVersion) {
            balance[TRANCHE_Q] = balanceQ;
            balance[TRANCHE_B] = balanceB;
            balance[TRANCHE_R] = balanceR;
            _balanceVersions[account_] = targetVersion;
            _workingBalances[account_] = weight;
        }
    }

    /// @dev Calculate working balance, which depends on the amount of staked tokens and veCHESS.
    ///      Before this function is called, both `_checkpoint()` and `_userCheckpoint(account)`
    ///      should be called to update `_workingSupply` and `_workingBalances[account]` to
    ///      the latest rebalance version.
    /// @param account User address
    /// @param rebalanceSize The number of existing rebalances. It must be the same as
    ///                       `fund.getRebalanceSize()`.
    function _updateWorkingBalance(address account, uint256 rebalanceSize) private {
        uint256 splitRatio = _historicalSplitRatio[rebalanceSize];
        if (splitRatio == 0) {
            // Read it from the fund in case that it's not initialized yet, e.g. when we reach here
            // for the first time and `rebalanceSize` is zero.
            splitRatio = fund.historicalSplitRatio(rebalanceSize);
            _historicalSplitRatio[rebalanceSize] = splitRatio;
        }
        uint256 weightedSupply =
            weightedBalance(
                _totalSupplies[TRANCHE_Q],
                _totalSupplies[TRANCHE_B],
                _totalSupplies[TRANCHE_R],
                splitRatio
            );
        uint256[TRANCHE_COUNT] storage balance = _balances[account];
        uint256 newWorkingBalance =
            weightedBalance(balance[TRANCHE_Q], balance[TRANCHE_B], balance[TRANCHE_R], splitRatio);
        uint256 veBalance = _votingEscrow.balanceOf(account);
        if (veBalance > 0) {
            uint256 veTotalSupply = _votingEscrow.totalSupply();
            uint256 maxWorkingBalance = newWorkingBalance.multiplyDecimal(MAX_BOOSTING_FACTOR);
            uint256 boostedWorkingBalance =
                newWorkingBalance.add(
                    weightedSupply
                        .mul(veBalance)
                        .multiplyDecimal(MAX_BOOSTING_FACTOR_MINUS_ONE)
                        .div(veTotalSupply)
                );
            newWorkingBalance = maxWorkingBalance.min(boostedWorkingBalance);
        }

        _workingSupply = _workingSupply.sub(_workingBalances[account]).add(newWorkingBalance);
        _workingBalances[account] = newWorkingBalance;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./IPrimaryMarket.sol";

interface IPrimaryMarketV2 is IPrimaryMarket {
    function claimAndUnwrap(address account)
        external
        returns (uint256 createdShares, uint256 redeemedUnderlying);

    function updateDelayedRedemptionDay() external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

/// @notice Amounts of Token M, A and B are sometimes stored in a `uint256[3]` array. This contract
///         defines index of each tranche in this array.
///
///         Solidity does not allow constants to be defined in interfaces. So this contract follows
///         the naming convention of interfaces but is implemented as an `abstract contract`.
abstract contract ITrancheIndex {
    uint256 internal constant TRANCHE_M = 0;
    uint256 internal constant TRANCHE_A = 1;
    uint256 internal constant TRANCHE_B = 2;

    uint256 internal constant TRANCHE_COUNT = 3;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "../../interfaces/ITwapOracle.sol";

interface IFund {
    /// @notice A linear transformation matrix that represents a rebalance.
    ///
    ///         ```
    ///             [ ratioM          0        0 ]
    ///         R = [ ratioA2M  ratioAB        0 ]
    ///             [ ratioB2M        0  ratioAB ]
    ///         ```
    ///
    ///         Amounts of the three tranches `m`, `a` and `b` can be rebalanced by multiplying the matrix:
    ///
    ///         ```
    ///         [ m', a', b' ] = [ m, a, b ] * R
    ///         ```
    struct Rebalance {
        uint256 ratioM;
        uint256 ratioA2M;
        uint256 ratioB2M;
        uint256 ratioAB;
        uint256 timestamp;
    }

    function trancheWeights() external pure returns (uint256 weightA, uint256 weightB);

    function tokenUnderlying() external view returns (address);

    function tokenM() external view returns (address);

    function tokenA() external view returns (address);

    function tokenB() external view returns (address);

    function underlyingDecimalMultiplier() external view returns (uint256);

    function twapOracle() external view returns (ITwapOracle);

    function feeCollector() external view returns (address);

    function endOfDay(uint256 timestamp) external pure returns (uint256);

    function shareTotalSupply(uint256 tranche) external view returns (uint256);

    function shareBalanceOf(uint256 tranche, address account) external view returns (uint256);

    function allShareBalanceOf(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function shareBalanceVersion(address account) external view returns (uint256);

    function shareAllowance(
        uint256 tranche,
        address owner,
        address spender
    ) external view returns (uint256);

    function shareAllowanceVersion(address owner, address spender) external view returns (uint256);

    function getRebalanceSize() external view returns (uint256);

    function getRebalance(uint256 index) external view returns (Rebalance memory);

    function getRebalanceTimestamp(uint256 index) external view returns (uint256);

    function currentDay() external view returns (uint256);

    function fundActivityStartTime() external view returns (uint256);

    function exchangeActivityStartTime() external view returns (uint256);

    function isFundActive(uint256 timestamp) external view returns (bool);

    function isPrimaryMarketActive(address primaryMarket, uint256 timestamp)
        external
        view
        returns (bool);

    function isExchangeActive(uint256 timestamp) external view returns (bool);

    function getTotalShares() external view returns (uint256);

    function historicalTotalShares(uint256 timestamp) external view returns (uint256);

    function historicalNavs(uint256 timestamp)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function extrapolateNav(uint256 timestamp, uint256 price)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function calculateNavB(uint256 navM, uint256 navA) external pure returns (uint256);

    function doRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 index
    )
        external
        view
        returns (
            uint256 newAmountM,
            uint256 newAmountA,
            uint256 newAmountB
        );

    function batchRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 fromIndex,
        uint256 toIndex
    )
        external
        view
        returns (
            uint256 newAmountM,
            uint256 newAmountA,
            uint256 newAmountB
        );

    function refreshBalance(address account, uint256 targetVersion) external;

    function refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) external;

    function mint(
        uint256 tranche,
        address account,
        uint256 amount
    ) external;

    function burn(
        uint256 tranche,
        address account,
        uint256 amount
    ) external;

    function transfer(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function transferFrom(
        uint256 tranche,
        address spender,
        address sender,
        address recipient,
        uint256 amount
    ) external returns (uint256 newAllowance);

    function increaseAllowance(
        uint256 tranche,
        address sender,
        address spender,
        uint256 addedValue
    ) external returns (uint256 newAllowance);

    function decreaseAllowance(
        uint256 tranche,
        address sender,
        address spender,
        uint256 subtractedValue
    ) external returns (uint256 newAllowance);

    function approve(
        uint256 tranche,
        address owner,
        address spender,
        uint256 amount
    ) external;

    event RebalanceTriggered(
        uint256 indexed index,
        uint256 indexed day,
        uint256 ratioM,
        uint256 ratioA2M,
        uint256 ratioB2M,
        uint256 ratioAB
    );
    event Settled(uint256 indexed day, uint256 navM, uint256 navA, uint256 navB);
    event InterestRateUpdated(uint256 baseInterestRate, uint256 floatingInterestRate);
    event Transfer(
        uint256 indexed tranche,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event Approval(
        uint256 indexed tranche,
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event BalancesRebalanced(
        address indexed account,
        uint256 version,
        uint256 balanceM,
        uint256 balanceA,
        uint256 balanceB
    );
    event AllowancesRebalanced(
        address indexed owner,
        address indexed spender,
        uint256 version,
        uint256 allowanceM,
        uint256 allowanceA,
        uint256 allowanceB
    );
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface IChessController {
    function getFundRelativeWeight(address account, uint256 timestamp) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface IChessSchedule {
    function getRate(uint256 timestamp) external view returns (uint256);

    function mint(address account, uint256 amount) external;

    function addMinter(address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface IPrimaryMarket {
    function claim(address account)
        external
        returns (uint256 createdShares, uint256 redeemedUnderlying);

    function settle(
        uint256 day,
        uint256 fundTotalShares,
        uint256 fundUnderlying,
        uint256 underlyingPrice,
        uint256 previousNav
    )
        external
        returns (
            uint256 sharesToMint,
            uint256 sharesToBurn,
            uint256 creationUnderlying,
            uint256 redemptionUnderlying,
            uint256 fee
        );
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

import "../interfaces/ITrancheIndex.sol";
import "../../interfaces/IChessSchedule.sol";
import "../../utils/CoreUtility.sol";

import {UnsettledTrade} from "../exchange/LibUnsettledTrade.sol";
import {VESnapshot} from "../exchange/StakingV2.sol";
import "../exchange/ExchangeV2.sol";
import "../fund/Fund.sol";
import "../fund/FundV2.sol";
import "../fund/PrimaryMarket.sol";
import "../fund/PrimaryMarketV2.sol";
import "../../governance/InterestRateBallot.sol";
import "../../governance/FeeDistributor.sol";
import "../../governance/VotingEscrowV2.sol";
import "../governance/ChessControllerV4.sol";
import "../../governance/ControllerBallot.sol";

interface IExchange {
    function chessSchedule() external view returns (IChessSchedule);

    function unsettledTrades(
        address account,
        uint256 tranche,
        uint256 epoch
    ) external view returns (UnsettledTrade memory);
}

contract ProtocolDataProvider is ITrancheIndex, CoreUtility {
    struct ProtocolData {
        uint256 blockNumber;
        uint256 blockTimestamp;
        WalletData wallet;
        FundData fund;
        PrimaryMarketData primaryMarket;
        ExchangeData exchange;
        GovernanceData governance;
        SwapPairData pair;
    }

    struct WalletData {
        WalletBalanceData balance;
        WalletAllowanceData allowance;
    }

    struct WalletBalanceData {
        uint256 nativeCurrency;
        uint256 underlyingToken;
        uint256 quoteToken;
        uint256 tokenM;
        uint256 tokenA;
        uint256 tokenB;
        uint256 chess;
    }

    struct WalletAllowanceData {
        uint256 primaryMarketUnderlying;
        WalletAllowanceExchangeData exchange;
        uint256 votingEscrowChess;
    }

    struct WalletAllowanceExchangeData {
        uint256 quoteToken;
        uint256 tokenM;
        uint256 tokenA;
        uint256 tokenB;
    }

    struct FundData {
        bool isFundActive;
        bool isPrimaryMarketActive;
        bool isExchangeActive;
        uint256 fundActivityStartTime;
        uint256 exchangeActivityStartTime;
        uint256 currentDay;
        uint256 currentWeek;
        uint256 dailyProtocolFeeRate;
        uint256 totalShares;
        uint256 totalUnderlying;
        uint256 rebalanceSize;
        uint256 currentInterestRate;
        Fund.Rebalance lastRebalance;
        uint256 relativeWeight;
        uint256 strategyUnderlying;
    }

    struct PrimaryMarketData {
        uint256 currentCreatingUnderlying;
        uint256 currentRedeemingShares;
        uint256 fundCap;
        uint256 redemptionFeeRate;
        uint256 splitFeeRate;
        uint256 mergeFeeRate;
        uint256 minCreationUnderlying;
        PrimaryMarketAccountData account;
    }

    struct PrimaryMarketAccountData {
        uint256 creatingUnderlying;
        uint256 redeemingShares;
        uint256 createdShares;
        uint256 redeemedUnderlying;
        uint256[16] recentDelayedRedemptions;
    }

    struct ExchangeData {
        Shares totalDeposited;
        uint256 weightedSupply;
        uint256 workingSupply;
        uint256 minBidAmount;
        uint256 minAskAmount;
        ExchangeAccountData account;
    }

    struct ExchangeAccountData {
        Shares available;
        Shares locked;
        uint256 weightedBalance;
        uint256 workingBalance;
        VESnapshot veSnapshot;
        bool isMaker;
        uint256 chessRewards;
    }

    struct Shares {
        uint256 tokenM;
        uint256 tokenA;
        uint256 tokenB;
    }

    struct GovernanceData {
        uint256 chessTotalSupply;
        uint256 chessRate;
        uint256 nextWeekChessRate;
        VotingEscrowData votingEscrow;
        BallotData interestRateBallot;
        ControllerBallotData controllerBallot;
        FeeDistributorData feeDistributor;
    }

    struct VotingEscrowData {
        uint256 totalLocked;
        uint256 totalSupply;
        uint256 tradingWeekTotalSupply;
        IVotingEscrow.LockedBalance account;
    }

    struct BallotData {
        uint256 tradingWeekTotalSupply;
        IBallot.Voter account;
    }

    struct ControllerBallotData {
        address[] pools;
        uint256[] currentSums;
        ControllerBallotAccountData account;
    }

    struct ControllerBallotAccountData {
        uint256 amount;
        uint256 unlockTime;
        uint256[] weights;
    }

    struct FeeDistributorData {
        FeeDistributorAccountData account;
        uint256 currentRewards;
        uint256 currentSupply;
        uint256 tradingWeekTotalSupply;
        uint256 adminFeeRate;
    }

    struct FeeDistributorAccountData {
        uint256 claimableRewards;
        uint256 currentBalance;
        uint256 amount;
        uint256 unlockTime;
    }

    struct SwapPairData {
        uint112 reserve0;
        uint112 reserve1;
        address token0;
        address token1;
    }

    string public constant VERSION = "2.0.0";

    VotingEscrowV2 public immutable votingEscrow;
    IChessSchedule public immutable chessSchedule;
    IERC20 public immutable chess;
    ControllerBallot public immutable controllerBallot;
    InterestRateBallot public immutable interestRateBallot;

    constructor(
        VotingEscrowV2 votingEscrow_,
        IChessSchedule chessSchedule_,
        ControllerBallot controllerBallot_,
        InterestRateBallot interestRateBallot_
    ) public {
        votingEscrow = votingEscrow_;
        chessSchedule = chessSchedule_;
        chess = IERC20(votingEscrow_.token());
        controllerBallot = controllerBallot_;
        interestRateBallot = interestRateBallot_;
    }

    /// @dev This function should be call as a "view" function off-chain to get the return value,
    ///      e.g. using `contract.getProtocolData.call()` in web3
    ///      or `contract.callStatic.getProtocolData()` in ethers.js.
    function getProtocolData(
        address primaryMarket,
        address exchange,
        address swapPair,
        address feeDistributor,
        address account,
        uint256 fundVersion
    ) external returns (ProtocolData memory data) {
        data.blockNumber = block.number;
        data.blockTimestamp = block.timestamp;

        data.wallet = getWalletData(primaryMarket, exchange, account);

        data.fund = getFundData(primaryMarket, exchange, fundVersion);

        data.primaryMarket = getPrimaryMarketData(primaryMarket, account, fundVersion);

        data.exchange = getExchangeData(exchange, account);

        data.governance = getGovernanceData(exchange, feeDistributor, account);

        data.pair = getSwapPairData(swapPair);
    }

    function getWalletData(
        address primaryMarket,
        address exchange,
        address account
    ) public view returns (WalletData memory data) {
        Fund fund = Fund(address(ExchangeV2(exchange).fund()));
        IERC20 underlyingToken = IERC20(fund.tokenUnderlying());
        IERC20 quoteToken = IERC20(ExchangeV2(exchange).quoteAssetAddress());

        data.balance.nativeCurrency = account.balance;
        data.balance.underlyingToken = underlyingToken.balanceOf(account);
        data.balance.quoteToken = quoteToken.balanceOf(account);
        (data.balance.tokenM, data.balance.tokenA, data.balance.tokenB) = fund.allShareBalanceOf(
            account
        );
        data.balance.chess = chess.balanceOf(account);

        data.allowance.primaryMarketUnderlying = underlyingToken.allowance(account, primaryMarket);
        data.allowance.exchange.quoteToken = quoteToken.allowance(account, exchange);
        data.allowance.exchange.tokenM = fund.shareAllowance(TRANCHE_M, account, exchange);
        data.allowance.exchange.tokenA = fund.shareAllowance(TRANCHE_A, account, exchange);
        data.allowance.exchange.tokenB = fund.shareAllowance(TRANCHE_B, account, exchange);
        data.allowance.votingEscrowChess = chess.allowance(account, address(votingEscrow));
    }

    function getFundData(
        address primaryMarket,
        address exchange,
        uint256 fundVersion
    ) public returns (FundData memory data) {
        Fund fund = Fund(address(ExchangeV2(exchange).fund()));
        data.isFundActive = fund.isFundActive(block.timestamp);
        data.isPrimaryMarketActive = fund.isPrimaryMarketActive(primaryMarket, block.timestamp);
        data.isExchangeActive = fund.isExchangeActive(block.timestamp);
        data.fundActivityStartTime = fund.fundActivityStartTime();
        data.exchangeActivityStartTime = fund.exchangeActivityStartTime();
        data.currentDay = fund.currentDay();
        data.currentWeek = _endOfWeek(data.currentDay - 1 days);
        data.dailyProtocolFeeRate = fund.dailyProtocolFeeRate();
        data.totalShares = fund.getTotalShares();
        data.rebalanceSize = fund.getRebalanceSize();
        data.currentInterestRate = fund.historicalInterestRate(data.currentWeek);
        uint256 rebalanceSize = fund.getRebalanceSize();
        data.lastRebalance = fund.getRebalance(rebalanceSize == 0 ? 0 : rebalanceSize - 1);
        ExchangeV2(exchange).refreshBalance(address(0), 0); // Trigger checkpoint
        data.relativeWeight = ExchangeV2(exchange).chessController().getFundRelativeWeight(
            address(fund),
            block.timestamp
        );
        if (fundVersion < 2) {
            IERC20 underlyingToken = IERC20(fund.tokenUnderlying());
            data.totalUnderlying = underlyingToken.balanceOf(address(fund));
        } else {
            data.totalUnderlying = FundV2(address(fund)).getTotalUnderlying();
            data.strategyUnderlying = FundV2(address(fund)).getStrategyUnderlying();
        }
    }

    function getPrimaryMarketData(
        address primaryMarket,
        address account,
        uint256 fundVersion
    ) public returns (PrimaryMarketData memory data) {
        PrimaryMarketV2 primaryMarket_ = PrimaryMarketV2(payable(primaryMarket));
        data.currentCreatingUnderlying = primaryMarket_.currentCreatingUnderlying();
        data.currentRedeemingShares = primaryMarket_.currentRedeemingShares();
        data.redemptionFeeRate = primaryMarket_.redemptionFeeRate();
        data.splitFeeRate = primaryMarket_.splitFeeRate();
        data.mergeFeeRate = primaryMarket_.mergeFeeRate();
        data.minCreationUnderlying = primaryMarket_.minCreationUnderlying();
        PrimaryMarketV2.CreationRedemption memory cr = primaryMarket_.creationRedemptionOf(account);
        data.account.creatingUnderlying = cr.creatingUnderlying;
        data.account.redeemingShares = cr.redeemingShares;
        data.account.createdShares = cr.createdShares;
        data.account.redeemedUnderlying = cr.redeemedUnderlying;
        if (fundVersion >= 2) {
            data.fundCap = primaryMarket_.fundCap();
            uint256 currentDay = primaryMarket_.currentDay();
            for (uint256 i = 0; i < 16; i++) {
                (data.account.recentDelayedRedemptions[i], ) = primaryMarket_.getDelayedRedemption(
                    account,
                    currentDay - (i + 1) * 1 days
                );
            }
        }
    }

    function getExchangeData(address exchange, address account)
        public
        returns (ExchangeData memory data)
    {
        ExchangeV2 exchangeContract = ExchangeV2(exchange);
        data.totalDeposited.tokenM = exchangeContract.totalSupply(TRANCHE_M);
        data.totalDeposited.tokenA = exchangeContract.totalSupply(TRANCHE_A);
        data.totalDeposited.tokenB = exchangeContract.totalSupply(TRANCHE_B);
        data.weightedSupply = exchangeContract.weightedBalance(
            data.totalDeposited.tokenM,
            data.totalDeposited.tokenA,
            data.totalDeposited.tokenB
        );
        data.workingSupply = exchangeContract.workingSupply();
        data.minBidAmount = exchangeContract.minBidAmount();
        data.minAskAmount = exchangeContract.minAskAmount();
        data.account.available.tokenM = exchangeContract.availableBalanceOf(TRANCHE_M, account);
        data.account.available.tokenA = exchangeContract.availableBalanceOf(TRANCHE_A, account);
        data.account.available.tokenB = exchangeContract.availableBalanceOf(TRANCHE_B, account);
        data.account.locked.tokenM = exchangeContract.lockedBalanceOf(TRANCHE_M, account);
        data.account.locked.tokenA = exchangeContract.lockedBalanceOf(TRANCHE_A, account);
        data.account.locked.tokenB = exchangeContract.lockedBalanceOf(TRANCHE_B, account);
        data.account.weightedBalance = exchangeContract.weightedBalance(
            data.account.available.tokenM + data.account.locked.tokenM,
            data.account.available.tokenA + data.account.locked.tokenA,
            data.account.available.tokenB + data.account.locked.tokenB
        );
        data.account.workingBalance = exchangeContract.workingBalanceOf(account);
        data.account.veSnapshot = exchangeContract.veSnapshotOf(account);
        data.account.isMaker = exchangeContract.isMaker(account);
        data.account.chessRewards = exchangeContract.claimableRewards(account);
    }

    function getGovernanceData(
        address exchange,
        address feeDistributor,
        address account
    ) public returns (GovernanceData memory data) {
        uint256 blockCurrentWeek = _endOfWeek(block.timestamp);
        data.chessTotalSupply = chess.totalSupply();
        data.chessRate = chessSchedule.getRate(block.timestamp);
        data.nextWeekChessRate = chessSchedule.getRate(block.timestamp + 7 days);
        data.votingEscrow.totalLocked = votingEscrow.totalLocked();
        data.votingEscrow.totalSupply = votingEscrow.totalSupply();
        data.votingEscrow.tradingWeekTotalSupply = votingEscrow.totalSupplyAtTimestamp(
            blockCurrentWeek
        );
        data.votingEscrow.account = votingEscrow.getLockedBalance(account);
        data.interestRateBallot.tradingWeekTotalSupply = interestRateBallot.totalSupplyAtTimestamp(
            blockCurrentWeek
        );
        data.interestRateBallot.account = interestRateBallot.getReceipt(account);

        data.controllerBallot = getControllerBallotData(exchange, account);

        if (feeDistributor != address(0)) {
            FeeDistributor feeDistributor_ = FeeDistributor(payable(feeDistributor));
            data.feeDistributor.account.claimableRewards = feeDistributor_.userCheckpoint(account);
            data.feeDistributor.account.currentBalance = feeDistributor_.userLastBalances(account);
            (
                data.feeDistributor.account.amount,
                data.feeDistributor.account.unlockTime
            ) = feeDistributor_.userLockedBalances(account);
            data.feeDistributor.currentRewards = feeDistributor_.rewardsPerWeek(
                blockCurrentWeek - 1 weeks
            );
            data.feeDistributor.currentSupply = feeDistributor_.veSupplyPerWeek(
                blockCurrentWeek - 1 weeks
            );
            data.feeDistributor.tradingWeekTotalSupply = feeDistributor_.totalSupplyAtTimestamp(
                blockCurrentWeek
            );
            data.feeDistributor.adminFeeRate = feeDistributor_.adminFeeRate();
        }
    }

    function getControllerBallotData(address, address account)
        public
        view
        returns (ControllerBallotData memory data)
    {
        data.pools = controllerBallot.getPools();
        data.currentSums = new uint256[](data.pools.length);
        (data.account.amount, data.account.unlockTime) = controllerBallot.userLockedBalances(
            account
        );
        data.account.weights = new uint256[](data.pools.length);
        for (uint256 i = 0; i < data.pools.length; i++) {
            address pool = data.pools[i];
            data.currentSums[i] = controllerBallot.sumAtTimestamp(pool, block.timestamp);
            data.account.weights[i] = controllerBallot.userWeights(account, pool);
        }
    }

    function getSwapPairData(address swapPair) public view returns (SwapPairData memory data) {
        IUniswapV2Pair pair = IUniswapV2Pair(swapPair);
        data.token0 = pair.token0();
        data.token1 = pair.token1();
        (data.reserve0, data.reserve1, ) = pair.getReserves();
    }

    function getUnsettledTrades(
        address exchangeAddress,
        address account,
        uint256[] memory epochs
    )
        external
        view
        returns (
            UnsettledTrade[] memory unsettledTradeM,
            UnsettledTrade[] memory unsettledTradeA,
            UnsettledTrade[] memory unsettledTradeB
        )
    {
        IExchange exchange = IExchange(exchangeAddress);
        unsettledTradeM = new UnsettledTrade[](epochs.length);
        unsettledTradeA = new UnsettledTrade[](epochs.length);
        unsettledTradeB = new UnsettledTrade[](epochs.length);
        for (uint256 i = 0; i < epochs.length; i++) {
            unsettledTradeM[i] = exchange.unsettledTrades(account, TRANCHE_M, epochs[i]);
            unsettledTradeA[i] = exchange.unsettledTrades(account, TRANCHE_A, epochs[i]);
            unsettledTradeB[i] = exchange.unsettledTrades(account, TRANCHE_B, epochs[i]);
        }
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

/// @notice Unsettled trade of a taker buy order or a maker sell order
/// @param frozenQuote Amount of quote assets from the taker
/// @param effectiveQuote Effective amount of quote assets at zero premium-discount
/// @param reservedBase Reserved amount of base assets from the maker
struct UnsettledBuyTrade {
    uint256 frozenQuote;
    uint256 effectiveQuote;
    uint256 reservedBase;
}

/// @notice Unsettled trade of a taker sell order or a maker buy order
/// @param frozenBase Amount of base assets from the taker
/// @param effectiveBase Effective amount of base assets at zero premium-discount
/// @param reservedQuote Reserved amount of quote assets from the maker
struct UnsettledSellTrade {
    uint256 frozenBase;
    uint256 effectiveBase;
    uint256 reservedQuote;
}

/// @notice Unsettled trades of an account in a single epoch
/// @param takerBuy Trade by taker buy orders
/// @param takerSell Trade by taker sell orders
/// @param makerBuy Trade by maker buy orders
/// @param makerSell Trade by maker sell orders
struct UnsettledTrade {
    UnsettledBuyTrade takerBuy;
    UnsettledSellTrade takerSell;
    UnsettledSellTrade makerBuy;
    UnsettledBuyTrade makerSell;
}

library LibUnsettledBuyTrade {
    using SafeMath for uint256;

    /// @dev Accumulate buy trades
    /// @param self Trade to update
    /// @param other New trade to be added to storage
    function add(UnsettledBuyTrade storage self, UnsettledBuyTrade memory other) internal {
        self.frozenQuote = self.frozenQuote.add(other.frozenQuote);
        self.effectiveQuote = self.effectiveQuote.add(other.effectiveQuote);
        self.reservedBase = self.reservedBase.add(other.reservedBase);
    }
}

library LibUnsettledSellTrade {
    using SafeMath for uint256;

    /// @dev Accumulate sell trades
    /// @param self Trade to update
    /// @param other New trade to be added to storage
    function add(UnsettledSellTrade storage self, UnsettledSellTrade memory other) internal {
        self.frozenBase = self.frozenBase.add(other.frozenBase);
        self.effectiveBase = self.effectiveBase.add(other.effectiveBase);
        self.reservedQuote = self.reservedQuote.add(other.reservedQuote);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/CoreUtility.sol";
import "../../utils/ManagedPausable.sol";

import "../interfaces/IFund.sol";
import "../../interfaces/IChessController.sol";
import "../../interfaces/IChessSchedule.sol";
import "../interfaces/ITrancheIndex.sol";
import "../interfaces/IPrimaryMarketV2.sol";
import "../../interfaces/IVotingEscrow.sol";

/// @notice Chess locking snapshot used in calculating working balance of an account.
/// @param veProportion The account's veCHESS divided by the total veCHESS supply.
/// @param veLocked Locked CHESS and unlock time, which is synchronized from VotingEscrow.
struct VESnapshot {
    uint256 veProportion;
    IVotingEscrow.LockedBalance veLocked;
}

abstract contract StakingV2 is ITrancheIndex, CoreUtility, ManagedPausable {
    /// @dev Reserved storage slots for future sibling contract upgrades
    uint256[29] private _reservedSlots;

    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event Deposited(uint256 tranche, address account, uint256 amount);
    event Withdrawn(uint256 tranche, address account, uint256 amount);

    uint256 private constant MAX_ITERATIONS = 500;

    uint256 private constant REWARD_WEIGHT_A = 4;
    uint256 private constant REWARD_WEIGHT_B = 2;
    uint256 private constant REWARD_WEIGHT_M = 3;
    uint256 private constant MAX_BOOSTING_FACTOR = 3e18;
    uint256 private constant MAX_BOOSTING_FACTOR_MINUS_ONE = MAX_BOOSTING_FACTOR - 1e18;

    /// @dev Maximum fraction of veCHESS that can be used to boost Token M.
    uint256 private constant MAX_BOOSTING_POWER_M = 0.5e18;

    IFund public immutable fund;
    IERC20 private immutable tokenM;
    IERC20 private immutable tokenA;
    IERC20 private immutable tokenB;

    /// @notice The Chess release schedule contract.
    IChessSchedule public immutable chessSchedule;

    uint256 public immutable guardedLaunchStart;

    uint256 private _rate;

    /// @notice The controller contract.
    IChessController public immutable chessController;

    /// @notice Quote asset for the exchange. Each exchange only handles one quote asset
    address public immutable quoteAssetAddress;

    /// @dev Total amount of user shares, i.e. sum of all entries in `_availableBalances` and
    ///      `_lockedBalances`. Note that these values can be smaller than the amount of
    ///      share tokens held by this contract, because shares locked in unsettled trades
    ///      are not included in total supplies or any user's balance.
    uint256[TRANCHE_COUNT] private _totalSupplies;

    /// @dev Rebalance version of `_totalSupplies`.
    uint256 private _totalSupplyVersion;

    /// @dev Amount of shares that can be withdrawn or traded by each user.
    mapping(address => uint256[TRANCHE_COUNT]) private _availableBalances;

    /// @dev Amount of shares that are locked in ask orders.
    mapping(address => uint256[TRANCHE_COUNT]) private _lockedBalances;

    /// @dev Rebalance version mapping for `_availableBalances`.
    mapping(address => uint256) private _balanceVersions;

    /// @dev 1e27 * ∫(rate(t) / totalWeight(t) dt) from the latest rebalance till checkpoint.
    uint256 private _invTotalWeightIntegral;

    /// @dev Final `_invTotalWeightIntegral` before each rebalance.
    ///      These values are accessed in a loop in `_userCheckpoint()` with bounds checking.
    ///      So we store them in a fixed-length array, in order to make compiler-generated
    ///      bounds checking on every access cheaper. The actual length of this array is stored in
    ///      `_historicalIntegralSize` and should be explicitly checked when necessary.
    uint256[65535] private _historicalIntegrals;

    /// @dev Actual length of the `_historicalIntegrals` array, which always equals to the number of
    ///      historical rebalances after `checkpoint()` is called.
    uint256 private _historicalIntegralSize;

    /// @dev Timestamp when checkpoint() is called.
    uint256 private _checkpointTimestamp;

    /// @dev Snapshot of `_invTotalWeightIntegral` per user.
    mapping(address => uint256) private _userIntegrals;

    /// @dev Mapping of account => claimable rewards.
    mapping(address => uint256) private _claimableRewards;

    IVotingEscrow private immutable _votingEscrow;
    uint256 private _workingSupply;
    mapping(address => uint256) private _workingBalances;
    mapping(address => VESnapshot) private _veSnapshots;

    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 guardedLaunchStart_,
        address votingEscrow_
    ) public {
        fund = IFund(fund_);
        tokenM = IERC20(IFund(fund_).tokenM());
        tokenA = IERC20(IFund(fund_).tokenA());
        tokenB = IERC20(IFund(fund_).tokenB());
        chessSchedule = IChessSchedule(chessSchedule_);
        chessController = IChessController(chessController_);
        quoteAssetAddress = quoteAssetAddress_;
        guardedLaunchStart = guardedLaunchStart_;
        _votingEscrow = IVotingEscrow(votingEscrow_);
    }

    function _initializeStaking() internal {
        require(_checkpointTimestamp == 0);
        _checkpointTimestamp = block.timestamp;
        _rate = IChessSchedule(chessSchedule).getRate(block.timestamp);
    }

    function _initializeStakingV2(address pauser_) internal {
        _initializeManagedPausable(pauser_);
        // The contract was just upgraded from an old version without boosting
        _workingSupply = weightedBalance(
            _totalSupplies[TRANCHE_M],
            _totalSupplies[TRANCHE_A],
            _totalSupplies[TRANCHE_B]
        );
    }

    /// @notice Return weight of given balance with respect to rewards.
    /// @param amountM Amount of Token M
    /// @param amountA Amount of Token A
    /// @param amountB Amount of Token B
    /// @return Rewarding weight of the balance
    function weightedBalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB
    ) public pure returns (uint256) {
        return
            amountM.mul(REWARD_WEIGHT_M).add(amountA.mul(REWARD_WEIGHT_A)).add(
                amountB.mul(REWARD_WEIGHT_B)
            ) / REWARD_WEIGHT_M;
    }

    function totalSupply(uint256 tranche) external view returns (uint256) {
        uint256 totalSupplyM = _totalSupplies[TRANCHE_M];
        uint256 totalSupplyA = _totalSupplies[TRANCHE_A];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];

        uint256 version = _totalSupplyVersion;
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (totalSupplyM, totalSupplyA, totalSupplyB) = _fundBatchRebalance(
                totalSupplyM,
                totalSupplyA,
                totalSupplyB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return totalSupplyM;
        } else if (tranche == TRANCHE_A) {
            return totalSupplyA;
        } else {
            return totalSupplyB;
        }
    }

    function availableBalanceOf(uint256 tranche, address account) external view returns (uint256) {
        uint256 amountM = _availableBalances[account][TRANCHE_M];
        uint256 amountA = _availableBalances[account][TRANCHE_A];
        uint256 amountB = _availableBalances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    function lockedBalanceOf(uint256 tranche, address account) external view returns (uint256) {
        uint256 amountM = _lockedBalances[account][TRANCHE_M];
        uint256 amountA = _lockedBalances[account][TRANCHE_A];
        uint256 amountB = _lockedBalances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    function balanceVersion(address account) external view returns (uint256) {
        return _balanceVersions[account];
    }

    function workingSupply() external view returns (uint256) {
        uint256 version = _totalSupplyVersion;
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (uint256 totalSupplyM, uint256 totalSupplyA, uint256 totalSupplyB) =
                _fundBatchRebalance(
                    _totalSupplies[TRANCHE_M],
                    _totalSupplies[TRANCHE_A],
                    _totalSupplies[TRANCHE_B],
                    version,
                    rebalanceSize
                );
            return weightedBalance(totalSupplyM, totalSupplyA, totalSupplyB);
        } else {
            return _workingSupply;
        }
    }

    function workingBalanceOf(address account) external view returns (uint256) {
        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        uint256 workingBalance = _workingBalances[account]; // gas saver
        if (version < rebalanceSize || workingBalance == 0) {
            uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
            uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
            uint256 amountM = available[TRANCHE_M].add(locked[TRANCHE_M]);
            uint256 amountA = available[TRANCHE_A].add(locked[TRANCHE_A]);
            uint256 amountB = available[TRANCHE_B].add(locked[TRANCHE_B]);
            if (version < rebalanceSize) {
                (amountM, amountA, amountB) = _fundBatchRebalance(
                    amountM,
                    amountA,
                    amountB,
                    version,
                    rebalanceSize
                );
            }
            return weightedBalance(amountM, amountA, amountB);
        } else {
            return workingBalance;
        }
    }

    function veSnapshotOf(address account) external view returns (VESnapshot memory) {
        return _veSnapshots[account];
    }

    function _fundRebalanceSize() internal view returns (uint256) {
        return fund.getRebalanceSize();
    }

    function _fundDoRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 index
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return fund.doRebalance(amountM, amountA, amountB, index);
    }

    function _fundBatchRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 fromIndex,
        uint256 toIndex
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return fund.batchRebalance(amountM, amountA, amountB, fromIndex, toIndex);
    }

    /// @dev Deposit to get rewards
    /// @param tranche Tranche of the share
    /// @param amount The amount to deposit
    function deposit(uint256 tranche, uint256 amount) public whenNotPaused {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(msg.sender, rebalanceSize);
        _availableBalances[msg.sender][tranche] = _availableBalances[msg.sender][tranche].add(
            amount
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].add(amount);
        _updateWorkingBalance(msg.sender);

        if (tranche == TRANCHE_M) {
            tokenM.safeTransferFrom(msg.sender, address(this), amount);
        } else if (tranche == TRANCHE_A) {
            tokenA.safeTransferFrom(msg.sender, address(this), amount);
        } else {
            tokenB.safeTransferFrom(msg.sender, address(this), amount);
        }

        emit Deposited(tranche, msg.sender, amount);
    }

    /// @dev Claim settled Token M from the primary market and deposit to get rewards
    /// @param primaryMarket The primary market to claim shares from
    function claimAndDeposit(address primaryMarket) external {
        (uint256 createdShares, ) = IPrimaryMarketV2(primaryMarket).claim(msg.sender);
        deposit(TRANCHE_M, createdShares);
    }

    function claimAndUnwrapAndDeposit(address primaryMarket) external {
        (uint256 createdShares, ) = IPrimaryMarketV2(primaryMarket).claimAndUnwrap(msg.sender);
        deposit(TRANCHE_M, createdShares);
    }

    /// @dev Withdraw
    /// @param tranche Tranche of the share
    /// @param amount The amount to deposit
    function withdraw(uint256 tranche, uint256 amount) external whenNotPaused {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(msg.sender, rebalanceSize);
        _availableBalances[msg.sender][tranche] = _availableBalances[msg.sender][tranche].sub(
            amount,
            "Insufficient balance to withdraw"
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        _updateWorkingBalance(msg.sender);

        if (tranche == TRANCHE_M) {
            tokenM.safeTransfer(msg.sender, amount);
        } else if (tranche == TRANCHE_A) {
            tokenA.safeTransfer(msg.sender, amount);
        } else {
            tokenB.safeTransfer(msg.sender, amount);
        }

        emit Withdrawn(tranche, msg.sender, amount);
    }

    /// @notice Transform share balance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshBalance(address account, uint256 targetVersion) external {
        uint256 rebalanceSize = _fundRebalanceSize();
        if (targetVersion == 0) {
            targetVersion = rebalanceSize;
        } else {
            require(targetVersion <= rebalanceSize, "Target version out of bound");
        }
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, targetVersion);
    }

    /// @notice Return claimable rewards of an account till now.
    ///
    ///         This function should be call as a "view" function off-chain to get
    ///         the return value, e.g. using `contract.claimableRewards.call(account)` in web3
    ///         or `contract.callStatic.claimableRewards(account)` in ethers.js.
    /// @param account Address of an account
    /// @return Amount of claimable rewards
    function claimableRewards(address account) external returns (uint256) {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        return _claimableRewards[account];
    }

    /// @notice Claim the rewards for an account.
    /// @param account Account to claim its rewards
    function claimRewards(address account) external whenNotPaused {
        require(
            block.timestamp >= guardedLaunchStart + 15 days,
            "Cannot claim during guarded launch"
        );
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _claim(account);
    }

    /// @notice Synchronize an account's locked Chess with `VotingEscrow`
    ///         and update its working balance.
    /// @param account Address of the synchronized account
    function syncWithVotingEscrow(address account) external {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);

        VESnapshot storage veSnapshot = _veSnapshots[account];
        IVotingEscrow.LockedBalance memory newLocked = _votingEscrow.getLockedBalance(account);
        if (
            newLocked.amount != veSnapshot.veLocked.amount ||
            newLocked.unlockTime != veSnapshot.veLocked.unlockTime ||
            newLocked.unlockTime < block.timestamp
        ) {
            veSnapshot.veLocked.amount = newLocked.amount;
            veSnapshot.veLocked.unlockTime = newLocked.unlockTime;
            veSnapshot.veProportion = _votingEscrow.balanceOf(account).divideDecimal(
                _votingEscrow.totalSupply()
            );
        }

        _updateWorkingBalance(account);
    }

    /// @dev Transfer shares from the sender to the contract internally
    /// @param tranche Tranche of the share
    /// @param sender Sender address
    /// @param amount The amount to transfer
    function _tradeAvailable(
        uint256 tranche,
        address sender,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(sender, rebalanceSize);
        _availableBalances[sender][tranche] = _availableBalances[sender][tranche].sub(amount);
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        _updateWorkingBalance(sender);
    }

    function _rebalanceAndClearTrade(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        if (amountVersion < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                amountVersion,
                rebalanceSize
            );
        }
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        if (amountM > 0) {
            available[TRANCHE_M] = available[TRANCHE_M].add(amountM);
            _totalSupplies[TRANCHE_M] = _totalSupplies[TRANCHE_M].add(amountM);
        }
        if (amountA > 0) {
            available[TRANCHE_A] = available[TRANCHE_A].add(amountA);
            _totalSupplies[TRANCHE_A] = _totalSupplies[TRANCHE_A].add(amountA);
        }
        if (amountB > 0) {
            available[TRANCHE_B] = available[TRANCHE_B].add(amountB);
            _totalSupplies[TRANCHE_B] = _totalSupplies[TRANCHE_B].add(amountB);
        }
        _updateWorkingBalance(account);

        return (amountM, amountA, amountB);
    }

    function _lock(
        uint256 tranche,
        address account,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _availableBalances[account][tranche] = _availableBalances[account][tranche].sub(
            amount,
            "Insufficient balance to lock"
        );
        _lockedBalances[account][tranche] = _lockedBalances[account][tranche].add(amount);
    }

    function _rebalanceAndUnlock(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        if (amountVersion < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                amountVersion,
                rebalanceSize
            );
        }
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        if (amountM > 0) {
            available[TRANCHE_M] = available[TRANCHE_M].add(amountM);
            locked[TRANCHE_M] = locked[TRANCHE_M].sub(amountM);
        }
        if (amountA > 0) {
            available[TRANCHE_A] = available[TRANCHE_A].add(amountA);
            locked[TRANCHE_A] = locked[TRANCHE_A].sub(amountA);
        }
        if (amountB > 0) {
            available[TRANCHE_B] = available[TRANCHE_B].add(amountB);
            locked[TRANCHE_B] = locked[TRANCHE_B].sub(amountB);
        }
    }

    function _tradeLocked(
        uint256 tranche,
        address account,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _lockedBalances[account][tranche] = _lockedBalances[account][tranche].sub(amount);
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        _updateWorkingBalance(account);
    }

    /// @dev Transfer claimable rewards to an account. Rewards since the last user checkpoint
    ///      is not included. This function should always be called after `_userCheckpoint()`,
    ///      in order for the user to get all rewards till now.
    /// @param account Address of the account
    function _claim(address account) internal {
        uint256 claimableReward = _claimableRewards[account];
        _claimableRewards[account] = 0;
        chessSchedule.mint(account, claimableReward);
    }

    /// @dev Transform total supplies to the latest rebalance version and make a global reward checkpoint.
    /// @param rebalanceSize The number of existing rebalances. It must be the same as
    ///                       `fund.getRebalanceSize()`.
    function _checkpoint(uint256 rebalanceSize) private {
        uint256 timestamp = _checkpointTimestamp;
        if (timestamp >= block.timestamp) {
            return;
        }

        uint256 integral = _invTotalWeightIntegral;
        uint256 endWeek = _endOfWeek(timestamp);
        uint256 weeklyPercentage =
            chessController.getFundRelativeWeight(address(fund), endWeek - 1 weeks);
        uint256 version = _totalSupplyVersion;
        uint256 rebalanceTimestamp;
        if (version < rebalanceSize) {
            rebalanceTimestamp = fund.getRebalanceTimestamp(version);
        } else {
            rebalanceTimestamp = type(uint256).max;
        }
        uint256 rate = _rate;
        uint256 totalSupplyM = _totalSupplies[TRANCHE_M];
        uint256 totalSupplyA = _totalSupplies[TRANCHE_A];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];
        uint256 weight = _workingSupply;
        uint256 timestamp_ = timestamp; // avoid stack too deep

        for (uint256 i = 0; i < MAX_ITERATIONS && timestamp_ < block.timestamp; i++) {
            uint256 endTimestamp = rebalanceTimestamp.min(endWeek).min(block.timestamp);

            if (weight > 0) {
                integral = integral.add(
                    rate
                        .mul(endTimestamp.sub(timestamp_))
                        .multiplyDecimal(weeklyPercentage)
                        .divideDecimalPrecise(weight)
                );
            }

            if (endTimestamp == rebalanceTimestamp) {
                uint256 oldSize = _historicalIntegralSize;
                _historicalIntegrals[oldSize] = integral;
                _historicalIntegralSize = oldSize + 1;

                integral = 0;
                (totalSupplyM, totalSupplyA, totalSupplyB) = _fundDoRebalance(
                    totalSupplyM,
                    totalSupplyA,
                    totalSupplyB,
                    version
                );

                version++;
                // Reset total weight boosting after the first rebalance
                weight = weightedBalance(totalSupplyM, totalSupplyA, totalSupplyB);

                if (version < rebalanceSize) {
                    rebalanceTimestamp = fund.getRebalanceTimestamp(version);
                } else {
                    rebalanceTimestamp = type(uint256).max;
                }
            }
            if (endTimestamp == endWeek) {
                rate = chessSchedule.getRate(endWeek);
                weeklyPercentage = chessController.getFundRelativeWeight(address(fund), endWeek);
                endWeek += 1 weeks;
            }

            timestamp_ = endTimestamp;
        }

        _checkpointTimestamp = block.timestamp;
        _invTotalWeightIntegral = integral;
        if (_rate != rate) {
            _rate = rate;
        }
        if (_totalSupplyVersion != rebalanceSize) {
            _totalSupplies[TRANCHE_M] = totalSupplyM;
            _totalSupplies[TRANCHE_A] = totalSupplyA;
            _totalSupplies[TRANCHE_B] = totalSupplyB;
            _totalSupplyVersion = rebalanceSize;
            // Reset total working weight before any boosting if rebalance ever triggered
            _workingSupply = weight;
        }
    }

    /// @dev Transform a user's balance to a given rebalance version and update this user's rewards.
    ///
    ///      In most cases, the target version is the latest version and this function cumulates
    ///      rewards till now. When this function is called from `refreshBalance()`,
    ///      `targetVersion` can be an older version, in which case rewards are cumulated till
    ///      the end of that version (i.e. timestamp of the transaction triggering the rebalance
    ///      with index `targetVersion`).
    ///
    ///      This function should always be called after `_checkpoint()` is called, so that
    ///      the global reward checkpoint is guarenteed up to date.
    /// @param account Account to update
    /// @param targetVersion The target rebalance version
    function _userCheckpoint(address account, uint256 targetVersion) private {
        uint256 oldVersion = _balanceVersions[account];
        if (oldVersion > targetVersion) {
            return;
        }
        uint256 userIntegral = _userIntegrals[account];
        uint256 integral;
        // This scope is to avoid the "stack too deep" error.
        {
            // We assume that this function is always called immediately after `_checkpoint()`,
            // which guarantees that `_historicalIntegralSize` equals to the number of historical
            // rebalances.
            uint256 rebalanceSize = _historicalIntegralSize;
            integral = targetVersion == rebalanceSize
                ? _invTotalWeightIntegral
                : _historicalIntegrals[targetVersion];
        }
        if (userIntegral == integral && oldVersion == targetVersion) {
            // Return immediately when the user's rewards have already been updated to
            // the target version.
            return;
        }

        uint256 rewards = _claimableRewards[account];
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        uint256 weight = _workingBalances[account];
        if (weight == 0) {
            // Loading available and locked is repeated to avoid "stake too deep" error.
            weight = weightedBalance(
                available[TRANCHE_M].add(locked[TRANCHE_M]),
                available[TRANCHE_A].add(locked[TRANCHE_A]),
                available[TRANCHE_B].add(locked[TRANCHE_B])
            );
            if (weight > 0) {
                // The contract was just upgraded from an old version without boosting
                _workingBalances[account] = weight;
            }
        }
        uint256 availableM = available[TRANCHE_M];
        uint256 availableA = available[TRANCHE_A];
        uint256 availableB = available[TRANCHE_B];
        uint256 lockedM = locked[TRANCHE_M];
        uint256 lockedA = locked[TRANCHE_A];
        uint256 lockedB = locked[TRANCHE_B];
        for (uint256 i = oldVersion; i < targetVersion; i++) {
            rewards = rewards.add(
                weight.multiplyDecimalPrecise(_historicalIntegrals[i].sub(userIntegral))
            );
            if (availableM != 0 || availableA != 0 || availableB != 0) {
                (availableM, availableA, availableB) = _fundDoRebalance(
                    availableM,
                    availableA,
                    availableB,
                    i
                );
            }
            if (lockedM != 0 || lockedA != 0 || lockedB != 0) {
                (lockedM, lockedA, lockedB) = _fundDoRebalance(lockedM, lockedA, lockedB, i);
            }
            userIntegral = 0;

            // Reset per-user weight boosting after the first rebalance
            weight = weightedBalance(
                availableM.add(lockedM),
                availableA.add(lockedA),
                availableB.add(lockedB)
            );
        }
        rewards = rewards.add(weight.multiplyDecimalPrecise(integral.sub(userIntegral)));
        address account_ = account; // Fix the "stack too deep" error
        _claimableRewards[account_] = rewards;
        _userIntegrals[account_] = integral;

        if (oldVersion < targetVersion) {
            if (available[TRANCHE_M] != availableM) {
                available[TRANCHE_M] = availableM;
            }
            if (available[TRANCHE_A] != availableA) {
                available[TRANCHE_A] = availableA;
            }
            if (available[TRANCHE_B] != availableB) {
                available[TRANCHE_B] = availableB;
            }
            if (locked[TRANCHE_M] != lockedM) {
                locked[TRANCHE_M] = lockedM;
            }
            if (locked[TRANCHE_A] != lockedA) {
                locked[TRANCHE_A] = lockedA;
            }
            if (locked[TRANCHE_B] != lockedB) {
                locked[TRANCHE_B] = lockedB;
            }
            _balanceVersions[account_] = targetVersion;
            _workingBalances[account_] = weight;
        }
    }

    /// @dev Calculate working balance, which depends on the amount of staked tokens and veCHESS.
    ///      Before this function is called, both `_checkpoint()` and `_userCheckpoint(account)`
    ///      should be called to update `_workingSupply` and `_workingBalances[account]` to
    ///      the latest rebalance version.
    /// @param account User address
    function _updateWorkingBalance(address account) private {
        uint256 weightedSupply =
            weightedBalance(
                _totalSupplies[TRANCHE_M],
                _totalSupplies[TRANCHE_A],
                _totalSupplies[TRANCHE_B]
            );
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        // Assume weightedBalance(x, 0, 0) always equal to x
        uint256 weightedM = available[TRANCHE_M].add(locked[TRANCHE_M]);
        uint256 weightedAB =
            weightedBalance(
                0,
                available[TRANCHE_A].add(locked[TRANCHE_A]),
                available[TRANCHE_B].add(locked[TRANCHE_B])
            );

        uint256 newWorkingBalance = weightedAB.add(weightedM);
        uint256 veProportion = _veSnapshots[account].veProportion;
        if (veProportion > 0 && _veSnapshots[account].veLocked.unlockTime > block.timestamp) {
            uint256 boostingPower = weightedSupply.multiplyDecimal(veProportion);
            if (boostingPower <= weightedAB) {
                newWorkingBalance = newWorkingBalance.add(
                    boostingPower.multiplyDecimal(MAX_BOOSTING_FACTOR_MINUS_ONE)
                );
            } else {
                uint256 boostingPowerM =
                    (boostingPower - weightedAB)
                        .min(boostingPower.multiplyDecimal(MAX_BOOSTING_POWER_M))
                        .min(weightedM);
                newWorkingBalance = newWorkingBalance.add(
                    weightedAB.add(boostingPowerM).multiplyDecimal(MAX_BOOSTING_FACTOR_MINUS_ONE)
                );
            }
        }

        _workingSupply = _workingSupply.sub(_workingBalances[account]).add(newWorkingBalance);
        _workingBalances[account] = newWorkingBalance;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/ProxyUtility.sol";

import {Order, OrderQueue, LibOrderQueue} from "./LibOrderQueue.sol";
import {
    UnsettledBuyTrade,
    UnsettledSellTrade,
    UnsettledTrade,
    LibUnsettledBuyTrade,
    LibUnsettledSellTrade
} from "./LibUnsettledTrade.sol";

import "./ExchangeRoles.sol";
import "./StakingV2.sol";

/// @title Tranchess's Exchange Contract
/// @notice A decentralized exchange to match premium-discount orders and clear trades
/// @author Tranchess
contract ExchangeV2 is ExchangeRoles, StakingV2, ProxyUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[29] private _reservedSlots;

    using SafeDecimalMath for uint256;
    using LibOrderQueue for OrderQueue;
    using SafeERC20 for IERC20;
    using LibUnsettledBuyTrade for UnsettledBuyTrade;
    using LibUnsettledSellTrade for UnsettledSellTrade;

    /// @notice A maker bid order is placed.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to buy
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Amount of quote asset in the order, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    event BidOrderPlaced(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version,
        uint256 orderIndex
    );

    /// @notice A maker ask order is placed.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to sell
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Amount of base asset in the order
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    event AskOrderPlaced(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version,
        uint256 orderIndex
    );

    /// @notice A maker bid order is canceled.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Original amount of quote asset in the order, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    /// @param fillable Unfilled amount when the order is canceled, rounding precision to 18 for
    ///                 quote assets with precision other than 18 decimal places
    event BidOrderCanceled(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version,
        uint256 orderIndex,
        uint256 fillable
    );

    /// @notice A maker ask order is canceled.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to sell
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Original amount of base asset in the order
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    /// @param fillable Unfilled amount when the order is canceled
    event AskOrderCanceled(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version,
        uint256 orderIndex,
        uint256 fillable
    );

    /// @notice Matching result of a taker bid order.
    /// @param taker Account placing the order
    /// @param tranche Tranche of the share
    /// @param quoteAmount Matched amount of quote asset, rounding precision to 18 for quote assets
    ///                    with precision other than 18 decimal places
    /// @param version Rebalance version of this trade
    /// @param lastMatchedPDLevel Premium-discount level of the last matched maker order
    /// @param lastMatchedOrderIndex Index of the last matched maker order in its order queue
    /// @param lastMatchedBaseAmount Matched base asset amount of the last matched maker order
    event BuyTrade(
        address indexed taker,
        uint256 indexed tranche,
        uint256 quoteAmount,
        uint256 version,
        uint256 lastMatchedPDLevel,
        uint256 lastMatchedOrderIndex,
        uint256 lastMatchedBaseAmount
    );

    /// @notice Matching result of a taker ask order.
    /// @param taker Account placing the order
    /// @param tranche Tranche of the share
    /// @param baseAmount Matched amount of base asset
    /// @param version Rebalance version of this trade
    /// @param lastMatchedPDLevel Premium-discount level of the last matched maker order
    /// @param lastMatchedOrderIndex Index of the last matched maker order in its order queue
    /// @param lastMatchedQuoteAmount Matched quote asset amount of the last matched maker order,
    ///                               rounding precision to 18 for quote assets with precision
    ///                               other than 18 decimal places
    event SellTrade(
        address indexed taker,
        uint256 indexed tranche,
        uint256 baseAmount,
        uint256 version,
        uint256 lastMatchedPDLevel,
        uint256 lastMatchedOrderIndex,
        uint256 lastMatchedQuoteAmount
    );

    /// @notice Settlement of unsettled trades of maker orders.
    /// @param account Account placing the related maker orders
    /// @param epoch Epoch of the settled trades
    /// @param amountM Amount of Token M added to the account's available balance
    /// @param amountA Amount of Token A added to the account's available balance
    /// @param amountB Amount of Token B added to the account's available balance
    /// @param quoteAmount Amount of quote asset transfered to the account, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    event MakerSettled(
        address indexed account,
        uint256 epoch,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 quoteAmount
    );

    /// @notice Settlement of unsettled trades of taker orders.
    /// @param account Account placing the related taker orders
    /// @param epoch Epoch of the settled trades
    /// @param amountM Amount of Token M added to the account's available balance
    /// @param amountA Amount of Token A added to the account's available balance
    /// @param amountB Amount of Token B added to the account's available balance
    /// @param quoteAmount Amount of quote asset transfered to the account, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    event TakerSettled(
        address indexed account,
        uint256 epoch,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 quoteAmount
    );

    uint256 private constant EPOCH = 30 minutes; // An exchange epoch is 30 minutes long

    /// @dev Maker reserves 105% of Token M they want to trade, which would stop
    ///      losses for makers when the net asset values turn out volatile
    uint256 private constant MAKER_RESERVE_RATIO_M = 1.05e18;

    /// @dev Maker reserves 100.1% of Token A they want to trade, which would stop
    ///      losses for makers when the net asset values turn out volatile
    uint256 private constant MAKER_RESERVE_RATIO_A = 1.001e18;

    /// @dev Maker reserves 110% of Token B they want to trade, which would stop
    ///      losses for makers when the net asset values turn out volatile
    uint256 private constant MAKER_RESERVE_RATIO_B = 1.1e18;

    /// @dev Premium-discount level ranges from -10% to 10% with 0.25% as step size
    uint256 private constant PD_TICK = 0.0025e18;

    uint256 private constant MIN_PD = 0.9e18;
    uint256 private constant MAX_PD = 1.1e18;
    uint256 private constant PD_START = MIN_PD - PD_TICK;
    uint256 private constant PD_LEVEL_COUNT = (MAX_PD - MIN_PD) / PD_TICK + 1;

    /// @notice Minumum quote amount of maker bid orders with 18 decimal places
    uint256 public immutable minBidAmount;

    /// @notice Minumum base amount of maker ask orders
    uint256 public immutable minAskAmount;

    /// @notice Minumum base or quote amount of maker orders during guarded launch
    uint256 public immutable guardedLaunchMinOrderAmount;

    /// @dev A multipler that normalizes a quote asset balance to 18 decimal places.
    uint256 private immutable _quoteDecimalMultiplier;

    /// @notice Mapping of rebalance version => tranche => an array of order queues
    mapping(uint256 => mapping(uint256 => OrderQueue[PD_LEVEL_COUNT + 1])) public bids;
    mapping(uint256 => mapping(uint256 => OrderQueue[PD_LEVEL_COUNT + 1])) public asks;

    /// @notice Mapping of rebalance version => best bid premium-discount level of the three tranches.
    ///         Zero indicates that there is no bid order.
    mapping(uint256 => uint256[TRANCHE_COUNT]) public bestBids;

    /// @notice Mapping of rebalance version => best ask premium-discount level of the three tranches.
    ///         Zero or `PD_LEVEL_COUNT + 1` indicates that there is no ask order.
    mapping(uint256 => uint256[TRANCHE_COUNT]) public bestAsks;

    /// @notice Mapping of account => tranche => epoch => unsettled trade
    mapping(address => mapping(uint256 => mapping(uint256 => UnsettledTrade)))
        public unsettledTrades;

    /// @dev Mapping of epoch => rebalance version
    mapping(uint256 => uint256) private _epochVersions;

    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 quoteDecimals_,
        address votingEscrow_,
        uint256 minBidAmount_,
        uint256 minAskAmount_,
        uint256 makerRequirement_,
        uint256 guardedLaunchStart_,
        uint256 guardedLaunchMinOrderAmount_
    )
        public
        ExchangeRoles(votingEscrow_, makerRequirement_)
        StakingV2(
            fund_,
            chessSchedule_,
            chessController_,
            quoteAssetAddress_,
            guardedLaunchStart_,
            votingEscrow_
        )
    {
        minBidAmount = minBidAmount_;
        minAskAmount = minAskAmount_;
        guardedLaunchMinOrderAmount = guardedLaunchMinOrderAmount_;
        require(quoteDecimals_ <= 18, "Quote asset decimals larger than 18");
        _quoteDecimalMultiplier = 10**(18 - quoteDecimals_);
    }

    /// @dev Initialize the contract. The contract is designed to be used with OpenZeppelin's
    ///      `TransparentUpgradeableProxy`. This function should be called by the proxy's
    ///      constructor (via the `_data` argument).
    function initialize() external {
        _initializeStaking();
        _initializeV2(msg.sender);
    }

    /// @dev Initialize the part added in V2. If this contract is upgraded from the previous
    ///      version, call `upgradeToAndCall` of the proxy and put a call to this function
    ///      in the `data` argument.
    function initializeV2(address pauser_) external onlyProxyAdmin {
        _initializeV2(pauser_);
    }

    function _initializeV2(address pauser_) private {
        _initializeStakingV2(pauser_);
    }

    /// @notice Return end timestamp of the epoch containing a given timestamp.
    /// @param timestamp Timestamp within a given epoch
    /// @return The closest ending timestamp
    function endOfEpoch(uint256 timestamp) public pure returns (uint256) {
        return (timestamp / EPOCH) * EPOCH + EPOCH;
    }

    function getMakerReserveRatio(uint256 tranche) public pure returns (uint256) {
        if (tranche == TRANCHE_M) {
            return MAKER_RESERVE_RATIO_M;
        } else if (tranche == TRANCHE_A) {
            return MAKER_RESERVE_RATIO_A;
        } else {
            return MAKER_RESERVE_RATIO_B;
        }
    }

    function getBidOrder(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    )
        external
        view
        returns (
            address maker,
            uint256 amount,
            uint256 fillable
        )
    {
        Order storage order = bids[version][tranche][pdLevel].list[index];
        maker = order.maker;
        amount = order.amount;
        fillable = order.fillable;
    }

    function getAskOrder(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    )
        external
        view
        returns (
            address maker,
            uint256 amount,
            uint256 fillable
        )
    {
        Order storage order = asks[version][tranche][pdLevel].list[index];
        maker = order.maker;
        amount = order.amount;
        fillable = order.fillable;
    }

    /// @notice Get all tranches' net asset values of a given time
    /// @param timestamp Timestamp of the net asset value
    /// @return estimatedNavM Token M's net asset value
    /// @return estimatedNavA Token A's net asset value
    /// @return estimatedNavB Token B's net asset value
    function estimateNavs(uint256 timestamp)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 price = fund.twapOracle().getTwap(timestamp);
        require(price != 0, "Price is not available");
        return fund.extrapolateNav(timestamp, price);
    }

    /// @notice Place a bid order for makers
    /// @param tranche Tranche of the base asset
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Quote asset amount with 18 decimal places
    /// @param version Current rebalance version. Revert if it is not the latest version.
    function placeBid(
        uint256 tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version
    ) external onlyMaker whenNotPaused {
        require(block.timestamp >= guardedLaunchStart + 8 days, "Guarded launch: market closed");
        if (block.timestamp < guardedLaunchStart + 4 weeks) {
            require(quoteAmount >= guardedLaunchMinOrderAmount, "Guarded launch: amount too low");
        } else {
            require(quoteAmount >= minBidAmount, "Quote amount too low");
        }
        uint256 bestAsk = bestAsks[version][tranche];
        require(
            pdLevel > 0 && pdLevel < (bestAsk == 0 ? PD_LEVEL_COUNT + 1 : bestAsk),
            "Invalid premium-discount level"
        );
        require(version == _fundRebalanceSize(), "Invalid version");

        uint256 index = bids[version][tranche][pdLevel].append(msg.sender, quoteAmount, version);
        if (bestBids[version][tranche] < pdLevel) {
            bestBids[version][tranche] = pdLevel;
        }

        _transferQuoteFrom(msg.sender, quoteAmount);

        emit BidOrderPlaced(msg.sender, tranche, pdLevel, quoteAmount, version, index);
    }

    /// @notice Place an ask order for makers
    /// @param tranche Tranche of the base asset
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Base asset amount
    /// @param version Current rebalance version. Revert if it is not the latest version.
    function placeAsk(
        uint256 tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version
    ) external onlyMaker whenNotPaused {
        require(block.timestamp >= guardedLaunchStart + 8 days, "Guarded launch: market closed");
        if (block.timestamp < guardedLaunchStart + 4 weeks) {
            require(baseAmount >= guardedLaunchMinOrderAmount, "Guarded launch: amount too low");
        } else {
            require(baseAmount >= minAskAmount, "Base amount too low");
        }
        require(
            pdLevel > bestBids[version][tranche] && pdLevel <= PD_LEVEL_COUNT,
            "Invalid premium-discount level"
        );
        require(version == _fundRebalanceSize(), "Invalid version");

        _lock(tranche, msg.sender, baseAmount);
        uint256 index = asks[version][tranche][pdLevel].append(msg.sender, baseAmount, version);
        uint256 oldBestAsk = bestAsks[version][tranche];
        if (oldBestAsk > pdLevel || oldBestAsk == 0) {
            bestAsks[version][tranche] = pdLevel;
        }

        emit AskOrderPlaced(msg.sender, tranche, pdLevel, baseAmount, version, index);
    }

    /// @notice Cancel a bid order
    /// @param version Order's rebalance version
    /// @param tranche Tranche of the order's base asset
    /// @param pdLevel Order's premium-discount level
    /// @param index Order's index in the order queue
    function cancelBid(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    ) external whenNotPaused {
        OrderQueue storage orderQueue = bids[version][tranche][pdLevel];
        Order storage order = orderQueue.list[index];
        require(order.maker == msg.sender, "Maker address mismatched");

        uint256 fillable = order.fillable;
        emit BidOrderCanceled(msg.sender, tranche, pdLevel, order.amount, version, index, fillable);
        orderQueue.cancel(index);

        // Update bestBid
        if (bestBids[version][tranche] == pdLevel) {
            uint256 newBestBid = pdLevel;
            while (newBestBid > 0 && bids[version][tranche][newBestBid].isEmpty()) {
                newBestBid--;
            }
            bestBids[version][tranche] = newBestBid;
        }

        _transferQuote(msg.sender, fillable);
    }

    /// @notice Cancel an ask order
    /// @param version Order's rebalance version
    /// @param tranche Tranche of the order's base asset
    /// @param pdLevel Order's premium-discount level
    /// @param index Order's index in the order queue
    function cancelAsk(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    ) external whenNotPaused {
        OrderQueue storage orderQueue = asks[version][tranche][pdLevel];
        Order storage order = orderQueue.list[index];
        require(order.maker == msg.sender, "Maker address mismatched");

        uint256 fillable = order.fillable;
        emit AskOrderCanceled(msg.sender, tranche, pdLevel, order.amount, version, index, fillable);
        orderQueue.cancel(index);

        // Update bestAsk
        if (bestAsks[version][tranche] == pdLevel) {
            uint256 newBestAsk = pdLevel;
            while (newBestAsk <= PD_LEVEL_COUNT && asks[version][tranche][newBestAsk].isEmpty()) {
                newBestAsk++;
            }
            bestAsks[version][tranche] = newBestAsk;
        }

        if (tranche == TRANCHE_M) {
            _rebalanceAndUnlock(msg.sender, fillable, 0, 0, version);
        } else if (tranche == TRANCHE_A) {
            _rebalanceAndUnlock(msg.sender, 0, fillable, 0, version);
        } else {
            _rebalanceAndUnlock(msg.sender, 0, 0, fillable, version);
        }
    }

    /// @notice Buy Token M
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyM(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (uint256 estimatedNav, , ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_M, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Buy Token A
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyA(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (, uint256 estimatedNav, ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_A, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Buy Token B
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyB(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (, , uint256 estimatedNav) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_B, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Sell Token M
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token M willing to trade
    function sellM(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (uint256 estimatedNav, , ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_M, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Sell Token A
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token A willing to trade
    function sellA(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (, uint256 estimatedNav, ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_A, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Sell Token B
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token B willing to trade
    function sellB(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (, , uint256 estimatedNav) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_B, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Settle trades of a specified epoch for makers
    /// @param account Address of the maker
    /// @param epoch A specified epoch's end timestamp
    /// @return amountM Token M amount added to msg.sender's available balance
    /// @return amountA Token A amount added to msg.sender's available balance
    /// @return amountB Token B amount added to msg.sender's available balance
    /// @return quoteAmount Quote asset amount transfered to msg.sender, rounding precison to 18
    ///                     for quote assets with precision other than 18 decimal places
    function settleMaker(address account, uint256 epoch)
        external
        whenNotPaused
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 quoteAmount
        )
    {
        (uint256 estimatedNavM, uint256 estimatedNavA, uint256 estimatedNavB) =
            estimateNavs(epoch.add(EPOCH));

        uint256 quoteAmountM;
        uint256 quoteAmountA;
        uint256 quoteAmountB;
        (amountM, quoteAmountM) = _settleMaker(account, TRANCHE_M, estimatedNavM, epoch);
        (amountA, quoteAmountA) = _settleMaker(account, TRANCHE_A, estimatedNavA, epoch);
        (amountB, quoteAmountB) = _settleMaker(account, TRANCHE_B, estimatedNavB, epoch);

        uint256 version = _epochVersions[epoch];
        (amountM, amountA, amountB) = _rebalanceAndClearTrade(
            account,
            amountM,
            amountA,
            amountB,
            version
        );
        quoteAmount = quoteAmountM.add(quoteAmountA).add(quoteAmountB);
        _transferQuote(account, quoteAmount);

        emit MakerSettled(account, epoch, amountM, amountA, amountB, quoteAmount);
    }

    /// @notice Settle trades of a specified epoch for takers
    /// @param account Address of the maker
    /// @param epoch A specified epoch's end timestamp
    /// @return amountM Token M amount added to msg.sender's available balance
    /// @return amountA Token A amount added to msg.sender's available balance
    /// @return amountB Token B amount added to msg.sender's available balance
    /// @return quoteAmount Quote asset amount transfered to msg.sender, rounding precison to 18
    ///                     for quote assets with precision other than 18 decimal places
    function settleTaker(address account, uint256 epoch)
        external
        whenNotPaused
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 quoteAmount
        )
    {
        (uint256 estimatedNavM, uint256 estimatedNavA, uint256 estimatedNavB) =
            estimateNavs(epoch.add(EPOCH));

        uint256 quoteAmountM;
        uint256 quoteAmountA;
        uint256 quoteAmountB;
        (amountM, quoteAmountM) = _settleTaker(account, TRANCHE_M, estimatedNavM, epoch);
        (amountA, quoteAmountA) = _settleTaker(account, TRANCHE_A, estimatedNavA, epoch);
        (amountB, quoteAmountB) = _settleTaker(account, TRANCHE_B, estimatedNavB, epoch);

        uint256 version = _epochVersions[epoch];
        (amountM, amountA, amountB) = _rebalanceAndClearTrade(
            account,
            amountM,
            amountA,
            amountB,
            version
        );
        quoteAmount = quoteAmountM.add(quoteAmountA).add(quoteAmountB);
        _transferQuote(account, quoteAmount);

        emit TakerSettled(account, epoch, amountM, amountA, amountB, quoteAmount);
    }

    /// @dev Buy share
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param tranche Tranche of the base asset
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param estimatedNav Estimated net asset value of the base asset
    /// @param quoteAmount Amount of quote assets willing to trade with 18 decimal places
    function _buy(
        uint256 version,
        uint256 tranche,
        uint256 maxPDLevel,
        uint256 estimatedNav,
        uint256 quoteAmount
    ) internal onlyActive whenNotPaused {
        require(maxPDLevel > 0 && maxPDLevel <= PD_LEVEL_COUNT, "Invalid premium-discount level");
        require(version == _fundRebalanceSize(), "Invalid version");
        require(estimatedNav > 0, "Zero estimated NAV");

        UnsettledBuyTrade memory totalTrade;
        uint256 epoch = endOfEpoch(block.timestamp);

        // Record rebalance version in the first transaction in the epoch
        if (_epochVersions[epoch] == 0) {
            _epochVersions[epoch] = version;
        }

        UnsettledBuyTrade memory currentTrade;
        uint256 orderIndex = 0;
        uint256 pdLevel = bestAsks[version][tranche];
        if (pdLevel == 0) {
            // Zero best ask indicates that no ask order is ever placed.
            // We set pdLevel beyond the largest valid level, forcing the following loop
            // to exit immediately.
            pdLevel = PD_LEVEL_COUNT + 1;
        }
        for (; pdLevel <= maxPDLevel; pdLevel++) {
            uint256 price = pdLevel.mul(PD_TICK).add(PD_START).multiplyDecimal(estimatedNav);
            OrderQueue storage orderQueue = asks[version][tranche][pdLevel];
            orderIndex = orderQueue.head;
            while (orderIndex != 0) {
                Order storage order = orderQueue.list[orderIndex];

                // If the order initiator is no longer qualified for maker,
                // we skip the order and the linked-list-based order queue
                // would never traverse the order again
                if (!isMaker(order.maker)) {
                    orderIndex = order.next;
                    continue;
                }

                // Scope to avoid "stack too deep"
                {
                    // Calculate the current trade assuming that the taker would be completely filled.
                    uint256 makerReserveRatio = getMakerReserveRatio(tranche);
                    currentTrade.frozenQuote = quoteAmount.sub(totalTrade.frozenQuote);
                    currentTrade.reservedBase = currentTrade.frozenQuote.mul(makerReserveRatio).div(
                        price
                    );

                    if (currentTrade.reservedBase < order.fillable) {
                        // Taker is completely filled.
                        currentTrade.effectiveQuote = currentTrade.frozenQuote.divideDecimal(
                            pdLevel.mul(PD_TICK).add(PD_START)
                        );
                    } else {
                        // Maker is completely filled. Recalculate the current trade.
                        currentTrade.frozenQuote = order.fillable.mul(price).div(makerReserveRatio);
                        currentTrade.effectiveQuote = order.fillable.mul(estimatedNav).div(
                            makerReserveRatio
                        );
                        currentTrade.reservedBase = order.fillable;
                    }
                }
                totalTrade.frozenQuote = totalTrade.frozenQuote.add(currentTrade.frozenQuote);
                totalTrade.effectiveQuote = totalTrade.effectiveQuote.add(
                    currentTrade.effectiveQuote
                );
                totalTrade.reservedBase = totalTrade.reservedBase.add(currentTrade.reservedBase);
                unsettledTrades[order.maker][tranche][epoch].makerSell.add(currentTrade);

                // There is no need to rebalance for maker; the fact that the order could
                // be filled here indicates that the maker is in the latest version
                _tradeLocked(tranche, order.maker, currentTrade.reservedBase);

                uint256 orderNewFillable = order.fillable.sub(currentTrade.reservedBase);
                if (orderNewFillable > 0) {
                    // Maker is not completely filled. Matching ends here.
                    order.fillable = orderNewFillable;
                    break;
                } else {
                    // Delete the completely filled maker order.
                    orderIndex = orderQueue.fill(orderIndex);
                }
            }

            orderQueue.updateHead(orderIndex);
            if (orderIndex != 0) {
                // This premium-discount level is not completely filled. Matching ends here.
                if (bestAsks[version][tranche] != pdLevel) {
                    bestAsks[version][tranche] = pdLevel;
                }
                break;
            }
        }
        emit BuyTrade(
            msg.sender,
            tranche,
            totalTrade.frozenQuote,
            version,
            pdLevel,
            orderIndex,
            orderIndex == 0 ? 0 : currentTrade.reservedBase
        );
        if (orderIndex == 0) {
            // Matching ends by completely filling all orders at and below the specified
            // premium-discount level `maxPDLevel`.
            // Find the new best ask beyond that level.
            for (; pdLevel <= PD_LEVEL_COUNT; pdLevel++) {
                if (!asks[version][tranche][pdLevel].isEmpty()) {
                    break;
                }
            }
            bestAsks[version][tranche] = pdLevel;
        }

        require(
            totalTrade.frozenQuote > 0,
            "Nothing can be bought at the given premium-discount level"
        );
        unsettledTrades[msg.sender][tranche][epoch].takerBuy.add(totalTrade);
        _transferQuoteFrom(msg.sender, totalTrade.frozenQuote);
    }

    /// @dev Sell share
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param tranche Tranche of the base asset
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param estimatedNav Estimated net asset value of the base asset
    /// @param baseAmount Amount of base assets willing to trade
    function _sell(
        uint256 version,
        uint256 tranche,
        uint256 minPDLevel,
        uint256 estimatedNav,
        uint256 baseAmount
    ) internal onlyActive whenNotPaused {
        require(minPDLevel > 0 && minPDLevel <= PD_LEVEL_COUNT, "Invalid premium-discount level");
        require(version == _fundRebalanceSize(), "Invalid version");
        require(estimatedNav > 0, "Zero estimated NAV");

        UnsettledSellTrade memory totalTrade;
        uint256 epoch = endOfEpoch(block.timestamp);

        // Record rebalance version in the first transaction in the epoch
        if (_epochVersions[epoch] == 0) {
            _epochVersions[epoch] = version;
        }

        UnsettledSellTrade memory currentTrade;
        uint256 orderIndex;
        uint256 pdLevel = bestBids[version][tranche];
        for (; pdLevel >= minPDLevel; pdLevel--) {
            uint256 price = pdLevel.mul(PD_TICK).add(PD_START).multiplyDecimal(estimatedNav);
            OrderQueue storage orderQueue = bids[version][tranche][pdLevel];
            orderIndex = orderQueue.head;
            while (orderIndex != 0) {
                Order storage order = orderQueue.list[orderIndex];

                // If the order initiator is no longer qualified for maker,
                // we skip the order and the linked-list-based order queue
                // would never traverse the order again
                if (!isMaker(order.maker)) {
                    orderIndex = order.next;
                    continue;
                }

                // Scope to avoid "stack too deep"
                {
                    // Calculate the current trade assuming that the taker would be completely filled.
                    uint256 makerReserveRatio = getMakerReserveRatio(tranche);
                    currentTrade.frozenBase = baseAmount.sub(totalTrade.frozenBase);
                    currentTrade.reservedQuote = currentTrade
                        .frozenBase
                        .multiplyDecimal(makerReserveRatio)
                        .multiplyDecimal(price);

                    if (currentTrade.reservedQuote < order.fillable) {
                        // Taker is completely filled
                        currentTrade.effectiveBase = currentTrade.frozenBase.multiplyDecimal(
                            pdLevel.mul(PD_TICK).add(PD_START)
                        );
                    } else {
                        // Maker is completely filled. Recalculate the current trade.
                        currentTrade.frozenBase = order.fillable.divideDecimal(price).divideDecimal(
                            makerReserveRatio
                        );
                        currentTrade.effectiveBase = order
                            .fillable
                            .divideDecimal(estimatedNav)
                            .divideDecimal(makerReserveRatio);
                        currentTrade.reservedQuote = order.fillable;
                    }
                }
                totalTrade.frozenBase = totalTrade.frozenBase.add(currentTrade.frozenBase);
                totalTrade.effectiveBase = totalTrade.effectiveBase.add(currentTrade.effectiveBase);
                totalTrade.reservedQuote = totalTrade.reservedQuote.add(currentTrade.reservedQuote);
                unsettledTrades[order.maker][tranche][epoch].makerBuy.add(currentTrade);

                uint256 orderNewFillable = order.fillable.sub(currentTrade.reservedQuote);
                if (orderNewFillable > 0) {
                    // Maker is not completely filled. Matching ends here.
                    order.fillable = orderNewFillable;
                    break;
                } else {
                    // Delete the completely filled maker order.
                    orderIndex = orderQueue.fill(orderIndex);
                }
            }

            orderQueue.updateHead(orderIndex);
            if (orderIndex != 0) {
                // This premium-discount level is not completely filled. Matching ends here.
                if (bestBids[version][tranche] != pdLevel) {
                    bestBids[version][tranche] = pdLevel;
                }
                break;
            }
        }
        emit SellTrade(
            msg.sender,
            tranche,
            totalTrade.frozenBase,
            version,
            pdLevel,
            orderIndex,
            orderIndex == 0 ? 0 : currentTrade.reservedQuote
        );
        if (orderIndex == 0) {
            // Matching ends by completely filling all orders at and above the specified
            // premium-discount level `minPDLevel`.
            // Find the new best bid beyond that level.
            for (; pdLevel > 0; pdLevel--) {
                if (!bids[version][tranche][pdLevel].isEmpty()) {
                    break;
                }
            }
            bestBids[version][tranche] = pdLevel;
        }

        require(
            totalTrade.frozenBase > 0,
            "Nothing can be sold at the given premium-discount level"
        );
        _tradeAvailable(tranche, msg.sender, totalTrade.frozenBase);
        unsettledTrades[msg.sender][tranche][epoch].takerSell.add(totalTrade);
    }

    /// @dev Settle both buy and sell trades of a specified epoch for takers
    /// @param account Taker address
    /// @param tranche Tranche of the base asset
    /// @param estimatedNav Estimated net asset value for the base asset
    /// @param epoch The epoch's end timestamp
    function _settleTaker(
        address account,
        uint256 tranche,
        uint256 estimatedNav,
        uint256 epoch
    ) internal returns (uint256 baseAmount, uint256 quoteAmount) {
        UnsettledTrade storage unsettledTrade = unsettledTrades[account][tranche][epoch];

        // Settle buy trade
        UnsettledBuyTrade memory takerBuy = unsettledTrade.takerBuy;
        if (takerBuy.frozenQuote > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _buyTradeResult(takerBuy, estimatedNav);
            baseAmount = executionBase;
            quoteAmount = takerBuy.frozenQuote.sub(executionQuote);
            delete unsettledTrade.takerBuy;
        }

        // Settle sell trade
        UnsettledSellTrade memory takerSell = unsettledTrade.takerSell;
        if (takerSell.frozenBase > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _sellTradeResult(takerSell, estimatedNav);
            quoteAmount = quoteAmount.add(executionQuote);
            baseAmount = baseAmount.add(takerSell.frozenBase.sub(executionBase));
            delete unsettledTrade.takerSell;
        }
    }

    /// @dev Settle both buy and sell trades of a specified epoch for makers
    /// @param account Maker address
    /// @param tranche Tranche of the base asset
    /// @param estimatedNav Estimated net asset value for the base asset
    /// @param epoch The epoch's end timestamp
    function _settleMaker(
        address account,
        uint256 tranche,
        uint256 estimatedNav,
        uint256 epoch
    ) internal returns (uint256 baseAmount, uint256 quoteAmount) {
        UnsettledTrade storage unsettledTrade = unsettledTrades[account][tranche][epoch];

        // Settle buy trade
        UnsettledSellTrade memory makerBuy = unsettledTrade.makerBuy;
        if (makerBuy.frozenBase > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _sellTradeResult(makerBuy, estimatedNav);
            baseAmount = executionBase;
            quoteAmount = makerBuy.reservedQuote.sub(executionQuote);
            delete unsettledTrade.makerBuy;
        }

        // Settle sell trade
        UnsettledBuyTrade memory makerSell = unsettledTrade.makerSell;
        if (makerSell.frozenQuote > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _buyTradeResult(makerSell, estimatedNav);
            quoteAmount = quoteAmount.add(executionQuote);
            baseAmount = baseAmount.add(makerSell.reservedBase.sub(executionBase));
            delete unsettledTrade.makerSell;
        }
    }

    /// @dev Calculate the result of an unsettled buy trade with a given NAV
    /// @param buyTrade Buy trade result of this particular epoch
    /// @param nav Net asset value for the base asset
    /// @return executionQuote Real amount of quote asset waiting for settlment
    /// @return executionBase Real amount of base asset waiting for settlment
    function _buyTradeResult(UnsettledBuyTrade memory buyTrade, uint256 nav)
        internal
        pure
        returns (uint256 executionQuote, uint256 executionBase)
    {
        uint256 reservedBase = buyTrade.reservedBase;
        uint256 reservedQuote = reservedBase.multiplyDecimal(nav);
        uint256 effectiveQuote = buyTrade.effectiveQuote;
        if (effectiveQuote < reservedQuote) {
            // Reserved base is enough to execute the trade.
            // nav is always positive here
            return (buyTrade.frozenQuote, effectiveQuote.divideDecimal(nav));
        } else {
            // Reserved base is not enough. The trade is partially executed
            // and a fraction of frozenQuote is returned to the taker.
            return (buyTrade.frozenQuote.mul(reservedQuote).div(effectiveQuote), reservedBase);
        }
    }

    /// @dev Calculate the result of an unsettled sell trade with a given NAV
    /// @param sellTrade Sell trade result of this particular epoch
    /// @param nav Net asset value for the base asset
    /// @return executionQuote Real amount of quote asset waiting for settlment
    /// @return executionBase Real amount of base asset waiting for settlment
    function _sellTradeResult(UnsettledSellTrade memory sellTrade, uint256 nav)
        internal
        pure
        returns (uint256 executionQuote, uint256 executionBase)
    {
        uint256 reservedQuote = sellTrade.reservedQuote;
        uint256 effectiveQuote = sellTrade.effectiveBase.multiplyDecimal(nav);
        if (effectiveQuote < reservedQuote) {
            // Reserved quote is enough to execute the trade.
            return (effectiveQuote, sellTrade.frozenBase);
        } else {
            // Reserved quote is not enough. The trade is partially executed
            // and a fraction of frozenBase is returned to the taker.
            return (reservedQuote, sellTrade.frozenBase.mul(reservedQuote).div(effectiveQuote));
        }
    }

    /// @dev Transfer quote asset to an account. Transfered amount is rounded down.
    /// @param account Recipient address
    /// @param amount Amount to transfer with 18 decimal places
    function _transferQuote(address account, uint256 amount) private {
        uint256 amountToTransfer = amount / _quoteDecimalMultiplier;
        if (amountToTransfer == 0) {
            return;
        }
        IERC20(quoteAssetAddress).safeTransfer(account, amountToTransfer);
    }

    /// @dev Transfer quote asset from an account. Transfered amount is rounded up.
    /// @param account Sender address
    /// @param amount Amount to transfer with 18 decimal places
    function _transferQuoteFrom(address account, uint256 amount) private {
        uint256 amountToTransfer =
            amount.add(_quoteDecimalMultiplier - 1) / _quoteDecimalMultiplier;
        IERC20(quoteAssetAddress).safeTransferFrom(account, address(this), amountToTransfer);
    }

    modifier onlyActive() {
        require(fund.isExchangeActive(block.timestamp), "Exchange is inactive");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/CoreUtility.sol";

import "../interfaces/IPrimaryMarket.sol";
import "../interfaces/IFund.sol";
import "../../interfaces/ITwapOracle.sol";
import "../../interfaces/IAprOracle.sol";
import "../../interfaces/IBallot.sol";
import "../../interfaces/IVotingEscrow.sol";
import "../interfaces/ITrancheIndex.sol";

import "./FundRoles.sol";

contract Fund is IFund, Ownable, ReentrancyGuard, FundRoles, CoreUtility, ITrancheIndex {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant UNIT = 1e18;
    uint256 private constant MAX_INTEREST_RATE = 0.2e18; // 20% daily
    uint256 private constant MAX_DAILY_PROTOCOL_FEE_RATE = 0.05e18; // 5% daily rate

    uint256 private constant WEIGHT_A = 1;
    uint256 private constant WEIGHT_B = 1;
    uint256 private constant WEIGHT_M = WEIGHT_A + WEIGHT_B;

    /// @notice Upper bound of `NAV_B / NAV_A` to trigger a rebalance.
    uint256 public immutable upperRebalanceThreshold;

    /// @notice Lower bound of `NAV_B / NAV_A` to trigger a rebalance.
    uint256 public immutable lowerRebalanceThreshold;

    /// @notice Address of the underlying token.
    address public immutable override tokenUnderlying;

    /// @notice A multipler that normalizes an underlying balance to 18 decimal places.
    uint256 public immutable override underlyingDecimalMultiplier;

    /// @notice Daily protocol fee rate.
    uint256 public dailyProtocolFeeRate;

    /// @notice TwapOracle address for the underlying asset.
    ITwapOracle public override twapOracle;

    /// @notice AprOracle address.
    IAprOracle public aprOracle;

    /// @notice Address of the interest rate ballot.
    IBallot public ballot;

    /// @notice Fee Collector address.
    address public override feeCollector;

    /// @notice Address of Token M.
    address public override tokenM;

    /// @notice Address of Token A.
    address public override tokenA;

    /// @notice Address of Token B.
    address public override tokenB;

    /// @notice End timestamp of the current trading day.
    ///         A trading day starts at UTC time `SETTLEMENT_TIME` of a day (inclusive)
    ///         and ends at the same time of the next day (exclusive).
    uint256 public override currentDay;

    /// @notice Start timestamp of the current primary market activity window.
    uint256 public override fundActivityStartTime;

    /// @notice Start timestamp of the current exchange activity window.
    uint256 public override exchangeActivityStartTime;

    uint256 public activityDelayTimeAfterRebalance;

    /// @dev Historical rebalances. Rebalances are often accessed in loops with bounds checking.
    ///      So we store them in a fixed-length array, in order to make compiler-generated
    ///      bounds checking on every access cheaper. The actual length of this array is stored in
    ///      `_rebalanceSize` and should be explicitly checked when necessary.
    Rebalance[65535] private _rebalances;

    /// @dev Historical rebalance count.
    uint256 private _rebalanceSize;

    /// @dev Total share supply of the three tranches. They are always rebalanced to the latest
    ///      version.
    uint256[TRANCHE_COUNT] private _totalSupplies;

    /// @dev Mapping of account => share balance of the three tranches.
    ///      Rebalance versions are stored in a separate mapping `_balanceVersions`.
    mapping(address => uint256[TRANCHE_COUNT]) private _balances;

    /// @dev Rebalance version mapping for `_balances`.
    mapping(address => uint256) private _balanceVersions;

    /// @dev Mapping of owner => spender => share allowance of the three tranches.
    ///      Rebalance versions are stored in a separate mapping `_allowanceVersions`.
    mapping(address => mapping(address => uint256[TRANCHE_COUNT])) private _allowances;

    /// @dev Rebalance version mapping for `_allowances`.
    mapping(address => mapping(address => uint256)) private _allowanceVersions;

    /// @dev Mapping of trading day => NAV tuple.
    mapping(uint256 => uint256[TRANCHE_COUNT]) private _historicalNavs;

    /// @notice Mapping of trading day => total fund shares.
    ///
    ///         Key is the end timestamp of a trading day. Value is the total fund shares after
    ///         settlement of that trading day, as if all Token A and B are merged.
    mapping(uint256 => uint256) public override historicalTotalShares;

    /// @notice Mapping of trading day => underlying assets in the fund.
    ///
    ///         Key is the end timestamp of a trading day. Value is the underlying assets in
    ///         the fund after settlement of that trading day.
    mapping(uint256 => uint256) public historicalUnderlying;

    /// @notice Mapping of trading week => interest rate of Token A.
    ///
    ///         Key is the end timestamp of a trading week. Value is the interest rate captured
    ///         after settlement of the last day of the previous trading week.
    mapping(uint256 => uint256) public historicalInterestRate;

    address[] private obsoletePrimaryMarkets;
    address[] private newPrimaryMarkets;

    constructor(
        address tokenUnderlying_,
        uint256 underlyingDecimals_,
        uint256 dailyProtocolFeeRate_,
        uint256 upperRebalanceThreshold_,
        uint256 lowerRebalanceThreshold_,
        address twapOracle_,
        address aprOracle_,
        address ballot_,
        address feeCollector_
    ) public Ownable() FundRoles() {
        tokenUnderlying = tokenUnderlying_;
        require(underlyingDecimals_ <= 18, "Underlying decimals larger than 18");
        underlyingDecimalMultiplier = 10**(18 - underlyingDecimals_);
        require(
            dailyProtocolFeeRate_ <= MAX_DAILY_PROTOCOL_FEE_RATE,
            "Exceed max protocol fee rate"
        );
        dailyProtocolFeeRate = dailyProtocolFeeRate_;
        upperRebalanceThreshold = upperRebalanceThreshold_;
        lowerRebalanceThreshold = lowerRebalanceThreshold_;
        twapOracle = ITwapOracle(twapOracle_);
        aprOracle = IAprOracle(aprOracle_);
        ballot = IBallot(ballot_);
        feeCollector = feeCollector_;

        currentDay = endOfDay(block.timestamp);
        uint256 lastDay = currentDay - 1 days;
        uint256 currentPrice = twapOracle.getTwap(lastDay);
        require(currentPrice != 0, "Price not available");
        _historicalNavs[lastDay][TRANCHE_M] = UNIT;
        _historicalNavs[lastDay][TRANCHE_A] = UNIT;
        _historicalNavs[lastDay][TRANCHE_B] = UNIT;
        historicalInterestRate[_endOfWeek(lastDay)] = MAX_INTEREST_RATE.min(aprOracle.capture());
        fundActivityStartTime = lastDay;
        exchangeActivityStartTime = lastDay + 30 minutes;
        activityDelayTimeAfterRebalance = 12 hours;
    }

    function initialize(
        address tokenM_,
        address tokenA_,
        address tokenB_,
        address primaryMarket_
    ) external onlyOwner {
        require(tokenM == address(0) && tokenM_ != address(0), "Already initialized");
        tokenM = tokenM_;
        tokenA = tokenA_;
        tokenB = tokenB_;
        _initializeRoles(tokenM_, tokenA_, tokenB_, primaryMarket_);
    }

    /// @notice Return weights of Token A and B when splitting Token M.
    /// @return weightA Weight of Token A
    /// @return weightB Weight of Token B
    function trancheWeights() external pure override returns (uint256 weightA, uint256 weightB) {
        return (WEIGHT_A, WEIGHT_B);
    }

    /// @notice UTC time of a day when the fund settles.
    function settlementTime() external pure returns (uint256) {
        return SETTLEMENT_TIME;
    }

    /// @notice Return end timestamp of the trading day containing a given timestamp.
    ///
    ///         A trading day starts at UTC time `SETTLEMENT_TIME` of a day (inclusive)
    ///         and ends at the same time of the next day (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading day.
    function endOfDay(uint256 timestamp) public pure override returns (uint256) {
        return ((timestamp.add(1 days) - SETTLEMENT_TIME) / 1 days) * 1 days + SETTLEMENT_TIME;
    }

    /// @notice Return end timestamp of the trading week containing a given timestamp.
    ///
    ///         A trading week starts at UTC time `SETTLEMENT_TIME` on a Thursday (inclusive)
    ///         and ends at the same time of the next Thursday (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading week.
    function endOfWeek(uint256 timestamp) external pure returns (uint256) {
        return _endOfWeek(timestamp);
    }

    /// @notice Return the status of the fund contract.
    /// @param timestamp Timestamp to assess
    /// @return True if the fund contract is active
    function isFundActive(uint256 timestamp) public view override returns (bool) {
        return timestamp >= fundActivityStartTime;
    }

    /// @notice Return the status of a given primary market contract.
    /// @param primaryMarket The primary market contract address
    /// @param timestamp Timestamp to assess
    /// @return True if the primary market contract is active
    function isPrimaryMarketActive(address primaryMarket, uint256 timestamp)
        public
        view
        override
        returns (bool)
    {
        return
            isPrimaryMarket(primaryMarket) &&
            timestamp >= fundActivityStartTime &&
            timestamp < currentDay;
    }

    /// @notice Return the status of the exchange. Unlike the primary market, exchange is
    ///         anonymous to fund
    /// @param timestamp Timestamp to assess
    /// @return True if the exchange contract is active
    function isExchangeActive(uint256 timestamp) public view override returns (bool) {
        return (timestamp >= exchangeActivityStartTime && timestamp < (currentDay - 60 minutes));
    }

    /// @notice Total shares of the fund, as if all Token A and B are merged.
    function getTotalShares() public view override returns (uint256) {
        return
            _totalSupplies[TRANCHE_M].add(_totalSupplies[TRANCHE_A]).add(_totalSupplies[TRANCHE_B]);
    }

    /// @notice Return the rebalance matrix at a given index. A zero struct is returned
    ///         if `index` is out of bound.
    /// @param index Rebalance index
    /// @return A rebalance matrix
    function getRebalance(uint256 index) external view override returns (Rebalance memory) {
        return _rebalances[index];
    }

    /// @notice Return timestamp of the transaction triggering the rebalance at a given index.
    ///         Zero is returned if `index` is out of bound.
    /// @param index Rebalance index
    /// @return Timestamp of the rebalance
    function getRebalanceTimestamp(uint256 index) external view override returns (uint256) {
        return _rebalances[index].timestamp;
    }

    /// @notice Return the number of historical rebalances.
    function getRebalanceSize() external view override returns (uint256) {
        return _rebalanceSize;
    }

    /// @notice Return NAV of Token M, A and B of the given trading day.
    /// @param day End timestamp of a trading day
    /// @return NAV of Token M, A and B
    function historicalNavs(uint256 day)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _historicalNavs[day][TRANCHE_M],
            _historicalNavs[day][TRANCHE_A],
            _historicalNavs[day][TRANCHE_B]
        );
    }

    /// @notice Estimate NAV of all tranches at a given timestamp, considering underlying price
    ///         change, accrued protocol fee and accrued interest since the previous settlement.
    ///
    ///         The extrapolation uses simple interest instead of daily compound interest in
    ///         calculating protocol fee and Token A's interest. There may be significant error
    ///         in the returned values when `timestamp` is far beyond the last settlement.
    /// @param timestamp Timestamp to estimate
    /// @param price Price of the underlying asset (18 decimal places)
    /// @return Estimated NAV of all tranches
    function extrapolateNav(uint256 timestamp, uint256 price)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        // Find the last settled trading day before the given timestamp.
        uint256 previousDay = currentDay - 1 days;
        if (previousDay > timestamp) {
            previousDay = endOfDay(timestamp) - 1 days;
        }
        uint256 previousShares = historicalTotalShares[previousDay];
        uint256 navM = _extrapolateNavM(previousDay, previousShares, timestamp, price);
        uint256 navA = _extrapolateNavA(previousDay, previousShares, timestamp);
        uint256 navB = calculateNavB(navM, navA);
        return (navM, navA, navB);
    }

    function _extrapolateNavM(
        uint256 previousDay,
        uint256 previousShares,
        uint256 timestamp,
        uint256 price
    ) private view returns (uint256) {
        uint256 navM;
        if (previousShares == 0) {
            // The fund is empty. Just return the previous recorded NAV.
            navM = _historicalNavs[previousDay][TRANCHE_M];
            if (navM == 0) {
                // No NAV is recorded because the given timestamp is before the fund launches.
                return UNIT;
            } else {
                return navM;
            }
        }
        uint256 totalValue =
            price.mul(historicalUnderlying[previousDay].mul(underlyingDecimalMultiplier));
        uint256 accruedFee =
            totalValue.multiplyDecimal(dailyProtocolFeeRate).mul(timestamp - previousDay).div(
                1 days
            );
        navM = (totalValue - accruedFee).div(previousShares);
        return navM;
    }

    function _extrapolateNavA(
        uint256 previousDay,
        uint256 previousShares,
        uint256 timestamp
    ) private view returns (uint256) {
        uint256 navA = _historicalNavs[previousDay][TRANCHE_A];
        if (previousShares == 0) {
            // The fund is empty. Just return the previous recorded NAV.
            if (navA == 0) {
                // No NAV is recorded because the given timestamp is before the fund launches.
                return UNIT;
            } else {
                return navA;
            }
        }

        uint256 week = _endOfWeek(previousDay);
        uint256 newNavA =
            navA
                .multiplyDecimal(
                UNIT.sub(dailyProtocolFeeRate.mul(timestamp - previousDay).div(1 days))
            )
                .multiplyDecimal(
                UNIT.add(historicalInterestRate[week].mul(timestamp - previousDay).div(1 days))
            );
        return newNavA > navA ? newNavA : navA;
    }

    function calculateNavB(uint256 navM, uint256 navA) public pure override returns (uint256) {
        // Using unchecked multiplications because they are unlikely to overflow
        if (navM * WEIGHT_M >= navA * WEIGHT_A) {
            return (navM * WEIGHT_M - navA * WEIGHT_A) / WEIGHT_B;
        } else {
            return 0;
        }
    }

    /// @notice Transform share amounts according to the rebalance at a given index.
    ///         This function performs no bounds checking on the given index. A non-existent
    ///         rebalance transforms anything to a zero vector.
    /// @param amountM Amount of Token M before the rebalance
    /// @param amountA Amount of Token A before the rebalance
    /// @param amountB Amount of Token B before the rebalance
    /// @param index Rebalance index
    /// @return newAmountM Amount of Token M after the rebalance
    /// @return newAmountA Amount of Token A after the rebalance
    /// @return newAmountB Amount of Token B after the rebalance
    function doRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 index
    )
        public
        view
        override
        returns (
            uint256 newAmountM,
            uint256 newAmountA,
            uint256 newAmountB
        )
    {
        Rebalance storage rebalance = _rebalances[index];
        newAmountM = amountM
            .multiplyDecimal(rebalance.ratioM)
            .add(amountA.multiplyDecimal(rebalance.ratioA2M))
            .add(amountB.multiplyDecimal(rebalance.ratioB2M));
        uint256 ratioAB = rebalance.ratioAB; // Gas saver
        newAmountA = amountA.multiplyDecimal(ratioAB);
        newAmountB = amountB.multiplyDecimal(ratioAB);
    }

    /// @notice Transform share amounts according to rebalances in a given index range,
    ///         This function performs no bounds checking on the given indices. The original amounts
    ///         are returned if `fromIndex` is no less than `toIndex`. A zero vector is returned
    ///         if `toIndex` is greater than the number of existing rebalances.
    /// @param amountM Amount of Token M before the rebalance
    /// @param amountA Amount of Token A before the rebalance
    /// @param amountB Amount of Token B before the rebalance
    /// @param fromIndex Starting of the rebalance index range, inclusive
    /// @param toIndex End of the rebalance index range, exclusive
    /// @return newAmountM Amount of Token M after the rebalance
    /// @return newAmountA Amount of Token A after the rebalance
    /// @return newAmountB Amount of Token B after the rebalance
    function batchRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 fromIndex,
        uint256 toIndex
    )
        external
        view
        override
        returns (
            uint256 newAmountM,
            uint256 newAmountA,
            uint256 newAmountB
        )
    {
        for (uint256 i = fromIndex; i < toIndex; i++) {
            (amountM, amountA, amountB) = doRebalance(amountM, amountA, amountB, i);
        }
        newAmountM = amountM;
        newAmountA = amountA;
        newAmountB = amountB;
    }

    /// @notice Transform share balance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshBalance(address account, uint256 targetVersion) external override {
        if (targetVersion > 0) {
            require(targetVersion <= _rebalanceSize, "Target version out of bound");
        }
        _refreshBalance(account, targetVersion);
    }

    /// @notice Transform allowance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param owner Owner of the allowance to rebalance
    /// @param spender Spender of the allowance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) external override {
        if (targetVersion > 0) {
            require(targetVersion <= _rebalanceSize, "Target version out of bound");
        }
        _refreshAllowance(owner, spender, targetVersion);
    }

    function shareBalanceOf(uint256 tranche, address account)
        external
        view
        override
        returns (uint256)
    {
        uint256 amountM = _balances[account][TRANCHE_M];
        uint256 amountA = _balances[account][TRANCHE_A];
        uint256 amountB = _balances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _balanceVersions[account]; i < size; i++) {
            (amountM, amountA, amountB) = doRebalance(amountM, amountA, amountB, i);
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    /// @notice Return all three share balances transformed to the latest rebalance version.
    /// @param account Owner of the shares
    function allShareBalanceOf(address account)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 amountM = _balances[account][TRANCHE_M];
        uint256 amountA = _balances[account][TRANCHE_A];
        uint256 amountB = _balances[account][TRANCHE_B];

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _balanceVersions[account]; i < size; i++) {
            (amountM, amountA, amountB) = doRebalance(amountM, amountA, amountB, i);
        }

        return (amountM, amountA, amountB);
    }

    function shareBalanceVersion(address account) external view override returns (uint256) {
        return _balanceVersions[account];
    }

    function shareAllowance(
        uint256 tranche,
        address owner,
        address spender
    ) external view override returns (uint256) {
        uint256 allowanceM = _allowances[owner][spender][TRANCHE_M];
        uint256 allowanceA = _allowances[owner][spender][TRANCHE_A];
        uint256 allowanceB = _allowances[owner][spender][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (allowanceM == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (allowanceA == 0) return 0;
        } else {
            if (allowanceB == 0) return 0;
        }

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _allowanceVersions[owner][spender]; i < size; i++) {
            (allowanceM, allowanceA, allowanceB) = _rebalanceAllowance(
                allowanceM,
                allowanceA,
                allowanceB,
                i
            );
        }

        if (tranche == TRANCHE_M) {
            return allowanceM;
        } else if (tranche == TRANCHE_A) {
            return allowanceA;
        } else {
            return allowanceB;
        }
    }

    function shareAllowanceVersion(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowanceVersions[owner][spender];
    }

    function shareTotalSupply(uint256 tranche) external view override returns (uint256) {
        return _totalSupplies[tranche];
    }

    function mint(
        uint256 tranche,
        address account,
        uint256 amount
    ) external override onlyPrimaryMarket {
        _refreshBalance(account, _rebalanceSize);
        _mint(tranche, account, amount);
    }

    function burn(
        uint256 tranche,
        address account,
        uint256 amount
    ) external override onlyPrimaryMarket {
        _refreshBalance(account, _rebalanceSize);
        _burn(tranche, account, amount);
    }

    function transfer(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount
    ) public override onlyShare {
        require(isFundActive(block.timestamp), "Transfer is inactive");
        _refreshBalance(sender, _rebalanceSize);
        _refreshBalance(recipient, _rebalanceSize);
        _transfer(tranche, sender, recipient, amount);
    }

    function transferFrom(
        uint256 tranche,
        address spender,
        address sender,
        address recipient,
        uint256 amount
    ) external override onlyShare returns (uint256 newAllowance) {
        transfer(tranche, sender, recipient, amount);

        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].sub(
            amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(tranche, sender, spender, newAllowance);
    }

    function approve(
        uint256 tranche,
        address owner,
        address spender,
        uint256 amount
    ) external override onlyShare {
        _refreshAllowance(owner, spender, _rebalanceSize);
        _approve(tranche, owner, spender, amount);
    }

    function increaseAllowance(
        uint256 tranche,
        address sender,
        address spender,
        uint256 addedValue
    ) external override onlyShare returns (uint256 newAllowance) {
        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].add(addedValue);
        _approve(tranche, sender, spender, newAllowance);
    }

    function decreaseAllowance(
        uint256 tranche,
        address sender,
        address spender,
        uint256 subtractedValue
    ) external override onlyShare returns (uint256 newAllowance) {
        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].sub(subtractedValue);
        _approve(tranche, sender, spender, newAllowance);
    }

    function _transfer(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender][tranche] = _balances[sender][tranche].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient][tranche] = _balances[recipient][tranche].add(amount);

        emit Transfer(tranche, sender, recipient, amount);
    }

    function _mint(
        uint256 tranche,
        address account,
        uint256 amount
    ) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupplies[tranche] = _totalSupplies[tranche].add(amount);
        _balances[account][tranche] = _balances[account][tranche].add(amount);

        emit Transfer(tranche, address(0), account, amount);
    }

    function _burn(
        uint256 tranche,
        address account,
        uint256 amount
    ) private {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account][tranche] = _balances[account][tranche].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);

        emit Transfer(tranche, account, address(0), amount);
    }

    function _approve(
        uint256 tranche,
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender][tranche] = amount;

        emit Approval(tranche, owner, spender, amount);
    }

    /// @notice Settle the current trading day. Settlement includes the following changes
    ///         to the fund.
    ///
    ///         1. Transfer protocol fee of the day to the fee collector.
    ///         2. Settle all pending creations and redemptions from all primary markets.
    ///         3. Calculate NAV of the day and trigger rebalance if necessary.
    ///         4. Capture new interest rate for Token A.
    function settle() external nonReentrant {
        uint256 day = currentDay;
        uint256 currentWeek = _endOfWeek(day - 1 days);
        require(block.timestamp >= day, "The current trading day does not end yet");
        uint256 price = twapOracle.getTwap(day);
        require(price != 0, "Underlying price for settlement is not ready yet");

        _collectFee();

        _settlePrimaryMarkets(day, price);

        // Calculate NAV
        uint256 totalShares = getTotalShares();
        uint256 underlying = IERC20(tokenUnderlying).balanceOf(address(this));
        uint256 navA = _historicalNavs[day - 1 days][TRANCHE_A];
        uint256 navM;
        if (totalShares > 0) {
            navM = price.mul(underlying.mul(underlyingDecimalMultiplier)).div(totalShares);
            if (historicalTotalShares[day - 1 days] > 0) {
                // Update NAV of Token A only when the fund is non-empty both before and after
                // this settlement
                uint256 newNavA =
                    navA.multiplyDecimal(UNIT.sub(dailyProtocolFeeRate)).multiplyDecimal(
                        historicalInterestRate[currentWeek].add(UNIT)
                    );
                if (navA < newNavA) {
                    navA = newNavA;
                }
            }
        } else {
            // If the fund is empty, use NAV of Token M in the last day
            navM = _historicalNavs[day - 1 days][TRANCHE_M];
        }
        uint256 navB = calculateNavB(navM, navA);

        if (_shouldTriggerRebalance(navA, navB)) {
            _triggerRebalance(day, navM, navA, navB);
            navM = UNIT;
            navA = UNIT;
            navB = UNIT;
            totalShares = getTotalShares();
            fundActivityStartTime = day + activityDelayTimeAfterRebalance;
            exchangeActivityStartTime = day + activityDelayTimeAfterRebalance;
        } else {
            fundActivityStartTime = day;
            exchangeActivityStartTime = day + 30 minutes;
        }

        if (currentDay == currentWeek) {
            historicalInterestRate[currentWeek + 1 weeks] = _updateInterestRate(currentWeek);
        }

        historicalTotalShares[day] = totalShares;
        historicalUnderlying[day] = underlying;
        _historicalNavs[day][TRANCHE_M] = navM;
        _historicalNavs[day][TRANCHE_A] = navA;
        _historicalNavs[day][TRANCHE_B] = navB;
        currentDay = day + 1 days;

        if (obsoletePrimaryMarkets.length > 0) {
            for (uint256 i = 0; i < obsoletePrimaryMarkets.length; i++) {
                _removePrimaryMarket(obsoletePrimaryMarkets[i]);
            }
            delete obsoletePrimaryMarkets;
        }

        if (newPrimaryMarkets.length > 0) {
            for (uint256 i = 0; i < newPrimaryMarkets.length; i++) {
                _addPrimaryMarket(newPrimaryMarkets[i]);
            }
            delete newPrimaryMarkets;
        }

        emit Settled(day, navM, navA, navB);
    }

    function addObsoletePrimaryMarket(address obsoletePrimaryMarket) external onlyOwner {
        require(isPrimaryMarket(obsoletePrimaryMarket), "The address is not a primary market");
        obsoletePrimaryMarkets.push(obsoletePrimaryMarket);
    }

    function addNewPrimaryMarket(address newPrimaryMarket) external onlyOwner {
        require(!isPrimaryMarket(newPrimaryMarket), "The address is already a primary market");
        newPrimaryMarkets.push(newPrimaryMarket);
    }

    function updateDailyProtocolFeeRate(uint256 newDailyProtocolFeeRate) external onlyOwner {
        require(
            newDailyProtocolFeeRate <= MAX_DAILY_PROTOCOL_FEE_RATE,
            "Exceed max protocol fee rate"
        );
        dailyProtocolFeeRate = newDailyProtocolFeeRate;
    }

    function updateTwapOracle(address newTwapOracle) external onlyOwner {
        twapOracle = ITwapOracle(newTwapOracle);
    }

    function updateAprOracle(address newAprOracle) external onlyOwner {
        aprOracle = IAprOracle(newAprOracle);
    }

    function updateBallot(address newBallot) external onlyOwner {
        ballot = IBallot(newBallot);
    }

    function updateFeeCollector(address newFeeCollector) external onlyOwner {
        feeCollector = newFeeCollector;
    }

    function updateActivityDelayTime(uint256 delayTime) external onlyOwner {
        require(
            delayTime >= 30 minutes && delayTime <= 12 hours,
            "Exceed allowed delay time range"
        );
        activityDelayTimeAfterRebalance = delayTime;
    }

    /// @dev Transfer protocol fee of the current trading day to the fee collector.
    ///      This function should be called before creation and redemption on the same day
    ///      are settled.
    function _collectFee() private {
        uint256 currentUnderlying = IERC20(tokenUnderlying).balanceOf(address(this));
        uint256 fee = currentUnderlying.multiplyDecimal(dailyProtocolFeeRate);
        if (fee > 0) {
            IERC20(tokenUnderlying).safeTransfer(address(feeCollector), fee);
        }
    }

    /// @dev Settle primary market operations in every PrimaryMarket contract.
    function _settlePrimaryMarkets(uint256 day, uint256 price) private {
        uint256 totalShares = getTotalShares();
        uint256 underlying = IERC20(tokenUnderlying).balanceOf(address(this));
        uint256 prevNavM = _historicalNavs[day - 1 days][TRANCHE_M];
        uint256 primaryMarketCount = getPrimaryMarketCount();
        for (uint256 i = 0; i < primaryMarketCount; i++) {
            uint256 price_ = price; // Fix the "stack too deep" error
            IPrimaryMarket pm = IPrimaryMarket(getPrimaryMarketMember(i));
            (
                uint256 sharesToMint,
                uint256 sharesToBurn,
                uint256 creationUnderlying,
                uint256 redemptionUnderlying,
                uint256 fee
            ) = pm.settle(day, totalShares, underlying, price_, prevNavM);
            if (sharesToMint > sharesToBurn) {
                _mint(TRANCHE_M, address(pm), sharesToMint - sharesToBurn);
            } else if (sharesToBurn > sharesToMint) {
                _burn(TRANCHE_M, address(pm), sharesToBurn - sharesToMint);
            }
            if (creationUnderlying > redemptionUnderlying) {
                IERC20(tokenUnderlying).safeTransferFrom(
                    address(pm),
                    address(this),
                    creationUnderlying - redemptionUnderlying
                );
            } else if (redemptionUnderlying > creationUnderlying) {
                IERC20(tokenUnderlying).safeTransfer(
                    address(pm),
                    redemptionUnderlying - creationUnderlying
                );
            }
            if (fee > 0) {
                IERC20(tokenUnderlying).safeTransfer(address(feeCollector), fee);
            }
        }
    }

    /// @dev Check whether a new rebalance should be triggered. Rebalance is triggered if
    ///      NAV of Token B over NAV of Token A is greater than the upper threshold or
    ///      less than the lower threshold.
    /// @param navA NAV of Token A before the rebalance
    /// @param navBOrZero NAV of Token B before the rebalance or zero if the NAV is negative
    /// @return Whether a new rebalance should be triggered
    function _shouldTriggerRebalance(uint256 navA, uint256 navBOrZero) private view returns (bool) {
        uint256 bOverA = navBOrZero.divideDecimal(navA);
        return bOverA < lowerRebalanceThreshold || bOverA > upperRebalanceThreshold;
    }

    /// @dev Create a new rebalance that resets NAV of all tranches to 1. Total supplies are
    ///      rebalanced immediately.
    /// @param day Trading day that triggers this rebalance
    /// @param navM NAV of Token M before this rebalance
    /// @param navA NAV of Token A before this rebalance
    /// @param navBOrZero NAV of Token B before this rebalance or zero if the NAV is negative
    function _triggerRebalance(
        uint256 day,
        uint256 navM,
        uint256 navA,
        uint256 navBOrZero
    ) private {
        Rebalance memory rebalance = _calculateRebalance(navM, navA, navBOrZero);
        uint256 oldSize = _rebalanceSize;
        _rebalances[oldSize] = rebalance;
        _rebalanceSize = oldSize + 1;
        emit RebalanceTriggered(
            oldSize,
            day,
            rebalance.ratioM,
            rebalance.ratioA2M,
            rebalance.ratioB2M,
            rebalance.ratioAB
        );

        (
            _totalSupplies[TRANCHE_M],
            _totalSupplies[TRANCHE_A],
            _totalSupplies[TRANCHE_B]
        ) = doRebalance(
            _totalSupplies[TRANCHE_M],
            _totalSupplies[TRANCHE_A],
            _totalSupplies[TRANCHE_B],
            oldSize
        );
        _refreshBalance(address(this), oldSize + 1);
    }

    /// @dev Create a new rebalance matrix that resets given NAVs to (1, 1, 1).
    ///
    ///      Note that NAV of Token B can be negative before the rebalance when the underlying price
    ///      drops dramatically in a single trading day, in which case zero should be passed to
    ///      this function instead of the negative NAV.
    /// @param navM NAV of Token M before the rebalance
    /// @param navA NAV of Token A before the rebalance
    /// @param navBOrZero NAV of Token B before the rebalance or zero if the NAV is negative
    /// @return The rebalance matrix
    function _calculateRebalance(
        uint256 navM,
        uint256 navA,
        uint256 navBOrZero
    ) private view returns (Rebalance memory) {
        uint256 ratioAB;
        uint256 ratioA2M;
        uint256 ratioB2M;
        if (navBOrZero <= navA) {
            // Lower rebalance
            ratioAB = navBOrZero;
            ratioA2M = ((navM - navBOrZero) * WEIGHT_M) / WEIGHT_A;
            ratioB2M = 0;
        } else {
            // Upper rebalance
            ratioAB = UNIT;
            ratioA2M = navA - UNIT;
            ratioB2M = navBOrZero - UNIT;
        }
        return
            Rebalance({
                ratioM: navM,
                ratioA2M: ratioA2M,
                ratioB2M: ratioB2M,
                ratioAB: ratioAB,
                timestamp: block.timestamp
            });
    }

    function _updateInterestRate(uint256 week) private returns (uint256) {
        uint256 baseInterestRate = MAX_INTEREST_RATE.min(aprOracle.capture());
        uint256 floatingInterestRate = ballot.count(week).div(365);
        uint256 rate = baseInterestRate.add(floatingInterestRate);

        emit InterestRateUpdated(baseInterestRate, floatingInterestRate);

        return rate;
    }

    /// @dev Transform share balance to a given rebalance version, or to the latest version
    ///      if `targetVersion` is zero. This function does no bound check on `targetVersion`.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function _refreshBalance(address account, uint256 targetVersion) private {
        if (targetVersion == 0) {
            targetVersion = _rebalanceSize;
        }
        uint256 oldVersion = _balanceVersions[account];
        if (oldVersion >= targetVersion) {
            return;
        }

        uint256[TRANCHE_COUNT] storage balanceTuple = _balances[account];
        uint256 balanceM = balanceTuple[TRANCHE_M];
        uint256 balanceA = balanceTuple[TRANCHE_A];
        uint256 balanceB = balanceTuple[TRANCHE_B];
        _balanceVersions[account] = targetVersion;

        if (balanceM == 0 && balanceA == 0 && balanceB == 0) {
            // Fast path for an empty account
            return;
        }

        for (uint256 i = oldVersion; i < targetVersion; i++) {
            (balanceM, balanceA, balanceB) = doRebalance(balanceM, balanceA, balanceB, i);
        }
        balanceTuple[TRANCHE_M] = balanceM;
        balanceTuple[TRANCHE_A] = balanceA;
        balanceTuple[TRANCHE_B] = balanceB;

        emit BalancesRebalanced(account, targetVersion, balanceM, balanceA, balanceB);
    }

    /// @dev Transform allowance to a given rebalance version, or to the latest version
    ///      if `targetVersion` is zero. This function does no bound check on `targetVersion`.
    /// @param owner Owner of the allowance to rebalance
    /// @param spender Spender of the allowance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function _refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) private {
        if (targetVersion == 0) {
            targetVersion = _rebalanceSize;
        }
        uint256 oldVersion = _allowanceVersions[owner][spender];
        if (oldVersion >= targetVersion) {
            return;
        }

        uint256[TRANCHE_COUNT] storage allowanceTuple = _allowances[owner][spender];
        uint256 allowanceM = allowanceTuple[TRANCHE_M];
        uint256 allowanceA = allowanceTuple[TRANCHE_A];
        uint256 allowanceB = allowanceTuple[TRANCHE_B];
        _allowanceVersions[owner][spender] = targetVersion;

        if (allowanceM == 0 && allowanceA == 0 && allowanceB == 0) {
            // Fast path for an empty allowance
            return;
        }

        for (uint256 i = oldVersion; i < targetVersion; i++) {
            (allowanceM, allowanceA, allowanceB) = _rebalanceAllowance(
                allowanceM,
                allowanceA,
                allowanceB,
                i
            );
        }
        allowanceTuple[TRANCHE_M] = allowanceM;
        allowanceTuple[TRANCHE_A] = allowanceA;
        allowanceTuple[TRANCHE_B] = allowanceB;

        emit AllowancesRebalanced(
            owner,
            spender,
            targetVersion,
            allowanceM,
            allowanceA,
            allowanceB
        );
    }

    function _rebalanceAllowance(
        uint256 allowanceM,
        uint256 allowanceA,
        uint256 allowanceB,
        uint256 index
    )
        private
        view
        returns (
            uint256 newAllowanceM,
            uint256 newAllowanceA,
            uint256 newAllowanceB
        )
    {
        Rebalance storage rebalance = _rebalances[index];

        /// @dev using saturating arithmetic to avoid unconscious overflow revert
        newAllowanceM = allowanceM.saturatingMultiplyDecimal(rebalance.ratioM);
        newAllowanceA = allowanceA.saturatingMultiplyDecimal(rebalance.ratioAB);
        newAllowanceB = allowanceB.saturatingMultiplyDecimal(rebalance.ratioAB);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/CoreUtility.sol";

import "../interfaces/IPrimaryMarketV2.sol";
import "../interfaces/IFundV2.sol";
import "../../interfaces/ITwapOracle.sol";
import "../../interfaces/IAprOracle.sol";
import "../../interfaces/IBallot.sol";
import "../../interfaces/IVotingEscrow.sol";
import "../interfaces/ITrancheIndex.sol";

import "./FundRoles.sol";

contract FundV2 is IFundV2, Ownable, ReentrancyGuard, FundRoles, CoreUtility, ITrancheIndex {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event StrategyUpdateProposed(
        address indexed newStrategy,
        uint256 minTimestamp,
        uint256 maxTimestamp
    );
    event StrategyUpdated(address indexed previousStrategy, address indexed newStrategy);
    event ProfitReported(uint256 profit, uint256 performanceFee);
    event LossReported(uint256 loss);
    event ObsoletePrimaryMarketAdded(address obsoletePrimaryMarket);
    event NewPrimaryMarketAdded(address newPrimaryMarket);
    event DailyProtocolFeeRateUpdated(uint256 newDailyProtocolFeeRate);
    event TwapOracleUpdated(address newTwapOracle);
    event AprOracleUpdated(address newAprOracle);
    event BallotUpdated(address newBallot);
    event FeeCollectorUpdated(address newFeeCollector);
    event ActivityDelayTimeUpdated(uint256 delayTime);

    uint256 private constant UNIT = 1e18;
    uint256 private constant MAX_INTEREST_RATE = 0.2e18; // 20% daily
    uint256 private constant MAX_DAILY_PROTOCOL_FEE_RATE = 0.05e18; // 5% daily rate

    uint256 private constant WEIGHT_A = 1;
    uint256 private constant WEIGHT_B = 1;
    uint256 private constant WEIGHT_M = WEIGHT_A + WEIGHT_B;

    uint256 private constant STRATEGY_UPDATE_MIN_DELAY = 3 days;
    uint256 private constant STRATEGY_UPDATE_MAX_DELAY = 7 days;

    /// @notice Upper bound of `NAV_B / NAV_A` to trigger a rebalance.
    uint256 public immutable upperRebalanceThreshold;

    /// @notice Lower bound of `NAV_B / NAV_A` to trigger a rebalance.
    uint256 public immutable lowerRebalanceThreshold;

    /// @notice Address of the underlying token.
    address public immutable override tokenUnderlying;

    /// @notice A multipler that normalizes an underlying balance to 18 decimal places.
    uint256 public immutable override underlyingDecimalMultiplier;

    /// @notice Daily protocol fee rate.
    uint256 public dailyProtocolFeeRate;

    /// @notice TwapOracle address for the underlying asset.
    ITwapOracle public override twapOracle;

    /// @notice AprOracle address.
    IAprOracle public aprOracle;

    /// @notice Address of the interest rate ballot.
    IBallot public ballot;

    /// @notice Fee Collector address.
    address public override feeCollector;

    /// @notice Address of Token M.
    address public override tokenM;

    /// @notice Address of Token A.
    address public override tokenA;

    /// @notice Address of Token B.
    address public override tokenB;

    /// @notice End timestamp of the current trading day.
    ///         A trading day starts at UTC time `SETTLEMENT_TIME` of a day (inclusive)
    ///         and ends at the same time of the next day (exclusive).
    uint256 public override currentDay;

    /// @notice Start timestamp of the current primary market activity window.
    uint256 public override fundActivityStartTime;

    /// @notice Start timestamp of the current exchange activity window.
    uint256 public override exchangeActivityStartTime;

    uint256 public activityDelayTimeAfterRebalance;

    /// @dev Historical rebalances. Rebalances are often accessed in loops with bounds checking.
    ///      So we store them in a fixed-length array, in order to make compiler-generated
    ///      bounds checking on every access cheaper. The actual length of this array is stored in
    ///      `_rebalanceSize` and should be explicitly checked when necessary.
    Rebalance[65535] private _rebalances;

    /// @dev Historical rebalance count.
    uint256 private _rebalanceSize;

    /// @dev Total share supply of the three tranches. They are always rebalanced to the latest
    ///      version.
    uint256[TRANCHE_COUNT] private _totalSupplies;

    /// @dev Mapping of account => share balance of the three tranches.
    ///      Rebalance versions are stored in a separate mapping `_balanceVersions`.
    mapping(address => uint256[TRANCHE_COUNT]) private _balances;

    /// @dev Rebalance version mapping for `_balances`.
    mapping(address => uint256) private _balanceVersions;

    /// @dev Mapping of owner => spender => share allowance of the three tranches.
    ///      Rebalance versions are stored in a separate mapping `_allowanceVersions`.
    mapping(address => mapping(address => uint256[TRANCHE_COUNT])) private _allowances;

    /// @dev Rebalance version mapping for `_allowances`.
    mapping(address => mapping(address => uint256)) private _allowanceVersions;

    /// @dev Mapping of trading day => NAV tuple.
    mapping(uint256 => uint256[TRANCHE_COUNT]) private _historicalNavs;

    /// @notice Mapping of trading day => total fund shares.
    ///
    ///         Key is the end timestamp of a trading day. Value is the total fund shares after
    ///         settlement of that trading day, as if all Token A and B are merged.
    mapping(uint256 => uint256) public override historicalTotalShares;

    /// @notice Mapping of trading day => underlying assets in the fund.
    ///
    ///         Key is the end timestamp of a trading day. Value is the underlying assets in
    ///         the fund after settlement of that trading day.
    mapping(uint256 => uint256) public override historicalUnderlying;

    /// @notice Mapping of trading week => interest rate of Token A.
    ///
    ///         Key is the end timestamp of a trading week. Value is the interest rate captured
    ///         after settlement of the last day of the previous trading week.
    mapping(uint256 => uint256) public historicalInterestRate;

    address[] private obsoletePrimaryMarkets;
    address[] private newPrimaryMarkets;

    /// @notice Amount of fee not transfered to the fee collector yet.
    uint256 public feeDebt;

    /// @dev Mapping of primary market => Amount of redemption underlying that the fund owes
    ///      the primary market
    mapping(address => uint256) public redemptionDebts;

    /// @dev Sum of the fee debt and redemption debts of all primary markets.
    uint256 private _totalDebt;

    address public strategy;

    address public proposedStrategy;

    uint256 private _proposedStrategyTimestamp;

    uint256 private _strategyUnderlying;

    constructor(
        address tokenUnderlying_,
        uint256 underlyingDecimals_,
        uint256 dailyProtocolFeeRate_,
        uint256 upperRebalanceThreshold_,
        uint256 lowerRebalanceThreshold_,
        address twapOracle_,
        address aprOracle_,
        address ballot_,
        address feeCollector_
    ) public Ownable() FundRoles() {
        tokenUnderlying = tokenUnderlying_;
        require(underlyingDecimals_ <= 18, "Underlying decimals larger than 18");
        underlyingDecimalMultiplier = 10**(18 - underlyingDecimals_);
        require(
            dailyProtocolFeeRate_ <= MAX_DAILY_PROTOCOL_FEE_RATE,
            "Exceed max protocol fee rate"
        );
        dailyProtocolFeeRate = dailyProtocolFeeRate_;
        upperRebalanceThreshold = upperRebalanceThreshold_;
        lowerRebalanceThreshold = lowerRebalanceThreshold_;
        twapOracle = ITwapOracle(twapOracle_);
        aprOracle = IAprOracle(aprOracle_);
        ballot = IBallot(ballot_);
        feeCollector = feeCollector_;

        currentDay = endOfDay(block.timestamp);
        uint256 lastDay = currentDay - 1 days;
        uint256 currentPrice = twapOracle.getTwap(lastDay);
        require(currentPrice != 0, "Price not available");
        _historicalNavs[lastDay][TRANCHE_M] = UNIT;
        _historicalNavs[lastDay][TRANCHE_A] = UNIT;
        _historicalNavs[lastDay][TRANCHE_B] = UNIT;
        historicalInterestRate[_endOfWeek(lastDay)] = MAX_INTEREST_RATE.min(aprOracle.capture());
        fundActivityStartTime = lastDay;
        exchangeActivityStartTime = lastDay + 30 minutes;
        activityDelayTimeAfterRebalance = 12 hours;
    }

    function initialize(
        address tokenM_,
        address tokenA_,
        address tokenB_,
        address primaryMarket_,
        address strategy_
    ) external onlyOwner {
        require(tokenM == address(0) && tokenM_ != address(0), "Already initialized");
        tokenM = tokenM_;
        tokenA = tokenA_;
        tokenB = tokenB_;
        _initializeRoles(tokenM_, tokenA_, tokenB_, primaryMarket_);
        emit StrategyUpdated(strategy, strategy_);
        strategy = strategy_;
    }

    /// @notice Return weights of Token A and B when splitting Token M.
    /// @return weightA Weight of Token A
    /// @return weightB Weight of Token B
    function trancheWeights() external pure override returns (uint256 weightA, uint256 weightB) {
        return (WEIGHT_A, WEIGHT_B);
    }

    /// @notice UTC time of a day when the fund settles.
    function settlementTime() external pure returns (uint256) {
        return SETTLEMENT_TIME;
    }

    /// @notice Return end timestamp of the trading day containing a given timestamp.
    ///
    ///         A trading day starts at UTC time `SETTLEMENT_TIME` of a day (inclusive)
    ///         and ends at the same time of the next day (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading day.
    function endOfDay(uint256 timestamp) public pure override returns (uint256) {
        return ((timestamp.add(1 days) - SETTLEMENT_TIME) / 1 days) * 1 days + SETTLEMENT_TIME;
    }

    /// @notice Return end timestamp of the trading week containing a given timestamp.
    ///
    ///         A trading week starts at UTC time `SETTLEMENT_TIME` on a Thursday (inclusive)
    ///         and ends at the same time of the next Thursday (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading week.
    function endOfWeek(uint256 timestamp) external pure returns (uint256) {
        return _endOfWeek(timestamp);
    }

    /// @notice Return the status of the fund contract.
    /// @param timestamp Timestamp to assess
    /// @return True if the fund contract is active
    function isFundActive(uint256 timestamp) public view override returns (bool) {
        return timestamp >= fundActivityStartTime;
    }

    /// @notice Return the status of a given primary market contract.
    /// @param primaryMarket The primary market contract address
    /// @param timestamp Timestamp to assess
    /// @return True if the primary market contract is active
    function isPrimaryMarketActive(address primaryMarket, uint256 timestamp)
        public
        view
        override
        returns (bool)
    {
        return
            isPrimaryMarket(primaryMarket) &&
            timestamp >= fundActivityStartTime &&
            timestamp < currentDay;
    }

    /// @notice Return the status of the exchange. Unlike the primary market, exchange is
    ///         anonymous to fund
    /// @param timestamp Timestamp to assess
    /// @return True if the exchange contract is active
    function isExchangeActive(uint256 timestamp) public view override returns (bool) {
        return (timestamp >= exchangeActivityStartTime && timestamp < (currentDay - 60 minutes));
    }

    function getTotalUnderlying() public view override returns (uint256) {
        uint256 hot = IERC20(tokenUnderlying).balanceOf(address(this));
        return hot.add(_strategyUnderlying).sub(_totalDebt);
    }

    function getStrategyUnderlying() external view override returns (uint256) {
        return _strategyUnderlying;
    }

    function getTotalDebt() external view override returns (uint256) {
        return _totalDebt;
    }

    /// @notice Total shares of the fund, as if all Token A and B are merged.
    function getTotalShares() public view override returns (uint256) {
        return
            _totalSupplies[TRANCHE_M].add(_totalSupplies[TRANCHE_A]).add(_totalSupplies[TRANCHE_B]);
    }

    /// @notice Return the rebalance matrix at a given index. A zero struct is returned
    ///         if `index` is out of bound.
    /// @param index Rebalance index
    /// @return A rebalance matrix
    function getRebalance(uint256 index) external view override returns (Rebalance memory) {
        return _rebalances[index];
    }

    /// @notice Return timestamp of the transaction triggering the rebalance at a given index.
    ///         Zero is returned if `index` is out of bound.
    /// @param index Rebalance index
    /// @return Timestamp of the rebalance
    function getRebalanceTimestamp(uint256 index) external view override returns (uint256) {
        return _rebalances[index].timestamp;
    }

    /// @notice Return the number of historical rebalances.
    function getRebalanceSize() external view override returns (uint256) {
        return _rebalanceSize;
    }

    /// @notice Return NAV of Token M, A and B of the given trading day.
    /// @param day End timestamp of a trading day
    /// @return NAV of Token M, A and B
    function historicalNavs(uint256 day)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _historicalNavs[day][TRANCHE_M],
            _historicalNavs[day][TRANCHE_A],
            _historicalNavs[day][TRANCHE_B]
        );
    }

    /// @notice Estimate NAV of all tranches at a given timestamp, considering underlying price
    ///         change, accrued protocol fee and accrued interest since the previous settlement.
    ///
    ///         The extrapolation uses simple interest instead of daily compound interest in
    ///         calculating protocol fee and Token A's interest. There may be significant error
    ///         in the returned values when `timestamp` is far beyond the last settlement.
    /// @param timestamp Timestamp to estimate
    /// @param price Price of the underlying asset (18 decimal places)
    /// @return Estimated NAV of all tranches
    function extrapolateNav(uint256 timestamp, uint256 price)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        // Find the last settled trading day before the given timestamp.
        uint256 previousDay = currentDay - 1 days;
        if (previousDay > timestamp) {
            previousDay = endOfDay(timestamp) - 1 days;
        }
        uint256 previousShares = historicalTotalShares[previousDay];
        uint256 navM = _extrapolateNavM(previousDay, previousShares, timestamp, price);
        uint256 navA = _extrapolateNavA(previousDay, previousShares, timestamp);
        uint256 navB = calculateNavB(navM, navA);
        return (navM, navA, navB);
    }

    function _extrapolateNavM(
        uint256 previousDay,
        uint256 previousShares,
        uint256 timestamp,
        uint256 price
    ) private view returns (uint256) {
        uint256 navM;
        if (previousShares == 0) {
            // The fund is empty. Just return the previous recorded NAV.
            navM = _historicalNavs[previousDay][TRANCHE_M];
            if (navM == 0) {
                // No NAV is recorded because the given timestamp is before the fund launches.
                return UNIT;
            } else {
                return navM;
            }
        }
        uint256 totalValue =
            price.mul(historicalUnderlying[previousDay].mul(underlyingDecimalMultiplier));
        uint256 accruedFee =
            totalValue.multiplyDecimal(dailyProtocolFeeRate).mul(timestamp - previousDay).div(
                1 days
            );
        navM = (totalValue - accruedFee).div(previousShares);
        return navM;
    }

    function _extrapolateNavA(
        uint256 previousDay,
        uint256 previousShares,
        uint256 timestamp
    ) private view returns (uint256) {
        uint256 navA = _historicalNavs[previousDay][TRANCHE_A];
        if (previousShares == 0) {
            // The fund is empty. Just return the previous recorded NAV.
            if (navA == 0) {
                // No NAV is recorded because the given timestamp is before the fund launches.
                return UNIT;
            } else {
                return navA;
            }
        }

        uint256 week = _endOfWeek(previousDay);
        uint256 newNavA =
            navA
                .multiplyDecimal(
                UNIT.sub(dailyProtocolFeeRate.mul(timestamp - previousDay).div(1 days))
            )
                .multiplyDecimal(
                UNIT.add(historicalInterestRate[week].mul(timestamp - previousDay).div(1 days))
            );
        return newNavA > navA ? newNavA : navA;
    }

    function calculateNavB(uint256 navM, uint256 navA) public pure override returns (uint256) {
        // Using unchecked multiplications because they are unlikely to overflow
        if (navM * WEIGHT_M >= navA * WEIGHT_A) {
            return (navM * WEIGHT_M - navA * WEIGHT_A) / WEIGHT_B;
        } else {
            return 0;
        }
    }

    /// @notice Transform share amounts according to the rebalance at a given index.
    ///         This function performs no bounds checking on the given index. A non-existent
    ///         rebalance transforms anything to a zero vector.
    /// @param amountM Amount of Token M before the rebalance
    /// @param amountA Amount of Token A before the rebalance
    /// @param amountB Amount of Token B before the rebalance
    /// @param index Rebalance index
    /// @return newAmountM Amount of Token M after the rebalance
    /// @return newAmountA Amount of Token A after the rebalance
    /// @return newAmountB Amount of Token B after the rebalance
    function doRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 index
    )
        public
        view
        override
        returns (
            uint256 newAmountM,
            uint256 newAmountA,
            uint256 newAmountB
        )
    {
        Rebalance storage rebalance = _rebalances[index];
        newAmountM = amountM
            .multiplyDecimal(rebalance.ratioM)
            .add(amountA.multiplyDecimal(rebalance.ratioA2M))
            .add(amountB.multiplyDecimal(rebalance.ratioB2M));
        uint256 ratioAB = rebalance.ratioAB; // Gas saver
        newAmountA = amountA.multiplyDecimal(ratioAB);
        newAmountB = amountB.multiplyDecimal(ratioAB);
    }

    /// @notice Transform share amounts according to rebalances in a given index range,
    ///         This function performs no bounds checking on the given indices. The original amounts
    ///         are returned if `fromIndex` is no less than `toIndex`. A zero vector is returned
    ///         if `toIndex` is greater than the number of existing rebalances.
    /// @param amountM Amount of Token M before the rebalance
    /// @param amountA Amount of Token A before the rebalance
    /// @param amountB Amount of Token B before the rebalance
    /// @param fromIndex Starting of the rebalance index range, inclusive
    /// @param toIndex End of the rebalance index range, exclusive
    /// @return newAmountM Amount of Token M after the rebalance
    /// @return newAmountA Amount of Token A after the rebalance
    /// @return newAmountB Amount of Token B after the rebalance
    function batchRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 fromIndex,
        uint256 toIndex
    )
        external
        view
        override
        returns (
            uint256 newAmountM,
            uint256 newAmountA,
            uint256 newAmountB
        )
    {
        for (uint256 i = fromIndex; i < toIndex; i++) {
            (amountM, amountA, amountB) = doRebalance(amountM, amountA, amountB, i);
        }
        newAmountM = amountM;
        newAmountA = amountA;
        newAmountB = amountB;
    }

    /// @notice Transform share balance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshBalance(address account, uint256 targetVersion) external override {
        if (targetVersion > 0) {
            require(targetVersion <= _rebalanceSize, "Target version out of bound");
        }
        _refreshBalance(account, targetVersion);
    }

    /// @notice Transform allowance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param owner Owner of the allowance to rebalance
    /// @param spender Spender of the allowance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) external override {
        if (targetVersion > 0) {
            require(targetVersion <= _rebalanceSize, "Target version out of bound");
        }
        _refreshAllowance(owner, spender, targetVersion);
    }

    function shareBalanceOf(uint256 tranche, address account)
        external
        view
        override
        returns (uint256)
    {
        uint256 amountM = _balances[account][TRANCHE_M];
        uint256 amountA = _balances[account][TRANCHE_A];
        uint256 amountB = _balances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _balanceVersions[account]; i < size; i++) {
            (amountM, amountA, amountB) = doRebalance(amountM, amountA, amountB, i);
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    /// @notice Return all three share balances transformed to the latest rebalance version.
    /// @param account Owner of the shares
    function allShareBalanceOf(address account)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 amountM = _balances[account][TRANCHE_M];
        uint256 amountA = _balances[account][TRANCHE_A];
        uint256 amountB = _balances[account][TRANCHE_B];

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _balanceVersions[account]; i < size; i++) {
            (amountM, amountA, amountB) = doRebalance(amountM, amountA, amountB, i);
        }

        return (amountM, amountA, amountB);
    }

    function shareBalanceVersion(address account) external view override returns (uint256) {
        return _balanceVersions[account];
    }

    function shareAllowance(
        uint256 tranche,
        address owner,
        address spender
    ) external view override returns (uint256) {
        uint256 allowanceM = _allowances[owner][spender][TRANCHE_M];
        uint256 allowanceA = _allowances[owner][spender][TRANCHE_A];
        uint256 allowanceB = _allowances[owner][spender][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (allowanceM == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (allowanceA == 0) return 0;
        } else {
            if (allowanceB == 0) return 0;
        }

        uint256 size = _rebalanceSize; // Gas saver
        for (uint256 i = _allowanceVersions[owner][spender]; i < size; i++) {
            (allowanceM, allowanceA, allowanceB) = _rebalanceAllowance(
                allowanceM,
                allowanceA,
                allowanceB,
                i
            );
        }

        if (tranche == TRANCHE_M) {
            return allowanceM;
        } else if (tranche == TRANCHE_A) {
            return allowanceA;
        } else {
            return allowanceB;
        }
    }

    function shareAllowanceVersion(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowanceVersions[owner][spender];
    }

    function shareTotalSupply(uint256 tranche) external view override returns (uint256) {
        return _totalSupplies[tranche];
    }

    function mint(
        uint256 tranche,
        address account,
        uint256 amount
    ) external override onlyPrimaryMarket {
        _refreshBalance(account, _rebalanceSize);
        _mint(tranche, account, amount);
    }

    function burn(
        uint256 tranche,
        address account,
        uint256 amount
    ) external override onlyPrimaryMarket {
        _refreshBalance(account, _rebalanceSize);
        _burn(tranche, account, amount);
    }

    function transfer(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount
    ) public override onlyShare {
        require(isFundActive(block.timestamp), "Transfer is inactive");
        _refreshBalance(sender, _rebalanceSize);
        _refreshBalance(recipient, _rebalanceSize);
        _transfer(tranche, sender, recipient, amount);
    }

    function transferFrom(
        uint256 tranche,
        address spender,
        address sender,
        address recipient,
        uint256 amount
    ) external override onlyShare returns (uint256 newAllowance) {
        transfer(tranche, sender, recipient, amount);

        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].sub(
            amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(tranche, sender, spender, newAllowance);
    }

    function approve(
        uint256 tranche,
        address owner,
        address spender,
        uint256 amount
    ) external override onlyShare {
        _refreshAllowance(owner, spender, _rebalanceSize);
        _approve(tranche, owner, spender, amount);
    }

    function increaseAllowance(
        uint256 tranche,
        address sender,
        address spender,
        uint256 addedValue
    ) external override onlyShare returns (uint256 newAllowance) {
        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].add(addedValue);
        _approve(tranche, sender, spender, newAllowance);
    }

    function decreaseAllowance(
        uint256 tranche,
        address sender,
        address spender,
        uint256 subtractedValue
    ) external override onlyShare returns (uint256 newAllowance) {
        _refreshAllowance(sender, spender, _rebalanceSize);
        newAllowance = _allowances[sender][spender][tranche].sub(subtractedValue);
        _approve(tranche, sender, spender, newAllowance);
    }

    function _transfer(
        uint256 tranche,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender][tranche] = _balances[sender][tranche].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient][tranche] = _balances[recipient][tranche].add(amount);

        emit Transfer(tranche, sender, recipient, amount);
    }

    function _mint(
        uint256 tranche,
        address account,
        uint256 amount
    ) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupplies[tranche] = _totalSupplies[tranche].add(amount);
        _balances[account][tranche] = _balances[account][tranche].add(amount);

        emit Transfer(tranche, address(0), account, amount);
    }

    function _burn(
        uint256 tranche,
        address account,
        uint256 amount
    ) private {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account][tranche] = _balances[account][tranche].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);

        emit Transfer(tranche, account, address(0), amount);
    }

    function _approve(
        uint256 tranche,
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender][tranche] = amount;

        emit Approval(tranche, owner, spender, amount);
    }

    /// @notice Settle the current trading day. Settlement includes the following changes
    ///         to the fund.
    ///
    ///         1. Charge protocol fee of the day.
    ///         2. Settle all pending creations and redemptions from all primary markets.
    ///         3. Calculate NAV of the day and trigger rebalance if necessary.
    ///         4. Capture new interest rate for Token A.
    function settle() external nonReentrant {
        uint256 day = currentDay;
        uint256 currentWeek = _endOfWeek(day - 1 days);
        require(block.timestamp >= day, "The current trading day does not end yet");
        uint256 price = twapOracle.getTwap(day);
        require(price != 0, "Underlying price for settlement is not ready yet");

        _collectFee();

        _settlePrimaryMarkets(day, price);

        _payDebt();

        // Calculate NAV
        uint256 totalShares = getTotalShares();
        uint256 underlying = getTotalUnderlying();
        uint256 navA = _historicalNavs[day - 1 days][TRANCHE_A];
        uint256 navM;
        if (totalShares > 0) {
            navM = price.mul(underlying.mul(underlyingDecimalMultiplier)).div(totalShares);
            if (historicalTotalShares[day - 1 days] > 0) {
                // Update NAV of Token A only when the fund is non-empty both before and after
                // this settlement
                uint256 newNavA =
                    navA.multiplyDecimal(UNIT.sub(dailyProtocolFeeRate)).multiplyDecimal(
                        historicalInterestRate[currentWeek].add(UNIT)
                    );
                if (navA < newNavA) {
                    navA = newNavA;
                }
            }
        } else {
            // If the fund is empty, use NAV of Token M in the last day
            navM = _historicalNavs[day - 1 days][TRANCHE_M];
        }
        uint256 navB = calculateNavB(navM, navA);

        if (_shouldTriggerRebalance(navA, navB)) {
            _triggerRebalance(day, navM, navA, navB);
            navM = UNIT;
            navA = UNIT;
            navB = UNIT;
            totalShares = getTotalShares();
            fundActivityStartTime = day + activityDelayTimeAfterRebalance;
            exchangeActivityStartTime = day + activityDelayTimeAfterRebalance;
        } else {
            fundActivityStartTime = day;
            exchangeActivityStartTime = day + 30 minutes;
        }

        if (day == currentWeek) {
            historicalInterestRate[currentWeek + 1 weeks] = _updateInterestRate(currentWeek);
        }

        historicalTotalShares[day] = totalShares;
        historicalUnderlying[day] = underlying;
        _historicalNavs[day][TRANCHE_M] = navM;
        _historicalNavs[day][TRANCHE_A] = navA;
        _historicalNavs[day][TRANCHE_B] = navB;
        currentDay = day + 1 days;

        if (obsoletePrimaryMarkets.length > 0) {
            for (uint256 i = 0; i < obsoletePrimaryMarkets.length; i++) {
                _removePrimaryMarket(obsoletePrimaryMarkets[i]);
            }
            delete obsoletePrimaryMarkets;
        }

        if (newPrimaryMarkets.length > 0) {
            for (uint256 i = 0; i < newPrimaryMarkets.length; i++) {
                _addPrimaryMarket(newPrimaryMarkets[i]);
            }
            delete newPrimaryMarkets;
        }

        emit Settled(day, navM, navA, navB);
    }

    modifier onlyStrategy() {
        require(msg.sender == strategy, "Only strategy");
        _;
    }

    function transferToStrategy(uint256 amount) external override onlyStrategy {
        _strategyUnderlying = _strategyUnderlying.add(amount);
        IERC20(tokenUnderlying).safeTransfer(strategy, amount);
    }

    function transferFromStrategy(uint256 amount) external override onlyStrategy {
        _strategyUnderlying = _strategyUnderlying.sub(amount);
        IERC20(tokenUnderlying).safeTransferFrom(strategy, address(this), amount);
        _payDebt();
    }

    function reportProfit(uint256 profit, uint256 performanceFee) external override onlyStrategy {
        require(profit >= performanceFee, "Performance fee cannot exceed profit");
        _strategyUnderlying = _strategyUnderlying.add(profit);
        feeDebt = feeDebt.add(performanceFee);
        _totalDebt = _totalDebt.add(performanceFee);
        emit ProfitReported(profit, performanceFee);
    }

    function reportLoss(uint256 loss) external override onlyStrategy {
        _strategyUnderlying = _strategyUnderlying.sub(loss);
        emit LossReported(loss);
    }

    function proposeStrategyUpdate(address newStrategy) external onlyOwner {
        require(newStrategy != strategy);
        proposedStrategy = newStrategy;
        _proposedStrategyTimestamp = block.timestamp;
        emit StrategyUpdateProposed(
            newStrategy,
            block.timestamp + STRATEGY_UPDATE_MIN_DELAY,
            block.timestamp + STRATEGY_UPDATE_MAX_DELAY
        );
    }

    function applyStrategyUpdate(address newStrategy) external onlyOwner {
        require(proposedStrategy == newStrategy, "Proposed strategy mismatch");
        require(
            block.timestamp >= _proposedStrategyTimestamp + STRATEGY_UPDATE_MIN_DELAY &&
                block.timestamp < _proposedStrategyTimestamp + STRATEGY_UPDATE_MAX_DELAY,
            "Not ready to update strategy"
        );
        require(_totalDebt == 0, "Cannot update strategy with debt");
        emit StrategyUpdated(strategy, newStrategy);
        strategy = newStrategy;
        proposedStrategy = address(0);
        _proposedStrategyTimestamp = 0;
    }

    function addObsoletePrimaryMarket(address obsoletePrimaryMarket) external onlyOwner {
        require(isPrimaryMarket(obsoletePrimaryMarket), "The address is not a primary market");
        obsoletePrimaryMarkets.push(obsoletePrimaryMarket);
        emit ObsoletePrimaryMarketAdded(obsoletePrimaryMarket);
    }

    function addNewPrimaryMarket(address newPrimaryMarket) external onlyOwner {
        require(!isPrimaryMarket(newPrimaryMarket), "The address is already a primary market");
        newPrimaryMarkets.push(newPrimaryMarket);
        emit NewPrimaryMarketAdded(newPrimaryMarket);
    }

    function updateDailyProtocolFeeRate(uint256 newDailyProtocolFeeRate) external onlyOwner {
        require(
            newDailyProtocolFeeRate <= MAX_DAILY_PROTOCOL_FEE_RATE,
            "Exceed max protocol fee rate"
        );
        dailyProtocolFeeRate = newDailyProtocolFeeRate;
        emit DailyProtocolFeeRateUpdated(newDailyProtocolFeeRate);
    }

    function updateTwapOracle(address newTwapOracle) external onlyOwner {
        twapOracle = ITwapOracle(newTwapOracle);
        emit TwapOracleUpdated(newTwapOracle);
    }

    function updateAprOracle(address newAprOracle) external onlyOwner {
        aprOracle = IAprOracle(newAprOracle);
        emit AprOracleUpdated(newAprOracle);
    }

    function updateBallot(address newBallot) external onlyOwner {
        ballot = IBallot(newBallot);
        emit BallotUpdated(newBallot);
    }

    function updateFeeCollector(address newFeeCollector) external onlyOwner {
        feeCollector = newFeeCollector;
        emit FeeCollectorUpdated(newFeeCollector);
    }

    function updateActivityDelayTime(uint256 delayTime) external onlyOwner {
        require(
            delayTime >= 30 minutes && delayTime <= 12 hours,
            "Exceed allowed delay time range"
        );
        activityDelayTimeAfterRebalance = delayTime;
        emit ActivityDelayTimeUpdated(delayTime);
    }

    /// @dev Transfer protocol fee of the current trading day to the fee collector.
    ///      This function should be called before creation and redemption on the same day
    ///      are settled.
    function _collectFee() private {
        uint256 currentUnderlying = getTotalUnderlying();
        uint256 fee = currentUnderlying.multiplyDecimal(dailyProtocolFeeRate);
        if (fee > 0) {
            feeDebt = feeDebt.add(fee);
            _totalDebt = _totalDebt.add(fee);
        }
    }

    /// @dev Settle primary market operations in every PrimaryMarket contract.
    function _settlePrimaryMarkets(uint256 day, uint256 price) private {
        uint256 day_ = day; // Fix the "stack too deep" error
        uint256 totalShares = getTotalShares();
        uint256 underlying = getTotalUnderlying();
        uint256 primaryMarketCount = getPrimaryMarketCount();
        uint256 prevNavM = _historicalNavs[day - 1 days][TRANCHE_M];
        uint256 newTotalDebt = _totalDebt;
        for (uint256 i = 0; i < primaryMarketCount; i++) {
            uint256 price_ = price; // Fix the "stack too deep" error
            IPrimaryMarketV2 pm = IPrimaryMarketV2(getPrimaryMarketMember(i));
            (
                uint256 sharesToMint,
                uint256 sharesToBurn,
                uint256 creationUnderlying,
                uint256 redemptionUnderlying,
                uint256 fee
            ) = pm.settle(day_, totalShares, underlying, price_, prevNavM);
            if (sharesToMint > sharesToBurn) {
                _mint(TRANCHE_M, address(pm), sharesToMint - sharesToBurn);
            } else if (sharesToBurn > sharesToMint) {
                _burn(TRANCHE_M, address(pm), sharesToBurn - sharesToMint);
            }
            uint256 debt = redemptionDebts[address(pm)];
            uint256 redemptionAndDebt = redemptionUnderlying.add(debt);
            if (creationUnderlying > redemptionAndDebt) {
                IERC20(tokenUnderlying).safeTransferFrom(
                    address(pm),
                    address(this),
                    creationUnderlying - redemptionAndDebt
                );
                redemptionDebts[address(pm)] = 0;
                newTotalDebt -= debt;
            } else {
                uint256 newDebt = redemptionAndDebt - creationUnderlying;
                redemptionDebts[address(pm)] = newDebt;
                newTotalDebt = newTotalDebt.sub(debt).add(newDebt);
            }
            if (fee > 0) {
                feeDebt = feeDebt.add(fee);
                newTotalDebt = newTotalDebt.add(fee);
            }
        }
        _totalDebt = newTotalDebt;
    }

    function _payDebt() private {
        uint256 total = _totalDebt;
        if (total == 0) {
            return;
        }
        uint256 hot = IERC20(tokenUnderlying).balanceOf(address(this));
        if (hot == 0) {
            return;
        }
        uint256 fee = feeDebt;
        if (fee > 0) {
            uint256 amount = hot.min(fee);
            feeDebt = fee - amount;
            total -= amount;
            hot -= amount;
            IERC20(tokenUnderlying).safeTransfer(feeCollector, amount);
        }
        uint256 primaryMarketCount = getPrimaryMarketCount();
        for (uint256 i = 0; i < primaryMarketCount && hot > 0 && total > 0; i++) {
            address pm = getPrimaryMarketMember(i);
            uint256 redemption = redemptionDebts[pm];
            if (redemption > 0) {
                uint256 amount = hot.min(redemption);
                redemptionDebts[pm] = redemption - amount;
                total -= amount;
                hot -= amount;
                IERC20(tokenUnderlying).safeTransfer(pm, amount);
                IPrimaryMarketV2(pm).updateDelayedRedemptionDay();
            }
        }
        _totalDebt = total;
    }

    /// @dev Check whether a new rebalance should be triggered. Rebalance is triggered if
    ///      NAV of Token B over NAV of Token A is greater than the upper threshold or
    ///      less than the lower threshold.
    /// @param navA NAV of Token A before the rebalance
    /// @param navBOrZero NAV of Token B before the rebalance or zero if the NAV is negative
    /// @return Whether a new rebalance should be triggered
    function _shouldTriggerRebalance(uint256 navA, uint256 navBOrZero) private view returns (bool) {
        uint256 bOverA = navBOrZero.divideDecimal(navA);
        return bOverA < lowerRebalanceThreshold || bOverA > upperRebalanceThreshold;
    }

    /// @dev Create a new rebalance that resets NAV of all tranches to 1. Total supplies are
    ///      rebalanced immediately.
    /// @param day Trading day that triggers this rebalance
    /// @param navM NAV of Token M before this rebalance
    /// @param navA NAV of Token A before this rebalance
    /// @param navBOrZero NAV of Token B before this rebalance or zero if the NAV is negative
    function _triggerRebalance(
        uint256 day,
        uint256 navM,
        uint256 navA,
        uint256 navBOrZero
    ) private {
        Rebalance memory rebalance = _calculateRebalance(navM, navA, navBOrZero);
        uint256 oldSize = _rebalanceSize;
        _rebalances[oldSize] = rebalance;
        _rebalanceSize = oldSize + 1;
        emit RebalanceTriggered(
            oldSize,
            day,
            rebalance.ratioM,
            rebalance.ratioA2M,
            rebalance.ratioB2M,
            rebalance.ratioAB
        );

        (
            _totalSupplies[TRANCHE_M],
            _totalSupplies[TRANCHE_A],
            _totalSupplies[TRANCHE_B]
        ) = doRebalance(
            _totalSupplies[TRANCHE_M],
            _totalSupplies[TRANCHE_A],
            _totalSupplies[TRANCHE_B],
            oldSize
        );
        _refreshBalance(address(this), oldSize + 1);
    }

    /// @dev Create a new rebalance matrix that resets given NAVs to (1, 1, 1).
    ///
    ///      Note that NAV of Token B can be negative before the rebalance when the underlying price
    ///      drops dramatically in a single trading day, in which case zero should be passed to
    ///      this function instead of the negative NAV.
    /// @param navM NAV of Token M before the rebalance
    /// @param navA NAV of Token A before the rebalance
    /// @param navBOrZero NAV of Token B before the rebalance or zero if the NAV is negative
    /// @return The rebalance matrix
    function _calculateRebalance(
        uint256 navM,
        uint256 navA,
        uint256 navBOrZero
    ) private view returns (Rebalance memory) {
        uint256 ratioAB;
        uint256 ratioA2M;
        uint256 ratioB2M;
        if (navBOrZero <= navA) {
            // Lower rebalance
            ratioAB = navBOrZero;
            ratioA2M = ((navM - navBOrZero) * WEIGHT_M) / WEIGHT_A;
            ratioB2M = 0;
        } else {
            // Upper rebalance
            ratioAB = UNIT;
            ratioA2M = navA - UNIT;
            ratioB2M = navBOrZero - UNIT;
        }
        return
            Rebalance({
                ratioM: navM,
                ratioA2M: ratioA2M,
                ratioB2M: ratioB2M,
                ratioAB: ratioAB,
                timestamp: block.timestamp
            });
    }

    function _updateInterestRate(uint256 week) private returns (uint256) {
        uint256 baseInterestRate = MAX_INTEREST_RATE.min(aprOracle.capture());
        uint256 floatingInterestRate = ballot.count(week).div(365);
        uint256 rate = baseInterestRate.add(floatingInterestRate);

        emit InterestRateUpdated(baseInterestRate, floatingInterestRate);

        return rate;
    }

    /// @dev Transform share balance to a given rebalance version, or to the latest version
    ///      if `targetVersion` is zero. This function does no bound check on `targetVersion`.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function _refreshBalance(address account, uint256 targetVersion) private {
        if (targetVersion == 0) {
            targetVersion = _rebalanceSize;
        }
        uint256 oldVersion = _balanceVersions[account];
        if (oldVersion >= targetVersion) {
            return;
        }

        uint256[TRANCHE_COUNT] storage balanceTuple = _balances[account];
        uint256 balanceM = balanceTuple[TRANCHE_M];
        uint256 balanceA = balanceTuple[TRANCHE_A];
        uint256 balanceB = balanceTuple[TRANCHE_B];
        _balanceVersions[account] = targetVersion;

        if (balanceM == 0 && balanceA == 0 && balanceB == 0) {
            // Fast path for an empty account
            return;
        }

        for (uint256 i = oldVersion; i < targetVersion; i++) {
            (balanceM, balanceA, balanceB) = doRebalance(balanceM, balanceA, balanceB, i);
        }
        balanceTuple[TRANCHE_M] = balanceM;
        balanceTuple[TRANCHE_A] = balanceA;
        balanceTuple[TRANCHE_B] = balanceB;

        emit BalancesRebalanced(account, targetVersion, balanceM, balanceA, balanceB);
    }

    /// @dev Transform allowance to a given rebalance version, or to the latest version
    ///      if `targetVersion` is zero. This function does no bound check on `targetVersion`.
    /// @param owner Owner of the allowance to rebalance
    /// @param spender Spender of the allowance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function _refreshAllowance(
        address owner,
        address spender,
        uint256 targetVersion
    ) private {
        if (targetVersion == 0) {
            targetVersion = _rebalanceSize;
        }
        uint256 oldVersion = _allowanceVersions[owner][spender];
        if (oldVersion >= targetVersion) {
            return;
        }

        uint256[TRANCHE_COUNT] storage allowanceTuple = _allowances[owner][spender];
        uint256 allowanceM = allowanceTuple[TRANCHE_M];
        uint256 allowanceA = allowanceTuple[TRANCHE_A];
        uint256 allowanceB = allowanceTuple[TRANCHE_B];
        _allowanceVersions[owner][spender] = targetVersion;

        if (allowanceM == 0 && allowanceA == 0 && allowanceB == 0) {
            // Fast path for an empty allowance
            return;
        }

        for (uint256 i = oldVersion; i < targetVersion; i++) {
            (allowanceM, allowanceA, allowanceB) = _rebalanceAllowance(
                allowanceM,
                allowanceA,
                allowanceB,
                i
            );
        }
        allowanceTuple[TRANCHE_M] = allowanceM;
        allowanceTuple[TRANCHE_A] = allowanceA;
        allowanceTuple[TRANCHE_B] = allowanceB;

        emit AllowancesRebalanced(
            owner,
            spender,
            targetVersion,
            allowanceM,
            allowanceA,
            allowanceB
        );
    }

    function _rebalanceAllowance(
        uint256 allowanceM,
        uint256 allowanceA,
        uint256 allowanceB,
        uint256 index
    )
        private
        view
        returns (
            uint256 newAllowanceM,
            uint256 newAllowanceA,
            uint256 newAllowanceB
        )
    {
        Rebalance storage rebalance = _rebalances[index];

        /// @dev using saturating arithmetic to avoid unconscious overflow revert
        newAllowanceM = allowanceM.saturatingMultiplyDecimal(rebalance.ratioM);
        newAllowanceA = allowanceA.saturatingMultiplyDecimal(rebalance.ratioAB);
        newAllowanceB = allowanceB.saturatingMultiplyDecimal(rebalance.ratioAB);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../../utils/SafeDecimalMath.sol";

import "../interfaces/IPrimaryMarket.sol";
import "../interfaces/IFund.sol";
import "../interfaces/ITrancheIndex.sol";

contract PrimaryMarket is IPrimaryMarket, ReentrancyGuard, ITrancheIndex, Ownable {
    event Created(address indexed account, uint256 underlying);
    event Redeemed(address indexed account, uint256 shares);
    event Split(address indexed account, uint256 inM, uint256 outA, uint256 outB);
    event Merged(address indexed account, uint256 outM, uint256 inA, uint256 inB);
    event Claimed(address indexed account, uint256 createdShares, uint256 redeemedUnderlying);
    event Settled(
        uint256 indexed day,
        uint256 sharesToMint,
        uint256 sharesToBurn,
        uint256 creationUnderlying,
        uint256 redemptionUnderlying,
        uint256 fee
    );

    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    /// @dev Creation and redemption of a single account.
    /// @param day Day of the last creation or redemption request.
    /// @param creatingUnderlying Underlying that will be used for creation at the end of this day.
    /// @param redeemingShares Shares that will be redeemed at the end of this day.
    /// @param createdShares Shares already created in previous days.
    /// @param redeemedUnderlying Underlying already redeemed in previous days.
    /// @param version Rebalance version before the end of this trading day.
    struct CreationRedemption {
        uint256 day;
        uint256 creatingUnderlying;
        uint256 redeemingShares;
        uint256 createdShares;
        uint256 redeemedUnderlying;
        uint256 version;
    }

    uint256 private constant MAX_REDEMPTION_FEE_RATE = 0.01e18;
    uint256 private constant MAX_SPLIT_FEE_RATE = 0.01e18;
    uint256 private constant MAX_MERGE_FEE_RATE = 0.01e18;

    uint256 public immutable guardedLaunchStart;
    uint256 public guardedLaunchTotalCap;
    uint256 public guardedLaunchIndividualCap;
    mapping(address => uint256) public guardedLaunchCreations;

    IFund public fund;

    uint256 public redemptionFeeRate;
    uint256 public splitFeeRate;
    uint256 public mergeFeeRate;
    uint256 public minCreationUnderlying;

    mapping(address => CreationRedemption) private _creationRedemptions;

    uint256 public currentDay;
    uint256 public currentCreatingUnderlying;
    uint256 public currentRedeemingShares;
    uint256 public currentFeeInShares;

    mapping(uint256 => uint256) private _historicalCreationRate;
    mapping(uint256 => uint256) private _historicalRedemptionRate;

    constructor(
        address fund_,
        uint256 guardedLaunchStart_,
        uint256 redemptionFeeRate_,
        uint256 splitFeeRate_,
        uint256 mergeFeeRate_,
        uint256 minCreationUnderlying_
    ) public Ownable() {
        require(redemptionFeeRate_ <= MAX_REDEMPTION_FEE_RATE, "Exceed max redemption fee rate");
        require(splitFeeRate_ <= MAX_SPLIT_FEE_RATE, "Exceed max split fee rate");
        require(mergeFeeRate_ <= MAX_MERGE_FEE_RATE, "Exceed max merge fee rate");
        fund = IFund(fund_);
        guardedLaunchStart = guardedLaunchStart_;
        redemptionFeeRate = redemptionFeeRate_;
        splitFeeRate = splitFeeRate_;
        mergeFeeRate = mergeFeeRate_;
        minCreationUnderlying = minCreationUnderlying_;
        currentDay = fund.currentDay();
    }

    function creationRedemptionOf(address account)
        external
        view
        returns (CreationRedemption memory)
    {
        return _currentCreationRedemption(account);
    }

    function create(uint256 underlying) external nonReentrant onlyActive {
        require(underlying >= minCreationUnderlying, "Min amount");
        IERC20(fund.tokenUnderlying()).safeTransferFrom(msg.sender, address(this), underlying);

        CreationRedemption memory cr = _currentCreationRedemption(msg.sender);
        cr.creatingUnderlying = cr.creatingUnderlying.add(underlying);
        _updateCreationRedemption(msg.sender, cr);

        currentCreatingUnderlying = currentCreatingUnderlying.add(underlying);

        if (block.timestamp < guardedLaunchStart + 4 weeks) {
            guardedLaunchCreations[msg.sender] = guardedLaunchCreations[msg.sender].add(underlying);
            require(
                IERC20(fund.tokenUnderlying()).balanceOf(address(fund)).add(
                    currentCreatingUnderlying
                ) <= guardedLaunchTotalCap,
                "Guarded launch: exceed total cap"
            );
            require(
                guardedLaunchCreations[msg.sender] <= guardedLaunchIndividualCap,
                "Guarded launch: exceed individual cap"
            );
        }

        emit Created(msg.sender, underlying);
    }

    function redeem(uint256 shares) external onlyActive {
        require(shares != 0, "Zero shares");
        // Use burn and mint to simulate a transfer, so that we don't need a special transferFrom()
        fund.burn(TRANCHE_M, msg.sender, shares);
        fund.mint(TRANCHE_M, address(this), shares);

        CreationRedemption memory cr = _currentCreationRedemption(msg.sender);
        cr.redeemingShares = cr.redeemingShares.add(shares);
        _updateCreationRedemption(msg.sender, cr);

        currentRedeemingShares = currentRedeemingShares.add(shares);
        emit Redeemed(msg.sender, shares);
    }

    function claim(address account)
        external
        override
        nonReentrant
        returns (uint256 createdShares, uint256 redeemedUnderlying)
    {
        CreationRedemption memory cr = _currentCreationRedemption(account);
        createdShares = cr.createdShares;
        redeemedUnderlying = cr.redeemedUnderlying;

        if (createdShares > 0) {
            IERC20(fund.tokenM()).safeTransfer(account, createdShares);
            cr.createdShares = 0;
        }
        if (redeemedUnderlying > 0) {
            IERC20(fund.tokenUnderlying()).safeTransfer(account, redeemedUnderlying);
            cr.redeemedUnderlying = 0;
        }
        _updateCreationRedemption(account, cr);

        emit Claimed(account, createdShares, redeemedUnderlying);
    }

    function split(uint256 inM) external onlyActive {
        require(
            block.timestamp >= guardedLaunchStart + 2 weeks,
            "Guarded launch: split not ready yet"
        );
        (uint256 weightA, uint256 weightB) = fund.trancheWeights();
        // Charge splitting fee and round it to a multiple of (weightA + weightB)
        uint256 unit = inM.sub(inM.multiplyDecimal(splitFeeRate)) / (weightA + weightB);
        require(unit > 0, "Too little to split");
        uint256 inMAfterFee = unit * (weightA + weightB);
        uint256 outA = unit * weightA;
        uint256 outB = inMAfterFee - outA;
        uint256 feeM = inM - inMAfterFee;

        fund.burn(TRANCHE_M, msg.sender, inM);
        fund.mint(TRANCHE_A, msg.sender, outA);
        fund.mint(TRANCHE_B, msg.sender, outB);
        fund.mint(TRANCHE_M, address(this), feeM);

        currentFeeInShares = currentFeeInShares.add(feeM);
        emit Split(msg.sender, inM, outA, outB);
    }

    function merge(uint256 inA) external onlyActive {
        (uint256 weightA, uint256 weightB) = fund.trancheWeights();
        // Round to tranche weights
        uint256 unit = inA / weightA;
        require(unit > 0, "Too little to merge");
        // Keep unmergable Token A unchanged.
        inA = unit * weightA;
        uint256 inB = unit.mul(weightB);
        uint256 outMBeforeFee = inA.add(inB);
        uint256 feeM = outMBeforeFee.multiplyDecimal(mergeFeeRate);
        uint256 outM = outMBeforeFee.sub(feeM);

        fund.burn(TRANCHE_A, msg.sender, inA);
        fund.burn(TRANCHE_B, msg.sender, inB);
        fund.mint(TRANCHE_M, msg.sender, outM);
        fund.mint(TRANCHE_M, address(this), feeM);

        currentFeeInShares = currentFeeInShares.add(feeM);
        emit Merged(msg.sender, outM, inA, inB);
    }

    /// @notice Settle ongoing creations and redemptions and also split and merge fees.
    ///
    ///         Creations and redemptions are settled according to the current shares and
    ///         underlying assets in the fund. Split and merge fee charged as Token M are also
    ///         redeemed at the same rate (without redemption fee).
    ///
    ///         This function does not mint or burn shares, nor transfer underlying assets.
    ///         It returns the following changes that should be done by the fund:
    ///
    ///         1. Mint or burn net shares (creations v.s. redemptions + split/merge fee).
    ///         2. Transfer underlying to or from this contract (creations v.s. redemptions).
    ///         3. Transfer fee in underlying assets to the governance address.
    ///
    ///         This function can only be called from the Fund contract. It should be called
    ///         after protocol fee is collected and before rebalance is triggered for the same
    ///         trading day.
    /// @param day The trading day to settle
    /// @param fundTotalShares Total shares of the fund (as if all Token A and B are merged)
    /// @param fundUnderlying Underlying assets in the fund
    /// @param underlyingPrice Price of the underlying assets at the end of the trading day
    /// @param previousNav NAV of Token M of the previous trading day
    /// @return sharesToMint Amount of Token M to mint for creations
    /// @return sharesToBurn Amount of Token M to burn for redemptions and split/merge fee
    /// @return creationUnderlying Underlying assets received for creations (including creation fee)
    /// @return redemptionUnderlying Underlying assets to be redeemed (excluding redemption fee)
    /// @return fee Total fee in underlying assets for the fund to transfer to the governance address,
    ///         inlucding creation fee, redemption fee and split/merge fee
    function settle(
        uint256 day,
        uint256 fundTotalShares,
        uint256 fundUnderlying,
        uint256 underlyingPrice,
        uint256 previousNav
    )
        external
        override
        nonReentrant
        onlyFund
        returns (
            uint256 sharesToMint,
            uint256 sharesToBurn,
            uint256 creationUnderlying,
            uint256 redemptionUnderlying,
            uint256 fee
        )
    {
        require(day >= currentDay, "Already settled");

        // Creation
        creationUnderlying = currentCreatingUnderlying;
        if (creationUnderlying > 0) {
            if (fundUnderlying > 0) {
                sharesToMint = creationUnderlying.mul(fundTotalShares).div(fundUnderlying);
            } else {
                // NAV is rounded down. Computing creations using NAV results in rounded up shares,
                // which is unfair to existing share holders. We only do that when there are
                // no shares before.
                require(
                    fundTotalShares == 0,
                    "Cannot create shares for fund with shares but no underlying"
                );
                require(previousNav > 0, "Cannot create shares at zero NAV");
                sharesToMint = creationUnderlying
                    .mul(underlyingPrice)
                    .mul(fund.underlyingDecimalMultiplier())
                    .div(previousNav);
            }
            _historicalCreationRate[day] = sharesToMint.divideDecimal(creationUnderlying);
        }

        // Redemption
        sharesToBurn = currentRedeemingShares;
        if (sharesToBurn > 0) {
            uint256 underlying = sharesToBurn.mul(fundUnderlying).div(fundTotalShares);
            uint256 redemptionFee = underlying.multiplyDecimal(redemptionFeeRate);
            redemptionUnderlying = underlying.sub(redemptionFee);
            _historicalRedemptionRate[day] = redemptionUnderlying.divideDecimal(sharesToBurn);
            fee = redemptionFee;
        }

        // Redeem split and merge fee
        uint256 feeInShares = currentFeeInShares;
        if (feeInShares > 0) {
            sharesToBurn = sharesToBurn.add(feeInShares);
            fee = fee.add(feeInShares.mul(fundUnderlying).div(fundTotalShares));
        }

        // Approve the fund to take underlying if creation is more than redemption.
        // Instead of directly transfering underlying to the fund, this implementation
        // makes testing much easier.
        if (creationUnderlying > redemptionUnderlying) {
            IERC20(fund.tokenUnderlying()).safeApprove(
                address(fund),
                creationUnderlying - redemptionUnderlying
            );
        }

        // This loop should never execute, because this function is called by Fund
        // for every day. We fill the gap just in case that something goes wrong in Fund.
        for (uint256 t = currentDay; t < day; t += 1 days) {
            _historicalCreationRate[t] = _historicalCreationRate[day];
            _historicalRedemptionRate[t] = _historicalRedemptionRate[day];
        }

        currentDay = day + 1 days;
        currentCreatingUnderlying = 0;
        currentRedeemingShares = 0;
        currentFeeInShares = 0;
        emit Settled(
            day,
            sharesToMint,
            sharesToBurn,
            creationUnderlying,
            redemptionUnderlying,
            fee
        );
    }

    function updateGuardedLaunchCap(uint256 newTotalCap, uint256 newIndividualCap)
        external
        onlyOwner
    {
        guardedLaunchTotalCap = newTotalCap;
        guardedLaunchIndividualCap = newIndividualCap;
    }

    function updateRedemptionFeeRate(uint256 newRedemptionFeeRate) external onlyOwner {
        require(newRedemptionFeeRate <= MAX_REDEMPTION_FEE_RATE, "Exceed max redemption fee rate");
        redemptionFeeRate = newRedemptionFeeRate;
    }

    function updateSplitFeeRate(uint256 newSplitFeeRate) external onlyOwner {
        require(newSplitFeeRate <= MAX_SPLIT_FEE_RATE, "Exceed max split fee rate");
        splitFeeRate = newSplitFeeRate;
    }

    function updateMergeFeeRate(uint256 newMergeFeeRate) external onlyOwner {
        require(newMergeFeeRate <= MAX_MERGE_FEE_RATE, "Exceed max merge fee rate");
        mergeFeeRate = newMergeFeeRate;
    }

    function updateMinCreationUnderlying(uint256 newMinCreationUnderlying) external onlyOwner {
        minCreationUnderlying = newMinCreationUnderlying;
    }

    function _currentCreationRedemption(address account)
        private
        view
        returns (CreationRedemption memory cr)
    {
        cr = _creationRedemptions[account];
        uint256 oldDay = cr.day;
        if (oldDay < currentDay) {
            if (cr.creatingUnderlying > 0) {
                cr.createdShares = cr.createdShares.add(
                    cr.creatingUnderlying.multiplyDecimal(_historicalCreationRate[oldDay])
                );
                cr.creatingUnderlying = 0;
            }
            uint256 rebalanceSize = fund.getRebalanceSize();
            if (cr.version < rebalanceSize) {
                if (cr.createdShares > 0) {
                    (cr.createdShares, , ) = fund.batchRebalance(
                        cr.createdShares,
                        0,
                        0,
                        cr.version,
                        rebalanceSize
                    );
                }
                cr.version = rebalanceSize;
            }
            if (cr.redeemingShares > 0) {
                cr.redeemedUnderlying = cr.redeemedUnderlying.add(
                    cr.redeemingShares.multiplyDecimal(_historicalRedemptionRate[oldDay])
                );
                cr.redeemingShares = 0;
            }
            cr.day = currentDay;
        }
    }

    function _updateCreationRedemption(address account, CreationRedemption memory cr) private {
        CreationRedemption storage old = _creationRedemptions[account];
        if (old.day != cr.day) {
            old.day = cr.day;
        }
        if (old.creatingUnderlying != cr.creatingUnderlying) {
            old.creatingUnderlying = cr.creatingUnderlying;
        }
        if (old.redeemingShares != cr.redeemingShares) {
            old.redeemingShares = cr.redeemingShares;
        }
        if (old.createdShares != cr.createdShares) {
            old.createdShares = cr.createdShares;
        }
        if (old.redeemedUnderlying != cr.redeemedUnderlying) {
            old.redeemedUnderlying = cr.redeemedUnderlying;
        }
        if (old.version != cr.version) {
            old.version = cr.version;
        }
    }

    modifier onlyActive() {
        require(fund.isPrimaryMarketActive(address(this), block.timestamp), "Only when active");
        _;
    }

    modifier onlyFund() {
        require(msg.sender == address(fund), "Only fund");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../../utils/SafeDecimalMath.sol";

import {DelayedRedemption, LibDelayedRedemption} from "./LibDelayedRedemption.sol";

import "../interfaces/IPrimaryMarketV2.sol";
import "../interfaces/IFundV2.sol";
import "../interfaces/ITrancheIndex.sol";
import "../../interfaces/IWrappedERC20.sol";

contract PrimaryMarketV2 is IPrimaryMarketV2, ReentrancyGuard, ITrancheIndex, Ownable {
    event Created(address indexed account, uint256 underlying);
    event Redeemed(address indexed account, uint256 shares);
    event Split(address indexed account, uint256 inM, uint256 outA, uint256 outB);
    event Merged(address indexed account, uint256 outM, uint256 inA, uint256 inB);
    event Claimed(address indexed account, uint256 createdShares, uint256 redeemedUnderlying);
    event Settled(
        uint256 indexed day,
        uint256 sharesToMint,
        uint256 sharesToBurn,
        uint256 creationUnderlying,
        uint256 redemptionUnderlying,
        uint256 fee
    );
    event RedemptionClaimable(uint256 indexed day);
    event FundCapUpdated(uint256 newCap);
    event RedemptionFeeRateUpdated(uint256 newRedemptionFeeRate);
    event SplitFeeRateUpdated(uint256 newSplitFeeRate);
    event MergeFeeRateUpdated(uint256 newMergeFeeRate);
    event MinCreationUnderlyingUpdated(uint256 newMinCreationUnderlying);

    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;
    using LibDelayedRedemption for DelayedRedemption;

    /// @dev Creation and redemption of a single account.
    /// @param day Day of the last creation or redemption request.
    /// @param creatingUnderlying Underlying that will be used for creation at the end of this day.
    /// @param redeemingShares Shares that will be redeemed at the end of this day.
    /// @param createdShares Shares already created in previous days.
    /// @param redeemedUnderlying Underlying already redeemed in previous days.
    /// @param version Rebalance version before the end of this trading day.
    struct CreationRedemption {
        uint256 day;
        uint256 creatingUnderlying;
        uint256 redeemingShares;
        uint256 createdShares;
        uint256 redeemedUnderlying;
        uint256 version;
    }

    uint256 private constant MAX_REDEMPTION_FEE_RATE = 0.01e18;
    uint256 private constant MAX_SPLIT_FEE_RATE = 0.01e18;
    uint256 private constant MAX_MERGE_FEE_RATE = 0.01e18;
    uint256 private constant MAX_ITERATIONS = 500;

    IFundV2 public immutable fund;
    IERC20 private immutable _tokenUnderlying;

    uint256 public redemptionFeeRate;
    uint256 public splitFeeRate;
    uint256 public mergeFeeRate;
    uint256 public minCreationUnderlying;

    mapping(address => CreationRedemption) private _creationRedemptions;

    uint256 public currentDay;
    uint256 public currentCreatingUnderlying;
    uint256 public currentRedeemingShares;
    uint256 public currentFeeInShares;

    mapping(uint256 => uint256) private _historicalCreationRate;
    mapping(uint256 => uint256) private _historicalRedemptionRate;

    /// @notice The upper limit of underlying that the fund can hold. This contract rejects
    ///         creations that may break this limit.
    /// @dev This limit can be bypassed if the fund has multiple primary markets.
    ///
    ///      Set it to uint(-1) to skip the check and save gas.
    uint256 public fundCap;

    /// @notice The first trading day on which redemptions cannot be claimed now.
    uint256 public delayedRedemptionDay;

    /// @dev Mapping of trading day => total redeemed underlying if users cannot claim their
    ///      redemptions on that day, or zero otherwise.
    mapping(uint256 => uint256) private _delayedUnderlyings;

    /// @dev The total amount of redeemed underlying that can be claimed by users.
    uint256 private _claimableUnderlying;

    /// @dev Mapping of account => a list of redemptions that have been settled
    ///      but are not claimable yet.
    mapping(address => DelayedRedemption) private _delayedRedemptions;

    constructor(
        address fund_,
        uint256 redemptionFeeRate_,
        uint256 splitFeeRate_,
        uint256 mergeFeeRate_,
        uint256 minCreationUnderlying_,
        uint256 fundCap_
    ) public Ownable() {
        require(redemptionFeeRate_ <= MAX_REDEMPTION_FEE_RATE, "Exceed max redemption fee rate");
        require(splitFeeRate_ <= MAX_SPLIT_FEE_RATE, "Exceed max split fee rate");
        require(mergeFeeRate_ <= MAX_MERGE_FEE_RATE, "Exceed max merge fee rate");
        fund = IFundV2(fund_);
        _tokenUnderlying = IERC20(IFund(fund_).tokenUnderlying());
        redemptionFeeRate = redemptionFeeRate_;
        splitFeeRate = splitFeeRate_;
        mergeFeeRate = mergeFeeRate_;
        minCreationUnderlying = minCreationUnderlying_;
        currentDay = IFund(fund_).currentDay();
        fundCap = fundCap_;
        delayedRedemptionDay = currentDay;
    }

    /// @dev Unlike the previous version, this function updates states of the account and is not
    ///      "view" any more. To get the return value off-chain, please call this function
    ///      using `contract.creationRedemptionOf.call(account)` in web3
    ///      or `contract.callStatic.creationRedemptionOf(account)` in ethers.js.
    function creationRedemptionOf(address account) external returns (CreationRedemption memory) {
        _updateDelayedRedemptionDay();
        _updateUser(account);
        return _creationRedemptions[account];
    }

    /// @notice Return delayed redemption of an account on a trading day.
    /// @param account Address of the account
    /// @param day A trading day
    /// @return underlying Redeemed underlying amount
    /// @return nextDay Trading day of the next delayed redemption, or zero if there's no
    ///                 delayed redemption on the given day or it is the last redemption
    function getDelayedRedemption(address account, uint256 day)
        external
        view
        returns (uint256 underlying, uint256 nextDay)
    {
        return _delayedRedemptions[account].get(day);
    }

    /// @notice Return trading day of the first delayed redemption of an account.
    function getDelayedRedemptionHead(address account) external view returns (uint256) {
        return _delayedRedemptions[account].headTail.head;
    }

    function updateDelayedRedemptionDay() external override nonReentrant {
        _updateDelayedRedemptionDay();
    }

    function create(uint256 underlying) external nonReentrant {
        _tokenUnderlying.safeTransferFrom(msg.sender, address(this), underlying);
        _create(underlying);
    }

    function wrapAndCreate() external payable nonReentrant {
        IWrappedERC20(address(_tokenUnderlying)).deposit{value: msg.value}();
        _create(msg.value);
    }

    function _create(uint256 underlying) private onlyActive {
        require(underlying >= minCreationUnderlying, "Min amount");

        // Do not call `_updateDelayedRedemptionDay()` because the latest `redeemedUnderlying`
        // is not used in this function.
        _updateUser(msg.sender);
        CreationRedemption storage cr = _creationRedemptions[msg.sender];
        cr.creatingUnderlying = cr.creatingUnderlying.add(underlying);

        uint256 creatingUnderlying = currentCreatingUnderlying.add(underlying);
        currentCreatingUnderlying = creatingUnderlying;

        uint256 cap = fundCap;
        if (cap != uint256(-1)) {
            require(
                fund.historicalUnderlying(currentDay - 1 days).add(creatingUnderlying) <= cap,
                "Exceed fund cap"
            );
        }

        emit Created(msg.sender, underlying);
    }

    function redeem(uint256 shares) external nonReentrant onlyActive {
        require(shares != 0, "Zero shares");
        // Use burn and mint to simulate a transfer, so that we don't need a special transferFrom()
        fund.burn(TRANCHE_M, msg.sender, shares);
        fund.mint(TRANCHE_M, address(this), shares);

        // Do not call `_updateDelayedRedemptionDay()` because the latest `redeemedUnderlying`
        // is not used in this function.
        _updateUser(msg.sender);
        CreationRedemption storage cr = _creationRedemptions[msg.sender];
        cr.redeemingShares = cr.redeemingShares.add(shares);

        currentRedeemingShares = currentRedeemingShares.add(shares);
        emit Redeemed(msg.sender, shares);
    }

    function claim(address account)
        external
        override
        nonReentrant
        returns (uint256 createdShares, uint256 redeemedUnderlying)
    {
        (createdShares, redeemedUnderlying) = _claim(account);
        if (createdShares > 0) {
            IERC20(fund.tokenM()).safeTransfer(account, createdShares);
        }
        if (redeemedUnderlying > 0) {
            _tokenUnderlying.safeTransfer(account, redeemedUnderlying);
        }
    }

    function claimAndUnwrap(address account)
        external
        override
        nonReentrant
        returns (uint256 createdShares, uint256 redeemedUnderlying)
    {
        (createdShares, redeemedUnderlying) = _claim(account);
        if (createdShares > 0) {
            IERC20(fund.tokenM()).safeTransfer(account, createdShares);
        }
        if (redeemedUnderlying > 0) {
            IWrappedERC20(address(_tokenUnderlying)).withdraw(redeemedUnderlying);
            (bool success, ) = account.call{value: redeemedUnderlying}("");
            require(success, "Transfer failed");
        }
    }

    function _claim(address account)
        private
        returns (uint256 createdShares, uint256 redeemedUnderlying)
    {
        _updateDelayedRedemptionDay();
        _updateUser(account);
        CreationRedemption storage cr = _creationRedemptions[account];
        createdShares = cr.createdShares;
        redeemedUnderlying = cr.redeemedUnderlying;

        if (createdShares > 0) {
            cr.createdShares = 0;
        }
        if (redeemedUnderlying > 0) {
            _claimableUnderlying = _claimableUnderlying.sub(redeemedUnderlying);
            cr.redeemedUnderlying = 0;
        }

        emit Claimed(account, createdShares, redeemedUnderlying);
        return (createdShares, redeemedUnderlying);
    }

    function split(uint256 inM) external onlyActive {
        (uint256 weightA, uint256 weightB) = fund.trancheWeights();
        // Charge splitting fee and round it to a multiple of (weightA + weightB)
        uint256 unit = inM.sub(inM.multiplyDecimal(splitFeeRate)) / (weightA + weightB);
        require(unit > 0, "Too little to split");
        uint256 inMAfterFee = unit * (weightA + weightB);
        uint256 outA = unit * weightA;
        uint256 outB = inMAfterFee - outA;
        uint256 feeM = inM - inMAfterFee;

        fund.burn(TRANCHE_M, msg.sender, inM);
        fund.mint(TRANCHE_A, msg.sender, outA);
        fund.mint(TRANCHE_B, msg.sender, outB);
        fund.mint(TRANCHE_M, address(this), feeM);

        currentFeeInShares = currentFeeInShares.add(feeM);
        emit Split(msg.sender, inM, outA, outB);
    }

    function merge(uint256 inA) external onlyActive {
        (uint256 weightA, uint256 weightB) = fund.trancheWeights();
        // Round to tranche weights
        uint256 unit = inA / weightA;
        require(unit > 0, "Too little to merge");
        // Keep unmergable Token A unchanged.
        inA = unit * weightA;
        uint256 inB = unit.mul(weightB);
        uint256 outMBeforeFee = inA.add(inB);
        uint256 feeM = outMBeforeFee.multiplyDecimal(mergeFeeRate);
        uint256 outM = outMBeforeFee.sub(feeM);

        fund.burn(TRANCHE_A, msg.sender, inA);
        fund.burn(TRANCHE_B, msg.sender, inB);
        fund.mint(TRANCHE_M, msg.sender, outM);
        fund.mint(TRANCHE_M, address(this), feeM);

        currentFeeInShares = currentFeeInShares.add(feeM);
        emit Merged(msg.sender, outM, inA, inB);
    }

    /// @notice Settle ongoing creations and redemptions and also split and merge fees.
    ///
    ///         Creations and redemptions are settled according to the current shares and
    ///         underlying assets in the fund. Split and merge fee charged as Token M are also
    ///         redeemed at the same rate (without redemption fee).
    ///
    ///         This function does not mint or burn shares, nor transfer underlying assets.
    ///         It returns the following changes that should be done by the fund:
    ///
    ///         1. Mint or burn net shares (creations v.s. redemptions + split/merge fee).
    ///         2. Transfer underlying to or from this contract (creations v.s. redemptions).
    ///         3. Transfer fee in underlying assets to the governance address.
    ///
    ///         This function can only be called from the Fund contract. It should be called
    ///         after protocol fee is collected and before rebalance is triggered for the same
    ///         trading day.
    /// @param day The trading day to settle
    /// @param fundTotalShares Total shares of the fund (as if all Token A and B are merged)
    /// @param fundUnderlying Underlying assets in the fund
    /// @param underlyingPrice Price of the underlying assets at the end of the trading day
    /// @param previousNav NAV of Token M of the previous trading day
    /// @return sharesToMint Amount of Token M to mint for creations
    /// @return sharesToBurn Amount of Token M to burn for redemptions and split/merge fee
    /// @return creationUnderlying Underlying assets received for creations (including creation fee)
    /// @return redemptionUnderlying Underlying assets to be redeemed (excluding redemption fee)
    /// @return fee Total fee in underlying assets for the fund to transfer to the governance address,
    ///         inlucding creation fee, redemption fee and split/merge fee
    function settle(
        uint256 day,
        uint256 fundTotalShares,
        uint256 fundUnderlying,
        uint256 underlyingPrice,
        uint256 previousNav
    )
        external
        override
        nonReentrant
        onlyFund
        returns (
            uint256 sharesToMint,
            uint256 sharesToBurn,
            uint256 creationUnderlying,
            uint256 redemptionUnderlying,
            uint256 fee
        )
    {
        require(day >= currentDay, "Already settled");

        // Creation
        creationUnderlying = currentCreatingUnderlying;
        if (creationUnderlying > 0) {
            if (fundUnderlying > 0) {
                sharesToMint = creationUnderlying.mul(fundTotalShares).div(fundUnderlying);
            } else {
                // NAV is rounded down. Computing creations using NAV results in rounded up shares,
                // which is unfair to existing share holders. We only do that when there are
                // no shares before.
                require(
                    fundTotalShares == 0,
                    "Cannot create shares for fund with shares but no underlying"
                );
                require(previousNav > 0, "Cannot create shares at zero NAV");
                sharesToMint = creationUnderlying
                    .mul(underlyingPrice)
                    .mul(fund.underlyingDecimalMultiplier())
                    .div(previousNav);
            }
            _historicalCreationRate[day] = sharesToMint.divideDecimal(creationUnderlying);
        }

        // Redemption
        sharesToBurn = currentRedeemingShares;
        if (sharesToBurn > 0) {
            uint256 underlying = sharesToBurn.mul(fundUnderlying).div(fundTotalShares);
            uint256 redemptionFee = underlying.multiplyDecimal(redemptionFeeRate);
            redemptionUnderlying = underlying.sub(redemptionFee);
            _historicalRedemptionRate[day] = redemptionUnderlying.divideDecimal(sharesToBurn);
            fee = redemptionFee;
        }

        // Redeem split and merge fee
        uint256 feeInShares = currentFeeInShares;
        if (feeInShares > 0) {
            sharesToBurn = sharesToBurn.add(feeInShares);
            fee = fee.add(feeInShares.mul(fundUnderlying).div(fundTotalShares));
        }

        // Approve the fund to take underlying if creation is more than redemption.
        // Instead of directly transfering underlying to the fund, this implementation
        // makes testing much easier.
        if (creationUnderlying > redemptionUnderlying) {
            // Do not use `SafeERC20.safeApprove()` because the previous allowance
            // may be non-zero when there were some delayed redemptions.
            _tokenUnderlying.approve(address(fund), creationUnderlying - redemptionUnderlying);
        }

        // This loop should never execute, because this function is called by Fund
        // for every day. We fill the gap just in case that something goes wrong in Fund.
        for (uint256 t = currentDay; t < day; t += 1 days) {
            _historicalCreationRate[t] = _historicalCreationRate[day];
            _historicalRedemptionRate[t] = _historicalRedemptionRate[day];
        }

        _delayedUnderlyings[day] = redemptionUnderlying;
        currentDay = day + 1 days;
        currentCreatingUnderlying = 0;
        currentRedeemingShares = 0;
        currentFeeInShares = 0;
        emit Settled(
            day,
            sharesToMint,
            sharesToBurn,
            creationUnderlying,
            redemptionUnderlying,
            fee
        );
    }

    function updateFundCap(uint256 newCap) external onlyOwner {
        fundCap = newCap;
        emit FundCapUpdated(newCap);
    }

    function updateRedemptionFeeRate(uint256 newRedemptionFeeRate) external onlyOwner {
        require(newRedemptionFeeRate <= MAX_REDEMPTION_FEE_RATE, "Exceed max redemption fee rate");
        redemptionFeeRate = newRedemptionFeeRate;
        emit RedemptionFeeRateUpdated(newRedemptionFeeRate);
    }

    function updateSplitFeeRate(uint256 newSplitFeeRate) external onlyOwner {
        require(newSplitFeeRate <= MAX_SPLIT_FEE_RATE, "Exceed max split fee rate");
        splitFeeRate = newSplitFeeRate;
        emit SplitFeeRateUpdated(newSplitFeeRate);
    }

    function updateMergeFeeRate(uint256 newMergeFeeRate) external onlyOwner {
        require(newMergeFeeRate <= MAX_MERGE_FEE_RATE, "Exceed max merge fee rate");
        mergeFeeRate = newMergeFeeRate;
        emit MergeFeeRateUpdated(newMergeFeeRate);
    }

    function updateMinCreationUnderlying(uint256 newMinCreationUnderlying) external onlyOwner {
        minCreationUnderlying = newMinCreationUnderlying;
        emit MinCreationUnderlyingUpdated(newMinCreationUnderlying);
    }

    /// @dev Update the status of an account.
    ///      1. If there is a pending creation before the last settlement, calculate its result
    ///         and add it to `createdShares`.
    ///      2. If there is a pending redemption before the last settlement, calculate its result.
    ///         Add the result to `redeemedUnderlying` if it can be claimed now. Otherwise, append
    ///         the result to the account's delayed redemption list.
    ///      3. Check the account's delayed redemption list. Remove the redemptions that can be
    ///         claimed now from the list and add them to `redeemedUnderlying`. Note that
    ///         if `_updateDelayedRedemptionDay()` is not called before this function, some
    ///         claimable redemption may not be correctly recognized and `redeemedUnderlying` may
    ///         be smaller than the actual amount that the user can claim.
    function _updateUser(address account) private {
        CreationRedemption storage cr = _creationRedemptions[account];
        uint256 oldDay = cr.day;
        uint256 newDay = currentDay;
        if (oldDay < newDay) {
            cr.day = newDay;
            uint256 oldCreatingUnderlying = cr.creatingUnderlying;
            uint256 oldCreatedShares = cr.createdShares;
            uint256 newCreatedShares = oldCreatedShares;
            if (oldCreatingUnderlying > 0) {
                newCreatedShares = newCreatedShares.add(
                    oldCreatingUnderlying.multiplyDecimal(_historicalCreationRate[oldDay])
                );
                cr.creatingUnderlying = 0;
            }
            uint256 rebalanceSize = fund.getRebalanceSize();
            uint256 oldVersion = cr.version;
            if (oldVersion < rebalanceSize) {
                if (newCreatedShares > 0) {
                    (newCreatedShares, , ) = fund.batchRebalance(
                        newCreatedShares,
                        0,
                        0,
                        oldVersion,
                        rebalanceSize
                    );
                }
                cr.version = rebalanceSize;
            }
            if (newCreatedShares != oldCreatedShares) {
                cr.createdShares = newCreatedShares;
            }

            uint256 oldRedeemingShares = cr.redeemingShares;
            if (oldRedeemingShares > 0) {
                uint256 underlying =
                    oldRedeemingShares.multiplyDecimal(_historicalRedemptionRate[oldDay]);
                cr.redeemingShares = 0;
                if (oldDay < delayedRedemptionDay) {
                    cr.redeemedUnderlying = cr.redeemedUnderlying.add(underlying);
                } else {
                    _delayedRedemptions[account].pushBack(underlying, oldDay);
                }
            }
        }

        uint256 delayedUnderlying =
            _delayedRedemptions[account].popFrontUntil(delayedRedemptionDay - 1 days);
        if (delayedUnderlying > 0) {
            cr.redeemedUnderlying = cr.redeemedUnderlying.add(delayedUnderlying);
        }
    }

    /// @dev Move `delayedRedemptionDay` forward when there are enough underlying tokens in
    ///      this contract.
    function _updateDelayedRedemptionDay() private returns (uint256) {
        uint256 oldDelayedRedemptionDay = delayedRedemptionDay;
        uint256 currentDay_ = currentDay;
        if (oldDelayedRedemptionDay >= currentDay_) {
            return oldDelayedRedemptionDay; // Fast path to return
        }
        uint256 newDelayedRedemptionDay = oldDelayedRedemptionDay;
        uint256 claimableUnderlying = _claimableUnderlying;
        uint256 balance = _tokenUnderlying.balanceOf(address(this)).sub(claimableUnderlying);
        for (uint256 i = 0; i < MAX_ITERATIONS && newDelayedRedemptionDay < currentDay_; i++) {
            uint256 underlying = _delayedUnderlyings[newDelayedRedemptionDay];
            if (underlying > balance) {
                break;
            }
            balance -= underlying;
            claimableUnderlying = claimableUnderlying.add(underlying);
            emit RedemptionClaimable(newDelayedRedemptionDay);
            newDelayedRedemptionDay += 1 days;
        }
        if (newDelayedRedemptionDay != oldDelayedRedemptionDay) {
            delayedRedemptionDay = newDelayedRedemptionDay;
            _claimableUnderlying = claimableUnderlying;
        }
        return newDelayedRedemptionDay;
    }

    /// @notice Receive unwrapped transfer from the wrapped token.
    receive() external payable {}

    modifier onlyActive() {
        require(fund.isPrimaryMarketActive(address(this), block.timestamp), "Only when active");
        _;
    }

    modifier onlyFund() {
        require(msg.sender == address(fund), "Only fund");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../utils/CoreUtility.sol";

import "../interfaces/IBallot.sol";
import "../interfaces/IVotingEscrow.sol";

contract InterestRateBallot is IBallot, CoreUtility {
    using SafeMath for uint256;

    event Voted(
        address indexed account,
        uint256 oldAmount,
        uint256 oldUnlockTime,
        uint256 oldWeight,
        uint256 amount,
        uint256 indexed unlockTime,
        uint256 indexed weight
    );

    uint256 private immutable _maxTime;

    uint256 public constant stepSize = 0.02e18;
    uint256 public constant minRange = 0;
    uint256 public constant maxOption = 3;

    IVotingEscrow public immutable votingEscrow;

    mapping(address => Voter) public voters;

    // unlockTime => amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;
    mapping(uint256 => uint256) public scheduledWeightedUnlock;

    constructor(address votingEscrow_) public {
        votingEscrow = IVotingEscrow(votingEscrow_);
        _maxTime = IVotingEscrow(votingEscrow_).maxTime();
    }

    function getWeight(uint256 index) public pure returns (uint256) {
        uint256 delta = stepSize.mul(index);
        return minRange.add(delta);
    }

    function getReceipt(address account) external view returns (Voter memory) {
        return voters[account];
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceOfAtTimestamp(account, block.timestamp);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupplyAtTimestamp(block.timestamp);
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp)
        external
        view
        returns (uint256)
    {
        return _balanceOfAtTimestamp(account, timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256) {
        return _totalSupplyAtTimestamp(timestamp);
    }

    function sumAtTimestamp(uint256 timestamp) external view returns (uint256) {
        return _sumAtTimestamp(timestamp);
    }

    function count(uint256 timestamp) external view override returns (uint256) {
        return _averageAtTimestamp(timestamp);
    }

    function cast(uint256 option) external {
        require(option < maxOption, "Invalid option");

        IVotingEscrow.LockedBalance memory lockedBalance =
            votingEscrow.getLockedBalance(msg.sender);
        Voter memory voter = voters[msg.sender];
        uint256 weight = getWeight(option);
        require(lockedBalance.amount > 0, "Zero value");

        // update scheduled unlock
        scheduledUnlock[voter.unlockTime] = scheduledUnlock[voter.unlockTime].sub(voter.amount);
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].add(
            lockedBalance.amount
        );

        scheduledWeightedUnlock[voter.unlockTime] = scheduledWeightedUnlock[voter.unlockTime].sub(
            voter.amount * voter.weight
        );
        scheduledWeightedUnlock[lockedBalance.unlockTime] = scheduledWeightedUnlock[
            lockedBalance.unlockTime
        ]
            .add(lockedBalance.amount * weight);

        emit Voted(
            msg.sender,
            voter.amount,
            voter.unlockTime,
            voter.weight,
            lockedBalance.amount,
            lockedBalance.unlockTime,
            weight
        );

        // update voter amount per account
        voters[msg.sender] = Voter({
            amount: lockedBalance.amount,
            unlockTime: lockedBalance.unlockTime,
            weight: weight
        });
    }

    function syncWithVotingEscrow(address account) external override {
        Voter memory voter = voters[account];
        if (voter.amount == 0) {
            return; // The account did not voted before
        }

        IVotingEscrow.LockedBalance memory lockedBalance = votingEscrow.getLockedBalance(account);
        if (lockedBalance.unlockTime <= block.timestamp) {
            return;
        }

        // update scheduled unlock
        scheduledUnlock[voter.unlockTime] = scheduledUnlock[voter.unlockTime].sub(voter.amount);
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].add(
            lockedBalance.amount
        );

        scheduledWeightedUnlock[voter.unlockTime] = scheduledWeightedUnlock[voter.unlockTime].sub(
            voter.amount * voter.weight
        );
        scheduledWeightedUnlock[lockedBalance.unlockTime] = scheduledWeightedUnlock[
            lockedBalance.unlockTime
        ]
            .add(lockedBalance.amount * voter.weight);

        emit Voted(
            account,
            voter.amount,
            voter.unlockTime,
            voter.weight,
            lockedBalance.amount,
            lockedBalance.unlockTime,
            voter.weight
        );

        // update voter amount per account
        voters[account].amount = lockedBalance.amount;
        voters[account].unlockTime = lockedBalance.unlockTime;
    }

    function _balanceOfAtTimestamp(address account, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        require(timestamp >= block.timestamp, "Must be current or future time");
        Voter memory voter = voters[account];
        if (timestamp > voter.unlockTime) {
            return 0;
        }
        return (voter.amount * (voter.unlockTime - timestamp)) / _maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp) private view returns (uint256) {
        uint256 total = 0;
        for (
            uint256 weekCursor = _endOfWeek(timestamp);
            weekCursor <= timestamp + _maxTime;
            weekCursor += 1 weeks
        ) {
            total += (scheduledUnlock[weekCursor] * (weekCursor - timestamp)) / _maxTime;
        }

        return total;
    }

    function _sumAtTimestamp(uint256 timestamp) private view returns (uint256) {
        uint256 sum = 0;
        for (
            uint256 weekCursor = _endOfWeek(timestamp);
            weekCursor <= timestamp + _maxTime;
            weekCursor += 1 weeks
        ) {
            sum += (scheduledWeightedUnlock[weekCursor] * (weekCursor - timestamp)) / _maxTime;
        }

        return sum;
    }

    function _averageAtTimestamp(uint256 timestamp) private view returns (uint256) {
        uint256 sum = 0;
        uint256 total = 0;
        for (
            uint256 weekCursor = _endOfWeek(timestamp);
            weekCursor <= timestamp + _maxTime;
            weekCursor += 1 weeks
        ) {
            sum += (scheduledWeightedUnlock[weekCursor] * (weekCursor - timestamp)) / _maxTime;
            total += (scheduledUnlock[weekCursor] * (weekCursor - timestamp)) / _maxTime;
        }

        if (total == 0) {
            return getWeight(maxOption.sub(1) / 2);
        }
        return sum / total;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../utils/SafeDecimalMath.sol";
import "../utils/CoreUtility.sol";

import "../interfaces/IVotingEscrow.sol";
import "../interfaces/IWrappedERC20.sol";

contract FeeDistributor is CoreUtility, Ownable {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event AdminUpdated(address newAdmin);
    event AdminFeeRateUpdated(uint256 newAdminFeeRate);

    /// @notice 60% as the max admin fee rate
    uint256 public constant MAX_ADMIN_FEE_RATE = 6e17;

    uint256 private immutable _maxTime;
    IERC20 public immutable rewardToken;
    IVotingEscrow public immutable votingEscrow;

    /// @notice Receiver for admin fee
    address public admin;

    /// @notice Admin fee rate
    uint256 public adminFeeRate;

    /// @notice Timestamp of the last checkpoint
    uint256 public checkpointTimestamp;

    /// @notice Mapping of unlockTime => total amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;

    /// @notice Amount of Chess locked at the end of the last checkpoint's week
    uint256 public nextWeekLocked;

    /// @notice Total veCHESS at the end of the last checkpoint's week
    uint256 public nextWeekSupply;

    /// @notice Cumulative rewards received until the last checkpoint minus cumulative rewards
    ///         claimed until now
    uint256 public lastRewardBalance;

    /// @notice Mapping of week => total rewards accumulated
    ///
    ///         Key is the start timestamp of a week on each Thursday. Value is
    ///         the rewards collected from the corresponding fund in rewardToken's unit
    mapping(uint256 => uint256) public rewardsPerWeek;

    /// @notice Mapping of week => vote-locked chess total supplies
    ///
    ///         Key is the start timestamp of a week on each Thursday. Value is
    ///         vote-locked chess total supplies captured at the start of each week
    mapping(uint256 => uint256) public veSupplyPerWeek;

    /// @notice Locked balance of an account, which is synchronized with `VotingEscrow` when
    ///         `syncWithVotingEscrow()` is called
    mapping(address => IVotingEscrow.LockedBalance) public userLockedBalances;

    /// @notice Start timestamp of the week of a user's last checkpoint
    mapping(address => uint256) public userWeekCursors;

    /// @notice An account's veCHESS amount at the beginning of the week of this user's
    ///         last checkpoint
    mapping(address => uint256) public userLastBalances;

    /// @notice Mapping of account => amount of claimable Chess
    mapping(address => uint256) public claimableRewards;

    event Synchronized(
        address indexed account,
        uint256 oldAmount,
        uint256 oldUnlockTime,
        uint256 newAmount,
        uint256 newUnlockTime
    );

    constructor(
        address rewardToken_,
        address votingEscrow_,
        address admin_,
        uint256 adminFeeRate_
    ) public {
        rewardToken = IERC20(rewardToken_);
        votingEscrow = IVotingEscrow(votingEscrow_);
        _maxTime = IVotingEscrow(votingEscrow_).maxTime();
        _updateAdmin(admin_);
        _updateAdminFeeRate(adminFeeRate_);
        checkpointTimestamp = block.timestamp;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceAtTimestamp(userLockedBalances[account], block.timestamp);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupplyAtTimestamp(block.timestamp);
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp)
        external
        view
        returns (uint256)
    {
        require(timestamp >= checkpointTimestamp, "Must be current or future time");
        return _balanceAtTimestamp(userLockedBalances[account], timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256) {
        require(timestamp >= checkpointTimestamp, "Must be current or future time");
        return _totalSupplyAtTimestamp(timestamp);
    }

    /// @dev Calculate the amount of veCHESS of a `LockedBalance` at a given timestamp
    function _balanceAtTimestamp(
        IVotingEscrow.LockedBalance memory lockedBalance,
        uint256 timestamp
    ) private view returns (uint256) {
        if (timestamp >= lockedBalance.unlockTime) {
            return 0;
        }
        return lockedBalance.amount.mul(lockedBalance.unlockTime - timestamp) / _maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp) private view returns (uint256) {
        uint256 total = 0;
        for (
            uint256 weekCursor = _endOfWeek(timestamp);
            weekCursor <= timestamp + _maxTime;
            weekCursor += 1 weeks
        ) {
            total = total.add((scheduledUnlock[weekCursor].mul(weekCursor - timestamp)) / _maxTime);
        }
        return total;
    }

    /// @notice Synchronize an account's locked Chess with `VotingEscrow`.
    /// @param account Address of the synchronized account
    function syncWithVotingEscrow(address account) external {
        userCheckpoint(account);

        uint256 nextWeek = _endOfWeek(block.timestamp);
        IVotingEscrow.LockedBalance memory newLockedBalance =
            votingEscrow.getLockedBalance(account);
        if (newLockedBalance.unlockTime <= nextWeek) {
            return;
        }
        IVotingEscrow.LockedBalance memory oldLockedBalance = userLockedBalances[account];
        uint256 newNextWeekLocked = nextWeekLocked;
        uint256 newNextWeekSupply = nextWeekSupply;

        // Remove the old schedule if there is one
        if (oldLockedBalance.amount > 0 && oldLockedBalance.unlockTime > nextWeek) {
            scheduledUnlock[oldLockedBalance.unlockTime] = scheduledUnlock[
                oldLockedBalance.unlockTime
            ]
                .sub(oldLockedBalance.amount);
            newNextWeekLocked = newNextWeekLocked.sub(oldLockedBalance.amount);
            newNextWeekSupply = newNextWeekSupply.sub(
                oldLockedBalance.amount.mul(oldLockedBalance.unlockTime - nextWeek) / _maxTime
            );
        }

        scheduledUnlock[newLockedBalance.unlockTime] = scheduledUnlock[newLockedBalance.unlockTime]
            .add(newLockedBalance.amount);
        nextWeekLocked = newNextWeekLocked.add(newLockedBalance.amount);
        // Round up on division when added to the total supply, so that the total supply is never
        // smaller than the sum of all accounts' veCHESS balance.
        nextWeekSupply = newNextWeekSupply.add(
            newLockedBalance.amount.mul(newLockedBalance.unlockTime - nextWeek).add(_maxTime - 1) /
                _maxTime
        );
        userLockedBalances[account] = newLockedBalance;

        emit Synchronized(
            account,
            oldLockedBalance.amount,
            oldLockedBalance.unlockTime,
            newLockedBalance.amount,
            newLockedBalance.unlockTime
        );
    }

    function userCheckpoint(address account) public returns (uint256 rewards) {
        checkpoint();
        rewards = claimableRewards[account].add(_rewardCheckpoint(account));
        claimableRewards[account] = rewards;
    }

    function claimRewards(address account) external returns (uint256 rewards) {
        rewards = _claimRewards(account);
        rewardToken.safeTransfer(account, rewards);
    }

    function claimRewardsAndUnwrap(address account) external returns (uint256 rewards) {
        rewards = _claimRewards(account);
        IWrappedERC20(address(rewardToken)).withdraw(rewards);
        (bool success, ) = account.call{value: rewards}("");
        require(success, "Transfer failed");
    }

    /// @notice Receive unwrapped transfer from the wrapped token.
    receive() external payable {}

    function _claimRewards(address account) private returns (uint256 rewards) {
        checkpoint();
        rewards = claimableRewards[account].add(_rewardCheckpoint(account));
        claimableRewards[account] = 0;
        lastRewardBalance = lastRewardBalance.sub(rewards);
    }

    /// @notice Make a global checkpoint. If the period since the last checkpoint spans over
    ///         multiple weeks, rewards received in this period are split into these weeks
    ///         proportional to the time in each week.
    /// @dev Post-conditions:
    ///
    ///      - `checkpointTimestamp == block.timestamp`
    ///      - `lastRewardBalance == rewardToken.balanceOf(address(this))`
    ///      - All `rewardsPerWeek[t]` are updated, where `t <= checkpointTimestamp`
    ///      - All `veSupplyPerWeek[t]` are set, where `t <= checkpointTimestamp`
    ///      - `nextWeekSupply` is the total veCHESS at the end of this week
    ///      - `nextWeekLocked` is the total locked Chess at the end of this week
    function checkpoint() public {
        uint256 tokenBalance = rewardToken.balanceOf(address(this));
        uint256 tokensToDistribute = tokenBalance.sub(lastRewardBalance);
        lastRewardBalance = tokenBalance;

        uint256 adminFee = tokensToDistribute.multiplyDecimal(adminFeeRate);
        if (adminFee > 0) {
            claimableRewards[admin] = claimableRewards[admin].add(adminFee);
            tokensToDistribute = tokensToDistribute.sub(adminFee);
        }
        uint256 rewardTime = checkpointTimestamp;
        uint256 weekCursor = _endOfWeek(rewardTime) - 1 weeks;
        uint256 currentWeek = _endOfWeek(block.timestamp) - 1 weeks;

        // Update veCHESS supply at the beginning of each week since the last checkpoint.
        if (weekCursor < currentWeek) {
            uint256 newLocked = nextWeekLocked;
            uint256 newSupply = nextWeekSupply;
            for (uint256 w = weekCursor + 1 weeks; w <= currentWeek; w += 1 weeks) {
                veSupplyPerWeek[w] = newSupply;
                // Calculate supply at the end of the next week.
                newSupply = newSupply.sub(newLocked.mul(1 weeks) / _maxTime);
                // Remove Chess unlocked at the end of the next week from total locked amount.
                newLocked = newLocked.sub(scheduledUnlock[w + 1 weeks]);
            }
            nextWeekLocked = newLocked;
            nextWeekSupply = newSupply;
        }

        // Distribute rewards received since the last checkpoint.
        if (tokensToDistribute > 0) {
            if (weekCursor >= currentWeek) {
                rewardsPerWeek[weekCursor] = rewardsPerWeek[weekCursor].add(tokensToDistribute);
            } else {
                uint256 sinceLast = block.timestamp - rewardTime;
                // Calculate the fraction of rewards proportional to the time from
                // the last checkpoint to the end of that week.
                rewardsPerWeek[weekCursor] = rewardsPerWeek[weekCursor].add(
                    tokensToDistribute.mul(weekCursor + 1 weeks - rewardTime) / sinceLast
                );
                weekCursor += 1 weeks;
                // Calculate the fraction of rewards for intermediate whole weeks.
                while (weekCursor < currentWeek) {
                    rewardsPerWeek[weekCursor] = tokensToDistribute.mul(1 weeks) / sinceLast;
                    weekCursor += 1 weeks;
                }
                // Calculate the fraction of rewards proportional to the time from
                // the beginning of the current week to the current block timestamp.
                rewardsPerWeek[weekCursor] =
                    tokensToDistribute.mul(block.timestamp - weekCursor) /
                    sinceLast;
            }
        }

        checkpointTimestamp = block.timestamp;
    }

    function _updateAdmin(address newAdmin) private {
        admin = newAdmin;
        emit AdminUpdated(newAdmin);
    }

    function updateAdmin(address newAdmin) external onlyOwner {
        _updateAdmin(newAdmin);
    }

    function _updateAdminFeeRate(uint256 newAdminFeeRate) private {
        require(newAdminFeeRate <= MAX_ADMIN_FEE_RATE, "Cannot exceed max admin fee rate");
        adminFeeRate = newAdminFeeRate;
        emit AdminFeeRateUpdated(newAdminFeeRate);
    }

    function updateAdminFeeRate(uint256 newAdminFeeRate) external onlyOwner {
        _updateAdminFeeRate(newAdminFeeRate);
    }

    /// @dev Calculate rewards since a user's last checkpoint and make a new checkpoint.
    ///
    ///      Post-conditions:
    ///
    ///      - `userWeekCursor[account]` is the start timestamp of the current week
    ///      - `userLastBalances[account]` is amount of veCHESS at the beginning of the current week
    /// @param account Address of the account
    /// @return Rewards since the last checkpoint
    function _rewardCheckpoint(address account) private returns (uint256) {
        uint256 currentWeek = _endOfWeek(block.timestamp) - 1 weeks;
        uint256 weekCursor = userWeekCursors[account];
        if (weekCursor >= currentWeek) {
            return 0;
        }
        if (weekCursor == 0) {
            userWeekCursors[account] = currentWeek;
            return 0;
        }

        // The week of the last user checkpoint has ended.
        uint256 lastBalance = userLastBalances[account];
        uint256 rewards =
            lastBalance > 0
                ? lastBalance.mul(rewardsPerWeek[weekCursor]) / veSupplyPerWeek[weekCursor]
                : 0;
        weekCursor += 1 weeks;

        // Iterate over succeeding weeks and calculate rewards.
        IVotingEscrow.LockedBalance memory lockedBalance = userLockedBalances[account];
        while (weekCursor < currentWeek) {
            uint256 veChessBalance = _balanceAtTimestamp(lockedBalance, weekCursor);
            if (veChessBalance == 0) {
                break;
            }
            // A positive veChessBalance guarentees that veSupply of that week is also positive
            rewards = rewards.add(
                veChessBalance.mul(rewardsPerWeek[weekCursor]) / veSupplyPerWeek[weekCursor]
            );
            weekCursor += 1 weeks;
        }

        userWeekCursors[account] = currentWeek;
        userLastBalances[account] = _balanceAtTimestamp(lockedBalance, currentWeek);
        return rewards;
    }

    /// @notice Recalculate `nextWeekSupply` from scratch. This function eliminates accumulated
    ///         rounding errors in `nextWeekSupply`, which is incrementally updated in
    ///         `syncWithVotingEscrow()` and `checkpoint()`. It is almost never required.
    /// @dev See related test cases for details about the rounding errors.
    function calibrateSupply() external {
        uint256 nextWeek = _endOfWeek(checkpointTimestamp);
        nextWeekSupply = _totalSupplyAtTimestamp(nextWeek);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../utils/CoreUtility.sol";
import "../utils/ManagedPausable.sol";
import "../interfaces/IVotingEscrow.sol";
import "../utils/ProxyUtility.sol";

interface IAddressWhitelist {
    function check(address account) external view returns (bool);
}

interface IVotingEscrowCallback {
    function syncWithVotingEscrow(address account) external;
}

contract VotingEscrowV2 is
    IVotingEscrow,
    OwnableUpgradeable,
    ReentrancyGuard,
    CoreUtility,
    ManagedPausable,
    ProxyUtility
{
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[29] private _reservedSlots;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event LockCreated(address indexed account, uint256 amount, uint256 unlockTime);

    event AmountIncreased(address indexed account, uint256 increasedAmount);

    event UnlockTimeIncreased(address indexed account, uint256 newUnlockTime);

    event Withdrawn(address indexed account, uint256 amount);

    uint8 public constant decimals = 18;

    uint256 public immutable override maxTime;

    address public immutable override token;

    string public name;
    string public symbol;

    address public addressWhitelist;

    mapping(address => LockedBalance) public locked;

    /// @notice Mapping of unlockTime => total amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;

    /// @notice max lock time allowed at the moment
    uint256 public maxTimeAllowed;

    /// @notice Contract to be call when an account's locked CHESS is updated
    address public callback;

    /// @notice Amount of Chess locked now. Expired locks are not included.
    uint256 public totalLocked;

    /// @notice Total veCHESS at the end of the last checkpoint's week
    uint256 public nextWeekSupply;

    /// @notice Mapping of week => vote-locked chess total supplies
    ///
    ///         Key is the start timestamp of a week on each Thursday. Value is
    ///         vote-locked chess total supplies captured at the start of each week
    mapping(uint256 => uint256) public veSupplyPerWeek;

    /// @notice Start timestamp of the trading week in which the last checkpoint is made
    uint256 public checkpointWeek;

    constructor(address token_, uint256 maxTime_) public {
        token = token_;
        maxTime = maxTime_;
    }

    /// @dev Initialize the contract. The contract is designed to be used with OpenZeppelin's
    ///      `TransparentUpgradeableProxy`. This function should be called by the proxy's
    ///      constructor (via the `_data` argument).
    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 maxTimeAllowed_
    ) external initializer {
        __Ownable_init();
        require(maxTimeAllowed_ <= maxTime, "Cannot exceed max time");
        maxTimeAllowed = maxTimeAllowed_;
        _initializeV2(msg.sender, name_, symbol_);
    }

    /// @dev Initialize the part added in V2. If this contract is upgraded from the previous
    ///      version, call `upgradeToAndCall` of the proxy and put a call to this function
    ///      in the `data` argument.
    ///
    ///      In the previous version, name and symbol were not correctly initialized via proxy.
    function initializeV2(
        address pauser_,
        string memory name_,
        string memory symbol_
    ) external onlyProxyAdmin {
        _initializeV2(pauser_, name_, symbol_);
    }

    function _initializeV2(
        address pauser_,
        string memory name_,
        string memory symbol_
    ) private {
        _initializeManagedPausable(pauser_);
        require(bytes(name).length == 0 && bytes(symbol).length == 0);
        name = name_;
        symbol = symbol_;

        // Initialize totalLocked, nextWeekSupply and checkpointWeek
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 totalLocked_ = 0;
        uint256 nextWeekSupply_ = 0;
        for (
            uint256 weekCursor = nextWeek;
            weekCursor <= nextWeek + maxTime;
            weekCursor += 1 weeks
        ) {
            totalLocked_ = totalLocked_.add(scheduledUnlock[weekCursor]);
            nextWeekSupply_ = nextWeekSupply_.add(
                (scheduledUnlock[weekCursor].mul(weekCursor - nextWeek)) / maxTime
            );
        }
        totalLocked = totalLocked_;
        nextWeekSupply = nextWeekSupply_;
        checkpointWeek = nextWeek - 1 weeks;
    }

    function getTimestampDropBelow(address account, uint256 threshold)
        external
        view
        override
        returns (uint256)
    {
        LockedBalance memory lockedBalance = locked[account];
        if (lockedBalance.amount == 0 || lockedBalance.amount < threshold) {
            return 0;
        }
        return lockedBalance.unlockTime.sub(threshold.mul(maxTime).div(lockedBalance.amount));
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOfAtTimestamp(account, block.timestamp);
    }

    function totalSupply() external view override returns (uint256) {
        uint256 weekCursor = checkpointWeek;
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 currentWeek = nextWeek - 1 weeks;
        uint256 newNextWeekSupply = nextWeekSupply;
        uint256 newTotalLocked = totalLocked;
        if (weekCursor < currentWeek) {
            weekCursor += 1 weeks;
            for (; weekCursor < currentWeek; weekCursor += 1 weeks) {
                // Remove Chess unlocked at the beginning of the next week from total locked amount.
                newTotalLocked = newTotalLocked.sub(scheduledUnlock[weekCursor]);
                // Calculate supply at the end of the next week.
                newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(1 weeks) / maxTime);
            }
            newTotalLocked = newTotalLocked.sub(scheduledUnlock[weekCursor]);
            newNextWeekSupply = newNextWeekSupply.sub(
                newTotalLocked.mul(block.timestamp - currentWeek) / maxTime
            );
        } else {
            newNextWeekSupply = newNextWeekSupply.add(
                newTotalLocked.mul(nextWeek - block.timestamp) / maxTime
            );
        }

        return newNextWeekSupply;
    }

    function getLockedBalance(address account)
        external
        view
        override
        returns (LockedBalance memory)
    {
        return locked[account];
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp)
        external
        view
        override
        returns (uint256)
    {
        return _balanceOfAtTimestamp(account, timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256) {
        return _totalSupplyAtTimestamp(timestamp);
    }

    function createLock(uint256 amount, uint256 unlockTime) external nonReentrant whenNotPaused {
        _assertNotContract();
        require(
            unlockTime + 1 weeks == _endOfWeek(unlockTime),
            "Unlock time must be end of a week"
        );

        LockedBalance memory lockedBalance = locked[msg.sender];

        require(amount > 0, "Zero value");
        require(lockedBalance.amount == 0, "Withdraw old tokens first");
        require(unlockTime > block.timestamp, "Can only lock until time in the future");
        require(
            unlockTime <= block.timestamp + maxTimeAllowed,
            "Voting lock cannot exceed max lock time"
        );

        _checkpoint(lockedBalance.amount, lockedBalance.unlockTime, amount, unlockTime);
        scheduledUnlock[unlockTime] = scheduledUnlock[unlockTime].add(amount);
        locked[msg.sender].unlockTime = unlockTime;
        locked[msg.sender].amount = amount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit LockCreated(msg.sender, amount, unlockTime);
    }

    function increaseAmount(address account, uint256 amount) external nonReentrant whenNotPaused {
        LockedBalance memory lockedBalance = locked[account];

        require(amount > 0, "Zero value");
        require(lockedBalance.unlockTime > block.timestamp, "Cannot add to expired lock");

        uint256 newAmount = lockedBalance.amount.add(amount);
        _checkpoint(
            lockedBalance.amount,
            lockedBalance.unlockTime,
            newAmount,
            lockedBalance.unlockTime
        );
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].add(
            amount
        );
        locked[account].amount = newAmount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit AmountIncreased(account, amount);
    }

    function increaseUnlockTime(uint256 unlockTime) external nonReentrant whenNotPaused {
        require(
            unlockTime + 1 weeks == _endOfWeek(unlockTime),
            "Unlock time must be end of a week"
        );
        LockedBalance memory lockedBalance = locked[msg.sender];

        require(lockedBalance.unlockTime > block.timestamp, "Lock expired");
        require(unlockTime > lockedBalance.unlockTime, "Can only increase lock duration");
        require(
            unlockTime <= block.timestamp + maxTimeAllowed,
            "Voting lock cannot exceed max lock time"
        );

        _checkpoint(
            lockedBalance.amount,
            lockedBalance.unlockTime,
            lockedBalance.amount,
            unlockTime
        );
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].sub(
            lockedBalance.amount
        );
        scheduledUnlock[unlockTime] = scheduledUnlock[unlockTime].add(lockedBalance.amount);
        locked[msg.sender].unlockTime = unlockTime;

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit UnlockTimeIncreased(msg.sender, unlockTime);
    }

    function withdraw() external nonReentrant {
        LockedBalance memory lockedBalance = locked[msg.sender];
        require(block.timestamp >= lockedBalance.unlockTime, "The lock is not expired");
        uint256 amount = uint256(lockedBalance.amount);

        lockedBalance.unlockTime = 0;
        lockedBalance.amount = 0;
        locked[msg.sender] = lockedBalance;

        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function updateAddressWhitelist(address newWhitelist) external onlyOwner {
        require(
            newWhitelist == address(0) || Address.isContract(newWhitelist),
            "Must be null or a contract"
        );
        addressWhitelist = newWhitelist;
    }

    function updateCallback(address newCallback) external onlyOwner {
        require(
            newCallback == address(0) || Address.isContract(newCallback),
            "Must be null or a contract"
        );
        callback = newCallback;
    }

    function _assertNotContract() private view {
        if (msg.sender != tx.origin) {
            if (
                addressWhitelist != address(0) &&
                IAddressWhitelist(addressWhitelist).check(msg.sender)
            ) {
                return;
            }
            revert("Smart contract depositors not allowed");
        }
    }

    function _balanceOfAtTimestamp(address account, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        require(timestamp >= block.timestamp, "Must be current or future time");
        LockedBalance memory lockedBalance = locked[account];
        if (timestamp > lockedBalance.unlockTime) {
            return 0;
        }
        return (lockedBalance.amount.mul(lockedBalance.unlockTime - timestamp)) / maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp) private view returns (uint256) {
        uint256 weekCursor = _endOfWeek(timestamp);
        uint256 total = 0;
        for (; weekCursor <= timestamp + maxTime; weekCursor += 1 weeks) {
            total = total.add((scheduledUnlock[weekCursor].mul(weekCursor - timestamp)) / maxTime);
        }
        return total;
    }

    /// @dev Pre-conditions:
    ///
    ///      - `newAmount > 0`
    ///      - `newUnlockTime > block.timestamp`
    ///      - `newUnlockTime + 1 weeks == _endOfWeek(newUnlockTime)`, i.e. aligned to a trading week
    ///
    ///      The latter two conditions gaurantee that `newUnlockTime` is no smaller than the local
    ///      variable `nextWeek` in the function.
    function _checkpoint(
        uint256 oldAmount,
        uint256 oldUnlockTime,
        uint256 newAmount,
        uint256 newUnlockTime
    ) private {
        // Update veCHESS supply at the beginning of each week since the last checkpoint.
        uint256 weekCursor = checkpointWeek;
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 currentWeek = nextWeek - 1 weeks;
        uint256 newTotalLocked = totalLocked;
        uint256 newNextWeekSupply = nextWeekSupply;
        if (weekCursor < currentWeek) {
            for (uint256 w = weekCursor + 1 weeks; w <= currentWeek; w += 1 weeks) {
                veSupplyPerWeek[w] = newNextWeekSupply;
                // Remove Chess unlocked at the beginning of this week from total locked amount.
                newTotalLocked = newTotalLocked.sub(scheduledUnlock[w]);
                // Calculate supply at the end of the next week.
                newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(1 weeks) / maxTime);
            }
            checkpointWeek = currentWeek;
        }

        // Remove the old schedule if there is one
        if (oldAmount > 0 && oldUnlockTime >= nextWeek) {
            newTotalLocked = newTotalLocked.sub(oldAmount);
            newNextWeekSupply = newNextWeekSupply.sub(
                oldAmount.mul(oldUnlockTime - nextWeek) / maxTime
            );
        }

        totalLocked = newTotalLocked.add(newAmount);
        // Round up on division when added to the total supply, so that the total supply is never
        // smaller than the sum of all accounts' veCHESS balance.
        nextWeekSupply = newNextWeekSupply.add(
            newAmount.mul(newUnlockTime - nextWeek).add(maxTime - 1) / maxTime
        );
    }

    function updateMaxTimeAllowed(uint256 newMaxTimeAllowed) external onlyOwner {
        require(newMaxTimeAllowed <= maxTime, "Cannot exceed max time");
        require(newMaxTimeAllowed > maxTimeAllowed, "Cannot shorten max time allowed");
        maxTimeAllowed = newMaxTimeAllowed;
    }

    /// @notice Recalculate `nextWeekSupply` from scratch. This function eliminates accumulated
    ///         rounding errors in `nextWeekSupply`, which is incrementally updated in
    ///         `createLock`, `increaseAmount` and `increaseUnlockTime`. It is almost
    ///         never required.
    /// @dev Search "rounding error" in test cases for details about the rounding errors.
    function calibrateSupply() external {
        uint256 nextWeek = checkpointWeek + 1 weeks;
        nextWeekSupply = _totalSupplyAtTimestamp(nextWeek);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "../../utils/CoreUtility.sol";
import "../../utils/SafeDecimalMath.sol";
import "../../interfaces/IChessController.sol";
import "../interfaces/IFund.sol";
import "../../interfaces/IControllerBallot.sol";

contract ChessControllerV4 is IChessController, CoreUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[192] private _reservedSlots;

    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    event WeightUpdated(address indexed fund, uint256 indexed timestamp, uint256 weight);

    address public immutable fund0;
    uint256 public immutable guardedLaunchStart;
    address public immutable controllerBallot;

    mapping(uint256 => mapping(address => uint256)) public weights;

    /// @notice Start timestamp of the last trading week that has weights updated.
    uint256 public lastTimestamp;

    constructor(
        address fund0_,
        uint256 guardedLaunchStart_,
        address controllerBallot_
    ) public {
        fund0 = fund0_;
        guardedLaunchStart = guardedLaunchStart_;
        require(_endOfWeek(guardedLaunchStart_) == guardedLaunchStart_ + 1 weeks);
        controllerBallot = controllerBallot_;
    }

    /// @dev Initialize the part added in V4. The contract is designed to be used with OpenZeppelin's
    ///      `TransparentUpgradeableProxy`. If this contract is upgraded from the previous version,
    ///      call `upgradeToAndCall` of the proxy and put a call to this function in the `data`
    ///      argument with `lastTimestamp_` set to the last updated week. If this contract is
    ///      the first implementation of the proxy, This function should be called by the proxy's
    ///      constructor (via the `_data` argument) with `lastTimestamp_` set to one week before
    ///      `guardedLaunchStart`.
    function initializeV4(uint256 lastTimestamp_) external {
        require(lastTimestamp == 0, "Already initialized");
        require(
            _endOfWeek(lastTimestamp_) == lastTimestamp_ + 1 weeks &&
                lastTimestamp_ >= guardedLaunchStart - 1 weeks
        );
        require(weights[lastTimestamp_ + 1 weeks][fund0] == 0, "Next week already updated");
        if (lastTimestamp_ >= guardedLaunchStart) {
            require(weights[lastTimestamp_][fund0] > 0, "Last week not updated");
        }
        lastTimestamp = lastTimestamp_;
    }

    /// @notice Get Fund relative weight (not more than 1.0) normalized to 1e18
    ///         (e.g. 1.0 == 1e18).
    /// @return weight Value of relative weight normalized to 1e18
    function getFundRelativeWeight(address fundAddress, uint256 timestamp)
        external
        override
        returns (uint256)
    {
        require(timestamp <= block.timestamp, "Too soon");
        if (timestamp < guardedLaunchStart) {
            return fundAddress == fund0 ? 1e18 : 0;
        }
        uint256 weekTimestamp = _endOfWeek(timestamp).sub(1 weeks);
        uint256 lastTimestamp_ = lastTimestamp; // gas saver
        require(weekTimestamp <= lastTimestamp_ + 1 weeks, "Previous week is empty");
        if (weekTimestamp <= lastTimestamp_) {
            return weights[weekTimestamp][fundAddress];
        }
        lastTimestamp = lastTimestamp_ + 1 weeks;
        return _updateFundWeight(weekTimestamp, fundAddress);
    }

    function _updateFundWeight(uint256 weekTimestamp, address fundAddress)
        private
        returns (uint256 weight)
    {
        (uint256[] memory ballotWeights, address[] memory funds) =
            IControllerBallot(controllerBallot).count(weekTimestamp);

        uint256 totalValueLocked;
        uint256[] memory fundValueLocked = new uint256[](ballotWeights.length);
        for (uint256 i = 0; i < ballotWeights.length; i++) {
            fundValueLocked[i] = getFundValueLocked(funds[i], weekTimestamp);
            totalValueLocked = totalValueLocked.add(fundValueLocked[i]);
        }

        uint256 totalWeight;
        for (uint256 i = 0; i < ballotWeights.length; i++) {
            uint256 fundWeight = ballotWeights[i];
            if (totalValueLocked > 0) {
                fundWeight = fundWeight.add(fundValueLocked[i].divideDecimal(totalValueLocked)) / 2;
            }
            weights[weekTimestamp][funds[i]] = fundWeight;
            emit WeightUpdated(funds[i], weekTimestamp, fundWeight);
            if (funds[i] == fundAddress) {
                weight = fundWeight;
            }
            totalWeight = totalWeight.add(fundWeight);
        }
        require(totalWeight <= 1e18, "Total weight exceeds 100%");
    }

    function getFundValueLocked(address fund, uint256 weekTimestamp) public view returns (uint256) {
        uint256 timestamp = (IFund(fund).currentDay() - 1 days).min(weekTimestamp);
        (uint256 navM, , ) = IFund(fund).historicalNavs(timestamp);
        return IFund(fund).historicalTotalShares(timestamp).multiplyDecimal(navM);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../utils/CoreUtility.sol";
import "../utils/SafeDecimalMath.sol";

import {IVotingEscrowCallback} from "../governance/VotingEscrowV2.sol";
import "../interfaces/IControllerBallot.sol";
import "../interfaces/IVotingEscrow.sol";

contract ControllerBallot is IControllerBallot, IVotingEscrowCallback, Ownable, CoreUtility {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    event PoolAdded(address pool);
    event PoolToggled(address indexed pool, bool isDisabled);
    event Voted(
        address indexed account,
        uint256 oldAmount,
        uint256 oldUnlockTime,
        uint256[] oldWeights,
        uint256 amount,
        uint256 unlockTime,
        uint256[] weights
    );

    IVotingEscrow public immutable votingEscrow;
    uint256 private immutable _maxTime;

    address[65535] private _pools;
    uint256 public poolSize;
    uint256 public disabledPoolSize;

    /// @notice Locked balance of an account, which is synchronized with `VotingEscrow` when
    ///         `syncWithVotingEscrow()` is called
    mapping(address => IVotingEscrow.LockedBalance) public userLockedBalances;

    /// @notice Mapping of account => pool => fraction of the user's veCHESS voted to the pool
    mapping(address => mapping(address => uint256)) public userWeights;

    /// @notice Mapping of pool => unlockTime => CHESS amount voted to the pool that will be
    ///         unlocked at unlockTime
    mapping(address => mapping(uint256 => uint256)) public poolScheduledUnlock;

    /// @notice Mapping of pool => status of the pool
    mapping(uint256 => bool) public disabledPools;

    constructor(address votingEscrow_) public {
        votingEscrow = IVotingEscrow(votingEscrow_);
        _maxTime = IVotingEscrow(votingEscrow_).maxTime();
    }

    function getPools() external view returns (address[] memory) {
        uint256 size = poolSize;
        address[] memory pools = new address[](size);
        for (uint256 i = 0; i < size; i++) {
            pools[i] = _pools[i];
        }
        return pools;
    }

    function addPool(address newPool) external onlyOwner {
        uint256 size = poolSize;
        _pools[size] = newPool;
        poolSize = size + 1;
        emit PoolAdded(newPool);
    }

    function togglePool(uint256 index) external onlyOwner {
        require(index < poolSize, "Invalid index");
        if (disabledPools[index]) {
            disabledPools[index] = false;
            disabledPoolSize--;
        } else {
            disabledPools[index] = true;
            disabledPoolSize++;
        }
        emit PoolToggled(_pools[index], disabledPools[index]);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balanceOfAtTimestamp(account, block.timestamp);
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp)
        public
        view
        returns (uint256)
    {
        require(timestamp >= block.timestamp, "Must be current or future time");
        IVotingEscrow.LockedBalance memory locked = userLockedBalances[account];
        if (timestamp >= locked.unlockTime) {
            return 0;
        }
        return locked.amount.mul(locked.unlockTime - timestamp) / _maxTime;
    }

    function totalSupply() external view returns (uint256) {
        return totalSupplyAtTimestamp(block.timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) public view returns (uint256) {
        uint256 size = poolSize;
        uint256 total = 0;
        for (uint256 i = 0; i < size; i++) {
            total = total.add(sumAtTimestamp(_pools[i], timestamp));
        }
        return total;
    }

    function sumAtTimestamp(address pool, uint256 timestamp) public view returns (uint256) {
        uint256 sum = 0;
        for (
            uint256 weekCursor = _endOfWeek(timestamp);
            weekCursor <= timestamp + _maxTime;
            weekCursor += 1 weeks
        ) {
            sum = sum.add(
                poolScheduledUnlock[pool][weekCursor].mul(weekCursor - timestamp) / _maxTime
            );
        }
        return sum;
    }

    function count(uint256 timestamp)
        external
        view
        override
        returns (uint256[] memory weights, address[] memory pools)
    {
        uint256 poolSize_ = poolSize;
        uint256 size = poolSize_ - disabledPoolSize;
        pools = new address[](size);
        uint256 j = 0;
        for (uint256 i = 0; i < poolSize_ && j < size; i++) {
            address pool = _pools[i];
            if (!disabledPools[i]) pools[j++] = pool;
        }

        uint256[] memory sums = new uint256[](size);
        uint256 total = 0;
        for (uint256 i = 0; i < size; i++) {
            uint256 sum = sumAtTimestamp(pools[i], timestamp);
            sums[i] = sum;
            total = total.add(sum);
        }

        weights = new uint256[](size);
        if (total == 0) {
            for (uint256 i = 0; i < size; i++) {
                weights[i] = 1e18 / size;
            }
        } else {
            for (uint256 i = 0; i < size; i++) {
                weights[i] = sums[i].divideDecimal(total);
            }
        }
    }

    function cast(uint256[] memory weights) external {
        uint256 size = poolSize;
        require(weights.length == size, "Invalid number of weights");
        uint256 totalWeight;
        for (uint256 i = 0; i < size; i++) {
            totalWeight = totalWeight.add(weights[i]);
        }
        require(totalWeight == 1e18, "Invalid weights");

        uint256[] memory oldWeights = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            oldWeights[i] = userWeights[msg.sender][_pools[i]];
        }

        IVotingEscrow.LockedBalance memory oldLockedBalance = userLockedBalances[msg.sender];
        IVotingEscrow.LockedBalance memory lockedBalance =
            votingEscrow.getLockedBalance(msg.sender);
        require(
            lockedBalance.amount > 0 && lockedBalance.unlockTime > block.timestamp,
            "No veCHESS"
        );

        _updateVoteStatus(msg.sender, size, oldWeights, weights, oldLockedBalance, lockedBalance);
    }

    function syncWithVotingEscrow(address account) external override {
        IVotingEscrow.LockedBalance memory oldLockedBalance = userLockedBalances[account];
        if (oldLockedBalance.amount == 0) {
            return; // The account did not voted before
        }
        IVotingEscrow.LockedBalance memory lockedBalance = votingEscrow.getLockedBalance(account);
        if (lockedBalance.unlockTime <= block.timestamp) {
            return;
        }

        uint256 size = poolSize;
        uint256[] memory weights = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            weights[i] = userWeights[account][_pools[i]];
        }

        _updateVoteStatus(account, size, weights, weights, oldLockedBalance, lockedBalance);
    }

    function _updateVoteStatus(
        address account,
        uint256 size,
        uint256[] memory oldWeights,
        uint256[] memory weights,
        IVotingEscrow.LockedBalance memory oldLockedBalance,
        IVotingEscrow.LockedBalance memory lockedBalance
    ) private {
        for (uint256 i = 0; i < size; i++) {
            address pool = _pools[i];
            poolScheduledUnlock[pool][oldLockedBalance.unlockTime] = poolScheduledUnlock[pool][
                oldLockedBalance.unlockTime
            ]
                .sub(oldLockedBalance.amount.multiplyDecimal(oldWeights[i]));

            poolScheduledUnlock[pool][lockedBalance.unlockTime] = poolScheduledUnlock[pool][
                lockedBalance.unlockTime
            ]
                .add(lockedBalance.amount.multiplyDecimal(weights[i]));
            userWeights[account][pool] = weights[i];
        }
        userLockedBalances[account] = lockedBalance;
        emit Voted(
            account,
            oldLockedBalance.amount,
            oldLockedBalance.unlockTime,
            oldWeights,
            lockedBalance.amount,
            lockedBalance.unlockTime,
            weights
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract of an emergency stop mechanism that can be triggered by an authorized account.
 *
 * This module is modified based on Pausable in OpenZeppelin v3.3.0, adding public functions to
 * pause, unpause and manage the pauser role. It is also designed to be used by upgradable
 * contracts, like PausableUpgradable but with compact storage slots and no dependencies.
 */
abstract contract ManagedPausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    event PauserRoleTransferred(address indexed previousPauser, address indexed newPauser);

    uint256 private constant FALSE = 0;
    uint256 private constant TRUE = 1;

    uint256 private _initialized;

    uint256 private _paused;

    address private _pauser;

    function _initializeManagedPausable(address pauser_) internal {
        require(_initialized == FALSE);
        _initialized = TRUE;
        _paused = FALSE;
        _pauser = pauser_;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused != FALSE;
    }

    function pauser() public view returns (address) {
        return _pauser;
    }

    function renouncePauserRole() external onlyPauser {
        emit PauserRoleTransferred(_pauser, address(0));
        _pauser = address(0);
    }

    function transferPauserRole(address newPauser) external onlyPauser {
        require(newPauser != address(0));
        emit PauserRoleTransferred(_pauser, newPauser);
        _pauser = newPauser;
    }

    modifier onlyPauser() {
        require(_pauser == msg.sender, "Pausable: only pauser");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(_paused == FALSE, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused != FALSE, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external onlyPauser whenNotPaused {
        _paused = TRUE;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external onlyPauser whenPaused {
        _paused = FALSE;
        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

abstract contract ProxyUtility {
    /// @dev Storage slot with the admin of the contract.
    bytes32 private constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    /// @dev Revert if the proxy admin is not the caller
    modifier onlyProxyAdmin() {
        bytes32 slot = _ADMIN_SLOT;
        address proxyAdmin;
        assembly {
            proxyAdmin := sload(slot)
        }
        require(msg.sender == proxyAdmin, "Only proxy admin");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

/// @notice A maker order
/// @param prev Index of the previous order at the same premium-discount level,
///             or zero if this is the first one
/// @param next Index of the next order at the same premium-discount level,
///             or zero if this is the last one
/// @param maker Account placing this order
/// @param amount Original amount of the order, which is amount of quote asset with 18 decimal places
///               for a bid order, or amount of base asset for an ask order
/// @param version Rebalance version when the order is placed
/// @param fillable Currently fillable amount
struct Order {
    uint256 prev;
    uint256 next;
    address maker;
    uint256 amount;
    uint256 version;
    uint256 fillable;
}

/// @notice A queue of orders with the same premium-discount level.
///
///         An order queue assigns a unique index to each order and stores the orders in a doubly
///         linked list. Orders can be removed from the queue by cancellation, expiration or trade.
/// @param list Mapping of order index => order
/// @param head Index of the first order in the queue, or zero if the queue is empty
/// @param tail Index of the last order in the queue, or zero if the queue is empty
/// @param counter The total number of orders that have been added to the queue, no matter whether
///                they are still active or not
struct OrderQueue {
    mapping(uint256 => Order) list;
    uint256 head;
    uint256 tail;
    uint256 counter;
}

/// @title Tranchess's Exchange Order Queue Contract
/// @notice Order queue struct and implementation using doubly linked list
/// @author Tranchess
library LibOrderQueue {
    function isEmpty(OrderQueue storage queue) internal view returns (bool) {
        return queue.head == 0;
    }

    /// @notice Append a new order to the queue
    /// @param queue Order queue
    /// @param maker Maker address
    /// @param amount Amount to place in the order with 18 decimal places
    /// @param version Current rebalance version
    /// @return Index of the order in the order queue
    function append(
        OrderQueue storage queue,
        address maker,
        uint256 amount,
        uint256 version
    ) internal returns (uint256) {
        uint256 index = queue.counter + 1;
        queue.counter = index;
        uint256 tail = queue.tail;
        queue.list[index] = Order({
            prev: tail,
            next: 0,
            maker: maker,
            amount: amount,
            version: version,
            fillable: amount
        });
        if (tail == 0) {
            // The queue was empty.
            queue.head = index;
        } else {
            // The queue was not empty.
            queue.list[tail].next = index;
        }
        queue.tail = index;
        return index;
    }

    /// @dev Cancel an order from the queue.
    /// @param queue Order queue
    /// @param index Index of the order to be canceled
    function cancel(OrderQueue storage queue, uint256 index) internal {
        uint256 oldHead = queue.head;
        if (index >= oldHead && oldHead > 0) {
            // The order is still active.
            Order storage order = queue.list[index];
            uint256 prev = order.prev;
            uint256 next = order.next;
            if (prev == 0) {
                // This is the first but not the only order.
                queue.head = next;
            } else {
                queue.list[prev].next = next;
            }
            if (next == 0) {
                // This is the last but not the only order.
                queue.tail = prev;
            } else {
                queue.list[next].prev = prev;
            }
        }
        delete queue.list[index];
    }

    /// @dev Remove an order that is completely filled in matching. Links of the previous
    ///      and next order are not updated here. Caller must call `updateHead` after finishing
    ///      the matching on this queue.
    /// @param queue Order queue
    /// @param index Index of the order to be removed
    /// @return nextIndex Index of the next order, or zero if the removed order is the last one
    function fill(OrderQueue storage queue, uint256 index) internal returns (uint256 nextIndex) {
        nextIndex = queue.list[index].next;
        delete queue.list[index];
    }

    /// @dev Update head and tail of the queue. This function should be called after matching
    ///      a taker order with this order queue and all orders before the new head are either
    ///      completely filled or expired.
    /// @param queue Order queue
    /// @param newHead Index of the first order that is still active now,
    ///                or zero if the queue is empty
    function updateHead(OrderQueue storage queue, uint256 newHead) internal {
        queue.head = newHead;
        if (newHead == 0) {
            queue.tail = 0;
        } else {
            queue.list[newHead].prev = 0;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/IVotingEscrow.sol";

/// @title Tranchess's Exchange Role Contract
/// @notice Exchange role management
/// @author Tranchess
abstract contract ExchangeRoles {
    event MakerApplied(address indexed account, uint256 expiration);

    /// @notice Voting Escrow.
    IVotingEscrow public immutable votingEscrow;

    /// @notice Minimum vote-locked governance token balance required to place maker orders.
    uint256 public immutable makerRequirement;

    /// @dev Mapping of account => maker expiration timestamp
    mapping(address => uint256) internal _makerExpiration;

    constructor(address votingEscrow_, uint256 makerRequirement_) public {
        votingEscrow = IVotingEscrow(votingEscrow_);
        makerRequirement = makerRequirement_;
    }

    // ------------------------------ MAKER ------------------------------------
    /// @notice Functions with this modifer can only be invoked by makers
    modifier onlyMaker() {
        require(isMaker(msg.sender), "Only maker");
        _;
    }

    /// @notice Returns maker expiration timestamp of an account.
    ///         When `makerRequirement` is zero, this function always returns
    ///         an extremely large timestamp (2500-01-01 00:00:00 UTC).
    function makerExpiration(address account) external view returns (uint256) {
        return makerRequirement > 0 ? _makerExpiration[account] : 16725225600;
    }

    /// @notice Verify if the account is an active maker or not
    /// @param account Account address to verify
    /// @return True if the account is an active maker; else returns false
    function isMaker(address account) public view returns (bool) {
        return makerRequirement == 0 || _makerExpiration[account] > block.timestamp;
    }

    /// @notice Apply for maker membership
    function applyForMaker() external {
        require(makerRequirement > 0, "No need to apply for maker");
        // The membership will be valid until the current vote-locked governance
        // token balance drop below the requirement.
        uint256 expiration = votingEscrow.getTimestampDropBelow(msg.sender, makerRequirement);
        _makerExpiration[msg.sender] = expiration;
        emit MakerApplied(msg.sender, expiration);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";

abstract contract FundRoles {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _primaryMarketMembers;
    mapping(address => bool) private _shareMembers;

    event PrimaryMarketAdded(address indexed primaryMarket);
    event PrimaryMarketRemoved(address indexed primaryMarket);

    function _initializeRoles(
        address tokenM_,
        address tokenA_,
        address tokenB_,
        address primaryMarket_
    ) internal {
        _shareMembers[tokenM_] = true;
        _shareMembers[tokenA_] = true;
        _shareMembers[tokenB_] = true;

        _addPrimaryMarket(primaryMarket_);
    }

    modifier onlyPrimaryMarket() {
        require(isPrimaryMarket(msg.sender), "FundRoles: only primary market");
        _;
    }

    function isPrimaryMarket(address account) public view returns (bool) {
        return _primaryMarketMembers.contains(account);
    }

    function getPrimaryMarketMember(uint256 index) public view returns (address) {
        return _primaryMarketMembers.at(index);
    }

    function getPrimaryMarketCount() public view returns (uint256) {
        return _primaryMarketMembers.length();
    }

    function _addPrimaryMarket(address primaryMarket) internal {
        if (_primaryMarketMembers.add(primaryMarket)) {
            emit PrimaryMarketAdded(primaryMarket);
        }
    }

    function _removePrimaryMarket(address primaryMarket) internal {
        if (_primaryMarketMembers.remove(primaryMarket)) {
            emit PrimaryMarketRemoved(primaryMarket);
        }
    }

    modifier onlyShare() {
        require(isShare(msg.sender), "FundRoles: only share");
        _;
    }

    function isShare(address account) public view returns (bool) {
        return _shareMembers[account];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
     * @dev Returns the number of values on the set. O(1).
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
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

struct DelayedRedemptionItem {
    uint192 underlying;
    uint64 next;
}

struct DelayedRedemptionHeadTail {
    uint64 head;
    uint64 tail;
}

/// @notice Delayed redemption
/// @param frozenQuote Amount of quote assets from the taker
/// @param effectiveQuote Effective amount of quote assets at zero premium-discount
/// @param reservedBase Reserved amount of base assets from the maker
struct DelayedRedemption {
    DelayedRedemptionHeadTail headTail;
    mapping(uint64 => DelayedRedemptionItem) list;
}

library LibDelayedRedemption {
    using SafeMath for uint256;

    function get(DelayedRedemption storage self, uint256 day)
        internal
        view
        returns (uint256, uint256)
    {
        DelayedRedemptionItem memory item = self.list[uint64(day)];
        return (item.underlying, item.next);
    }

    /// @dev Append an item to the list.
    /// @param self The list to update
    /// @param underlying Redemption underlying amount
    /// @param day Trading day of the redemption
    function pushBack(
        DelayedRedemption storage self,
        uint256 underlying,
        uint256 day
    ) internal {
        uint64 day64 = uint64(day);
        require(uint192(underlying) == underlying && day64 == day);
        self.list[day64].underlying = uint192(underlying);
        DelayedRedemptionHeadTail memory headTail = self.headTail;
        require(day64 > headTail.tail);
        if (headTail.tail == 0) {
            // The list was empty.
            headTail.head = day64;
            headTail.tail = day64;
        } else {
            self.list[headTail.tail].next = day64;
            headTail.tail = day64;
        }
        self.headTail = headTail;
    }

    /// @dev Remove all items until a given trading day and return the sum of all items.
    /// @param self The list to update
    /// @param day Trading day
    /// @return Sum of all redemptions that are removed from the list
    function popFrontUntil(DelayedRedemption storage self, uint256 day) internal returns (uint256) {
        uint64 day64 = uint64(day);
        require(day64 == day);
        DelayedRedemptionHeadTail memory headTail = self.headTail;
        uint64 p = headTail.head;
        if (p > day64 || p == 0) {
            return 0; // Fast path with no SSTORE
        }
        uint256 underlying = 0;
        while (p != 0 && p <= day64) {
            underlying = underlying.add(uint256(self.list[p].underlying));
            uint64 nextP = self.list[p].next;
            delete self.list[p];
            p = nextP;
        }
        if (p == 0) {
            delete self.headTail; // Set both head and tail to zero
        } else {
            headTail.head = p;
            self.headTail = headTail;
        }
        return underlying;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWrappedERC20 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface IControllerBallot {
    function count(uint256 timestamp)
        external
        view
        returns (uint256[] memory ratios, address[] memory funds);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

import "../interfaces/ITrancheIndexV2.sol";
import "../interfaces/IChessSchedule.sol";
import "../utils/CoreUtility.sol";

import "../fund/FundV3.sol";
import "../fund/PrimaryMarketV3.sol";
import "../fund/PrimaryMarketRouter.sol";
import "../fund/ShareStaking.sol";
import "../swap/StableSwap.sol";
import "../swap/LiquidityGauge.sol";
import "../swap/SwapBonus.sol";
import "../swap/SwapRouter.sol";
import "../governance/InterestRateBallot.sol";
import "../governance/FeeDistributor.sol";
import "../governance/VotingEscrowV2.sol";
import "../governance/ControllerBallot.sol";

contract DataAggregator is ITrancheIndexV2, CoreUtility {
    struct Data {
        uint256 blockNumber;
        uint256 blockTimestamp;
        FundAllData[] funds;
        GovernanceData governance;
        FeeDistributorData[] feeDistributors;
        ExternalSwapData[] externalSwaps;
    }

    struct FundAllData {
        FundData fund;
        PrimaryMarketData primaryMarket;
        ShareStakingData shareStaking;
        StableSwapData bishopStableSwap;
        StableSwapData queenStableSwap;
        FundAccountData account;
    }

    struct FundData {
        bool isFundActive;
        uint256 fundActivityStartTime;
        uint256 activityDelayTimeAfterRebalance;
        uint256 currentDay;
        uint256 dailyProtocolFeeRate;
        uint256 totalSupplyQ;
        uint256 totalSupplyB;
        uint256 totalUnderlying;
        uint256 strategyUnderlying;
        uint256 rebalanceSize;
        uint256 upperRebalanceThreshold;
        uint256 lowerRebalanceThreshold;
        uint256 splitRatio;
        uint256 latestUnderlyingPrice;
        uint256 navB;
        uint256 navR;
        uint256 currentInterestRate;
        FundV3.Rebalance lastRebalance;
    }

    struct PrimaryMarketData {
        uint256 fundCap;
        uint256 redemptionFeeRate;
        uint256 mergeFeeRate;
        uint256 redemptionQueueHead;
    }

    struct ShareStakingData {
        uint256 totalSupplyQ;
        uint256 totalSupplyB;
        uint256 totalSupplyR;
        uint256 weightedSupply;
        uint256 workingSupply;
        uint256 chessRate;
        ShareStakingAccountData account;
    }

    struct ShareStakingAccountData {
        uint256 balanceQ;
        uint256 balanceB;
        uint256 balanceR;
        uint256 weightedBalance;
        uint256 workingBalance;
        uint256 claimableChess;
    }

    struct StableSwapData {
        uint256 feeRate;
        uint256 adminFeeRate;
        uint256 ampl;
        uint256 currentD;
        uint256 currentPrice;
        uint256 baseBalance;
        uint256 quoteBalance;
        uint256 oraclePrice;
        uint256 lpTotalSupply;
        uint256 lpWorkingSupply;
        uint256 chessRate;
        uint256 lastDistributionQ;
        uint256 lastDistributionB;
        uint256 lastDistributionR;
        uint256 lastDistributionQuote;
        uint256 lastDistributionTotalSupply;
        address bonusToken;
        uint256 bonusRate;
        StableSwapAccountData account;
    }

    struct StableSwapAccountData {
        uint256 lpBalance;
        uint256 workingBalance;
        uint256 claimableChess;
        uint256 claimableBonus;
        uint256 claimableQ;
        uint256 claimableB;
        uint256 claimableR;
        uint256 claimableQuote;
    }

    struct FundAccountData {
        FundAccountBalanceData balance;
        FundAccountAllowanceData allowance;
    }

    struct FundAccountBalanceData {
        uint256 underlying;
        uint256 quote;
        uint256 trancheQ;
        uint256 trancheB;
        uint256 trancheR;
    }

    struct FundAccountAllowanceData {
        uint256 primaryMarketRouterUnderlying;
        uint256 primaryMarketRouterTrancheQ;
        uint256 swapRouterUnderlying;
        uint256 swapRouterTrancheQ;
        uint256 swapRouterTrancheB;
        uint256 swapRouterQuote;
        uint256 flashSwapRouterTrancheR;
        uint256 flashSwapRouterQuote;
        uint256 shareStakingTrancheQ;
        uint256 shareStakingTrancheB;
        uint256 shareStakingTrancheR;
    }

    struct GovernanceData {
        uint256 chessRate;
        uint256 nextWeekChessRate;
        VotingEscrowData votingEscrow;
        InterestRateBallotData interestRateBallot;
        ControllerBallotData controllerBallot;
        GovernanceAccountData account;
    }

    struct VotingEscrowData {
        uint256 totalLocked;
        uint256 totalSupply;
        uint256 tradingWeekTotalSupply;
        IVotingEscrow.LockedBalance account;
    }

    struct InterestRateBallotData {
        uint256 tradingWeekTotalSupply;
        IBallot.Voter account;
    }

    struct ControllerBallotData {
        address[] pools;
        uint256[] currentSums;
        ControllerBallotAccountData account;
    }

    struct ControllerBallotAccountData {
        uint256 amount;
        uint256 unlockTime;
        uint256[] weights;
    }

    struct GovernanceAccountData {
        GovernanceAccountBalanceData balance;
        GovernanceAccountAllowanceData allowance;
    }

    struct GovernanceAccountBalanceData {
        uint256 nativeCurrency;
        uint256 chess;
    }

    struct GovernanceAccountAllowanceData {
        uint256 votingEscrowChess;
    }

    struct FeeDistributorData {
        uint256 currentRewards;
        uint256 currentSupply;
        uint256 tradingWeekTotalSupply;
        uint256 adminFeeRate;
        FeeDistributorAccountData account;
    }

    struct FeeDistributorAccountData {
        uint256 claimableRewards;
        uint256 currentBalance;
        uint256 amount;
        uint256 unlockTime;
    }

    struct ExternalSwapData {
        string symbol0;
        string symbol1;
        uint112 reserve0;
        uint112 reserve1;
    }

    string public constant VERSION = "2.0.0";

    VotingEscrowV2 public immutable votingEscrow;
    IChessSchedule public immutable chessSchedule;
    IERC20 public immutable chess;
    ControllerBallot public immutable controllerBallot;
    InterestRateBallot public immutable interestRateBallot;
    SwapRouter public immutable swapRouter;
    address public immutable flashSwapRouter;
    IERC20 public immutable bishopQuoteToken;

    constructor(
        VotingEscrowV2 votingEscrow_,
        IChessSchedule chessSchedule_,
        ControllerBallot controllerBallot_,
        InterestRateBallot interestRateBallot_,
        SwapRouter swapRouter_,
        address flashSwapRouter_,
        IERC20 bishopQuoteToken_
    ) public {
        votingEscrow = votingEscrow_;
        chessSchedule = chessSchedule_;
        chess = IERC20(votingEscrow_.token());
        controllerBallot = controllerBallot_;
        interestRateBallot = interestRateBallot_;
        swapRouter = swapRouter_;
        flashSwapRouter = flashSwapRouter_;
        bishopQuoteToken = bishopQuoteToken_;
    }

    function getData(
        PrimaryMarketRouter[] calldata primaryMarketRouters,
        ShareStaking[] calldata shareStakings,
        FeeDistributor[] calldata feeDistributors,
        address[] calldata externalSwaps,
        address account
    ) public returns (Data memory data) {
        data.blockNumber = block.number;
        data.blockTimestamp = block.timestamp;

        data.funds = new FundAllData[](primaryMarketRouters.length);
        for (uint256 i = 0; i < primaryMarketRouters.length; i++) {
            data.funds[i] = getFundAllData(primaryMarketRouters[i], shareStakings[i], account);
        }

        data.governance = getGovernanceData(account);

        data.feeDistributors = new FeeDistributorData[](feeDistributors.length);
        for (uint256 i = 0; i < feeDistributors.length; i++) {
            data.feeDistributors[i] = getFeeDistributorData(feeDistributors[i], account);
        }

        data.externalSwaps = new ExternalSwapData[](externalSwaps.length / 3);
        for (uint256 i = 0; i < externalSwaps.length / 3; i++) {
            data.externalSwaps[i] = getExternalSwapData(
                IUniswapV2Router01(externalSwaps[i * 3]),
                externalSwaps[i * 3 + 1],
                externalSwaps[i * 3 + 2]
            );
        }
    }

    function getFundAllData(
        PrimaryMarketRouter primaryMarketRouter,
        ShareStaking shareStaking,
        address account
    ) public returns (FundAllData memory data) {
        FundV3 fund = FundV3(address(primaryMarketRouter.fund()));
        data.fund = getFundData(fund);

        PrimaryMarketV3 primaryMarket =
            PrimaryMarketV3(payable(address(primaryMarketRouter.primaryMarket())));
        data.primaryMarket = getPrimaryMarketData(primaryMarket);

        data.shareStaking = getShareStakingData(shareStaking, data.fund.splitRatio, account);

        StableSwap bishopStableSwap =
            StableSwap(
                payable(
                    address(
                        swapRouter.getSwap(fund.tokenShare(TRANCHE_B), address(bishopQuoteToken))
                    )
                )
            );
        data.bishopStableSwap = getStableSwapData(bishopStableSwap, account);

        IERC20 underlyingToken = IERC20(fund.tokenUnderlying());
        StableSwap queenStableSwap =
            StableSwap(
                payable(
                    address(
                        swapRouter.getSwap(fund.tokenShare(TRANCHE_Q), address(underlyingToken))
                    )
                )
            );
        if (address(queenStableSwap) != address(0)) {
            data.queenStableSwap = getStableSwapData(queenStableSwap, account);
        }

        data.account.balance.underlying = underlyingToken.balanceOf(account);
        data.account.balance.quote = bishopQuoteToken.balanceOf(account);
        (
            data.account.balance.trancheQ,
            data.account.balance.trancheB,
            data.account.balance.trancheR
        ) = fund.trancheAllBalanceOf(account);

        data.account.allowance.primaryMarketRouterUnderlying = underlyingToken.allowance(
            account,
            address(primaryMarketRouter)
        );
        data.account.allowance.primaryMarketRouterTrancheQ = fund.trancheAllowance(
            TRANCHE_Q,
            account,
            address(primaryMarketRouter)
        );
        data.account.allowance.swapRouterUnderlying = underlyingToken.allowance(
            account,
            address(swapRouter)
        );
        data.account.allowance.swapRouterTrancheQ = fund.trancheAllowance(
            TRANCHE_Q,
            account,
            address(swapRouter)
        );
        data.account.allowance.swapRouterTrancheB = fund.trancheAllowance(
            TRANCHE_B,
            account,
            address(swapRouter)
        );
        data.account.allowance.swapRouterQuote = bishopQuoteToken.allowance(
            account,
            address(swapRouter)
        );
        data.account.allowance.flashSwapRouterTrancheR = fund.trancheAllowance(
            TRANCHE_R,
            account,
            flashSwapRouter
        );
        data.account.allowance.flashSwapRouterQuote = bishopQuoteToken.allowance(
            account,
            flashSwapRouter
        );
        data.account.allowance.shareStakingTrancheQ = fund.trancheAllowance(
            TRANCHE_Q,
            account,
            address(shareStaking)
        );
        data.account.allowance.shareStakingTrancheB = fund.trancheAllowance(
            TRANCHE_B,
            account,
            address(shareStaking)
        );
        data.account.allowance.shareStakingTrancheR = fund.trancheAllowance(
            TRANCHE_R,
            account,
            address(shareStaking)
        );
    }

    function getFundData(FundV3 fund) public view returns (FundData memory data) {
        ITwapOracleV2 twapOracle = fund.twapOracle();

        data.isFundActive = fund.isFundActive(block.timestamp);
        data.fundActivityStartTime = fund.fundActivityStartTime();
        data.activityDelayTimeAfterRebalance = fund.activityDelayTimeAfterRebalance();
        data.currentDay = fund.currentDay();
        data.dailyProtocolFeeRate = fund.dailyProtocolFeeRate();
        data.totalSupplyQ = fund.trancheTotalSupply(TRANCHE_Q);
        data.totalSupplyB = fund.trancheTotalSupply(TRANCHE_B);
        data.totalUnderlying = fund.getTotalUnderlying();
        data.strategyUnderlying = fund.getStrategyUnderlying();
        data.rebalanceSize = fund.getRebalanceSize();
        data.upperRebalanceThreshold = fund.upperRebalanceThreshold();
        data.lowerRebalanceThreshold = fund.lowerRebalanceThreshold();
        data.splitRatio = fund.splitRatio();
        data.latestUnderlyingPrice = getLatestPrice(twapOracle);
        if (data.splitRatio != 0) {
            (, data.navB, data.navR) = fund.extrapolateNav(data.latestUnderlyingPrice);
            data.currentInterestRate = fund.historicalInterestRate(data.currentDay - 1 days);
        }
        data.lastRebalance = fund.getRebalance(
            data.rebalanceSize == 0 ? 0 : data.rebalanceSize - 1
        );
    }

    function getLatestPrice(ITwapOracleV2 twapOracle) public view returns (uint256) {
        (bool success, bytes memory encodedPrice) =
            address(twapOracle).staticcall(abi.encodeWithSignature("getLatest()"));
        if (success) {
            return abi.decode(encodedPrice, (uint256));
        } else {
            uint256 lastEpoch = (block.timestamp / 30 minutes) * 30 minutes;
            for (uint256 i = 0; i < 48; i++) {
                // Search for the latest TWAP
                uint256 twap = twapOracle.getTwap(lastEpoch - i * 30 minutes);
                if (twap != 0) {
                    return twap;
                }
            }
        }
    }

    function getPrimaryMarketData(PrimaryMarketV3 primaryMarket)
        public
        view
        returns (PrimaryMarketData memory data)
    {
        data.fundCap = primaryMarket.fundCap();
        data.redemptionFeeRate = primaryMarket.redemptionFeeRate();
        data.mergeFeeRate = primaryMarket.mergeFeeRate();
        data.redemptionQueueHead = primaryMarket.getNewRedemptionQueueHead();
    }

    function getShareStakingData(
        ShareStaking shareStaking,
        uint256 splitRatio,
        address account
    ) public returns (ShareStakingData memory data) {
        data.account.claimableChess = shareStaking.claimableRewards(account);
        data.totalSupplyQ = shareStaking.totalSupply(TRANCHE_Q);
        data.totalSupplyB = shareStaking.totalSupply(TRANCHE_B);
        data.totalSupplyR = shareStaking.totalSupply(TRANCHE_R);
        data.weightedSupply = shareStaking.weightedBalance(
            data.totalSupplyQ,
            data.totalSupplyB,
            data.totalSupplyR,
            splitRatio
        );
        data.workingSupply = shareStaking.workingSupply();
        data.chessRate = shareStaking.getRate();
        data.account.balanceQ = shareStaking.trancheBalanceOf(TRANCHE_Q, account);
        data.account.balanceB = shareStaking.trancheBalanceOf(TRANCHE_B, account);
        data.account.balanceR = shareStaking.trancheBalanceOf(TRANCHE_R, account);
        data.account.weightedBalance = shareStaking.weightedBalance(
            data.account.balanceQ,
            data.account.balanceB,
            data.account.balanceR,
            splitRatio
        );
        data.account.workingBalance = shareStaking.workingBalanceOf(account);
    }

    function getStableSwapData(StableSwap stableSwap, address account)
        public
        returns (StableSwapData memory data)
    {
        LiquidityGauge lp = LiquidityGauge(stableSwap.lpToken());
        SwapBonus swapBonus = SwapBonus(lp.swapBonus());

        // Trigger checkpoint
        (
            data.account.claimableChess,
            data.account.claimableBonus,
            data.account.claimableQ,
            data.account.claimableB,
            data.account.claimableR,
            data.account.claimableQuote
        ) = lp.claimableRewards(account);
        data.account.lpBalance = lp.balanceOf(account);
        data.account.workingBalance = lp.workingBalanceOf(account);

        data.feeRate = stableSwap.feeRate();
        data.adminFeeRate = stableSwap.adminFeeRate();
        data.ampl = stableSwap.getAmpl();
        data.lpTotalSupply = lp.totalSupply();
        if (data.lpTotalSupply != 0) {
            // Handle rebalance
            stableSwap.sync();
        }
        data.lpWorkingSupply = lp.workingSupply();
        (data.baseBalance, data.quoteBalance) = stableSwap.allBalances();
        data.chessRate = lp.getRate();
        uint256 lpVersion = lp.latestVersion();
        (
            data.lastDistributionQ,
            data.lastDistributionB,
            data.lastDistributionR,
            data.lastDistributionQuote
        ) = lp.distributions(lpVersion);
        data.lastDistributionTotalSupply = lp.distributionTotalSupplies(lpVersion);
        data.bonusToken = swapBonus.bonusToken();
        data.bonusRate = block.timestamp < swapBonus.endTimestamp() ? swapBonus.ratePerSecond() : 0;

        (bool success, bytes memory encodedOraclePrice) =
            address(stableSwap).call(abi.encodeWithSignature("getOraclePrice()"));
        if (success) {
            data.currentD = stableSwap.getCurrentD();
            data.currentPrice = stableSwap.getCurrentPrice();
            data.oraclePrice = abi.decode(encodedOraclePrice, (uint256));
        }
    }

    function getGovernanceData(address account) public view returns (GovernanceData memory data) {
        uint256 blockCurrentWeek = _endOfWeek(block.timestamp);

        data.chessRate = chessSchedule.getRate(block.timestamp);
        data.nextWeekChessRate = chessSchedule.getRate(block.timestamp + 1 weeks);

        data.votingEscrow.totalLocked = votingEscrow.totalLocked();
        data.votingEscrow.totalSupply = votingEscrow.totalSupply();
        data.votingEscrow.tradingWeekTotalSupply = votingEscrow.totalSupplyAtTimestamp(
            blockCurrentWeek
        );
        data.votingEscrow.account = votingEscrow.getLockedBalance(account);

        data.interestRateBallot.tradingWeekTotalSupply = interestRateBallot.totalSupplyAtTimestamp(
            blockCurrentWeek
        );
        data.interestRateBallot.account = interestRateBallot.getReceipt(account);

        data.controllerBallot = getControllerBallotData(account);

        data.account.balance.nativeCurrency = account.balance;
        data.account.balance.chess = chess.balanceOf(account);
        data.account.allowance.votingEscrowChess = chess.allowance(account, address(votingEscrow));
    }

    function getControllerBallotData(address account)
        public
        view
        returns (ControllerBallotData memory data)
    {
        data.pools = controllerBallot.getPools();
        // TODO handle disabled pools
        data.currentSums = new uint256[](data.pools.length);
        (data.account.amount, data.account.unlockTime) = controllerBallot.userLockedBalances(
            account
        );
        data.account.weights = new uint256[](data.pools.length);
        for (uint256 i = 0; i < data.pools.length; i++) {
            address pool = data.pools[i];
            data.currentSums[i] = controllerBallot.sumAtTimestamp(pool, block.timestamp);
            data.account.weights[i] = controllerBallot.userWeights(account, pool);
        }
    }

    function getFeeDistributorData(FeeDistributor feeDistributor, address account)
        public
        returns (FeeDistributorData memory data)
    {
        data.account.claimableRewards = feeDistributor.userCheckpoint(account);
        data.account.currentBalance = feeDistributor.userLastBalances(account);
        (data.account.amount, data.account.unlockTime) = feeDistributor.userLockedBalances(account);
        uint256 blockCurrentWeek = _endOfWeek(block.timestamp);
        data.currentRewards = feeDistributor.rewardsPerWeek(blockCurrentWeek - 1 weeks);
        data.currentSupply = feeDistributor.veSupplyPerWeek(blockCurrentWeek - 1 weeks);
        data.tradingWeekTotalSupply = feeDistributor.totalSupplyAtTimestamp(blockCurrentWeek);
        data.adminFeeRate = feeDistributor.adminFeeRate();
    }

    function getExternalSwapData(
        IUniswapV2Router01 router,
        address token0,
        address token1
    ) public view returns (ExternalSwapData memory data) {
        IUniswapV2Pair pair =
            IUniswapV2Pair(IUniswapV2Factory(router.factory()).getPair(token0, token1));
        data.symbol0 = ERC20(token0).symbol();
        data.symbol1 = ERC20(token1).symbol();
        if (pair.token0() == token0) {
            (data.reserve0, data.reserve1, ) = pair.getReserves();
        } else {
            (data.reserve1, data.reserve0, ) = pair.getReserves();
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../utils/SafeDecimalMath.sol";

import "../interfaces/IPrimaryMarketV3.sol";
import "../interfaces/ITrancheIndexV2.sol";
import "../interfaces/IWrappedERC20.sol";

contract PrimaryMarketV3 is IPrimaryMarketV3, ReentrancyGuard, ITrancheIndexV2, Ownable {
    event Created(address indexed account, uint256 underlying, uint256 outQ);
    event Redeemed(address indexed account, uint256 inQ, uint256 underlying, uint256 fee);
    event Split(address indexed account, uint256 inQ, uint256 outB, uint256 outR);
    event Merged(
        address indexed account,
        uint256 outQ,
        uint256 inB,
        uint256 inR,
        uint256 feeUnderlying
    );
    event RedemptionQueued(address indexed account, uint256 index, uint256 underlying);
    event RedemptionPopped(uint256 count, uint256 newHead, uint256 requiredUnderlying);
    event RedemptionClaimed(address indexed account, uint256 index, uint256 underlying);
    event FundCapUpdated(uint256 newCap);
    event RedemptionFeeRateUpdated(uint256 newRedemptionFeeRate);
    event MergeFeeRateUpdated(uint256 newMergeFeeRate);

    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    struct QueuedRedemption {
        address account;
        uint256 underlying;
        uint256 previousPrefixSum;
    }

    uint256 private constant MAX_REDEMPTION_FEE_RATE = 0.01e18;
    uint256 private constant MAX_MERGE_FEE_RATE = 0.01e18;

    IFundV3 public immutable override fund;
    IERC20 private immutable _tokenUnderlying;

    uint256 public redemptionFeeRate;
    uint256 public mergeFeeRate;

    /// @notice The upper limit of underlying that the fund can hold. This contract rejects
    ///         creations that may break this limit.
    /// @dev This limit can be bypassed if the fund has multiple primary markets.
    ///
    ///      Set it to uint(-1) to skip the check and save gas.
    uint256 public fundCap;

    /// @notice Queue of redemptions that cannot be claimed yet. Key is a sequential index
    ///         starting from zero. Value is a tuple of user address, redeemed underlying and
    ///         prefix sum before this entry.
    mapping(uint256 => QueuedRedemption) public queuedRedemptions;

    /// @notice Total underlying tokens of claimable queued redemptions.
    uint256 public claimableUnderlying;

    /// @notice Index of the redemption queue head. All redemptions with index smaller than
    ///         this value can be claimed now.
    uint256 public redemptionQueueHead;

    /// @notice Index of the redemption following the last entry of the queue. The next queued
    ///         redemption will be written at this index.
    uint256 public redemptionQueueTail;

    constructor(
        address fund_,
        uint256 redemptionFeeRate_,
        uint256 mergeFeeRate_,
        uint256 fundCap_
    ) public Ownable() {
        fund = IFundV3(fund_);
        _tokenUnderlying = IERC20(IFundV3(fund_).tokenUnderlying());
        _updateRedemptionFeeRate(redemptionFeeRate_);
        _updateMergeFeeRate(mergeFeeRate_);
        _updateFundCap(fundCap_);
    }

    /// @notice Calculate the result of a creation.
    /// @param underlying Underlying amount spent for the creation
    /// @return outQ Created QUEEN amount
    function getCreation(uint256 underlying) public view override returns (uint256 outQ) {
        uint256 fundUnderlying = fund.getTotalUnderlying();
        uint256 fundEquivalentTotalQ = fund.getEquivalentTotalQ();
        require(fundUnderlying.add(underlying) <= fundCap, "Exceed fund cap");
        if (fundEquivalentTotalQ == 0) {
            outQ = underlying.mul(fund.underlyingDecimalMultiplier());
            uint256 splitRatio = fund.splitRatio();
            require(splitRatio != 0, "Fund is not initialized");
            uint256 settledDay = fund.currentDay() - 1 days;
            uint256 underlyingPrice = fund.twapOracle().getTwap(settledDay);
            (uint256 navB, uint256 navR) = fund.historicalNavs(settledDay);
            outQ = outQ.mul(underlyingPrice).div(splitRatio).divideDecimal(navB.add(navR));
        } else {
            require(
                fundUnderlying != 0,
                "Cannot create QUEEN for fund with shares but no underlying"
            );
            outQ = underlying.mul(fundEquivalentTotalQ).div(fundUnderlying);
        }
    }

    /// @notice Calculate the amount of underlying tokens to create at least the given QUEEN amount.
    ///         This only works with non-empty fund for simplicity.
    /// @param minOutQ Minimum received QUEEN amount
    /// @return underlying Underlying amount that should be used for creation
    function getCreationForQ(uint256 minOutQ) external view override returns (uint256 underlying) {
        // Assume:
        //   minOutQ * fundUnderlying = a * fundEquivalentTotalQ - b
        // where a and b are integers and 0 <= b < fundEquivalentTotalQ
        // Then
        //   underlying = a
        //   getCreation(underlying)
        //     = floor(a * fundEquivalentTotalQ / fundUnderlying)
        //    >= floor((a * fundEquivalentTotalQ - b) / fundUnderlying)
        //     = minOutQ
        //   getCreation(underlying - 1)
        //     = floor((a * fundEquivalentTotalQ - fundEquivalentTotalQ) / fundUnderlying)
        //     < (a * fundEquivalentTotalQ - b) / fundUnderlying
        //     = minOutQ
        uint256 fundUnderlying = fund.getTotalUnderlying();
        uint256 fundEquivalentTotalQ = fund.getEquivalentTotalQ();
        require(fundEquivalentTotalQ > 0, "Cannot calculate creation for empty fund");
        return minOutQ.mul(fundUnderlying).add(fundEquivalentTotalQ - 1).div(fundEquivalentTotalQ);
    }

    function _getRedemptionBeforeFee(uint256 inQ) private view returns (uint256 underlying) {
        uint256 fundUnderlying = fund.getTotalUnderlying();
        uint256 fundEquivalentTotalQ = fund.getEquivalentTotalQ();
        underlying = inQ.mul(fundUnderlying).div(fundEquivalentTotalQ);
    }

    /// @notice Calculate the result of a redemption.
    /// @param inQ QUEEN amount spent for the redemption
    /// @return underlying Redeemed underlying amount
    /// @return fee Underlying amount charged as redemption fee
    function getRedemption(uint256 inQ)
        public
        view
        override
        returns (uint256 underlying, uint256 fee)
    {
        underlying = _getRedemptionBeforeFee(inQ);
        fee = underlying.multiplyDecimal(redemptionFeeRate);
        underlying = underlying.sub(fee);
    }

    /// @notice Calculate the amount of QUEEN that can be redeemed for at least the given amount
    ///         of underlying tokens.
    /// @dev The return value may not be the minimum solution due to rounding errors.
    /// @param minUnderlying Minimum received underlying amount
    /// @return inQ QUEEN amount that should be redeemed
    function getRedemptionForUnderlying(uint256 minUnderlying)
        external
        view
        override
        returns (uint256 inQ)
    {
        // Assume:
        //   minUnderlying * 1e18 = a * (1e18 - redemptionFeeRate) + b
        //   a * fundEquivalentTotalQ = c * fundUnderlying - d
        // where
        //   a, b, c, d are integers
        //   0 <= b < 1e18 - redemptionFeeRate
        //   0 <= d < fundUnderlying
        // Then
        //   underlyingBeforeFee = a
        //   inQ = c
        //   getRedemption(inQ).underlying
        //     = floor(c * fundUnderlying / fundEquivalentTotalQ) -
        //       - floor(floor(c * fundUnderlying / fundEquivalentTotalQ) * redemptionFeeRate / 1e18)
        //     = ceil(floor(c * fundUnderlying / fundEquivalentTotalQ) * (1e18 - redemptionFeeRate) / 1e18)
        //    >= ceil(floor((c * fundUnderlying - d) / fundEquivalentTotalQ) * (1e18 - redemptionFeeRate) / 1e18)
        //     = ceil(a * (1e18 - redemptionFeeRate) / 1e18)
        //     = (a * (1e18 - redemptionFeeRate) + b) / 1e18        // because b < 1e18
        //     = minUnderlying
        uint256 fundUnderlying = fund.getTotalUnderlying();
        uint256 fundEquivalentTotalQ = fund.getEquivalentTotalQ();
        uint256 underlyingBeforeFee = minUnderlying.divideDecimal(1e18 - redemptionFeeRate);
        return
            underlyingBeforeFee.mul(fundEquivalentTotalQ).add(fundUnderlying - 1).div(
                fundUnderlying
            );
    }

    /// @notice Calculate the result of a split.
    /// @param inQ QUEEN amount to be split
    /// @return outB Received BISHOP amount, which is also received ROOK amount
    function getSplit(uint256 inQ) public view override returns (uint256 outB) {
        return inQ.multiplyDecimal(fund.splitRatio());
    }

    /// @notice Calculate the amount of QUEEN that can be split into at least the given amount of
    ///         BISHOP and ROOK.
    /// @param minOutB Received BISHOP amount, which is also received ROOK amount
    /// @return inQ QUEEN amount that should be split
    function getSplitForB(uint256 minOutB) external view override returns (uint256 inQ) {
        uint256 splitRatio = fund.splitRatio();
        return minOutB.mul(1e18).add(splitRatio.sub(1)).div(splitRatio);
    }

    /// @notice Calculate the result of a merge.
    /// @param inB Spent BISHOP amount, which is also spent ROOK amount
    /// @return outQ Received QUEEN amount
    /// @return feeQ QUEEN amount charged as merge fee
    function getMerge(uint256 inB) public view override returns (uint256 outQ, uint256 feeQ) {
        uint256 outQBeforeFee = inB.divideDecimal(fund.splitRatio());
        feeQ = outQBeforeFee.multiplyDecimal(mergeFeeRate);
        outQ = outQBeforeFee.sub(feeQ);
    }

    /// @notice Calculate the amount of BISHOP and ROOK that can be merged into at least
    ///      the given amount of QUEEN.
    /// @dev The return value may not be the minimum solution due to rounding errors.
    /// @param minOutQ Minimum received QUEEN amount
    /// @return inB BISHOP amount that should be merged, which is also spent ROOK amount
    function getMergeForQ(uint256 minOutQ) external view override returns (uint256 inB) {
        // Assume:
        //   minOutQ * 1e18 = a * (1e18 - mergeFeeRate) + b
        //   c = ceil(a * splitRatio / 1e18)
        // where a and b are integers and 0 <= b < 1e18 - mergeFeeRate
        // Then
        //   outQBeforeFee = a
        //   inB = c
        //   getMerge(inB).outQ
        //     = c * 1e18 / splitRatio - floor(c * 1e18 / splitRatio * mergeFeeRate / 1e18)
        //     = ceil(c * 1e18 / splitRatio * (1e18 - mergeFeeRate) / 1e18)
        //    >= ceil(a * (1e18 - mergeFeeRate) / 1e18)
        //     = (a * (1e18 - mergeFeeRate) + b) / 1e18         // because b < 1e18
        //     = minOutQ
        uint256 outQBeforeFee = minOutQ.divideDecimal(1e18 - mergeFeeRate);
        inB = outQBeforeFee.mul(fund.splitRatio()).add(1e18 - 1).div(1e18);
    }

    /// @notice Return index of the first queued redemption that cannot be claimed now.
    ///         Users can use this function to determine which indices can be passed to
    ///         `claimRedemptions()`.
    /// @return Index of the first redemption that cannot be claimed now
    function getNewRedemptionQueueHead() external view returns (uint256) {
        uint256 available = _tokenUnderlying.balanceOf(address(fund));
        uint256 l = redemptionQueueHead;
        uint256 r = redemptionQueueTail;
        uint256 startPrefixSum = queuedRedemptions[l].previousPrefixSum;
        // overflow is desired
        if (queuedRedemptions[r].previousPrefixSum - startPrefixSum <= available) {
            return r;
        }
        // Iteration count is bounded by log2(tail - head), which is at most 256.
        while (l + 1 < r) {
            uint256 m = (l + r) / 2;
            if (queuedRedemptions[m].previousPrefixSum - startPrefixSum <= available) {
                l = m;
            } else {
                r = m;
            }
        }
        return l;
    }

    /// @notice Search in the redemption queue.
    /// @param account Owner of the redemptions, or zero address to return all redemptions
    /// @param startIndex Redemption index where the search starts, or zero to start from the head
    /// @param maxIterationCount Maximum number of redemptions to be scanned, or zero for no limit
    /// @return indices Indices of found redemptions
    /// @return underlying Total underlying of found redemptions
    function getQueuedRedemptions(
        address account,
        uint256 startIndex,
        uint256 maxIterationCount
    ) external view returns (uint256[] memory indices, uint256 underlying) {
        uint256 head = redemptionQueueHead;
        uint256 tail = redemptionQueueTail;
        if (startIndex == 0) {
            startIndex = head;
        } else {
            require(startIndex >= head && startIndex <= tail, "startIndex out of bound");
        }
        uint256 endIndex = tail;
        if (maxIterationCount != 0 && tail - startIndex > maxIterationCount) {
            endIndex = startIndex + maxIterationCount;
        }
        indices = new uint256[](endIndex - startIndex);
        uint256 count = 0;
        for (uint256 i = startIndex; i < endIndex; i++) {
            if (account == address(0) || queuedRedemptions[i].account == account) {
                indices[count] = i;
                underlying += queuedRedemptions[i].underlying;
                count++;
            }
        }
        if (count != endIndex - startIndex) {
            // Shrink the array
            assembly {
                mstore(indices, count)
            }
        }
    }

    /// @notice Return whether the fund can change its primary market to another contract.
    function canBeRemovedFromFund() external view override returns (bool) {
        return redemptionQueueHead == redemptionQueueTail;
    }

    /// @notice Create QUEEN using underlying tokens. This function should be called by
    ///         a smart contract, which transfers underlying tokens to this contract
    ///         in the same transaction.
    /// @param recipient Address that will receive created QUEEN
    /// @param minOutQ Minimum QUEEN amount to be received
    /// @param version The latest rebalance version
    /// @return outQ Received QUEEN amount
    function create(
        address recipient,
        uint256 minOutQ,
        uint256 version
    ) external override nonReentrant returns (uint256 outQ) {
        uint256 underlying = _tokenUnderlying.balanceOf(address(this)).sub(claimableUnderlying);
        outQ = getCreation(underlying);
        require(outQ >= minOutQ && outQ > 0, "Min QUEEN created");
        fund.primaryMarketMint(TRANCHE_Q, recipient, outQ, version);
        _tokenUnderlying.safeTransfer(address(fund), underlying);
        emit Created(recipient, underlying, outQ);
    }

    /// @notice Redeem QUEEN to get underlying tokens back. Revert if there are still some
    ///         queued redemptions that cannot be claimed now.
    /// @param recipient Address that will receive redeemed underlying tokens
    /// @param inQ Spent QUEEN amount
    /// @param minUnderlying Minimum amount of underlying tokens to be received
    /// @param version The latest rebalance version
    /// @return underlying Received underlying amount
    function redeem(
        address recipient,
        uint256 inQ,
        uint256 minUnderlying,
        uint256 version
    ) external override nonReentrant returns (uint256 underlying) {
        underlying = _redeem(recipient, inQ, minUnderlying, version);
    }

    /// @notice Redeem QUEEN to get native currency back. The underlying must be wrapped token
    ///         of the native currency. Revert if there are still some queued redemptions that
    ///         cannot be claimed now.
    /// @param recipient Address that will receive redeemed underlying tokens
    /// @param inQ Spent QUEEN amount
    /// @param minUnderlying Minimum amount of underlying tokens to be received
    /// @param version The latest rebalance version
    /// @return underlying Received underlying amount
    function redeemAndUnwrap(
        address recipient,
        uint256 inQ,
        uint256 minUnderlying,
        uint256 version
    ) external override nonReentrant returns (uint256 underlying) {
        underlying = _redeem(address(this), inQ, minUnderlying, version);
        IWrappedERC20(address(_tokenUnderlying)).withdraw(underlying);
        (bool success, ) = recipient.call{value: underlying}("");
        require(success, "Transfer failed");
    }

    function _redeem(
        address recipient,
        uint256 inQ,
        uint256 minUnderlying,
        uint256 version
    ) private returns (uint256 underlying) {
        uint256 fee;
        (underlying, fee) = getRedemption(inQ);
        fund.primaryMarketBurn(TRANCHE_Q, msg.sender, inQ, version);
        _popRedemptionQueue(0);
        require(underlying >= minUnderlying && underlying > 0, "Min underlying redeemed");
        // Redundant check for user-friendly revert message.
        require(
            underlying <= _tokenUnderlying.balanceOf(address(fund)),
            "Not enough underlying in fund"
        );
        fund.primaryMarketTransferUnderlying(recipient, underlying, fee);
        emit Redeemed(recipient, inQ, underlying, fee);
    }

    /// @notice Redeem QUEEN and wait in the redemption queue. Redeemed underlying tokens will
    ///         be claimable when the fund has enough balance to pay this redemption and all
    ///         previous ones in the queue.
    /// @param recipient Address that will receive redeemed underlying tokens
    /// @param inQ Spent QUEEN amount
    /// @param minUnderlying Minimum amount of underlying tokens to be received
    /// @param version The latest rebalance version
    /// @return underlying Received underlying amount
    /// @return index Index of the queued redemption
    function queueRedemption(
        address recipient,
        uint256 inQ,
        uint256 minUnderlying,
        uint256 version
    ) external override nonReentrant returns (uint256 underlying, uint256 index) {
        uint256 fee;
        (underlying, fee) = getRedemption(inQ);
        fund.primaryMarketBurn(TRANCHE_Q, msg.sender, inQ, version);
        require(underlying >= minUnderlying && underlying > 0, "Min underlying redeemed");
        index = redemptionQueueTail;
        QueuedRedemption storage newRedemption = queuedRedemptions[index];
        newRedemption.account = recipient;
        newRedemption.underlying = underlying;
        // overflow is desired
        queuedRedemptions[index + 1].previousPrefixSum =
            newRedemption.previousPrefixSum +
            underlying;
        redemptionQueueTail = index + 1;
        fund.primaryMarketAddDebt(underlying, fee);
        emit Redeemed(recipient, inQ, underlying, fee);
        emit RedemptionQueued(recipient, index, underlying);
    }

    /// @notice Remove a given number of redemptions from the front of the redemption queue and
    ///         fetch underlying tokens of these redemptions from the fund. Revert if the fund
    ///         cannot pay these redemptions now.
    /// @param count The number of redemptions to be removed, or zero to completely empty the queue
    function popRedemptionQueue(uint256 count) external nonReentrant {
        _popRedemptionQueue(count);
    }

    function _popRedemptionQueue(uint256 count) private {
        uint256 oldHead = redemptionQueueHead;
        uint256 oldTail = redemptionQueueTail;
        uint256 newHead;
        if (count == 0) {
            if (oldHead == oldTail) {
                return;
            }
            newHead = oldTail;
        } else {
            newHead = oldHead.add(count);
            require(newHead <= oldTail, "Redemption queue out of bound");
        }
        // overflow is desired
        uint256 requiredUnderlying =
            queuedRedemptions[newHead].previousPrefixSum -
                queuedRedemptions[oldHead].previousPrefixSum;
        // Redundant check for user-friendly revert message.
        require(
            requiredUnderlying <= _tokenUnderlying.balanceOf(address(fund)),
            "Not enough underlying in fund"
        );
        claimableUnderlying = claimableUnderlying.add(requiredUnderlying);
        fund.primaryMarketPayDebt(requiredUnderlying);
        redemptionQueueHead = newHead;
        emit RedemptionPopped(newHead - oldHead, newHead, requiredUnderlying);
    }

    /// @notice Claim underlying tokens of queued redemptions. All these redemptions must
    ///         belong to the same account.
    /// @param account Recipient of the redemptions
    /// @param indices Indices of the redemptions in the queue, which must be in increasing order
    /// @return underlying Total claimed underlying amount
    function claimRedemptions(address account, uint256[] calldata indices)
        external
        override
        nonReentrant
        returns (uint256 underlying)
    {
        underlying = _claimRedemptions(account, indices);
        _tokenUnderlying.safeTransfer(account, underlying);
    }

    /// @notice Claim native currency of queued redemptions. The underlying must be wrapped token
    ///         of the native currency. All these redemptions must belong to the same account.
    /// @param account Recipient of the redemptions
    /// @param indices Indices of the redemptions in the queue, which must be in increasing order
    /// @return underlying Total claimed underlying amount
    function claimRedemptionsAndUnwrap(address account, uint256[] calldata indices)
        external
        override
        nonReentrant
        returns (uint256 underlying)
    {
        underlying = _claimRedemptions(account, indices);
        IWrappedERC20(address(_tokenUnderlying)).withdraw(underlying);
        (bool success, ) = account.call{value: underlying}("");
        require(success, "Transfer failed");
    }

    function _claimRedemptions(address account, uint256[] calldata indices)
        private
        returns (uint256 underlying)
    {
        uint256 count = indices.length;
        if (count == 0) {
            return 0;
        }
        uint256 head = redemptionQueueHead;
        if (indices[count - 1] >= head) {
            _popRedemptionQueue(indices[count - 1] - head + 1);
        }
        for (uint256 i = 0; i < count; i++) {
            require(i == 0 || indices[i] > indices[i - 1], "Indices out of order");
            QueuedRedemption storage redemption = queuedRedemptions[indices[i]];
            uint256 redemptionUnderlying = redemption.underlying;
            require(
                redemption.account == account && redemptionUnderlying != 0,
                "Invalid redemption index"
            );
            underlying = underlying.add(redemptionUnderlying);
            emit RedemptionClaimed(account, indices[i], redemptionUnderlying);
            delete queuedRedemptions[indices[i]];
        }
        claimableUnderlying = claimableUnderlying.sub(underlying);
    }

    function split(
        address recipient,
        uint256 inQ,
        uint256 version
    ) external override returns (uint256 outB) {
        outB = getSplit(inQ);
        fund.primaryMarketBurn(TRANCHE_Q, msg.sender, inQ, version);
        fund.primaryMarketMint(TRANCHE_B, recipient, outB, version);
        fund.primaryMarketMint(TRANCHE_R, recipient, outB, version);
        emit Split(recipient, inQ, outB, outB);
    }

    function merge(
        address recipient,
        uint256 inB,
        uint256 version
    ) external override returns (uint256 outQ) {
        uint256 feeQ;
        (outQ, feeQ) = getMerge(inB);
        uint256 feeUnderlying = _getRedemptionBeforeFee(feeQ);
        fund.primaryMarketBurn(TRANCHE_B, msg.sender, inB, version);
        fund.primaryMarketBurn(TRANCHE_R, msg.sender, inB, version);
        fund.primaryMarketMint(TRANCHE_Q, recipient, outQ, version);
        fund.primaryMarketAddDebt(0, feeUnderlying);
        emit Merged(recipient, outQ, inB, inB, feeUnderlying);
    }

    /// @dev Nothing to do for daily fund settlement.
    function settle(uint256 day) external override onlyFund {}

    function _updateFundCap(uint256 newCap) private {
        fundCap = newCap;
        emit FundCapUpdated(newCap);
    }

    function updateFundCap(uint256 newCap) external onlyOwner {
        _updateFundCap(newCap);
    }

    function _updateRedemptionFeeRate(uint256 newRedemptionFeeRate) private {
        require(newRedemptionFeeRate <= MAX_REDEMPTION_FEE_RATE, "Exceed max redemption fee rate");
        redemptionFeeRate = newRedemptionFeeRate;
        emit RedemptionFeeRateUpdated(newRedemptionFeeRate);
    }

    function updateRedemptionFeeRate(uint256 newRedemptionFeeRate) external onlyOwner {
        _updateRedemptionFeeRate(newRedemptionFeeRate);
    }

    function _updateMergeFeeRate(uint256 newMergeFeeRate) private {
        require(newMergeFeeRate <= MAX_MERGE_FEE_RATE, "Exceed max merge fee rate");
        mergeFeeRate = newMergeFeeRate;
        emit MergeFeeRateUpdated(newMergeFeeRate);
    }

    function updateMergeFeeRate(uint256 newMergeFeeRate) external onlyOwner {
        _updateMergeFeeRate(newMergeFeeRate);
    }

    /// @notice Receive unwrapped transfer from the wrapped token.
    receive() external payable {}

    modifier onlyFund() {
        require(msg.sender == address(fund), "Only fund");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "../fund/ShareStaking.sol";

import "../interfaces/IPrimaryMarketRouter.sol";
import "../interfaces/IPrimaryMarketV3.sol";
import "../interfaces/ISwapRouter.sol";
import "../interfaces/IStableSwap.sol";
import "../interfaces/IWrappedERC20.sol";

contract PrimaryMarketRouter is IPrimaryMarketRouter, ITrancheIndexV2 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IPrimaryMarketV3 public immutable primaryMarket;
    IFundV3 public immutable fund;
    IERC20 private immutable _tokenUnderlying;
    address private immutable _tokenB;

    constructor(address pm) public {
        primaryMarket = IPrimaryMarketV3(pm);
        IFundV3 fund_ = IPrimaryMarketV3(pm).fund();
        fund = fund_;
        _tokenUnderlying = IERC20(fund_.tokenUnderlying());
        _tokenB = fund_.tokenB();
    }

    /// @dev Get redemption with StableSwap getQuoteOut interface.
    function getQuoteOut(uint256 baseIn) external view override returns (uint256 quoteOut) {
        (quoteOut, ) = primaryMarket.getRedemption(baseIn);
    }

    /// @dev Get creation for QUEEN with StableSwap getQuoteIn interface.
    function getQuoteIn(uint256 baseOut) external view override returns (uint256 quoteIn) {
        quoteIn = primaryMarket.getCreationForQ(baseOut);
    }

    /// @dev Get creation with StableSwap getBaseOut interface.
    function getBaseOut(uint256 quoteIn) external view override returns (uint256 baseOut) {
        baseOut = primaryMarket.getCreation(quoteIn);
    }

    /// @dev Get redemption for underlying with StableSwap getBaseIn interface.
    function getBaseIn(uint256 quoteOut) external view override returns (uint256 baseIn) {
        baseIn = primaryMarket.getRedemptionForUnderlying(quoteOut);
    }

    /// @dev Create QUEEN with StableSwap buy interface.
    ///      Underlying should have already been sent to this contract
    function buy(
        uint256 version,
        uint256 baseOut,
        address recipient,
        bytes calldata
    ) external override returns (uint256 realBaseOut) {
        uint256 routerQuoteBalance = IERC20(_tokenUnderlying).balanceOf(address(this));
        IERC20(_tokenUnderlying).safeTransfer(address(primaryMarket), routerQuoteBalance);
        realBaseOut = primaryMarket.create(recipient, baseOut, version);
    }

    /// @dev Redeem QUEEN with StableSwap sell interface.
    ///      QUEEN should have already been sent to this contract
    function sell(
        uint256 version,
        uint256 quoteOut,
        address recipient,
        bytes calldata
    ) external override returns (uint256 realQuoteOut) {
        uint256 routerBaseBalance = fund.trancheBalanceOf(TRANCHE_Q, address(this));
        realQuoteOut = primaryMarket.redeem(recipient, routerBaseBalance, quoteOut, version);
    }

    function create(
        address recipient,
        uint256 underlying,
        uint256 minOutQ,
        uint256 version
    ) public payable override returns (uint256 outQ) {
        if (msg.value > 0) {
            require(msg.value == underlying); // sanity check
            IWrappedERC20(address(_tokenUnderlying)).deposit{value: msg.value}();
            _tokenUnderlying.safeTransfer(address(primaryMarket), msg.value);
        } else {
            IERC20(_tokenUnderlying).safeTransferFrom(
                msg.sender,
                address(primaryMarket),
                underlying
            );
        }

        outQ = primaryMarket.create(recipient, minOutQ, version);
    }

    function createAndStake(
        uint256 underlying,
        uint256 minOutQ,
        address staking,
        uint256 version
    ) external payable override {
        // Create QUEEN
        uint256 outQ = create(staking, underlying, minOutQ, version);
        // Stake QUEEN
        ShareStaking(staking).deposit(TRANCHE_Q, outQ, msg.sender, version);
    }

    function createSplitAndStake(
        uint256 underlying,
        uint256 minOutQ,
        address router,
        address quoteAddress,
        uint256 minLpOut,
        address staking,
        uint256 version
    ) external payable override {
        // Create QUEEN
        uint256 outQ = create(address(this), underlying, minOutQ, version);
        _splitAndStake(outQ, router, quoteAddress, minLpOut, staking, version);
    }

    function splitAndStake(
        uint256 inQ,
        address router,
        address quoteAddress,
        uint256 minLpOut,
        address staking,
        uint256 version
    ) external override {
        fund.trancheTransferFrom(TRANCHE_Q, msg.sender, address(this), inQ, version);
        _splitAndStake(inQ, router, quoteAddress, minLpOut, staking, version);
    }

    function _splitAndStake(
        uint256 inQ,
        address router,
        address quoteAddress,
        uint256 minLpOut,
        address staking,
        uint256 version
    ) private {
        // Split QUEEN into BISHOP and ROOK
        uint256 outB = primaryMarket.split(address(this), inQ, version);
        // Add BISHOP to stable swap
        {
            IStableSwap swap = ISwapRouter(router).getSwap(_tokenB, quoteAddress);
            fund.trancheTransfer(TRANCHE_B, address(swap), outB, version);
            uint256 lpOut = swap.addLiquidity(version, msg.sender);
            require(lpOut >= minLpOut, "Insufficient output");
        }

        if (staking == address(0)) {
            fund.trancheTransfer(TRANCHE_R, msg.sender, outB, version);
        } else {
            // Stake rook
            fund.trancheTransfer(TRANCHE_R, staking, outB, version);
            ShareStaking(staking).deposit(TRANCHE_R, outB, msg.sender, version);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../interfaces/IStableSwap.sol";
import "../interfaces/ILiquidityGauge.sol";
import "../interfaces/ITranchessSwapCallee.sol";
import "../interfaces/IWrappedERC20.sol";

import "../utils/SafeDecimalMath.sol";
import "../utils/AdvancedMath.sol";
import "../utils/ManagedPausable.sol";

abstract contract StableSwap is IStableSwap, Ownable, ReentrancyGuard, ManagedPausable {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event LiquidityAdded(
        address indexed sender,
        address indexed recipient,
        uint256 baseIn,
        uint256 quoteIn,
        uint256 lpOut,
        uint256 fee,
        uint256 adminFee,
        uint256 oraclePrice
    );
    event LiquidityRemoved(
        address indexed account,
        uint256 lpIn,
        uint256 baseOut,
        uint256 quotOut,
        uint256 fee,
        uint256 adminFee,
        uint256 oraclePrice
    );
    event Swap(
        address indexed sender,
        address indexed recipient,
        uint256 baseIn,
        uint256 quoteIn,
        uint256 baseOut,
        uint256 quoteOut,
        uint256 fee,
        uint256 adminFee,
        uint256 oraclePrice
    );
    event Sync(uint256 base, uint256 quote, uint256 oraclePrice);
    event AmplRampUpdated(uint256 start, uint256 end, uint256 startTimestamp, uint256 endTimestamp);
    event FeeCollectorUpdated(address newFeeCollector);
    event FeeRateUpdated(uint256 newFeeRate);
    event AdminFeeRateUpdated(uint256 newAdminFeeRate);

    uint256 private constant AMPL_MAX_VALUE = 1e6;
    uint256 private constant AMPL_RAMP_MIN_TIME = 86400;
    uint256 private constant AMPL_RAMP_MAX_CHANGE = 10;
    uint256 private constant MAX_FEE_RATE = 0.5e18;
    uint256 private constant MAX_ADMIN_FEE_RATE = 1e18;
    uint256 private constant MAX_ITERATION = 255;
    uint256 private constant MINIMUM_LIQUIDITY = 1e3;

    address public immutable lpToken;
    IFundV3 public immutable override fund;
    uint256 public immutable override baseTranche;
    address public immutable override quoteAddress;

    /// @dev A multipler that normalizes a quote asset balance to 18 decimal places.
    uint256 internal immutable _quoteDecimalMultiplier;

    uint256 public baseBalance;
    uint256 public quoteBalance;

    uint256 private _priceOverOracleIntegral;
    uint256 private _priceOverOracleTimestamp;

    uint256 public amplRampStart;
    uint256 public amplRampEnd;
    uint256 public amplRampStartTimestamp;
    uint256 public amplRampEndTimestamp;

    address public feeCollector;
    uint256 public feeRate;
    uint256 public adminFeeRate;
    uint256 public totalAdminFee;

    constructor(
        address lpToken_,
        address fund_,
        uint256 baseTranche_,
        address quoteAddress_,
        uint256 quoteDecimals_,
        uint256 ampl_,
        address feeCollector_,
        uint256 feeRate_,
        uint256 adminFeeRate_
    ) public {
        lpToken = lpToken_;
        fund = IFundV3(fund_);
        baseTranche = baseTranche_;
        quoteAddress = quoteAddress_;
        require(quoteDecimals_ <= 18, "Quote asset decimals larger than 18");
        _quoteDecimalMultiplier = 10**(18 - quoteDecimals_);

        require(ampl_ > 0 && ampl_ < AMPL_MAX_VALUE, "Invalid A");
        amplRampEnd = ampl_;
        emit AmplRampUpdated(ampl_, ampl_, 0, 0);

        _updateFeeCollector(feeCollector_);
        _updateFeeRate(feeRate_);
        _updateAdminFeeRate(adminFeeRate_);

        _initializeManagedPausable(msg.sender);
    }

    receive() external payable {}

    function baseAddress() external view override returns (address) {
        return fund.tokenShare(baseTranche);
    }

    function allBalances() external view override returns (uint256, uint256) {
        (uint256 base, uint256 quote, , , , , ) = _getRebalanceResult(fund.getRebalanceSize());
        return (base, quote);
    }

    function getAmpl() public view returns (uint256) {
        uint256 endTimestamp = amplRampEndTimestamp;
        if (block.timestamp < endTimestamp) {
            uint256 startTimestamp = amplRampStartTimestamp;
            uint256 start = amplRampStart;
            uint256 end = amplRampEnd;
            if (end > start) {
                return
                    start +
                    ((end - start) * (block.timestamp - startTimestamp)) /
                    (endTimestamp - startTimestamp);
            } else {
                return
                    start -
                    ((start - end) * (block.timestamp - startTimestamp)) /
                    (endTimestamp - startTimestamp);
            }
        } else {
            return amplRampEnd;
        }
    }

    function getCurrentD() external view override returns (uint256) {
        (uint256 base, uint256 quote, , , , , ) = _getRebalanceResult(fund.getRebalanceSize());
        return _getD(base, quote, getAmpl(), getOraclePrice());
    }

    function getCurrentPriceOverOracle() public view override returns (uint256) {
        (uint256 base, uint256 quote, , , , , ) = _getRebalanceResult(fund.getRebalanceSize());
        if (base == 0 || quote == 0) {
            return 1e18;
        }
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        uint256 d = _getD(base, quote, ampl, oraclePrice);
        return _getPriceOverOracle(base, quote, ampl, oraclePrice, d);
    }

    /// @notice Get the current swap price, i.e. negative slope at the current point on the curve.
    ///         The returned value is computed after both base and quote balances are normalized to
    ///         18 decimal places. If the quote token does not have 18 decimal places, the returned
    ///         value has a different order of magnitude than the ratio of quote amount to base
    ///         amount in a swap.
    function getCurrentPrice() external view override returns (uint256) {
        (uint256 base, uint256 quote, , , , , ) = _getRebalanceResult(fund.getRebalanceSize());
        uint256 oraclePrice = getOraclePrice();
        if (base == 0 || quote == 0) {
            return oraclePrice;
        }
        uint256 ampl = getAmpl();
        uint256 d = _getD(base, quote, ampl, oraclePrice);
        return _getPriceOverOracle(base, quote, ampl, oraclePrice, d).multiplyDecimal(oraclePrice);
    }

    function getPriceOverOracleIntegral() external view override returns (uint256) {
        return
            _priceOverOracleIntegral +
            getCurrentPriceOverOracle() *
            (block.timestamp - _priceOverOracleTimestamp);
    }

    function getQuoteOut(uint256 baseIn) external view override returns (uint256 quoteOut) {
        (uint256 oldBase, uint256 oldQuote, , , , , ) =
            _getRebalanceResult(fund.getRebalanceSize());
        uint256 newBase = oldBase.add(baseIn);
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        // Add 1 in case of rounding errors
        uint256 d = _getD(oldBase, oldQuote, ampl, oraclePrice) + 1;
        uint256 newQuote = _getQuote(ampl, newBase, oraclePrice, d) + 1;
        quoteOut = oldQuote.sub(newQuote);
        // Round down output after fee
        quoteOut = quoteOut.multiplyDecimal(1e18 - feeRate);
    }

    function getQuoteIn(uint256 baseOut) external view override returns (uint256 quoteIn) {
        (uint256 oldBase, uint256 oldQuote, , , , , ) =
            _getRebalanceResult(fund.getRebalanceSize());
        uint256 newBase = oldBase.sub(baseOut);
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        // Add 1 in case of rounding errors
        uint256 d = _getD(oldBase, oldQuote, ampl, oraclePrice) + 1;
        uint256 newQuote = _getQuote(ampl, newBase, oraclePrice, d) + 1;
        quoteIn = newQuote.sub(oldQuote);
        uint256 feeRate_ = feeRate;
        // Round up input before fee
        quoteIn = quoteIn.mul(1e18).add(1e18 - feeRate_ - 1) / (1e18 - feeRate_);
    }

    function getBaseOut(uint256 quoteIn) external view override returns (uint256 baseOut) {
        (uint256 oldBase, uint256 oldQuote, , , , , ) =
            _getRebalanceResult(fund.getRebalanceSize());
        // Round down input after fee
        uint256 quoteInAfterFee = quoteIn.multiplyDecimal(1e18 - feeRate);
        uint256 newQuote = oldQuote.add(quoteInAfterFee);
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        // Add 1 in case of rounding errors
        uint256 d = _getD(oldBase, oldQuote, ampl, oraclePrice) + 1;
        uint256 newBase = _getBase(ampl, newQuote, oraclePrice, d) + 1;
        baseOut = oldBase.sub(newBase);
    }

    function getBaseIn(uint256 quoteOut) external view override returns (uint256 baseIn) {
        (uint256 oldBase, uint256 oldQuote, , , , , ) =
            _getRebalanceResult(fund.getRebalanceSize());
        uint256 feeRate_ = feeRate;
        // Round up output before fee
        uint256 quoteOutBeforeFee = quoteOut.mul(1e18).add(1e18 - feeRate_ - 1) / (1e18 - feeRate_);
        uint256 newQuote = oldQuote.sub(quoteOutBeforeFee);
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        // Add 1 in case of rounding errors
        uint256 d = _getD(oldBase, oldQuote, ampl, oraclePrice) + 1;
        uint256 newBase = _getBase(ampl, newQuote, oraclePrice, d) + 1;
        baseIn = newBase.sub(oldBase);
    }

    function buy(
        uint256 version,
        uint256 baseOut,
        address recipient,
        bytes calldata data
    )
        external
        override
        nonReentrant
        checkVersion(version)
        whenNotPaused
        returns (uint256 realBaseOut)
    {
        require(baseOut > 0, "Zero output");
        realBaseOut = baseOut;
        (uint256 oldBase, uint256 oldQuote) = _handleRebalance(version);
        require(baseOut < oldBase, "Insufficient liquidity");
        // Optimistically transfer tokens.
        fund.trancheTransfer(baseTranche, recipient, baseOut, version);
        if (data.length > 0) {
            ITranchessSwapCallee(msg.sender).tranchessSwapCallback(baseOut, 0, data);
        }
        uint256 newQuote = _getNewQuoteBalance();
        uint256 quoteIn = newQuote.sub(oldQuote);
        uint256 fee = quoteIn.multiplyDecimal(feeRate);
        uint256 oraclePrice = getOraclePrice();
        {
            uint256 ampl = getAmpl();
            uint256 oldD = _getD(oldBase, oldQuote, ampl, oraclePrice);
            _updatePriceOverOracleIntegral(oldBase, oldQuote, ampl, oraclePrice, oldD);
            uint256 newD = _getD(oldBase - baseOut, newQuote.sub(fee), ampl, oraclePrice);
            require(newD >= oldD, "Invariant mismatch");
        }
        uint256 adminFee = fee.multiplyDecimal(adminFeeRate);
        baseBalance = oldBase - baseOut;
        quoteBalance = newQuote.sub(adminFee);
        totalAdminFee = totalAdminFee.add(adminFee);
        uint256 baseOut_ = baseOut;
        emit Swap(msg.sender, recipient, 0, quoteIn, baseOut_, 0, fee, adminFee, oraclePrice);
    }

    function sell(
        uint256 version,
        uint256 quoteOut,
        address recipient,
        bytes calldata data
    )
        external
        override
        nonReentrant
        checkVersion(version)
        whenNotPaused
        returns (uint256 realQuoteOut)
    {
        require(quoteOut > 0, "Zero output");
        realQuoteOut = quoteOut;
        (uint256 oldBase, uint256 oldQuote) = _handleRebalance(version);
        // Optimistically transfer tokens.
        IERC20(quoteAddress).safeTransfer(recipient, quoteOut);
        if (data.length > 0) {
            ITranchessSwapCallee(msg.sender).tranchessSwapCallback(0, quoteOut, data);
        }
        uint256 newBase = fund.trancheBalanceOf(baseTranche, address(this));
        uint256 baseIn = newBase.sub(oldBase);
        uint256 fee;
        {
            uint256 feeRate_ = feeRate;
            fee = quoteOut.mul(feeRate_).div(1e18 - feeRate_);
        }
        require(quoteOut.add(fee) < oldQuote, "Insufficient liquidity");
        uint256 oraclePrice = getOraclePrice();
        {
            uint256 newQuote = oldQuote - quoteOut;
            uint256 ampl = getAmpl();
            uint256 oldD = _getD(oldBase, oldQuote, ampl, oraclePrice);
            _updatePriceOverOracleIntegral(oldBase, oldQuote, ampl, oraclePrice, oldD);
            uint256 newD = _getD(newBase, newQuote - fee, ampl, oraclePrice);
            require(newD >= oldD, "Invariant mismatch");
        }
        uint256 adminFee = fee.multiplyDecimal(adminFeeRate);
        baseBalance = newBase;
        quoteBalance = oldQuote - quoteOut - adminFee;
        totalAdminFee = totalAdminFee.add(adminFee);
        uint256 quoteOut_ = quoteOut;
        emit Swap(msg.sender, recipient, baseIn, 0, 0, quoteOut_, fee, adminFee, oraclePrice);
    }

    /// @notice Add liquidity. This function should be called by a smart contract, which transfers
    ///         base and quote tokens to this contract in the same transaction.
    /// @param version The latest rebalance version
    /// @param recipient Recipient of minted LP tokens
    /// @param lpOut Amount of minted LP tokens
    function addLiquidity(uint256 version, address recipient)
        external
        override
        nonReentrant
        checkVersion(version)
        whenNotPaused
        returns (uint256 lpOut)
    {
        (uint256 oldBase, uint256 oldQuote) = _handleRebalance(version);
        uint256 newBase = fund.trancheBalanceOf(baseTranche, address(this));
        uint256 newQuote = _getNewQuoteBalance();
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        uint256 lpSupply = IERC20(lpToken).totalSupply();
        if (lpSupply == 0) {
            require(newBase > 0 && newQuote > 0, "Zero initial balance");
            baseBalance = newBase;
            quoteBalance = newQuote;
            // Overflow is desired
            _priceOverOracleIntegral += 1e18 * (block.timestamp - _priceOverOracleTimestamp);
            _priceOverOracleTimestamp = block.timestamp;
            uint256 d1 = _getD(newBase, newQuote, ampl, oraclePrice);
            ILiquidityGauge(lpToken).mint(address(this), MINIMUM_LIQUIDITY);
            ILiquidityGauge(lpToken).mint(recipient, d1.sub(MINIMUM_LIQUIDITY));
            emit LiquidityAdded(msg.sender, recipient, newBase, newQuote, d1, 0, 0, oraclePrice);
            return d1;
        }
        uint256 fee;
        uint256 adminFee;
        {
            // Initial invariant
            uint256 d0 = _getD(oldBase, oldQuote, ampl, oraclePrice);
            _updatePriceOverOracleIntegral(oldBase, oldQuote, ampl, oraclePrice, d0);
            {
                // New invariant before charging fee
                uint256 d1 = _getD(newBase, newQuote, ampl, oraclePrice);
                uint256 idealQuote = d1.mul(oldQuote) / d0;
                uint256 difference =
                    idealQuote > newQuote ? idealQuote - newQuote : newQuote - idealQuote;
                fee = difference.multiplyDecimal(feeRate);
            }
            adminFee = fee.multiplyDecimal(adminFeeRate);
            totalAdminFee = totalAdminFee.add(adminFee);
            baseBalance = newBase;
            quoteBalance = newQuote.sub(adminFee);
            // New invariant after charging fee
            uint256 d2 = _getD(newBase, newQuote.sub(fee), ampl, oraclePrice);
            require(d2 > d0, "No liquidity is added");
            lpOut = lpSupply.mul(d2.sub(d0)).div(d0);
        }
        ILiquidityGauge(lpToken).mint(recipient, lpOut);
        emit LiquidityAdded(
            msg.sender,
            recipient,
            newBase - oldBase,
            newQuote - oldQuote,
            lpOut,
            fee,
            adminFee,
            oraclePrice
        );
    }

    /// @dev Remove liquidity proportionally.
    /// @param lpIn Exact amount of LP token to burn
    /// @param minBaseOut Least amount of base asset to withdraw
    /// @param minQuoteOut Least amount of quote asset to withdraw
    function removeLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut,
        uint256 minQuoteOut
    )
        external
        override
        nonReentrant
        checkVersion(version)
        returns (uint256 baseOut, uint256 quoteOut)
    {
        (baseOut, quoteOut) = _removeLiquidity(version, lpIn, minBaseOut, minQuoteOut);
        IERC20(quoteAddress).safeTransfer(msg.sender, quoteOut);
    }

    /// @dev Remove liquidity proportionally and unwrap for native token.
    /// @param lpIn Exact amount of LP token to burn
    /// @param minBaseOut Least amount of base asset to withdraw
    /// @param minQuoteOut Least amount of quote asset to withdraw
    function removeLiquidityUnwrap(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut,
        uint256 minQuoteOut
    )
        external
        override
        nonReentrant
        checkVersion(version)
        returns (uint256 baseOut, uint256 quoteOut)
    {
        (baseOut, quoteOut) = _removeLiquidity(version, lpIn, minBaseOut, minQuoteOut);
        IWrappedERC20(quoteAddress).withdraw(quoteOut);
        (bool success, ) = msg.sender.call{value: quoteOut}("");
        require(success, "Transfer failed");
    }

    function _removeLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut,
        uint256 minQuoteOut
    ) private returns (uint256 baseOut, uint256 quoteOut) {
        uint256 lpSupply = IERC20(lpToken).totalSupply();
        (uint256 oldBase, uint256 oldQuote) = _handleRebalance(version);
        baseOut = oldBase.mul(lpIn).div(lpSupply);
        quoteOut = oldQuote.mul(lpIn).div(lpSupply);
        require(baseOut >= minBaseOut, "Insufficient output");
        require(quoteOut >= minQuoteOut, "Insufficient output");
        baseBalance = oldBase.sub(baseOut);
        quoteBalance = oldQuote.sub(quoteOut);
        ILiquidityGauge(lpToken).burnFrom(msg.sender, lpIn);
        fund.trancheTransfer(baseTranche, msg.sender, baseOut, version);
        emit LiquidityRemoved(msg.sender, lpIn, baseOut, quoteOut, 0, 0, 0);
    }

    /// @dev Remove base liquidity only.
    /// @param lpIn Exact amount of LP token to burn
    /// @param minBaseOut Least amount of base asset to withdraw
    function removeBaseLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut
    ) external override nonReentrant checkVersion(version) whenNotPaused returns (uint256 baseOut) {
        (uint256 oldBase, uint256 oldQuote) = _handleRebalance(version);
        uint256 lpSupply = IERC20(lpToken).totalSupply();
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        uint256 d1;
        {
            uint256 d0 = _getD(oldBase, oldQuote, ampl, oraclePrice);
            _updatePriceOverOracleIntegral(oldBase, oldQuote, ampl, oraclePrice, d0);
            d1 = d0.sub(d0.mul(lpIn).div(lpSupply));
        }
        {
            uint256 fee = oldQuote.mul(lpIn).div(lpSupply).multiplyDecimal(feeRate);
            // Add 1 in case of rounding errors
            uint256 newBase = _getBase(ampl, oldQuote.sub(fee), oraclePrice, d1) + 1;
            baseOut = oldBase.sub(newBase);
            require(baseOut >= minBaseOut, "Insufficient output");
            ILiquidityGauge(lpToken).burnFrom(msg.sender, lpIn);
            baseBalance = newBase;
            uint256 adminFee = fee.multiplyDecimal(adminFeeRate);
            totalAdminFee = totalAdminFee.add(adminFee);
            quoteBalance = oldQuote.sub(adminFee);
            emit LiquidityRemoved(msg.sender, lpIn, baseOut, 0, fee, adminFee, oraclePrice);
        }
        fund.trancheTransfer(baseTranche, msg.sender, baseOut, version);
    }

    /// @dev Remove quote liquidity only.
    /// @param lpIn Exact amount of LP token to burn
    /// @param minQuoteOut Least amount of quote asset to withdraw
    function removeQuoteLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minQuoteOut
    )
        external
        override
        nonReentrant
        checkVersion(version)
        whenNotPaused
        returns (uint256 quoteOut)
    {
        quoteOut = _removeQuoteLiquidity(version, lpIn, minQuoteOut);
        IERC20(quoteAddress).safeTransfer(msg.sender, quoteOut);
    }

    /// @dev Remove quote liquidity only and unwrap for native token.
    /// @param lpIn Exact amount of LP token to burn
    /// @param minQuoteOut Least amount of quote asset to withdraw
    function removeQuoteLiquidityUnwrap(
        uint256 version,
        uint256 lpIn,
        uint256 minQuoteOut
    )
        external
        override
        nonReentrant
        checkVersion(version)
        whenNotPaused
        returns (uint256 quoteOut)
    {
        quoteOut = _removeQuoteLiquidity(version, lpIn, minQuoteOut);
        IWrappedERC20(quoteAddress).withdraw(quoteOut);
        (bool success, ) = msg.sender.call{value: quoteOut}("");
        require(success, "Transfer failed");
    }

    function _removeQuoteLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minQuoteOut
    ) private returns (uint256 quoteOut) {
        (uint256 oldBase, uint256 oldQuote) = _handleRebalance(version);
        uint256 lpSupply = IERC20(lpToken).totalSupply();
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        uint256 d1;
        {
            uint256 d0 = _getD(oldBase, oldQuote, ampl, oraclePrice);
            _updatePriceOverOracleIntegral(oldBase, oldQuote, ampl, oraclePrice, d0);
            d1 = d0.sub(d0.mul(lpIn).div(lpSupply));
        }
        uint256 idealQuote = oldQuote.mul(lpSupply.sub(lpIn)).div(lpSupply);
        // Add 1 in case of rounding errors
        uint256 newQuote = _getQuote(ampl, oldBase, oraclePrice, d1) + 1;
        uint256 fee = idealQuote.sub(newQuote).multiplyDecimal(feeRate);
        quoteOut = oldQuote.sub(newQuote).sub(fee);
        require(quoteOut >= minQuoteOut, "Insufficient output");
        ILiquidityGauge(lpToken).burnFrom(msg.sender, lpIn);
        uint256 adminFee = fee.multiplyDecimal(adminFeeRate);
        totalAdminFee = totalAdminFee.add(adminFee);
        quoteBalance = newQuote.add(fee).sub(adminFee);
        emit LiquidityRemoved(msg.sender, lpIn, 0, quoteOut, fee, adminFee, oraclePrice);
    }

    /// @notice Force stored values to match balances.
    function sync() external nonReentrant {
        (uint256 oldBase, uint256 oldQuote) = _handleRebalance(fund.getRebalanceSize());
        uint256 ampl = getAmpl();
        uint256 oraclePrice = getOraclePrice();
        uint256 d = _getD(oldBase, oldQuote, ampl, oraclePrice);
        _updatePriceOverOracleIntegral(oldBase, oldQuote, ampl, oraclePrice, d);
        uint256 newBase = fund.trancheBalanceOf(baseTranche, address(this));
        uint256 newQuote = _getNewQuoteBalance();
        baseBalance = newBase;
        quoteBalance = newQuote;
        emit Sync(newBase, newQuote, oraclePrice);
    }

    function collectFee() external {
        IERC20(quoteAddress).safeTransfer(feeCollector, totalAdminFee);
        delete totalAdminFee;
    }

    function _getNewQuoteBalance() private view returns (uint256) {
        return IERC20(quoteAddress).balanceOf(address(this)).sub(totalAdminFee);
    }

    function _updatePriceOverOracleIntegral(
        uint256 base,
        uint256 quote,
        uint256 ampl,
        uint256 oraclePrice,
        uint256 d
    ) private {
        // Overflow is desired
        _priceOverOracleIntegral +=
            _getPriceOverOracle(base, quote, ampl, oraclePrice, d) *
            (block.timestamp - _priceOverOracleTimestamp);
        _priceOverOracleTimestamp = block.timestamp;
    }

    function _getD(
        uint256 base,
        uint256 quote,
        uint256 ampl,
        uint256 oraclePrice
    ) private view returns (uint256) {
        // Newtonian: D' = (4A(kx + y) + D^3 / 2kxy)D / ((4A - 1)D + 3D^3 / 4kxy)
        uint256 normalizedQuote = quote.mul(_quoteDecimalMultiplier);
        uint256 baseValue = base.multiplyDecimal(oraclePrice);
        uint256 sum = baseValue.add(normalizedQuote);
        if (sum == 0) return 0;

        uint256 prev = 0;
        uint256 d = sum;
        for (uint256 i = 0; i < MAX_ITERATION; i++) {
            prev = d;
            uint256 d3 = d.mul(d).div(baseValue).mul(d) / normalizedQuote / 4;
            d = (sum.mul(4 * ampl) + 2 * d3).mul(d) / d.mul(4 * ampl - 1).add(3 * d3);
            if (d <= prev + 1 && prev <= d + 1) {
                break;
            }
        }
        return d;
    }

    function _getPriceOverOracle(
        uint256 base,
        uint256 quote,
        uint256 ampl,
        uint256 oraclePrice,
        uint256 d
    ) private view returns (uint256) {
        uint256 commonExp = d.multiplyDecimal(4e18 - 1e18 / ampl);
        uint256 baseValue = base.multiplyDecimal(oraclePrice);
        uint256 normalizedQuote = quote.mul(_quoteDecimalMultiplier);
        return
            (baseValue.mul(8).add(normalizedQuote.mul(4)).sub(commonExp))
                .multiplyDecimal(normalizedQuote)
                .divideDecimal(normalizedQuote.mul(8).add(baseValue.mul(4)).sub(commonExp))
                .divideDecimal(baseValue);
    }

    function _getBase(
        uint256 ampl,
        uint256 quote,
        uint256 oraclePrice,
        uint256 d
    ) private view returns (uint256 base) {
        // Solve 16Ayk^2·x^2 + 4ky(4Ay - 4AD + D)·x - D^3 = 0
        // Newtonian: kx' = ((kx)^2 + D^3 / 16Ay) / (2kx + y - D + D/4A)
        uint256 normalizedQuote = quote.mul(_quoteDecimalMultiplier);
        uint256 d3 = d.mul(d).div(normalizedQuote).mul(d) / (16 * ampl);
        uint256 prev = 0;
        uint256 baseValue = d;
        for (uint256 i = 0; i < MAX_ITERATION; i++) {
            prev = baseValue;
            baseValue =
                baseValue.mul(baseValue).add(d3) /
                (2 * baseValue).add(normalizedQuote).add(d / (4 * ampl)).sub(d);
            if (baseValue <= prev + 1 && prev <= baseValue + 1) {
                break;
            }
        }
        base = baseValue.divideDecimal(oraclePrice);
    }

    function _getQuote(
        uint256 ampl,
        uint256 base,
        uint256 oraclePrice,
        uint256 d
    ) private view returns (uint256 quote) {
        // Solve 16Axk·y^2 + 4kx(4Akx - 4AD + D)·y - D^3 = 0
        // Newtonian: y' = (y^2 + D^3 / 16Akx) / (2y + kx - D + D/4A)
        uint256 baseValue = base.multiplyDecimal(oraclePrice);
        uint256 d3 = d.mul(d).div(baseValue).mul(d) / (16 * ampl);
        uint256 prev = 0;
        uint256 normalizedQuote = d;
        for (uint256 i = 0; i < MAX_ITERATION; i++) {
            prev = normalizedQuote;
            normalizedQuote =
                normalizedQuote.mul(normalizedQuote).add(d3) /
                (2 * normalizedQuote).add(baseValue).add(d / (4 * ampl)).sub(d);
            if (normalizedQuote <= prev + 1 && prev <= normalizedQuote + 1) {
                break;
            }
        }
        quote = normalizedQuote / _quoteDecimalMultiplier;
    }

    function updateAmplRamp(uint256 endAmpl, uint256 endTimestamp) external onlyOwner {
        require(endAmpl > 0 && endAmpl < AMPL_MAX_VALUE, "Invalid A");
        require(endTimestamp >= block.timestamp + AMPL_RAMP_MIN_TIME, "A ramp time too short");
        uint256 ampl = getAmpl();
        require(
            (endAmpl >= ampl && endAmpl <= ampl * AMPL_RAMP_MAX_CHANGE) ||
                (endAmpl < ampl && endAmpl * AMPL_RAMP_MAX_CHANGE >= ampl),
            "A ramp change too large"
        );
        amplRampStart = ampl;
        amplRampEnd = endAmpl;
        amplRampStartTimestamp = block.timestamp;
        amplRampEndTimestamp = endTimestamp;
        emit AmplRampUpdated(ampl, endAmpl, block.timestamp, endTimestamp);
    }

    function _updateFeeCollector(address newFeeCollector) private {
        feeCollector = newFeeCollector;
        emit FeeCollectorUpdated(newFeeCollector);
    }

    function updateFeeCollector(address newFeeCollector) external onlyOwner {
        _updateFeeCollector(newFeeCollector);
    }

    function _updateFeeRate(uint256 newFeeRate) private {
        require(newFeeRate <= MAX_FEE_RATE, "Exceed max fee rate");
        feeRate = newFeeRate;
        emit FeeRateUpdated(newFeeRate);
    }

    function updateFeeRate(uint256 newFeeRate) external onlyOwner {
        _updateFeeRate(newFeeRate);
    }

    function _updateAdminFeeRate(uint256 newAdminFeeRate) private {
        require(newAdminFeeRate <= MAX_ADMIN_FEE_RATE, "Exceed max admin fee rate");
        adminFeeRate = newAdminFeeRate;
        emit AdminFeeRateUpdated(newAdminFeeRate);
    }

    function updateAdminFeeRate(uint256 newAdminFeeRate) external onlyOwner {
        _updateAdminFeeRate(newAdminFeeRate);
    }

    /// @dev Check if the user-specified version is correct.
    modifier checkVersion(uint256 version) virtual {_;}

    /// @dev Compute the new base and quote amount after rebalanced to the latest version.
    ///      If any tokens should be distributed to LP holders, their amounts are also returned.
    ///
    ///      The latest rebalance version is passed in a parameter and it is caller's responsibility
    ///      to pass the correct version.
    /// @param latestVersion The latest rebalance version
    /// @return newBase Amount of base tokens after rebalance
    /// @return newQuote Amount of quote tokens after rebalance
    /// @return excessiveQ Amount of QUEEN that should be distributed to LP holders due to rebalance
    /// @return excessiveB Amount of BISHOP that should be distributed to LP holders due to rebalance
    /// @return excessiveR Amount of ROOK that should be distributed to LP holders due to rebalance
    /// @return excessiveQuote Amount of quote tokens that should be distributed to LP holders due to rebalance
    /// @return isRebalanced Whether the stored base and quote amount are rebalanced
    function _getRebalanceResult(uint256 latestVersion)
        internal
        view
        virtual
        returns (
            uint256 newBase,
            uint256 newQuote,
            uint256 excessiveQ,
            uint256 excessiveB,
            uint256 excessiveR,
            uint256 excessiveQuote,
            bool isRebalanced
        );

    /// @dev Update the stored base and quote balance to the latest rebalance version and distribute
    ///      any excessive tokens to LP holders.
    ///
    ///      The latest rebalance version is passed in a parameter and it is caller's responsibility
    ///      to pass the correct version.
    /// @param latestVersion The latest rebalance version
    /// @return newBase Amount of stored base tokens after rebalance
    /// @return newQuote Amount of stored quote tokens after rebalance
    function _handleRebalance(uint256 latestVersion)
        internal
        virtual
        returns (uint256 newBase, uint256 newQuote);

    /// @notice Get the base token price from the price oracle. The returned price is normalized
    ///         to 18 decimal places.
    function getOraclePrice() public view virtual override returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "../interfaces/ILiquidityGauge.sol";
import "../interfaces/IChessSchedule.sol";
import "../interfaces/IChessController.sol";
import "../interfaces/IFundV3.sol";
import "../interfaces/ITrancheIndexV2.sol";
import "../interfaces/IStableSwap.sol";
import "../interfaces/IVotingEscrow.sol";

import "../utils/CoreUtility.sol";
import "../utils/SafeDecimalMath.sol";

interface ISwapBonus {
    function bonusToken() external view returns (address);

    function getBonus() external returns (uint256);
}

contract LiquidityGauge is ILiquidityGauge, ITrancheIndexV2, CoreUtility, ERC20 {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    struct Distribution {
        uint256 amountQ;
        uint256 amountB;
        uint256 amountR;
        uint256 quoteAmount;
    }

    uint256 private constant MAX_ITERATIONS = 500;
    uint256 private constant MAX_BOOSTING_FACTOR = 3e18;
    uint256 private constant MAX_BOOSTING_FACTOR_MINUS_ONE = MAX_BOOSTING_FACTOR - 1e18;

    address public immutable stableSwap;
    IERC20 private immutable _quoteToken;
    IChessSchedule public immutable chessSchedule;
    IChessController public immutable chessController;
    IFundV3 public immutable fund;
    IVotingEscrow private immutable _votingEscrow;
    address public immutable swapBonus;
    IERC20 private immutable _bonusToken;
    /// @notice Timestamp when rewards start.
    uint256 public immutable rewardStartTimestamp;

    uint256 private _workingSupply;
    mapping(address => uint256) private _workingBalances;

    uint256 public latestVersion;
    mapping(uint256 => Distribution) public distributions;
    mapping(uint256 => uint256) public distributionTotalSupplies;
    mapping(address => Distribution) public userDistributions;
    mapping(address => uint256) public userVersions;

    uint256 private _chessIntegral;
    uint256 private _chessIntegralTimestamp;
    mapping(address => uint256) private _chessUserIntegrals;
    mapping(address => uint256) private _claimableChess;

    uint256 private _bonusIntegral;
    mapping(address => uint256) private _bonusUserIntegral;
    mapping(address => uint256) private _claimableBonus;

    /// @dev Per-gauge CHESS emission rate. The product of CHESS emission rate
    ///      and weekly percentage of the gauge
    uint256 private _rate;

    constructor(
        string memory name_,
        string memory symbol_,
        address stableSwap_,
        address chessSchedule_,
        address chessController_,
        address fund_,
        address votingEscrow_,
        address swapBonus_,
        uint256 rewardStartTimestamp_
    ) public ERC20(name_, symbol_) {
        stableSwap = stableSwap_;
        _quoteToken = IERC20(IStableSwap(stableSwap_).quoteAddress());
        chessSchedule = IChessSchedule(chessSchedule_);
        chessController = IChessController(chessController_);
        fund = IFundV3(fund_);
        _votingEscrow = IVotingEscrow(votingEscrow_);
        swapBonus = swapBonus_;
        _bonusToken = IERC20(ISwapBonus(swapBonus_).bonusToken());
        rewardStartTimestamp = rewardStartTimestamp_;
        _chessIntegralTimestamp = block.timestamp;
    }

    modifier onlyStableSwap() {
        require(msg.sender == stableSwap, "Only stable swap");
        _;
    }

    function getRate() external view returns (uint256) {
        return _rate / 1e18;
    }

    function mint(address account, uint256 amount) external override onlyStableSwap {
        uint256 oldWorkingBalance = _workingBalances[account];
        uint256 oldWorkingSupply = _workingSupply;
        uint256 oldBalance = balanceOf(account);
        _checkpoint(account, oldBalance, oldWorkingBalance, oldWorkingSupply);

        _mint(account, amount);
        _updateWorkingBalance(
            account,
            oldWorkingBalance,
            oldWorkingSupply,
            oldBalance.add(amount),
            totalSupply()
        );
    }

    function burnFrom(address account, uint256 amount) external override onlyStableSwap {
        uint256 oldWorkingBalance = _workingBalances[account];
        uint256 oldWorkingSupply = _workingSupply;
        uint256 oldBalance = balanceOf(account);
        _checkpoint(account, oldBalance, oldWorkingBalance, oldWorkingSupply);

        _burn(account, amount);
        _updateWorkingBalance(
            account,
            oldWorkingBalance,
            oldWorkingSupply,
            oldBalance.sub(amount),
            totalSupply()
        );
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal override {
        revert("Transfer is not allowed");
    }

    function workingBalanceOf(address account) external view override returns (uint256) {
        return _workingBalances[account];
    }

    function workingSupply() external view override returns (uint256) {
        return _workingSupply;
    }

    function claimableRewards(address account)
        external
        override
        returns (
            uint256 chessAmount,
            uint256 bonusAmount,
            uint256 amountQ,
            uint256 amountB,
            uint256 amountR,
            uint256 quoteAmount
        )
    {
        return _checkpoint(account, balanceOf(account), _workingBalances[account], _workingSupply);
    }

    function claimRewards(address account) external override {
        uint256 balance = balanceOf(account);
        uint256 oldWorkingBalance = _workingBalances[account];
        uint256 oldWorkingSupply = _workingSupply;
        (
            uint256 chessAmount,
            uint256 bonusAmount,
            uint256 amountQ,
            uint256 amountB,
            uint256 amountR,
            uint256 quoteAmount
        ) = _checkpoint(account, balance, oldWorkingBalance, oldWorkingSupply);
        _updateWorkingBalance(account, oldWorkingBalance, oldWorkingSupply, balance, totalSupply());

        if (chessAmount != 0) {
            chessSchedule.mint(account, chessAmount);
            delete _claimableChess[account];
        }
        if (bonusAmount != 0) {
            _bonusToken.safeTransfer(account, bonusAmount);
            delete _claimableBonus[account];
        }
        if (amountQ != 0 || amountB != 0 || amountR != 0 || quoteAmount != 0) {
            uint256 version = latestVersion;
            if (amountQ != 0) {
                fund.trancheTransfer(TRANCHE_Q, account, amountQ, version);
            }
            if (amountB != 0) {
                fund.trancheTransfer(TRANCHE_B, account, amountB, version);
            }
            if (amountR != 0) {
                fund.trancheTransfer(TRANCHE_R, account, amountR, version);
            }
            if (quoteAmount != 0) {
                _quoteToken.safeTransfer(account, quoteAmount);
            }
            delete userDistributions[account];
        }
    }

    function syncWithVotingEscrow(address account) external {
        uint256 balance = balanceOf(account);
        uint256 oldWorkingBalance = _workingBalances[account];
        uint256 oldWorkingSupply = _workingSupply;
        _checkpoint(account, balance, oldWorkingBalance, oldWorkingSupply);
        _updateWorkingBalance(account, oldWorkingBalance, oldWorkingSupply, balance, totalSupply());
    }

    function distribute(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 quoteAmount,
        uint256 version
    ) external override onlyStableSwap {
        // Update global state
        distributions[version].amountQ = amountQ;
        distributions[version].amountB = amountB;
        distributions[version].amountR = amountR;
        distributions[version].quoteAmount = quoteAmount;
        distributionTotalSupplies[version] = totalSupply();
        latestVersion = version;
    }

    function _updateWorkingBalance(
        address account,
        uint256 oldWorkingBalance,
        uint256 oldWorkingSupply,
        uint256 newBalance,
        uint256 newTotalSupply
    ) private {
        uint256 newWorkingBalance = newBalance;
        uint256 veBalance = _votingEscrow.balanceOf(account);
        if (veBalance > 0) {
            uint256 veTotalSupply = _votingEscrow.totalSupply();
            uint256 maxWorkingBalance = newWorkingBalance.multiplyDecimal(MAX_BOOSTING_FACTOR);
            uint256 boostedWorkingBalance =
                newWorkingBalance.add(
                    newTotalSupply
                        .mul(veBalance)
                        .multiplyDecimal(MAX_BOOSTING_FACTOR_MINUS_ONE)
                        .div(veTotalSupply)
                );
            newWorkingBalance = maxWorkingBalance.min(boostedWorkingBalance);
        }
        _workingSupply = oldWorkingSupply.sub(oldWorkingBalance).add(newWorkingBalance);
        _workingBalances[account] = newWorkingBalance;
    }

    function _checkpoint(
        address account,
        uint256 balance,
        uint256 weight,
        uint256 totalWeight
    )
        private
        returns (
            uint256 chessAmount,
            uint256 bonusAmount,
            uint256 amountQ,
            uint256 amountB,
            uint256 amountR,
            uint256 quoteAmount
        )
    {
        chessAmount = _chessCheckpoint(account, weight, totalWeight);
        bonusAmount = _bonusCheckpoint(account, weight, totalWeight);
        (amountQ, amountB, amountR, quoteAmount) = _distributionCheckpoint(account, balance);
    }

    function _chessCheckpoint(
        address account,
        uint256 weight,
        uint256 totalWeight
    ) private returns (uint256 amount) {
        // Update global state
        uint256 timestamp = _chessIntegralTimestamp;
        uint256 integral = _chessIntegral;
        uint256 endWeek = _endOfWeek(timestamp);
        uint256 rate = _rate;
        for (uint256 i = 0; i < MAX_ITERATIONS && timestamp < block.timestamp; i++) {
            uint256 endTimestamp = endWeek.min(block.timestamp);
            if (totalWeight != 0 && endTimestamp > rewardStartTimestamp) {
                integral = integral.add(
                    rate
                        .mul(endTimestamp.sub(timestamp.max(rewardStartTimestamp)))
                        .decimalToPreciseDecimal()
                        .div(totalWeight)
                );
            }
            if (endTimestamp == endWeek) {
                rate = chessSchedule.getRate(endWeek).mul(
                    chessController.getFundRelativeWeight(address(this), endWeek)
                );
                if (endWeek < rewardStartTimestamp && endWeek + 1 weeks > rewardStartTimestamp) {
                    // Rewards start in the middle of the next week. We adjust the rate to
                    // compensate for the period between `endWeek` and `rewardStartTimestamp`.
                    rate = rate.mul(1 weeks).div(endWeek + 1 weeks - rewardStartTimestamp);
                }
                endWeek += 1 weeks;
            }
            timestamp = endTimestamp;
        }
        _chessIntegralTimestamp = block.timestamp;
        _chessIntegral = integral;
        _rate = rate;

        // Update per-user state
        amount = _claimableChess[account].add(
            weight.multiplyDecimalPrecise(integral.sub(_chessUserIntegrals[account]))
        );
        _claimableChess[account] = amount;
        _chessUserIntegrals[account] = integral;
    }

    function _bonusCheckpoint(
        address account,
        uint256 weight,
        uint256 totalWeight
    ) private returns (uint256 amount) {
        // Update global state
        uint256 newBonus = ISwapBonus(swapBonus).getBonus();
        uint256 integral = _bonusIntegral;
        if (totalWeight != 0 && newBonus != 0) {
            integral = integral.add(newBonus.divideDecimalPrecise(totalWeight));
            _bonusIntegral = integral;
        }

        // Update per-user state
        uint256 oldUserIntegral = _bonusUserIntegral[account];
        if (oldUserIntegral == integral) {
            return _claimableBonus[account];
        }
        amount = _claimableBonus[account].add(
            weight.multiplyDecimalPrecise(integral.sub(oldUserIntegral))
        );
        _claimableBonus[account] = amount;
        _bonusUserIntegral[account] = integral;
    }

    function _distributionCheckpoint(address account, uint256 balance)
        private
        returns (
            uint256 amountQ,
            uint256 amountB,
            uint256 amountR,
            uint256 quoteAmount
        )
    {
        uint256 version = userVersions[account];
        uint256 newVersion = latestVersion;

        // Update per-user state
        Distribution storage userDist = userDistributions[account];
        amountQ = userDist.amountQ;
        amountB = userDist.amountB;
        amountR = userDist.amountR;
        quoteAmount = userDist.quoteAmount;
        if (version == newVersion) {
            return (amountQ, amountB, amountR, quoteAmount);
        }
        for (uint256 i = version; i < newVersion; i++) {
            if (amountQ != 0 || amountB != 0 || amountR != 0) {
                (amountQ, amountB, amountR) = fund.doRebalance(amountQ, amountB, amountR, i);
            }
            Distribution storage dist = distributions[i + 1];
            uint256 distTotalSupply = distributionTotalSupplies[i + 1];
            if (distTotalSupply != 0) {
                amountQ = amountQ.add(dist.amountQ.mul(balance).div(distTotalSupply));
                amountB = amountB.add(dist.amountB.mul(balance).div(distTotalSupply));
                amountR = amountR.add(dist.amountR.mul(balance).div(distTotalSupply));
                quoteAmount = quoteAmount.add(dist.quoteAmount.mul(balance).div(distTotalSupply));
            }
        }
        userDist.amountQ = amountQ;
        userDist.amountB = amountB;
        userDist.amountR = amountR;
        userDist.quoteAmount = quoteAmount;
        userVersions[account] = newVersion;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract SwapBonus is Ownable {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable liquidityGauge;
    address public immutable bonusToken;
    uint256 public ratePerSecond;
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    uint256 public lastTimestamp;

    constructor(address liquidityGauge_, address bonusToken_) public {
        liquidityGauge = liquidityGauge_;
        bonusToken = bonusToken_;
    }

    function updateBonus(
        uint256 amount,
        uint256 start,
        uint256 interval
    ) external onlyOwner {
        require(start >= block.timestamp, "Start time in the past");
        require(
            endTimestamp < block.timestamp && endTimestamp == lastTimestamp,
            "Last reward not yet expired"
        );
        ratePerSecond = amount.div(interval);
        startTimestamp = start;
        endTimestamp = start.add(interval);
        lastTimestamp = startTimestamp;
        IERC20(bonusToken).safeTransferFrom(msg.sender, address(this), ratePerSecond.mul(interval));
    }

    function getBonus() external returns (uint256) {
        require(msg.sender == liquidityGauge);
        uint256 currentTimestamp = endTimestamp.min(block.timestamp);
        uint256 reward = ratePerSecond.mul(currentTimestamp - lastTimestamp);
        lastTimestamp = currentTimestamp;
        if (reward > 0) {
            IERC20(bonusToken).safeTransfer(liquidityGauge, reward);
        }
        return reward;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/ISwapRouter.sol";
import "../interfaces/ITrancheIndexV2.sol";
import "../fund/ShareStaking.sol";
import "../interfaces/IWrappedERC20.sol";

/// @title Tranchess Swap Router
/// @notice Router for stateless execution of swaps against Tranchess stable swaps
contract SwapRouter is ISwapRouter, ITrancheIndexV2, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event SwapAdded(address addr0, address addr1, address swap);

    mapping(address => mapping(address => IStableSwap)) private _swapMap;

    /// @dev Returns the swap for the given token pair and fee. The swap contract may or may not exist.
    function getSwap(address baseAddress, address quoteAddress)
        public
        view
        override
        returns (IStableSwap)
    {
        (address addr0, address addr1) =
            baseAddress < quoteAddress ? (baseAddress, quoteAddress) : (quoteAddress, baseAddress);
        return _swapMap[addr0][addr1];
    }

    function addSwap(
        address baseAddress,
        address quoteAddress,
        address swap
    ) external onlyOwner {
        require(
            swap == address(0) ||
                (baseAddress == IStableSwap(swap).baseAddress() &&
                    quoteAddress == IStableSwap(swap).quoteAddress())
        ); // sanity check
        (address addr0, address addr1) =
            baseAddress < quoteAddress ? (baseAddress, quoteAddress) : (quoteAddress, baseAddress);
        _swapMap[addr0][addr1] = IStableSwap(swap);
        emit SwapAdded(addr0, addr1, swap);
    }

    receive() external payable {}

    function addLiquidity(
        address baseAddress,
        address quoteAddress,
        uint256 baseIn,
        uint256 quoteIn,
        uint256 minLpOut,
        uint256 version,
        uint256 deadline
    ) external payable override checkDeadline(deadline) {
        IStableSwap swap = getSwap(baseAddress, quoteAddress);
        require(address(swap) != address(0), "Unknown swap");

        swap.fund().trancheTransferFrom(
            swap.baseTranche(),
            msg.sender,
            address(swap),
            baseIn,
            version
        );
        if (msg.value > 0) {
            require(msg.value == quoteIn); // sanity check
            IWrappedERC20(quoteAddress).deposit{value: quoteIn}();
            IERC20(quoteAddress).safeTransfer(address(swap), quoteIn);
        } else {
            IERC20(quoteAddress).safeTransferFrom(msg.sender, address(swap), quoteIn);
        }

        uint256 lpOut = swap.addLiquidity(version, msg.sender);
        require(lpOut >= minLpOut, "Insufficient output");
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        address recipient,
        address staking,
        uint256[] calldata versions,
        uint256 deadline
    ) external payable override checkDeadline(deadline) returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");
        require(versions.length == path.length - 1, "Invalid versions");
        IStableSwap[] memory swaps;
        bool[] memory isBuy;
        (amounts, swaps, isBuy) = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= minAmountOut, "Insufficient output");

        if (msg.value > 0) {
            require(msg.value == amounts[0]); // sanity check
            IWrappedERC20(path[0]).deposit{value: amounts[0]}();
            IERC20(path[0]).safeTransfer(address(swaps[0]), amounts[0]);
        } else {
            if (isBuy[0]) {
                IERC20(path[0]).safeTransferFrom(msg.sender, address(swaps[0]), amounts[0]);
            } else {
                swaps[0].fund().trancheTransferFrom(
                    swaps[0].baseTranche(),
                    msg.sender,
                    address(swaps[0]),
                    amounts[0],
                    versions[0]
                );
            }
        }

        if (staking == address(0)) {
            _swap(amounts, swaps, isBuy, versions, recipient);
        } else {
            _swap(amounts, swaps, isBuy, versions, staking);
            ShareStaking(staking).deposit(
                swaps[swaps.length - 1].baseTranche(),
                amounts[amounts.length - 1],
                recipient,
                versions[versions.length - 1]
            );
        }
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 maxAmountIn,
        address[] calldata path,
        address recipient,
        address staking,
        uint256[] calldata versions,
        uint256 deadline
    ) external payable override checkDeadline(deadline) returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");
        require(versions.length == path.length - 1, "Invalid versions");
        IStableSwap[] memory swaps;
        bool[] memory isBuy;
        (amounts, swaps, isBuy) = getAmountsIn(amountOut, path);
        require(amounts[0] <= maxAmountIn, "Excessive input");

        if (msg.value > 0) {
            require(msg.value == maxAmountIn); // sanity check
            IWrappedERC20(path[0]).deposit{value: amounts[0]}();
            IERC20(path[0]).safeTransfer(address(swaps[0]), amounts[0]);
        } else {
            if (isBuy[0]) {
                IERC20(path[0]).safeTransferFrom(msg.sender, address(swaps[0]), amounts[0]);
            } else {
                swaps[0].fund().trancheTransferFrom(
                    swaps[0].baseTranche(),
                    msg.sender,
                    address(swaps[0]),
                    amounts[0],
                    versions[0]
                );
            }
        }

        if (staking == address(0)) {
            _swap(amounts, swaps, isBuy, versions, recipient);
        } else {
            _swap(amounts, swaps, isBuy, versions, staking);
            ShareStaking(staking).deposit(
                swaps[swaps.length - 1].baseTranche(),
                amountOut,
                recipient,
                versions[versions.length - 1]
            );
        }
        // refund native token
        if (msg.value > amounts[0]) {
            (bool success, ) = msg.sender.call{value: msg.value - amounts[0]}("");
            require(success, "Transfer failed");
        }
    }

    function swapExactTokensForTokensUnwrap(
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        address recipient,
        uint256[] calldata versions,
        uint256 deadline
    ) external override checkDeadline(deadline) returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");
        require(versions.length == path.length - 1, "Invalid versions");
        IStableSwap[] memory swaps;
        bool[] memory isBuy;
        (amounts, swaps, isBuy) = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= minAmountOut, "Insufficient output");
        if (isBuy[0]) {
            IERC20(path[0]).safeTransferFrom(msg.sender, address(swaps[0]), amounts[0]);
        } else {
            swaps[0].fund().trancheTransferFrom(
                swaps[0].baseTranche(),
                msg.sender,
                address(swaps[0]),
                amounts[0],
                versions[0]
            );
        }
        _swap(amounts, swaps, isBuy, versions, address(this));
        IWrappedERC20(path[path.length - 1]).withdraw(amounts[amounts.length - 1]);
        (bool success, ) = recipient.call{value: amounts[amounts.length - 1]}("");
        require(success, "Transfer failed");
    }

    function swapTokensForExactTokensUnwrap(
        uint256 amountOut,
        uint256 maxAmountIn,
        address[] calldata path,
        address recipient,
        uint256[] calldata versions,
        uint256 deadline
    ) external override checkDeadline(deadline) returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");
        require(versions.length == path.length - 1, "Invalid versions");
        IStableSwap[] memory swaps;
        bool[] memory isBuy;
        (amounts, swaps, isBuy) = getAmountsIn(amountOut, path);
        require(amounts[0] <= maxAmountIn, "Excessive input");
        if (isBuy[0]) {
            IERC20(path[0]).safeTransferFrom(msg.sender, address(swaps[0]), amounts[0]);
        } else {
            swaps[0].fund().trancheTransferFrom(
                swaps[0].baseTranche(),
                msg.sender,
                address(swaps[0]),
                amounts[0],
                versions[0]
            );
        }
        _swap(amounts, swaps, isBuy, versions, address(this));
        IWrappedERC20(path[path.length - 1]).withdraw(amountOut);
        (bool success, ) = recipient.call{value: amountOut}("");
        require(success, "Transfer failed");
    }

    function getAmountsOut(uint256 amount, address[] memory path)
        public
        view
        override
        returns (
            uint256[] memory amounts,
            IStableSwap[] memory swaps,
            bool[] memory isBuy
        )
    {
        amounts = new uint256[](path.length);
        swaps = new IStableSwap[](path.length - 1);
        isBuy = new bool[](path.length - 1);
        amounts[0] = amount;
        for (uint256 i; i < path.length - 1; i++) {
            swaps[i] = getSwap(path[i], path[i + 1]);
            require(address(swaps[i]) != address(0), "Unknown swap");
            if (path[i] == swaps[i].baseAddress()) {
                amounts[i + 1] = swaps[i].getQuoteOut(amounts[i]);
            } else {
                isBuy[i] = true;
                amounts[i + 1] = swaps[i].getBaseOut(amounts[i]);
            }
        }
    }

    function getAmountsIn(uint256 amount, address[] memory path)
        public
        view
        override
        returns (
            uint256[] memory amounts,
            IStableSwap[] memory swaps,
            bool[] memory isBuy
        )
    {
        amounts = new uint256[](path.length);
        swaps = new IStableSwap[](path.length - 1);
        isBuy = new bool[](path.length - 1);
        amounts[amounts.length - 1] = amount;
        for (uint256 i = path.length - 1; i > 0; i--) {
            swaps[i - 1] = getSwap(path[i - 1], path[i]);
            require(address(swaps[i - 1]) != address(0), "Unknown swap");
            if (path[i] == swaps[i - 1].baseAddress()) {
                isBuy[i - 1] = true;
                amounts[i - 1] = swaps[i - 1].getQuoteIn(amounts[i]);
            } else {
                amounts[i - 1] = swaps[i - 1].getBaseIn(amounts[i]);
            }
        }
    }

    function _swap(
        uint256[] memory amounts,
        IStableSwap[] memory swaps,
        bool[] memory isBuy,
        uint256[] calldata versions,
        address recipient
    ) private {
        for (uint256 i = 0; i < swaps.length; i++) {
            address to = i < swaps.length - 1 ? address(swaps[i + 1]) : recipient;
            if (!isBuy[i]) {
                swaps[i].sell(versions[i], amounts[i + 1], to, new bytes(0));
            } else {
                swaps[i].buy(versions[i], amounts[i + 1], to, new bytes(0));
            }
        }
    }

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, "Transaction too old");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "../interfaces/IFundV3.sol";
import "../interfaces/IStableSwap.sol";

interface IPrimaryMarketRouter is IStableSwapCore {
    function create(
        address recipient,
        uint256 underlying,
        uint256 minOutQ,
        uint256 version
    ) external payable returns (uint256 outQ);

    function createAndStake(
        uint256 underlying,
        uint256 minOutQ,
        address staking,
        uint256 version
    ) external payable;

    function createSplitAndStake(
        uint256 underlying,
        uint256 minOutQ,
        address router,
        address quoteAddress,
        uint256 minLpOut,
        address staking,
        uint256 version
    ) external payable;

    function splitAndStake(
        uint256 inQ,
        address router,
        address quoteAddress,
        uint256 minLpOut,
        address staking,
        uint256 version
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./IStableSwap.sol";

interface ISwapRouter {
    function getSwap(address baseToken, address quoteToken) external view returns (IStableSwap);

    function getAmountsOut(uint256 amount, address[] memory path)
        external
        view
        returns (
            uint256[] memory amounts,
            IStableSwap[] memory swaps,
            bool[] memory isBuy
        );

    function getAmountsIn(uint256 amount, address[] memory path)
        external
        view
        returns (
            uint256[] memory amounts,
            IStableSwap[] memory swaps,
            bool[] memory isBuy
        );

    function addLiquidity(
        address baseToken,
        address quoteToken,
        uint256 baseDelta,
        uint256 quoteDelta,
        uint256 minMintAmount,
        uint256 version,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        address recipient,
        address staking,
        uint256[] calldata versions,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 maxAmountIn,
        address[] calldata path,
        address recipient,
        address staking,
        uint256[] calldata versions,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokensUnwrap(
        uint256 amountIn,
        uint256 minAmountOut,
        address[] calldata path,
        address recipient,
        uint256[] calldata versions,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokensUnwrap(
        uint256 amountOut,
        uint256 maxAmountIn,
        address[] calldata path,
        address recipient,
        uint256[] calldata versions,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "../interfaces/IFundV3.sol";

interface IStableSwapCore {
    function getQuoteOut(uint256 baseIn) external view returns (uint256 quoteOut);

    function getQuoteIn(uint256 baseOut) external view returns (uint256 quoteIn);

    function getBaseOut(uint256 quoteIn) external view returns (uint256 baseOut);

    function getBaseIn(uint256 quoteOut) external view returns (uint256 baseIn);

    function buy(
        uint256 version,
        uint256 baseOut,
        address recipient,
        bytes calldata data
    ) external returns (uint256 realBaseOut);

    function sell(
        uint256 version,
        uint256 quoteOut,
        address recipient,
        bytes calldata data
    ) external returns (uint256 realQuoteOut);
}

interface IStableSwap is IStableSwapCore {
    function fund() external view returns (IFundV3);

    function baseTranche() external view returns (uint256);

    function baseAddress() external view returns (address);

    function quoteAddress() external view returns (address);

    function allBalances() external view returns (uint256, uint256);

    function getOraclePrice() external view returns (uint256);

    function getCurrentD() external view returns (uint256);

    function getCurrentPriceOverOracle() external view returns (uint256);

    function getCurrentPrice() external view returns (uint256);

    function getPriceOverOracleIntegral() external view returns (uint256);

    function addLiquidity(uint256 version, address recipient) external returns (uint256);

    function removeLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut,
        uint256 minQuoteOut
    ) external returns (uint256 baseOut, uint256 quoteOut);

    function removeLiquidityUnwrap(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut,
        uint256 minQuoteOut
    ) external returns (uint256 baseOut, uint256 quoteOut);

    function removeBaseLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minBaseOut
    ) external returns (uint256 baseOut);

    function removeQuoteLiquidity(
        uint256 version,
        uint256 lpIn,
        uint256 minQuoteOut
    ) external returns (uint256 quoteOut);

    function removeQuoteLiquidityUnwrap(
        uint256 version,
        uint256 lpIn,
        uint256 minQuoteOut
    ) external returns (uint256 quoteOut);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface ILiquidityGauge is IERC20 {
    function mint(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function workingSupply() external view returns (uint256);

    function workingBalanceOf(address account) external view returns (uint256);

    function claimableRewards(address account)
        external
        returns (
            uint256 chessAmount,
            uint256 bonusAmount,
            uint256 amountQ,
            uint256 amountB,
            uint256 amountR,
            uint256 quoteAmount
        );

    function claimRewards(address account) external;

    function distribute(
        uint256 amountQ,
        uint256 amountB,
        uint256 amountR,
        uint256 quoteAmount,
        uint256 version
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

interface ITranchessSwapCallee {
    function tranchessSwapCallback(
        uint256 baseDeltaOut,
        uint256 quoteDeltaOut,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

library AdvancedMath {
    /// @dev Calculate square root.
    ///
    ///      Reference: https://en.wikipedia.org/wiki/Integer_square_root#Algorithm_using_Newton's_method
    function sqrt(uint256 s) internal pure returns (uint256) {
        if (s == 0) return 0;
        uint256 t = s;
        uint256 x0 = 2;
        if (t >= 1 << 128) {
            t >>= 128;
            x0 <<= 64;
        }
        if (t >= 1 << 64) {
            t >>= 64;
            x0 <<= 32;
        }
        if (t >= 1 << 32) {
            t >>= 32;
            x0 <<= 16;
        }
        if (t >= 1 << 16) {
            t >>= 16;
            x0 <<= 8;
        }
        if (t >= 1 << 8) {
            t >>= 8;
            x0 <<= 4;
        }
        if (t >= 1 << 4) {
            t >>= 4;
            x0 <<= 2;
        }
        if (t >= 1 << 2) {
            x0 <<= 1;
        }
        uint256 x1 = (x0 + s / x0) >> 1;
        while (x1 < x0) {
            x0 = x1;
            x1 = (x0 + s / x0) >> 1;
        }
        return x0;
    }

    /// @notice Calculate cubic root.
    function cbrt(uint256 s) internal pure returns (uint256) {
        if (s == 0) return 0;
        uint256 t = s;
        uint256 x0 = 2;
        if (t >= 1 << 192) {
            t >>= 192;
            x0 <<= 64;
        }
        if (t >= 1 << 96) {
            t >>= 96;
            x0 <<= 32;
        }
        if (t >= 1 << 48) {
            t >>= 48;
            x0 <<= 16;
        }
        if (t >= 1 << 24) {
            t >>= 24;
            x0 <<= 8;
        }
        if (t >= 1 << 12) {
            t >>= 12;
            x0 <<= 4;
        }
        if (t >= 1 << 6) {
            t >>= 6;
            x0 <<= 2;
        }
        if (t >= 1 << 3) {
            x0 <<= 1;
        }
        uint256 x1 = (2 * x0 + s / x0 / x0) / 3;
        while (x1 < x0) {
            x0 = x1;
            x1 = (2 * x0 + s / x0 / x0) / 3;
        }
        return x0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import {IVotingEscrowCallback} from "../governance/VotingEscrowV2.sol";

interface IClaimRewards {
    function claimRewards(address account) external;

    function claimRewardsAndUnwrap(address account) external;
}

contract BatchOperationHelper {
    string public constant VERSION = "2.0.0";

    function batchClaimRewards(address[] calldata contracts, address account) public {
        uint256 count = contracts.length;
        for (uint256 i = 0; i < count; i++) {
            IClaimRewards(contracts[i]).claimRewards(account);
        }
    }

    function batchClaimRewardsAndUnwrap(
        address[] calldata contracts,
        address[] calldata wrappedContracts,
        address account
    ) external {
        batchClaimRewards(contracts, account);
        uint256 count = wrappedContracts.length;
        for (uint256 i = 0; i < count; i++) {
            IClaimRewards(wrappedContracts[i]).claimRewardsAndUnwrap(account);
        }
    }

    function batchSyncWithVotingEscrow(address[] calldata contracts, address account) external {
        uint256 count = contracts.length;
        for (uint256 i = 0; i < count; i++) {
            IVotingEscrowCallback(contracts[i]).syncWithVotingEscrow(account);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/ProxyUtility.sol";

import {Order, OrderQueue, LibOrderQueue} from "./LibOrderQueue.sol";
import {
    UnsettledBuyTrade,
    UnsettledSellTrade,
    UnsettledTrade,
    LibUnsettledBuyTrade,
    LibUnsettledSellTrade
} from "./LibUnsettledTrade.sol";

import "./ExchangeRoles.sol";
import "./StakingV3.sol";

/// @title Tranchess's Exchange Contract
/// @notice A decentralized exchange to match premium-discount orders and clear trades
/// @author Tranchess
contract ExchangeV3 is ExchangeRoles, StakingV3, ProxyUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[29] private _reservedSlots;

    using SafeDecimalMath for uint256;
    using LibOrderQueue for OrderQueue;
    using SafeERC20 for IERC20;
    using LibUnsettledBuyTrade for UnsettledBuyTrade;
    using LibUnsettledSellTrade for UnsettledSellTrade;

    /// @notice A maker bid order is placed.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to buy
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Amount of quote asset in the order, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    event BidOrderPlaced(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version,
        uint256 orderIndex
    );

    /// @notice A maker ask order is placed.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to sell
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Amount of base asset in the order
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    event AskOrderPlaced(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version,
        uint256 orderIndex
    );

    /// @notice A maker bid order is canceled.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Original amount of quote asset in the order, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    /// @param fillable Unfilled amount when the order is canceled, rounding precision to 18 for
    ///                 quote assets with precision other than 18 decimal places
    event BidOrderCanceled(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version,
        uint256 orderIndex,
        uint256 fillable
    );

    /// @notice A maker ask order is canceled.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to sell
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Original amount of base asset in the order
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    /// @param fillable Unfilled amount when the order is canceled
    event AskOrderCanceled(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version,
        uint256 orderIndex,
        uint256 fillable
    );

    /// @notice Matching result of a taker bid order.
    /// @param taker Account placing the order
    /// @param tranche Tranche of the share
    /// @param quoteAmount Matched amount of quote asset, rounding precision to 18 for quote assets
    ///                    with precision other than 18 decimal places
    /// @param version Rebalance version of this trade
    /// @param lastMatchedPDLevel Premium-discount level of the last matched maker order
    /// @param lastMatchedOrderIndex Index of the last matched maker order in its order queue
    /// @param lastMatchedBaseAmount Matched base asset amount of the last matched maker order
    event BuyTrade(
        address indexed taker,
        uint256 indexed tranche,
        uint256 quoteAmount,
        uint256 version,
        uint256 lastMatchedPDLevel,
        uint256 lastMatchedOrderIndex,
        uint256 lastMatchedBaseAmount
    );

    /// @notice Matching result of a taker ask order.
    /// @param taker Account placing the order
    /// @param tranche Tranche of the share
    /// @param baseAmount Matched amount of base asset
    /// @param version Rebalance version of this trade
    /// @param lastMatchedPDLevel Premium-discount level of the last matched maker order
    /// @param lastMatchedOrderIndex Index of the last matched maker order in its order queue
    /// @param lastMatchedQuoteAmount Matched quote asset amount of the last matched maker order,
    ///                               rounding precision to 18 for quote assets with precision
    ///                               other than 18 decimal places
    event SellTrade(
        address indexed taker,
        uint256 indexed tranche,
        uint256 baseAmount,
        uint256 version,
        uint256 lastMatchedPDLevel,
        uint256 lastMatchedOrderIndex,
        uint256 lastMatchedQuoteAmount
    );

    /// @notice Settlement of unsettled trades of maker orders.
    /// @param account Account placing the related maker orders
    /// @param epoch Epoch of the settled trades
    /// @param amountM Amount of Token M added to the account's available balance
    /// @param amountA Amount of Token A added to the account's available balance
    /// @param amountB Amount of Token B added to the account's available balance
    /// @param quoteAmount Amount of quote asset transfered to the account, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    event MakerSettled(
        address indexed account,
        uint256 epoch,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 quoteAmount
    );

    /// @notice Settlement of unsettled trades of taker orders.
    /// @param account Account placing the related taker orders
    /// @param epoch Epoch of the settled trades
    /// @param amountM Amount of Token M added to the account's available balance
    /// @param amountA Amount of Token A added to the account's available balance
    /// @param amountB Amount of Token B added to the account's available balance
    /// @param quoteAmount Amount of quote asset transfered to the account, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    event TakerSettled(
        address indexed account,
        uint256 epoch,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 quoteAmount
    );

    uint256 private constant EPOCH = 30 minutes; // An exchange epoch is 30 minutes long

    /// @dev Maker reserves 105% of Token M they want to trade, which would stop
    ///      losses for makers when the net asset values turn out volatile
    uint256 private constant MAKER_RESERVE_RATIO_M = 1.05e18;

    /// @dev Maker reserves 100.1% of Token A they want to trade, which would stop
    ///      losses for makers when the net asset values turn out volatile
    uint256 private constant MAKER_RESERVE_RATIO_A = 1.001e18;

    /// @dev Maker reserves 110% of Token B they want to trade, which would stop
    ///      losses for makers when the net asset values turn out volatile
    uint256 private constant MAKER_RESERVE_RATIO_B = 1.1e18;

    /// @dev Premium-discount level ranges from -10% to 10% with 0.25% as step size
    uint256 private constant PD_TICK = 0.0025e18;

    uint256 private constant MIN_PD = 0.9e18;
    uint256 private constant MAX_PD = 1.1e18;
    uint256 private constant PD_START = MIN_PD - PD_TICK;
    uint256 private constant PD_LEVEL_COUNT = (MAX_PD - MIN_PD) / PD_TICK + 1;

    /// @notice Minumum quote amount of maker bid orders with 18 decimal places
    uint256 public immutable minBidAmount;

    /// @notice Minumum base amount of maker ask orders
    uint256 public immutable minAskAmount;

    /// @notice Minumum base or quote amount of maker orders during guarded launch
    uint256 public immutable guardedLaunchMinOrderAmount;

    /// @dev A multipler that normalizes a quote asset balance to 18 decimal places.
    uint256 private immutable _quoteDecimalMultiplier;

    /// @notice Mapping of rebalance version => tranche => an array of order queues
    mapping(uint256 => mapping(uint256 => OrderQueue[PD_LEVEL_COUNT + 1])) public bids;
    mapping(uint256 => mapping(uint256 => OrderQueue[PD_LEVEL_COUNT + 1])) public asks;

    /// @notice Mapping of rebalance version => best bid premium-discount level of the three tranches.
    ///         Zero indicates that there is no bid order.
    mapping(uint256 => uint256[TRANCHE_COUNT]) public bestBids;

    /// @notice Mapping of rebalance version => best ask premium-discount level of the three tranches.
    ///         Zero or `PD_LEVEL_COUNT + 1` indicates that there is no ask order.
    mapping(uint256 => uint256[TRANCHE_COUNT]) public bestAsks;

    /// @notice Mapping of account => tranche => epoch => unsettled trade
    mapping(address => mapping(uint256 => mapping(uint256 => UnsettledTrade)))
        public unsettledTrades;

    /// @dev Mapping of epoch => rebalance version
    mapping(uint256 => uint256) private _epochVersions;

    /// @dev The `makerRequirement_` param is removed to workaround a stack-too-deep error.
    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 quoteDecimals_,
        address votingEscrow_,
        uint256 minBidAmount_,
        uint256 minAskAmount_,
        uint256 guardedLaunchStart_,
        uint256 guardedLaunchMinOrderAmount_,
        address upgradeTool_
    )
        public
        ExchangeRoles(votingEscrow_, 0)
        StakingV3(
            fund_,
            chessSchedule_,
            chessController_,
            quoteAssetAddress_,
            guardedLaunchStart_,
            votingEscrow_,
            upgradeTool_
        )
    {
        minBidAmount = minBidAmount_;
        minAskAmount = minAskAmount_;
        guardedLaunchMinOrderAmount = guardedLaunchMinOrderAmount_;
        require(quoteDecimals_ <= 18, "Quote asset decimals larger than 18");
        _quoteDecimalMultiplier = 10**(18 - quoteDecimals_);
    }

    /// @dev Initialize the contract. The contract is designed to be used with OpenZeppelin's
    ///      `TransparentUpgradeableProxy`. This function should be called by the proxy's
    ///      constructor (via the `_data` argument).
    function initialize() external {
        _initializeStaking();
        _initializeV2(msg.sender);
    }

    /// @dev Initialize the part added in V2. If this contract is upgraded from the previous
    ///      version, call `upgradeToAndCall` of the proxy and put a call to this function
    ///      in the `data` argument.
    function initializeV2(address pauser_) external onlyProxyAdmin {
        _initializeV2(pauser_);
    }

    function _initializeV2(address pauser_) private {
        _initializeStakingV2(pauser_);
    }

    /// @notice Return end timestamp of the epoch containing a given timestamp.
    /// @param timestamp Timestamp within a given epoch
    /// @return The closest ending timestamp
    function endOfEpoch(uint256 timestamp) public pure returns (uint256) {
        return (timestamp / EPOCH) * EPOCH + EPOCH;
    }

    function getMakerReserveRatio(uint256 tranche) public pure returns (uint256) {
        if (tranche == TRANCHE_M) {
            return MAKER_RESERVE_RATIO_M;
        } else if (tranche == TRANCHE_A) {
            return MAKER_RESERVE_RATIO_A;
        } else {
            return MAKER_RESERVE_RATIO_B;
        }
    }

    function getBidOrder(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    )
        external
        view
        returns (
            address maker,
            uint256 amount,
            uint256 fillable
        )
    {
        Order storage order = bids[version][tranche][pdLevel].list[index];
        maker = order.maker;
        amount = order.amount;
        fillable = order.fillable;
    }

    function getAskOrder(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    )
        external
        view
        returns (
            address maker,
            uint256 amount,
            uint256 fillable
        )
    {
        Order storage order = asks[version][tranche][pdLevel].list[index];
        maker = order.maker;
        amount = order.amount;
        fillable = order.fillable;
    }

    /// @notice Get all tranches' net asset values of a given time
    /// @param timestamp Timestamp of the net asset value
    /// @return estimatedNavM Token M's net asset value
    /// @return estimatedNavA Token A's net asset value
    /// @return estimatedNavB Token B's net asset value
    function estimateNavs(uint256 timestamp)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 price = fund.twapOracle().getTwap(timestamp);
        require(price != 0, "Price is not available");
        return fund.extrapolateNav(timestamp, price);
    }

    /// @notice Place a bid order for makers
    /// @param tranche Tranche of the base asset
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Quote asset amount with 18 decimal places
    /// @param version Current rebalance version. Revert if it is not the latest version.
    function placeBid(
        uint256 tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version
    ) external onlyMaker whenNotPaused beforeProtocolUpgrade {
        require(block.timestamp >= guardedLaunchStart + 8 days, "Guarded launch: market closed");
        if (block.timestamp < guardedLaunchStart + 4 weeks) {
            require(quoteAmount >= guardedLaunchMinOrderAmount, "Guarded launch: amount too low");
        } else {
            require(quoteAmount >= minBidAmount, "Quote amount too low");
        }
        uint256 bestAsk = bestAsks[version][tranche];
        require(
            pdLevel > 0 && pdLevel < (bestAsk == 0 ? PD_LEVEL_COUNT + 1 : bestAsk),
            "Invalid premium-discount level"
        );
        require(version == _fundRebalanceSize(), "Invalid version");

        uint256 index = bids[version][tranche][pdLevel].append(msg.sender, quoteAmount, version);
        if (bestBids[version][tranche] < pdLevel) {
            bestBids[version][tranche] = pdLevel;
        }

        _transferQuoteFrom(msg.sender, quoteAmount);

        emit BidOrderPlaced(msg.sender, tranche, pdLevel, quoteAmount, version, index);
    }

    /// @notice Place an ask order for makers
    /// @param tranche Tranche of the base asset
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Base asset amount
    /// @param version Current rebalance version. Revert if it is not the latest version.
    function placeAsk(
        uint256 tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version
    ) external onlyMaker whenNotPaused beforeProtocolUpgrade {
        require(block.timestamp >= guardedLaunchStart + 8 days, "Guarded launch: market closed");
        if (block.timestamp < guardedLaunchStart + 4 weeks) {
            require(baseAmount >= guardedLaunchMinOrderAmount, "Guarded launch: amount too low");
        } else {
            require(baseAmount >= minAskAmount, "Base amount too low");
        }
        require(
            pdLevel > bestBids[version][tranche] && pdLevel <= PD_LEVEL_COUNT,
            "Invalid premium-discount level"
        );
        require(version == _fundRebalanceSize(), "Invalid version");

        _lock(tranche, msg.sender, baseAmount);
        uint256 index = asks[version][tranche][pdLevel].append(msg.sender, baseAmount, version);
        uint256 oldBestAsk = bestAsks[version][tranche];
        if (oldBestAsk > pdLevel || oldBestAsk == 0) {
            bestAsks[version][tranche] = pdLevel;
        }

        emit AskOrderPlaced(msg.sender, tranche, pdLevel, baseAmount, version, index);
    }

    /// @notice Cancel a bid order
    /// @param version Order's rebalance version
    /// @param tranche Tranche of the order's base asset
    /// @param pdLevel Order's premium-discount level
    /// @param index Order's index in the order queue
    function cancelBid(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    ) external whenNotPaused returns (uint256 fillable) {
        OrderQueue storage orderQueue = bids[version][tranche][pdLevel];
        Order storage order = orderQueue.list[index];
        address maker = order.maker;
        // Bid orders can be canceled by anyone after the upgrade
        if (block.timestamp < upgradeTimestamp) {
            require(maker == msg.sender, "Maker address mismatched");
        } else {
            require(maker != address(0), "Maker address mismatched");
        }

        fillable = order.fillable;
        emit BidOrderCanceled(maker, tranche, pdLevel, order.amount, version, index, fillable);
        orderQueue.cancel(index);

        // Update bestBid
        if (bestBids[version][tranche] == pdLevel) {
            uint256 newBestBid = pdLevel;
            while (newBestBid > 0 && bids[version][tranche][newBestBid].isEmpty()) {
                newBestBid--;
            }
            bestBids[version][tranche] = newBestBid;
        }

        _transferQuote(maker, fillable);
    }

    /// @notice Cancel an ask order
    /// @param version Order's rebalance version
    /// @param tranche Tranche of the order's base asset
    /// @param pdLevel Order's premium-discount level
    /// @param index Order's index in the order queue
    function cancelAsk(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    ) external whenNotPaused beforeProtocolUpgrade {
        OrderQueue storage orderQueue = asks[version][tranche][pdLevel];
        Order storage order = orderQueue.list[index];
        require(order.maker == msg.sender, "Maker address mismatched");

        uint256 fillable = order.fillable;
        emit AskOrderCanceled(msg.sender, tranche, pdLevel, order.amount, version, index, fillable);
        orderQueue.cancel(index);

        // Update bestAsk
        if (bestAsks[version][tranche] == pdLevel) {
            uint256 newBestAsk = pdLevel;
            while (newBestAsk <= PD_LEVEL_COUNT && asks[version][tranche][newBestAsk].isEmpty()) {
                newBestAsk++;
            }
            bestAsks[version][tranche] = newBestAsk;
        }

        if (tranche == TRANCHE_M) {
            _rebalanceAndUnlock(msg.sender, fillable, 0, 0, version);
        } else if (tranche == TRANCHE_A) {
            _rebalanceAndUnlock(msg.sender, 0, fillable, 0, version);
        } else {
            _rebalanceAndUnlock(msg.sender, 0, 0, fillable, version);
        }
    }

    /// @notice Buy Token M
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyM(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (uint256 estimatedNav, , ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_M, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Buy Token A
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyA(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (, uint256 estimatedNav, ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_A, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Buy Token B
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyB(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (, , uint256 estimatedNav) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_B, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Sell Token M
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token M willing to trade
    function sellM(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (uint256 estimatedNav, , ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_M, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Sell Token A
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token A willing to trade
    function sellA(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (, uint256 estimatedNav, ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_A, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Sell Token B
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token B willing to trade
    function sellB(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (, , uint256 estimatedNav) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_B, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Settle trades of a specified epoch for makers
    /// @param account Address of the maker
    /// @param epoch A specified epoch's end timestamp
    /// @return amountM Token M amount added to msg.sender's available balance
    /// @return amountA Token A amount added to msg.sender's available balance
    /// @return amountB Token B amount added to msg.sender's available balance
    /// @return quoteAmount Quote asset amount transfered to msg.sender, rounding precison to 18
    ///                     for quote assets with precision other than 18 decimal places
    function settleMaker(address account, uint256 epoch)
        external
        whenNotPaused
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 quoteAmount
        )
    {
        (uint256 estimatedNavM, uint256 estimatedNavA, uint256 estimatedNavB) =
            estimateNavs(epoch.add(EPOCH));

        uint256 quoteAmountM;
        uint256 quoteAmountA;
        uint256 quoteAmountB;
        (amountM, quoteAmountM) = _settleMaker(account, TRANCHE_M, estimatedNavM, epoch);
        (amountA, quoteAmountA) = _settleMaker(account, TRANCHE_A, estimatedNavA, epoch);
        (amountB, quoteAmountB) = _settleMaker(account, TRANCHE_B, estimatedNavB, epoch);

        uint256 version = _epochVersions[epoch];
        (amountM, amountA, amountB) = _rebalanceAndClearTrade(
            account,
            amountM,
            amountA,
            amountB,
            version
        );
        quoteAmount = quoteAmountM.add(quoteAmountA).add(quoteAmountB);
        _transferQuote(account, quoteAmount);

        emit MakerSettled(account, epoch, amountM, amountA, amountB, quoteAmount);
    }

    /// @notice Settle trades of a specified epoch for takers
    /// @param account Address of the maker
    /// @param epoch A specified epoch's end timestamp
    /// @return amountM Token M amount added to msg.sender's available balance
    /// @return amountA Token A amount added to msg.sender's available balance
    /// @return amountB Token B amount added to msg.sender's available balance
    /// @return quoteAmount Quote asset amount transfered to msg.sender, rounding precison to 18
    ///                     for quote assets with precision other than 18 decimal places
    function settleTaker(address account, uint256 epoch)
        external
        whenNotPaused
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 quoteAmount
        )
    {
        (uint256 estimatedNavM, uint256 estimatedNavA, uint256 estimatedNavB) =
            estimateNavs(epoch.add(EPOCH));

        uint256 quoteAmountM;
        uint256 quoteAmountA;
        uint256 quoteAmountB;
        (amountM, quoteAmountM) = _settleTaker(account, TRANCHE_M, estimatedNavM, epoch);
        (amountA, quoteAmountA) = _settleTaker(account, TRANCHE_A, estimatedNavA, epoch);
        (amountB, quoteAmountB) = _settleTaker(account, TRANCHE_B, estimatedNavB, epoch);

        uint256 version = _epochVersions[epoch];
        (amountM, amountA, amountB) = _rebalanceAndClearTrade(
            account,
            amountM,
            amountA,
            amountB,
            version
        );
        quoteAmount = quoteAmountM.add(quoteAmountA).add(quoteAmountB);
        _transferQuote(account, quoteAmount);

        emit TakerSettled(account, epoch, amountM, amountA, amountB, quoteAmount);
    }

    /// @dev Buy share
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param tranche Tranche of the base asset
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param estimatedNav Estimated net asset value of the base asset
    /// @param quoteAmount Amount of quote assets willing to trade with 18 decimal places
    function _buy(
        uint256 version,
        uint256 tranche,
        uint256 maxPDLevel,
        uint256 estimatedNav,
        uint256 quoteAmount
    ) internal onlyActive whenNotPaused beforeProtocolUpgrade {
        require(maxPDLevel > 0 && maxPDLevel <= PD_LEVEL_COUNT, "Invalid premium-discount level");
        require(version == _fundRebalanceSize(), "Invalid version");
        require(estimatedNav > 0, "Zero estimated NAV");

        UnsettledBuyTrade memory totalTrade;
        uint256 epoch = endOfEpoch(block.timestamp);

        // Record rebalance version in the first transaction in the epoch
        if (_epochVersions[epoch] == 0) {
            _epochVersions[epoch] = version;
        }

        UnsettledBuyTrade memory currentTrade;
        uint256 orderIndex = 0;
        uint256 pdLevel = bestAsks[version][tranche];
        if (pdLevel == 0) {
            // Zero best ask indicates that no ask order is ever placed.
            // We set pdLevel beyond the largest valid level, forcing the following loop
            // to exit immediately.
            pdLevel = PD_LEVEL_COUNT + 1;
        }
        for (; pdLevel <= maxPDLevel; pdLevel++) {
            uint256 price = pdLevel.mul(PD_TICK).add(PD_START).multiplyDecimal(estimatedNav);
            OrderQueue storage orderQueue = asks[version][tranche][pdLevel];
            orderIndex = orderQueue.head;
            while (orderIndex != 0) {
                Order storage order = orderQueue.list[orderIndex];

                // If the order initiator is no longer qualified for maker,
                // we skip the order and the linked-list-based order queue
                // would never traverse the order again
                if (!isMaker(order.maker)) {
                    orderIndex = order.next;
                    continue;
                }

                // Scope to avoid "stack too deep"
                {
                    // Calculate the current trade assuming that the taker would be completely filled.
                    uint256 makerReserveRatio = getMakerReserveRatio(tranche);
                    currentTrade.frozenQuote = quoteAmount.sub(totalTrade.frozenQuote);
                    currentTrade.reservedBase = currentTrade.frozenQuote.mul(makerReserveRatio).div(
                        price
                    );

                    if (currentTrade.reservedBase < order.fillable) {
                        // Taker is completely filled.
                        currentTrade.effectiveQuote = currentTrade.frozenQuote.divideDecimal(
                            pdLevel.mul(PD_TICK).add(PD_START)
                        );
                    } else {
                        // Maker is completely filled. Recalculate the current trade.
                        currentTrade.frozenQuote = order.fillable.mul(price).div(makerReserveRatio);
                        currentTrade.effectiveQuote = order.fillable.mul(estimatedNav).div(
                            makerReserveRatio
                        );
                        currentTrade.reservedBase = order.fillable;
                    }
                }
                totalTrade.frozenQuote = totalTrade.frozenQuote.add(currentTrade.frozenQuote);
                totalTrade.effectiveQuote = totalTrade.effectiveQuote.add(
                    currentTrade.effectiveQuote
                );
                totalTrade.reservedBase = totalTrade.reservedBase.add(currentTrade.reservedBase);
                unsettledTrades[order.maker][tranche][epoch].makerSell.add(currentTrade);

                // There is no need to rebalance for maker; the fact that the order could
                // be filled here indicates that the maker is in the latest version
                _tradeLocked(tranche, order.maker, currentTrade.reservedBase);

                uint256 orderNewFillable = order.fillable.sub(currentTrade.reservedBase);
                if (orderNewFillable > 0) {
                    // Maker is not completely filled. Matching ends here.
                    order.fillable = orderNewFillable;
                    break;
                } else {
                    // Delete the completely filled maker order.
                    orderIndex = orderQueue.fill(orderIndex);
                }
            }

            orderQueue.updateHead(orderIndex);
            if (orderIndex != 0) {
                // This premium-discount level is not completely filled. Matching ends here.
                if (bestAsks[version][tranche] != pdLevel) {
                    bestAsks[version][tranche] = pdLevel;
                }
                break;
            }
        }
        emit BuyTrade(
            msg.sender,
            tranche,
            totalTrade.frozenQuote,
            version,
            pdLevel,
            orderIndex,
            orderIndex == 0 ? 0 : currentTrade.reservedBase
        );
        if (orderIndex == 0) {
            // Matching ends by completely filling all orders at and below the specified
            // premium-discount level `maxPDLevel`.
            // Find the new best ask beyond that level.
            for (; pdLevel <= PD_LEVEL_COUNT; pdLevel++) {
                if (!asks[version][tranche][pdLevel].isEmpty()) {
                    break;
                }
            }
            bestAsks[version][tranche] = pdLevel;
        }

        require(
            totalTrade.frozenQuote > 0,
            "Nothing can be bought at the given premium-discount level"
        );
        unsettledTrades[msg.sender][tranche][epoch].takerBuy.add(totalTrade);
        _transferQuoteFrom(msg.sender, totalTrade.frozenQuote);
    }

    /// @dev Sell share
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param tranche Tranche of the base asset
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param estimatedNav Estimated net asset value of the base asset
    /// @param baseAmount Amount of base assets willing to trade
    function _sell(
        uint256 version,
        uint256 tranche,
        uint256 minPDLevel,
        uint256 estimatedNav,
        uint256 baseAmount
    ) internal onlyActive whenNotPaused beforeProtocolUpgrade {
        require(minPDLevel > 0 && minPDLevel <= PD_LEVEL_COUNT, "Invalid premium-discount level");
        require(version == _fundRebalanceSize(), "Invalid version");
        require(estimatedNav > 0, "Zero estimated NAV");

        UnsettledSellTrade memory totalTrade;
        uint256 epoch = endOfEpoch(block.timestamp);

        // Record rebalance version in the first transaction in the epoch
        if (_epochVersions[epoch] == 0) {
            _epochVersions[epoch] = version;
        }

        UnsettledSellTrade memory currentTrade;
        uint256 orderIndex;
        uint256 pdLevel = bestBids[version][tranche];
        for (; pdLevel >= minPDLevel; pdLevel--) {
            uint256 price = pdLevel.mul(PD_TICK).add(PD_START).multiplyDecimal(estimatedNav);
            OrderQueue storage orderQueue = bids[version][tranche][pdLevel];
            orderIndex = orderQueue.head;
            while (orderIndex != 0) {
                Order storage order = orderQueue.list[orderIndex];

                // If the order initiator is no longer qualified for maker,
                // we skip the order and the linked-list-based order queue
                // would never traverse the order again
                if (!isMaker(order.maker)) {
                    orderIndex = order.next;
                    continue;
                }

                // Scope to avoid "stack too deep"
                {
                    // Calculate the current trade assuming that the taker would be completely filled.
                    uint256 makerReserveRatio = getMakerReserveRatio(tranche);
                    currentTrade.frozenBase = baseAmount.sub(totalTrade.frozenBase);
                    currentTrade.reservedQuote = currentTrade
                        .frozenBase
                        .multiplyDecimal(makerReserveRatio)
                        .multiplyDecimal(price);

                    if (currentTrade.reservedQuote < order.fillable) {
                        // Taker is completely filled
                        currentTrade.effectiveBase = currentTrade.frozenBase.multiplyDecimal(
                            pdLevel.mul(PD_TICK).add(PD_START)
                        );
                    } else {
                        // Maker is completely filled. Recalculate the current trade.
                        currentTrade.frozenBase = order.fillable.divideDecimal(price).divideDecimal(
                            makerReserveRatio
                        );
                        currentTrade.effectiveBase = order
                            .fillable
                            .divideDecimal(estimatedNav)
                            .divideDecimal(makerReserveRatio);
                        currentTrade.reservedQuote = order.fillable;
                    }
                }
                totalTrade.frozenBase = totalTrade.frozenBase.add(currentTrade.frozenBase);
                totalTrade.effectiveBase = totalTrade.effectiveBase.add(currentTrade.effectiveBase);
                totalTrade.reservedQuote = totalTrade.reservedQuote.add(currentTrade.reservedQuote);
                unsettledTrades[order.maker][tranche][epoch].makerBuy.add(currentTrade);

                uint256 orderNewFillable = order.fillable.sub(currentTrade.reservedQuote);
                if (orderNewFillable > 0) {
                    // Maker is not completely filled. Matching ends here.
                    order.fillable = orderNewFillable;
                    break;
                } else {
                    // Delete the completely filled maker order.
                    orderIndex = orderQueue.fill(orderIndex);
                }
            }

            orderQueue.updateHead(orderIndex);
            if (orderIndex != 0) {
                // This premium-discount level is not completely filled. Matching ends here.
                if (bestBids[version][tranche] != pdLevel) {
                    bestBids[version][tranche] = pdLevel;
                }
                break;
            }
        }
        emit SellTrade(
            msg.sender,
            tranche,
            totalTrade.frozenBase,
            version,
            pdLevel,
            orderIndex,
            orderIndex == 0 ? 0 : currentTrade.reservedQuote
        );
        if (orderIndex == 0) {
            // Matching ends by completely filling all orders at and above the specified
            // premium-discount level `minPDLevel`.
            // Find the new best bid beyond that level.
            for (; pdLevel > 0; pdLevel--) {
                if (!bids[version][tranche][pdLevel].isEmpty()) {
                    break;
                }
            }
            bestBids[version][tranche] = pdLevel;
        }

        require(
            totalTrade.frozenBase > 0,
            "Nothing can be sold at the given premium-discount level"
        );
        _tradeAvailable(tranche, msg.sender, totalTrade.frozenBase);
        unsettledTrades[msg.sender][tranche][epoch].takerSell.add(totalTrade);
    }

    /// @dev Settle both buy and sell trades of a specified epoch for takers
    /// @param account Taker address
    /// @param tranche Tranche of the base asset
    /// @param estimatedNav Estimated net asset value for the base asset
    /// @param epoch The epoch's end timestamp
    function _settleTaker(
        address account,
        uint256 tranche,
        uint256 estimatedNav,
        uint256 epoch
    ) internal returns (uint256 baseAmount, uint256 quoteAmount) {
        UnsettledTrade storage unsettledTrade = unsettledTrades[account][tranche][epoch];

        // Settle buy trade
        UnsettledBuyTrade memory takerBuy = unsettledTrade.takerBuy;
        if (takerBuy.frozenQuote > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _buyTradeResult(takerBuy, estimatedNav);
            baseAmount = executionBase;
            quoteAmount = takerBuy.frozenQuote.sub(executionQuote);
            delete unsettledTrade.takerBuy;
        }

        // Settle sell trade
        UnsettledSellTrade memory takerSell = unsettledTrade.takerSell;
        if (takerSell.frozenBase > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _sellTradeResult(takerSell, estimatedNav);
            quoteAmount = quoteAmount.add(executionQuote);
            baseAmount = baseAmount.add(takerSell.frozenBase.sub(executionBase));
            delete unsettledTrade.takerSell;
        }
    }

    /// @dev Settle both buy and sell trades of a specified epoch for makers
    /// @param account Maker address
    /// @param tranche Tranche of the base asset
    /// @param estimatedNav Estimated net asset value for the base asset
    /// @param epoch The epoch's end timestamp
    function _settleMaker(
        address account,
        uint256 tranche,
        uint256 estimatedNav,
        uint256 epoch
    ) internal returns (uint256 baseAmount, uint256 quoteAmount) {
        UnsettledTrade storage unsettledTrade = unsettledTrades[account][tranche][epoch];

        // Settle buy trade
        UnsettledSellTrade memory makerBuy = unsettledTrade.makerBuy;
        if (makerBuy.frozenBase > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _sellTradeResult(makerBuy, estimatedNav);
            baseAmount = executionBase;
            quoteAmount = makerBuy.reservedQuote.sub(executionQuote);
            delete unsettledTrade.makerBuy;
        }

        // Settle sell trade
        UnsettledBuyTrade memory makerSell = unsettledTrade.makerSell;
        if (makerSell.frozenQuote > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _buyTradeResult(makerSell, estimatedNav);
            quoteAmount = quoteAmount.add(executionQuote);
            baseAmount = baseAmount.add(makerSell.reservedBase.sub(executionBase));
            delete unsettledTrade.makerSell;
        }
    }

    /// @dev Calculate the result of an unsettled buy trade with a given NAV
    /// @param buyTrade Buy trade result of this particular epoch
    /// @param nav Net asset value for the base asset
    /// @return executionQuote Real amount of quote asset waiting for settlment
    /// @return executionBase Real amount of base asset waiting for settlment
    function _buyTradeResult(UnsettledBuyTrade memory buyTrade, uint256 nav)
        internal
        pure
        returns (uint256 executionQuote, uint256 executionBase)
    {
        uint256 reservedBase = buyTrade.reservedBase;
        uint256 reservedQuote = reservedBase.multiplyDecimal(nav);
        uint256 effectiveQuote = buyTrade.effectiveQuote;
        if (effectiveQuote < reservedQuote) {
            // Reserved base is enough to execute the trade.
            // nav is always positive here
            return (buyTrade.frozenQuote, effectiveQuote.divideDecimal(nav));
        } else {
            // Reserved base is not enough. The trade is partially executed
            // and a fraction of frozenQuote is returned to the taker.
            return (buyTrade.frozenQuote.mul(reservedQuote).div(effectiveQuote), reservedBase);
        }
    }

    /// @dev Calculate the result of an unsettled sell trade with a given NAV
    /// @param sellTrade Sell trade result of this particular epoch
    /// @param nav Net asset value for the base asset
    /// @return executionQuote Real amount of quote asset waiting for settlment
    /// @return executionBase Real amount of base asset waiting for settlment
    function _sellTradeResult(UnsettledSellTrade memory sellTrade, uint256 nav)
        internal
        pure
        returns (uint256 executionQuote, uint256 executionBase)
    {
        uint256 reservedQuote = sellTrade.reservedQuote;
        uint256 effectiveQuote = sellTrade.effectiveBase.multiplyDecimal(nav);
        if (effectiveQuote < reservedQuote) {
            // Reserved quote is enough to execute the trade.
            return (effectiveQuote, sellTrade.frozenBase);
        } else {
            // Reserved quote is not enough. The trade is partially executed
            // and a fraction of frozenBase is returned to the taker.
            return (reservedQuote, sellTrade.frozenBase.mul(reservedQuote).div(effectiveQuote));
        }
    }

    /// @dev Transfer quote asset to an account. Transfered amount is rounded down.
    /// @param account Recipient address
    /// @param amount Amount to transfer with 18 decimal places
    function _transferQuote(address account, uint256 amount) private {
        uint256 amountToTransfer = amount / _quoteDecimalMultiplier;
        if (amountToTransfer == 0) {
            return;
        }
        IERC20(quoteAssetAddress).safeTransfer(account, amountToTransfer);
    }

    /// @dev Transfer quote asset from an account. Transfered amount is rounded up.
    /// @param account Sender address
    /// @param amount Amount to transfer with 18 decimal places
    function _transferQuoteFrom(address account, uint256 amount) private {
        uint256 amountToTransfer =
            amount.add(_quoteDecimalMultiplier - 1) / _quoteDecimalMultiplier;
        IERC20(quoteAssetAddress).safeTransferFrom(account, address(this), amountToTransfer);
    }

    modifier onlyActive() {
        require(fund.isExchangeActive(block.timestamp), "Exchange is inactive");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/CoreUtility.sol";
import "../../utils/ManagedPausable.sol";

import "../interfaces/IFund.sol";
import "../../interfaces/IChessController.sol";
import "../../interfaces/IChessSchedule.sol";
import "../interfaces/ITrancheIndex.sol";
import "../interfaces/IPrimaryMarketV2.sol";
import "../../interfaces/IVotingEscrow.sol";

/// @notice Chess locking snapshot used in calculating working balance of an account.
/// @param veProportion The account's veCHESS divided by the total veCHESS supply.
/// @param veLocked Locked CHESS and unlock time, which is synchronized from VotingEscrow.
struct VESnapshot {
    uint256 veProportion;
    IVotingEscrow.LockedBalance veLocked;
}

interface IUpgradeTool {
    function upgradeTimestamp() external view returns (uint256);
}

abstract contract StakingV3 is ITrancheIndex, CoreUtility, ManagedPausable {
    /// @dev Reserved storage slots for future sibling contract upgrades
    uint256[29] private _reservedSlots;

    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event Deposited(uint256 tranche, address account, uint256 amount);
    event Withdrawn(uint256 tranche, address account, uint256 amount);

    uint256 private constant MAX_ITERATIONS = 500;

    uint256 private constant REWARD_WEIGHT_A = 4;
    uint256 private constant REWARD_WEIGHT_B = 2;
    uint256 private constant REWARD_WEIGHT_M = 3;
    uint256 private constant MAX_BOOSTING_FACTOR = 3e18;
    uint256 private constant MAX_BOOSTING_FACTOR_MINUS_ONE = MAX_BOOSTING_FACTOR - 1e18;

    /// @dev Maximum fraction of veCHESS that can be used to boost Token M.
    uint256 private constant MAX_BOOSTING_POWER_M = 0.5e18;

    IFund public immutable fund;
    IERC20 private immutable tokenM;
    IERC20 private immutable tokenA;
    IERC20 private immutable tokenB;

    /// @notice The Chess release schedule contract.
    IChessSchedule public immutable chessSchedule;

    uint256 public immutable guardedLaunchStart;

    address public immutable upgradeTool;

    uint256 public immutable upgradeTimestamp;

    uint256 private _rate;

    /// @notice The controller contract.
    IChessController public immutable chessController;

    /// @notice Quote asset for the exchange. Each exchange only handles one quote asset
    address public immutable quoteAssetAddress;

    /// @dev Total amount of user shares, i.e. sum of all entries in `_availableBalances` and
    ///      `_lockedBalances`. Note that these values can be smaller than the amount of
    ///      share tokens held by this contract, because shares locked in unsettled trades
    ///      are not included in total supplies or any user's balance.
    uint256[TRANCHE_COUNT] private _totalSupplies;

    /// @dev Rebalance version of `_totalSupplies`.
    uint256 private _totalSupplyVersion;

    /// @dev Amount of shares that can be withdrawn or traded by each user.
    mapping(address => uint256[TRANCHE_COUNT]) private _availableBalances;

    /// @dev Amount of shares that are locked in ask orders.
    mapping(address => uint256[TRANCHE_COUNT]) private _lockedBalances;

    /// @dev Rebalance version mapping for `_availableBalances`.
    mapping(address => uint256) private _balanceVersions;

    /// @dev 1e27 * ∫(rate(t) / totalWeight(t) dt) from the latest rebalance till checkpoint.
    uint256 private _invTotalWeightIntegral;

    /// @dev Final `_invTotalWeightIntegral` before each rebalance.
    ///      These values are accessed in a loop in `_userCheckpoint()` with bounds checking.
    ///      So we store them in a fixed-length array, in order to make compiler-generated
    ///      bounds checking on every access cheaper. The actual length of this array is stored in
    ///      `_historicalIntegralSize` and should be explicitly checked when necessary.
    uint256[65535] private _historicalIntegrals;

    /// @dev Actual length of the `_historicalIntegrals` array, which always equals to the number of
    ///      historical rebalances after `checkpoint()` is called.
    uint256 private _historicalIntegralSize;

    /// @dev Timestamp when checkpoint() is called.
    uint256 private _checkpointTimestamp;

    /// @dev Snapshot of `_invTotalWeightIntegral` per user.
    mapping(address => uint256) private _userIntegrals;

    /// @dev Mapping of account => claimable rewards.
    mapping(address => uint256) private _claimableRewards;

    IVotingEscrow private immutable _votingEscrow;
    uint256 private _workingSupply;
    mapping(address => uint256) private _workingBalances;
    mapping(address => VESnapshot) private _veSnapshots;

    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 guardedLaunchStart_,
        address votingEscrow_,
        address upgradeTool_
    ) public {
        fund = IFund(fund_);
        tokenM = IERC20(IFund(fund_).tokenM());
        tokenA = IERC20(IFund(fund_).tokenA());
        tokenB = IERC20(IFund(fund_).tokenB());
        chessSchedule = IChessSchedule(chessSchedule_);
        chessController = IChessController(chessController_);
        quoteAssetAddress = quoteAssetAddress_;
        guardedLaunchStart = guardedLaunchStart_;
        _votingEscrow = IVotingEscrow(votingEscrow_);
        upgradeTool = upgradeTool_;
        upgradeTimestamp = IUpgradeTool(upgradeTool_).upgradeTimestamp();
    }

    function _initializeStaking() internal {
        require(_checkpointTimestamp == 0);
        _checkpointTimestamp = block.timestamp;
        _rate = IChessSchedule(chessSchedule).getRate(block.timestamp);
    }

    function _initializeStakingV2(address pauser_) internal {
        _initializeManagedPausable(pauser_);
        // The contract was just upgraded from an old version without boosting
        _workingSupply = weightedBalance(
            _totalSupplies[TRANCHE_M],
            _totalSupplies[TRANCHE_A],
            _totalSupplies[TRANCHE_B]
        );
    }

    /// @notice Return weight of given balance with respect to rewards.
    /// @param amountM Amount of Token M
    /// @param amountA Amount of Token A
    /// @param amountB Amount of Token B
    /// @return Rewarding weight of the balance
    function weightedBalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB
    ) public pure returns (uint256) {
        return
            amountM.mul(REWARD_WEIGHT_M).add(amountA.mul(REWARD_WEIGHT_A)).add(
                amountB.mul(REWARD_WEIGHT_B)
            ) / REWARD_WEIGHT_M;
    }

    function totalSupply(uint256 tranche) external view returns (uint256) {
        uint256 totalSupplyM = _totalSupplies[TRANCHE_M];
        uint256 totalSupplyA = _totalSupplies[TRANCHE_A];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];

        uint256 version = _totalSupplyVersion;
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (totalSupplyM, totalSupplyA, totalSupplyB) = _fundBatchRebalance(
                totalSupplyM,
                totalSupplyA,
                totalSupplyB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return totalSupplyM;
        } else if (tranche == TRANCHE_A) {
            return totalSupplyA;
        } else {
            return totalSupplyB;
        }
    }

    function availableBalanceOf(uint256 tranche, address account) external view returns (uint256) {
        uint256 amountM = _availableBalances[account][TRANCHE_M];
        uint256 amountA = _availableBalances[account][TRANCHE_A];
        uint256 amountB = _availableBalances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    function lockedBalanceOf(uint256 tranche, address account) external view returns (uint256) {
        uint256 amountM = _lockedBalances[account][TRANCHE_M];
        uint256 amountA = _lockedBalances[account][TRANCHE_A];
        uint256 amountB = _lockedBalances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    function balanceVersion(address account) external view returns (uint256) {
        return _balanceVersions[account];
    }

    function workingSupply() external view returns (uint256) {
        uint256 version = _totalSupplyVersion;
        uint256 rebalanceSize = _fundRebalanceSize();
        if (version < rebalanceSize) {
            (uint256 totalSupplyM, uint256 totalSupplyA, uint256 totalSupplyB) =
                _fundBatchRebalance(
                    _totalSupplies[TRANCHE_M],
                    _totalSupplies[TRANCHE_A],
                    _totalSupplies[TRANCHE_B],
                    version,
                    rebalanceSize
                );
            return weightedBalance(totalSupplyM, totalSupplyA, totalSupplyB);
        } else {
            return _workingSupply;
        }
    }

    function workingBalanceOf(address account) external view returns (uint256) {
        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = _fundRebalanceSize();
        uint256 workingBalance = _workingBalances[account]; // gas saver
        if (version < rebalanceSize || workingBalance == 0) {
            uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
            uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
            uint256 amountM = available[TRANCHE_M].add(locked[TRANCHE_M]);
            uint256 amountA = available[TRANCHE_A].add(locked[TRANCHE_A]);
            uint256 amountB = available[TRANCHE_B].add(locked[TRANCHE_B]);
            if (version < rebalanceSize) {
                (amountM, amountA, amountB) = _fundBatchRebalance(
                    amountM,
                    amountA,
                    amountB,
                    version,
                    rebalanceSize
                );
            }
            return weightedBalance(amountM, amountA, amountB);
        } else {
            return workingBalance;
        }
    }

    function veSnapshotOf(address account) external view returns (VESnapshot memory) {
        return _veSnapshots[account];
    }

    function _fundRebalanceSize() internal view returns (uint256) {
        return fund.getRebalanceSize();
    }

    function _fundDoRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 index
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return fund.doRebalance(amountM, amountA, amountB, index);
    }

    function _fundBatchRebalance(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 fromIndex,
        uint256 toIndex
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return fund.batchRebalance(amountM, amountA, amountB, fromIndex, toIndex);
    }

    /// @dev Deposit to get rewards
    /// @param tranche Tranche of the share
    /// @param amount The amount to deposit
    function deposit(uint256 tranche, uint256 amount) public whenNotPaused beforeProtocolUpgrade {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(msg.sender, rebalanceSize);
        _availableBalances[msg.sender][tranche] = _availableBalances[msg.sender][tranche].add(
            amount
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].add(amount);
        _updateWorkingBalance(msg.sender);

        if (tranche == TRANCHE_M) {
            tokenM.safeTransferFrom(msg.sender, address(this), amount);
        } else if (tranche == TRANCHE_A) {
            tokenA.safeTransferFrom(msg.sender, address(this), amount);
        } else {
            tokenB.safeTransferFrom(msg.sender, address(this), amount);
        }

        emit Deposited(tranche, msg.sender, amount);
    }

    /// @dev Claim settled Token M from the primary market and deposit to get rewards
    /// @param primaryMarket The primary market to claim shares from
    function claimAndDeposit(address primaryMarket) external {
        (uint256 createdShares, ) = IPrimaryMarketV2(primaryMarket).claim(msg.sender);
        deposit(TRANCHE_M, createdShares);
    }

    function claimAndUnwrapAndDeposit(address primaryMarket) external {
        (uint256 createdShares, ) = IPrimaryMarketV2(primaryMarket).claimAndUnwrap(msg.sender);
        deposit(TRANCHE_M, createdShares);
    }

    /// @dev Withdraw
    /// @param tranche Tranche of the share
    /// @param amount The amount to deposit
    function withdraw(uint256 tranche, uint256 amount) external whenNotPaused {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(msg.sender, rebalanceSize);
        _availableBalances[msg.sender][tranche] = _availableBalances[msg.sender][tranche].sub(
            amount,
            "Insufficient balance to withdraw"
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        _updateWorkingBalance(msg.sender);

        if (tranche == TRANCHE_M) {
            tokenM.safeTransfer(msg.sender, amount);
        } else if (tranche == TRANCHE_A) {
            tokenA.safeTransfer(msg.sender, amount);
        } else {
            tokenB.safeTransfer(msg.sender, amount);
        }

        emit Withdrawn(tranche, msg.sender, amount);
    }

    /// @notice Transform share balance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshBalance(address account, uint256 targetVersion) external {
        uint256 rebalanceSize = _fundRebalanceSize();
        if (targetVersion == 0) {
            targetVersion = rebalanceSize;
        } else {
            require(targetVersion <= rebalanceSize, "Target version out of bound");
        }
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, targetVersion);
    }

    /// @notice Return claimable rewards of an account till now.
    ///
    ///         This function should be call as a "view" function off-chain to get
    ///         the return value, e.g. using `contract.claimableRewards.call(account)` in web3
    ///         or `contract.callStatic.claimableRewards(account)` in ethers.js.
    /// @param account Address of an account
    /// @return Amount of claimable rewards
    function claimableRewards(address account) external returns (uint256) {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        return _claimableRewards[account];
    }

    /// @notice Claim the rewards for an account.
    /// @param account Account to claim its rewards
    function claimRewards(address account) external whenNotPaused {
        require(
            block.timestamp >= guardedLaunchStart + 15 days,
            "Cannot claim during guarded launch"
        );
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _claim(account);
    }

    /// @notice Synchronize an account's locked Chess with `VotingEscrow`
    ///         and update its working balance.
    /// @param account Address of the synchronized account
    function syncWithVotingEscrow(address account) external {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);

        VESnapshot storage veSnapshot = _veSnapshots[account];
        IVotingEscrow.LockedBalance memory newLocked = _votingEscrow.getLockedBalance(account);
        if (
            newLocked.amount != veSnapshot.veLocked.amount ||
            newLocked.unlockTime != veSnapshot.veLocked.unlockTime ||
            newLocked.unlockTime < block.timestamp
        ) {
            veSnapshot.veLocked.amount = newLocked.amount;
            veSnapshot.veLocked.unlockTime = newLocked.unlockTime;
            veSnapshot.veProportion = _votingEscrow.balanceOf(account).divideDecimal(
                _votingEscrow.totalSupply()
            );
        }

        _updateWorkingBalance(account);
    }

    modifier beforeProtocolUpgrade() {
        require(block.timestamp < upgradeTimestamp, "Closed after upgrade");
        _;
    }

    /// @notice Upgrade to Tranchess V2. This can only be called from the upgrade tool.
    function protocolUpgrade(address account)
        external
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 claimedRewards
        )
    {
        require(msg.sender == upgradeTool, "Only upgrade tool");
        require(block.timestamp >= upgradeTimestamp, "Not ready for upgrade");
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);

        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        // These amounts of tokens will be burnt by the upgrade tool.
        amountM = available[TRANCHE_M].add(locked[TRANCHE_M]);
        amountA = available[TRANCHE_A].add(locked[TRANCHE_A]);
        amountB = available[TRANCHE_B].add(locked[TRANCHE_B]);
        if (amountM > 0) {
            available[TRANCHE_M] = 0;
            locked[TRANCHE_M] = 0;
            _totalSupplies[TRANCHE_M] = _totalSupplies[TRANCHE_M].sub(amountM);
        }
        if (amountA > 0) {
            available[TRANCHE_A] = 0;
            locked[TRANCHE_A] = 0;
            _totalSupplies[TRANCHE_A] = _totalSupplies[TRANCHE_A].sub(amountA);
        }
        if (amountB > 0) {
            available[TRANCHE_B] = 0;
            locked[TRANCHE_B] = 0;
            _totalSupplies[TRANCHE_B] = _totalSupplies[TRANCHE_B].sub(amountB);
        }
        _updateWorkingBalance(account);

        claimedRewards = _claim(account);
    }

    /// @dev Transfer shares from the sender to the contract internally
    /// @param tranche Tranche of the share
    /// @param sender Sender address
    /// @param amount The amount to transfer
    function _tradeAvailable(
        uint256 tranche,
        address sender,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(sender, rebalanceSize);
        _availableBalances[sender][tranche] = _availableBalances[sender][tranche].sub(amount);
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        _updateWorkingBalance(sender);
    }

    function _rebalanceAndClearTrade(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        if (amountVersion < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                amountVersion,
                rebalanceSize
            );
        }
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        if (amountM > 0) {
            available[TRANCHE_M] = available[TRANCHE_M].add(amountM);
            _totalSupplies[TRANCHE_M] = _totalSupplies[TRANCHE_M].add(amountM);
        }
        if (amountA > 0) {
            available[TRANCHE_A] = available[TRANCHE_A].add(amountA);
            _totalSupplies[TRANCHE_A] = _totalSupplies[TRANCHE_A].add(amountA);
        }
        if (amountB > 0) {
            available[TRANCHE_B] = available[TRANCHE_B].add(amountB);
            _totalSupplies[TRANCHE_B] = _totalSupplies[TRANCHE_B].add(amountB);
        }
        _updateWorkingBalance(account);

        return (amountM, amountA, amountB);
    }

    function _lock(
        uint256 tranche,
        address account,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _availableBalances[account][tranche] = _availableBalances[account][tranche].sub(
            amount,
            "Insufficient balance to lock"
        );
        _lockedBalances[account][tranche] = _lockedBalances[account][tranche].add(amount);
    }

    function _rebalanceAndUnlock(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        if (amountVersion < rebalanceSize) {
            (amountM, amountA, amountB) = _fundBatchRebalance(
                amountM,
                amountA,
                amountB,
                amountVersion,
                rebalanceSize
            );
        }
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        if (amountM > 0) {
            available[TRANCHE_M] = available[TRANCHE_M].add(amountM);
            locked[TRANCHE_M] = locked[TRANCHE_M].sub(amountM);
        }
        if (amountA > 0) {
            available[TRANCHE_A] = available[TRANCHE_A].add(amountA);
            locked[TRANCHE_A] = locked[TRANCHE_A].sub(amountA);
        }
        if (amountB > 0) {
            available[TRANCHE_B] = available[TRANCHE_B].add(amountB);
            locked[TRANCHE_B] = locked[TRANCHE_B].sub(amountB);
        }
    }

    function _tradeLocked(
        uint256 tranche,
        address account,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = _fundRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _lockedBalances[account][tranche] = _lockedBalances[account][tranche].sub(amount);
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        _updateWorkingBalance(account);
    }

    /// @dev Transfer claimable rewards to an account. Rewards since the last user checkpoint
    ///      is not included. This function should always be called after `_userCheckpoint()`,
    ///      in order for the user to get all rewards till now.
    /// @param account Address of the account
    function _claim(address account) internal returns (uint256 claimableReward) {
        claimableReward = _claimableRewards[account];
        _claimableRewards[account] = 0;
        chessSchedule.mint(account, claimableReward);
    }

    /// @dev Transform total supplies to the latest rebalance version and make a global reward checkpoint.
    /// @param rebalanceSize The number of existing rebalances. It must be the same as
    ///                       `fund.getRebalanceSize()`.
    function _checkpoint(uint256 rebalanceSize) private {
        uint256 timestamp = _checkpointTimestamp;
        if (timestamp >= block.timestamp) {
            return;
        }

        uint256 integral = _invTotalWeightIntegral;
        uint256 endWeek = _endOfWeek(timestamp);
        uint256 weeklyPercentage =
            chessController.getFundRelativeWeight(address(fund), endWeek - 1 weeks);
        uint256 version = _totalSupplyVersion;
        uint256 rebalanceTimestamp;
        if (version < rebalanceSize) {
            rebalanceTimestamp = fund.getRebalanceTimestamp(version);
        } else {
            rebalanceTimestamp = type(uint256).max;
        }
        uint256 rate = _rate;
        uint256 totalSupplyM = _totalSupplies[TRANCHE_M];
        uint256 totalSupplyA = _totalSupplies[TRANCHE_A];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];
        uint256 weight = _workingSupply;
        uint256 timestamp_ = timestamp; // avoid stack too deep

        for (uint256 i = 0; i < MAX_ITERATIONS && timestamp_ < block.timestamp; i++) {
            uint256 endTimestamp = rebalanceTimestamp.min(endWeek).min(block.timestamp);

            if (weight > 0) {
                integral = integral.add(
                    rate
                        .mul(endTimestamp.sub(timestamp_))
                        .multiplyDecimal(weeklyPercentage)
                        .divideDecimalPrecise(weight)
                );
            }

            if (endTimestamp == rebalanceTimestamp) {
                uint256 oldSize = _historicalIntegralSize;
                _historicalIntegrals[oldSize] = integral;
                _historicalIntegralSize = oldSize + 1;

                integral = 0;
                (totalSupplyM, totalSupplyA, totalSupplyB) = _fundDoRebalance(
                    totalSupplyM,
                    totalSupplyA,
                    totalSupplyB,
                    version
                );

                version++;
                // Reset total weight boosting after the first rebalance
                weight = weightedBalance(totalSupplyM, totalSupplyA, totalSupplyB);

                if (version < rebalanceSize) {
                    rebalanceTimestamp = fund.getRebalanceTimestamp(version);
                } else {
                    rebalanceTimestamp = type(uint256).max;
                }
            }
            if (endTimestamp == endWeek) {
                rate = chessSchedule.getRate(endWeek);
                weeklyPercentage = chessController.getFundRelativeWeight(address(fund), endWeek);
                endWeek += 1 weeks;
            }

            timestamp_ = endTimestamp;
        }

        _checkpointTimestamp = block.timestamp;
        _invTotalWeightIntegral = integral;
        if (_rate != rate) {
            _rate = rate;
        }
        if (_totalSupplyVersion != rebalanceSize) {
            _totalSupplies[TRANCHE_M] = totalSupplyM;
            _totalSupplies[TRANCHE_A] = totalSupplyA;
            _totalSupplies[TRANCHE_B] = totalSupplyB;
            _totalSupplyVersion = rebalanceSize;
            // Reset total working weight before any boosting if rebalance ever triggered
            _workingSupply = weight;
        }
    }

    /// @dev Transform a user's balance to a given rebalance version and update this user's rewards.
    ///
    ///      In most cases, the target version is the latest version and this function cumulates
    ///      rewards till now. When this function is called from `refreshBalance()`,
    ///      `targetVersion` can be an older version, in which case rewards are cumulated till
    ///      the end of that version (i.e. timestamp of the transaction triggering the rebalance
    ///      with index `targetVersion`).
    ///
    ///      This function should always be called after `_checkpoint()` is called, so that
    ///      the global reward checkpoint is guarenteed up to date.
    /// @param account Account to update
    /// @param targetVersion The target rebalance version
    function _userCheckpoint(address account, uint256 targetVersion) private {
        uint256 oldVersion = _balanceVersions[account];
        if (oldVersion > targetVersion) {
            return;
        }
        uint256 userIntegral = _userIntegrals[account];
        uint256 integral;
        // This scope is to avoid the "stack too deep" error.
        {
            // We assume that this function is always called immediately after `_checkpoint()`,
            // which guarantees that `_historicalIntegralSize` equals to the number of historical
            // rebalances.
            uint256 rebalanceSize = _historicalIntegralSize;
            integral = targetVersion == rebalanceSize
                ? _invTotalWeightIntegral
                : _historicalIntegrals[targetVersion];
        }
        if (userIntegral == integral && oldVersion == targetVersion) {
            // Return immediately when the user's rewards have already been updated to
            // the target version.
            return;
        }

        uint256 rewards = _claimableRewards[account];
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        uint256 weight = _workingBalances[account];
        if (weight == 0) {
            // Loading available and locked is repeated to avoid "stake too deep" error.
            weight = weightedBalance(
                available[TRANCHE_M].add(locked[TRANCHE_M]),
                available[TRANCHE_A].add(locked[TRANCHE_A]),
                available[TRANCHE_B].add(locked[TRANCHE_B])
            );
            if (weight > 0) {
                // The contract was just upgraded from an old version without boosting
                _workingBalances[account] = weight;
            }
        }
        uint256 availableM = available[TRANCHE_M];
        uint256 availableA = available[TRANCHE_A];
        uint256 availableB = available[TRANCHE_B];
        uint256 lockedM = locked[TRANCHE_M];
        uint256 lockedA = locked[TRANCHE_A];
        uint256 lockedB = locked[TRANCHE_B];
        for (uint256 i = oldVersion; i < targetVersion; i++) {
            rewards = rewards.add(
                weight.multiplyDecimalPrecise(_historicalIntegrals[i].sub(userIntegral))
            );
            if (availableM != 0 || availableA != 0 || availableB != 0) {
                (availableM, availableA, availableB) = _fundDoRebalance(
                    availableM,
                    availableA,
                    availableB,
                    i
                );
            }
            if (lockedM != 0 || lockedA != 0 || lockedB != 0) {
                (lockedM, lockedA, lockedB) = _fundDoRebalance(lockedM, lockedA, lockedB, i);
            }
            userIntegral = 0;

            // Reset per-user weight boosting after the first rebalance
            weight = weightedBalance(
                availableM.add(lockedM),
                availableA.add(lockedA),
                availableB.add(lockedB)
            );
        }
        rewards = rewards.add(weight.multiplyDecimalPrecise(integral.sub(userIntegral)));
        address account_ = account; // Fix the "stack too deep" error
        _claimableRewards[account_] = rewards;
        _userIntegrals[account_] = integral;

        if (oldVersion < targetVersion) {
            if (available[TRANCHE_M] != availableM) {
                available[TRANCHE_M] = availableM;
            }
            if (available[TRANCHE_A] != availableA) {
                available[TRANCHE_A] = availableA;
            }
            if (available[TRANCHE_B] != availableB) {
                available[TRANCHE_B] = availableB;
            }
            if (locked[TRANCHE_M] != lockedM) {
                locked[TRANCHE_M] = lockedM;
            }
            if (locked[TRANCHE_A] != lockedA) {
                locked[TRANCHE_A] = lockedA;
            }
            if (locked[TRANCHE_B] != lockedB) {
                locked[TRANCHE_B] = lockedB;
            }
            _balanceVersions[account_] = targetVersion;
            _workingBalances[account_] = weight;
        }
    }

    /// @dev Calculate working balance, which depends on the amount of staked tokens and veCHESS.
    ///      Before this function is called, both `_checkpoint()` and `_userCheckpoint(account)`
    ///      should be called to update `_workingSupply` and `_workingBalances[account]` to
    ///      the latest rebalance version.
    /// @param account User address
    function _updateWorkingBalance(address account) private {
        uint256 weightedSupply =
            weightedBalance(
                _totalSupplies[TRANCHE_M],
                _totalSupplies[TRANCHE_A],
                _totalSupplies[TRANCHE_B]
            );
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        // Assume weightedBalance(x, 0, 0) always equal to x
        uint256 weightedM = available[TRANCHE_M].add(locked[TRANCHE_M]);
        uint256 weightedAB =
            weightedBalance(
                0,
                available[TRANCHE_A].add(locked[TRANCHE_A]),
                available[TRANCHE_B].add(locked[TRANCHE_B])
            );

        uint256 newWorkingBalance = weightedAB.add(weightedM);
        uint256 veProportion = _veSnapshots[account].veProportion;
        if (veProportion > 0 && _veSnapshots[account].veLocked.unlockTime > block.timestamp) {
            uint256 boostingPower = weightedSupply.multiplyDecimal(veProportion);
            if (boostingPower <= weightedAB) {
                newWorkingBalance = newWorkingBalance.add(
                    boostingPower.multiplyDecimal(MAX_BOOSTING_FACTOR_MINUS_ONE)
                );
            } else {
                uint256 boostingPowerM =
                    (boostingPower - weightedAB)
                        .min(boostingPower.multiplyDecimal(MAX_BOOSTING_POWER_M))
                        .min(weightedM);
                newWorkingBalance = newWorkingBalance.add(
                    weightedAB.add(boostingPowerM).multiplyDecimal(MAX_BOOSTING_FACTOR_MINUS_ONE)
                );
            }
        }

        _workingSupply = _workingSupply.sub(_workingBalances[account]).add(newWorkingBalance);
        _workingBalances[account] = newWorkingBalance;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../interfaces/IPrimaryMarketV2.sol";
import "../fund/PrimaryMarket.sol";
import "../exchange/ExchangeV3.sol";
import "./UpgradeTool.sol";

contract BatchUpgradeTool {
    using SafeMath for uint256;

    /// @dev `encodedData` consists of two types of data:
    ///      - unsettled epochs
    ///      - bid orders
    //       Unsettled epochs are encoded as follows:
    //       Bit  255       | 0 (constant)
    //       Bit [224, 228) | exchangeIndex
    //       Bit 192        | 0 (maker), 1(taker)
    //       Bit [0, 64)    | epoch
    //       Bid orders are encoded as follows:
    //       Bit  255       | 1 (constant)
    //       Bit [224, 228) | exchangeIndex
    //       Bit [76, 80)   | version
    //       Bit [72, 76)   | tranche
    //       Bit [64, 72)   | pdLevel
    //       Bit [0, 64)    | index
    /// @return tokenAmounts An array of (upgradeTools.length * 3) values, containing the amount
    ///         of three tokens upgraded for each Fund
    /// @return underlyingAmounts An array of (oldPrimaryMarkets.length + oldWrappedPrimaryMarkets.length)
    ///         values, containing the amount of underlying tokens claimed from each primary market
    /// @return totalQuoteAmount Total amount of quote tokens returned to the account.
    /// @return totalRewards Total amount of CHESS claimed by the account.
    function batchProtocolUpgrade(
        address[] calldata oldPrimaryMarkets,
        address[] calldata oldWrappedPrimaryMarkets,
        address[] calldata upgradeTools,
        uint256[] calldata encodedData,
        address account
    )
        external
        returns (
            uint256[] memory tokenAmounts,
            uint256[] memory underlyingAmounts,
            uint256 totalQuoteAmount,
            uint256 totalRewards
        )
    {
        underlyingAmounts = new uint256[](
            oldPrimaryMarkets.length + oldWrappedPrimaryMarkets.length
        );
        for (uint256 i = 0; i < oldPrimaryMarkets.length; i++) {
            (, underlyingAmounts[i]) = IPrimaryMarket(oldPrimaryMarkets[i]).claim(account);
        }
        for (uint256 i = 0; i < oldWrappedPrimaryMarkets.length; i++) {
            (, underlyingAmounts[i + oldPrimaryMarkets.length]) = IPrimaryMarketV2(
                oldWrappedPrimaryMarkets[i]
            )
                .claimAndUnwrap(account);
        }

        for (uint256 i = 0; i < encodedData.length; i++) {
            uint256 encodedDatum = encodedData[i];
            uint256 exchangeIndex = (encodedDatum >> 224) & 0xF;
            ExchangeV3 exchange =
                ExchangeV3(address(UpgradeTool(upgradeTools[exchangeIndex]).oldExchange()));
            uint256 quoteAmount;
            if ((encodedDatum >> 255) == 0) {
                // unsettled epochs
                uint256 epoch = encodedDatum & 0xFFFFFFFFFFFFFFFF;
                (, , , quoteAmount) = ((encodedDatum >> 192) & 0x1 == 0)
                    ? exchange.settleMaker(account, epoch)
                    : exchange.settleTaker(account, epoch);
            } else {
                // bid orders
                uint256 version = (encodedDatum >> 76) & 0xF;
                uint256 tranche = (encodedDatum >> 72) & 0xF;
                uint256 pdLevel = (encodedDatum >> 64) & 0xFF;
                uint256 index = encodedDatum & 0xFFFFFFFFFFFFFFFF;
                quoteAmount = exchange.cancelBid(version, tranche, pdLevel, index);
            }
            totalQuoteAmount = totalQuoteAmount.add(quoteAmount);
        }

        tokenAmounts = new uint256[](upgradeTools.length * 3);
        for (uint256 i = 0; i < upgradeTools.length; i++) {
            UpgradeTool tool = UpgradeTool(upgradeTools[i]);
            if (address(tool) == address(0)) {
                continue;
            }
            uint256 claimedRewards;
            (
                tokenAmounts[i * 3],
                tokenAmounts[i * 3 + 1],
                tokenAmounts[i * 3 + 2],
                claimedRewards
            ) = tool.protocolUpgrade(account);
            totalRewards = totalRewards.add(claimedRewards);
        }
    }

    /// @notice Same as `batchProtocolUpgrade` but returns minimal parameters that should be used
    ///         to call `batchProtocolUpgrade`.
    function batchProtocolUpgradeParameters(
        address[] memory oldPrimaryMarkets,
        address[] memory oldWrappedPrimaryMarkets,
        address[] memory upgradeTools,
        uint256[] memory encodedData,
        address account
    )
        external
        returns (
            address[] memory,
            address[] memory,
            address[] memory,
            uint256[] memory
        )
    {
        bool[] memory requiredTools = new bool[](upgradeTools.length);
        _filterPrimaryMarkets(1, oldPrimaryMarkets, upgradeTools, requiredTools, account);
        _filterPrimaryMarkets(2, oldWrappedPrimaryMarkets, upgradeTools, requiredTools, account);
        _filterEncodedData(encodedData, upgradeTools, requiredTools, account);
        _filterUpgradeTools(upgradeTools, requiredTools, account);
        return (oldPrimaryMarkets, oldWrappedPrimaryMarkets, upgradeTools, encodedData);
    }

    function _filterPrimaryMarkets(
        uint256 fundVersion,
        address[] memory primaryMarkets,
        address[] memory upgradeTools,
        bool[] memory requiredTools,
        address account
    ) private {
        for (uint256 i = 0; i < primaryMarkets.length; i++) {
            (uint256 shares, uint256 underlying) =
                fundVersion == 1
                    ? IPrimaryMarket(primaryMarkets[i]).claim(account)
                    : IPrimaryMarketV2(primaryMarkets[i]).claimAndUnwrap(account);
            if (shares | underlying == 0) {
                primaryMarkets[i] = address(0);
            } else if (shares != 0) {
                address tokenUnderlying = PrimaryMarket(primaryMarkets[i]).fund().tokenUnderlying();
                for (uint256 j = 0; j < upgradeTools.length; j++) {
                    if (
                        address(UpgradeTool(upgradeTools[j]).tokenUnderlying()) == tokenUnderlying
                    ) {
                        requiredTools[j] = true;
                        break;
                    }
                }
            }
        }
        _packAddressArray(primaryMarkets);
    }

    function _filterEncodedData(
        uint256[] memory encodedData,
        address[] memory upgradeTools,
        bool[] memory requiredTools,
        address account
    ) private {
        for (uint256 i = 0; i < encodedData.length; i++) {
            uint256 encodedDatum = encodedData[i];
            uint256 exchangeIndex = (encodedDatum >> 224) & 0xF;
            ExchangeV3 exchange =
                ExchangeV3(address(UpgradeTool(upgradeTools[exchangeIndex]).oldExchange()));
            if ((encodedDatum >> 255) == 0) {
                // unsettled epochs
                uint256 epoch = encodedDatum & 0xFFFFFFFFFFFFFFFF;
                (uint256 amountM, uint256 amountA, uint256 amountB, uint256 quoteAmount) =
                    ((encodedDatum >> 192) & 0x1 == 0)
                        ? exchange.settleMaker(account, epoch)
                        : exchange.settleTaker(account, epoch);
                if (amountM | amountA | amountB | quoteAmount == 0) {
                    encodedData[i] = 0;
                } else {
                    requiredTools[exchangeIndex] = true;
                }
            } else {
                // bid orders
                uint256 version = (encodedDatum >> 76) & 0xF;
                uint256 tranche = (encodedDatum >> 72) & 0xF;
                uint256 pdLevel = (encodedDatum >> 64) & 0xFF;
                uint256 index = encodedDatum & 0xFFFFFFFFFFFFFFFF;
                (address maker, , ) = exchange.getBidOrder(version, tranche, pdLevel, index);
                if (maker != account) {
                    encodedData[i] = 0;
                } else {
                    exchange.cancelBid(version, tranche, pdLevel, index);
                    requiredTools[exchangeIndex] = true;
                }
            }
        }
        _packUintArray(encodedData);
    }

    function _filterUpgradeTools(
        address[] memory upgradeTools,
        bool[] memory requiredTools,
        address account
    ) private {
        for (uint256 i = 0; i < upgradeTools.length; i++) {
            UpgradeTool tool = UpgradeTool(upgradeTools[i]);
            (uint256 r1, uint256 r2, uint256 r3, uint256 r4) = tool.protocolUpgrade(account);
            if (r1 | r2 | r3 | r4 == 0 && !requiredTools[i]) {
                upgradeTools[i] = address(0);
            }
        }
        // Do not pack upgradeTools because encodedData has references to it
    }

    function _packAddressArray(address[] memory array) private pure {
        uint256 newLength = 0;
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] != address(0)) {
                array[newLength] = array[i];
                newLength += 1;
            }
        }
        assembly {
            mstore(array, newLength)
        }
    }

    function _packUintArray(uint256[] memory array) private pure {
        uint256 newLength = 0;
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] != 0) {
                array[newLength] = array[i];
                newLength += 1;
            }
        }
        assembly {
            mstore(array, newLength)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "../utils/CoreUtility.sol";
import "../utils/SafeDecimalMath.sol";
import "../interfaces/IChessController.sol";
import "../interfaces/IControllerBallot.sol";

contract ChessControllerV5 is IChessController, CoreUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[192] private _reservedSlots;

    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    event WeightUpdated(address indexed fund, uint256 indexed timestamp, uint256 weight);

    address public immutable fund0;
    uint256 public immutable guardedLaunchStart;
    address public immutable controllerBallot;

    mapping(uint256 => mapping(address => uint256)) public weights;

    /// @notice Start timestamp of the last trading week that has weights updated.
    uint256 public lastTimestamp;

    constructor(
        address fund0_,
        uint256 guardedLaunchStart_,
        address controllerBallot_
    ) public {
        fund0 = fund0_;
        guardedLaunchStart = guardedLaunchStart_;
        require(_endOfWeek(guardedLaunchStart_) == guardedLaunchStart_ + 1 weeks);
        controllerBallot = controllerBallot_;
    }

    /// @dev Initialize the part added in V4. The contract is designed to be used with OpenZeppelin's
    ///      `TransparentUpgradeableProxy`. If this contract is upgraded from the previous version,
    ///      call `upgradeToAndCall` of the proxy and put a call to this function in the `data`
    ///      argument with `lastTimestamp_` set to the last updated week. If this contract is
    ///      the first implementation of the proxy, This function should be called by the proxy's
    ///      constructor (via the `_data` argument) with `lastTimestamp_` set to one week before
    ///      `guardedLaunchStart`.
    function initializeV4(uint256 lastTimestamp_) external {
        require(lastTimestamp == 0, "Already initialized");
        require(
            _endOfWeek(lastTimestamp_) == lastTimestamp_ + 1 weeks &&
                lastTimestamp_ >= guardedLaunchStart - 1 weeks
        );
        require(weights[lastTimestamp_ + 1 weeks][fund0] == 0, "Next week already updated");
        if (lastTimestamp_ >= guardedLaunchStart) {
            require(weights[lastTimestamp_][fund0] > 0, "Last week not updated");
        }
        lastTimestamp = lastTimestamp_;
    }

    /// @notice Get Fund relative weight (not more than 1.0) normalized to 1e18
    ///         (e.g. 1.0 == 1e18).
    /// @return weight Value of relative weight normalized to 1e18
    function getFundRelativeWeight(address fundAddress, uint256 timestamp)
        external
        override
        returns (uint256)
    {
        require(timestamp <= block.timestamp, "Too soon");
        if (timestamp < guardedLaunchStart) {
            return fundAddress == fund0 ? 1e18 : 0;
        }
        uint256 weekTimestamp = _endOfWeek(timestamp).sub(1 weeks);
        uint256 lastTimestamp_ = lastTimestamp; // gas saver
        require(weekTimestamp <= lastTimestamp_ + 1 weeks, "Previous week is empty");
        if (weekTimestamp <= lastTimestamp_) {
            return weights[weekTimestamp][fundAddress];
        }
        lastTimestamp = lastTimestamp_ + 1 weeks;
        return _updateFundWeight(weekTimestamp, fundAddress);
    }

    function _updateFundWeight(uint256 weekTimestamp, address fundAddress)
        private
        returns (uint256 weight)
    {
        (uint256[] memory ballotWeights, address[] memory funds) =
            IControllerBallot(controllerBallot).count(weekTimestamp);

        uint256 totalWeight;
        for (uint256 i = 0; i < ballotWeights.length; i++) {
            uint256 fundWeight = ballotWeights[i];
            weights[weekTimestamp][funds[i]] = fundWeight;
            emit WeightUpdated(funds[i], weekTimestamp, fundWeight);
            if (funds[i] == fundAddress) {
                weight = fundWeight;
            }
            totalWeight = totalWeight.add(fundWeight);
        }
        require(totalWeight <= 1e18, "Total weight exceeds 100%");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "../../utils/CoreUtility.sol";
import "../../utils/SafeDecimalMath.sol";
import "../../interfaces/IChessController.sol";
import "../interfaces/IFund.sol";

contract ChessControllerV3 is IChessController, CoreUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[192] private _reservedSlots;

    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    uint256 public constant WINDOW_SIZE = 2;
    uint256 public immutable minWeight;

    address public immutable fund0;
    address public immutable fund1;
    address public immutable fund2;

    uint256 public immutable guardedLaunchStart;
    uint256 public immutable guardedLaunchStartV3;

    mapping(uint256 => mapping(address => uint256)) public weights;

    constructor(
        address fund0_,
        address fund1_,
        address fund2_,
        uint256 guardedLaunchStart_,
        uint256 guardedLaunchStartV3_,
        uint256 minWeight_
    ) public {
        require(minWeight_ > 0 && minWeight_ < 0.5e18);
        fund0 = fund0_;
        fund1 = fund1_;
        fund2 = fund2_;
        guardedLaunchStart = guardedLaunchStart_;
        require(_endOfWeek(guardedLaunchStart_) == guardedLaunchStart_ + 1 weeks);
        guardedLaunchStartV3 = guardedLaunchStartV3_;
        require(_endOfWeek(guardedLaunchStartV3_) == guardedLaunchStartV3_ + 1 weeks);
        require(guardedLaunchStartV3_ > guardedLaunchStart_);
        minWeight = minWeight_;
    }

    function initializeV3(uint256[] calldata guardedWeights2_) external {
        require(guardedLaunchStartV3 > block.timestamp, "Too late to initialize");
        // Make sure guarded launch in V2 has been initialized.
        require(weights[guardedLaunchStart][fund0] != 0);
        // Make sure guarded launch in V2 has ended.
        require(weights[guardedLaunchStartV3][fund0] == 0);
        require(weights[guardedLaunchStartV3][fund2] == 0, "Already initialized");
        require(guardedWeights2_.length > 0);
        for (uint256 i = 0; i < guardedWeights2_.length; i++) {
            uint256 weight2 = guardedWeights2_[i];
            require(weight2 >= minWeight && weight2 <= 1e18 - minWeight * 2, "Invalid weight");
            weights[guardedLaunchStartV3 + i * 1 weeks][fund2] = weight2;
        }
    }

    /// @notice Get Fund relative weight (not more than 1.0) normalized to 1e18
    ///         (e.g. 1.0 == 1e18).
    /// @return weight Value of relative weight normalized to 1e18
    function getFundRelativeWeight(address fundAddress, uint256 timestamp)
        external
        override
        returns (uint256)
    {
        require(timestamp <= block.timestamp, "Too soon");
        if (fundAddress != fund0 && fundAddress != fund1 && fundAddress != fund2) {
            return 0;
        }
        if (timestamp < guardedLaunchStart) {
            return fundAddress == fund0 ? 1e18 : 0;
        } else if (timestamp < guardedLaunchStartV3 && fundAddress == fund2) {
            return 0;
        }

        uint256 weekTimestamp = _endOfWeek(timestamp).sub(1 weeks);
        uint256 weight = weights[weekTimestamp][fundAddress];
        if (weight != 0) {
            return weight;
        }

        (uint256 weight0, uint256 weight1, uint256 weight2) = _updateFundWeight(weekTimestamp);
        if (fundAddress == fund0) {
            return weight0;
        } else if (fundAddress == fund1) {
            return weight1;
        } else {
            return weight2;
        }
    }

    function _updateFundWeight(uint256 weekTimestamp)
        private
        returns (
            uint256 weight0,
            uint256 weight1,
            uint256 weight2
        )
    {
        uint256 prevWeight0 = weights[weekTimestamp - 1 weeks][fund0];
        require(prevWeight0 != 0, "Previous week is empty");
        uint256 prevWeight2 = weights[weekTimestamp - 1 weeks][fund2];
        weight2 = weights[weekTimestamp][fund2];
        if (weight2 == 0) {
            // After guarded launch V3, keep weight of fund 2 constant. This contract is planned to
            // be upgraded again after guarded launch V3 and the constant weight2 won't last long.
            weight2 = prevWeight2;
        }
        prevWeight0 = prevWeight0.mul(1e18 - weight2).div(1e18 - prevWeight2).max(minWeight).min(
            1e18 - weight2 - minWeight
        );
        uint256 fundValueLocked0 = getFundValueLocked(fund0, weekTimestamp);
        uint256 totalValueLocked = fundValueLocked0.add(getFundValueLocked(fund1, weekTimestamp));

        if (totalValueLocked == 0) {
            weight0 = prevWeight0;
        } else {
            weight0 = (prevWeight0.mul(WINDOW_SIZE - 1).add(
                fundValueLocked0.mul(1e18 - weight2).div(totalValueLocked)
            ) / WINDOW_SIZE)
                .max(minWeight)
                .min(1e18 - weight2 - minWeight);
        }
        weight1 = 1e18 - weight2 - weight0;

        weights[weekTimestamp][fund0] = weight0;
        weights[weekTimestamp][fund1] = weight1;
        weights[weekTimestamp][fund2] = weight2;
    }

    function getFundValueLocked(address fund, uint256 weekTimestamp)
        public
        view
        returns (uint256 fundValueLocked)
    {
        uint256 timestamp = (IFund(fund).currentDay() - 1 days).min(weekTimestamp);
        (uint256 navM, , ) = IFund(fund).historicalNavs(timestamp);
        fundValueLocked = IFund(fund).historicalTotalShares(timestamp).multiplyDecimal(navM);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "../../utils/CoreUtility.sol";
import "../../utils/SafeDecimalMath.sol";
import "../../interfaces/IChessController.sol";
import "../interfaces/IFund.sol";

contract ChessControllerV2 is IChessController, CoreUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[192] private _reservedSlots;

    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    uint256 public constant WINDOW_SIZE = 2;
    uint256 public immutable minWeight;

    address public immutable fund0;
    address public immutable fund1;
    mapping(uint256 => mapping(address => uint256)) public weights;

    uint256 public immutable guardedLaunchStart;

    constructor(
        address fund0_,
        address fund1_,
        uint256 guardedLaunchStart_,
        uint256 minWeight_
    ) public {
        require(minWeight_ > 0 && minWeight_ < 1e18);
        fund0 = fund0_;
        fund1 = fund1_;
        guardedLaunchStart = guardedLaunchStart_;
        minWeight = minWeight_;
    }

    function initialize(uint256[] calldata guardedWeights0_) external {
        require(weights[guardedLaunchStart][fund0] == 0);
        require(guardedWeights0_.length > 0);
        require(_endOfWeek(guardedLaunchStart) == guardedLaunchStart + 1 weeks, "Not end of week");
        for (uint256 i = 0; i < guardedWeights0_.length; i++) {
            uint256 guardedWeight0 = guardedWeights0_[i];
            require(
                guardedWeight0 >= minWeight && guardedWeight0 <= 1e18 - minWeight,
                "Invalid weight"
            );
            weights[guardedLaunchStart + i * 1 weeks][fund0] = guardedWeight0;
            weights[guardedLaunchStart + i * 1 weeks][fund1] = 1e18 - guardedWeight0;
        }
    }

    /// @notice Get Fund relative weight (not more than 1.0) normalized to 1e18
    ///         (e.g. 1.0 == 1e18).
    /// @return weight Value of relative weight normalized to 1e18
    function getFundRelativeWeight(address fundAddress, uint256 timestamp)
        external
        override
        returns (uint256)
    {
        require(timestamp <= block.timestamp, "Too soon");
        if (fundAddress != fund0 && fundAddress != fund1) {
            return 0;
        }
        if (timestamp < guardedLaunchStart) {
            return fundAddress == fund0 ? 1e18 : 0;
        }

        uint256 weekTimestamp = _endOfWeek(timestamp).sub(1 weeks);
        uint256 weight = weights[weekTimestamp][fundAddress];
        if (weight != 0) {
            return weight;
        }

        (uint256 weight0, uint256 weight1) = _updateFundWeight(weekTimestamp);
        return fundAddress == fund0 ? weight0 : weight1;
    }

    function _updateFundWeight(uint256 weekTimestamp)
        private
        returns (uint256 weightMovingAverage0, uint256 weightMovingAverage1)
    {
        uint256 fundValueLocked0 = getFundValueLocked(fund0, weekTimestamp);
        uint256 totalValueLocked = fundValueLocked0.add(getFundValueLocked(fund1, weekTimestamp));
        uint256 prevFundWeight0 = weights[weekTimestamp - 1 weeks][fund0];
        require(prevFundWeight0 != 0, "Previous week is empty");

        if (totalValueLocked == 0) {
            weightMovingAverage0 = prevFundWeight0;
            weightMovingAverage1 = weights[weekTimestamp - 1 weeks][fund1];
        } else {
            weightMovingAverage0 = (prevFundWeight0.mul(WINDOW_SIZE - 1).add(
                fundValueLocked0.divideDecimal(totalValueLocked)
            ) / WINDOW_SIZE)
                .max(minWeight)
                .min(1e18 - minWeight);
            weightMovingAverage1 = 1e18 - weightMovingAverage0;
        }

        weights[weekTimestamp][fund0] = weightMovingAverage0;
        weights[weekTimestamp][fund1] = weightMovingAverage1;
    }

    function getFundValueLocked(address fund, uint256 weekTimestamp)
        public
        view
        returns (uint256 fundValueLocked)
    {
        uint256 timestamp = (IFund(fund).currentDay() - 1 days).min(weekTimestamp);
        (uint256 navM, , ) = IFund(fund).historicalNavs(timestamp);
        fundValueLocked = IFund(fund).historicalTotalShares(timestamp).multiplyDecimal(navM);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../../utils/CoreUtility.sol";
import "../../interfaces/IVotingEscrow.sol";

interface IAddressWhitelist {
    function check(address account) external view returns (bool);
}

contract VotingEscrow is IVotingEscrow, OwnableUpgradeable, ReentrancyGuard, CoreUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[32] private _reservedSlots;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event LockCreated(address indexed account, uint256 amount, uint256 unlockTime);

    event AmountIncreased(address indexed account, uint256 increasedAmount);

    event UnlockTimeIncreased(address indexed account, uint256 newUnlockTime);

    event Withdrawn(address indexed account, uint256 amount);

    uint256 public immutable override maxTime;

    address public immutable override token;

    string public name;
    string public symbol;

    address public addressWhitelist;

    mapping(address => LockedBalance) public locked;

    /// @notice Mapping of unlockTime => total amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;

    /// @notice max lock time allowed at the moment
    uint256 public maxTimeAllowed;

    constructor(
        address token_,
        address addressWhitelist_,
        string memory name_,
        string memory symbol_,
        uint256 maxTime_
    ) public {
        name = name_;
        symbol = symbol_;
        token = token_;
        addressWhitelist = addressWhitelist_;
        maxTime = maxTime_;
    }

    /// @notice Initialize ownership
    function initialize(uint256 maxTimeAllowed_) external initializer {
        __Ownable_init();
        require(maxTimeAllowed_ <= maxTime, "Cannot exceed max time");
        maxTimeAllowed = maxTimeAllowed_;
    }

    function getTimestampDropBelow(address account, uint256 threshold)
        external
        view
        override
        returns (uint256)
    {
        LockedBalance memory lockedBalance = locked[account];
        if (lockedBalance.amount == 0 || lockedBalance.amount < threshold) {
            return 0;
        }
        return lockedBalance.unlockTime.sub(threshold.mul(maxTime).div(lockedBalance.amount));
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOfAtTimestamp(account, block.timestamp);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupplyAtTimestamp(block.timestamp);
    }

    function getLockedBalance(address account)
        external
        view
        override
        returns (LockedBalance memory)
    {
        return locked[account];
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp)
        external
        view
        override
        returns (uint256)
    {
        return _balanceOfAtTimestamp(account, timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256) {
        return _totalSupplyAtTimestamp(timestamp);
    }

    function createLock(
        uint256 amount,
        uint256 unlockTime,
        address,
        bytes memory
    ) external nonReentrant {
        _assertNotContract();
        require(
            unlockTime + 1 weeks == _endOfWeek(unlockTime),
            "Unlock time must be end of a week"
        );

        LockedBalance memory lockedBalance = locked[msg.sender];

        require(amount > 0, "Zero value");
        require(lockedBalance.amount == 0, "Withdraw old tokens first");
        require(unlockTime > block.timestamp, "Can only lock until time in the future");
        require(
            unlockTime <= block.timestamp + maxTimeAllowed,
            "Voting lock cannot exceed max lock time"
        );

        scheduledUnlock[unlockTime] = scheduledUnlock[unlockTime].add(amount);
        locked[msg.sender].unlockTime = unlockTime;
        locked[msg.sender].amount = amount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit LockCreated(msg.sender, amount, unlockTime);
    }

    function increaseAmount(
        address account,
        uint256 amount,
        address,
        bytes memory
    ) external nonReentrant {
        LockedBalance memory lockedBalance = locked[account];

        require(amount > 0, "Zero value");
        require(lockedBalance.unlockTime > block.timestamp, "Cannot add to expired lock");

        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].add(
            amount
        );
        locked[account].amount = lockedBalance.amount.add(amount);

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit AmountIncreased(account, amount);
    }

    function increaseUnlockTime(
        uint256 unlockTime,
        address,
        bytes memory
    ) external nonReentrant {
        require(
            unlockTime + 1 weeks == _endOfWeek(unlockTime),
            "Unlock time must be end of a week"
        );
        LockedBalance memory lockedBalance = locked[msg.sender];

        require(lockedBalance.unlockTime > block.timestamp, "Lock expired");
        require(unlockTime > lockedBalance.unlockTime, "Can only increase lock duration");
        require(
            unlockTime <= block.timestamp + maxTimeAllowed,
            "Voting lock cannot exceed max lock time"
        );

        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].sub(
            lockedBalance.amount
        );
        scheduledUnlock[unlockTime] = scheduledUnlock[unlockTime].add(lockedBalance.amount);
        locked[msg.sender].unlockTime = unlockTime;

        emit UnlockTimeIncreased(msg.sender, unlockTime);
    }

    function withdraw() external nonReentrant {
        LockedBalance memory lockedBalance = locked[msg.sender];
        require(block.timestamp >= lockedBalance.unlockTime, "The lock is not expired");
        uint256 amount = uint256(lockedBalance.amount);

        lockedBalance.unlockTime = 0;
        lockedBalance.amount = 0;
        locked[msg.sender] = lockedBalance;

        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function updateAddressWhitelist(address newWhitelist) external onlyOwner {
        require(
            newWhitelist == address(0) || Address.isContract(newWhitelist),
            "Smart contract whitelist has to be null or a contract"
        );
        addressWhitelist = newWhitelist;
    }

    function _assertNotContract() private view {
        if (msg.sender != tx.origin) {
            if (
                addressWhitelist != address(0) &&
                IAddressWhitelist(addressWhitelist).check(msg.sender)
            ) {
                return;
            }
            revert("Smart contract depositors not allowed");
        }
    }

    function _balanceOfAtTimestamp(address account, uint256 timestamp)
        private
        view
        returns (uint256)
    {
        require(timestamp >= block.timestamp, "Must be current or future time");
        LockedBalance memory lockedBalance = locked[account];
        if (timestamp > lockedBalance.unlockTime) {
            return 0;
        }
        return (lockedBalance.amount.mul(lockedBalance.unlockTime - timestamp)) / maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp) private view returns (uint256) {
        uint256 weekCursor = _endOfWeek(timestamp);
        uint256 total = 0;
        for (; weekCursor <= timestamp + maxTime; weekCursor += 1 weeks) {
            total = total.add((scheduledUnlock[weekCursor].mul(weekCursor - timestamp)) / maxTime);
        }
        return total;
    }

    function updateMaxTimeAllowed(uint256 newMaxTimeAllowed) external onlyOwner {
        require(newMaxTimeAllowed <= maxTime, "Cannot exceed max time");
        require(newMaxTimeAllowed > maxTimeAllowed, "Cannot shorten max time allowed");
        maxTimeAllowed = newMaxTimeAllowed;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockWrappedToken is ERC20 {
    constructor(string memory name, string memory symbol) public ERC20(name, symbol) {
        _setupDecimals(18);
    }

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) external {
        _burn(msg.sender, wad);
        msg.sender.transfer(wad);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20, Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20(name, symbol) {
        _setupDecimals(decimals);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../../interfaces/ITwapOracle.sol";

/// @title Time-weighted average price oracle
/// @notice This contract extends the Open Oracle standard by Compound, accepts price data
///         signed by two Reporters (a primary source and a secondary source) and computes
///         time-weighted average price (TWAP) in every 30-minute epoch.
/// @author Tranchess
contract TwapOracle is ITwapOracle, Ownable {
    uint256 private constant MESSAGE_INTERVAL = 1 minutes;
    uint256 private constant MESSAGE_BATCH_SIZE = 30; // not exceeding 32 for v's to fit in a word
    uint256 private constant EPOCH = MESSAGE_INTERVAL * MESSAGE_BATCH_SIZE;

    /// @dev Minimal number of messages in an epoch.
    uint256 private constant MIN_MESSAGE_COUNT = 15;
    uint256 private constant PUBLISHING_DELAY = 15 minutes;

    uint256 private constant SECONDARY_SOURCE_DELAY = EPOCH * 2;
    uint256 private constant OWNER_DELAY = EPOCH * 4;
    uint256 private constant PRICE_UNIT = 1e12;
    uint256 private constant PRICE_MASK = 0xffffffffffffffff;

    event Update(uint256 timestamp, uint256 price, UpdateType updateType);

    address public immutable primarySource;
    address public immutable secondarySource;
    uint256 private immutable _startTimestamp;
    string public symbol;

    uint256 private _lastPrimaryMessageCount;
    uint256 private _lastSecondaryTimestamp;
    uint256 private _lastSecondaryMessageCount;

    /// @dev Mapping of epoch end timestamp => TWAP
    mapping(uint256 => uint256) private _prices;

    /// @param primarySource_ Address of the primary data source
    /// @param secondarySource_ Address of the secondary data source
    /// @param symbol_ Asset symbol
    constructor(
        address primarySource_,
        address secondarySource_,
        string memory symbol_
    ) public {
        primarySource = primarySource_;
        secondarySource = secondarySource_;
        symbol = symbol_;
        _startTimestamp = block.timestamp;
    }

    /// @notice Return TWAP with 18 decimal places in the epoch ending at the specified timestamp.
    ///         Zero is returned if the epoch is not initialized yet or can still be updated
    ///         with more messages from the same source.
    /// @param timestamp End Timestamp in seconds of the epoch
    /// @return TWAP (18 decimal places) in the epoch, or zero if the epoch is not initialized yet
    ///         or can still be updated with more messages from the same source.
    function getTwap(uint256 timestamp) external view override returns (uint256) {
        // Check whether the stored price can be updated in the future
        if (
            // Case 1: it can still be updated by more messages from the primary source
            timestamp > block.timestamp - PUBLISHING_DELAY ||
            // Case 2: it comes from the secondary source and can still be updated
            // by more messages from that source
            (timestamp <= block.timestamp - SECONDARY_SOURCE_DELAY &&
                timestamp > block.timestamp - SECONDARY_SOURCE_DELAY - PUBLISHING_DELAY &&
                timestamp == _lastSecondaryTimestamp)
        ) {
            return 0;
        } else {
            return _prices[timestamp];
        }
    }

    /// @notice Return minimum acceptable message count from the primary source
    ///         to update a given epoch.
    /// @param timestamp End timestamp in seconds of the epoch to update
    /// @return Minimum acceptable message count, or `MESSAGE_BATCH_SIZE + 1` if the epoch
    ///         cannot be updated now
    function minPrimaryMessageCountToUpdate(uint256 timestamp) external view returns (uint256) {
        if (_prices[timestamp] != 0) {
            if (timestamp > block.timestamp - PUBLISHING_DELAY) {
                return _lastPrimaryMessageCount + 1;
            } else {
                return MESSAGE_BATCH_SIZE + 1;
            }
        } else {
            return MIN_MESSAGE_COUNT;
        }
    }

    /// @notice Return minimum acceptable message count from the secondary source
    ///         to update a given epoch.
    /// @param timestamp End timestamp in seconds of the epoch to update
    /// @return Minimum acceptable message count, or `MESSAGE_BATCH_SIZE + 1` if the epoch
    ///         cannot be updated now
    function minSecondaryMessageCountToUpdate(uint256 timestamp) external view returns (uint256) {
        if (timestamp > block.timestamp - SECONDARY_SOURCE_DELAY || timestamp <= _startTimestamp) {
            return MESSAGE_BATCH_SIZE + 1;
        } else if (_prices[timestamp] != 0) {
            if (
                timestamp == _lastSecondaryTimestamp &&
                timestamp > block.timestamp - SECONDARY_SOURCE_DELAY - PUBLISHING_DELAY
            ) {
                return _lastSecondaryMessageCount + 1;
            } else {
                return MESSAGE_BATCH_SIZE + 1;
            }
        } else {
            return MIN_MESSAGE_COUNT;
        }
    }

    /// @notice Submit prices in a epoch that are signed by the primary source.
    /// @param timestamp End timestamp in seconds of the epoch
    /// @param priceList A list of prices (6 decimal places) in messages signed by the source,
    ///        with zero indicating a missing message
    /// @param rList A list of "r" values of signatures
    /// @param sList A list of "s" values of signatures
    /// @param packedV "v" values of signatures packed in a single word,
    ///        starting from the lowest byte
    function updateTwapFromPrimary(
        uint256 timestamp,
        uint256[MESSAGE_BATCH_SIZE] calldata priceList,
        bytes32[MESSAGE_BATCH_SIZE] calldata rList,
        bytes32[MESSAGE_BATCH_SIZE] calldata sList,
        uint256 packedV
    ) external {
        // Do not check (timestamp > _startTimestamp) for two reasons:
        // 1. the primary source is trusted;
        // 2. to save gas in most of the time.

        uint256 lastMessageCount = MIN_MESSAGE_COUNT - 1;
        if (_prices[timestamp] != 0) {
            require(
                timestamp > block.timestamp - PUBLISHING_DELAY,
                "Too late for the primary source to update an existing epoch"
            );
            lastMessageCount = _lastPrimaryMessageCount;
        }
        uint256 newMessageCount =
            _updateTwapFromSource(
                timestamp,
                lastMessageCount,
                priceList,
                rList,
                sList,
                packedV,
                primarySource,
                UpdateType.PRIMARY
            );
        if (timestamp > block.timestamp - PUBLISHING_DELAY) {
            _lastPrimaryMessageCount = newMessageCount;
        }
    }

    /// @notice Submit prices in a epoch that are signed by the secondary source.
    ///         This is allowed only after SECONDARY_SOURCE_DELAY has elapsed after the epoch.
    /// @param timestamp End timestamp in seconds of the epoch
    /// @param priceList A list of prices (6 decimal places) in messages signed by the source,
    ///        with zero indicating a missing message
    /// @param rList A list of "r" values of signatures
    /// @param sList A list of "s" values of signatures
    /// @param packedV "v" values of signatures packed in a single word,
    ///        starting from the lowest byte
    function updateTwapFromSecondary(
        uint256 timestamp,
        uint256[MESSAGE_BATCH_SIZE] calldata priceList,
        bytes32[MESSAGE_BATCH_SIZE] calldata rList,
        bytes32[MESSAGE_BATCH_SIZE] calldata sList,
        uint256 packedV
    ) external {
        require(
            timestamp <= block.timestamp - SECONDARY_SOURCE_DELAY,
            "Not ready for the secondary source"
        );
        require(
            timestamp > _startTimestamp,
            "The secondary source cannot update epoch before this contract is deployed"
        );
        uint256 lastMessageCount = MIN_MESSAGE_COUNT - 1;
        if (_prices[timestamp] != 0) {
            require(
                timestamp == _lastSecondaryTimestamp &&
                    timestamp > block.timestamp - SECONDARY_SOURCE_DELAY - PUBLISHING_DELAY,
                "Too late for the secondary source to update an existing epoch"
            );
            lastMessageCount = _lastSecondaryMessageCount;
        }
        uint256 newMessageCount =
            _updateTwapFromSource(
                timestamp,
                lastMessageCount,
                priceList,
                rList,
                sList,
                packedV,
                secondarySource,
                UpdateType.SECONDARY
            );
        if (timestamp > block.timestamp - SECONDARY_SOURCE_DELAY - PUBLISHING_DELAY) {
            _lastSecondaryTimestamp = timestamp;
            _lastSecondaryMessageCount = newMessageCount;
        }
    }

    /// @dev Verify signatures and update a epoch.
    /// @param timestamp End timestamp in seconds of the epoch
    /// @param lastMessageCount Message count in the last update to the epoch
    /// @param priceList A list of prices (6 decimal places) in messages signed by the source,
    ///        with zero indicating a missing message
    /// @param rList A list of "r" values of signatures
    /// @param sList A list of "s" values of signatures
    /// @param packedV "v" values of signatures packed in a single word,
    ///        starting from the lowest byte
    /// @param source Address of the data source that signs the messages
    /// @param updateType Type of this update, which will be included in an event
    /// @return messageCount Non-zero price count in `priceList`
    function _updateTwapFromSource(
        uint256 timestamp,
        uint256 lastMessageCount,
        uint256[MESSAGE_BATCH_SIZE] memory priceList,
        bytes32[MESSAGE_BATCH_SIZE] memory rList,
        bytes32[MESSAGE_BATCH_SIZE] memory sList,
        uint256 packedV,
        address source,
        UpdateType updateType
    ) private returns (uint256 messageCount) {
        require(timestamp % EPOCH == 0, "Unaligned timestamp");
        messageCount = 0;
        uint256 sum = 0;
        string memory _symbol = symbol; // gas saver
        uint256 t = timestamp - EPOCH;
        uint256 weight = 1;
        for (uint256 i = 0; i < MESSAGE_BATCH_SIZE; i++) {
            t += MESSAGE_INTERVAL;
            // Only prices fitting in 8 bytes (about 1.8e13 with 6 decimal places) are accepted,
            // which guarentees the following arithmetic operations never overflow.
            uint256 p = priceList[i] & PRICE_MASK;
            if (p == 0) {
                weight += 1;
                packedV >>= 8;
                continue;
            }
            // Build the original message and verify its signature. The computation is packed
            // in a single complex statement to save gas. Solidity generates unnecessary
            // initialization for each local variable, which wastes notable gas in this hot loop.
            require(
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            keccak256(
                                // Rebuild the message signed by the source
                                abi.encode("prices", t, _symbol, p)
                            )
                        )
                    ),
                    uint8(packedV), // the lowest byte of packedV
                    rList[i],
                    sList[i]
                ) == source,
                "Invalid signature"
            );
            sum += p * weight;
            weight = 1;
            messageCount += 1;
            packedV >>= 8;
        }
        require(messageCount > lastMessageCount, "More messages are required to update this epoch");
        if (weight > 1) {
            sum += (priceList[MESSAGE_BATCH_SIZE - weight] & PRICE_MASK) * (weight - 1);
        }
        uint256 average = (sum * PRICE_UNIT) / MESSAGE_BATCH_SIZE;
        _prices[t] = average;
        emit Update(t, average, updateType);
    }

    /// @notice Submit a TWAP with 18 decimal places by the owner.
    ///         This is allowed only when a epoch gets no update after OWNER_DELAY has elapsed.
    function updateTwapFromOwner(uint256 timestamp, uint256 price) external onlyOwner {
        require(timestamp % EPOCH == 0, "Unaligned timestamp");
        require(timestamp <= block.timestamp - OWNER_DELAY, "Not ready for owner");
        require(_prices[timestamp] == 0, "Owner cannot update an existing epoch");
        require(
            timestamp > _startTimestamp,
            "Owner cannot update epoch before this contract is deployed"
        );

        uint256 lastPrice = _prices[timestamp - EPOCH];
        require(lastPrice > 0, "Owner can only update a epoch following an updated epoch");
        require(
            price > lastPrice / 10 && price < lastPrice * 10,
            "Owner price deviates too much from the last price"
        );

        _prices[timestamp] = price;
        emit Update(timestamp, price, UpdateType.OWNER);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../utils/SafeDecimalMath.sol";

import "../interfaces/IFundV3.sol";
import "../interfaces/IWrappedERC20.sol";

interface ITokenHub {
    function getMiniRelayFee() external view returns (uint256);

    function transferOut(
        address contractAddr,
        address recipient,
        uint256 amount,
        uint64 expireTime
    ) external payable returns (bool);
}

/// @notice Strategy for delegating BNB to BSC validators and earn rewards.
///
///         BSC validator delegation and reward distribution happens on the Binance Chain (BC).
///         A staker address, which is securely managed by multi-signature, executes
///         delegation-related transactions and periodically transfer rewards back to this contract
///         on BSC.
///
///         This contract is a bridge between the fund and the staker. It performs cross-chain
///         transfers from the fund to the staker and forward transfers from the staker back to
///         the fund. It is also in charge of profit bookkeeping, which is either automatcially
///         reported by reporters using scripts or manually calibrated by the owner.
contract BscStakingStrategy is Ownable {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IWrappedERC20;

    event ReporterAdded(address reporter);
    event ReporterRemoved(address reporter);
    event StakerUpdated(address staker);
    event Received(address from, uint256 amount);

    ITokenHub private constant TOKEN_HUB = ITokenHub(0x0000000000000000000000000000000000001004);
    uint256 private constant BRIDGE_EXPIRE_TIME = 1 hours;
    uint256 private constant MAX_ESTIMATED_DAILY_PROFIT_RATE = 0.1e18;
    uint256 private constant MAX_PERFORMANCE_FEE_RATE = 0.5e18;

    IFundV3 public immutable fund;
    address private immutable _tokenUnderlying;

    /// @notice BEP2 address that does the actual staking on Binance Chain.
    ///         DO NOT transfer any asset to this address on Binance Smart Chain.
    address public staker;

    /// @notice Fraction of profit that goes to the fund's fee collector.
    uint256 public performanceFeeRate;

    /// @notice Estimated daily profit rate. This value limits the maximum daily profit that can be
    ///         reported by a reporter.
    uint256 public estimatedDailyProfitRate;

    /// @notice Amount of underlying lost since the last peak. Performance fee is charged
    ///         only when this value is zero.
    uint256 public currentDrawdown;

    /// @notice The set of reporters. Reporters can report profit within a pre-configured range
    ///         once a day.
    mapping(address => bool) public reporters;

    /// @notice The last trading day when a reporter reports daily profit.
    uint256 public reportedDay;

    constructor(
        address fund_,
        address staker_,
        uint256 performanceFeeRate_
    ) public {
        fund = IFundV3(fund_);
        _tokenUnderlying = IFundV3(fund_).tokenUnderlying();
        staker = staker_;
        performanceFeeRate = performanceFeeRate_;
        emit StakerUpdated(staker_);
    }

    modifier onlyReporter() {
        require(reporters[msg.sender], "Only reporter");
        _;
    }

    function addReporter(address reporter) external onlyOwner {
        require(!reporters[reporter]);
        reporters[reporter] = true;
        emit ReporterAdded(reporter);
    }

    function removeReporter(address reporter) external onlyOwner {
        require(reporters[reporter]);
        reporters[reporter] = false;
        emit ReporterRemoved(reporter);
    }

    /// @notice Report daily profit to the fund by a reporter.
    /// @param amount Absolute profit, which must be no greater than twice the estimation
    function accrueProfit(uint256 amount) external onlyReporter {
        uint256 total = fund.getStrategyUnderlying();
        require(
            amount / 2 <= total.multiplyDecimal(estimatedDailyProfitRate),
            "Profit out of range"
        );
        _accrueProfit(amount);
    }

    /// @notice Report daily profit according to the pre-configured rate by a reporter.
    function accrueEstimatedProfit() external onlyReporter {
        uint256 total = fund.getStrategyUnderlying();
        _accrueProfit(total.multiplyDecimal(estimatedDailyProfitRate));
    }

    function _accrueProfit(uint256 amount) private {
        uint256 currentDay = fund.currentDay();
        uint256 oldReportedDay = reportedDay;
        require(oldReportedDay < currentDay, "Already reported");
        reportedDay = oldReportedDay + 1 days;
        _reportProfit(amount);
    }

    function updateEstimatedDailyProfitRate(uint256 rate) external onlyOwner {
        require(rate < MAX_ESTIMATED_DAILY_PROFIT_RATE);
        estimatedDailyProfitRate = rate;
        reportedDay = fund.currentDay();
    }

    /// @notice Report profit to the fund by the owner.
    function reportProfit(uint256 amount) external onlyOwner {
        reportedDay = fund.currentDay();
        _reportProfit(amount);
    }

    /// @dev Report profit and performance fee to the fund. Performance fee is charged only when
    ///      there's no previous loss to cover.
    function _reportProfit(uint256 amount) private {
        uint256 oldDrawdown = currentDrawdown;
        if (amount < oldDrawdown) {
            currentDrawdown = oldDrawdown - amount;
            fund.reportProfit(amount, 0);
        } else {
            if (oldDrawdown > 0) {
                currentDrawdown = 0;
            }
            uint256 performanceFee = (amount - oldDrawdown).multiplyDecimal(performanceFeeRate);
            fund.reportProfit(amount, performanceFee);
        }
    }

    /// @notice Report loss to the fund. Performance fee will not be charged until
    ///         the current drawdown is covered.
    function reportLoss(uint256 amount) external onlyOwner {
        reportedDay = fund.currentDay();
        currentDrawdown = currentDrawdown.add(amount);
        fund.reportLoss(amount);
    }

    function updateStaker(address newStaker) external onlyOwner {
        require(newStaker != address(0));
        staker = newStaker;
        emit StakerUpdated(newStaker);
    }

    function updatePerformanceFeeRate(uint256 newRate) external onlyOwner {
        require(newRate <= MAX_PERFORMANCE_FEE_RATE);
        performanceFeeRate = newRate;
    }

    /// @notice Transfer underlying tokens from the fund to the staker on Binance Chain.
    /// @param amount Amount of underlying transfered from the fund, including cross-chain relay fee
    function transferToStaker(uint256 amount) external onlyOwner {
        fund.transferToStrategy(amount);
        _unwrap(amount);
        uint256 relayFee = TOKEN_HUB.getMiniRelayFee();
        require(
            TOKEN_HUB.transferOut{value: amount}(
                address(0),
                staker,
                amount.sub(relayFee),
                uint64(block.timestamp + BRIDGE_EXPIRE_TIME)
            ),
            "BSC bridge failed"
        );
    }

    /// @notice Transfer all underlying tokens, both wrapped and unwrapped, to the fund.
    function transferToFund() external onlyOwner {
        uint256 unwrapped = address(this).balance;
        if (unwrapped > 0) {
            _wrap(unwrapped);
        }
        uint256 amount = IWrappedERC20(_tokenUnderlying).balanceOf(address(this));
        IWrappedERC20(_tokenUnderlying).safeApprove(address(fund), amount);
        fund.transferFromStrategy(amount);
    }

    /// @notice Receive cross-chain transfer from the staker.
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @dev Convert BNB into WBNB
    function _wrap(uint256 amount) private {
        IWrappedERC20(_tokenUnderlying).deposit{value: amount}();
    }

    /// @dev Convert WBNB into BNB
    function _unwrap(uint256 amount) private {
        IWrappedERC20(_tokenUnderlying).withdraw(amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "../interfaces/ITrancheIndexV2.sol";
import "../utils/SafeDecimalMath.sol";
import "./StableSwap.sol";

contract QueenStableSwap is StableSwap, ITrancheIndexV2 {
    using SafeDecimalMath for uint256;

    constructor(
        address lpToken_,
        address fund_,
        uint256 quoteDecimals_,
        uint256 ampl_,
        address feeCollector_,
        uint256 feeRate_,
        uint256 adminFeeRate_
    )
        public
        StableSwap(
            lpToken_,
            fund_,
            TRANCHE_Q,
            IFundV3(fund_).tokenUnderlying(),
            quoteDecimals_,
            ampl_,
            feeCollector_,
            feeRate_,
            adminFeeRate_
        )
    {
        require(10**(18 - quoteDecimals_) == IFundV3(fund_).underlyingDecimalMultiplier());
    }

    function _getRebalanceResult(uint256)
        internal
        view
        override
        returns (
            uint256 newBase,
            uint256 newQuote,
            uint256 excessiveQ,
            uint256 excessiveB,
            uint256 excessiveR,
            uint256 excessiveQuote,
            bool isRebalanced
        )
    {
        return (baseBalance, quoteBalance, 0, 0, 0, 0, false);
    }

    function _handleRebalance(uint256)
        internal
        override
        returns (uint256 newBase, uint256 newQuote)
    {
        return (baseBalance, quoteBalance);
    }

    function getOraclePrice() public view override returns (uint256) {
        uint256 fundUnderlying = fund.getTotalUnderlying();
        uint256 fundEquivalentTotalQ = fund.getEquivalentTotalQ();
        return fundUnderlying.mul(_quoteDecimalMultiplier).divideDecimal(fundEquivalentTotalQ);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

import "../fund/ShareStaking.sol";

import "../interfaces/ITranchessSwapCallee.sol";
import "../interfaces/IPrimaryMarketV3.sol";
import "../interfaces/ISwapRouter.sol";
import "../interfaces/ITrancheIndexV2.sol";

/// @title Tranchess Flash Swap Router
/// @notice Router for stateless execution of flash swaps against Tranchess stable swaps
contract FlashSwapRouter is ITranchessSwapCallee, ITrancheIndexV2, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event SwapToggled(address externalRouter, bool enabled);
    event SwapRook(
        address indexed recipient,
        uint256 baseIn,
        uint256 quoteIn,
        uint256 baseOut,
        uint256 quoteOut
    );

    ISwapRouter public immutable tranchessRouter;
    mapping(address => bool) public externalRouterAllowlist;

    constructor(address tranchessRouter_) public {
        tranchessRouter = ISwapRouter(tranchessRouter_);
    }

    function toggleExternalRouter(address externalRouter) external onlyOwner {
        bool enabled = !externalRouterAllowlist[externalRouter];
        externalRouterAllowlist[externalRouter] = enabled;
        emit SwapToggled(externalRouter, enabled);
    }

    function buyR(
        IFundV3 fund,
        address queenSwapOrPrimaryMarketRouter,
        uint256 maxQuote,
        address recipient,
        address tokenQuote,
        address externalRouter,
        address[] memory externalPath,
        address staking,
        uint256 version,
        uint256 outR
    ) external {
        require(externalRouterAllowlist[externalRouter], "Invalid external router");
        uint256 underlyingAmount;
        uint256 totalQuoteAmount;
        bytes memory data;
        {
            uint256 inQ = IPrimaryMarketV3(fund.primaryMarket()).getSplitForB(outR);
            underlyingAmount = IStableSwapCore(queenSwapOrPrimaryMarketRouter).getQuoteIn(inQ);
            // Calculate the exact amount of quote asset to pay
            totalQuoteAmount = IUniswapV2Router01(externalRouter).getAmountsIn(
                underlyingAmount,
                externalPath
            )[0];
            data = abi.encode(
                fund,
                queenSwapOrPrimaryMarketRouter,
                totalQuoteAmount,
                staking == address(0) ? recipient : staking,
                version,
                externalRouter,
                externalPath
            );
        }
        // Arrange the stable swap path
        IStableSwap tranchessPair = tranchessRouter.getSwap(fund.tokenB(), tokenQuote);
        address recipient_ = recipient;
        address tokenQuote_ = tokenQuote;
        // Calculate the amount of quote asset for selling BISHOP
        uint256 quoteAmount = tranchessPair.getQuoteOut(outR);
        // Send the user's portion of the payment to Tranchess swap
        uint256 resultAmount = totalQuoteAmount.sub(quoteAmount);
        require(resultAmount <= maxQuote, "Excessive input");
        IERC20(tokenQuote_).safeTransferFrom(msg.sender, address(this), resultAmount);
        tranchessPair.sell(version, quoteAmount, address(this), data);
        if (staking != address(0)) {
            ShareStaking(staking).deposit(TRANCHE_R, outR, recipient_, version);
        }
        emit SwapRook(recipient_, 0, resultAmount, outR, 0);
    }

    function sellR(
        IFundV3 fund,
        address queenSwapOrPrimaryMarketRouter,
        uint256 minQuote,
        address recipient,
        address tokenQuote,
        address externalRouter,
        address[] memory externalPath,
        uint256 version,
        uint256 inR
    ) external {
        require(externalRouterAllowlist[externalRouter], "Invalid external router");
        // Send the user's ROOK to this router
        fund.trancheTransferFrom(TRANCHE_R, msg.sender, address(this), inR, version);
        bytes memory data =
            abi.encode(
                fund,
                queenSwapOrPrimaryMarketRouter,
                minQuote,
                recipient,
                version,
                externalRouter,
                externalPath
            );
        tranchessRouter.getSwap(fund.tokenB(), tokenQuote).buy(version, inR, address(this), data);
    }

    function tranchessSwapCallback(
        uint256 baseOut,
        uint256 quoteOut,
        bytes calldata data
    ) external override {
        (
            IFundV3 fund,
            address queenSwapOrPrimaryMarketRouter,
            uint256 expectQuoteAmount,
            address recipient,
            uint256 version,
            ,

        ) = abi.decode(data, (IFundV3, address, uint256, address, uint256, address, address[]));
        address tokenQuote = IStableSwap(msg.sender).quoteAddress();
        require(
            msg.sender == address(tranchessRouter.getSwap(tokenQuote, fund.tokenB())),
            "Tranchess Pair check failed"
        );
        if (baseOut > 0) {
            uint256 resultAmount;
            {
                require(quoteOut == 0, "Unidirectional check failed");
                uint256 quoteAmount = IStableSwap(msg.sender).getQuoteIn(baseOut);
                // Merge BISHOP and ROOK into QUEEN
                uint256 outQ =
                    IPrimaryMarketV3(fund.primaryMarket()).merge(address(this), baseOut, version);

                // Redeem or swap QUEEN for underlying
                fund.trancheTransfer(TRANCHE_Q, queenSwapOrPrimaryMarketRouter, outQ, version);
                uint256 underlyingAmount =
                    IStableSwapCore(queenSwapOrPrimaryMarketRouter).sell(
                        version,
                        0,
                        address(this),
                        ""
                    );

                // Trade underlying for quote asset
                uint256 totalQuoteAmount =
                    _externalSwap(data, underlyingAmount, fund.tokenUnderlying(), tokenQuote)[1];
                // Send back quote asset to tranchess swap
                IERC20(tokenQuote).safeTransfer(msg.sender, quoteAmount);
                // Send the rest of quote asset to user
                resultAmount = totalQuoteAmount.sub(quoteAmount);
                require(resultAmount >= expectQuoteAmount, "Insufficient output");
                IERC20(tokenQuote).safeTransfer(recipient, resultAmount);
            }
            emit SwapRook(recipient, baseOut, 0, 0, resultAmount);
        } else {
            address tokenUnderlying = fund.tokenUnderlying();
            // Trade quote asset for underlying asset
            uint256 underlyingAmount =
                _externalSwap(data, expectQuoteAmount, tokenQuote, tokenUnderlying)[1];

            // Create or swap borrowed underlying for QUEEN
            IERC20(tokenUnderlying).safeTransfer(queenSwapOrPrimaryMarketRouter, underlyingAmount);
            uint256 outQ =
                IStableSwapCore(queenSwapOrPrimaryMarketRouter).buy(version, 0, address(this), "");

            // Split QUEEN into BISHOP and ROOK
            uint256 outB =
                IPrimaryMarketV3(fund.primaryMarket()).split(address(this), outQ, version);
            // Send back BISHOP to tranchess swap
            fund.trancheTransfer(TRANCHE_B, msg.sender, outB, version);
            // Send ROOK to user
            fund.trancheTransfer(TRANCHE_R, recipient, outB, version);
        }
    }

    function _externalSwap(
        bytes memory data,
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) private returns (uint256[] memory amounts) {
        (, , , , , address externalRouter, address[] memory externalPath) =
            abi.decode(data, (address, address, uint256, address, uint256, address, address[]));
        require(externalPath.length > 1, "Invalid external path");
        require(externalPath[0] == tokenIn, "Invalid token in");
        require(externalPath[externalPath.length - 1] == tokenOut, "Invalid token out");
        IERC20(tokenIn).safeApprove(externalRouter, amountIn);
        amounts = IUniswapV2Router01(externalRouter).swapExactTokensForTokens(
            amountIn,
            0,
            externalPath,
            address(this),
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../../utils/SafeDecimalMath.sol";
import "../../utils/CoreUtility.sol";

import "../interfaces/IFund.sol";
import "../../interfaces/IChessController.sol";
import "../../interfaces/IChessSchedule.sol";
import "../interfaces/ITrancheIndex.sol";
import "../interfaces/IPrimaryMarket.sol";

abstract contract Staking is ITrancheIndex, CoreUtility {
    /// @dev Reserved storage slots for future sibling contract upgrades
    uint256[32] private _reservedSlots;

    using Math for uint256;
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    event Deposited(uint256 tranche, address account, uint256 amount);
    event Withdrawn(uint256 tranche, address account, uint256 amount);

    uint256 private constant MAX_ITERATIONS = 500;

    uint256 private constant REWARD_WEIGHT_A = 4;
    uint256 private constant REWARD_WEIGHT_B = 2;
    uint256 private constant REWARD_WEIGHT_M = 3;

    IFund public immutable fund;
    IERC20 private immutable tokenM;
    IERC20 private immutable tokenA;
    IERC20 private immutable tokenB;

    /// @notice The Chess release schedule contract.
    IChessSchedule public immutable chessSchedule;

    uint256 public immutable guardedLaunchStart;

    uint256 private _rate;

    /// @notice The controller contract.
    IChessController public immutable chessController;

    /// @notice Quote asset for the exchange. Each exchange only handles one quote asset
    address public immutable quoteAssetAddress;

    /// @dev Total amount of user shares, i.e. sum of all entries in `_availableBalances` and
    ///      `_lockedBalances`. Note that these values can be smaller than the amount of
    ///      share tokens held by this contract, because shares locked in unsettled trades
    ///      are not included in total supplies or any user's balance.
    uint256[TRANCHE_COUNT] private _totalSupplies;

    /// @dev Rebalance version of `_totalSupplies`.
    uint256 private _totalSupplyVersion;

    /// @dev Amount of shares that can be withdrawn or traded by each user.
    mapping(address => uint256[TRANCHE_COUNT]) private _availableBalances;

    /// @dev Amount of shares that are locked in ask orders.
    mapping(address => uint256[TRANCHE_COUNT]) private _lockedBalances;

    /// @dev Rebalance version mapping for `_availableBalances`.
    mapping(address => uint256) private _balanceVersions;

    /// @dev 1e27 * ∫(rate(t) / totalWeight(t) dt) from the latest rebalance till checkpoint.
    uint256 private _invTotalWeightIntegral;

    /// @dev Final `_invTotalWeightIntegral` before each rebalance.
    ///      These values are accessed in a loop in `_userCheckpoint()` with bounds checking.
    ///      So we store them in a fixed-length array, in order to make compiler-generated
    ///      bounds checking on every access cheaper. The actual length of this array is stored in
    ///      `_historicalIntegralSize` and should be explicitly checked when necessary.
    uint256[65535] private _historicalIntegrals;

    /// @dev Actual length of the `_historicalIntegrals` array, which always equals to the number of
    ///      historical rebalances after `checkpoint()` is called.
    uint256 private _historicalIntegralSize;

    /// @dev Timestamp when checkpoint() is called.
    uint256 private _checkpointTimestamp;

    /// @dev Snapshot of `_invTotalWeightIntegral` per user.
    mapping(address => uint256) private _userIntegrals;

    /// @dev Mapping of account => claimable rewards.
    mapping(address => uint256) private _claimableRewards;

    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 guardedLaunchStart_
    ) public {
        fund = IFund(fund_);
        tokenM = IERC20(IFund(fund_).tokenM());
        tokenA = IERC20(IFund(fund_).tokenA());
        tokenB = IERC20(IFund(fund_).tokenB());
        chessSchedule = IChessSchedule(chessSchedule_);
        chessController = IChessController(chessController_);
        quoteAssetAddress = quoteAssetAddress_;
        _checkpointTimestamp = block.timestamp;
        guardedLaunchStart = guardedLaunchStart_;

        _rate = IChessSchedule(chessSchedule_).getRate(block.timestamp);
    }

    /// @notice Return weight of given balance with respect to rewards.
    /// @param amountM Amount of Token M
    /// @param amountA Amount of Token A
    /// @param amountB Amount of Token B
    /// @return Rewarding weight of the balance
    function rewardWeight(
        uint256 amountM,
        uint256 amountA,
        uint256 amountB
    ) public pure returns (uint256) {
        return
            amountM.mul(REWARD_WEIGHT_M).add(amountA.mul(REWARD_WEIGHT_A)).add(
                amountB.mul(REWARD_WEIGHT_B)
            ) / REWARD_WEIGHT_M;
    }

    function totalSupply(uint256 tranche) external view returns (uint256) {
        uint256 totalSupplyM = _totalSupplies[TRANCHE_M];
        uint256 totalSupplyA = _totalSupplies[TRANCHE_A];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];

        uint256 version = _totalSupplyVersion;
        uint256 rebalanceSize = fund.getRebalanceSize();
        if (version < rebalanceSize) {
            (totalSupplyM, totalSupplyA, totalSupplyB) = fund.batchRebalance(
                totalSupplyM,
                totalSupplyA,
                totalSupplyB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return totalSupplyM;
        } else if (tranche == TRANCHE_A) {
            return totalSupplyA;
        } else {
            return totalSupplyB;
        }
    }

    function availableBalanceOf(uint256 tranche, address account) external view returns (uint256) {
        uint256 amountM = _availableBalances[account][TRANCHE_M];
        uint256 amountA = _availableBalances[account][TRANCHE_A];
        uint256 amountB = _availableBalances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = fund.getRebalanceSize();
        if (version < rebalanceSize) {
            (amountM, amountA, amountB) = fund.batchRebalance(
                amountM,
                amountA,
                amountB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    function lockedBalanceOf(uint256 tranche, address account) external view returns (uint256) {
        uint256 amountM = _lockedBalances[account][TRANCHE_M];
        uint256 amountA = _lockedBalances[account][TRANCHE_A];
        uint256 amountB = _lockedBalances[account][TRANCHE_B];

        if (tranche == TRANCHE_M) {
            if (amountM == 0 && amountA == 0 && amountB == 0) return 0;
        } else if (tranche == TRANCHE_A) {
            if (amountA == 0) return 0;
        } else {
            if (amountB == 0) return 0;
        }

        uint256 version = _balanceVersions[account];
        uint256 rebalanceSize = fund.getRebalanceSize();
        if (version < rebalanceSize) {
            (amountM, amountA, amountB) = fund.batchRebalance(
                amountM,
                amountA,
                amountB,
                version,
                rebalanceSize
            );
        }

        if (tranche == TRANCHE_M) {
            return amountM;
        } else if (tranche == TRANCHE_A) {
            return amountA;
        } else {
            return amountB;
        }
    }

    function balanceVersion(address account) external view returns (uint256) {
        return _balanceVersions[account];
    }

    /// @dev Deposit to get rewards
    /// @param tranche Tranche of the share
    /// @param amount The amount to deposit
    function deposit(uint256 tranche, uint256 amount) public {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(msg.sender, rebalanceSize);
        if (tranche == TRANCHE_M) {
            tokenM.safeTransferFrom(msg.sender, address(this), amount);
        } else if (tranche == TRANCHE_A) {
            tokenA.safeTransferFrom(msg.sender, address(this), amount);
        } else {
            tokenB.safeTransferFrom(msg.sender, address(this), amount);
        }
        _availableBalances[msg.sender][tranche] = _availableBalances[msg.sender][tranche].add(
            amount
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].add(amount);

        emit Deposited(tranche, msg.sender, amount);
    }

    /// @dev Claim settled Token M from the primary market and deposit to get rewards
    /// @param primaryMarket The primary market to claim shares from
    function claimAndDeposit(address primaryMarket) external {
        (uint256 createdShares, ) = IPrimaryMarket(primaryMarket).claim(msg.sender);
        deposit(TRANCHE_M, createdShares);
    }

    /// @dev Withdraw
    /// @param tranche Tranche of the share
    /// @param amount The amount to deposit
    function withdraw(uint256 tranche, uint256 amount) external {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(msg.sender, rebalanceSize);
        _availableBalances[msg.sender][tranche] = _availableBalances[msg.sender][tranche].sub(
            amount,
            "Insufficient balance to withdraw"
        );
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
        if (tranche == TRANCHE_M) {
            tokenM.safeTransfer(msg.sender, amount);
        } else if (tranche == TRANCHE_A) {
            tokenA.safeTransfer(msg.sender, amount);
        } else {
            tokenB.safeTransfer(msg.sender, amount);
        }

        emit Withdrawn(tranche, msg.sender, amount);
    }

    /// @notice Transform share balance to a given rebalance version, or to the latest version
    ///         if `targetVersion` is zero.
    /// @param account Account of the balance to rebalance
    /// @param targetVersion The target rebalance version, or zero for the latest version
    function refreshBalance(address account, uint256 targetVersion) external {
        uint256 rebalanceSize = fund.getRebalanceSize();
        if (targetVersion == 0) {
            targetVersion = rebalanceSize;
        } else {
            require(targetVersion <= rebalanceSize, "Target version out of bound");
        }
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, targetVersion);
    }

    /// @notice Return claimable rewards of an account till now.
    ///
    ///         This function should be call as a "view" function off-chain to get
    ///         the return value, e.g. using `contract.claimableRewards.call(account)` in web3
    ///         or `contract.callStatic.claimableRewards(account)` in ethers.js.
    /// @param account Address of an account
    /// @return Amount of claimable rewards
    function claimableRewards(address account) external returns (uint256) {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        return _claimableRewards[account];
    }

    /// @notice Claim the rewards for an account.
    /// @param account Account to claim its rewards
    function claimRewards(address account) external {
        require(
            block.timestamp >= guardedLaunchStart + 15 days,
            "Cannot claim during guarded launch"
        );
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _claim(account);
    }

    /// @dev Transfer shares from the sender to the contract internally
    /// @param tranche Tranche of the share
    /// @param sender Sender address
    /// @param amount The amount to transfer
    function _tradeAvailable(
        uint256 tranche,
        address sender,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(sender, rebalanceSize);
        _availableBalances[sender][tranche] = _availableBalances[sender][tranche].sub(amount);
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
    }

    function _rebalanceAndClearTrade(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        if (amountVersion < rebalanceSize) {
            (amountM, amountA, amountB) = fund.batchRebalance(
                amountM,
                amountA,
                amountB,
                amountVersion,
                rebalanceSize
            );
        }
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        if (amountM > 0) {
            available[TRANCHE_M] = available[TRANCHE_M].add(amountM);
            _totalSupplies[TRANCHE_M] = _totalSupplies[TRANCHE_M].add(amountM);
        }
        if (amountA > 0) {
            available[TRANCHE_A] = available[TRANCHE_A].add(amountA);
            _totalSupplies[TRANCHE_A] = _totalSupplies[TRANCHE_A].add(amountA);
        }
        if (amountB > 0) {
            available[TRANCHE_B] = available[TRANCHE_B].add(amountB);
            _totalSupplies[TRANCHE_B] = _totalSupplies[TRANCHE_B].add(amountB);
        }
        return (amountM, amountA, amountB);
    }

    function _lock(
        uint256 tranche,
        address account,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _availableBalances[account][tranche] = _availableBalances[account][tranche].sub(
            amount,
            "Insufficient balance to lock"
        );
        _lockedBalances[account][tranche] = _lockedBalances[account][tranche].add(amount);
    }

    function _rebalanceAndUnlock(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    ) internal {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        if (amountVersion < rebalanceSize) {
            (amountM, amountA, amountB) = fund.batchRebalance(
                amountM,
                amountA,
                amountB,
                amountVersion,
                rebalanceSize
            );
        }
        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        if (amountM > 0) {
            available[TRANCHE_M] = available[TRANCHE_M].add(amountM);
            locked[TRANCHE_M] = locked[TRANCHE_M].sub(amountM);
        }
        if (amountA > 0) {
            available[TRANCHE_A] = available[TRANCHE_A].add(amountA);
            locked[TRANCHE_A] = locked[TRANCHE_A].sub(amountA);
        }
        if (amountB > 0) {
            available[TRANCHE_B] = available[TRANCHE_B].add(amountB);
            locked[TRANCHE_B] = locked[TRANCHE_B].sub(amountB);
        }
    }

    function _tradeLocked(
        uint256 tranche,
        address account,
        uint256 amount
    ) internal {
        uint256 rebalanceSize = fund.getRebalanceSize();
        _checkpoint(rebalanceSize);
        _userCheckpoint(account, rebalanceSize);
        _lockedBalances[account][tranche] = _lockedBalances[account][tranche].sub(amount);
        _totalSupplies[tranche] = _totalSupplies[tranche].sub(amount);
    }

    /// @dev Transfer claimable rewards to an account. Rewards since the last user checkpoint
    ///      is not included. This function should always be called after `_userCheckpoint()`,
    ///      in order for the user to get all rewards till now.
    /// @param account Address of the account
    function _claim(address account) internal {
        chessSchedule.mint(account, _claimableRewards[account]);
        _claimableRewards[account] = 0;
    }

    /// @dev Transform total supplies to the latest rebalance version and make a global reward checkpoint.
    /// @param rebalanceSize The number of existing rebalances. It must be the same as
    ///                       `fund.getRebalanceSize()`.
    function _checkpoint(uint256 rebalanceSize) private {
        uint256 timestamp = _checkpointTimestamp;
        if (timestamp >= block.timestamp) {
            return;
        }

        uint256 integral = _invTotalWeightIntegral;
        uint256 endWeek = _endOfWeek(timestamp);
        uint256 weeklyPercentage =
            chessController.getFundRelativeWeight(address(this), endWeek - 1 weeks);
        uint256 version = _totalSupplyVersion;
        uint256 rebalanceTimestamp;
        if (version < rebalanceSize) {
            rebalanceTimestamp = fund.getRebalanceTimestamp(version);
        } else {
            rebalanceTimestamp = type(uint256).max;
        }
        uint256 rate = _rate;
        uint256 totalSupplyM = _totalSupplies[TRANCHE_M];
        uint256 totalSupplyA = _totalSupplies[TRANCHE_A];
        uint256 totalSupplyB = _totalSupplies[TRANCHE_B];
        uint256 weight = rewardWeight(totalSupplyM, totalSupplyA, totalSupplyB);
        uint256 timestamp_ = timestamp; // avoid stack too deep

        for (uint256 i = 0; i < MAX_ITERATIONS && timestamp_ < block.timestamp; i++) {
            uint256 endTimestamp = rebalanceTimestamp.min(endWeek).min(block.timestamp);

            if (weight > 0) {
                integral = integral.add(
                    rate
                        .mul(endTimestamp.sub(timestamp_))
                        .multiplyDecimal(weeklyPercentage)
                        .divideDecimalPrecise(weight)
                );
            }

            if (endTimestamp == rebalanceTimestamp) {
                uint256 oldSize = _historicalIntegralSize;
                _historicalIntegrals[oldSize] = integral;
                _historicalIntegralSize = oldSize + 1;

                integral = 0;
                (totalSupplyM, totalSupplyA, totalSupplyB) = fund.doRebalance(
                    totalSupplyM,
                    totalSupplyA,
                    totalSupplyB,
                    version
                );

                version++;
                weight = rewardWeight(totalSupplyM, totalSupplyA, totalSupplyB);

                if (version < rebalanceSize) {
                    rebalanceTimestamp = fund.getRebalanceTimestamp(version);
                } else {
                    rebalanceTimestamp = type(uint256).max;
                }
            }
            if (endTimestamp == endWeek) {
                rate = chessSchedule.getRate(endWeek);
                weeklyPercentage = chessController.getFundRelativeWeight(address(this), endWeek);
                endWeek += 1 weeks;
            }

            timestamp_ = endTimestamp;
        }

        _checkpointTimestamp = block.timestamp;
        _invTotalWeightIntegral = integral;
        if (_rate != rate) {
            _rate = rate;
        }
        if (_totalSupplyVersion != rebalanceSize) {
            _totalSupplies[TRANCHE_M] = totalSupplyM;
            _totalSupplies[TRANCHE_A] = totalSupplyA;
            _totalSupplies[TRANCHE_B] = totalSupplyB;
            _totalSupplyVersion = rebalanceSize;
        }
    }

    /// @dev Transform a user's balance to a given rebalance version and update this user's rewards.
    ///
    ///      In most cases, the target version is the latest version and this function cumulates
    ///      rewards till now. When this function is called from `refreshBalance()`,
    ///      `targetVersion` can be an older version, in which case rewards are cumulated till
    ///      the end of that version (i.e. timestamp of the transaction triggering the rebalance
    ///      with index `targetVersion`).
    ///
    ///      This function should always be called after `_checkpoint()` is called, so that
    ///      the global reward checkpoint is guarenteed up to date.
    /// @param account Account to update
    /// @param targetVersion The target rebalance version
    function _userCheckpoint(address account, uint256 targetVersion) private {
        uint256 oldVersion = _balanceVersions[account];
        if (oldVersion > targetVersion) {
            return;
        }
        uint256 userIntegral = _userIntegrals[account];
        uint256 integral;
        // This scope is to avoid the "stack too deep" error.
        {
            // We assume that this function is always called immediately after `_checkpoint()`,
            // which guarantees that `_historicalIntegralSize` equals to the number of historical
            // rebalances.
            uint256 rebalanceSize = _historicalIntegralSize;
            integral = targetVersion == rebalanceSize
                ? _invTotalWeightIntegral
                : _historicalIntegrals[targetVersion];
        }
        if (userIntegral == integral && oldVersion == targetVersion) {
            // Return immediately when the user's rewards have already been updated to
            // the target version.
            return;
        }

        uint256[TRANCHE_COUNT] storage available = _availableBalances[account];
        uint256[TRANCHE_COUNT] storage locked = _lockedBalances[account];
        uint256 availableM = available[TRANCHE_M];
        uint256 availableA = available[TRANCHE_A];
        uint256 availableB = available[TRANCHE_B];
        uint256 lockedM = locked[TRANCHE_M];
        uint256 lockedA = locked[TRANCHE_A];
        uint256 lockedB = locked[TRANCHE_B];
        uint256 rewards = _claimableRewards[account];
        for (uint256 i = oldVersion; i < targetVersion; i++) {
            uint256 weight =
                rewardWeight(
                    availableM.add(lockedM),
                    availableA.add(lockedA),
                    availableB.add(lockedB)
                );
            rewards = rewards.add(
                weight.multiplyDecimalPrecise(_historicalIntegrals[i].sub(userIntegral))
            );
            if (availableM != 0 || availableA != 0 || availableB != 0) {
                (availableM, availableA, availableB) = fund.doRebalance(
                    availableM,
                    availableA,
                    availableB,
                    i
                );
            }
            if (lockedM != 0 || lockedA != 0 || lockedB != 0) {
                (lockedM, lockedA, lockedB) = fund.doRebalance(lockedM, lockedA, lockedB, i);
            }
            userIntegral = 0;
        }
        uint256 weight =
            rewardWeight(availableM.add(lockedM), availableA.add(lockedA), availableB.add(lockedB));
        rewards = rewards.add(weight.multiplyDecimalPrecise(integral.sub(userIntegral)));
        address account_ = account; // Fix the "stack too deep" error
        _claimableRewards[account_] = rewards;
        _userIntegrals[account_] = integral;

        if (oldVersion < targetVersion) {
            if (available[TRANCHE_M] != availableM) {
                available[TRANCHE_M] = availableM;
            }
            if (available[TRANCHE_A] != availableA) {
                available[TRANCHE_A] = availableA;
            }
            if (available[TRANCHE_B] != availableB) {
                available[TRANCHE_B] = availableB;
            }
            if (locked[TRANCHE_M] != lockedM) {
                locked[TRANCHE_M] = lockedM;
            }
            if (locked[TRANCHE_A] != lockedA) {
                locked[TRANCHE_A] = lockedA;
            }
            if (locked[TRANCHE_B] != lockedB) {
                locked[TRANCHE_B] = lockedB;
            }
            _balanceVersions[account_] = targetVersion;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "../exchange/Staking.sol";

contract StakingTestWrapper is Staking {
    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 guardedLaunchStart_
    )
        public
        Staking(fund_, chessSchedule_, chessController_, quoteAssetAddress_, guardedLaunchStart_)
    {}

    function tradeAvailable(
        uint256 tranche,
        address sender,
        uint256 amount
    ) external {
        _tradeAvailable(tranche, sender, amount);
    }

    function rebalanceAndClearTrade(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    ) external {
        _rebalanceAndClearTrade(account, amountM, amountA, amountB, amountVersion);
    }

    function lock(
        uint256 tranche,
        address account,
        uint256 amount
    ) external {
        _lock(tranche, account, amount);
    }

    function rebalanceAndUnlock(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    ) external {
        _rebalanceAndUnlock(account, amountM, amountA, amountB, amountVersion);
    }

    function tradeLocked(
        uint256 tranche,
        address account,
        uint256 amount
    ) external {
        _tradeLocked(tranche, account, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "../exchange/StakingV2.sol";

contract StakingV2TestWrapper is StakingV2 {
    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 guardedLaunchStart_,
        address votingEscrow_
    )
        public
        StakingV2(
            fund_,
            chessSchedule_,
            chessController_,
            quoteAssetAddress_,
            guardedLaunchStart_,
            votingEscrow_
        )
    {}

    function initialize() external {
        _initializeStaking();
        _initializeStakingV2(msg.sender);
    }

    function tradeAvailable(
        uint256 tranche,
        address sender,
        uint256 amount
    ) external {
        _tradeAvailable(tranche, sender, amount);
    }

    function rebalanceAndClearTrade(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    ) external {
        _rebalanceAndClearTrade(account, amountM, amountA, amountB, amountVersion);
    }

    function lock(
        uint256 tranche,
        address account,
        uint256 amount
    ) external {
        _lock(tranche, account, amount);
    }

    function rebalanceAndUnlock(
        address account,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 amountVersion
    ) external {
        _rebalanceAndUnlock(account, amountM, amountA, amountB, amountVersion);
    }

    function tradeLocked(
        uint256 tranche,
        address account,
        uint256 amount
    ) external {
        _tradeLocked(tranche, account, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IFund.sol";

contract Share is IERC20 {
    uint8 public constant decimals = 18;

    string public name;
    string public symbol;
    uint256 private immutable _tranche;

    IFund public fund;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * _tranche is immutable: it can only be set once during construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address fund_,
        uint256 tranche_
    ) public {
        name = name_;
        symbol = symbol_;
        fund = IFund(fund_);
        _tranche = tranche_;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return fund.shareTotalSupply(_tranche);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view override returns (uint256) {
        return fund.shareBalanceOf(_tranche, account);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        fund.transfer(_tranche, msg.sender, recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return fund.shareAllowance(_tranche, owner, spender);
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        fund.approve(_tranche, msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint256 newAllowance = fund.transferFrom(_tranche, msg.sender, sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
        emit Approval(sender, msg.sender, newAllowance);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        uint256 newAllowance = fund.increaseAllowance(_tranche, msg.sender, spender, addedValue);
        emit Approval(msg.sender, spender, newAllowance);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 newAllowance =
            fund.decreaseAllowance(_tranche, msg.sender, spender, subtractedValue);
        emit Approval(msg.sender, spender, newAllowance);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../../utils/SafeDecimalMath.sol";

import {Order, OrderQueue, LibOrderQueue} from "./LibOrderQueue.sol";
import {
    UnsettledBuyTrade,
    UnsettledSellTrade,
    UnsettledTrade,
    LibUnsettledBuyTrade,
    LibUnsettledSellTrade
} from "./LibUnsettledTrade.sol";

import "./ExchangeRoles.sol";
import "./Staking.sol";

/// @title Tranchess's Exchange Contract
/// @notice A decentralized exchange to match premium-discount orders and clear trades
/// @author Tranchess
contract Exchange is ExchangeRoles, Staking {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[32] private _reservedSlots;

    using SafeDecimalMath for uint256;
    using LibOrderQueue for OrderQueue;
    using SafeERC20 for IERC20;
    using LibUnsettledBuyTrade for UnsettledBuyTrade;
    using LibUnsettledSellTrade for UnsettledSellTrade;

    /// @notice A maker bid order is placed.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to buy
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Amount of quote asset in the order, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    event BidOrderPlaced(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version,
        uint256 orderIndex
    );

    /// @notice A maker ask order is placed.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to sell
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Amount of base asset in the order
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    event AskOrderPlaced(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version,
        uint256 orderIndex
    );

    /// @notice A maker bid order is canceled.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Original amount of quote asset in the order, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    /// @param fillable Unfilled amount when the order is canceled, rounding precision to 18 for
    ///                 quote assets with precision other than 18 decimal places
    event BidOrderCanceled(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version,
        uint256 orderIndex,
        uint256 fillable
    );

    /// @notice A maker ask order is canceled.
    /// @param maker Account placing the order
    /// @param tranche Tranche of the share to sell
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Original amount of base asset in the order
    /// @param version The latest rebalance version when the order is placed
    /// @param orderIndex Index of the order in the order queue
    /// @param fillable Unfilled amount when the order is canceled
    event AskOrderCanceled(
        address indexed maker,
        uint256 indexed tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version,
        uint256 orderIndex,
        uint256 fillable
    );

    /// @notice Matching result of a taker bid order.
    /// @param taker Account placing the order
    /// @param tranche Tranche of the share
    /// @param quoteAmount Matched amount of quote asset, rounding precision to 18 for quote assets
    ///                    with precision other than 18 decimal places
    /// @param version Rebalance version of this trade
    /// @param lastMatchedPDLevel Premium-discount level of the last matched maker order
    /// @param lastMatchedOrderIndex Index of the last matched maker order in its order queue
    /// @param lastMatchedBaseAmount Matched base asset amount of the last matched maker order
    event BuyTrade(
        address indexed taker,
        uint256 indexed tranche,
        uint256 quoteAmount,
        uint256 version,
        uint256 lastMatchedPDLevel,
        uint256 lastMatchedOrderIndex,
        uint256 lastMatchedBaseAmount
    );

    /// @notice Matching result of a taker ask order.
    /// @param taker Account placing the order
    /// @param tranche Tranche of the share
    /// @param baseAmount Matched amount of base asset
    /// @param version Rebalance version of this trade
    /// @param lastMatchedPDLevel Premium-discount level of the last matched maker order
    /// @param lastMatchedOrderIndex Index of the last matched maker order in its order queue
    /// @param lastMatchedQuoteAmount Matched quote asset amount of the last matched maker order,
    ///                               rounding precision to 18 for quote assets with precision
    ///                               other than 18 decimal places
    event SellTrade(
        address indexed taker,
        uint256 indexed tranche,
        uint256 baseAmount,
        uint256 version,
        uint256 lastMatchedPDLevel,
        uint256 lastMatchedOrderIndex,
        uint256 lastMatchedQuoteAmount
    );

    /// @notice Settlement of unsettled trades of maker orders.
    /// @param account Account placing the related maker orders
    /// @param epoch Epoch of the settled trades
    /// @param amountM Amount of Token M added to the account's available balance
    /// @param amountA Amount of Token A added to the account's available balance
    /// @param amountB Amount of Token B added to the account's available balance
    /// @param quoteAmount Amount of quote asset transfered to the account, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    event MakerSettled(
        address indexed account,
        uint256 epoch,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 quoteAmount
    );

    /// @notice Settlement of unsettled trades of taker orders.
    /// @param account Account placing the related taker orders
    /// @param epoch Epoch of the settled trades
    /// @param amountM Amount of Token M added to the account's available balance
    /// @param amountA Amount of Token A added to the account's available balance
    /// @param amountB Amount of Token B added to the account's available balance
    /// @param quoteAmount Amount of quote asset transfered to the account, rounding precision to 18
    ///                    for quote assets with precision other than 18 decimal places
    event TakerSettled(
        address indexed account,
        uint256 epoch,
        uint256 amountM,
        uint256 amountA,
        uint256 amountB,
        uint256 quoteAmount
    );

    uint256 private constant EPOCH = 30 minutes; // An exchange epoch is 30 minutes long

    /// @dev Maker reserves 110% of the asset they want to trade, which would stop
    ///      losses for makers when the net asset values turn out volatile
    uint256 private constant MAKER_RESERVE_RATIO = 1.1e18;

    /// @dev Premium-discount level ranges from -10% to 10% with 0.25% as step size
    uint256 private constant PD_TICK = 0.0025e18;

    uint256 private constant MIN_PD = 0.9e18;
    uint256 private constant MAX_PD = 1.1e18;
    uint256 private constant PD_START = MIN_PD - PD_TICK;
    uint256 private constant PD_LEVEL_COUNT = (MAX_PD - MIN_PD) / PD_TICK + 1;

    /// @notice Minumum quote amount of maker bid orders with 18 decimal places
    uint256 public immutable minBidAmount;

    /// @notice Minumum base amount of maker ask orders
    uint256 public immutable minAskAmount;

    /// @notice Minumum base or quote amount of maker orders during guarded launch
    uint256 public immutable guardedLaunchMinOrderAmount;

    /// @dev A multipler that normalizes a quote asset balance to 18 decimal places.
    uint256 private immutable _quoteDecimalMultiplier;

    /// @notice Mapping of rebalance version => tranche => an array of order queues
    mapping(uint256 => mapping(uint256 => OrderQueue[PD_LEVEL_COUNT + 1])) public bids;
    mapping(uint256 => mapping(uint256 => OrderQueue[PD_LEVEL_COUNT + 1])) public asks;

    /// @notice Mapping of rebalance version => best bid premium-discount level of the three tranches.
    ///         Zero indicates that there is no bid order.
    mapping(uint256 => uint256[TRANCHE_COUNT]) public bestBids;

    /// @notice Mapping of rebalance version => best ask premium-discount level of the three tranches.
    ///         Zero or `PD_LEVEL_COUNT + 1` indicates that there is no ask order.
    mapping(uint256 => uint256[TRANCHE_COUNT]) public bestAsks;

    /// @notice Mapping of account => tranche => epoch => unsettled trade
    mapping(address => mapping(uint256 => mapping(uint256 => UnsettledTrade)))
        public unsettledTrades;

    /// @dev Mapping of epoch => rebalance version
    mapping(uint256 => uint256) private _epochVersions;

    constructor(
        address fund_,
        address chessSchedule_,
        address chessController_,
        address quoteAssetAddress_,
        uint256 quoteDecimals_,
        address votingEscrow_,
        uint256 minBidAmount_,
        uint256 minAskAmount_,
        uint256 makerRequirement_,
        uint256 guardedLaunchStart_,
        uint256 guardedLaunchMinOrderAmount_
    )
        public
        ExchangeRoles(votingEscrow_, makerRequirement_)
        Staking(fund_, chessSchedule_, chessController_, quoteAssetAddress_, guardedLaunchStart_)
    {
        minBidAmount = minBidAmount_;
        minAskAmount = minAskAmount_;
        guardedLaunchMinOrderAmount = guardedLaunchMinOrderAmount_;
        require(quoteDecimals_ <= 18, "Quote asset decimals larger than 18");
        _quoteDecimalMultiplier = 10**(18 - quoteDecimals_);
    }

    /// @notice Return end timestamp of the epoch containing a given timestamp.
    /// @param timestamp Timestamp within a given epoch
    /// @return The closest ending timestamp
    function endOfEpoch(uint256 timestamp) public pure returns (uint256) {
        return (timestamp / EPOCH) * EPOCH + EPOCH;
    }

    function getBidOrder(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    )
        external
        view
        returns (
            address maker,
            uint256 amount,
            uint256 fillable
        )
    {
        Order storage order = bids[version][tranche][pdLevel].list[index];
        maker = order.maker;
        amount = order.amount;
        fillable = order.fillable;
    }

    function getAskOrder(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    )
        external
        view
        returns (
            address maker,
            uint256 amount,
            uint256 fillable
        )
    {
        Order storage order = asks[version][tranche][pdLevel].list[index];
        maker = order.maker;
        amount = order.amount;
        fillable = order.fillable;
    }

    /// @notice Get all tranches' net asset values of a given time
    /// @param timestamp Timestamp of the net asset value
    /// @return estimatedNavM Token M's net asset value
    /// @return estimatedNavA Token A's net asset value
    /// @return estimatedNavB Token B's net asset value
    function estimateNavs(uint256 timestamp)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 price = fund.twapOracle().getTwap(timestamp);
        require(price != 0, "Price is not available");
        return fund.extrapolateNav(timestamp, price);
    }

    /// @notice Place a bid order for makers
    /// @param tranche Tranche of the base asset
    /// @param pdLevel Premium-discount level
    /// @param quoteAmount Quote asset amount with 18 decimal places
    /// @param version Current rebalance version. Revert if it is not the latest version.
    function placeBid(
        uint256 tranche,
        uint256 pdLevel,
        uint256 quoteAmount,
        uint256 version
    ) external onlyMaker {
        require(block.timestamp >= guardedLaunchStart + 8 days, "Guarded launch: market closed");
        if (block.timestamp < guardedLaunchStart + 4 weeks) {
            require(quoteAmount >= guardedLaunchMinOrderAmount, "Guarded launch: amount too low");
        } else {
            require(quoteAmount >= minBidAmount, "Quote amount too low");
        }
        uint256 bestAsk = bestAsks[version][tranche];
        require(
            pdLevel > 0 && pdLevel < (bestAsk == 0 ? PD_LEVEL_COUNT + 1 : bestAsk),
            "Invalid premium-discount level"
        );
        require(version == fund.getRebalanceSize(), "Invalid version");

        _transferQuoteFrom(msg.sender, quoteAmount);

        uint256 index = bids[version][tranche][pdLevel].append(msg.sender, quoteAmount, version);
        if (bestBids[version][tranche] < pdLevel) {
            bestBids[version][tranche] = pdLevel;
        }

        emit BidOrderPlaced(msg.sender, tranche, pdLevel, quoteAmount, version, index);
    }

    /// @notice Place an ask order for makers
    /// @param tranche Tranche of the base asset
    /// @param pdLevel Premium-discount level
    /// @param baseAmount Base asset amount
    /// @param version Current rebalance version. Revert if it is not the latest version.
    function placeAsk(
        uint256 tranche,
        uint256 pdLevel,
        uint256 baseAmount,
        uint256 version
    ) external onlyMaker {
        require(block.timestamp >= guardedLaunchStart + 8 days, "Guarded launch: market closed");
        if (block.timestamp < guardedLaunchStart + 4 weeks) {
            require(baseAmount >= guardedLaunchMinOrderAmount, "Guarded launch: amount too low");
        } else {
            require(baseAmount >= minAskAmount, "Base amount too low");
        }
        require(
            pdLevel > bestBids[version][tranche] && pdLevel <= PD_LEVEL_COUNT,
            "Invalid premium-discount level"
        );
        require(version == fund.getRebalanceSize(), "Invalid version");

        _lock(tranche, msg.sender, baseAmount);
        uint256 index = asks[version][tranche][pdLevel].append(msg.sender, baseAmount, version);
        uint256 oldBestAsk = bestAsks[version][tranche];
        if (oldBestAsk > pdLevel || oldBestAsk == 0) {
            bestAsks[version][tranche] = pdLevel;
        }

        emit AskOrderPlaced(msg.sender, tranche, pdLevel, baseAmount, version, index);
    }

    /// @notice Cancel a bid order
    /// @param version Order's rebalance version
    /// @param tranche Tranche of the order's base asset
    /// @param pdLevel Order's premium-discount level
    /// @param index Order's index in the order queue
    function cancelBid(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    ) external {
        OrderQueue storage orderQueue = bids[version][tranche][pdLevel];
        Order storage order = orderQueue.list[index];
        require(order.maker == msg.sender, "Maker address mismatched");

        uint256 fillable = order.fillable;
        emit BidOrderCanceled(msg.sender, tranche, pdLevel, order.amount, version, index, fillable);
        orderQueue.cancel(index);

        // Update bestBid
        if (bestBids[version][tranche] == pdLevel) {
            uint256 newBestBid = pdLevel;
            while (newBestBid > 0 && bids[version][tranche][newBestBid].isEmpty()) {
                newBestBid--;
            }
            bestBids[version][tranche] = newBestBid;
        }

        _transferQuote(msg.sender, fillable);
    }

    /// @notice Cancel an ask order
    /// @param version Order's rebalance version
    /// @param tranche Tranche of the order's base asset
    /// @param pdLevel Order's premium-discount level
    /// @param index Order's index in the order queue
    function cancelAsk(
        uint256 version,
        uint256 tranche,
        uint256 pdLevel,
        uint256 index
    ) external {
        OrderQueue storage orderQueue = asks[version][tranche][pdLevel];
        Order storage order = orderQueue.list[index];
        require(order.maker == msg.sender, "Maker address mismatched");

        uint256 fillable = order.fillable;
        emit AskOrderCanceled(msg.sender, tranche, pdLevel, order.amount, version, index, fillable);
        orderQueue.cancel(index);

        // Update bestAsk
        if (bestAsks[version][tranche] == pdLevel) {
            uint256 newBestAsk = pdLevel;
            while (newBestAsk <= PD_LEVEL_COUNT && asks[version][tranche][newBestAsk].isEmpty()) {
                newBestAsk++;
            }
            bestAsks[version][tranche] = newBestAsk;
        }

        if (tranche == TRANCHE_M) {
            _rebalanceAndUnlock(msg.sender, fillable, 0, 0, version);
        } else if (tranche == TRANCHE_A) {
            _rebalanceAndUnlock(msg.sender, 0, fillable, 0, version);
        } else {
            _rebalanceAndUnlock(msg.sender, 0, 0, fillable, version);
        }
    }

    /// @notice Buy Token M
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyM(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (uint256 estimatedNav, , ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_M, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Buy Token A
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyA(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (, uint256 estimatedNav, ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_A, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Buy Token B
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param quoteAmount Amount of quote assets (with 18 decimal places) willing to trade
    function buyB(
        uint256 version,
        uint256 maxPDLevel,
        uint256 quoteAmount
    ) external {
        (, , uint256 estimatedNav) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _buy(version, TRANCHE_B, maxPDLevel, estimatedNav, quoteAmount);
    }

    /// @notice Sell Token M
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token M willing to trade
    function sellM(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (uint256 estimatedNav, , ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_M, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Sell Token A
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token A willing to trade
    function sellA(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (, uint256 estimatedNav, ) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_A, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Sell Token B
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param baseAmount Amount of Token B willing to trade
    function sellB(
        uint256 version,
        uint256 minPDLevel,
        uint256 baseAmount
    ) external {
        (, , uint256 estimatedNav) = estimateNavs(endOfEpoch(block.timestamp) - 2 * EPOCH);
        _sell(version, TRANCHE_B, minPDLevel, estimatedNav, baseAmount);
    }

    /// @notice Settle trades of a specified epoch for makers
    /// @param account Address of the maker
    /// @param epoch A specified epoch's end timestamp
    /// @return amountM Token M amount added to msg.sender's available balance
    /// @return amountA Token A amount added to msg.sender's available balance
    /// @return amountB Token B amount added to msg.sender's available balance
    /// @return quoteAmount Quote asset amount transfered to msg.sender, rounding precison to 18
    ///                     for quote assets with precision other than 18 decimal places
    function settleMaker(address account, uint256 epoch)
        external
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 quoteAmount
        )
    {
        (uint256 estimatedNavM, uint256 estimatedNavA, uint256 estimatedNavB) =
            estimateNavs(epoch.add(EPOCH));

        uint256 quoteAmountM;
        uint256 quoteAmountA;
        uint256 quoteAmountB;
        (amountM, quoteAmountM) = _settleMaker(account, TRANCHE_M, estimatedNavM, epoch);
        (amountA, quoteAmountA) = _settleMaker(account, TRANCHE_A, estimatedNavA, epoch);
        (amountB, quoteAmountB) = _settleMaker(account, TRANCHE_B, estimatedNavB, epoch);

        uint256 version = _epochVersions[epoch];
        (amountM, amountA, amountB) = _rebalanceAndClearTrade(
            account,
            amountM,
            amountA,
            amountB,
            version
        );
        quoteAmount = quoteAmountM.add(quoteAmountA).add(quoteAmountB);
        _transferQuote(account, quoteAmount);

        emit MakerSettled(account, epoch, amountM, amountA, amountB, quoteAmount);
    }

    /// @notice Settle trades of a specified epoch for takers
    /// @param account Address of the maker
    /// @param epoch A specified epoch's end timestamp
    /// @return amountM Token M amount added to msg.sender's available balance
    /// @return amountA Token A amount added to msg.sender's available balance
    /// @return amountB Token B amount added to msg.sender's available balance
    /// @return quoteAmount Quote asset amount transfered to msg.sender, rounding precison to 18
    ///                     for quote assets with precision other than 18 decimal places
    function settleTaker(address account, uint256 epoch)
        external
        returns (
            uint256 amountM,
            uint256 amountA,
            uint256 amountB,
            uint256 quoteAmount
        )
    {
        (uint256 estimatedNavM, uint256 estimatedNavA, uint256 estimatedNavB) =
            estimateNavs(epoch.add(EPOCH));

        uint256 quoteAmountM;
        uint256 quoteAmountA;
        uint256 quoteAmountB;
        (amountM, quoteAmountM) = _settleTaker(account, TRANCHE_M, estimatedNavM, epoch);
        (amountA, quoteAmountA) = _settleTaker(account, TRANCHE_A, estimatedNavA, epoch);
        (amountB, quoteAmountB) = _settleTaker(account, TRANCHE_B, estimatedNavB, epoch);

        uint256 version = _epochVersions[epoch];
        (amountM, amountA, amountB) = _rebalanceAndClearTrade(
            account,
            amountM,
            amountA,
            amountB,
            version
        );
        quoteAmount = quoteAmountM.add(quoteAmountA).add(quoteAmountB);
        _transferQuote(account, quoteAmount);

        emit TakerSettled(account, epoch, amountM, amountA, amountB, quoteAmount);
    }

    /// @dev Buy share
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param tranche Tranche of the base asset
    /// @param maxPDLevel Maximal premium-discount level accepted
    /// @param estimatedNav Estimated net asset value of the base asset
    /// @param quoteAmount Amount of quote assets willing to trade with 18 decimal places
    function _buy(
        uint256 version,
        uint256 tranche,
        uint256 maxPDLevel,
        uint256 estimatedNav,
        uint256 quoteAmount
    ) internal onlyActive {
        require(maxPDLevel > 0 && maxPDLevel <= PD_LEVEL_COUNT, "Invalid premium-discount level");
        require(version == fund.getRebalanceSize(), "Invalid version");
        require(estimatedNav > 0, "Zero estimated NAV");

        UnsettledBuyTrade memory totalTrade;
        uint256 epoch = endOfEpoch(block.timestamp);

        // Record rebalance version in the first transaction in the epoch
        if (_epochVersions[epoch] == 0) {
            _epochVersions[epoch] = version;
        }

        UnsettledBuyTrade memory currentTrade;
        uint256 orderIndex = 0;
        uint256 pdLevel = bestAsks[version][tranche];
        if (pdLevel == 0) {
            // Zero best ask indicates that no ask order is ever placed.
            // We set pdLevel beyond the largest valid level, forcing the following loop
            // to exit immediately.
            pdLevel = PD_LEVEL_COUNT + 1;
        }
        for (; pdLevel <= maxPDLevel; pdLevel++) {
            uint256 price = pdLevel.mul(PD_TICK).add(PD_START).multiplyDecimal(estimatedNav);
            OrderQueue storage orderQueue = asks[version][tranche][pdLevel];
            orderIndex = orderQueue.head;
            while (orderIndex != 0) {
                Order storage order = orderQueue.list[orderIndex];

                // If the order initiator is no longer qualified for maker,
                // we skip the order and the linked-list-based order queue
                // would never traverse the order again
                if (!isMaker(order.maker)) {
                    orderIndex = order.next;
                    continue;
                }

                // Calculate the current trade assuming that the taker would be completely filled.
                currentTrade.frozenQuote = quoteAmount.sub(totalTrade.frozenQuote);
                currentTrade.reservedBase = currentTrade.frozenQuote.mul(MAKER_RESERVE_RATIO).div(
                    price
                );

                if (currentTrade.reservedBase < order.fillable) {
                    // Taker is completely filled.
                    currentTrade.effectiveQuote = currentTrade.frozenQuote.divideDecimal(
                        pdLevel.mul(PD_TICK).add(PD_START)
                    );
                } else {
                    // Maker is completely filled. Recalculate the current trade.
                    currentTrade.frozenQuote = order.fillable.mul(price).div(MAKER_RESERVE_RATIO);
                    currentTrade.effectiveQuote = order.fillable.mul(estimatedNav).div(
                        MAKER_RESERVE_RATIO
                    );
                    currentTrade.reservedBase = order.fillable;
                }
                totalTrade.frozenQuote = totalTrade.frozenQuote.add(currentTrade.frozenQuote);
                totalTrade.effectiveQuote = totalTrade.effectiveQuote.add(
                    currentTrade.effectiveQuote
                );
                totalTrade.reservedBase = totalTrade.reservedBase.add(currentTrade.reservedBase);
                unsettledTrades[order.maker][tranche][epoch].makerSell.add(currentTrade);

                // There is no need to rebalance for maker; the fact that the order could
                // be filled here indicates that the maker is in the latest version
                _tradeLocked(tranche, order.maker, currentTrade.reservedBase);

                uint256 orderNewFillable = order.fillable.sub(currentTrade.reservedBase);
                if (orderNewFillable > 0) {
                    // Maker is not completely filled. Matching ends here.
                    order.fillable = orderNewFillable;
                    break;
                } else {
                    // Delete the completely filled maker order.
                    orderIndex = orderQueue.fill(orderIndex);
                }
            }

            orderQueue.updateHead(orderIndex);
            if (orderIndex != 0) {
                // This premium-discount level is not completely filled. Matching ends here.
                if (bestAsks[version][tranche] != pdLevel) {
                    bestAsks[version][tranche] = pdLevel;
                }
                break;
            }
        }
        emit BuyTrade(
            msg.sender,
            tranche,
            totalTrade.frozenQuote,
            version,
            pdLevel,
            orderIndex,
            orderIndex == 0 ? 0 : currentTrade.reservedBase
        );
        if (orderIndex == 0) {
            // Matching ends by completely filling all orders at and below the specified
            // premium-discount level `maxPDLevel`.
            // Find the new best ask beyond that level.
            for (; pdLevel <= PD_LEVEL_COUNT; pdLevel++) {
                if (!asks[version][tranche][pdLevel].isEmpty()) {
                    break;
                }
            }
            bestAsks[version][tranche] = pdLevel;
        }

        require(
            totalTrade.frozenQuote > 0,
            "Nothing can be bought at the given premium-discount level"
        );
        _transferQuoteFrom(msg.sender, totalTrade.frozenQuote);
        unsettledTrades[msg.sender][tranche][epoch].takerBuy.add(totalTrade);
    }

    /// @dev Sell share
    /// @param version Current rebalance version. Revert if it is not the latest version.
    /// @param tranche Tranche of the base asset
    /// @param minPDLevel Minimal premium-discount level accepted
    /// @param estimatedNav Estimated net asset value of the base asset
    /// @param baseAmount Amount of base assets willing to trade
    function _sell(
        uint256 version,
        uint256 tranche,
        uint256 minPDLevel,
        uint256 estimatedNav,
        uint256 baseAmount
    ) internal onlyActive {
        require(minPDLevel > 0 && minPDLevel <= PD_LEVEL_COUNT, "Invalid premium-discount level");
        require(version == fund.getRebalanceSize(), "Invalid version");
        require(estimatedNav > 0, "Zero estimated NAV");

        UnsettledSellTrade memory totalTrade;
        uint256 epoch = endOfEpoch(block.timestamp);

        // Record rebalance version in the first transaction in the epoch
        if (_epochVersions[epoch] == 0) {
            _epochVersions[epoch] = version;
        }

        UnsettledSellTrade memory currentTrade;
        uint256 orderIndex;
        uint256 pdLevel = bestBids[version][tranche];
        for (; pdLevel >= minPDLevel; pdLevel--) {
            uint256 price = pdLevel.mul(PD_TICK).add(PD_START).multiplyDecimal(estimatedNav);
            OrderQueue storage orderQueue = bids[version][tranche][pdLevel];
            orderIndex = orderQueue.head;
            while (orderIndex != 0) {
                Order storage order = orderQueue.list[orderIndex];

                // If the order initiator is no longer qualified for maker,
                // we skip the order and the linked-list-based order queue
                // would never traverse the order again
                if (!isMaker(order.maker)) {
                    orderIndex = order.next;
                    continue;
                }

                currentTrade.frozenBase = baseAmount.sub(totalTrade.frozenBase);
                currentTrade.reservedQuote = currentTrade
                    .frozenBase
                    .multiplyDecimal(MAKER_RESERVE_RATIO)
                    .multiplyDecimal(price);

                if (currentTrade.reservedQuote < order.fillable) {
                    // Taker is completely filled
                    currentTrade.effectiveBase = currentTrade.frozenBase.multiplyDecimal(
                        pdLevel.mul(PD_TICK).add(PD_START)
                    );
                } else {
                    // Maker is completely filled. Recalculate the current trade.
                    currentTrade.frozenBase = order.fillable.divideDecimal(price).divideDecimal(
                        MAKER_RESERVE_RATIO
                    );
                    currentTrade.effectiveBase = order
                        .fillable
                        .divideDecimal(estimatedNav)
                        .divideDecimal(MAKER_RESERVE_RATIO);
                    currentTrade.reservedQuote = order.fillable;
                }
                totalTrade.frozenBase = totalTrade.frozenBase.add(currentTrade.frozenBase);
                totalTrade.effectiveBase = totalTrade.effectiveBase.add(currentTrade.effectiveBase);
                totalTrade.reservedQuote = totalTrade.reservedQuote.add(currentTrade.reservedQuote);
                unsettledTrades[order.maker][tranche][epoch].makerBuy.add(currentTrade);

                uint256 orderNewFillable = order.fillable.sub(currentTrade.reservedQuote);
                if (orderNewFillable > 0) {
                    // Maker is not completely filled. Matching ends here.
                    order.fillable = orderNewFillable;
                    break;
                } else {
                    // Delete the completely filled maker order.
                    orderIndex = orderQueue.fill(orderIndex);
                }
            }

            orderQueue.updateHead(orderIndex);
            if (orderIndex != 0) {
                // This premium-discount level is not completely filled. Matching ends here.
                if (bestBids[version][tranche] != pdLevel) {
                    bestBids[version][tranche] = pdLevel;
                }
                break;
            }
        }
        emit SellTrade(
            msg.sender,
            tranche,
            totalTrade.frozenBase,
            version,
            pdLevel,
            orderIndex,
            orderIndex == 0 ? 0 : currentTrade.reservedQuote
        );
        if (orderIndex == 0) {
            // Matching ends by completely filling all orders at and above the specified
            // premium-discount level `minPDLevel`.
            // Find the new best bid beyond that level.
            for (; pdLevel > 0; pdLevel--) {
                if (!bids[version][tranche][pdLevel].isEmpty()) {
                    break;
                }
            }
            bestBids[version][tranche] = pdLevel;
        }

        require(
            totalTrade.frozenBase > 0,
            "Nothing can be sold at the given premium-discount level"
        );
        _tradeAvailable(tranche, msg.sender, totalTrade.frozenBase);
        unsettledTrades[msg.sender][tranche][epoch].takerSell.add(totalTrade);
    }

    /// @dev Settle both buy and sell trades of a specified epoch for takers
    /// @param account Taker address
    /// @param tranche Tranche of the base asset
    /// @param estimatedNav Estimated net asset value for the base asset
    /// @param epoch The epoch's end timestamp
    function _settleTaker(
        address account,
        uint256 tranche,
        uint256 estimatedNav,
        uint256 epoch
    ) internal returns (uint256 baseAmount, uint256 quoteAmount) {
        UnsettledTrade storage unsettledTrade = unsettledTrades[account][tranche][epoch];

        // Settle buy trade
        UnsettledBuyTrade memory takerBuy = unsettledTrade.takerBuy;
        if (takerBuy.frozenQuote > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _buyTradeResult(takerBuy, estimatedNav);
            baseAmount = executionBase;
            quoteAmount = takerBuy.frozenQuote.sub(executionQuote);
            delete unsettledTrade.takerBuy;
        }

        // Settle sell trade
        UnsettledSellTrade memory takerSell = unsettledTrade.takerSell;
        if (takerSell.frozenBase > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _sellTradeResult(takerSell, estimatedNav);
            quoteAmount = quoteAmount.add(executionQuote);
            baseAmount = baseAmount.add(takerSell.frozenBase.sub(executionBase));
            delete unsettledTrade.takerSell;
        }
    }

    /// @dev Settle both buy and sell trades of a specified epoch for makers
    /// @param account Maker address
    /// @param tranche Tranche of the base asset
    /// @param estimatedNav Estimated net asset value for the base asset
    /// @param epoch The epoch's end timestamp
    function _settleMaker(
        address account,
        uint256 tranche,
        uint256 estimatedNav,
        uint256 epoch
    ) internal returns (uint256 baseAmount, uint256 quoteAmount) {
        UnsettledTrade storage unsettledTrade = unsettledTrades[account][tranche][epoch];

        // Settle buy trade
        UnsettledSellTrade memory makerBuy = unsettledTrade.makerBuy;
        if (makerBuy.frozenBase > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _sellTradeResult(makerBuy, estimatedNav);
            baseAmount = executionBase;
            quoteAmount = makerBuy.reservedQuote.sub(executionQuote);
            delete unsettledTrade.makerBuy;
        }

        // Settle sell trade
        UnsettledBuyTrade memory makerSell = unsettledTrade.makerSell;
        if (makerSell.frozenQuote > 0) {
            (uint256 executionQuote, uint256 executionBase) =
                _buyTradeResult(makerSell, estimatedNav);
            quoteAmount = quoteAmount.add(executionQuote);
            baseAmount = baseAmount.add(makerSell.reservedBase.sub(executionBase));
            delete unsettledTrade.makerSell;
        }
    }

    /// @dev Calculate the result of an unsettled buy trade with a given NAV
    /// @param buyTrade Buy trade result of this particular epoch
    /// @param nav Net asset value for the base asset
    /// @return executionQuote Real amount of quote asset waiting for settlment
    /// @return executionBase Real amount of base asset waiting for settlment
    function _buyTradeResult(UnsettledBuyTrade memory buyTrade, uint256 nav)
        internal
        pure
        returns (uint256 executionQuote, uint256 executionBase)
    {
        uint256 reservedBase = buyTrade.reservedBase;
        uint256 reservedQuote = reservedBase.multiplyDecimal(nav);
        uint256 effectiveQuote = buyTrade.effectiveQuote;
        if (effectiveQuote < reservedQuote) {
            // Reserved base is enough to execute the trade.
            // nav is always positive here
            return (buyTrade.frozenQuote, effectiveQuote.divideDecimal(nav));
        } else {
            // Reserved base is not enough. The trade is partially executed
            // and a fraction of frozenQuote is returned to the taker.
            return (buyTrade.frozenQuote.mul(reservedQuote).div(effectiveQuote), reservedBase);
        }
    }

    /// @dev Calculate the result of an unsettled sell trade with a given NAV
    /// @param sellTrade Sell trade result of this particular epoch
    /// @param nav Net asset value for the base asset
    /// @return executionQuote Real amount of quote asset waiting for settlment
    /// @return executionBase Real amount of base asset waiting for settlment
    function _sellTradeResult(UnsettledSellTrade memory sellTrade, uint256 nav)
        internal
        pure
        returns (uint256 executionQuote, uint256 executionBase)
    {
        uint256 reservedQuote = sellTrade.reservedQuote;
        uint256 effectiveQuote = sellTrade.effectiveBase.multiplyDecimal(nav);
        if (effectiveQuote < reservedQuote) {
            // Reserved quote is enough to execute the trade.
            return (effectiveQuote, sellTrade.frozenBase);
        } else {
            // Reserved quote is not enough. The trade is partially executed
            // and a fraction of frozenBase is returned to the taker.
            return (reservedQuote, sellTrade.frozenBase.mul(reservedQuote).div(effectiveQuote));
        }
    }

    /// @dev Transfer quote asset to an account. Transfered amount is rounded down.
    /// @param account Recipient address
    /// @param amount Amount to transfer with 18 decimal places
    function _transferQuote(address account, uint256 amount) private {
        uint256 amountToTransfer = amount / _quoteDecimalMultiplier;
        if (amountToTransfer == 0) {
            return;
        }
        IERC20(quoteAssetAddress).safeTransfer(account, amountToTransfer);
    }

    /// @dev Transfer quote asset from an account. Transfered amount is rounded up.
    /// @param account Sender address
    /// @param amount Amount to transfer with 18 decimal places
    function _transferQuoteFrom(address account, uint256 amount) private {
        uint256 amountToTransfer =
            amount.add(_quoteDecimalMultiplier - 1) / _quoteDecimalMultiplier;
        IERC20(quoteAssetAddress).safeTransferFrom(account, address(this), amountToTransfer);
    }

    modifier onlyActive() {
        require(fund.isExchangeActive(block.timestamp), "Exchange is inactive");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import {Order, OrderQueue, LibOrderQueue} from "../exchange/LibOrderQueue.sol";

contract OrderQueueTestWrapper {
    using LibOrderQueue for OrderQueue;

    OrderQueue public queue;

    uint256 public lastReturn;

    function getOrder(uint256 index) external view returns (Order memory) {
        return queue.list[index];
    }

    function isEmpty() external view returns (bool) {
        return queue.isEmpty();
    }

    function append(
        address maker,
        uint256 amount,
        uint256 version
    ) external {
        lastReturn = queue.append(maker, amount, version);
    }

    function cancel(uint256 index) external {
        queue.cancel(index);
    }

    function fill(uint256 index) external {
        lastReturn = queue.fill(index);
    }

    function updateHead(uint256 newHead) external {
        queue.updateHead(newHead);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IAprOracle.sol";
import "../utils/SafeDecimalMath.sol";
import "../utils/Exponential.sol";
import "../utils/CoreUtility.sol";

// Compound
interface CTokenInterface {
    function borrowIndex() external view returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function accrualBlockNumber() external view returns (uint256);
}

// Aave
interface ILendingPool {
    function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);
}

contract AprOracle is IAprOracle, Exponential, CoreUtility {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    uint256 public constant DECIMAL = 10**18;
    uint256 public constant COMPOUND_BORROW_MAX_MANTISSA = 0.0005e16;

    // Mainnet: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    // Kovan: 0xe22da380ee6B445bb8273C81944ADEB6E8450422
    address public immutable usdc;

    // Kovan: 0x9FE532197ad76c5a68961439604C037EB79681F0
    address public immutable aaveUsdcLendingPool;

    // Mainnet: 0x39AA39c021dfbaE8faC545936693aC917d5E7563
    // Kovan: 0x4a92E71227D294F041BD82dd8f78591B75140d63
    address public immutable cUsdc;

    string public name;
    uint256 public compoundBorrowIndex;
    uint256 public aaveBorrowIndex;
    uint256 public timestamp;
    uint256 public currentDailyRate;

    constructor(
        string memory name_,
        address usdc_,
        address aaveUsdcLendingPool_,
        address cUsdc_
    ) public {
        name = name_;
        usdc = usdc_;
        aaveUsdcLendingPool = aaveUsdcLendingPool_;
        cUsdc = cUsdc_;
        compoundBorrowIndex = getCompoundBorrowIndex(cUsdc_);
        aaveBorrowIndex = getAaveBorrowIndex(aaveUsdcLendingPool_, usdc_);
        timestamp = block.timestamp;
    }

    // Compound
    function getCompoundBorrowIndex(address cToken) public view returns (uint256 newBorrowIndex) {
        /* Calculate the current borrow interest rate */
        uint256 borrowRateMantissa = CTokenInterface(cToken).borrowRatePerBlock();
        require(borrowRateMantissa <= COMPOUND_BORROW_MAX_MANTISSA, "Borrow rate is absurdly high");

        uint256 borrowIndexPrior = CTokenInterface(cToken).borrowIndex();
        uint256 accrualBlockNumber = CTokenInterface(cToken).accrualBlockNumber();

        (, uint256 blockDelta) = subUInt(block.number, accrualBlockNumber);

        (, Exp memory simpleInterestFactor) =
            mulScalar(Exp({mantissa: borrowRateMantissa}), blockDelta);
        (, newBorrowIndex) = mulScalarTruncateAddUInt(
            simpleInterestFactor,
            borrowIndexPrior,
            borrowIndexPrior
        );
    }

    // Aave
    function getAaveBorrowIndex(address aaveLendingPool, address token)
        public
        view
        returns (uint256 newBorrowRate)
    {
        newBorrowRate = ILendingPool(aaveLendingPool).getReserveNormalizedVariableDebt(token);
    }

    function getAverageDailyRate()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 newCompoundBorrowIndex = getCompoundBorrowIndex(cUsdc);
        uint256 newAaveBorrowRate = getAaveBorrowIndex(aaveUsdcLendingPool, usdc);

        uint256 compoundPeriodicRate =
            newCompoundBorrowIndex.sub(compoundBorrowIndex).divideDecimal(compoundBorrowIndex);
        uint256 aavePeriodicRate =
            newAaveBorrowRate.sub(aaveBorrowIndex).divideDecimal(aaveBorrowIndex);

        uint256 dailyRate =
            compoundPeriodicRate.add(aavePeriodicRate).mul(1 days).div(2).div(
                block.timestamp.sub(timestamp)
            );

        return (
            newCompoundBorrowIndex,
            newAaveBorrowRate,
            compoundPeriodicRate,
            aavePeriodicRate,
            dailyRate
        );
    }

    function capture() external override returns (uint256 dailyRate) {
        uint256 currentWeek = _endOfWeek(timestamp);
        if (currentWeek > block.timestamp) {
            return currentDailyRate;
        }

        (compoundBorrowIndex, aaveBorrowIndex, , , dailyRate) = getAverageDailyRate();
        timestamp = block.timestamp;
        currentDailyRate = dailyRate;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./CarefulMath.sol";
import "./ExponentialNoError.sol";

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @dev Legacy contract for compatibility reasons with existing contracts that still use MathError
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
abstract contract Exponential is CarefulMath, ExponentialNoError {
    /**
     * @dev Creates an exponential from numerator and denominator values.
     *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
     *            or if `denom` is zero.
     */
    function getExp(uint256 num, uint256 denom) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint256 rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    /**
     * @dev Adds two exponentials, returning a new exponential.
     */
    function addExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError error, uint256 result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Subtracts two exponentials, returning a new exponential.
     */
    function subExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError error, uint256 result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Multiply an Exp by a scalar, returning a new Exp.
     */
    function mulScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mulScalarTruncate(Exp memory a, uint256 scalar)
        internal
        pure
        returns (MathError, uint256)
    {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mulScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (MathError, uint256) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    /**
     * @dev Divide an Exp by a scalar, returning a new Exp.
     */
    function divScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    /**
     * @dev Divide a scalar by an Exp, returning a new Exp.
     */
    function divScalarByExp(uint256 scalar, Exp memory divisor)
        internal
        pure
        returns (MathError, Exp memory)
    {
        /*
          We are doing this as:
          getExp(mulUInt(expScale, scalar), divisor.mantissa)

          How it works:
          Exp = a / b;
          Scalar = s;
          `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
        (MathError err0, uint256 numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    /**
     * @dev Divide a scalar by an Exp, then truncate to return an unsigned integer.
     */
    function divScalarByExpTruncate(uint256 scalar, Exp memory divisor)
        internal
        pure
        returns (MathError, uint256)
    {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    /**
     * @dev Multiplies two exponentials, returning a new exponential.
     */
    function mulExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        // We add half the scale before dividing so that we get rounding instead of truncation.
        //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
        // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
        (MathError err1, uint256 doubleScaledProductWithHalfScale) =
            addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint256 product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        // The only error `div` can return is MathError.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    /**
     * @dev Multiplies two exponentials given their mantissas, returning a new exponential.
     */
    function mulExp(uint256 a, uint256 b) internal pure returns (MathError, Exp memory) {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    /**
     * @dev Multiplies three exponentials, returning a new exponential.
     */
    function mulExp3(
        Exp memory a,
        Exp memory b,
        Exp memory c
    ) internal pure returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    /**
     * @dev Divides two exponentials, returning a new exponential.
     *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
     *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
     */
    function divExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**
 * @title Careful Math
 * @author Compound
 * @notice Derived from OpenZeppelin's SafeMath library
 *         https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
abstract contract CarefulMath {
    /**
     * @dev Possible error codes that we can return
     */
    enum MathError {NO_ERROR, DIVISION_BY_ZERO, INTEGER_OVERFLOW, INTEGER_UNDERFLOW}

    /**
     * @dev Multiplies two numbers, returns an error on overflow.
     */
    function mulUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint256 c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function divUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    /**
     * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
     */
    function subUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
     * @dev Adds two numbers, returns an error on overflow.
     */
    function addUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        uint256 c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    /**
     * @dev add a and b and then subtract c
     */
    function addThenSubUInt(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (MathError, uint256) {
        (MathError err0, uint256 sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
abstract contract ExponentialNoError {
    uint256 constant expScale = 1e18;
    uint256 constant doubleScale = 1e36;
    uint256 constant halfExpScale = expScale / 2;
    uint256 constant mantissaOne = expScale;

    struct Exp {
        uint256 mantissa;
    }

    struct Double {
        uint256 mantissa;
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) internal pure returns (uint256) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(Exp memory a, uint256 scalar) internal pure returns (uint256) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (uint256) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) internal pure returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) internal pure returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint256 n, string memory errorMessage) internal pure returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint256 a, uint256 b) internal pure returns (uint256) {
        return add_(a, b, "addition overflow");
    }

    function add_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Exp memory b) internal pure returns (uint256) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint256 b) internal pure returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Double memory b) internal pure returns (uint256) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Exp memory b) internal pure returns (uint256) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) internal pure returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint256 b) internal pure returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Double memory b) internal pure returns (uint256) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint256 a, uint256 b) internal pure returns (uint256) {
        return div_(a, b, "divide by zero");
    }

    function div_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint256 a, uint256 b) internal pure returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../interfaces/IAprOracle.sol";
import "../utils/SafeDecimalMath.sol";
import "../utils/Exponential.sol";
import "../utils/CoreUtility.sol";

// Venus
interface VTokenInterfaces {
    function borrowIndex() external view returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function accrualBlockNumber() external view returns (uint256);
}

contract BscAprOracle is IAprOracle, Exponential, CoreUtility {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;

    uint256 public constant VENUS_BORROW_MAX_MANTISSA = 0.0005e16;

    address public immutable vUsdc;

    string public name;
    uint256 public venusBorrowIndex;
    uint256 public timestamp;
    uint256 public currentDailyRate;

    constructor(string memory name_, address vUsdc_) public {
        name = name_;
        vUsdc = vUsdc_;
        venusBorrowIndex = getVenusBorrowIndex(vUsdc_);
        timestamp = block.timestamp;
    }

    // Venus
    function getVenusBorrowIndex(address vToken) public view returns (uint256 newBorrowIndex) {
        /* Calculate the current borrow interest rate */
        uint256 borrowRateMantissa = VTokenInterfaces(vToken).borrowRatePerBlock();
        require(borrowRateMantissa <= VENUS_BORROW_MAX_MANTISSA, "Borrow rate is absurdly high");

        uint256 borrowIndexPrior = VTokenInterfaces(vToken).borrowIndex();
        uint256 accrualBlockNumber = VTokenInterfaces(vToken).accrualBlockNumber();

        (, uint256 blockDelta) = subUInt(block.number, accrualBlockNumber);

        (, Exp memory simpleInterestFactor) =
            mulScalar(Exp({mantissa: borrowRateMantissa}), blockDelta);
        (, newBorrowIndex) = mulScalarTruncateAddUInt(
            simpleInterestFactor,
            borrowIndexPrior,
            borrowIndexPrior
        );
    }

    function getAverageDailyRate()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 newVenusBorrowIndex = getVenusBorrowIndex(vUsdc);

        uint256 venusPeriodicRate =
            newVenusBorrowIndex.sub(venusBorrowIndex).divideDecimal(venusBorrowIndex);

        uint256 dailyRate = venusPeriodicRate.mul(1 days).div(block.timestamp.sub(timestamp));

        return (newVenusBorrowIndex, venusPeriodicRate, dailyRate);
    }

    function capture() external override returns (uint256 dailyRate) {
        uint256 currentWeek = _endOfWeek(timestamp);
        if (currentWeek > block.timestamp) {
            return currentDailyRate;
        }

        (venusBorrowIndex, , dailyRate) = getAverageDailyRate();
        timestamp = block.timestamp;
        currentDailyRate = dailyRate;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

/// @notice Vests `Chess` tokens for a single address

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract VestingEscrow is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Fund(uint256 amount);
    event Claim(uint256 amount);
    event ToggleDisable(bool disabled);

    address public immutable token;
    address public immutable recipient;
    uint256 public immutable startTime;
    uint256 public immutable endTime;
    bool public canDisable;

    uint256 public initialLocked;
    uint256 public vestedAtStart;
    uint256 public totalClaimed;
    uint256 public disabledAt;

    constructor(
        address token_,
        address recipient_,
        uint256 startTime_,
        uint256 endTime_,
        bool canDisable_
    ) public {
        token = token_;
        recipient = recipient_;
        startTime = startTime_;
        endTime = endTime_;
        canDisable = canDisable_;
    }

    function initialize(uint256 amount, uint256 vestedAtStart_) external {
        require(amount != 0 && amount >= vestedAtStart_, "Invalid amount or vestedAtStart");
        require(initialLocked == 0, "Already initialized");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        initialLocked = amount;
        vestedAtStart = vestedAtStart_;
        emit Fund(amount);
    }

    /// @notice Get the total number of tokens which have vested, that are held
    ///         by this contract
    function vestedSupply() external view returns (uint256) {
        return _totalVestedOf(block.timestamp);
    }

    /// @notice Get the total number of tokens which are still locked
    ///         (have not yet vested)
    function lockedSupply() external view returns (uint256) {
        return initialLocked.sub(_totalVestedOf(block.timestamp));
    }

    /// @notice Get the number of unclaimed, vested tokens for a given address
    /// @param account address to check
    function balanceOf(address account) external view returns (uint256) {
        if (account != recipient) {
            return 0;
        }
        return _totalVestedOf(block.timestamp).sub(totalClaimed);
    }

    /// @notice Disable or re-enable a vested address's ability to claim tokens
    /// @dev When disabled, the address is only unable to claim tokens which are still
    ///      locked at the time of this call. It is not possible to block the claim
    ///      of tokens which have already vested.
    function toggleDisable() external onlyOwner {
        require(canDisable, "Cannot disable");

        bool isDisabled = disabledAt == 0;
        if (isDisabled) {
            disabledAt = block.timestamp;
        } else {
            disabledAt = 0;
        }

        emit ToggleDisable(isDisabled);
    }

    /// @notice Disable the ability to call `toggleDisable`
    function disableCanDisable() external onlyOwner {
        canDisable = false;
    }

    /// @notice Claim tokens which have vested
    function claim() external {
        uint256 timestamp = disabledAt;
        if (timestamp == 0) {
            timestamp = block.timestamp;
        }
        uint256 claimable = _totalVestedOf(timestamp).sub(totalClaimed);
        totalClaimed = totalClaimed.add(claimable);
        IERC20(token).safeTransfer(recipient, claimable);

        emit Claim(claimable);
    }

    function _totalVestedOf(uint256 timestamp) internal view returns (uint256) {
        uint256 start = startTime;
        uint256 end = endTime;
        uint256 locked = initialLocked;
        if (timestamp < start) {
            return 0;
        } else if (timestamp > end) {
            return locked;
        }
        uint256 vestedAtStart_ = vestedAtStart;
        return
            locked.sub(vestedAtStart_).mul(timestamp - start).div(end - start).add(vestedAtStart_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IChessSchedule.sol";
import "../utils/CoreUtility.sol";

import "./ChessRoles.sol";

contract ChessSchedule is IChessSchedule, OwnableUpgradeable, ChessRoles, CoreUtility {
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[32] private _reservedSlots;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant MAX_SUPPLY = 120_000_000e18;

    /// @dev Hard-coded cumulative weekly supply. Please refer to the whitepaper for details.
    ///      Below are the concrete numbers in this list, which are also tested in "test/chessSchedule.ts".
    ///
    ///      ```
    ///         300000    900000   1800000   3000000   5400000   7704000   9915840  12039206  14077638  16034532
    ///       17913151  19716625  21447960  23110041  24705640  26237414  27707917  29119601  30474817  31775824
    ///       33037801  34261919  35449313  36601086  37718305  38802007  39853199  40872855  41861921  42921315
    ///       43931928  44894622  45810235  46679580  47503444  48302592  49077766  49829685  50559047  51266527
    ///       51959858  52639322  53305197  53957754  54597261  55223977  55838159  56440057  57029917  57607980
    ///       58174482  58729653  59273722  59806909  60329432  60841504  61343336  61835130  62317089  62789409
    ///       63252282  63705898  64150441  64586093  65013033  65431434  65841466  66243298  66637094  67023013
    ///      ```
    bytes private constant CUMULATIVE_SUPPLY_SCHEDULE =
        hex"000000000000000000000000000000000000000000003f870857a3e0e380000000000000000000000000000000000000000000000000be951906eba2aa800000000000000000000000000000000000000000000000017d2a320dd74555000000000000000000000000000000000000000000000000027b46536c66c8e300000000000000000000000000000000000000000000000004777e962985cfff000000000000000000000000000000000000000000000000065f62ad457aa39f0000000000000000000000000000000000000000000000000833c2c374cc129f00000000000000000000000000000000000000000000000009f566aa3e18d928d800000000000000000000000000000000000000000000000ba50e48ffcd3def5800000000000000000000000000000000000000000000000d4371b8b190797d1000000000000000000000000000000000000000000000000ed141dc8c1e6e659c0000000000000000000000000000000000000000000000104f28620947a945a4000000000000000000000000000000000000000000000011bdc83dca5db1a5600000000000000000000000000000000000000000000000131dbdd53a5724eec40000000000000000000000000000000000000000000000146f9f6d938553a8a0000000000000000000000000000000000000000000000015b3fd101e26da27d8000000000000000000000000000000000000000000000016eb6130b8f80c68140000000000000000000000000000000000000000000000181650bbb9e9a9b324000000000000000000000000000000000000000000000019354b23ced790486400000000000000000000000000000000000000000000001a48cadee3f50e3f4000000000000000000000000000000000000000000000001b5406c7ea3059ae0400000000000000000000000000000000000000000000001c573e59c54139431c00000000000000000000000000000000000000000000001d52af1bbf2e3022e400000000000000000000000000000000000000000000001e4694d90b274c853800000000000000000000000000000000000000000000001f33296942ab5917e400000000000000000000000000000000000000000000002018a503a9d012eafc000000000000000000000000000000000000000000000020f73e3f2f422970dc000000000000000000000000000000000000000000000021cf29e8ca212387fc000000000000000000000000000000000000000000000022a09b48dd90e1bfe400000000000000000000000000000000000000000000002380f126009ae94fac00000000000000000000000000000000000000000000002456f296c5adc1756000000000000000000000000000000000000000000000002522ce55d3fa57d3b8000000000000000000000000000000000000000000000025e4b1d0c190c25c0c0000000000000000000000000000000000000000000000269cc91a32a98ba6f00000000000000000000000000000000000000000000000274b3edbf8eeff4cd0000000000000000000000000000000000000000000000027f478c257eb6de800000000000000000000000000000000000000000000000028989f06a12b8ea45800000000000000000000000000000000000000000000002937d8a2f5d1f4a3b4000000000000000000000000000000000000000000000029d24b6e0804764cbc00000000000000000000000000000000000000000000002a681bff597ec5fc1c00000000000000000000000000000000000000000000002afaed8bd921b3118800000000000000000000000000000000000000000000002b8acf5d102f23f12800000000000000000000000000000000000000000000002c17d085050e30619400000000000000000000000000000000000000000000002ca1ffb499270695a800000000000000000000000000000000000000000000002d296b730bbdb9ca1400000000000000000000000000000000000000000000002dae21cab5aa0c590400000000000000000000000000000000000000000000002e3030aa2e56594ddc00000000000000000000000000000000000000000000002eafa59ee82e12204400000000000000000000000000000000000000000000002f2c8dfed2c1d9aa5400000000000000000000000000000000000000000000002fa6f6da7a10d081300000000000000000000000000000000000000000000000301eecfd068894f508000000000000000000000000000000000000000000000030947cde5c4e8f69b400000000000000000000000000000000000000000000003107b2e87ed1749ba8000000000000000000000000000000000000000000000031789b088b13a864d4000000000000000000000000000000000000000000000031e7410fdcaa27506000000000000000000000000000000000000000000000003253b08a6b986ba480000000000000000000000000000000000000000000000032bdf4e86e748858a000000000000000000000000000000000000000000000003326191d35683f81a80000000000000000000000000000000000000000000000338c2829f15406dbe4000000000000000000000000000000000000000000000033f02caeae196a8fe4000000000000000000000000000000000000000000000034523113f4bf2828a8000000000000000000000000000000000000000000000034b23fa68cde95e26800000000000000000000000000000000000000000000003510625ff9c8d40d040000000000000000000000000000000000000000000000356ca31dfd619ba994000000000000000000000000000000000000000000000035c70b94b7688ac3040000000000000000000000000000000000000000000000361fa52503550977e80000000000000000000000000000000000000000000000367679061a7a64f0a8000000000000000000000000000000000000000000000036cb9061557536ae480000000000000000000000000000000000000000000000371ef41aa95095ecd800000000000000000000000000000000000000000000003770acd0a78617a3740000";

    IERC20 public immutable chess;
    uint256 public immutable startTimestamp;

    uint256 public minted;

    constructor(address chess_, uint256 startTimestamp_) public ChessRoles() {
        require(
            _endOfWeek(startTimestamp_ - 1) == startTimestamp_,
            "Start timestamp is not start of a trading week"
        );
        chess = IERC20(chess_);
        startTimestamp = startTimestamp_;
    }

    /// @notice Initialize ownership and deposit tokens.
    function initialize() external initializer {
        __Ownable_init();
        chess.safeTransferFrom(msg.sender, address(this), MAX_SUPPLY);
    }

    /// @notice Get length of the supply schedule
    /// @return The length of the supply schedule
    function getScheduleLength() public pure returns (uint256) {
        return CUMULATIVE_SUPPLY_SCHEDULE.length / 32;
    }

    /// @notice Get the total supply and weekly supply at the given week index
    /// @param index Index for weekly supply
    /// @return currentWeekCumulativeSupply The cumulative supply at the
    ///         beginning of the week
    /// @return weeklySupply Weekly supply
    function getWeeklySupply(uint256 index)
        public
        pure
        returns (uint256 currentWeekCumulativeSupply, uint256 weeklySupply)
    {
        uint256 length = getScheduleLength();
        bytes memory scheduleBytes = CUMULATIVE_SUPPLY_SCHEDULE;
        if (index == 0) {
            assembly {
                weeklySupply := mload(add(scheduleBytes, 32))
            }
        } else if (index < length) {
            uint256 offset = index * 32;
            uint256 nextWeekCumulativeSupply;
            assembly {
                currentWeekCumulativeSupply := mload(add(scheduleBytes, offset))
                nextWeekCumulativeSupply := mload(add(scheduleBytes, add(offset, 32)))
            }
            weeklySupply = nextWeekCumulativeSupply.sub(currentWeekCumulativeSupply);
        } else {
            uint256 offset = length * 32;
            assembly {
                currentWeekCumulativeSupply := mload(add(scheduleBytes, offset))
            }
        }
    }

    /// @notice Current number of tokens in existence (claimed or unclaimed)
    function availableSupply() public view returns (uint256) {
        if (block.timestamp < startTimestamp) {
            return 0;
        }
        uint256 index = (block.timestamp - startTimestamp) / 1 weeks;
        uint256 currentWeek = index * 1 weeks + startTimestamp;
        (uint256 currentWeekCumulativeSupply, uint256 weeklySupply) = getWeeklySupply(index);
        return
            currentWeekCumulativeSupply.add(
                weeklySupply.mul(block.timestamp - currentWeek).div(1 weeks)
            );
    }

    /// @notice Get the release rate of CHESS token at the given timestamp
    /// @param timestamp Timestamp for release rate
    /// @return Release rate (number of CHESS token per second)
    function getRate(uint256 timestamp) external view override returns (uint256) {
        if (timestamp < startTimestamp) {
            return 0;
        }
        uint256 index = (timestamp - startTimestamp) / 1 weeks;
        (, uint256 weeklySupply) = getWeeklySupply(index);
        return weeklySupply.div(1 weeks);
    }

    /// @notice Creates `amount` CHESS tokens and assigns them to `account`,
    ///         increasing the total supply. This is guarded by `Minter` role.
    /// @param account recipient of the token
    /// @param amount amount of the token
    function mint(address account, uint256 amount) external override onlyMinter {
        require(minted.add(amount) <= availableSupply(), "Exceeds allowable mint amount");
        chess.safeTransfer(account, amount);
        minted = minted.add(amount);
    }

    function addMinter(address account) external override onlyOwner {
        _addMinter(account);
    }

    function removeMinter(address account) external onlyOwner {
        _removeMinter(account);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";

abstract contract ChessRoles {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _minterMembers;

    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);

    modifier onlyMinter() {
        require(isMinter(msg.sender), "Only minter");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minterMembers.contains(account);
    }

    function getMinterMember(uint256 index) external view returns (address) {
        return _minterMembers.at(index);
    }

    function getMinterCount() external view returns (uint256) {
        return _minterMembers.length();
    }

    function _addMinter(address minter) internal {
        if (_minterMembers.add(minter)) {
            emit MinterAdded(minter);
        }
    }

    function _removeMinter(address minter) internal {
        if (_minterMembers.remove(minter)) {
            emit MinterRemoved(minter);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

import "../interfaces/IPrimaryMarketV3.sol";
import "../interfaces/ITrancheIndexV2.sol";
import "./StableSwap.sol";

contract BishopStableSwap is StableSwap, ITrancheIndexV2 {
    event Rebalanced(uint256 base, uint256 quote, uint256 version);

    uint256 public immutable tradingCurbThreshold;

    uint256 public currentVersion;

    constructor(
        address lpToken_,
        address fund_,
        address quoteAddress_,
        uint256 quoteDecimals_,
        uint256 ampl_,
        address feeCollector_,
        uint256 feeRate_,
        uint256 adminFeeRate_,
        uint256 tradingCurbThreshold_
    )
        public
        StableSwap(
            lpToken_,
            fund_,
            TRANCHE_B,
            quoteAddress_,
            quoteDecimals_,
            ampl_,
            feeCollector_,
            feeRate_,
            adminFeeRate_
        )
    {
        tradingCurbThreshold = tradingCurbThreshold_;
        currentVersion = IFundV3(fund_).getRebalanceSize();
    }

    /// @dev Make sure the user-specified version is the latest rebalance version.
    modifier checkVersion(uint256 version) override {
        require(version == fund.getRebalanceSize(), "Obsolete rebalance version");
        _;
    }

    function _getRebalanceResult(uint256 latestVersion)
        internal
        view
        override
        returns (
            uint256 newBase,
            uint256 newQuote,
            uint256 excessiveQ,
            uint256 excessiveB,
            uint256 excessiveR,
            uint256 excessiveQuote,
            bool isRebalanced
        )
    {
        if (latestVersion == currentVersion) {
            return (baseBalance, quoteBalance, 0, 0, 0, 0, false);
        }
        isRebalanced = true;

        uint256 oldBaseBalance = baseBalance;
        uint256 oldQuoteBalance = quoteBalance;
        (excessiveQ, newBase, ) = fund.batchRebalance(
            0,
            oldBaseBalance,
            0,
            currentVersion,
            latestVersion
        );
        if (newBase < oldBaseBalance) {
            // We split all QUEEN from rebalance if the amount of BISHOP is smaller than before.
            // In almost all cases, the total amount of BISHOP after the split is still smaller
            // than before.
            excessiveR = IPrimaryMarketV3(fund.primaryMarket()).getSplit(excessiveQ);
            newBase = newBase.add(excessiveR);
        }
        if (newBase < oldBaseBalance) {
            // If BISHOP amount is still smaller than before, we remove quote tokens proportionally.
            newQuote = oldQuoteBalance.mul(newBase).div(oldBaseBalance);
            excessiveQuote = oldQuoteBalance - newQuote;
        } else {
            // In most cases when we reach here, the BISHOP amount remains the same (ratioBR = 1).
            newQuote = oldQuoteBalance;
            excessiveB = newBase - oldBaseBalance;
            newBase = oldBaseBalance;
        }
    }

    function _handleRebalance(uint256 latestVersion)
        internal
        override
        returns (uint256 newBase, uint256 newQuote)
    {
        uint256 excessiveQ;
        uint256 excessiveB;
        uint256 excessiveR;
        uint256 excessiveQuote;
        bool isRebalanced;
        (
            newBase,
            newQuote,
            excessiveQ,
            excessiveB,
            excessiveR,
            excessiveQuote,
            isRebalanced
        ) = _getRebalanceResult(latestVersion);
        if (isRebalanced) {
            baseBalance = newBase;
            quoteBalance = newQuote;
            currentVersion = latestVersion;
            emit Rebalanced(newBase, newQuote, latestVersion);
            if (excessiveQ > 0) {
                if (excessiveR > 0) {
                    IPrimaryMarketV3(fund.primaryMarket()).split(
                        address(this),
                        excessiveQ,
                        latestVersion
                    );
                    excessiveQ = 0;
                } else {
                    fund.trancheTransfer(TRANCHE_Q, lpToken, excessiveQ, latestVersion);
                }
            }
            if (excessiveB > 0) {
                fund.trancheTransfer(TRANCHE_B, lpToken, excessiveB, latestVersion);
            }
            if (excessiveR > 0) {
                fund.trancheTransfer(TRANCHE_R, lpToken, excessiveR, latestVersion);
            }
            if (excessiveQuote > 0) {
                IERC20(quoteAddress).safeTransfer(lpToken, excessiveQuote);
            }
            ILiquidityGauge(lpToken).distribute(
                excessiveQ,
                excessiveB,
                excessiveR,
                excessiveQuote,
                latestVersion
            );
        }
    }

    function getOraclePrice() public view override returns (uint256) {
        uint256 price = fund.twapOracle().getLatest();
        (, uint256 navB, uint256 navR) = fund.extrapolateNav(price);
        require(navR >= navB.multiplyDecimal(tradingCurbThreshold), "Trading curb");
        return navB;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";
import "@uniswap/lib/contracts/libraries/FixedPoint.sol";

import "../interfaces/ITwapOracleV2.sol";

/// @title Time-weighted average price oracle
/// @notice This contract extends the Chainlink Oracle, computes
///         time-weighted average price (TWAP) in every 30-minute epoch.
/// @author Tranchess
/// @dev This contract relies on the following assumptions on the Chainlink aggregator:
///      1. Round ID returned by `latestRoundData()` is monotonically increasing over time.
///      2. Round ID is continuous in the same phase. Formally speaking, let `x` and `y` be two
///         round IDs returned by `latestRoundData` in different blocks and they satisfy `x < y`
///         and `x >> 64 == y >> 64`. Then every integer between `x` and `y` is a valid round ID.
///      3. Phase change is rare.
///      4. Each round is updated only once and `updatedAt` returned by `getRoundData()` is
///         timestamp of the block in which the round is updated. Therefore, a transaction is
///         guaranteed to see all rounds whose `updatedAt` is less than the current block timestamp.
contract ChainlinkTwapOracle is ITwapOracleV2, Ownable {
    using FixedPoint for FixedPoint.uq112x112;
    using FixedPoint for FixedPoint.uq144x112;
    using SafeMath for uint256;

    uint256 private constant EPOCH = 30 minutes;
    uint256 private constant MAX_SWAP_DELAY = 15 minutes;
    uint256 private constant MAX_ITERATION = 500;

    event Update(uint256 timestamp, uint256 price, UpdateType updateType);

    /// @notice The contract fails to update an epoch from either Chainlink or Uniswap
    ///         and will not attempt to do so in the future.
    event SkipMissingData(uint256 timestamp);

    /// @notice Twap of this epoch can be calculated from both Chainlink and Uniswap,
    ///         but the difference is too large. The contract decides not to update this epoch
    ///         using either result.
    event SkipDeviation(uint256 timestamp, uint256 chainlinkTwap, uint256 swapTwap);

    /// @notice Chainlink aggregator used as the primary data source.
    address public immutable chainlinkAggregator;

    /// @notice Minimum number of Chainlink rounds required in an epoch.
    uint256 public immutable chainlinkMinMessageCount;

    /// @dev A multipler that normalizes price from the Chainlink aggregator to 18 decimal places.
    uint256 private immutable _chainlinkPriceMultiplier;

    /// @notice Uniswap V2 pair contract used as the backup data source.
    address public immutable swapPair;

    /// @dev Index of the token (0 or 1) in the pair whose price is taken.
    uint256 private immutable _swapTokenIndex;

    /// @dev A multipler that normalizes price from the Uniswap V2 pair to 18 decimal places.
    uint256 private immutable _swapPriceMultiplier;

    /// @notice The previous oracle that was used before this contract is deployed.
    ITwapOracle public immutable fallbackOracle;

    /// @notice Epochs until this timestamp should be read from the fallback oracle.
    uint256 public immutable fallbackTimestamp;

    string public symbol;

    /// @notice The last epoch that has been updated (or attempted to update) using data from
    ///         Chainlink or Uniswap.
    uint256 public lastTimestamp;

    /// @notice The last Chainlink round ID that has been read.
    uint80 public lastRoundID;

    /// @notice The last observation of the Uniswap V2 pair cumulative price.
    uint256 public lastSwapCumulativePrice;

    /// @notice Timestamp of the last Uniswap observation.
    uint256 public lastSwapTimestamp;

    /// @dev Mapping of epoch end timestamp => TWAP
    mapping(uint256 => uint256) private _prices;

    /// @param chainlinkAggregator_ Address of the Chainlink aggregator
    /// @param swapPair_ Address of the Uniswap V2 pair
    /// @param symbol_ Asset symbol
    constructor(
        address chainlinkAggregator_,
        uint256 chainlinkMinMessageCount_,
        address swapPair_,
        address fallbackOracle_,
        uint256 fallbackTimestamp_,
        string memory symbol_
    ) public {
        chainlinkAggregator = chainlinkAggregator_;
        chainlinkMinMessageCount = chainlinkMinMessageCount_;
        uint256 decimal = AggregatorV3Interface(chainlinkAggregator_).decimals();
        _chainlinkPriceMultiplier = 10**(uint256(18).sub(decimal));

        swapPair = swapPair_;
        ERC20 swapToken0 = ERC20(IUniswapV2Pair(swapPair_).token0());
        ERC20 swapToken1 = ERC20(IUniswapV2Pair(swapPair_).token1());
        uint256 swapTokenIndex_;
        bytes32 symbolHash = keccak256(bytes(symbol_));
        if (symbolHash == keccak256(bytes(swapToken0.symbol()))) {
            swapTokenIndex_ = 0;
        } else if (symbolHash == keccak256(bytes(swapToken1.symbol()))) {
            swapTokenIndex_ = 1;
        } else {
            revert("Symbol mismatch");
        }
        _swapTokenIndex = swapTokenIndex_;
        _swapPriceMultiplier = swapTokenIndex_ == 0
            ? 10**(uint256(18).add(swapToken0.decimals()).sub(swapToken1.decimals()))
            : 10**(uint256(18).add(swapToken1.decimals()).sub(swapToken0.decimals()));

        fallbackOracle = ITwapOracle(fallbackOracle_);
        symbol = symbol_;
        lastTimestamp = (block.timestamp / EPOCH) * EPOCH + EPOCH;
        require(
            fallbackOracle_ == address(0) || fallbackTimestamp_ >= lastTimestamp,
            "Fallback timestamp too early"
        );
        fallbackTimestamp = fallbackTimestamp_;
        (lastRoundID, , , , ) = AggregatorV3Interface(chainlinkAggregator_).latestRoundData();
    }

    /// @notice Return the latest price with 18 decimal places.
    function getLatest() external view override returns (uint256) {
        (, int256 answer, , uint256 updatedAt, ) =
            AggregatorV3Interface(chainlinkAggregator).latestRoundData();
        require(updatedAt > block.timestamp - EPOCH, "Stale price oracle");
        return uint256(answer).mul(_chainlinkPriceMultiplier);
    }

    /// @notice Return TWAP with 18 decimal places in the epoch ending at the specified timestamp.
    ///         Zero is returned if the epoch is not initialized yet.
    /// @param timestamp End Timestamp in seconds of the epoch
    /// @return TWAP (18 decimal places) in the epoch, or zero if the epoch is not initialized yet.
    function getTwap(uint256 timestamp) external view override returns (uint256) {
        if (timestamp <= fallbackTimestamp) {
            return address(fallbackOracle) == address(0) ? 0 : fallbackOracle.getTwap(timestamp);
        } else {
            return _prices[timestamp];
        }
    }

    /// @notice Attempt to update the next epoch after `lastTimestamp` using data from Chainlink
    ///         or Uniswap. If neither data source is available, the epoch is skipped and this
    ///         function will never update it in the future.
    ///
    ///         This function is designed to be called after each epoch.
    /// @dev First, this function reads all Chainlink rounds before the end of this epoch, and
    ///      calculates the TWAP if there are enough data points in this epoch.
    ///
    ///      Otherwise, it tries to use data from Uniswap. Calculating TWAP from a Uniswap pair
    ///      requires two observations at both endpoints of the epoch. An observation is considered
    ///      valid only if it's taken within `MAX_SWAP_DELAY` seconds after the desired timestamp.
    ///      Regardless of whether or how the epoch is updated, the current observation is stored
    ///      if it is valid for the next epoch's start.
    function update() external {
        uint256 timestamp = lastTimestamp + EPOCH;
        require(block.timestamp > timestamp, "Too soon");

        (uint256 chainlinkTwap, uint80 newRoundID) = _updateTwapFromChainlink(timestamp);

        // Only observe the Uniswap pair if it's not too late.
        uint256 swapTwap = 0;
        if (block.timestamp <= timestamp + MAX_SWAP_DELAY) {
            uint256 currentCumulativePrice = _observeSwap();
            swapTwap = _updateTwapFromSwap(timestamp, currentCumulativePrice);
            lastSwapCumulativePrice = currentCumulativePrice;
            lastSwapTimestamp = block.timestamp;
        }

        if (chainlinkTwap != 0) {
            if (
                swapTwap != 0 &&
                (chainlinkTwap < (swapTwap / 10) * 9 || swapTwap < (chainlinkTwap / 10) * 9)
            ) {
                emit SkipDeviation(timestamp, chainlinkTwap, swapTwap);
            } else {
                _prices[timestamp] = chainlinkTwap;
                emit Update(timestamp, chainlinkTwap, UpdateType.CHAINLINK);
            }
        } else if (swapTwap != 0) {
            _prices[timestamp] = swapTwap;
            emit Update(timestamp, swapTwap, UpdateType.UNISWAP_V2);
        } else {
            emit SkipMissingData(timestamp);
        }
        lastTimestamp = timestamp;
        lastRoundID = newRoundID;
    }

    /// @dev Sequentially read Chainlink oracle until end of the given epoch.
    /// @param timestamp End timestamp of the epoch to be updated
    /// @return twap TWAP of the epoch calculated from Chainlink, or zero if there's no sufficient data
    /// @return newRoundID The last round ID that has been read until the end of this epoch
    function _updateTwapFromChainlink(uint256 timestamp)
        private
        view
        returns (uint256 twap, uint80 newRoundID)
    {
        (uint80 roundID, int256 oldAnswer, , uint256 oldUpdatedAt, ) =
            _getChainlinkRoundData(lastRoundID);
        uint256 sum = 0;
        uint256 sumTimestamp = timestamp - EPOCH;
        uint256 messageCount = 0;
        for (uint256 i = 0; i < MAX_ITERATION; i++) {
            (, int256 newAnswer, , uint256 newUpdatedAt, ) = _getChainlinkRoundData(++roundID);
            if (newUpdatedAt < oldUpdatedAt || newUpdatedAt > timestamp) {
                // This round is either not available yet (newUpdatedAt < updatedAt)
                // or beyond the current epoch (newUpdatedAt > timestamp).
                roundID--;
                break;
            }
            if (newUpdatedAt > sumTimestamp) {
                sum = sum.add(uint256(oldAnswer).mul(newUpdatedAt - sumTimestamp));
                sumTimestamp = newUpdatedAt;
                messageCount++;
            }
            oldAnswer = newAnswer;
            oldUpdatedAt = newUpdatedAt;
        }

        if (messageCount >= chainlinkMinMessageCount) {
            sum = sum.add(uint256(oldAnswer).mul(timestamp - sumTimestamp));
            return (sum.mul(_chainlinkPriceMultiplier) / EPOCH, roundID);
        } else {
            return (0, roundID);
        }
    }

    /// @dev Calculate TWAP for the given epoch.
    /// @param timestamp End timestamp of the epoch to be updated
    /// @param currentCumulativePrice Current observation of the Uniswap pair
    /// @return TWAP of the epoch calculated from Uniswap, or zero if either observation is invalid
    function _updateTwapFromSwap(uint256 timestamp, uint256 currentCumulativePrice)
        private
        view
        returns (uint256)
    {
        uint256 t = lastSwapTimestamp;
        if (t <= timestamp - EPOCH || t > timestamp - EPOCH + MAX_SWAP_DELAY) {
            // The last observation is not taken near the start of this epoch and cannot be used
            // to update this epoch.
            return 0;
        } else {
            return
                _getSwapTwap(lastSwapCumulativePrice, currentCumulativePrice, t, block.timestamp);
        }
    }

    /// @dev Call `chainlinkAggregator.getRoundData(roundID)`. Return zero if the call reverts.
    function _getChainlinkRoundData(uint80 roundID)
        private
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        (bool success, bytes memory returnData) =
            chainlinkAggregator.staticcall(
                abi.encodePacked(AggregatorV3Interface.getRoundData.selector, abi.encode(roundID))
            );
        if (success) {
            return abi.decode(returnData, (uint80, int256, uint256, uint256, uint80));
        } else {
            return (roundID, 0, 0, 0, roundID);
        }
    }

    function _observeSwap() private view returns (uint256) {
        (uint256 price0Cumulative, uint256 price1Cumulative, ) =
            UniswapV2OracleLibrary.currentCumulativePrices(swapPair);
        return _swapTokenIndex == 0 ? price0Cumulative : price1Cumulative;
    }

    function _getSwapTwap(
        uint256 startCumulativePrice,
        uint256 endCumulativePrice,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) private view returns (uint256) {
        return
            FixedPoint
                .uq112x112(
                uint224(
                    (endCumulativePrice - startCumulativePrice) / (endTimestamp - startTimestamp)
                )
            )
                .mul(_swapPriceMultiplier)
                .decode144();
    }

    /// @notice Fast-forward Chainlink round ID by owner. This is required when `lastRoundID` stucks
    ///         at an old round, due to either incontinuous round IDs caused by a phase change or
    ///         an abnormal `updatedAt` timestamp.
    function fastForwardRoundID(uint80 roundID) external onlyOwner {
        uint80 lastRoundID_ = lastRoundID;
        require(roundID > lastRoundID_, "Round ID too low");
        (, , , uint256 lastUpdatedAt, ) = _getChainlinkRoundData(lastRoundID_);
        (, , , uint256 updatedAt, ) = _getChainlinkRoundData(roundID);
        require(updatedAt > lastUpdatedAt, "Invalid round timestamp");
        require(updatedAt <= lastTimestamp, "Round too new");
        lastRoundID = roundID;
    }

    /// @notice Submit a TWAP with 18 decimal places by the owner.
    ///         This is allowed only when a epoch cannot be updated by either Chainlink or Uniswap.
    function updateTwapFromOwner(uint256 timestamp, uint256 price) external onlyOwner {
        require(timestamp % EPOCH == 0, "Unaligned timestamp");
        require(timestamp <= lastTimestamp, "Not ready for owner");
        require(_prices[timestamp] == 0, "Owner cannot update an existing epoch");

        uint256 lastPrice = _prices[timestamp - EPOCH];
        require(lastPrice > 0, "Owner can only update a epoch following an updated epoch");
        require(
            price > lastPrice / 10 && price < lastPrice * 10,
            "Owner price deviates too much from the last price"
        );

        _prices[timestamp] = price;
        emit Update(timestamp, price, UpdateType.OWNER);
    }

    /// @notice Observe the Uniswap pair and calculate TWAP since the last observation.
    function peekSwapPrice() external view returns (uint256) {
        uint256 cumulativePrice = _observeSwap();
        return
            _getSwapTwap(
                lastSwapCumulativePrice,
                cumulativePrice,
                lastSwapTimestamp,
                block.timestamp
            );
    }
}

pragma solidity >=0.5.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

pragma solidity >=0.4.0;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/ITwapOracleV2.sol";
import "../utils/CoreUtility.sol";

contract MockTwapOracle is ITwapOracleV2, CoreUtility, Ownable {
    struct StoredEpoch {
        uint256 twap;
        uint256 nextEpoch;
    }

    event Update(uint256 timestamp, uint256 price, UpdateType updateType);
    event ReporterAdded(address reporter);
    event ReporterRemoved(address reporter);

    uint256 private constant EPOCH = 30 minutes;
    uint256 private constant MAX_ITERATION = 500;

    ITwapOracle public immutable fallbackOracle;
    uint256 public immutable fallbackTimestamp;

    /// @notice A linked-list of epochs when TWAP is updated.
    ///         Epochs ending at the end of trading days are always stored.
    mapping(uint256 => StoredEpoch) public storedEpochs;

    /// @notice Timestamp of the last stored epoch. The `Update` event is not emitted for
    ///         this epoch yet.
    uint256 public lastStoredEpoch;

    /// @notice Mapping of epoch => TWAP. This mapping stores epochs that are manually updated
    ///         out-of-order.
    ///
    ///         - If value is 0, the epoch is not a hole and its TWAP equals to the last stored epoch.
    ///         - If value is uint(-1), the epoch is a hole and not updated yet.
    ///         - Otherwise, the epoch is a hole and the value is its TWAP.
    mapping(uint256 => uint256) public holes;

    mapping(address => bool) public reporters;

    constructor(
        uint256 initialTwap_,
        address fallbackOracle_,
        uint256 fallbackTimestamp_
    ) public {
        lastStoredEpoch = _endOfDay(block.timestamp) - 1 days;
        storedEpochs[lastStoredEpoch].twap = initialTwap_;
        fallbackOracle = ITwapOracle(fallbackOracle_);
        require(
            fallbackOracle_ == address(0) || fallbackTimestamp_ >= lastStoredEpoch,
            "Fallback timestamp too early"
        );
        fallbackTimestamp = fallbackTimestamp_;
        catchUp();
        reporters[msg.sender] = true;
        emit ReporterAdded(msg.sender);
    }

    modifier onlyReporter() {
        require(reporters[msg.sender], "Only reporter");
        _;
    }

    function addReporter(address reporter) external onlyOwner {
        require(!reporters[reporter]);
        reporters[reporter] = true;
        emit ReporterAdded(reporter);
    }

    function removeReporter(address reporter) external onlyOwner {
        require(reporters[reporter]);
        reporters[reporter] = false;
        emit ReporterRemoved(reporter);
    }

    function updateNext(uint256 twap) external onlyReporter {
        catchUp();
        uint256 nextEpoch = _nextEpoch();
        require(nextEpoch == lastStoredEpoch, "Call catchUp() first");
        storedEpochs[nextEpoch].twap = twap;
    }

    /// @notice Emit `Update` event for past epochs and add a stored epoch for the next one.
    function catchUp() public {
        uint256 nextEpoch = _nextEpoch();
        uint256 lastEpoch = lastStoredEpoch;
        if (nextEpoch <= lastEpoch) {
            return;
        }
        uint256 nextStoredEpoch = _endOfDay(lastEpoch);
        uint256 twap = storedEpochs[lastEpoch].twap;
        if (holes[lastEpoch] == 0) {
            emit Update(lastEpoch, twap, UpdateType.PRIMARY);
        }
        uint256 epoch = lastEpoch + EPOCH;
        for (uint256 i = 0; i < MAX_ITERATION && epoch < nextEpoch; i++) {
            if (holes[epoch] == 0) {
                emit Update(epoch, twap, UpdateType.PRIMARY);
                if (epoch == nextStoredEpoch) {
                    storedEpochs[lastEpoch].nextEpoch = nextStoredEpoch;
                    storedEpochs[nextStoredEpoch].twap = twap;
                    lastEpoch = nextStoredEpoch;
                    nextStoredEpoch += 1 days;
                }
            }
            epoch += EPOCH;
        }
        storedEpochs[lastEpoch].nextEpoch = epoch;
        storedEpochs[epoch].twap = twap;
        lastStoredEpoch = epoch;
    }

    function digHole(uint256 timestamp) external onlyReporter {
        require(timestamp % EPOCH == 0, "Unaligned timestamp");
        require(timestamp > block.timestamp, "Can only dig hole in the future");
        holes[timestamp] = uint256(-1);
    }

    function fillHole(uint256 timestamp, uint256 twap) external onlyReporter {
        require(timestamp % EPOCH == 0, "Unaligned timestamp");
        require(timestamp < block.timestamp, "Can only fill hole in the past");
        require(holes[timestamp] == uint256(-1), "Not a hole or already filled");
        holes[timestamp] = twap;
        emit Update(timestamp, twap, UpdateType.OWNER);
    }

    function getTwap(uint256 timestamp) external view override returns (uint256) {
        if (timestamp <= fallbackTimestamp) {
            if (address(fallbackOracle) == address(0)) {
                return 0;
            } else {
                return fallbackOracle.getTwap(timestamp);
            }
        }
        if (timestamp >= lastStoredEpoch || timestamp % EPOCH != 0) {
            return 0;
        }

        uint256 holeTwap = holes[timestamp];
        if (holeTwap != 0) {
            return holeTwap == uint256(-1) ? 0 : holeTwap;
        }

        // Search for the nearest stored epoch. The search starts at the latest 00:00 UTC
        // no later than the given timestamp, which is guaranteed to be a stored epoch.
        uint256 epoch = _endOfDay(timestamp) - 1 days;
        uint256 next = storedEpochs[epoch].nextEpoch;
        while (next > 0 && next <= timestamp) {
            epoch = next;
            next = storedEpochs[epoch].nextEpoch;
        }
        return storedEpochs[epoch].twap;
    }

    function getLatest() external view override returns (uint256) {
        return storedEpochs[lastStoredEpoch].twap;
    }

    function _endOfDay(uint256 timestamp) private pure returns (uint256) {
        return ((timestamp.add(1 days) - SETTLEMENT_TIME) / 1 days) * 1 days + SETTLEMENT_TIME;
    }

    function _nextEpoch() private view returns (uint256) {
        return (block.timestamp / EPOCH) * EPOCH + EPOCH;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./MockTwapOracle.sol";
import "@chainlink/contracts/src/v0.6/interfaces/KeeperCompatibleInterface.sol";

contract MockTwapOracleKeeper is KeeperCompatibleInterface, CoreUtility {
    MockTwapOracle private immutable mockTwap;

    constructor(address mockTwap_) public {
        mockTwap = MockTwapOracle(mockTwap_);
    }

    function checkUpkeep(
        bytes calldata /*checkData*/
    ) external override returns (bool upkeepNeeded, bytes memory performData) {
        return (block.timestamp > _endOfDay(mockTwap.lastStoredEpoch()), bytes(""));
    }

    function performUpkeep(
        bytes calldata /*performData*/
    ) external override {
        mockTwap.catchUp();
    }

    function _endOfDay(uint256 timestamp) private pure returns (uint256) {
        return ((timestamp.add(1 days) - SETTLEMENT_TIME) / 1 days) * 1 days + SETTLEMENT_TIME;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface KeeperCompatibleInterface {

  /**
   * @notice checks if the contract requires work to be done.
   * @param checkData data passed to the contract when checking for upkeep.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with,
   * if upkeep is needed.
   */
  function checkUpkeep(
    bytes calldata checkData
  )
    external
    returns (
      bool upkeepNeeded,
      bytes memory performData
    );

  /**
   * @notice Performs work on the contract. Executed by the keepers, via the registry.
   * @param performData is the data which was passed back from the checkData
   * simulation.
   */
  function performUpkeep(
    bytes calldata performData
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@chainlink/contracts/src/v0.6/interfaces/KeeperCompatibleInterface.sol";

contract BatchKeeperHelperBase is KeeperCompatibleInterface, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    event AllowlistAdded(address contractAddress);
    event AllowlistRemoved(address contractAddress);

    EnumerableSet.AddressSet private _allowlist;

    constructor(address[] memory contracts_) public {
        for (uint256 i = 0; i < contracts_.length; i++) {
            _allowlist.add(contracts_[i]);
            emit AllowlistAdded(contracts_[i]);
        }
    }

    function allowlist() external view returns (address[] memory list) {
        uint256 length = _allowlist.length();
        list = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            list[i] = _allowlist.at(i);
        }
    }

    function addAllowlist(address contractAddress) external onlyOwner {
        _allowlist.add(contractAddress);
        emit AllowlistAdded(contractAddress);
    }

    function removeAllowlist(address contractAddress) external onlyOwner {
        _allowlist.remove(contractAddress);
        emit AllowlistRemoved(contractAddress);
    }

    function checkUpkeep(bytes calldata)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        uint256 length = _allowlist.length();
        for (uint256 i = 0; i < length; i++) {
            address contractAddress = _allowlist.at(i);
            if (_checkUpkeep(contractAddress)) {
                upkeepNeeded = true;
                performData = abi.encodePacked(performData, contractAddress);
            }
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        uint256 contractLength = performData.length / 20;
        require(contractLength > 0);
        for (uint256 i = 0; i < contractLength; i++) {
            address contractAddress = _getContractAddr(i);
            require(_allowlist.contains(contractAddress), "Not allowlisted");
            _performUpkeep(contractAddress);
        }
    }

    function _getContractAddr(uint256 index) private pure returns (address contractAddress) {
        assembly {
            // 0x38 = 0x4 + 0x20 + 0x14
            contractAddress := calldataload(add(0x38, mul(index, 0x14)))
        }
    }

    function _checkUpkeep(address contractAddress) internal virtual returns (bool) {}

    function _performUpkeep(address contractAddress) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./BatchKeeperHelperBase.sol";

interface IChainlinkTwapOracle {
    function lastTimestamp() external view returns (uint256);

    function update() external;
}

contract OracleKeeperHelper is BatchKeeperHelperBase {
    uint256 private constant EPOCH = 30 minutes;

    uint256 public delay;

    constructor(address[] memory oracles_, uint256 delay_) public BatchKeeperHelperBase(oracles_) {
        delay = delay_;
    }

    function updateDelay(uint256 newDelay) external onlyOwner {
        delay = newDelay;
    }

    function _checkUpkeep(address contractAddress) internal override returns (bool) {
        IChainlinkTwapOracle chainlinkTwap = IChainlinkTwapOracle(contractAddress);
        uint256 lastTimestamp = chainlinkTwap.lastTimestamp();
        return block.timestamp > lastTimestamp + EPOCH + delay;
    }

    function _performUpkeep(address contractAddress) internal override {
        IChainlinkTwapOracle(contractAddress).update();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "./BatchKeeperHelperBase.sol";
import "../interfaces/IFundV3.sol";

interface IFundSettlement is IFundV3 {
    function settle() external;
}

interface IDistributor {
    function checkpoint() external;
}

contract FundKeeperHelper is BatchKeeperHelperBase {
    uint256 public delay;

    address private immutable _bnbFundAddr;
    IDistributor private immutable _feeDistributor;

    constructor(
        address[] memory funds_,
        uint256 delay_,
        address bnbFundAddr_,
        address feeDistributor_
    ) public BatchKeeperHelperBase(funds_) {
        delay = delay_;
        _bnbFundAddr = bnbFundAddr_;
        _feeDistributor = IDistributor(feeDistributor_);
    }

    function updateDelay(uint256 newDelay) external onlyOwner {
        delay = newDelay;
    }

    function _checkUpkeep(address contractAddress) internal override returns (bool) {
        IFundSettlement fund = IFundSettlement(contractAddress);
        uint256 currentDay = fund.currentDay();
        uint256 price = fund.twapOracle().getTwap(currentDay);
        return (block.timestamp >= currentDay + delay && price != 0);
    }

    function _performUpkeep(address contractAddress) internal override {
        if (contractAddress == _bnbFundAddr) {
            _feeDistributor.checkpoint();
        }
        IFundSettlement(contractAddress).settle();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "../interfaces/IFundV3.sol";
import "../interfaces/IShareV2.sol";

contract ShareV2 is IShareV2 {
    uint8 public constant decimals = 18;
    IFundV3 public immutable fund;
    uint256 public immutable tranche;

    string public name;
    string public symbol;

    constructor(
        string memory name_,
        string memory symbol_,
        address fund_,
        uint256 tranche_
    ) public {
        name = name_;
        symbol = symbol_;
        fund = IFundV3(fund_);
        tranche = tranche_;
    }

    function totalSupply() external view override returns (uint256) {
        return fund.trancheTotalSupply(tranche);
    }

    function balanceOf(address account) external view override returns (uint256) {
        return fund.trancheBalanceOf(tranche, account);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        fund.shareTransfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return fund.trancheAllowance(tranche, owner, spender);
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        fund.shareApprove(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        fund.shareTransferFrom(msg.sender, sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        fund.shareIncreaseAllowance(msg.sender, spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        fund.shareDecreaseAllowance(msg.sender, spender, subtractedValue);
        return true;
    }

    modifier onlyFund() {
        require(msg.sender == address(fund), "Only fund");
        _;
    }

    function fundEmitTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external override onlyFund {
        emit Transfer(sender, recipient, amount);
    }

    function fundEmitApproval(
        address owner,
        address spender,
        uint256 amount
    ) external override onlyFund {
        emit Approval(owner, spender, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract MockExternalRouter {
    using SafeERC20 for IERC20;

    // keccak256(path) => amountOut => amountIn
    mapping(bytes32 => mapping(uint256 => uint256)) public nextIn;

    // keccak256(path) => amountIn => amountOut
    mapping(bytes32 => mapping(uint256 => uint256)) public nextOut;

    function setNextSwap(
        address[] memory path,
        uint256 amountIn,
        uint256 amountOut
    ) external {
        nextIn[keccak256(abi.encode(path))][amountOut] = amountIn;
        nextOut[keccak256(abi.encode(path))][amountIn] = amountOut;
    }

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts)
    {
        uint256 amountIn = nextIn[keccak256(abi.encode(path))][amountOut];
        require(amountIn != 0, "No mock for the swap");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        amounts[0] = nextIn[keccak256(abi.encode(path))][amountOut];
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        require(deadline >= block.timestamp, "Deadline");
        uint256 amountOut = nextOut[keccak256(abi.encode(path))][amountIn];
        require(amountOut != 0, "No mock for the swap");
        require(amountOut >= amountOutMin, "MockExternalRouter: Insufficient output");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        amounts[amounts.length - 1] = amountOut;
        nextIn[keccak256(abi.encode(path))][amountOut] = 0;
        nextOut[keccak256(abi.encode(path))][amountIn] = 0;
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(path[path.length - 1]).safeTransfer(to, amountOut);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Proxy.sol";
import "../utils/Address.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 *
 * Upgradeability is only provided internally through {_upgradeTo}. For an externally upgradeable proxy see
 * {TransparentUpgradeableProxy}.
 */
contract UpgradeableProxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) public payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * @dev Upgrades the proxy to a new implementation.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal virtual {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./UpgradeableProxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is UpgradeableProxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic, address admin_, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
    }

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _admin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external virtual ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {
        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            adm := sload(slot)
        }
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        bytes32 slot = _ADMIN_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newAdmin)
        }
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../access/Ownable.sol";
import "./TransparentUpgradeableProxy.sol";

/**
 * @dev This is an auxiliary contract meant to be assigned as the admin of a {TransparentUpgradeableProxy}. For an
 * explanation of why you would want to use this see the documentation for {TransparentUpgradeableProxy}.
 */
contract ProxyAdmin is Ownable {

    /**
     * @dev Returns the current implementation of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Returns the current admin of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Changes the admin of `proxy` to `newAdmin`.
     *
     * Requirements:
     *
     * - This contract must be the current admin of `proxy`.
     */
    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrades `proxy` to `implementation`. See {TransparentUpgradeableProxy-upgradeTo}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {
        proxy.upgradeTo(implementation);
    }

    /**
     * @dev Upgrades `proxy` to `implementation` and calls a function on the new implementation. See
     * {TransparentUpgradeableProxy-upgradeToAndCall}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgradeAndCall(TransparentUpgradeableProxy proxy, address implementation, bytes memory data) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

// This file imports external contracts that are used by this project,
// forcing Hardhat to compile them.

import "@openzeppelin/contracts/access/TimelockController.sol";
import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/ProxyAdmin.sol";

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.9 <0.8.0;
pragma experimental ABIEncoderV2;

import "./../math/SafeMath.sol";
import "./AccessControl.sol";

/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 *
 * _Available since v3.3._
 */
contract TimelockController is AccessControl {

    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private _timestamps;
    uint256 private _minDelay;

    /**
     * @dev Emitted when a call is scheduled as part of operation `id`.
     */
    event CallScheduled(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data, bytes32 predecessor, uint256 delay);

    /**
     * @dev Emitted when a call is performed as part of operation `id`.
     */
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    /**
     * @dev Emitted when operation `id` is cancelled.
     */
    event Cancelled(bytes32 indexed id);

    /**
     * @dev Emitted when the minimum delay for future operations is modified.
     */
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    /**
     * @dev Initializes the contract with a given `minDelay`.
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors) public {
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);

        // deployer + self administration
        _setupRole(TIMELOCK_ADMIN_ROLE, _msgSender());
        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        // register proposers
        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }

        _minDelay = minDelay;
        emit MinDelayChange(0, minDelay);
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, _msgSender()) || hasRole(role, address(0)), "TimelockController: sender requires permission");
        _;
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable {}

    /**
     * @dev Returns whether an id correspond to a registered operation. This
     * includes both Pending, Ready and Done operations.
     */
    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    /**
     * @dev Returns whether an operation is pending or not.
     */
    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns whether an operation is ready or not.
     */
    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        // solhint-disable-next-line not-rely-on-time
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns the timestamp at with an operation becomes ready (0 for
     * unset operations, 1 for done operations).
     */
    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    /**
     * @dev Returns the minimum delay for an operation to become valid.
     *
     * This value can be changed by executing an operation that calls `updateDelay`.
     */
    function getMinDelay() public view virtual returns (uint256 duration) {
        return _minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    /**
     * @dev Schedule an operation containing a single transaction.
     *
     * Emits a {CallScheduled} event.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function schedule(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt, uint256 delay) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    /**
     * @dev Schedule an operation containing a batch of transactions.
     *
     * Emits one {CallScheduled} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function scheduleBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt, uint256 delay) public virtual onlyRole(PROPOSER_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], datas[i], predecessor, delay);
        }
    }

    /**
     * @dev Schedule an operation that is to becomes valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= getMinDelay(), "TimelockController: insufficient delay");
        // solhint-disable-next-line not-rely-on-time
        _timestamps[id] = SafeMath.add(block.timestamp, delay);
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {
        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    /**
     * @dev Execute an (ready) operation containing a single transaction.
     *
     * Emits a {CallExecuted} event.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function execute(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt) public payable virtual onlyRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(id, predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    /**
     * @dev Execute an (ready) operation containing a batch of transactions.
     *
     * Emits one {CallExecuted} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function executeBatch(address[] calldata targets, uint256[] calldata values, bytes[] calldata datas, bytes32 predecessor, bytes32 salt) public payable virtual onlyRole(EXECUTOR_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    /**
     * @dev Execute an operation's call.
     *
     * Emits a {CallExecuted} event.
     */
    function _call(bytes32 id, uint256 index, address target, uint256 value, bytes calldata data) private {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    /**
     * @dev Changes the minimum timelock duration for future operations.
     *
     * Emits a {MinDelayChange} event.
     *
     * Requirements:
     *
     * - the caller must be the timelock itself. This can only be achieved by scheduling and later executing
     * an operation where the timelock is the target and the data is the ABI-encoded call to this function.
     */
    function updateDelay(uint256 newDelay) external virtual {
        require(msg.sender == address(this), "TimelockController: caller must be timelock");
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "../utils/AdvancedMath.sol";

contract AdvancedMathWrapper {
    using AdvancedMath for uint256;

    function sqrt(uint256 value) external pure returns (uint256) {
        return value.sqrt();
    }

    function cbrt(uint256 value) external pure returns (uint256) {
        return value.cbrt();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Chess is ERC20 {
    constructor(uint256 initialSupply) public ERC20("Chess", "CHESS") {
        _mint(msg.sender, initialSupply);
    }
}