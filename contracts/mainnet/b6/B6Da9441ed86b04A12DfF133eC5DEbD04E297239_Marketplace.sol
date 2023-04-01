/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: contracts/Marketplace.sol



pragma solidity ^0.8.9;









contract Marketplace is ERC1155Holder, Pausable, Ownable{
	receive() external payable {  }
	
	using SafeMath for uint256;
	using Address for address;
	
	mapping(uint256 => uint256) public marketSupply;	

	/// @dev offer pointer
    uint256 private offerIdPointer = 0;

	enum OfferMethod{ SELL, BUY }
	enum OfferStatus{ PAYABLE, CLOSED, PAID }

	// A structure for an Offer
	struct Offer{
		uint256 id;
		uint256 token; // payment token 
		uint256 collection; // Nft collection 
		uint256 pieceID; // token ID
		uint256 supply;  // total supply on market on current price
		uint256 quantity;
		uint256 price;   // price in wei
		address from;
		OfferMethod method;
		OfferStatus status;
	}

	struct TokenList {
		address _address;
		bool _pause;
	}

	struct CollectionList {
		address _address;
		bool _pause;
	}
	
	mapping(uint256 => Offer) public offers; // map for all offers on the market
	mapping(uint256 => TokenList) public tokens; ///@dev Governance payment token address
	mapping(uint256 => CollectionList) public collections; ///@dev Governance collection address

	// Events
	event OfferCreated(IERC1155 collection, uint256 indexed offerIndex, address indexed creator, uint256 indexed pieceID, uint256 supply, uint256 price);
	event PiecePurchasedWithToken(IERC20 token, IERC1155 collection, uint256 indexed offerIndex,uint256 indexed pieceID, uint256 amount, address buyer);
	event PiecePurchased(IERC1155 collection, uint256 indexed offerIndex,uint256 indexed pieceID, uint256 amount, address buyer);
	event PieceSell(IERC1155 collection, uint256 indexed offerIndex,uint256 indexed pieceID, uint256 amount, address seller);
	event OfferClosed(IERC1155 collection, address indexed seller, uint256 pieceID, uint256 offerID);

	/**
		Pause the marketplace
	 */
	function pause() public onlyOwner {
        _pause();
    }

	/**
		Unpause the marketplace
	 */
    function unpause() public onlyOwner {
        _unpause();
    }

	/**
		create a payment token
		@param _id token id
		@param _address token address
	 */
	function addToken(uint256 _id, address _address) external onlyOwner whenNotPaused {
		require(_id > 0, 'FootballMarketPlace: You can not use zero as ID for token');
		TokenList memory token = TokenList(_address, false);

		tokens[_id] = token;
	}

	/**
		delete a collection
		@param _id collection id
	 */
	function deleteToken(uint256 _id) external onlyOwner whenNotPaused {
		require(tokens[_id]._address != address(0x0), "FootballMarketPlace: the payment token not found");

		delete tokens[_id];
	}

	/**
		get a payment token
		@param _token payment token id
	 */
	function getToken(uint256 _token) internal view virtual returns(IERC20) {
		TokenList memory token = tokens[_token];

		require(token._address != address(0x0), "FootballMarketPlace: the payment token not found");
		require(!token._pause, "FootballMarketPlace: the payment token has been paused");

		return IERC20(token._address);
	}

	/**
		Pause a payment token
		@param _id payment token id
	 */
	function pauseToken(uint256 _id) public onlyOwner {
        require(tokens[_id]._address != address(0x0), "FootballMarketPlace: the payment token not found");

		tokens[_id]._pause = true;
    }

	/**
		Unpause a payment token
		@param _id payment token id
	 */
    function unpauseToken(uint256 _id) public onlyOwner {
        require(tokens[_id]._address != address(0x0), "FootballMarketPlace: the payment token not found");

		tokens[_id]._pause = false;
    }

	/**
		Create a ERC1155 collection
		@param _id collection id
		@param _address token address
	 */
	function addCollection(uint256 _id, address _address) external onlyOwner whenNotPaused {
		CollectionList memory collection = CollectionList(_address, false);

		collections[_id] = collection;
	}

	/**
		delete a collection
		@param _id collection id
	 */
	function deleteCollection(uint256 _id) external onlyOwner whenNotPaused {
		require(collections[_id]._address != address(0x0), "FootballMarketPlace: the collection not found");

		delete collections[_id];
	}

	/**
		Get a collection
		@param _collection offer id
	 */
	function getCollection(uint256 _collection) internal view virtual returns(IERC1155) {
		CollectionList memory collection = collections[_collection];

		require(collection._address != address(0x0), "FootballMarketPlace: the collection not found");
		require(!collection._pause, "FootballMarketPlace: the collection has been paused");

		return IERC1155(collection._address);
	}
	
	/**
		Pause a collection
		@param _id collection id
	 */
	function pauseCollection(uint256 _id) public onlyOwner {
        require(collections[_id]._address != address(0x0), "FootballMarketPlace: the collection not found");

		collections[_id]._pause = true;
    }

	/**
		Unpause a collection
		@param _id collection id
	 */
	function unpauseCollection(uint256 _id) public onlyOwner {
        require(collections[_id]._address != address(0x0), "FootballMarketPlace: the collection not found");

		collections[_id]._pause = false;
    }

	/**
		Get an offer
		@param _offer offer id
	 */
	function getOffer(uint256 _offer) internal view virtual returns(Offer memory) {
		Offer memory offer = offers[_offer];

		require(offer.from != address(0x0), "FootballMarketPlace: the offer not found");

		return offer;
	}
	
	/**
		Create an offer
		@param _collection NFT collection
		@param _pieceID nft token id
		@param _amount initial supply for market
		@param _price price for market
	 */
	function createSellOffer(uint256 _token, uint256 _collection, uint256 _pieceID, uint256 _amount, uint256 _price) external whenNotPaused {
		// check user has enough nfts
		IERC1155 collection = getCollection(_collection);

		if (_token != 0) getToken(_token);

		require(collection.isApprovedForAll(msg.sender, address(this)), "FootballMarketPlace: Exceed User balance Limit");
		require(collection.balanceOf(msg.sender, _pieceID) >= _amount, "FootballMarketPlace: Exceed User balance Limit");
		// increase the pointer number
		offerIdPointer = offerIdPointer.add(1);
		// update market supply info
		marketSupply[_pieceID] = marketSupply[_pieceID].add(_amount);

		// lock tokens into this market contract
		collection.safeTransferFrom(msg.sender, address(this), _pieceID, _amount, "");

		// store new offer's information in the order book
		Offer memory newOffer = Offer(
			offerIdPointer,
			_token,
			_collection,
			_pieceID,
			_amount,
			_amount,
			_price, 
			msg.sender,
			OfferMethod.SELL,
			OfferStatus.PAYABLE
		);
		offers[offerIdPointer] = newOffer;

		emit OfferCreated(collection, offerIdPointer, msg.sender, _pieceID, _amount, _price);
	}

	/**
		Create an offer
		@param _collection NFT collection
		@param _pieceID nft token id
		@param _amount initial supply for market
		@param _price price for market
	 */
	function createBuyOffer(uint256 _collection, uint256 _pieceID, uint256 _amount, uint256 _price) external whenNotPaused payable {
		// check user has enough nfts
		IERC1155 collection = getCollection(_collection);

		uint256 _salePrice = _price.mul(_amount);

		require(msg.value >= _salePrice, "FootballMarketPlace: Not enough funds");

		payable(address(this)).transfer(msg.value);

		// increase the pointer number
		offerIdPointer = offerIdPointer.add(1);
		// update market supply info
		marketSupply[_pieceID] = marketSupply[_pieceID].add(_amount);

		// store new offer's information in the order book
		Offer memory newOffer = Offer(
			offerIdPointer,
			0,
			_collection,
			_pieceID,
			_amount,
			_amount,
			_price, 
			msg.sender,
			OfferMethod.BUY,
			OfferStatus.PAYABLE
		);

		offers[offerIdPointer] = newOffer;

		emit OfferCreated(collection, offerIdPointer, msg.sender, _pieceID, _amount, _price);
	}

	/**
		Create an offer
		@param _token payment token id
		@param _collection NFT collection
		@param _pieceID nft token id
		@param _amount initial supply for market
		@param _price price for market
	 */
	function createBuyOfferWithToken(uint256 _token, uint256 _collection, uint256 _pieceID, uint256 _amount, uint256 _price) external whenNotPaused {
		// check user has enough nfts
		IERC1155 collection = getCollection(_collection);
		IERC20 token = getToken(_token);

		uint256 _salePrice = _price.mul(_amount);

		require(token.balanceOf(msg.sender) >= _salePrice, "FootballMarketPlace: PaymentToken is not balance enough to purchase NFT");
		require(token.allowance(msg.sender, address(this)) >= _salePrice, "FootballMarketPlace: PaymentToken is not allowanced enough to purchase NFT");

		// transfer payment token to the seller
		token.transferFrom(msg.sender, address(this), _salePrice);

		// increase the pointer number
		offerIdPointer = offerIdPointer.add(1);
		// update market supply info
		marketSupply[_pieceID] = marketSupply[_pieceID].add(_amount);

		// store new offer's information in the order book
		Offer memory newOffer = Offer(
			offerIdPointer,
			_token,
			_collection,
			_pieceID,
			_amount,
			_amount,
			_price, 
			msg.sender,
			OfferMethod.BUY,
			OfferStatus.PAYABLE
		);

		offers[offerIdPointer] = newOffer;

		emit OfferCreated(collection, offerIdPointer, msg.sender, _pieceID, _amount, _price);
	}

	/**
	 Purchase pieces from a specific offer with token
	 @param _offerIdx offer index in offers array
	 @param _amount  amount of the piece to be purchased
	 */
	function purchaseWithToken(uint256 _offerIdx, uint256 _amount) external whenNotPaused {
		Offer memory offer = getOffer(_offerIdx);
		IERC1155 collection = getCollection(offer.collection);

		require(offer.token > 0, "FootballMarketPlace: The purchase is not allowed");
		require(offer.status == OfferStatus.PAYABLE, "FootballMarketPlace: The offer is not payable");
		require(offer.method == OfferMethod.SELL, "FootballMarketPlace: The offer is not payable");
		require(offer.from != msg.sender, "FootballMarketPlace: The seller cannot purchase");
		require(offer.supply >= _amount, "FootballMarketPlace: Not enough supply");
		// total Sale Price
		uint256 _salePrice = offer.price.mul(_amount);
		IERC20 token = getToken(offer.token);
		require(token.balanceOf(msg.sender) >= _salePrice, "FootballMarketPlace: PaymentToken is not balance enough to purchase NFT");
		require(token.allowance(msg.sender, address(this)) >= _salePrice, "FootballMarketPlace: PaymentToken is not allowanced enough to purchase NFT");

		// transfer payment token to the seller
		token.transferFrom(msg.sender, offer.from, _salePrice);

		// deduct supply of current offer
		offers[_offerIdx].supply = offer.supply.sub(_amount);
		marketSupply[offer.pieceID] = marketSupply[offer.pieceID].sub(_amount);

		if (offers[_offerIdx].supply <= 0) offers[_offerIdx].status = OfferStatus.PAID;

		// transfer piece to buyer
		collection.safeTransferFrom(address(this), msg.sender, offer.pieceID, _amount, "");

		emit PiecePurchasedWithToken(token, collection, _offerIdx, offer.pieceID, _amount, msg.sender);
	}

	/**
	 Purchase pieces from a specific offer with token
	 @param _offerIdx offer index in offers array
	 @param _amount  amount of the piece to be purchased
	 */
	function purchase(uint256 _offerIdx, uint256 _amount) public payable whenNotPaused {
		Offer memory offer = getOffer(_offerIdx);
		IERC1155 collection = getCollection(offer.collection);

		require(offer.token == 0, "FootballMarketPlace: The purchase is not allowed");
		require(offer.status == OfferStatus.PAYABLE, "FootballMarketPlace: The offer is not payable");
		require(offer.method == OfferMethod.SELL, "FootballMarketPlace: The offer is not payable");
		require(offer.from != msg.sender, "FootballMarketPlace: The seller cannot purchase");
		require(offer.supply >= _amount, "FootballMarketPlace: Not enough supply");
		// total Sale Price
		uint256 _salePrice = offer.price.mul(_amount);
		
		require(msg.value >= _salePrice, "FootballMarketPlace: Not enough balance");

		payable(offer.from).transfer(msg.value);
		// deduct supply of current offer
		offers[_offerIdx].supply = offer.supply.sub(_amount);
		marketSupply[offer.pieceID] = marketSupply[offer.pieceID].sub(_amount);

		if (offers[_offerIdx].supply <= 0) offers[_offerIdx].status = OfferStatus.PAID;

		// transfer piece to buyer
		collection.safeTransferFrom(address(this), msg.sender, offer.pieceID, _amount, "");

		emit PiecePurchased(collection, _offerIdx, offer.pieceID, _amount, msg.sender);
	}

	function sell(uint256 _offerIdx, uint256 _amount) public whenNotPaused {
		Offer memory offer = getOffer(_offerIdx);
		IERC1155 collection = getCollection(offer.collection);

		require(offer.from != msg.sender, "FootballMarketPlace: The buyer cannot sell");
		require(offer.status == OfferStatus.PAYABLE, "FootballMarketPlace: The offer is not sellable");
		require(offer.method == OfferMethod.BUY, "FootballMarketPlace: The offer is not sellable");
		require(_amount > 0 && _amount <= offer.supply, "FootballMarketPlace: The amount is not valid");
		require(collection.isApprovedForAll(msg.sender, address(this)), "FootballMarketPlace: Exceed User is not approved");
		require(collection.balanceOf(msg.sender, offer.pieceID) >= _amount, "FootballMarketPlace: Exceed User balance Limit");

		uint256 price = offer.price.mul(_amount);
		
		if (offer.token == 0) {
			payable(msg.sender).transfer(price);
		} else {
			IERC20 token = getToken(offer.token);
			token.approve(address(this), price);
			token.transferFrom(address(this), msg.sender, price);
		}

		offers[_offerIdx].supply = offer.supply.sub(_amount);

		if (offers[_offerIdx].supply <= 0) offers[_offerIdx].status = OfferStatus.PAID;

		emit PieceSell(collection, _offerIdx, offer.pieceID, _amount, msg.sender);
	}

	/**
		Close an offer and return all pieced to the seller
		@param _idx index of offer
	 */
	function closeOffer(uint256 _idx) external {
		Offer memory offer = getOffer(_idx);
		IERC1155 collection = getCollection(offer.collection);
		
		require(offer.status == OfferStatus.PAYABLE, "FootballMarketPlace: The offer is not payable");
		require(offer.from == msg.sender, "FootballMarketPlace: Only owner can close");
		
		uint256 pieceId = offer.pieceID;
		uint256 amount = offer.supply;

		if (offer.method == OfferMethod.SELL){
			// update market supply info
			marketSupply[pieceId] = marketSupply[pieceId].sub(amount);

			// refund pieces to the seller
			collection.safeTransferFrom(address(this), msg.sender, pieceId, amount, "");
		}

		if (offer.method == OfferMethod.BUY){
			uint256 price = offer.price.mul(offer.supply);
			// refund pieces to the seller
			if (offer.token == 0) {
				payable(offer.from).transfer(price);
			} else {
				IERC20 token = getToken(offer.token);
				token.approve(address(this), price);
				token.transferFrom(address(this), offer.from, price);
			}
		}

		offers[_idx].status = OfferStatus.CLOSED;
		offers[_idx].supply = 0;

		emit OfferClosed(collection, msg.sender, pieceId, _idx);
	}

	/**
		Get all offers
	 */
	function getAllOffers() public view returns(Offer[] memory) {
		uint256 count = offerIdPointer;
		Offer[] memory list = new Offer[](count);

		uint256 currentIndex = 0;

		for(uint256 i = 0; i < count; i++) {
			uint256 currentId = i + 1;
			
			Offer storage currentItem = offers[currentId];
			list[currentIndex] = currentItem;

			currentIndex += 1;
		}

		return list;
	}

	/**
		Get all offers created by the sender
	 */
	function getMyOffers() public view returns(Offer[] memory) {
		uint256 count = 0;

		for(uint256 i = 0; i <= offerIdPointer; i++) {
			if (offers[i].from == msg.sender) count++;
		}

		Offer[] memory list = new Offer[](count);

		uint256 currentIndex = 0;

		for(uint256 i = 1; i <= offerIdPointer; i++) {
			if (offers[i].from == msg.sender) {
				Offer storage currentItem = offers[i];
				list[currentIndex] = currentItem;

				currentIndex += 1;
			}
		}

		return list;
	}

	/**
		Get all offers for NFT
		@param _piceID NFT ID
	 */
	function getNFTOffers(uint256 _piceID) public view returns(Offer[] memory) {
		uint256 count = 0;

		for(uint256 i = 0; i <= offerIdPointer; i++) {
			if (offers[i].pieceID == _piceID) count++;
		}

		Offer[] memory list = new Offer[](count);

		uint256 currentIndex = 0;

		for(uint256 i = 0; i <= offerIdPointer; i++) {
			if (offers[i].pieceID == _piceID) {
				Offer storage currentItem = offers[i];
				list[currentIndex] = currentItem;

				currentIndex += 1;
			}
		}

		return list;
	}

	function getBalance() external view returns(uint256) {
		return address(this).balance;
	}

	function getTokenBalance(uint256 _token) external view returns(uint256) {
		IERC20 token = getToken(_token);

		return token.balanceOf(address(this));
	}
}