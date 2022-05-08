/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// File: contracts/interfaces/IERC721Minter.sol


pragma solidity ^0.8.0;

interface IERC721Minter {
    function mintToken(
        address recipient, 
        string memory tokenUri
    ) external returns (uint256);
}
// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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

// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
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
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: contracts/Marketplace.sol


pragma solidity ^0.8.0;








contract Marketplace is Ownable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    struct Item {
        uint256 tokenId;
        uint256 royaltyPercentage;
        address nftContract;
        address currentOwner;
        address royaltyRecipient;
        bool saleOngoing;
    }
    
    struct Trade {
        address from;
        address to;
        uint256 amount;
        uint256 price;
        uint256 tradeTime;
    }
    
    uint256 private _marketplaceFeePercentage = 25;
    uint256 private _royaltyPercentageDefault = 75;
    
    address public ERC721Minter;
    bytes32 public merkleRoot;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REGISTERED_CALLER_ROLE = keccak256("REGISTERED_CALLER_ROLE"); //Can call setter functions and modify data in this contract

    string private constant MUST_BE_TOKEN_OWNER = "You are not the token owner";
    bool public adminMint = true;
    bool public whitelistPresale = false;
    // address[] private _acceptedTokens = []; Removed for testing only
    //WETH, MATIC, USDC, DAI Mainnet addresses --- CHANGE AS REQUIRED

    mapping(uint256 => Item) private _idToItem; 
    mapping(address => bool) private _isBlacklisted;
    mapping(address => mapping(uint256 => uint256)) private _tokenToItemId;
    mapping(uint256 => string) private _idToUnlockableContent;
    mapping(uint256 => Trade[]) private _idToTradeHistory;

    modifier notListedForSale(uint256 itemId) {
        require(_idToItem[itemId].saleOngoing == false, "Item listed for sale");
        _;
    }

    modifier notBlacklisted {
        require(!_isBlacklisted[msg.sender], "User blacklisted");
        _;
    }
    
    modifier registeredCaller {
        require(hasRole(REGISTERED_CALLER_ROLE, msg.sender), "Unauthorized");
        _;
    }
    
    modifier minterSet {
        require(ERC721Minter != address(0), "Minter contract uninitialized");
        _;
    }

    //Grants default admin role to contract creator/owner
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    //@dev Transfer owner role to a different non-zero address
    //Default admin role is also transferred to new owner and revoked from previous owner
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _transferOwnership(newOwner);
    }

    //@notice Updates the merkle root
    //Caller must be admin
    function setMerkleRoot(bytes32 _merkleRoot) external onlyRole(ADMIN_ROLE) {
        merkleRoot = _merkleRoot;
    }

    //@notice Grants admin privileges to given addresses --- Owner only
    function grantAdminRole(address[] memory _admins) external onlyOwner {
        for(uint i=0; i<_admins.length; i++) {
            _grantRole(ADMIN_ROLE, _admins[i]);
        }
    }

    function isRegisteredCaller(address caller) external view returns (bool) {
        return hasRole(REGISTERED_CALLER_ROLE, caller);
    }

    //@notice Returns if an input token is in the accepted tokens list
    function isAcceptedToken(address token) external view returns (bool) {
        return true; //Accepting all tokens - FOR TESTNET 
    }

    function blacklistUser(address user) external onlyRole(ADMIN_ROLE) {
        _isBlacklisted[user] = true;
    }

    function removeUserFromBlacklist(address user) external onlyRole(ADMIN_ROLE) {
        _isBlacklisted[user] = false;
    }

    //@notice Make minting open to all --- Owner only
    function enablePublicMint() external onlyOwner {
        require(whitelistPresale, "Enable WL mint first");
        whitelistPresale = false;
    }

    //@notice Enable minting for whitelisted addresses --- Owner only
    function enableWhitelistMint() external onlyOwner {
        adminMint = false;
        whitelistPresale = true;
    }

    function getItemForSale(uint256 itemId) external view returns (bool) {
        return _idToItem[itemId].saleOngoing;
    }

    function setItemForSale(uint256 itemId, bool saleState) external registeredCaller {
        _idToItem[itemId].saleOngoing = saleState;
    }

    function getItemOwner(uint256 itemId) external view returns (address) {
        return _idToItem[itemId].currentOwner;
    } 
    
    function setItemOwner(uint256 itemId, address newOwner) external registeredCaller {
        _idToItem[itemId].currentOwner = newOwner;
    }

    function getBlacklisted(address user) external view returns (bool) {
        return _isBlacklisted[user];
    }

    function getUnlockableContent(uint256 itemId) external view returns (string memory) {
        require(msg.sender == _idToItem[itemId].currentOwner, "Only item owner can view this");
        return _idToUnlockableContent[itemId];
    }

    //@dev Sets minter contract and grants registered caller roles to standardSale, auction and fractionalSale contract addresses
    function setRegisteredContracts(
        address _minterContract,
        address _standardSaleContract,
        address _auctionContract,
        address _fractionalSaleContract
    ) external onlyRole(ADMIN_ROLE) {
        ERC721Minter = _minterContract;
        _grantRole(REGISTERED_CALLER_ROLE, _standardSaleContract);
        _grantRole(REGISTERED_CALLER_ROLE, _auctionContract);
        _grantRole(REGISTERED_CALLER_ROLE, _fractionalSaleContract);
    }

    function getMarketplaceFee() external view returns (uint256) {
        return _marketplaceFeePercentage;
    }

    //@notice Returns data about given item ID
    function getItemInfo(uint256 itemId) external view 
    returns 
    (uint256 tokenId, uint256 royaltyPercentage, address nftContract, address currentOwner, address royaltyRecipient, bool saleOngoing) {
        Item memory i = _idToItem[itemId];
        return (i.tokenId, i.royaltyPercentage, i.nftContract, i.currentOwner, i.royaltyRecipient, i.saleOngoing);
    }

    function hasBeenListed(address nft, uint256 tokenId) external view returns (bool) {
        return _tokenToItemId[nft][tokenId] == 0 ? false : true;
    }

    //@notice Creates a new trade for an item ID
    //Caller must be a registered smart contract
    function addTrade(
        uint256 itemId, 
        address _from, 
        address _to, 
        uint256 _amount,
        uint256 _price
    ) external registeredCaller {
        _idToTradeHistory[itemId].push(Trade(_from, _to, _amount, _price, block.timestamp));
    }

    function _isERC1155(address nftContract) private view returns (bool) {
        return IERC1155(nftContract).supportsInterface(0xd9b67a26);
    }

    //@notice Lists an existing NFT
    //@param Token ID of NFT
    //@param Royalty percentage multiplied by 10
    //@param Contract address of NFT collection
    //@param Royalty recipient address
    //@param Unlockable content url - optional
    //@return Item ID of the newly listed NFT
    function listItem(
        uint256 _tokenId,
        uint256 _royaltyPercentage,
        address _nftContract,
        address _royaltyRecipient,
        string memory _unlockableContent
    ) public notBlacklisted returns (uint256) {
        require(_tokenToItemId[_nftContract][_tokenId] == 0, "Item already listed");
        if(_isERC1155(_nftContract)) {
            require(IERC1155(_nftContract).balanceOf(msg.sender, _tokenId) >= 1);
        }else {
            require(msg.sender == IERC721(_nftContract).ownerOf(_tokenId), MUST_BE_TOKEN_OWNER);
        }
        
        _itemIds.increment();
        uint256 currentId = _itemIds.current();
        _tokenToItemId[_nftContract][_tokenId] = currentId;

        _idToItem[currentId] = Item({
            tokenId: _tokenId,
            royaltyPercentage: _royaltyRecipient != address(0) && _royaltyPercentage == 0 ? _royaltyPercentageDefault : _royaltyPercentage,
            nftContract: _nftContract,
            currentOwner: msg.sender,
            royaltyRecipient: _royaltyRecipient,
            saleOngoing: false
        });

        _idToUnlockableContent[currentId] = _unlockableContent;
        return currentId;
    }

    function getTradeHistory(uint256 itemId) external view returns (Trade[] memory) {
        return _idToTradeHistory[itemId];
    } 

    //@notice Mints a new NFT and then lists it on the marketplace --- For admin and WL only
    //@param Merkle proof --- verified only during WL presale
    //@param Royalty percentage multiplied by 10
    //@param Royalty recipient address
    //@param URI containing the metadata of the NFT
    //@param Unlockable content url - optional
    //@return Item ID of the newly listed NFT
    function mintThenListItemRestricted(
        bytes32[] calldata _merkleProof,
        uint256 _royaltyPercentage,
        address _royaltyRecipient,
        string memory _tokenUri,
        string memory _unlockableContent
    ) external notBlacklisted minterSet returns (uint256) {
        if(adminMint) {
            require(hasRole(ADMIN_ROLE, msg.sender), "Unauthorized");
        } else if(whitelistPresale) {
            require(MerkleProof.verify(_merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");
        }

        uint256 tokenId = IERC721Minter(ERC721Minter).mintToken(msg.sender, _tokenUri);
        uint256 itemId = listItem(tokenId, _royaltyPercentage, ERC721Minter, _royaltyRecipient, _unlockableContent);

        return itemId;
    }

    //@notice Mints a new NFT and then lists it on the marketplace --- Public
    //Only accessible after admin mint and WL mint has ended
    function mintThenListItemPublic(
        uint256 _royaltyPercentage,
        address _royaltyRecipient,
        string memory _tokenUri,
        string memory _unlockableContent
    ) external notBlacklisted minterSet returns (uint256) {
        require(!adminMint && !whitelistPresale, "Public mint not started yet");
        uint256 tokenId = IERC721Minter(ERC721Minter).mintToken(msg.sender, _tokenUri);
        uint256 itemId = listItem(tokenId, _royaltyPercentage, ERC721Minter, _royaltyRecipient, _unlockableContent);

        return itemId;
    }

    //@notice Remove a listed item from the marketplace
    //@dev Caller must be item owner or admin
    function unlistItem(uint256 itemId) external {
        require(_idToItem[itemId].saleOngoing == false);
        require(msg.sender == _idToItem[itemId].currentOwner || hasRole(ADMIN_ROLE, msg.sender));
        delete _idToItem[itemId];
    }
    
    //@dev Transfers given NFT to zero address
    //@param ID of item to burn
    //@param Amount of tokens to burn, only applicable for ERC1155
    function burnItem(uint256 itemId, uint256 amount) external {
        require(msg.sender == _idToItem[itemId].currentOwner);
        require(amount > 0);
        address _nftContract = _idToItem[itemId].nftContract;
        if(_isERC1155(_nftContract) == false) {
            require(amount == 1);
            IERC721(_nftContract).safeTransferFrom(msg.sender, address(0), _idToItem[itemId].tokenId);
        }else {
            IERC1155(_nftContract).safeTransferFrom(msg.sender, address(0), _idToItem[itemId].tokenId, amount, "");
        }
    }

    function updateItemOwner(uint256 itemId) external {
        _idToItem[itemId].currentOwner = IERC721(_idToItem[itemId].nftContract).ownerOf(_idToItem[itemId].tokenId);
    }
    
    //@notice Transfers a listed NFT to another address
    //@dev NFT contract must be ERC721, caller must be item owner and item must not be listed for sale
    //@param Item ID to gift
    //@param Address that should receive the NFT
    function giftItemERC721(
        uint256 itemId, 
        address recipient
    ) external notBlacklisted notListedForSale(itemId) {
        require(msg.sender == _idToItem[itemId].currentOwner, MUST_BE_TOKEN_OWNER);
        _idToItem[itemId].currentOwner = recipient;
        _idToTradeHistory[itemId].push(Trade(msg.sender, recipient, 1, 0, block.timestamp));

        IERC721(_idToItem[itemId].nftContract).safeTransferFrom(msg.sender, recipient, _idToItem[itemId].tokenId); //...
    }

    //@notice Transfers an amount of listed ERC1155 NFT to another address
    //@dev NFT contract must be ERC1155, caller must be item owner and item must not be listed for sale
    //@param Item ID to gift
    //@param Amount of tokens to gift
    //@param Address that should receive the NFTs
    function giftItemERC1155(
        uint256 itemId, 
        uint256 amount,
        address recipient
    ) external notBlacklisted notListedForSale(itemId) {
        require(msg.sender == _idToItem[itemId].currentOwner, MUST_BE_TOKEN_OWNER);
        _idToItem[itemId].currentOwner = recipient;
        _idToTradeHistory[itemId].push(Trade(msg.sender, recipient, amount, 0, block.timestamp));

        IERC1155(_idToItem[itemId].nftContract).safeTransferFrom(msg.sender, recipient, _idToItem[itemId].tokenId, amount, ""); //...
    }

    //@notice Change marketplace fee percentage --- Owner only
    function updateMarketplaceFee(uint256 newMarketplaceFeePercentage) external onlyOwner {
        _marketplaceFeePercentage = newMarketplaceFeePercentage;
    }
    
    //@notice Change default royalty percentage --- Admin only
    function updateDefaultRoyaltyFee(uint256 newDefaultRoyalty) external onlyRole(ADMIN_ROLE) {
        _royaltyPercentageDefault = newDefaultRoyalty;
    }

}