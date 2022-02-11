/**
 *Submitted for verification at BscScan.com on 2022-02-02
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor (address newOwner) {
		require(newOwner != address(0), "Ownable: the owner must not be empty");
		_owner = newOwner;
		emit OwnershipTransferred(address(0), newOwner);
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
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

contract StakedToken is Context, Ownable {

	using SafeERC20 for IERC20;
	uint256 constant DAY_IN_SECONDS = 86400;

	IERC20 public immutable STAKED_TOKEN;
    uint256 public constant MIN_STAKED_TIME = 1 days;
	uint256 public constant MAX_STAKED_COUNT = 101;
	uint256 public constant MAX_CHANGE_REWARD_TOKENS_BY_DAY_COUNT = 1000;

	uint256 public rewardTokensByDay;

	uint256 public totalReceivedReward;
	uint256 public totalAddedTokenForReward;
	uint256 public totalStakesCount;
	uint256 public totalStakedTokens;

	uint256 private immutable startedDayNumber;

	mapping(address => Stake[]) private _staked;

	struct Stake {
		uint256 startTime;
		uint256 endTime;
		uint256 lastRewardTime;
		uint256 amount;
	}

	struct ChangeRewardToken {
		uint256 currentDayNumber;
		uint256 rewardAmount;
	}

	struct DailyStakeInfo {
		uint256 stakesCount;
		uint256 stakedTokenAmount;
	}

	mapping(uint256 => DailyStakeInfo) private _countStakesByDay;

	ChangeRewardToken[] private changeRewardTokenAll;

	event Staked(address indexed from, address indexed onBehalfOf, uint256 amount);
	event UnStake(address indexed from, address indexed to, uint256 amount);
	event GetReward(address indexed from, address indexed to, uint256 amount);
	event AddRewardFund(address who, uint256 amount);
	event ChangeRewardTokenByDay(address who, uint256 value);

	constructor(IERC20 stakedToken, address admin, uint256 currentRewardTokensByDay) Ownable(admin) {
		require(address(stakedToken) != address(0), 'INVALID_ZERO_ADDRESS');
		rewardTokensByDay = currentRewardTokensByDay;
		STAKED_TOKEN = stakedToken;
		startedDayNumber = getCurrentDayNumber();
		logRewardTokenByDay(rewardTokensByDay);
	}

	function stake(address onBehalfOf, uint256 amount) external {
		require(amount != 0, 'INVALID_ZERO_AMOUNT');
        require(onBehalfOf != address(0), 'INVALID_ZERO_ADDRESS');
		require(getCountStake(onBehalfOf) <= MAX_STAKED_COUNT, 'INVALID_STAKED_COUNT');

		IERC20(STAKED_TOKEN).safeTransferFrom(_msgSender(), address(this), amount);
		uint256 currentTime = getCurrentTime();
		Stake memory userStake = Stake(currentTime, 0, 0, amount);
        _staked[onBehalfOf].push(userStake);
		totalStakesCount++;
		totalStakedTokens += amount;
		_countStakesByDay[getCurrentDayNumber()].stakesCount = totalStakesCount;
		_countStakesByDay[getCurrentDayNumber()].stakedTokenAmount = totalStakedTokens;
		emit Staked(_msgSender(), onBehalfOf, amount);
	}

    function unStake(address onBehalfOf) external {
		uint256 count = getCountStake(_msgSender());
		for(uint256 i = 0; i < count; i++ ) {
			unStakeAny(onBehalfOf, i);
		}
    }

	function unStakeAny(address onBehalfOf, uint256 index) public {
		require(onBehalfOf != address(0), 'INVALID_ZERO_ADDRESS');
		address sender = _msgSender();
		require(index < getCountStake(sender), 'INVALID_INDEX');
		if (_staked[sender][index].endTime == 0) {
			getReward(onBehalfOf);

			uint256 stakedAmount = _staked[sender][index].amount;

			_staked[sender][index].endTime = getCurrentTime();

			totalStakesCount--;
			totalStakedTokens -= stakedAmount;
			_countStakesByDay[getCurrentDayNumber()].stakesCount = totalStakesCount;
			_countStakesByDay[getCurrentDayNumber()].stakedTokenAmount = totalStakedTokens;

			IERC20(STAKED_TOKEN).safeTransfer(onBehalfOf, stakedAmount);
			emit UnStake(msg.sender, onBehalfOf, stakedAmount);
		}
	}

	function getReward(address onBehalfOf) public {
		require(onBehalfOf != address(0), 'INVALID_ZERO_ADDRESS');
		address sender = _msgSender();

		uint256 count = getCountStake(sender);
		require(0 < count, 'USER_NOT_STAKE');

		uint256 reward = 0;

		for(uint256 i = 0; i < count; i++ ) {
			(uint256 currentReward, uint256 newLastTime) = calcRewardByIndex(sender, i, 0);
			reward += currentReward;
			if (newLastTime > 0) {
				setLastRewardTime(sender, i, newLastTime);
			}
		}

		if (reward > 0) {
			IERC20(STAKED_TOKEN).safeTransfer(onBehalfOf, reward);
			emit GetReward(sender, onBehalfOf, reward);
			totalReceivedReward += reward;
		}
	}

	function viewUserStakeAny(address user, uint256 index) public view returns
	(uint256 _startTime, uint256 _endTime, uint256 _lastRewardTime, uint256 _amount) {
		require(user != address(0), 'INVALID_ZERO_ADDRESS');
		require(index < getCountStake(user), 'INVALID_INDEX');

		_startTime = _staked[user][index].startTime;
		_endTime = _staked[user][index].endTime;
		_lastRewardTime = _staked[user][index].lastRewardTime;
		_amount = _staked[user][index].amount;
	}

	function viewUserStake(address user) public view returns
	(uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
		uint256 count = getCountStake(user);
		uint256[] memory _startTimes = new uint[](count);
		uint256[] memory _endTimes = new uint[](count);
		uint256[] memory _lastRewardTimes = new uint[](count);
		uint256[] memory _amounts = new uint[](count);

		for(uint256 i = 0; i < count; i++ ) {
			(uint256 _startTime, uint256 _endTime, uint256 _lastRewardTime, uint256 _amount) =
				viewUserStakeAny(user, i);
				_startTimes[i] = _startTime;
				_endTimes[i] = _endTime;
				_lastRewardTimes[i] = _lastRewardTime;
				_amounts[i] = _amount;
		}
		return(_startTimes, _endTimes, _lastRewardTimes, _amounts);
	}

	function getCountStake(address user) public view returns (uint256 _count) {
		require(user != address(0), 'INVALID_ZERO_ADDRESS');
		_count = _staked[user].length;
	}

	function getChangeRewardCount() public view returns (uint256 _count) {
		_count = changeRewardTokenAll.length;
	}

	function viewChangeRewardByIndex(uint256 index) public view returns
		(uint256 _currentDayNumber, uint256 _rewardAmount) {
		return (changeRewardTokenAll[index].currentDayNumber, changeRewardTokenAll[index].rewardAmount);
	}

	function viewCountStakesByDay(uint256 dayNumber) public view returns (uint256 _stakesCount, uint256 _stakedTokenAmount) {
		return(_countStakesByDay[dayNumber].stakesCount, _countStakesByDay[dayNumber].stakedTokenAmount);
	}

	function getDayNumber(uint256 timestamp) public pure returns (uint256) {
		return timestamp / 1 days;
	}

	function getCurrentDayNumber() public view returns (uint256) {
		return getCurrentTime() / 1 days;
	}

	function calcRewardByIndex(address user, uint256 index, uint256 shiftTime) public view returns
		(uint256 reward, uint256 lastTime) {
		(uint256 _startTime, uint256 _endTime, uint256 _lastRewardTime, uint256 amount) = viewUserStakeAny(user, index);
		(uint256 _daysCount, uint256 _startDayNumber) = getRewardDayData(_startTime, _endTime, _lastRewardTime, shiftTime);

		if (_daysCount > 0) {
			reward = calcReward(_daysCount, _startDayNumber, amount);
			if (_lastRewardTime == 0) {
				lastTime = _startTime + (1 days) * _daysCount;
			} else {
				lastTime = _lastRewardTime + (1 days) * _daysCount;
			}
		} else {
			reward = 0;
		}
	}

	function calcReward(uint256 dayCount, uint256 startDay, uint256 amount) private view returns (uint256 reward) {
		for (uint256 i = 0; i < dayCount; i++) {
			reward += getDailyAmount(startDay + i, amount);
		}
	}

	function getDailyAmount(uint256 startDay, uint256 amount) private view returns (uint256 dailyAmount) {
		(, uint256 _currentTokenAmount) = getCurrentCountStakes(startDay);
		if(_currentTokenAmount > 0) {
			dailyAmount = amount  * getRewardTokenAmount(startDay) / _currentTokenAmount;
		}
	}

	function getRewardTokenAmount(uint256 startDay) private view returns (uint256) {
		uint256 index = 0;
		ChangeRewardToken[] memory memChangeRewardTokenAll = changeRewardTokenAll;

		while(index < memChangeRewardTokenAll.length) {
			if(startDay == memChangeRewardTokenAll[index].currentDayNumber) {
				return memChangeRewardTokenAll[index].rewardAmount;
			}
			if (startDay > memChangeRewardTokenAll[index].currentDayNumber) {
				index++;
			} else {
				return memChangeRewardTokenAll[index-1].rewardAmount;
			}
		}
		return memChangeRewardTokenAll[index-1].rewardAmount;
	}

	function getCurrentCountStakes(uint256 startDay) private view returns
	(uint256 currentStakesCount, uint256 currentTokenAmount) {
		if (_countStakesByDay[startDay].stakesCount > 0) {
			currentStakesCount = _countStakesByDay[startDay].stakesCount;
			currentTokenAmount = _countStakesByDay[startDay].stakedTokenAmount;
		} else {
			uint256 currentStartDay = startDay - 1;
			while(currentStakesCount == 0 && startedDayNumber <= currentStartDay) {
				currentStakesCount = _countStakesByDay[currentStartDay].stakesCount;
				currentTokenAmount = _countStakesByDay[currentStartDay].stakedTokenAmount;
				currentStartDay --;
			}
		}
	}

	function getRewardDayData(uint256 beginTime, uint256 finishTime, uint256 lastTime, uint256 shiftTime) private view
	    returns (uint256 dayCount, uint256 startDay) {
		uint256 currentTime = getCurrentTime() + shiftTime;
		if (currentTime > beginTime + MIN_STAKED_TIME) {
			if (lastTime > 0) {
				if (finishTime == 0) {
   					if (currentTime > lastTime + MIN_STAKED_TIME) { //ok
						return ((currentTime - lastTime - MIN_STAKED_TIME) / 1 days, getDayNumber(lastTime));
					} else { //ok
						return (0, getDayNumber(lastTime));
					}
				} else {
					if (lastTime >= finishTime) { //ok
						return (0, getDayNumber(lastTime));
					}
					if (currentTime > finishTime + MIN_STAKED_TIME) { //ok 11
						return ((finishTime - lastTime) / 1 days, getDayNumber(lastTime));
					} else { //ok 10
						return ((currentTime - (lastTime + MIN_STAKED_TIME)) / 1 days, getDayNumber(lastTime));
					}
				}
			} else {
				if (finishTime == 0) { //ok
					uint256 rewardDayCount = (currentTime - (beginTime + MIN_STAKED_TIME)) / 1 days;
					return (rewardDayCount, getDayNumber(beginTime));
				} else {
					if (currentTime > finishTime + MIN_STAKED_TIME) { //ok
						return ((finishTime - beginTime) / 1 days, getDayNumber(beginTime));
					} else { //ok
						return ((currentTime - (beginTime + MIN_STAKED_TIME)) / 1 days, getDayNumber(beginTime));
					}
				}
			}
		}
		return (0, getDayNumber(beginTime));
	}

	function addRewardFund(uint256 amount) public onlyOwner {
		require(amount != 0, 'INVALID_ZERO_AMOUNT');
		IERC20(STAKED_TOKEN).safeTransferFrom(_msgSender(), address(this), amount);
		emit AddRewardFund(_msgSender(), amount);
		totalAddedTokenForReward += amount;
	}

	function setRewardTokenByDay(uint256 newValue) public onlyOwner {
		rewardTokensByDay = newValue;
		logRewardTokenByDay(newValue);
	}

	function logRewardTokenByDay(uint256 newValue) internal {
		uint256 length = changeRewardTokenAll.length;
		uint256 currentDayNumber = getCurrentDayNumber();
		if (length > 0) {
			require(changeRewardTokenAll[length-1].currentDayNumber < currentDayNumber,
				'You can only change once a day');
			require(length < MAX_CHANGE_REWARD_TOKENS_BY_DAY_COUNT,
				'Already reached MAX_CHANGE_REWARD_TOKENS_BY_DAY_COUNT');
		}
		ChangeRewardToken memory changeRewardTokenOne = ChangeRewardToken(currentDayNumber, newValue);
		changeRewardTokenAll.push(changeRewardTokenOne);
		emit ChangeRewardTokenByDay(_msgSender(), newValue);
	}

	function setLastRewardTime(address user, uint256 index, uint256 newTime) internal {
		_staked[user][index].lastRewardTime = newTime;
	}

	function getCurrentTime() public view returns(uint256) {
		return block.timestamp;
	}
}