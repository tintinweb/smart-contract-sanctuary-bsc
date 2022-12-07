// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./safemath.sol";
import "./ownable.sol";
import "./storageinterface.sol";
import "./stakinginterface.sol";



contract tidePosition is Ownable  {
    using SafeMath for uint256;
    
    address public caller;
    struct tidecmd {
        uint cmd;
        address sender;
        uint orderType;
        uint slippageP;
        tideStorage.Trade  t;
    }

    tideStorage public storageI;
    Staking public stakingI;

    event MarketOrderInitiated(
        uint indexed orderId,
        address indexed trader,
        uint indexed pairIndex,
        bool open
    );
    event swapinit(
        uint amountIn,
        uint amountOut,
        address path1,
        address path2
    );

    event MarketOrderClosed(
        uint indexed orderId,
        address indexed trader,
        uint indexed pairIndex,
        uint closeMode,
        uint closePrice,
        uint lendingFee,
        uint pnl
    );

    event OpenLimitPlaced(
        address indexed trader,
        uint indexed pairIndex,
        uint index
    );
    event OpenLimitUpdated(
        address indexed trader,
        uint indexed pairIndex,
        uint index,
        uint newPrice,
        uint newTp,
        uint newSl
    );
    event OpenLimitExecuted(
        address indexed trader,
        uint indexed pairIndex,
        uint index
    );
    event OpenLimitCanceled(
        address indexed trader,
        uint indexed pairIndex,
        uint index,
        uint lendingFee,
        uint returnDai
    );

    event TpUpdated(
        address indexed trader,
        uint indexed pairIndex,
        uint index,
        uint newTp
    );
    event SlUpdated(
        address indexed trader,
        uint indexed pairIndex,
        uint index,
        uint newSl
    );
    event SlUpdateInitiated(
        uint indexed orderId,
        address indexed trader,
        uint indexed pairIndex,
        uint index,
        uint newSl
    );

    // Params (adjustable)
    uint public maxPosDai=1e18;            // 1e18 (eg. 75000 * 1e18)
    uint public limitOrdersTimelock = 5    ;  // block (eg. 30)
    // Params (constant)
    uint constant liqDiff = 0;
    uint constant PRECISION = 1e10;
    //uint constant MAX_SL_P = 75;  // -75% PNL
    uint public positionFee = 35; // milipercent 0.1%
    uint public executorFee = 10000000000000000; // 0.05 bnb
    
    mapping(address => bool) public isCallerContract;

    modifier onlyCaller(){ require(isCallerContract[msg.sender]); _; }

    function addCallerContract(address _caller) external onlyOwner{
        require(_caller != address(0));
        isCallerContract[_caller] = true;
    }

    constructor (address _storage,address _staking)  {
        storageI = tideStorage(_storage);
        stakingI = Staking(_staking);
    }
    function setExternal(address _storage,address _staking) external {
        storageI = tideStorage(_storage);
        stakingI = Staking(_staking);
    }

    function setPositionFee( uint _fee) onlyOwner external {
        positionFee = _fee;
    }
    function setExecutorFee( uint _fee) onlyOwner external {
        executorFee = _fee;
    }

    function setStorage(address _storage) external onlyOwner {
        storageI = tideStorage(_storage);
    }
    function setStaking(address _staking) external onlyOwner {
        stakingI = Staking(_staking);
    }
    function _openTrade(tideStorage.Trade memory t,
        uint orderType,
        uint slippageP, // for market orders only
        address sender
        ) external onlyCaller {
        require(storageI.openTradesCount(sender,t.pairIndex)
            + storageI.openLimitOrdersCount(sender,t.pairIndex)
            < storageI.maxTradesPerPair(), 
            "MAX_TRADES_PER_PAIR");

        require(t.positionSizeDai <= maxPosDai, "ABOVE_MAX_POS");
        //require(t.positionSizeDai * t.leverage>= pairMinLevPosDai(t.pairIndex), "BELOW_MIN_POS");
        /*
        require(t.leverage > 0 && t.leverage >= stakingI.pairMinLeverage(t.pairIndex) 
            && t.leverage <= stakingI.pairMaxLeverage(t.pairIndex), 
            "LEVERAGE_INCORRECT");
        */
        require(t.tp == 0 || (t.buy ?
                t.tp > t.openPrice :
                t.tp < t.openPrice), "WRONG_TP");

        require(t.sl == 0 || (t.buy ?
                t.sl < t.openPrice :
                t.sl > t.openPrice), "WRONG_SL");


        uint fee = t.positionSizeDai.mul(positionFee).div(10000);

        stakingI.addAdminFee(fee);
        
        if(orderType != 0){
            uint index = storageI.firstEmptyOpenLimitIndex(sender, t.pairIndex);

            address borrowToken = t.buy?stakingI.quoteToken():(stakingI.pairInfos(t.pairIndex)).base;
            uint borrowAmount = t.buy?(t.positionSizeDai).mul(t.leverage):(t.positionSizeDai).mul(t.leverage).mul(stakingI.quteTokenDecimals()).div(t.openPrice);
            //stakingI.addTotalLocked(borrowToken,borrowAmount);

            storageI.storeOpenLimitOrder(
                tideStorage.OpenLimitOrder(
                    sender,
                    t.pairIndex,
                    index,
                    t.positionSizeDai,
                    t.buy,
                    t.leverage,
                    t.tp,
                    t.sl,
                    t.openPrice,
                    t.openPrice,
                    block.number,
                    block.timestamp,
                    0
                )
            );
            emit OpenLimitPlaced(
                sender,
                t.pairIndex,
                index
            );

        }else{
            
            uint index = storageI.firstEmptyTradeIndex(sender, t.pairIndex);
            
            tideStorage.TradeInfo memory ti=tideStorage.TradeInfo(
                        address(0),
                        0,
                        address(0),
                        0,
                        block.timestamp,    //open time
                        0,    //tp update time
                        0,     //sl update time
                        0
                    );

            tideStorage.Trade memory newt=tideStorage.Trade(
                        sender,
                        t.pairIndex,
                        index,
                        t.positionSizeDai,
                        0, 
                        t.buy,
                        t.leverage,
                        t.tp,
                        t.sl,
                        0
                    );
            uint256[] memory amountsOut;
            address[] memory path = new address[](2);

            ti.borrowAmount = (t.positionSizeDai).mul(t.leverage);
            ti.positionAmount = (t.positionSizeDai).mul(t.leverage);
            newt.openPrice = stakingI.quteTokenDecimals(); 


            if (t.buy){
                ti.borrowToken = stakingI.quoteToken();
                ti.positionToken = (stakingI.pairInfos(t.pairIndex)).base;

                path[0]=ti.borrowToken;
                path[1]=ti.positionToken;
                
                amountsOut = stakingI.getAmountsOut(ti.borrowAmount, path);
                
                //uint slip = 1000-slippageP;
                //amountsOut = stakingI.swapExactTokensForTokens(ti.borrowAmount,amountsOut[1].mul(slip).div(1000),path);
                ti.positionAmount = amountsOut[amountsOut.length-1];
                
                newt.openPrice = (newt.openPrice).mul(amountsOut[0]).div(amountsOut[1]);
                ti.liq = (newt.openPrice).mul(newt.leverage-1).div(newt.leverage).mul(100+liqDiff).div(100);

            }else{
                ti.borrowToken = (stakingI.pairInfos(t.pairIndex)).base;
                ti.positionToken = stakingI.quoteToken();

                path[0]=ti.borrowToken;
                path[1]=ti.positionToken;
                amountsOut = stakingI.getAmountsIn(ti.positionAmount, path);
                uint slip = 1000+slippageP;
                //amountsOut = stakingI.swapTokensForExactTokens(ti.positionAmount,amountsOut[0].mul(slip).div(1000),path);

                ti.borrowAmount = amountsOut[0];
                newt.openPrice = (newt.openPrice).mul(amountsOut[1]).div(amountsOut[0]);
                ti.liq = (newt.openPrice).mul(newt.leverage+1).div(newt.leverage).mul(100-liqDiff).div(100);
            }

            //stakingI.addTotalLocked(ti.borrowToken,ti.borrowAmount);
            
            storageI.storeTrade(newt,ti);
            emit MarketOrderInitiated(
                index,
                sender,
                t.pairIndex,
                true
            );
        }

    }
    function _updateSl(
        uint pairIndex,
        uint index,
        uint newSl,
        address sender
    ) external onlyCaller {

        tideStorage.Trade memory t = storageI.openTrades(sender,pairIndex,index);
        tideStorage.TradeInfo memory i = storageI.openTradesInfo(sender,pairIndex,index);

        require(t.leverage > 0, "NO_TRADE");

        //uint maxSlDist = t.openPrice * MAX_SL_P / 100 / t.leverage;

                
        /*require(newSl == 0 || (t.buy ? 
            newSl >= t.openPrice - maxSlDist :
            newSl <= t.openPrice + maxSlDist), "SL_TOO_BIG");*/
        
        require(block.timestamp - i.slLastUpdated >= limitOrdersTimelock,
            "LIMIT_TIMELOCK");

        storageI.updateSl(sender, pairIndex, index, newSl);

        emit SlUpdated(
            sender,
            pairIndex,
            index,
            newSl
        );
    }
    function _updateTp(
        uint pairIndex,
        uint index,
        uint newTp,
        address sender
    ) external onlyCaller {
        tideStorage.Trade memory t = storageI.openTrades(sender,pairIndex,index);
        tideStorage.TradeInfo memory i = storageI.openTradesInfo(sender,pairIndex,index);

        require(t.leverage > 0, "NO_TRADE");
        require(block.timestamp - i.tpLastUpdated >= limitOrdersTimelock,
            "LIMIT_TIMELOCK");

        storageI.updateTp(sender, pairIndex, index, newTp);

        emit TpUpdated(
            sender,
            pairIndex,
            index,
            newTp
        );

    }

    function _closeTradeByUser(
        uint pairIndex,
        uint index,
        uint slippageP,
        address sender
    )  external onlyCaller {
        closeTrade(sender,pairIndex,index,0,slippageP);
    }

    function closeTradeByPrice(
        address trader,
        uint pairIndex,
        uint index,
        uint mode //0 by user, 1 by sl,2 by tp, 3 by liq
    )  onlyExecutor external {
        TransferHelper.safeTransferETH(msg.sender, executorFee);
        closeTrade(trader,pairIndex,index,mode,300);
    }

    function closeTrade(
        address trader,
        uint pairIndex,
        uint index,
        uint mode, //0 by user, 1 by sl,2 by tp, 3 by liq
        uint slippageP
    )  internal {
        
        address sender = trader;

        tideStorage.Trade memory t = storageI.openTrades(sender,pairIndex,index);
        tideStorage.TradeInfo memory i = storageI.openTradesInfo(sender,pairIndex,index);
        require(t.leverage > 0, "NO_TRADE");


        // release locked
        //stakingI.removeTotalLocked(i.borrowToken,i.borrowAmount);

        //distribute lending fee
        uint lendingfee = (stakingI.lendingFees(stakingI.quoteToken())).mul(i.borrowToken==stakingI.quoteToken()?i.borrowAmount:i.positionAmount);
        lendingfee = lendingfee.mul(block.timestamp - i.openTime);
        lendingfee = lendingfee.div(3600).div(stakingI.lendingFeesDecimas()).div(100);
        stakingI.distribute(lendingfee,stakingI.quoteToken());

        // swap to original coins , calc pnl
        uint256[] memory amountsOut;
        address[] memory path = new address[](2);
        path[0] = i.positionToken;
        path[1] = i.borrowToken;
        uint slip = 1000+slippageP;
        int pnl = int(t.positionSizeDai);
        uint closePrice = stakingI.quteTokenDecimals();
        
        if (t.buy){
            slip = 1000-slippageP;
            amountsOut = stakingI.getAmountsOut(i.positionAmount, path);
            //amountsOut = stakingI.swapExactTokensForTokens(i.positionAmount,amountsOut[1].mul(slip).div(1000),path);
            pnl = pnl + int(amountsOut[1])-int(i.borrowAmount);
            closePrice = closePrice.mul(amountsOut[1]).div(amountsOut[0]);
            
        }else{
            amountsOut = stakingI.getAmountsIn(i.borrowAmount, path);
            //amountsOut = stakingI.swapTokensForExactTokens(i.borrowAmount,amountsOut[0].mul(slip).div(1000),path);
            pnl = pnl + int(amountsOut[0])-int(i.borrowAmount);
            closePrice = closePrice.mul(amountsOut[0]).div(amountsOut[1]);
        }
        pnl = pnl -int(lendingfee);
        if(mode<3 &&  pnl>0){ //if close by liq, dont send remain
            stakingI.sendProfit(t.trader,uint(pnl));
        }
        
        storageI.unregisterTrade(sender,pairIndex,index);
        // emit event close trade
        emit MarketOrderClosed(
            index,
            sender,
            pairIndex,
            mode,
            closePrice,
            lendingfee,
            uint(pnl)
        );
    }

    function _cancelOrder(
        uint pairIndex,
        uint index,
        address sender
    )  external onlyCaller {
        require(storageI.hasOpenLimitOrder(sender, pairIndex, index),
            "NO_LIMIT");

        tideStorage.OpenLimitOrder memory o = storageI.getOpenLimitOrder(
            sender, pairIndex, index
        );

        require(block.number - o.block >= limitOrdersTimelock, "LIMIT_TIMELOCK");


        // release locked
        address borrowToken = o.buy?stakingI.quoteToken():(stakingI.pairInfos(o.pairIndex)).base;
        uint borrowAmount = o.buy?(o.positionSize).mul(o.leverage):(o.positionSize).mul(o.leverage).mul(stakingI.quteTokenDecimals()).div(o.minPrice);
        uint positionAmount = o.buy?(o.positionSize).mul(o.leverage).mul(stakingI.quteTokenDecimals()).div(o.minPrice):(o.positionSize).mul(o.leverage);
        //stakingI.removeTotalLocked(borrowToken,borrowAmount);

        uint lendingfee = (stakingI.lendingFees(stakingI.quoteToken())).mul(borrowToken==stakingI.quoteToken()?borrowAmount:positionAmount);
        lendingfee = lendingfee.mul(block.timestamp - o.openTime);
        lendingfee = lendingfee.div(3600).div(stakingI.lendingFeesDecimas()).div(100);

        if(o.positionSize<lendingfee) {
            lendingfee = o.positionSize;
        }
        stakingI.distribute(lendingfee,stakingI.quoteToken());
        //
        uint pnl = o.positionSize;
        pnl = pnl.sub(lendingfee);
        if(pnl>0){
            stakingI.sendProfit(o.trader,pnl);
        }

        storageI.unregisterOpenLimitOrder(sender, pairIndex, index);
        
        emit OpenLimitCanceled(
            sender,
            pairIndex,
            index,
            lendingfee,
            pnl
        );

    }

    function executeLimit(address _trader, uint _pairIndex,uint _index,uint slippageP) external  onlyExecutor {
        TransferHelper.safeTransferETH(msg.sender, executorFee);

        require(storageI.hasOpenLimitOrder(_trader, _pairIndex, _index),
            "NO_LIMIT");

        tideStorage.OpenLimitOrder memory o = storageI.getOpenLimitOrder(
            _trader, _pairIndex, _index
        );


        //release lock ,distribute lending fee
        address borrowToken = o.buy?stakingI.quoteToken():(stakingI.pairInfos(o.pairIndex)).base;
        uint borrowAmount = o.buy?(o.positionSize).mul(o.leverage):(o.positionSize).mul(o.leverage).mul(stakingI.quteTokenDecimals()).div(o.minPrice);
        //stakingI.removeTotalLocked(borrowToken,borrowAmount);
        
        uint lendingfee = (stakingI.lendingFees(stakingI.quoteToken())).mul((o.positionSize).mul(o.leverage));
        lendingfee = lendingfee.mul(block.timestamp - o.openTime);
        lendingfee = lendingfee.div(3600).div(stakingI.lendingFeesDecimas()).div(100);


        if(o.positionSize<lendingfee) {
            stakingI.distribute(o.positionSize,stakingI.quoteToken()); 
        }else{
            stakingI.distribute(lendingfee,stakingI.quoteToken()); 
            o.positionSize = o.positionSize.sub(lendingfee);
            uint index = storageI.firstEmptyTradeIndex(_trader, o.pairIndex);
            tideStorage.TradeInfo memory ti=tideStorage.TradeInfo(
                        address(0),
                        0,
                        address(0),
                        0,
                        block.timestamp,    //open time
                        block.timestamp,    //tp update time
                        block.timestamp,     //sl update time
                        0
                    );
            tideStorage.Trade memory t = tideStorage.Trade(
                        o.trader,
                        o.pairIndex,
                        index,
                        o.positionSize,
                        0, 
                        o.buy,
                        o.leverage,
                        o.tp,
                        o.sl,
                        0
                    );
            uint256[] memory amountsOut;
            address[] memory path = new address[](2);

            ti.borrowAmount = (o.positionSize).mul(o.leverage);
            ti.positionAmount = (o.positionSize).mul(o.leverage);
            t.openPrice = stakingI.quteTokenDecimals();
            if (o.buy){
                ti.borrowToken = stakingI.quoteToken();
                ti.positionToken = (stakingI.pairInfos(o.pairIndex)).base;
                path[0]=ti.borrowToken;
                path[1]=ti.positionToken;
                amountsOut = stakingI.getAmountsOut(ti.borrowAmount, path);
                //amountsOut = stakingI.swapExactTokensForTokens(ti.borrowAmount,amountsOut[1].mul(1000-slippageP).div(1000),path);
                ti.positionAmount = amountsOut[amountsOut.length-1];
                t.openPrice = (t.openPrice).mul(amountsOut[0]).div(amountsOut[1]);
                ti.liq=(t.openPrice).mul(t.leverage-1).div(t.leverage).mul(100+liqDiff).div(100);
            }else{
                ti.borrowToken = (stakingI.pairInfos(o.pairIndex)).base;
                ti.positionToken = stakingI.quoteToken();
                path[0]=ti.borrowToken;
                path[1]=ti.positionToken;
                amountsOut = stakingI.getAmountsIn(ti.positionAmount, path);
                //amountsOut = stakingI.swapTokensForExactTokens(ti.positionAmount,amountsOut[0].mul(1000+slippageP).div(1000),path);
                ti.borrowAmount = amountsOut[0];
                t.openPrice = (t.openPrice).mul(amountsOut[0]).div(amountsOut[1]);
                ti.liq=(t.openPrice).mul(t.leverage+1).div(t.leverage).mul(100-liqDiff).div(100);
            }
            //stakingI.addTotalLocked(ti.borrowToken,ti.borrowAmount);
            
            storageI.storeTrade(t,ti);
            emit MarketOrderInitiated(
                index,
                _trader,
                _pairIndex,
                true
            );     
       }
        storageI.unregisterOpenLimitOrder(_trader, _pairIndex, _index);
        
        emit OpenLimitExecuted(
            _trader,
            _pairIndex,
            _index
        );
                
    }

    function payout () public onlyOwner returns(bool res) {

        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
        return true;
    }   
    // allow this contract to receive ether
    receive() external payable {}
}