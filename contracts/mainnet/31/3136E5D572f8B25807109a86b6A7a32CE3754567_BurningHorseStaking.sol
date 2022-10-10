/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT


//   ____                   _             _    _                      _____ _        _    _             
//  |  _ \                 (_)           | |  | |                    / ____| |      | |  (_)            
//  | |_) |_   _ _ __ _ __  _ _ __   __ _| |__| | ___  _ __ ___  ___| (___ | |_ __ _| | ___ _ __   __ _ 
//  |  _ <| | | | '__| '_ \| | '_ \ / _` |  __  |/ _ \| '__/ __|/ _ \\___ \| __/ _` | |/ / | '_ \ / _` |
//  | |_) | |_| | |  | | | | | | | | (_| | |  | | (_) | |  \__ \  __/____) | || (_| |   <| | | | | (_| |
//  |____/ \__,_|_|  |_| |_|_|_| |_|\__, |_|  |_|\___/|_|  |___/\___|_____/ \__\__,_|_|\_\_|_| |_|\__, |
//                                   __/ |                                                         __/ |
//                                  |___/                                                         |___/ 


// File: ReentrancyGuard.sol


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
// File: Address.sol


// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

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
// File: IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

    function burn(address account, uint256 amount) external returns(bool);

    function lotteryTransfer(address recipient, uint256 amount) external returns (bool);

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
// File: SafeERC20.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

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
// File: IBurningHorse.sol


// BurningHorse Token Interface                                        //place for social etc

pragma solidity ^0.8.0;

interface IBurningHorse {

    function balanceOf(address account) external view returns (uint256);
    
    function burn(uint256 amount) external returns(bool);

    function mint(address account, uint256 amount) external;

    function lotteryTransfer(address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function viewBurningPercentage() external returns (uint256);

    function decimals() external returns(uint8);

    function viewUserBurned(address _address) external view returns(uint256);

}
// File: Ownable.sol


pragma solidity ^0.8.4;

/**
* @notice Contract is a inheritable smart contract that will add a 
* New modifier called onlyOwner available in the smart contract inherting it
* 
* onlyOwner makes a function only callable from the Token owner
*
*/
contract Ownable {
    // _owner is the owner of the Token
    address private _owner;

    /**
    * Event OwnershipTransferred is used to log that a ownership change of the token has occured
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * Modifier
    * We create our own function modifier called onlyOwner, it will Require the current owner to be 
    * the same as msg.sender
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }



}
// File: PausableStaking.sol


pragma solidity ^0.8.4;



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract PausableStaking is Ownable {

mapping(uint256 => bool) public pausedPlan;

  function pause1() onlyOwner public {
    pausedPlan[74] = true;

  }

  function unpause1() onlyOwner public {
    pausedPlan[74] = false;

  }

  function pause2() onlyOwner public {
    pausedPlan[94] = true;

  }

  function unpause2() onlyOwner public {
    pausedPlan[94] = false;

  }

  function pause3() onlyOwner public {
    pausedPlan[114] = true;
  }

  function unpause3() onlyOwner public {
    pausedPlan[114] = false;
  }

  function pause4() onlyOwner public {
    pausedPlan[134] = true;
  }

  function unpause4() onlyOwner public {
    pausedPlan[134] = false;
  }

  function pause5() onlyOwner public {
    pausedPlan[174] = true;
  }

  function unpause5() onlyOwner public {
    pausedPlan[174] = false;
  }

  function pause6() onlyOwner public {
    pausedPlan[344] = true;
  }

  function unpause6() onlyOwner public {
    pausedPlan[344] = false;
  }

  function viewPausedStakings() public view returns(bool staking1, bool staking2, bool staking3, bool staking4, bool staking5, bool staking6){
      return(pausedPlan[74], pausedPlan[94], pausedPlan[114], pausedPlan[134], pausedPlan[174], pausedPlan[344]);
  }

}
// File: Pausable.sol


pragma solidity ^0.8.4;



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}
// File: SafeMath.sol



pragma solidity ^0.8.4;

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
// File: MainStakingNew.sol


pragma solidity ^0.8.13;










contract BurningHorseStaking is Ownable, Pausable, PausableStaking, ReentrancyGuard{

    using SafeMath for uint;
    using SafeERC20 for IBurningHorse;
    using SafeERC20 for IERC20;

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
    
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    uint256 public maxQuota;
    uint256 public maxUserQuota;
    uint256 public timeRange;
    uint256 public totalStaked;
    uint[] plansNumber = [74,94,114,134,174,344];
    mapping(address => uint256) userStaked;


    /**
     * @notice
      rewardPerDay is like this because it is used to represent %, since we only use integer numbers
      This will give users reward for each staked token / Day APY
      rewardPerDay = 1 / (1 * APY/100 / 365);
     */

    mapping(uint256 => uint256) public rewardPerDay;
    mapping(uint256 => uint256) public lockTime;


    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders[74].push();
        stakeholders[94].push();
        stakeholders[114].push();
        stakeholders[134].push();
        stakeholders[174].push();
        stakeholders[344].push();
        timeRange = 731;    //731 = 2years + 1d
        maxQuota = 226000000 * 1e8;
        maxUserQuota = 500000 * 1e8;

        rewardPerDay[74] = 4933;
        rewardPerDay[94] = 3883;
        rewardPerDay[114] = 3202;
        rewardPerDay[134] = 2724;
        rewardPerDay[174] = 2098;
        rewardPerDay[344] = 1061;

        lockTime[74] = 0;
        lockTime[94] = 30;
        lockTime[114] = 90;
        lockTime[134] = 180;
        lockTime[174] = 365;
        lockTime[344] = 730;       

    }
    /**
     * @notice
     * A stake struct is used to represent the way we store stakes, 
     * A Stake will contain the users address, the amount staked and a timestamp, 
     * Since which is when the stake was made
     */
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }


    /**
    * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder{
        address user;
        Stake[] address_stakes;
    }

     /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */ 
    struct StakingSummary{
        uint256 total_amount;
        Stake[] stakes;
    }

    struct StakingSummary94{
        uint256 total_amount94;
        Stake[] stakes94;
    }

    struct StakingSummary114{
        uint256 total_amount114;
        Stake[] stakes114;
    }

    struct StakingSummary134{
        uint256 total_amount134;
        Stake[] stakes134;
    }

    struct StakingSummary174{
        uint256 total_amount174;
        Stake[] stakes174;
    }

    struct StakingSummary344{
        uint256 total_amount344;
        Stake[] stakes344;
    }


    /**
    * @notice 
    *   This is a array where we store all Stakes that are performed on the Contract
    *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
    */

    mapping(uint256 => Stakeholder[]) stakeholders;

    /**
    * @notice 
    * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */

    mapping(uint256 => mapping(address => uint256)) internal stakes;

    // if i stake alone so i should put number inside first bracket and address inside second

    address brhsToken = 0x68FD3bDaf70bd14828bab06d5BF854349d1F4aE6;
    IBurningHorse token = IBurningHorse(brhsToken);

    /**
    * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(address indexed user, uint256 stakingPlan, uint256 amount, uint256 index, uint256 timestamp);
          


    /**
    * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker, uint256 stakePlan) internal returns (uint256){
        stakeholders[stakePlan].push();
        uint256 userIndex = stakeholders[stakePlan].length - 1;
        stakeholders[stakePlan][userIndex].user = staker;
        stakes[stakePlan][staker] = userIndex; 
        
        return userIndex; 
    }

    /**
    *  @notice The blacklist is a precautionary measure in case of attacks.
    *  Closes access to staking.
    *  Do not try to harm and you will not get here :)
    */

    mapping(address => bool) private blacklist;

    function addToBlacklist(address _address) external onlyOwner{
        require(!blacklist[_address], "Already in blacklist");
        blacklist[_address] = true;
    }

    function removeFromBlacklist(address _address) external onlyOwner{
        require(blacklist[_address], "Not in blacklist");
        blacklist[_address] = false;
    }


    function _stake(uint256 _amount, uint256 stakePlan) internal whenNotPaused {                
        require(_amount > 0, "Cannot stake nothing");
        require(!pausedPlan[stakePlan], "This staking plan is currently not available.");
        require(userStaked[msg.sender] + _amount <= maxUserQuota, "Exceeding the max quota per user");
        require(totalStaked + _amount <= maxQuota, "Exceeding the max staking quota");
    
        uint256 index = stakes[stakePlan][msg.sender];
        uint256 timestamp = block.timestamp;

        if(index == 0){
            index = _addStakeholder(msg.sender, stakePlan);
        }
        stakeholders[stakePlan][index].address_stakes.push(Stake(msg.sender, _amount, timestamp, 0));

        userStaked[msg.sender] += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, stakePlan, _amount, index, timestamp);
    }


    /**
    * @notice
    * By default, the maximum period of a particular staking is 2 years = the maximum locking period
    * The new time range cannot be less than 2 years = 730 days
    * After crossing this mark, new rewards stop accruing
    */

    function setTimeRange(uint256 _newTimeRangeInDays) external onlyOwner{
        require(_newTimeRangeInDays > 730, "Min time range must be greater than 2 years");
        timeRange = _newTimeRangeInDays;
    }

    function _checkOutOfTimeRange(uint256 curStake) internal view returns(uint256){
        uint256 stakeTime = (block.timestamp - curStake) / 1 days;
        if(stakeTime > timeRange) stakeTime = timeRange;
        return stakeTime;
    }

    function setMaxQuota(uint256 _newMaxQuota) external onlyOwner{
        maxQuota = _newMaxQuota;
    }

    function setMaxUserQuota(uint256 _newMaxUserQuota) external onlyOwner{
        maxUserQuota = _newMaxUserQuota;
    }

    function viewMyQuotaLeft() public view returns(uint256){
        return(maxUserQuota - userStaked[msg.sender]);
    }

    function viewStakingQuotaLeft() public view returns(uint256){
        return(maxQuota - totalStaked);
    }

    function viewUserStaked(address _user) external view onlyOwner returns(uint256){
        return(userStaked[_user]);
    }
   
    function calculateStakeReward(Stake memory _current_stake, uint256 _stakePlan) internal view returns(uint256){          
        return ((_checkOutOfTimeRange(_current_stake.since)) * _current_stake.amount) / rewardPerDay[_stakePlan];
    }

    function _withdrawStake(uint256 amount, uint256 index, uint256 _stakePlan) internal returns(uint256){
        require(_isStakePlan(_stakePlan), "Incorrect staking plan number");
        uint256 user_index = stakes[_stakePlan][msg.sender];
        Stake memory current_stake = stakeholders[_stakePlan][user_index].address_stakes[index];
        require(((block.timestamp - current_stake.since) / 1 days) >= lockTime[_stakePlan], "Lock time is not expired");
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

        uint256 reward = calculateStakeReward(current_stake, _stakePlan);
        current_stake.amount = current_stake.amount - amount;

        if(current_stake.amount == 0){
            delete stakeholders[_stakePlan][user_index].address_stakes[index];
        }
        else {
        stakeholders[_stakePlan][user_index].address_stakes[index].amount = current_stake.amount;
        stakeholders[_stakePlan][user_index].address_stakes[index].since = block.timestamp;    
        }

        userStaked[msg.sender] -= amount;
        totalStaked -= amount;

        return amount+reward;
    }

 
    function hasStake(address _staker) public view returns(StakingSummary memory){
        StakingSummary memory summary = StakingSummary(0, stakeholders[74][stakes[74][_staker]].address_stakes);
        
        uint256 totalStakeAmount; 
        uint256 stakesLenght = summary.stakes.length;

        for (uint256 s = 0; s < stakesLenght; ++s){
           uint256 availableReward = calculateStakeReward(summary.stakes[s], 74);
           summary.stakes[s].claimable = availableReward;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
       }

        summary.total_amount = totalStakeAmount;
        return summary;
    }

    function hasStake94(address _staker94) public view returns(StakingSummary94 memory){
        StakingSummary94 memory summary94 = StakingSummary94(0, stakeholders[94][stakes[94][_staker94]].address_stakes);
        
        uint256 totalStakeAmount; 
        uint256 stakesLenght = summary94.stakes94.length;
        
        for (uint256 s = 0; s < stakesLenght; ++s){
           uint256 availableReward94 = calculateStakeReward(summary94.stakes94[s], 94);
           summary94.stakes94[s].claimable = availableReward94;
           totalStakeAmount = totalStakeAmount+summary94.stakes94[s].amount;
       }
       summary94.total_amount94 = totalStakeAmount;
        return summary94;
    }

    function hasStake114(address _staker114) public view returns(StakingSummary114 memory){
        StakingSummary114 memory summary114 = StakingSummary114(0, stakeholders[114][stakes[114][_staker114]].address_stakes);
        
        uint256 totalStakeAmount; 
        uint256 stakesLenght = summary114.stakes114.length;

        for (uint256 s = 0; s < stakesLenght; ++s){
           uint256 availableReward114 = calculateStakeReward(summary114.stakes114[s], 114);
           summary114.stakes114[s].claimable = availableReward114;
           totalStakeAmount = totalStakeAmount+summary114.stakes114[s].amount;
       }
       summary114.total_amount114 = totalStakeAmount;
        return summary114;
    }

    function hasStake134(address _staker134) public view returns(StakingSummary134 memory){
        StakingSummary134 memory summary134 = StakingSummary134(0, stakeholders[134][stakes[134][_staker134]].address_stakes);
        
        uint256 totalStakeAmount; 
        uint256 stakesLenght = summary134.stakes134.length;

        for (uint256 s = 0; s < stakesLenght; ++s){
           uint256 availableReward134 = calculateStakeReward(summary134.stakes134[s], 134);
           summary134.stakes134[s].claimable = availableReward134;
           totalStakeAmount = totalStakeAmount+summary134.stakes134[s].amount;
       }
       summary134.total_amount134 = totalStakeAmount;
        return summary134;
    }

    function hasStake174(address _staker174) public view returns(StakingSummary174 memory){
        StakingSummary174 memory summary174 = StakingSummary174(0, stakeholders[174][stakes[174][_staker174]].address_stakes);
        
        uint256 totalStakeAmount; 
        uint256 stakesLenght = summary174.stakes174.length;

        for (uint256 s = 0; s < stakesLenght; ++s){
           uint256 availableReward174 = calculateStakeReward(summary174.stakes174[s], 174);
           summary174.stakes174[s].claimable = availableReward174;
           totalStakeAmount = totalStakeAmount+summary174.stakes174[s].amount;
       }
       summary174.total_amount174 = totalStakeAmount;
        return summary174;
    }

    function hasStake344(address _staker344) public view returns(StakingSummary344 memory){
        StakingSummary344 memory summary344 = StakingSummary344(0, stakeholders[344][stakes[344][_staker344]].address_stakes);
        
        uint256 totalStakeAmount; 
        uint256 stakesLenght = summary344.stakes344.length;

        for (uint256 s = 0; s < stakesLenght; ++s){
           uint256 availableReward344 = calculateStakeReward(summary344.stakes344[s], 344);
           summary344.stakes344[s].claimable = availableReward344;
           totalStakeAmount = totalStakeAmount+summary344.stakes344[s].amount;
       }
       summary344.total_amount344 = totalStakeAmount;
        return summary344;
    }

    function _isStakePlan(uint256 _stakePlan) internal view returns(bool){
        for(uint i=0; i<6; ++i){
            if(plansNumber[i] == _stakePlan) return true;
        }
        return false;
    }

    function stake(uint256 _amount, uint256 _stakePlan) public notContract nonReentrant{
        require(_amount <= token.balanceOf(msg.sender), "Cannot stake more than you own");
        require(_isStakePlan(_stakePlan), "Incorrect staking plan number");
        require(!blacklist[msg.sender], "Access denied");

        _stake(_amount, _stakePlan);
        token.transferFrom(address(msg.sender), address(0), _amount);
    }


    function withdrawStake(uint256 amount, uint256 stake_index, uint256 _stakePlan) public notContract nonReentrant{
        uint256 amount_to_mint = _withdrawStake(amount, stake_index, _stakePlan);
        token.mint(msg.sender, amount_to_mint);
    }

    function recoverWrongTokens(address _token, uint256 _amount) public onlyOwner{
        require(_token != address(0), "The returned token cannot be zero address");
        IERC20 tokenToReturn = IERC20(address(_token));
        tokenToReturn.transfer(payable(msg.sender), _amount);
    }


}