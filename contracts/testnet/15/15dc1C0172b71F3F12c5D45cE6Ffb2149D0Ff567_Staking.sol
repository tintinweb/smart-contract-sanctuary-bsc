/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

//SPDX-License-Identifier: MIT


// Dependency file: @openzeppelin/contracts/utils/math/SafeMath.sol

// pragma solidity ^0.8.0;

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

pragma solidity ^0.8.6;

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

    function _transfer(address _from, address _to, uint256 _value) external ;
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


contract Staking {

    using SafeMath for uint256;

    IERC20 public token;

    address public contractOwner;

    uint256 public stakeIDs;

    struct stakeDetails {
        uint256 stakeID;
        address staker;
        uint256 stakeAmount;
        uint256 numberOfDays;
        uint256 stakeTimeStart;
        uint256 stakeTimeEnd;
        bool unstaked;
    }

    uint256 sevenDaysRewardPercentage = 100;
    uint256 fifteenDaysRewardPercentage = 300;
    uint256 thirtyDaysRewardPercentage = 600;
    uint256 ninetyDaysRewardPercentage = 800;
    uint256 earlyWithdrawTax = 25;

    mapping(uint256 => stakeDetails) public stakes;

    mapping(address => uint256 []) public stakeIdOfUser;

    mapping(address => uint256) public stakedAmount;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        contractOwner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    function updateRewardPercentage(uint256 _sevenDaysRewardPercentage, uint256 _fifteenDaysRewardPercentage, uint256 _thirtyDaysRewardPercentage, uint256 _ninetyDaysRewardPercentage) public onlyOwner() {
        sevenDaysRewardPercentage = _sevenDaysRewardPercentage;
        fifteenDaysRewardPercentage = _fifteenDaysRewardPercentage;
        thirtyDaysRewardPercentage = _thirtyDaysRewardPercentage;
        ninetyDaysRewardPercentage = _ninetyDaysRewardPercentage;
    }

    function stakeToken(uint256 _amount, uint256 _timePeriod) public returns(uint256) {
        require(_timePeriod == 7 || _timePeriod == 15 || _timePeriod == 30 || _timePeriod == 90);
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient User Token Balance");
        require(_amount > 0, "Invalid Stake Amount");
        stakeIDs = stakeIDs + 1;

        stakeDetails memory newStake = stakeDetails({
            stakeID: stakeIDs,
            staker: msg.sender,
            stakeAmount: _amount,
            stakeTimeStart: block.timestamp,
            numberOfDays: _timePeriod,
            stakeTimeEnd: block.timestamp.add(_timePeriod * 1 days),
            unstaked: false
        });
 
        stakes[stakeIDs] = newStake;
        stakeIdOfUser[msg.sender].push(stakeIDs);
        stakedAmount[msg.sender] = stakedAmount[msg.sender].add(_amount);
        token.transferFrom(msg.sender, address(this), _amount);
        return stakeIDs;
    }

    function getUserStakeIDs() public view returns(uint256 [] memory){
        return stakeIdOfUser[msg.sender];
    }

    function unstake(uint256 _stakeID) public {
        require(stakes[_stakeID].unstaked == false);
        require(stakes[_stakeID].staker == msg.sender);
        
        uint256 unstakeAmount = 0;

        if(block.timestamp > stakes[_stakeID].stakeTimeEnd) {
            uint256 rewardPercentage = calculateReward(_stakeID);
            uint256 rewardAmount = stakes[_stakeID].stakeAmount.mul(rewardPercentage).div(100);
            unstakeAmount = stakes[_stakeID].stakeAmount.add(rewardAmount);
        } else {
            uint256 tax = stakes[_stakeID].stakeAmount.mul(earlyWithdrawTax).div(100);
            unstakeAmount = stakes[_stakeID].stakeAmount.sub(tax);
        }
        stakedAmount[msg.sender] = stakedAmount[msg.sender].sub(stakes[_stakeID].stakeAmount);
        token.transfer(msg.sender, unstakeAmount);
        stakes[_stakeID].unstaked = true;
    }

    function calculateReward(uint256 _stakeID) public view returns(uint256) {
        
        uint256 rewardPercentage;

        if(stakes[_stakeID].numberOfDays == 7) {
            rewardPercentage = sevenDaysRewardPercentage;
        } else if(stakes[_stakeID].numberOfDays == 15) {
            rewardPercentage = fifteenDaysRewardPercentage;
        } else if(stakes[_stakeID].numberOfDays == 30) {
            rewardPercentage = thirtyDaysRewardPercentage;
        } else {
            rewardPercentage = ninetyDaysRewardPercentage;
        }
        return rewardPercentage;
    }

    function setEarlyWithdrawTax(uint256 _earlyWithdrawTax) public onlyOwner() {
        earlyWithdrawTax = _earlyWithdrawTax;
    }

    function getUserReward(address _userAddress) public view returns(uint256){
        uint256 rewardAmount = 0;
        for(uint256 i=0; i < stakeIdOfUser[_userAddress].length; i++) {

            uint256 stakeID = stakeIdOfUser[_userAddress][i];
            if(!stakes[stakeID].unstaked){
                uint256 currentTime = block.timestamp;
                uint256 startTime = stakes[stakeID].stakeTimeStart;
                uint256 numerOfDaysPassed = currentTime.sub(startTime).div(1 days); 

                uint256 calculatedReward = calculateReward(stakeID).mul(100);
                rewardAmount = rewardAmount.add(stakes[stakeID].stakeAmount.mul(numerOfDaysPassed.mul(calculatedReward.div(stakes[stakeID].numberOfDays))).div(10000));
            }
        }
        return rewardAmount;
    }

}