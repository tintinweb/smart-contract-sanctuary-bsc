// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SubscriptionHistory.sol";
import "./IUniswapV2Router.sol";

contract FlashInuSubscription is Ownable , SubscriptionHistory {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeMath for uint256;
    bool public subsEthStatus = false;
    bool public subsTokenStatus = false;
    AggregatorV3Interface internal priceFeedETH;
    IUniswapV2Router02 public uniswapV2Router;
    address public pair = 0x49b5374F0Ff4Cb8649a198Aca1F4a5E46DC50eBb;
    Counters.Counter private _orderIdCounter;
    uint256 public FLASH_DECIMAL = 18; 
    uint256 public weeklyETHRate = 0.15 ether;
    uint256 public montlyETHRate = 0.6 ether;
    IERC20 public token;
    address public constant deadAddress = address(0xdead);
    address public  feeReceiver = 0x25D8C376567d08aeE011DF11119249fce963f37e;
    uint256 public feeReceiverPercent = 0; 

    event BurnToken(address subscriber, uint256 amount, uint256 numberOfDays);

    constructor() {
        token = IERC20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47);
        priceFeedETH = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    function getLatestPriceETH() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeedETH.latestRoundData();
        return price;
    }

    function setWeekelyPriceETH(uint256 _price) external onlyOwner {
       weeklyETHRate = _price;
    }

    function setMonthlyPriceETH(uint256 _price) external onlyOwner {
       montlyETHRate = _price;
    }

    function totalSubscriptions() public view returns (uint256) {
     return _orderIdCounter.current();
    }

    function getNextOrderId() private returns (uint256){
      _orderIdCounter.increment();
     return _orderIdCounter.current();
   }

    function addSubscription(address _subscriber, uint256 _numberOfDays) public onlyOwner returns (uint256){
        require(_subscriber != address(0), "Can not be Zero address");
        addSubscriber(_subscriber,0,block.timestamp, block.timestamp + _numberOfDays * 1 days,false,false,getNextOrderId());
        return _orderIdCounter.current();

    }


    function getPrice_OLD() public view returns (uint256,uint256){
        IUniswapV2Pair _pair = IUniswapV2Pair(pair);
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = _pair.getReserves();
        uint256 weeklyAmount = reserve0 * weeklyETHRate / reserve1;
        uint256 monthlyAmount = reserve0 * montlyETHRate / reserve1;
        return (weeklyAmount * FLASH_DECIMAL ,monthlyAmount * FLASH_DECIMAL);
    }

     function getPrice() public view returns (uint256,uint256){
        return (15000 * FLASH_DECIMAL ,60000 * FLASH_DECIMAL);
    }

    function updateETHAggregator(address _ethAggr) public onlyOwner{
        require(_ethAggr != address(0), "Can not be Zero address");
        priceFeedETH = AggregatorV3Interface(_ethAggr);
    }

    function updateFeeReceiver(address _feeReceiver) public onlyOwner{
        require(_feeReceiver != address(0), "Can not be Zero address");
        feeReceiver = _feeReceiver;
    }

    function updateFeeReceiverPercent(uint256 _percent) public onlyOwner{

        feeReceiverPercent = _percent;
    }


    function updateToken(address tokenAddres) external onlyOwner {
        require(tokenAddres != address(0), "Can not be Zero address");
        token = IERC20(tokenAddres);
    }

    function updatepair(address tokenAddres) external onlyOwner {
        require(tokenAddres != address(0), "Can not be Zero address");
        pair = tokenAddres;
    }

    function setSubETHStatus(bool newState) public onlyOwner {
        subsEthStatus = newState;
    }

    function setSubTokenStatus(bool newState) public onlyOwner {
        subsTokenStatus = newState;
    }
    
    

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }


    function recoverToken(address _to,uint256 _tokenamount) external onlyOwner returns(bool _sent){
        require(_to != address(0), "Can not be Zero address");
        uint256 _contractBalance = IERC20(token).balanceOf(address(this));
        require(_contractBalance >= _tokenamount);
        _sent = IERC20(token).transfer(_to, _tokenamount);
    }

    function burnToken() external onlyOwner returns(bool _sent){
        uint256 _contractBalance = IERC20(token).balanceOf(address(this));
        require(_contractBalance > 0);
        _sent = IERC20(token).transfer(deadAddress, _contractBalance);
    }

    receive() external payable {}

    function approveTokens(uint256 _tokenamount) external returns(bool){
       IERC20(token).approve(address(this), _tokenamount);
       return true;
   }

   function checkAllowance(address sender) public view returns(uint256){
       return IERC20(token).allowance(sender, address(this));
   }
     
     
    function subscribeUsingEth(uint _numberOfDays) external payable {
        require(subsEthStatus, "Sub is Not active For ETH");
        require(_numberOfDays == 7 || _numberOfDays == 30, "This subs is not supported.");
        
         if(_numberOfDays == 7){
            require(weeklyETHRate <= msg.value, "Insufficient Balance");
        }else {
           require(montlyETHRate <= msg.value, "Insufficient Balance");
        }
        addSubscriber(msg.sender,msg.value,block.timestamp, block.timestamp + _numberOfDays * 1 days,false,true,getNextOrderId());
    }

    function subscribeUsingToken(uint256 _tokenamount,uint _numberOfDays) public returns(bool) {
        require(_tokenamount <= checkAllowance(msg.sender), "Please approve tokens before transferring");
        require(subsTokenStatus, "Sub is Not active For Token");
        require(_numberOfDays == 7 || _numberOfDays == 30, "This subs is not supported.");
        // Transfer to dead and fee recever address
        (uint256 weeklyAmount,uint256 monthlyAmount) = getPrice();
        uint256 tokenToBurn = _tokenamount;
        if(_numberOfDays == 7){
            require(_tokenamount >= weeklyAmount,"Not enough token supplied");
            tokenToBurn = weeklyAmount;
        }else {
            require(_tokenamount >= monthlyAmount,"Not enough token supplied");
            tokenToBurn = monthlyAmount;
        }
        uint256 tokenUsed = tokenToBurn;
        if(feeReceiverPercent>0){
           uint256 feeReceverPart =  feeReceiverPercent * tokenToBurn / 100;
            IERC20(token).transferFrom(msg.sender,feeReceiver, feeReceverPart);
            tokenToBurn = tokenToBurn - feeReceverPart;
        }

        if(tokenToBurn > 0){
            IERC20(token).transferFrom(msg.sender,deadAddress, tokenToBurn);
            emit BurnToken( msg.sender,  tokenToBurn, _numberOfDays);
        }
        
        addSubscriber(msg.sender,tokenUsed,block.timestamp, block.timestamp + _numberOfDays * 1 days,true,false,getNextOrderId());
       return true;
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

abstract contract SubscriptionHistory is Ownable {
    event UpdateSubscriptionEntries(address account, uint256 startDate, uint256 endDate,uint256 orderId);
    struct SubscriptionInfo {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        address subscriber;
        bool isToken;
        bool isETH;
        uint256 orderId;
    }

    struct OrderIdHistory {
        uint256 orderId;
    }
    mapping(address => OrderIdHistory[]) private _subscriberDetailsByAddress;
    mapping(address => SubscriptionInfo) private _activeSubscriptionByAddress;

    SubscriptionInfo[] internal _subscribers;

    constructor() {
        SubscriptionInfo memory zeroInfo = SubscriptionInfo(0, 0, 0, address(0),false, false,0);
        _subscribers.push(zeroInfo);
    }

    function addSubscriber(address subscriber, uint256 amount, uint256 startTime, uint256 endTime,bool isToken, bool isETH,uint256 orderId) internal returns (uint256 index) {
        index = _subscribers.length;
        SubscriptionInfo memory subsInfo = SubscriptionInfo(amount, startTime, endTime,subscriber, isToken,isETH,orderId);
        _subscribers.push(subsInfo);
        _activeSubscriptionByAddress[subscriber] = subsInfo;
        OrderIdHistory memory orderInfo = OrderIdHistory(orderId);
        _subscriberDetailsByAddress[subscriber].push(orderInfo);
        emit UpdateSubscriptionEntries(subscriber,startTime,endTime,orderId);
    }

    function getSubscriberByOrderId(uint256 orderId) public view returns(SubscriptionInfo memory subscriberInfo) {
        // if no data in map will get 0 index and zeroInfo.
        return _subscribers[orderId];
    }


    function getLastSubscribers(uint256 n) external view returns(SubscriptionInfo[] memory) {
        uint256 len = n > _subscribers.length ? _subscribers.length : n;

        SubscriptionInfo[] memory subInfo = new SubscriptionInfo[](len);

        for (uint256 i = 0; i < len; i++) {
            subInfo[i] = _subscribers[_subscribers.length - i - 1];
        }

        return _subscribers;
    }

    function getActiveSubscriptionByAddress(address subscriber) external view returns(SubscriptionInfo memory) {
        return _activeSubscriptionByAddress[subscriber];
    }


    function getSubscriptionHistoryByAddres(address subscriber, uint256 n) external view returns(SubscriptionInfo[] memory) {
        uint256 len = n > _subscribers.length ? _subscribers.length : n;

        SubscriptionInfo[] memory subInfo = new SubscriptionInfo[](len);
        OrderIdHistory[] memory oIdHistory = _subscriberDetailsByAddress[subscriber];
        

        for (uint256 i = 0; i < oIdHistory.length; i++) {
            subInfo[i] = _subscribers[oIdHistory[i].orderId];
        }

        return subInfo;
    }

    function getSubscriptionOrderIdHistory(address subscriber) external view returns(OrderIdHistory[] memory) {
        return _subscriberDetailsByAddress[subscriber];
    }



}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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