/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT
// Developed by: dxsoftware.net

pragma solidity 0.8.13;

interface IBEP20 {
  /**
   * @dev Returns the total tokens supply
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

interface Kapex is IBEP20 {
  function burn(uint256 amount) external;
}

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
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data; // msg.data is used to handle array, bytes, string
  }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  /**
   * @dev Performs a Solidity function call using a low level `call`. A
   * plain`call` is an unsafe replacement for a function call: use this
   * function instead.
   *
   * If `target` reverts with a revert reason, it is bubbled up by this
   * function (like regular Solidity function calls).
   *
   * Returns the raw returned data. To convert to the expected return value,
   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
   *
   * Requirements:
   *
   * - `target` must be a contract.
   * - calling `target` with `data` must not revert.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
   * `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but also transferring `value` wei to `target`.
   *
   * Requirements:
   *
   * - the calling contract must have an BNB balance of at least `value`.
   * - the called Solidity function must be `payable`.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  /**
   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
   * with `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }

  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
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
  address private _previousOwner;
  uint256 private _lockTime;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function d_owner() public view returns (address) {
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

  function f_getUnlockTime() public view returns (uint256) {
    return _lockTime;
  }

  //Locks the contract for owner for the amount of time provided
  function lock(uint256 time) public virtual onlyOwner {
    _previousOwner = _owner;
    _owner = address(0);
    _lockTime = block.timestamp + time;
    emit OwnershipTransferred(_owner, address(0));
  }

  //Unlocks the contract for owner when _lockTime is exceeds
  function unlock() public virtual {
    require(_previousOwner == msg.sender, "You don't have permission to unlock");
    require(block.timestamp > _lockTime, "Contract is locked until 7 days");
    emit OwnershipTransferred(_owner, _previousOwner);
    _owner = _previousOwner;
    _previousOwner = address(0);
  }
}

// pragma solidity >=0.5.0;

interface ISummitSwapFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface ISummitSwapPair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface ISummitSwapRouter01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;

interface ISummitSwapRouter02 is ISummitSwapRouter01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

contract KAPEX_Fee_Manager is Context, Ownable {
  using SafeMath for uint256;
  using Address for address;

  uint256 public feeRoyalty = 200; //+ Sent to 1144 royalty list

  uint256 public feeKodaBurn = 200; //+ Sent to dead adress
  uint256 public feeKodaLiquidity = 100; //+ 0.5% sold to BNB, 0.5% sold to KODA
  uint256 public feeKodaKapexLiquidity = 150; //+ KAPEX/KODA pair on SummitSwap

  uint256 public feeKapexLiquidity = 150; //+ 1.5% sold to BNB and paired with KAPEX (PancakeSwap & SummitSwap)

  uint256 public feeStakingPool = 250; //+ Sent to Kapex staking pool
  uint256 public feeBurn = 0; //+ Burnt
  uint256 public feeMarketing = 200; //+ Sent to marketing wallet
  uint256 public feeDev = 0; //+ Sent to treasury

  uint256 public feeTotal;

  address payable public royaltyAddress = payable(0x47965804C22fCBa3d3300226F5F159F32D7da9A6);
  address payable public marketingAddress = payable(0x34BCBcB56e1fDDc78151c0c96662f9CF79dd607c);
  address payable public devAddress = payable(0x709bF4aC7ED6Bb2F9d60b1215d983496AB68efbc);
  address payable public burnAddress = payable(0x000000000000000000000000000000000000dEaD);
  address payable public stakingPoolAddress = payable(0x92ccc28B0e6E106c87568fC4A43C383c00D29BfD);
  address payable public lpTokensLockAddress = payable(0xdE2379768295879F71d6886EFCD9c5A580884C26);

  IBEP20 public kodaToken = IBEP20(0x8094e772fA4A60bdEb1DfEC56AB040e17DD608D5);
  Kapex public kapexToken = Kapex(0x11441AFb1D10E3Ce4E39666FC4F4A2A5d6d8C0Da);

  ISummitSwapRouter02 public summitSwapRouter = ISummitSwapRouter02(0x2e8C54d980D930C16eFeb28f7061b0f3A78c0A87);
  ISummitSwapRouter02 public pancakeSwapRouter = ISummitSwapRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

  bool private inSwapAndLiquify; // after each successfull swapandliquify disable the swapandliquify

  event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqiudity); // fire event how many tokens were swapedandLiquified

  constructor() {
    updateTotalFee();
  }

  function updateTotalFee() private {
    feeTotal = feeRoyalty
      .add(feeKodaBurn)
      .add(feeKodaLiquidity)
      .add(feeKodaKapexLiquidity)
      .add(feeKapexLiquidity)
      .add(feeMarketing)
      .add(feeStakingPool)
      .add(feeDev)
      .add(feeBurn);
  }

  function resetFees(
    uint256 _feeRoyalty,
    uint256 _feeKodaBurn,
    uint256 _feeKodaLiquidity,
    uint256 _feeKodaKapexLiquidity,
    uint256 _feeKapexLiquidity,
    uint256 _feeStakingPool,
    uint256 _feeBurn,
    uint256 _feeMarketing,
    uint256 _feeDev
  ) external onlyOwner {
    feeRoyalty = _feeRoyalty;
    feeKodaBurn = _feeKodaBurn;
    feeKodaLiquidity = _feeKodaLiquidity;
    feeKodaKapexLiquidity = _feeKodaKapexLiquidity;
    feeKapexLiquidity = _feeKapexLiquidity;
    feeStakingPool = _feeStakingPool;
    feeBurn = _feeBurn;
    feeMarketing = _feeMarketing;
    feeDev = _feeDev;
    updateTotalFee();
  }

  function setFeeRoyalty(uint256 fee) external onlyOwner {
    feeRoyalty = fee;
    updateTotalFee();
  }

  function setFeeKodaBurn(uint256 fee) external onlyOwner {
    feeKodaBurn = fee;
    updateTotalFee();
  }

  function setFeeKodaLiquidity(uint256 fee) external onlyOwner {
    feeKodaLiquidity = fee;
    updateTotalFee();
  }

  function setFeeKodaKapexLiquidity(uint256 fee) external onlyOwner {
    feeKodaKapexLiquidity = fee;
    updateTotalFee();
  }

  function setFeeKapexLiquidity(uint256 fee) external onlyOwner {
    feeKapexLiquidity = fee;
    updateTotalFee();
  }

  function setFeeMarketing(uint256 fee) external onlyOwner {
    feeMarketing = fee;
    updateTotalFee();
  }

  function setFeeStakingPool(uint256 fee) external onlyOwner {
    feeStakingPool = fee;
    updateTotalFee();
  }

  function setFeeDev(uint256 fee) external onlyOwner {
    feeDev = fee;
    updateTotalFee();
  }

  function setFeeBurn(uint256 fee) external onlyOwner {
    feeBurn = fee;
    updateTotalFee();
  }

  function setKoda(IBEP20 newKodaToken) external onlyOwner {
    kodaToken = newKodaToken;
  }

  function setKapex(Kapex newKapexToken) external onlyOwner {
    kapexToken = newKapexToken;
  }

  function setRoyaltyAddress(address payable newRoyaltyAddress) external onlyOwner {
    royaltyAddress = newRoyaltyAddress;
  }

  function setMarketingAddress(address payable newMarketingAddress) external onlyOwner {
    marketingAddress = newMarketingAddress;
  }

  function setDevAddress(address payable newDevAddress) external onlyOwner {
    devAddress = newDevAddress;
  }

  function setBurnAddress(address payable newBurnAddress) external onlyOwner {
    burnAddress = newBurnAddress;
  }

  function setStakingPoolAddress(address payable newStakingPoolAddress) external onlyOwner {
    stakingPoolAddress = newStakingPoolAddress;
  }

  function setLpTokensLockAddress(address payable newLpTokensLockAddress) external onlyOwner {
    lpTokensLockAddress = newLpTokensLockAddress;
  }

  function setSummitSwapRouter(ISummitSwapRouter02 newSummitSwapRouter) external onlyOwner {
    summitSwapRouter = newSummitSwapRouter;
  }

  function setPancakeSwapRouter(ISummitSwapRouter02 newPancakeSwapRouter) external onlyOwner {
    pancakeSwapRouter = newPancakeSwapRouter;
  }

  receive() external payable {}

  function getSwapPercentToBNB() public view returns (uint256) {
    return
      feeMarketing.add(feeDev).add(feeKodaBurn).add(feeKodaLiquidity).add(feeKodaKapexLiquidity.div(2)).add(
        feeKapexLiquidity.div(2)
      );
  }

  function distributeBurnFee(uint256 kapexToSpend) private {
    if (feeBurn > 0) {
      uint256 burnKapexAmount = kapexToSpend.mul(feeBurn).div(feeTotal);
      kapexToken.burn(burnKapexAmount);
      // kapexToken.transfer(burnAddress, burnKapexAmount);
    }
  }

  function distributeRoyaltyFee(uint256 kapexToSpend) private {
    if (feeRoyalty > 0) {
      uint256 royaltyKapexAmount = kapexToSpend.mul(feeRoyalty).div(feeTotal);
      kapexToken.transfer(royaltyAddress, royaltyKapexAmount);
    }
  }

  function distributeStakingPoolFee(uint256 kapexToSpend) private {
    if (feeStakingPool > 0) {
      uint256 stakingPoolAmount = kapexToSpend.mul(feeStakingPool).div(feeTotal);
      kapexToken.transfer(stakingPoolAddress, stakingPoolAmount);
    }
  }

  function distributeDevFee(uint256 swapPercentToBNB, uint256 bnbToSpend) private {
    if (feeDev > 0) {
      uint256 devAmount = bnbToSpend.mul(feeDev).div(swapPercentToBNB);
      devAddress.transfer(devAmount);
    }
  }

  function distributeMarketingFee(uint256 swapPercentToBNB, uint256 bnbToSpend) private {
    if (feeMarketing > 0) {
      uint256 marketingAmount = bnbToSpend.mul(feeMarketing).div(swapPercentToBNB);
      marketingAddress.transfer(marketingAmount);
    }
  }

  function distributeKapexLiquidityFee(
    uint256 swapPercentToBNB,
    uint256 bnbToSpend,
    uint256 kapexToSpend
  ) private {
    if (feeKapexLiquidity > 0) {
      uint256 kapexLiquidityAmountInBNB = bnbToSpend.mul(feeKapexLiquidity.div(2)).div(swapPercentToBNB);
      uint256 kapexLiquidtyAmountInKapex = kapexToSpend.mul(feeKapexLiquidity.div(2)).div(feeTotal);

      kapexToken.approve(address(pancakeSwapRouter), kapexLiquidtyAmountInKapex);

      pancakeSwapRouter.addLiquidityETH{value: kapexLiquidityAmountInBNB.div(2)}(
        address(kapexToken),
        kapexLiquidtyAmountInKapex,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        lpTokensLockAddress,
        block.timestamp
      );
    }
  }

  function distributeKodaBurnFee(uint256 swapPercentToKoda, uint256 kodaToSpend) private {
    if (feeKodaBurn > 0) {
      uint256 burnKodaAmount = kodaToSpend.mul(feeKodaBurn).div(swapPercentToKoda);
      kodaToken.transfer(burnAddress, burnKodaAmount);
    }
  }

  function distributeKodaLiquidityFee(
    uint256 swapPercentToKoda,
    uint256 kodaToSpend,
    uint256 swapPercentToBNB,
    uint256 bnbToSpend
  ) private {
    if (feeKodaLiquidity > 0) {
      uint256 kodaLiquidityAmount = kodaToSpend.mul(feeKodaLiquidity.div(2)).div(swapPercentToKoda);
      uint256 kodaLiquidityAmountInBNB = bnbToSpend.mul(feeKodaLiquidity.div(2)).div(swapPercentToBNB);

      kodaToken.approve(address(pancakeSwapRouter), kodaLiquidityAmount);

      pancakeSwapRouter.addLiquidityETH{value: kodaLiquidityAmountInBNB}(
        address(kodaToken),
        kodaLiquidityAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        lpTokensLockAddress,
        block.timestamp
      );
    }
  }

  function distributeKodaKapexLiquidityFee(
    uint256 swapPercentToKoda,
    uint256 kodaToSpend,
    uint256 kapexToSpend
  ) private {
    if (feeKodaKapexLiquidity > 0) {
      uint256 kodaKapexLiquidityAmountInKapex = kapexToSpend.mul(feeKodaKapexLiquidity.div(2)).div(feeTotal);
      uint256 kodaKapexLiquidityAmountInKoda = kodaToSpend.mul(feeKodaKapexLiquidity.div(2)).div(swapPercentToKoda);

      kapexToken.approve(address(summitSwapRouter), kodaKapexLiquidityAmountInKapex);
      kodaToken.approve(address(summitSwapRouter), kodaKapexLiquidityAmountInKoda);

      summitSwapRouter.addLiquidity(
        address(kapexToken),
        address(kodaToken),
        kodaKapexLiquidityAmountInKapex,
        kodaKapexLiquidityAmountInKoda,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        lpTokensLockAddress,
        block.timestamp
      );
    }
  }

  function disburseSwapAndLiquifyTokens(uint256 kapexToSpend) public onlyOwner {
    require(kapexToSpend <= kapexToken.balanceOf(address(this)), "Amount is greater than contract kapex balance");

    distributeBurnFee(kapexToSpend);
    distributeRoyaltyFee(kapexToSpend);
    distributeStakingPoolFee(kapexToSpend);

    uint256 swapPercentToBNB = getSwapPercentToBNB();
    uint256 swapTokensToBNB = kapexToSpend.mul(swapPercentToBNB).div(feeTotal);

    // uint256 initialBNBBalance = address(this).balance;
    swapKapexForBNB(swapTokensToBNB);
    uint256 boughtBNBAmount = address(this).balance;

    distributeDevFee(swapPercentToBNB, boughtBNBAmount);
    distributeMarketingFee(swapPercentToBNB, boughtBNBAmount);
    distributeKapexLiquidityFee(swapPercentToBNB, boughtBNBAmount, kapexToSpend);

    uint256 swapPercentToKoda = feeKodaBurn.add(feeKodaLiquidity.div(2)).add(feeKodaKapexLiquidity.div(2));
    uint256 swapTokensToKoda = boughtBNBAmount.mul(swapPercentToKoda).div(swapPercentToBNB);

    // uint256 kodaInitialBalance = kodaToken.balanceOf(address(this));
    swapBNBForKoda(swapTokensToKoda);
    uint256 boughtKodaAmount = kodaToken.balanceOf(address(this));

    distributeKodaBurnFee(swapPercentToKoda, boughtKodaAmount);
    distributeKodaLiquidityFee(swapPercentToKoda, boughtKodaAmount, swapPercentToBNB, boughtBNBAmount);
    distributeKodaKapexLiquidityFee(swapPercentToKoda, boughtKodaAmount, kapexToSpend);
  }

  function swapKapexForBNB(uint256 tokenAmount) private {
    address[] memory pancakeSwapPath = new address[](2);
    pancakeSwapPath[0] = address(kapexToken);
    pancakeSwapPath[1] = pancakeSwapRouter.WETH();

    uint256 pancakeSwapBNBOut = pancakeSwapRouter.getAmountsOut(tokenAmount, pancakeSwapPath)[1];

    address[] memory summitSwapPath = new address[](3);
    summitSwapPath[0] = address(kapexToken);
    summitSwapPath[1] = address(kodaToken);
    summitSwapPath[2] = summitSwapRouter.WETH();

    uint256 summitSwapBNBOut = summitSwapRouter.getAmountsOut(tokenAmount, summitSwapPath)[2];

    if (pancakeSwapBNBOut > summitSwapBNBOut) {
      kapexToken.approve(address(pancakeSwapRouter), tokenAmount);

      pancakeSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        pancakeSwapPath,
        address(this),
        block.timestamp
      );
    } else {
      kapexToken.approve(address(summitSwapRouter), tokenAmount);

      summitSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        summitSwapPath,
        address(this),
        block.timestamp
      );
    }
  }

  function swapBNBForKoda(uint256 bnbAmount) private {
    address[] memory pancakeSwapPath = new address[](2);
    pancakeSwapPath[0] = pancakeSwapRouter.WETH();
    pancakeSwapPath[1] = address(kodaToken);
    uint256 pancakeSwapTokenOut = pancakeSwapRouter.getAmountsOut(bnbAmount, pancakeSwapPath)[1];

    address[] memory summitSwapPath = new address[](2);
    summitSwapPath[0] = summitSwapRouter.WETH();
    summitSwapPath[1] = address(kodaToken);
    uint256 summitSwapTokenOut = summitSwapRouter.getAmountsOut(bnbAmount, summitSwapPath)[1];

    if (pancakeSwapTokenOut > summitSwapTokenOut) {
      pancakeSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
        0,
        pancakeSwapPath,
        address(this),
        block.timestamp
      );
    } else {
      summitSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
        0,
        pancakeSwapPath,
        address(this),
        block.timestamp
      );
    }
  }

  /**
   * @dev recovers any tokens stuck in Contract's balance
   * NOTE! if ownership is renounced then it will not work
   * NOTE! Contract's Address and Owner's address MUST NOT
   * be excluded from reflection reward
   */
  function recoverTokens(
    address tokenAddress,
    address recipient,
    uint256 amountToRecover,
    uint256 recoverFeePercentage
  ) external onlyOwner {
    IBEP20 token = IBEP20(tokenAddress);
    uint256 balance = token.balanceOf(address(this));

    require(balance >= amountToRecover, "KODA Liquidity Provider: Not Enough Tokens in contract to recover");

    address feeRecipient = _msgSender();
    uint256 feeAmount = amountToRecover.mul(recoverFeePercentage).div(10000);
    amountToRecover = amountToRecover.sub(feeAmount);
    if (feeAmount > 0) token.transfer(feeRecipient, feeAmount);
    if (amountToRecover > 0) token.transfer(recipient, amountToRecover);
  }

  function recoverBNB(
    address payable recipient,
    uint256 amountToRecover,
    uint256 recoverFeePercentage
  ) external onlyOwner {
    require(address(this).balance >= amountToRecover, "KODA Liquidity Provider: Not Enough BNB in contract to recover");

    address payable feeRecipient = _msgSender();
    uint256 feeAmount = amountToRecover.mul(recoverFeePercentage).div(10000);
    amountToRecover = amountToRecover.sub(feeAmount);
    if (feeAmount > 0) feeRecipient.transfer(feeAmount);
    if (amountToRecover > 0) recipient.transfer(amountToRecover);
  }
}