// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "../contracts/Interfaces/GNSStakingInterfaceV6_2.sol";
import "../contracts/Interfaces/AggregatorInterfaceV5.sol";
import "../contracts/Interfaces/NftRewardsInterfaceV6.sol";

contract GNSReferralsV6_2 {

    // CONSTANTS
    uint constant PRECISION = 1e10;
    StorageInterfaceV5 public immutable storageT;

    // ADJUSTABLE PARAMETERS
    uint public allyFeeP;           // % (of referrer fees going to allies, eg. 10)
    uint public startReferrerFeeP;  // % (of referrer fee when 0 volume referred, eg. 75)
    uint public openFeeP;           // % (of opening fee used for referral system, eg. 33)
    uint public targetVolumeDai;    // DAI (to reach maximum referral system fee, eg. 1e8)

    // CUSTOM TYPES
    struct AllyDetails{
        address[] referrersReferred;
        uint volumeReferredDai;    // 1e18
        uint pendingRewardsToken;  // 1e18
        uint totalRewardsToken;    // 1e18
        uint totalRewardsValueDai; // 1e18
        bool active;
    }

    struct ReferrerDetails{
        address ally;
        address[] tradersReferred;
        uint volumeReferredDai;    // 1e18
        uint pendingRewardsToken;  // 1e18
        uint totalRewardsToken;    // 1e18
        uint totalRewardsValueDai; // 1e18
        bool active;
    }

    // STATE (MAPPINGS)
    mapping(address => AllyDetails) public allyDetails;
    mapping(address => ReferrerDetails) public referrerDetails;

    mapping(address => address) public referrerByTrader;

    // EVENTS
    event UpdatedAllyFeeP(uint value);
    event UpdatedStartReferrerFeeP(uint value);
    event UpdatedOpenFeeP(uint value);
    event UpdatedTargetVolumeDai(uint value);

    event AllyWhitelisted(address indexed ally);
    event AllyUnwhitelisted(address indexed ally);

    event ReferrerWhitelisted(
        address indexed referrer,
        address indexed ally
    );
    event ReferrerUnwhitelisted(address indexed referrer);
    event ReferrerRegistered(
        address indexed trader,
        address indexed referrer
    );

    event AllyRewardDistributed(
        address indexed ally,
        address indexed trader,
        uint volumeDai,
        uint amountToken,
        uint amountValueDai
    );
    event ReferrerRewardDistributed(
        address indexed referrer,
        address indexed trader,
        uint volumeDai,
        uint amountToken,
        uint amountValueDai
    );

    event AllyRewardsClaimed(
        address indexed ally,
        uint amountToken
    );
    event ReferrerRewardsClaimed(
        address indexed referrer,
        uint amountToken
    );

    constructor(
        StorageInterfaceV5 _storageT,
        uint _allyFeeP,
        uint _startReferrerFeeP,
        uint _openFeeP,
        uint _targetVolumeDai
    ){
        require(address(_storageT) != address(0)
        && _allyFeeP <= 50
        && _startReferrerFeeP <= 100
        && _openFeeP <= 50
            && _targetVolumeDai > 0, "WRONG_PARAMS");

        storageT = _storageT;

        allyFeeP = _allyFeeP;
        startReferrerFeeP = _startReferrerFeeP;
        openFeeP = _openFeeP;
        targetVolumeDai = _targetVolumeDai;
    }

    // MODIFIERS
    modifier onlyGov(){
        require(msg.sender == storageT.gov(), "GOV_ONLY");
        _;
    }
    modifier onlyTrading(){
        require(msg.sender == storageT.trading(), "TRADING_ONLY");
        _;
    }
    modifier onlyCallbacks(){
        require(msg.sender == storageT.callbacks(), "CALLBACKS_ONLY");
        _;
    }

    // MANAGE PARAMETERS
    function updateAllyFeeP(uint value) external onlyGov{
        require(value <= 50, "VALUE_ABOVE_50");

        allyFeeP = value;

        emit UpdatedAllyFeeP(value);
    }
    function updateStartReferrerFeeP(uint value) external onlyGov{
        require(value <= 100, "VALUE_ABOVE_100");

        startReferrerFeeP = value;

        emit UpdatedStartReferrerFeeP(value);
    }
    function updateOpenFeeP(uint value) external onlyGov{
        require(value <= 50, "VALUE_ABOVE_50");

        openFeeP = value;

        emit UpdatedOpenFeeP(value);
    }
    function updateTargetVolumeDai(uint value) external onlyGov{
        require(value > 0, "VALUE_0");

        targetVolumeDai = value;

        emit UpdatedTargetVolumeDai(value);
    }

    // MANAGE ALLIES
    function whitelistAlly(address ally) external onlyGov{
        require(ally != address(0), "ADDRESS_0");

        AllyDetails storage a = allyDetails[ally];
        require(!a.active, "ALLY_ALREADY_ACTIVE");

        a.active = true;

        emit AllyWhitelisted(ally);
    }
    function unwhitelistAlly(address ally) external onlyGov{
        AllyDetails storage a = allyDetails[ally];
        require(a.active, "ALREADY_UNACTIVE");

        a.active = false;

        emit AllyUnwhitelisted(ally);
    }

    // MANAGE REFERRERS
    function whitelistReferrer(
        address referrer,
        address ally
    ) external onlyGov{

        require(referrer != address(0), "ADDRESS_0");

        ReferrerDetails storage r = referrerDetails[referrer];
        require(!r.active, "REFERRER_ALREADY_ACTIVE");

        r.active = true;

        if(ally != address(0)){
            AllyDetails storage a = allyDetails[ally];
            require(a.active, "ALLY_NOT_ACTIVE");

            r.ally = ally;
            a.referrersReferred.push(referrer);
        }

        emit ReferrerWhitelisted(referrer, ally);
    }
    function unwhitelistReferrer(address referrer) external onlyGov{
        ReferrerDetails storage r = referrerDetails[referrer];
        require(r.active, "ALREADY_UNACTIVE");

        r.active = false;

        emit ReferrerUnwhitelisted(referrer);
    }

    function registerPotentialReferrer(
        address trader,
        address referrer
    ) external onlyTrading{

        ReferrerDetails storage r = referrerDetails[referrer];

        if(referrerByTrader[trader] != address(0)
        || referrer == address(0)
            || !r.active){
            return;
        }

        referrerByTrader[trader] = referrer;
        r.tradersReferred.push(trader);

        emit ReferrerRegistered(trader, referrer);
    }

    // REWARDS DISTRIBUTION
    function distributePotentialReward(
        address trader,
        uint volumeDai,
        uint pairOpenFeeP,
        uint tokenPriceDai
    ) external onlyCallbacks returns(uint){

        address referrer = referrerByTrader[trader];
        ReferrerDetails storage r = referrerDetails[referrer];

        if(!r.active){
            return 0;
        }

        uint referrerRewardValueDai = volumeDai * getReferrerFeeP(
            pairOpenFeeP,
            r.volumeReferredDai
        ) / PRECISION / 100;

        uint referrerRewardToken = referrerRewardValueDai * PRECISION / tokenPriceDai;

        storageT.handleTokens(address(this), referrerRewardToken, true);

        AllyDetails storage a = allyDetails[r.ally];

        uint allyRewardValueDai;
        uint allyRewardToken;

        if(a.active){
            allyRewardValueDai = referrerRewardValueDai * allyFeeP / 100;
            allyRewardToken = referrerRewardToken * allyFeeP / 100;

            a.volumeReferredDai += volumeDai;
            a.pendingRewardsToken += allyRewardToken;
            a.totalRewardsToken += allyRewardToken;
            a.totalRewardsValueDai += allyRewardValueDai;

            referrerRewardValueDai -= allyRewardValueDai;
            referrerRewardToken -= allyRewardToken;

            emit AllyRewardDistributed(
                r.ally,
                trader,
                volumeDai,
                allyRewardToken,
                allyRewardValueDai
            );
        }

        r.volumeReferredDai += volumeDai;
        r.pendingRewardsToken += referrerRewardToken;
        r.totalRewardsToken += referrerRewardToken;
        r.totalRewardsValueDai += referrerRewardValueDai;

        emit ReferrerRewardDistributed(
            referrer,
            trader,
            volumeDai,
            referrerRewardToken,
            referrerRewardValueDai
        );

        return referrerRewardValueDai + allyRewardValueDai;
    }

    // REWARDS CLAIMING
    function claimAllyRewards() external{
        AllyDetails storage a = allyDetails[msg.sender];
        uint rewardsToken = a.pendingRewardsToken;

        require(rewardsToken > 0, "NO_PENDING_REWARDS");

        a.pendingRewardsToken = 0;
        storageT.token().transfer(msg.sender, rewardsToken);

        emit AllyRewardsClaimed(msg.sender, rewardsToken);
    }
    function claimReferrerRewards() external{
        ReferrerDetails storage r = referrerDetails[msg.sender];
        uint rewardsToken = r.pendingRewardsToken;

        require(rewardsToken > 0, "NO_PENDING_REWARDS");

        r.pendingRewardsToken = 0;
        storageT.token().transfer(msg.sender, rewardsToken);

        emit ReferrerRewardsClaimed(msg.sender, rewardsToken);
    }

    // VIEW FUNCTIONS
    function getReferrerFeeP(
        uint pairOpenFeeP,
        uint volumeReferredDai
    ) public view returns(uint){

        uint maxReferrerFeeP = pairOpenFeeP * 2 * openFeeP / 100;
        uint minFeeP = maxReferrerFeeP * startReferrerFeeP / 100;

        uint feeP = minFeeP + (maxReferrerFeeP - minFeeP)
        * volumeReferredDai / 1e18 / targetVolumeDai;

        return feeP > maxReferrerFeeP ? maxReferrerFeeP : feeP;
    }

    function getPercentOfOpenFeeP(
        address trader
    ) external view returns(uint){
        return getPercentOfOpenFeeP_calc(referrerDetails[referrerByTrader[trader]].volumeReferredDai);
    }

    function getPercentOfOpenFeeP_calc(
        uint volumeReferredDai
    ) public view returns(uint resultP){
        resultP = (openFeeP * (
        startReferrerFeeP * PRECISION +
        volumeReferredDai * PRECISION * (100 - startReferrerFeeP) / 1e18 / targetVolumeDai)
        ) / 100;

        resultP = resultP > openFeeP * PRECISION ?
        openFeeP * PRECISION :
        resultP;
    }

    function getTraderReferrer(
        address trader
    ) external view returns(address){
        address referrer = referrerByTrader[trader];

        return referrerDetails[referrer].active ? referrer : address(0);
    }
    function getReferrersReferred(
        address ally
    ) external view returns (address[] memory){
        return allyDetails[ally].referrersReferred;
    }
    function getTradersReferred(
        address referred
    ) external view returns (address[] memory){
        return referrerDetails[referred].tradersReferred;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface AggregatorInterfaceV5{
    enum OrderType { MARKET_OPEN, MARKET_CLOSE, LIMIT_OPEN, LIMIT_CLOSE }
    function getPrice(uint,OrderType,uint) external returns(uint);
    function tokenPriceDai() external view returns(uint);
    function pairMinOpenLimitSlippageP(uint) external view returns(uint);
    function closeFeeP(uint) external view returns(uint);
    function linkFee(uint,uint) external view returns(uint);
    function openFeeP(uint) external view returns(uint);
    function pairMinLeverage(uint) external view returns(uint);
    function pairMaxLeverage(uint) external view returns(uint);
    function pairsCount() external view returns(uint);
    function tokenDaiReservesLp() external view returns(uint, uint);
    function referralP(uint) external view returns(uint);
    function nftLimitOrderFeeP(uint) external view returns(uint);
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

interface GNSStakingInterfaceV6_2{
    function distributeRewardDai(uint amount) external;
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