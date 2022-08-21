/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}




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





interface IBioDeposit {
 /*   function acceptPartnerFee() external payable returns (bool);
    function hasUser(address _user) external view returns (bool, bool);
    function mint(uint256 _parentTokenID, bool _wannaVIP) external payable ;
    function upgradeToVIP() external  payable  ;
    function upgradeTokenToVIP(uint256 _tokenID) external payable;
    function buyService(uint256 _parentTokenID, uint32 _serviceID) external payable ;
    function distributePartnerFee(address _partner) external ;
    function setUserImage(string memory _hash) external ;
    function claimReward() external  ;
    function availableRewardForUser(address _user) external  view returns(uint256);
    function getUserRefData(address user) external view returns(bool, uint256, uint256, uint32, uint32, uint8, uint32, uint8, uint8, uint64, string memory);*/
}


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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

/*
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

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
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
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
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
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
                return retval == IERC721ReceiverUpgradeable(to).onERC721Received.selector;
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
    uint256[44] private __gap;
}







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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}




/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal initializer {
    }
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
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
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
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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
        uint256 length = ERC721Upgradeable.balanceOf(to);
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
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
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
    uint256[46] private __gap;
}


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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}








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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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



interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}





contract BioDeposit is ERC721EnumerableUpgradeable, PausableUpgradeable, OwnableUpgradeable, IBioDeposit
{

 // bytes32 public constant MANAGER = keccak256("MANAGER");
  
    struct Level{
        uint128 personalDeposit; // Personal Deposit Requirement in USDT for this level (18 decimals)
        uint128 firstLineVolume; // First Line Volume Requirement in USDT for this level (18 decimals)
        uint128 structureVolume; // Structure Volume Requirement in USDT for this level(18 decimals)
        uint128 investorVolume; // Investor Volume Requirement in USDT for this level(18 decimals)

        uint16 USDBonus; //USD Bonus*1000. 4% = 40
        uint16 revenueBonus; // Revenue Bonus*1000. 1.5% = 15
        uint16 utilityBonus; // Utitlity Bonus*1000. 1.5% = 15
    }

    Level[10] private levels;


   struct LeaderBonus{
        uint128 personalDeposit; // Personal Deposit Requirement in USDT for this level (18 decimals)
        uint128 firstLineVolume; // First Line Volume Requirement in USDT for this level (18 decimals)
        uint128 mainBranchVolume; // Main Branch Volume Requirement in USDT for this level(18 decimals)
        uint128 sideBranchVolume; // Side Branch Volume Requirement in USDT for this level(18 decimals)

        uint128 USDBonus; //USD Bonus in USDT (18 decimals)
//        uint128 revenueBonus; // Revenue Bonus in revenue token (18 decimals)
//        uint128 utilityBonus; // Utitlity Bonus in utility token (18 decimals)
  
    }

    LeaderBonus[22] private LBonus;


    struct Product{
        uint128 price; // Full product price that user should pay in USDT (18 decimals)
        uint128 cost1; // Amount of USDT we should send to CostAddress_1 (18 decimals)
        uint128 cost2; // Amount of USDT we should send to CostAddress_2 (18 decimals)
        address costAddress_1; //Address #1 we should send usdt for covering costs
        address costAddress_2; //Address #2 we should send usdt for covering costs
        uint128 itemsAmount; // How many items of the product available for sale
        uint32 lastItemID; // ID of first unsold item
        bool isActive; // Is this product currently acive
    }

    Product[] private products;


    struct Tree{
        string fieldID; // Field ID
        uint16 yearPlanted; // Year when tree was planted
        string coord_1; // GPS coordinates of tree
        string coord_2; // GPS coordinates of tree
        uint128 price; // Price paid for tree
    }

    Tree[] private treeData;

    struct User{
        uint8 level; // User Level
        uint8 lblevel; // User LBLevel
        uint256[] parents; // Parent IDs Array
        uint256[] firstLine; // First Line IDs Array
        uint32[] trees; // Trees array
        uint32 tAmount; // Trees Amount

        uint128 personalDeposit; // Personal Deposit in USDT (18 decimals)
        uint128 firstLineVolume; // First Line Volume in USDT (18 decimals)
        uint128 mainBranchVolume; // Main Branch Volume in USDT (18 decimals)
        uint128 sideBranchVolume; // Side Branch Volume in USDT (18 decimals)
        uint128 structureVolume; // Structure Volume in USDT (18 decimals)

        uint128 USDBalance; //Total Balance in USDT (18 decimals)
        uint128 USDBalanceWithdrawn; //Withdrawn Balance in USDT (18 decimals)

        uint128 revenueBalance; //Revenue Balance in revenue token (18 decimals)
        uint128 revenueBalanceWithdrawn; //Withdrawn Balance in revenue token (18 decimals)

        uint128 utilityBalance; //Utility Balance in utility token (18 decimals)
        uint128 utilityBalanceWithdrawn; //Withdrawn Balance in utility token (18 decimals)

        bool isLevelProtected; // Does user have his Level protected from lowering
        string imageHash; // imageHash in IPFS
    }

    mapping(uint256 => User) users; //tokenID => User; tokenID starts from 1;
    
    string private baseURIStr;

    uint128[] private totalBuyAmounts; // Total Buy Amounts By Products in USDT (18 decimals)
    uint128 private totalUniLevelBonusBalance = 0; // USDT (18 decimals)
    uint128 private totalLeaderBonusBalance = 0; // USDT (18 decimals)
    uint128 private USDTWithdrawn = 0; // USDT withdrawn by users (18 decimals)
    address private constant service_1 = 0xD2308164406E4cd89756e6aF9B0e4809B685B9CB;
    address private constant service_2 = 0x058C02254965Cf3e6d19a7ea9d5a80ba7655EBA6;

    bool private isPromoLive = true;

    uint8 storageVersion;
    IERC20Metadata public usdt;

/*  event MintBonuses(uint256 indexed tokenID, uint256 price, uint256 refBonus, uint256 userBonus, uint256 vipBonus, uint256 commission);
    event UpgradeBonuses(uint256 indexed tokenID, uint256 price, uint256 refBonus, uint256 userBonus, uint256 vipBonus, uint256 commission);
    event ServiceBonuses(uint256 indexed tokenID, uint256 price, uint256 refBonus, uint256 userBonus, uint256 vipBonus, uint256 commission);

    event ServicePriceSet(uint256 indexed id, uint256 price);
    event RewardClaimed(uint256 indexed tokenID, uint256 directRefBonus, uint256 poolRewardPayout);
    event XFactorUpdated(address indexed user, uint256 indexed tokenID, uint8 xFactor);
    event RankUpdated(address indexed user, uint256 indexed tokenID, uint64 rank);
*/

    function initialize() public initializer {
        __ERC721Enumerable_init();
        __Pausable_init_unchained();
        __Ownable_init_unchained();
        __ERC721_init_unchained("Test BioDeposit NFT", "Test BDNFT");
 
//      Тут надо прописать 2 админа!
//      _setupRole(DEFAULT_ADMIN_ROLE, 0xD2308164406E4cd89756e6aF9B0e4809B685B9CB);
//      _setupRole(DEFAULT_ADMIN_ROLE, 0x058C02254965Cf3e6d19a7ea9d5a80ba7655EBA6);


        baseURIStr = "ipfs://";
        usdt = IERC20Metadata(0x55d398326f99059fF775485246999027B3197955);

        //Levels Initialize 
        levels[0].personalDeposit = 0;
        levels[0].firstLineVolume = 0;
        levels[0].structureVolume = 0;
        levels[0].investorVolume  = 0;
        levels[0].USDBonus        = 0;
        levels[0].revenueBonus    = 0;
        levels[0].utilityBonus    = 0;

        levels[1].personalDeposit = 1000000000000000000000;
        levels[1].firstLineVolume = 0;
        levels[1].structureVolume = 0;
        levels[1].investorVolume  = 1000000000000000000000;
        levels[1].USDBonus        = 40;
        levels[1].revenueBonus    = 15;
        levels[1].utilityBonus    = 15;

        levels[2].personalDeposit = 1500000000000000000000;
        levels[2].firstLineVolume =  750000000000000000000;
        levels[2].structureVolume = 2500000000000000000000;
        levels[2].investorVolume  = 2500000000000000000000;
        levels[2].USDBonus        = 50;
        levels[2].revenueBonus    = 15;
        levels[2].utilityBonus    = 15;

        levels[3].personalDeposit =  2000000000000000000000;
        levels[3].firstLineVolume =  2000000000000000000000;
        levels[3].structureVolume = 10000000000000000000000;
        levels[3].investorVolume  = 10000000000000000000000;
        levels[3].USDBonus        = 60;
        levels[3].revenueBonus    = 15;
        levels[3].utilityBonus    = 15;

        levels[4].personalDeposit =   2500000000000000000000;
        levels[4].firstLineVolume =   5000000000000000000000;
        levels[4].structureVolume =  40000000000000000000000;
        levels[4].investorVolume  =  40000000000000000000000;
        levels[4].USDBonus        = 80;
        levels[4].revenueBonus    = 15;
        levels[4].utilityBonus    = 15;

        levels[5].personalDeposit =    3500000000000000000000;
        levels[5].firstLineVolume =   15000000000000000000000;
        levels[5].structureVolume =  150000000000000000000000;
        levels[5].investorVolume  =  150000000000000000000000;
        levels[5].USDBonus        = 100;
        levels[5].revenueBonus    =  15;
        levels[5].utilityBonus    =  15;

        levels[6].personalDeposit =    5000000000000000000000;
        levels[6].firstLineVolume =   35000000000000000000000;
        levels[6].structureVolume =  500000000000000000000000;
        levels[6].investorVolume  =  500000000000000000000000;
        levels[6].USDBonus        = 120;
        levels[6].revenueBonus    =  15;
        levels[6].utilityBonus    =  15;

        levels[7].personalDeposit =    10000000000000000000000;
        levels[7].firstLineVolume =    80000000000000000000000;
        levels[7].structureVolume =  1250000000000000000000000;
        levels[7].investorVolume  =  1250000000000000000000000;
        levels[7].USDBonus        = 140;
        levels[7].revenueBonus    =  15;
        levels[7].utilityBonus    =  15;

        levels[8].personalDeposit =    25000000000000000000000;
        levels[8].firstLineVolume =   225000000000000000000000;
        levels[8].structureVolume =  2500000000000000000000000;
        levels[8].investorVolume  =  2500000000000000000000000;
        levels[8].USDBonus        = 160;
        levels[8].revenueBonus    =  15;
        levels[8].utilityBonus    =  15;

        levels[9].personalDeposit =    50000000000000000000000;
        levels[9].firstLineVolume =   500000000000000000000000;
        levels[9].structureVolume =  5000000000000000000000000;
        levels[9].investorVolume  =  5000000000000000000000000;
        levels[9].USDBonus        = 190;
        levels[9].revenueBonus    =  15;
        levels[9].utilityBonus    =  15;


        //LBonus Initialize
        LBonus[0].personalDeposit   = 0;
        LBonus[0].firstLineVolume   = 0;
        LBonus[0].mainBranchVolume  = 0;
        LBonus[0].sideBranchVolume  = 0;
        LBonus[0].USDBonus          = 0;
//        LBonus[0].revenueBonus      = 0;
//        LBonus[0].utilityBonus      = 0;

        LBonus[1].personalDeposit   = 1000000000000000000000;
        LBonus[1].firstLineVolume   = 0;
        LBonus[1].mainBranchVolume  = 1250000000000000000000;
        LBonus[1].sideBranchVolume  = 1250000000000000000000;
        LBonus[1].USDBonus          =   50000000000000000000;
//        LBonus[1].revenueBonus      = 0;
//        LBonus[1].utilityBonus      = 0;
       
/*        LBonus[2].personalDeposit   = 1000000000000000000000;
        LBonus[2].firstLineVolume   = 0;
        LBonus[2].mainBranchVolume  = 3125000000000000000000;
        LBonus[2].sideBranchVolume  = 3125000000000000000000;
        LBonus[2].USDBonus          =  100000000000000000000;
//        LBonus[2].revenueBonus      = 0;
//        LBonus[2].utilityBonus      = 0;

        LBonus[3].personalDeposit   = 1000000000000000000000;
        LBonus[3].firstLineVolume   = 0;
        LBonus[3].mainBranchVolume  = 5000000000000000000000;
        LBonus[3].sideBranchVolume  = 5000000000000000000000;
        LBonus[3].USDBonus          =  150000000000000000000;
//        LBonus[3].revenueBonus      = 0;
//        LBonus[3].utilityBonus      = 0;

        LBonus[4].personalDeposit   =  1000000000000000000000;
        LBonus[4].firstLineVolume   = 0;
        LBonus[4].mainBranchVolume  = 11750000000000000000000;
        LBonus[4].sideBranchVolume  = 11750000000000000000000;
        LBonus[4].USDBonus          =   200000000000000000000;
//        LBonus[4].revenueBonus      = 0;
//        LBonus[4].utilityBonus      = 0;

        LBonus[5].personalDeposit   =  1000000000000000000000;
        LBonus[5].firstLineVolume   = 0;
        LBonus[5].mainBranchVolume  = 18500000000000000000000;
        LBonus[5].sideBranchVolume  = 18500000000000000000000;
        LBonus[5].USDBonus          =   250000000000000000000;
//        LBonus[5].revenueBonus      = 0;
//       LBonus[5].utilityBonus      = 0;

        LBonus[6].personalDeposit   =   1000000000000000000000;
        LBonus[6].firstLineVolume   =   5000000000000000000000;
        LBonus[6].mainBranchVolume  =  25000000000000000000000;
        LBonus[6].sideBranchVolume  =  25000000000000000000000;
        LBonus[6].USDBonus          =    300000000000000000000;
//        LBonus[6].revenueBonus      = 0;
//        LBonus[6].utilityBonus      = 0;

        LBonus[7].personalDeposit   =   1300000000000000000000;
        LBonus[7].firstLineVolume   =   7250000000000000000000;
        LBonus[7].mainBranchVolume  =  40000000000000000000000;
        LBonus[7].sideBranchVolume  =  40000000000000000000000;
        LBonus[7].USDBonus          =    400000000000000000000;
//        LBonus[7].revenueBonus      = 0;
//        LBonus[7].utilityBonus      = 0;

        LBonus[8].personalDeposit   =   1600000000000000000000;
        LBonus[8].firstLineVolume   =   9500000000000000000000;
        LBonus[8].mainBranchVolume  =  56000000000000000000000;
        LBonus[8].sideBranchVolume  =  56000000000000000000000;
        LBonus[8].USDBonus          =    500000000000000000000;
//        LBonus[8].revenueBonus      = 0;
//        LBonus[8].utilityBonus      = 0;

        LBonus[9].personalDeposit   =   2000000000000000000000;
        LBonus[9].firstLineVolume   =  12000000000000000000000;
        LBonus[9].mainBranchVolume  =  75000000000000000000000;
        LBonus[9].sideBranchVolume  =  75000000000000000000000;
        LBonus[9].USDBonus          =    750000000000000000000;
//        LBonus[9].revenueBonus      = 0;
//        LBonus[9].utilityBonus      = 0;

        LBonus[10].personalDeposit   =    2650000000000000000000;
        LBonus[10].firstLineVolume   =   17250000000000000000000;
        LBonus[10].mainBranchVolume  =  130000000000000000000000;
        LBonus[10].sideBranchVolume  =  130000000000000000000000;
        LBonus[10].USDBonus          =    1000000000000000000000;
//        LBonus[10].revenueBonus      = 0;
//        LBonus[10].utilityBonus      = 0;

        LBonus[11].personalDeposit   =    3300000000000000000000;
        LBonus[11].firstLineVolume   =   22500000000000000000000;
        LBonus[11].mainBranchVolume  =  190000000000000000000000;
        LBonus[11].sideBranchVolume  =  190000000000000000000000;
        LBonus[11].USDBonus          =    1300000000000000000000;
//        LBonus[11].revenueBonus      = 0;
//        LBonus[11].utilityBonus      = 0;

        LBonus[12].personalDeposit   =    4000000000000000000000;
        LBonus[12].firstLineVolume   =   28000000000000000000000;
        LBonus[12].mainBranchVolume  =  250000000000000000000000;
        LBonus[12].sideBranchVolume  =  250000000000000000000000;
        LBonus[12].USDBonus          =    2000000000000000000000;
//        LBonus[12].revenueBonus      = 0;
//        LBonus[12].utilityBonus      = 0;

        LBonus[13].personalDeposit   =    5250000000000000000000;
        LBonus[13].firstLineVolume   =   39000000000000000000000;
        LBonus[13].mainBranchVolume  =  375000000000000000000000;
        LBonus[13].sideBranchVolume  =  375000000000000000000000;
        LBonus[13].USDBonus          =    3000000000000000000000;
//        LBonus[13].revenueBonus      = 0;
//        LBonus[13].utilityBonus      = 0;

        LBonus[14].personalDeposit   =    6700000000000000000000;
        LBonus[14].firstLineVolume   =   50000000000000000000000;
        LBonus[14].mainBranchVolume  =  500000000000000000000000;
        LBonus[14].sideBranchVolume  =  500000000000000000000000;
        LBonus[14].USDBonus          =    5000000000000000000000;
//        LBonus[14].revenueBonus      = 0;
//        LBonus[14].utilityBonus      = 0;

        LBonus[15].personalDeposit   =    8000000000000000000000;
        LBonus[15].firstLineVolume   =   60000000000000000000000;
        LBonus[15].mainBranchVolume  =  625000000000000000000000;
        LBonus[15].sideBranchVolume  =  625000000000000000000000;
        LBonus[15].USDBonus          =    7500000000000000000000;
//        LBonus[15].revenueBonus      = 0;
//        LBonus[15].utilityBonus      = 0;

        LBonus[16].personalDeposit   =   12000000000000000000000;
        LBonus[16].firstLineVolume   =  100000000000000000000000;
        LBonus[16].mainBranchVolume  =  825000000000000000000000;
        LBonus[16].sideBranchVolume  =  825000000000000000000000;
        LBonus[16].USDBonus          =   12000000000000000000000;
//        LBonus[16].revenueBonus      = 0;
//        LBonus[16].utilityBonus      = 0;

        LBonus[17].personalDeposit   =    16000000000000000000000;
        LBonus[17].firstLineVolume   =   140000000000000000000000;
        LBonus[17].mainBranchVolume  =  1050000000000000000000000;
        LBonus[17].sideBranchVolume  =  1050000000000000000000000;
        LBonus[17].USDBonus          =    18000000000000000000000;
//        LBonus[17].revenueBonus      = 0;
//        LBonus[17].utilityBonus      = 0;

        LBonus[18].personalDeposit   =    20000000000000000000000;
        LBonus[18].firstLineVolume   =   180000000000000000000000;
        LBonus[18].mainBranchVolume  =  1250000000000000000000000;
        LBonus[18].sideBranchVolume  =  1250000000000000000000000;
        LBonus[18].USDBonus          =    25000000000000000000000;
//        LBonus[18].revenueBonus      = 0;
//        LBonus[18].utilityBonus      = 0;

        LBonus[19].personalDeposit   =    30000000000000000000000;
        LBonus[19].firstLineVolume   =   290000000000000000000000;
        LBonus[19].mainBranchVolume  =  1650000000000000000000000;
        LBonus[19].sideBranchVolume  =  1650000000000000000000000;
        LBonus[19].USDBonus          =    50000000000000000000000;
//        LBonus[19].revenueBonus      = 0;
//        LBonus[19].utilityBonus      = 0;

        LBonus[20].personalDeposit   =    40000000000000000000000;
        LBonus[20].firstLineVolume   =   400000000000000000000000;
        LBonus[20].mainBranchVolume  =  2050000000000000000000000;
        LBonus[20].sideBranchVolume  =  2050000000000000000000000;
        LBonus[20].USDBonus          =    75000000000000000000000;
//        LBonus[20].revenueBonus      = 0;
//        LBonus[20].utilityBonus      = 0;

        LBonus[21].personalDeposit   =    50000000000000000000000;
        LBonus[21].firstLineVolume   =   500000000000000000000000;
        LBonus[21].mainBranchVolume  =  2500000000000000000000000;
        LBonus[21].sideBranchVolume  =  2550000000000000000000000;
        LBonus[21].USDBonus          =   150000000000000000000000;
//        LBonus[21].revenueBonus      = 0;
//        LBonus[21].utilityBonus      = 0;
*/
        Product memory tempProduct;


       // version for remix tests
/*        tempProduct = Product({
           price: 118000000000000000000,
           cost1:  48000000000000000000,
           cost2:  10000000000000000000,
           costAddress_1: address(0xfA66559CbBB70de7459d2fC3036C22358f835D30),
           costAddress_2: address(0xB40295157c6E72D8f2bA3cbeb8F4b997747C0d6F),
           itemsAmount: 30,
           lastItemID: 0,
           isActive: true
        });
*/

        // version for mainnet test of usdt transfers
        tempProduct = Product({
           price: 118000000000000000,
           cost1:  48000000000000000,
           cost2:  10000000000000000,
           costAddress_1: address(0x5C13cff82c73A73F1d3f7624804D4089D4E1CE34),
           costAddress_2: address(0x56dcF8A73994abc49d99A3E7f0478904Bd706b48),
           itemsAmount: 3128,
           lastItemID: 0,
           isActive: true
        });

        products.push(tempProduct);
        totalBuyAmounts.push(0);

        Tree memory tempTree;

        tempTree = Tree({
           fieldID: "56.05.53.082",
           yearPlanted: 2022,
           coord_1: "566433.994",
           coord_2: "4580571.642",
           price: products[0].price
        });

        treeData.push(tempTree);

       // version for mainnet tests      
       admin_mint (0xD4E0EA6108315D62A7c08c7236bec70d0e47c6E9, 1, 9, true);
       admin_mint (0x9aEcf27d32598e74C20F887FaF69e812A29a2444, 1, 7, true);
       admin_mint (0x5C13cff82c73A73F1d3f7624804D4089D4E1CE34, 2, 5, true);
       admin_mint (0x56dcF8A73994abc49d99A3E7f0478904Bd706b48, 2, 5, true);
       admin_mint (0x2293EFf3ea6A1Aade782A42F4750CcD7F514cA76, 2, 0, false);
       admin_mint (0xBA3e9DbF0df642562dD9Af0f45400110ad9b381C, 3, 0, false);

       // version for remix tests
/*     admin_mint (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 1, 9, true);
       admin_mint (0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 1, 7, true);
       admin_mint (0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 2, 5, true);
       admin_mint (0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 2, 5, true);
       admin_mint (0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 2, 0, false);
       admin_mint (0x17F6AD8Ef982297579C203069C1DbfFE4348c372, 3, 0, false);
*/
    
        storageVersion = version(); 
    }


    function version() public pure returns (uint8){
        return uint8(0);
    }


    function updateStorage() public {
        require (storageVersion < version(), "Can't upgrade. Already done!");
        storageVersion = version();
    }


    function _baseURI() internal view override returns (string memory) {
        return baseURIStr;
    }


    function supportsInterface(bytes4 interfaceId) public view override (ERC721EnumerableUpgradeable) returns (bool){
        return  super.supportsInterface(interfaceId)
                || interfaceId == type(IERC721Upgradeable).interfaceId
                || interfaceId == type(IERC721EnumerableUpgradeable).interfaceId
                || interfaceId == type(IERC721MetadataUpgradeable).interfaceId;
    }


//*************** USER FUNCTIONS ******************************* */

   // user mints BioDeposit NFT
   function mint(uint256 _parentTokenID) public whenNotPaused(){
        require(!isContract(msg.sender)/*, "Contract calls are not available"*/);
        require(balanceOf(msg.sender) == 0/*, "BioDeposit NFT is already minted for this address"*/);

        uint256 mintedTokenID = totalSupply()+1;
        _safeMint(msg.sender, mintedTokenID);

        if (mintedTokenID != 1) {
            if(_exists(_parentTokenID)){
                users[mintedTokenID].parents.push(_parentTokenID);
                users[_parentTokenID].firstLine.push(mintedTokenID);            
            }else{ 
            users[mintedTokenID].parents.push(1);
            users[1].firstLine.push(mintedTokenID);
            }
        }

        if ((mintedTokenID > 1) && (users[_parentTokenID].parents.length > 0)) {
            uint i=0;
            while (i < users[_parentTokenID].parents.length) {
                users[mintedTokenID].parents.push(users[_parentTokenID].parents[i]);
                i++;
            }
        }
    }


    // user buys products
    function Buy(uint8 _productID, uint32 _itemsAmount) public whenNotPaused(){
        uint256 _userTokenID = this.tokenIDByUser(msg.sender);
    
        require(_exists(_userTokenID)/*, "_userTokenID doesn't exist"*/);
        require(!isContract(msg.sender)/*, "Contract calls are not available"*/);
        require(ownerOf(_userTokenID) == msg.sender/*, "Not a token owner"*/);

        require(products.length > _productID/*, "Invalid productID"*/);
        require(products[_productID].isActive/*, "Product is inactive"*/);

        require((_itemsAmount > 0) && (_itemsAmount < 1000)/*, "Not a valid buy amount"*/);
        require((products[_productID].lastItemID + _itemsAmount) <= products[_productID].itemsAmount/*, "Not enough products for sale available"*/);

        uint128 amountPaid = products[_productID].price * _itemsAmount;
        uint128 usdtAmount = amountPaid;


        //receive payment
        require(usdt.balanceOf(msg.sender) >= amountPaid/*, "Not enough USDT"*/);
        require(usdt.allowance(msg.sender, address(this)) >= amountPaid/*, "Increase allowance"*/);
        uint256 balanceBefore = usdt.balanceOf(address(this));
        usdt.transferFrom(msg.sender, address(this), amountPaid);
        uint256 balanceAfter = usdt.balanceOf(address(this));
        require(balanceAfter - balanceBefore == amountPaid/*, "USDT Payment error"*/);
      
        // transfer funds
        amountPaid -= amountPaid*25/100;

        usdt.transfer(products[_productID].costAddress_1, products[_productID].cost1 * _itemsAmount);
        amountPaid -= products[_productID].cost1 * _itemsAmount;

        usdt.transfer(products[_productID].costAddress_2, products[_productID].cost2 * _itemsAmount);
        amountPaid -= products[_productID].cost2 * _itemsAmount;

        
        usdt.transfer(service_1, amountPaid/2);
        usdt.transfer(service_2, amountPaid/2);

        // updating structure
        totalBuyAmounts[_productID] += usdtAmount;
        users[_userTokenID].personalDeposit += usdtAmount;
        users[_userTokenID].tAmount += _itemsAmount;
        checkLevel(_userTokenID);
        checkLBLevel(_userTokenID);

        // processing promo
        if ((isPromoLive) && (usdtAmount >= 3000000000000000000000)){
            setUserLevel(_userTokenID, 4);
        }

        if ((isPromoLive) && (usdtAmount >= 5000000000000000000000)){
            setUserLevel(_userTokenID, 5);
        }

        // adding IDs of trees
        addItems(_userTokenID, _productID, _itemsAmount);

        if ((users[_userTokenID].parents.length == 0) || 
           (!_exists(users[_userTokenID].parents[0]))){
           return;
        }        

        // updating parents
        uint256 parentID = users[_userTokenID].parents[0];

        users[parentID].firstLineVolume += usdtAmount;
        users[parentID].structureVolume += usdtAmount;
        checkLevel(parentID);

        users[parentID].USDBalance += usdtAmount*levels[users[parentID].level].USDBonus/1000;
        totalUniLevelBonusBalance += usdtAmount*levels[users[parentID].level].USDBonus/1000;
        
        users[parentID].revenueBalance += usdtAmount*levels[users[parentID].level].revenueBonus/1000;
        users[parentID].utilityBalance += usdtAmount*levels[users[parentID].level].utilityBonus/1000;

        users[parentID].mainBranchVolume = calcMainBV(parentID);
        users[parentID].sideBranchVolume = calcSideBV(parentID);
        checkLBLevel(parentID);

        uint8 tempLevel = users[parentID].level;

        if (users[_userTokenID].parents.length > 1) {
            for (uint i=1; i < users[_userTokenID].parents.length; i++){
                users[users[_userTokenID].parents[i]].structureVolume += usdtAmount;
                checkLevel(users[_userTokenID].parents[i]);
                users[users[_userTokenID].parents[i]].mainBranchVolume = calcMainBV(users[_userTokenID].parents[i]);
                users[users[_userTokenID].parents[i]].sideBranchVolume = calcSideBV(users[_userTokenID].parents[i]);
                checkLBLevel(users[_userTokenID].parents[i]);

                if (users[users[_userTokenID].parents[i]].level > tempLevel){
                    uint128 usdReward = usdtAmount*(levels[users[users[_userTokenID].parents[i]].level].USDBonus - levels[tempLevel].USDBonus)/1000;
                    users[users[_userTokenID].parents[i]].USDBalance += usdReward;
                    tempLevel = users[users[_userTokenID].parents[i]].level;
                    totalUniLevelBonusBalance += usdReward;
                }
            }

        }
    }

    // user claims reward
    function claimReward() public whenNotPaused() {
        uint256 _tokenID = this.tokenIDByUser(msg.sender);
      
        require(_exists(_tokenID)/*, "_tokenID doesn't exist"*/);       
        require(!isContract(msg.sender)/*, "Contract calls are not available"*/);
        require(ownerOf(_tokenID) == msg.sender/*, "Not a token owner"*/);
        
        uint128 payoutAmount = users[_tokenID].USDBalance - users[_tokenID].USDBalanceWithdrawn;
       require(usdt.balanceOf(address(this)) >= payoutAmount/*, "Contract USDT Balance Low"*/);
        users[_tokenID].USDBalanceWithdrawn = users[_tokenID].USDBalance;

        if (_tokenID == 1){
            usdt.transfer(service_1, payoutAmount/2);
            usdt.transfer(service_2, payoutAmount/2);
        }else{
            usdt.transfer(msg.sender, payoutAmount);
        }
        USDTWithdrawn += payoutAmount;

//        emit RewardClaimed (_tokenID, payoutAmount);
    }



//*************** OWNER/ ADMIN FUNCTIONS ******************************* */
    
    // admin mints BioDeposit NFT for user
   function admin_mint(address _receiver, uint256 _parentTokenID, uint8 _startLevel, bool _levelProtected) public onlyOwner whenNotPaused(){

//        require(!isContract(msg.sender), "Contract calls are not available");

        require(balanceOf(_receiver) == 0/*, "BioDeposit NFT is already minted for this address"*/);

        uint256 mintedTokenID = totalSupply()+1;
        _safeMint(_receiver, mintedTokenID);

         if (mintedTokenID != 1) {
            if(_exists(_parentTokenID)){
                users[mintedTokenID].parents.push(_parentTokenID);
                users[_parentTokenID].firstLine.push(mintedTokenID);            
            }else{ 
            users[mintedTokenID].parents.push(1);
            users[1].firstLine.push(mintedTokenID);
            }
        }

        users[mintedTokenID].level = _startLevel;

        users[mintedTokenID].isLevelProtected = _levelProtected;
        users[mintedTokenID].imageHash = "";
        

        if ((mintedTokenID > 1) && (users[_parentTokenID].parents.length > 0)) {
            uint i=0;
            while (i < users[_parentTokenID].parents.length) {
                users[mintedTokenID].parents.push(users[_parentTokenID].parents[i]);
                i++;
            }
        }

    }


    // admin sets level for user. Level can not be lowered!
/*    function adminSetUserLevel(uint256 _userTokenID, uint8 _newLevel) public onlyOwner{
        require(_exists(_userTokenID), "User doesn't exist");
        require(_newLevel > users[_userTokenID].level, "Can not decrease level");
        require(_newLevel < levels.length, "Max Level is 9");

        users[_userTokenID].level = _newLevel;
        users[_userTokenID].isLevelProtected = true;
    }


    // admin updates level info
    function updateLevelInfo(uint8   _levelIndex,
                             uint128 _personalDeposit, 
                             uint128 _firstLineVolume, 
                             uint128 _structureVolume,
                             uint128 _investorVolume) public onlyOwner{

        require(_levelIndex < levels.length, "Level index is out of bounds");

        levels[_levelIndex].personalDeposit = _personalDeposit;
        levels[_levelIndex].firstLineVolume = _firstLineVolume;
        levels[_levelIndex].structureVolume = _structureVolume;
        levels[_levelIndex].investorVolume  = _investorVolume;
    }


    // admin updates LBonus info
    function updateLBonusInfo(uint8  _levelIndex,
                             uint128 _personalDeposit, 
                             uint128 _firstLineVolume, 
                             uint128 _mainBranchVolume,
                             uint128 _sideBranchVolume) public onlyOwner{

        require(_levelIndex < LBonus.length, "Level index is out of bounds");

        LBonus[_levelIndex].personalDeposit = _personalDeposit;
        LBonus[_levelIndex].firstLineVolume = _firstLineVolume;
        LBonus[_levelIndex].mainBranchVolume = _mainBranchVolume;
        LBonus[_levelIndex].sideBranchVolume  = _sideBranchVolume;
    }


    // admin adds new product
    function addProduct(uint128 _price,
                        uint128 _cost1,
                        uint128 _cost2,
                        address _costAddress_1,
                        address _costAddress_2,
                        uint128 _itemsAmount) public onlyOwner{

        Product memory tempProduct;

        tempProduct = Product({
            price: _price,
            cost1:  _cost1,
            cost2:  _cost2,
            costAddress_1: _costAddress_1,
            costAddress_2: _costAddress_2,
            itemsAmount: _itemsAmount,
            lastItemID: 0,
            isActive: false
        });

        products.push(tempProduct);
        totalBuyAmounts.push(0);
    }


    // admin updates existing product by its ID
    function updateProduct(uint16  _productIndex,
                           uint128 _price,
                           uint128 _cost1,
                           uint128 _cost2) public onlyOwner{

        require(_productIndex < products.length, "Product index is out of bounds");

        products[_productIndex].price = _price;
        products[_productIndex].cost1 = _cost1;
        products[_productIndex].cost2 = _cost2;
    }


    // admin updates available product amount by _productIndex
    function updateProductAmount(uint16 _productIndex, uint128 _newAmount) public onlyOwner{
        require(_productIndex < products.length, "Product index is out of bounds");
        products[_productIndex].itemsAmount = _newAmount;
    }


    // admin changes product status i.e. active -> inactive or vice versa
    function changeProductStatus(uint16 _productIndex) public onlyOwner{
        require(_productIndex < products.length, "Product index is out of bounds");
        products[_productIndex].isActive = !products[_productIndex].isActive;
    }

*/

/*   function changeParentID(uint256 _userTokenID, uint256 _newParentID) public onlyOwner{

        require(_userTokenID > 1, "_userTokenID cannot be <= 1");
        require(_exists(_userTokenID), "_tokenID doesn't exist");

        require(_newParentID > 1, "_newParentID cannot be <= 1");
        require(_exists(_newParentID), "_newParentID doesn't exist");

        require(users[_userTokenID].parents[0] == 1, "works only if current user's _ParentID = 1");
        require(users[_userTokenID].firstLine.length == 0, "works only if user didn't invite anybody");

        delete users[_userTokenID].parents;
        users[_userTokenID].parents.push(_newParentID);
        for (uint i=0; i < users[_newParentID].parents.length; i++){
            users[_userTokenID].parents.push(users[_newParentID].parents[i]);
        }
        users[_newParentID].firstLine.push(_userTokenID);
 //   удалить этого юзера из первой линии предыдущего спонсора     
 //  deleteFromFirstLine(1,_userTokenID);
    } */

/*
    // admin changes status of promo
    function changePromoStatus() public onlyOwner{
        isPromoLive = !isPromoLive;
    }


    // admin removes user's level protection
    function removeLevelProtection(uint256 _userTokenID) public onlyOwner{
        require(_exists(_userTokenID), "user doesn't exist");
        users[_userTokenID].isLevelProtected = false;
    }


    // admins moves unused usdt to service addresses
    function unusedBonusToService() public onlyOwner{

    }
    

    // admin moves usdt from service addreses back to contract
    function serviceToBonus() public onlyOwner{

    }



    // admin gets total buy amounts  (18 decimals)
    function getTotals() public view onlyOwner returns(uint128[] memory) {
        return totalBuyAmounts;
    }


    // admin gets total uniLevel bonus (18 decimals)
    function getTotalUniLevelBonusBalance() public view onlyOwner returns(uint256) {
        return totalUniLevelBonusBalance;
    }


    // admin gets total Leader Bonus (18 decimals)
    function getTotalLeaderBonusBalance() public view onlyOwner returns(uint256) {
        return totalLeaderBonusBalance;
    }


    // admin gets total USDT withdrawn by users (18 decimals)
    function getUSDTWithdrawn() public view onlyOwner returns(uint256) {
        return USDTWithdrawn;
    }


    // admin gets min contract usdt balance it must have at the moment to cover all payouts 
    function getBonusBalance() public view onlyOwner returns(uint256) {     
        return totalUniLevelBonusBalance + totalLeaderBonusBalance - USDTWithdrawn;
    }

*/

    function setBaseURI(string memory _baseURIStr) public onlyOwner(){
        baseURIStr = _baseURIStr;
    }



    function pause() public onlyOwner() {
        super._pause();
    }



    function unpause() public onlyOwner() {
        super._unpause();
    }

      function setUserImage(string memory _hash) public whenNotPaused(){
        uint256 _tokenID = tokenOfOwnerByIndex(msg.sender,0);
        users[_tokenID].imageHash = _hash;
    }

    function burn(uint256 _tokenId) external whenNotPaused() {
        _burn(_tokenId);
    }


    //***************** VIEW Functions ************************/
/*
    function getUserDataByID_1(uint256 _userTokenID) public view returns(uint256, uint256, uint8, uint8, uint32){
        require(_exists(_userTokenID), "user doesn't exist");
       
        uint256 _parentID = 1;
        if (users[_userTokenID].parents.length > 0){
            _parentID = users[_userTokenID].parents[0];
        }

        return(
        _userTokenID,
        _parentID,
                       
        users[_userTokenID].level,
        users[_userTokenID].lblevel,

        users[_userTokenID].tAmount
        );
    }


   function getUserDataByID_2(uint256 _userTokenID) public view returns(uint128, uint128, uint128, uint128, uint128){
        require(_exists(_userTokenID), "user doesn't exist");
      
        return(
        users[_userTokenID].personalDeposit,

        users[_userTokenID].firstLineVolume,
        users[_userTokenID].mainBranchVolume, 

        users[_userTokenID].sideBranchVolume, 
        users[_userTokenID].structureVolume
        );
    }


    function getUserDataByID_3(uint256 _userTokenID) public view returns(uint128, uint128, uint128, uint128, uint128){
        require(_exists(_userTokenID), "user doesn't exist");
       
        return(
        users[_userTokenID].revenueBalance,
        users[_userTokenID].utilityBalance,

        users[_userTokenID].USDBalance,
        users[_userTokenID].USDBalanceWithdrawn,

        users[_userTokenID].USDBalance - users[_userTokenID].USDBalanceWithdrawn
        );
    }


    function getLevelData(uint8 _levelIndex) public view returns(uint256, uint256, uint256, uint256, uint16, uint16, uint16){
        require(_levelIndex < levels.length, "Level index is out of bound");

        return(
        levels[_levelIndex].personalDeposit,
        levels[_levelIndex].firstLineVolume,
        levels[_levelIndex].structureVolume,
        levels[_levelIndex].investorVolume,

        levels[_levelIndex].USDBonus,
        levels[_levelIndex].revenueBonus,
        levels[_levelIndex].utilityBonus
        );
    }


    function getLBonusData(uint8 _levelIndex) public view returns(uint128, uint128, uint128, uint128, uint128){
        require(_levelIndex < LBonus.length, "LB Level index is out of bound");

        return(
        LBonus[_levelIndex].personalDeposit,
        LBonus[_levelIndex].firstLineVolume,
        LBonus[_levelIndex].mainBranchVolume,
        LBonus[_levelIndex].sideBranchVolume,

        LBonus[_levelIndex].USDBonus
//        LBonus[_levelIndex].revenueBonus,
//        LBonus[_levelIndex].utilityBonus
        );
    }


    function getLastIDByProduct(uint8 _productID) public view returns (uint32){
         require(_productID < products.length, "Product index is out of bounds");
       
        return products[_productID].lastItemID;
    }


    function getTreeInfoByID(uint32 _treeID) public view returns(string memory, uint16, string memory, string memory, uint256){
        require(_treeID < treeData.length, "Tree ID is out bounds");

        return(
        treeData[_treeID].fieldID,
        treeData[_treeID].yearPlanted,
        treeData[_treeID].coord_1,
        treeData[_treeID].coord_2,
        treeData[_treeID].price
        );
    }


    function getProductInfo(uint8 _productID) public view returns(uint256, uint256, uint256, uint256, uint32, bool){
        require(_productID < products.length, "Product ID is out of bounds");

        return(
            products[_productID].price,
            products[_productID].cost1,
            products[_productID].cost2,
            products[_productID].itemsAmount,
            products[_productID].lastItemID,
            products[_productID].isActive
        );
    }

*/
    function getUserParents(uint256 _userTokenID) public view returns(uint256[] memory){
        require(_exists(_userTokenID), "user doesn't exist");
        return users[_userTokenID].parents;
    }


    function getUserFirstLine(uint256 _userTokenID) public view returns(uint256[] memory){
        require(_exists(_userTokenID), "user doesn't exist");
        return users[_userTokenID].firstLine;
    }


    function getUserTrees(uint256 _userTokenID) public view returns(uint32[] memory){
        require(_exists(_userTokenID), "user doesn't exist");
        return users[_userTokenID].trees;
    }


    function tokenIDByUser(address owner) external view returns (uint256){
        if(balanceOf(owner) > 0){
            return tokenOfOwnerByIndex(owner,0);
        } else
            return 0;
    }


    //***************** INTERNAL Functions ************************/

    // checks user level
    function checkLevel(uint256 _userTokenID) private{
        bool b = true;
        uint8 i = 0;
        uint8 currentLevel = users[_userTokenID].level;

        while ((b == true) && (i<10)){


           if (((users[_userTokenID].personalDeposit >= levels[i].personalDeposit) &&
              (users[_userTokenID].firstLineVolume >= levels[i].firstLineVolume) &&
              (users[_userTokenID].structureVolume >= levels[i].structureVolume)) ||
              (users[_userTokenID].personalDeposit >= levels[i].investorVolume)){
                  users[_userTokenID].level = i;
                  i++;
                  } else {
                      b = false;
                    }
            }

        if ((users[_userTokenID].isLevelProtected) && (users[_userTokenID].level < currentLevel)){
                    
            users[_userTokenID].level = currentLevel;
        }   
    }

    // checks user LBonus level
    function checkLBLevel(uint256 _userTokenID) private{
        bool b = true;
        uint8 i = users[_userTokenID].lblevel+1;

        while ((b == true) && (i<22)){
            
            if ((users[_userTokenID].personalDeposit >= LBonus[i].personalDeposit) &&
               (users[_userTokenID].firstLineVolume >= LBonus[i].firstLineVolume) &&
               (users[_userTokenID].mainBranchVolume >= LBonus[i].mainBranchVolume) &&
               (users[_userTokenID].sideBranchVolume >= LBonus[i].sideBranchVolume)){

                   users[_userTokenID].lblevel = i;
                   users[_userTokenID].USDBalance += LBonus[i].USDBonus;  
                   totalLeaderBonusBalance += LBonus[i].USDBonus;
                   i++;
                } else {
                    b = false;
            }
        } 
    }


    // returns user's mainBranchVolume by userTokenID
    function calcMainBV(uint256 _userTokenID) private returns (uint128){
        if (users[_userTokenID].firstLine.length == 0) {
            return 0;
        }

        if (users[_userTokenID].firstLine.length == 1) {
            return users[users[_userTokenID].firstLine[0]].structureVolume + users[users[_userTokenID].firstLine[0]].personalDeposit;
        }

        if (users[_userTokenID].firstLine.length > 1) {
            uint128 max = 0;

            for (uint i=0; i < users[_userTokenID].firstLine.length; i++){
                if ((users[users[_userTokenID].firstLine[i]].structureVolume + users[users[_userTokenID].firstLine[i]].personalDeposit) > max){
                    max = users[users[_userTokenID].firstLine[i]].structureVolume + users[users[_userTokenID].firstLine[i]].personalDeposit;
                }

            }
            return max;
        }
    }


    // returns user's sideBranchVolume by userTokenID
    function calcSideBV(uint256 _userTokenID) private returns (uint128){
       
        if (users[_userTokenID].firstLine.length > 1) {
            uint128 max = 0;
            uint128 sum = 0;
            uint128 c = 0;

            for (uint i=0; i < users[_userTokenID].firstLine.length; i++){
                    c = users[users[_userTokenID].firstLine[i]].structureVolume + users[users[_userTokenID].firstLine[i]].personalDeposit;
                    sum += c;
                    if (c > max){
                        max = c;
                    }
            }
            return sum - max;
        }else return 0;
    }


    // updates user's level (only useable while promo is live)
    function setUserLevel(uint256 _userTokenID, uint8 _newLevel) private{
        require(_exists(_userTokenID)/*, "User doesn't exist"*/);
        require(_newLevel > users[_userTokenID].level/*, "Can not decrease level"*/);
        require(_newLevel < levels.length/*, "Max Level is 9"*/);

        users[_userTokenID].level = _newLevel;
        users[_userTokenID].isLevelProtected = true;
    }


    // adds tree IDs to user's trees array
    function addItems(uint256 _userTokenID, uint8 _productID, uint32 _itemsAmount) private{
        require((products[_productID].lastItemID + _itemsAmount) <= products[_productID].itemsAmount/*, "Not enough products for sale available"*/);

        uint i = 0;
        while (i < _itemsAmount){
            users[_userTokenID].trees.push(products[_productID].lastItemID);
            i++;
            products[_productID].lastItemID++;
        }
    }



/*function deleteFromFirstLine(uint256 _userTokenID, uint256 _IDToDelete) private{
uint i = 0;
bool b = true;

while (b && (i < users[_userTokenID].firstLine.length))

}
*/


/*    function _random(uint256 _min, uint256 _max, string memory seed) private view returns(uint256){
        require (_min < _max, "Random: invalid params");
        uint256 base =  uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.coinbase, seed)));
        return _min + base % (_max - _min);
    }
*/
 

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}