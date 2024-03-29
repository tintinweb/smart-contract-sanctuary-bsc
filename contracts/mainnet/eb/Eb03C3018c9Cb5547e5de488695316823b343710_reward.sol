/**
 *Submitted for verification at BscScan.com on 2021-11-10
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

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
        assert(a == b * c + a % b);
        // There is no case in which this doesn't hold

        return c;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);
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
        assembly {size := extcodesize(account)}
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
        (bool success,) = recipient.call{value : amount}("");
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
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

    function addressToString(address _address) internal pure returns (string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for (uint256 i = 0; i < 20; i++) {
            _addr[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}

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
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IOwnable {
    function policy() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipPulled(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceManagement() public virtual override onlyPolicy {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_)
    public
    virtual
    override
    onlyPolicy
    {
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed(_owner, newOwner_);
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require(msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner);
        _owner = _newOwner;
    }
}

interface IStaking {
    function stake(uint _amount, address _recipient) external returns (bool);

    function claim(address _recipient) external;
}

contract reward is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public epochInterval;
    uint256 public releaseInterval;
    uint256 public lastEpochId;
    uint256 public totalClaimReward;
    uint256 public totalRewardsIssued;
    address public rewardCoin;
    address public staking;



    mapping(address => bool) public bondList;
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => EpochInfo) public epochInfo;
    mapping(uint256 => mapping(address => uint256)) public epochForVal;
    mapping(uint256 => mapping(address => uint256)) public debt;

    struct UserInfo {
        uint256 updateTimestamp;
        uint256 updateLastEpochId;
        uint256 unclaimedReward;
        uint256 remainingReleaseTimestamp;
    }

    struct EpochInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 totalBond;
        uint256 reward;
        bool rewardFinish;
    }

    constructor(address _rewardCoin, uint256 _epochInterval, uint256 _releaseInterval, address [] memory _bondList, address _staking) {
        lastEpochId = 0;
        epochInterval = _epochInterval;
        releaseInterval = _releaseInterval;
        setEpochInfo(0, block.timestamp, block.timestamp.add(epochInterval), 0,true);
        rewardCoin = _rewardCoin;
        for (uint256 i = 0; i < _bondList.length; i++) {
            setBondList(_bondList[i], true);
        }
        staking = _staking;
    }

    function epochsInfo(uint256 _id) external view returns (uint256, uint256, uint256, uint256, bool){
        EpochInfo storage epoch = epochInfo[_id];
        return (epoch.startTime, epoch.endTime, epoch.totalBond, epoch.reward, epoch.rewardFinish);
    }

    function setEpochInfo(uint256 id, uint256 _startTime, uint256 _endTime, uint256 _totalBond, bool _rewardFinish) internal {
        EpochInfo storage epoch = epochInfo[id];
        epoch.startTime = _startTime;
        epoch.endTime = _endTime;
        epoch.totalBond = _totalBond;
        epoch.rewardFinish = _rewardFinish;
    }

    function setBondList(address _addr, bool _state) public onlyPolicy returns (bool) {
        bondList[_addr] = _state;
        return true;
    }

    function setEpochInterval(uint256 _val) public onlyPolicy returns (bool) {
        epochInterval = _val;
        return true;
    }

    function setReleaseInterval(uint256 _val) public onlyPolicy returns (bool) {
        releaseInterval = _val;
        return true;
    }

    function totalReward() view public returns (uint256) {
        return IERC20(rewardCoin).balanceOf(address(this)).add(totalClaimReward);
    }

    function nowEpochPendingReward_() view public returns (uint256) {
        return totalReward().sub(totalRewardsIssued, "005");
    }

    function nowEpochPendingReward() view public returns (uint256) {
        if (canNextEpoch()) {
            return nowEpochPendingReward_();
        } else {
            return 0;
        }
    }

    function canNextEpoch() view public returns (bool) {
        EpochInfo storage lastEpoch = epochInfo[lastEpochId];
        if (lastEpoch.endTime < block.timestamp && nowEpochPendingReward_() != 0) {//当前时间超过区间结束时间，并且该区间有奖励，才能跳到下一个区间
            return true;
        } else {
            return false;
        }
    }


    function clickBuyBond(address _user, uint256 _bondVal) public returns (bool) {
        require(bondList[msg.sender], "this msg sender not Bond");

        EpochInfo storage lastEpoch = epochInfo[lastEpochId];
        if (canNextEpoch() || lastEpoch.endTime > block.timestamp) {
            if (canNextEpoch()) {
                lastEpochId = lastEpochId.add(1);
                epochInfo[lastEpochId] = EpochInfo({
                totalBond : 0,
                rewardFinish : true,
                reward : nowEpochPendingReward_(),
                startTime : block.timestamp,
                endTime : block.timestamp.add(epochInterval)
                });
                totalRewardsIssued = totalRewardsIssued.add(nowEpochPendingReward_());
            }
            epochForVal[lastEpochId][_user] = epochForVal[lastEpochId][_user].add(_bondVal);
            epochInfo[lastEpochId].totalBond = epochInfo[lastEpochId].totalBond.add(_bondVal);

            userInfo[_user] = UserInfo({
            unclaimedReward : userReward(_user),
            updateLastEpochId : lastEpochId,
            updateTimestamp : block.timestamp,
            remainingReleaseTimestamp : releaseInterval
            });
        }
        return true;
    }

    function userPendingReward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        EpochInfo storage epoch = epochInfo[user.updateLastEpochId];
        EpochInfo storage lastEpoch = epochInfo[lastEpochId];
        if (user.updateLastEpochId > 0 && (user.updateLastEpochId != lastEpochId || lastEpoch.endTime < block.timestamp)) {//用户好久之前的操作，隔了好久的id
            return epochInfo[user.updateLastEpochId].reward.mul(epochForVal[user.updateLastEpochId][_user]).div(epoch.totalBond);
        }
        return 0;
    }

    function userReward(address _user) public view returns (uint256) {
        return userInfo[_user].unclaimedReward.add(userPendingReward(_user));
    }
    function claim(address _user) public returns (uint256 claimAmt) {
        if (userPendingReward(_user) > 0) {
            userInfo[_user].unclaimedReward = userReward(_user);
        }
        if (userInfo[_user].unclaimedReward > 0) {
            UserInfo memory info = userInfo[_user];
            uint256 throughTimestamp = block.timestamp.sub(info.updateTimestamp, "006");
            if (throughTimestamp < info.remainingReleaseTimestamp) {
                claimAmt = info.unclaimedReward.mul(throughTimestamp).div(info.remainingReleaseTimestamp, "003");
                userInfo[_user] = UserInfo({
                unclaimedReward : info.unclaimedReward.sub(claimAmt),
                updateLastEpochId : 0,
                updateTimestamp : block.timestamp,
                remainingReleaseTimestamp : info.remainingReleaseTimestamp.sub(throughTimestamp)
                });
            } else {
                claimAmt = info.unclaimedReward;
                delete userInfo[_user];
            }
            IERC20(rewardCoin).safeTransfer(_user, claimAmt);
            totalClaimReward = totalClaimReward.add(claimAmt);
        }
        return claimAmt;
    }

    function claim_(address _user) public view returns (uint256, uint256, uint256) {
        uint256 user_unclaimedReward = userReward(_user);
        uint256 throughTimestamp = block.timestamp.sub(userInfo[_user].updateTimestamp, "006");
        uint256 claimAmt = 0;
        if (throughTimestamp < userInfo[_user].remainingReleaseTimestamp) {
            claimAmt = user_unclaimedReward.mul(throughTimestamp).div(userInfo[_user].remainingReleaseTimestamp, "003");
        } else {
            claimAmt = user_unclaimedReward;
        }
        return (user_unclaimedReward, claimAmt, user_unclaimedReward.sub(claimAmt, "011"));
    }

    function claimAndStake(address _user) public returns (bool){
        uint256 claimAmt = claim(_user);

        IERC20(rewardCoin).safeApprove(staking, claimAmt);
        IStaking(staking).stake(claimAmt, _user);
        IStaking(staking).claim(_user);

        return true;
    }
}