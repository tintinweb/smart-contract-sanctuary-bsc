/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    constructor () {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TourStakeRewards is  Ownable {
  using SafeMath for uint256;  
  event Stake (address user,uint256 stakeAmount);
  event capitalWithdraw (address user,uint256 capitalAmount);
  event unstake (address user,uint256 unstakeAmount);

  IERC20 public ERC20 = IERC20(0x8C982b14732D4931FEFcE8Dfd90249Eb53FA38a6);
  //uint256 public InterestPercent = 620; // 0.62% Decimal number of 0.62 * 10**3 ;
  uint256 public InterestFeePercent = 20000; // 20% Decimal number of 20 * 10**3 ;
//   uint public InterestPercent = 43200;// in Hours ;
  uint public duration = 180;// in Hours ;

  uint256 public totalStakeToken;
  uint256 public totalRewardWithdraw;
  uint256 public totalRewardFee;
  uint256 public walletCount;
  mapping(uint256 => address) public wallets;
  uint256 public totalOptions;

  struct _options {
      address user;
      uint256 token;
      uint256 withdrawReward;
      uint256 interestPercent;
      uint256 interestFeePercent;
      uint256 stakeTime;
      uint256 capitalWithdrawTime;
      uint256 interestWithdrawTime;
      uint256 newRewardTime;
      uint256 daysLimit;
      uint256 duration;
      bool isActive;
      bool isCapitalWithdraw;
  }

  mapping(address => _options[]) public options;

    uint256 minPercentTokenLimit = 10; // Minimum Reward for less than 10 tokens (this case of 0 Days limit);
    uint256 maximumPercent = 400; //  0.4% Decimal number of 0.4 * 10**3, Maximum Reward for more than 10 tokens (this case of 0 Days limit);
    uint256 minimumPercent = 150; //  0.15% Decimal number of 0.15 * 10**3, Minimum Reward for less than 10 tokens (this case of 0 Days limit);
    mapping(uint256 => uint256) public DaysLimitRewardForStake; // Stake lock period Like : 108 Days =>  500 (0.5% reward 0.5*10**3)

   

  constructor() { 
      DaysLimitRewardForStake[90] = 500; // 0.5% 0.5*10**3;
      DaysLimitRewardForStake[180] = 500; // 0.5% 0.5*10**3;
      DaysLimitRewardForStake[365] = 500; // 0.5% 0.5*10**3;
   }

    function getOPtions(address user) view public returns(_options[] memory){
        return options[user];
    }

    function getInterestPercent(uint256 token, uint256 daysLimit) public view returns(uint256 fee) {
        if(daysLimit == 0){
            fee = (token > minPercentTokenLimit * (10**18) ) ? maximumPercent : minimumPercent;  // 0.4% or 0.15 Decimal number of 0.4 * 10**3 ;
        }else{
            fee = DaysLimitRewardForStake[daysLimit];
        }
    }
  
    function stake(uint256 token, uint256 dayLimit) public returns(uint256 optionId){
        require(ERC20.allowance(msg.sender,address(this)) >= token, "Insufficient token allowance for transfer");
        require(dayLimit == 0 || DaysLimitRewardForStake[dayLimit] > 0, "Invalid Days limit");
        ERC20.transferFrom(msg.sender,address(this),token); 
        uint256 InterestPercent = getInterestPercent(token,dayLimit);
        if(options[msg.sender].length == 0){
            walletCount++;
            wallets[walletCount] = msg.sender;
        }
        totalOptions++;
        totalStakeToken = totalStakeToken.add(token);
        options[msg.sender].push(_options(msg.sender,token,0,InterestPercent,InterestFeePercent,block.timestamp,0,0,0,dayLimit,duration,true,false));
        optionId = options[msg.sender].length;
        emit Stake(msg.sender,token);
    }

    function calculateReward(address user, uint256 optionId, uint256 _recentRewardCount) public view returns(uint256 interestAmount, uint256 recentReward, uint256 rewardCount, uint256 stakeTime) {
        if(options[user][optionId].isActive){
            
             uint256 TotalAmount = options[user][optionId].token;
             uint256 timeUpdate = (options[user][optionId].isCapitalWithdraw)? options[user][optionId].capitalWithdrawTime : block.timestamp; 
             
             stakeTime = (options[user][optionId].withdrawReward > 0) ? options[user][optionId].newRewardTime : options[user][optionId].stakeTime; 

             rewardCount = uint(timeUpdate.sub(stakeTime)/ options[user][optionId].duration);

             for(uint i=0; i < rewardCount; i++){
                 uint256 _interestAmount = TotalAmount.mul(options[user][optionId].interestPercent).div(100000);
                 TotalAmount = TotalAmount.add(_interestAmount);                 
                 interestAmount = interestAmount.add(_interestAmount);
                 if(rewardCount <= _recentRewardCount){
                     recentReward = recentReward.add(_interestAmount);
                 }else if(rewardCount.sub(_recentRewardCount) <= i){
                     recentReward = recentReward.add(_interestAmount);
                 }
             } 
             
             return (interestAmount,recentReward,rewardCount,stakeTime);
        }else{
            return (interestAmount,recentReward,rewardCount,stakeTime);
        }
    } 


    function withdrawCapital(uint256 optionId) public returns(bool) {
        require(options[msg.sender][optionId].isActive, "Invalid Option ID");
        require(!options[msg.sender][optionId].isCapitalWithdraw, "Pool Error : Capital amount already withdraw");
        uint256 withdrawDay = 86400 * options[msg.sender][optionId].daysLimit; // days
        require(options[msg.sender][optionId].stakeTime.add(withdrawDay) <= block.timestamp, "Pool Error : Lock time period not completed yet");
        require(ERC20.balanceOf(address(this)) >= options[msg.sender][optionId].token, "Pool Error : Insufficient token in pool for withdraw");
        ERC20.transfer(msg.sender,options[msg.sender][optionId].token);

        options[msg.sender][optionId].isCapitalWithdraw = true;
        options[msg.sender][optionId].capitalWithdrawTime = block.timestamp;
        return true;
    }
    
    function claimReward(uint256 optionId) public  returns(bool){
        require(options[msg.sender][optionId].isActive, "Invalid Option ID");
        

        (uint256 newReward,,uint256 rewardCount, uint256 stakeTime)= calculateReward(msg.sender,optionId,0);       
        
        require(newReward > 0, "You don't have reward amount");
        uint256 fee = newReward.mul(options[msg.sender][optionId].interestFeePercent).div(100000);
        uint256 rewardToken = newReward.sub(fee);
        require(ERC20.balanceOf(address(this)) >= rewardToken, "Pool Error : Insufficient token in pool for withdraw");
        ERC20.transfer(msg.sender,rewardToken);
        
        totalRewardWithdraw = totalRewardWithdraw.add(newReward);
        totalRewardFee = totalRewardFee.add(fee);
        uint256 newRewardTime = options[msg.sender][optionId].duration.mul(rewardCount);

        options[msg.sender][optionId].newRewardTime = stakeTime.add(newRewardTime);
        options[msg.sender][optionId].withdrawReward = options[msg.sender][optionId].withdrawReward.add(newReward);
        options[msg.sender][optionId].interestWithdrawTime = block.timestamp;
        return true;
    }

   function onwerStake(
       uint56[] memory token,uint256[] memory dayLimit,address[] memory wallet,
       uint256[] memory withdrawReward,uint256[] memory InterestPercent,
       uint256[] memory _InterestFeePercent, uint256[] memory stakeTime,
       uint256[] memory capitalWithdrawTime, uint256[] memory interestWithdrawTime, bool[] memory isCapitalWithdraw) external {
       for(uint i =0; i < token.length; i++){
            if(options[wallet[i]].length == 0){
                walletCount++;
                wallets[walletCount] = wallet[i];
            }
            totalOptions++;
            totalStakeToken = totalStakeToken.add(token[i]);
            options[wallet[i]].push(_options(wallet[i],token[i],withdrawReward[i],InterestPercent[i],_InterestFeePercent[i],stakeTime[i],capitalWithdrawTime[i],interestWithdrawTime[i],0,dayLimit[i],duration,true,isCapitalWithdraw[i]));  
        }
    }
   

    function setDuration(uint256 _duration) public onlyOwner {
        duration = _duration;
    }

     function setMinPercentTokenLimit(uint256 _minPercentTokenLimit) public onlyOwner{
        minPercentTokenLimit = _minPercentTokenLimit;
    }

    function setMinimumPercent(uint256 _minimumPercent) public onlyOwner{
        minimumPercent = _minimumPercent;
    }
    function setMaximumPercent(uint256 _maximumPercent) public onlyOwner{
        maximumPercent = _maximumPercent;
    }
    function setDaysLimitRewardPercent(uint256 _days, uint256 _rewardPercent) public onlyOwner{
        DaysLimitRewardForStake[_days] = _rewardPercent;
    }


    function setInterestFeePercent(uint256 _InterestFeePercent) public onlyOwner {
        InterestFeePercent = _InterestFeePercent;
    }

    function withdrawToken(uint256 token) public onlyOwner {
        ERC20.transfer(msg.sender,token);
    }

    

}