/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

pragma solidity >=0.4.22 <0.9.0;

contract TestSL {
    constructor() {}
    enum OrderStatus {
        CREATED,
        SUCCESS,
        CANCELLED
    }
    enum OrderType {
        STOP_LIMIT_BUY,
        STOP_LIMIT_SELL,
        LIMIT_ORDER_BUY,
        LIMIT_ORDER_SELL
    }
    event OrderCreated(
        uint256 orderId,
        uint256 nonce,
        address owner,
        address srcToken,
        address dstToken,
        uint256 amountIn,
        uint256 stopPrice,
        uint256 limitPrice,
        uint256 amountOutMin,
        uint64 expiredAt,
        OrderType orderType
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
        bytes32 orderHash;
        OrderStatus orderStatus;
    }

    struct OrderKey {
        uint256 nonce;
        address srcToken;
        address dstToken;
        uint256 amountIn;
        uint256 stopPrice;
        uint256 limitPrice;
        uint256 amountOutMin;
        uint64 expiredAt;
    }

    Order[] private orderList;

    function createOrder(
        OrderKey memory orderKey,
        OrderType orderType
    ) external payable {
        bytes32 orderHash = keccak256(
            abi.encode(orderKey.nonce, msg.sender, orderKey.srcToken, orderKey.dstToken, orderKey.amountIn, orderKey.stopPrice, orderKey.limitPrice, orderKey.amountOutMin, orderKey.expiredAt)
        );

        {
            bytes memory byteCode = type(Vault).creationCode;
            address execAddr = address(uint160(uint(keccak256(
                abi.encodePacked(bytes1(0xff), address(this), orderHash, keccak256(byteCode))
            ))));
            orderList.push(Order(orderHash, OrderStatus.CREATED));
        }

        emit OrderCreated(
            orderList.length-1,
            orderKey.nonce,
            msg.sender,
            orderKey.srcToken,
            orderKey.dstToken,
            orderKey.amountIn,
            orderKey.stopPrice,
            orderKey.limitPrice,
            orderKey.amountOutMin,
            orderKey.expiredAt,
            orderType
        );
    }

    function fulfillOrder(
        uint256 orderId,
        address owner,
        OrderKey memory orderKey,
        bytes calldata _data
    ) external {
        require(block.timestamp < orderKey.expiredAt, 'order expire already.');
        require(orderId < orderList.length, 'orderId exceeds total order.');
        require(orderList[orderId].orderStatus == OrderStatus.CREATED, 'order cannot be fulfill because of incorrect status.');

        bytes32 orderHash = keccak256(
            abi.encode(orderKey.nonce, owner, orderKey.srcToken, orderKey.dstToken, orderKey.amountIn, orderKey.stopPrice, orderKey.limitPrice, orderKey.amountOutMin, orderKey.expiredAt)
        );
        require(orderList[orderId].orderHash == orderHash);

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
            100
        );
    }

    function cancelOrder(
        uint256 orderId,
        OrderKey memory orderKey
    ) external {
        require(orderId < orderList.length, 'orderId exceeds total order.');
        require(orderList[orderId].orderStatus == OrderStatus.CREATED, 'order cannot be cancel because of incorrect status');
        bytes32 orderHash = keccak256(
            abi.encode(orderKey.nonce, msg.sender, orderKey.srcToken, orderKey.dstToken, orderKey.amountIn, orderKey.stopPrice, orderKey.limitPrice, orderKey.amountOutMin, orderKey.expiredAt)
        );
        require(orderList[orderId].orderHash == orderHash);

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

    function viewOrderStatus(
        uint256 orderId,
        address owner,
        OrderKey memory orderKey
    ) external view returns(OrderStatus) {
        require(orderId < orderList.length, 'orderId exceeds total order.');
        bytes32 orderHash = keccak256(
            abi.encode(orderKey.nonce, owner, orderKey.srcToken, orderKey.dstToken, orderKey.amountIn, orderKey.stopPrice, orderKey.limitPrice, orderKey.amountOutMin, orderKey.expiredAt)
        );
        require(orderList[orderId].orderHash == orderHash);
        return orderList[orderId].orderStatus;
    }
}

contract Vault{
    constructor() {
        selfdestruct(payable(address(this)));
    }
}