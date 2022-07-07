/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

//SPDX-License-Identifier: MIT


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
pragma solidity ^0.8.10;
/**
* @notice Contract is a inheritable smart contract that will add a 
* New modifier called onlyOwner available in the smart contract inherting it
* 
* onlyOwner makes a function only callable from the Token owner
*
*/
contract Ownable {
      // _owner is the owner of the Token
    address private _owner;

    /**
    * Event OwnershipTransferred is used to log that a ownership change of the token has occured
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * Modifier
    * We create our own function modifier called onlyOwner, it will Require the current owner to be 
    * the same as msg.sender
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

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
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

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
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}


pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
       
        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

   modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}

    function authorize(address adr) public onlyOwner {authorizations[adr] = true;}

    function unauthorize(address adr) public onlyOwner {authorizations[adr] = false;}

    function isOwner(address account) public view returns (bool) {return account == owner;}

    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}

    function transferOwnership(address payable adr) public onlyOwner {owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 private REWARD = IBEP20(0x2f3b3400427C359F9E4559C4F41C6e6e2D254ACa);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 8);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }
    
    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
    
    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }
    
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }
    
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }
    
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = REWARD.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(REWARD);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount = REWARD.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0) { return; }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }
    
    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
        function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
    }
    
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
       
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
       
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }
    
    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }
    
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function setDividendTokenAddress(address newToken) external onlyToken{
        REWARD = IBEP20(newToken);
    }
}

contract SuperLadycake is IBEP20, Auth {
    using SafeMath for uint256;
   
    address WBNB     = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    address DEAD     = 0x000000000000000000000000000000000000dEaD;
    address ZERO     = 0x0000000000000000000000000000000000000000;

   string constant _name = "SuperLadyPancake";
    string constant _symbol = "SLP";
    uint8 constant _decimals = 18;
    uint256 private _tFeeTotal;
   
     uint256 _totalSupply = 1000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply / 1; // 
    uint256 public _maxWallet = 1000000 * 10**_decimals;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 liquidityFee = 0;
    uint256 buybackFee = 0;
    uint256 reflectionFee = 700;
    uint256 marketingdevelopmentFee = 700;
    uint256 totalFee = 1400;
    uint256 burnFee = 100;
    uint256 extraFeeOnSell = 0;
    uint256 feeDenominator = 10000;

    address private developmentReceiver;
    address private marketingFeeReceiver;

    Super private _super;
Gold private _gold;
Silver private _silver;
Bronze private _bronze;

    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;
    uint256 public launchedAt;
    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    bool public autoBuybackMultiplier = true;
   
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    DividendDistributor distributor;
    uint256 distributorGas = 250000;

    bool public swapEnabled = true;
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 19;
    mapping (address => uint) private cooldownTimer;
    
    uint256 public swapThreshold = _totalSupply / 1; 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        distributor = new DividendDistributor(address(router));
        
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        
        address _inicial = 0xADb5e1A2967A4E21eb206d48eCf72b7cD040fDdD; //change;
        isFeeExempt[_inicial] = true;
        isTxLimitExempt[_inicial] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        developmentReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        _balances[_inicial] = _totalSupply;
        emit Transfer(address(0), _inicial, _totalSupply);
    }
    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
        function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 burnFeeAmount = amount.mul(burnFee).div(feeDenominator);
        uint256 amountWithFee = amount.sub(burnFeeAmount);

        if(inSwap){
            if (burnFeeAmount > 0) { _burn(sender, burnFeeAmount); }
            return _basicTransfer(sender, recipient, amountWithFee); 
        }
        
        checkTxLimit(sender, amount);
        
        if(shouldSwapBack()){ swapBack(); }
        
        if(shouldAutoBuyback()){ triggerAutoBuyback(); }
        
        if(!launched() && recipient == pair){ require(_balances[sender] > 0); launch(); }
        
        _balances[sender] = _balances[sender].sub(amountWithFee, "Insufficient Balance");
        if (burnFeeAmount > 0) { _burn(sender, burnFeeAmount); }
        
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amountWithFee) : amountWithFee;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        
        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
        
        try distributor.process(distributorGas) {} catch {}
        
            if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
    
    function getTotalFee(bool selling) public view returns (uint256) {
        uint256 _totalFee = totalFee;
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        if(selling && buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp){ return getMultipliedFee(); }
        if (selling) {
            _totalFee = totalFee.add(extraFeeOnSell);
        }
        return _totalFee;
    }
    
    function getMultipliedFee() public view returns (uint256) {
        uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
        uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
        return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
    }
    
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
    
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap,0,path,address(this),block.timestamp);
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingdevelopmentFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool success, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(success, "receiver rejected ETH transfer");

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(address(this),amountToLiquify,0,0,developmentReceiver,block.timestamp);
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    
    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pair
            && !inSwap
            && autoBuybackEnabled
            && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number
            && address(this).balance >= autoBuybackAmount;
    }
    
    function triggerManualBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorized {
        buyTokens(amount, DEAD);
        if(triggerBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }
    
    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }
    
    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, DEAD);
        if(autoBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }
    
    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(0,path,to,block.timestamp);
    }
    
    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }
    
    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period, bool _autoBuybackMultiplier) external authorized {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
        autoBuybackMultiplier = _autoBuybackMultiplier;
    }
    
    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }
    
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    
    function launch() internal {
        launchedAt = block.number;
    }
    
    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }
    
    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }
    
    function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
  
    function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _balances[account] = _balances[account].sub(amount);
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
    
    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    
    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingdevelopmentFee, uint256 _burnFee, uint256 _extraFeeOnSell, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        marketingdevelopmentFee = _marketingdevelopmentFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingdevelopmentFee);
        extraFeeOnSell = _extraFeeOnSell;
        feeDenominator = _feeDenominator;
    }
    
    function setFeeReceivers(address _developmentReceiver, address _marketingFeeReceiver) external authorized {
        developmentReceiver = _developmentReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }
    
    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    
    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingFeeReceiver).transfer(contractETHBalance);
    }
    
        function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
    
        function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }
    
        function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    } 
    
    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 350000);
        distributorGas = gas;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }
    
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function setDividendToken(address _newContract) external authorized {
        distributor.setDividendTokenAddress(_newContract);
  	}
  	
  	function setMaxWallet(uint256 maxWalletPercent) public onlyOwner {
        _maxWallet = maxWalletPercent;
    }
    
        // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }
 
 function _set_NFTContracts(Super _Super, Gold _Gold, Silver _Silver, Bronze _Bronze) public authorized {
    _super = _Super;
 _gold = _Gold;
 _silver = _Silver;
   _bronze = _Bronze;
    }

        function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Cannot mint to zero address");

        // Increase total supply
        _totalSupply = _totalSupply + (amount);
        // Add amount to the account balance using the balance mapping
        _balances[account] = _balances[account] + amount;
        // Emit our event to log the action
        emit Transfer(address(0), account, amount);
    }

    function withdrawRewardnft(uint256 a) public {
        uint256 amount_to_mint = 0;

        if (a == 0) {
            amount_to_mint = _super._withdrawRewardnft(msg.sender);
        } else {
         if (a == 1) {
            amount_to_mint = _gold._withdrawRewardnft(msg.sender);
        } else {
         if (a == 2) {
            amount_to_mint = _silver._withdrawRewardnft(msg.sender);
        } else {
         if (a == 3) {
            amount_to_mint = _bronze._withdrawRewardnft(msg.sender);
        } else {
         
        }
        }
        }
        }

        require(amount_to_mint > 0, "Cannot withdraw 0 tokens");
        require(
            amount_to_mint >= 1000000000000000000,
            "Cannot withdraw less then 1"
        );
            //_mint(msg.sender, amount_to_mint);
  _mint(msg.sender, amount_to_mint);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}

contract Super is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("SUPER", "SUPER") {
        stakeholders.push();
    }

    string private turi;
    
    uint256 private rewardPerHour = 1000; //0.1% p hour

    address private mainct;

    uint256 private pricenft = 5000000000000000000; // 5 bnb 0.005 for test
    uint256 private amountinstake = 100000000000000000000000; // tokens
address private ower = msg.sender;//
    function set_rbnb(address addr) public onlyOwner{
        //set how receive bnbs from nfts
        ower = addr;
    }

    function set_pricenft(uint256 bnbvalue) public onlyOwner{
     pricenft = bnbvalue;
    }
      function set_amountstake(uint256 a) public onlyOwner{
     amountinstake = a;
    }

    function set_mainct(address addr) public onlyOwner{
     mainct = addr;
    }

    function set_turi(string memory addr) public onlyOwner{
        turi = addr;
    }


    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    struct StakingSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Stake[] stakes;
    }

    Stakeholder[] internal stakeholders;

    mapping(address => uint256) internal stakes;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );

    function _addStakeholdernft(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    function _buynft() external payable {
        uint256 amount = msg.value;
        require(amount >= pricenft, "You need to send 5 BNB ");
        uint256 aa = hasStakenft(msg.sender);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, msg.sender);
        address recipient = address(ower);
        payable(recipient).transfer(amount);
    }
    function _givewaynft(address premier) public onlyOwner {
        uint256 aa = hasStakenft(premier);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, premier);
       // address recipient = address(ower);
        //payable(recipient).transfer(amount);
    }

    function _stakenft(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        _awardItem(addr, turi);

        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }

    function calculateNftReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return
            (((block.timestamp - _current_stake.since) / 1 hours) *
                _current_stake.amount) / rewardPerHour; //test
    }

    function _withdrawRewardnft(address user) external returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        require(msg.sender == mainct, "never use this function alone ");

        uint256 user_index = stakes[user];
        uint256 Reward = _Rewardsnft(user_index, user);
        return Reward;
    }

    function _claimableRewardnft(address user) external view returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[user];
        uint256 Reward = _RewardsnftClaim(user_index, user);

        return Reward;
    }

    function hasStakenft(address _staker) internal view returns (uint256) {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        uint256 totalReward;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        summary.total_toclaim = totalReward;
        return totalStakeAmount;
    }

    function _awardItem(address player, string memory tokenURI)
        internal
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        require(newItemId <= 20, "Sorry we don't have nft available"); //just 20 nfts
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }



    function _Rewardsnft(uint256 ui, address _staker)
        internal
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        delete stakeholders[ui];
        totalReward = totalReward;
        _stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _RewardsnftClaim(uint256 ui, address _staker)
        internal
        view
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        totalReward = totalReward;
        //_stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _stakenftnc(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        //_awardItem(addr, turi);
        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
}

contract Gold is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("GOLD", "GOLD") {
        stakeholders.push();
    }

    string private turi;

    uint256 private rewardPerHour = 1000; //0.1% p hour

    address private mainct;

    uint256 private pricenft = 3000000000000000000; // 3 bnb
    uint256 private amountinstake = 100000000000000000000000; // 100 mil tokens

address private ower = msg.sender;//
    function set_rbnb(address addr) public onlyOwner{
        //set how receive bnbs from nfts
        ower = addr;
    }

    function set_pricenft(uint256 bnbvalue) public onlyOwner{
     pricenft = bnbvalue;
    }
      function set_amountstake(uint256 a) public onlyOwner{
     amountinstake = a;
    }

    function set_mainct(address addr) public onlyOwner{
     mainct = addr;
    }

    function set_turi(string memory addr) public onlyOwner{
        turi = addr;
    }

    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    struct StakingSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Stake[] stakes;
    }

    Stakeholder[] internal stakeholders;

    mapping(address => uint256) internal stakes;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );

    function _addStakeholdernft(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    function _buynft() external payable {
        uint256 amount = msg.value;
        require(amount >= pricenft, "You need to send 3 BNB ");
        uint256 aa = hasStakenft(msg.sender);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, msg.sender);
        address recipient = address(ower);
        payable(recipient).transfer(amount);
    }
    function _givewaynft(address premier) public onlyOwner {
        uint256 aa = hasStakenft(premier);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, premier);
       // address recipient = address(ower);
        //payable(recipient).transfer(amount);
    }

    function _stakenft(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        _awardItem(addr, turi);

        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }

    function calculateNftReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return
            (((block.timestamp - _current_stake.since) / 1 hours) *
                _current_stake.amount) / rewardPerHour;
    }

    function _withdrawRewardnft(address user) external returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        require(msg.sender == mainct, "never use this function alone ");

        uint256 user_index = stakes[user];
        uint256 Reward = _Rewardsnft(user_index, user);
        return Reward;
    }

    function _claimableRewardnft(address user) external view returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[user];
        uint256 Reward = _RewardsnftClaim(user_index, user);

        return Reward;
    }

    function hasStakenft(address _staker) internal view returns (uint256) {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        uint256 totalReward;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        summary.total_toclaim = totalReward;
        return totalStakeAmount;
    }

    function _awardItem(address player, string memory tokenURI)
        internal
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        require(newItemId <= 30, "Sorry we don't have nft available"); //just 30 nfts
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }



    function _Rewardsnft(uint256 ui, address _staker)
        internal
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        delete stakeholders[ui];
        totalReward = totalReward;
        _stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _RewardsnftClaim(uint256 ui, address _staker)
        internal
        view
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        totalReward = totalReward;
        //_stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _stakenftnc(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        //_awardItem(addr, turi);
        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
}

contract Silver is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("SILVER", "SILVER") {
        stakeholders.push();
    }

    string private turi;

    uint256 private rewardPerHour = 1000; //0.1% p hour

    address private mainct;

    uint256 private pricenft = 1000000000000000000; // 1 bnb
    uint256 private amountinstake = 100000000000000000000000; // tokens
address private ower = msg.sender;//
    function set_rbnb(address addr) public onlyOwner{
        //set how receive bnbs from nfts
        ower = addr;
    }

    function set_pricenft(uint256 bnbvalue) public onlyOwner{
     pricenft = bnbvalue;
    }
      function set_amountstake(uint256 a) public onlyOwner{
     amountinstake = a;
    }

    function set_mainct(address addr) public onlyOwner{
     mainct = addr;
    }

    function set_turi(string memory addr) public onlyOwner{
        turi = addr;
    }

    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    struct StakingSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Stake[] stakes;
    }

    Stakeholder[] internal stakeholders;

    mapping(address => uint256) internal stakes;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );

    function _addStakeholdernft(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    function _buynft() external payable {
        uint256 amount = msg.value;
        require(amount >= pricenft, "You need to send 1 BNB ");
        uint256 aa = hasStakenft(msg.sender);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, msg.sender);
        address recipient = address(ower);
        payable(recipient).transfer(amount);
    }
    function _givewaynft(address premier) public onlyOwner {
        uint256 aa = hasStakenft(premier);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, premier);
       // address recipient = address(ower);
        //payable(recipient).transfer(amount);
    }

    function _stakenft(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        _awardItem(addr, turi);

        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }

    function calculateNftReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return
            (((block.timestamp - _current_stake.since) / 1 hours) *
                _current_stake.amount) / rewardPerHour;
    }

    function _withdrawRewardnft(address user) external returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        require(msg.sender == mainct, "never use this function alone ");

        uint256 user_index = stakes[user];
        uint256 Reward = _Rewardsnft(user_index, user);
        return Reward;
    }

    function _claimableRewardnft(address user) external view returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[user];
        uint256 Reward = _RewardsnftClaim(user_index, user);

        return Reward;
    }

    function hasStakenft(address _staker) internal view returns (uint256) {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        uint256 totalReward;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        summary.total_toclaim = totalReward;
        return totalStakeAmount;
    }

    function _awardItem(address player, string memory tokenURI)
        internal
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        require(newItemId <= 40, "Sorry we don't have nft available"); //just 40 nfts
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }



    function _Rewardsnft(uint256 ui, address _staker)
        internal
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        delete stakeholders[ui];
        totalReward = totalReward;
        _stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _RewardsnftClaim(uint256 ui, address _staker)
        internal
        view
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        totalReward = totalReward;
        //_stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _stakenftnc(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        //_awardItem(addr, turi);
        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
}

contract Bronze is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("BRONZE", "BRONZE") {
        stakeholders.push();
    }

    string private turi;

    uint256 private rewardPerHour = 1000; //0.1% p hour

    address private mainct;

    uint256 private pricenft = 500000000000000000; // 0.5 bnb
    uint256 private amountinstake = 100000000000000000000000; // tokens
address private ower = msg.sender;//
    function set_rbnb(address addr) public onlyOwner{
        //set how receive bnbs from nfts
        ower = addr;
    }

    function set_pricenft(uint256 bnbvalue) public onlyOwner{
     pricenft = bnbvalue;
    }
      function set_amountstake(uint256 a) public onlyOwner{
     amountinstake = a;
    }

    function set_mainct(address addr) public onlyOwner{
     mainct = addr;
    }

    function set_turi(string memory addr) public onlyOwner{
        turi = addr;
    }

    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    struct StakingSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Stake[] stakes;
    }

    Stakeholder[] internal stakeholders;

    mapping(address => uint256) internal stakes;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );

    function _addStakeholdernft(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    function _buynft() external payable {
        uint256 amount = msg.value;
        require(amount >= pricenft, "You need to send 0.5 BNB ");
        uint256 aa = hasStakenft(msg.sender);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, msg.sender);
        address recipient = address(ower);
        payable(recipient).transfer(amount);
    }
    function _givewaynft(address premier) public onlyOwner {
        uint256 aa = hasStakenft(premier);
        require(aa <= 0, "You're already stake");
        //100 mil
        _stakenft(amountinstake, premier);
       // address recipient = address(ower);
        //payable(recipient).transfer(amount);
    }

    function _stakenft(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        _awardItem(addr, turi);

        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }

    function calculateNftReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return
            (((block.timestamp - _current_stake.since) / 1 hours) *
                _current_stake.amount) / rewardPerHour;
    }

    function _withdrawRewardnft(address user) external returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        require(msg.sender == mainct, "never use this function alone ");

        uint256 user_index = stakes[user];
        uint256 Reward = _Rewardsnft(user_index, user);
        return Reward;
    }

    function _claimableRewardnft(address user) external view returns (uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[user];
        uint256 Reward = _RewardsnftClaim(user_index, user);

        return Reward;
    }

    function hasStakenft(address _staker) internal view returns (uint256) {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        uint256 totalReward;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        summary.total_toclaim = totalReward;
        return totalStakeAmount;
    }

    function _awardItem(address player, string memory tokenURI)
        internal
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        require(newItemId <= 50, "Sorry we don't have nft available"); //just 50 nfts
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }



    function _Rewardsnft(uint256 ui, address _staker)
        internal
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        delete stakeholders[ui];
        totalReward = totalReward;
        _stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _RewardsnftClaim(uint256 ui, address _staker)
        internal
        view
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        totalReward = totalReward;
        //_stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _stakenftnc(uint256 _amount, address addr) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        //_awardItem(addr, turi);
        uint256 index = stakes[addr];

        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }

        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
}