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
}

pragma solidity ^0.8.10;
//SPDX-License-Identifier: UNLICENSED
interface IWETH {
    function deposit() external payable ;
    function withdraw(uint wad) external payable;
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function balanceOf(address _owner) external returns (uint);
    function allowance(address _owner, address _spender ) external returns(uint);
    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);
}

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED

library LibOrder {
    //keccak256("Order(address user,address sellToken,address buyToken,uint256 sellAmount,uint256 buyAmount,uint256 expirationTimeSeconds)")
    bytes32 internal constant _EIP712_ORDER_SCHEMA_HASH = 0x68d868c8698fc31da3a36bb7a184a4af099797794701bae97bea3de7ebe6e399;
    
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
        uint sellAmount;
        uint pSellAmt;
        uint buyAmount;
        uint pBuyAmt;
        uint fee; 
        uint createdAt;
        uint executedAt;
        Status status;
    }

    struct OrderInfo {
        bytes32[] orderQueqe; 
        uint256 lastIndex; 
    }
    

    function getOrderHash(address user, address sellToken ,address buyToken,uint256 sellAmount,uint256 buyAmount, uint256 createdAt) internal pure returns (bytes32 orderHash) {
        orderHash = keccak256(abi.encode(_EIP712_ORDER_SCHEMA_HASH, user, sellToken, buyToken, sellAmount, buyAmount, createdAt));   
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
import './interface/IWETH.sol';
import './interface/IExchangeFactory.sol';
import './library/TransferHelper.sol';

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

    uint private unlocked = 1;

    event CreateOrder(bytes32 indexed  hash, address indexed maker, address buyToken, address sellToken, uint buyAmount, uint sellAmount);
    event CancleOrder(bytes32 indexed hash);

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

    event Trade(address indexed pair, uint256 _volume,uint256 _price);

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

    function _createOrderGetHash(address _user, address _buyToken, address _sellToken, uint _buyAmount, uint _sellAmount) internal returns (bytes32 hash_) {
        hash_ = LibOrder.getOrderHash(_user, _sellToken,  _buyToken , _sellAmount, _buyAmount, block.timestamp);
        orderByHash[hash_] =  LibOrder.Order(
            _user,
            new bytes32[](0),
            _sellToken,
            _buyToken,
            _sellAmount,
            0,
            _buyAmount,
            0,
            0,
            block.timestamp,
            0,
            LibOrder.Status.PENDING
        );
        emit CreateOrder(hash_, _user,_buyToken, _sellToken, _buyAmount, _sellAmount);
    }

    function checkPrice(address _buyToken,address _sellToken, uint _buyAmount, uint _sellAmount) public view  returns(uint price) {
        price = _buyToken==fiatToken ? (_buyAmount*(10**IERC20(_sellToken).decimals()))/_sellAmount : (_sellAmount*(10**IERC20(_buyToken).decimals()))/_buyAmount;
    }

    function createOrderTokensForTokens(address _user, address _buyToken, address _sellToken, uint _buyAmount, uint _sellAmount) external {
        createOrder(_user, _buyToken, _sellToken, _buyAmount, _sellAmount);
    }

    function createOrderETHForTokens(address _user ,address _buyToken ,address _sellToken, uint _buyAmount,uint _sellAmount)external {
        address _weth = IExchangeFactory(factory).weth();
        require(_buyToken == _weth, 'Exchange: INVALID_PATH');
        createOrder(_user,_buyToken, _sellToken, _buyAmount, _sellAmount);
    }

    function createOrderTokensForETH(address _user ,address _buyToken ,address _sellToken, uint _buyAmount,uint _sellAmount)external payable {
        address _weth = IExchangeFactory(factory).weth();
        require(_sellToken == _weth, 'Exchange: INVALID_PATH');
        createOrder( _user,_buyToken, _sellToken, _buyAmount, _sellAmount);
    }

    function _range(uint _price) internal view virtual returns(uint) {
        if(orders[_price].orderQueqe.length!=0)
            return ((orders[_price].orderQueqe.length-orders[_price].lastIndex) > 5 ? (orders[_price].lastIndex+5): orders[_price].orderQueqe.length);
        else 
            return 0;
    }

    function createOrder(address _user,address _buyToken, address _sellToken, uint _buyAmount, uint _sellAmount) internal lock onlyFactory  {
        uint _tBuyAmount = _buyAmount;
        uint _tSellAmount = _sellAmount;
        uint takerFee;
        uint makerFee;

        uint price = checkPrice( _buyToken, _sellToken,  _buyAmount,  _sellAmount);
        bytes32 hash_ = _createOrderGetHash( _user,  _buyToken,  _sellToken,  _buyAmount,  _sellAmount);
        uint len = _range(price);

        for(uint i = orders[price].lastIndex; i< len;) {
            bytes32 __hash = orders[price].orderQueqe[i]; 
            if(orderByHash[hash_].sellToken == orderByHash[__hash].buyToken) {
                if(!isCancelled(__hash)) {
                    if(!isCompleted(__hash)) {
                        (uint _takerFee, uint _makerFee) = _getFees(
                            _buyToken,
                            (orderByHash[hash_].buyAmount-orderByHash[hash_].pBuyAmt),
                            (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt)
                        );
                        takerFee +=_takerFee;
                        makerFee +=_makerFee;
                        lastPrice = price;

                        orderByHash[hash_].takerOrderHashs.push(__hash);
                        orderByHash[__hash].takerOrderHashs.push(hash_);

                        if ((orderByHash[__hash].sellAmount - orderByHash[__hash].pSellAmt) > (orderByHash[hash_].buyAmount - orderByHash[hash_].pBuyAmt)) { 
                            _transfer(_buyToken,orderByHash[hash_].maker,(orderByHash[hash_].buyAmount-orderByHash[hash_].pBuyAmt)-_takerFee);
                            _transfer(_sellToken,orderByHash[__hash].maker,(orderByHash[hash_].sellAmount - orderByHash[hash_].pSellAmt)-_makerFee);

                            // emit PartialExecutedOrder(
                            //     __hash,
                            //     hash_, 
                            //     orderByHash[__hash].maker,
                            //     orderByHash[hash_].maker,
                            //     orderByHash[__hash].sellToken,
                            //     orderByHash[hash_].sellToken,
                            //     (orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt),
                            //     (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt),
                            //     _makerFee
                            // );

                            updateOrder(__hash,(orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt),(orderByHash[hash_].buyAmount-orderByHash[hash_].pBuyAmt),_makerFee,LibOrder.Status.PARTIALCOMPLETED);

                            // emit ExecutedOrder(
                            //     hash_,
                            //     __hash,
                            //     orderByHash[hash_].maker,
                            //     orderByHash[__hash].maker,
                            //     orderByHash[hash_].sellToken,
                            //     orderByHash[__hash].sellToken,
                            //     (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt),
                            //     (orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt),
                            //     _takerFee
                            // );

                            updateOrder(hash_,_buyAmount,_sellAmount,_takerFee,LibOrder.Status.COMPLETED);
                            
                            _tBuyAmount = 0;
                            _tSellAmount = 0;  
                            break;
                        } else {
                            _tBuyAmount = _tBuyAmount - (orderByHash[__hash].sellAmount - orderByHash[__hash].pSellAmt);
                            _tSellAmount = _tSellAmount - (orderByHash[__hash].buyAmount - orderByHash[__hash].pBuyAmt);
                        
                            orders[price].lastIndex = i + 1;  

                            if(_tBuyAmount!=0) {
                                _transfer(_buyToken,orderByHash[hash_].maker,(orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt)-_takerFee);
                                _transfer(_sellToken,orderByHash[__hash].maker,(orderByHash[__hash].buyAmount-orderByHash[__hash].pBuyAmt)-_makerFee);

                                // emit PartialExecutedOrder(
                                //     hash_,
                                //     __hash,
                                //     orderByHash[hash_].maker,
                                //     orderByHash[__hash].maker,
                                //     orderByHash[hash_].sellToken,
                                //     orderByHash[__hash].sellToken,
                                //     (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt),
                                //     (orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt),
                                //     _takerFee
                                // );
                                updateOrder(hash_,(orderByHash[__hash].sellAmount - orderByHash[__hash].pSellAmt),(orderByHash[__hash].buyAmount - orderByHash[__hash].pBuyAmt),_takerFee,LibOrder.Status.PARTIALCOMPLETED);

                                // emit ExecutedOrder(
                                //     __hash,
                                //     hash_,
                                //     orderByHash[__hash].maker,
                                //     orderByHash[hash_].maker,
                                //     orderByHash[__hash].sellToken,
                                //     orderByHash[hash_].sellToken,
                                //     (orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt),
                                //     (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt),
                                //     _makerFee
                                // );

                                updateOrder(__hash,orderByHash[__hash].buyAmount,orderByHash[__hash].sellAmount,_makerFee,LibOrder.Status.COMPLETED);

                            } else {

                                _transfer(_buyToken,orderByHash[hash_].maker,(orderByHash[hash_].buyAmount - orderByHash[hash_].pBuyAmt) - _takerFee);
                                _transfer(_sellToken,orderByHash[__hash].maker,(orderByHash[hash_].sellAmount - orderByHash[hash_].pSellAmt) - _makerFee);
                                
                                // emit ExecutedOrder(
                                //     hash_,
                                //     __hash,
                                //     orderByHash[hash_].maker,
                                //     orderByHash[__hash].maker,
                                //     orderByHash[hash_].sellToken,
                                //     orderByHash[__hash].sellToken,
                                //     (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt),
                                //     (orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt),
                                //     _takerFee
                                // );
                                updateOrder(hash_,orderByHash[hash_].buyAmount,orderByHash[hash_].sellAmount,_takerFee,LibOrder.Status.COMPLETED);

                                // emit ExecutedOrder(
                                //     __hash,
                                //     hash_,
                                //     orderByHash[__hash].maker,
                                //     orderByHash[hash_].maker,
                                //     orderByHash[__hash].sellToken,
                                //     orderByHash[hash_].sellToken,
                                //     (orderByHash[__hash].sellAmount-orderByHash[__hash].pSellAmt),
                                //     (orderByHash[hash_].sellAmount-orderByHash[hash_].pSellAmt),
                                //     _makerFee
                                // );   

                                updateOrder(__hash,orderByHash[__hash].buyAmount,orderByHash[__hash].sellAmount,_makerFee,LibOrder.Status.COMPLETED);

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
    
        uint _volume = _buyToken==baseToken?( _buyAmount-_tBuyAmount):(_sellAmount-_tSellAmount);
        emit Trade(address(this), _volume, price);
        
        _takeFee( _buyToken, _sellToken, takerFee, makerFee);
        
        if(_tBuyAmount!=0)
        orders[price].orderQueqe.push(hash_);
   
    }

    function updateOrder(bytes32 hash_ ,uint pBuy,uint pSell,uint fee,LibOrder.Status status) internal {
        LibOrder.Order memory order = orderByHash[hash_];
        order.fee += fee; 
        order.executedAt = block.timestamp;
        order.status = status;
        if(LibOrder.Status.COMPLETED ==status) {
            compleated[hash_] =true;
            order.pSellAmt = pSell; 
            order.pBuyAmt = pBuy; 
        } else {
            order.pSellAmt += pSell; 
            order.pBuyAmt += pBuy; 
        }

        orderByHash[hash_] = order;
    }

    function getTakersByOrderHash(bytes32 _hash) external view returns(bytes32[] memory) {
            return orderByHash[_hash].takerOrderHashs;
    } 

    function _transfer(address _token,address _to, uint _amount) internal {
        address _weth = IExchangeFactory(factory).weth();
        if(_token==_weth){
            // payable(_to).transfer(_amount);
            TransferHelper.safeTransferETH(_to, _amount);
        } else {
            // IERC20(_token).transfer(_to,_amount);
            TransferHelper.safeTransfer(_token, _to,_amount);
        }
    }

    function _takeFee(address _buyToken,address _sellToken,uint takerFee,uint makerFee) internal  {
        if(takerFee!=0){
            // IERC20(_buyToken).transfer(IExchangeFactory(factory).feeTo(),takerFee);
            _transfer(_buyToken,IExchangeFactory(factory).feeTo(), takerFee);
        } 
        if(makerFee!=0) {
            // IERC20(_sellToken).transfer(IExchangeFactory(factory).feeTo(),makerFee);
            _transfer(_sellToken,IExchangeFactory(factory).feeTo(), makerFee);
        }
    }

    function _getFees(
      address buyToken,
      uint makerBuyAmount,
      uint makerSellAmount
    ) internal view returns(uint,uint) {
        (uint taker_fee_numerator, uint taker_fee_denominator, uint maker_fee_numerator, uint maker_fee_denominator) = IExchangeFactory(factory).getFees();
        uint takerFee;
        uint makerFee;
        if(buyToken==baseToken) {
            makerFee = makerBuyAmount * maker_fee_numerator / maker_fee_denominator;
            takerFee = makerSellAmount * taker_fee_numerator / taker_fee_denominator;
        } else {
            takerFee = makerBuyAmount * maker_fee_numerator / maker_fee_denominator;
            makerFee = makerSellAmount * taker_fee_numerator / taker_fee_denominator;
        }

        return (takerFee,makerFee);
    }

    function cancleOrder(bytes32 _hash) external onlyFactory {
        require(!cancelled[_hash],"Exchange: Order Already Cancled!");
        require(!compleated[_hash],"Exchange: Order Already Completed!");
        orderByHash[_hash].status = LibOrder.Status.CANCLED;
        cancelled[_hash] = true;
        _transfer(orderByHash[_hash].sellToken,orderByHash[_hash].maker,(orderByHash[_hash].sellAmount-orderByHash[_hash].pSellAmt));
        emit CancleOrder(_hash);
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
            sellToken= orderByHash[_hash].sellToken;
            buyToken= orderByHash[_hash].buyToken;
            sellAmount= orderByHash[_hash].sellAmount;
            pSellAmt= orderByHash[_hash].pSellAmt;
            buyAmount= orderByHash[_hash].buyAmount;
            pBuyAmt= orderByHash[_hash].pBuyAmt;
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