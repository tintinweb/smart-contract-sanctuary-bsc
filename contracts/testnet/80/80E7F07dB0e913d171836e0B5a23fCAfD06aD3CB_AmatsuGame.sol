/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/token/ERC721/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/token/ERC721/[email protected]


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


// File @openzeppelin/contracts/utils/math/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/security/[email protected]


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}


// File @openzeppelin/contracts/access/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

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
        _checkRole(role, _msgSender());
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


// File contracts/interfaces/IMaterial.sol


pragma solidity ^0.8.6;

interface IMaterial {
  function mint(address _to, uint256 _amount) external;
  function cap() external view returns (uint256 _cap);
  function burn(address to, uint256 amount) external;
  function burnSupply() external view returns(uint256);
  function burnOf(address to) external view returns(uint256);
  function circulatingSupply() external view returns (uint256 _supply);
}


// File contracts/interfaces/IEconomyGame.sol


pragma solidity ^0.8.6;

interface IEconomyGame {
  function battlePowerBy(uint256 key) external view returns(uint256 slash, uint256 heavy, uint256 strike, uint256 tech, uint256 magic, uint256 total, bool attack);
  function productionEfficiencyBy(uint256 key) external view returns(uint256 ore, uint256 stone,	uint256 wood, uint256 fiber,	uint256 hide, bool attack);
  
  function kuniPower(uint256 _tokenId, bool attack, bool addAttack) external returns (uint256 slash, uint256 heavy, uint256 strike, uint256 tech, uint256 magic, uint256 total);
  function kuniPowerTeam(uint256[] memory _tokenIds, bool attack, bool addAttack) external returns (uint256 slash, uint256 heavy, uint256 strike, uint256 tech, uint256 magic, uint256 total);
  
  function productionEfficiency(uint256 _tokenId, bool _defendOrAttack, bool _hasAttack) view external returns (uint256 ore, uint256 stone, uint256 wood, uint256 fiber, uint256 hide);
  function productionEfficiencyTeam(uint256[] memory  _tokenIds, bool _defendOrAttack, bool _hasAttack) view external returns (uint256 ore, uint256 stone, uint256 wood, uint256 fiber, uint256 hide);

  function niohPower(uint256 stage, uint256 difficulty) external view returns(uint256);
  function advantagePoint(uint256[] memory  _tokenIds, address kuniItem, uint256[][] memory items, uint256 stage, uint256 difficulty, address player, uint256 bonusPercent) external view returns(uint256 apKuni, uint256 apNioh, bool win);
  function materialStas(address _material, uint256 k) external view returns(uint256 slash, uint256 heavy, uint256 strike, uint256 tech, uint256 magic);
  function materialStasBatch(address[] memory _materials, uint256[] memory qty) external view returns(uint256 slash, uint256 heavy, uint256 strike, uint256 tech, uint256 magic);
  function toCraftNameCat(uint256[] memory items, uint256 attack) external view returns(string memory name, uint256 cat);
  // function toCraftEL(uint256 burnTotal) external view returns(uint256 el);
  // function currentCap(uint256 el) external view returns(uint256);
  function rewardNIOH(uint256 stage, bool win) external view returns(uint256);
  // new_bonus = current_bonus + (max_bonus - current_bonus)*k
  function battleBonusInc(uint256 cBonus) external view returns(uint256 value, uint decimals);
  function expertisePointInc(uint256 cap) external view returns(uint256 value, uint decimals);
  function currentCap(uint256 cap) external view returns(uint256);  
  function battlePowerBonus(uint256[] memory _tokenIds, address kuniItem, uint256[][] memory items, uint256 bonus) external view returns(uint256 power);
  function geDifficulty(address[] memory adds) external view returns(uint256);
}


// File contracts/interfaces/IERC721Mint.sol


pragma solidity ^0.8.6;

interface IERC721Mint {

  struct Meta {
    string name;
    uint256 slash;
    uint256 heavy;
    uint256 strike;
    uint256 tech;
    uint256	magic;
    uint256 cat; // 1: weapon, 2: head, 3: body, 4: eye, 5: hand
  }

  function safeMint(address to, string memory name, uint256[] memory meta) external;
  function currentId() external view returns (uint256);
  function getMeta(uint256 tokenId) view external returns(string memory name, uint256 slash, uint256 heavy, 
    uint256 strike, uint256 tech, uint256	magic, uint256 cat
  );
}


// File contracts/IAmatsuGame.sol


pragma solidity ^0.8.6;

interface IAmatsuGame {

  /* ========== EVENTS ========== */
  event Deposit(address indexed user, uint256 indexed amount, uint256 indexed kuni);
  event Claim(address indexed user);
  event Withdraw(address indexed user, uint256 indexed amount, uint256 indexed kuni);
  event Fighting(address indexed user, uint256 stage, uint256 apKuni, uint256 apNioh, bool win);
  event Craft(address indexed user, uint256 indexed tokenId);

  event ASKScholar(address indexed owner, uint256 tokenId, uint256 nioh, uint256 material);
  event CancelScholar(address indexed sender, uint256 tokenId);
  event ClaimScholar(address indexed sender, uint256 tokenId);
  event AcceptScholar(address indexed renting, uint256 tokenId);

  /* ========== FUNCTIONS ========== */

  function deposit(uint256 amount, uint256[] memory tokenIds) external;
  function withdraw() external;
  function claim() external;
  function fighting(uint256[] memory tokenIds, uint256[][] memory items) external;
  function craft(address[] memory materials, uint256[] memory qty, uint256 attack) external;
  function stageOf(address sender) external view returns(uint256);
  function battleBonusOf(address sender) external view returns(uint256);
  function currentCapOf(address sender) external view returns(uint256);


  function askScholar(uint256 tokenId, uint256 nioh, uint256 material) external;
  function claimScholar(uint256 tokenId) external;
  function cancelScholar(uint256 tokenId) external;
  function acceptScholar(uint256 tokenId) external;

  struct MaterialInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 rewardDebtAtBlock;
  }

  struct PoolInfo {
    address token;
    uint256 ratio;  // ratio will per 1e4
    uint256 supply; // How many allocation supply assigned to this pool. KUNIs to distribute per block.
    uint256 lastRewardBlock;  // Last block number that Materials distribution occurs.  
    uint256 accRewardPerShare; // Accumulated Rewards per share, times 1e12. See below.
  }

  struct ScholarInfo {
    address owner;
    uint256 nioh;
    uint256 material;
  }
}


// File contracts/commons/IVault.sol


pragma solidity ^0.8.6;

interface IVault {
    function mint(address _token, uint256 _amount) external;
    function send(address _token, address _to, uint256 _amount) external;
    function emergencyWithdraw(address _token, address payable _to) external; 
}


// File contracts/AmatsuGame.sol



pragma solidity ^0.8.6;


// import "hardhat/console.sol";












contract AmatsuGame is AccessControl, IERC721Receiver, Pausable, ReentrancyGuard, IAmatsuGame {

  using SafeMath for uint256;

  uint256[] public REWARD_MULTIPLIER = [1, 0];
  uint256[] public HALVING_AT_BLOCK;
  uint256 public NUM_OF_BLOCK_PER_DAY = 28800;
  uint256 public FINISH_BONUS_AT_BLOCK;
  uint256 public START_BLOCK;
  uint256 public MAGIC_NUM = 1e12;
  // Type list owner
  // renting
  uint public RENT = 0;
  // Renting out
  uint public RENT_OUT = 1;
  // SCHOLARSHIP
  uint public RENT_ALL = 2;
  // Player
  uint public GAME = 3;

  // Address token
  address public kuniSaru;  // Kunisaru address
  address public kuniItem;  // Kunisaru address
  address public kuniToken; // $kuni address
  address public oreToken;  // $ore address
  address public stoneToken;
  address public woodToken;
  address public fiberToken;
  address public hideToken;


  // type => owner => index => tokenId
  mapping(uint => mapping(address => mapping(uint256 => uint256))) public ownerTokens;
  // type => tokenId => idndex
  mapping(uint => mapping(uint256 => uint256)) public ownedIndex;
  // type => owner => total
  mapping(uint => mapping(address => uint256)) public saruBalanceOf;

  // Scholarship
  mapping(uint256 => address) public renting;
  mapping(uint256 => ScholarInfo) public rentingOut;
  
  // material address => tokenId => info
  mapping(address => mapping(uint256 => MaterialInfo)) materialInfo;
  // kuni address => user address => info
  mapping(address => mapping(address => MaterialInfo)) userInfo;
  // material address => pool
  mapping(address => PoolInfo) public pools;

  // 
  IEconomyGame private eco;
  address      private rewardVault;

  // craft current cap
  mapping (address=>uint256) public currentCap;
  // material token => ratio
  mapping(address => uint256) private materialsToken;

  // Fighting PvE
  // // user => saruId => status
  // mapping(address => mapping(uint256=>bool)) private _existsKuniItem;
  // // user => saruId => cat
  // mapping(address=>mapping(uint256=>uint256)) private _itemAttached;
  // user => stage
  mapping (address=>uint256) public stages;
  // address = nioh point
  mapping (address=>uint256) public niohPoint;
  mapping (address => uint256) public battleBonus;
  uint256 public difficulty = 5e10; // 0,005

  uint256 public STAMINA = 4795;
  // tokenId => stamina
  mapping(uint256 => uint256) public lastStamina;


  constructor(
    address kuni,
    address saruAddr,
    address rVault,
    address _eco,
    address _kuniItem,
    uint256 _startBlock,
    uint256 _halvingAfterBlock
  ) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    kuniSaru    = saruAddr;
    kuniToken   = kuni;
    eco         = IEconomyGame(_eco);
    rewardVault = rVault;
    kuniItem    = _kuniItem;

    START_BLOCK  = _startBlock == 0 ? block.number : _startBlock;

    for (uint256 i = 0; i < REWARD_MULTIPLIER.length - 1; i++) {
      uint256 halvingAtBlock = _halvingAfterBlock.mul(i + 1).add(_startBlock);
      HALVING_AT_BLOCK.push(halvingAtBlock);
    }
    FINISH_BONUS_AT_BLOCK = _halvingAfterBlock.mul(REWARD_MULTIPLIER.length - 1).add(_startBlock);
    HALVING_AT_BLOCK.push(type(uint256).min);
  }

  function deposit(uint256 amount, uint256[] memory tokenIds) external override {
    _deposit(msg.sender, amount, tokenIds);
  }

  function withdraw() external override whenNotPaused nonReentrant  {
    _updatePool(kuniToken);
    updatePools();
    harvest(true);
  }

  function claim() external override whenNotPaused nonReentrant  {
    _updatePool(kuniToken);
    updatePools();
    harvest(false);
  }

  function fighting(uint256[] memory tokenIds, uint256[][] memory items) external override whenNotPaused nonReentrant  {
    require(tokenIds.length > 0 && tokenIds.length <= 6, "Amatsu: Please select NFT");
    // updatePools();
    _updatePool(kuniToken);
    uint256 stage = stages[msg.sender];
    if (stage == 0) {
      stage = 1;
    }
    uint256 apKuni; uint256 apNioh; bool win;
    // uint256 apKuni; uint256 apNioh; bool win;
    (apKuni, apNioh, win) = _fighting(msg.sender, tokenIds, items, stage);
    if (win) {
      stages[msg.sender] = stage.add(1);
    }

    emit Fighting(msg.sender, stage, apKuni, apNioh, win);
  }

  function craft(address[] memory materials, uint256[] memory qty, uint256 attack) external override {
    _craft(materials, qty, attack);
  }

  function stageOf(address sender) external view override returns(uint256) {
    return stages[sender];
  }

  function battleBonusOf(address sender) external view override returns(uint256) {
    return battleBonus[sender];
  }

  function currentCapOf(address sender) external view override returns(uint256) {
    return currentCap[sender];
  }

  function askScholar(uint256 tokenId, uint256 nioh, uint256 material) external override {
    require(nioh > 0 && nioh <= 100, "Scholarship: NIOH > 0 && NIOH <= 100");
    require(material > 0 && material <= 100, "Scholarship: MATERIAL > 0 && MATERIAL <= 100");
    rentingOut[tokenId] = ScholarInfo(msg.sender, nioh, material);
    _transfer(msg.sender, address(this), tokenId, RENT_OUT, true);
    emit ASKScholar(msg.sender, tokenId, nioh, material);
  }

  function acceptScholar(uint256 tokenId) external override whenNotPaused nonReentrant {
    require(renting[tokenId] == address(0x0), "Amatsu [Accept Scholar]: This NFT has been loaned out.");
    require(rentingOut[tokenId].owner != address(0x0), 'Amatsu [Accept Scholar]: This NFT has not been loaned out.');
    require(rentingOut[tokenId].owner != msg.sender, 'Amatsu [Accept Scholar]: Unable to process request.');
    updatePools();
    _addToken(msg.sender, RENT, tokenId);
    renting[tokenId] = msg.sender;
    _updateMaterialBy(tokenId, userInfo[kuniToken][msg.sender].amount);
    emit AcceptScholar(msg.sender, tokenId);
  }

  function claimScholar(uint256 tokenId) external override whenNotPaused nonReentrant  {
     _updatePool(kuniToken);
    _claimScholar(msg.sender, tokenId, false);
  }

  function _claimScholar(address sender, uint256 tokenId, bool isWithdraw) internal {
    ScholarInfo storage info = rentingOut[tokenId];
    require(renting[tokenId] == sender || info.owner == sender, 'Amatsu [Claim Scholar]: Unable to process request');
    updatePools();
    if (sender == info.owner) {
      sender = renting[tokenId];
    }
    _harvestWithMaterialTokenId(sender, tokenId, isWithdraw, info.material, info.owner);
  }

  function cancelScholar(uint256 tokenId) external override whenNotPaused nonReentrant  {
    _updatePool(kuniToken);
    _claimScholar(msg.sender, tokenId, true);
    _cancel(msg.sender, tokenId);
  }

  function _cancel(address sender, uint256 tokenId) internal whenNotPaused {
    if (rentingOut[tokenId].owner == sender) {
      _transfer(address(this), sender, tokenId, RENT_OUT, true);
      delete rentingOut[tokenId];
    }
    
    if (renting[tokenId] != address(0x0)) {
      _removeToken(renting[tokenId], RENT, tokenId);
      delete renting[tokenId];
    }
  }

  // ============== PRIVATES Funs ==============

  function _getReward2Share(address _token) internal view returns (uint256) {
    PoolInfo storage pool = pools[_token];
    uint256 rewardPerShare = pool.accRewardPerShare;
    uint256 lpSupply = pool.supply;
    if (block.number > pool.lastRewardBlock && lpSupply > 0) {
      uint256 reward = getPoolReward(_token, pool.lastRewardBlock, block.number, pool.ratio);
      return rewardPerShare.add(reward.mul(MAGIC_NUM).div(lpSupply));
    }
    return 0;
  }

  function _pendingKuniReward(address _user) internal view returns (uint256) {
    uint256 share = _getReward2Share(kuniToken);
    if (share == 0) {
      return 0;
    }
    MaterialInfo storage user = userInfo[kuniToken][_user];
    return niohPoint[_user].mul(share).div(MAGIC_NUM).sub(user.rewardDebt);
  }


  function _pendingMaterialReward(address _token, uint256 tokenId, address _user) internal view returns (uint256) {
    MaterialInfo storage saru = materialInfo[_token][tokenId];
    uint256 rewardPerShare = _getReward2Share(_token);
    if (rewardPerShare == 0) {
      return 0;
    }

    uint256 total = saru.amount.mul(rewardPerShare).div(MAGIC_NUM).sub(saru.rewardDebt);
    ScholarInfo storage info = rentingOut[tokenId];
    if (renting[tokenId] != address(0x0)) {
      if (_user == info.owner) {
        return total.mul(info.material).div(100);
      }

      if (_user == renting[tokenId]) {
        return total.sub(total.mul(info.material).div(100));
      }
    }
    return total;
  }

  function pendingReward(address token, address _user) external view returns(uint256 totalReward) {
    if (token == kuniToken) {
      totalReward = _pendingKuniReward(_user);
    } else {
      for (uint256 inx = saruBalanceOf[GAME][msg.sender]; inx > 0; inx--) {
        uint256 tokenId = ownerTokens[GAME][msg.sender][inx - 1];
        totalReward = totalReward.add(_pendingMaterialReward(token, tokenId, _user));
      }

      for (uint256 inx = saruBalanceOf[RENT][msg.sender]; inx > 0; inx--) {
        uint256 tokenId = ownerTokens[RENT][msg.sender][inx - 1];
        totalReward = totalReward.add(_pendingMaterialReward(token, tokenId, _user));
      }

      for (uint256 inx = saruBalanceOf[RENT_OUT][msg.sender]; inx > 0; inx--) {
        uint256 tokenId = ownerTokens[RENT_OUT][msg.sender][inx-1];
        if (renting[tokenId] != address(0x0)) {
          totalReward = totalReward.add(_pendingMaterialReward(token, tokenId, _user));
        }
      }
    }
  }

  function pendingRewardBy(uint256 tokenId, address materialToken, address sender) external view returns(uint256) {
    return _pendingMaterialReward(materialToken, tokenId, sender);
  }

  function _updateDifficulty() internal {
    address[] memory tokens = new address[](5);
    tokens[0] = oreToken;
    tokens[1] = stoneToken;
    tokens[2] = woodToken;
    tokens[3] = fiberToken;
    tokens[4] = hideToken;
    difficulty = eco.geDifficulty(tokens);
  }

  function _SaruValid(address sender, uint256[] memory tokenIds) internal returns(bool) {
    for (uint256 index = 0; index < tokenIds.length; index++) {
      uint256 tokenId = ownerTokens[GAME][sender][ownedIndex[GAME][tokenIds[index]]];
      require(tokenId == tokenIds[index] || renting[tokenIds[index]] == sender, 'Amatsu: Your not is owner');
      require(lastStamina[tokenIds[index]] == 0 || block.number - lastStamina[tokenIds[index]] >= STAMINA, "Not enough stamina. Please select other character!");
      lastStamina[tokenIds[index]] = block.number;
    }
    return true;
  }

  function _ItemsValid(address sender, uint256[][] memory items) internal view {
    uint256 len = items.length;
    if (len == 0) {
      return;
    }
    uint256 slash;
    uint256 heavy;
    uint256 strike;
    uint256 tech;
    uint256	magic;
    for (uint256 i = 0; i < len; i++) {
      slash  = equipmentCorrect(sender, items[i][0], 1, slash);
      heavy  = equipmentCorrect(sender, items[i][1], 2, heavy);
      strike = equipmentCorrect(sender, items[i][2], 3, strike);
      tech   = equipmentCorrect(sender, items[i][3], 4, tech);
      magic  = equipmentCorrect(sender, items[i][4], 5, magic);
    }
  }

  function equipmentCorrect(address owner, uint256 tokenId, uint256 cat, uint256 item) internal view returns(uint256) {
    if (tokenId > 0) {
      require(IERC721(kuniItem).ownerOf(tokenId) == owner, 'Amatsu: Your not is owner');
      uint256 _cat;
      (,,,,,,_cat) = IERC721Mint(kuniItem).getMeta(tokenId);
      require(_cat == cat, "Amatsu: Unable to process request");
      if (item == 0) {
        item = tokenId;
      } else {
        require(item != tokenId, 'Amatsu: Unable to process request');
      }
    }

    return item;
  }


  function _fighting(address sender, uint256[] memory sarus, uint256[][] memory items, uint256 stage) internal returns(uint256 apKuni, uint256 apNioh, bool win) {
    // check owner
    _SaruValid(sender, sarus);
    _ItemsValid(sender, items);
    _updateDifficulty();
    uint256 _bat = battleBonus[sender];
    (apKuni, apNioh, win) = eco.advantagePoint(sarus, kuniItem, items, stage, difficulty, sender, _bat);
    uint256 _nioh = eco.rewardNIOH(stage, win).mul(100);
    PoolInfo storage pool = pools[kuniToken];
    // UserInfo storage user = userInfo[kuniToken][sender];
    // user.rewardDebt = user.rewardDebt.add(_nioh.mul(pool.accRewardPerShare).div(MAGIC_NUM));
    pool.supply = pool.supply.add(_nioh);
    uint256 mySelf = _nioh;
    uint256 totalNioh = sarus.length * 100;
    for (uint256 inx = 0; inx < sarus.length; inx++) {
      uint256 tokenId = sarus[inx];
      ScholarInfo storage info = rentingOut[tokenId];
      if (info.owner != address(0x0)) {
        MaterialInfo storage user = userInfo[kuniToken][info.owner];
        uint256 newNioh = _nioh.mul(info.nioh).div(totalNioh);
        niohPoint[info.owner] = niohPoint[info.owner].add(newNioh);
        user.rewardDebt = user.rewardDebt.add(newNioh.mul(pool.accRewardPerShare).div(MAGIC_NUM));
        mySelf = mySelf.sub(newNioh);
      }
    }
    
    updateBattleBonus(sender, mySelf, pool.accRewardPerShare);
  }

  function updateBattleBonus(address sender, uint256 newNioh, uint256 share) internal {
    MaterialInfo storage user = userInfo[kuniToken][sender];
    if (newNioh >= 0) {
      niohPoint[sender] = niohPoint[sender].add(newNioh);
      user.rewardDebt = user.rewardDebt.add(newNioh.mul(share).div(MAGIC_NUM));
    }
    uint256 bonus = battleBonus[sender];
    (bonus, ) = eco.battleBonusInc(bonus);
    battleBonus[sender] = bonus;
  }

  function _craft(address[] memory materialTokens, uint256[] memory amounts, uint256 attack) internal {
    require(materialTokens.length > 0, 'Amatsu: Unable to process request!');
    uint256 total = 0;
    for (uint256 index = 0; index < materialTokens.length; index++) {
      // if (materials[_materials[index]] > 0) {
      if (materialsToken[materialTokens[index]] > 0 && amounts[index].mod(1e18) == 0) {
        total = total.add(amounts[index]);
        IMaterial(materialTokens[index]).burn(msg.sender, amounts[index]);
      } else {
        revert('Amatsu: Material not support or qty low!');
      }
    }

    uint256 cap = eco.currentCap(currentCap[msg.sender]);
    require(total >= 1e18 && total <= cap.mul(1e18), 'Amatsu: Materials Limit reached. Please reduce the number of materials');

    uint256 slash; uint256 heavy; uint256 strike; uint256 tech; uint256 magic;
    (slash, heavy, strike, tech, magic) = eco.materialStasBatch(materialTokens, amounts);
    uint256[] memory stats = new uint256[](6);// = [slash, heavy, strike, tech, magic];
    stats[0] = slash;
    stats[1] = heavy;
    stats[2] = strike;
    stats[3] = tech;
    stats[4] = magic;
    string memory name;
    (name, attack) = eco.toCraftNameCat(stats, attack);
    stats[5] = attack;
  
    uint256 tokenId = IERC721Mint(kuniItem).currentId();
    IERC721Mint(kuniItem).safeMint(msg.sender, name, stats);
    uint256 elCap;
    (elCap, ) = eco.expertisePointInc(currentCap[msg.sender]);
    currentCap[msg.sender] = elCap;
    emit Craft(msg.sender, tokenId);
  }

  function harvest(bool isWithdraw) internal {
    for (uint256 inx = saruBalanceOf[GAME][msg.sender]; inx > 0; inx--) {
      uint256 tokenId = ownerTokens[GAME][msg.sender][inx - 1];
      _harvestWithMaterialTokenId(msg.sender, tokenId, isWithdraw, 0, address(0x0));
      if (isWithdraw) {
        _transfer(address(this), msg.sender, tokenId, GAME, true);
      }
    }

    for (uint256 inx = saruBalanceOf[RENT][msg.sender]; inx > 0; inx--) {
      uint256 tokenId = ownerTokens[RENT][msg.sender][inx - 1];
      _claimScholar(msg.sender, tokenId, false);
      // _claimScholar(msg.sender, tokenId, isWithdraw);
      // _cancel(msg.sender, tokenId);
    }

    for (uint256 inx = saruBalanceOf[RENT_OUT][msg.sender]; inx > 0; inx--) {
      uint256 tokenId = ownerTokens[RENT_OUT][msg.sender][inx-1];
      if (renting[tokenId] != address(0x0)) {
        _claimScholar(msg.sender, tokenId, false);
        // _claimScholar(msg.sender, tokenId, isWithdraw);
        // _cancel(msg.sender, tokenId);
      }
    }

    MaterialInfo storage userKuni = userInfo[kuniToken][msg.sender];
    if (isWithdraw) {
      // KUNI diposit
      if (userKuni.amount > 0) {
        IERC20(kuniToken).transferFrom(address(this), msg.sender, userKuni.amount);
      }
      userKuni.amount = 0;
    }
    _harvestKuni(msg.sender);
  }

  function _harvestWithMaterialTokenId(address sender, uint256 tokenId, bool isWithdraw, uint256 mPercent, address owner) internal {
    _harvestWithTokenId(sender, oreToken, tokenId, isWithdraw, mPercent, owner);
    _harvestWithTokenId(sender, stoneToken, tokenId, isWithdraw, mPercent, owner);
    _harvestWithTokenId(sender, woodToken, tokenId, isWithdraw, mPercent, owner);
    _harvestWithTokenId(sender, fiberToken, tokenId, isWithdraw, mPercent, owner);
    _harvestWithTokenId(sender, hideToken, tokenId, isWithdraw, mPercent, owner);
  }

  function _harvestWithTokenId(address sender, address token, uint256 tokenId, bool isWithdraw, uint256 mPercent, address owner) internal {
    MaterialInfo storage saruInfo = materialInfo[token][tokenId];
    PoolInfo storage pool = pools[token];
    if (saruInfo.amount > 0) {
      uint256 pending = saruInfo.amount.mul(pool.accRewardPerShare).div(MAGIC_NUM).sub(saruInfo.rewardDebt);
      uint256 masterBal = IERC20(token).balanceOf(address(rewardVault));
      if (pending > masterBal) {
        pending = masterBal;
      }
      if(pending > 0) {
        uint256 shareAmount = 0;
        if (owner != address(0x0) && mPercent > 0) { // owner
          shareAmount = pending.mul(mPercent).div(100);
          IVault(rewardVault).send(token, owner, shareAmount);
        }
        IVault(rewardVault).send(token, sender, pending.sub(shareAmount));
        saruInfo.rewardDebtAtBlock = block.number;
      }
      if (isWithdraw) {
        pool.supply = pool.supply.sub(saruInfo.amount);
        saruInfo.amount = 0;
      }
      saruInfo.rewardDebt = saruInfo.amount.mul(pool.accRewardPerShare).div(MAGIC_NUM);
    }
  }

  function _harvestKuni(address sender) internal {
    MaterialInfo storage user = userInfo[kuniToken][sender];
    PoolInfo storage pool = pools[kuniToken];
    if (user.rewardDebtAtBlock == block.number) {
      return;
    }
    if (niohPoint[sender] > 0) {
      uint256 pendingKuni = niohPoint[sender].mul(pool.accRewardPerShare).div(MAGIC_NUM).sub(user.rewardDebt); // overload
      uint256 masterKuniBal = IERC20(kuniToken).balanceOf(address(rewardVault));

      if (pendingKuni > masterKuniBal) {
        pendingKuni = masterKuniBal;
      }
      
      if(pendingKuni > 0) {
        IVault(rewardVault).send(kuniToken, sender, pendingKuni);
        user.rewardDebtAtBlock = block.number;
      }
      pool.supply = pool.supply.sub(niohPoint[sender]);
      niohPoint[sender] = 0;
      user.rewardDebt = niohPoint[sender].mul(pool.accRewardPerShare).div(MAGIC_NUM);
    }
  }

  function updatePools() internal {
    _updatePool(oreToken);
    _updatePool(stoneToken);
    _updatePool(woodToken);
    _updatePool(fiberToken);
    _updatePool(hideToken);
  }

  function _updatePool(address _token) internal {
    PoolInfo storage pool = pools[_token];
    if (block.number <= pool.lastRewardBlock) {
      return;
    }
    if (pool.supply == 0) {
      pool.lastRewardBlock = block.number;
      return;
    }
    
    uint256 reward = getPoolReward(_token, pool.lastRewardBlock, block.number, pool.ratio);
    if (reward > 0) {
      IVault(rewardVault).mint(_token, reward);
    }

    pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(MAGIC_NUM).div(pool.supply));
    pool.lastRewardBlock = block.number;
  }

  function _deposit(address sender, uint256 kuniAmount, uint256[] memory tokenIds) internal whenNotPaused nonReentrant  {
    require(kuniAmount > 0 || tokenIds.length > 0, 'Amatsu: Invalid input!');
    updatePools();
    MaterialInfo storage userKuni = userInfo[kuniToken][sender];
    if (userKuni.amount == 0) {
      userKuni.rewardDebtAtBlock = block.number;
    }

    // update old token
    if (kuniAmount > 0) {
      IERC20(kuniToken).transferFrom(sender, address(this), kuniAmount);
      for (uint256 inx = 0; inx < saruBalanceOf[GAME][sender]; inx++) {
        _updateMaterialBy(ownerTokens[GAME][sender][inx], kuniAmount);
      }

      for (uint256 inx = 0; inx < saruBalanceOf[RENT][sender]; inx++) {
        _updateMaterialBy(ownerTokens[RENT][sender][inx], kuniAmount);
      }
    }

    userKuni.amount = userKuni.amount.add(kuniAmount);
    // new deposit
    for (uint256 inx = 0; inx < tokenIds.length; inx++) {
      _updateMaterialBy(tokenIds[inx], userKuni.amount);
      _transfer(sender, address(this), tokenIds[inx], GAME, true);
    }
  }

  function _updateMaterialBy(uint256 tokenId, uint256 amount) internal {
    uint256 ore; uint256 stone; uint256 wood; uint256 fiber; uint256 hide;
    (ore, stone, wood, fiber, hide) = eco.productionEfficiency(tokenId, false, true);
      _materialDeposit(oreToken, tokenId, amount, ore);
      _materialDeposit(stoneToken, tokenId, amount, stone);
      _materialDeposit(woodToken, tokenId, amount, wood);
      _materialDeposit(fiberToken, tokenId, amount, fiber);
      _materialDeposit(hideToken, tokenId, amount, hide);      
  }

  function _materialDeposit(address token, uint256 tokenId, uint256 kuni, uint256 pEfficiency) internal {
    uint256 _amount = kuni.div(1e6).mul(pEfficiency).div(MAGIC_NUM);
    MaterialInfo storage saruInfo = materialInfo[token][tokenId];
    PoolInfo storage pool = pools[token];
    if (saruInfo.amount == 0) {
      saruInfo.rewardDebtAtBlock = block.number;
    }
    saruInfo.amount = saruInfo.amount.add(_amount);
    pool.supply = pool.supply.add(_amount);
    saruInfo.rewardDebt = saruInfo.rewardDebt.add(_amount.mul(pool.accRewardPerShare).div(MAGIC_NUM));
  }

  function getRewardPerBlock(address token, uint256 ratioK) internal view returns(uint256) {
    return IMaterial(token).circulatingSupply().mul(ratioK).div(1e4).div(NUM_OF_BLOCK_PER_DAY);
  }

  function getPoolReward(address token, uint256 _from, uint256 _to, uint256 ratioK) internal view returns (uint256 reward) {
    uint256 multiplier = getMultiplier(_from, _to);
    uint256 rewardPerBlock = getRewardPerBlock(token, ratioK);
    reward = multiplier.mul(rewardPerBlock);
    uint256 amountCanMint = IMaterial(token).circulatingSupply();

    if (amountCanMint < reward) {
      reward = amountCanMint;
    }  
  }

  function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
    uint256 result = 0;
    if (_from < START_BLOCK) return 0;

    for (uint256 i = 0; i < HALVING_AT_BLOCK.length; i++) {
      uint256 endBlock = HALVING_AT_BLOCK[i];

      if (_to <= endBlock) {
        uint256 m = _to.sub(_from).mul(REWARD_MULTIPLIER[i]);
        return result.add(m);
      }

      if (_from < endBlock) {
        uint256 m = endBlock.sub(_from).mul(REWARD_MULTIPLIER[i]);
        _from = endBlock;
        result = result.add(m);
      }
    }
    return result;
  }

  // ============== CONFIG FUNCS ===============
    // ore, stone, cotton, lumber, leather
  // ore, stone, fiber,  wood,   hide
  // ratios per 1e4
  function setMaterialBatch(address[] memory tokens, uint256[] memory ratios) external onlyRole(DEFAULT_ADMIN_ROLE) {
    // require(tokens.length == 5, 'Size is 5');
    for (uint256 inx = 0; inx < tokens.length; inx++) {
      pools[tokens[inx]] = PoolInfo(tokens[inx], ratios[inx], 0, block.number, 0);
      materialsToken[tokens[inx]] = ratios[inx];
      IERC20(tokens[inx]).approve(address(this), type(uint256).max);
    }

    oreToken = tokens[0];
    stoneToken = tokens[1];
    fiberToken = tokens[2];
    woodToken = tokens[3];
    hideToken = tokens[4];
  }

  function setKuniToken(address _kuni, uint256 ratioKuni) external onlyRole(DEFAULT_ADMIN_ROLE) {
    pools[_kuni].token = _kuni;
    pools[_kuni].ratio = ratioKuni;
    IERC20(_kuni).approve(address(this), type(uint256).max);
  }

  function setSaruToken(address _saru) external onlyRole(DEFAULT_ADMIN_ROLE) {
    kuniSaru = _saru;
  }

  function setVault(address val) external onlyRole(DEFAULT_ADMIN_ROLE) {
    rewardVault = val;
  }

  function setEco(address val) external onlyRole(DEFAULT_ADMIN_ROLE) {
    eco = IEconomyGame(val);
  }

  function setBlockPerDay(uint256 blockPerDay, uint256 staminaPerDay) external onlyRole(DEFAULT_ADMIN_ROLE) {
    NUM_OF_BLOCK_PER_DAY = blockPerDay;
    STAMINA = staminaPerDay;
  }

  function setKuniItem(address val) external onlyRole(DEFAULT_ADMIN_ROLE) {
    kuniItem = val;
  }

  // ============== Modifier ===================

  function onERC721Received(
      address,
      address,
      uint256,
      bytes memory
  ) public virtual override returns (bytes4) {
      return this.onERC721Received.selector;
  }

  function _addToken(address _from, uint _type, uint256 _tokenId) internal {
    ownedIndex[_type][_tokenId] = saruBalanceOf[_type][_from];
    ownerTokens[_type][_from][ownedIndex[_type][_tokenId]] = _tokenId;
    saruBalanceOf[_type][_from] = saruBalanceOf[_type][_from].add(1);
  }

  function _removeToken(address _from, uint _type, uint256 _tokenId) internal {
    uint256 cIndex = ownedIndex[_type][_tokenId];
    uint256 lastIndex = saruBalanceOf[_type][_from].sub(1);
    saruBalanceOf[_type][_from] = lastIndex;
    if (cIndex != lastIndex) {
      uint256 lastTokenId = ownerTokens[_type][_from][lastIndex];
      ownedIndex[_type][lastTokenId] = cIndex;
      ownerTokens[_type][_from][cIndex] = lastTokenId;
    }

    delete ownedIndex[_type][_tokenId];
    delete ownerTokens[_type][_from][lastIndex];
  }

  function _transfer(address _from, address _to, uint256 _tokenId, uint _type, bool isTransfer) internal {
    // if (_tokenId == 0) {return;}
    if (isTransfer) {
      IERC721(kuniSaru).safeTransferFrom(_from, _to, _tokenId);
    }

    if (_to == address(this)) { // add
      _addToken(_from, _type, _tokenId);
      if (_type == RENT_OUT) {
        _addToken(address(this), RENT_ALL, _tokenId);
      }
    } else { // remove: from is this
      _removeToken(_to, _type, _tokenId);
      if (_type == RENT_OUT) {
        _removeToken(address(this), RENT_ALL, _tokenId);
      }
    }
  }

  function emergencyWithdraw(address _token, address payable _to) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (_token == address(0x0)) {
      payable(_to).transfer(address(this).balance);
    }
    else {
      IERC20(_token).transferFrom(address(this), _to, IERC20(_token).balanceOf(address(this)));
    }
  }
}