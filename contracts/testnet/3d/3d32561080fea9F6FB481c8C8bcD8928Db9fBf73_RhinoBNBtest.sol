/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

contract RhinoBNBtest is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant min = 0.05 ether;
    uint256 public constant max = 50 ether;
    uint256 public roi = 5;
    uint256 public constant fee = 6;
    uint256 public constant withdraw_fee = 7;
    uint256 public daysToWithdraw = 168 * 60 * 60;    //Can withdraw every 7 days 
    uint256 public daysToClaim = 24 * 60 * 60;       //Claim every 1 day  
    uint256 public ref_fee = 7;
    address payable public dev;
    address payable public dev1;
    bool public init = false;
    bool public alreadyInvested = false;


    struct referral_system {
        address ref_address;
        uint256 reward;
    }

    struct referral_withdraw {
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

    mapping(address => referral_system) public referral;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => referral_withdraw) public refTotalWithdraw;

    constructor(address payable _dev, address payable _dev1) {
        dev = _dev;
        dev1 = _dev1;
    }
    
    // invest function 
    function deposit(address _ref) public payable  {
        require(init, "Not Started Yet");
        require(msg.value>=min && msg.value <= max, "Cannot Deposit");
       
        if(!checkAlready()) {
            uint256 ref_fee_add = refFee(msg.value);
            if(_ref != address(0) && _ref != msg.sender) {
                uint256 ref_last_balance = referral[_ref].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);
                referral[_ref] = referral_system(_ref,totalRefFee);
            }

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 userCurrentInvestment = msg.value;
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
            uint256 total_fee = depositFee(msg.value).div(2);

            dev.transfer(total_fee);
            dev1.transfer(total_fee);
        } else {
            uint256 ref_fee_add = refFee(msg.value);
            if(_ref != address(0) && _ref != msg.sender) {
                uint256 ref_last_balance = referral[_ref].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
                referral[_ref] = referral_system(_ref,totalRefFee);
            }

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 userCurrentInvestment = msg.value;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);
        
            // fees 
            uint256 total_fee = depositFee(msg.value).div(2);
            dev.transfer(total_fee);
            dev1.transfer(total_fee);
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

        if (claimInvestEnd>= nowTime) {
            uint256 earned = SafeMath.sub(nowTime,claimInvestTime);
            uint256 totalEarned = SafeMath.mul(earned, value);
            return totalEarned;
        } else {
            return userDailyReturn;
        }
    }

    function withdrawal() public noReentrant {
        require(init, "Not Started Yet");    
        require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");
        require(totalRewards[msg.sender].amount <= SafeMath.mul(investments[msg.sender].invested,3), "You cant withdraw you have collected 3 times Already");
        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;

        if(totalWithdraw[msg.sender].amount.add(aval_withdraw) >= investments[msg.sender].invested.mul(3)){
            aval_withdraw = investments[msg.sender].invested.mul(3).sub(totalWithdraw[msg.sender].amount);
        }

        uint256 aval_withdraw2 = SafeMath.div(aval_withdraw,2);
        uint256 wFee = withdrawFee(aval_withdraw2); 
        uint256 totalAmountToWithdraw = SafeMath.sub(aval_withdraw2,wFee); 
        

        //reset to 0
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender, 0);
        
        //50% re-invested.
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(aval_withdraw2));

        //50% withdrawn
        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender, totalWithdraw[msg.sender].amount.add(aval_withdraw2));

        //reset weekly withdraw time
        weekly[msg.sender] = weeklyWithdraw(msg.sender, block.timestamp, block.timestamp.add(daysToWithdraw));

        payable(msg.sender).transfer(totalAmountToWithdraw);
        dev.transfer(wFee);
    }

    function claimDailyRewards() public noReentrant{
        require(init, "Not Started Yet");
        require(claimTime[msg.sender].deadline <= block.timestamp, "You cant claim");

        uint256 rewards = userReward(msg.sender);

        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;

        uint256 value = SafeMath.add(rewards,currentApproved);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; 
        uint256 totalRewardAmount = SafeMath.add(amount,rewards); 
        totalRewards[msg.sender].amount=totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp.add(daysToClaim);

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
       
    }

    function Ref_Withdraw() external noReentrant {
        require(init, "Not Started Yet");

        uint256 value = referral[msg.sender].reward;

        referral[msg.sender] = referral_system(msg.sender,0);

        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;

        uint256 totalValue = SafeMath.add(value,lastWithdraw);

        refTotalWithdraw[msg.sender] = referral_withdraw(msg.sender,totalValue);

        payable(msg.sender).transfer(value);
    }

    // initialized the market
    function signal_market() public onlyOwner {
        init = true;
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

    function refFee(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,ref_fee),100);
    }

    function withdrawFee(uint256 _amount) public pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,withdraw_fee),100);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}