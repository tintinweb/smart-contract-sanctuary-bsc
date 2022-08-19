/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org
// SPDX-License-Identifier: MIT
// File @openzeppelin/contracts-upgradeable/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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


// File @openzeppelin/contracts-upgradeable/security/[email protected]


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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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


// File @openzeppelin/contracts-upgradeable/security/[email protected]


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// File @openzeppelin/contracts/utils/cryptography/[email protected]


// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
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


// File contracts/MetafameSale_MTv2.sol


pragma solidity ^0.8.0;










abstract contract Status is ContextUpgradeable {

    event Publicsaled(address account);
    event Unpublicsaled(address account);
    event Presaled(address account);
    event Unpresaled(address account);
    event Vcsaled(address account);
    event Unvcsaled(address account);
    event MakeoverStart(address account);
    event MakeoverStop(address account);
    event RefreshStart(address account);
    event RefreshStop(address account);

    bool private _publicsaled;
    bool private _presaled;
    bool private _vcsaled;
    bool private _makeoverStatus;
    bool private _refreshStatus;

    function __Status_init() internal {
        _publicsaled = false;
        _presaled = false;
        _vcsaled = false;
        _makeoverStatus = false;
        _refreshStatus = false;
    }

    function publicsaled() public view virtual returns (bool) {
        return _publicsaled;
    }

    function presaled() public view virtual returns (bool) {
        return _presaled;
    }

    function vcsaled() public view virtual returns (bool) {
        return _vcsaled;
    }

    function makeoverStatus() public view virtual returns (bool) {
        return _makeoverStatus;
    }

    function refreshStatus() public view virtual returns (bool) {
        return _refreshStatus;
    }

    modifier whenPublicsaled() {
        require(publicsaled(), "Status: not publicsaled");
        _;
    }

    modifier whenPresaled() {
        require(presaled(), "Status: not presaled");
        _;
    }

    modifier whenVcsaled() {
        require(vcsaled(), "Status: not vcsaled");
        _;
    }

    modifier whenMakeover() {
        require(makeoverStatus(), "Status: not makeover");
        _;
    }

    modifier whenRefresh() {
        require(refreshStatus(), "Status: not refresh");
        _;
    }

    function _publicsale() internal virtual  {
        _publicsaled = true;
        emit Publicsaled(_msgSender());
    }

    function _unpublicsale() internal virtual  {
        _publicsaled = false;
        emit Unpublicsaled(_msgSender());
    }

    function _presale() internal virtual  {
        _presaled = true;
        emit Presaled(_msgSender());
    }

    function _unpresale() internal virtual  {
        _presaled = false;
        emit Unpresaled(_msgSender());
    }

    function _vcsale() internal virtual  {
        _vcsaled = true;
        emit Vcsaled(_msgSender());
    }

    function _unvcsale() internal virtual  {
        _vcsaled = false;
        emit Unvcsaled(_msgSender());
    }

    function _makeoverStart() internal virtual  {
        _makeoverStatus = true;
        emit MakeoverStart(_msgSender());
    }

    function _makeoverStop() internal virtual  {
        _makeoverStatus = false;
        emit MakeoverStop(_msgSender());
    }

    function _refreshStart() internal virtual  {
        _refreshStatus = true;
        emit RefreshStart(_msgSender());
    }

    function _refreshStop() internal virtual  {
        _refreshStatus = false;
        emit RefreshStop(_msgSender());
    }
}

interface IMF1155 {
    function mint(address to, uint256 tokenId, uint256 amount, uint256 gender, uint256 skin) external;
    function mintAndBurn(address account, uint256 tokenId,uint256 newTokenId) external;
    function setRefreshDNA(uint256 tokenId, string memory itemsDNA, string memory layersDNA) external;
    function setRefreshTimes(uint256 tokenId) external;
    function getRemainingBoxQuantity() external view returns(uint256);
    function getAllocatedBoxQuantity() external view returns(uint256);
    function getMaxSupply() external view returns(uint256);
    function getStepOneIdCounter() external view returns (uint256);
    function getMakeOverLimitId() external view returns (uint256);
    function getBalanceOf(address account, uint256 id) external view returns (uint256);
    function pause() external;
    function unpause() external;
}

contract MetafameSaleMTv20_0819 is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, PausableUpgradeable, Status{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    
    bool public _endsaled;
    uint256 public _FOR_OWNER;

    IMF1155 public metafame1155;
    address public busdAddr;
    address public setterAddr;

    uint256 public maxPurchaseLimit;
    uint256 public maxPurchaseLimitWL;
    uint256 public maxPurchaseLimitVC;

    uint256 public publicSaleStart;
    uint256 public publicSaleEnd;

    uint256 public busdPerBox;
    uint256 public busdPerBoxWL;
    uint256 public busdPerBoxVC;
    uint256 public makeOverPrice;
    uint256 public refreshPrice;

    uint256 private _makeOver;
    string private _vcode;

    uint256 public vcRoundNumber;
    struct VCRoundInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 limit;
        uint256 alreadySaled;
    }
    mapping(uint256 => VCRoundInfo) public vcRound;

    uint256 public wlRoundNumber;
    struct RoundInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 limit;
        uint256 alreadySaled;
    }
    mapping(uint256 => RoundInfo) public wlRound;

    uint256 public refreshRoundNumber;
    struct RefreshRoundInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 limit;
        uint256 alreadyRefreshed;
        string refreshPartName1;
        string refreshPartName2;
    }
    mapping(uint256 => RefreshRoundInfo) public rfRound;
    mapping(uint256 => mapping(uint256 => bool)) public refreshed; 

    mapping(uint256 => address) public firstBuyerList;

    mapping(address => uint256) public vcAlreadyMinted;    // for vc sale
    mapping(address => uint256) public whiteListAlreadyMinted;    // for pre sale
    mapping(address => uint256) public alreadyMinted;    // for public sale

    mapping(address => bool) public eliteClubMember;
    mapping(address => bool) public vipClubMember;

    bytes32 public merkleRoot;

    event MakeOver(address indexed owner, uint256 newTokenId, uint256 price);
    event Refresh(address indexed owner, uint256 tokenId, uint256 price);
    event PurchaseBoxVC(address indexed user, uint256 price, uint256 number, uint256[] tokenIds);
    event PurchaseBoxPresale(address indexed user, uint256 price, uint256 number, uint256[] tokenIds);
    event PurchaseBox(address indexed user, uint256 price, uint256 number, uint256[] tokenIds);
    event OwnerMint(address indexed user, uint256 number, uint256[] tokenIds);

    IPancakeSwapRouter public pancakeRouter;
    address public bmfAddr;
    
    function initialize(IMF1155 _metafame1155) initializer public {
        __Ownable_init();
        __Pausable_init();
        __Status_init();
        metafame1155 = _metafame1155;

        maxPurchaseLimit = 150;
        maxPurchaseLimitWL = 150;
        maxPurchaseLimitVC = 150;
        _FOR_OWNER = 1112;
        _makeOver = 200000;

        _endsaled = false;

        publicSaleStart = 1656132461;
        publicSaleEnd = 1687639628;

        vcRoundNumber =  1;
        vcRound[1] = VCRoundInfo({
            startTime: 1656132461,
            endTime: 1687639628,
            limit: 100,
            alreadySaled: 0
        });

        wlRoundNumber =  1;
        wlRound[1] = RoundInfo({
            startTime: 1656132461,
            endTime: 1687639628,
            limit: 100,
            alreadySaled: 0
        });

        refreshRoundNumber =  1;
        rfRound[1] = RefreshRoundInfo({
            startTime: 1656132461,
            endTime: 1687639628,
            limit: 100,
            alreadyRefreshed: 0,
            refreshPartName1: "Shoes",
            refreshPartName2: "Gears"
        });

        //0.1 BUSD
        busdPerBox = 1 * 10**17;
        busdPerBoxWL = 1 * 10**17;
        busdPerBoxVC = 1 * 10**17;
        makeOverPrice = 1 * 10**17;
        refreshPrice = 1 * 10**17;

        merkleRoot = 0x9ef3317b70b220ac8c1af78b775fa6bafaf7530d69992c293a3173500ad78562;
        busdAddr = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
        setterAddr = 0x364272515e284E59c5a1299eb6C12A42a589193D;

    }

    function getRemainingPurchase(address user) external view returns(uint256) {
        return maxPurchaseLimit - alreadyMinted[user];
    }

    function getVCRemainingPurchase(address user) external view returns(uint256) {
        return maxPurchaseLimitVC - vcAlreadyMinted[user];
    }

    function getWLRemainingPurchase(address user, bytes32[] calldata _merkleProof) external view returns(uint256) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf) , "MetafameSale: The account is not in the whitelist");
        return maxPurchaseLimitWL - whiteListAlreadyMinted[user];
    }

    // For verification code sale
    function purchaseBoxVCsale(
        uint256 gender, 
        uint256 skin,
        uint256 number,
        string memory vcode,
        uint256 payAmount,
        uint256 payType
        ) 
        whenNotPaused 
        whenVcsaled
        nonReentrant 
        public 
        {
        require(block.timestamp >= vcRound[vcRoundNumber].startTime, "MetafameSale:Not reach the vc-sale time of this round");
        require(block.timestamp <= vcRound[vcRoundNumber].endTime, "MetafameSale: End of this round");
        require(!endsaled(), "MetafameSale: End of sale");
        require(vcRound[vcRoundNumber].alreadySaled + number <= vcRound[vcRoundNumber].limit, "MetafameSale: Reach the vc-sale limit of this round");
        require(metafame1155.getAllocatedBoxQuantity() + number <= metafame1155.getMaxSupply() - _FOR_OWNER, "Metafame1155: Reach the max supply");
        require(vcAlreadyMinted[_msgSender()] + number <= maxPurchaseLimitVC, "MetafameSale: Exceed allowed mint limit per account");
        require(gender < 2, "MetafameSale: Wrong Gender Type");
        require(skin < 4, "MetafameSale: Wrong Skin Type");
        require( keccak256(abi.encodePacked(vcode)) == keccak256(abi.encodePacked(_vcode)), "MetafameSale: Wrong verification code");

        uint256[] memory tokenIDArray = new uint256[](number);
        uint256 price;

        require(payAmount >= busdPerBoxVC * 10**18 * number, "Insufficient/Wrong BUSD");
        price = busdPerBoxVC * number;
        payToken(price, payType);
        eliteClubMember[_msgSender()] = true;
        vcAlreadyMinted[_msgSender()] += number;
        vcRound[vcRoundNumber].alreadySaled += number;
        
        uint256 tokenId;
        for(uint256 i=0; i<number ; i++){
            tokenId = _mintBox(_msgSender(), gender, skin);
            firstBuyerList[tokenId] = _msgSender();
            tokenIDArray[i] = tokenId;
        }
        emit PurchaseBoxVC(msg.sender, price, number, tokenIDArray);
    }

    // For wl presale
    function purchaseBoxPresale(
        uint256 gender, 
        uint256 skin,
        uint256 number,
        bytes32[] calldata _merkleProof,
        uint256 payAmount,
        uint256 payType
        ) 
        whenNotPaused 
        whenPresaled 
        nonReentrant 
        public 
        {
        require(block.timestamp >= wlRound[wlRoundNumber].startTime, "MetafameSale: Not reach the whistList-sale time of this round");
        require(block.timestamp <= wlRound[wlRoundNumber].endTime, "MetafameSale: End of this round");
        require(!endsaled(), "MetafameSale: End of sale");
        require(wlRound[wlRoundNumber].alreadySaled + number <= wlRound[wlRoundNumber].limit, "MetafameSale: Reach the whistList-sale limit of this round");
        require(metafame1155.getAllocatedBoxQuantity() + number <= metafame1155.getMaxSupply() - _FOR_OWNER, "Metafame1155: Reach the max supply");
        require(whiteListAlreadyMinted[_msgSender()] + number <= maxPurchaseLimitWL, "MetafameSale: Exceed allowed mint limit per account");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf) , "MetafameSale: The account is not in the whitelist");
        require(gender < 2, "MetafameSale: Wrong Gender Type");
        require(skin < 4, "MetafameSale: Wrong Skin Type");

        uint256[] memory tokenIDArray = new uint256[](number);
        uint256 price;

        require(payAmount >= busdPerBoxWL * 10**18 * number, "Insufficient/Wrong BUSD");
        price = busdPerBoxWL * number;
        payToken(price, payType);
        eliteClubMember[_msgSender()] = true;
        whiteListAlreadyMinted[_msgSender()] += number;
        wlRound[wlRoundNumber].alreadySaled += number;
        
        uint256 tokenId;
        for(uint256 i=0; i<number ; i++){
            tokenId = _mintBox(_msgSender(), gender, skin);
            firstBuyerList[tokenId] = _msgSender();
            tokenIDArray[i] = tokenId;
        }

        emit PurchaseBoxPresale(msg.sender, price, number, tokenIDArray);

    }

    //For public sale
    function purchaseBoxPublicSale(
        uint256 gender,
        uint256 skin,
        uint256 number,
        uint256 payAmount,
        uint256 payType
        ) 
        whenNotPaused 
        whenPublicsaled
        nonReentrant 
        external 
        {
        require(block.timestamp >= publicSaleStart, "MetafameSale: Not reach public-sale time");
        require(block.timestamp <= publicSaleEnd, "Status: End of public-sale");
        require(!endsaled(), "Status: End of sale");
        require(metafame1155.getAllocatedBoxQuantity() + number <= metafame1155.getMaxSupply() - _FOR_OWNER, "Metafame1155: Reach the max supply");
        require(alreadyMinted[msg.sender] + number <= maxPurchaseLimit, "MetafameSale: Exceed allowed mint limit per account");
        require(gender < 2, "MetafameSale: Wrong Gender Type");
        require(skin < 4, "MetafameSale: Wrong Skin Type");

        uint256[] memory tokenIDArray = new uint256[](number);
        uint256 price;

        require(payAmount >= busdPerBox * 10**18 * number, "Insufficient/Wrong BUSD");
        price = busdPerBox * number;
        payToken(price, payType);
        alreadyMinted[address(msg.sender)] += number;
        eliteClubMember[_msgSender()] = true;

        uint256 tokenId;
        for(uint256 i=0; i<number ; i++){
            tokenId = _mintBox(_msgSender(), gender, skin);
            firstBuyerList[tokenId] = _msgSender();
            tokenIDArray[i] = tokenId;
        }

        emit PurchaseBox(msg.sender, price, number, tokenIDArray);

    }

    function _mintBox(
        address to,
        uint256 gender,
        uint256 skin
        ) 
        whenNotPaused
        private 
        returns (uint256)
        {
        uint256 tokenId = metafame1155.getStepOneIdCounter();

        metafame1155.mint(to, tokenId, 1, gender, skin);
        return tokenId;
    }

    function makeOver( 
        uint256 tokenId,
        uint256 payAmount,
        uint256 payType
        ) 
        whenNotPaused 
        whenMakeover
        nonReentrant
        existenceCheck(_msgSender(), tokenId) 
        public 
        returns(uint256)
        {
        require(tokenId <= metafame1155.getMaxSupply(), "MetafameSale: No more level to upgrade");
        require(payAmount >= makeOverPrice * 10**18, "Insufficient pay amount");
        uint256 newTokenId = tokenId + _makeOver;
        uint256 finalPrice = payToken(makeOverPrice, payType);
        metafame1155.mintAndBurn(_msgSender(), tokenId, newTokenId);
        vipClubMember[_msgSender()] = true;
        emit MakeOver(_msgSender(), newTokenId, finalPrice);
        return newTokenId;
    }

    function refresh( 
        uint256 tokenId,
        uint256 payAmount,
        uint256 payType
        ) 
        whenNotPaused 
        whenRefresh
        nonReentrant
        existenceCheck(_msgSender(), tokenId) 
        public 
        {
        require(block.timestamp >= rfRound[refreshRoundNumber].startTime, "MetafameSale: Not reach the refresh time of this round");
        require(block.timestamp <= rfRound[refreshRoundNumber].endTime, "MetafameSale: End of this round");
        require(rfRound[refreshRoundNumber].alreadyRefreshed  <= rfRound[refreshRoundNumber].limit, "MetafameSale: Reach the refresh limit of this round");
        require(refreshed[tokenId][refreshRoundNumber] == false, "MetafameSale: This NFT was refreshed in this round");
        require(payAmount >= refreshPrice * 10**18, "Insufficient pay amount");
        uint256 finalPrice = payToken(refreshPrice, payType);
        metafame1155.setRefreshTimes(tokenId);
        refreshed[tokenId][refreshRoundNumber] = true;
        rfRound[refreshRoundNumber].alreadyRefreshed += 1;
        emit Refresh(_msgSender(), tokenId, finalPrice);
    }

    function payToken(uint256 price, uint256 payType) private returns (uint256 finalPrice){
     
        if(payType == 0){
            IERC20Upgradeable currency = IERC20Upgradeable(busdAddr);
            finalPrice = price * 10**18;
            currency.safeTransferFrom(address(msg.sender), payable(address(owner())), finalPrice);
            return finalPrice;
        }
        if(payType == 1){
            address[] memory path = new address[](2);
            path[0] = bmfAddr;
            path[1] = busdAddr;

            IERC20Upgradeable currency = IERC20Upgradeable(bmfAddr);
            
            uint256 amountIn = getAmountsIn(price, path); 
            finalPrice = amountIn * 10**18; 

            currency.safeTransferFrom(address(msg.sender), payable(address(owner())), finalPrice);

            return finalPrice;
        }
    
    }

    function publicsale() public onlyOwner {
        _publicsale();
    }

    function unpublicsale() public onlyOwner{
        _unpublicsale();
    }

    function presale() public onlyOwner {
        _presale();
    }

    function unpresale() public onlyOwner{
        _unpresale();
    }

    function vcsale() public onlyOwner {
        _vcsale();
    }

    function unvcsale() public onlyOwner{
        _unvcsale();
    }

    function makeoverStart() public onlyOwner {
        _makeoverStart();
    }

    function makeoverStop() public onlyOwner{
        _makeoverStop();
    }

    function refreshStart() public onlyOwner {
        _refreshStart();
    }

    function refreshStop() public onlyOwner{
        _refreshStop();
    }

    function pause() onlyOwner public  {
        _pause();
        metafame1155.pause();
    }

    function unpause() onlyOwner public {
        _unpause();
        metafame1155.unpause();
    }

    function endsale() onlyOwner public  {
        _endsaled = true;
    }
    
    function unEndsale() onlyOwner public {
        _endsaled = false;
    }
    // get endsale status
    function endsaled() public view virtual returns (bool) {
        return _endsaled;
    }

    function getRemainingBoxQuantity() external view returns(uint256){
        return metafame1155.getRemainingBoxQuantity();
    }

    function getAllocatedBoxQuantity() external view returns(uint256) {
        return metafame1155.getAllocatedBoxQuantity();
    }

    function getMaxSupply() external view returns(uint256) {
        return metafame1155.getMaxSupply();
    }
    
    function getStepOneIdCounter() external view returns (uint256) {
        return metafame1155.getStepOneIdCounter();
    } 

    function getBalanceOf(address account, uint256 id) external view returns (uint256) {
        return metafame1155.getBalanceOf(account, id);
    }

    function getWLRoundStartTime(uint256 roundNumber) external view returns (uint256) {
        return wlRound[roundNumber].startTime;
    }

    function getWLRoundEndTime(uint256 roundNumber) external view returns (uint256) {
        return wlRound[roundNumber].endTime;
    }

    function getWLRoundSaleLimit(uint256 roundNumber) onlyOwner external view returns (uint256) {
        return wlRound[roundNumber].limit;
    }

    function getWLRoundSaled(uint256 roundNumber) onlyOwner external view returns (uint256) {
        return wlRound[roundNumber].alreadySaled;
    }

    function getVCRoundStartTime(uint256 roundNumber) external view returns (uint256) {
        return vcRound[roundNumber].startTime;
    }

    function getVCRoundEndTime(uint256 roundNumber) external view returns (uint256) {
        return vcRound[roundNumber].endTime;
    }

    function getRefreshRoundStartTime(uint256 roundNumber) external view returns (uint256) {
        return rfRound[roundNumber].startTime;
    }

    function getRefreshRoundEndTime(uint256 roundNumber) external view returns (uint256) {
        return rfRound[roundNumber].endTime;
    }

    function getVcode() onlyOwner external view returns (string memory) {
        return _vcode;
    }

    function ownerMint(
        address to,
        uint256 gender, 
        uint256 skin,
        uint256 number
        ) 
        onlyOwner
        public 
        {
        require(metafame1155.getAllocatedBoxQuantity() <= metafame1155.getMaxSupply(), "Metafame1155: No more box can be minted");
        require(gender < 2, "MetafameSale: Wrong Gender Type");
        require(skin < 4, "MetafameSale: Wrong Skin Type");

        uint256[] memory tokenIDArray = new uint256[](number);

        uint256 tokenId;
        
        for(uint256 i=0; i<number ; i++){
            tokenId = _mintBox(to, gender, skin);
            tokenIDArray[i] = tokenId;
        }

        emit OwnerMint(msg.sender, number, tokenIDArray);
    }

    function setBUSDPerBox(uint256 saleType, uint256 newPrice) onlyOwner whenPaused public {
        if(saleType == 0){
            busdPerBoxWL = newPrice;
        }
        else if(saleType == 1){
            busdPerBox = newPrice;
        }  
        else{
            busdPerBoxVC = newPrice;
        }
    }

    function setMakeOverPrice(uint256 newPrice) onlyOwner whenPaused public {
        makeOverPrice = newPrice;
    }

    function setRefreshPrice(uint256 newPrice) onlyOwner whenPaused public {
        refreshPrice = newPrice;
    }

    function setMaxPurchaseLimit(uint256 limit) onlyOwner whenPaused public {
        maxPurchaseLimit = limit;
    }

    function setMaxPurchaseLimitWL(uint256 limit) onlyOwner whenPaused public {
        maxPurchaseLimitWL = limit;
    }

    function setMaxPurchaseLimitVC(uint256 limit) onlyOwner whenPaused public {
        maxPurchaseLimitVC = limit;
    }

    function setOwnerMintAmount(uint256 limit) onlyOwner whenPaused public {
        _FOR_OWNER = limit;
    }

    function setVCRoundNumber(uint256 roundNumber) onlyOwner whenPaused public {
        vcRoundNumber = roundNumber;
    }

    function setVCRoundInfo(uint256 roundNumber, uint256 _startTime, uint256 _endTime, uint256 _limit) onlyOwner whenPaused public {
        vcRound[roundNumber] = VCRoundInfo({
            startTime: _startTime,
            endTime: _endTime,
            limit: _limit,
            alreadySaled: 0
        });
    }

    function setVCRoundTime(uint256 roundNumber, uint256 _startTime, uint256 _endTime) onlyOwner whenPaused public {
        vcRound[roundNumber].startTime = _startTime;
        vcRound[roundNumber].endTime = _endTime;
    }

    function setVCRoundLimit(uint256 roundNumber, uint256 _limit) onlyOwner whenPaused public {
        vcRound[roundNumber].limit = _limit;
    }

    function setWlRoundNumber(uint256 roundNumber) onlyOwner whenPaused public {
        wlRoundNumber = roundNumber;
    }

    function setWlRoundInfo(uint256 roundNumber, uint256 _startTime, uint256 _endTime, uint256 _limit) onlyOwner whenPaused public {
        wlRound[roundNumber] = RoundInfo({
            startTime: _startTime,
            endTime: _endTime,
            limit: _limit,
            alreadySaled: 0
        });
    }

    function setWlRoundTime(uint256 roundNumber, uint256 _startTime, uint256 _endTime) onlyOwner whenPaused public {
        wlRound[roundNumber].startTime = _startTime;
        wlRound[roundNumber].endTime = _endTime;
    }

    function setWlRoundLimit(uint256 roundNumber, uint256 _limit) onlyOwner whenPaused public {
        wlRound[roundNumber].limit = _limit;
    }

    function setRefreshRoundNumber(uint256 roundNumber) onlyOwner whenPaused public {
        refreshRoundNumber = roundNumber;
    }

    function setRefreshRoundInfo(
        uint256 roundNumber,
        uint256 _startTime, 
        uint256 _endTime, 
        uint256 _limit,
        string memory _refreshPartName1,
        string memory _refreshPartName2
        ) 
        onlyOwner 
        whenPaused 
        public 
        {
        rfRound[roundNumber] = RefreshRoundInfo({
            startTime: _startTime,
            endTime: _endTime,
            limit: _limit,
            alreadyRefreshed: 0,
            refreshPartName1: _refreshPartName1,
            refreshPartName2: _refreshPartName2
        });
    }

    function setRefreshRoundTime(uint256 roundNumber, uint256 _startTime, uint256 _endTime) onlyOwner whenPaused public {
        rfRound[roundNumber].startTime = _startTime;
        rfRound[roundNumber].endTime = _endTime;
    }

    function setRefreshRoundLimit(uint256 roundNumber, uint256 _limit) onlyOwner whenPaused public {
        rfRound[roundNumber].limit = _limit;
    }

    function setRefreshRoundPartName(uint256 roundNumber,uint256 step, string memory partName) onlyOwner whenPaused public {
        if(step == 1){
            rfRound[roundNumber].refreshPartName1 = partName;
        }
        if(step == 2){
            rfRound[roundNumber].refreshPartName2 = partName;
        }
    }

    function setPublicSaleStart(uint256 _publicSaleStart) onlyOwner whenPaused public{
        publicSaleStart = _publicSaleStart;
    }
    function setPublicSaleEnd(uint256 _publicSaleEnd) onlyOwner whenPaused public{
        publicSaleEnd = _publicSaleEnd;
    }

    function set1155Address(IMF1155 _metafame1155) onlyOwner whenPaused public {
        metafame1155 = _metafame1155;
    }

    function setMerkleRoot(bytes32 root) onlyOwner whenPaused public {
        merkleRoot = root;
    }

    function setVcode(string memory newVcode) onlyOwner whenPaused public {
        _vcode = newVcode;
    }

    function setDNA(uint256 tokenId, string memory itemsDNA, string memory layersDNA) public {
        require(owner() == _msgSender() || setterAddr == _msgSender(), "Metafame: caller is not the owner/setter");
        metafame1155.setRefreshDNA(tokenId, itemsDNA, layersDNA);
    }

    function setDNARefreshTimes(uint256 tokenId) public {
        require(owner() == _msgSender() || setterAddr == _msgSender(), "Metafame: caller is not the owner/setter");
        metafame1155.setRefreshTimes(tokenId);
    }

    function setSetterAddr(address _addr) onlyOwner whenPaused public {
        setterAddr = _addr;
    }

    function setBUSDAddr(address _addr) onlyOwner whenPaused public {
        busdAddr = _addr;
    }

    function setBMFAddr(address _addr) onlyOwner whenPaused public {
        bmfAddr = _addr;
    }

    function setPswapAddr(address _addr) onlyOwner whenPaused public {
        pancakeRouter = IPancakeSwapRouter(_addr);
    }

    function getTokenBuyerByRange(uint256 from, uint256 to) onlyOwner public view returns(address[] memory){
        address[] memory addresses = new address[]((to+1) - from);
        uint256 j = 0;
        for (uint256 i = from; i <= to ; ++i) {
            addresses[j] = firstBuyerList[i];
            j++;
        }
        return addresses;
    }
   
    modifier existenceCheck(address account, uint256 tokenId) {
        require(metafame1155.getBalanceOf(account, tokenId) != 0, "ERC1155Metadata: query for nonexistent/not your token");
        _;
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) public virtual view returns (uint256 amountsIn) {
        uint256[] memory amounts = pancakeRouter.getAmountsIn(amountOut, path);
        amountsIn = amounts[0];
    }

}

interface IPancakeSwapRouter {
    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
}