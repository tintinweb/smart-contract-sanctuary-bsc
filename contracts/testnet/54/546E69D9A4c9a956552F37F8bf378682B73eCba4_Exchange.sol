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

pragma solidity ^0.8.0;
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity ^0.8.0;
import "./IUniswapV2Router01.sol";
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
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

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;
import "./Context.sol";
//S
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

import "./Context.sol";

contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;


    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }


    function paused() public view virtual returns (bool) {
        return _paused;
    }


    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }


    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }


    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }


    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity ^0.8.10;
import './library/Initializable.sol';
import './library/Ownable.sol';
import "./interface/IERC20.sol";
import "./library/LibOrder.sol";
// SPDX-License-Identifier: UNLICENSED
import "./library/Pausable.sol";

import "./interface/IUniswapV2Router02.sol";

interface IVault {
    function balanceOf(IERC20 _token ) external view returns (uint256);
    function owner() external view returns (address );
    function exchange() external view returns (address );
    function safeTokenTransfer(IERC20 _token, address _to, uint256 _amount) external;
} 

interface IWETH {
    function deposit() external payable ;
    function withdraw(uint256 wad) external ;
    function approve(address guy, uint256 wad) external returns (bool);
    function transfer(address dst, uint256 wad) external returns (bool);
    function transferFrom(address src,address dst,uint256 wad) external returns (bool);  
}

contract Exchange  is Initializable , Ownable ,Pausable {
    // CUSTOM DATATYPE
    struct Pair {
        address baseToken;
        address pairToken;
        uint lastprice;
        uint minmunTxAmt;
        mapping(uint => LibOrder.OrderInfo) orders;
    }

    // VARIABLES
    mapping(address => Pair) private _pair;
    mapping(bytes32 => bool) private cancelled;
    mapping(bytes32 => bool) private compleated;
    mapping(bytes32 => LibOrder.Order) private orderByHash;
    mapping(address => uint) public nonce;
    mapping(address => mapping(address => address)) public getPair;
    address[] private _pairTokens;
    mapping(address=>uint) public listingFees;
    mapping(address=>bool) public listingEnable;
    address[] public allPairs;
    address public feeTo;
    IWETH public weth; 
    mapping(address=>bool) private locked;

    IVault public vault; 

    uint256 maker_fee_numerator;
    uint256 maker_fee_denominator;
    uint256 taker_fee_numerator;
    uint256 taker_fee_denominator;
    
    IUniswapV2Router02 public pancakeRouter;

    // error
    error Unauthorized();
    error Locked();
    error PairNotExist();
    error AllowanceExceed();
    error NotEnoughEther();
    // MODIFIERS

    modifier lock(address _pairHash) {
        if(locked[_pairHash]) revert Locked();
        locked[_pairHash] = true;
        _;
        locked[_pairHash] = false;
    }

    modifier checkPair(address _buyToken,address _sellToken) {
        if(getPair[_buyToken][_sellToken]==address(0)) revert PairNotExist();
        _;
    }

    modifier checkAmt(address[2] calldata tokens , uint[2] calldata  amounts ) {
        address _pairHash = getPair[tokens[0]][tokens[1]];
       require(
        _pair[_pairHash].baseToken==tokens[0]?
       _pair[_pairHash].minmunTxAmt<=amounts[0] : _pair[_pairHash].minmunTxAmt<=amounts[1] );
       _;
    }

    // EVENTS

    event PairCreated(address indexed user, address indexed token0, address indexed token1, address pair, uint);
    event CreateOrder(bytes32 indexed  _hash, address indexed maker, address buyToken, address sellToken, uint buyAmount, uint sellAmount, uint price);
    event CancleOrder(bytes32 indexed _hash);
    event Trade(address indexed pair, uint256 _volume,uint256 _price);
    event Swap(address[] path, uint[] amounts);

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

    // Functions
    function initialize(address _feeTo, address _vault, IWETH _weth,address[] calldata pairTokens,uint[] calldata listingFee) external initializer {
        require(pairTokens.length==listingFee.length);
        feeTo = _feeTo;
        weth = _weth;
        maker_fee_numerator = 3;
        maker_fee_denominator = 1000;
        taker_fee_numerator = 3;
        taker_fee_denominator = 1000;
        _transferOwnership(_feeTo);
        vault = IVault(_vault);
        for(uint i=0; i< pairTokens.length; i++) {
            listingEnable[pairTokens[i]]=true;
            listingFees[pairTokens[i]] =listingFee[i];
            _pairTokens.push(pairTokens[i]);
        }
    }

    function createPair(address baseToken, address qouteToken) external payable {
        require(listingEnable[qouteToken],"Exchange : listing not enble with this qoute token");
        require(baseToken != qouteToken, 'Exchange: IDENTICAL_ADDRESSES');
        require(baseToken != address(0) && qouteToken != address(0), 'Exchange: ZERO_ADDRESS');
        require(getPair[baseToken][qouteToken] == address(0), 'Exchange: PAIR_EXISTS');

        if(msg.sender != owner()) {
            require(msg.value >= listingFees[qouteToken],"Exchange: Listing Fees not Received!");
            payable(feeTo).transfer(listingFees[qouteToken]);
        } 

        address pair = address(uint160(uint(keccak256(abi.encodePacked(baseToken, qouteToken)))));

        _pair[pair].baseToken = baseToken;
        _pair[pair].pairToken = qouteToken;

        getPair[baseToken][qouteToken] = address(pair);
        getPair[qouteToken][baseToken] = address(pair); 
        allPairs.push(address(pair));

        emit PairCreated(msg.sender, baseToken, qouteToken, address(pair), allPairs.length);
    }

    function exchangeOrderTokensForTokens(address _user, address[2] calldata tokens, uint[2] calldata amounts ) external checkPair(tokens[0],tokens[1]) checkAmt(tokens, amounts ) whenNotPaused {
        if(IERC20(tokens[1]).allowance(_user,address(this))<amounts[1]) revert AllowanceExceed();
        address _pairHash =  getPair[tokens[0]][tokens[1]];
        IERC20(tokens[1]).transferFrom(_user,address(vault) , amounts[1]);
        (, uint volume ,uint price) = executeOrder(_user,_pairHash,tokens, amounts);
        if(volume!=0){
            emit Trade(_pairHash,  volume, price);
        }
    }

    function exchangeOrderTokensForETH(address _user,address[2] calldata tokens, uint[2] calldata amounts) external payable checkPair(tokens[0],tokens[1]) checkAmt(tokens, amounts ) whenNotPaused {
        require(tokens[1] == address(weth), 'Exchange: INVALID_PATH');  
        assert(msg.value == amounts[1]);
        weth.deposit{value:msg.value}();
        weth.transfer(address(vault),amounts[1]);
        address _pairHash =  getPair[tokens[0]][tokens[1]];
        (, uint volume ,uint price) = executeOrder(_user, _pairHash, tokens, amounts);
        if(volume!=0){
            emit Trade(_pairHash,  volume, price);
        }
    }

    function exchangeOrderETHForTokens(address _user,address[2] calldata tokens, uint[2] calldata amounts) external  checkPair(tokens[0],tokens[1]) checkAmt(tokens, amounts ) whenNotPaused {
        require(tokens[0] == address(weth), 'Exchange: INVALID_PATH');    
        require(IERC20(tokens[1]).allowance(_user,address(this))>=amounts[1],"ExchagnePair: Allownace Exceed!");
        address _pairHash =  getPair[tokens[0]][tokens[1]];
        IERC20(tokens[1]).transferFrom(_user, address(vault) , amounts[1]);
        (, uint volume ,uint price) = executeOrder(_user, _pairHash, tokens, amounts);
        if(volume!=0){
            emit Trade(_pairHash,  volume, price);
        }
    }

    function cancleOrderByHash(bytes32 _hash) public {
        require( orderByHash[_hash].maker==msg.sender,"Exchange:Forbidden");
        require(!cancelled[_hash],"Exchange: Order Already Cancled!");
        require(!compleated[_hash],"Exchange: Order Already Completed!");
        orderByHash[_hash].status = LibOrder.Status.CANCLED;
        orderByHash[_hash].executedAt = block.timestamp;
        cancelled[_hash] = true;
        _transfer(orderByHash[_hash].tokens[1],orderByHash[_hash].maker,(orderByHash[_hash].amounts[1]-orderByHash[_hash].pAmounts[1]));
        emit CancleOrder(_hash);
    }

    function cancleAllOrderByHash(address[] calldata  _pairs,bytes32[] calldata _hashs) external {
        assert(_pairs.length == _hashs.length);
        for(uint i = 0; i<_pairs.length;i++){
            require(orderByHash[_hashs[i]].maker==msg.sender,"Exchange:Forbidden");
            cancleOrderByHash(_hashs[i]);
        }
    }

    // Internal Functions 
    function _createOrderGetHash(address _user, address[2] calldata tokens,  uint[2] calldata amounts ) internal returns (bytes32 hash_,uint price) {
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
        price = checkPrice( tokens,amounts);
        emit CreateOrder( hash_,  _user,  tokens[0],  tokens[1],  amounts[0],  amounts[1],price);
    }

    function executeOrder(address _user,address _pairHash, address[2] calldata tokens, uint[2] calldata amounts) internal returns(bytes32 hash_,uint price,uint _volume){
        if(locked[_pairHash]) revert Locked();
        locked[_pairHash] = true;
        uint[2] memory _tAmounts = amounts;
        uint[2] memory _fees;
     
        (hash_,price) = _createOrderGetHash( _user,  tokens,amounts);
        uint len = _range(_pairHash,price);
        for(uint i = _pair[_pairHash].orders[price].lastIndex; i< len;) {
            bytes32 __hash = _pair[_pairHash].orders[price].orderQueqe[i]; 
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
                        _pair[_pairHash].lastprice = price;

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
                            _pair[_pairHash].orders[price].lastIndex = i + 1;  
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
    
        _volume = tokens[0]==_pair[_pairHash].baseToken?( amounts[0]-_tAmounts[0]):(amounts[1]-_tAmounts[1]);
        _takeFee(tokens[0], tokens[1], _fees[0], _fees[1]);
        
        if(_tAmounts[0]!=0)
        _pair[_pairHash].orders[price].orderQueqe.push(hash_);


        locked[_pairHash] = false;
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

    function _transfer(address _token,address _to, uint _amount) internal {
        if(_token==address(weth)){
            vault.safeTokenTransfer(IERC20(_token), address(this), _amount);
            weth.withdraw(_amount);
            payable(_to).transfer(_amount);
            // TransferHelper.safeTransferETH(_to, _amount);
        } else {
            // IERC20(_token).transfer(_to,_amount);
            vault.safeTokenTransfer(IERC20(_token), _to, _amount);
            // TransferHelper.safeTransfer(_token, _to,_amount);
        }
    }

    function _takeFee(address _buyToken,address _sellToken,uint takerFee,uint makerFee) internal  {
        if(makerFee!=0){
            // IERC20(_buyToken).transfer(IExchangeFactory(factory).feeTo(),takerFee);
            _transfer(_buyToken,feeTo, makerFee);
        } 
        if(takerFee!=0) {
            // IERC20(_sellToken).transfer(IExchangeFactory(factory).feeTo(),makerFee);
            _transfer(_sellToken,feeTo, takerFee);
        }
    }
    
    // Internal View Functions 
    function _getFees(
        uint makerBuyAmount,
        uint makerSellAmount
      ) internal view returns(uint[2] memory fees ) {
          // (uint taker_fee_numerator, uint taker_fee_denominator, uint maker_fee_numerator, uint maker_fee_denominator) = IExchangeFactory(factory).getFees();
          uint takerFee;
          uint makerFee;
          makerFee = makerBuyAmount * maker_fee_numerator / maker_fee_denominator;
          takerFee = makerSellAmount * taker_fee_numerator / taker_fee_denominator;
          fees[0] = takerFee;
          fees[1] = makerFee;
          return (fees);
    }

    function _range(address _pairHash, uint _price) internal view virtual returns(uint) {
        uint length =  _pair[_pairHash].orders[_price].orderQueqe.length;
        uint lastIndex = _pair[_pairHash].orders[_price].lastIndex;
        if(_pair[_pairHash].orders[_price].orderQueqe.length!=0)
            return ((length-lastIndex) > 5 ? (lastIndex+5): length);
        else 
            return 0;
    }

    // Ownable Functions 

    function setFees(  
        uint256 _taker_fee_numerator,
        uint256 _taker_fee_denominator,
        uint256 _maker_fee_numerator,
        uint256 _maker_fee_denominator
    ) external  onlyOwner{
        taker_fee_numerator = _taker_fee_numerator;
        taker_fee_denominator = _taker_fee_denominator;
        maker_fee_numerator = _maker_fee_numerator;
        maker_fee_denominator = _maker_fee_denominator;
    }

    function setFeeTo(address _feeTo) external onlyOwner{
        feeTo = _feeTo;
    }

    function setListingFee(address _token, uint _fee) external onlyOwner {
        listingFees[_token] = _fee;
    }

    function setListingEnable(address _token, bool _status) external onlyOwner {
        listingEnable[_token] = _status;
    }

    function setMinAmt(address _pairHash, uint _amount ) external onlyOwner {
       _pair[_pairHash].minmunTxAmt = _amount;
    }

    // function withdraw(address _to,uint _amt) external onlyOwner {
    //     payable(_to).transfer(_amt);
    // }

    // function withdrawToken(address _token,address _to,uint _amt) external onlyOwner {
    //     IERC20(_token).transfer(_to,_amt);
    // }

    // Public or External View Functions 

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getFees() external view returns(uint taker_fee_numerator_, uint taker_fee_denominator_, uint maker_fee_numerator_, uint maker_fee_denominator_){
        taker_fee_numerator_ = taker_fee_numerator;
        taker_fee_denominator_ = taker_fee_denominator;
        maker_fee_numerator_ = maker_fee_numerator;
        maker_fee_denominator_ = maker_fee_denominator;
    }

    function checkPrice(address[2] calldata tokens,  uint[2] calldata amounts) public view  returns(uint price) {
        address fiatToken =  _pair[getPair[tokens[0]][tokens[1]]].pairToken;
        price = tokens[0]==fiatToken ? (amounts[0]*(10**IERC20(tokens[1]).decimals()))/amounts[1] : (amounts[1]*(10**IERC20(tokens[0]).decimals()))/amounts[0];
    }

    function getPriceByOrderHash(bytes32 _orderHash) public view returns(uint price) {
       LibOrder.Order memory order =  orderByHash[_orderHash];
        address fiatToken =  _pair[getPair[order.tokens[0]][order.tokens[1]]].pairToken;
        price = order.tokens[0]==fiatToken ? (order.amounts[0]*(10**IERC20(order.tokens[1]).decimals()))/order.amounts[1] : (order.amounts[1]*(10**IERC20(order.tokens[0]).decimals()))/order.amounts[0];
    }

    function getPairPrice(address _pairHash) public view  returns(uint price) {
       return _pair[_pairHash].lastprice;
    }

    function getTakersByOrderHash(bytes32 _hash) external view returns(bytes32[] memory) {
        return orderByHash[_hash].takerOrderHashs;
    } 

    function getOrdersByPrice(address pairHash, uint256 price) external  view returns  (uint lastIndex,bytes32[] memory queqe) {
       lastIndex =_pair[pairHash].orders[price].lastIndex;
       queqe =_pair[pairHash].orders[price].orderQueqe;
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

    function getPairInfo(address _pairHash) external view returns(address baseToken, address pairToken, uint minTxAmt) {
       return( _pair[_pairHash].baseToken, _pair[_pairHash].pairToken, _pair[_pairHash].minmunTxAmt);
    }

    function isCancelled(bytes32 __hash) public view returns(bool) {
        return cancelled[__hash];
    }

    function isCompleted(bytes32 __hash) public view returns(bool) {
        return compleated[__hash];
    }

    function getAllPairTokens() public view returns(address[] memory ) {
        return _pairTokens;
    }

    function pause() external onlyOwner {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory ){
        require(IERC20(path[0]).allowance(msg.sender,address(this))>=amountIn,"ERC20: allowance exceed");
        IERC20(path[0]).transferFrom(msg.sender,address(this),amountIn);
        IERC20(path[0]).approve(address(pancakeRouter),amountIn);
        uint[] memory amounts = pancakeRouter.swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
        emit Swap(path,  amounts);
        return amounts;
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory ){
        require(IERC20(path[0]).allowance(msg.sender,address(this))>=amountIn,"ERC20: allowance exceed");
        IERC20(path[0]).transferFrom(msg.sender,address(this),amountIn);
        IERC20(path[0]).approve(address(pancakeRouter),amountIn);
        uint[] memory amounts =  pancakeRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
        emit Swap(path,  amounts);
        return amounts;
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory ){
        uint[] memory amounts = pancakeRouter.swapExactETHForTokens{value:msg.value}(amountOutMin, path, to, deadline);
        emit Swap(path,  amounts);
        return amounts;
    }

    function getAmountOut(address[] calldata path, uint amount) external view returns(uint[] memory) {
        return pancakeRouter.getAmountsOut(amount,path);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external view returns (uint amountOut) {
        return pancakeRouter.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external view returns (uint amountIn) {
        return pancakeRouter.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts) {
        return pancakeRouter.getAmountsOut(amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts) {
        return pancakeRouter.getAmountsIn(amountOut, path);
    }

    function changePancakeRouter(address _newRouter) external  onlyOwner {
          pancakeRouter = IUniswapV2Router02(_newRouter);
    }

    function withdraw() external {
        payable(feeTo).transfer(address(this).balance);
    }
}