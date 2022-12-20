/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: GPL-3.0-or-later Or MIT
// File: contracts\Lib\Context.sol



pragma solidity ^0.6.0;

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts\Lib\Ownable.sol



pragma solidity ^0.6.0;
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
    constructor () internal {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts\Lib\SafeMath.sol



pragma solidity ^0.6.0;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts\Interface\IBEP20.sol



pragma solidity >=0.4.0;

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
    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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

// File: contracts\Referral.sol


pragma solidity ^0.6.0;
contract Referral is Ownable {
  using SafeMath for uint;

  /**
   * @dev Max referral level depth
   */
  uint8 constant MAX_REFER_DEPTH = 3;

  /**
   * @dev Max referee amount to bonus rate depth
   */
  uint8 constant MAX_REFEREE_BONUS_LEVEL = 3;


  /**
   * @dev The struct of account information
   * @param referrer The referrer addresss
   * @param reward The total referral reward of an address
   * @param referredCount The total referral amount of an address
   * @param lastActiveTimestamp The last active timestamp of an address
   */
  struct Account {
    address referrer;
    uint reward;
    uint referredCount;
    uint lastActiveTimestamp;
  }

  /**
   * @dev The struct of referee amount to bonus rate
   * @param lowerBound The minial referee amount
   * @param rate The bonus rate for each referee amount
   */
  struct RefereeBonusRate {
    uint lowerBound;
    uint rate;
  }

  event RegisteredReferer(address referee, address referrer);
  event RegisteredRefererFailed(address referee, address referrer, string reason);
  event PaidReferral(address from, address to, uint amount, uint level);
  event UpdatedUserLastActiveTime(address user, uint timestamp);

  mapping(address => Account) public accounts;

  uint256[] levelRate;
  uint256 referralBonus;
  uint256 decimals;
  uint256 secondsUntilInactive;
  bool onlyRewardActiveReferrers;
  RefereeBonusRate[] refereeBonusRateMap;

  IBEP20 public BUSD;

  /**
   * @param _decimals The base decimals for float calc, for example 1000
   * @param _referralBonus The total referral bonus rate, which will divide by decimals. For example, If you will like to set as 5%, it can set as 50 when decimals is 1000.
   * @param _secondsUntilInactive The seconds that a user does not update will be seen as inactive.
   * @param _onlyRewardActiveReferrers The flag to enable not paying to inactive uplines.
   * @param _levelRate The bonus rate for each level, which will divide by decimals too. The max depth is MAX_REFER_DEPTH.
   * @param _refereeBonusRateMap The bonus rate mapping to each referree amount, which will divide by decimals too. The max depth is MAX_REFER_DEPTH.
   * The map should be pass as [<lower amount>, <rate>, ....]. For example, you should pass [1, 250, 5, 500, 10, 1000] when decimals is 1000 for the following case.
   *
   *  25%     50%     100%
   *   | ----- | ----- |----->
   *  1ppl    5ppl    10ppl
   *
   * @notice refereeBonusRateMap's lower amount should be ascending
   */
  constructor(
    address _BUSD,
    uint _decimals,
    uint _referralBonus,
    uint _secondsUntilInactive,
    bool _onlyRewardActiveReferrers,
    uint256[] memory _levelRate,
    uint256[] memory _refereeBonusRateMap
  )
    public
  {
    require(_levelRate.length > 0, "Referral level should be at least one");
    require(_levelRate.length <= MAX_REFER_DEPTH, "Exceeded max referral level depth");
    require(_refereeBonusRateMap.length % 2 == 0, "Referee Bonus Rate Map should be pass as [<lower amount>, <rate>, ....]");
    require(_refereeBonusRateMap.length / 2 <= MAX_REFEREE_BONUS_LEVEL, "Exceeded max referree bonus level depth");
    require(_referralBonus <= _decimals, "Referral bonus exceeds 100%");
    require(sum(_levelRate) <= _decimals, "Total level rate exceeds 100%");

    BUSD = IBEP20(_BUSD);

    decimals = _decimals;
    referralBonus = _referralBonus;
    secondsUntilInactive = _secondsUntilInactive;
    onlyRewardActiveReferrers = _onlyRewardActiveReferrers;
    levelRate = _levelRate;

    // Set default referee amount rate as 1ppl -> 100% if rate map is empty.
    if (_refereeBonusRateMap.length == 0) {
      refereeBonusRateMap.push(RefereeBonusRate(1, decimals));
      return;
    }

    for (uint i; i < _refereeBonusRateMap.length; i += 2) {
      if (_refereeBonusRateMap[i+1] > decimals) {
        revert("One of referee bonus rate exceeds 100%");
      }
      // Cause we can't pass struct or nested array without enabling experimental ABIEncoderV2, use array to simulate it
      refereeBonusRateMap.push(RefereeBonusRate(_refereeBonusRateMap[i], _refereeBonusRateMap[i+1]));
    }
  }

  function sum(uint[] memory data) public pure returns (uint) {
    uint S;
    for(uint i;i < data.length;i++) {
      S += data[i];
    }
    return S;
  }


  /**
   * @dev Utils function for check whether an address has the referrer
   */
  function hasReferrer(address addr) public view returns(bool){
    return accounts[addr].referrer != address(0);
  }

  /**
   * @dev Get block timestamp with function for testing mock
   */
  function getTime() public view returns(uint256) {
    return block.timestamp; // solium-disable-line security/no-block-members
  }

  /**
   * @dev Given a user amount to calc in which rate period
   * @param amount The number of referrees
   */
  function getRefereeBonusRate(uint256 amount) public view returns(uint256) {
    uint rate = refereeBonusRateMap[0].rate;
    for(uint i = 1; i < refereeBonusRateMap.length; i++) {
      if (amount < refereeBonusRateMap[i].lowerBound) {
        break;
      }
      rate = refereeBonusRateMap[i].rate;
    }
    return rate;
  }

  function isCircularReference(address referrer, address referee) public view returns(bool){
    address parent = referrer;

    for (uint i; i < levelRate.length; i++) {
      if (parent == address(0)) {
        break;
      }

      if (parent == referee) {
        return true;
      }

      parent = accounts[parent].referrer;
    }

    return false;
  }

  /**
   * @dev Add an address as referrer
   * @param referrer The address would set as referrer of msg.sender
   * @return whether success to add upline
   */
  function addReferrer(address referrer) public returns(bool){
    if (referrer == address(0)) {
      emit RegisteredRefererFailed(msg.sender, referrer, "Referrer cannot be 0x0 address");
      return false;
    } else if (isCircularReference(referrer, msg.sender)) {
      emit RegisteredRefererFailed(msg.sender, referrer, "Referee cannot be one of referrer uplines");
      return false;
    } else if (accounts[msg.sender].referrer != address(0)) {
      emit RegisteredRefererFailed(msg.sender, referrer, "Address have been registered upline");
      return false;
    }

    Account storage userAccount = accounts[msg.sender];
    Account storage parentAccount = accounts[referrer];

    userAccount.referrer = referrer;
    userAccount.lastActiveTimestamp = getTime();
    parentAccount.referredCount = parentAccount.referredCount.add(1);

    emit RegisteredReferer(msg.sender, referrer);
    return true;
  }

  /**
   * @dev This will calc and pay referral to uplines instantly
   * @param value The number tokens will be calculated in referral process
   * @return the total referral bonus paid
   */
  function payReferral(uint256 value) public returns(uint256){
    Account memory userAccount = accounts[msg.sender];
    uint totalReferal;

    for (uint i; i < levelRate.length; i++) {
      address parent = userAccount.referrer;
      Account storage parentAccount = accounts[userAccount.referrer];

      if (parent == address(0)) {
        break;
      }

      if(onlyRewardActiveReferrers && parentAccount.lastActiveTimestamp.add(secondsUntilInactive) >= getTime() || !onlyRewardActiveReferrers) {
        uint c = value.mul(referralBonus).div(decimals);
        c = c.mul(levelRate[i]).div(decimals);
        c = c.mul(getRefereeBonusRate(parentAccount.referredCount)).div(decimals);

        totalReferal = totalReferal.add(c);

        parentAccount.reward = parentAccount.reward.add(c);
        // parent.transfer(c);
        BUSD.transferFrom(address(msg.sender), parent, c);
        emit PaidReferral(msg.sender, parent, c, i + 1);
      }

      userAccount = parentAccount;
    }

    updateActiveTimestamp(msg.sender);
    return totalReferal;
  }

  /**
   * @dev Developers should define what kind of actions are seens active. By default, payReferral will active msg.sender.
   * @param user The address would like to update active time
   */
  function updateActiveTimestamp(address user) public {
    uint timestamp = getTime();
    accounts[user].lastActiveTimestamp = timestamp;
    emit UpdatedUserLastActiveTime(user, timestamp);
  }

  function setSecondsUntilInactive(uint _secondsUntilInactive) public onlyOwner {
    secondsUntilInactive = _secondsUntilInactive;
  }

  function setOnlyRewardAActiveReferrers(bool _onlyRewardActiveReferrers) public onlyOwner {
    onlyRewardActiveReferrers = _onlyRewardActiveReferrers;
  }
}

// File: contracts\Presale.sol


pragma solidity ^0.6.0;
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

contract MDRPresale is Ownable, Referral {
    using SafeMath for uint256;

    IBEP20 public MDR;
    
    uint256 public startDate = 1669177000;                  // 2022/11/25 02:00:00 UTC
    uint256 public endDate = 1669180000;                    // 2022/12/9 02:00:00 UTC
    
    uint256 public totalTokensToSell = 50000000 * 10**18;   // 50000000 MDR tokens for sell
    uint256 public mdrPerBusd = 10 * 10**18;                // 1 Busd = 10 MDR
    uint256 public minPerTransaction = 100 * 10**18;        // min amount per transaction (100 BUSD)
    uint256 public maxPerUser = 2000 * 10**18;              // max amount per user (2000 BUSD)
    uint256 public totalSold;

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    bool public saleEnded;
    
    mapping(address => uint256) public mdrPerAddresses;

    event tokensBought(address indexed user, uint256 amountSpent, uint256 amountBought, string tokenName, uint256 date);
    event tokensClaimed(address indexed user, uint256 amount, uint256 date);
    event addLiquidityEvent(uint256 tokenAmount, uint256 ethAmount, uint256 allowance);

    modifier checkSaleRequirements(uint256 buyAmount) {
        require(now >= startDate && now < endDate, 'MDR Presale time passed');
        require(saleEnded == false, 'Sale ended');
        require(
            buyAmount > 0 && buyAmount <= unsoldTokens(),
            'Insufficient buy amount'
        );
        _;
    }

    address public adminWallet;
    address public stakePool;

    uint256 public stakePoolRate = 1000; // 10%
    uint256 public liquidityRate = 4000; // 40%

    constructor(
        address _MDR,
        address _BUSD,
        uint _decimals,
        uint _referralBonus,
        uint _secondsUntilInactive,
        bool _onlyRewardActiveReferrers,
        uint256[] memory _levelRate,
        uint256[] memory _refereeBonusRateMap
    ) Referral (
        _BUSD,
        _decimals,
        _referralBonus,
        _secondsUntilInactive,
        _onlyRewardActiveReferrers,
        _levelRate,
        _refereeBonusRateMap
    ) public {
        MDR = IBEP20(_MDR);
    }

    // Function to buy MDR using BUSD token
    function buyWithBUSD(uint256 buyAmount, address referrer) public payable checkSaleRequirements(buyAmount) {
        require(adminWallet != address(0), "Presale: admin address is not valid.");
        require(stakePool != address(0), "Presale: stake pool is not valid.");

        uint256 amount = calculateBUSDAmount(buyAmount);
        require(BUSD.balanceOf(msg.sender) >= amount, 'Insufficient BUSD balance');
        require(buyAmount >= minPerTransaction, 'Lower than the minimal transaction amount');
        
        if(!hasReferrer(msg.sender)){
            addReferrer(msg.sender);
        }

        // pay referral
        payReferral(amount);

        uint256 referralAmount = amount * referralBonus / decimals;
        uint256 stakePoolAmount = amount * stakePoolRate / decimals;
        uint256 liquidityAmount = amount * liquidityRate / decimals;

        // send BUSD to stakePool
        BUSD.transferFrom(address(msg.sender), stakePool, stakePoolAmount);

        // add Liquidity
        addLiquidity(MDR.balanceOf(address(this)) / 10, liquidityAmount);

        // send BUSD to admin
        BUSD.transferFrom(address(msg.sender), adminWallet, BUSD.balanceOf(address(this)));

        uint256 sumSoFar = mdrPerAddresses[msg.sender].add(buyAmount);
        require(sumSoFar <= maxPerUser, 'Greater than the maximum purchase limit');

        mdrPerAddresses[msg.sender] = sumSoFar;
        totalSold = totalSold.add(buyAmount);
        
        MDR.transfer(msg.sender, buyAmount);
        emit tokensBought(msg.sender, amount, buyAmount, 'BUSD', now);
    }

    // function to set the presale start date
    function setStartDate(uint256 _startDate) public onlyOwner {
        require(_startDate < endDate);
        startDate = _startDate;
    }

    // function to set the presale end date
    function setEndDate(uint256 _endDate) public onlyOwner {
        require(_endDate > startDate);
        endDate = _endDate;
    }

    // function to set the total tokens to sell
    function setTotalTokensToSell(uint256 _totalTokensToSell) public onlyOwner {
        totalTokensToSell = _totalTokensToSell;
    }

    // function to set the minimal transaction amount
    function setMinPerTransaction(uint256 _minPerTransaction) public onlyOwner {
        minPerTransaction = _minPerTransaction;
    }

    // function to set the maximum amount which a user can buy
    function setMaxPerUser(uint256 _maxPerUser) public onlyOwner {
        maxPerUser = _maxPerUser;
    }

    // function to set the total tokens to sell
    function setTokenPricePerBUSD(uint256 _mdrPerBusd) public onlyOwner {
        require(_mdrPerBusd > 0, "Invalid MDR price per BUSD");
        mdrPerBusd = _mdrPerBusd;
    }

    //function to end the sale
    function endSale() public onlyOwner {
        require(saleEnded == false);

        saleEnded = true;
        
        // uint256 teamAmount = address(this).balance.div(10);
        // uint256 bnbAmount = address(this).balance - teamAmount;
        // uint256 tokenAmount = MDR.balanceOf(address(this));

        // teamAddr.transfer(teamAmount);
        // addLiquidity(tokenAmount, bnbAmount);

    }

    //function to withdraw unsold tokens
    function withdrawUnsoldTokens() public onlyOwner {
        uint256 remainedTokens = unsoldTokens();
        require(remainedTokens > 0, "No remained tokens");
        MDR.transfer(owner(), remainedTokens);
    }

    //function to withdraw locked lp tokens
    function withdrawLockedLPTokens() public onlyOwner {
        uint256 lockedLPTokens = lockedLPTokens();
        require(lockedLPTokens > 0, "No locked LP tokens");

        IUniswapV2Pair(uniswapV2Pair).transfer(owner(), lockedLPTokens);
    }

    //function to return the amount of unsold tokens
    function unsoldTokens() public view returns (uint256) {
        // return totalTokensToSell.sub(totalSold);
        return MDR.balanceOf(address(this));
    }

    //function to return the amount of unsold tokens
    function lockedLPTokens() public view returns (uint256) {
        // return totalTokensToSell.sub(totalSold);
        return IUniswapV2Pair(uniswapV2Pair).balanceOf(address(this));
    }

    //function to calculate the quantity of MDR token based on the MDR price of busdAmount
    function calculateMDRAmount(uint256 busdAmount) public view returns (uint256) {
        uint256 mdrAmount = mdrPerBusd.mul(busdAmount).div(10**18);
        return mdrAmount;
    }

    //function to calculate the quantity of bnb needed using its MDR price to buy `buyAmount` of MDR tokens.
    function calculateBUSDAmount(uint256 mdrAmount) public view returns (uint256) {
        require(mdrPerBusd > 0, "MDR price per BUSD should be greater than 0");
        uint256 busdAmount = mdrAmount.mul(10**18).div(mdrPerBusd);
        return busdAmount;
    }

    function setRouter(address _router) public onlyOwner{
        require(saleEnded == false);
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(_router);

        if (IUniswapV2Factory(_newPancakeRouter.factory()).getPair(address(MDR), _newPancakeRouter.WETH()) == address(0)) {
            uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(MDR), _newPancakeRouter.WETH());
        } else {
            uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).getPair(address(MDR), _newPancakeRouter.WETH());
        }
        
        uniswapV2Router = _newPancakeRouter;
    }

    function addLiquidity(uint256 tokenAmount, uint256 busdAmount) private {
        // approve token transfer to cover all possible scenarios
        MDR.approve(address(uniswapV2Router), tokenAmount);
        BUSD.approve(address(uniswapV2Router), busdAmount);
        uint256 allowance = MDR.allowance(address(this), address(uniswapV2Router));
        
        emit addLiquidityEvent(tokenAmount, busdAmount, allowance);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(MDR),
            address(BUSD),
            tokenAmount,
            busdAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function updateAdminWallet(address _adminWallet) public onlyOwner {
        require(_adminWallet != address(0), "Presale: Invalid address.");
        adminWallet = _adminWallet;
    }

    function updateStakePool(address _stakePool) public onlyOwner {
        require(_stakePool != address(0), "Presale: Invalid address.");
        stakePool = _stakePool;
    }

    function updateStakePoolRate(uint256 _stakePoolRate) public onlyOwner {
        require(_stakePoolRate < decimals, "Presale: Rate is not valid");
        stakePoolRate = _stakePoolRate;
    }

    function updateLiquidityRate(uint256 _liquidityRate) public onlyOwner {
        require(_liquidityRate < decimals, "Presale: Rate is not valid");
        liquidityRate = _liquidityRate;
    }
}