/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

pragma solidity 0.8.10;

// SPDX-License-Identifier: UNLICENSED

interface IExchangeFactory {
    function getFees() external view returns(uint taker_fee_numerator_, uint taker_fee_denominator_, uint maker_fee_numerator_, uint maker_fee_denominator_);
    function feeTo() external view returns (address);
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

library LibOrder {
    //keccak256("Order(address user,address sellToken,address buyToken,uint256 sellAmount,uint256 buyAmount,uint256 expirationTimeSeconds)")
    bytes32 internal constant _EIP712_ORDER_SCHEMA_HASH = 0x68d868c8698fc31da3a36bb7a184a4af099797794701bae97bea3de7ebe6e399;

    enum Type {
        Buy,
        Sell
    } 

    enum Status {
        PENDING,
        PARTIALCOMPLETED,
        COMPLETED,
        CANCLED
    }

    struct Order {
        address maker;
        bytes32[] takerOrderHashs; 
        address sellToken; 
        address buyToken; 
        uint256 sellAmount;
        uint256 pSellAmt;
        uint256 buyAmount;
        uint256 pBuyAmt;
        uint256 makerFee; 
        uint256 takerFee; 
        uint256 expirationTimeSeconds;
        Status status;
    }

    struct OrderInfo {
        bytes32[] orderQueqe; 
        uint256 lastIndex; 
    }
    

    function getOrderHash(address user, address sellToken ,address buyToken,uint256 sellAmount,uint256 buyAmount, uint256 expirationTimeSeconds) internal pure returns (bytes32 orderHash) {
        orderHash = keccak256(
        abi.encode(_EIP712_ORDER_SCHEMA_HASH, user, sellToken, buyToken, sellAmount, buyAmount, expirationTimeSeconds)
        );   
    }

}

contract ExchangePair {
    using LibOrder for LibOrder.Order;

    address public factory;
    address public baseToken;
    address public fiatToken;

    mapping(bytes32 => bool) public cancelled;
    mapping(bytes32 => bool) public compleated;
    mapping(bytes32 => LibOrder.Order) public orderByHash;
    mapping(uint => LibOrder.OrderInfo) private orders;
    uint private unlocked = 1;

    event CreateOrder(bytes32 hash, address buyToken, address sellToken, uint buyAmount, uint sellAmount, uint256 price);
    event CancleOrder(bytes32 hash);

    event ExecutedOrder(
        bytes32 makerHash,
        bytes32 takerHash,
        address maker,
        address taker,
        address makerSellToken,
        address takerSellToken,
        uint256 makerSellAmount,
        uint256 takerSellAmount,
        uint256 makerVolumeFee,
        uint256 takerVolumeFee
    );
    event PartialExecutedOrder(
        bytes32 makerHash,
        bytes32 takerHash,
        address maker,
        address taker,
        address makerSellToken,
        address takerSellToken,
        uint256 makerSellAmount,
        uint256 takerSellAmount,
        uint256 makerVolumeFee,
        uint256 takerVolumeFee
    );
 
    modifier lock() {
        require(unlocked == 1, 'Exchange: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address _factory) {
        factory = _factory;
    }

    function initialize(address _baseToken, address _fiatToken) external {
        require(msg.sender == factory, 'Exchange: FORBIDDEN'); // sufficient check
        baseToken = _baseToken;
        fiatToken = _fiatToken;
    }

    function createOrder(address _user, address _buyToken, address _sellToken, uint _buyAmount, uint _sellAmount) public lock returns (uint _tBuyAmount , uint _tSellAmount){
        _tBuyAmount = _buyAmount;
        _tSellAmount = _sellAmount;

        uint price = _buyToken==fiatToken ? (_buyAmount*1e18)/_sellAmount : (_sellAmount*1e18)/_buyAmount;
        bytes32 hash_ = LibOrder.getOrderHash(_user, _sellToken,  _buyToken , _sellAmount, _buyAmount, (block.timestamp+3 days));
        orderByHash[hash_] =  LibOrder.Order(_user, new bytes32[](0), _sellToken,  _buyToken , _sellAmount,0, _buyAmount,0, 0, 0, (block.timestamp+3 days),LibOrder.Status.PENDING);
        emit CreateOrder(hash_, _buyToken, _sellToken, _buyAmount, _sellAmount, price);

        for(uint i = orders[price].lastIndex;i< orders[price].orderQueqe.length; i++) {
            bytes32 __hash = orders[price].orderQueqe[i];
            (uint takerFee,uint makerFee) = _settleMatchedOrders((orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt),(orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt));
            if(!cancelled[__hash] &&! compleated[__hash] && orderByHash[hash_].sellToken == orderByHash[__hash].buyToken) {
                if ((orderByHash[__hash].sellAmount - orderByHash[__hash].pSellAmt ) > (orderByHash[hash_].buyAmount-orderByHash[hash_].pBuyAmt)) { 
                    
                    orderByHash[__hash].pSellAmt +=  (orderByHash[hash_].buyAmount-orderByHash[hash_].pBuyAmt);
                    orderByHash[__hash].pBuyAmt +=  (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt);
                    orderByHash[hash_].pSellAmt += _sellAmount;
                    orderByHash[hash_].pBuyAmt += _buyAmount;

                    orderByHash[hash_].takerOrderHashs.push(__hash);
                    orderByHash[hash_].status = LibOrder.Status.COMPLETED;
                    orderByHash[__hash].makerFee += makerFee;

                    compleated[hash_] = true;  
                    orderByHash[hash_].takerFee += takerFee; 
                    orderByHash[__hash].takerOrderHashs.push(hash_);
                    orderByHash[__hash].status = LibOrder.Status.PARTIALCOMPLETED;
                    _tBuyAmount = 0;

                    emit PartialExecutedOrder(__hash,hash_, orderByHash[__hash].maker, orderByHash[hash_].maker, orderByHash[__hash].sellToken,orderByHash[hash_].sellToken, orderByHash[__hash].sellAmount, orderByHash[hash_].sellAmount, makerFee, 0);
                    emit ExecutedOrder(hash_,__hash, orderByHash[hash_].maker, orderByHash[__hash].maker, orderByHash[hash_].sellToken, orderByHash[__hash].sellToken, orderByHash[hash_].sellAmount, orderByHash[__hash].sellAmount, 0, takerFee);
                    break;
                } else {
                    _tBuyAmount = _tBuyAmount - (orderByHash[__hash].sellAmount - orderByHash[__hash].pSellAmt);
                    _tSellAmount = _tSellAmount - (orderByHash[__hash].buyAmount - orderByHash[__hash].pBuyAmt);
                    if(_tBuyAmount!=0){
 
                        orderByHash[__hash].status = LibOrder.Status.COMPLETED;
                        orderByHash[hash_].status = LibOrder.Status.PARTIALCOMPLETED;
                        orderByHash[hash_].takerFee += takerFee; 
                        orderByHash[__hash].makerFee += makerFee;
                        compleated[__hash] = true;
                        orderByHash[hash_].pBuyAmt += (orderByHash[__hash].sellAmount - orderByHash[__hash].pSellAmt); 
                        orderByHash[hash_].pSellAmt += (orderByHash[__hash].buyAmount - orderByHash[__hash].pBuyAmt); 
                        orderByHash[__hash].pSellAmt = orderByHash[__hash].sellAmount; 
                        orderByHash[__hash].pBuyAmt = orderByHash[__hash].buyAmount; 
                        emit ExecutedOrder(__hash,hash_, orderByHash[__hash].maker, orderByHash[hash_].maker, orderByHash[__hash].sellToken,orderByHash[hash_].sellToken, orderByHash[__hash].sellAmount, orderByHash[hash_].sellAmount, makerFee, 0);
                        emit PartialExecutedOrder(hash_,__hash, orderByHash[hash_].maker, orderByHash[__hash].maker, orderByHash[hash_].sellToken, orderByHash[__hash].sellToken, orderByHash[hash_].sellAmount, orderByHash[__hash].sellAmount, 0, takerFee); 
                        orders[price].lastIndex = i + 1;  

                    } else {
                        orderByHash[__hash].status = LibOrder.Status.COMPLETED;
                        orderByHash[hash_].status = LibOrder.Status.COMPLETED;
                    
                        compleated[__hash] = true;
                        compleated[hash_] = true;

                        orderByHash[hash_].takerFee += takerFee; 
                        orderByHash[__hash].makerFee += makerFee;

                        orderByHash[hash_].pSellAmt = orderByHash[hash_].sellAmount; 
                        orderByHash[hash_].pBuyAmt = orderByHash[hash_].buyAmount; 
                        orderByHash[__hash].pSellAmt = orderByHash[__hash].sellAmount; 
                         orderByHash[__hash].pBuyAmt = orderByHash[__hash].buyAmount; 

                        emit ExecutedOrder(__hash,hash_, orderByHash[__hash].maker, orderByHash[hash_].maker, orderByHash[__hash].sellToken,orderByHash[hash_].sellToken, orderByHash[__hash].sellAmount, orderByHash[hash_].sellAmount, makerFee, 0);
                        emit ExecutedOrder(hash_,__hash, orderByHash[hash_].maker, orderByHash[__hash].maker, orderByHash[hash_].sellToken, orderByHash[__hash].sellToken, orderByHash[hash_].sellAmount, orderByHash[__hash].sellAmount, 0, takerFee); 
                        orders[price].lastIndex = i + 1;  
                        break;

                    }
                }
            }
        }
        if(_tBuyAmount!=0)
            orders[price].orderQueqe.push(hash_);
    }

    function getTakersByOrderHash(bytes32 _hash) external view returns(bytes32[] memory) {
            return orderByHash[_hash].takerOrderHashs;
    } 

    function _settleMatchedOrders(
      uint makerSellAmount,
      uint takerSellAmount
    ) internal view returns(uint,uint){
        (uint taker_fee_numerator, uint taker_fee_denominator, uint maker_fee_numerator, uint maker_fee_denominator) = IExchangeFactory(factory).getFees();
        uint takerFee = makerSellAmount * taker_fee_numerator / taker_fee_denominator;
        uint makerFee = takerSellAmount * maker_fee_numerator / maker_fee_denominator;
       return (takerFee,makerFee);

    }

    function cancleOrder(bytes32 _hash) external {
        require(orderByHash[_hash].maker == msg.sender,"Exchange: Forbidden");
        orderByHash[_hash].status = LibOrder.Status.CANCLED;
        cancelled[_hash] = true;
        emit CancleOrder(_hash);
    }

    function getOrdersByPrice(uint256 price) external  view returns  (uint lastIndex,bytes32[] memory queqe) {
        return (orders[price].lastIndex,orders[price].orderQueqe);
    }

}