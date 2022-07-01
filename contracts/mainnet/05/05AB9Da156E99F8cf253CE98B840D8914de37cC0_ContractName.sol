/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC1155/ERC1155.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

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

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

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
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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

    /**
     * @dev Hook that is called after any token transfer. This includes minting
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
    function _afterTokenTransfer(
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

// File: nft.sol

pragma solidity ^0.8.13;




interface IUniswapV2Router01 {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface PriceTool{
    function getPrice(address _outToken, address _inToken, uint256 _amount) external view returns(uint256 amount);
}

interface RandomUtils{
    function getRandom(uint256 _num, uint256 _start) external view returns (uint8);
}
 
interface FAF{
    function delFreeMint() external;
    function getFreeMintNumber() external view returns(uint256);
}
contract ContractName is ERC1155, Ownable {
    
    using SafeMath for uint256;
    
    IUniswapV2Router01 public uniswapV2Router;
 
    string public _uri = "https://future.mypinata.cloud/ipfs/QmVL5zj6fGqGNjhhv99KkM1tv5cArLzbjgx2HAqhfbJ7az/{id}"; 

    
    PriceTool public priceTool = PriceTool(0x981763e3C4f883dE5E4a09249Ed8aB37d7d6FAD6);
    
    RandomUtils public randomUtils = RandomUtils(0x0d1809Ceed5426Bf07EbC01f0605d4C027c6B1F4);
  //  RandomUtils public randomUtils = RandomUtils(0x8794941893dff0C5FF56E3e1660024916e67B5e9);

    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public holdAddr = 0x0000000000000000000000000000000000000001;
    address public _fafAds;
    FAF public faf;
    IERC20 public _FAF;
    

    //平台总积分
    uint256 public totalPoints = 0;
    //当前空投金额
    uint256 public currentReward = 0;
    //1级卡数量
    uint256 public cardNumber = 0;
    //最后一次发放领取积分次数
    uint256 public lastTimeDoAirdrop = 0;
    //最后一次发放打工次数
    uint256 public lastTimeDoWork = 0; 
    uint256 public start = 100;
    bool public _up = true;

    mapping(address => address) public recommend;
    //个人积分
    mapping(address => uint256) public userPoints;
    //nft积分
    mapping(uint256 => uint256) public idPoints;
    //当前卡牌数量
    mapping(uint256 => uint256) public idAmount;
    //当前卡牌组数量 绿1 蓝2 紫3 金4
    mapping(uint256 => uint256) public groupAmount;
    //卡牌数量上限
    mapping(uint256 => uint256) public idTotalAmount;
    //用户是否存在
    mapping(address => bool) public isExist;
    //用户是否可领取分红
    mapping(address => bool) public isAirdrop;
    //用户可领取打工饰品次数
    mapping(address => uint256) public doWorkAmount;

    bool public idoMintEnable = true;

    //用户组
    address[] _users;

    event compose(address _address, uint256 _level);
    string public name;
    string public symbol;
 
    constructor(address fafAdr) ERC1155(_uri) {
        IUniswapV2Router01 _uniswapV2Router = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        setPoints();
        setURI(_uri);
        name = "FAF";
        symbol = "GAME";
        _FAF = IERC20(fafAdr);
        faf = FAF(fafAdr);
        _fafAds = fafAdr;
    }
 
    //mint 1级基础卡
    function mint(uint256 _amount) public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(priceTool.getPrice(_fafAds, _usdt, _amount) >= 290, "price too little");
        require(idAmount[1] + 1 <= idTotalAmount[1], "Quantity overrun");
        _amount = _amount * 10 ** 18;
        _FAF.transferFrom(msg.sender, address(this), _amount);
        bouns(_amount);
        uint id = randomUtils.getRandom(21, 1);
        _mint(msg.sender, id, 1, "");
        addPoint(msg.sender, 1);
        idAmount[1] += 1;
        if(!isExist[msg.sender]){
            _users.push(msg.sender);
            isExist[msg.sender] = true;
        }
        cardNumber ++;
        if(block.timestamp - lastTimeDoAirdrop > 604800){
            uint256 pledgeBalance = _FAF.balanceOf(address(this));
            require(pledgeBalance > 0, "no balance");
            currentReward = pledgeBalance;
            for(uint i = 0; i < _users.length; i++) {
                isAirdrop[_users[i]] = true;
            }
            lastTimeDoAirdrop = block.timestamp;
        }
        if(block.timestamp - lastTimeDoWork > 259200){
            for(uint i = 0; i < _users.length; i++) {
                doWorkAmount[_users[i]] += 1;
            }
            lastTimeDoWork = block.timestamp;
        }
    }
 
    //mint 1级基础卡
    function idomint() public {
        require(idoMintEnable, "no open");
        uint256 _amount = 6000;
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(idAmount[1] + 1 <= idTotalAmount[1], "Quantity overrun");
        _amount = _amount * 10 ** 18;
        _FAF.transferFrom(msg.sender, address(this), _amount);
        bouns(_amount);
        uint id = randomUtils.getRandom(21, 1);
        _mint(msg.sender, id, 1, "");
        addPoint(msg.sender, 1);
        idAmount[1] += 1;
        if(!isExist[msg.sender]){
            _users.push(msg.sender);
            isExist[msg.sender] = true;
        }
        cardNumber ++;
        if(block.timestamp - lastTimeDoAirdrop > 604800){
            uint256 pledgeBalance = _FAF.balanceOf(address(this));
            require(pledgeBalance > 0, "no balance");
            currentReward = pledgeBalance;
            for(uint i = 0; i < _users.length; i++) {
                isAirdrop[_users[i]] = true;
            }
            lastTimeDoAirdrop = block.timestamp;
        }
        if(block.timestamp - lastTimeDoWork > 259200){
            for(uint i = 0; i < _users.length; i++) {
                doWorkAmount[_users[i]] += 1;
            }
            lastTimeDoWork = block.timestamp;
        }
    }

    //管理员mint
    function adminMint(address _target, uint id, uint amount) external onlyOwner {
        require(idAmount[id] + amount <= idTotalAmount[id], "Quantity overrun");
        _mint(_target, id, amount, "");
        addPointAdmin(_target, idPoints[id] * amount);
        if(!isExist[_target]){
            _users.push(_target);
            isExist[_target] = true;
        }
        idAmount[id] += amount;
        cardNumber += amount;
    }

    //免费mint
    function freeMint() public {
        require(idAmount[1] + 1 <= idTotalAmount[1], "Quantity overrun");
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(faf.getFreeMintNumber() > 0, "no free mint number");
        uint id = randomUtils.getRandom(21, 1);
        _mint(msg.sender, id, 1, "");
        addPoint(msg.sender, 1);
        idAmount[id] += 1;
        if(!isExist[msg.sender]){
            _users.push(msg.sender);
            isExist[msg.sender] = true;
        }
        faf.delFreeMint();
    }

    //基础卡合成 1、2级
    //入参：3张卡id数组
    function baseCompose(uint256[] memory ids) external {
        require(address(msg.sender) == address(tx.origin), "no contract");
        uint256 level;
        for(uint i = 0; i < ids.length; i++){
            require(ids[i] <= 42, "error id");
            burn(msg.sender, ids[i], 1);
            level = ids[i] + 21;
        }
        require(idAmount[level] + 1 <= idTotalAmount[level], "Quantity overrun");
        _mint(msg.sender, level, 1, "");
        addPoint(msg.sender, level);
        idAmount[level] += 1;
        emit compose(msg.sender, level);
    }

    //高级合成
    //入参：[3级基础卡, 饰品卡1, 饰品卡2, 饰品卡3]id
    function highCompose(uint256[] memory ids) external {
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(ids.length == 4, "number error");
        require(ids[0] > 42 && ids[0] < 64, "baseId error");
        require(ids[1] > 147 && ids[1] < 158, "highId error");
        require(ids[2] > 147 && ids[2] < 158, "highId error");
        require(ids[3] > 147 && ids[3] < 158, "highId error");
        for(uint i = 0; i < ids.length; i++){
            burn(msg.sender, ids[i], 1);
        }
        uint256 styleId = randomUtils.getRandom(start, 1);
        uint256 id = 0;
        //金卡
        if(styleId < 2){
             id = 126 + randomUtils.getRandom(21, 1);
             groupAmount[4] += 1;
        }else
        //紫卡
        if(styleId > 1 && styleId < 9){
             id = 105 + randomUtils.getRandom(21, 1);
             groupAmount[3] += 1;
        }else
        //蓝卡
        if(styleId > 8 && styleId < 30){
             id = 84 + randomUtils.getRandom(21, 1);
             groupAmount[2] += 1;
        }else
        //绿卡
        {
             id = 63 + randomUtils.getRandom(21, 1);
             groupAmount[1] += 1;
        }
        require(idAmount[id] + 1 <= idTotalAmount[id], "Quantity overrun");
        _mint(msg.sender, id, 1, "");
        addPoint(msg.sender, id);
        idAmount[id] += 1;
        if(_up){
            if(start < 200){
                start += 1;
            }else{
                _up = false;
            }
        }else{
            if(start >= 200){
                start -= 100;
            }else{
                _up = true; 
            }
        }
        emit compose(msg.sender, id);
    }


    //增加积分
    function addPoint(address _target, uint256 _id) internal{
        userPoints[_target] += idPoints[_id];
        totalPoints += idPoints[_id];
    }

    function addPointAdmin(address _target, uint256 _amount) internal{
        userPoints[_target] += _amount;
        totalPoints += _amount;
    }
    
    //减少积分
    function delPoint(address _target, uint256 _id) internal{
        userPoints[_target] -= idPoints[_id];
        totalPoints -= idPoints[_id];
    }

    function setIdoMint(bool _target) external onlyOwner{
        idoMintEnable = _target;
    }
 
    function setURI(string memory URI) public onlyOwner {
        _setURI(URI);
    }

    //转账
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        userPoints[to] += idPoints[id];
        userPoints[from] -= idPoints[id];
        if(!isExist[to]){
            _users.push(to);
            isExist[to] = true;
        }
        super.safeTransferFrom(from, to, id, amount, data);
    }

    //批量转账
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        for(uint i = 0; i < ids.length; i++){
            userPoints[from] -= idPoints[ids[i]] * amounts[i];
            userPoints[to] -= idPoints[ids[i]] * amounts[i];
        }
        if(!isExist[to]){
            _users.push(to);
            isExist[to] = true;
        }
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    //分发收益
    function bouns(uint256 _amount) internal {
        _FAF.transfer(holdAddr, _amount * 4 / 10);
        address top1 = recommend[msg.sender];
        if(top1 != address(0)){
            _FAF.transfer(top1, _amount * 15 / 100);
            top1 = recommend[top1];
            if(top1 != address(0)){
                _FAF.transfer(top1, _amount * 10 / 100);
                top1 = recommend[top1];
                if(top1 != address(0)){
                    _FAF.transfer(top1, _amount * 5 / 100);
                }else{
                    _FAF.transfer(holdAddr, _amount * 5 / 100);
                }
            }else{
                _FAF.transfer(holdAddr, _amount * 15 / 100);
            }
        }else{
            _FAF.transfer(holdAddr, _amount * 20 / 100);
        }
    }

    //销毁
    function burn(address account, uint256 id, uint256 value) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        delPoint(msg.sender, id);
        _burn(account, id, value);
    }
 
    //批量销毁
    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        for(uint i = 0; i < ids.length; i++){
            userPoints[msg.sender] -= idPoints[ids[i]] * values[i];
            totalPoints -= idPoints[ids[i]] * values[i];
        }
        _burnBatch(account, ids, values);
    }

    //推荐人绑定
    function bind(address _target) external {
        recommend[msg.sender] = _target;
    }

    //查询推荐人
    function getRecommend(address _address) view external returns(address){
        return recommend[_address];
    }
    
    //管理员增加空投状态
    function doAirdrop() external onlyOwner {
        uint256 pledgeBalance = _FAF.balanceOf(address(this));
        require(pledgeBalance > 0, "no balance");
        currentReward = pledgeBalance;
        for(uint i = 0; i < _users.length; i++) {
            isAirdrop[_users[i]] = true;
        }
        lastTimeDoAirdrop = block.timestamp;
    }

    //个人总有卡牌积分数/全网卡牌积分数×分配代币数量
    function getProfit() payable external {
        require(msg.value >= 0.0005 ether, "pay little");
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(isAirdrop[msg.sender], "no reward");
        uint256 reward = userPoints[msg.sender] * currentReward / totalPoints;
        isAirdrop[msg.sender] = false;
        _FAF.transfer(msg.sender, reward);
        payable(0x0Ace0596c3c5e0F3C4D6F6180AaA15F4888bdAb5).transfer(msg.value);
    }

    //查询个人收益
    function getMyProfit(address _target) external view returns (uint256){
        require(isAirdrop[_target], "no reward");
        return userPoints[_target] * currentReward / totalPoints;
    }

    
    //管理员增加打工次数
    function addDoWork() external onlyOwner {
        for(uint i = 0; i < _users.length; i++) {
            doWorkAmount[_users[i]] += 1;
        }
        lastTimeDoWork = block.timestamp;
    }

    //领取打工收益 -> 饰品
    function getDoWorkProfit() external payable{
        require(msg.value >= 0.0005 ether, "pay little");
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(doWorkAmount[msg.sender] > 0, "no reward");
        payable(0x0Ace0596c3c5e0F3C4D6F6180AaA15F4888bdAb5).transfer(msg.value);
        for(uint8 i = 1; i < 148; i++){
            uint256 amount = balanceOf(msg.sender, i); 
            if(amount > 0){
                uint256 id;
                //基础卡
                if(i < 64){
                    id = randomUtils.getRandom(3, 148);
                    _mint(msg.sender, id, amount, "");
                    userPoints[msg.sender] += idPoints[id] * amount;
                    totalPoints += idPoints[id] * amount;
                }
                //绿卡
                if(i > 63 && i < 85){
                    uint8 rand = randomUtils.getRandom(10, 1);
                    if(rand == 1){
                        id = randomUtils.getRandom(3, 151);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }else{
                        id = randomUtils.getRandom(3, 148);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }
                }
                //蓝卡
                if(i > 84 && i < 106){
                    uint8 rand = randomUtils.getRandom(10, 1);
                    if(rand < 3){
                        id = randomUtils.getRandom(3, 151);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }else{
                        id = randomUtils.getRandom(3, 148);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }
                }
                //紫卡
                if(i > 105 && i < 127){
                    uint8 rand = randomUtils.getRandom(10, 1);
                    if(rand == 1){
                        id = randomUtils.getRandom(3, 154);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }else if(rand == 2 || rand == 3){
                        id = randomUtils.getRandom(3, 151);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id];
                    }else if(rand == 9){
                        _mint(msg.sender, 157, amount, "");
                        userPoints[msg.sender] += idPoints[157] * amount;
                        totalPoints += idPoints[157] * amount;
                    }else{
                        id = randomUtils.getRandom(3, 148);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }
                }
                //金卡
                if(i > 126 && i < 148){
                    uint8 rand = randomUtils.getRandom(10, 1);
                    if(rand == 1 || rand == 2){
                        id = randomUtils.getRandom(3, 154);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }else if(rand == 3 || rand == 4){
                        _mint(msg.sender, 157, amount, "");
                        userPoints[msg.sender] += idPoints[157] * amount;
                        totalPoints += idPoints[157] * amount;
                    }else if(rand == 5 || rand == 6 || rand == 7){
                        id = randomUtils.getRandom(3, 148);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }else{
                        id = randomUtils.getRandom(3, 151);
                        _mint(msg.sender, id, amount, "");
                        userPoints[msg.sender] += idPoints[id] * amount;
                        totalPoints += idPoints[id] * amount;
                    }
                }
            }
        }
        doWorkAmount[msg.sender] -= 1;
    }

    function setPoints() internal {
        for(uint i = 1; i < 158; i++){
            if(i > 0 && i < 22){
                idPoints[i] = 100;
                idTotalAmount[i] = 180000;
            }else if(i > 21 && i < 43){
                idPoints[i] = 300;
                idTotalAmount[i] = 60000;
            }else if(i > 42 && i < 64){
                idPoints[i] = 900;
                idTotalAmount[i] = 20000;
            }else if(i > 63 && i < 85){
                idPoints[i] = 1080;
                idTotalAmount[i] = 6906;
            }else if(i > 84 && i < 106){
                idPoints[i] = 1404;
                idTotalAmount[i] = 2302;
            }else if(i > 105 && i < 127){
                idPoints[i] = 2106;
                idTotalAmount[i] = 767;
            }else if(i > 126 && i < 148){
                idPoints[i] = 4212;
                idTotalAmount[i] = 25;
            }
        }
    }

    //代币提现
    function withdraw(address _token, address _target, uint256 _amount) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "no balance");
		IERC20(_token).transfer(_target, _amount);
    }

    function setFAF(address _target) external onlyOwner{
        _FAF = IERC20(_target);
        faf = FAF(_target);
        _fafAds = _target;
    }

    function getPrice(address token1, address token2, uint256 _amount) view external returns(uint256){
        return priceTool.getPrice(token1, token2, _amount);
    }
}