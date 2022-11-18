/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// File: rlink/interfaces/IRlinkRelation.sol



pragma solidity ^0.8.0;

interface IRlinkRelation {
    /**
     * @dev query seconds of a month
     * @return seconds of a month
     */
    function monthScale() external pure returns(uint256);

    /**
     * @dev query stake base amount,stake monthes formula: (1 + usingMonthes) * usingMonthes / 2 * stakeBase
     * @return stake base amount
     */
    function stakeBase() external pure returns(uint256);

    /**
     * @dev query stake for month limit
     * @return stake for month limit
     */
    function maxStakeMonth() external view returns(uint256);

    /**
     * @dev query staked limit
     * @return stake limit
     */
    function maxStakeAmount() external view returns(uint256);

    /**
     * @dev query global trial seconds
     * @return seconds of global trial
     */
    function globalTrial() external view returns(uint256);

    /**
     * @dev query stake enable status
     * @return stake enable status
     */
    function stakeEnabled() external view returns(bool);

    /**
     * @dev query withdraw enable status
     * @return withdraw enable status
     */
    function withdrawEnabled() external view returns(bool);

    /**
     * @dev query burn expired stake enable status
     * @return burn expired stake enable status
     */
    function burnEnabled() external view returns(bool);

    /**
     * @dev query stakingToken address
     * @return burn stakingToken address
     */
    function stakingToken() external view returns(address);    

    /**
     * @dev add address relation
     * @param _child: address of the child
     * @param _parent: address of the parent
     * @return whether or not the add relation succeeded
     */
    function addRelation(address _child, address _parent) external returns(bool);

    /**
     * @dev query child and parent is associated
     * @param child: address of the child
     * @param parent: address of the parent
     * @return child and parent is associated
     */
    function isParent(address child,address parent) external view returns(bool);

    /**
     * @dev query parent of address
     * @param account: address of the child
     * @return parent address
     */
    function parentOf(address account) external view returns(address);

    /**
     * @dev stake stakingToken to rlink relation
     * @param forAccount: address of stake for
     * @param amount: stake amount
     * @return whether or not the stake succeeded
     */
    function stake(address forAccount,uint256 amount) external returns(bool);

    /**
     * @dev query address staked amount
     * @param account: address of to be queried
     * @return staked amount
     */
    function stakeOf(address account) external view returns(uint256);

    /**
     * @dev withdraw stake
     * require withdraw is enabled
     * @param to: withdraw to address
     */
    function withdraw(address to) external;

    /**
     * @dev burn expired stake of account
     * require burn expired stake is enabled
     * @param account: address of expired stake
     */
    function burnExpiredStake(address account) external;

    /**
     * @dev distribute token
     * you must approve bigger than 'amount' allowance of token for rlink relation contract before call
     * @param token: token address to be distributed
     * @param to: to address
     * @param incentiveRate: numerator of incentive rate,denominator is 1e18
     * @param parentRate: numerator of parent rewards rate,denominator is 1e18
     * @param grandpaRate: numerator of grandpa rewards rate,denominator is 1e18
     */
    function distribute(
        address token,
        address to,
        uint256 amount,
        uint256 incentiveRate,
        uint256 parentRate,
        uint256 grandpaRate
    ) external returns(uint256 distributedAmount);

    /**
     * @dev query trial expire at 
     * require burn expired stake is enabled
     * @param account: the address of to be queried
     * @return trial expire at of queried address
     */
    function trialExpireAt(address account) external view returns(uint256);

    /**
     * @dev query expire at
     * require burn expired stake is enabled
     * @param account: the address of to be queried
     * @return expire at of queried address
     */
    function expireAt(address account) external view returns(uint256);

    /**
     * @dev query call function 'distribute' fee (default is 0)
     * @return call function 'distribute' fee
     */
    function distributeFee() external view returns(uint256);

    /**
     * @dev query call add relation rewards amount 
     * @return add relation rewards amount 
     */
    function bindReward() external view returns(uint256);

    /**
     * @dev query remaining rewards amount
     * @return remaining rewards amount
     */
    function remainingRewards() external view returns(uint256);

    /**
     * @dev query total minted rewards amount
     * @return total minted rewards amount
     */
    function mintedRewards() external view returns(uint256);
    
    //an event thats emitted when new relation added
    event AddedRelation(address child,address parent);

    //an event thats emitted when staked
    event Staked(address forAccount,uint256 amount);

    //an event thats emitted when token distributed
    event Distributed(address sender,address token, address to,uint256 toAmount,uint256 parantAmount, uint256 grandpaAmount);
}
// File: rlink/interfaces/IRlink.sol



pragma solidity ^0.8.0;

interface IRlink {
    function burn(uint rawAmount) external;
}
// File: rlink/libs/Context.sol



pragma solidity ^0.8.0;

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
        return msg.data;
    }
}

// File: rlink/libs/Ownable.sol



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

// File: rlink/libs/BlackListable.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract BlackListable is Ownable {

    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    mapping (address => bool) public isBlackListed;
    
    function _addBlackList (address _evilUser) internal {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function _removeBlackList (address _clearedUser) internal {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    modifier notBlackListed {
        require(!isBlackListed[_msgSender()],"blacklisted");
        _;
    }

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}
// File: rlink/libs/Pausable.sol



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

// File: rlink/libs/Address.sol



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

// File: rlink/interfaces/IERC20.sol



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

// File: rlink/libs/SafeERC20.sol



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

// File: rlink/libs/SafeMath.sol


pragma solidity ^0.8.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
// File: rlink/libs/Math.sol



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
        // (a + b) / 2 can overflow, so we distribute.
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// File: rlink/rlinkRelation.sol



pragma solidity ^0.8.0;








contract RlinkRelation is Pausable,BlackListable,IRlinkRelation {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address=>address) private _parents;

    mapping(address=>uint256) private _stakeBalances;

    mapping(address=>uint256) private _specialTrials;

    mapping(address=>StakeInfo) private _stakes;

    uint256 public override distributeFee;

    address public feeTo;

    uint256 public override bindReward;

    uint256 public override mintedRewards;

    uint256 public override remainingRewards;

    bool public override stakeEnabled;

    uint256 public stakeEnableTime;

    bool public verifyChild = false;    

    uint256 public constant distributeFeeCap = 1000 * 1e18;

    uint256 public constant override monthScale = 31 days;

    uint256 public constant override stakeBase = 10000 * 1e18;

    uint256 public override maxStakeMonth = 10;

    uint256 public override globalTrial = 0;

    bool public override withdrawEnabled = false;

    bool public override burnEnabled = false;

    bool public queryVerify = false;
  
    address public override immutable stakingToken;

    uint256 public immutable createTime;


    event DistributeFeeChanged(address sender, uint256 oldFee,uint256 newFee);

    event SetedSpecialTrials(address account,uint256 trialSeconds);

    event BindRewardChanged(address sender, uint256 oldReward,uint256 newReward);

    event AddedReward(uint256 amount);

    event StakeEnableChanged(address sender, bool enableStatus);

    event WithdrawEnableChanged(address sender,bool enableStatus);

    event BurnEnabledChanged(address sender,bool enableStatus);

    event MaxStakeMonthChanged(address sender,uint256 oldLimit,uint256 newLimit);

    event VerifyChildChanged(address sender,bool enableStatus);

    event GlobalTrialTimeChanged(address sender,uint256 oldTrialTime,uint256 newTrialTime);

    event FeeToChanged(address sender,address oldFeeTo,address newFeeTo);

    event BurnedStake(address sender,address account,uint256 amount);

    event Withdrawed(address account,uint256 amount);

    event DistributedParams(address token,address to,uint256 amount,uint256 incentiveRate,uint256 parentRate,uint256 grandpaRate);

    event QueryVerifyChanged(address sender,bool isEnable);

    struct StakeInfo {
        uint256 firstCallTime;
        uint256 stakedExpireAt;
        uint256 stakedMonthes;
    }

    modifier onlyGovernance(){
        require(owner() == _msgSender(), "Rlink: caller is not the governance");
        _;
    }

    constructor(address _stakingToken){
        stakingToken = _stakingToken;
        createTime = block.timestamp;
        feeTo = msg.sender;
    }

    function isParent(address child,address parent) external view override returns(bool) {
        return _parents[child] == parent;
    }

    function parentOf(address account) external view override returns(address) {
        if(queryVerify){
            require(_checkStake(msg.sender),"Rlink::distribute: insufficient stakes");
        }

        return _parents[account];
    }

    function addRelation(address _child, address _parent) external override whenNotPaused notBlackListed returns(bool) {
        require(_child != _parent,"Rlink::addRelation: parent can not be self");
        require(_child != address(0) && _parent != address(0),"Rlink::addRelation: child or parent can not be address 0");
        require(_parents[_child] == address(0),"Rlink::addRelation: child already has parent");
        require(_parents[_parent] != _child,"Rlink::addRelation: parent can not be descendant of child");
        require(!verifyChild || tx.origin == _child,"Rlink::addRelation: child must be tx origin");

        _parents[_child] = _parent;
        if(bindReward > 0 && remainingRewards >= bindReward){
            remainingRewards = remainingRewards.sub(bindReward);
            mintedRewards = mintedRewards.add(bindReward);
            IERC20(stakingToken).safeTransfer(msg.sender,bindReward);
        }

        emit AddedRelation(_child, _parent);
        return true;
    }

    function stake(address forAccount,uint256 amount) external override whenNotPaused notBlackListed returns(bool) {
        require(forAccount!=address(0),"Rlink::stake: can not stake for address 0");
        require(amount>0,"Rlink::stake: can not stake 0");
        require(stakeEnabled,"Rlink::stake: stake is not enabled");

        IERC20(stakingToken).safeTransferFrom(_msgSender(), address(this), amount);
        uint256 oldAmount=_stakeBalances[forAccount];
        uint256 newAmount=oldAmount.add(amount);
        require(newAmount <= maxStakeAmount(),"Rlink::stake: total staked of forAccount exceeds max stake amount");
        _stakeBalances[forAccount] = newAmount;

        uint256 oldStakedMonthes = calcStakeMonthes(oldAmount);
        uint256 newStakedMonthes = calcStakeMonthes(newAmount);
        if(newStakedMonthes > oldStakedMonthes){
            uint256 oldExpireAt = Math.max(_stakes[forAccount].stakedExpireAt,trialExpireAt(forAccount));
            _stakes[forAccount].stakedMonthes = newStakedMonthes;
            _stakes[forAccount].stakedExpireAt = Math.max(oldExpireAt,block.timestamp).add(newStakedMonthes.sub(oldStakedMonthes).mul(monthScale));
        }

        emit Staked(forAccount, amount);
        return true;
    } 

    function stakeOf(address account) external view override returns(uint256){
        return _stakeBalances[account];
    }

    function expireAt(address account) public view override returns(uint256) {
        if(_stakes[account].stakedMonthes >= maxStakeMonth){
            return type(uint256).max;
        }
        return Math.max(_stakes[account].stakedExpireAt,trialExpireAt(account));
    }

    function calcStakeMonthes(uint256 stakedAmount) public view returns(uint256) {
        uint256 stakeBase_ = stakeBase;
        if(stakedAmount<stakeBase_){
            return 0;
        }
        if(stakedAmount<stakeBase_.mul(3)){
            return 1;
        }
        if(stakedAmount >= maxStakeAmount()){
            return maxStakeMonth;
        }
        uint256 high = maxStakeMonth;
        uint256 low = 1;
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if ((1 + mid).mul(mid).div(2).mul(stakeBase_) > stakedAmount) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        
        return high == 1 ? 1 : high - 1;
    }

    function maxStakeAmount() public view override returns(uint256){
        uint256 m=maxStakeMonth;
        if(m == 1){
            return stakeBase;
        }
        
        return (1 + m).mul(m).div(2).mul(stakeBase);
    }

    function withdraw(address to) external override whenNotPaused notBlackListed {
        require(to!=address(0),"Rlink::withdraw: can not withdraw to address 0");
        require(withdrawEnabled,"Rlink::withdraw: withdraw is disabled");
        require(_stakeBalances[msg.sender]>0,"Rlink::withdraw: you have no stakes");

        uint256 stakeAmount = _stakeBalances[msg.sender];
        _stakeBalances[msg.sender] = 0;
        _stakes[msg.sender].stakedExpireAt=block.timestamp - 1;
        _stakes[msg.sender].stakedMonthes=0;
        IERC20(stakingToken).safeTransfer(to, stakeAmount);

        emit Withdrawed(msg.sender,stakeAmount);
    }
    
    function burnExpiredStake(address account) external override whenNotPaused notBlackListed {
        require(burnEnabled,"Rlink::burnExpiredStake: burn stake is disabled");
        require(createTime.add(10 * 31 * 86400) < block.timestamp,"Rlink::burnExpiredStake: contract must created 10 monthes");
        require(expireAt(account) < block.timestamp,"Rlink::burnExpiredStake: stake is not expired");
        require(_stakeBalances[account]>0,"Rlink::burnExpiredStake: account has no stakes");
        
        uint256 stakeBalance = _stakeBalances[account];
        _stakeBalances[account] = 0;
        IRlink(stakingToken).burn(stakeBalance);

        emit BurnedStake(msg.sender, account,stakeBalance);
    }

    function distribute(
        address token,
        address to,
        uint256 amount,
        uint256 incentiveRate,
        uint256 parentRate,
        uint256 grandpaRate
    ) external override whenNotPaused notBlackListed returns(uint256 distributedAmount) {
        require(amount>0,"Rlink::distribute:  can not distribute 0");
        require(to!=address(0),"Rlink::distribute:  to address can not be address 0");
        require(incentiveRate.add(parentRate).add(grandpaRate)<1e18,"Rlink::distribute: sum of the rates must less than 1e18");
        require(_checkStake(msg.sender),"Rlink::distribute: insufficient stakes");

        address sender=_msgSender();
        if(stakeEnabled && _stakes[sender].firstCallTime == 0){
            _stakes[sender].firstCallTime = block.timestamp;
        }
        _chargeDistributeFee(sender);

        IERC20 token_= IERC20(token);
        uint256 forGrandpaAmount = amount.mul(grandpaRate).div(1e18);
        uint256 forParentAmount = amount.mul(parentRate).div(1e18); 
        address parent_ = _parents[to];
        if(parent_ != address(0) && forParentAmount.add(forGrandpaAmount)>0){
            if(forParentAmount > 0){
                token_.safeTransferFrom(sender, parent_, forParentAmount);
            }
            if(forGrandpaAmount>0 && _parents[parent_] != address(0)){
                token_.safeTransferFrom(sender, _parents[parent_], forGrandpaAmount);
            }  
        }

        uint256 selfAmount = amount.sub(forParentAmount).sub(forGrandpaAmount);
        if(parent_ == address(0)){
            selfAmount = selfAmount.sub(amount.mul(incentiveRate).div(1e18));
        }
        token_.safeTransferFrom(sender,to,selfAmount);                     

        emit DistributedParams(token,to,amount,incentiveRate,parentRate,grandpaRate);
        emit Distributed(sender,token, to, selfAmount, forParentAmount, forGrandpaAmount);
        distributedAmount = selfAmount + forParentAmount + forGrandpaAmount;
    }

    function _checkStake(address account) internal view returns(bool){
        if(!stakeEnabled){
            return true;
        }

        return expireAt(account) > block.timestamp;
    }

    function trialExpireAt(address account) public view override returns(uint256){
        uint256 firstCallTs = _stakes[account].firstCallTime;
        uint256 checkStartAt = firstCallTs == 0 ? block.timestamp : Math.max(stakeEnableTime,firstCallTs);

        return checkStartAt.add(Math.max(_specialTrials[account], globalTrial));
    }

    function _chargeDistributeFee(address sender) internal {
        if(distributeFee>0){
            IERC20(stakingToken).safeTransferFrom(sender, feeTo, distributeFee);
        }
    }

    function firstCallTime(address account) external view returns(uint256) {
        return _stakes[account].firstCallTime;
    }

    function trialTimes(address account) external view returns(uint256){
        return Math.max(_specialTrials[account], globalTrial);
    }

    function setDistributeFee(uint256 newFee) external onlyGovernance {
        require(newFee <= distributeFeeCap,"newFee exceeds distribute fee cap");
        uint256 oldFee=distributeFee;
        distributeFee=newFee;

        emit DistributeFeeChanged(msg.sender, oldFee,newFee);
    }

    function setBindReward(uint256 newReward) external onlyGovernance {
        uint256 oldReward= bindReward;
        bindReward = newReward;

        emit BindRewardChanged(msg.sender, oldReward,newReward);
    }

    function addReward(uint256 addAmount) external onlyGovernance {
        require(addAmount>0,"addAmount can not be 0");
        IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), addAmount);
        remainingRewards = remainingRewards.add(addAmount);

        emit AddedReward(addAmount);
    }

    function setStakeEnable(bool isEnable) external onlyGovernance {
        stakeEnabled = isEnable;
        if(isEnable && stakeEnableTime==0){
            stakeEnableTime=block.timestamp;
        }

        emit StakeEnableChanged(msg.sender,isEnable);
    }

    function setSpecialTrial(address account,uint256 trialSeconds) external onlyGovernance {
        _specialTrials[account] = trialSeconds;

        emit SetedSpecialTrials(account, trialSeconds);
    }    

    function setWithdrawEnable(bool isEnable) external onlyGovernance {
        withdrawEnabled = isEnable;

        emit WithdrawEnableChanged(msg.sender, isEnable);
    }

    function setMaxStakeMonth(uint256 newMaxStakeMonth) external onlyGovernance {
        require(newMaxStakeMonth > 0,"max stake month can not be 0");
        require(newMaxStakeMonth <= 10 * 12,"max stake month too high");
        uint256 oldMax = maxStakeMonth;
        maxStakeMonth = newMaxStakeMonth;

        emit MaxStakeMonthChanged(msg.sender, oldMax, newMaxStakeMonth);
    }

    function setVerifyChild(bool isEnable) external onlyGovernance {
        verifyChild=isEnable;

        emit VerifyChildChanged(msg.sender,isEnable);
    }

    function setGlobalTrial(uint256 _newTrialTime) external onlyGovernance {
        uint256 oldTrial_ = globalTrial;
        globalTrial = _newTrialTime;

        emit GlobalTrialTimeChanged(msg.sender,oldTrial_,_newTrialTime);
    }

    function setFeeTo(address newFeeTo) external onlyGovernance {
        require(newFeeTo!=address(0),"fee to can not be address 0");
        address oldFeeTo = feeTo;
        feeTo = newFeeTo;

        emit FeeToChanged(msg.sender, oldFeeTo, newFeeTo);
    }

    function setBurnEnable(bool isEnable) external onlyGovernance {
        burnEnabled=isEnable;

        emit BurnEnabledChanged(msg.sender,isEnable);
    }

    function setQueryVerify(bool isEnable) external onlyGovernance {
        queryVerify=isEnable;

        emit QueryVerifyChanged(msg.sender, isEnable);
    }

    function pause() external onlyGovernance {
        _pause();
    }

    function unpause() external onlyGovernance {
        _unpause();
    }

    function addBlackList(address _evilUser) external onlyGovernance {
        _addBlackList(_evilUser);
    }

    function removeBlackList(address _clearedUser) external onlyGovernance {
        _removeBlackList(_clearedUser);
    }
}