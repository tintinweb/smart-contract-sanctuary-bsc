/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity >=0.4.22 <0.9.0;

interface IArkenDexV3 {
    enum RouterInterface {
        UNISWAP_V2,
        BAKERY,
        VYPER,
        VYPER_UNDERLYING,
        DOPPLE,
        DODO_V2,
        DODO_V1,
        DFYN,
        BALANCER,
        UNISWAP_V3
    }
    struct TradeRoute {
        address routerAddress;
        address lpAddress;
        address fromToken;
        address toToken;
        address from;
        address to;
        uint32 part;
        uint8 direction; 
        int16 fromTokenIndex; 
        int16 toTokenIndex;
        uint16 amountAfterFee; 
        RouterInterface dexInterface; 
    }
    struct TradeDescription {
        address srcToken;
        address dstToken;
        uint256 amountIn;
        uint256 amountOutMin;
        address payable to;
        TradeRoute[] routes;
        bool isRouterSource;
        bool isSourceFee;
    }
}

contract TestSL {
    constructor() {}
    enum OrderStatus {
        CREATED,
        SUCCESS,
        CANCELLED
    }
    enum OrderType {
        STOP_LIMIT,
        LIMIT_ORDER
    }

    enum OrderBuySell {
        BUY,
        SELL
    }

    event OrderCreated(
        uint64 orderId,
        bytes32 orderHash,
        address owner,
        OrderCreatedData orderCreate
    );

    event OrderSuccess(
        uint256 orderId,
        bytes32 orderHash,
        uint256 amountOut
    );

    event OrderCancelled(
        uint256 orderId,
        bytes32 orderHash
    );

    struct OrderCreatedData {
        address srcToken;
        address dstToken;
        uint256 amountIn;
        uint256 startPrice;
        uint256 stopPrice;
        uint256 limitPrice;
        uint256 expiredAt;
        uint256 amountOutMin;
        OrderBuySell orderBuySell;
        OrderType orderType;
    }

    struct Order {
        address srcToken;
        address dstToken;
        uint256 amountIn;
        uint256 startPrice;
        uint256 stopPrice;
        uint256 limitPrice;
        uint256 expiredAt;
        uint256 amountOutMin;
        address execAddr;
        OrderStatus orderStatus;
        OrderBuySell orderBuySell;
        OrderType orderType;
    }

    Order[] private orderList;
    bytes32[] private orderHashList;
    address[] private orderOwnerAddrList;

    modifier onlyCorrectOrder(
        uint256 orderId,
        bytes32 orderHash
    ) {
        require(orderId < orderList.length, 'orderId exceeds total order.');
        require(orderHash == orderHashList[orderId], 'orderHash doest not match.');
        _;
    }


    function getAddress(bytes memory bytecode, uint _salt) private view returns (address){
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );
        return address(uint160(uint(hash)));
    }

    function createOrder(
        address srcToken,
        address dstToken,
        uint256 nonce,
        uint256 amountIn,
        uint256 startPrice,
        uint256 stopPrice,
        uint256 limitPrice,
        uint256 amountOutMin,
        uint256 expiredAt,
        OrderBuySell orderBuySell,
        OrderType orderType
    ) external{
        Order memory order = Order({
            srcToken: srcToken,
            dstToken: dstToken,
            amountIn: amountIn,
            startPrice: startPrice,
            stopPrice: stopPrice,
            limitPrice: limitPrice,
            expiredAt: expiredAt,
            amountOutMin: amountOutMin,
            execAddr: msg.sender,
            orderStatus: OrderStatus.CREATED,
            orderBuySell: orderBuySell, 
            orderType: orderType
        });
        bytes32 orderHash = keccak256(
            abi.encode(order.srcToken, order.dstToken, msg.sender, nonce, block.number)
        );
        
        orderList.push(order);
        orderHashList.push(orderHash);
        orderOwnerAddrList.push(msg.sender);

        bytes memory _byteCode = type(Vault).creationCode;
        uint salt = uint(orderHash);
        address execAddr = getAddress(_byteCode, salt);

        uint256 orderId = orderList.length-1;
        orderList[orderId].execAddr = execAddr;
        orderList[orderId].orderStatus = OrderStatus.CREATED;

        OrderCreatedData memory orderCreated = OrderCreatedData({
            srcToken: orderList[orderId].srcToken,
            dstToken: orderList[orderId].dstToken,
            amountIn: orderList[orderId].amountIn,
            startPrice: orderList[orderId].startPrice,
            stopPrice: orderList[orderId].stopPrice,
            limitPrice: orderList[orderId].limitPrice,
            expiredAt: orderList[orderId].expiredAt,
            amountOutMin: orderList[orderId].amountOutMin,
            orderBuySell: orderList[orderId].orderBuySell,
            orderType: orderList[orderId].orderType
        });

        emit OrderCreated(
            uint64(orderId),
            orderHash, 
            msg.sender,
            orderCreated
        );
    }

    function fulfillOrder(
        uint256 orderId,
        bytes32 orderHash,
        IArkenDexV3.TradeDescription memory desc
    ) external onlyCorrectOrder(orderId, orderHash){
        // require(orderOwnerAddr == orderOwnerAddrList[orderId], 'orderOwnerAddr doest not match.');
        require(block.timestamp < orderList[orderId].expiredAt, 'order expire already.');
        require(orderList[orderId].orderStatus == OrderStatus.CREATED, 'order cannot be fulfill because wrong status.');
        // require(desc.amountOutMin == orderList[orderId].amountOutMin, 'amountOutMin does not match.');
        // require(desc.to == orderOwnerAddrList[orderId], 'orderOwnerAddr doest not match.');

        require(desc.amountOutMin >= 1, 'return amount is not enough');

        address execAddr;
        bytes memory _byteCode = type(Vault).creationCode;
        uint salt = uint(orderHash);
        assembly {
            execAddr := create2(0, add(_byteCode, 32), mload(_byteCode), salt)
        }

        orderList[orderId].orderStatus = OrderStatus.SUCCESS;

        emit OrderSuccess(
            orderId,
            orderHash,
            orderList[orderId].amountIn
        );
    }

    function cancelOrder(
        uint256 orderId,
        bytes32 orderHash
    ) external onlyCorrectOrder(orderId, orderHash) {
        require(msg.sender == orderOwnerAddrList[orderId], 'orderOwnerAddr doest not match.');
        require(orderList[orderId].orderStatus == OrderStatus.CREATED, 'order cannot be cancel because wrong status');

        address execAddr;
        bytes memory _byteCode = type(Vault).creationCode;
        uint salt = uint(orderHash);
        assembly {
            execAddr := create2(0, add(_byteCode, 32), mload(_byteCode), salt)
        }

        orderList[orderId].orderStatus = OrderStatus.CANCELLED;
        
        emit OrderCancelled(
            orderId, 
            orderHash
        );
    }

    function viewOrder(
        uint256 orderId,
        bytes32 orderHash
    ) external view onlyCorrectOrder(orderId, orderHash) returns(Order memory) {
        return orderList[orderId];
    }
}

contract Vault{
    constructor() {
        selfdestruct(payable(address(this)));
    }
}