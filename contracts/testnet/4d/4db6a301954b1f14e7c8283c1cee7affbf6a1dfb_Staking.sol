/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

/**
 *Submitted for verification at polygonscan.com on 2022-03-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// File: all-code/locknesss/Context.sol


// OpenZeppelin Contracts v4.3.2 (utils/Context.sol)

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
// File: all-code/lockness/Ownable.sol


// OpenZeppelin Contracts v4.3.2 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
// File: all-code/lockness/BEP20.sol


pragma solidity ^0.8.0;
/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// File: all-code/lockness/SafeMath.sol



pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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


// File: browser/Staking.sol


pragma solidity ^0.8.0;

contract Staking is Ownable {
    using SafeMath for uint256;

    IBEP20 public stakeToken;
    IBEP20 public rewardToken;

    uint256 private _totalSupply;

    uint256 public totalRewardFunds;
    uint256 public rewardBalance = totalRewardFunds;

    uint day = 60;
    uint accuracyFactor = 10 ** 10;

    mapping(address => uint256) public totalStakeRecords;
    mapping(address => stakerDetails[]) public Stakers;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 noOfDays);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RecoverToken(address indexed token, uint256 indexed amount);

    struct stakerDetails {
        uint id;
        uint balance;
        uint totalRewards;
        uint lockingPeriod;
        uint lastUpdatedTime;
        uint maxTime;
        uint rewardEarned;
        uint rewardPaidOut;
        uint apr;
    }
   

    modifier updateReward(address account, uint id) {
        Stakers[account][id].rewardEarned = earned(account, id);
        _;
    }

    constructor(IBEP20 _stakeToken, IBEP20 _rewardToken) {
        stakeToken = IBEP20(_stakeToken);
        rewardToken = IBEP20(_rewardToken);
    }

    function getRewardRate(address account, uint id) public view returns (uint256) {
        uint daysInTimestamp = Stakers[account][id].lockingPeriod * day;

        uint amount = getAmountWithApr(account, id);

        return amount
                .div(365)
                .mul(Stakers[account][id].lockingPeriod)
                .div(daysInTimestamp);
    }

    function getAmountWithApr(address account, uint id) public view returns(uint) {
        return Stakers[account][id].balance
                .mul(Stakers[account][id].apr).div(100).div(accuracyFactor);
    }

    function earned(address account, uint id) public view returns (uint256) {
        if(Stakers[account][id].rewardPaidOut < Stakers[account][id].totalRewards) {
            if(block.timestamp >= Stakers[account][id].maxTime) {
                return (Stakers[account][id].totalRewards.sub(Stakers[account][id].rewardPaidOut));
            }

            return
                getRewardRate(account, id).mul(block.timestamp.sub(Stakers[account][id].lastUpdatedTime));
        } else {
            return 0;
        } 
    }

    function isRewardAvailable(uint rewardAmount) public view returns (bool) {
        if(rewardBalance >= rewardAmount) {
            return true;
        }
        return false;
    }

    function getAPR(uint noOfDays) public view returns(uint) {
          return ((noOfDays * (1 * (noOfDays * accuracyFactor)).div(10000)) + (25 * accuracyFactor));
    }

      function getAPR1(uint noOfDays) public view returns(uint) {
        return ((noOfDays * (2 * (noOfDays * accuracyFactor)).div(10000)) + (50 * accuracyFactor));
    }
      function getAPR2(uint noOfDays) public view returns(uint) {
       return ((noOfDays * (3 * (noOfDays * accuracyFactor)).div(10000)) + (75 * accuracyFactor));
    }

    function rewardForPeriod( uint amount, uint noOfDays, uint num) public view returns (uint) {
        if(num==0){
        uint apr = getAPR(noOfDays).div(accuracyFactor);
        uint reward = amount.mul(apr).div(100);
        uint totalRewardForPeriod = reward.div(365).mul(noOfDays);
        return totalRewardForPeriod;}
        else if(num ==1){
         uint apr = getAPR1(noOfDays);
        uint reward = amount.mul(apr).div(100).div(accuracyFactor);
        uint totalRewardForPeriod = reward.div(365).mul(noOfDays);
        return totalRewardForPeriod;
        }
        else{
         uint apr = getAPR2(noOfDays);
        uint reward = amount.mul(apr).div(100).div(accuracyFactor);
        uint totalRewardForPeriod = reward.div(365).mul(noOfDays);
        return totalRewardForPeriod;

        }
    }

    function stake(uint256 amount, uint noOfDays,uint256 num) public {
        require(amount > 0, "Cannot stake 0");
        if(num==0){

        uint daysInTimestamp = noOfDays * day;
        stakerDetails memory staker;
        uint rewardForUser = rewardForPeriod(amount, noOfDays,num);
        totalStakeRecords[msg.sender] += 1;
        staker.id = totalStakeRecords[msg.sender];
        staker.lockingPeriod = noOfDays;
        staker.totalRewards = rewardForUser;
        staker.lastUpdatedTime = block.timestamp;
        staker.maxTime = block.timestamp + (daysInTimestamp);
        staker.balance = amount;
        staker.apr = getAPR(noOfDays);

        Stakers[msg.sender].push(staker);
        rewardBalance -= rewardForUser;
        _totalSupply = _totalSupply.add(amount);
        stakeToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount, noOfDays);}
        else if(num==1){
        uint daysInTimestamp = noOfDays * day;
        stakerDetails memory staker;
        uint rewardForUser = rewardForPeriod(amount, noOfDays,num);
        totalStakeRecords[msg.sender] += 1;
        staker.id = totalStakeRecords[msg.sender];
        staker.lockingPeriod = noOfDays;
        staker.totalRewards = rewardForUser;
        staker.lastUpdatedTime = block.timestamp;
        staker.maxTime = block.timestamp + (daysInTimestamp);
        staker.balance = amount;
        staker.apr = getAPR1(noOfDays);

        Stakers[msg.sender].push(staker);
        rewardBalance -= rewardForUser;
        _totalSupply = _totalSupply.add(amount);
        stakeToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount, noOfDays);
        }
        else{
                uint daysInTimestamp = noOfDays * day;
        stakerDetails memory staker;
        uint rewardForUser = rewardForPeriod(amount, noOfDays,num);
        totalStakeRecords[msg.sender] += 1;
        staker.id = totalStakeRecords[msg.sender];
        staker.lockingPeriod = noOfDays;
        staker.totalRewards = rewardForUser;
        staker.lastUpdatedTime = block.timestamp;
        staker.maxTime = block.timestamp + (daysInTimestamp);
        staker.balance = amount;
        staker.apr = getAPR2(noOfDays);

        Stakers[msg.sender].push(staker);
        rewardBalance -= rewardForUser;
        _totalSupply = _totalSupply.add(amount);
        stakeToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount, noOfDays);

        }
    }

    function unstake(uint id) public {
        require(block.timestamp >= Stakers[msg.sender][id].maxTime, "Tokens are locked! Try unstaking after locking period");
        uint amount = Stakers[msg.sender][id].balance;
        _totalSupply = _totalSupply.sub(amount);
        Stakers[msg.sender][id].balance = 0;
        stakeToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }


    function getReward(uint id) public updateReward(msg.sender, id) {
        uint256 reward = earned(msg.sender, id);
        Stakers[msg.sender][id].lastUpdatedTime = block.timestamp;
        if (reward > 0) {
            Stakers[msg.sender][id].rewardEarned = 0;
            Stakers[msg.sender][id].rewardPaidOut += reward;
            rewardToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit(uint id) external {
        unstake(id);
        getReward(id);
    }


    function TotalValueLocked() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account, uint id) public view returns (uint256) {
        return Stakers[account][id].balance;
    }

    function recoverExcessToken(address token, uint256 amount) external onlyOwner {
        if(token == address(stakeToken)) {
            require(amount <= rewardBalance, "Cannot remove more than remaining reward");
        }

        IBEP20(token).transfer(msg.sender, amount);
        emit RecoverToken(token, amount);
    }

    function depositRewards(uint amount) public onlyOwner {
        stakeToken.transferFrom(msg.sender, address(this), amount);
        totalRewardFunds += amount;
        rewardBalance += amount;
    }
    function TotalRewards() public view returns(uint256){
        uint256 tRewards = totalRewardFunds - rewardBalance;
        return tRewards;
    }
}