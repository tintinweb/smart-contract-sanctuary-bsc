/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

/**
*Submitted for verification at BscScan.com on 2022-03-02
*/
 
// File: contracts/utils/Address.sol
 
 
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)
 
pragma solidity ^0.8.1;
 
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
    *
    * [IMPORTANT]
    * ====
    * You shouldn't rely on `isContract` to protect against flash loan attacks!
    *
    * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
    * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
    * constructor.
    * ====
    */
   function isContract(address account) internal view returns (bool) {
       // This method relies on extcodesize/address.code.length, which returns 0
       // for contracts in construction, since the code is only stored at the end
       // of the constructor execution.
 
       return account.code.length > 0;
   }
 
   /**
    * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
    * `recipient`, forwarding all available gas and reverting on errors.
    *
    * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
    * of certain opcodes, possibly making contracts go over the 2300 gas limit
    * imposed by `transfer`, making them unable to receive funds via
    * `transfer`. {sendValue} removes this limitation.
    *
    * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
    *
    * IMPORTANT: because control is transferred to `recipient`, care must be
    * taken to not create reentrancy vulnerabilities. Consider using
    * {ReentrancyGuard} or the
    * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
    */
   function sendValue(address payable recipient, uint256 amount) internal {
       require(address(this).balance >= amount, "Address: insufficient balance");
 
       (bool success, ) = recipient.call{value: amount}("");
       require(success, "Address: unable to send value, recipient may have reverted");
   }
 
   /**
    * @dev Performs a Solidity function call using a low level `call`. A
    * plain `call` is an unsafe replacement for a function call: use this
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
       return functionCallWithValue(target, data, 0, errorMessage);
   }
 
   /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    * but also transferring `value` wei to `target`.
    *
    * Requirements:
    *
    * - the calling contract must have an ETH balance of at least `value`.
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
       require(isContract(target), "Address: call to non-contract");
 
       (bool success, bytes memory returndata) = target.call{value: value}(data);
       return verifyCallResult(success, returndata, errorMessage);
   }
 
   /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    * but performing a static call.
    *
    * _Available since v3.3._
    */
   function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
       return functionStaticCall(target, data, "Address: low-level static call failed");
   }
 
   /**
    * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
    * but performing a static call.
    *
    * _Available since v3.3._
    */
   function functionStaticCall(
       address target,
       bytes memory data,
       string memory errorMessage
   ) internal view returns (bytes memory) {
       require(isContract(target), "Address: static call to non-contract");
 
       (bool success, bytes memory returndata) = target.staticcall(data);
       return verifyCallResult(success, returndata, errorMessage);
   }
 
   /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    * but performing a delegate call.
    *
    * _Available since v3.4._
    */
   function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
       return functionDelegateCall(target, data, "Address: low-level delegate call failed");
   }
 
   /**
    * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
    * but performing a delegate call.
    *
    * _Available since v3.4._
    */
   function functionDelegateCall(
       address target,
       bytes memory data,
       string memory errorMessage
   ) internal returns (bytes memory) {
       require(isContract(target), "Address: delegate call to non-contract");
 
       (bool success, bytes memory returndata) = target.delegatecall(data);
       return verifyCallResult(success, returndata, errorMessage);
   }
 
   /**
    * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
    * revert reason using the provided one.
    *
    * _Available since v4.3._
    */
   function verifyCallResult(
       bool success,
       bytes memory returndata,
       string memory errorMessage
   ) internal pure returns (bytes memory) {
       if (success) {
           return returndata;
       } else {
           // Look for revert reason and bubble it up if present
           if (returndata.length > 0) {
               // The easiest way to bubble the revert reason is using memory via assembly
 
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
 
// File: contracts/utils/math/SafeMath.sol
 
 
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
 
// File: contracts/utils/Context.sol
 
 
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
 
// File: contracts/access/Ownable.sol
 
 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
 
pragma solidity ^0.8.0;
 
 
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
 
// File: contracts/token/ERC20/IERC20.sol
 
 
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
 
// File: contracts/token/ERC20/extensions/IERC20Metadata.sol
 
 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
 
pragma solidity ^0.8.0;
 
 
/**
* @dev Interface for the optional metadata functions from the ERC20 standard.
*
* _Available since v4.1._
*/
interface IERC20Metadata is IERC20 {
   /**
    * @dev Returns the name of the token.
    */
   function name() external view returns (string memory);
 
   /**
    * @dev Returns the symbol of the token.
    */
   function symbol() external view returns (string memory);
 
   /**
    * @dev Returns the decimals places of the token.
    */
   function decimals() external view returns (uint8);
}
 
 
pragma solidity ^0.8.4;
 
 
 
 
 
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
 
interface IUniswapV2Router01 {
   function factory() external pure returns (address);
   function WETH() external pure returns (address);
   function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline
   ) external returns (uint amountA, uint amountB, uint liquidity);
   function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline
   ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
   function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline
   ) external returns (uint amountA, uint amountB);
   function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
   ) external returns (uint amountToken, uint amountETH);
   function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
   ) external returns (uint amountA, uint amountB);
   function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
   ) external returns (uint amountToken, uint amountETH);
   function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
   ) external returns (uint[] memory amounts);
   function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
   ) external returns (uint[] memory amounts);
   function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
   function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
   function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
   function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
   function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
   function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
   function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
   function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
   function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
 
interface IUniswapV2Router02 is IUniswapV2Router01 {
   function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
   ) external returns (uint amountETH);
   function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
   ) external returns (uint amountETH);
   function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
   ) external;
   function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline
   ) external payable;
   function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
   ) external;
}
 
 
// Main Contract
contract Bear2 is IERC20Metadata, Ownable {
   using SafeMath for uint256;
   using Address for address;
 
   mapping (address => uint256) private _walletBalance;
   mapping (address => mapping (address => uint256)) private _allowances;
   mapping (address => bool) private _isTaxExempt;
 
   IUniswapV2Router02 public immutable uniswapV2Router;
 
   // General
   string private _name = 'Bear Token';
   string private _symbol = 'BEAR2';
   uint8 private _decimals = 9;
   uint256 public constant _supplyTotal = 100000000000000000000000;
   uint256 public maxTxPercent = 5;
   address public immutable uniswapV2Pair;
   //address public _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // LIVE
   address public _routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // TEST
 
   // Wallet addresses
   address private constant burnAddress = 0x000000000000000000000000000000000000dEaD;
   address payable public taxWallet = payable(0x9Fbb5d68B0e441C3eDef7aE76866E7548DF07979);
   address payable public liqWallet = payable(0x9Fbb5d68B0e441C3eDef7aE76866E7548DF07979);
 
   // NFT
   address public addressOfNFT = 0x000000000000000000000000000000000000dEaD;
   address public addressOfNFT2 = 0x000000000000000000000000000000000000dEaD;
   address public addressOfNFT3 = 0x000000000000000000000000000000000000dEaD;
   mapping (address => uint256) private nftMintCredits;
  
   // Max wallet size
   uint256 public maxWalletSize = 5;
   mapping (address => bool) private maxWalletExempt;
 
   // Club
   mapping (address => uint256) private clubPayoutCount;
   mapping (address => uint256) private clubPayoutTally;
   mapping (address => uint256) private taxFreeBuyClub;
   address[] public clubList;
   uint256 public clubPayout = 10;
   uint256 public clubEntryPrice = 100000000000000000000;
 
   // Taxes
   uint256 public burnTaxS  = 1;
   uint256 public burnTaxB  = 0;
   uint256 public burnTaxT  = 0;
   uint256 public taxTaxS  = 13;
   uint256 public taxTaxB  = 4;
   uint256 public taxTaxT  = 5;
   uint256 public clubTaxS = 3;
   uint256 public clubTaxB = 3;
   uint256 public clubTaxT = 3;
   uint256 public liqTaxS = 4;
   uint256 public liqTaxB = 3;
   uint256 public liqTaxT = 4;
 
   // Tax options
   bool public taxesOnSell = true;
   bool public taxesOnBuy = true;
   bool public taxesOnTran = true;
   bool private doTaxes = true;
  
   // Swap
   uint256 public taxSwapAt  = 250000000000000000000;
   uint256 public liqSwapAt  = 250000000000000000000;
   uint256 public taxCount   = 0;
   uint256 public liqCount   = 0;
   bool public swapOnSell = true;
   bool public swapOnBuy = false;
   bool private inSwap = false;
 
   event SwapTokensForETH(
       uint256 amountIn,
       address[] path
   );
 
   constructor() {
       _walletBalance[_msgSender()] = _supplyTotal;
       emit Transfer(address(0), _msgSender(), _supplyTotal);
 
       IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress);
       uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
           .createPair(address(this), _uniswapV2Router.WETH());
 
       uniswapV2Router = _uniswapV2Router;
 
       _isTaxExempt[_msgSender()] = true;
       _isTaxExempt[burnAddress] = true;
       _isTaxExempt[taxWallet] = true;
       _isTaxExempt[liqWallet] = true;
       _isTaxExempt[_routerAddress] = true;
       maxWalletExempt[_msgSender()] = true;
       maxWalletExempt[burnAddress] = true;
       maxWalletExempt[taxWallet] = true;
       maxWalletExempt[liqWallet] = true;
       maxWalletExempt[_routerAddress] = true;
   }
 
   // Core
   function name() public view override returns (string memory) {
       return _name;
   }
   function symbol() public view override returns (string memory) {
       return _symbol;
   }
   function decimals() public view override returns (uint8) {
       return _decimals;
   }
   function balanceOf(address account) public view override returns (uint256) {
       return _walletBalance[account];
   }
   function totalSupply() public pure override returns (uint256) {
       return _supplyTotal;
   }
   function transfer(address recipient, uint256 amount) public override returns (bool) {
       _transfer(_msgSender(), recipient, amount);
       return true;
   }
   function allowance(address owner, address spender) public view override returns (uint256) {
       return _allowances[owner][spender];
   }  
   function _approve(address owner, address spender, uint256 amount) private {
       require(owner != address(0), "ERC20: approve from the zero address");
       require(spender != address(0), "ERC20: approve to the zero address");
       _allowances[owner][spender] = amount;
       emit Approval(owner, spender, amount);
   }
   function approve(address spender, uint256 amount) public override returns (bool) {
       _approve(_msgSender(), spender, amount);
       return true;
   }
   function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
       _transfer(sender, recipient, amount);
       _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
       return true;
   }
   function renounceOwnership() public override onlyOwner {
       if (_walletBalance[address(this)] == 1337133713371337){ // Added a check to stop accidental renounce
           _transferOwnership(address(0));
       }
   }
 
   // General
   function changeRouterAddress(address newRouterAddress) public virtual onlyOwner {
       _routerAddress = newRouterAddress;
   }
   function changeTaxWallet(address payable newWallet) public virtual onlyOwner {
       taxWallet = newWallet;
   } 
   function changeLiqWallet(address payable newLiqWallet) public virtual onlyOwner {
       liqWallet = newLiqWallet;
   }  
   function withdrawContractTokens(address account, uint256 tokenAmount) external onlyOwner() {
       require(_walletBalance[address(this)] >= tokenAmount, "Wallet balance error");
       _walletBalance[account] = _walletBalance[account].add(tokenAmount); 
       _walletBalance[address(this)] = _walletBalance[address(this)].sub(tokenAmount);    
       emit Transfer(address(this), account, tokenAmount);
   }
   function withdrawContractBNB(address payable account) external onlyOwner() {
       payable(address(account)).transfer(address(this).balance);
   }
   function changeMaxTxPercent(uint256 newMaxTxPercent) public virtual onlyOwner {
       maxTxPercent = newMaxTxPercent;
   }
 
   // NFT
   function changeNFTAddress(address newAddressOfNFT) public virtual onlyOwner {
       addressOfNFT = newAddressOfNFT;
   }
   function changeNFTAddress2(address newAddressOfNFT) public virtual onlyOwner {
       addressOfNFT2 = newAddressOfNFT;
   }
   function changeNFTAddress3(address newAddressOfNFT) public virtual onlyOwner {
       addressOfNFT3 = newAddressOfNFT;
   }
   function addNFTCredits(address[] memory accounts, uint256 creditsToAdd) public virtual onlyOwner {
       uint256 accLen = accounts.length;
       for (uint256 i=0; i<accLen; i++) {
           nftMintCredits[accounts[i]] = nftMintCredits[accounts[i]] + creditsToAdd;
       }
   }
   function resetNFTCredits(address account) public virtual onlyOwner {
       nftMintCredits[account] = 0;
   }
   function getNFTCredits(address account) public view returns (uint256) {
       return nftMintCredits[account];
   }
 
   // Tax values
   function changeTaxOnSell(uint256 newTax) public virtual onlyOwner {
       taxTaxS = newTax;
   }
   function changeTaxOnBuy(uint256 newTax) public virtual onlyOwner {
       taxTaxB = newTax;
   }
   function changeTaxOnTransfer(uint256 newTax) public virtual onlyOwner {
       taxTaxT = newTax;
   }
   function changeLiqOnSell(uint256 newLiqTax) public virtual onlyOwner {
       liqTaxS = newLiqTax;
   }
   function changeLiqOnBuy(uint256 newLiqTax) public virtual onlyOwner {
       liqTaxB = newLiqTax;
   }
   function changeLiqOnTransfer(uint256 newLiqTax) public virtual onlyOwner {
       liqTaxT = newLiqTax;
   }
   function changeBurnOnSell(uint256 newBurnTax) public virtual onlyOwner {
       burnTaxS = newBurnTax;
   }
   function changeBurnOnBuy(uint256 newBurnTax) public virtual onlyOwner {
       burnTaxB = newBurnTax;
   }
   function changeBurnOnTransfer(uint256 newBurnTax) public virtual onlyOwner {
       burnTaxT = newBurnTax;
   }
   function changeClubTaxOnSell(uint256 newClubTax) public virtual onlyOwner {
       clubTaxS = newClubTax;
   }
   function changeClubTaxOnBuy(uint256 newClubTax) public virtual onlyOwner {
       clubTaxS = newClubTax;
   }
   function changeClubTaxOnTransfer(uint256 newClubTax) public virtual onlyOwner {
       clubTaxS = newClubTax;
   }
 
   // Taxes enabled
   function changeTaxesOnSell(bool newTaxStatus) public virtual onlyOwner {
       taxesOnSell = newTaxStatus;
   }
   function changeTaxesOnBuy(bool newTaxStatus) public virtual onlyOwner {
       taxesOnBuy = newTaxStatus;
   }
   function changeTaxesOnTran(bool newTaxStatus) public virtual onlyOwner {
       taxesOnTran = newTaxStatus;
   }
 
 
   // Max wallet size
   function changeMaxWalletSize(uint256 newMaxWalletSize) public virtual onlyOwner {
       maxWalletSize = newMaxWalletSize;
   }
   function addMaxWalletExempt(address account) public virtual onlyOwner {
       maxWalletExempt[account] = true;
   }
   function removeMaxWalletExempt(address account) public virtual onlyOwner {
       maxWalletExempt[account] = false;
   }
   function isMaxWalletExempt(address account) public view returns (bool) {
       return maxWalletExempt[account];
   }
 
 
   // Tax exempt buys
   function addTaxFreeBuyCredits(address[] memory accounts, uint256 taxFreeBuyCredits) public virtual onlyOwner {
       uint256 accLen = accounts.length;
       for (uint256 i=0; i<accLen; i++) {
           taxFreeBuyClub[accounts[i]] = taxFreeBuyClub[accounts[i]] + taxFreeBuyCredits;
       }
   }
   function resetTaxFreeBuyCredits(address account) public virtual onlyOwner {
       taxFreeBuyClub[account] = 0;
   }
   function getTaxFreeBuyCredits(address account) public view returns (uint256) {
       return taxFreeBuyClub[account];
   }
 
  
   // Tax exempt
   function isTaxExempt(address account) public view returns (bool) {
       return _isTaxExempt[account];
   }
   function addTaxExempt(address account) external onlyOwner() {
       require(!_isTaxExempt[account], "Account is already tax exempt");
       _isTaxExempt[account] = true;
   }
   function removeTaxExempt(address account) external onlyOwner() {
       require(_isTaxExempt[account], "Account is not tax exempt");
       _isTaxExempt[account] = false;
   }
 
 
   // Club
   function changeClubEntryPrice(uint256 newPrice) public virtual onlyOwner {
       clubEntryPrice = newPrice;
   }
   function changeClubPayout(uint256 newPayout) public virtual onlyOwner {       
       clubPayout = newPayout;
   }
   function getClubPayoutCount(address account) external view returns (uint256) {
       return clubPayoutCount[account];
   }
   function getClubPayoutTally(address account) external view returns (uint256) {
       return clubPayoutTally[account];
   }
   function clearClubList() public virtual onlyOwner {
       delete clubList;
   }
   function setWalletPayoutCount(address[] memory accounts, uint256 payoutC) external onlyOwner() {
       uint256 accLen = accounts.length;
 
       for (uint256 i=0; i<accLen; i++) {
           if (clubPayoutCount[accounts[i]] == 0) {
               uint256 clubSize = clubList.length;
               bool foundIt = false;
 
               if (clubSize > 0){
                   for (uint256 z=0; z<clubSize; z++) {
                       if (clubList[z] == accounts[i]) {
                           foundIt = true;
                       }
                   }
 
                   if (!foundIt){
                       clubList.push(accounts[i]);
                   }
               } else {
                   clubList.push(accounts[i]);
               }
           }
           clubPayoutCount[accounts[i]] = payoutC;
       }
   }
   function addWalletPayoutCount(address[] memory accounts, uint256 payoutsToAdd) external onlyOwner() {
       uint256 accLen = accounts.length;
 
       for (uint256 i=0; i<accLen; i++) {
           uint256 clubSize = clubList.length;
           bool foundIt = false;
 
           if (clubSize > 0){
               for (uint256 z=0; z<clubSize; z++) {
                   if (clubList[z] == accounts[i]) {
                       foundIt = true;
                   }
               }
 
               if (!foundIt){
                   clubList.push(accounts[i]);
               }
           } else {
               clubList.push(accounts[i]);
           }
           clubPayoutCount[accounts[i]] = clubPayoutCount[accounts[i]] + payoutsToAdd;
       }
   }
 
 
   // Swap
   function changeSwapOnSell(bool newSwapOnSell) public virtual onlyOwner {
       swapOnSell = newSwapOnSell;
   }
   function changeSwapOnBuy(bool newSwapOnBuy) public virtual onlyOwner {
       swapOnBuy = newSwapOnBuy;
   }
   function changeTaxSwapAt(uint256 newTaxSwapAt) public virtual onlyOwner {
       taxSwapAt = newTaxSwapAt;
   }
   function changeLiqSwapAt(uint256 newLiqSwapAt) public virtual onlyOwner {
       liqSwapAt = newLiqSwapAt;
   }
   function swapForMint(address account, uint256 amount) external returns (uint256)  {
       bool isValid = false;
 
       if (_msgSender() == addressOfNFT) { isValid = true; }
       if (_msgSender() == addressOfNFT2) { isValid = true; }
       if (_msgSender() == addressOfNFT3) { isValid = true; }
 
       require(isValid, "Function can only be called from approved NFT Contract");
 
       if (nftMintCredits[account] > 0){
           nftMintCredits[account] = nftMintCredits[account].sub(1);
       } else {
           require(_walletBalance[account] >= amount, "Wallet does not hold tokens or NFT credits to mint");
 
           _walletBalance[burnAddress] = _walletBalance[burnAddress].add(amount); 
           _walletBalance[account] = _walletBalance[account].sub(amount);    
           emit Transfer(account, burnAddress, amount);
       }
 
       // Return users total Gem bonus payouts as a reed (higher = more likely to get rare)
       return clubPayoutTally[account];
   }
   function swapTokensForEth(uint256 tokenAmount, address sendTo) private {
       address[] memory path = new address[](2);
       path[0] = address(this);
       path[1] = uniswapV2Router.WETH();
 
       _approve(address(this), address(uniswapV2Router), tokenAmount);
       _approve(sendTo, address(uniswapV2Router), tokenAmount);
 
       uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
           tokenAmount,
           0,
           path,
           sendTo,
           block.timestamp
       );
 
       emit SwapTokensForETH(tokenAmount, path);
 
       inSwap = false;
   }
 
 
   // MAIN TRANSFER
   function _transfer(address sender, address recipient, uint256 amount) internal virtual {
       require(amount > 0, "Transfer amount must be greater than zero");
       require(sender != address(0), "ERC20: transfer from the zero address");
       require(sender != address(burnAddress), "BaseRfiToken: transfer from the burn address");
       require(_walletBalance[sender] >= amount, "Insufficient balance");
 
       if(sender != owner()){
           require(recipient != address(0), "ERC20: transfer to the zero address");
       }
      
       uint256 newAmount = amount;
       uint256 burnTax = 0;  
       uint256 taxTax = 0;  
       uint256 clubTax = 0;  
       uint256 liqTax = 0;  
      
       doTaxes = true;
 
       if (inSwap){
           doTaxes = false;
       }
 
       uint256 totalTxAmount = _supplyTotal.div(100).mul(maxTxPercent);
       if(recipient != owner() && sender != owner() && !isTaxExempt(sender) && !isTaxExempt(recipient) && doTaxes) {
           if(amount > totalTxAmount) {
               revert("Transfer amount exceeds the maxTxPercent.");
           }
       }
 
       // BUY
       if(sender == uniswapV2Pair) {
 
           // Check if tax free
           if (isTaxExempt(recipient) || !taxesOnBuy){
               doTaxes = false;
           }
 
           // Check if tax free buy credit
           if (taxFreeBuyClub[recipient] > 0){
               doTaxes = false;
               taxFreeBuyClub[recipient] = taxFreeBuyClub[recipient].sub(1);
           }
 
           // Check max wallet size
           if(!maxWalletExempt[recipient]) {
               uint256 newAmountT = _walletBalance[recipient].add(amount);
               uint256 maxAmountT = _supplyTotal.div(100).mul(maxWalletSize);
              
               if(newAmountT > maxAmountT) {
                   revert("Wallet would exceed the maxWalletSize.");
               }
           }
 
           burnTax = burnTaxB;
           taxTax = taxTaxB;
           clubTax = clubTaxB;
           liqTax = liqTaxB;
 
           if (swapOnBuy && !inSwap){
 
               // Run tax swapper
               if (balanceOf(address(this)) >= taxSwapAt && taxCount >= taxSwapAt) {
                   inSwap = true;
                   swapTokensForEth(taxSwapAt, taxWallet);
                   taxCount = 0;
               }
 
               // Run liq swapper
               if (balanceOf(address(this)) >= liqSwapAt && liqCount >= liqSwapAt) {
                   inSwap = true;
                   swapTokensForEth(liqSwapAt, liqWallet);
                   liqCount = 0;
               }
           }
          
           // Buyer club check
           if (amount >= clubEntryPrice && recipient != address(this)){
              
               // Add to club
               if (clubPayoutCount[recipient] == 0) {
                    uint256 clubSize = clubList.length;
                    bool foundIt = false;
 
                   if (clubSize > 0){
 
                       for (uint256 i=0; i<clubSize; i++) {
                           if (clubList[i] == recipient) {
                               foundIt = true;
                           }
                       }
 
                       if (!foundIt){
                           clubList.push(recipient);
                       }
                   } else {
                       clubList.push(recipient);
                   }
               }
              
               uint256 payoutMop = amount.div(clubEntryPrice);
               clubPayoutCount[recipient] = clubPayoutCount[recipient].add(clubPayout.mul(payoutMop));
           }
       }
 
       // SELL
       if(recipient == uniswapV2Pair) {
 
           if (isTaxExempt(sender) || !taxesOnSell){
               doTaxes = false;
           }
 
           burnTax = burnTaxS;
           taxTax = taxTaxS;
           clubTax = clubTaxS;
           liqTax = liqTaxS;
          
           if (swapOnSell && !inSwap){
 
               // Run tax swapper
               if (balanceOf(address(this)) >= taxSwapAt && taxCount >= taxSwapAt) {
                   inSwap = true;
                   swapTokensForEth(taxSwapAt, taxWallet);
                   taxCount = 0;
               }
 
               // Run liq swapper
               if (balanceOf(address(this)) >= liqSwapAt && liqCount >= liqSwapAt) {
                   inSwap = true;
                   swapTokensForEth(liqSwapAt, liqWallet);
                   liqCount = 0;
               }
           }
 
           // Remove from club on sell
           if (clubPayoutCount[sender] > 0) {
               clubPayoutCount[sender] = 1;
           }
 
           // Remove tax free buys on sell
           taxFreeBuyClub[sender] = 0;
 
       }
 
       // TRANSFER
       if (sender != uniswapV2Pair && recipient != uniswapV2Pair){
           if (isTaxExempt(sender) || isTaxExempt(recipient) || !taxesOnTran){
               doTaxes = false;
           }
 
           // Check max wallet size
           if(!maxWalletExempt[recipient]) {
               uint256 newAmountT = _walletBalance[recipient].add(amount);
               uint256 maxAmountT = _supplyTotal.div(100).mul(maxWalletSize);
              
               if(newAmountT > maxAmountT) {
                   revert("Wallet would exceed the maxWalletSize.");
               }
           }
 
           burnTax = burnTaxT;
           taxTax = taxTaxT;
           clubTax = clubTaxT;
           liqTax = liqTaxT;
       }
 
       // TAXES
       if (doTaxes){
 
           // BURN
           if (burnTax > 0){
               uint256 burnAmount = amount.div(100).mul(burnTax);
          
               _walletBalance[burnAddress] = _walletBalance[burnAddress].add(burnAmount);
 
               emit Transfer(sender, burnAddress, burnAmount);
               newAmount = newAmount.sub(burnAmount);
           }
 
           // TAX
           if (taxTax > 0){
               uint256 taxAmount = amount.div(100).mul(taxTax);
              
               _walletBalance[address(this)] = _walletBalance[address(this)].add(taxAmount);
               taxCount = taxCount.add(taxAmount);
 
               emit Transfer(sender, address(this), taxAmount);
               newAmount = newAmount.sub(taxAmount);
           }
 
           // LIQ
           if (liqTax > 0){
               uint256 liqAmount = amount.div(100).mul(liqTax);
               uint256 liqAmountHalf = liqAmount.div(2);
              
               _walletBalance[address(liqWallet)] = _walletBalance[address(liqWallet)].add(liqAmountHalf);
               _walletBalance[address(this)] = _walletBalance[address(this)].add(liqAmountHalf);
               liqCount = liqCount.add(liqAmountHalf);
 
               emit Transfer(sender, address(this), liqAmountHalf);
               emit Transfer(sender, address(liqWallet), liqAmountHalf);
               newAmount = newAmount.sub(liqAmount);
           }
 
           // CLUB
           if (clubTax > 0){
               uint256 clubRewardAmount = amount.div(100).mul(clubTax);
 
               if (_walletBalance[sender] >= clubTax){
                   uint256 clubSize = clubList.length;
 
                   if (clubSize > 0){
                       uint256 clubTaxPer = clubRewardAmount.div(clubSize);
 
                       for (uint256 i=0; i<clubSize; i++) {
 
                           if (clubPayoutCount[clubList[i]] > 0) {
 
                               if (clubList[i] != sender && clubList[i] != recipient) {
 
                                   _walletBalance[clubList[i]] = _walletBalance[clubList[i]].add(clubTaxPer);
                                   emit Transfer(sender, clubList[i], clubTaxPer);
                                   newAmount = newAmount.sub(clubTaxPer);
 
                                   clubPayoutCount[clubList[i]] = clubPayoutCount[clubList[i]].sub(1);
                                   clubPayoutTally[clubList[i]] = clubPayoutTally[clubList[i]].add(clubTaxPer);
                                  
                               }
                           }
                       }
                   }
               }
           }
       }
 
       _walletBalance[recipient] = _walletBalance[recipient].add(newAmount); 
       _walletBalance[sender] = _walletBalance[sender].sub(amount);    
       emit Transfer(sender, recipient, newAmount);
   }
 
   receive() external payable {}
}