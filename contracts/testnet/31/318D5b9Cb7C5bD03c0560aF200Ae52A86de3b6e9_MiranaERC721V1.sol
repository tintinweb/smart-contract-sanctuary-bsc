// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract MinterAccessControl is Initializable, OwnableUpgradeable {
    mapping(address => bool) private _minters;
    
    event MinterAdded(address indexed operator, address indexed minter);
    event MinterRemoved(address indexed operator, address indexed minter);

    function __MinterAccessControl_init() internal initializer {
        __Ownable_init_unchained();
        __MinterAccessControl_init_unchained();
    }

    function __MinterAccessControl_init_unchained() internal initializer {
    }

    /**
     * @dev Add `_minter` to the list of allowed minters.
     */
    function addMinter(address _minter) external onlyOwner {
        require(!_minters[_minter], 'Already minter');
        _minters[_minter] = true;
        emit MinterAdded(_msgSender(), _minter);
    }

    /**
     * @dev Revoke `_minter` from the list of allowed minters.
     */
    function removeMinter(address _minter) external onlyOwner {
        require(_minters[_minter], 'Not minter');
        _minters[_minter] = false;
        emit MinterRemoved(_msgSender(), _minter);
    }

    /**
     * @dev Returns `true` if `account` has been granted to minters.
     */
    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    uint256[9] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract OperatorRole is OwnableUpgradeable {
    mapping (address => bool) operators;

    function __OperatorRole_init() external initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function addOperator(address operator) external onlyOwner {
        operators[operator] = true;
    }

    function removeOperator(address operator) external onlyOwner {
        operators[operator] = false;
    }

    modifier onlyOperator() {
        require(operators[_msgSender()], "OperatorRole: caller is not the operator");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../roles/OperatorRole.sol";
import "../../exchange-interfaces/contracts/INftTransferProxy.sol";

contract TransferProxy is INftTransferProxy, Initializable, OperatorRole {

    function __TransferProxy_init() external initializer {
        __Ownable_init();
    }

    function erc721safeTransferFrom(IERC721Upgradeable token, address from, address to, uint256 tokenId) override external onlyOperator {
        token.safeTransferFrom(from, to, tokenId);
    }

    function erc1155safeTransferFrom(IERC1155Upgradeable token, address from, address to, uint256 id, uint256 value, bytes calldata data) override external onlyOperator {
        token.safeTransferFrom(from, to, id, value, data);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface INftTransferProxy {
  function erc721safeTransferFrom(
    IERC721Upgradeable token,
    address from,
    address to,
    uint256 tokenId
  ) external;

  function erc1155safeTransferFrom(
    IERC1155Upgradeable token,
    address from,
    address to,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../rarible/exchange-interfaces/contracts/ITransferProxy.sol";
import "../../rarible/exchange-interfaces/contracts/INftTransferProxy.sol";
import "../../rarible/exchange-interfaces/contracts/IERC20TransferProxy.sol";
import "./ITransferExecutor.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./lib/LibTransfer.sol";

abstract contract TransferExecutorV1 is
  Initializable,
  OwnableUpgradeable,
  ITransferExecutor
{
  using LibTransfer for address;

  mapping(bytes4 => address) proxies;

  event ProxyChange(bytes4 indexed assetType, address proxy);

  function __TransferExecutor_init_unchained(
    INftTransferProxy transferProxy,
    IERC20TransferProxy erc20TransferProxy
  ) internal {
    proxies[LibAsset.ERC20_ASSET_CLASS] = address(erc20TransferProxy);
    proxies[LibAsset.ERC721_ASSET_CLASS] = address(transferProxy);
    proxies[LibAsset.ERC1155_ASSET_CLASS] = address(transferProxy);
  }

  function setTransferProxy(bytes4 assetType, address proxy)
    external
    onlyOwner
  {
    proxies[assetType] = proxy;
    emit ProxyChange(assetType, proxy);
  }

  function getBytes(string memory key)
    external
    pure
    returns (bytes memory result)
  {
    result = abi.encodePacked(key);
  }

  function getBytes4(string memory key) external pure returns (bytes4 result) {
    result = bytes4(keccak256(abi.encodePacked(key)));
  }

  function getAddress(uint key) external pure returns (address addr) {
    addr = address(bytes20(sha256(abi.encodePacked(key >> 96))));
  }

  function getBytes32(string memory key)
    external
    pure
    returns (bytes32 result)
  {
    result = keccak256((abi.encodePacked(key)));
  }

  function transfer(
    LibAsset.Asset memory asset,
    address from,
    address to,
    bytes4 transferDirection,
    bytes4 transferType
  ) internal override {
    if (asset.assetType.assetClass == LibAsset.ETH_ASSET_CLASS) {
      to.transferEth(asset.value);
    } else if (asset.assetType.assetClass == LibAsset.ERC20_ASSET_CLASS) {
      address token = abi.decode(asset.assetType.data, (address));
      IERC20TransferProxy(proxies[LibAsset.ERC20_ASSET_CLASS])
        .erc20safeTransferFrom(IERC20Upgradeable(token), from, to, asset.value);
    } else if (asset.assetType.assetClass == LibAsset.ERC721_ASSET_CLASS) {
      (address token, uint256 tokenId) = abi.decode(
        asset.assetType.data,
        (address, uint256)
      );
      require(asset.value == 1, "erc721 value error");
      INftTransferProxy(proxies[LibAsset.ERC721_ASSET_CLASS])
        .erc721safeTransferFrom(IERC721Upgradeable(token), from, to, tokenId);
    } else if (asset.assetType.assetClass == LibAsset.ERC1155_ASSET_CLASS) {
      (address token, uint256 tokenId) = abi.decode(
        asset.assetType.data,
        (address, uint256)
      );
      INftTransferProxy(proxies[LibAsset.ERC1155_ASSET_CLASS])
        .erc1155safeTransferFrom(
          IERC1155Upgradeable(token),
          from,
          to,
          tokenId,
          asset.value,
          ""
        );
    } else {
      ITransferProxy(proxies[asset.assetType.assetClass]).transfer(
        asset,
        from,
        to
      );
    }
    emit Transfer(asset, from, to, transferDirection, transferType);
  }

  uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../lib-asset/contracts/LibAsset.sol";

interface ITransferProxy {
  function transfer(
    LibAsset.Asset calldata asset,
    address from,
    address to
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IERC20TransferProxy {
  function erc20safeTransferFrom(
    IERC20Upgradeable token,
    address from,
    address to,
    uint256 value
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../rarible/lib-asset/contracts/LibAsset.sol";

abstract contract ITransferExecutor {

    //events
    event Transfer(LibAsset.Asset asset, address from, address to, bytes4 transferDirection, bytes4 transferType);

    function transfer(
        LibAsset.Asset memory asset,
        address from,
        address to,
        bytes4 transferDirection,
        bytes4 transferType
    ) internal virtual;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibTransfer {
    function transferEth(address to, uint value) internal {
        (bool success,) = to.call{ value: value }("");
        require(success, "transfer failed");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibAsset {
  bytes4 public constant ETH_ASSET_CLASS = bytes4(keccak256("ETH"));
  bytes4 public constant ERC20_ASSET_CLASS = bytes4(keccak256("ERC20"));
  bytes4 public constant NFT_ASSET_CLASS = bytes4(keccak256("NFT"));
  bytes4 public constant ERC721_ASSET_CLASS = bytes4(keccak256("ERC721"));
  bytes4 public constant ERC1155_ASSET_CLASS = bytes4(keccak256("ERC1155"));
  bytes4 public constant COLLECTION = bytes4(keccak256("COLLECTION"));
  bytes4 public constant CRYPTO_PUNKS = bytes4(keccak256("CRYPTO_PUNKS"));

  bytes32 constant ASSET_TYPE_TYPEHASH =
    keccak256("AssetType(bytes4 assetClass,bytes data)");

  bytes32 constant ASSET_TYPEHASH =
    keccak256(
      "Asset(AssetType assetType,uint256 value)AssetType(bytes4 assetClass,bytes data)"
    );

  struct AssetType {
    bytes4 assetClass;
    bytes data;
  }

  struct Asset {
    AssetType assetType;
    uint256 value;
  }

  function hash(AssetType memory assetType) internal pure returns (bytes32) {
    return
      keccak256(
        abi.encode(
          ASSET_TYPE_TYPEHASH,
          assetType.assetClass,
          keccak256(assetType.data)
        )
      );
  }

  function hash(Asset memory asset) internal pure returns (bytes32) {
    return
      keccak256(abi.encode(ASSET_TYPEHASH, hash(asset.assetType), asset.value));
  }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./LibFill.sol";
import "./LibOrder.sol";
import "./OrderValidator.sol";
import "./AssetMatcher.sol";
import "./ITransferManager.sol";
import "./TransferExecutorV1.sol";
import "./lib/LibTransfer.sol";

abstract contract MiranaOrderBaseV1 is Initializable, OwnableUpgradeable, AssetMatcher, TransferExecutor, OrderValidator, ITransferManager {
    using SafeMathUpgradeable for uint;
    using LibTransfer for address;

    uint256 private constant UINT256_MAX = 2 ** 256 - 1;

    //state of the orders
    mapping(bytes32 => uint) public fills;

    //events
    event Cancel(bytes32 hash, address maker, LibAsset.AssetType makeAssetType, LibAsset.AssetType takeAssetType);
    event Match(bytes32 leftHash, bytes32 rightHash, address leftMaker, address rightMaker, uint newLeftFill, uint newRightFill, LibAsset.AssetType leftAsset, LibAsset.AssetType rightAsset);

    function cancel(LibOrder.Order memory order) external {
        require(_msgSender() == order.maker, "not a maker");
        require(order.salt != 0, "0 salt can't be used");
        bytes32 orderKeyHash = LibOrder.hashKey(order);
        fills[orderKeyHash] = UINT256_MAX;
        emit Cancel(orderKeyHash, order.maker, order.makeAsset.assetType, order.takeAsset.assetType);
    }

    function matchOrders(
        LibOrder.Order memory orderLeft,
        bytes memory signatureLeft,
        LibOrder.Order memory orderRight,
        bytes memory signatureRight
    ) external payable {
        validateFull(orderLeft, signatureLeft);
        validateFull(orderRight, signatureRight);
        if (orderLeft.taker != address(0)) {
            require(orderRight.maker == orderLeft.taker, "leftOrder.taker verification failed");
        }
        if (orderRight.taker != address(0)) {
            require(orderRight.taker == orderLeft.maker, "rightOrder.taker verification failed");
        }
        matchAndTransfer(orderLeft, orderRight);
    }

    function matchAndTransfer(LibOrder.Order memory orderLeft, LibOrder.Order memory orderRight) internal {
        (LibAsset.AssetType memory makeMatch, LibAsset.AssetType memory takeMatch) = matchAssets(orderLeft, orderRight);
        bytes32 leftOrderKeyHash = LibOrder.hashKey(orderLeft);
        bytes32 rightOrderKeyHash = LibOrder.hashKey(orderRight);

        LibOrderDataV2.DataV2 memory leftOrderData = LibOrderData.parse(orderLeft);
        LibOrderDataV2.DataV2 memory rightOrderData = LibOrderData.parse(orderRight);

        LibFill.FillResult memory newFill = getFillSetNew(orderLeft, orderRight, leftOrderKeyHash, rightOrderKeyHash, leftOrderData, rightOrderData);

        (uint totalMakeValue, uint totalTakeValue) = doTransfers(makeMatch, takeMatch, newFill, orderLeft, orderRight, leftOrderData, rightOrderData);
        if (makeMatch.assetClass == LibAsset.ETH_ASSET_CLASS) {
            require(takeMatch.assetClass != LibAsset.ETH_ASSET_CLASS);
            require(msg.value >= totalMakeValue, "not enough eth");
            if (msg.value > totalMakeValue) {
                address(msg.sender).transferEth(msg.value.sub(totalMakeValue));
            }
        } else if (takeMatch.assetClass == LibAsset.ETH_ASSET_CLASS) {
            require(msg.value >= totalTakeValue, "not enough eth");
            if (msg.value > totalTakeValue) {
                address(msg.sender).transferEth(msg.value.sub(totalTakeValue));
            }
        }
        emit Match(leftOrderKeyHash, rightOrderKeyHash, orderLeft.maker, orderRight.maker, newFill.rightValue, newFill.leftValue, makeMatch, takeMatch);
    }

    function getFillSetNew(
        LibOrder.Order memory orderLeft,
        LibOrder.Order memory orderRight,
        bytes32 leftOrderKeyHash,
        bytes32 rightOrderKeyHash,
        LibOrderDataV2.DataV2 memory leftOrderData,
        LibOrderDataV2.DataV2 memory rightOrderData
    ) internal returns (LibFill.FillResult memory) {
        uint leftOrderFill = getOrderFill(orderLeft, leftOrderKeyHash);
        uint rightOrderFill = getOrderFill(orderRight, rightOrderKeyHash);
        LibFill.FillResult memory newFill = LibFill.fillOrder(orderLeft, orderRight, leftOrderFill, rightOrderFill, leftOrderData.isMakeFill, rightOrderData.isMakeFill);

        require(newFill.rightValue > 0 && newFill.leftValue > 0, "nothing to fill");

        if (orderLeft.salt != 0) {
            if (leftOrderData.isMakeFill) {
                fills[leftOrderKeyHash] = leftOrderFill.add(newFill.leftValue);
            } else {
                fills[leftOrderKeyHash] = leftOrderFill.add(newFill.rightValue);
            }
        }

        if (orderRight.salt != 0) {
            if (rightOrderData.isMakeFill) {
                fills[rightOrderKeyHash] = rightOrderFill.add(newFill.rightValue);
            } else {
                fills[rightOrderKeyHash] = rightOrderFill.add(newFill.leftValue);
            }
        }
        return newFill;
    }

    function getOrderFill(LibOrder.Order memory order, bytes32 hash) internal view returns (uint fill) {
        if (order.salt == 0) {
            fill = 0;
        } else {
            fill = fills[hash];
        }
    }

    function matchAssets(LibOrder.Order memory orderLeft, LibOrder.Order memory orderRight) internal view returns (LibAsset.AssetType memory makeMatch, LibAsset.AssetType memory takeMatch) {
        makeMatch = matchAssets(orderLeft.makeAsset.assetType, orderRight.takeAsset.assetType);
        require(makeMatch.assetClass != 0, "assets don't match");
        takeMatch = matchAssets(orderLeft.takeAsset.assetType, orderRight.makeAsset.assetType);
        require(takeMatch.assetClass != 0, "assets don't match");
    }

    function validateFull(LibOrder.Order memory order, bytes memory signature) internal view {
        LibOrder.validate(order);
        validate(order, signature);
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LibOrder.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

library LibFill {
    using SafeMathUpgradeable for uint;

    struct FillResult {
        uint leftValue;
        uint rightValue;
    }

    /**
     * @dev Should return filled values
     * @param leftOrder left order
     * @param rightOrder right order
     * @param leftOrderFill current fill of the left order (0 if order is unfilled)
     * @param rightOrderFill current fill of the right order (0 if order is unfilled)
     * @param leftIsMakeFill true if left orders fill is calculated from the make side, false if from the take side
     * @param rightIsMakeFill true if right orders fill is calculated from the make side, false if from the take side
     */
    function fillOrder(LibOrder.Order memory leftOrder, LibOrder.Order memory rightOrder, uint leftOrderFill, uint rightOrderFill, bool leftIsMakeFill, bool rightIsMakeFill) internal pure returns (FillResult memory) {
        (uint leftMakeValue, uint leftTakeValue) = LibOrder.calculateRemaining(leftOrder, leftOrderFill, leftIsMakeFill);
        (uint rightMakeValue, uint rightTakeValue) = LibOrder.calculateRemaining(rightOrder, rightOrderFill, rightIsMakeFill);

        //We have 3 cases here:
        if (rightTakeValue > leftMakeValue) { //1nd: left order should be fully filled
            return fillLeft(leftMakeValue, leftTakeValue, rightOrder.makeAsset.value, rightOrder.takeAsset.value);
        }//2st: right order should be fully filled or 3d: both should be fully filled if required values are the same
        return fillRight(leftOrder.makeAsset.value, leftOrder.takeAsset.value, rightMakeValue, rightTakeValue);
    }

    function fillRight(uint leftMakeValue, uint leftTakeValue, uint rightMakeValue, uint rightTakeValue) internal pure returns (FillResult memory result) {
        uint makerValue = LibMath.safeGetPartialAmountFloor(rightTakeValue, leftMakeValue, leftTakeValue);
        require(makerValue <= rightMakeValue, "fillRight: unable to fill");
        return FillResult(rightTakeValue, makerValue);
    }

    function fillLeft(uint leftMakeValue, uint leftTakeValue, uint rightMakeValue, uint rightTakeValue) internal pure returns (FillResult memory result) {
        uint rightTake = LibMath.safeGetPartialAmountFloor(leftTakeValue, rightMakeValue, rightTakeValue);
        require(rightTake <= leftMakeValue, "fillLeft: unable to fill");
        return FillResult(leftMakeValue, leftTakeValue);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/LibMath.sol";
import "../../rarible/lib-asset/contracts/LibAsset.sol";
import "./LibOrderDataV2.sol";
import "./LibOrderDataV1.sol";

library LibOrder {
    using SafeMathUpgradeable for uint;

    bytes32 constant ORDER_TYPEHASH = keccak256(
        "Order(address maker,Asset makeAsset,address taker,Asset takeAsset,uint256 salt,uint256 start,uint256 end,bytes4 dataType,bytes data)Asset(AssetType assetType,uint256 value)AssetType(bytes4 assetClass,bytes data)"
    );

    struct Order {
        address maker;
        LibAsset.Asset makeAsset;
        address taker;
        LibAsset.Asset takeAsset;
        uint salt;
        uint start;
        uint end;
        bytes4 dataType;
        bytes data;
    }

    function calculateRemaining(Order memory order, uint fill, bool isMakeFill) internal pure returns (uint makeValue, uint takeValue) {
        if (isMakeFill){
            makeValue = order.makeAsset.value.sub(fill);
            takeValue = LibMath.safeGetPartialAmountFloor(order.takeAsset.value, order.makeAsset.value, makeValue);
        } else {
            takeValue = order.takeAsset.value.sub(fill);
            makeValue = LibMath.safeGetPartialAmountFloor(order.makeAsset.value, order.takeAsset.value, takeValue); 
        } 
    }

    function hashKey(Order memory order) internal pure returns (bytes32) {
        //order.data is in hash for V2 orders
        if (order.dataType == LibOrderDataV2.V2){
            return keccak256(abi.encode(
                order.maker,
                LibAsset.hash(order.makeAsset.assetType),
                LibAsset.hash(order.takeAsset.assetType),
                order.salt,
                order.data
            ));
        } else {
            return keccak256(abi.encode(
                order.maker,
                LibAsset.hash(order.makeAsset.assetType),
                LibAsset.hash(order.takeAsset.assetType),
                order.salt
            ));
        }
        
    }

    function hash(Order memory order) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                ORDER_TYPEHASH,
                order.maker,
                LibAsset.hash(order.makeAsset),
                order.taker,
                LibAsset.hash(order.takeAsset),
                order.salt,
                order.start,
                order.end,
                order.dataType,
                keccak256(order.data)
            ));
    }

    function validate(LibOrder.Order memory order) internal view {
        require(order.start == 0 || order.start < block.timestamp, "Order start validation failed");
        require(order.end == 0 || order.end > block.timestamp, "Order end validation failed");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC1271.sol";
import "./LibOrder.sol";
import "../../rarible/libraries/contracts/LibSignature.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";

abstract contract OrderValidator is Initializable, ContextUpgradeable, EIP712Upgradeable {
    using LibSignature for bytes32;
    using AddressUpgradeable for address;
    
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    function __OrderValidator_init_unchained() internal initializer {
        __EIP712_init_unchained("Exchange", "2");
    }

    function validate(LibOrder.Order memory order, bytes memory signature) internal view {
        if (order.salt == 0) {
            if (order.maker != address(0)) {
                require(_msgSender() == order.maker, "maker is not tx sender");
            } else {
                order.maker = _msgSender();
            }
        } else {
            if (_msgSender() != order.maker) {
                bytes32 hash = LibOrder.hash(order);
                address signer;
                if (signature.length == 65) {
                    signer = _hashTypedDataV4(hash).recover(signature);
                }
                if  (signer != order.maker) {
                    if (order.maker.isContract()) {
                        require(
                            IERC1271(order.maker).isValidSignature(_hashTypedDataV4(hash), signature) == MAGICVALUE,
                            "contract order signature verification error"
                        );
                    } else {
                        revert("order signature verification error");
                    }
                }  
            }
        }
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../rarible/exchange-interfaces/contracts/IAssetMatcher.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract AssetMatcher is Initializable, OwnableUpgradeable {
  bytes constant EMPTY = "";
  mapping(bytes4 => address) matchers;

  event MatcherChange(bytes4 indexed assetType, address matcher);

  function setAssetMatcher(bytes4 assetType, address matcher)
    external
    onlyOwner
  {
    matchers[assetType] = matcher;
    emit MatcherChange(assetType, matcher);
  }

  function matchAssets(
    LibAsset.AssetType memory leftAssetType,
    LibAsset.AssetType memory rightAssetType
  ) internal view returns (LibAsset.AssetType memory) {
    LibAsset.AssetType memory result = matchAssetOneSide(
      leftAssetType,
      rightAssetType
    );
    if (result.assetClass == 0) {
      return matchAssetOneSide(rightAssetType, leftAssetType);
    } else {
      return result;
    }
  }

  function matchAssetOneSide(
    LibAsset.AssetType memory leftAssetType,
    LibAsset.AssetType memory rightAssetType
  ) private view returns (LibAsset.AssetType memory) {
    bytes4 classLeft = leftAssetType.assetClass;
    bytes4 classRight = rightAssetType.assetClass;
    if (classLeft == LibAsset.ETH_ASSET_CLASS) {
      if (classRight == LibAsset.ETH_ASSET_CLASS) {
        return leftAssetType;
      }
      return LibAsset.AssetType(0, EMPTY);
    }
    if (classLeft == LibAsset.ERC20_ASSET_CLASS) {
      if (classRight == LibAsset.ERC20_ASSET_CLASS) {
        return simpleMatch(leftAssetType, rightAssetType);
      }
      return LibAsset.AssetType(0, EMPTY);
    }
    if (classLeft == LibAsset.ERC721_ASSET_CLASS) {
      if (classRight == LibAsset.ERC721_ASSET_CLASS) {
        return simpleMatch(leftAssetType, rightAssetType);
      }
      return LibAsset.AssetType(0, EMPTY);
    }
    if (classLeft == LibAsset.ERC1155_ASSET_CLASS) {
      if (classRight == LibAsset.ERC1155_ASSET_CLASS) {
        return simpleMatch(leftAssetType, rightAssetType);
      }
      return LibAsset.AssetType(0, EMPTY);
    }
    address matcher = matchers[classLeft];
    if (matcher != address(0)) {
      return IAssetMatcher(matcher).matchAssets(leftAssetType, rightAssetType);
    }
    if (classLeft == classRight) {
      return simpleMatch(leftAssetType, rightAssetType);
    }
    revert("not found IAssetMatcher");
  }

  function simpleMatch(
    LibAsset.AssetType memory leftAssetType,
    LibAsset.AssetType memory rightAssetType
  ) private pure returns (LibAsset.AssetType memory) {
    bytes32 leftHash = keccak256(leftAssetType.data);
    bytes32 rightHash = keccak256(rightAssetType.data);
    if (leftHash == rightHash) {
      return leftAssetType;
    }
    return LibAsset.AssetType(0, EMPTY);
  }

  uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../rarible/lib-asset/contracts/LibAsset.sol";
import "./LibFill.sol";
import "./TransferExecutor.sol";
import "./LibOrderData.sol";

abstract contract ITransferManager is ITransferExecutor {
    bytes4 constant TO_MAKER = bytes4(keccak256("TO_MAKER"));
    bytes4 constant TO_TAKER = bytes4(keccak256("TO_TAKER"));
    bytes4 constant PROTOCOL = bytes4(keccak256("PROTOCOL"));
    bytes4 constant ROYALTY = bytes4(keccak256("ROYALTY"));
    bytes4 constant ORIGIN = bytes4(keccak256("ORIGIN"));
    bytes4 constant PAYOUT = bytes4(keccak256("PAYOUT"));

    function doTransfers(
        LibAsset.AssetType memory makeMatch,
        LibAsset.AssetType memory takeMatch,
        LibFill.FillResult memory fill,
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        LibOrderDataV2.DataV2 memory leftOrderData,
        LibOrderDataV2.DataV2 memory rightOrderData
    ) internal virtual returns (uint totalMakeValue, uint totalTakeValue);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

library LibMath {
    using SafeMathUpgradeable for uint;

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return partialAmount value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        if (isRoundingErrorFloor(numerator, denominator, target)) {
            revert("rounding error");
        }
        partialAmount = numerator.mul(target).div(denominator);
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return isError Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        if (denominator == 0) {
            revert("division by zero");
        }

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * target)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.mul(1000) >= numerator.mul(target);
    }

    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        if (isRoundingErrorCeil(numerator, denominator, target)) {
            revert("rounding error");
        }
        partialAmount = numerator.mul(target).add(denominator.sub(1)).div(denominator);
    }

    /// @dev Checks if rounding error >= 0.1% when rounding up.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return isError Rounding error is present.
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        if (denominator == 0) {
            revert("division by zero");
        }

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = denominator.sub(remainder) % denominator;
        isError = remainder.mul(1000) >= numerator.mul(target);
        return isError;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../rarible/royalties/contracts/LibPart.sol";

library LibOrderDataV2 {
    bytes4 constant public V2 = bytes4(keccak256("V2"));

    struct DataV2 {
        LibPart.Part[] payouts;
        LibPart.Part[] originFees;
        bool isMakeFill;
    }

    function decodeOrderDataV2(bytes memory data) internal pure returns (DataV2 memory orderData) {
        orderData = abi.decode(data, (DataV2));
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../rarible/royalties/contracts/LibPart.sol";

library LibOrderDataV1 {
    bytes4 constant public V1 = bytes4(keccak256("V1"));

    struct DataV1 {
        LibPart.Part[] payouts;
        LibPart.Part[] originFees;
    }

    function decodeOrderDataV1(bytes memory data) internal pure returns (DataV1 memory orderData) {
        orderData = abi.decode(data, (DataV1));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibPart {
    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC1271 {

    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param _hash Hash of the data signed on the behalf of address(this)
     * @param _signature Signature byte array associated with _data
     *
     * MUST return the bytes4 magic value 0x1626ba7e when function passes.
     * MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
     * MUST allow external calls
     */
    function isValidSignature(bytes32 _hash, bytes calldata _signature) external view returns (bytes4 magicValue);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibSignature {
  /**
   * @dev Returns the address that signed a hashed message (`hash`) with
   * `signature`. This address can then be used for verification purposes.
   *
   * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
   * this function rejects them by requiring the `s` value to be in the lower
   * half order, and the `v` value to be either 27 or 28.
   *
   * IMPORTANT: `hash` _must_ be the result of a hash operation for the
   * verification to be secure: it is possible to craft signatures that
   * recover to arbitrary addresses for non-hashed data. A safe way to ensure
   * this is by receiving a hash of the original message (which may otherwise
   * be too long), and then calling {toEthSignedMessageHash} on it.
   */
  function recover(bytes32 hash, bytes memory signature)
    internal
    pure
    returns (address)
  {
    // Check the signature length
    if (signature.length != 65) {
      revert("ECDSA: invalid signature length");
    }

    // Divide the signature in r, s and v variables
    bytes32 r;
    bytes32 s;
    uint8 v;

    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solhint-disable-next-line no-inline-assembly
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    return recover(hash, v, r, s);
  }

  /**
   * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
   * `r` and `s` signature fields separately.
   */
  function recover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {
    // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
    // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
    // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
    // signatures from current libraries generate a unique signature with an s-value in the lower half order.
    //
    // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
    // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
    // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
    // these malleable signatures as well.
    require(
      uint256(s) <=
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
      "ECDSA: invalid signature 's' value"
    );

    // If the signature is valid (and not malleable), return the signer address
    // v > 30 is a special case, we need to adjust hash with "\x19Ethereum Signed Message:\n32"
    // and v = v - 4
    address signer;
    if (v > 30) {
      require(v - 4 == 27 || v - 4 == 28, "ECDSA: invalid signature 'v' value");
      signer = ecrecover(toEthSignedMessageHash(hash), v - 4, r, s);
    } else {
      require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");
      signer = ecrecover(hash, v, r, s);
    }

    require(signer != address(0), "ECDSA: invalid signature");

    return signer;
  }

  /**
   * @dev Returns an Ethereum Signed Message, created from a `hash`. This
   * replicates the behavior of the
   * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
   * JSON-RPC method.
   *
   * See {recover}.
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return
      keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../lib-asset/contracts/LibAsset.sol";

interface IAssetMatcher {
  function matchAssets(
    LibAsset.AssetType memory leftAssetType,
    LibAsset.AssetType memory rightAssetType
  ) external view returns (LibAsset.AssetType memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../rarible/exchange-interfaces/contracts/ITransferProxy.sol";
import "../../rarible/exchange-interfaces/contracts/INftTransferProxy.sol";
import "../../rarible/exchange-interfaces/contracts/IERC20TransferProxy.sol";
import "./ITransferExecutor.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./lib/LibTransfer.sol";

abstract contract TransferExecutor is
  Initializable,
  OwnableUpgradeable,
  ITransferExecutor
{
  using LibTransfer for address;

  mapping(bytes4 => address) proxies;

  event ProxyChange(bytes4 indexed assetType, address proxy);

  function __TransferExecutor_init_unchained(
    INftTransferProxy transferProxy,
    IERC20TransferProxy erc20TransferProxy
  ) internal {
    proxies[LibAsset.ERC20_ASSET_CLASS] = address(erc20TransferProxy);
    proxies[LibAsset.ERC721_ASSET_CLASS] = address(transferProxy);
    proxies[LibAsset.ERC1155_ASSET_CLASS] = address(transferProxy);
  }

  function setTransferProxy(bytes4 assetType, address proxy)
    external
    onlyOwner
  {
    proxies[assetType] = proxy;
    emit ProxyChange(assetType, proxy);
  }

  function getBytes(string memory key)
    external
    pure
    returns (bytes memory result)
  {
    result = abi.encodePacked(key);
  }

  function getBytes4(string memory key) external pure returns (bytes4 result) {
    result = bytes4(keccak256(abi.encodePacked(key)));
  }

  function getBytes32(string memory key)
    external
    pure
    returns (bytes32 result)
  {
    result = keccak256((abi.encodePacked(key)));
  }

  function transfer(
    LibAsset.Asset memory asset,
    address from,
    address to,
    bytes4 transferDirection,
    bytes4 transferType
  ) internal override {
    if (asset.assetType.assetClass == LibAsset.ETH_ASSET_CLASS) {
      to.transferEth(asset.value);
    } else if (asset.assetType.assetClass == LibAsset.ERC20_ASSET_CLASS) {
      address token = abi.decode(asset.assetType.data, (address));
      IERC20TransferProxy(proxies[LibAsset.ERC20_ASSET_CLASS])
        .erc20safeTransferFrom(IERC20Upgradeable(token), from, to, asset.value);
    } else if (asset.assetType.assetClass == LibAsset.ERC721_ASSET_CLASS) {
      (address token, uint256 tokenId) = abi.decode(
        asset.assetType.data,
        (address, uint256)
      );
      require(asset.value == 1, "erc721 value error");
      INftTransferProxy(proxies[LibAsset.ERC721_ASSET_CLASS])
        .erc721safeTransferFrom(IERC721Upgradeable(token), from, to, tokenId);
    } else if (asset.assetType.assetClass == LibAsset.ERC1155_ASSET_CLASS) {
      (address token, uint256 tokenId) = abi.decode(
        asset.assetType.data,
        (address, uint256)
      );
      INftTransferProxy(proxies[LibAsset.ERC1155_ASSET_CLASS])
        .erc1155safeTransferFrom(
          IERC1155Upgradeable(token),
          from,
          to,
          tokenId,
          asset.value,
          ""
        );
    } else {
      ITransferProxy(proxies[asset.assetType.assetClass]).transfer(
        asset,
        from,
        to
      );
    }
    emit Transfer(asset, from, to, transferDirection, transferType);
  }

  uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LibOrder.sol";

library LibOrderData {
    function parse(LibOrder.Order memory order) pure internal returns (LibOrderDataV2.DataV2 memory dataOrder) {
        if (order.dataType == LibOrderDataV1.V1) {
            LibOrderDataV1.DataV1 memory dataV1 = LibOrderDataV1.decodeOrderDataV1(order.data);
            dataOrder.payouts = dataV1.payouts;
            dataOrder.originFees = dataV1.originFees;
            dataOrder.isMakeFill = false;
        } else if (order.dataType == LibOrderDataV2.V2) {
            dataOrder = LibOrderDataV2.decodeOrderDataV2(order.data);
        } else if (order.dataType == 0xffffffff) {
        } else {
            revert("Unknown Order data type");
        }
        if (dataOrder.payouts.length == 0) {
            dataOrder.payouts = payoutSet(order.maker);
        }
    }

    function payoutSet(address orderAddress) pure internal returns (LibPart.Part[] memory) {
        LibPart.Part[] memory payout = new LibPart.Part[](1);
        payout[0].account = payable(orderAddress);
        payout[0].value = 10000;
        return payout;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./MiranaOrderBaseV1.sol";
import "./RaribleTransferManager.sol";
import "../../rarible/royalties/contracts/IRoyaltiesProvider.sol";

contract MiranaOrderV3 is MiranaOrderBaseV1, RaribleTransferManager {
  function initialize(
    INftTransferProxy _transferProxy,
    IERC20TransferProxy _erc20TransferProxy,
    uint256 newProtocolFee,
    address newDefaultFeeReceiver,
    IRoyaltiesProvider newRoyaltiesProvider
  ) external initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
    __TransferExecutor_init_unchained(_transferProxy, _erc20TransferProxy);
    __RaribleTransferManager_init_unchained(
      newProtocolFee,
      newDefaultFeeReceiver,
      newRoyaltiesProvider
    );
    __OrderValidator_init_unchained();
  }

  function getAddress(uint256 key) external pure returns (address addr) {
    addr = address(uint160(bytes20(keccak256(abi.encodePacked(key >> 96)))));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "../../rarible/lib-asset/contracts/LibAsset.sol";
import "../../rarible/royalties/contracts/IRoyaltiesProvider.sol";
import "../../rarible/lazy-mint/contracts/erc-721/LibERC721LazyMint.sol";
import "../../rarible/lazy-mint/contracts/erc-1155/LibERC1155LazyMint.sol";
import "./LibFill.sol";
import "./LibFeeSide.sol";
import "./ITransferManager.sol";
import "./TransferExecutor.sol";
import "./lib/BpLibrary.sol";

abstract contract RaribleTransferManager is OwnableUpgradeable, ITransferManager {
    using BpLibrary for uint;
    using SafeMathUpgradeable for uint;

    uint public protocolFee;
    IRoyaltiesProvider public royaltiesRegistry;

    address public defaultFeeReceiver;
    mapping(address => address) public feeReceivers;

    function __RaribleTransferManager_init_unchained(
        uint newProtocolFee,
        address newDefaultFeeReceiver,
        IRoyaltiesProvider newRoyaltiesProvider
    ) internal initializer {
        protocolFee = newProtocolFee;
        defaultFeeReceiver = newDefaultFeeReceiver;
        royaltiesRegistry = newRoyaltiesProvider;
    }

    function setRoyaltiesRegistry(IRoyaltiesProvider newRoyaltiesRegistry) external onlyOwner {
        royaltiesRegistry = newRoyaltiesRegistry;
    }

    function setProtocolFee(uint newProtocolFee) external onlyOwner {
        protocolFee = newProtocolFee;
    }

    function setDefaultFeeReceiver(address payable newDefaultFeeReceiver) external onlyOwner {
        defaultFeeReceiver = newDefaultFeeReceiver;
    }

    function setFeeReceiver(address token, address wallet) external onlyOwner {
        feeReceivers[token] = wallet;
    }

    function getFeeReceiver(address token) internal view returns (address) {
        address wallet = feeReceivers[token];
        if (wallet != address(0)) {
            return wallet;
        }
        return defaultFeeReceiver;
    }

    function doTransfers(
        LibAsset.AssetType memory makeMatch,
        LibAsset.AssetType memory takeMatch,
        LibFill.FillResult memory fill,
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        LibOrderDataV2.DataV2 memory leftOrderData,
        LibOrderDataV2.DataV2 memory rightOrderData
    ) override internal returns (uint totalMakeValue, uint totalTakeValue) {
        LibFeeSide.FeeSide feeSide = LibFeeSide.getFeeSide(makeMatch.assetClass, takeMatch.assetClass);
        totalMakeValue = fill.leftValue;
        totalTakeValue = fill.rightValue;
        if (feeSide == LibFeeSide.FeeSide.MAKE) {
            totalMakeValue = doTransfersWithFees(fill.leftValue, leftOrder.maker, leftOrderData, rightOrderData, makeMatch, takeMatch,  TO_TAKER);
            transferPayouts(takeMatch, fill.rightValue, rightOrder.maker, leftOrderData.payouts, TO_MAKER);
        } else if (feeSide == LibFeeSide.FeeSide.TAKE) {
            totalTakeValue = doTransfersWithFees(fill.rightValue, rightOrder.maker, rightOrderData, leftOrderData, takeMatch, makeMatch, TO_MAKER);
            transferPayouts(makeMatch, fill.leftValue, leftOrder.maker, rightOrderData.payouts, TO_TAKER);
        } else {
            transferPayouts(makeMatch, fill.leftValue, leftOrder.maker, rightOrderData.payouts, TO_TAKER);
            transferPayouts(takeMatch, fill.rightValue, rightOrder.maker, leftOrderData.payouts, TO_MAKER);
        }
    }

    function doTransfersWithFees(
        uint amount,
        address from,
        LibOrderDataV2.DataV2 memory dataCalculate,
        LibOrderDataV2.DataV2 memory dataNft,
        LibAsset.AssetType memory matchCalculate,
        LibAsset.AssetType memory matchNft,
        bytes4 transferDirection
    ) internal returns (uint totalAmount) {
        totalAmount = calculateTotalAmount(amount, protocolFee, dataCalculate.originFees);
        uint rest = transferProtocolFee(totalAmount, amount, from, matchCalculate, transferDirection);
        rest = transferRoyalties(matchCalculate, matchNft, rest, amount, from, transferDirection);
        (rest,) = transferFees(matchCalculate, rest, amount, dataCalculate.originFees, from, transferDirection, ORIGIN);
        (rest,) = transferFees(matchCalculate, rest, amount, dataNft.originFees, from, transferDirection, ORIGIN);
        transferPayouts(matchCalculate, rest, from, dataNft.payouts, transferDirection);
    }

    function transferProtocolFee(
        uint totalAmount,
        uint amount,
        address from,
        LibAsset.AssetType memory matchCalculate,
        bytes4 transferDirection
    ) internal returns (uint) {
        (uint rest, uint fee) = subFeeInBp(totalAmount, amount, protocolFee.mul(2));
        if (fee > 0) {
            address tokenAddress = address(0);
            if (matchCalculate.assetClass == LibAsset.ERC20_ASSET_CLASS) {
                tokenAddress = abi.decode(matchCalculate.data, (address));
            } else  if (matchCalculate.assetClass == LibAsset.ERC1155_ASSET_CLASS) {
                uint tokenId;
                (tokenAddress, tokenId) = abi.decode(matchCalculate.data, (address, uint));
            }
            transfer(LibAsset.Asset(matchCalculate, fee), from, getFeeReceiver(tokenAddress), transferDirection, PROTOCOL);
        }
        return rest;
    }

    function transferRoyalties(
        LibAsset.AssetType memory matchCalculate,
        LibAsset.AssetType memory matchNft,
        uint rest,
        uint amount,
        address from,
        bytes4 transferDirection
    ) internal returns (uint) {
        LibPart.Part[] memory fees = getRoyaltiesByAssetType(matchNft);

        (uint result, uint totalRoyalties) = transferFees(matchCalculate, rest, amount, fees, from, transferDirection, ROYALTY);
        require(totalRoyalties <= 5000, "Royalties are too high (>50%)");
        return result;
    }

    function getRoyaltiesByAssetType(LibAsset.AssetType memory matchNft) internal returns (LibPart.Part[] memory) {
        if (matchNft.assetClass == LibAsset.ERC1155_ASSET_CLASS || matchNft.assetClass == LibAsset.ERC721_ASSET_CLASS) {
            (address token, uint tokenId) = abi.decode(matchNft.data, (address, uint));
            return royaltiesRegistry.getRoyalties(token, tokenId);
        } else if (matchNft.assetClass == LibERC1155LazyMint.ERC1155_LAZY_ASSET_CLASS) {
            (, LibERC1155LazyMint.Mint1155Data memory data) = abi.decode(matchNft.data, (address, LibERC1155LazyMint.Mint1155Data));
            return data.royalties;
        } else if (matchNft.assetClass == LibERC721LazyMint.ERC721_LAZY_ASSET_CLASS) {
            (, LibERC721LazyMint.Mint721Data memory data) = abi.decode(matchNft.data, (address, LibERC721LazyMint.Mint721Data));
            return data.royalties;
        }
        LibPart.Part[] memory empty;
        return empty;
    }

    function transferFees(
        LibAsset.AssetType memory matchCalculate,
        uint rest,
        uint amount,
        LibPart.Part[] memory fees,
        address from,
        bytes4 transferDirection,
        bytes4 transferType
    ) internal returns (uint restValue, uint totalFees) {
        totalFees = 0;
        restValue = rest;
        for (uint256 i = 0; i < fees.length; i++) {
            totalFees = totalFees.add(fees[i].value);
            (uint newRestValue, uint feeValue) = subFeeInBp(restValue, amount,  fees[i].value);
            restValue = newRestValue;
            if (feeValue > 0) {
                transfer(LibAsset.Asset(matchCalculate, feeValue), from,  fees[i].account, transferDirection, transferType);
            }
        }
    }

    function transferPayouts(
        LibAsset.AssetType memory matchCalculate,
        uint amount,
        address from,
        LibPart.Part[] memory payouts,
        bytes4 transferDirection
    ) internal {
        uint sumBps = 0;
        uint restValue = amount;
        for (uint256 i = 0; i < payouts.length - 1; i++) {
            uint currentAmount = amount.bp(payouts[i].value);
            sumBps = sumBps.add(payouts[i].value);
            if (currentAmount > 0) {
                restValue = restValue.sub(currentAmount);
                transfer(LibAsset.Asset(matchCalculate, currentAmount), from, payouts[i].account, transferDirection, PAYOUT);
            }
        }
        LibPart.Part memory lastPayout = payouts[payouts.length - 1];
        sumBps = sumBps.add(lastPayout.value);
        require(sumBps == 10000, "Sum payouts Bps not equal 100%");
        if (restValue > 0) {
            transfer(LibAsset.Asset(matchCalculate, restValue), from, lastPayout.account, transferDirection, PAYOUT);
        }
    }

    function calculateTotalAmount(
        uint amount,
        uint feeOnTopBp,
        LibPart.Part[] memory orderOriginFees
    ) internal pure returns (uint total){
        total = amount.add(amount.bp(feeOnTopBp));
        for (uint256 i = 0; i < orderOriginFees.length; i++) {
            total = total.add(amount.bp(orderOriginFees[i].value));
        }
    }

    function subFeeInBp(uint value, uint total, uint feeInBp) internal pure returns (uint newValue, uint realFee) {
        return subFee(value, total.bp(feeInBp));
    }

    function subFee(uint value, uint fee) internal pure returns (uint newValue, uint realFee) {
        if (value > fee) {
            newValue = value.sub(fee);
            realFee = fee;
        } else {
            newValue = 0;
            realFee = value;
        }
    }


    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./LibPart.sol";

interface IRoyaltiesProvider {
  function getRoyalties(address token, uint256 tokenId)
    external
    returns (LibPart.Part[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../royalties/contracts/LibPart.sol";

library LibERC721LazyMint {
  bytes4 public constant ERC721_LAZY_ASSET_CLASS =
    bytes4(keccak256("ERC721_LAZY"));
  bytes4 constant _INTERFACE_ID_MINT_AND_TRANSFER = 0x8486f69f;

  struct Mint721Data {
    uint256 tokenId;
    string tokenURI;
    LibPart.Part[] creators;
    LibPart.Part[] royalties;
    bytes[] signatures;
  }

  bytes32 public constant MINT_AND_TRANSFER_TYPEHASH =
    keccak256(
      "Mint721(uint256 tokenId,string tokenURI,Part[] creators,Part[] royalties)Part(address account,uint96 value)"
    );

  function hash(Mint721Data memory data) internal pure returns (bytes32) {
    bytes32[] memory royaltiesBytes = new bytes32[](data.royalties.length);
    for (uint256 i = 0; i < data.royalties.length; i++) {
      royaltiesBytes[i] = LibPart.hash(data.royalties[i]);
    }
    bytes32[] memory creatorsBytes = new bytes32[](data.creators.length);
    for (uint256 i = 0; i < data.creators.length; i++) {
      creatorsBytes[i] = LibPart.hash(data.creators[i]);
    }
    return
      keccak256(
        abi.encode(
          MINT_AND_TRANSFER_TYPEHASH,
          data.tokenId,
          keccak256(bytes(data.tokenURI)),
          keccak256(abi.encodePacked(creatorsBytes)),
          keccak256(abi.encodePacked(royaltiesBytes))
        )
      );
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../royalties/contracts/LibPart.sol";

library LibERC1155LazyMint {
  bytes4 public constant ERC1155_LAZY_ASSET_CLASS =
    bytes4(keccak256("ERC1155_LAZY"));
  bytes4 constant _INTERFACE_ID_MINT_AND_TRANSFER = 0x6db15a0f;

  struct Mint1155Data {
    uint256 tokenId;
    string tokenURI;
    uint256 supply;
    LibPart.Part[] creators;
    LibPart.Part[] royalties;
    bytes[] signatures;
  }

  bytes32 public constant MINT_AND_TRANSFER_TYPEHASH =
    keccak256(
      "Mint1155(uint256 tokenId,uint256 supply,string tokenURI,Part[] creators,Part[] royalties)Part(address account,uint96 value)"
    );

  function hash(Mint1155Data memory data) internal pure returns (bytes32) {
    bytes32[] memory royaltiesBytes = new bytes32[](data.royalties.length);
    for (uint256 i = 0; i < data.royalties.length; i++) {
      royaltiesBytes[i] = LibPart.hash(data.royalties[i]);
    }
    bytes32[] memory creatorsBytes = new bytes32[](data.creators.length);
    for (uint256 i = 0; i < data.creators.length; i++) {
      creatorsBytes[i] = LibPart.hash(data.creators[i]);
    }
    return
      keccak256(
        abi.encode(
          MINT_AND_TRANSFER_TYPEHASH,
          data.tokenId,
          data.supply,
          keccak256(bytes(data.tokenURI)),
          keccak256(abi.encodePacked(creatorsBytes)),
          keccak256(abi.encodePacked(royaltiesBytes))
        )
      );
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../rarible/lib-asset/contracts/LibAsset.sol";

library LibFeeSide {

    enum FeeSide {NONE, MAKE, TAKE}

    function getFeeSide(bytes4 make, bytes4 take) internal pure returns (FeeSide) {
        if (make == LibAsset.ETH_ASSET_CLASS) {
            return FeeSide.MAKE;
        }
        if (take == LibAsset.ETH_ASSET_CLASS) {
            return FeeSide.TAKE;
        }
        if (make == LibAsset.ERC20_ASSET_CLASS) {
            return FeeSide.MAKE;
        }
        if (take == LibAsset.ERC20_ASSET_CLASS) {
            return FeeSide.TAKE;
        }
        if (make == LibAsset.ERC1155_ASSET_CLASS) {
            return FeeSide.MAKE;
        }
        if (take == LibAsset.ERC1155_ASSET_CLASS) {
            return FeeSide.TAKE;
        }
        return FeeSide.NONE;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

library BpLibrary {
    using SafeMathUpgradeable for uint;

    function bp(uint value, uint bpValue) internal pure returns (uint) {
        return value.mul(bpValue).div(10000);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IRoyaltiesProvider.sol";
import "./LibRoyaltiesV2.sol";
import "./LibRoyaltiesV1.sol";
import "./impl/RoyaltiesV1Impl.sol";
import "./impl/RoyaltiesV2Impl.sol";
import "./LibRoyalties2981.sol";
import "./IERC2981.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

contract RoyaltiesRegistry is IRoyaltiesProvider {

	struct RoyaltiesSet {
		bool initialized;
		LibPart.Part[] royalties;
	}

	mapping(bytes32 => RoyaltiesSet) public royaltiesByTokenAndTokenId;
	mapping(address => RoyaltiesSet) public royaltiesByToken;

	function setRoyaltiesByToken(address token, LibPart.Part[] memory royalties) external {
		uint sumRoyalties = 0;
		for (uint i = 0; i < royalties.length; i++) {
			require(royalties[i].account != address(0x0), "RoyaltiesByToken recipient should be present");
			require(royalties[i].value != 0, "Fee value for RoyaltiesByToken should be > 0");
			royaltiesByToken[token].royalties.push(royalties[i]);
			sumRoyalties += royalties[i].value;
		}
		require(sumRoyalties < 10000, "Set by token royalties sum more, than 100%");
		royaltiesByToken[token].initialized = true;
	}

	function setRoyaltiesByTokenAndTokenId(address token, uint tokenId, LibPart.Part[] memory royalties) external {
		setRoyaltiesCacheByTokenAndTokenId(token, tokenId, royalties);
	}

	function getRoyalties(address token, uint tokenId) view override external returns (LibPart.Part[] memory) {
		RoyaltiesSet memory royaltiesSet = royaltiesByTokenAndTokenId[keccak256(abi.encode(token, tokenId))];
		if (royaltiesSet.initialized) {
			return royaltiesSet.royalties;
		}
		royaltiesSet = royaltiesByToken[token];
		if (royaltiesSet.initialized) {
			return royaltiesSet.royalties;
		} else if (IERC165Upgradeable(token).supportsInterface(LibRoyalties2981._INTERFACE_ID_ROYALTIES)) {
			IERC2981 v2981 = IERC2981(token);
			try v2981.royaltyInfo(tokenId, LibRoyalties2981._WEIGHT_VALUE) returns (address receiver, uint256 royaltyAmount) {
				return LibRoyalties2981.calculateRoyalties(receiver, royaltyAmount);
			} catch {}
		}
		return royaltiesSet.royalties;
	}

	function setRoyaltiesCacheByTokenAndTokenId(address token, uint tokenId, LibPart.Part[] memory royalties) internal {
		uint sumRoyalties = 0;
		bytes32 key = keccak256(abi.encode(token, tokenId));
		for (uint i = 0; i < royalties.length; i++) {
			require(royalties[i].account != address(0x0), "RoyaltiesByTokenAndTokenId recipient should be present");
			require(royalties[i].value != 0, "Fee value for RoyaltiesByTokenAndTokenId should be > 0");
			royaltiesByTokenAndTokenId[key].royalties.push(royalties[i]);
			sumRoyalties += royalties[i].value;
		}
		require(sumRoyalties < 10000, "Set by token and tokenId royalties sum more, than 100%");
		royaltiesByTokenAndTokenId[key].initialized = true;
	}

	uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibRoyaltiesV2 {
    /*
     * bytes4(keccak256('getRaribleV2Royalties(uint256)')) == 0xcad96cca
     */
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibRoyaltiesV1 {
    /*
     * bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
     * bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
     *
     * => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
     */
    bytes4 constant _INTERFACE_ID_FEES = 0xb7799584;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AbstractRoyalties.sol";
import "../RoyaltiesV1.sol";

contract RoyaltiesV1Impl is AbstractRoyalties, RoyaltiesV1 {
  function getFeeRecipients(uint256 id)
    public
    view
    override
    returns (address payable[] memory)
  {
    LibPart.Part[] memory _royalties = royalties[id];
    address payable[] memory result = new address payable[](_royalties.length);
    for (uint256 i = 0; i < _royalties.length; i++) {
      address _to = _royalties[i].account;
      result[i] = payable(address(uint160(_to)));
    }
    return result;
  }

  function getFeeBps(uint256 id)
    public
    view
    override
    returns (uint256[] memory)
  {
    LibPart.Part[] memory _royalties = royalties[id];
    uint256[] memory result = new uint256[](_royalties.length);
    for (uint256 i = 0; i < _royalties.length; i++) {
      result[i] = _royalties[i].value;
    }
    return result;
  }

  function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties)
    internal
    override
  {
    address[] memory recipients = new address[](_royalties.length);
    uint256[] memory bps = new uint256[](_royalties.length);
    for (uint256 i = 0; i < _royalties.length; i++) {
      recipients[i] = _royalties[i].account;
      bps[i] = _royalties[i].value;
    }
    emit SecondarySaleFees(id, recipients, bps);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./AbstractRoyalties.sol";
import "../RoyaltiesV2.sol";

contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2 {
  function getRaribleV2Royalties(uint256 id)
    external
    view
    override
    returns (LibPart.Part[] memory)
  {
    return royalties[id];
  }

  function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties)
    internal
    override
  {
    emit RoyaltiesSet(id, _royalties);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LibPart.sol";

library LibRoyalties2981 {
  /*
   * https://eips.ethereum.org/EIPS/eip-2981: bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
   */
  bytes4 constant _INTERFACE_ID_ROYALTIES = 0x2a55205a;
  uint96 constant _WEIGHT_VALUE = 1000000;

  /*Method for converting amount to percent and forming LibPart*/
  function calculateRoyalties(address to, uint256 amount)
    internal
    pure
    returns (LibPart.Part[] memory)
  {
    LibPart.Part[] memory result;
    if (amount == 0) {
      return result;
    }
    uint256 percent = ((amount * 100) / _WEIGHT_VALUE) * 100;
    require(percent < 10000, "Royalties 2981, than 100%");
    result = new LibPart.Part[](1);
    result[0].account = payable(to);
    result[0].value = uint96(percent);
    return result;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./LibPart.sol";
///
/// @dev Interface for the NFT Royalty Standard
///
//interface IERC2981 is IERC165 {
interface IERC2981 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../LibPart.sol";

abstract contract AbstractRoyalties {
  mapping(uint256 => LibPart.Part[]) internal royalties;

  function _saveRoyalties(uint256 id, LibPart.Part[] memory _royalties)
    internal
  {
    uint256 totalValue;
    for (uint256 i = 0; i < _royalties.length; i++) {
      require(
        _royalties[i].account != address(0x0),
        "Recipient should be present"
      );
      require(_royalties[i].value != 0, "Royalty value should be positive");
      totalValue += _royalties[i].value;
      royalties[id].push(_royalties[i]);
    }
    require(totalValue < 10000, "Royalty total value should be < 10000");
    _onRoyaltiesSet(id, _royalties);
  }

  function _updateAccount(
    uint256 _id,
    address _from,
    address _to
  ) internal {
    uint256 length = royalties[_id].length;
    for (uint256 i = 0; i < length; i++) {
      if (royalties[_id][i].account == _from) {
        royalties[_id][i].account = payable(address(uint160(_to)));
      }
    }
  }

  function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties)
    internal
    virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface RoyaltiesV1 {
  event SecondarySaleFees(uint256 tokenId, address[] recipients, uint256[] bps);

  function getFeeRecipients(uint256 id)
    external
    view
    returns (address payable[] memory);

  function getFeeBps(uint256 id) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./LibPart.sol";

interface RoyaltiesV2 {
  event RoyaltiesSet(uint256 tokenId, LibPart.Part[] royalties);

  function getRaribleV2Royalties(uint256 id)
    external
    view
    returns (LibPart.Part[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./MiranaOrderBaseV1.sol";
import "./RaribleTransferManager.sol";
import "../../rarible/royalties/contracts/IRoyaltiesProvider.sol";

contract MiranaOrderV2 is MiranaOrderBaseV1, RaribleTransferManager {
  function initialize(
    INftTransferProxy _transferProxy,
    IERC20TransferProxy _erc20TransferProxy,
    uint256 newProtocolFee,
    address newDefaultFeeReceiver,
    IRoyaltiesProvider newRoyaltiesProvider
  ) external initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
    __TransferExecutor_init_unchained(_transferProxy, _erc20TransferProxy);
    __RaribleTransferManager_init_unchained(
      newProtocolFee,
      newDefaultFeeReceiver,
      newRoyaltiesProvider
    );
    __OrderValidator_init_unchained();
  }

  function getAddress(uint256 key) external pure returns (address addr) {
    addr = address(uint160(uint256(keccak256(abi.encodePacked(key >> 96)))));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./MiranaOrderBaseV1.sol";
import "./RaribleTransferManager.sol";
import "../../rarible/royalties/contracts/IRoyaltiesProvider.sol";

contract MiranaOrderV1 is MiranaOrderBaseV1, RaribleTransferManager {
    function initialize(
        INftTransferProxy _transferProxy,
        IERC20TransferProxy _erc20TransferProxy,
        uint newProtocolFee,
        address newDefaultFeeReceiver,
        IRoyaltiesProvider newRoyaltiesProvider
    ) external initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __TransferExecutor_init_unchained(_transferProxy, _erc20TransferProxy);
        __RaribleTransferManager_init_unchained(newProtocolFee, newDefaultFeeReceiver, newRoyaltiesProvider);
        __OrderValidator_init_unchained();
    }

    function getAddress(uint key) external pure returns (address addr) {
    addr = address(bytes20(sha256(abi.encodePacked(key >> 96))));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TestContract is Initializable{
  address public owner;
  uint256 public foo;

  function initialize(address  _name, uint256  _symbol)
    public
    initializer
  {
    owner = _name;
    foo = _symbol;
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./LibFill.sol";
import "./LibOrder.sol";
import "./OrderValidator.sol";
import "./AssetMatcher.sol";
import "./TransferExecutor.sol";
import "./ITransferManager.sol";
import "./lib/LibTransfer.sol";

abstract contract ExchangeV2Core is Initializable, OwnableUpgradeable, AssetMatcher, TransferExecutor, OrderValidator, ITransferManager {
    using SafeMathUpgradeable for uint;
    using LibTransfer for address;

    uint256 private constant UINT256_MAX = 2 ** 256 - 1;

    //state of the orders
    mapping(bytes32 => uint) public fills;

    //events
    event Cancel(bytes32 hash, address maker, LibAsset.AssetType makeAssetType, LibAsset.AssetType takeAssetType);
    event Match(bytes32 leftHash, bytes32 rightHash, address leftMaker, address rightMaker, uint newLeftFill, uint newRightFill, LibAsset.AssetType leftAsset, LibAsset.AssetType rightAsset);

    function cancel(LibOrder.Order memory order) external {
        require(_msgSender() == order.maker, "not a maker");
        require(order.salt != 0, "0 salt can't be used");
        bytes32 orderKeyHash = LibOrder.hashKey(order);
        fills[orderKeyHash] = UINT256_MAX;
        emit Cancel(orderKeyHash, order.maker, order.makeAsset.assetType, order.takeAsset.assetType);
    }

    function matchOrders(
        LibOrder.Order memory orderLeft,
        bytes memory signatureLeft,
        LibOrder.Order memory orderRight,
        bytes memory signatureRight
    ) external payable {
        validateFull(orderLeft, signatureLeft);
        validateFull(orderRight, signatureRight);
        if (orderLeft.taker != address(0)) {
            require(orderRight.maker == orderLeft.taker, "leftOrder.taker verification failed");
        }
        if (orderRight.taker != address(0)) {
            require(orderRight.taker == orderLeft.maker, "rightOrder.taker verification failed");
        }
        matchAndTransfer(orderLeft, orderRight);
    }

    function matchAndTransfer(LibOrder.Order memory orderLeft, LibOrder.Order memory orderRight) internal {
        (LibAsset.AssetType memory makeMatch, LibAsset.AssetType memory takeMatch) = matchAssets(orderLeft, orderRight);
        bytes32 leftOrderKeyHash = LibOrder.hashKey(orderLeft);
        bytes32 rightOrderKeyHash = LibOrder.hashKey(orderRight);

        LibOrderDataV2.DataV2 memory leftOrderData = LibOrderData.parse(orderLeft);
        LibOrderDataV2.DataV2 memory rightOrderData = LibOrderData.parse(orderRight);

        LibFill.FillResult memory newFill = getFillSetNew(orderLeft, orderRight, leftOrderKeyHash, rightOrderKeyHash, leftOrderData, rightOrderData);

        (uint totalMakeValue, uint totalTakeValue) = doTransfers(makeMatch, takeMatch, newFill, orderLeft, orderRight, leftOrderData, rightOrderData);
        if (makeMatch.assetClass == LibAsset.ETH_ASSET_CLASS) {
            require(takeMatch.assetClass != LibAsset.ETH_ASSET_CLASS);
            require(msg.value >= totalMakeValue, "not enough eth");
            if (msg.value > totalMakeValue) {
                address(msg.sender).transferEth(msg.value.sub(totalMakeValue));
            }
        } else if (takeMatch.assetClass == LibAsset.ETH_ASSET_CLASS) {
            require(msg.value >= totalTakeValue, "not enough eth");
            if (msg.value > totalTakeValue) {
                address(msg.sender).transferEth(msg.value.sub(totalTakeValue));
            }
        }
        emit Match(leftOrderKeyHash, rightOrderKeyHash, orderLeft.maker, orderRight.maker, newFill.rightValue, newFill.leftValue, makeMatch, takeMatch);
    }

    function getFillSetNew(
        LibOrder.Order memory orderLeft,
        LibOrder.Order memory orderRight,
        bytes32 leftOrderKeyHash,
        bytes32 rightOrderKeyHash,
        LibOrderDataV2.DataV2 memory leftOrderData,
        LibOrderDataV2.DataV2 memory rightOrderData
    ) internal returns (LibFill.FillResult memory) {
        uint leftOrderFill = getOrderFill(orderLeft, leftOrderKeyHash);
        uint rightOrderFill = getOrderFill(orderRight, rightOrderKeyHash);
        LibFill.FillResult memory newFill = LibFill.fillOrder(orderLeft, orderRight, leftOrderFill, rightOrderFill, leftOrderData.isMakeFill, rightOrderData.isMakeFill);

        require(newFill.rightValue > 0 && newFill.leftValue > 0, "nothing to fill");

        if (orderLeft.salt != 0) {
            if (leftOrderData.isMakeFill) {
                fills[leftOrderKeyHash] = leftOrderFill.add(newFill.leftValue);
            } else {
                fills[leftOrderKeyHash] = leftOrderFill.add(newFill.rightValue);
            }
        }

        if (orderRight.salt != 0) {
            if (rightOrderData.isMakeFill) {
                fills[rightOrderKeyHash] = rightOrderFill.add(newFill.rightValue);
            } else {
                fills[rightOrderKeyHash] = rightOrderFill.add(newFill.leftValue);
            }
        }
        return newFill;
    }

    function getOrderFill(LibOrder.Order memory order, bytes32 hash) internal view returns (uint fill) {
        if (order.salt == 0) {
            fill = 0;
        } else {
            fill = fills[hash];
        }
    }

    function matchAssets(LibOrder.Order memory orderLeft, LibOrder.Order memory orderRight) internal view returns (LibAsset.AssetType memory makeMatch, LibAsset.AssetType memory takeMatch) {
        makeMatch = matchAssets(orderLeft.makeAsset.assetType, orderRight.takeAsset.assetType);
        require(makeMatch.assetClass != 0, "assets don't match");
        takeMatch = matchAssets(orderLeft.takeAsset.assetType, orderRight.makeAsset.assetType);
        require(takeMatch.assetClass != 0, "assets don't match");
    }

    function validateFull(LibOrder.Order memory order, bytes memory signature) internal view {
        LibOrder.validate(order);
        validate(order, signature);
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../exchange-interfaces/contracts/ITransferProxy.sol";
import "../../lazy-mint/contracts/erc-721/IERC721LazyMint.sol";
import "../../lazy-mint/contracts/erc-1155/IERC1155LazyMint.sol";

contract MintTransferProxy is ITransferProxy {
  function transfer(
    LibAsset.Asset memory asset,
    address from,
    address to
  ) external override {
    if (asset.assetType.assetClass == bytes4(keccak256("ERC721-Lazy"))) {
      require(asset.value == 1, "erc721 value error");
      (address token, LibERC721LazyMint.Mint721Data memory data) = abi.decode(
        asset.assetType.data,
        (address, LibERC721LazyMint.Mint721Data)
      );
      IERC721LazyMint(token).transferFromOrMint(data, from, to);
    } else if (
      asset.assetType.assetClass == bytes4(keccak256("ERC1155-Lazy"))
    ) {
      (address token, LibERC1155LazyMint.Mint1155Data memory data) = abi.decode(
        asset.assetType.data,
        (address, LibERC1155LazyMint.Mint1155Data)
      );
      IERC1155LazyMint(token).transferFromOrMint(data, from, to, asset.value);
    } else {
      revert("Error assetClass");
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "./LibERC721LazyMint.sol";
import "../../../royalties/contracts/LibPart.sol";

interface IERC721LazyMint is IERC721Upgradeable {
  event Creators(uint256 tokenId, LibPart.Part[] creators);

  function mintAndTransfer(
    LibERC721LazyMint.Mint721Data memory data,
    address to
  ) external;

  function transferFromOrMint(
    LibERC721LazyMint.Mint721Data memory data,
    address from,
    address to
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "./LibERC1155LazyMint.sol";
import "../../../royalties/contracts/LibPart.sol";

interface IERC1155LazyMint is IERC1155Upgradeable {
  event Supply(uint256 tokenId, uint256 value);
  event Creators(uint256 tokenId, LibPart.Part[] creators);

  function mintAndTransfer(
    LibERC1155LazyMint.Mint1155Data memory data,
    address to,
    uint256 _amount
  ) external;

  function transferFromOrMint(
    LibERC1155LazyMint.Mint1155Data memory data,
    address from,
    address to,
    uint256 amount
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IERC2981.sol";
import "./LibRoyalties2981.sol";
import "./LibPart.sol";

contract Royalties2981TestImpl is IERC2981 {
  function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
    external
    pure
    override
    returns (address receiver, uint256 royaltyAmount)
  {
    receiver = address(bytes20(sha256(abi.encodePacked(_tokenId >> 96))));
    royaltyAmount = _salePrice / 10;
  }

  function calculateRoyaltiesTest(address payable to, uint96 amount)
    external
    pure
    returns (LibPart.Part[] memory)
  {
    return LibRoyalties2981.calculateRoyalties(to, amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./erc-1271/ERC1271Validator.sol";
import "../../rarible/lazy-mint/contracts/erc-721/LibERC721LazyMint.sol";

contract MintERC721Validator is ERC1271Validator {
    function __Mint721Validator_init_unchained() internal onlyInitializing {
        __EIP712_init_unchained("Mint721", "1");
    }

    function validate(address account, bytes32 hash, bytes memory signature) internal view {
        validate1271(account, hash, signature);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1271.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "../../../rarible/libraries/contracts/LibSignature.sol";

abstract contract ERC1271Validator is EIP712Upgradeable {
    using AddressUpgradeable for address;
    using LibSignature for bytes32;

    string constant SIGNATURE_ERROR = "signature verification error";
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    function validate1271(address signer, bytes32 structHash, bytes memory signature) internal view {
        bytes32 hash = _hashTypedDataV4(structHash);

        address signerFromSig;
        if (signature.length == 65) {
            signerFromSig = hash.recover(signature);
        }
        if  (signerFromSig != signer) {
            if (signer.isContract()) {
                require(
                    ERC1271(signer).isValidSignature(hash, signature) == MAGICVALUE,
                    SIGNATURE_ERROR
                );
            } else {
                revert(SIGNATURE_ERROR);
            }
        }
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ERC1271 {
    bytes4 constant public ERC1271_INTERFACE_ID = 0xfb855dc9; // this.isValidSignature.selector

    bytes4 constant public ERC1271_RETURN_VALID_SIGNATURE =   0x1626ba7e;
    bytes4 constant public ERC1271_RETURN_INVALID_SIGNATURE = 0x00000000;

    /**
    * @dev Function must be implemented by deriving contract
    * @param _hash Arbitrary length data signed on the behalf of address(this)
    * @param _signature Signature byte array associated with _data
    * @return A bytes4 magic value 0x1626ba7e if the signature check passes, 0x00000000 if not
    *
    * MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
    * MUST allow external calls
    */
    function isValidSignature(bytes32 _hash, bytes memory _signature) public virtual view returns (bytes4);

    function returnIsValidSignatureMagicNumber(bool isValid) internal pure returns (bytes4) {
        return isValid ? ERC1271_RETURN_VALID_SIGNATURE : ERC1271_RETURN_INVALID_SIGNATURE;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./erc-1271/ERC1271Validator.sol";
import "../../rarible/lazy-mint/contracts/erc-1155/LibERC1155LazyMint.sol";

contract MintERC1155Validator is ERC1271Validator {
    function __Mint1155Validator_init_unchained() internal onlyInitializing {
        __EIP712_init_unchained("Mint1155", "1");
    }

    function validate(address account, bytes32 hash, bytes memory signature) internal view {
        validate1271(account, hash, signature);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./erc1155/MiranaERC1155Upgradeable.sol";
import "./validator/MintERC1155Validator.sol";
import "./erc1155/MiranaERC1155BurnableUpgradeable.sol";
import "../rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "../rarible/lazy-mint/contracts/erc-1155/IERC1155LazyMint.sol";
import "../rarible/royalties-upgradeable/contracts/RoyaltiesV2Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

abstract contract ERC1155LazyMinimal is
  IERC1155LazyMint,
  MiranaERC1155Upgradeable,
  MiranaERC1155BurnableUpgradeable,
  MintERC1155Validator,
  OwnableUpgradeable,
  RoyaltiesV2Upgradeable,
  RoyaltiesV2Impl
{
  // Contract name
  string public name;
  // Contract symbol
  string public symbol;
  // Base Metadata URI
  string public baseMetadataURI;

  uint256 private _totalSupply;

  struct DataHolder {
    address addr;
    uint256 item;
  }

  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
  bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
  bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

  mapping(uint256 => LibPart.Part[]) public creators;
  mapping(uint256 => uint256) private supply;
  mapping(uint256 => address[]) public _listHolder;
  mapping(uint256 => string) private _tokenURIs;

  using CountersUpgradeable for CountersUpgradeable.Counter;
  using SafeMathUpgradeable for uint256;

  CountersUpgradeable.Counter private _tokenIdCounter;

  function __ERC1155Lazy_init_unchained() internal onlyInitializing {}

  mapping(address => bool) private defaultApprovals;

  event DefaultApproval(address indexed operator, bool hasApproval);

  function _setDefaultApproval(address operator, bool hasApproval) internal {
    defaultApprovals[operator] = hasApproval;
    emit DefaultApproval(operator, hasApproval);
  }

  function isApprovedForAll(address _owner, address _operator)
    public
    view
    virtual
    override(IERC1155Upgradeable, MiranaERC1155Upgradeable)
    returns (bool)
  {
    return
      defaultApprovals[_operator] || super.isApprovedForAll(_owner, _operator);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(
      IERC165Upgradeable,
      ERC165StorageUpgradeable,
      MiranaERC1155Upgradeable
    )
    returns (bool)
  {
    return
      interfaceId == LibERC1155LazyMint._INTERFACE_ID_MINT_AND_TRANSFER ||
      interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES ||
      interfaceId == _INTERFACE_ID_ERC165 ||
      interfaceId == _INTERFACE_ID_ERC1155 ||
      interfaceId == _INTERFACE_ID_ERC1155_METADATA_URI;
  }

  function transferFromOrMint(
    LibERC1155LazyMint.Mint1155Data memory data,
    address from,
    address to,
    uint256 amount
  ) external override {
    uint256 balance = balanceOf(from, data.tokenId);
    uint256 left = amount;
    if (balance != 0) {
      uint256 transfer = amount;
      if (balance < amount) {
        transfer = balance;
      }
      safeTransferFrom(from, to, data.tokenId, transfer, "");
      left = amount - transfer;
    }
    if (left > 0) {
      mintAndTransfer(data, to, left);
    }
  }

  function mintAndTransfer(
    LibERC1155LazyMint.Mint1155Data memory data,
    address to,
    uint256 _amount
  ) public virtual override {
    address minter = data.creators[0].account;
    address sender = _msgSender();

    require(
      minter == sender || isApprovedForAll(minter, sender),
      "ERC1155: transfer caller is not approved"
    );
    require(_amount > 0, "amount incorrect");

    if (supply[data.tokenId] == 0) {
      require(data.creators.length == data.signatures.length);

      bytes32 hash = LibERC1155LazyMint.hash(data);
      for (uint256 i = 0; i < data.creators.length; i++) {
        address creator = data.creators[i].account;
        if (creator != sender) {
          validate(creator, hash, data.signatures[i]);
        }
      }

      _saveSupply(data.tokenId, data.supply);
      _saveRoyalties(data.tokenId, data.royalties);
      _saveCreators(data.tokenId, data.creators);
      super._setURI(data.tokenURI);
    }

    if (balanceOf(to, data.tokenId) == 0) {
      _listHolder[data.tokenId].push(to);
    }

    _mint(to, data.tokenId, _amount, "");
    _totalSupply++;
    if (minter != to) {
      emit Transfer(sender, address(0), minter, data.tokenId, _amount);
      emit Transfer(sender, minter, to, data.tokenId, _amount);
    } else {
      emit Transfer(sender, address(0), to, data.tokenId, _amount);
    }
  }

  function mintNewId(address recipient, uint256 amount) external onlyOwner {
    _tokenIdCounter.increment();
    _mint(recipient, _tokenIdCounter.current(), amount, "");
    _totalSupply++;
    _listHolder[_tokenIdCounter.current()].push(recipient);
    emit Transfer(
      _msgSender(),
      address(0),
      recipient,
      _tokenIdCounter.current(),
      amount
    );
  }

  function mintOldId(
    address recipient,
    uint256 oldId,
    uint256 amount
  ) external onlyOwner {
    if (balanceOf(recipient, oldId) == 0) {
      _listHolder[oldId].push(recipient);
    }
    _mint(recipient, oldId, amount, "");
    emit Transfer(
      _msgSender(),
      address(0),
      recipient,
      _tokenIdCounter.current(),
      amount
    );
  }

  //burn
  function burn(
    address account,
    uint256 tokenId,
    uint256 amount
  ) public virtual override {
    super.burn(account, tokenId, amount);
    _totalSupply--;

    if (balanceOf(account, tokenId) == 0) {
      for (uint256 index = 0; index < _listHolder[tokenId].length; index++) {
        if (_listHolder[tokenId][index] == account) {
          delete _listHolder[tokenId][index];
        }
      }
    }
  }

  /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual override(IERC1155Upgradeable, MiranaERC1155Upgradeable) {
    if (balanceOf(to, id) == 0) {
      _listHolder[id].push(to);
    }
    super.safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev See {IERC1155-safeBatchTransferFrom}.
   */
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual override(IERC1155Upgradeable, MiranaERC1155Upgradeable) {
    for (uint256 i = 0; i < ids.length; ++i) {
      if (balanceOf(to, ids[i]) == 0) {
        _listHolder[ids[i]].push(to);
      }
    }
    super.safeBatchTransferFrom(from, to, ids, amounts, data);
  }

  /**
   * Generate URI by id.
   */
  function uri(uint256 _tokenId) public view override returns (string memory) {
    return
      string(
        abi.encodePacked(
          baseMetadataURI,
          StringsUpgradeable.toString(_tokenId),
          ".json"
        )
      );
  }

  /**
   * Generate list holder of token
   */
  function getListHolderOfToken(uint256 tokenId)
    public
    view
    returns (DataHolder[] memory)
  {
    DataHolder[] memory _listDataHolder = new DataHolder[](
      _listHolder[tokenId].length
    );
    for (uint256 index = 0; index < _listHolder[tokenId].length; index++) {
      uint256 amount = balanceOf(_listHolder[tokenId][index], tokenId);
      DataHolder memory data = DataHolder({
        addr: _listHolder[tokenId][index],
        item: amount
      });
      _listDataHolder[index] = data;
    }
    return _listDataHolder;
  }

  /**
   * totalSupply
   */
  function totalSupply() external view virtual returns (uint256) {
    return _totalSupply;
  }

  function _saveSupply(uint256 tokenId, uint256 _supply) internal {
    require(supply[tokenId] == 0);
    supply[tokenId] = _supply;
    emit Supply(tokenId, _supply);
  }

  function _saveCreators(uint256 tokenId, LibPart.Part[] memory _creators)
    internal
  {
    LibPart.Part[] storage creatorsOfToken = creators[tokenId];
    uint256 total = 0;
    for (uint256 i = 0; i < _creators.length; i++) {
      require(
        _creators[i].account != address(0x0),
        "Account should be present"
      );
      require(_creators[i].value != 0, "Creator share should be positive");
      creatorsOfToken.push(_creators[i]);
      total = total.add(_creators[i].value);
    }
    require(total == 10000, "total amount of creators share should be 10000");
    emit Creators(tokenId, _creators);
  }

  function updateAccount(
    uint256 _id,
    address _from,
    address _to
  ) external {
    require(_msgSender() == _from, "not allowed");
    super._updateAccount(_id, _from, _to);
  }

  function getCreators(uint256 _id)
    external
    view
    returns (LibPart.Part[] memory)
  {
    return creators[_id];
  }

  function _getSupply(uint256 tokenId) internal view returns (uint256) {
    return supply[tokenId];
  }

  function tokenURI(uint256 id) external view virtual returns (string memory) {
    return _tokenURI(id);
  }

  function baseURI() public view virtual returns (string memory) {
    return baseMetadataURI;
  }

  function checkPrefix(string memory base, string memory tokenURI_)
    internal
    pure
    returns (string memory)
  {
    bytes memory whatBytes = bytes(base);
    bytes memory whereBytes = bytes(tokenURI_);

    if (whatBytes.length > whereBytes.length) {
      return string(abi.encodePacked(base, tokenURI_));
    }

    for (uint256 j = 0; j < whatBytes.length; j++) {
      if (whereBytes[j] != whatBytes[j]) {
        return string(abi.encodePacked(base, tokenURI_));
      }
    }

    return tokenURI_;
  }

  function _tokenURI(uint256 tokenId)
    internal
    view
    virtual
    returns (string memory)
  {
    string memory tokenURI_ = _tokenURIs[tokenId];
    string memory base = baseURI();

    // If there is no base URI, return the token URI.
    if (bytes(base).length == 0) {
      return tokenURI_;
    }
    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    if (bytes(tokenURI_).length > 0) {
      return checkPrefix(base, tokenURI_);
    }
    // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
    return string(abi.encodePacked(base, StringsUpgradeable.toString(tokenId)));
  }

  /**
   * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function _setTokenURI(uint256 tokenId, string memory _uri) internal virtual {
    _tokenURIs[tokenId] = _uri;
    emit URI(_tokenURI(tokenId), tokenId);
  }

  /**
   * @notice Will update the base URL of token's URI
   * @param _newBaseMetadataURI New base URL of token's URI
   */
  function setBaseMetadataURI(string memory _newBaseMetadataURI)
    public
    onlyOwner
  {
    baseMetadataURI = _newBaseMetadataURI;
    _setURI(baseMetadataURI);
  }

  uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/IERC1155MetadataURIUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract MiranaERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event Transfer(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit Transfer(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit Transfer(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "./MiranaERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract MiranaERC1155BurnableUpgradeable is Initializable, MiranaERC1155Upgradeable {
    function __ERC1155Burnable_init() internal onlyInitializing {
    }

    function __ERC1155Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165StorageUpgradeable.sol";
import "../../royalties/contracts/LibRoyaltiesV2.sol";
import "../../royalties/contracts/RoyaltiesV2.sol";

abstract contract RoyaltiesV2Upgradeable is ERC165StorageUpgradeable, RoyaltiesV2 {
    function __RoyaltiesV2Upgradeable_init_unchained() internal initializer {
        _registerInterface(LibRoyaltiesV2._INTERFACE_ID_ROYALTIES);
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Storage.sol)

pragma solidity ^0.8.0;

import "./ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Storage based implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165StorageUpgradeable is Initializable, ERC165Upgradeable {
    function __ERC165Storage_init() internal onlyInitializing {
    }

    function __ERC165Storage_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract MinimalMiranaERC721 is
  Initializable,
  ERC721Upgradeable,
  ERC721BurnableUpgradeable,
  OwnableUpgradeable
{
  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIdCounter;

  string private _baseTokenURI;
  uint256 private _totalSupply;

  event MiranaERC721Created(address owner, string name, string symbol);

  function initialize(
    string memory _name,
    string memory _symbol,
    string memory baseTokenURI
  ) public initializer {
    _baseTokenURI = baseTokenURI;
    __ERC721_init(_name, _symbol);
    __ERC721Burnable_init();
    __Ownable_init();
    emit MiranaERC721Created(_msgSender(), _name, _symbol);
  }

  function mint(address recipient) external {
    _tokenIdCounter.increment();
    _mint(recipient, _tokenIdCounter.current());
    _totalSupply++;
  }

  function burn(uint256 tokenId) public virtual override {
    super.burn(tokenId);
    _totalSupply--;
  }

  function setTokenURI(string memory uri) external onlyOwner {
    _baseTokenURI = uri;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function totalSupply() external view virtual returns (uint256) {
    return _totalSupply;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(
          abi.encodePacked(
            baseURI,
            StringsUpgradeable.toString(tokenId),
            ".json"
          )
        )
        : "";
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal onlyInitializing {
    }

    function __ERC721Burnable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155Upgradeable.sol";
import "./IERC1155ReceiverUpgradeable.sol";
import "./extensions/IERC1155MetadataURIUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155BurnableUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Burnable_init() internal onlyInitializing {
    }

    function __ERC1155Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract MiranaERC1155 is
  Initializable,
  ERC1155Upgradeable,
  ERC1155BurnableUpgradeable,
  OwnableUpgradeable
{
  // Contract name
  string public name;
  // Contract symbol
  string public symbol;
  // Base Metadata URI
  string public baseMetadataURI;

  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIdCounter;

  uint256 private _totalSupply;
  mapping(uint256 => address[]) public _listHolder;

  event MiranaERC1155Created(address owner, string name, string symbol);

  function initialize(
    string memory _name,
    string memory _symbol,
    string memory _baseTokenURI
  ) public initializer {
    name = _name;
    symbol = _symbol;
    baseMetadataURI = _baseTokenURI;
    __ERC1155_init("");
    __ERC1155Burnable_init();
    __Ownable_init();
    emit MiranaERC1155Created(_msgSender(), _name, _symbol);
  }

  function mintNewId(address recipient, uint256 amount) external onlyOwner {
    _tokenIdCounter.increment();
    _mint(recipient, _tokenIdCounter.current(), amount, "");
    _totalSupply++;
    _listHolder[_tokenIdCounter.current()].push(recipient);
  }

  function mintOldId(
    address recipient,
    uint256 oldId,
    uint256 amount
  ) external onlyOwner {
    if (balanceOf(recipient, oldId) == 0) {
      _listHolder[oldId].push(recipient);
    }
    _mint(recipient, oldId, amount, "");
  }

  //burn
  function burn(
    address account,
    uint256 tokenId,
    uint256 amount
  ) public virtual override {
    super.burn(account, tokenId, amount);
    _totalSupply--;

    if (balanceOf(account, tokenId) == 0) {
      for (uint256 index = 0; index < _listHolder[tokenId].length; index++) {
        if (_listHolder[tokenId][index] == account) {
          delete _listHolder[tokenId][index];
        }
      }
    }
  }

  /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual override {
    if (balanceOf(to, id) == 0) {
      _listHolder[id].push(to);
    }
    super.safeTransferFrom(from, to, id, amount, data);
  }

  /**
   * @dev See {IERC1155-safeBatchTransferFrom}.
   */
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual override {
    for (uint256 i = 0; i < ids.length; ++i) {
      if (balanceOf(to, ids[i]) == 0) {
        _listHolder[ids[i]].push(to);
      }
    }
    super.safeBatchTransferFrom(from, to, ids, amounts, data);
  }

  /**
   * Generate URI by id.
   */
  function uri(uint256 _tokenId) public view override returns (string memory) {
    return
      string(
        abi.encodePacked(
          baseMetadataURI,
          StringsUpgradeable.toString(_tokenId),
          ".json"
        )
      );
  }

  /**
   * totalSupply
   */
  function totalSupply() external view virtual returns (uint256) {
    return _totalSupply;
  }

  /**
   * Generate list holder of token
   */
  function getListHolderOfToken(uint256 tokenId)
    external
    view
    virtual
    returns (address[] memory)
  {
    return _listHolder[tokenId];
  }

  /**
   * @notice Will update the base URL of token's URI
   * @param _newBaseMetadataURI New base URL of token's URI
   */
  function setBaseMetadataURI(string memory _newBaseMetadataURI)
    external
    onlyOwner
  {
    baseMetadataURI = _newBaseMetadataURI;
    _setURI(baseMetadataURI);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./MiranaERC1155.sol";
import "./MiranaBaseCollection.sol";

/**
 * @dev This contract is for creating proxy to access ERC1155Rarible token.
 *
 * The beacon should be initialized before call ERC1155RaribleFactoryC2 constructor.
 *
 */
contract MiranaERC1155Collection is MiranaBaseCollection {
  address public beacon;

  event CollectionCreated(
    uint256 _id,
    string logoImage,
    string tokenType,
    string tokenName,
    string tokenSymbol,
    address proxyAddress,
    address owner
  );

  constructor(address _beacon) {
    beacon = _beacon;
  }

  function createCollection(
    string memory logoImage,
    string memory tokenType,
    string memory tokenName,
    string memory tokenSymbol,
    string memory baseTokenURI,
    uint256 salt
  ) public override {
    require(
      keccak256(abi.encodePacked((logoImage))) !=
        keccak256(abi.encodePacked((""))),
      "logoImage is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenName))) !=
        keccak256(abi.encodePacked((""))),
      "tokenName is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenSymbol))) !=
        keccak256(abi.encodePacked((""))),
      "tokenSymbol is requried"
    );
    require(
      (keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("Single"))) ||
        keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("")))),
      "tokenType is Single"
    );

    address beaconProxy = deployProxy(beacon, _getData(tokenName, tokenSymbol, baseTokenURI), salt);
    MiranaERC1155 token = MiranaERC1155(address(beaconProxy));
    token.transferOwnership(_msgSender());

    uint256 _id = block.timestamp;
    Collection memory collection = Collection({
      _id: _id,
      logoImage: logoImage,
      tokenType: tokenType,
      tokenName: tokenName,
      tokenSymbol: tokenSymbol,
      proxyAddress: beaconProxy,
      owner: _msgSender()
    });
    userCollections[_msgSender()].push(collection);
    collections.push(collection);

    emit CollectionCreated(
      _id,
      logoImage,
      tokenType,
      tokenName,
      tokenSymbol,
      beaconProxy,
      _msgSender()
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./interfaces/ICollection.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev This contract is for creating proxy to access ERC721Rarible token.
 *
 * The beacon should be initialized before call ERC721RaribleFactoryC2 constructor.
 *
 */
abstract contract MiranaBaseCollection is ICollection, Ownable {
  mapping(address => Collection[]) public userCollections;
  Collection[] public collections;

  //deploying BeaconProxy contract with create2
  function deployProxy(
    address beacon,
    bytes memory data,
    uint256 salt
  ) internal returns (address proxy) {
    bytes memory bytecode = getCreationBytecode(beacon, data);
    require(bytecode.length != 0, "Create2: bytecode length is zero");
    assembly {
      proxy := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
    }
    require(proxy != address(0), "Create2: Failed on deploy");
  }

  //adding constructor arguments to BeaconProxy bytecode
  function getCreationBytecode(address beacon, bytes memory _data)
    internal
    pure
    returns (bytes memory)
  {
    return
      abi.encodePacked(
        type(BeaconProxy).creationCode,
        abi.encode(beacon, _data)
      );
  }

  //returns address that contract with such arguments will be deployed on
  function getAddress(
    address beacon,
    string memory _name,
    string memory _symbol,
    string memory _baseTokenURI,
    uint256 _salt
  ) public view returns (address proxy) {
    bytes memory bytecode = getCreationBytecode(
      beacon,
      _getData(_name, _symbol, _baseTokenURI)
    );

    bytes32 hash = keccak256(
      abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
    );

    return address(uint160(uint256(hash)));
  }

  function _getData(
    string memory _name,
    string memory _symbol,
    string memory _baseTokenURI
  ) internal pure returns (bytes memory) {
    return
      abi.encodeWithSignature(
        "initialize(string,string,string)",
        _name,
        _symbol,
        _baseTokenURI
      );
  }

  function getCollection(address addr, uint256 _id)
    public
    view
    override
    returns (Collection memory, uint256 index)
  {
    for (index = 0; index < userCollections[addr].length; index++) {
      if (userCollections[addr][index]._id == _id) {
        return (userCollections[addr][index], index);
      }
    }
    return (userCollections[addr][userCollections[addr].length], index);
  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollection {
  struct Collection {
    uint256 _id;
    string logoImage;
    string tokenType;
    string tokenName;
    string tokenSymbol;
    address proxyAddress;
    address owner;
  }

  function getCollection(address addr, uint256 _id)
    external
    view
    returns (Collection memory, uint256 index);

  function createCollection(
    string memory logoImage,
    string memory tokenType,
    string memory tokenName,
    string memory tokenSymbol,
    string memory baseTokenURI,
    uint256 salt
  ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./MiranaERC721.sol";
import "./MiranaBaseCollection.sol";

/**
 * @dev This contract is for creating proxy to access ERC721Rarible token.
 *
 * The beacon should be initialized before call ERC721RaribleFactoryC2 constructor.
 *
 */
contract MiranaERC721Collection is MiranaBaseCollection {
  address public beacon;

  event CollectionCreated(
    uint256 _id,
    string logoImage,
    string tokenType,
    string tokenName,
    string tokenSymbol,
    address proxyAddress,
    address owner
  );

  constructor(address _beacon) {
    beacon = _beacon;
  }

  function createCollection(
    string memory logoImage,
    string memory tokenType,
    string memory tokenName,
    string memory tokenSymbol,
    string memory baseTokenURI,
    uint256 salt
  ) public override {
    require(
      keccak256(abi.encodePacked((logoImage))) !=
        keccak256(abi.encodePacked((""))),
      "logoImage is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenName))) !=
        keccak256(abi.encodePacked((""))),
      "tokenName is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenSymbol))) !=
        keccak256(abi.encodePacked((""))),
      "tokenSymbol is requried"
    );
    require(
      (keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("Single"))) ||
        keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("")))),
      "tokenType is Single"
    );

    address beaconProxy = deployProxy(beacon, _getData(tokenName, tokenSymbol, baseTokenURI), salt);
    MiranaERC721 token = MiranaERC721(address(beaconProxy));
    token.transferOwnership(_msgSender());

    uint256 _id = block.timestamp;
    Collection memory collection = Collection({
      _id: _id,
      logoImage: logoImage,
      tokenType: tokenType,
      tokenName: tokenName,
      tokenSymbol: tokenSymbol,
      proxyAddress: beaconProxy,
      owner: _msgSender()
    });
    userCollections[_msgSender()].push(collection);
    collections.push(collection);

    emit CollectionCreated(
      _id,
      logoImage,
      tokenType,
      tokenName,
      tokenSymbol,
      beaconProxy,
      _msgSender()
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract MiranaERC721 is
  Initializable,
  ERC721Upgradeable,
  ERC721BurnableUpgradeable,
  OwnableUpgradeable
{
  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIdCounter;

  string private _baseTokenURI;
  uint256 private _totalSupply;

  event MiranaERC721Created(address owner, string name, string symbol);

  function initialize(
    string memory _name,
    string memory _symbol,
    string memory baseTokenURI
  ) public initializer {
    _baseTokenURI = baseTokenURI;
    __ERC721_init(_name, _symbol);
    __ERC721Burnable_init();
    __Ownable_init();
    emit MiranaERC721Created(_msgSender(), _name, _symbol);
  }

  function mint(address recipient) external onlyOwner {
    _tokenIdCounter.increment();
    _mint(recipient, _tokenIdCounter.current());
    _totalSupply++;
  }

  function burn(uint256 tokenId) public virtual override {
    super.burn(tokenId);
    _totalSupply--;
  }

  function setTokenURI(string memory uri) external onlyOwner {
    _baseTokenURI = uri;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function totalSupply() external view virtual returns (uint256) {
    return _totalSupply;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(
          abi.encodePacked(
            baseURI,
            StringsUpgradeable.toString(tokenId),
            ".json"
          )
        )
        : "";
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';


contract AcceptedTokenList is Ownable {
  using EnumerableSet for EnumerableSet.AddressSet;

  struct MinPriorityFee {
    uint128 sellOrderMinFee;
    uint128 buyOrderMinFee;
  }
  EnumerableSet.AddressSet internal acceptedTokens;
  // min priority fee per second for each token, to prevent spamming
  mapping (address => MinPriorityFee) internal minPriorityFeeData;

  event TokensAdded(address[] _tokens);
  event TokensRemoved(address[] _tokens);

  constructor() {}

  function addAcceptedTokens(
    address[] memory _tokens,
    uint128[] memory _minPriorityFeeSell,
    uint128[] memory _minPriorityFeeBuy
  )
    public onlyOwner
  {
    require(
      _tokens.length == _minPriorityFeeSell.length && _tokens.length == _minPriorityFeeBuy.length,
      'invalid lengths'
    );
    for (uint256 i = 0; i < _tokens.length; i++) {
      acceptedTokens.add(_tokens[i]);
      minPriorityFeeData[_tokens[i]] = MinPriorityFee({
        sellOrderMinFee: _minPriorityFeeSell[i],
        buyOrderMinFee: _minPriorityFeeBuy[i]
      });
    }
    emit TokensAdded(_tokens);
  }

  function removeAcceptedTokens(address[] calldata _tokens) public onlyOwner {
    for (uint256 i = 0; i < _tokens.length; i++) {
      acceptedTokens.remove(_tokens[i]);
      delete minPriorityFeeData[_tokens[i]];
    }
    emit TokensRemoved(_tokens);
  }

  function isTokenAccepted(address _token) public view returns (bool) {
    return acceptedTokens.contains(_token);
  }

  function numberAcceptedTokens() public view returns (uint256) {
    return acceptedTokens.length();
  }

  function acceptedTokenAt(uint256 i) public view returns (address) {
    return acceptedTokens.at(i);
  }

  function getAllAcceptedTokens() public view returns (address[] memory _tokens) {
    _tokens = new address[](acceptedTokens.length());
    for (uint256 i = 0; i < _tokens.length; i++) {
      _tokens[i] = acceptedTokens.at(i);
    }
  }

  function getMinPriorityFeeData(address _token) public view returns (MinPriorityFee memory) {
    return minPriorityFeeData[_token];
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';


contract Operators is Ownable {
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet internal operators;

  event OperatorsAdded(address[] _operators);
  event OperatorsRemoved(address[] _operators);

  constructor() {}

  function addOperators(address[] calldata _operators) public onlyOwner {
    for (uint256 i = 0; i < _operators.length; i++) {
      operators.add(_operators[i]);
    }
    emit OperatorsAdded(_operators);
  }

  function removeOperators(address[] calldata _operators) public onlyOwner {
    for (uint256 i = 0; i < _operators.length; i++) {
      operators.remove(_operators[i]);
    }
    emit OperatorsRemoved(_operators);
  }

  function isOperator(address _operator) public view returns (bool) {
    return operators.contains(_operator);
  }

  function numberOperators() public view returns (uint256) {
    return operators.length();
  }

  function operatorAt(uint256 i) public view returns (address) {
    return operators.at(i);
  }

  function getAllOperators() public view returns (address[] memory _operators) {
    _operators = new address[](operators.length());
    for (uint256 i = 0; i < _operators.length; i++) {
      _operators[i] = operators.at(i);
    }
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import {IMiranaMarketBase} from "./interfaces/IMiranaMarketBase.sol";
import {IFeeCalculator} from "./interfaces/IFeeCalculator.sol";

import {EnumerableSet, Operators} from "../../../utils/Operators.sol";
import {AcceptedTokenList} from "../../../utils/AcceptedTokenList.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract MiranaMarketBase is
  IMiranaMarketBase,
  AcceptedTokenList,
  Operators,
  ReentrancyGuard
{
  using EnumerableSet for EnumerableSet.UintSet;
  using SafeERC20 for IERC20;

  uint64 private constant ONE_HUNDRED_PERCENT = 10000;
  uint64 private constant MIN_ORDER_DURATION = 5 minutes;

  uint256 public override numberOrders;

  mapping(uint256 => Order) internal orders;
  // user => token => order ids
  mapping(address => mapping(address => EnumerableSet.UintSet))
    internal userOrderIds;

  FeeConfig internal feeConfig;

  event SetFeeConfig(address indexed feeCalculator, uint64 baseFeePercent);
  event OrderCreated(
    address indexed creator,
    address indexed acceptedToken,
    address indexed nftToken,
    uint256 tokenId,
    uint64 quantities,
    uint128 targetPrice,
    uint128 baseFeePercent,
    uint128 priorityFee,
    uint64 createdTime,
    uint64 expiredTime,
    bool isSelling
  );

  event OrderCancelled(uint256 orderId, address caller);

  event OrderTaken(
    uint256 indexed orderId,
    address indexed seller,
    address indexed buyer,
    uint32 quantities,
    uint32 remainingQuantities,
    uint256 totalPrice,
    uint256 totalFees
  );

  /**
   * @param _feeHolder the fee holder for the platform, can not be 0x0
   * @param _feeCalculator fee calculator contract to help calculate base fee, can be 0x0
   * @param _baseFeePercent base fee percent to be used if feeCalculator is 0x0
   * @param _acceptedTokens list accepted tokens to use for buy/sell, must be ERC20
   * @param _minPriorityFeeSell min priority fee per second for sell order
   * @param _minPriorityFeeBuy min priority fee per second for buy order
   */
  constructor(
    address _feeHolder,
    address _feeCalculator,
    uint64 _baseFeePercent,
    address[] memory _acceptedTokens,
    uint128[] memory _minPriorityFeeSell,
    uint128[] memory _minPriorityFeeBuy
  ) {
    setFeeConfig(_feeHolder, _feeCalculator, _baseFeePercent);
    addAcceptedTokens(_acceptedTokens, _minPriorityFeeSell, _minPriorityFeeBuy);
  }

  receive() external payable {}

  function ownerWithdraw(
    address token,
    uint256 amount,
    address payable recipient
  ) external onlyOwner {
    _transferToken(token, recipient, amount);
  }

  /**
   * @dev Create/Update a buy/sell order
   * @param acceptedToken the token that user wants to use to buy or sell to, only ERC20
   * @param nftToken token that the creator wants to buy/sell
   * @param tokenId id of token that the creator wants to buy/sell
   * @param quantities number of tokens that the creator initially wants to buy/sell
   * @param targetPrice target price that the creator wants to buy/sell
   * @param priorityFee fee that the creator willings to pay on top of base fee
   * @param duration duration that the order is valid since the created time
   */
  function createOrder(
    uint256 orderId,
    address acceptedToken,
    address nftToken,
    uint256 tokenId,
    uint32 quantities,
    uint128 targetPrice,
    uint128 priorityFee,
    uint64 duration,
    bool isSelling
  ) external payable override {
    {
      require(quantities > 0, "quantities 0");
      require(
        isTokenAccepted(acceptedToken),
        "acceptedToken is not whitelisted"
      );
      require(targetPrice > 0, "invalid target price");
      require(duration >= MIN_ORDER_DURATION, "low order duration");
      if (isSelling) {
        require(
          hasValidOwnership(msg.sender, nftToken, tokenId, quantities),
          "insufficient balance"
        );
        require(
          priorityFee / duration >=
            getMinPriorityFeeData(acceptedToken).sellOrderMinFee,
          "priority is low"
        );
      } else {
        require(
          acceptedToken != address(0),
          "not support native token for buying"
        );
        require(
          IERC20(acceptedToken).balanceOf(msg.sender) >=
            targetPrice * quantities,
          "insufficient balance"
        );
        require(
          priorityFee / duration >=
            getMinPriorityFeeData(acceptedToken).buyOrderMinFee,
          "priority is low"
        );
      }
    }

    if (orderId == 0) {
      orderId = ++numberOrders;
    }
    uint64 currentTime = _getBlockTimestamp();
    uint64 baseFeePercent = uint64(
      getBaseFeePercent(
        msg.sender,
        acceptedToken,
        nftToken,
        tokenId,
        targetPrice,
        isSelling
      )
    );

    orders[orderId] = Order({
      creator: msg.sender,
      acceptedToken: acceptedToken,
      nftToken: nftToken,
      tokenId: tokenId,
      targetPrice: targetPrice,
      baseFeePercent: baseFeePercent,
      priorityFee: priorityFee,
      quantities: quantities,
      remainingQuantities: quantities,
      createdTime: currentTime,
      expiredTime: currentTime + duration,
      isSelling: isSelling
    });
    userOrderIds[msg.sender][nftToken].add(orderId);

    {
      // collect priority fees
      if (acceptedToken == address(0)) {
        require(msg.value == priorityFee, "invalid value for priority fee");
      } else {
        IERC20(acceptedToken).safeTransferFrom(
          msg.sender,
          address(this),
          priorityFee
        );
      }
    }

    emit OrderCreated(
      msg.sender,
      acceptedToken,
      nftToken,
      tokenId,
      quantities,
      targetPrice,
      baseFeePercent,
      priorityFee,
      currentTime,
      currentTime + duration,
      isSelling
    );
  }

  /**
   * @dev Cancel an existing order, can be called by the creator or an operator
   * @param orderId id of the order to be cancelled
   */
  function cancelOrder(uint256 orderId) external override nonReentrant {
    address creator = orders[orderId].creator;
    require(creator == msg.sender || isOperator(msg.sender), "not authorized");
    require(orders[orderId].remainingQuantities > 0, "already sold all");

    uint128 totalFee = orders[orderId].priorityFee;
    uint128 refundFee = _getRefundFees(
      orders[orderId].createdTime,
      orders[orderId].expiredTime,
      totalFee
    );

    address acceptedToken = orders[orderId].acceptedToken;
    // transfer refund fee to sender
    _transferToken(acceptedToken, creator, refundFee);
    // transfer remaining fee to the fee holder
    _transferToken(acceptedToken, feeConfig.feeHolder, totalFee - refundFee);

    userOrderIds[creator][orders[orderId].nftToken].remove(orderId);
    delete orders[orderId];

    emit OrderCancelled(orderId, msg.sender);
  }

  /**
   * @dev Take an order, can take partial order
   * @param orderId id of the order to take
   * @param quantities amount of tokens to take, must be <= the remaining quantities
   */
  function takeOrder(uint256 orderId, uint32 quantities)
    external
    payable
    override
    nonReentrant
  {
    Order memory order = orders[orderId];

    require(order.creator != address(0), "order not found");
    require(order.creator != msg.sender, "can not take your order");
    require(quantities > 0, "quantities 0");
    require(order.remainingQuantities >= quantities, "quantities too high");
    require(order.expiredTime >= _getBlockTimestamp(), "order expired");

    orders[orderId].remainingQuantities -= quantities;

    address acceptedToken = order.acceptedToken;

    uint256 totalPrice = order.targetPrice * quantities;
    if (order.isSelling) {
      if (acceptedToken == address(0)) {
        require(msg.value == totalPrice, "invalid msg value for buying");
      } else {
        IERC20(acceptedToken).safeTransferFrom(
          msg.sender,
          address(this),
          totalPrice
        );
      }
    } else {
      require(acceptedToken != address(0));
      IERC20(acceptedToken).safeTransferFrom(
        order.creator,
        address(this),
        totalPrice
      );
    }

    uint256 totalFees = (totalPrice * order.baseFeePercent) /
      ONE_HUNDRED_PERCENT;
    totalPrice -= totalFees;

    // avoid using check sellOrders[orderId].remainingQuantities == 0
    if (order.remainingQuantities == quantities) {
      // sold all quantities, check if should refund
      uint128 refundFee = _getRefundFees(
        order.createdTime,
        order.expiredTime,
        order.priorityFee
      );
      totalFees += order.priorityFee - refundFee;
      totalPrice += refundFee;
      // remove sell order from list
      userOrderIds[order.creator][order.nftToken].remove(orderId);
    }

    // transfer fees to the feeHolder
    _transferToken(acceptedToken, feeConfig.feeHolder, totalFees);

    // transfer acceptedToken to the seller, transfer nft to the buyer
    if (order.isSelling) {
      // creator is the seller, sender is the buyer
      _transferToken(acceptedToken, order.creator, totalPrice);
      makeTransfer(
        order.creator,
        msg.sender,
        order.nftToken,
        order.tokenId,
        quantities
      );
    } else {
      // creator is the buyer, sender is the seller
      _transferToken(acceptedToken, msg.sender, totalPrice);
      makeTransfer(
        msg.sender,
        order.creator,
        order.nftToken,
        order.tokenId,
        quantities
      );
    }

    emit OrderTaken(
      orderId,
      order.isSelling ? order.creator : msg.sender,
      order.isSelling ? msg.sender : order.creator,
      quantities,
      order.remainingQuantities - quantities,
      totalPrice,
      totalFees
    );
  }

  /**
   * @dev Get all information of an order
   */
  function getOrder(uint256 orderId)
    external
    view
    override
    returns (Order memory)
  {
    return orders[orderId];
  }

  /**
   * @dev Get all information of a list of orders in range
   */
  function getOrderInRange(uint256 startIndex, uint256 endIndex)
    external
    view
    override
    returns (Order[] memory _orders)
  {
    _orders = new Order[](endIndex - startIndex + 1);
    for (uint256 i = startIndex; i <= endIndex; i++) {
      _orders[i - startIndex] = orders[i];
    }
  }

  /**
   * @dev Set fee configuration, only called by the owner
   */
  function setFeeConfig(
    address _feeHolder,
    address _feeCalculator,
    uint64 _baseFeePercent
  ) public onlyOwner {
    require(_feeHolder != address(0), "invalid fee holder");
    feeConfig.feeHolder = _feeHolder;
    feeConfig.feeCalculator = _feeCalculator;
    feeConfig.baseFeePercent = _baseFeePercent;
    emit SetFeeConfig(_feeCalculator, _baseFeePercent);
  }

  /**
   * @dev Return the base fee percent for an order
   */
  function getBaseFeePercent(
    address user,
    address acceptedToken,
    address nftToken,
    uint256 tokenId,
    uint128 targetPrice,
    bool isSelling
  ) public view returns (uint64 baseFeePercent) {
    FeeConfig memory config = feeConfig;
    baseFeePercent = (config.feeCalculator == address(0))
      ? config.baseFeePercent
      : IFeeCalculator(config.feeCalculator).calculateBaseFeePercent(
        user,
        acceptedToken,
        nftToken,
        tokenId,
        targetPrice,
        isSelling
      );
  }

  function _transferToken(
    address token,
    address recipient,
    uint256 amount
  ) internal {
    if (token == address(0)) {
      (bool success, ) = payable(recipient).call{value: amount}("");
      require(success, "transfer native token failed");
    } else {
      IERC20(token).safeTransfer(recipient, amount);
    }
  }

  function _getRefundFees(
    uint64 _createdTime,
    uint64 _expiredTime,
    uint128 _priorityFee
  ) internal view returns (uint128 refundFee) {
    uint64 currentTime = _getBlockTimestamp();
    if (currentTime < _expiredTime) {
      refundFee =
        (_priorityFee * (_expiredTime - currentTime)) /
        (_expiredTime - _createdTime);
    }
  }

  /**
   * @dev Function to transfer NFT
   */
  function makeTransfer(
    address _from,
    address _to,
    address _token,
    uint256 _tokenId,
    uint256 _value
  ) internal virtual;

  function hasValidOwnership(
    address _user,
    address _token,
    uint256 _tokenId,
    uint64 _quantities
  ) internal view virtual returns (bool);

  function _getBlockTimestamp() internal view virtual returns (uint64) {
    return uint64(block.timestamp);
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMiranaMarketBase {
  /**
   * @dev Data for an Order
   * @param creator the Order's creator
   * @param acceptedToken the token that user wants to use to buy or sell to, only ERC20
   * @param nftToken nft token that the creator wants to buy/sell
   * @param tokenId id of token that the creator wants to buy/sell
   * @param targetPrice target price that the creator wants to buy/sell
   * @param priorityFee fee that the creator willings to pay on top of base fee
   * @param quantities number of tokens that the creator initially wants to buy/sell
   * @param remainingQuantities remaining quantities that can buy/sell
   * @param baseFeePercent base fee percent for the order, will be charge for each token
   * @param createdTime time that the order is created
   * @param expiredTime time that the order is no longer valid
   * @param isSelling whether it is sell or buy order
   */
  struct Order {
    address creator;
    address acceptedToken;
    address nftToken;
    uint256 tokenId;
    uint128 targetPrice;
    uint128 priorityFee;
    uint32 quantities;
    uint32 remainingQuantities;
    uint64 baseFeePercent;
    uint64 createdTime;
    uint64 expiredTime;
    bool isSelling;
  }

  /**
   * @dev If feeCalculator != address(0), use it to calculate base fee, otherwise use baseFeePercent
   */
  struct FeeConfig {
    address feeCalculator;
    address feeHolder;
    uint64 baseFeePercent;
  }

  /**
   * @dev Create/Update a new buy/sell order
   * @param acceptedToken the token that user wants to use to buy or sell to, only ERC20
   * @param nftToken nft token that the creator wants to buy/sell
   * @param quantities number of tokens that the creator initially wants to buy/sell
   * @param tokenId id of token that the creator wants to buy/sell
   * @param targetPrice target price that the creator wants to buy/sell
   * @param priorityFee fee that the creator willings to pay on top of base fee
   * @param duration duration that the order is valid since the created time
   * @param isSelling whether it is sell or buy order
   */
  function createOrder(
    uint256 orderId,
    address acceptedToken,
    address nftToken,
    uint256 tokenId,
    uint32 quantities,
    uint128 targetPrice,
    uint128 priorityFee,
    uint64 duration,
    bool isSelling
  ) external payable;

  /**
   * @dev Cancel an existing order, can be called by the creator or an operator
   * @param orderId id of the order to be cancelled
   */
  function cancelOrder(uint256 orderId) external;

  /**
   * @dev Take an order, can take partial order
   * @param orderId id of the order to take
   * @param quantities amount of tokens to take, must be <= the remaining quantities
   */
  function takeOrder(uint256 orderId, uint32 quantities) external payable;

  /**
   * @dev Get all information of an order
   */
  function getOrder(uint256 orderId) external view returns (Order memory);

  /**
   * @dev Get all information of a list of orders in range
   */
  function getOrderInRange(uint256 startIndex, uint256 endIndex)
    external
    view
    returns (Order[] memory _orders);

  /**
   * @dev Number created orders so far, including cancelled ones
   */
  function numberOrders() external view returns (uint256);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;


interface IFeeCalculator {
  /**
   * @dev Calculate the base fee percent for user when creating an order/offer
   * @param user address of the user who is making the order/offer
   * @param acceptedToken the token that user wants to use to buy or sell to, only ERC20
   * @param nftToken nft token that user is interacting with
   * @param tokenId id of the token
   * @param price price that user wants to buy/sell
   * @param isSelling whether it is buy or sell
   */
  function calculateBaseFeePercent(
    address user,
    address acceptedToken,
    address nftToken,
    uint256 tokenId,
    uint256 price,
    bool isSelling
  ) external view returns (uint64 baseFeePercent);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import {MiranaMarketBase} from './MiranaMarketBase.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IERC721 {
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function ownerOf(uint256 tokenId) external view returns (address owner);
}


contract MiranaMarketERC721 is MiranaMarketBase {

  constructor(
    address _feeHolder,
    address _feeCalculator,
    uint64 _baseFeePercent,
    address[] memory _acceptedTokens,
    uint128[] memory _minPriorityFeeSell,
    uint128[] memory _minPriorityFeeBuy
  )
    MiranaMarketBase(
      _feeHolder,
      _feeCalculator,
      _baseFeePercent,
      _acceptedTokens,
      _minPriorityFeeSell,
      _minPriorityFeeBuy
    ) {}

  function makeTransfer(
    address _from,
    address _to,
    address _token,
    uint256 _tokenId,
    uint256 _value
  )
    internal override
  {
    require(_value == 1, 'invalid value for ERC721 token');
    IERC721(_token).safeTransferFrom(_from, _to, _tokenId);
  }

  function hasValidOwnership(
    address _user,
    address _token,
    uint256 _tokenId,
    uint64 _quantities
  ) internal view override returns (bool)
  {
    if (_quantities > 1) return false;
    // Note: it could revert here if _tokenId does not exist
    if (IERC721(_token).ownerOf(_tokenId) == _user) return true;
    return false;
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import {MiranaMarketBase} from './MiranaMarketBase.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IERC1155 {
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) external;

  function balanceOf(address account, uint256 id) external view returns (uint256);
}


contract MiranaMarketERC1155 is MiranaMarketBase {

  constructor(
    address _feeHolder,
    address _feeCalculator,
    uint64 _baseFeePercent,
    address[] memory _acceptedTokens,
    uint128[] memory _minPriorityFeeSell,
    uint128[] memory _minPriorityFeeBuy
  )
    MiranaMarketBase(
      _feeHolder,
      _feeCalculator,
      _baseFeePercent,
      _acceptedTokens,
      _minPriorityFeeSell,
      _minPriorityFeeBuy
    ) {}

  function makeTransfer(
    address _from,
    address _to,
    address _token,
    uint256 _tokenId,
    uint256 _value
  )
    internal override
  {
    IERC1155(_token).safeTransferFrom(_from, _to, _tokenId, _value, '');
  }

  function hasValidOwnership(
    address _user,
    address _token,
    uint256 _tokenId,
    uint64 _quantities
  ) internal view override returns (bool)
  {
    return IERC1155(_token).balanceOf(_user, _tokenId) >= _quantities;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract TestBeaconProxy is BeaconProxy{
     constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) {
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/UpgradeableBeacon.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../../access/Ownable.sol";
import "../../utils/Address.sol";

/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
     * beacon.
     */
    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newImplementation` must be a contract.
     */
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract TestBeacon is UpgradeableBeacon {
    constructor(address impl) UpgradeableBeacon(impl) {

    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract MiranaERC721Beacon is UpgradeableBeacon {
    constructor(address impl) UpgradeableBeacon(impl) {

    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract MiranaERC1155Beacon is UpgradeableBeacon {
    constructor(address impl) UpgradeableBeacon(impl) {

    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../token/MiranaERC721V1.sol";
import "./interfaces/ICollection.sol";

contract MiranaCollection is ICollection, Ownable {
  mapping(address => Collection[]) public userCollections;
  Collection[] public collections;

  event CollectionCreated(
    uint256 _id,
    string logoImage,
    string tokenType,
    string tokenName,
    string tokenSymbol,
    address erc721,
    address erc1155,
    address owner
  );

  event CollectionUpdated(
    uint256 _id,
    string tokenType,
    address erc721,
    address erc1155,
    address owner
  );

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(addr)
    }
    return size > 0;
  }

  function getCollection(address addr, uint256 _id)
    public
    view
    override
    returns (Collection memory, uint256 index)
  {
    for (index = 0; index < userCollections[addr].length; index++) {
      if (userCollections[addr][index]._id == _id) {
        return (userCollections[addr][index], index);
      }
    }
    return (userCollections[addr][userCollections[addr].length], index);
  }

  function createCollection(
    string memory logoImage,
    string memory tokenType,
    string memory tokenName,
    string memory tokenSymbol
  ) public override {
    require(!isContract(_msgSender()), "caller is not able contract");
    require(
      keccak256(abi.encodePacked((tokenName))) !=
        keccak256(abi.encodePacked((""))),
      "tokenName is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenSymbol))) !=
        keccak256(abi.encodePacked((""))),
      "tokenSymbol is requried"
    );
    require(
      (keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("Single"))) ||
        keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("")))),
      "tokenType is Single"
    );

    address owner = _msgSender();
    MiranaERC721V1 erc721;
    if (
      keccak256(abi.encodePacked((tokenType))) ==
      keccak256(abi.encodePacked(("Single")))
    ) {
      // erc721.initialize(tokenName, tokenSymbol, "");
      // erc721.transferOwnership(_msgSender());
    }

    uint256 _id = block.timestamp;
    Collection memory collection = Collection({
      _id: _id,
      logoImage: logoImage,
      tokenType: tokenType,
      tokenName: tokenName,
      tokenSymbol: tokenSymbol,
      erc721: address(erc721),
      erc1155: address(0),
      owner: owner
    });
    userCollections[owner].push(collection);
    collections.push(collection);

    emit CollectionCreated(
      _id,
      logoImage,
      tokenType,
      tokenName,
      tokenSymbol,
      address(erc721),
      address(0),
      owner
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ERC721LazyMinimal.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MiranaERC721V1 is Initializable, ERC721LazyMinimal {
  event MiranaERC721Created(address owner, string name, string symbol);

  function initialize(
    string memory _name,
    string memory _symbol,
    string memory baseTokenURI,
    address transferProxy,
    address lazyTransferProxy
  ) public initializer {
    __Ownable_init();
    __ERC721_init(_name, _symbol);
    __ERC721Enumerable_init();
    __ERC721URIStorage_init();
    __ERC721Burnable_init();
    __ERC721Lazy_init_unchained();
    __Mint721Validator_init_unchained();
    // __RoyaltiesV2Upgradeable_init_unchained();
    __Context_init_unchained();
    __ERC165_init_unchained();
    setBaseTokenURI(baseTokenURI);
    _setDefaultApproval(transferProxy, true);
    _setDefaultApproval(lazyTransferProxy, true);
    emit MiranaERC721Created(_msgSender(), _name, _symbol);
  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollection {
  struct Collection {
    uint256 _id;
    string logoImage;
    string tokenType;
    string tokenName;
    string tokenSymbol;
    address erc721;
    address erc1155;
    address owner;
  }

  function getCollection(address addr, uint256 _id)
    external
    view
    returns (Collection memory, uint256 index);

  function createCollection(
    string memory logoImage,
    string memory tokenType,
    string memory tokenName,
    string memory tokenSymbol
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./validator/MintERC721Validator.sol";
import "../rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "../rarible/lazy-mint/contracts/erc-721/IERC721LazyMint.sol";
import "../rarible/royalties-upgradeable/contracts/RoyaltiesV2Upgradeable.sol";
import "./erc721/MiranaERC721Upgradeable.sol";
import "./erc721/MiranaERC721EnumerableUpgradeable.sol";
import "./erc721/MiranaERC721URIStorageUpgradeable.sol";
import "./erc721/MiranaERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract ERC721LazyMinimal is
  IERC721LazyMint,
  MiranaERC721Upgradeable,
  MiranaERC721EnumerableUpgradeable,
  MiranaERC721URIStorageUpgradeable,
  MiranaERC721BurnableUpgradeable,
  MintERC721Validator,
  RoyaltiesV2Upgradeable,
  RoyaltiesV2Impl,
  OwnableUpgradeable
{
  using SafeMathUpgradeable for uint256;

  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
  bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
  bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

  // tokenId => creators
  mapping(uint256 => LibPart.Part[]) private creators;

  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIdCounter;

  string private _baseTokenURI;

  function __ERC721Lazy_init_unchained() internal onlyInitializing {}

  mapping(address => bool) private defaultApprovals;

  event DefaultApproval(address indexed operator, bool hasApproval);

  function _setDefaultApproval(address operator, bool hasApproval) internal {
    defaultApprovals[operator] = hasApproval;
    emit DefaultApproval(operator, hasApproval);
  }

  function setDefaultApproval(address operator, bool hasApproval)
    public
    onlyOwner
  {
    defaultApprovals[operator] = hasApproval;
    emit DefaultApproval(operator, hasApproval);
  }

  function _isApprovedOrOwner(address spender, uint256 tokenId)
    internal
    view
    virtual
    override
    returns (bool)
  {
    return
      defaultApprovals[spender] || super._isApprovedOrOwner(spender, tokenId);
  }

  function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override(IERC721Upgradeable, MiranaERC721Upgradeable)
    returns (bool)
  {
    return
      defaultApprovals[operator] || super.isApprovedForAll(owner, operator);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(
      IERC165Upgradeable,
      ERC165StorageUpgradeable,
      MiranaERC721Upgradeable,
      MiranaERC721EnumerableUpgradeable
    )
    returns (bool)
  {
    return
      interfaceId == LibERC721LazyMint._INTERFACE_ID_MINT_AND_TRANSFER ||
      interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES ||
      interfaceId == _INTERFACE_ID_ERC165 ||
      interfaceId == _INTERFACE_ID_ERC721 ||
      interfaceId == _INTERFACE_ID_ERC721_METADATA ||
      interfaceId == _INTERFACE_ID_ERC721_ENUMERABLE;
  }

  function transferFromOrMint(
    LibERC721LazyMint.Mint721Data memory data,
    address from,
    address to
  ) external override {
    if (_exists(data.tokenId)) {
      safeTransferFrom(from, to, data.tokenId);
    } else {
      mintAndTransfer(data, to);
    }
  }

  function mintAndTransfer(
    LibERC721LazyMint.Mint721Data memory data,
    address to
  ) public virtual override {
    address minter = data.creators[0].account;
    address sender = _msgSender();

    require(data.creators.length == data.signatures.length);
    require(
      minter == sender || isApprovedForAll(minter, sender),
      "ERC721: transfer caller is not owner nor approved"
    );

    bytes32 hash = LibERC721LazyMint.hash(data);
    for (uint256 i = 0; i < data.creators.length; i++) {
      address creator = data.creators[i].account;
      if (creator != sender) {
        validate(creator, hash, data.signatures[i]);
      }
    }

    _safeMint(to, data.tokenId);
    if (minter != to) {
      emit Transfer(address(0), minter, data.tokenId);
      emit Transfer(minter, to, data.tokenId);
    } else {
      emit Transfer(address(0), to, data.tokenId);
    }
    _saveRoyalties(data.tokenId, data.royalties);
    _saveCreators(data.tokenId, data.creators);
    _setTokenURI(data.tokenId, data.tokenURI);
  }

  function _saveCreators(uint256 tokenId, LibPart.Part[] memory _creators)
    internal
  {
    LibPart.Part[] storage creatorsOfToken = creators[tokenId];
    uint256 total = 0;
    for (uint256 i = 0; i < _creators.length; i++) {
      require(
        _creators[i].account != address(0x0),
        "Account should be present"
      );
      require(_creators[i].value != 0, "Creator share should be positive");
      creatorsOfToken.push(_creators[i]);
      total = total.add(_creators[i].value);
    }
    require(total == 10000, "total amount of creators share should be 10000");
    emit Creators(tokenId, _creators);
  }

  function updateAccount(
    uint256 _id,
    address _from,
    address _to
  ) external {
    require(_msgSender() == _from, "not allowed");
    super._updateAccount(_id, _from, _to);
  }

  function getCreators(uint256 _id)
    external
    view
    returns (LibPart.Part[] memory)
  {
    return creators[_id];
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  )
    internal
    override(MiranaERC721Upgradeable, MiranaERC721EnumerableUpgradeable)
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(MiranaERC721Upgradeable, MiranaERC721URIStorageUpgradeable)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function mint(address recipient) external {
    _tokenIdCounter.increment();
    _mint(recipient, _tokenIdCounter.current());
    emit Transfer(address(0), recipient, _tokenIdCounter.current());
  }

  function mint(address recipient, string memory uri) external {
    _tokenIdCounter.increment();
    _safeMint(recipient, _tokenIdCounter.current());
    _setTokenURI(_tokenIdCounter.current(), uri);
    emit Transfer(address(0), recipient, _tokenIdCounter.current());
  }

  function _burn(uint256 tokenId)
    internal
    override(MiranaERC721Upgradeable, MiranaERC721URIStorageUpgradeable)
  {
    super._burn(tokenId);
  }

  function setBaseTokenURI(string memory uri) public onlyOwner {
    _baseTokenURI = uri;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function getTokenURI(uint256 tokenId) public view returns (string memory) {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(
          abi.encodePacked(
            baseURI,
            StringsUpgradeable.toString(tokenId),
            ".json"
          )
        )
        : "";
  }

  uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract MiranaERC721Upgradeable is
  Initializable,
  ContextUpgradeable,
  ERC165Upgradeable,
  IERC721Upgradeable,
  IERC721MetadataUpgradeable
{
  using AddressUpgradeable for address;
  using StringsUpgradeable for uint256;

  // Token name
  string private _name;

  // Token symbol
  string private _symbol;

  // Mapping from token ID to owner address
  mapping(uint256 => address) private _owners;

  // Mapping owner address to token count
  mapping(address => uint256) private _balances;

  // Mapping from token ID to approved address
  mapping(uint256 => address) private _tokenApprovals;

  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) private _operatorApprovals;

  /**
   * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
   */
  function __ERC721_init(string memory name_, string memory symbol_)
    internal
    onlyInitializing
  {
    __ERC721_init_unchained(name_, symbol_);
  }

  function __ERC721_init_unchained(string memory name_, string memory symbol_)
    internal
    onlyInitializing
  {
    _name = name_;
    _symbol = symbol_;
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165Upgradeable, IERC165Upgradeable)
    returns (bool)
  {
    return
      interfaceId == type(IERC721Upgradeable).interfaceId ||
      interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC721-balanceOf}.
   */
  function balanceOf(address owner)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return _balances[owner];
  }

  /**
   * @dev See {IERC721-ownerOf}.
   */
  function ownerOf(uint256 tokenId)
    public
    view
    virtual
    override
    returns (address)
  {
    address owner = _owners[tokenId];
    require(owner != address(0), "ERC721: owner query for nonexistent token");
    return owner;
  }

  /**
   * @dev See {IERC721Metadata-name}.
   */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev See {IERC721Metadata-symbol}.
   */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
  }

  /**
   * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
   * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
   * by default, can be overriden in child contracts.
   */
  function _baseURI() internal view virtual returns (string memory) {
    return "";
  }

  /**
   * @dev See {IERC721-approve}.
   */
  function approve(address to, uint256 tokenId) public virtual override {
    address owner = MiranaERC721Upgradeable.ownerOf(tokenId);
    require(to != owner, "ERC721: approval to current owner");

    require(
      _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
      "ERC721: approve caller is not owner nor approved for all"
    );

    _approve(to, tokenId);
  }

  /**
   * @dev See {IERC721-getApproved}.
   */
  function getApproved(uint256 tokenId)
    public
    view
    virtual
    override
    returns (address)
  {
    require(_exists(tokenId), "ERC721: approved query for nonexistent token");

    return _tokenApprovals[tokenId];
  }

  /**
   * @dev See {IERC721-setApprovalForAll}.
   */
  function setApprovalForAll(address operator, bool approved)
    public
    virtual
    override
  {
    _setApprovalForAll(_msgSender(), operator, approved);
  }

  /**
   * @dev See {IERC721-isApprovedForAll}.
   */
  function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }

  /**
   * @dev See {IERC721-transferFrom}.
   */
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    //solhint-disable-next-line max-line-length
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );

    _transfer(from, to, tokenId);
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    safeTransferFrom(from, to, tokenId, "");
  }

  /**
   * @dev See {IERC721-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public virtual override {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );
    _safeTransfer(from, to, tokenId, _data);
  }

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   *
   * `_data` is additional data, it has no specified format and it is sent in call to `to`.
   *
   * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
   * implement alternative mechanisms to perform token transfer, such as signature-based.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function _safeTransfer(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) internal virtual {
    _transfer(from, to, tokenId);
    require(
      _checkOnERC721Received(from, to, tokenId, _data),
      "ERC721: transfer to non ERC721Receiver implementer"
    );
  }

  /**
   * @dev Returns whether `tokenId` exists.
   *
   * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
   *
   * Tokens start existing when they are minted (`_mint`),
   * and stop existing when they are burned (`_burn`).
   */
  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return _owners[tokenId] != address(0);
  }

  /**
   * @dev Returns whether `spender` is allowed to manage `tokenId`.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function _isApprovedOrOwner(address spender, uint256 tokenId)
    internal
    view
    virtual
    returns (bool)
  {
    require(_exists(tokenId), "ERC721: operator query for nonexistent token");
    address owner = MiranaERC721Upgradeable.ownerOf(tokenId);
    return (spender == owner ||
      getApproved(tokenId) == spender ||
      isApprovedForAll(owner, spender));
  }

  /**
   * @dev Safely mints `tokenId` and transfers it to `to`.
   *
   * Requirements:
   *
   * - `tokenId` must not exist.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function _safeMint(address to, uint256 tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }

  /**
   * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
   * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
   */
  function _safeMint(
    address to,
    uint256 tokenId,
    bytes memory _data
  ) internal virtual {
    _mint(to, tokenId);
    require(
      _checkOnERC721Received(address(0), to, tokenId, _data),
      "ERC721: transfer to non ERC721Receiver implementer"
    );
  }

  /**
   * @dev Mints `tokenId` and transfers it to `to`.
   *
   * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
   *
   * Requirements:
   *
   * - `tokenId` must not exist.
   * - `to` cannot be the zero address.
   *
   * Emits a {Transfer} event.
   */
  function _mint(address to, uint256 tokenId) internal virtual {
    require(to != address(0), "ERC721: mint to the zero address");
    require(!_exists(tokenId), "ERC721: token already minted");

    _beforeTokenTransfer(address(0), to, tokenId);

    _balances[to] += 1;
    _owners[tokenId] = to;

    _afterTokenTransfer(address(0), to, tokenId);
  }

  /**
   * @dev Destroys `tokenId`.
   * The approval is cleared when the token is burned.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   *
   * Emits a {Transfer} event.
   */
  function _burn(uint256 tokenId) internal virtual {
    address owner = MiranaERC721Upgradeable.ownerOf(tokenId);

    _beforeTokenTransfer(owner, address(0), tokenId);

    // Clear approvals
    _approve(address(0), tokenId);

    _balances[owner] -= 1;
    delete _owners[tokenId];

    emit Transfer(owner, address(0), tokenId);

    _afterTokenTransfer(owner, address(0), tokenId);
  }

  /**
   * @dev Transfers `tokenId` from `from` to `to`.
   *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - `tokenId` token must be owned by `from`.
   *
   * Emits a {Transfer} event.
   */
  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {
    require(
      MiranaERC721Upgradeable.ownerOf(tokenId) == from,
      "ERC721: transfer from incorrect owner"
    );
    require(to != address(0), "ERC721: transfer to the zero address");

    _beforeTokenTransfer(from, to, tokenId);

    // Clear approvals from the previous owner
    _approve(address(0), tokenId);

    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);

    _afterTokenTransfer(from, to, tokenId);
  }

  /**
   * @dev Approve `to` to operate on `tokenId`
   *
   * Emits a {Approval} event.
   */
  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(MiranaERC721Upgradeable.ownerOf(tokenId), to, tokenId);
  }

  /**
   * @dev Approve `operator` to operate on all of `owner` tokens
   *
   * Emits a {ApprovalForAll} event.
   */
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC721: approve to caller");
    _operatorApprovals[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /**
   * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
   * The call is not executed if the target address is not a contract.
   *
   * @param from address representing the previous owner of the given token ID
   * @param to target address that will receive the tokens
   * @param tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return bool whether the call correctly returned the expected magic value
   */
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) private returns (bool) {
    if (to.isContract()) {
      try
        IERC721ReceiverUpgradeable(to).onERC721Received(
          _msgSender(),
          from,
          tokenId,
          _data
        )
      returns (bytes4 retval) {
        return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721: transfer to non ERC721Receiver implementer");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }

  /**
   * @dev Hook that is called before any token transfer. This includes minting
   * and burning.
   *
   * Calling conditions:
   *
   * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
   * transferred to `to`.
   * - When `from` is zero, `tokenId` will be minted for `to`.
   * - When `to` is zero, ``from``'s `tokenId` will be burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}

  /**
   * @dev Hook that is called after any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "./MiranaERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract MiranaERC721EnumerableUpgradeable is
  Initializable,
  MiranaERC721Upgradeable,
  IERC721EnumerableUpgradeable
{
  function __ERC721Enumerable_init() internal onlyInitializing {}

  function __ERC721Enumerable_init_unchained() internal onlyInitializing {}

  // Mapping from owner to list of owned token IDs
  mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) private _ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] private _allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) private _allTokensIndex;

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165Upgradeable, MiranaERC721Upgradeable)
    returns (bool)
  {
    return
      interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
   */
  function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(
      index < MiranaERC721Upgradeable.balanceOf(owner),
      "ERC721Enumerable: owner index out of bounds"
    );
    return _ownedTokens[owner][index];
  }

  /**
   * @dev See {IERC721Enumerable-totalSupply}.
   */
  function totalSupply() public view virtual override returns (uint256) {
    return _allTokens.length;
  }

  /**
   * @dev See {IERC721Enumerable-tokenByIndex}.
   */
  function tokenByIndex(uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(
      index < MiranaERC721EnumerableUpgradeable.totalSupply(),
      "ERC721Enumerable: global index out of bounds"
    );
    return _allTokens[index];
  }

  /**
   * @dev Hook that is called before any token transfer. This includes minting
   * and burning.
   *
   * Calling conditions:
   *
   * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
   * transferred to `to`.
   * - When `from` is zero, `tokenId` will be minted for `to`.
   * - When `to` is zero, ``from``'s `tokenId` will be burned.
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    if (from == address(0)) {
      _addTokenToAllTokensEnumeration(tokenId);
    } else if (from != to) {
      _removeTokenFromOwnerEnumeration(from, tokenId);
    }
    if (to == address(0)) {
      _removeTokenFromAllTokensEnumeration(tokenId);
    } else if (to != from) {
      _addTokenToOwnerEnumeration(to, tokenId);
    }
  }

  /**
   * @dev Private function to add a token to this extension's ownership-tracking data structures.
   * @param to address representing the new owner of the given token ID
   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
    uint256 length = MiranaERC721Upgradeable.balanceOf(to);
    _ownedTokens[to][length] = tokenId;
    _ownedTokensIndex[tokenId] = length;
  }

  /**
   * @dev Private function to add a token to this extension's token tracking data structures.
   * @param tokenId uint256 ID of the token to be added to the tokens list
   */
  function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }

  /**
   * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
   * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
   * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
   * This has O(1) time complexity, but alters the order of the _ownedTokens array.
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
    private
  {
    // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = MiranaERC721Upgradeable.balanceOf(from) - 1;
    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary
    if (tokenIndex != lastTokenIndex) {
      uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

      _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
      _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
    }

    // This also deletes the contents at the last position of the array
    delete _ownedTokensIndex[tokenId];
    delete _ownedTokens[from][lastTokenIndex];
  }

  /**
   * @dev Private function to remove a token from this extension's token tracking data structures.
   * This has O(1) time complexity, but alters the order of the _allTokens array.
   * @param tokenId uint256 ID of the token to be removed from the tokens list
   */
  function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
    // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = _allTokens.length - 1;
    uint256 tokenIndex = _allTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
    // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
    // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
    uint256 lastTokenId = _allTokens[lastTokenIndex];

    _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
    _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

    // This also deletes the contents at the last position of the array
    delete _allTokensIndex[tokenId];
    _allTokens.pop();
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "./MiranaERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract MiranaERC721URIStorageUpgradeable is
  Initializable,
  MiranaERC721Upgradeable
{
  function __ERC721URIStorage_init() internal onlyInitializing {}

  function __ERC721URIStorage_init_unchained() internal onlyInitializing {}

  using StringsUpgradeable for uint256;

  // Optional mapping for token URIs
  mapping(uint256 => string) private _tokenURIs;

  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721URIStorage: URI query for nonexistent token"
    );

    string memory _tokenURI = _tokenURIs[tokenId];
    string memory base = _baseURI();

    // If there is no base URI, return the token URI.
    if (bytes(base).length == 0) {
      return _tokenURI;
    }
    // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
    if (bytes(_tokenURI).length > 0) {
      return string(abi.encodePacked(base, _tokenURI));
    }

    return super.tokenURI(tokenId);
  }

  /**
   * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function _setTokenURI(uint256 tokenId, string memory _tokenURI)
    internal
    virtual
  {
    require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
  }

  /**
   * @dev Destroys `tokenId`.
   * The approval is cleared when the token is burned.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   *
   * Emits a {Transfer} event.
   */
  function _burn(uint256 tokenId) internal virtual override {
    super._burn(tokenId);

    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "./MiranaERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract MiranaERC721BurnableUpgradeable is
  Initializable,
  ContextUpgradeable,
  MiranaERC721Upgradeable
{
  function __ERC721Burnable_init() internal onlyInitializing {}

  function __ERC721Burnable_init_unchained() internal onlyInitializing {}

  /**
   * @dev Burns `tokenId`. See {ERC721-_burn}.
   *
   * Requirements:
   *
   * - The caller must own `tokenId` or be an approved operator.
   */
  function burn(uint256 tokenId) public virtual {
    //solhint-disable-next-line max-line-length
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721Burnable: caller is not owner nor approved"
    );
    _burn(tokenId);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../token/MiranaERC1155V1.sol";
import "./interfaces/ICollection.sol";

contract MiranaCollection is ICollection, Ownable {
  mapping(address => Collection[]) public userCollections;
  Collection[] public collections;

  event CollectionCreated(
    uint256 _id,
    string logoImage,
    string tokenType,
    string tokenName,
    string tokenSymbol,
    address erc721,
    address erc1155,
    address owner
  );

  event CollectionUpdated(
    uint256 _id,
    string tokenType,
    address erc721,
    address erc1155,
    address owner
  );

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(addr)
    }
    return size > 0;
  }

  function getCollection(address addr, uint256 _id)
    public
    view
    override
    returns (Collection memory, uint256 index)
  {
    for (index = 0; index < userCollections[addr].length; index++) {
      if (userCollections[addr][index]._id == _id) {
        return (userCollections[addr][index], index);
      }
    }
    return (userCollections[addr][userCollections[addr].length], index);
  }

  function createCollection(
    string memory logoImage,
    string memory tokenType,
    string memory tokenName,
    string memory tokenSymbol
  ) public override {
    require(!isContract(_msgSender()), "caller is not able contract");
    require(
      keccak256(abi.encodePacked((tokenName))) !=
        keccak256(abi.encodePacked((""))),
      "tokenName is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenSymbol))) !=
        keccak256(abi.encodePacked((""))),
      "tokenSymbol is requried"
    );
    require(
      (keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("Multiple"))) ||
        keccak256(abi.encodePacked((tokenType))) !=
        keccak256(abi.encodePacked(("")))),
      "tokenType is Single"
    );

    address owner = _msgSender();
    MiranaERC1155V1 erc1155;
    if (
      keccak256(abi.encodePacked((tokenType))) ==
      keccak256(abi.encodePacked(("Multiple")))
    ) {
      // erc1155.initialize(tokenName, tokenSymbol, "");
      // erc1155.transferOwnership(_msgSender());
    }

    uint256 _id = block.timestamp;
    Collection memory collection = Collection({
      _id: _id,
      logoImage: logoImage,
      tokenType: tokenType,
      tokenName: tokenName,
      tokenSymbol: tokenSymbol,
      erc721: address(0),
      erc1155: address(erc1155),
      owner: owner
    });
    userCollections[owner].push(collection);
    collections.push(collection);

    emit CollectionCreated(
      _id,
      logoImage,
      tokenType,
      tokenName,
      tokenSymbol,
      address(0),
      address(erc1155),
      owner
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ERC1155LazyMinimal.sol";

contract MiranaERC1155V1 is ERC1155LazyMinimal {
  event MiranaERC1155Created(address owner, string name, string symbol);

  function initialize(
    string memory _name,
    string memory _symbol,
    string memory baseTokenURI,
    address transferProxy,
    address lazyTransferProxy
  ) public initializer {
    __Ownable_init();
    __ERC1155_init(baseTokenURI);
    __ERC1155Burnable_init();
    __Mint1155Validator_init_unchained();
    __ERC1155Lazy_init_unchained();
    __RoyaltiesV2Upgradeable_init_unchained();
    __Context_init_unchained();
    __ERC165_init_unchained();

    _setDefaultApproval(transferProxy, true);
    _setDefaultApproval(lazyTransferProxy, true);

    name = _name;
    symbol = _symbol;

    emit MiranaERC1155Created(_msgSender(), _name, _symbol);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../token/MiranaERC1155V1.sol";
import "./MinimalMiranaBaseCollection.sol";

contract ERC1155MiranaCollection is Initializable, MinimalMiranaBaseCollection {
  function initialize(
    address _originAddress,
    address _transferProxy,
    address _lazyTransferProxy
  ) public initializer {
    originAddress = _originAddress;
    transferProxy = _transferProxy;
    lazyTransferProxy = _lazyTransferProxy;
    __Ownable_init();
  }

  function createCollection(
    string memory tokenName,
    string memory tokenSymbol,
    string memory baseTokenURI
  ) public {
    require(
      keccak256(abi.encodePacked((tokenName))) !=
        keccak256(abi.encodePacked((""))),
      "tokenName is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenSymbol))) !=
        keccak256(abi.encodePacked((""))),
      "tokenSymbol is requried"
    );

    address minimalAddress = cloneAddress(originAddress);

    require(minimalAddress != address(0), "clone is failed");

    MiranaERC1155V1 token = MiranaERC1155V1(minimalAddress);
    token.initialize(
      tokenName,
      tokenSymbol,
      baseTokenURI,
      transferProxy,
      lazyTransferProxy
    );
    token.transferOwnership(_msgSender());

    emit CollectionCreated(
      tokenName,
      tokenSymbol,
      minimalAddress,
      _msgSender()
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract MinimalMiranaBaseCollection is OwnableUpgradeable {
  address public originAddress;
  address public transferProxy;
  address public lazyTransferProxy;

  event CollectionCreated(
    string tokenName,
    string tokenSymbol,
    address minimalAddress,
    address owner
  );

  function cloneAddress(address target) internal returns (address addr) {
    // convert address to 20 bytes
    bytes20 targetBytes = bytes20(target);

    // actual code //
    // 3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3

    // creation code //
    // copy runtime code into memory and return it
    // 3d602d80600a3d3981f3

    // runtime code //
    // code to delegatecall to address
    // 363d3d373d3d3d363d73 address 5af43d82803e903d91602b57fd5bf3

    assembly {
      /*
            reads the 32 bytes of memory starting at pointer stored in 0x40

            In solidity, the 0x40 slot in memory is special: it contains the "free memory pointer"
            which points to the end of the currently allocated memory.
            */
      let clone := mload(0x40)
      // store 32 bytes to memory starting at "clone"
      mstore(
        clone,
        0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
      )

      /*
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      pointer
            */
      // store 32 bytes to memory starting at "clone" + 20 bytes
      // 0x14 = 20
      mstore(add(clone, 0x14), targetBytes)

      /*
              |               20 bytes               |                 20 bytes              |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              pointer
            */
      // store 32 bytes to memory starting at "clone" + 40 bytes
      // 0x28 = 40
      mstore(
        add(clone, 0x28),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )

      /*
              |               20 bytes               |                 20 bytes              |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
            */
      // create new contract
      // send 0 Ether
      // code starts at pointer stored in "clone"
      // code size 0x37 (55 bytes)
      addr := create(0, clone, 0x37)
    }
  }

  function setOriginAddress(address _originAddress) external onlyOwner {
    originAddress = _originAddress;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../token/MiranaERC721V1.sol";
import "./MinimalMiranaBaseCollection.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC721MiranaCollection is Initializable, MinimalMiranaBaseCollection {
  function initialize(
    address _originAddress,
    address _transferProxy,
    address _lazyTransferProxy
  ) public initializer {
    originAddress = _originAddress;
    transferProxy = _transferProxy;
    lazyTransferProxy = _lazyTransferProxy;
    __Ownable_init();
  }

  function createCollection(
    string memory tokenName,
    string memory tokenSymbol,
    string memory baseTokenURI
  ) public {
    require(
      keccak256(abi.encodePacked((tokenName))) !=
        keccak256(abi.encodePacked((""))),
      "tokenName is requried"
    );
    require(
      keccak256(abi.encodePacked((tokenSymbol))) !=
        keccak256(abi.encodePacked((""))),
      "tokenSymbol is requried"
    );

    address minimalAddress = cloneAddress(originAddress);

    require(minimalAddress != address(0), "clone is failed");

    MiranaERC721V1 token = MiranaERC721V1(minimalAddress);
    // token.initialize(
    //   tokenName,
    //   tokenSymbol,
    //   baseTokenURI,
    //   transferProxy,
    //   lazyTransferProxy
    // );
    // token.transferOwnership(_msgSender());

    emit CollectionCreated(
      tokenName,
      tokenSymbol,
      minimalAddress,
      _msgSender()
    );
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165StorageUpgradeable.sol";
import "../../royalties/contracts/LibRoyaltiesV1.sol";
import "../../royalties/contracts/RoyaltiesV1.sol";

abstract contract RoyaltiesV1Upgradeable is ERC165StorageUpgradeable, RoyaltiesV1 {
    function __RoyaltiesV1Upgradeable_init_unchained() internal initializer {
        _registerInterface(LibRoyaltiesV1._INTERFACE_ID_FEES);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./impl/RoyaltiesV1Impl.sol";

contract RoyaltiesV1TestImpl is RoyaltiesV1Impl {
  function saveRoyalties(uint256 id, LibPart.Part[] memory royalties) external {
    _saveRoyalties(id, royalties);
  }

  function updateAccount(
    uint256 id,
    address from,
    address to
  ) external {
    _updateAccount(id, from, to);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./impl/RoyaltiesV2Impl.sol";

contract RoyaltiesV2TestImpl is RoyaltiesV2Impl {
  function saveRoyalties(uint256 id, LibPart.Part[] memory royalties) external {
    _saveRoyalties(id, royalties);
  }

  function updateAccount(
    uint256 id,
    address from,
    address to
  ) external {
    _updateAccount(id, from, to);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./MiranaOrderBase.sol";
import "./RaribleTransferManager.sol";
import "../../rarible/royalties/contracts/IRoyaltiesProvider.sol";

contract MiranaOrder is ExchangeV2Core, RaribleTransferManager {
    function initialize(
        INftTransferProxy _transferProxy,
        IERC20TransferProxy _erc20TransferProxy,
        uint newProtocolFee,
        address newDefaultFeeReceiver,
        IRoyaltiesProvider newRoyaltiesProvider
    ) external initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __TransferExecutor_init_unchained(_transferProxy, _erc20TransferProxy);
        __RaribleTransferManager_init_unchained(newProtocolFee, newDefaultFeeReceiver, newRoyaltiesProvider);
        __OrderValidator_init_unchained();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../roles/OperatorRole.sol";
import "../../exchange-interfaces/contracts/IERC20TransferProxy.sol";

contract ERC20TransferProxy is IERC20TransferProxy, Initializable, OperatorRole {

    function __ERC20TransferProxy_init() external initializer {
        __Ownable_init();
    }

    function erc20safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) override external onlyOperator {
        require(token.transferFrom(from, to, value), "failure while transferring");
    }
}