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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

abstract contract ERC1155Receiver is IERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
            interfaceId == 0x4e2312e0; // ERC-1155 `ERC1155TokenReceiver` support
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

abstract contract ERC721Receiver is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return ERC721Receiver.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

import "../external/Library.sol";
import "../external/IStargateRouter.sol";


/// @title Main contract which serves as the entry point
interface IMultichainPortal {
    struct StargateArgs {
        uint16 dstChainId;
        uint16 srcPoolId;
        uint16 dstPoolId;
        uint256 minAmountOut;
        IStargateRouter.lzTxObj lzTxObj;
        address receiver;
        bytes data;
    }

    struct Payload {
        address user;
        address swapRouter;
        bytes swapArguments;
        Types.ICall[] calls;
    }

    function swapERC20AndCall(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address user,
        address swapRouter,
        bytes calldata swapArguments,
        Types.ICall[] calldata calls
    ) external;

    function swapNativeAndCall(
        address tokenOut,
        address user,
        address swapRouter,
        bytes calldata swapArguments,
        Types.ICall[] calldata calls
    ) external payable;

    function swapERC20AndSend(
        uint amountIn,
        uint amountUSDC,
        address user,
        address tokenIn,
        address swapRouter,
        bytes calldata swapArguments,
        StargateArgs memory stargateArgs
    ) external payable;

    function swapNativeAndSend(
        uint amountIn,
        uint amountUSDC,
        uint lzFee,
        address user,
        address swapRouter,
        bytes calldata swapArguments,
        IMultichainPortal.StargateArgs memory stargateArgs
    ) external payable;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC1155Receiver.sol";
import "./IMultichainPortal.sol";
import "./ERC721Receiver.sol";
import "../external/Library.sol";
import "../external/IStargateReceiver.sol";
import "../external/IStargateRouter.sol";


// solhint-disable avoid-low-level-calls
error NotFromRouter();
contract MultichainPortal is
    IMultichainPortal,
    Initializable,
    Pausable,
    Ownable,
    ERC721Receiver,
    ERC1155Receiver,
    IStargateReceiver
{
    using SafeERC20 for IERC20;

    uint256 public fee;
    address public beneficiary;
    address public portalRouter;
    address public usdc;
    uint16 public lastChainId;
	bytes public lastSrcAddress;
	uint256 public lastNonce;
    address public stargateRouter;
    string public lastErr;

    event SwapCallError(string reason);

    function initialize(
        address _portalRouter,
        address _stargateRouter,
        address _beneficiary,
        address _usdc,
        uint256 _fee
    ) external initializer {
        portalRouter = _portalRouter;
        stargateRouter = _stargateRouter;
        beneficiary = _beneficiary;
        usdc = _usdc;
        fee = _fee;
    }

    receive() external payable {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /// @dev called by Stargate on destination chain
    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes calldata payload
    ) external override {
		if (msg.sender != stargateRouter) revert NotFromRouter();
        
        lastChainId = _chainId;
		lastSrcAddress = _srcAddress;
		lastNonce = _nonce;
        
        _processRequest(_token, amountLD, payload);
	}

    /// @dev swaps erc20 tokens on source chain into usdc and sends to stargate
    function swapERC20AndSend(
        uint amountIn,
        uint amountUSDC,
        address user,
        address tokenIn,
        address swapRouter,
        bytes calldata swapArguments,
        IMultichainPortal.StargateArgs memory stargateArgs
    ) external payable override whenNotPaused {
        require(msg.value > 0, "stargate requires a msg.value to pay crosschain message"); //TODO: modifiers
        require(amountIn > 0, "error: swap() requires qty > 0");

        // if swaprouter address in address(0), assume tokenIn is usdc and do not swap
        IERC20 _tokenIn = IERC20(tokenIn);
        uint256 initialBalance = _tokenIn.balanceOf(address(this));
        if (swapRouter != address(0)) {
            _swapERC20(tokenIn, amountIn, user, swapRouter, swapArguments, initialBalance);
        }

        this.send{value:msg.value}(
            amountUSDC,
            stargateArgs.dstChainId,
            stargateArgs.srcPoolId,
            stargateArgs.dstPoolId,
            stargateArgs.minAmountOut,
            stargateArgs.lzTxObj,
            stargateArgs.receiver,
            stargateArgs.data
        );
    }

    /// @dev swaps native tokens on source chain into usdc and sends to stargate
    function swapNativeAndSend(
        uint amountIn,
        uint amountUSDC,
        uint lzFee,
        address user,
        address swapRouter,
        bytes calldata swapArguments,
        IMultichainPortal.StargateArgs memory stargateArgs
    ) external payable override whenNotPaused {
        require(msg.value > amountIn, "stargate requires a msg.value to pay crosschain message");
        require(amountIn > 0, "error: swap() requires qty > 0");

        // if swaprouter address in address(0), assume tokenIn is usdc and do not swap
        uint256 initialBalance = address(this).balance;
        if (swapRouter != address(0)) {
            (bool successfulSwap, bytes memory result) = swapRouter.call{value: amountIn}(
                swapArguments
            );

            if (!successfulSwap) {
                _extractReasonString(result);
            }
 
            uint256 swapCost = initialBalance - address(this).balance;
            uint256 overpayment = msg.value - swapCost - lzFee;

            (bool successfulReimbursement, ) = user.call{value: overpayment}("");
            require(successfulReimbursement, "reimbursement failed");
        }

        this.send{value:lzFee}(
            amountUSDC,
            stargateArgs.dstChainId,
            stargateArgs.srcPoolId,
            stargateArgs.dstPoolId,
            stargateArgs.minAmountOut,
            stargateArgs.lzTxObj,
            stargateArgs.receiver,
            stargateArgs.data
        );

    }

    /// @param qty The number of tokens to send
    /// @param dstChainId the destination chain id
    /// @param srcPoolId the source Stargate poolId
    /// @param dstPoolId the destination Stargate poolId 
    /// @param minAmountOut minimum amount of tokens allowed out
    /// @param lzTxObj the layer zero transaction object 
    /// @param receiver destination address, the sgReceive() implementer
    /// @param data The bytes containing the payload
    function send(
        uint qty,
        uint16 dstChainId,
        uint16 srcPoolId,
        uint16 dstPoolId,
        uint256 minAmountOut,
        IStargateRouter.lzTxObj memory lzTxObj,
        address receiver,
        bytes calldata data
    ) external payable {
        require(msg.sender == address(this), "can only be called by portal");
        require(msg.value > 0, "stargate requires a msg.value to pay crosschain message");
        require(qty > 0, "error: swap() requires qty > 0");

        
        (uint256 brydgeFee, uint256 postFeeAmountIn) = _calculateFee(qty);
        IERC20(usdc).safeTransfer(beneficiary, brydgeFee);

        IERC20(usdc).approve(address(stargateRouter), postFeeAmountIn);

        // Stargate's Router.swap() function sends the tokens to the destination chain.
        IStargateRouter(stargateRouter).swap{value:msg.value}(
            dstChainId,
            srcPoolId,
            dstPoolId,
            payable(beneficiary),                            // TODO: refund to user, not to beneficiary
            postFeeAmountIn,
            minAmountOut,
            lzTxObj,
            abi.encodePacked(receiver),
            data
        );
    }

    /// @dev decodes arguments and executes rawRequestData on destination chain
    function _processRequest(address _token, uint256 amountLD, bytes calldata rawRequestData) internal {
        (
            address user,
            address tokenOut,
            address swapRouter, // swap contract address
            bytes memory swapArguments, // swap contract arguments
            Types.ICall[] memory calls // call list
        ) = abi.decode(rawRequestData, (address, address, address, bytes, Types.ICall[]));

        try
            this.swapERC20AndCall(_token, tokenOut, amountLD, user, swapRouter, swapArguments, calls)
        {} catch Error(string memory reason) {
            // This is executed in case
            // revert was called inside getData
            // and a reason string was provided.
            emit SwapCallError(reason);
            lastErr = reason;
            IERC20(_token).safeTransfer(user, amountLD);
        } catch (bytes memory reason) {
            // This is executed in case revert() was used
            // or there was a failing assertion, division
            // by zero, etc. inside getData.
            if (reason.length < 68) emit SwapCallError("unknown error");
            // solhint-disable-next-line no-inline-assembly
            assembly {
                reason := add(reason, 0x04)
            }
            emit SwapCallError(abi.decode(reason, (string)));
            lastErr = abi.decode(reason, (string));
            IERC20(_token).safeTransfer(user, amountLD);
        }
        
    }

    /// @dev swap Native token for desired output token and execute calls on destination chain
    function swapNativeAndCall(
        address tokenOut,
        address user,
        address swapRouter,
        bytes calldata swapArguments,
        Types.ICall[] calldata calls
    ) external payable whenNotPaused {
        if (msg.sender != portalRouter && msg.sender != address(this)) {
            revert("Cannot be called directly");
        }

        IERC20 token = IERC20(tokenOut);
        uint256 initialOutBalance;
        if (tokenOut != address(0)) {
            initialOutBalance = token.balanceOf(address(this));
        } else {
            // Native token output
            initialOutBalance = address(this).balance;
        }

        uint256 initialBalance = address(this).balance;
        (uint256 brydgeFee, uint256 postFeeAmountIn) = _calculateFee(msg.value);
        (bool successfulFeePayment, ) = beneficiary.call{value: brydgeFee}("");
        require(successfulFeePayment, "Brydge fee payment failed");

        if (swapRouter != address(0)) {
            (bool successfulSwap, bytes memory result) = swapRouter.call{value: postFeeAmountIn}(
                swapArguments
            );

            if (!successfulSwap) {
                revert(_extractReasonString(result));
            }

            uint256 swapCost = initialBalance - address(this).balance;
            if (msg.value > swapCost) {
                (bool successfulReimbursement, ) = user.call{value: msg.value-swapCost}("");
                require(successfulReimbursement, "reimbursement failed");
            }
        }

        _handleCalls(calls);

        /// send any remaining tokens back to the user
        if (tokenOut != address(0)) {
            if (token.balanceOf(address(this)) > initialOutBalance) {
                token.safeTransfer(user, token.balanceOf(address(this)) - initialOutBalance);
            }
        } else {
            // Native token output
            if (address(this).balance > initialOutBalance) {
                (bool success, ) = user.call{value: address(this).balance - initialOutBalance}("");
                require(success, "reimbursement failed");
            }
        }
    }

    /// @dev swap erc20 for desired output token and execute calls on destination chain
    function swapERC20AndCall(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address user,
        address swapRouter,
        bytes calldata swapArguments,
        Types.ICall[] calldata calls
    ) external virtual whenNotPaused {
        if (msg.sender != portalRouter && msg.sender != address(this)) {
            revert("Cannot be called directly");
        }

        IERC20 token = IERC20(tokenOut);
        uint256 initialBalance;
        if (tokenOut == tokenIn) {
            initialBalance = token.balanceOf(address(this)) - amountIn;
        } else if (tokenOut != address(0)) {
            initialBalance = token.balanceOf(address(this));
        } else {
            // Native token output
            initialBalance = address(this).balance;
        }

        IERC20 _tokenIn = IERC20(tokenIn);
        uint256 inTokenBalance = _tokenIn.balanceOf(address(this));
        (uint256 brydgeFee,) = _calculateFee(amountIn);
        if (msg.sender != address(this)) { //not from stargate
            _tokenIn.safeTransfer(beneficiary, brydgeFee);
        }

        if (swapRouter != address(0)) {
            _swapERC20(tokenIn, amountIn, user, swapRouter, swapArguments, inTokenBalance);
        }

        _handleCalls(calls);

        /// send any remaining tokens back to the user
        if (tokenOut != address(0)) {
            if (token.balanceOf(address(this)) > initialBalance) {
                token.safeTransfer(user, token.balanceOf(address(this)) - initialBalance);
            }
        } else {
            // Native token output
            if (address(this).balance > initialBalance) {
                (bool success, ) = user.call{value: address(this).balance - initialBalance}("");
                require(success, "reimbursement failed");
            }
        }
    }

    function _handleCalls(Types.ICall[] calldata calls) internal {
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory reason) = calls[i]._to.call{value: calls[i]._value}(
                calls[i]._calldata
            );

            if (!success) {
                revert(_extractReasonString(reason));
            }
        }
    }

    function _swapERC20(
        address tokenIn,
        uint256 amountIn,
        address user,
        address swapRouter,
        bytes calldata swapArguments,
        uint256 initialBalance
    ) internal {
        IERC20 token = IERC20(tokenIn);        
        _handleERC20Approval(tokenIn, swapRouter, amountIn);
        (bool successfulSwap, bytes memory result) = swapRouter.call(swapArguments);

        if (!successfulSwap) {
            revert(_extractReasonString(result));
        }

        uint256 swapCost = initialBalance - token.balanceOf(address(this));
        if (amountIn > swapCost) {
            token.safeTransfer(user, amountIn - swapCost);
        }
    }

    function _handleERC20Approval(
        address token,
        address operator,
        uint256 amount
    ) internal {
        if (IERC20(token).allowance(address(this), operator) < amount) {
            IERC20(token).approve(
                operator,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            );
        }
    }

    function _calculateFee(uint256 amountIn) internal view returns (uint256, uint256) {
        uint256 brydgeFee = mulDiv(amountIn, fee, 1000);
        uint256 postFeeAmountIn = amountIn - brydgeFee;
        return (brydgeFee, postFeeAmountIn);
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        uint256 a = x / z;
        uint256 b = x % z; // x = a * z + b
        uint256 c = y / z;
        uint256 d = y % z; // y = c * z + d
        return a * c * z + a * d + b * c + (b * d) / z;
    }

    function _extractReasonString(bytes memory reason) internal pure returns (string memory) {
        if (reason.length < 68) return "swap failed";
        // solhint-disable-next-line no-inline-assembly
        assembly {
            reason := add(reason, 0x04)
        }
        return abi.decode(reason, (string));
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.14;

interface IStargateReceiver {
    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes memory payload
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.14;
pragma abicoder v2;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.14;

library Types {
    struct ICall {
        address _to;
        uint256 _value;
        bytes _calldata;
    }
}