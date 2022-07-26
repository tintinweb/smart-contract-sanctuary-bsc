/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

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

contract IGOFilledSubscribe is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address[] public adminList;

    address public BASEADDRESS;// base address

    /* whiteList */
    bool public whiteListStatus = false;// whiteList status

    address[] public whiteList;// whitelist

    // whitelist user status (user address > user status)
    mapping(address => uint256) public whiteListUserStatus;

    /* preemption */
    bool public preemptionStatus = false;// preemption status

    uint256 public preemptionStartAt;// preemption start time

    uint256 public preemptionEndAt;// preemption end time

    // user preemption info
    struct PreemptionInfo {
        uint256 payTokenAmount;
        uint256 subscribeTokenAmount;
    }

    // user preemption list (user address > PreemptionInfo)
    mapping(address => PreemptionInfo) UserPreemptionList;

    // user preemption status (user address > status)
    mapping(address => uint256) public userPreemptionStatus;

    /* time */
    uint256 public pledgeStartAt;// pledge start time

    uint256 public pledgeEndAt;// pledge end time

    uint256 public payStartAt;// pay start time

    uint256 public payEndAt;// pay end time

    uint256 public outputStartAt;// output start time

    uint256 public outputEndAt;// output end time

    /* subscribe */
    address public pledgeToken;// pledge token

    uint256 public pledgeTokenAmount;// pledge token amount

    address public payToken;// pay token

    uint256 public payTokenAmount;// pay token amount

    address public subscribeToken;// subscribe token

    uint256 public subscribeTokenAmount;// subscribe token amount

    uint256 public subscribeTokenTotalSupply;// subscribe token total supply

    uint256 public subscribeTokenAlreadySupply = 0;// subscribe token already supply

    uint256 public subscribeRate = 0;// subscribe increasing rate.   100 mean 0.01

    uint256 public subscribeClaimPeriod = 0;// subscribe claim period.  Unit : second

    // user pledge amount (user address > pledge amount)
    mapping(address => uint256) public userPledgeAmount;

    // user pledge at (user address > time)
    mapping(address => uint256) public userPledgeAt;

    // user pay amount (user address > pay amount)
    mapping(address => uint256) public userPayAmount;

    // user subscribe amount (user address > subscribe amount)
    mapping(address => uint256) public userSubscribeAmount;

    // user subscribe at (user address > time[])
    mapping(address => uint256[]) public userSubscribeAt;

    // user subscribe amount total (user address > subscribe amount)
    mapping(address => uint256) public userSubscribeAmountTotal;

    // user subscribe claim amount (user address > already claim amount)
    mapping(address => uint256) public userAlreadyClaimAmount;

    // user subscribe claim period (user address > period)
    mapping(address => uint256) public userClaimPeriod;

    // user subscribe claim at (user address > time)
    mapping(address => uint256[]) public userClaimAt;

    // user peldge claim at (user address > time)
    mapping(address => uint256) public userPledgeClaimAt;

    address public feeTo;

    constructor(address _IGOOwner) public {
        adminList.push(_IGOOwner);

        BASEADDRESS = address(1);

        feeTo = _IGOOwner;

        transferOwnership(_IGOOwner);
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

    /* fee */
    function setFeeTo(address _feeTo) public nonReentrant onlyAdmin {
        require(_feeTo != address(0), "NONEMPTY_ADDRESS");
        feeTo = _feeTo;
    }

    /* whitelist */
    // set whitelist status
    function setWhiteListStatus(bool _status) public nonReentrant onlyAdmin {
        whiteListStatus = _status;
    }

    // add whitelist
    function addWhiteList(address[] memory _userList) public nonReentrant onlyAdmin {
        require(_userList.length > 0, "NONEMPTY_ADDRESS_LIST");

        for ( uint256 nIndex = 0; nIndex < _userList.length; nIndex++){
            address _user = _userList[nIndex];
            require(_user != address(0), "NONEMPTY_ADDRESS");

            if (whiteListUserStatus[_user] == 0) {
                whiteListUserStatus[_user] = 1;
                whiteList.push(_user);
            }
        }
    }

    // check user is whitelist
    function checkUserIsWhiteList(address _user) public view returns (bool) {
        if (whiteListUserStatus[_user] > 0) {
            return true;
        }else{
            return false;
        }
    }

    modifier onlyWhiteList() {
        if(whiteListStatus == true){
            // open whitelist
            require(checkUserIsWhiteList(msg.sender) == true, "ONLY_WHITELIST_OPERATE");
        }

        _;
    }

    /* preemption */
    // set preemption status
    function setPreemptionStatus(bool _status) public nonReentrant onlyAdmin {
        preemptionStatus = _status;
    }

    // set preemption at
    function setPreemptionAt(uint256 _preemptionStartAt, uint256 _preemptionEndAt) external nonReentrant onlyAdmin {
        require((_preemptionStartAt > 0) && (_preemptionEndAt > 0) && (_preemptionStartAt <= _preemptionEndAt), "AT_ERROR");
        preemptionStartAt = _preemptionStartAt;
        preemptionEndAt = _preemptionEndAt;
    }

    // add preemption list
    function addPreemptionList(address[] memory _userList, uint256[] memory _payTokenAmountList, uint256[] memory _subscribeTokenAmountList) public nonReentrant onlyAdmin {
        require(_userList.length > 0, "NONEMPTY_ADDRESS_LIST");
        require((_userList.length == _payTokenAmountList.length) && (_userList.length == _subscribeTokenAmountList.length), "INCONSISTENT_LENGTH");

        for ( uint256 _dd = 0; _dd < _userList.length; _dd++){
            address _user = _userList[_dd];
            require(_user != address(0), "NONEMPTY_ADDRESS");

            UserPreemptionList[_user].payTokenAmount = _payTokenAmountList[_dd];
            UserPreemptionList[_user].subscribeTokenAmount = _subscribeTokenAmountList[_dd];
        }
    }

    // get user preemption info
    function getUserPreemptionInfo(address _user) public view returns (bool, bool, bool, address, uint256, address, uint256) {
        PreemptionInfo memory _preemptionInfo = UserPreemptionList[_user];
        uint256 _payAmount = _preemptionInfo.payTokenAmount;
        uint256 _subscribeTokenAmount = _preemptionInfo.subscribeTokenAmount;
        return (preemptionStatus, checkUserPreemption(_user), checkUserPreemptionStatus(_user), payToken, _payAmount, subscribeToken, _subscribeTokenAmount);
    }

    /* subscribe */
    // init info
    function initInfo(uint256 _pledgeStartAt, uint256 _pledgeEndAt, uint256 _payStartAt, uint256 _payEndAt, uint256 _outputStartAt, uint256 _outputEndAt, address _pledgeToken, uint256 _pledgeTokenAmount, address _payToken, uint256 _payTokenAmount, address _subscribeToken, uint256 _subscribeTokenAmount, uint256 _subscribeTokenTotalSupply, uint256 _subscribeRate, uint256 _subscribeClaimPeriod) external nonReentrant onlyAdmin {
        pledgeStartAt = _pledgeStartAt;
        pledgeEndAt = _pledgeEndAt;
        payStartAt = _payStartAt;
        payEndAt = _payEndAt;
        outputStartAt = _outputStartAt;
        outputEndAt = _outputEndAt;

        pledgeToken = _pledgeToken;
        pledgeTokenAmount = _pledgeTokenAmount;
        payToken = _payToken;
        payTokenAmount = _payTokenAmount;
        subscribeToken = _subscribeToken;
        subscribeTokenAmount = _subscribeTokenAmount;
        subscribeTokenTotalSupply = _subscribeTokenTotalSupply;
        subscribeRate = _subscribeRate;
        subscribeClaimPeriod = _subscribeClaimPeriod;
    }

    // set subscribe info
    function setSubscribeInfo(address _pledgeToken, uint256 _pledgeTokenAmount, address _payToken, uint256 _payTokenAmount, address _subscribeToken, uint256 _subscribeTokenAmount, uint256 _subscribeTokenTotalSupply, uint256 _subscribeRate, uint256 _subscribeClaimPeriod) external nonReentrant onlyAdmin {
        require((_pledgeToken != address(0)) && (_payToken != address(0)) && (_subscribeToken != address(0)), "NONEMPTY_TOKEN");
        require((_pledgeTokenAmount > 0) && (_payTokenAmount > 0) && (_subscribeTokenAmount > 0) && (_subscribeTokenTotalSupply > 0) && (_subscribeTokenTotalSupply >= _subscribeTokenAmount), "NONEMPTY_AMOUNT");

        pledgeToken = _pledgeToken;
        pledgeTokenAmount = _pledgeTokenAmount;
        payToken = _payToken;
        payTokenAmount = _payTokenAmount;
        subscribeToken = _subscribeToken;
        subscribeTokenAmount = _subscribeTokenAmount;
        subscribeTokenTotalSupply = _subscribeTokenTotalSupply;
        subscribeRate = _subscribeRate;
        subscribeClaimPeriod = _subscribeClaimPeriod;
    }

    // get subscribe info
    function getSubscribeInfo() public view returns (address, uint256, address, uint256, address, uint256, uint256, uint256){
        return (pledgeToken, pledgeTokenAmount, payToken, payTokenAmount, subscribeToken, subscribeTokenAmount, subscribeTokenTotalSupply, subscribeRate);
    }

    // set all time
    function setAllAt(uint256 _pledgeStartAt, uint256 _pledgeEndAt, uint256 _payStartAt, uint256 _payEndAt, uint256 _outputStartAt, uint256 _outputEndAt, uint256 _preemptionStartAt, uint256 _preemptionEndAt) public nonReentrant onlyAdmin {
        require((_pledgeStartAt > 0) && (_pledgeEndAt > 0) && (_payStartAt > 0) && (_payEndAt > 0) && (_outputStartAt > 0) && (_outputEndAt > 0), "NONEMPTY_AT");
        require((_pledgeStartAt < _pledgeEndAt) && (_payStartAt < _payEndAt) && (_outputStartAt < _outputEndAt) && (_pledgeEndAt <= _payStartAt) && (_payEndAt <= _outputStartAt), "AT_ERROR");
        
        if( (_preemptionStartAt > 0) && (_preemptionEndAt > 0) ){
            require((_preemptionStartAt < _preemptionEndAt) && (_preemptionEndAt <= _pledgeStartAt), "PREEMPTION_AT_ERROR");
        }

        pledgeStartAt = _pledgeStartAt;
        pledgeEndAt = _pledgeEndAt;
        payStartAt = _payStartAt;
        payEndAt = _payEndAt;
        outputStartAt = _outputStartAt;
        outputEndAt = _outputEndAt;
        preemptionStartAt = _preemptionStartAt;
        preemptionEndAt = _preemptionEndAt;
    }

    // get all time
    function getAllAt() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        return (pledgeStartAt, pledgeEndAt, payStartAt, payEndAt, outputStartAt, outputEndAt, preemptionStartAt, preemptionEndAt);
    }

    /* check init */
    // check preemption is going
    function checkPreemptionIsGoing() public view returns (bool) {
        if ( preemptionStatus ) {
            if ( (preemptionStartAt <= block.timestamp) && (block.timestamp < preemptionEndAt) ) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    // check pledge is going
    function checkPledgeIsGoing() public view returns (bool) {
        if ( (pledgeStartAt <= block.timestamp) && (block.timestamp < pledgeEndAt) ) {
            return true;
        } else {
            return false;
        }
    }

    // check pay is going
    function checkPayIsGoing() public view returns (bool) {
        if ( (payStartAt <= block.timestamp) && (block.timestamp < payEndAt) ) {
            return true;
        } else {
            return false;
        }
    }

    // check output is going
    function checkOutputIsGoing() public view returns (bool) {
        if ( (outputStartAt <= block.timestamp) && (block.timestamp < outputEndAt) ) {
            return true;
        } else {
            return false;
        }
    }

    // check output is start
    function checkOutputIsStart() public view returns (bool) {
        if (outputStartAt <= block.timestamp) {
            return true;
        }else{
            return false;
        }
    }

    // check output is end
    function checkOutputIsEnd() public view returns (bool) {
        if (outputEndAt <= block.timestamp ) {
            return true;
        }else{
            return false;
        }
    }

    // check subscribe is over
    function checkSubscribeIsOver(uint256 _subscribeAmount) public view returns (bool) {
        if (subscribeTokenAlreadySupply.add(_subscribeAmount) > subscribeTokenTotalSupply ) {
            return true;
        }else{
            return false;
        }
    }

    // get subscribe pay amount
    function getSubscribePayAmount(uint256 _subscribeAmount) public view returns (uint256) {
        uint256 _tmp = subscribeTokenAmount.mul(subscribeRate).div(10000);
        uint256 _subscribeTokenTotal = subscribeTokenAmount.add(_tmp);

        uint256 _tmp2 = payTokenAmount.mul(subscribeRate).div(10000);
        uint256 _payTokenTotal = payTokenAmount.add(_tmp2);

        uint256 _dividend = _payTokenTotal.mul(_subscribeAmount).mul(10000);
        uint256 _res = _dividend.div(_subscribeTokenTotal).div(10000);

        return _res;
    }

    /* check user */
    // check user pledge status
    function checkUserPledgeStatus(address _user) public view returns (bool) {
        if (userPledgeAt[_user] > 0) {
            return true;
        }else{
            return false;
        }
    }

    // check user pledge claim status
    function checkUserPledgeClaimStatus(address _user) public view returns (bool) {
        if (userPledgeClaimAt[_user] > 0) {
            return true;
        }else{
            return false;
        }
    }

    // check user subscribe amount is over
    function checkUserSubscribeIsOver(address _user, uint256 _subscribeAmount) public view returns (bool) {
        uint256 _subscribeTotal = 0;
        if ( checkUserPledgeStatus(_user) ) {
            // already pledge
            uint256 _tmp = subscribeTokenAmount.mul(subscribeRate).div(10000);
            _subscribeTotal = subscribeTokenAmount.add(_tmp);
        } else {
            // no pledge
            _subscribeTotal = subscribeTokenAmount;
        }

        uint256 _userAlreadySubscribe = userSubscribeAmount[_user];
        if ( _userAlreadySubscribe.add(_subscribeAmount) > _subscribeTotal ) {
            return true;
        } else {
            return false;
        }
    }

    // check user subscribe status
    function checkUserSubscribeStatus(address _user) public view returns (bool) {
        if (userSubscribeAt[_user].length > 0) {
            return true;
        } else {
            return false;
        }
    }

    // check user preemption
    function checkUserPreemption(address _user) public view returns (bool) {
        PreemptionInfo memory _preemptionInfo = UserPreemptionList[_user];
        uint256 _subscribeTokenAmountCheck = _preemptionInfo.subscribeTokenAmount;

        if ( _subscribeTokenAmountCheck > 0) {
            return true;
        } else {
            return false;
        }
    }

    // check user preemption status
    function checkUserPreemptionStatus(address _user) public view returns (bool) {
        if (userPreemptionStatus[_user] > 0) {
            return true;
        } else {
            return false;
        }
    }

    // get user subscribe amount
    function getUserSubscribeAmount(address _user) public view returns (uint256, uint256, uint256, uint256) {
        uint256 _userPreemptionSubscribeAmount = 0;
        if ( checkUserPreemptionStatus(_user) ) {
            PreemptionInfo memory _preemptionInfo = UserPreemptionList[msg.sender];
            _userPreemptionSubscribeAmount = _preemptionInfo.subscribeTokenAmount;
        }
        uint256 _userSubscribeAmount = userSubscribeAmount[_user];

        uint256 _userCansubscribeTotal = 0;
        if ( checkUserPledgeStatus(_user) ) {
            // already pledge
            uint256 _tmp = subscribeTokenAmount.mul(subscribeRate).div(10000);
            _userCansubscribeTotal = subscribeTokenAmount.add(_tmp);
        } else {
            // no pledge
            _userCansubscribeTotal = subscribeTokenAmount;
        }

        return (_userPreemptionSubscribeAmount, _userSubscribeAmount, userSubscribeAmountTotal[_user], _userCansubscribeTotal);
    }

    // get user claim amount
    function getUserCanClaimAmount(address _user) public view returns (uint256, uint256, uint256, bool) {
        uint256 _claimAmount = 0;// claim amount
        uint256 _periodCurrent = 0; // current period
        uint256 _periodTotal = 0;// period total
        bool _claimStatus = false;

        if ( checkOutputIsStart() ) {
            // calculate period
            uint256 _periodDuration = subscribeClaimPeriod;// period duration
            uint256 _atTotal = outputEndAt.sub(outputStartAt);// output at total
            if( ( _periodDuration > 0) && ( _atTotal > 0) && (_periodDuration < _atTotal) ) {
                _periodTotal = _atTotal.div(_periodDuration);
                if( _atTotal.mod(_periodDuration) > 0 ){
                    _periodTotal = _periodTotal.add(1);
                }
            } else {
                _periodTotal = 1;
            }

            if ( checkOutputIsGoing() ) {
                // output going

                if( checkUserSubscribeStatus(_user) ) {
                    for ( uint256 _dd = 1; _dd <= _periodTotal; _dd++ ) {
                        uint256 _atTmp = _periodDuration.mul(_dd).add(outputStartAt);// period end at

                        if( (block.timestamp >= _atTmp) && (_atTmp > outputStartAt) ) {
                            _periodCurrent = _dd;
                        }
                    }

                    // calculate claim amount
                    if ( (_periodCurrent > 0) && (_periodTotal > 0) ) {
                        uint256 _userLastClaimPeriod = userClaimPeriod[_user];// last claim period
                        if ( _periodCurrent > _userLastClaimPeriod ) {
                            uint256 _periodTmp = _periodCurrent.sub(_userLastClaimPeriod);// can claim period amount
                            address _userTmp = _user;
                            _claimAmount = userSubscribeAmountTotal[_userTmp].div(_periodTotal).mul(_periodTmp);
                        }
                    }

                    if( _claimAmount > 0 ) {
                        _claimStatus = true;
                    }
                }
                
            } else if ( checkOutputIsEnd() ) {
                // output end
                _periodCurrent = _periodTotal;

                // calculate claim amount
                if ( userSubscribeAmountTotal[_user] > userAlreadyClaimAmount[_user] ) {
                    _claimAmount = userSubscribeAmountTotal[_user].sub(userAlreadyClaimAmount[_user]);
                }

                if ( ( checkUserPledgeStatus(_user) && (checkUserPledgeClaimStatus(_user) == false) ) || (_claimAmount > 0) ) {
                    _claimStatus = true;
                }
            }
        }

        return (_claimAmount, _periodCurrent, _periodTotal, _claimStatus);
    }

    // withdraw
    function withdraw(address _token) public onlyOwner nonReentrant {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance > 0, "BALANCE_ERROR");
        IERC20(_token).transfer(msg.sender, balance);
    }

    event FillPledge(address _sender, address _pledgeToken, uint256 _pledgeTokenAmount, uint256 _at);
    event FillSubscribe(address _sender, address _payToken, uint256 _payTokenAmount, address _subscribeToken, uint256 _subscribeTokenAmount, uint256 _at);
    event FillClaimSubscribe(address _sender, address _pledgeToken, uint256 _pledgeTokenAmount, address _payToken, uint256 _payTokenAmount, uint256 _periodCurrent, uint256 _periodTotal, uint256 _at);

    function pledge() public nonReentrant onlyWhiteList {
        require(checkPledgeIsGoing(), "PLEDGE_SUBSCRIBE_NOT_GOING");
        require(checkUserPledgeStatus(msg.sender) == false, "USER_ALREADY_PLEDGE");

        userPledgeAmount[msg.sender] = pledgeTokenAmount;
        userPledgeAt[msg.sender] = block.timestamp;

        IERC20(pledgeToken).safeTransferFrom(msg.sender, address(this), pledgeTokenAmount);

        emit FillPledge(msg.sender, pledgeToken, pledgeTokenAmount, block.timestamp);
    }

    function subscribe(uint256 _subscribeTokenAmount) public payable nonReentrant {
        uint256 _payAmount = 0;

        if ( checkPreemptionIsGoing() ) {
            // preemption
            require(checkUserPreemption(msg.sender), "USER_PREEMPTION_SUBSCRIBE_ERROR");
            require(checkUserPreemptionStatus(msg.sender) == false, "USER_ALREADY_PREEMPTION_SUBSCRIBE");
            require(checkSubscribeIsOver(_subscribeTokenAmount) == false, "SUBSCRIBE_SUPPLY_INSUFFICIENT");

            PreemptionInfo memory _preemptionInfo = UserPreemptionList[msg.sender];
            _payAmount = _preemptionInfo.payTokenAmount;
            uint256 _subscribeTokenAmountCheck = _preemptionInfo.subscribeTokenAmount;
            require(_subscribeTokenAmount == _subscribeTokenAmountCheck, "SUBSCRIBE_AMOUNT_ERROR");

            subscribeTokenAlreadySupply = subscribeTokenAlreadySupply.add(_subscribeTokenAmount);

            userPreemptionStatus[msg.sender] = block.timestamp;

            userSubscribeAt[msg.sender].push(block.timestamp);
            userSubscribeAmountTotal[msg.sender] = userSubscribeAmountTotal[msg.sender].add(_subscribeTokenAmount);

            if ( _payAmount > 0 ) {
                userPayAmount[msg.sender] = userPayAmount[msg.sender].add(_payAmount);

                if ( payToken == BASEADDRESS ) {
                    require(msg.value == _payAmount, "CHECK_PAY_AMOUNT_ERROR");
                    address payable _feeTo = address(uint160(feeTo));
                    _feeTo.transfer(_payAmount);
                } else {
                    IERC20(payToken).safeTransferFrom(msg.sender, feeTo, _payAmount);
                }
            }

        } else if( checkPayIsGoing() ) {
            // subscribe

            if ( whiteListStatus ) {
                // open whitelist
                require(checkUserIsWhiteList(msg.sender) == true, "ONLY_WHITELIST_OPERATE");
            }

            require(checkSubscribeIsOver(_subscribeTokenAmount) == false, "SUBSCRIBE_SUPPLY_INSUFFICIENT");
            require(checkUserSubscribeIsOver(msg.sender, _subscribeTokenAmount) == false, "USER_SUBSCRIBE_INSUFFICIENT");

            subscribeTokenAlreadySupply = subscribeTokenAlreadySupply.add(_subscribeTokenAmount);

            userSubscribeAmount[msg.sender] = userSubscribeAmount[msg.sender].add(_subscribeTokenAmount);
            userSubscribeAt[msg.sender].push(block.timestamp);
            userSubscribeAmountTotal[msg.sender] = userSubscribeAmountTotal[msg.sender].add(_subscribeTokenAmount);

            _payAmount = getSubscribePayAmount(_subscribeTokenAmount);
            require(_payAmount > 0, "PAY_AMOUNT_ERROR");
            userPayAmount[msg.sender] = userPayAmount[msg.sender].add(_payAmount);

            if ( payToken == BASEADDRESS ) {
                require(msg.value == _payAmount, "CHECK_PAY_AMOUNT_ERROR");
                address payable _feeTo = address(uint160(feeTo));
                _feeTo.transfer(_payAmount);
            } else {
                IERC20(payToken).safeTransferFrom(msg.sender, feeTo, _payAmount);
            }

        } else {
            require(checkPayIsGoing(), "SUBSCRIBE_NOT_GOING");
        }

        emit FillSubscribe(msg.sender, payToken, _payAmount, subscribeToken, _subscribeTokenAmount, block.timestamp);
    }

    function claimSubscribe() public nonReentrant {
        (uint256 _claimAmount, uint256 _periodCurrent, uint256 _periodTotal, bool _claimStatus) = getUserCanClaimAmount(msg.sender);
        require(_claimStatus, "CLAIM_STATUS_ERROR");

        // claim subscribe
        if( _claimAmount > 0 ){
            userAlreadyClaimAmount[msg.sender] = userAlreadyClaimAmount[msg.sender].add(_claimAmount);

            userClaimPeriod[msg.sender] = _periodCurrent;

            userClaimAt[msg.sender].push(block.timestamp);

            IERC20(subscribeToken).safeTransfer(msg.sender, _claimAmount);
        }

        // claim pledge
        uint256 _userPledgeAmount = 0;
        if ( checkOutputIsEnd() && checkUserPledgeStatus(msg.sender) && (checkUserPledgeClaimStatus(msg.sender) == false) ){
            // output is end && user already pledge && user no claim pledge
            userPledgeClaimAt[msg.sender] = block.timestamp;
            _userPledgeAmount = userPledgeAmount[msg.sender];
            IERC20(pledgeToken).safeTransfer(msg.sender, _userPledgeAmount);
        }

        emit FillClaimSubscribe(msg.sender, pledgeToken, _userPledgeAmount, subscribeToken, _claimAmount, _periodCurrent, _periodTotal, block.timestamp);
    }

}

contract IGOFilledSubscribeFactory is Ownable, ReentrancyGuard{
    using SafeMath for uint256;

    address[] public adminList;

    address[] public allDLCs;

    constructor() public {
        adminList.push(msg.sender);
    }

    event DLCCreated(address _DLCOwner, address _DLCAddress);

    function createDLC() external onlyAdmin returns (address _DLCAddress) {

        bytes32 salt = keccak256(abi.encodePacked(msg.sender, keccak256(abi.encodePacked(type(IGOFilledSubscribe).creationCode)), block.timestamp));
        IGOFilledSubscribe DLCArr = new IGOFilledSubscribe{salt: salt}(msg.sender);

        _DLCAddress = address(DLCArr);
        allDLCs.push(_DLCAddress);

        emit DLCCreated(msg.sender, _DLCAddress);
    }

    function getAllDLC() public view returns (address[] memory) {
        return allDLCs;
    }

    function allDLCLength() public view returns (uint256) {
        return allDLCs.length;
    }

    function setAdminList(address[] memory _list) public nonReentrant onlyOwner {
        require(_list.length > 0, "NONEMPTY_ADDRESS_LIST");
        
        for ( uint256 nIndex = 0; nIndex < _list.length; nIndex++){
            require(_list[nIndex] != address(0), "ADMIN_NONEMPTY_ADDRESS");
        }
        adminList = _list;
    }

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

}