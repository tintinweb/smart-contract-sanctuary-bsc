/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

// File: StakeUpFarm.sol

/*
 *  ______     ______   ______     __  __     ______     __  __     ______      ______   ______     ______     __    __
 * /\  ___\   /\__  _\ /\  __ \   /\ \/ /    /\  ___\   /\ \/\ \   /\  == \    /\  ___\ /\  __ \   /\  == \   /\ "-./  \
 * \ \___  \  \/_/\ \/ \ \  __ \  \ \  _"-.  \ \  __\   \ \ \_\ \  \ \  _-/    \ \  __\ \ \  __ \  \ \  __<   \ \ \-./\ \
 *  \/\_____\    \ \_\  \ \_\ \_\  \ \_\ \_\  \ \_____\  \ \_____\  \ \_\       \ \_\    \ \_\ \_\  \ \_\ \_\  \ \_\ \ \_\
 *   \/_____/     \/_/   \/_/\/_/   \/_/\/_/   \/_____/   \/_____/   \/_/        \/_/     \/_/\/_/   \/_/ /_/   \/_/  \/_/
 *
 *  ╔═══════════════════════════════════════╗
 *  ║ - StakeUp Farm - $SUF                 ║
 *  ║ -> https://stakeup.farm <-            ║
 *  ║ -> https://t.me/stakeupfarm <-        ║
 *  ║ -> https://discord.gg/yCSVMGeS2f <-   ║
 *  ║ -> https://twitter.com/stakeupfarm <- ║
 *  ╚═══════════════════════════════════════╝
 *
 */

/*    SPDX-License-Identifier: MIT    */
pragma solidity 0.8.17;






contract StakeUpFarm is Ownable, ReentrancyGuard {
    // Tokens
    using SafeERC20 for IERC20;
    IERC20 public BUSD = IERC20(0x0d3B278914458Be098A78a2423cd8842C62a2A50); // $BUSD
    IERC20 public SUF = IERC20(0x84f1D5076545244527249A1D431bad5Ffb970939); // $SUF
    IERC721 public NFTx125 =
        IERC721(0x03936503F8075d333602A4d6D614DCd16b23d611); // $NFT @todo: change to NFT
    IERC721 public NFTx150 =
        IERC721(0xBE8c72c2fE47C3406fAC40B74eeD26e19287B876); // $NFT @todo: change to NFT
    IERC721 public NFTx175 =
        IERC721(0x7882DD2Fcb283258c6b5eED92E05E6343C0738d2); // $NFT @todo: change to NFT
    IERC721 public NFTx2 = IERC721(0x444d3C44790b88A5873d4AF4c1b4aC229C3ec34E); // $NFT @todo: change to NFT
    uint256 internal NFTx125ID;
    uint256 internal NFTx150ID;
    uint256 internal NFTx175ID;
    uint256 internal NFTx2ID;

    // Configurables
    uint256 public BUSDdaily = 6; // Daily reward of 6%
    uint256 public SUFdaily = 12; // Daily reward of 12%
    uint256 public minDeposit = 25 ether; // 25 BUSD
    uint256 public maxDeposit = 10000 ether; // 10,000 BUSD
    uint256 public ID;

    // Fees
    uint256 public referralFee = 6;
    uint256 public depositFee = 4;
    uint256 public sellFee = 4;
    address public feeWallet = 0xb8e76417cB45ACce973dDD923E014424e261735C; // @todo: change to real wallet

    // Chart settings
    mapping(uint256 => uint256) internal day;
    mapping(uint256 => uint256) internal priceOnDay;
    uint256 internal currentDay;

    struct investorDetails {
        address investorAddress;
        uint256 invested;
        uint256 sellLimit;
        uint256 sellLastTime;
        uint256 availableReferralToWithdraw;
        uint256 totalReferral;
        uint256 numberOfReferrals;
        uint256 staked;
        uint256 NFTx;
        bool boughtNFT;
    }

    struct claimDailyBUSD {
        address investorAddress;
        uint256 startTime;
    }

    struct claimDailySUF {
        address investorAddress;
        uint256 startTime;
    }

    mapping(address => investorDetails) public investor;
    mapping(address => claimDailyBUSD) public claimTimeBUSD;
    mapping(address => claimDailySUF) public claimTimeSUF;
    mapping(uint256 => address) public investorID;

    function mintSUF(address _referral, uint256 _amount) public nonReentrant {
        require(
            _amount >= minDeposit && _amount <= maxDeposit,
            "Deposit amount is not in range"
        );
        require(
            BUSD.allowance(msg.sender, address(this)) >= _amount,
            "Not enough BUSD allowed"
        );
        require(
            BUSD.balanceOf(msg.sender) >= _amount,
            "Not enough BUSD balance"
        );
        uint256 _referralFee;
        if (
            _referral != address(0) &&
            _referral != msg.sender &&
            investor[_referral].invested > 50 ether
        ) {
            _referralFee = (_amount * referralFee) / 100;
            investor[_referral].availableReferralToWithdraw += _referralFee;
            investor[_referral].totalReferral += _referralFee;
            investor[_referral].numberOfReferrals++;
        }
        uint256 _depositFee = (_amount * depositFee) / 100;
        investor[msg.sender].invested += _amount - _depositFee;
        BUSD.safeTransferFrom(msg.sender, address(this), _amount - _depositFee);
        BUSD.safeTransferFrom(msg.sender, feeWallet, _depositFee);
        SUF.safeIncreaseAllowance(address(this), ~uint256(0));
        if (claimTimeBUSD[msg.sender].startTime == 0) {
            claimTimeBUSD[msg.sender].startTime = block.timestamp;
        }
        investorID[ID] = msg.sender;
        ID++;
    }

    function stakeSUF(uint256 _amount) public nonReentrant {
        require(
            SUF.allowance(msg.sender, address(this)) >= _amount,
            "Not enough SUF allowed"
        );
        require(SUF.balanceOf(msg.sender) >= _amount, "Not enough SUF balance");
        investor[msg.sender].sellLimit = (_amount * 10) / 100;
        SUF.safeTransferFrom(msg.sender, address(this), _amount);
        investor[msg.sender].staked += _amount;
        if (claimTimeSUF[msg.sender].startTime == 0) {
            claimTimeSUF[msg.sender].startTime = block.timestamp;
        }
    }

    function buyNFT(uint256 _option) public nonReentrant {
        require(
            checkNFT(msg.sender) == false,
            "You have already bought an NFT"
        );

        require(
            BUSD.allowance(msg.sender, address(this)) >= 125 ether,
            "Not enough BUSD allowed"
        );
        require(
            BUSD.balanceOf(msg.sender) >= 125 ether,
            "Not enough BUSD balance"
        );
        require(
            _option == 1 || _option == 2 || _option == 3 || _option == 4,
            "Invalid option"
        );

        if (_option == 1) {
            BUSD.safeTransferFrom(msg.sender, address(this), 125 ether);
            NFTx125.safeTransferFrom(address(this), msg.sender, NFTx125ID); //@todo: change to real ID
            investor[msg.sender].NFTx = 125;
            NFTx125ID++;
        } else if (_option == 2) {
            BUSD.safeTransferFrom(msg.sender, address(this), 175 ether);
            NFTx150.safeTransferFrom(address(this), msg.sender, NFTx150ID); //@todo: change to real ID
            investor[msg.sender].NFTx = 150;
            NFTx150ID++;
        } else if (_option == 3) {
            BUSD.safeTransferFrom(msg.sender, address(this), 250 ether);
            NFTx175.safeTransferFrom(address(this), msg.sender, NFTx175ID); //@todo: change to real ID
            investor[msg.sender].NFTx = 175;
            NFTx175ID++;
        } else if (_option == 4) {
            BUSD.safeTransferFrom(msg.sender, address(this), 375 ether);
            NFTx2.safeTransferFrom(address(this), msg.sender, NFTx2ID); //@todo: change to real ID
            investor[msg.sender].NFTx = 200;
            NFTx2ID++;
        }
        investor[msg.sender].boughtNFT = true;
    }

    function sellSUF(uint256 _amount) public nonReentrant {
        require(
            SUF.allowance(msg.sender, address(this)) >= _amount,
            "Not enough SUF allowed"
        );
        require(SUF.balanceOf(msg.sender) >= _amount, "Not enough SUF balance");
        require(
            _amount <= investor[msg.sender].sellLimit,
            "Sell amount is not in range"
        );
        require(
            investor[msg.sender].sellLastTime + 1 days <= block.timestamp,
            "Sell time not passed"
        );
        investor[msg.sender].sellLastTime = block.timestamp;
        SUF.safeTransferFrom(msg.sender, address(this), _amount);
        BUSD.safeTransferFrom(
            address(this),
            msg.sender,
            ((_amount * sellFee) / 100) * getSUFPrice()
        );
        BUSD.safeTransferFrom(
            address(this),
            feeWallet,
            ((_amount * (100 - sellFee)) / 100) * getSUFPrice()
        );
    }

    function claimDailyBUSDRewards() public nonReentrant {
        SUF.safeTransferFrom(
            address(this),
            msg.sender,
            userRewardBUSD(msg.sender)
        );
        claimTimeBUSD[msg.sender] = claimDailyBUSD(msg.sender, block.timestamp);
    }

    function claimDailySUFRewards() public nonReentrant {
        SUF.safeTransferFrom(
            address(this),
            msg.sender,
            userRewardSUF(msg.sender)
        );
        claimTimeSUF[msg.sender] = claimDailySUF(msg.sender, block.timestamp);
    }

    function withdrawReferral() public nonReentrant {
        require(
            investor[msg.sender].availableReferralToWithdraw > 0,
            "No referral to withdraw"
        );
        BUSD.safeTransfer(
            msg.sender,
            investor[msg.sender].availableReferralToWithdraw
        );
        investor[msg.sender].availableReferralToWithdraw = 0;
    }

    function userRewardBUSD(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 userInvestment = investor[_userAddress].invested;
        uint256 secondsPassed = block.timestamp -
            claimTimeBUSD[_userAddress].startTime;
        return
            checkBoost(
                _userAddress,
                ((BUSDdaily / 100) / 86400) * secondsPassed * userInvestment
            );
    }

    function burnSUF(uint256 _amount) public nonReentrant {
        require(
            SUF.allowance(msg.sender, address(this)) >= _amount,
            "Not enough SUF allowed"
        );
        require(SUF.balanceOf(msg.sender) >= _amount, "Not enough SUF balance");
        SUF.safeTransferFrom(msg.sender, address(this), _amount);
        SUF.safeTransferFrom(address(this), address(0), _amount);
    }

    function unstakeSUF(uint256 _amount) public nonReentrant {
        require(
            SUF.allowance(msg.sender, address(this)) >= _amount,
            "Not enough SUF allowed"
        );
        require(SUF.balanceOf(msg.sender) >= _amount, "Not enough SUF balance");
        require(
            investor[msg.sender].staked >= _amount,
            "Not enough SUF staked"
        );

        SUF.safeTransferFrom(address(this), msg.sender, (_amount * 90) / 100);
        burnSUF((_amount * 10) / 100);
        investor[msg.sender].staked -= _amount;
    }

    function userRewardSUF(address _userAddress) public view returns (uint256) {
        uint256 userInvestment = investor[_userAddress].staked;
        uint256 secondsPassed = block.timestamp -
            claimTimeSUF[_userAddress].startTime;
        return
            checkBoost(
                _userAddress,
                ((SUFdaily / 100) / 86400) * secondsPassed * userInvestment
            );
    }

    function getSUFPrice() public view returns (uint256) {
        uint256 d1 = BUSD.balanceOf(address(this)) * 1 ether;
        uint256 d2 = SUF.balanceOf(address(this)) + 1;
        return d1 / d2;
    }

    function BUSDtoSUF(uint256 _amount) public view returns (uint256) {
        uint256 SUFPrice = getSUFPrice();
        return _amount / SUFPrice;
    }

    function SUFToBUSD(uint256 _amount) public view returns (uint256) {
        uint256 SUFPrice = getSUFPrice();
        return _amount * SUFPrice;
    }

    function SUFToBUSDBalance(address user) public view returns (uint256) {
        uint256 SUFPrice = getSUFPrice();
        return SUF.balanceOf(user) * SUFPrice;
    }

    function changeReferralReward(uint256 _newReferralFee) public onlyOwner {
        referralFee = _newReferralFee;
    }

    function getNumberOfReferrals(address user) public view returns (uint256) {
        return investor[user].numberOfReferrals;
    }

    function getContractBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getAvailableToWithdrawReferral(address user)
        public
        view
        returns (uint256)
    {
        return investor[user].availableReferralToWithdraw;
    }

    function getBUSDAPR() public view returns (uint256) {
        return BUSDdaily * 365;
    }

    function getSUFAPR() public view returns (uint256) {
        return SUFdaily * 365;
    }

    function getNumberOfInvestors() public view returns (uint256) {
        return ID;
    }

    function checkNFT(address _user) public view returns (bool) {
        return investor[_user].boughtNFT;
    }

    function checkBoost(address _user, uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 multiplier = investor[_user].NFTx;
        if (multiplier == 0) {
            return _amount;
        } else {
            return ((multiplier + 1e4) * _amount) / 1e4;
        }
    }

    function chartData(uint256 _day) public returns (uint256) {
        require(_day >= 1 && _day <= currentDay, "Invalid day");

        if (day[1] == 0) {
            // Initialize chart data
            day[1] = block.timestamp;
            currentDay++;
            priceOnDay[currentDay] = getSUFPrice();
        } else if (day[currentDay] + 1 days <= block.timestamp) {
            day[currentDay + 1] = block.timestamp;
            currentDay++;
            priceOnDay[currentDay] = getSUFPrice();
        }

        return priceOnDay[_day];
    }
}

/* |====================> Made with love by the awesome @weimaster <===================| */
/* |================================> END OF CONTRACT <================================| */