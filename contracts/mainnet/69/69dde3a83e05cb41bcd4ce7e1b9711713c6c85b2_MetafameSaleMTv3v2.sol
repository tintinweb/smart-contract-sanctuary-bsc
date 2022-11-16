/**
 *Submitted for verification at BscScan.com on 2022-11-16
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


// File @openzeppelin/contracts-upgradeable/security/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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


// File contracts/MetafameSale_MT.sol


pragma solidity ^0.8.10;









abstract contract Status is ContextUpgradeable {

    bool public publicsaleStatus;
    bool public presaleStatus;
    bool public makeoverStatus;
    bool public refreshStatus;

    function __Status_init() internal {
        publicsaleStatus = false;
        presaleStatus = false;
        makeoverStatus = false;
        refreshStatus = false;
    }

    function _publicsaleable() internal virtual  {
        publicsaleStatus = !publicsaleStatus;
    }

    function _presaleable() internal virtual  {
        presaleStatus = !presaleStatus;
    }

    function _makeoverable() internal virtual  {
        makeoverStatus = !makeoverStatus;
    }

    function _refreshable() internal virtual  {
        refreshStatus = !refreshStatus;
    }

    modifier whenPublicsaled() {
        require(publicsaleStatus == true, "Status: not publicsale");
        _;
    }

    modifier whenPresaled() {
        require(presaleStatus == true, "Status: not presale");
        _;
    }

    modifier whenMakeover() {
        require(makeoverStatus == true, "Status: not makeover");
        _;
    }

    modifier whenRefresh() {
        require(refreshStatus == true, "Status: not refresh");
        _;
    }
}

interface IMF721 {
    function mint(address to, uint256 tokenId, uint256 gender, uint256 skin, uint256 tier) external;
    function mintAndBurn(address account, uint256 tokenId,uint256 newTokenId) external;
    function setRefreshDNA(uint256 tokenId, string memory itemsDNA, string memory layersDNA) external;
    function setRefreshTimes(uint256 tokenId) external;
    function getRemainingBoxQuantity() external view returns(uint256);
    function getAllocatedBoxQuantity() external view returns(uint256);
    function getMaxSupply() external view returns(uint256);
    function getStepOneIdCounter() external view returns (uint256);
    function ownerOf(uint256 id) external view returns (address);
    function getTier(uint256 tokenId) external view returns (uint256);
    function pause() external;
    function unpause() external;
}

interface IPancakeSwapRouter {
    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);
}

contract MetafameSaleMTv3v2 is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, PausableUpgradeable, Status{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    
    uint256 public _FOR_OWNER;
    uint256 public _makeOver;

    IMF721 public metafame721;
    IPancakeSwapRouter public pancakeRouter;
    address public busdAddr;
    address public bmfAddr;
    address public setterAddr;
    
    uint256 public maxPurchaseLimit;
    uint256 public maxPurchaseLimitWL;

    mapping(uint256 => uint256) public busdPerBox;
    mapping(uint256 => uint256) public busdPerBoxWL;
    mapping(uint256 => uint256) public makeOverPrice;
    mapping(uint256 => uint256) public refreshPrice;

    uint256 public publicSaleStart;
    uint256 public publicSaleEnd;

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

    mapping(uint256 => address) public firstBuyerList;
  
    mapping(address => uint256) public whiteListAlreadyMinted;    
    mapping(address => uint256) public alreadyMinted;   

    mapping(address => bool) public eliteClubMember;
    mapping(address => bool) public vipClubMember;

    bytes32 public merkleRoot;

    uint256 public publishDNAPrice;
    mapping(uint256 => bool) public payCreditOfPublishDNA;
    event PublishDNA(address indexed owner, uint256 tokenId, uint256 price);

    struct TierInfo {
        uint256 limit;
        uint256 counter;
    }
    mapping(uint256 => TierInfo) public tiers;

    event MakeOver(address indexed owner, uint256 newTokenId, uint256 price);
    event Refresh(address indexed owner, uint256 tokenId, uint256 price);
    event PurchaseBoxPresale(address indexed user, uint256 price, uint256 number, uint256[] tokenIds);
    event PurchaseBox(address indexed user, uint256 price, uint256 number, uint256[] tokenIds);
    event OwnerMint(address indexed user, uint256 number, uint256[] tokenIds);

    function initialize(IMF721 _metafame721) initializer public {
        __Ownable_init();
        __Pausable_init();
        __Status_init();
        metafame721 = _metafame721;
        //testnet: 0xe25751c41187eE5e2b1b4376d7A18F3d82c94c46
        //mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
        busdAddr = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
        //testnet: 0xBb20e69d26bd1BD8D94af928B6f3D4A5625CC909
        //mainnet: 0x54c159b71262878Bf096b45a3c6A8FD0a3250B10
        bmfAddr = 0x54c159b71262878Bf096b45a3c6A8FD0a3250B10;
        setterAddr = 0x364272515e284E59c5a1299eb6C12A42a589193D;
        //testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        pancakeRouter = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        maxPurchaseLimit = 100;
        _FOR_OWNER = 1112;
        _makeOver = 2000000;

        publicSaleStart = 1668744000;
        publicSaleEnd = 1668787200;

        busdPerBox[1] = 250;
        busdPerBox[2] = 100;
        busdPerBox[3] = 10;

        tiers[1].limit = 500;  
        tiers[2].limit = 0;  
        tiers[3].limit = 0;  

    }

    function purchaseBoxPresale(
        uint256 gender, 
        uint256 skin,
        bytes32[] calldata _merkleProof,
        uint256 payAmount,
        uint256 payType,
        uint256 tier
        ) 
        whenNotPaused 
        whenPresaled 
        nonReentrant 
        typeCheck(gender, skin, tier)
        payCheck(payType)
        public 
        {
        require(block.timestamp >= wlRound[wlRoundNumber].startTime, "MetafameSale: Not reach the whistList-sale time of this round");
        require(block.timestamp <= wlRound[wlRoundNumber].endTime, "MetafameSale: End of this round");
        require(tiers[tier].counter + 1 <= tiers[tier].limit, "MetafameSale: Reach the tier limit");
        require(wlRound[wlRoundNumber].alreadySaled + 1 <= wlRound[wlRoundNumber].limit, "MetafameSale: Reach the whistList-sale limit of this round");
        require(metafame721.getAllocatedBoxQuantity() + 1 <= metafame721.getMaxSupply() - _FOR_OWNER, "Metafame721: Reach the max supply");
        require(whiteListAlreadyMinted[_msgSender()] + 1 <= maxPurchaseLimitWL, "MetafameSale: Exceed allowed mint limit per account");
        require(MerkleProof.verify(_merkleProof, merkleRoot, getLeaf(msg.sender)) , "MetafameSale: The account is not in the whitelist");
        require(busdPerBoxWL[tier] > 0, "MetafameSale: Price problem");
        
        uint256[] memory tokenIDArray = new uint256[](2);
        uint256 finalPrice;
        if(payType == 1){
            uint256 amountIn = getAmountsIn(busdPerBoxWL[tier]); 
            require(payAmount >= amountIn * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = amountIn * 10**18;
            payToken(finalPrice, payType);
        }
        else if(payType == 0){
            require(payAmount >= busdPerBoxWL[tier] * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = payToken(busdPerBoxWL[tier], payType);
        }

        eliteClubMember[_msgSender()] = true;
        whiteListAlreadyMinted[_msgSender()] += 1;
        wlRound[wlRoundNumber].alreadySaled += 1;
        
        uint256 tokenId;
        tokenId = _mintBox(_msgSender(), gender, skin, tier);
        firstBuyerList[tokenId] = _msgSender();
        tokenIDArray[0] = tokenId;
        tiers[tier].counter += 1;

        emit PurchaseBoxPresale(msg.sender, busdPerBoxWL[tier] * 10**18, 1, tokenIDArray);
    }

    function purchaseBoxPublicSale(
        uint256 gender,
        uint256 skin,
        uint256 payAmount,
        uint256 payType,
        uint256 tier
        ) 
        whenNotPaused 
        whenPublicsaled
        nonReentrant 
        typeCheck(gender, skin, tier)
        payCheck(payType)
        external 
        {
        require(block.timestamp >= publicSaleStart, "MetafameSale: Not reach public-sale time");
        require(block.timestamp <= publicSaleEnd, "Status: End of public-sale");
        require(tiers[tier].counter + 1 <= tiers[tier].limit, "MetafameSale: Reach the tier limit");
        require(metafame721.getAllocatedBoxQuantity() + 1 <= metafame721.getMaxSupply() - _FOR_OWNER, "Metafame721: Reach the max supply");
        require(alreadyMinted[msg.sender] + 1 <= maxPurchaseLimit, "MetafameSale: Exceed allowed mint limit per account");
        require(busdPerBox[tier] > 0, "MetafameSale: Price problem");
        
        uint256[] memory tokenIDArray = new uint256[](2);
        uint256 finalPrice;
        if(payType == 1){
            uint256 amountIn = getAmountsIn(busdPerBox[tier]); 
            require(payAmount >= amountIn * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = amountIn * 10**18;
            payToken(finalPrice, payType);
        }
        else if(payType == 0){
            require(payAmount >= busdPerBox[tier] * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = payToken(busdPerBox[tier], payType);
        }

        alreadyMinted[address(msg.sender)] += 1;
        eliteClubMember[_msgSender()] = true;

        uint256 tokenId;
        tokenId = _mintBox(_msgSender(), gender, skin, tier);
        firstBuyerList[tokenId] = _msgSender();
        tokenIDArray[0] = tokenId;
        tiers[tier].counter += 1;

        emit PurchaseBox(msg.sender, busdPerBox[tier] * 10**18, 1, tokenIDArray);
    }

    function _mintBox(
        address to,
        uint256 gender,
        uint256 skin,
        uint256 tier
        ) 
        whenNotPaused
        private 
        returns (uint256)
        {
        uint256 tokenId = metafame721.getStepOneIdCounter();
        metafame721.mint(to, tokenId, gender, skin, tier);
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
        payCheck(payType)
        public 
        returns(uint256)
        {
        require(tokenId <= metafame721.getMaxSupply(), "MetafameSale: No more level to upgrade");
        uint256 tier = metafame721.getTier(tokenId);
        require(makeOverPrice[tier] > 0, "MetafameSale: Price problem");

        uint256 finalPrice;
        if(payType == 1){
            uint256 amountIn = getAmountsIn(makeOverPrice[tier]); 
            require(payAmount >= amountIn * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = amountIn * 10**18;
            payToken(finalPrice, payType);
        }
        else if(payType == 0){
            require(payAmount >= makeOverPrice[tier] * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = payToken(makeOverPrice[tier], payType);
        }
        
        uint256 newTokenId = tokenId + _makeOver;
        metafame721.mintAndBurn(_msgSender(), tokenId, newTokenId);
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
        payCheck(payType)
        public 
        {
        require(block.timestamp >= rfRound[refreshRoundNumber].startTime, "MetafameSale: Not reach the refresh time of this round");
        require(block.timestamp <= rfRound[refreshRoundNumber].endTime, "MetafameSale: End of this round");
        require(rfRound[refreshRoundNumber].alreadyRefreshed  <= rfRound[refreshRoundNumber].limit, "MetafameSale: Reach the refresh limit of this round");
        uint256 tier = metafame721.getTier(tokenId);
        require(refreshPrice[tier] > 0, "MetafameSale: Price problem");

        uint256 finalPrice;
        if(payType == 1){
            uint256 amountIn = getAmountsIn(refreshPrice[tier]); 
            require(payAmount >= amountIn * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = amountIn * 10**18;
            payToken(finalPrice, payType);
        }
        else if(payType == 0){
            require(payAmount >= refreshPrice[tier] * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = payToken(refreshPrice[tier], payType);
        }

        metafame721.setRefreshTimes(tokenId);
        rfRound[refreshRoundNumber].alreadyRefreshed += 1;
        payCreditOfPublishDNA[tokenId] = true;
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
            IERC20Upgradeable currency = IERC20Upgradeable(bmfAddr);
            finalPrice = price;
            currency.safeTransferFrom(address(msg.sender), payable(address(owner())), finalPrice);
            return finalPrice;
        }
    }

    function getLeaf(address sender) internal pure returns(bytes32){
        bytes32 leaf = keccak256(abi.encodePacked(sender));
        return leaf;
    }

    function publicsaleable() public onlyOwner {
        _publicsaleable();
    }

    function presaleable() public onlyOwner {
        _presaleable();
    }

    function makeoverable() public onlyOwner {
        _makeoverable();
    }

    function refreshable() public onlyOwner {
        _refreshable();
    }

    function pause() onlyOwner public  {
        _pause();
        metafame721.pause();
    }

    function unpause() onlyOwner public {
        _unpause();
        metafame721.unpause();
    }

    function getRemainingBoxQuantity() external view returns(uint256){
        return metafame721.getRemainingBoxQuantity();
    }

    function getAllocatedBoxQuantity() external view returns(uint256) {
        return metafame721.getAllocatedBoxQuantity();
    }

    function getMaxSupply() external view returns(uint256) {
        return metafame721.getMaxSupply();
    }
    
    function getStepOneIdCounter() external view returns (uint256) {
        return metafame721.getStepOneIdCounter();
    } 

    function getOwnerOf(uint256 id) external view returns (address) {
        return metafame721.ownerOf(id);
    }

    function getAmountsIn(
        uint256 amountOut
    ) public virtual view returns (uint256 amountsIn) {
        address[] memory path = new address[](2);
        path[0] = bmfAddr;
        path[1] = busdAddr;
        uint256[] memory amounts = pancakeRouter.getAmountsIn(amountOut, path);
        amountsIn = amounts[0];
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

    function getRemainingPurchase(address user) external view returns(uint256) {
        return maxPurchaseLimit - alreadyMinted[user];
    }

    function getWLRemainingPurchase(address user, bytes32[] calldata _merkleProof) external view returns(uint256) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf) , "MetafameSale: The account is not in the whitelist");
        return maxPurchaseLimitWL - whiteListAlreadyMinted[user];
    }

    function setBUSDPerBox(uint256 saleType, uint256 tier, uint256 newPrice) onlyOwner whenPaused public {
        if(saleType == 0){
            busdPerBoxWL[tier] = newPrice;
        }
        if(saleType == 1){
            busdPerBox[tier] = newPrice;
        }
    }

    function setMakeOverPrice(uint256 newPrice, uint256 tier) onlyOwner whenPaused public {
        makeOverPrice[tier] = newPrice;
    }

    function setRefreshPrice(uint256 newPrice, uint256 tier) onlyOwner whenPaused public {
        refreshPrice[tier] = newPrice;
    }

    function setMaxPurchaseLimit(uint256 limit) onlyOwner whenPaused public {
        maxPurchaseLimit = limit;
    }

    function setMaxPurchaseLimitWL(uint256 limit) onlyOwner whenPaused public {
        maxPurchaseLimitWL = limit;
    }

    function setOwnerMintAmount(uint256 limit) onlyOwner whenPaused public {
        _FOR_OWNER = limit;
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

    function set721Address(IMF721 _metafame721) onlyOwner whenPaused public {
        metafame721 = _metafame721;
    }

    function setMerkleRoot(bytes32 root) onlyOwner whenPaused public {
        merkleRoot = root;
    }

    function setMakeoverNum(uint256 newMakeoverNum) onlyOwner whenPaused public {
        _makeOver = newMakeoverNum;
    }

    function setDNA(uint256 tokenId, string memory itemsDNA, string memory layersDNA) public {
        require(owner() == _msgSender() || setterAddr == _msgSender(), "Metafame: caller is not the owner/setter");
        metafame721.setRefreshDNA(tokenId, itemsDNA, layersDNA);
        payCreditOfPublishDNA[tokenId] = false;
    }

    function setDNARefreshTimes(uint256 tokenId) public {
        require(owner() == _msgSender() || setterAddr == _msgSender(), "Metafame: caller is not the owner/setter");
        metafame721.setRefreshTimes(tokenId);
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

    function setTierLimit(uint256 tier, uint256 newLimit) onlyOwner whenPaused public {
        tiers[tier].limit = newLimit;
    }

    function setPublishDNAPrice(uint256 newPrice) onlyOwner whenPaused public {
        publishDNAPrice = newPrice;
    }

    function payToPublishDNA(
        uint256 tokenId,
        uint256 payAmount,
        uint256 payType
        ) 
        whenNotPaused 
        nonReentrant
        existenceCheck(_msgSender(), tokenId)
        payCheck(payType)
        public 
        {
        require(payCreditOfPublishDNA[tokenId] = false, "MetafameSale: You already paid");
        uint256 finalPrice;
        if(payType == 1){
            uint256 amountIn = getAmountsIn(publishDNAPrice); 
            require(payAmount >= amountIn * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = amountIn * 10**18;
            payToken(finalPrice, payType);
        }
        else{
            require(payAmount >= publishDNAPrice * 10**18, "MetafameSale: Insufficient pay amount");
            finalPrice = payToken(publishDNAPrice, payType);
        }
        metafame721.setRefreshTimes(tokenId);
        payCreditOfPublishDNA[tokenId] = true;
        emit PublishDNA(_msgSender(), tokenId, finalPrice);
    }

    modifier existenceCheck(address owner, uint256 tokenId) {
        require(metafame721.ownerOf(tokenId) == owner, "ERC721Metadata: query for nonexistent/not your token");
        _;
    }

    modifier typeCheck(uint256 gender, uint256 skin, uint256 tier) {
        require(gender < 2, "MetafameSale: Wrong Gender Type");
        require(skin < 4, "MetafameSale: Wrong Skin Type");
        require(tier < 4 && tier > 0, "MetafameSale: Wrong Tier Type");
        _;
    }

    modifier payCheck(uint256 payType) {
        require(payType < 2, "MetafameSale: Wrong Pay Type");
        _;
    }

    function ownerMint(
        address to,
        uint256 gender, 
        uint256 skin,
        uint256 number,
        uint256 tier
        ) 
        onlyOwner
        typeCheck(gender, skin, tier)
        public 
        {
        require(metafame721.getAllocatedBoxQuantity() <= metafame721.getMaxSupply(), "Metafame721: No more box can be minted");
        uint256[] memory tokenIDArray = new uint256[](number);
        uint256 tokenId;
        
        for(uint256 i=0; i<number ; i++){
            tokenId = _mintBox(to, gender, skin, tier);
            tokenIDArray[i] = tokenId;
        }

        emit OwnerMint(msg.sender, number, tokenIDArray);
    }
}