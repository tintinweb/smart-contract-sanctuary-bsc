/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: Unlicensed
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
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

contract LPTokenWrapper {
    using SafeMath for uint256;

    IERC20 public lpt;
    address public devlAddress;
    uint256 public totalFee;
    uint256 public fee = 2; //percent 2%

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) internal virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpt.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) internal virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        uint256 feeAmount = amount.mul(fee).div(100);
        totalFee = totalFee.add(feeAmount);
        lpt.transfer(msg.sender, amount.sub(feeAmount));
        lpt.transfer(devlAddress,feeAmount);
    }
}

interface ICommunityRelations {
    function setAccountLevel(address account, uint8 types) external;

    function getAccountLevel(address account) external view returns(uint8);

    function getInviter(address account) external view returns(address, uint8);
}

contract StakeRIGLPPool is LPTokenWrapper, Ownable {
    using SafeMath for uint256;

    address public velTokenAddress;
    address public rigTokenAddress;
    uint256 public totalReward = 1200000 * 10 ** 9;

    address public relationAddress;
    uint256 internal relationMax = 5;
    uint256 internal relationMin = 2;
    uint256 public claimRate = 1; //persent;

    uint256[] period = [30, 90, 180, 270, 360];
    uint256[] periodRewardRate = [16, 50, 100, 160, 200];
    mapping(uint256 => uint256) periodReward;

    struct StakeMap {
        uint256 amount;
        uint256 marketAmount;
        uint256 period;
        uint256 expirationTime;
        uint256 lastRewardTime;
        uint256 rewardStakePaid;
    }
    mapping(address => StakeMap[]) userStakeMaps;
    event Staked(address indexed user, uint256 amount, uint256 period);
    event Withdrawn(address indexed user, uint256 amount);
    event Reward(address indexed user, uint256 amount);

    modifier checkPeriod(uint256 _period) {
        bool isPeriod = false;
        for(uint256 i= 0; i < period.length; i++) {
            if(period[i] == _period) {
                isPeriod = true;
                break;
            }
                
        }
        require(isPeriod, "StakeRIGLPPool: Wrong cycle");
        _;
    }
    
    constructor(
        address _velTokenAddress,
        address _rigTokenAddress,
        address _lpTokenAddress,
        address _devlAddress
    ) {
        velTokenAddress = _velTokenAddress;
        lpt = IERC20(_lpTokenAddress);
        rigTokenAddress = _rigTokenAddress;
        devlAddress = _devlAddress;
        uint256 everyDayReward = totalReward.mul(77).div(uint256(12441600000000));
        for(uint256 i=0; i < period.length; i++) {
            periodReward[period[i]] = everyDayReward.mul(periodRewardRate[i]).div(100);
        }
    }

    function setVelTokenAddress(address _velTokenAddress) external onlyOwner {
        velTokenAddress = _velTokenAddress;
    }

    function setLpTokenAddress(address _lpTokenAddress) external onlyOwner {
         lpt = IERC20(_lpTokenAddress);
    }

    function setRelationAddress(address _relationAddress) external onlyOwner {
        relationAddress = _relationAddress;
    }

    function setDevlAddress(address _devlAddress) external onlyOwner {
        devlAddress = _devlAddress;
    }

    function setRigTokenAddress(address _rigTokenAddress) external onlyOwner {
        rigTokenAddress = _rigTokenAddress;
    }

    function setClaimRate(uint256 rate) external onlyOwner {
        claimRate = rate;
    }

    function stakeLp(uint256 _amount, uint256 _period) public checkPeriod(_period) {
        require(_amount > 0, 'StakeRIGLPPool: Cannot stake 0');
        super.stake(_amount);
        StakeMap memory stakeMap = StakeMap({
            amount: _amount,
            marketAmount: calculateRIGAmount(_amount),
            period: _period,
            expirationTime: block.timestamp.add(_period.mul(1 days)),
            lastRewardTime: block.timestamp,
            rewardStakePaid: 0
        });
        userStakeMaps[msg.sender].push(stakeMap);
        setRelation(msg.sender, 1);
        emit Staked(msg.sender, _amount, _period);
    }

    function withdrawLP(uint256 index) public {
        StakeMap[] storage userStakes = userStakeMaps[msg.sender];
        require(index < userStakes.length, "StakeRIGLPPool: ");
        uint256 withdrawAmount = 0;
        uint256 totalWithdrwaReward = 0;
        StakeMap storage userStake = userStakes[index];
        if(block.timestamp > userStake.expirationTime) {
            withdrawAmount = withdrawAmount.add(userStake.amount);
            uint256 amountTokenReward = userStake.marketAmount.mul(periodReward[userStake.period]).mul(lastTimeRewardApplicable(userStake.expirationTime).sub(userStake.lastRewardTime));
            totalWithdrwaReward = totalWithdrwaReward.add(amountTokenReward);
            remove(msg.sender, index);
            setRelation(msg.sender, 0);
        }
        require(withdrawAmount > 0, 'StakeRIGLPPool: Cannot withdraw 0');
        super.withdraw(withdrawAmount);
        totalWithdrwaReward = totalWithdrwaReward.div(10 ** 9);
        uint256 balance = IERC20(velTokenAddress).balanceOf(address(this));
        if(balance >= totalWithdrwaReward.add(totalWithdrwaReward.mul(23).div(100))) {
            (uint256 transferAmount, uint256 fee) = calculateFee(totalWithdrwaReward);
            IERC20(velTokenAddress).transfer(msg.sender, transferAmount);
            IERC20(velTokenAddress).transfer(devlAddress, fee);
            uint256 funderAmount = totalWithdrwaReward;
            relationFunder(msg.sender, funderAmount);
            emit Reward(msg.sender, totalWithdrwaReward);
        }
        emit Withdrawn(msg.sender, withdrawAmount);
    }

    function calculateFee(uint256 amount) private view returns(uint256 transferAmount, uint256 fee) {
        fee = amount.mul(claimRate).div(100);
        transferAmount = amount.sub(fee);
    }

    function relationFunder(address account, uint256 amount) private {
        address inviterAccount = account;
        for(uint8 i = 1; i <= 10; i++) {
            (address inviter, uint8 level) =  ICommunityRelations(relationAddress).getInviter(inviterAccount);
            inviterAccount = inviter;
            if(level <= 0) continue;
            if(inviterAccount == address(0)) break;
            uint256 rewardAmount;
            if(i == 1) {
               rewardAmount = amount.mul(relationMax).div(100);
            } else {
               rewardAmount = amount.mul(relationMin).div(100);
            }
            IERC20(velTokenAddress).transfer(inviterAccount, rewardAmount);
        }
    }

    function setRelation(address account, uint8 types) private {
        if(relationAddress != address(0)) {
            ICommunityRelations(relationAddress).setAccountLevel(account, types);
        }
    }

    function getReward() public  {
        StakeMap[] storage userStakes = userStakeMaps[msg.sender];
        require(userStakes.length > 0, "StakeRIGLPPool: You have no staked");
        uint256 totalAmountReward = 0;
        for(uint256 i = 0; i < userStakes.length; i++) {
            StakeMap storage userStake = userStakes[i];
            uint256 amountTokenReward = userStake.marketAmount.mul(periodReward[userStake.period]).mul(lastTimeRewardApplicable(userStake.expirationTime).sub(userStake.lastRewardTime));
            userStake.lastRewardTime = lastTimeRewardApplicable(userStake.expirationTime);
            userStake.rewardStakePaid = userStake.rewardStakePaid.add(amountTokenReward);
            totalAmountReward = totalAmountReward.add(amountTokenReward);
        }
        totalAmountReward = totalAmountReward.div(10 ** 9);
        uint256 balance = IERC20(velTokenAddress).balanceOf(address(this));
        require(balance > 10000000, "The mine pit was hollowed out");
        if(totalAmountReward > balance) {
            totalAmountReward = balance;
        }
        if(totalAmountReward > 0) {
            (uint256 transferAmount, uint256 fee) = calculateFee(totalAmountReward);
            IERC20(velTokenAddress).transfer(msg.sender, transferAmount);
            IERC20(velTokenAddress).transfer(devlAddress, fee);
            uint256 funderAmount = totalAmountReward;
            relationFunder(msg.sender, funderAmount);
            emit Reward(msg.sender, totalAmountReward);
        }
    }

    function remove(address staker, uint256 index) internal {
         StakeMap[] storage userStakes = userStakeMaps[staker];
        if (index >= userStakes.length) return;

        for (uint256 i = index; i < userStakes.length - 1; i++) {
            userStakes[i] = userStakes[i + 1];
        }
        userStakes.pop();
    }

    function lastTimeRewardApplicable(uint256 expirationTime) internal view returns (uint256) {
        return Math.min(block.timestamp, expirationTime);
    }

    function calculateRIGAmount(uint256 lpAmount) private view returns(uint256) {
        uint256 totalLP = IERC20(address(lpt)).totalSupply();
        uint256 lpRigAmount = IERC20(rigTokenAddress).balanceOf(address(lpt));
        uint256 marketAmount = lpRigAmount.mul(lpAmount).div(totalLP);
        return marketAmount;
    }

    function earned(address account) public view returns (uint256) {
        StakeMap[] memory userStakes = userStakeMaps[account];
        if(userStakes.length <= 0) return 0;
        uint256 totalAmountReward = 0;
        for(uint256 i = 0; i < userStakes.length; i++) {
            StakeMap memory userStake = userStakes[i];
            uint256 amountTokenReward = userStake.marketAmount.mul(periodReward[userStake.period]).mul(lastTimeRewardApplicable(userStake.expirationTime).sub(userStake.lastRewardTime));
            totalAmountReward = totalAmountReward.add(amountTokenReward);
        }
        return totalAmountReward.div(10 ** 9);
    }

    function earnedByIndex(address account, uint256 index) public view returns (uint256) {
         StakeMap[] memory userStakes = userStakeMaps[account];
         if(index >= userStakes.length) return 0;
         StakeMap memory userStake = userStakes[index];
         uint256 amountTokenReward = userStake.marketAmount.mul(periodReward[userStake.period]).mul(lastTimeRewardApplicable(userStake.expirationTime).sub(userStake.lastRewardTime));
         return amountTokenReward.div(10 ** 9);
    }

    function getWithdrawAmount(address account) public view returns(uint256) {
        StakeMap[] memory userStakes = userStakeMaps[account];
        if(userStakes.length <= 0) return 0;
        uint256 withdrawAmount = 0;
        for(uint256 i = 0; i < userStakes.length; i++) {
            StakeMap memory userStake = userStakes[i];
            if(block.timestamp > userStake.expirationTime) {
                withdrawAmount = withdrawAmount.add(userStake.amount);
            }
        }
        return withdrawAmount;
    }

    function getAcountStakeMaps(address account) public view returns(StakeMap[] memory) {
        return userStakeMaps[account];
    }
}