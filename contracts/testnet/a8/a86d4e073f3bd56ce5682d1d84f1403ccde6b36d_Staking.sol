/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// SPDX-License-Identifier: agpl-3.0
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
     function increaseAllowance(address spender, uint256 amount) external returns (bool);

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

pragma solidity ^0.8.0;

contract Staking{

    using SafeMath for uint256;
    IERC20 public chaindx;
   

    constructor(IERC20 _chaindx){
        chaindx=_chaindx;
    }

    uint256 public startBlock=block.timestamp;
    uint256 public endBlock=block.timestamp+10512000;
    uint256 public fundstaking;
    
    uint256 public totalstaked;
   
    struct UserDetails{
        uint256 amount;
        address user;
        uint256 starttime;
    }

     UserDetails[] users;
     address[] totalusers;
     mapping(address => UserDetails) public UserList;
     mapping(address => uint256) public addressPush;
     mapping(address => uint256) public withdrawReward;

    function fundTransfer(uint256 _amount) public{
        chaindx.transferFrom(msg.sender,address(this),_amount);
        fundstaking+=_amount;
    }
   
    function stake(uint256 _amount ) public{
        UserDetails storage user=UserList[msg.sender];
        uint256 value=user.amount;
        if(user.amount == 0){
             chaindx.transferFrom(msg.sender,address(this),_amount);
        UserList[msg.sender]=UserDetails({
            amount:_amount,
            user:msg.sender,
            starttime:block.number
        });
        totalstaked+=_amount;
        withdrawReward[msg.sender]=block.timestamp + uint256(120 days);
        }
        else{
            chaindx.transferFrom(msg.sender,address(this),_amount);
            user.amount=value+_amount;
            user.starttime=block.timestamp;
            totalstaked+=_amount;
            withdrawReward[msg.sender]=block.timestamp + uint256(120 days);
        }
    }

    function compound() public{
         UserDetails storage user=UserList[msg.sender];
         uint256 transfer=rewardPerBlockAddress(msg.sender);
         user.amount=user.amount+transfer;
         user.starttime=block.number;
         totalstaked+=transfer;
    }

    function harvest() public{
          UserDetails storage user=UserList[msg.sender];
          uint256 transfer=rewardPerBlockAddress(msg.sender);
          chaindx.increaseAllowance(address(this),transfer);
          chaindx.transferFrom(address(this),msg.sender,transfer);
          user.starttime=block.number;
    }
    

    function rewardPerBlock() public view returns(uint256){
        uint256 reward=fundstaking.div(10512000);
        return reward;
    }

    function withdraw() public {
        require(block.timestamp >= withdrawReward[msg.sender],'4 month is not yet completed');
        UserDetails storage user=UserList[msg.sender];
        uint256  reward=rewardPerBlockAddress(msg.sender);
        chaindx.increaseAllowance(address(this),reward+user.amount);
        chaindx.transferFrom(address(this),msg.sender,reward+user.amount);
        totalstaked -= user.amount;
        user.amount=0;
        user.starttime=0;
    }

    function rewardPerBlockAddress(address _address) public view returns(uint256){
        UserDetails memory user=UserList[_address];
        uint256 amount=user.amount;
        uint256 startblock=user.starttime;
        // uint256 percent=amount.mul(100).mul(number).div(totalstaked);
        uint256 transfer=amount.mul(rewardPerBlock()).mul(10**18).div(totalstaked);
        uint256 totalblock=block.number - startblock;
        return (totalblock.mul(transfer).div(10**18));
    }

   

     function getRewardDetails() public view returns(uint256,uint256,uint256,uint256){
        UserDetails memory user=UserList[msg.sender];
        uint256 amount=user.amount;
        uint256 startblock=user.starttime;
        uint256 percent=amount.div(totalstaked).mul(100);
        uint256 transfer=rewardPerBlock().mul(percent).div(100);
        uint256 totalblock=block.number - startblock;
        return (percent,transfer,totalblock,totalblock.mul(transfer));
    }

    function getUserDetails(address _address) public view returns(uint256,uint256){
         UserDetails memory user=UserList[_address];
         return (user.amount,user.starttime);

    }

    function getTimestamp(address _address) public view returns(uint256){
        return  withdrawReward[_address];
    }
    function getApy() public view returns(uint256,uint256){
        return (fundstaking,totalstaked);
        
    }

    function totalStaked() public view returns(uint256){
        return totalstaked;
    }


    function endTime() public view returns(uint256){
        return endBlock;
    }

    
}