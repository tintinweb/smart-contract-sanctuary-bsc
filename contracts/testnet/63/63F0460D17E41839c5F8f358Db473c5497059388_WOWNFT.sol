/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity =0.8.11;


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)
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

// 
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

// 
contract WCoin is ERC20("WCoin", "WCOIN"), Ownable {

    uint256 private tokenPrice;
    uint256 private constant initialSupply = 100000000e18;

    uint256 public privateSellSupply = 7000000e18;
    address private immutable privateSellAddress;
    mapping(uint256 => uint256[2]) private privateSupplyMapping;

    uint256 public IDOSupply = 6000000e18;
    address private immutable IDOAddress;
    mapping(uint256 => uint256[]) private IDOSupplyMapping;

    uint256 public pancakeSwapSupply = 1000000e18;

    uint256 public p2eSupply = 55000000e18;
    address private immutable p2eAddress;

    uint256 public marketingSupply = 5000000e18;
    address private immutable marketingAddress;
    mapping(uint256 => uint256[]) private marketingSupplyMapping;

    uint256 public constant teamSupply = 10000000e18;
    uint256 private currentTeamSupply = teamSupply;
    address private immutable teamAddress;

    uint256 public advisorsSupply = 3000000e18;
    address private immutable advisorsAddress;
    mapping(uint256 => uint256[]) private advisorsSupplyMapping;

    uint256 public stakingSupply = 5000000e18;
    address private immutable stakingAddress;
    mapping(uint256 => uint256[]) private stakingSupplyMapping;

    uint256 public treasurySupply = 8000000e18;
    address private immutable treasuryAddress;
    mapping(uint256 => uint256[]) private treasurySupplyMapping;

    uint256 public creationTime = block.timestamp;

    /// @notice Boolean to permanently disable minting of new tokens
    bool public mintingPermanentlyDisabled = false;

    // Event that logs every buy operation
    event BuyTokens(address _buyer, uint256 _price, uint256 _amountTokens);
    event SoldTokens(address _seller, uint256 _amountTokens);

    event WithDrawn(uint256 _amount, address _recipient);

    constructor(
        uint256 _price,
        address _privateSellAddress,
        address _IDOAddress,
        address _p2eAddress,
        address _marketingAddress,
        address _teamAddress,
        address _advisorsAddress,
        address _stakingAddress,
        address _treasuryAddress
    ) {
        tokenPrice = _price;
        teamAddress = _teamAddress;

        privateSellAddress = _privateSellAddress;
        // Private Sell: 5 months 20% each (starting from moment of deploy 0).
        privateSupplyMapping[0]= [0 days, privateSellSupply - privateSellSupply / 5];
        privateSupplyMapping[1]= [30 days, privateSupplyMapping[0][1] - privateSellSupply / 5];
        privateSupplyMapping[2]= [60 days, privateSupplyMapping[1][1] - privateSellSupply / 5];
        privateSupplyMapping[3]= [90 days, privateSupplyMapping[2][1] - privateSellSupply / 5];
        privateSupplyMapping[4] = [120 days, privateSupplyMapping[3][1] - privateSellSupply / 5];

        IDOAddress = _IDOAddress;
        // IDO: 5 months 20% each (starting from moment of deploy 0).
        IDOSupplyMapping[0]= [0 days, IDOSupply - IDOSupply / 5];
        IDOSupplyMapping[1]= [30 days, IDOSupplyMapping[0][1] - IDOSupply / 5];
        IDOSupplyMapping[2]= [60 days, IDOSupplyMapping[1][1] - IDOSupply / 5];
        IDOSupplyMapping[3]= [90 days, IDOSupplyMapping[2][1] - IDOSupply / 5];
        IDOSupplyMapping[4] = [120 days, IDOSupplyMapping[3][1] - IDOSupply / 5];

        marketingAddress = _marketingAddress;
        // Marketing: 11 % per month for the first 8 months. Last month 12% (TBC)
        for (uint i = 0; i < 8; i++) {
            if (i == 0) {
                marketingSupplyMapping[i] = [(i * 30 days) + 30 days, marketingSupply - ((marketingSupply / 10) + (marketingSupply / 100))];
            } else {
                marketingSupplyMapping[i] = [(i * 30 days) + 30 days, marketingSupplyMapping[i-1][1] - ((marketingSupply / 10) + (marketingSupply / 100))];
            }
            
        }
        // 12% last month
        marketingSupplyMapping[8] = [(8 * 30 days) + 30 days, marketingSupplyMapping[7][1] - ((marketingSupply / 10) + (marketingSupply / 100) * 2)];

        treasuryAddress = _treasuryAddress;
        // Treasury: 1 Year Locked. Then 10 % per month (10 months)
        for (uint i = 0; i < 10; i++) {
            if (i==0) { 
                treasurySupplyMapping[i] = [(i * 30 days), treasurySupply - (treasurySupply / 10)];
            } else {
                treasurySupplyMapping[i] = [(i * 30 days), treasurySupplyMapping[i-1][1] - (treasurySupply / 10)];
            }
        }

        advisorsAddress = _advisorsAddress;
        // Advisors: 1 Year locked. Then 30 % per month. Then last month 10%.
        for (uint i = 0; i < 3; i++) {
            if (i==0) {
                advisorsSupplyMapping[i] = [(i * 30 days), advisorsSupply - ((advisorsSupply / 10) * 3)];
            } else {
                advisorsSupplyMapping[i] = [(i * 30 days), advisorsSupplyMapping[i-1][1] - ((advisorsSupply / 10) * 3)];
            }
        }
        advisorsSupplyMapping[3] = [90 days, advisorsSupplyMapping[2][1] - (advisorsSupply / 10)];

        stakingAddress = _stakingAddress;
        // 3 Months blocked. Then 33%, 33%, 34%
        stakingSupplyMapping[0] = [(0 * 30 days) + 30 days, stakingSupply - (stakingSupply * 33 / 100)];
        stakingSupplyMapping[1] = [(1 * 30 days) + 30 days, stakingSupplyMapping[0][1] - (stakingSupply * 33 / 100)];
        stakingSupplyMapping[2] = [(2 * 30 days) + 30 days, stakingSupplyMapping[1][1] - (stakingSupply * 34 / 100)];
        
        p2eAddress = _p2eAddress;
    }

    /**
     * @notice Mint new tokens to owner
     *
     * Requirements:
     *
     * - Minting must not be permanently disabled
     */
    function mint() public onlyOwner {
        require(!mintingPermanentlyDisabled, "Minting permanently disabled!");
        _mint(p2eAddress, p2eSupply); // Minting to p2eAddress - SHOULD NOT BE OWNED BY CREATORS
        _mint(msg.sender, pancakeSwapSupply); //Mint only pancakeswap to owner for staking
        _mint(address(this), initialSupply - p2eSupply - pancakeSwapSupply);
        disableMintingPermanently(); // Disabling minting forever
    }
    
    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 contractBalance = balanceOf(address(this));
        require(amountTobuy <= contractBalance, "Not enough tokens in the reserve.");
        require(tokenPrice > 0, "You need to send some BNB");

        transfer(msg.sender, amountTobuy);
        emit BuyTokens(msg.sender, tokenPrice, amountTobuy);
    }

    function sell(uint256 _amount) public {
        require(_amount > 0, "More than 0 tokens must be sold");

        uint256 allowance = allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check token allowance");

        transferFrom(msg.sender, address(this), _amount);

        transfer(msg.sender, _amount);
        emit SoldTokens(msg.sender, _amount);
    }

    function getCurrentBalance() external view returns(uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }

    /**
     * @notice Disable minting permanently
     */
    function disableMintingPermanently() private onlyOwner {
        mintingPermanentlyDisabled = true;
    }

    function setTokenPrice(uint256 _price) external onlyOwner() {
        tokenPrice = _price;
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function checkCanRelease(uint256 _allowed, uint256 _supply, uint256 _amount) private pure returns (bool) {
        return _allowed <= (_supply - _amount);
    }

    function releasePrivateSellFunds(uint256 _amount) public onlyOwner {
        require(privateSellSupply > 0, "Not enough private sell supply");
        require(privateSellSupply - _amount > 0, "Amount can not exceed private sell supply");

        uint256 releaseAllowed;
        bool isAllowed = false;
    
        for(uint i = 0; i < 5; i++) {
            if (block.timestamp >= (creationTime + privateSupplyMapping[i][0])) {
                releaseAllowed = privateSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, privateSellSupply, _amount), "Amount not allowed!");
        transfer(privateSellAddress, _amount);
        privateSellSupply = privateSellSupply - _amount;
        emit WithDrawn(_amount, privateSellAddress);
    }

    function releaseIDOFunds(uint256 _amount) public onlyOwner {
        require(IDOSupply > 0, "Not enough IDO supply");
        require(IDOSupply - _amount > 0, "Amount can not exceed IDO supply");

        uint256 releaseAllowed;
        bool isAllowed = false;
    
        for(uint i = 0; i < 5; i++) {
            if (block.timestamp >= (creationTime + IDOSupplyMapping[i][0])) {
                releaseAllowed = IDOSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, IDOSupply, _amount), "Amount not allowed!");
        transfer(IDOAddress, _amount);
        IDOSupply = IDOSupply - _amount;
        emit WithDrawn(_amount, IDOAddress);
    }

    function releaseMarketingFunds(uint256 _amount) public onlyOwner {
        require(marketingSupply > 0, "Not enough Marketing supply");
        require(marketingSupply - _amount > 0, "Amount can not exceed Marketing supply");

        uint256 releaseAllowed;
        bool isAllowed = false;
    
        for(uint i = 0; i < 9; i++) {
            if (block.timestamp >= (creationTime + marketingSupplyMapping[i][0])) {
                releaseAllowed = marketingSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, marketingSupply, _amount), "Amount not allowed!");
        transfer(marketingAddress, _amount);
        marketingSupply = marketingSupply - _amount;
        emit WithDrawn(_amount, marketingAddress);
    }

    function releaseAdvisorsFunds(uint256 _amount) public onlyOwner {
        require(advisorsSupply > 0, "Not enough Advisors supply");
        require(advisorsSupply - _amount > 0, "Amount can not exceed Advisors supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            for(uint i = 0; i < 4; i++) {
                if (block.timestamp >= (restrictedTime + advisorsSupplyMapping[i][0])) {
                    releaseAllowed = advisorsSupplyMapping[i][1];
                    isAllowed = true;
                }
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, advisorsSupply, _amount), "Amount not allowed!");
        transfer(advisorsAddress, _amount);
        advisorsSupply = advisorsSupply - _amount;
        emit WithDrawn(_amount, advisorsAddress);
    }

    function releaseTreasuryFunds(uint256 _amount) public onlyOwner {
        require(treasurySupply > 0, "Not enough Treasury supply");
        require(treasurySupply - _amount > 0, "Amount can not exceed Treasury supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            for(uint i = 0; i < 10; i++) {
                if (block.timestamp >= (restrictedTime + treasurySupplyMapping[i][0])) {
                    releaseAllowed = treasurySupplyMapping[i][1];
                    isAllowed = true;
                }
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, treasurySupply, _amount), "Amount not allowed!");
        transfer(treasuryAddress, _amount);
        treasurySupply = treasurySupply - _amount;
        emit WithDrawn(_amount, treasuryAddress);
    }


    function releaseStakingFunds(uint256 _amount) public onlyOwner {
        require(stakingSupply > 0, "Not enough Staking supply");
        require(stakingSupply - _amount > 0, "Amount can not exceed Staking supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 90 days;
    
        for(uint i = 0; i < 3; i++) {
            if (block.timestamp >= (restrictedTime + stakingSupplyMapping[i][0])) {
                releaseAllowed = stakingSupplyMapping[i][1];
                isAllowed = true;
            }
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, stakingSupply, _amount), "Amount not allowed!");
        transfer(stakingAddress, _amount);
        stakingSupply = stakingSupply - _amount;
        emit WithDrawn(_amount, stakingAddress);
    }

    function getTeamFundsAllowed() private view returns (uint256) {
        uint256 releaseAllowed = 0;
        uint256 restrictedTime = creationTime + 365 days;

        for (uint i = 0; i < 365; i++) {
            if (block.timestamp >= (restrictedTime + (i * 1 days))) {
                releaseAllowed = releaseAllowed + teamSupply / 365;
            }
        }

        return releaseAllowed;
    }

    function releaseTeamFunds(uint256 _amount) public onlyOwner {
        require(currentTeamSupply > 0, "Not enough Team supply");
        require(currentTeamSupply - _amount > 0, "Amount can not exceed Team supply");

        bool isAllowed = false;
        uint256 releaseAllowed;
        uint256 restrictedTime = creationTime + 365 days;
    
        if (block.timestamp >= restrictedTime) {
            isAllowed = true;
            releaseAllowed = getTeamFundsAllowed();
        }

        require(isAllowed, "Timelock active, not yet allowed!");
        require(checkCanRelease(releaseAllowed, currentTeamSupply, _amount), "Amount not allowed!");
        transfer(teamAddress, _amount);
        currentTeamSupply = currentTeamSupply - _amount;
        emit WithDrawn(_amount, teamAddress);
    }
}

//  
contract WOWNFT is ERC721, Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;

    WCoin WCoinToken;
    IERC20 private immutable BUSDAddress;
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); // Chainlink BNB/USD Price Feed on BSC

    uint256 public tokenPrice;

    struct TokenMetadata {
      uint256 tokenID;
      uint256 price;
      uint256 timestamp;
    }
    mapping(address => TokenMetadata[]) private tokensOwned;

    bool public feeEnabled = true;
    bool public transferable = true;
	bool public whitelistEnabled = false;

    mapping(address => bool) public authorized;

    bool public privateSaleEnabled = true;
    mapping (address => bool) public whitelistedWallets;

    constructor(
      uint256 _price,
      address _WCoinTokenAddress,
      address _BUSDtokenAddress) ERC721("WOWNFT", "WOW") {
        tokenPrice = _price;
        _tokenIdCounter.increment();             // Start counter = 1
        BUSDAddress = IERC20(_BUSDtokenAddress); // BUSD Contract Address
        WCoinToken = WCoin(_WCoinTokenAddress);  // WCoin Contract Address
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner() == msg.sender, "Unauthorized caller");
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner external {
        require(_toAdd != address(0));
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) onlyOwner external {
        require(_toRemove != address(0));
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }

    function pause() external onlyAuthorized {
        _pause();
    }

    function unpause() external onlyAuthorized {
        _unpause();
    }
	
	function enableWhitelist() external onlyAuthorized {
        whitelistEnabled = true;
    }

    function disableWhitelist() external onlyAuthorized {
        whitelistEnabled = false;
    }

    function enableTransfers() external onlyAuthorized {
        transferable = true;
    }

    function disableTransfers() external onlyAuthorized {
        transferable = false;
    }

    function enablePrivateSale() external onlyAuthorized {
        privateSaleEnabled = true;
    }

    function disablePrivateSale() external onlyAuthorized {
        privateSaleEnabled = false;
    }

    function enableFee() external onlyAuthorized {
        feeEnabled = true;
    }

    function disableFee() external onlyAuthorized {
        feeEnabled = false;
    }

    function setWallet(address _wallet) external onlyAuthorized {
        whitelistedWallets[_wallet] = true;
    }

    function whitelistContains(address _wallet) private view returns (bool) {
        return whitelistedWallets[_wallet];
    }
    
    function setPrice(uint256 _price) external onlyAuthorized {
        tokenPrice = _price;
    }

    /**
     * @notice Gets BNB price from Chainlink Oracle
     */
    function getLatestBNBPrice() private view returns (uint256) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    /**
     * @notice 0.95 USD Fee in BNB
     */
    function getBNBFee() private view returns (uint256) {
        return (uint256(19) / uint256(20)) / getLatestBNBPrice(); // $0.95 fee
    }

    function getBUSDBalance() external view onlyOwner returns(uint256) {
        return BUSDAddress.balanceOf(address(this));
    }

    function withdrawBUSD() external onlyOwner {
        uint256 balance = BUSDAddress.balanceOf(address(this));
        BUSDAddress.transfer(msg.sender, balance);
    }

    /**
     * @notice WCoin balance of the contract
     */
    function getWCoinBalance() external view returns(uint256) {
        return WCoinToken.balanceOf(address(this));
    }

    function withdrawWCoin() external onlyOwner {
        uint256 balance = WCoinToken.balanceOf(address(this));
        WCoinToken.transfer(msg.sender, balance);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://www.nt.com.pe/waometa/";
    }
    
    /**
     * @notice Mints NFT to caller
     */
    function mintToken(uint256 _price, uint256 _tokenCount) external payable whenNotPaused returns(uint256[] memory) {
        require(_tokenCount >= 1, "TokenCount must be >1");
        if (privateSaleEnabled) {                                                                               // If the privateSale is enabled
            if (whitelistEnabled) {
				        require(whitelistContains(msg.sender), "Whitelisted only");
			      }
            require(_price == (_tokenCount * tokenPrice), "Not enough BUSD");
            BUSDAddress.transferFrom(msg.sender, address(this), _tokenCount * tokenPrice);                     // On privateSale user pays with BUSD
        } else {                                                                                                // When OUT of privateSale
            if (!authorized[msg.sender] && msg.sender != owner()) {                                             // If the user who wants to mint is NOT an admin
                require(_price <= (500e18 / WCoinToken.getTokenPrice()), "Price over transaction limit");      // Check over $500 Transaction limit
                if (feeEnabled) {
                    uint256 BNBFee = getBNBFee() * _tokenCount; 
                    require(msg.value == BNBFee, "Insufficient BNB funds");                                     // If feeEnabled there's a 0.95 USD BNB additional charge to the tokenPrice
                    payable(address(this)).transfer(_tokenCount * msg.value);
                }

                require(balanceOf(msg.sender) <= (_tokenIdCounter.current() / 500), "Holding limit achieved");  // 0.02% of total supply
                require(_price == (_tokenCount * tokenPrice), "Not enough WCoin");

                WCoinToken.transferFrom(msg.sender, address(this), _tokenCount * tokenPrice);                  // Pays with WCoinToken
            } 
        }

        uint256 _tokenID;
        uint256[] memory _tokenIDs;
        for (uint i = 0; i < _tokenCount; i++) {
          _tokenID = _tokenIdCounter.current();
          _tokenIDs[i] = _tokenID;
          _safeMint(msg.sender, _tokenID);
          tokensOwned[msg.sender].push(TokenMetadata(_tokenID, tokenPrice, block.timestamp));
          _tokenIdCounter.increment();         
        }                                                                   // Increment after token has been minted
        return _tokenIDs;
    }

    function sell(uint256 _tokenID, uint256 _price, address _buyer) external whenNotPaused {
        require(_price <= 10000e18, "Price over transaction limit");
        TokenMetadata memory token = _getTokenFromUser(msg.sender, _tokenID);
        require(token.timestamp <= token.timestamp + 60 seconds, "Wait +60 seconds to sell");

        WCoinToken.transferFrom(_buyer, msg.sender, _price);
        safeTransferFrom(msg.sender, _buyer, _tokenID);
        tokensOwned[_buyer].push(token);
        _removeToken(_tokenID, msg.sender);
    }

    function _validateUser(address _userAddress, uint256 _tokenID) private view returns (bool) {
        for (uint i = 0; i < tokensOwned[_userAddress].length; i++) {
            if (tokensOwned[_userAddress][i].tokenID == _tokenID) {
                return true;
            }
        }
        return false;
    }

    function _getTokenFromUser(address _userAddress, uint256 _tokenID) private view returns (TokenMetadata memory) {
        require(_validateUser(_userAddress, _tokenID), "Not the token owner");
        for (uint i = 0; i < tokensOwned[_userAddress].length; i++) {
            if (tokensOwned[_userAddress][i].tokenID == _tokenID) {
                return tokensOwned[_userAddress][i];
            }
        }
    }

    function _removeToken(uint256 _tokenID, address _userAddress) private {
        for (uint i = 0; i < tokensOwned[_userAddress].length; i++) {
            if (tokensOwned[_userAddress][i].tokenID == _tokenID) {
                delete tokensOwned[_userAddress][i];
            }
        }
    }

    function burnToken(uint256 _tokenID) external {
        require(_validateUser(msg.sender, _tokenID), "Not the token owner");
        _burn(_tokenID);
        _removeToken(_tokenID, msg.sender);
    }

    /**
     * @notice Transfer Mints NFT only if contract not paused, transfers are enabled and holding limit
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenIds)
        internal
        whenNotPaused
        override
    {
        // If transferable or either sender is the owner
        require(transferable, "Transfers paused");
        super._beforeTokenTransfer(from, to, tokenIds);
    }
}