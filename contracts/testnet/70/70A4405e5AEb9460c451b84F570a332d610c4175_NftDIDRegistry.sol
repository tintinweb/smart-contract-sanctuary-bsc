/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: contracts/did-registry.sol

pragma solidity ^0.8.4;



contract NftDIDRegistry {

    mapping(address => mapping(uint256 => address)) public ERC1155TokenAdmins;
    mapping(address => mapping(uint256 => mapping(bytes32 => mapping(address => uint)))) public delegates;
    mapping(address => mapping(uint256 => uint)) public changed;
    mapping(address => uint) public nonce;

    modifier onlyOwner(address nft_contract, uint256 nft_id, address actor) {
        require (actor == identityOwner(nft_contract, nft_id));
        _;
    }

    event DIDDelegateChanged(
        address indexed nft_contract,
        uint256 indexed nft_id,
        bytes32 delegateType,
        address delegate,
        uint validTo,
        uint previousChange
    );

    event DIDOwnerChanged(
        address indexed nft_contract,
        uint256 indexed nft_id,
        address owner,
        uint previousChange
    );

    event DIDAttributeChanged(
        address indexed nft_contract,
        uint256 indexed nft_id,
        bytes32 name,
        bytes value,
        uint validTo,
        uint previousChange
    );

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }

    function identityOwner(address nft_contract, uint256 nft_id) public view returns (address) {
        // check here if the contract address supports IERC721 interface.
        if (_supportsERC165Interface(nft_contract, type(IERC165).interfaceId) && _supportsERC165Interface(nft_contract, type(IERC721).interfaceId))
            return IERC721(nft_contract).ownerOf(nft_id);
        if (_supportsERC165Interface(nft_contract, type(IERC165).interfaceId) && _supportsERC165Interface(nft_contract, type(IERC1155).interfaceId)) {
            return ERC1155TokenAdmins[nft_contract][nft_id];
        }
        return address(0);
    }

    function changeOwner(address nft_contract, uint256 nft_id, address actor, address newOwner) internal {
        require(_supportsERC165Interface(nft_contract, type(IERC165).interfaceId) && _supportsERC165Interface(nft_contract, type(IERC1155).interfaceId));
        require(actor == ERC1155TokenAdmins[nft_contract][nft_id] || actor == nft_contract || actor == ERC1155TokenAdmins[nft_contract][nft_id]);

        ERC1155TokenAdmins[nft_contract][nft_id] = newOwner;

        emit DIDOwnerChanged(nft_contract, nft_id, newOwner, changed[nft_contract][nft_id]);
        changed[nft_contract][nft_id] = block.number;
    }

    function changeOwner(address nft_address, uint256 nft_id, address newOwner) public {
        changeOwner(nft_address, nft_id, msg.sender, newOwner);
    }

    function changeOwnerSigned(address nft_contract, uint256 nft_id, uint8 sigV, bytes32 sigR, bytes32 sigS, address newOwner) public {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(nft_contract, nft_id)], nft_contract, nft_id, "changeOwner", newOwner));
        changeOwner(nft_contract, nft_id, checkSignature(nft_contract, nft_id, sigV, sigR, sigS, hash), newOwner);
    }

    function checkSignature(address nft_contract, uint256 nft_id, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 hash) internal returns(address) {
        address signer = ecrecover(hash, sigV, sigR, sigS);
        require(signer == identityOwner(nft_contract, nft_id));
        nonce[signer]++;
        return signer;
    }

    function validDelegate(address nft_contract, uint256 nft_id, bytes32 delegateType, address delegate) public view returns(bool) {
        uint validity = delegates[nft_contract][nft_id][keccak256(abi.encodePacked(delegateType))][delegate];
        return (validity > block.timestamp);
    }

    function addDelegate(address nft_contract, uint256 nft_id, address actor, bytes32 delegateType, address delegate, uint validity) internal onlyOwner(nft_contract, nft_id, actor) {
        delegates[nft_contract][nft_id][keccak256(abi.encodePacked(delegateType))][delegate] = block.timestamp + validity;
        uint previousChange = changed[nft_contract][nft_id];
        emit DIDDelegateChanged(nft_contract, nft_id, delegateType, delegate, block.timestamp + validity, previousChange);
        changed[nft_contract][nft_id] = block.number;
    }

    function addDelegate(address nft_contract, uint256 nft_id, bytes32 delegateType, address delegate, uint validity) public {
        addDelegate(nft_contract, nft_id, msg.sender, delegateType, delegate, validity);
    }

    function addDelegateSigned(address nft_contract, uint256 nft_id, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate, uint validity) public {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(nft_contract, nft_id)], nft_contract, "addDelegate", delegateType, delegate, validity));
        addDelegate(nft_contract, nft_id, checkSignature(nft_contract, nft_id, sigV, sigR, sigS, hash), delegateType, delegate, validity);
    }

    function revokeDelegate(address nft_contract, uint256 nft_id, address actor, bytes32 delegateType, address delegate) internal onlyOwner(nft_contract, nft_id, actor) {
        delegates[nft_contract][nft_id][keccak256(abi.encodePacked(delegateType))][delegate] = block.timestamp;
        uint previousChange = changed[nft_contract][nft_id];
        emit DIDDelegateChanged(nft_contract, nft_id, delegateType, delegate, block.timestamp, previousChange);
        changed[nft_contract][nft_id] = block.number;
    }

    function revokeDelegate(address nft_contract, uint256 nft_id, bytes32 delegateType, address delegate) public {
        revokeDelegate(nft_contract, nft_id, msg.sender, delegateType, delegate);
    }

    function revokeDelegateSigned(address nft_contract, uint256 nft_id, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate) public {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(nft_contract, nft_id)], nft_contract, "revokeDelegate", delegateType, delegate));
        revokeDelegate(nft_contract, nft_id, checkSignature(nft_contract, nft_id, sigV, sigR, sigS, hash), delegateType, delegate);
    }

    function setAttribute(address nft_contract, uint256 nft_id, address actor, bytes32 name, bytes calldata value, uint validity ) internal onlyOwner(nft_contract, nft_id, actor) {
        uint previousChange = changed[nft_contract][nft_id];
        emit DIDAttributeChanged(nft_contract, nft_id, name, value, block.timestamp + validity, previousChange);
        changed[nft_contract][nft_id] = block.number;
    }

    function setAttribute(address nft_contract, uint256 nft_id, bytes32 name, bytes calldata value, uint validity) public {
        setAttribute(nft_contract, nft_id, msg.sender, name, value, validity);
    }

    function setAttributeSigned(address nft_contract, uint256 nft_id, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes calldata value, uint validity) public {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(nft_contract, nft_id)], nft_contract, "setAttribute", name, value, validity));
        setAttribute(nft_contract, nft_id, checkSignature(nft_contract, nft_id, sigV, sigR, sigS, hash), name, value, validity);
    }

    function revokeAttribute(address nft_contract, uint256 nft_id, address actor, bytes32 name, bytes calldata value ) internal onlyOwner(nft_contract, nft_id, actor) {
        uint previousChange = changed[nft_contract][nft_id];
        emit DIDAttributeChanged(nft_contract, nft_id, name, value, 0, previousChange);
        changed[nft_contract][nft_id] = block.number;
    }

    function revokeAttribute(address nft_contract, uint256 nft_id, bytes32 name, bytes calldata value) public {
        revokeAttribute(nft_contract, nft_id, msg.sender, name, value);
    }

    function revokeAttributeSigned(address nft_contract, uint256 nft_id, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes calldata value) public {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(nft_contract, nft_id)], nft_contract, "revokeAttribute", name, value));
        revokeAttribute(nft_contract, nft_id, checkSignature(nft_contract, nft_id, sigV, sigR, sigS, hash), name, value);
    }

}