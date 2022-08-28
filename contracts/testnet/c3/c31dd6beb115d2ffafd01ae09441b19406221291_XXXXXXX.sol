/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: UNLICENSED
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

contract XXXXXXX is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    //uint256 public constant min = 10 ether;    mainnet
    uint256 public constant min = 1 ether;    //testnet
    uint256 public constant max = 50000 ether;
    uint256 public roi = 10;
    uint256 public constant fee = 5;
    uint256 public constant withdraw_fee = 10;
    uint256 public constant ref_fee = 5;
    uint256 public constant claim_cycle = 5;
    uint256 public constant compound_step = 3;
    uint256 public constant mandatory_fee = 30;
    uint256 public constant max_cycle = 4;
    uint256 public constant max_compound_count = 3;
    bool public INIT = false;
    //uint256 constant public TIME_STEP = 1 days;   mainnet
    uint256 constant public TIME_STEP = 20;   //testnet
    address payable public  dev;
    address public tokenAdress;
    IERC20 private BusdInterface;	

    constructor() {
         //dev = payable(0xeDda662A365F665C60B9c4aC1F20d71C41C63148);   mainnet
        dev = payable(0xc3646D72e2FF181144273C988f9b993a35755d9d);   // testnet

        //tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;  mainet
        tokenAdress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;    //testnet
        BusdInterface = IERC20(tokenAdress);
    }


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
        uint256 compoundCount;
        uint256 withdrawCount;
        uint256 cycleCount;
    }

    struct claimDaily {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct userWithdrawal {
        address user_address;
        uint256 amount;
        uint256 count;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }

    struct userTotalCompound {
        address user_address;
        uint256 amount;
    }

     struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 

    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalCompound) public totalCompound;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => refferal_withdraw) public refTotalWithdraw;

    function startProject() public noReentrant  {
        require(msg.sender == dev, "only the owner can start the project");
        require(INIT == false, "project not started yet");
        INIT = true;
    }

    // invest function 
    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(INIT == true, "Contract does not launch yet");
        require(_amount>=min && _amount <= max, "Invalid amount");
        require(investments[msg.sender].invested == 0, "Only one active deposit");


        BusdInterface.transferFrom(msg.sender,address(this),_amount);

        if(!checkAlready()){
        uint256 ref_fee_add = refFee(_amount);
        if(_ref != address(0) && _ref != msg.sender) {
         uint256 ref_last_balance = refferal[_ref].reward;
         uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
         refferal[_ref] = refferal_system(_ref,totalRefFee);
        }
        else {
           BusdInterface.transfer(dev,ref_fee_add);
        }

        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment,0,0,0);

        // Claim Setting
       uint256 claimTimeStart = block.timestamp;
       uint256 claimTimeEnd = block.timestamp + TIME_STEP;

       claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
        
       // fees 
        uint256 total_fee = depositFee(_amount);
        BusdInterface.transfer(dev,total_fee);
        }
        else {
        uint256 ref_fee_add = refFee(_amount);
        if(_ref != address(0) && _ref != msg.sender) {
         uint256 ref_last_balance = refferal[_ref].reward;
         uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
         refferal[_ref] = refferal_system(_ref,totalRefFee);
        }
        else {
           BusdInterface.transfer(dev,ref_fee_add);
        }

        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment,0,0,0);

       // fees 
        uint256 total_fee = depositFee(_amount);
        BusdInterface.transfer(dev,total_fee);
        }
    }

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 userInvestment = investments[_userAddress].invested;
        uint256 userDailyReturn = DailyRoi(userInvestment);

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
        require(INIT == true, "contract does not launch yet");
        require(approvedWithdrawal[msg.sender].count == claim_cycle, "You must have claimed 5 times to withdraw");
        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
        uint256 wFee = withdrawFee(aval_withdraw);
        uint256 totalAmountToWithdraw = SafeMath.sub(aval_withdraw,wFee); 

        if(investments[msg.sender].compoundCount < compound_step){
            uint256 mFee = mandatoryFee(aval_withdraw);
            totalAmountToWithdraw = SafeMath.sub(totalAmountToWithdraw,mFee); 
        }

        investments[msg.sender].cycleCount = investments[msg.sender].cycleCount.add(1);

        if(investments[msg.sender].cycleCount < max_cycle){
            investments[msg.sender].withdrawCount = investments[msg.sender].withdrawCount.add(1);
        }else{
            investments[msg.sender] = user_investment_details(msg.sender,0,0,0,0);
        }

        BusdInterface.transfer(msg.sender,totalAmountToWithdraw);	
        BusdInterface.transfer(dev,wFee);
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,0,0);

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + TIME_STEP;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        uint256 amount = totalWithdraw[msg.sender].amount;

        uint256 totalAmount = SafeMath.add(amount,aval_withdraw);

        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);
    }   

    function compound() public noReentrant { 
        require(INIT == true, "contract does not launch yet");
        require(approvedWithdrawal[msg.sender].count == claim_cycle, "user must have claimed 5 times to withdraw");
        require(investments[msg.sender].compoundCount < max_compound_count, "the maximum compound count is 3");
        require(investments[msg.sender].withdrawCount== 0, "You have already harvested");
        uint256 totalAmountToCompound = approvedWithdrawal[msg.sender].amount;  
        
        //create new deposit
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = totalAmountToCompound;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        uint256 userCompounCount = investments[msg.sender].compoundCount;
        uint256 userCycleCount = investments[msg.sender].cycleCount;
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment,userCompounCount.add(1),0,userCycleCount.add(1));
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,0,0);

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + TIME_STEP;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
        
        uint256 amount = totalCompound[msg.sender].amount;
        uint256 totalAmount = SafeMath.add(amount,totalAmountToCompound);
        totalCompound[msg.sender] = userTotalCompound(msg.sender,totalAmount);
    }

    function claimDailyRewards() public noReentrant{
        require(INIT == true, "contract does not launch yet");
        require(claimTime[msg.sender].deadline <= block.timestamp, "You cant claim");

        uint256 rewards = userReward(msg.sender);

        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;
        uint256 currentApprovedCount = approvedWithdrawal[msg.sender].count;

        require(currentApprovedCount < claim_cycle, "You can claim maximum of 5 times in a cycle");

        uint256 value = SafeMath.add(rewards,currentApproved);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value,currentApprovedCount.add(1));
        uint256 amount = totalRewards[msg.sender].amount;
        uint256 totalRewardAmount = SafeMath.add(amount,rewards);
        totalRewards[msg.sender].amount=totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + TIME_STEP;

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
    }

    function Ref_Withdraw() external noReentrant {
        require(INIT == true, "contract does not launch yet");
        uint256 value = refferal[msg.sender].reward;

        BusdInterface.transfer(msg.sender,value);

        refferal[msg.sender] = refferal_system(msg.sender,0);

        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;

        uint256 totalValue = SafeMath.add(value,lastWithdraw);

        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender,totalValue);
    }

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

    function mandatoryFee(uint256 _amount) public pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,mandatory_fee),100);
    }

    function withdraw_balance() external noReentrant { //testnet
        BusdInterface.transfer(msg.sender, getContractBalance());
    }

    function getContractBalance() public view returns (uint256) {
		return BusdInterface.balanceOf(address(this));
	}
}