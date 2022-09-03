/**
 *Submitted for verification at BscScan.com on 2022-09-02
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
        uint256 rate;     // exchange rate
        uint256 startTime;
        uint256 endTime;
    }

    uint8 private BNB_CURRENCY = 1;
    uint8 private USDT_CURRENCY = 2;

    uint256 private MAIN_RATE = 100;     // 100%
    uint256 private MAKERTING_RATE = 0;  // 0%

    // variables
    IBEP20 public token;
    IBEP20 public usdtToken;

    AggregatorV3Interface internal priceFeed;

    // start time and end time of sale
    uint256 public saleStart = block.timestamp;     // start sale
    uint256 public saleEnd = ~uint256(0);            // default end sale to infinity

    // the total number of token for sale
    uint256 public supply = 0;

    // the sale info for each round
    PaymentTier[] public paymentTiers;

    // the total tokens distributed.
    uint256 public distributedAmount = 0;

    uint256 public totalBNBAmount = 0;
    uint256 public totalUSDTAmount = 0;
    uint256 public totalAmount = 0;
    address mainWallet;
    address marketingWallet;

    uint256 private BNBThreshold = 0;
    uint256 private USDTThreshold = 0;


    constructor(address tokenAddress, address usdtAddress, address _mainWallet, address _marketingWallet) {

        //USDT address testnet = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
        //Token address testnet = 0x09D917575697e36867b0D567d1dd187D2ec173c0

        // link: https://docs.chain.link/docs/bnb-chain-addresses/
        /**
        * Network: Binance Smart Chain
        * Aggregator: USDT / BNB
        * Address: 0xD5c40f5144848Bd4EF08a9605d860e727b991513
        */
        priceFeed = AggregatorV3Interface(0xD5c40f5144848Bd4EF08a9605d860e727b991513);

        token = IBEP20(tokenAddress);
        usdtToken = IBEP20(usdtAddress);

        mainWallet = _mainWallet;
        marketingWallet = _marketingWallet;

        // Presale:
        paymentTiers.push(
            PaymentTier({
                rate: 5000,                 // 1 BNB = 5000 Token 
                startTime: saleStart,      // from Saturday, 27 August 2022 0:00:00
                endTime: 1661990400        // to Thursday, 1 September 2022 0:00:00
            })
		);

        // round 1:
        paymentTiers.push(
            PaymentTier({
                rate: 4500,                 // 1 BNB = 4500 Token 
                startTime: 1661990400,      // from Thursday, 1 September 2022 0:00:00
                endTime: 1662595200         // to  Thursday, 8 September 2022 0:00:00
            })
        );

        // round 2:
        paymentTiers.push(
            PaymentTier({
                rate: 4000,                 // 1 BNB = 4000 Token 
                startTime: 1662595200,      // from Thursday, 8 September 2022 0:00:00
                endTime: 1663200000         // to  Thursday, 15 September 2022 0:00:00
            })
		);

        // round 3:
        paymentTiers.push(
            PaymentTier({
                rate: 3500,                 // 1 BNB = 3500 Token 
                startTime: 1663200000,      // from Thursday, 15 September 2022 0:00:00
                endTime: 1663804800         // to  Thursday, 22 September 2022 0:00:00
            })
		);

        // round 4: 
        paymentTiers.push(
            PaymentTier({
                rate: 3000,                 // 1 BNB = 3000 Token 
                startTime: 1663804800,      // from Thursday, 22 September 2022 0:00:00
                endTime: 1695340800         // to  Friday, 22 September 2023 0:00:00
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

    function adminSetBNBThreshold(uint256 bnbAmount) public onlyOwner {
        require(bnbAmount > 0, "adminSetBNBThreshold: bnb amount must greater than 0");
        BNBThreshold = bnbAmount;
    }

    function adminGetBNBThreshold() public view onlyOwner returns (uint256){
        return BNBThreshold;
    }

    function adminSetUSDTThreshold(uint256 usdtAmount) public onlyOwner {
        require(usdtAmount > 0, "adminSetUSDTThreshold: bnb amount must greater than 0");
        USDTThreshold = usdtAmount;
    }

    function adminGetUSDTThreshold() public view onlyOwner returns (uint256){
        return USDTThreshold;
    }

    function adminWithdrawBNB() public payable onlyOwner{
        payable(msg.sender).transfer(totalBNBAmount);
        totalBNBAmount = 0;
    }

    function adminWithdrawUSDT() public onlyOwner{
        usdtToken.transfer(msg.sender, totalUSDTAmount);
        totalUSDTAmount = 0;
    }

    function adminWithdrawToken() public onlyOwner{
        token.transfer(msg.sender, token.balanceOf(address(this)));
        supply = 0;
    }


    receive() external payable {
        buyToken();
    }

    // buy token by BNB
    function buyToken () public payable {
        require(block.timestamp >= saleStart &&  block.timestamp <= saleEnd, "buyToken: Sale is not active this time");
		/*require(supply > 0, "buyToken: sale ended, everything was sold");

        // Calculate the amount of token.
        uint256 tokenAmount = calculateTokensAmount(BNB_CURRENCY, msg.value);
        require(distributedAmount.add(tokenAmount) <= supply, "buyToken: not enough token for sale");
    */
        totalBNBAmount = totalBNBAmount.add(msg.value);
        totalAmount = totalAmount.add(msg.value);
        // purpose: in order to reduce the gas
        if (totalBNBAmount >= BNBThreshold) {
            uint256 marketingAmount = totalBNBAmount.mul(MAKERTING_RATE).div(100);
             uint256 mainAmount = totalBNBAmount.sub(marketingAmount);

            // Transfer BNB to wallets
            payable(mainWallet).transfer(mainAmount);

            // Only transfer when having token.
            if (marketingAmount > 0) {
                payable(marketingWallet).transfer(marketingAmount);
            }

            totalBNBAmount = 0;
        }

        // Transfer the token to buyer
    /*    token.transfer(msg.sender, tokenAmount);

        // update supply and distributed amount
        supply = supply.sub(tokenAmount);
        distributedAmount = distributedAmount.add(tokenAmount);    */
    }

    // buy token by USDT
    function buyTokenByUSDT (uint256 amount)  external  {
        require(block.timestamp >= saleStart &&  block.timestamp <= saleEnd, "buyTokenByUSDT: Sale is not active this time");
	/*	require(supply > 0, "buyTokenByUSDT: sale ended, everything was sold");

        // Calculate the amount of token.
        uint256 tokenAmount = calculateTokensAmount(USDT_CURRENCY, amount);
        require(distributedAmount.add(tokenAmount) <= supply, "buyTokenByUSDT: not enough token for sale");
    */
        // Transfer USDT from buyer's wallet to contract.
       uint256 tokenAmount = calculateTokensAmount(USDT_CURRENCY, amount);
        usdtToken.transferFrom(msg.sender, address(this), amount);
        totalAmount = totalAmount.add(tokenAmount);
        // Update amount
        totalUSDTAmount = totalUSDTAmount.add(amount);

        // purpose: in order to reduce the gas
        if (totalUSDTAmount >= USDTThreshold) {
            uint256 marketingAmount = totalUSDTAmount.mul(MAKERTING_RATE).div(100);
            uint256 mainAmount = totalUSDTAmount.sub(marketingAmount);

            // Transfer USDT to main wallet
            usdtToken.transfer(mainWallet, mainAmount);

            // Only transfer when having token.
            if (marketingAmount > 0) {
                // Transfer USDT to marketing wallet
                usdtToken.transfer(marketingWallet, marketingAmount);
            }

            totalUSDTAmount = 0;
        }

        // Transfer the token to buyer
       // token.transfer(msg.sender, tokenAmount);

        // update supply and distributed amount
      //  supply = supply.sub(tokenAmount);
        //distributedAmount = distributedAmount.add(tokenAmount);
    }

    function calculateTokensAmount(uint8 currency, uint256 amount) public view returns(uint256) {
        require((currency == BNB_CURRENCY) || (currency == USDT_CURRENCY), "calculateTokensAmount: only support BNB or USDT");

        // Get the current token exchange rate
        uint256 rate = getRate();
        require(rate > 0, "calculateTokensAmount: token exchange rate must be greater than 0");

        uint256 bnbAmount = 0;
        if (currency == USDT_CURRENCY) {
            // Get the current USDT/BNB exchange.
            uint256 usdt_bnb = uint256(getLatestPrice());
            require(usdt_bnb > 0, "calculateTokensAmount: can't get the USDT/BNB exchange");
            bnbAmount = amount.mul(usdt_bnb).div(1 ether);
        } else {
            bnbAmount = amount;
        }
        
        // Calculate the amount of token.
        uint256 tokenAmount = bnbAmount.mul(rate);

        return tokenAmount;
    }

    function getRate() private view returns (uint256) {
        for (uint256 i = 0; i < 3; i++) {
            if (block.timestamp >= paymentTiers[i].startTime && block.timestamp <= paymentTiers[i].endTime) {
                return paymentTiers[i].rate;
            }
        }
        return 0;
    }

    function getTotalAmount() public view returns (uint256) {
        
        return totalAmount;
    }

    /**
     * Returns the latest price (USDT/BNB)
     */
    function getLatestPrice() public view returns (int256) {
        (uint80 roundID, int256 price, uint256 startedAt, uint256 timeStamp, uint80 answeredInRound) = priceFeed.latestRoundData();

        require(roundID >= 0, "getLatestPrice: have no round id");
        require(startedAt >= 0, "getLatestPrice: have no start time");
        require(timeStamp >= 0, "getLatestPrice: have no timestamp");
        require(answeredInRound >= 0, "getLatestPrice: have no answered");

        return price;
        
    }
}