// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./ownable.sol";

contract tideStorage is Ownable  {
 
    // Enums
    enum LimitOrder { TP, SL, LIQ, OPEN }

    // Structs
    struct Trader{
        uint leverageUnlocked;
        address referral;
        uint referralRewardsTotal;  // 1e18
    }
    struct Trade{
        address trader;
        uint pairIndex;
        uint index;
        uint positionSizeDai;       // 1e18
        uint openPrice;             // PRECISION
        bool buy;
        uint leverage;
        uint tp;                    // PRECISION
        uint sl;                    // PRECISION
        
    }

    struct TradeInfo{
        address borrowToken;
        uint borrowAmount;
        address positionToken;
        uint positionAmount;
        uint openTime;
        uint tpLastUpdated;
        uint slLastUpdated;
        uint liq;
    }

    struct OpenLimitOrder{
        address trader;
        uint pairIndex;
        uint index;
        uint positionSize;          // 1e18 (DAI or GFARM2)
        bool buy;
        uint leverage;
        uint tp;                    // PRECISION (%)
        uint sl;                    // PRECISION (%)
        uint minPrice;              // PRECISION
        uint maxPrice;              // PRECISION
        uint block;
        uint openTime;
        uint tokenId;               // index in supportedTokens
    }

    // List of allowed contracts => can update storage + mint/burn tokens

    uint public maxTradesPerPair = 3;
    uint public maxSlP = 80;                             // %


    // User info mapping
    mapping(address => Trader) public traders;

    // Trades mappings
    mapping(address => mapping(uint => mapping(uint => Trade))) public openTrades;
    mapping(address => mapping(uint => mapping(uint => TradeInfo))) public openTradesInfo;
    mapping(address => mapping(uint => uint)) public openTradesCount;

    // Limit orders mappings
    mapping(address => mapping(uint => mapping(uint => uint))) public openLimitOrderIds;
    mapping(address => mapping(uint => uint)) public openLimitOrdersCount;
    OpenLimitOrder[] public openLimitOrders;

    // Restrictions & Timelocks
    mapping(uint => uint) public tradesPerBlock;
    mapping(address => bool) public isTradingContract;
    
    modifier onlyTrading(){ require(isTradingContract[msg.sender]); _; }

    function addTradingContract(address _trading) external onlyOwner{
        require(_trading != address(0));
        isTradingContract[_trading] = true;
    }
    function removeTradingContract(address _trading) external onlyOwner{
        require(_trading != address(0));
        isTradingContract[_trading] = false;
    }

    function setMaxTradesPerPair(uint _maxTradesPerPair) external onlyOwner {
        require(_maxTradesPerPair > 0);
        maxTradesPerPair = _maxTradesPerPair;
    } 

    // Manage stored trades
    function storeTrade(Trade memory _trade, TradeInfo memory _tradeInfo) external onlyTrading{
        _trade.index = firstEmptyTradeIndex(_trade.trader, _trade.pairIndex);
        openTrades[_trade.trader][_trade.pairIndex][_trade.index] = _trade;
        openTradesInfo[_trade.trader][_trade.pairIndex][_trade.index] = _tradeInfo;
        openTradesCount[_trade.trader][_trade.pairIndex]++;
    }

    function unregisterTrade(address trader, uint pairIndex, uint index)  external onlyTrading  {
        Trade storage t = openTrades[trader][pairIndex][index];
        if(t.leverage == 0){ return; }
        delete openTrades[trader][pairIndex][index];
        delete openTradesInfo[trader][pairIndex][index];
        openTradesCount[trader][pairIndex]--;
    }

    // Manage open limit orders
    function storeOpenLimitOrder(OpenLimitOrder memory o)  external onlyTrading {
        o.index = firstEmptyOpenLimitIndex(o.trader, o.pairIndex);
        o.block = block.number;
        o.openTime = block.timestamp;
        openLimitOrders.push(o);
        openLimitOrderIds[o.trader][o.pairIndex][o.index] = openLimitOrders.length-1;
        openLimitOrdersCount[o.trader][o.pairIndex]++;
    }
    function updateOpenLimitOrder(OpenLimitOrder calldata _o)  external onlyTrading  {
        if(!hasOpenLimitOrder(_o.trader, _o.pairIndex, _o.index)){ return; }
        OpenLimitOrder storage o = openLimitOrders[openLimitOrderIds[_o.trader][_o.pairIndex][_o.index]];
        o.positionSize = _o.positionSize;
        o.buy = _o.buy;
        o.leverage = _o.leverage;
        o.tp = _o.tp;
        o.sl = _o.sl;
        o.minPrice = _o.minPrice;
        o.maxPrice = _o.maxPrice;
        o.block = block.number;
    }
    function unregisterOpenLimitOrder(address _trader, uint _pairIndex, uint _index)  external onlyTrading{
        if(!hasOpenLimitOrder(_trader, _pairIndex, _index)){ return; }

        // Copy last order to deleted order => update id of this limit order
        uint id = openLimitOrderIds[_trader][_pairIndex][_index];
        openLimitOrders[id] = openLimitOrders[openLimitOrders.length-1];
        openLimitOrderIds[openLimitOrders[id].trader][openLimitOrders[id].pairIndex][openLimitOrders[id].index] = id;

        // Remove
        delete openLimitOrderIds[_trader][_pairIndex][_index];
        openLimitOrders.pop();

        openLimitOrdersCount[_trader][_pairIndex]--;
    }

    // View utils functions
    function firstEmptyTradeIndex(address trader, uint pairIndex) public view returns(uint index){
        for(uint i = 0; i < maxTradesPerPair; i++){
            if(openTrades[trader][pairIndex][i].leverage == 0){ index = i; break; }
        }
    }
    function firstEmptyOpenLimitIndex(address trader, uint pairIndex) public view returns(uint index){
        for(uint i = 0; i < maxTradesPerPair; i++){
            if(!hasOpenLimitOrder(trader, pairIndex, i)){ index = i; break; }
        }
    }
    function hasOpenLimitOrder(address trader, uint pairIndex, uint index) public view returns(bool){
        if(openLimitOrders.length == 0){ return false; }
        OpenLimitOrder storage o = openLimitOrders[openLimitOrderIds[trader][pairIndex][index]];
        return o.trader == trader && o.pairIndex == pairIndex && o.index == index;
    }
    // Manage open trade
    function updateSl(address _trader, uint _pairIndex, uint _index, uint _newSl)  external onlyTrading  {
        Trade storage t = openTrades[_trader][_pairIndex][_index];
        TradeInfo storage i = openTradesInfo[_trader][_pairIndex][_index];
        if(t.leverage == 0){ return; }
        t.sl = _newSl;
        i.slLastUpdated = block.number;
    }
    function updateTp(address _trader, uint _pairIndex, uint _index, uint _newTp)  external onlyTrading {
        Trade storage t = openTrades[_trader][_pairIndex][_index];
        TradeInfo storage i = openTradesInfo[_trader][_pairIndex][_index];
        if(t.leverage == 0){ return; }
        t.tp = _newTp;
        i.tpLastUpdated = block.number;
    }

    function getOpenLimitOrder(
        address _trader, 
        uint _pairIndex,
        uint _index
    ) external view returns(OpenLimitOrder memory){ 
        require(hasOpenLimitOrder(_trader, _pairIndex, _index));
        return openLimitOrders[openLimitOrderIds[_trader][_pairIndex][_index]]; 
    }
    function getOpenLimitOrders() external view returns(OpenLimitOrder[] memory){ 
        return openLimitOrders; 
    }

}