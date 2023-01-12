/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
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

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

interface IUniRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniRouter02 is IUniRouter01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

interface IToken {
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
}

contract INTStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public POOL_FACTORY;

    bool public isInitialized;
    uint256 public duration = 365; // 365 days

    uint256 public startBlock;
    uint256 public bonusEndBlock;


    uint256 public slippageFactor = 950; 
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address[] public BTCreflectionToStakedPath = [0x8BaBbB98678facC7342735486C851ABD7A0d17Ca,0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd,0x72B94D9eE3b0e4FF9E94c2474eb600d778072028];
    address[] public SFMreflectionToStakedPath = [0x8a9424745056Eb399FD19a0EC26A14316684e274,0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd,0x72B94D9eE3b0e4FF9E94c2474eb600d778072028];
    address[] public GRVreflectionToStakedPath = [0xDAcbdeCc2992a63390d108e8507B98c7E2B5584a,0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd,0x72B94D9eE3b0e4FF9E94c2474eb600d778072028];
    address[] public earnedToStakedPath;

    address public walletA;

    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_BTCREFLECTION;
    uint256 public PRECISION_FACTOR_SFMREFLECTION;
    uint256 public PRECISION_FACTOR_GRVREFLECTION;

    IERC20 public stakingToken = IERC20(0x72B94D9eE3b0e4FF9E94c2474eb600d778072028);
    IERC20 public earnedToken = IERC20(0x72B94D9eE3b0e4FF9E94c2474eb600d778072028);
    IERC20 public BTCdividendToken = IERC20(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);
    IERC20 public SFMdividendToken = IERC20(0x8a9424745056Eb399FD19a0EC26A14316684e274);
    IERC20 public GRVdividendToken = IERC20(0xDAcbdeCc2992a63390d108e8507B98c7E2B5584a);

    uint256 public accBTCDividendPerShare;
    uint256 public accSFMDividendPerShare;
    uint256 public accGRVDividendPerShare;

    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalBTCReflections;
    uint256 private totalSFMReflections;
    uint256 private totalGRVReflections;
    uint256 private BTCreflectionDebt;
    uint256 private SFMreflectionDebt;
    uint256 private GRVreflectionDebt;

    struct Lockup {
        uint8 stakeType;
        uint256 duration;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 rate;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 totalStaked;
    }

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 locked;
        uint256 available;
    }

    struct Stake {
        uint8   stakeType;
        uint256 amount;    
        uint256 duration;   
        uint256 end;        
        uint256 rewardDebt; 
        uint256 BTCreflectionDebt;
        uint256 SFMreflectionDebt; 
        uint256 GRVreflectionDebt; 
    }
    uint256 constant MAX_STAKES = 256;

    Lockup[] public lockups;
    mapping(address => Stake[]) public userStakes;
    mapping(address => UserInfo) public userStaked;

    event Deposit(address indexed user, uint256 stakeType, uint256 amount);
    event Withdraw(address indexed user, uint256 stakeType, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event LockupUpdated(uint8 _type, uint256 _duration, uint256 _fee0, uint256 _fee1, uint256 _rate);
    event RewardsStop(uint256 blockNumber);


    constructor() {
        POOL_FACTORY = msg.sender;
    }

    function initialize() external {
        require(!isInitialized, "Ai");
        require(msg.sender == POOL_FACTORY, "Nf");

        // Make this contract initialized
        isInitialized = true;


        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "30");
        PRECISION_FACTOR = uint256(10**(uint256(40).sub(decimalsRewardToken)));

        uint256 decimalsBTCdividendToken = 18;
        if(address(BTCdividendToken) != address(0x0)) {
            decimalsBTCdividendToken = uint256(IToken(address(BTCdividendToken)).decimals());
            require(decimalsBTCdividendToken < 30, "30");
        }
        PRECISION_FACTOR_BTCREFLECTION = uint256(10**(uint256(40).sub(decimalsBTCdividendToken)));

        uint256 decimalsSFMdividendToken = 18;
        if(address(SFMdividendToken) != address(0x0)) {
            decimalsSFMdividendToken = uint256(IToken(address(SFMdividendToken)).decimals());
            require(decimalsSFMdividendToken < 30, "0");
        }
        PRECISION_FACTOR_SFMREFLECTION = uint256(10**(uint256(40).sub(decimalsSFMdividendToken)));

        uint256 decimalsGRVdividendToken = 18;
        if(address(GRVdividendToken) != address(0x0)) {
            decimalsGRVdividendToken = uint256(IToken(address(GRVdividendToken)).decimals());
            require(decimalsGRVdividendToken < 30, "30");
        }
        PRECISION_FACTOR_GRVREFLECTION = uint256(10**(uint256(40).sub(decimalsGRVdividendToken)));

        
        lockups.push(Lockup(0, 30, 0, 200, 951293759, 0, 0, 0)); // 1% liquidity
        lockups.push(Lockup(1, 90, 0, 100, 1426940638, 0, 0, 0)); // 1.5% liquidity
        lockups.push(Lockup(2, 180, 0, 0, 1902587518, 0, 0, 0)); // 2% liquidity

        _resetAllowances();
    }

    function deposit(uint256 _amount, uint8 _stakeType) external nonReentrant {
        require(_amount > 0, "0");
        require(_stakeType < lockups.length, "");

        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending;
        uint256 pendingCompound;
        uint256 pendingBTCReflection;
        uint256 pendingSFMReflection;
        uint256 pendingGRVReflection;
        uint256 compounded;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingBTCReflection = pendingBTCReflection.add(
                stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(stake.BTCreflectionDebt)
            );

            pendingSFMReflection = pendingSFMReflection.add(
                stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(stake.SFMreflectionDebt)
            );

            pendingGRVReflection = pendingGRVReflection.add(
                stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(stake.GRVreflectionDebt)
            );

            uint256 _pending = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR).sub(stake.rewardDebt);
            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound.add(_pending);

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(_pending, earnedToStakedPath, address(this));
                    uint256 _afterAmount = stakingToken.balanceOf(address(this));
                    _pending = _afterAmount.sub(_beforeAmount);
                }
                compounded = compounded.add(_pending);
                stake.amount = stake.amount.add(_pending);
            } else {
                pending = pending.add(_pending);
            }
            stake.rewardDebt = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR);
            stake.BTCreflectionDebt = stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION);
            stake.SFMreflectionDebt = stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION);
            stake.GRVreflectionDebt = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION);
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Ins");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "IT");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned.sub(pendingCompound);
            } else {
                totalEarned;
            }
        }

        if (pendingBTCReflection > 0) {
            if(address(BTCdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingBTCReflection);
            } else {
                BTCdividendToken.safeTransfer(address(msg.sender), pendingBTCReflection);
            }
            totalBTCReflections = totalBTCReflections.sub(pendingBTCReflection);
        }

        if (pendingSFMReflection > 0) {
            if(address(SFMdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingSFMReflection);
            } else {
                SFMdividendToken.safeTransfer(address(msg.sender), pendingSFMReflection);
            }
            totalSFMReflections = totalSFMReflections.sub(pendingSFMReflection);
        }

        if (pendingGRVReflection > 0) {
            if(address(GRVdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingGRVReflection);
            } else {
                GRVdividendToken.safeTransfer(address(msg.sender), pendingGRVReflection);
            }
            totalGRVReflections = totalGRVReflections.sub(pendingGRVReflection);
        }


        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount.sub(beforeAmount);


        if (lockup.depositFee > 0) {
            uint256 fee = realAmount.mul(lockup.depositFee).div(10000);
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount.sub(fee);
            }
        }
        
        _addStake(_stakeType, msg.sender, lockup.duration, realAmount);

        user.amount = user.amount.add(realAmount).add(compounded);
        lockup.totalStaked = lockup.totalStaked.add(realAmount).add(compounded);
        totalStaked = totalStaked.add(realAmount).add(compounded);

        emit Deposit(msg.sender, _stakeType, realAmount.add(compounded));
    }

    function _addStake(uint8 _stakeType, address _account, uint256 _duration, uint256 _amount) internal {
        Stake[] storage stakes = userStakes[_account];

        uint256 end = block.timestamp.add(_duration.mul(1 days));
        uint256 i = stakes.length;
        require(i < MAX_STAKES, "Max ");

        stakes.push(); 
        while (i != 0 && stakes[i - 1].end > end) {
            stakes[i] = stakes[i - 1];
            i -= 1;
        }
        
        Lockup storage lockup = lockups[_stakeType];

        // insert the stake
        Stake storage newStake = stakes[i];
        newStake.stakeType = _stakeType;
        newStake.duration = _duration;
        newStake.end = end;
        newStake.amount = _amount;
        newStake.rewardDebt = newStake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR);
        newStake.BTCreflectionDebt = newStake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION);
        newStake.SFMreflectionDebt = newStake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION);
        newStake.GRVreflectionDebt = newStake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION);
    }

    function withdraw(uint256 _amount, uint8 _stakeType) external nonReentrant {
        require(_amount > 0, " 0");
        require(_stakeType < lockups.length, "Ie");

        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];
        
        uint256 pending;
        uint256 pendingCompound;
        uint256 pendingBTCReflection;
        uint256 pendingSFMReflection;
        uint256 pendingGRVReflection;
        uint256 compounded;
        uint256 remained = _amount;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            if(remained == 0) break;

            uint256 _pending = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR).sub(stake.rewardDebt);

            uint256 _pendingBTCReflection = stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(stake.BTCreflectionDebt);
            pendingBTCReflection = pendingBTCReflection.add(_pendingBTCReflection);

            uint256 _pendingSFMReflection = stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(stake.SFMreflectionDebt);
            pendingSFMReflection = pendingSFMReflection.add(_pendingSFMReflection);

            uint256 _pendingGRVReflection = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(stake.GRVreflectionDebt);
            pendingGRVReflection = pendingGRVReflection.add(_pendingGRVReflection);

            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound.add(_pending);

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(_pending, earnedToStakedPath, address(this));
                    uint256 _afterAmount = stakingToken.balanceOf(address(this));
                    _pending = _afterAmount.sub(_beforeAmount);
                }
                compounded = compounded.add(_pending);
                stake.amount = stake.amount.add(_pending);
            } else {
                pending = pending.add(_pending);
                if(stake.amount > remained) {
                    stake.amount = stake.amount.sub(remained);
                    remained;
                } else {
                    remained = remained.sub(stake.amount);
                    stake.amount;
                }
            }
            stake.rewardDebt = stake.amount.mul(lockup.accTokenPerShare);
            stake.rewardDebt = stake.rewardDebt.div(PRECISION_FACTOR);

            stake.BTCreflectionDebt = stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION);
            stake.SFMreflectionDebt = stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION);
            stake.GRVreflectionDebt = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION);
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "s");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned.sub(pendingCompound);
            } else {
                totalEarned;
            }
            
            emit Deposit(msg.sender, _stakeType, compounded);
        }

        if (pendingBTCReflection > 0) {
            if(address(BTCdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingBTCReflection);
            } else {
                BTCdividendToken.safeTransfer(address(msg.sender), pendingBTCReflection);
            }
            totalBTCReflections = totalBTCReflections.sub(pendingBTCReflection);
        }

        if (pendingSFMReflection > 0) {
            if(address(SFMdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingSFMReflection);
            } else {
                SFMdividendToken.safeTransfer(address(msg.sender), pendingSFMReflection);
            }
            totalSFMReflections = totalSFMReflections.sub(pendingSFMReflection);
        }

        if (pendingGRVReflection > 0) {
            if(address(GRVdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingGRVReflection);
            } else {
                GRVdividendToken.safeTransfer(address(msg.sender), pendingGRVReflection);
            }
            totalGRVReflections = totalGRVReflections.sub(pendingGRVReflection);
        }

        uint256 realAmount = _amount.sub(remained);
        user.amount = user.amount.sub(realAmount).add(pendingCompound);
        lockup.totalStaked = lockup.totalStaked.sub(realAmount).add(pendingCompound);
        totalStaked = totalStaked.sub(realAmount).add(pendingCompound);

        if(realAmount > 0) {
            if (lockup.withdrawFee > 0) {
                uint256 fee = realAmount.mul(lockup.withdrawFee).div(10000);
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount.sub(fee);
            }

            stakingToken.safeTransfer(address(msg.sender), realAmount);
        }

        emit Withdraw(msg.sender, _stakeType, realAmount);
    }

    function claimReward(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending;
        uint256 pendingCompound;
        uint256 compounded;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR).sub(stake.rewardDebt);

            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound.add(_pending);

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(_pending, earnedToStakedPath, address(this));
                    uint256 _afterAmount = stakingToken.balanceOf(address(this));
                    _pending = _afterAmount.sub(_beforeAmount);
                }
                compounded = compounded.add(_pending);
                stake.amount = stake.amount.add(_pending);

                stake.BTCreflectionDebt = stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(
                    (stake.amount.sub(_pending)).mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(stake.BTCreflectionDebt)
                );

                stake.SFMreflectionDebt = stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(
                    (stake.amount.sub(_pending)).mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(stake.SFMreflectionDebt)
                );

                stake.GRVreflectionDebt = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(
                    (stake.amount.sub(_pending)).mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(stake.GRVreflectionDebt)
                );

            } else {
                pending = pending.add(_pending);
            }
            stake.rewardDebt = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR);
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "ns");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Is");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned.sub(pendingCompound);
            } else {
                totalEarned;
            }

            user.amount = user.amount.add(compounded);
            lockup.totalStaked = lockup.totalStaked.add(compounded);
            totalStaked = totalStaked.add(compounded);

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function claimBTCDividend(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pendingBTCReflection;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pendingBTCReflection = stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(stake.BTCreflectionDebt);
            pendingBTCReflection = pendingBTCReflection.add(_pendingBTCReflection);

            stake.BTCreflectionDebt = stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION);
        }

        if (pendingBTCReflection > 0) {
            if(address(BTCdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingBTCReflection);
            } else {
                BTCdividendToken.safeTransfer(address(msg.sender), pendingBTCReflection);
            }
            totalBTCReflections = totalBTCReflections.sub(pendingBTCReflection);
        }
    }

    function claimSFMDividend(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pendingSFMReflection;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pendingSFMReflection = stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(stake.SFMreflectionDebt);
            pendingSFMReflection = pendingSFMReflection.add(_pendingSFMReflection);

            stake.SFMreflectionDebt = stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION);
        }

        if (pendingSFMReflection > 0) {
            if(address(SFMdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingSFMReflection);
            } else {
                SFMdividendToken.safeTransfer(address(msg.sender), pendingSFMReflection);
            }
            totalSFMReflections = totalSFMReflections.sub(pendingSFMReflection);
        }
    }

    function claimGRVDividend(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pendingGRVReflection;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pendingGRVReflection = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(stake.GRVreflectionDebt);
            pendingGRVReflection = pendingGRVReflection.add(_pendingGRVReflection);

            stake.GRVreflectionDebt = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION);
        }

        if (pendingGRVReflection > 0) {
            if(address(GRVdividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingGRVReflection);
            } else {
                GRVdividendToken.safeTransfer(address(msg.sender), pendingGRVReflection);
            }
            totalGRVReflections = totalGRVReflections.sub(pendingGRVReflection);
        }
    }

    function compoundReward(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending;
        uint256 pendingCompound;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR).sub(stake.rewardDebt);
            pending = pending.add(_pending);

            if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, earnedToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));
                _pending = _afterAmount.sub(_beforeAmount);
            }
            pendingCompound = pendingCompound.add(_pending);

            stake.amount = stake.amount.add(_pending);
            stake.rewardDebt = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR);

            stake.BTCreflectionDebt = stake.amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(
                (stake.amount.sub(_pending)).mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(stake.BTCreflectionDebt)
            );

            stake.SFMreflectionDebt = stake.amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(
                (stake.amount.sub(_pending)).mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(stake.SFMreflectionDebt)
            );

            stake.GRVreflectionDebt = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(
                (stake.amount.sub(_pending)).mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(stake.GRVreflectionDebt)
            );
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "I");
            
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned;
            }

            user.amount = user.amount.add(pendingCompound);
            lockup.totalStaked = lockup.totalStaked.add(pendingCompound);
            totalStaked = totalStaked.add(pendingCompound);

            emit Deposit(msg.sender, _stakeType, pendingCompound);
        }
    }

   

    function compoundGRVDividend(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pendingGRVReflection;
        uint256 pendingGRVCompound;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pendingGRV = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(stake.GRVreflectionDebt);
            pendingGRVReflection = pendingGRVReflection.add(_pendingGRV);

            if(address(stakingToken) != address(GRVdividendToken) && _pendingGRV > 0) {
                if(address(GRVdividendToken) == address(0x0)) {
                    address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                    IWETH(wethAddress).deposit{ value: _pendingGRV }();
                }

                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pendingGRV, GRVreflectionToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));

                _pendingGRV = _afterAmount.sub(_beforeAmount);
            }
            
            pendingGRVCompound = pendingGRVCompound.add(_pendingGRV);
            stake.amount = stake.amount.add(_pendingGRV);
            stake.rewardDebt = stake.amount.mul(lockup.accTokenPerShare).div(PRECISION_FACTOR).sub(
                (stake.amount.sub(_pendingGRV)).mul(lockup.accTokenPerShare).div(PRECISION_FACTOR).sub(stake.rewardDebt)
            );
            stake.GRVreflectionDebt = stake.amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION);
        }

        totalGRVReflections = totalGRVReflections.sub(pendingGRVReflection);
        if (pendingGRVReflection > 0) {
            user.amount = user.amount.add(pendingGRVCompound);
            lockup.totalStaked = lockup.totalStaked.add(pendingGRVCompound);
            totalStaked = totalStaked.add(pendingGRVCompound);

            emit Deposit(msg.sender, _stakeType, pendingGRVCompound);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 amountToTransfer;
        for(uint256 j; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            amountToTransfer = amountToTransfer.add(stake.amount);

            stake.amount;
            stake.rewardDebt;
            stake.BTCreflectionDebt;
            stake.SFMreflectionDebt;
            stake.GRVreflectionDebt;

        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

            user.amount = user.amount.sub(amountToTransfer);
            lockup.totalStaked = lockup.totalStaked.sub(amountToTransfer);
            totalStaked = totalStaked.sub(amountToTransfer);
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function rewardPerBlock(uint8 _stakeType) public view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;

        return lockups[_stakeType].rate;
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount.sub(totalStaked);
        }

        return _amount;
    }

    function availableBTCdividendTokens() public view returns (uint256) {
        if(address(BTCdividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = BTCdividendToken.balanceOf(address(this));
        
        if(address(BTCdividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount.sub(totalEarned);
        }

        if(address(BTCdividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount.sub(totalStaked);
        }

        return _amount;
    }

    
    /**
     * @notice Available amount of SFM reflection token
     */
    function availableSFMdividendTokens() public view returns (uint256) {
        if(address(SFMdividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = SFMdividendToken.balanceOf(address(this));
        
        if(address(SFMdividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount.sub(totalEarned);
        }

        if(address(SFMdividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount.sub(totalStaked);
        }

        return _amount;
    }

    
    function availableGRVdividendTokens() public view returns (uint256) {
        if(address(GRVdividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = GRVdividendToken.balanceOf(address(this));
        
        if(address(GRVdividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount.sub(totalEarned);
        }

        if(address(GRVdividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount.sub(totalStaked);
        }

        return _amount;
    }

    function userInfo(uint8 _stakeType, address _account) public view returns (uint256 amount, uint256 available, uint256 locked) {
        Stake[] storage stakes = userStakes[_account];
        
        for(uint256 i; i < stakes.length; i++) {
            Stake storage stake = stakes[i];

            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            
            amount = amount.add(stake.amount);
            if(block.timestamp > stake.end) {
                available = available.add(stake.amount);
            } else {
                locked = locked.add(stake.amount);
            }
        }
    }

    
    function pendingReward(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;
        if(startBlock == 0) return 0;

        Stake[] storage stakes = userStakes[_account];
        Lockup storage lockup = lockups[_stakeType];

        if(lockup.totalStaked == 0) return 0;
        
        uint256 adjustedTokenPerShare = lockup.accTokenPerShare;
        if (block.number > lockup.lastRewardBlock && lockup.totalStaked != 0) {
            uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
            uint256 reward = multiplier.mul(lockup.rate);
            adjustedTokenPerShare =
                lockup.accTokenPerShare.add(
                    reward.mul(PRECISION_FACTOR).div(lockup.totalStaked)
                );
        }

        uint256 pending;
        for(uint256 i; i < stakes.length; i++) {
            Stake storage stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pending = pending.add(
                stake.amount.mul(adjustedTokenPerShare).div(PRECISION_FACTOR).sub(stake.rewardDebt)
            );
        }
        return pending;
    }

    function pendingBTCDividends(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;
        if(startBlock == 0) return 0;

        Stake[] storage stakes = userStakes[_account];
        
        if(totalStaked == 0) return 0;
        
        
        uint256 BTCreflectionAmount = availableBTCdividendTokens();
        uint256 sTokenBal = stakingToken.balanceOf(address(this));

        uint256 adjustedBTCReflectionPerShare = accBTCDividendPerShare.add(
                BTCreflectionAmount.sub(totalBTCReflections).mul(PRECISION_FACTOR_BTCREFLECTION).div(sTokenBal)
            );
        
        uint256 pendingBTCReflection;
        for(uint256 i; i < stakes.length; i++) {
            Stake storage stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingBTCReflection = pendingBTCReflection.add(
                stake.amount.mul(adjustedBTCReflectionPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(
                    stake.BTCreflectionDebt
                )
            );
        }
        return pendingBTCReflection;
    }

    function pendingSFMDividends(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;
        if(startBlock == 0) return 0;

        Stake[] storage stakes = userStakes[_account];
        
        if(totalStaked == 0) return 0;
        
        
        uint256 SFMreflectionAmount = availableSFMdividendTokens();
        uint256 sTokenBal = stakingToken.balanceOf(address(this));

        uint256 adjustedSFMReflectionPerShare = accSFMDividendPerShare.add(
                SFMreflectionAmount.sub(totalSFMReflections).mul(PRECISION_FACTOR_SFMREFLECTION).div(sTokenBal)
            );
        
        uint256 pendingSFMReflection;
        for(uint256 i; i < stakes.length; i++) {
            Stake storage stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingSFMReflection = pendingSFMReflection.add(
                stake.amount.mul(adjustedSFMReflectionPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(
                    stake.SFMreflectionDebt
                )
            );
        }
        return pendingSFMReflection;
    }

    function pendingGRVDividends(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;
        if(startBlock == 0) return 0;

        Stake[] storage stakes = userStakes[_account];
        
        if(totalStaked == 0) return 0;
        
        
        uint256 GRVreflectionAmount = availableGRVdividendTokens();
        uint256 sTokenBal = stakingToken.balanceOf(address(this));

        uint256 adjustedGRVReflectionPerShare = accGRVDividendPerShare.add(
                GRVreflectionAmount.sub(totalGRVReflections).mul(PRECISION_FACTOR_GRVREFLECTION).div(sTokenBal)
            );
        
        uint256 pendingGRVReflection;
        for(uint256 i; i < stakes.length; i++) {
            Stake storage stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingGRVReflection = pendingGRVReflection.add(
                stake.amount.mul(adjustedGRVReflectionPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(
                    stake.GRVreflectionDebt
                )
            );
        }
        return pendingGRVReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {        
        _updatePool(0);

        uint256 _amount = stakingToken.balanceOf(address(this));
        _amount = _amount.sub(totalStaked);

        uint256 pendingBTCReflection = _amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION).sub(BTCreflectionDebt);
        if(pendingBTCReflection > 0) {
            if(address(BTCdividendToken) == address(0x0)) {
                payable(walletA).transfer(pendingBTCReflection);
            } else {
                BTCdividendToken.safeTransfer( walletA, pendingBTCReflection);
            }
            totalBTCReflections = totalBTCReflections.sub(pendingBTCReflection);
        }
        
        BTCreflectionDebt = _amount.mul(accBTCDividendPerShare).div(PRECISION_FACTOR_BTCREFLECTION);

        uint256 pendingSFMReflection = _amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION).sub(SFMreflectionDebt);
        if(pendingSFMReflection > 0) {
            if(address(SFMdividendToken) == address(0x0)) {
                payable(walletA).transfer(pendingSFMReflection);
            } else {
                SFMdividendToken.safeTransfer( walletA, pendingSFMReflection);
            }
            totalSFMReflections = totalSFMReflections.sub(pendingSFMReflection);
        }
        
        SFMreflectionDebt = _amount.mul(accSFMDividendPerShare).div(PRECISION_FACTOR_SFMREFLECTION);

        uint256 pendingGRVReflection = _amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION).sub(GRVreflectionDebt);
        if(pendingGRVReflection > 0) {
            if(address(GRVdividendToken) == address(0x0)) {
                payable(walletA).transfer(pendingGRVReflection);
            } else {
                GRVdividendToken.safeTransfer( walletA, pendingGRVReflection);
            }
            totalGRVReflections = totalGRVReflections.sub(pendingGRVReflection);
        }
        
        GRVreflectionDebt = _amount.mul(accGRVDividendPerShare).div(PRECISION_FACTOR_GRVREFLECTION);
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external nonReentrant {
        require(_amount > 0);

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned.add(afterAmt).sub(beforeAmt);
    }

   
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "P");

        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned;
            } else {
                totalEarned = totalEarned.sub(_amount);
            }
        }
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(earnedToken),
            "R"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal.sub(totalStaked), "IB");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "S");

        startBlock = block.number.add(100);
        bonusEndBlock = startBlock.add(duration * 28800);
        for(uint256 i; i < lockups.length; i++) {
            lockups[i].lastRewardBlock = startBlock;
        }
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
    }

    function updateLockup(uint8 _stakeType, uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {
 
        require(_stakeType < lockups.length, "LNF");
        require(_depositFee < 2000, "IDF");
        require(_withdrawFee < 2000, "IWF");

        Lockup storage _lockup = lockups[_stakeType];
        _lockup.duration = _duration;
        _lockup.depositFee = _depositFee;
        _lockup.withdrawFee = _withdrawFee;
        _lockup.rate = _rate;
        
        emit LockupUpdated(_stakeType, _duration, _depositFee, _withdrawFee, _rate);
    }

    function resetAllowances() external onlyOwner {
        _resetAllowances();
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool(uint8 _stakeType) internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 BTCreflectionAmount = availableBTCdividendTokens();
            uint256 SFMreflectionAmount = availableSFMdividendTokens();
            uint256 GRVreflectionAmount = availableGRVdividendTokens();

            uint256 sTokenBal = stakingToken.balanceOf(address(this));

            accBTCDividendPerShare = accBTCDividendPerShare.add(
                    BTCreflectionAmount.sub(totalBTCReflections).mul(PRECISION_FACTOR_BTCREFLECTION).div(sTokenBal)
                );

            accSFMDividendPerShare = accSFMDividendPerShare.add(
                    SFMreflectionAmount.sub(totalSFMReflections).mul(PRECISION_FACTOR_SFMREFLECTION).div(sTokenBal)
                );

           accGRVDividendPerShare = accGRVDividendPerShare.add(
                    GRVreflectionAmount.sub(totalGRVReflections).mul(PRECISION_FACTOR_GRVREFLECTION).div(sTokenBal)
                );

            totalBTCReflections = BTCreflectionAmount;
            totalSFMReflections = SFMreflectionAmount;
            totalGRVReflections = GRVreflectionAmount;
        }

        Lockup storage lockup = lockups[_stakeType];
        if (block.number <= lockup.lastRewardBlock) return;

        if (lockup.totalStaked == 0) {
            lockup.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
        uint256 _reward = multiplier.mul(lockup.rate);
        lockup.accTokenPerShare = lockup.accTokenPerShare.add(
            _reward.mul(PRECISION_FACTOR).div(lockup.totalStaked)
        );
        lockup.lastRewardBlock = block.number;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniRouter02(uniRouterAddress).swapExactTokensForTokens(
            _amountIn,
            amountOut.mul(slippageFactor).div(1000),
            _path,
            _to,
            block.timestamp.add(600)
        );
    }

    function _resetAllowances() internal {
        earnedToken.safeApprove(uniRouterAddress, uint256(0));
        earnedToken.safeIncreaseAllowance(
            uniRouterAddress,
            type(uint256).max
        );

        if(address(BTCdividendToken) == address(0x0)) {
            address wethAddress = IUniRouter02(uniRouterAddress).WETH();
            IERC20(wethAddress).safeApprove(uniRouterAddress, uint256(0));
            IERC20(wethAddress).safeIncreaseAllowance(
                uniRouterAddress,
                type(uint256).max
            );
        } else {
            BTCdividendToken.safeApprove(uniRouterAddress, uint256(0));
            SFMdividendToken.safeApprove(uniRouterAddress, uint256(0));
            GRVdividendToken.safeApprove(uniRouterAddress, uint256(0));

            BTCdividendToken.safeIncreaseAllowance(
                uniRouterAddress,
                type(uint256).max
            );

            SFMdividendToken.safeIncreaseAllowance(
                uniRouterAddress,
                type(uint256).max
            );

            GRVdividendToken.safeIncreaseAllowance(
                uniRouterAddress,
                type(uint256).max
            );
        }        
    }

    receive() external payable {}
}