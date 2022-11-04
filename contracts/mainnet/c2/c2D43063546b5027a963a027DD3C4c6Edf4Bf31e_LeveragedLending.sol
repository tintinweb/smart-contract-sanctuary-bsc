/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

interface VBep20 {
    /**
     * @notice Sender supplies assets into the market and receives vTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param mintAmount The amount of the underlying asset to supply
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function mint(uint mintAmount) external returns (uint);

    /**
     * @notice Sender supplies assets into the market and receiver receives vTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param receiver the account which is receiving the vTokens
     * @param mintAmount The amount of the underlying asset to supply
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function mintBehalf(address receiver, uint mintAmount) external returns (uint);

    /**
     * @notice Sender redeems vTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemTokens The number of vTokens to redeem into underlying
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeem(uint redeemTokens) external returns (uint);
    /**
     * @notice Sender redeems vTokens in exchange for a specified amount of underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The amount of underlying to redeem
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    /**
      * @notice Sender borrows assets from the protocol to their own address
      * @param borrowAmount The amount of the underlying asset to borrow
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function borrow(uint borrowAmount) external returns (uint);
    /**
     * @notice Sender repays their own borrow
     * @param repayAmount The amount to repay
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function repayBorrow(uint repayAmount) external returns (uint);

    /**
     * @notice Sender repays a borrow belonging to borrower
     * @param borrower the account with the debt being payed off
     * @param repayAmount The amount to repay
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    /**
     * @notice The sender adds to reserves.
     * @param addAmount The amount fo underlying token to add as reserves
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function _addReserves(uint addAmount) external returns (uint);
}


interface BEP20Interface {
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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity ^0.5.16;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
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
contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

interface Unitroller {
    function enterMarkets(address[] calldata vTokens) external returns (uint[] memory);
}

interface IPancakeswapV2Rounter {
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
}

contract LeveragedLending is Ownable {
    using SafeMath for uint256;

    // ETHUSD price feed address
    address constant ETHUSD_PRICE_FEED_ADDRESS = 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e;
    // ETH BEP20 token address
    address constant ETH_ADDRESS = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    // VETH BEP20 token address
    address constant VETH_ADDRESS = 0xf508fCD89b8bd15579dc79A6827cB4686A3592c8;
    // USDT BEP20 token address
    address constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
    // VUSDT BEP20 token address
    address constant VUSDT_ADDRESS = 0xfD5840Cd36d94D7229439859C0112a4185BC0255;
    // WBNB Bep20 token address
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c ;
    // Unitroller address
    address constant UNITROLLER_ADDRESS = 0xfD36E2c2a6789Db23113685031d7F16329158384;
    // Pancakeswap V2 router address
    address constant PANCAKESWAP_V2_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Max integer
    uint256 constant MAX_UINT = uint256(-1);
    // Safe collateral percent
    uint256 constant SAFE_COLLATERAL_PERCENT = 70;
    // Balance limit percent
    uint256 constant BALANCE_LIMIT_PERCENT = 75;
    // Accumulated lend amount initially set to zero
    uint256 private accLendAmount;
    // Accumulated borrow amount initially set to zero
    uint256 private accBorrowAmount;

    // Get the latest ETHUSD price
    function getLatestPrice() public view returns (int) {
        (,int price,,,) = AggregatorV3Interface(ETHUSD_PRICE_FEED_ADDRESS).latestRoundData();
        return price;
    }

    // Initialize the leveraged lending protocol
    function init() public onlyOwner {
        // Init contracts
        BEP20Interface eth = BEP20Interface(ETH_ADDRESS);
        BEP20Interface usdt = BEP20Interface(USDT_ADDRESS);
        Unitroller unitroller = Unitroller(UNITROLLER_ADDRESS);

        // Enter market
        address[] memory vTokens = new address[](2);
        vTokens[0] = VETH_ADDRESS;
        vTokens[1] = VUSDT_ADDRESS;
        unitroller.enterMarkets(vTokens);

        // Arppvoe ETH and USDT
        eth.approve(VETH_ADDRESS, MAX_UINT);
        usdt.approve(VUSDT_ADDRESS, MAX_UINT);
        eth.approve(PANCAKESWAP_V2_ROUTER_ADDRESS, MAX_UINT);
        usdt.approve(PANCAKESWAP_V2_ROUTER_ADDRESS, MAX_UINT);
    }

    // Start leveraged lending with "amount" ETH and repeat it for "loopCount" times
    function join(uint256 amount, uint256 loopCount) public onlyOwner {
        // Init contracts
        BEP20Interface eth = BEP20Interface(ETH_ADDRESS);
        VBep20 vEth = VBep20(VETH_ADDRESS);
        VBep20 vUsdt = VBep20(VUSDT_ADDRESS);
        IPancakeswapV2Rounter router = IPancakeswapV2Rounter(PANCAKESWAP_V2_ROUTER_ADDRESS);

        // Send eth to the contract
        eth.transferFrom(msg.sender, address(this), amount);

        // Get ETHUSD price
        uint256 price = (uint256)(getLatestPrice());

        // Set path for swap ( USDT->WBNB->ETH )
        address[] memory path;
        path = new address[](3);
        path[0] = USDT_ADDRESS;
        path[1] = WBNB_ADDRESS;
        path[2] = ETH_ADDRESS;

        // Set lend amount
        uint256 lendAmount = amount;
        uint256 _accLendAmount = 0;
        uint256 _accBorrowAmount = 0;

        while(loopCount > 0) {

            // Deposit ETH
            vEth.mint(lendAmount);
            _accLendAmount += lendAmount;

            // Borrow USDT
            uint256 borrowAmount = lendAmount.mul(price).mul(SAFE_COLLATERAL_PERCENT).div(10 ** 22);
            vUsdt.borrow(borrowAmount);
            vUsdt.redeem(borrowAmount);
            _accBorrowAmount += borrowAmount;

            // Swap USDT to ETH
            uint[] memory amounts = router.swapExactTokensForTokens(
                borrowAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

            // Set amount to retrived ETH amount
            lendAmount = amounts[2];
            loopCount --;
        }
        accLendAmount = _accLendAmount;
        accBorrowAmount = _accBorrowAmount;
    }

    // Balance the current assets to prevent it from liquidation
    function balance() public onlyOwner {
        // Get ETHUSD price
        uint256 price = (uint256)(getLatestPrice());
        require(accLendAmount.mul(BALANCE_LIMIT_PERCENT).mul(price) < accBorrowAmount.mul(10 ** 22), "Balance call is not necessary.");

        // Caculate the redeem amount
        uint256 redeemAmount = (accBorrowAmount.mul(10 ** 22) - SAFE_COLLATERAL_PERCENT.mul(accLendAmount).mul(price)).div(price.mul((uint256)(100).sub(SAFE_COLLATERAL_PERCENT)));

        // Init contracts
        VBep20 vEth = VBep20(VETH_ADDRESS);
        VBep20 vUsdt = VBep20(VUSDT_ADDRESS);
        IPancakeswapV2Rounter router = IPancakeswapV2Rounter(PANCAKESWAP_V2_ROUTER_ADDRESS);

        // Set path for swap ( USDT->WBNB->ETH )
        address[] memory path;
        path = new address[](3);
        path[0] = ETH_ADDRESS;
        path[1] = WBNB_ADDRESS;
        path[2] = USDT_ADDRESS;
        
        // redeem ETH
        vEth.redeemUnderlying(redeemAmount);
        accLendAmount -= redeemAmount;

        // Swap ETH to USDT
        uint[] memory amounts = router.swapExactTokensForTokens(
        redeemAmount,
        0,
        path,
        address(this),
        block.timestamp
        );

        // Set amount to retrived ETH amount
        uint256 repayAmount = amounts[2];
        
        // Repay borrowed USDT
        vUsdt.repayBorrow(repayAmount);
        accBorrowAmount -= repayAmount;
    }

    // Withdraw funds
    function withdraw() public onlyOwner{
        // Init contracts
        BEP20Interface eth = BEP20Interface(ETH_ADDRESS);
        VBep20 vEth = VBep20(VETH_ADDRESS);
        VBep20 vUsdt = VBep20(VUSDT_ADDRESS);
        IPancakeswapV2Rounter router = IPancakeswapV2Rounter(PANCAKESWAP_V2_ROUTER_ADDRESS);

        // Set path for swap ( USDT->WBNB->ETH )
        address[] memory path;
        path = new address[](3);
        path[0] = ETH_ADDRESS;
        path[1] = WBNB_ADDRESS;
        path[2] = USDT_ADDRESS;
        
        // redeem ETH
        vEth.redeemUnderlying(accLendAmount);

        // Swap ETH to USDT
        uint[] memory amounts = router.swapTokensForExactTokens(
            accBorrowAmount,
            accLendAmount,
            path,
            address(this),
            block.timestamp
        );
        
        // Repay borrowed USDT
        vUsdt.repayBorrow(accBorrowAmount);
        eth.transfer(msg.sender, accLendAmount.sub(amounts[0]));

        // Init accumulated lend amount and borrow amount
        accLendAmount = 0;
        accBorrowAmount = 0;
    }
}