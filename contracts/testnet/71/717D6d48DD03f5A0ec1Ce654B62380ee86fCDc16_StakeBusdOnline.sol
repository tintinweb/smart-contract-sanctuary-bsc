/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IERC20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
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
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract StakeBusdOnline is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant min = 50 ether;
    uint256 public constant max = 20000 ether;
    uint256 public roi = 8;
    uint256 public constant fee = 10;
    uint256 public constant withdraw_fee = 5;
    uint256 public constant ref_fee = 8;
    uint256 public constant jackpot_percent = 8;
    uint256 public daysToWithdraw = 0.05 * 60 * 60;    //7 days
    uint256 public daysToClaim = 0.01 * 60 * 60;       //1 day
    address public dev = 0x7D4D145e0E572BAA319B9f11d6178cD1ed99a391;
    IERC20 private BusdInterface;
    address public tokenAdress;
    bool public init = false;
    bool public alreadyInvested = false;
    constructor() {
    tokenAdress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; 
    BusdInterface = IERC20(tokenAdress);
                 }

    struct jackpot_info {
        uint256 lastTime;
        address lastWinner;
        uint256 lastWinnerDeposit;
        address candidate;
        uint256 candidateDeposit;
    }
    
    jackpot_info public jackpot;

    struct refferal_system {
        address ref_address;
        uint256 reward;
    }

    struct refferal_withdraw {
        address ref_address;
        uint256 totalWithdraw;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct weeklyWithdraw {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct claimDaily {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct userWithdrawal {
        address user_address;
        uint256 amount;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }
     struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 

    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => refferal_withdraw) public refTotalWithdraw;

    // invest function 
    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(init, "Not Started Yet");
        require(_amount>=min && _amount <= max, "Cannot Deposit");
       
        if(!checkAlready()){
        uint256 ref_fee_add = refFee(_amount);
        if(_ref != address(0) && _ref != msg.sender) {
         uint256 ref_last_balance = refferal[_ref].reward;
         uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
         refferal[_ref] = refferal_system(_ref,totalRefFee);
        }
        else {
            uint256 ref_last_balance = refferal[dev].reward;
            uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);  
            refferal[dev] = refferal_system(dev,totalRefFee);
        }

        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

        // weekly withdraw 
        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp.add(daysToWithdraw);

        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

        // Claim Setting
        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp.add(daysToClaim);

       claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
        
       // fees 
        uint256 total_fee = depositFee(_amount);
        uint256 total_contract = SafeMath.sub(_amount,total_fee);
        BusdInterface.transferFrom(msg.sender,dev,total_fee);
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);
        }
        else {

        uint256 ref_fee_add = refFee(_amount);
        if(_ref != address(0) && _ref != msg.sender) {
         uint256 ref_last_balance = refferal[_ref].reward;
         uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
         refferal[_ref] = refferal_system(_ref,totalRefFee);
        }
        else {
            uint256 ref_last_balance = refferal[dev].reward;
            uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);  
            refferal[dev] = refferal_system(dev,totalRefFee);
        }

        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);
        
       // fees 
        uint256 total_fee = depositFee(_amount);
        uint256 total_contract = SafeMath.sub(_amount,total_fee);
        BusdInterface.transferFrom(msg.sender,dev,total_fee);
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);

        }

         // jackpot
        if (_amount == max) {
            jackpot.lastWinner = msg.sender;
            jackpot.lastWinnerDeposit = max;
            jackpot.candidate = address(0);
            jackpot.candidateDeposit = 0;
            jackpot.lastTime = block.timestamp;

            uint256 jackpotAmount = jackpot.lastWinnerDeposit * jackpot_percent / 100;

            uint256 userLastInvestment = investments[jackpot.lastWinner].invested;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,jackpotAmount);
            investments[jackpot.lastWinner] = user_investment_details(jackpot.lastWinner,totalInvestment);
        } else if (_amount > jackpot.candidateDeposit) {
            jackpot.candidate = msg.sender;
            jackpot.candidateDeposit = _amount;
        }
    }

    function userReward(address _userAddress) public view returns(uint256) {
        
        
        uint256 userInvestment = investments[_userAddress].invested;
        uint256 userDailyReturn = DailyRoi(userInvestment);

        // invested time

        uint256 claimInvestTime = claimTime[_userAddress].startTime;
        uint256 claimInvestEnd = claimTime[_userAddress].deadline;

        uint256 totalTime = SafeMath.sub(claimInvestEnd,claimInvestTime);

        uint256 value = SafeMath.div(userDailyReturn,totalTime);

        uint256 nowTime = block.timestamp;

        if(claimInvestEnd>= nowTime) {
        uint256 earned = SafeMath.sub(nowTime,claimInvestTime);

        uint256 totalEarned = SafeMath.mul(earned, value);

        return totalEarned;
        }
        else {
          
            return userDailyReturn;
        }
    }

    function withdrawal() public noReentrant {
       require(init, "Not Started Yet");    
       require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");
       require(totalRewards[msg.sender].amount <= SafeMath.mul(investments[msg.sender].invested,3), "You cant withdraw you have collected 3 times Already"); 
    
    
       uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
       uint256 aval_withdraw2 = SafeMath.mul(SafeMath.div(aval_withdraw,100),70); // aval_withdraw2 receives 70%
       uint256 aval_withdraw3 = SafeMath.mul(SafeMath.div(aval_withdraw,100),30); // aval_withdraw3 receives 30%
    
       uint256 wFee = withdrawFee(aval_withdraw3); // withdraw fee
    
       uint256 totalAmountToWithdraw = SafeMath.sub(aval_withdraw3,wFee); // Total amount withdrawable detecting withdraw tax
       approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,0); // Updated to 0 as the 70% available is re-invested
    
       //70% is re-invested without any tax.
       
       uint256 userLastInvestment = investments[msg.sender].invested;
       uint256 userCurrentInvestment = aval_withdraw2;
       uint256 totalInvestment = userLastInvestment.add(userCurrentInvestment);
       investments[msg.sender] = user_investment_details(msg.sender, totalInvestment);

       uint256 weeklyStart = block.timestamp;
       uint256 deadline_weekly = block.timestamp.add(daysToWithdraw);

       weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

       uint256 amount = totalWithdraw[msg.sender].amount;

       uint256 totalAmount = SafeMath.add(amount,aval_withdraw3); 

       totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);

       BusdInterface.transfer(msg.sender,totalAmountToWithdraw);
       BusdInterface.transfer(dev,wFee);


    }
    
   

    function claimDailyRewards() public noReentrant{
        require(init, "Not Started Yet");
        require(claimTime[msg.sender].deadline <= block.timestamp, "You cant claim");

        uint256 rewards = userReward(msg.sender);

        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;

        uint256 value = SafeMath.add(rewards,currentApproved);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; //hhnew
        uint256 totalRewardAmount = SafeMath.add(amount,rewards); //hhnew
        totalRewards[msg.sender].amount=totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp.add(daysToClaim);

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        // jackpot
        if (jackpot.candidate != address(0) && block.timestamp > jackpot.lastTime + 1 days) {
            jackpot.lastWinner = jackpot.candidate;
            jackpot.lastWinnerDeposit = jackpot.candidateDeposit;
            jackpot.candidate = address(0);
            jackpot.candidateDeposit = 0;
            jackpot.lastTime = block.timestamp;

            uint256 jackpotAmount = jackpot.lastWinnerDeposit * jackpot_percent / 100;
            
            uint256 ref_last_balance = refferal[owner()].reward;
            uint256 totalRefFee = SafeMath.add(jackpotAmount,ref_last_balance);
            refferal[owner()] = refferal_system(owner(),totalRefFee);

            uint256 userLastInvestment = investments[jackpot.lastWinner].invested;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,jackpotAmount);
            investments[jackpot.lastWinner] = user_investment_details(jackpot.lastWinner,totalInvestment);
        }

    }

    function Ref_Withdraw() external noReentrant {
        require(init, "Not Started Yet");
        uint256 value = refferal[msg.sender].reward;
        refferal[msg.sender] = refferal_system(msg.sender, 0);
        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;
        uint256 totalValue = SafeMath.add(value,lastWithdraw);
        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender, totalValue);
        BusdInterface.transfer(msg.sender, value);
    }

    // initialized the market

    function signal_market() public onlyOwner {
        init = true;
        jackpot.lastTime = block.timestamp;
    }


    // other functions

    function DailyRoi(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,roi),100);
    }
     function checkAlready() public view returns(bool) {
         address _address= msg.sender;
        if(investments[_address].user_address==_address){
            return true;
        }
        else{
            return false;
        }
    }

    function depositFee(uint256 _amount) public pure returns(uint256){
     return SafeMath.div(SafeMath.mul(_amount,fee),100);
    }

    function refFee(uint256 _amount) public pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,ref_fee),100);
    }

    function withdrawFee(uint256 _amount) public pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,withdraw_fee),100);
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }

}