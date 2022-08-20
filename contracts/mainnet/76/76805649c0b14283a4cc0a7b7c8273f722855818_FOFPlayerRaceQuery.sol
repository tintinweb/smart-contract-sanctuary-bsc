/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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

// File: FOFPlayerRaceData.sol



pragma solidity ^0.8.0;




contract FOFPlayerRaceData is Ownable {

    using SafeMath for uint256;

    
    mapping(address => string) public nicknames;

    mapping(uint256 => string) public cardNicknames;

    
    mapping(uint256 => address[]) public clubMembers;

    mapping(address => uint256) public memberToClubIds;

    mapping(uint256 => address[3]) public clubRaceMembers;

    mapping(uint256 => uint256) public raceIds;

    mapping(uint256 => mapping(uint256 => uint256)) public raceTime;

    mapping(uint256 => uint256) public raceDurations;

    mapping(uint256 => mapping(uint256 => uint256[])) public raceVehicles;

    mapping(uint256 => mapping(uint256 => uint256)) public raceReward;
    mapping(uint256 => mapping(uint256 => uint256)) public fofRaceReward;

    uint256 public maxRaceTimes = 20;

    mapping(address => uint256) public uerRaceTotalTimes;

    mapping(address => uint256) public userRaceLeftTimes;

    mapping(address => bool) public uerGetFuelForFree;

    uint256 public rankingRaceTicket = 2 * 10 ** 16;

    uint256 public fuelPrice = 5 * 10 ** 18;

    mapping(uint256 => uint256) public fuelPriceDiscount;

    // mapping(address => uint256) public userBuyFuelTime;
    mapping(address => uint256) public userTodayRaceTimes;

    mapping(address => uint256) public userLastRaceTime;

    uint256 public todayRaceTimes;

    uint256 public LastRaceTime;

    uint256 public discountEndTime = 1693497600;

    uint256 public freeFuelTime = 1661961600;


    // address public receiveAddress;
    address public withdrawAddress;

    // address public rankAddress = 0xBdDeeC848161d71851Bcb3ff8A4Bf590eF782E71;
    address public clubAddress;
    address public repokAddress = 0x936380034e18e8E9DBc35DBbdc7248507e935Cc1;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;


    uint256 public todayDividends;
    uint256 public todayFofDividends;

    uint256 public topDividends = 10 ** 17;

    mapping(uint256 => mapping(uint256 => uint256)) public settlementTimesToDividends;

    mapping(uint256 => mapping(uint256 => uint256)) public settlementTimesToFofDividends;

    uint256[] public settlementTimesToTime;


    mapping(address => bool) public isController;


    constructor() {
    
        raceTime[1][1] = 7200;
        raceTime[1][2] = 25200;
        raceTime[1][3] = 50400;

        raceTime[2][1] = 1665316800;
        raceTime[3][1] = 1671537600;

        raceDurations[1] = 2 hours;
        raceDurations[2] = 1 hours;
        raceDurations[3] = 1 hours;

        fuelPriceDiscount[1] = 90;
        fuelPriceDiscount[2] = 95;
        fuelPriceDiscount[3] = 97;

        raceIds[1] = 1;
        raceIds[2] = 1;
        raceIds[3] = 1;

        withdrawAddress = address(0x068E169b6d3a0DFB1Fe2C9ad593f8f9447e47cBe);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    function setClubAddress(address _clubAddress) public onlyController {
        clubAddress = _clubAddress;
    }

    function setRepokAddress(address _repokAddress) public onlyController {
        repokAddress = _repokAddress;
    }

    function setWithdrawAddress(address _withdrawAddress) public onlyController {
        withdrawAddress = _withdrawAddress;
    }

    function setMaxRaceTimes(uint256 _maxRaceTimes) public onlyController {
        maxRaceTimes = _maxRaceTimes;
    }

    function setRaceTime(uint256 raceType, uint256 raceid, uint256 time) public onlyController {
        raceTime[raceType][raceid] = time;
    }

    function setTopDividends(uint256 _topDividends) public onlyController {
        topDividends = _topDividends;
    }

    function setDiscountEndTime(uint256 _discountEndTime) public onlyController {
        discountEndTime = _discountEndTime;
    }

    function setFreeFuelTime(uint256 _freeFuelTime) public onlyController {
        freeFuelTime = _freeFuelTime;
    }

    function setRaceDurations(uint256 raceType, uint256 time) public onlyController {
        raceDurations[raceType] = time;
    }

    function setRankingRaceTicket(uint256 _rankingRaceTicket) public onlyController {
        rankingRaceTicket = _rankingRaceTicket;
    }

    function setFuelPrice(uint256 _fuelPrice) public onlyController {
        fuelPrice = _fuelPrice;
    }

    function setNickname(address user, string memory _nickname) public onlyController {
        nicknames[user] = _nickname;
    }

    function setCardNicknames(uint256 tokenId, string memory _nickname) public onlyController {
        cardNicknames[tokenId] = _nickname;
    }

    function joinClub(address user, uint256 tokenId) public onlyController {

        require(memberToClubIds[user] == 0, "You have joined the club");

        memberToClubIds[user] = tokenId;

        clubMembers[tokenId].push(user);
    }

    function deleteClubMember(uint256 clubId, uint256 index, address member) public onlyController {

        delete clubMembers[clubId][index];
        
        memberToClubIds[member] = 0;
    }

    function subUserRaceLeftTimes(address user, uint256 times) public onlyController {
        userRaceLeftTimes[user] -= times;
    }

    function addUserRaceLeftTimes(address user, uint256 times) public onlyController {
        userRaceLeftTimes[user] += times;
    }

    function setUserRaceTotalTimes(address user, uint256 times) public onlyController {
        uerRaceTotalTimes[user] = times;
    }

    function addRaceVehicles(uint256 raceType, uint256 raceId, uint256 tokenId) public onlyController {
        raceVehicles[raceType][raceId].push(tokenId);
    }

    function addRaceIds(uint256 raceType,uint256 num) public onlyController {
        raceIds[raceType] += num;
    }

    function addRaceReward(uint256 raceType, uint256 raceId, uint256 reward) public onlyController {
        raceReward[raceType][raceId] += reward;
    }

    function addFofRaceReward(uint256 raceType, uint256 raceId, uint256 fofReward) public onlyController {
        fofRaceReward[raceType][raceId] += fofReward;
    }

    function addSettlementTimesToTime(uint256 time) public onlyController {
        settlementTimesToTime.push(time);
    }

    function setSettlementTimesToDividends(uint256 dividends) public onlyController {
        settlementTimesToDividends[settlementTimesToTime.length][4] = dividends;
        todayDividends = 0;
    }

    function setSettlementTimesToFofDividends(uint256 fofDividends) public onlyController {
        settlementTimesToFofDividends[settlementTimesToTime.length][4] = fofDividends;
        todayFofDividends = 0;
    }

    function deleteClubRaceMembers(uint256 clubId) public onlyController {
        delete clubRaceMembers[clubId];
    }

    function setClubRaceMembers(uint256 clubId, uint256 index, address user) public onlyController {
        clubRaceMembers[clubId][index] = user;
    }

    function addTodayDividends(uint256 dividends) public onlyController {
        todayDividends = todayDividends.add(dividends);
    }

    function addTodayFofDividends(uint256 fofDividends) public onlyController {
        todayFofDividends = todayFofDividends.add(fofDividends);
    }

    function setTodayDividends(uint256 dividends) public onlyController {
        todayDividends = dividends;
    }

    function setTodayFofDividends(uint256 fofDividends) public onlyController {
        todayFofDividends = fofDividends;
    }

    function setUerGetFuelForFree(address user, bool flag) public onlyController {
        uerGetFuelForFree[user] = flag;
    }

    function addUserTodayRaceTimes(address user, uint256 times) public onlyController {
        userTodayRaceTimes[user] += times;

        todayRaceTimes += times;

        userLastRaceTime[user] = block.timestamp;

        LastRaceTime =  block.timestamp;
    }

    function setUserTodayRaceTimes(address user, uint256 times) public onlyController {
        userTodayRaceTimes[user] = times;
    }

    function setTodayRaceTimes(uint256 times) public onlyController {
        todayRaceTimes = times;
    }

    function getRaceVehicles(uint256 raceType, uint256 raceId) public view returns(uint256[] memory) {
        return raceVehicles[raceType][raceId];
    }

    function getClubMembers(uint256 clubId) public view returns(address[] memory) {
        return clubMembers[clubId];
    }

    function getClubRaceMembers(uint256 clubId) public view returns(address[3] memory) {
        return clubRaceMembers[clubId];
    }

    function getSettlementTimesToTime() public view returns(uint256[] memory) {
        return settlementTimesToTime;
    }

    function getRaceTime(uint256 raceType) public view returns(uint256) {
        return raceTime[raceType][raceIds[raceType]];
    }

}
// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

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
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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
        address owner = ERC721.ownerOf(tokenId);

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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
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
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;


/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

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
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// File: FOFPlayerNFT.sol



pragma solidity ^0.8.0;


// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract FOFPlayerNFT is ERC721URIStorage, Ownable {

	uint256 public counter;

    uint256 private randNum = 0;

    mapping(uint256 => uint256) public NFTIDs;

    mapping(uint256 => uint256) public NFTTypes;

    mapping(address => uint256[]) public userNFTIDs;

    mapping(uint256 => uint256) public NFTIDToIndex;

    mapping(address => mapping(uint256 => uint256)) public userNFTTypeNumber;

    mapping(uint256 => uint256) public NFTTypeNumber;

    mapping(uint256 => uint256) public IDToWhtidrawTime;

    mapping(uint256 => bool) private islock;
    

    mapping(address => bool) public isController;


	constructor() ERC721("FOFPlayer", "FOFNFT"){
		counter = 0;
	}

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
         require(isController[msg.sender],"Must be controller");
         _;
    }
    
    function setNFTLock(uint256 tokenId, bool unlock) public onlyController returns (bool) {
        if(islock[tokenId] == unlock){
            return false;
        }
        islock[tokenId] = unlock;

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(!islock[tokenId], "ERC721: the NFT is locked");

        uint256 index = NFTIDToIndex[tokenId];

        userNFTIDs[from][index] = 0;

        NFTIDToIndex[tokenId] = userNFTIDs[to].length;

        userNFTIDs[to].push(tokenId);

        userNFTTypeNumber[from][NFTTypes[tokenId]] -= 1;

        userNFTTypeNumber[to][NFTTypes[tokenId]] += 1;
        
        return super._transfer(from, to, tokenId);
    }

    function createNFT(address user, uint256 NFTType) public onlyController returns (uint256){
        counter ++;

        uint256 tokenId = _rand();

        _safeMint(user, tokenId);

        NFTIDs[counter] = tokenId;

        NFTTypes[tokenId] = NFTType;

        NFTIDToIndex[tokenId] = userNFTIDs[user].length;

        userNFTIDs[user].push(tokenId);

        userNFTTypeNumber[user][NFTType] ++;

        NFTTypeNumber[NFTType] ++;

        IDToWhtidrawTime[tokenId] = block.timestamp;
		
        return tokenId;
	} 

    function createNFTs(address[] memory users, uint256 NFTType) public onlyController {

        for(uint256 i = 0; i < users.length; i++){
            createNFT(users[i],NFTType);
        }
        
	}

	function burn(uint256 tokenId) public virtual {
		require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: you are not the owner nor approved!");

		super._burn(tokenId);

        uint256 index = NFTIDToIndex[tokenId];

        userNFTIDs[msg.sender][index] = 0;

        userNFTTypeNumber[msg.sender][NFTTypes[tokenId]] -= 1;

        NFTTypeNumber[NFTTypes[tokenId]] -= 1;
	}

    function approveToController(address ownerAddr, uint256 tokenId) public onlyController {
        address owner = ownerOf(tokenId);

        require(ownerAddr == owner, "ERC721: this user does not own this tokenId");

        _approve(msg.sender, tokenId);
    }

    function setIDToWhtidrawTime(uint256 tokenId, uint256 time) public onlyController returns(bool){
        IDToWhtidrawTime[tokenId] = time;
        return true;
    }

    function setIDToWhtidrawTimes(uint256[] memory tokenIds, uint256 time) public onlyController returns(bool){

        for(uint256 i = 0; i < tokenIds.length; i++){
            IDToWhtidrawTime[tokenIds[i]] = time;
        }
        
        return true;
    }

    function _rand() internal virtual returns(uint256) {
        
        uint256 number1 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender))) % (4 * 10 ** 8) + 19689868;

        uint256 number2 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))) % (2 * 10 ** 8) + 19586796;
        
        return number1 + number2 + counter * 10 ** 9;
    }

    function getUserNFTIDs(address user) public view returns(uint256[] memory) {
		return userNFTIDs[user];
	}

}
// File: FOFPlayerController1.sol



pragma solidity ^0.8.0;




contract FOFPlayerController1 is Ownable {

    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);

    event OpenBlindBox(address from, uint256 cost, uint256 awardTypes, Component com);

    event WhtidrawDividends(address from, uint256 profit);


    struct Component {
        uint256 id;

        address holder;

        uint256 types;

        uint256 rarity;

        uint256 speed;

        uint256 stability;

        uint256 controllability;

        uint256 explosive;
    }

    struct Commission {

        uint256 rewardTime;

        uint256 rewardType;

        uint256 reward;
    }

    uint256 public cId;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 private randNum;

    address public kickbackAddress = 0xc83D33C262B6AaBB559922dd0f2aE5458acD4689;
    address public vipAddress = address(this);
    address public leagueAddress = 0x5da88e4aeA67Be3Fa8D75BB32dCE23F3c50B04b9;
    address public marketingAddress = 0x85c1c55AbDB5bd78D10ce285ef1c1647F7FFADfa;


    mapping(uint256 => Component) public components;

    mapping(address => uint256[]) public myComponentCids;

    mapping(uint256 => uint256) public cIdToIndexs;

    mapping(address => Commission[]) public myCommissions;

    uint256[6] public rareValue = [10,11,12,13,14,15];

    uint256[5] public epicValue = [16,17,18,19,20];

    uint256[10] public storyValue = [21,22,23,24,25,26,27,28,29,30];

    uint256 public blindBoxPrice = 1 * 10 ** 16;


    uint256 public todayDividends;

    uint256 public topDividends = 10 ** 17;

    mapping(uint256 => mapping(uint256 => uint256)) public settlementTimesToDividends;

    uint256[] public settlementTimesToTime;


    mapping(address => bool) public isController;
    
 
    FOFPlayerNFT FPN;

    constructor() {
        // FPN = FOFPlayerNFT(0x8918337F9aF8BC5a70EE804dc284B1d017665B27);
        FPN = FOFPlayerNFT(0x25894eA4eE6576623Fd8383d6D023dc5219E0553);
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    function setFOFPlayerNFT(address _FOFPlayerNFT) public onlyController {
        FPN = FOFPlayerNFT(_FOFPlayerNFT);
    }

    function setKickbackAddress(address _kickbackAddress) public onlyController {
        kickbackAddress = _kickbackAddress;
    }

    function setVipAddress(address _vipAddress) public onlyController {
        vipAddress = _vipAddress;
    }

    function setLeagueAddress(address _leagueAddress) public onlyController {
        leagueAddress = _leagueAddress;
    }

    function setMarketingAddress(address _marketingAddress) public onlyController {
        marketingAddress = _marketingAddress;
    }

    function setTopDividends(uint256 _topDividends) public onlyController {
        topDividends = _topDividends;
    }

    function setBoxsPrices(uint256 price) public onlyController {
        blindBoxPrice = price;
    }

    function setCId(uint256 _cId) public onlyController {
        cId = _cId;
    }

    function whtidraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function openBlindBox(uint256 types) public payable{

        require(types > 0 && types < 6, "The blind box type does not exist");
       
        require(msg.value == blindBoxPrice, "The price of the blind box is wrong");

        cId++;

        (uint256 rarity,uint256 speed,uint256 stability, uint256 controllability, uint256 explosive) = _getBlindBoxAwardType();

        components[cId] = Component(cId, msg.sender, types, rarity, speed, stability, controllability, explosive);

        cIdToIndexs[cId] = myComponentCids[msg.sender].length;

        myComponentCids[msg.sender].push(cId);

        uint256 price1 = msg.value.mul(44).div(100);
        uint256 price2 = msg.value.mul(30).div(100);
        uint256 price3 = msg.value.mul(16).div(100);
        uint256 price4 = msg.value - price1 - price2 - price3;

        payable(kickbackAddress).transfer(price1);
        payable(vipAddress).transfer(price2);
        payable(leagueAddress).transfer(price3);
        payable(marketingAddress).transfer(price4);

        todayDividends = todayDividends.add(price2);

        if(todayDividends > topDividends){
            _settlement();
        }

        emit OpenBlindBox(msg.sender, msg.value, types, components[cId]);
    }

    function _getBlindBoxAwardType() internal virtual returns (uint256 rarity,uint256 speed,uint256 stability, uint256 controllability, uint256 explosive) {  
        uint256 rarityRandom =  (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender)))) % 100;

        uint256 number;

        if(rarityRandom >= 95){
            rarity = 3;
            speed = storyValue[getRarityValue(10, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 1) * block.number, msg.sender))));
            stability = storyValue[getRarityValue(10, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))));
            controllability = storyValue[getRarityValue(10, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 3) * block.number, msg.sender))));
            explosive = storyValue[getRarityValue(10, number)];
        }else if (rarityRandom >= 70){
            rarity = 2;
            speed = epicValue[getRarityValue(5, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 1) * block.number, msg.sender))));
            stability = epicValue[getRarityValue(5, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))));
            controllability = epicValue[getRarityValue(5, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 3) * block.number, msg.sender))));
            explosive = epicValue[getRarityValue(5, number)];
        }else{
            rarity = 1;
            speed = rareValue[getRarityValue(6, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 1) * block.number, msg.sender))));
            stability = rareValue[getRarityValue(6, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))));
            controllability = rareValue[getRarityValue(6, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 3) * block.number, msg.sender))));
            explosive = rareValue[getRarityValue(6, number)];
        }
        return(rarity, speed, stability, controllability, explosive);
    }

    function getRarityValue(uint256 _length, uint256 number) public pure returns (uint256){
        return number % _length;
    }

    function settlement() public onlyController {
        _settlement();
    }

    function _settlement() internal virtual {
        require(todayDividends > 0, "No dividends to settle");

        settlementTimesToTime.push(block.timestamp);

        uint256 nft1Num = FPN.NFTTypeNumber(1);

        uint256 nft2Num = FPN.NFTTypeNumber(2);

        uint256 nft3Num = FPN.NFTTypeNumber(3);

        if(nft1Num > 0){
            settlementTimesToDividends[settlementTimesToTime.length][1] = todayDividends.mul(50).div(100 * nft1Num);
        }

        if(nft2Num > 0){
            settlementTimesToDividends[settlementTimesToTime.length][2] = todayDividends.mul(30).div(100 * nft2Num);
        }

        if(nft3Num > 0){
            settlementTimesToDividends[settlementTimesToTime.length][3] = todayDividends.mul(20).div(100 * nft3Num);
        }

        todayDividends = 0;
    }

    function whtidrawDividends() public {

        uint256[] memory ids = FPN.getUserNFTIDs(msg.sender);

        uint256 time = block.timestamp;

        uint256 profit;

        uint256 i;

        uint256 j;

        for(i = 0; i < ids.length; i++){
            if(ids[i] != 0){
                for(j = settlementTimesToTime.length; j > 0; j--){
                    if(settlementTimesToTime[j - 1] > FPN.IDToWhtidrawTime(ids[i])){
                        profit = profit.add(settlementTimesToDividends[j][FPN.NFTTypes(ids[i])]);
                    }else{
                        break;
                    }
                }

                FPN.setIDToWhtidrawTime(ids[i], time);
            }
        }

        if(profit > 0){
            payable(msg.sender).transfer(profit);

            myCommissions[msg.sender].push(Commission(time, 1, profit));
        }

        emit WhtidrawDividends(msg.sender, profit);
    }

    function deleteMyComponent(address user, uint256 cid) public onlyController returns(bool) {
        
        require(user == components[cid].holder, "This user is not the owner of the component");

        delete myComponentCids[user][cIdToIndexs[cid]];

        delete components[cid];

        delete cIdToIndexs[cid];

        return true;
    }

    function deleteMyComponents(address user, uint256[] memory cids) public onlyController returns(bool) {

        for(uint256 i = 0; i < cids.length; i++){

            uint256 cid = cids[i];

            require(user == components[cid].holder, "This user is not the owner of the component");

            delete myComponentCids[user][cIdToIndexs[cid]];

            delete components[cid];

            delete cIdToIndexs[cid];
        }

        return true;
    }

    function addMyComponent(uint256 id, address holder, uint256 types, uint256 rarity, uint256 speed, 
    uint256 stability, uint256 controllability, uint256 explosive) public onlyController returns(bool){

        require(components[id].id != id, "The component data has been imported");

        components[id] = Component(id, holder, types, rarity, speed, stability, controllability, explosive);

        cIdToIndexs[id] = myComponentCids[holder].length;

        myComponentCids[holder].push(id);

        return true;
    }

    function addMyCommissions(address user, uint256 rewardTime, uint256 rewardType, uint256 reward) public onlyController returns(bool){
        myCommissions[user].push(Commission(rewardTime, rewardType, reward));
        return true;
    }

    function setSettlementTimesToTime(uint256 time) public onlyController returns(bool){
        settlementTimesToTime.push(time);
        return true;
    }

    function setSettlementTimesToDividends(uint256 index1, uint256 index2, uint256 dividend) public onlyController returns(bool){
        settlementTimesToDividends[index1][index2] = dividend;
        return true;
    }

    function addTodayDividends(uint256 reward) public onlyController returns(bool){
        todayDividends = todayDividends.add(reward);

        if(todayDividends > topDividends){
            _settlement();
        }

        return true;
    }

    function getUserDividends(address user) public view returns(uint256) {

        uint256[] memory ids = FPN.getUserNFTIDs(user);

        uint256 profit;

        uint256 i;

        uint256 j;

        for(i = 0; i < ids.length; i++){
            if(ids[i] != 0){
                for(j = settlementTimesToTime.length; j > 0; j--){
                    if(settlementTimesToTime[j - 1] > FPN.IDToWhtidrawTime(ids[i])){
                        profit = profit.add(settlementTimesToDividends[j][FPN.NFTTypes(ids[i])]);
                    }else{
                        break;
                    }
                }
            }
        }

        return profit;
    }

    function queryMyCommissions(address user) public view returns(Commission[] memory){
        return myCommissions[user];
    }

    function queryMyComponentIds(address user) public view returns(uint256[] memory){
        return myComponentCids[user];
    }

    function queryMyComponent(address user) public view returns(Component[] memory myComponents){
        uint256 count;

        uint256[] memory cids = myComponentCids[user];

        Component[] memory myComponents0 = new Component[](uint256(cids.length));

        for(uint256 i = 0; i < cids.length; i++){
            if(cids[i] != 0){
                myComponents0[count] = components[cids[i]];
                count++;
            }
        }

        myComponents = new Component[](uint256(count));

        for(uint256 i = 0; i < count; i++){
            myComponents[i] = myComponents0[i];
        }

        return myComponents;
    }

    function queryMyComponentByType(address user, uint256 types) public view returns(Component[] memory myComponents){

        uint256 count;

        uint256[] memory cids = myComponentCids[user];

        Component[] memory myComponents0 = new Component[](uint256(cids.length));

        for(uint256 i = 0; i < cids.length; i++){
            if(components[cids[i]].types == types){
                myComponents0[count] = components[cids[i]];
                count++;
            }
        }

        myComponents = new Component[](uint256(count));

        for(uint256 i = 0; i < count; i++){
            myComponents[i] = myComponents0[i];
        }

        return myComponents;
    }
    
}
// File: FOFPlayerController2.sol



pragma solidity ^0.8.0;





contract FOFPlayerController2 is Ownable {

    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);

    event MergeVehicle(address from, uint256[] burnIds, Vehicle vehicle);

    
    struct Vehicle {
        uint256 tokenId;

        uint256 types;

        uint256 speed;

        uint256 stability;

        uint256 controllability;

        uint256 explosive;

        uint256 attribute;
    }

    
    mapping(uint256 => Vehicle) public vehicles;

    mapping(uint256 => uint256) public tokenIdToStatus;

    mapping(uint256 => bool) public openVehicleMerge;


    mapping(address => bool) public isController;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
 
    FOFPlayerNFT FPN;

    FOFPlayerController1 FPC;

    constructor() {
        // FPN = FOFPlayerNFT(0x8918337F9aF8BC5a70EE804dc284B1d017665B27);
        // FPC = FOFPlayerController1(payable(0x74b58b15da0F0073069EB7e585ADb17Dc2330EF4));
        FPN = FOFPlayerNFT(0x25894eA4eE6576623Fd8383d6D023dc5219E0553);
        FPC = FOFPlayerController1(payable(0x50E79435Bb54564E8F6d0BBa2B841027C77B8824));

        openVehicleMerge[101] = true;
        openVehicleMerge[102] = true;
        openVehicleMerge[103] = true;
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    function setFOFPlayerNFT(address _FOFPlayerNFT) public onlyController {
        FPN = FOFPlayerNFT(_FOFPlayerNFT);
    }

    function setFOFPlayerController1(address _FOFPlayerController1) public onlyController {
        FPC = FOFPlayerController1(payable(_FOFPlayerController1));
    }

    function openopenVehicleMerge(uint256 VehicleType, bool open) public onlyController {
        openVehicleMerge[VehicleType] = open;
    }

    function mergeVehicle(uint256[] memory cIds) public returns (uint256) {

        require(checkCids(cIds), "The selected parts cannot be synthesized into vehicles");

        require(openVehicleMerge[101], "Vehicle synthesis of this type is not available");

        (uint256 speed,uint256 stability, uint256 controllability,uint256 explosive) = countVehicleAttribute(cIds);

        uint256 attribute = speed.add(stability).add(controllability).add(explosive);

        FPC.deleteMyComponents(msg.sender, cIds);

        uint256 tokenId = FPN.createNFT(msg.sender, 101);

        vehicles[tokenId] = Vehicle(tokenId, 101, speed, stability, controllability, explosive, attribute);

        emit MergeVehicle(msg.sender, cIds, vehicles[tokenId]);

        return tokenId;
    }

    function mergeAdvancedVehicle(uint256[] memory tokenIds) public returns (uint256) {

        require(tokenIds[0] != tokenIds[1], "The vehicle types don't match");

        require(FPN.ownerOf(tokenIds[0]) == msg.sender && FPN.ownerOf(tokenIds[1]) == msg.sender , "You are not the owner of the vehicle");

        require(FPN.NFTTypes(tokenIds[0]) == FPN.NFTTypes(tokenIds[1]) && FPN.NFTTypes(tokenIds[0]) > 100, "The vehicle types don't match");

        require(tokenIdToStatus[tokenIds[0]] == 0 && tokenIdToStatus[tokenIds[1]] == 0, "Vehicles are unavailable");

        uint256 types = FPN.NFTTypes(tokenIds[0]) + 1;

        require(openVehicleMerge[types], "Vehicle synthesis of this type is not available");

        uint256 tokenId = FPN.createNFT(msg.sender, types);

        (uint256 speed,uint256 stability, uint256 controllability,uint256 explosive) = countVehicleAttribute2(tokenIds);

        uint256 attribute = speed.add(stability).add(controllability).add(explosive);

        vehicles[tokenId] = Vehicle(tokenId, types, speed, stability, controllability, explosive, attribute);

        delete vehicles[tokenIds[0]];

        delete vehicles[tokenIds[1]];

        FPN.approveToController(msg.sender, tokenIds[0]);

        FPN.approveToController(msg.sender, tokenIds[1]);

        FPN.transferFrom(msg.sender, deadWallet, tokenIds[0]);

        FPN.transferFrom(msg.sender, deadWallet, tokenIds[1]);

        emit MergeVehicle(msg.sender, tokenIds, vehicles[tokenId]);

        return tokenId;
    }

    function setNFTStatus(uint256 tokenId, uint256 status) public onlyController returns (bool) {
        tokenIdToStatus[tokenId] = status;
        return true;
    }

    function countVehicleAttribute(uint256[] memory cIds) public view returns(uint256,uint256,uint256,uint256) {

        uint256 speed;
        uint256 stability;
        uint256 controllability;
        uint256 explosive;

        for(uint256 i = 0; i < 5; i++){

            (,,,,uint256 speed0,uint256 stability0,uint256 controllability0,uint256 explosive0) = FPC.components(cIds[i]);

            speed = speed.add(speed0);
            stability = stability.add(stability0);
            controllability = controllability.add(controllability0);
            explosive = explosive.add(explosive0);
        }

        return (speed,stability,controllability,explosive);
    }

    function countVehicleAttribute2(uint256[] memory tokenIds) public view returns(uint256,uint256,uint256,uint256) {

        Vehicle memory vehicle0 = vehicles[tokenIds[0]];
        Vehicle memory vehicle1 = vehicles[tokenIds[1]];

        uint256 speed = vehicle0.speed.add(vehicle1.speed).mul(3).div(2);
        uint256 stability = vehicle0.stability.add(vehicle1.stability).mul(3).div(2);
        uint256 controllability = vehicle0.controllability.add(vehicle1.controllability).mul(3).div(2);
        uint256 explosive = vehicle0.explosive.add(vehicle1.explosive).mul(3).div(2);

        return (speed,stability,controllability,explosive);
    }

    function checkCids(uint256[] memory cIds) public view returns(bool) {

        uint256 i;

        uint256 j;

        uint256 counter;

        for(i = 0; i < 5; i++){

            (,,uint256 types,,,,,) = FPC.components(cIds[i]);

            for(j = 1; j < 6; j++){
                if(types == j){
                    counter  = counter.add(j);
                }
            }
        }

        if(counter == 15){
            return true;
        }

        return false; 
    }

    function getUserNFTIDs(address user) public view returns(uint256[] memory NFTIDs) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];
        }

        return (NFTIDs);
	}

    function getUserNFTIDsAndTypes(address user) public view returns(uint256[] memory NFTIDs, uint256[] memory types) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        types = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];

            types[i] = FPN.NFTTypes(NFTIDs[i]);
        }

        return (NFTIDs,types);
	}

    function getUserNFTIDsByType(address user, uint256 NFTType) public view returns(uint256[] memory NFTIDs) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0 && FPN.NFTTypes(NFTIDs0[i]) == NFTType){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];
        }

        return NFTIDs;
	}

    function getUserVehicles(address user) public view returns(Vehicle[] memory myVehicles) {

		uint256[] memory NFTIDs = getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs.length; i++){
            if(FPN.NFTTypes(NFTIDs[i]) > 100){

                NFTIDs1[counter] = NFTIDs[i];

                counter++;
            }
        }

        myVehicles = new Vehicle[](uint256(counter));

        for(i = 0; i < counter; i++){
            myVehicles[i] = vehicles[NFTIDs1[i]];
        }

        return myVehicles;
	}

    function getUserVehiclesByType(address user, uint256 NFTType) public view returns(Vehicle[] memory myVehicles) {

		uint256[] memory NFTIDs = getUserNFTIDsByType(user, NFTType);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs.length; i++){
            if(FPN.NFTTypes(NFTIDs[i]) == NFTType){

                NFTIDs1[counter] = NFTIDs[i];

                counter++;
            }
        }

        myVehicles = new Vehicle[](uint256(counter));

        for(i = 0; i < counter; i++){
            myVehicles[i] = vehicles[NFTIDs1[i]];
        }

        return myVehicles;
	}

    function getUserNFTs(address user) public view returns(uint256[] memory NFTIDs, uint256[] memory types, uint256[] memory NFTStatus) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        types = new uint256[](uint256(counter));

        NFTStatus = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];

            types[i] = FPN.NFTTypes(NFTIDs[i]);

            NFTStatus[i] = tokenIdToStatus[NFTIDs1[i]];
        }

        return (NFTIDs,types,NFTStatus);
	}

    function getUserNFTsByType(address user, uint256 NFTType) public view returns(uint256[] memory NFTIDs, uint256[] memory types, uint256[] memory NFTStatus) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0 && FPN.NFTTypes(NFTIDs0[i]) == NFTType){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        types = new uint256[](uint256(counter));

        NFTStatus = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){

            NFTIDs[i] = NFTIDs1[i];

            types[i] = FPN.NFTTypes(NFTIDs[i]);

            NFTStatus[i] = tokenIdToStatus[NFTIDs1[i]];
        }

        return (NFTIDs,types,NFTStatus);
	}

}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: FOFPlayerRaceQuery.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;





contract FOFPlayerRaceQuery is Ownable {

    using SafeMath for uint256;


    address public USDT = 0x55d398326f99059fF775485246999027B3197955;

    address public FOF = 0x5aB6f89Bf100E8a5162f3eA58cD696AA4Fdc3E95;

    address public pancakeswapV2Pair = 0xA20FB350F7C7674a978574B7404EDEC9aa1dbAe3;

    FOFPlayerNFT FPN;

    FOFPlayerController2 FPC2;

    FOFPlayerRaceData FPRD;

    constructor() {
        FPN = FOFPlayerNFT(0x59FDE0bb581D0F0F24518921b04F68f1d763fB69);
        FPC2 = FOFPlayerController2(payable(0x3c9ffD06fa3adE6bCBb7B409d66741a2A52f094d));
        FPRD = FOFPlayerRaceData(payable(0x574B8A24Ac72dA402F770061703E7249d3701415));
    }

    function setFOFPlayerNFT(address _FOFPlayerNFT) public onlyOwner {
        FPN = FOFPlayerNFT(_FOFPlayerNFT);
    }

    function setFOFPlayerController2(address _FOFPlayerController2) public onlyOwner {
        FPC2 = FOFPlayerController2(payable(_FOFPlayerController2));
    }

    function setFOFPlayerRaceData(address _FOFPlayerRaceData) public onlyOwner {
        FPRD = FOFPlayerRaceData(payable(_FOFPlayerRaceData));
    }

    function setUSDT(address _USDT) public onlyOwner {
        USDT = _USDT;
    }

    function setFOF(address _FOF) public onlyOwner {
        FOF = _FOF;
    }

    function setPancakeswapV2Pair(address _pancakeswapV2Pair) public onlyOwner {
        pancakeswapV2Pair = _pancakeswapV2Pair;
    }

    function rankRaceRewards(uint256 reward) public view returns(uint256[] memory rewards) {

        rewards = new uint256[](uint256(7));

        rewards[0] = reward.mul(40).div(100);
        rewards[1] = reward.mul(35).div(100);
        rewards[2] = reward.mul(25).div(100);

        uint256 reward2 = USDTEqualsToToken(1 * 10 ** 18);

        rewards[3] = reward2;
        rewards[4] = reward2;
        rewards[5] = reward2;
        rewards[6] = reward2;
        
        return rewards;
    }

    function raceRewards(uint256 reward) public pure returns(uint256[] memory rewards,uint256[] memory clubRewards) {

        rewards = new uint256[](uint256(10));
        clubRewards = new uint256[](uint256(10));

        rewards[0] = reward.mul(60 * 50).div(10000);
        rewards[1] = reward.mul(60 * 30).div(10000);
        rewards[2] = reward.mul(60 * 20).div(10000);

        clubRewards[0] = reward.mul(20 * 50).div(10000);
        clubRewards[1] = reward.mul(20 * 30).div(10000);
        clubRewards[2] = reward.mul(20 * 20).div(10000);

        uint256 i;

        uint256 reward0;

        for(i = 3; i < 10; i++){
            reward0 = reward.mul(10).div(700);
            rewards[i] = reward0;
            clubRewards[i] = reward0;
        }

        return (rewards,clubRewards);
    }

    function USDTEqualsToToken(uint256 USDTAmount) public view returns(uint256) {
        
        uint256 tokenOfPair = ERC20(FOF).balanceOf(pancakeswapV2Pair);
        uint256 USDTOfPair = ERC20(USDT).balanceOf(pancakeswapV2Pair);

        // uint256 tokenOfPair = 100;
        // uint256 USDTOfPair = 200;

        if(USDTOfPair == 0){
            return 0;
        }

        uint256 amount = USDTAmount.mul(tokenOfPair).div(USDTOfPair);

        return amount;
    }

    function ticketDivided(uint256 ticketPrice) public pure returns(uint256,uint256,uint256,uint256){
        uint256 rank = ticketPrice.mul(70).div(100);
        uint256 repo = ticketPrice.mul(12).div(100);
        uint256 league = ticketPrice.mul(5).div(100);
        uint256 maket = ticketPrice.sub(rank).sub(repo).sub(league * 3);
        
        return (rank,repo,maket,league);
    }

    function fuelDivided(uint256 fuelPrices) public pure returns(uint256,uint256){
        uint256 maket = fuelPrices.mul(10).div(100);
        // uint256 union = fuelPrices.mul(5).div(100);
        uint256 burn = fuelPrices.sub(maket * 4);
        
        return (burn,maket);
    }

    function getfuelPrice() public view returns(uint256 fuelPrice){
        fuelPrice = USDTEqualsToToken(FPRD.fuelPrice());
        return fuelPrice;
    }

    function findMemberIndex(uint256 clubId, address member) public view returns(uint256) {

        uint256 i;

        for(i = 0; i < FPRD.getClubMembers(clubId).length; i++){

            if(member == FPRD.clubMembers(clubId, i)){
                return i + 1;
            }
        }

        return 0;
    }

    function checkIsRaceTime(uint256 raceType) public view returns(bool) {

        uint256 time = block.timestamp;

        if(raceType == 1){

            if((FPRD.raceTime(1, 1) < time.mod(24 hours) && time.mod(24 hours) < FPRD.raceTime(1, 1) + FPRD.raceDurations(1))
            || (FPRD.raceTime(1, 2) < time.mod(24 hours) && time.mod(24 hours) < FPRD.raceTime(1, 2) + FPRD.raceDurations(1))
            || (FPRD.raceTime(1, 3) < time.mod(24 hours) && time.mod(24 hours) < FPRD.raceTime(1, 3) + FPRD.raceDurations(1))){
                return true;
            }
        }

        if(raceType == 2 || raceType == 3){
            if((FPRD.raceTime(raceType, FPRD.raceIds(raceType)) < time && time < FPRD.raceTime(raceType, FPRD.raceIds(raceType)) + FPRD.raceDurations(raceType))){
                return true;
            }
        }

        return false;
    }

    function getClubMembers(address user) public view returns(address[] memory members) {

        uint256[] memory clubIds = FPC2.getUserNFTIDsByType(user, 4);

        members = getClubMembers(clubIds[0]);

        return members;
    }

    function getClubMembers(uint256 clubId) public view returns(address[] memory members) {

        address[] memory members0 = new address[](uint256(FPRD.getClubMembers(clubId).length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < FPRD.getClubMembers(clubId).length; i++){

            if(FPRD.clubMembers(clubId, i) != address(0)){
                members0[counter] = FPRD.clubMembers(clubId, i);
                counter++;
            }
        }

        members = new address[](uint256(counter));

        for(i = 0; i < counter; i++){
            members[i] = members0[i];
        }

        return members;
    }

    function getClubMemberLists(address user) public view returns(string[] memory nicknames, address[] memory members, 
    uint256[] memory vehicleNums, uint256[3] memory raceMembersIndexs, uint256 raceType) {

        if(block.timestamp < FPRD.raceTime(2, FPRD.raceIds(2)) &&  block.timestamp + 24 hours > FPRD.raceTime(2, FPRD.raceIds(2))){
            raceType = 2;
        }else if(block.timestamp < FPRD.raceTime(3, FPRD.raceIds(3)) &&  block.timestamp + 24 hours > FPRD.raceTime(3, FPRD.raceIds(3))){
            raceType = 3;
        }

        uint256[] memory clubIds = FPC2.getUserNFTIDsByType(user, 4);

        members = getClubMembers(clubIds[0]);

        nicknames = new string[](uint256(members.length));

        vehicleNums = new uint256[](uint256(members.length));

        address[3] memory raceMembers = FPRD.getClubRaceMembers(clubIds[0]);

        uint256 i;
        uint256 j;
        uint256 counter;

        for(i = 0; i < members.length; i++){
            nicknames[i] = FPRD.nicknames(members[i]);

            vehicleNums[i] = getUserVehicleNum(members[i]);

            // if(raceType == 2 || raceType == 3){
                for(j = 0; j < 3; j++){
                    if(members[i] == raceMembers[j]){
                        raceMembersIndexs[counter] = i + 1;
                        counter++;
                    }
                }
            // }
        }

        return (nicknames,members,vehicleNums,raceMembersIndexs,raceType);
    }

    function getClubSignUpMemberLists(address user,uint256 raceType) public view returns(string[] memory nicknames, address[] memory members, uint256[] memory vehicleType) {

        uint256[] memory tokenIds = FPRD.getRaceVehicles(raceType, FPRD.raceIds(raceType));

        uint256[] memory clubIds = FPC2.getUserNFTIDsByType(user, 4);

        address[3] memory raceMembers = FPRD.getClubRaceMembers(clubIds[0]);

        uint256[] memory tokenIds0 = new uint256[](uint256(tokenIds.length));

        uint256 i;
        uint256 j;
        uint256 counter;

        for(i = 0; i < 3; i++){

            for(j = 0; j < tokenIds.length; j++){

                address member = FPN.ownerOf(tokenIds[j]);

                if(member == raceMembers[i]){
                    tokenIds0[counter] = tokenIds[j];
                    counter++;
                }
            }
        }

        nicknames = new string[](uint256(counter));

        members = new address[](uint256(counter));

        vehicleType = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){

            members[i] = FPN.ownerOf(tokenIds0[i]);

            nicknames[i] = FPRD.nicknames(members[i]);

            vehicleType[i] = FPN.NFTTypes(tokenIds0[i]);
        }

        return (nicknames,members,vehicleType);
    }

    function getUserVehicleNum(address user) public view returns(uint256) {

        uint256 vehicleNum1 = getUserNFTNumByType(user, 101);
        uint256 vehicleNum2 = getUserNFTNumByType(user, 102);
        uint256 vehicleNum3 = getUserNFTNumByType(user, 103);
        uint256 vehicleNum4 = getUserNFTNumByType(user, 104);
        uint256 vehicleNum5 = getUserNFTNumByType(user, 105);
        uint256 vehicleNum6 = getUserNFTNumByType(user, 106);

        return vehicleNum1.add(vehicleNum2).add(vehicleNum3).add(vehicleNum4).add(vehicleNum5).add(vehicleNum6);
    }

    function getUserNFTNumByType(address user, uint256 types) public view returns(uint256) {
        uint256[] memory NFTIDs = FPC2.getUserNFTIDsByType(user, types);
        return NFTIDs.length;
    }

    function checkRaceMember(uint256 clubId, address member) public view returns(bool) {

        uint256 i;

        for(i = 0; i < 3; i++){

            if(member == FPRD.clubRaceMembers(clubId, i)){
                return true;
            }
        }

        return false;
    }

    function getNFTIdsByType(uint256 types) public view returns(uint256[] memory ids) {

        uint256 total = FPN.counter();

        uint256[] memory ids0 = new uint256[](uint256(total));

        uint256 counter;

        uint256 i;

        for(i = 1; i <= total; i++){

            if(FPN.NFTTypes(FPN.NFTIDs(i)) == types){

                ids0[counter] = FPN.NFTIDs(i);

                counter++;
            }
        }

        ids = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            ids[i] = ids0[i];
        }

        return ids;
    }

    function getNFTByType(uint256 types) public view returns(uint256[] memory ids, string[] memory cardNicknames) {

        ids = getNFTIdsByType(types);

        cardNicknames = new string[](uint256(ids.length));

        uint256 i;

        for(i = 0; i < ids.length; i++){
            cardNicknames[i] = FPRD.cardNicknames(ids[i]);
        }

        return (ids,cardNicknames);
    }

    function getNFTByUserAndType(address user, uint256 types) public view returns(uint256[] memory ids, string[] memory cardNicknames, uint256 index) {

        uint256[] memory cardIds = FPC2.getUserNFTIDsByType(user, types);

        ids = getNFTIdsByType(types);

        cardNicknames = new string[](uint256(ids.length));

        uint256 i;

        for(i = 0; i < ids.length; i++){
            cardNicknames[i] = FPRD.cardNicknames(ids[i]);
            if(cardIds.length > 0 && cardIds[0] == ids[i]){
                index = i + 1;
            }
        }

        return (ids,cardNicknames,index);
    }

    function raceRankingLists(uint256 raceType,uint256 raceId) public view returns(address[] memory racers, string[] memory nicknames,
    uint256[] memory clubIds, string[] memory cardNicknames,uint256[] memory vehicleTypes,uint256[] memory rewards,uint256[] memory fofRewards) {

        uint256[] memory vehicleIds = raceRanking(raceType, raceId);

        racers = new address[](uint256(vehicleIds.length));
        nicknames = new string[](uint256(vehicleIds.length));
        clubIds = new uint256[](uint256(vehicleIds.length));
        cardNicknames = new string[](uint256(vehicleIds.length));
        vehicleTypes = new uint256[](uint256(vehicleIds.length));
        rewards = new uint256[](uint256(vehicleIds.length));
        fofRewards = new uint256[](uint256(vehicleIds.length));

        uint256 i;

        for(i = 0; i < vehicleIds.length; i++){

            racers[i] = FPN.ownerOf(vehicleIds[i]);
            nicknames[i] = FPRD.nicknames(racers[i]);
            clubIds[i] = FPRD.memberToClubIds(racers[i]);
            cardNicknames[i] = FPRD.cardNicknames(clubIds[i]);
            vehicleTypes[i] = FPN.NFTTypes(vehicleIds[i]);

            (rewards[i],fofRewards[i]) = raceReward(raceType,raceId,i);
        } 

        return (racers,nicknames,clubIds,cardNicknames,vehicleTypes,rewards,fofRewards);
    }

    function raceRankingLists2(uint256 raceType,uint256 index) public view returns(address[] memory racers, string[] memory nicknames,
    uint256[] memory clubIds, string[] memory cardNicknames,uint256[] memory vehicleTypes,uint256[] memory rewards,uint256[] memory fofRewards) {

        (racers,nicknames,clubIds,cardNicknames,vehicleTypes,rewards,fofRewards) = raceRankingLists(raceType, FPRD.raceIds(raceType) + 1 - index);

        return (racers,nicknames,clubIds,cardNicknames,vehicleTypes,rewards,fofRewards);
    }

    function raceReward(uint256 raceType,uint256 raceId,uint256 index) public view returns(uint256, uint256){

        uint256 reward = FPRD.raceReward(raceType, raceId);

        if(raceType == 1){
            uint256[] memory rewards = rankRaceRewards(reward);

            return (rewards[index],0);
        }else if(raceType == 2 || raceType == 3){
            uint256 fofReward = FPRD.fofRaceReward(raceType, raceId);

            (uint256[] memory rewards,) = raceRewards(reward);

            (uint256[] memory foRrewards,) = raceRewards(fofReward);

            return (rewards[index],foRrewards[index]);
        }

        return (0,0);
    }

    function raceRankingRacers(uint256 raceType,uint256 raceId) public view returns(address[] memory racers) {

        uint256[] memory vehicleIds = raceRanking(raceType,raceId);

        racers = new address[](uint256(vehicleIds.length));

        uint256 i;

        for(i = 0; i < vehicleIds.length; i++){
            racers[i] = FPN.ownerOf(vehicleIds[i]);
        } 

        return racers;
    }

    function raceRankingClubOwners(uint256 raceType,uint256 raceId) public view returns(address[] memory clubOwners) {

        uint256[] memory vehicleIds = raceRanking(raceType,raceId);

        clubOwners = new address[](uint256(vehicleIds.length));

        uint256 i;

        for(i = 0; i < vehicleIds.length; i++){
            clubOwners[i] = FPN.ownerOf(FPRD.memberToClubIds(FPN.ownerOf(vehicleIds[i])));
        } 

        return clubOwners;
    }

    function raceRanking(uint256 raceType,uint256 raceId) public view returns(uint256[] memory vehicleIds) {

        uint256[] memory vehicleIds0 = FPRD.getRaceVehicles(raceType, raceId);

        if(raceType == 1){
            require(vehicleIds0.length >= 7, "Insufficient vehicles for the race");
        }else{
            require(vehicleIds0.length >= 10, "Insufficient vehicles for the race");
        }

        uint256[] memory arr = new uint256[](uint256(vehicleIds0.length));

        uint256 i;

        for(i = 0; i < vehicleIds0.length; i++){
            (,,,,,,arr[i]) = FPC2.vehicles(vehicleIds0[i]);
        }

        vehicleIds = sort(arr,vehicleIds0);

        return vehicleIds;
    }

    function getRaceVehicles(uint256 raceType,uint256 raceId) public view returns(bool) {

        uint256[] memory tokenIds = FPRD.getRaceVehicles(raceType, raceId);

        if(raceType == 1 && tokenIds.length >= 7){
            return true;
        }

        if((raceType == 2 || raceType == 3) && tokenIds.length >= 10){
            return true;
        }

        return false;
    }

    function getRaceVehiclesIndex(uint256 raceType,uint256 raceId,uint256 vehicleId) public view returns(uint256) {

        uint256[] memory tokenIds = FPRD.getRaceVehicles(raceType, raceId);

        uint256 i;

        for (i = 0; i < tokenIds.length; i++){
            if(vehicleId == tokenIds[i]){
                return i + 1;
            }
        }
        return 0;
    }

    function getRankRaceTime() public view returns(uint256[3] memory startTime, uint256[3] memory endTime) {

        uint256 i;

        for(i = 0; i < 3; i++){
            startTime[i] = FPRD.raceTime(1,i + 1).mod(24 hours);

            endTime[i] = startTime[i] + FPRD.raceDurations(1);
        }

        return (startTime, endTime);
    }

    function getUserClubDividends(address user) public view returns(uint256 profit, uint256 fofProfit) {

        uint256[] memory clubIds = FPC2.getUserNFTIDsByType(user, 4);

        uint256 i;

        if(clubIds.length > 0 && clubIds[0] != 0){
            for(i = FPRD.getSettlementTimesToTime().length; i > 0; i--){
                if(FPRD.settlementTimesToTime(i - 1) > FPN.IDToWhtidrawTime(clubIds[0])){
                    profit = profit.add(FPRD.settlementTimesToDividends(i,4));
                    fofProfit = fofProfit.add(FPRD.settlementTimesToFofDividends(i,4));
                }else{
                    break;
                }
            }
        }

        return (profit,fofProfit);
    }

    function checkCanSignUpRank(address user, uint256 vehicleId) public view returns(uint256) {
        return checkCanSignUpRank(user, FPRD.raceIds(1), vehicleId);
    }

    function checkCanSignUpRank(address user, uint256 raceId, uint256 vehicleId) public view returns(uint256) {

        if(!checkIsRaceTime(1)) return 1;//"Now is not the time of the race"

        if(FPN.ownerOf(vehicleId) != user) return 2;//"You are not the owner"

        if(FPC2.tokenIdToStatus(vehicleId) != 0) return 3;//"The vehicle you selected is unavailable"

        if(FPRD.userRaceLeftTimes(user) == 0) return 4;//"You have run out of race times"

        if(FPRD.getRaceVehicles(1, raceId).length >= 7) return 5;//"Registration for this race is full"

        if(getRaceVehiclesIndex(1, raceId, vehicleId) > 0) return 6;//"You have already signed up for this race"

        if(FPN.NFTTypes(vehicleId) < 101) return 7;//"The type of card you choose is not a vehicle"

        if(FPRD.userTodayRaceTimes(msg.sender) >= 20) return 8;//"You have run out of game times for today"

        return 0;
    }

    function checkCanSignUp(address user, uint256 raceType, uint256 vehicleId) public view returns(uint256) {
        return checkCanSignUp(user, raceType, FPRD.raceIds(raceType), vehicleId);
    }

    function checkCanSignUp(address user, uint256 raceType, uint256 raceId,uint256 vehicleId) public view returns(uint256) {

        if(raceType != 2 && raceType != 3) return 1;//"You entered the wrong race type"

        if(!checkIsRaceTime(raceType)) return 2;//"Now is not the time of the race"

        if(FPN.ownerOf(vehicleId) != user) return 3;//"You are not the owner"

        if(FPC2.tokenIdToStatus(vehicleId) != 0) return 4;//"The vehicle you selected is unavailable"

        if(!checkRaceMember(FPRD.memberToClubIds(user), user)) return 5;//"You are not eligible"

        if(FPRD.getRaceVehicles(raceType, raceId).length >= 150) return 6;//"Registration for this race is full"

        if(getRaceVehiclesIndex(raceType, raceId, vehicleId) > 0) return 7;//"You have already signed up for this race"

        if(FPN.NFTTypes(vehicleId) < 101) return 8;//"The type of card you choose is not a vehicle"

        return 0;
    }

    function checkCanBuyFuel(address user) public view returns(uint256) {

        if(getUserVehicleNum(user) == 0) return 1;

        if(FPRD.userRaceLeftTimes(user) > 0) return 2;

        if(FPRD.userTodayRaceTimes(user) >= 20) return 3;

        return 0;
    }

    function sort(uint256[] memory arr, uint256[] memory vehicleIds) public pure returns(uint256[] memory) {

        require(arr.length == vehicleIds.length , "Sorted arrays have different lengths");

        uint256 i;

        uint256 j;

        uint256 temp;

        for (i = 0; i < arr.length; i++){

            for (j = 0; j < arr.length -  i - 1; j++){
                
                if (arr[j] < arr[j + 1]){

                    temp = arr[j + 1];

                    arr[j + 1] = arr[j];

                    arr[j] = temp;

                    temp = vehicleIds[j + 1];

                    vehicleIds[j + 1] = vehicleIds[j];

                    vehicleIds[j] = temp;
                }
            }
        }

        if(vehicleIds.length > 10){
            uint256[] memory tokenIds = new uint256[](uint256(10));

            for (i = 0; i < 10; i++){
                tokenIds[i] = vehicleIds[i];
            }

            return tokenIds;
        }

        return vehicleIds;
    }

}