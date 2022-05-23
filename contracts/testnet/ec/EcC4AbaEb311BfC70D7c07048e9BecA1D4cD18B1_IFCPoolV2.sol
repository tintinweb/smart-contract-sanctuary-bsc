// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IBiswapFarm {
    function poolLength() external view returns (uint256);

    function userInfo(uint, address) external view returns (uint256[2] memory);

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    // View function to see pending BSWs on frontend.
    function pendingBSW(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    // Deposit LP tokens to MasterChef for BSW allocation.
    function deposit(uint256 _pid, uint256 _amount) external;

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external;

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) external;

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) external;

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external;
}

pragma solidity 0.8.4;

interface IBiswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function swapFee() external view returns (uint32);
    function devFee() external view returns (uint32);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setSwapFee(uint32) external;
    function setDevFee(uint32) external;
}

pragma solidity 0.8.4;

interface IBiswapRouter02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapFeeReward() external pure returns (address);

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint swapFee) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint swapFee) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/*
 _____ _         _____               
|     |_|___ ___|   __|_ _ _ ___ ___ 
| | | | |   | . |__   | | | | .'| . |
|_|_|_|_|_|_|___|_____|_____|__,|  _|
                                |_| 
*
* MIT License
* ===========
*
* Copyright (c) 2022 MinoSwap
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../pcs/interfaces/IPancakeswapFarm.sol";
import "../pcs/interfaces/IPancakeswapRouter.sol";
import "../bsw/interfaces/IBiswapRouter02.sol";
import "../bsw/interfaces/IBiswapPair.sol";
import "../bsw/interfaces/IBiswapFarm.sol";
import "./interfaces/IStrategy.sol";

contract IFCStrat is ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    /* ========== CONSTANTS ============= */

    // Maximum slippage factor.
    uint256 public constant SLIPPAGE_FACTOR_MAX = 10000;

    /* ========== STATE VARIABLES ========== */

    // Address of the platform farm.
    address public farmContractAddress;

    // Address of the AMM Pool Router.
    address public pcsRouterAddress;

    // Address of the AMM Pool Router.
    address public bswRouterAddress;

    // Pid of the want in the platform farm.
    uint256 public pid;

    // Address of the LP token.
    address public wantAddress;

    // Address of the earned or native platform token.
    address public earnedAddress;   
    
    // Wrapped BNB.
    address public wbnbAddress;
    
    // Developer address.
    address public devAddress;

    // Address of the profit distribution contract.
    address public distributorAddress;

    // IFC pool address.
    address public ifcPoolAdress;

    // LP token address.
    address public lpToken;

    // LP token A address.
    address public tokenA;

    // LP token B address.
    address public tokenB;

    /* ========== MODIFIERS ========== */

    modifier onlyIfc() {
        require(
            msg.sender == ifcPoolAdress,
            "IFCStrat::onlyIfc: Caller is not a farms"
        );
        _;
    }

    modifier onlyGovernance() {
        require(
            (msg.sender == devAddress || msg.sender == owner()),
            "IFCStrat::onlyGovernance: Not gov"
        );
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(uint _pid, address[] memory addresses) {
        pid = _pid;
        farmContractAddress = addresses[0];
        pcsRouterAddress = addresses[1];
        bswRouterAddress = addresses[2];
        wantAddress = addresses[3];
        earnedAddress = addresses[4];
        wbnbAddress = addresses[5];
        devAddress = addresses[6];
        distributorAddress = addresses[7];
        ifcPoolAdress = addresses[8];
        lpToken = addresses[9];
        tokenA = addresses[10];
        tokenB = addresses[11];
    }

    /* ========== VIEWS ========== */

    function lpBalance() public view returns (uint) {
        return IBiswapFarm(farmContractAddress).userInfo(pid, address(this))[0];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function earn()
        external
        virtual
        nonReentrant
        whenNotPaused
    {
        _unfarm(0);
        _earn();
    }

    function deposit(uint256 _wantAmt)
        external
        virtual
        onlyIfc
        nonReentrant
        whenNotPaused
        returns (uint256 _lpToken)
    {
        IERC20(wantAddress).safeTransferFrom(
            address(msg.sender),
            address(this),
            _wantAmt
        );
        _convertWantToLp();
        _farm();
        _earn();
        return _lpToken;
    }

    function withdraw(uint256 _lpToken)
        external
        virtual
        onlyIfc
        nonReentrant
        returns (uint256)
    {
        require(_lpToken > 0, "IFCStrat::withdraw: Zero _wantAmt");
        if (_lpToken > lpBalance()) {
            _lpToken = lpBalance();
        }
        _unfarm(_lpToken);

        uint _want = IERC20(wantAddress).balanceOf(address(this));
        _convertLpToWant();
        _want = IERC20(wantAddress).balanceOf(address(this)) - _want;
        IERC20(wantAddress).safeTransfer(ifcPoolAdress, _want);
        _earn();
        return _want;
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function _convertWantToLp() internal {
        uint wantAmt = IERC20(wantAddress).balanceOf(address(this));

        if (wantAddress != tokenA) {
            address[] memory path = new address[](2);
            path[0] = wantAddress;
            path[1] = tokenA;

            _safeSwap(
                pcsRouterAddress, 
                wantAmt/2, 
                9900,
                path, 
                address(this), 
                block.timestamp + 60
            );
        }
        if (wantAddress != tokenB) {
            address[] memory path = new address[](2);
            path[0] = wantAddress;
            path[1] = tokenB;
            
            _safeSwap(
                pcsRouterAddress, 
                wantAmt/2, 
                9900, 
                path,
                address(this), 
                block.timestamp + 60
            );
        }

        uint _tokenA = IERC20(tokenA).balanceOf(address(this));
        uint _tokenB = IERC20(tokenB).balanceOf(address(this));
        IERC20(tokenA).safeIncreaseAllowance(bswRouterAddress, _tokenA);
        IERC20(tokenB).safeIncreaseAllowance(bswRouterAddress, _tokenB);
        IBiswapRouter02(bswRouterAddress).addLiquidity(
            tokenA, 
            tokenB, 
            _tokenA, 
            _tokenB, 
            0, 
            0, 
            address(this), 
            block.timestamp + 60
        );
    }

    function _convertLpToWant() internal {
        uint _lpToken = IERC20(lpToken).balanceOf(address(this));
        IERC20(lpToken).safeIncreaseAllowance(bswRouterAddress, _lpToken);
        IBiswapRouter02(bswRouterAddress).removeLiquidity(
            tokenA,
            tokenB,
            _lpToken,
            0,
            0,
            address(this),
            block.timestamp + 60
        );

        if (wantAddress != tokenA) {
            address[] memory path = new address[](2);
            path[0] = tokenA;
            path[1] = wantAddress;
            uint _tokenA = IERC20(tokenA).balanceOf(address(this));

            _safeSwap(
                pcsRouterAddress, 
                _tokenA, 
                9900,
                path, 
                address(this), 
                block.timestamp + 60
            );
        }
        if (wantAddress != tokenB) {
            address[] memory path = new address[](2);
            path[0] = tokenB;
            path[1] = wantAddress;
            uint _tokenB = IERC20(tokenB).balanceOf(address(this));
            
            _safeSwap(
                pcsRouterAddress, 
                _tokenB, 
                9900, 
                path,
                address(this), 
                block.timestamp + 60
            );
        }
    }

    function _farm() internal virtual {
        uint256 _lpToken = IERC20(lpToken).balanceOf(address(this));
        IERC20(lpToken).safeIncreaseAllowance(farmContractAddress, _lpToken);
        IBiswapFarm(farmContractAddress).deposit(pid, _lpToken);
    }

    function _unfarm(uint256 _wantAmt) internal virtual {
        IBiswapFarm(farmContractAddress).withdraw(pid, _wantAmt);
    }

    function _earn() internal {
        _collect();
        _farm();
    }

    function _collect() internal virtual {
        uint256 earnedAmt = IERC20(earnedAddress).balanceOf(address(this));
        if (earnedAmt > 0 && distributorAddress != address(0)) {
            IERC20(earnedAddress).transfer(distributorAddress, earnedAmt);
        }
    }

    /* ========== UTILITY FUNCTIONS ========== */

    function _safeSwap(
        address _uniRouterAddress,
        uint256 _amountIn,
        uint256 _slippageFactor,
        address[] memory _path,
        address _to,
        uint256 _deadline
    ) internal virtual {
        uint256 amountOut;
        try IPancakeRouter02(_uniRouterAddress)
            .getAmountsOut(_amountIn, _path) 
            returns (uint256[] memory amounts) {
            amountOut = amounts[amounts.length - 1];
            if (amountOut == 0) return;
        } catch {
            return;
        }

        IERC20(_path[0]).safeIncreaseAllowance(_uniRouterAddress, _amountIn);

        IPancakeRouter02(_uniRouterAddress)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * _slippageFactor / SLIPPAGE_FACTOR_MAX,
            _path,
            _to,
            _deadline
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/*
 _____ _         _____               
|     |_|___ ___|   __|_ _ _ ___ ___ 
| | | | |   | . |__   | | | | .'| . |
|_|_|_|_|_|_|___|_____|_____|__,|  _|
                                |_| 
*
* MIT License
* ===========
*
* Copyright (c) 2022 MinoSwap
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../interfaces/IIFC.sol";
import "../IFCStrat.sol";
import "../../pcs/interfaces/IPancakeswapRouter.sol";

interface IMinoFarm {
    function ifcWithdraw() external;
}

interface IVestingMaster {
    function lockedPeriodAmount() external view returns (uint256);
    function lock(address, uint256) external;
}

contract IFCPoolV2 is Ownable, ERC1155Holder {
    using SafeERC20 for IERC20;
    enum Collection { DIAMOND, BTC, GOLD, ETH, SILVER, BNB }
    
    struct CollectionInfo {
        uint price;
        uint baseShares;
    }

    struct UserInfo {
        uint rewardDebt;
        uint withdrawalDebt;
    }
    /* ========== CONSTANTS ============= */

    // IFC unlock time.
    uint public UNLOCK_TIME = 1665532800;

    // Withdrawal limit to minimize loss due to slippage.
    uint public constant WITHDRAWAL_LIMIT = 400e18;

    // Maximum slippage for swaps
    uint public constant SLIPPAGE_FACTOR_MAX = 10000;

    /* ========== STATE VARIABLES ========== */
    
    // IFC Token 
    IIFC public ifc;
    
    // Want token
    IERC20 public want;
    
    // Mino token
    IERC20 public mino;
    
    // Address of MinoFarm
    address public minoFarm;

    // Vesting master contract.
    IVestingMaster public vestingMaster;
    
    // Last block reward was distributed
    uint public lastRewardBlock;

    // The accumulated rewards per share
    uint public accRewardPerShare;
    
    // Mino distribution per block
    uint public minoPerBlock;
    
    // Address of the IFC strategy
    address public ifcStrategy;

    // Info of every IFC collection
    CollectionInfo[6] public collections;

    // Total number of shares.
    uint public totalShares;

    // Total amount of want deposited.
    uint public totalWant;

    // Total amount of withdrawal debt accumulated;
    uint public totalWithdrawalDebt;

    // Info of every IFC member
    mapping (address => UserInfo) public userInfo;

    // Whitelisted claimables
    mapping (address => mapping(Collection => uint)) public claimables;
    
    // @todo remove
    function updateUnlockTime(uint time) external {
        UNLOCK_TIME = time;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _ifc,
        address _mino, 
        address _want,
        uint _minoPerBlock
    ) {
        ifc = IIFC(_ifc);
        mino = IERC20(_mino);
        want = IERC20(_want);
        minoPerBlock = _minoPerBlock;

        collections[uint(Collection.DIAMOND)] = CollectionInfo(100_000e18, 100_000e18);
        collections[uint(Collection.BTC)]     = CollectionInfo(0, 100_000e18);
        collections[uint(Collection.GOLD)]    = CollectionInfo(50_000e18, 50_000e18);
        collections[uint(Collection.ETH)]     = CollectionInfo(0, 50_000e18);
        collections[uint(Collection.SILVER)]  = CollectionInfo(10_000e18, 10_000e18);
        collections[uint(Collection.BNB)]     = CollectionInfo(0, 10_000e18);
    }

    /* ========== VIEWS ========== */

    function pendingClaimable() external view returns (uint pending) {
        if (minoFarm != address(0)) {
            uint shares = getHolderShares(msg.sender);
            uint minoReward = minoPerBlock * (block.number - lastRewardBlock);
            uint _accRewardPerShare = accRewardPerShare + minoReward * 1e12 / totalShares;
            uint accPending = shares * _accRewardPerShare / 1e12;
            if (accPending > userInfo[msg.sender].rewardDebt) {
                pending = accPending - userInfo[msg.sender].rewardDebt;
            }

            if(pending > mino.balanceOf(address(this))) {
                pending = mino.balanceOf(address(this));
            }
        }
    }

    function getHolderShares(address holder) public view returns (uint shares) {
        address[] memory addresses = new address[](6);
        uint[] memory ids = new uint[](6);
        for (uint256 i = 0; i < 6; i++) {
            addresses[i] = holder;
            ids[i] = i;
        }
        uint[] memory balances = ifc.balanceOfBatch(addresses, ids);

        for (uint256 i = 0; i < 6; i++) {
            shares += collections[i].baseShares * balances[i];
        }
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
 
    function updateRewards() public {
        if (totalShares == 0) {
            lastRewardBlock = block.number;
            return;
        }

        if (block.number > lastRewardBlock && minoFarm != address(0)) {
            IMinoFarm(minoFarm).ifcWithdraw();
            uint minoReward = minoPerBlock * (block.number - lastRewardBlock);
            accRewardPerShare += minoReward * 1e12 / totalShares;
            lastRewardBlock = block.number;
        }
    }

    function claim() public {
        updateRewards();
        uint accClaimable = getHolderShares(msg.sender) * accRewardPerShare / 1e12;
        uint claimable;
        if (accClaimable > userInfo[msg.sender].rewardDebt) {
            claimable = accClaimable - userInfo[msg.sender].rewardDebt;
        } 
        if(claimable > mino.balanceOf(address(this))) {
            claimable = mino.balanceOf(address(this));
        }
        userInfo[msg.sender].rewardDebt += claimable;
        safeMinoTransfer(msg.sender, claimable);
    }

    function purchase(uint id, uint units) external {
        CollectionInfo storage _collection = collections[id];
        require(_collection.price > 0, "IFCPool::purchase: Invalid collection");

        updateRewards();
        uint userShares = getHolderShares(msg.sender);
        if(userShares > 0) {
            uint accPending = userShares * accRewardPerShare / 1e12;
            uint pending;
            if (accPending > userInfo[msg.sender].rewardDebt) {
                pending = accPending - userInfo[msg.sender].rewardDebt;
            }
            if (pending > 0) {
                uint locked;
                if (address(vestingMaster) != address(0)) {
                    locked = pending / (vestingMaster.lockedPeriodAmount() + 1) * vestingMaster.lockedPeriodAmount();
                }
                safeMinoTransfer(msg.sender, pending - locked);
                if (locked > 0) {
                    uint actualAmount = safeMinoTransfer(
                        address(vestingMaster),
                        locked
                    );
                    vestingMaster.lock(msg.sender, actualAmount);
                }
            }
        }

        uint amount = _collection.price * units;
        want.safeTransferFrom(msg.sender, address(this), amount);
        ifc.safeTransferFrom(address(this), msg.sender, uint(id), units, "");
        
        totalShares += _collection.baseShares * units;
        totalWant += amount;

        userShares = getHolderShares(msg.sender);
        userInfo[msg.sender].rewardDebt = userShares * accRewardPerShare / 1e12;
    }

    function claimIfc(Collection id) public {
        uint claimable = claimables[msg.sender][id];
        require(claimable > 0, "IFCPool::claimIfc: No claimables");

        updateRewards();
        uint userShares = getHolderShares(msg.sender);
        if(userShares > 0) {
            uint pending;
            uint accPending = userShares * accRewardPerShare / 1e12;
            if (accPending > userInfo[msg.sender].rewardDebt) {
                pending = accPending - userInfo[msg.sender].rewardDebt;
            }
            if (pending > 0) {
                uint locked;
                if (address(vestingMaster) != address(0)) {
                    locked = pending / (vestingMaster.lockedPeriodAmount() + 1) * vestingMaster.lockedPeriodAmount();
                }
                safeMinoTransfer(msg.sender, pending - locked);
                if (locked > 0) {
                    uint actualAmount = safeMinoTransfer(
                        address(vestingMaster),
                        locked
                    );
                    vestingMaster.lock(msg.sender, actualAmount);
                }
            }
        }
        ifc.safeTransferFrom(address(this), msg.sender, uint(id), claimable, "");
        claimables[msg.sender][id] = 0;

        totalShares += collections[uint(id)].baseShares * claimable;
        userShares = getHolderShares(msg.sender);
        userInfo[msg.sender].rewardDebt = userShares * accRewardPerShare / 1e12;
    }

    function sell(uint id, uint units) external {
        require(UNLOCK_TIME <= block.timestamp, "IFCPool::sell: Still locked");
        require(want.balanceOf(address(this)) == 0, "IFCPool::sell: Want not farmed");
        updateRewards();
        uint userShares = getHolderShares(msg.sender);
        uint pending;
        if(userShares > 0) {
            uint accPending = userShares * accRewardPerShare / 1e12;
            if (accPending > userInfo[msg.sender].rewardDebt) {
                pending = accPending - userInfo[msg.sender].rewardDebt;
            }
            if (pending > 0) {
                uint locked;
                if (address(vestingMaster) != address(0)) {
                    locked = pending / (vestingMaster.lockedPeriodAmount() + 1) * vestingMaster.lockedPeriodAmount();
                }
                safeMinoTransfer(msg.sender, pending - locked);
                if (locked > 0) {
                    uint actualAmount = safeMinoTransfer(
                        address(vestingMaster),
                        locked
                    );
                    vestingMaster.lock(msg.sender, actualAmount);
                }
            }
        }
        ifc.safeTransferFrom(msg.sender, address(this), id, units, "");

        if (collections[id].price > 0) {
            uint shares = collections[id].baseShares * units;
 
            uint _withdrawalDebt = (IFCStrat(ifcStrategy).lpBalance() - totalWithdrawalDebt) * shares / totalWant;
            userInfo[msg.sender].withdrawalDebt += _withdrawalDebt;
            totalWant -= collections[id].price * units;
            totalWithdrawalDebt += _withdrawalDebt;
        }

        totalShares -= collections[id].baseShares * units;
        userShares = getHolderShares(msg.sender);
        userInfo[msg.sender].rewardDebt = userShares * accRewardPerShare / 1e12;
    }

    function safeWithdrawDebt() external {
        UserInfo storage _userInfo = userInfo[msg.sender];
        require(_userInfo.withdrawalDebt > 0, "IFCPool::safeWithdrawDebt: User has no withdrawal debt");

        uint amount = WITHDRAWAL_LIMIT;
        if (_userInfo.withdrawalDebt < WITHDRAWAL_LIMIT) {
            amount = _userInfo.withdrawalDebt;
        }
        _userInfo.withdrawalDebt -= amount;
        totalWithdrawalDebt -= amount;
        uint _want = IFCStrat(ifcStrategy).withdraw(amount);
        want.safeTransfer(msg.sender, _want);
    }

    function withdrawDebt() external {
        UserInfo storage _userInfo = userInfo[msg.sender];
        require(_userInfo.withdrawalDebt > 0, "IFCPool::withdrawDebt: User has no withdrawal debt");

        uint amount = _userInfo.withdrawalDebt;
        _userInfo.withdrawalDebt = 0;
        totalWithdrawalDebt -= amount;
        uint _want = IFCStrat(ifcStrategy).withdraw(amount);
        want.safeTransfer(msg.sender, _want);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setIfcStrategy(address _ifcStrategy) external onlyOwner {
        require(ifcStrategy == address(0), "IFCPoolV2:setIfcStrategy: IfcStrat already set");
        ifcStrategy = _ifcStrategy;
    }

    function setVestingMaster(address _vestingMaster) external onlyOwner {
        require(address(vestingMaster) != address(0), "IFCPoolV2:setVestingMaster: VM already set");
        vestingMaster = IVestingMaster(_vestingMaster);
    }

    function setMinoFarm(address _minoFarm) external onlyOwner {
        minoFarm = _minoFarm;
        lastRewardBlock = block.number;
    }

    function setMinoPerBlock(uint _minoPerBlock) external onlyOwner {
        minoPerBlock = _minoPerBlock;
    }

    function enterStaking(uint _wantAmt) external onlyOwner {
        want.safeIncreaseAllowance(ifcStrategy, _wantAmt);
        IFCStrat(ifcStrategy).deposit(_wantAmt);
    }

    function addClaimable(address claimableAddress, Collection id, uint units) external onlyOwner {
        require(uint(id) % 2 != 0, "IFCPoolV2::addClaimable: Invalid claimable");
        claimables[claimableAddress][id] = units;
    }

    function sendRewardBeforeTransfer(address _from, address _to) external {
        require(msg.sender == address(ifc), "Not IFC");
        updateRewards();
        uint fromShares = getHolderShares(_from);
        uint fromPending = fromShares * accRewardPerShare / 1e12 - userInfo[_from].rewardDebt;
        safeMinoTransfer(_from, fromPending);

        uint toShares = getHolderShares(_to);
        uint toPending = toShares * accRewardPerShare / 1e12 - userInfo[_to].rewardDebt;
        safeMinoTransfer(_to, toPending);
    }

    function updateRewardDebtAfterTransfer(address _from, address _to) external {
        require(msg.sender == address(ifc), "Not IFC");
        uint fromShares = getHolderShares(_from);
        userInfo[_from].rewardDebt = fromShares * accRewardPerShare / 1e12;

        uint toShares = getHolderShares(_to);
        userInfo[_to].rewardDebt = toShares * accRewardPerShare / 1e12;
    }

    /* ========== UTILITY FUNCTIONS ========== */

    function safeMinoTransfer(address _to, uint256 _amount)
        internal
        returns (uint256)
    {
        uint256 balance = mino.balanceOf(address(this));
        if (_amount > balance) {
            _amount = balance;
        }

        require(
            mino.transfer(_to, _amount),
            "IFCPoolV2::safeMinoTransfer: Transfer failed"
        );
        return _amount;
    }
}

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IIFC is IERC1155 {
    function maxSupply(uint256 id) external view returns (uint256);

    function totalSupply(uint256 id) external view returns (uint256);
    
    function exists(uint256 id) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/*
   __  ____           ____               
  /  |/  (_)__  ___  / __/    _____ ____ 
 / /|_/ / / _ \/ _ \_\ \| |/|/ / _ `/ _ \
/_/  /_/_/_//_/\___/___/|__,__/\_,_/ .__/
                                  /_/           
*
* MIT License
* ===========
*
* Copyright (c) 2022 MinoSwap
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

 */

interface IStrategy {

   /* ========== EVENTS ========== */

    event SetDevAddress(address indexed user, address devAddress);
    event SetDistributorAddress(address indexed user, address distributorAddress);
    event SetBuyBackRate(address indexed user, uint256 buyBackRate);
    
    /* ========== VIEWS ========== */
    
    function sharesTotal() external view returns (uint256);


    /* ========== MUTATIVE FUNCTIONS ========== */
    
    function earn() external;

    /* ========== RESTRICTED FUNCTIONS ========== */

    function deposit(uint256 _wantAmt)
        external
        returns (uint256);
        
    function withdraw(uint256 _wantAmt)
        external
        returns (uint256);

    function pause() external;

    function unpause() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IPancakeswapFarm {
    function poolLength() external view returns (uint256);

    function userInfo() external view returns (uint256);

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

    // View function to see pending CAKEs on frontend.
    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) external;

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external;

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) external;

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) external;

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}