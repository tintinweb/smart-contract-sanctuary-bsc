/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// 
contract SaudiStaking is Ownable {
    struct StakeContext {
        uint256 amountStaked;
        uint256 stakedTime;
        uint256 unlockTime;
    }

    struct UserContext {
        uint256 amountUnlocked;
        uint256 totalStaked;
        uint256 unlockIndex;
        StakeContext[] stakes;

        int256 defReward;
        int256 claimedReward;
    }

    event Stake(address user, uint256 amount, uint256 until);
    event UnStake(address user, address to, uint256 amount);
    event Claim(address user, uint256 amount);

    IERC20 public immutable saudiDaoToken;

    uint256 public vestingPeriod;
    mapping(address => UserContext) stakingInfo;
    address public votingAddress;
    address public stakingPool;
    uint256 public constant REWARD_RESOLUTION = 10 ** 12;
    uint256 public rewardRate; // reward amount per token per second in resolution

    modifier onlyVoting() {
        require(msg.sender == votingAddress, "Not voting contract");
        _;
    }

    constructor(address _token, address _stakingPool, uint256 _rewardRate) Ownable() {
        require(_token.code.length > 0, "Not a valid token contract");

        saudiDaoToken = IERC20(_token);
        stakingPool = _stakingPool;
        vestingPeriod = 7 days;
        rewardRate = _rewardRate;
    }

    function updateVotingContract(address _voting) external onlyOwner {
        require(_voting.code.length > 0, "Not a valid voting contract");
        votingAddress = _voting;
    }

    function updateRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    function updateStakingPool(address _stakingPool) external onlyOwner {
        stakingPool = _stakingPool;
    }

    function getUnlockedClaimableAmount(address _user) external view returns (uint256, int256) {
        UserContext storage _uc = stakingInfo[_user];
        uint256 i;
        uint256 _amountToBeUnlocked = 0;
        int256 _defReward = 0;

        for (i = _uc.unlockIndex; i < _uc.stakes.length; i ++) {
            StakeContext storage _sc = _uc.stakes[i];
            if (_sc.stakedTime >= block.timestamp) break;

            if (_sc.unlockTime == 0) continue;

            if (_sc.unlockTime <= block.timestamp) {
                _amountToBeUnlocked += _sc.amountStaked;
                _defReward += int256(_sc.unlockTime * _sc.amountStaked);
            }
        }

        _amountToBeUnlocked += _uc.amountUnlocked;
        _defReward += _uc.defReward;

        int256 claimableAmount = int256(rewardRate) * (int256(block.timestamp * _amountToBeUnlocked) - _defReward) / int256(REWARD_RESOLUTION) - _uc.claimedReward;

        return (_amountToBeUnlocked, claimableAmount);
    }

    function getStakedAmount(address _user) external view returns (uint256) {
        UserContext storage _uc = stakingInfo[_user];
        return _uc.totalStaked;
    }

    function updateUserContext(address _user) internal {
        UserContext storage _uc = stakingInfo[_user];
        uint256 i;
        uint256 _amountToBeUnlocked = 0;
        int256 _defReward = 0;
        uint256 nextUnlockIndex = 0;

        for (i = _uc.unlockIndex; i < _uc.stakes.length; i ++) {
            StakeContext storage _sc = _uc.stakes[i];
            if (_sc.stakedTime >= block.timestamp) break;

            if (_sc.unlockTime == 0) continue;

            if (_sc.unlockTime <= block.timestamp) {
                _amountToBeUnlocked += _sc.amountStaked;
                _defReward += int256(_sc.unlockTime * _sc.amountStaked);
                delete _uc.stakes[i];
            } else if (nextUnlockIndex == 0) {
                nextUnlockIndex = i;
            }
        }

        _uc.unlockIndex = nextUnlockIndex;
        _uc.amountUnlocked += _amountToBeUnlocked;
        _uc.defReward += _defReward;
    }

    function updateVestingPeriod(uint256 _period) external onlyOwner {
        require(_period >= 1 days && _period <= 15 days, "Period is not valid");
        vestingPeriod = _period;
    }

    function stake(uint256 _amount) external {
        address _sender = msg.sender;
        UserContext storage _uc = stakingInfo[_sender];

        updateUserContext(_sender);

        require(_amount > 0, "No staking amount supposed");

        uint256 oldBal = saudiDaoToken.balanceOf(_sender);
        saudiDaoToken.transferFrom(_sender, address(this), _amount);
        _amount = oldBal - saudiDaoToken.balanceOf(_sender);

        _uc.stakes.push(StakeContext({
            amountStaked: _amount,
            stakedTime: block.timestamp,
            unlockTime: block.timestamp + vestingPeriod
        }));

        _uc.totalStaked += _amount;

        emit Stake(_sender, _amount, block.timestamp + vestingPeriod);
    }

    function unstake(address _to, uint256 _amount) external {
        address _sender = msg.sender;
        UserContext storage _uc = stakingInfo[_sender];

        updateUserContext(_sender);
        _claim(_sender);

        require(_amount > 0, "No amount to unstake supposed");
        require(_uc.amountUnlocked >= _amount, "Not enough amount to unstake");

        saudiDaoToken.transfer(_to, _amount);
        _uc.amountUnlocked -= _amount;
        _uc.defReward -= int256(block.timestamp * _amount);
        _uc.totalStaked -= _amount;

        emit UnStake(_sender, _to, _amount);
    }

    function vote(address _voter, uint256 _amount) external onlyVoting {
        UserContext storage _uc = stakingInfo[_voter];

        updateUserContext(_voter);
        _claim(_voter);

        require(_amount > 0, "No amount to vote supposed");
        require(_uc.amountUnlocked >= _amount, "Not enough amount to vote");

        saudiDaoToken.transfer(votingAddress, _amount);
        _uc.amountUnlocked -= _amount;
        _uc.defReward -= int256(block.timestamp * _amount);
        _uc.totalStaked -= _amount;
    }

    function claim() external {
        address _sender = msg.sender;
        updateUserContext(_sender);
        _claim(_sender);
    }

    function _claim(address _user) internal {
        UserContext storage _uc = stakingInfo[_user];
        int256 targetClaimedAmount = int256(rewardRate) * (int256(block.timestamp * _uc.amountUnlocked) - _uc.defReward) / int256(REWARD_RESOLUTION);
        int256 claimableAmount = targetClaimedAmount - _uc.claimedReward;

        _uc.claimedReward = targetClaimedAmount;

        saudiDaoToken.transferFrom(stakingPool, _user, uint256(claimableAmount));

        emit Claim(_user, uint256(claimableAmount));
    }
}