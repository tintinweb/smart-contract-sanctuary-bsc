/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-13
*/

// SPDX-License-Identifier: MIT


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

library SafeMathUpgradeable {
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


interface IERC20Upgradeable {
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

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract EcpsMarket  {


    using SafeMathUpgradeable for uint;
    using Address for address;

    address public admin;

    IERC721 public nft;

    IERC20Upgradeable public COP;

    IERC20Upgradeable public ROC;

    address public marginAddress; // 保证金池子

    address public dividendAddress; // 分红池子

    address public burnAddress; // 燃烧地址

    bool initialized;

    struct Commodity {
        address sellAdderss; // 出售地址
        uint ecpsSellType; // 出售方式 1：固定 2: 拍卖
        uint256 ecpsAmount; // 出售价格
        uint coin; // 出售币种 1：COP 2: ROC
        uint auctionEndTime; // 竞拍结束时间
        address highestBidder; // 最高出价地址
        uint highestBid; // 最高出价
        bool ended; // 竞拍结束
    }

    Commodity commodity;

    struct CommodityInfo {
        string ecpsName; // 作品名称
        string ecpsIntroduce; // 作品介绍
        string ecpsPicture; // 作品图片
        bool copyright; // 是否开启版税
        address copyrightAdderss; // 版税地址
        bool isPutaway;
    }

    CommodityInfo commodityInfo;

    mapping(uint=> Commodity) public commodityList;

    mapping(uint=> CommodityInfo) public commodityInfoList;

    mapping(uint => mapping(address => uint)) public bidMap;

    event Sale(address, uint);

    event SaleAgain(address, uint);

    event Down(address, uint);

    event Buy(address,address,uint);

    event Markup(address,address,uint);

    event MarkupEnd(address,uint);

    modifier onlyAdmin {
        require(msg.sender == admin,"You Are not admin");
        _;
    }

    /**
     * 初始化
     */
    function initialize(address _admin, address _marginAddress, address _dividendAddress, address _nftAddress, address _copAddress, address _rocAddress, address _burnAddress) external {
        require(!initialized,"initialized");
        admin = _admin;
        marginAddress = _marginAddress;
        dividendAddress = _dividendAddress;
        nft = IERC721(_nftAddress);
        COP = IERC20Upgradeable(_copAddress);
        ROC = IERC20Upgradeable(_rocAddress);
        burnAddress = _burnAddress;
        initialized = true;
    }

    function setParam(
        address _admin
    ) external onlyAdmin {
        admin = address(_admin);
    }

    /**
    * 查询是否创建过
    */
    function isExistEntry(uint _tokenId) public view returns(bool){
        return commodityInfoList[_tokenId].isPutaway;
    }

    /**
     * 上架出售
     */
    function sale(uint _tokenId,
        string memory ecpsName,
        string memory ecpsIntroduce,
        string memory ecpsPicture,
        uint ecpsSellType,
        uint256 ecpsAmount,
        uint coin,
        uint auctionEndTime,
        bool copyright) external {
        require(!isExistEntry(_tokenId), "The tokenId has been created");
        nft.transferFrom(msg.sender, address(this),_tokenId);
        commodity = Commodity(msg.sender, ecpsSellType, ecpsAmount, coin, auctionEndTime,msg.sender,0,false);
        commodityInfo = CommodityInfo(ecpsName, ecpsIntroduce, ecpsPicture, copyright, msg.sender,false);
        if(coin == 1){
            COP.transferFrom(msg.sender, marginAddress, ecpsAmount.mul(10).div(100));
        } else if(coin == 2){
            ROC.transferFrom(msg.sender, marginAddress, ecpsAmount.mul(10).div(100));
        } else {
            require(1 == 2, "the nft is banned");
        }
        commodityList[_tokenId] = commodity;
        commodityInfoList[_tokenId] = commodityInfo;
        emit Sale(msg.sender, _tokenId);
    }

    /**
     * 再次出售
     */
    function sellAgain(uint _tokenId,
        uint ecpsSellType,
        uint256 ecpsAmount,
        uint coin,
        uint auctionEndTime) external {
        require(commodityList[_tokenId].ended, "The tokenId has been created");
        nft.transferFrom(msg.sender, address(this),_tokenId);
        commodity = Commodity(msg.sender, ecpsSellType, ecpsAmount, coin, auctionEndTime,msg.sender,0,false);
        if(coin == 1){
            COP.transferFrom(msg.sender, marginAddress, ecpsAmount.mul(10).div(100));
        } else if(coin == 2){
            ROC.transferFrom(msg.sender, marginAddress, ecpsAmount.mul(10).div(100));
        } else {
            require(1 == 2, "the nft is banned");
        }
        commodityList[_tokenId] = commodity;
        emit Sale(msg.sender, _tokenId);
    }

    /**
     * 下架
     */
    function down(uint _tokenId) external {
        require(msg.sender == commodityList[_tokenId].sellAdderss, "No operation permission");
        // if(commodityList[_tokenId].coin == 1){
        //     COP.transferFrom(marginAddress, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
        // } else if(commodityList[_tokenId].coin == 2){
        //     ROC.transferFrom(marginAddress, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
        // } else {
        //     require(1 == 2, "the nft is banned");
        // }
        nft.transferFrom(address(this), msg.sender,_tokenId);
        delete commodityList[_tokenId];
        emit Down(msg.sender, _tokenId);
    }

    /**
     * 购买
     */
    function buy(uint _tokenId) external  {
        require(1 == commodityList[_tokenId].ecpsSellType, "No operation permission");
        if(commodityList[_tokenId].coin == 1){
            if(commodityInfoList[_tokenId].copyright){
                COP.transferFrom(msg.sender, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(85).div(100));
                COP.transferFrom(msg.sender, commodityInfoList[_tokenId].copyrightAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
            } else{
                COP.transferFrom(msg.sender, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(95).div(100));
            }
            COP.transferFrom(msg.sender, dividendAddress, commodityList[_tokenId].ecpsAmount.mul(5).div(100));
            // COP.transferFrom(marginAddress, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
        } else if(commodityList[_tokenId].coin == 2){
            if(commodityInfoList[_tokenId].copyright){
                ROC.transferFrom(msg.sender, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(85).div(100));
                ROC.transferFrom(msg.sender, commodityInfoList[_tokenId].copyrightAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
            } else{
                ROC.transferFrom(msg.sender, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(95).div(100));
            }
            ROC.transferFrom(msg.sender, dividendAddress, commodityList[_tokenId].ecpsAmount.mul(5).div(100));
            // ROC.transferFrom(marginAddress, commodityList[_tokenId].sellAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
        } else {
            require(1 == 2, "the nft is banned");
        }
        nft.transferFrom(address(this),msg.sender,_tokenId);
        address _sellAdderss =  commodityList[_tokenId].sellAdderss;
        delete commodityList[_tokenId];
        emit Buy(_sellAdderss, msg.sender, _tokenId);
    }

    /**
     * 加价
     */
    function markup(uint _tokenId,uint256 amount) external  {
        require(!commodityList[_tokenId].ended, "Auction has ended");
        require(2 == commodityList[_tokenId].ecpsSellType, "No operation permission");
        if(commodityList[_tokenId].coin == 1){
            COP.transferFrom(msg.sender, address(this), amount);
        } else if(commodityList[_tokenId].coin == 2){
            ROC.transferFrom(msg.sender, address(this), amount);
        } else {
            require(1 == 2, "the nft is banned");
        }
        uint256 betRecordAmount = bidMap[_tokenId][msg.sender];
        betRecordAmount+=amount;
        commodity = commodityList[_tokenId];

        if(commodity.highestBid < betRecordAmount){
            commodity.highestBidder = msg.sender;
            commodity.highestBid = betRecordAmount;
        }
        commodityList[_tokenId] = commodity;
        bidMap[_tokenId][msg.sender] = betRecordAmount;
        emit Markup(commodityList[_tokenId].sellAdderss, msg.sender, _tokenId);
    }

    /**
     * 结束拍卖
     */
     function markupEnd(uint _tokenId, address[] memory bidAddress) external onlyAdmin {
        require(!commodityList[_tokenId].ended, "Auction has ended");
        commodity = commodityList[_tokenId];
        commodity.ended = true;
        commodityList[_tokenId] = commodity;
        // 批量退钱
        if(commodityList[_tokenId].coin == 1){
            for (uint i = 0; i < bidAddress.length; i++) {
                COP.transfer(  bidAddress[i], bidMap[_tokenId][bidAddress[i]]);
            }
            if(commodityList[_tokenId].highestBid > 0){
                if(commodityInfoList[_tokenId].copyright){
                    COP.transfer(commodityList[_tokenId].sellAdderss, commodityList[_tokenId].highestBid.mul(85).div(100));
                    COP.transfer(commodityInfoList[_tokenId].copyrightAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
                } else{
                    COP.transfer(commodityList[_tokenId].sellAdderss, commodityList[_tokenId].highestBid.mul(95).div(100));
                }
                COP.transfer(dividendAddress, commodityList[_tokenId].highestBid.mul(5).div(100));
            }
        } else if(commodityList[_tokenId].coin == 2){
            for (uint i = 0; i < bidAddress.length; i++) {
                ROC.transfer(  bidAddress[i], bidMap[_tokenId][bidAddress[i]]);
            }
            if(commodityList[_tokenId].highestBid > 0){
                if(commodityInfoList[_tokenId].copyright){
                    ROC.transfer(commodityList[_tokenId].sellAdderss, commodityList[_tokenId].highestBid.mul(85).div(100));
                    ROC.transfer(commodityInfoList[_tokenId].copyrightAdderss, commodityList[_tokenId].ecpsAmount.mul(10).div(100));
                } else{
                    ROC.transfer(commodityList[_tokenId].sellAdderss, commodityList[_tokenId].highestBid.mul(95).div(100));
                }
                ROC.transfer(dividendAddress, commodityList[_tokenId].highestBid.mul(5).div(100));
            }
        }
        nft.transferFrom(address(this),commodity.highestBidder,_tokenId);
        delete commodityList[_tokenId];
        emit MarkupEnd(msg.sender, _tokenId);
    }

    function withdrawCOP(address _addr, uint _amount) external onlyAdmin {
        require(_addr!=address(0),"Can not withdraw to Blackhole");
        COP.transfer(_addr, _amount);
    }

    function batchAdminWithdrawCOP(address[] memory _userList, uint[] memory _amount) external onlyAdmin {
        for (uint i = 0; i < _userList.length; i++) {
            COP.transfer(address(_userList[i]), uint(_amount[i]));
        }
    }

    function withdrawROC(address _addr, uint _amount) external onlyAdmin {
        require(_addr!=address(0),"Can not withdraw to Blackhole");
        ROC.transfer(_addr, _amount);
    }

    function batchAdminWithdrawROC(address[] memory _userList, uint[] memory _amount) external onlyAdmin {
        for (uint i = 0; i < _userList.length; i++) {
            ROC.transfer(address(_userList[i]), uint(_amount[i]));
        }
    }

    receive () external payable {}
}