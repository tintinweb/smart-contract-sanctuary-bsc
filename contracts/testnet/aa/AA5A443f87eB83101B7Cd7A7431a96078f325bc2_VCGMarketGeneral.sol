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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAuctionManager {
    function bid(
        uint256 nonce,
        uint256 amount,
        address bidder
    ) external;

    function getHighestBidder(uint256 nonce)
        external
        view
        returns (address, uint256);

    function getWithdrawAmount(uint256 nonce, address bidder)
        external
        returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMarketGeneral {
    enum Side {
        Sell,
        Bid
    }

    enum CollectionType {
        ERC721,
        ERC1155
    }

    enum OfferStatus {
        NotExist,
        Open,
        Accepted,
        Cancelled
    }

    enum OfferStrategy {
        FixedPrice,
        Auction
    }

    struct Offer {
        Side side;
        address maker; // signer of the maker order
        address collection; // collection address
        CollectionType collectionType; // collection type 721 / 1155
        uint256 tokenId; // id of the token
        uint256 amount; // amount of tokens to sell/purchase (must be 1 for ERC721, 1+ for ERC1155)
        uint256 price; // price
        OfferStrategy strategy; // strategy for trade execution (e.g., Auction, StandardSaleForFixedPrice)
        uint256 nonce; // order nonce (must be unique unless new maker order is meant to override existing one e.g., lower ask price)
        uint256 startTime; // startTime in timestamp
        uint256 endTime; // endTime in timestamp
        OfferStatus status;
    }

    struct AuctionInfo {
        bool buyOut; // check buyout for auction
        address auctionCurrency; // auction for currency only
    }

    struct BidInfo {
        address bidCurrency; // for bid only
    }

    struct TransferHandler {
        Offer offer;
        address seller;
        address buyer;
        uint256 paymentFee;
        uint256 payment;
        uint256 nftAmount;
        address currencyAddress;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRoyaltyManager {
    struct CollectionInfo {
        uint256 collectionRoyalty;
        address collectionTaker;
    }

    function getCollectionRoyaltyInfo(address collectionAddress)
        external
        view
        returns (CollectionInfo memory);

    function getMainCollectionRoyaltyInfo(address collectionAddress, uint nftId)
        external
        view
        returns (CollectionInfo memory);

    function addRoyalty(
        address collectionAddress,
        uint256 sellAmount,
        address _token,
        uint _nftId
    ) external returns (uint256);

    function withdrawRoyalty(
        address collectionAddress,
        address _token,
        uint256 _nftId
    ) external returns (uint256);

    function checkVCGNFT(address _collection) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CurrencyWhitelist is Ownable {
    modifier _validCurrency(address[] memory _tokens) {
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(currencyWhitelist[_tokens[i]], "invalid currency");
        }
        _;
    }
    mapping(address => bool) public currencyWhitelist; //token addresss => true/false

    function setCurrencyWhitelist(
        address _tokens,
        bool _values
    ) external onlyOwner {
        require(
            _tokens != address(0),
            "CurrencyWhitelist: cannot setup address 0"
        );
        currencyWhitelist[_tokens] = _values;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IMarketGeneral.sol";

contract MarketGeneralBase is IMarketGeneral, Ownable {
    using SafeERC20 for IERC20;

    mapping(uint256 => Offer) public offers; // nonce => Offer
    mapping(uint256 => AuctionInfo) public auctionInfos; // nonce => AuctionInfo
    mapping(uint256 => BidInfo) public bidInfos; // nonce => Bid Info
    mapping(uint256 => mapping(address => bool)) offerCurrencies; // offer nonce => currency address

    modifier notContract() {
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier _offerValid(uint256 nonce) {
        require(offers[nonce].status == OfferStatus.Open, "offer not active");
        require(
            block.timestamp >= offers[nonce].startTime &&
                block.timestamp <= offers[nonce].endTime,
            "offer is not start or already end"
        );
        _;
    }

    modifier _offerOwner(uint256 nonce) {
        require(offers[nonce].maker == msg.sender, "call should own the offer");
        _;
    }

    modifier _checkCurrencyValidity(address currency, uint256 amount) {
        require(
            IERC20(currency).allowance(msg.sender, address(this)) >= amount,
            "not enough allowance"
        );
        require(
            IERC20(currency).balanceOf(msg.sender) >= amount,
            "not enough balance"
        );
        _;
    }

    modifier _checkLastOffer(uint256 nonce) {
        if (offers[nonce].maker != address(0)) {
            require(
                offers[nonce].maker == msg.sender,
                "caller should own the offer"
            );
        }
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract NftBlackList is Ownable {
    modifier _nftNotBlackListed(address nftAddress) {
        require(!nftBlackList[nftAddress], "nft is blacklist from market");
        _;
    }

    mapping(address => bool) public nftBlackList; //collection addresss => true/false

    function setNftBlackList(
        address[] calldata _tokens,
        bool[] calldata _values
    ) external onlyOwner {
        require(
            _tokens.length == _values.length,
            "VCGMarketGeneral: diff length"
        );
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(
                _tokens[i] != address(0),
                "VCGMarketGeneral: cannot setup address 0"
            );
            nftBlackList[_tokens[i]] = _values[i];
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IRoyaltyManager.sol";
import "./interfaces/IAuctionManager.sol";
import "./lib/CurrencyWhiteList.sol";
import "./lib/NftBlackList.sol";
import "./lib/MarketGeneralBase.sol";

contract VCGMarketGeneral is
    MarketGeneralBase,
    CurrencyWhitelist,
    NftBlackList,
    ReentrancyGuard,
    Pausable
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public txFee;
    uint256 public creatorPortion = 7000; // creator portion 70% for royalty
    IRoyaltyManager public royaltyManager;
    IAuctionManager public auctionManager;

    event newOffer(Offer, address[]);
    event acceptedOffer(Offer, address);
    event canceledOffer(Offer);

    mapping(uint => mapping(address => bool)) public whiteListedTransact; // nonce => wallet address => can buy/no
    mapping(uint => bool) public isNeedWhiteList; // nonce => use whitelist

    constructor() {
        txFee = 250; // 2.5%
    }

    // withdraw function
    function withdrawBNB() public onlyOwner {
        require(address(this).balance > 0, "does not have any balance");
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(address _tokenAddress, uint256 _amount)
        public
        onlyOwner
    {
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    // setup contract
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setTxFee(uint256 _fee) external onlyOwner {
        require(
            _fee >= 0 && _fee <= 10000,
            "VCGMarketGeneral: must between base & max fee"
        );
        require(_fee != txFee, "VCGMarketGeneral: cannot set same fee");
        txFee = _fee;
    }

    function setRoyaltyManager(address _royaltyManager) external onlyOwner {
        require(
            _royaltyManager != address(0),
            "VCGMarketGeneral: cannot setup address 0"
        );
        require(
            IRoyaltyManager(_royaltyManager) != royaltyManager,
            "VCGMarketGeneral: cannot setup same address"
        );

        royaltyManager = IRoyaltyManager(_royaltyManager);
    }

    function setAuctionManager(address _auctionManager) external onlyOwner {
        require(
            _auctionManager != address(0),
            "VCGMarketGeneral: cannot setup address 0"
        );
        require(
            IAuctionManager(_auctionManager) != auctionManager,
            "VCGMarketGeneral: cannot setup same address"
        );

        auctionManager = IAuctionManager(_auctionManager);
    }

    function setCreatorPortion(uint _creatorPortion) external onlyOwner {
        require(
            _creatorPortion >= 0 && _creatorPortion <= 10000, 
            "max portion exceed"
        );
        creatorPortion = _creatorPortion;
    }

    // main offer
    function offer(
        Offer memory _offer,
        address[] calldata currencies,
        bool buyOut,
        address[] calldata whiteListedAddress
    )
        public
        nonReentrant
        notContract
        whenNotPaused
        _validCurrency(currencies)
        _nftNotBlackListed(_offer.collection)
        _checkLastOffer(_offer.nonce)
    {
        require(
            offers[_offer.nonce].status != OfferStatus.Cancelled &&
                offers[_offer.nonce].status != OfferStatus.Accepted,
            "VCGMarketGeneral: offer already cancel/accepted"
        );

        if (_offer.side == Side.Sell) {
            _offerSale(_offer, currencies, buyOut);
            if (whiteListedAddress.length > 0) {
                for (uint i = 0; i < whiteListedAddress.length; i++) {
                    whiteListedTransact[_offer.nonce][
                        whiteListedAddress[i]
                    ] = true;
                }
                isNeedWhiteList[_offer.nonce] = true;
            }
        } else if (_offer.side == Side.Bid) {
            _offerBid(_offer, currencies[0]);
        }

        emit newOffer(offers[_offer.nonce], currencies);
    }

    // main accept
    function accept(
        uint256 nonce,
        uint256 nftAmount,
        address currencyAddress,
        uint256 currencyAmount
    ) public nonReentrant notContract whenNotPaused _offerValid(nonce) {
        Offer memory _offer = offers[nonce];

        if (_offer.side == Side.Sell) {
            require(
                offerCurrencies[nonce][currencyAddress],
                "VCGMarketGeneral: Currency Not Supported"
            );
            if (isNeedWhiteList[nonce]) {
                require(
                    whiteListedTransact[nonce][msg.sender],
                    "not whitelisted"
                );
            }
            if (_offer.strategy == OfferStrategy.FixedPrice) {
                _fixedPriceHandler(_offer, currencyAddress, nftAmount);
            } else if (_offer.strategy == OfferStrategy.Auction) {
                _auctionHandler(_offer, currencyAddress, currencyAmount);
            }
        } else if (_offer.side == Side.Bid) {
            _acceptBid(_offer, nftAmount);
        }

        emit acceptedOffer(offers[_offer.nonce], msg.sender);
    }

    // main cancel
    function cancel(uint256 nonce)
        public
        notContract
        nonReentrant
        _offerOwner(nonce)
        whenNotPaused
    {
        require(offers[nonce].status == OfferStatus.Open, "offer not active");
        if (offers[nonce].side == Side.Sell) {
            if (offers[nonce].strategy == OfferStrategy.Auction) {
                require(
                    block.timestamp < offers[nonce].startTime,
                    "VCGMarketGeneral: Auction already start"
                );
            }
            _cancelSell(offers[nonce]);
        } else if (offers[nonce].side == Side.Bid) {
            _cancelBid(offers[nonce]);
        }

        emit canceledOffer(offers[nonce]);
    }

    // create offer sale
    function _offerSale(
        Offer memory _offer,
        address[] memory currencies,
        bool buyOut
    ) internal {
        if (_offer.strategy == OfferStrategy.Auction) {
            auctionInfos[_offer.nonce].auctionCurrency = currencies[0];
            auctionInfos[_offer.nonce].buyOut = buyOut;
        }

        if (_offer.collectionType == CollectionType.ERC721) {
            IERC721 nft = IERC721(_offer.collection);
            _validateER721(msg.sender, nft, _offer.tokenId);
            _offer.status = OfferStatus.Open;
            _offer.maker = msg.sender;
            offers[_offer.nonce] = _offer;
        }

        if (_offer.collectionType == CollectionType.ERC1155) {
            IERC1155 nft = IERC1155(_offer.collection);
            _validateERC1155(msg.sender, nft, _offer.tokenId, _offer.amount);
            _offer.status = OfferStatus.Open;
            _offer.maker = msg.sender;
            offers[_offer.nonce] = _offer;
        }

        for (uint256 i = 0; i < currencies.length; i++) {
            offerCurrencies[_offer.nonce][currencies[i]] = true;
        }
    }

    // create offer bid
    function _offerBid(Offer memory _offer, address currency) internal {
        _offer.status = OfferStatus.Open;
        uint256 previousBid = offers[_offer.nonce].amount.mul(
            offers[_offer.nonce].price
        );
        uint256 currentBid = _offer.amount.mul(_offer.price);
        offers[_offer.nonce] = _offer;
        bidInfos[_offer.nonce].bidCurrency = currency;

        if (currentBid > previousBid) {
            _transferERC(
                msg.sender,
                address(this),
                currentBid - previousBid,
                IERC20(currency)
            );
        } else if (previousBid > currentBid) {
            IERC20(currency).transfer(msg.sender, previousBid - currentBid);
        }
    }

    // cancel handler
    function _cancelSell(Offer memory _offer) internal {
        _offer.status = OfferStatus.Cancelled;
        offers[_offer.nonce] = _offer;
    }

    function _cancelBid(Offer memory _offer) internal {
        _offer.status = OfferStatus.Cancelled;
        offers[_offer.nonce] = _offer;

        IERC20(bidInfos[_offer.nonce].bidCurrency).transfer(
            msg.sender,
            _offer.amount.mul(_offer.price)
        );

        delete bidInfos[_offer.nonce];
    }

    // accept handler
    function _fixedPriceHandler(
        Offer memory _offer,
        address currencyAddress,
        uint256 nftAmount
    )
        internal
        _checkCurrencyValidity(currencyAddress, _offer.price.mul(nftAmount))
    {
        require(
            _offer.amount.sub(nftAmount) >= 0,
            "VCGMarketGeneral: more than nft amount"
        );
        uint256 royaltyFee = royaltyManager.addRoyalty(
            _offer.collection,
            _offer.price.mul(nftAmount),
            currencyAddress,
            _offer.tokenId
        );

        TransferHandler memory args = TransferHandler(
            _offer,
            _offer.maker,
            msg.sender,
            calculateFee(_offer.price.mul(nftAmount), royaltyFee),
            calculateSellerPayment(
                _offer.price.mul(nftAmount),
                calculateFee(_offer.price.mul(nftAmount), royaltyFee)
            ),
            nftAmount,
            currencyAddress
        );
        _transferHandler(args);
        _acceptOfferSell(_offer, nftAmount);
    }

    function _auctionHandler(
        Offer memory _offer,
        address currencyAddress,
        uint256 currencyAmount
    ) internal _checkCurrencyValidity(currencyAddress, currencyAmount) {
        if (
            auctionInfos[_offer.nonce].buyOut &&
            currencyAmount >= _offer.amount.mul(_offer.price)
        ) {
            uint256 royaltyFee = royaltyManager.addRoyalty(
                _offer.collection,
                _offer.amount.mul(_offer.price),
                currencyAddress,
                _offer.tokenId
            );
            uint256 makerPercentageAmount = calculateSellerPayment(
                _offer.amount.mul(_offer.price),
                calculateFee(_offer.amount.mul(_offer.price), royaltyFee)
            );

            TransferHandler memory args = TransferHandler(
                _offer,
                _offer.maker,
                msg.sender,
                calculateFee(_offer.amount.mul(_offer.price), royaltyFee),
                makerPercentageAmount,
                _offer.amount,
                currencyAddress
            );
            _transferHandler(args);
            _acceptOfferSell(_offer, _offer.amount);
            return;
        }

        auctionManager.bid(_offer.nonce, currencyAmount, msg.sender);
        _transferERC(
            msg.sender,
            address(this),
            currencyAmount,
            IERC20(currencyAddress)
        );
    }

    function _acceptOfferSell(Offer memory _offer, uint256 nftAmount) internal {
        _offer.amount = _offer.amount.sub(nftAmount);
        if (_offer.amount == 0) {
            _offer.status = OfferStatus.Accepted;
        }
        offers[_offer.nonce] = _offer;
    }

    function _acceptBid(Offer memory _offer, uint256 nftAmount) internal {
        require(
            _offer.amount >= nftAmount,
            "VCGMarketGeneral: NFT stock is not match"
        );
        uint256 royaltyFee = royaltyManager.addRoyalty(
            _offer.collection,
            _offer.price.mul(nftAmount),
            bidInfos[_offer.nonce].bidCurrency,
            _offer.tokenId
        );
        uint256 sellerPercentageAmount = calculateSellerPayment(
            _offer.price.mul(nftAmount),
            calculateFee(_offer.price.mul(nftAmount), royaltyFee)
        );

        _transferNFT(_offer, msg.sender, _offer.maker, nftAmount);

        IERC20(bidInfos[_offer.nonce].bidCurrency).transfer(
            msg.sender,
            sellerPercentageAmount
        );

        _acceptOfferBuy(_offer, nftAmount);
    }

    function _acceptOfferBuy(Offer memory _offer, uint256 nftAmount) internal {
        _offer.amount = _offer.amount.sub(nftAmount);
        if (_offer.amount == 0) {
            _offer.status = OfferStatus.Accepted;
        }
        offers[_offer.nonce] = _offer;
    }

    // auction withdrawal
    function withdrawLose(uint256 nonce) public {
        (address highestBidder, ) = auctionManager.getHighestBidder(nonce);
        require(
            highestBidder != msg.sender,
            "VCGMarketGeneral: you are highest bidder"
        );
        uint256 bidAmount = auctionManager.getWithdrawAmount(nonce, msg.sender);

        IERC20(auctionInfos[nonce].auctionCurrency).transfer(
            msg.sender,
            bidAmount
        );
    }

    function claimAuctionWinner(uint256 nonce) public {
        require(
            block.timestamp > offers[nonce].endTime,
            "VCGMarketGeneral: Auction still live"
        );
        require(
            offers[nonce].status == OfferStatus.Open,
            "VCGMarketGeneral: already claimed"
        );
        (address highestBidder, uint256 highestBid) = auctionManager
            .getHighestBidder(nonce);
        require(
            msg.sender == highestBidder,
            "VCGMarketGeneral: not auction winner"
        );

        uint256 royaltyFee = royaltyManager.addRoyalty(
            offers[nonce].collection,
            highestBid,
            auctionInfos[nonce].auctionCurrency,
            offers[nonce].tokenId
        );
        uint256 makerPercentageAmount = highestBid.sub(
            highestBid.div(10000).mul(txFee).add(royaltyFee)
        );

        _transferNFT(
            offers[nonce],
            offers[nonce].maker,
            msg.sender,
            offers[nonce].amount
        );
        IERC20(auctionInfos[nonce].auctionCurrency).transfer(
            offers[nonce].maker,
            makerPercentageAmount
        );

        _acceptOfferSell(offers[nonce], offers[nonce].amount);
    }

    function claimSellerAuction(uint256 nonce) public {
        require(
            block.timestamp > offers[nonce].endTime,
            "VCGMarketGeneral: Auction still live"
        );
        require(
            msg.sender == offers[nonce].maker,
            "VCGMarketGeneral: not offer maker"
        );
        require(
            offers[nonce].status == OfferStatus.Open,
            "VCGMarketGeneral: already claimed"
        );

        (address highestBidder, uint256 highestBid) = auctionManager
            .getHighestBidder(nonce);

        uint256 royaltyFee = royaltyManager.addRoyalty(
            offers[nonce].collection,
            highestBid,
            auctionInfos[nonce].auctionCurrency,
            offers[nonce].tokenId
        );
        uint256 makerPercentageAmount = highestBid.sub(
            highestBid.div(10000).mul(txFee).add(royaltyFee)
        );

        _transferNFT(
            offers[nonce],
            msg.sender,
            highestBidder,
            offers[nonce].amount
        );

        _transferERC(
            address(this),
            msg.sender,
            makerPercentageAmount,
            IERC20(auctionInfos[nonce].auctionCurrency)
        );
        _acceptOfferSell(offers[nonce], offers[nonce].amount);
    }

    // royalty claim
    function claimRoyalty(
        address collection,
        address _token,
        uint _tokenId
    ) external {
        if (royaltyManager.checkVCGNFT(collection)) {
            IRoyaltyManager.CollectionInfo
                memory mainCollectionInfo = royaltyManager
                    .getMainCollectionRoyaltyInfo(collection, _tokenId);
            require(
                mainCollectionInfo.collectionTaker == msg.sender,
                "VCGMarketGeneral: not colletion taker"
            );

            uint256 withdrawAmount = royaltyManager.withdrawRoyalty(
                collection,
                _token,
                _tokenId
            );

            IERC20(_token).transfer(
                msg.sender,
                withdrawAmount.mul(creatorPortion).div(10000)
            ); // creator portion is divide with marketplace contract
        } else {
            IRoyaltyManager.CollectionInfo
                memory collectionInfo = royaltyManager.getCollectionRoyaltyInfo(
                    collection
                );
            require(
                collectionInfo.collectionTaker == msg.sender,
                "VCGMarketGeneral: not colletion taker"
            );

            uint256 withdrawAmount = royaltyManager.withdrawRoyalty(
                collection,
                _token,
                _tokenId
            );

            IERC20(_token).transfer(msg.sender, withdrawAmount);
        }
    }

    // helper
    function _transferERC(
        address from,
        address to,
        uint256 amount,
        IERC20 _token
    ) internal {
        require(
            amount > 0 && to != address(0),
            "VCGMarketGeneral: wrong amount or dest on transfer"
        );
        _token.safeTransferFrom(from, to, amount);
    }

    function _transferNFT(
        Offer memory _offer,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (_offer.collectionType == CollectionType.ERC1155) {
            _validateERC1155(
                from,
                IERC1155(_offer.collection),
                _offer.tokenId,
                amount
            );
            IERC1155(_offer.collection).safeTransferFrom(
                from,
                to,
                _offer.tokenId,
                amount,
                ""
            );
        }

        if (_offer.collectionType == CollectionType.ERC721) {
            _validateER721(from, IERC721(_offer.collection), _offer.tokenId);
            IERC721(_offer.collection).safeTransferFrom(
                from,
                to,
                _offer.tokenId
            );
        }
    }

    function _validateER721(
        address owner,
        IERC721 nft,
        uint256 tokenId
    ) internal view {
        require(
            nft.ownerOf(tokenId) == owner,
            "VCGMarketGeneral: ERC721 not owner"
        );
        require(
            nft.getApproved(tokenId) == address(this) ||
                nft.isApprovedForAll(owner, address(this)),
            "VCGMarketGeneral: ERC721 not approved"
        );
    }

    function _validateERC1155(
        address owner,
        IERC1155 nft,
        uint256 tokenId,
        uint256 nftAmount
    ) internal view {
        require(
            nft.balanceOf(owner, tokenId) >= nftAmount,
            "VCGMarketGeneral: ERC1155 not enough balance"
        );
        require(
            nft.isApprovedForAll(owner, address(this)),
            "VCGMarketGeneral: ERC1155 not approved"
        );
    }

    function _transferHandler(TransferHandler memory args) internal {
        _transferNFT(args.offer, args.seller, args.buyer, args.nftAmount);

        _transferERC(
            args.buyer,
            address(this),
            args.paymentFee,
            IERC20(args.currencyAddress)
        );

        _transferERC(
            args.buyer,
            args.seller,
            args.payment,
            IERC20(args.currencyAddress)
        );
    }

    function calculateFee(uint256 payment, uint256 royalty)
        internal
        view
        returns (uint256)
    {
        return (payment.div(10000).mul(txFee)).add(royalty);
    }

    function calculateSellerPayment(uint256 payment, uint256 fee)
        internal
        pure
        returns (uint256)
    {
        return payment.sub(fee);
    }
}