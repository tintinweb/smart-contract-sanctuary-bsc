/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: Unlicensed
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IInviter {
    function getInviter(address account) external returns(address);
}


interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint256);
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

contract LPTokenWrapper {
    using SafeMath for uint256;

    IERC20 public usdtToken;
    address public managerAddress;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        usdtToken.transferFrom(msg.sender, managerAddress, amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        //usdtToken.transfer(msg.sender, amount);
    }
}

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract MetaStakePool is
    Ownable
{
    using SafeMath for uint256;

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;

    IERC20 public targetToken;
    IERC20 public usdtToken;
    address public inviterAddress;

    address public fundAddress;

    uint256 public totalSupply;
    mapping(address => uint256) private stakeBalances;

    enum TYPELEVEL{LEVEL1, LEVEL2, LEVEL3}
    mapping(TYPELEVEL => uint8) levelRewardRatio;
    mapping(TYPELEVEL => uint256[]) levelRequiredValue;

    uint256 public layer = 100;

    uint256 public rewardRate = 1157407407407407;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;
    mapping(address => uint256) public userRewardPerTokenPaid;

    uint256 public minRequiredAmount = 60 * 10 ** 18;

    uint256 public buyBackFee = 0; //60%
    uint256 public dividentFee = 20; //20%
    uint256 public fundFee = 20; //10%

    bool public startBuyBack = false;
    bool public startOpenStake = false;

    uint256 public giveRate = 3; //3%
    uint256 public giveRequireAmount = 100 * 10 ** 18;

    mapping(address => uint256) public rewards;
    // mapping(address => uint256) public lastUpdateTime;
    mapping(address => bool) public blackList;
    mapping(address => bool) public accountStakeMapping;
    mapping(address => uint256) public accountStakeTimes;

    struct InviterMap {
        uint256 directCount;
        uint256 totalTeamAchievement;
    }
    mapping(address => InviterMap) internal accountInvterAchievement;
    uint256 internal totalLevelRatio = 15; //18%
    uint256 internal Level1RequireAmount = 5000 * 10 ** 18;
    uint256 internal Level1Ratio = 8; // 9%
    uint256 internal Level2RequireAmount = 15000 * 10 ** 18;
    uint256 internal Level2Ratio = 11; //10%
    uint256 internal Level3RequireAmount = 50000 * 10 ** 18;
    uint256 internal Level3Ratio = 13; //8%
    uint256 internal Level4RequireAmount = 150000 * 10 ** 18;
    uint256 internal Level4Ratio = 15; //8%

    uint256 public directCountRequired = 5;
    uint256 public directCountGreatRequired = 10;

    uint256 public directRewardRatio = 5; //5%

    mapping (address => uint256) public accountPaidValue;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 usdtReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(
        address _tokenAddress,
        address _fundAddress,
        address _usdtToken,
        address _routerAddress,
        address _inviterAddress
    )  {
        targetToken = IERC20(_tokenAddress);
        usdtToken = IERC20(_usdtToken);

        fundAddress = _fundAddress;
        inviterAddress = _inviterAddress;

        levelRewardRatio[TYPELEVEL.LEVEL1] = 26; //2.6
        levelRewardRatio[TYPELEVEL.LEVEL2] = 30; //3.0
        levelRewardRatio[TYPELEVEL.LEVEL3] = 35; //3.5

        levelRequiredValue[TYPELEVEL.LEVEL1] = [60 * 10 ** 18, 500 * 10 ** 18];
        levelRequiredValue[TYPELEVEL.LEVEL2] = [500 * 10 ** 18, 2000 * 10 ** 18];
        levelRequiredValue[TYPELEVEL.LEVEL3] = [2000 * 10 ** 18, 999999999 * 10 ** 18];

        pancakeRouter = IPancakeRouter02(_routerAddress);
    }

    function setLevelRewardRatio(TYPELEVEL _levelType, uint8 _ratio) external onlyOwner {
        levelRewardRatio[_levelType] = _ratio;
    }

    function setLevelRequiredValue(TYPELEVEL _levelType, uint256[] memory _arr) external onlyOwner {
        levelRequiredValue[_levelType] = _arr;
    }

    function setDirectCountRequired(uint256 _directCountRequired, uint256 _directCountGreatRequired) external onlyOwner {
        directCountRequired = _directCountRequired;
        directCountGreatRequired = _directCountGreatRequired;
    }

    function setMinRequiredAmount(uint256 _minRequiredAmount) external onlyOwner {
        minRequiredAmount = _minRequiredAmount;
    }

    function setLevelRequireAmount(
        uint256 _level1RequiredAount,
        uint256 _level2RequiredAount,
        uint256 _level3RequiredAount,
        uint256 _level4RequiredAount
    ) external onlyOwner {
        Level1RequireAmount = _level1RequiredAount;
        Level2RequireAmount = _level2RequiredAount;
        Level3RequireAmount = _level3RequiredAount;
        Level4RequireAmount = _level4RequiredAount;
    }

    function setLevelRatio(
        uint256 _level1Ratio,
        uint256 _level2Ratio,
        uint256 _level3Ratio,
        uint256 _level4Ratio,
        uint256 _totalRatio
    ) external onlyOwner {
        Level1Ratio = _level1Ratio;
        Level2Ratio = _level2Ratio;
        Level3Ratio = _level3Ratio;
        Level4Ratio = _level4Ratio;
        totalLevelRatio = _totalRatio;
    }

    function setConfigFee(
        uint256 _buyBackFee, 
        uint256 _dividentFee, 
        uint256 _fundFee
    ) external onlyOwner {
        buyBackFee = _buyBackFee;
        dividentFee = _dividentFee;
        fundFee = _fundFee;
    }

    function setStartBuyBack(bool _isStart) external onlyOwner {
        startBuyBack = _isStart;
    }

    function setStartOpenStake(bool _isOpend) external onlyOwner {
        startOpenStake = _isOpend;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            uint256 earnAmount = earned(account);
            rewards[account] = earnAmount;
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function setAddressConfig(
        address _tokenAddress,
        address _inviterAddress,
        address _pancakePair,
        address _fundAddress
    ) external onlyOwner {
        targetToken = IERC20(_tokenAddress);
        inviterAddress = _inviterAddress;
        pancakePair = _pancakePair;
        fundAddress = _fundAddress;
    }

    function setRewardRate(uint256 rate) external onlyOwner {
        rewardRate = rate;
    }

    function setBlackList(address account, bool _is) external onlyOwner {
        blackList[account] = _is;
    }

    function setGiveRate(uint256 _giveRate) external onlyOwner {
        giveRate = _giveRate;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(block.timestamp.sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(totalSupply));
    }

    function earned(address account) public view returns (uint256) {
        if(blackList[account]) return 0;
        uint256 earnAmount = stakeBalances[account]
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
        if(earnAmount <= 0) return 0;        
        uint256 value = calculateValue(earnAmount);
        uint256 totalReward = stakeBalances[account].mul(getMultiple(account)).div(10);
        if(accountPaidValue[account].add(value) >= totalReward) {
            earnAmount = (totalReward.sub(accountPaidValue[account])).mul(10 ** 18).div(getCurPrice(address(targetToken)));
        }
        return earnAmount;
    }

    function stake(uint256 amount)
        public
        updateReward(msg.sender)
    {
        require(amount >= minRequiredAmount, 'STAKEPOOL: Cannot stake less than 100');
        require(!blackList[msg.sender], "Black list account");
        if(!startOpenStake) {
             require(!accountStakeMapping[msg.sender], "Had Staked");
        }
        stakeBalances[msg.sender] = stakeBalances[msg.sender].add(amount);
        totalSupply = totalSupply.add(amount);
        if(!accountStakeMapping[msg.sender]) {
            accountStakeMapping[msg.sender] = true;
        }

        if(giveRate > 0) {
            uint256 giveAmount = amount.mul(giveRate).div(100);
            //direct grant 
            targetToken.transfer(msg.sender, giveAmount);
        }

        uint256 buyBackAmount;
        uint256 inviterLevelReward;
        if (buyBackFee > 0) {
            buyBackAmount = amount.mul(buyBackFee).div(100);
            usdtToken.transferFrom(msg.sender, address(this), buyBackAmount);
            if(startBuyBack) {
                swapTokensToToken(buyBackAmount, address(this)); 
            } else {
                swapTokensToToken(buyBackAmount, 0x000000000000000000000000000000000000dEaD); 
            }
           // swapAndLiquify(buyBackAmount);
        }
        //inviter
        address inviter = IInviter(inviterAddress).getInviter(msg.sender);
        if(inviter != address(0)) {
            invited(inviter, amount);
            inviterLevelReward = differentialDivedent(inviter, amount);
        }
        uint256 fundAmount = amount.sub(buyBackAmount.add(inviterLevelReward));
        usdtToken.transferFrom(msg.sender, fundAddress, fundAmount);
        emit Staked(msg.sender, amount);
    }

    function differentialDivedent(address inviter, uint256 amount) private returns(uint256) {
        uint256 totalRatio;
        uint256 totalRewardAmount;
        uint256 dloop = 0;
        while(inviter != address(0)) {
            uint256 rewardUsdtAmount = 0;
            uint256 directRewardAmount = 0;
            InviterMap storage accInviterMap = accountInvterAchievement[inviter];
            if(dloop == 0 && stakeBalances[inviter] > 0) {
                //direct recommend reward
                directRewardAmount = amount.mul(directRewardRatio).div(100);
                //totalRewardAmount = totalRewardAmount.add(directRewardAmount);
                //usdtToken.transferFrom(msg.sender, inviter, directRewardAmount);
            }
            if(accInviterMap.totalTeamAchievement >= Level4RequireAmount && Level4Ratio > totalRatio && stakeBalances[inviter] > 0 && accInviterMap.directCount >= directCountGreatRequired) {
                rewardUsdtAmount = amount.mul(Level4Ratio.sub(totalRatio)).div(100);
                totalRatio = totalRatio.add(Level4Ratio.sub(totalRatio));
            } else if(accInviterMap.totalTeamAchievement >= Level3RequireAmount && Level3Ratio > totalRatio  && stakeBalances[inviter] > 0 && accInviterMap.directCount >= directCountGreatRequired) {
                rewardUsdtAmount = amount.mul(Level3Ratio.sub(totalRatio)).div(100);
                totalRatio = totalRatio.add(Level3Ratio.sub(totalRatio));
            } else if(accInviterMap.totalTeamAchievement >= Level2RequireAmount && Level2Ratio > totalRatio && stakeBalances[inviter] > 0 && accInviterMap.directCount >= directCountGreatRequired) {
                rewardUsdtAmount = amount.mul(Level2Ratio.sub(totalRatio)).div(100);
                totalRatio = totalRatio.add(Level2Ratio.sub(totalRatio));
            } else if(accInviterMap.totalTeamAchievement >= Level1RequireAmount && Level1Ratio > totalRatio && stakeBalances[inviter] > 0 && accInviterMap.directCount >= directCountRequired) {
                rewardUsdtAmount = amount.mul(Level1Ratio.sub(totalRatio)).div(100);
                totalRatio = totalRatio.add(Level1Ratio.sub(totalRatio));
            }
            uint256 subTotalReward = rewardUsdtAmount.add(directRewardAmount);
            if(subTotalReward > 0) {
                usdtToken.transferFrom(msg.sender, inviter, subTotalReward);
                totalRewardAmount = totalRewardAmount.add(subTotalReward);
            }
            dloop++;
            if(totalRatio >= totalLevelRatio || dloop >= layer) {
                break;
            }
            inviter = IInviter(inviterAddress).getInviter(inviter);
        }
        return totalRewardAmount;
    }

    function invited(address inviter, uint256 amount) private {
        InviterMap storage accInviterMap = accountInvterAchievement[inviter];
        accInviterMap.directCount = accInviterMap.directCount.add(1);
        if (stakeBalances[inviter] > 0) {
            accInviterMap.totalTeamAchievement = accInviterMap.totalTeamAchievement.add(amount);
        }   
        //team achievement
        achievement(inviter, amount);
    }

    function achievement(address account, uint256 amount) private {
        address superior = IInviter(inviterAddress).getInviter(account);
        uint256 curLoop = 0;
        while(superior != address(0)) {
            if (stakeBalances[superior] > 0) {
                InviterMap storage accInviterMap = accountInvterAchievement[superior];
                accInviterMap.totalTeamAchievement = accInviterMap.totalTeamAchievement.add(amount);
            }
            superior = IInviter(inviterAddress).getInviter(superior);
            curLoop++;
            if(curLoop >= layer) {
                break;
            }
        }
    }

    function swapTokensToToken(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(usdtToken);
        path[1] = address(targetToken);

        usdtToken.approve(address(pancakeRouter), tokenAmount);
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            //calculate value
            uint256 value = calculateValue(reward);
            require(value > 0, 'zero error price');
            uint256 totalReward = stakeBalances[msg.sender].mul(getMultiple(msg.sender)).div(10);
            if(accountPaidValue[msg.sender].add(value) >= totalReward) {
               reward = (totalReward.sub(accountPaidValue[msg.sender])).mul(10 ** 18).div(getCurPrice(address(targetToken)));
               totalSupply = totalSupply.sub(stakeBalances[msg.sender]);
               stakeBalances[msg.sender] = 0;
               accountPaidValue[msg.sender] = 0;
               accountStakeTimes[msg.sender] = accountStakeTimes[msg.sender].add(1);
            } else {
                accountPaidValue[msg.sender] = accountPaidValue[msg.sender].add(value);
            } 
            rewards[msg.sender] = 0;
            targetToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function getMultiple(address account) public view returns(uint256 multiple) {
        if(stakeBalances[account] > levelRequiredValue[TYPELEVEL.LEVEL3][0]) {
            multiple = levelRewardRatio[TYPELEVEL.LEVEL3];
        } else if(stakeBalances[account] >= levelRequiredValue[TYPELEVEL.LEVEL2][0] && stakeBalances[account] < levelRequiredValue[TYPELEVEL.LEVEL2][1]) {
            multiple = levelRewardRatio[TYPELEVEL.LEVEL2];
        } else if(stakeBalances[account] >= levelRequiredValue[TYPELEVEL.LEVEL1][0] && stakeBalances[account] < levelRequiredValue[TYPELEVEL.LEVEL1][1]) {
            multiple = levelRewardRatio[TYPELEVEL.LEVEL1];
        }
    }

    function getAccountInvterAchievement(address account) public view returns(InviterMap memory) {
        return accountInvterAchievement[account];
    }

    function calculateValue(uint256 tokenAmount) public view returns(uint256) {
        return tokenAmount.mul(getCurPrice(address(targetToken))).div(10 ** 18);
    }

    function getCurPrice(address _tokenAddress) public view returns(uint _price){
        address t0 = IPancakePair(pancakePair).token0();
        (uint r0,uint r1,) = IPancakePair(pancakePair).getReserves();
        if( r0 > 0 && r1 > 0 ){
             if( t0 == address(_tokenAddress)){
                _price = r1 * 10 ** 18 / r0;
            }else{
                _price = r0 * 10 ** 18 / r1;
            }   
        }
    }

    function getAccountMetaStake(address account) public view returns(bool) {
        return accountStakeMapping[account];
    }

    function balanceOf(address account) public view returns(uint256) {
        return stakeBalances[account];
    }
}