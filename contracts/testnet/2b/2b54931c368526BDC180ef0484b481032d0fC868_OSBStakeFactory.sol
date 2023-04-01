// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Multicall.sol)

pragma solidity ^0.8.0;

import "./AddressUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * _Available since v4.1._
 */
abstract contract MulticallUpgradeable is Initializable {
    function __Multicall_init() internal onlyInitializing {
    }

    function __Multicall_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = _functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
    @title ERC-1155 Multi Token Standard
    @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md
    Note: The ERC-165 identifier for this interface is 0xd9b67a26.
 */
interface IERC1155 {
    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be msg.sender.
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_id` argument MUST be the token type being transferred.
        The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be msg.sender.
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_ids` argument MUST be the list of tokens being transferred.
        The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    /**
        @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absense of an event assumes disabled).
    */
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /**
        @dev MUST emit when the URI is updated for a token ID.
        URIs are defined in RFC 3986.
        The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    */
    event URI(string _value, uint256 indexed _id);

    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external;

    /**
        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if length of `_ids` is not the same as length of `_values`.
        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
        MUST revert on any other error.
        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _ids     IDs of each token type (order and length must match _values array)
        @param _values  Transfer amounts per token type (order and length must match _ids array)
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`
    */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    /**
        @notice Get the balance of an account's Tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the Token
        @return        The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    /**
        @notice Get the balance of multiple account/token pairs
        @param _owners The addresses of the token holders
        @param _ids    ID of the Tokens
        @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param _owner     The owner of the Tokens
        @param _operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @title ERC20Metadata interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./interface/IContractMetadata.sol";

/**
 *  @title   Contract Metadata
 *  @notice  Thirdweb's `ContractMetadata` is a contract extension for any base contracts. It lets you set a metadata URI
 *           for you contract.
 *           Additionally, `ContractMetadata` is necessary for NFT contracts that want royalties to get distributed on OpenSea.
 */

abstract contract ContractMetadata is IContractMetadata {
    /// @notice Returns the contract metadata URI.
    string public override contractURI;

    /**
     *  @notice         Lets a contract admin set the URI for contract-level metadata.
     *  @dev            Caller should be authorized to setup contractURI, e.g. contract admin.
     *                  See {_canSetContractURI}.
     *                  Emits {ContractURIUpdated Event}.
     *
     *  @param _uri     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function setContractURI(string memory _uri) external override {
        if (!_canSetContractURI()) {
            revert("Not authorized");
        }

        _setupContractURI(_uri);
    }

    /// @dev Lets a contract admin set the URI for contract-level metadata.
    function _setupContractURI(string memory _uri) internal {
        string memory prevURI = contractURI;
        contractURI = _uri;

        emit ContractURIUpdated(prevURI, _uri);
    }

    /// @dev Returns whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view virtual returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 *  Thirdweb's `ContractMetadata` is a contract extension for any base contracts. It lets you set a metadata URI
 *  for you contract.
 *
 *  Additionally, `ContractMetadata` is necessary for NFT contracts that want royalties to get distributed on OpenSea.
 */

interface IContractMetadata {
    /// @dev Returns the metadata URI of the contract.
    function contractURI() external view returns (string memory);

    /**
     *  @dev Sets contract URI for the storefront-level metadata of the contract.
     *       Only module admin can call this function.
     */
    function setContractURI(string calldata _uri) external;

    /// @dev Emitted when the contract URI is updated.
    event ContractURIUpdated(string prevURI, string newURI);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IPermissions {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./IPermissions.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IPermissionsEnumerable is IPermissions {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * [forum post](https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296)
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

interface IStaking1155 {
    /// @dev Emitted when tokens are staked.
    event TokensStaked(address indexed staker, uint256 indexed tokenId, uint256 amount);

    /// @dev Emitted when a set of staked token-ids are withdrawn.
    event TokensWithdrawn(address indexed staker, uint256 indexed tokenId, uint256 amount);

    /// @dev Emitted when a staker claims staking rewards.
    event RewardsClaimed(address indexed staker, uint256 rewardAmount);

    /// @dev Emitted when contract admin updates timeUnit.
    event UpdatedTimeUnit(uint256 indexed _tokenId, uint256 oldTimeUnit, uint256 newTimeUnit);

    /// @dev Emitted when contract admin updates rewardsPerUnitTime.
    event UpdatedRewardsPerUnitTime(
        uint256 indexed _tokenId,
        uint256 oldRewardsPerUnitTime,
        uint256 newRewardsPerUnitTime
    );

    /// @dev Emitted when contract admin updates timeUnit.
    event UpdatedDefaultTimeUnit(uint256 oldTimeUnit, uint256 newTimeUnit);

    /// @dev Emitted when contract admin updates rewardsPerUnitTime.
    event UpdatedDefaultRewardsPerUnitTime(uint256 oldRewardsPerUnitTime, uint256 newRewardsPerUnitTime);

    /**
     *  @notice Staker Info.
     *
     *  @param amountStaked             Total number of tokens staked by the staker.
     *
     *  @param timeOfLastUpdate         Last reward-update timestamp.
     *
     *  @param unclaimedRewards         Rewards accumulated but not claimed by user yet.
     *
     *  @param conditionIdOflastUpdate  Condition-Id when rewards were last updated for user.
     */
    struct Staker {
        uint256 amountStaked;
        uint256 timeOfLastUpdate;
        uint256 unclaimedRewards;
        uint256 conditionIdOflastUpdate;
    }

    /**
     *  @notice Staking Condition.
     *
     *  @param timeUnit           Unit of time specified in number of seconds. Can be set as 1 seconds, 1 days, 1 hours, etc.
     *
     *  @param rewardsPerUnitTime Rewards accumulated per unit of time.
     *
     *  @param startTimestamp     Condition start timestamp.
     *
     *  @param endTimestamp       Condition end timestamp.
     */
    struct StakingCondition {
        uint256 timeUnit;
        uint256 rewardsPerUnitTime;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    /**
     *  @notice Stake ERC721 Tokens.
     *
     *  @param tokenId   ERC1155 token-id to stake.
     *  @param amount    Amount to stake.
     */
    function stake(uint256 tokenId, uint256 amount) external;

    /**
     *  @notice Withdraw staked tokens.
     *
     *  @param tokenId   ERC1155 token-id to withdraw.
     *  @param amount    Amount to withdraw.
     */
    function withdraw(uint256 tokenId, uint256 amount) external;

    /**
     *  @notice Claim accumulated rewards.
     *
     *  @param tokenId   Staked token Id.
     */
    function claimRewards(uint256 tokenId) external;

    /**
     *  @notice View amount staked and total rewards for a user.
     *
     *  @param tokenId   Staked token Id.
     *  @param staker    Address for which to calculated rewards.
     */
    function getStakeInfoForToken(uint256 tokenId, address staker)
        external
        view
        returns (uint256 _tokensStaked, uint256 _rewards);

    /**
     *  @notice View amount staked and total rewards for a user.
     *
     *  @param staker    Address for which to calculated rewards.
     */
    function getStakeInfo(address staker)
        external
        view
        returns (
            uint256[] memory _tokensStaked,
            uint256[] memory _tokenAmounts,
            uint256 _totalRewards
        );
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

interface IStaking20 {
    /// @dev Emitted when tokens are staked.
    event TokensStaked(address indexed staker, uint256 amount);

    /// @dev Emitted when a tokens are withdrawn.
    event TokensWithdrawn(address indexed staker, uint256 amount);

    /// @dev Emitted when a staker claims staking rewards.
    event RewardsClaimed(address indexed staker, uint256 rewardAmount);

    /// @dev Emitted when contract admin updates timeUnit.
    event UpdatedTimeUnit(uint256 oldTimeUnit, uint256 newTimeUnit);

    /// @dev Emitted when contract admin updates rewardsPerUnitTime.
    event UpdatedRewardRatio(
        uint256 oldNumerator,
        uint256 newNumerator,
        uint256 oldDenominator,
        uint256 newDenominator
    );

    /// @dev Emitted when contract admin updates minimum staking amount.
    event UpdatedMinStakeAmount(uint256 oldAmount, uint256 newAmount);

    /**
     *  @notice Staker Info.
     *
     *  @param amountStaked             Total number of tokens staked by the staker.
     *
     *  @param timeOfLastUpdate         Last reward-update timestamp.
     *
     *  @param unclaimedRewards         Rewards accumulated but not claimed by user yet.
     *
     *  @param conditionIdOflastUpdate  Condition-Id when rewards were last updated for user.
     */
    struct Staker {
        uint256 amountStaked;
        uint256 timeOfLastUpdate;
        uint256 unclaimedRewards;
        uint256 conditionIdOflastUpdate;
    }

    /**
     *  @notice Staking Condition.
     *
     *  @param timeUnit                 Unit of time specified in number of seconds. Can be set as 1 seconds, 1 days, 1 hours, etc.
     *
     *  @param rewardRatioNumerator     Rewards ratio is the number of reward tokens for a number of staked tokens,
     *                                  per unit of time.
     *
     *  @param rewardRatioDenominator   Rewards ratio is the number of reward tokens for a number of staked tokens,
     *                                  per unit of time.
     *
     *  @param startTimestamp           Condition start timestamp.
     *
     *  @param endTimestamp             Condition end timestamp.
     */
    struct StakingCondition {
        uint256 timeUnit;
        uint256 rewardRatioNumerator;
        uint256 rewardRatioDenominator;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    /**
     *  @notice Stake ERC721 Tokens.
     *
     *  @param amount    Amount to stake.
     */
    function stake(uint256 amount) external payable;

    /**
     *  @notice Withdraw staked tokens.
     *
     *  @param amount    Amount to withdraw.
     */
    function withdraw(uint256 amount) external;

    /**
     *  @notice Claim accumulated rewards.
     *
     */
    function claimRewards() external;

    /**
     *  @notice View amount staked and total rewards for a user.
     *
     *  @param staker    Address for which to calculated rewards.
     */
    function getStakeInfo(address staker) external view returns (uint256 _tokensStaked, uint256 _rewards);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

interface IStaking721 {
    /// @dev Emitted when a set of token-ids are staked.
    event TokensStaked(address indexed staker, uint256[] indexed tokenIds);

    /// @dev Emitted when a set of staked token-ids are withdrawn.
    event TokensWithdrawn(address indexed staker, uint256[] indexed tokenIds);

    /// @dev Emitted when a staker claims staking rewards.
    event RewardsClaimed(address indexed staker, uint256 rewardAmount);

    /// @dev Emitted when contract admin updates timeUnit.
    event UpdatedTimeUnit(uint256 oldTimeUnit, uint256 newTimeUnit);

    /// @dev Emitted when contract admin updates rewardsPerUnitTime.
    event UpdatedRewardsPerUnitTime(uint256 oldRewardsPerUnitTime, uint256 newRewardsPerUnitTime);

    /**
     *  @notice Staker Info.
     *
     *  @param amountStaked             Total number of tokens staked by the staker.
     *
     *  @param timeOfLastUpdate         Last reward-update timestamp.
     *
     *  @param unclaimedRewards         Rewards accumulated but not claimed by user yet.
     *
     *  @param conditionIdOflastUpdate  Condition-Id when rewards were last updated for user.
     */
    struct Staker {
        uint256 amountStaked;
        uint256 timeOfLastUpdate;
        uint256 unclaimedRewards;
        uint256 conditionIdOflastUpdate;
    }

    /**
     *  @notice Staking Condition.
     *
     *  @param timeUnit           Unit of time specified in number of seconds. Can be set as 1 seconds, 1 days, 1 hours, etc.
     *
     *  @param rewardsPerUnitTime Rewards accumulated per unit of time.
     *
     *  @param startTimestamp     Condition start timestamp.
     *
     *  @param endTimestamp       Condition end timestamp.
     */
    struct StakingCondition {
        uint256 timeUnit;
        uint256 rewardsPerUnitTime;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    /**
     *  @notice Stake ERC721 Tokens.
     *
     *  @param tokenIds    List of tokens to stake.
     */
    function stake(uint256[] calldata tokenIds) external;

    /**
     *  @notice Withdraw staked tokens.
     *
     *  @param tokenIds    List of tokens to withdraw.
     */
    function withdraw(uint256[] calldata tokenIds) external;

    /**
     *  @notice Claim accumulated rewards.
     */
    function claimRewards() external;

    /**
     *  @notice View amount staked and total rewards for a user.
     *
     *  @param staker    Address for which to calculated rewards.
     */
    function getStakeInfo(address staker) external view returns (uint256[] memory _tokensStaked, uint256 _rewards);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./interface/IPermissions.sol";
import "../lib/TWStrings.sol";

/**
 *  @title   Permissions
 *  @dev     This contracts provides extending-contracts with role-based access control mechanisms
 */
contract Permissions is IPermissions {
    /// @dev Map from keccak256 hash of a role => a map from address => whether address has role.
    mapping(bytes32 => mapping(address => bool)) private _hasRole;

    /// @dev Map from keccak256 hash of a role to role admin. See {getRoleAdmin}.
    mapping(bytes32 => bytes32) private _getRoleAdmin;

    /// @dev Default admin role for all roles. Only accounts with this role can grant/revoke other roles.
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /// @dev Modifier that checks if an account has the specified role; reverts otherwise.
    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    /**
     *  @notice         Checks whether an account has a particular role.
     *  @dev            Returns `true` if `account` has been granted `role`.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _hasRole[role][account];
    }

    /**
     *  @notice         Checks whether an account has a particular role;
     *                  role restrictions can be swtiched on and off.
     *
     *  @dev            Returns `true` if `account` has been granted `role`.
     *                  Role restrictions can be swtiched on and off:
     *                      - If address(0) has ROLE, then the ROLE restrictions
     *                        don't apply.
     *                      - If address(0) does not have ROLE, then the ROLE
     *                        restrictions will apply.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account for which the role is being checked.
     */
    function hasRoleWithSwitch(bytes32 role, address account) public view returns (bool) {
        if (!_hasRole[role][address(0)]) {
            return _hasRole[role][account];
        }

        return true;
    }

    /**
     *  @notice         Returns the admin role that controls the specified role.
     *  @dev            See {grantRole} and {revokeRole}.
     *                  To change a role's admin, use {_setRoleAdmin}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function getRoleAdmin(bytes32 role) external view override returns (bytes32) {
        return _getRoleAdmin[role];
    }

    /**
     *  @notice         Grants a role to an account, if not previously granted.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleGranted Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account to which the role is being granted.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        if (_hasRole[role][account]) {
            revert("Can only grant to non holders");
        }
        _setupRole(role, account);
    }

    /**
     *  @notice         Revokes role from an account.
     *  @dev            Caller must have admin role for the `role`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        _checkRole(_getRoleAdmin[role], msg.sender);
        _revokeRole(role, account);
    }

    /**
     *  @notice         Revokes role from the account.
     *  @dev            Caller must have the `role`, with caller being the same as `account`.
     *                  Emits {RoleRevoked Event}.
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param account  Address of the account from which the role is being revoked.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        if (msg.sender != account) {
            revert("Can only renounce for self");
        }
        _revokeRole(role, account);
    }

    /// @dev Sets `adminRole` as `role`'s admin role.
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = _getRoleAdmin[role];
        _getRoleAdmin[role] = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /// @dev Sets up `role` for `account`
    function _setupRole(bytes32 role, address account) internal virtual {
        _hasRole[role][account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    /// @dev Revokes `role` from `account`
    function _revokeRole(bytes32 role, address account) internal virtual {
        _checkRole(role, account);
        delete _hasRole[role][account];
        emit RoleRevoked(role, account, msg.sender);
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!_hasRole[role][account]) {
            revert(
                string(
                    abi.encodePacked(
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /// @dev Checks `role` for `account`. Reverts with a message including the required role.
    function _checkRoleWithSwitch(bytes32 role, address account) internal view virtual {
        if (!hasRoleWithSwitch(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "Permissions: account ",
                        TWStrings.toHexString(uint160(account), 20),
                        " is missing role ",
                        TWStrings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

import "./interface/IPermissionsEnumerable.sol";
import "./Permissions.sol";

/**
 *  @title   PermissionsEnumerable
 *  @dev     This contracts provides extending-contracts with role-based access control mechanisms.
 *           Also provides interfaces to view all members with a given role, and total count of members.
 */
contract PermissionsEnumerable is IPermissionsEnumerable, Permissions {
    /**
     *  @notice A data structure to store data of members for a given role.
     *
     *  @param index    Current index in the list of accounts that have a role.
     *  @param members  map from index => address of account that has a role
     *  @param indexOf  map from address => index which the account has.
     */
    struct RoleMembers {
        uint256 index;
        mapping(uint256 => address) members;
        mapping(address => uint256) indexOf;
    }

    /// @dev map from keccak256 hash of a role to its members' data. See {RoleMembers}.
    mapping(bytes32 => RoleMembers) private roleMembers;

    /**
     *  @notice         Returns the role-member from a list of members for a role,
     *                  at a given index.
     *  @dev            Returns `member` who has `role`, at `index` of role-members list.
     *                  See struct {RoleMembers}, and mapping {roleMembers}
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *  @param index    Index in list of current members for the role.
     *
     *  @return member  Address of account that has `role`
     */
    function getRoleMember(bytes32 role, uint256 index) external view override returns (address member) {
        uint256 currentIndex = roleMembers[role].index;
        uint256 check;

        for (uint256 i = 0; i < currentIndex; i += 1) {
            if (roleMembers[role].members[i] != address(0)) {
                if (check == index) {
                    member = roleMembers[role].members[i];
                    return member;
                }
                check += 1;
            } else if (hasRole(role, address(0)) && i == roleMembers[role].indexOf[address(0)]) {
                check += 1;
            }
        }
    }

    /**
     *  @notice         Returns total number of accounts that have a role.
     *  @dev            Returns `count` of accounts that have `role`.
     *                  See struct {RoleMembers}, and mapping {roleMembers}
     *
     *  @param role     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     *
     *  @return count   Total number of accounts that have `role`
     */
    function getRoleMemberCount(bytes32 role) external view override returns (uint256 count) {
        uint256 currentIndex = roleMembers[role].index;

        for (uint256 i = 0; i < currentIndex; i += 1) {
            if (roleMembers[role].members[i] != address(0)) {
                count += 1;
            }
        }
        if (hasRole(role, address(0))) {
            count += 1;
        }
    }

    /// @dev Revokes `role` from `account`, and removes `account` from {roleMembers}
    ///      See {_removeMember}
    function _revokeRole(bytes32 role, address account) internal override {
        super._revokeRole(role, account);
        _removeMember(role, account);
    }

    /// @dev Grants `role` to `account`, and adds `account` to {roleMembers}
    ///      See {_addMember}
    function _setupRole(bytes32 role, address account) internal override {
        super._setupRole(role, account);
        _addMember(role, account);
    }

    /// @dev adds `account` to {roleMembers}, for `role`
    function _addMember(bytes32 role, address account) internal {
        uint256 idx = roleMembers[role].index;
        roleMembers[role].index += 1;

        roleMembers[role].members[idx] = account;
        roleMembers[role].indexOf[account] = idx;
    }

    /// @dev removes `account` from {roleMembers}, for `role`
    function _removeMember(bytes32 role, address account) internal {
        uint256 idx = roleMembers[role].indexOf[account];

        delete roleMembers[role].members[idx];
        delete roleMembers[role].indexOf[account];
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../openzeppelin-presets/utils/math/SafeMath.sol";
import "../eip/interface/IERC1155.sol";

import "./interface/IStaking1155.sol";

abstract contract Staking1155Upgradeable is ReentrancyGuardUpgradeable, IStaking1155 {
    /*///////////////////////////////////////////////////////////////
                            State variables / Mappings
    //////////////////////////////////////////////////////////////*/

    ///@dev Address of ERC1155 contract -- staked tokens belong to this contract.
    address public stakingToken;

    /// @dev Flag to check direct transfers of staking tokens.
    uint8 internal isStaking = 1;

    ///@dev Next staking condition Id. Tracks number of conditon updates so far.
    uint256 private nextDefaultConditionId;

    ///@dev List of token-ids ever staked.
    uint256[] public indexedTokens;

    ///@dev Mapping from token-id to whether it is indexed or not.
    mapping(uint256 => bool) public isIndexed;

    ///@dev Mapping from default condition-id to default condition.
    mapping(uint256 => StakingCondition) private defaultCondition;

    ///@dev Mapping from token-id to next staking condition Id for the token. Tracks number of conditon updates so far.
    mapping(uint256 => uint256) private nextConditionId;

    ///@dev Mapping from token-id and staker address to Staker struct. See {struct IStaking1155.Staker}.
    mapping(uint256 => mapping(address => Staker)) public stakers;

    ///@dev Mapping from token-id and condition Id to staking condition. See {struct IStaking1155.StakingCondition}
    mapping(uint256 => mapping(uint256 => StakingCondition)) private stakingConditions;

    /// @dev Mapping from token-id to list of accounts that have staked that token-id.
    mapping(uint256 => address[]) public stakersArray;

    function __Staking1155_init(address _stakingToken) internal onlyInitializing {
        __ReentrancyGuard_init();

        require(address(_stakingToken) != address(0), "address 0");
        stakingToken = _stakingToken;
    }

    /*///////////////////////////////////////////////////////////////
                        External/Public Functions
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice    Stake ERC721 Tokens.
     *
     *  @dev       See {_stake}. Override that to implement custom logic.
     *
     *  @param _tokenId   ERC1155 token-id to stake.
     *  @param _amount    Amount to stake.
     */
    function stake(uint256 _tokenId, uint256 _amount) external nonReentrant {
        _stake(_tokenId, _amount);
    }

    /**
     *  @notice    Withdraw staked tokens.
     *
     *  @dev       See {_withdraw}. Override that to implement custom logic.
     *
     *  @param _tokenId   ERC1155 token-id to withdraw.
     *  @param _amount    Amount to withdraw.
     */
    function withdraw(uint256 _tokenId, uint256 _amount) external nonReentrant {
        _withdraw(_tokenId, _amount);
    }

    /**
     *  @notice    Claim accumulated rewards.
     *
     *  @dev       See {_claimRewards}. Override that to implement custom logic.
     *             See {_calculateRewards} for reward-calculation logic.
     *
     *  @param _tokenId   Staked token Id.
     */
    function claimRewards(uint256 _tokenId) external nonReentrant {
        _claimRewards(_tokenId);
    }

    /**
     *  @notice  Set time unit. Set as a number of seconds.
     *           Could be specified as -- x * 1 hours, x * 1 days, etc.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *
     *  @param _tokenId     ERC1155 token Id.
     *  @param _timeUnit    New time unit.
     */
    function setTimeUnit(uint256 _tokenId, uint256 _timeUnit) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        uint256 _nextConditionId = nextConditionId[_tokenId];
        StakingCondition memory condition = _nextConditionId == 0
            ? defaultCondition[nextDefaultConditionId - 1]
            : stakingConditions[_tokenId][_nextConditionId - 1];
        require(_timeUnit != condition.timeUnit, "Time-unit unchanged.");

        _setStakingCondition(_tokenId, _timeUnit, condition.rewardsPerUnitTime);

        emit UpdatedTimeUnit(_tokenId, condition.timeUnit, _timeUnit);
    }

    /**
     *  @notice  Set rewards per unit of time.
     *           Interpreted as x rewards per second/per day/etc based on time-unit.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *
     *  @param _tokenId               ERC1155 token Id.
     *  @param _rewardsPerUnitTime    New rewards per unit time.
     */
    function setRewardsPerUnitTime(uint256 _tokenId, uint256 _rewardsPerUnitTime) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        uint256 _nextConditionId = nextConditionId[_tokenId];
        StakingCondition memory condition = _nextConditionId == 0
            ? defaultCondition[nextDefaultConditionId - 1]
            : stakingConditions[_tokenId][_nextConditionId - 1];
        require(_rewardsPerUnitTime != condition.rewardsPerUnitTime, "Reward unchanged.");

        _setStakingCondition(_tokenId, condition.timeUnit, _rewardsPerUnitTime);

        emit UpdatedRewardsPerUnitTime(_tokenId, condition.rewardsPerUnitTime, _rewardsPerUnitTime);
    }

    /**
     *  @notice  Set time unit. Set as a number of seconds.
     *           Could be specified as -- x * 1 hours, x * 1 days, etc.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *  @param _defaultTimeUnit    New time unit.
     */
    function setDefaultTimeUnit(uint256 _defaultTimeUnit) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        StakingCondition memory _defaultCondition = defaultCondition[nextDefaultConditionId - 1];
        require(_defaultTimeUnit != _defaultCondition.timeUnit, "Default time-unit unchanged.");

        _setDefaultStakingCondition(_defaultTimeUnit, _defaultCondition.rewardsPerUnitTime);

        emit UpdatedDefaultTimeUnit(_defaultCondition.timeUnit, _defaultTimeUnit);
    }

    /**
     *  @notice  Set rewards per unit of time.
     *           Interpreted as x rewards per second/per day/etc based on time-unit.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *  @param _defaultRewardsPerUnitTime    New rewards per unit time.
     */
    function setDefaultRewardsPerUnitTime(uint256 _defaultRewardsPerUnitTime) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        StakingCondition memory _defaultCondition = defaultCondition[nextDefaultConditionId - 1];
        require(_defaultRewardsPerUnitTime != _defaultCondition.rewardsPerUnitTime, "Default reward unchanged.");

        _setDefaultStakingCondition(_defaultCondition.timeUnit, _defaultRewardsPerUnitTime);

        emit UpdatedDefaultRewardsPerUnitTime(_defaultCondition.rewardsPerUnitTime, _defaultRewardsPerUnitTime);
    }

    /**
     *  @notice View amount staked and rewards for a user, for a given token-id.
     *
     *  @param _staker          Address for which to calculated rewards.
     *  @return _tokensStaked   Amount of tokens staked for given token-id.
     *  @return _rewards        Available reward amount.
     */
    function getStakeInfoForToken(uint256 _tokenId, address _staker)
        external
        view
        virtual
        returns (uint256 _tokensStaked, uint256 _rewards)
    {
        _tokensStaked = stakers[_tokenId][_staker].amountStaked;
        _rewards = _availableRewards(_tokenId, _staker);
    }

    /**
     *  @notice View all tokens staked and total rewards for a user.
     *
     *  @param _staker          Address for which to calculated rewards.
     *  @return _tokensStaked   List of token-ids staked.
     *  @return _tokenAmounts   Amount of each token-id staked.
     *  @return _totalRewards   Total rewards available.
     */
    function getStakeInfo(address _staker)
        external
        view
        virtual
        returns (
            uint256[] memory _tokensStaked,
            uint256[] memory _tokenAmounts,
            uint256 _totalRewards
        )
    {
        uint256[] memory _indexedTokens = indexedTokens;
        uint256[] memory _stakedAmounts = new uint256[](_indexedTokens.length);
        uint256 indexedTokenCount = _indexedTokens.length;
        uint256 stakerTokenCount = 0;

        for (uint256 i = 0; i < indexedTokenCount; i++) {
            _stakedAmounts[i] = stakers[_indexedTokens[i]][_staker].amountStaked;
            if (_stakedAmounts[i] > 0) stakerTokenCount += 1;
        }

        _tokensStaked = new uint256[](stakerTokenCount);
        _tokenAmounts = new uint256[](stakerTokenCount);
        uint256 count = 0;
        for (uint256 i = 0; i < indexedTokenCount; i++) {
            if (_stakedAmounts[i] > 0) {
                _tokensStaked[count] = _indexedTokens[i];
                _tokenAmounts[count] = _stakedAmounts[i];
                _totalRewards += _availableRewards(_indexedTokens[i], _staker);
                count += 1;
            }
        }
    }

    function getTimeUnit(uint256 _tokenId) public view returns (uint256 _timeUnit) {
        uint256 _nextConditionId = nextConditionId[_tokenId];
        require(_nextConditionId != 0, "Time unit not set. Check default time unit.");
        _timeUnit = stakingConditions[_tokenId][_nextConditionId - 1].timeUnit;
    }

    function getRewardsPerUnitTime(uint256 _tokenId) public view returns (uint256 _rewardsPerUnitTime) {
        uint256 _nextConditionId = nextConditionId[_tokenId];
        require(_nextConditionId != 0, "Rewards not set. Check default rewards.");
        _rewardsPerUnitTime = stakingConditions[_tokenId][_nextConditionId - 1].rewardsPerUnitTime;
    }

    function getDefaultTimeUnit() public view returns (uint256 _timeUnit) {
        _timeUnit = defaultCondition[nextDefaultConditionId - 1].timeUnit;
    }

    function getDefaultRewardsPerUnitTime() public view returns (uint256 _rewardsPerUnitTime) {
        _rewardsPerUnitTime = defaultCondition[nextDefaultConditionId - 1].rewardsPerUnitTime;
    }

    /*///////////////////////////////////////////////////////////////
                            Internal Functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Staking logic. Override to add custom logic.
    function _stake(uint256 _tokenId, uint256 _amount) internal virtual {
        require(_amount != 0, "Staking 0 tokens");
        address _stakingToken = stakingToken;

        if (stakers[_tokenId][_stakeMsgSender()].amountStaked > 0) {
            _updateUnclaimedRewardsForStaker(_tokenId, _stakeMsgSender());
        } else {
            stakersArray[_tokenId].push(_stakeMsgSender());
            stakers[_tokenId][_stakeMsgSender()].timeOfLastUpdate = block.timestamp;

            uint256 _conditionId = nextConditionId[_tokenId];
            stakers[_tokenId][_stakeMsgSender()].conditionIdOflastUpdate = _conditionId == 0
                ? nextDefaultConditionId - 1
                : _conditionId - 1;
        }

        require(
            IERC1155(_stakingToken).balanceOf(_stakeMsgSender(), _tokenId) >= _amount &&
                IERC1155(_stakingToken).isApprovedForAll(_stakeMsgSender(), address(this)),
            "Not balance or approved"
        );
        isStaking = 2;
        IERC1155(_stakingToken).safeTransferFrom(_stakeMsgSender(), address(this), _tokenId, _amount, "");
        isStaking = 1;
        // stakerAddress[_tokenIds[i]] = _stakeMsgSender();
        stakers[_tokenId][_stakeMsgSender()].amountStaked += _amount;

        if (!isIndexed[_tokenId]) {
            isIndexed[_tokenId] = true;
            indexedTokens.push(_tokenId);
        }

        emit TokensStaked(_stakeMsgSender(), _tokenId, _amount);
    }

    /// @dev Withdraw logic. Override to add custom logic.
    function _withdraw(uint256 _tokenId, uint256 _amount) internal virtual {
        uint256 _amountStaked = stakers[_tokenId][_stakeMsgSender()].amountStaked;
        require(_amount != 0, "Withdrawing 0 tokens");
        require(_amountStaked >= _amount, "Withdrawing more than staked");

        _updateUnclaimedRewardsForStaker(_tokenId, _stakeMsgSender());

        if (_amountStaked == _amount) {
            address[] memory _stakersArray = stakersArray[_tokenId];
            for (uint256 i = 0; i < _stakersArray.length; ++i) {
                if (_stakersArray[i] == _stakeMsgSender()) {
                    stakersArray[_tokenId][i] = _stakersArray[_stakersArray.length - 1];
                    stakersArray[_tokenId].pop();
                    break;
                }
            }
        }
        stakers[_tokenId][_stakeMsgSender()].amountStaked -= _amount;

        IERC1155(stakingToken).safeTransferFrom(address(this), _stakeMsgSender(), _tokenId, _amount, "");

        emit TokensWithdrawn(_stakeMsgSender(), _tokenId, _amount);
    }

    /// @dev Logic for claiming rewards. Override to add custom logic.
    function _claimRewards(uint256 _tokenId) internal virtual {
        uint256 rewards = stakers[_tokenId][_stakeMsgSender()].unclaimedRewards +
            _calculateRewards(_tokenId, _stakeMsgSender());

        require(rewards != 0, "No rewards");

        stakers[_tokenId][_stakeMsgSender()].timeOfLastUpdate = block.timestamp;
        stakers[_tokenId][_stakeMsgSender()].unclaimedRewards = 0;

        uint256 _conditionId = nextConditionId[_tokenId];
        stakers[_tokenId][_stakeMsgSender()].conditionIdOflastUpdate = _conditionId == 0
            ? nextDefaultConditionId - 1
            : _conditionId - 1;

        _mintRewards(_stakeMsgSender(), rewards);

        emit RewardsClaimed(_stakeMsgSender(), rewards);
    }

    /// @dev View available rewards for a user.
    function _availableRewards(uint256 _tokenId, address _user) internal view virtual returns (uint256 _rewards) {
        if (stakers[_tokenId][_user].amountStaked == 0) {
            _rewards = stakers[_tokenId][_user].unclaimedRewards;
        } else {
            _rewards = stakers[_tokenId][_user].unclaimedRewards + _calculateRewards(_tokenId, _user);
        }
    }

    /// @dev Update unclaimed rewards for a users. Called for every state change for a user.
    function _updateUnclaimedRewardsForStaker(uint256 _tokenId, address _staker) internal virtual {
        uint256 rewards = _calculateRewards(_tokenId, _staker);
        stakers[_tokenId][_staker].unclaimedRewards += rewards;
        stakers[_tokenId][_staker].timeOfLastUpdate = block.timestamp;

        uint256 _conditionId = nextConditionId[_tokenId];
        stakers[_tokenId][_staker].conditionIdOflastUpdate = _conditionId == 0
            ? nextDefaultConditionId - 1
            : _conditionId - 1;
    }

    /// @dev Set staking conditions, for a token-Id.
    function _setStakingCondition(
        uint256 _tokenId,
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime
    ) internal virtual {
        require(_timeUnit != 0, "time-unit can't be 0");
        uint256 conditionId = nextConditionId[_tokenId];

        if (conditionId == 0) {
            uint256 _nextDefaultConditionId = nextDefaultConditionId;
            for (; conditionId < _nextDefaultConditionId; conditionId += 1) {
                StakingCondition memory _defaultCondition = defaultCondition[conditionId];

                stakingConditions[_tokenId][conditionId] = StakingCondition({
                    timeUnit: _defaultCondition.timeUnit,
                    rewardsPerUnitTime: _defaultCondition.rewardsPerUnitTime,
                    startTimestamp: _defaultCondition.startTimestamp,
                    endTimestamp: _defaultCondition.endTimestamp
                });
            }
        }

        stakingConditions[_tokenId][conditionId - 1].endTimestamp = block.timestamp;

        stakingConditions[_tokenId][conditionId] = StakingCondition({
            timeUnit: _timeUnit,
            rewardsPerUnitTime: _rewardsPerUnitTime,
            startTimestamp: block.timestamp,
            endTimestamp: 0
        });

        nextConditionId[_tokenId] = conditionId + 1;
    }

    /// @dev Set default staking conditions.
    function _setDefaultStakingCondition(uint256 _timeUnit, uint256 _rewardsPerUnitTime) internal virtual {
        require(_timeUnit != 0, "time-unit can't be 0");
        uint256 conditionId = nextDefaultConditionId;
        nextDefaultConditionId += 1;

        defaultCondition[conditionId] = StakingCondition({
            timeUnit: _timeUnit,
            rewardsPerUnitTime: _rewardsPerUnitTime,
            startTimestamp: block.timestamp,
            endTimestamp: 0
        });

        if (conditionId > 0) {
            defaultCondition[conditionId - 1].endTimestamp = block.timestamp;
        }
    }

    /// @dev Reward calculation logic. Override to implement custom logic.
    function _calculateRewards(uint256 _tokenId, address _staker) internal view virtual returns (uint256 _rewards) {
        Staker memory staker = stakers[_tokenId][_staker];
        uint256 _stakerConditionId = staker.conditionIdOflastUpdate;
        uint256 _nextConditionId = nextConditionId[_tokenId];

        if (_nextConditionId == 0) {
            _nextConditionId = nextDefaultConditionId;

            for (uint256 i = _stakerConditionId; i < _nextConditionId; i += 1) {
                StakingCondition memory condition = defaultCondition[i];

                uint256 startTime = i != _stakerConditionId ? condition.startTimestamp : staker.timeOfLastUpdate;
                uint256 endTime = condition.endTimestamp != 0 ? condition.endTimestamp : block.timestamp;

                (bool noOverflowProduct, uint256 rewardsProduct) = SafeMath.tryMul(
                    (endTime - startTime) * staker.amountStaked,
                    condition.rewardsPerUnitTime
                );
                (bool noOverflowSum, uint256 rewardsSum) = SafeMath.tryAdd(
                    _rewards,
                    rewardsProduct / condition.timeUnit
                );

                _rewards = noOverflowProduct && noOverflowSum ? rewardsSum : _rewards;
            }
        } else {
            for (uint256 i = _stakerConditionId; i < _nextConditionId; i += 1) {
                StakingCondition memory condition = stakingConditions[_tokenId][i];

                uint256 startTime = i != _stakerConditionId ? condition.startTimestamp : staker.timeOfLastUpdate;
                uint256 endTime = condition.endTimestamp != 0 ? condition.endTimestamp : block.timestamp;

                (bool noOverflowProduct, uint256 rewardsProduct) = SafeMath.tryMul(
                    (endTime - startTime) * staker.amountStaked,
                    condition.rewardsPerUnitTime
                );
                (bool noOverflowSum, uint256 rewardsSum) = SafeMath.tryAdd(
                    _rewards,
                    rewardsProduct / condition.timeUnit
                );

                _rewards = noOverflowProduct && noOverflowSum ? rewardsSum : _rewards;
            }
        }
    }

    /*////////////////////////////////////////////////////////////////////
        Optional hooks that can be implemented in the derived contract
    ///////////////////////////////////////////////////////////////////*/

    /// @dev Exposes the ability to override the msg sender -- support ERC2771.
    function _stakeMsgSender() internal virtual returns (address) {
        return msg.sender;
    }

    /*///////////////////////////////////////////////////////////////
        Virtual functions to be implemented in derived contract
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice View total rewards available in the staking contract.
     *
     */
    function getRewardTokenBalance() external view virtual returns (uint256 _rewardsAvailableInContract);

    /**
     *  @dev    Mint/Transfer ERC20 rewards to the staker. Must override.
     *
     *  @param _staker    Address for which to calculated rewards.
     *  @param _rewards   Amount of tokens to be given out as reward.
     *
     *  For example, override as below to mint ERC20 rewards:
     *
     * ```
     *  function _mintRewards(address _staker, uint256 _rewards) internal override {
     *
     *      TokenERC20(rewardTokenAddress).mintTo(_staker, _rewards);
     *
     *  }
     * ```
     */
    function _mintRewards(address _staker, uint256 _rewards) internal virtual;

    /**
     *  @dev    Returns whether staking restrictions can be set in given execution context.
     *          Must override.
     *
     *
     *  For example, override as below to restrict access to admin:
     *
     * ```
     *  function _canSetStakeConditions() internal override {
     *
     *      return msg.sender == adminAddress;
     *
     *  }
     * ```
     */
    function _canSetStakeConditions() internal view virtual returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../openzeppelin-presets/utils/math/SafeMath.sol";
import "../eip/interface/IERC20.sol";
import "../lib/CurrencyTransferLib.sol";

import "./interface/IStaking20.sol";

abstract contract Staking20Upgradeable is ReentrancyGuardUpgradeable, IStaking20 {
    /*///////////////////////////////////////////////////////////////
                            State variables / Mappings
    //////////////////////////////////////////////////////////////*/

    /// @dev The address of the native token wrapper contract.
    address internal immutable nativeTokenWrapper;

    ///@dev Address of ERC20 contract -- staked tokens belong to this contract.
    address public stakingToken;

    /// @dev Decimals of staking token.
    uint256 public stakingTokenDecimals;

    /// @dev Decimals of reward token.
    uint256 public rewardTokenDecimals;

    /// @dev List of accounts that have staked that token-id.
    address[] public stakersArray;

    /// @dev Total amount of tokens staked in the contract.
    uint256 public stakingTokenBalance;

    ///@dev Next staking condition Id. Tracks number of conditon updates so far.
    uint256 private nextConditionId;

    ///@dev Mapping staker address to Staker struct. See {struct IStaking20.Staker}.
    mapping(address => Staker) public stakers;

    ///@dev Mapping from condition Id to staking condition. See {struct IStaking721.StakingCondition}
    mapping(uint256 => StakingCondition) private stakingConditions;

    constructor(address _nativeTokenWrapper) {
        require(_nativeTokenWrapper != address(0), "address 0");

        nativeTokenWrapper = _nativeTokenWrapper;
    }

    function __Staking20_init(
        address _stakingToken,
        uint256 _stakingTokenDecimals,
        uint256 _rewardTokenDecimals
    ) internal onlyInitializing {
        __ReentrancyGuard_init();

        require(address(_stakingToken) != address(0), "token address 0");
        require(_stakingTokenDecimals != 0 && _rewardTokenDecimals != 0, "decimals 0");

        stakingToken = _stakingToken;
        stakingTokenDecimals = _stakingTokenDecimals;
        rewardTokenDecimals = _rewardTokenDecimals;
    }

    /*///////////////////////////////////////////////////////////////
                        External/Public Functions
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice    Stake ERC20 Tokens.
     *
     *  @dev       See {_stake}. Override that to implement custom logic.
     *
     *  @param _amount    Amount to stake.
     */
    function stake(uint256 _amount) external payable nonReentrant {
        _stake(_amount);
    }

    /**
     *  @notice    Withdraw staked ERC20 tokens.
     *
     *  @dev       See {_withdraw}. Override that to implement custom logic.
     *
     *  @param _amount    Amount to withdraw.
     */
    function withdraw(uint256 _amount) external nonReentrant {
        _withdraw(_amount);
    }

    /**
     *  @notice    Claim accumulated rewards.
     *
     *  @dev       See {_claimRewards}. Override that to implement custom logic.
     *             See {_calculateRewards} for reward-calculation logic.
     */
    function claimRewards() external nonReentrant {
        _claimRewards();
    }

    /**
     *  @notice  Set time unit. Set as a number of seconds.
     *           Could be specified as -- x * 1 hours, x * 1 days, etc.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *  @param _timeUnit    New time unit.
     */
    function setTimeUnit(uint256 _timeUnit) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
        require(_timeUnit != condition.timeUnit, "Time-unit unchanged.");

        _setStakingCondition(_timeUnit, condition.rewardRatioNumerator, condition.rewardRatioDenominator);

        emit UpdatedTimeUnit(condition.timeUnit, _timeUnit);
    }

    /**
     *  @notice  Set rewards per unit of time.
     *           Interpreted as (numerator/denominator) rewards per second/per day/etc based on time-unit.
     *
     *           For e.g., ratio of 1/20 would mean 1 reward token for every 20 tokens staked.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *  @param _numerator    Reward ratio numerator.
     *  @param _denominator  Reward ratio denominator.
     */
    function setRewardRatio(uint256 _numerator, uint256 _denominator) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
        require(
            _numerator != condition.rewardRatioNumerator || _denominator != condition.rewardRatioDenominator,
            "Reward ratio unchanged."
        );
        _setStakingCondition(condition.timeUnit, _numerator, _denominator);

        emit UpdatedRewardRatio(
            condition.rewardRatioNumerator,
            _numerator,
            condition.rewardRatioDenominator,
            _denominator
        );
    }

    /**
     *  @notice View amount staked and rewards for a user.
     *
     *  @param _staker          Address for which to calculated rewards.
     *  @return _tokensStaked   Amount of tokens staked.
     *  @return _rewards        Available reward amount.
     */
    function getStakeInfo(address _staker) external view virtual returns (uint256 _tokensStaked, uint256 _rewards) {
        _tokensStaked = stakers[_staker].amountStaked;
        _rewards = _availableRewards(_staker);
    }

    function getTimeUnit() public view returns (uint256 _timeUnit) {
        _timeUnit = stakingConditions[nextConditionId - 1].timeUnit;
    }

    function getRewardRatio() public view returns (uint256 _numerator, uint256 _denominator) {
        _numerator = stakingConditions[nextConditionId - 1].rewardRatioNumerator;
        _denominator = stakingConditions[nextConditionId - 1].rewardRatioDenominator;
    }

    /*///////////////////////////////////////////////////////////////
                            Internal Functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Staking logic. Override to add custom logic.
    function _stake(uint256 _amount) internal virtual {
        require(_amount != 0, "Staking 0 tokens");

        address _stakingToken;
        if (stakingToken == CurrencyTransferLib.NATIVE_TOKEN) {
            _stakingToken = nativeTokenWrapper;
        } else {
            require(msg.value == 0, "Value not 0");
            _stakingToken = stakingToken;
        }

        if (stakers[_stakeMsgSender()].amountStaked > 0) {
            _updateUnclaimedRewardsForStaker(_stakeMsgSender());
        } else {
            stakersArray.push(_stakeMsgSender());
            stakers[_stakeMsgSender()].timeOfLastUpdate = block.timestamp;
            stakers[_stakeMsgSender()].conditionIdOflastUpdate = nextConditionId - 1;
        }

        uint256 balanceBefore = IERC20(_stakingToken).balanceOf(address(this));
        CurrencyTransferLib.transferCurrencyWithWrapper(
            stakingToken,
            _stakeMsgSender(),
            address(this),
            _amount,
            nativeTokenWrapper
        );
        uint256 actualAmount = IERC20(_stakingToken).balanceOf(address(this)) - balanceBefore;

        stakers[_stakeMsgSender()].amountStaked += actualAmount;
        stakingTokenBalance += actualAmount;

        emit TokensStaked(_stakeMsgSender(), actualAmount);
    }

    /// @dev Withdraw logic. Override to add custom logic.
    function _withdraw(uint256 _amount) internal virtual {
        uint256 _amountStaked = stakers[_stakeMsgSender()].amountStaked;
        require(_amount != 0, "Withdrawing 0 tokens");
        require(_amountStaked >= _amount, "Withdrawing more than staked");

        _updateUnclaimedRewardsForStaker(_stakeMsgSender());

        if (_amountStaked == _amount) {
            address[] memory _stakersArray = stakersArray;
            for (uint256 i = 0; i < _stakersArray.length; ++i) {
                if (_stakersArray[i] == _stakeMsgSender()) {
                    stakersArray[i] = _stakersArray[_stakersArray.length - 1];
                    stakersArray.pop();
                    break;
                }
            }
        }
        stakers[_stakeMsgSender()].amountStaked -= _amount;
        stakingTokenBalance -= _amount;

        CurrencyTransferLib.transferCurrencyWithWrapper(
            stakingToken,
            address(this),
            _stakeMsgSender(),
            _amount,
            nativeTokenWrapper
        );

        emit TokensWithdrawn(_stakeMsgSender(), _amount);
    }

    /// @dev Logic for claiming rewards. Override to add custom logic.
    function _claimRewards() internal virtual {
        uint256 rewards = stakers[_stakeMsgSender()].unclaimedRewards + _calculateRewards(_stakeMsgSender());

        require(rewards != 0, "No rewards");

        stakers[_stakeMsgSender()].timeOfLastUpdate = block.timestamp;
        stakers[_stakeMsgSender()].unclaimedRewards = 0;
        stakers[_stakeMsgSender()].conditionIdOflastUpdate = nextConditionId - 1;

        _mintRewards(_stakeMsgSender(), rewards);

        emit RewardsClaimed(_stakeMsgSender(), rewards);
    }

    /// @dev View available rewards for a user.
    function _availableRewards(address _staker) internal view virtual returns (uint256 _rewards) {
        if (stakers[_staker].amountStaked == 0) {
            _rewards = stakers[_staker].unclaimedRewards;
        } else {
            _rewards = stakers[_staker].unclaimedRewards + _calculateRewards(_staker);
        }
    }

    /// @dev Update unclaimed rewards for a users. Called for every state change for a user.
    function _updateUnclaimedRewardsForStaker(address _staker) internal virtual {
        uint256 rewards = _calculateRewards(_staker);
        stakers[_staker].unclaimedRewards += rewards;
        stakers[_staker].timeOfLastUpdate = block.timestamp;
        stakers[_staker].conditionIdOflastUpdate = nextConditionId - 1;
    }

    /// @dev Set staking conditions.
    function _setStakingCondition(
        uint256 _timeUnit,
        uint256 _numerator,
        uint256 _denominator
    ) internal virtual {
        require(_denominator != 0, "divide by 0");
        require(_timeUnit != 0, "time-unit can't be 0");
        uint256 conditionId = nextConditionId;
        nextConditionId += 1;

        stakingConditions[conditionId] = StakingCondition({
            timeUnit: _timeUnit,
            rewardRatioNumerator: _numerator,
            rewardRatioDenominator: _denominator,
            startTimestamp: block.timestamp,
            endTimestamp: 0
        });

        if (conditionId > 0) {
            stakingConditions[conditionId - 1].endTimestamp = block.timestamp;
        }
    }

    /// @dev Calculate rewards for a staker.
    function _calculateRewards(address _staker) internal view virtual returns (uint256 _rewards) {
        Staker memory staker = stakers[_staker];

        uint256 _stakerConditionId = staker.conditionIdOflastUpdate;
        uint256 _nextConditionId = nextConditionId;

        for (uint256 i = _stakerConditionId; i < _nextConditionId; i += 1) {
            StakingCondition memory condition = stakingConditions[i];

            uint256 startTime = i != _stakerConditionId ? condition.startTimestamp : staker.timeOfLastUpdate;
            uint256 endTime = condition.endTimestamp != 0 ? condition.endTimestamp : block.timestamp;

            (bool noOverflowProduct, uint256 rewardsProduct) = SafeMath.tryMul(
                (endTime - startTime) * staker.amountStaked,
                condition.rewardRatioNumerator
            );
            (bool noOverflowSum, uint256 rewardsSum) = SafeMath.tryAdd(
                _rewards,
                (rewardsProduct / condition.timeUnit) / condition.rewardRatioDenominator
            );

            _rewards = noOverflowProduct && noOverflowSum ? rewardsSum : _rewards;
        }

        (, _rewards) = SafeMath.tryMul(_rewards, 10**rewardTokenDecimals);

        _rewards /= (10**stakingTokenDecimals);
    }

    /*////////////////////////////////////////////////////////////////////
        Optional hooks that can be implemented in the derived contract
    ///////////////////////////////////////////////////////////////////*/

    /// @dev Exposes the ability to override the msg sender -- support ERC2771.
    function _stakeMsgSender() internal virtual returns (address) {
        return msg.sender;
    }

    /*///////////////////////////////////////////////////////////////
        Virtual functions to be implemented in derived contract
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice View total rewards available in the staking contract.
     *
     */
    function getRewardTokenBalance() external view virtual returns (uint256 _rewardsAvailableInContract);

    /**
     *  @dev    Mint/Transfer ERC20 rewards to the staker. Must override.
     *
     *  @param _staker    Address for which to calculated rewards.
     *  @param _rewards   Amount of tokens to be given out as reward.
     *
     *  For example, override as below to mint ERC20 rewards:
     *
     * ```
     *  function _mintRewards(address _staker, uint256 _rewards) internal override {
     *
     *      TokenERC20(rewardTokenAddress).mintTo(_staker, _rewards);
     *
     *  }
     * ```
     */
    function _mintRewards(address _staker, uint256 _rewards) internal virtual;

    /**
     *  @dev    Returns whether staking restrictions can be set in given execution context.
     *          Must override.
     *
     *
     *  For example, override as below to restrict access to admin:
     *
     * ```
     *  function _canSetStakeConditions() internal override {
     *
     *      return msg.sender == adminAddress;
     *
     *  }
     * ```
     */
    function _canSetStakeConditions() internal view virtual returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../openzeppelin-presets/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./interface/IStaking721.sol";

abstract contract Staking721Upgradeable is ReentrancyGuardUpgradeable, IStaking721 {
    /*///////////////////////////////////////////////////////////////
                            State variables / Mappings
    //////////////////////////////////////////////////////////////*/

    ///@dev Address of ERC721 NFT contract -- staked tokens belong to this contract.
    address public stakingToken;

    ///@dev List of token-ids ever staked.
    uint256[] public indexedTokens;

    /// @dev List of accounts that have staked their NFTs.
    address[] public stakersArray;

    /// @dev Flag to check direct transfers of staking tokens.
    uint8 internal isStaking = 1;

    ///@dev Next staking condition Id. Tracks number of conditon updates so far.
    uint256 private nextConditionId;

    ///@dev Mapping from token-id to whether it is indexed or not.
    mapping(uint256 => bool) public isIndexed;

    ///@dev Mapping from staker address to Staker struct. See {struct IStaking721.Staker}.
    mapping(address => Staker) public stakers;

    /// @dev Mapping from staked token-id to staker address.
    mapping(uint256 => address) public stakerAddress;

    ///@dev Mapping from condition Id to staking condition. See {struct IStaking721.StakingCondition}
    mapping(uint256 => StakingCondition) private stakingConditions;

    function __Staking721_init(address _stakingToken) internal onlyInitializing {
        __ReentrancyGuard_init();

        require(address(_stakingToken) != address(0), "collection address 0");
        stakingToken = _stakingToken;
    }

    /*///////////////////////////////////////////////////////////////
                        External/Public Functions
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice    Stake ERC721 Tokens.
     *
     *  @dev       See {_stake}. Override that to implement custom logic.
     *
     *  @param _tokenIds    List of tokens to stake.
     */
    function stake(uint256[] calldata _tokenIds) external nonReentrant {
        _stake(_tokenIds);
    }

    /**
     *  @notice    Withdraw staked tokens.
     *
     *  @dev       See {_withdraw}. Override that to implement custom logic.
     *
     *  @param _tokenIds    List of tokens to withdraw.
     */
    function withdraw(uint256[] calldata _tokenIds) external nonReentrant {
        _withdraw(_tokenIds);
    }

    /**
     *  @notice    Claim accumulated rewards.
     *
     *  @dev       See {_claimRewards}. Override that to implement custom logic.
     *             See {_calculateRewards} for reward-calculation logic.
     */
    function claimRewards() external nonReentrant {
        _claimRewards();
    }

    /**
     *  @notice  Set time unit. Set as a number of seconds.
     *           Could be specified as -- x * 1 hours, x * 1 days, etc.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *
     *  @param _timeUnit    New time unit.
     */
    function setTimeUnit(uint256 _timeUnit) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
        require(_timeUnit != condition.timeUnit, "Time-unit unchanged.");

        _setStakingCondition(_timeUnit, condition.rewardsPerUnitTime);

        emit UpdatedTimeUnit(condition.timeUnit, _timeUnit);
    }

    /**
     *  @notice  Set rewards per unit of time.
     *           Interpreted as x rewards per second/per day/etc based on time-unit.
     *
     *  @dev     Only admin/authorized-account can call it.
     *
     *
     *  @param _rewardsPerUnitTime    New rewards per unit time.
     */
    function setRewardsPerUnitTime(uint256 _rewardsPerUnitTime) external virtual {
        if (!_canSetStakeConditions()) {
            revert("Not authorized");
        }

        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
        require(_rewardsPerUnitTime != condition.rewardsPerUnitTime, "Reward unchanged.");

        _setStakingCondition(condition.timeUnit, _rewardsPerUnitTime);

        emit UpdatedRewardsPerUnitTime(condition.rewardsPerUnitTime, _rewardsPerUnitTime);
    }

    /**
     *  @notice View amount staked and total rewards for a user.
     *
     *  @param _staker          Address for which to calculated rewards.
     *  @return _tokensStaked   List of token-ids staked by staker.
     *  @return _rewards        Available reward amount.
     */
    function getStakeInfo(address _staker)
        external
        view
        virtual
        returns (uint256[] memory _tokensStaked, uint256 _rewards)
    {
        uint256[] memory _indexedTokens = indexedTokens;
        bool[] memory _isStakerToken = new bool[](_indexedTokens.length);
        uint256 indexedTokenCount = _indexedTokens.length;
        uint256 stakerTokenCount = 0;

        for (uint256 i = 0; i < indexedTokenCount; i++) {
            _isStakerToken[i] = stakerAddress[_indexedTokens[i]] == _staker;
            if (_isStakerToken[i]) stakerTokenCount += 1;
        }

        _tokensStaked = new uint256[](stakerTokenCount);
        uint256 count = 0;
        for (uint256 i = 0; i < indexedTokenCount; i++) {
            if (_isStakerToken[i]) {
                _tokensStaked[count] = _indexedTokens[i];
                count += 1;
            }
        }

        _rewards = _availableRewards(_staker);
    }

    function getTimeUnit() public view returns (uint256 _timeUnit) {
        _timeUnit = stakingConditions[nextConditionId - 1].timeUnit;
    }

    function getRewardsPerUnitTime() public view returns (uint256 _rewardsPerUnitTime) {
        _rewardsPerUnitTime = stakingConditions[nextConditionId - 1].rewardsPerUnitTime;
    }

    /*///////////////////////////////////////////////////////////////
                            Internal Functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Staking logic. Override to add custom logic.
    function _stake(uint256[] calldata _tokenIds) internal virtual {
        uint256 len = _tokenIds.length;
        require(len != 0, "Staking 0 tokens");

        address _stakingToken = stakingToken;

        if (stakers[_stakeMsgSender()].amountStaked > 0) {
            _updateUnclaimedRewardsForStaker(_stakeMsgSender());
        } else {
            stakersArray.push(_stakeMsgSender());
            stakers[_stakeMsgSender()].timeOfLastUpdate = block.timestamp;
            stakers[_stakeMsgSender()].conditionIdOflastUpdate = nextConditionId - 1;
        }
        for (uint256 i = 0; i < len; ++i) {
            require(
                IERC721(_stakingToken).ownerOf(_tokenIds[i]) == _stakeMsgSender() &&
                    (IERC721(_stakingToken).getApproved(_tokenIds[i]) == address(this) ||
                        IERC721(_stakingToken).isApprovedForAll(_stakeMsgSender(), address(this))),
                "Not owned or approved"
            );

            isStaking = 2;
            IERC721(_stakingToken).safeTransferFrom(_stakeMsgSender(), address(this), _tokenIds[i]);
            isStaking = 1;

            stakerAddress[_tokenIds[i]] = _stakeMsgSender();

            if (!isIndexed[_tokenIds[i]]) {
                isIndexed[_tokenIds[i]] = true;
                indexedTokens.push(_tokenIds[i]);
            }
        }
        stakers[_stakeMsgSender()].amountStaked += len;

        emit TokensStaked(_stakeMsgSender(), _tokenIds);
    }

    /// @dev Withdraw logic. Override to add custom logic.
    function _withdraw(uint256[] calldata _tokenIds) internal virtual {
        uint256 _amountStaked = stakers[_stakeMsgSender()].amountStaked;
        uint256 len = _tokenIds.length;
        require(len != 0, "Withdrawing 0 tokens");
        require(_amountStaked >= len, "Withdrawing more than staked");

        address _stakingToken = stakingToken;

        _updateUnclaimedRewardsForStaker(_stakeMsgSender());

        if (_amountStaked == len) {
            address[] memory _stakersArray = stakersArray;
            for (uint256 i = 0; i < _stakersArray.length; ++i) {
                if (_stakersArray[i] == _stakeMsgSender()) {
                    stakersArray[i] = _stakersArray[_stakersArray.length - 1];
                    stakersArray.pop();
                    break;
                }
            }
        }
        stakers[_stakeMsgSender()].amountStaked -= len;

        for (uint256 i = 0; i < len; ++i) {
            require(stakerAddress[_tokenIds[i]] == _stakeMsgSender(), "Not staker");
            stakerAddress[_tokenIds[i]] = address(0);
            IERC721(_stakingToken).safeTransferFrom(address(this), _stakeMsgSender(), _tokenIds[i]);
        }

        emit TokensWithdrawn(_stakeMsgSender(), _tokenIds);
    }

    /// @dev Logic for claiming rewards. Override to add custom logic.
    function _claimRewards() internal virtual {
        uint256 rewards = stakers[_stakeMsgSender()].unclaimedRewards + _calculateRewards(_stakeMsgSender());

        require(rewards != 0, "No rewards");

        stakers[_stakeMsgSender()].timeOfLastUpdate = block.timestamp;
        stakers[_stakeMsgSender()].unclaimedRewards = 0;
        stakers[_stakeMsgSender()].conditionIdOflastUpdate = nextConditionId - 1;

        _mintRewards(_stakeMsgSender(), rewards);

        emit RewardsClaimed(_stakeMsgSender(), rewards);
    }

    /// @dev View available rewards for a user.
    function _availableRewards(address _user) internal view virtual returns (uint256 _rewards) {
        if (stakers[_user].amountStaked == 0) {
            _rewards = stakers[_user].unclaimedRewards;
        } else {
            _rewards = stakers[_user].unclaimedRewards + _calculateRewards(_user);
        }
    }

    /// @dev Update unclaimed rewards for a users. Called for every state change for a user.
    function _updateUnclaimedRewardsForStaker(address _staker) internal virtual {
        uint256 rewards = _calculateRewards(_staker);
        stakers[_staker].unclaimedRewards += rewards;
        stakers[_staker].timeOfLastUpdate = block.timestamp;
        stakers[_staker].conditionIdOflastUpdate = nextConditionId - 1;
    }

    /// @dev Set staking conditions.
    function _setStakingCondition(uint256 _timeUnit, uint256 _rewardsPerUnitTime) internal virtual {
        require(_timeUnit != 0, "time-unit can't be 0");
        uint256 conditionId = nextConditionId;
        nextConditionId += 1;

        stakingConditions[conditionId] = StakingCondition({
            timeUnit: _timeUnit,
            rewardsPerUnitTime: _rewardsPerUnitTime,
            startTimestamp: block.timestamp,
            endTimestamp: 0
        });

        if (conditionId > 0) {
            stakingConditions[conditionId - 1].endTimestamp = block.timestamp;
        }
    }

    /// @dev Calculate rewards for a staker.
    function _calculateRewards(address _staker) internal view virtual returns (uint256 _rewards) {
        Staker memory staker = stakers[_staker];

        uint256 _stakerConditionId = staker.conditionIdOflastUpdate;
        uint256 _nextConditionId = nextConditionId;

        for (uint256 i = _stakerConditionId; i < _nextConditionId; i += 1) {
            StakingCondition memory condition = stakingConditions[i];

            uint256 startTime = i != _stakerConditionId ? condition.startTimestamp : staker.timeOfLastUpdate;
            uint256 endTime = condition.endTimestamp != 0 ? condition.endTimestamp : block.timestamp;

            (bool noOverflowProduct, uint256 rewardsProduct) = SafeMath.tryMul(
                (endTime - startTime) * staker.amountStaked,
                condition.rewardsPerUnitTime
            );
            (bool noOverflowSum, uint256 rewardsSum) = SafeMath.tryAdd(_rewards, rewardsProduct / condition.timeUnit);

            _rewards = noOverflowProduct && noOverflowSum ? rewardsSum : _rewards;
        }
    }

    /*////////////////////////////////////////////////////////////////////
        Optional hooks that can be implemented in the derived contract
    ///////////////////////////////////////////////////////////////////*/

    /// @dev Exposes the ability to override the msg sender -- support ERC2771.
    function _stakeMsgSender() internal virtual returns (address) {
        return msg.sender;
    }

    /*///////////////////////////////////////////////////////////////
        Virtual functions to be implemented in derived contract
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice View total rewards available in the staking contract.
     *
     */
    function getRewardTokenBalance() external view virtual returns (uint256 _rewardsAvailableInContract);

    /**
     *  @dev    Mint/Transfer ERC20 rewards to the staker. Must override.
     *
     *  @param _staker    Address for which to calculated rewards.
     *  @param _rewards   Amount of tokens to be given out as reward.
     *
     *  For example, override as below to mint ERC20 rewards:
     *
     * ```
     *  function _mintRewards(address _staker, uint256 _rewards) internal override {
     *
     *      TokenERC20(rewardTokenAddress).mintTo(_staker, _rewards);
     *
     *  }
     * ```
     */
    function _mintRewards(address _staker, uint256 _rewards) internal virtual;

    /**
     *  @dev    Returns whether staking restrictions can be set in given execution context.
     *          Must override.
     *
     *
     *  For example, override as below to restrict access to admin:
     *
     * ```
     *  function _canSetStakeConditions() internal override {
     *
     *      return msg.sender == adminAddress;
     *
     *  }
     * ```
     */
    function _canSetStakeConditions() internal view virtual returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function transfer(address to, uint256 value) external returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/**
 *  Thirdweb's EditionStake smart contract allows users to stake their ERC-1155 NFTs
 *  and earn rewards in form of an ERC-20 token.
 *
 *  note:
 *  - Reward token and staking token can't be changed after deployment.
 *
 *  - ERC1155 tokens from only the specified contract can be staked.
 *
 *  - All token/NFT transfers require approval on their respective contracts.
 *
 *  - Admin must deposit reward tokens using the `depositRewardTokens` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of tokens.
 *
 *  - Users must stake NFTs using the `stake` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of NFTs.
 */

interface IEditionStake {
    /// @dev Emitted when contract admin withdraws reward tokens.
    event RewardTokensWithdrawnByAdmin(uint256 _amount);

    /// @dev Emitted when contract admin deposits reward tokens.
    event RewardTokensDepositedByAdmin(uint256 _amount);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) deposit reward-tokens.
     *
     *          note: Tokens should be approved on the reward-token contract before depositing.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function depositRewardTokens(uint256 _amount) external payable;

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) withdraw reward-tokens.
     *          Useful for removing excess balance, thus preventing locking of tokens.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function withdrawRewardTokens(uint256 _amount) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/**
 *  Thirdweb's NFTStake smart contract allows users to stake their ERC-721 NFTs
 *  and earn rewards in form of an ERC-20 token.
 *
 *  note:
 *  - Reward token and staking token can't be changed after deployment.
 *
 *  - ERC721 tokens from only the specified contract can be staked.
 *
 *  - All token/NFT transfers require approval on their respective contracts.
 *
 *  - Admin must deposit reward tokens using the `depositRewardTokens` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of tokens.
 *
 *  - Users must stake NFTs using the `stake` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of NFTs.
 */

interface INFTStake {
    /// @dev Emitted when contract admin withdraws reward tokens.
    event RewardTokensWithdrawnByAdmin(uint256 _amount);

    /// @dev Emitted when contract admin deposits reward tokens.
    event RewardTokensDepositedByAdmin(uint256 _amount);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) deposit reward-tokens.
     *
     *          note: Tokens should be approved on the reward-token contract before depositing.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function depositRewardTokens(uint256 _amount) external payable;

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) withdraw reward-tokens.
     *          Useful for removing excess balance, thus preventing locking of tokens.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function withdrawRewardTokens(uint256 _amount) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/**
 *  Thirdweb's TokenStake smart contract allows users to stake their ERC-20 Tokens
 *  and earn rewards in form of a different ERC-20 token.
 *
 *  note:
 *  - Reward token and staking token can't be changed after deployment.
 *    Reward token contract can't be same as the staking token contract.
 *
 *  - ERC20 tokens from only the specified contract can be staked.
 *
 *  - All token transfers require approval on their respective token-contracts.
 *
 *  - Admin must deposit reward tokens using the `depositRewardTokens` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of tokens.
 *
 *  - Users must stake tokens using the `stake` function only.
 *    Any direct transfers may cause unintended consequences, such as locking of tokens.
 */

interface ITokenStake {
    /// @dev Emitted when contract admin withdraws reward tokens.
    event RewardTokensWithdrawnByAdmin(uint256 _amount);

    /// @dev Emitted when contract admin deposits reward tokens.
    event RewardTokensDepositedByAdmin(uint256 _amount);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) deposit reward-tokens.
     *
     *          note: Tokens should be approved on the reward-token contract before depositing.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function depositRewardTokens(uint256 _amount) external payable;

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) withdraw reward-tokens.
     *          Useful for removing excess balance, thus preventing locking of tokens.
     *
     *  @param _amount     Amount of tokens to deposit.
     */
    function withdrawRewardTokens(uint256 _amount) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb

// Helper interfaces
import { IWETH } from "../interfaces/IWETH.sol";

import "../openzeppelin-presets/token/ERC20/utils/SafeERC20.sol";

library CurrencyTransferLib {
    using SafeERC20 for IERC20;

    /// @dev The address interpreted as native token of the chain.
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @dev Transfers a given amount of currency.
    function transferCurrency(
        address _currency,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_amount == 0) {
            return;
        }

        if (_currency == NATIVE_TOKEN) {
            safeTransferNativeToken(_to, _amount);
        } else {
            safeTransferERC20(_currency, _from, _to, _amount);
        }
    }

    /// @dev Transfers a given amount of currency. (With native token wrapping)
    function transferCurrencyWithWrapper(
        address _currency,
        address _from,
        address _to,
        uint256 _amount,
        address _nativeTokenWrapper
    ) internal {
        if (_amount == 0) {
            return;
        }

        if (_currency == NATIVE_TOKEN) {
            if (_from == address(this)) {
                // withdraw from weth then transfer withdrawn native token to recipient
                IWETH(_nativeTokenWrapper).withdraw(_amount);
                safeTransferNativeTokenWithWrapper(_to, _amount, _nativeTokenWrapper);
            } else if (_to == address(this)) {
                // store native currency in weth
                require(_amount == msg.value, "msg.value != amount");
                IWETH(_nativeTokenWrapper).deposit{ value: _amount }();
            } else {
                safeTransferNativeTokenWithWrapper(_to, _amount, _nativeTokenWrapper);
            }
        } else {
            safeTransferERC20(_currency, _from, _to, _amount);
        }
    }

    /// @dev Transfer `amount` of ERC20 token from `from` to `to`.
    function safeTransferERC20(
        address _currency,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_from == _to) {
            return;
        }

        if (_from == address(this)) {
            IERC20(_currency).safeTransfer(_to, _amount);
        } else {
            IERC20(_currency).safeTransferFrom(_from, _to, _amount);
        }
    }

    /// @dev Transfers `amount` of native token to `to`.
    function safeTransferNativeToken(address to, uint256 value) internal {
        // solhint-disable avoid-low-level-calls
        // slither-disable-next-line low-level-calls
        (bool success, ) = to.call{ value: value }("");
        require(success, "native token transfer failed");
    }

    /// @dev Transfers `amount` of native token to `to`. (With native token wrapping)
    function safeTransferNativeTokenWithWrapper(
        address to,
        uint256 value,
        address _nativeTokenWrapper
    ) internal {
        // solhint-disable avoid-low-level-calls
        // slither-disable-next-line low-level-calls
        (bool success, ) = to.call{ value: value }("");
        if (!success) {
            IWETH(_nativeTokenWrapper).deposit{ value: value }();
            IERC20(_nativeTokenWrapper).safeTransfer(to, value);
        }
    }
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 * @dev Collection of functions related to the address type
 */
library TWAddress {
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
     * [EIP1884](https://eips.ethereum.org/EIPS/eip-1884) increases the gas cost
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

        (bool success, ) = recipient.call{ value: amount }("");
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

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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

// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;

/// @author thirdweb

/**
 * @dev String operations.
 */
library TWStrings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (metatx/ERC2771Context.sol)

pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771ContextUpgradeable is Initializable, ContextUpgradeable {
    mapping(address => bool) private _trustedForwarder;

    function __ERC2771Context_init(address[] memory trustedForwarder) internal onlyInitializing {
        __Context_init_unchained();
        __ERC2771Context_init_unchained(trustedForwarder);
    }

    function __ERC2771Context_init_unchained(address[] memory trustedForwarder) internal onlyInitializing {
        for (uint256 i = 0; i < trustedForwarder.length; i++) {
            _trustedForwarder[trustedForwarder[i]] = true;
        }
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return _trustedForwarder[forwarder];
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../../../../eip/interface/IERC20.sol";
import "../../../../lib/TWAddress.sol";

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
    using TWAddress for address;

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

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

//   $$\     $$\       $$\                 $$\                         $$\
//   $$ |    $$ |      \__|                $$ |                        $$ |
// $$$$$$\   $$$$$$$\  $$\  $$$$$$\   $$$$$$$ |$$\  $$\  $$\  $$$$$$\  $$$$$$$\
// \_$$  _|  $$  __$$\ $$ |$$  __$$\ $$  __$$ |$$ | $$ | $$ |$$  __$$\ $$  __$$\
//   $$ |    $$ |  $$ |$$ |$$ |  \__|$$ /  $$ |$$ | $$ | $$ |$$$$$$$$ |$$ |  $$ |
//   $$ |$$\ $$ |  $$ |$$ |$$ |      $$ |  $$ |$$ | $$ | $$ |$$   ____|$$ |  $$ |
//   \$$$$  |$$ |  $$ |$$ |$$ |      \$$$$$$$ |\$$$$$\$$$$  |\$$$$$$$\ $$$$$$$  |
//    \____/ \__|  \__|\__|\__|       \_______| \_____\____/  \_______|\_______/

// Token
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";

// Meta transactions
import "../openzeppelin-presets/metatx/ERC2771ContextUpgradeable.sol";

// Utils
import "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import "../lib/CurrencyTransferLib.sol";

//  ==========  Features    ==========

import "../extension/ContractMetadata.sol";
import "../extension/PermissionsEnumerable.sol";
import { Staking1155Upgradeable } from "../extension/Staking1155Upgradeable.sol";
import "../interfaces/staking/IEditionStake.sol";

contract EditionStake is
    Initializable,
    ContractMetadata,
    PermissionsEnumerable,
    ERC2771ContextUpgradeable,
    MulticallUpgradeable,
    Staking1155Upgradeable,
    ERC165Upgradeable,
    IERC1155ReceiverUpgradeable,
    IEditionStake
{
    bytes32 private constant MODULE_TYPE = bytes32("EditionStake");
    uint256 private constant VERSION = 1;

    /// @dev The address of the native token wrapper contract.
    address internal immutable nativeTokenWrapper;

    /// @dev ERC20 Reward Token address. See {_mintRewards} below.
    address public rewardToken;

    /// @dev Total amount of reward tokens in the contract.
    uint256 private rewardTokenBalance;

    constructor(address _nativeTokenWrapper) initializer {
        nativeTokenWrapper = _nativeTokenWrapper;
    }

    /// @dev Initiliazes the contract, like a constructor.
    function initialize(
        address _defaultAdmin,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _rewardToken,
        address _stakingToken,
        uint256 _defaultTimeUnit,
        uint256 _defaultRewardsPerUnitTime
    ) external initializer {
        __ERC2771Context_init_unchained(_trustedForwarders);

        rewardToken = _rewardToken;
        __Staking1155_init(_stakingToken);
        _setDefaultStakingCondition(_defaultTimeUnit, _defaultRewardsPerUnitTime);

        _setupContractURI(_contractURI);
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    /// @dev Returns the module type of the contract.
    function contractType() external pure virtual returns (bytes32) {
        return MODULE_TYPE;
    }

    /// @dev Returns the version of the contract.
    function contractVersion() external pure virtual returns (uint8) {
        return uint8(VERSION);
    }

    /// @dev Lets the contract receive ether to unwrap native tokens.
    receive() external payable {
        require(msg.sender == nativeTokenWrapper, "caller not native token wrapper.");
    }

    /// @dev Admin deposits reward tokens.
    function depositRewardTokens(uint256 _amount) external payable nonReentrant {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not authorized");

        address _rewardToken = rewardToken == CurrencyTransferLib.NATIVE_TOKEN ? nativeTokenWrapper : rewardToken;

        uint256 balanceBefore = IERC20(_rewardToken).balanceOf(address(this));
        CurrencyTransferLib.transferCurrencyWithWrapper(
            rewardToken,
            _msgSender(),
            address(this),
            _amount,
            nativeTokenWrapper
        );
        uint256 actualAmount = IERC20(_rewardToken).balanceOf(address(this)) - balanceBefore;

        rewardTokenBalance += actualAmount;

        emit RewardTokensDepositedByAdmin(actualAmount);
    }

    /// @dev Admin can withdraw excess reward tokens.
    function withdrawRewardTokens(uint256 _amount) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not authorized");

        // to prevent locking of direct-transferred tokens
        rewardTokenBalance = _amount > rewardTokenBalance ? 0 : rewardTokenBalance - _amount;

        CurrencyTransferLib.transferCurrencyWithWrapper(
            rewardToken,
            address(this),
            _msgSender(),
            _amount,
            nativeTokenWrapper
        );

        emit RewardTokensWithdrawnByAdmin(_amount);
    }

    /// @notice View total rewards available in the staking contract.
    function getRewardTokenBalance() external view override returns (uint256 _rewardsAvailableInContract) {
        return rewardTokenBalance;
    }

    /*///////////////////////////////////////////////////////////////
                        ERC 165 / 721 logic
    //////////////////////////////////////////////////////////////*/

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        require(isStaking == 2, "Direct transfer");
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /*///////////////////////////////////////////////////////////////
                        Transfer Staking Rewards
    //////////////////////////////////////////////////////////////*/

    /// @dev Mint/Transfer ERC20 rewards to the staker.
    function _mintRewards(address _staker, uint256 _rewards) internal override {
        require(_rewards <= rewardTokenBalance, "Not enough reward tokens");
        rewardTokenBalance -= _rewards;
        CurrencyTransferLib.transferCurrencyWithWrapper(
            rewardToken,
            address(this),
            _staker,
            _rewards,
            nativeTokenWrapper
        );
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns whether staking related restrictions can be set in the given execution context.
    function _canSetStakeConditions() internal view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @dev Checks whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /*///////////////////////////////////////////////////////////////
                            Miscellaneous
    //////////////////////////////////////////////////////////////*/

    function _stakeMsgSender() internal view virtual override returns (address) {
        return _msgSender();
    }

    function _msgSender() internal view virtual override returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

/// @author thirdweb

//   $$\     $$\       $$\                 $$\                         $$\
//   $$ |    $$ |      \__|                $$ |                        $$ |
// $$$$$$\   $$$$$$$\  $$\  $$$$$$\   $$$$$$$ |$$\  $$\  $$\  $$$$$$\  $$$$$$$\
// \_$$  _|  $$  __$$\ $$ |$$  __$$\ $$  __$$ |$$ | $$ | $$ |$$  __$$\ $$  __$$\
//   $$ |    $$ |  $$ |$$ |$$ |  \__|$$ /  $$ |$$ | $$ | $$ |$$$$$$$$ |$$ |  $$ |
//   $$ |$$\ $$ |  $$ |$$ |$$ |      $$ |  $$ |$$ | $$ | $$ |$$   ____|$$ |  $$ |
//   \$$$$  |$$ |  $$ |$$ |$$ |      \$$$$$$$ |\$$$$$\$$$$  |\$$$$$$$\ $$$$$$$  |
//    \____/ \__|  \__|\__|\__|       \_______| \_____\____/  \_______|\_______/

// Token
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";

// Meta transactions
import "../openzeppelin-presets/metatx/ERC2771ContextUpgradeable.sol";

// Utils
import "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import "../lib/CurrencyTransferLib.sol";

//  ==========  Features    ==========

import "../extension/ContractMetadata.sol";
import "../extension/PermissionsEnumerable.sol";
import { Staking721Upgradeable } from "../extension/Staking721Upgradeable.sol";
import "../interfaces/staking/INFTStake.sol";

contract NFTStake is
    Initializable,
    ContractMetadata,
    PermissionsEnumerable,
    ERC2771ContextUpgradeable,
    MulticallUpgradeable,
    Staking721Upgradeable,
    ERC165Upgradeable,
    IERC721ReceiverUpgradeable,
    INFTStake
{
    bytes32 private constant MODULE_TYPE = bytes32("NFTStake");
    uint256 private constant VERSION = 1;

    /// @dev The address of the native token wrapper contract.
    address internal immutable nativeTokenWrapper;

    /// @dev ERC20 Reward Token address. See {_mintRewards} below.
    address public rewardToken;

    /// @dev Total amount of reward tokens in the contract.
    uint256 private rewardTokenBalance;

    constructor(address _nativeTokenWrapper) initializer {
        nativeTokenWrapper = _nativeTokenWrapper;
    }

    /// @dev Initiliazes the contract, like a constructor.
    function initialize(
        address _defaultAdmin,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _rewardToken,
        address _stakingToken,
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime
    ) external initializer {
        __ERC2771Context_init_unchained(_trustedForwarders);

        rewardToken = _rewardToken;
        __Staking721_init(_stakingToken);
        _setStakingCondition(_timeUnit, _rewardsPerUnitTime);

        _setupContractURI(_contractURI);
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    /// @dev Returns the module type of the contract.
    function contractType() external pure virtual returns (bytes32) {
        return MODULE_TYPE;
    }

    /// @dev Returns the version of the contract.
    function contractVersion() external pure virtual returns (uint8) {
        return uint8(VERSION);
    }

    /// @dev Lets the contract receive ether to unwrap native tokens.
    receive() external payable {
        require(msg.sender == nativeTokenWrapper, "caller not native token wrapper.");
    }

    /// @dev Admin deposits reward tokens.
    function depositRewardTokens(uint256 _amount) external payable nonReentrant {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not authorized");

        address _rewardToken = rewardToken == CurrencyTransferLib.NATIVE_TOKEN ? nativeTokenWrapper : rewardToken;

        uint256 balanceBefore = IERC20(_rewardToken).balanceOf(address(this));
        CurrencyTransferLib.transferCurrencyWithWrapper(
            rewardToken,
            _msgSender(),
            address(this),
            _amount,
            nativeTokenWrapper
        );
        uint256 actualAmount = IERC20(_rewardToken).balanceOf(address(this)) - balanceBefore;

        rewardTokenBalance += actualAmount;

        emit RewardTokensDepositedByAdmin(actualAmount);
    }

    /// @dev Admin can withdraw excess reward tokens.
    function withdrawRewardTokens(uint256 _amount) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not authorized");

        // to prevent locking of direct-transferred tokens
        rewardTokenBalance = _amount > rewardTokenBalance ? 0 : rewardTokenBalance - _amount;

        CurrencyTransferLib.transferCurrencyWithWrapper(
            rewardToken,
            address(this),
            _msgSender(),
            _amount,
            nativeTokenWrapper
        );

        emit RewardTokensWithdrawnByAdmin(_amount);
    }

    /// @notice View total rewards available in the staking contract.
    function getRewardTokenBalance() external view override returns (uint256) {
        return rewardTokenBalance;
    }

    /*///////////////////////////////////////////////////////////////
                        ERC 165 / 721 logic
    //////////////////////////////////////////////////////////////*/

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view override returns (bytes4) {
        require(isStaking == 2, "Direct transfer");
        return this.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC721ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /*///////////////////////////////////////////////////////////////
                        Transfer Staking Rewards
    //////////////////////////////////////////////////////////////*/

    /// @dev Mint/Transfer ERC20 rewards to the staker.
    function _mintRewards(address _staker, uint256 _rewards) internal override {
        require(_rewards <= rewardTokenBalance, "Not enough reward tokens");
        rewardTokenBalance -= _rewards;
        CurrencyTransferLib.transferCurrencyWithWrapper(
            rewardToken,
            address(this),
            _staker,
            _rewards,
            nativeTokenWrapper
        );
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns whether staking related restrictions can be set in the given execution context.
    function _canSetStakeConditions() internal view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @dev Checks whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /*///////////////////////////////////////////////////////////////
                            Miscellaneous
    //////////////////////////////////////////////////////////////*/

    function _stakeMsgSender() internal view virtual override returns (address) {
        return _msgSender();
    }

    function _msgSender() internal view virtual override returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/interfaces/IOSBStakeFactory.sol";

abstract contract $IOSBStakeFactory is IOSBStakeFactory {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../../contracts/interfaces/ISetting.sol";

abstract contract $ISetting is ISetting {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/OSBStakeFactory.sol";
import "../@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";

contract $OSBStakeFactory is OSBStakeFactory {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    function $__Context_init() external {
        super.__Context_init();
    }

    function $__Context_init_unchained() external {
        super.__Context_init_unchained();
    }

    function $_msgSender() external view returns (address ret0) {
        (ret0) = super._msgSender();
    }

    function $_msgData() external view returns (bytes memory ret0) {
        (ret0) = super._msgData();
    }

    function $_disableInitializers() external {
        super._disableInitializers();
    }

    function $_getInitializedVersion() external view returns (uint8 ret0) {
        (ret0) = super._getInitializedVersion();
    }

    function $_isInitializing() external view returns (bool ret0) {
        (ret0) = super._isInitializing();
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/OSBTokenStake.sol";
import "../@thirdweb-dev/contracts/extension/Staking20Upgradeable.sol";

contract $OSBTokenStake is OSBTokenStake {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor(address _nativeTokenWrapper) OSBTokenStake(_nativeTokenWrapper) {}

    function $nativeTokenWrapper() external view returns (address) {
        return nativeTokenWrapper;
    }

    function $_mintRewards(address _staker,uint256 _rewards) external {
        super._mintRewards(_staker,_rewards);
    }

    function $_canSetStakeConditions() external view returns (bool ret0) {
        (ret0) = super._canSetStakeConditions();
    }

    function $_canSetContractURI() external view returns (bool ret0) {
        (ret0) = super._canSetContractURI();
    }

    function $_stakeMsgSender() external view returns (address ret0) {
        (ret0) = super._stakeMsgSender();
    }

    function $_msgSender() external view returns (address sender) {
        (sender) = super._msgSender();
    }

    function $_msgData() external view returns (bytes memory ret0) {
        (ret0) = super._msgData();
    }

    function $__Staking20_init(address _stakingToken,uint256 _stakingTokenDecimals,uint256 _rewardTokenDecimals) external {
        super.__Staking20_init(_stakingToken,_stakingTokenDecimals,_rewardTokenDecimals);
    }

    function $_stake(uint256 _amount) external {
        super._stake(_amount);
    }

    function $_withdraw(uint256 _amount) external {
        super._withdraw(_amount);
    }

    function $_claimRewards() external {
        super._claimRewards();
    }

    function $_availableRewards(address _staker) external view returns (uint256 _rewards) {
        (_rewards) = super._availableRewards(_staker);
    }

    function $_updateUnclaimedRewardsForStaker(address _staker) external {
        super._updateUnclaimedRewardsForStaker(_staker);
    }

    function $_setStakingCondition(uint256 _timeUnit,uint256 _numerator,uint256 _denominator) external {
        super._setStakingCondition(_timeUnit,_numerator,_denominator);
    }

    function $_calculateRewards(address _staker) external view returns (uint256 _rewards) {
        (_rewards) = super._calculateRewards(_staker);
    }

    function $__ReentrancyGuard_init() external {
        super.__ReentrancyGuard_init();
    }

    function $__ReentrancyGuard_init_unchained() external {
        super.__ReentrancyGuard_init_unchained();
    }

    function $__Multicall_init() external {
        super.__Multicall_init();
    }

    function $__Multicall_init_unchained() external {
        super.__Multicall_init_unchained();
    }

    function $__ERC2771Context_init(address[] calldata trustedForwarder) external {
        super.__ERC2771Context_init(trustedForwarder);
    }

    function $__ERC2771Context_init_unchained(address[] calldata trustedForwarder) external {
        super.__ERC2771Context_init_unchained(trustedForwarder);
    }

    function $__Context_init() external {
        super.__Context_init();
    }

    function $__Context_init_unchained() external {
        super.__Context_init_unchained();
    }

    function $_revokeRole(bytes32 role,address account) external {
        super._revokeRole(role,account);
    }

    function $_setupRole(bytes32 role,address account) external {
        super._setupRole(role,account);
    }

    function $_addMember(bytes32 role,address account) external {
        super._addMember(role,account);
    }

    function $_removeMember(bytes32 role,address account) external {
        super._removeMember(role,account);
    }

    function $_setRoleAdmin(bytes32 role,bytes32 adminRole) external {
        super._setRoleAdmin(role,adminRole);
    }

    function $_checkRole(bytes32 role,address account) external view {
        super._checkRole(role,account);
    }

    function $_checkRoleWithSwitch(bytes32 role,address account) external view {
        super._checkRoleWithSwitch(role,account);
    }

    function $_setupContractURI(string calldata _uri) external {
        super._setupContractURI(_uri);
    }

    function $_disableInitializers() external {
        super._disableInitializers();
    }

    function $_getInitializedVersion() external view returns (uint8 ret0) {
        (ret0) = super._getInitializedVersion();
    }

    function $_isInitializing() external view returns (bool ret0) {
        (ret0) = super._isInitializing();
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IOSBStakeFactory {
    function createNFTStake(
        address _defaultAdmin,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _rewardToken,
        address _stakingToken,
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime
    ) external returns (address);
}

struct ContractInfo {
    uint256 id;
    ContractType contractType;
    address contractAddress;
    address owner;
    address rewardToken;
    address stakingToken;
}

enum ContractType {
    TOKEN_STAKE,
    NFT_STAKE,
    EDITION_STAKE
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface ISetting {
    function checkOnlySuperAdmin(address _caller) external view;
    function checkOnlyAdmin(address _caller) external view;
    function checkOnlySuperAdminOrController(address _caller) external view;
    function checkOnlyController(address _caller) external view;
    function isAdmin(address _account) external view returns(bool);
    function isSuperAdmin(address _account) external view returns(bool);
    function getSuperAdmin() external view returns(address);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {ClonesUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@thirdweb-dev/contracts/staking/NFTStake.sol";
import "@thirdweb-dev/contracts/staking/EditionStake.sol";
import "./OSBTokenStake.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IOSBStakeFactory.sol";

contract OSBStakeFactory is IOSBStakeFactory, ContextUpgradeable {
    ISetting public setting;

    address public libraryNFTStakeAddress;
    address public libraryEditionStakeAddress;
    address public libraryTokenStakeAddress;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public lastId;

    /**
     * @dev Check account is controller from account address.
     */
    mapping(address => bool) public controllers;

    /**
     * @dev Keep track of contract info from created ID.
     */
    mapping(uint256 => ContractInfo) public contractInfos;

    // ============ EVENTS ============

    /// @dev Emit an event when the contract is deployed
    event ContractDeployed(
        address settingAddress,
        address indexed libraryNFTStakeAddress,
        address indexed libraryEditionStakeAddress,
        address indexed libraryTokenStakeAddress
    );

    /// @dev Emit an event when the libraryTokenStakeAddress is updated.
    event SetLibraryTokenStakeAddress(address indexed oldAddress, address indexed newAddress);

    /// @dev Emit an event when the libraryNFTStakeAddress is updated.
    event SetLibraryNFTStakeAddress(address indexed oldAddress, address indexed newAddress);

    /// @dev Emit an event when the libraryEditionStakeAddress is updated.
    event SetLibraryEditionStakeAddress(address indexed oldAddress, address indexed newAddress);

    /// @dev Emit an event when contract TokenStake created.
    event CreateTokenStake(ContractInfo contractInfo);

    /// @dev Emit an event when contract NFTStake created.
    event CreateNFTStake(ContractInfo contractInfo);

    /// @dev Emit an event when contract EditionStake created.
    event CreateEditionStake(ContractInfo contractInfo);

    /**
     * @notice Setting states initial when deploy contract and only called once.
     * @param _settingAddress Setting contract address.
     * @param _libraryNFTStakeAddress OSB721 library address.
     * @param _libraryEditionStakeAddress OSB1155 library address.
     * @param _libraryTokenStakeAddress Crossmint service address.
     */
    function initialize(
        address _settingAddress,
        address _libraryNFTStakeAddress,
        address _libraryEditionStakeAddress,
        address _libraryTokenStakeAddress
    ) external initializer {
        require(_settingAddress != address(0), "Invalid settingAddress");
        require(_libraryNFTStakeAddress != address(0), "Invalid libraryNFTStakeAddress");
        require(_libraryEditionStakeAddress != address(0), "Invalid libraryEditionStakeAddress");
        require(_libraryTokenStakeAddress != address(0), "Invalid libraryTokenStakeAddress");

        setting = ISetting(_settingAddress);
        libraryNFTStakeAddress = _libraryNFTStakeAddress;
        libraryEditionStakeAddress = _libraryEditionStakeAddress;
        libraryTokenStakeAddress = _libraryTokenStakeAddress;

        emit ContractDeployed(_settingAddress, _libraryNFTStakeAddress, _libraryEditionStakeAddress, _libraryTokenStakeAddress);
    }

    // ============ ACCESS CONTROL/SANITY MODIFIERS ============

    modifier onlySuperAdmin() {
        setting.checkOnlySuperAdmin(_msgSender());
        _;
    }

    // ============ OWNER-ONLY ADMIN FUNCTIONS =============

    /**
     * @notice Update the new NFTStake library address
     * @param _libraryNFTStakeAddress Library address
     */
    function setLibraryNFTStakeAddress(address _libraryNFTStakeAddress) external onlySuperAdmin {
        require(_libraryNFTStakeAddress != address(0), "Invalid libraryNFTStakeAddress");
        address oldAddress = libraryNFTStakeAddress;
        libraryNFTStakeAddress = _libraryNFTStakeAddress;
        emit SetLibraryNFTStakeAddress(oldAddress, _libraryNFTStakeAddress);
    }

    /**
     * @notice Update the new EditionStake library address
     * @param _libraryEditionStakeAddress Library address
     */
    function setLibraryEditionStakeAddress(address _libraryEditionStakeAddress) external onlySuperAdmin {
        require(_libraryEditionStakeAddress != address(0), "Invalid libraryEditionStakeAddress");
        address oldAddress = libraryEditionStakeAddress;
        libraryEditionStakeAddress = _libraryEditionStakeAddress;
        emit SetLibraryEditionStakeAddress(oldAddress, _libraryEditionStakeAddress);
    }

    /**
     * @notice Update the new TokenStake library address
     * @param _libraryTokenStakeAddress Library address
     */
    function setLibraryTokenStakeAddress(address _libraryTokenStakeAddress) external onlySuperAdmin {
        require(_libraryTokenStakeAddress != address(0), "Invalid libraryTokenStakeAddress");
        address oldAddress = libraryTokenStakeAddress;
        libraryTokenStakeAddress = _libraryTokenStakeAddress;
        emit SetLibraryTokenStakeAddress(oldAddress, _libraryTokenStakeAddress);
    }

    // ============ PUBLIC FUNCTIONS FOR CREATING =============

    /**
     * @notice Creates a new TokenStake contract and returns its address.
     *
     * @param _defaultAdmin The address of the default admin of the new contract.
     * @param _contractURI The URI of the metadata associated with the new contract.
     * @param _trustedForwarders An array of trusted forwarder addresses.
     * @param _rewardToken The address of the ERC20 token used for rewards.
     * @param _stakingToken The address of the ERC20 token used for staking.
     * @param _timeUnit The time unit for reward calculations.
     *
     * If reward ratio is 1/20, this implies that there will be 1 Reward token given out for every 20 tokens staked.
     * The numerator and denominator of the reward ratio should be set separately (1 and 20 in this case respectively).
     * @param _rewardRatioNumerator //
     * @param _rewardRatioDenominator //
     *
     * @return The address of the newly created contract.
     */
    function createTokenStake(
        address _defaultAdmin,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _rewardToken,
        address _stakingToken,
        uint256 _timeUnit,
        uint256 _rewardRatioNumerator,
        uint256 _rewardRatioDenominator
    ) external returns (address) {
        lastId.increment();
        bytes32 salt = keccak256(abi.encodePacked(lastId.current()));
        address deployedContract;

        OSBTokenStake _tokenStake = OSBTokenStake(payable(ClonesUpgradeable.cloneDeterministic(libraryTokenStakeAddress, salt)));
        _tokenStake.initialize(
            _defaultAdmin,
            _contractURI,
            _trustedForwarders,
            _rewardToken,
            _stakingToken,
            _timeUnit,
            _rewardRatioNumerator,
            _rewardRatioDenominator
        );
        deployedContract = address(_tokenStake);

        ContractInfo memory contractInfo = _createStake(ContractType.TOKEN_STAKE, deployedContract, _defaultAdmin, _rewardToken, _stakingToken);

        emit CreateTokenStake(contractInfo);
        return contractInfo.contractAddress;
    }

    /**
     * @notice Creates a new NFTStake contract and returns its address.
     *
     * @param _defaultAdmin The address of the default admin of the new contract.
     * @param _contractURI The URI of the metadata associated with the new contract.
     * @param _trustedForwarders An array of trusted forwarder addresses.
     * @param _rewardToken The address of the ERC20 token used for rewards.
     * @param _stakingToken The address of the ERC721 token used for staking.
     * @param _timeUnit The time unit for reward calculations.
     * @param _rewardsPerUnitTime The amount of rewards per unit of time.
     *
     * @return The address of the newly created contract.
     */
    function createNFTStake(
        address _defaultAdmin,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _rewardToken,
        address _stakingToken,
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime
    ) external returns (address) {
        lastId.increment();
        bytes32 salt = keccak256(abi.encodePacked(lastId.current()));
        address deployedContract;

        NFTStake _nftStake = NFTStake(payable(ClonesUpgradeable.cloneDeterministic(libraryNFTStakeAddress, salt)));
        _nftStake.initialize(_defaultAdmin, _contractURI, _trustedForwarders, _rewardToken, _stakingToken, _timeUnit, _rewardsPerUnitTime);
        deployedContract = address(_nftStake);

        ContractInfo memory contractInfo = _createStake(ContractType.NFT_STAKE, deployedContract, _defaultAdmin, _rewardToken, _stakingToken);

        emit CreateNFTStake(contractInfo);
        return contractInfo.contractAddress;
    }

    /**
     * @notice Creates a new EditionStake contract and returns its address.
     *
     * @param _defaultAdmin The address of the default admin of the new contract.
     * @param _contractURI The URI of the metadata associated with the new contract.
     * @param _trustedForwarders An array of trusted forwarder addresses.
     * @param _rewardToken The address of the ERC20 token used for rewards.
     * @param _stakingToken The address of the ERC1155 token used for staking.
     * @param _timeUnit The time unit for reward calculations.
     * @param _rewardsPerUnitTime The amount of rewards per unit of time.
     *
     * @return The address of the newly created contract.
     */
    function createEditionStake(
        address _defaultAdmin,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _rewardToken,
        address _stakingToken,
        uint256 _timeUnit,
        uint256 _rewardsPerUnitTime
    ) external returns (address) {
        lastId.increment();
        bytes32 salt = keccak256(abi.encodePacked(lastId.current()));
        address deployedContract;

        EditionStake _editionStake = EditionStake(payable(ClonesUpgradeable.cloneDeterministic(libraryEditionStakeAddress, salt)));
        _editionStake.initialize(_defaultAdmin, _contractURI, _trustedForwarders, _rewardToken, _stakingToken, _timeUnit, _rewardsPerUnitTime);
        deployedContract = address(_editionStake);

        ContractInfo memory contractInfo = _createStake(ContractType.EDITION_STAKE, deployedContract, _defaultAdmin, _rewardToken, _stakingToken);

        emit CreateEditionStake(contractInfo);
        return contractInfo.contractAddress;
    }

    function _createStake(
        ContractType _contractType,
        address _contractAddress,
        address _defaultAdmin,
        address _rewardToken,
        address _stakingToken
    ) private returns (ContractInfo memory) {
        ContractInfo storage contractInfo = contractInfos[lastId.current()];
        contractInfo.id = lastId.current();
        contractInfo.contractType = _contractType;
        contractInfo.contractAddress = _contractAddress;
        contractInfo.owner = _defaultAdmin;
        contractInfo.rewardToken = _rewardToken;
        contractInfo.stakingToken = _stakingToken;

        return contractInfo;
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.16;

// Meta transactions
import "@thirdweb-dev/contracts/openzeppelin-presets/metatx/ERC2771ContextUpgradeable.sol";

// Utils
import "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import "@thirdweb-dev/contracts/lib/CurrencyTransferLib.sol";
import "@thirdweb-dev/contracts/eip/interface/IERC20Metadata.sol";

//  ==========  Features    ==========

import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";
import "@thirdweb-dev/contracts/extension/PermissionsEnumerable.sol";
import {Staking20Upgradeable} from "@thirdweb-dev/contracts/extension/Staking20Upgradeable.sol";
import "@thirdweb-dev/contracts/interfaces/staking/ITokenStake.sol";

contract OSBTokenStake is
    Initializable,
    ContractMetadata,
    PermissionsEnumerable,
    ERC2771ContextUpgradeable,
    MulticallUpgradeable,
    Staking20Upgradeable,
    ITokenStake
{
    bytes32 private constant MODULE_TYPE = bytes32("TokenStake");
    uint256 private constant VERSION = 1;

    /// @dev ERC20 Reward Token address. See {_mintRewards} below.
    address public rewardToken;

    /// @dev Total amount of reward tokens in the contract.
    uint256 private rewardTokenBalance;

    constructor(address _nativeTokenWrapper) initializer Staking20Upgradeable(_nativeTokenWrapper) {}

    /// @dev Initiliazes the contract, like a constructor.
    function initialize(
        address _defaultAdmin,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _rewardToken,
        address _stakingToken,
        uint256 _timeUnit,
        uint256 _rewardRatioNumerator,
        uint256 _rewardRatioDenominator
    ) external initializer {
        __ERC2771Context_init_unchained(_trustedForwarders);

        require(_rewardToken != _stakingToken, "Reward Token and Staking Token can't be same.");
        rewardToken = _rewardToken;

        uint256 _stakingTokenDecimals = _stakingToken == CurrencyTransferLib.NATIVE_TOKEN ? 18 : IERC20Metadata(_stakingToken).decimals();
        uint256 _rewardTokenDecimals = _rewardToken == CurrencyTransferLib.NATIVE_TOKEN ? 18 : IERC20Metadata(_rewardToken).decimals();

        __Staking20_init(_stakingToken, _stakingTokenDecimals, _rewardTokenDecimals);
        _setStakingCondition(_timeUnit, _rewardRatioNumerator, _rewardRatioDenominator);

        _setupContractURI(_contractURI);
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    /// @dev Returns the module type of the contract.
    function contractType() external pure virtual returns (bytes32) {
        return MODULE_TYPE;
    }

    /// @dev Returns the version of the contract.
    function contractVersion() external pure virtual returns (uint8) {
        return uint8(VERSION);
    }

    /// @dev Lets the contract receive ether to unwrap native tokens.
    receive() external payable {
        require(msg.sender == nativeTokenWrapper, "caller not native token wrapper.");
    }

    /// @dev Admin deposits reward tokens.
    function depositRewardTokens(uint256 _amount) external payable nonReentrant {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not authorized");

        address _rewardToken = rewardToken == CurrencyTransferLib.NATIVE_TOKEN ? nativeTokenWrapper : rewardToken;

        uint256 balanceBefore = IERC20(_rewardToken).balanceOf(address(this));
        CurrencyTransferLib.transferCurrencyWithWrapper(rewardToken, _msgSender(), address(this), _amount, nativeTokenWrapper);
        uint256 actualAmount = IERC20(_rewardToken).balanceOf(address(this)) - balanceBefore;

        rewardTokenBalance += actualAmount;

        emit RewardTokensDepositedByAdmin(actualAmount);
    }

    /// @dev Admin can withdraw excess reward tokens.
    function withdrawRewardTokens(uint256 _amount) external nonReentrant {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not authorized");

        // to prevent locking of direct-transferred tokens
        rewardTokenBalance = _amount > rewardTokenBalance ? 0 : rewardTokenBalance - _amount;

        CurrencyTransferLib.transferCurrencyWithWrapper(rewardToken, address(this), _msgSender(), _amount, nativeTokenWrapper);

        // The withdrawal shouldn't reduce staking token balance. `>=` accounts for any accidental transfers.
        address _stakingToken = stakingToken == CurrencyTransferLib.NATIVE_TOKEN ? nativeTokenWrapper : stakingToken;
        require(IERC20(_stakingToken).balanceOf(address(this)) >= stakingTokenBalance, "Staking token balance reduced.");

        emit RewardTokensWithdrawnByAdmin(_amount);
    }

    /// @notice View total rewards available in the staking contract.
    function getRewardTokenBalance() external view override returns (uint256) {
        return rewardTokenBalance;
    }

    /*///////////////////////////////////////////////////////////////
                        Transfer Staking Rewards
    //////////////////////////////////////////////////////////////*/

    /// @dev Mint/Transfer ERC20 rewards to the staker.
    function _mintRewards(address _staker, uint256 _rewards) internal override {
        require(_rewards <= rewardTokenBalance, "Not enough reward tokens");
        rewardTokenBalance -= _rewards;
        CurrencyTransferLib.transferCurrencyWithWrapper(rewardToken, address(this), _staker, _rewards, nativeTokenWrapper);
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns whether staking related restrictions can be set in the given execution context.
    function _canSetStakeConditions() internal view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @dev Checks whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view override returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /*///////////////////////////////////////////////////////////////
                            Miscellaneous
    //////////////////////////////////////////////////////////////*/

    function _stakeMsgSender() internal view virtual override returns (address) {
        return _msgSender();
    }

    function _msgSender() internal view virtual override returns (address sender) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }
}