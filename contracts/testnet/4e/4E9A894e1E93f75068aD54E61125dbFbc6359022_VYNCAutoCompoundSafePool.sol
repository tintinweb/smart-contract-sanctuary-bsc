pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IVyncStakingManager.sol";
import "./interfaces/IVyncReferral.sol";
import "./library/UserInfo.sol";

contract VYNCAutoCompoundSafePool is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using UserInfo for UserInfo.Data;
    IVyncReferral public vyncReferral;
    IERC20 public vync = IERC20(0xee1ae38BE4Ce0074C4A4A8DC821CC784778f378c);
    IVyncStakingManager public vyncStakingManager = IVyncStakingManager(0x07A42C3e5066D3fb6905DDe9412822Ad9e8dD5aF);
    address public router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint256 public constant VYNC_SINGLE_PID = 1;
    mapping(address => UserInfo.Data) public userInfo;
    uint256 public totalSupply;
    uint256 public rewardPerTokenStored;
    uint256 public lastPoolReward;
    uint256 public lastUpdatePoolReward;
    uint256 public referralCommissionRate;
    uint256 public percentFeeForCompounding;

    modifier updateReward(address account) {
        // due to harvest lockup, lastPoolReward needs wait 8 hours to be updated
        // so we use condition to avoid gas wasting
        if(lastPoolReward != lastUpdatePoolReward) {
            rewardPerTokenStored = rewardPerToken();
            lastUpdatePoolReward = lastPoolReward;
            // need update rewardPerTokenStored to get different rewards
            if(account != address(0)){
                userInfo[account].updateReward(earned(account), rewardPerTokenStored);
            }
        }
        _;
    }

    event Deposit(address account, uint256 amount);
    event Withdraw(address account, uint256 amount);
    event Harvest(address account, uint256 amount);
    event Compound(address account, uint256 amount);
    event RewardPaid(address account, uint256 reward);
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );

    constructor() {
        approve();
    }

    function balanceOf(address user) public view returns(uint256) {
        return userInfo[msg.sender].amount;
    }

    function totalPoolRevenue() public view returns (uint256) {
        return totalPoolPendingRewards();
    }

    // rewards that ready to withdraw
    function totalPoolRewards() public view returns (uint256) {
        (uint256 depositedSinglePool,,,) = vyncStakingManager.userInfo(VYNC_SINGLE_PID, address(this));
        // total deposited sub 3% fees while withdrawn - total supply
        return depositedSinglePool.mul(97).div(100).sub(totalSupply).add(vync.balanceOf(address(this)));
    }

    function totalPoolPendingRewards() public view returns (uint256) {
        return vyncStakingManager.pendingVync(VYNC_SINGLE_PID, address(this));
    }

    // total user's rewards: pending + earned
    function pendingEarned(address account) public view returns(uint256) {
        return balanceOf(account).mul(
            pendingRewardPerToken()
            .sub(userInfo[account].rewardPerTokenPaid)
            .div(1e18)
            .add(userInfo[account].rewards)
        );
    }

    // total user's rewards ready to withdraw
    function earned(address account) public view returns(uint256) {
        return balanceOf(account).mul(
            rewardPerToken()
            .sub(userInfo[account].rewardPerTokenPaid)
            .div(1e18)
            .add(userInfo[account].rewards)
        );
    }

    function pendingRewardPerToken() public view returns(uint256) {
        return rewardPerToken().add(
            totalPoolPendingRewards().mul(1e18).div(totalSupply)
        );
    }

    function rewardPerToken() public view returns(uint256) {
        if(totalSupply == 0){
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add(
            (totalPoolRewards().sub(lastUpdatePoolReward)).mul(1e18).div(totalSupply)
        );
    }

    function updateVyncReferral(IVyncReferral _vyncReferral) external onlyOwner {
        vyncReferral = _vyncReferral;
    }

    function updateReferralCommissionRate(uint256 _rate) external onlyOwner {
        referralCommissionRate = _rate;
    }

    function updatePercentFeeForCompounding(uint256 _rate) external onlyOwner {
        percentFeeForCompounding = _rate;
    }

    function approve() public {
        vync.approve(address(vyncStakingManager), MAX_INT);
        vync.approve(router, MAX_INT);
    }

    function deposit(uint256 amount) external nonReentrant updateReward(msg.sender) {
        vync.transferFrom(msg.sender, address(this), amount);
        // cannot use amount due to 1% RFI fees on transfer token
        uint256 stakeAmount = vync.balanceOf(address(this));
        vyncStakingManager.deposit(VYNC_SINGLE_PID, stakeAmount, address(this));
        userInfo[msg.sender].deposit(stakeAmount);
        totalSupply = totalSupply.add(amount);
        emit Deposit(msg.sender, stakeAmount);
    }

    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(userInfo[msg.sender].amount >= amount, "insufficient balance");
        // 3% fees applied
        vyncStakingManager.withdraw(VYNC_SINGLE_PID, amount);
        uint256 amountLeft = vync.balanceOf(address(this));
        vync.transfer(msg.sender, amountLeft);
        userInfo[msg.sender].withdraw(amountLeft);
        totalSupply = totalSupply.sub(amount);
        emit Withdraw(msg.sender, amount);
    }

    function harvest() external {
        // function to harvest rewards
        uint256 reward = earned(msg.sender);
        if(reward > 0){
            userInfo[msg.sender].updateReward(0, 0);
            uint256 balanceOfThis = vync.balanceOf(address(this));
            (uint256 stakedAmount,,,) = vyncStakingManager.userInfo(VYNC_SINGLE_PID, address(this));
            uint256 reserveAmount = balanceOfThis.add(stakedAmount);
            if(balanceOfThis < reward){
                // cover 4 % fee
                vyncStakingManager.withdraw(VYNC_SINGLE_PID, reward.sub(balanceOfThis).mul(104).div(100));
            }
            vync.transfer(msg.sender, reward);
            payReferralCommission(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function compound() external {
        // function to compound for pool
        bool _canCompound = canCompound();
        if(_canCompound){
            uint256 balanceBefore = vync.balanceOf(address(this));
            vyncStakingManager.deposit(VYNC_SINGLE_PID, 0, address(this));
            uint256 amountCollected = vync.balanceOf(address(this)).sub(balanceBefore);
            uint256 rewardForCaller = amountCollected.mul(percentFeeForCompounding).div(100);
            uint256 rewardForPool = amountCollected.sub(rewardForCaller);
            // stake to VYNC pool
            vyncStakingManager.deposit(VYNC_SINGLE_PID, rewardForPool, address(this));
            vync.transfer(msg.sender, rewardForCaller);
            lastPoolReward = lastPoolReward.add(rewardForPool);
            emit Compound(msg.sender, rewardForPool);
        }
    }

    function canCompound() public view returns (bool) {
        return vyncStakingManager.canHarvest(VYNC_SINGLE_PID, address(this));
    }

    function payReferralCommission(address _user, uint256 _pending) internal {
        if(
            address(vyncStakingManager) != address(0)
            && referralCommissionRate > 0
        ){
            address referrer = vyncReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(
                10000
            );
            if (referrer != address(0) && commissionAmount > 0) {
                if(vync.balanceOf(address(this)) < commissionAmount){
                    vyncStakingManager.withdraw(VYNC_SINGLE_PID, commissionAmount);
                }
                vync.transfer(referrer, commissionAmount);
                vyncReferral.recordReferralCommission(
                    referrer,
                    commissionAmount
                );
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVyncStakingManager {
    function setDevAddress(address _devAddress) external;
    function pendingVync(uint256 _pid, address _user)
    external
    view
    returns (uint256);

    function canHarvest(uint256 _pid, address _user)
    external
    view
    returns (bool);

    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referrer
    ) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function poolInfo(uint256 _pid) external view returns (
        address lpToken,
        uint256 allocPoint,
        uint256 lastRewardBlock,
        uint256 accVyncPerShare,
        uint16 depositFeeBP,
        uint256 harvestInterval
    );

    function userInfo(uint256 _pid, address _user) external view returns (
        uint256 amount,
        uint256 rewardDebt,
        uint256 rewardLockedUp,
        uint256 nextHarvestUntil
    );

    function totalAllocPoint() external view returns (uint256);

    function vyncPerBlock() external view returns (uint256);



}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVyncReferral{

    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library UserInfo {
    using SafeMath for uint256;
    struct Data {
        uint256 amount;
        // packing slot
        uint256 rewards;
        uint256 rewardPerTokenPaid;
    }

    function deposit(
        UserInfo.Data storage data,
        uint256 amount
    ) internal {
        data.amount = data.amount.add(amount);
    }   

    function withdraw(
        UserInfo.Data storage data,
        uint256 amount
    ) internal {
        data.amount = data.amount.sub(amount);
    }

    function updateReward(
        UserInfo.Data storage data,
        uint256 rewards,
        uint256 rewardPerTokenPaid
    ) internal {
        data.rewards = rewards;
        data.rewardPerTokenPaid = rewardPerTokenPaid;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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