// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {

    uint256 public minDays;
    uint256 public maxDays;
    uint256 public minMultiply;
    uint256 public maxMultiply;
    uint256 public rewardVestingPeriod;
    uint256 public rewardPerYear;
    uint256 public startReward;
    uint256 public endReward;
    uint256 public startStaking;
    uint256 public endStaking;
    uint256 public totalStakedAmount;
    uint256 public totalWeightedStakedAmount;
    address public immutable token;

    mapping(address => mapping(uint256 => uint256)) public userStakedAmount;
    mapping(address => mapping(uint256 => uint256)) public userStakedStart;
    mapping(address => mapping(uint256 => uint256)) public userStakedPeriod;
    mapping(address => uint256) public userTotalStakedAmount;
    mapping(address => uint256) public userTotalWeightedStakedAmount;
    mapping(address => uint256) public userLastCollect;
    mapping(address => uint256) public userLastClaim;
    mapping(address => uint256) public userReward;
    mapping(address => uint256) public userRewardVesting; // Full amount of vesting
    mapping(address => uint256) public userStakedTime;

    event OnEnterStaking(uint256 amount, uint256 period, uint256 id);
    event OnClaimReward(uint256 amount);
    event OnUnlock(uint256 amount, uint256 id);
    event OnHarvest(uint256 amount);
    event OnSetMinDays(uint256 amount);
    event OnSetMaxDays(uint256 amount);
    event OnSetMinMultiple(uint256 amount);
    event OnSetMaxMultiple(uint256 amount);
    event OnSetRewardPerYear(uint256 amount);
    event OnSetRewardVesting(uint256 period);
    event OnSetStartReward(uint256 time);
    event OnSetEndReward(uint256 time);
    event OnSetStartStaking(uint256 time);
    event OnSetEndStaking(uint256 time);

    constructor(address _token){
        require(_token != address(0), "Zero address");
        token = _token;
        minDays = 15 * 24 * 60 * 60;
        maxDays = 90 * 24 * 60 * 60;
        minMultiply = 20000; // 2
        maxMultiply = 40000; // 4
        rewardVestingPeriod = 7 * 24 * 60 * 60;
        rewardPerYear =  9500000 * 10 ** 18;
        startReward = block.timestamp;
        endReward = block.timestamp + (90 * 24 * 60 * 60);
        startStaking = block.timestamp;
        endStaking = block.timestamp + (90 * 24 * 60 * 60);
    }

    function setMinDays (uint256 _min) external onlyOwner {
        minDays = _min;

        emit OnSetMinDays (_min);
    }

    function setMaxDays (uint256 _max) external onlyOwner {
        maxDays = _max;

        emit OnSetMaxDays (_max);
    }

    function setMinMultiple (uint256 _min) external onlyOwner {
        minMultiply = _min;

        emit OnSetMinMultiple (_min);
    }

    function setMaxMultiple (uint256 _max) external onlyOwner {
        maxMultiply = _max;

        emit OnSetMaxMultiple (_max);
    }

    function setRewardPerYear (uint256 _amount) external onlyOwner {
        rewardPerYear = _amount;

        emit OnSetRewardPerYear (_amount);
    }

    function setRewardVesting (uint256 _period) external onlyOwner {
        rewardVestingPeriod = _period;

        emit OnSetRewardVesting (_period);
    }

    function setStartReward (uint256 _time) external onlyOwner {
        require(_time > endReward);
        startReward = _time;

        emit OnSetStartReward (_time);
    }

    function setEndReward (uint256 _time) external onlyOwner {
        require(_time > startReward);
        endReward = _time;

        emit OnSetEndReward (_time);
    }

    function setStartStaking (uint256 _time) external onlyOwner {
        require(_time < endStaking);
        startStaking = _time;

        emit OnSetStartStaking (_time);
    }

    function setEndStaking (uint256 _time) external onlyOwner {
        require(_time > startStaking);
        endStaking = _time;

        emit OnSetEndStaking (_time);
    }

    function enterStaking (uint256 _amount, uint256 _period) external {
        require(block.timestamp >= startStaking, "Not start yet");
        require(block.timestamp <= endStaking, "Already ended");
        require(_period >= minDays, "Lower than min lock period");
        require(_period <= maxDays, "Higher than max lock period");
        if(userStakedTime[_msgSender()] == 0) {
            userLastCollect[_msgSender()] = block.timestamp;
        }
        userStakedTime[_msgSender()] += 1;
        require(userStakedAmount[_msgSender()][userStakedTime[_msgSender()]] == 0, "Error");
        userStakedAmount[_msgSender()][userStakedTime[_msgSender()]] = _amount;
        userStakedPeriod[_msgSender()][userStakedTime[_msgSender()]] = _period;
        userStakedStart[_msgSender()][userStakedTime[_msgSender()]] = block.timestamp;
        userTotalStakedAmount[_msgSender()] += _amount;
        userTotalWeightedStakedAmount[_msgSender()] += _amount * getMultiple(_msgSender(), userStakedTime[_msgSender()]) /10000;
        totalWeightedStakedAmount += _amount * getMultiple(_msgSender(), userStakedTime[_msgSender()]) / 10000;
        IERC20(token).transferFrom(_msgSender(), address(this), _amount);
        collectRewards();

        emit OnEnterStaking(_amount, _period, userStakedTime[_msgSender()]);
    }

    function harvest () public {
        collectRewards();
        userLastClaim[_msgSender()] = block.timestamp;

        emit OnHarvest(userReward[_msgSender()]);
    }

    function collectRewards () internal {
        userReward[_msgSender()] += rewardPending(_msgSender());
        userRewardVesting[_msgSender()] = userReward[_msgSender()];
        userLastCollect[_msgSender()] = block.timestamp;
    }

    function rewardPending(address _adr) public view returns (uint256) {
        uint256 _rewards;
        _rewards = userTotalWeightedStakedAmount[_adr] * (block.timestamp - userLastCollect[_adr]) * rewardPerYear / (totalWeightedStakedAmount * (365*24*60*60));
        return _rewards;
    }

    function claimReward () public {
        uint256 claimAmount = getClaimable (_msgSender());
        userReward[_msgSender()] -= claimAmount;

        IERC20(token).transfer(_msgSender(), claimAmount);
        userLastClaim[_msgSender()] = block.timestamp;

        emit OnClaimReward(claimAmount);
    }

    function unlockStaking (uint256 _id) external {
        require(getLockedStatus(_msgSender(), _id) == 1, "Cannot unlock");
        require(userStakedAmount[_msgSender()][userStakedTime[_msgSender()]] == 0, "Not valid");
        IERC20(token).transfer(_msgSender(), userStakedAmount[_msgSender()][_id]);
        userStakedAmount[_msgSender()][_id] = 0;
        collectRewards();

        emit OnUnlock (userStakedAmount[_msgSender()][_id], _id);
    }

    function getClaimable (address _adr) public view returns (uint256) {
        uint256 claimAmount;
        claimAmount = (block.timestamp - userLastClaim[_msgSender()]) * userRewardVesting[_msgSender()] / rewardVestingPeriod;
        if (claimAmount > userReward[_msgSender()]) {
            claimAmount = userReward[_msgSender()];
        }

        return claimAmount;
    }

    function getMultiple(address _adr, uint256 _id) public view returns (uint256) {
        uint256 _multiple;
        _multiple = minMultiply + ((userStakedPeriod[_adr][_id]-minDays)*(maxMultiply-minMultiply)/(maxDays-minDays));

        return _multiple;
    }

    function getSingleReward(address _adr, uint256 _id) public view returns (uint256) {
        uint256 _rewards;
        _rewards = userStakedAmount[_adr][_id] * getMultiple(_adr, _id) * (block.timestamp - userLastCollect[_adr]) * rewardPerYear / (totalWeightedStakedAmount * (365*24*60*60) * 10000);

        return _rewards;
    }

    function getLockedStatus (address _adr, uint256 _id) public view returns (uint256) {
        uint256 status;
        if (block.timestamp >= userStakedStart[_adr][_id] + userStakedPeriod[_adr][_id]) {
            if (userStakedAmount[_adr][_id] == 0) {
                status = 2;
            } else {
                status = 1;
            }
        }else{
            status = 0;
        }

        return status;
    }
}

// SPDX-License-Identifier: MIT

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