/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts-upgradeable/utils/[email protected]
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]
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
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/token/ERC20/utils/[email protected]
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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/[email protected]
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/utils/math/[email protected]
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
library SafeMathUpgradeable {
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


// File contracts/RissottoPreSale.sol
pragma solidity ^0.8.17;
interface AggregatorInterface {
  function latestAnswer()
    external
    view
    returns (
      int256
    );
  
  function latestTimestamp()
    external
    view
    returns (
      uint256
    );

  function latestRound()
    external
    view
    returns (
      uint256
    );

  function getAnswer(
    uint256 roundId
  )
    external
    view
    returns (
      int256
    );

  function getTimestamp(
    uint256 roundId
  )
    external
    view
    returns (
      uint256
    );

  event AnswerUpdated(
    int256 indexed current,
    uint256 indexed roundId,
    uint256 updatedAt
  );

  event NewRound(
    uint256 indexed roundId,
    address indexed startedBy,
    uint256 startedAt
  );
}

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{
}

interface IPreIDOEvents {
  /// @notice Emitted when tokens is locked in the pre-IDO contract
  /// @param sender The sender address whose the locked tokens belong
  /// @param id The order ID used to tracking order information
  /// @param amount The amount of tokens to be locked
  /// @param lockOnBlock The block timestamp when tokens locked inside the pre-IDO
  /// @param releaseOnBlock The block timestamp when tokens can be redeem or claimed from the time-locked contract
  event LockTokens(address indexed sender, uint256 indexed id, uint256 amount, uint256 lockOnBlock, uint256 releaseOnBlock);   

  /// @notice Emitted when tokens is unlocked or claimed by `receiver` from the time-locked contract
  /// @param receiver The receiver address where the tokens to be distributed to
  /// @param id The order ID used to tracking order information
  /// @param amount The amount of tokens has been distributed
  event UnlockTokens(address indexed receiver, uint256 indexed id, uint256 amount);
}


interface IPreIDOImmutables {
  /// @notice The token contract that used to distribute to investors when those tokens is unlocked
  /// @return The token contract
  function token() external view returns(IERC20MetadataUpgradeable);
}

interface IPreIDOState {
  /// @notice Look up information about a specific order in the pre-IDO contract
  /// @param id The order ID to look up
  /// @return beneficiary The investor address whose `amount` of tokens in this order belong to,
  /// amount The amount of tokens has been locked in this order,
  /// releaseOnBlock The block timestamp when tokens can be redeem or claimed from the time-locked contract,
  /// claimed The status of this order whether it's claimed or not.
  function orders(uint256 id) external view returns(
    address beneficiary,
    uint256 amount,
    uint256 releaseOnBlock,
    bool claimed
  );

  /// @notice Look up all order IDs that a specific `investor` address has been order in the pre-IDO contract
  /// @param investor The investor address to look up
  /// @return ids All order IDs that the `investor` has been order
  function investorOrderIds(address investor) external view returns(uint256[] memory ids);

  /// @notice Look up locked-balance of a specific `investor` address in the pre-IDO contract
  /// @param investor The investor address to look up
  /// @return balance The locked-balance of the `investor`
  function balanceOf(address investor) external view returns(uint256 balance);
}

interface IPreIDOBase is IPreIDOImmutables, IPreIDOState, IPreIDOEvents {

}

contract RissottoPresale is IPreIDOBase, Initializable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IERC20MetadataUpgradeable;
    using AddressUpgradeable for address;

    struct TokenInfo {
        address priceFeed;
        int256 rate;
        uint8 decimals;
        uint256 raisedAmount; // how many tokens has been raised so far
    }
    struct OrderInfo {
        address beneficiary;
        uint256 amount;
        uint256 releaseOnBlock;
        bool claimed;
    }

    uint256 public MIN_LOCK; // 1 month;
    /// @dev discountsLock[rate] = durationInSeconds
    mapping(uint8 => uint256) public discountsLock;
    /// @dev supportedTokens[tokenAddress] = TokenInfo
    mapping(address => TokenInfo) public supportedTokens;
    /// @dev balanceOf[investor] = balance
    mapping(address => uint256) public override balanceOf;
    /// @dev orderIds[investor] = array of order ids
    mapping(address => uint256[]) private orderIds;
    /// @dev orders[orderId] = OrderInfo
    mapping(uint256 => OrderInfo) public override orders;
    /// @dev The latest order id for tracking order info
    uint256 private latestOrderId;
    /// @notice The total amount of tokens had been distributed
    uint256 public totalDistributed;
    /// @notice The minimum investment funds for purchasing tokens in USD
    uint256 public minInvestment;
    /// @notice The token used for pre-sale
    IERC20MetadataUpgradeable public override token;
    /// @dev The price feed address of native token
    AggregatorV2V3Interface internal priceFeed;
    /// @notice The block timestamp before starting the presale purchasing
    uint256 public notBeforeBlock;
    /// @notice The block timestamp after ending the presale purchasing
    uint256 public notAfterBlock;

    uint256 public tokenSalePrice;
    
    uint256 private raisedAmounts;

    function initialize (
        address _token,
        address _priceFeed,
        uint256 _notBeforeBlock,
        uint256 _notAfterBlock
    ) public initializer{
        require(
            _token != address(0) && _priceFeed != address(0),
            "invalid contract address"
        ); // ICA
        require(
                _notAfterBlock > _notBeforeBlock,
            "invalid presale schedule"
        ); // IPS

        __Ownable_init();
        token = IERC20MetadataUpgradeable(_token);
        priceFeed = AggregatorV2V3Interface(_priceFeed);
        notBeforeBlock = _notBeforeBlock;
        notAfterBlock = _notAfterBlock;

        // initialize discounts rate lock duration
        MIN_LOCK = 90 days; // 3 months;

        discountsLock[10] = MIN_LOCK;
        discountsLock[20] = 2 * MIN_LOCK;
        discountsLock[30] = 3 * MIN_LOCK;

        minInvestment = 50;
        latestOrderId = 0;
        tokenSalePrice = 5000000000000000000;
    }

    receive() external payable inPresalePeriod {
        int256 price = getPrice();
        _order(msg.value, 18, price, priceFeed.decimals(), 10); // default to 10% discount rate
    }


    function setMinLockPeriod(uint256 _seconds) public onlyOwner{
        require(
                _seconds > 0,
            "time must be greater than zero"
        ); // IPS
        MIN_LOCK = _seconds;
    }


    function setTokenPrice(uint256 _pricesale) public onlyOwner{
        require(
                _pricesale > 0,
            "price must be greater than zero"
        ); // IPS
        tokenSalePrice = _pricesale;
    }


    function setTokenAddress(address _token) public onlyOwner{
        require(
                _token != address(0),
            "zero address not valid"
        ); // IPS
        token = IERC20MetadataUpgradeable(_token);
    }


    function setSaleTime(uint256 _starttime , uint256 _endtime) public onlyOwner{
        require(
                _endtime > _starttime,
            "invalid presale schedule"
        ); // IPS
        notBeforeBlock = _starttime;
        notAfterBlock = _endtime;
    }

    function investorOrderIds(address investor)
        external
        view
        override
        returns (uint256[] memory ids)
    {
        uint256[] memory arr = orderIds[investor];
        return arr;
    }

    function order(uint8 discountsRate) external payable inPresalePeriod {
        int256 price = getPrice();
        _order(msg.value, 18, price, priceFeed.decimals(), discountsRate);
    }

    function countGetToken(address _tokenAddress ,uint256 _amount , uint8 _discountsRate  ) public view returns(uint256){
        require(_tokenAddress != address(0) , "Invalid Fund Address");
        require(_amount > 0 , "Invalid Amount Enter");
        uint8 _priceDecimals =  priceFeed.decimals();
        uint8 _amountDecimals = 18;
        int256 price = getPrice();
        if(_tokenAddress != address(0)){
            TokenInfo storage tokenInfo = supportedTokens[_tokenAddress];
            require(
            tokenInfo.priceFeed != address(0),
            "purchasing of tokens was not supported"
        ); // TNS
           _priceDecimals = IERC20MetadataUpgradeable(_tokenAddress).decimals();
           _amountDecimals = tokenInfo.decimals;
           price = getPriceToken(_tokenAddress);
        }
        
        uint256 tokenPriceX4 = (tokenSalePrice.div(10**14) * (100 - _discountsRate)) / 100; // 300 = 0.03(default price) * 10^4
        uint256 distributeAmount = _amount.mul(uint256(price)).div(tokenPriceX4);
        uint8 upperPow = token.decimals() + 4; // 4(token price decimals) => 10^4 = 22
        uint8 lowerPow = _amountDecimals + _priceDecimals;
        if (upperPow >= lowerPow) {
            distributeAmount = distributeAmount.mul(10**(upperPow - lowerPow));
        } else {
            distributeAmount = distributeAmount.div(10**(lowerPow - upperPow));
        }

        return distributeAmount;
    }

    function orderToken(
        address fundsAddress,
        uint256 fundsAmount,
        uint8 discountsRate
    ) external inPresalePeriod {
        TokenInfo storage tokenInfo = supportedTokens[fundsAddress];
        require(fundsAmount > 0, "invalid token amount value"); // ITA
        require(
            tokenInfo.priceFeed != address(0),
            "purchasing of tokens was not supported"
        ); // TNS

        tokenInfo.rate = getPriceToken(fundsAddress);
        IERC20Upgradeable(fundsAddress).safeTransferFrom(
            msg.sender,
            address(this),
            fundsAmount
        );
        tokenInfo.raisedAmount = tokenInfo.raisedAmount.add(fundsAmount);
        _order(
            fundsAmount,
            IERC20MetadataUpgradeable(fundsAddress).decimals(),
            tokenInfo.rate,
            tokenInfo.decimals,
            discountsRate
        );
    }

    function _order(
        uint256 amount,
        uint8 _amountDecimals,
        int256 price,
        uint8 _priceDecimals,
        uint8 discountsRate
    ) internal {
        require(
            amount.mul(uint256(price)).div(
                10**(_amountDecimals + _priceDecimals)
            ) >= minInvestment,
            "the investment amount does not reach the minimum amount required"
        ); // LMI

        uint256 amountValue = amount.mul(uint256(price)).div(10**(_amountDecimals + _priceDecimals));
        raisedAmounts = raisedAmounts.add(amountValue);

        uint256 lockDuration = discountsLock[discountsRate];
        require(
            lockDuration >= MIN_LOCK,
            "the lock duration does not reach the minimum duration required"
        ); // NDR

        uint256 releaseOnBlock = notAfterBlock + lockDuration;
        uint256 tokenPriceX4 = (tokenSalePrice.div(10**14) * (100 - discountsRate)) / 100;
        uint256 distributeAmount = amount.mul(uint256(price)).div(tokenPriceX4);
        uint8 upperPow = token.decimals() + 4; // 4(token price decimals) => 10^4 = 22
        uint8 lowerPow = _amountDecimals + _priceDecimals;
        if (upperPow >= lowerPow) {
            distributeAmount = distributeAmount.mul(10**(upperPow - lowerPow));
        } else {
            distributeAmount = distributeAmount.div(10**(lowerPow - upperPow));
        }
        require(
            totalDistributed + distributeAmount <=
                token.balanceOf(address(this)),
            "there is not enough supply token to be distributed"
        ); // NET

        orders[++latestOrderId] = OrderInfo(
            msg.sender,
            distributeAmount,
            releaseOnBlock,
            false
        );
        totalDistributed = totalDistributed.add(distributeAmount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(distributeAmount);
        orderIds[msg.sender].push(latestOrderId);

        emit LockTokens(
            msg.sender,
            latestOrderId,
            distributeAmount,
            block.timestamp,
            releaseOnBlock
        );
    }

    function redeem(uint256 orderId) external {
        require(orderId <= latestOrderId, "the order ID is incorrect"); // IOI

        OrderInfo storage orderInfo = orders[orderId];
        require(msg.sender == orderInfo.beneficiary, "not order beneficiary"); // NOO
        require(orderInfo.amount > 0, "insufficient redeemable tokens"); // ITA
        require(
            block.timestamp >= orderInfo.releaseOnBlock,
            "tokens are being locked"
        ); // TIL
        require(!orderInfo.claimed, "tokens are ready to be claimed"); // TAC

        uint256 amount = safeTransferToken(
            orderInfo.beneficiary,
            orderInfo.amount
        );
        orderInfo.claimed = true;
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);

        emit UnlockTokens(orderInfo.beneficiary, orderId, amount);
    }

    function getPrice() public view returns (int256 price) {
        price = priceFeed.latestAnswer();
    }

    function getPriceToken(address fundAddress)
        public
        view
        returns (int256 price)
    {
        price = AggregatorV2V3Interface(supportedTokens[fundAddress].priceFeed)
            .latestAnswer();
    }

    function remainingTokens()
        public
        view
        inPresalePeriod
        returns (uint256 remainingToken)
    {
        remainingToken = token.balanceOf(address(this)) - totalDistributed;
    }

    function getRaisedFunds()
        external
        view
        returns (uint256 raisedFunds)   
    {
        raisedFunds = raisedAmounts.mul(1000);
    }

    function collectFunds(address fundsAddress)
        external
        onlyOwner
        afterPresalePeriod
    {
        uint256 amount = IERC20Upgradeable(fundsAddress).balanceOf(address(this));
        require(amount > 0, "insufficient funds for collection"); // NEC
        IERC20Upgradeable(fundsAddress).transfer(owner(), amount);
    }

    function collect() external onlyOwner afterPresalePeriod {
        uint256 amount = address(this).balance;
        require(amount > 0, "insufficient funds for collection"); // NEC
        payable(owner()).transfer(amount);
    }

    function setMinInvestment(uint256 _minInvestment)
        external
        onlyOwner
        beforePresaleEnd
    {
        require(_minInvestment > 0, "Invalid input value"); // IIV
        minInvestment = _minInvestment;
    }

    function setSupportedToken(address _token, address _priceFeed)
        external
        onlyOwner
        beforePresaleEnd
    {
        require(_token != address(0), "invalid token address"); // ITA
        require(_priceFeed != address(0), "invalid oracle price feed address"); // IOPA

        supportedTokens[_token].priceFeed = _priceFeed;
        supportedTokens[_token].decimals = AggregatorV2V3Interface(_priceFeed)
            .decimals();
        supportedTokens[_token].rate = AggregatorV2V3Interface(_priceFeed)
            .latestAnswer();
    }

    function safeTransferToken(address _to, uint256 _amount)
        internal
        returns (uint256 amount)
    {
        uint256 bal = token.balanceOf(address(this));
        if (bal < _amount) {
            token.safeTransfer(_to, bal);
            amount = bal;
        } else {
            token.safeTransfer(_to, _amount);
            amount = _amount;
        }
    }

    modifier inPresalePeriod() {
        require(
            block.timestamp > notBeforeBlock,
            "Pre-sale has not been started "
        ); // PNS
        require(block.timestamp < notAfterBlock, "Pre-sale has already ended "); // PEN
        _;
    }

    modifier afterPresalePeriod() {
        require(block.timestamp > notAfterBlock, "Pre-sale is still ongoing"); // PNE
        _;
    }

    modifier beforePresaleEnd() {
        require(block.timestamp < notAfterBlock, "Pre-sale has already ended"); // PEN
        _;
    }
}