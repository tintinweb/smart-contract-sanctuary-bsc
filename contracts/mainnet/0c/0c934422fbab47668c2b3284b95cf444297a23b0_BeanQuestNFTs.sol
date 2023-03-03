/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

//SPDX-License-Identifier: UNLICENSED

// File: @openzeppelin/contracts/utils/Context.sol

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
contract Activation {

    struct Stat {
        uint STR;
        uint DEX;
        uint INT;
        uint seasonCompoundedLast;
        uint lbSTR;
        uint lbDEX;
        uint lbINT;
    }

    mapping(address => Stat) public stats;
    mapping(address => uint) public highestStatReached;

    struct Relic {
        string relicName;
        uint256 multiplier;
        uint8 bonusType;
        bool consumable;
    }

    Relic[] public relics;
    mapping(uint8 => mapping(address => bool)) public activated; //Lets us know if effect is activated
    mapping(uint => mapping(address => bool)) public idActivated;
    mapping(address => mapping(uint8 => uint256)) public relicActiveForBonus; //Lets us know which token is giving the bonus

    function _unequipStatsUpgrade(address _addr, uint _id, uint _attribute) virtual internal {
        stats[_addr].STR = _attribute == 0 ? stats[_addr].STR - relics[_id].multiplier : stats[_addr].STR;
        stats[_addr].DEX = _attribute == 1 ? stats[_addr].DEX - relics[_id].multiplier : stats[_addr].DEX;
        stats[_addr].INT = _attribute == 2 ? stats[_addr].INT - relics[_id].multiplier : stats[_addr].INT;
    }
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

// File: @openzeppelin/contracts/token/ERC1155/ERC1155.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI, Activation {
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
        require(account != address(0), "ERC1155: address zero is not a valid owner");
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
            "ERC1155: caller is not token owner nor approved"
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
            "ERC1155: caller is not token owner nor approved"
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
     * Emits a {TransferBatch} event.
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
     * Emits a {TransferSingle} event.
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
     * Emits a {TransferBatch} event.
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
     * Emits an {ApprovalForAll} event.
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
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
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
    ) internal virtual {
        
        for (uint256 i = 0; i < ids.length; i++) {
            uint _id = ids[i];
            if(from != address(0) && balanceOf(from, _id) - amounts[i] == 0) {
                uint8 _bonus = relics[_id].bonusType;
                if(_bonus > 12 && _bonus < 16) {
                    _unequipStatsUpgrade(from, _id, _bonus - 13);
                }
                activated[_bonus][from] = false;
                idActivated[_id][from] = false;
                relicActiveForBonus[from][_bonus] = 0;
            }
        }

    }

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

// File: contracts/BossNFTs.sol

// contracts/GameItems.sol

pragma solidity ^0.8.0;


contract BeanQuestNFTs is ERC1155, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Strings for uint256;


    /*BONUS TYPES:
    0 = null
    1 = Bonus compound when leveling STR
    2 = Bonus compound when leveling DEX
    3 = Bonus compound when leveling INT
    4 = Bonus level STR
    5 = Bonus level DEX
    6 = Bonus level INT
    7 = Higher Chance to beat Boss
    8 = Boss Protection - Lose less of your compound - value: reinvest * value / 100
    9 = Haste - Can avoid withdrawal penalty quicker -  value: 432000 - value
    10 = Stats upgrade consumable (STR) - value must be * 10 ** 18
    11 = Stats upgrade consumable (DEX) - same
    12 = Stats upgrade consumable (INT) - same
    13 = Equip Stats Upgrade (STR) - same   
    14 = Equip Stats Upgrade (DEX) - same
    15 = Equip Stats Upgrade (INT) - same
    16 = Ability to upgrade 3 attributes simultaneously (divides by 3) - 0
    17 = Bonus compound when leveling all 3 stats;
    18 = Recovery - Can challenge boss quicker - value: 43200 - value
    19 = Augmented chance to find magic bean - value: 55(beanChance) + value
    20 = Can look for Magic Beans faster : value: 86400 - value

    */
    uint public totalBonuses = 21;


    address public minerContract;
    BeanQuest miner = BeanQuest(minerContract);
    address public gachaAddress;
    address public questsAddress;
    // address kvrfContract;
    // KenshiVRF vrf = KenshiVRF(kvrfContract);
    address public bossAddress;
    BossContract boss = BossContract(bossAddress);    
    
    address[] public users;
    mapping(address => bool) public isUser;
    uint public maxStat;
    uint public season;


    // struct Gacha {
    //     uint[] common;
    //     uint[] uncommon;
    //     uint[] rare;
    //     uint[] legendary;
    //     uint[] chances;
    //     uint cost;
    // }

    // Gacha[] public gachas;
    // // uint[] public gachaCommon;
    // // uint[] public gachaRare;
    // // uint[] public gachaUltraRare;
    
    // // uint public gachaCost = 0.05 ether;
    // uint public maxMint = 10;
    // address payable dev;

    // event GachaMint(address user, uint[] item, uint[] rarity);
    event StatsUpdated(address user, uint attribute, uint amount);

    constructor(string memory _uri) ERC1155(_uri) {
        relics.push(Relic("null", 0, 0, false));
    }

    function toggleEffect (uint _id) public {
        require(balanceOf(msg.sender, _id) > 0, "You do not own this relic");
        uint8 _bonus = relics[_id].bonusType;
        if(_bonus > 9 && _bonus < 13) {
            _eatStatsConsumable(msg.sender, _id, _bonus - 10);
        }
        else {
            if(activated[_bonus][msg.sender]) { 
                if(relicActiveForBonus[msg.sender][_bonus] != _id) { // THIS MEANS WE ARE EQUIPPING A RELIC THAT HAS A BONUS THAT IS ALREADY ACTIVE
                    idActivated[relicActiveForBonus[msg.sender][_bonus]][msg.sender] = false; // Deactivate the previous relic equipped for this bonus
                    if(_bonus > 12 && _bonus < 16) { // If it's an equip that raises your stats
                        _unequipStatsUpgrade(msg.sender, relicActiveForBonus[msg.sender][_bonus], uint(_bonus) - 13);  // It will put your stats back where they should be
                        _equipStatsUpgrade(msg.sender, _id, _bonus - 13); // It will then put your stats right for the new item you're equipping
                    }
                    relicActiveForBonus[msg.sender][_bonus] = _id; // This is the new relic active for this bonus
                    idActivated[_id][msg.sender] = true; // This relic is now activated
                }
                else { //THIS MEANS WE ARE UNEQUIPPING A RELIC
                    if(_bonus > 12 && _bonus < 16) { // if it's an equip that raises your stats
                        _unequipStatsUpgrade(msg.sender, _id, uint(_bonus) - 13); // Sets stats to their proper place
                    }
                    activated[_bonus][msg.sender] = false; // Bonus no longer activated
                    idActivated[_id][msg.sender] = false; // The item is no longer activated
                    relicActiveForBonus[msg.sender][_bonus] = 0; // The relic active for this bonus is set to null
                }
            }
            else {  // THIS MEANS WE ARE EQUIPPING A RELIC THAT HAD NO BONUS ACTIVE
                if (_bonus > 12 && _bonus < 16){ //If it's an equip that raises your stats
                    _equipStatsUpgrade(msg.sender, _id, uint(_bonus) - 13); // Increases your stats accordingly
                }
                activated[_bonus][msg.sender] = true; // Bonus is now activated
                idActivated[_id][msg.sender] = true; // This item is now activated
                relicActiveForBonus[msg.sender][_bonus] = _id; //This is now the relic active for this bonus
            }
            if(activated[17][msg.sender]) {
                activated[1][msg.sender] = false;
                activated[2][msg.sender] = false;
                activated[3][msg.sender] = false;
                idActivated[relicActiveForBonus[msg.sender][1]][msg.sender] = false;
                idActivated[relicActiveForBonus[msg.sender][2]][msg.sender] = false;
                idActivated[relicActiveForBonus[msg.sender][3]][msg.sender] = false;
                relicActiveForBonus[msg.sender][1] = 0;
                relicActiveForBonus[msg.sender][2] = 0;
                relicActiveForBonus[msg.sender][3] = 0;
            }
            if(activated[1][msg.sender] || activated[2][msg.sender] || activated[3][msg.sender]){
                activated[17][msg.sender] = false;
                idActivated[relicActiveForBonus[msg.sender][17]][msg.sender] = false;
                relicActiveForBonus[msg.sender][17] = 0;
            }
        }
    }

    function _burnConsumables(address _addr) internal {
        uint _id;
        for(uint8 i = 1; i < totalBonuses; i++) {
            _id = getRelicActiveForBonus(_addr, i);
            if(_id != 0 && relics[_id].consumable && i != 9 && i != 19 && i != 20) {
                _burn(_addr, _id, 1);
            }
        }
    }

    function _burnHaste(address _addr) external {
        require(msg.sender == minerContract, "Unauthorized");
        uint _id = getRelicActiveForBonus(_addr, 9);
        if(relics[_id].consumable) {
            _burn(_addr, _id, 1);
        }
    }

    function _burnQuestItem(address _addr, uint id, uint amount) external {
        require(msg.sender == questsAddress, "Unauthorized");
        _burn(_addr, id, amount);
    }

    function _burnBeanConsumables(address _addr) external {
        require(msg.sender == minerContract, "Unauthorized");
        uint _id = getRelicActiveForBonus(_addr, 19);
        if(relics[_id].consumable) {
            _burn(_addr, _id, 1);
        }
        _id = getRelicActiveForBonus(_addr, 20);
        if(relics[_id].consumable) {
            _burn(_addr, _id, 1);
        }
    }


    function _equipStatsUpgrade(address _addr, uint _id, uint _attribute) internal {
        if(!isUser[_addr]) {
            users.push(_addr);
            isUser[_addr] = true;
        }
        stats[_addr].STR = _attribute == 0 ? stats[_addr].STR + getBonusMultiplier(_id) : stats[_addr].STR;
        stats[_addr].DEX = _attribute == 1 ? stats[_addr].DEX + getBonusMultiplier(_id) : stats[_addr].DEX;
        stats[_addr].INT = _attribute == 2 ? stats[_addr].INT + getBonusMultiplier(_id) : stats[_addr].INT;
    }

    function _unequipStatsUpgrade(address _addr, uint _id, uint _attribute) virtual override internal {
        stats[_addr].STR = _attribute == 0 ? stats[_addr].STR - getBonusMultiplier(_id) : stats[_addr].STR;
        stats[_addr].DEX = _attribute == 1 ? stats[_addr].DEX - getBonusMultiplier(_id) : stats[_addr].DEX;
        stats[_addr].INT = _attribute == 2 ? stats[_addr].INT - getBonusMultiplier(_id) : stats[_addr].INT;
    }

    function _eatStatsConsumable(address _addr, uint _id, uint _attribute) internal {
        if(!isUser[_addr]) {
            users.push(_addr);
            isUser[_addr] = true;
        }
        if(stats[_addr].seasonCompoundedLast != season) {
            stats[_addr] = Stat(
                0 + getBonusMultiplier(getRelicActiveForBonus(_addr, 13)),
                0 + getBonusMultiplier(getRelicActiveForBonus(_addr, 14)),
                0 + getBonusMultiplier(getRelicActiveForBonus(_addr, 15)),
                season, 0, 0, 0);
        }
        uint _bonus = getBonusMultiplier(_id);
        if(_attribute == 0) {
            stats[_addr].STR += _bonus;
            if(stats[_addr].STR - getBonusMultiplier(getRelicActiveForBonus(_addr, 13)) >= 10 ether ) {
                stats[_addr].lbSTR = stats[_addr].STR - getBonusMultiplier(getRelicActiveForBonus(_addr, 13)) - 10 ether;
            }
        }
        if(_attribute == 1) {
            stats[_addr].DEX += _bonus;
            if(stats[_addr].DEX - getBonusMultiplier(getRelicActiveForBonus(_addr, 14)) >= 10 ether) {
                stats[_addr].lbDEX = stats[_addr].DEX - getBonusMultiplier(getRelicActiveForBonus(_addr, 14)) - 10 ether;
            }
        }
        if(_attribute == 2) {
            stats[_addr].INT += _bonus;
            if(stats[_addr].INT - getBonusMultiplier(getRelicActiveForBonus(_addr, 15)) >= 10 ether) {
                stats[_addr].lbINT = stats[_addr].INT - getBonusMultiplier(getRelicActiveForBonus(_addr, 15)) - 10 ether;
            }
        }
        _burn(_addr, _id, 1);
    }

    function updateStats(uint payout, address _addr, uint8 _attribute) external returns (uint) {
        require(msg.sender == minerContract, "You are not authorized to use this function");
        if(!isUser[_addr]) {
            users.push(_addr);
            isUser[_addr] = true;
        }
        uint256 _addAttribute;
        uint _addAttTotal;
        // if(stats[_addr].seasonCompoundedLast != season) {
        //     stats[_addr] = Stat(
        //         0 + getBonusMultiplier(getRelicActiveForBonus(_addr, 13)),
        //         0 + getBonusMultiplier(getRelicActiveForBonus(_addr, 14)),
        //         0 + getBonusMultiplier(getRelicActiveForBonus(_addr, 15)),
        //         season, 0, 0, 0);
        // }
        // stats[_addr].seasonCompoundedLast = season;
        if(_attribute == 0) {
            _addAttribute = getEffectStatus(4, _addr) ? SafeMath.div(SafeMath.mul(payout, getBonusMultiplier(getRelicActiveForBonus(_addr, 4))), 100) : payout;
            stats[_addr].STR = stats[_addr].STR + _addAttribute - (getBonusMultiplier(getRelicActiveForBonus(_addr, 13)) + stats[_addr].lbSTR) > 10 ether ? 10 ether + getBonusMultiplier(getRelicActiveForBonus(_addr, 13)) + stats[_addr].lbSTR : SafeMath.add(stats[_addr].STR, _addAttribute);
            payout = getEffectStatus(1, _addr) ? SafeMath.div(SafeMath.mul(payout, getBonusMultiplier(getRelicActiveForBonus(_addr , 1))), 100) : payout;
        }
        if(_attribute == 1) {
            _addAttribute = getEffectStatus(5, _addr) ? SafeMath.div(SafeMath.mul(payout, getBonusMultiplier(getRelicActiveForBonus(_addr, 5))), 100) : payout;
            stats[_addr].DEX = stats[_addr].DEX + _addAttribute - (getBonusMultiplier(getRelicActiveForBonus(_addr, 14)) + stats[_addr].lbDEX) > 10 ether ? 10 ether + getBonusMultiplier(getRelicActiveForBonus(_addr, 14)) + stats[_addr].lbDEX : SafeMath.add(stats[_addr].DEX, _addAttribute);
            payout = getEffectStatus(2, _addr) ? SafeMath.div(SafeMath.mul(payout, getBonusMultiplier(getRelicActiveForBonus(_addr, 2))), 100) : payout;
        }
        if(_attribute == 2) {
            _addAttribute = getEffectStatus(6, _addr) ? SafeMath.div(SafeMath.mul(payout, getBonusMultiplier(getRelicActiveForBonus(_addr, 6))), 100) : payout;
            stats[_addr].INT = stats[_addr].INT + _addAttribute - (getBonusMultiplier(getRelicActiveForBonus(_addr, 15)) + stats[_addr].lbINT) > 10 ether ? 10 ether + getBonusMultiplier(getRelicActiveForBonus(_addr, 15)) + stats[_addr].lbINT : SafeMath.add(stats[_addr].INT, _addAttribute);
            payout = getEffectStatus(3, _addr) ? SafeMath.div(SafeMath.mul(payout, getBonusMultiplier(getRelicActiveForBonus(_addr, 3))), 100) : payout;
        }
        if(_attribute == 3) {
            _addAttribute = getEffectStatus(4, _addr) ? SafeMath.div(SafeMath.mul(payout / 3, getBonusMultiplier(getRelicActiveForBonus(_addr, 4))), 100) : payout / 3;
            _addAttTotal += _addAttribute;
            stats[_addr].STR = stats[_addr].STR + _addAttribute - (getBonusMultiplier(getRelicActiveForBonus(_addr, 13)) + stats[_addr].lbSTR) > 10 ether ? 10 ether + getBonusMultiplier(getRelicActiveForBonus(_addr, 13)) + stats[_addr].lbSTR : SafeMath.add(stats[_addr].STR, _addAttribute);
            _addAttribute = getEffectStatus(5, _addr) ? SafeMath.div(SafeMath.mul(payout / 3, getBonusMultiplier(getRelicActiveForBonus(_addr, 5))), 100) : payout / 3;
            _addAttTotal += _addAttribute;
            stats[_addr].DEX = stats[_addr].DEX + _addAttribute - (getBonusMultiplier(getRelicActiveForBonus(_addr, 14)) + stats[_addr].lbDEX) > 10 ether ? 10 ether + getBonusMultiplier(getRelicActiveForBonus(_addr, 14)) + stats[_addr].lbDEX : SafeMath.add(stats[_addr].DEX, _addAttribute);
            _addAttribute = getEffectStatus(6, _addr) ? SafeMath.div(SafeMath.mul(payout / 3, getBonusMultiplier(getRelicActiveForBonus(_addr, 6))), 100) : payout / 3;
            _addAttTotal += _addAttribute;
            stats[_addr].INT = stats[_addr].INT + _addAttribute - (getBonusMultiplier(getRelicActiveForBonus(_addr, 15)) + stats[_addr].lbINT) > 10 ether ? 10 ether + getBonusMultiplier(getRelicActiveForBonus(_addr, 15)) + stats[_addr].lbINT : SafeMath.add(stats[_addr].INT, _addAttribute);
            payout = getEffectStatus(17, _addr) ? SafeMath.div(SafeMath.mul(payout, getBonusMultiplier(getRelicActiveForBonus(_addr, 17))), 100) : payout;
        }
        _burnConsumables(_addr);
        emit StatsUpdated(_addr, _attribute, _attribute == 3 ? _addAttTotal : _addAttribute);
        return payout;
    }

    function userStats(address _addr) view external returns(uint[4] memory) {
            uint256[4] memory _stats;
            _stats[0] = stats[_addr].STR;
            _stats[1] = stats[_addr].DEX;
            _stats[2] = stats[_addr].INT;
            _stats[3] = stats[_addr].STR + stats[_addr].DEX + stats[_addr].INT;
            return _stats;
    }

    function getRelic(uint _id) public view returns(Relic memory) {
        return relics[_id];
    }

    function getRelicName(uint _id) public view returns (string memory) {
        return relics[_id].relicName;
    }

    function getBonusType(uint _id) public view returns (uint8) {
        return relics[_id].bonusType;
    }

    function getRelicActiveForBonus(address _add, uint8 _bonus) public view returns(uint) {
        return relicActiveForBonus[_add][_bonus];
    }

    function getBonusMultiplier(uint _id) public view returns (uint) {
        return relics[_id].multiplier;
    }

    function getEffectStatus(uint8 _bonus, address _add) public view returns(bool) {
        return activated[_bonus][_add];
    }

    function tokenURI(uint256 _id) public view virtual returns (string memory) {
        string memory baseURI = uri(_id);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _id.toString(), ".json")) : "";
    }

    function getRelics() public view returns(Relic[] memory) {
        return relics;
    }

    function getRelicsBalances(address _address) public view returns (uint[] memory balances) {
        uint[] memory _balances = new uint[](relics.length);
        for(uint i; i < relics.length; i++) {
            _balances[i] = balanceOf(_address, i);
        }
        return (_balances);
    }

    function getRelicsEquipped(address _address) public view returns (bool[] memory equipped) {
        bool[] memory _equipped = new bool[](relics.length);
        for(uint i; i < relics.length; i++) {
            _equipped[i] = idActivated[i][_address];
        }
        return _equipped;
    }

    function getBonusesEquipped(address _address) public view returns(bool[] memory bonuses, uint[] memory multipliers, Relic[] memory equippedRelics) {
        bool[] memory _bonuses = new bool[](totalBonuses);
        uint[] memory _multipliers = new uint[](totalBonuses);
        Relic[] memory _relics = new Relic[](totalBonuses);

        for(uint8 i=1; i < totalBonuses; i++) {
            _bonuses[i] = activated[i][_address];
            _multipliers[i] = getBonusMultiplier(getRelicActiveForBonus(_address, i));
            _relics[i] = relics[relicActiveForBonus[_address][i]];
        }
        return(_bonuses, _multipliers, _relics);
    }

    function getUris() public view returns (string[] memory uri) {
        string[] memory _uri = new string[](relics.length);
        for(uint i; i < relics.length; i++) {
            _uri[i] = tokenURI(i);
        }
        return _uri;
    }

    function getInventory(address _address) public view returns(uint[] memory balances, Relic[] memory relics, bool[] memory equipped, string[] memory uri) {
        uint[] memory _relics = new uint[](relics.length);
        bool[] memory _equipped = new bool[](relics.length);
        string[] memory _uri = new string[](relics.length);
        for(uint i; i < relics.length; i++) {
            _relics[i] = balanceOf(_address, i);
            _equipped[i] = idActivated[i][_address];
            _uri[i] = tokenURI(i);        }
        return (_relics, relics, _equipped, _uri);
    }

    function getLevels(uint num, uint num2) public view returns(address[] memory arrUsers, uint[] memory str, uint[] memory inte, uint[] memory dex) {
        uint b = num2 == 0 ? users.length : num2 - num;
        address[] memory _users = new address[](b);
        string[] memory _names = new string[](b);
        uint[] memory _str = new uint[](b);
        uint[] memory _int = new uint[](b);
        uint[] memory _dex = new uint[](b);
        for(uint i; i < b ; i++) {
            _str[i] = stats[users[num]].STR;
            _int[i] = stats[users[num]].INT;
            _dex[i] = stats[users[num]].DEX;
            _users[i] = users[num];
            _names[i] = miner.getNicknameToAddress(users[num]);
            num++;
        }
        return (_users, _str, _int, _dex);
    }
    
    function createRelic(Relic memory _relic) public onlyOwner {
        relics.push(_relic);
    }

    function createRelics(Relic[] memory _relics) public onlyOwner {
        for(uint i; i < _relics.length; i++) {
            relics.push(_relics[i]);
        }
    }

    function defineRelic(uint _id, uint _multiplier, string memory _name, uint8 _bonusType, bool _consumable) public onlyOwner {
        Relic(relics[_id].relicName = _name, relics[_id].multiplier = _multiplier, relics[_id].bonusType = _bonusType, relics[_id].consumable = _consumable);
    }

    function mint(uint _id, address _add, uint amount) public {
        require(msg.sender == minerContract || msg.sender == gachaAddress || msg.sender == questsAddress);
        _mint(_add, _id, amount, "");
    }
    
    // function mintOwner(uint _id, address _add, uint amount) public onlyOwner {
    //     _mint(_add, _id, amount, "");
    // }

    function setSeason(bool attemptReset) public onlyOwner {
        season++;
        if(attemptReset) {
            resetStats(0, 0);
        }
    }

    function resetStats(uint num, uint num2) public {
        require(msg.sender == owner() || msg.sender == address(this), "Unauthorized call");
        uint b = num2 == 0 ? users.length : num2 - num;
        for(uint i; i < b; i++) {
            _resetStats(users[num]);
            num++;
        }
    }

    function _resetStats(address _addr) internal {
        stats[_addr].STR = 0 + getBonusMultiplier(relicActiveForBonus[_addr][13]);
        stats[_addr].DEX = 0 + getBonusMultiplier(relicActiveForBonus[_addr][14]);
        stats[_addr].INT = 0 + getBonusMultiplier(relicActiveForBonus[_addr][15]);
        stats[_addr].seasonCompoundedLast = season;
        stats[_addr].lbSTR = 0;
        stats[_addr].lbDEX = 0;
        stats[_addr].lbINT = 0;
    }

    function setContracts(address _miner, address _boss, address _gacha, address _quests) public onlyOwner {
        minerContract = _miner;
        miner = BeanQuest(_miner);
        boss = BossContract(_boss);
        bossAddress = _boss;
        gachaAddress = _gacha;
        questsAddress = _quests;
    }

    function setURI(string memory _newUri) public onlyOwner {
        _setURI(_newUri);
    }

    // function getPreviousNFTs(address _c) public onlyOwner {
    //     previousNFTContract _nft = previousNFTContract(_c);
    //     relics = _nft.getRelics();
    // }
    
}

// contract previousNFTContract {
//     function getRelics() public view returns(Activation.Relic[] memory) {} 
// }

contract BossContract {
    function getSeason() external view returns(uint) {}
}

contract BeanQuest {
    function getNicknameToAddress(address _addr) public view returns (string memory nick){}
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}