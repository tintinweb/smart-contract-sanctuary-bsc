/**
 *Submitted for verification at BscScan.com on 2022-10-19
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

// File: FFFController.sol



pragma solidity ^0.8.0;




interface ISwapRouter {
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract FFFController is Ownable {

    using SafeMath for uint256;

    event ActivateNode(address account, uint256 nodeId, uint256 tokenId, uint256 newPower);
    event BuyNode(address account, uint256 nodeId, uint256 tokenCost, uint256 newPower);
    event BuyPower(address account, uint256 tokenType, uint256 amount, uint256 power);
    event DrawNodeTokenRelease(address account, uint256 nodeId, uint256 timeRelease, uint256 priceRelease);
    event DrawNodeProfit(address account, uint256 nodeId, uint256 profit);
    event DrawNodeRecommendeProfit(address account, uint256 nodeId, uint256 profit);
    event DrawPowerRecommendeProfit(address account, uint256 nodeId, uint256 profit);
    event DrawMiningToken(address account, uint256 power, uint256 profit);
    event BindRecommender(address account, address recommender);
    event UpgradeUserLevel(address account, uint256 preLevel, uint256 newLevel);

    mapping(address => address[]) public invitees;

    mapping(address => address) public myRecommender;

    mapping(address => uint256) public bindTime;

    mapping(address => uint256) public userPower;

    mapping(address => uint256) public underPower;

    mapping(address => uint256) public userNodeLevel;

    mapping(uint256 => uint256) public nodeLevelUserAmount;

    mapping(uint256 => uint256) public nodeTypeUserAmount;

    address[] public registers;

    mapping(address => uint256) public registerTime;

    mapping(address => uint256) public userMiningProfits;

    mapping(address => uint256) public userNodeRecommendeProfits;

    mapping(address => uint256) public userDrawNodeRecommendeProfits;

    mapping(address => uint256) public userPowerRecommendeProfits;

    mapping(address => uint256) public userDrawPowerRecommendeProfits;

    mapping(address => uint256) public userDrawNodeTokenDividend;

    mapping(address => uint256) public userDrawNodeLevelTokenDividend;

    mapping(address => uint256) public userDrawNodeTokenDividendLastAmount;

    mapping(address => uint256) public userDrawNodeLevelTokenDividendLastAmount;

    mapping(address => uint256) public userTeamId;

    mapping(address => uint256) public nodeIds;

    mapping(uint256 => address) public nodeIdToAddress;

    mapping(uint256 => uint256) public nodeOpenTime;

    mapping(uint256 => uint256) public nodePrice;

    mapping(uint256 => uint256) public nodeTokenReward;

    mapping(uint256 => uint256) public tokenForTimeRelease;

    mapping(uint256 => uint256) public tokenForPriceRelease;

    mapping(uint256 => bool) public nftIsActive;

    mapping(uint256 => uint256) public nodeID;

    mapping(uint256 => uint256) public openNodeUnderPowerLimit;

    mapping(uint256 => uint256) public nftActivePowerAwards;

    mapping(uint256 => uint256) public powerPrices;

    mapping(address => uint256) public drawTime;

    address[5] public marketingAddress;

    string public baseLink;

    uint256 public forceInitialPrice;

    uint256 public _nodeRecommendFee = 3000;
    uint256 public _nodeMarketingFee = 2000;
    uint256 public _buyPowerRecommendFee = 4000;
    uint256 public _buyPowerMarketingFee = 1000;

    uint256 public powerRecommendRewardRate = 7500;
    uint256 public powerRecommendUsdtRewardRate = 125;

    uint256 public perBlockMining = 43 * 10 ** 18;
    uint256 public _newUserFee = 3500;

    uint256 public buyPowerfofDiscount = 8000;

    uint256[5] public levelPowerLimit = [100,200,300,500,1000];
    uint256[5] public levelInviteesLimit = [3,6,10,15,20];
    uint256[5] public levelUnderPowerLimit = [3000,5000,20000,30000,50000];
    
    uint256[5] public nodeLevelDividendRate = [1000,3400,3000,1600,1000];
    uint256[5] public levelPowerRate = [300,600,900,1500,3000];

    //nodeTokenDividend
    uint256 public nodeTokenDividend;
    uint256 public nodeTokenDividendRateForLevel = 7692;
    uint256[2] public nodeTokenDividendRateForNodeType = [1539,769];

    //data
    mapping(uint256 => uint256) public nodeProfit;
    mapping(uint256 => uint256) public nodeProfitToday;
    uint256 public nodeProfitLastTime;

    uint256 public totalPower;
    uint256 public miningTotal;
    
    address public withdrawAddress;

    address public deadWallet = address(0x000000000000000000000000000000000000dEaD);
    
    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    address public fofPair;
    address public forcePair;

    ERC20 fof;
    ERC20 force;
    ERC20 usdt;
    FOFPlayerNFT fNft;

    ISwapRouter public _swapRouter;

    mapping(address => bool) public isController;

    constructor() {

        fof = ERC20(0xa1Cf6214D17771B25DAF2aA7802c159F40921119);
        force = ERC20(0x503c9Cfa6ED22D1A971A246bc4D106711436D26b);
        usdt = ERC20(0x55d398326f99059fF775485246999027B3197955);

        fNft = FOFPlayerNFT(0x59FDE0bb581D0F0F24518921b04F68f1d763fB69);

        fofPair = address(0x3559179416b6F1ae70cD87c20C5b499c1F1A9930);
        forcePair = address(0x8cE3623e8F008272CD2aE6216C032A6C8cf1f2c7);

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        usdt.approve(address(_swapRouter), 10000000000 * 10 ** 18);

        withdrawAddress = address(0x1f856398b29Ef714eEc91cBb523506F4B7AE4A9A);

        //teamLeader
        nodeIds[address(0x16ED80289204B6f79Fe34bB2aAe3E55A6D9aF4bC)] = 1001;
        nodeIds[address(0x40ce528D121e547ABc0CADbF00A8ac90ab004452)] = 1002;
        nodeIds[address(0x790171d197787F0715dcF01871ff2c6C5D8700D1)] = 1003;

        nodeIdToAddress[1001] = address(0x16ED80289204B6f79Fe34bB2aAe3E55A6D9aF4bC);
        nodeIdToAddress[1002] = address(0x40ce528D121e547ABc0CADbF00A8ac90ab004452);
        nodeIdToAddress[1003] = address(0x790171d197787F0715dcF01871ff2c6C5D8700D1);

        userTeamId[address(0x16ED80289204B6f79Fe34bB2aAe3E55A6D9aF4bC)] = 1001;
        userTeamId[address(0x40ce528D121e547ABc0CADbF00A8ac90ab004452)] = 1002;
        userTeamId[address(0x790171d197787F0715dcF01871ff2c6C5D8700D1)] = 1003;

        userPower[address(0x16ED80289204B6f79Fe34bB2aAe3E55A6D9aF4bC)] = 1000;
        userPower[address(0x40ce528D121e547ABc0CADbF00A8ac90ab004452)] = 1000;
        userPower[address(0x790171d197787F0715dcF01871ff2c6C5D8700D1)] = 1000;

        nodeOpenTime[1001] = block.timestamp;
        nodeOpenTime[1002] = block.timestamp;
        nodeOpenTime[1003] = block.timestamp;

        nodeID[1] = 1003;
        nodeID[2] = 5000;

        nodePrice[1] = 500 * 10 ** 18;
        nodePrice[2] = 300 * 10 ** 18;

        openNodeUnderPowerLimit[1] = 200;
        openNodeUnderPowerLimit[2] = 100;

        nodeTokenReward[1] = 1680 * 10 ** 18;
        nodeTokenReward[2] = 560 * 10 ** 18;

        powerPrices[1] = 10 * 10 ** 18;
        powerPrices[2] = 100 * 10 ** 18;
        powerPrices[3] = 200 * 10 ** 18;
        powerPrices[4] = 300 * 10 ** 18;
        powerPrices[5] = 500 * 10 ** 18;
        powerPrices[6] = 1000 * 10 ** 18;

        marketingAddress = [address(0xA75d4fCcb3278Af7c217B7Eba0988d6807C589df),
                            address(0x09F2003f0162A92F11b2B94c2a9B1985232cc179),
                            address(0x053e42d88D8d0abB8f3537433BB3A08C540a54E7),
                            address(0xb6f74879E60b3b58Eb6139641463264Bff6B7C38),
                            address(0xd9FA7F1594a8C554387Be2704cEEc3F27d28a35f)];

        forceInitialPrice = 10 ** 17;
    }

    function claim(address to, uint256 amount) external onlyOwner {
        usdt.transfer(to, amount);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    function setBaseLink(string memory base) public onlyOwner {
        baseLink = base;
    }

    function setForce(address _force) public onlyOwner {
        force = ERC20(_force);
    }

    function setForcePair(address _pair) public onlyOwner {
        forcePair = address(_pair);
    }

    function setForceInitialPrice(uint256 price) public onlyOwner {
        forceInitialPrice = price;
    }

    function addNodeDividend(uint256 dividend) external returns (uint256) {
        require(isController[msg.sender],"Must be controller");
        nodeTokenDividend += dividend;
        return nodeTokenDividend;
    }

    function activateNode(uint256 tokenId) public {

        require(checkCanActivateNode(msg.sender, tokenId) == 0, "You can not open the node");
        
        uint256 nodeType;

        if(fNft.NFTTypes(tokenId) == 1 || fNft.NFTTypes(tokenId) == 2){
            nodeType = 1;
        }
        
        if(fNft.NFTTypes(tokenId) == 3){
            nodeType = 2;
        }

        require(nodeID[nodeType] < 1500 || (nodeID[nodeType] > 5000 && nodeID[nodeType] < 6000), "Nodes have been sold out");

        nftIsActive[tokenId] = true;

        uint256 nodeId = ++nodeID[nodeType];

        nodeIds[msg.sender] = nodeId;

        nodeIdToAddress[nodeId] = msg.sender;

        nodeOpenTime[nodeId] = block.timestamp;

        uint256 power;

        if(fNft.NFTTypes(tokenId) == 1){
            power = nodePrice[nodeType].div(5 * 10 ** 17);
        }else{
            power = nodePrice[nodeType].div(10 ** 18);
        }

        userPower[msg.sender] += power;

        totalPower += power;

        nodeTypeUserAmount[nodeType]++;
        
        _updateUnderPower(msg.sender);

        _setRegisterTime(msg.sender);

        emit ActivateNode(msg.sender, nodeId, tokenId, power);
    }

    function buyNode(uint256 nodeType) public {

        require(checkCanBuyNode(msg.sender, nodeType) == 0, "You can not open the node");
        require(nodeID[nodeType] < 1500 || (nodeID[nodeType] > 5000 && nodeID[nodeType] < 6000), "Nodes have been sold out");

        uint256 usdtAmount = nodePrice[nodeType];

        usdt.transferFrom(msg.sender, address(this), usdtAmount);
        
        uint256 recommendFees = usdtAmount.mul(_nodeRecommendFee).div(10000);
        uint256 marketingFees = usdtAmount.mul(_nodeMarketingFee).div(10000);
        uint256 nodeActivityFees = usdtAmount.sub(recommendFees).sub(marketingFees);

        userNodeRecommendeProfits[myRecommender[msg.sender]] += recommendFees;
        _addNodeProfit(nodeType, recommendFees);

        _divideMarketingFees(marketingFees);

        usdt.transfer(nodeIdToAddress[userTeamId[msg.sender]], nodeActivityFees);

        uint256 nodeId = ++nodeID[nodeType];

        nodeIds[msg.sender] = nodeId;

        nodeIdToAddress[nodeId] = msg.sender;

        nodeOpenTime[nodeId] = block.timestamp;

        uint256 power = nodePrice[nodeType].div(10 ** 18);

        userPower[msg.sender] += power;

        totalPower += power;

        nodeTypeUserAmount[nodeType]++;
        
        _updateUnderPower(msg.sender);

        _setRegisterTime(msg.sender);

        emit BuyNode(msg.sender, nodeId, usdtAmount, power);
    }

    function _addNodeProfit(uint256 nodeType, uint256 fees) public {
        nodeProfit[nodeType] += fees;

        if(block.timestamp.div(1 days) > nodeProfitLastTime.div(1 days)){
            nodeProfitToday[nodeType] = fees;
        }else{
            nodeProfitToday[nodeType] += fees;
        }

        nodeProfitLastTime = block.timestamp;
    }

    function _setRegisterTime(address user) public {
        if(registerTime[user] == 0){
            registerTime[user] = block.timestamp;
            registers.push(user);
        }
    }

    function upgradeUserLevel() public {

        uint256 level0 = userNodeLevel[msg.sender];
        uint256 level = _queryUserNodeLevel(msg.sender);

        if(level > level0){
            userNodeLevel[msg.sender] = level;
            if(nodeLevelUserAmount[level0] > 0){
                nodeLevelUserAmount[level0] -= 1;
            }
            nodeLevelUserAmount[level] += 1;
        }

        emit UpgradeUserLevel(msg.sender, level0, level);
    }

    function _updateUnderPower(address user) public {

        do{
            underPower[myRecommender[user]] = _queryEffectiveUnderPower(myRecommender[user]);
            
            user = myRecommender[user];
        } while (myRecommender[user] != address(0));
    }

    function _divideMarketingFees(uint256 fees) public {

        if(fees > 0){

            uint256 feess = fees.mul(20).div(100);
            uint256 i;

            for(i = 0; i < 5; i++){
                usdt.transfer(marketingAddress[i], feess);
            }
        }
    }

    function _dividePowerRecommendFees(address user, uint256 fees) public returns(uint256 divideFees) {

        uint256 i;
        uint256 count;
        address user0 = myRecommender[user];

        uint256 fees1 = fees.mul(powerRecommendRewardRate).div(10000);

        uint256 fees2 = fees.mul(powerRecommendUsdtRewardRate).div(10000);

        userPowerRecommendeProfits[user0] += fees1;

        for(i = 1; i < 21; i++){
            if(myRecommender[user0] != address(0)){
                userPowerRecommendeProfits[myRecommender[user0]] += fees2;
                user0 = myRecommender[user0];
                count++;
            }else{
                break;
            }
        }

        divideFees = fees1 + fees2.mul(count);
    }

    function buyPower(uint256 types) public {

        require(checkCanBuyPower(msg.sender, types) == 0, "You can not buy power");

        uint256 cost = powerPrices[types];

        uint256 tokenType;

        if(fof.balanceOf(msg.sender) >= cost.mul(buyPowerfofDiscount).div(10000)){
            tokenType = 2;

            cost = cost.mul(buyPowerfofDiscount).div(10000);

            fof.transferFrom(msg.sender, deadWallet, cost);
        }else{
            tokenType = 1;

            usdt.transferFrom(msg.sender, address(this), powerPrices[types]);

            uint256 marketingFees = powerPrices[types].mul(_buyPowerMarketingFee).div(10000);
            uint256 recommendFees = powerPrices[types].mul(_buyPowerRecommendFee).div(10000);

            _divideMarketingFees(marketingFees);
            uint256 divideFees = _dividePowerRecommendFees(msg.sender, recommendFees);

            _addNodeProfit(_queryNodeType(nodeIds[msg.sender]), divideFees);

            uint256 buyBackFee = powerPrices[types].sub(marketingFees).sub(recommendFees);

            if(buyBackFee > 0){
                swapTokenForBurn(buyBackFee);
            }
        }

        userPower[msg.sender] += powerPrices[types].div(10 ** 18);

        totalPower += powerPrices[types].div(10 ** 18);

        _updateUnderPower(msg.sender);

        _setRegisterTime(msg.sender);

        emit BuyPower(msg.sender, tokenType, cost, powerPrices[types].div(10 ** 14));
    }

    function swapTokenForBurn(uint256 usdtAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(force);

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, // accept any amount of ETH
            path,
            address(deadWallet),
            block.timestamp
        );
    }

    function bindRecommender(address recommender) public {

        require(checkCanBindRecommender(msg.sender, recommender) == 0, "Recommender binding failed");

        myRecommender[msg.sender] = recommender;

        invitees[recommender].push(msg.sender);

        bindTime[msg.sender] = block.timestamp;

        userTeamId[msg.sender] = userTeamId[recommender];

        _updateUnderPower(msg.sender);

        emit BindRecommender(msg.sender, recommender);
    }

    function drawNodeRecommendeProfit() public {

        require(queryUserProfitProgress(msg.sender) < 300, "The profit has reached the upper limit");
        require(checkCanDrawProfit(msg.sender), "Your node has not been activated");

        require(userDrawNodeRecommendeProfits[msg.sender] < userNodeRecommendeProfits[msg.sender], "No profit can be withdrawn");

        uint256 profit = userNodeRecommendeProfits[msg.sender] - userDrawNodeRecommendeProfits[msg.sender];

        usdt.transfer(msg.sender, profit);

        userDrawNodeRecommendeProfits[msg.sender] += profit;

        emit DrawNodeRecommendeProfit(msg.sender, nodeIds[msg.sender], profit);
    }

    function drawPowerRecommendeProfit() public {

        require(queryUserProfitProgress(msg.sender) < 300, "The profit has reached the upper limit");

        require(userPowerRecommendeProfits[msg.sender] > userDrawPowerRecommendeProfits[msg.sender], "No profit can be withdrawn");

        uint256 profit = userPowerRecommendeProfits[msg.sender] - userDrawPowerRecommendeProfits[msg.sender];

        usdt.transfer(msg.sender, profit);

        userDrawPowerRecommendeProfits[msg.sender] += profit;

        emit DrawPowerRecommendeProfit(msg.sender, nodeIds[msg.sender], profit);
    }

    function drawNodeTokenRelease() public {

        require(queryUserProfitProgress(msg.sender) < 300, "The profit has reached the upper limit");
        require(checkCanDrawProfit(msg.sender), "Your node has not been activated");

        (uint256 timeRelease, uint256 priceRelease) = _queryNodeTokenRelease(msg.sender);

        require(timeRelease > 0 || priceRelease > 0, "No token can be withdrawn");

        force.transferFrom(withdrawAddress, msg.sender, timeRelease + priceRelease);
    
        uint256 nodeId = nodeIds[msg.sender];
        tokenForTimeRelease[nodeId] += timeRelease;
        tokenForPriceRelease[nodeId] += priceRelease;

        emit DrawNodeTokenRelease(msg.sender, nodeIds[msg.sender], timeRelease, priceRelease);
    }

    function drawNodeProfit() public {//NodeTokenDividend

        require(queryUserProfitProgress(msg.sender) < 300, "The profit has reached the upper limit");
        require(checkCanDrawProfit(msg.sender), "Your node has not been activated");

        uint256 dividend = _queryNodeTokenDividend(msg.sender);

        require(dividend > 0, "No profit can be withdrawn");

        force.transferFrom(withdrawAddress, msg.sender, dividend);

        userDrawNodeTokenDividend[msg.sender] += dividend;

        userDrawNodeTokenDividendLastAmount[msg.sender] = nodeTokenDividend;

        emit DrawNodeProfit(msg.sender, nodeIds[msg.sender], dividend);
    }

    function drawNodeTokenDividend() public {//NodeLevelTokenDividend

        require(queryUserProfitProgress(msg.sender) < 300, "The profit has reached the upper limit");
        require(checkCanDrawProfit(msg.sender), "Your node has not been activated");

        uint256 dividend = _queryNodeLevelTokenDividend(msg.sender);

        require(dividend > 0, "No profit can be withdrawn");

        force.transferFrom(withdrawAddress, msg.sender, dividend);

        userDrawNodeLevelTokenDividend[msg.sender] += dividend;

        userDrawNodeLevelTokenDividendLastAmount[msg.sender] = nodeTokenDividend;

        emit DrawNodeProfit(msg.sender, nodeIds[msg.sender], dividend);
    }

    function drawMiningToken() public {

        require(queryUserProfitProgress(msg.sender) < 300, "The profit has reached the upper limit");
        
        uint256 availableUnderPower = _queryAvailableUnderPower(msg.sender);
        
        uint256 power = userPower[msg.sender] + availableUnderPower;

        uint256 miningAmount = _queryTokenMining(msg.sender, power);

        require(miningAmount > 0, "No profit can be withdrawn");

        force.transfer(msg.sender, miningAmount);

        drawTime[msg.sender] = block.timestamp;

        userMiningProfits[msg.sender] += miningAmount;

        miningTotal += miningAmount;

        emit DrawMiningToken(msg.sender, power, miningAmount);
    }

    function _queryNodeType(uint256 nodeId) public pure returns(uint256) {
        if(nodeId > 1000 && nodeId < 5000){
            return 1;
        }
        if(nodeId > 5000){
            return 2;
        }
        return 0;
    }

    function _queryTokenMining(address user, uint256 power) public view returns(uint256 miningAmount) {

        uint256 time;

        if(drawTime[user] == 0){
            time = registerTime[user];
        }else{
            time = drawTime[user];
        }

        uint256 intervalBlock = (block.timestamp - time).div(15 minutes);

        uint256 newPower = _queryNewPowerOf24Hours();

        if(block.timestamp - registerTime[user] < 1 days){

            if(userPower[user] > 0 && newPower > 0){
                miningAmount = perBlockMining.mul(intervalBlock * _newUserFee * userPower[user]).div(10000 * newPower);
            }
        }else{
            if(userPower[user] > 0 && totalPower > newPower){
                miningAmount = perBlockMining.mul(intervalBlock * (10000 - _newUserFee) * power).div(10000 * (totalPower - newPower));
            }
        }
    }

    function _queryNewPowerOf24Hours() public view returns(uint256 power) {

        uint256 startTime = block.timestamp - 1 days;

        uint256 i;
        for(i = registers.length; i > 1; i--){
            if(registerTime[registers[i - 1]] > startTime){
                power += userPower[registers[i - 1]];
            }else{
                break;
            } 
        }
    }

    function _queryNodeTokenRelease(address user) public view returns(uint256 timeRelease, uint256 priceRelease) {
        
        uint256 nodeId = nodeIds[user];
        uint256 nodeType = _queryNodeType(nodeId);

        if(nodeId > 1000){

            uint256 month = (block.timestamp - nodeOpenTime[nodeId]).div(30 days) + 1;

            if(month > 12){
                month = 12;
            }

            timeRelease = nodeTokenReward[nodeType].mul(month).div(24);

            uint256 multiple = forceEqualsToUsdt(10 ** 18).div(forceInitialPrice * 10);

            if(multiple > 10){
                multiple = 10;
            }
    
            priceRelease = nodeTokenReward[nodeType].mul(multiple).div(20);

            timeRelease = timeRelease - tokenForTimeRelease[nodeId];
            priceRelease = priceRelease - tokenForPriceRelease[nodeId];
        }
    }

    function _queryAvailableUnderPower(address user) public view returns(uint256 availableUnderPower) {

        uint256 level = userNodeLevel[user];

        if(level > 0){
            availableUnderPower = _queryEffectiveUnderPower(user);
            
            availableUnderPower = availableUnderPower.mul(levelPowerRate[level - 1]).div(10000);
        }
    }

    function _queryNodeLevelTokenDividend(address user) public view returns(uint256 dividend) {

        uint256 level = userNodeLevel[user];
        uint256 newTokenDividend = nodeTokenDividend - userDrawNodeLevelTokenDividendLastAmount[user];
        uint256 levelDividend = newTokenDividend.mul(nodeTokenDividendRateForLevel).div(10000);

        if(level > 0){
            dividend = levelDividend.mul(nodeLevelDividendRate[level - 1]).div(10000 * nodeLevelUserAmount[level]);
        }
    }

    function _queryNodeTokenDividend(address user) public view returns(uint256 dividend) {

        uint256 nodeType = _queryNodeType(nodeIds[user]);
        uint256 newTokenDividend = nodeTokenDividend - userDrawNodeTokenDividendLastAmount[user];

        if(nodeType > 0){
            uint256 nodeTypeDividend = newTokenDividend.mul(nodeTokenDividendRateForNodeType[nodeType - 1]).div(10000);
            dividend = nodeTypeDividend.div(nodeTypeUserAmount[nodeType]);
        }
    }

    function _queryEffectiveUnderPower(address user) public view returns(uint256 effectiveUnderPower){
        
        address[] memory inviteess = invitees[user];

        uint256[] memory powers = new uint256[](uint256(inviteess.length));

        uint256 i;
        for(i = 0; i < inviteess.length; i++){
            powers[i] = userPower[inviteess[i]] + underPower[inviteess[i]];
            effectiveUnderPower += powers[i];
        }

        if(inviteess.length > 1){
            uint256[] memory newPowers = _sort(powers);
            effectiveUnderPower = effectiveUnderPower - newPowers[0];
        }

        return effectiveUnderPower;
    }

    function _queryUserNodeLevel(address user) public view returns(uint256){

        uint256 amount = _queryUserEffectiveInvitees(user);
        uint256 i;

        for(i = 5; i > 0; i--){

            if(userPower[user] >= levelPowerLimit[i - 1] 
            && amount >= levelInviteesLimit[i - 1] 
            && underPower[user] >= levelUnderPowerLimit[i - 1]){
                return i;
            }
        }

        return 0;
    }

    function _queryUserEffectiveInvitees(address user) public view returns(uint256 amount){

        uint256 i;

        for(i = 0; i < invitees[user].length; i++){
            if(userPower[invitees[user][i]] >= 10){
                amount++;
            }
        }

        return amount;
    }

    function queryNodePrice() public view returns(uint256 superNodePrice, uint256 genesisNodePrice){
        superNodePrice = nodePrice[1].div(10 ** 14);
        genesisNodePrice = nodePrice[2].div(10 ** 14);
    }

    function queryNodeProfit(uint256 nodeType) public view returns(uint256 profit, uint256 profitToday) {
        profit = nodeProfit[nodeType].div(10 ** 14);
        profitToday = nodeProfitToday[nodeType].div(10 ** 14);
    }

    function queryNodeTokenReward(address user) public view returns(uint256 total, uint256 draw, uint256 notDraw, uint256 canDraw) {

        uint256 nodeId = nodeIds[user];
        uint256 nodeType = _queryNodeType(nodeIds[user]);

        total = nodeTokenReward[nodeType].div(10 ** 14);
        draw = (tokenForTimeRelease[nodeId] + tokenForPriceRelease[nodeId]).div(10 ** 14);
        notDraw = total - draw;
        (uint256 timeRelease, uint256 priceRelease) = _queryNodeTokenRelease(user);
        canDraw = (timeRelease + priceRelease).div(10 ** 14);
    }

    function queryMyNodeReward(address user) public view returns(uint256 total, uint256 expected, uint256 draw, uint256 canDraw) {

        uint256 nodeId = nodeIds[user];

        expected = total.mul(3 * 365 days).div(block.timestamp - nodeOpenTime[nodeId]).div(10 ** 14);
        draw = userDrawNodeTokenDividend[user].div(10 ** 14);
        canDraw = _queryNodeTokenDividend(user).div(10 ** 14);
        total = draw + canDraw;
    }

    function queryNodeRecommendReward(address user) public view returns(uint256 cumulative, uint256 draw, uint256 canDraw) {
        cumulative = userNodeRecommendeProfits[user].div(10 ** 14);
        draw = userDrawNodeRecommendeProfits[user].div(10 ** 14);
        canDraw = cumulative - draw;
    }

    function queryPowerRecommendReward(address user) public view returns(uint256 total, uint256 draw, uint256 canDraw) {
        total = userPowerRecommendeProfits[user].div(10 ** 14);
        draw = userDrawPowerRecommendeProfits[user].div(10 ** 14);
        canDraw = total - draw;
    }

    function queryNetPower() public view returns(uint256 netPower, uint256 newPower, uint256 totalMining){
        netPower = totalPower;
        newPower = _queryNewPowerOf24Hours();
        totalMining = miningTotal.div(10 ** 14);
    }

    function queryMyPower(address user) public view returns(uint256 level, uint256 myPower, uint256 myUnderPower){
        level = userNodeLevel[user];
        myPower = userPower[user];
        myUnderPower = underPower[user];
    }

    function queryDayMining() public view returns(uint256 total, uint256 unMining, 
    uint256 totalMining, uint256 blockMining, uint256 dayMining, uint256 perPowerMining){
        unMining = force.balanceOf(address(this)).div(10 ** 14);
        totalMining = miningTotal.div(10 ** 14);
        total = unMining + totalMining;
        blockMining = perBlockMining.div(10 ** 14);
        dayMining = perBlockMining.mul(96).div(10 ** 14);
        perPowerMining = perBlockMining.div(totalPower).div(10 ** 14);
    }

    function queryMyMining(address user) public view returns(uint256 total, uint256 draw, uint256 canDraw){
        draw = userMiningProfits[user].div(10 ** 14);
        uint256 availableUnderPower = _queryAvailableUnderPower(user);
        uint256 power = userPower[user] + availableUnderPower;
        canDraw = _queryTokenMining(user, power).div(10 ** 14);
        total = draw + canDraw;
    }

    function queryInvitees(address user) public view returns(address[] memory myInvitees) {
        myInvitees = invitees[user];
    }

    function queryUserProfitProgress(address user) public view returns(uint256 progress) {

        uint256 forceProfit = userMiningProfits[user] + tokenForTimeRelease[nodeIds[user]] + tokenForPriceRelease[nodeIds[user]] 
        + userDrawNodeTokenDividend[user] + userDrawNodeLevelTokenDividend[user];
        // uint256 usddtProfit = userNodeRecommendeProfits[user] + userPowerRecommendeProfits[user];
        uint256 total = forceEqualsToUsdt(forceProfit);
        if(userPower[user] > 0){
            progress = total.div(userPower[user] * 10 ** 16);
        }
    }

    function queryMyInviteesData(address user) public view returns(uint256[] memory levels, address[] memory inviteess, 
    uint256[] memory powers, uint256[] memory underPowers) {
        
        inviteess = invitees[user];

        levels = new uint256[](uint256(inviteess.length));
        powers = new uint256[](uint256(inviteess.length));
        underPowers = new uint256[](uint256(inviteess.length));

        uint256 i;
        for(i = 0; i < inviteess.length; i++){
            levels[i] = userNodeLevel[inviteess[i]];
            powers[i] = userPower[inviteess[i]];
            underPowers[i] = underPower[inviteess[i]];
        }
    }

    function queryLevelAndUserAmount() public view returns(uint256[5] memory levelDividends, uint256[5] memory userAmounts) {

        uint256 i;
        uint256 levelDividend = nodeTokenDividend.mul(nodeTokenDividendRateForLevel).div(10000);
        for(i = 0; i < 5; i++){
            levelDividends[i] = levelDividend.mul(nodeLevelDividendRate[i]).div(10 ** 18);
            userAmounts[i] = nodeLevelUserAmount[i];
        }
    }

    function queryMyNodeLevelDividend(address user) public view returns(uint256 level, uint256 total, uint256 dividend, uint256 canDividend) {
        level = userNodeLevel[user];
        dividend = userDrawNodeLevelTokenDividend[user].div(10 ** 14);
        canDividend = _queryNodeLevelTokenDividend(user).div(10 ** 14);
        total = dividend + canDividend;
    }

    function getUserNFTIDsByType(address user, uint256 NFTType) public view returns(uint256[] memory NFTIDs) {

		uint256[] memory NFTIDs0 = fNft.getUserNFTIDs(user);
        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;
        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0 && fNft.NFTTypes(NFTIDs0[i]) == NFTType){

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

    function forceEqualsToUsdt(uint256 tokenAmount) public view returns(uint256 usdtAmount) {
        
        uint256 tokenOfPair = force.balanceOf(forcePair);

        uint256 usdtOfPair = usdt.balanceOf(forcePair);

        if(tokenOfPair > 0 && usdtOfPair > 0){
            usdtAmount = tokenAmount.mul(usdtOfPair).div(tokenOfPair);
        }

        return usdtAmount;
    }

    function queryIsBindRecommender(address user) public view returns (bool){

        if(myRecommender[user] == address(0)){
            return false;
        }
        return true;
    }

    function queryInviteLink(address user) public view returns (string memory inviteLink){

        if(userPower[user] > 0){
            string memory addr = toString(user);

            if (user != address(0)) {
                inviteLink = string(abi.encodePacked(baseLink, addr));
            }
        }

        return inviteLink;
    }

    function toString(address account) public pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function _sort(uint256[] memory arr) public pure returns(uint256[] memory) {

        require(arr.length > 0, "Sorted arrays does not have data");

        uint256 i;
        uint256 j;
        uint256 temp;

        for (i = 0; i < arr.length; i++){

            for (j = 0; j < arr.length -  i - 1; j++){
                
                if (arr[j] < arr[j + 1]){

                    temp = arr[j + 1];

                    arr[j + 1] = arr[j];

                    arr[j] = temp;
                }
            }
        }
        return arr;
    }

    function checkCanBindRecommender(address user, address recommender) public view returns (uint256) {
        if(userPower[recommender] == 0) return 1;//"The recommender have not buy power"
        if(myRecommender[user] != address(0)) return 2;//"You have bound a recommender"
        if(user == recommender) return 3;//"You can't bind yourself"
        if(recommender == address(0) || recommender == deadWallet) return 4;//"You can't bind address 0"
        if(userTeamId[recommender] < 1001 || userTeamId[recommender] > 1003) return 5;//"Please bind the correct recommender"
        return 0;
    }

    function checkCanActivateNode(address user, uint256 tokenId) public view returns (uint256) {
        if(nodeIds[user] != 0) return 1;//"You have opened the node"
        if(nftIsActive[tokenId]) return 2;//"Your nft has been activated"
        if(fNft.ownerOf(tokenId) != user) return 3;//"You are not the owner of the nft"
        if(fNft.NFTTypes(tokenId) < 1 && fNft.NFTTypes(tokenId) > 3) return 4;//"Your nft cannot be used for activation"
        if(myRecommender[user] == address(0)) return 5;//"You have not bound a recommender"
        return 0;
    }

    function checkCanBuyNode(address user, uint256 nodeType) public view returns (uint256) {
        if(nodeIds[user] != 0) return 1;//"You have opened the node"
        if(usdt.balanceOf(user) < nodePrice[nodeType]) return 2;//"You don't have enough usdt"
        if(nodeType != 1 && nodeType != 2) return 3;//"Incorrect node type input"
        if(myRecommender[user] == address(0)) return 4;//"You have not bound a recommender"
        return 0;
    }

    function checkCanBuyPower(address user, uint256 types) public view returns (uint256) {
        if(fof.balanceOf(user) < powerPrices[types].mul(buyPowerfofDiscount).div(10000) && usdt.balanceOf(user) < powerPrices[types]) return 1;//"You don't have enough usdt"
        if(myRecommender[user] == address(0)) return 2;//"You have not bound a recommender"
        if(types < 1 && types > 6) return 3;//"Incorrect type input"
        return 0;
    }

    function checkCanUpgradeUserLevel(address user) public view returns (bool) {

        uint256 level0 = userNodeLevel[user];
        uint256 level = _queryUserNodeLevel(user);

        if(level > level0){
            return true;
        }
        return false;
    }

    function checkCanDrawProfit(address user) public view returns (bool) {
        uint256 nodeType = _queryNodeType(nodeIds[user]);
        if(nodeType > 0 && underPower[user] >= openNodeUnderPowerLimit[nodeType]) return true;//"Your under power does not meet the activation conditions"
        return false;
    }

}