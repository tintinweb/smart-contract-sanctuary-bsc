// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IPancakePair.sol";

contract HexaFinityTokenUpgradable is Initializable, IERC20Upgradeable, OwnableUpgradeable {
  using StringsUpgradeable for uint256;
  using SafeMathUpgradeable for uint256;
  using AddressUpgradeable for address;

  mapping(address => uint256) private _rOwned;
  mapping(address => uint256) private _tOwned;
  mapping(address => mapping(address => uint256)) private _allowances;

  mapping(address => bool) private _isExcludedFromFee;

  mapping(address => bool) private _isExcluded;
  address[] private _excluded;
  
  uint256 private constant MAX = ~uint256(0);
  uint256 private _tTotal;
  uint256 private _rTotal;
  uint256 private _tFeeTotal;

  /**
   * @dev Sets the values for {NAME} and {SYMBOL}, and {DECIMALS}
   *
   * All three of these values are constants: they can only be set once during
   * construction.
   */
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  
  /**
   * @dev denomiator of rate calculation.
   */   
  uint256 private constant RATE_DENOMINATOR = 10**3;

  /**
   * @dev Percentage of the static reflection fee.
   */        
  uint256 public _rewardFee;
  uint256 private _previousRewardFee;

  /**
   * @dev Percentage of the liquidity fee.
   */           
  uint256 public _liquidityFee;
  uint256 private _previousLiquidityFee;

  /**
   * @dev Percentage of the auto burn fee.
   */   
  uint256 public _burnFee;
  uint256 private _previousBurnFee;
  address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD; 

  /**
   * @dev Percentage of the owner fee.
   */   
  uint256 public _taxFee;
  address public taxFeeAddress;
  uint256 private _previousTaxFee;

  IPancakeRouter02 public pancakeswapV2Router;
  address public pancakeswapV2Pair;
  
  bool inSwapAndLiquify;
  bool public swapAndLiquifyEnabled;

  /**
   * @dev The maximum transaction amount to minimize and break the impact of 
   * Whale actions.
   */       
  uint256 public _maxTxAmount;
  
  /**
   * @dev The number of tokens sell, to add to the liquidity.
   */     
  uint256 public numTokensSellToAddToLiquidity;
  
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event LiquidityAdded(uint256 tokenAmount, uint256 bnbAmount);
  event SwapAndLiquifyStatus(string status);
  event SwapAndLiquify(
      uint256 tokensSwapped,
      uint256 bnbReceived,
      uint256 tokensIntoLiquidity
  );
  
  modifier lockTheSwap {
      inSwapAndLiquify = true;
      _;
      inSwapAndLiquify = false;
  }
  
  function initialize(address _router, address _taxReceiver) public initializer {
    __Ownable_init();

    _name = "HexaFinity";
    _symbol = "HEXA";
    _decimals = 18;

    _rewardFee = 1;
    _previousRewardFee = _rewardFee;

    _liquidityFee = 0;
    _previousLiquidityFee = _liquidityFee;

    _burnFee = 3;
    _previousBurnFee = _burnFee;

    _taxFee = 6;
    _previousTaxFee = _taxFee;

    _tTotal = 6000 * 10**9 * 10**_decimals;
    _rTotal = (MAX - (MAX % _tTotal));

    _maxTxAmount = 3 * 10**9 * 10**_decimals; // set 0.005% of total
    numTokensSellToAddToLiquidity = 3 * 10**8 * 10**_decimals; // 10% of maxTxAmount

    _rOwned[_msgSender()] = _rTotal;

    swapAndLiquifyEnabled = false;

    IPancakeRouter02 _pancakeswapV2Router =
        IPancakeRouter02(_router);
      // Create a pancakeswap pair for this new token
    pancakeswapV2Pair = IPancakeFactory(_pancakeswapV2Router.factory()).createPair(
        address(this),
        _pancakeswapV2Router.WETH()
    );

    // set the rest of the contract variables
    pancakeswapV2Router = _pancakeswapV2Router;

    // set tax receiver address
    taxFeeAddress = _taxReceiver;
    
    //exclude owner and this contract from fee
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;
    
    emit Transfer(address(0), _msgSender(), _tTotal);

    // //exclude owner and this contract from fee
    // _isExcludedFromFee[owner()] = true;
    // _isExcludedFromFee[address(this)] = true;
    // _isExcludedFromFee[_taxReceiverAddress] = true;

    // //exclude tax receiver and burn address from reward
    // excludeFromReward(_taxReceiverAddress);
    // excludeFromReward(_burnAddress);
  }

  /**
   * @dev See {IBEP20-name}.
   */
  function name() external view returns (string memory) {
      return _name;
  }

  /**
   * @dev See {IBEP20-symbol}.
   */
  function symbol() external view returns (string memory) {
      return _symbol;
  }

  /**
   * @dev See {IBEP20-decimals}.
   */
  function decimals() external view returns (uint8) {
      return _decimals;
  }

  /**
   * @dev See {IBEP20-totalSupply}.
   */
  function totalSupply() external view override returns (uint256) {
      return _tTotal;
  }

  /**
   * @dev See {IBEP20-balanceOf}.
   */
  function balanceOf(address account) public view override returns (uint256) {
      if (_isExcluded[account]) return _tOwned[account];
      return tokenFromReflection(_rOwned[account]);
  }

  /**
   * @dev See {IBEP20-transfer}.
   */
  function transfer(address recipient, uint256 amount)
      external
      override
      returns (bool)
  {
      _transfer(_msgSender(), recipient, amount);
      return true;
  }

  /**
   * @dev See {IBEP20-allowance}.
   */
  function allowance(address owner, address spender)
      external
      view
      override
      returns (uint256)
  {
      return _allowances[owner][spender];
  }

  /**
   * @dev See {IBEP20-approve}.
   */
  function approve(address spender, uint256 amount)
      external
      override
      returns (bool)
  {
      _approve(_msgSender(), spender, amount);
      return true;
  }

  /**
   * @dev See {IBEP20-transferFrom}.
   */
  function transferFrom(
      address sender,
      address recipient,
      uint256 amount
  ) external override returns (bool) {
      _transfer(sender, recipient, amount);
      _approve(
          sender,
          _msgSender(),
          _allowances[sender][_msgSender()].sub(
              amount,
              "BEP20: transfer amount exceeds allowance"
          )
      );
      return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as mitigation for
   * problems described in {IBEP20-approve}.
   */
  function increaseAllowance(address spender, uint256 addedValue)
      external
      virtual
      returns (bool)
  {
      _approve(
          _msgSender(),
          spender,
          _allowances[_msgSender()][spender].add(addedValue)
      );
      return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as mitigation for
   * problems described in {IBEP20-approve}.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue)
      external
      virtual
      returns (bool)
  {
      _approve(
          _msgSender(),
          spender,
          _allowances[_msgSender()][spender].sub(
              subtractedValue,
              "BEP20: decreased allowance below zero"
          )
      );
      return true;
  }

  function isExcludedFromReward(address account) external view returns (bool) {
      return _isExcluded[account];
  }

  function totalFees() external view returns (uint256) {
      return _tFeeTotal;
  }

function totalBurned() external view returns (uint256) {
  return balanceOf(BURN_ADDRESS);
}

  function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
      require(tAmount <= _tTotal, "Amount must be less than supply");
      if (!deductTransferFee) {
          (uint256 rAmount,,,,,) = _getValues(tAmount);
          return rAmount;
      } else {
          (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
          return rTransferAmount;
      }
  }
  
  function tokenFromReflection(uint256 rAmount)
      public
      view
      returns (uint256)
  {
      require(
          rAmount <= _rTotal,
          "Amount must be less than total reflections"
      );
      uint256 currentRate = _getRate();
      return rAmount.div(currentRate);
  }

  function excludeFromReward(address account) external onlyOwner() {
      require(
          account != 0x10ED43C718714eb63d5aA57B78B54704E256024E, 
          "We can not exclude Pancake router."
      );
      require(
          !_isExcluded[account], 
          "Account is already excluded"
      );
      if(_rOwned[account] > 0) {
          _tOwned[account] = tokenFromReflection(_rOwned[account]);
      }
      _isExcluded[account] = true;
      _excluded.push(account);
  }

  /**
   * @dev limit excluded addresses list to avoid aborting functions with 
   * "out-of-gas" exception.
   */   
  function includeInReward(address account) external onlyOwner() {
      require(_isExcluded[account], "Account is not excluded");
      for (uint256 i = 0; i < _excluded.length; i++) {
          if (_excluded[i] == account) {
              _excluded[i] = _excluded[_excluded.length - 1];
              _tOwned[account] = 0;
              _isExcluded[account] = false;
              _excluded.pop();
              break;
          }
      }
  }

  function _transferBothExcluded(
      address sender, 
      address recipient, 
      uint256 tAmount
  ) private {
      (uint256 rAmount, 
      uint256 rTransferAmount, 
      uint256 rFee, 
      uint256 tTransferAmount, 
      uint256 tFee, 
      uint256 tLiquidity
      ) = _getValues(tAmount);
      _tOwned[sender] = _tOwned[sender].sub(tAmount);
      _rOwned[sender] = _rOwned[sender].sub(rAmount);
      _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
      _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
      _takeLiquidity(tLiquidity);
      _reflectFee(rFee, tFee);
      emit Transfer(sender, recipient, tTransferAmount);
  }
  
  //to receive BNB from pancakeswapV2Router when swapping
  receive() external payable {}

  function _reflectFee(uint256 rFee, uint256 tFee) private {
      _rTotal = _rTotal.sub(rFee);
      _tFeeTotal = _tFeeTotal.add(tFee);
  }

  function _getValues(uint256 tAmount)
      private
      view
      returns (
          uint256,
          uint256,
          uint256,
          uint256,
          uint256,
          uint256
      )
  {
      (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) =
          _getTValues(tAmount);
      (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
          _getRValues(tAmount, tFee, tLiquidity, _getRate());
      return (
          rAmount,
          rTransferAmount,
          rFee,
          tTransferAmount,
          tFee,
          tLiquidity
      );
  }

  function _getTValues(uint256 tAmount) 
      private 
      view 
      returns (
          uint256, 
          uint256, 
          uint256
      ) 
  {
      uint256 tFee = calculateTaxFee(tAmount);
      uint256 tLiquidity = calculateLiquidityFee(tAmount);
      uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
      return (tTransferAmount, tFee, tLiquidity);
  }

  function _getRValues(
      uint256 tAmount,
      uint256 tFee,
      uint256 tLiquidity,
      uint256 currentRate
  )
      private
      pure
      returns (
          uint256,
          uint256,
          uint256
      )
  {
      uint256 rAmount = tAmount.mul(currentRate);
      uint256 rFee = tFee.mul(currentRate);
      uint256 rLiquidity = tLiquidity.mul(currentRate);
      uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
      return (rAmount, rTransferAmount, rFee);
  }

  function _getRate() private view returns(uint256) {
      (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
      return rSupply.div(tSupply);
  }

  /**
   * @dev limit excluded addresses list to avoid aborting functions with 
   * "out-of-gas" exception.
   */   
  function _getCurrentSupply() private view returns(uint256, uint256) {
      uint256 rSupply = _rTotal;
      uint256 tSupply = _tTotal;
      for (uint256 i = 0; i < _excluded.length; i++) {
          if (
              _rOwned[_excluded[i]] > rSupply ||
              _tOwned[_excluded[i]] > tSupply
          ) return (_rTotal, _tTotal);
          rSupply = rSupply.sub(_rOwned[_excluded[i]]);
          tSupply = tSupply.sub(_tOwned[_excluded[i]]);
      }
      if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
      return (rSupply, tSupply);
  }
  
  function _takeLiquidity(uint256 tLiquidity) private {
      uint256 currentRate = _getRate();
      uint256 rLiquidity = tLiquidity.mul(currentRate);
      _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
      if(_isExcluded[address(this)])
          _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
  }
  
  function calculateTaxFee(uint256 _amount) private view returns (uint256) {
      return _amount.mul(_rewardFee).div(RATE_DENOMINATOR);
  }

  function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
      return _amount.mul(_liquidityFee).div(RATE_DENOMINATOR);
  }
  
  function removeAllFee() private {
      if(_rewardFee == 0 && _liquidityFee == 0 && _taxFee == 0 && _burnFee == 0) return;
      
      _previousRewardFee = _rewardFee;
      _previousLiquidityFee = _liquidityFee;
      _previousTaxFee = _taxFee;
      _previousBurnFee = _burnFee;
      
      _rewardFee = 0;
      _liquidityFee = 0;
      _taxFee = 0;
      _burnFee = 0;
  }
  
  function restoreAllFee() private {
      _rewardFee = _previousRewardFee;
      _liquidityFee = _previousLiquidityFee;
      _burnFee = _previousBurnFee;
      _taxFee = _previousTaxFee;
  }
  
  function isExcludedFromFee(address account) external view returns(bool) {
      return _isExcludedFromFee[account];
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve` and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) private {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");

      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer} and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` / `from` cannot be the zero address.
   * - `recipient` / `to` cannot be the zero address.
   * - `sender` / `from` must have a balance of at least `amount`.
   */
  function _transfer(
      address from,  // sender
      address to,  // recipient
      uint256 amount
  ) private {
      require(from != address(0), "BEP20: transfer from the zero address");
      require(to != address(0), "BEP20: transfer to the zero address");
      require(amount > 0, "Transfer amount must be greater than zero");

      // is the token balance of this contract address over the min number of
      // tokens that we need to initiate a swap + liquidity lock?
      // also, don't get caught in a circular liquidity event.
      // also, don't swap & liquify if sender is pancakeswap pair.
      uint256 contractTokenBalance = balanceOf(address(this));        
      bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
      if (
          overMinTokenBalance &&
          !inSwapAndLiquify &&
          from != pancakeswapV2Pair &&
          swapAndLiquifyEnabled
      ) {
          contractTokenBalance = numTokensSellToAddToLiquidity;
          //add liquidity
          swapAndLiquify(contractTokenBalance);
      }
      
      //transfer amount, it will take reward, burn, liquidity fee
      _tokenTransfer(from,to,amount);
  }

  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
      // split the contract balance into halves
      uint256 half = contractTokenBalance.div(2);
      uint256 otherHalf = contractTokenBalance.sub(half);

      // capture the contract's current BNB balance.
      // this is so that we can capture exactly the amount of BNB that the
      // swap creates and does not make the liquidity event include any BNB that
      // has been manually sent to the contract
      uint256 initialBalance = address(this).balance;

      // swap tokens for BNB
      swapTokensForBnb(half); // this breaks the BNB 

      // how much BNB did we just swap into?
      uint256 newBalance = address(this).balance.sub(initialBalance);

      // add liquidity to Pancakeswap
      addLiquidity(otherHalf, newBalance);
      
      emit SwapAndLiquify(half, newBalance, otherHalf);
  }

  // @dev The swapAndLiquify function uses this for swap to BNB
  function swapTokensForBnb(uint256 tokenAmount) private returns (bool status){

      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = pancakeswapV2Router.WETH();

      _approve(address(this), address(pancakeswapV2Router), tokenAmount);

      // make the swap
      // A reliable Oracle is to be introduced to avoid possible sandwich attacks.
      try pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          tokenAmount,
          0, // accept any amount of BNB
          path,
          address(this),
          block.timestamp
      ) {
          emit SwapAndLiquifyStatus("Success");
          return true;
      }   
      catch {
          emit SwapAndLiquifyStatus("Failed");
          return false;
      }
  }

  function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
      // approve token transfer to cover all possible scenarios
      _approve(address(this), address(pancakeswapV2Router), tokenAmount);

      // add liquidity and get LP tokens to contract itself
      // A reliable Oracle is to be introduced to avoid possible sandwich attacks.
      pancakeswapV2Router.addLiquidityETH{value: bnbAmount}(
          address(this),
          tokenAmount,
          0, // slippage is unavoidable
          0, // slippage is unavoidable
          address(this),
          block.timestamp
      );
      emit LiquidityAdded(tokenAmount, bnbAmount);        
  }

  //this method is responsible for taking all fee, if takeFee is true
  function _tokenTransfer(address sender, address recipient, uint256 amount) private {
      if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
          removeAllFee();
      }
      else{
          require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount");
      }
      
      //Calculate burn amount and development amount
      uint256 burnAmt = amount.mul(_burnFee).div(RATE_DENOMINATOR);
      uint256 taxFeeAmt = amount.mul(_taxFee).div(RATE_DENOMINATOR);

      if (_isExcluded[sender] && !_isExcluded[recipient]) {
          _transferFromExcluded(sender, recipient, (amount.sub(burnAmt).sub(taxFeeAmt)));
      } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
          _transferToExcluded(sender, recipient, (amount.sub(burnAmt).sub(taxFeeAmt)));
      } else if (_isExcluded[sender] && _isExcluded[recipient]) {
          _transferBothExcluded(sender, recipient, (amount.sub(burnAmt).sub(taxFeeAmt)));
      } else {
          _transferStandard(sender, recipient, (amount.sub(burnAmt).sub(taxFeeAmt)));
      }
      
      //Temporarily remove fees to transfer to burn address and development wallet
      _rewardFee = 0;
      _liquidityFee = 0;

      //Send transfers to burn address and development wallet
      if (burnAmt> 0)
          _transferStandard(sender, BURN_ADDRESS, burnAmt);
      if (taxFeeAmt>0)
          _transferStandard(sender, taxFeeAddress, taxFeeAmt);

      //Restore reward and liquidity fees
      _rewardFee = _previousRewardFee;
      _liquidityFee = _previousLiquidityFee;

      if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
          restoreAllFee();
  }

  function _transferStandard(
      address sender,
      address recipient,
      uint256 tAmount
  ) private {
      (
          uint256 rAmount,
          uint256 rTransferAmount,
          uint256 rFee,
          uint256 tTransferAmount,
          uint256 tFee,
          uint256 tLiquidity
      ) = _getValues(tAmount);
      _rOwned[sender] = _rOwned[sender].sub(rAmount);
      _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
      _takeLiquidity(tLiquidity);
      _reflectFee(rFee, tFee);
      emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
      (
          uint256 rAmount, 
          uint256 rTransferAmount, 
          uint256 rFee, 
          uint256 tTransferAmount, 
          uint256 tFee, 
          uint256 tLiquidity
      ) = _getValues(tAmount);
      _rOwned[sender] = _rOwned[sender].sub(rAmount);
      _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
      _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
      _takeLiquidity(tLiquidity);
      _reflectFee(rFee, tFee);
      emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
      (
          uint256 rAmount, 
          uint256 rTransferAmount, 
          uint256 rFee, 
          uint256 tTransferAmount, 
          uint256 tFee, 
          uint256 tLiquidity
      ) = _getValues(tAmount);
      _tOwned[sender] = _tOwned[sender].sub(tAmount);
      _rOwned[sender] = _rOwned[sender].sub(rAmount);
      _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
      _takeLiquidity(tLiquidity);
      _reflectFee(rFee, tFee);
      emit Transfer(sender, recipient, tTransferAmount);
  }

  /**
   * @dev The owner can withdraw BNB collected in the contract from 
   * `swapAndLiquify` or if someone sends BNB directly to the contract.
   * 
   * The swapAndLiquify function converts half of the contractTokenBalance 
   * tokens to BNB. For every swapAndLiquify function call, a small amount 
   * of BNB remains in the contract. This amount grows over time with the 
   * swapAndLiquify function being called throughout the life of the contract.
   * 
   * This amount will migrate via the Multi-Signature owner's wallet and
   * be used for charity purposes according to public consent. 
   */
  // function migrateLeftoverBnb(
  //     address payable recipient, 
  //     uint256 amount
  // ) external onlyOwner nonReentrant{
  //     require(recipient != address(0), 
  //         "BEP20: recipient cannot be the zero address");
  //     require(amount <= address(this).balance, 
  //         "BEP20: amount should not exceed the contract balance."
  //     );
  //     recipient.transfer(amount);
  // }

  /**
   * @dev The owner can exclude specific accounts from Fees.
   */   
  function excludeFromFee(address account) external onlyOwner {
      _isExcludedFromFee[account] = true;
  }

    /**
   * @dev The owner can include specific accounts in Fees.
   */           
  function includeInFee(address account) external onlyOwner {
      _isExcludedFromFee[account] = false;
  }

  /**
   * @dev Call this function to enable Swap and Liquify.
   */  
  function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
      swapAndLiquifyEnabled = _enabled;
      emit SwapAndLiquifyEnabledUpdated(_enabled);
  }
  
  /**
   * @dev This function can be used to change burnFee to zero percentage upon a 
   * certain amount of tokens are burned.
   */
  function stopAutoBurn() external onlyOwner() {
      _burnFee = 0;
  }
  
  /**
   * @dev Update the amount of "numTokensSellToAddToLiquidity".
   * 
   * Requirements:
   *
   * The new amount must be less than or equal to one million.
   */   
  function setNumTokensSellToAddToLiquidity(uint256 newAmount) external onlyOwner() {
      require(newAmount <= 1e6 * 10**_decimals, 
          "BEP20: the amount must be lesser than or equal to one million."
      );      
      numTokensSellToAddToLiquidity = newAmount;
  }

  /**
   * @dev Call this function to change the Max transaction amount.
   * Adjusting of 'maxTxAmount' will be required during the initial stage.
   * 
   * Requirements:
   *
   * The new amount must be greater than or equal to one million to avoid misuse 
   * of the function.
   */      
  function setMaxTxAmount(uint256 newAmount) external onlyOwner() {
      require(newAmount >= 1e6 * 10**_decimals, 
          "BEP20: the amount must be greater than or equal to one million."
      );        
      _maxTxAmount = newAmount;
  }

  /**
   * @dev Call this function if required to set a different Development 
   * wallet address.
   *
   * Requirements:
   *
   * The development wallet cannot be the zero address.
   */
  function setDevelopmentWallet(address newWallet) external onlyOwner() {
      require(newWallet != address(0), 
          "BEP20: the new wallet cannot be the zero address."
      );
      taxFeeAddress = newWallet;
  }
  
  /**
   * @dev Update the Router address if Pancakeswap upgrades to a 
   * newer version.
   */
  function setRouterAddress(address newRouter) external onlyOwner {
      IPancakeRouter02 _newRouter = IPancakeRouter02(newRouter);
      address get_pair = IPancakeFactory(_newRouter.factory()).getPair(
          address(this), _newRouter.WETH()
      );
      //checks if pair already exists
      if (get_pair == address(0)) {
          pancakeswapV2Pair = IPancakeFactory(_newRouter.factory()).createPair(
              address(this), _newRouter.WETH()
          );
      }
      else {
          pancakeswapV2Pair = get_pair;
      }
          pancakeswapV2Router = _newRouter;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPancakePair {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPancakeRouter01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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