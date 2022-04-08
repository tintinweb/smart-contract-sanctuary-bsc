/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


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


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: contracts/AM2X/am2x.sol

//SPDX-License-Identifier: MIT









pragma solidity ^0.8.0;

interface PoolV1 {
    struct Deposit {
        address account;
        uint amount;
        uint payout;
        uint allocated;
        uint bonus;
        bool paid;
        uint checkpoint;
    }

    struct User {
        address referer;
        address account;
        uint[] deposits;
        uint totalDeposit;
        uint totalWithdrawn;
        bool disableDeposit;
        uint totalBonus;
        uint directBonus;
        uint lvl6Bonus;
    }

    function deposits(uint) external returns (Deposit memory);

    function contractInfo() external view returns (uint, uint, uint, uint, uint, uint, uint, uint);

    function userids(address) external returns (uint);
}

contract AM2X is Initializable {
    using SafeERC20 for IERC20;

    struct Deposit {
        uint index;
        uint checkpoint;
    }

    struct User {
        address referer;
        address account;
        Deposit[] deposits;
        uint[] partners;
        uint totalDeposit;
        uint totalWithdrawn;
        uint totalBonus;
        uint directBonus;
        uint lvl6Bonus;
        uint checkpoint;
    }

    struct Level {
        uint level;
        uint lvl0; // partner
        uint lvl1;
        uint lvl2;
        uint lvl3;
        uint lvl4;
        uint lvl5;
        uint team; // total Team count
    }

    constructor ()  {
       _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    // Royalty
    address public _owner;
    IERC20 public token;
    uint public price;
    uint public maxUnits;  
    uint public minUnits;
    uint public commissionFeeRate;
    uint public levelStep;
    uint[] public referRate;
    uint public lvl6Rate;
    uint public marketingFee;
    address public marketingWallet;
    address public firstWallet;
    bool public enabled;
    bool public shareLevel6;
    bool public fixedCommit;
    bool public contributeEnabled;
    uint public contributeRate;

    uint public totalDeposit;
    uint public depositCount;
    uint public totalBonus;
    uint public totalWithdrawn;
    uint public totalCommission;
    uint public totalUsers;

    address[] public lvl6;
    
    uint commitLeft;
    PoolV1 public poolv1 = PoolV1(0x9457dB7Be9d6A6EC1f8bFBFcDF8Ca756daD5c704);
    
    uint public contributeIndex;
    uint public maxContributeIndex;
    uint public totalContribute;
    mapping(uint => uint) public contributeAmounts;
    mapping(address => uint) public userContributed;

    mapping(address => uint) public userids;
    mapping(uint => User) public users;
    mapping(uint => Level) public levels;
    mapping(uint => address) public depositIndexToAccount;

    event UserMsg(uint userid, string msg, uint value);
    event Commission(uint value);
    event Contribute(uint userv1id, address indexed account, uint value);

    /*constructor(IERC20 _token, uint _price) {
        token = _token;
        price = _price;
    }*/

    function initialize(
        address _contractOwner,
        IERC20 _token,
        uint _price,
        uint _maxUnits,  
        uint _minUnits,
        uint _commissionFeeRate,
        uint _levelStep,
        //uint[] memory _referRate,
        uint _lvl6Rate,
        uint _marketingFee,
        //address _marketingWallet,
        address _firstWallet,
        bool _enabled,
        bool _shareLevel6
        //bool _fixedCommit,
        //bool _contributeEnabled,
        //uint _contributeRate

    ) public initializer {
       
        _owner = _contractOwner;
        token = _token;
        price = _price;
        maxUnits = _maxUnits;
        minUnits = _minUnits;
        commissionFeeRate = _commissionFeeRate;
        levelStep = _levelStep;
        //referRate = _referRate;
        lvl6Rate = _lvl6Rate;
        marketingFee = _marketingFee;
        //marketingWallet = _marketingWallet;
        firstWallet = _firstWallet;
        enabled = _enabled;
        shareLevel6 = _shareLevel6;
        //fixedCommit = _fixedCommit;
        //contributeEnabled = _contributeEnabled;
        //contributeRate = _contributeRate;
        
    }

    receive() external payable {}

    function invest(address referer, uint units) external {
        if (msg.sender == firstWallet) {
            if (enabled != true) {
                enabled = true;
            }
        }
        require(enabled, "Pool Not Enabled");
        require(units >= minUnits, "Less than Min Units");
        require(units <= maxUnits, "Over than Max Units");

        uint userid = userids[msg.sender];
        if (userid == 0) {
            totalUsers += 1;
            userid = totalUsers;
            userids[msg.sender] = userid;
            emit UserMsg(userid, "Joined", 0);
        }

        User storage user = users[userid];
        if (user.account == address(0)) {
            user.account = msg.sender;
            user.checkpoint = block.timestamp;
        }

        if (user.referer == address(0) && referer != address(0)) {
            if (users[userids[referer]].totalDeposit > 0 && referer != msg.sender && user.totalDeposit == 0) {
                user.referer = referer;
                users[userids[referer]].partners.push(userid);
                processLevelUpdate(referer, msg.sender);

                address parent = referer;
                for (uint i = 0; i < 5; i++) {
                    if (parent == address(0)) break;
                    levels[userids[parent]].team += 1;
                    parent = users[userids[parent]].referer;
                }
            }
        }

        processDeposit(units);

        //        payReferral(user.referer, units);

        
    }

    function payForCommission(address referer, uint value) private returns (uint){
        address upline = referer;
        uint commission = value * getCommissionRate() / 1000;

        uint totalRefOut;
        for (uint i = 0; i < referRate.length; i++) {
            uint uplineId = userids[upline];
            if (uplineId == 0) break;
            if (upline != address(0) && levels[uplineId].level > i) {
                if (users[uplineId].totalDeposit > users[uplineId].totalWithdrawn) {
                    uint bonus = value * referRate[i] / 1000;
                    totalRefOut = totalRefOut + bonus;
                    token.safeTransfer(upline, bonus);
                    //                    emit PayBonus(upline, bonus);
                    emit UserMsg(uplineId, "RefBonus", bonus);
                    users[uplineId].totalBonus += bonus;
                    if (i == 0) {
                        users[uplineId].directBonus += bonus;
                    }
                }
                upline = users[uplineId].referer;
            } else break;
        }

        if (shareLevel6 == true) {
            for (uint i = 0; i < lvl6.length; i++) {
                uint bonus = value * lvl6Rate / 1000 / lvl6.length;
                totalRefOut += bonus;
                token.safeTransfer(lvl6[i], bonus / lvl6.length);
                //            emit PayBonus(lvl6[i], bonus);
                emit UserMsg(userids[lvl6[i]], "LvL6Bonus", bonus);
                users[userids[lvl6[i]]].totalBonus += bonus;
                users[userids[lvl6[i]]].lvl6Bonus += bonus;
            }
        }

        uint contributeOut;
        if (contributeEnabled) {
            require(contributeIndex > 0, "Contribute Index Not Set");
            PoolV1.Deposit memory dp = poolv1.deposits(contributeIndex);
            if (dp.amount > dp.allocated + contributeAmounts[contributeIndex]) {
                uint contributeAmount = value * contributeRate / 1000;
                uint needpay = dp.amount - dp.allocated - contributeAmounts[contributeIndex];

                if (needpay > contributeAmount) {
                    contributeOut = contributeAmount;
                    contributeAmounts[contributeIndex] += contributeOut;
                } else {
                    contributeOut = needpay;
                    contributeAmounts[contributeIndex] += contributeOut;
                    contributeIndex += 1;
                }
                userContributed[dp.account] += contributeOut;
                //                poolv1.userids(dp.account)
                token.safeTransfer(dp.account, contributeOut);
                totalContribute += contributeOut;
                emit Contribute(poolv1.userids(dp.account), dp.account, contributeOut);
            } else {
                contributeIndex += 1;
            }
            if (contributeIndex >= maxContributeIndex) {
                contributeEnabled = false;
            }
        }

        totalBonus += totalRefOut;
        uint marketingOut = commission - contributeOut - totalRefOut;
        token.safeTransfer(marketingWallet, marketingOut);

        emit Commission(commission);
        return commission;
    }

    function getCommissionRate() public view returns (uint) {
        if (contributeEnabled) {
            return commissionFeeRate + contributeRate;
        } else {
            return commissionFeeRate;
        }
    }

    function payReferral(address referer, uint units) private {
        // pay to referral
        uint value = price * units;
        uint commission = value * commissionFeeRate / 1000;
        uint totalRefOut;

        address upline = referer;

        for (uint i = 0; i < referRate.length; i++) {
            uint uplineId = userids[upline];
            if (uplineId == 0) break;
            if (upline != address(0) && levels[uplineId].level > i) {
                uint bonus = value * referRate[i] / 1000;
                totalRefOut = totalRefOut + bonus;
                token.safeTransfer(upline, bonus);
                //                    emit PayBonus(upline, bonus);
                emit UserMsg(uplineId, "RefBonus", bonus);
                users[uplineId].totalBonus += bonus;
                if (i == 0) {
                    users[uplineId].directBonus += bonus;
                }
                upline = users[uplineId].referer;
            } else break;
        }

        for (uint i = 0; i < lvl6.length; i++) {
            uint bonus = value * lvl6Rate / 1000 / lvl6.length;
            totalRefOut += bonus;
            token.safeTransfer(lvl6[i], bonus / lvl6.length);
            //            emit PayBonus(lvl6[i], bonus);
            emit UserMsg(userids[lvl6[i]], "LvL6Bonus", bonus);
            users[userids[lvl6[i]]].totalBonus += bonus;
            users[userids[lvl6[i]]].lvl6Bonus += bonus;
        }

        uint contributeOut;
        if (contributeEnabled) {
            require(contributeIndex > 0, "Contribute Index Not Set");
            PoolV1.Deposit memory dp = poolv1.deposits(contributeIndex);
            if (dp.amount > dp.allocated + contributeAmounts[contributeIndex]) {
                uint contributeAmount = value * contributeRate / 1000;
                uint needpay = dp.amount - dp.allocated - contributeAmounts[contributeIndex];

                if (needpay > contributeAmount) {
                    contributeOut = contributeAmount;
                    contributeAmounts[contributeIndex] += contributeOut;
                } else {
                    contributeOut = needpay;
                    contributeAmounts[contributeIndex] += contributeOut;
                    contributeIndex += 1;
                }
                userContributed[dp.account] += contributeOut;
                //                poolv1.userids(dp.account)
                token.safeTransfer(dp.account, contributeOut);
                totalContribute += contributeOut;
                emit Contribute(poolv1.userids(dp.account), dp.account, contributeOut);
            } else {
                contributeIndex += 1;
            }
            if (contributeIndex >= maxContributeIndex) {
                contributeEnabled = false;
            }
        }
        uint commi = commission - totalRefOut - contributeOut;
        token.safeTransfer(marketingWallet, commi);
        emit Commission(commi);
        totalBonus += totalRefOut;
        totalCommission += commission;
    }

    function processLevelUpdate(address referer, address from) private {
        if (referer == address(0)) return;
        uint refererid = userids[referer];
        if (refererid == 0) return;
        uint fromid = userids[from];

        User storage user = users[refererid];
        Level storage level = levels[refererid];

        if (levels[fromid].level == 0) {
            level.lvl0++;
            if (level.lvl0 >= levelStep && level.level < 1) {
                level.level = 1;
                emit UserMsg(refererid, "LevelUp", 1);
                processLevelUpdate(user.referer, referer);
            }
        } else if (levels[fromid].level == 1) {
            level.lvl1++;
            if (level.lvl1 >= levelStep && level.level < 2) {
                level.level = 2;
                emit UserMsg(userids[referer], "LevelUp", 2);
                processLevelUpdate(user.referer, referer);
            }
        } else if (levels[fromid].level == 2) {
            level.lvl2++;
            if (level.lvl2 >= levelStep && level.level < 3) {
                level.level = 3;
                emit UserMsg(userids[referer], "LevelUp", 3);
                processLevelUpdate(user.referer, referer);
            }
        } else if (levels[fromid].level == 3) {
            level.lvl3++;
            if (level.lvl3 >= levelStep && level.level < 4) {
                level.level = 4;
                emit UserMsg(userids[referer], "LevelUp", 4);
                processLevelUpdate(user.referer, referer);
            }
        } else if (levels[fromid].level == 4) {
            level.lvl4++;
            if (level.lvl4 >= levelStep && level.level < 5) {
                level.level = 5;
                emit UserMsg(userids[referer], "LevelUp", 5);
                processLevelUpdate(user.referer, referer);
            }
        } else if (levels[fromid].level == 5) {
            level.lvl5++;
            if (level.lvl5 >= levelStep && level.level < 6) {
                emit UserMsg(userids[referer], "LevelUp", 6);
                level.level = 6;
                lvl6.push(referer);
            }
        }
    }

    function processDeposit(uint units) private returns (uint value) {
        uint userid = userids[msg.sender];
        User storage user = users[userid];
        require(userAllocated(msg.sender) >= user.totalDeposit, "Less Allocated");

        value = units * price;
        token.safeTransferFrom(msg.sender, address(this), value);
        totalDeposit += value;

        emit UserMsg(userid, "Deposit", value);

        for (uint i = 0; i < units; i++) {
            Deposit memory deposit = Deposit(depositCount + i, block.timestamp);
            user.deposits.push(deposit);
            depositIndexToAccount[depositCount + i] = msg.sender;
            // push deposit nature index
        }
        depositCount += units;
        user.totalDeposit += value;
    }

    function claim() external {
        uint userid = userids[msg.sender];
        User storage user = users[userid];
        uint allocated = userAllocated(msg.sender);
        require(allocated > user.totalWithdrawn, "No more allocated");
        uint topay = allocated - user.totalWithdrawn;
        user.totalWithdrawn += topay;
        totalWithdrawn += topay;
        emit UserMsg(userid, "Claim", topay);
        uint commission = payForCommission(user.referer, topay);
        totalCommission += commission;
        token.safeTransfer(msg.sender, topay - commission);
    }

    function userAllocated(address account) public view returns (uint) {
        if (depositCount < 1) return 0;
        uint userid = userids[account];
        User storage user = users[userid];
        uint weight;
        for (uint i = 0; i < user.deposits.length; i += 1) {
            weight += (depositCount - user.deposits[i].index);
        }
        return totalDeposit * weight * 2 / totalWeight();
    }

    function userPercent(address account) public view returns (uint) {
        return userWeight(account) * depositCount * 200 / totalWeight();
    }

    function userWeight(address account) public view returns (uint) {
        uint userid = userids[account];
        User storage user = users[userid];
        uint weight;
        for (uint i = 0; i < user.deposits.length; i += 1) {
            weight += (depositCount - user.deposits[i].index);
        }
        return weight * 2;
    }

    function totalWeight() public view returns (uint) {
        return depositCount * 2 * (depositCount * 2 + 1) / 2;
    }

    function userInfoById(uint id) public view returns (uint, uint, User memory, Level memory) {
        User storage user = users[id];
        Level storage level = levels[id];
        return (id, userids[user.referer], user, level);
    }

    function userInfoByAddress(address account) public view returns (uint, uint, User memory, Level memory) {
        uint userid = userids[account];
        return userInfoById(userid);
    }

    function partnerIdsById(uint id) public view returns (uint[] memory){
        User storage user = users[id];
        return user.partners;
    }


    function setContributedAmount(uint index, uint contribA) external onlyOwner {
        contributeAmounts[index] = contribA;
    }

    function setFixedCommit(bool action) external onlyOwner {
        fixedCommit = action;
    }

    function retrunFixedCommitLeft() external onlyOwner {
        token.safeTransfer(marketingWallet, commitLeft);
        commitLeft = 0;
    }

    function setCommissionFeeRate(uint rate) external onlyOwner {
        commissionFeeRate = rate;
    }

    function setReferRate(uint[] memory rates) external onlyOwner {
        referRate = rates;
    }

    function setLevelStep(uint step) external onlyOwner {
        levelStep = step;
    }

    function setShareLevel6(bool share) external onlyOwner {
        shareLevel6 = share;
    }

    function level6() public view returns (address [] memory) {
        return lvl6;
    }

    function setMarketingWallet(address wallet) external onlyOwner {
        marketingWallet = wallet;
    }

    function setEnabled(bool action) external onlyOwner {
        enabled = action;
    }

    function setToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function setPrice(uint _price) external onlyOwner {
        price = _price;
    }

    function withdraw(uint amount) external onlyOwner {
        if (address(this).balance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
        if (token.balanceOf(address(this)) > 0) {
            token.safeTransfer(msg.sender, amount);
        }
    }

    function setContributeRate(uint rate) external onlyOwner {
        contributeRate = rate;
    }

    function setContributeAddress(PoolV1 pv1) external onlyOwner {
        poolv1 = pv1;
    }

    function setContributeEnabled(bool action) external onlyOwner {
        contributeEnabled = action;
        uint depositLength;
        uint nextPayIndex;
        (, , , depositLength, , , , nextPayIndex) = poolv1.contractInfo();
        contributeIndex = nextPayIndex;
        maxContributeIndex = depositLength;
    }

    function setContributeIndex(uint index, uint max) external onlyOwner {
        contributeIndex = index;
        maxContributeIndex = max;
    }

    function setMaxUnits(uint units) external onlyOwner {
        maxUnits = units;
    }

    function setMinUnits(uint units) external onlyOwner {
        minUnits = units;
    }

    function setMarketingFee(uint fee) external onlyOwner {
        marketingFee = fee;
    }

    function setlvl6Rate(uint fee) external onlyOwner {
        lvl6Rate = fee;
    }

    function siteInfo() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, bool) {
        return (price, minUnits, maxUnits, totalDeposit, depositCount, totalBonus, totalWithdrawn, totalUsers, enabled);
    }
}