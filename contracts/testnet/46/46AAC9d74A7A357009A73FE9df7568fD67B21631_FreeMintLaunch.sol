// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IConfigStore {
  event SetBaseProjectURI(string uri);

  event SetBaseMembershipPassURI(string uri);

  event SetBaseContractURI(string uri);

  event SetSigner(address signer);

  event SetSuperAdmin(address admin);

  event SetDevTreasury(address devTreasury);

  event SetTapFee(uint256 fee);

  event SetContributeFee(uint256 fee);

  event SetClaimFee(uint256 fee);

  event SetMinLockRate(uint256 minLockRate);

  event RoyaltyFeeSenderChanged(address royaltyFeeSender, bool isAdd);

  event TerminalRoleChanged(address terminal, bool grant);

  event MintRoleChanged(address account, bool grant);

  error BadTapFee();

  error ZeroAddress();

  function baseProjectURI() external view returns (string memory);

  function baseMembershipPassURI() external view returns (string memory);

  function baseContractURI() external view returns (string memory);

  function signerAddress() external view returns (address);

  function superAdmin() external view returns (address);

  function devTreasury() external view returns (address);

  function tapFee() external view returns (uint256);

  function contributeFee() external view returns (uint256);

  function claimFee() external view returns (uint256);

  function minLockRate() external view returns (uint256);

  function royaltyFeeSenderWhiteList(address _sender) external view returns (bool);

  function terminalRoles(address) external view returns (bool);

  function mintRoles(address) external view returns (bool);

  function setBaseProjectURI(string calldata _uri) external;

  function setBaseMembershipPassURI(string calldata _uri) external;

  function setBaseContractURI(string calldata _uri) external;

  function setSigner(address _admin) external;

  function setSuperAdmin(address _signer) external;

  function setDevTreasury(address _devTreasury) external;

  function setTapFee(uint256 _fee) external;

  function setContributeFee(uint256 _fee) external;

  function setClaimFee(uint256 _fee) external;

  function setMinLockRate(uint256 _lockRate) external;

  function addRoyaltyFeeSender(address _sender) external;

  function removeRoyaltyFeeSender(address _sender) external;

  function grantTerminalRole(address _terminal) external;

  function revokeTerminalRole(address _terminal) external;

  function grantMintRole(address _terminal) external;

  function revokeMintRole(address _terminal) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IConfigStore} from "./IConfigStore.sol";

enum FundingCycleState {
  WarmUp,
  Active,
  Expired
}

enum FundingCycleMod {
  Airdrop,
  Auction,
  FreeMint,
  FundRaising
}

struct AuctionedPass {
  // tier id, indexed from 0
  uint256 id;
  // the amount of tickets allocated to current round
  uint256 allocateAmount;
  // the amount of tickets reserved to next round
  uint256 reservedAmount;
}

struct FundingCycleProperties {
  uint256 id;
  FundingCycleMod launchMode;
  uint256 previousId;
  uint256 projectId;
  uint256 start;
  uint16 duration;
  uint256 end;
  bool isPaused;
}

struct FundingCycleParameter {
  FundingCycleMod launchMode;
  uint16 duration;
}

interface IFundingCycles {
  event Init(
    uint256 indexed fundingCycleId,
    uint256 indexed projectId,
    uint256 previous,
    uint256 start,
    uint256 end,
    uint256 duration,
    FundingCycleMod launchMode
  );

  event InitAuctionedPass(uint256 indexed fundingCycleId, AuctionedPass autionPass);

  event PauseStateChanged(uint256 indexed fundingCycleId, bool isPause);

  error BadDuration();
  error UnAuthorized();
  error FundingCycleNotExist();
  error FundingCycleExist(uint256 fundingCycleId);

  function count() external view returns (uint256);

  function configStore() external view returns (IConfigStore);

  function latestIdFundingProject(uint256 _projectId) external view returns (uint256);

  function getFundingCycle(uint256 _fundingCycleId)
    external
    view
    returns (FundingCycleProperties memory);

  function currentOf(uint256 _projectId) external view returns (FundingCycleProperties memory);

  function getFundingCycleState(uint256 _fundingCycleId) external view returns (FundingCycleState);

  function getAutionedPass(uint256 _fundingCycleId, uint256 _tierId)
    external
    view
    returns (AuctionedPass memory);

  function configure(
    uint256 _projectId,
    FundingCycleParameter calldata _params,
    AuctionedPass[] calldata _auctionedPass
  ) external returns (FundingCycleProperties memory);

  function setPauseFundingCycle(uint256 _projectId, bool _paused) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AuctionedPass} from "../interfaces/ITerminal.sol";

interface ILaunchMod {
  error NoZero();
  error UnAuthorized();
  error ZeroAddress();
  error SizeNotMatch();
  error AlreadyClaimed();
  error InsufficientBalance();
  error FundingCycleNotExist();

  // modifier onlyProjectFundingCycleMatch(uint256 _projectId, uint256 _fundingCycleId) {
  //   FundingCycleProperties memory _fundingCycle = fundingCycles.getFundingCycle(_fundingCycleId);
  //   if (_projectId == 0 || _fundingCycle.projectId != _projectId) revert FundingCycleNotExist();
  //   _;
  // }

  function launch(
    uint256 _projectId,
    uint256 _fundingCycleId,
    bytes calldata _encodedParam
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IMembershipPass is IERC1155, IERC2981 {
  event MintPass(address indexed recepient, uint256 indexed tier, uint256 amount);

  event BatchMintPass(address indexed recepient, uint256[] tiers, uint256[] amounts);

  error BadTierSize();
  error ZeroAddress();
  error BadCapacity();
  error BadFee();
  error InsufficientBalance();

  function royaltyInfo(uint256 _tier, uint256 _salePrice)
    external
    view
    override
    returns (address receiver, uint256 royaltyAmount);

  function mintPassForMember(
    address _recepient,
    uint256 _token,
    uint256 _amount
  ) external;

  function batchMintPassForMember(
    address _recepient,
    uint256[] calldata _tokens,
    uint256[] calldata _amounts
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IMembershipPass} from "./IMembershipPass.sol";

interface IMembershipPassBooth {
  event Issue(
    uint256 indexed projectId,
    address membershipPass,
    address royaltyDistributor,
    uint256[] tierFee,
    uint256[] tierCapacity,
    uint256[] multipers
  );

  event BatchMintTicket(
    address indexed from,
    uint256 indexed projectId,
    uint256[] tiers,
    uint256[] amounts
  );

  event MintTicket(address indexed from, uint256 indexed projectId, uint256 tier, uint256 amount);

  error UnAuthorized();

  function tierSizeOf(uint256 _projectId) external view returns (uint256);

  function membershipPassOf(uint256 _projectId) external view returns (IMembershipPass);

  function issue(
    uint256 _projectId,
    address _royalty,
    uint256[] calldata _tierFees,
    uint256[] calldata _tierCapacities,
    uint256[] calldata _multipers
  ) external returns (address);

  function batchMintTicket(
    uint256 _projectId,
    address _from,
    uint256[] calldata _tierIds,
    uint256[] calldata _amounts
  ) external;

  function mintTicket(
    uint256 _projectId,
    address _from,
    uint256 _tierId,
    uint256 _amount
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IConfigStore} from "./IConfigStore.sol";

interface IProjects is IERC721 {
  error EmptyHandle();
  error TakenedHandle();
  error UnAuthorized();

  event Create(uint256 indexed projectId, address indexed owner, bytes32 handle, address caller);

  function count() external view returns (uint256);

  function configStore() external view returns (IConfigStore);

  function handleOf(uint256 _projectId) external returns (bytes32 handle);

  function projectFor(bytes32 _handle) external returns (uint256 projectId);

  function exists(uint256 _projectId) external view returns (bool);

  function create(address _owner, bytes32 _handle) external returns (uint256 id);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {AuctionedPass, FundingCycleParameter, FundingCycleMod} from "./IFundingCycles.sol";

struct Metadata {
  // The unique handle name for the DAO
  bytes32 handle;
  // The NFT token address of Customized Boosters
  address[] customBoosters;
  // The multipliers of customized NFT
  uint16[] boosterMultipliers;
}

struct ImmutablePassTier {
  uint256 tierFee;
  uint256 multiplier;
  uint256 tierCapacity;
}

interface ITerminal {
  error BadTierId();
  error NoZero();
  error ZeroAddress();
  error UnAuthorized();
  error InsufficientBalance();
  error FundingCycleActived();

  event LaunchModChanged(FundingCycleMod _launchMod, address modAddress,  bool isAdd);

  function createDao(
    Metadata calldata _metadata,
    ImmutablePassTier[] calldata _tiers,
    AuctionedPass[] calldata _auctionedPass,
    FundingCycleParameter calldata _params,
    bytes memory _encodedParam
  ) external;

  function createNewFundingCycle(
    uint256 _projectId,
    AuctionedPass[] calldata _auctionedPass,
    FundingCycleParameter calldata _params,
    bytes memory _encodedParam
  ) external;

  function setPausedFundingCycleProject(uint256 _projectId, bool _paused) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {IProjects} from "../interfaces/IProjects.sol";
import {IConfigStore} from "../interfaces/IConfigStore.sol";
import {IMembershipPassBooth} from "../interfaces/IMembershipPassBooth.sol";
import {ILaunchMod, AuctionedPass} from "../interfaces/ILaunchMod.sol";
import {IFundingCycles, FundingCycleProperties, FundingCycleMod} from "../interfaces/IFundingCycles.sol";

contract FreeMintLaunch is Initializable, ILaunchMod {
  error Voucher721(address _voucher);
  error ForbidAllocateWhenZeroAddress();

  event Launch(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    address[] communityVoucheres
  );

  event CommunityClaim(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    address indexed beneficiary,
    uint256[] tierIds,
    uint256[] amounts,
    string note
  );

  /*╔═════════════════════════════╗
    ║  Private Stored Properties  ║
    ╚═════════════════════════════╝*/

  mapping(uint256 => mapping(uint256 => address)) private _communityVouchereOf;

  /*╔═════════════════════════════╗
    ║  Public Stored Properties   ║
    ╚═════════════════════════════╝*/

  IProjects public projects;

  IFundingCycles public fundingCycles;

  IMembershipPassBooth public membershipPassBooth;

  IConfigStore public configStore;

  // the community claimed flag by funding cycle
  // address => (funding cycyle id => claimed)
  mapping(address => mapping(uint256 => bool)) public communityClaimedOf;

  // funding cycyle id => tier id => claimed amount
  mapping(uint256 => mapping(uint256 => uint256)) public communityClaimedAmountOf;

  function initialize(
    IProjects _projects,
    IFundingCycles _fundingCycles,
    IMembershipPassBooth _passBooth,
    IConfigStore _configStore
  ) public initializer {
    if (
      _projects == IProjects(address(0)) ||
      _fundingCycles == IFundingCycles(address(0)) ||
      _passBooth == IMembershipPassBooth(address(0)) ||
      _configStore == IConfigStore(address(0))
    ) revert ZeroAddress();

    projects = _projects;
    fundingCycles = _fundingCycles;
    membershipPassBooth = _passBooth;
    configStore = _configStore;
  }

  /**
   * @notice
   * Launch for funding cycle
   *
   * @param _projectId The ID of project
   * @param _fundingCycleId The ID of new funding cycle
   * @param _encodedParam The encoded params for launch mode
   */
  function launch(
    uint256 _projectId,
    uint256 _fundingCycleId,
    bytes calldata _encodedParam
  ) external override {
    if (!configStore.terminalRoles(msg.sender)) revert UnAuthorized();

    uint256 _tierSize = membershipPassBooth.tierSizeOf(_projectId);
    address[] memory _communityVoucheres = abi.decode(_encodedParam, (address[]));
    if (_communityVoucheres.length != _tierSize) revert SizeNotMatch();

    for (uint256 i; i < _communityVoucheres.length; i++) {
      if (
        _communityVoucheres[i] == address(0) &&
        fundingCycles.getAutionedPass(_fundingCycleId, i).allocateAmount != 0
      ) revert ForbidAllocateWhenZeroAddress();
      if (
        _communityVoucheres[i] != address(0) &&
        !IERC721(_communityVoucheres[i]).supportsInterface(0x80ac58cd)
      ) revert Voucher721(_communityVoucheres[i]);

      _communityVouchereOf[_fundingCycleId][i] = _communityVoucheres[i];
    }

    emit Launch(_projectId, _fundingCycleId, _communityVoucheres);
  }

  /**
   * @notice
   * Community members can mint the  membership pass for free. For those who has the specific NFT in wallet, enable to claim free pass
   *
   * @param _projectId The ID of the DAO being contribute to
   * @param _fundingCycleId The funding cycle id
   * @param _memo memo attached when purchase
   */
  function communityContribute(
    uint256 _projectId,
    uint256 _fundingCycleId,
    string calldata _memo
  ) external {
    FundingCycleProperties memory _fundingCycle = fundingCycles.getFundingCycle(_fundingCycleId);
    if (
      _projectId == 0 ||
      _projectId != _fundingCycle.projectId ||
      _fundingCycle.launchMode != FundingCycleMod.FreeMint
    ) revert FundingCycleNotExist();
    if (communityClaimedOf[msg.sender][_fundingCycleId]) revert AlreadyClaimed();

    communityClaimedOf[msg.sender][_fundingCycleId] = true;

    uint256 _tierSize = membershipPassBooth.tierSizeOf(_projectId);
    uint256[] memory _tiers = new uint256[](_tierSize);
    uint256[] memory _amounts = new uint256[](_tierSize);
    bool _eligible;
    bool _enoughTicket;
    for (uint256 i; i < _tierSize; i++) {
      AuctionedPass memory _auctionedPass = fundingCycles.getAutionedPass(_fundingCycleId, i);
      _tiers[i] = _auctionedPass.id;
      address _communityVouchere = _communityVouchereOf[_fundingCycleId][_auctionedPass.id];
      if (
        _communityVouchere != address(0) && IERC721(_communityVouchere).balanceOf(msg.sender) > 0
      ) {
        _eligible = true;
        if (
          _auctionedPass.allocateAmount -
            communityClaimedAmountOf[_fundingCycleId][_auctionedPass.id] >
          0
        ) {
          communityClaimedAmountOf[_fundingCycleId][_auctionedPass.id] += 1;
          _enoughTicket = true;
          _amounts[i] = 1;
        }
      }
    }

    if (!_eligible) revert UnAuthorized();
    if (!_enoughTicket) revert InsufficientBalance();

    membershipPassBooth.batchMintTicket(_projectId, msg.sender, _tiers, _amounts);

    emit CommunityClaim(_projectId, _fundingCycleId, msg.sender, _tiers, _amounts, _memo);
  }
}