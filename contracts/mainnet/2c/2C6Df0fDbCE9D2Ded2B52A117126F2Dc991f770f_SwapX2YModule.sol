// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './interfaces/IiZiSwapPool.sol';
import './libraries/Liquidity.sol';
import './libraries/Point.sol';
import './libraries/PointBitmap.sol';
import './libraries/LogPowMath.sol';
import './libraries/MulDivMath.sol';
import './libraries/TwoPower.sol';
import './libraries/LimitOrder.sol';
import './libraries/SwapMathY2X.sol';
import './libraries/SwapMathX2Y.sol';
import './libraries/SwapMathY2XDesire.sol';
import './libraries/SwapMathX2YDesire.sol';
import './libraries/TokenTransfer.sol';
import './libraries/UserEarn.sol';
import './libraries/State.sol';
import './libraries/Oracle.sol';
import './libraries/OrderOrEndpoint.sol';
import './libraries/MaxMinMath.sol';
import './interfaces/IiZiSwapCallback.sol';
import './libraries/SwapCache.sol';

contract SwapX2YModule {

    using Liquidity for mapping(bytes32 =>Liquidity.Data);
    using Liquidity for Liquidity.Data;
    using Point for mapping(int24 =>Point.Data);
    using Point for Point.Data;
    using PointBitmap for mapping(int16 =>uint256);
    using LimitOrder for LimitOrder.Data;
    using UserEarn for UserEarn.Data;
    using UserEarn for mapping(bytes32 =>UserEarn.Data);
    using SwapMathY2X for SwapMathY2X.RangeRetState;
    using SwapMathX2Y for SwapMathX2Y.RangeRetState;
    using Oracle for Oracle.Observation[65535];
    using OrderOrEndpoint for mapping(int24 =>int24);

    int24 internal constant LEFT_MOST_PT = -800000;
    int24 internal constant RIGHT_MOST_PT = 800000;

    /// @notice left most point regularized by pointDelta
    int24 public leftMostPt;
    /// @notice right most point regularized by pointDelta
    int24 public rightMostPt;
    /// @notice maximum liquidSum for each point, see points() in IiZiSwapPool or library Point
    uint128 public maxLiquidPt;

    /// @notice address of iZiSwapFactory
    address public factory;

    /// @notice address of tokenX
    address public tokenX;
    /// @notice address of tokenY
    address public tokenY;
    /// @notice fee amount of this swap pool, 3000 means 0.3%
    uint24 public fee;

    /// @notice minimum number of distance between initialized or limitorder points 
    int24 public pointDelta;

    /// @notice the fee growth as a 128-bit fixpoing fees of tokenX collected per 1 liquidity of the pool
    uint256 public feeScaleX_128;
    /// @notice the fee growth as a 128-bit fixpoing fees of tokenY collected per 1 liquidity of the pool
    uint256 public feeScaleY_128;

    uint160 sqrtRate_96;

    /// @notice some values of pool
    /// see library State or IiZiSwapPool#state for more infomation
    State public state;

    /// @notice the information about a liquidity by the liquidity's key
    mapping(bytes32 =>Liquidity.Data) public liquidities;

    /// @notice 256 packed point (orderOrEndpoint>0) boolean values. See PointBitmap for more information
    mapping(int16 =>uint256) public pointBitmap;

    /// @notice returns infomation of a point in the pool, see Point library of IiZiSwapPool#poitns for more information
    mapping(int24 =>Point.Data) public points;
    /// @notice infomation about a point whether has limit order and whether as an liquidity's endpoint
    mapping(int24 =>int24) public orderOrEndpoint;
    /// @notice limitOrder info on a given point
    mapping(int24 =>LimitOrder.Data) public limitOrderData;
    /// @notice information about a user's limit order (sell tokenY and earn tokenX)
    mapping(bytes32 => UserEarn.Data) public userEarnX;
    /// @notice information about a user's limit order (sell tokenX and earn tokenY)
    mapping(bytes32 => UserEarn.Data) public userEarnY;
    /// @notice observation data array
    Oracle.Observation[65535] public observations;
    
    uint256 public totalFeeXCharged;
    uint256 public totalFeeYCharged;

    address private original;

    address private swapModuleX2Y;
    address private swapModuleY2X;
    address private liquidityModule;
    address private limitOrderModule;
    address private flashModule;

    /// @notice percent to charge from miner's fee
    uint24 public immutable feeChargePercent = 50;

    function balanceX() private view returns (uint256) {
        (bool success, bytes memory data) =
            tokenX.staticcall(abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, address(this)));
        require(success && data.length >= 32);
        return abi.decode(data, (uint256));
    }

    function balanceY() private view returns (uint256) {
        (bool success, bytes memory data) =
            tokenY.staticcall(abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, address(this)));
        require(success && data.length >= 32);
        return abi.decode(data, (uint256));
    }

    /// Delegate call implementation for IiZiSwapPool#swapX2Y.
    function swapX2Y(
        address recipient,
        uint128 amount,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY) {
        require(amount > 0, "AP");

        lowPt = MaxMinMath.max(lowPt, leftMostPt);
        amountX = 0;
        amountY = 0;
        State memory st = state;
        SwapCache memory cache;
        cache.currFeeScaleX_128 = feeScaleX_128;
        cache.currFeeScaleY_128 = feeScaleY_128;
        cache.finished = false;
        cache._sqrtRate_96 = sqrtRate_96;
        cache.pointDelta = pointDelta;
        cache.currentOrderOrEndpt = orderOrEndpoint.getOrderOrEndptVal(st.currentPoint, cache.pointDelta);
        cache.startPoint = st.currentPoint;
        cache.startLiquidity = st.liquidity;
        cache.timestamp = uint32(block.timestamp);

        while (lowPt <= st.currentPoint && !cache.finished) {

            // step1: fill limit order 
            if (cache.currentOrderOrEndpt & 2 > 0) {
                // amount <= uint128.max
                uint128 amountNoFee = uint128(uint256(amount) * (1e6 - fee) / 1e6);
                if (amountNoFee > 0) {
                    LimitOrder.Data storage od = limitOrderData[st.currentPoint];
                    uint128 currY = od.sellingY;
                    (uint128 costX, uint128 acquireY) = SwapMathX2Y.x2YAtPrice(
                        amountNoFee, st.sqrtPrice_96, currY
                    );
                    if (acquireY < currY || costX >= amountNoFee) {
                        cache.finished = true;
                    }
                    uint128 feeAmount;
                    if (costX >= amountNoFee) {
                        feeAmount = amount - costX;
                    } else {
                        // costX <= amountX <= uint128.max
                        feeAmount = uint128(uint256(costX) * fee / (1e6 - fee));
                        uint256 mod = uint256(costX) * fee % (1e6 - fee);
                        if (mod > 0) {
                            feeAmount += 1;
                        }
                    }
                    totalFeeXCharged += feeAmount;
                    amount -= (costX + feeAmount);
                    amountX = amountX + costX + feeAmount;
                    amountY += acquireY;
                    currY -= acquireY;
                    od.sellingY = currY;
                    od.earnX += costX;
                    od.accEarnX += costX;
                    if (od.sellingX == 0 && currY == 0) {
                        int24 newVal = cache.currentOrderOrEndpt & 1;
                        orderOrEndpoint.setOrderOrEndptVal(st.currentPoint, cache.pointDelta, newVal);
                        if (newVal == 0) {
                            pointBitmap.setZero(st.currentPoint, cache.pointDelta);
                        }
                    }
                } else {
                    cache.finished = true;
                }
            }
            if (cache.finished) {
                break;
            }
            int24 searchStart = st.currentPoint - 1;

            // step2: clear the liquidity if the currentPoint is an endpoint
            if (cache.currentOrderOrEndpt & 1 > 0) {
                // amount <= uint128.max
                uint128 amountNoFee = uint128(uint256(amount) * (1e6 - fee) / 1e6);
                if (amountNoFee > 0) {
                    if (st.liquidity > 0) {
                        SwapMathX2Y.RangeRetState memory retState = SwapMathX2Y.x2YRange(
                            st,
                            st.currentPoint,
                            cache._sqrtRate_96,
                            amountNoFee
                        );
                        cache.finished = retState.finished;
                        uint128 feeAmount;
                        if (retState.costX >= amountNoFee) {
                            feeAmount = amount - retState.costX;
                        } else {
                            // retState.costX <= amount <= uint128.max
                            feeAmount = uint128(uint256(retState.costX) * fee / (1e6 - fee));
                            uint256 mod = uint256(retState.costX) * fee % (1e6 - fee);
                            if (mod > 0) {
                                feeAmount += 1;
                            }
                        }
                        uint256 chargedFeeAmount = uint256(feeAmount) * feeChargePercent / 100;
                        totalFeeXCharged += chargedFeeAmount;

                        cache.currFeeScaleX_128 = cache.currFeeScaleX_128 + MulDivMath.mulDivFloor(feeAmount - chargedFeeAmount, TwoPower.Pow128, st.liquidity);
                        amountX = amountX + retState.costX + feeAmount;
                        amountY += retState.acquireY;
                        amount -= (retState.costX + feeAmount);
                        st.currentPoint = retState.finalPt;
                        st.sqrtPrice_96 = retState.sqrtFinalPrice_96;
                        st.liquidityX = retState.liquidityX;
                    }
                    if (!cache.finished) {
                        Point.Data storage pointdata = points[st.currentPoint];
                        pointdata.passEndpoint(cache.currFeeScaleX_128, cache.currFeeScaleY_128);
                        st.liquidity = Liquidity.liquidityAddDelta(st.liquidity, - pointdata.liquidDelta);
                        st.currentPoint = st.currentPoint - 1;
                        st.sqrtPrice_96 = LogPowMath.getSqrtPrice(st.currentPoint);
                        st.liquidityX = 0;
                    }
                } else {
                    cache.finished = true;
                }
            }
            if (cache.finished || st.currentPoint < lowPt) {
                break;
            }
            int24 nextPt= pointBitmap.nearestLeftOneOrBoundary(searchStart, cache.pointDelta);
            if (nextPt < lowPt) {
                nextPt = lowPt;
            }
            int24 nextVal = orderOrEndpoint.getOrderOrEndptVal(nextPt, cache.pointDelta);
            
            // in [nextPt, st.currentPoint)
            if (st.liquidity == 0) {
                // no liquidity in the range [nextPt, st.currentPoint]
                st.currentPoint = nextPt;
                st.sqrtPrice_96 = LogPowMath.getSqrtPrice(st.currentPoint);
                // st.liquidityX must be 0
                cache.currentOrderOrEndpt = nextVal;
            } else {
                // amount > 0
                // amountNoFee <= amount <= uint128.max
                uint128 amountNoFee = uint128(uint256(amount) * (1e6 - fee) / 1e6);
                if (amountNoFee > 0) {
                    SwapMathX2Y.RangeRetState memory retState = SwapMathX2Y.x2YRange(
                        st, nextPt, cache._sqrtRate_96, amountNoFee
                    );
                    cache.finished = retState.finished;
                    uint128 feeAmount;
                    if (retState.costX >= amountNoFee) {
                        feeAmount = amount - retState.costX;
                    } else {
                        // feeAmount <= retState.costX <= amount <= uint128.max
                        feeAmount = uint128(uint256(retState.costX) * fee / (1e6 - fee));
                        uint256 mod = uint256(retState.costX) * fee % (1e6 - fee);
                        if (mod > 0) {
                            feeAmount += 1;
                        }
                    }
                    amountY += retState.acquireY;
                    amountX = amountX + retState.costX + feeAmount;
                    amount -= (retState.costX + feeAmount);

                    uint256 chargedFeeAmount = uint256(feeAmount) * feeChargePercent / 100;
                    totalFeeXCharged += chargedFeeAmount;
                    
                    cache.currFeeScaleX_128 = cache.currFeeScaleX_128 + MulDivMath.mulDivFloor(feeAmount - chargedFeeAmount, TwoPower.Pow128, st.liquidity);
                    st.currentPoint = retState.finalPt;
                    st.sqrtPrice_96 = retState.sqrtFinalPrice_96;
                    st.liquidityX = retState.liquidityX;
                } else {
                    cache.finished = true;
                }
                if (st.currentPoint == nextPt) {
                    cache.currentOrderOrEndpt = nextVal;
                } else {
                    // not necessary, because finished must be true
                    cache.currentOrderOrEndpt = 0;
                }
            }
            if (st.currentPoint <= lowPt) {
                break;
            }
        }

        if (cache.startPoint != st.currentPoint) {
            (st.observationCurrentIndex, st.observationQueueLen) = observations.append(
                st.observationCurrentIndex,
                cache.timestamp,
                cache.startPoint,
                st.observationQueueLen,
                st.observationNextQueueLen
            );
        }

        // write back fee scale, no fee of y
        feeScaleX_128 = cache.currFeeScaleX_128;
        // write back state
        state = st;
        require(amountY > 0, "PR");
        // transfer y to trader
        TokenTransfer.transferToken(tokenY, recipient, amountY);
        // trader pay x
        require(amountX > 0, "PP");
        uint256 bx = balanceX();
        IiZiSwapCallback(msg.sender).swapX2YCallback(amountX, amountY, data);
        require(balanceX() >= bx + amountX, "XE");
        
    }
    
    /// Delegate call implementation for IiZiSwapPool#swapX2YDesireY.
    function swapX2YDesireY(
        address recipient,
        uint128 desireY,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY) {
        require(desireY > 0, "AP");

        lowPt = MaxMinMath.max(lowPt, leftMostPt);
        amountX = 0;
        amountY = 0;
        State memory st = state;
        SwapCache memory cache;
        cache.currFeeScaleX_128 = feeScaleX_128;
        cache.currFeeScaleY_128 = feeScaleY_128;
        cache.finished = false;
        cache._sqrtRate_96 = sqrtRate_96;
        cache.pointDelta = pointDelta;
        cache.currentOrderOrEndpt = orderOrEndpoint.getOrderOrEndptVal(st.currentPoint, cache.pointDelta);
        cache.startPoint = st.currentPoint;
        cache.startLiquidity = st.liquidity;
        cache.timestamp = uint32(block.timestamp);
        while (lowPt <= st.currentPoint && !cache.finished) {
            // clear limit order first
            if (cache.currentOrderOrEndpt & 2 > 0) {
                LimitOrder.Data storage od = limitOrderData[st.currentPoint];
                uint128 currY = od.sellingY;
                (uint128 costX, uint128 acquireY) = SwapMathX2YDesire.x2YAtPrice(
                    desireY, st.sqrtPrice_96, currY
                );
                if (acquireY >= desireY) {
                    cache.finished = true;
                }

                uint256 feeAmount = MulDivMath.mulDivCeil(costX, fee, 1e6 - fee);
                totalFeeXCharged += feeAmount;
                desireY = (desireY <= acquireY) ? 0 : desireY - acquireY;
                amountX += (costX + feeAmount);
                amountY += acquireY;
                currY -= acquireY;
                od.sellingY = currY;
                od.earnX += costX;
                od.accEarnX += costX;
                if (od.sellingX == 0 && currY == 0) {
                    int24 newVal = cache.currentOrderOrEndpt & 1;
                    orderOrEndpoint.setOrderOrEndptVal(st.currentPoint, cache.pointDelta, newVal);
                    if (newVal == 0) {
                        pointBitmap.setZero(st.currentPoint, cache.pointDelta);
                    }
                }
            }
            if (cache.finished) {
                break;
            }
            int24 searchStart = st.currentPoint - 1;
            // second, clear the liquid if the currentPoint is an endpoint
            if (cache.currentOrderOrEndpt & 1 > 0) {
                if (st.liquidity > 0) {
                    SwapMathX2YDesire.RangeRetState memory retState = SwapMathX2YDesire.x2YRange(
                        st,
                        st.currentPoint,
                        cache._sqrtRate_96,
                        desireY
                    );
                    cache.finished = retState.finished;
                    
                    uint256 feeAmount = MulDivMath.mulDivCeil(retState.costX, fee, 1e6 - fee);
                    uint256 chargedFeeAmount = feeAmount * feeChargePercent / 100;
                    totalFeeXCharged += chargedFeeAmount;

                    cache.currFeeScaleX_128 = cache.currFeeScaleX_128 + MulDivMath.mulDivFloor(feeAmount - chargedFeeAmount, TwoPower.Pow128, st.liquidity);
                    amountX += (retState.costX + feeAmount);
                    amountY += retState.acquireY;
                    desireY -= MaxMinMath.min(desireY, retState.acquireY);
                    st.currentPoint = retState.finalPt;
                    st.sqrtPrice_96 = retState.sqrtFinalPrice_96;
                    st.liquidityX = retState.liquidityX;
                }
                if (!cache.finished) {
                    Point.Data storage pointdata = points[st.currentPoint];
                    pointdata.passEndpoint(cache.currFeeScaleX_128, cache.currFeeScaleY_128);
                    st.liquidity = Liquidity.liquidityAddDelta(st.liquidity, - pointdata.liquidDelta);
                    st.currentPoint = st.currentPoint - 1;
                    st.sqrtPrice_96 = LogPowMath.getSqrtPrice(st.currentPoint);
                    st.liquidityX = 0;
                }
            }
            if (cache.finished || st.currentPoint < lowPt) {
                break;
            }
            int24 nextPt = pointBitmap.nearestLeftOneOrBoundary(searchStart, cache.pointDelta);
            if (nextPt < lowPt) {
                nextPt = lowPt;
            }
            int24 nextVal = orderOrEndpoint.getOrderOrEndptVal(nextPt, cache.pointDelta);

            // in [nextPt, st.currentPoint)
            if (st.liquidity == 0) {
                // no liquidity in the range [nextPt, st.currentPoint]
                st.currentPoint = nextPt;
                st.sqrtPrice_96 = LogPowMath.getSqrtPrice(st.currentPoint);
                // st.liquidityX must be 0
                cache.currentOrderOrEndpt = nextVal;
            } else {
                // amount > 0
                // if (desireY > 0) {
                    SwapMathX2YDesire.RangeRetState memory retState = SwapMathX2YDesire.x2YRange(
                        st, nextPt, cache._sqrtRate_96, desireY
                    );
                    cache.finished = retState.finished;
                    
                    uint256 feeAmount = MulDivMath.mulDivCeil(retState.costX, fee, 1e6 - fee);
                    uint256 chargedFeeAmount = feeAmount * feeChargePercent / 100;
                    totalFeeXCharged += chargedFeeAmount;
                    
                    amountY += retState.acquireY;
                    amountX += (retState.costX + feeAmount);
                    desireY -= MaxMinMath.min(desireY, retState.acquireY);
                    
                    cache.currFeeScaleX_128 = cache.currFeeScaleX_128 + MulDivMath.mulDivFloor(feeAmount - chargedFeeAmount, TwoPower.Pow128, st.liquidity);

                    st.currentPoint = retState.finalPt;
                    st.sqrtPrice_96 = retState.sqrtFinalPrice_96;
                    st.liquidityX = retState.liquidityX;
                // } else {
                //     cache.finished = true;
                // }
                if (st.currentPoint == nextPt) {
                    cache.currentOrderOrEndpt = nextVal;
                } else {
                    // not necessary, because finished must be true
                    cache.currentOrderOrEndpt = 0;
                }
            }
            if (st.currentPoint <= lowPt) {
                break;
            }
        }
        if (cache.startPoint != st.currentPoint) {
            (st.observationCurrentIndex, st.observationQueueLen) = observations.append(
                st.observationCurrentIndex,
                cache.timestamp,
                cache.startPoint,
                st.observationQueueLen,
                st.observationNextQueueLen
            );
        }

        // write back fee scale, no fee of y
        feeScaleX_128 = cache.currFeeScaleX_128;
        // write back state
        state = st;
        require(amountY > 0, "PR");
        // transfer y to trader
        TokenTransfer.transferToken(tokenY, recipient, amountY);
        // trader pay x
        require(amountX > 0, "PP");
        uint256 bx = balanceX();
        IiZiSwapCallback(msg.sender).swapX2YCallback(amountX, amountY, data);
        require(balanceX() >= bx + amountX, "XE");
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IiZiSwapPool {

    /// @notice Emitted when miner successfully add liquidity (mint)
    /// @param sender the address that minted the liquidity
    /// @param owner the owner who will benefit from this liquidity
    /// @param leftPoint left endpoint of the liquidity
    /// @param rightPoint right endpoint of the liquidity
    /// @param liquidity the amount of liquidity minted to the range [leftPoint, rightPoint)
    /// @param amountX amount of tokenX deposit
    /// @param amountY amount of tokenY deposit
    event Mint(
        address sender, 
        address indexed owner, 
        int24 indexed leftPoint, 
        int24 indexed rightPoint, 
        uint128 liquidity, 
        uint256 amountX, 
        uint256 amountY
    );

    /// @notice Emitted when miner successfully decrease liquidity (withdraw)
    /// @param owner owner address of liquidity
    /// @param leftPoint left endpoint of liquidity
    /// @param rightPoint right endpoint of liquidity
    /// @param liquidity amount of liquidity decreased
    /// @param amountX amount of tokenX withdrawed
    /// @param amountY amount of tokenY withdrawed
    event Burn(
        address indexed owner, 
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when a trader successfully exchange
    /// @param tokenX tokenX of pool
    /// @param tokenY tokenY of pool
    /// @param fee fee amount of pool
    /// @param sellXEarnY true for selling tokenX, false for buying tokenX
    /// @param amountX amount of tokenX in this exchange
    /// @param amountY amount of tokenY in this exchange
    event Swap(
        address indexed tokenX,
        address indexed tokenY,
        uint24 indexed fee,
        bool sellXEarnY,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted by the pool for any flashes of tokenX/tokenY
    /// @param sender the address that initiated the swap call, and that received the callback
    /// @param recipient the address that received the tokens from flash
    /// @param amountX the amount of tokenX that was flashed
    /// @param amountY the amount of tokenY that was flashed
    /// @param paidX the amount of tokenX paid for the flash, which can exceed the amountX plus the fee
    /// @param paidY the amount of tokenY paid for the flash, which can exceed the amountY plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amountX,
        uint256 amountY,
        uint256 paidX,
        uint256 paidY
    );

    /// @notice Emitted when a seller successfully add a limit order
    /// @param amount amount of token to sell the seller added
    /// @param point point of limit order
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event AddLimitOrder(
        uint256 amount,
        int24 point,
        bool sellXEarnY
    );

    /// @notice Emitted when a seller successfully decrease a limit order
    /// @param amount amount of token to sell the seller decreased
    /// @param point point of limit order
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event DecLimitOrder(
        uint256 amount,
        int24 point,
        bool sellXEarnY
    );

    /// @notice Returns the information about a liquidity by the liquidity's key
    /// @param key the liquidity's key is a hash of a preimage composed by the miner(owner), pointLeft and pointRight
    /// @return liquidity the amount of liquidity,
    /// @return lastFeeScaleX_128 fee growth of tokenX inside the range as of the last mint/burn/collect,
    /// @return lastFeeScaleY_128 fee growth of tokenY inside the range as of the last mint/burn/collect,
    /// @return tokenOwedX the computed amount of tokenX miner can collect as of the last mint/burn/collect,
    /// @return tokenOwedY the computed amount of tokenY miner can collect as of the last mint/burn/collect
    function liquidity(bytes32 key)
        external
        view
        returns (
            uint128 liquidity,
            uint256 lastFeeScaleX_128,
            uint256 lastFeeScaleY_128,
            uint256 tokenOwedX,
            uint256 tokenOwedY
        );
    
    /// @notice Returns the information about a user's limit order (sell tokenY and earn tokenX)
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenX earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenY not selled in this limit order
    /// @return sellingDec amount of tokenY decreased by seller from this limit order
    /// @return earn amount of tokenX earned in this limit order not assigned
    /// @return earnAssign assigned amount of tokenX earned in this limit order
    function userEarnX(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 earnAssign
        );
    
    /// @notice Returns the information about a user's limit order (sell tokenX and earn tokenY)
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenY earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenX not selled in this limit order
    /// @return sellingDec amount of tokenX decreased by seller from this limit order
    /// @return earn amount of tokenY earned in this limit order not assigned
    /// @return earnAssign assigned amount of tokenY earned in this limit order
    function userEarnY(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 earnAssign
        );
    
    /// @notice Marks a given amount of tokenY in a limitorder(sellx and earn y) as assigned
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignY max amount of tokenY to mark assigned
    /// @return actualAssignY actual amount of tokenY marked
    function assignLimOrderEarnY(
        int24 point,
        uint128 assignY
    ) external returns(uint128 actualAssignY);
    
    /// @notice Marks a given amount of tokenX in a limitorder(selly and earn x) as assigned
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignX max amount of tokenX to mark assigned
    /// @return actualAssignX actual amount of tokenX marked
    function assignLimOrderEarnX(
        int24 point,
        uint128 assignX
    ) external returns(uint128 actualAssignX);

    /// @notice Decrease limitorder of selling X
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaX max amount of tokenX seller wants to decrease
    /// @return actualDeltaX actual amount of tokenX decreased
    function decLimOrderWithX(
        int24 point,
        uint128 deltaX
    ) external returns (uint128 actualDeltaX);
    
    /// @notice Decrease limitorder of selling Y
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaY max amount of tokenY seller wants to decrease
    /// @return actualDeltaY actual amount of tokenY decreased
    function decLimOrderWithY(
        int24 point,
        uint128 deltaY
    ) external returns (uint128 actualDeltaY);
    
    /// @notice Add a limit order (selling x) in the pool
    /// @param recipient owner of the limit order
    /// @param point point of the order, be sure to be times of pointDelta
    /// @param amountX amount of tokenX to sell
    /// @param data any data that should be passed through to the callback
    /// @return orderX actual added amount of tokenX
    /// @return acquireY amount of tokenY acquired if there is a limit order to sell y before adding
    function addLimOrderWithX(
        address recipient,
        int24 point,
        uint128 amountX,
        bytes calldata data
    ) external returns (uint128 orderX, uint128 acquireY);

    /// @notice Add a limit order (selling y) in the pool
    /// @param recipient owner of the limit order
    /// @param point point of the order, be sure to be times of pointDelta
    /// @param amountY amount of tokenY to sell
    /// @param data any data that should be passed through to the callback
    /// @return orderY actual added amount of tokenY
    /// @return acquireX amount of tokenX acquired if there exists a limit order to sell x before adding
    function addLimOrderWithY(
        address recipient,
        int24 point,
        uint128 amountY,
        bytes calldata data
    ) external returns (uint128 orderY, uint128 acquireX);

    /// @notice Collect earned or decreased token from limit order
    /// @param recipient address to benefit
    /// @param point point of limit order, be sure to be times of pointDelta
    /// @param collectDec max amount of decreased selling token to collect
    /// @param collectEarn max amount of earned token to collect
    /// @param isEarnY direction of this limit order, true for sell y, false for sell x
    /// @return actualCollectDec actual amount of decresed selling token collected
    /// @return actualCollectEarn actual amount of earned token collected
    function collectLimOrder(
        address recipient, int24 point, uint128 collectDec, uint128 collectEarn, bool isEarnY
    ) external returns(uint128 actualCollectDec, uint128 actualCollectEarn);

    /// @notice Add liquidity to the pool
    /// @param recipient newly created liquidity will belong to this address
    /// @param leftPt left endpoint of the liquidity, be sure to be times of pointDelta
    /// @param rightPt right endpoint of the liquidity, be sure to be times of pointDelta
    /// @param liquidDelta amount of liquidity to add
    /// @param data any data that should be passed through to the callback
    /// @return amountX The amount of tokenX that was paid for the liquidity. Matches the value in the callback
    /// @return amountY The amount of tokenY that was paid for the liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Decrease a given amount of liquidity from msg.sender's liquidities
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param liquidDelta amount of liquidity to burn
    /// @return amountX The amount of tokenX should be refund after burn
    /// @return amountY The amount of tokenY should be refund after burn
    function burn(
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Collects tokens (fee or refunded after burn) from a liquidity
    /// @param recipient the address which should receive the collected tokens
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param amountXLim max amount of tokenX the owner wants to collect
    /// @param amountYLim max amount of tokenY the owner wants to collect
    /// @return actualAmountX the amount tokenX collected
    /// @return actualAmountY the amount tokenY collected
    function collect(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint256 amountXLim,
        uint256 amountYLim
    ) external returns (uint256 actualAmountX, uint256 actualAmountY);

    /// @notice Swap tokenY for tokenX， given max amount of tokenY user willing to pay
    /// @param recipient the address to receive tokenX
    /// @param amount the max amount of tokenY user willing to pay
    /// @param highPt the highest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX payed
    /// @return amountY amount of tokenY acquired
    function swapY2X(
        address recipient,
        uint128 amount,
        int24 highPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);
    
    /// @notice Swap tokenY for tokenX， given amount of tokenX user desires
    /// @param recipient the address to receive tokenX
    /// @param desireX the amount of tokenX user desires
    /// @param highPt the highest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX payed
    /// @return amountY amount of tokenY acquired
    function swapY2XDesireX(
        address recipient,
        uint128 desireX,
        int24 highPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);
    
    /// @notice Swap tokenX for tokenY， given max amount of tokenX user willing to pay
    /// @param recipient the address to receive tokenY
    /// @param amount the max amount of tokenX user willing to pay
    /// @param lowPt the lowest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX acquired
    /// @return amountY amount of tokenY payed
    function swapX2Y(
        address recipient,
        uint128 amount,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);
    
    /// @notice Swap tokenX for tokenY， given amount of tokenY user desires
    /// @param recipient the address to receive tokenY
    /// @param desireY the amount of tokenY user desires
    /// @param lowPt the lowest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX acquired
    /// @return amountY amount of tokenY payed
    function swapX2YDesireY(
        address recipient,
        uint128 desireY,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Returns sqrt(1.0001), in 96 bit fixpoint number
    function sqrtRate_96() external view returns(uint160);
    
    /// @notice State values of pool
    /// @return sqrtPrice_96 a 96 fixpoing number describe the sqrt value of current price(tokenX/tokenY)
    /// @return currentPoint the current point of the pool, 1.0001 ^ currentPoint = price
    /// @return observationCurrentIndex the index of the last oracle observation that was written,
    /// @return observationQueueLen the current maximum number of observations stored in the pool,
    /// @return observationNextQueueLen the next maximum number of observations, to be updated when the observation.
    /// @return locked whether the pool is locked (only used for checking reentrance)
    /// @return liquidity liquidity on the currentPoint (currX * sqrtPrice + currY / sqrtPrice)
    /// @return liquidityX liquidity of tokenX
    function state()
        external view
        returns(
            uint160 sqrtPrice_96,
            int24 currentPoint,
            uint16 observationCurrentIndex,
            uint16 observationQueueLen,
            uint16 observationNextQueueLen,
            bool locked,
            uint128 liquidity,
            uint128 liquidityX
        );
    
    /// @notice LimitOrder info on a given point
    /// @param point the given point 
    /// @return sellingX total amount of tokenX selling on the point
    /// @return earnY total amount of unclaimed earned tokenY
    /// @return accEarnY total amount of earned tokenY(via selling tokenX) by all users at this point as of the last swap
    /// @return sellingY total amount of tokenYselling on the point
    /// @return earnX total amount of unclaimed earned tokenX
    /// @return accEarnX total amount of earned tokenX(via selling tokenY) by all users at this point as of the last swap
    function limitOrderData(int24 point)
        external view
        returns(
            uint128 sellingX,
            uint128 earnY,
            uint256 accEarnY,
            uint128 sellingY,
            uint128 earnX,
            uint256 accEarnX
        );
    
    /// @notice Query infomation about a point whether has limit order or is an liquidity's endpoint
    /// @param point point to query
    /// @return val endpoint for val&1>0 and has limit order for val&2 > 0
    function orderOrEndpoint(int24 point) external returns(int24 val);

    /// @notice Returns observation data about a specific index
    /// @param index the index of observation array
    /// @return timestamp the timestamp of the observation,
    /// @return accPoint the point multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// @return init whether the observation has been initialized and the above values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 timestamp,
            int56 accPoint,
            bool init
        );

    /// @notice Point status in the pool
    /// @param point the point
    /// @return liquidSum the total amount of liquidity that uses the point either as left endpoint or right endpoint
    /// @return liquidDelta how much liquidity changes when the pool price crosses the point from left to right
    /// @return accFeeXOut_128 the fee growth on the other side of the point from the current point in tokenX
    /// @return accFeeYOut_128 the fee growth on the other side of the point from the current point in tokenY
    /// @return isEndpt whether the point is an endpoint of a some miner's liquidity, true if liquidSum > 0
    function points(int24 point)
        external
        view
        returns (
            uint128 liquidSum,
            int128 liquidDelta,
            uint256 accFeeXOut_128,
            uint256 accFeeYOut_128,
            bool isEndpt
        );

    /// @notice Returns 256 packed point (statusVal>0) boolean values. See PointBitmap for more information
    function pointBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the integral value of point(time) and integral value of 1/liquidity(time)
    ///     at some target timestamps (block.timestamp - secondsAgo[i])
    /// @dev Reverts if target timestamp is early than oldest observation in the queue
    /// @dev If you call this method with secondsAgos = [3600, 0]. the average point of this pool during recent hour is 
    /// (accPoints[1] - accPoints[0]) / 3600
    /// @param secondsAgos describe the target timestamp , targetTimestimp[i] = block.timestamp - secondsAgo[i]
    /// @return accPoints integral value of point(time) from 0 to each target timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory accPoints);
    
    /// @notice Expand max-length of observation queue
    /// @param newNextQueueLen new value of observationNextQueueLen, which should be greater than current observationNextQueueLen
    function expandObservationQueue(uint16 newNextQueueLen) external;

    /// @notice Borrow tokenX and/or tokenY and pay it back within a block
    /// @dev The caller needs to implement a IiZiSwapPool#flashCallback callback function
    /// @param recipient the address which will receive the tokenY and/or tokenX
    /// @param amountX the amount of tokenX to borrow
    /// @param amountY the amount of tokenY to borrow
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amountX,
        uint256 amountY,
        bytes calldata data
    ) external;

    /// @notice Returns a snapshot infomation of Liquidity in [leftPoint, rightPoint)
    /// @param leftPoint left endpoint of range, should be times of pointDelta
    /// @param rightPoint right endpoint of range, should be times of pointDelta
    /// @return deltaLiquidities an array of delta liquidity for points in the range
    ///    note 1. delta liquidity here is amount of liquidity changed when cross a point from left to right
    ///    note 2. deltaLiquidities only contains points which are times of pointDelta
    ///    note 3. this function may cost a ENORMOUS amount of gas, be careful to call
    function liquiditySnapshot(int24 leftPoint, int24 rightPoint) external view returns(int128[] memory deltaLiquidities);

    struct LimitOrderStruct {
        uint128 sellingX;
        uint128 earnY;
        uint256 accEarnY;
        uint128 sellingY;
        uint128 earnX;
        uint256 accEarnX;
    }

    /// @notice Returns a snapshot infomation of Limit Order in [leftPoint, rightPoint)
    /// @param leftPoint left endpoint of range, should be times of pointDelta
    /// @param rightPoint right endpoint of range, should be times of pointDelta
    /// @return limitOrders an array of Limit Orders for points in the range
    ///    note 1. this function may cost a HUGE amount of gas, be careful to call
    function limitOrderSnapshot(int24 leftPoint, int24 rightPoint) external view returns(LimitOrderStruct[] memory limitOrders); 

    /// @notice Amount of charged fee on tokenX
    function totalFeeXCharged() external view returns(uint256);

    /// @notice Amount of charged fee on tokenY
    function totalFeeYCharged() external view returns(uint256);

    /// @notice Percent to charge from miner's fee
    function feeChargePercent() external view returns(uint24);

    /// @notice Collect charged fee, only factory's chargeReceiver can call
    function collectFeeCharged() external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './MulDivMath.sol';
import './TwoPower.sol';

library Liquidity {
    struct Data {
        uint128 liquidity;
        uint256 lastFeeScaleX_128;
        uint256 lastFeeScaleY_128;
        uint256 tokenOwedX;
        uint256 tokenOwedY;
    }
    
    // delta cannot be int128.min and it can be proved that
    // liquidDelta of any one point will not be int128.min
    function liquidityAddDelta(uint128 l, int128 delta) internal pure returns (uint128 nl) {
        if (delta < 0) {
            // in the pool, max(liquidity) < 2 ** 127
            // so, -delta > -2**127, -delta <= int128.max
            nl = l - uint128(-delta);
        } else {
            nl = l + uint128(delta);
        }
    }

    function get(
        mapping(bytes32 => Data) storage self,
        address minter,
        int24 tl,
        int24 tr
    ) internal view returns (Liquidity.Data storage data) {
        data = self[keccak256(abi.encodePacked(minter, tl, tr))];
    }

    function update(
        Liquidity.Data storage self,
        int128 delta,
        uint256 feeScaleX_128,
        uint256 feeScaleY_128
    ) internal {
        Data memory data = self;
        uint128 liquidity;
        if (delta == 0) {
            require(data.liquidity > 0, "L>0");
            liquidity = data.liquidity;
        } else {
            liquidity = liquidityAddDelta(data.liquidity, delta);
        }
        uint256 deltaScaleX = data.lastFeeScaleX_128;
        uint256 deltaScaleY = data.lastFeeScaleY_128;
        // use assembly to prevent revert if overflow
        // data.lastFeeScaleX(Y)_128 may be "negative" (>=2^255)
        assembly {
            deltaScaleX := sub(feeScaleX_128, deltaScaleX)
            deltaScaleY := sub(feeScaleY_128, deltaScaleY)
        }
        uint256 feeX = MulDivMath.mulDivFloor(deltaScaleX, data.liquidity, TwoPower.Pow128);
        uint256 feeY = MulDivMath.mulDivFloor(deltaScaleY, data.liquidity, TwoPower.Pow128);
        data.liquidity = liquidity;

        // update the position
        if (delta != 0) self.liquidity = liquidity;
        self.lastFeeScaleX_128 = feeScaleX_128;
        self.lastFeeScaleY_128 = feeScaleY_128;
        if (feeX > 0 || feeY > 0) {
            // need to withdraw before overflow
            self.tokenOwedX += feeX;
            self.tokenOwedY += feeY;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

library Point {
    
    struct Data {
        uint128 liquidSum;
        // value to add when pass this slot from left to right
        // value to dec when pass this slot from right to left
        int128 liquidDelta;
        // if pointPrice < currPrice
        //    value = sigma(feeScaleX(p)), which p < pointPrice
        // if pointPrice >= currPrice
        //    value = sigma(feeScaleX(p)), which p >= pointPrice
        uint256 accFeeXOut_128;
        // similar to accFeeXOut_128
        uint256 accFeeYOut_128;
        // whether the point is endpoint of a liquid segment
        bool isEndpt;
    }
    
    function _getFeeScaleL(
        int24 endpt,
        int24 currpt,
        uint256 feeScale_128,
        uint256 feeScaleBeyond_128
    ) internal pure returns (uint256 feeScaleL_128) {
        if (endpt <= currpt) {
            feeScaleL_128 = feeScaleBeyond_128;
        } else {
            assembly {
                feeScaleL_128:= sub(feeScale_128, feeScaleBeyond_128)
            }
        }
    }
    function _getFeeScaleGE(
        int24 endpt,
        int24 currpt,
        uint256 feeScale_128,
        uint256 feeScaleBeyond_128
    ) internal pure returns (uint256 feeScaleGE_128) {
        if (endpt > currpt) {
            feeScaleGE_128 = feeScaleBeyond_128;
        } else {
            assembly {
                feeScaleGE_128:= sub(feeScale_128, feeScaleBeyond_128)
            }
        }
    }
    /// @dev calculate fee scale within range [pl, pr)
    /// @param axies collection of points of liquidities
    /// @param pl left endpoint of the segment
    /// @param pr right endpoint of the segment
    /// @param currpt point of the curr price
    /// @param feeScaleX_128 total fee scale of token x accummulated of the exchange
    /// @param feeScaleY_128 similar to feeScaleX_128
    /// @return accFeeXIn_128 accFeeYIn_128 fee scale of token x and token y within range [pl, pr)
    function getSubFeeScale(
        mapping(int24 =>Point.Data) storage axies,
        int24 pl,
        int24 pr,
        int24 currpt,
        uint256 feeScaleX_128,
        uint256 feeScaleY_128
    ) internal view returns (uint256 accFeeXIn_128, uint256 accFeeYIn_128) {
        Point.Data storage plData = axies[pl];
        Point.Data storage prData = axies[pr];
        // tot fee scale of token x for price < pl
        uint256 feeScaleLX_128 = _getFeeScaleL(pl, currpt, feeScaleX_128, plData.accFeeXOut_128);
        // to fee scale of token x for price >= pr
        uint256 feeScaleGEX_128 = _getFeeScaleGE(pr, currpt, feeScaleX_128, prData.accFeeXOut_128);
        uint256 feeScaleLY_128 = _getFeeScaleL(pl, currpt, feeScaleY_128, plData.accFeeYOut_128);
        uint256 feeScaleGEY_128 = _getFeeScaleGE(pr, currpt, feeScaleY_128, prData.accFeeYOut_128);
        assembly{
            accFeeXIn_128 := sub(sub(feeScaleX_128, feeScaleLX_128), feeScaleGEX_128)
            accFeeYIn_128 := sub(sub(feeScaleY_128, feeScaleLY_128), feeScaleGEY_128)
        }
    }
    
    /// @dev update and endpoint of a liquidity segment,
    /// @param axies collections of points
    /// @param endpt endpoint of a segment
    /// @param isLeft left or right endpoint
    /// @param currpt point of current price
    /// @param delta >0 for add liquidity and <0 for dec
    /// @param liquidLimPt liquid limit per point
    /// @param feeScaleX_128 total fee scale of token x
    /// @param feeScaleY_128 total fee scale of token y
    function updateEndpoint(
        mapping(int24 =>Point.Data) storage axies,
        int24 endpt,
        bool isLeft,
        int24 currpt,
        int128 delta,
        uint128 liquidLimPt,
        uint256 feeScaleX_128,
        uint256 feeScaleY_128
    ) internal returns (bool) {
        Point.Data storage data = axies[endpt];
        uint128 liquidAccBefore = data.liquidSum;
        // delta cannot be 0
        require(delta!=0, "D0");
        // liquide acc cannot overflow
        uint128 liquidAccAfter;
        if (delta > 0) {
            liquidAccAfter = liquidAccBefore + uint128(delta);
            require(liquidAccAfter > liquidAccBefore, "LAAO");
        } else {
            liquidAccAfter = liquidAccBefore - uint128(-delta);
            require(liquidAccAfter < liquidAccBefore, "LASO");
        }
        require(liquidAccAfter <= liquidLimPt, "L LIM PT");
        data.liquidSum = liquidAccAfter;

        if (isLeft) {
            data.liquidDelta = data.liquidDelta + delta;
        } else {
            data.liquidDelta = data.liquidDelta - delta;
        }
        bool new_or_erase = false;
        if (liquidAccBefore == 0) {
            // a new endpoint of certain segment
            new_or_erase = true;
            data.isEndpt = true;
            // it can be proved that
            // for either left point or right point of the liquide segment
            // the feeScaleBeyond can be initialized to arbitrary value
            // we here set the initial val to total feeScale to delay overflow
            if (endpt >= currpt) {
                data.accFeeXOut_128 = feeScaleX_128;
                data.accFeeYOut_128 = feeScaleY_128;
            }
        } else if (liquidAccAfter == 0) {
            // no segment use this endpoint
            new_or_erase = true;
            data.isEndpt = false;
        }
        return new_or_erase;
    }

    /// @dev pass the endpoint, change the feescale beyond the price
    /// @param endpt endpoint to change
    /// @param feeScaleX_128 total fee scale of token x
    /// @param feeScaleY_128 total fee scale of token y 
    function passEndpoint(
        Point.Data storage endpt,
        uint256 feeScaleX_128,
        uint256 feeScaleY_128
    ) internal {
        uint256 accFeeXOut_128 = endpt.accFeeXOut_128;
        uint256 accFeeYOut_128 = endpt.accFeeYOut_128;
        assembly {
            accFeeXOut_128 := sub(feeScaleX_128, accFeeXOut_128)
            accFeeYOut_128 := sub(feeScaleY_128, accFeeYOut_128)
        }
        endpt.accFeeXOut_128 = accFeeXOut_128;
        endpt.accFeeYOut_128 = accFeeYOut_128;
    }

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

library PointBitmap {

    function MSB(uint256 number) internal pure returns (uint8 msb) {
        require(number > 0);

        if (number >= 0x100000000000000000000000000000000) {
            number >>= 128;
            msb += 128;
        }
        if (number >= 0x10000000000000000) {
            number >>= 64;
            msb += 64;
        }
        if (number >= 0x100000000) {
            number >>= 32;
            msb += 32;
        }
        if (number >= 0x10000) {
            number >>= 16;
            msb += 16;
        }
        if (number >= 0x100) {
            number >>= 8;
            msb += 8;
        }
        if (number >= 0x10) {
            number >>= 4;
            msb += 4;
        }
        if (number >= 0x4) {
            number >>= 2;
            msb += 2;
        }
        if (number >= 0x2) msb += 1;
    }

    function LSB(uint256 number) internal pure returns (uint8 msb) {
        require(number > 0);

        msb = 255;
        if (number & type(uint128).max > 0) {
            msb -= 128;
        } else {
            number >>= 128;
        }
        if (number & type(uint64).max > 0) {
            msb -= 64;
        } else {
            number >>= 64;
        }
        if (number & type(uint32).max > 0) {
            msb -= 32;
        } else {
            number >>= 32;
        }
        if (number & type(uint16).max > 0) {
            msb -= 16;
        } else {
            number >>= 16;
        }
        if (number & type(uint8).max > 0) {
            msb -= 8;
        } else {
            number >>= 8;
        }
        if (number & 0xf > 0) {
            msb -= 4;
        } else {
            number >>= 4;
        }
        if (number & 0x3 > 0) {
            msb -= 2;
        } else {
            number >>= 2;
        }
        if (number & 0x1 > 0) msb -= 1;
    }

    /// @notice Flips the initialized state for a given point from false to true, or vice versa
    /// @param self The mapping in which to flip the point
    /// @param point The point to flip
    /// @param pointDelta The spacing between usable points
    function flipPoint(
        mapping(int16 => uint256) storage self,
        int24 point,
        int24 pointDelta
    ) internal {
        require(point % pointDelta == 0);
        int24 mapPt = point / pointDelta;
        int16 wordIdx = int16(mapPt >> 8);
        uint8 bitIdx = uint8(uint24(mapPt % 256));
        self[wordIdx] ^= 1 << bitIdx;
    }

    function setOne(
        mapping(int16 => uint256) storage self,
        int24 point,
        int24 pointDelta
    ) internal {
        require(point % pointDelta == 0);
        int24 mapPt = point / pointDelta;
        int16 wordIdx = int16(mapPt >> 8);
        uint8 bitIdx = uint8(uint24(mapPt % 256));
        self[wordIdx] |= 1 << bitIdx;
    }

    function setZero(
        mapping(int16 => uint256) storage self,
        int24 point,
        int24 pointDelta
    ) internal {
        require(point % pointDelta == 0);
        int24 mapPt = point / pointDelta;
        int16 wordIdx = int16(mapPt >> 8);
        uint8 bitIdx = uint8(uint24(mapPt % 256));
        self[wordIdx] &= ~(1 << bitIdx);
    }

    // find nearest one from point, or boundary in the same word
    function nearestLeftOneOrBoundary(
        mapping(int16 => uint256) storage self,
        int24 point,
        int24 pointDelta
    ) internal view returns (int24 left) {
        int24 mapPt = point / pointDelta;
        if (point < 0 && point % pointDelta != 0) mapPt--; // round towards negative infinity

        int16 wordIdx = int16(mapPt >> 8);
        uint8 bitIdx = uint8(uint24(mapPt % 256));
        
        uint256 ones = self[wordIdx] & ((1 << bitIdx) - 1 + (1 << bitIdx));

        left = (ones != 0)
            ? (mapPt - int24(uint24(bitIdx - MSB(ones)))) * pointDelta
            : (mapPt - int24(uint24(bitIdx))) * pointDelta;
        
    }
    // find nearest one from point, or boundary in the same word
    function nearestRightOneOrBoundary(
        mapping(int16 => uint256) storage self,
        int24 point,
        int24 pointDelta
    ) internal view returns (int24 right) {
        int24 mapPt = point / pointDelta;
        if (point < 0 && point % pointDelta != 0) mapPt--; // round towards negative infinity

        mapPt += 1;
        int16 wordIdx = int16(mapPt >> 8);
        uint8 bitIdx = uint8(uint24(mapPt % 256));
        
        uint256 ones = self[wordIdx] & (~((1 << bitIdx) - 1));

        right = (ones != 0)
            ? (mapPt + int24(uint24(LSB(ones) - bitIdx))) * pointDelta
            : (mapPt + int24(uint24(type(uint8).max - bitIdx))) * pointDelta;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


library LogPowMath {

    int24 internal constant MIN_POINT = -887272;

    int24 internal constant MAX_POINT = -MIN_POINT;


    uint160 internal constant MIN_SQRT_PRICE = 4295128739;

    uint160 internal constant MAX_SQRT_PRICE = 1461446703485210103287273052203988822378723970342;

    /// @notice sqrt(1.0001^point) in form oy 96-bit fix point num
    function getSqrtPrice(int24 point) internal pure returns (uint160 sqrtPrice_96) {
        uint256 absIdx = point < 0 ? uint256(-int256(point)) : uint256(int256(point));
        require(absIdx <= uint256(int256(MAX_POINT)), 'T');

        uint256 value = absIdx & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absIdx & 0x2 != 0) value = (value * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absIdx & 0x4 != 0) value = (value * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absIdx & 0x8 != 0) value = (value * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absIdx & 0x10 != 0) value = (value * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absIdx & 0x20 != 0) value = (value * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absIdx & 0x40 != 0) value = (value * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absIdx & 0x80 != 0) value = (value * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absIdx & 0x100 != 0) value = (value * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absIdx & 0x200 != 0) value = (value * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absIdx & 0x400 != 0) value = (value * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absIdx & 0x800 != 0) value = (value * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absIdx & 0x1000 != 0) value = (value * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absIdx & 0x2000 != 0) value = (value * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absIdx & 0x4000 != 0) value = (value * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absIdx & 0x8000 != 0) value = (value * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absIdx & 0x10000 != 0) value = (value * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absIdx & 0x20000 != 0) value = (value * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absIdx & 0x40000 != 0) value = (value * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absIdx & 0x80000 != 0) value = (value * 0x48a170391f7dc42444e8fa2) >> 128;

        if (point > 0) value = type(uint256).max / value;

        sqrtPrice_96 = uint160((value >> 32) + (value % (1 << 32) == 0 ? 0 : 1));
    }

    // floor(log1.0001(sqrtPrice_96))
    function getLogSqrtPriceFloor(uint160 sqrtPrice_96) internal pure returns (int24 logValue) {
        // second inequality must be < because the price can nevex reach the price at the max tick
        require(sqrtPrice_96 >= MIN_SQRT_PRICE && sqrtPrice_96 < MAX_SQRT_PRICE, 'R');
        uint256 sqrtPrice_128 = uint256(sqrtPrice_96) << 32;

        uint256 x = sqrtPrice_128;
        uint256 m = 0;

        assembly {
            let y := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(5, gt(x, 0xFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(4, gt(x, 0xFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(3, gt(x, 0xFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(2, gt(x, 0xF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(1, gt(x, 0x3))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := gt(x, 0x1)
            m := or(m, y)
        }

        if (m >= 128) x = sqrtPrice_128 >> (m - 127);
        else x = sqrtPrice_128 << (127 - m);

        int256 l2 = (int256(m) - 128) << 64;

        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(63, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(62, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(61, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(60, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(59, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(58, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(57, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(56, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(55, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(54, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(53, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(52, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(51, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(50, y))
        }

        int256 ls10001 = l2 * 255738958999603826347141;

        int24 logFloor = int24((ls10001 - 3402992956809132418596140100660247210) >> 128);
        int24 logUpper = int24((ls10001 + 291339464771989622907027621153398088495) >> 128);

        logValue = logFloor == logUpper ? logFloor : getSqrtPrice(logUpper) <= sqrtPrice_96 ? logUpper : logFloor;
    }

    function getLogSqrtPriceFU(uint160 sqrtPrice_96) internal pure returns (int24 logFloor, int24 logUpper) {
        // second inequality must be < because the price can nevex reach the price at the max tick
        require(sqrtPrice_96 >= MIN_SQRT_PRICE && sqrtPrice_96 < MAX_SQRT_PRICE, 'R');
        uint256 sqrtPrice_128 = uint256(sqrtPrice_96) << 32;

        uint256 x = sqrtPrice_128;
        uint256 m = 0;

        assembly {
            let y := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(5, gt(x, 0xFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(4, gt(x, 0xFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(3, gt(x, 0xFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(2, gt(x, 0xF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(1, gt(x, 0x3))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := gt(x, 0x1)
            m := or(m, y)
        }

        if (m >= 128) x = sqrtPrice_128 >> (m - 127);
        else x = sqrtPrice_128 << (127 - m);

        int256 l2 = (int256(m) - 128) << 64;

        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(63, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(62, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(61, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(60, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(59, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(58, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(57, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(56, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(55, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(54, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(53, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(52, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(51, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(50, y))
        }

        int256 ls10001 = l2 * 255738958999603826347141;

        logFloor = int24((ls10001 - 3402992956809132418596140100660247210) >> 128);
        logUpper = int24((ls10001 + 291339464771989622907027621153398088495) >> 128);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library MulDivMath {

    // compute res = floor(a * b / c), assuming res < 2^256
    function mulDivFloor(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256 res) {
        
        // let prodMod2_256 = a * b % 2^256
        uint256 prodMod2_256; 
        // let prodDiv2_256 = a * b / 2^256
        uint256 prodDiv2_256;
        assembly {
            let prodModM1 := mulmod(a, b, not(0))
            prodMod2_256 := mul(a, b)
            prodDiv2_256 := sub(sub(prodModM1, prodMod2_256), lt(prodModM1, prodMod2_256))
        }

        if (prodDiv2_256 == 0) {
            require(c > 0);
            assembly {
                res := div(prodMod2_256, c)
            }
            return res;
        }

        // we should ensure that a * b /c < 2^256 before calling
        require(c > prodDiv2_256);

        uint256 resMod;
        assembly {
            resMod := mulmod(a, b, c)
            // a * b - resMod
            prodDiv2_256 := sub(prodDiv2_256, gt(resMod, prodMod2_256))
            prodMod2_256 := sub(prodMod2_256, resMod)

            // compute lowbit of c
            let lowbit := not(c)
            lowbit := add(lowbit, 1)
            lowbit := and(lowbit, c)

            // c / lowbit
            c := div(c, lowbit)
            // a * b / lowbit
            prodMod2_256 := div(prodMod2_256, lowbit)
            lowbit := add(div(sub(0, lowbit), lowbit), 1)
            prodDiv2_256 := mul(prodDiv2_256, lowbit)
            prodMod2_256 := or(prodMod2_256, prodDiv2_256)

            // get inv of c
            // cInv * c = 1 (mod 2^4)
            let cInv := xor(mul(3, c), 2)
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^8
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^16
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^32
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^64
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^128
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^256

            // a * b / c = prodMod2_256 * cInv (mod 2^256)
            res := mul(prodMod2_256, cInv)
        }
    }

    // compute res = ceil(a * b / c), assuming res < 2^256
    function mulDivCeil(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256 res) {
        res = mulDivFloor(a, b, c);
        if (mulmod(a, b, c) > 0) {
            require(res < type(uint256).max);
            res++;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library TwoPower {
    uint256 internal constant Pow128 = 0x100000000000000000000000000000000;
    uint256 internal constant Pow96 = 0x1000000000000000000000000;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

library LimitOrder {
    struct Data {
        uint128 sellingX;
        uint128 earnY;
        uint256 accEarnY;
        uint128 sellingY;
        uint128 earnX;
        uint256 accEarnX;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './MulDivMath.sol';
import './TwoPower.sol';
import './AmountMath.sol';
import './State.sol';
import './MaxMinMath.sol';
import './Converter.sol';


library SwapMathY2X {

    struct RangeRetState {
        // whether user has run out of tokenY
        bool finished;
        // actual cost of tokenY to buy tokenX
        uint128 costY;
        // actual amount of tokenX acquired
        uint256 acquireX;
        // final point after this swap
        int24 finalPt;
        // sqrt price on final point
        uint160 sqrtFinalPrice_96;
        // liquidity of tokenX at finalPt
        // if finalPt is not rightPt, liquidityX is meaningless
        uint128 liquidityX;
    }
    
    function y2XAtPrice(
        uint128 amountY,
        uint160 sqrtPrice_96,
        uint128 currX
    ) internal pure returns (uint128 costY, uint128 acquireX) {
        uint256 l = MulDivMath.mulDivFloor(amountY, TwoPower.Pow96, sqrtPrice_96);
        // acquireX <= currX <= uint128.max
        acquireX = uint128(MaxMinMath.min256(MulDivMath.mulDivFloor(l, TwoPower.Pow96, sqrtPrice_96), currX));
        l = MulDivMath.mulDivCeil(acquireX, sqrtPrice_96, TwoPower.Pow96);
        uint256 cost = MulDivMath.mulDivCeil(l, sqrtPrice_96, TwoPower.Pow96);
        // costY = cost <= amountY <= uint128.max
        costY = uint128(cost);
    }

    function mulDivCeil(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        uint256 v = a * b;
        if (v % c == 0) {
            return v / c;
        }
        return v / c + 1;
    }

    function y2XAtPriceLiquidity(
        uint128 amountY,
        uint160 sqrtPrice_96,
        uint128 liquidityX
    ) internal pure returns (uint128 costY, uint256 acquireX, uint128 newLiquidityX) {
        uint256 maxTransformLiquidityY = amountY * TwoPower.Pow96 / sqrtPrice_96;
        // transformLiquidityY <= liquidityX
        uint128 transformLiquidityY = uint128(MaxMinMath.min256(maxTransformLiquidityY, liquidityX));
        // costY <= amountY
        costY = uint128(mulDivCeil(transformLiquidityY, sqrtPrice_96, TwoPower.Pow96));
        acquireX = uint256(transformLiquidityY) * TwoPower.Pow96 / sqrtPrice_96;
        newLiquidityX = liquidityX - transformLiquidityY;
    }

    struct Range {
        uint128 liquidity;
        uint160 sqrtPriceL_96;
        int24 leftPt;
        uint160 sqrtPriceR_96;
        int24 rightPt;
        uint160 sqrtRate_96;
    }
    struct RangeCompRet {
        uint128 costY;
        uint256 acquireX;
        bool completeLiquidity;
        int24 locPt;
        uint160 sqrtLoc_96;
    }

    function y2XRangeComplete(
        Range memory rg,
        uint128 amountY
    ) internal pure returns (
        RangeCompRet memory ret
    ) {
        uint256 maxY = AmountMath.getAmountY(rg.liquidity, rg.sqrtPriceL_96, rg.sqrtPriceR_96, rg.sqrtRate_96, true);
        if (maxY <= amountY) {
            // ret.costY <= maxY <= uint128.max
            ret.costY = uint128(maxY);
            ret.acquireX = AmountMath.getAmountX(rg.liquidity, rg.leftPt, rg.rightPt, rg.sqrtPriceR_96, rg.sqrtRate_96, false);
            // we complete this liquidity segment
            ret.completeLiquidity = true;
        } else {
            // we should locate highest price
            // it is believed that uint160 is enough for muldiv and adding, because amountY < maxY
            uint160 sqrtLoc_96 = uint160(MulDivMath.mulDivFloor(
                amountY,
                rg.sqrtRate_96 - TwoPower.Pow96,
                rg.liquidity
            ) + rg.sqrtPriceL_96);
            ret.locPt = LogPowMath.getLogSqrtPriceFloor(sqrtLoc_96);

            ret.locPt = MaxMinMath.max(rg.leftPt, ret.locPt);
            ret.locPt = MaxMinMath.min(rg.rightPt - 1, ret.locPt);

            ret.completeLiquidity = false;
            ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);
            if (ret.locPt == rg.leftPt) {
                ret.costY = 0;
                ret.acquireX = 0;
                return ret;
            }

            uint256 costY256 = AmountMath.getAmountY(
                rg.liquidity,
                rg.sqrtPriceL_96,
                ret.sqrtLoc_96,
                rg.sqrtRate_96,
                true
            );
            // ret.costY <= amountY <= uint128.max
            ret.costY = uint128(MaxMinMath.min256(costY256, amountY));
            // it is believed that costY <= amountY even if 
            // the costY is the upperbound of the result
            // because amountY is not a real and 
            // sqrtLoc_96 <= sqrtLoc256_96
            ret.acquireX = AmountMath.getAmountX(
                rg.liquidity,
                rg.leftPt,
                ret.locPt,
                ret.sqrtLoc_96,
                rg.sqrtRate_96,
                false
            );
        
        }
    }

    /// @notice compute amount of tokens exchanged during swapY2X and some amount values (currX, currY, allX) on final point
    ///    after this swapping
    /// @param currentState state values containing (currX, currY, allX) of start point
    /// @param rightPt right most point during this swap
    /// @param sqrtRate_96 sqrt(1.0001)
    /// @param amountY max amount of Y user willing to pay
    /// @return retState amount of token acquired and some values on final point
    function y2XRange(
        State memory currentState,
        int24 rightPt,
        uint160 sqrtRate_96,
        uint128 amountY
    ) internal pure returns (
        RangeRetState memory retState
    ) {
        retState.costY = 0;
        retState.acquireX = 0;
        retState.finished = false;
        // first, if current point is not all x, we can not move right directly
        bool startHasY = (currentState.liquidityX < currentState.liquidity);
        if (startHasY) {
            (retState.costY, retState.acquireX, retState.liquidityX) = y2XAtPriceLiquidity(
                amountY, 
                currentState.sqrtPrice_96,
                currentState.liquidityX
            );
            if (retState.liquidityX > 0 || retState.costY >= amountY) {
                // it means remaining y is not enough to rise current price to price*1.0001
                // but y may remain, so we cannot simply use (costY == amountY)
                retState.finished = true;
                retState.finalPt = currentState.currentPoint;
                retState.sqrtFinalPrice_96 = currentState.sqrtPrice_96;
                return retState;
            } else {
                // y not run out
                // not finsihed
                amountY -= retState.costY;
                currentState.currentPoint += 1;
                if (currentState.currentPoint == rightPt) {
                    retState.finalPt = currentState.currentPoint;
                    // get fixed sqrt price to reduce accumulated error
                    retState.sqrtFinalPrice_96 = LogPowMath.getSqrtPrice(rightPt);
                    return retState;
                }
                // sqrt(price) + sqrt(price) * (1.0001 - 1) = 
                // sqrt(price) * 1.0001
                currentState.sqrtPrice_96 = uint160(
                    uint256(currentState.sqrtPrice_96) +
                    uint256(currentState.sqrtPrice_96) * (uint256(sqrtRate_96) - TwoPower.Pow96) / TwoPower.Pow96
                );
            }
        }

        uint160 sqrtPriceR_96 = LogPowMath.getSqrtPrice(rightPt);
        // (uint128 liquidCostY, uint256 liquidAcquireX, bool liquidComplete, int24 locPt, uint160 sqrtLoc_96)
        RangeCompRet memory ret = y2XRangeComplete(
            Range({
                liquidity: currentState.liquidity,
                sqrtPriceL_96: currentState.sqrtPrice_96,
                leftPt: currentState.currentPoint,
                sqrtPriceR_96: sqrtPriceR_96,
                rightPt: rightPt,
                sqrtRate_96: sqrtRate_96
            }),
            amountY
        );

        retState.costY += ret.costY;
        amountY -= ret.costY;
        retState.acquireX += ret.acquireX;
        if (ret.completeLiquidity) {
            retState.finished = (amountY == 0);
            retState.finalPt = rightPt;
            retState.sqrtFinalPrice_96 = sqrtPriceR_96;
        } else {
            // trade at locPt
            uint128 locCostY;
            uint256 locAcquireX;
            // if (startHasY && ret.locPt == currentState.currentPoint) {
            //     // get fixed sqrt price to reduce accumulated error
            //     // because ret.sqrtLoc_96 is computed from sqrtStartPrice * sqrt(1.0001)
            //     ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);
            // }
            (locCostY, locAcquireX, retState.liquidityX) = y2XAtPriceLiquidity(amountY, ret.sqrtLoc_96, currentState.liquidity);
            
            retState.costY += locCostY;
            retState.acquireX += locAcquireX;
            retState.finished = true;
            retState.sqrtFinalPrice_96 = ret.sqrtLoc_96;
            retState.finalPt = ret.locPt;
        }
    }

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './MulDivMath.sol';
import './TwoPower.sol';
import './AmountMath.sol';
import './State.sol';
import './MaxMinMath.sol';
import './Converter.sol';

library SwapMathX2Y {

    // group returned values of x2YRange to avoid stake too deep
    struct RangeRetState {
        // whether user run out of amountX
        bool finished;
        // actual cost of tokenX to buy tokenY
        uint128 costX;
        // amount of acquired tokenY
        uint256 acquireY;
        // final point after this swap
        int24 finalPt;
        // sqrt price on final point
        uint160 sqrtFinalPrice_96;
        // liquidity of tokenX at finalPt
        uint128 liquidityX;
    }

    function x2YAtPrice(
        uint128 amountX,
        uint160 sqrtPrice_96,
        uint128 currY
    ) internal pure returns (uint128 costX, uint128 acquireY) {
        uint256 l = MulDivMath.mulDivFloor(amountX, sqrtPrice_96, TwoPower.Pow96);
        acquireY = Converter.toUint128(MulDivMath.mulDivFloor(l, sqrtPrice_96, TwoPower.Pow96));
        if (acquireY > currY) {
            acquireY = currY;
        }
        l = MulDivMath.mulDivCeil(acquireY, TwoPower.Pow96, sqrtPrice_96);
        uint256 cost = MulDivMath.mulDivCeil(l, TwoPower.Pow96, sqrtPrice_96);
        // it is believed that costX <= amountX <= uint128.max
        costX = uint128(cost);
        // it is believed that costX <= amountX
    }

    function mulDivCeil(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        uint256 v = a * b;
        if (v % c == 0) {
            return v / c;
        }
        return v / c + 1;
    }

    function x2YAtPriceLiquidity(
        uint128 amountX,
        uint160 sqrtPrice_96,
        uint128 liquidity,
        uint128 liquidityX
    ) internal pure returns (uint128 costX, uint256 acquireY, uint128 newLiquidityX) {
        uint256 liquidityY = uint256(liquidity - liquidityX);
        uint256 maxTransformLiquidityX = MulDivMath.mulDivFloor(amountX, sqrtPrice_96, TwoPower.Pow96);
        // transformLiquidityX <= liquidityY <= uint128.max
        uint128 transformLiquidityX = uint128(MaxMinMath.min256(maxTransformLiquidityX, liquidityY));

        // transformLiquidityX <= floor(amountX * sqrtPrice_96 / TwoPower.Pow96)
        // ceil(transformLiquidityX * sqrtPrice_96 / TwoPower.Pow96) <=
        // ceil(floor(amountX * sqrtPrice_96 / TwoPower.Pow96) * sqrtPrice_96 / TwoPower.Pow96) <=
        // ceil(amountX * sqrtPrice_96 / TwoPower.Pow96 * sqrtPrice_96 / TwoPower.Pow96) =
        // ceil(amountX) = amountX <= uint128.max
        costX = uint128(mulDivCeil(transformLiquidityX, TwoPower.Pow96, sqrtPrice_96));
        acquireY = MulDivMath.mulDivFloor(transformLiquidityX, sqrtPrice_96, TwoPower.Pow96);
        newLiquidityX = liquidityX + transformLiquidityX;
    }
    
    struct Range {
        uint128 liquidity;
        uint160 sqrtPriceL_96;
        int24 leftPt;
        uint160 sqrtPriceR_96;
        int24 rightPt;
        uint160 sqrtRate_96;
    }
    
    struct RangeCompRet {
        uint128 costX;
        uint256 acquireY;
        bool completeLiquidity;
        int24 locPt;
        uint160 sqrtLoc_96;
    }

    /// @dev move from rightPt to leftPt, the range is [leftPt, rightPt)
    function x2YRangeComplete(
        Range memory rg,
        uint128 amountX
    ) internal pure returns (
        RangeCompRet memory ret
    ) {
        uint160 sqrtPricePrM1_96 = uint160(mulDivCeil(rg.sqrtPriceR_96, TwoPower.Pow96, rg.sqrtRate_96));
        uint160 sqrtPricePrMl_96 = LogPowMath.getSqrtPrice(rg.rightPt - rg.leftPt);
        // rg.rightPt - rg.leftPt <= 256 * 100
        // 1.0001 ** 25600 < 13
        // 13 * 2^96 - 2^96 < 2^100
        // rg.liquidity * (sqrtPricePrMl_96 - TwoPower.Pow96) < 2^228 < 2^256
        uint256 maxX = mulDivCeil(rg.liquidity, sqrtPricePrMl_96 - TwoPower.Pow96, rg.sqrtPriceR_96 - sqrtPricePrM1_96);
        if (maxX <= amountX) {
            // maxX <= amountX <= uint128.max
            ret.costX = uint128(maxX);
            ret.acquireY = AmountMath.getAmountY(rg.liquidity, rg.sqrtPriceL_96, rg.sqrtPriceR_96, rg.sqrtRate_96, false);
            ret.completeLiquidity = true;
        } else {
            // we should locate lowest price
            // 1. amountX * (rg.sqrtPriceR_96 - sqrtPricePrM1_96)
            // < maxX * (rg.sqrtPriceR_96 - sqrtPricePrM1_96)
            // < rg.liquidity * (sqrtPricePrMl_96 - TwoPower.Pow96) + (rg.sqrtPriceR_96 - sqrtPricePrM1_96)
            // < 2^228 + 2^160 < 2^256
            // 2. sqrtValue_96 = amountX * (rg.sqrtPriceR_96 - sqrtPricePrM1_96) // rg.liquidity + 2^96
            // <= amountX * (rg.sqrtPriceR_96 - sqrtPricePrM1_96) / rg.liquidity + 2^96
            // <= (maxX - 1) * (rg.sqrtPriceR_96 - sqrtPricePrM1_96) / rg.liquidity + 2^96
            // < rg.liquidity * (sqrtPricePrMl_96 - 2^96) / (rg.sqrtPriceR_96 - sqrtPricePrM1_96) * (rg.sqrtPriceR_96 - sqrtPricePrM1_96) / rg.liquidity + 2^96
            // = sqrtPricePrMl_96 < 2^160
            uint160 sqrtValue_96 = uint160(uint256(amountX) * (uint256(rg.sqrtPriceR_96) - sqrtPricePrM1_96) / uint256(rg.liquidity) + TwoPower.Pow96);

            int24 logValue = LogPowMath.getLogSqrtPriceFloor(sqrtValue_96);

            ret.locPt = rg.rightPt - logValue;

            ret.locPt = MaxMinMath.min(ret.locPt, rg.rightPt);
            ret.locPt = MaxMinMath.max(ret.locPt, rg.leftPt + 1);
            ret.completeLiquidity = false;
            
            if (ret.locPt == rg.rightPt) {
                ret.costX = 0;
                ret.acquireY = 0;
                ret.locPt = ret.locPt - 1;
                ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);
            } else {
                uint160 sqrtPricePrMloc_96 = LogPowMath.getSqrtPrice(rg.rightPt - ret.locPt);
                uint256 costX256 = mulDivCeil(rg.liquidity, sqrtPricePrMloc_96 - TwoPower.Pow96, rg.sqrtPriceR_96 - sqrtPricePrM1_96);
                // ret.costX <= amountX <= uint128.max
                ret.costX = uint128(MaxMinMath.min256(costX256, amountX));
                
                ret.locPt = ret.locPt - 1;
                ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);

                uint160 sqrtLocA1_96 = uint160(
                    uint256(ret.sqrtLoc_96) +
                    uint256(ret.sqrtLoc_96) * (uint256(rg.sqrtRate_96) - TwoPower.Pow96) / TwoPower.Pow96
                );
                ret.acquireY = AmountMath.getAmountY(rg.liquidity, sqrtLocA1_96, rg.sqrtPriceR_96, rg.sqrtRate_96, false);
            }
        }
    }
    
    /// @notice compute amount of tokens exchanged during swapX2Y
    ///    and some amount values (currX, currY, allX) on final point
    ///    after this swapping
    /// @param currentState state values containing (currX, currY, allX) of start point
    /// @param leftPt left most point during this swap
    /// @param sqrtRate_96 sqrt(1.0001)
    /// @param amountX max amount of tokenX user willing to pay
    /// @return retState amount of token acquired and some values on final point
    function x2YRange(
        State memory currentState,
        int24 leftPt,
        uint160 sqrtRate_96,
        uint128 amountX
    ) internal pure returns (
        RangeRetState memory retState
    ) {
        retState.costX = 0;
        retState.acquireY = 0;
        retState.finished = false;
        // if (!currentState.allX && (currentState.currX > 0 || leftPt == currentState.currentPoint)) {
        bool currentHasY = (currentState.liquidityX < currentState.liquidity);
        if (currentHasY && (currentState.liquidityX > 0 || leftPt == currentState.currentPoint)) {
            (retState.costX, retState.acquireY, retState.liquidityX) = x2YAtPriceLiquidity(
                amountX, currentState.sqrtPrice_96, currentState.liquidity, currentState.liquidityX
            );
            if (retState.liquidityX < currentState.liquidity ||  retState.costX >= amountX) {
                // remaining x is not enough to down current price to price / 1.0001
                // but x may remain, so we cannot simply use (costX == amountX)
                retState.finished = true;
                retState.finalPt = currentState.currentPoint;
                retState.sqrtFinalPrice_96 = currentState.sqrtPrice_96;
            } else {
                amountX -= retState.costX;
            }
        } else if (currentHasY) { // all y
            currentState.currentPoint = currentState.currentPoint + 1;
            // sqrt(price) + sqrt(price) * (1.0001 - 1) = 
            // sqrt(price) * 1.0001
            currentState.sqrtPrice_96 = uint160(
                uint256(currentState.sqrtPrice_96) +
                uint256(currentState.sqrtPrice_96) * (uint256(sqrtRate_96) - TwoPower.Pow96) / TwoPower.Pow96
            );
        } else {
            retState.liquidityX = currentState.liquidityX;
        }

        if (retState.finished) {
            return retState;
        }

        if (leftPt < currentState.currentPoint) {
            uint160 sqrtPriceL_96 = LogPowMath.getSqrtPrice(leftPt);
            RangeCompRet memory ret = x2YRangeComplete(
                Range({
                    liquidity: currentState.liquidity,
                    sqrtPriceL_96: sqrtPriceL_96,
                    leftPt: leftPt, 
                    sqrtPriceR_96: currentState.sqrtPrice_96, 
                    rightPt: currentState.currentPoint, 
                    sqrtRate_96: sqrtRate_96
                }),
                amountX
            );
            retState.costX += ret.costX;
            amountX -= ret.costX;
            retState.acquireY += ret.acquireY;
            if (ret.completeLiquidity) {
                retState.finished = (amountX == 0);
                retState.finalPt = leftPt;
                retState.sqrtFinalPrice_96 = sqrtPriceL_96;
                retState.liquidityX = currentState.liquidity;
            } else {
                uint128 locCostX;
                uint256 locAcquireY;
                (locCostX, locAcquireY, retState.liquidityX) = x2YAtPriceLiquidity(amountX, ret.sqrtLoc_96, currentState.liquidity, 0);
                retState.costX += locCostX;
                retState.acquireY += locAcquireY;
                retState.finished = true;
                retState.sqrtFinalPrice_96 = ret.sqrtLoc_96;
                retState.finalPt = ret.locPt;
            }
        } else {
            // finishd must be false
            // retState.finished = false;
            // liquidityX has been set
            retState.finalPt = currentState.currentPoint;
            retState.sqrtFinalPrice_96 = currentState.sqrtPrice_96;
        }
    }
    
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './MulDivMath.sol';
import './TwoPower.sol';
import './AmountMath.sol';
import './State.sol';
import './MaxMinMath.sol';
import './Converter.sol';

library SwapMathY2XDesire {

    struct RangeRetState {
        // whether user acquires enough tokenX
        bool finished;
        // actual cost of tokenY to buy tokenX
        uint256 costY;
        // actual amount of tokenX acquired
        uint128 acquireX;
        // final point after this swap
        int24 finalPt;
        // sqrt price on final point
        uint160 sqrtFinalPrice_96;
        // liquidity of tokenX at finalPt
        // if finalPt is not rightPt, liquidityX is meaningless
        uint128 liquidityX;
    }

    function y2XAtPrice(
        uint128 desireX,
        uint160 sqrtPrice_96,
        uint128 currX
    ) internal pure returns (uint128 costY, uint128 acquireX) {
        acquireX = MaxMinMath.min(desireX, currX);
        uint256 l = MulDivMath.mulDivCeil(acquireX, sqrtPrice_96, TwoPower.Pow96);
        // costY should <= uint128.max
        costY = Converter.toUint128(MulDivMath.mulDivCeil(l, sqrtPrice_96, TwoPower.Pow96));
    }

    function y2XAtPriceLiquidity(
        uint128 desireX,
        uint160 sqrtPrice_96,
        uint128 liquidityX
    ) internal pure returns (uint256 costY, uint128 acquireX, uint128 newLiquidityX) {
        uint256 maxTransformLiquidityY = MulDivMath.mulDivCeil(desireX, sqrtPrice_96, TwoPower.Pow96);
        // transformLiquidityY <= liquidityX <= uint128.max
        uint128 transformLiquidityY = uint128(MaxMinMath.min256(maxTransformLiquidityY, liquidityX));
        costY = MulDivMath.mulDivCeil(transformLiquidityY, sqrtPrice_96, TwoPower.Pow96);
        acquireX = Converter.toUint128(uint256(transformLiquidityY) * TwoPower.Pow96 / sqrtPrice_96);
        newLiquidityX = liquidityX - transformLiquidityY;
    }

    struct Range {
        uint128 liquidity;
        uint160 sqrtPriceL_96;
        int24 leftPt;
        uint160 sqrtPriceR_96;
        int24 rightPt;
        uint160 sqrtRate_96;
    }

    struct RangeCompRet {
        uint256 costY;
        uint128 acquireX;
        bool completeLiquidity;
        int24 locPt;
        uint160 sqrtLoc_96;
    }
    
    function y2XRangeComplete(
        Range memory rg,
        uint128 desireX
    ) internal pure returns (
        RangeCompRet memory ret
    ) {
        uint256 maxX = AmountMath.getAmountX(rg.liquidity, rg.leftPt, rg.rightPt, rg.sqrtPriceR_96, rg.sqrtRate_96, false);
        if (maxX <= desireX) {
            // maxX <= desireX <= uint128.max
            ret.acquireX = uint128(maxX);
            ret.costY = AmountMath.getAmountY(rg.liquidity, rg.sqrtPriceL_96, rg.sqrtPriceR_96, rg.sqrtRate_96, true);
            ret.completeLiquidity = true;
            return ret;
        }

        uint256 sqrtPricePrPl_96 = LogPowMath.getSqrtPrice(rg.rightPt - rg.leftPt);
        uint160 sqrtPricePrM1_96 = uint160(uint256(rg.sqrtPriceR_96) * TwoPower.Pow96 / rg.sqrtRate_96);

        // div must be > 2^96
        // because, if
        //  div <= 2^96
        //  <=>  sqrtPricePrPl_96 - desireX * (sqrtPriceR_96 - sqrtPricePrM1_96) / liquidity <= 2^96 (here, '/' is div of int)
        //  <=>  desireX >= (sqrtPricePrPl_96 - 2^96) * liquidity / (sqrtPriceR_96 - sqrtPricePrM1_96) 
        //  <=>  desireX >= maxX
        //  will enter the branch above and return
        uint256 div = sqrtPricePrPl_96 - MulDivMath.mulDivFloor(desireX, rg.sqrtPriceR_96 - sqrtPricePrM1_96, rg.liquidity);

        // sqrtPriceLoc_96 must < rg.sqrtPriceR_96, because div > 2^96
        uint256 sqrtPriceLoc_96 = rg.sqrtPriceR_96 * TwoPower.Pow96 / div;

        ret.completeLiquidity = false;
        ret.locPt = LogPowMath.getLogSqrtPriceFloor(uint160(sqrtPriceLoc_96));

        ret.locPt = MaxMinMath.max(rg.leftPt, ret.locPt);
        ret.locPt = MaxMinMath.min(rg.rightPt - 1, ret.locPt);
        ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);

        if (ret.locPt == rg.leftPt) {
            // ret.sqrtLoc_96 = rg.sqrtPriceL_96;
            ret.acquireX = 0;
            ret.costY = 0;
            return ret;
        }
        ret.completeLiquidity = false;
        // ret.acquireX <= desireX <= uint128.max
        ret.acquireX = uint128(MaxMinMath.min256(AmountMath.getAmountX(
            rg.liquidity,
            rg.leftPt,
            ret.locPt,
            ret.sqrtLoc_96,
            rg.sqrtRate_96,
            false
        ), desireX));
        // if (ret.sqrtLoc_96 < rg.sqrtPriceL_96) {
        //     ret.sqrtLoc_96 = rg.sqrtPriceL_96;
        // }
        ret.costY = AmountMath.getAmountY(
            rg.liquidity,
            rg.sqrtPriceL_96,
            ret.sqrtLoc_96,
            rg.sqrtRate_96,
            true
        );
    }

    /// @notice compute amount of tokens exchanged during swapY2XDesireY and some amount values (currX, currY, allX) on final point
    ///    after this swapping
    /// @param currentState state values containing (currX, currY, allX) of start point
    /// @param rightPt right most point during this swap
    /// @param sqrtRate_96 sqrt(1.0001)
    /// @param desireX amount of tokenX user wants to buy
    /// @return retState amount of token acquired and some values on final point
    function y2XRange(
        State memory currentState,
        int24 rightPt,
        uint160 sqrtRate_96,
        uint128 desireX
    ) internal pure returns (
        RangeRetState memory retState
    ) {
        retState.costY = 0;
        retState.acquireX = 0;
        retState.finished = false;
        // first, if current point is not all x, we can not move right directly
        bool startHasY = (currentState.liquidityX < currentState.liquidity);
        if (startHasY) {
            (retState.costY, retState.acquireX, retState.liquidityX) = y2XAtPriceLiquidity(desireX, currentState.sqrtPrice_96, currentState.liquidityX);
            if (retState.liquidityX > 0 || retState.acquireX >= desireX) {
                // currX remain, means desire runout
                retState.finished = true;
                retState.finalPt = currentState.currentPoint;
                retState.sqrtFinalPrice_96 = currentState.sqrtPrice_96;
                return retState;
            } else {
                // not finished
                desireX -= retState.acquireX;
                currentState.currentPoint += 1;
                if (currentState.currentPoint == rightPt) {
                    retState.finalPt = currentState.currentPoint;
                    // get fixed sqrt price to reduce accumulated error
                    retState.sqrtFinalPrice_96 = LogPowMath.getSqrtPrice(rightPt);
                    return retState;
                }
                // sqrt(price) + sqrt(price) * (1.0001 - 1) = 
                // sqrt(price) * 1.0001
                currentState.sqrtPrice_96 = uint160(
                    uint256(currentState.sqrtPrice_96) +
                    uint256(currentState.sqrtPrice_96) * (uint256(sqrtRate_96) - TwoPower.Pow96) / TwoPower.Pow96
                );
            }
        }
        
        uint160 sqrtPriceR_96 = LogPowMath.getSqrtPrice(rightPt);
        RangeCompRet memory ret = y2XRangeComplete(
            Range({
                liquidity: currentState.liquidity,
                sqrtPriceL_96: currentState.sqrtPrice_96,
                leftPt: currentState.currentPoint,
                sqrtPriceR_96: sqrtPriceR_96,
                rightPt: rightPt,
                sqrtRate_96: sqrtRate_96
            }), 
            desireX
        );
        retState.costY += ret.costY;
        retState.acquireX += ret.acquireX;
        desireX -= ret.acquireX;
        if (ret.completeLiquidity) {
            retState.finished = (desireX == 0);
            retState.finalPt = rightPt;
            retState.sqrtFinalPrice_96 = sqrtPriceR_96;
        } else {
            uint256 locCostY;
            uint128 locAcquireX;
            // if (startHasY && ret.locPt == currentState.currentPoint) {
            //     // get fixed sqrt price to reduce accumulated error
            //     // because ret.sqrtLoc_96 is computed from sqrtStartPrice * sqrt(1.0001)
            //     ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);
            // }
            (locCostY, locAcquireX, retState.liquidityX) = y2XAtPriceLiquidity(desireX, ret.sqrtLoc_96, currentState.liquidity);
            retState.costY += locCostY;
            retState.acquireX += locAcquireX;
            retState.finished = true;
            retState.finalPt = ret.locPt;
            retState.sqrtFinalPrice_96 = ret.sqrtLoc_96;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './MulDivMath.sol';
import './TwoPower.sol';
import './AmountMath.sol';
import './State.sol';
import './MaxMinMath.sol';
import './Converter.sol';

library SwapMathX2YDesire {
    
    // group returned values of x2YRange to avoid stake too deep
    struct RangeRetState {
        // whether user has acquire enough tokenY
        bool finished;
        // actual cost of tokenX to buy tokenY
        uint256 costX;
        // amount of acquired tokenY
        uint128 acquireY;
        // final point after this swap
        int24 finalPt;
        // sqrt price on final point
        uint160 sqrtFinalPrice_96;
        // liquidity of tokenX at finalPt
        uint128 liquidityX;
    }
    function x2YAtPrice(
        uint128 desireY,
        uint160 sqrtPrice_96,
        uint128 currY
    ) internal pure returns (uint128 costX, uint128 acquireY) {
        acquireY = desireY;
        if (acquireY > currY) {
            acquireY = currY;
        }
        uint256 l = MulDivMath.mulDivCeil(acquireY, TwoPower.Pow96, sqrtPrice_96);
        costX = Converter.toUint128(MulDivMath.mulDivCeil(l, TwoPower.Pow96, sqrtPrice_96));
    }
    function mulDivCeil(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        uint256 v = a * b;
        if (v % c == 0) {
            return v / c;
        }
        return v / c + 1;
    }
    function x2YAtPriceLiquidity(
        uint128 desireY,
        uint160 sqrtPrice_96,
        uint128 liquidity,
        uint128 liquidityX
    ) internal pure returns (uint256 costX, uint128 acquireY, uint128 newLiquidityX) {
        uint256 liquidityY = liquidity - liquidityX;
        uint256 maxTransformLiquidityX = mulDivCeil(uint256(desireY), TwoPower.Pow96, sqrtPrice_96);
        // transformLiquidityX <= liquidityY <= uint128.max
        uint128 transformLiquidityX = uint128(MaxMinMath.min256(maxTransformLiquidityX, liquidityY));
        costX = mulDivCeil(transformLiquidityX, TwoPower.Pow96, sqrtPrice_96);
        // acquireY should not > uint128.max
        acquireY = Converter.toUint128(transformLiquidityX * sqrtPrice_96 / TwoPower.Pow96);
        newLiquidityX = liquidityX + transformLiquidityX;
    }

    struct Range {
        uint128 liquidity;
        uint160 sqrtPriceL_96;
        int24 leftPt;
        uint160 sqrtPriceR_96;
        int24 rightPt;
        uint160 sqrtRate_96;
    }

    struct RangeCompRet {
        uint256 costX;
        uint128 acquireY;
        bool completeLiquidity;
        int24 locPt;
        uint160 sqrtLoc_96;
    }
    
    function x2YRangeComplete(
        Range memory rg,
        uint128 desireY
    ) internal pure returns (
        RangeCompRet memory ret
    ) {
        uint256 maxY = AmountMath.getAmountY(rg.liquidity, rg.sqrtPriceL_96, rg.sqrtPriceR_96, rg.sqrtRate_96, false);
        if (maxY <= desireY) {
            // maxY <= desireY <= uint128.max
            ret.acquireY = uint128(maxY);
            ret.costX = AmountMath.getAmountX(rg.liquidity, rg.leftPt, rg.rightPt, rg.sqrtPriceR_96, rg.sqrtRate_96, true);
            ret.completeLiquidity = true;
            return ret;
        }
        // desireY < maxY = rg.liquidity * (rg.sqrtPriceR_96 - rg.sqrtPriceL_96) / (rg.sqrtRate_96 - 2^96)
        // here, '/' means div of int
        // desireY < rg.liquidity * (rg.sqrtPriceR_96 - rg.sqrtPriceL_96) / (rg.sqrtRate_96 - 2^96)
        // => desireY * (rg.sqrtRate_96 - TwoPower.Pow96) / rg.liquidity < rg.sqrtPriceR_96 - rg.sqrtPriceL_96
        // => rg.sqrtPriceR_96 - desireY * (rg.sqrtRate_96 - TwoPower.Pow96) / rg.liquidity > rg.sqrtPriceL_96
        uint160 cl = uint160(uint256(rg.sqrtPriceR_96) - uint256(desireY) * (rg.sqrtRate_96 - TwoPower.Pow96) / rg.liquidity);
        
        ret.locPt = LogPowMath.getLogSqrtPriceFloor(cl) + 1;
        
        ret.locPt = MaxMinMath.min(ret.locPt, rg.rightPt);
        ret.locPt = MaxMinMath.max(ret.locPt, rg.leftPt + 1);
        ret.completeLiquidity = false;

        if (ret.locPt == rg.rightPt) {
            ret.costX = 0;
            ret.acquireY = 0;
            ret.locPt = ret.locPt - 1;
            ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);
        } else {
            uint160 sqrtPricePrMloc_96 = LogPowMath.getSqrtPrice(rg.rightPt - ret.locPt);
            uint160 sqrtPricePrM1_96 = uint160(mulDivCeil(rg.sqrtPriceR_96, TwoPower.Pow96, rg.sqrtRate_96));
            ret.costX = mulDivCeil(rg.liquidity, sqrtPricePrMloc_96 - TwoPower.Pow96, rg.sqrtPriceR_96 - sqrtPricePrM1_96);

            ret.locPt = ret.locPt - 1;
            ret.sqrtLoc_96 = LogPowMath.getSqrtPrice(ret.locPt);

            uint160 sqrtLocA1_96 = uint160(
                uint256(ret.sqrtLoc_96) +
                uint256(ret.sqrtLoc_96) * (uint256(rg.sqrtRate_96) - TwoPower.Pow96) / TwoPower.Pow96
            );
            uint256 acquireY256 = AmountMath.getAmountY(rg.liquidity, sqrtLocA1_96, rg.sqrtPriceR_96, rg.sqrtRate_96, false);
            // ret.acquireY <= desireY <= uint128.max
            ret.acquireY = uint128(MaxMinMath.min256(acquireY256, desireY));
        }
    }

    /// @notice compute amount of tokens exchanged during swapX2YDesireY and some amount values (currX, currY, allX) on final point
    ///    after this swapping
    /// @param currentState state values containing (currX, currY, allX) of start point
    /// @param leftPt left most point during this swap
    /// @param sqrtRate_96 sqrt(1.0001)
    /// @param desireY amount of Y user wants to buy
    /// @return retState amount of token acquired and some values on final point
    function x2YRange(
        State memory currentState,
        int24 leftPt,
        uint160 sqrtRate_96,
        uint128 desireY
    ) internal pure returns (
        RangeRetState memory retState
    ) {
        retState.costX = 0;
        retState.acquireY = 0;
        retState.finished = false;

        bool currentHasY = (currentState.liquidityX < currentState.liquidity);
        if (currentHasY && (currentState.liquidityX > 0 || leftPt == currentState.currentPoint)) {
            (retState.costX, retState.acquireY, retState.liquidityX) = x2YAtPriceLiquidity(
                desireY, currentState.sqrtPrice_96, currentState.liquidity, currentState.liquidityX
            );
            if (retState.liquidityX < currentState.liquidity || retState.acquireY >= desireY) {
                // remaining desire y is not enough to down current price to price / 1.0001
                // but desire y may remain, so we cannot simply use (retState.acquireY >= desireY)
                retState.finished = true;
                retState.finalPt = currentState.currentPoint;
                retState.sqrtFinalPrice_96 = currentState.sqrtPrice_96;
            } else {
                desireY -= retState.acquireY;
            }
        } else if (currentHasY) { // all y
            currentState.currentPoint = currentState.currentPoint + 1;
            // sqrt(price) + sqrt(price) * (1.0001 - 1) = 
            // sqrt(price) * 1.0001
            currentState.sqrtPrice_96 = uint160(
                uint256(currentState.sqrtPrice_96) +
                uint256(currentState.sqrtPrice_96) * (uint256(sqrtRate_96) - TwoPower.Pow96) / TwoPower.Pow96
            );
        } else {
            retState.liquidityX = currentState.liquidityX;
        }
        if (retState.finished) {
            return retState;
        }
        if (leftPt < currentState.currentPoint) {
            uint160 sqrtPriceL_96 = LogPowMath.getSqrtPrice(leftPt);
            RangeCompRet memory ret = x2YRangeComplete(
                Range({
                    liquidity: currentState.liquidity,
                    sqrtPriceL_96: sqrtPriceL_96,
                    leftPt: leftPt,
                    sqrtPriceR_96: currentState.sqrtPrice_96,
                    rightPt: currentState.currentPoint,
                    sqrtRate_96: sqrtRate_96
                }), 
                desireY
            );            
            retState.costX += ret.costX;
            desireY -= ret.acquireY;
            retState.acquireY += ret.acquireY;
            if (ret.completeLiquidity) {
                retState.finished = (desireY == 0);
                retState.finalPt = leftPt;
                retState.sqrtFinalPrice_96 = sqrtPriceL_96;
                retState.liquidityX = currentState.liquidity;
            } else {
                // locPt > leftPt
                uint256 locCostX;
                uint128 locAcquireY;
                // trade at locPt
                (locCostX, locAcquireY, retState.liquidityX) = x2YAtPriceLiquidity(
                    desireY, ret.sqrtLoc_96, currentState.liquidity, 0
                );

                retState.costX += locCostX;
                retState.acquireY += locAcquireY;
                retState.finished = true;
                retState.sqrtFinalPrice_96 = ret.sqrtLoc_96;
                retState.finalPt = ret.locPt;
            }
        } else {
            // finishd must be false
            // retState.finished = false;
            retState.finalPt = currentState.currentPoint;
            retState.sqrtFinalPrice_96 = currentState.sqrtPrice_96;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '../interfaces/IERC20Minimal.sol';

library TokenTransfer {
    
    function transferToken(
        address tokenAddr,
        address toAddr,
        uint256 amount
    ) internal {
        (bool ok, bytes memory retData) =
            tokenAddr.call(abi.encodeWithSelector(IERC20Minimal.transfer.selector, toAddr, amount));
        require(ok && (retData.length == 0 || abi.decode(retData, (bool))), 'TNS');
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.7.3;

import './MulDivMath.sol';
import './TwoPower.sol';
import './Converter.sol';
import './MaxMinMath.sol';


library UserEarn {

    // describe user's earning info for a limit order
    struct Data {
        // total amount of earned token by all users at this point 
        // with same direction (sell x or sell y) as of the last update(add/dec)
        uint256 lastAccEarn;
        // remaing amount of token on sale in this limit order
        uint128 sellingRemain;
        // uncollected decreased token
        uint128 sellingDec;
        // unassigned earned token
        // earned token before collected need to be assigned
        uint128 earn;
        // assigned but uncollected earned token
        uint128 earnAssign;
    }
    
    function get(
        mapping(bytes32 => Data) storage self,
        address user,
        int24 point
    ) internal view returns (UserEarn.Data storage data) {
        data = self[keccak256(abi.encodePacked(user, point))];
    }

    function update(
        UserEarn.Data storage self,
        uint256 currAccEarn,
        uint160 sqrtPrice_96,
        uint128 totalEarn,
        bool isEarnY
    ) internal returns (uint128 totalEarnRemain) {
        Data memory data = self;
        uint256 earn = currAccEarn - data.lastAccEarn;
        if (earn > totalEarn) {
            earn = totalEarn;
        }
        uint256 sold;
        if (isEarnY) {
            uint256 l = MulDivMath.mulDivCeil(earn, TwoPower.Pow96, sqrtPrice_96);
            sold = MulDivMath.mulDivCeil(l, TwoPower.Pow96, sqrtPrice_96);
        } else {
            uint256 l = MulDivMath.mulDivCeil(earn, sqrtPrice_96, TwoPower.Pow96);
            sold = MulDivMath.mulDivCeil(l, sqrtPrice_96, TwoPower.Pow96);
        }
        if (sold > data.sellingRemain) {
            sold = data.sellingRemain;
            if (isEarnY) {
                uint256 l = MulDivMath.mulDivFloor(sold, sqrtPrice_96, TwoPower.Pow96);
                earn = MulDivMath.mulDivFloor(l, sqrtPrice_96, TwoPower.Pow96);
            } else {
                uint256 l = MulDivMath.mulDivFloor(sold, TwoPower.Pow96, sqrtPrice_96);
                earn = MulDivMath.mulDivFloor(l, TwoPower.Pow96, sqrtPrice_96);
            }
        }
        // sold1 = ceil(ceil(earn1 * Q / P) * Q / P)
        // if sold1 <= data.sellingRemain, earn = earn1 <= totalEarn, sold=sold1 <= data.sellingRemain
        // if sold1 > data.sellingRemain, sold = data.sellingRemain
        //     sold1 - 1 < ceil(ceil(earn1 * Q / P) * Q / P)
        //  => sold1 - 1 < ceil(earn1 * Q / P) * Q / P
        //  => floor((sold1 - 1) * P / Q) < ceil(earn1 * Q / P)
        //  => floor((sold1 - 1) * P / Q) < earn1 * Q / P
        //  => earn = floor(floor((sold1 - 1) * P / Q) * P / Q) < earn1 <= totalEarn

        // earn <= totalEarn
        data.earn += uint128(earn);
        // sold <= data.sellingRemain
        data.sellingRemain -= uint128(sold);
        self.lastAccEarn = currAccEarn;
        if (earn > 0) {
            self.earn = data.earn;
        }
        if (sold > 0) {
            self.sellingRemain = data.sellingRemain;
        }
        // earn <= totalEarn
        totalEarnRemain = totalEarn - uint128(earn);
    }

    function add(
        UserEarn.Data storage self,
        uint128 delta,
        uint256 currAccEarn,
        uint160 sqrtPrice_96,
        uint128 totalEarn,
        bool isEarnY
    ) internal returns(uint128 totalEarnRemain) {
        totalEarnRemain = update(self, currAccEarn, sqrtPrice_96, totalEarn, isEarnY);
        self.sellingRemain = self.sellingRemain + delta;
    }

    function dec(
        UserEarn.Data storage self,
        uint128 delta,
        uint256 currAccEarn,
        uint160 sqrtPrice_96,
        uint128 totalEarn,
        bool isEarnY
    ) internal returns(uint128 actualDelta, uint128 totalEarnRemain) {
        totalEarnRemain = update(self, currAccEarn, sqrtPrice_96, totalEarn, isEarnY);
        actualDelta = MaxMinMath.min(delta, self.sellingRemain);
        self.sellingRemain = self.sellingRemain - actualDelta;
        self.sellingDec = self.sellingDec + actualDelta;
    }

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

struct State {
        // a 96 fixpoing number describe the sqrt value of current price(tokenX/tokenY)
        uint160 sqrtPrice_96;
        // The current point of the pool, 1.0001 ^ currentPoint = price
        int24 currentPoint;
        // The index of the last oracle observation that was written,
        uint16 observationCurrentIndex;
        // The current maximum number of observations stored in the pool,
        uint16 observationQueueLen;
        // The next maximum number of observations, to be updated when the observation.
        uint16 observationNextQueueLen;
        // whether the pool is locked (only used for checking reentrance)
        bool locked;

        // total liquidity on the currentPoint (currX * sqrtPrice + currY / sqrtPrice)
        uint128 liquidity;
        // liquidity of tokenX, liquidity of tokenY is liquidity - liquidityX
        uint128 liquidityX;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

library Oracle {

    struct Observation {
        uint32 timestamp;
        // sigma (point_i * time_i - time_(i-1))
        int56 accPoint;
        // true if this observation is inited
        bool init;
    }

    /// @notice Record a new observation with a circular queue.
    /// @param last the specified observation to be updated
    /// @param timestamp the timestamp of the new observation, > last.timestamp
    /// @param currentPoint log 1.0001 of price
    /// @return observation generated
    function newObservation(
        Observation memory last,
        uint32 timestamp,
        int24 currentPoint
    ) private pure returns (Observation memory) {
        uint56 delta = uint56(timestamp - last.timestamp);
        return
            Observation({
                timestamp: timestamp,
                accPoint: last.accPoint + int56(currentPoint) * int56(delta),
                init: true
            });
    }

    function init(Observation[65535] storage self, uint32 timestamp)
        internal
        returns (uint16 queueLen, uint16 nextQueueLen)
    {
        self[0] = Observation({
            timestamp: timestamp,
            accPoint: 0,
            init: true
        });
        return (1, 1);
    }

    /// @notice Append a price oracle observation data in the pool
    /// @param self circular-queue of observation data in array form
    /// @param currentIndex the index of the last observation in the array
    /// @param timestamp timestamp of new observation
    /// @param currentPoint current point of new observation (usually we append the point value just-before exchange)
    /// @param queueLen max-length of circular queue
    /// @param nextQueueLen next max-length of circular queue, if length of queue increase over queueLen, queueLen will become nextQueueLen
    /// @return newIndex index of new observation
    /// @return newQueueLen queueLen value after appending
    function append(
        Observation[65535] storage self,
        uint16 currentIndex,
        uint32 timestamp,
        int24 currentPoint,
        uint16 queueLen,
        uint16 nextQueueLen
    ) internal returns (uint16 newIndex, uint16 newQueueLen) {
        Observation memory last = self[currentIndex];

        if (last.timestamp == timestamp) return (currentIndex, queueLen);

        // if the conditions are right, we can bump the cardinality
        if (nextQueueLen > queueLen && currentIndex == (queueLen - 1)) {
            newQueueLen = nextQueueLen;
        } else {
            newQueueLen = queueLen;
        }

        newIndex = (currentIndex + 1) % newQueueLen;
        self[newIndex] = newObservation(last, timestamp, currentPoint);
    }

    /// @notice Expand the max-length of observation queue
    /// @param queueLen current max-length of queue
    /// @param nextQueueLen next max-length
    /// @return next max-length
    function expand(
        Observation[65535] storage self,
        uint16 queueLen,
        uint16 nextQueueLen
    ) internal returns (uint16) {
        require(queueLen > 0, 'LEN');
        
        if (nextQueueLen <= queueLen) return queueLen;
        
        for (uint16 i = queueLen; i < nextQueueLen; i++) self[i].timestamp = 1;
        return nextQueueLen;
    }

    function lte(
        uint32 time,
        uint32 a,
        uint32 b
    ) private pure returns (bool) {
        if (a <= time && b <= time) return a <= b;

        uint256 aAdjusted = a > time ? a : a + 2**32;
        uint256 bAdjusted = b > time ? b : b + 2**32;

        return aAdjusted <= bAdjusted;
    }
    
    /// @notice Binary search to find two neighbor observations for a target timestamp
    /// @param self observation queue in array form
    /// @param timestamp timestamp of current block
    /// @param targetTimestamp target time stamp
    /// @param currentIdx The index of the last observation in the array
    /// @param queueLen current max-length of queue
    /// @return beforeNeighbor before-or-at observation neighbor to target timestamp
    /// @return afterNeighbor after-or-at observation neighbor to target timestamp
    function findNeighbor(
        Observation[65535] storage self,
        uint32 timestamp,
        uint32 targetTimestamp,
        uint16 currentIdx,
        uint16 queueLen
    ) private view returns (Observation memory beforeNeighbor, Observation memory afterNeighbor) {
        uint256 l = (currentIdx + 1) % queueLen; // oldest observation
        uint256 r = l + queueLen - 1; // newest observation
        uint256 i;
        while (true) {
            i = (l + r) / 2;

            beforeNeighbor = self[i % queueLen];

            if (!beforeNeighbor.init) {
                l = i + 1;
                continue;
            }

            afterNeighbor = self[(i + 1) % queueLen];

            bool leftLessOrEq = lte(timestamp, beforeNeighbor.timestamp, targetTimestamp);

            if (leftLessOrEq && lte(timestamp, targetTimestamp, afterNeighbor.timestamp)) break;

            if (!leftLessOrEq) r = i - 1;
            else l = i + 1;
        }
    }

    /// @notice Find two neighbor observations for a target timestamp
    /// @param self observation queue in array form
    /// @param timestamp timestamp of current block
    /// @param targetTimestamp target time stamp
    /// @param currentPoint current point of swap
    /// @param currentIndex the index of the last observation in the array
    /// @param queueLen current max-length of queue
    /// @return beforeNeighbor before-or-at observation neighbor to target timestamp
    /// @return afterNeighbor after-or-at observation neighbor to target timestamp, if the targetTimestamp is later than last observation in queue,
    ///     the afterNeighbor observation does not exist in the queue
    function getTwoNeighborObservation(
        Observation[65535] storage self,
        uint32 timestamp,
        uint32 targetTimestamp,
        int24 currentPoint,
        uint16 currentIndex,
        uint16 queueLen
    ) private view returns (Observation memory beforeNeighbor, Observation memory afterNeighbor) {
        beforeNeighbor = self[currentIndex];

        if (lte(timestamp, beforeNeighbor.timestamp, targetTimestamp)) {
            if (beforeNeighbor.timestamp == targetTimestamp) {
                return (beforeNeighbor, beforeNeighbor);
            } else {
                return (beforeNeighbor, newObservation(beforeNeighbor, targetTimestamp, currentPoint));
            }
        }

        beforeNeighbor = self[(currentIndex + 1) % queueLen];
        if (!beforeNeighbor.init) beforeNeighbor = self[0];

        require(lte(timestamp, beforeNeighbor.timestamp, targetTimestamp), 'OLD');

        return findNeighbor(self, timestamp, targetTimestamp, currentIndex, queueLen);
    }

    /// @dev Reverts if secondsAgo to large.
    /// @param self the observation circular queue in array form
    /// @param timestamp the current block timestamp
    /// @param secondsAgo target timestamp is timestamp-secondsAg, 0 to return the current cumulative values.
    /// @param currentPoint the current point of pool
    /// @param currentIndex the index of the last observation in the array
    /// @param queueLen max-length of circular queue
    /// @return accPoint integral value of point(time) from 0 to each timestamp
    function observeSingle(
        Observation[65535] storage self,
        uint32 timestamp,
        uint32 secondsAgo,
        int24 currentPoint,
        uint16 currentIndex,
        uint16 queueLen
    ) internal view returns (int56 accPoint ) {
        if (secondsAgo == 0) {
            Observation memory last = self[currentIndex];
            if (last.timestamp != timestamp) last = newObservation(last, timestamp, currentPoint);
            return last.accPoint;
        }

        uint32 targetTimestamp = timestamp - secondsAgo;

        (Observation memory beforeNeighbor, Observation memory afterNeighbor) =
            getTwoNeighborObservation(self, timestamp, targetTimestamp, currentPoint, currentIndex, queueLen);

        if (targetTimestamp == beforeNeighbor.timestamp) {
            // we're at the left boundary
            return beforeNeighbor.accPoint;
        } else if (targetTimestamp == afterNeighbor.timestamp) {
            // we're at the right boundary
            return afterNeighbor.accPoint;
        } else {
            // we're in the middle
            uint56 leftRightTimeDelta = afterNeighbor.timestamp - beforeNeighbor.timestamp;
            uint56 targetTimeDelta = targetTimestamp - beforeNeighbor.timestamp;
            return beforeNeighbor.accPoint  + 
                (afterNeighbor.accPoint - beforeNeighbor.accPoint) / int56(leftRightTimeDelta) * int56(targetTimeDelta);
        }
    }

    /// @notice Returns the integral value of point with time 
    /// @dev Reverts if target timestamp is early than oldest observation in the queue
    /// @dev if you call this method with secondsAgos = [3600, 0]. the average point of this pool during recent hour is (accPoints[1] - accPoints[0]) / 3600
    /// @param self the observation circular queue in array form
    /// @param timestamp the current block timestamp
    /// @param secondsAgos describe the target timestamp , targetTimestimp[i] = block.timestamp - secondsAgo[i]
    /// @param currentPoint the current point of pool
    /// @param currentIndex the index of the last observation in the array
    /// @param queueLen max-length of circular queue
    /// @return accPoints integral value of point(time) from 0 to each timestamp
    function observe(
        Observation[65535] storage self,
        uint32 timestamp,
        uint32[] memory secondsAgos,
        int24 currentPoint,
        uint16 currentIndex,
        uint16 queueLen
    ) internal view returns (int56[] memory accPoints ) {
        require(queueLen > 0, 'I');

        accPoints = new int56[](secondsAgos.length);
        for (uint256 i = 0; i < secondsAgos.length; i++) {
            accPoints[i] = observeSingle(
                self,
                timestamp,
                secondsAgos[i],
                currentPoint,
                currentIndex,
                queueLen
            );
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

library OrderOrEndpoint {
    
    function getOrderOrEndptVal(mapping(int24 =>int24) storage self, int24 point, int24 pd) internal view returns(int24 val) {
        if (point % pd != 0) {
            return 0;
        }
        val = self[point / pd];
    }
    function setOrderOrEndptVal(mapping(int24 =>int24) storage self, int24 point, int24 pd, int24 val) internal {
        self[point / pd] = val;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

library MaxMinMath {

    function max(int24 a, int24 b) internal pure returns (int24) {
        if (a > b) {
            return a;
        }
        return b;
    }

    function min(int24 a, int24 b) internal pure returns (int24) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function min(uint128 a, uint128 b) internal pure returns (uint128) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return a;
        }
        return b;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IiZiSwapMintCallback {

    /// @notice Called to msg.sender in iZiSwapPool#mint call
    /// @param x Amount of tokenX need to pay from miner
    /// @param y Amount of tokenY need to pay from miner
    /// @param data Any data passed through by the msg.sender via the iZiSwapPool#mint call
    function mintDepositCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

interface IiZiSwapCallback {

    /// @notice Called to msg.sender in iZiSwapPool#swapY2X(DesireX) call
    /// @param x Amount of tokenX trader will acquire
    /// @param y Amount of tokenY trader will pay
    /// @param data Any dadta passed though by the msg.sender via the iZiSwapPool#swapY2X(DesireX) call
    function swapY2XCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

    /// @notice Called to msg.sender in iZiSwapPool#swapX2Y(DesireY) call
    /// @param x Amount of tokenX trader will pay
    /// @param y Amount of tokenY trader will require
    /// @param data Any dadta passed though by the msg.sender via the iZiSwapPool#swapX2Y(DesireY) call
    function swapX2YCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

interface IiZiSwapAddLimOrderCallback {

    /// @notice Called to msg.sender in iZiSwapPool#addLimOrderWithX(Y) call
    /// @param x Amount of tokenX seller will pay
    /// @param y Amount of tokenY seller will pay
    /// @param data Any dadta passed though by the msg.sender via the iZiSwapPool#addLimOrderWithX(Y) call
    function payCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

// group local vars in swap functions to avoid stack too deep
struct SwapCache {
    // fee growth of tokenX during swap
    uint256 currFeeScaleX_128;
    // fee growth of tokenY during swap
    uint256 currFeeScaleY_128;
    // whether swap finished
    bool finished;
    // 96bit-fixpoint of sqrt(1.0001)
    uint160 _sqrtRate_96;
    // pointDelta
    int24 pointDelta;
    // whether has limorder and whether as endpt for current point
    int24 currentOrderOrEndpt;
    // start point of swap, etc. state.currPt before swap loop
    int24 startPoint;
    // start liquidity of swap, etc. state.liquidity before swap loop
    uint128 startLiquidity;
    // block time stamp of this swap transaction
    uint32 timestamp;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './MulDivMath.sol';
import './TwoPower.sol';
import './LogPowMath.sol';

library AmountMath {

    function getAmountY(
        uint128 liquidity,
        uint160 sqrtPriceL_96,
        uint160 sqrtPriceR_96,
        uint160 sqrtRate_96,
        bool upper
    ) internal pure returns (uint256 amount) {
        uint160 numerator = sqrtPriceR_96 - sqrtPriceL_96;
        uint160 denominator = sqrtRate_96 - uint160(TwoPower.Pow96);
        if (!upper) {
            amount = MulDivMath.mulDivFloor(liquidity, numerator, denominator);
        } else {
            amount = MulDivMath.mulDivCeil(liquidity, numerator, denominator);
        }
    }

    function getAmountX(
        uint128 liquidity,
        int24 leftPt,
        int24 rightPt,
        uint160 sqrtPriceR_96,
        uint160 sqrtRate_96,
        bool upper
    ) internal pure returns (uint256 amount) {
        // rightPt - (leftPt - 1), pc = leftPt - 1
        uint160 sqrtPricePrPl_96 = LogPowMath.getSqrtPrice(rightPt - leftPt);
        uint160 sqrtPricePrM1_96 = uint160(uint256(sqrtPriceR_96) * TwoPower.Pow96 / sqrtRate_96);

        uint160 numerator = sqrtPricePrPl_96 - uint160(TwoPower.Pow96);
        uint160 denominator = sqrtPriceR_96 - sqrtPricePrM1_96;
        if (!upper) {
            amount = MulDivMath.mulDivFloor(liquidity, numerator, denominator);
        } else {
            amount = MulDivMath.mulDivCeil(liquidity, numerator, denominator);
        }
    }

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;


library Converter {

    function toUint128(uint256 a) internal pure returns (uint128 b){
        b = uint128(a);
        require(a == b, 'C128');
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Minimal ERC20 interface for Uniswap
/// @notice Contains a subset of the full ERC20 interface that is used in Uniswap V3
interface IERC20Minimal {
    /// @notice Returns the balance of a token
    /// @param account The account for which to look up the number of tokens it has, i.e. its balance
    /// @return The number of tokens held by the account
    function balanceOf(address account) external view returns (uint256);

    /// @notice Transfers the amount of token from the `msg.sender` to the recipient
    /// @param recipient The account that will receive the amount transferred
    /// @param amount The number of tokens to send from the sender to the recipient
    /// @return Returns true for a successful transfer, false for an unsuccessful transfer
    function transfer(address recipient, uint256 amount) external returns (bool);

    /// @notice Returns the current allowance given to a spender by an owner
    /// @param owner The account of the token owner
    /// @param spender The account of the token spender
    /// @return The current allowance granted by `owner` to `spender`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets the allowance of a spender from the `msg.sender` to the value `amount`
    /// @param spender The account which will be allowed to spend a given amount of the owners tokens
    /// @param amount The amount of tokens allowed to be used by `spender`
    /// @return Returns true for a successful approval, false for unsuccessful
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Transfers `amount` tokens from `sender` to `recipient` up to the allowance given to the `msg.sender`
    /// @param sender The account from which the transfer will be initiated
    /// @param recipient The recipient of the transfer
    /// @param amount The amount of the transfer
    /// @return Returns true for a successful transfer, false for unsuccessful
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /// @notice Event emitted when tokens are transferred from one address to another, either via `#transfer` or `#transferFrom`.
    /// @param from The account from which the tokens were sent, i.e. the balance decreased
    /// @param to The account to which the tokens were sent, i.e. the balance increased
    /// @param value The amount of tokens that were transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Event emitted when the approval amount for the spender of a given owner's tokens changes.
    /// @param owner The account that approved spending of its tokens
    /// @param spender The account for which the spending allowance was modified
    /// @param value The new allowance from the owner to the spender
    event Approval(address indexed owner, address indexed spender, uint256 value);
}