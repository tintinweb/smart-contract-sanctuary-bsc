/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: MIT

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


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
        assembly {
            size := extcodesize(account)
        }
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity >=0.6.2;

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

pragma solidity >=0.6.2;



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


contract tokenSale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public token;
    IERC20 public busd;
    IERC20 public usdt;
    IERC20 public bnb;

    address public BNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public BUSD = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;

    address router02 = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 private _UniswapV2Router02;
    
    uint256 one = 1*10e18;

    bool public isPreSale = true;
    uint256 public isClaimV1 = block.timestamp + 365 days;
    uint256 public isClaimV2 = block.timestamp + 395 days;
    uint256 public isClaimV3 = block.timestamp + 425 days;
    uint256 public isClaimV4 = block.timestamp + 455 days;
    uint256 public isClaimV5 = block.timestamp + 485 days;
    uint256 public isClaimV6 = block.timestamp + 515 days;

    uint256 public tokenPerUsd = 0.6 * 1e18;
    uint256 constant MIN_BUSD = 110 * 1e18;
    uint256 public soldAmount = 0;
    uint256 public withdrawnTokens = 0;

    mapping(address => uint256) public buyerAmount;
	mapping(address => uint256) public claimAmount;
    mapping(address => bool) public buyerAmountV;
    mapping(address => bool) public buyerAmountV1;
    mapping(address => bool) public buyerAmountV2;
    mapping(address => bool) public buyerAmountV3;
    mapping(address => bool) public buyerAmountV4;
    mapping(address => bool) public buyerAmountV5;
    mapping(address => bool) public buyerAmountV6;
    
    address wallet = address(0);

    //Token
    //0x6544378a1262aCd7EfecBa2B0dB402a84cE540bF
    //BUSD
    //0xfb8EeEF304382E52490F6240909f99E8ACA97b89
    //USDT
    //0xfF34cb7B81EaF0CB4037c812225fBdC1a97157A4
    //Wallet
    //0x50be3d4219078CAE0e13c5740b92c4b194097eAB
    //BNB
    //0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd


    event LogEnablePreSale(bool status);
    event LogEnableClaimPreSale(uint256 status, uint256 version);
    event LogClaimBuyer(address buyer, uint256 neifAmount, uint256 datetime, uint256 version);
    event LogBuyWithBNB(address buyer, uint256 amountInBNB, uint256 datetime);
    event LogBuyWithBUSD(address buyer, uint256 amountInBUSD, uint256 datetime);
    event LogBuyWithUSDT(address buyer, uint256 amountInUSDT, uint256 datetime);

    constructor(IERC20 _token, IERC20 _busd, IERC20 _usdt, address _wallet) {
    //constructor() {
        require(
            address(_busd) != address(0) && address(_token) != address(0),
            "zero address in constructor"
        );
        busd = _busd;
        usdt = _usdt;
        token = _token;
        wallet = _wallet;
        /*busd = IERC20(0xfb8EeEF304382E52490F6240909f99E8ACA97b89);
        token = IERC20(0x6544378a1262aCd7EfecBa2B0dB402a84cE540bF);
        wallet = 0x50be3d4219078CAE0e13c5740b92c4b194097eAB;*/
        bnb = IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        _UniswapV2Router02 = IUniswapV2Router02(router02);
    }

    function bnbPrice() external view returns(uint256){
        address[] memory path = new address[](2);
        path[0]=BNB;
        path[1]=BUSD;
        return _UniswapV2Router02.getAmountsOut(one,path)[1].div(one);
    }

    function usdToBnb(uint256 amount) external view returns(uint256){
        address[] memory path = new address[](2);
        path[1]=BNB;
        path[0]=BUSD;
        return _UniswapV2Router02.getAmountsOut(amount,path)[1];
    }

    function usdToBnbPriv(uint256 amount) private view returns(uint256){
        address[] memory path = new address[](2);
        path[1]=BNB;
        path[0]=BUSD;
        return _UniswapV2Router02.getAmountsOut(amount,path)[1];
    }
    /*
    function bnbToUsd(uint256 amount) external view returns(uint256){
        address[] memory path = new address[](2);
        path[0]=BNB;
        path[1]=BUSD;
        return _UniswapV2Router02.getAmountsOut(amount,path)[1];
    }*/

    modifier onlyBuyer() {
        require(buyerAmount[msg.sender] > 0, "Only buyer");
        _;
    }

    function buyWithBNB(uint256 amount) external nonReentrant {
        require(
            isPreSale == true,
            "Not Open Pre Sale"
        );
        require(
            amount >= MIN_BUSD,
            "amount required >= 110 BUSD"
        );
        //require(buyerAmount[msg.sender] == 0, "Limit 1 transation per address");
        //require(amount <= bnb.balanceOf(msg.sender), "BNB is not enough");
        uint256 bamount = usdToBnbPriv(amount);
        require(bamount <= address(msg.sender).balance, "BNB is not enough");
        uint256 tokenToReceived = amount.div(tokenPerUsd).mul(1e18);
        //require(tokenToReceived <= remainTokenQuota, "over max sale amount");
    //    require(amount.mod(tokenPerUsd) == 0, "only whole pieces can be purchased");
        //remainTokenQuota = remainTokenQuota.sub(tokenToReceived);
        buyerAmount[msg.sender] = buyerAmount[msg.sender].add(tokenToReceived);
        buyerAmountV[msg.sender] = false;
        buyerAmountV1[msg.sender] = true; 
        buyerAmountV2[msg.sender] = true;
        buyerAmountV3[msg.sender] = true; 
        buyerAmountV4[msg.sender] = true;
        buyerAmountV5[msg.sender] = true;
        buyerAmountV6[msg.sender] = true;
        //soldAmount = soldAmount.add(tokenToReceived*1e18);
        soldAmount = soldAmount.add(tokenToReceived);


        
        //busd.safeTransferFrom(msg.sender, address(this), amount);
        bnb.safeTransferFrom(msg.sender, wallet, bamount);
        /*emit LogBuyWithBUSD(
            msg.sender,
            amount,
            remainTokenQuota,
            block.timestamp
        );*/
        token.safeTransfer(msg.sender, tokenToReceived.div(100).mul(30));
        withdrawnTokens = withdrawnTokens + tokenToReceived.div(100).mul(30);
        emit LogBuyWithBNB(
            msg.sender,
            amount,
            block.timestamp
        );
    }

    function buyWithBUSD(uint256 amount) external nonReentrant {
        require(
            isPreSale == true,
            "Not Open Pre Sale"
        );
        require(
            amount >= MIN_BUSD,
            "amount required >= 110 BUSD"
        );
        //require(buyerAmount[msg.sender] == 0, "Limit 1 transation per address");
        require(amount <= busd.balanceOf(msg.sender), "BUSD is not enough");
        uint256 tokenToReceived = amount.div(tokenPerUsd).mul(1e18);
        //require(tokenToReceived <= remainTokenQuota, "over max sale amount");
        require(amount.mod(tokenPerUsd) == 0, "only whole pieces can be purchased");
        //remainTokenQuota = remainTokenQuota.sub(tokenToReceived);
        buyerAmount[msg.sender] = buyerAmount[msg.sender].add(tokenToReceived);
        buyerAmountV[msg.sender] = false;
        buyerAmountV1[msg.sender] = true; 
        buyerAmountV2[msg.sender] = true;
        buyerAmountV3[msg.sender] = true; 
        buyerAmountV4[msg.sender] = true;
        buyerAmountV5[msg.sender] = true;
        buyerAmountV6[msg.sender] = true;
        //soldAmount = soldAmount.add(tokenToReceived*1e18);
        soldAmount = soldAmount.add(tokenToReceived);

        //busd.safeTransferFrom(msg.sender, address(this), amount);
        busd.safeTransferFrom(msg.sender, wallet, amount);
        /*emit LogBuyWithBUSD(
            msg.sender,
            amount,
            remainTokenQuota,
            block.timestamp
        );*/
        token.safeTransfer(msg.sender, tokenToReceived.div(100).mul(30));
        withdrawnTokens = withdrawnTokens + tokenToReceived.div(100).mul(30);
        emit LogBuyWithBUSD(
            msg.sender,
            amount,
            block.timestamp
        );
    }

    function buyWithUSDT(uint256 amount) external nonReentrant {
        require(
            isPreSale == true,
            "Not Open Pre Sale"
        );
        require(
            amount >= MIN_BUSD,
            "amount required >= 50 BUSD"
        );
        //require(buyerAmount[msg.sender] == 0, "Limit 1 transation per address");
        require(amount <= usdt.balanceOf(msg.sender), "USDT is not enough");
        uint256 tokenToReceived = amount.div(tokenPerUsd).mul(1e18);
        //require(tokenToReceived <= remainTokenQuota, "over max sale amount");
        require(amount.mod(tokenPerUsd) == 0, "only whole pieces can be purchased");
        //remainTokenQuota = remainTokenQuota.sub(tokenToReceived);
        buyerAmount[msg.sender] = buyerAmount[msg.sender].add(tokenToReceived);
        buyerAmountV[msg.sender] = false;
        buyerAmountV1[msg.sender] = true; 
        buyerAmountV2[msg.sender] = true;
        buyerAmountV3[msg.sender] = true; 
        buyerAmountV4[msg.sender] = true;
        buyerAmountV5[msg.sender] = true;
        buyerAmountV6[msg.sender] = true;
        //soldAmount = soldAmount.add(tokenToReceived*1e18);
        soldAmount = soldAmount.add(tokenToReceived);

        //busd.safeTransferFrom(msg.sender, address(this), amount);
        usdt.safeTransferFrom(msg.sender, wallet, amount);
        /*emit LogBuyWithBUSD(
            msg.sender,
            amount,
            remainTokenQuota,
            block.timestamp
        );*/
        token.safeTransfer(msg.sender, tokenToReceived.div(100).mul(30));
        withdrawnTokens = withdrawnTokens + tokenToReceived.div(100).mul(30);
        emit LogBuyWithUSDT(
            msg.sender,
            amount,
            block.timestamp
        );
    }

    function claimV() external onlyBuyer {
        require(buyerAmountV[msg.sender] == true, "Not open claim yet");
        uint256 amount = claimAmount[msg.sender];
        buyerAmountV[msg.sender] = false;
        withdrawnTokens = withdrawnTokens + amount;

        token.safeTransfer(msg.sender, amount);
		claimAmount[msg.sender] = 0;
        emit LogClaimBuyer(msg.sender, amount, block.timestamp, 0);
    }

    function claimV1() external onlyBuyer {
        require(isClaimV1 < block.timestamp && buyerAmountV1[msg.sender] == true, "Not open claim yet");
        uint256 amount = buyerAmount[msg.sender].div(100).mul(11);
        buyerAmountV1[msg.sender] = false;
        withdrawnTokens = withdrawnTokens + amount;

        token.safeTransfer(msg.sender, amount);
        emit LogClaimBuyer(msg.sender, amount, block.timestamp, 1);
    }

    function claimV2() external onlyBuyer {
        require(isClaimV2 < block.timestamp && buyerAmountV2[msg.sender] == true, "Not open claim yet");
        uint256 amount = buyerAmount[msg.sender].div(100).mul(11);
        buyerAmountV2[msg.sender] = false;
        withdrawnTokens = withdrawnTokens + amount;

        token.safeTransfer(msg.sender, amount);
        emit LogClaimBuyer(msg.sender, amount, block.timestamp, 2);
    }

    function claimV3() external onlyBuyer {
        require(isClaimV3 < block.timestamp && buyerAmountV3[msg.sender] == true, "Not open claim yet");
        uint256 amount = buyerAmount[msg.sender].div(100).mul(11);
        buyerAmountV3[msg.sender] = false;
        withdrawnTokens = withdrawnTokens + amount;

        token.safeTransfer(msg.sender, amount);
        emit LogClaimBuyer(msg.sender, amount, block.timestamp, 3);
    }

    function claimV4() external onlyBuyer {
        require(isClaimV4 < block.timestamp && buyerAmountV4[msg.sender]== true, "Not open claim yet");
        uint256 amount = buyerAmount[msg.sender].div(100).mul(11);
        buyerAmountV4[msg.sender] = false;
        withdrawnTokens = withdrawnTokens + amount;

        token.safeTransfer(msg.sender, amount);
        emit LogClaimBuyer(msg.sender, amount, block.timestamp, 4);
    }

    function claimV5() external onlyBuyer {
        require(isClaimV5 < block.timestamp && buyerAmountV5[msg.sender] == true, "Not open claim yet");
        uint256 amount = buyerAmount[msg.sender].div(100).mul(11);
        buyerAmountV5[msg.sender] = false;
        withdrawnTokens = withdrawnTokens + amount;

        token.safeTransfer(msg.sender, amount);
        emit LogClaimBuyer(msg.sender, amount, block.timestamp, 5);
    }

    function claimV6() external onlyBuyer {
        require(isClaimV6 < block.timestamp && buyerAmountV6[msg.sender] == true, "Not open claim yet");
        uint256 amount = buyerAmount[msg.sender].div(100).mul(15);
        buyerAmountV6[msg.sender] = false;
        withdrawnTokens = withdrawnTokens + amount;

        token.safeTransfer(msg.sender, amount);
        emit LogClaimBuyer(msg.sender, amount, block.timestamp, 6);
    }

    function setEnableClaimV1(uint256 state) external onlyOwner {
        isClaimV1 = state;
        emit LogEnableClaimPreSale(isClaimV1, 1);
    }

    function setEnableClaimV2(uint256 state) external onlyOwner {
        isClaimV2 = state;
        emit LogEnableClaimPreSale(isClaimV2, 2);
    }

    function setEnableClaimV3(uint256 state) external onlyOwner {
        isClaimV3 = state;
        emit LogEnableClaimPreSale(isClaimV3, 3);
    }

    function setEnableClaimV4(uint256 state) external onlyOwner {
        isClaimV4 = state;
        emit LogEnableClaimPreSale(isClaimV4, 4);
    }

    function setEnableClaimV5(uint256 state) external onlyOwner {
        isClaimV5 = state;
        emit LogEnableClaimPreSale(isClaimV5, 5);
    }

    function setEnableClaimV6(uint256 state) external onlyOwner {
        isClaimV6 = state;
        emit LogEnableClaimPreSale(isClaimV6, 6);
    }

    function setEnablePreSale(bool state) external onlyOwner {
        isPreSale = state;
        emit LogEnablePreSale(isPreSale);
    }

    function setTokenAddress(IERC20 _token) external onlyOwner {
        token = IERC20(_token);
    }

    function getTokenAddress() external view returns (IERC20) {
        return token;
    }

    function withdrawBUSD(uint256 amount) external onlyOwner {
        busd.safeTransfer(msg.sender, amount);
    }

    function withdrawToken(uint256 amount) external onlyOwner {
        token.safeTransfer(msg.sender, amount);
    }

    function balanceOfToken() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function balanceOfBusd() external view returns (uint256) {
        return busd.balanceOf(address(this));
    }

    function balanceOfUsdt() external view returns (uint256) {
        return usdt.balanceOf(address(this));
    }
	
	function withdrawBNB(address to, uint256 value) external onlyOwner {
        require(address(this).balance >= value, "Insufficient BNB balance");
        (bool success,) = to.call{value: value}("");
        require(success, "Transfer failed");
    }

    function withdrawTokens(address tokenAddress, address to, uint256 value) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= value, "Insufficient token balance");

        try IERC20(tokenAddress).transfer(to, value) {} catch {
            revert("Transfer failed");
        }
    }
	
	function multiAllower(address[] memory _contributors, uint256[] memory _amount) external onlyOwner{
        require(_contributors.length <= 100);
        require(_contributors.length == _amount.length);
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            buyerAmount[_contributors[i]] = buyerAmount[_contributors[i]].add(_amount[i]);
			claimAmount[_contributors[i]] = claimAmount[_contributors[i]].add(_amount[i].div(100).mul(30));
            soldAmount = soldAmount.add(_amount[i]);
            buyerAmountV[_contributors[i]] = true;
            buyerAmountV1[_contributors[i]] = true; 
            buyerAmountV2[_contributors[i]] = true;
            buyerAmountV3[_contributors[i]] = true; 
            buyerAmountV4[_contributors[i]] = true;
            buyerAmountV5[_contributors[i]] = true;
            buyerAmountV6[_contributors[i]] = true;
        }
    }
}