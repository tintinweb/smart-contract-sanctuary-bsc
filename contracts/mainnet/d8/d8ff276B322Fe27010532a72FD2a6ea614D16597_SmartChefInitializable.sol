/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

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
    constructor() internal {
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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

pragma solidity >=0.6.0 <0.8.0;

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

    constructor() internal {
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

// File: bsc-library/contracts/IBEP20.sol

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity >=0.6.2 <0.8.0;

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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// File: bsc-library/contracts/SafeBEP20.sol

pragma solidity ^0.6.0;

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// File: contracts/SmartChefInitializable.sol

pragma solidity 0.6.12;

contract SmartChefInitializable is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // The address of the smart chef factory
    address public SMART_CHEF_FACTORY;

    // The address of the smart chef factory
    address public feeAddress = 0x000000000000000000000000000000000000dEaD;

    // Whether a limit is set for users
    bool public hasUserLimit;

    // Whether it is initialized
    bool public isInitialized;

    // Whether it is initialized
    bool public emergencyUnlock = false;

    // Accrued token per share
    uint256 public accTokenPerShare;

    // The block number when CGOLD mining ends.
    uint256 public bonusEndBlock;

    // The block number when CGOLD mining starts.
    uint256 public startBlock;

    // The block number of the last pool update
    uint256 public lastRewardBlock;

    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;

    // CGOLD tokens created per block.
    uint256 public rewardPerBlock;

    // Deposit Fee.
    uint256 public depositFeeBP;

    // Withdraw Fee.
    uint256 public withdrawFeeBP;

    uint256 public contractLockPeriod; // 6-month in seconds


    // The precision factor
    uint256 public PRECISION_FACTOR;

    // The reward token
    IBEP20 public rewardToken;

    // The staked token
    IBEP20 public stakedToken;
    // The total staked amount
    uint256 public totalstakedAmount = 0;
   
    uint256 public withdrawalFeeInterval;
    uint256 public withdrawalFeeDeadline; 

    mapping(address => UserInfo) public userInfo;
    mapping (address => bool) public _isWhitelisted;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        uint256 noWithdrawalFeeAfter;
        uint256 depositTime;
        uint256 rewardLockedUp;  // Reward locked up.
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);
    event NewFees(uint256 newDepositFeeBP, uint256 newWithdrawFeeBP);
    event UpdatedFeeAddress(address oldfeeaddress, address newfeeaddress);

    constructor() public {
        SMART_CHEF_FACTORY = msg.sender;
        _isWhitelisted[msg.sender];

        _isWhitelisted[0x3869c723e68660e4f81C51394073B98AeA67aC9F];
        _isWhitelisted[0x0CD4C4A8492902993074068441540CfFcF8D8433];
        _isWhitelisted[0x4bcD0e827dCAF744983209405Eee40824bF19b7F];
        _isWhitelisted[0xedD400409407f65DE8BB41d7B50548844B6C500A];
        _isWhitelisted[0x322654be005A78ef393746f5689e66E183D8682C];
        _isWhitelisted[0x26efFb5D61014964467aB8D7f0EEf72aC89B6257];
        _isWhitelisted[0xff4c0DA35A783B3cCD2E87E6ED0546592D4ed876];
        _isWhitelisted[0x9cbe5e2148EC011Ab20cCea0E7674E52ECF4B715];
        _isWhitelisted[0xb13180f01BA90C25eE57093A1fB4094bEb4D000e];
        _isWhitelisted[0x804490aC4879806923cE081c906efb85Fc8876c4];
        _isWhitelisted[0xC277567C918Ee857D996C7A601c4356eC7DE4A3d];
        _isWhitelisted[0xc13d7498EC470e8aF8aEAC363d854A997F3683d7];
        _isWhitelisted[0xC079665458b4Ccaf47cDFdff7aB84D8AB66d50AB];
        _isWhitelisted[0xC4ab64e403A07CffF9420E6De1F098d21Ff05F59];
        _isWhitelisted[0x641d6f96589AA21eD0f50b3F4ae4fA9b6Fa1a057];
        _isWhitelisted[0x1ee8738153744BB899695eceae823Ad9267a7bD7];
        _isWhitelisted[0x476ED8dc608Ba11deF575ac769E8c8fC3a1A6840];
        _isWhitelisted[0x0C37357eB7575fDD89190D7AAE2a43e5aA04cdcA];
        _isWhitelisted[0x1ee8738153744BB899695eceae823Ad9267a7bD7];
        _isWhitelisted[0x5D7a20991339102A879d52D626904BA54C70B453];
        _isWhitelisted[0xF6b1453a51BadadB67f4EF19445F3cc7F7D5C423];
        _isWhitelisted[0xB04Fc2Ea9C521636C9DC471d07ebFf0E750dFb4B];
        _isWhitelisted[0xD74A687837C4198ACBB1D8CEB2a3b77BB631BeC7];
        _isWhitelisted[0xC9cD314297d425322B894FDbf05f60c54F15746D];
        _isWhitelisted[0x2222aC7922755D3b38740d8647857AAFBf2A766b];
        _isWhitelisted[0xe0833a33Af980D4D3B5a84DE6E9615725f197131];
        _isWhitelisted[0xc77511B5d066775bcaAEAfE40762152fb7FB5cA1];
        _isWhitelisted[0x998530b132Bc9c3f8FfEbbDC15199a021841D258];
        _isWhitelisted[0x9f575feCa1B8Ed08C4c87F6Cf6BF8577b6592343];
        _isWhitelisted[0xF6b1453a51BadadB67f4EF19445F3cc7F7D5C423];
        _isWhitelisted[0x698De3CD4af2854953D895B2335Ca3F5a8d94eD7];
        _isWhitelisted[0x92Dd51a91d559B5DB476CcE6F6Cfbb7372Afa0f7];
        _isWhitelisted[0x83b9998ea4EBdA46f5086De9BB6Fd6668EdFaa71];
        _isWhitelisted[0x57367F38772300007A30DFF0f1aa1B76bDAF8603];
        _isWhitelisted[0x7adf3a57363ed2447D4f3A647Afe6Ca527015C21];
        _isWhitelisted[0x27C3cA5C0F628830c730860441f8a9B73a58DeA2];
        _isWhitelisted[0x3254315a6B006C898Ef2D3BF1e922E76fe44159B];
        _isWhitelisted[0x476ED8dc608Ba11deF575ac769E8c8fC3a1A6840];
        _isWhitelisted[0xF6b1453a51BadadB67f4EF19445F3cc7F7D5C423];
        _isWhitelisted[0x62750a161b6DA69cCfc85F1106Bd66BAB0b8f656];
        _isWhitelisted[0x4Ee256Dd9BEeA8079790b577C807004207344aE5];
        _isWhitelisted[0xc222949dEeb9C02f1d57308e4B4d27996A750f65];
        _isWhitelisted[0xB37eCAaB5e4bD0634fAA388dF041C54151bbe06B];
        _isWhitelisted[0xbf1C04d127bF8DdE89c4347b23e21465BD9eCE7D];
        _isWhitelisted[0x26efFb5D61014964467aB8D7f0EEf72aC89B6257];
        _isWhitelisted[0xff4c0DA35A783B3cCD2E87E6ED0546592D4ed876];
        _isWhitelisted[0x0CD4C4A8492902993074068441540CfFcF8D8433];
        _isWhitelisted[0x1ee8738153744BB899695eceae823Ad9267a7bD7];
        _isWhitelisted[0x561BB0974a93E74A9BA0298591688a83B143a0C8];
        _isWhitelisted[0x1B52234CC36aAaA6e6C756796A0A7D2fB2F271Ff];
        _isWhitelisted[0xD05E3215DF8B8DA4659200141fC964Ec2D703c0B];
        _isWhitelisted[0x89C57a47d6066FF44eC4b3b3f9e53B8E17e9Ce43];
        _isWhitelisted[0xfeA76Cc68732E867BA61dE0AE4d9a817132B2b51];
        _isWhitelisted[0x35dCC4C3Ce116649bac123d4c27096806A2Ad7B4];
        _isWhitelisted[0xba2B124EFA638Bd6Ec66CeC17133d6e3c7bB484C];
        _isWhitelisted[0x4Ee256Dd9BEeA8079790b577C807004207344aE5];
        _isWhitelisted[0xb13180f01BA90C25eE57093A1fB4094bEb4D000e];
        _isWhitelisted[0x1ee8738153744BB899695eceae823Ad9267a7bD7];
        _isWhitelisted[0xF7FcF67CE1fc15C9DA53872990B3708dbf5afE25];
        _isWhitelisted[0x604374F9E30c74fe8c860A9933d82FF3d0E736a4];
        _isWhitelisted[0xC0ff39486D9B63C2e61D0772a7770BA1c37C76dC];
        _isWhitelisted[0xe711dCb2aD75033798182Fb3D0119AE24FdDF900];
        _isWhitelisted[0x643599F94d46270B3615E4B2449e5a291a4dd469];
        _isWhitelisted[0x9E7dDBB0858E68a8c80158f386fAe4666658C9E6];
        _isWhitelisted[0x9E99e71C29a142f777aE7Df116F5C2D541FFE469];
        _isWhitelisted[0xb13180f01BA90C25eE57093A1fB4094bEb4D000e];
        _isWhitelisted[0xF6b1453a51BadadB67f4EF19445F3cc7F7D5C423];
        _isWhitelisted[0x2aF6dB169066161c93F898B9D6422f92a0981A10];
        _isWhitelisted[0x3AaBcB5b684A2B5b0ae466132CA3762705CA6D18];
        _isWhitelisted[0x66eC9BB1Ebe85F50D116A1c3eEd1D286bD2D9618];
        _isWhitelisted[0x35055dC57b925bcc2cbBfdd75e4f2A7e4698C4e0];
        _isWhitelisted[0x0571886Dbd134b096aA4C4EeC8390eE83a1E13AB];
        _isWhitelisted[0xe1fD38df9a748690CDc36686F46f22167b4994cC];
        _isWhitelisted[0x0CD4C4A8492902993074068441540CfFcF8D8433];
        _isWhitelisted[0x998530b132Bc9c3f8FfEbbDC15199a021841D258];
        _isWhitelisted[0x6848b0A4C76E02A3709144f9f083fF3104ED787a];
        _isWhitelisted[0x9D596297c0710d0c5B7F5B8d5C51cFd0Fbb5C356];
        _isWhitelisted[0xeACBC4Fe2284aFb2De7dB4B391ebb9F001c59728];
        _isWhitelisted[0x6c72794d2aAE714627FDeb44427f59D1E51A9423];
        _isWhitelisted[0x5fa84B43b2cdD79cd8758024CA028e4216499f43];
        _isWhitelisted[0x6d3c08acE11347e9d26b49f2A61e45DcB18a837b];
        _isWhitelisted[0x84bf2b079C0d26eFEa1133Fea2C2F10423d55B05];
        _isWhitelisted[0x4dd75536F10E3CFe0d6a1d4142FdB71Af1399922];
        _isWhitelisted[0xa446ccB0981b93EE243FEF03730aCb0Ac56B5D49];
        _isWhitelisted[0x982a64d9e0F2F1F80885ce7eF125599904b27b6b];
        _isWhitelisted[0x0b2eB501405306F37a5fa2FDafe6Fe31318f3e8F];
        _isWhitelisted[0xd500573F0133B90c2305c91F11577780fc3bAAbC];
        _isWhitelisted[0x719C5328484b2e53cfb8d446DCC1d5923C4D08c7];
        _isWhitelisted[0xd25a0294a61471B05e1104E2298d6f11f7Ca58B1];
        _isWhitelisted[0x722e2B2c7Ba0eA3a0EDbddAfF5967f54C3b8D59A];
        _isWhitelisted[0x9E99e71C29a142f777aE7Df116F5C2D541FFE469];
        _isWhitelisted[0x2222aC7922755D3b38740d8647857AAFBf2A766b];
        _isWhitelisted[0x540490aFdec63dF7C3781be4470a8D0dB90a4040];
        _isWhitelisted[0x322654be005A78ef393746f5689e66E183D8682C];
        _isWhitelisted[0xC277567C918Ee857D996C7A601c4356eC7DE4A3d];
        _isWhitelisted[0xBB5531bE5eaDD67fb01C2b982E76C5427934cE2e];
        _isWhitelisted[0x813EE4f74E394619C24a54D14aD8Be11eBD0aF1A];
        _isWhitelisted[0x95966ac17b1859A3E2C3605047e613388d1Da756];
        _isWhitelisted[0x631F5C9d21BCae5058bD58fE5358458Dd0ae925b];

    }

    /*
     * @notice Initialize the contract
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _bonusEndBlock: end block
     * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     */
    function initialize(
        IBEP20 _stakedToken,
        IBEP20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _poolLimitPerUser,
        uint256 _depositFeeBP,
        uint256 _withdrawFeeBP,
        uint256 _withdrawalFeeInterval,
        uint256 _withdrawalFeeDeadline,
        uint256 _contractLockPeriod,
        address _admin
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == SMART_CHEF_FACTORY, "Not factory");
        require(_depositFeeBP <= 10000, "Cannot be bigger than 100");
        require(_withdrawFeeBP <= 10000, "Cannot be bigger than 100");
        // Make this contract initialized
        isInitialized = true;

        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        depositFeeBP = _depositFeeBP;
        withdrawFeeBP = _withdrawFeeBP;
        withdrawalFeeInterval = _withdrawalFeeInterval;
        withdrawalFeeDeadline = _withdrawalFeeDeadline;
        contractLockPeriod = _contractLockPeriod;
        if (_poolLimitPerUser > 0) {
            hasUserLimit = true;
            poolLimitPerUser = _poolLimitPerUser;
        }

        uint256 decimalsRewardToken = uint256(rewardToken.decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");

        PRECISION_FACTOR = uint256(10**(uint256(30).sub(decimalsRewardToken)));

        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;

        // Transfer ownership to the admin address who becomes owner of the contract
        transferOwnership(_admin);
    }

    function remainLockTime(address _user) 
        public
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_user];
        uint256 timeElapsed = block.timestamp - (user.depositTime);
        uint256 remainingLockTime = 0;
        if (user.depositTime == 0) {
            remainingLockTime = 0;
        } else if(timeElapsed < contractLockPeriod) {
            remainingLockTime = (contractLockPeriod - (timeElapsed)) > /* valor do endblock em unix */ bonusEndBlock ? /* valor do endblock em unix */ bonusEndBlock : (contractLockPeriod - (timeElapsed));
        }

        return remainingLockTime;
    }
    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in rewardToken)
     */

    // BLACKLIST FUNCTION
    function whitelistAddress(address account, bool value) external onlyOwner{
        _isWhitelisted[account] = value;
    }

    function deposit(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 remainLock = remainLockTime(msg.sender);
        uint256 depositAmount = _amount;
        if (hasUserLimit) {
            require(_amount.add(user.amount) <= poolLimitPerUser, "User amount above limit");
        }

        _updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
             if (pending > 0 || user.rewardLockedUp > 0) {
                  if (remainLock <= 0) {
                      pending = pending.add(user.rewardLockedUp);
                      rewardToken.safeTransfer(address(msg.sender), pending);
                      user.rewardLockedUp = 0;
            } else if (pending > 0) {
                    user.rewardLockedUp = user.rewardLockedUp.add(pending);
                }
        } }

        if (_amount > 0) {
            require(stakedToken.balanceOf(address(msg.sender)) >= _amount);
            uint256 beforeStakedTokenTotalBalance = stakedToken.balanceOf(address(this));
            if(depositFeeBP > 0 && !_isWhitelisted[msg.sender]) {
                uint256 depositFee = _amount.mul(depositFeeBP).div(10000);
                stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount.sub(depositFee));
                stakedToken.safeTransferFrom(address(msg.sender), feeAddress, depositFee);
            } else {
                stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            }
            uint256 depositedAmount = stakedToken.balanceOf(address(this)).sub(beforeStakedTokenTotalBalance);
            user.amount = user.amount.add(depositedAmount);
            depositAmount = depositedAmount;
            totalstakedAmount = totalstakedAmount.add(depositedAmount);
            uint256 shouldNotWithdrawBefore = block.timestamp + withdrawalFeeInterval;
            if (shouldNotWithdrawBefore > withdrawalFeeDeadline) {
                shouldNotWithdrawBefore = withdrawalFeeDeadline;
            }
            user.noWithdrawalFeeAfter = shouldNotWithdrawBefore;
            user.depositTime = block.timestamp;
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        emit Deposit(msg.sender, depositAmount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 remainLock = remainLockTime(msg.sender);
        require(user.amount >= _amount, "Amount to withdraw too high");
        uint256 checkWithdrawBlock = startBlock.add(contractLockPeriod);
        require(remainLock <= 0
        || block.number >= checkWithdrawBlock
        || emergencyUnlock == true, "withdraw: locktime remains!");
        _updatePool();

        uint256 pending = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt).add(user.rewardLockedUp);

        if (_amount > 0) {
            uint256 beforestakedtokentotalsupply = stakedToken.balanceOf(address(this));
            if(withdrawFeeBP > 0) {
                uint256 withdrawFee = _amount.mul(withdrawFeeBP).div(10000);
                stakedToken.safeTransfer(address(msg.sender), _amount.sub(withdrawFee));
                stakedToken.safeTransfer(feeAddress, withdrawFee);
            } else {
                stakedToken.safeTransfer(address(msg.sender), _amount);
            }
            uint256 withdrawamount = beforestakedtokentotalsupply.sub(stakedToken.balanceOf(address(this)));
            totalstakedAmount = totalstakedAmount.sub(withdrawamount);
            user.amount = user.amount.sub(withdrawamount);
            user.noWithdrawalFeeAfter = block.timestamp + withdrawalFeeInterval;
        }

        if (pending > 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        user.rewardLockedUp = 0;
        emit Withdraw(msg.sender, _amount);
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;

        if (amountToTransfer > 0) {
            totalstakedAmount = totalstakedAmount.sub(amountToTransfer);
            stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    function _emergencyUnlock(bool _unlock) external onlyOwner {
        emergencyUnlock = _unlock;
    }
    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(stakedToken), "Cannot be staked token");
        require(_tokenAddress != address(rewardToken), "Cannot be reward token");

        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner
     */
    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser(bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        require(hasUserLimit, "Must be set");
        if (_hasUserLimit) {
            require(_poolLimitPerUser > poolLimitPerUser, "New limit must be higher");
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            hasUserLimit = _hasUserLimit;
            poolLimitPerUser = 0;
        }
        emit NewPoolLimit(poolLimitPerUser);
    }

    /*
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerBlock: the reward per block
     */
    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    function updateFees(uint256 _newDepositFeeBP, uint256 _newWithdrawFeeBP) external onlyOwner {
        depositFeeBP = _newDepositFeeBP;
        withdrawFeeBP = _newWithdrawFeeBP;
        emit NewFees(depositFeeBP, withdrawFeeBP);
    }

    function updateFeeAddress(address newFeeAddress) external {
        require(msg.sender == feeAddress, "Set: You do not have right permission");
        emit UpdatedFeeAddress(feeAddress, newFeeAddress);
        feeAddress = newFeeAddress;
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @dev This function is only callable by owner.
     * @param _startBlock: the new start block
     * @param _bonusEndBlock: the new end block
     */
    function updateStartAndEndBlocks(
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _withdrawalFeeInterval,
        uint256 _withdrawalFeeDeadline,
        uint256 _contractLockPeriod
        ) external onlyOwner {
        require(_startBlock < _bonusEndBlock, "New startBlock must be lower than new endBlock");
        require(block.number < _startBlock, "New startBlock must be higher than current block");

        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        withdrawalFeeInterval = _withdrawalFeeInterval;
        withdrawalFeeDeadline = _withdrawalFeeDeadline;
        contractLockPeriod = _contractLockPeriod;

        // Set the lastRewardBlock as the startBlock
        lastRewardBlock = startBlock;

        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (block.number > lastRewardBlock && totalstakedAmount != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 vivReward = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare =
                accTokenPerShare.add(vivReward.mul(PRECISION_FACTOR).div(totalstakedAmount));
            return user.amount.mul(adjustedTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        } else {
            return user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
        }
    }

    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if (block.number <= lastRewardBlock) {
            return;
        }

        if (totalstakedAmount == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 vivReward = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(vivReward.mul(PRECISION_FACTOR).div(totalstakedAmount));
        lastRewardBlock = block.number;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }

    function rewardDuration() public view returns (uint256) {
        return bonusEndBlock.sub(startBlock);
    }

    function calcRewardPerBlock() public onlyOwner {
        require(block.number < startBlock, "Pool has started");
        uint256 rewardBal = rewardToken.balanceOf(address(this));
        rewardPerBlock = rewardBal.div(rewardDuration());
    }
}