/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
// SPDX-License-Identifier: MIT
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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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

// File: @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
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

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: Liger88.sol


pragma solidity ^0.8.15;
pragma abicoder v2;



// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";




  
 
library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
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

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

   
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

   
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


abstract contract ERC1155 is  Context, ERC165, IERC1155, IERC1155MetadataURI , ERC1155Holder {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    
    constructor(string memory uri_) {
        _setURI(uri_);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165, ERC1155Receiver) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

     
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

     
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

    
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    
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

   
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

     
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

     
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

   
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    
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
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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
}
 

 
contract Liger88 is ERC1155,  Ownable, ReentrancyGuard  {

  uint256 public ligerCounter;

  mapping (uint256=> string) private _uris;
   
  mapping (uint256=> uint256) public _tokenMintQty;

  mapping (address => bool) public isFeeExempt;

  mapping(string => bool) public tokenNameExists;
  
  mapping(string => bool) public tokenURIExists;  

   
   struct Liger {
    uint256 tokenid;
    string tokenname;
    string tokenuri;
    string tags;
    string description;
    address payable mintedby;
    uint256 price;
    uint256 quantity;
    uint256 numberoftransfers;
    uint posttime;
    uint saletime;
  }

  uint256 public mintingPrice = 0; //1000;
  uint256 public ligerTaxRate = 0; //80;
  uint256 public busdLigerRate = 1000;
  uint256 public feeDenominator  = 1000;

  address public ligerAddress;
  IERC20 public ligerToken;

  address public busdAddress;
 
  IERC20 public busdToken;
 
  uint256  public ligerTaxAmount;
  uint256  public busdTaxAmount;
 

  

  address public treasuryReceiver;
  address public mintingReceiver;
 
  

  // map liger's token id to liger
  mapping(uint256 => Liger) public allLigers;


  mapping(address => uint256[]) public ligersMintedBy;
  mapping(address => uint256) public ligersMintedByCounter;
  //map ligers by address
  mapping(address => uint256[]) public ligersOf;
  mapping(address => uint256) public ligersOfCounter;

  event LigerAddressChanged (address ligerAddress);
 
  event LigerTaxRateChanged (uint256 ligerTaxRate);
 

  string public name;
  string public symbol;
    
  
 constructor()  ERC1155("")  ReentrancyGuard() {
    
    name = "Liger88";
    symbol = "LIGER88";
  
    address _ligerAddress = 0x1A3C30eF97275ec72267c50CA2ACb3fCA580c9E7;
    address _busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address _treasuryReceiver = 0x835FE28d6a4A5e63ef8d90ea686A81Fc9bd4b897;
    address _mintingReceiver = 0x56a3A45afB3c3e4F6bf911cE8289FE55c7AaDDc1;

    ligerAddress = payable(_ligerAddress);
    ligerToken = IERC20(_ligerAddress);

    busdAddress = payable(_busdAddress);
    busdToken = IERC20(_busdAddress);
   
    treasuryReceiver =  _treasuryReceiver;
    mintingReceiver = _mintingReceiver;
  
    isFeeExempt[_mintingReceiver] = true;
    isFeeExempt[_treasuryReceiver] = true;
    isFeeExempt[address(this)] = true;
    isFeeExempt[msg.sender] = true;
 
  }

  
  function _updateLigerBalances (address from, address to, uint256 id) internal {
      Liger memory liger = allLigers[id];
      liger.numberoftransfers += 1;
      liger.saletime  = block.timestamp; 
      allLigers[id] = liger;

      uint256  sellergalleryctr = ligersOfCounter[from];

      if (sellergalleryctr > 1) {
       ligersOf[from][id] = ligersOf[from][sellergalleryctr - 1];
      }

      ligersOf[from].pop();
      ligersOfCounter[from]--;


      ligersOf[to].push(id);
      ligersOfCounter[to]++;
  }

  function safeTransferFrom(address from, address to,uint256 id, uint256 amount,  bytes memory data) public virtual override nonReentrant()     {
     
      require(from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved" );

      _safeTransferFrom(from, to, id, amount, data);

      _updateLigerBalances(from, to, id);

  }


  function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts,  bytes memory data) public virtual override nonReentrant()    {
     for(uint i=0; i < ids.length; i++){

        uint256 id = ids[i];
        uint256 amount =  amounts[i];

        _safeTransferFrom(from, to, id, amount , data);
        
        _updateLigerBalances(from, to, id);
        
      }
    // _safeBatchTransferFrom(from, to, ids, amounts, data);
  }

 

 function mintLiger(string memory _name, string memory _tags, string memory _description, uint256 _amount, string memory _tokenURI, uint256 _price, uint8 _busdliger) external nonReentrant onlyOwner
    {
    require(msg.sender != address(0), "address 0");

    //additional check
    require(_amount > 0, "no mint quantity specified");
 

    uint256 senderbalance = 0;
    
    uint256 mintingFee =  0;

    if (_busdliger == 0) { //0 PINFT 1 BUSD
       senderbalance = IERC20(ligerAddress).balanceOf(msg.sender);
    
       mintingFee =  (mintingPrice / feeDenominator) * _amount * 10 ** 18;
    
      if(!isFeeExempt[msg.sender]) {
        require(senderbalance >= mintingFee, "insufficient liger to mint");
      }
    } else {
       senderbalance = IERC20(busdAddress).balanceOf(msg.sender);
    
       mintingFee =  (mintingPrice / feeDenominator) * _amount  * (busdLigerRate / feeDenominator)  * 10 ** 18  ;
    
      if(!isFeeExempt[msg.sender]) {
        require(senderbalance >= mintingFee, "insufficient busd to mint");
      }
    }
   
   
    ligerCounter ++;

    require(!(_tokenMintQty[ligerCounter] > 0), "token already exists");

    _mint(msg.sender, ligerCounter, _amount, "");
    
    _uris[ligerCounter] = _tokenURI;
    
    _tokenMintQty[ligerCounter] = _amount;

    tokenURIExists[_tokenURI] = true;
    tokenNameExists[_name] = true;

    //charge for minting
    if(!isFeeExempt[msg.sender]) {
      if (_busdliger == 0) {
        IERC20(ligerAddress).transferFrom( msg.sender, mintingReceiver, mintingFee );
      } else {
        IERC20(busdAddress).transferFrom( msg.sender, mintingReceiver, mintingFee );
      }
    }

     // create a new liger (struct) and pass in new values
    Liger memory newLiger = Liger(
    ligerCounter,
    _name,
    _tokenURI,
    _tags, 
    _description,
    payable(msg.sender),
    _price,
    _amount,
    0,
    block.timestamp,
    0 );

    // add the token id and it's liger to all liger mapping
    allLigers[ligerCounter] = newLiger;

    ligersOf[msg.sender].push(ligerCounter);
    ligersOfCounter[msg.sender]++;
   
    ligersMintedBy[msg.sender].push(ligerCounter);
    ligersMintedByCounter[msg.sender]++;

     
  } 


  function uri(uint256 tokenId) override public view returns (string memory) {
    return(_uris[tokenId]);
  }

 
  // get total number of tokens owned by an address
  function getTotalNumberOfTokensOwnedByAnAddress(address _owner, uint256 _tokenId) public view returns(uint256) {
    uint256 totalNumberOfTokensOwned = balanceOf(_owner, _tokenId);
    return totalNumberOfTokensOwned;
  }

  // check if the token already exists
  function getTokenExists(uint256 _tokenId) public view returns(bool) {
    bool tokenExists = (_tokenMintQty[_tokenId] > 0);
    return tokenExists;
  }
 
   function changeTokenDetails(uint256 _tokenId, bool _justprice, uint256 _newPrice, string memory _newName, string memory _newTags, string memory _newDescription ) public nonReentrant() {
    
    require(_tokenMintQty[_tokenId] > 0, "token does not exist");
 
    require(msg.sender != address(0),"an empty address");
   
    // get the token's owner
    require(balanceOf(msg.sender, _tokenId) > 0 , "not the token owner");

    // get the token's owner
    require(balanceOf(msg.sender, _tokenId) == _tokenMintQty[ligerCounter] , "not all copies owned ");
    
    Liger memory liger = allLigers[_tokenId];
 
     
    if (_justprice ) {
      liger.price = _newPrice;
    } else {
      liger.price = _newPrice;
      liger.tokenname = _newName;
      liger.tags = _newTags;
      liger.description = _newDescription;
    }
  
    allLigers[_tokenId] = liger;

    }


function buyToken(uint256 _tokenId,   uint256 _price,  uint256 _amount, address payable _seller ,  uint8 _busdliger) external nonReentrant() {
 
    // check if the function caller is not an zero account address
    require(msg.sender != address(0));
    
    // require that token should exist
    require(_tokenMintQty[_tokenId] >= _amount, "token should exist");

    Liger memory liger = allLigers[_tokenId];

    
    // // get the token's owner
    address payable tokenOwner = _seller;
    // token's owner should not be an zero address account
    require(tokenOwner != address(0), "should not be a zero address account");
    // the one who wants to buy the token should not be the token's owner
    require(tokenOwner != msg.sender, "should not be the token's owner");
    
    // //check seller has balance to sell
    require(balanceOf(tokenOwner,_tokenId) >= _amount, "insufficient nft balance to sell");

    uint256 ligerprice = _price ;
   
    uint256 ligercharge = (ligerprice * ligerTaxRate) / feeDenominator;
    
    uint256 ligerprice2 = ligerprice + ligercharge;
     
    uint256 senderbalance = 0;
    
    if (_busdliger == 0) { //0 PINFT 1 BUSD 
       senderbalance = IERC20(ligerAddress).balanceOf(msg.sender);
       require(senderbalance >= ligerprice2 , "need to top up ligerplay token balance");
      
      IERC20(ligerAddress).transferFrom( msg.sender, tokenOwner,  ligerprice );
     
      if(!isFeeExempt[msg.sender] && ligercharge > 0) {
        IERC20(ligerAddress).transferFrom( msg.sender, treasuryReceiver,  ligercharge );
        ligerTaxAmount = ligerTaxAmount + ligercharge;
      }
    } else {
       senderbalance = IERC20(busdAddress).balanceOf(msg.sender);
    
       require(senderbalance >= ligerprice2   , "insufficient busd to buy");
       
       IERC20(busdAddress).transferFrom( msg.sender, tokenOwner, ligerprice );
       
      if(!isFeeExempt[msg.sender]  && ligercharge > 0) {
          IERC20(busdAddress).transferFrom( msg.sender, treasuryReceiver, ligercharge );
           busdTaxAmount = busdTaxAmount + ligercharge;
       }
       
    }
    
    _safeTransferFrom(tokenOwner, msg.sender, _tokenId, _amount, '');
     
    liger.numberoftransfers += 1;
    liger.saletime  = block.timestamp;
    liger.price = ligerprice;
    // set and update that token in the mapping
    allLigers[_tokenId] = liger;

    
    ligersOf[msg.sender].push(_tokenId);
    ligersOfCounter[msg.sender]++;
           
   }


  function rescueToken(uint256 _tokenId, uint256 tokens) nonReentrant() external onlyOwner {
      _safeTransferFrom(address(this), msg.sender, _tokenId, tokens, '');

  }

  // clear out balance in contract 
   function clearStuckBalance_sender(uint256 amountPercentage) nonReentrant() external onlyOwner {
        require(address(this).balance > 0, "balance is zero");
       
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);

     }


  // airdrop fixed amount to batch of addresses 
  function multiTransfer_fixedNFT(uint256 id, address[] calldata addresses) nonReentrant() external onlyOwner {

    require(addresses.length < 2001,"GAS Error: max airdrop limit is 2000 addresses"); // to prevent overflow

    uint256 airdropcount =  addresses.length;

    require(balanceOf(msg.sender, id) >= airdropcount, "Not enough tokens in wallet");
    _safeTransferFrom(msg.sender, address(this), id, airdropcount, '');

    address from = address(this);
    for(uint i=0; i < addresses.length; i++){
         address to = addresses[i];
        _safeTransferFrom(from, to , id, 1, '');

        _updateLigerBalances(from, to, id);
      }

   }


  // airdrop erc20 individual specific number of tokens to batch of addresses 
  function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) nonReentrant() external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 airdropcount = 0;

    for(uint i=0; i < addresses.length; i++){
        airdropcount = airdropcount + tokens[i];
    }

    require(IERC20(ligerAddress).balanceOf(msg.sender) >= airdropcount, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        IERC20(ligerAddress).transferFrom(msg.sender,addresses[i],tokens[i]);
    }
   
  }

 function setLigerAddress(address _newligeraddress) nonReentrant() public  onlyOwner {
        ligerAddress = payable(_newligeraddress);
    }

    function setLigerTaxRate(uint256 _newligertaxrate) nonReentrant() external onlyOwner  {
        ligerTaxRate = _newligertaxrate ;
    }
       
   
    function setMintingPrice(uint256 _newMintingPrice) nonReentrant()  external onlyOwner {
        mintingPrice = _newMintingPrice;
    }
     
   function setLigerCounter(uint256 _newLigerCounter) nonReentrant()  external onlyOwner {
        ligerCounter = _newLigerCounter;
    }
     
  function setBusdAddress( address _busdAddress   ) nonReentrant() external onlyOwner {
      busdAddress = _busdAddress;  
  }

  function setTreasuryReceiver( address _treasuryReceiver   ) nonReentrant() external onlyOwner {
      treasuryReceiver = _treasuryReceiver;  
  }

   function setMintingReceiver(    address _mintingReceiver ) nonReentrant() external onlyOwner {
      mintingReceiver = _mintingReceiver;  
  }

  function setIsFeeExempt(address holder, bool exempt) nonReentrant() external onlyOwner {
      isFeeExempt[holder] = exempt;
  }
   
  function setBusdLigerRate(uint256 _newbusdligerrate) nonReentrant() external onlyOwner  {
        busdLigerRate = _newbusdligerrate;    
  }   

}