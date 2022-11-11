/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// File: contracts/Marketplace.sol


pragma solidity >=0.7.0 <0.9.0;







contract Marketplace is Ownable, ReentrancyGuard {
  IERC721 private nftAddress;
  IERC20 private tokenAddress;

  uint256 private MAX_AUCTION_TIME = 3 days;
  uint256 private MIN_BID_PERCENTAGE = 5;
  uint256 private REFUND_TIME;

  struct tokenERC20 {
    string name;
    address contractAddress;
    uint256 fee;
  }
  struct nftListing {
    uint256[] price;
    address seller;
    bool approve;
  }
  struct nftAuction {
    address seller;
    address buyer;
    uint256[] tokenIds;
    uint256 indexToken;
    uint256 floorPrice; 
    uint256 bidPrice; 
    uint256 deadline; 
  }

  mapping(address => mapping(uint256 => nftListing)) private nftListings;
  mapping(address => mapping(uint256 => nftAuction)) private nftAuctions;
  mapping(address => bool) private isAuthorize;
  mapping(uint256 => tokenERC20) public tokensERC20;

  // Default values
  address public beneficiary;

  uint256 public totalTokenTypes = 1; // Index 0 is default BNB
  uint256 private sumPrice = 0;
  uint256 public totalAuction;
  uint256 public feeListing;

  bool public approveAvailable;
  bool public isPausedAuction = true;
  bool public isPausedListing = true;

  // Modifiers
  modifier isListed (
    address contractNftAddress,
    uint256 tokenId,
    address owner
  ) {
    require(this.getNftListingAddress(contractNftAddress, tokenId) != owner, "This NFT is already listed");
    _;
  }

  modifier isOwner(
    address contractNftAddress,
    uint256 tokenId,
    address spender
  ) {
    nftAddress = IERC721(contractNftAddress);
    address owner = nftAddress.ownerOf(tokenId);
    require(spender == owner, "Sorry you do not own this NFT");
    _;
  }

  constructor () {
    tokensERC20[0].name = "BNB";
    beneficiary = msg.sender;
  }

  // Set data
  function updateBeneficiary (address _address) external onlyOwner {
    require(_address != address(0), "No valid address");
    require(_address != beneficiary, "No valid address 300");
    beneficiary = _address;
  }

  function setAuthorizedContractAddress (address _address) external onlyOwner {
    require(address(_address) != address(0), 'Contract address is not valid');
    if (isAuthorize[_address]) {
      isAuthorize[_address] = false;
    } else {
      isAuthorize[_address] = true;
    }
  }

  function createToken (string memory name, address contractAddress, uint256 fee) external onlyOwner {
    require(contractAddress != address(0), "Empty address");
    require(strlen(name) > 0, "Type a valid name for this token");
    require(fee < 100, "Invalid fee");
    tokenERC20 storage newToken = tokensERC20[totalTokenTypes];
    newToken.name = name;
    newToken.contractAddress = contractAddress;
    newToken.fee = fee;
    totalTokenTypes = totalTokenTypes + 1;
  }

  function updateToken (
    uint256 indexToken,
    string memory name,
    address contractAddress,
    uint256 fee
  ) external onlyOwner{
    require(fee < 100, "Invalid fee");
    tokenERC20 storage newToken = tokensERC20[indexToken];
    require(indexToken < totalTokenTypes && indexToken >= 0, "This token does not exist to update");
    if (indexToken > 0) {
     require(newToken.contractAddress != address(0), "Empty address");
    }
    require(contractAddress != address(0), "No address configured");
    require(strlen(name) > 0, "Type a valid name for this token");
    newToken.name = name; 
    newToken.contractAddress = contractAddress;      
    newToken.fee = fee;
  }

  //Auction
  event NftAuction (
    address sellerAddress,
    address buyerAddress,
    address contractAddress,
    uint256[] tokenIds,
    uint256 indexToken,
    uint256 floorPrice,
    uint256 bidPrice,
    uint256 deadline,
    uint256 id
  );
  function auction (
    address contractNftAddress,
    uint256[] memory tokenIds,
    uint256 indexToken,
    uint256 floorPrice,
    uint256 startPrice,
    uint256 deadline
  ) external {
    require(isPausedAuction == false, "Auction is paused");
    require(isAuthorize[contractNftAddress] == true, "The contract of this NFT is not authorized for this Marketplace");
    require(deadline < block.timestamp + MAX_AUCTION_TIME + 300, "Sorry the auction has ended");
    require(tokensERC20[indexToken].contractAddress != address(0), "Sorry, an error has occurred");
    require(floorPrice > 0, "Price must be above zero");
    require(startPrice <= floorPrice, "The floor price must be less than or equal to the start price");
    require(tokenIds.length > 0, "You must have at least one NFT to create an auction");
    require(IERC721(contractNftAddress).isApprovedForAll(msg.sender, address(this)) == true, "NFTs are not approved for this marketplace contract");
    for (uint256 i = 0; i < tokenIds.length; i++) {
      require(this.getNftListingAddress(contractNftAddress, tokenIds[i]) == address(0), "One of the NFTs you want to auction is already listed");
    }
    for (uint256 i = 0; i < tokenIds.length; i++) {
      IERC721(contractNftAddress).transferFrom(msg.sender, address(this), tokenIds[i]);
    }
    nftAuctions[contractNftAddress][totalAuction] = nftAuction(
      msg.sender,
      address(0),
      tokenIds,
      indexToken,
      floorPrice,
      startPrice,
      deadline
    );
    emit NftAuction(msg.sender, address(0), contractNftAddress, tokenIds, indexToken, floorPrice, startPrice, deadline, totalAuction);
    totalAuction = totalAuction + 1;
  }

  event AuctionRefund(address buyerAddress);
  event BidAuction(
    address buyerAddress,
    address contractAddress,
    uint256 id,
    uint256 bidPrice
  );
  function bid (address contractNftAddress, uint256 id) external payable {
    require(isPausedAuction == false, "Auction is paused");
    require(msg.sender != this.getNftAuctionAddress(contractNftAddress, id), "You are the owner of this auction you cannot bid");
    require(this.getNftAuctionDeadline(contractNftAddress, id) > block.timestamp, "This auction has already ended");
    uint256 bidPrice = this.getNftAuctionBidPrice(contractNftAddress, id);
    uint256 floorPrice = this.getNftAuctionFloorPrice(contractNftAddress, id);
    address buyer = this.getNftAuctionBuyer(contractNftAddress, id);
    if (this.getNftAuctionIndexToken(contractNftAddress, id) == 0) {
      require(msg.value >= (floorPrice * MIN_BID_PERCENTAGE)/100, "Sorry your bid for this auction is too low");
      require(msg.value > (bidPrice + ((bidPrice * MIN_BID_PERCENTAGE)/100)), "Your bid for this auction must be higher than the previous bid");
      if (buyer != address(0)) {
        payable(buyer).transfer(bidPrice); 
        emit AuctionRefund(
          buyer
        );
      }
      _setAuctionBid(contractNftAddress, id, msg.value);
      emit BidAuction(msg.sender, contractNftAddress, id, msg.value);
    } else {
      tokenAddress = IERC20(tokensERC20[this.getNftAuctionIndexToken(contractNftAddress, id)].contractAddress);
      uint256 tokenAllowance = tokenAddress.allowance(msg.sender, address(this));
      require(tokenAllowance >= (floorPrice * MIN_BID_PERCENTAGE)/100, "Sorry your bid for this auction is too low");
      require(tokenAllowance > bidPrice, "Your bid for this auction must be higher than the previous bid");
      tokenAddress.transferFrom(msg.sender, address(this), tokenAllowance);
      if (buyer != address(0)) {
        tokenAddress.transferFrom(
          address(this),
          buyer,
          bidPrice
        );
        emit AuctionRefund(
          buyer
        );
      }
      _setAuctionBid(contractNftAddress, id, tokenAllowance);
      emit BidAuction(msg.sender, contractNftAddress, id, tokenAllowance);
    }
    _setAuctionBuyer(contractNftAddress, id, msg.sender);
  }

  event AcceptedAuction(
    address sellerAddress,
    address buyerAddress,
    address contractAddress,
    uint256 id,
    uint256[]
    tokenIds
  );
  function acceptAuction (address contractNftAddress, uint256 id) external {
    require(isPausedAuction == false, "Auction is paused");
    address seller = this.getNftAuctionAddress(contractNftAddress, id);
    address buyer = this.getNftAuctionBuyer(contractNftAddress, id);
    uint256 bidPrice = this.getNftAuctionBidPrice(contractNftAddress, id);
    require(seller == msg.sender, "Sorry you are not the owner of this auction");
    require(buyer != address(0), "You cannot accept this auction, no one has bid");
    require(bidPrice > 0, "You cannot accept this auction, no one has Bid");
    uint256[] memory tokenIds = this.getNftAuctionTokenIds(contractNftAddress, id);
    uint256 indexToken = this.getNftAuctionIndexToken(contractNftAddress, id);
    uint256 transferSeller = ((100 - tokensERC20[indexToken].fee) * bidPrice) / 100;
    uint256 transferMarketplace = (tokensERC20[indexToken].fee * bidPrice) / 100;
    if (indexToken == 0) {
      payable(seller).transfer(transferSeller);
      payable(beneficiary).transfer(transferMarketplace);
    } else {
      tokenAddress = IERC20(tokensERC20[indexToken].contractAddress);
      tokenAddress.transferFrom(address(this), seller, transferSeller);
      tokenAddress.transferFrom(address(this), beneficiary, transferMarketplace);
    }
    emit AcceptedAuction(
      seller,
      buyer,
      contractNftAddress,
      id,
      tokenIds
    );
    for (uint256 i = 0; i < tokenIds.length; i++) {
      IERC721(contractNftAddress).transferFrom(address(this), buyer, tokenIds[i]);
    }
    delete nftAuctions[contractNftAddress][id];
  }

  event CancelAuction(
    address sellerAddress,
    address contractAddress,
    uint256 id,
    uint256[]
    tokenIds
  );
  function cancelAuction (address contractNftAddress, uint256 id) external {
    require(isPausedAuction == false, "Auction is paused");
    address seller = this.getNftAuctionAddress(contractNftAddress, id);
    require(seller == msg.sender, "Sorry you are not the owner of this auction");
    uint256[] memory tokenIds = this.getNftAuctionTokenIds(contractNftAddress, id);
    address buyer = this.getNftAuctionBuyer(contractNftAddress, id);
    if (buyer != address(0)) {
      uint256 bidPrice = this.getNftAuctionBidPrice(contractNftAddress, id);
      if (bidPrice > 0) {
        uint256 indexToken = this.getNftAuctionIndexToken(contractNftAddress, id);
        if (indexToken == 0) {
          payable(buyer).transfer(bidPrice);
        } else {
          tokenAddress = IERC20(tokensERC20[indexToken].contractAddress);
          tokenAddress.transferFrom(address(this), buyer, bidPrice);
        }
        emit AuctionRefund(
          buyer
        );
      }
    }
    emit CancelAuction(
      seller,
      contractNftAddress,
      id,
      tokenIds
    );
    for (uint256 i = 0; i < tokenIds.length; i++) {
      IERC721(contractNftAddress).transferFrom(address(this), seller, tokenIds[i]);
    }
    delete nftAuctions[contractNftAddress][id];
  }

  function cancelEmergencyAuction (address contractNftAddress, uint256 id) external onlyOwner {
    uint256[] memory tokenIds = this.getNftAuctionTokenIds(contractNftAddress, id);
    address buyer = this.getNftAuctionBuyer(contractNftAddress, id);
    if (buyer != address(0)) {
      uint256 bidPrice = this.getNftAuctionBidPrice(contractNftAddress, id);
      if (bidPrice > 0) {
        uint256 indexToken = this.getNftAuctionIndexToken(contractNftAddress, id);
        if (indexToken == 0) {
          payable(buyer).transfer(bidPrice);
        } else {
          tokenAddress = IERC20(tokensERC20[indexToken].contractAddress);
          tokenAddress.transferFrom(address(this), buyer, bidPrice);
        }
        emit AuctionRefund(
          buyer
        );
      }
    }
    address seller = this.getNftAuctionAddress(contractNftAddress, id);
    emit CancelAuction(
      seller,
      contractNftAddress,
      id,
      tokenIds
    );
    for (uint256 i = 0; i < tokenIds.length; i++) {
      IERC721(contractNftAddress).transferFrom(address(this), seller, tokenIds[i]);
    }
    delete nftAuctions[contractNftAddress][id];
  }
  event AuctionRefundBuyer(
    address buyerAddress,
    address contractAddress,
    uint256 id
  );
  function refundBuyer (address contractNftAddress, uint256 id) external {
    require(isPausedAuction == false, "Auction is paused");
    address buyer = this.getNftAuctionBuyer(contractNftAddress, id);
    require(buyer == msg.sender, "Sorry, you have not bid on this auction");
    require(this.getNftAuctionDeadline(contractNftAddress, id) + REFUND_TIME < block.timestamp, "Sorry you cannot request a refund, until the auction ends or is canceled by the owner");
    if (buyer != address(0)) {
      uint256 indexToken = this.getNftAuctionIndexToken(contractNftAddress, id);
      uint256 bidPrice = this.getNftAuctionBidPrice(contractNftAddress, id);
      if (indexToken == 0) {
        payable(buyer).transfer(bidPrice);
      } else {
        tokenAddress = IERC20(tokensERC20[indexToken].contractAddress);
        tokenAddress.transferFrom(address(this), buyer, bidPrice);
      }
      emit AuctionRefundBuyer(
        buyer,
        contractNftAddress,
        id
      );
    }
    _setAuctionBid(contractNftAddress, id, 0);
  }

  function _setAuctionBid (address contractNftAddress, uint256 id, uint256 price) internal {
    nftAuctions[contractNftAddress][id].bidPrice = price;
  }

  function _setAuctionBuyer (address contractNftAddress, uint256 id, address _buyer) internal {
    nftAuctions[contractNftAddress][id].buyer = _buyer;
  }

  function setMaxAuctionTime (uint256 time) external onlyOwner {
    MAX_AUCTION_TIME = time;
  }

  function setMinBidPercentage (uint256 percentage) external onlyOwner {
    require(percentage < 100, "The percentage must not be greater than 100");
    require(percentage > 0, "The percentage must have to be greater than 0");
    MIN_BID_PERCENTAGE = percentage;
  }

  function setRefundTime (uint256 time) external onlyOwner {
    REFUND_TIME = time;
  }

  function setPauseAuction () external onlyOwner {
    if (isPausedAuction) {
      isPausedAuction = false;
    } else {
      isPausedAuction = true;
    }
  }

  // Listing
  event NftListed(
    address sellerAddress,
    address contractNftAddress,
    uint256 tokenId,
    uint256[] price
  );

  function list (
    address contractNftAddress,
    uint256 tokenId,
    uint256[] memory price,
    bool isTransferable
  )
    external
    payable
    isListed(contractNftAddress, tokenId, msg.sender)
    isOwner(contractNftAddress, tokenId, msg.sender)
  {
    require(isPausedListing == false, "Listing is paused");
    require(isAuthorize[contractNftAddress] == true, "The contract of this NFT is not authorized for this Marketplace");
    require(price.length == totalTokenTypes, "An error has occurred please try again");
    if (IERC721(contractNftAddress).isApprovedForAll(msg.sender, address(this)) == false) {
      require(IERC721(contractNftAddress).getApproved(tokenId) == address(this), "This NFT is not approved for this Marketplace contract"); 
    }
    for (uint256 i = 0; i < totalTokenTypes; i++) {
      sumPrice = sumPrice + price[i];
    }
    require(sumPrice > 0, "Price Must Be Above Zero");
    if (isTransferable) {
      nftAddress = IERC721(contractNftAddress);
      nftAddress.transferFrom(
        msg.sender,
        address(this),
        tokenId
      );
      nftListings[contractNftAddress][tokenId] = nftListing(price, msg.sender, false);
    } else {
      require(approveAvailable == true, "An error has occurred please Try Again");
      if (feeListing > 0) {
        require(msg.value >= feeListing, "Fee price not reached, try again");
        payable(beneficiary).transfer(msg.value);
      }
      nftListings[contractNftAddress][tokenId] = nftListing(price, msg.sender, true);
    }    
    sumPrice = 0;
    emit NftListed(msg.sender, contractNftAddress, tokenId, price);
  }

  event NftBought(
    address buyerAddress,
    address sellerAddress,
    address contractNftAddress,
    uint256 tokenId,
    uint256 price,
    uint256 tokenIndex
  );

  function buy (
    address contractNftAddress,
    uint256 tokenId,
    uint256 tokenIndex
  )
    external
    payable
    nonReentrant
  {
    require(isPausedListing == false, "Listing is paused");
    address seller = this.getNftListingAddress(contractNftAddress, tokenId);
    uint256 price = this.getNftListingPrice(contractNftAddress, tokenId, tokenIndex);
    require(seller != msg.sender, "Sorry you can't buy your own NFT");
    require(price > 0, "NFT not available to buy");
    if (tokenIndex == 0) {
      require(msg.value >= price, "You don't have enough balance");
      uint256 transferSeller = ((100 - tokensERC20[tokenIndex].fee) * msg.value) / 100;
      uint256 transferMarketplace = (tokensERC20[tokenIndex].fee * msg.value) / 100;

      payable(seller).transfer(transferSeller);
      payable(beneficiary).transfer(transferMarketplace);
    } else {
      tokenAddress = IERC20(tokensERC20[tokenIndex].contractAddress);
      uint256 tokenAllowance = tokenAddress.allowance(msg.sender, address(this));
      require(tokenAllowance >= price, "You don't have enough balance");
      uint256 transferSeller = ((100 - tokensERC20[tokenIndex].fee) * tokenAllowance) / 100;
      uint256 transferMarketplace = (tokensERC20[tokenIndex].fee * tokenAllowance) / 100;
      tokenAddress.transferFrom(msg.sender, seller, transferSeller);
      tokenAddress.transferFrom(msg.sender, beneficiary, transferMarketplace);
    }
    nftAddress = IERC721(contractNftAddress);
    if (this.getNftListingApprove(contractNftAddress, tokenId)) {
      require(IERC721(contractNftAddress).getApproved(tokenId) == address(this), "Sorry NFT not available to buy");
      nftAddress.transferFrom(
        seller,
        msg.sender,
        tokenId
      );
    } else {
      nftAddress.transferFrom(
        address(this),
        msg.sender,
        tokenId
      );
    }
    // Check to make sure the NFT was transfered
    emit NftBought(msg.sender, seller, contractNftAddress, tokenId, price, tokenIndex);
    // Remove NFT token from mapping once bought
    delete (nftListings[contractNftAddress][tokenId]);
  }

  event ItemCanceled(
    address contractNftAddress,
    uint256 tokenId
  );
  function cancelListing (
    address contractNftAddress,
    uint256 tokenId
  )
    external
  {
    require(isPausedListing == false, "Listing is paused");
    require(this.getNftListingAddress(contractNftAddress, tokenId) == msg.sender, "Sorry you are not the owner of this NFT");
    nftAddress = IERC721(contractNftAddress);
    if (this.getNftListingApprove(contractNftAddress, tokenId) == false) {
      nftAddress.transferFrom(
        address(this),
        msg.sender,
        tokenId
      );
    }
    delete (nftListings[contractNftAddress][tokenId]);
    emit ItemCanceled(contractNftAddress, tokenId);
  }

  function cancelEmergencyListing (
    address contractNftAddress,
    uint256 tokenId
  )
    external
    onlyOwner
  {
    nftAddress = IERC721(contractNftAddress);
    if (this.getNftListingApprove(contractNftAddress, tokenId) == false) {
      nftAddress.transferFrom(
        address(this),
        this.getNftListingAddress(contractNftAddress, tokenId),
        tokenId
      );
    }
    delete (nftListings[contractNftAddress][tokenId]);
    emit ItemCanceled(contractNftAddress, tokenId);
  }

  event NftListedUpdate(
    address contractNftAddress,
    uint256 tokenId,
    uint256[] price
  );  
  function updateListing (
    address contractNftAddress,
    uint256 tokenId,
    uint256[] memory newPrice
  )
    external
  {
    require(isPausedListing == false, "Listing is paused");
    require(this.getNftListingAddress(contractNftAddress, tokenId) == msg.sender, "Sorry you are not the owner of this NFT");
    require(newPrice.length == totalTokenTypes, "An error has occurred please try again");
    for (uint256 i = 0; i < totalTokenTypes; i++) {
      sumPrice = sumPrice + newPrice[i];
    }
    require(sumPrice > 0, "Price Must Be Above Zero");
    nftListings[contractNftAddress][tokenId].price = newPrice;
    nftListings[contractNftAddress][tokenId].seller = msg.sender;
    sumPrice = 0;
    emit NftListedUpdate(contractNftAddress, tokenId, newPrice);
  }

  function setPauseListing () external onlyOwner {
    if (isPausedListing) {
      isPausedListing = false;
    } else {
      isPausedListing = true;
    }
  }

  // Get contract
  function getNftListingPrice(
    address contractNftAddress,
    uint256 tokenId,
    uint256 indexToken
  )
    external
    view
    returns(uint256)
  {
    uint256[] memory prices = nftListings[contractNftAddress][tokenId].price;
    return prices[indexToken];
  }

  function getNftListingAddress(
    address contractNftAddress,
    uint256 tokenId
  )
    external
    view
    returns(address)
  {
    return nftListings[contractNftAddress][tokenId].seller;
  }

  function getNftListingApprove(address contractNftAddress, uint256 tokenId)
    external
    view
    returns(bool)
  {
    return nftListings[contractNftAddress][tokenId].approve;
  }

  function getNftAuctionAddress(address contractNftAddress, uint256 id)
    external
    view
    returns(address)
  {
    return nftAuctions[contractNftAddress][id].seller;
  }

  function getNftAuctionBidPrice (address contractNftAddress, uint256 id)
    external
    view
    returns(uint256)
  {
    return nftAuctions[contractNftAddress][id].bidPrice;
  }

  function getNftAuctionTokenIds (address contractNftAddress, uint256 id)
    external
    view
    returns(uint256[] memory)
  {
    return nftAuctions[contractNftAddress][id].tokenIds;
  }

  function getNftAuctionBuyer (address contractNftAddress, uint256 id)
    external
    view
    returns(address)
  {
    return nftAuctions[contractNftAddress][id].buyer;
  }

  function getNftAuctionDeadline (address contractNftAddress, uint256 id)
    external
    view
    returns(uint256)
  {
    return nftAuctions[contractNftAddress][id].deadline;
  }

  function getNftAuctionIndexToken (address contractNftAddress, uint256 id)
    external
    view
    returns(uint256)
  {
    return nftAuctions[contractNftAddress][id].indexToken;
  }

  function getNftAuctionFloorPrice (address contractNftAddress, uint256 id)
    external
    view
    returns(uint256)
  {
    return nftAuctions[contractNftAddress][id].floorPrice;
  }

  /**
  * @dev Returns the length of a given string
  *
  * @param s The string to measure the length of
  * @return The length of the input string
  */
  function strlen(string memory s) internal pure returns (uint) {
    uint len;
    uint i = 0;
    uint bytelength = bytes(s).length;
    for(len = 0; i < bytelength; len++) {
      bytes1 b = bytes(s)[i];
      if(b < 0x80) {
        i += 1;
      } else if (b < 0xE0) {
        i += 2;
      } else if (b < 0xF0) {
        i += 3;
      } else if (b < 0xF8) {
        i += 4;
      } else if (b < 0xFC) {
        i += 5;
      } else {
        i += 6;
      }
    }
    return len;
  }
}