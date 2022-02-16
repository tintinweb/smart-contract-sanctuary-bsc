/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol

// 
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol

// 
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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// 
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

// File: contracts/interfaces/IBEP20.sol

pragma solidity ^0.8.0;

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

// File: contracts/helpers/SafeBEP20.sol

// 

pragma solidity ^0.8.0;



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
    using AddressUpgradeable for address;

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
            "SafeBEP20: approve from non-zero to non-zero allowance"
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
            "SafeBEP20: decreased allowance below zero"
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

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// File: contracts/interfaces/IMinimaxToken.sol

// 
pragma solidity ^0.8.0;

interface IMinimaxToken {
    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;

    function owner() external returns (address);
}

// File: contracts/MinimaxStaking.sol

// 
pragma solidity ^0.8.0;






contract MinimaxStaking is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    uint public constant SHARE_MULTIPLIER = 1e12;

    using SafeMath for uint;
    using SafeBEP20 for IBEP20;

    struct UserPoolInfo {
        uint amount; // How many LP tokens the user has provided.
        uint rewardDebt; // Reward debt. See explanation below.
        uint timeDeposited; // timestamp when minimax was deposited
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 token; // Address of LP token contract.
        uint totalSupply;
        uint allocPoint; // How many allocation points assigned to this pool. MINIMAXs to distribute per block.
        uint timeLocked; // How long stake must be locked for
        uint lastRewardBlock; // Last block number that MINIMAXs distribution occurs.
        uint accMinimaxPerShare; // Accumulated MINIMAXs per share, times SHARE_MULTIPLIER. See below.
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint => mapping(address => UserPoolInfo)) public userPoolInfo;

    address public minimaxToken;
    uint public minimaxPerBlock;
    uint public startBlock;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint public totalAllocPoint;

    event Deposit(address indexed user, uint indexed pid, uint amount);
    event Withdraw(address indexed user, uint indexed pid, uint amount);
    event EmergencyWithdraw(address indexed user, uint indexed pid, uint256 amount);
    event PoolAdded(uint allocPoint, uint timeLocked);
    event SetMinimaxPerBlock(uint minimaxPerBlock);
    event SetPool(uint pid, uint allocPoint);

    function initialize(
        address _minimaxToken,
        uint _minimaxPerBlock,
        uint _startBlock
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        minimaxToken = _minimaxToken;
        minimaxPerBlock = _minimaxPerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(
            PoolInfo({
                token: IBEP20(minimaxToken),
                totalSupply: 0,
                allocPoint: 800,
                timeLocked: 0 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                token: IBEP20(minimaxToken),
                totalSupply: 0,
                allocPoint: 1400,
                timeLocked: 7 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                token: IBEP20(minimaxToken),
                totalSupply: 0,
                allocPoint: 2000,
                timeLocked: 30 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        poolInfo.push(
            PoolInfo({
                token: IBEP20(minimaxToken),
                totalSupply: 0,
                allocPoint: 3000,
                timeLocked: 90 days,
                lastRewardBlock: startBlock,
                accMinimaxPerShare: 0
            })
        );
        totalAllocPoint = 7200;
    }

    /* ========== External Functions ========== */

    function getUserAmount(uint _pid, address _user) external view returns (uint) {
        UserPoolInfo storage user = userPoolInfo[_pid][_user];
        return user.amount;
    }

    // View function to see pending MINIMAXs from Pools on frontend.
    function pendingMinimax(uint _pid, address _user) external view returns (uint) {
        PoolInfo memory pool = poolInfo[_pid];
        UserPoolInfo memory user = userPoolInfo[_pid][_user];

        // Minting reward
        uint accMinimaxPerShare = pool.accMinimaxPerShare;
        if (block.number > pool.lastRewardBlock && pool.totalSupply != 0) {
            uint multiplier = (block.number).sub(pool.lastRewardBlock);
            uint minimaxReward = multiplier.mul(minimaxPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accMinimaxPerShare = accMinimaxPerShare.add(minimaxReward.mul(SHARE_MULTIPLIER).div(pool.totalSupply));
        }
        uint pendingUserMinimax = user.amount.mul(accMinimaxPerShare).div(SHARE_MULTIPLIER).sub(user.rewardDebt);
        return pendingUserMinimax;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.totalSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        // Minting reward
        uint multiplier = (block.number).sub(pool.lastRewardBlock);
        uint minimaxReward = multiplier.mul(minimaxPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accMinimaxPerShare = pool.accMinimaxPerShare.add(
            minimaxReward.mul(SHARE_MULTIPLIER).div(pool.totalSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit lp tokens for MINIMAX allocation.
    function deposit(uint _pid, uint _amount) external nonReentrant {
        require(_amount > 0, "deposit: amount is 0");
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            _claimPendingMintReward(_pid, msg.sender);
        }
        if (_amount > 0) {
            uint before = pool.token.balanceOf(address(this));
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint post = pool.token.balanceOf(address(this));
            uint finalAmount = post.sub(before);
            user.amount = user.amount.add(finalAmount);
            user.timeDeposited = block.timestamp;
            pool.totalSupply = pool.totalSupply.add(finalAmount);
            emit Deposit(msg.sender, _pid, finalAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accMinimaxPerShare).div(SHARE_MULTIPLIER);
    }

    // Withdraw LP tokens
    function withdraw(uint _pid, uint _amount) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: requested amount is high");
        require(block.timestamp >= user.timeDeposited.add(pool.timeLocked), "can't withdraw before end of lock-up");

        updatePool(_pid);
        _claimPendingMintReward(_pid, msg.sender);

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalSupply = pool.totalSupply.sub(_amount);
            pool.token.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accMinimaxPerShare).div(SHARE_MULTIPLIER);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][msg.sender];
        require(block.timestamp >= user.timeDeposited.add(pool.timeLocked), "time locked");

        uint amount = user.amount;

        pool.totalSupply = pool.totalSupply.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        pool.token.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint length = poolInfo.length;
        for (uint pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint _allocPoint,
        address _poolToken,
        uint _timeLocked
    ) external onlyOwner {
        massUpdatePools();
        uint lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                token: IBEP20(_poolToken),
                totalSupply: 0,
                allocPoint: _allocPoint,
                timeLocked: _timeLocked,
                lastRewardBlock: lastRewardBlock,
                accMinimaxPerShare: 0
            })
        );
        emit PoolAdded(_allocPoint, _timeLocked);
    }

    // Update the given pool's MINIMAX allocation point. Can only be called by the owner.
    function set(uint _pid, uint _allocPoint) external onlyOwner {
        massUpdatePools();
        uint prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }
        emit SetPool(_pid, _allocPoint);
    }

    function setMinimaxPerBlock(uint _minimaxPerBlock) external onlyOwner {
        minimaxPerBlock = _minimaxPerBlock;
        emit SetMinimaxPerBlock(_minimaxPerBlock);
    }

    function _claimPendingMintReward(uint _pid, address _user) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserPoolInfo storage user = userPoolInfo[_pid][_user];

        uint pendingMintReward = user.amount.mul(pool.accMinimaxPerShare).div(SHARE_MULTIPLIER).sub(user.rewardDebt);
        if (pendingMintReward > 0) {
            IMinimaxToken(minimaxToken).mint(_user, pendingMintReward);
        }
    }
}

// File: contracts/interfaces/IPriceOracle.sol

// 
pragma solidity ^0.8.0;

interface IPriceOracle {
    function latestAnswer() external view returns (int256);
}

// File: contracts/interfaces/IPancakeRouter.sol

// 
pragma solidity ^0.8.0;

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// File: contracts/interfaces/ISmartChefInitializable.sol

// 
pragma solidity ^0.8.0;

interface ISmartChefInitializable {
    // Deposit '_amount' of stakedToken tokens
    function deposit(uint256 _amount) external;

    // Withdraw '_amount' of stakedToken and all pending rewardToken tokens
    function withdraw(uint256 _amount) external;
}

contract SmartChefInitializable is ISmartChefInitializable {
    // The reward token
    IBEP20 public rewardToken;

    // The staked token
    IBEP20 public stakedToken;

    function deposit(uint256 _amount) external {}

    function withdraw(uint256 _amount) external {}
}

// File: contracts/ProxyCaller.sol

// 
pragma solidity ^0.8.0;

contract ProxyCaller {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function exec(address callee, bytes calldata data) external returns (bool success, bytes memory) {
        require(msg.sender == _owner, "O");
        return callee.call(data);
    }
}

// File: contracts/MinimaxMain.sol

// 
pragma solidity ^0.8.0;








/*
    MinimaxMain
*/
contract MinimaxMain is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address public cakeAddress; // 0x0E09FABB73BD3ADE0A17ECC321FD13A19E81CE82
    address public cakeOracleAddress; // 0xB6064ED41D4F67E353768AA239CA86F4F73665A1
    address public busdAddress; // 0xE9E7CEA3DEDCA5984780BAFC599BD69ADD087D56
    address public cakeRouterAddress; // 0x10ED43C718714EB63D5AA57B78B54704E256024E
    address public minimaxStaking;

    event PositionWasCreated(uint indexed positionIndex);
    event PositionWasModified(uint indexed positionIndex);
    event PositionWasClosed(uint indexed positionIndex);

    uint public constant FEE_MULTIPLIER = 1e8;
    uint public constant SLIPPAGE_MULTIPLIER = 1e8;
    // From chainlink price oracle (decimals)
    uint public constant PRICE_MULTIPLIER = 1e8;

    struct PositionInfo {
        uint stakedAmount;
        uint feeAmount;
        uint stopLossPrice;
        uint maxSlippage;
        address poolAddress;
        address owner;
        address rewardToken;
        address callerAddress;
        bool closed;
        uint takeProfitPrice;
    }

    uint lastPositionIndex;

    // Not an array for upgradability of PositionInfo struct
    mapping(uint => PositionInfo) public positions;
    mapping(address => bool) public isLiquidator;

    bytes4 private constant ENTER_STAKING_SELECTOR = bytes4(keccak256("enterStaking(uint256)"));
    bytes4 private constant LEAVE_STAKING_SELECTOR = bytes4(keccak256("leaveStaking(uint256)"));
    bytes4 private constant DEPOSIT_SELECTOR = bytes4(keccak256("deposit(uint256)"));
    bytes4 private constant WITHDRAW_SELECTOR = bytes4(keccak256("withdraw(uint256)"));
    bytes4 private constant APPROVE_SELECTOR = bytes4(keccak256("approve(address,uint256)"));

    address[] private availableCallers;

    // Fee threshold
    struct FeeThreshold {
        uint fee;
        uint stakedAmountThreshold;
    }

    FeeThreshold[] public depositFees;

    address masterChefAddress; // "0x73feaa1eE314F8c655E354234017bE2193C9E24E"

    mapping(address => bool) public smartChefPools;

    bytes4 private constant TRANSFER_SELECTOR = bytes4(keccak256("transfer(address,uint256)"));

    // Storage section ends!

    modifier onlyLiquidator() {
        require(isLiquidator[address(msg.sender)], "only one of liquidators can close positions");
        _;
    }

    using SafeBEP20 for IBEP20;
    using SafeMath for uint;

    function initialize(
        address _minimaxStaking,
        address _cakeAddress,
        address _cakeOracleAddress,
        address _busdAddress,
        address _cakeRouterAddress,
        address _masterChefAddress
    ) external initializer {
        minimaxStaking = _minimaxStaking;
        cakeAddress = _cakeAddress;
        cakeOracleAddress = _cakeOracleAddress;
        busdAddress = _busdAddress;
        cakeRouterAddress = _cakeRouterAddress;
        masterChefAddress = _masterChefAddress;

        __Ownable_init();
        __ReentrancyGuard_init();

        // staking pool
        depositFees.push(
            FeeThreshold({
                fee: 100000, // 0.1%
                stakedAmountThreshold: 1000 * 1e18 // all stakers <= 1000 MMX would have 0.1% fee for deposit
            })
        );

        depositFees.push(
            FeeThreshold({
                fee: 90000, // 0.09%
                stakedAmountThreshold: 5000 * 1e18
            })
        );

        depositFees.push(
            FeeThreshold({
                fee: 80000, // 0.08%
                stakedAmountThreshold: 10000 * 1e18
            })
        );

        depositFees.push(
            FeeThreshold({
                fee: 70000, // 0.07%
                stakedAmountThreshold: 50000 * 1e18
            })
        );
        depositFees.push(
            FeeThreshold({
                fee: 50000, // 0.05%
                stakedAmountThreshold: 10000000 * 1e18 // this level doesn't matter
            })
        );
    }

    // May run out of gas!
    function setSmartChefPools(address[] calldata pools, bool[] calldata allowances) external onlyOwner {
        for (uint i = 0; i < pools.length; i++) {
            smartChefPools[pools[i]] = allowances[i];
        }
    }

    function getSlippageMultiplier() public pure returns (uint) {
        return SLIPPAGE_MULTIPLIER;
    }

    function getPriceMultiplier() public pure returns (uint) {
        return PRICE_MULTIPLIER;
    }

    function getUserFee() public view returns (uint) {
        MinimaxStaking staking = MinimaxStaking(minimaxStaking);

        uint amountPool2 = staking.getUserAmount(2, msg.sender);
        uint amountPool3 = staking.getUserAmount(3, msg.sender);
        uint totalStakedAmount = amountPool2.add(amountPool3);

        uint length = depositFees.length;

        for (uint bucketId = 0; bucketId < length; ++bucketId) {
            uint threshold = depositFees[bucketId].stakedAmountThreshold;
            if (totalStakedAmount <= threshold) {
                return depositFees[bucketId].fee;
            }
        }
        return depositFees[length - 1].fee;
    }

    function getPositionInfo(uint positionIndex) external view returns (PositionInfo memory) {
        return positions[positionIndex];
    }

    // May run out of gas if 'amount' is big
    function addNewCallers(uint amount) external onlyOwner {
        for (uint i = 0; i < amount; i++) {
            ProxyCaller caller = new ProxyCaller();
            availableCallers.push(address(caller));
        }
    }

    function emergencyWithdrawCake(address to, uint cakeAmount) external onlyOwner {
        IBEP20(cakeAddress).safeTransfer(to, cakeAmount);
    }

    function setDepositFee(uint poolIdx, uint feeShare) external onlyOwner {
        require(poolIdx < depositFees.length, "wrong pool index");
        depositFees[poolIdx].fee = feeShare;
    }

    function setCakeOracleAddress(address oracleAddress) external onlyOwner {
        cakeOracleAddress = oracleAddress;
    }

    function setCakeRouterAddress(address routerAddress) external onlyOwner {
        cakeRouterAddress = routerAddress;
    }

    function setMinimaxStakingAddress(address stakingAddress) external onlyOwner {
        minimaxStaking = stakingAddress;
    }

    function setMasterChefAddress(address masterChefAddressVal) external onlyOwner {
        masterChefAddress = masterChefAddressVal;
    }

    function stakeCake(
        address poolAddress,
        uint256 cakeAmount,
        uint256 maxSlippage,
        uint256 stopLossPrice,
        uint256 takeProfitPrice
    ) external nonReentrant returns (uint) {
        emit PositionWasCreated(lastPositionIndex);

        require(stopLossPrice != 0, "stakeCake: stop-loss price is zero");
        require(takeProfitPrice != 0, "stakeCake: take-profit price is zero");

        bytes4 stakingSelector = DEPOSIT_SELECTOR;
        address rewardToken = cakeAddress;
        if (poolAddress == masterChefAddress) {
            stakingSelector = ENTER_STAKING_SELECTOR;
        } else {
            require(smartChefPools[poolAddress], "stakeCake: got not allowed pool");
            rewardToken = address(SmartChefInitializable(poolAddress).rewardToken());
        }

        address caller = getAvailableCaller();

        IBEP20(cakeAddress).safeTransferFrom(address(msg.sender), address(this), cakeAmount);

        uint userFeeShare = getUserFee();
        uint userFeeAmount = cakeAmount.mul(userFeeShare).div(FEE_MULTIPLIER);
        uint amountToStake = cakeAmount.sub(userFeeAmount);

        lastPositionIndex += 1;

        positions[lastPositionIndex - 1] = PositionInfo({
            stakedAmount: amountToStake,
            feeAmount: userFeeAmount,
            stopLossPrice: stopLossPrice,
            maxSlippage: maxSlippage,
            poolAddress: poolAddress,
            owner: address(msg.sender),
            rewardToken: rewardToken,
            callerAddress: caller,
            closed: false,
            takeProfitPrice: takeProfitPrice
        });

        stakeViaCaller(positions[lastPositionIndex - 1], amountToStake, stakingSelector);
        // No rewards to dump
        return lastPositionIndex - 1;
    }

    function deposit(uint positionIndex, uint amount) external nonReentrant {
        bytes4 stakingSelector = DEPOSIT_SELECTOR;
        if (positions[positionIndex].poolAddress == masterChefAddress) {
            stakingSelector = ENTER_STAKING_SELECTOR;
        }
        depositImpl(positionIndex, amount, stakingSelector);
    }

    function setLiquidator(address user, bool value) external onlyOwner {
        isLiquidator[user] = value;
    }

    function changeStopLossPrice(uint positionIndex, uint newStopLossPrice) external nonReentrant {
        emit PositionWasModified(positionIndex);
        PositionInfo storage position = positions[positionIndex];
        require(position.owner == address(msg.sender), "stop loss may be changed only by position owner");
        require(newStopLossPrice != 0, "changeStopLossPrice: new price is zero");
        position.stopLossPrice = newStopLossPrice;
    }

    function withdrawAll(uint positionIndex) external nonReentrant {
        PositionInfo storage position = positions[positionIndex];
        bytes4 withdrawSelector = WITHDRAW_SELECTOR;
        if (position.poolAddress == masterChefAddress) {
            withdrawSelector = LEAVE_STAKING_SELECTOR;
        }
        withdrawImpl(position, positionIndex, position.stakedAmount, withdrawSelector);
    }

    function alterPositionParams(
        uint positionIndex,
        uint newAmount,
        uint newStopLossPrice,
        uint newTakeProfitPrice,
        uint newSlippage
    ) external nonReentrant {
        PositionInfo storage position = positions[positionIndex];
        require(position.owner == address(msg.sender), "stop loss may be changed only by position owner");
        require(newStopLossPrice != 0, "changeStopLossPrice: new price is zero");
        require(newSlippage != 0, "slippage: new slippage is zero");

        bytes4 depositSelector = DEPOSIT_SELECTOR;
        bytes4 withdrawSelector = WITHDRAW_SELECTOR;
        if (position.poolAddress == masterChefAddress) {
            depositSelector = ENTER_STAKING_SELECTOR;
            withdrawSelector = LEAVE_STAKING_SELECTOR;
        }

        position.stopLossPrice = newStopLossPrice;
        position.takeProfitPrice = newTakeProfitPrice;
        position.maxSlippage = newSlippage;

        if (newAmount < position.stakedAmount) {
            uint withdrawAmount = position.stakedAmount.sub(newAmount);
            withdrawImpl(position, positionIndex, withdrawAmount, withdrawSelector);
        } else if (newAmount > position.stakedAmount) {
            uint depositAmount = newAmount.sub(position.stakedAmount);
            depositImpl(positionIndex, depositAmount, depositSelector);
        } else {
            emit PositionWasModified(positionIndex);
        }
    }

    function withdraw(uint positionIndex, uint amount) external nonReentrant {
        PositionInfo storage position = positions[positionIndex];
        bytes4 withdrawSelector = WITHDRAW_SELECTOR;
        if (position.poolAddress == masterChefAddress) {
            withdrawSelector = LEAVE_STAKING_SELECTOR;
        }
        withdrawImpl(position, positionIndex, amount, withdrawSelector);
    }

    function dumpRewards(PositionInfo storage position) private {
        uint rewardAmount = IBEP20(position.rewardToken).balanceOf(position.callerAddress);
        if (rewardAmount != 0) {
            transferTokensViaCaller(position, position.rewardToken, position.owner, rewardAmount);
        }
    }

    // Emits `PositionWasClosed` always.
    function liquidateByIndexImpl(uint positionIndex) private {
        emit PositionWasClosed(positionIndex);

        bytes4 withdrawSelector = WITHDRAW_SELECTOR;
        if (positions[positionIndex].poolAddress == masterChefAddress) {
            withdrawSelector = LEAVE_STAKING_SELECTOR;
        }

        PositionInfo storage position = positions[positionIndex];
        verifyPositionReadinessForLiquidation(positionIndex);
        withdrawViaCaller(position, position.stakedAmount, withdrawSelector);

        transferTokensViaCaller(position, cakeAddress, address(this), position.stakedAmount);
        // Firstly, 'transferTokensViaCaller', then 'dumpRewards': order is important here when (rewardToken == CAKE)
        dumpRewards(position);

        IPriceOracle cakePriceOracle = IPriceOracle(cakeOracleAddress);
        uint latestPrice = uint(cakePriceOracle.latestAnswer());
        finishLiquidationAfterUnstaking(positionIndex, latestPrice);
    }

    function liquidateByIndex(uint positionIndex) external nonReentrant onlyLiquidator {
        liquidateByIndexImpl(positionIndex);
    }

    // May run out of gas if array length is too big!
    function liquidateManyByIndex(uint[] calldata positionIndexes) external nonReentrant onlyLiquidator {
        for (uint i = 0; i < positionIndexes.length; ++i) {
            liquidateByIndexImpl(positionIndexes[i]);
        }
    }

    function returnCaller(address caller) private {
        availableCallers.push(caller);
    }

    function approveViaCaller(
        address caller,
        address callee,
        address user,
        uint allowance
    ) private {
        (bool success, bytes memory data) = ProxyCaller(caller).exec(
            callee,
            abi.encodeWithSelector(APPROVE_SELECTOR, user, allowance)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "approve via caller");
    }

    function getAvailableCaller() private returns (address) {
        if (availableCallers.length == 0) {
            ProxyCaller caller = new ProxyCaller();
            return address(caller);
        }
        address res = availableCallers[availableCallers.length - 1];
        availableCallers.pop();
        return res;
    }

    function stakeViaCaller(
        PositionInfo storage position,
        uint amount,
        bytes4 poolSelector
    ) private {
        IBEP20(cakeAddress).safeTransfer(position.callerAddress, amount);
        approveViaCaller(position.callerAddress, cakeAddress, position.poolAddress, amount);
        (bool success, bytes memory data) = ProxyCaller(position.callerAddress).exec(
            position.poolAddress,
            abi.encodeWithSelector(poolSelector, amount)
        );
        require(success && (data.length == 0), "stake via caller");
    }

    // Emits `PositionsWasModified` always.
    function depositImpl(
        uint positionIndex,
        uint amount,
        bytes4 depositSelector
    ) private {
        emit PositionWasModified(positionIndex);

        PositionInfo storage position = positions[positionIndex];
        require(position.owner == address(msg.sender), "deposit: only position owner allowed");
        require(position.closed == false, "deposit: position is closed");

        IBEP20(cakeAddress).safeTransferFrom(address(msg.sender), address(this), amount);

        uint userFeeShare = getUserFee();
        uint userFeeAmount = amount.mul(userFeeShare).div(FEE_MULTIPLIER);
        uint amountToDeposit = amount.sub(userFeeAmount);

        position.stakedAmount = (position.stakedAmount).add(amountToDeposit);
        position.feeAmount = (position.feeAmount).add(userFeeAmount);

        stakeViaCaller(position, amountToDeposit, depositSelector);
        dumpRewards(position);
    }

    function transferTokensViaCaller(
        PositionInfo storage position,
        address token,
        address to,
        uint amount
    ) private {
        (bool success, ) = ProxyCaller(position.callerAddress).exec(
            token,
            abi.encodeWithSelector(TRANSFER_SELECTOR, to, amount)
        );
        require(success, "transferTokensViaCaller: send token to owner");
    }

    function withdrawViaCaller(
        PositionInfo storage position,
        uint amount,
        bytes4 withdrawSelector
    ) private {
        (bool success, bytes memory data) = ProxyCaller(position.callerAddress).exec(
            position.poolAddress,
            abi.encodeWithSelector(withdrawSelector, amount)
        );
        require(success && (data.length == 0), "withdrawViaCaller: unstaking");
    }

    // Emits:
    //   * `PositionWasClosed`,   if `amount == position.stakedAmount`.
    //   * `PositionWasModified`, otherwise.
    function withdrawImpl(
        PositionInfo storage position,
        uint positionIndex,
        uint amount,
        bytes4 withdrawSelector
    ) private {
        require(position.owner == address(msg.sender), "withdraw: only position owner allowed");
        require(position.closed == false, "withdraw: position is closed");
        require(amount <= position.stakedAmount, "withdraw: withdraw amount exceeds staked amount");
        withdrawViaCaller(position, amount, withdrawSelector);
        transferTokensViaCaller(position, cakeAddress, position.owner, amount);
        dumpRewards(position);

        if (amount == position.stakedAmount) {
            emit PositionWasClosed(positionIndex);
            position.closed = true;
            returnCaller(position.callerAddress);
        } else {
            emit PositionWasModified(positionIndex);
            position.stakedAmount = (position.stakedAmount).sub(amount);
        }
    }

    function verifyPositionReadinessForLiquidation(uint positionIndex) private view returns (uint) {
        PositionInfo storage position = positions[positionIndex];
        require(position.closed == false, "isPositionReadyForLiquidation: position is closed");
        require(position.owner != address(0), "position is not created");

        IPriceOracle cakePriceOracle = IPriceOracle(cakeOracleAddress);
        uint latestPrice = uint(cakePriceOracle.latestAnswer());
        require(
            (latestPrice < position.stopLossPrice) || (latestPrice > position.takeProfitPrice),
            "isPositionReadyForLiquidation: incorrect price level"
        );

        return latestPrice;
    }

    function finishLiquidationAfterUnstaking(uint positionIndex, uint latestPrice) private {
        PositionInfo storage position = positions[positionIndex];

        IPancakeRouter dexRouter = IPancakeRouter(cakeRouterAddress);

        // Optimistic conversion BUSD amount
        uint minAmountOut = position.stakedAmount.mul(latestPrice).div(PRICE_MULTIPLIER);
        // Accounting slippage
        minAmountOut = minAmountOut.sub(minAmountOut.mul(position.maxSlippage).div(SLIPPAGE_MULTIPLIER));

        address[] memory path = new address[](2);
        path[0] = cakeAddress;
        path[1] = busdAddress;

        IBEP20(cakeAddress).safeIncreaseAllowance(address(cakeRouterAddress), position.stakedAmount);

        dexRouter.swapExactTokensForTokens(
            position.stakedAmount,
            minAmountOut,
            path, /* path */
            position.owner, /* to */
            block.timestamp /* deadline */
        );

        // Transfer fee to liquidator address
        IBEP20(cakeAddress).safeTransfer(msg.sender, position.feeAmount);

        position.closed = true;
        returnCaller(position.callerAddress);
    }
}