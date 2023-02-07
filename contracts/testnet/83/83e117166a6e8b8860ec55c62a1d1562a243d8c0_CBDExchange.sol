// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

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
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

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

// SPDX-License-Identifier: MIT
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function setApprovalForAll(address operator, bool approved) external;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {Pausable} from "openzeppelin-contracts/security/Pausable.sol";
import {IERC721} from "openzeppelin-contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "openzeppelin-contracts/token/ERC1155/IERC1155.sol";
import {Order,SigStore,MintParams,AssetType} from  "./utils/DataTypes.sol";
import {OrderState} from "./utils/OrderState.sol";
import {ICBDManager} from "./interfaces/ICBDManager.sol";
import {ICBDVendor} from "./interfaces/ICBDVendor.sol";

library BytesLibrary {
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes32  fullMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
         return ecrecover(fullMessage, v, r, s);
    }
}

contract CBDExchange is OrderState, Ownable, Pausable {
    using BytesLibrary for bytes32;
    using SafeTransferLib for ERC20;
    using SafeTransferLib for address;

    address public beneficiaryAddress;
    address public buyerFeeSigner;
    uint256 public beneficiaryFee; 
    uint256 public royaltyFeeLimit;
    uint256 public vendorFeeLimit;
    ICBDManager public manager;
    address public weth;

    // auth token for exchange
    mapping(address => bool) public allowedToken;

    event MatchOrder(
        address indexed sellToken,
        uint256 indexed sellTokenId,
        uint256 sellValue,
        address owner,
        address buyToken,
        uint256 buyTokenId,
        uint256 buyValue,
        address buyer,
        uint256 orderType
    );

    event Cancel(
        address indexed sellToken,
        uint256 indexed sellTokenId,
        address owner,
        address buyToken,
        uint256 buyTokenId
    );

	constructor(
		address payable beneficiary,
        address buyerfeesigner,
        uint256 beneficiaryfee,
        address cbdManagerAddr,
        address wethAddr
	)  {
		royaltyFeeLimit = 50;
        vendorFeeLimit = 40;
		beneficiaryAddress = beneficiary;
        buyerFeeSigner = buyerfeesigner;
        beneficiaryFee = beneficiaryfee;
        manager = ICBDManager(cbdManagerAddr);
        weth = wethAddr;
    }                                    

    receive() external payable {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function sell(
        Order memory order,
        SigStore memory sig,
        SigStore memory buyerFeeSig,
        uint256 royaltyFee,
        uint256 vendorFee,
        address payable royaltyReceipt,
        bool isStore,
        MintParams memory storeParams
    ) external payable whenNotPaused {
        require((block.timestamp <= order.expiryTime), "expired!");
        require(order.orderType == 1, "Invalid orderType!");
        require(order.key.owner != msg.sender, "Owner?");

        validateOrderSignature(order, sig);
        validateBuyerFeeSig(order, royaltyFee, royaltyReceipt, buyerFeeSig);

        transferSellFee(
            order, 
            royaltyReceipt, 
            isStore ? ICBDVendor(order.key.sellAsset.token).vendorWallet() : address(0), 
            royaltyFee, 
            vendorFee, 
            msg.sender
        );
        setCompleted(order, true);
        transferToken(order, msg.sender, isStore, storeParams);
        emitMatchOrder(order, msg.sender);
    }

    function buy(
        Order memory order,
        SigStore memory sig,
        SigStore memory buyerFeeSig,
        uint256 royaltyFee,
        uint256 vendorFee,
        address payable royaltyReceipt,
        bool isStore,
        MintParams memory storeParams
    ) external whenNotPaused {
        require((block.timestamp <= order.expiryTime), "B-1");
        require(order.orderType == 2, "B-2");
        require(order.key.owner != msg.sender, "B-3");
        validateOrderSignature(order, sig);
        validateBuyerFeeSig(order, royaltyFee, royaltyReceipt, buyerFeeSig);
        
        transferBuyFee(
            order, 
            royaltyReceipt,
            isStore ? ICBDVendor(order.key.buyAsset.token).vendorWallet() : address(0), 
            royaltyFee, 
            vendorFee, 
            msg.sender
        );
        setCompleted(order, true);
        transferToken(order, msg.sender, isStore, storeParams);
        emitMatchOrder(order, msg.sender);
    }

    function bid(
        Order memory order,
        SigStore memory sig,
        SigStore memory buyerSig,
        SigStore memory buyerFeeSig,
        address buyer,
        uint256 buyingAmount,
        uint256 royaltyFee,
        uint256 vendorFee,
        address payable royaltyReceipt,
        bool isStore,
        MintParams memory storeParams
    ) external whenNotPaused {
        require((block.timestamp <= order.expiryTime), "expired!");
        require(buyingAmount >= order.buying, " Invalid buyingAmount!");	
        require(order.orderType == 3, "Invalid orderType!");
        require(order.key.owner == msg.sender, "Only owner can call!");

        validateOrderSignature(order, sig);
        validateBidOrderSignature(order, buyerSig, buyer, buyingAmount);
        validateBuyerFeeSig(order, royaltyFee, royaltyReceipt, buyerFeeSig);

        setCompleted(order, true);
        setCompletedBidOrder(order, true, buyer, buyingAmount);

        transferBidFee(
            order.key.buyAsset.token,
            order.key.owner,
            buyingAmount,
            royaltyReceipt,
            isStore ? ICBDVendor(order.key.sellAsset.token).vendorWallet() : address(0),
            royaltyFee,
            vendorFee,
            buyer
        );
        transferToken(order, buyer, isStore, storeParams);
        emitMatchOrder(order, buyer);
    }
    
    function transferToken(
        Order memory order,
        address buyer,
        bool isStore,
        MintParams memory storeParams
    ) internal {
        if (order.key.sellAsset.assetType == AssetType.ERC721 || order.key.buyAsset.assetType == AssetType.ERC721) {
            if (order.orderType == 1 || order.orderType == 3) {
                if (!isStore) {
                    require(manager.getVendorContains(order.key.sellAsset.token), "Not from vendor");
                    require(IERC721(order.key.sellAsset.token).ownerOf(order.key.sellAsset.tokenId) == order.key.owner, "Not the owner!");
                    
                    IERC721(order.key.sellAsset.token).safeTransferFrom(
                        order.key.owner,
                        buyer,
                        order.key.sellAsset.tokenId
                    );
                } else {
                    require(manager.getVendorContains(order.key.sellAsset.token), "Mint can only done by vendor!");
                    ICBDVendor(order.key.sellAsset.token).safeMintWithPermit(                        
                        order.key.owner,
                        buyer,
                        order.key.sellAsset.tokenId,
                        storeParams.uri,
                        storeParams.blockExpiry,
                        storeParams.v,
                        storeParams.r,
                        storeParams.s
                    );
                }
            } else if (order.orderType == 2) {
                if (!isStore) {
                    require(manager.getVendorContains(order.key.buyAsset.token), "Not from vendor");
                    require(IERC721(order.key.buyAsset.token).ownerOf(order.key.buyAsset.tokenId) == buyer, "Not the owner!");

                    IERC721(order.key.buyAsset.token).safeTransferFrom(
                        buyer,
                        order.key.owner,
                        order.key.buyAsset.tokenId
                    );
                } else {
                    require(manager.getVendorContains(order.key.buyAsset.token), "Not from vendor!");
                    ICBDVendor(order.key.buyAsset.token).safeMintWithPermit(                        
                        buyer,
                        order.key.owner,
                        order.key.buyAsset.tokenId,
                        storeParams.uri,
                        storeParams.blockExpiry,
                        storeParams.v,
                        storeParams.r,
                        storeParams.s
                    );
                }
            }
        } else if (order.key.sellAsset.assetType == AssetType.ERC1155 || order.key.buyAsset.assetType == AssetType.ERC1155) {
            if (order.orderType == 1 || order.orderType == 3) {
                if (!isStore) {
                    IERC1155(order.key.sellAsset.token).safeTransferFrom(                        
                        order.key.owner,
                        buyer,
                        order.key.sellAsset.tokenId,
                        order.selling,
                        "0x"
                    );
                } else {
                    require(manager.getVendorContains(order.key.sellAsset.token), "TK-3");
                    ICBDVendor(order.key.sellAsset.token).safeMintWithPermit(                        
                        order.key.owner,
                        buyer,
                        order.key.sellAsset.tokenId,
                        storeParams.uri,
                        storeParams.blockExpiry,
                        storeParams.v,
                        storeParams.r,
                        storeParams.s
                    );
                }
            } else if (order.orderType == 2) {
                if (!isStore) {
                    IERC1155(order.key.buyAsset.token).safeTransferFrom(              
                        buyer,
                        order.key.owner,
                        order.key.buyAsset.tokenId,
                        order.buying,
                        "0x"
                    );
                } else {
                    require(manager.getVendorContains(order.key.buyAsset.token), "TK-4");
                    ICBDVendor(order.key.buyAsset.token).safeMintWithPermit(
                        buyer,
                        order.key.owner,
                        order.key.buyAsset.tokenId,
                        storeParams.uri,
                        storeParams.blockExpiry,
                        storeParams.v,
                        storeParams.r,
                        storeParams.s
                    );
                }
            }
        } else {
            revert("invalid assest");
        }
    }

    function transferSellFee(
        Order memory order,
        address royaltyReceipt,
        address vendorReceipt,
        uint256 royaltyFee,
        uint256 vendorFee,
        address buyer
    ) internal {
        if (order.key.buyAsset.token == address(0x00)) {
            require(msg.value == order.buying, "TS-1");
            transferEthFee(
                order.buying,
                order.key.owner,
                royaltyFee,
                vendorFee,
                royaltyReceipt,
                vendorReceipt
            );
        } else if (order.key.buyAsset.token == weth) {
            transferWethFee(
                order.buying,
                order.key.owner,
                buyer,
                royaltyFee,
                vendorFee,
                royaltyReceipt,
                vendorReceipt
            );
        } else {
            transferErc20Fee(
                order.key.buyAsset.token,
                order.buying,
                order.key.owner,
                buyer,
                royaltyFee,
                vendorFee,
                royaltyReceipt,
                vendorReceipt
            );
        }
    }

    function transferBuyFee(
        Order memory order,
        address royaltyReceipt,
        address vendorReceipt,
        uint256 royaltyFee,
        uint256 vendorFee,
        address buyer
    ) internal {
        if (order.key.sellAsset.token == weth) {
            transferWethFee(
                order.selling,
                buyer,
                order.key.owner,
                royaltyFee,
                vendorFee,
                royaltyReceipt,
                vendorReceipt
            );
        } else {
            transferErc20Fee(
                order.key.sellAsset.token,
                order.selling,
                buyer,
                order.key.owner,
                royaltyFee,
                vendorFee,
                royaltyReceipt,
                vendorReceipt
            );
        }
    }

    function transferBidFee(
        address asset,
        address seller,
        uint256 buyingAmount,
        address royaltyReceipt,
        address vendorReceipt,
        uint256 royaltyFee,
        uint256 vendorFee,
        address buyer
    ) internal {
        if (asset == weth) {
            transferWethFee(
                buyingAmount,
                seller,
                buyer,
                royaltyFee,
                vendorFee,
                royaltyReceipt,
                vendorReceipt
            );
        } else {
            transferErc20Fee(
                asset,
                buyingAmount,
                seller,
                buyer,
                royaltyFee,
                vendorFee,
                royaltyReceipt,
                vendorReceipt
            );
        }
    }

    function transferEthFee(
        uint256 amount,
        address _seller,
        uint256 royaltyFee,
        uint256 vendorFee,
        address royaltyReceipt,
        address vendorReceipt
    ) internal {
        (
            uint256 protocolfee,
            uint256 secoundaryFee,
            uint256 vendorShare,
            uint256 remaining
        ) = transferFeeView(amount, 
            royaltyReceipt == address(0) ? 0 :royaltyFee, 
            vendorReceipt == address(0) ? 0 : vendorFee);
        if (protocolfee > 0) {
            beneficiaryAddress.safeTransferETH(protocolfee);
        }
        if ((secoundaryFee > 0) && (royaltyReceipt != address(0x00))) {
            royaltyReceipt.safeTransferETH(secoundaryFee);
        }
        if ((vendorShare > 0) && (vendorReceipt != address(0x00))) {
            address(manager).safeTransferETH(vendorShare);
            manager.addVendorBalance(vendorReceipt,vendorShare);
        }
        if (remaining > 0) {
            _seller.safeTransferETH(remaining);
        }
    }

    function transferWethFee(
        uint256 amount,
        address _seller,
        address buyer,
        uint256 royaltyFee,
        uint256 vendorFee,
        address royaltyReceipt,
        address vendorReceipt
    ) internal {
        (
            uint256 protocolfee,
            uint256 secoundaryFee,
            uint256 vendorShare,
            uint256 remaining
        ) = transferFeeView(amount, 
                royaltyReceipt == address(0) ? 0 :royaltyFee, 
                vendorReceipt == address(0) ? 0 : vendorFee);
        if (protocolfee > 0) {
            ERC20(weth).safeTransferFrom(
                buyer,
                beneficiaryAddress,
                protocolfee
            );
        }
        if ((secoundaryFee > 0) && (royaltyReceipt != address(0x00))) {
            ERC20(weth).safeTransferFrom(buyer, royaltyReceipt, secoundaryFee);
        }
        if ((vendorShare > 0) && (vendorReceipt != address(0x00))) {
            ERC20(weth).safeTransferFrom(buyer, vendorReceipt, vendorShare);
        }
        if (remaining > 0) {
            ERC20(weth).safeTransferFrom(buyer, _seller, remaining);
        }
    }

    function transferErc20Fee(
        address token,
        uint256 amount,
        address _seller,
        address buyer,
        uint256 royaltyFee,
        uint256 vendorFee,
        address royaltyReceipt,
        address vendorReceipt
    ) internal {
        require(allowedToken[token], "Invalid FT!");

        (
            uint256 protocolfee,
            uint256 secoundaryFee,
            uint256 vendorShare,
            uint256 remaining
        ) = transferFeeView(amount, 
                royaltyReceipt == address(0) ? 0 :royaltyFee, 
                vendorReceipt == address(0) ? 0 : vendorFee);
        if (protocolfee > 0) {
            ERC20(token).safeTransferFrom(
                buyer,
                beneficiaryAddress,
                protocolfee
            );
        }
        if ((secoundaryFee > 0) && (royaltyReceipt != address(0x00))) {            
            ERC20(token).safeTransferFrom(
                buyer,
                royaltyReceipt,
                secoundaryFee
            );
        }
        if ((vendorShare > 0) && (vendorReceipt != address(0x00))) {
            ERC20(token).safeTransferFrom(
                buyer,
                vendorReceipt,
                vendorShare
            );
        }
        if (remaining > 0) {
            ERC20(token).safeTransferFrom(buyer, _seller, remaining);
        }
    }

    function transferFeeView(uint256 amount, uint256 royaltyPcent, uint256 vendorPcent)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 protocolFee = (amount * beneficiaryFee) / 1000;

        uint256 secoundaryFee;
        uint256 vendorShareFee;

        if(royaltyPcent > 0) {
            uint256 royaltyShare = royaltyPcent > royaltyFeeLimit ? royaltyFeeLimit : royaltyPcent;
            secoundaryFee = (amount * royaltyShare) / 1000;
        }
        
        if(vendorPcent > 0) {
            uint256 vendorShare = vendorPcent > vendorFeeLimit ? vendorFeeLimit : royaltyPcent;
            vendorShareFee = (amount * vendorShare) / 1000;
        }

        uint256 remaining = amount - (protocolFee + secoundaryFee + vendorShareFee);

        return (protocolFee, secoundaryFee, vendorShareFee, remaining);
    }

    function emitMatchOrder(Order memory order, address buyer) internal {
        emit MatchOrder(
            order.key.sellAsset.token,
            order.key.sellAsset.tokenId,
            order.selling,
            order.key.owner,
            order.key.buyAsset.token,
            order.key.buyAsset.tokenId,
            order.buying,
            buyer,
            order.orderType
        );
    }

    function cancel(Order memory order) external {
        require(order.key.owner == msg.sender, "C-1");
        setCompleted(order, true);
        emit Cancel(
            order.key.sellAsset.token,
            order.key.sellAsset.tokenId,
            msg.sender,
            order.key.buyAsset.token,
            order.key.buyAsset.tokenId
        );
    }

    function validateBuyerFeeSig(
        Order memory order,
        uint256 buyerFee,
        address royaltyReceipt,
        SigStore memory sig
    ) internal view {
        require(
            prepareBuyerFeeMessage(order, buyerFee, royaltyReceipt).recover(
                sig.v,
                sig.r,
                sig.s
            ) == buyerFeeSigner,
            "VB"
        );
    }

    function validateBuyerFeeSigView(
        Order memory order,
        uint256 buyerFee,
        address royaltyReceipt,
        SigStore memory sig
    ) public pure returns (address) {
            return prepareBuyerFeeMessage(order, buyerFee, royaltyReceipt).recover(
                sig.v,
                sig.r,
                sig.s
            ); 
    }

    function toEthSignedMessageHash(bytes32 hash, SigStore memory sig)
        public
        pure
        returns (address signer)
    {
        signer = hash.recover(sig.v, sig.r, sig.s);
    }

    function setBeneficiary(address newBeneficiary) external onlyOwner {
        require(newBeneficiary != address(0), "0 addr");

        beneficiaryAddress = newBeneficiary;
    }

    function setBuyerFeeSigner(address newBuyerFeeSigner) external onlyOwner {
        require(newBuyerFeeSigner != address(0), "0 addr");

        buyerFeeSigner = newBuyerFeeSigner;
    }

    function setBeneficiaryFee(uint256 newbeneficiaryfee) external onlyOwner {
        beneficiaryFee = newbeneficiaryfee;
    }

    function setRoyaltyFeeLimit(uint256 newRoyaltyFeeLimit) external onlyOwner {
        royaltyFeeLimit = newRoyaltyFeeLimit;
    }

    function setVendorFeeLimit(uint256 newVendorFeeLimit) external onlyOwner {
        vendorFeeLimit = newVendorFeeLimit;
    }

    function setTokenStatus(address token, bool status) external onlyOwner {
        require(token != address(0), "0 addr!");
        allowedToken[token] = status;
    }

    function recoverLeftOverEth(uint256 amount) external onlyOwner {
        owner().safeTransferETH(amount);
    }

    function recoverLeftOverToken(ERC20 token,uint256 amount) external onlyOwner {
        token.safeTransfer(owner(),amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICBDManager {    
    // error ZeroAddress();
    // error OnlyExchange();
    // error OnlyFactory();
    // error InsufficientBalance();

    function setNewVendor(address newVendor) external;
    function addVendorBalance(address account,uint256 amount) external;
    function getVendorContains(address account) external view returns (bool);
    function isMinter(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ICBDVendor {
    function vendorWallet() external view returns (address);
    function safeMintWithPermit( 
        address from,
        address to,
        uint256 tokenId,
        string memory uri,
        uint256 blockExpiry,
        uint8 v,
        bytes32 r,
        bytes32 s) external;

    event vendorAddress(address indexed owner,address indexed newVendor);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

enum AssetType {
    ERC20,
    ERC721,
    ERC1155
}

struct Asset {
    address token;
    uint256 tokenId;
    AssetType assetType;  // 0 -> ERC20. 1 -> ERC721, 2 -> ERC1155
}

struct OrderKey {
    /* who signed the order */
    address payable owner;
    /* what has owner */
    Asset sellAsset;
    /* what wants owner */  
    Asset buyAsset;
}

struct Order {
    OrderKey key;
    /* how much has owner (in wei, or UINT256_MAX if ERC-721) */
    uint256 selling;
    /* how much wants owner (in wei, or UINT256_MAX if ERC-721) */
    uint256 buying;
    /* fee for selling  secoundary sale*/
    uint256 sellerFee;
    /* random numbers*/
    uint256 salt;
    /* expiry time for order*/
    uint256 expiryTime; // for bid auction auction time + bidexpiry
    /* order Type */
    uint256 orderType; // 1.sell , 2.buy, 3.bid
}

/* An ECDSA signature. */
struct SigStore {
    /* v parameter */
    uint8 v;
    /* r parameter */
    bytes32 r;
    /* s parameter */
    bytes32 s;
}

struct MintParams {
    uint256 blockExpiry;
    uint8 v;
    bytes32 r;
    bytes32 s;
    string uri;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import {Order,SigStore} from  "./DataTypes.sol";

library BytesLibrary {
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes32  fullMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
         return ecrecover(fullMessage, v, r, s);
    }
}

contract OrderState   {
    using BytesLibrary for bytes32;

    // error InvalidBuyerFeeSig();
    // error ZeroAddress();

    mapping(bytes32 => bool) public completed; // 1.completed

    function getCompleted(Order calldata order)
        external
        view
        returns (bool)
    {
        return completed[getCompletedKey(order)];
    }

    function setCompleted(Order memory order, bool newCompleted)
        internal
    {
        completed[getCompletedKey(order)] = newCompleted;
    }

    function setCompletedBidOrder(
        Order memory order,
        bool newCompleted,
        address buyer,
        uint256 buyingAmount
    ) internal {
        completed[
            getBidOrderCompletedKey(order, buyer, buyingAmount)
        ] = newCompleted;
    }

    function getCompletedKey(Order memory order)
        public
        pure
        returns (bytes32)
    {
        return prepareOrderHash(order);
    }

    function getBidOrderCompletedKey(
        Order memory order,
        address buyer,
        uint256 buyingAmount
    ) public pure returns (bytes32) {
        return prepareBidOrderHash(order, buyer, buyingAmount);
    }

    function validateOrderSignature(Order memory order, SigStore memory sig)
        internal
        view
    {
        require(completed[getCompletedKey(order)] != true, "Signature exist");
        if (sig.v == 0 && sig.r == bytes32(0x0) && sig.s == bytes32(0x0)) {
            revert("incorrect signature");
        } else {
            require(
                prepareOrderHash(order).recover(sig.v, sig.r, sig.s) ==
                    order.key.owner,
                "Incorrect signature"
            );
        }
    }

    function validateOrderSignatureView(Order memory order, SigStore memory sig)
        public
        view 
        returns (address)
    {
        require(completed[getCompletedKey(order)] != true, "Signature exist");
        if (sig.v == 0 && sig.r == bytes32(0x0) && sig.s == bytes32(0x0)) {
            revert("Incorrect signature");
        } else {
              return prepareOrderHash(order).recover(sig.v, sig.r, sig.s);
        }
    }

    function validateBidOrderSignature(
        Order memory order,
        SigStore memory sig,
        address bidder,
        uint256 buyingAmount
    ) internal view {
        require(
            completed[getBidOrderCompletedKey(order, bidder, buyingAmount)] !=
                true,
            "Signature exist"
        );
        if (sig.v == 0 && sig.r == bytes32(0x0) && sig.s == bytes32(0x0)) {
            revert("Incorrect bid signature");
        } else {
            require(
                prepareBidOrderHash(order, bidder, buyingAmount).recover(
                    sig.v,
                    sig.r,
                    sig.s
                ) == bidder,
                "Incorrect bid signature"
            );
        }
    }

    function validateBidOrderSignatureView(
        Order memory order,
        SigStore memory sig,
        address bidder,
        uint256 buyingAmount
    ) public view returns (address) {
        require(completed[getCompletedKey(order)] != true, "Signature exist");
        if (sig.v == 0 && sig.r == bytes32(0x0) && sig.s == bytes32(0x0)) {
            revert("Incorrect bid signature");
        } else {
                return prepareBidOrderHash(order, bidder, buyingAmount).recover(
                    sig.v,
                    sig.r,
                    sig.s
                );
        }
    }

    function prepareOrderHash(Order memory order)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    order.key.owner,
                    abi.encodePacked(
                        order.key.sellAsset.token,
                        order.key.sellAsset.tokenId,
                        order.key.sellAsset.assetType,
                        order.key.buyAsset.token,
                        order.key.buyAsset.tokenId,
                        order.key.buyAsset.assetType
                    ),
                    order.selling,
                    order.buying,
                    order.sellerFee,
                    order.salt,
                    order.expiryTime,
                    order.orderType
                )
            );
    }

    function prepareBidOrderHash(
        Order memory order,
        address bidder,
        uint256 buyingAmount
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    bidder,
                    abi.encodePacked(
                        order.key.buyAsset.token,
                        order.key.buyAsset.tokenId,
                        order.key.buyAsset.assetType,
                        order.key.sellAsset.token,
                        order.key.sellAsset.tokenId,
                        order.key.sellAsset.assetType
                    ),
                    buyingAmount,
                    order.selling,
                    order.sellerFee,
                    order.salt,
                    order.expiryTime,
                    order.orderType
                )
            );
    }

    function prepareBuyerFeeMessage(
        Order memory order,
        uint256 fee,
        address royaltyReceipt
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    abi.encodePacked(
                        order.key.owner,
                        abi.encodePacked(
                            order.key.sellAsset.token,
                            order.key.sellAsset.tokenId,
                            order.key.buyAsset.token,
                            order.key.buyAsset.tokenId
                        ),
                        order.selling,
                        order.buying,
                        order.sellerFee,
                        order.salt,
                        order.expiryTime,
                        order.orderType
                    ),
                    fee,
                    royaltyReceipt
                )
            );
    }
}