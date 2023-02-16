// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../contracts/Interfaces/NftRewardsInterfaceV6.sol";

contract GNSPairsStorageV6 {

    // Contracts (constant)
    StorageInterfaceV5 immutable storageT;

    // Params (constant)
    uint constant MIN_LEVERAGE = 2;
    uint constant MAX_LEVERAGE = 1000;

    // Custom data types
    enum FeedCalculation { DEFAULT, INVERT, COMBINE }
    struct Feed{ address feed1; address feed2; FeedCalculation feedCalculation; uint maxDeviationP; } // PRECISION (%)

    struct Pair{
        string from;
        string to;
        Feed feed;
        uint spreadP;               // PRECISION
        uint groupIndex;
        uint feeIndex;
    }
    struct Group{
        string name;
        bytes32 job;
        uint minLeverage;
        uint maxLeverage;
        uint maxCollateralP;        // % (of DAI vault current balance)
    }
    struct Fee{
        string name;
        uint openFeeP;              // PRECISION (% of leveraged pos)
        uint closeFeeP;             // PRECISION (% of leveraged pos)
        uint oracleFeeP;            // PRECISION (% of leveraged pos)
        uint nftLimitOrderFeeP;     // PRECISION (% of leveraged pos)
        uint referralFeeP;          // PRECISION (% of leveraged pos)
        uint minLevPosDai;          // 1e18 (collateral x leverage, useful for min fee)
    }

    // State
    uint public currentOrderId;

    uint public pairsCount;
    uint public groupsCount;
    uint public feesCount;

    mapping(uint => Pair) public pairs;
    mapping(uint => Group) public groups;
    mapping(uint => Fee) public fees;

    mapping(string => mapping(string => bool)) public isPairListed;

    mapping(uint => uint[2]) public groupsCollaterals; // (long, short)

    // Events
    event PairAdded(uint index, string from, string to);
    event PairUpdated(uint index);

    event GroupAdded(uint index, string name);
    event GroupUpdated(uint index);

    event FeeAdded(uint index, string name);
    event FeeUpdated(uint index);

    constructor(uint _currentOrderId, address _storageT) {
        require(_currentOrderId > 0, "ORDER_ID_0");
        currentOrderId = _currentOrderId;
        storageT = StorageInterfaceV5(_storageT);
    }

    // Modifiers
    modifier onlyGov(){ require(msg.sender == storageT.gov(), "GOV_ONLY"); _; }

    modifier groupListed(uint _groupIndex){
        require(groups[_groupIndex].minLeverage > 0, "GROUP_NOT_LISTED");
        _;
    }
    modifier feeListed(uint _feeIndex){
        require(fees[_feeIndex].openFeeP > 0, "FEE_NOT_LISTED");
        _;
    }

    modifier feedOk(Feed calldata _feed){
        require(_feed.maxDeviationP > 0 && _feed.feed1 != address(0), "WRONG_FEED");
        require(_feed.feedCalculation != FeedCalculation.COMBINE || _feed.feed2 != address(0), "FEED_2_MISSING");
        _;
    }
    modifier groupOk(Group calldata _group){
        require(_group.job != bytes32(0), "JOB_EMPTY");
        require(_group.minLeverage >= MIN_LEVERAGE && _group.maxLeverage <= MAX_LEVERAGE
            && _group.minLeverage < _group.maxLeverage, "WRONG_LEVERAGES");
        _;
    }
    modifier feeOk(Fee calldata _fee){
        require(_fee.openFeeP > 0 && _fee.closeFeeP > 0 && _fee.oracleFeeP > 0
        && _fee.nftLimitOrderFeeP > 0 && _fee.referralFeeP > 0 && _fee.minLevPosDai > 0, "WRONG_FEES");
        _;
    }

    // Manage pairs
    function addPair(Pair calldata _pair) public onlyGov feedOk(_pair.feed) groupListed(_pair.groupIndex) feeListed(_pair.feeIndex){
        require(!isPairListed[_pair.from][_pair.to], "PAIR_ALREADY_LISTED");

        pairs[pairsCount] = _pair;
        isPairListed[_pair.from][_pair.to] = true;

        emit PairAdded(pairsCount++, _pair.from, _pair.to);
    }
    function addPairs(Pair[] calldata _pairs) external{
        for(uint i = 0; i < _pairs.length; i++){
            addPair(_pairs[i]);
        }
    }
    function updatePair(uint _pairIndex, Pair calldata _pair) external onlyGov feedOk(_pair.feed) feeListed(_pair.feeIndex){
        Pair storage p = pairs[_pairIndex];
        require(isPairListed[p.from][p.to], "PAIR_NOT_LISTED");

        p.feed = _pair.feed;
        p.spreadP = _pair.spreadP;
        p.feeIndex = _pair.feeIndex;

        emit PairUpdated(_pairIndex);
    }

    // Manage groups
    function addGroup(Group calldata _group) external onlyGov groupOk(_group){
        groups[groupsCount] = _group;
        emit GroupAdded(groupsCount++, _group.name);
    }
    function updateGroup(uint _id, Group calldata _group) external onlyGov groupListed(_id) groupOk(_group){
        groups[_id] = _group;
        emit GroupUpdated(_id);
    }

    // Manage fees
    function addFee(Fee calldata _fee) external onlyGov feeOk(_fee){
        fees[feesCount] = _fee;
        emit FeeAdded(feesCount++, _fee.name);
    }
    function updateFee(uint _id, Fee calldata _fee) external onlyGov feeListed(_id) feeOk(_fee){
        fees[_id] = _fee;
        emit FeeUpdated(_id);
    }

    // Update collateral open exposure for a group (callbacks)
    function updateGroupCollateral(uint _pairIndex, uint _amount, bool _long, bool _increase) external{
        require(msg.sender == storageT.callbacks(), "CALLBACKS_ONLY");

        uint[2] storage collateralOpen = groupsCollaterals[pairs[_pairIndex].groupIndex];
        uint index = _long ? 0 : 1;

        if(_increase){
            collateralOpen[index] += _amount;
        }else{
            collateralOpen[index] = collateralOpen[index] > _amount ? collateralOpen[index] - _amount : 0;
        }
    }

    // Fetch relevant info for order (aggregator)
    function pairJob(uint _pairIndex) external returns(string memory, string memory, bytes32, uint){
        require(msg.sender == address(storageT.priceAggregator()), "AGGREGATOR_ONLY");

        Pair memory p = pairs[_pairIndex];
        require(isPairListed[p.from][p.to], "PAIR_NOT_LISTED");

        return (p.from, p.to, groups[p.groupIndex].job, currentOrderId++);
    }

    // Getters (pairs & groups)
    function getPairs(uint _pairIndex) external view returns(Pair memory) {
        return pairs[_pairIndex];
    }
    function pairFeed(uint _pairIndex) external view returns(Feed memory){
        return pairs[_pairIndex].feed;
    }
    function pairSpreadP(uint _pairIndex) external view returns(uint){
        return pairs[_pairIndex].spreadP;
    }
    function pairMinLeverage(uint _pairIndex) external view returns(uint){
        return groups[pairs[_pairIndex].groupIndex].minLeverage;
    }
    function pairMaxLeverage(uint _pairIndex) external view returns(uint){
        return groups[pairs[_pairIndex].groupIndex].maxLeverage;
    }
    function groupMaxCollateral(uint _pairIndex) external view returns(uint){
        return groups[pairs[_pairIndex].groupIndex].maxCollateralP*storageT.vault().currentBalanceDai()/100;
    }
    function groupCollateral(uint _pairIndex, bool _long) external view returns(uint){
        return groupsCollaterals[pairs[_pairIndex].groupIndex][_long ? 0 : 1];
    }
    function guaranteedSlEnabled(uint _pairIndex) external view returns(bool){
        return pairs[_pairIndex].groupIndex == 0; // crypto only
    }

    // Getters (fees)
    function pairOpenFeeP(uint _pairIndex) external view returns(uint){
        return fees[pairs[_pairIndex].feeIndex].openFeeP;
    }
    function pairCloseFeeP(uint _pairIndex) external view returns(uint){
        return fees[pairs[_pairIndex].feeIndex].closeFeeP;
    }
    function pairOracleFeeP(uint _pairIndex) external view returns(uint){
        return fees[pairs[_pairIndex].feeIndex].oracleFeeP;
    }
    function pairNftLimitOrderFeeP(uint _pairIndex) external view returns(uint){
        return fees[pairs[_pairIndex].feeIndex].nftLimitOrderFeeP;
    }
    function pairReferralFeeP(uint _pairIndex) external view returns(uint){
        return fees[pairs[_pairIndex].feeIndex].referralFeeP;
    }
    function pairMinLevPosDai(uint _pairIndex) external view returns(uint){
        return fees[pairs[_pairIndex].feeIndex].minLevPosDai;
    }

    // Getters (backend)
    function pairsBackend(uint _index) external view returns(Pair memory, Group memory, Fee memory){
        Pair memory p = pairs[_index];
        return (p, groups[p.groupIndex], fees[p.feeIndex]);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PairsStorageInterfaceV6.sol";

interface AggregatorInterfaceV6_2{
    enum OrderType { MARKET_OPEN, MARKET_CLOSE, LIMIT_OPEN, LIMIT_CLOSE, UPDATE_SL }
    function pairsStorage() external view returns(PairsStorageInterfaceV6);
    function getPrice(uint,OrderType,uint) external returns(uint);
    function tokenPriceDai() external returns(uint);
    function linkFee(uint,uint) external view returns(uint);
    function tokenDaiReservesLp() external view returns(uint, uint);
    function pendingSlOrders(uint) external view returns(PendingSl memory);
    function storePendingSlOrder(uint orderId, PendingSl calldata p) external;
    function unregisterPendingSlOrder(uint orderId) external;
    struct PendingSl{address trader; uint pairIndex; uint index; uint openPrice; bool buy; uint newSl; }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface NftInterfaceV5{
    function balanceOf(address) external view returns (uint);
    function ownerOf(uint) external view returns (address);
    function transferFrom(address, address, uint) external;
    function tokenOfOwnerByIndex(address, uint) external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./StorageInterfaceV5.sol";

interface NftRewardsInterfaceV6{
    struct TriggeredLimitId{ address trader; uint pairIndex; uint index; StorageInterfaceV5.LimitOrder order; }
    enum OpenLimitOrderType{ LEGACY, REVERSAL, MOMENTUM }
    function storeFirstToTrigger(TriggeredLimitId calldata, address) external;
    function storeTriggerSameBlock(TriggeredLimitId calldata, address) external;
    function unregisterTrigger(TriggeredLimitId calldata) external;
    function distributeNftReward(TriggeredLimitId calldata, uint) external;
    function openLimitOrderTypes(address, uint, uint) external view returns(OpenLimitOrderType);
    function setOpenLimitOrderType(address, uint, uint, OpenLimitOrderType) external;
    function triggered(TriggeredLimitId calldata) external view returns(bool);
    function timedOut(TriggeredLimitId calldata) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface PairsStorageInterfaceV6{
    enum FeedCalculation { DEFAULT, INVERT, COMBINE }    // FEED 1, 1 / (FEED 1), (FEED 1)/(FEED 2)
    struct Feed{ address feed1; address feed2; FeedCalculation feedCalculation; uint maxDeviationP; } // PRECISION (%)
    struct Pair{ string from; string to; Feed feed; uint spreadP; uint groupIndex; uint feeIndex; } // PRECISION
    function incrementCurrentOrderId() external returns(uint);
    function updateGroupCollateral(uint, uint, bool, bool) external;
    function pairJob(uint) external returns(string memory, string memory, bytes32, uint);
    function pairFeed(uint) external view returns(Feed memory);
    function pairSpreadP(uint) external view returns(uint);
    function pairMinLeverage(uint) external view returns(uint);
    function pairMaxLeverage(uint) external view returns(uint);
    function groupMaxCollateral(uint) external view returns(uint);
    function groupCollateral(uint, bool) external view returns(uint);
    function guaranteedSlEnabled(uint) external view returns(bool);
    function pairOpenFeeP(uint) external view returns(uint);
    function pairCloseFeeP(uint) external view returns(uint);
    function pairOracleFeeP(uint) external view returns(uint);
    function pairNftLimitOrderFeeP(uint) external view returns(uint);
    function pairReferralFeeP(uint) external view returns(uint);
    function pairMinLevPosDai(uint) external view returns(uint);
    function getPairs(uint) external view returns(Pair memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./TokenInterfaceV5.sol";
import "./UniswapRouterInterfaceV5.sol";
import "./AggregatorInterfaceV6_2.sol";
import "./VaultInterfaceV5.sol";
import "./NftInterfaceV5.sol";

interface StorageInterfaceV5{
    enum LimitOrder { TP, SL, LIQ, OPEN }
    struct Trader{
        uint leverageUnlocked;
        address referral;
        uint referralRewardsTotal;  // 1e18
    }
    struct Trade{
        address trader;
        uint pairIndex;
        uint index;
        uint initialPosToken;       // 1e18
        uint positionSizeDai;       // 1e18
        uint openPrice;             // PRECISION
        bool buy;
        uint leverage;
        uint tp;                    // PRECISION
        uint sl;                    // PRECISION
    }
    struct TradeInfo{
        uint tokenId;
        uint tokenPriceDai;         // PRECISION
        uint openInterestDai;       // 1e18
        uint tpLastUpdated;
        uint slLastUpdated;
        bool beingMarketClosed;
    }
    struct OpenLimitOrder{
        address trader;
        uint pairIndex;
        uint index;
        uint positionSize;          // 1e18 (DAI or GFARM2)
        uint spreadReductionP;
        bool buy;
        uint leverage;
        uint tp;                    // PRECISION (%)
        uint sl;                    // PRECISION (%)
        uint minPrice;              // PRECISION
        uint maxPrice;              // PRECISION
        uint block;
        uint tokenId;               // index in supportedTokens
    }
    struct PendingMarketOrder{
        Trade trade;
        uint block;
        uint wantedPrice;           // PRECISION
        uint slippageP;             // PRECISION (%)
        uint spreadReductionP;
        uint tokenId;               // index in supportedTokens
    }
    struct PendingNftOrder{
        address nftHolder;
        uint nftId;
        address trader;
        uint pairIndex;
        uint index;
        LimitOrder orderType;
    }
    function PRECISION() external pure returns(uint);
    function gov() external view returns(address);
    function dev() external view returns(address);
    function dai() external view returns(TokenInterfaceV5);
    function token() external view returns(TokenInterfaceV5);
    function linkErc677() external view returns(TokenInterfaceV5);
    function tokenDaiRouter() external view returns(UniswapRouterInterfaceV5);
    function priceAggregator() external view returns(AggregatorInterfaceV6_2);
    function vault() external view returns(VaultInterfaceV5);
    function trading() external view returns(address);
    function callbacks() external view returns(address);
    function handleTokens(address,uint,bool) external;
    function transferDai(address, address, uint) external;
    function transferLinkToAggregator(address, uint, uint) external;
    function unregisterTrade(address, uint, uint) external;
    function unregisterPendingMarketOrder(uint, bool) external;
    function unregisterOpenLimitOrder(address, uint, uint) external;
    function hasOpenLimitOrder(address, uint, uint) external view returns(bool);
    function storePendingMarketOrder(PendingMarketOrder memory, uint, bool) external;
    function storeReferral(address, address) external;
    function openTrades(address, uint, uint) external view returns(Trade memory);
    function openTradesInfo(address, uint, uint) external view returns(TradeInfo memory);
    function updateSl(address, uint, uint, uint) external;
    function updateTp(address, uint, uint, uint) external;
    function getOpenLimitOrder(address, uint, uint) external view returns(OpenLimitOrder memory);
    function spreadReductionsP(uint) external view returns(uint);
    function positionSizeTokenDynamic(uint,uint) external view returns(uint);
    function maxSlP() external view returns(uint);
    function storeOpenLimitOrder(OpenLimitOrder memory) external;
    function reqID_pendingMarketOrder(uint) external view returns(PendingMarketOrder memory);
    function storePendingNftOrder(PendingNftOrder memory, uint) external;
    function updateOpenLimitOrder(OpenLimitOrder calldata) external;
    function firstEmptyTradeIndex(address, uint) external view returns(uint);
    function firstEmptyOpenLimitIndex(address, uint) external view returns(uint);
    function increaseNftRewards(uint, uint) external;
    function nftSuccessTimelock() external view returns(uint);
    function currentPercentProfit(uint,uint,bool,uint) external view returns(int);
    function reqID_pendingNftOrder(uint) external view returns(PendingNftOrder memory);
    function setNftLastSuccess(uint) external;
    function updateTrade(Trade memory) external;
    function nftLastSuccess(uint) external view returns(uint);
    function unregisterPendingNftOrder(uint) external;
    function handleDevGovFees(uint, uint, bool, bool) external returns(uint);
    function distributeLpRewards(uint) external;
    function getReferral(address) external view returns(address);
    function increaseReferralRewards(address, uint) external;
    function storeTrade(Trade memory, TradeInfo memory) external;
    function setLeverageUnlocked(address, uint) external;
    function getLeverageUnlocked(address) external view returns(uint);
    function openLimitOrdersCount(address, uint) external view returns(uint);
    function maxOpenLimitOrdersPerPair() external view returns(uint);
    function openTradesCount(address, uint) external view returns(uint);
    function pendingMarketOpenCount(address, uint) external view returns(uint);
    function pendingMarketCloseCount(address, uint) external view returns(uint);
    function maxTradesPerPair() external view returns(uint);
    function maxTradesPerBlock() external view returns(uint);
    function tradesPerBlock(uint) external view returns(uint);
    function pendingOrderIdsCount(address) external view returns(uint);
    function maxPendingMarketOrders() external view returns(uint);
    function maxGainP() external view returns(uint);
    function defaultLeverageUnlocked() external view returns(uint);
    function openInterestDai(uint, uint) external view returns(uint);
    function getPendingOrderIds(address) external view returns(uint[] memory);
    function traders(address) external view returns(Trader memory);
    function nfts(uint) external view returns(NftInterfaceV5);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface TokenInterfaceV5{
    function burn(address, uint256) external;
    function mint(address, uint256) external;
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns(bool);
    function balanceOf(address) external view returns(uint256);
    function hasRole(bytes32, address) external view returns (bool);
    function approve(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface UniswapRouterInterfaceV5{
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface VaultInterfaceV5{
    function sendDaiToTrader(address, uint) external;
    function receiveDaiFromTrader(address, uint, uint) external;
    function currentBalanceDai() external view returns(uint);
    function distributeRewardDai(uint) external;
}