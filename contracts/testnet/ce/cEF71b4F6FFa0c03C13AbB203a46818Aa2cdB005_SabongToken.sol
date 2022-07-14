/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;


//import "../../utils/Context.sol";
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


//import "../../utils/Address.sol";
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


//import "@openzeppelin/contracts/utils/Strings.sol";
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


//import "@openzeppelin/contracts/access/Ownable.sol";
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


//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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


//import "./IERC165.sol";
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


//import "./IERC721.sol";
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


//import "./IERC721Receiver.sol";
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


// import "./extensions/IERC721Metadata.sol";
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


//import "../../utils/introspection/ERC165.sol";
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


//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
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
        address owner = ERC721.ownerOf(tokenId);
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
        address owner = ERC721.ownerOf(tokenId);
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
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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


//-----------------------------------
// SabongToken(ERC721)
//-----------------------------------
contract SabongToken is Ownable, ERC721 {
    //--------------------------------------
    // イベント
    //--------------------------------------
    event TokenBirthed( address indexed owner, uint256 indexed parentId0, uint256 indexed parentId1, uint256 tokenId, uint256 timeToAdult, uint256 gen );
    event TokenBreeded( uint256 indexed tokenId, uint256 consumed, uint256 childId, uint256 childGen );
    event TokenGrew( uint256 indexed tokenId );
    event TokenLendingStarted( uint256 indexed tokenId, address indexed from, address indexed to );
    event TokenLendingFinished( uint256 indexed tokenId, address indexed from, address indexed to );
    event TokenGifted( uint256 indexed tokenId, address indexed from, address indexed to );
    event TokenReleased( uint256 indexed tokenId );

    //--------------------------------------
    // 定数
    //--------------------------------------
    string constant private TOKEN_NAME = "Sabong Token";
    string constant private TOKEN_SYMBOL = "ST";
    uint256 constant private TOKEN_ID_OFFSET = 1;
    uint256 constant private INVAlID_PARENT_ID = 0;
    uint256 constant private MAX_BREED_COUNT = 7;
    uint256 constant private MAX_GEN_TOTAL = 21;

    //--------------------------------------
    // 管理データ
    //--------------------------------------
    // 管理者
    address private _manager;

    // 手数料徴収者
    address private _fee_receiver;

    // NFTを直接MINTできるアドレスのマップ
    mapping( address => bool ) private _map_mintable_for_address;

    // コストの対象となるコントラクト
    IERC20 private _sbg_contract;   // SBG
    IERC20 private _sst_contract;   // SST

    // URI参照先の基本(※これにtokenIdをつけて返す)
    string private _base_uri;

    // 交配後に成体化が成功するまでの待ち時間
    uint256 private _wait_to_adult;

    // コストの内容
    uint256[MAX_GEN_TOTAL] private _sbg_costs;
    uint256[MAX_GEN_TOTAL] private _sst_costs;

    //--------------------------------------
    // ストレージ
    //--------------------------------------
    // 供給数
    uint256 private _total_supply;

    // NFT個別    
    uint256[] private _arr_consumed;        // 交配した回数
    uint256[] private _arr_gen;             // 世代
    uint256[] private _arr_parent0;         // 親のID(0)
    uint256[] private _arr_parent1;         // 親のID(1)
    uint256[] private _arr_time_to_adult;   // 成体になれる時間(growが成功するようになるunixtime)
    bool[] private _arr_is_adult;           // 成体か？(交配等が可能か？)
    uint256[][] private _arr_children;      // 子供のID

    // 貸し出し情報（スカラーシップ）
    mapping( uint256 => address ) private _map_lending_from;
    mapping( uint256 => address ) private _map_lending_to;

    //-------------------------------------------------
    // [modifier] 管理者か？
    //-------------------------------------------------
    modifier onlyManager(){
        require( msg.sender == _manager, "not the manager" );
        _;
    }

    //-------------------------------------------------
    // [modifier] ミント可能か？
    //-------------------------------------------------
    modifier onlyMintable(){
        require( _map_mintable_for_address[msg.sender], "not mintable" );
        _;
    }

    //--------------------------------------
    // コンストラクタ
    //--------------------------------------
    constructor() Ownable() ERC721( TOKEN_NAME, TOKEN_SYMBOL ) {
        // test
        _manager = msg.sender;
        _fee_receiver = msg.sender;
        _map_mintable_for_address[msg.sender] = true;

        _sbg_contract = IERC20( 0xb30A813998c16797870dBb9E47552240d82c9eEC );
        _sst_contract = IERC20( 0x8D61e614E418889645dE14Cdf63F5ED304a2FAF7 );

        // デフォルト値設定
        // _base_uri = "https://sabong.com/api/getMetadata?id=";
        //_wait_to_adult = 5*24*60*60;   // 5日間(暫定)

        // test
        _base_uri = "https://stg.sabong.com/api/getMetadata?id=";
        _wait_to_adult = 10*60; // 5*24*60*60;   // 10分(ダミー)

        uint256 sbgD = 10**4;
        uint256 sstD = 10**4;
        _sbg_costs[ 0]  =  10*sbgD;    _sst_costs[ 0]  =  0*sstD;
        _sbg_costs[ 1]  =  20*sbgD;    _sst_costs[ 1]  =  0*sstD;
        _sbg_costs[ 2]  =  30*sbgD;    _sst_costs[ 2]  =  0*sstD;
        _sbg_costs[ 3]  =  40*sbgD;    _sst_costs[ 3]  =  1*sstD;
        _sbg_costs[ 4]  =  50*sbgD;    _sst_costs[ 4]  =  2*sstD;
        _sbg_costs[ 5]  =  60*sbgD;    _sst_costs[ 5]  =  3*sstD;
        _sbg_costs[ 6]  =  70*sbgD;    _sst_costs[ 6]  =  4*sstD;
        _sbg_costs[ 7]  =  80*sbgD;    _sst_costs[ 7]  =  5*sstD;
        _sbg_costs[ 8]  =  90*sbgD;    _sst_costs[ 8]  =  6*sstD;
        _sbg_costs[ 9]  = 100*sbgD;    _sst_costs[ 9]  =  7*sstD;
        _sbg_costs[10]  = 110*sbgD;    _sst_costs[10]  =  8*sstD;
        _sbg_costs[11]  = 120*sbgD;    _sst_costs[11]  =  9*sstD;
        _sbg_costs[12]  = 130*sbgD;    _sst_costs[12]  = 10*sstD;
        _sbg_costs[13]  = 140*sbgD;    _sst_costs[13]  = 11*sstD;
        _sbg_costs[14]  = 150*sbgD;    _sst_costs[14]  = 12*sstD;
        _sbg_costs[15]  = 160*sbgD;    _sst_costs[15]  = 13*sstD;
        _sbg_costs[16]  = 170*sbgD;    _sst_costs[16]  = 14*sstD;
        _sbg_costs[17]  = 180*sbgD;    _sst_costs[17]  = 15*sstD;
        _sbg_costs[18]  = 190*sbgD;    _sst_costs[18]  = 16*sstD;
        _sbg_costs[19]  = 200*sbgD;    _sst_costs[19]  = 17*sstD;
        _sbg_costs[20]  = 210*sbgD;    _sst_costs[20]  = 18*sstD;
    }

    //--------------------------------------
    // [public] マネージャー
    //--------------------------------------
    function manager() public view returns (address) {
        return( _manager );
    }

    //--------------------------------------
    // [external/onlyOwner] マネージャー設定
    //--------------------------------------
    function setManager( address target ) external onlyOwner {
        _manager = target;
    }

    //--------------------------------------
    // [external] 確認
    //--------------------------------------
    function feeReceiver() external view returns (address) { return( _fee_receiver ); }
    function isMintable( address target ) external view returns (bool) { return( _map_mintable_for_address[target] ); }
    function sbgContract() external view returns (address) { return( address(_sbg_contract) ); }
    function sstContract() external view returns (address) { return( address(_sst_contract) ); }

    function baseURI() external view returns (string memory) { return( _base_uri ); }
    function waitToAdult() external view returns (uint256) { return( _wait_to_adult ); }
    function sbgCostAt( uint256 genTotal ) external view returns (uint256) { return( _sbg_costs[genTotal] ); }
    function sstCostAt( uint256 genTotal ) external view returns (uint256) { return( _sst_costs[genTotal] ); }

    //--------------------------------------
    // [external/onlyManager] 設定
    //--------------------------------------
    function setFeeReceiver( address target ) external onlyManager { _fee_receiver = target; }
    function setMintable( address target, bool flag ) external onlyManager {
        if( flag ){
            _map_mintable_for_address[target] = true;
        }else{
            delete _map_mintable_for_address[target];
        }
    }
    function setSbgContract( address target ) external onlyManager { _sbg_contract = IERC20(target); }
    function setSstContract( address target ) external onlyManager { _sst_contract = IERC20(target); }

    function setBaseURI( string calldata uri ) external onlyManager { _base_uri = uri; }
    function setWaitToAdult( uint256 wait ) external onlyManager { _wait_to_adult = wait; }
    function setSbgCostAt( uint256 genTotal, uint256 val ) external onlyManager { _sbg_costs[genTotal] = val; }
    function setSstCostAt( uint256 genTotal, uint256 val ) external onlyManager { _sst_costs[genTotal] = val; }

    //--------------------------------------
    // [external] 情報確認：供給数
    //--------------------------------------
    function totalSupply() external view returns (uint256) { return( _total_supply ); }
    function totalMinted() external view returns (uint256) { return( _arr_consumed.length ); }

    //--------------------------------------
    // [public] トークンURI
    //--------------------------------------
    function tokenURI( uint256 tokenId ) public view override returns (string memory) {
        require( _exists( tokenId ), "nonexistent token" );

        return( string( abi.encodePacked( _base_uri, Strings.toString( tokenId ) ) ) );
    }

    //--------------------------------------
    // [external] 情報確認：NFT個別
    //--------------------------------------
    function consumedAt( uint256 tokenId ) external view returns (uint256) { return( _arr_consumed[tokenId-TOKEN_ID_OFFSET] ); }
    function genAt( uint256 tokenId ) external view returns (uint256) { return( _arr_gen[tokenId-TOKEN_ID_OFFSET] ); }
    function parent0At( uint256 tokenId ) external view returns (uint256) { return( _arr_parent0[tokenId-TOKEN_ID_OFFSET] ); }
    function parent1At( uint256 tokenId ) external view returns (uint256) { return( _arr_parent1[tokenId-TOKEN_ID_OFFSET] ); }
    function timeToAdultAt( uint256 tokenId ) external view returns (uint256) { return( _arr_time_to_adult[tokenId-TOKEN_ID_OFFSET] ); }
    function isAdultAt( uint256 tokenId ) external view returns (bool) { return( _arr_is_adult[tokenId-TOKEN_ID_OFFSET] ); }
    function childrenAt( uint256 tokenId ) external view returns (uint256[] memory) { return( _arr_children[tokenId-TOKEN_ID_OFFSET] ); }
    function isGrowableAt( uint256 tokenId ) external view returns (bool) { return( ! _arr_is_adult[tokenId-TOKEN_ID_OFFSET] && block.timestamp >= _arr_time_to_adult[tokenId-TOKEN_ID_OFFSET] ); }
    function isLentAt( uint256 tokenId ) external view returns (bool) { return( _map_lending_from[tokenId] != address(0) ); }
    function lendingFromAt( uint256 tokenId ) external view returns (address) { return( _map_lending_from[tokenId] ); }
    function lendingToAt( uint256 tokenId ) external view returns (address) { return( _map_lending_to[tokenId] ); }
    function isReleasedAt( uint256 tokenId ) external view returns (bool) { return( tokenId <= _arr_consumed.length && ! _exists(tokenId) ); }

    //------------------------------------------------------
    // [external/onlyMintable] トークンの発行（運営等による直接発行）
    //------------------------------------------------------
    function mintTokens( address[] calldata owners, uint256[] calldata nums, uint256[] calldata waits ) external onlyMintable {
        require( owners.length == nums.length, "mismatch array sizes" );
        require( owners.length == waits.length, "mismatch array sizes" );
        for( uint256 i=0; i<owners.length; i++ ){
            require( owners[i] != address(0), "invalid address" );
            require( nums[i] > 0, "invalid num" );
        }

        // mint
        for( uint256 i=0; i<owners.length; i++ ){
            for( uint256 j=0; j<nums[i]; j++ ){
                _birth( owners[i], INVAlID_PARENT_ID, INVAlID_PARENT_ID, waits[i], 0 );    // ジェネシス(世代０＝両親は無効）
            }
        }
    }

    //---------------------------------------------
    // [external] 両親を指定しての交配（ユーザーによる発行）
    //---------------------------------------------
    function breed( uint256 tokenId0, uint256 tokenId1 ) external {
        require( tokenId0 != tokenId1, "same tokenId" );
        require( _exists( tokenId0 ), "nonexistent token0" );
        require( _exists( tokenId1 ), "nonexistent token1" );
        require( ownerOf( tokenId0 ) == msg.sender, "not owned token0" );
        require( ownerOf( tokenId1 ) == msg.sender, "not owned token1" );

        // 両親の確認（内部でrequire判定をしている）
        uint256 dataId0 = tokenId0 - TOKEN_ID_OFFSET;
        uint256 dataId1 = tokenId1 - TOKEN_ID_OFFSET;
        _checkParents( tokenId0, tokenId1, dataId0, dataId1 );

        // コストの消費と世代の算出
        uint256 gen = _checkGenThenWasteCost( dataId0, dataId1, msg.sender );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        // 誕生（内部でイベントが発火する）
        uint256 tokenId = _birth( msg.sender, tokenId0, tokenId1, block.timestamp + _wait_to_adult, gen );

        // 両親の更新（交配数を加算、子供のログに追加）
        _arr_consumed[dataId0]++;
        _arr_consumed[dataId1]++;
        _arr_children[dataId0].push( tokenId );
        _arr_children[dataId1].push( tokenId );

        // イベント：交配
        emit TokenBreeded( tokenId0, _arr_consumed[dataId0], tokenId, gen );
        emit TokenBreeded( tokenId1, _arr_consumed[dataId1], tokenId, gen );
    }

    //--------------------------------------
    // [internal] 両親の確認
    //--------------------------------------
    function _checkParents( uint256 tokenId0, uint256 tokenId1, uint256 dataId0, uint256 dataId1 ) internal view returns (bool) {
        // 成長しているか？
        require( _arr_is_adult[dataId0], "not adult token0" );
        require( _arr_is_adult[dataId1], "not adult token1" );        

        // 余力はあるか？
        require( _arr_consumed[dataId0] < MAX_BREED_COUNT, "consumed token0" );
        require( _arr_consumed[dataId1] < MAX_BREED_COUNT, "consumed token1" );

        // 親との交配はNG
        require( tokenId0 != _arr_parent0[dataId1] && tokenId0 != _arr_parent1[dataId1], "breed with child" );
        require( tokenId1 != _arr_parent0[dataId0] && tokenId1 != _arr_parent1[dataId0], "breed with child" );

        // 兄弟との交配はNG（親が無効なら制限は無い）
        require( _arr_parent0[dataId0] == INVAlID_PARENT_ID || (_arr_parent0[dataId0] != _arr_parent0[dataId1] && _arr_parent0[dataId0] != _arr_parent1[dataId1]), "same parent" );
        require( _arr_parent1[dataId0] == INVAlID_PARENT_ID || (_arr_parent1[dataId0] != _arr_parent0[dataId1] && _arr_parent1[dataId0] != _arr_parent1[dataId1]), "same parent" );
        require( _arr_parent0[dataId1] == INVAlID_PARENT_ID || (_arr_parent0[dataId1] != _arr_parent0[dataId0] && _arr_parent0[dataId1] != _arr_parent1[dataId0]), "same parent" );
        require( _arr_parent1[dataId1] == INVAlID_PARENT_ID || (_arr_parent1[dataId1] != _arr_parent0[dataId0] && _arr_parent1[dataId1] != _arr_parent1[dataId0]), "same parent" );

        // ここまできたら交配可能
        return( true );
    }

    //--------------------------------------
    // [internal] 世代によるコストの消費
    //--------------------------------------
    function _checkGenThenWasteCost( uint256 dataId0, uint256 dataId1, address msgSender ) internal returns (uint256) {
        uint256 costRate;
        if( _arr_consumed[dataId0] > _arr_consumed[dataId1] ){ costRate = _arr_consumed[dataId0] + 1; }
        else{ costRate = _arr_consumed[dataId1] + 1; }

        uint256 genTotal = _arr_gen[dataId0] + _arr_gen[dataId1];
        if( genTotal >= MAX_GEN_TOTAL ){
            genTotal = MAX_GEN_TOTAL - 1;
        }

        // コストの算出
        uint256 costSbg = costRate * _sbg_costs[genTotal];
        uint256 costSst = costRate * _sst_costs[genTotal];

        // コストの消費
        if( costSbg > 0 ){
            _sbg_contract.transferFrom( msgSender, _fee_receiver, costSbg );
        }

        if( costSst > 0 ){
            _sst_contract.transferFrom( msgSender, _fee_receiver, costSst );
        }

        // 世代を返す
        uint256 gen;
        if( _arr_gen[dataId0] > _arr_gen[dataId1] ){ gen = _arr_gen[dataId0] + 1; }
        else{ gen = _arr_gen[dataId1] + 1; }
        return( gen );
    }

    //--------------------------------------
    // [internal] トークンの誕生（実体）
    //--------------------------------------
    function _birth( address owner, uint256 id0, uint256 id1, uint256 timeToAdult, uint256 gen ) internal returns (uint256) {
        // 発行
        uint256 tokenId = _arr_consumed.length + TOKEN_ID_OFFSET;

        // データの追加
        _arr_consumed.push( 0 );
        _arr_gen.push( gen );
        _arr_parent0.push( id0 );
        _arr_parent1.push( id1 );
        _arr_time_to_adult.push( timeToAdult );
        _arr_is_adult.push( false );
        uint256[] memory arrEmpty = new uint256[](0);
        _arr_children.push( arrEmpty );

        // イベント：誕生
        emit TokenBirthed( owner, id0, id1, tokenId, timeToAdult, gen );

        // ミント
        _safeMint( owner, tokenId );    // 内部で[ERC721.Transfer]が発火する

        // 供給量の加算
        _total_supply++;

        // 時間指定がなければ成体にする
        if( timeToAdult <= 0 ){
            _grow( tokenId );
        }

        return( tokenId );
    }

    //--------------------------------------
    // [external] 成長(所有者)
    //--------------------------------------
    function grow( uint256 tokenId ) external {
        require( _exists( tokenId ), "nonexistent token" );
        require( ! _arr_is_adult[tokenId-TOKEN_ID_OFFSET], "already grew" );
        require( block.timestamp >= _arr_time_to_adult[tokenId-TOKEN_ID_OFFSET], "time not passed" );
        require( ownerOf( tokenId ) == msg.sender, "not owned token" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _grow( tokenId );
    }

    //--------------------------------------
    // [external/onlyManager] 成長(管理者)
    //--------------------------------------
    function growByManager( uint256 tokenId ) external onlyManager {
        require( _exists( tokenId ), "nonexistent token" );
        require( ! _arr_is_adult[tokenId-TOKEN_ID_OFFSET], "already grew" );
        require( block.timestamp >= _arr_time_to_adult[tokenId-TOKEN_ID_OFFSET], "time not passed" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _grow( tokenId );
    }

    //--------------------------------------
    // [internal] トークンの成長（実体）
    //--------------------------------------
    function _grow( uint256 tokenId ) internal {
        // 成長フラグを立てる
        _arr_is_adult[tokenId-TOKEN_ID_OFFSET] = true;

        // イベント：成長
        emit TokenGrew( tokenId );
    }

    //--------------------------------------
    // [external] 貸し出し開始（所有者)
    //--------------------------------------
    function startLending( uint256 tokenId, address to ) external {
        require( _exists( tokenId ), "nonexistent token" );
        require( _arr_is_adult[tokenId-TOKEN_ID_OFFSET], "not adult" );
        require( _map_lending_from[tokenId] == address(0), "already lent" );
        require( ownerOf( tokenId ) == msg.sender, "not owned token" );
        require( msg.sender != to, "sender is to" );
        require( to != address(0), "invalid to" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _startLending( tokenId, msg.sender, to );
    }

    //--------------------------------------
    // [external/onlyManager] 貸し出し開始（管理者)
    //--------------------------------------
    function startLendingByManager( uint256 tokenId, address from, address to ) external onlyManager {
        require( _exists( tokenId ), "nonexistent token" );
        require( _arr_is_adult[tokenId-TOKEN_ID_OFFSET], "not adult" );
        require( _map_lending_from[tokenId] == address(0), "already lent" );
        require( ownerOf( tokenId ) == from, "not owned token" );
        require( from != to, "from is to" );
        require( from != address(0), "invalid from" );
        require( to != address(0), "invalid to" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _startLending( tokenId, from, to );
    }

    //--------------------------------------
    // [internal] 貸し出し開始(実体)
    //--------------------------------------
    function _startLending( uint256 tokenId, address from, address to ) internal {
        // 転送
        _transfer( from, address(this), tokenId );  // 内部で[ERC721.Transfer]が発火する

        // イベント：貸し出し開始
        emit TokenLendingStarted( tokenId, from, to );

        // 登録
        _map_lending_from[tokenId] = from;
        _map_lending_to[tokenId] = to;
    }

    //--------------------------------------
    // [external] 貸し出し終了（所有者)
    //--------------------------------------
    function finishLending( uint256 tokenId ) external {
        require( _exists( tokenId ), "nonexistent token" );
        require( _map_lending_from[tokenId] == msg.sender, "not owned token" );
        require( ownerOf( tokenId ) == address(this), "not managed token" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _finishLending( tokenId );
    }

    //--------------------------------------
    // [external/onlyManager] 貸し出し終了（管理者)
    //--------------------------------------
    function finishLendingByManager( uint256 tokenId ) external onlyManager {
        require( _exists( tokenId ), "nonexistent token" );
        require( _map_lending_from[tokenId] != address(0), "not lent token" );
        require( ownerOf( tokenId ) == address(this), "not managed token" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _finishLending( tokenId );
    }

    //--------------------------------------
    // [internal] 貸し出し終了(実体)
    //--------------------------------------
    function _finishLending( uint256 tokenId ) internal {
        // 転送
        _transfer( address(this), _map_lending_from[tokenId], tokenId );    // 内部で[ERC721.Transfer]が発火する

        // イベント：貸し出し終了
        emit TokenLendingFinished( tokenId, _map_lending_from[tokenId], _map_lending_to[tokenId] );

        // 解除
        delete _map_lending_from[tokenId];
        delete _map_lending_to[tokenId];
    }

    //--------------------------------------
    // [external] プレゼント(転送)
    //--------------------------------------
    function gift( uint256 tokenId, address to ) external {
        require( _exists( tokenId ), "nonexistent token" );
        require( ownerOf( tokenId ) == msg.sender, "not owned token" );
        require( to != address(0), "invalid address" );
        require( msg.sender != to, "sender is to" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _gift( tokenId, msg.sender, to );
    }

    //--------------------------------------
    // [internal] トークンの転送（実体）
    //--------------------------------------
    function _gift( uint256 tokenId, address from, address to ) internal {
        // 転送
        _transfer( from, to, tokenId );   // 内部で[ERC721.Transfer]が発火する

        // イベント：プレゼント
        emit TokenGifted( tokenId, from, to );
    }

    //--------------------------------------
    // [external] 開放(焼却)
    //--------------------------------------
    function release( uint256 tokenId ) external {
        require( _exists( tokenId ), "nonexistent token" );
        require( ownerOf( tokenId ) == msg.sender, "not owned token" );

        //-------------------
        // ここまできたら確認完了
        //-------------------

        _release( tokenId );
    }

    //--------------------------------------
    // [internal] トークンの開放（実体）
    //--------------------------------------
    function _release( uint256 tokenId ) internal {
        // 焼却
        _burn( tokenId );   // 内部で[ERC721.Transfer]が発火する

        // イベント：開放
        emit TokenReleased( tokenId );

        // 供給量の減算
        _total_supply--;
    }

}