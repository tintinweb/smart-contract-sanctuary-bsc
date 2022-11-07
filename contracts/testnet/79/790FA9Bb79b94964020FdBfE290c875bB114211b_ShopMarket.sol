/**
 *Submitted for verification at BscScan.com on 2022-11-07
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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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

// File: abeyregistrar/IBaseRegistrar.sol

//import "../registry/ANS.sol";
//import "./IBaseRegistrar.sol";


interface IBaseRegistrar is IERC721 {

    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);
    event NameMigrated(
        uint256 indexed id,
        address indexed owner,
        uint256 expires
    );
    event NameRegistered(
        uint256 indexed id,
        address indexed owner,
        uint256 expires
    );
    event NameRenewed(uint256 indexed id, uint256 expires);
    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external;

    // Revoke controller permission for an address.
    function removeController(address controller) external;

    // Set the resolver for the TLD this registrar manages.
    function setResolver(address resolver) external;

    // Returns the expiration timestamp of the specified label hash.
    function nameExpires(uint256 id) external view returns (uint256);

    // Returns true iff the specified name is available for registration.
    function available(uint256 id) external view returns (bool);

    /**
     * @dev Register a name.
     */
    function register(
        uint256 id,
        address owner,
        uint256 duration
    ) external returns (uint256);

    function renew(uint256 id, uint256 duration) external returns (uint256);

    /**
     * @dev Reclaim ownership of a name in ANS, if you own it in the registrar.
     */
    function reclaim(uint256 id, address owner) external;
}

// File: registry/ANS.sol

pragma solidity >=0.8.4;

interface ANS {
    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);

    // Logged when an operator is added or removed.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external returns (bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

// File: abeyregistrar/BaseRegistrarImplementation.sol

pragma solidity >=0.8.4;








contract BaseRegistrarImplementation is ERC721, IERC721Enumerable, IBaseRegistrar, Ownable  {
    // A map of expiry times
    mapping(uint256=>uint) expiries;
    // The ANS registry
    ANS public ans;
    // The namehash of the TLD this registrar owns (eg, .eth)
    bytes32 public baseNode;
    // A map of addresses that are authorised to register and renew names.
    mapping(address => bool) public controllers;
    uint256 public constant GRACE_PERIOD = 90 days;
    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 constant private ERC721_ID = bytes4(
        keccak256("balanceOf(address)") ^
        keccak256("ownerOf(uint256)") ^
        keccak256("approve(address,uint256)") ^
        keccak256("getApproved(uint256)") ^
        keccak256("setApprovalForAll(address,bool)") ^
        keccak256("isApprovedForAll(address,address)") ^
        keccak256("transferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256,bytes)")
    );
    bytes4 constant private RECLAIM_ID = bytes4(keccak256("reclaim(uint256,address)"));
    string public baseUri;
    string constant INVALID_INDEX = "005007";
    uint256[] internal tokens;
    mapping(uint256 => uint256) internal idToIndex;
    mapping(address => uint256[]) internal ownerToIds;


    /**
     * v2.1.3 version of _isApprovedOrOwner which calls ownerOf(tokenId) and takes grace period into conanseration instead of ERC721.ownerOf(tokenId);
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.1.3/contracts/token/ERC721/ERC721.sol#L187
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    constructor(ANS _ans, bytes32 _baseNode) ERC721("ABEY NAME SERVICE","ANS") {
        ans = _ans;
        baseNode = _baseNode;
    }

    modifier live {
        require(ans.owner(baseNode) == address(this));
        _;
    }

    modifier onlyController {
        require(controllers[msg.sender]);
        _;
    }

    function totalSupply()
    external
    override
    view
    returns (uint256)
    {
        return tokens.length;
    }


    function tokenByIndex(
        uint256 _index
        )
    external
    override
    view
    returns (uint256)
    {
        require(_index < tokens.length, INVALID_INDEX);
        return tokens[_index];
    }


    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
        )
    external
    override
    view
    returns (uint256)
    {
        require(_index < ownerToIds[_owner].length, INVALID_INDEX);
        return ownerToIds[_owner][_index];
    }


    function _mint(
        address _to,
        uint256 _tokenId
        )
    internal
    override
    virtual
    {
        super._mint(_to, _tokenId);
        tokens.push(_tokenId);
        idToIndex[_tokenId] = tokens.length - 1;
    }


    function _burn(
        uint256 _tokenId
        )
    internal
    override
    virtual
    {
        super._burn(_tokenId);

        uint256 tokenIndex = idToIndex[_tokenId];
        uint256 lastTokenIndex = tokens.length - 1;
        uint256 lastToken = tokens[lastTokenIndex];

        tokens[tokenIndex] = lastToken;

        tokens.pop();
        // This wastes gas if you are burning the last token but saves a little gas if you are not.
        idToIndex[lastToken] = tokenIndex;
        idToIndex[_tokenId] = 0;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not approved or owner"
        );

        _transfer(from, to, tokenId);
        ans.setSubnodeOwner(baseNode, bytes32(tokenId), to);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override(ERC721, IERC721) {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not approved or owner"
        );
        _safeTransfer(from, to, tokenId, _data);
        ans.setSubnodeOwner(baseNode, bytes32(tokenId), to);
    }

    /**
     * @dev Gets the owner of the specified token ID. Names become unowned
     *      when their registration expires.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view override(IERC721, ERC721) returns (address) {
        require(expiries[tokenId] > block.timestamp);
        return super.ownerOf(tokenId);
    }

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external override onlyOwner {
        require(controller != address(0), "address can not be zero!");
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    // Revoke controller permission for an address.
    function removeController(address controller) external override onlyOwner {
        require(controller != address(0), "address can not be zero!");
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    // Set the resolver for the TLD this registrar manages.
    function setResolver(address resolver) external override onlyOwner {
        ans.setResolver(baseNode, resolver);
    }

    // Returns the expiration timestamp of the specified id.
    function nameExpires(uint256 id) public view override returns(uint) {
        return expiries[id];
    }

    // Returns true iff the specified name is available for registration.
    function available(uint256 id) public view override returns(bool) {
        return expiries[id] + GRACE_PERIOD < block.timestamp;
    }

    /**
     * @dev Register a name.
     * @param id The token ID (keccak256 of the label).
     * @param owner The address that should own the registration.
     * @param duration Duration in seconds for the registration.
     */
    function register(uint256 id, address owner, uint duration) external override returns(uint) {
      return _register(id, owner, duration, true);
    }

    /**
     * @dev Register a name, without modifying the registry.
     * @param id The token ID (keccak256 of the label).
     * @param owner The address that should own the registration.
     * @param duration Duration in seconds for the registration.
     */
    function registerOnly(uint256 id, address owner, uint duration) external returns(uint) {
      return _register(id, owner, duration, false);
    }

    function _register(uint256 id, address owner, uint duration, bool updateRegistry) internal live onlyController returns(uint) {
        require(available(id));
        require(block.timestamp + duration + GRACE_PERIOD > block.timestamp + GRACE_PERIOD); // Prevent future overflow

        expiries[id] = block.timestamp + duration;
        if(_exists(id)) {
            // Name was previously owned, and expired
            _burn(id);
        }
        _mint(owner, id);
        if(updateRegistry) {
            ans.setSubnodeOwner(baseNode, bytes32(id), owner);
        }

        emit NameRegistered(id, owner, block.timestamp + duration);

        return block.timestamp + duration;
    }

    function renew(uint256 id, uint duration) external override live onlyController returns(uint) {
        require(expiries[id] + GRACE_PERIOD >= block.timestamp); // Name must be registered here or in grace period
        require(expiries[id] + duration + GRACE_PERIOD > duration + GRACE_PERIOD); // Prevent future overflow
        expiries[id] += duration;
        emit NameRenewed(id, expiries[id]);
        return expiries[id];
    }

    /**
     * @dev Reclaim ownership of a name in ANS, if you own it in the registrar.
     */
    function reclaim(uint256 id, address owner) external override live {
        require(_isApprovedOrOwner(msg.sender, id));
        ans.setSubnodeOwner(baseNode, bytes32(id), owner);
    }

    function supportsInterface(bytes4 interfaceID) public override(ERC721, IERC165) view returns (bool) {
        return interfaceID == INTERFACE_META_ID ||
               interfaceID == ERC721_ID ||
               interfaceID == RECLAIM_ID;
    }

    /**
     * PRIVILEGED MODULE FUNCTION. Sets a new baseURI for all token types.
     */
    function setURI(string memory newURI) external onlyOwner {
        baseUri = newURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = baseUri;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId))) : "";
    }
}

// File: ShopMarket.sol

/**
 *  SPDX-License-Identifier: MIT
*/

pragma solidity 0.8.7;






contract ShopMarket is Ownable {
    using SafeMath for uint256;
    using Address for address;
    BaseRegistrarImplementation base;
    
    bool inited;

    struct ItemInfo {
        uint256 tokenId;
        uint256 amount;
        address seller;
        uint256 status; //0下架 1上架  2已销售
        address buyer;
    }

    address public devAddress;
    
    
    
    uint256 public devFee;
    uint8 public is_stop;
    uint256 public autoIncrement;
    
    mapping(uint256 => ItemInfo) public ItemList;

    event  Stake(address indexed _seller,uint256 indexed _itemId,uint256 indexed _tokenId,uint256 _price);
    event  UnStake(address indexed _seller,uint256 indexed _itemId);
    event  Sold(address indexed _buyer,uint256 indexed _itemId,uint256 indexed _amount,address  _seller);

    uint256 public inquiryFee;

    event Inquiry(address indexed _inquiryer,uint256 indexed _itemId,uint256 indexed _price);    
    event UnInquiry(address indexed _inquiryer,uint256 indexed _itemId);   
    struct InquiryInfo{
        address inquiryer;
        uint256 price;
        uint256 status; //0询价中 1成交  2已撤销
        uint256 index;
    }

    mapping(uint256 => InquiryInfo[]) public InquiryInfoList; //itemId => (index=>InquiryInfo)
    mapping(uint256 => InquiryInfo) public LastInquiryInfo;//itemId => InquiryInfo

    event InquiryFree(address indexed _inquiryer,uint256 indexed _tokenId,uint256 indexed _price);    
    event UnInquiryFree(address indexed _inquiryer,uint256 indexed _tokenId); 
    event InquirySoldFree(address indexed _buyer,address indexed _seller,uint256 indexed _tokenId,uint256 _amount);

    mapping(uint256 => InquiryInfo[]) public InquiryInfoFreeList; //contract => (tokenId=>(index=>InquiryInfo))
    mapping(uint256 => InquiryInfo) public LastInquiryFreeInfo;//contract => (tokenId => InquiryInfo)

    
    event InquirySold(address indexed _buyer,uint256 indexed _itemId,uint256 indexed _amount,address  _seller);
    
    struct auctionInfo{
        uint256 tokenId;
        uint256 startPrice;//开始价格
        uint256 markup;//每次加价
        uint256 startTime;//开始时间
        uint256 overTime;//结束时间
        address seller;
        uint256 status; //0下架 1上架  2已销售
        address buyer;
    }

    //拍卖列表
    mapping(uint256 => auctionInfo) public auctionList; //itemId => auctionInfo
    //最后报价记录
    mapping(uint256 => InquiryInfo) public lastAuctionInquiryInfo;//itemId => InquiryInfo
    //出价记录
    mapping(uint256 => InquiryInfo[]) public auctionInquiryInfoList; //itemId => (index=>InquiryInfo)


    event  AuctionStake(address indexed _seller,uint256 indexed _itemId,uint256 indexed _tokenId,uint256  _startPrice,uint256 _markup,uint256 _startTime, uint256 _overTime);
    event  UnAuctionStake(address indexed _seller,uint256 indexed _itemId);
    event  AuctionBid(address indexed _buyer,uint256 indexed _itemId,uint256 indexed _amount,uint256 _index);
    event  AuctionSold(address indexed _buyer,uint256 indexed _itemId,uint256 indexed _amount,address  _seller,uint256 _index);



    constructor(
        BaseRegistrarImplementation _base
    ) {
        base = _base;

        devFee = 250;
        autoIncrement = 1;
        is_stop = 0;
    }
    
    function getNumber() public view returns(uint256) {
        return block.number; // solium-disable-line security/no-block-members
    }
    
    
    function setBaseAddress(BaseRegistrarImplementation _base) public onlyOwner{
        base = _base;
    }
    
    function setDevAddress(address _devAddress) public onlyOwner{
        require(_devAddress!=address(0),"invalid address");
        devAddress = _devAddress;
    }


    function setDevFee(uint256 _devFee) public onlyOwner{
        require(_devFee<=10000,"invalid amount");
        devFee = _devFee;
    }
     function setIsstop(uint8 _is_stop) public onlyOwner{
        require(_is_stop==0||_is_stop==1,'invalid amount');
        is_stop = _is_stop;
    }
    
     modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        // require(!msg.sender.isContract()," address can't be contract");
        _;
    }

    //上架
    function stake(uint256 _tokenId, uint256 _amount ) public isHuman{
         require(is_stop==0,"market is stop");
         
         require(_amount>0,"nft price must greater than 0");

         address nftOwner = base.ownerOf(_tokenId);
         require(nftOwner==msg.sender,"owner invalid");

        address approveAddress = base.getApproved(_tokenId);
        require(approveAddress==address(this),"nft is not approve to contract");

       
        uint256 itemId = autoIncrement;

        ItemInfo memory _nftInfo = ItemInfo(_tokenId,_amount,msg.sender,1,address(0));
        ItemList[itemId] = _nftInfo;

        autoIncrement ++;

        //退回询价
        rebackInquiryFree(_nftInfo.tokenId);

        emit Stake(msg.sender, itemId ,_tokenId,_amount);
        base.transferFrom(msg.sender,address(this),_tokenId);
    }

    //下架
    function unStake(uint256 _itemId) public isHuman{
        require(is_stop==0,"market is stop");
        ItemInfo storage _nftInfo =  ItemList[_itemId];
        require(_nftInfo.status==1,"nft status is error");
        require(_nftInfo.seller==msg.sender,"owner invalid");

         _nftInfo.status = 0;

        //退回询价
        rebackInquiry(_itemId);

        emit UnStake(msg.sender, _itemId);
        base.transferFrom(address(this),msg.sender,_nftInfo.tokenId);
    }

    //购买
    function buy(uint256 _itemId) public isHuman payable{
        require(is_stop==0,"market is stop");

        ItemInfo storage _nftInfo =  ItemList[_itemId];
        require(msg.sender != _nftInfo.seller,"can't for oneself");
        require(_nftInfo.status==1,"nft is unstake or selled");
        require(msg.value >= _nftInfo.amount,"ether not enough");

        _nftInfo.status = 2;
        _nftInfo.buyer = msg.sender;

        //后续
        uint256 amount = _nftInfo.amount;

        //退回询价
        rebackInquiry(_itemId);
        rebackInquiryFree(_nftInfo.tokenId);

        afterProcess(
            _nftInfo.seller,
            amount
        );
        

        emit Sold(_nftInfo.buyer, _itemId,_nftInfo.amount,_nftInfo.seller);
        base.transferFrom(address(this),msg.sender,_nftInfo.tokenId);
    }

    //获取上架NFT 的价格
    function itemPrice(uint256 _itemId) public view returns(uint256){
        ItemInfo memory _nftInfo =  ItemList[_itemId];
        return _nftInfo.amount;
    }

    //询价
    function inquiry(uint256 _itemId) public isHuman payable{
        require(is_stop==0,"market is stop");

        ItemInfo storage _nftInfo =  ItemList[_itemId];
        require(msg.sender != _nftInfo.seller,"can't for oneself");
        require(_nftInfo.status==1,"nft is unstake or selled");
        require(msg.value  > 0,"ether not be zero");
        require(msg.value < _nftInfo.amount,"ether must less nft price");

        InquiryInfo memory _lasInquiryInfo = LastInquiryInfo[_itemId];
        require(msg.value > _lasInquiryInfo.price,"Must be greater than the last inquiry");
    
        uint256 _index = InquiryInfoList[_itemId].length;
        InquiryInfo memory _inquiryInfo = InquiryInfo(msg.sender,msg.value,0,_index);

        //退回上一个人的询价
        rebackInquiry(_itemId);

        LastInquiryInfo[_itemId] = _inquiryInfo;
        InquiryInfoList[_itemId].push(_inquiryInfo);

        inquiryFee = inquiryFee.add(msg.value);

        emit Inquiry(msg.sender,_itemId,msg.value);
    }

    //同意询价交易
    function agreeInquiry(uint256 _itemId) public isHuman {
        require(is_stop==0,"market is stop");

        ItemInfo storage _nftInfo =  ItemList[_itemId];
        require(_nftInfo.status==1,"nft is unstake or selled");
        require(msg.sender ==_nftInfo.seller,"caller is not owner");

        InquiryInfo storage _lasInquiryInfo = LastInquiryInfo[_itemId];
        require(_lasInquiryInfo.status == 0,"has deal or uninquiry");
        require(_lasInquiryInfo.inquiryer != address(0),"inquiryer is zero");
        require(_lasInquiryInfo.price > 0,"inquiry price is zero");
 

        _lasInquiryInfo.status = 1;
        _nftInfo.status = 2;
        _nftInfo.buyer = _lasInquiryInfo.inquiryer;

        //后续
        uint256 amount = _lasInquiryInfo.price;

        inquiryFee = inquiryFee.sub(amount);

        afterProcess(
            msg.sender,
            amount
        );

        inquiryFee = inquiryFee.sub(amount);

        emit InquirySold(_nftInfo.buyer, _itemId,amount,_nftInfo.seller);

        base.transferFrom(address(this),_lasInquiryInfo.inquiryer,_nftInfo.tokenId);
        delete LastInquiryInfo[_itemId];
    }

    //退回询价
    function unInquiry(uint256 _itemId) public isHuman{
        require(is_stop==0,"market is stop");

       InquiryInfo memory _lasInquiryInfo = LastInquiryInfo[_itemId];
       require(_lasInquiryInfo.inquiryer == msg.sender,"havant inquiry");
       require(_lasInquiryInfo.status == 0,"has deal or uninquiry");

       rebackInquiry(_itemId);


       emit UnInquiry(msg.sender,_itemId);   
    }

    //获取询价次数
    function getInquiryCount(uint256 _itemId) public view returns(uint256){
        return InquiryInfoList[_itemId].length;
    }

    //退回询价
    function rebackInquiry(uint256 _itemId) internal{
        InquiryInfo storage _lasInquiryInfo = LastInquiryInfo[_itemId];
        if(_lasInquiryInfo.inquiryer != address(0) && _lasInquiryInfo.price > 0 && _lasInquiryInfo.status == 0){
            _lasInquiryInfo.status = 2;

            InquiryInfo storage _inquiryInfo = InquiryInfoList[_itemId][_lasInquiryInfo.index];
            _inquiryInfo.status = 2;

            inquiryFee = inquiryFee.sub(_lasInquiryInfo.price);

            payable(_lasInquiryInfo.inquiryer).transfer(_lasInquiryInfo.price);
        }

        delete LastInquiryInfo[_itemId];
    }

    //询价 - 未上架
    function inquiryFree(uint256 _tokenId) public isHuman payable{
        require(is_stop==0,"market is stop");

        address nftOwner = base.ownerOf(_tokenId);
        require(msg.sender != nftOwner,"can't for oneself");

        InquiryInfo memory _lasInquiryInfo = LastInquiryFreeInfo[_tokenId];
        require(msg.value > _lasInquiryInfo.price,"Must be greater than the last inquiry");
    
        uint256 _index = InquiryInfoFreeList[_tokenId].length;
        InquiryInfo memory _inquiryInfo = InquiryInfo(msg.sender,msg.value,0,_index);

        //退回上一个人的询价
        rebackInquiryFree(_tokenId);

        LastInquiryFreeInfo[_tokenId] = _inquiryInfo;
        InquiryInfoFreeList[_tokenId].push(_inquiryInfo);

        inquiryFee = inquiryFee.add(msg.value);

        emit InquiryFree(msg.sender,_tokenId,msg.value);
    }

    //同意询价交易 - 未上架
    function agreeInquiryFree(uint256 _tokenId) public isHuman{
        require(is_stop==0,"market is stop");
        
         address nftOwner = base.ownerOf(_tokenId);
         require(nftOwner==msg.sender,"owner invalid");

        InquiryInfo storage _lasInquiryInfo = LastInquiryFreeInfo[_tokenId];
        require(_lasInquiryInfo.status == 0,"has deal or uninquiry");
        require(_lasInquiryInfo.inquiryer != address(0),"inquiryer is zero");
        require(_lasInquiryInfo.price > 0,"inquiry price is zero");
 
        _lasInquiryInfo.status = 1;

        //后续
        uint256 amount = _lasInquiryInfo.price;

        inquiryFee = inquiryFee.sub(amount);

        afterProcess(
            msg.sender,
            amount
        );

        emit InquirySoldFree(_lasInquiryInfo.inquiryer,msg.sender, _tokenId,amount);
        
        base.transferFrom(msg.sender,_lasInquiryInfo.inquiryer,_tokenId);

        delete LastInquiryFreeInfo[_tokenId];
    }

    //退回询价 - 未上架
    function unInquiryFree(uint256 _tokenId) public isHuman{
        require(is_stop==0,"market is stop");

       InquiryInfo memory _lasInquiryInfo = LastInquiryFreeInfo[_tokenId];
       require(_lasInquiryInfo.inquiryer == msg.sender,"havant inquiry");
       require(_lasInquiryInfo.status == 0,"has deal or uninquiry");

       rebackInquiryFree(_tokenId);

       emit UnInquiryFree(msg.sender,_tokenId);   
    }

    //退回询价后续
    function rebackInquiryFree(uint256 _tokenId) internal{
        InquiryInfo storage _lasInquiryInfo = LastInquiryFreeInfo[_tokenId];
        if(_lasInquiryInfo.inquiryer != address(0) && _lasInquiryInfo.price > 0 && _lasInquiryInfo.status == 0){
            _lasInquiryInfo.status = 2;

            InquiryInfo storage _inquiryInfo = InquiryInfoFreeList[_tokenId][_lasInquiryInfo.index];
            _inquiryInfo.status = 2;

            inquiryFee = inquiryFee.sub(_lasInquiryInfo.price);

            payable(_lasInquiryInfo.inquiryer).transfer(_lasInquiryInfo.price);
        }

        delete LastInquiryFreeInfo[_tokenId];
    }

    //获取询价次数
    function getInquiryFreeCount(uint256 _tokenId) public view returns(uint256){
        return InquiryInfoFreeList[_tokenId].length;
    }

    //拍卖上架
    function auctionStake(uint256 _tokenId, uint256 startPrice, uint256 markup,uint256 startTime, uint256 overTime) public isHuman{
         require(is_stop==0,"market is stop");
         require(overTime > block.timestamp ,"overTime must greater than now time");
         require(startTime < overTime,"startTime must greater than overTime");
         require(startPrice>0,"nft price must greater than 0");
         require(markup>0,"markup must greater than 0");
         

         address nftOwner = base.ownerOf(_tokenId);
         require(nftOwner==msg.sender,"owner invalid");

        address approveAddress = base.getApproved(_tokenId);
        require(approveAddress==address(this),"nft is not approve to contract");

       
       
        uint256 itemId = autoIncrement;
        

         auctionInfo memory _auctionInfo = auctionInfo(_tokenId,startPrice,markup,startTime,overTime,msg.sender,1,address(0));
         auctionList[itemId] = _auctionInfo;

         autoIncrement ++;

         emit AuctionStake(msg.sender, itemId ,_tokenId,startPrice,markup,startTime,overTime);
         base.transferFrom(msg.sender,address(this),_tokenId);
    }

    //拍卖下架
    function unAuctionStake(uint256 _itemId) public isHuman{
        require(is_stop==0,"market is stop");

        auctionInfo storage _auctionInfo =  auctionList[_itemId];
        require(_auctionInfo.status==1,"nft status is error");
        require(_auctionInfo.seller==msg.sender,"owner invalid");

         _auctionInfo.status = 0;

        //后续
        emit UnAuctionStake(msg.sender, _itemId);
        base.transferFrom(address(this),msg.sender,_auctionInfo.tokenId);
    }

    //拍卖出价
    function auctionBid(uint256 _itemId) public isHuman payable{
         require(is_stop==0,"market is stop");
         auctionInfo storage _auctionInfo =  auctionList[_itemId];
         require(_auctionInfo.seller != msg.sender,"owner cant bid");
         require(_auctionInfo.status>0,"auction status is error");
         require(_auctionInfo.startTime < block.timestamp,"auciton not start");
         require(_auctionInfo.overTime > block.timestamp,"auciton is end");
         require(_auctionInfo.buyer != msg.sender,"has bid");


         InquiryInfo storage _lasInquiryInfo = lastAuctionInquiryInfo[_itemId];

         uint256 startAmount = _auctionInfo.startPrice;
         //如果有人出过价
         if(_auctionInfo.status == 2){
             startAmount = _lasInquiryInfo.price.add(_auctionInfo.markup);
         }

         require(msg.value >= startAmount,"price is error");

         //退回上一个人的出价
         if(_lasInquiryInfo.inquiryer!=address(0)){
            auctionInquiryInfoList[_itemId][_lasInquiryInfo.index].status = 2;
            payable(_lasInquiryInfo.inquiryer).transfer(_lasInquiryInfo.price);
            inquiryFee = inquiryFee.sub(_lasInquiryInfo.price);
         }

         _lasInquiryInfo.inquiryer = msg.sender;
         _lasInquiryInfo.price = msg.value;
         _lasInquiryInfo.status = 0;
         _lasInquiryInfo.index = auctionInquiryInfoList[_itemId].length;

         auctionInquiryInfoList[_itemId].push(_lasInquiryInfo);

         _auctionInfo.status = 2;


        inquiryFee = inquiryFee.add(msg.value);


         emit AuctionBid(msg.sender,_itemId,msg.value,_lasInquiryInfo.index);
    }

    //领取
    function auctionClaim(uint256 _itemId) public isHuman{
        require(is_stop==0,"market is stop");
        auctionInfo storage _auctionInfo =  auctionList[_itemId];
        require(_auctionInfo.status==2,"auction status is error");
        require(_auctionInfo.overTime < block.timestamp,"auciton not end");
        require(_auctionInfo.buyer==address(0),"has claim");

        InquiryInfo memory _lasInquiryInfo = lastAuctionInquiryInfo[_itemId];

        auctionInquiryInfoList[_itemId][_lasInquiryInfo.index].status = 1;

        _auctionInfo.buyer = _lasInquiryInfo.inquiryer;

        uint256 amount = _lasInquiryInfo.price;

        inquiryFee = inquiryFee.sub(amount);

        afterProcess(
            _auctionInfo.seller,
            amount
        );
        
        emit AuctionSold(_auctionInfo.buyer,_itemId,_lasInquiryInfo.price,_auctionInfo.seller,_lasInquiryInfo.index);

        base.transferFrom(address(this),_auctionInfo.buyer,_auctionInfo.tokenId);

        delete lastAuctionInquiryInfo[_itemId];
        
    }

    //交易后续操作
    function afterProcess(
        address _seller,
        uint256 amount
    ) internal {
        uint256 devAmount = amount.mul(devFee).div(10000);
        uint256 transferAmount = amount.sub(devAmount);


        //将扣除手续费的资金转给原NFT所有者
        payable(_seller).transfer(transferAmount);

        //手续费分配
        if(devAddress != address(0)){
            if(address(this).balance >= inquiryFee){
                (bool success, ) = payable(devAddress).call{
                    value: address(this).balance.sub(inquiryFee)
                }("");
                require(success, "TRANSFER_FAILED");
            }
        }
    }

}