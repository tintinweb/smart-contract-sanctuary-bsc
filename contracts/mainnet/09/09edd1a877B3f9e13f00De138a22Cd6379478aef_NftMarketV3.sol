/**
 *Submitted for verification at BscScan.com on 2022-08-04
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
// File: libs/SafeCast.sol



pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
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
// File: sDAO-NftMarket/nft-marketV3.sol



pragma solidity 0.8.4;












interface IERC721Transfer {
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
}

interface IERC1155Transfer {
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
}

interface INFTFactory {
    function collectionIdOf(address nftAddress) external view returns(uint);
}

interface INFTCollection {
    function author() external view returns(address);

    function authorFee() external view returns(uint);
}

contract NftMarketV3 is CfoNftTakeable,Adminable,Pausable,ERC721Holder,ERC1155Holder,ReentrancyGuard {
    using SafeCast for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private constant ETHAddress = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    uint private immutable pledgeLockDuration;
    mapping(uint256 => uint256) public pledgeRateOf;

    uint public nextAuctionId = 1;
    mapping(uint256 => bytes32) public auctionHashOf;
    mapping(uint256 => AuctionRep) public auctionRepOf;
    mapping(uint256 => address) public lastBidderOf;
    mapping(uint256 => uint256) public lastBidPriceOf;
    mapping(uint256 => DutchInfo) public DutchOf;

    mapping(uint256 => uint256) public rewardRateOf;

    uint public globalFeeRate = 5 * 1e16;
    mapping(address => bool) public isSpecialFee;
    mapping(address => uint256) public specialFeeOf;

    // testnet
    // address public constant sdtToken = address(0x98CF2d5f059E6A469AB6CA185C492193202c9217);

    //mainnet
    address public constant sdtToken = address(0x1eeAf13BD1b50d510D25880cC302403478db7097);

    address public immutable nftFactory; 
    address public sdtVault;

    uint public listingFee;
    address private constant listingFeeToken = sdtToken;

    address private medalFeeTo = address(0x414e6c1F77373c2D7218835d7998bFac2c05A99d);
    uint private medalFeeRate = 20 * 1e16;

    address private genesisFeeTo = address(0xB58d62162d502423C5251AE642e1D7a749E1BF36);
    uint private genesisFeeRate = 10 * 1e16;

    address private spacemanFeeTo = address(0x7f555cCf01Af73f393087e8605C9FCEad406c460);
    uint private spacemanFeeRate = 10 * 1e16;

    address private jointlyFeeTo = address(0x3151E011ec185891889a086773AA4189E2c58244);
    uint private jointlyFeeRate = 30 * 1e16;

    address private nftStakingFeeTo = address(0xB882E8ED53F22F2abee5FaE22d578ac4094211Fa);
    uint private nftStakingFeeRate = 30 * 1e16;

    address private listingFeeTo = address(0x5c3e578C590B288ce4e513c67Df9042C214C9C71);

    mapping(address => bool) public isRelayer;

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
        uint16 saleStatus;  // 0: onsale,1:sold,2:canceled
        uint16 saleType; // 0：one time offer,1:english auction,2: dutch auction
    }

    struct DutchInfo {
        uint128 periodSeconds;
        uint128 isDecrByFixed; // 0:percent，1：fix amount
        uint decrEachPeriod;
        uint minPrice;
    }

    struct AuctionParams {
        address nftAddress;
        uint nftId;
        bool isERC1155;
        uint sellAmount;
        uint startPrice;
        address priceToken;
        uint duration;
        bool isPledge;
        uint saleType;
    }

    struct BaseParams {
        uint auctionId;
        address seller;
        address nftAddress;
        uint nftId;
        uint sellAmount;
        uint startPrice;
        address priceToken;
    }

    event AuctionCreated(uint auctionId,address seller, bytes32[] auctionParas,bytes32[] dutchParas,uint blockTime);
    event AuctionBided(address bidder,uint auctionId,uint bidPrice,uint blockTime);
    event AuctionTraded(address bidder,uint auctionId,uint dealPrice,uint feeAmount,uint pledgeReward,uint blockTime);
    event AuctionCanceled(address seller,uint auctionId,uint pledgeReward,uint blockTime);

    constructor(
        uint _pledgeLockDuration,
        address _nftFactory,
        address _sdtVault
    ){
        require(_pledgeLockDuration > 0,"_pledgeLockDuration can not be 0");

        pledgeLockDuration = _pledgeLockDuration;
        nftFactory = _nftFactory;
        sdtVault = _sdtVault;

        setPledgeRewardRate(1000*1e18,15 * 1e16);
        setPledgeRewardRate(10000*1e18,18 * 1e16);   
        setPledgeRewardRate(30000*1e18,20 * 1e16);   
        setPledgeRewardRate(type(uint256).max,25 * 1e16);
    }

    // address nftAddress,uint nftId,bool isERC1155,uint sellAmount,uint startPrice,address priceToken,uint duration,bool isPledge,saleType
    // auctionParas[0]: nftAddress
    // auctionParas[1]: nftId
    // auctionParas[2]: isERC1155
    // auctionParas[3]: sellAmount
    // auctionParas[4]: startPrice
    // auctionParas[5]: priceToken
    // auctionParas[6]: duration
    // auctionParas[7]: isPledge
    // auctionParas[8]: saleType
    // dutchParas[0]: dutch periodSeconds
    // dutchParas[1]: dutch isDecrByFixed
    // dutchParas[2]: dutch decrEachPeriod
    // dutchParas[3]: dutch minPrice
    function create(bytes32[] calldata auctionParas,bytes32[] calldata dutchParas) external whenNotPaused nonReentrant {
        AuctionParams memory paras = _getCreateParams(auctionParas);
        DutchInfo memory dutchParas_ = _getDutchParams(dutchParas);
        require(_checkCreateParams(paras,dutchParas_),"check params failed");

        if(listingFee > 0){
            IERC20(listingFeeToken).safeTransferFrom(msg.sender,listingFeeTo,listingFee);
        }
        if(paras.isPledge){    
            _transferFromToken(paras.priceToken,paras.startPrice);
        }

        _transferFromNFT(msg.sender, address(this), paras.nftAddress, paras.nftId, paras.isERC1155, paras.sellAmount);

        uint auctionId = nextAuctionId++;
        auctionHashOf[auctionId] = getAuctionHash(auctionId,msg.sender,paras.nftAddress,paras.nftId, paras.sellAmount,paras.startPrice,paras.priceToken);

        AuctionRep memory rep = AuctionRep({
            startTime: block.timestamp.toUint64(),
            deadline: block.timestamp.add(paras.duration).toUint64(),
            isPledge: paras.isPledge ? 1 : 0,
            isERC1155: paras.isERC1155 ? 1 : 0,
            saleStatus: 0,
            saleType: paras.saleType.toUint16()
        });
        auctionRepOf[auctionId] = rep;
        if(paras.saleType == 2){
            DutchOf[auctionId] = dutchParas_;
        }

        if(paras.isPledge){
            rewardRateOf[auctionId] = getRewardRate(paras.startPrice);
        }

        emit AuctionCreated(auctionId, msg.sender, auctionParas,dutchParas,block.timestamp);
    }

    function _getCreateParams(bytes32[] calldata paras) internal pure returns(AuctionParams memory paras_){
        paras_ = AuctionParams({
            nftAddress: _bytes32ToAddress(paras[0]),
            nftId: uint(paras[1]),
            isERC1155: uint(paras[2]) > 0,
            sellAmount: uint(paras[3]),
            startPrice: uint(paras[4]),
            priceToken: _bytes32ToAddress(paras[5]),
            duration: uint(paras[6]),
            isPledge: uint(paras[7]) > 0,
            saleType: uint(paras[8])
        });

        // if(!paras_.isERC1155){
        //     paras_.sellAmount = 1;
        // }
    }

    function _getDutchParams(bytes32[] calldata dutchParas) internal pure returns(DutchInfo memory paras_){
        paras_ = DutchInfo({
            periodSeconds: SafeCast.toUint128(uint(dutchParas[0])),
            isDecrByFixed: uint(dutchParas[1]) > 0 ? 1 : 0,
            decrEachPeriod: uint(dutchParas[2]),
            minPrice: uint(dutchParas[3])
        });
    }

    function _checkCreateParams(AuctionParams memory paras,DutchInfo memory dutchParas_) internal pure returns(bool){
        require(paras.priceToken != address(0),"nft address can not be address 0");
        require(paras.isERC1155 && paras.sellAmount > 0 || !paras.isERC1155 && paras.sellAmount == 1,"invalid sell amount");
        require(paras.startPrice > 0,"start price can not be 0");
        require(paras.priceToken != address(0),"priceToken can not be address 0");
        require(paras.duration > 0,"invalid duration");
        if(paras.isPledge){
            require(paras.priceToken == sdtToken,"only sell for sdt can use pledge");
            // require(paras.startPrice >= minPledgeAmount,"pledge too low");
            require(paras.saleType == 0,"pledge only for one time offer");
        }
        require(paras.saleType < 3,"invalid sale type");
        if(paras.saleType == 2){
            require(dutchParas_.periodSeconds > 0 && dutchParas_.periodSeconds < paras.duration,"invalid dutch periodSeconds");
            require(dutchParas_.minPrice < paras.startPrice,"invalid dutch min price");
            require(dutchParas_.isDecrByFixed == 1 && dutchParas_.decrEachPeriod < paras.startPrice || dutchParas_.isDecrByFixed == 0 && dutchParas_.decrEachPeriod < 1e18,"invalid dutch decrEachPeriod");           
        }

        return true;
    }

    function getAuctionHash(uint auctionId,address seller,address nftAddress,uint nftId,uint sellAmount,uint startPrice,address priceToken) public pure returns(bytes32) {

        return keccak256(abi.encode(
            auctionId,
            seller,
            nftAddress,
            nftId,
            sellAmount,
            startPrice,
            priceToken
        ));
    }

    // paras[0]: auctionId
    // paras[1]: seller
    // paras[2]: nftAddress
    // paras[3]: nftId
    // paras[4]: sellAmount
    // paras[5]: startPrice
    // paras[6]: priceToken
    function _getBaseParams(bytes32[] calldata paras) internal pure returns(BaseParams memory baseParas_){
        baseParas_ = BaseParams({
            auctionId: uint(paras[0]),
            seller: _bytes32ToAddress(paras[1]),
            nftAddress: _bytes32ToAddress(paras[2]),
            nftId: uint(paras[3]),
            sellAmount: uint(paras[4]),
            startPrice: uint(paras[5]),
            priceToken: _bytes32ToAddress(paras[6])
        });
    }

    function _checkBaseParams(BaseParams memory paras) internal view returns(bool){
        bytes32 auctionHash = getAuctionHash(paras.auctionId, paras.seller, paras.nftAddress, paras.nftId, paras.sellAmount, paras.startPrice, paras.priceToken);
        require(auctionHash != bytes32(0x0) && auctionHash == auctionHashOf[paras.auctionId],"incorrect auction params");

        return true;
    }

    function bid(bytes32[] calldata baseParams,uint bidPrice) external payable nonReentrant {
        require(!Address.isContract(msg.sender),"caller can not be contract");
        BaseParams memory paras = _getBaseParams(baseParams);
        require(_checkBaseParams(paras),"incorrect base params");
        require(paras.auctionId > 0,"auction id can not be 0");
        require(msg.sender != paras.seller,"caller can not be seller");

        AuctionRep memory rep = auctionRepOf[paras.auctionId];
        require(rep.saleStatus == 0,"auction has been traded or canceled");
        require(rep.startTime <= block.timestamp,"auction not start");
        require(rep.deadline > block.timestamp,"auction ended");
        if(rep.saleType == 0){
             require(bidPrice == paras.startPrice,"one time offer auction: invalid price");
        }else if(rep.saleType == 1){
            uint sprice = lastBidPriceOf[paras.auctionId];
            require(sprice > 0 && bidPrice > sprice || sprice == 0 && bidPrice >= paras.startPrice,"english auction: invalid price");
        }else{
            uint sprice = lastBidPriceOf[paras.auctionId];
            require(sprice > 0 && bidPrice > sprice || sprice == 0 && bidPrice >= calcDutchPrice(paras.auctionId,paras.startPrice,rep.startTime,rep.deadline),"dutch auction: invalid price");
        }

        _transferFromToken(paras.priceToken,bidPrice);

        if(rep.saleType != 0 && lastBidPriceOf[paras.auctionId] > 0){
            _transferToken(paras.priceToken, lastBidderOf[paras.auctionId], lastBidPriceOf[paras.auctionId]);
        }
        lastBidderOf[paras.auctionId] = msg.sender;
        lastBidPriceOf[paras.auctionId] = bidPrice;

        emit AuctionBided(msg.sender, paras.auctionId, bidPrice, block.timestamp);

        if(rep.saleType == 0){
            _dealProcess(rep, paras, bidPrice, msg.sender);
        }
    }

    function _dealProcess(AuctionRep memory rep,BaseParams memory paras,uint dealPrice, address buyer) internal {
        auctionRepOf[paras.auctionId].saleStatus = 1;

        uint feeAmount = dealPrice.mul(feeOf(paras.priceToken)) / 1e18;
        uint authorFee = INFTFactory(nftFactory).collectionIdOf(paras.nftAddress) > 0 ? dealPrice.mul(INFTCollection(paras.nftAddress).authorFee()) / 1e18 : 0;
        uint sellerAmount = dealPrice.sub(feeAmount).sub(authorFee);
        uint pledgeReward = 0;
        if(rep.isPledge == 1){
            sellerAmount = sellerAmount.add(paras.startPrice);
            pledgeReward = calcPledgeRewards(paras.auctionId,rep.startTime,paras.startPrice);
            sellerAmount = sellerAmount.add(pledgeReward);
        }
        if(authorFee > 0){
            _transferToken(paras.priceToken,INFTCollection(paras.nftAddress).author(),authorFee);
        }

        _distributeFee(paras.priceToken,feeAmount);
        _transferToken(paras.priceToken,paras.seller,sellerAmount);

        _transferFromNFT(address(this), buyer, paras.nftAddress, paras.nftId, rep.isERC1155==1, paras.sellAmount);

        emit AuctionTraded(buyer, paras.auctionId, dealPrice, feeAmount,pledgeReward,block.timestamp);
    }

    function FinishAuction(bytes32[] calldata baseParams) external nonReentrant {
        BaseParams memory paras = _getBaseParams(baseParams);
        require(_checkBaseParams(paras),"incorrect base params");
        require(msg.sender == paras.seller || msg.sender == lastBidderOf[paras.auctionId] || isRelayer[msg.sender],"invalid caller");

        require(paras.auctionId > 0,"auctionId can not be 0");
        AuctionRep memory rep = auctionRepOf[paras.auctionId];
        require(rep.saleStatus == 0,"auction has been traded or canceled");
        require(rep.deadline <= block.timestamp || msg.sender == paras.seller,"auction not ended");
        require(rep.saleType == 1 || rep.saleType == 2,"invlaid sale type");
        require(lastBidPriceOf[paras.auctionId] > 0 && lastBidderOf[paras.auctionId] != address(0),"auction has no offer");

        _dealProcess(rep, paras, lastBidPriceOf[paras.auctionId], lastBidderOf[paras.auctionId]);
    }


    function calcDutchPrice(uint auctionId,uint startPrice,uint startTime,uint toTimestamp) public view returns(uint){
        DutchInfo memory dutchInfo = DutchOf[auctionId];
        require(dutchInfo.minPrice > 0,"invalid dutch auction id");
        uint amountEachPeriod = dutchInfo.isDecrByFixed == 1 ? dutchInfo.decrEachPeriod : startPrice.mul(dutchInfo.decrEachPeriod) / 1e18;
        uint times = toTimestamp >= startTime ? (toTimestamp - startTime) / dutchInfo.periodSeconds : 0;
        uint decrAmount = amountEachPeriod.mul(times);
        uint currPrice = startPrice > decrAmount ? Math.max(startPrice - decrAmount,dutchInfo.minPrice) : dutchInfo.minPrice;

        return currPrice;
    }

    // paras[0]: auctionId
    // paras[1]: seller
    // paras[2]: nftAddress
    // paras[3]: nftId
    // paras[4]: sellAmount
    // paras[5]: startPrice
    // paras[6]: priceToken
    function cancel(bytes32[] calldata baseParams) external whenNotPaused nonReentrant {
        BaseParams memory paras = _getBaseParams(baseParams);
        require(_checkBaseParams(paras),"incorrect base params");
        require(paras.auctionId > 0,"auction id can not be 0");
        require(msg.sender == paras.seller,"caller must be seller");
        
        AuctionRep memory rep = auctionRepOf[paras.auctionId];
        require(rep.saleStatus == 0,"auction has been traded or canceled");
        require(rep.isPledge == 0 || block.timestamp > pledgeLockDuration.add(rep.startTime),"pledge token locked");
        require(lastBidPriceOf[paras.auctionId] == 0,"auction has bid");

        auctionRepOf[paras.auctionId].saleStatus = 2;

        uint pledgeReward = 0;
        if(rep.isPledge == 1){
            pledgeReward = calcPledgeRewards(paras.auctionId, rep.startTime,paras.startPrice);
            uint sellerAmount = paras.startPrice.add(pledgeReward);
            _transferToken(paras.priceToken,paras.seller,sellerAmount);
        }

        _transferFromNFT(address(this), paras.seller, paras.nftAddress, paras.nftId, rep.isERC1155==1, paras.sellAmount);

        emit AuctionCanceled(paras.seller, paras.auctionId,pledgeReward,block.timestamp);
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

    function _transferFromToken(address token,uint amount) internal {
        if(token == ETHAddress){
            require(msg.value >= amount,"insufficient input value");
        }else{
            if(token == sdtToken){
                IERC20(token).safeTransferFrom(msg.sender,sdtVault,amount);
            }else{
                address vault = address(this);
                uint balanceBefore = IERC20(token).balanceOf(vault);
                IERC20(token).safeTransferFrom(msg.sender,vault,amount);
                require(IERC20(token).balanceOf(vault).sub(balanceBefore) >= amount,"insufficient received amount");
            }
        }
    }

    function _transferToken(address token,address to,uint amount) internal {
        if(token == ETHAddress){
            TransferHelper.safeTransferETH(to, amount);
        }else{
            if(token == sdtToken){
                IERC20(token).safeTransferFrom(sdtVault,to,amount);
            }else{
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }

    function _distributeFee(address token,uint fee) internal {
        _transferToken(token,medalFeeTo,fee.mul(medalFeeRate) / 1e18);
        _transferToken(token,genesisFeeTo,fee.mul(genesisFeeRate) / 1e18);
        _transferToken(token,spacemanFeeTo,fee.mul(spacemanFeeRate) / 1e18);
        _transferToken(token,jointlyFeeTo,fee.mul(jointlyFeeRate) / 1e18);
        _transferToken(token,nftStakingFeeTo,fee.mul(nftStakingFeeRate) / 1e18);
    }

    function _transferFromNFT(address from,address to, address nftAddress,uint nftId,bool isERC1155,uint amount) internal {
        if(isERC1155){
            IERC1155Transfer(nftAddress).safeTransferFrom(from, to, nftId, amount, "");
        }else{
            IERC721Transfer(nftAddress).safeTransferFrom(from, to, nftId);
        }
    }

    // function _toUint64(uint256 value) internal pure returns (uint64) {
    //     require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
    //     return uint64(value);
    // }

    // function _toUint128()

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

    function currentPrices(uint[] calldata auctionIds,uint[] calldata startPrices,uint[] calldata startTimes) external view returns(uint[] memory){
        require(auctionIds.length > 0,"auctionIds can not be empty");
        require(auctionIds.length == startPrices.length && auctionIds.length == startTimes.length,"length all array must be same");

        uint[] memory prices = new uint[](auctionIds.length);
        for(uint i=0;i<auctionIds.length;i++){
            uint auctionId = auctionIds[i];
            require(auctionId > 0,"included auction id 0");
            if(auctionRepOf[auctionId].saleType == 2){
                prices[i] =  calcDutchPrice(auctionId, startPrices[i], startTimes[i],block.timestamp);
            }else{
                uint lastBidPrice = lastBidPriceOf[auctionId];
                prices[i] =  lastBidPrice > 0 ? lastBidPrice : startPrices[i];
            }
        }

        return prices;
    }

    function _bytes32ToAddress(bytes32 buffer) internal pure returns(address){
        uint ui = uint(buffer);
        require(ui <= type(uint160).max,"bytes32 overflow uint160");

        return address(uint160(ui));
    }

    function infos() external view returns(uint _listingFee, address _listingFeeToken,address _listingFeeTo,uint _pledgeLockDuration,uint _globalFeeRate, uint[] memory _rewardRates,uint _minPledgeAmount){
        _listingFee = listingFee;
        _listingFeeToken = listingFeeToken;
        _listingFeeTo = listingFeeTo;
        _pledgeLockDuration = pledgeLockDuration;
        _globalFeeRate = globalFeeRate;

        _rewardRates = new uint[](4);
        _rewardRates[0] = pledgeRateOf[1000*1e18];
        _rewardRates[1] = pledgeRateOf[10000*1e18];
        _rewardRates[2] = pledgeRateOf[30000*1e18];
        _rewardRates[3] = pledgeRateOf[type(uint256).max];

        _minPledgeAmount = 0;
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

    // function setMinPledgeAmount(uint _minPledgeAmount) external onlyAdmin {
    //     minPledgeAmount = _minPledgeAmount;
    // }

    function setSdtVault(address _sdtVault) external onlyAdmin {
        require(_sdtVault != address(0),"sdt vault can not be address 0");
        sdtVault = _sdtVault;
    }

    function setRelayer(address _relayer,bool _status) external onlyOwner {
        require(_relayer != address(0),"_relayer can not be address 0");
        isRelayer[_relayer] = _status;
    }
}