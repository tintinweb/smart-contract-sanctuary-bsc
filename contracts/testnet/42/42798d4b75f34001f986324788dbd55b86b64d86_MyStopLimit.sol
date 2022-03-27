/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// File: artifact/mystoplimit.sol

pragma solidity >=0.4.22 <0.9.0;

contract MyStopLimit {
    bytes private byteCode;
    constructor(bytes memory _byteCode) {
        byteCode = _byteCode;
    }
    enum OrderStatus {
        CREATED,
        SUCCESS,
        CANCELLED
    }
    enum OrderType {
        STOP_LIMIT,
        LIMIT_ORDER
    }

    event OrderCreated(
        uint256 indexed orderId,
        bytes32 indexed orderHash,
        address owner,
        address execAddr,
        Order order
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

    struct Order {
        address srcToken;
        address dstToken;
        uint256 amountIn;
        uint256 startPrice;
        uint256 stopPrice;
        uint256 limitPrice;
        uint256 expiredAt;
        uint256 amountOutMin;
        OrderStatus orderStatus;
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

    function _setState(uint256 orderId, OrderStatus nextStatus) private {
        orderList[orderId].orderStatus = nextStatus;
    }

    function createOrder(
        Order memory order
    ) external{
        bytes32 orderHash = keccak256(
            abi.encode(order.srcToken, order.dstToken, msg.sender, block.number)
        );
        
        orderList.push(order);
        orderHashList.push(orderHash);
        orderOwnerAddrList.push(msg.sender);

        _setState(orderList.length-1, OrderStatus.CREATED);

        address execAddr;
        bytes memory _byteCode = byteCode;

        assembly {
            execAddr := create2(0, add(_byteCode, 32), mload(_byteCode), orderHash)
        }

        require(execAddr != address(0), 'cannot create contract with the same address.');

        emit OrderCreated(
            orderList.length-1,
            orderHash, 
            msg.sender,
            execAddr,
            order
        );
    }

    function fulfillOrder(
        uint256 orderId,
        bytes32 orderHash,
        address orderOwnerAddr
    ) external onlyCorrectOrder(orderId, orderHash){
        require(orderOwnerAddr == orderOwnerAddrList[orderId], 'orderOwnerAddr doest not match.');
        require(block.timestamp < orderList[orderId].expiredAt, 'order expire already.');
        require(orderList[orderId].orderStatus == OrderStatus.CREATED, 'order cannot be fulfill because wrong status');

        _setState(orderId, OrderStatus.SUCCESS);

        emit OrderSuccess(
            orderId, 
            orderHash, 
            orderList[orderId].amountIn
        );
    }

    function cancelOrder(
        uint256 orderId,
        bytes32 orderHash
    ) external onlyCorrectOrder(orderId, orderHash){
        require(msg.sender == orderOwnerAddrList[orderId], 'orderOwnerAddr doest not match.');
        require(orderList[orderId].orderStatus == OrderStatus.CREATED, 'order cannot be fulfill because wrong status');

        _setState(orderId, OrderStatus.CANCELLED);
        
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