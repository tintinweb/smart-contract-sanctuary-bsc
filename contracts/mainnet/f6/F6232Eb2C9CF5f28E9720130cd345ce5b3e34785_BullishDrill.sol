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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.17;
// You don't need SafeMath library for Solidity 0.8+. 

//---------------------------------------------------------
// Imports
//---------------------------------------------------------
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "./interfaces/ITokenXBaseV3.sol";
import "./interfaces/ICakeBaker.sol";

//---------------------------------------------------------
// Contract
//---------------------------------------------------------
contract Bullish is ReentrancyGuard, Pausable, ERC1155Holder
{
	using SafeERC20 for IERC20;

	struct PoolInfo
	{
		address address_stake_token;
		address address_reward_token;
		
		uint256 harvest_interval;
		uint256 alloc_point;
		uint256 total_staked_amount;

		uint256 accu_reward_amount_per_share_e12;
		uint256 total_xnft_boost_rate_e4;
	}

	struct FeeInfo
	{
		uint256 deposit_e4; // 300 is 3%
		uint256 withdrawal_max_e4;
		uint256 withdrawal_min_e4;
		uint256 withdrawal_period; // decrease time from max to min
	}

	struct RewardInfo
	{
		uint256 start_block_id;
		uint256 last_rewarded_block_id;	
		uint256 emission_per_block;

		uint256 total_alloc_point;
		uint256 total_locked_amount;
	}

	struct UserInfo
	{
		uint256 staked_amount;
		uint256 paid_reward_amount;
		uint256 locked_reward_amount;

		uint256 last_deposit_time;
		uint256 next_harvest_time;

		uint256[] xnft_id_list; // APR booster
		uint256 xnft_boost_rate_e4; // 300 is 3%
	}

	uint256 public constant MAX_HARVEST_INTERVAL = 14 days;
	uint256 public constant MAX_DEPOSIT_FEE_E4 = 2000; // 20%
	uint256 public constant MIN_WITHDRAWAL_FEE_E4 = 0; // 0%
	uint256 public constant MAX_WITHDRAWAL_FEE_E4 = 2000; // 20%

	address public address_chick; // for tax
	address public address_operator;
	address public address_cakebaker; // for delegate farming at pancakeswap

	address public address_xnft;
	uint256[] xnft_level_prefix = [1000000, 2000000, 3000000];
	uint256[] xnft_boost_rate_e4 = [300, 600, 900];

	PoolInfo[] public pool_info; // pool_id / pool_info
	FeeInfo[] public fee_info; // pool_id / fee_info
	mapping(address => bool) public is_pool_exist;
	mapping(uint256 => mapping(address => UserInfo)) public user_info; // pool_id / user_adddress / user_info
	mapping(address => RewardInfo) public reward_info; // reward_address / reward_info

	//---------------------------------------------------------------
	// Front-end connectors
	//---------------------------------------------------------------
	event PauseCB(address indexed operator);
	event ResumeCB(address indexed operator);
	event SetChickCB(address indexed operator, address _controller);
	event SetCakeBakerCB(address indexed operator, address _controller);
	event UpdateEmissionRateCB(address indexed operator, uint256 _reward_per_block);
	event SetOperatorCB(address indexed operator, address _new_operator);
	event SetNFTBoosterCB(address indexed operator, address _address_xnft);
	event MakePoolCB(address indexed operator, uint256 new_pool_id);
	event SetPoolInfoCB(address indexed operator, uint256 _pool_id);
	
	event DepositCB(address indexed user, uint256 _pool_id, uint256 _amount);
	event WithdrawCB(address indexed user, uint256 _pool_id, uint256 _amount);
	event HarvestCB(address indexed user, uint256 _pool_id, uint256 _pending_reward_amount);
	event HarvestNotYetCB(address indexed user, uint256 _pool_id, uint256 _pending_reward_amount);

	event AddNFTBoosterCB(address indexed user, uint256 _nft_id);
	event RemoveNFTBoosterCB(address indexed user, uint256 _nft_id);
	event GetNFTBoosterListCB(address indexed user, uint256 _pool_id, uint256[] nft_id_list);
	event GetPendingRewardAmountCB(address indexed user, uint256 _pool_id, address _address_user, uint256 _pending_amount);
	
	event EmergencyWithdrawCB(address indexed user, uint256 _pool_id, uint256 _amount);
	event HandleStuckCB(address indexed user, uint256 _amount);

	//---------------------------------------------------------------
	// Modifier
	//---------------------------------------------------------------
	modifier uniquePool(address _address_lp) { require(is_pool_exist[_address_lp] == false, "uniquePool: duplicated"); _; }
	modifier onlyOperator() { require(msg.sender == address_operator, "onlyOperator: Not authorized"); _; }

	//---------------------------------------------------------------
	// Variable Interfaces
	//---------------------------------------------------------------
	function set_chick(address _new_address) external onlyOperator
	{
		require(_new_address != address(0), "set_chick: Wrong address");

		address_chick = _new_address;
		for(uint256 i=0; i<pool_info.length; i++)
		{
			ITokenXBaseV3 reward_token = ITokenXBaseV3(pool_info[i].address_reward_token);
			reward_token.set_chick(address_chick);
		}

		emit SetChickCB(msg.sender, _new_address);
	}

	function set_cakebaker(address _new_address) external onlyOperator
	{
		require(_new_address != address(0), "set_cakebaker: Wrong address");
		address_cakebaker = _new_address;
		
		emit SetCakeBakerCB(msg.sender, _new_address);
	}

	function set_operator(address _new_operator) external onlyOperator
	{
		require(_new_operator != address(0), "set_operator: Wrong address");
		address_operator = _new_operator;
		emit SetOperatorCB(msg.sender, _new_operator);
	}

	function set_xnft_address(address _address_xnft) external onlyOperator
	{
		require(_address_xnft != address(0), "set_xnft_address: Wrong address");
		address_xnft = _address_xnft;
		emit SetNFTBoosterCB(msg.sender, _address_xnft);
	}

	function get_pool_count() external view returns(uint256)
	{
		return pool_info.length;
	}

	function set_deposit_fee(uint256 _pool_id, uint16 _fee_e4) external onlyOperator
	{
		require(_pool_id < pool_info.length, "set_deposit_fee: Wrong pool id.");
		require(_fee_e4 <= MAX_DEPOSIT_FEE_E4, "set_deposit_fee: Maximun deposit fee exceeded.");

		FeeInfo storage cur_fee = fee_info[_pool_id];
		cur_fee.deposit_e4 = _fee_e4;
	}

	function set_withdrawal_fee(uint256 _pool_id, uint16 _fee_max_e4, uint16 _fee_min_e4, uint256 _period_sec) external onlyOperator
	{
		require(_pool_id < pool_info.length, "set_withdrawal_fee: Wrong pool id.");
		require(_fee_min_e4 >= MIN_WITHDRAWAL_FEE_E4, "set_withdrawal_fee: Minimun fee exceeded.");
		require(_fee_max_e4 <= MAX_WITHDRAWAL_FEE_E4, "set_withdrawal_fee: Maximun fee exceeded.");
		require(_fee_min_e4 <= _fee_max_e4, "set_withdrawal_fee: Wrong withdrawal fee");

		FeeInfo storage cur_fee = fee_info[_pool_id];
		cur_fee.withdrawal_max_e4 = _fee_max_e4;
		cur_fee.withdrawal_min_e4 = _fee_min_e4;
		cur_fee.withdrawal_period = _period_sec;
	}

	function set_alloc_point(uint256 _pool_id, uint256 _alloc_point, bool _update_all) external onlyOperator
	{
		require(_pool_id < pool_info.length, "set_alloc_point: Wrong pool id.");

		if(_update_all)
			refresh_reward_per_share();

		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];

		reward.total_alloc_point += _alloc_point;
		reward.total_alloc_point -= pool.alloc_point;

		pool.alloc_point = _alloc_point;
	}

	function set_emission_per_block(address _address_reward, uint256 _emission_per_block) external onlyOperator
	{
		require(_address_reward != address(0), "set_emission_per_block: Wrong address");

		refresh_reward_per_share();

		reward_info[_address_reward].emission_per_block = _emission_per_block;
		emit UpdateEmissionRateCB(msg.sender, _emission_per_block);
	}

	//---------------------------------------------------------------
	// External Method
	//---------------------------------------------------------------
	constructor(address _address_chick, address _address_xnft)
	{
		address_operator = msg.sender;
		
		address_chick = _address_chick;
		address_xnft = _address_xnft;
	}

	function make_reward(address _address_reward_token, uint256 _reward_mint_start_block_id, uint256 _emission_per_block) external
	{
		require(_address_reward_token != address(0), "make_pool: Wrong address");

		RewardInfo storage reward = reward_info[_address_reward_token];
		reward.emission_per_block = _emission_per_block;
		reward.start_block_id = _reward_mint_start_block_id;
		reward.last_rewarded_block_id = (block.number > _reward_mint_start_block_id)?
			block.number : _reward_mint_start_block_id;

		ITokenXBaseV3 reward_token = ITokenXBaseV3(_address_reward_token);
		reward_token.set_chick(address_chick);
	}

	function make_pool(address _address_stake_token, address _address_reward_token, uint256 _alloc_point,
		uint256 _harvest_interval, bool _refresh_reward)
		public onlyOperator uniquePool(_address_stake_token) returns(uint256)
	{
		require(_address_stake_token != address(0), "make_pool: Wrong address");
		require(_address_reward_token != address(0), "make_pool: Wrong address");
		require(_harvest_interval <= MAX_HARVEST_INTERVAL, "make_pool: Invalid harvest interval");

		if(_refresh_reward)
			refresh_reward_per_share();

		RewardInfo storage reward = reward_info[_address_reward_token];
		require(reward.last_rewarded_block_id != 0, "make_pool: Invalid reward token");
		
		is_pool_exist[_address_stake_token] = true;

		reward.total_alloc_point += _alloc_point;

		pool_info.push(PoolInfo({
			address_stake_token: _address_stake_token,
			address_reward_token: _address_reward_token,

			harvest_interval: _harvest_interval,
			alloc_point: _alloc_point,
			total_staked_amount: 0,

			accu_reward_amount_per_share_e12: 0,
			total_xnft_boost_rate_e4: 0
		}));

		fee_info.push(FeeInfo({
			deposit_e4: 0,
			withdrawal_max_e4: 0,
			withdrawal_min_e4: 0,
			withdrawal_period: 0
		}));

		uint new_pool_id = pool_info.length-1;
		emit MakePoolCB(msg.sender, new_pool_id);
		return new_pool_id;
	}

	function refresh_reward_per_share() public
	{
		for(uint256 i=0; i < pool_info.length; i++)
			_refresh_reward_per_share(pool_info[i], reward_info[pool_info[i].address_reward_token]);
	}

	function deposit_nft(uint256 _pool_id, uint256 _xnft_id) public whenNotPaused nonReentrant
	{
		require(_pool_id < pool_info.length, "deposit_nft: Wrong pool id");

		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];
		
		_refresh_reward_per_share(pool, reward);

		require(pool.address_stake_token == address_xnft, "deposit_nft: Wrong pool id for NFT");

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];

		require(_is_exist_xnft_in_list(user, _xnft_id) == false, "deposit_nft: Already using NFT");

		_collect_reward(pool, user, address_user);

		// User -> Bullish
		IERC1155 stake_token = IERC1155(pool.address_stake_token);
		stake_token.safeTransferFrom(address_user, address(this), _xnft_id, 1, "");

		// Write down deposit amount on Bullish's ledger
		user.staked_amount += 1;
		_add_xnft_to_list(user, _xnft_id);

		emit DepositCB(address_user, _pool_id, user.staked_amount);
	}

	function withdraw_nft(uint256 _pool_id, uint256 _xnft_id) public nonReentrant
	{
		require(_pool_id < pool_info.length, "withdraw_nft: Wrong pool id.");

		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];
		_refresh_reward_per_share(pool, reward);

		require(pool.address_stake_token != address_xnft, "withdraw_nft: Wrong pool id");

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];

		require(_is_exist_xnft_in_list(user, _xnft_id) == true, "withdraw_nft: No NFT found");

		if(user.next_harvest_time == 0)
			user.next_harvest_time = block.timestamp + pool.harvest_interval;

		_collect_reward(pool, user, address_user);

		// Bullish -> User
		IERC1155 stake_token = IERC1155(pool.address_stake_token);
		stake_token.safeTransferFrom(address(this), address_user, _xnft_id, 1, "");

		user.staked_amount -= 1;
		_remove_xnft_from_list(user, _xnft_id);

		emit WithdrawCB(address_user, _pool_id, user.staked_amount);
	}

	function deposit(uint256 _pool_id, uint256 _amount) public whenNotPaused nonReentrant
	{
		require(_pool_id < pool_info.length, "deposit: Wrong pool id");

		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];
		_refresh_reward_per_share(pool, reward);

		require(pool.address_stake_token != address_xnft, "deposit_nft: Wrong pool id");

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];

		_collect_reward(pool, user, address_user);

		if(_amount > 0)
		{
			// User -> Bullish
			IERC20 stake_token = IERC20(pool.address_stake_token);
			stake_token.safeTransferFrom(address_user, address(this), _amount);

			uint256 deposit_fee = 0;
			if(fee_info[_pool_id].deposit_e4 > 0)
			{
				// Bullish -> Chick for Fee
				deposit_fee = _amount * fee_info[_pool_id].deposit_e4 / 1e4;
				stake_token.safeTransfer(address_chick, deposit_fee);				
			}

			uint256 deposit_amount = _amount - deposit_fee;

			// Bullish -> CakeBaker for Deposit to delecate farming
			if(address_cakebaker != address(0))
			{
				ICakeBaker cakebaker = ICakeBaker(address_cakebaker);
				cakebaker.delegate(address(this), pool.address_stake_token, deposit_amount);
			}

			// Write down deposit amount on Bullish's ledger
			user.staked_amount += deposit_amount;
			pool.total_staked_amount += deposit_amount;
		}

		emit DepositCB(address_user, _pool_id, user.staked_amount);
	}

	function withdraw(uint256 _pool_id, uint256 _amount) public nonReentrant
	{
		require(_pool_id < pool_info.length, "withdraw: Wrong pool id.");

		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];
		_refresh_reward_per_share(pool, reward);

		require(pool.address_stake_token != address_xnft, "withdraw: Wrong pool id");

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];

		require(user.staked_amount >= _amount, "withdraw: user.staked_amount >= _amount");

		if(user.next_harvest_time == 0)
			user.next_harvest_time = block.timestamp + pool.harvest_interval;

		_collect_reward(pool, user, address_user);

		if(_amount > 0)
		{
			// CakeBaker -> Bullish
			if(address_cakebaker != address(0))
			{
				ICakeBaker cakebaker = ICakeBaker(address_cakebaker);
				cakebaker.retain(address(this), pool.address_stake_token, _amount);
			}

			IERC20 stake_token = IERC20(pool.address_stake_token);

			uint256 withdraw_fee = 0;
 			uint256 withdraw_fee_rate_e4 = _get_cur_withdraw_fee_e4(user, fee_info[_pool_id]);
			if(withdraw_fee_rate_e4 > 0)
			{
				// Bullish -> Chick for Fee
				withdraw_fee = _amount * withdraw_fee_rate_e4 / 1e4;
				stake_token.safeTransfer(address_chick, withdraw_fee);				
			}

			uint256 withdraw_amount = _amount - withdraw_fee;

			stake_token.safeTransfer(address_user, withdraw_amount);

			user.staked_amount -= _amount;
			pool.total_staked_amount -= withdraw_amount;
		}

		emit WithdrawCB(address_user, _pool_id, user.staked_amount);
	}

	function harvest(uint256 _pool_id) public whenNotPaused nonReentrant
	{
		require(_pool_id < pool_info.length, "harvest: Wrong pool id.");

		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];
		_refresh_reward_per_share(pool, reward);

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];

		uint256 pending_reward_amount = _get_pending_reward_amount(pool, reward, user);
		if(pending_reward_amount == 0)
		{
			emit HarvestNotYetCB(address_user, _pool_id, pending_reward_amount);
		}		
		else if(_can_harvest(user))
		{
			_collect_reward(pool, user, address_user);
			_safe_reward_transfer(pool, address_user, pending_reward_amount);

			user.locked_reward_amount = 0;
			reward.total_locked_amount -= pending_reward_amount;

			user.paid_reward_amount += pending_reward_amount;
			user.next_harvest_time = block.timestamp + pool.harvest_interval;
			
			emit HarvestCB(address_user, _pool_id, pending_reward_amount);
		}
		else
		{
			user.locked_reward_amount += pending_reward_amount;
			reward.total_locked_amount += pending_reward_amount;

			emit HarvestNotYetCB(address_user, _pool_id, pending_reward_amount);
		}
	}

	function add_nft_booster(uint256 _pool_id, uint256 _nft_id) external whenNotPaused
	{
		require(_pool_id < pool_info.length, "add_nft_booster: Wrong pool id.");
		
		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];
		_refresh_reward_per_share(pool, reward);

		require(pool.address_stake_token != address_xnft, "add_nft_booster: NFT pool doesn't support booster.");

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];

		require(_is_exist_xnft_in_list(user, _nft_id) == false, "add_nft_booster: Already using nft id");

		// User -> Bullish
		IERC1155 stake_token = IERC1155(address_xnft);
		stake_token.safeTransferFrom(address_user, address(this), _nft_id, 1, "");

		uint16 grade = _get_nft_grade(_nft_id);
		user.xnft_boost_rate_e4 += xnft_boost_rate_e4[grade-1];
		pool.total_xnft_boost_rate_e4 += xnft_boost_rate_e4[grade-1];

		_add_xnft_to_list(user, _nft_id);

		emit AddNFTBoosterCB(msg.sender, _nft_id);
	}

	function remove_nft_booster(uint256 _pool_id, uint256 _nft_id) external
	{
		require(_pool_id < pool_info.length, "remove_nft_booster: Wrong pool id.");

		PoolInfo storage pool = pool_info[_pool_id];
		RewardInfo storage reward = reward_info[pool.address_reward_token];
		_refresh_reward_per_share(pool, reward);

		require(pool.address_stake_token != address_xnft, "remove_nft_booster: NFT pool doesn't support booster.");

		address address_user = msg.sender;
		UserInfo storage user = user_info[_pool_id][address_user];

		require(_is_exist_xnft_in_list(user, _nft_id) == true, "remove_nft_booster: No NFT found");

		// Bullish -> User
		IERC1155 stake_token = IERC1155(address_xnft);
		stake_token.safeTransferFrom(address(this), address_user, _nft_id, 1, "");

		uint16 grade = _get_nft_grade(_nft_id);
		user.xnft_boost_rate_e4 -= xnft_boost_rate_e4[grade-1];
		pool.total_xnft_boost_rate_e4 -= xnft_boost_rate_e4[grade-1];

		_remove_xnft_from_list(user, _nft_id);

		emit RemoveNFTBoosterCB(msg.sender, _nft_id);
	}

	function get_nft_booster_list(uint256 _pool_id) external returns(uint256[] memory)
	{
		address address_user = msg.sender;
		uint256[] memory id_list = user_info[_pool_id][address_user].xnft_id_list;
		emit GetNFTBoosterListCB(msg.sender, _pool_id, id_list);
		return id_list;
	}

	function has_nft(address _address_user) external view returns(bool)
	{
		if(_address_user == address(0))
			return false;
			
		for(uint256 i=0; i<pool_info.length; i++)
		{
			UserInfo storage user = user_info[i][_address_user];
			if(user.xnft_id_list.length > 0)
				return true;
		}

		return false;
	}

	function get_pending_reward_amount(uint256 _pool_id, address _address_user) external returns(uint256)
	{
		require(_pool_id < pool_info.length, "get_pending_reward_amount: Wrong pool id.");

		PoolInfo storage pool = pool_info[_pool_id];
		UserInfo storage user = user_info[_pool_id][_address_user];
		RewardInfo storage reward = reward_info[pool.address_reward_token];

		uint256 pending_amount = _get_pending_reward_amount(pool, reward, user);

		emit GetPendingRewardAmountCB(msg.sender, _pool_id, _address_user, pending_amount);
		return pending_amount;
	}

	function emergency_withdraw(uint256 _pool_id) public nonReentrant
	{
		require(_pool_id < pool_info.length, "emergency_withdraw: Wrong pool id.");

		address address_user = msg.sender;
		PoolInfo storage pool = pool_info[_pool_id];

		require(pool.address_stake_token != address_xnft, "emergency_withdraw: NFT pool doesn't support.");

		UserInfo storage user = user_info[_pool_id][address_user];

		uint256 amount = user.staked_amount;
		user.staked_amount = 0;
		user.paid_reward_amount = 0;

		IERC20 stake_token = IERC20(pool.address_stake_token);
		stake_token.safeTransfer(address_user, amount);

		emit EmergencyWithdrawCB(address_user, _pool_id, amount);
	}

	function handle_stuck(address _address_token, uint256 _amount) public onlyOperator nonReentrant
	{
		require(_address_token != address_xnft, "handle_stuck: NFT pool doesn't support.");
		
		for(uint16 i=0; i<pool_info.length; i++)
			require(_address_token != pool_info[i].address_reward_token, "handle_stuck: Wrong token address");

		address address_user = msg.sender;

		IERC20 stake_token = IERC20(_address_token);
		stake_token.safeTransfer(address_user, _amount);
		
		emit HandleStuckCB(address_user, _amount);
	}

	function pause() external onlyOperator
	{ 
		_pause(); 
		emit PauseCB(msg.sender);
	}
	
	function resume() external onlyOperator
	{ 
		_unpause();
		emit ResumeCB(msg.sender);
	}

	//---------------------------------------------------------------
	// Internal Method
	//---------------------------------------------------------------
	function _can_harvest(UserInfo storage user) private view returns(bool)
	{
		return block.timestamp >= user.next_harvest_time;
	}

	function _safe_reward_transfer(PoolInfo storage _pool, address _to, uint256 _amount) internal
	{
		IERC20 reward_token = IERC20(_pool.address_reward_token);
		uint256 cur_reward_balance = reward_token.balanceOf(address(this));

		if(_amount > cur_reward_balance)
			reward_token.safeTransfer(_to, cur_reward_balance);
		else
			reward_token.safeTransfer(_to, _amount);
	}

	function _collect_reward(PoolInfo storage _pool, UserInfo storage _user, address _adress_user) private returns(uint256)
	{
		if(_user.staked_amount == 0)
			return 0;
		
		uint256 user_share = _user.staked_amount * _user.xnft_boost_rate_e4 / 1e4;
		uint256 accu_reward_amount = user_share * _pool.accu_reward_amount_per_share_e12 / 1e12;
		
		uint256 pending_reward_amount = accu_reward_amount - _user.paid_reward_amount;
		if(pending_reward_amount > 0)
		{
			_safe_reward_transfer(_pool, _adress_user, pending_reward_amount);
			_user.paid_reward_amount = accu_reward_amount;
		}

		return pending_reward_amount;
	}

	function _get_pending_reward_amount(PoolInfo storage _pool, RewardInfo storage _reward, UserInfo storage _user) internal returns(uint256)
	{
		uint256 elapsed_block_count = block.number - _reward.last_rewarded_block_id;
		if(elapsed_block_count == 0)
			return 0;

		_refresh_reward_per_share(_pool, _reward);
		
		uint256 accu_rps_e12 = _pool.accu_reward_amount_per_share_e12;
		if(_pool.total_staked_amount > 0 && _pool.alloc_point > 0 && elapsed_block_count > 0)
		{
			uint256 new_reward_per_pool = _get_new_rewards_amount(_pool, _reward, elapsed_block_count);
			accu_rps_e12 += new_reward_per_pool * 1e12 / _pool.total_staked_amount;
		}

		uint256 user_boosted_amount_e16 = accu_rps_e12 * _user.staked_amount * 
			(10000 + _user.xnft_boost_rate_e4) / _pool.total_staked_amount;

		uint256 pending_total = user_boosted_amount_e16 / 1e16 - _user.paid_reward_amount;
		return pending_total;
	}

	function _get_new_rewards_amount(PoolInfo storage _pool, RewardInfo storage _reward, uint256 _block_count) internal view returns(uint256)
	{
		uint256 new_reward_per_pool = _block_count * _reward.emission_per_block * _pool.alloc_point / _reward.total_alloc_point;
		return new_reward_per_pool;
	}

	function _refresh_reward_per_share(PoolInfo storage _pool, RewardInfo storage _reward) internal
	{		
		uint256 elapsed_block_count = block.number - _reward.last_rewarded_block_id;
		if(_pool.total_staked_amount == 0 || _pool.alloc_point == 0 || elapsed_block_count == 0)
			return;

		uint256 mint_reward_amount = _get_new_rewards_amount(_pool, _reward, elapsed_block_count);

		// add more rewards for the nft boosters
		mint_reward_amount += (mint_reward_amount * (10000 + _pool.total_xnft_boost_rate_e4) / 1e4);

		// Mint native token -> Bullish
		ITokenXBaseV3 reward_token = ITokenXBaseV3(_pool.address_reward_token);
		reward_token.mint(address(this), mint_reward_amount);

		_pool.accu_reward_amount_per_share_e12 += (mint_reward_amount * 1e12 / _pool.total_staked_amount);
		_reward.last_rewarded_block_id = block.number;
	}

	function _get_nft_grade(uint256 _xnft_id) internal view returns(uint16)
	{
		require(_xnft_id > xnft_level_prefix[0], "get_grade: Wrong ID");

		if(_xnft_id < xnft_level_prefix[1]) return 1;
		else if(_xnft_id < xnft_level_prefix[2]) return 2;
		else return 3;
	}

	function _is_exist_xnft_in_list(UserInfo storage _user, uint256 _nft_id) view internal returns(bool)
	{
		bool check_ownership = false;
		for(uint256 i=0; i < _user.xnft_id_list.length; i++)
		{
			if(_user.xnft_id_list[i] == _nft_id)
				check_ownership = true;
		}

		return check_ownership;
	}

	function _add_xnft_to_list(UserInfo storage user, uint256 _nft_id) internal
	{
		for(uint256 i=0; i<user.xnft_id_list.length; i++)
			require(user.xnft_id_list[i] != _nft_id, "add_nft_booster: Already using nft id");

		user.xnft_id_list.push(_nft_id);
	}

	function _remove_xnft_from_list(UserInfo storage user, uint256 _nft_id) internal
	{
		for(uint256 i=0; i<user.xnft_id_list.length; i++)
		{
			if(user.xnft_id_list[i] == _nft_id)
			{
				user.xnft_id_list[i] = user.xnft_id_list[user.xnft_id_list.length-1];
				user.xnft_id_list.pop();
				break;
			}
		}
	}

	function _min(uint256 a, uint256 b) internal pure returns (uint256)
	{
    	return a <= b ? a : b;
	}
	
	function _get_cur_withdraw_fee_e4(UserInfo storage _user, FeeInfo storage _fee) internal view returns(uint256)
	{
		uint256 time_diff = block.timestamp - _user.last_deposit_time;
		uint256 reduction_rate_e4 = _min(time_diff * 1e4 / _fee.withdrawal_period, 10000);
		uint256 final_fee_e4 = _fee.withdrawal_min_e4 + (_fee.withdrawal_max_e4-_fee.withdrawal_min_e4) * reduction_rate_e4 / 1e4;
		return final_fee_e4;
	}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Imports
//---------------------------------------------------------
import "./Bullish.sol";

//---------------------------------------------------------
// Contract
//---------------------------------------------------------
contract BullishDrill is Bullish
{
	constructor(address _address_chick, address _address_xnft) Bullish(_address_chick, _address_xnft)
	{
	}
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Interface
//---------------------------------------------------------
interface ICakeBaker
{
	function set_address_reward_vault(address _new_address) external;
	function set_operator(address _new_address) external;
	function set_controller(address _new_address) external;
	function set_pancake_masterchef(address _new_address) external;
	function add_pancake_farm(uint256 _pool_id, address _address_lp, address _address_reward_token) external returns(uint256);
	function delegate(address _address_lp_vault, address _address_lp, uint256 _amount) external returns(uint256);
	function retain(address _address_lp_vault, address _address_lp, uint256 _amount) external returns(uint256);
	function harvest() external;
	function pause() external;
	function resume() external;
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.17;

//---------------------------------------------------------
// Interface
//---------------------------------------------------------
interface ITokenXBaseV3
{
	function set_chick(address _new_chick) external;
	function toggle_block_send(address[] memory _accounts, bool _is_blocked) external;
	function toggle_block_recv(address[] memory _accounts, bool _is_blocked) external;
	function set_chick_work(bool _is_work) external;
	function mint(address _to, uint256 _amount) external;
	function burn(uint256 _amount) external;
}