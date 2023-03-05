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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981Upgradeable is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
pragma solidity >=0.8.0 <0.9.0;

/// @title NFT Marketplace interface for ExoWorlds
/// @author Tamer Fouad
interface IMarketplace {
	/// @notice Two types of listings. `Direct`, `Auction`
	enum ListingType {
		Direct,
		Auction
	}

	/// @notice Offer infomation for making an offer or for placing a bid
	/// @param tokenId The token id that received the offer or bid
	/// @param offeror The offeror address
	/// @param offerPrice The price of offer or bid
	struct Offer {
		address offeror;
		uint256 tokenId;
		uint256 offerPrice;
	}

	/// @dev The struct for the parameter of `createMarketItem` function
	/// @param tokenId The token id of the NFT
	/// @param startTime  The unix timestamp of auction start time
	/// @param secondsUntilEndTime The unix time of auction period.
	/// @param reserveTokenPrice The reserve price for auction listing, ignore when direct listing
	/// @param buyoutTokenPrice The token price for direct sale, buyout price for an auction
	/// @param listingType The listing type - Direct | Auction.
	struct MarketItemParameters {
		uint256 tokenId;
		uint256 startTime;
		uint256 secondsUntilEndTime;
		uint256 reserveTokenPrice;
		uint256 buyoutTokenPrice;
		ListingType listingType;
	}

	/// @dev Struct for the marketplace item
	/// @param tokenOwner The token owner address
	/// @param itemId The marketplace item id
	/// @param tokenId The token id of the NFT
	/// @param startTime  The unix timestamp of auction start time
	/// @param endTime The unix timestamp of auction end time
	/// @param reserveTokenPrice The reserve price for auction listing, ignore when direct listing
	/// @param buyoutTokenPrice The token price for direct sale, buyout price for an auction
	/// @param listingType The listing type - Direct | Auction
	struct MarketItem {
		address tokenOwner;
		uint256 itemId;
		uint256 tokenId;
		uint256 startTime;
		uint256 endTime;
		uint256 reserveTokenPrice;
		uint256 buyoutTokenPrice;
		ListingType listingType;
	}

	/// @notice Emitted when a new market item is created
	/// @param itemId The marketplace item id
	/// @param tokenId The token id of market item
	/// @param lister The address of listing creator
	/// @param newItem The struct of new item
	event CreateMarketItem(
		uint256 indexed itemId,
		uint256 indexed tokenId,
		address indexed lister,
		MarketItem newItem
	);

	/// @notice Emitted when a market item is updated.
	/// @param itemId The marketplace item id
	/// @param tokenId The token id of item market item
	/// @param lister The address of the listing creator
	/// @param updatedItem The struct of updated item
	event UpdateMarketItem(
		uint256 indexed itemId,
		uint256 indexed tokenId,
		address indexed lister,
		MarketItem updatedItem
	);

	/// @notice Emitted when a market item is removed.
	/// @param itemId The marketplace item id
	/// @param tokenId The token id of item market item
	/// @param lister The address of the listing creator
	/// @param removeItem The struct of removed item
	event RemoveMarketItem(
		uint256 indexed itemId,
		uint256 indexed tokenId,
		address indexed lister,
		MarketItem removeItem
	);

	/// @dev Emitted when a direct sale item sold
	/// @param seller The address of seller
	/// @param buyer The address of buyer
	/// @param itemId The marketplace item id
	/// @param tokenId The token id of market item
	/// @param buyoutPrice The buyout price
	event NewSale(
		address indexed seller,
		address buyer,
		uint256 indexed itemId,
		uint256 indexed tokenId,
		uint256 buyoutPrice
	);

	/// @dev Emitted when a new offer placed in direct sale or a new bid placed in an auction
	/// @param offeror The address of offeror
	/// @param itemId The marketplace item id
	/// @param tokenId The token id of market item
	/// @param offerPrice The price of an offer or a bid amount
	/// @param listingType The type of listing `Direct`, `Auction`
	event NewOffer(
		address indexed offeror,
		uint256 itemId,
		uint256 indexed tokenId,
		uint256 offerPrice,
		ListingType indexed listingType
	);

	/// @dev Emitted when an auction is closed
	/// @param itemId The marketplace item id
	/// @param tokenId The token id of market item
	/// @param auctionCreator The address of the auction creator
	/// @param winningBidder The address of winner in the auction
	/// @param cancelled The flag of cancelled or not
	event AuctionClosed(
		uint256 itemId,
		uint256 indexed tokenId,
		address indexed auctionCreator,
		address winningBidder,
		bool indexed cancelled
	);

	/// @dev Emitted when the market cut fee
	/// @param newFee The percent for market cut fee
	event MarketFeeUpdate(uint96 newFee);

	/// @dev Emitted when auction buffer time, increaseBps are updated
	/// @param timeBuffer The time for increase time buffer in auction
	/// @param bidBufferBps The percent for the increase of bid amount
	event AuctionBuffersUpdated(uint64 timeBuffer, uint96 bidBufferBps);

	/// @dev Emitted when the `restrictedOwnerOnly` is updated.
	/// @param restricted The flag for the restricted
	event ListingRestricted(bool restricted);

	/// @notice Create a direct sale item in the marketplace
	/// @dev Make a new `MarketItemParameters` param with `_tokenId` and `_price`
	/// , and call `createMarketItem` function
	/// @param _tokenId The token id
	/// @param _price The price for direct sale
	function createDirectSaleItem(uint256 _tokenId, uint256 _price) external;

	/**
	 * @notice Lister can edit market item
	 * @dev Lister edits `reserveTokenPrice`, `buyoutTokenPrice`, `startTime`, `secondsUntilEndTime` of market item
	 *
	 * @param _tokenId The token id to edit
	 * @param _reserveTokenPrice The minimum price for the auction item
	 * @param _buyoutTokenPrice The buyout price for the market item
	 * @param _startTime The unix timestamp of the auction start time
	 * @param _secondsUntilEndTime The auction period time
	 *
	 * Requirements:
	 *
	 * - Only `lister` can edit market item.
	 * - Cannot edit if auction is already started or if invalid `buyoutPrice`
	 *
	 * Emits a {UpdateMarketItem} event
	 */
	function updateMarketItem(
		uint256 _tokenId,
		uint256 _reserveTokenPrice,
		uint256 _buyoutTokenPrice,
		uint256 _startTime,
		uint256 _secondsUntilEndTime
	) external;

	/// @notice Update direct sale item in MP
	/// @dev Update direct sale item with `_tokenId`, `_price`
	/// @param _tokenId The NFT id and uses `assetAddress`. only for MP V1
	/// @param _price The buyout price of NFT
	/// Same requirements as `updateMarketItem`
	/// Emits a {UpdateMarketItem} event
	function updateDirectSaleItem(uint256 _tokenId, uint256 _price) external;

	/// @notice Remove direct sale item from MP
	/// @dev Remove item from active listing array
	/// Update mapping from `itemId` to listing index, `tokenId` to listing index
	/// Requirements:
	/// - Only owner or admin can remove item
	function removeDirectSaleItem(uint256 _tokenId) external;

	/**
	 * @notice Buy a direct sale item
	 * @dev Execute sale:
	 * 1. Split payment
	 * 2. Transfer item from `seller` to `buyer`
	 * 3. Remove item from active listing array
	 * @param _tokenId Token Id
	 *
	 * Requirements:
	 *
	 * - Seller cannot call this function
	 * - Buyer must pay `buyoutTokenPrice` of item
	 * - Market item's `listingType` must be `Direct`
	 *
	 * Emits a {NewSale} event
	 */
	function buy(uint256 _tokenId) external payable;

	/**
	 * @notice Make an offer to the direct sale item or place a bid to the auction
	 * @dev Create an offer, Replace winning bid
	 * @param _tokenId The token id of MP item
	 *
	 * Requirements:
	 *
	 * - MP item must exists
	 * - Caller cannot be the listing creator
	 * - `offerPrice` must be greater than 0.
	 * - Auction must be started.
	 * - Check other requirements in `placeBid` and `placeOffer`
	 */
	function offer(uint256 _tokenId) external payable;

	/**
	 * @notice Listing creator accept an offer in direct sale item
	 * @dev Execut sale: Refer `buy` function
	 *
	 * @param _tokenId The token id of MP item
	 * @param _offeror The address of the offeror
	 *
	 * Requirements:
	 *
	 * - Offer must be valid.
	 */
	function acceptOffer(uint256 _tokenId, address _offeror) external;

	/**
	 * @notice Offeror cancel an offer and claim VET
	 * @param _tokenId The token id of MP item
	 *
	 * Requirements:
	 *
	 * - Offer must be valid
	 */
	function cancelOffer(uint256 _tokenId) external;

	/**
	 * @notice Close an auction
	 * @dev If the auction is not started or no bid, cancel an auction
	 * If the auction has bidder, close an auction with winning bidder
	 * @param _tokenId The token id of MP item
	 *
	 * Requirements:
	 *
	 * - Only admin can call this function
	 * - Offer must be valid
	 */
	function closeAuction(uint256 _tokenId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IMarketplace.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract MPV2 is
    Initializable,
	IMarketplace,
	OwnableUpgradeable,
	IERC721ReceiverUpgradeable,
	ReentrancyGuardUpgradeable,
    PausableUpgradeable

{
	using CountersUpgradeable for CountersUpgradeable.Counter;

	// Market item counter
	CountersUpgradeable.Counter private _itemCounter;

	// NFT contract address for MP V1: ExoWorlds's contract address
	address private _assetContract;

	// The max bps of the contract. 10000 == 100 %
	uint96 private constant MAX_BPS = 10000;

	// Active listing MP items
	MarketItem[] private _items;

	// Whether listing is restricted by owner.
	bool public restrictedOwnerOnly;

	// Increase `endTime` of auction when new winning bid coming after closed the auction ~5 minutes ago.
	uint64 public timeBuffer ;

	// The minimum increase precent required from the previous winning bid. Default: 5%.
	uint96 public bidBufferBps;

	// Mapping from MP `itemId` to index in listing array
	mapping(uint256 => uint256) private _allItemsIndex;

	// Mapping from MP `tokenId` to index in listing array
	mapping(uint256 => uint256) private _allTokensIndex;

	// Mapping from `tokenId` to offeror address => offer info on a direct listing.
	mapping(uint256 => mapping(address => Offer)) private _offers;

	// Mapping from `tokenId` to current winning bid info in an auction.
	mapping(uint256 => Offer) private _winningBid;

	/// @dev Modifier used internally to accept only new offer.
	modifier onlyNewOffer(uint256 _tokenId, address _offeror) {
		Offer memory targetOffer = _offers[_tokenId][_offeror];
		require(
			targetOffer.offeror == address(0),
			"Marketplace: offer already exists, cancel offer first"
		);
		_;
	}

	/// @dev Modifier used internally to throws if called by any account other than the owner.
	modifier onlyOwnerWhenRestricted() {
		require(
			!restrictedOwnerOnly || owner() == _msgSender(),
			"Marketplace: caller must be owner"
		);
		_;
	}

 	function initialize() public initializer {
		__Pausable_init();
		__Ownable_init();
		timeBuffer = 5 minutes;
		bidBufferBps = 500;
    }


	/// @dev Lets the contract accept VET.
	receive() external payable {}

    /// @dev Pause all transfers
	function pause() public onlyOwner {
		_pause();
	}

	/// @dev Returns to normal state
	function unpause() public onlyOwner {
		_unpause();
	}

	/// @inheritdoc	IMarketplace
	function createDirectSaleItem(uint256 _tokenId, uint256 _price)
		external
		override
		onlyOwnerWhenRestricted
        whenNotPaused
	{
		MarketItemParameters memory newItemParams = MarketItemParameters({
			tokenId: _tokenId,
			startTime: 0,
			secondsUntilEndTime: 0,
			reserveTokenPrice: 0,
			buyoutTokenPrice: _price,
			listingType: ListingType.Direct
		});
		createMarketItem(newItemParams);
	}

	/// @inheritdoc	IMarketplace
	function updateMarketItem(
		uint256 _tokenId,
		uint256 _reserveTokenPrice,
		uint256 _buyoutTokenPrice,
		uint256 _startTime,
		uint256 _secondsUntilEndTime
	) 
    external 
    override 
    whenNotPaused 
    {
		uint256 index = _allTokensIndex[_tokenId];
		require(index > 0, "Marketplace: non exist marketplace item");
		require(
			_items[index - 1].tokenOwner == _msgSender(),
			"Marketplace: caller is not listing creator"
		);

		MarketItem memory targetItem = _items[index - 1];
		bool isAuction = targetItem.listingType == ListingType.Auction;

		// Can only edit auction listing before it starts.
		if (isAuction) {
			require(
				block.timestamp < targetItem.startTime,
				"Marketplace: auction has already started"
			);
			require(
				_buyoutTokenPrice >= _reserveTokenPrice,
				"Marketplace: reserve price exceeds buyout price"
			);
		}

		uint256 newStartTime = _startTime == 0 ? targetItem.startTime : _startTime;
		_items[index - 1] = MarketItem({
			itemId: targetItem.itemId,
			tokenOwner: targetItem.tokenOwner,
			tokenId: _tokenId,
			startTime: newStartTime,
			endTime: _secondsUntilEndTime == 0
				? targetItem.endTime
				: newStartTime + _secondsUntilEndTime,
			reserveTokenPrice: _reserveTokenPrice,
			buyoutTokenPrice: _buyoutTokenPrice,
			listingType: targetItem.listingType
		});

		emit UpdateMarketItem(
			targetItem.itemId,
			targetItem.tokenId,
			targetItem.tokenOwner,
			_items[index - 1]
		);
	}

	/// @inheritdoc IMarketplace
	function updateDirectSaleItem(uint256 _tokenId, uint256 _price)
		external
		override
        whenNotPaused
	{
		uint256 index = _allTokensIndex[_tokenId];
		require(index > 0, "Marketplace: non exist marketplace item");
		require(
			_items[index - 1].tokenOwner == _msgSender(),
			"Marketplace: caller is not listing creator"
		);

		MarketItem memory targetItem = _items[index - 1];

		_items[index - 1] = MarketItem({
			itemId: targetItem.itemId,
			tokenOwner: targetItem.tokenOwner,
			tokenId: _tokenId,
			startTime: 0,
			endTime: 0,
			reserveTokenPrice: 0,
			buyoutTokenPrice: _price,
			listingType: targetItem.listingType
		});

		emit UpdateMarketItem(
			targetItem.itemId,
			_tokenId,
			targetItem.tokenOwner,
			_items[index - 1]
		);
	}

	/// @inheritdoc IMarketplace
	function removeDirectSaleItem(uint256 _tokenId) external override whenNotPaused {
		uint256 index = _allTokensIndex[_tokenId];
		require(index > 0, "Marketplace: non exist marketplace item");

		MarketItem memory item = _items[index - 1];
		require(
			_msgSender() == item.tokenOwner || _msgSender() == owner(),
			"Marketplace: Caller is neither admin nor token owner"
		);

		_removeItemFromAllItemsEnumeration(_tokenId);
	}

	/// @inheritdoc IMarketplace
	function buy(uint256 _tokenId) external payable override nonReentrant whenNotPaused {
		MarketItem memory targetItem = getItemByTokenId(_tokenId);
		address buyer = _msgSender();
		require(
			buyer != targetItem.tokenOwner,
			"Marketplace: you cannot buy yourself"
		);
		// Check whether the settled total price
		require(
			msg.value == targetItem.buyoutTokenPrice,
			"Marketplace: invalid price"
		);

		executeSale(targetItem, buyer, targetItem.buyoutTokenPrice);
	}

	/// @inheritdoc IMarketplace
	function offer(uint256 _tokenId) external payable override nonReentrant whenNotPaused {
		MarketItem memory targetItem = getItemByTokenId(_tokenId);
		require(
			_msgSender() != targetItem.tokenOwner,
			"Marketplace: caller cannot be listing creator"
		);
		require(
			block.timestamp > targetItem.startTime,
			"Marketplace: inactive item"
		);
		uint256 offerPrice = msg.value;
		require(offerPrice > 0, "Marketplace: invalid offer price");

		Offer memory newOffer = Offer({
			offeror: _msgSender(),
			tokenId: targetItem.tokenId,
			offerPrice: offerPrice
		});

		if (targetItem.listingType == ListingType.Auction) {
			placeBid(targetItem, newOffer);
		} else if (targetItem.listingType == ListingType.Direct) {
			placeOffer(targetItem, newOffer);
		}
	}

	/// @inheritdoc IMarketplace
	function acceptOffer(uint256 _tokenId, address _offeror)
		external
		override
		nonReentrant
        whenNotPaused
	{
		uint256 index = _allTokensIndex[_tokenId];
		require(index > 0, "Marketplace: non exist marketplace item");
		require(
			_items[index - 1].tokenOwner == _msgSender(),
			"Marketplace: caller is not listing creator"
		);
		MarketItem memory targetItem = _items[index - 1];

		Offer memory targetOffer = _offers[_tokenId][_offeror];

		require(
			targetOffer.offeror != address(0) && targetOffer.offerPrice > 0,
			"Marketplace: invalid offeror"
		);

		delete _offers[_tokenId][_offeror];

		executeSale(targetItem, _offeror, targetOffer.offerPrice);
	}

	/// @inheritdoc IMarketplace
	function cancelOffer(uint256 _tokenId) external override nonReentrant whenNotPaused {
		address offeror = _msgSender();
		Offer memory targetOffer = _offers[_tokenId][offeror];
		require(
			targetOffer.offeror != address(0) && targetOffer.offerPrice > 0,
			"Marketplace: invalid offer"
		);
		transferCurrency(offeror, targetOffer.offerPrice);
		delete _offers[_tokenId][offeror];
	}

	/// @inheritdoc IMarketplace
	function closeAuction(uint256 _tokenId)
		external
		override
		onlyOwner
		nonReentrant
        whenNotPaused
	{
		MarketItem memory targetItem = getItemByTokenId(_tokenId);

		require(
			targetItem.listingType == ListingType.Auction,
			"Marketplace: not an auction"
		);

		Offer memory targetBid = _winningBid[_tokenId];

		bool toCancel = targetItem.startTime > block.timestamp ||
			targetBid.offeror == address(0);

		if (toCancel) {
			_cancelAuction(targetItem);
		} else {
			payout(targetBid.offerPrice, targetItem);
			_closeAuctionForBidder(targetItem, targetBid);
		}
	}

	/// @dev Sets `_assetContract` address for our collection in MP V1
	function setAssetAddress(address assetContract_) external onlyOwner  {
		_assetContract = assetContract_;
	}

	/// @dev Update auction buffers - timeBuffer, and increase bid buffer BPS
	function setAuctionBuffers(uint64 _timeBuffer, uint96 _bidBufferBps)
		external
		onlyOwner
	{
		require(_bidBufferBps < MAX_BPS, "Marketplace: invalid BPS");

		timeBuffer = _timeBuffer;
		bidBufferBps = _bidBufferBps;

		emit AuctionBuffersUpdated(_timeBuffer, _bidBufferBps);
	}

	/// @dev Owner can restrict listing.
	function setRestrictedOwnerOnly(bool restricted) external onlyOwner {
		restrictedOwnerOnly = restricted;
		emit ListingRestricted(restricted);
	}

	/// @dev Gets active listing - `_items`
	function getActiveItems() external view returns (MarketItem[] memory) {
		return _items;
	}

	/// @dev Gets active listing count
	function getActiveItemsCount() external view returns (uint256) {
		return _items.length+10;
	}

	/// @dev Gets an offer with `_tokenId`, `_offeror`
	function getOffer(uint256 _tokenId, address _offeror)
		external
		view
		returns (Offer memory)
	{
		return _offers[_tokenId][_offeror];
	}

	/// @dev Gets an winning bid for `_tokenId`
	function getWinningBid(uint256 _tokenId)
		external
		view
		returns (Offer memory)
	{
		return _winningBid[_tokenId];
	}

	/// @dev Gets current asset contract address for MP V1
	function nftAddress() external view returns (address) {
		return _assetContract;
	}

	/**
	 *   ERC 721 Receiver functions.
	 **/
	function onERC721Received(
		address,
		address,
		uint256,
		bytes calldata
	) external pure override returns (bytes4) {
		return this.onERC721Received.selector;
	}

	/**
	 * @notice Create a market item in MP
	 * @dev Validate NFT ownership and approval of MP, push item to active listing array
	 * Update mapping itemId => array index, token id
	 * @param _params a market item params
	 *
	 * Requirments:
	 *
	 * - If `listingType` is Auction, `secondsUntilEndTime` must be greater than 0.
	 * - NFT must not listed in MP
	 * - `lister` owned NFT and MP must approved
	 * - If `listingType` is Auction, then `reserveTokenPrice` must be smaller than `buyoutTokenPrice`
	 *
	 * Emits a {CreateMarketItem} event
	 */
	function createMarketItem(MarketItemParameters memory _params)
		public
		onlyOwnerWhenRestricted
        whenNotPaused
	{
		require(
			_allTokensIndex[_params.tokenId] == 0,
			"Marketplace: market item already exists"
		);
		require(
			_params.secondsUntilEndTime > 0 ||
				_params.listingType == ListingType.Direct,
			"Marketplace: secondsUntilEndTime must be greater than 0 for auction"
		);

		// Get values to populate `Listing`.
		uint256 itemId = _itemCounter.current();
		address tokenOwner = _msgSender();

		validateOwnershipAndApproval(tokenOwner, _params.tokenId);

		uint256 startTime = _params.startTime < block.timestamp
			? block.timestamp
			: _params.startTime;
		uint256 endTime = _params.listingType == ListingType.Auction
			? startTime + _params.secondsUntilEndTime
			: 0;
		MarketItem memory newItem = MarketItem({
			itemId: itemId,
			tokenOwner: tokenOwner,
			tokenId: _params.tokenId,
			startTime: startTime,
			endTime: endTime,
			reserveTokenPrice: _params.reserveTokenPrice,
			buyoutTokenPrice: _params.buyoutTokenPrice,
			listingType: _params.listingType
		});

		// Tokens listed for sale in an auction are escrowed in Marketplace.
		if (newItem.listingType == ListingType.Auction) {
			require(
				newItem.buyoutTokenPrice >= newItem.reserveTokenPrice,
				"Marketplace: reserve price exceeds buyout price"
			);
			transferMarketItem(tokenOwner, address(this), newItem);
		}
		_items.push(newItem);
		_allItemsIndex[itemId] = _items.length;
		_allTokensIndex[_params.tokenId] = _items.length;
		_itemCounter.increment();

		emit CreateMarketItem(itemId, _params.tokenId, tokenOwner, newItem);
	}

	/// @dev Gets a MP item by MP item id
	function getItemByMarketId(uint256 _itemId)
		public
		view
		returns (MarketItem memory)
	{
		uint256 index = _allItemsIndex[_itemId];
		require(index > 0, "Marketplace: non exist marketplace item");
		MarketItem memory targetItem = _items[index - 1];
		return targetItem;
	}

	/// @dev Gets a MP item by item id
	function getItemByTokenId(uint256 _tokenId)
		public
		view
		returns (MarketItem memory)
	{
		uint256 index = _allTokensIndex[_tokenId];
		require(index > 0, "Marketplace: non exist marketplace item");
		MarketItem memory targetItem = _items[index - 1];
		return targetItem;
	}

	/// @dev Performs a direct listing sale.
	/**
	 * @notice Execute sale for direct sale item
	 * @dev Validate item, payment split and transfer item\
	 *
	 * @param _targetItem Market item to execute sale
	 * @param _buyer buyer address
	 * @param _price buyout price
	 *
	 * Requirements:
	 *
	 * - `listingType` must be direct sale item
	 * - Item must be active
	 * - Total price must be greater than `market cut fee` + `royalty fee`
	 *
	 * Emits a {NewSale} event
	 */
	function executeSale(
		MarketItem memory _targetItem,
		address _buyer,
		uint256 _price
	) internal  {
		validateDirectSale(_targetItem);

		payout(_price, _targetItem);
		transferMarketItem(_targetItem.tokenOwner, _buyer, _targetItem);

		_removeItemFromAllItemsEnumeration(_targetItem.tokenId);

		emit NewSale(
			_targetItem.tokenOwner,
			_buyer,
			_targetItem.itemId,
			_targetItem.tokenId,
			_price
		);
	}

	/**
	 * @notice Place an offer to a direct sale item
	 * @dev Create new offer in `_offers` mapping
	 * @param _targetItem target marketplace item
	 * @param _newOffer new offer struct
	 *
	 * Emits a {NewOffer} event
	 */
	function placeOffer(MarketItem memory _targetItem, Offer memory _newOffer)
		internal
		onlyNewOffer(_targetItem.tokenId, _newOffer.offeror)
	{
		_offers[_targetItem.tokenId][_newOffer.offeror] = _newOffer;

		emit NewOffer(
			_newOffer.offeror,
			_targetItem.itemId,
			_targetItem.tokenId,
			_newOffer.offerPrice,
			_targetItem.listingType
		);
	}

	/**
	 * @notice Place a bid to an auction
	 * @dev Update winning bid
	 * Refund previous winning bid amount.
	 * If bid amount is at `buyoutPrice`, then close auction and execute sale
	 * @param _targetItem target auction item
	 * @param _incomingBid new offer(bid) struct
	 *
	 * Requirements:
	 *
	 * - Bid must be winning bid
	 *
	 * Emits a {NewOffer} event
	 */
	function placeBid(MarketItem memory _targetItem, Offer memory _incomingBid)
		internal
	{
		Offer memory currentWinningBid = _winningBid[_targetItem.tokenId];
		uint256 currentOfferPrice = currentWinningBid.offerPrice;
		uint256 incomingOfferPrice = _incomingBid.offerPrice;

		require(
			isNewWinningBid(
				_targetItem.reserveTokenPrice,
				currentOfferPrice,
				incomingOfferPrice
			),
			"Marketplace: not winning bid"
		);

		// Refund VET to previous winning bidder.
		if (currentWinningBid.offeror != address(0) && currentOfferPrice > 0) {
			transferCurrency(currentWinningBid.offeror, currentOfferPrice);
		}

		// Close auction and execute sale if incoming bid amount is at buyout price.
		if (
			_targetItem.buyoutTokenPrice > 0 &&
			incomingOfferPrice >= _targetItem.buyoutTokenPrice
		) {
			payout(incomingOfferPrice, _targetItem);
			_closeAuctionForBidder(_targetItem, _incomingBid);
		} else {
			// Update the winning bid and listing's end time before external contract calls.
			_winningBid[_targetItem.tokenId] = _incomingBid;

			if (_targetItem.endTime - block.timestamp <= timeBuffer) {
				_targetItem.endTime += timeBuffer;
				uint256 index = _allItemsIndex[_targetItem.itemId] - 1;
				_items[index] = _targetItem;
			}

			// Emit a new offer event
			emit NewOffer(
				_incomingBid.offeror,
				_targetItem.itemId,
				_targetItem.tokenId,
				_incomingBid.offerPrice,
				_targetItem.listingType
			);
		}
	}

	/**
	 * @notice Cancel an auction
	 * @dev Refund NFT to `lister` and remove auction from active listing
	 * @param _targetItem a parameter just like in doxygen (must be followed by parameter name)
	 *
	 * Requirements:
	 *
	 * - Only `lister` can cancel an auction.
	 *
	 * Emits a {AuctionClosed} event
	 */
	function _cancelAuction(MarketItem memory _targetItem) internal {
		transferMarketItem(address(this), _targetItem.tokenOwner, _targetItem);
		_removeItemFromAllItemsEnumeration(_targetItem.tokenId);

		emit AuctionClosed(
			_targetItem.itemId,
			_targetItem.tokenId,
			_targetItem.tokenOwner,
			address(0),
			true
		);
	}

	/**
	 * @notice Close an auction for a bidder
	 * @dev Transfer NFT to winning bidder and remove item from active listing
	 * @param _targetItem Auction item
	 * @param winningBid_ Winning bid in an auction
	 *
	 * Emits a {AcutionClosed} event
	 */
	function _closeAuctionForBidder(
		MarketItem memory _targetItem,
		Offer memory winningBid_
	) internal {
		transferMarketItem(address(this), winningBid_.offeror, _targetItem);
		_removeItemFromAllItemsEnumeration(_targetItem.tokenId);

		// Remove winning bid of the auction
		delete _winningBid[_targetItem.tokenId];

		emit AuctionClosed(
			_targetItem.itemId,
			_targetItem.tokenId,
			_targetItem.tokenOwner,
			winningBid_.offeror,
			false
		);
	}

	/// @dev Transfers tokens listed for sale in a direct or auction listing.
	function transferMarketItem(
		address _from,
		address _to,
		MarketItem memory _item
	) internal  {
		IERC721Upgradeable(_assetContract).safeTransferFrom(_from, _to, _item.tokenId, "");
	}

	/// @dev Payout stakeholders on sale
	function payout(uint256 _payoutAmount, MarketItem memory _item) internal  {
		address payee = _item.tokenOwner;

		uint256 remainder = _payoutAmount;

		try
			IERC2981Upgradeable(_assetContract).royaltyInfo(_item.tokenId, _payoutAmount)
		returns (address royaltyFeeRecipient, uint256 royaltyFeeAmount) {
			if (royaltyFeeAmount > 0) {
				require(
					royaltyFeeAmount <= _payoutAmount,
					"Marketplace: Royalty amount exceed the total price"
				);
				remainder -= royaltyFeeAmount;
				transferCurrency(royaltyFeeRecipient, royaltyFeeAmount);
			}
		} catch {}
		// Distribute price to token owner
		transferCurrency(payee, remainder);
	}

	/// @dev Transfers a given `_amount` of VET to `_to`.
	function transferCurrency(address _to, uint256 _amount) internal {
		if (_amount == 0) {
			return;
		}
		address payable tgt = payable(_to);

		(bool success, ) = tgt.call{ value: _amount }("");
		require(success, "Marketplace: Failed to send VET");
	}

	/// @dev Checks whether an incoming bid should be the new current highest bid.
	function isNewWinningBid(
		uint256 _reservePrice,
		uint256 _currentWinningBidPrice,
		uint256 _incomingBidPrice
	) internal view returns (bool isValidNewBid) {
		isValidNewBid = _currentWinningBidPrice == 0
			? _incomingBidPrice >= _reservePrice
			: (_incomingBidPrice > _currentWinningBidPrice &&
				((_incomingBidPrice - _currentWinningBidPrice) * MAX_BPS) /
					_currentWinningBidPrice >=
				bidBufferBps);
	}

	/// @dev Validates conditions of a direct listing sale.
	function validateDirectSale(MarketItem memory _item) internal view {
		require(
			_item.listingType == ListingType.Direct,
			"Marketplace: invalid listing type"
		);

		// Check if sale is made within the listing window.
		require(
			block.timestamp > _item.startTime,
			"Marketplace: inactive market item"
		);

		// Check if whether token owner owns and has approved token.
		validateOwnershipAndApproval(_item.tokenOwner, _item.tokenId);
	}

	/// @dev Validates that `_tokenOwner` owns and has approved MP to transfer tokens.
	function validateOwnershipAndApproval(address _tokenOwner, uint256 _tokenId)
		internal
		view
	{
		address market = address(this);
		bool isValid = IERC721Upgradeable(_assetContract).ownerOf(_tokenId) == _tokenOwner &&
			(IERC721Upgradeable(_assetContract).getApproved(_tokenId) == market ||
				IERC721Upgradeable(_assetContract).isApprovedForAll(_tokenOwner, market));

		require(isValid, "Marketplace: invalid ownership or approval");
	}

	/**
	 * @dev Private function to remove a token from index tracking structures = `_allItemsIndex`
	 * @param _tokenId uint256 ID of the item to be removed from the market item list
	 */
	function _removeItemFromAllItemsEnumeration(uint256 _tokenId) private  {
		uint256 lastItemIndex = _items.length - 1;
		uint256 removeIndex = _allTokensIndex[_tokenId] - 1;

		MarketItem memory removeItem = _items[removeIndex];

		if (removeIndex != lastItemIndex) {
			MarketItem memory lastItem = _items[lastItemIndex];

			_items[removeIndex] = lastItem;
			_allItemsIndex[lastItem.itemId] = removeIndex + 1;
			_allTokensIndex[lastItem.tokenId] = removeIndex + 1;
		}

		delete _allItemsIndex[removeItem.itemId];
		delete _allTokensIndex[_tokenId];
		_items.pop();

		emit RemoveMarketItem(
			removeItem.itemId,
			_tokenId,
			removeItem.tokenOwner,
			removeItem
		);
	}
}