/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

/*
$$\      $$\  $$$$$$\   $$$$$$\   $$$$$$\  $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\  $$\      $$\  $$$$$$\  $$$$$$$\  
$$$\    $$$ |$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$ | $\  $$ |$$  __$$\ $$  __$$\ 
$$$$\  $$$$ |$$ /  $$ |$$ /  \__|$$ /  $$ |$$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ |$$$\ $$ |$$ /  $$ |$$ |  $$ |
$$\$$\$$ $$ |$$$$$$$$ |$$ |      $$$$$$$$ |$$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  $$ $$ $$\$$ |$$$$$$$$ |$$$$$$$  |
$$ \$$$  $$ |$$  __$$ |$$ |      $$  __$$ |$$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\ $$$$  _$$$$ |$$  __$$ |$$  ____/ 
$$ |\$  /$$ |$$ |  $$ |$$ |  $$\ $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$$  / \$$$ |$$ |  $$ |$$ |      
$$ | \_/ $$ |$$ |  $$ |\$$$$$$  |$$ |  $$ |$$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |$$  /   \$$ |$$ |  $$ |$$ |      
\__|     \__|\__|  \__| \______/ \__|  \__|\__|  \__| \______/ \__|  \__| \______/ \__/     \__|\__|  \__|\__|      
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.6.12;

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
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

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

interface ICakeMasterChef {
    function deposit(uint256 _poolId, uint256 _amount) external;

    function withdraw(uint256 _poolId, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256 amount, uint256 rewardDebt);

    function poolInfo(uint256 _pid) external view returns (address lpToken, uint256 allocPoint, uint256 lastRewardBlock, uint256 accCakePerShare);

    function emergencyWithdraw(uint256 _pid) external;

    function cakePerBlock() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);
}

interface IUniswapV2Router {
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

/**
    - Deploy BBChef
    - Set swapRoute2 (optional) (require if reward token LP on different DEX)
    - Set router2 (optional) (require if reward token LP on different DEX)
 */
contract BBChefMulti4PCS is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 rewardPerBlock;  // MCRN tokens created per block.
        uint256 lastRewardBlock;  // Last block number that MCRNs distribution occurs.
        uint256 accMacaronPerShare; // Accumulated MCRNs per share, times 1e12. See below.
        uint256 hostPid;            // hostchef pool id
        uint256 lpSupply;
        uint256 lastUpdateBlock;
    }
    
    // Treasury
    address treasury;

    // REWARD TOKEN!
    IBEP20 public rewardToken;

    IBEP20 public hostRewardToken; // HOST MasterChef Reward Token
    ICakeMasterChef public hostChef;        // CAKE MasterChef for Strategy
    mapping(uint256 => bool) public isHostPidSupported;
    
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // The block number when MCRN mining starts.
    uint256 public startBlock;

    uint256 public hostRewardDistPercent = 1; // 1%
    uint256 public routerLoss = 5; // 5%
    uint256 public slippageTolerance = 10; // 1:0.1% 10:1% 20:2%

    // About BB
    IUniswapV2Router public router;
    address[] public swapPath;
    IUniswapV2Router public router2;
    address[] public swapPath2;

    event Deposit(address indexed user, uint256 pid, uint256 amount);
    event Withdraw(address indexed user, uint256 pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 pid, uint256 amount);

    constructor(
        IBEP20 _rewardToken,
        uint256 _startBlock,
        ICakeMasterChef _hostChef,
        IBEP20 _hostRewardToken,
        IUniswapV2Router _router,
        address[] memory _swapPath,
        address _treasury
    ) public {
        rewardToken = _rewardToken;
        startBlock = _startBlock != 0 ? _startBlock : block.number;
        router = _router;
        swapPath = _swapPath;
        treasury = _treasury;
        
        require(address(_hostChef) != address(0), "_hostChef can't be 0x");
        hostChef = _hostChef;
        
        require(address(_rewardToken) != address(_hostRewardToken), "_rewardToken and _hostRewardToken can't be same!");
        require(address(_hostRewardToken) != address(0), "_hostRewardToken can't be 0x");
        _hostRewardToken.safeApprove(address(_router), type(uint256).max);
        hostRewardToken = _hostRewardToken;
    }
    
    /* ========== VIEW METHODS ========== */

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    function getPoolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // View function to see pending Reward on frontend.
    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accMacaronPerShare = pool.accMacaronPerShare;
        
        if (block.number > pool.lastRewardBlock && pool.lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 macaronReward = multiplier.mul(pool.rewardPerBlock);
            accMacaronPerShare = accMacaronPerShare.add(macaronReward.mul(1e12).div(pool.lpSupply));
        }
        return user.amount.mul(accMacaronPerShare).div(1e12).sub(user.rewardDebt);
    }

    function getStakedAmountOnHost(uint256 _pid) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        (uint256 stakedAmount, ) = hostChef.userInfo(pool.hostPid, address(this));
        return stakedAmount;
    }

    /* ========== SETTER METHODS ========== */

    function setRouterLoss(uint256 _routerLoss) external onlyOwner {
        routerLoss = _routerLoss;
    }
    
    function setRewardPerBlock(uint256 _pid, uint256 _rewardPerBlock) external onlyOwner {
        poolInfo[_pid].rewardPerBlock = _rewardPerBlock;
        updatePool(_pid);
    }

    function setHostRewardDistPercent(uint256 _percent) external onlyOwner {
        hostRewardDistPercent = _percent;
    }

    function setRouter1(IUniswapV2Router _router) external onlyOwner {
        router = _router;
        hostRewardToken.safeApprove(address(_router), type(uint256).max);
    }

    function setRouter2(IUniswapV2Router _router) external onlyOwner {
        router2 = _router;

        require(swapPath2[0] != address(0), "swapPath2[0] can't be 0x");
        IBEP20(swapPath2[0]).safeApprove(address(router2), type(uint256).max);
    }

    function setRouterPath(address[] memory _path) external onlyOwner {
        swapPath = _path;
    }

    function setRouterPath2(address[] memory _path) external onlyOwner {
        swapPath2 = _path;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setHostChef(ICakeMasterChef _hostChef) external onlyOwner {
        require(address(_hostChef) != address(0), "_hostChef can't be 0x");
        hostChef = _hostChef;
    }

    function setHostRewardToken(IBEP20 _hostRewardToken) external onlyOwner {
        require(address(_hostRewardToken) != address(0), "_hostRewardToken can't be 0x");
        hostRewardToken = _hostRewardToken;
    }

    function setSlippageTolerance(uint256 _slippageTolerance) external onlyOwner {
        require(_slippageTolerance < 500, "Slippage tolerance can't be greather than 50 percent.");
        slippageTolerance = _slippageTolerance;
    }

    /* ========== INTERNAL METHODS ========== */

    function _swapTokens1(address _input, address _output, uint256 _amount) internal {
        if (_input == _output || _amount == 0) return;
        address[] memory path = swapPath;
        
        // use direct path if path not setted
        if (path.length == 0) {
            // path: _input -> _output
            path = new address[](2);
            path[0] = _input;
            path[1] = _output;
        }
        uint256[] memory amountsOuts = router.getAmountsOut(_amount, path);
        uint256 lastAmountOut = amountsOuts[amountsOuts.length-1];
        uint256 amountOutMin = lastAmountOut.sub(lastAmountOut.mul(slippageTolerance).div(1000));   // slippage tolerance
        uint256[] memory amounts = router.swapExactTokensForTokens(_amount, amountOutMin, path, address(this), now);

        if(address(router2) != address(0)) {
            _swapTokens2(path[path.length-1], address(rewardToken), amounts[amounts.length-1]);
        }
    }

    function _swapTokens2(address _input, address _output, uint256 _amount) internal {
        if (_input == _output || _amount == 0) return;
        address[] memory path = swapPath2;
        
        // use direct path if path not setted
        if (path.length == 0) {
            // path: _input -> _output
            path = new address[](2);
            path[0] = _input;
            path[1] = _output;
        }
        uint256[] memory amountsOuts = router2.getAmountsOut(_amount, path);
        uint256 lastAmountOut = amountsOuts[amountsOuts.length-1];
        uint256 amountOutMin = lastAmountOut.sub(lastAmountOut.mul(slippageTolerance).div(1000));   // slippage tolerance
        router2.swapExactTokensForTokens(_amount, amountOutMin, path, address(this), now);
    }

    function _strategy(uint256 _pid) internal {
        PoolInfo memory pool = poolInfo[_pid];
        uint256 stakingTokenBal = pool.lpToken.balanceOf(address(this));
        (uint256 stakedAmountOnHost, ) = hostChef.userInfo(pool.hostPid, address(this));
        uint256 needToAmount = 0;
        if(stakedAmountOnHost <= pool.lpSupply) {
            // need to deposit
            needToAmount = pool.lpSupply.sub(stakedAmountOnHost);
            require(stakingTokenBal >= needToAmount, "strategyDeposit: not enough token for stake! You should never been here!");
            hostChef.deposit(pool.hostPid, needToAmount);
        } else {
            // need to withdraw
            needToAmount = stakedAmountOnHost.sub(pool.lpSupply);
            hostChef.withdraw(pool.hostPid, needToAmount);
        }
    }
    
    function _updateRewardPerBlockByStrategy(uint256 _pid) internal {
        //calculate real reward per block
        PoolInfo storage pool = poolInfo[_pid];
        uint256 hostRewardPerBlock = 0;
        uint256 stakedAmountOnHost = 0;
        uint256 stakedAmountThis = pool.lpSupply;

        // get rewardPerBlock on host contract
        uint256 cakePerBlock = hostChef.cakePerBlock();
        (address lpToken,uint256 allocPoint,,) = hostChef.poolInfo(pool.hostPid);
        uint256 hostTotalAllocPoint = hostChef.totalAllocPoint();
        hostRewardPerBlock = cakePerBlock.mul(allocPoint).div(hostTotalAllocPoint);
        // rewardPerBlock as rewardToken calculation
        // todo: with method
        stakedAmountOnHost = IBEP20(lpToken).balanceOf(address(hostChef));
        
        if(hostRewardPerBlock > 0 && stakedAmountThis > 0 && stakedAmountOnHost > 0) {
            uint256 rewardPerBlockAsHostRewardToken = hostRewardPerBlock.mul(stakedAmountThis).div(stakedAmountOnHost);
            uint256[] memory amountsOuts = router.getAmountsOut(rewardPerBlockAsHostRewardToken, swapPath);
            uint256 rewardPerBlockAsRewardToken = amountsOuts[amountsOuts.length-1];

            if(address(router2) != address(0)) {
                uint256[] memory amountsOuts2 = router2.getAmountsOut(amountsOuts[amountsOuts.length-1], swapPath2);
                rewardPerBlockAsRewardToken = amountsOuts2[amountsOuts2.length-1];
            }

            if(rewardPerBlockAsRewardToken > 0)
                pool.rewardPerBlock = rewardPerBlockAsRewardToken.mul(100-routerLoss).div(100);
            else
                pool.rewardPerBlock = 0;
        }
        else {
            pool.rewardPerBlock = 0;
        }
    }
    
    function _rewardDistribution() internal {
        uint256 rewardBalance = hostRewardToken.balanceOf(address(this));
        if (rewardBalance > 0 && hostRewardDistPercent > 0) {
            hostRewardToken.safeTransfer(treasury, rewardBalance.mul(hostRewardDistPercent).div(100));
        }
    }

    function _buyback() internal {
        uint256 rewardBalance = hostRewardToken.balanceOf(address(this));
        _swapTokens1(address(hostRewardToken), address(rewardToken), rewardBalance);
    }

    /* ========== EXTERNAL/PUBLIC METHODS ========== */

    // Stake STAKING tokens to ChocoChef
    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = 0;
        if (user.amount > 0) {
            pending = user.amount.mul(pool.accMacaronPerShare).div(1e12).sub(user.rewardDebt);
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            pool.lpSupply = pool.lpSupply.add(_amount);
        }
        // Deposit or harvest on host
        _strategy(_pid);
        _rewardDistribution();
        _buyback();
        if (user.amount > 0 && pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }
        user.rewardDebt = user.amount.mul(pool.accMacaronPerShare).div(1e12);
        _updateRewardPerBlockByStrategy(_pid);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw STAKING tokens from STAKING.
    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accMacaronPerShare).div(1e12).sub(user.rewardDebt);
        
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpSupply = pool.lpSupply.sub(_amount);
        }
        // Withdraw on host
        _strategy(_pid);
        
        if(_amount > 0)
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        
        // This line after transfer bec. lpToken and hostRewardToken can be same
        _rewardDistribution();
        _buyback();

        if(pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }
        user.rewardDebt = user.amount.mul(pool.accMacaronPerShare).div(1e12);
        _updateRewardPerBlockByStrategy(_pid);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        pool.lpSupply = pool.lpSupply.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    }

    // Withdraw reward. EMERGENCY ONLY.
    function emergencyRewardWithdraw() external onlyOwner {
        uint256 _amount = rewardToken.balanceOf(address(this));
        if(_amount > 0)
            rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    function addPool(uint256 _hostPid) public onlyOwner {
        (address _lpToken, uint256 _allocPoint,, ) = hostChef.poolInfo(_hostPid);
        require(_allocPoint > 0, "Host allocPoint can't be zero!");
        require(_lpToken != address(hostRewardToken), "_lpToken and _hostRewardToken can't be same!");
        require(isHostPidSupported[_hostPid] == false, "This pool already added before!");
        isHostPidSupported[_hostPid] = true;

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        poolInfo.push(PoolInfo({
            lpToken: IBEP20(_lpToken),
            rewardPerBlock: 0,
            lastRewardBlock: lastRewardBlock,
            accMacaronPerShare: 0,
            hostPid: _hostPid,
            lpSupply: 0,
            lastUpdateBlock: block.number
        }));

        IBEP20(_lpToken).safeApprove(address(hostChef), type(uint256).max);
    }

    function addMultiPool(uint256[] memory _hostPids) external onlyOwner {
        for(uint256 i = 0; i < _hostPids.length; i++) {
            addPool(_hostPids[i]);
        }
    }

    function updatePool(uint256 _pid, uint256 _hostPid) external onlyOwner {
        require(isHostPidSupported[_hostPid] == false, "This pool already added before!");

        (address _lpToken, uint256 _allocPoint,, ) = hostChef.poolInfo(_hostPid);
        require(_allocPoint > 0, "Host allocPoint can't be zero!");
        require(_lpToken != address(hostRewardToken), "_lpToken and _hostRewardToken can't be same!");

        PoolInfo storage pool = poolInfo[_pid];
        require(_lpToken == address(pool.lpToken), "_hostPid lpToken does not match!");

        unstakeAll(_pid);
        isHostPidSupported[pool.hostPid] = false;
        pool.hostPid = _hostPid;
        isHostPidSupported[_hostPid] = true;
        pool.lastUpdateBlock = block.number;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            updatePool(pid);
            _updateRewardPerBlockByStrategy(pid);
        }
    }

    function rewardDistribution() external onlyOwner {
        _rewardDistribution();
    }
    
    function buyback(uint256 _pid) external onlyOwner {
        _strategy(_pid);
        _buyback();
    }

    function buybackAll() external onlyOwner {
        for(uint256 i = 0; i < poolInfo.length; i++) {
            _strategy(i);
        }
        _buyback();
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        
        if (pool.lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 macaronReward = multiplier.mul(pool.rewardPerBlock);
        pool.accMacaronPerShare = pool.accMacaronPerShare.add(macaronReward.mul(1e12).div(pool.lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function unstakeAll(uint256 _pid) public onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        (uint256 _stakedAmount, ) = hostChef.userInfo(pool.hostPid, address(this));
        hostChef.withdraw(pool.hostPid, _stakedAmount);
    }
}