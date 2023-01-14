pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
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

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
interface IExchangeFactory {
    function getFees() external view returns(uint taker_fee_numerator_, uint taker_fee_denominator_, uint maker_fee_numerator_, uint maker_fee_denominator_);
    function feeTo() external view returns (address);
    function weth() external view returns (address);
    function listingEnable(address) external view returns (bool);
}

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED

library LibOrder {
    //keccak256("Order(address user,address sellToken,address buyToken,uint256 sellAmount,uint256 buyAmount,uint256 expirationTimeSeconds, uint nonce)")
    bytes32 internal constant _EIP712_ORDER_SCHEMA_HASH = 0xfee94c0fa16356fd77c9559019fab290583d7f33d3dc2d47ce92012467cca44e;
    
    enum Status {
        PENDING,
        PARTIALCOMPLETED,
        COMPLETED,
        CANCLED
    }

    struct Order {
        address maker;
        bytes32[] takerOrderHashs; 
        address[2] tokens; 
        uint[2] amounts;
        uint[2] pAmounts;
        uint fee; 
        uint createdAt;
        uint executedAt;
        Status status;
    }

    struct OrderInfo {
        bytes32[] orderQueqe; 
        uint256 lastIndex; 
    }
    
    function getOrderHash(address user, address sellToken ,address buyToken,uint256 sellAmount,uint256 buyAmount, uint256 createdAt, uint nonce) internal pure returns (bytes32 orderHash) {
        orderHash = keccak256(abi.encode(_EIP712_ORDER_SCHEMA_HASH, user, sellToken, buyToken, sellAmount, buyAmount, createdAt,nonce));   
    }

}

pragma solidity ^0.8.10;
library TransferHelper {

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

pragma solidity ^0.8.10;
import './library/LibOrder.sol';
import './interface/IERC20.sol';
import './interface/IExchangeFactory.sol';
import "./library/TransferHelper.sol";
// SPDX-License-Identifier: UNLICENSED

contract ExchangePair {
    using LibOrder for LibOrder.Order;

    address public factory;
    address public baseToken;
    address public fiatToken;
    
    uint public lastPrice;
    mapping(bytes32 => bool) public cancelled;
    mapping(bytes32 => bool) public compleated;
    mapping(bytes32 => LibOrder.Order) private orderByHash;
    mapping(uint => LibOrder.OrderInfo) private orders;
    mapping(address => uint) public nonce;
    uint private unlocked = 1;

    event ExecutedOrder(
        bytes32 indexed makerHash,
        bytes32 indexed takerHash,
        address indexed maker,
        address  taker,
        address makerSellToken,
        address takerSellToken,
        uint256 makerSellAmount,
        uint256 takerSellAmount,
        uint fee
    );
    
    event PartialExecutedOrder(
        bytes32 indexed makerHash,
        bytes32 indexed takerHash,
        address indexed maker,
        address taker,
        address makerSellToken,
        address takerSellToken,
        uint256 makerSellAmount,
        uint256 takerSellAmount,
        uint fee
    );

    modifier lock() {
        require(unlocked == 1, 'Exchange: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier onlyFactory {
        require(factory==msg.sender,"Exchagne:Forbidden");
        _;
    }

    constructor(address _factory) {
        factory = _factory;
    }

    function initialize(address _baseToken, address _fiatToken) external {
        require(msg.sender == factory, 'Exchange: FORBIDDEN');
        baseToken = _baseToken;
        fiatToken = _fiatToken;
    }

    function _createOrderGetHash(address _user, address[2] calldata tokens,  uint[2] calldata amounts ) internal returns (bytes32 hash_) {
        uint nonce_ = nonce[_user];
        hash_ = LibOrder.getOrderHash(_user, tokens[1],  tokens[0] , amounts[1], amounts[0], block.timestamp, nonce_);
        uint[2] memory tArr;
        orderByHash[hash_] =  LibOrder.Order(
            _user,
            new bytes32[](0),
            tokens,
            amounts,
            tArr,
            0,
            block.timestamp,
            0,
            LibOrder.Status.PENDING
        );
        nonce[_user]++;
        // emit CreateOrder(hash_, _user,_buyToken, _sellToken, _buyAmount, _sellAmount);
    }

    function checkPrice(address[2] calldata tokens,  uint[2] calldata amounts) public view  returns(uint price) {
        price = tokens[0]==fiatToken ? (amounts[0]*(10**IERC20(tokens[1]).decimals()))/amounts[1] : (amounts[1]*(10**IERC20(tokens[0]).decimals()))/amounts[0];
    }

    function createOrderTokensForTokens(address _user ,address[2] calldata tokens , uint[2] calldata amounts) external returns (bytes32 , uint ,uint ){
        return createOrder(_user,tokens, amounts);
    }

    function createOrderETHForTokens(address _user ,address[2] calldata tokens , uint[2] calldata amounts) external returns (bytes32 , uint ,uint ){
        address _weth = IExchangeFactory(factory).weth();
        require(tokens[0] == _weth, 'Exchange: INVALID_PATH');
        return createOrder(_user,tokens, amounts);
    }

    function createOrderTokensForETH(address _user ,address[2] calldata tokens , uint[2] calldata amounts) external payable returns (bytes32 , uint ,uint ){
        address _weth = IExchangeFactory(factory).weth();
        require(tokens[1] == _weth, 'Exchange: INVALID_PATH');
        return createOrder(_user,tokens, amounts);
    }

    function _range(uint _price) internal view virtual returns(uint) {
        if(orders[_price].orderQueqe.length!=0)
            return ((orders[_price].orderQueqe.length-orders[_price].lastIndex) > 5 ? (orders[_price].lastIndex+5): orders[_price].orderQueqe.length);
        else 
            return 0;
    }

    function createOrder(address _user,address[2] calldata tokens, uint[2] calldata amounts) internal lock onlyFactory returns(bytes32 hash_,uint price,uint _volume){
        uint[2] memory _tAmounts = amounts;
        uint[2] memory _fees;

        price = checkPrice( tokens,amounts);
        hash_ = _createOrderGetHash( _user,  tokens,amounts);
        uint len = _range(price);
        for(uint i = orders[price].lastIndex; i< len;) {
            bytes32 __hash = orders[price].orderQueqe[i]; 
            if(orderByHash[hash_].tokens[1] == orderByHash[__hash].tokens[0]) {
                if(!isCancelled(__hash)) {
                    if(!isCompleted(__hash)) { 
                        uint[4] memory tAmt_;
                        tAmt_[0] = (orderByHash[hash_].amounts[0]-orderByHash[hash_].pAmounts[0]);
                        tAmt_[1] = (orderByHash[hash_].amounts[1]-orderByHash[hash_].pAmounts[1]);
                        tAmt_[2] = (orderByHash[__hash].amounts[0]-orderByHash[__hash].pAmounts[0]);
                        tAmt_[3] = (orderByHash[__hash].amounts[1]-orderByHash[__hash].pAmounts[1]);

                        (uint[2] memory fees) = _getFees(
                            tAmt_[0],
                            tAmt_[1] 
                        );
                        _fees[0] +=fees[0];
                        _fees[1] +=fees[1];
                        lastPrice = price;

                        orderByHash[hash_].takerOrderHashs.push(__hash);
                        orderByHash[__hash].takerOrderHashs.push(hash_);

                        if (tAmt_[3] > tAmt_[0]) { 
                            _transfer(tokens[1], orderByHash[__hash].maker, tAmt_[1] - fees[0]);
                            updateOrder(__hash, hash_, tAmt_[1], tAmt_[0], fees[1], LibOrder.Status.PARTIALCOMPLETED);
                            _transfer(tokens[0], orderByHash[hash_].maker, tAmt_[0] - fees[1]);
                            updateOrder(hash_, __hash, amounts[0], amounts[1], fees[0], LibOrder.Status.COMPLETED);
                            _tAmounts[0] = 0;
                            _tAmounts[1] = 0;  
                            break;
                        } else {
                            _tAmounts[0] =  _tAmounts[0] - tAmt_[3];
                            _tAmounts[1] =  _tAmounts[1] - tAmt_[2];
                            orders[price].lastIndex = i + 1;  
                            if( _tAmounts[0]!=0) {
                                _transfer( tokens[0], orderByHash[hash_].maker, tAmt_[3] - fees[1] );
                                updateOrder(hash_,__hash,tAmt_[3],tAmt_[2],fees[0],LibOrder.Status.PARTIALCOMPLETED);
                                _transfer( tokens[1],orderByHash[__hash].maker,tAmt_[2] - fees[0]);
                                updateOrder(__hash,hash_,orderByHash[__hash].amounts[0],orderByHash[__hash].amounts[1],fees[1],LibOrder.Status.COMPLETED);
                            } else {
                                _transfer( tokens[0],orderByHash[hash_].maker,tAmt_[0] - fees[1]);
                                updateOrder(hash_, __hash, orderByHash[hash_].amounts[0],orderByHash[hash_].amounts[1],fees[0],LibOrder.Status.COMPLETED);
                                _transfer( tokens[1],orderByHash[__hash].maker, tAmt_[1] - fees[0]);
                                updateOrder(__hash,hash_,orderByHash[__hash].amounts[0],orderByHash[__hash].amounts[1],fees[1],LibOrder.Status.COMPLETED);
                                break;
                            }
                        }
                    }
                }
            }
            unchecked {
                i++;
            }
        }
    
        _volume = tokens[0]==baseToken?( amounts[0]-_tAmounts[0]):(amounts[1]-_tAmounts[1]);
        // console.log("token0:%s , takerFee:%s, makerfee:%s",IERC20(tokens[0]).symbol(), _fees[0], _fees[1]);
        _takeFee(tokens[0], tokens[1], _fees[0], _fees[1]);
        
        if(_tAmounts[0]!=0)
            orders[price].orderQueqe.push(hash_);
        return (hash_, _volume, price);
    }

    function updateOrder(bytes32 makerHash_ , bytes32 takerHash__, uint pBuy,uint pSell,uint fee,LibOrder.Status status) internal {
        LibOrder.Order memory order = orderByHash[makerHash_];
        LibOrder.Order memory order__ = orderByHash[takerHash__];
        uint tAmt =(order__.amounts[1]-order__.pAmounts[1]);
        uint pAmt = (order.amounts[1]-order.pAmounts[1]);
        if(LibOrder.Status.COMPLETED ==status) {
            emit ExecutedOrder(
                makerHash_,
                takerHash__,
                order.maker,
                order__.maker,
                order__.tokens[1],
                order.tokens[1],
                tAmt,
                pAmt,
                fee
            );

            compleated[makerHash_]=true;
            order.pAmounts[1] = pSell; 
            order.pAmounts[0] = pBuy; 

        } else {

            emit PartialExecutedOrder(
                makerHash_,
                takerHash__,
                order.maker,
                order__.maker,
                order.tokens[1],
                order__.tokens[1],
                pAmt,
                tAmt,
                fee
            );

            order.pAmounts[1] += pSell; 
            order.pAmounts[0] += pBuy; 
        }
        order.fee += fee; 
        order.executedAt = block.timestamp;
        order.status = status;
        orderByHash[makerHash_] = order;
    }

    function getTakersByOrderHash(bytes32 _hash) external view returns(bytes32[] memory) {
            return orderByHash[_hash].takerOrderHashs;
    } 

    function _transfer(address _token,address _to, uint _amount) internal {
        address _weth = IExchangeFactory(factory).weth();
        if(_token==_weth){
            payable(_to).transfer(_amount);
            // TransferHelper.safeTransferETH(_to, _amount);
        } else {
            IERC20(_token).transfer(_to,_amount);
            // TransferHelper.safeTransfer(_token, _to,_amount);
        }
    }

    function _takeFee(address _buyToken,address _sellToken,uint takerFee,uint makerFee) internal  {
        if(makerFee!=0){
            // IERC20(_buyToken).transfer(IExchangeFactory(factory).feeTo(),takerFee);
            _transfer(_buyToken,IExchangeFactory(factory).feeTo(), makerFee);
        } 
        if(takerFee!=0) {
            // IERC20(_sellToken).transfer(IExchangeFactory(factory).feeTo(),makerFee);
            _transfer(_sellToken,IExchangeFactory(factory).feeTo(), takerFee);
        }
    }

    function _getFees(
      uint makerBuyAmount,
      uint makerSellAmount
    ) internal view returns(uint[2] memory fees ) {
        (uint taker_fee_numerator, uint taker_fee_denominator, uint maker_fee_numerator, uint maker_fee_denominator) = IExchangeFactory(factory).getFees();
        uint takerFee;
        uint makerFee;
        makerFee = makerBuyAmount * maker_fee_numerator / maker_fee_denominator;
        takerFee = makerSellAmount * taker_fee_numerator / taker_fee_denominator;
        fees[0] = takerFee;
        fees[1] = makerFee;
        return (fees);
    }

    function cancleOrder(bytes32 _hash) external onlyFactory {
        require(!cancelled[_hash],"Exchange: Order Already Cancled!");
        require(!compleated[_hash],"Exchange: Order Already Completed!");
        orderByHash[_hash].status = LibOrder.Status.CANCLED;
        orderByHash[_hash].executedAt = block.timestamp;
        cancelled[_hash] = true;
        
        _transfer(orderByHash[_hash].tokens[1],orderByHash[_hash].maker,(orderByHash[_hash].amounts[1]-orderByHash[_hash].pAmounts[1]));
        // emit CancleOrder(_hash,orderByHash[_hash].tokens[1],orderByHash[_hash].maker,(orderByHash[_hash].amounts[1]-orderByHash[_hash].pAmounts[1]));
    }

    function getOrdersByPrice(uint256 price) external  view returns  (uint lastIndex,bytes32[] memory queqe) {
        return (orders[price].lastIndex,orders[price].orderQueqe);
    }
    
    function getOrderByHash(bytes32 _hash) external view returns (
        address maker,
        bytes32[] memory takerOrderHashs, 
        address sellToken,
        address buyToken,
        uint256 sellAmount,
        uint256 pSellAmt,
        uint256 buyAmount,   
        uint256 pBuyAmt,
        uint256 fee, 
        uint256 createdAt,
        uint256 executedAt,
        LibOrder.Status  status 
    ) {
            maker= orderByHash[_hash].maker;
            takerOrderHashs= orderByHash[_hash].takerOrderHashs;
            sellToken= orderByHash[_hash].tokens[1];
            buyToken= orderByHash[_hash].tokens[0];
            sellAmount= orderByHash[_hash].amounts[1];
            pSellAmt= orderByHash[_hash].pAmounts[1];
            buyAmount= orderByHash[_hash].amounts[0];
            pBuyAmt= orderByHash[_hash].pAmounts[0];
            fee= orderByHash[_hash].fee;
            createdAt = orderByHash[_hash].createdAt;
            executedAt = orderByHash[_hash].executedAt;
            status =  orderByHash[_hash].status;
    }

    function getMakerByHash(bytes32 _hash) external view returns (address maker) {
        maker= orderByHash[_hash].maker;
    }

    function isCancelled(bytes32 __hash) public view returns(bool) {
        return cancelled[__hash];
    }

    function isCompleted(bytes32 __hash) public view returns(bool) {
        return compleated[__hash];
    }
}