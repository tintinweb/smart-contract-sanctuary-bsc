/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

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

contract OpenFundsV2 is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    IERC20 private BusdInterface;
    address public dev = 0xE5575Dd2ff93853D6475A63fa7757a80200C2259;
    uint256 public constant deposit_fee = 6;
    uint256 public constant withdraw_fee = 3;
    address public tokenAdress;
    bool public init = false;
    constructor() {
    tokenAdress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; 
    BusdInterface = IERC20(tokenAdress);
                 }

    struct user_investment_details {
        address user_address;
        uint256 invested;
        uint256 last_withdraw;
        uint256 deadline;
        uint256 roi;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }


    mapping(address => user_investment_details) public investPlan1;
    mapping(address => user_investment_details) public investPlan2;
    mapping(address => user_investment_details) public investPlan3;

    mapping(address => userTotalWithdraw) public totalWithdrawPlan1;
    mapping(address => userTotalWithdraw) public totalWithdrawPlan2;
    mapping(address => userTotalWithdraw) public totalWithdrawPlan3;

    uint256 _min = 0;
    uint256 userLastInvestment =0;
    // invest function 
    function deposit(uint256 plan , uint256 _amount) public noReentrant  {
        require(init, "Not Started Yet");
        if (plan == 1) {
            require(!checkPlan1Already(),"You have already join this plan!");
            _min  = 0 ether;
            userLastInvestment = investPlan1[msg.sender].invested;
            uint256 userCurrentInvestment = _amount;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investPlan1[msg.sender] = user_investment_details(msg.sender,totalInvestment,block.timestamp,block.timestamp + 3 minutes,15);
        } else if (plan == 2) {
            require(!checkPlan2Already(),"You have already join this plan!");
            _min = 0 ether;
            userLastInvestment = investPlan2[msg.sender].invested;
            uint256 userCurrentInvestment = _amount;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investPlan2[msg.sender] = user_investment_details(msg.sender,totalInvestment,block.timestamp,block.timestamp + 3 minutes,20);
        } else if (plan == 3) {
            require(!checkPlan3Already(),"You have already join this plan!");
            _min = 0 ether;
            userLastInvestment = investPlan3[msg.sender].invested;
            uint256 userCurrentInvestment = _amount;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investPlan3[msg.sender] = user_investment_details(msg.sender,totalInvestment,block.timestamp,block.timestamp + 3 minutes,30);
        } else {
            require(false,'Wrong plan!');
        }
        
        
        require(_amount>=_min , "Cannot Deposit");

        // fees 
        uint256 total_fee = depositFee(_amount);
        uint256 total_contract = SafeMath.sub(_amount,total_fee);
        BusdInterface.transferFrom(msg.sender,dev,total_fee);
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);
    }

    function userReward(address _userAddress, uint256 plan) public view returns(uint256) {
        
        uint256 userInvestment = 0;
        uint256 roi = 0;
        uint256 deadline = 0;
        uint256 lastWithdraw = 0;
        if(plan == 1) {
            userInvestment =  investPlan1[_userAddress].invested;
            roi =  investPlan1[_userAddress].roi;
            deadline = investPlan1[_userAddress].deadline;
            lastWithdraw = investPlan1[_userAddress].last_withdraw;
        } else if (plan == 2) {
            userInvestment =  investPlan2[_userAddress].invested;
            roi =  investPlan2[_userAddress].roi;
            deadline = investPlan2[_userAddress].deadline;
            lastWithdraw = investPlan2[_userAddress].last_withdraw;
        } else if (plan == 3) {
            userInvestment =  investPlan3[_userAddress].invested;
            roi =  investPlan3[_userAddress].roi;
            deadline = investPlan3[_userAddress].deadline;
            lastWithdraw = investPlan3[_userAddress].last_withdraw;
        } else {
            require(false,'Wrong plan!');
        }

        uint256 nowTime = block.timestamp;
        uint256 userEarns = SafeMath.mul(DailyRoi(userInvestment,roi),3);

        // invested time
        uint256 totalDeadline = deadline - lastWithdraw;
        uint256 stakeTime = nowTime - lastWithdraw;
        if(deadline>= nowTime) {
            uint256 totalEarned = SafeMath.div(SafeMath.mul(stakeTime, userEarns),totalDeadline);
            return totalEarned;
        }
        else {
          
            return userEarns;
        }
    }

    function withdrawal(uint256 plan) public noReentrant {
        require(init, "Not Started Yet");    

        uint256 totalInvestment = 0;
        uint256 deadline = 0;
        uint256 roi = 0;
        uint256 lastTotalWithdraw = 0;
        if(plan == 1) {
            totalInvestment =  investPlan1[msg.sender].invested;
            require(totalWithdrawPlan1[msg.sender].amount <= SafeMath.mul(totalInvestment,3), "You cant withdraw you have collected three times Already"); // hh new
            deadline = investPlan1[msg.sender].deadline;
            roi =  investPlan1[msg.sender].roi;
            lastTotalWithdraw = totalWithdrawPlan1[msg.sender].amount;   
        } else if (plan == 2) {
            totalInvestment =  investPlan2[msg.sender].invested;
            require(totalWithdrawPlan2[msg.sender].amount <= SafeMath.mul(totalInvestment,4), "You cant withdraw you have collected for times Already"); // hh new
            deadline = investPlan2[msg.sender].deadline;
            roi =  investPlan2[msg.sender].roi;
            lastTotalWithdraw = totalWithdrawPlan2[msg.sender].amount;
        } else if (plan == 3) {
            totalInvestment =  investPlan3[msg.sender].invested;
            require(totalWithdrawPlan3[msg.sender].amount <= SafeMath.mul(totalInvestment,5), "You cant withdraw you have collected five times Already"); // hh new
            deadline = investPlan3[msg.sender].deadline;
            roi =  investPlan3[msg.sender].roi;
            lastTotalWithdraw = totalWithdrawPlan3[msg.sender].amount;
        } else {
            require(false,"Wrong plan!");
        }
        require(totalInvestment >0 ,"Wrong!");
        require(deadline <= block.timestamp, "You cant withdraw");
        
        uint256 userEarns = SafeMath.mul(DailyRoi(totalInvestment,roi),3);
        uint256 wFee = withdrawFee(userEarns);

        BusdInterface.transfer(msg.sender,userEarns );
        BusdInterface.transfer(dev,wFee);
        

        if(plan == 1) {
            investPlan1[msg.sender] = user_investment_details(msg.sender,totalInvestment,block.timestamp,block.timestamp + 3 minutes,15);
            totalWithdrawPlan1[msg.sender] = userTotalWithdraw(msg.sender,lastTotalWithdraw + userEarns);
        } else if (plan == 2) {
            totalWithdrawPlan2[msg.sender] = userTotalWithdraw(msg.sender,lastTotalWithdraw + userEarns);
            investPlan2[msg.sender] = user_investment_details(msg.sender,totalInvestment,block.timestamp,block.timestamp + 3 minutes,20);
        } else if (plan == 3) {
            totalWithdrawPlan3[msg.sender] = userTotalWithdraw(msg.sender,lastTotalWithdraw + userEarns);  
            investPlan3[msg.sender] = user_investment_details(msg.sender,totalInvestment,block.timestamp,block.timestamp + 3 minutes,30);
        } else {
            require(false,'Wrong plan!');
        }

    }

    function unStake(uint256 plan) external noReentrant {
        require(init, "Not Started Yet");
        uint256 I_investment = 0;
        uint256 t_withdraw = 0;
        if (plan == 1) {
            I_investment = investPlan1[msg.sender].invested;
            t_withdraw = totalWithdrawPlan1[msg.sender].amount;
        } else if (plan == 2) {
            I_investment = investPlan2[msg.sender].invested;
            t_withdraw = totalWithdrawPlan2[msg.sender].amount;
        } else if (plan == 3) {
            I_investment = investPlan3[msg.sender].invested;
            t_withdraw = totalWithdrawPlan3[msg.sender].amount;
        } else {
            require(false,"Unknown Plan!");
        }
        

        require(I_investment > t_withdraw, "You already withdraw a lot than your investment");
        uint256 lastFee = depositFee(I_investment);
        uint256 currentBalance = SafeMath.sub(I_investment,lastFee);

        uint256 UnstakeValue = SafeMath.sub(currentBalance,t_withdraw);

        uint256 UnstakeValueCore = SafeMath.div(SafeMath.mul(UnstakeValue,70),100);

        uint256 UnstakeValueReturn = SafeMath.div(SafeMath.mul(UnstakeValue, 30),100);

        BusdInterface.transfer(msg.sender,UnstakeValueReturn);

        BusdInterface.transfer(dev,UnstakeValueCore);

        if (plan == 1) {
            investPlan1[msg.sender] = user_investment_details(msg.sender,0,block.timestamp,block.timestamp,0);
            totalWithdrawPlan1[msg.sender] = userTotalWithdraw(msg.sender,0);
        } else if (plan == 2) {
            investPlan2[msg.sender] = user_investment_details(msg.sender,0,block.timestamp,block.timestamp,0);
            totalWithdrawPlan2[msg.sender] = userTotalWithdraw(msg.sender,0);
        } else if (plan == 3) {
            investPlan3[msg.sender] = user_investment_details(msg.sender,0,block.timestamp,block.timestamp,0);
            totalWithdrawPlan3[msg.sender] = userTotalWithdraw(msg.sender,0);
        } else {
            require(false,"Unknown Plan!");
        }
    }

    // initialized the market

    function startMarket() public onlyOwner {
        init = true;
    }


    // other functions

    function DailyRoi(uint256 _amount, uint256 _roi) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,_roi),1000);
    }
    
    function checkPlan1Already() public view returns(bool) {
         address _address= msg.sender;
        if(investPlan1[_address].user_address==_address && investPlan1[_address].invested !=0){
            return true;
        }
        else{
            return false;
        }
    }

    function checkPlan2Already() public view returns(bool) {
         address _address= msg.sender;
        if(investPlan1[_address].user_address==_address && investPlan2[_address].invested !=0){
            return true;
        }
        else{
            return false;
        }
    }

    function checkPlan3Already() public view returns(bool) {
         address _address= msg.sender;
        if(investPlan1[_address].user_address==_address && investPlan3[_address].invested !=0){
            return true;
        }
        else{
            return false;
        }
    }

    function depositFee(uint256 _amount) public pure returns(uint256){
     return SafeMath.div(SafeMath.mul(_amount,deposit_fee),100);
    }

    function withdrawFee(uint256 _amount) public pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,withdraw_fee),100);
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }

}