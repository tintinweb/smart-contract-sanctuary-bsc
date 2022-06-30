/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-28
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// File: @openzeppelin/contracts/utils/Context.sol


pragma solidity ^0.8.0;

/*
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

// File: @openzeppelin/contracts/utils/Strings.sol


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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/lib/Pausable.sol


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
 contract Pausable is Ownable {
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
    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/lib/ERC721Base.sol

pragma solidity ^0.8.0;










/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Base is Context, ERC165, IERC721, IERC721Metadata , Pausable{
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping owner address to token count
    mapping(address => uint256) internal _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) internal _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

     // Base URI
    string private baseURI_;

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
    function _baseURI() internal view virtual  returns (string memory) {
        return baseURI_;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
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
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
        address owner = ownerOf(tokenId);
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
        if(tokenId != 0){
            require(to != address(0), "ERC721: mint to the zero address");
        }
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
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
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
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
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
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
                return retval == IERC721Receiver(to).onERC721Received.selector;
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
     * @dev function to set the contract URI
     * @param _baseTokenURI string URI prefix to assign
     */
    function setBaseURI(string calldata _baseTokenURI) external onlyOwner {
        _setBaseURI(_baseTokenURI);
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */
    function _setBaseURI(string memory _baseUri) internal virtual {
        baseURI_ = _baseUri;
    }

    /**
     * @dev Returns the base URI set via {_setBaseURI}. This will be
     * automatically added as a prefix in {tokenURI} to each token's URI, or
     * to the token ID if no specific URI is set for that token ID.
     */
    function baseUri() public view returns (string memory) {
        return baseURI_;
    }    


}

// File: contracts/DhorseSaleClockAuction.sol

pragma solidity ^0.8.0;




/// @title Interface for ERC-721: Non-Fungible Tokens
interface InterfaceERC721 {
    // Required methods
    function totalSupply() external view returns (uint256 total);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

 
}


/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }

    // Reference to contract tracking NFT ownership
    InterfaceERC721 public nonFungibleContract;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(_owner, address(this), _tokenId);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _transfer(address _receiver, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(address(this),_receiver, _tokenId);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _addAuction(uint256 _tokenId, Auction memory _auction) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.duration >= 1 minutes, "Invalid duration");

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bid(uint256 _tokenId, uint256 _bidAmount)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction), "Auction is not live");
     
        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
       
        require(_bidAmount >= price, "Insufficient amount");
        
        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);
      
        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
           
            uint256 auctioneerCut = _computeCut(price);
           
            uint256 sellerProceeds = price - auctioneerCut;
          
            payable(seller).transfer(sellerProceeds);
           
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
       
        uint256 bidExcess = _bidAmount - price;
       
        // Return the funds.
        payable(msg.sender).transfer(bidExcess);

        // Tell the world!
        emit AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _isOnAuction(Auction memory _auction) internal pure returns (bool) {
        return (_auction.startedAt > 0);
    }

    /// @dev Returns current price of an NFT on auction. 
    function _currentPrice(Auction memory _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;

       
        if (block.timestamp > _auction.startedAt) {
            secondsPassed = block.timestamp - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
       
        if (_secondsPassed >= _duration) {
         
          // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _endingPrice;
        } else {
             
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
          
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            
            return uint256(currentPrice);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price * ownerCut / 10000;
    }

}


/// @title Clock auction for non-fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuction is Pausable, ClockAuctionBase {

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _cut - percent cut the owner takes on each auction, must be
    ///  between 0-10,000.
     constructor(address _nftAddress, uint256 _cut)  {
        require(_cut <= 10000, "must be between 0-10,000");
        ownerCut = _cut;

        InterfaceERC721 candidateContract = InterfaceERC721(_nftAddress);
        nonFungibleContract = candidateContract;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.

    function withdrawBalance(address _receiver) external {
        require(msg.sender == owner(), "caller must be owner");
        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = payable(_receiver).send(address(this).balance);
        require(res == true, "transfer failed");
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external virtual
        whenNotPaused
    {
        require(_startingPrice == uint256(uint128(_startingPrice)), "Invalid starting price" );
        require(_endingPrice == uint256(uint128(_endingPrice)), "Invalid ending price");
        require(_duration == uint256(uint64(_duration)), "Invalid duration");

        require(_owns(msg.sender, _tokenId), "Sender must be owner");
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(block.timestamp)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function bid(uint256 _tokenId)
        external
        virtual 
        payable
        whenNotPaused
    {
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenId, msg.value);
        
        _transfer(msg.sender, _tokenId);
        
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(uint256 _tokenId)
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction), "Auction not in live");
        address seller = auction.seller;
        require(msg.sender == seller, "Must be a seller");
        _cancelAuction(_tokenId, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenPaused(uint256 _tokenId)
        whenPaused
        onlyOwner
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction), "Auction not in live");
        _cancelAuction(_tokenId, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function getAuction(uint256 _tokenId)
        external
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction), "Auction not in live");
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction), "Auction not in live");
        return _currentPrice(auction);
    }

}


/// @title Clock auction modified for sale of horses
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract DhorseSaleClockAuction is ClockAuction {

    bool public isDhorseSaleClockAuction = true;
    
    // Tracks last 5 sale price of gen0 horse sales
    uint256 public gen0SaleCount;
    uint256[5] public lastGen0SalePrices;

    // Delegate constructor
     constructor(address _nftAddr, uint256 _cut) 
        ClockAuction(_nftAddr, _cut) {}

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external override virtual

    {
        require(_startingPrice == uint256(uint128(_startingPrice)), "Invalid starting price");
        require(_endingPrice == uint256(uint128(_endingPrice)), "Invalid ending price");
        require(_duration == uint256(uint64(_duration)), "Invalid duration");

        require(msg.sender == address(nonFungibleContract), "Only fungible contract");
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(block.timestamp)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function bid(uint256 _tokenId)
        external 
        virtual 
        override
        payable
    {
        // _bid verifies token ID size
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);

        // If not a gen0 auction, exit
        if (seller == address(nonFungibleContract)) {
            // Track gen0 sale prices
            lastGen0SalePrices[gen0SaleCount % 5] = price;
            gen0SaleCount++;
        }
    }

    function averageGen0SalePrice() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastGen0SalePrices[i];
        }
        return sum / 5;
    }

}

// File: contracts/lib/HorseBase.sol

pragma solidity ^0.8.0;



interface IWETH{
    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function balanceOf(address recipient) external returns(uint256); 

}


contract HorseBase is ERC721Base("DHorse", "DHORSE") {

    // breeding limits per month
    uint public constant STALLION = 7;
    uint public constant MARE = 2;
    
    IWETH public weth;

    // minimum eligibility time duration for breeding after birth
    uint public limit = 30 days;
    // Platform Fee 
    uint256 public fee = 15; //15%
    uint256 public baseBreedingPrice = 0.075 ether; 
    // Platform Fee when breeding own stable 
    uint256 public platformFee = 30; //30%

    address public pricePool;
    address public DhorsePlatform;


     /*** DATA TYPES ***/
    struct Horse {
        // The timestamp from the block when this horsecame into existence.
        uint birthTime;
        // The ID of the parents of this horse.
        uint32 mareId;
        uint32 stallionId;
        // The "generation number" of this horse.
        // (i.e. add(mare.generation, stallion.generation))
        uint16 generation;
        // 0 => female. 1 => male
        uint16 gender; 
        //totalOffSpring count.
        uint32 totalOffSpring;
    }

    struct Stud{
        uint placeTime; // studfarm placed time + selected duration
        uint duration;  // selected duration (1, 3, or 7 days) of time your racehorse will be in Stud Farm.
        uint price;
    }
    mapping(uint256 => Stud) public studFarm;   

    struct studFee{
        uint studOwner; // receiving fee %
        uint prizePool;
    }

    // Stud farm fee based on selected duration 
    mapping(uint => studFee) public studFeePcent;

    /// @dev An array containing the Horse struct for all horses in existence. The ID
    ///  of each horseis actually an index into this array. Note that ID 0 is a negahorse,
    ///  the unHorse. In other words, horseID 0 is invalid... ;-)
    Horse[] public horses;

    /// @dev The address of the ClockAuction contract that handles sales of horses. 
    DhorseSaleClockAuction public saleAuction;
    
    constructor(){
        studFeePcent[1 days] = studFee( 40, 45);
        studFeePcent[3 days] = studFee( 48, 37);
        studFeePcent[7 days] = studFee( 56, 29);
    }

    modifier exist(uint256 _stallion, uint256 _mare ) {
        require(horses[_mare].birthTime != 0 && horses[_stallion].birthTime != 0, "Horse not exist");
        _;
    }
    event SetPricePool(address newPricePool);
    event SetDhorsePlatform(address newDhorsePlatform);
    event StudFarm(uint stallion, uint endtime, uint price); 
    event Birth(address owner, uint256 horseId, uint256 mareId, uint256 stallionId);
    event SetBaseBreedingPrice(uint256 basePrice);
  
    /// @dev An internal method that creates a new horse and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is block.timestampn to be valid. Will generate both a Birth event
    ///  and a Transfer event.
    function _createHorse(
        uint256 _mareId,
        uint256 _stallionId,
        uint256 _generation,
        address _owner,
        uint16 _gender
    )
        internal
        returns (uint)
    {
 
        Horse memory _horse = Horse({
            birthTime: uint64(block.timestamp),
            mareId: uint32(_mareId),
            stallionId: uint32(_stallionId),
            generation: uint16(_generation),
            gender: _gender,
            totalOffSpring: 0
        });
        horses.push(_horse);
        uint256 newhorseId =  horses.length - 1;

        require(newhorseId == uint256(uint32(newhorseId)), "NewhorseId");

        // emit the birth event
        emit Birth(
            _owner,
            newhorseId,
            uint256(_horse.mareId),
            uint256(_horse.stallionId)
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _mint(_owner, newhorseId);

        return newhorseId;
    }


    /// @notice Returns the total number of horses currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return horses.length - 1;
    }

    /// @notice Returns a list of all Horse IDs assigned to an address.
    /// @param _owner The owner whose horses we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. 
    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalHorses = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all horses have IDs starting at 1 and increasing
            // sequentially up to the totalHorsecount.
            uint256 horseId;

            for (horseId = 1; horseId <= totalHorses; horseId++) {
                if (_owners[horseId] == _owner) {
                    result[resultIndex] = horseId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

     /// @dev Checks that a given horses is able to breed. 
    function _isReadyToBreed(Horse memory _horse) internal view returns (bool) {
        return (( (block.timestamp - _horse.birthTime) / limit) >= 1) &&
         (_horse.totalOffSpring < ((block.timestamp - _horse.birthTime)/limit) * MARE );
    }

    /// @dev Check if a stallion has authorized breeding. 
    function _isBreedingPermitted(uint256 _stallionId) internal view returns (bool) {
        return (studFarm[_stallionId].placeTime > block.timestamp) && 
             (horses[_stallionId].totalOffSpring <= ((block.timestamp - horses[_stallionId].birthTime)/limit) * STALLION ) ;
    }

    //  @notice Place stallion in studfarm.
    function placeStallionStudFarm(uint256 _stallionId, uint256 _duration,uint256 _price)
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _stallionId) && horses[_stallionId].gender == 1, "Must be horse owner & stallion");
        require(_price >= baseBreedingPrice, "Less than min price");
        require((_duration == 1 days) || (_duration == 3 days) || (_duration == 7 days), "Invalid duration");
        studFarm[_stallionId].duration =  _duration;
        studFarm[_stallionId].price = _price;
        studFarm[_stallionId].placeTime = block.timestamp + _duration;
        emit StudFarm(_stallionId, studFarm[_stallionId].placeTime, _price);
    }

    /// @notice Checks that a given horses is able to breed 
    /// @param _horseId reference the id of the horses, any user can inquire about it
    function isReadyToBreed(uint256 _horseId)
        public
        view
        returns (bool)
    {
        require(_horseId > 0, "Invalid horseId" );
        Horse storage _horse = horses[_horseId];
        return _isReadyToBreed(_horse);
    }

    /// @dev Internal check to see if a given stallion and mare are a valid mating pair.
    /// @param _mare A reference to the Horse struct of the potential mare.
    /// @param _mareId The mare's ID.
    /// @param _stallion A reference to the Horse struct of the potential stallion.
    /// @param _stallionId The stallion's ID
    function _isValidMatingPair(
        Horse storage _mare,
        uint256 _mareId,
        Horse storage _stallion,
        uint256 _stallionId
    )
        private
        view
        returns(bool)
    {
        // A Horse can't breed with itself!
        if (_mareId == _stallionId) {
            return false;
        }

        // Horses can't breed with their parents.
        if (_mare.mareId == _stallionId || _mare.stallionId == _stallionId) {
            return false;
        }
        if (_stallion.mareId == _mareId || _stallion.stallionId == _mareId) {
            return false;
        }

        // We can short circuit the sibling check (below) if either horseis
        // gen zero (has a mare ID of zero).
        if (_stallion.mareId == 0 || _mare.mareId == 0) {
            return true;
        }

        // Horses can't breed with full or half siblings.
        if (_stallion.mareId == _mare.mareId || _stallion.mareId == _mare.stallionId) {
            return false;
        }
        if (_stallion.stallionId == _mare.mareId || _stallion.stallionId == _mare.stallionId) {
            return false;
        }

        return true;
    }

    /// @dev Internal check to see if a given stallion and mare are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function _canBreedWithViaAuction(uint256 _mareId, uint256 _stallionId)
        internal
        view
        returns (bool)
    {
        Horse storage mare = horses[_mareId];
        Horse storage stallion = horses[_stallionId];
        return _isValidMatingPair(mare, _mareId, stallion, _stallionId);
    }

    /// @notice Checks to see if two horses can breed together, including checks for
    ///  ownership and siring approvals. 
    /// @param _mareId The ID of the proposed mare.
    /// @param _stallionId The ID of the proposed stallion.
    function canBreedWith(uint256 _mareId, uint256 _stallionId)
        external
        view
        returns(bool)
    {
        require(_mareId > 0, "Invalid mareId");
        require(_stallionId > 0, "Invalid stallionId");
        Horse storage mare = horses[_mareId];
        Horse storage stallion = horses[_stallionId];
        return _isValidMatingPair(mare, _mareId, stallion, _stallionId) &&
            _isBreedingPermitted(_stallionId);
    }

    /// @notice Breed a Horse you own (as mare) with a stallion that placed in studfarm.
    /// @param _mareId The ID of the Horse acting as mare.
    /// @param _stallionId The ID of the Horse acting as stallion.
    function mix(uint256 _mareId, uint256 _stallionId)
        external
        payable
        whenNotPaused 
        exist(_stallionId,  _mareId)
        returns (uint256)
    {
          
        Stud memory stud = studFarm[_stallionId];
        // Checks for payment.
        require(weth.transferFrom(msg.sender, address(this), stud.price), "transferFrom Failed");
     
        // Caller must own the mare.
        require(_owns(msg.sender, _mareId), "Caller must own the mare");
        // Grab a reference to the potential mare
        Horse storage mare = horses[_mareId];
        // Grab a reference to the potential stallion
        Horse storage stallion = horses[_stallionId];

        require(mare.gender == 0 && stallion.gender == 1, "Gender invalid");
     
        require(_isBreedingPermitted(_stallionId), "Not permitted to breed");
        require(_isReadyToBreed(mare), "Not ready to breed");

        // Test that these horses are a valid mating pair.
        require(_isValidMatingPair(
            mare,
            _mareId,
            stallion,
            _stallionId
        ), "Horses are a valid mating pair");
        
        uint256 horsesId = _createHorse(_mareId,_stallionId,  (mare.generation + stallion.generation), _owners[_mareId],  getGender(_mareId, _stallionId));
        mare.totalOffSpring++;
        stallion.totalOffSpring++;

        // Send the balance fee 
        _safetransfer(msg.sender, _owners[_stallionId], stud.price, studFeePcent[stud.duration].studOwner, studFeePcent[stud.duration].prizePool);
        // return the new horses's ID
        return horsesId;
    }

    function _safetransfer(address  _user, address _receiver, uint _amount, uint _studOwnerPcent, uint _prizePool) private {
        if(_user != _receiver){
            require(weth.transfer(_receiver, (_amount * _studOwnerPcent/100)), "transfer failed");
            require(weth.transfer(pricePool, (_amount * _prizePool/100)), "transfer failed");
            require(weth.transfer(DhorsePlatform, (_amount * fee /100)), "transfer failed");
        }else{
            uint256 platFee = (_amount*platformFee/100);
            _amount = _amount - platFee;
             require(weth.transfer(DhorsePlatform, platFee), "transfer failed");
             require(weth.transfer(pricePool, _amount), "transfer failed");
        }
    }

    function getGender(uint _mareId, uint _stallionId) public view returns(uint16 no){
      bytes32 _hash = keccak256(
        abi.encode(
                blockhash(block.number),
                block.coinbase,
                gasleft(),
                _stallionId,
                _mareId,
                msg.sender
            )
         );
        no =  (uint16(uint(_hash))%(2));
    }
  
    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (ownerOf(_tokenId) == _claimant);
    }

    function setPricePool(address newPricePool) external onlyOwner {
        require(newPricePool != address(0x00), "Zero address");
        pricePool = newPricePool;
        emit SetPricePool(newPricePool);
    }

    function setDhorsePlatform(address newDhorsePlatform) external onlyOwner {
        require(newDhorsePlatform != address(0x00), "Zero address");
        DhorsePlatform = newDhorsePlatform;
        emit SetDhorsePlatform(newDhorsePlatform);
    }

    function setBaseBreedingPrice(uint256 basePrice) external onlyOwner {
        baseBreedingPrice = basePrice;
        emit SetBaseBreedingPrice(basePrice);
    }


}

// File: contracts/lib/HorseAuction.sol

pragma solidity ^0.8.0;




contract HorseAuction is HorseBase {
  
    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) external onlyOwner {
        DhorseSaleClockAuction candidateContract = DhorseSaleClockAuction(_address);

        require(candidateContract.isDhorseSaleClockAuction(), "Must be sale auction contract");

        // Set the new contract address
        saleAuction = candidateContract;
    }
   
    /// @dev Put a horse up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _horseId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If horse is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _horseId), "Not a owner" );
        // Ensure the horse is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the horse IS allowed to be in a cooldown.
        _approve(address(saleAuction),_horseId);
        // Sale auction throws if inputs are invalid and clears
        // transfer and stallion approval after escrowing the horse.
        saleAuction.createAuction(
            _horseId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

}

// File: contracts/lib/HorseMinting.sol

pragma solidity ^0.8.0;



/// @title all functions related to creating horses
contract HorseMinting is HorseAuction {

    // Constants for gen0 auctions.
    uint256 public constant GEN0_STARTING_PRICE = 10e15;
    uint256 public constant GEN0_AUCTION_DURATION = 1 days;

    /// @dev we can create promo horses. Only callable by owner
    /// @param _owner the future owner of the created horses. Default to contract owner
    function createPromoHorse(address _owner,  uint256 _generation, uint16 _gender) external onlyOwner {
        address horseOwner = _owner;
        if (horseOwner == address(0)) {
             horseOwner = owner();
        }

        _createHorse(0, 0, _generation,  horseOwner, _gender);
    }

    /// @dev Creates a new gen0 horse with the given  and
    ///  creates an auction for it.
    function createGen0Auction( uint256 _generation, uint16 _gender) external onlyOwner {

        uint256 horseId = _createHorse(0, 0, _generation, address(this), _gender);
        _approve(address(saleAuction), horseId);

        saleAuction.createAuction(
            horseId,
            _computeNextGen0Price(),
            0,
            GEN0_AUCTION_DURATION,
            address(this)
        );

    }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function _computeNextGen0Price() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageGen0SalePrice();

        // Sanity check to ensure we don't overflow arithmetic
        require(avePrice == uint256(uint128(avePrice)), "Sanity check");

        uint256 nextPrice = avePrice + (avePrice / 2);
      

        // We never auction for less than starting price
        if (nextPrice < GEN0_STARTING_PRICE) {
            nextPrice = GEN0_STARTING_PRICE;
        }
     
        return nextPrice;
    }

}

// File: contracts/DHorseCore.sol

pragma solidity ^0.8.0;

contract DHorseCore is HorseMinting{

    constructor (string memory _baseUri, IWETH _weth, address _pricePool, address _dhorsePlatform) {

        _createHorse(0, 0, 0, address(0),uint16(0));
        _setBaseURI(_baseUri);
        weth = _weth;
        pricePool = _pricePool;
        DhorsePlatform = _dhorsePlatform;
        emit SetPricePool(_pricePool);
        emit SetDhorsePlatform(_dhorsePlatform);        
    }


    /// @notice Returns all the relevant information about a specific horse.
    /// @param _id The ID of the horse of interest.
    function getHorse(uint256 _id)
        external
        view
        returns (
        bool isReady,
        uint256 birthTime,
        uint256 mareId,
        uint256 stallionId,
        uint256 generation,
        uint256 gender,
        uint256 totalOffSpring

    ) {
        Horse storage _horse = horses[_id];

        // if this variable is 0
        isReady = _isReadyToBreed(_horse);
        birthTime = uint256(_horse.birthTime);
        mareId = uint256(_horse.mareId);
        stallionId = uint256(_horse.stallionId);
        generation = uint256(_horse.generation);
        gender = uint256(_horse.gender);
        totalOffSpring = uint256(_horse.totalOffSpring);
    }

    function inCaseTokensGetStuck(address _token) external onlyOwner {
        uint256 amount = IWETH(_token).balanceOf(address(this));
        IWETH(_token).transfer(msg.sender, amount);
    }

    // testing purpose
    function TestSetLimit(uint256 _testlimit) external onlyOwner  {
        limit = _testlimit;
    }
}