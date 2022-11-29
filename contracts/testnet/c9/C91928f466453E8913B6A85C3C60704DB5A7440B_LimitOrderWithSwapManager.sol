// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./core/interfaces/IiZiSwapCallback.sol";
import "./core/interfaces/IiZiSwapFactory.sol";
import "./core/interfaces/IiZiSwapPool.sol";

import "./libraries/MulDivMath.sol";
import "./libraries/TwoPower.sol";
import "./libraries/LogPowMath.sol";
import "./libraries/LimOrder.sol";
import "./libraries/LimOrderCircularQueue.sol";
import "./libraries/Converter.sol";

import "./base/base.sol";
import "./base/Switch.sol";

contract LimitOrderWithSwapManager is Switch, Base, IiZiSwapAddLimOrderCallback, IiZiSwapCallback {

    using LimOrderCircularQueue for LimOrderCircularQueue.Queue;

    /// @notice Emitted when user successfully create an limit order
    /// @param pool address of swap pool
    /// @param point point (price) of this limit order
    /// @param user address of user
    /// @param amount amount of token ready to sell
    /// @param sellingRemain amount of selling token remained after successfully create this limit order
    /// @param earn amount of acquired token after successfully create this limit order
    /// @param sellXEarnY true if this order sell tokenX, false if sell tokenY
    event NewLimitOrder(
        address pool,
        int24 point,
        address user,
        uint128 amount,
        uint128 sellingRemain,
        uint128 earn,
        bool sellXEarnY
    );
    /// @notice Emitted when user preswap AND SWAP OUT or do market swap before adding limit order
    /// @param tokenIn address of tokenIn (user payed to swap pool)
    /// @param tokenOut address of tokenOut (user acquired from swap pool)
    /// @param fee fee amount of swap pool
    /// @param amountIn amount of tokenIn during swap
    /// @param amountOut amount of tokenOut during swap
    event MarketSwap(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint128 amountIn,
        uint128 amountOut
    );
    /// @notice Emitted when user dec or update his limit order
    /// @param pool address of swap pool
    /// @param point point (price) of this limit order
    /// @param user address of user
    /// @param sold amount of token sold from last claim to now
    /// @param earn amount of token earned from last claim to now
    /// @param sellXEaryY true if sell tokenX, false if sell tokenY
    event Claim(
        address pool,
        int24 point,
        address user,
        uint128 sold,
        uint128 earn,
        bool sellXEaryY
    );
    // max-poolId in poolIds, poolId starts from 1
    uint128 private maxPoolId = 1;

    // owners of limit order
    mapping(uint256 =>address) public sellers;
    
    struct PoolMeta {
        address tokenX;
        address tokenY;
        uint24 fee;
    }

    // mapping from pool id to pool's meta info
    mapping(uint128 =>PoolMeta) public poolMetas;

    // mapping from pool id to pool address
    mapping(uint128 =>address) public poolAddrs;

    // mapping from pool address to poolid
    mapping(address =>uint128) public poolIds;

    // seller's active order id
    mapping(address => LimOrder[]) private addr2ActiveOrder;
    // seller's canceled or finished order id
    mapping(address => LimOrderCircularQueue.Queue) private addr2DeactiveOrder;

    // maximum number of active order per user
    // TODO: 
    //   currently we used a fixed number of storage space. A better way is to allow user to expand it.
    //   Otherwise, the first 300 orders need more gas for storage.
    uint256 public immutable DEACTIVE_ORDER_LIM = 300;

    // callback data passed through iZiSwapPool#addLimOrderWithX(Y) to the callback
    struct LimCallbackData {
        // tokenX of swap pool
        address tokenX;
        // tokenY of swap pool
        address tokenY;
        // fee amount of swap pool
        uint24 fee;
        // the address who provides token to sell
        address payer;
    }

    modifier checkActive(uint256 lIdx) {
        require(addr2ActiveOrder[msg.sender].length > lIdx, 'Out Of Length!');
        require(addr2ActiveOrder[msg.sender][lIdx].active, 'Not Active!');
        _;
    }

    /// @notice Constructor to create this contract.
    /// @param factory address of iZiSwapFactory
    /// @param weth address of WETH token
    constructor( address factory, address weth ) Base(factory, weth) {}

    /// @notice Callback for add limit order, in order to deposit corresponding tokens
    /// @param x amount of tokenX need to pay from miner
    /// @param y amount of tokenY need to pay from miner
    /// @param data encoded LimCallbackData
    function payCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external override notPause {
        LimCallbackData memory dt = abi.decode(data, (LimCallbackData));
        verify(dt.tokenX, dt.tokenY, dt.fee);
        if (x > 0) {
            pay(dt.tokenX, dt.payer, msg.sender, x);
        }
        if (y > 0) {
            pay(dt.tokenY, dt.payer, msg.sender, y);
        }
    }

    struct SwapCallbackData {
        address tokenX;
        address tokenY;
        uint24 fee;
        address payer;
    }

    /// @notice Callback for swapY2X and swapY2XDesireX, in order to pay tokenY from trader.
    /// @param x amount of tokenX trader acquired
    /// @param y amount of tokenY need to pay from trader
    /// @param data encoded SwapCallbackData
    function swapY2XCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external override notPause {
        SwapCallbackData memory dt = abi.decode(data, (SwapCallbackData));
        verify(dt.tokenX, dt.tokenY, dt.fee);
        pay(dt.tokenY, dt.payer, msg.sender, y);
    }

    /// @notice Callback for swapX2Y and swapX2YDesireY, in order to pay tokenX from trader.
    /// @param x amount of tokenX need to pay from trader
    /// @param y amount of tokenY trader acquired
    /// @param data encoded SwapCallbackData
    function swapX2YCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external override notPause {
        SwapCallbackData memory dt = abi.decode(data, (SwapCallbackData));
        verify(dt.tokenX, dt.tokenY, dt.fee);
        pay(dt.tokenX, dt.payer, msg.sender, x);
    }

    function limOrderKey(address miner, int24 pt) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(miner, pt));
    }

    function cachePoolKey(address pool, PoolMeta memory meta) private returns (uint128 poolId) {
        poolId = poolIds[pool];
        if (poolId == 0) {
            poolIds[pool] = (poolId = maxPoolId++);
            poolMetas[poolId] = meta;
            poolAddrs[poolId] = pool;
        }
    }

    function getEarnX(address pool, bytes32 key) private view returns(uint256, uint128, uint128) {
        (uint256 lastAccEarn, , , uint128 earn, uint128 legacyEarn, ) = IiZiSwapPool(pool).userEarnX(key);
        return (lastAccEarn, earn, legacyEarn);
    }

    function getEarnX(address pool, address miner, int24 pt) private view returns(uint256 accEarn, uint128 earn, uint128 legacyEarn) {
        (accEarn, earn, legacyEarn) = getEarnX(pool, limOrderKey(miner, pt));
    }

    function getEarnY(address pool, bytes32 key) private view returns(uint256, uint128, uint128) {
        (uint256 lastAccEarn, , , uint128 earn, uint128 legacyEarn, ) = IiZiSwapPool(pool).userEarnY(key);
        return (lastAccEarn, earn, legacyEarn);
    }

    function getEarnY(address pool, address miner, int24 pt) private view returns(uint256 accEarn, uint128 earn, uint128 legacyEarn) {
        (accEarn, earn, legacyEarn) = getEarnY(pool, limOrderKey(miner, pt));
    }

    function getEarn(address pool, address miner, int24 pt, bool sellXEarnY) private view returns(uint256 accEarn, uint128 earn, uint128 legacyEarn) {
        if (sellXEarnY) {
            (accEarn, earn, legacyEarn) = getEarnY(pool, limOrderKey(miner, pt));
        } else {
            (accEarn, earn, legacyEarn) = getEarnX(pool, limOrderKey(miner, pt));
        }
    }

    /// parameters when calling newLimOrder, grouped together to avoid stake too deep
    struct AddLimOrderParam {
        // recipient to acquire token during pre-swap
        // if and only if user acquire chain token token (like eth/bnb, and not in wrapped form),
        //     address should be 0, and user should append a unwrapWETH9(...) calling immediately 
        //     (via multicall)
        address recipient;
        // tokenX of swap pool
        address tokenX;
        // tokenY of swap pool
        address tokenY;
        // fee amount of swap pool
        uint24 fee;
        // on which point to add limit order
        int24 pt;

        bool isDesireMode;
        // amount of token to sell/acquire
        // if isDesireMode is true, acquire amount
        // otherwise, sell amount
        uint128 amount;
        uint256 swapMinAcquired;
        // sell tokenX or sell tokenY
        bool sellXEarnY;

        uint256 deadline;
    }

    function _addLimOrder(
        address pool, AddLimOrderParam memory addLimitOrderParam
    ) private returns (uint128 order, uint128 acquire) {
        if (addLimitOrderParam.sellXEarnY) {
            (order, acquire) = IiZiSwapPool(pool).addLimOrderWithX(
                address(this), addLimitOrderParam.pt, addLimitOrderParam.amount,
                abi.encode(LimCallbackData({tokenX: addLimitOrderParam.tokenX, tokenY: addLimitOrderParam.tokenY, fee: addLimitOrderParam.fee, payer: msg.sender}))
            );
        } else {
            (order, acquire) = IiZiSwapPool(pool).addLimOrderWithY(
                address(this), addLimitOrderParam.pt, addLimitOrderParam.amount,
                abi.encode(LimCallbackData({tokenX: addLimitOrderParam.tokenX, tokenY: addLimitOrderParam.tokenY, fee: addLimitOrderParam.fee, payer: msg.sender}))
            );
        }
    }

    struct SwapBeforeResult {
        uint128 remainAmount;
        uint128 costBeforeSwap;
        uint128 acquireBeforeSwap;
        bool swapOut;
    }

    function _swapBefore(
        address pool,
        AddLimOrderParam memory addLimitOrderParam
    ) private returns (SwapBeforeResult memory) {
        address recipient = addLimitOrderParam.recipient == address(0) ? address(this) : addLimitOrderParam.recipient;
        SwapBeforeResult memory result = SwapBeforeResult({
            remainAmount: 0,
            costBeforeSwap: 0,
            acquireBeforeSwap: 0,
            swapOut: false
        });
        result.remainAmount = addLimitOrderParam.amount;
        (
            ,
            int24 currentPoint,
            ,
            ,
            ,
            ,
            ,
        ) = IiZiSwapPool(pool).state();
        if (addLimitOrderParam.sellXEarnY) {
            if (addLimitOrderParam.pt < currentPoint) {
                uint256 costX;
                uint256 acquireY;
                if (addLimitOrderParam.isDesireMode) {
                    (costX, acquireY) = IiZiSwapPool(pool).swapX2YDesireY(
                        recipient, addLimitOrderParam.amount, addLimitOrderParam.pt,
                        abi.encode(SwapCallbackData({
                            tokenX: addLimitOrderParam.tokenX, 
                            fee: addLimitOrderParam.fee, 
                            tokenY: addLimitOrderParam.tokenY, 
                            payer: msg.sender
                        }))
                    );
                    require(acquireY >= addLimitOrderParam.swapMinAcquired, "X2YDesireYAcquired");
                    result.remainAmount = acquireY < uint256(addLimitOrderParam.amount) ? addLimitOrderParam.amount - uint128(acquireY) : 0;
                } else {
                    (costX, acquireY) = IiZiSwapPool(pool).swapX2Y(
                        recipient, addLimitOrderParam.amount, addLimitOrderParam.pt,
                        abi.encode(SwapCallbackData({
                            tokenX: addLimitOrderParam.tokenX, 
                            fee: addLimitOrderParam.fee, 
                            tokenY: addLimitOrderParam.tokenY, 
                            payer: msg.sender
                        }))
                    );
                    require(acquireY >= addLimitOrderParam.swapMinAcquired, "X2YAcquired");
                    result.remainAmount = costX < uint256(addLimitOrderParam.amount) ? addLimitOrderParam.amount - uint128(costX) : 0;
                }
                result.acquireBeforeSwap = Converter.toUint128(acquireY);
                result.costBeforeSwap = Converter.toUint128(costX);
            }
        } else {
            if (addLimitOrderParam.pt > currentPoint) {
                uint256 costY;
                uint256 acquireX;
                if (addLimitOrderParam.isDesireMode) {
                    (acquireX, costY) = IiZiSwapPool(pool).swapY2XDesireX(
                        recipient, addLimitOrderParam.amount, addLimitOrderParam.pt + 1,
                        abi.encode(SwapCallbackData({
                            tokenX: addLimitOrderParam.tokenX, 
                            fee: addLimitOrderParam.fee, 
                            tokenY: addLimitOrderParam.tokenY, 
                            payer: msg.sender
                        }))
                    );
                    require(acquireX >= addLimitOrderParam.swapMinAcquired, "Y2XDesireXAcquired");
                    result.remainAmount = acquireX < uint256(addLimitOrderParam.amount) ? addLimitOrderParam.amount - uint128(acquireX) : 0;
                } else {
                    (acquireX, costY) = IiZiSwapPool(pool).swapY2X(
                        recipient, addLimitOrderParam.amount, addLimitOrderParam.pt + 1,
                        abi.encode(SwapCallbackData({
                            tokenX: addLimitOrderParam.tokenX, 
                            fee: addLimitOrderParam.fee, 
                            tokenY: addLimitOrderParam.tokenY, 
                            payer: msg.sender
                        }))
                    );
                    require(acquireX >= addLimitOrderParam.swapMinAcquired, "Y2XAcquired");
                    result.remainAmount = costY < uint256(addLimitOrderParam.amount) ? addLimitOrderParam.amount - uint128(costY) : 0;
                }
                result.acquireBeforeSwap = Converter.toUint128(acquireX);
                result.costBeforeSwap = Converter.toUint128(costY);
            }
        }
        result.swapOut = (result.remainAmount <= addLimitOrderParam.amount / 10000);
        return result;
    }

    /// @notice Create a limit order for recipient.
    /// @param idx slot in the addr2ActiveOrder[msg.sender]
    /// @param originAddLimitOrderParam describe params of added limit order, see AddLimOrderParam for more
    /// @return orderAmount actual amount of token added in limit order
    /// @return costBeforeSwap amount of token cost if we need to swap before add limit order
    /// @return acquireBeforeSwap amount of token acquired if we need to swap before add limit order
    /// @return acquire amount of token acquired if there is a limit order to sell the other token before adding
    function newLimOrder(
        uint256 idx,
        AddLimOrderParam calldata originAddLimitOrderParam
    ) external payable notPause checkDeadline(originAddLimitOrderParam.deadline) returns (uint128 orderAmount, uint128 costBeforeSwap, uint128 acquireBeforeSwap, uint128 acquire) {
        require(originAddLimitOrderParam.tokenX < originAddLimitOrderParam.tokenY, 'x<y');

        AddLimOrderParam memory addLimitOrderParam = originAddLimitOrderParam;
        
        address pool = IiZiSwapFactory(factory).pool(addLimitOrderParam.tokenX, addLimitOrderParam.tokenY, addLimitOrderParam.fee);

        SwapBeforeResult memory swapBeforeResult = _swapBefore(pool, addLimitOrderParam);
        addLimitOrderParam.amount = swapBeforeResult.remainAmount;
        if (swapBeforeResult.swapOut) {
            // swap out
            if (address(this).balance > 0) safeTransferETH(msg.sender, address(this).balance);
            emit MarketSwap(
                originAddLimitOrderParam.sellXEarnY ? originAddLimitOrderParam.tokenX : originAddLimitOrderParam.tokenY,
                originAddLimitOrderParam.sellXEarnY ? originAddLimitOrderParam.tokenY : originAddLimitOrderParam.tokenX,
                originAddLimitOrderParam.fee,
                costBeforeSwap,
                acquireBeforeSwap
            );
            return (0, swapBeforeResult.costBeforeSwap, swapBeforeResult.acquireBeforeSwap, 0);
        }
        if (addLimitOrderParam.isDesireMode) {
            // transform desire amount to sell amount
            uint160 sqrtPrice = LogPowMath.getSqrtPrice(addLimitOrderParam.pt);
            if (addLimitOrderParam.sellXEarnY) {
                uint256 l = MulDivMath.mulDivCeil(addLimitOrderParam.amount, TwoPower.pow96, sqrtPrice);
                addLimitOrderParam.amount = Converter.toUint128(MulDivMath.mulDivCeil(l, TwoPower.pow96, sqrtPrice));
            } else {
                uint256 l = MulDivMath.mulDivCeil(addLimitOrderParam.amount, sqrtPrice, TwoPower.pow96);
                addLimitOrderParam.amount = Converter.toUint128(MulDivMath.mulDivCeil(l, sqrtPrice, TwoPower.pow96));
            }
            // no need to write following line
            addLimitOrderParam.isDesireMode = false;
        }
        (orderAmount, acquire) = _addLimOrder(pool, addLimitOrderParam);
        (uint256 accEarn, , ) = getEarn(pool, address(this), addLimitOrderParam.pt, addLimitOrderParam.sellXEarnY);
        uint128 poolId = cachePoolKey(pool, PoolMeta({tokenX: addLimitOrderParam.tokenX, tokenY: addLimitOrderParam.tokenY, fee: addLimitOrderParam.fee}));
        LimOrder[] storage limOrders = addr2ActiveOrder[msg.sender];
        if (idx < limOrders.length) {
            // replace
            require(limOrders[idx].active == false, 'active conflict!');
            limOrders[idx] = LimOrder({
                pt: addLimitOrderParam.pt,
                amount: addLimitOrderParam.amount + swapBeforeResult.costBeforeSwap,
                sellingRemain: orderAmount,
                accSellingDec: 0,
                sellingDec: 0,
                // donot add acquireBeforeSwap, because we have collected them
                earn: acquire,
                lastAccEarn: accEarn,
                poolId: poolId,
                sellXEarnY: addLimitOrderParam.sellXEarnY,
                timestamp: uint128(block.timestamp),
                active: true
            });
        } else {
            limOrders.push(LimOrder({
                pt: addLimitOrderParam.pt,
                amount: addLimitOrderParam.amount + swapBeforeResult.costBeforeSwap,
                sellingRemain: orderAmount,
                accSellingDec: 0,
                sellingDec: 0,
                // donot add acquireBeforeSwap, because we have collected them
                earn: acquire,
                lastAccEarn: accEarn,
                poolId: poolId,
                sellXEarnY: addLimitOrderParam.sellXEarnY,
                timestamp: uint128(block.timestamp),
                active: true
            }));
        }
        emit NewLimitOrder(pool, addLimitOrderParam.pt, msg.sender, addLimitOrderParam.amount, orderAmount, acquire, addLimitOrderParam.sellXEarnY);
    }

    /// @notice Compute max amount of earned token the seller can claim.
    /// @param lastAccEarn total amount of earned token of all users on this point before last update of this limit order
    /// @param accEarn total amount of earned token of all users on this point now
    /// @param earnRemain total amount of unclaimed earned token of all users on this point
    /// @return earnLim max amount of earned token the seller can claim
    function getEarnLim(uint256 lastAccEarn, uint256 accEarn, uint128 earnRemain) private pure returns(uint128 earnLim) {
        require(accEarn >= lastAccEarn, "AEO");
        uint256 earnLim256 = accEarn - lastAccEarn;
        if (earnLim256 > earnRemain) {
            earnLim256 = earnRemain;
        }
        earnLim = uint128(earnLim256);
    }

    /// @notice Compute amount of earned token and amount of sold token for a limit order as much as possible.
    /// @param sqrtPrice_96 a 96 bit fixpoint number to describe sqrt(price) of pool
    /// @param earnLim max amount of earned token computed by getEarnLim(...)
    /// @param sellingRemain amount of token before exchange in the limit order
    /// @param isEarnY direction of the limit order (sell Y or sell tokenY)
    /// @return earn amount of earned token this limit order can claim
    /// @return sold amount of sold token which will be minused from sellingRemain
    function getEarnSold(
        uint160 sqrtPrice_96,
        uint128 earnLim,
        uint128 sellingRemain,
        bool isEarnY
    ) private pure returns (uint128 earn, uint128 sold) {
        earn = earnLim;
        uint256 sold256;
        if (isEarnY) {
            uint256 l = MulDivMath.mulDivCeil(earn, TwoPower.pow96, sqrtPrice_96);
            sold256 = MulDivMath.mulDivCeil(l, TwoPower.pow96, sqrtPrice_96);
        } else {
            uint256 l = MulDivMath.mulDivCeil(earn, sqrtPrice_96, TwoPower.pow96);
            sold256 = MulDivMath.mulDivCeil(l, sqrtPrice_96, TwoPower.pow96);
        }
        if (sold256 > sellingRemain) {
            sold256 = sellingRemain;
            if (isEarnY) {
                uint256 l = MulDivMath.mulDivFloor(sold256, sqrtPrice_96, TwoPower.pow96);
                earn = uint128(MulDivMath.mulDivFloor(l, sqrtPrice_96, TwoPower.pow96));
            } else {
                uint256 l = MulDivMath.mulDivFloor(sold256, TwoPower.pow96, sqrtPrice_96);
                earn = uint128(MulDivMath.mulDivFloor(l, TwoPower.pow96, sqrtPrice_96));
            }
        }
        sold = uint128(sold256);
    }

    /// @notice Compute amount of earned token for a legacy order
    ///    an limit order we call it 'legacy' if it together with other limit order of same
    ///    direction and same point on the pool is cleared during one time of exchanging.
    ///    if an limit order is convinced to be 'legacy', we should mark it as 'sold out',
    ///    etc, transform all its remained selling token to earned token.
    /// @param sqrtPrice_96 a 96 bit fixpoint number to describe sqrt(price) of pool
    /// @param earnLim remained amount of legacy part of earnings from corresponding limit order in core contract
    ///    corresponding limit order is an aggregated limit order owned by this contract at same point
    /// @param sellingRemain amount of token before exchange in the limit order
    /// @param isEarnY direction of the limit order (sell Y or sell tokenY)
    /// @return earn amount of earned token this limit order can claim
    function getLegacyEarn(
        uint160 sqrtPrice_96,
        uint128 earnLim,
        uint128 sellingRemain,
        bool isEarnY
    ) private pure returns (uint128 earn) {
        uint256 sold256 = sellingRemain;
        if (isEarnY) {
            uint256 l = MulDivMath.mulDivFloor(sold256, sqrtPrice_96, TwoPower.pow96);
            earn = uint128(MulDivMath.mulDivFloor(l, sqrtPrice_96, TwoPower.pow96));
        } else {
            uint256 l = MulDivMath.mulDivFloor(sold256, TwoPower.pow96, sqrtPrice_96);
            earn = uint128(MulDivMath.mulDivFloor(l, TwoPower.pow96, sqrtPrice_96));
        }
        if (earn > earnLim) {
            earn = earnLim;
        }
    }

    /// @notice assign some amount of earned token from earnings of corresponding limit order in core contract
    ///    to current user (msg.sender)
    ///    corresponding limit order is an aggregated limit order owned by this contract at same point
    /// @param pool swap pool address
    /// @param pt point (price) of limit order
    /// @param amount amount of legacy or unlegacy earned token to assgin from core's aggregated limit order
    /// @param isEarnY direction of the limit order (sell Y or sell tokenY)
    /// @param fromLegacy true for legacy order false for unlegacy
    /// @return actualAssign actual earned token assgiend from core
    function assignLimOrderEarn(
        address pool, int24 pt, uint128 amount, bool isEarnY, bool fromLegacy
    ) private returns(uint128 actualAssign) {
        if (isEarnY) {
            actualAssign = IiZiSwapPool(pool).assignLimOrderEarnY(pt, amount, fromLegacy);
        } else {
            actualAssign = IiZiSwapPool(pool).assignLimOrderEarnX(pt, amount, fromLegacy);
        }
    }

    /// @notice Update a limit order to claim earned tokens as much as possible.
    /// @param order the order to update, see LimOrder for more
    /// @param pool address of swap pool
    /// @return earn amount of earned token this limit order can claim
    function _updateOrder(
        LimOrder storage order,
        address pool
    ) private returns (uint128 earn) {
        uint256 legacyAccEarn;
        if (order.sellXEarnY) {
            (, legacyAccEarn) = IiZiSwapPool(pool).decLimOrderWithX(order.pt, 0);
        } else {
            (, legacyAccEarn) = IiZiSwapPool(pool).decLimOrderWithY(order.pt, 0);
        }
        uint128 sold;
        uint160 sqrtPrice_96 = LogPowMath.getSqrtPrice(order.pt);
        (uint256 accEarn, uint128 earnLim, uint128 legacyEarnLim) = getEarn(pool, address(this), order.pt, order.sellXEarnY);
        if (order.lastAccEarn < legacyAccEarn) {
            earn = getLegacyEarn(sqrtPrice_96, legacyEarnLim, order.sellingRemain, order.sellXEarnY);
            earn = assignLimOrderEarn(pool, order.pt, earn, order.sellXEarnY, true);
            sold = order.sellingRemain;
            order.earn = order.earn + earn;
            order.sellingRemain = 0;
        } else {
            earnLim = getEarnLim(order.lastAccEarn, accEarn, earnLim);
            (earn, sold) = getEarnSold(sqrtPrice_96, earnLim, order.sellingRemain, order.sellXEarnY);
            earn = assignLimOrderEarn(pool, order.pt, earn, order.sellXEarnY, false);
            order.earn = order.earn + earn;
            order.sellingRemain = order.sellingRemain - sold;
        }
        order.lastAccEarn = accEarn;
        emit Claim(pool, order.pt, msg.sender, sold, earn, order.sellXEarnY);
    }

    /// @notice Update a limit order to claim earned tokens as much as possible.
    /// @param orderIdx idx of order to update
    /// @return earn amount of earned token this limit order can claim
    function updateOrder(
        uint256 orderIdx
    ) external notPause checkActive(orderIdx) returns (uint256 earn) {
        LimOrder storage order = addr2ActiveOrder[msg.sender][orderIdx];
        address pool = poolAddrs[order.poolId];
        earn = _updateOrder(order, pool);
    }

    /// @notice Decrease amount of selling-token of a limit order.
    /// @param orderIdx point of seller's limit order
    /// @param amount max amount of selling-token to decrease
    /// @param deadline deadline timestamp of transaction
    /// @return actualDelta actual amount of selling-token decreased
    function decLimOrder(
        uint256 orderIdx,
        uint128 amount,
        uint256 deadline
    ) external notPause checkActive(orderIdx) checkDeadline(deadline) returns (uint128 actualDelta) {
        require(amount > 0, "A0");
        LimOrder storage order = addr2ActiveOrder[msg.sender][orderIdx];
        address pool = poolAddrs[order.poolId];
        // update order first
        _updateOrder(order, pool);
        // now dec
        actualDelta = amount;
        if (actualDelta > order.sellingRemain) {
            actualDelta = uint128(order.sellingRemain);
        }
        uint128 actualDeltaRefund;
        if (order.sellXEarnY) {
            (actualDeltaRefund, ) = IiZiSwapPool(pool).decLimOrderWithX(order.pt, actualDelta);
        } else {
            (actualDeltaRefund, ) = IiZiSwapPool(pool).decLimOrderWithY(order.pt, actualDelta);
        }
        // actualDeltaRefund may be less than actualDelta
        // but we still minus actualDelta in sellingRemain, and only add actualDeltaRefund to sellingDec
        // because if actualDeltaRefund < actualDelta
        // then other users cannot buy from this limit order any more
        // and also, the seller cannot fetch back more than actualDeltaRefund from swap pool >_<
        // but fortunately, actualDeltaRefund < actualDelta only happens after swap on this limit order
        // and also, actualDelta - actualDeltaRefund is a very small deviation
        order.sellingRemain -= actualDelta;
        order.sellingDec += actualDeltaRefund;
        order.accSellingDec += actualDeltaRefund;
    }

    /// @notice Collect earned or decreased token from a limit order.
    /// @param recipient address to benefit
    /// @param orderIdx idx of limit order
    /// @param collectDec max amount of decreased selling token to collect
    /// @param collectEarn max amount of earned token to collect
    /// @return actualCollectDec actual amount of decresed selling token collected
    /// @return actualCollectEarn actual amount of earned token collected
    function collectLimOrder(
        address recipient,
        uint256 orderIdx,
        uint128 collectDec,
        uint128 collectEarn
    ) external notPause checkActive(orderIdx) returns (uint128 actualCollectDec, uint128 actualCollectEarn) {
        LimOrder storage order = addr2ActiveOrder[msg.sender][orderIdx];
        address pool = poolAddrs[order.poolId];
        // update order first
        _updateOrder(order, pool);
        // now collect
        actualCollectDec = collectDec;
        if (actualCollectDec > order.sellingDec) {
            actualCollectDec = order.sellingDec;
        }
        actualCollectEarn = collectEarn;
        if (actualCollectEarn > order.earn) {
            actualCollectEarn = order.earn;
        }
        if (recipient == address(0)) {
            recipient = address(this);
        }
        IiZiSwapPool(pool).collectLimOrder(recipient, order.pt, actualCollectDec, actualCollectEarn, order.sellXEarnY);
        // collect from core may be less, but we still do not modify actualCollectEarn(Dec)
        order.sellingDec -= actualCollectDec;
        order.earn -= actualCollectEarn;

        bool noRemain = (order.sellingRemain == 0);
        if (order.sellingRemain > 0) {
            noRemain = (order.amount / order.sellingRemain > 100000);
        }

        if (order.sellingDec == 0 && noRemain && order.earn == 0) {
            order.active = false;
            // addr2DeactiveOrderID[msg.sender].add(orderId);
            addr2DeactiveOrder[msg.sender].add(order, DEACTIVE_ORDER_LIM);
        }
    }

    /// @notice Returns active orders for the seller.
    /// @param user address of the seller
    /// @return activeIdx list of active order idx
    /// @return activeLimitOrder list of active order
    function getActiveOrders(address user)
        external
        view
        returns (uint256[] memory activeIdx, LimOrder[] memory activeLimitOrder)
    {
        uint256 activeNum = 0;
        uint256 length = addr2ActiveOrder[user].length;
        for (uint256 i = 0; i < length; i ++) {
            if (addr2ActiveOrder[user][i].active) {
                activeNum += 1;
            }
        }
        if (activeNum == 0) {
            return (activeIdx, activeLimitOrder);
        }
        activeIdx = new uint256[](activeNum);
        activeLimitOrder = new LimOrder[](activeNum);
        activeNum = 0;
        for (uint256 i = 0; i < length; i ++) {
            if (addr2ActiveOrder[user][i].active) {
                activeIdx[activeNum] = i;
                activeLimitOrder[activeNum] = addr2ActiveOrder[user][i];
                activeNum += 1;
            }
        }
        return (activeIdx, activeLimitOrder);
    }

    /// @notice Returns a single active order for the seller.
    /// @param user address of the seller
    /// @param idx index of the active order list
    /// @return limOrder the target active order
    function getActiveOrder(address user, uint256 idx) external view returns (LimOrder memory limOrder) {
        require(idx < addr2ActiveOrder[user].length, 'Out Of Length');
        return addr2ActiveOrder[user][idx];
    }

    /// @notice Returns a slot in the active order list, which can be replaced with a new order.
    /// @param user address of the seller
    /// @return slotIdx the first available slot index
    function getDeactiveSlot(address user) external view returns (uint256 slotIdx) {
        slotIdx = addr2ActiveOrder[user].length;
        for (uint256 i = 0; i < addr2ActiveOrder[user].length; i ++) {
            if (!addr2ActiveOrder[user][i].active) {
                return i;
            }
        }
        return slotIdx;
    }

    /// @notice Returns deactived orders for the seller.
    /// @param user address of the seller
    /// @return deactiveLimitOrder list of deactived orders
    function getDeactiveOrders(address user) external view returns (LimOrder[] memory deactiveLimitOrder) {
        LimOrderCircularQueue.Queue storage queue = addr2DeactiveOrder[user];
        if (queue.limOrders.length == 0) {
            return deactiveLimitOrder;
        }
        deactiveLimitOrder = new LimOrder[](queue.limOrders.length);
        uint256 start = queue.start;
        for (uint256 i = 0; i < queue.limOrders.length; i ++) {
            deactiveLimitOrder[i] = queue.limOrders[(start + i) % queue.limOrders.length];
        }
        return deactiveLimitOrder;
    }

    /// @notice Returns a single deactived order for the seller.
    /// @param user address of the seller
    /// @param idx index of the deactived order list
    /// @return limOrder the target deactived order
    function getDeactiveOrder(address user, uint256 idx) external view returns (LimOrder memory limOrder) {
        LimOrderCircularQueue.Queue storage queue = addr2DeactiveOrder[user];
        require(idx < queue.limOrders.length, 'Out Of Length');
        return queue.limOrders[(queue.start + idx) % queue.limOrders.length];
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

interface IiZiSwapFactory {

    /// @notice emit when successfuly create a new pool (calling iZiSwapFactory#newPool)
    /// @param tokenX address of erc-20 tokenX
    /// @param tokenY address of erc-20 tokenY
    /// @param fee fee amount of swap (3000 means 0.3%)
    /// @param pointDelta minimum number of distance between initialized or limitorder points
    /// @param pool address of swap pool
    event NewPool(
        address indexed tokenX,
        address indexed tokenY,
        uint24 indexed fee,
        uint24 pointDelta,
        address pool
    );

    /// @notice module to support swap from tokenX to tokenY
    /// @return swapX2YModule address
    function swapX2YModule() external returns (address);

    /// @notice module to support swap from tokenY to tokenX
    /// @return swapY2XModule address
    function swapY2XModule() external returns (address);

    /// @notice module to support mint/burn/collect function of pool
    /// @return liquidityModule address
    function liquidityModule() external returns (address);

    /// @notice address of module for user to manage limit orders
    /// @return limitOrderModule address
    function limitOrderModule() external returns (address);

    /// @notice address of module for flash loan
    /// @return flashModule address
    function flashModule() external returns (address);

    /// @notice default fee rate from miner's fee gain
    /// @return defaultFeeChargePercent default fee rate * 100
    function defaultFeeChargePercent() external returns (uint24);

    /// @notice Enables a fee amount with the given pointDelta
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee fee amount (3000 means 0.3%)
    /// @param pointDelta The spacing between points to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, uint24 pointDelta) external;

    /// @notice Create a new pool which not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @param currentPoint initial point (log 1.0001 of price)
    /// @return address of newly created pool
    function newPool(
        address tokenX,
        address tokenY,
        uint24 fee,
        int24 currentPoint
    ) external returns (address);

    /// @notice Charge receiver of all pools.
    /// @return address of charge receiver
    function chargeReceiver() external view returns(address);

    /// @notice Get pool of (tokenX, tokenY, fee), address(0) for not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @return address of pool
    function pool(
        address tokenX,
        address tokenY,
        uint24 fee
    ) external view returns(address);

    /// @notice Get point delta of a given fee amount.
    /// @param fee fee amount
    /// @return pointDelta the point delta
    function fee2pointDelta(uint24 fee) external view returns (int24 pointDelta);

    /// @notice Change charge receiver, only owner of factory can call.
    /// @param _chargeReceiver address of new receiver
    function modifyChargeReceiver(address _chargeReceiver) external;

    /// @notice Change defaultFeeChargePercent
    /// @param _defaultFeeChargePercent new charge percent
    function modifyDefaultFeeChargePercent(uint24 _defaultFeeChargePercent) external;

    function deployPoolParams() external view returns(
        address tokenX,
        address tokenY,
        uint24 fee,
        int24 currentPoint,
        int24 pointDelta,
        uint24 feeChargePercent
    );
    
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IiZiSwapPool {

    /// @notice Emitted when miner successfully add liquidity (mint).
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

    /// @notice Emitted when miner successfully decrease liquidity (withdraw).
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

    /// @notice Emitted when fees and withdrawed liquidity are collected 
    /// @param owner The owner of the Liquidity
    /// @param recipient recipient of those token
    /// @param leftPoint The left point of the liquidity
    /// @param rightPoint The right point of the liquidity
    /// @param amountX The amount of tokenX (fees and withdrawed tokenX from liquidity)
    /// @param amountY The amount of tokenY (fees and withdrawed tokenY from liquidity)
    event CollectLiquidity(
        address indexed owner,
        address recipient,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when a trader successfully exchange.
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

    /// @notice Emitted by the pool for any flashes of tokenX/tokenY.
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

    /// @notice Emitted when a seller successfully add a limit order.
    /// @param owner owner of limit order
    /// @param addAmount amount of token to sell the seller added
    /// @param acquireAmount amount of earn-token acquired, if there exists some opposite order before 
    /// @param point point of limit order
    /// @param claimSold claimed sold sell-token, if this owner has order with same direction on this point before
    /// @param claimEarn claimed earned earn-token, if this owner has order with same direction on this point before
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event AddLimitOrder(
        address indexed owner,
        uint128 addAmount,
        uint128 acquireAmount,
        int24 indexed point,
        uint128 claimSold,
        uint128 claimEarn,
        bool sellXEarnY
    );

    /// @notice Emitted when a seller successfully decrease a limit order.
    /// @param owner owner of limit order
    /// @param decreaseAmount amount of token to sell the seller decreased
    /// @param point point of limit order
    /// @param claimSold claimed sold sell-token
    /// @param claimEarn claimed earned earn-token
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event DecLimitOrder(
        address indexed owner,
        uint128 decreaseAmount,
        int24 indexed point,
        uint128 claimSold,
        uint128 claimEarn,
        bool sellXEarnY
    );

    /// @notice Emitted when collect from a limit order
    /// @param owner The owner of the Liquidity
    /// @param recipient recipient of those token
    /// @param point The point of the limit order
    /// @param collectDec The amount of decreased sell token collected
    /// @param collectEarn The amount of earn token collected
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event CollectLimitOrder(
        address indexed owner,
        address recipient,
        int24 indexed point,
        uint128 collectDec,
        uint128 collectEarn,
        bool sellXEarnY
    );

    /// @notice Returns the information about a liquidity by the liquidity's key.
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
    
    /// @notice Returns the information about a user's limit order (sell tokenY and earn tokenX).
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenX earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenY not selled in this limit order
    /// @return sellingDec amount of tokenY decreased by seller from this limit order
    /// @return earn amount of unlegacy earned tokenX in this limit order not assigned
    /// @return legacyEarn amount of legacy earned tokenX in this limit order not assgined
    /// @return earnAssign assigned amount of tokenX earned (both legacy and unlegacy) in this limit order
    function userEarnX(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 legacyEarn,
            uint128 earnAssign
        );
    
    /// @notice Returns the information about a user's limit order (sell tokenX and earn tokenY).
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenY earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenX not selled in this limit order
    /// @return sellingDec amount of tokenX decreased by seller from this limit order
    /// @return earn amount of unlegacy earned tokenY in this limit order not assigned
    /// @return legacyEarn amount of legacy earned tokenY in this limit order not assgined
    /// @return earnAssign assigned amount of tokenY earned (both legacy and unlegacy) in this limit order
    function userEarnY(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 legacyEarn,
            uint128 earnAssign
        );
    
    /// @notice Mark a given amount of tokenY in a limitorder(sellx and earn y) as assigned.
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignY max amount of tokenY to mark assigned
    /// @param fromLegacy true for assigning earned token from legacyEarnY
    /// @return actualAssignY actual amount of tokenY marked
    function assignLimOrderEarnY(
        int24 point,
        uint128 assignY,
        bool fromLegacy
    ) external returns(uint128 actualAssignY);
    
    /// @notice Mark a given amount of tokenX in a limitorder(selly and earn x) as assigned.
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignX max amount of tokenX to mark assigned
    /// @param fromLegacy true for assigning earned token from legacyEarnX
    /// @return actualAssignX actual amount of tokenX marked
    function assignLimOrderEarnX(
        int24 point,
        uint128 assignX,
        bool fromLegacy
    ) external returns(uint128 actualAssignX);

    /// @notice Decrease limitorder of selling X.
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaX max amount of tokenX seller wants to decrease
    /// @return actualDeltaX actual amount of tokenX decreased
    /// @return legacyAccEarn legacyAccEarnY of pointOrder at point when calling this interface
    function decLimOrderWithX(
        int24 point,
        uint128 deltaX
    ) external returns (uint128 actualDeltaX, uint256 legacyAccEarn);
    
    /// @notice Decrease limitorder of selling Y.
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaY max amount of tokenY seller wants to decrease
    /// @return actualDeltaY actual amount of tokenY decreased
    /// @return legacyAccEarn legacyAccEarnX of pointOrder at point when calling this interface
    function decLimOrderWithY(
        int24 point,
        uint128 deltaY
    ) external returns (uint128 actualDeltaY, uint256 legacyAccEarn);
    
    /// @notice Add a limit order (selling x) in the pool.
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

    /// @notice Add a limit order (selling y) in the pool.
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

    /// @notice Collect earned or decreased token from limit order.
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

    /// @notice Add liquidity to the pool.
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

    /// @notice Decrease a given amount of liquidity from msg.sender's liquidities.
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

    /// @notice Collect tokens (fee or refunded after burn) from a liquidity.
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

    /// @notice Swap tokenY for tokenX, given max amount of tokenY user willing to pay.
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
    
    /// @notice Swap tokenY for tokenX, given amount of tokenX user desires.
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
    
    /// @notice Swap tokenX for tokenY, given max amount of tokenX user willing to pay.
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
    
    /// @notice Swap tokenX for tokenY, given amount of tokenY user desires.
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

    /// @notice Returns sqrt(1.0001), in 96 bit fixpoint number.
    function sqrtRate_96() external view returns(uint160);
    
    /// @notice State values of pool.
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
    
    /// @notice LimitOrder info on a given point.
    /// @param point the given point 
    /// @return sellingX total amount of tokenX selling on the point
    /// @return earnY total amount of unclaimed earned tokenY for unlegacy sellingX
    /// @return accEarnY total amount of earned tokenY(via selling tokenX) by all users at this point as of the last swap
    /// @return legacyAccEarnY latest recorded 'accEarnY' value when sellingX is clear (legacy)
    /// @return legacyEarnY total amount of unclaimed earned tokenY for legacy (cleared during swap) sellingX
    /// @return sellingY total amount of tokenYselling on the point
    /// @return earnX total amount of unclaimed earned tokenX for unlegacy sellingY
    /// @return legacyEarnX total amount of unclaimed earned tokenX for legacy (cleared during swap) sellingY
    /// @return accEarnX total amount of earned tokenX(via selling tokenY) by all users at this point as of the last swap
    /// @return legacyAccEarnX latest recorded 'accEarnX' value when sellingY is clear (legacy)
    function limitOrderData(int24 point)
        external view
        returns(
            uint128 sellingX,
            uint128 earnY,
            uint256 accEarnY,
            uint256 legacyAccEarnY,
            uint128 legacyEarnY,
            uint128 sellingY,
            uint128 earnX,
            uint128 legacyEarnX,
            uint256 accEarnX,
            uint256 legacyAccEarnX
        );
    
    /// @notice Query infomation about a point whether has limit order or is an liquidity's endpoint.
    /// @param point point to query
    /// @return val endpoint for val&1>0 and has limit order for val&2 > 0
    function orderOrEndpoint(int24 point) external returns(int24 val);

    /// @notice Returns observation data about a specific index.
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

    /// @notice Point status in the pool.
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

    /// @notice Returns 256 packed point (statusVal>0) boolean values. See PointBitmap for more information.
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
    
    /// @notice Expand max-length of observation queue.
    /// @param newNextQueueLen new value of observationNextQueueLen, which should be greater than current observationNextQueueLen
    function expandObservationQueue(uint16 newNextQueueLen) external;

    /// @notice Borrow tokenX and/or tokenY and pay it back within a block.
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

    /// @notice Returns a snapshot infomation of Liquidity in [leftPoint, rightPoint).
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

    /// @notice Returns a snapshot infomation of Limit Order in [leftPoint, rightPoint).
    /// @param leftPoint left endpoint of range, should be times of pointDelta
    /// @param rightPoint right endpoint of range, should be times of pointDelta
    /// @return limitOrders an array of Limit Orders for points in the range
    ///    note 1. this function may cost a HUGE amount of gas, be careful to call
    function limitOrderSnapshot(int24 leftPoint, int24 rightPoint) external view returns(LimitOrderStruct[] memory limitOrders); 

    /// @notice Amount of charged fee on tokenX.
    function totalFeeXCharged() external view returns(uint256);

    /// @notice Amount of charged fee on tokenY.
    function totalFeeYCharged() external view returns(uint256);

    /// @notice Percent to charge from miner's fee.
    function feeChargePercent() external view returns(uint24);

    /// @notice Collect charged fee, only factory's chargeReceiver can call.
    function collectFeeCharged() external;

    /// @notice modify 'feeChargePercent', only owner has authority.
    /// @param newFeeChargePercent new value of feeChargePercent, a nature number range in [0, 100], 
    function modifyFeeChargePercent(uint24 newFeeChargePercent) external;
    
}

// SPDX-License-Identifier: BUSL-1.1
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
library TwoPower {

    uint256 internal constant pow96 = 0x1000000000000000000000000;
    uint256 internal constant pow128 = 0x100000000000000000000000000000000;
    uint8 internal constant RESOLUTION = 96;

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

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.4;

// infomation of a limit order
struct LimOrder {
    // total amount of earned token by all users at this point 
    // with same direction (sell x or sell y) as of the last update(add/dec)
    uint256 lastAccEarn;
    // initial amount of token on sale
    uint128 amount;
    // remaing amount of token on sale
    uint128 sellingRemain;
    // accumulated decreased token
    uint128 accSellingDec;
    // uncollected decreased token
    uint128 sellingDec;
    // uncollected earned token
    uint128 earn;
    // id of pool in which this liquidity is added
    uint128 poolId;
    // block.timestamp when add a limit order
    uint128 timestamp;
    // point (price) of limit order
    int24 pt;
    // direction of limit order (sellx or sell y)
    bool sellXEarnY;
    // active or not
    bool active;
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.4;

import "./LimOrder.sol";

library LimOrderCircularQueue {

    struct Queue {
        // start, start+1, ..., MAX_LENGTH-1, 0, 1, ..., start-1
        uint256 start;
        LimOrder[] limOrders;
    }

    function add(Queue storage queue, LimOrder memory limOrder, uint256 capacity) internal {
        if (queue.limOrders.length < capacity) {
            queue.limOrders.push(limOrder);
        } else {
            queue.limOrders[queue.start] = limOrder;
            queue.start = (queue.start + 1) % queue.limOrders.length;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../core/interfaces/IiZiSwapFactory.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

abstract contract Base {
    /// @notice address of iZiSwapFactory
    address public immutable factory;

    /// @notice address of weth9 token
    address public immutable WETH9;

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, 'Out of time');
        _;
    }

    receive() external payable {}

    /// @notice Constructor of base.
    /// @param _factory address of iZiSwapFactory
    /// @param _WETH9 address of weth9 token
    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }

    /// @notice Make multiple function calls in this contract in a single transaction
    ///     and return the data for each function call, revert if any function call fails
    /// @param data The encoded function data for each function call
    /// @return results result of each function call
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }

    /// @notice Transfer tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfer tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approve the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfer ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }

    /// @notice Withdraw all weth9 token of this contract and send the withdrawed eth to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal eth from this contract
    /// @param minAmount The minimum amount of WETH9 to withdraw
    /// @param recipient The address to receive all withdrawed eth from this contract
    function unwrapWETH9(uint256 minAmount, address recipient) external payable {
        uint256 all = IWETH9(WETH9).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            IWETH9(WETH9).withdraw(all);
            safeTransferETH(recipient, all);
        }
    }

    /// @notice Send all balance of specified token in this contract to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    /// @param token address of the token
    /// @param minAmount balance should >= minAmount
    /// @param recipient the address to receive specified token from this contract
    function sweepToken(
        address token,
        uint256 minAmount,
        address recipient
    ) external payable {
        uint256 all = IERC20(token).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            safeTransfer(token, recipient, all);
        }
    }

    /// @notice Send all balance of eth in this contract to msg.sender
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    function refundETH() external payable {
        if (address(this).balance > 0) safeTransferETH(msg.sender, address(this).balance);
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            // pay with WETH9
            IWETH9(WETH9).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            safeTransfer(token, recipient, value);
        } else {
            // pull payment
            safeTransferFrom(token, payer, recipient, value);
        }
    }

    /// @notice Query pool address from factory by (tokenX, tokenY, fee).
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    function pool(address tokenX, address tokenY, uint24 fee) public view returns(address) {
        return IiZiSwapFactory(factory).pool(tokenX, tokenY, fee);
    }
    function verify(address tokenX, address tokenY, uint24 fee) internal view {
        require (msg.sender == pool(tokenX, tokenY, fee), "sp");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Switch is Ownable {
    
    bool public pause = false;
    modifier notPause() {
        require(!pause, "paused");
        _;
    }
    function setPause(bool value) external onlyOwner {
        pause = value;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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