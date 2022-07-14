// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IShilla.sol";

library ZeroSub {
    function zSub (uint256 a, uint256 b) internal pure returns (uint256) {
        if(a < b) return 0;
        return a - b;
    }
}

contract ShillaVault is Ownable {
    using SafeERC20 for IShilla;
    using ZeroSub for uint256;

    struct Lock {
        bool exists;
        uint256 unlockTimestampInterval;
        uint256 weight;
        uint256 weightDivisor;
        uint256 totalDeposits;
        uint256 totalProfits;
    }
    struct Items {
        uint256 id;
        address withdrawer;
        uint256 balance;
        uint256 lastDividendPoints;
        uint256 lockId;
        uint256 unlockTimestamp;
        bool withdrawn;
        bool deposited;
    }

    IShilla public token;
    uint256 public depositsCount;
    uint256 public locksCount;
    uint256 public totalDeposits;
    uint256 public totalProfits;
    uint256 public totalDividendPoints;
    
    uint256 public vaultsROIBalance;

    mapping (uint256 => Lock) private lock;
    mapping (uint256 => Items) private lockedToken;
    uint256[] public lockList;

    mapping (address => uint256) public totalDepositsOf;
    mapping (address => uint256[]) private lockedTokensOf;

    uint256 constant APPROXIMATION_EXTENSION = 10**18;
    event LockCreated(uint256 indexed lockId, uint256 indexed unlockInterval, uint256 indexed weight, uint256 weightDivisor);
    event DividendUpdated(uint256 totalDividendPoints);
    event DepositUpdated(address indexed withdrawer, uint256 indexed lockId, uint256 totalDeposits);
    event Deposit(address indexed withdrawer, uint256 indexed stakeId, uint256 indexed lockId, uint256 amount, uint256 unlockTime, uint256 lastDividendPoints);
    event Withdraw(address indexed withdrawer, uint256 indexed stakeId, uint256 amount);

    constructor(address _token) {
        token = IShilla(_token);

        locksCount = 1;
        lock[locksCount].exists = true;
        //3_day
        lock[locksCount].unlockTimestampInterval = 3 days;
        //weights/weightDivisor = 0.09375 => 1.5625%
        lock[locksCount].weight = 9375;
        lock[locksCount].weightDivisor = 100000;
        lockList.push(locksCount);
        emit LockCreated(1, lock[locksCount].unlockTimestampInterval, lock[locksCount].weight, lock[locksCount].weightDivisor);

        locksCount = 2;
        lock[locksCount].exists = true;
        //1_week
        lock[locksCount].unlockTimestampInterval = 7 days;
        //weights/weightDivisor = 0.21875 => 3.6458333333333335%
        lock[locksCount].weight = 21875;
        lock[locksCount].weightDivisor = 100000;
        lockList.push(locksCount);
        emit LockCreated(2, lock[locksCount].unlockTimestampInterval, lock[locksCount].weight, lock[locksCount].weightDivisor);

        locksCount = 3;
        lock[locksCount].exists = true;
        //2_week
        lock[locksCount].unlockTimestampInterval = 14 days;
        //weights/weightDivisor = 0.4375 => 7.291666666666667%
        lock[locksCount].weight = 43750;
        lock[locksCount].weightDivisor = 100000;
        lockList.push(locksCount);
        emit LockCreated(3, lock[locksCount].unlockTimestampInterval, lock[locksCount].weight, lock[locksCount].weightDivisor);

        locksCount = 4;
        lock[locksCount].exists = true;
        //1_month
        lock[locksCount].unlockTimestampInterval = 28 days;
        //weights/weightDivisor = 0.875 => 14.583333333333334%
        lock[locksCount].weight = 87500;
        lock[locksCount].weightDivisor = 100000;
        lockList.push(locksCount);
        emit LockCreated(4, lock[locksCount].unlockTimestampInterval, lock[locksCount].weight, lock[locksCount].weightDivisor);

        locksCount = 5;
        lock[locksCount].exists = true;
        //2_month
        lock[locksCount].unlockTimestampInterval = 56 days;
        //weights/weightDivisor = 1.75 => 29.166666666666668%
        lock[locksCount].weight = 175000;
        lock[locksCount].weightDivisor = 100000;
        lockList.push(locksCount);
        emit LockCreated(5, lock[locksCount].unlockTimestampInterval, lock[locksCount].weight, lock[locksCount].weightDivisor);

        locksCount = 6;
        lock[locksCount].exists = true;
        //3_month
        lock[locksCount].unlockTimestampInterval = 84 days;
        //weights/weightDivisor = 2.625 => 43.75%
        lock[locksCount].weight = 262500;
        lock[locksCount].weightDivisor = 100000;
        lockList.push(locksCount);
        emit LockCreated(6, lock[locksCount].unlockTimestampInterval, lock[locksCount].weight, lock[locksCount].weightDivisor);
    }

    function stake(address _withdrawer, uint256 _amount, uint256 _lockId) external returns (uint256 _id) {
        require(lock[_lockId].exists, 'Invalid lock!');
        require(_amount > 0, 'No amount staked!');
        token.safeTransferFrom(msg.sender, address(this), _amount);

        totalDeposits = totalDeposits + _amount;
        vaultsROIBalance = vaultsROIBalance + _amount;
        totalDepositsOf[_withdrawer] = totalDepositsOf[_withdrawer] + _amount;
        lock[_lockId].totalDeposits = lock[_lockId].totalDeposits + _amount;
        _id = ++depositsCount;

        //updateDividends stake dividends to its latest lock dividends
        // so that the stake doesn't share in the dividends shared before the stake was made
        lockedToken[_id].lastDividendPoints = totalDividendPoints;
        lockedToken[_id].withdrawer = _withdrawer;
        lockedToken[_id].balance = _amount;
        lockedToken[_id].lockId = _lockId;
        lockedToken[_id].unlockTimestamp = block.timestamp + lock[_lockId].unlockTimestampInterval;
        lockedToken[_id].deposited = true;
        
        lockedTokensOf[_withdrawer].push(_id);
        emit Deposit(_withdrawer, _id, _lockId, _amount, lockedToken[_id].unlockTimestamp, lockedToken[_id].lastDividendPoints);
        emit DepositUpdated(_withdrawer, _id, lock[_lockId].totalDeposits);
    }

    function unstake(uint256 _id) external {
        require(block.timestamp >= lockedToken[_id].unlockTimestamp, 'Tokens still locked!');
        _unstake(_id);
    }

    //Called by the token with tax, games with vault's profit share, any utility dapp that makes profits in the ecosystem, 
    // or anyone that feels like giving back to the community :)
    function diburseProfits(uint256 amount) external {
        token.safeTransferFrom(msg.sender, address(this), amount);
        _diburseProfits(amount);
    }

    //Burn unallocated rewards
    function _burnUnAllocatedRewards(uint256 amount) external onlyOwner {
        uint256 unAllocatedRewards =  _getUnAllocatedRewards();
        require(unAllocatedRewards >= amount, "Insufficient unallocated rewards");
        unAllocatedRewards -= amount;
        require(token.burn(amount), "Failed to burn rewards");
    }

    //Diburse unallocated rewards
    function _diburseUnAllocatedRewards(uint256 amount) external onlyOwner {
        uint256 unAllocatedRewards =  _getUnAllocatedRewards();
        require(unAllocatedRewards >= amount, "Insufficient unallocated rewards");
        unAllocatedRewards -= amount;
        _diburseProfits(amount);
    }

    function _getUnAllocatedRewards() private view returns (uint256) {
        return token.balanceOf(address(this)) - vaultsROIBalance;
    }

    function getUnAllocatedRewards() external view returns (uint256) {
        return _getUnAllocatedRewards();
    }

    function getLock(uint256 id) external view returns (
        uint256 unlockTimestampInterval, 
        uint256 weight, 
        uint256 weightDivisor,
        uint256 deposit,
        uint256 profit) {
        unlockTimestampInterval = lock[id].unlockTimestampInterval;
        weight = lock[id].weight;
        weightDivisor = lock[id].weightDivisor;
        deposit = lock[id].totalDeposits;
        profit = lock[id].totalProfits;
    }

    function getLocks() external view returns (
        uint256[] memory idList,
        uint256[] memory unlockTimestampIntervals, 
        uint256[] memory weights, 
        uint256[] memory weightDivisors,
        uint256[] memory deposits,
        uint256[] memory profits) {
        
        idList = new uint256[](lockList.length);
        unlockTimestampIntervals = new uint256[](lockList.length);
        weights = new uint256[](lockList.length);
        weightDivisors = new uint256[](lockList.length);
        deposits = new uint256[](lockList.length);
        profits = new uint256[](lockList.length);

        for(uint8 i = 0; i < lockList.length; i++) {
            idList[i] = lockList[i];
            unlockTimestampIntervals[i] = lock[idList[i]].unlockTimestampInterval;
            weights[i] = lock[idList[i]].weight;
            weightDivisors[i] = lock[idList[i]].weightDivisor;
            deposits[i] = lock[idList[i]].totalDeposits;
            profits[i] = lock[idList[i]].totalProfits;
        }
    }

    //Get total number of stakes currently done by @staker
    function countStakedBy(address staker) external view returns (uint256) {
        return lockedTokensOf[staker].length;
    }

    function lastStakeBy(address account) external view returns (uint256) {
        if(lockedTokensOf[account].length > 0) return lockedTokensOf[account][lockedTokensOf[account].length - 1];
        return 0;
    }

    //Get total rewards of all tokens currently staked by @staker
    function totalRewardsOfStakesBy(address staker) external view returns (uint256 roi) {
        for (uint256 i = 0; i < lockedTokensOf[staker].length; i++) {
            roi += _dividendsOwing(lockedTokensOf[staker][i]);
        }
    }

    //Get the total amount deposited in the stake referenced by @stakeId
    function stakeAt(uint256 stakeId) external view returns (uint256) {
        return lockedToken[stakeId].balance;
    }

    //Get the total amount deposited in the stake referenced by @stakeId + reward so far
    function stakeRewardAt(uint256 stakeId) external view returns (uint256) {
        return _dividendsOwing(stakeId);
    }

    //Get the total amount deposited in the vault referenced by @lockId
    function lockStakesAt(uint256 lockId) external view returns (uint256) {
        return lock[lockId].totalDeposits;
    }

    //Get the total amount deposited in the vault referenced by @lockId + reward so far
    function lockStakesROIAt(uint256 lockId) external view returns (uint256) {
        return lock[lockId].totalDeposits + lock[lockId].totalProfits;
    }

    function _unstake(uint256 _id) private {
        require(lockedToken[_id].deposited, 'Invalid stake!');
        require(msg.sender == lockedToken[_id].withdrawer, 'Access denied!');
        require(!lockedToken[_id].withdrawn, 'Tokens already withdrawn!');

        lockedToken[_id].withdrawn = true;

        uint256 profits = _dividendsOwing(_id);

        lock[lockedToken[_id].lockId].totalProfits = lock[lockedToken[_id].lockId].totalProfits.zSub(profits);
        totalProfits = totalProfits.zSub(profits);

        uint256 withdrawal = lockedToken[_id].balance + profits;
        
        if(vaultsROIBalance < withdrawal) {
            withdrawal = vaultsROIBalance;
        }
        vaultsROIBalance = vaultsROIBalance - withdrawal;

        totalDeposits = totalDeposits - lockedToken[_id].balance;
        totalDepositsOf[msg.sender] = totalDepositsOf[msg.sender] - lockedToken[_id].balance;
        lock[lockedToken[_id].lockId].totalDeposits = lock[lockedToken[_id].lockId].totalDeposits - lockedToken[_id].balance;
        emit DepositUpdated(msg.sender, lockedToken[_id].lockId, lock[lockedToken[_id].lockId].totalDeposits);

        for (uint256 i = 0; i < lockedTokensOf[msg.sender].length; i++) {
            if (lockedTokensOf[msg.sender][i] == _id) {
                lockedTokensOf[msg.sender][i] = lockedTokensOf[msg.sender][lockedTokensOf[msg.sender].length - 1];
                lockedTokensOf[msg.sender].pop();
                break;
            }
        }

        emit Withdraw(msg.sender, _id, withdrawal);
        token.safeTransfer(msg.sender, withdrawal);
    }

    function _diburseProfits(uint256 amount) private {
        if(totalDeposits > 0) {
            uint256 point = (amount * APPROXIMATION_EXTENSION) / totalDeposits;
            totalDividendPoints += point;
            uint256 amountUsed;
            uint256 lockShare;

            for (uint8 i = 0; i < lockList.length; i++) {
                if(lock[lockList[i]].totalDeposits > 0) {
                    lockShare = _pointToRewardShare(point, lockList[i], lock[lockList[i]].totalDeposits);
                    lock[lockList[i]].totalProfits += lockShare;
                    amountUsed += lockShare;
                }
                
            }

            totalProfits += amountUsed;
            vaultsROIBalance += amountUsed;
            emit DividendUpdated(totalDividendPoints);
        }
    }
    
    function _dividendsOwing(uint256 id) private view returns(uint256) {
        uint256 newDividendPoints = totalDividendPoints - lockedToken[id].lastDividendPoints;
        return _pointToRewardShare(newDividendPoints, lockedToken[id].lockId, lockedToken[id].balance);
    }

    function _pointToRewardShare(uint256 point, uint256 lockId, uint256 balance) private view returns(uint256) {
        return (balance * point * lock[lockId].weight) / (lock[lockId].weightDivisor * APPROXIMATION_EXTENSION);
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IShilla is IERC20 {
    function decimals() external view returns (uint8);
    function burn(uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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