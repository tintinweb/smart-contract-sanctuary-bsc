/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract Sale is Ownable {
    using SafeMath for uint256;

    struct PaymentTier {
        uint256 price;     // currency unit: dollar
        uint256 startTime;
        uint256 endTime;
    }


    uint256 private PRICE_BASE = 10 ** 8;
    uint256 private MAIN_RATE = 95;     // 95 %
    uint256 private MAKERTING_RATE = 5;  // 5%

    // variables
    IBEP20 public token;

    AggregatorV3Interface internal priceFeed;

    // start time and end time of sale
    uint256 public saleStart = block.timestamp;     // start sale from 1 Apr 2022: 1648771201
    uint256 public saleEnd = ~uint256(0);            // default end sale to infinity

    // the total number of token for sale
    uint256 public supply = 0;

    // the sale info for each round
    PaymentTier[] public paymentTiers;

    // the total tokens distributed.
    uint256 public distributedAmount = 0;

    uint256 public totalBndAmount = 0;

    address mainWallet;
    address marketingWallet;

    uint256 private bnbThreshold = 0;


    constructor(address tokenAddress, address _mainWallet, address _marketingWallet) {
        /**
        * Network: Binance Smart Chain
        * Aggregator: BNB/USD
        * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        */
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

        token = IBEP20(tokenAddress);

        mainWallet = _mainWallet;
        marketingWallet = _marketingWallet;

        // round 1:  Aug 4st - Aug 7th, 2022
        paymentTiers.push(
            PaymentTier({
              price: 20 * (10 ** 16),    // $0.2
              startTime: saleStart,      // from  Aug 4st
              endTime: 1664582399        // to Aug 7th, 2022
            })
		    );

        // round 2:  Aug 8th - Aug 14th, 2022
        paymentTiers.push(
            PaymentTier({
              price: 75 * (10 ** 16),     // $0.75
              startTime: 1664582400,      // from 1 October 2022
              endTime: 1672531199         // to Aug 14th, 2022
            })
		    );

        // round 3:  Aug 15th - Aug 21st, 2022
        paymentTiers.push(
            PaymentTier({
              price: 85 * (10 ** 16),     // $0.85
              startTime: 1664582400,      // from ug 15th 2022
              endTime: 1672531199         // to Aug 21st, 2022
            })
		    );

        // round 4:   Aug 22nd - Sep 18th, 2022
        paymentTiers.push(
            PaymentTier({
              price: 85 * (10 ** 16),     // $0.85
              startTime: 1664582400,      // from Aug 22nd 2022
              endTime: 1672531199         // to Sep 18th, 2022
            })
		    );
    }

    function adminAddTokenAmount(uint256 amount) public onlyOwner {
        require(amount > 0, "adminAddTokenAmount: amount must greater than 0");
		uint256 oldBalance = token.balanceOf(address(this));
		token.transferFrom(msg.sender, address(this), amount);
		uint256 delta = token.balanceOf(address(this)).sub(oldBalance);
		supply = supply.add(delta);
    }

    function adminSetSaleEndTime(uint256 endTime) public onlyOwner {
        require(endTime > 1672531200, "adminSetSaleEndTime: End time must greater than 00:00:00 1/Jan/2023");
        saleEnd = endTime;
        paymentTiers[2].endTime = saleEnd;
    }

    function adminSetBnbThreshold(uint256 bnbAmount) public onlyOwner {
        require(bnbAmount > 0, "adminSetBnbThreshold: bnb amount must greater than 0");
        bnbThreshold = bnbAmount;
    }

    function adminGetBnbThreshold() public view onlyOwner returns (uint256){
        return bnbThreshold;
    }

    function adminWithdrawToken() public onlyOwner{
        token.transfer(msg.sender, token.balanceOf(address(this)));
        supply = 0;
    }


    receive() external payable {
        buyToken();
    }

    function buyToken () public payable {
        require(block.timestamp >= saleStart &&  block.timestamp <= saleEnd, "buyToken: Sale is not active this time");
	/*	require(supply > 0, "buyToken: sale ended, everything was sold");

        // Calculate the amount of token.
        uint256 tokenAmount = calculateTokensAmount(msg.value);
        require(distributedAmount.add(tokenAmount) <= supply, "buyToken: not enough token for sale");
*/
        totalBndAmount = totalBndAmount.add(msg.value);

        // purpose: in order to reduce the gas
        if (totalBndAmount >= bnbThreshold) {
            uint256 marketingAmount = totalBndAmount.mul(MAKERTING_RATE).div(100);
            uint256 mainAmount = totalBndAmount.sub(marketingAmount);

            // Transfer BNB to wallets
            payable(mainWallet).transfer(mainAmount);
            payable(marketingWallet).transfer(marketingAmount);

            totalBndAmount = 0;
        }

        // Transfer the token to buyer
    /*    token.transfer(msg.sender, tokenAmount);

        supply = supply.sub(tokenAmount);
        distributedAmount = distributedAmount.add(tokenAmount);  */
        
    }

    function calculateTokensAmount(uint256 amount) public view returns(uint256) {
        // Get the current token price
        uint256 tokenPrice = getPrice();
        require(tokenPrice > 0, "calculateTokensAmount: token price must be greater than 0");

        // Get the current BNB/USD exchange.
        uint256 bnb_usd = uint256(getLatestPrice());
        require(bnb_usd > 0, "calculateTokensAmount: can't get the BNB/USD exchange");

        // Calculate the amount of token.
        uint256 tokenAmount = amount.mul(bnb_usd).mul(1 ether).div(tokenPrice).div(PRICE_BASE);

        return tokenAmount;
    }

    function getPrice() private view returns (uint256) {
      for (uint256 i = 0; i < 3; i++) {
        if (block.timestamp >= paymentTiers[i].startTime && block.timestamp <= paymentTiers[i].endTime) {
          return paymentTiers[i].price;
        }
      }
      return 0;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int256) {
        (uint80 roundID, int256 price, uint256 startedAt, uint256 timeStamp, uint80 answeredInRound) = priceFeed.latestRoundData();
        return price;
    }
}