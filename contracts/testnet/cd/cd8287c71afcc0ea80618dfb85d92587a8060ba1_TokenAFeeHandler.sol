/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// Sources flattened with hardhat v2.10.1 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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


// File @openzeppelin/contracts-upgradeable/utils/math/[email protected]

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


// File @openzeppelin/contracts-upgradeable/utils/math/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

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
        return a >= b ? a : b;
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
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

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
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}


// File contracts/interfaces/nana/IFeeHandler.sol

pragma solidity ^0.8.0;

// interface process fee
interface IFeeHandler {
    function handleFee(address tokenAddress, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts/utils/structs/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}


// File contracts/interfaces/IERC20.sol

pragma solidity >=0.5.0;

//solhint-disable-next-line compiler-version

interface IERC20 {
    event Approval( address indexed owner, address indexed spender, uint256 value );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File contracts/interfaces/ITokenAFeeHandler.sol

pragma solidity ^0.8.0;


interface ITokenAFeeHandler is IERC20{
    enum FeeType {
        nodeRewardRatio, //0 Node reward
        dividendRatio, //1 Mining with coins
        marketingRatio, //2 marketing
        destroyRatio, //3 destroy
        lpRewardRatio, //4 Liquidity Rewards
        reflowRatio, //5 reflow casting pool
        nftRatio, //6 NFT mining
        ecologyRatio, //7 Ecological construction
        repurchaseDestroy, //8 Repurchase and destroy
        reduceRatio, //9 Sell the remainder after deducting the slippage fee and destroy it
        sellLimitRatio //10 Sell Limit
    }

    enum ActionType {
        Buy, //0
        Sell, //1
        AddLiquid, //2
        RemoveLiquid, //3
        Transfer, //4
        SellReduce//5 Handle the sales repurchase function in the pool, and rebate liquidity.
    }

    struct FeeConfig {
        uint256 feeRatio;
        bool needHandle; // 0-transfer to target; 1-transfer target and handle
        address feeHandler;
    }

    struct InsuredConfig{
        uint32 start;
        uint32 end;
        uint ratio;
    }

    struct TradingOperationConfig {
        ActionType actionType;
        uint256 totalFeeRatio;
        mapping(uint256 => FeeConfig) handleConfig;
        EnumerableSet.UintSet rewardTypeSet;
    }

    struct LiquidityLockConfig {
        bool openLockLiquid;
        uint lockLiquidDuration;
        address lpTimeLock;
    }

    function setFeeConfig(
        ActionType _tradingType,
        FeeType _rewardType,
        FeeConfig memory _config,
        bool opt
    ) external;

 

    function getFeeConfig(ActionType _tradingType, FeeType _rewardType)
        external
        view
        returns (FeeConfig memory feeConfig);

    function getBase() external view returns (uint256);

    function handleDeductFee(ActionType actionType,uint256 feeAmount,address from,address user) external;

    function calDeductFee(ActionType actionType, uint256 inputAmount)
        external
        view
        returns (uint256 leftAmount);

    function calAddFee(ActionType actionType, uint256 inputAmount)
        external
        view
        returns (uint256 addAmount);
    function checkBuy(address buyAddress) external view;
    function checkSell(address sellAddress) external view;
    function reflowDistributeFee(ActionType actionType) external;

    function getReduceThreshold() external view returns (uint);

    function getLiquidityLockConfig() external view returns(LiquidityLockConfig memory config);
    function setLiquidityLockConfig(LiquidityLockConfig memory config) external;
    // function handleLiquidDeductFee( ActionType actionType, uint256 feeAmount, address from ) external;

    function transferFromFee(
        address from,
        address to,
        uint256 amount,
        ITokenAFeeHandler.ActionType actionType,
        address user
    ) external returns (uint256 deductFeeLeftAmount);

    function transferFee(address to, uint256 amount,ITokenAFeeHandler.ActionType actionType,address user) external returns (uint256 deductFeeLeftAmount);
}


// File contracts/interfaces/IOracle.sol

pragma solidity ^0.8.0;

interface IOracle {
    function getPriceChangeRatio() external view returns (uint256 priceChangeRatio);
}


// File contracts/libraries/TransferHelper.sol

pragma solidity ^0.8.4;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("approve(address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("transfer(address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }

    function isContract(address _addr)internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}


// File contracts/interfaces/IBkWeList.sol

pragma solidity ^0.8.0;

interface IBkWeList {
    function isWeList(address _address)external view returns(bool);

    function isBkList(address _address)external view returns(bool);
}


// File contracts/BkWeList.sol

pragma solidity ^0.8.0;


// //import "hardhat/console.sol";

abstract contract BkWeList is IBkWeList {
    using EnumerableSet for EnumerableSet.AddressSet;

    event AddWeList(address[] _address);
    event RemoveWeList(address _address);
    event AddBkList(address[] _address);
    event RemoveBkList(address _address);

    EnumerableSet.AddressSet internal bkList;
    EnumerableSet.AddressSet internal weList;

    modifier validateBkWe(address _address) virtual {
        if (weList.contains(_address)) {} else {
            require(!bkList.contains(_address), "address in blackList");
            _;
        }
    }

    function _addWeList(address[] memory _address) internal virtual {
        for (uint i = 0; i < _address.length; i++) {
            require(!bkList.contains(_address[i]), "address is blackList");
            weList.add(_address[i]);
        }
        emit AddWeList(_address);
    }

    function _removeWeList(address _address) internal virtual {
        weList.remove(_address);
        emit RemoveWeList(_address);
    }

    function isWeList(address _address) public view override returns (bool) {
        return weList.contains(_address);
    }

    function _addBkList(address[] memory _address) internal virtual {
        for (uint i = 0; i < _address.length; i++) {
            require(!weList.contains(_address[i]), "address is whiteList");
            bkList.add(_address[i]);
        }
        emit AddBkList(_address);
    }

    function _removeBkList(address _address) internal virtual {
        bkList.remove(_address);
        emit RemoveBkList(_address);
    }

    function isBkList(address _address) public view override returns (bool) {
        return bkList.contains(_address);
    }
}


// File contracts/banana/TokenAFeeHandler.sol

pragma solidity ^0.8.0;







//import "hardhat/console.sol";

// this is Token A
contract TokenAFeeHandler is ITokenAFeeHandler, BkWeList, OwnableUpgradeable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMathUpgradeable for uint;

    string public _name;
    string public _symbol;
    uint8 public _decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;
    uint256 private _totalSupply;

    mapping(address => bool) public isManager;
    mapping(ActionType => TradingOperationConfig) private configMaps;

    uint16 public base;
    uint16 public transferPercent;
    uint16 public sellPercent;


    LiquidityLockConfig private liquidityLockConfig;

    IOracle public oracle;
    // inflation
    uint256 public baseRatio;
    uint256 public spy;
    uint256 public step;
    uint256 public inflationPattern; // 0 default normal token, 1 inflation token
    uint256 public extraSupply;
    uint256 public inflationRewardEndTime;
    uint256 public minInflationAmount;
    uint256 public reduceThreshold;
    bool public bInInflation;
    mapping(address => bool) public inflationRewardBlacklist;
    mapping(address => uint256) public lastUpdateTime;
    InsuredConfig[] public insuredConfigs;

    event InflationMint(address indexed account, uint256 extraAmount);
    event FeeDeduct(address user,uint256 feeAmount, uint256 feeRatio, ActionType actionType, FeeType rewardType );

    modifier onlyManager() {
        require(isManager[_msgSender()], "Not manager");
        _;
    }

    function initialize(string memory name_, string memory symbol_) public initializer {
        __Ownable_init();
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        base = 10000;
        isManager[_msgSender()] = true;

        baseRatio = 10**18;
        spy = (208 * baseRatio) / 10000 / 1 days;
        step = 15 minutes;
        inflationPattern = 0;
        inflationRewardEndTime = block.timestamp.add(365 days);

        //Add a destroyed configuration by default for check the
        FeeConfig memory feeConfig = FeeConfig(0, false, address(0x000000000000000000000000000000000000dEaD));
        ActionType actionType = ActionType.Sell;
        FeeType feeType = FeeType.destroyRatio;
        configMaps[actionType].rewardTypeSet.add(uint(feeType));
        configMaps[actionType].handleConfig[uint(feeType)] = feeConfig;
    }

    function setOracle(IOracle _oracle) public onlyManager {
        oracle = _oracle;
    }

    function setReduceThreshold(uint _reduceThreshold) public onlyManager {
        reduceThreshold = _reduceThreshold;
    }

    function getReduceThreshold() external view override returns (uint) {
        return reduceThreshold;
    }

    function getBase() external view override returns (uint256) {
        return base;
    }

    function setTransferPercent(uint16 _transferPercent) public onlyManager {
        transferPercent = _transferPercent;
    }

    function setSellPercent(uint16 _sellPercent) public onlyManager {
        sellPercent = _sellPercent;
    }

    function addInsuredConfig(InsuredConfig memory insuredConfig) external onlyManager {
        insuredConfigs.push(insuredConfig);
    }

    function removeInsuredConfig(uint256 index) external onlyManager {
        require(index < insuredConfigs.length, "I");
        insuredConfigs[index] = insuredConfigs[insuredConfigs.length - 1];
        insuredConfigs.pop();
    }

    // Find the corresponding slippage rate based on the oracle price change rate.
    function getInsuredConfigRatio() external view returns(uint256 ratio) {
        if (address(oracle) == address(0)) {
            return 0;
        }
        uint256 priceChangeRatio = oracle.getPriceChangeRatio();
        if (priceChangeRatio > 0) {
            for (uint256 index = 0; index < insuredConfigs.length; index++) {
                InsuredConfig memory config = insuredConfigs[index];
                if (
                    priceChangeRatio >= config.start &&
                    priceChangeRatio < config.end
                ) {
                    ratio = config.ratio;
                    return ratio;
                }
            }
        }
    }

    function setFeeConfig(
        ActionType _actionType,
        FeeType _feeType,
        FeeConfig memory _config,
        bool
    ) external override onlyManager {
        // if (opt) {
            configMaps[_actionType].rewardTypeSet.add(uint(_feeType));
            configMaps[_actionType].totalFeeRatio = configMaps[_actionType].totalFeeRatio + _config.feeRatio;
            configMaps[_actionType].handleConfig[uint(_feeType)] = _config;
            //Add feehandler to whitelist。
        // } else {
        //     configMaps[_actionType].rewardTypeSet.remove(uint(_feeType));
        //     configMaps[_actionType].totalFeeRatio = configMaps[_actionType].totalFeeRatio - _config.feeRatio;
        //     delete configMaps[_actionType].handleConfig[uint(_feeType)];
        //     //Add feehandler to whitelist。
        // }
    }

    function getFeeConfig(ActionType _actionType, FeeType _feeType) external view override returns(FeeConfig memory feeConfig) {
        return configMaps[_actionType].handleConfig[uint(_feeType)];
    }

    // decut the config fee and transfer to handle fee addree which config.
    // prameter from
    function distributeFee(
        ActionType actionType,
        uint feeAmount,
        address from,
        address user
    ) internal {
        // console.log("from is:",from);
        // console.log("_balances[from],feeAmount is:",_balances[from],feeAmount);
        _balances[from] = _balances[from].sub(feeAmount);
        TradingOperationConfig storage operatingConfig = configMaps[actionType];
        uint len = operatingConfig.rewardTypeSet.length();
        uint256 totalFeeRatio = operatingConfig.totalFeeRatio;
        for (uint index = 0; index < len; index++) {
            uint feeType = operatingConfig.rewardTypeSet.at(index);
            FeeConfig storage feeConfig = operatingConfig.handleConfig[feeType];
            uint256 feeRatio = feeConfig.feeRatio;

            //If it is a reflow casting pool, the number of amounts will change due to the impact on the fluidity. is processed last.
            if (feeType == uint(ITokenAFeeHandler.FeeType.reflowRatio) 
                || feeType == uint(ITokenAFeeHandler.FeeType.repurchaseDestroy)) {
                uint amountOfAFee = (feeRatio * feeAmount) / totalFeeRatio;
                
                _balances[address(feeConfig.feeHandler)] += amountOfAFee;
                emit FeeDeduct(user,amountOfAFee, feeRatio, actionType, FeeType(feeType));
                emit Transfer(from, feeConfig.feeHandler, amountOfAFee);
                // this.transferFrom(address(this), feeConfig.feeHandler, amountOfAFee);
                continue;
            }

            // If it is a sell operation and a destroy operation. 
            // Then it is necessary to judge whether the insured mechanism is effective. 
            // If it is effective, the rate of destruction needs to be increased.
            if (
                feeType == uint(ITokenAFeeHandler.FeeType.destroyRatio) &&
                actionType == ITokenAFeeHandler.ActionType.Sell
            ) {
                uint insuredRatio = this.getInsuredConfigRatio();
                if (insuredRatio > 0) {
                    feeRatio += insuredRatio;
                    totalFeeRatio += insuredRatio;
                }
            }
            if (feeRatio > 0) {
                uint amountOfAFee = (feeRatio * feeAmount) / totalFeeRatio;
                // super._transfer(address(this), feeConfig.feeHandler, amountOfAFee);
                _balances[address(feeConfig.feeHandler)] += amountOfAFee;
                emit FeeDeduct(user,amountOfAFee, feeRatio, actionType, FeeType(feeType));
                emit Transfer(from, feeConfig.feeHandler, amountOfAFee);
                if (feeConfig.needHandle) {
                    IFeeHandler(feeConfig.feeHandler).handleFee( address(this), amountOfAFee );
                }
            }
        }
    }

    // reflow fee processing.
    function reflowDistributeFee(ActionType actionType) external override {
        TradingOperationConfig storage operatingConfig = configMaps[actionType];
        FeeConfig storage feeConfig = operatingConfig.handleConfig[
            uint(ITokenAFeeHandler.FeeType.reflowRatio)
        ];
        if (feeConfig.feeRatio > 0) {
            IFeeHandler(feeConfig.feeHandler).handleFee(address(this), 0);
        }

        FeeConfig storage feeConfig2 = operatingConfig.handleConfig[
            uint(ITokenAFeeHandler.FeeType.repurchaseDestroy)
        ];
        if (feeConfig2.feeRatio > 0) {
            IFeeHandler(feeConfig2.feeHandler).handleFee(address(this), 0);
        }
    }


    function handleDeductFee( ActionType actionType, uint256 feeAmount, address from,address user ) external override {
        distributeFee(actionType, feeAmount, from,user);
    }

    // Calculates the amount of reduced handling fee based on the amount entered and the total handling fee.
    function calDeductFee(ActionType actionType, uint256 inputAmount) external view override returns (uint256 leftAmount) {
        TradingOperationConfig storage operatingConfig = configMaps[actionType];
        uint256 totalFeeRatio = operatingConfig.totalFeeRatio;
        // If it is a sell operation and a destroy operation. 
        // Then it is necessary to judge whether the insured mechanism is effective. 
        // If it is effective, the rate of destruction needs to be increased.。
        if (actionType == ITokenAFeeHandler.ActionType.Sell) {
            uint256 insuredRatio = this.getInsuredConfigRatio();
            if (insuredRatio > 0) {
                totalFeeRatio += insuredRatio;
            }
        }
        if (totalFeeRatio <= 0) {
            return inputAmount;
        }

        leftAmount = (inputAmount * (base - totalFeeRatio)) / base;
        return leftAmount;
    }

    // Calculate the amount of increased handling fee based on the amount entered and the total handling fee
    function calAddFee(ActionType actionType, uint256 inputAmount) external view override returns (uint256 addAmount) {
        TradingOperationConfig storage operatingConfig = configMaps[actionType];
        uint256 totalFeeRatio = operatingConfig.totalFeeRatio;

        // If it is a sell operation and a destroy operation. 
        // Then it is necessary to judge whether the insured mechanism is effective. 
        // If it is effective, the rate of destruction needs to be increased.
        if (actionType == ITokenAFeeHandler.ActionType.Sell) {
            uint256 insuredRatio = this.getInsuredConfigRatio();
            if (insuredRatio > 0) {
                totalFeeRatio += insuredRatio;
            }
        }

        if (totalFeeRatio <= 0) {
            return inputAmount;
        }
        addAmount = (base * inputAmount) / (base - totalFeeRatio);
        if (((base * inputAmount) % (base - totalFeeRatio)) > 0) {
            addAmount += 1;
        }
        return addAmount;
    }

    function setManager(address _manager, bool _flag) public onlyOwner {
        isManager[_manager] = _flag;
    }

    function truncateManager() public onlyManager {
        delete isManager[msg.sender];
    }

    function setInflationRewardBlacklist(address account, bool enable) public virtual onlyManager {
        inflationRewardBlacklist[account] = enable;
    }

    function getReward(address account) public view returns (uint256) {
       if (lastUpdateTime[account] == 0 || inflationRewardBlacklist[account] || inflationPattern == 0 || _balances[account] < minInflationAmount) {
            return 0;
        }

        uint256 duration = lastTime().sub(lastUpdateTime[account]);
        if (duration < step) {
            return 0;
        }

        return _balances[account].mul(spy).div(baseRatio).mul(lastTime().sub(lastUpdateTime[account]));
    }   

    function lastTime() public view returns (uint256) {
        return MathUpgradeable.min(block.timestamp, inflationRewardEndTime);
    }

    modifier calculateReward(address account) {
        if (account != address(0) && !bInInflation ) {
            bInInflation = true;

            uint256 reward = getReward(account);
            if (reward > 0) {
                extraSupply = extraSupply.add(reward);
                _balances[account] = _balances[account].add(reward);
                emit InflationMint(account, reward);
            }

            lastUpdateTime[account] = inflationPattern == 0 ? 0 : lastTime();
            bInInflation = false;
        }
        _;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual calculateReward(from) calculateReward(to) { }

    function setBaseRatio(uint256 _baseRatio) public virtual onlyManager {
        baseRatio = _baseRatio;
    }

    function setSpy(uint256 _spy) public virtual onlyManager {
        spy = _spy;
    }

    function setStep(uint256 _step) public virtual onlyManager {
        step = _step;
    }

    function setInflationPattern(uint8 pattern) public onlyManager {
        require(pattern == 0 || pattern == 1, "invalide value");
        inflationPattern = pattern;
    }

    function setInflationRewardEndTime(uint256 endTime) public onlyManager {
        inflationRewardEndTime = endTime;
    }

    function setMinInflationAmount(uint256 _minInflationAmount)
        public
        onlyManager
    {
        minInflationAmount = _minInflationAmount;
    }

    function getLiquidityLockConfig()
        external
        view
        override
        returns (LiquidityLockConfig memory config)
    {
        return liquidityLockConfig;
    }

    function setLiquidityLockConfig(LiquidityLockConfig memory config)
        external
        override
    {
        liquidityLockConfig = config;
    }

    function checkBuy(address buyAddress)
        public
        view
        override
        validateBkWe(buyAddress)
    {
    }

    function checkSell(address sellAddress)
        public
        view
        override
        validateBkWe(sellAddress)
    {
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply + extraSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner] + getReward(owner);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transferFrom(from, to, value);
        return true;
    }

    function _transferFrom(address from, address to, uint256 value) internal returns (bool) {
        require(value <= balanceOf(from), "error balance");
        require(to != address(0), "zero address");
        require(!isBkList(from),"is Bk");

        _beforeTokenTransfer(from, to, value);
        
        // The account must keep a certain remaining amount.
        // If the from is contract,it is not restricted by this rule, because the contract does other DEFI business
        if (!TransferHelper.isContract(from)) {
            uint256 balanceOfFrom = balanceOf(from);
            require((balanceOfFrom - value) * base >= transferPercent * balanceOfFrom, "amount gt balance");
        }
        uint deductFeeAmount = value;
        if(!(TransferHelper.isContract(from) || TransferHelper.isContract(to)) && !isWeList(from)){
            deductFeeAmount = this.calDeductFee(ActionType.Transfer, value);
            uint256 fee = value - deductFeeAmount;
            //If it is a transfer to a contract or not, it is a transfer between users
            if (fee > 0) {
                this.handleDeductFee(ActionType.Transfer,fee, msg.sender,msg.sender);
                this.reflowDistributeFee(ActionType.Transfer);
            }
        }

        _balances[from] = _balances[from].sub(deductFeeAmount);
        _balances[to] = _balances[to].add(deductFeeAmount);
        emit Transfer(from, to, deductFeeAmount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        require(amount <= _balances[account]);

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        require(amount <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }

    // for swap transfer with fee delivery
    function _transferFromFee(
        address from,
        address to,
        uint256 value,
        ActionType actionType,
        address user

    ) internal returns (uint256 deductFeeLeftAmount) {
        require(value <= balanceOf(from), "error balance");
        require(to != address(0), "zero address");

        _beforeTokenTransfer(from, to, value);

        // Account sold must keep a certain remaining amount
        // If the contract is transferred to other contracts or users, 
        // it is not restricted by this rule, because the contract does other DEFI business.
        if (!TransferHelper.isContract(from)) {
            uint256 balanceOfFrom = balanceOf(from);
            require((balanceOfFrom - value) * base >= sellPercent * balanceOfFrom, "sellAmount gt balance");
        }
        deductFeeLeftAmount = this.calDeductFee(actionType, value);
        uint256 feeAmount = value - deductFeeLeftAmount;
        if (feeAmount > 0) {
            this.handleDeductFee(actionType, feeAmount, from,user);
        }

        _balances[from] = _balances[from].sub(deductFeeLeftAmount);
        _balances[to] = _balances[to].add(deductFeeLeftAmount);
        emit Transfer(from, to, deductFeeLeftAmount);
        return deductFeeLeftAmount;
    }

    // for swap transfer with fee delivery
    function transferFee(
        address to, 
        uint256 value, 
        ActionType actionType,
        address user
    ) public override returns (uint256 deductFeeLeftAmount) {
        return _transferFromFee(msg.sender, to, value, actionType,user);
    }

    // for swap transfer with fee delivery
    function transferFromFee(
        address from,
        address to,
        uint256 value,
        ActionType actionType,
        address user
    ) public override returns (uint256 deductFeeLeftAmount) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        return _transferFromFee(from, to, value, actionType,user);
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }


    function addWeList(address[] memory _address) public virtual onlyManager {
        _addWeList(_address);
    }

    function removeWeList(address _address) public virtual onlyManager {
        _removeWeList(_address);
    }

    function addBkList(address[] memory _address) public virtual onlyManager {
        _addBkList(_address);
    }

    function removeBkList(address _address) public virtual onlyManager {
        _removeBkList(_address);
    }

}