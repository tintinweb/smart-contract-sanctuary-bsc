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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
library Counters {
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

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract ERC721Marketplace is Initializable, OwnableUpgradeable, PausableUpgradeable {
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address offeror;
        address owner;
        uint256 price;
        address currency;
        bool isAuction;
        bool isPublisher;
        uint256 minimumOffer;
        uint256 duration;
        address bidder;
        uint256 lockedBid;
        address invitedBidder;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    Counters.Counter private _itemsRemoved;

    address public feeAddress;
    event FeeAddressUpdated(address oldAddress, address newAddress);
    uint32 public defaultFee;
    event DefaultFeeUpdated(uint32 oldFee, uint32 newFee);
    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(uint256 => uint256) private tokenIdToItemId;
    Counters.Counter private _privateItems;
    mapping(uint256 => MarketItem) private idToPrivateMarketItem;
    mapping(uint256 => uint256) private tokenIdToPrivateItemId;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address offeror,
        address owner,
        uint256 price,
        address currency,
        bool isAuction,
        bool isPublisher,
        uint256 minimumOffer,
        uint256 duration
    );
    event MarketItemRemoved(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId
    );
    event MarketItemSold(address owner, address buyer, uint256 tokenId);

    /// @notice A token is offered for sale by owner; or such an offer is revoked
    /// @param  tokenId       which token
    /// @param  offeror       the token owner that is selling
    /// @param  minimumOffer  the amount (in Wei) that is the minimum to accept; or zero to indicate no offer
    /// @param  invitedBidder the exclusive invited buyer for this offer; or the zero address if not exclusive
    event OfferUpdated(
        uint256 indexed tokenId,
        address offeror,
        uint256 minimumOffer,
        address invitedBidder
    );

    /// @notice A new highest bid is committed for a token; or such a bid is revoked
    /// @param  tokenId   which token
    /// @param  bidder    the party that committed Ether to bid
    /// @param  lockedBid the amount (in Wei) that the bidder has committed
    event BidUpdated(
        uint256 indexed tokenId,
        address bidder,
        uint256 lockedBid
    );

    /// @notice A token is traded on the marketplace (this implies any offer for the token is revoked)
    /// @param  tokenId which token
    /// @param  value   the sale price
    /// @param  offeror the party that previously owned the token
    /// @param  bidder  the party that now owns the token
    event Traded(
        uint256 indexed tokenId,
        uint256 value,
        address indexed offeror,
        address indexed bidder
    );

    event RoyaltyTransferred(address from, address to, uint256 amount);

    function initialize(address _feeAddress, uint32 _defaultFee)
        public
        virtual
        initializer
    {
        __Ownable_init();
        __Pausable_init();

        feeAddress = _feeAddress;
        defaultFee = _defaultFee;
    }

    function setFeeAddress(address _feeAddress) 
        public 
        onlyOwner
    {
        feeAddress = _feeAddress;
    }

    function setFeeAddress(uint32 _defaultFee) 
        public 
        onlyOwner
    {
        defaultFee = _defaultFee;
    }

    function getPrivateMarketItem(uint256 tokenId)
        public
        view
        onlyPrivateMarketItem(tokenId)
        returns (MarketItem memory)
    {
        uint256 itemId = tokenIdToPrivateItemId[tokenId];
        return idToPrivateMarketItem[itemId];
    }

    function getMarketItem(uint256 tokenId)
        public
        view
        onlyMarketItem(tokenId)
        returns (MarketItem memory)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        return idToMarketItem[itemId];
    }

    function createPrivateMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address currency,
        address invitedBidder
    ) external whenNotPaused {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.sender == IERC721(nftContract).ownerOf(tokenId),
            "Only the token owner can offer"
        );

        _privateItems.increment();
        uint256 itemId = _privateItems.current();
        tokenIdToPrivateItemId[tokenId] = itemId;
        idToPrivateMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            currency,
            false,
            false,
            price,
            0,
            address(0),
            0,
            invitedBidder
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            currency,
            false,
            false,
            price,
            0
        );
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address currency,
        bool isAuction,
        bool isPublisher,
        uint256 minimumOffer,
        uint256 duration
    ) external whenNotPaused {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.sender == IERC721(nftContract).ownerOf(tokenId),
            "Only the token owner can offer"
        );
        uint256 itemId = tokenIdToItemId[tokenId];

        if (itemId < 1) {
            _itemIds.increment();
            itemId = _itemIds.current();
            tokenIdToItemId[tokenId] = itemId;
            idToMarketItem[itemId] = MarketItem(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                price,
                currency,
                isAuction,
                isPublisher,
                minimumOffer,
                duration,
                address(0),
                0,
                address(0)
            );
        } else {
            itemId = tokenIdToItemId[tokenId];
            MarketItem storage marketItem = idToMarketItem[itemId];
            marketItem.nftContract = nftContract;
            marketItem.offeror = msg.sender;
            marketItem.owner = address(0);
            marketItem.price = price;
            marketItem.currency = currency;
            marketItem.isAuction = isAuction;
            marketItem.isPublisher = isPublisher;
            marketItem.minimumOffer = minimumOffer;
            marketItem.duration = duration;
            marketItem.bidder = address(0);
            marketItem.lockedBid = 0;
            marketItem.invitedBidder = address(0);
            idToMarketItem[itemId] = marketItem;
        }

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            currency,
            isAuction,
            isPublisher,
            minimumOffer,
            duration
        );

        if (isAuction) {
            require(
                minimumOffer > 0,
                "createMarketItem: minimum offer must be at least 1 wei"
            );
            emit OfferUpdated(tokenId, msg.sender, minimumOffer, address(0));
        }
    }

    function removeMarketItem(uint256 tokenId, address nftContract)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            idToMarketItem[itemId].offeror == msg.sender,
            "removeMarketItem : you are not the offeror of the NFT"
        );
        require(
            idToMarketItem[itemId].lockedBid <= 0 &&
                idToMarketItem[itemId].bidder == address(0),
            "An auction on this NFT is running and has active bid. Cancel the auction before removing this item from the market"
        );
        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].offeror = address(0);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        emit MarketItemRemoved(itemId, nftContract, tokenId);
    }

    function createPrivateMarketSale(uint256 tokenId)
        public
        whenNotPaused
        onlyPrivateMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToPrivateItemId[tokenId];
        uint256 price = idToPrivateMarketItem[itemId].price;
        address offeror = idToPrivateMarketItem[itemId].offeror;
        address currency = idToPrivateMarketItem[itemId].currency;
        address nftContract = idToPrivateMarketItem[itemId].nftContract;
        address buyer = msg.sender;

        // compute fee amount
        uint256 fee = (price * defaultFee) / 10000;
        //compute owner sale amount
        uint256 amount = price - fee;

        // Transfer the owner amount
        IERC20(currency).transferFrom(buyer, offeror, amount);
        // Transfer the fee amount
        IERC20(currency).transferFrom(buyer, feeAddress, fee);

        // transfer the NFT to the buyer
        IERC721(nftContract).transferFrom(address(this), buyer, tokenId);
        idToPrivateMarketItem[itemId].owner = buyer;
        idToPrivateMarketItem[itemId].offeror = address(0);
        idToPrivateMarketItem[itemId].minimumOffer = 0;
        idToPrivateMarketItem[itemId].invitedBidder = address(0);

        emit MarketItemSold(offeror, buyer, tokenId);
    }

    function createMarketSale(uint256 tokenId)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        uint256 price = idToMarketItem[itemId].price;
        address offeror = idToMarketItem[itemId].offeror;
        address currency = idToMarketItem[itemId].currency;
        address nftContract = idToMarketItem[itemId].nftContract;
        address buyer = msg.sender;

        address receiver = address(0);
        uint256 royaltyAmount = 0;

        if (
            IERC165(nftContract).supportsInterface(type(IERC2981).interfaceId)
        ) {
            (address _receiver, uint256 _royaltyAmount) = IERC2981(nftContract)
                .royaltyInfo(tokenId, price);

            if (offeror != _receiver) {
                receiver = _receiver;
                royaltyAmount = _royaltyAmount;
            }
        }

        // compute fee amount
        uint256 fee = (price * defaultFee) / 10000;
        //compute owner sale amount
        uint256 amount = price - fee - royaltyAmount;

        // Transfer the owner amount
        IERC20(currency).transferFrom(buyer, offeror, amount);
        // Transfer the fee amount
        IERC20(currency).transferFrom(buyer, feeAddress, fee);
        if (receiver != address(0)) {
            // Transfer the royalty amount
            IERC20(currency).transferFrom(buyer, receiver, royaltyAmount);
            emit RoyaltyTransferred(buyer, receiver, royaltyAmount);
        }

        // transfer the NFT to the buyer
        IERC721(nftContract).transferFrom(address(this), buyer, tokenId);
        idToMarketItem[itemId].owner = buyer;
        idToMarketItem[itemId].offeror = address(0);
        idToMarketItem[itemId].minimumOffer = 0;
        idToMarketItem[itemId].invitedBidder = address(0);
        _itemsSold.increment();

        emit MarketItemSold(offeror, buyer, tokenId);
    }

    function closeAuction(uint256 tokenId)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp > idToMarketItem[itemId].duration,
            "closeAuction: Auction period is running"
        );
        require(
            msg.sender == idToMarketItem[itemId].offeror,
            "closeAuction: Only offeror can cancel and auction for a token he owns"
        );
        require(
            idToMarketItem[itemId].bidder != address(0),
            "closeAuction: This auction has no bid."
        );
        uint256 highestBid = idToMarketItem[itemId].lockedBid;
        address offeror = idToMarketItem[itemId].offeror;
        address bidder = idToMarketItem[itemId].bidder;

        _doTrade(itemId, highestBid, offeror, bidder);
        _setBid(itemId, address(0), 0);
        _itemsSold.increment();
        emit MarketItemSold(offeror, bidder, tokenId);
    }

    /// @dev Collect fee for owner & offeror and transfer underlying asset. The Traded event emits before the
    ///      ERC721.Transfer event so that somebody observing the events and seeing the latter will recognize the
    ///      context of the former. The bid is NOT cleaned up generally in this function because a circumstance exists
    ///      where an existing bid persists after a trade. See "context 3" above.
    function _doTrade(
        uint256 itemId,
        uint256 value,
        address offeror,
        address bidder
    ) private {
        address receiver = address(0);
        uint256 royaltyAmount = 0;

        if (
            IERC165(idToMarketItem[itemId].nftContract).supportsInterface(
                type(IERC2981).interfaceId
            )
        ) {
            (address _receiver, uint256 _royaltyAmount) = IERC2981(
                idToMarketItem[itemId].nftContract
            ).royaltyInfo(idToMarketItem[itemId].tokenId, value);

            if (offeror != _receiver) {
                receiver = _receiver;
                royaltyAmount = _royaltyAmount;
            }
        }
        // Divvy up proceeds
        uint256 feeAmount = (value * defaultFee) / 10000; // reverts on overflow
        uint256 bidderAmount = value - feeAmount - royaltyAmount;
        IERC20(idToMarketItem[itemId].currency).transfer(feeAddress, feeAmount);
        IERC20(idToMarketItem[itemId].currency).transfer(offeror, bidderAmount);
        if (receiver != address(0)) {
            // Transfer the royalty amount
            IERC20(idToMarketItem[itemId].currency).transfer(
                receiver,
                royaltyAmount
            );
            emit RoyaltyTransferred(bidder, receiver, royaltyAmount);
        }

        emit Traded(idToMarketItem[itemId].tokenId, value, offeror, bidder);
        idToMarketItem[itemId].offeror = address(0);
        idToMarketItem[itemId].minimumOffer = 0;
        idToMarketItem[itemId].invitedBidder = address(0);
        idToMarketItem[itemId].owner = bidder;
        IERC721(idToMarketItem[itemId].nftContract).transferFrom(
            address(this),
            bidder,
            idToMarketItem[itemId].tokenId
        );
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 currentIndex = 0;

        uint256 count = 0;
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                count += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](count);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyListedNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].offeror == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].offeror == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyPrivateNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _privateItems.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = idToPrivateMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToPrivateMarketItem[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyPrivateMarketItems()
        public
        view
        returns (MarketItem[] memory)
    {
        uint256 totalItemCount = _privateItems.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].invitedBidder == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].invitedBidder == msg.sender) {
                uint256 currentId = idToPrivateMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToPrivateMarketItem[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (
                idToMarketItem[i + 1].owner == msg.sender &&
                idToMarketItem[i + 1].invitedBidder == address(0)
            ) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function cancelAuction(uint256 tokenId)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "cancelAuction: Auction period is over for this NFT"
        );
        require(
            msg.sender == idToMarketItem[itemId].offeror,
            "cancelAuction: Only offeror can cancel and auction for a token he owns"
        );

        address bidder = idToMarketItem[itemId].bidder;
        uint256 lockedBid = idToMarketItem[itemId].lockedBid;
        address currency = idToMarketItem[itemId].currency;

        if (bidder != address(0)) {
            // Refund the current bidder
            IERC20(currency).transfer(bidder, lockedBid);
        }
        _setOffer(itemId, address(0), 0, address(0));
    }

    /// @notice An bidder may revoke their bid
    /// @param  tokenId which token
    function revokeBid(uint256 tokenId)
        external
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "revoke Bid: Auction period is over for this NFT"
        );
        require(
            msg.sender == idToMarketItem[itemId].bidder,
            "revoke Bid: Only the bidder may revoke their bid"
        );
        address currency = idToMarketItem[itemId].currency;
        address existingBidder = idToMarketItem[itemId].bidder;
        uint256 existingLockedBid = idToMarketItem[itemId].lockedBid;
        IERC20(currency).transfer(existingBidder, existingLockedBid);
        _setBid(itemId, address(0), 0);
    }

    /// @notice Anyone may commit more than the existing bid for a token.
    /// @param  tokenId which token
    function bid(uint256 tokenId, uint256 amount)
        external
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        uint256 existingLockedBid = idToMarketItem[itemId].lockedBid;
        uint256 minimumOffer = idToMarketItem[itemId].minimumOffer;
        require(
            idToMarketItem[itemId].isAuction,
            "bid: this NFT is not auctionable"
        );
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "bid: Auction period is over for this NFT"
        );
        require(amount >= minimumOffer, "Bid too low");
        require(amount > existingLockedBid, "Bid lower than the highest bid");
        address existingBidder = idToMarketItem[itemId].bidder;
        address currency = idToMarketItem[itemId].currency;

        IERC20(currency).transferFrom(msg.sender, address(this), amount);
        if (existingBidder != address(0)) {
            IERC20(currency).transfer(existingBidder, existingLockedBid);
        }
        _setBid(itemId, msg.sender, amount);
    }

    /// @notice Anyone may add more value to their existing bid
    /// @param  tokenId which token
    function bidIncrease(uint256 tokenId, uint256 amount)
        external
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "bid Increase: Auction period is over for this NFT"
        );
        require(amount > 0, "bidIncrease: Must send value to increase bid");
        require(
            msg.sender == idToMarketItem[itemId].bidder,
            "bidIncrease: You are not current bidder"
        );
        uint256 newBidAmount = idToMarketItem[itemId].lockedBid + amount;
        address currency = idToMarketItem[itemId].currency;

        IERC20(currency).transferFrom(msg.sender, address(this), amount);
        idToMarketItem[itemId].lockedBid = newBidAmount;
        _setBid(itemId, msg.sender, newBidAmount);
    }

    /// @notice The owner can set the fee portion
    /// @param  newFeePortion the transaction fee (in basis points) as a portion of the sale price
    function setFeePortion(uint32 newFeePortion) external onlyOwner {
        require(newFeePortion >= 0, "Exceeded maximum fee portion of 10%");
        defaultFee = newFeePortion;
    }

    /// @dev Set and emit new offer
    function _setOffer(
        uint256 itemId,
        address offeror,
        uint256 minimumOffer,
        address invitedBidder
    ) private {
        idToMarketItem[itemId].offeror = offeror;
        idToMarketItem[itemId].minimumOffer = minimumOffer;
        idToMarketItem[itemId].invitedBidder = invitedBidder;
        emit OfferUpdated(
            idToMarketItem[itemId].tokenId,
            offeror,
            minimumOffer,
            invitedBidder
        );
    }

    /// @dev Set and emit new bid
    function _setBid(
        uint256 itemId,
        address bidder,
        uint256 lockedBid
    ) private {
        idToMarketItem[itemId].bidder = bidder;
        idToMarketItem[itemId].lockedBid = lockedBid;
        emit BidUpdated(idToMarketItem[itemId].tokenId, bidder, lockedBid);
    }

    function _marketItemCount() public view returns (uint256) {
        return _itemIds.current();
    }

    function _marketPrivateItemCount() public view returns (uint256) {
        return _privateItems.current();
    }

    modifier onlyPrivateMarketItem(uint256 tokenId) {
        require(
            tokenIdToPrivateItemId[tokenId] > 0,
            "TokenId not found in the market"
        );
        _;
    }

    modifier onlyMarketItem(uint256 tokenId) {
        require(
            tokenIdToItemId[tokenId] > 0,
            "TokenId not found in the market"
        );
        _;
    }
}