/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract SoccerBusdGold is Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant min = 50 ether;
    uint256 public constant max = 5000 ether;
    uint256 public constant roi = 8;
    uint256 public constant min_roi = 4;
    uint256 public constant max_roi = 12;
    uint256 public constant claimCycleDays = 7; //7 days 
    uint256 public constant deposit_dev_fee = 5;
    uint256 public constant withdraw_dev_fee = 4;
    uint256 public constant withdraw_tvl_fee = 2;
    uint256 public constant auto_claim_tax = 3;
    uint256 public constant max_rewards = 3; //3x
    uint256 public ref_fee = 8;
    
    address public dev = 0xb0a259055c61983bf8937e4BB73B62acd52585C0;
    address public tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD Mainnet
    
    bool public init = false;

    IERC20 busd = IERC20(tokenAdress);

    uint256 public constant jackpot_percent = 1;

    struct jackpot_info {
        address lastWinner;
        uint256 depositAmount;
        uint256 drawTime;
    }

    jackpot_info public jackpot;

    struct today_big_deposit {
        address depositorAddress;
        uint256 depositAmount;
    }

    today_big_deposit public todayBigDeposit;    

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

    mapping(address => uint256) public userWithdrawCount;
    mapping(address => uint256) public userDepositCount;
    mapping(address => uint256) public userROI;
    mapping(address => bool) public autoClaimEnabled;
    
    // getROI function
    function getROI(address userAddress) public view returns(uint256){
        return (userROI[userAddress]);
    }

    function getROIByAddress(address userAddress) public view returns(uint256){
        return (userROI[userAddress]);
    }

    // setROI function
    function setROI(bool isIncrement) internal {
        if(isIncrement == false){
            userROI[msg.sender]--;     
        }else {
            userROI[msg.sender]++;
        }

        if(userROI[msg.sender] < 4){
            userROI[msg.sender] = min_roi;
        }
        
        if(userROI[msg.sender] > 12){
            userROI[msg.sender] = max_roi;
        }
    }

    function distributeJackpot() public {
        require(((block.timestamp - jackpot.drawTime)/3600) > 24,"Jackpot can be announced only after 24 hours of last draw");
        jackpot.lastWinner = todayBigDeposit.depositorAddress;
        jackpot.depositAmount = todayBigDeposit.depositAmount;
        jackpot.drawTime = block.timestamp;

        uint256 jackpotAmount = SafeMath.div(SafeMath.mul(busd.balanceOf(address(this)),jackpot_percent),100);
        busd.transfer(jackpot.lastWinner, jackpotAmount);

        todayBigDeposit.depositAmount = 0;
        todayBigDeposit.depositorAddress = address(0);
    }

    // invest function 
    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(init, "Not Started Yet");
        require(_amount>=min && _amount <= max, "Cannot Deposit");

        if(userDepositCount[msg.sender] == 0) {
            userROI[msg.sender] = roi;
        }

        if(_amount > todayBigDeposit.depositAmount){
            todayBigDeposit.depositAmount = _amount;
            todayBigDeposit.depositorAddress = msg.sender;
        }

        if(!checkAlready()) {
            uint256 ref_fee_add = refFee(_amount);
            if(_ref != address(0) && _ref != msg.sender) {
                uint256 ref_last_balance = referral[_ref].reward;
                uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);
                referral[_ref] = referral_system(_ref,totalRefFee);
            }

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 userCurrentInvestment = _amount;
            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

            // weekly withdraw 
            uint256 weeklyStart = block.timestamp;
            uint256 deadline_weekly = block.timestamp + (claimCycleDays * 86400);

            weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

            // claim Setting
            uint256 claimTimeStart = block.timestamp;
            uint256 claimTimeEnd = block.timestamp + 1 days;

            claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
                
            // fees 
            // uint256 total_fee = depositFee(_amount);
            uint256 deposit_dev_amount = SafeMath.div(SafeMath.mul(_amount,deposit_dev_fee),100);
            busd.transferFrom(msg.sender, address(this), _amount);
            busd.transfer(dev, deposit_dev_amount);

        } else {

            uint256 ref_fee_add = refFee(_amount);
            
            uint256 ref_last_balance = referral[dev].reward;
            uint256 totalRefFee = SafeMath.add(ref_fee_add,ref_last_balance);   
            referral[dev] = referral_system(dev,totalRefFee);
            

            // investment details
            uint256 userLastInvestment = investments[msg.sender].invested;
            uint256 userCurrentInvestment = _amount;

            if(userCurrentInvestment >= SafeMath.div(SafeMath.mul(userLastInvestment,80),100)){
                userDepositCount[msg.sender]++;
                setROI(true);
            }

            uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
            investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);
        
            // fees 
            uint256 deposit_dev_amount = SafeMath.div(SafeMath.mul(_amount,deposit_dev_fee),100);
            busd.transferFrom(msg.sender, address(this), _amount);
            busd.transfer(dev, deposit_dev_amount);
        }
    }

    // reinvest function 
    function reDeposit(uint256 _amount) internal  {       
        userDepositCount[msg.sender]++;
        setROI(true);

        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);
    }

    function referralReDeposit(uint256 _amount) internal  {       
        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = SafeMath.add(userLastInvestment,userCurrentInvestment);
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);
    }

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 userInvestment = investments[_userAddress].invested;
        uint256 userDailyReturn = DailyRoi(userInvestment,_userAddress);

        if(autoClaimEnabled[_userAddress]){
             // invested time
            uint256 claimInvestTime = claimTime[_userAddress].startTime;
            uint256 claimInvestEnd = claimTime[_userAddress].deadline;

            uint256 totalTime = SafeMath.sub(claimInvestEnd,claimInvestTime);

            uint256 perCycleRoi = userDailyReturn * claimCycleDays;
            uint256 value = SafeMath.div(perCycleRoi,totalTime);

            uint256 nowTime = block.timestamp;

            if (claimInvestEnd>= nowTime) {
                uint256 earned = SafeMath.sub(nowTime,claimInvestTime);
                uint256 totalEarned = SafeMath.mul(earned, value);
                return totalEarned;
            } else {
                return (userDailyReturn * claimCycleDays);
            }
        }else {
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
    }

    function getApprovedWithdrawal(address userAddress) public view returns(uint256){
        if(autoClaimEnabled[userAddress]){
            uint256 userRewards = userReward(userAddress);
            uint256 userApprovedWithdrawal = approvedWithdrawal[msg.sender].amount;
            
            return SafeMath.add(userRewards,userApprovedWithdrawal);
        }else{
            return approvedWithdrawal[msg.sender].amount;
        }
    }

    function enableAutoClaim() public {
        require(autoClaimEnabled[msg.sender] == false,"Auto claim is already enabled for this user");
        
        uint256 rewards = userReward(msg.sender);

        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;

        uint256 value = SafeMath.add(rewards,currentApproved);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; //hhnew
        uint256 totalRewardAmount = SafeMath.add(amount,rewards); //hhnew
        totalRewards[msg.sender].amount=totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + (claimCycleDays * 86400);

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + (claimCycleDays * 86400);

        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

        autoClaimEnabled[msg.sender] = true;
    }

    function withdrawal() public noReentrant {
        require(init, "Not Started Yet");    
        require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");
        require(totalRewards[msg.sender].amount <= SafeMath.mul(investments[msg.sender].invested, max_rewards), "You have calimed maximum rewards of your initial depostit - Reinvest using another wallet!");

        if(autoClaimEnabled[msg.sender]){
            autoClaimRewards();
        }

        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
        uint256 aval_withdraw2 = SafeMath.div(aval_withdraw,2); // divide the fees
        uint256 wFee = withdrawFee(aval_withdraw2); // changed from aval_withdraw
        uint256 wDevfee = SafeMath.div(SafeMath.mul(aval_withdraw2,withdraw_dev_fee),100);
        uint256 totalAmountToWithdraw = SafeMath.sub(aval_withdraw2,wFee); // changed from aval_withdraw to aval_withdraw2
        
        if(autoClaimEnabled[msg.sender]){
            uint256 autoClaimFee = SafeMath.div(SafeMath.mul(aval_withdraw2,auto_claim_tax),100);
            uint256 totalFee = SafeMath.add(wFee,autoClaimFee);
            totalAmountToWithdraw = SafeMath.sub(aval_withdraw2,totalFee);
            wDevfee = SafeMath.add(wDevfee,autoClaimFee);
        }
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,aval_withdraw2);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + (claimCycleDays * 86400);

        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

        uint256 amount = totalWithdraw[msg.sender].amount;

        uint256 totalAmount = SafeMath.add(amount,aval_withdraw2);

        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);
        
        userWithdrawCount[msg.sender]++;
        setROI(false);

        busd.transfer(msg.sender, totalAmountToWithdraw);
        busd.transfer(dev, wDevfee);
    }

    function withdrawAndRedeposit() public noReentrant {
        require(init, "Not Started Yet");    
        require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");
        require(totalRewards[msg.sender].amount <= SafeMath.mul(investments[msg.sender].invested, max_rewards), "You have calimed maximum rewards of your initial depostit - Reinvest using another wallet!");

        if(autoClaimEnabled[msg.sender]){
            autoClaimRewards();
        }

        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
        uint256 aval_withdraw2 = SafeMath.div(aval_withdraw,4); // divide the fees
        uint256 wFee = withdrawFee(aval_withdraw2); // changed from aval_withdraw
        uint256 wDevfee = SafeMath.div(SafeMath.mul(aval_withdraw2,withdraw_dev_fee),100);
        uint256 totalAmountToWithdraw = SafeMath.sub(aval_withdraw2,wFee); // changed from aval_withdraw to aval_withdraw2
        
        if(autoClaimEnabled[msg.sender]){
            uint256 autoClaimFee = SafeMath.div(SafeMath.mul(aval_withdraw2,auto_claim_tax),100);
            uint256 totalFee = SafeMath.add(wFee,autoClaimFee);
            totalAmountToWithdraw = SafeMath.sub(aval_withdraw2,totalFee);
            wDevfee = SafeMath.add(wDevfee,autoClaimFee);
        }

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,aval_withdraw2);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + claimCycleDays * 86400;

        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

        uint256 amount = totalWithdraw[msg.sender].amount;

        uint256 totalAmount = SafeMath.add(amount,aval_withdraw2);

        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);
        
        uint256 redepositAmount = SafeMath.div(aval_withdraw2,2);
        reDeposit(redepositAmount);

        busd.transfer(msg.sender, totalAmountToWithdraw);
        busd.transfer(dev, wDevfee);
    }

    function autoClaimRewards() public {
        uint256 rewards = userReward(msg.sender);

        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;

        uint256 value = SafeMath.add(rewards,currentApproved);

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; //hhnew
        uint256 totalRewardAmount = SafeMath.add(amount,rewards); //hhnew
        totalRewards[msg.sender].amount=totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + (claimCycleDays * 86400);

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
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
        uint256 claimTimeEnd = block.timestamp + 1 days;

        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        if(((block.timestamp - jackpot.drawTime)/3600) > 24){
            distributeJackpot();
        }
    }

    function Ref_Withdraw() external noReentrant {
        require(init, "Not Started Yet");
        require(checkAlready(),"You do not have any active investments");
        
        uint256 value = referral[msg.sender].reward;

        uint256 redepositAmount = SafeMath.div(value,2);
        uint256 refWithdrawAmount = SafeMath.div(value,2);

        referralReDeposit(redepositAmount);
        busd.transfer(msg.sender, refWithdrawAmount);

        referral[msg.sender] = referral_system(msg.sender,0);

        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;

        uint256 totalValue = SafeMath.add(value,lastWithdraw);

        refTotalWithdraw[msg.sender] = referral_withdraw(msg.sender,totalValue);
    }

    // initialized the market
    function signal_market() public onlyOwner {
        init = true;
        jackpot.drawTime = block.timestamp;
    }

    // other functions
    function DailyRoi(uint256 _amount, address userAddress) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,getROI(userAddress)),100);
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
        return SafeMath.div(SafeMath.mul(_amount,deposit_dev_fee),100);
    }
    

    function refFee(uint256 _amount) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(_amount,ref_fee),100);
    }


    function withdrawFee(uint256 _amount) public pure returns(uint256) {
        uint256 totalWithdrawFee = SafeMath.add(withdraw_dev_fee,withdraw_tvl_fee);
        return SafeMath.div(SafeMath.mul(_amount,totalWithdrawFee),100);
    }
    

    function getBalance() public view returns(uint256){
        return busd.balanceOf(address(this));
    }
}