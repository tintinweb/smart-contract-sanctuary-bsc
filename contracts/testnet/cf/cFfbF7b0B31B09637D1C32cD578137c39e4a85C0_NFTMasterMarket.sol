/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

/**
 *Submitted for verification at hecoinfo.com on 2022-04-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

contract NFTMasterMarket is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    address[] public adminList;

    address public BASEADDRESS;

    address[] public allowedPayTokens;

    /* fee */
    address public feeTo;

    // fee pay token list (token > fee)
    mapping(address => uint256) public feePayTokenList;
    
    // copyright type
    uint256 public copyrightType = 1;

    /* owner miner === type = 1 */
    // nft owner miner (NFTtoken > rate)
    mapping(address => uint256) public ownerMinerFeeRate;

    /* original miner === type = 2 */
    uint256 public oriMinerFeeRate;

    // nft original miner (NFTtoken > tokenId > address)
    mapping(address => mapping(uint256 => address)) public originMiner;

    constructor() public {
        adminList.push(msg.sender);
        BASEADDRESS = address(1);

        feeTo = msg.sender;
    }

    /* admin */
    // set admin list
    function setAdminList(address[] memory _list) public nonReentrant onlyOwner {
        require(_list.length > 0, "NONEMPTY_ADDRESS_LIST");
        
        for ( uint256 nIndex = 0; nIndex < _list.length; nIndex++){
            require(_list[nIndex] != address(0), "ADMIN_NONEMPTY_ADDRESS");
        }
        adminList = _list;
    }

    // get admin list
    function getAdminList() public view returns (address[] memory) {
        return adminList;
    }

    function onlyAdminCheck(address _adminAddress) internal view returns (bool) {
        for ( uint256 nIndex = 0; nIndex < adminList.length; nIndex++){
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

    /* pay info */
    // add pay token allow
    function addAllowedPayTokens(address _token) public onlyAdmin nonReentrant {
        require(_token != address(0), "NONEMPTY_ADDRESS");
        require(checkPayTokenIsAllowed(_token) == false, "TOKEN_ALREADY_ALLOWED");
        allowedPayTokens.push(_token);
    }
    
    // check pay token allow
    function checkPayTokenIsAllowed(address _token) public view returns (bool) {
        for (uint256 _index = 0; _index < allowedPayTokens.length; _index++) {
            if (allowedPayTokens[_index] == _token) {
                return true;
            }
        }
        return false;
    }
    
    /* fee */
    // set feeTo
    function setFeeTo(address _feeTo) public onlyAdmin nonReentrant {
        require(_feeTo != address(0), "NONEMPTY_ADDRESS");
        feeTo = _feeTo;
    }

    // get feeTo
    function getFeeTo() public view returns (address) {
        return feeTo;
    }
    
    // set pay token fee
    function setPayTokenFee(address token, uint256 amount) public onlyAdmin nonReentrant {
        require(token != address(0), "NONEMPTY_ADDRESS");
        require(checkPayTokenIsAllowed(token), "TOKEN_NOT_ALLOWED");
        require(amount < 5000, "AMOUNT_OVERFLOW");
        
        feePayTokenList[token] = amount;
    }
    
    // get pay token fee
    function getPayTokenFee(address token) public view returns (uint256) {
        return feePayTokenList[token];
    }

    /* owners miner */
    // set owner miner fee
    function setOwnerMinerFeeRate(address[] memory _tokenList, uint256[] memory _rateList) public onlyAdmin nonReentrant {
        require(_tokenList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require(_tokenList.length == _rateList.length, "INCONSISTENT_LENGTH");

        for ( uint256 _dd = 0; _dd < _tokenList.length; _dd++){
            address _token = _tokenList[_dd];
            uint256 _rate = _rateList[_dd];
            require(_token != address(0), "NONEMPTY_ADDRESS");
            require(_rate < 5000, "AMOUNT_OVERFLOW");
            ownerMinerFeeRate[_token] = _rate;
        }
    }

    // get owner miner fee
    function getOwnerMinerFeeRate(address _token) public view returns (uint256) {
        require(_token != address(0), "NONEMPTY_ADDRESS");
        return ownerMinerFeeRate[_token];
    }

    /* original miner */
    // set original miner fee
    function setOriMinerFeeRate(uint256 _rate) public onlyAdmin nonReentrant {
        require(_rate < 5000, "AMOUNT_OVERFLOW");
        oriMinerFeeRate = _rate;
    }

    // get original miner fee
    function getOriMinerFeeRate() public view returns (uint256) {
        return oriMinerFeeRate;
    }

    // set original miner
    function setOriMiner(address[] memory _tokenList, uint256[] memory _tokenIdList, address[] memory _oriAddressList) public onlyAdmin nonReentrant {
        require(_tokenList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require((_tokenList.length == _tokenIdList.length) && (_tokenList.length == _oriAddressList.length), "INCONSISTENT_LENGTH");

        for ( uint256 _dd = 0; _dd < _tokenList.length; _dd++){
            address _token = _tokenList[_dd];
            uint256 _tokenId = _tokenIdList[_dd];
            address _oriAddress = _oriAddressList[_dd];
            require(_token != address(0), "NONEMPTY_ADDRESS");
            originMiner[_token][_tokenId] = _oriAddress;
        }
    }

    // get original miner
    function getOriMiner(address _token, uint256 _tokenId) public view returns (address) {
        require(_token != address(0), "NONEMPTY_ADDRESS");
        return originMiner[_token][_tokenId];
    }

    /* other */
    // set copyright type
    function setCopyrightType(uint256 _type) public onlyAdmin nonReentrant {
        require(_type > 0, "TYPE_ERROR");
        copyrightType = _type;
    }

    // get copyright rate
    function getCopyrightRate(address _token) public view returns (uint256) {
        uint256 _rate = 0;
        if ( copyrightType == 1 ) {
            _rate = ownerMinerFeeRate[_token];
        } else {
            _rate = oriMinerFeeRate;
        }
        return _rate;
    }

    /* order */    
    // order id
    Counters.Counter public _orderIds;

    // order info
    struct OrderInfo{
        uint256 OrderId;
        address OrderOwner;
        address NFTToken;
        uint256[] TokenID;
        address PayToken;
        uint256 PayAmount;
        uint256 SoldStatus;// 0-sold out, 1-sold, 2-be sold
    }
    
    // order list (orderID > orderInfo)
    mapping(uint256 => OrderInfo) public orderList;
    
    // order id list
    uint256[] public orderIdList;
    
    // check orderid is existed
    function orderIdIsExisted(uint256 _orderId) public view returns (bool){
        bool isExisted = false;
        if (orderList[_orderId].OrderId == _orderId) {
            return true;
        }
        return isExisted;
    }

    // get order info
    function getOrderInfo(uint256 _orderID) public view returns (uint256, address, address, uint256[] memory, address, uint256, uint256) {
        uint256 _id = _orderID;
        uint256 _orderId = orderList[_id].OrderId;
        address _orderOwner = orderList[_id].OrderOwner;
        address _nftToken = orderList[_id].NFTToken;
        uint256[] memory _tokenID = orderList[_id].TokenID;
        address _payToken = orderList[_id].PayToken;
        uint256 _payAmount = orderList[_id].PayAmount;
        uint256 _soldStatus = orderList[_id].SoldStatus;
        return (_orderId, _orderOwner, _nftToken, _tokenID, _payToken, _payAmount, _soldStatus);
    }

    // order
    event SoldOrder(address _user, address _token, uint256[] _tokenIDList, address _payToken, uint256 _payAmount, uint256 _orderID);
    event SoldOutOrder(address _user, address _token, uint256[] _tokenIDList, uint256 _orderID);
    event PurchaseOrder(address _user, address _recipient, address _token, uint256[] _tokenIDList, address _payToken, uint256 _payAmount, uint256 _orderID);
    event PurchaseOrderMutil(address _user, uint256[] _orderIDList);
    event TransferMutil(address _user, address _recipient, address _token, uint256[] _tokenIDList);
    
    // sold order
    function soldOrder(address _token, uint256[] memory _tokenIDList, address _payToken, uint256 _payAmount) public nonReentrant returns (uint256) {
        require(_tokenIDList.length > 0, "NONEMPTY_TOKEN_LIST");
        require((_token != address(0)) && (_payToken != address(0)) && (_token != _payToken), "TOKEN_ERROR");

        require(checkPayTokenIsAllowed(_payToken), "PAY_TOKEN_NOT_ALLOWED");
        require(_payAmount > 0, "PAY_AMOUNT_ERROR");

        for( uint256 _d = 0; _d < _tokenIDList.length; _d++ ) {
            require(IERC721(_token).ownerOf(_tokenIDList[_d]) == msg.sender, "NFT_NOT_OWNER");
        }
        
        _orderIds.increment();
        uint256 newOrderId = _orderIds.current();
        
        orderIdList.push(newOrderId);
        orderList[newOrderId] = OrderInfo(newOrderId, msg.sender, _token, _tokenIDList, _payToken, _payAmount, 1);

        for( uint256 _i = 0; _i < _tokenIDList.length; _i++ ) {
            IERC721(_token).transferFrom(msg.sender, address(this), _tokenIDList[_i]);
        }
        
        emit SoldOrder(msg.sender, _token, _tokenIDList, _payToken, _payAmount, newOrderId);

        return newOrderId;
    }
    
    // sold out order
    function soldOutOrder(uint256 _orderID) public nonReentrant {
        require(_orderID > 0, "ORDER_ERROR");
        require(orderIdIsExisted(_orderID), "ORDER_NOT_EXISTED");
        require(orderList[_orderID].OrderOwner == msg.sender, "ORDER_OWNER_ERROR");
        require(orderList[_orderID].SoldStatus == 1, "ORDER_CANNOT_OPERATE");
        
        orderList[_orderID].SoldStatus = 0;
        
        address _token = orderList[_orderID].NFTToken;
        uint256[] memory _tokenIDList = orderList[_orderID].TokenID;

        for(uint256 _i = 0; _i < _tokenIDList.length; _i++){
            IERC721(_token).safeTransferFrom(address(this), msg.sender, _tokenIDList[_i]);
        }
        
        emit SoldOutOrder(msg.sender, _token, _tokenIDList, _orderID);
    }
    
    // calculate arrival amount
    function calculateArrivalAmount(uint256 amount, address token) public view returns (uint256 tokenFee, uint256 amountValid, uint256 rate) {
        require(amount > 0, "AMOUNT_ERROR");
        require(token != address(0), "NONEMPTY_ADDRESS");
        require(checkPayTokenIsAllowed(token), "PAY_TOKEN_NOT_ALLOWED");

        rate = feePayTokenList[token];
        if(rate > 0){
            tokenFee = amount.mul(rate).div(10000);
            amountValid = amount.sub(tokenFee);
        }else{
            tokenFee = 0;
            amountValid = amount;
        }
    }
    
    // purchase order
    function purchaseOrder(uint256 _orderID) public payable nonReentrant {
        require(_orderID > 0, "ORDER_ERROR");
        require(orderIdIsExisted(_orderID), "ORDER_NOT_EXISTED");
        require(orderList[_orderID].SoldStatus == 1, "ORDER_CANNOT_OPERATE");
        
        orderList[_orderID].SoldStatus = 2;

        _purchaseOrder(_orderID, true);
    }

    // purchase order process
    function _purchaseOrder(uint256 orderID, bool checkBaseStatus) private {
        uint256 _orderID = orderList[orderID].OrderId;
        address _payToken = orderList[_orderID].PayToken;
        uint256 _payAmount = orderList[_orderID].PayAmount;
        address _orderOwner = orderList[_orderID].OrderOwner;
        address _nftToken = orderList[_orderID].NFTToken;
        uint256[] memory _tokenID = orderList[_orderID].TokenID;
        
        // calculate arrival amount
        (uint256 tokenFee, uint256 amountValid, uint256 rate) = calculateArrivalAmount(_payAmount, _payToken);
            
        if( _payToken == BASEADDRESS ){
            if ( checkBaseStatus ) {
                require(msg.value == _payAmount, "PAY_AMOUNT_ERROR");
            }
            
            if( (tokenFee > 0) && (rate > 0) && (feeTo != address(0)) ){
                address payable _feeTo = address(uint160(feeTo));
                _feeTo.transfer(tokenFee);
            }

            if ( copyrightType == 1 ) {
                uint256 _rateTotal = ownerMinerFeeRate[_nftToken];
                address _nftOwner = Ownable(_nftToken).owner();
                if( (_rateTotal > 0) && (_nftOwner != address(0)) ){
                    uint256 _payAmountTotal = _payAmount;
                    uint256 _ownerFee = _payAmountTotal.mul(_rateTotal).div(10000);
                    if( _ownerFee > 0 ){
                        address payable _ownerFeeTo = address(uint160(_nftOwner));
                        if( amountValid >= _ownerFee ) {
                            _ownerFeeTo.transfer(_ownerFee);
                            amountValid = amountValid.sub(_ownerFee);
                        } else {
                            _ownerFeeTo.transfer(amountValid);
                            amountValid = 0;
                        }
                    }
                }
            } else {
                uint256 _tokenIDLen = _tokenID.length;
                uint256 _oriMinerFeeRateEach = oriMinerFeeRate.div(_tokenIDLen);
                if( _oriMinerFeeRateEach > 0 ){
                    uint256 _payAmountTotal = _payAmount;
                    for(uint256 _dd = 0; _dd < _tokenIDLen; _dd++){
                        address _originMiner = originMiner[_nftToken][_tokenID[_dd]];
                        if( _originMiner != address(0) ){
                            uint256 _oriFee = _payAmountTotal.mul(_oriMinerFeeRateEach).div(10000);
                            if( _oriFee > 0) {
                                address payable _oriFeeTo = address(uint160(_originMiner));
                                if( amountValid >= _oriFee ) {
                                    _oriFeeTo.transfer(_oriFee);
                                    amountValid = amountValid.sub(_oriFee);
                                } else {
                                    _oriFeeTo.transfer(amountValid);
                                    amountValid = 0;
                                }
                            }
                        }
                    }
                }
            }
            
            address payable _orderOwnerAddress = address(uint160(_orderOwner));
            _orderOwnerAddress.transfer(amountValid);
            
        } else {
            // other token
            if( (tokenFee > 0) && (rate > 0) && (feeTo != address(0)) ){
                IERC20(_payToken).safeTransferFrom(msg.sender, feeTo, tokenFee);
            }

            if ( copyrightType == 1 ) {
                uint256 _rateTotal = ownerMinerFeeRate[_nftToken];
                address _nftOwner = Ownable(_nftToken).owner();
                if( (_rateTotal > 0) && (_nftOwner != address(0)) ){
                    uint256 _payAmountTotal = _payAmount;
                    uint256 _ownerFee = _payAmountTotal.mul(_rateTotal).div(10000);
                    if( _ownerFee > 0 ){
                        address _payTokenAddr = _payToken;
                        if( amountValid >= _ownerFee ) {
                            IERC20(_payTokenAddr).safeTransferFrom(msg.sender, _nftOwner, _ownerFee);
                            amountValid = amountValid.sub(_ownerFee);
                        } else {
                            IERC20(_payTokenAddr).safeTransferFrom(msg.sender, _nftOwner, amountValid);
                            amountValid = 0;
                        }
                    }
                }
            } else {
                uint256 _tokenIDLen = _tokenID.length;
                uint256 _oriMinerFeeRateEach = oriMinerFeeRate.div(_tokenIDLen);
                if( _oriMinerFeeRateEach > 0 ){
                    address _payTokenAddr = _payToken;
                    uint256 _payAmountTotal = _payAmount;
                    for(uint256 _dd = 0; _dd < _tokenIDLen; _dd++){
                        address _originMiner = originMiner[_nftToken][_tokenID[_dd]];
                        if( _originMiner != address(0) ){
                            uint256 _oriFee = _payAmountTotal.mul(_oriMinerFeeRateEach).div(10000);
                            if( _oriFee > 0 ) {
                                if( amountValid >= _oriFee ) {
                                    IERC20(_payTokenAddr).safeTransferFrom(msg.sender, _originMiner, _oriFee);
                                    amountValid = amountValid.sub(_oriFee);
                                } else {
                                    IERC20(_payTokenAddr).safeTransferFrom(msg.sender, _originMiner, amountValid);
                                    amountValid = 0;
                                }
                            }
                        }
                    }
                }
            }

            IERC20(_payToken).safeTransferFrom(msg.sender, _orderOwner, amountValid);
        }

        for(uint256 _i = 0; _i < _tokenID.length; _i++){
            IERC721(_nftToken).safeTransferFrom(address(this), msg.sender, _tokenID[_i]);
        }

        emit PurchaseOrder(_orderOwner, msg.sender, _nftToken, _tokenID, _payToken, _payAmount, _orderID);
    }

    // purchase order mutil
    function purchaseOrderMutil(uint256[] memory _orderIDList) public payable nonReentrant {
        uint256 _orderIDListLen = _orderIDList.length;
        require(_orderIDListLen > 0, "NONEMPTY_ORDER_LIST");

        uint256 _payBaseAmount = 0;
        for ( uint256 _dd = 0; _dd < _orderIDListLen; _dd++ ) {
            uint256 _orderID = _orderIDList[_dd];
            require(_orderID > 0, "ORDER_ERROR");
            require(orderIdIsExisted(_orderID), "ORDER_NOT_EXISTED");
            require(orderList[_orderID].SoldStatus == 1, "ORDER_CANNOT_OPERATE");
            require(orderList[_orderID].TokenID.length == 1, "ORDER_TOKEN_ID_ERROR");

            address _payToken = orderList[_orderID].PayToken;
            // check orderId repetition
            if( (_dd > 0) && (_orderIDListLen > 1) ){
                uint256 _tmp = _dd.sub(1);
                require(_orderIDList[_tmp] != _orderIDList[_dd], "ORDER_ERROR");

                address _payTokenTmp = orderList[_orderIDList[_tmp]].PayToken;
                require(_payToken == _payTokenTmp, "ORDER_PAY_TOKEN_ERROR");
            }

            if( _payToken == BASEADDRESS ) {
                uint256 _payAmount = orderList[_orderID].PayAmount;
                _payBaseAmount = _payBaseAmount.add(_payAmount);
            }

            orderList[_orderID].SoldStatus = 2;
        }

        // check base pay amount
        if( _payBaseAmount > 0 ){
            require(msg.value == _payBaseAmount, "PAY_BASE_AMOUNT_ERROR");
        }

        // transfer
        for ( uint256 _index = 0; _index < _orderIDListLen; _index++ ) {
            uint256 _orderID = _orderIDList[_index];
            _purchaseOrder(_orderID, false);
        }

        emit PurchaseOrderMutil(msg.sender, _orderIDList);
    }

    // transfer mutil
    function transferMutil(address _recipient, address _token, uint256[] memory _tokenIDList) public nonReentrant {
        require(_tokenIDList.length > 0, "NONEMPTY_TOKEN_LIST");

        for( uint256 _d = 0; _d < _tokenIDList.length; _d++ ) {
            require(IERC721(_token).ownerOf(_tokenIDList[_d]) == msg.sender, "NFT_NOT_OWNER");
        }

        for( uint256 _i = 0; _i < _tokenIDList.length; _i++ ) {
            IERC721(_token).safeTransferFrom(msg.sender, _recipient, _tokenIDList[_i]);
        }
        
        emit TransferMutil(msg.sender, _recipient, _token, _tokenIDList);
    }

    // get user nft mutil
    function getUserNftMutil(address[] memory _tokenList, address _user) public view returns(address[] memory, uint256[] memory) {
        uint256 _tokenListlen = _tokenList.length;
        require(_tokenListlen > 0, "TOKEN_ERROR");
        require(_user != address(0), "NONEMPTY_ADDRESS");

        uint256 _tokenIdListlen = 0;

        uint256[] memory _balanceList = new uint256[](_tokenListlen);
        for ( uint256 _d = 0; _d < _tokenListlen; _d++ ) {
            address _token = _tokenList[_d];
            require(_token != address(0), "NONEMPTY_ADDRESS");

            uint256 _balance = IERC721(_token).balanceOf(_user);
            _balanceList[_d] = _balance;

            _tokenIdListlen = _tokenIdListlen.add(_balance);
        }

        uint256[] memory _tokenIdList = new uint256[](_tokenIdListlen);
        address[] memory _tokenListFormat = new address[](_tokenIdListlen);
        uint256 _tmp = 0;
        for ( uint256 _dd = 0; _dd < _tokenListlen; _dd++ ) {
            address _token = _tokenList[_dd];
            uint256 _balance = _balanceList[_dd];

            if ( _balance > 0 ){
                for ( uint256 _ind = 0; _ind < _balance; _ind++ ) {
                    _tokenListFormat[_tmp] = _token;
                    _tokenIdList[_tmp] = IERC721Enumerable(_token).tokenOfOwnerByIndex(_user, _ind);
                    _tmp = _tmp.add(1);
                }
            }
        }

        return (_tokenListFormat, _tokenIdList);
    }

}