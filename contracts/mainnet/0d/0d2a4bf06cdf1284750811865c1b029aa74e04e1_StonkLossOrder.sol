// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IBEP20.sol";
import "./IWBNB.sol";
import "./Pancakeswap.sol";
import "./IStonkFees.sol";
import "./Constants.sol";

/**
 *
 * STONKS
 *
 * Coin: 0x52fd0db7597c332c0d3449a35f03625d881c3117
 *
 * App: https://app.stonks.cash
 *
 * Website: https://stonks.cash
 *
 * Telegram: https://t.me/stonksCoinBsc
 *
 * Created by: https://github.com/fryzjerr
 */
contract StonkLossOrder is Ownable {
    string public name = "StonkLoss";

    enum OrderType {BNB_TOKEN, TOKEN_TOKEN, TOKEN_BNB}
    enum LimitType {STOP_LOSS, TAKE_PROFIT}

    struct Order {
        uint256 id;                 // Order ID
        address owner;              // Order placer
        OrderType orderType;        // Order type
        LimitType limitType;        // Limit type
        address tokenIn;            // Token to swap
        address tokenOut;           // Token to swap for
        address pair;               // PancakeswapPair
        uint256 amountIn;           // Amount in
        uint256 targetAmountOut;    // Price to trigger order at
        uint256 minAmountOut;       // Max price to trigger order at (in case price changed before tx has been mined)
        uint256 feePaid;
        uint256 expiry;
    }

    address public pancakeFactory;

    mapping(uint256 => Order) public orders;

    IStonkFees stonkFees;

    constructor(address stonkFeesAddress) {
        pancakeFactory = Constants.pancakeRouter().factory();
        stonkFees = IStonkFees(stonkFeesAddress);
    }


    bool internal entered = false;

    modifier reentrancyGuard() {
        require(!entered, "Reentrancy Disallowed");
        entered = true;
        _;
        entered = false;
    }


    function getStonkFeesAddress() external view returns (address) {
        return address(stonkFees);
    }

    function pairFor(address tokenA, address tokenB) external view returns (address) {
        return PancakeLibrary.pairFor(pancakeFactory, tokenA, tokenB);
    }

    function changeStonkFeesAddress(address newAddress) external onlyOwner {
        stonkFees = IStonkFees(newAddress);
    }


    /*
     *   Places an order with BNB transferred to the contract
     *   Called from frontend app as user's wallet address
     *   @param orderID must be the ID of the order returned by the backend
     *
     *   WARNING! This function takes fees from the amount that was transferred to it,
     *            Hence the amount should be respectively higher.
    */
    function placeBNBTokenOrder(
        uint256 orderID,
        bool stopLoss, //otherwise TP
        address tokenOut,
        uint256 targetAmountOut,
        uint256 minAmountOut,
        uint256 expiry
    ) external payable {

        uint256 fee = stonkFees.computeFee(msg.value);
        uint amountIn = msg.value - fee;

        stonkFees.depositFee{value : fee}(fee);

        LimitType limitType = stopLoss ? LimitType.STOP_LOSS : LimitType.TAKE_PROFIT;

        createOrder(orderID, OrderType.BNB_TOKEN, limitType, Constants.WBNB(), tokenOut, amountIn, targetAmountOut, minAmountOut, fee, expiry);
    }

    /*
     *    Places an order for given amount of token
     *    Called from frontend app as user's wallet address
     *    Msg.value is the fee and it has to be no less than fee from stonkFees
     *    @param orderID must be the ID of the order returned by the backend
    */
    function placeTokenTokenOrder(
        uint256 orderID,
        bool stopLoss, //otherwise TP
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 targetAmountOut,
        uint256 minAmountOut,
        uint256 expiry
    ) external payable {
        uint256 amountBNB = getCurrentAmountOut(amountIn, tokenIn, Constants.WBNB());

        require(IBEP20(tokenIn).allowance(msg.sender, address(this)) >= amountIn, "Not enough allowance for order");

        require(msg.value >= stonkFees.computeFee(amountBNB), "Not enough allowance for order");
        stonkFees.depositFee{value : msg.value}(msg.value);

        LimitType limitType = stopLoss ? LimitType.STOP_LOSS : LimitType.TAKE_PROFIT;

        createOrder(orderID, OrderType.TOKEN_BNB, limitType, tokenIn, tokenOut, amountIn, targetAmountOut, minAmountOut, msg.value, expiry);
    }

    /*
     *    Places an order for given amount of token
     *    Called from frontend app as user's wallet address
     *    Msg.value is the fee and it has to be no less than fee from stonkFees
     *    @param orderID must be the ID of the order returned by the backend
    */
    function placeTokenBNBOrder(
        uint256 orderID,
        bool stopLoss, //otherwise TP
        address tokenIn,
        uint256 amountIn,
        uint256 targetAmountOut,
        uint256 minAmountOut,
        uint256 expiry
    ) external payable {
        uint256 amountBNB = getCurrentAmountOut(amountIn, tokenIn, Constants.WBNB());

        require(IBEP20(tokenIn).allowance(msg.sender, address(this)) >= amountIn, "Not enough allowance for order");

        require(msg.value >= stonkFees.computeFee(amountBNB), "Not enough allowance for order");
        stonkFees.depositFee{value : msg.value}(msg.value);

        LimitType limitType = stopLoss ? LimitType.STOP_LOSS : LimitType.TAKE_PROFIT;

        createOrder(orderID, OrderType.TOKEN_BNB, limitType, tokenIn, Constants.WBNB(), amountIn, targetAmountOut, minAmountOut, msg.value, expiry);
    }

    /**
    *   Get order with given ID
    */
    function getOrder(uint256 orderID) external view returns(Order memory) {
        return orders[orderID];
    }

    /**
    *   Checks if an order with given ID exists
    */
    function orderExists(uint256 orderID) external view returns(bool) {
        return orders[orderID].id != 0;
    }

    /**
    *   Checks if orders with given IDs exist
    */
    function ordersExist(uint[] calldata orderIDs) external view returns(bool[] memory response) {
        response = new bool[](orderIDs.length);

        for (uint i = 0; i < orderIDs.length; i++) {
            response[i] = orders[orderIDs[i]].id != 0;
        }

        return response;
    }

    /*
     *  Creates an order to store it until the execution comes.
     */
    function createOrder(
        uint256 orderID,
        OrderType orderType,
        LimitType limitType,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 targetAmountOut,
        uint256 minAmountOut,
        uint256 feePaid,
        uint256 expiry
    ) internal {

        require(orders[orderID].amountIn == 0, "This order already exists!");

        address pair = IPancakeFactory(pancakeFactory).getPair(tokenIn, tokenOut);
        require(pair != address(0), "Pancakeswap pair does not exist");

        require(minAmountOut <= targetAmountOut, "Invalid output amounts");

        if (orders[orderID].id != 0) {
            require(orders[orderID].owner == msg.sender, "This is not your order!");
        }

        orders[orderID] = Order(
            orderID,
            msg.sender,
            orderType,
            limitType,
            tokenIn,
            tokenOut,
            pair,
            amountIn,
            targetAmountOut,
            minAmountOut,
            feePaid,
            expiry
        );

        emit OrderPlaced(orderID, msg.sender, amountIn, tokenIn, tokenOut, targetAmountOut, minAmountOut);
    }

    function cancelOrder(uint256 orderID) external {
        Order memory order = orders[orderID];

        // require caller to be authorized & order be pending
        require(
            msg.sender == order.owner,
            "You are not authorized to cancel this order."
        );

        cancelOrderInternal(order);
    }

    function cancelOrderInternal(Order memory order) internal {
        if (order.orderType == OrderType.BNB_TOKEN) {
            payable(order.owner).transfer(order.amountIn);
        }

        closeOrder(order.id);

        emit OrderCancelled(order.id);
    }

    function closeOrder(uint256 orderID) internal {
        orders[orderID].id = 0;
        orders[orderID].amountIn = 0;
        orders[orderID].owner = address(0x0000000000000000000000000000000000000000);
        orders[orderID].feePaid = 0;
    }

    /*
    *   Fulfils order at current price (with targetAmountOut check)
    */
    function fulfilOrder(uint256 orderID) public reentrancyGuard returns (bool filled) {
        Order memory order = orders[orderID];

        uint currentAmountOut = getCurrentAmountOut(orderID);

        if (order.minAmountOut > currentAmountOut) {
            emit OrderConditionsNotMet(orderID, "minAmountOut");
            return false;   // Min amount out is not met!
        }

        if (order.limitType == LimitType.STOP_LOSS) {
            if (order.targetAmountOut < currentAmountOut) {
                emit OrderConditionsNotMet(orderID, "targetAmountOut");
                return false; // Target amount out is not met!
            }

        } else {
            if (order.targetAmountOut > currentAmountOut) {
                emit OrderConditionsNotMet(orderID, "targetAmountOut");
                return false; // Target amount out is not met!
            }
        }

        if (order.expiry != 0 && order.expiry < block.timestamp) {
            emit OrderConditionsNotMet(orderID, "expiry");
            return false;
        }

        if (!checkBalanceAndAllowance(order)) {
            emit OrderConditionsNotMet(orderID, "balanceOrAllowance");
            return false;
        }

        makeSwap(order);
        emit OrderFulfilled(orderID, msg.sender);

        return true;
    }

    /*
    *   Fulfils order at current price ignoring the target price of the order
    */
    function fulfilOrderIgnoreTarget(uint256 orderID) public reentrancyGuard returns (bool filled) {
        Order memory order = orders[orderID];

        uint currentAmountOut = getCurrentAmountOut(orderID);
        require(order.minAmountOut <= currentAmountOut, "Min amount out is not met!");

        require(msg.sender == order.owner, "You are not the owner of this order!");

        if (!checkBalanceAndAllowance(order)) {
            return false;
        }

        makeSwap(order);
        emit OrderFulfilled(orderID, msg.sender);

        return true;
    }

    function fulfilMany(uint256[] calldata orderIDs) external {
        for (uint256 i = 0; i < orderIDs.length; i++) {
            if (orders[orderIDs[i]].id != 0) {
                address(this).call(
                    abi.encodePacked(
                        this.fulfilOrder.selector,
                        abi.encode(orderIDs[i])
                    )
                );
            }
            // fulfilOrder(orderIDs[i]);
        }
    }

    function checkBalanceAndAllowance(Order memory order) internal returns (bool){
        if (order.orderType != OrderType.BNB_TOKEN) {
            if (IBEP20(order.tokenIn).balanceOf(order.owner) < order.amountIn) {
                cancelOrderInternal(order);
                return false;
            }

            if (IBEP20(order.tokenIn).allowance(order.owner, address(this)) < order.amountIn) {
                cancelOrderInternal(order);
                return false;
            }
        }

        return true;
    }

    function getCurrentAmountOut(uint256 orderID) public view returns (uint256 amount) {
        Order memory ord = orders[orderID];
        return getCurrentAmountOut(ord.amountIn, ord.tokenIn, ord.tokenOut);
    }

    function getCurrentAmountOut(uint256 amountIn, address tokenIn, address tokenOut) public view returns (uint256 amount) {
        address[] memory tokens = new address[](2);
        tokens[0] = tokenIn;
        tokens[1] = tokenOut;

        return Constants.pancakeRouter().getAmountsOut(amountIn, tokens)[1];
    }

    function makeSwap(Order memory ord) internal {
        if (ord.orderType == OrderType.BNB_TOKEN) {
            makeBNBTokenSwap(
                ord.owner,
                ord.tokenIn,
                ord.tokenOut,
                ord.pair,
                ord.amountIn
            );

        } else if (ord.orderType == OrderType.TOKEN_TOKEN) {
            makeTokenTokenSwap(
                ord.owner,
                ord.tokenIn,
                ord.tokenOut,
                ord.pair,
                ord.amountIn
            );

        } else {    // OrderType.TOKEN_BNB
            makeTokenBNBSwap(
                ord.owner,
                ord.tokenIn,
                ord.tokenOut,
                ord.pair,
                ord.amountIn
            );
        }

        closeOrder(ord.id);
    }

    function makeTokenTokenSwap(address owner, address tokenIn, address tokenOut, address pair, uint256 amountIn) internal {
        if (IBEP20(tokenIn).transferFrom(owner, pair, amountIn)) {
            swap(pair, tokenIn, tokenOut, owner);
        }
    }

    function makeBNBTokenSwap(address owner, address tokenIn, address tokenOut, address pair, uint256 amountIn) internal {
        IWBNB(Constants.WBNB()).deposit{value : amountIn}();

        if (IWBNB(Constants.WBNB()).transfer(pair, amountIn)) {
            swap(pair, tokenIn, tokenOut, owner);
        }
    }

    function makeTokenBNBSwap(address owner, address tokenIn, address tokenOut, address pair, uint256 amountIn) internal {
        if (IBEP20(tokenIn).transferFrom(owner, pair, amountIn)) {
            uint balanceBefore = IBEP20(Constants.WBNB()).balanceOf(address(this));
            swap(pair, tokenIn, tokenOut, address(this));

            uint amountOut = IBEP20(Constants.WBNB()).balanceOf(address(this)) - balanceBefore;

            IWBNB(Constants.WBNB()).withdraw(amountOut);
            TransferHelper.safeTransferETH(owner, amountOut);
        }
    }

    function swap(address _pair, address tokenIn, address tokenOut, address to) internal {
        (address token0,) = PancakeLibrary.sortTokens(tokenIn, tokenOut);
        IPancakePair pair = IPancakePair(_pair);

        uint amountInput;
        uint amountOutput;

        {// scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = tokenIn == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IBEP20(tokenIn).balanceOf(address(pair)) - reserveInput;
            amountOutput = PancakeLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
        }

        (uint amount0Out, uint amount1Out) = tokenIn == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
        pair.swap(amount0Out, amount1Out, to, new bytes(0));
    }

    receive() external payable {}

    event OrderPlaced(uint256 orderID, address owner, uint256 amountIn, address tokenIn, address tokenOut, uint256 targetAmountOut, uint256 minAmountOut);
    event OrderCancelled(uint256 orderID);
    event OrderFulfilled(uint256 orderID, address broker);
    event OrderConditionsNotMet(uint orderID, bytes32 reason);
}