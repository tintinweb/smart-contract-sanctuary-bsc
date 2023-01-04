/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
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
}

// import '@openzeppelin/contracts/utils/math/Math.sol';
/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
  /**
   * @dev Returns the largest of two numbers.
   */
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  /**
   * @dev Returns the smallest of two numbers.
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

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

// import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

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
    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{ value: amount }('');
    require(success, 'Address: unable to send value, recipient may have reverted');
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
    return functionCall(target, data, 'Address: low-level call failed');
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
    return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
    require(address(this).balance >= value, 'Address: insufficient balance for call');
    require(isContract(target), 'Address: call to non-contract');

    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return functionStaticCall(target, data, 'Address: low-level static call failed');
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
    require(isContract(target), 'Address: static call to non-contract');

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
    return functionDelegateCall(target, data, 'Address: low-level delegate call failed');
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
    require(isContract(target), 'Address: delegate call to non-contract');

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
  bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';

  /**
   * @dev Converts a `uint256` to its ASCII `string` decimal representation.
   */
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return '0';
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
      return '0x00';
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
    buffer[0] = '0';
    buffer[1] = 'x';
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, 'Strings: hex length insufficient');
    return string(buffer);
  }
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
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC721-balanceOf}.
   */
  function balanceOf(address owner) public view virtual override returns (uint256) {
    require(owner != address(0), 'ERC721: balance query for the zero address');
    return _balances[owner];
  }

  /**
   * @dev See {IERC721-ownerOf}.
   */
  function ownerOf(uint256 tokenId) public view virtual override returns (address) {
    address owner = _owners[tokenId];
    require(owner != address(0), 'ERC721: owner query for nonexistent token');
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
    require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');

    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
  }

  /**
   * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
   * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
   * by default, can be overriden in child contracts.
   */
  function _baseURI() internal view virtual returns (string memory) {
    return '';
  }

  /**
   * @dev See {IERC721-approve}.
   */
  function approve(address to, uint256 tokenId) public virtual override {
    address owner = ERC721.ownerOf(tokenId);
    require(to != owner, 'ERC721: approval to current owner');

    require(
      _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
      'ERC721: approve caller is not owner nor approved for all'
    );

    _approve(to, tokenId);
  }

  /**
   * @dev See {IERC721-getApproved}.
   */
  function getApproved(uint256 tokenId) public view virtual override returns (address) {
    require(_exists(tokenId), 'ERC721: approved query for nonexistent token');

    return _tokenApprovals[tokenId];
  }

  /**
   * @dev See {IERC721-setApprovalForAll}.
   */
  function setApprovalForAll(address operator, bool approved) public virtual override {
    require(operator != _msgSender(), 'ERC721: approve to caller');

    _operatorApprovals[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }

  /**
   * @dev See {IERC721-isApprovedForAll}.
   */
  function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override
    returns (bool)
  {
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
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      'ERC721: transfer caller is not owner nor approved'
    );

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
    safeTransferFrom(from, to, tokenId, '');
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
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      'ERC721: transfer caller is not owner nor approved'
    );
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
    require(
      _checkOnERC721Received(from, to, tokenId, _data),
      'ERC721: transfer to non ERC721Receiver implementer'
    );
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
  function _isApprovedOrOwner(address spender, uint256 tokenId)
    internal
    view
    virtual
    returns (bool)
  {
    require(_exists(tokenId), 'ERC721: operator query for nonexistent token');
    address owner = ERC721.ownerOf(tokenId);
    return (spender == owner ||
      getApproved(tokenId) == spender ||
      isApprovedForAll(owner, spender));
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
    _safeMint(to, tokenId, '');
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
      'ERC721: transfer to non ERC721Receiver implementer'
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
    require(to != address(0), 'ERC721: mint to the zero address');
    require(!_exists(tokenId), 'ERC721: token already minted');

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
    address owner = ERC721.ownerOf(tokenId);

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
    require(ERC721.ownerOf(tokenId) == from, 'ERC721: transfer of token that is not own');
    require(to != address(0), 'ERC721: transfer to the zero address');

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
    emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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
      try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (
        bytes4 retval
      ) {
        return retval == IERC721Receiver.onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert('ERC721: transfer to non ERC721Receiver implementer');
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
}

// import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

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
  function tokenOfOwnerByIndex(address owner, uint256 index)
    external
    view
    returns (uint256 tokenId);

  /**
   * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
   * Use along with {totalSupply} to enumerate all tokens.
   */
  function tokenByIndex(uint256 index) external view returns (uint256);
}

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
  // Mapping from owner to list of owned token IDs
  mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) private _ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] private _allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) private _allTokensIndex;

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165, ERC721)
    returns (bool)
  {
    return
      interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
  }

  /**
   * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
   */
  function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(index < ERC721.balanceOf(owner), 'ERC721Enumerable: owner index out of bounds');
    return _ownedTokens[owner][index];
  }

  /**
   * @dev See {IERC721Enumerable-totalSupply}.
   */
  function totalSupply() public view virtual override returns (uint256) {
    return _allTokens.length;
  }

  /**
   * @dev See {IERC721Enumerable-tokenByIndex}.
   */
  function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
    require(index < ERC721Enumerable.totalSupply(), 'ERC721Enumerable: global index out of bounds');
    return _allTokens[index];
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
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    if (from == address(0)) {
      _addTokenToAllTokensEnumeration(tokenId);
    } else if (from != to) {
      _removeTokenFromOwnerEnumeration(from, tokenId);
    }
    if (to == address(0)) {
      _removeTokenFromAllTokensEnumeration(tokenId);
    } else if (to != from) {
      _addTokenToOwnerEnumeration(to, tokenId);
    }
  }

  /**
   * @dev Private function to add a token to this extension's ownership-tracking data structures.
   * @param to address representing the new owner of the given token ID
   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
    uint256 length = ERC721.balanceOf(to);
    _ownedTokens[to][length] = tokenId;
    _ownedTokensIndex[tokenId] = length;
  }

  /**
   * @dev Private function to add a token to this extension's token tracking data structures.
   * @param tokenId uint256 ID of the token to be added to the tokens list
   */
  function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }

  /**
   * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
   * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
   * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
   * This has O(1) time complexity, but alters the order of the _ownedTokens array.
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
    // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary
    if (tokenIndex != lastTokenIndex) {
      uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

      _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
      _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
    }

    // This also deletes the contents at the last position of the array
    delete _ownedTokensIndex[tokenId];
    delete _ownedTokens[from][lastTokenIndex];
  }

  /**
   * @dev Private function to remove a token from this extension's token tracking data structures.
   * This has O(1) time complexity, but alters the order of the _allTokens array.
   * @param tokenId uint256 ID of the token to be removed from the tokens list
   */
  function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
    // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = _allTokens.length - 1;
    uint256 tokenIndex = _allTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
    // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
    // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
    uint256 lastTokenId = _allTokens[lastTokenIndex];

    _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
    _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

    // This also deletes the contents at the last position of the array
    delete _allTokensIndex[tokenId];
    _allTokens.pop();
  }
}

// import '@openzeppelin/contracts/access/Ownable.sol';

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
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

// import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
  // Booleans are more expensive than uint256 or any type that takes up a full
  // word because each write operation emits an extra SLOAD to first read the
  // slot's contents, replace the bits taken up by the boolean, and then write
  // back. This is the compiler's defense against contract upgrades and
  // pointer aliasing, and it cannot be disabled.

  // The values being non-zero value makes deployment a bit more expensive,
  // but in exchange the refund on every call to nonReentrant will be lower in
  // amount. Since refunds are capped to a percentage of the total
  // transaction's gas, it is best to keep them low in cases like this one, to
  // increase the likelihood of the full refund coming into effect.
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }
}

// import '@openzeppelin/contracts/utils/Counters.sol';

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
    require(value > 0, 'Counter: decrement overflow');
    unchecked {
      counter._value = value - 1;
    }
  }

  function reset(Counter storage counter) internal {
    counter._value = 0;
  }
}

interface ICoupons {
  function checkCoupon(
    string memory _id_collection,
    string memory _coupon_code,
    uint256 _tokenPrice
  ) external;
}

contract Market is ERC721, ERC721Enumerable, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  using SafeMath for uint256;
  using Math for uint256;
  using Address for address;

  // mapping(address => bool) private excludedList;
  mapping(uint256 => TokenMeta) private _tokenMeta;
  mapping(uint256 => Bid) private _bids;

  string private baseURI;
  uint256 public feeSellTokens = 20000; // 2 %
  uint256 public minIncrement = 20000; // 2 % min increment for new bids from highest
  uint256 public maxAllowedRoyalties = 500000; // 50 %
  address public couponsContract;
  
  address[21] public acceptedTokens; // position or index 0 of this array will never be used || 19 free positions to modify
  string[21] public acceptedTokensName; // token names
  bool[21] public acceptedTokensStatus; // token status: true=visible to select false= no visible to select 
  mapping(string => uint256) public _collectionToken;

  struct TokenMeta {
    uint256 id;
    string name;
    bool sale;
    uint256 sell_method; // 1 : fixed, 2 : bids
    uint256 expire_at;
    uint256 price;
    uint256 royalty;
    address artist;
    bool locked;
    string id_collection;
  }

  struct Bid {
    address bidder;
    uint256 amount;
  }

  // Events
  event OrderSuccessful(
    uint256 indexed assetId,
    address indexed seller,
    uint256 totalPrice,
    address indexed buyer
  );
  event OrderAuctionResolved(
    uint256 indexed assetId,
    address indexed seller,
    uint256 totalPrice,
    address indexed buyer
  );
  event ChangedSalesFee(uint256 salesFee);
  event ChangedMinIncrement(uint256 newMinIncrement);
  event ChangedSalesTokenStatus(
    uint256 indexed tokenId,
    address indexed who,
    bool status,
    uint256 price,
    uint256 sell_method,
    uint256 expire_at
  );
  event ChangedMaxAllowedRoyalties(uint256 maxRoyalties);
  event NewHighestBid(uint256 indexed tokenId, address indexed bidder, uint256 newHighestBid);
  event RefundCoinsFromAuction(uint256 indexed tokenId, address indexed bidder, uint256 amount);
  event NewProfit(uint256 indexed tokenId, address indexed admin, uint256 time, uint256 amount);
  event TransferOutsideMarket(
    address indexed sender,
    address indexed receiver,
    uint256 indexed tokenId,
    uint256 time
  );
  event WithdrawnProfits(address indexed receiver, uint256 amount, uint256 time, address acceptedToken);

  event Set_AcceptedToken(uint256 index, address tokenAddress, string name, bool status);

  event Set_CollectionToken(string id_collection, uint256 acceptedTokenIndex, address acceptedToken);

  constructor(string memory _newbaseURI) ERC721("NONAME", "NONA") {
    // URL Base
    setBaseURI(_newbaseURI);

    address nativeCoinRepresentation = 0x1111111111111111111111111111111111111111;
    string memory nativeCoinName = "MATIC"; // MATIC, BNB, ETH
    bool nativeCoinStatus = true;

    acceptedTokens[1] = nativeCoinRepresentation; // position or index "1" is equal to 0x11111... and represents the native coin
    acceptedTokensName[1] = nativeCoinName;
    acceptedTokensStatus[1] = nativeCoinStatus;
    emit Set_AcceptedToken(1, nativeCoinRepresentation, nativeCoinName, nativeCoinStatus);
  }

  /**
   * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
   * in child contracts.
   */
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
  {
    // solium-disable-next-line operator-whitespace
    return super.supportsInterface(interfaceId);
  }

  /**
   * @dev set token BEP20 to be used to buy and sell tokens
   * @param _acceptedToken address contract
   * @param _index index in list of acceptedTokens
   */
  function setAcceptedTokens(address _acceptedToken, uint256 _index, string memory _name, bool _status) public onlyOwner {
    // require(_acceptedToken.isContract(), 'The accepted token address must be a deployed contract');
    require(_index >= 1 && _index<=20, "the index must be a number between 2 and 20");
    if(_index != 1){
        acceptedTokens[_index] = _acceptedToken;
    }
    acceptedTokensName[_index] = _name;
    acceptedTokensStatus[_index] = _status;
    emit Set_AcceptedToken(_index, _acceptedToken, _name, _status);
  }

  function getListAcceptedTokens()external view returns(address[] memory, string[] memory, bool[] memory){ // position or index 0 of this array will never be used
    address[] memory addressList = new address[](acceptedTokens.length);
    string[] memory nameList = new string[](acceptedTokens.length);
    bool[] memory statusList = new bool[](acceptedTokens.length);
    for (uint256 i=0; i<acceptedTokens.length; i++) {
        addressList[i] = acceptedTokens[i];
        nameList[i] = acceptedTokensName[i];
        statusList[i] = acceptedTokensStatus[i];
    }
    return (addressList, nameList, statusList);
  }

  function setCouponsContract(address _couponsContract) public onlyOwner {
    require(
      _couponsContract.isContract(),
      'The Coupons Contract address must be a deployed contract'
    );
    couponsContract = _couponsContract;
  }

  function setBaseURI(string memory _newBaseURI) public virtual onlyOwner {
    baseURI = _newBaseURI;
  }

  /**
   * @dev set fee to cut from sales
   * @param _newFeeSellTokens uint256 fee to cut 0-499999
   */
  function setFeeSellTokens(uint256 _newFeeSellTokens) public onlyOwner {
    require(_newFeeSellTokens < 500000, 'ERC721: Max Allowed Royalties 50%');
    feeSellTokens = _newFeeSellTokens;
    emit ChangedSalesFee(feeSellTokens);
  }

  function getFeeSellTokens() public view returns (uint256) {
    return feeSellTokens;
  }

  /**
   * @dev set min Increment value for new bids in percent 0-1000000
   * @param _newMinIncrement uint256
   */
  function setMinIncrement(uint256 _newMinIncrement) public onlyOwner {
    minIncrement = _newMinIncrement;
    emit ChangedMinIncrement(_newMinIncrement);
  }

  function getMinIncrement() public view returns (uint256) {
    return minIncrement;
  }

  /**
   * @dev validate if the from account can buy the token {_tokenId}
   * @param _from address
   * @param _tokenId uint256
   */
  function canBuy(address _from, uint256 _tokenId) public view returns (bool) {
    bool can_buy;
    address acceptedToken = getTokenOfCollectionToken(_tokenId);
    if(acceptedToken == acceptedTokens[1]){
      if(address(_from).balance >= _tokenMeta[_tokenId].price){
        can_buy = true;
      }
    }else if(IERC20(acceptedToken).balanceOf(_from) >= _tokenMeta[_tokenId].price){
      can_buy = true;
    }
    return can_buy;
  }

  /**
   * @dev calculate royalty to pay if buy token
   * @param _tokenId uint256
   */
  function calculaRoyaltyToBePaid(uint256 _tokenId)
    public
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256 feeSellToken = _computePercent(_tokenMeta[_tokenId].price, feeSellTokens);
    uint256 feeArtistSellToken = _computePercent(
      _tokenMeta[_tokenId].price,
      _tokenMeta[_tokenId].royalty
    );
    uint256 sellerProceeds = _tokenMeta[_tokenId].price - feeSellToken - feeArtistSellToken;
    return (sellerProceeds, feeSellToken, feeArtistSellToken);
  }

  /**
   * @dev sets max allowed royalty to create a new token
   * @param _newMaxAllowedRoyalties uint256 max value %
   */
  function setMaxAllowedRoyalties(uint256 _newMaxAllowedRoyalties) public onlyOwner {
    require(_newMaxAllowedRoyalties < 500000, 'ERC721: Max Allowed Royalties 50%');
    maxAllowedRoyalties = _newMaxAllowedRoyalties;
    emit ChangedMaxAllowedRoyalties(maxAllowedRoyalties);
  }

  modifier isOnAuctions(uint256 _tokenId) {
    require(_exists(_tokenId), 'ERC721: nonexistent token');
    require(_tokenMeta[_tokenId].sell_method == 2, "ERC721: It's not open to bids");
    require(_tokenMeta[_tokenId].locked == true, "ERC721: It's not locked for bids");
    require(_tokenMeta[_tokenId].sale == true, "ERC721: It's not for sale currently");
    _;
  }

  modifier isOpenToAuctions(uint256 _tokenId) {
    require(block.timestamp < _tokenMeta[_tokenId].expire_at, 'ERC721: Time expired to do bids');
    _;
  }

  modifier auctionsEnded(uint256 _tokenId) {
    require(block.timestamp >= _tokenMeta[_tokenId].expire_at, 'ERC721: Time no expired yet');
    _;
  }

  receive() external payable {
    revert();
  }

  fallback() external payable {
    revert();
  }

  function withdraw(uint256 _acceptedTokenIndex) public onlyOwner {
    uint256 balance;
    if(_acceptedTokenIndex == 1){
      balance = address(this).balance;
      payable(owner()).transfer(balance);
    }else{
      balance = IERC20(acceptedTokens[_acceptedTokenIndex]).balanceOf(address(this));
      IERC20(acceptedTokens[_acceptedTokenIndex]).transfer(owner(), balance);
    }
    
    emit WithdrawnProfits(owner(), balance, block.timestamp, acceptedTokens[_acceptedTokenIndex]);
  }

  function minAmountForBid(uint256 _tokenId)
    public
    view
    isOpenToAuctions(_tokenId)
    returns (uint256)
  {
    uint256 maxValue = _tokenMeta[_tokenId].price.max(_bids[_tokenId].amount);
    uint256 amountRequired = _computePercent(maxValue, minIncrement);
    return maxValue + amountRequired;
  }

  function timeLeftToCloseAuctions(uint256 _tokenId) public view returns (uint256) {
    if (block.timestamp >= _tokenMeta[_tokenId].expire_at) {
      return 0;
    }

    uint256 left = _tokenMeta[_tokenId].expire_at - block.timestamp;
    return (left > 0) ? left : 0;
  }

  function highestBid(uint256 _tokenId) public view isOnAuctions(_tokenId) returns (uint256) {
    return _tokenMeta[_tokenId].price.max(_bids[_tokenId].amount);
  }

  function setCollectionToken(string memory _id_collection, uint256 _acceptedTokenIndex) external {
    require(_acceptedTokenIndex >= 1 && _acceptedTokenIndex<=20, "the index must be a number between 1 and 20");
    require(_collectionToken[_id_collection] == 0, "this collection is already associated with a token");
    require(acceptedTokens[_acceptedTokenIndex] != address(0), "invalid _acceptedTokenIndex");
    _collectionToken[_id_collection] = _acceptedTokenIndex;
    emit Set_CollectionToken(_id_collection, _acceptedTokenIndex, acceptedTokens[_acceptedTokenIndex]);
  }

  // getTokenOfCollectionToken is to get the token used to trade in a collection of a specific item
  function getTokenOfCollectionToken(uint256 _tokenId) public view returns (address) {
    return acceptedTokens[_collectionToken[_tokenMeta[_tokenId].id_collection]];
  }

  function bid(uint256 _tokenId, uint256 _amount)
    external
    payable
    isOnAuctions(_tokenId)
    isOpenToAuctions(_tokenId)
    nonReentrant
  {
    require(ownerOf(_tokenId) != _msgSender(), "ERC721: Owner can't bid on its token");
    uint256 amountRequired = minAmountForBid(_tokenId);
    require(_amount >= amountRequired, 'ERC721: Bid amount lower than current min bids');
    address acceptedToken = getTokenOfCollectionToken(_tokenId);

    address oldBidder = _bids[_tokenId].bidder;
    uint256 oldAmount = _bids[_tokenId].amount;

    _bids[_tokenId] = Bid({ bidder: _msgSender(), amount: _amount });

    if (oldBidder != address(0) && oldAmount > 0) {
      if(acceptedToken == acceptedTokens[1]){
        payable(oldBidder).transfer(oldAmount);
      }else{
        IERC20(acceptedToken).transfer(oldBidder, oldAmount);
      }
      emit RefundCoinsFromAuction(_tokenId, oldBidder, oldAmount);
    }

    if(acceptedToken == acceptedTokens[1]){
      require(msg.value >= _amount, "ERC720: Insufficient balance to offer amount for the NFT");
    }else{
      IERC20(acceptedToken).transferFrom(_msgSender(), address(this), _amount);
    }
    emit NewHighestBid(_tokenId, _msgSender(), _amount);
  }

  function resolveAuction(uint256 _tokenId)
    external
    isOnAuctions(_tokenId)
    auctionsEnded(_tokenId)
  {
    require(
      _bids[_tokenId].amount >= _tokenMeta[_tokenId].price,
      'ERC721: There is nothing pending to solve'
    );
    address acceptedToken = getTokenOfCollectionToken(_tokenId);
    address tokenSeller = ownerOf(_tokenId);
    uint256 sellerProceeds = _bids[_tokenId].amount;
    uint256 feesByTransfer = _payTxFee(_tokenId, true); // pay fees by auctions

    if(acceptedToken == acceptedTokens[1]){
      payable(tokenSeller).transfer(sellerProceeds.sub(feesByTransfer));
    }else{
      IERC20(acceptedToken).transfer(tokenSeller, sellerProceeds.sub(feesByTransfer));
    }

    _transfer(tokenSeller, _bids[_tokenId].bidder, _tokenId);

    _tokenMeta[_tokenId].price = _bids[_tokenId].amount;
    delete _bids[_tokenId];

    emit OrderAuctionResolved(_tokenId, tokenSeller, _tokenMeta[_tokenId].price, ownerOf(_tokenId));
  }

  /**
   * @dev sets maps token to its price
   * @param _tokenId uint256 token ID (token number)
   * @param _sale bool token on sale
   * @param _price unit256 token price
   *
   * Requirements:
   * `tokenId` must exist
   * `price` must be more than 0
   * `owner` must the msg.owner
   * `sale` must be true or false
   * `sell_method` must be 1 : price fixed or 2 : auctions
   * `expire_at` must be an unix timestamp
   */
  function setTokenSale(
    uint256 _tokenId,
    bool _sale,
    uint256 _sell_method,
    uint256 _expire_at,
    uint256 _price
  ) public {
    require(_price > 0, 'ERC721: Price of token must be greater than zero');
    require(ownerOf(_tokenId) == _msgSender(), 'ERC721: Only owner of token can do this action');

    if (
      _tokenMeta[_tokenId].sell_method == 2 &&
      _tokenMeta[_tokenId].locked == true &&
      _tokenMeta[_tokenId].sale == true
    ) {
      require(
        _tokenMeta[_tokenId].expire_at <= block.timestamp && _bids[_tokenId].bidder == address(0),
        'ERC721: Token currently blocked due to active auctions'
      );
    }

    _tokenMeta[_tokenId].sale = _sale;
    _tokenMeta[_tokenId].sell_method = _sell_method;
    _tokenMeta[_tokenId].expire_at = _expire_at;
    _tokenMeta[_tokenId].price = _price;
    _tokenMeta[_tokenId].locked = false;

    if (_sell_method == 2 && _sale == true) {
      _tokenMeta[_tokenId].locked = true;
    }

    emit ChangedSalesTokenStatus(_tokenId, _msgSender(), _sale, _price, _sell_method, _expire_at);
  }

  /**
   * @dev sets token meta
   * @param _tokenId uint256 token ID (token number)
   * @param _meta TokenMeta
   *
   * Requirements:
   * `tokenId` must exist
   * `owner` must the msg.owner
   */
  function _setTokenMeta(uint256 _tokenId, TokenMeta memory _meta) internal {
    require(_exists(_tokenId));
    // require(ownerOf(_tokenId) == _msgSender());
    _tokenMeta[_tokenId] = _meta;
  }

  function tokenMeta(uint256 _tokenId) public view returns (TokenMeta memory) {
    require(_exists(_tokenId));
    return _tokenMeta[_tokenId];
  }

  function artistOf(uint256 _tokenId) internal view virtual returns (address) {
    require(_exists(_tokenId));
    return _tokenMeta[_tokenId].artist;
  }

  /**
   * @dev purchase _tokenId
   * @param _tokenId uint256 token ID (token number)
   * @param _operation_type uint256 (0= normal, 1= buy with coupon)
   * @param _coupon_code string (coupon code to claim)
   */
  function buy(
    uint256 _tokenId,
    uint256 _operation_type,
    string memory _coupon_code,
    address _sellerAddress,
    string memory _name,
    uint256 _price,
    uint256 _royalty,
    string memory _id_collection
  ) external payable nonReentrant returns (uint256) {
    if (_tokenId == 0) {
      _tokenId = mint(_sellerAddress, _name, _price, 1, 0, _royalty, true, _id_collection);
    }
    address acceptedToken = getTokenOfCollectionToken(_tokenId);
    require(
      msg.sender != address(0) && msg.sender != ownerOf(_tokenId),
      'ERC721: Curent sender is already owner of this token'
    );
    if (_operation_type == 0 && acceptedToken == acceptedTokens[1]) {
      require(msg.value >= _tokenMeta[_tokenId].price, 'ERC721: insufficient balance to purchase the NFT');
    }
    require(_tokenMeta[_tokenId].sale == true, 'ERC721: This token is not for Sale currently');

    if (_tokenMeta[_tokenId].sell_method == 2 && _tokenMeta[_tokenId].locked) {
      require(
        _tokenMeta[_tokenId].expire_at <= block.timestamp && _bids[_tokenId].bidder == address(0),
        'ERC721: Token locked currently due to Auctions'
      );
    }

    if (_operation_type == 1) {
      ICoupons(couponsContract).checkCoupon(
        _tokenMeta[_tokenId].id_collection,
        _coupon_code,
        _tokenMeta[_tokenId].price
      );
    }

    address tokenSeller = ownerOf(_tokenId);
    if (_operation_type == 0) {
      uint256 sellerProceeds = _tokenMeta[_tokenId].price;
      uint256 feesByTransfer = _payTxFee(_tokenId, false);

      if(acceptedToken == acceptedTokens[1]){
        payable(tokenSeller).transfer(sellerProceeds.sub(feesByTransfer));
      }else{
        IERC20(acceptedToken).transferFrom(msg.sender, tokenSeller, sellerProceeds.sub(feesByTransfer));
      }
    }
    _transfer(tokenSeller, msg.sender, _tokenId);

    uint256 token_price = _tokenMeta[_tokenId].price;
    emit OrderSuccessful(_tokenId, tokenSeller, token_price, msg.sender);
    return _tokenId;
  }

  function mint(
    address _owner,
    string memory _name,
    uint256 _price,
    uint256 _sell_method,
    uint256 _expire_at,
    uint256 _royalty,
    bool _sale,
    string memory _id_collection
  ) public returns (uint256) {
    require(_price > 0);
    require(
      _royalty >= 0 && _royalty <= maxAllowedRoyalties,
      'ERC721: Very high royalty, you have to set a lower royalty'
    );
    require(_collectionToken[_id_collection] != 0, "collection without trading token");

    _tokenIds.increment();
    bool locked = false;

    uint256 newItemId = _tokenIds.current();
    _safeMint(_owner, newItemId);

    if (_sell_method == 2 && _sale == true) {
      require(block.timestamp < _expire_at, 'ERC721: time to expire auction must be in the future');
      locked = true;
    }

    TokenMeta memory meta = TokenMeta(
      newItemId,
      _name,
      _sale,
      _sell_method,
      _expire_at,
      _price,
      _royalty,
      _owner,
      locked,
      _id_collection
    );
    _setTokenMeta(newItemId, meta);

    return newItemId;
  }

  function getTokenPrice(uint256 _tokenId, bool sellByAuctions) internal view returns (uint256) {
    return
      sellByAuctions
        ? _tokenMeta[_tokenId].price.max(_bids[_tokenId].amount)
        : _tokenMeta[_tokenId].price;
  }

  function _payTxFee(uint256 _tokenId, bool sellByAuctions) internal returns (uint256) {
    address acceptedToken = getTokenOfCollectionToken(_tokenId);
    
    uint256 feesByTransfer = 0;
    address tokenSeller = ownerOf(_tokenId);

    if (tokenSeller != owner()) {
      uint256 feeSellToken = _computePercent(getTokenPrice(_tokenId, sellByAuctions), feeSellTokens);
      
      if(acceptedToken == acceptedTokens[1]){
        payable(owner()).transfer(feeSellToken);
      }else{
        if (sellByAuctions) {
          IERC20(acceptedToken).transfer(owner(), feeSellToken);
        } else {
          require(IERC20(acceptedToken).balanceOf(_msgSender()) >= feeSellToken, 'ERC720: insufficient balance to transfer the NFT');
          IERC20(acceptedToken).transferFrom(msg.sender, owner(), feeSellToken);
        }
      }

      emit NewProfit(_tokenId, owner(), block.timestamp, feeSellToken);
      feesByTransfer += feeSellToken;
    }

    if (tokenSeller != owner() && tokenSeller != artistOf(_tokenId)) {
      uint256 royaltyFee = _computePercent(getTokenPrice(_tokenId, sellByAuctions), _tokenMeta[_tokenId].royalty);

      if(acceptedToken == acceptedTokens[1]){
        payable(artistOf(_tokenId)).transfer(royaltyFee);
      }else{
        if (sellByAuctions) {
          IERC20(acceptedToken).transfer(artistOf(_tokenId), royaltyFee);
        } else {
          require(IERC20(acceptedToken).balanceOf(_msgSender()) >= royaltyFee, 'ERC720: insufficient balance to transfer the NFT');
          IERC20(acceptedToken).transferFrom(msg.sender, artistOf(_tokenId), royaltyFee);
        }
      }

      feesByTransfer += royaltyFee;
    }
    return feesByTransfer;
  }

  function _computePercent(uint256 _amount, uint256 feeAmount) internal pure returns (uint256) {
    return _amount.mul(feeAmount).div(1e6);
  }

  function tokensOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 length = ERC721.balanceOf(_owner);
    uint256[] memory tokens = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      tokens[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokens;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);

    _tokenMeta[tokenId].sale = false;
    _tokenMeta[tokenId].locked = false;
  }

  function destroySmartContract() public onlyOwner {
    // withdraw();
    selfdestruct(payable(owner()));
  }
}