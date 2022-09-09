// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './ISymbol.sol';
import './SymbolStorage.sol';
import '../oracle/IOracleManager.sol';
import '../library/SafeMath.sol';
import '../library/DpmmLinearPricing.sol';
import '../library/EverlastingOptionPricing.sol';
import '../utils/NameVersion.sol';

contract SymbolImplementationOption is SymbolStorage, NameVersion {

    using SafeMath for uint256;
    using SafeMath for int256;

    int256 constant ONE = 1e18;

    address public immutable manager;

    address public immutable oracleManager;

    bytes32 public immutable symbolId;

    bytes32 public immutable priceId; // used to get indexPrice from oracleManager

    bytes32 public immutable volatilityId; // used to get volatility from oracleManager

    int256 public immutable feeRatioNotional;

    int256 public immutable feeRatioMark;

    int256 public immutable strikePrice;

    int256 public immutable alpha;

    int256 public immutable fundingPeriod; // in seconds (without 1e18 base)

    int256 public immutable minTradeVolume;

    int256 public immutable initialMarginRatio;

    int256 public immutable maintenanceMarginRatio;

    int256 public immutable pricePercentThreshold; // max price percent change to force settlement

    uint256 public immutable timeThreshold; // max time delay in seconds (without 1e18 base) to force settlement

    int256 public immutable startingPriceShiftLimit; // Max price shift in percentage allowed before trade/liquidation

    bool   public immutable isCall;

    bool   public immutable isCloseOnly;

    modifier _onlyManager_() {
        require(msg.sender == manager, 'SymbolImplementationOption: only manager');
        _;
    }

    constructor (
        address manager_,
        address oracleManager_,
        string[3] memory symbols_,
        int256[11] memory parameters_,
        bool[2] memory boolParameters_
    ) NameVersion('SymbolImplementationOption', '3.0.2')
    {
        manager = manager_;
        oracleManager = oracleManager_;

        symbol = symbols_[0];
        symbolId = keccak256(abi.encodePacked(symbols_[0]));
        priceId = keccak256(abi.encodePacked(symbols_[1]));
        volatilityId = keccak256(abi.encodePacked(symbols_[2]));

        feeRatioNotional = parameters_[0];
        feeRatioMark = parameters_[1];
        strikePrice = parameters_[2];
        alpha = parameters_[3];
        fundingPeriod = parameters_[4];
        minTradeVolume = parameters_[5];
        initialMarginRatio = parameters_[6];
        maintenanceMarginRatio = parameters_[7];
        pricePercentThreshold = parameters_[8];
        timeThreshold = parameters_[9].itou();
        startingPriceShiftLimit = parameters_[10];

        isCall = boolParameters_[0];
        isCloseOnly = boolParameters_[1];

        require(
            IOracleManager(oracleManager).value(priceId) != 0,
            'SymbolImplementationOption.constructor: no price oracle'
        );
        require(
            IOracleManager(oracleManager).value(volatilityId) != 0,
            'SymbolImplementationOption.constructor: no volatility oracle'
        );
    }

    function hasPosition(uint256 pTokenId) external view returns (bool) {
        return positions[pTokenId].volume != 0;
    }

    //================================================================================

    function settleOnAddLiquidity(int256 liquidity)
    external _onlyManager_ returns (ISymbol.SettlementOnAddLiquidity memory s)
    {
        Data memory data;

        if (_getNetVolumeAndCostWithSkip(data)) return s;
        if (_getTimestampAndPriceWithSkip(data)) return s;
        _getFunding(data, liquidity);
        _getTradersPnl(data);
        _getInitialMarginRequired(data);

        s.settled = true;
        s.funding = data.funding;
        s.deltaTradersPnl = data.tradersPnl - tradersPnl;
        s.deltaInitialMarginRequired = data.initialMarginRequired - initialMarginRequired;

        indexPrice = data.curIndexPrice;
        fundingTimestamp = data.curTimestamp;
        cumulativeFundingPerVolume = data.cumulativeFundingPerVolume;
        tradersPnl = data.tradersPnl;
        initialMarginRequired = data.initialMarginRequired;
    }

    function settleOnRemoveLiquidity(int256 liquidity, int256 removedLiquidity)
    external _onlyManager_ returns (ISymbol.SettlementOnRemoveLiquidity memory s)
    {
        Data memory data;

        if (_getNetVolumeAndCostWithSkip(data)) return s;
        _getTimestampAndPrice(data);
        _getFunding(data, liquidity);
        _getTradersPnl(data);
        _getInitialMarginRequired(data);

        s.settled = true;
        s.funding = data.funding;
        s.deltaTradersPnl = data.tradersPnl - tradersPnl;
        s.deltaInitialMarginRequired = data.initialMarginRequired - initialMarginRequired;
        s.removeLiquidityPenalty = _getRemoveLiquidityPenalty(data, liquidity - removedLiquidity);

        indexPrice = data.curIndexPrice;
        fundingTimestamp = data.curTimestamp;
        cumulativeFundingPerVolume = data.cumulativeFundingPerVolume;
        tradersPnl = data.tradersPnl;
        initialMarginRequired = data.initialMarginRequired;
    }

    function settleOnTraderWithPosition(uint256 pTokenId, int256 liquidity)
    external _onlyManager_ returns (ISymbol.SettlementOnTraderWithPosition memory s)
    {
        Data memory data;

        _getNetVolumeAndCost(data);
        _getTimestampAndPrice(data);
        _getFunding(data, liquidity);
        _getTradersPnl(data);
        _getInitialMarginRequired(data);

        Position memory p = positions[pTokenId];

        s.funding = data.funding;
        s.deltaTradersPnl = data.tradersPnl - tradersPnl;
        s.deltaInitialMarginRequired = data.initialMarginRequired - initialMarginRequired;

        int256 diff;
        unchecked { diff = data.cumulativeFundingPerVolume - p.cumulativeFundingPerVolume; }
        s.traderFunding = p.volume * diff / ONE;

        s.traderPnl = p.volume * data.theoreticalPrice / ONE - p.cost;
        s.traderInitialMarginRequired = p.volume.abs() * data.initialMarginPerVolume / ONE;

        indexPrice = data.curIndexPrice;
        fundingTimestamp = data.curTimestamp;
        cumulativeFundingPerVolume = data.cumulativeFundingPerVolume;
        tradersPnl = data.tradersPnl;
        initialMarginRequired = data.initialMarginRequired;

        positions[pTokenId].cumulativeFundingPerVolume = data.cumulativeFundingPerVolume;
    }

    // priceLimit: the average trade price cannot exceeds priceLimit
    // for long, averageTradePrice <= priceLimit; for short, averageTradePrice >= priceLimit
    function settleOnTrade(uint256 pTokenId, int256 tradeVolume, int256 liquidity, int256 priceLimit)
    external _onlyManager_ returns (ISymbol.SettlementOnTrade memory s)
    {
        _updateLastNetVolume();

        require(
            tradeVolume != 0 && tradeVolume % minTradeVolume == 0,
            'SymbolImplementationOption.settleOnTrade: invalid tradeVolume'
        );

        Data memory data;
        _getNetVolumeAndCost(data);
        _getTimestampAndPrice(data);
        _getFunding(data, liquidity);

        Position memory p = positions[pTokenId];

        if (isCloseOnly) {
            require(
                (p.volume > 0 && tradeVolume < 0 && p.volume + tradeVolume >= 0) ||
                (p.volume < 0 && tradeVolume > 0 && p.volume + tradeVolume <= 0),
                'SymbolImplementationOption.settleOnTrade: close only'
            );
        }

        int256 diff;
        unchecked { diff = data.cumulativeFundingPerVolume - p.cumulativeFundingPerVolume; }
        s.traderFunding = p.volume * diff / ONE;

        s.tradeCost = DpmmLinearPricing.calculateCost(
            data.theoreticalPrice,
            data.K,
            data.netVolume,
            tradeVolume
        );

        s.tradeFee = SafeMath.min(
            data.curIndexPrice * tradeVolume.abs() / ONE * feeRatioNotional / ONE,
            s.tradeCost.abs() * feeRatioMark / ONE
        );

        // check slippage
        int256 averageTradePrice = s.tradeCost * ONE / tradeVolume;
        require(
            (tradeVolume > 0 && averageTradePrice <= priceLimit) ||
            (tradeVolume < 0 && averageTradePrice >= priceLimit),
            'SymbolImplementationOption.settleOnTrade: slippage exceeds allowance'
        );

        if (!(p.volume >= 0 && tradeVolume >= 0) && !(p.volume <= 0 && tradeVolume <= 0)) {
            int256 absVolume = p.volume.abs();
            int256 absTradeVolume = tradeVolume.abs();
            if (absVolume <= absTradeVolume) {
                s.tradeRealizedCost = s.tradeCost * absVolume / absTradeVolume + p.cost;
            } else {
                s.tradeRealizedCost = p.cost * absTradeVolume / absVolume + s.tradeCost;
            }
        }

        data.netVolume += tradeVolume;
        data.netCost += s.tradeCost - s.tradeRealizedCost;
        _getTradersPnl(data);
        _getInitialMarginRequired(data);

        require(
            DpmmLinearPricing.calculateMarkPrice(data.theoreticalPrice, data.K, data.netVolume) > 0,
            'SymbolImplementationOption.settleOnTrade: exceed mark limit'
        );

        p.volume += tradeVolume;
        p.cost += s.tradeCost - s.tradeRealizedCost;
        p.cumulativeFundingPerVolume = data.cumulativeFundingPerVolume;

        s.funding = data.funding;
        s.deltaTradersPnl = data.tradersPnl - tradersPnl;
        s.deltaInitialMarginRequired = data.initialMarginRequired - initialMarginRequired;
        s.indexPrice = data.curIndexPrice;

        s.traderPnl = p.volume * data.theoreticalPrice / ONE - p.cost;
        s.traderInitialMarginRequired = p.volume.abs() * data.initialMarginPerVolume / ONE;

        if (p.volume == 0) {
            s.positionChangeStatus = -1;
            nPositionHolders--;
        } else if (p.volume - tradeVolume == 0) {
            s.positionChangeStatus = 1;
            nPositionHolders++;
        }

        netVolume = data.netVolume;
        netCost = data.netCost;
        indexPrice = data.curIndexPrice;
        fundingTimestamp = data.curTimestamp;
        cumulativeFundingPerVolume = data.cumulativeFundingPerVolume;
        tradersPnl = data.tradersPnl;
        initialMarginRequired = data.initialMarginRequired;

        positions[pTokenId] = p;
    }

    function settleOnLiquidate(uint256 pTokenId, int256 liquidity)
    external _onlyManager_ returns (ISymbol.SettlementOnLiquidate memory s)
    {
        _updateLastNetVolume();

        Data memory data;

        _getNetVolumeAndCost(data);
        _getTimestampAndPrice(data);
        _getFunding(data, liquidity);

        Position memory p = positions[pTokenId];

        // check price shift
        int256 netVolumeShiftAllowance = startingPriceShiftLimit * ONE / data.K;
        require(
            (p.volume >= 0 && data.netVolume + netVolumeShiftAllowance >= lastNetVolume) ||
            (p.volume <= 0 && data.netVolume <= lastNetVolume + netVolumeShiftAllowance),
            'SymbolImplementationOption.settleOnLiquidate: slippage exceeds allowance'
        );

        int256 diff;
        unchecked { diff = data.cumulativeFundingPerVolume - p.cumulativeFundingPerVolume; }
        s.traderFunding = p.volume * diff / ONE;

        s.tradeVolume = -p.volume;
        s.tradeCost = DpmmLinearPricing.calculateCost(
            data.theoreticalPrice,
            data.K,
            data.netVolume,
            -p.volume
        );
        s.tradeRealizedCost = s.tradeCost + p.cost;

        data.netVolume -= p.volume;
        data.netCost -= p.cost;
        _getTradersPnl(data);
        _getInitialMarginRequired(data);

        s.funding = data.funding;
        s.deltaTradersPnl = data.tradersPnl - tradersPnl;
        s.deltaInitialMarginRequired = data.initialMarginRequired - initialMarginRequired;
        s.indexPrice = data.curIndexPrice;

        s.traderPnl = p.volume * data.theoreticalPrice / ONE - p.cost;
        s.traderMaintenanceMarginRequired = p.volume.abs() * data.maintenanceMarginPerVolume / ONE;

        netVolume = data.netVolume;
        netCost = data.netCost;
        indexPrice = data.curIndexPrice;
        fundingTimestamp = data.curTimestamp;
        cumulativeFundingPerVolume = data.cumulativeFundingPerVolume;
        tradersPnl = data.tradersPnl;
        initialMarginRequired = data.initialMarginRequired;
        if (p.volume != 0) {
            nPositionHolders--;
        }

        delete positions[pTokenId];
    }

    //================================================================================

    struct Data {
        uint256 preTimestamp;
        uint256 curTimestamp;
        int256 preIndexPrice;
        int256 curIndexPrice;
        int256 netVolume;
        int256 netCost;
        int256 cumulativeFundingPerVolume;
        int256 K;
        int256 tradersPnl;
        int256 initialMarginRequired;
        int256 funding;

        int256 intrinsicValue;
        int256 timeValue;
        int256 delta;
        int256 u;
        int256 theoreticalPrice;
        int256 initialMarginPerVolume;
        int256 maintenanceMarginPerVolume;
    }

    function _getNetVolumeAndCost(Data memory data) internal view {
        data.netVolume = netVolume;
        data.netCost = netCost;
    }

    function _getNetVolumeAndCostWithSkip(Data memory data) internal view returns (bool) {
        data.netVolume = netVolume;
        if (data.netVolume == 0) {
            return true;
        }
        data.netCost = netCost;
        return false;
    }

    function _getTimestampAndPrice(Data memory data) internal view {
        data.preTimestamp = fundingTimestamp;
        data.curTimestamp = block.timestamp;
        data.curIndexPrice = IOracleManager(oracleManager).getValue(priceId).utoi();
    }

    function _getTimestampAndPriceWithSkip(Data memory data) internal view returns (bool) {
        _getTimestampAndPrice(data);
        data.preIndexPrice = indexPrice;
        return (
            data.curTimestamp < data.preTimestamp + timeThreshold &&
            (data.curIndexPrice - data.preIndexPrice).abs() * ONE < data.preIndexPrice * pricePercentThreshold
        );
    }

    function _calculateK(int256 indexPrice, int256 theoreticalPrice, int256 delta, int256 liquidity)
    internal view returns (int256)
    {
        return indexPrice ** 2 / theoreticalPrice * delta.abs() * alpha / liquidity / ONE;
    }

    function _getFunding(Data memory data, int256 liquidity) internal view {
        data.cumulativeFundingPerVolume = cumulativeFundingPerVolume;

        int256 volatility = IOracleManager(oracleManager).getValue(volatilityId).utoi();
        data.intrinsicValue = isCall ?
                              (data.curIndexPrice - strikePrice).max(0) :
                              (strikePrice - data.curIndexPrice).max(0);
        (data.timeValue, data.delta, data.u) = EverlastingOptionPricing.getEverlastingTimeValueAndDelta(
            data.curIndexPrice, strikePrice, volatility, fundingPeriod * ONE / 31536000
        );
        data.theoreticalPrice = data.intrinsicValue + data.timeValue;

        if (data.intrinsicValue > 0) {
            if (isCall) data.delta += ONE;
            else data.delta -= ONE;
        } else if (data.curIndexPrice == strikePrice) {
            if (isCall) data.delta = ONE / 2;
            else data.delta = -ONE / 2;
        }

        data.K = _calculateK(data.curIndexPrice, data.theoreticalPrice, data.delta, liquidity);

        int256 markPrice = DpmmLinearPricing.calculateMarkPrice(
            data.theoreticalPrice, data.K, data.netVolume
        );
        int256 diff = (markPrice - data.intrinsicValue) * (data.curTimestamp - data.preTimestamp).utoi() / fundingPeriod;

        data.funding = data.netVolume * diff / ONE;
        unchecked { data.cumulativeFundingPerVolume += diff; }
    }

    function _getTradersPnl(Data memory data) internal pure {
        data.tradersPnl = -DpmmLinearPricing.calculateCost(data.theoreticalPrice, data.K, data.netVolume, -data.netVolume) - data.netCost;
    }

    function _getInitialMarginRequired(Data memory data) internal view {
        int256 deltaPart = data.delta * (isCall ? data.curIndexPrice : -data.curIndexPrice) / ONE * maintenanceMarginRatio / ONE;
        int256 gammaPart = (data.u * data.u / ONE - ONE) * data.timeValue / ONE / 8 * maintenanceMarginRatio / ONE * maintenanceMarginRatio / ONE;

        data.maintenanceMarginPerVolume = deltaPart + gammaPart;
        data.initialMarginPerVolume = data.maintenanceMarginPerVolume * initialMarginRatio / maintenanceMarginRatio;
        data.initialMarginRequired = data.netVolume.abs() * data.initialMarginPerVolume / ONE;
    }

    function _getRemoveLiquidityPenalty(Data memory data, int256 newLiquidity)
    internal view returns (int256)
    {
        int256 newK = _calculateK(data.curIndexPrice, data.theoreticalPrice, data.delta, newLiquidity);
        int256 newPnl = -DpmmLinearPricing.calculateCost(data.theoreticalPrice, newK, data.netVolume, -data.netVolume) - data.netCost;
        return newPnl - data.tradersPnl;
    }

    // update lastNetVolume if this is the first transaction in current block
    function _updateLastNetVolume() internal {
        if (block.number > lastNetVolumeBlock) {
            lastNetVolume = netVolume;
            lastNetVolumeBlock = block.number;
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface ISymbol {

    struct SettlementOnAddLiquidity {
        bool settled;
        int256 funding;
        int256 deltaTradersPnl;
        int256 deltaInitialMarginRequired;
    }

    struct SettlementOnRemoveLiquidity {
        bool settled;
        int256 funding;
        int256 deltaTradersPnl;
        int256 deltaInitialMarginRequired;
        int256 removeLiquidityPenalty;
    }

    struct SettlementOnTraderWithPosition {
        int256 funding;
        int256 deltaTradersPnl;
        int256 deltaInitialMarginRequired;
        int256 traderFunding;
        int256 traderPnl;
        int256 traderInitialMarginRequired;
    }

    struct SettlementOnTrade {
        int256 funding;
        int256 deltaTradersPnl;
        int256 deltaInitialMarginRequired;
        int256 indexPrice;
        int256 traderFunding;
        int256 traderPnl;
        int256 traderInitialMarginRequired;
        int256 tradeCost;
        int256 tradeFee;
        int256 tradeRealizedCost;
        int256 positionChangeStatus; // 1: new open (enter), -1: total close (exit), 0: others (not change)
    }

    struct SettlementOnLiquidate {
        int256 funding;
        int256 deltaTradersPnl;
        int256 deltaInitialMarginRequired;
        int256 indexPrice;
        int256 traderFunding;
        int256 traderPnl;
        int256 traderMaintenanceMarginRequired;
        int256 tradeVolume;
        int256 tradeCost;
        int256 tradeRealizedCost;
    }

    struct Position {
        int256 volume;
        int256 cost;
        int256 cumulativeFundingPerVolume;
    }

    function implementation() external view returns (address);

    function symbol() external view returns (string memory);

    function netVolume() external view returns (int256);

    function netCost() external view returns (int256);

    function indexPrice() external view returns (int256);

    function fundingTimestamp() external view returns (uint256);

    function cumulativeFundingPerVolume() external view returns (int256);

    function tradersPnl() external view returns (int256);

    function initialMarginRequired() external view returns (int256);

    function nPositionHolders() external view returns (uint256);

    function positions(uint256 pTokenId) external view returns (Position memory);

    function setImplementation(address newImplementation) external;

    function manager() external view returns (address);

    function oracleManager() external view returns (address);

    function symbolId() external view returns (bytes32);

    function feeRatio() external view returns (int256);             // futures only

    function alpha() external view returns (int256);

    function fundingPeriod() external view returns (int256);

    function minTradeVolume() external view returns (int256);

    function initialMarginRatio() external view returns (int256);

    function maintenanceMarginRatio() external view returns (int256);

    function pricePercentThreshold() external view returns (int256);

    function timeThreshold() external view returns (uint256);

    function isCloseOnly() external view returns (bool);

    function priceId() external view returns (bytes32);              // option only

    function volatilityId() external view returns (bytes32);         // option only

    function feeRatioITM() external view returns (int256);           // option only

    function feeRatioOTM() external view returns (int256);           // option only

    function strikePrice() external view returns (int256);           // option only

    function minInitialMarginRatio() external view returns (int256); // option only

    function isCall() external view returns (bool);                  // option only

    function hasPosition(uint256 pTokenId) external view returns (bool);

    function settleOnAddLiquidity(int256 liquidity)
    external returns (ISymbol.SettlementOnAddLiquidity memory s);

    function settleOnRemoveLiquidity(int256 liquidity, int256 removedLiquidity)
    external returns (ISymbol.SettlementOnRemoveLiquidity memory s);

    function settleOnTraderWithPosition(uint256 pTokenId, int256 liquidity)
    external returns (ISymbol.SettlementOnTraderWithPosition memory s);

    function settleOnTrade(uint256 pTokenId, int256 tradeVolume, int256 liquidity, int256 priceLimit)
    external returns (ISymbol.SettlementOnTrade memory s);

    function settleOnLiquidate(uint256 pTokenId, int256 liquidity)
    external returns (ISymbol.SettlementOnLiquidate memory s);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../utils/Admin.sol';

abstract contract SymbolStorage is Admin {

    // admin will be truned in to Timelock after deployment

    event NewImplementation(address newImplementation);

    address public implementation;

    string public symbol;

    int256 public netVolume;

    int256 public netCost;

    int256 public indexPrice;

    uint256 public fundingTimestamp;

    int256 public cumulativeFundingPerVolume;

    int256 public tradersPnl;

    int256 public initialMarginRequired;

    uint256 public nPositionHolders;

    struct Position {
        int256 volume;
        int256 cost;
        int256 cumulativeFundingPerVolume;
    }

    // pTokenId => Position
    mapping (uint256 => Position) public positions;

    // The recorded net volume at the beginning of current block
    // which only update once in one block and cannot be manipulated in one block
    int256 public lastNetVolume;

    // The block number in which lastNetVolume updated
    uint256 public lastNetVolumeBlock;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../utils/INameVersion.sol';
import '../utils/IAdmin.sol';

interface IOracleManager is INameVersion, IAdmin {

    event NewOracle(bytes32 indexed symbolId, address indexed oracle);

    function getOracle(bytes32 symbolId) external view returns (address);

    function getOracle(string memory symbol) external view returns (address);

    function setOracle(address oracleAddress) external;

    function delOracle(bytes32 symbolId) external;

    function delOracle(string memory symbol) external;

    function value(bytes32 symbolId) external view returns (uint256);

    function getValue(bytes32 symbolId) external view returns (uint256);

    function updateValue(
        bytes32 symbolId,
        uint256 timestamp_,
        uint256 value_,
        uint8   v_,
        bytes32 r_,
        bytes32 s_
    ) external returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

library SafeMath {

    uint256 constant UMAX = 2 ** 255 - 1;
    int256  constant IMIN = -2 ** 255;

    function utoi(uint256 a) internal pure returns (int256) {
        require(a <= UMAX, 'SafeMath.utoi: overflow');
        return int256(a);
    }

    function itou(int256 a) internal pure returns (uint256) {
        require(a >= 0, 'SafeMath.itou: underflow');
        return uint256(a);
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != IMIN, 'SafeMath.abs: overflow');
        return a >= 0 ? a : -a;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function max(int256 a, int256 b) internal pure returns (int256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a <= b ? a : b;
    }

    // rescale a uint256 from base 10**decimals1 to 10**decimals2
    function rescale(uint256 a, uint256 decimals1, uint256 decimals2) internal pure returns (uint256) {
        return decimals1 == decimals2 ? a : a * 10**decimals2 / 10**decimals1;
    }

    // rescale towards zero
    // b: rescaled value in decimals2
    // c: the remainder
    function rescaleDown(uint256 a, uint256 decimals1, uint256 decimals2) internal pure returns (uint256 b, uint256 c) {
        b = rescale(a, decimals1, decimals2);
        c = a - rescale(b, decimals2, decimals1);
    }

    // rescale towards infinity
    // b: rescaled value in decimals2
    // c: the excessive
    function rescaleUp(uint256 a, uint256 decimals1, uint256 decimals2) internal pure returns (uint256 b, uint256 c) {
        b = rescale(a, decimals1, decimals2);
        uint256 d = rescale(b, decimals2, decimals1);
        if (d != a) {
            b += 1;
            c = rescale(b, decimals2, decimals1) - a;
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

library DpmmLinearPricing {

    int256 constant ONE = 1e18;

    function calculateMarkPrice(
        int256 indexPrice,
        int256 K,
        int256 tradersNetVolume
    ) internal pure returns (int256)
    {
        return indexPrice * (ONE + K * tradersNetVolume / ONE) / ONE;
    }

    function calculateCost(
        int256 indexPrice,
        int256 K,
        int256 tradersNetVolume,
        int256 tradeVolume
    ) internal pure returns (int256)
    {
        int256 r = ((tradersNetVolume + tradeVolume) ** 2 - tradersNetVolume ** 2) / ONE * K / ONE / 2 + tradeVolume;
        return indexPrice * r / ONE;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

library EverlastingOptionPricing {

    uint128 private constant TWO127 = 0x80000000000000000000000000000000;   // 2^127
    uint128 private constant TWO128_1 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // 2^128 - 1
    int128  private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    int256  private constant ONE = 10**18;
    uint256 private constant UONE = 10**18;

    function utoi(uint256 a) internal pure returns (int256) {
        require(a <= 2**255 - 1);
        return int256(a);
    }

    function itou(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }

    function int256To128(int256 a) internal pure returns (int128) {
        require(a >= -2**127);
        require(a <= 2**127 - 1);
        return int128(a);
    }

    /*
     * Return index of most significant non-zero bit in given non-zero 256-bit
     * unsigned integer value.
     *
     * @param x value to get index of most significant non-zero bit in
     * @return index of most significant non-zero bit in given number
     */
    function mostSignificantBit (uint256 x) internal pure returns (uint8 r) {
        require (x > 0);

        if (x >= 0x100000000000000000000000000000000) {x >>= 128; r += 128;}
        if (x >= 0x10000000000000000) {x >>= 64; r += 64;}
        if (x >= 0x100000000) {x >>= 32; r += 32;}
        if (x >= 0x10000) {x >>= 16; r += 16;}
        if (x >= 0x100) {x >>= 8; r += 8;}
        if (x >= 0x10) {x >>= 4; r += 4;}
        if (x >= 0x4) {x >>= 2; r += 2;}
        if (x >= 0x2) r += 1; // No need to shift x anymore
    }

    /*
     * Calculate log_2 (x / 2^128) * 2^128.
     *
     * @param x parameter value
     * @return log_2 (x / 2^128) * 2^128
     */
    function _log_2 (uint256 x) internal pure returns (int256) {
        require (x > 0);

        uint8 msb = mostSignificantBit (x);

        if (msb > 128) x >>= msb - 128;
        else if (msb < 128) x <<= 128 - msb;

        x &= TWO128_1;

        int256 result = (int256 (uint256(msb)) - 128) << 128; // Integer part of log_2

        int256 bit = int256(uint256(TWO127));
        for (uint8 i = 0; i < 128 && x > 0; i++) {
            x = (x << 1) + ((x * x + TWO127) >> 128);
            if (x > TWO128_1) {
                result |= bit;
                x = (x >> 1) - TWO127;
            }
            bit >>= 1;
        }

        return result;
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function _exp_2 (int128 x) internal pure returns (int128) {
        unchecked {
            require (x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            uint256 result = 0x80000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0)
                result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
            if (x & 0x4000000000000000 > 0)
                result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
            if (x & 0x2000000000000000 > 0)
                result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
            if (x & 0x1000000000000000 > 0)
                result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
            if (x & 0x800000000000000 > 0)
                result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
            if (x & 0x400000000000000 > 0)
                result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
            if (x & 0x200000000000000 > 0)
                result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
            if (x & 0x100000000000000 > 0)
                result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
            if (x & 0x80000000000000 > 0)
                result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
            if (x & 0x40000000000000 > 0)
                result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
            if (x & 0x20000000000000 > 0)
                result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
            if (x & 0x10000000000000 > 0)
                result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
            if (x & 0x8000000000000 > 0)
                result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
            if (x & 0x4000000000000 > 0)
                result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
            if (x & 0x2000000000000 > 0)
                result = result * 0x1000162E525EE054754457D5995292026 >> 128;
            if (x & 0x1000000000000 > 0)
                result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
            if (x & 0x800000000000 > 0)
                result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
            if (x & 0x400000000000 > 0)
                result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
            if (x & 0x200000000000 > 0)
                result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
            if (x & 0x100000000000 > 0)
                result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
            if (x & 0x80000000000 > 0)
                result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
            if (x & 0x40000000000 > 0)
                result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
            if (x & 0x20000000000 > 0)
                result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
            if (x & 0x10000000000 > 0)
                result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
            if (x & 0x8000000000 > 0)
                result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
            if (x & 0x4000000000 > 0)
                result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
            if (x & 0x2000000000 > 0)
                result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
            if (x & 0x1000000000 > 0)
                result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
            if (x & 0x800000000 > 0)
                result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
            if (x & 0x400000000 > 0)
                result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
            if (x & 0x200000000 > 0)
                result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
            if (x & 0x100000000 > 0)
                result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
            if (x & 0x80000000 > 0)
                result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
            if (x & 0x40000000 > 0)
                result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
            if (x & 0x20000000 > 0)
                result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
            if (x & 0x10000000 > 0)
                result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
            if (x & 0x8000000 > 0)
                result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
            if (x & 0x4000000 > 0)
                result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
            if (x & 0x2000000 > 0)
                result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
            if (x & 0x1000000 > 0)
                result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
            if (x & 0x800000 > 0)
                result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
            if (x & 0x400000 > 0)
                result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
            if (x & 0x200000 > 0)
                result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
            if (x & 0x100000 > 0)
                result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
            if (x & 0x80000 > 0)
                result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
            if (x & 0x40000 > 0)
                result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
            if (x & 0x20000 > 0)
                result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
            if (x & 0x10000 > 0)
                result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
            if (x & 0x8000 > 0)
                result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
            if (x & 0x4000 > 0)
                result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
            if (x & 0x2000 > 0)
                result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
            if (x & 0x1000 > 0)
                result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
            if (x & 0x800 > 0)
                result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
            if (x & 0x400 > 0)
                result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
            if (x & 0x200 > 0)
                result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
            if (x & 0x100 > 0)
                result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
            if (x & 0x80 > 0)
                result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
            if (x & 0x40 > 0)
                result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
            if (x & 0x20 > 0)
                result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
            if (x & 0x10 > 0)
                result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
            if (x & 0x8 > 0)
                result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
            if (x & 0x4 > 0)
                result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
            if (x & 0x2 > 0)
                result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
            if (x & 0x1 > 0)
                result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

            result >>= uint256 (int256 (63 - (x >> 64)));
            require (result <= uint256 (int256 (MAX_64x64)));

            return int128 (int256 (result));
        }
    }

    // x in 18 decimals, y in 18 decimals
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        x *= UONE;
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // calculate x^y, x, y and return in 18 decimals
    function exp(uint256 x, int256 y) internal pure returns (int256) {
        int256 log2x = _log_2((x << 128) / UONE) * ONE >> 128;
        int256 p = log2x * y / ONE;
        return _exp_2(int256To128((p << 64) / ONE)) * ONE >> 64;
    }

    function getEverlastingTimeValue(int256 S, int256 K, int256 V, int256 T)
    internal pure returns (int256 timeValue, int256 u)
    {
        int256 u2 = ONE * 8 * ONE / V * ONE / V * ONE / T + ONE;
        u = utoi(sqrt(itou(u2)));

        uint256 x = itou(S * ONE / K);
        if (S > K) {
            timeValue = K * exp(x, (ONE - u) / 2) / u;
        } else if (S == K) {
            timeValue = K * ONE / u;
        } else {
            timeValue = K * exp(x, (ONE + u) / 2) / u;
        }
    }

    function getEverlastingTimeValueAndDelta(int256 S, int256 K, int256 V, int256 T)
    internal pure returns (int256 timeValue, int256 delta, int256 u)
    {
        int256 u2 = ONE * 8 * ONE / V * ONE / V * ONE / T + ONE;
        u = utoi(sqrt(itou(u2)));

        uint256 x = itou(S * ONE / K);
        if (S > K) {
            timeValue = K * exp(x, (ONE - u) / 2) / u;
            delta = (ONE - u) * timeValue / S / 2;
        } else if (S == K) {
            timeValue = K * ONE / u;
            delta = 0;
        } else {
            timeValue = K * exp(x, (ONE + u) / 2) / u;
            delta = (ONE + u) * timeValue / S / 2;
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './INameVersion.sol';

/**
 * @dev Convenience contract for name and version information
 */
abstract contract NameVersion is INameVersion {

    bytes32 public immutable nameId;
    bytes32 public immutable versionId;

    constructor (string memory name, string memory version) {
        nameId = keccak256(abi.encodePacked(name));
        versionId = keccak256(abi.encodePacked(version));
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './IAdmin.sol';

abstract contract Admin is IAdmin {

    address public admin;

    modifier _onlyAdmin_() {
        require(msg.sender == admin, 'Admin: only admin');
        _;
    }

    constructor () {
        admin = msg.sender;
        emit NewAdmin(admin);
    }

    function setAdmin(address newAdmin) external _onlyAdmin_ {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IAdmin {

    event NewAdmin(address indexed newAdmin);

    function admin() external view returns (address);

    function setAdmin(address newAdmin) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface INameVersion {

    function nameId() external view returns (bytes32);

    function versionId() external view returns (bytes32);

}