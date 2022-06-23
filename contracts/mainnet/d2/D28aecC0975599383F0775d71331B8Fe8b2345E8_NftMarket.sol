/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// File: libs/IERC165.sol



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

// File: libs/ERC165.sol



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

// File: libs/IERC1155Receiver.sol



pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: libs/ERC1155Receiver.sol



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

// File: libs/ERC1155Holder.sol



pragma solidity ^0.8.0;


/**
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

// File: libs/IERC721Receiver.sol



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

// File: libs/ERC721Holder.sol



pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// File: libs/TransferHelper.sol



pragma solidity ^0.8.0;

library TransferHelper {
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}
// File: libs/Context.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/GSN/Context.sol
/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// File: libs/Ownable.sol


pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/ownership/Ownable.sol
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: libs/Adminable.sol



pragma solidity ^0.8.0;


abstract contract Adminable is Ownable {

    mapping(address => bool) public isAdmin;

    modifier onlyAdmin {
        require(isAdmin[msg.sender],"onlyAdmin: forbidden");
        _;
    }

    constructor () {
        isAdmin[msg.sender] = true;
    }

    function addAdmin(address _admin) external onlyOwner {
        require(_admin != address(0),"admin can not be address 0");
        isAdmin[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != address(0),"admin can not be address 0");
        isAdmin[_admin] = false;
    }
}
// File: libs/Pausable.sol



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

// File: libs/ReentrancyGuard.sol



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
     * by making the `nonReentrant` function external, and make it call a
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

// File: libs/Address.sol


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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
// File: libs/IERC20.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
// File: libs/SafeERC20.sol



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

// File: libs/CfoTakeable.sol



pragma solidity ^0.8.0;



abstract contract CfoTakeable is Ownable {
    using Address for address;
    using SafeERC20 for IERC20;

    event CfoTakedToken(address caller, address token, address to,uint256 amount);
    event CfoTakedETH(address caller,address to,uint256 amount);

    address public cfo;

    modifier onlyCfoOrOwner {
        require(msg.sender == cfo || msg.sender == owner(),"onlyCfo: forbidden");
        _;
    }

    constructor(){
        cfo = msg.sender;
    }

    function takeToken(address token,address to,uint256 amount) public onlyCfoOrOwner {
        require(token != address(0),"invalid token");
        require(amount > 0,"amount can not be 0");
        require(to != address(0) && !to.isContract(),"invalid to address");
        IERC20(token).safeTransfer(to, amount);

        emit CfoTakedToken(msg.sender,token,to, amount);
    }

    function takeETH(address to,uint256 amount) public onlyCfoOrOwner {
        require(amount > 0,"amount can not be 0");
        require(address(this).balance>=amount,"insufficient balance");
        require(to != address(0) && !to.isContract(),"invalid to address");
        
        payable(to).transfer(amount);

        emit CfoTakedETH(msg.sender,to,amount);
    }

    function takeAllToken(address token, address to) public {
        uint balance = IERC20(token).balanceOf(address(this));
        if(balance > 0){
            takeToken(token, to, balance);
        }
    }

    function takeAllTokenToSelf(address token) external {
        takeAllToken(token,msg.sender);
    }

    function takeAllETH(address to) public {
        uint balance = address(this).balance;
        if(balance > 0){
            takeETH(to, balance);
        }
    }

    function takeAllETHToSelf() external {
        takeAllETH(msg.sender);
    }

    function setCfo(address _cfo) external onlyOwner {
        require(_cfo != address(0),"_cfo can not be address 0");
        cfo = _cfo;
    }
}
// File: libs/CfoNftTakeable.sol



pragma solidity ^0.8.0;


interface IERC721TransferMin {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC1155TransferMin {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

abstract contract CfoNftTakeable is CfoTakeable {

    event CfoTakedERC721(address caller, address token, address to,uint256 tokenId);
    event CfoTakedERC1155(address caller,address token,address to,uint256 tokenId,uint256 amount);
    
    function takeERC721(address to,address token,uint tokenId) external onlyCfoOrOwner {
        require(to != address(0),"to can not be address 0");
        IERC721TransferMin(token).safeTransferFrom(address(this), to, tokenId);

        emit CfoTakedERC721(msg.sender,to,token,tokenId);
    }

    function takeERC1155(address to,address token,uint tokenId,uint amount) external onlyCfoOrOwner {
        require(to != address(0),"to can not be address 0");
        require(amount > 0,"amount can not be 0");
        IERC1155TransferMin(token).safeTransferFrom(address(this), to, tokenId,amount,"");

        emit CfoTakedERC1155(msg.sender,to,token,tokenId, amount);
    }
}
// File: libs/SafeMath.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/math/SafeMath.sol
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// File: libs/Math.sol


pragma solidity ^0.8.0;

// File: @openzeppelin/contracts/math/Math.sol
pragma solidity ^0.8.0;

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

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
// File: sDAO-NftMarket/nft-marketV2.sol



pragma solidity 0.8.4;











interface IERC721Transfer {
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
}

interface IERC1155Transfer {
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
}

contract NftMarket is CfoNftTakeable,Adminable,Pausable,ERC721Holder,ERC1155Holder,ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // address public immutable weth;
    // address public immutable stone;

    uint public immutable pledgeLockDuration;
    mapping(uint256 => uint256) public pledgeRateOf;

    uint public nextAuctionId = 1;
    mapping(uint256 => bytes32) public auctionHashOf;
    mapping(uint256 => AuctionRep) public auctionRepOf;
    mapping(uint256 => uint256) public rewardRateOf;
    mapping(uint256 => address) public auctionBidderOf;

    uint public globalFeeRate = 5 * 1e16;
    mapping(address => bool) public isSpecialFee;
    mapping(address => uint256) public specialFeeOf;

    uint public listingFee = 10 * 1e18;
    address public immutable stoneToken;

    address public medalFeeTo = address(0x414e6c1F77373c2D7218835d7998bFac2c05A99d);
    uint public medalFeeRate = 20 * 1e16;

    address public genesisFeeTo = address(0xB58d62162d502423C5251AE642e1D7a749E1BF36);
    uint public genesisFeeRate = 10 * 1e16;

    address public spacemanFeeTo = address(0x7f555cCf01Af73f393087e8605C9FCEad406c460);
    uint public spacemanFeeRate = 10 * 1e16;

    address public jointlyFeeTo = address(0x3151E011ec185891889a086773AA4189E2c58244);
    uint public jointlyFeeRate = 30 * 1e16;

    address public nftStakingFeeTo = address(0xB882E8ED53F22F2abee5FaE22d578ac4094211Fa);
    uint public nftStakingFeeRate = 30 * 1e16;

    address public listingFeeTo = address(0x5c3e578C590B288ce4e513c67Df9042C214C9C71);

    uint public minPledgeAmount;

    // mapping(address => bool) public isSupportToken;

    // struct Auction {
    //     address seller;
    //     address nftAddress;
    //     uint256 nftId;
    //     uint256 sellAmount;
    //     uint256 price;
    //     address priceToken;
    //     // address bidder;
    // }

    struct AuctionRep {
        uint64 startTime;
        uint64 deadline;
        uint32 isPledge;
        uint32 isERC1155;
        uint32 saleStatus;  // 0: onsale,1:sold,2:canceled
    }

    event AuctionCreated(uint auctionId,address seller,address nftAddress,uint nftId,uint sellAmount,uint price,address priceToken,uint startTime,uint deadline,bool isERC1155,bool isPledge);
    event AuctionTraded(address bidder,uint auctionId,uint feeAmount,uint pledgeReward,uint blockTime);
    event AuctionCanceled(address seller,uint auctionId,uint pledgeReward,uint blockTime);

    constructor(
        address _stone,
        uint _pledgeLockDuration
    ){
        require(_stone != address(0),"_stone can not be address 0");
        require(_pledgeLockDuration > 0,"_pledgeLockDuration can not be 0");

        stoneToken = _stone;
        pledgeLockDuration = _pledgeLockDuration;

        setPledgeRewardRate(1000*1e18,15 * 1e16);
        setPledgeRewardRate(10000*1e18,18 * 1e16);   
        setPledgeRewardRate(30000*1e18,20 * 1e16);   
        setPledgeRewardRate(type(uint256).max,25 * 1e16);  
    }

    function create(address nftAddress,uint nftId,bool isERC1155,uint sellAmount,uint price,address priceToken,uint deadline,bool isPledge) external whenNotPaused nonReentrant {
        require(nftAddress != address(0),"nft address can not be address 0");
        require(!isERC1155 || sellAmount > 0,"invalid sell amount");
        require(price > 0,"price can not be 0");
        require(deadline > block.timestamp,"invalid deadline");
        require(!isPledge || priceToken == stoneToken,"only sell for stone can use pledge");
        require(!isPledge || price >= minPledgeAmount,"pledge too low");

        address caller = msg.sender;
        uint f = listingFee;
        if(f > 0){
            IERC20(stoneToken).safeTransferFrom(caller,listingFeeTo,f);
        }
        if(isPledge){            
            IERC20(priceToken).safeTransferFrom(caller,address(this),price);
        }

        _transferFromNFT(caller, address(this), nftAddress, nftId, isERC1155, sellAmount);

        uint auctionId = nextAuctionId++;
        auctionHashOf[auctionId] = getAuctionHash(auctionId,caller,nftAddress,nftId,sellAmount,price,priceToken);

        AuctionRep memory rep = AuctionRep({
            startTime: _toUint64(block.timestamp),
            deadline: _toUint64(deadline),
            isPledge: isPledge ? 1 : 0,
            isERC1155: isERC1155 ? 1 : 0,
            saleStatus: 0
        });
        auctionRepOf[auctionId] = rep;

        if(isPledge){
            rewardRateOf[auctionId] = getRewardRate(price);
        }

        emit AuctionCreated(auctionId, caller, nftAddress, nftId,sellAmount,price,priceToken,rep.startTime,rep.deadline, rep.isERC1155==1,rep.isPledge==1);
    }

    function getAuctionHash(uint auctionId,address seller,address nftAddress,uint nftId,uint sellAmount,uint price,address priceToken) public pure returns(bytes32) {

        return keccak256(abi.encode(
            auctionId,
            seller,
            nftAddress,
            nftId,
            sellAmount,
            price,
            priceToken
        ));
    }

    function bid(uint auctionId,address seller,address nftAddress,uint nftId,uint sellAmount,uint price,address priceToken) external payable whenNotPaused nonReentrant {
        require(auctionId > 0,"auction id can not be 0");
        bytes32 auctionHash = getAuctionHash(auctionId, seller, nftAddress, nftId, sellAmount, price, priceToken);
        require(auctionHash != bytes32(0x0) && auctionHash == auctionHashOf[auctionId],"incorrect auction params");
        AuctionRep memory rep = auctionRepOf[auctionId];
        require(rep.saleStatus == 0,"auction has been traded or canceled");
        require(rep.deadline > block.timestamp,"expired");

        if(priceToken == address(0)){
            require(msg.value >= price,"insufficient input value");
        }else{
            uint balanceBefore = IERC20(priceToken).balanceOf(address(this));
            IERC20(priceToken).safeTransferFrom(msg.sender,address(this),price);
            require(IERC20(priceToken).balanceOf(address(this)).sub(balanceBefore) >= price,"insufficient received amount");
        }

        auctionBidderOf[auctionId] = msg.sender;
        auctionRepOf[auctionId].saleStatus = 1;
        
        uint feeAmount = price.mul(feeOf(priceToken)) / 1e18;
        uint sellerAmount = price.sub(feeAmount);
        uint pledgeReward = 0;
        if(rep.isPledge==1){
            sellerAmount = sellerAmount.add(price);
            pledgeReward = calcPledgeRewards(auctionId,rep.startTime,price);
            sellerAmount = sellerAmount.add(pledgeReward);
        }

        _distributeFee(priceToken,feeAmount);
        _transferToken(priceToken,seller,sellerAmount);

        _transferFromNFT(address(this), msg.sender, nftAddress, nftId, rep.isERC1155==1, sellAmount);

        emit AuctionTraded(msg.sender, auctionId, feeAmount,pledgeReward,block.timestamp);
    }

    function cancel(uint auctionId,address seller,address nftAddress,uint nftId,uint sellAmount,uint price,address priceToken) external whenNotPaused nonReentrant {
        require(auctionId > 0,"auction id can not be 0");
        require(msg.sender == seller,"caller must be seller");
        bytes32 auctionHash = getAuctionHash(auctionId, seller, nftAddress, nftId, sellAmount, price, priceToken);
        require(auctionHash != bytes32(0x0) && auctionHash == auctionHashOf[auctionId],"incorrect auction params");
        AuctionRep memory rep = auctionRepOf[auctionId];
        require(rep.saleStatus == 0,"auction has been traded or canceled");
        require(rep.isPledge==0 || block.timestamp > pledgeLockDuration.add(rep.startTime),"pledge token locked");

        auctionRepOf[auctionId].saleStatus = 2;

        uint pledgeReward = 0;
        if(rep.isPledge==1){
            pledgeReward = calcPledgeRewards(auctionId, rep.startTime,price);
            uint sellerAmount = price.add(pledgeReward);
            IERC20(priceToken).safeTransfer(seller,sellerAmount);          
        }

        _transferFromNFT(address(this), msg.sender, nftAddress, nftId, rep.isERC1155==1, sellAmount);

        emit AuctionCanceled(msg.sender, auctionId,pledgeReward,block.timestamp);
    }

    function calcPledgeRewards(uint auctionId,uint startTime,uint pledgeAmount) public view returns(uint){
        uint pledgeLockDuration_ = pledgeLockDuration;
        uint rewardTo = Math.min(block.timestamp,startTime.add(pledgeLockDuration_));
        uint rewardRate = rewardRateOf[auctionId];
        return pledgeAmount.mul(rewardRate).mul(rewardTo.sub(startTime)) / 1e18 / pledgeLockDuration_;
    }

    function getRewardRate(uint pledgeAmount) view public returns(uint){
        if(pledgeAmount < 1000 * 1e18) return pledgeRateOf[1000 * 1e18];
        if(pledgeAmount < 10000 * 1e18) return pledgeRateOf[10000 * 1e18];
        if(pledgeAmount < 30000 * 1e18) return pledgeRateOf[30000 * 1e18];

        return pledgeRateOf[type(uint256).max];
    }

    function _transferToken(address token,address to,uint amount) internal {
        if(token == address(0)){
            TransferHelper.safeTransferETH(to, amount);
        }else{
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function _distributeFee(address token,uint fee) internal {
        IERC20 token_ = IERC20(token);
        token_.safeTransfer(medalFeeTo,fee.mul(medalFeeRate) / 1e18);
        token_.safeTransfer(genesisFeeTo,fee.mul(genesisFeeRate) / 1e18);
        token_.safeTransfer(spacemanFeeTo,fee.mul(spacemanFeeRate) / 1e18);
        token_.safeTransfer(jointlyFeeTo,fee.mul(jointlyFeeRate) / 1e18);
        token_.safeTransfer(nftStakingFeeTo,fee.mul(nftStakingFeeRate) / 1e18);
    }

    function _transferFromNFT(address from,address to, address nftAddress,uint nftId,bool isERC1155,uint amount) internal {
        if(isERC1155){
            IERC1155Transfer(nftAddress).safeTransferFrom(from, to, nftId, amount, "");
        }else{
            IERC721Transfer(nftAddress).safeTransferFrom(from, to, nftId);
        }
    }

    function _toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function pledgeEarneds(uint[] calldata auctionIds,uint[] calldata prices) external view returns(uint[] memory _rewards,uint[] memory _rewardRates){
        require(auctionIds.length > 0,"auctionIds can not be empty");
        _rewards = new uint[](auctionIds.length);
        _rewardRates = new uint[](auctionIds.length);
        for(uint i=0;i<auctionIds.length;i++){
            AuctionRep memory rep = auctionRepOf[auctionIds[i]];
            if(rep.isPledge == 1){
                _rewardRates[i] = rewardRateOf[auctionIds[i]];
                _rewards[i] = rep.saleStatus == 0 ? calcPledgeRewards(auctionIds[i],auctionRepOf[auctionIds[i]].startTime,prices[i]) : 0;
            }
        }
    }

    function infos() external view returns(address _stone,address _listingFeeTo,uint _pledgeLockDuration,uint _globalFeeRate, uint[] memory _rewardRates,uint _minPledgeAmount){
        _stone = stoneToken;
        _listingFeeTo = listingFeeTo;
        _pledgeLockDuration = pledgeLockDuration;
        _globalFeeRate = globalFeeRate;

        _rewardRates = new uint[](4);
        _rewardRates[0] = pledgeRateOf[1000*1e18];
        _rewardRates[1] = pledgeRateOf[10000*1e18];
        _rewardRates[2] = pledgeRateOf[30000*1e18];
        _rewardRates[3] = pledgeRateOf[type(uint256).max];

        _minPledgeAmount = minPledgeAmount;
    }

    function setPledgeRewardRate(uint _pledgeCap,uint _pledgeRewardRate) public onlyAdmin {
        require(_pledgeCap == 1000*1e18 || _pledgeCap == 10000*1e18 || _pledgeCap == 30000*1e18 ||  _pledgeCap == type(uint256).max,"invaild pledgeCap");
        pledgeRateOf[_pledgeCap] = _pledgeRewardRate;
    }

    function feeOf(address priceToken) public view returns(uint){
        return isSpecialFee[priceToken] ? specialFeeOf[priceToken] : globalFeeRate;
    }

    function setGlobalFee(uint _feeRate) external onlyAdmin {
        require(_feeRate <= 1e18,"fee can not greater than 1e18");
        globalFeeRate = _feeRate;
    }

    function feeTos() external view returns(address _medalFeeTo,address _genesisFeeTo,address _spacemanFeeTo,address _jointlyFeeTo,address _nftStakingFeeTo){
        _medalFeeTo = medalFeeTo;
        _genesisFeeTo = genesisFeeTo;
        _spacemanFeeTo = spacemanFeeTo;
        _jointlyFeeTo = jointlyFeeTo;
        _nftStakingFeeTo = nftStakingFeeTo;
    }

    function feeRates() external view returns(uint _medalFeeRate,uint _genesisFeeRate,uint _spacemanFeeRate,uint _jointlyFeeRate,uint _nftStakingFeeRate){
        _medalFeeRate = medalFeeRate;
        _genesisFeeRate = genesisFeeRate;
        _spacemanFeeRate = spacemanFeeRate;
        _jointlyFeeRate = jointlyFeeRate;
        _nftStakingFeeRate = nftStakingFeeRate;
    }

    function setFeeTos(address _medalFeeTo,address _genesisFeeTo,address _spacemanFeeTo,address _jointlyFeeTo,address _nftStakingFeeTo) external onlyAdmin {
        require(_medalFeeTo != address(0),"_medalFeeTo can not be address 0");
        require(_genesisFeeTo != address(0),"_medalFeeTo can not be address 0");
        require(_spacemanFeeTo != address(0),"_medalFeeTo can not be address 0");
        require(_jointlyFeeTo != address(0),"_medalFeeTo can not be address 0");
        require(_nftStakingFeeTo != address(0),"_medalFeeTo can not be address 0");

        medalFeeTo = _medalFeeTo;
        genesisFeeTo = _genesisFeeTo;
        spacemanFeeTo = _spacemanFeeTo;
        jointlyFeeTo = _jointlyFeeTo;
        nftStakingFeeTo = _nftStakingFeeTo;
    }

    function setFeeRates(uint _medalFeeRate,uint _genesisFeeRate,uint _spacemanFeeRate,uint _jointlyFeeRate,uint _nftStakingFeeRate) external onlyAdmin {
        require(_medalFeeRate.add(_genesisFeeRate).add(_spacemanFeeRate).add(_jointlyFeeRate).add(_nftStakingFeeRate) == 1e18,"sum of fee rates can not greater than 1e18");
        medalFeeRate = _medalFeeRate;
        genesisFeeRate = _genesisFeeRate;
        spacemanFeeRate = _spacemanFeeRate;
        jointlyFeeRate = _jointlyFeeRate;
        nftStakingFeeRate = _nftStakingFeeRate;
    }

    function setSpecialFee(address priceToken,uint _feeRate) external onlyAdmin {
        require(priceToken != address(0),"ido can not be address 0");
        require(_feeRate <= 1e18,"fee can not greater than 1e18");
        isSpecialFee[priceToken] = true;
        specialFeeOf[priceToken] = _feeRate;
    }

    function removeSpecialFee(address priceToken) external onlyAdmin {
        require(priceToken != address(0),"ido can not be address 0");
        isSpecialFee[priceToken] = false;
    }

    // function setListingFeeToken(address _listingFeeToken) public onlyAdmin {
    //     listingFeeToken = _listingFeeToken;
    // }

    function setListingFee(uint _listingFee) external onlyAdmin {
        listingFee = _listingFee;
    }

    function setListingFeeTo(address _listingFeeTo) external onlyAdmin {
        listingFeeTo = _listingFeeTo;
    }

    // function setPledgeToken(address _pledgeToken) public onlyAdmin {
    //     pledgeToken = _pledgeToken;
    // }

    function setMinPledgeAmount(uint _minPledgeAmount) external onlyAdmin {
        minPledgeAmount = _minPledgeAmount;
    }
}