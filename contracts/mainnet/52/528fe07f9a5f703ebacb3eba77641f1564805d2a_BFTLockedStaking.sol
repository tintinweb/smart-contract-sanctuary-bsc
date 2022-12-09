/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// Sources flattened with hardhat v2.8.4 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]


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


// File @openzeppelin/contracts/security/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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


// File @openzeppelin/contracts/utils/math/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File contracts/BFTLockedStaking.sol


pragma solidity ^0.8.0;
abstract contract IERC20Staking is ReentrancyGuard, Ownable {

    struct Plan {
        uint256 overallStaked;
        uint256 stakesCount;
        uint256 apr;
        uint256 stakeDuration;
        uint256 depositDeduction;
        uint256 withdrawDeduction;
        uint256 earlyPenalty;
        bool initialPool;
        bool conclude;
    }
    
    struct Staking {
        uint256 amount;
        uint256 stakeAt;
        uint256 endstakeAt;
    }

    mapping(uint256 => mapping(address => Staking[])) public stakes;

    address public stakingToken;
    mapping(uint256 => Plan) public plans;

    constructor(address _stakingToken) {
        stakingToken = _stakingToken;
    }

    function stake(uint256 _stakingId, uint256 _amount)  public virtual;
    function canWithdrawAmount(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function unstake(uint256 _stakingId, uint256 _amount) public virtual;
    function earnedToken(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function claimEarned(uint256 _stakingId) public virtual;
    function getStakedPlans(address _account) public virtual view returns (bool[] memory);
}

contract BFTLockedStaking is IERC20Staking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public periodicTime = 365 days;
    uint256 planLimit = 3;
    uint256 MAXRLIMIT = 1000;
    
    struct ReferralStake {
        uint256 stakingId;
        uint256 stakedAmount;
        uint256 stakeAt;
        address[] claimers;
    }

    struct Referral {
        address referrer;
        address[] referees;
        mapping(address => ReferralStake[]) referralStakes;
    }

    uint256 referralLevels = 3;
    uint256 minTokenForReferral = 1;
    mapping(address => Referral) public referrals; 
    mapping(uint256 => uint256) public referralLevelEarnings;
   
    constructor(address _stakingToken) IERC20Staking(_stakingToken) {
        plans[0].apr = 8;
        plans[0].stakeDuration = 90 days;
        plans[0].earlyPenalty = 75;

        plans[1].apr = 15;
        plans[1].stakeDuration = 180 days;
        plans[1].earlyPenalty = 75;

        plans[2].apr = 30;
        plans[2].stakeDuration = 365 days;
        plans[2].earlyPenalty = 75;

        referralLevelEarnings[0] = 3;
        referralLevelEarnings[1] = 2;
        referralLevelEarnings[2] = 1;
    }

    function referralStake(uint256 _stakingId, uint256 _amount, address _referrer)  public {
        require(_referrer!=msg.sender, "You can't refer yourself");

        if(referrals[msg.sender].referrer == address(0) && getTotalStakedAmount(_referrer) >= minTokenForReferral) {
            referrals[msg.sender].referrer = _referrer;
            referrals[_referrer].referees.push(msg.sender);
        }

        stake(_stakingId, _amount);
    }

    function stake(uint256 _stakingId, uint256 _amount) public override {
        require(_amount > 0, "Staking Amount cannot be zero");
        require(
            IERC20(stakingToken).balanceOf(msg.sender) >= _amount,
            "Balance is not enough"
        );
        require(_stakingId < planLimit, "Staking is unavailable");
        
        Plan storage plan = plans[_stakingId];
        require(!plan.conclude, "Staking in this pool is concluded");

        uint256 beforeBalance = IERC20(stakingToken).balanceOf(address(this));
        IERC20(stakingToken).transferFrom(msg.sender, address(this), _amount);
        uint256 afterBalance = IERC20(stakingToken).balanceOf(address(this));
        uint256 amount = afterBalance - beforeBalance;
        
        uint256 deductionAmount = amount.mul(plan.depositDeduction).div(1000);
        if(deductionAmount > 0) {
            IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        }
        
        uint256 stakelength = stakes[_stakingId][msg.sender].length;
        
        if(stakelength == 0) {
            plan.stakesCount += 1;
        }

        stakes[_stakingId][msg.sender].push();
        
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.amount = amount.sub(deductionAmount);
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plan.stakeDuration;
        
        plan.overallStaked = plan.overallStaked.add(
            amount.sub(deductionAmount)
        );

        if(referrals[msg.sender].referrer != address(0)) {
            address _referrer = referrals[msg.sender].referrer;
            
            ReferralStake storage _referralStake = referrals[_referrer].referralStakes[msg.sender].push();
            _referralStake.stakingId = _stakingId;
            _referralStake.stakedAmount = _staking.amount;
            _referralStake.stakeAt =  _staking.stakeAt;
        }
    }

    function canWithdrawAmount(uint256 _stakingId, address _account) public override view returns (uint256, uint256) {
        uint256 _stakedAmount = 0;
        uint256 _canWithdraw = 0;
        for (uint256 i = 0; i < stakes[_stakingId][_account].length; i++) {
            Staking storage _staking = stakes[_stakingId][_account][i];
            _stakedAmount = _stakedAmount.add(_staking.amount);
            _canWithdraw = _canWithdraw.add(_staking.amount);
        }
        return (_stakedAmount, _canWithdraw);
    }

    function earnedToken(uint256 _stakingId, address _account) public override view returns (uint256, uint256) {
        uint256 _canClaim = 0;
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        for (uint256 i = 0; i < stakes[_stakingId][_account].length; i++) {
            Staking storage _staking = stakes[_stakingId][_account][i];
            if (block.timestamp >= _staking.endstakeAt)
                _canClaim = _canClaim.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .mul(plan.apr)
                        .div(100)
                        .div(periodicTime)
                );
                _earned = _earned.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .mul(plan.apr)
                        .div(100)
                        .div(periodicTime)
                );
        }
        return (_earned, _canClaim);
    }

    function unstake(uint256 _stakingId, uint256 _amount) public override {
        uint256 _stakedAmount;
        uint256 _canWithdraw;
        Plan storage plan = plans[_stakingId];

        (_stakedAmount, _canWithdraw) = canWithdrawAmount(
            _stakingId,
            msg.sender
        );
        require(
            _canWithdraw >= _amount,
            "Withdraw Amount is not enough"
        );
        uint256 deductionAmount = _amount.mul(plans[_stakingId].withdrawDeduction).div(1000);
        uint256 tamount = _amount - deductionAmount;
        uint256 amount = _amount;
        uint256 _earned = 0;
        uint256 _penalty = 0;
        for (uint256 i = stakes[_stakingId][msg.sender].length; i > 0; i--) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i-1];
            
            if (amount >= _staking.amount) {
                
                if (block.timestamp >= _staking.endstakeAt) {
                    _earned = _earned.add(
                        _staking.amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .mul(plan.apr)
                            .div(100)
                            .div(periodicTime)
                    );
                } else {
                    _penalty = _penalty.add(
                        _staking.amount
                        .mul(plan.earlyPenalty)
                        .div(100)
                    );
                }

                amount = amount.sub(_staking.amount);
                _staking.amount = 0;
            } else {
                
                if (block.timestamp >= _staking.endstakeAt) {
                    _earned = _earned.add(
                        amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .mul(plan.apr)
                            .div(100)
                            .div(periodicTime)
                    );
                } else {
                    _penalty = _penalty.add(
                        amount
                        .mul(plan.earlyPenalty)
                        .div(100)
                    );
                }

                _staking.amount = _staking.amount.sub(amount);
                amount = 0;
                break;
            }
            _staking.stakeAt = block.timestamp;
        }

        if(deductionAmount > 0) {
            IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        }
        if(tamount > 0) {
            IERC20(stakingToken).transfer(msg.sender, tamount - _penalty);
        }
        if(_earned > 0) {
            IERC20(stakingToken).transfer(msg.sender, _earned);
        }
        plans[_stakingId].overallStaked = plans[_stakingId].overallStaked.sub(_amount);
    }

    function claimEarned(uint256 _stakingId) public override {
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        for (uint256 i = 0; i < stakes[_stakingId][msg.sender].length; i++) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            if (block.timestamp >= _staking.endstakeAt) {
                _earned = _earned.add(
                    _staking
                        .amount
                        .mul(plan.apr)
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .div(100)
                );
                _staking.stakeAt = block.timestamp;
            }
        }
        require(_earned > 0, "There is no amount to claim");
        IERC20(stakingToken).transfer(msg.sender, _earned);
    }

    function claimReferralEarnings() public {
        uint256 _earned = 0;
        uint256 _claimable = 0;
        (_earned, _claimable) = getReferralEarnings(msg.sender);
        require(_claimable > 0, "No amount to claim");
        claimLevelsReferralEarnings(msg.sender, 0);
        IERC20(stakingToken).transfer(msg.sender, _claimable);
    }

    function claimLevelsReferralEarnings(address _account, uint256 _level) internal {
        
        if(_level == referralLevels) {
            return;
        }

        address[] memory _referees = getReferees(_account);
        for(uint256 i = 0; i < _referees.length; i++) {
            address _referee = _referees[i];
            claimLevelsReferralEarnings(_referee, _level + 1);
            claimSingleLevelReferralEarnings(_account, _referee);
        }  
    }

    function claimSingleLevelReferralEarnings(address _referrer, address _referee) internal {
        for(uint256 j = 0; j < referrals[_referrer].referralStakes[_referee].length; j++) {
            if(!addressExists(msg.sender, referrals[_referrer].referralStakes[_referee][j].claimers)) {
                referrals[_referrer].referralStakes[_referee][j].claimers.push(msg.sender);
            }
        }
    }

    function getStakedPlans(address _account) public override view returns (bool[] memory) {
        bool[] memory walletPlans = new bool[](planLimit);
        for (uint256 i = 0; i < planLimit; i++) {
            walletPlans[i] = stakes[i][_account].length == 0 ? false : true;
        }
        return walletPlans;
    }

    function getTotalStakedAmount(address _account) public view returns(uint256){
        uint256 _totalStakedAmount = 0;
        for(uint256 i = 0; i < referralLevels; i++) {
            for(uint256 j = 0; j < stakes[i][_account].length; j++) {
                Staking storage _staking = stakes[i][_account][j];
                _totalStakedAmount = _totalStakedAmount.add(_staking.amount);
            }
        }
        return _totalStakedAmount;
    }

    function getReferees(address _account) public view returns (address[] memory) {
        return referrals[_account].referees;
    }

    function hasReferees(address _account) public view returns (bool flag) {
        return ( referrals[_account].referees.length>0?true:false);
    }

    function getReferralStakes(address _referrer, address _referee) public view returns (ReferralStake[] memory) {
        return referrals[_referrer].referralStakes[_referee];
    }

    function getReferralEarnings(address _account) public view returns(uint256, uint256) {
        return getLevelsReferralEarning(_account, _account, 0);         
    }

    function getLevelsReferralEarning(address _account, address _referrer, uint256 _level) public view returns(uint256, uint256) {
        uint256 _earned = 0;
        uint256 _claimable = 0;
        
        if(_level == referralLevels) {
            return (_earned, _claimable);
        }

        address[] memory _referees = getReferees(_referrer);
        for(uint256 i = 0; i < _referees.length; i++) {
            address _referee = _referees[i];
            uint256 _nexEarned;
            uint256 _nextClaimable;
            (_nexEarned, _nextClaimable) = getLevelsReferralEarning(_account, _referee, _level + 1);
            _earned = _earned.add(_nexEarned);
            _claimable = _claimable.add(_nextClaimable);
            
            (_nexEarned, _nextClaimable) = getSingleLevelReferralEarning(_account, _referrer, _referee, _level);
            _earned = _earned.add(_nexEarned);
            _claimable = _claimable.add(_nextClaimable);

        }
        return (_earned, _claimable);     
    }

    function getSingleLevelReferralEarning(address _account, address _referrer, address _referee, uint256 _level) public view returns (uint256, uint256) {
        ReferralStake[] memory _referralStakes = getReferralStakes(_referrer, _referee);
        uint256 _earned = 0;
        uint256 _claimable = 0;

        for(uint256 j = 0; j < _referralStakes.length; j++) {
            uint256 _referralValue = _referralStakes[j].stakedAmount
                    .mul(referralLevelEarnings[_level])
                    .div(100);
            
            if(!addressExists(_account, _referralStakes[j].claimers)) {
                _claimable = _claimable.add(_referralValue);
            }
            _earned = _earned.add(_referralValue);
        }
        return (_earned, _claimable);
    }

    function getReferralEarningsData(address _account) public view returns(
        address[] memory, 
        uint256[] memory, 
        ReferralStake[][] memory
    ) {
        return getLevelReferralEarningsData(_account, 0);         
    }

    function getLevelReferralEarningsData(address _referrer, uint256 _level) public view returns(
        address[] memory, 
        uint256[] memory,
        ReferralStake[][] memory
    ) {
        address[] memory _referees;
        uint256[] memory _levels;
        ReferralStake[][] memory _referralStakes;
         
        if(_level < referralLevels && _referrer != address(0)) {
            (_referees, _levels, _referralStakes) = getSingleLevelReferralEarningsData(_referrer, _level);
            address[] memory _nextReferees;
            uint256[] memory _nextLevels;
            ReferralStake[][] memory _nextReferralStakes;
            uint256 count = MAXRLIMIT <= _referees.length ? MAXRLIMIT : _referees.length;
            for(uint256 i = 0; i < count; i++) {
                (_nextReferees, _nextLevels, _nextReferralStakes) = getLevelReferralEarningsData(_referees[i], _level + 1);
                _referees = concatenateAddresses(_referees, _nextReferees);
                _levels = concatenateIntegers(_levels, _nextLevels);
                _referralStakes = concatenateReferralStakes(_referralStakes, _nextReferralStakes);   
            }
        }
        return (_referees, _levels, _referralStakes);    
    }

    function getSingleLevelReferralEarningsData(address _referrer, uint256 _level) public view returns(
        address[] memory, 
        uint256[] memory,
        ReferralStake[][] memory
    ) {      
        address[] memory _referees ;
        uint256[] memory _levels ;
        ReferralStake[][] memory _referralStakes;
        if(_referrer==address(0)||_level>=3)
        {
            return (_referees, _levels, _referralStakes);  
        }
        _referees = getReferees(_referrer);
        if(_referees.length!=0)
        {     
            _levels = new uint256[](_referees.length);
            _referralStakes = new ReferralStake[][](_referees.length);
            uint256 count = MAXRLIMIT <= _referees.length ? MAXRLIMIT : _referees.length;
            for(uint256 i = 0; i < count; i++) {
                _levels[i] = _level;
                _referralStakes[i] = referrals[_referrer].referralStakes[_referees[i]];
            }
        }
        return (_referees, _levels, _referralStakes);    
    }

    function concatenateAddresses(address[] memory a1, address[] memory a2) internal pure returns(address[] memory) {
        address[] memory returnArr = new address[](a1.length + a2.length);
        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }
        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }
        return returnArr;
    }

    function concatenateIntegers(uint256[] memory a1, uint256[] memory a2) internal pure returns(uint256[] memory) {
        uint256[] memory returnArr = new uint256[](a1.length + a2.length);
        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }
        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }
        return returnArr;
    }

    function concatenateReferralStakes(ReferralStake[][] memory a1, ReferralStake[][] memory a2) internal pure returns(ReferralStake[][] memory) {
        ReferralStake[][] memory returnArr = new ReferralStake[][](a1.length + a2.length);
        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }
        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }
        return returnArr;
    } 

    function addressExists(address add, address[] memory array) internal pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == add) {
                return true;
            }
        }
        return false;
    }

    receive() external payable {}

    function setAPR(uint256 _stakingId, uint256 _percent) external onlyOwner {
        plans[_stakingId].apr = _percent;
    }

    function setStakeDuration(uint256 _stakingId, uint256 _duration) external onlyOwner {
        plans[_stakingId].stakeDuration = _duration;
    }

    function setDepositDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].depositDeduction = _deduction;
    }

    function setWithdrawDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].withdrawDeduction = _deduction;
    }

    function setEarlyPenalty(uint256 _stakingId, uint256 _penalty) external onlyOwner {
        plans[_stakingId].earlyPenalty = _penalty;
    }

    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }

    function setReferralLevelEarnings(uint256 _level, uint256 _earning) external onlyOwner {
        referralLevelEarnings[_level] = _earning;
    }

    function setMinTokenForReferral(uint256 _minTokenForReferral) external onlyOwner {
        minTokenForReferral = _minTokenForReferral;
    }

    function removeStuckToken() external onlyOwner {
        IERC20(stakingToken).transfer(owner(), IERC20(stakingToken).balanceOf(address(this)));
    }

    function recoverETH() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No ETH available");       
        payable(msg.sender).transfer(amount);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner{
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
    }    
}