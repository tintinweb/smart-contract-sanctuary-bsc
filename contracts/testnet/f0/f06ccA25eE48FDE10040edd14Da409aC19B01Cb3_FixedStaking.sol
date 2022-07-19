// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/** @title Staking
 * @notice It is a contract for Staking MetaPlay with fixed returns of 100% APR
 */

contract FixedStaking is ReentrancyGuard {
    using SafeERC20 for IERC20;

    //100% APR => 8.33 % Per month => 0.277% Per day
    uint8 public immutable fixedAPY = 100;
    uint256 public emergencyWithdrawFee = 10; // 10%
    IERC20 public token;

    uint256 public startPeriod;
    uint256 public endPeriod;
    uint256 public lockupPeriod;
    uint256 public immutable lockupDuration = 365 * 1 days;
    uint256 internal _precision = 1E6;

    address public owner1;
    address public owner2;

    constructor() {
        owner1 = msg.sender;
        owner2 = msg.sender;
    }

    struct UserInfo {
        uint256 depositedAmount;
        uint256 totalReward;
        uint256 pendingRewards;
        uint256 lastClaim;
    }

    UserInfo[] public userInfo;

    // mapping of user's wallet address to user id
    mapping(address => uint256) public userToId;
    mapping(address => uint256) private _userStartTime;

    // user events
    event UserAdded(address indexed user);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    // Owner's events
    event WithdrawResidualTokens();
    event StartStaking(uint256 startPeriod, uint256 lockupDuration, uint256 endPeriod);
    event TokenAddressSet(address token);

    /**
     * @notice modifier to check if user is valid
     */
    modifier validateUserByAddress() {
        require(userToId[msg.sender] <= userInfo.length, "User does not exist in the pool");
        _;
    }

    /**
     * @notice modifier to check if owner is valid
     */
    modifier owners() {
        require(msg.sender == owner1 || msg.sender == owner2, "Sorry, this request can be called by only owners");
        _;
    }

    /**
     * @notice function to approving and adding user to pool
     */
    function userAdded() public {
        // check if user is already in the pool
        require(userToId[msg.sender] == 0, "You are already in the pool");
        uint256 id = userInfo.length + 1;
        userInfo.push(UserInfo({ depositedAmount: 0, totalReward: 0, pendingRewards: 0, lastClaim: 0 }));
        userToId[msg.sender] = id;
        _userStartTime[msg.sender] = block.timestamp;
        emit UserAdded(msg.sender);
    }

    /**
     * @notice function to deposit amount to the pool
     * @param _amount: amount to deposit
     */

    function deposit(uint256 _amount) public validateUserByAddress {
        require(userToId[msg.sender] > 0, "You are not in the pool");
        require(block.timestamp > startPeriod, "Staking period ended");
        require(_amount > 0, "Amount must be greater than 0");

        UserInfo storage user = userInfo[userToId[msg.sender]];
        _updateRewards();

        token.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.depositedAmount = user.depositedAmount + (_amount);

        emit Deposit(msg.sender, _amount);
    }

    /**
     * @notice function to withdraw deposited amount from the pool
     * @param _amount: amount to withdraw
     * @param _withdrawRewards: bool to check if user wants to claim rewards too
     */
    function withdraw(uint256 _amount, bool _withdrawRewards) external validateUserByAddress nonReentrant {
        UserInfo storage user = userInfo[userToId[msg.sender]];
        require(block.timestamp > user.lastClaim + lockupDuration, "You cannot withdraw yet!");
        require(user.depositedAmount >= _amount, "Withdrawing more than you have!");
        _updateRewards();

        if (_withdrawRewards) {
            uint256 claimedAmount = user.pendingRewards;
            token.safeTransfer(address(msg.sender), user.pendingRewards);
            emit Claim(msg.sender, claimedAmount);
            user.totalReward = user.totalReward + claimedAmount;
            user.pendingRewards = user.pendingRewards - claimedAmount;
            user.lastClaim = block.timestamp;
        }
        if (_amount > 0) {
            token.safeTransfer(address(msg.sender), _amount);
            user.depositedAmount = user.depositedAmount - (_amount);
        }

        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @notice function to claim rewards
     */
    function claim() public validateUserByAddress nonReentrant {
        UserInfo storage user = userInfo[userToId[msg.sender]];
        _updateRewards();

        uint256 claimedAmount = user.pendingRewards;
        token.safeTransfer(msg.sender, user.pendingRewards);
        emit Claim(msg.sender, claimedAmount);
        user.pendingRewards = 0;
        user.lastClaim = block.timestamp;
        user.totalReward = user.totalReward + (claimedAmount);
    }

    /**
     * @notice function to withdraw staked amount before staking end period
     * @param _amount: amount to withdraw
     */
    function emergencyWithdraw(uint256 _amount) external validateUserByAddress nonReentrant {
        UserInfo storage user = userInfo[userToId[msg.sender]];

        require(block.timestamp < endPeriod, " Staking time is already over kindly use normal withdraw funtion");
        require(user.depositedAmount >= _amount, "Withdrawing more than you have!");

        _updateRewards();
        claim();

        if (_amount > 0 && user.pendingRewards == 0) {
            uint256 amountToTransfer = _amount - (emergencyWithdrawFee * _amount); // extracted 10% fee
            token.safeTransfer(address(msg.sender), amountToTransfer);
            user.depositedAmount = user.depositedAmount - (_amount);
        }

        user.lastClaim = block.timestamp;
        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @notice function that returns the remaining time in seconds of the staking period
     * @dev the higher is the precision and the more the time remaining will be precise
     * @param _user, address of the user to be checked
     * @return uint percentage of time remaining * precision
     */
    function _percentageTimeRemaining(address _user) internal view validateUserByAddress returns (uint256) {
        bool early = startPeriod > _userStartTime[_user];
        uint256 startTime;
        if (endPeriod > block.timestamp) {
            startTime = early ? startPeriod : _userStartTime[_user];
            uint256 timeRemaining = lockupDuration - (block.timestamp - startTime);
            return (_precision * (lockupDuration - timeRemaining)) / lockupDuration;
        }
        startTime = early ? 0 : lockupDuration - (endPeriod - _userStartTime[_user]);
        return (_precision * (lockupDuration - startTime)) / lockupDuration;
    }

    /**
     * @notice function to update user's pending rewards
     */
    function _updateRewards() private {
        UserInfo storage user = userInfo[userToId[msg.sender]];
        if (
            startPeriod == 0 || user.depositedAmount == 0 || block.timestamp < startPeriod || user.lastClaim > endPeriod
        ) {
            return;
        }

        // uint256 rewardCalculator = (((user.depositedAmount * fixedAPY) * _percentageTimeRemaining(msg.sender)) /
        //     (_precision * 100));

        //find the reward for per day
        uint256 currentDay = block.timestamp;
        if (block.timestamp > endPeriod) {
            currentDay = endPeriod;
        }

        uint256 rewardDays = (currentDay - user.lastClaim) / 60 / 60 / 24;
        uint256 rewardCalculator = ((27777777 * user.depositedAmount) * rewardDays) / 1E10;

        user.pendingRewards = user.pendingRewards + rewardCalculator;
        user.lastClaim = block.timestamp;
    }

    /**
     * @notice function that start the staking
     * @dev set `startPeriod` to the current `block.timestamp`
     * set `lockupPeriod` which is `block.timestamp` + `lockupDuration`
     * and `endPeriod` which is `startPeriod` + `lockupDuration`
     */
    function startStaking() external owners {
        require(startPeriod == 0, "Staking has already started");
        startPeriod = block.timestamp;
        lockupPeriod = block.timestamp + lockupDuration;
        endPeriod = startPeriod + lockupDuration;
        emit StartStaking(startPeriod, lockupDuration, endPeriod);
    }

    /**
     * @notice function to get total current staked amount
     */
    function getDepositedAmount() external view returns (uint256) {
        uint256 amount = 0;
        for (uint256 index = 0; index < userInfo.length; index++) {
            amount = amount + userInfo[userToId[msg.sender]].depositedAmount;
        }
        return amount;
    }

    /**
     * @notice function to get withdraw left out tokens from emergency
     * fees after staking peroid ends
     */
    function withdrawResidualTokens(IERC20 _token, uint256 _amount) external owners {
        require(block.timestamp > endPeriod, "Sorry, you can't take tokens before staking period is over");
        uint256 amount = 0;
        for (uint256 index = 0; index < userInfo.length; index++) {
            amount = amount + userInfo[userToId[msg.sender]].depositedAmount;
        }
        require(_amount <= address(this).balance - amount, "Sorry, these tokens don't belong to you");
        _token.safeTransfer(msg.sender, amount);
    }

    function setEmergencyWithdrawFee(uint256 _emergencyWithdrawFee) external owners {
        require(_emergencyWithdrawFee < 100, "Fee can't be 100%");
        require(_emergencyWithdrawFee > 0, "Fee can't be 0");

        emergencyWithdrawFee = _emergencyWithdrawFee;
    }

    function setToken(IERC20 _token) external owners {
        require(address(token) == address(0), "Token already set!");
        require(address(_token) != address(0), "Invalid Token Address");

        token = _token;

        emit TokenAddressSet(address(token));
    }

    function tranferOwnershipOne(address newOwner) external owners {
        require(newOwner != address(0), "Ownership can not be tranferred to null address");
        require(newOwner != owner1 && newOwner != owner2, "You are already a owner");
        owner1 = newOwner;
    }

    function tranferOwnershipTwo(address newOwner) external owners {
        require(newOwner != address(0), "Ownership can not be tranferred to null address");
        require(newOwner != owner1 && newOwner != owner2, "You are already a owner");
        owner2 = newOwner;
    }
}

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

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

    constructor () {
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

// SPDX-License-Identifier: MIT

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