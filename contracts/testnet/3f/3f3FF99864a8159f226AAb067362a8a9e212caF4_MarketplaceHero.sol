/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// Sources flattened with hardhat v2.6.8 https://hardhat.org

// File contracts/libraries/SafeMath.sol

pragma solidity ^0.6.6;

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
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File contracts/interfaces/IBidNFT.sol

pragma solidity >=0.6.2;

interface IBidNFT {
    function bidToken(uint256 _tokenId, uint256 _price) external;

    function readyToSellToken(uint256 _tokenId, uint256 _price) external;

    function updateSellToken(uint256 _tokenId, uint256 _price) external;

    function buyToken(uint256 _tokenId) external;

    function cancelToSellToken(uint256 _tokenId) external;

    function readyBidToken(uint256 _tokenId, uint256 _startPrice, uint64 _startTime, uint64 _endTime) external;

    function updateBidStartPrice(uint256 _tokenId, uint256 _price) external;

    function cancelBidToken(uint256 _tokenId) external;

    function finalized(uint256 _tokenId) external;
}


// File contracts/OpenZepplin/utils/Address.sol

pragma solidity ^0.6.6;
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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


// File contracts/OpenZepplin/token/ERC20/IERC20.sol

pragma solidity ^0.6.6;

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


// File contracts/OpenZepplin/token/ERC20/SafeERC20.sol

pragma solidity ^0.6.6;
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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File contracts/OpenZepplin/GSN/Context.sol

pragma solidity ^0.6.6;
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File contracts/OpenZepplin/utils/Pausable.sol

pragma solidity ^0.6.6;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
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
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
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
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
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


// File contracts/OpenZepplin/access/Ownable.sol

pragma solidity ^0.6.6;

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


// File contracts/OpenZepplin/token/ERC721/IERC721Receiver.sol

pragma solidity ^0.6.6;
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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}


// File contracts/OpenZepplin/token/ERC721/ERC721Holder.sol

pragma solidity ^0.6.6;

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
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// File contracts/OpenZepplin/introspection/IERC165.sol

pragma solidity ^0.6.6;
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


// File contracts/OpenZepplin/token/ERC721/IERC721.sol

pragma solidity ^0.6.6;
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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


// File contracts/_MarketplaceHero.sol

// SPDX-License-Identifier: MIT

// pragma solidity =0.6.6;
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;









contract MarketplaceHero is Pausable, Ownable, ERC721Holder, IBidNFT {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    struct BidEntry {
        address bidder;
        uint256 price;
    }

    struct TokenNFTEntry {
        uint256 tokenId;
        uint256 startPrice;
        uint64 startTime;
        uint64 endTime;
    }

    struct TokenSellEntry {
        uint256 tokenId;
        uint256 price;
    }

    IERC721 public nft;
    IERC20 public quoteErc20;
    address public feeAddr;
    uint256 public feePercent;

    uint256[] private itemAuctioned;

    mapping(uint256 => BidEntry[]) private _tokenBids;
    mapping(uint256 => TokenNFTEntry) private _tokenNFTEntry;
    mapping(uint256 => TokenSellEntry) private _tokeSellEntry;
    mapping(uint256 => bool) private _tokenIsSell;
    mapping(uint256 => bool) private _tokenIsBid;
    mapping(uint256 => address) private _tokenBidder;
    mapping(uint256 => address) private _tokenSeller;
    mapping(address => uint256[]) private _tokenSell;

    event FeeAddressTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SetFeePercent(
        address indexed seller,
        uint256 oldFeePercent,
        uint256 newFeePercent
    );
    event ReadyBidToken(
        uint256 tokenId,
        uint256 startPrice,
        uint64 startTime,
        uint64 endTime
    );
    event Bid(address indexed bidder, uint256 indexed tokenId, uint256 price);
    event UpdateBidStartPrice(
        uint256 tokenId,
        uint256 oldPrice,
        uint256 newPrice
    );
    event CancelBid(address seller, uint256 tokenId);
    event Finalized(address verifier, uint256 tokenId, uint256 time);
    event ReadySellToken(uint256 tokenId, uint256 price);
    event CancelSellToken(uint256 tokenId);
    event BuyToken(
        address buyer,
        address seller,
        uint256 tokenId,
        uint256 price,
        uint256 time
    );
    event UpdatePriceSellToken(
        uint256 tokenId,
        uint256 oldPrice,
        uint256 newPrice
    );

    constructor(
        address _nftAddress,
        address _quoteErc20Address,
        address _feeAddr,
        uint256 _feePercent
    ) public {
        require(_nftAddress != address(0) && _nftAddress != address(this));
        require(
            _quoteErc20Address != address(0) &&
                _quoteErc20Address != address(this)
        );
        nft = IERC721(_nftAddress);
        quoteErc20 = IERC20(_quoteErc20Address);
        feeAddr = _feeAddr;
        feePercent = _feePercent;
        emit FeeAddressTransferred(address(0), feeAddr);
        emit SetFeePercent(_msgSender(), 0, feePercent);
    }

    function getBids(uint256 _tokenId) public view returns (BidEntry[] memory) {
        return _tokenBids[_tokenId];
    }

    function getBidsLength(uint256 _tokenId) public view returns (uint256) {
        return _tokenBids[_tokenId].length;
    }

    function getTokenNFTDetail(uint256 _tokenId)
        public
        view
        returns (TokenNFTEntry memory)
    {
        return _tokenNFTEntry[_tokenId];
    }

    function getTokenSellDetail(uint256 _tokenId)
        public
        view
        returns (TokenSellEntry memory)
    {
        return _tokeSellEntry[_tokenId];
    }

    function getTokenSellOf(address _address) public view returns(uint256[] memory) {
        return _tokenSell[_address];
    }

    function getItemsNFTAuctionedLength() public view returns (uint256) {
        return itemAuctioned.length;
    }

    function getItemsNFTAuctioned() public view returns (uint256[] memory) {
        return itemAuctioned;
    }

    function bidEnded(uint256 _tokenId) public view returns (bool) {
        return block.timestamp > _tokenNFTEntry[_tokenId].endTime;
    }

    function tokenIsSell(uint256 _tokenId) public view returns (bool) {
        return _tokenIsSell[_tokenId];
    }

    function tokenIsBid(uint256 _tokenId) public view returns (bool) {
        return _tokenIsBid[_tokenId];
    }

    function isFinisher(uint256 _tokenId, address _address)
        public
        view
        returns (bool)
    {
        if (_tokenBids[_tokenId].length != 0) {
            return
                _tokenBidder[_tokenId] == _address ||
                _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1].bidder ==
                _address;
        } else {
            return _tokenBidder[_tokenId] == _address;
        }
    }

    function config(
        address _quoteErcAddress,
        address _feeAddr,
        uint256 _fee
    ) external onlyOwner {
        quoteErc20 = IERC20(_quoteErcAddress);
        feeAddr = _feeAddr;
        feePercent = _fee;
    }

    function readyToSellToken(uint256 _tokenId, uint256 _price)
        public
        override
        whenNotPaused
    {
        require(
            _msgSender() == nft.ownerOf(_tokenId),
            "Only Token Owner can sell token"
        );
        require(_tokenIsBid[_tokenId] == false, "Tokens are being auctioned");
        require(_price != 0, "Price must be greater than zero");
        nft.safeTransferFrom(address(_msgSender()), address(this), _tokenId);
        _tokenSell[address(_msgSender())].push(_tokenId);
        _tokeSellEntry[_tokenId] = TokenSellEntry({
            tokenId: _tokenId,
            price: _price
        });
        _tokenSeller[_tokenId] = _msgSender();
        _tokenIsBid[_tokenId] = false;
        _tokenIsSell[_tokenId] = true;
        emit ReadySellToken(_tokenId, _price);
    }

    function updateSellToken(uint256 _tokenId, uint256 _price)
        public
        override
        whenNotPaused
    {
        address _seller = _tokenSeller[_tokenId];
        require(
            _msgSender() == _seller,
            "Only the seller can change the price"
        );
        require(_price != 0, "Price must be greater than zero");
        uint256 _priceOld = _tokeSellEntry[_tokenId].price;
        _tokeSellEntry[_tokenId].price = _price;
        emit UpdatePriceSellToken(_tokenId, _priceOld, _price);
    }

    function _deleteSell(uint256 _tokenId) private {
        delete _tokeSellEntry[_tokenId];
        delete _tokenBidder[_tokenId];
        delete _tokenIsSell[_tokenId];
    }

    function buyToken(uint256 _tokenId) public override whenNotPaused {
        require(
            _msgSender() != address(0) && _msgSender() != address(this),
            "Wrong msg sender"
        );
        address _seller = _tokenSeller[_tokenId];
        require(_msgSender() != _seller, "Owner cannot buy");
        require(_tokenIsSell[_tokenId] == true, "Token not in sell");
        uint256 _price = _tokeSellEntry[_tokenId].price;
        uint256 feeAmount = _price.mul(feePercent).div(100);
        quoteErc20.safeTransferFrom(
            _msgSender(),
            _seller,
            _price.sub(feeAmount)
        );
        if (feeAmount != 0) {
            quoteErc20.safeTransferFrom(_msgSender(), feeAddr, feeAmount);
        }
        nft.safeTransferFrom(address(this), _msgSender(), _tokenId);
        _deleteSell(_tokenId);
        emit BuyToken(_msgSender(), _seller, _tokenId, _price, block.timestamp);
    }

    function cancelToSellToken(uint256 _tokenId) public override whenNotPaused {
        require(_tokenIsSell[_tokenId] == true, "Token not in sell");
        address _seller = _tokenSeller[_tokenId];
        require(
            _msgSender() == _seller,
            "Only the seller can cancel sell token"
        );
        nft.safeTransferFrom(address(this), _msgSender(), _tokenId);
        _deleteSell(_tokenId);
        emit CancelSellToken(_tokenId);
    }

    function readyBidToken(
        uint256 _tokenId,
        uint256 _startPrice,
        uint64 _startTime,
        uint64 _endTime
    ) public override whenNotPaused {
        require(
            _msgSender() == nft.ownerOf(_tokenId),
            "Only Token Owner can sell token"
        );
        require(_startPrice != 0, "Price must be greater than zero");
        require(
            _startTime < 10000000000,
            "Auction: enter an unix timestamp in seconds, not miliseconds"
        );
        require(
            _endTime < 10000000000,
            "Auction: enter an unix timestamp in seconds, not miliseconds"
        );
        require(
            _startTime >= block.timestamp,
            "Auction: start time is before current time"
        );
        require(
            _endTime > _startTime,
            "Auction: end time must be older than start time"
        );
        nft.safeTransferFrom(address(_msgSender()), address(this), _tokenId);
        _tokenNFTEntry[_tokenId] = TokenNFTEntry({
            tokenId: _tokenId,
            startPrice: _startPrice,
            startTime: _startTime,
            endTime: _endTime
        });
        itemAuctioned.push(_tokenId);
        _tokenBidder[_tokenId] = _msgSender();
        _tokenIsBid[_tokenId] = true;
        _tokenIsSell[_tokenId] = false;
        emit ReadyBidToken(_tokenId, _startPrice, _startTime, _endTime);
    }

    function bidToken(uint256 _tokenId, uint256 _price)
        public
        override
        whenNotPaused
    {
        require(
            block.timestamp >= _tokenNFTEntry[_tokenId].startTime &&
                block.timestamp <= _tokenNFTEntry[_tokenId].endTime,
            "Auction: outside auction hours"
        );
        require(
            _msgSender() != address(0) && _msgSender() != address(this),
            "Wrong msg sender"
        );
        require(_price != 0, "Price must be granter than zero");
        require(
            _price > _tokenNFTEntry[_tokenId].startPrice,
            "The price must be higher than the starting price"
        );
        if (_tokenBids[_tokenId].length > 0) {
            require(
                _price >
                    _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1].price,
                "Bid price must be greater than current bidder"
            );
        }
        address _seller = _tokenBidder[_tokenId];
        address _to = address(_msgSender());
        require(_seller != _to, "Owner cannot bid");
        quoteErc20.safeTransferFrom(
            address(_msgSender()),
            address(this),
            _price
        );
        if (_tokenBids[_tokenId].length > 0) {
            quoteErc20.safeTransfer(
                _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1].bidder,
                _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1].price
            );
        }
        _tokenBids[_tokenId].push(BidEntry({bidder: _to, price: _price}));
        emit Bid(_msgSender(), _tokenId, _price);
    }

    function updateBidStartPrice(uint256 _tokenId, uint256 _price)
        public
        override
        whenNotPaused
    {
        address _seller = _tokenBidder[_tokenId];
        require(
            _msgSender() == _seller,
            "Only the seller can change the starting price"
        );
        require(
            block.timestamp < _tokenNFTEntry[_tokenId].startTime,
            "Auction has started or ended"
        );
        require(_price != 0, "Price must be granter than zero");
        require(
            _msgSender() != address(0) && _msgSender() != address(this),
            "Wrong msg sender"
        );
        uint256 oldPrice = _tokenNFTEntry[_tokenId].startPrice;
        _tokenNFTEntry[_tokenId].startPrice = _price;
        emit UpdateBidStartPrice(_tokenId, oldPrice, _price);
    }

    function _deleteBid(uint256 _tokenId) private {
        delete _tokenNFTEntry[_tokenId];
        delete _tokenBids[_tokenId];
        delete _tokenBidder[_tokenId];
        delete _tokenIsBid[_tokenId];
        for (uint256 i = 0; i < itemAuctioned.length; i++) {
            if (itemAuctioned[i] == _tokenId) {
                itemAuctioned[i] = itemAuctioned[itemAuctioned.length - 1];
                itemAuctioned.pop();
                break;
            }
        }
    }

    function cancelBidToken(uint256 _tokenId) public override whenNotPaused {
        address _seller = _tokenBidder[_tokenId];
        require(
            _msgSender() == _seller,
            "Only the seller can cancel sell token"
        );
        require(
            block.timestamp < _tokenNFTEntry[_tokenId].endTime,
            "Auction has ended"
        );
        require(
            _msgSender() != address(0) && _msgSender() != address(this),
            "Wrong msg sender"
        );
        if (_tokenBids[_tokenId].length > 0) {
            quoteErc20.safeTransfer(
                _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1].bidder,
                _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1].price
            );
        }
        nft.safeTransferFrom(address(this), _msgSender(), _tokenId);
        _deleteBid(_tokenId);
        emit CancelBid(_msgSender(), _tokenId);
    }

    function finalized(uint256 _tokenId) public override whenNotPaused {
        require(
            block.timestamp > _tokenNFTEntry[_tokenId].endTime,
            "Auction is not over yet"
        );
        require(
            _msgSender() != address(0) && _msgSender() != address(this),
            "Wrong msg sender"
        );
        address _seller = _tokenBidder[_tokenId];
        require(
            _msgSender() ==
                _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1].bidder ||
                _msgSender() == _seller,
            "Bidder does not exist"
        );
        if (_tokenBids[_tokenId].length > 0) {
            address _to = _tokenBids[_tokenId][_tokenBids[_tokenId].length - 1]
                .bidder;
            uint256 _price = _tokenBids[_tokenId][
                _tokenBids[_tokenId].length - 1
            ].price;
            nft.safeTransferFrom(address(this), _to, _tokenId);
            uint256 feeAmount = _price.mul(feePercent).div(100);
            quoteErc20.safeTransfer(_seller, _price.sub(feeAmount));
            if (feeAmount != 0) {
                quoteErc20.safeTransfer(feeAddr, feeAmount);
            }
        } else {
            nft.safeTransferFrom(address(this), _seller, _tokenId);
        }
        _deleteBid(_tokenId);
        emit Finalized(_msgSender(), _tokenId, block.timestamp);
    }

    function transferFeeAddress(address _feeAddr) public {
        require(_msgSender() == feeAddr, "FORBIDDEN");
        feeAddr = _feeAddr;
        emit FeeAddressTransferred(_msgSender(), feeAddr);
    }

    function setFeePercent(uint256 _feePercent) public onlyOwner {
        require(feePercent != _feePercent, "Not need update");
        emit SetFeePercent(_msgSender(), feePercent, _feePercent);
        feePercent = _feePercent;
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    function getBlock() public view returns (uint256) {
        return block.timestamp;
    }
}