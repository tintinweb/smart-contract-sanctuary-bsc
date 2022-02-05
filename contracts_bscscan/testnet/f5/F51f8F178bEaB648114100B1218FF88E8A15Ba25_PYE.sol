/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// File: PyeSwap_token/contracts/interfaces/IPYESwapRouter01.sol

pragma solidity >=0.6.2;

interface IPYESwapRouter01 {
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

// File: PyeSwap_token/contracts/interfaces/IPYESwapRouter.sol

pragma solidity >=0.6.2;


interface IPYESwapRouter is IPYESwapRouter01 {
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
    function pairFeeAddress(address pair) external view returns (address);
    function adminFee() external view returns (uint256);
    function feeAddressGet() external view returns (address);
}

// File: PyeSwap_token/contracts/interfaces/IPYESwapPair.sol

pragma solidity >=0.5.0;

interface IPYESwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function baseToken() external view returns (address);
    function getTotalFee() external view returns (uint);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function updateTotalFee(uint totalFee) external returns (bool);

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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast, address _baseToken);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, uint amount0Fee, uint amount1Fee, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setBaseToken(address _baseToken) external;
}

// File: PyeSwap_token/contracts/interfaces/IPYESwapFactory.sol

pragma solidity >=0.5.0;

interface IPYESwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function pairExist(address pair) external view returns (bool);

    function createPair(address tokenA, address tokenB, bool supportsTokenFee) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function routerInitialize(address) external;
    function routerAddress() external view returns (address);
}

// File: PyeSwap_token/contracts/interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: PyeSwap_token/contracts/interfaces/IERC20.sol

pragma solidity >=0.5.0;

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

// File: PyeSwap_token/contracts/interfaces/IPYE.sol

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IPYE {
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Address.sol



pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Context.sol



pragma solidity >=0.6.0 <0.8.0;

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol



pragma solidity >=0.6.0 <0.8.0;

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

// File: PyeSwap_token/contracts/PYE.sol

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;











contract PYE is IPYE, Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    // Fees
    struct Fees {
        uint256 taxFee;
        uint256 marketingFee;
        uint256 mechanismFee;
        uint256 buybackFee;
        address marketingAddress;
        address mechanismAddress;
    }

    // Transaction fee values
    struct FeeValues {
        uint256 transferAmount;
        uint256 marketing;
        uint256 mechanism;
        uint256 reflection;
        uint256 buyBack;
    }

    // Every reflection share
    struct Share {
        uint256 amount;
        mapping (address => uint256) totalExcluded;
        mapping (address => uint256) totalRealised;
    }

    // Token details
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _tTotal = 10 * 10**9 * 10**9;

    // Reflection details
    mapping (address => Share) public shares;

    // Users states
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isBountyExempt;

    // Reflection tokens
    mapping (uint256 => address) private pairs;
    mapping (uint256 => address) private tokens;
    uint256 private pairsLength;

    // Reflection details
    uint256 public totalShares;
    mapping (address => uint256) public totalBountys;
    mapping (address => uint256) public totalDistributed;
    mapping (address => uint256) public bountysPerShare;
    uint256 public bountysPerShareAccuracyFactor = 10 ** 36;

    uint256 private distributorGas = 500000;

    string constant _name = "MOON52";
    string constant _symbol = "MOON52";
    uint8 constant _decimals = 9;

    Fees public _defaultFees;
    Fees private _previousFees;
    Fees private _emptyFees;

    IPYESwapRouter public pyeSwapRouter;
    address public pyeSwapPair;
    address public WBNB;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = 5 * 10**8 * 10**9;

    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _tTotal / 2000; // 0.005%
    bool private inSwap;

    modifier swapping() { inSwap = true; _; inSwap = false; }
    modifier onlyExchange() {
        bool isPair = false;
        for(uint i = 0; i < pairsLength; i++) {
            if(pairs[i] == msg.sender) isPair = true;
        }
        require(
            msg.sender == address(pyeSwapRouter)
            || isPair
            , "PYE: NOT_ALLOWED"
        );
        _;
    }

    event BuybackMultiplierActive(uint256 duration);

    constructor(address _router, address _marketing, address _mechanism) public {
        _balances[_msgSender()] = _tTotal;

        pyeSwapRouter = IPYESwapRouter(_router);
        WBNB = pyeSwapRouter.WETH();
        pyeSwapPair = IPYESwapFactory(pyeSwapRouter.factory())
        .createPair(address(this), WBNB, true);

        tokens[pairsLength] = WBNB;
        pairs[pairsLength] = pyeSwapPair;
        pairsLength += 1;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(pyeSwapRouter)] = true;
        _isExcludedFromFee[pyeSwapPair] = true;

        isTxLimitExempt[_msgSender()] = true;
        isTxLimitExempt[pyeSwapPair] = true;
        isTxLimitExempt[address(pyeSwapRouter)] = true;

        isBountyExempt[pyeSwapPair] = true;
        isBountyExempt[address(this)] = true;
        isBountyExempt[_burnAddress] = true;

        setShare(owner(), _tTotal);

        _defaultFees = Fees(
            800,
            300,
            200,
            100,
            _marketing,
            _mechanism
        );

        IPYESwapPair(pyeSwapPair).updateTotalFee(1400);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return isBountyExempt[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function _updatePairsFee() internal {
        for (uint j = 0; j < pairsLength; j++) {
            IPYESwapPair(pairs[j]).updateTotalFee(getTotalFee());
        }
    }

    function setTaxFeePercent(uint256 _taxFee) external onlyOwner {
        _defaultFees.taxFee = _taxFee;
        _updatePairsFee();
    }

    function setMarketingPercent(uint256 _marketingFee) external onlyOwner {
        _defaultFees.marketingFee = _marketingFee;
        _updatePairsFee();
    }

    function setBuyBackPercent(uint256 _burnFee) external onlyOwner {
        _defaultFees.buybackFee = _burnFee;
        _updatePairsFee();
    }

    function setMechanismPercent(uint256 _mechanismFee) external onlyOwner {
        _defaultFees.mechanismFee = _mechanismFee;
        _updatePairsFee();
    }

    function setMarketingAddress(address _marketing) external onlyOwner {
        require(_marketing != address(0), "PYE: Address Zero is not allowed");
        _defaultFees.marketingAddress = _marketing;
    }

    function setMechanismAddress(address _mechanism) external onlyOwner {
        require(_mechanism != address(0), "PYE: Address Zero is not allowed");
        _defaultFees.mechanismAddress = _mechanism;
    }

    function updateRouterAndPair(address _router, address _pair) public onlyOwner {
        _isExcludedFromFee[address(pyeSwapRouter)] = false;
        _isExcludedFromFee[pyeSwapPair] = false;
        pyeSwapRouter = IPYESwapRouter(_router);
        pyeSwapPair = _pair;
        WBNB = pyeSwapRouter.WETH();

        _isExcludedFromFee[address(pyeSwapRouter)] = true;
        _isExcludedFromFee[pyeSwapPair] = true;

        isBountyExempt[pyeSwapPair] = true;

        isTxLimitExempt[pyeSwapPair] = true;
        isTxLimitExempt[address(pyeSwapRouter)] = true;

        pairs[0] = pyeSwapPair;
        tokens[0] = WBNB;

        IPYESwapPair(pyeSwapPair).updateTotalFee(getTotalFee());
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**4
        );
    }

    //to receive BNB from pyeRouter when swapping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (FeeValues memory) {
        FeeValues memory values = FeeValues(
            0,
            calculateFee(tAmount, _defaultFees.marketingFee),
            calculateFee(tAmount, _defaultFees.mechanismFee),
            calculateFee(tAmount, _defaultFees.taxFee),
            calculateFee(tAmount, _defaultFees.buybackFee)
        );

        values.transferAmount = tAmount.sub(values.marketing).sub(values.mechanism).sub(values.reflection).sub(values.buyBack);
        return values;
    }

    function calculateFee(uint256 _amount, uint256 _fee) private pure returns (uint256) {
        if(_fee == 0) return 0;
        return _amount.mul(_fee).div(
            10**4
        );
    }

    function removeAllFee() private {
        _previousFees = _defaultFees;
        _defaultFees = _emptyFees;
    }

    function restoreAllFee() private {
        _defaultFees = _previousFees;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        checkTxLimit(from, amount);

        if(shouldBuyAndLiquify()){ buyAndLiquify(); }
        if(shouldAutoBuyback()){ triggerAutoBuyback(); }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        //transfer amount, it will take tax
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();

        FeeValues memory _values = _getValues(amount);
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(_values.transferAmount);
        _takeFees(_values);

        if(!isBountyExempt[sender]){ setShare(sender, _balances[sender]); }
        if(!isBountyExempt[recipient]){ setShare(recipient, _balances[recipient]); }

        emit Transfer(sender, recipient, _values.transferAmount);

        if(!takeFee)
            restoreAllFee();
    }

    function _takeFees(FeeValues memory values) private {
        _takeFee(values.marketing, _defaultFees.marketingAddress);
        _takeFee(values.mechanism, _defaultFees.mechanismAddress);
        _takeFee(values.reflection, address(this));
        _takeFee(values.buyBack, _burnAddress);
    }

    function _takeFee(uint256 tAmount, address recipient) private {
        if(recipient == address(0)) return;
        if(tAmount == 0) return;

        _balances[address(this)] = _balances[address(this)].add(tAmount);
    }

    function updateBurnAddress(address _newBurnAddress) external onlyOwner {
        _burnAddress = _newBurnAddress;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldBuyAndLiquify() internal view returns (bool) {
        return msg.sender != pyeSwapPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pyeSwapPair
        && !inSwap
        && autoBuybackEnabled
        && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number // After N blocks from last buyback
        && address(this).balance >= autoBuybackAmount;
    }

    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, _burnAddress);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        pyeSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function triggerBullRun(uint256 amount, bool triggerBuybackMultiplier) external onlyOwner {
        buyTokens(amount, _burnAddress);
        if(triggerBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(_burnAddress)).sub(balanceOf(address(0)));
    }

    function setIsBountyExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pyeSwapPair);
        isBountyExempt[holder] = exempt;
        if(exempt){
            setShare(holder, 0);
        }else{
            setShare(holder, _balances[holder]);
        }
    }

    function getTotalFee() internal view returns (uint256) {
        return _defaultFees.mechanismFee
            .add(_defaultFees.marketingFee)
            .add(_defaultFees.taxFee)
            .add(_defaultFees.buybackFee);
    }

    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external onlyOwner {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external onlyOwner {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function clearBuybackMultiplier() external onlyOwner {
        buybackMultiplierTriggeredAt = 0;
    }

    function buyAndLiquify() internal swapping {
        uint256 amountToSwap = _balances[address(this)];

        _approve(address(this), address(pyeSwapRouter), amountToSwap);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        pyeSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalFee = getTotalFee();

        uint256 amountBNBReflection = amountBNB.mul(_defaultFees.taxFee).div(totalFee);
        uint256 amountBNBMechanism = amountBNB.mul(_defaultFees.mechanismFee).div(totalFee);
        uint256 amountBNBMarketing = amountBNB.mul(_defaultFees.marketingFee).div(totalFee);

        depositETH(amountBNBReflection);
        payable(_defaultFees.marketingAddress).transfer(amountBNBMarketing);
        payable(_defaultFees.mechanismAddress).transfer(amountBNBMechanism);
    }

    function depositETH(uint256 _value) internal {
        uint256 balanceBefore = IWETH(WBNB).balanceOf(address(this));

        IWETH(WBNB).deposit{value: _value}();

        uint256 amount = IWETH(WBNB).balanceOf(address(this)).sub(balanceBefore);

        totalBountys[WBNB] = totalBountys[WBNB].add(amount);
        bountysPerShare[WBNB] = bountysPerShare[WBNB].add(bountysPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function depositLPFee(uint256 amount, address token) public onlyExchange {
        uint256 tokenIndex = _getTokenIndex(token);
        if(tokenIndex < pairsLength) {
            uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
            if(allowance >= amount) {
                IERC20(token).transferFrom(msg.sender, address(this), amount);

                uint256 totalFee = getTotalFee();
                uint256 mechanismFeeAmount = amount.mul(_defaultFees.mechanismFee).div(totalFee);
                uint256 marketingFeeAmount = amount.mul(_defaultFees.marketingFee).div(totalFee);
                uint256 reflectionAmount = amount.mul(_defaultFees.taxFee).div(totalFee);

                IERC20(token).transfer(_defaultFees.marketingAddress, marketingFeeAmount);
                IERC20(token).transfer( _defaultFees.mechanismAddress, mechanismFeeAmount);

                totalBountys[token] = totalBountys[token].add(reflectionAmount);
                bountysPerShare[token] = bountysPerShare[token].add(bountysPerShareAccuracyFactor.mul(reflectionAmount).div(totalShares));
            }
        }
    }

    function _getTokenIndex(address _token) internal view returns (uint256) {
        uint256 index = pairsLength + 1;
        for(uint256 i = 0; i < pairsLength; i++) {
            if(tokens[i] == _token) index = i;
        }

        return index;
    }

    function addPair(address _pair, address _token) public {
        address factory = pyeSwapRouter.factory();
        require(
            msg.sender == factory
            || msg.sender == address(pyeSwapRouter)
            || msg.sender == address(this)
        , "PYE: NOT_ALLOWED"
        );

        if(!_checkPairRegistered(_pair)) {
            _isExcludedFromFee[_pair] = true;
            isTxLimitExempt[_pair] = true;
            isBountyExempt[_pair] = true;

            pairs[pairsLength] = _pair;
            tokens[pairsLength] = _token;

            pairsLength += 1;

            IPYESwapPair(_pair).updateTotalFee(getTotalFee());
        }
    }

    function _checkPairRegistered(address _pair) internal view returns (bool) {
        bool isPair = false;
        for(uint i = 0; i < pairsLength; i++) {
            if(pairs[i] == _pair) isPair = true;
        }

        return isPair;
    }

    function distributeBounty(address keeper) internal {
        if(shares[keeper].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(keeper);
        if(amount > 0){

            uint256 gasUsed = 0;
            uint256 gasLeft = gasleft();

            for (uint j = 0; j < pairsLength; j++) {
                if(gasUsed < distributorGas) {
                    address token = tokens[j];
                    uint256 tokenAmount = getCumulativeBounty(shares[keeper].amount, token);
                    if(tokenAmount > 0) {
                        IERC20(token).transfer(keeper, tokenAmount);
                        totalDistributed[token] = totalDistributed[token].add(tokenAmount);
                        shares[keeper].totalRealised[token] = shares[keeper].totalRealised[token].add(tokenAmount);
                        shares[keeper].totalExcluded[token] = getCumulativeBounty(shares[keeper].amount, token);
                    }

                    gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                    gasLeft = gasleft();
                } else {
                    break;
                }
            }
        }
    }

    function claimBounty() external {
        distributeBounty(msg.sender);
    }

    function getUnpaidEarnings(address keeper) public view returns (uint256) {
        uint256 amounts;
        for (uint j = 0; j < pairsLength; j++) {
            address token = tokens[j];
            amounts = amounts.add(shares[keeper].amount);
        }
        if(amounts == 0){ return 0; }


        bool isZero = true;
        for (uint j = 0; j < pairsLength; j++) {
            address token = tokens[j];
            uint256 keeperTotalBountys = getCumulativeBounty(shares[keeper].amount, token);
            uint256 keeperTotalExcluded = shares[keeper].totalExcluded[token];

            if(keeperTotalBountys > keeperTotalExcluded)
                isZero = false;
        }

        if(isZero) { return 0; }

        return 1;
    }

    function getCumulativeBounty(uint256 share, address token) internal view returns (uint256) {
        if(pairsLength == 0) {
            return 0;
        }

        return share.mul(bountysPerShare[token]).div(bountysPerShareAccuracyFactor);
    }

    function setShare(address keeper, uint256 amount) internal {
        uint256 amounts;
        for (uint j = 0; j < pairsLength; j++) {
            address token = tokens[j];
            amounts = amounts.add(shares[keeper].amount);
        }
        if(amounts > 0){
            distributeBounty(keeper);
        }

        totalShares = totalShares.sub(shares[keeper].amount).add(amount);
        shares[keeper].amount = amount;

        for (uint j = 0; j < pairsLength; j++) {
            address token = tokens[j];
            shares[keeper].totalExcluded[token] = getCumulativeBounty(shares[keeper].amount, token);
        }
    }

    function setDistributorSettings(uint256 _gas) external onlyOwner {
        require(_gas < 750000, "PYE: TOO_HIGH_GAS_AMOUNT");
        distributorGas = _gas;
    }
}