/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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

// File: @openzeppelin\contracts\token\ERC721\IERC721.sol





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

// File: @openzeppelin\contracts\token\ERC721\IERC721Enumerable.sol





/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol





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

// File: @openzeppelin\contracts\math\SafeMath.sol





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

// File: @openzeppelin\contracts\utils\Address.sol





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

// File: @openzeppelin\contracts\token\ERC20\SafeERC20.sol







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

// File: @openzeppelin\contracts\GSN\Context.sol





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

// File: @openzeppelin\contracts\access\Ownable.sol





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

// File: @openzeppelin\contracts\utils\ReentrancyGuard.sol





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
contract ReentrancyGuard {
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

    constructor () internal {
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

// File: contracts\NFTMaster\v2\NFTMasterNeoBlindBox.sol



interface INFTcustom {
    function mintItem(address recipient, uint256 propertyId) external returns (uint256);
}

contract NFTMasterNeoBlindBox is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address[] public adminList;

    address public immutable BASE_ADDRESS;

    struct BlindBoxInfo {
        uint256 boxStartAt;
        uint256 boxEndAt;
        address nftAddress;
        uint256[] nftPropertyIdList;
        uint256[] boxSupplyList;
        address payToken;
        uint256 payPrice;
        uint256 purchaseAmountLimit;
        uint256 preemptionDuration;
        bool boxStatus;
    }

    struct BlindBoxExtraInfo {
        address[] whiteAddressList;
        uint256[] whiteNumList;
        address[] preemptionNftList;
        uint256[] preemptionNumList;
        mapping(address => uint256) userPurchaseAmountList;
        mapping(address => bool) userPreemptionUsedList;
    }

    // address => index
    mapping(address => uint256) transferAddressAndTokenIdIndex;

    // nftAddress => (nftTokenID => boxIndex)
    mapping(address => mapping(uint256 => uint256)) boxIndexMapping;

    // boxIndex => blindBoxInfo
    mapping(uint256 => BlindBoxInfo) BlindBoxList;

    // boxIndex => BlindBoxExtraInfo
    mapping(uint256 => BlindBoxExtraInfo) BlindBoxExtraList;

    // nft token type (token > type:0-mint,1-transfer)
    mapping(address => uint256) public nftTokenType;

    address public platformAddress;

    address public transferNftAddress;

    constructor() public {
        adminList.push(msg.sender);

        BASE_ADDRESS = address(1);

        platformAddress = msg.sender;

        transferNftAddress = msg.sender;
    }

    // set nft token type
    function setNftTokenType(address[] memory _nftToken, uint256[] memory _typeList) public nonReentrant onlyAdmin {
        require(_nftToken.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_nftToken.length == _typeList.length, "INCONSISTENT_ARRAY");

        for (uint256 _dd = 0; _dd < _nftToken.length; _dd++) {
            require(_nftToken[_dd] != address(0), "NONEMPTY_ADDRESS");
            nftTokenType[_nftToken[_dd]] = _typeList[_dd];
        }
    }

    /* admin */
    // set admin list
    function setAdminList(address[] memory _list) public nonReentrant onlyOwner {
        require(_list.length > 0, "NONEMPTY_ADDRESS_LIST");

        for (uint256 nIndex = 0; nIndex < _list.length; nIndex++) {
            require(_list[nIndex] != address(0), "ADMIN_NONEMPTY_ADDRESS");
        }
        adminList = _list;
    }

    // get admin list
    function getAdminList() public view returns (address[] memory) {
        return adminList;
    }

    function onlyAdminCheck(address _adminAddress) internal view returns (bool) {
        for (uint256 nIndex = 0; nIndex < adminList.length; nIndex++) {
            if (adminList[nIndex] == _adminAddress) {
                return true;
            }
        }
        return false;
    }

    modifier onlyAdmin() {
        require(onlyAdminCheck(msg.sender) == true, "ONLY_ADMIN_OPERATE");

        _;
    }

    /* other */
    // set platform address
    function setPlatformAddress(address _token) public onlyAdmin nonReentrant {
        require(_token != address(0), "NONEMPTY_ADDRESS");
        platformAddress = _token;
    }

    // set transfer nft address
    function setTransferNftAddress(address _token) public onlyAdmin nonReentrant {
        require(_token != address(0), "NONEMPTY_ADDRESS");
        transferNftAddress = _token;
    }

    event InitBox(uint256 _boxIndex, address _nftAddress, uint256[] _nftPropertyIdList, uint256[] _numberList, address _token, uint256 _price, bool _status, uint256 _startAt, uint256 _endAt, uint256 _purchaseAmountLimit, uint256 _preemptionDuration);
    event SetStatus(uint256 _boxIndex, bool _status);

    /* box */
    // init box
    function initBox(uint256 _boxIndex, address _nftAddress, uint256[] memory _nftPropertyIdList, uint256[] memory _numberList, address _token, uint256 _price, bool _status, uint256 _startAt, uint256 _endAt, uint256 _purchaseAmountLimit, uint256 _preemptionDuration) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        require(_nftPropertyIdList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_nftPropertyIdList.length == _numberList.length, "INCONSISTENT_LENGTH");

        for (uint256 nIndex = 0; nIndex < _nftPropertyIdList.length; nIndex++) {
            require(_nftPropertyIdList[nIndex] > 0, "NONEMPTY_NFT_PROPERTY_ID_LIST");
        }

        require(_token != address(0), "NONEMPTY_TOKEN");
        require(_price > 0, "NONEMPTY_AMOUNT");
        require((_startAt > 0) && (_endAt > 0) && (_startAt < _endAt), "AT_ERROR");

        BlindBoxList[_boxIndex] = BlindBoxInfo({
        boxStartAt : _startAt,
        boxEndAt : _endAt,
        nftAddress : _nftAddress,
        nftPropertyIdList : _nftPropertyIdList,
        boxSupplyList : _numberList,
        payToken : _token,
        payPrice : _price,
        purchaseAmountLimit : _purchaseAmountLimit,
        preemptionDuration : _preemptionDuration,
        boxStatus : _status
        });

        emit InitBox(_boxIndex, _nftAddress, _nftPropertyIdList, _numberList, _token, _price, _status, _startAt, _endAt, _purchaseAmountLimit, _preemptionDuration);
    }

    // get box info
    function getBoxInfo(uint256 _boxIndex) public view returns (uint256, address, uint256[] memory, uint256[] memory, address, uint256, bool, uint256, uint256, uint256, uint256, uint256){
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxInfo memory _blindBoxInfo = BlindBoxList[_boxIndex];
        uint256 _getRemainder = getRemainder(_boxIndex);
        return (_boxIndex, _blindBoxInfo.nftAddress, _blindBoxInfo.nftPropertyIdList, _blindBoxInfo.boxSupplyList, _blindBoxInfo.payToken, _blindBoxInfo.payPrice, _blindBoxInfo.boxStatus, _blindBoxInfo.boxStartAt, _blindBoxInfo.boxEndAt, _getRemainder, _blindBoxInfo.purchaseAmountLimit, _blindBoxInfo.preemptionDuration);
    }

    // set box supply
    function setBoxSupply(uint256 _boxIndex, uint256[] memory _nftPropertyIdList, uint256[] memory _numberList) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        require(_nftPropertyIdList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_nftPropertyIdList.length == _numberList.length, "INCONSISTENT_LENGTH");

        for (uint256 nIndex = 0; nIndex < _nftPropertyIdList.length; nIndex++) {
            require(_nftPropertyIdList[nIndex] > 0, "NONEMPTY_NFT_PROPERTY_ID_LIST");
        }

        BlindBoxInfo storage _blindBoxInfo = BlindBoxList[_boxIndex];
        _blindBoxInfo.nftPropertyIdList = _nftPropertyIdList;
        _blindBoxInfo.boxSupplyList = _numberList;
    }

    // set open status
    function setStatus(uint256 _boxIndex, bool _status) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxInfo storage _blindBoxInfo = BlindBoxList[_boxIndex];
        _blindBoxInfo.boxStatus = _status;

        emit SetStatus(_boxIndex, _status);
    }

    // set pay info
    function setPayInfo(uint256 _boxIndex, address _token, uint256 _price, uint256 _amount) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        require(_token != address(0), "NONEMPTY_TOKEN");
        require(_price > 0, "NONEMPTY_AMOUNT");

        BlindBoxInfo storage _blindBoxInfo = BlindBoxList[_boxIndex];
        _blindBoxInfo.payToken = _token;
        _blindBoxInfo.payPrice = _price;
        _blindBoxInfo.purchaseAmountLimit = _amount;
    }

    // set at
    function setAt(uint256 _boxIndex, uint256 _startAt, uint256 _endAt) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        require((_startAt > 0) && (_endAt > 0) && (_startAt < _endAt), "AT_ERROR");

        BlindBoxInfo storage _blindBoxInfo = BlindBoxList[_boxIndex];
        _blindBoxInfo.boxStartAt = _startAt;
        _blindBoxInfo.boxEndAt = _endAt;
    }

    // get box remainder
    function getRemainder(uint256 _boxIndex) public view returns (uint256){
        uint256 _tmpSupply = 0;
        BlindBoxInfo memory _blindBoxInfo = BlindBoxList[_boxIndex];
        for (uint256 nIndex = 0; nIndex < _blindBoxInfo.boxSupplyList.length; nIndex++) {
            _tmpSupply = _tmpSupply.add(_blindBoxInfo.boxSupplyList[nIndex]);
        }
        return _tmpSupply;
    }

    // set preemption nft
    function setPreemptionNftInfo(uint256 _boxIndex, address[] memory _nftList, uint256[] memory _numList) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        require(_nftList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_nftList.length == _numList.length, "INCONSISTENT_ARRAY");

        for (uint256 _dd = 0; _dd < _nftList.length; _dd++) {
            require(_nftList[_dd] != address(0), "NONEMPTY_ADDRESS");
        }

        BlindBoxExtraInfo storage _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        _blindBoxExtraInfo.preemptionNftList = _nftList;
        _blindBoxExtraInfo.preemptionNumList = _numList;
    }

    // add preemption nft
    function addPreemptionNftInfo(uint256 _boxIndex, address[] memory _nftList, uint256[] memory _numList) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        require(_nftList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_nftList.length == _numList.length, "INCONSISTENT_ARRAY");

        BlindBoxExtraInfo storage _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        for (uint256 _dd = 0; _dd < _nftList.length; _dd++) {
            require(_nftList[_dd] != address(0), "NONEMPTY_ADDRESS");

            _blindBoxExtraInfo.preemptionNftList.push(_nftList[_dd]);
            _blindBoxExtraInfo.preemptionNumList.push(_numList[_dd]);
        }
    }

    // get preemption nft
    function getPreemptionNftInfo(uint256 _boxIndex) public view returns (address[] memory, uint256[] memory){
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxExtraInfo memory _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        return (_blindBoxExtraInfo.preemptionNftList, _blindBoxExtraInfo.preemptionNumList);
    }

    // set white address
    function setWhiteAddressInfo(uint256 _boxIndex, address[] memory _addressList, uint256[] memory _numList) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        require(_addressList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_addressList.length == _numList.length, "INCONSISTENT_ARRAY");

        for (uint256 _dd = 0; _dd < _addressList.length; _dd++) {
            require(_addressList[_dd] != address(0), "NONEMPTY_ADDRESS");
        }

        BlindBoxExtraInfo storage _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        _blindBoxExtraInfo.whiteAddressList = _addressList;
        _blindBoxExtraInfo.whiteNumList = _numList;
    }

    // add white address
    function addWhiteAddressInfo(uint256 _boxIndex, address[] memory _addressList, uint256[] memory _numList) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        require(_addressList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_addressList.length == _numList.length, "INCONSISTENT_ARRAY");

        BlindBoxExtraInfo storage _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        for (uint256 _dd = 0; _dd < _addressList.length; _dd++) {
            require(_addressList[_dd] != address(0), "NONEMPTY_ADDRESS");

            _blindBoxExtraInfo.whiteAddressList.push(_addressList[_dd]);
            _blindBoxExtraInfo.whiteNumList.push(_numList[_dd]);
        }
    }

    // get white address
    function getWhiteAddressInfo(uint256 _boxIndex) public view returns (address[] memory, uint256[] memory){
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxExtraInfo memory _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        return (_blindBoxExtraInfo.whiteAddressList, _blindBoxExtraInfo.whiteNumList);
    }

    // set preemption duration
    function setPreemptionDuration(uint256 _boxIndex, uint256 _duration) public onlyAdmin nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxInfo storage _blindBoxInfo = BlindBoxList[_boxIndex];
        _blindBoxInfo.preemptionDuration = _duration;
    }

    // check preemption is in progress
    function checkPreemptionIsInProgress(uint256 _boxIndex) public view returns (bool){
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxInfo memory _blindBoxInfo = BlindBoxList[_boxIndex];
        bool res = false;
        if ((_blindBoxInfo.preemptionDuration > 0) && (_blindBoxInfo.boxStartAt > 0) && (_blindBoxInfo.boxEndAt > 0)) {
            uint256 preemptionStartAt = _blindBoxInfo.boxStartAt.sub(_blindBoxInfo.preemptionDuration);
            if ((preemptionStartAt <= block.timestamp) && (block.timestamp <= _blindBoxInfo.boxStartAt)) {
                res = true;
            }
        }
        return res;
    }

    // get user preemption info
    function getUserPreemptionInfo(uint256 _boxIndex, address _user) public view returns (bool, address, uint256, uint256){
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxExtraInfo memory _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        bool _isPreemption = false;
        address _nftToken = address(0);
        uint256 _nftTokenId = 0;
        uint256 _preemptionNum = 0;

        if (_blindBoxExtraInfo.whiteAddressList.length > 0) {
            for (uint256 _dd = 0; _dd < _blindBoxExtraInfo.whiteAddressList.length; _dd++) {
                address _addressTmp = _blindBoxExtraInfo.whiteAddressList[_dd];
                // check white address
                if (_addressTmp == _user) {
                    _isPreemption = true;
                    _preemptionNum = _blindBoxExtraInfo.whiteNumList[_dd];

                    break;
                }
            }
        }

        if (_blindBoxExtraInfo.preemptionNftList.length > 0) {
            for (uint256 _dd = 0; _dd < _blindBoxExtraInfo.preemptionNftList.length; _dd++) {
                address _nftTokenTmp = _blindBoxExtraInfo.preemptionNftList[_dd];
                // check balance
                if (IERC721(_nftTokenTmp).balanceOf(_user) > 0) {
                    // get tokenId
                    _nftTokenId = IERC721Enumerable(_nftTokenTmp).tokenOfOwnerByIndex(_user, 0);

                    _isPreemption = true;
                    _nftToken = _nftTokenTmp;
                    _preemptionNum = _blindBoxExtraInfo.preemptionNumList[_dd];

                    break;
                }
            }
        }

        return (_isPreemption, _nftToken, _nftTokenId, _preemptionNum);
    }

    // get user purchase amount
    function getUserPurchaseAmount(uint256 _boxIndex, address _user) public view returns (uint256){
        require(_boxIndex > 0, "BOX_INDEX_ERROR");

        BlindBoxExtraInfo storage _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        return _blindBoxExtraInfo.userPurchaseAmountList[_user];
    }

    // random
    function psuedoRandomness() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
                block.timestamp + block.difficulty +
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
                block.gaslimit +
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
                block.number
            )));
    }

    // random guess
    function psuedoRandomnessGuess(uint256 _factor) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
                block.timestamp.add(_factor) + block.difficulty +
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
                block.gaslimit +
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
                block.number
            )));
    }

    event BlindPurchasePropertyId(address nftAddress, uint256[] nftTokenId, uint256[] resultPropertyId, uint256 remaining, uint256 at);
    event BlindPurchase(address recipient, address payToken, uint256 payPrice, uint256 payAmount, uint256 payPriceTotal, address nftAddress, uint256 at);
    event BlindPurchasePreemption(uint256 _boxIndex, address recipient, bool isPreemption, address preemptionNftToken, uint256 preemptionNftTokenId, uint256 at);

    function blindPurchase(uint256 _boxIndex, uint256 _num) public payable nonReentrant {
        require(_boxIndex > 0, "BOX_INDEX_ERROR");
        BlindBoxInfo storage _blindBoxInfo = BlindBoxList[_boxIndex];
        BlindBoxExtraInfo storage _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];
        require(_blindBoxInfo.boxStatus, "STATUS_PAUSE");

        // check preemption status
        bool _preemptionStatus = checkPreemptionIsInProgress(_boxIndex);
        if (_preemptionStatus == false) {
            // preemption is not in progress
            require(_blindBoxInfo.boxStartAt <= block.timestamp && block.timestamp <= _blindBoxInfo.boxEndAt, "BOX_EXPIRED");
        }

        // check purchase num
        require(_num > 0, "AMOUNT_ERROR");

        uint256 remaining = getRemainder(_boxIndex);
        require(remaining >= _num, "SUPPLY_INSUFFICIENT");

        // check purchase amount limit
        uint256 _userPurchaseAmount = getUserPurchaseAmount(_boxIndex, msg.sender);
        uint256 _userPurchaseAmountTmp = _userPurchaseAmount.add(_num);
        if (_blindBoxInfo.purchaseAmountLimit > 0) {
            require(_userPurchaseAmountTmp <= _blindBoxInfo.purchaseAmountLimit, "PURCHASE_AMOUNT_REACH_MAX");
        }
        _blindBoxExtraInfo.userPurchaseAmountList[msg.sender] = _userPurchaseAmountTmp;

        // check used or not preemption
        require(_blindBoxExtraInfo.userPreemptionUsedList[msg.sender] == false, "PREEMPTION_USED");

        // preemption
        (bool _isPreemption, address _preemptionNftToken, uint256 _preemptionNftTokenId, uint256 _preemptionNum) = getUserPreemptionInfo(_boxIndex, msg.sender);
        if (_preemptionStatus == true) {
            // preemption is in progress

            // user have preemption
            require(_isPreemption == true, "BOX_NOT_STARTED");

            require(_num <= _preemptionNum, "PURCHASE_AMOUNT_REACH_MAX");

            _blindBoxExtraInfo.userPreemptionUsedList[msg.sender] = true;
        }
        emit BlindPurchasePreemption(_boxIndex, msg.sender, _isPreemption, _preemptionNftToken, _preemptionNftTokenId, block.timestamp);

        uint256[] memory resultPropertyId = new uint256[](_num);
        for (uint256 _dd = 0; _dd < _num; _dd++) {
            uint256 _randomness = psuedoRandomness();
            _randomness = _randomness.mod(remaining);

            for (uint256 ind = 0; ind < _blindBoxInfo.boxSupplyList.length; ind++) {
                if (_randomness <= _blindBoxInfo.boxSupplyList[ind] && _blindBoxInfo.boxSupplyList[ind] > 0) {
                    resultPropertyId[_dd] = _blindBoxInfo.nftPropertyIdList[ind];
                    _blindBoxInfo.boxSupplyList[ind] = _blindBoxInfo.boxSupplyList[ind].sub(1);
                    remaining = remaining.sub(1);
                    break;
                } else {
                    _randomness = _randomness.sub(_blindBoxInfo.boxSupplyList[ind]);
                }
            }
        }
        uint256 remainingEmit = remaining;
        uint256 numEmit = _num;

        uint256[] memory boxIndexArr = new uint256[](1);
        boxIndexArr[0] = _boxIndex;

        address _payToken = _blindBoxInfo.payToken;
        uint256 _payPrice = _blindBoxInfo.payPrice;
        uint256 payPriceTotal = _payPrice.mul(numEmit);
        if (_payToken == BASE_ADDRESS) {
            require(msg.value == payPriceTotal, "PAY_AMOUNT_ERROR");
            address payable _platformAddress = address(uint160(platformAddress));
            _platformAddress.transfer(payPriceTotal);
        } else {
            IERC20(_payToken).safeTransferFrom(msg.sender, platformAddress, payPriceTotal);
        }

        uint256[] memory resultTokenId = new uint256[](numEmit);

        BlindBoxInfo memory _blindBoxInfo1 = getBlindBoxInfo(boxIndexArr[0]);
        for (uint256 _i = 0; _i < numEmit; _i++) {
            if (nftTokenType[_blindBoxInfo1.nftAddress] > 0) {
                require(IERC721(_blindBoxInfo1.nftAddress).balanceOf(transferNftAddress) >= numEmit, "NFT_BALANCE_ERROR");
                // get tokenID
                resultTokenId[_i] = IERC721Enumerable(_blindBoxInfo1.nftAddress).tokenOfOwnerByIndex(transferNftAddress, transferAddressAndTokenIdIndex[_blindBoxInfo1.nftAddress]);
                // transfer token
                IERC721(_blindBoxInfo1.nftAddress).safeTransferFrom(transferNftAddress, msg.sender, resultTokenId[_i]);
                // drive transfer address token id index
                transferAddressAndTokenIdIndex[_blindBoxInfo1.nftAddress] = transferAddressAndTokenIdIndex[_blindBoxInfo1.nftAddress].add(1);
            } else {
                // mint
                resultTokenId[_i] = INFTcustom(_blindBoxInfo1.nftAddress).mintItem(msg.sender, resultPropertyId[_i]);
            }

            boxIndexMapping[_blindBoxInfo1.nftAddress][resultTokenId[_i]] = boxIndexArr[0];
        }

        if (nftTokenType[_blindBoxInfo1.nftAddress] > 0) {
            delete transferAddressAndTokenIdIndex[_blindBoxInfo1.nftAddress];
        }

        emit BlindPurchasePropertyId(_blindBoxInfo1.nftAddress, resultTokenId, resultPropertyId, remainingEmit, block.timestamp);
        emit BlindPurchase(msg.sender, _payToken, _payPrice, numEmit, payPriceTotal, _blindBoxInfo1.nftAddress, block.timestamp);
    }

    function getBlindBoxInfo(uint256 _boxIndex) internal view returns (BlindBoxInfo memory) {
        BlindBoxInfo memory _blindBoxInfo = BlindBoxList[_boxIndex];
        return _blindBoxInfo;
    }

    function getBoxNftLog(address _nftAddress, uint256 _nftTokenID) external view returns (uint256){
        return boxIndexMapping[_nftAddress][_nftTokenID];
    }

    function getUserIsUsedPreemption(uint256 _boxIndex, address _user) external view returns (bool){
        BlindBoxExtraInfo storage _blindBoxExtraInfo = BlindBoxExtraList[_boxIndex];

        return _blindBoxExtraInfo.userPreemptionUsedList[_user];
    }
}