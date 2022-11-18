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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

/// @notice Emitted when one of the inputs is type(int256).min.
error PRBMath__MulDivSignedInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows int256.
error PRBMath__MulDivSignedOverflow(uint256 rAbs);

/// @notice Emitted when the input is MIN_SD59x18.
error PRBMathSD59x18__AbsInputTooSmall();

/// @notice Emitted when ceiling a number overflows SD59x18.
error PRBMathSD59x18__CeilOverflow(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__DivInputTooSmall();

/// @notice Emitted when one of the intermediary unsigned results overflows SD59x18.
error PRBMathSD59x18__DivOverflow(uint256 rAbs);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathSD59x18__ExpInputTooBig(int256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathSD59x18__Exp2InputTooBig(int256 x);

/// @notice Emitted when flooring a number underflows SD59x18.
error PRBMathSD59x18__FloorUnderflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMathSD59x18__FromIntOverflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMathSD59x18__FromIntUnderflow(int256 x);

/// @notice Emitted when the product of the inputs is negative.
error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);

/// @notice Emitted when multiplying the inputs overflows SD59x18.
error PRBMathSD59x18__GmOverflow(int256 x, int256 y);

/// @notice Emitted when the input is less than or equal to zero.
error PRBMathSD59x18__LogInputTooSmall(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__MulInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__MulOverflow(uint256 rAbs);

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__PowuOverflow(uint256 rAbs);

/// @notice Emitted when the input is negative.
error PRBMathSD59x18__SqrtNegativeInput(int256 x);

/// @notice Emitted when the calculating the square root overflows SD59x18.
error PRBMathSD59x18__SqrtOverflow(int256 x);

/// @notice Emitted when addition overflows UD60x18.
error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);

/// @notice Emitted when ceiling a number overflows UD60x18.
error PRBMathUD60x18__CeilOverflow(uint256 x);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathUD60x18__ExpInputTooBig(uint256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathUD60x18__Exp2InputTooBig(uint256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format format overflows UD60x18.
error PRBMathUD60x18__FromUintOverflow(uint256 x);

/// @notice Emitted when multiplying the inputs overflows UD60x18.
error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);

/// @notice Emitted when the input is less than 1.
error PRBMathUD60x18__LogInputTooSmall(uint256 x);

/// @notice Emitted when the calculating the square root overflows UD60x18.
error PRBMathUD60x18__SqrtOverflow(uint256 x);

/// @notice Emitted when subtraction underflows UD60x18.
error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);

/// @dev Common mathematical functions used in both PRBMathSD59x18 and PRBMathUD60x18. Note that this shared library
/// does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
/// representation. When it does not, it is explicitly mentioned in the NatSpec documentation.
library PRBMath {
    /// STRUCTS ///

    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }

    /// STORAGE ///

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @dev Largest power of two divisor of SCALE.
    uint256 internal constant SCALE_LPOTD = 262144;

    /// @dev SCALE inverted mod 2^256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;

    /// FUNCTIONS ///

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    /// @dev Has to use 192.64-bit fixed-point numbers.
    /// See https://ethereum.stackexchange.com/a/96594/24693.
    /// @param x The exponent as an unsigned 192.64-bit fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp2(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // Start from 0.5 in the 192.64-bit fixed-point format.
            result = 0x800000000000000000000000000000000000000000000000;

            // Multiply the result by root(2, 2^-i) when the bit at position i is 1. None of the intermediary results overflows
            // because the initial result is 2^191 and all magic factors are less than 2^65.
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            // We're doing two things at the same time:
            //
            //   1. Multiply the result by 2^n + 1, where "2^n" is the integer part and the one is added to account for
            //      the fact that we initially set the result to 0.5. This is accomplished by subtracting from 191
            //      rather than 192.
            //   2. Convert the result to the unsigned 60.18-decimal fixed-point format.
            //
            // This works because 2^(191-ip) = 2^ip / 2^191, where "ip" is the integer part "2^n".
            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    /// @notice Finds the zero-based index of the first one in the binary representation of x.
    /// @dev See the note on msb in the "Find First Set" Wikipedia article https://en.wikipedia.org/wiki/Find_first_set
    /// @param x The uint256 number for which to find the index of the most significant bit.
    /// @return msb The index of the most significant bit as an uint256.
    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The multiplicand as an uint256.
    /// @param y The multiplier as an uint256.
    /// @param denominator The divisor as an uint256.
    /// @return result The result as an uint256.
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        // Make sure the result is less than 2^256. Also prevents denominator == 0.
        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }

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
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

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

    /// @notice Calculates floor(x*y÷1e18) with full precision.
    ///
    /// @dev Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev An extension of "mulDiv" for signed numbers. Works by computing the signs and the absolute values separately.
    ///
    /// Requirements:
    /// - None of the inputs can be type(int256).min.
    /// - The result must fit within int256.
    ///
    /// @param x The multiplicand as an int256.
    /// @param y The multiplier as an int256.
    /// @param denominator The divisor as an int256.
    /// @return result The result as an int256.
    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {
        if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
            revert PRBMath__MulDivSignedInputTooSmall();
        }

        // Get hold of the absolute values of x, y and the denominator.
        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        // Compute the absolute value of (x*y)÷denominator. The result must fit within int256.
        uint256 rAbs = mulDiv(ax, ay, ad);
        if (rAbs > uint256(type(int256).max)) {
            revert PRBMath__MulDivSignedOverflow(rAbs);
        }

        // Get the signs of x, y and the denominator.
        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        // XOR over sx, sy and sd. This is checking whether there are one or three negative signs in the inputs.
        // If yes, the result should be negative.
        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Set the initial guess to the least power of two that is greater than or equal to sqrt(x).
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
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

import {ILaunchMod} from "../interfaces/ILaunchMod.sol";
import {PayoutMod} from "../interfaces/IPayoutStore.sol";

struct WeightInfo {
  uint256 amount;
  uint256 sqrtWeight;
}

interface IFixedPriceLaunch is ILaunchMod {
  error BadPayment();
  error BadLockRate();
  error OnlyGovernor();
  error FundingCyclePaused();
  error BadOperationPeriod();

  event Launch(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    uint256 target,
    uint16 lockRate,
    uint256[] salePrices
  );

  event Tap(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    address indexed beneficiary,
    uint256 govFeeAmount,
    uint256 netTransferAmount
  );

  event Unlock(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    uint256 unlockAmount,
    uint256 totalUnlockedAmount
  );

  event UpdateLocked(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    uint256 depositAmount,
    uint256 totalDepositedAmount
  );

  event Pay(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    address indexed beneficiary,
    uint256 amount,
    uint256[] tiers,
    uint256[] amounts,
    string note
  );

  event Claim(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    address indexed beneficiary,
    uint256 refundAmount,
    uint256[] offeringAmounts
  );

  event DistributeToPayoutMod(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    PayoutMod mod,
    uint256 amount,
    address receiver
  );

  event UnlockTreasury(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    uint256 unlockAmount
  );

  function getTappableAmount(uint256 _fundingCycleId) external view returns (uint256);

  function tap(
    uint256 _projectId,
    uint256 _fundingCycleId,
    uint256 _amount
  ) external;
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

import {IProjects} from "./IProjects.sol";
import {IConfigStore} from "./IConfigStore.sol";

struct PayoutMod {
  uint16 percent;
  address payable beneficiary;
}

interface IPayoutStore {
  error BadPercentage();
  error BadTotalPercentage();
  error BadAddress();
  error NoOp();
  error UnAuthorized();

  event SetPayoutMod(
    uint256 indexed projectId,
    uint256 indexed fundingCycleId,
    PayoutMod mod,
    address caller
  );

  function projects() external view returns (IProjects);

  function configStore() external view returns (IConfigStore);

  function payoutModsOf(uint256 _fundingCycleId) external returns (PayoutMod[] memory);

  function setPayoutMods(
    uint256 _projectId,
    uint256 _fundingCycleId,
    PayoutMod[] memory _mods
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

import {PRBMath} from "@prb/math/contracts/PRBMath.sol"; // TODO remove
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {AdvancedMath} from "../library/AdvancedMath.sol";
import {IProjects} from "../interfaces/IProjects.sol";
import {IPayoutStore} from "../interfaces/IPayoutStore.sol";
import {IConfigStore} from "../interfaces/IConfigStore.sol";
import {IMembershipPassBooth} from "../interfaces/IMembershipPassBooth.sol";
import {IFixedPriceLaunch, PayoutMod, WeightInfo} from "../interfaces/IFixedPriceLaunch.sol";
import {IFundingCycles, FundingCycleState, FundingCycleProperties} from "../interfaces/IFundingCycles.sol";

contract FixedPriceLaunch is Initializable, IFixedPriceLaunch {
  using AdvancedMath for uint256;

  modifier onlyProjectFundingCycleMatch(uint256 _projectId, uint256 _fundingCycleId) {
    if (_projectId == 0 || fundingCycles.getFundingCycle(_fundingCycleId).projectId != _projectId)
      revert FundingCycleNotExist();
    _;
  }

  modifier onlyCorrectPeroid(uint256 _fundingCycleId, FundingCycleState _expectState) {
    if (fundingCycles.getFundingCycleState(_fundingCycleId) != _expectState)
      revert BadOperationPeriod();
    _;
  }

  /*╔═════════════════════════════╗
    ║   Private Stored Constants  ║
    ╚═════════════════════════════╝*/

  // The max percentage of funds lock in treasury 100%
  uint256 private constant MAX_LOCK_RATE = 1e4;

  /*╔═════════════════════════════╗
    ║  Private Stored Properties  ║
    ╚═════════════════════════════╝*/
  mapping(uint256 => mapping(uint256 => uint256)) private _totalBiddingAmountBy;

  // total sqrt weight of each tiers by funding cycle
  // funding cycle id => (tier id => total sqrt weight)
  mapping(uint256 => mapping(uint256 => uint256)) private _totalSqrtWeightBy;

  // the weight details of each funding cycles by address
  // address => (funding cycyle id => (tier id => weight detail))
  mapping(address => mapping(uint256 => mapping(uint256 => WeightInfo))) private _depositedWeightBy;

  mapping(uint256 => mapping(uint256 => uint256)) private _salePriceOf;

  // rate to be locked in treasury 1000 -> 10% 9999 -> 99.99%
  mapping(uint256 => uint16) private _lockRateOf;

  mapping(uint256 => uint256) private _targetOf;

  // Stores the amount that has been tapped within each funding cycle.
  // TODO: Accept with ETH only, should we add ERC20 tokens?
  mapping(uint256 => uint256) private _tappedOf;

  // Stores the amount that has been contributed of each funding cycle.
  // TODO: Accept with ETH only, should we add ERC20 tokens?
  mapping(uint256 => uint256) private _depositedOf;

  // Stores the amount that has been unlocked of each funding cycle.
  // TODO: Accept with ETH only, should we add ERC20 tokens?
  mapping(uint256 => uint256) private _unLockedOf;

  /*╔═════════════════════════════╗
    ║  Public Stored Properties   ║
    ╚═════════════════════════════╝*/

  // the amount of ETH that each funding cycle is responsible for.
  mapping(uint256 => uint256) public balanceOf;

  // the claimed flag by funding cycle
  // address => (funding cycyle id => claimed)
  mapping(address => mapping(uint256 => bool)) public claimedOf;

  // funding cycyle id => tier id => claimed amount
  mapping(uint256 => mapping(uint256 => uint256)) public claimedAmountOf;

  IProjects public projects;

  IFundingCycles public fundingCycles;

  IMembershipPassBooth public membershipPassBooth;

  IPayoutStore public payoutStore;

  IConfigStore public configStore;

  /*╔══════════════════════════╗
    ║  External / Public VIEW  ║
    ╚══════════════════════════╝*/
  /**
	 * @notice
	 * Get offering tickets by funding cycle

	 * @param _from The wallet address of the user 
	 * @param _projectId The ID of the DAO you contributed with
	 * @param _fundingCycleId The ID of the funding cycle

	 * @return _allocationPercents The allocation percentage of each tier Passes offering in this funding cycle
	 * @return _allocationAmounts The amount of each tier Passes offering in this funding cycle
	*/
  function getOfferingAmount(
    address _from,
    uint256 _projectId,
    uint256 _fundingCycleId
  ) public view returns (uint256[] memory, uint256[] memory) {
    uint256 _tierSize = membershipPassBooth.tierSizeOf(_projectId);
    uint256[] memory _allocationPercents = new uint256[](_tierSize);
    uint256[] memory _allocationAmounts = new uint256[](_tierSize);
    for (uint256 i; i < _tierSize; i++) {
      uint256 _allocateAmount = fundingCycles.getAutionedPass(_fundingCycleId, i).allocateAmount;
      if (_allocateAmount == 0 || claimedOf[_from][_fundingCycleId]) {
        continue;
      }
      if (_totalBiddingAmountBy[_fundingCycleId][i] > _allocateAmount) {
        _allocationPercents[i] = _totalSqrtWeightBy[_fundingCycleId][i] == 0
          ? 0
          : ((_depositedWeightBy[_from][_fundingCycleId][i].sqrtWeight * 1e12) /
            _totalSqrtWeightBy[_fundingCycleId][i]) / 1e6;
      } else {
        _allocationPercents[i] =
          ((_depositedWeightBy[_from][_fundingCycleId][i].amount * 1e12) / _allocateAmount) /
          1e6;
      }

      _allocationAmounts[i] = (_allocationPercents[i] * _allocateAmount) / 1e6;
    }

    return (_allocationPercents, _allocationAmounts);
  }

  /**
   * @notice
	 * Estimate allocate tickets

	 * @param _projectId The ID of the DAO
	 * @param _fundingCycleId The ID of the funding cycle
	 * @param _payData payment info
   * 
   * @return _allocationPercents The allocation percentage of each tier Passes offering in this funding cycle
	 * @return _allocationAmounts The amount of each tier Passes offering in this funding cycle
	*/
  function getEstimatingAmount(
    uint256 _projectId,
    uint256 _fundingCycleId,
    uint256[] calldata _payData
  ) external view returns (uint256[] memory, uint256[] memory) {
    uint256 _tierSize = membershipPassBooth.tierSizeOf(_projectId);
    if (_payData.length != _tierSize) revert BadPayment();

    uint256[] memory _allocationPercents = new uint256[](_tierSize);
    uint256[] memory _allocationAmounts = new uint256[](_tierSize);
    for (uint256 i; i < _tierSize; i++) {
      uint256 _allocateAmount = fundingCycles.getAutionedPass(_fundingCycleId, i).allocateAmount;
      if (_allocateAmount == 0) {
        continue;
      }
      if ((_totalBiddingAmountBy[_fundingCycleId][i] + _payData[i]) > _allocateAmount) {
        uint256 _sqrtedWeight = (_payData[i] * _salePriceOf[_fundingCycleId][i]).sqrt();
        _allocationPercents[i] =
          ((_sqrtedWeight * 1e12) / _totalSqrtWeightBy[_fundingCycleId][i] + _sqrtedWeight) /
          1e6;
      } else {
        _allocationPercents[i] = ((_payData[i] * 1e12) / _allocateAmount) / 1e6;
      }
      _allocationAmounts[i] = (_allocationPercents[i] * _allocateAmount) / 1e6;
    }

    return (_allocationPercents, _allocationAmounts);
  }

  /**
	 * @notice
	 * Get offering tickets by funding cycle

	 * @param _from user address
	 * @param _projectId the project id of contribute dao
	 * @param _fundingCycleId the funding cycle id
	*/
  function getRefundingAmount(
    address _from,
    uint256 _projectId,
    uint256 _fundingCycleId
  ) external view returns (uint256 amount) {
    if (claimedOf[_from][_fundingCycleId]) return 0;

    (uint256[] memory _offeringAmounts, ) = getOfferingAmount(_from, _projectId, _fundingCycleId);
    for (uint256 i; i < _offeringAmounts.length; i++) {
      uint256 _amount = _depositedWeightBy[_from][_fundingCycleId][i].amount;
      if (_amount == 0) continue;
      amount += (_amount - _offeringAmounts[i]) * _salePriceOf[_fundingCycleId][i];
    }
  }

  /**
   * @notice
   * Get the tappable amount of giving funding cycle
   *
   * @param _fundingCycleId The ID of funding cycle to get max tappable amount
   */
  function getTappableAmount(uint256 _fundingCycleId)
    public
    view
    override
    returns (uint256 _totalTappable)
  {
    uint256 _eligibleDeposited = _getEligibleDepositedAmount(_fundingCycleId);
    uint256 _baseTappable = (_eligibleDeposited * (1e4 - _lockRateOf[_fundingCycleId])) / 1e4;

    _totalTappable = _baseTappable + _unLockedOf[_fundingCycleId] - _tappedOf[_fundingCycleId];
  }

  /**
	 * @notice
	 * Calculate the unsold tickets by funding cycle id

	 * @param _fundingCycleId the funding cycle id
	*/
  function getUnSoldTickets(uint256 _fundingCycleId) public view returns (uint256) {}

  /*╔═════════════════════════╗
    ║   External Transaction  ║
    ╚═════════════════════════╝*/

  function initialize(
    IProjects _projects,
    IFundingCycles _fundingCycles,
    IMembershipPassBooth _passBooth,
    IPayoutStore _payoutStore,
    IConfigStore _configStore
  ) public initializer {
    if (
      _projects == IProjects(address(0)) ||
      _fundingCycles == IFundingCycles(address(0)) ||
      _passBooth == IMembershipPassBooth(address(0)) ||
      _payoutStore == IPayoutStore(address(0)) ||
      _configStore == IConfigStore(address(0))
    ) revert ZeroAddress();

    projects = _projects;
    fundingCycles = _fundingCycles;
    membershipPassBooth = _passBooth;
    payoutStore = _payoutStore;
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
    (
      uint256 _target,
      uint16 _lockRate,
      uint256[] memory _salePrices,
      PayoutMod[] memory _payoutMods
    ) = abi.decode(_encodedParam, (uint256, uint16, uint256[], PayoutMod[]));
    if (_salePrices.length != _tierSize) revert SizeNotMatch();
    if (_target == 0) revert NoZero();
    if (_lockRate < configStore.minLockRate()) revert BadLockRate();

    for (uint256 i = 0; i < _tierSize; i++) {
      _salePriceOf[_fundingCycleId][i] = _salePrices[i];
    }

    _targetOf[_fundingCycleId] = _target;
    _lockRateOf[_fundingCycleId] = _lockRate;

    payoutStore.setPayoutMods(_projectId, _fundingCycleId, _payoutMods);

    emit Launch(_projectId, _fundingCycleId, _target, _lockRate, _salePrices);
  }

  /**
   * @notice
   * Contribute ETH to a dao
   *
   * @param _projectId The ID of the DAO being contribute to
   * @param _tiers The payment tier ids
   * @param _amounts The amounts of submitted
   * @param _memo The memo that will be attached in the published event after purchasing
   */
  function contribute(
    uint256 _projectId,
    uint256[] calldata _tiers,
    uint256[] calldata _amounts,
    string calldata _memo
  ) external payable {
    FundingCycleProperties memory _fundingCycle = fundingCycles.currentOf(_projectId);
    uint256 _fundingCycleId = _fundingCycle.id;
    if (_fundingCycleId == 0) revert FundingCycleNotExist();
    if (fundingCycles.getFundingCycleState(_fundingCycleId) != FundingCycleState.Active)
      revert BadOperationPeriod();

    // Make sure its not paused.
    if (_fundingCycle.isPaused) revert FundingCyclePaused();
    if (_tiers.length != _amounts.length) revert BadPayment();

    uint256 _amount;
    for (uint256 i; i < _tiers.length; i++) {
      uint256 _salePrice = _salePriceOf[_fundingCycleId][_tiers[i]];
      _amount += _amounts[i] * _salePrice;

      uint256 _sqrtedWeight = (_amounts[i] / _salePrice).sqrt();
      _totalSqrtWeightBy[_fundingCycleId][_tiers[i]] += _sqrtedWeight;
      _totalBiddingAmountBy[_fundingCycleId][_tiers[i]] += _amounts[i];
      WeightInfo memory _weightByTier = _depositedWeightBy[msg.sender][_fundingCycleId][_tiers[i]];
      _depositedWeightBy[msg.sender][_fundingCycleId][_tiers[i]] = WeightInfo({
        amount: _weightByTier.amount + _amounts[i],
        sqrtWeight: _weightByTier.sqrtWeight + _sqrtedWeight
      });
    }

    // Contribute fee amount
    uint256 _feeAmount = (_amount * configStore.contributeFee()) / 100;
    if (msg.value < (_amount + _feeAmount)) revert InsufficientBalance();

    // Update tappable and locked balance
    _updateLocked(_projectId, _fundingCycleId, _amount);

    // Transfer fee to the dev treasury
    Address.sendValue(payable(configStore.devTreasury()), _feeAmount);

    // Add to the balance of the funding cycle.
    balanceOf[_fundingCycleId] += _amount;

    emit Pay(_projectId, _fundingCycleId, msg.sender, _amount, _tiers, _amounts, _memo);
  }

  /**
   * @notice
   * Claim menbershippass or refund overlow part
   *
   * @param _projectId the project id to claim
   * @param _fundingCycleId the funding cycle id to claim
   */
  function claimPassOrRefund(uint256 _projectId, uint256 _fundingCycleId)
    external
    onlyProjectFundingCycleMatch(_projectId, _fundingCycleId)
    onlyCorrectPeroid(_fundingCycleId, FundingCycleState.Expired)
  {
    if (claimedOf[msg.sender][_fundingCycleId]) revert AlreadyClaimed();

    claimedOf[msg.sender][_fundingCycleId] = true;

    uint256 _refundAmount;
    (uint256[] memory _offeringAmounts, ) = getOfferingAmount(
      msg.sender,
      _projectId,
      _fundingCycleId
    );
    uint256[] memory _tierIds = new uint256[](_offeringAmounts.length);
    for (uint256 i; i < _offeringAmounts.length; i++) {
      _tierIds[i] = i;
      uint256 _amount = _depositedWeightBy[msg.sender][_fundingCycleId][i].amount;
      if (_amount == 0) continue;

      _refundAmount += (_amount - _offeringAmounts[i]) * _salePriceOf[_fundingCycleId][i];

      claimedAmountOf[_fundingCycleId][i] += _offeringAmounts[i];
      if (
        claimedAmountOf[_fundingCycleId][i] >=
        fundingCycles.getAutionedPass(_fundingCycleId, i).allocateAmount
      ) revert InsufficientBalance();
    }
    if (_refundAmount > 0) {
      if (balanceOf[_fundingCycleId] < _refundAmount) revert InsufficientBalance();

      balanceOf[_fundingCycleId] -= _refundAmount;
      Address.sendValue(payable(msg.sender), _refundAmount);
    }

    membershipPassBooth.batchMintTicket(_projectId, msg.sender, _tierIds, _offeringAmounts);

    emit Claim(_projectId, _fundingCycleId, msg.sender, _refundAmount, _offeringAmounts);
  }

  /**
   * @notice
   * Tap into funds that have been contributed to a project's funding cycles
   *
   * @param _projectId The ID of the project to which the funding cycle being tapped belongs
   * @param _fundingCycleId The ID of the funding cycle to tap
   * @param _amount The amount being tapped
   */
  function tap(
    uint256 _projectId,
    uint256 _fundingCycleId,
    uint256 _amount
  )
    external
    override
    // nonReentrant TODO 处理一下
    onlyProjectFundingCycleMatch(_projectId, _fundingCycleId)
    onlyCorrectPeroid(_fundingCycleId, FundingCycleState.Expired)
  {
    if (msg.sender != projects.ownerOf(_projectId)) revert UnAuthorized();

    // get a reference to this project's current balance, including any earned yield.
    uint256 _balance = balanceOf[_fundingCycleId];
    if (_amount > _balance) revert InsufficientBalance();

    // register the funds as tapped. Get the ID of the funding cycle that was tapped.
    uint256 _total = getTappableAmount(_fundingCycleId);
    if (_amount > _total) revert InsufficientBalance();
    _tappedOf[_fundingCycleId] += _amount;

    // removed the tapped funds from the project's balance.
    balanceOf[_fundingCycleId] = _balance - _amount;

    uint256 _feeAmount = (_amount * configStore.tapFee()) / 100;
    uint256 _tappableAmount = _amount - _feeAmount;
    Address.sendValue(payable(configStore.devTreasury()), _feeAmount);

    uint256 _leftoverTransferAmount = _distributeToPayoutMods(
      _projectId,
      _fundingCycleId,
      _tappableAmount
    );
    address payable _projectOwner = payable(projects.ownerOf(_projectId));

    if (_leftoverTransferAmount > 0) {
      Address.sendValue(_projectOwner, _leftoverTransferAmount);
    }

    emit Tap(_projectId, _fundingCycleId, msg.sender, _feeAmount, _tappableAmount);
  }

  /**
   * @notice
   * Unlock the funds in project's treasury, only can unlock by funding cycle
   *
   * @param _projectId The project ID of funding cycle belongs to
   * @param _fundingCycleId The ID of funding cycle to unlock funds
   * @param _amount The amount of unlock
   */
  function _unlock(
    uint256 _projectId,
    uint256 _fundingCycleId,
    uint256 _amount
  ) internal {
    uint256 _total = _getUnLockableAmount(_fundingCycleId);
    if (_amount > _total) revert InsufficientBalance();

    _unLockedOf[_fundingCycleId] += _amount;

    emit Unlock(_projectId, _fundingCycleId, _amount, _unLockedOf[_fundingCycleId]);
  }

  /**
   * @notice
   * Unlock the locked balance in dao treasury
   *
   * @dev
   * Only daoGovernor contract
   *
   * @param _projectId The Id of the project to unlock
   * @param _fundingCycleId The Id of the fundingCycle to unlock
   * @param _unlockAmount The amount being unlocked
   */
  // function unLockTreasury(
  //   uint256 _projectId,
  //   uint256 _fundingCycleId,
  //   uint256 _unlockAmount
  // )
  //   external
  //   override
  //   onlyProjectFundingCycleMatch(_projectId, _fundingCycleId)
  //   onlyCorrectPeroid(_fundingCycleId, FundingCycleState.Expired)
  // {
  //   if (msg.sender != address(daoGovernorBooster)) revert OnlyGovernor();

  //   fundingCycles.unlock(_projectId, _fundingCycleId, _unlockAmount);

  //   emit UnlockTreasury(_projectId, _fundingCycleId, _unlockAmount);
  // }

  /*╔═════════════════════════════╗
    ║   Private Helper Functions  ║
    ╚═════════════════════════════╝*/

  /**
   * @notice
   * Pays out the mods for the specified funding cycle.
   * @param _projectId The project id base the distribution on.
   * @param _fundingCycleId The funding cycle id to base the distribution on.
   * @param _amount The total amount being paid out.
   * @return leftoverAmount If the mod percents dont add up to 100%, the leftover amount is returned.
   */
  function _distributeToPayoutMods(
    uint256 _projectId,
    uint256 _fundingCycleId,
    uint256 _amount
  ) private returns (uint256 leftoverAmount) {
    // Set the leftover amount to the initial amount.
    leftoverAmount = _amount;

    // Get a reference to the project's payout mods.
    PayoutMod[] memory _mods = payoutStore.payoutModsOf(_fundingCycleId);

    if (_mods.length == 0) return leftoverAmount;

    //Transfer between all mods.
    for (uint256 _i; _i < _mods.length; ) {
      // Get a reference to the mod being iterated on.
      PayoutMod memory _mod = _mods[_i];

      // The amount to send towards mods. Mods percents are out of 10000.
      uint256 _modCut = PRBMath.mulDiv(_amount, _mod.percent, 10000);

      if (_modCut > 0) {
        Address.sendValue(_mod.beneficiary, _modCut);
      }

      // Subtract from the amount to be sent to the beneficiary.
      leftoverAmount = leftoverAmount - _modCut;

      unchecked {
        _i++;
      }

      emit DistributeToPayoutMod(_fundingCycleId, _projectId, _mod, _modCut, msg.sender);
    }
  }

  /**
   * @notice
   * Update the total deposited funds of funding cycle, include overflowed funds
   *
   * @param _projectId The project ID of funding cycle belongs to
   * @param _fundingCycleId The ID of funding cycle to update records
   * @param _amount The amount of tap
   */
  function _updateLocked(
    uint256 _projectId,
    uint256 _fundingCycleId,
    uint256 _amount
  ) private {
    _depositedOf[_fundingCycleId] += _amount;

    emit UpdateLocked(_projectId, _fundingCycleId, _amount, _depositedOf[_fundingCycleId]);
  }

  /**
   * @notice
   * Get the unlockable amount of giving funding cycle
   *
   * @param _fundingCycleId The ID of funding cycle to get unlockable amount
   */
  function _getUnLockableAmount(uint256 _fundingCycleId)
    private
    view
    returns (uint256 _totalUnLockable)
  {
    uint256 _eligibleDeposited = _getEligibleDepositedAmount(_fundingCycleId);
    uint256 _lockedAmount = (_eligibleDeposited * _lockRateOf[_fundingCycleId]) / 1e4;

    _totalUnLockable = _lockedAmount - _unLockedOf[_fundingCycleId];
  }

  /**
   * @notice
   * Get the eligible amount of giving funding cycle, return the smaller value of target rising amount and actually deposit amount
   *
   * @param _fundingCycleId The ID of funding cycle to get eligible amount
   */
  function _getEligibleDepositedAmount(uint256 _fundingCycleId)
    private
    view
    returns (uint256 _eligibleAmount)
  {
    _eligibleAmount = _depositedOf[_fundingCycleId] >= _targetOf[_fundingCycleId]
      ? _targetOf[_fundingCycleId]
      : _depositedOf[_fundingCycleId];
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library AdvancedMath {
  /**
   * @notice
   * Calculates the square root of x, rounding down
   *
   * @dev
   * Uses the Babylonian method (https://ethereum.stackexchange.com/a/97540/37941)
   *
   * @param x The uint256 number for which to calculate the square root
   * @return result The result as an uint256
   */
  function sqrt(uint256 x) internal pure returns (uint256 result) {
    if (x == 0) {
      return 0;
    }
    // Calculate the square root of the perfect square of a power of two that is the closest to x.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 0x100000000000000000000000000000000) {
      xAux >>= 128;
      result <<= 64;
    }
    if (xAux >= 0x10000000000000000) {
      xAux >>= 64;
      result <<= 32;
    }
    if (xAux >= 0x100000000) {
      xAux >>= 32;
      result <<= 16;
    }
    if (xAux >= 0x10000) {
      xAux >>= 16;
      result <<= 8;
    }
    if (xAux >= 0x100) {
      xAux >>= 8;
      result <<= 4;
    }
    if (xAux >= 0x10) {
      xAux >>= 4;
      result <<= 2;
    }
    if (xAux >= 0x8) {
      result <<= 1;
    }
    // The operations can never overflow because the result is max 2^127 when it enters this block.
    unchecked {
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1;
      result = (result + x / result) >> 1; // Seven iterations should be enough
      uint256 roundedDownResult = x / result;
      return result >= roundedDownResult ? roundedDownResult : result;
    }
  }
}