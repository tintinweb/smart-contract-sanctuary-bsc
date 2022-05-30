/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT
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


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;


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
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File @openzeppelin/contracts/utils/math/[email protected]

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


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and making it call a
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


// File contracts/lib/Babylonian.sol


pragma solidity 0.8.9;

library Babylonian {
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
        // else z = 0
    }
}


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

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


// File contracts/owner/Operator.sol


pragma solidity 0.8.9;


contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}


// File contracts/utils/ContractGuard.sol


pragma solidity 0.8.9;

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}


// File contracts/interfaces/IBasisAsset.sol


pragma solidity 0.8.9;

interface IBasisAsset {
    function mint(address recipient, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;

    function isOperator() external returns (bool);

    function operator() external view returns (address);

    function transferOperator(address newOperator_) external;
}


// File contracts/interfaces/IPrinter.sol


pragma solidity 0.8.9;

interface IPrinter {
    function balanceOf(address _mason) external view returns (uint256);

    function earned(address _mason) external view returns (uint256);

    function canWithdraw(address _mason) external view returns (bool);

    function canClaimReward(address _mason) external view returns (bool);

    function epoch() external view returns (uint256);

    function nextEpochPoint() external view returns (uint256);

    function setOperator(address _operator) external;

    function setLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external;

    function stake(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function exit() external;

    function claimReward() external;

    function allocateSeigniorage(uint256 _amount) external;

    function governanceRecoverUnsupported(address _token, uint256 _amount, address _to) external;
}


// File contracts/interfaces/IInk.sol


pragma solidity 0.8.9;

interface IInk {
    function mint(address recipient, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;

    function isOperator() external returns (bool);

    function operator() external view returns (address);

    function transferOperator(address newOperator_) external;

    function setTaxRate(uint256 _taxRate) external;

    function setNoTaxSenderAddr(address _noTaxSenderAddr, bool _value) external;

    function setNoTaxRecipientAddr(address _noTaxRecipientAddr, bool _value) external;
    
    function setNoTax(address _noTaxAddr, bool _value) external;
    
    function setInvestmentFundAddress(address _investmentFund) external;
    
    function setDevFundAddress(address _devFund) external;
}


// File contracts/TreasuryV3.sol


pragma solidity 0.8.9;









contract TreasuryV3 is ContractGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    // governance
    address public operator;
    mapping(address => bool) public bridgeOperators;
    mapping(address => bool) public bridgeAdmins;

    // flags
    bool public initialized = false;

    // epoch
    uint256 public startTime;
    uint256 public epoch       = 0;
    uint256 public epochPeriod = 6 hours;

    // core components
    address public paper;
    address public ink;
    address public printer;

    // supply
    uint256   public totalPaperMinted;
    uint256   public maxPaperToMint = 5000000 ether;
    uint256[] public mintTable;

    // events
    event Initialized(address indexed executor, uint256 at);
    event PrinterFunded (uint256 timestamp, uint256 seigniorage);
    event SetBridgeAdmin(address adminAddress, bool enabled);
    event SetBridgeOperator(address operatorAddress, bool enabled);
    event SetMaxPaperToMint(uint256 paperAmount);
    event SetTotalPaperMinted(uint256 paperAmount);
    event SetInkTaxRate(uint256 taxRate);
    event SetOperator(address operator);
    event SetEpoch(uint256 epoch);
    event SetStartTime(uint256 startTime);
    event ClearBridgeAdmins();
    event ClearBridgeOperators();

    modifier onlyOperator() {
        require(operator == msg.sender, "Treasury: caller is not the operator");
        _;
    }
    
    modifier onlyBridgeOperators {
        require(bridgeOperators[msg.sender] == true, "Treasury: caller is not a bridge operator");
        _;
    }

    modifier onlyBridgeAdmins {
        require(bridgeAdmins[msg.sender] == true, "Treasury: caller is not a bridge admin");
        _;
    }

    modifier checkCondition {
        require(block.timestamp >= startTime, "Treasury: not started yet");

        _;
    }

    modifier checkEpoch {
        require(block.timestamp >= nextEpochPoint(), "Treasury: not opened yet");

        _;

        epoch = epoch.add(1);
    }

    modifier checkOperator {
        require(
            IBasisAsset(paper).operator() == address(this) &&
                IBasisAsset(ink).operator() == address(this) &&
                Operator(printer).operator() == address(this),
            "Treasury: need more permission"
        );

        _;
    }

    modifier notInitialized {
        require(!initialized, "Treasury: already initialized");

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */
    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // epoch
    function nextEpochPoint() public view returns (uint256) {
        return startTime.add(epoch.mul(epochPeriod));
    }


    /* ========== GOVERNANCE ========== */
    function initialize(
        address _paper,
        address _ink,
        address _printer,
        uint256 _startTime,
        uint256 _epochPeriod
    ) public notInitialized {
        paper            = _paper;
        ink              = _ink;
        printer          = _printer;
        startTime        = _startTime;
        epochPeriod      = _epochPeriod;

        initialized = true;
        operator = msg.sender;

        bridgeAdmins[msg.sender] = true;

        _buildTable();
        
        emit Initialized(msg.sender, block.number);
    }

    /* PUBLIC FUNCTIONS */
    function allocateSeigniorage() external onlyOneBlock checkCondition checkEpoch checkOperator {
        require(totalPaperMinted <= maxPaperToMint, "Treasury: Max paper already minted");

        uint256 _toMint;
        uint256 _dayIndex = epoch/4;
        
        if (_dayIndex >= mintTable.length) {
            _dayIndex = mintTable.length - 1;
        }

        _toMint = mintTable[_dayIndex] * (10**18);

        if(totalPaperMinted + _toMint > maxPaperToMint) {
            _toMint = maxPaperToMint - totalPaperMinted;
        }

        totalPaperMinted = totalPaperMinted + _toMint;
        
        _sendToPrinter(_toMint);
    }
    /* END PUBLIC FUNCTIONS */

    /* OPERATOR FUNCTIONS */
    function setMaxPaperToMint(uint256 _paperAmount) external onlyOperator {
        maxPaperToMint = _paperAmount;
        emit SetMaxPaperToMint(_paperAmount);
    }

    function setTotalPaperMinted(uint256 _paperAmount) external onlyOperator {
        totalPaperMinted = _paperAmount;
        emit SetTotalPaperMinted(_paperAmount);
    }    
    
    function setEpoch(uint256 _epoch) external onlyOperator {
        epoch = _epoch;
        emit SetEpoch(_epoch);
    }

    function setStartTime(uint256 _startTime) external onlyOperator {
        startTime = _startTime;
        emit SetStartTime(_startTime);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
        emit SetOperator(_operator);
    }

    function setInkTaxRate(uint256 _taxRate) external onlyOperator {
        IInk(ink).setTaxRate(_taxRate);
        emit SetInkTaxRate(_taxRate);
    }

    function setInkNoTaxSenderAddr(address _noTaxSenderAddr, bool _value) external onlyOperator {
        IInk(ink).setNoTaxSenderAddr(_noTaxSenderAddr, _value);
    }

    function setInkNoTaxRecipientAddr(address _noTaxRecipientAddr, bool _value) external onlyOperator {
        IInk(ink).setNoTaxRecipientAddr(_noTaxRecipientAddr, _value);
    }

    function setInkNoTax(address _noTaxAddr, bool _value) external onlyOperator {
        IInk(ink).setNoTax(_noTaxAddr, _value);
    }

    function setInkInvestmentFundAddress(address _investmentFund) external onlyOperator {
        IInk(ink).setInvestmentFundAddress(_investmentFund);
    }

    function setInkDevFundAddress(address _devFund) external onlyOperator {
        IInk(ink).setDevFundAddress(_devFund);
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        _token.safeTransfer(_to, _amount);
    }

    function paperSetOperator(address _operator) external onlyOperator {
        IBasisAsset(paper).transferOperator(_operator);
    }

    function inkSetOperator(address _operator) external onlyOperator {
        IBasisAsset(ink).transferOperator(_operator);
    }    
    
    function printerSetOperator(address _operator) external onlyOperator {
        IPrinter(printer).setOperator(_operator);
    }

    function printerSetLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external onlyOperator {
        IPrinter(printer).setLockUp(_withdrawLockupEpochs, _rewardLockupEpochs);
    }

    function printerGovernanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        IPrinter(printer).governanceRecoverUnsupported(_token, _amount, _to);
    }
    /* END OPERATOR FUNCTIONS */

    /* BRIDGE ADMIN FUNCTIONS */
    function setBridgeOperator(address _operatorAddress, bool _enabled) external onlyBridgeAdmins {
        bridgeOperators[_operatorAddress] = _enabled;
        emit SetBridgeOperator(_operatorAddress, _enabled);
    }

    function setBridgeAdmin(address _adminAddress, bool _enabled) external onlyBridgeAdmins {
        bridgeAdmins[_adminAddress] = _enabled;
        emit SetBridgeAdmin(_adminAddress, _enabled);
    }
    /* END BRIDGE ADMIN FUNCTIONS */

    /* BRIDGE OPERATOR FUNCTIONS */
    function bridgeMint(address _recipient, uint256 _amount) external onlyBridgeOperators {
        IBasisAsset(paper).mint(_recipient, _amount);
    }
    /* END BRIDGE OPERATOR FUNCTIONS */

    /* INTERNAL FUNCTIONS */
    function _sendToPrinter(uint256 _amount) internal {
        IBasisAsset(paper).mint(address(this), _amount);

        IERC20(paper).safeApprove(printer, 0);
        IERC20(paper).safeApprove(printer, _amount);
        IPrinter(printer).allocateSeigniorage(_amount);
        emit PrinterFunded(block.timestamp, _amount);
    }
    /* END INTERNAL FUNCTIONS */

    function _buildTable() internal {
        mintTable = [
            10,26,42,58,74,90,106,121,137,152,167,182,197,212,227,242,256,270,285,299,313,327,341,355,368,382,395,408,422,435,448,461,473,486,499,511,523,536,548,560,572,584,595,607,619,630,642,653,664,675,686,697,708,719,729,740,750,761,771,781,791,801,811,821,831,840,850,859,869,878,887,896,906,915,923,932,941,950,958,967,975,984,992,1000,1008,1016,1024,1032,1040,1048,1055,1063,1071,1078,1085,1093,1100,1107,1114,1121,1128,
            1135,1142,1149,1155,1162,1169,1175,1181,1188,1194,1200,1207,1213,1219,1225,1231,1236,1242,1248,1254,1259,1265,1270,1276,1281,1286,1292,1297,1302,1307,1312,1317,1322,1327,1331,1336,1341,1345,1350,1355,1359,1363,1368,1372,1376,1381,1385,1389,1393,1397,1401,1405,1409,1412,1416,1420,1423,1427,1431,1434,1438,1441,1444,1448,1451,1454,1457,1460,1464,1467,1470,1473,1475,1478,1481,1484,1487,1489,1492,1495,1497,1500,1502,1505,1507,1510,1512,1514,1516,1519,1521,1523,1525,1527,1529,1531,1533,1535,1537,1539,1541,
            1542,1544,1546,1547,1549,1551,1552,1554,1555,1557,1558,1560,1561,1562,1564,1565,1566,1567,1568,1570,1571,1572,1573,1574,1575,1576,1577,1578,1578,1579,1580,1581,1582,1582,1583,1584,1584,1585,1585,1586,1587,1587,1588,1588,1588,1589,1589,1589,1590,1590,1590,1591,1591,1591,1591,1591,1591,1592,1592,1592,1592,1592,1592,1592,1592,1591,1591,1591,1591,1591,1591,1591,1590,1590,1590,1589,1589,1589,1588,1588,1588,1587,1587,1586,1586,1585,1585,1584,1584,1583,1583,1582,1581,1581,1580,1579,1579,1578,1577,1576,1576,
            1575,1574,1573,1572,1572,1571,1570,1569,1568,1567,1566,1565,1564,1563,1562,1561,1560,1559,1558,1557,1556,1555,1554,1552,1551,1550,1549,1548,1547,1545,1544,1543,1542,1540,1539,1538,1536,1535,1534,1532,1531,1530,1528,1527,1526,1524,1523,1521,1520,1518,1517,1515,1514,1512,1511,1509,1508,1506,1505,1503,1502,1500,1499,1498,1496,1495,1494,1493,1492,1491,1490,1488,1487,1486,1485,1484,1483,1482,1480,1479,1478,1477,1476,1475,1474,1472,1471,1470,1469,1468,1467,1466,1464,1463,1462,1461,1460,1459,1458,1456,1455,
            1454,1453,1452,1451,1450,1448,1447,1446,1445,1444,1443,1442,1440,1439,1438,1437,1436,1435,1434,1432,1431,1430,1429,1428,1427,1426,1424,1423,1422,1421,1420,1419,1418,1416,1415,1414,1413,1412,1411,1410,1408,1407,1406,1405,1404,1403,1402,1400,1399,1398,1397,1396,1395,1394,1392,1391,1390,1389,1388,1387,1386,1384,1383,1382,1381,1380,1379,1378,1376,1375,1374,1373,1372,1371,1370,1368,1367,1366,1365,1364,1363,1362,1360,1359,1358,1357,1356,1355,1354,1352,1351,1350,1349,1348,1347,1345,1344,1343,1342,1341,1340,
            1339,1337,1336,1335,1334,1333,1332,1331,1329,1328,1327,1326,1325,1324,1323,1321,1320,1319,1318,1317,1316,1315,1313,1312,1311,1310,1309,1308,1307,1305,1304,1303,1302,1301,1300,1299,1297,1296,1295,1294,1293,1292,1291,1289,1288,1287,1286,1285,1284,1283,1281,1280,1279,1278,1277,1276,1275,1273,1272,1271,1270,1269,1268,1267,1265,1264,1263,1262,1261,1260,1259,1257,1256,1255,1254,1253,1252,1251,1249,1248,1247,1246,1245,1244,1243,1241,1240,1239,1238,1237,1236,1235,1233,1232,1231,1230,1229,1228,1227,1225,1224,
            1223,1222,1221,1220,1219,1217,1216,1215,1214,1213,1212,1211,1209,1208,1207,1206,1205,1204,1203,1201,1200,1199,1198,1197,1196,1194,1193,1192,1191,1190,1189,1188,1186,1185,1184,1183,1182,1181,1180,1178,1177,1176,1175,1174,1173,1172,1170,1169,1168,1167,1166,1165,1164,1162,1161,1160,1159,1158,1157,1156,1154,1153,1152,1151,1150,1149,1148,1146,1145,1144,1143,1142,1141,1140,1138,1137,1136,1135,1134,1133,1132,1130,1129,1128,1127,1126,1125,1124,1122,1121,1120,1119,1118,1117,1116,1114,1113,1112,1111,1110,1109,
            1108,1106,1105,1104,1103,1102,1101,1100,1098,1097,1096,1095,1094,1093,1092,1090,1089,1088,1087,1086,1085,1084,1082,1081,1080,1079,1078,1077,1076,1074,1073,1072,1071,1070,1069,1068,1066,1065,1064,1063,1062,1061,1060,1058,1057,1056,1055,1054,1053,1051,1050,1049,1048,1047,1046,1045,1043,1042,1041,1040,1039,1038,1037,1035,1034,1033,1032,1031,1030,1029,1027,1026,1025,1024,1023,1022,1021,1019,1018,1017,1016,1015,1014,1013,1011,1010,1009,1008,1007,1006,1005,1003,1002,1001,1000,999,998,997,995,994,993,
            992,991,990,989,987,986,985,984,983,982,981,979,978,977,976,975,974,973,971,970,969,968,967,966,965,963,962,961,960,959,958,957,955,954,953,952,951,950,949,947,946,945,944,943,942,941,939,938,937,936,935,934,933,931,930,929,928,927,926,925,923,922,921,920,919,918,917,915,914,913,912,911,910,909,907,906,905,904,903,902,900,899,898,897,896,895,894,892,891,890,889,888,887,886,884,883,882,881,880,879,878,
            876,875,874,873,872,871,870,868,867,866,865,864,863,862,860,859,858,857,856,855,854,852,851,850,849,848,847,846,844,843,842,841,840,839,838,836,835,834,833,832,831,830,828,827,826,825,824,823,822,820,819,818,817,816,815,814,812,811,810,809,808,807,806,804,803,802,801,800,799,798,796,795,794,793,792,791,790,788,787,786,785,784,783,782,780,779,778,777,776,775,774,772,771,770,769,768,767,766,764,763,762,
            761,760,759,758,756,755,754,753,752,751,749,748,747,746,745,744,743,741,740,739,738,737,736,735,733,732,731,730,729,728,727,725,724,723,722,721,720,719,717,716,715,714,713,712,711,709,708,707,706,705,704,703,701,700,699,698,697,696,695,693,692,691,690,689,688,687,685,684,683,682,681,680,679,677,676,675,674,673,672,671,669,668,667,666        
        ];
    }
}