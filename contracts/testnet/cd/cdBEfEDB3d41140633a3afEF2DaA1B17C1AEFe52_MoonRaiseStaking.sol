pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MoonRaiseStaking is Ownable {
    IERC20 public _mrt;
    IERC20 public _lpToken;

    uint256 public _rateLP;
    uint256 public _rateApr; //apr = _rateApr/_zoom
    uint256 public _tvlMRT; // total MRT lock
    uint256 public _tvlLP; // total LP lock
    uint256 public _zoom;
    uint256 public _minTimeUnLock;
    uint256 public _minTimeStake;
    uint256 public _maxTimeStake;
    uint256 public _baseTimeStake;
    uint256 public _blockPerDay;

    address public _disRewardWallet;

    struct StakerMRT {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 sMRT;
        uint256 rewardPerBlock;
    }

    struct StakerLP {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 sMRT;
        uint256 rewardPerBlock;
    }

    mapping(address => StakerMRT[]) public stakerMRTs;
    mapping(address => StakerLP[]) public stakerLPs;

    constructor(
        IERC20 mrt,
        IERC20 lp,
        address wallet
    ) public {
        _mrt = mrt;
        _lpToken = lp;
        _disRewardWallet = wallet;
        _rateLP = 4;
        _rateApr = 5000;
        _minTimeUnLock = 7 days;
        _minTimeStake = 8 days;
        _maxTimeStake = 730 days;
        _baseTimeStake = 365 days;
        _blockPerDay = 28800;
        _zoom = 10000;
    }

    function setRateLp(uint256 newRate) public onlyOwner {
        _rateLP = newRate;
    }

    function setRateApr(uint256 newRate) public onlyOwner {
        _rateApr = newRate;
    }

    function setDistributionWallet(address wallet) public onlyOwner {
        _disRewardWallet = wallet;
    }

    function setMinTimeUnlock(uint256 time) public onlyOwner {
        _minTimeUnLock = time;
    }

    function setMinTimeStake(uint256 time) public onlyOwner {
        _minTimeStake = time;
    }

    function setMrtToken(IERC20 token) public onlyOwner {
        _mrt = token;
    }

    function setLpToken(IERC20 token) public onlyOwner {
        _lpToken = token;
    }

    function stakeMRT(uint256 amount, uint256 time) public {
        require(time >= _minTimeStake, "not enough minimum time stake");
        require(_lpToken.balanceOf(msg.sender) >= amount, "not enough balance");
        require(
            time <= _maxTimeStake,
            "stake time must smaller than _maxTimeStake"
        );
        uint256 sMRT = (amount * time) / _baseTimeStake;
        _mrt.transferFrom(msg.sender, address(this), amount);
        uint256 rewardPerBlock = getRewardPerYear(sMRT) /
            _baseTimeStake /
            _blockPerDay; 
        StakerMRT memory newStake = StakerMRT(
            amount,
            block.timestamp,
            block.timestamp + time,
            sMRT,
            rewardPerBlock
        );

        stakerMRTs[msg.sender].push(newStake);
        _tvlMRT += amount;
    }

    function stakeLP(uint256 amount, uint256 time) public {
        require(time >= _minTimeStake, "not emough minimum time stake");
        require(_lpToken.balanceOf(msg.sender) >= amount, "not enough balance");
        require(
            time <= _maxTimeStake,
            "stake time must smaller than _maxTimeStake"
        );
        uint256 sMRT = ((amount * time) * _rateLP) / _baseTimeStake;
        _mrt.transferFrom(msg.sender, address(this), amount);
        uint256 rewardPerBlock = getRewardPerYear(sMRT) /
            _baseTimeStake /
            _blockPerDay;
        StakerLP memory newStake = StakerLP(
            amount,
            block.timestamp,
            block.timestamp + time,
            sMRT,
            rewardPerBlock
        );

        stakerLPs[msg.sender].push(newStake);
        _tvlLP += amount;
    }

    function unlockMRT(uint256 stakeIndex) public {
        require(
            stakerMRTs[msg.sender][stakeIndex].startTime + _minTimeUnLock <
                block.timestamp,
            "require minimum time more than _minTimeUnLock"
        );
        uint256 reward = 0;
        if (block.timestamp >= stakerMRTs[msg.sender][stakeIndex].endTime) {
            reward =
                ((block.timestamp -
                    stakerMRTs[msg.sender][stakeIndex].startTime) *
                    stakerMRTs[msg.sender][stakeIndex].rewardPerBlock) /
                3;
        }
        if (
            _mrt.balanceOf(address(this)) >=
            stakerMRTs[msg.sender][stakeIndex].amount + reward
        ) {
            _mrt.transfer(
                msg.sender,
                stakerMRTs[msg.sender][stakeIndex].amount + reward
            );
        } else {
            _mrt.transferFrom(
                _disRewardWallet,
                msg.sender,
                stakerMRTs[msg.sender][stakeIndex].amount + reward
            );
        }
        _tvlMRT -= stakerMRTs[msg.sender][stakeIndex].amount;
        delete stakerMRTs[msg.sender][stakeIndex];
    }

    function unlockLP(uint256 stakeIndex) public {
        require(
            stakerLPs[msg.sender][stakeIndex].startTime + _minTimeUnLock <
                block.timestamp,
            "require minimum time more than _minTimeUnLock"
        );
        uint256 reward = 0;
        if (block.timestamp >= stakerLPs[msg.sender][stakeIndex].endTime) {
            reward =
                ((block.timestamp -
                    stakerLPs[msg.sender][stakeIndex].startTime) *
                    stakerLPs[msg.sender][stakeIndex].rewardPerBlock) /
                3;

            if (_mrt.balanceOf(address(this)) >= reward) {
                _mrt.transfer(msg.sender, reward);
            } else {
                _mrt.transferFrom(_disRewardWallet, msg.sender, reward);
            }
        }

        _lpToken.transfer(msg.sender, stakerLPs[msg.sender][stakeIndex].amount);
        _tvlLP -= stakerLPs[msg.sender][stakeIndex].amount;
        delete stakerLPs[msg.sender][stakeIndex];
    }

    function getsMRT(address user) public view returns (uint256) {
        uint256 sMRT = 0;
        for (uint256 i = 0; i < stakerMRTs[user].length; i++) {
            sMRT += stakerMRTs[user][i].sMRT;
        }

        for (uint256 i = 0; i < stakerLPs[user].length; i++) {
            sMRT += stakerLPs[user][i].sMRT;
        }
        return sMRT;
    }

    function getAmountMRT(address user) public view returns (uint256) {
        uint256 mrt = 0;
        for (uint256 i = 0; i < stakerMRTs[user].length; i++) {
            mrt += stakerMRTs[user][i].amount;
        }
        return mrt;
    }

    function getAmountLP(address user) public view returns (uint256) {
        uint256 lp = 0;
        for (uint256 i = 0; i < stakerLPs[user].length; i++) {
            lp += stakerLPs[user][i].amount;
        }
        return lp;
    }

    function getRewardPerYear(uint256 sMRT) internal view returns (uint256) {
        uint256 reward = (sMRT * _rateApr) / _zoom;
        return reward;
    }

    function getEstimateRewardPerYear(address user)
        public
        view
        returns (uint256)
    {
        uint256 sMRT = getsMRT(user);
        return getRewardPerYear(sMRT);
    }

    function getInfoStakeMRT(address user, uint256 id)
        public
        view
        returns (StakerMRT memory)
    {
        return stakerMRTs[user][id];
    }

    function getLengthStakeMRT(address user) public view returns (uint256) {
        return stakerMRTs[user].length;
    }

    function getLengthStakeLP(address user) public view returns (uint256) {
        return stakerLPs[user].length;
    }

    function getStakeMRTs(address user)
        public
        view
        returns (StakerMRT[] memory)
    {
        return stakerMRTs[user];
    }

    function getStakeLPs(address user) public view returns (StakerLP[] memory) {
        return stakerLPs[user];
    }

    function getInfoStakeLP(address user, uint256 id)
        public
        view
        returns (StakerLP memory)
    {
        return stakerLPs[user][id];
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