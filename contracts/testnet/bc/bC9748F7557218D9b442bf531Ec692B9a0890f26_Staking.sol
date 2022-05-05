// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol';

contract Staking is Ownable {
    using SafeMath for uint256;

    struct Deposit {
        uint256 tokenAmount;
        uint256 weight;
        uint256 lockedUntil;
        uint256 rewardDebt;
        uint256 rewardDebtAlt;
    }

    struct UserInfo {
        uint256 tokenAmount;
        uint256 totalWeight;
        uint256 totalRewardsClaimed;
        uint256 totalRewardsClaimedAlt;
        Deposit[] deposits;
    }

    uint256 public constant ONE_DAY = 1 days;
    uint256 public constant MULTIPLIER = 1e12;
    
    uint256 public constant TOTAL_LOCK_MODES = 4;
    uint256 public constant LOCK_DUR_MIN = 7 * ONE_DAY;
    uint256 public constant LOCK_DUR_MID = 14 * ONE_DAY;
    uint256 public constant LOCK_DUR_MAX = 31 * ONE_DAY;

    uint256 public accTokenPerUnitWeight; // Accumulated TKNs per weight, times MULTIPLIER.
    uint256 public accTokenPerUnitWeightAlt; // Accumulated TKNAlt per weight, times MULTIPLIER.

    // total locked amount across all users
    uint256 public usersLockingAmount;
    // total locked weight across all users
    uint256 public usersLockingWeight;

    // The staking and reward token
    IERC20 public immutable token;
    // The alt reward token
    IERC20 public immutable tokenAlt;

    // the reward rates
    uint256 public rateMin;
    uint256 public rateMid;
    uint256 public rateMax;

    // The accounting of unclaimed TKN rewards
    uint256 public unclaimedTokenRewards;
    uint256 public unclaimedTokenRewardsAlt;

    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 rewardAmount, uint256 rewardAmountAlt);
    event RatesUpdated(uint256 rateMin, uint256 rateMid, uint256 rateMax);

    constructor(
        IERC20 _token,
        IERC20 _tokenAlt,
        uint256 _rateMin,
        uint256 _rateMid,
        uint256 _rateMax
    ) public {
        token = _token;
        tokenAlt = _tokenAlt;

        rateMin = _rateMin;
        rateMid = _rateMid;
        rateMax = _rateMax;
    }

    // Returns total staked token balance for the given address
    function balanceOf(address _user) external view returns (uint256) {
        return userInfo[_user].tokenAmount;
    }

    // Returns total staked token weight for the given address
    function weightOf(address _user) external view returns (uint256) {
        return userInfo[_user].totalWeight;
    }

    // Returns total claimed tokens of type 1 for the given address
    function totalClaimed(address _user) external view returns (uint256) {
        return userInfo[_user].totalRewardsClaimed;
    }

    // Returns total claimed tokens of type Alt for the given address
    function totalClaimedAlt(address _user) external view returns (uint256) {
        return userInfo[_user].totalRewardsClaimedAlt;
    }

    // Returns information on the given deposit for the given address
    function getDeposit(address _user, uint256 _depositId) external view returns (uint256, uint256, uint256, uint256, uint256) {
        Deposit storage stakeDeposit = userInfo[_user].deposits[_depositId];
        return (stakeDeposit.tokenAmount, stakeDeposit.weight, stakeDeposit.lockedUntil, stakeDeposit.rewardDebt, stakeDeposit.rewardDebtAlt);
    }

    // Returns number of deposits for the given address. Allows iteration over deposits.
    function getDepositsLength(address _user) external view returns (uint256) {
        return userInfo[_user].deposits.length;
    }

    function getPendingRewardOf(address _staker, uint256 _depositId) external view returns(uint256, uint256) {
        UserInfo storage user = userInfo[_staker];
        Deposit storage stakeDeposit = user.deposits[_depositId];

        uint256 _amount = stakeDeposit.tokenAmount;
        uint256 _weight = stakeDeposit.weight;
        uint256 _rewardDebt = stakeDeposit.rewardDebt;
        uint256 _rewardDebtAlt = stakeDeposit.rewardDebtAlt;

        // calculate reward upto current block
        uint256 tokenReward = token.balanceOf(address(this)) - usersLockingAmount - unclaimedTokenRewards;
        uint256 _accTokenPerUnitWeight = accTokenPerUnitWeight + (tokenReward * MULTIPLIER) / usersLockingWeight;
        uint256 _rewardAmount = ((_weight * _accTokenPerUnitWeight) / MULTIPLIER) - _rewardDebt;

        uint256 tokenRewardAlt = tokenAlt.balanceOf(address(this)) - unclaimedTokenRewardsAlt;
        uint256 _accTokenPerUnitWeightAlt = accTokenPerUnitWeightAlt + (tokenRewardAlt * MULTIPLIER) / usersLockingWeight;
        uint256 _rewardAmountAlt = ((_weight * _accTokenPerUnitWeightAlt) / MULTIPLIER) - _rewardDebtAlt;

        return (_rewardAmount, _rewardAmountAlt);
    }

    function getUnlockSpecs(uint256 _amount, uint256 _lockMode) public view returns(uint256 lockUntil, uint256 weight) {
        require(_lockMode < TOTAL_LOCK_MODES, "Staking: Invalid lock mode");

        if(_lockMode == 0) {
            // 0 : no lock
            return (now256(), _amount);
        }
        else if(_lockMode == 1) {
            // 1 : 7-day lock
            return (now256() + LOCK_DUR_MIN, (_amount * (100 + rateMin)) / 100);
        }
        else if(_lockMode == 2) {
            // 2 : 14-day lock
            return (now256() + LOCK_DUR_MID, (_amount * (100 + rateMid)) / 100);
        }

        // 3 : 31-day lock
        return (now256() + LOCK_DUR_MAX, (_amount * (100 + rateMax)) / 100);
    }

    function now256() public view returns (uint256) {
        // return current block timestamp
        return block.timestamp;
    }

    function updateRates(uint256 _rateMin, uint256 _rateMid, uint256 _rateMax) external onlyOwner {
        require(_rateMin < 100, "Staking: Invalid rate");
        require(_rateMid < 100, "Staking: Invalid rate");
        require(_rateMax < 100, "Staking: Invalid rate");
        rateMin = _rateMin;
        rateMid = _rateMid;
        rateMax = _rateMax;

        emit RatesUpdated(_rateMin, _rateMid, _rateMax);
    }

    // Added to support recovering lost tokens that find their way to this contract
    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(token), "TKNStaking: Cannot withdraw the staking token");
        require(_tokenAddress != address(tokenAlt), "TKNStaking: Cannot withdraw the rewards token");
        IERC20(_tokenAddress).transfer(msg.sender, _tokenAmount);
    }

    // Update reward variables
    function sync() external {
        _sync();
    }

    // Stake tokens
    function stake(uint256 _amount, uint256 _lockMode) external {
        _stake(msg.sender, _amount, _lockMode);
    }

    // Unstake tokens and claim rewards
    function unstake(uint256 _depositId) external {
        _unstake(msg.sender, _depositId, true);
    }

    // Claim rewards
    function claimRewards(uint256 _depositId) external {
        _claimRewards(msg.sender, _depositId);
    }

    function claimRewardsBatch(uint256[] calldata _depositIds) external {
        for(uint256 i = 0; i < _depositIds.length; i++) {
            _claimRewards(msg.sender, _depositIds[i]);
        }
    }

    // TODO
    function autoBuyUsingRewards(uint256[] calldata _depositIds) external {
        // buys SQDI with all BUSD rewards earned by the user, and stakes them
    }

    // Unstake tokens withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _depositId) external {
        _unstake(msg.sender, _depositId, false);
    }

    function _sync() internal {
        uint256 _weightLocked = usersLockingWeight;
        if (_weightLocked == 0) {
            return;
        }

        uint256 tokenReward = token.balanceOf(address(this)) - usersLockingAmount - unclaimedTokenRewards;
        unclaimedTokenRewards += tokenReward;
        accTokenPerUnitWeight += (tokenReward * MULTIPLIER) / _weightLocked;

        uint256 tokenRewardAlt = tokenAlt.balanceOf(address(this)) - unclaimedTokenRewardsAlt;
        unclaimedTokenRewardsAlt += tokenRewardAlt;
        accTokenPerUnitWeightAlt += (tokenRewardAlt * MULTIPLIER) / _weightLocked;
    }

    function _stake(address _staker, uint256 _userAmount, uint256 _lockMode) internal {
        _sync();

        UserInfo storage user = userInfo[_staker];

        uint256 _amount = _transferTokenFrom(address(_staker), address(this), _userAmount);
        require(_amount > 0, "TKNStaking: Deposit amount is 0");

        (uint256 lockUntil, uint256 stakeWeight) = getUnlockSpecs(_amount, _lockMode);

        // create and save the deposit (append it to deposits array)
        Deposit memory deposit =
            Deposit({
                tokenAmount: _amount,
                weight: stakeWeight,
                lockedUntil: lockUntil,
                rewardDebt: (stakeWeight*accTokenPerUnitWeight) / MULTIPLIER,
                rewardDebtAlt: (stakeWeight*accTokenPerUnitWeightAlt) / MULTIPLIER
            });
        // deposit ID is an index of the deposit in `deposits` array
        user.deposits.push(deposit);

        user.tokenAmount += _amount;
        user.totalWeight += stakeWeight;

        // update global variable
        usersLockingWeight += stakeWeight;
        usersLockingAmount += _amount;

        emit Staked(_staker, _amount);
    }

    function _unstake(address _staker, uint256 _depositId, bool _sendRewards) internal {
        UserInfo storage user = userInfo[_staker];
        Deposit storage stakeDeposit = user.deposits[_depositId];

        uint256 _amount = stakeDeposit.tokenAmount;
        uint256 _weight = stakeDeposit.weight;
        uint256 _rewardDebt = stakeDeposit.rewardDebt;
        uint256 _rewardDebtAlt = stakeDeposit.rewardDebtAlt;

        require(_amount > 0, "TKNStaking: Deposit amount is 0");
        require(now256() > stakeDeposit.lockedUntil, "TKNStaking: Deposit not unlocked yet");

        if(_sendRewards) {
            _sync();
        }

        uint256 _rewardAmount = ((_weight * accTokenPerUnitWeight) / MULTIPLIER) - _rewardDebt;
        uint256 _rewardAmountAlt = ((_weight * accTokenPerUnitWeightAlt) / MULTIPLIER) - _rewardDebtAlt;

        // update user record
        user.tokenAmount -= _amount;
        user.totalWeight = user.totalWeight - _weight;
        user.totalRewardsClaimed += _rewardAmount;
        user.totalRewardsClaimedAlt += _rewardAmountAlt;

        // update global variable
        usersLockingWeight -= _weight;
        usersLockingAmount -= _amount;
        unclaimedTokenRewards -= _rewardAmount;
        unclaimedTokenRewardsAlt -= _rewardAmountAlt;

        uint256 tokenToSend = _amount;
        if(_sendRewards) {
            // add rewards
            tokenToSend += _rewardAmount;
            _safeTokenTransferAlt(_staker, _rewardAmountAlt);
            emit Claimed(_staker, _rewardAmount, _rewardAmountAlt);
        }

        delete user.deposits[_depositId];

        // return tokens back to holder
        _safeTokenTransfer(_staker, tokenToSend);
        emit Unstaked(_staker, _amount);
    }

    function _claimRewards(address _staker, uint256 _depositId) internal {
        UserInfo storage user = userInfo[_staker];
        Deposit storage stakeDeposit = user.deposits[_depositId];

        uint256 _amount = stakeDeposit.tokenAmount;
        uint256 _weight = stakeDeposit.weight;
        uint256 _rewardDebt = stakeDeposit.rewardDebt;
        uint256 _rewardDebtAlt = stakeDeposit.rewardDebtAlt;

        require(_amount > 0, "TKNStaking: Deposit amount is 0");
        _sync();

        uint256 _rewardAmount = ((_weight * accTokenPerUnitWeight) / MULTIPLIER) - _rewardDebt;
        uint256 _rewardAmountAlt = ((_weight * accTokenPerUnitWeightAlt) / MULTIPLIER) - _rewardDebtAlt;

        // update stakeDeposit record
        stakeDeposit.rewardDebt += _rewardAmount;
        stakeDeposit.rewardDebtAlt += _rewardAmountAlt;

        // update user record
        user.totalRewardsClaimed += _rewardAmount;
        user.totalRewardsClaimedAlt += _rewardAmountAlt;

        // update global variable
        unclaimedTokenRewards -= _rewardAmount;
        unclaimedTokenRewardsAlt -= _rewardAmountAlt;

        // return tokens back to holder
        _safeTokenTransfer(_staker, _rewardAmount);
        _safeTokenTransferAlt(_staker, _rewardAmountAlt);
        emit Claimed(_staker, _rewardAmount, _rewardAmountAlt);
    }

    function _transferTokenFrom(address _from, address _to, uint256 _value) internal returns (uint256) {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.transferFrom(_from, _to, _value);
        return token.balanceOf(address(this)) - balanceBefore;
    }

    // Safe token transfer function, just in case if rounding error causes contract to not have enough TKN.
    function _safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            IERC20(token).transfer(_to, tokenBal);
        } else {
            IERC20(token).transfer(_to, _amount);
        }
    }

    // Safe token transfer function, just in case if rounding error causes contract to not have enough TKN.
    function _safeTokenTransferAlt(address _to, uint256 _amount) internal {
        uint256 tokenBal = tokenAlt.balanceOf(address(this));
        if (_amount > tokenBal) {
            IERC20(tokenAlt).transfer(_to, tokenBal);
        } else {
            IERC20(tokenAlt).transfer(_to, _amount);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.4.0;

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
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}