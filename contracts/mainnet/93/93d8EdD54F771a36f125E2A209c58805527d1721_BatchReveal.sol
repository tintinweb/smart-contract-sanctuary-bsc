// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
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

//SPDX-License-Identifier: CC0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./chainlink/VRFConsumerBaseV2Upgradeable.sol";
import "./interfaces/IBatchReveal.sol";
import "./interfaces/IBaseLaunchpeg.sol";
import "./LaunchpegErrors.sol";

// Creator: Tubby Cats
/// https://github.com/tubby-cats/batch-nft-reveal

/// @title BatchReveal
/// @notice Implements a gas efficient way of revealing NFT URIs gradually
contract BatchReveal is
    IBatchReveal,
    VRFConsumerBaseV2Upgradeable,
    OwnableUpgradeable
{
    /// @notice Batch reveal configuration by launchpeg
    mapping(address => BatchRevealConfig) public override launchpegToConfig;

    /// @notice VRF request ids by launchpeg
    mapping(uint256 => address) public vrfRequestIdToLaunchpeg;

    /// @notice Randomized seeds used to shuffle TokenURIs by launchpeg
    mapping(address => mapping(uint256 => uint256))
        public
        override launchpegToBatchToSeed;

    /// @notice Last token that has been revealed by launchpeg
    mapping(address => uint256) public override launchpegToLastTokenReveal;

    /// @dev Size of the array that will store already taken URIs numbers by launchpeg
    mapping(address => uint256) public launchpegToRangeLength;

    /// @notice Contract uses VRF or pseudo-randomness
    bool public override useVRF;

    /// @notice Chainlink subscription ID
    uint64 public override subscriptionId;

    /// @notice The gas lane to use, which specifies the maximum gas price to bump to.
    /// For a list of available gas lanes on each network,
    /// see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 public override keyHash;

    /// @notice Depends on the number of requested values that you want sent to the
    /// fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    /// so 100,000 is a safe default for this example contract. Test and adjust
    /// this limit based on the network that you select, the size of the request,
    /// and the processing of the callback request in the fulfillRandomWords()
    /// function.
    uint32 public override callbackGasLimit;

    /// @notice Number of block confirmations that the coordinator will wait before triggering the callback
    /// The default is 3
    uint16 public constant override requestConfirmations = 3;

    /// @notice Next batch that will be revealed by VRF (if activated) by launchpeg
    mapping(address => uint256) public override launchpegToNextBatchToReveal;

    /// @notice True when force revealed has been triggered for the given launchpeg
    /// @dev VRF will not be used anymore if a batch has been force revealed
    mapping(address => bool) public override launchpegToHasBeenForceRevealed;

    /// @notice Has the random number for a batch already been asked by launchpeg
    /// @dev Prevents people from spamming the random words request
    /// and therefore reveal more batches than expected
    mapping(address => mapping(uint256 => bool))
        public
        override launchpegToVrfRequestedForBatch;

    struct Range {
        int128 start;
        int128 end;
    }

    /// @dev Emitted on revealNextBatch() and forceReveal()
    /// @param baseLaunchpeg Base launchpeg address
    /// @param batchNumber The batch revealed
    /// @param batchSeed The random number drawn
    event Reveal(address baseLaunchpeg, uint256 batchNumber, uint256 batchSeed);

    /// @dev Emitted on setRevealBatchSize()
    /// @param baseLaunchpeg Base launchpeg address
    /// @param revealBatchSize New reveal batch size
    event RevealBatchSizeSet(address baseLaunchpeg, uint256 revealBatchSize);

    /// @dev Emitted on setRevealStartTime()
    /// @param baseLaunchpeg Base launchpeg address
    /// @param revealStartTime New reveal start time
    event RevealStartTimeSet(address baseLaunchpeg, uint256 revealStartTime);

    /// @dev Emitted on setRevealInterval()
    /// @param baseLaunchpeg Base launchpeg address
    /// @param revealInterval New reveal interval
    event RevealIntervalSet(address baseLaunchpeg, uint256 revealInterval);

    /// @dev emitted on setVRF()
    /// @param _vrfCoordinator Chainlink coordinator address
    /// @param _keyHash Keyhash of the gas lane wanted
    /// @param _subscriptionId Chainlink subscription ID
    /// @param _callbackGasLimit Max gas used by the coordinator callback
    event VRFSet(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    );

    /// @dev Verify that batch reveal is configured for the given launchpeg
    modifier batchRevealInitialized(address _baseLaunchpeg) {
        if (!isBatchRevealInitialized(_baseLaunchpeg)) {
            revert Launchpeg__BatchRevealNotInitialized();
        }
        _;
    }

    /// @dev Verify that batch reveal hasn't started for the given launchpeg
    modifier revealNotStarted(address _baseLaunchpeg) {
        if (launchpegToLastTokenReveal[_baseLaunchpeg] != 0) {
            revert Launchpeg__BatchRevealStarted();
        }
        _;
    }

    /// @notice Initialize batch reveal
    function initialize() external override initializer {
        __Ownable_init();
    }

    /// @dev Configure batch reveal for a given launch
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _revealBatchSize Size of the batch reveal
    /// @param _revealStartTime Batch reveal start time
    /// @param _revealInterval Batch reveal interval
    function configure(
        address _baseLaunchpeg,
        uint256 _revealBatchSize,
        uint256 _revealStartTime,
        uint256 _revealInterval
    ) external override onlyOwner revealNotStarted(_baseLaunchpeg) {
        uint256 _collectionSize = IBaseLaunchpeg(_baseLaunchpeg)
            .collectionSize();
        launchpegToConfig[_baseLaunchpeg].collectionSize = _collectionSize;
        launchpegToConfig[_baseLaunchpeg].intCollectionSize = int128(
            int256(_collectionSize)
        );
        _setRevealBatchSize(_baseLaunchpeg, _revealBatchSize);
        _setRevealStartTime(_baseLaunchpeg, _revealStartTime);
        _setRevealInterval(_baseLaunchpeg, _revealInterval);
    }

    /// @notice Set the reveal batch size. Can only be set after
    /// batch reveal has been initialized and before a batch has
    /// been revealed.
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _revealBatchSize New reveal batch size
    function setRevealBatchSize(
        address _baseLaunchpeg,
        uint256 _revealBatchSize
    )
        public
        override
        onlyOwner
        batchRevealInitialized(_baseLaunchpeg)
        revealNotStarted(_baseLaunchpeg)
    {
        _setRevealBatchSize(_baseLaunchpeg, _revealBatchSize);
    }

    /// @notice Set the reveal batch size
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _revealBatchSize New reveal batch size
    function _setRevealBatchSize(
        address _baseLaunchpeg,
        uint256 _revealBatchSize
    ) internal {
        if (_revealBatchSize == 0) {
            revert Launchpeg__InvalidBatchRevealSize();
        }
        uint256 collectionSize = launchpegToConfig[_baseLaunchpeg]
            .collectionSize;
        if (
            collectionSize % _revealBatchSize != 0 ||
            _revealBatchSize > collectionSize
        ) {
            revert Launchpeg__InvalidBatchRevealSize();
        }
        launchpegToRangeLength[_baseLaunchpeg] =
            (collectionSize / _revealBatchSize) *
            2;
        launchpegToConfig[_baseLaunchpeg].revealBatchSize = _revealBatchSize;
        emit RevealBatchSizeSet(_baseLaunchpeg, _revealBatchSize);
    }

    /// @notice Set the batch reveal start time. Can only be set after
    /// batch reveal has been initialized and before a batch has
    /// been revealed.
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _revealStartTime New batch reveal start time
    function setRevealStartTime(
        address _baseLaunchpeg,
        uint256 _revealStartTime
    )
        public
        override
        onlyOwner
        batchRevealInitialized(_baseLaunchpeg)
        revealNotStarted(_baseLaunchpeg)
    {
        _setRevealStartTime(_baseLaunchpeg, _revealStartTime);
    }

    /// @notice Set the batch reveal start time.
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _revealStartTime New batch reveal start time
    function _setRevealStartTime(
        address _baseLaunchpeg,
        uint256 _revealStartTime
    ) internal {
        // probably a mistake if the reveal is more than 100 days in the future
        if (_revealStartTime > block.timestamp + 8_640_000) {
            revert Launchpeg__InvalidRevealDates();
        }
        launchpegToConfig[_baseLaunchpeg].revealStartTime = _revealStartTime;
        emit RevealStartTimeSet(_baseLaunchpeg, _revealStartTime);
    }

    /// @notice Set the batch reveal interval. Can only be set after
    /// batch reveal has been initialized and before a batch has
    /// been revealed.
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _revealInterval New batch reveal interval
    function setRevealInterval(address _baseLaunchpeg, uint256 _revealInterval)
        public
        override
        onlyOwner
        batchRevealInitialized(_baseLaunchpeg)
        revealNotStarted(_baseLaunchpeg)
    {
        _setRevealInterval(_baseLaunchpeg, _revealInterval);
    }

    /// @notice Set the batch reveal interval.
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _revealInterval New batch reveal interval
    function _setRevealInterval(address _baseLaunchpeg, uint256 _revealInterval)
        internal
    {
        // probably a mistake if reveal interval is longer than 10 days
        if (_revealInterval > 864_000) {
            revert Launchpeg__InvalidRevealDates();
        }
        launchpegToConfig[_baseLaunchpeg].revealInterval = _revealInterval;
        emit RevealIntervalSet(_baseLaunchpeg, _revealInterval);
    }

    /// @notice Set VRF configuration
    /// @param _vrfCoordinator Chainlink coordinator address
    /// @param _keyHash Keyhash of the gas lane wanted
    /// @param _subscriptionId Chainlink subscription ID
    /// @param _callbackGasLimit Max gas used by the coordinator callback
    function setVRF(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) external override onlyOwner {
        if (_vrfCoordinator == address(0)) {
            revert Launchpeg__InvalidCoordinator();
        }

        (
            ,
            uint32 _maxGasLimit,
            bytes32[] memory s_provingKeyHashes
        ) = VRFCoordinatorV2Interface(_vrfCoordinator).getRequestConfig();

        // 20_000 is the cost of storing one word, callback cost will never be lower than that
        if (_callbackGasLimit > _maxGasLimit || _callbackGasLimit < 20_000) {
            revert Launchpeg__InvalidCallbackGasLimit();
        }

        bool keyHashFound;
        for (uint256 i; i < s_provingKeyHashes.length; i++) {
            if (s_provingKeyHashes[i] == _keyHash) {
                keyHashFound = true;
                break;
            }
        }

        if (!keyHashFound) {
            revert Launchpeg__InvalidKeyHash();
        }

        (, , , address[] memory consumers) = VRFCoordinatorV2Interface(
            _vrfCoordinator
        ).getSubscription(_subscriptionId);

        bool isInConsumerList;
        for (uint256 i; i < consumers.length; i++) {
            if (consumers[i] == address(this)) {
                isInConsumerList = true;
                break;
            }
        }

        if (!isInConsumerList) {
            revert Launchpeg__IsNotInTheConsumerList();
        }

        useVRF = true;
        setVRFConsumer(_vrfCoordinator);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        callbackGasLimit = _callbackGasLimit;

        emit VRFSet(
            _vrfCoordinator,
            _keyHash,
            _subscriptionId,
            _callbackGasLimit
        );
    }

    // Forked from openzeppelin
    /// @dev Returns the smallest of two numbers.
    /// @param _a First number to consider
    /// @param _b Second number to consider
    /// @return min Minimum between the two params
    function _min(int128 _a, int128 _b) internal pure returns (int128) {
        return _a < _b ? _a : _b;
    }

    /// @notice Fills the range array
    /// @dev Ranges include the start but not the end [start, end)
    /// @param _ranges initial range array
    /// @param _start beginning of the array to be added
    /// @param _end end of the array to be added
    /// @param _lastIndex last position in the range array to consider
    /// @param _intCollectionSize collection size
    /// @return newLastIndex new lastIndex to consider for the future range to be added
    function _addRange(
        Range[] memory _ranges,
        int128 _start,
        int128 _end,
        uint256 _lastIndex,
        int128 _intCollectionSize
    ) private view returns (uint256) {
        uint256 positionToAssume = _lastIndex;
        for (uint256 j; j < _lastIndex; j++) {
            int128 rangeStart = _ranges[j].start;
            int128 rangeEnd = _ranges[j].end;
            if (_start < rangeStart && positionToAssume == _lastIndex) {
                positionToAssume = j;
            }
            if (
                (_start < rangeStart && _end > rangeStart) ||
                (rangeStart <= _start && _end <= rangeEnd) ||
                (_start < rangeEnd && _end > rangeEnd)
            ) {
                int128 length = _end - _start;
                _start = _min(_start, rangeStart);
                _end = _start + length + (rangeEnd - rangeStart);
                _ranges[j] = Range(-1, -1); // Delete
            }
        }
        for (uint256 pos = _lastIndex; pos > positionToAssume; pos--) {
            _ranges[pos] = _ranges[pos - 1];
        }
        _ranges[positionToAssume] = Range(
            _start,
            _min(_end, _intCollectionSize)
        );
        _lastIndex++;
        if (_end > _intCollectionSize) {
            _addRange(
                _ranges,
                0,
                _end - _intCollectionSize,
                _lastIndex,
                _intCollectionSize
            );
            _lastIndex++;
        }
        return _lastIndex;
    }

    /// @dev Adds the last batch into the ranges array
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _lastBatch Batch number to consider
    /// @param _revealBatchSize Reveal batch size
    /// @param _intCollectionSize Collection size
    /// @param _rangeLength Range length
    /// @return ranges Ranges array filled with every URI taken by batches smaller or equal to lastBatch
    function _buildJumps(
        address _baseLaunchpeg,
        uint256 _lastBatch,
        uint256 _revealBatchSize,
        int128 _intCollectionSize,
        uint256 _rangeLength
    ) private view returns (Range[] memory) {
        Range[] memory ranges = new Range[](_rangeLength);
        uint256 lastIndex;
        for (uint256 i; i < _lastBatch; i++) {
            int128 start = int128(
                int256(
                    _getFreeTokenId(
                        _baseLaunchpeg,
                        launchpegToBatchToSeed[_baseLaunchpeg][i],
                        ranges,
                        _intCollectionSize
                    )
                )
            );
            int128 end = start + int128(int256(_revealBatchSize));
            lastIndex = _addRange(
                ranges,
                start,
                end,
                lastIndex,
                _intCollectionSize
            );
        }
        return ranges;
    }

    /// @dev Gets the random token URI number from tokenId
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _startId Token Id to consider
    /// @return uriId Revealed Token URI Id
    function getShuffledTokenId(address _baseLaunchpeg, uint256 _startId)
        external
        view
        override
        returns (uint256)
    {
        int128 intCollectionSize = launchpegToConfig[_baseLaunchpeg]
            .intCollectionSize;
        uint256 revealBatchSize = launchpegToConfig[_baseLaunchpeg]
            .revealBatchSize;
        uint256 batch = _startId / revealBatchSize;
        Range[] memory ranges = new Range[](
            launchpegToRangeLength[_baseLaunchpeg]
        );

        ranges = _buildJumps(
            _baseLaunchpeg,
            batch,
            revealBatchSize,
            intCollectionSize,
            launchpegToRangeLength[_baseLaunchpeg]
        );

        uint256 positionsToMove = (_startId % revealBatchSize) +
            launchpegToBatchToSeed[_baseLaunchpeg][batch];

        return
            _getFreeTokenId(
                _baseLaunchpeg,
                positionsToMove,
                ranges,
                intCollectionSize
            );
    }

    /// @dev Gets the shifted URI number from tokenId and range array
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _positionsToMoveStart Token URI offset if none of the URI Ids were taken
    /// @param _ranges Ranges array built by _buildJumps()
    /// @param _intCollectionSize Collection size
    /// @return uriId Revealed Token URI Id
    function _getFreeTokenId(
        address _baseLaunchpeg,
        uint256 _positionsToMoveStart,
        Range[] memory _ranges,
        int128 _intCollectionSize
    ) private view returns (uint256) {
        int128 positionsToMove = int128(int256(_positionsToMoveStart));
        int128 id;

        for (uint256 round = 0; round < 2; round++) {
            for (uint256 i; i < launchpegToRangeLength[_baseLaunchpeg]; i++) {
                int128 start = _ranges[i].start;
                int128 end = _ranges[i].end;
                if (id < start) {
                    int128 finalId = id + positionsToMove;
                    if (finalId < start) {
                        return uint256(uint128(finalId));
                    } else {
                        positionsToMove -= start - id;
                        id = end;
                    }
                } else if (id < end) {
                    id = end;
                }
            }
            if ((id + positionsToMove) >= _intCollectionSize) {
                positionsToMove -= _intCollectionSize - id;
                id = 0;
            }
        }
        return uint256(uint128(id + positionsToMove));
    }

    /// @dev Sets batch seed for specified batch number
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _batchNumber Batch number that needs to be revealed
    /// @param _collectionSize Collection size
    /// @param _revealBatchSize Reveal batch size
    function _setBatchSeed(
        address _baseLaunchpeg,
        uint256 _batchNumber,
        uint256 _collectionSize,
        uint256 _revealBatchSize
    ) internal {
        uint256 randomness = uint256(
            keccak256(
                abi.encode(
                    msg.sender,
                    tx.gasprice,
                    block.number,
                    block.timestamp,
                    block.difficulty,
                    blockhash(block.number - 1),
                    address(this)
                )
            )
        );

        // not perfectly random since the folding doesn't match bounds perfectly, but difference is small
        launchpegToBatchToSeed[_baseLaunchpeg][_batchNumber] =
            randomness %
            (_collectionSize - (_batchNumber * _revealBatchSize));
    }

    /// @dev Returns true if a batch can be revealed
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _totalSupply Number of token already minted
    /// @return hasToRevealInfo Returns a bool saying whether a reveal can be triggered or not
    /// and the number of the next batch that will be revealed
    function hasBatchToReveal(address _baseLaunchpeg, uint256 _totalSupply)
        public
        view
        override
        returns (bool, uint256)
    {
        uint256 revealBatchSize = launchpegToConfig[_baseLaunchpeg]
            .revealBatchSize;
        uint256 revealStartTime = launchpegToConfig[_baseLaunchpeg]
            .revealStartTime;
        uint256 revealInterval = launchpegToConfig[_baseLaunchpeg]
            .revealInterval;
        uint256 lastTokenRevealed = launchpegToLastTokenReveal[_baseLaunchpeg];
        uint256 batchNumber;
        unchecked {
            batchNumber = lastTokenRevealed / revealBatchSize;
        }

        // We don't want to reveal other batches if a VRF random words request is pending
        if (
            block.timestamp < revealStartTime + batchNumber * revealInterval ||
            _totalSupply < lastTokenRevealed + revealBatchSize ||
            launchpegToVrfRequestedForBatch[_baseLaunchpeg][batchNumber]
        ) {
            return (false, batchNumber);
        }

        return (true, batchNumber);
    }

    /// @dev Reveals next batch if possible
    /// @dev If using VRF, the reveal happens on the coordinator callback call
    /// @param _baseLaunchpeg Base launchpeg address
    /// @param _totalSupply Number of token already minted
    /// @return isRevealed Returns false if it is not possible to reveal the next batch
    function revealNextBatch(address _baseLaunchpeg, uint256 _totalSupply)
        external
        override
        returns (bool)
    {
        if (_baseLaunchpeg != msg.sender) {
            revert Launchpeg__Unauthorized();
        }

        uint256 batchNumber;
        bool canReveal;
        (canReveal, batchNumber) = hasBatchToReveal(
            _baseLaunchpeg,
            _totalSupply
        );

        if (!canReveal) {
            return false;
        }

        if (useVRF) {
            uint256 requestId = VRFCoordinatorV2Interface(vrfCoordinator)
                .requestRandomWords(
                    keyHash,
                    subscriptionId,
                    requestConfirmations,
                    callbackGasLimit,
                    1
                );
            vrfRequestIdToLaunchpeg[requestId] = _baseLaunchpeg;
            launchpegToVrfRequestedForBatch[_baseLaunchpeg][batchNumber] = true;
        } else {
            launchpegToLastTokenReveal[_baseLaunchpeg] += launchpegToConfig[
                _baseLaunchpeg
            ].revealBatchSize;
            _setBatchSeed(
                _baseLaunchpeg,
                batchNumber,
                launchpegToConfig[_baseLaunchpeg].collectionSize,
                launchpegToConfig[_baseLaunchpeg].revealBatchSize
            );
            emit Reveal(
                _baseLaunchpeg,
                batchNumber,
                launchpegToBatchToSeed[_baseLaunchpeg][batchNumber]
            );
        }

        return true;
    }

    /// @dev Callback triggered by the VRF coordinator
    /// @param _randomWords Array of random numbers provided by the VRF coordinator
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        address baseLaunchpeg = vrfRequestIdToLaunchpeg[_requestId];

        if (launchpegToHasBeenForceRevealed[baseLaunchpeg]) {
            revert Launchpeg__HasBeenForceRevealed();
        }

        uint256 revealBatchSize = launchpegToConfig[baseLaunchpeg]
            .revealBatchSize;
        uint256 collectionSize = launchpegToConfig[baseLaunchpeg]
            .collectionSize;
        uint256 _batchToReveal = launchpegToNextBatchToReveal[baseLaunchpeg]++;
        uint256 _revealBatchSize = revealBatchSize;
        uint256 _seed = _randomWords[0] %
            (collectionSize - (_batchToReveal * _revealBatchSize));

        launchpegToBatchToSeed[baseLaunchpeg][_batchToReveal] = _seed;
        launchpegToLastTokenReveal[baseLaunchpeg] += _revealBatchSize;

        emit Reveal(
            baseLaunchpeg,
            _batchToReveal,
            launchpegToBatchToSeed[baseLaunchpeg][_batchToReveal]
        );
    }

    /// @dev Force reveal, should be restricted to owner
    function forceReveal(address _baseLaunchpeg) external override onlyOwner {
        uint256 revealBatchSize = launchpegToConfig[_baseLaunchpeg]
            .revealBatchSize;
        uint256 batchNumber;
        unchecked {
            batchNumber =
                launchpegToLastTokenReveal[_baseLaunchpeg] /
                revealBatchSize;
            launchpegToLastTokenReveal[_baseLaunchpeg] += revealBatchSize;
        }

        _setBatchSeed(
            _baseLaunchpeg,
            batchNumber,
            launchpegToConfig[_baseLaunchpeg].collectionSize,
            launchpegToConfig[_baseLaunchpeg].revealBatchSize
        );
        launchpegToHasBeenForceRevealed[_baseLaunchpeg] = true;
        emit Reveal(
            _baseLaunchpeg,
            batchNumber,
            launchpegToBatchToSeed[_baseLaunchpeg][batchNumber]
        );
    }

    /// @notice Returns true if batch reveal is configured for the given launchpeg
    /// Since the collection size is set only when batch reveal is initialized,
    /// and the collection size cannot be 0, we assume a 0 value means
    /// the batch reveal configuration has not been initialized.
    function isBatchRevealInitialized(address _baseLaunchpeg)
        public
        view
        override
        returns (bool)
    {
        return launchpegToConfig[_baseLaunchpeg].collectionSize != 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// ------------------------------------------------------------------------------
/// @notice Interface for contracts using VRF randomness
///   Forked from chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol
/// ------------------------------------------------------------------------------

/// @dev PURPOSE
///
/// @dev Reggie the Random Oracle (not his real job) wants to provide randomness
/// @dev to Vera the verifier in such a way that Vera can be sure he's not
/// @dev making his output up to suit himself. Reggie provides Vera a public key
/// @dev to which he knows the secret key. Each time Vera provides a seed to
/// @dev Reggie, he gives back a value which is computed completely
/// @dev deterministically from the seed and the secret key.
///
/// @dev Reggie provides a proof by which Vera can verify that the output was
/// @dev correctly computed once Reggie tells it to her, but without that proof,
/// @dev the output is indistinguishable to her from a uniform random sample
/// @dev from the output space.
///
/// @dev The purpose of this contract is to make it easy for unrelated contracts
/// @dev to talk to Vera the verifier about the work Reggie is doing, to provide
/// @dev simple access to a verifiable source of randomness. It ensures 2 things:
/// @dev 1. The fulfillment came from the VRFCoordinator
/// @dev 2. The consumer contract implements fulfillRandomWords.
/// @dev USAGE
///
/// @dev Calling contracts must inherit from VRFConsumerBase, and can
/// @dev initialize VRFConsumerBase's attributes in their constructor as
/// @dev shown:
///
/// @dev   contract VRFConsumer {
/// @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
/// @dev       VRFConsumerBase(_vrfCoordinator) public {
/// @dev         <initialization with other arguments goes here>
/// @dev       }
/// @dev   }
///
/// @dev The oracle will have given you an ID for the VRF keypair they have
/// @dev committed to (let's call it keyHash). Create subscription, fund it
/// @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
/// @dev subscription management functions).
/// @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
/// @dev callbackGasLimit, numWords),
/// @dev see (VRFCoordinatorInterface for a description of the arguments).
///
/// @dev Once the VRFCoordinator has received and validated the oracle's response
/// @dev to your request, it will call your contract's fulfillRandomWords method.
///
/// @dev The randomness argument to fulfillRandomWords is a set of random words
/// @dev generated from your requestId and the blockHash of the request.
///
/// @dev If your contract could have concurrent requests open, you can use the
/// @dev requestId returned from requestRandomWords to track which response is associated
/// @dev with which randomness request.
/// @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
/// @dev if your contract could have multiple requests in flight simultaneously.
///
/// @dev Colliding `requestId`s are cryptographically impossible as long as seeds
/// @dev differ.
///
/// ------------------------------------------------------------------------------
/// @dev SECURITY CONSIDERATIONS
///
/// @dev A method with the ability to call your fulfillRandomness method directly
/// @dev could spoof a VRF response with any random value, so it's critical that
/// @dev it cannot be directly called by anything other than this base contract
/// @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
///
/// @dev For your users to trust that your contract's random behavior is free
/// @dev from malicious interference, it's best if you can write it so that all
/// @dev behaviors implied by a VRF response are executed ///during/// your
/// @dev fulfillRandomness method. If your contract must store the response (or
/// @dev anything derived from it) and use it later, you must ensure that any
/// @dev user-significant behavior which depends on that stored value cannot be
/// @dev manipulated by a subsequent VRF request.
///
/// @dev Similarly, both miners and the VRF oracle itself have some influence
/// @dev over the order in which VRF responses appear on the blockchain, so if
/// @dev your contract could have multiple VRF requests in flight simultaneously,
/// @dev you must ensure that the order in which the VRF responses arrive cannot
/// @dev be used to manipulate your contract's user-significant behavior.
///
/// @dev Since the block hash of the block which contains the requestRandomness
/// @dev call is mixed into the input to the VRF ///last///, a sufficiently powerful
/// @dev miner could, in principle, fork the blockchain to evict the block
/// @dev containing the request, forcing the request to be included in a
/// @dev different block with a different hash, and therefore a different input
/// @dev to the VRF. However, such an attack would incur a substantial economic
/// @dev cost. This cost scales with the number of blocks the VRF oracle waits
/// @dev until it calls responds to a request. It is for this reason that
/// @dev that you can signal to an oracle you'd like them to wait longer before
/// @dev responding to the request (however this is not enforced in the contract
/// @dev and so remains effective only in the case of unmodified oracle software).
///

abstract contract VRFConsumerBaseV2Upgradeable {
    error OnlyCoordinatorCanFulfill(address have, address want);
    address internal vrfCoordinator;

    /// @notice Initializes the vrf coordinator address
    /// @param _vrfCoordinator address of VRFCoordinator contract
    function setVRFConsumer(address _vrfCoordinator) internal {
        vrfCoordinator = _vrfCoordinator;
    }

    /// @notice fulfillRandomness handles the VRF response. Your contract must
    /// @notice implement it. See "SECURITY CONSIDERATIONS" above for important
    /// @notice principles to keep in mind when implementing your fulfillRandomness
    /// @notice method.
    ///
    /// @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
    /// @dev signature, and will call it once it has verified the proof
    /// @dev associated with the randomness. (It is triggered via a call to
    /// @dev rawFulfillRandomness, below.)
    ///
    /// @param requestId The Id initially returned by requestRandomness
    /// @param randomWords the VRF output expanded to the requested number of words
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual;

    /// @notice rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    /// proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    /// the origin of the call
    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}

// SPDX-License-Identifier: MIT
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerQueryForNonexistentToken();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error URIQueryForNonexistentToken();

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension. Built to optimize for lower gas during batch mints.
 *
 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).
 *
 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 *
 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721AUpgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC721Upgradeable,
    IERC721MetadataUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Compiler will pack this into a single 256bit word.
    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    // Compiler will pack this into a single 256bit word.
    struct AddressData {
        // Realistically, 2**64-1 is more than enough.
        uint64 balance;
        // Keeps track of mint count with minimal overhead for tokenomics.
        uint64 numberMinted;
        // Keeps track of burn count with minimal overhead for tokenomics.
        uint64 numberBurned;
        // For miscellaneous variable(s) pertaining to the address
        // (e.g. number of whitelist mint slots used).
        // If there are multiple variables, please pack them into a uint64.
        uint64 aux;
    }

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenOwnership) internal _ownerships;

    // Mapping owner address to address data
    mapping(address => AddressData) private _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721A_init(string memory name_, string memory symbol_)
        internal
        onlyInitializing
    {
        __ERC721A_init_unchained(name_, symbol_);
    }

    function __ERC721A_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * To change the starting tokenId, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than _currentIndex - _startTokenId() times
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to _startTokenId()
        unchecked {
            return _currentIndex - _startTokenId();
        }
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
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberMinted);
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberBurned);
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return _addressData[owner].aux;
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        _addressData[owner].aux = aux;
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId)
        internal
        view
        returns (TokenOwnership memory)
    {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr && curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    // Invariant:
                    // There will always be an ownership that has an address and is not burned
                    // before an ownership that does not have an address and is not burned.
                    // Hence, curr will not underflow.
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).addr;
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
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
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
        address owner = ERC721AUpgradeable.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        override
        returns (address)
    {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

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
        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
        _transfer(from, to, tokenId);
        if (
            to.isContract() &&
            !_checkContractOnERC721Received(from, to, tokenId, _data)
        ) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex &&
            !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, "");
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        _mint(to, quantity, _data, true);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (safe && to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (
                        !_checkContractOnERC721Received(
                            address(0),
                            to,
                            updatedIndex++,
                            _data
                        )
                    ) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex != end);
                // Reentrancy protection
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex != end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
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
    ) private {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev This is equivalent to _burn(tokenId, false)
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
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
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);
        address from = prevOwnership.addr;
        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());
            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }
        _beforeTokenTransfers(from, address(0), tokenId, 1);
        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);
        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;
            // Keep track of who burned the token, and the timestamp of burning.
            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;
            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }
        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);
        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try
            IERC721ReceiverUpgradeable(to).onERC721Received(
                _msgSender(),
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
            return
                retval ==
                IERC721ReceiverUpgradeable(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[42] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";

import "../ERC721AUpgradeable.sol";

/// @title IBaseLaunchpeg
/// @author Trader Joe
/// @notice Defines the basic interface of BaseLaunchpeg
interface IBaseLaunchpeg is IERC721Upgradeable, IERC721MetadataUpgradeable {
    enum Phase {
        NotStarted,
        DutchAuction,
        PreMint,
        Allowlist,
        PublicSale,
        Ended
    }

    /// @notice Collection data to initialize Launchpeg
    /// @param name ERC721 name
    /// @param symbol ERC721 symbol
    /// @param maxPerAddressDuringMint Max amount of NFTs an address can mint in public phases
    /// @param collectionSize The collection size (e.g 10000)
    /// @param amountForDevs Amount of NFTs reserved for `projectOwner` (e.g 200)
    /// @param amountForAuction Amount of NFTs available for the auction (e.g 8000)
    /// @param amountForAllowlist Amount of NFTs available for the allowlist mint (e.g 1000)
    struct CollectionData {
        string name;
        string symbol;
        address batchReveal;
        uint256 maxPerAddressDuringMint;
        uint256 collectionSize;
        uint256 amountForDevs;
        uint256 amountForAuction;
        uint256 amountForAllowlist;
    }

    /// @notice Collection owner data to initialize Launchpeg
    /// @param owner The contract owner
    /// @param projectOwner The project owner
    /// @param royaltyReceiver Royalty fee collector
    /// @param joeFeeCollector The address to which the fees on the sale will be sent
    /// @param joeFeePercent The fees collected by the fee collector on the sale benefits
    struct CollectionOwnerData {
        address owner;
        address projectOwner;
        address royaltyReceiver;
        address joeFeeCollector;
        uint256 joeFeePercent;
    }

    function PROJECT_OWNER_ROLE() external pure returns (bytes32);

    function collectionSize() external view returns (uint256);

    function unrevealedURI() external view returns (string memory);

    function baseURI() external view returns (string memory);

    function amountForDevs() external view returns (uint256);

    function amountForAllowlist() external view returns (uint256);

    function maxPerAddressDuringMint() external view returns (uint256);

    function joeFeePercent() external view returns (uint256);

    function joeFeeCollector() external view returns (address);

    function allowlist(address) external view returns (uint256);

    function amountMintedByDevs() external view returns (uint256);

    function amountMintedDuringPreMint() external view returns (uint256);

    function amountClaimedDuringPreMint() external view returns (uint256);

    function amountMintedDuringAllowlist() external view returns (uint256);

    function amountMintedDuringPublicSale() external view returns (uint256);

    function preMintStartTime() external view returns (uint256);

    function allowlistStartTime() external view returns (uint256);

    function publicSaleStartTime() external view returns (uint256);

    function publicSaleEndTime() external view returns (uint256);

    function withdrawAVAXStartTime() external view returns (uint256);

    function allowlistPrice() external view returns (uint256);

    function salePrice() external view returns (uint256);

    function initializeBatchReveal(address _batchReveal) external;

    function setRoyaltyInfo(address receiver, uint96 feePercent) external;

    function seedAllowlist(
        address[] memory _addresses,
        uint256[] memory _numSlots
    ) external;

    function setBaseURI(string calldata baseURI) external;

    function setUnrevealedURI(string calldata baseURI) external;

    function setPreMintStartTime(uint256 _preMintStartTime) external;

    function setAllowlistStartTime(uint256 _allowlistStartTime) external;

    function setPublicSaleStartTime(uint256 _publicSaleStartTime) external;

    function setPublicSaleEndTime(uint256 _publicSaleEndTime) external;

    function setWithdrawAVAXStartTime(uint256 _withdrawAVAXStartTime) external;

    function devMint(uint256 quantity) external;

    function preMint(uint96 _quantity) external payable;

    function claimPreMint() external;

    function batchClaimPreMint(uint96 _maxQuantity) external;

    function allowlistMint(uint256 _quantity) external payable;

    function publicSaleMint(uint256 _quantity) external payable;

    function withdrawAVAX(address to) external;

    function getOwnershipData(uint256 tokenId)
        external
        view
        returns (ERC721AUpgradeable.TokenOwnership memory);

    function userPendingPreMints(address owner) external view returns (uint256);

    function numberMinted(address owner) external view returns (uint256);

    function numberMintedWithPreMint(address _owner)
        external
        view
        returns (uint256);

    function currentPhase() external view returns (Phase);

    function revealNextBatch() external;

    function hasBatchToReveal() external view returns (bool, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title IBatchReveal
/// @author Trader Joe
/// @notice Defines the basic interface of BatchReveal
interface IBatchReveal {
    struct BatchRevealConfig {
        uint256 collectionSize;
        int128 intCollectionSize;
        /// @notice Size of the batch reveal
        /// @dev Must divide collectionSize
        uint256 revealBatchSize;
        /// @notice Timestamp for the start of the reveal process
        /// @dev Can be set to zero for immediate reveal after token mint
        uint256 revealStartTime;
        /// @notice Time interval for gradual reveal
        /// @dev Can be set to zero in order to reveal the collection all at once
        uint256 revealInterval;
    }

    function initialize() external;

    function configure(
        address _baseLaunchpeg,
        uint256 _revealBatchSize,
        uint256 _revealStartTime,
        uint256 _revealInterval
    ) external;

    function setRevealBatchSize(
        address _baseLaunchpeg,
        uint256 _revealBatchSize
    ) external;

    function setRevealStartTime(
        address _baseLaunchpeg,
        uint256 _revealStartTime
    ) external;

    function setRevealInterval(address _baseLaunchpeg, uint256 _revealInterval)
        external;

    function setVRF(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) external;

    function launchpegToConfig(address)
        external
        view
        returns (
            uint256,
            int128,
            uint256,
            uint256,
            uint256
        );

    function launchpegToBatchToSeed(address, uint256)
        external
        view
        returns (uint256);

    function launchpegToLastTokenReveal(address)
        external
        view
        returns (uint256);

    function useVRF() external view returns (bool);

    function subscriptionId() external view returns (uint64);

    function keyHash() external view returns (bytes32);

    function callbackGasLimit() external view returns (uint32);

    function requestConfirmations() external view returns (uint16);

    function launchpegToNextBatchToReveal(address)
        external
        view
        returns (uint256);

    function launchpegToHasBeenForceRevealed(address)
        external
        view
        returns (bool);

    function launchpegToVrfRequestedForBatch(address, uint256)
        external
        view
        returns (bool);

    function getShuffledTokenId(address _baseLaunchpeg, uint256 _startId)
        external
        view
        returns (uint256);

    function isBatchRevealInitialized(address _baseLaunchpeg)
        external
        view
        returns (bool);

    function revealNextBatch(address _baseLaunchpeg, uint256 _totalSupply)
        external
        returns (bool);

    function hasBatchToReveal(address _baseLaunchpeg, uint256 _totalSupply)
        external
        view
        returns (bool, uint256);

    function forceReveal(address _baseLaunchpeg) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// LaunchpegFactory
error LaunchpegFactory__InvalidBatchReveal();
error LaunchpegFactory__InvalidImplementation();

// Launchpeg
error Launchpeg__BatchRevealAlreadyInitialized();
error Launchpeg__BatchRevealDisabled();
error Launchpeg__BatchRevealNotInitialized();
error Launchpeg__BatchRevealStarted();
error Launchpeg__CanNotMintThisMany();
error Launchpeg__HasBeenForceRevealed();
error Launchpeg__InvalidAllowlistPrice();
error Launchpeg__InvalidAuctionDropInterval();
error Launchpeg__InvalidBatchReveal();
error Launchpeg__InvalidBatchRevealSize();
error Launchpeg__InvalidCallbackGasLimit();
error Launchpeg__InvalidClaim();
error Launchpeg__InvalidCoordinator();
error Launchpeg__InvalidKeyHash();
error Launchpeg__InvalidJoeFeeCollector();
error Launchpeg__InvalidMaxPerAddressDuringMint();
error Launchpeg__InvalidOwner();
error Launchpeg__InvalidProjectOwner();
error Launchpeg__InvalidPercent();
error Launchpeg__InvalidQuantity();
error Launchpeg__InvalidRevealDates();
error Launchpeg__InvalidRoyaltyInfo();
error Launchpeg__InvalidPhases();
error Launchpeg__IsNotInTheConsumerList();
error Launchpeg__LargerCollectionSizeNeeded();
error Launchpeg__MaxSupplyForDevReached();
error Launchpeg__MaxSupplyReached();
error Launchpeg__NotEligibleForAllowlistMint();
error Launchpeg__NotEnoughAVAX(uint256 avaxSent);
error Launchpeg__NotInitialized();
error Launchpeg__RevealNextBatchNotAvailable();
error Launchpeg__TransferFailed();
error Launchpeg__Unauthorized();
error Launchpeg__WithdrawAVAXNotAvailable();
error Launchpeg__WrongAddressesAndNumSlotsLength();
error Launchpeg__WrongPhase();

// PendingOwnableUpgradeable
error PendingOwnableUpgradeable__NotOwner();
error PendingOwnableUpgradeable__AddressZero();
error PendingOwnableUpgradeable__NotPendingOwner();
error PendingOwnableUpgradeable__PendingOwnerAlreadySet();
error PendingOwnableUpgradeable__NoPendingOwner();

// SafeAccessControlEnumerableUpgradeable
error SafeAccessControlEnumerableUpgradeable__SenderMissingRoleAndIsNotOwner(
    bytes32 role,
    address sender
);
error SafeAccessControlEnumerableUpgradeable__RoleIsDefaultAdmin();

// SafePausableUpgradeable
error SafePausableUpgradeable__AlreadyPaused();
error SafePausableUpgradeable__AlreadyUnpaused();

// OperatorFilterer
error OperatorNotAllowed(address operator);