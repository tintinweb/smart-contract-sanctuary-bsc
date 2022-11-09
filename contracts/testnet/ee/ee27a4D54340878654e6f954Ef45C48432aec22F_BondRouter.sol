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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./IBondNFT.sol";
import "./BondStruct.sol";
import "./IFactory.sol";
import "./IBondRefund.sol";

contract BondRouter is Ownable, BondStruct, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;


    uint256 constant public ONE_HUNDRED_PERCENT = 1e6;
    // System
    address public adminWallet;
    address public refundAddress;

    // Batch
    mapping(uint256 => BatchInfo) private batchInfo;
    uint256 public batchId;
    mapping(uint256 => uint256) private withdraw;

    // pending request
    uint256 private requestId;
    mapping(uint256 => PendingRequest) private requests;
    EnumerableSet.UintSet private listRequestId;

    // nft factory
    address public factory;

    //bond nft address
    IBondNFT public bondNFTAddress;

    //fee processing when redeem early
    uint256 public penaltyFee;

    //operators
    EnumerableSet.AddressSet private operators;

    /* ===================== Modifiers ===================== */
    modifier onlyOperator() {
        require(operators.contains(msg.sender), "BondRouter: only operator");
        _;
    }


    /* ===================== Events ===================== */
    event UpdateBondPrice(uint256 _batchId, uint256[] _prices, InterestRate[] _rates, bool _action);
    event BuyBond(address _user, uint256 _price, uint256 _quantity, uint256 _batchId);
    event Redeem(address _owner, uint256[] ids, address _receiver, uint256 _totalReceiver, uint256 _batchId);
    event Harvest(address _owner, uint256[] ids, address _receiver, uint256 _totalReceiver, uint256 _batchId);
    event CreateBondNFTAddress(address nft);
    event CreateRequest(PendingRequest _request, uint256 id, uint256 _batchId);
    event ExecuteRequest(PendingRequest _request, uint256 id, uint256 _batchId);
    event UpdateStartTime(uint256 _old, uint256 _new, uint256 _batchId);
    event UpdatePenaltyFee(uint256 _old, uint256 _new);
    event UpdateAdminWallet(address _old, address _new);
    event CreateNewBatch(uint256 _batchId, BatchConfig _config, BackedBond[] _backedBond, uint256[] _prices, InterestRate[] _rates);
    event UpdateOperators(address _operator, bool _action);
    event UpdateBatchStatus(uint256 _bacthId, bool _action);
    event UpdateRefundAddress(address _old, address _new);
    event RedeemInfo(uint256 _id, uint256 _value, uint256 _interest, uint256 _currentValue);

    /* ===================== Constructor ===================== */

    constructor(address _nftFactory, address _adminWallet, address _refundAddress) {
        factory = _nftFactory;
        operators.add(msg.sender);
        require(_adminWallet != address(0), "BondRouter: admin wallet not a zero");
        adminWallet = _adminWallet;
        refundAddress = _refundAddress;
    }

    /* ===================== Internal functions ===================== */
    function _payment(address _currency, address _receiver, uint256 _amount) internal {
        IBondRefund(refundAddress).transfer(_currency, _receiver, _amount);
    }

    function _lock(IBondNFT _bond, uint256[] memory _ids) internal {
        _bond.lock(_ids);
    }

    function _unlock(IBondNFT _bond, uint256[] memory _ids) internal {
        _bond.unlock(_ids);
    }

    function _redeem(IBondNFT _bond, uint256[] memory _ids) internal {
        _bond.redeem(_ids);
    }

    function _issue(IBondNFT _bond, address _receiver, uint256 _quantity, uint256 _amount, uint256 _maturity, uint256 _interest, uint256 _batchId) internal {
        _bond.issue(_receiver, _quantity, _amount, _maturity, _interest, _batchId);
    }

    function _calInterest(uint256 _interest, uint256 _lastHarvest, uint256 _maturity, uint256 _startTime) internal view returns (uint256) {
        uint256 _endTime = _min(block.timestamp, _maturity);
        uint256 _start = _max(_lastHarvest, _startTime);
        if (block.timestamp < _startTime) {
            return 0;
        }
        return (_endTime - _start) * _interest / (_maturity - _startTime);
    }

    function _calCurrentRate(uint256 _start, uint256 _end, InterestRate memory _rate) internal view returns (uint256) {
        uint256 _timeStamp = _max(_start, block.timestamp);
        return (_rate.max - (((_rate.max - _rate.min) * (_timeStamp - _start)) / (_end - _start)));
    }

    function _createPendingRequest(RequestType _requestType, address _receiver, uint256 _amount, uint256[] memory _ids, uint256 _batchId) internal {
        requestId++;
        requests[requestId].requestType = _requestType;
        requests[requestId].status = RequestStatus.PENDING;
        requests[requestId].to = _receiver;
        requests[requestId].amount = _amount;
        requests[requestId].tokenIds = _ids;
        requests[requestId].createdAt = block.timestamp;
        requests[requestId].batchId = _batchId;
        listRequestId.add(requestId);
        emit CreateRequest(requests[requestId], requestId, _batchId);
    }

    function _updateLastHarvest(IBondNFT _bond, uint256[] memory ids) internal {
        _bond.updateLastHarvest(ids, msg.sender);
    }

    function _executeRequest(uint256 _requestId) internal {
        PendingRequest storage _request = requests[_requestId];

        //        IERC20(batchInfo[_request.batchId].config.currency).safeTransfer(_request.to, _request.amount);
        _payment(batchInfo[_request.batchId].config.currency, _request.to, _request.amount);
        if (_request.requestType == RequestType.REDEEM) {
            _unlock(bondNFTAddress, _request.tokenIds);
            _redeem(bondNFTAddress, _request.tokenIds);
        }
        _request.status = RequestStatus.EXECUTED;
        listRequestId.remove(_requestId);
        emit ExecuteRequest(_request, _requestId, _request.batchId);
    }

    function _buyBond(uint256 _batchId, uint256 _price, uint256 _quantity) internal {
        require(_batchId > 0 && _batchId <= batchId, "BondRouter: !_batchId");
        BatchInfo storage _batchInfo = batchInfo[_batchId];
        require(_batchInfo.bondPrice.contains(_price), "BondRouter: _price not support");
        require(_batchInfo.status, "BondRouter: !active");
        require(block.timestamp < _batchInfo.config.maturity, "BondRouter: !maturity");

        //check input
        uint256 _amountTransfer = _price * _quantity;
        require(_quantity > 0 && _amountTransfer + _batchInfo.raised <= _batchInfo.config.totalFundRaise, "BatchFactory: not valid quantity");

        //transfer fund
        IERC20(_batchInfo.config.currency).safeTransferFrom(msg.sender, adminWallet, _amountTransfer);

        _batchInfo.raised += _amountTransfer;

        uint256 _currentRate = _calCurrentRate(_batchInfo.config.startTime, _batchInfo.config.maturity, _batchInfo.interestRates[_price]);

        uint256 _interest = _price * _currentRate;
        //issue bond nft
        _issue(bondNFTAddress, msg.sender, _quantity, _price, _batchInfo.config.maturity, _interest, _batchId);

        emit BuyBond(msg.sender, _price, _quantity, _batchId);
    }

    function _calAmount(uint256 _tokenId, uint256 _batchId, uint256 _startTime) internal view returns (uint256 _interest, uint256 _bondAmount, uint256 _amountBack) {
        BondInfo memory _info = bondNFTAddress.info(_tokenId);
        require(_batchId == _info.batchId, "Batch: !batch id");
        if (_info.lastHarvest <= _info.maturity) {
            _interest += _calInterest(_info.interest, _info.lastHarvest, _info.maturity, _startTime);
        }
        if (_info.maturity > block.timestamp) {
            _bondAmount += _info.amount * (ONE_HUNDRED_PERCENT - penaltyFee) / ONE_HUNDRED_PERCENT;
            _amountBack += _info.amount;
        } else {
            _bondAmount += _info.amount;
        }
    }

    function _executeRedeem(uint256 _batchId, uint256[] memory _ids, address _to) internal {
        require(_batchId > 0 && _batchId <= batchId, "BondRouter: !_batchId");
        BatchInfo storage _info = batchInfo[_batchId];
        uint256 _amountSent = 0;
        uint256 _amountRefund = 0;
        for (uint256 i = 0; i < _ids.length; i++) {
            (uint256 _interestAmount, uint256 _totalAmount, uint256 _amountBack) = _calAmount(_ids[i], _batchId, _info.config.startTime);
            _amountSent += (_totalAmount + _interestAmount);
            _amountRefund += _amountBack;
            emit RedeemInfo(_ids[i], _amountBack, _interestAmount, _totalAmount);
        }
        if (_amountRefund > 0) {
            _info.raised -= _amountRefund;
        }

        _updateLastHarvest(bondNFTAddress, _ids);
        _lock(bondNFTAddress, _ids);
        _createPendingRequest(RequestType.REDEEM, _to, _amountSent, _ids, _batchId);

        emit Redeem(msg.sender, _ids, _to, _amountSent, _batchId);
    }

    function _executeHarvest(uint256 _batchId, uint256[] memory _ids, address _to) internal {
        require(_batchId > 0 && _batchId <= batchId, "BondRouter: !_batchId");

        // calculate amount interest
        BatchConfig memory _info = batchInfo[_batchId].config;
        require(block.timestamp >= _info.startTime, "BondRouter: can not harvest now");

        uint256 _amountSent = 0;
        for (uint256 i = 0; i < _ids.length; i++) {
            (uint256 _interestAmount,,) = _calAmount(_ids[i], _batchId, _info.startTime);
            _amountSent += _interestAmount;
        }
        //        _createPendingRequest(RequestType.HARVEST, _to, _amountSent, _ids, _batchId);
        _payment(_info.currency, msg.sender, _amountSent);
        _updateLastHarvest(bondNFTAddress, _ids);

        emit Harvest(msg.sender, _ids, _to, _amountSent, _batchId);
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function _max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /* ===================== External functions ===================== */

    //deposit funds and get bond
    function buyBond(BuyingInfo[] memory _buyInfo) external whenNotPaused {
        for (uint256 i = 0; i < _buyInfo.length; i++) {
            _buyBond(_buyInfo[i].batchId, _buyInfo[i].price, _buyInfo[i].quantity);
        }
    }


    // take profit and refund or create request harvest
    function redeem(ClaimInfo[] memory _info, address _to) external whenNotPaused nonReentrant {
        for (uint256 i = 0; i < _info.length; i++) {
            _executeRedeem(_info[i].batchId, _info[i].ids, _to);
        }
    }

    // take profit or create request harvest
    function harvest(ClaimInfo[] memory _info, address _to) external whenNotPaused nonReentrant {
        for (uint256 i = 0; i < _info.length; i++) {
            _executeHarvest(_info[i].batchId, _info[i].ids, _to);
        }
    }


    /* ===================== View functions ===================== */
    function getBatch(uint256 _batchId) external view returns (BatchInfoResponse memory) {

        uint256 length = batchInfo[_batchId].bondPrice.length();
        InterestRate[] memory interestRate = new InterestRate[](length);
        for(uint256 i = 0; i < length; i++) {
            interestRate[i] = batchInfo[_batchId].interestRates[batchInfo[_batchId].bondPrice.at(i)];
        }
        BatchInfoResponse memory response = BatchInfoResponse(
        {
        raised : batchInfo[_batchId].raised,
        bondPrice : batchInfo[_batchId].bondPrice.values(),
        backedBond : batchInfo[_batchId].backedBond,
        config : batchInfo[_batchId].config,
        status : batchInfo[_batchId].status,
        interestRate: interestRate
        });
        return response;
    }

    function getPendingRequest(uint256 _page, uint256 _limit) external view returns (uint256[] memory, uint256 _length) {
        uint256 _from = _page * _limit;
        _length = listRequestId.length();
        uint256 _to = _min((_page + 1) * _limit, listRequestId.length());
        uint256[] memory _result = new uint256[](_to - _from);
        for (uint256 i = 0; _from < _to; i++) {
            _result[i] = listRequestId.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function getRequest(uint256 _requestId) external view returns (PendingRequest memory) {
        return requests[_requestId];
    }

    function getClaimable(uint256[] memory _ids) external view returns (uint256 _result) {
        for (uint256 i = 0; i < _ids.length; i++) {
            BondInfo memory _info = bondNFTAddress.info(_ids[i]);
            BatchConfig memory _config = batchInfo[_info.batchId].config;
            (uint256 _interestAmount,,) = _calAmount(_ids[i], _info.batchId, _config.startTime);
            _result += _interestAmount;
        }
        return _result;
    }

    function getCurrentRate(uint256 _start, uint256 _end, InterestRate memory _rate) external view returns(uint256) {
        return _calCurrentRate(_start, _end, _rate);
    }

    /* ===================== Restrict Access ===================== */
    function createBondNFT(string memory _name, string memory _symbol, string memory _uri) external onlyOwner {
        require(address(bondNFTAddress) == address(0), "BondRouter: created");
        bondNFTAddress = IBondNFT(IFactory(factory).createBondNFT(address(this), _name, _symbol, _uri));
        emit CreateBondNFTAddress(address(bondNFTAddress));
    }

    function createBatch(BatchConfig memory _config, BackedBond[] memory _backedBond, uint256[] memory _prices, InterestRate[] memory _rates, bool _active)
    external onlyOperator {
        batchId ++;
        require(_config.startTime > block.timestamp, "BondRouter: start time < now");
        require(_config.maturity > _config.startTime, "BondRouter: maturity < start time");
        require(_prices.length == _rates.length, "BondRouter: !length");
        batchInfo[batchId].config = _config;
        for (uint256 i = 0; i < _backedBond.length; i++) {
            batchInfo[batchId].backedBond.push(_backedBond[i]);
        }

        //default
        if (_prices.length > 0) {
            for (uint256 i = 0; i < _prices.length; i++) {
                InterestRate memory _rate = _rates[i];
                require(_rate.max <= ONE_HUNDRED_PERCENT && _rate.min <= ONE_HUNDRED_PERCENT, "BondRouter: greater than ONE_HUNDRED_PERCENT");
                require(_rate.max >= _rate.min, "BondRouter: Max rate must greater min rate");
                batchInfo[batchId].bondPrice.add(_prices[i]);
                batchInfo[batchId].interestRates[_prices[i]] = _rate;
            }
        } else {
            batchInfo[batchId].bondPrice.add(100 ether);
            batchInfo[batchId].bondPrice.add(500 ether);
            batchInfo[batchId].bondPrice.add(1000 ether);
            batchInfo[batchId].bondPrice.add(5000 ether);
            batchInfo[batchId].bondPrice.add(10000 ether);

            batchInfo[batchId].interestRates[100 ether] = InterestRate({max: 100000, min: 50000});
            // 10%
            batchInfo[batchId].interestRates[500 ether] = InterestRate({max: 105000, min: 52500});
            // 12%
            batchInfo[batchId].interestRates[1000 ether] = InterestRate({max: 108000, min: 54000});
            // 14%
            batchInfo[batchId].interestRates[5000 ether] = InterestRate({max: 110000, min: 55000});
            batchInfo[batchId].interestRates[10000 ether] = InterestRate({max: 115000, min: 57500});
            // 16%
        }
        batchInfo[batchId].status = _active;
        emit CreateNewBatch(batchId, _config, _backedBond, batchInfo[batchId].bondPrice.values(), _rates);
    }

    function updateBondPrice(uint256 _batchId, uint256[] memory _prices, InterestRate[] memory _rates, bool _action) external onlyOperator {
        require(_batchId > 0 && _batchId <= batchId, "BondRouter: !_batchId");
        BatchInfo storage _info = batchInfo[_batchId];

        for (uint256 i = 0; i < _prices.length; i++) {
            if (_action) {
                InterestRate memory _rate = _rates[i];
                require(_prices.length == _rates.length, "BondRouter: invalid length");
                require(_info.bondPrice.add(_prices[i]), "BondRouter: !added");
                require(_rate.max <= ONE_HUNDRED_PERCENT && _rate.min <= ONE_HUNDRED_PERCENT, "BondRouter: greater than ONE_HUNDRED_PERCENT");
                require(_rate.max > _rate.min, "BondRouter: Max rate must greater min rate");
                _info.interestRates[_prices[i]] = _rate;
            } else {
                require(_info.bondPrice.remove(_prices[i]), "BondRouter: !removed");
                _info.interestRates[_prices[i]] = InterestRate({max:0, min: 0});
            }
        }
        emit UpdateBondPrice(_batchId, _prices, _rates, _action);
    }

    function executeRequest(uint256[] memory _ids) external onlyOperator {
        for (uint256 i = 0; i < _ids.length; i++) {
            require(listRequestId.contains(_ids[i]), "BondRouter: request id not in list");
            _executeRequest(_ids[i]);
        }
    }

    function updateStartTime(uint256 _value, uint256 _batchId) external onlyOperator {
        require(_batchId > 0 && _batchId <= batchId, "BondRouter: !_batchId");
        BatchInfo storage _info = batchInfo[_batchId];
        require(_value >= block.timestamp, "BondRouter: invalid value");
        uint256 _old = _info.config.startTime;
        _info.config.startTime = _value;
        emit UpdateStartTime(_old, _value, _batchId);
    }

    function updatePenaltyFee(uint256 _value) external onlyOperator {
        require(_value < ONE_HUNDRED_PERCENT, "BondRouter: invalid value");
        uint256 _old = penaltyFee;
        penaltyFee = _value;
        emit UpdatePenaltyFee(_old, _value);
    }

    function updateBatchStatus(uint256 _batchId, bool _status) external onlyOperator {
        require(_batchId > 0 && _batchId <= batchId, "BondRouter: !_batchId");
        batchInfo[_batchId].status = _status;
        emit UpdateBatchStatus(_batchId, _status);
    }

    function updateAdminWallet(address _value) external onlyOwner {
        require(_value != address(0), "BondRouter: invalid address");
        address _old = adminWallet;
        adminWallet = _value;
        emit UpdateAdminWallet(_old, _value);
    }

    function updateRefundAddress(address _value) external onlyOwner {
        require(_value != address(0), "BondRouter: invalid address");
        address _old = refundAddress;
        refundAddress = _value;
        emit UpdateRefundAddress(_old, _value);
    }

    function updateOperators(address _operator, bool _action) external onlyOwner {
        require(_operator != address(0), "BondRouter: !zero address");
        if (_action) {
            require(operators.add(_operator), "BondRouter: added");
        } else {
            require(operators.remove(_operator), "BondRouter: removed");
        }
        emit UpdateOperators(_operator, _action);
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


interface BondStruct {

    enum RequestType {REDEEM, HARVEST}
    enum RequestStatus {PENDING, EXECUTED}
    struct BondInfo {
        uint256 issueDate; // time issue
        uint256 lastHarvest; // last time harvest
        uint256 maturity; // last time harvest
        uint256 amount; // last time harvest
        uint256 interest; // interest
        uint256 batchId;
    }


    struct PendingRequest {
        RequestType requestType;
        RequestStatus status;
        address to;
        uint256 amount;
        uint256 createdAt;
        uint256 batchId;
        uint256[] tokenIds;
    }

    struct BatchConfig {
        uint256 totalFundRaise; // total fund
        uint256 startTime; // time to start
        uint256 maturity; // maturity date
        address currency; //
    }

    //bond nft from backed
    struct BackedBond {
        address nft;
        uint256[] ids;
    }

    struct InterestRate {
        uint256 max;
        uint256 min;
    }

    struct BatchInfo {
        bool status;
        uint256 raised; // current raised
        EnumerableSet.UintSet bondPrice;
        mapping(uint256 => InterestRate) interestRates;
        BackedBond[] backedBond;
        BatchConfig config;
    }

    struct BatchInfoResponse {
        bool status;
        uint256 raised; // current raised
        uint256[] bondPrice;
        InterestRate[] interestRate;
        BackedBond[] backedBond;
        BatchConfig config;
    }

    struct BuyingInfo {
        uint256 batchId;
        uint256 price;
        uint256 quantity;
    }

    struct ClaimInfo {
        uint256 batchId;
        uint256[] ids;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BondStruct.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IBondNFT is BondStruct, IERC721 {
    function info(uint256 id) external view returns (BondInfo memory _info);

    function unlock(uint256[] memory tokenIds) external;

    function lock(uint256[] memory tokenIds) external;

    function redeem(uint256[] memory tokenIds) external;

    function issue(address receiver_, uint256 quantity_, uint256 amount_, uint256 maturity_, uint256 interest_, uint256 _batchId) external;

    function updateLastHarvest(uint256[] memory tokenIds, address user) external;

    function currentSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBondRefund {
    function transfer(address _erc20, address _receiver, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BondStruct.sol";

interface IFactory is BondStruct {
    function createBondNFT(address issuer, string memory _name, string memory _symbol, string memory _uri) external returns (address);
}