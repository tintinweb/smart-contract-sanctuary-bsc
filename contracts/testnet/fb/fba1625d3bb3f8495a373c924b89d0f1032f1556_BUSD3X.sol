/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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

    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

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

contract BUSD3X is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    IERC20 private BusdInterface;

       bool public started;
    uint256 public constant min = 50 ether;
    uint256 public constant max = 10000 ether;
    uint256 public constant fee = 1;
    uint256 public constant ref_fee = 3;
    uint256 public roi = 3; //make constant in mainnet
    uint256 public withdrawDays = 604800; //7 days
    uint256 public claimDays = 86400; //1 days

    address private dev;
    address private dev1;
    address private partner1;
    address private partner2;
    address private partner3;
    address public tokenAdress;

    uint256 public totalDeposits;
    uint256 public totalCompounded;
    uint256 public totalReinvested;
    uint256 public totalWithdrawn;
    uint256 public dateLaunched;

    
       bool public lastDepositActivated;
    address public potentialLastDepositWinner;
    uint256 public lastDepositStartTime;
    uint256 public totalLastDepositJackpot;
    uint256 public lastDepositTimeStep = 3600; //1 hours
    uint256 public lastDepositEndTime; //1 hours
    uint256 public currentLastDepositPot = 0;
    uint256 public currentLastBuyRound = 1;
    uint256 private maxPotBalance = 3000 ether;
    
    address public currentLastDepositWinner;
    uint256 public currentlastDepositRewarded;
    uint256 public currentlastDepositEnd;

    constructor(address _dev,address _dev1,address _partner1,address _partner2,address _partner3) {
        tokenAdress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        BusdInterface = IERC20(tokenAdress);
        dev = _dev;
        dev1 = _dev1;
        partner1 = _partner1;
        partner2 = _partner2;
        partner3 = _partner3;
    }

    struct refferal_system {
        address ref_address;
        uint256 reward;
    }

    struct refferal_withdraw {
        address ref_address;
        uint256 totalWithdraw;
        uint256 totalCompounded;
        uint256 totalReinvested;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
        uint256 trueDeposit;
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
        uint256 amountReinvested;
    }

    struct userLastDepositWithdraw {
        address user_address;
        uint256 amount;
        uint256 amountReinvested;
    }

    struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 

    struct LastBuyHistory {
        uint256 round;
        address winnerAddress;
        uint256 amountRewards;
        uint256 amountReInvested;
        uint256 drawTime;
    }

    LastBuyHistory[] internal lastBuyHistory;
    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userLastDepositWithdraw) public totalLastDepositWithdraw;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => refferal_withdraw) public refTotalWithdraw;

    event LastBuyEvent(uint256 round, address indexed winnerAddress, uint256 amountRewards, uint256 amountReInvested, uint256 drawTime);

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 totalTime = claimTime[_userAddress].deadline.sub(claimTime[_userAddress].startTime);
        uint256 value = DailyRoi(investments[_userAddress].invested).div(totalTime);

        if(claimTime[_userAddress].deadline >= block.timestamp) {
            uint256 earned = block.timestamp.sub(claimTime[_userAddress].startTime);
            return earned.mul(value);
        }
        else {
            return DailyRoi(investments[_userAddress].invested);
        }
    }

    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(started, "Not Launched!");
        require(_amount >= min && _amount <= max, "User cannot deposit. Please check minimum/maximum deposit.");

        //referral bonus
        if(_ref != address(0) && _ref != msg.sender && investments[_ref].invested > 0){
            uint256 ref_fee_add = refFee(_amount);
            refferal[_ref] = refferal_system(_ref, ref_fee_add.add(refferal[_ref].reward));
        }
        
        //claim existing dividends
        if(investments[_ref].invested > 0 && userReward(msg.sender) > 0){
            uint256 rewards = userReward(msg.sender);
            approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender, approvedWithdrawal[msg.sender].amount.add(rewards));
            totalRewards[msg.sender].amount = totalRewards[msg.sender].amount.add(rewards);
        }

        //record investment
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(_amount), investments[msg.sender].trueDeposit.add(_amount));

        //reset weekly withdraw time
        weekly[msg.sender] = weeklyWithdraw(msg.sender, block.timestamp, block.timestamp.add(withdrawDays));

        //reset daily claim time
        claimTime[msg.sender] = claimDaily(msg.sender, block.timestamp, block.timestamp.add(claimDays));      
        
        //transfer amount
        payFeesAndGetRemaining(_amount, true, address(0));

        totalDeposits += _amount;

        if(lastDepositActivated) {
            if(block.timestamp.sub(lastDepositStartTime) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
                this.drawLastDepositWinner();
            }
            lastDepositEntry(msg.sender, _amount);
        }
    }

    function lastDepositEntry(address userAddress, uint256 amount) private {
        if(!lastDepositActivated) return;

        uint256 share = amount.mul(500).div(1000);

        if(currentLastDepositPot.add(share) > maxPotBalance){       
            currentLastDepositPot += maxPotBalance.sub(currentLastDepositPot);
        }
        else{
            currentLastDepositPot += share;
        }
        
        lastDepositStartTime = block.timestamp;
        lastDepositEndTime = block.timestamp.add(lastDepositTimeStep);
        potentialLastDepositWinner = userAddress;
    }

    function drawLastDepositWinner() external {
        require(lastDepositActivated && block.timestamp.sub(lastDepositStartTime) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0));
        
        uint256 busdReward = currentLastDepositPot.div(2);

        //50% re-invested as true deposit. and will have tax, 5% sustainability tax.
        investments[potentialLastDepositWinner] = user_investment_details(potentialLastDepositWinner, investments[potentialLastDepositWinner].invested.add(busdReward.sub(projectFee(busdReward).mul(5))), investments[potentialLastDepositWinner].trueDeposit.add(busdReward.sub(projectFee(busdReward).mul(5))));

        //50% withdrawn
        totalWithdraw[potentialLastDepositWinner] = userTotalWithdraw(potentialLastDepositWinner, totalWithdraw[potentialLastDepositWinner].amount.add(busdReward), totalWithdraw[potentialLastDepositWinner].amountReinvested.add(busdReward.sub(projectFee(busdReward).mul(5))));
        
        //50% withdrawn, record in user last deposit struct
        totalLastDepositWithdraw[potentialLastDepositWinner] = userLastDepositWithdraw(potentialLastDepositWinner, totalLastDepositWithdraw[potentialLastDepositWinner].amount.add(busdReward), totalLastDepositWithdraw[potentialLastDepositWinner].amountReinvested.add(busdReward.sub(projectFee(busdReward).mul(5))));
        

        //transfer bonus
        if(getBalance() < busdReward) {
            busdReward = getBalance();
        }
        
        payFeesAndGetRemaining(busdReward, false, potentialLastDepositWinner);
        lastBuyHistory.push(LastBuyHistory(currentLastBuyRound, potentialLastDepositWinner, busdReward, busdReward, block.timestamp));
        emit LastBuyEvent(currentLastBuyRound, potentialLastDepositWinner, busdReward, busdReward, block.timestamp);
        totalLastDepositJackpot = totalLastDepositJackpot.add(currentLastDepositPot);
        
        totalWithdrawn += busdReward;
        totalReinvested += busdReward.sub(projectFee(busdReward).mul(5));

        currentLastDepositWinner = potentialLastDepositWinner;
        currentlastDepositRewarded = currentLastDepositPot;
        currentlastDepositEnd = block.timestamp;
        currentLastDepositPot = 0;
        potentialLastDepositWinner = address(0);
        lastDepositStartTime = block.timestamp; 
        currentLastBuyRound++;
    }

    function payFeesAndGetRemaining(uint256 _amount, bool fromDeposit, address addressFromLastDepositEvent) internal {
        uint256 taxFee = projectFee(_amount);
        uint256 totalAmount = _amount.sub(taxFee.mul(5));
        address toAddress = addressFromLastDepositEvent == address(0) ? msg.sender : addressFromLastDepositEvent;
        if(fromDeposit){
            BusdInterface.transferFrom(msg.sender, dev, taxFee);
            BusdInterface.transferFrom(msg.sender, dev1, taxFee);
            BusdInterface.transferFrom(msg.sender, partner1, taxFee);
            BusdInterface.transferFrom(msg.sender, partner2, taxFee);
            BusdInterface.transferFrom(msg.sender, partner3, taxFee);
            BusdInterface.transferFrom(msg.sender, address(this), totalAmount);        
        }
        else{
            BusdInterface.transfer(dev, taxFee);
            BusdInterface.transfer(dev1, taxFee);
            BusdInterface.transfer(partner1, taxFee);
            BusdInterface.transfer(partner2, taxFee);
            BusdInterface.transfer(partner3, taxFee);
            BusdInterface.transfer(toAddress, totalAmount);
        } 
    }

    function withdrawal() public noReentrant {
        require(started, "Not Launched!");    
        require(weekly[msg.sender].deadline <= block.timestamp, "User can't withdraw.");
        require(totalWithdraw[msg.sender].amount <= investments[msg.sender].invested.mul(3), "User's total withdrawn is already 3x of his investment.");
        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;

        if(totalWithdraw[msg.sender].amount.add(aval_withdraw) >= investments[msg.sender].invested.mul(3)){
            aval_withdraw = investments[msg.sender].invested.mul(3).sub(totalWithdraw[msg.sender].amount);
        }

        //current reward / 2
        uint256 aval_withdraw2 = aval_withdraw.div(2);

        //reset to 0
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender, 0);
        
        //50% re-invested as true deposit. and will have tax, 5% sustainability tax.
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(aval_withdraw2.sub(projectFee(aval_withdraw2).mul(5))), investments[msg.sender].trueDeposit.add(aval_withdraw2.sub(projectFee(aval_withdraw2).mul(5))));

        //50% withdrawn
        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender, totalWithdraw[msg.sender].amount.add(aval_withdraw2), totalWithdraw[msg.sender].amountReinvested.add(aval_withdraw2.sub(projectFee(aval_withdraw2).mul(5))));

        //reset weekly withdraw time
        weekly[msg.sender] = weeklyWithdraw(msg.sender, block.timestamp, block.timestamp.add(withdrawDays));

        //transfer amount
        if(getBalance() < aval_withdraw2) {
            aval_withdraw2 = getBalance();
        }
        
        payFeesAndGetRemaining(aval_withdraw2, false, address(0));

        totalWithdrawn += aval_withdraw;
        totalReinvested += aval_withdraw2.sub(projectFee(aval_withdraw2).mul(5));
        
        if(lastDepositActivated) {
            if(block.timestamp.sub(lastDepositStartTime) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
                this.drawLastDepositWinner();
            }
        }
    }

    function claimDailyRewards() public noReentrant{
        require(started, "Not Launched!");
        require(claimTime[msg.sender].deadline <= block.timestamp, "User can't claim yet.");

        //update withdrawable amount
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender, userReward(msg.sender).add(approvedWithdrawal[msg.sender].amount));
        
        //update available rewards
        totalRewards[msg.sender].amount = totalRewards[msg.sender].amount.add(userReward(msg.sender));

        //reset claim time
        claimTime[msg.sender] = claimDaily(msg.sender, block.timestamp, block.timestamp.add(claimDays));  
        
        if(lastDepositActivated) {
            if(block.timestamp.sub(lastDepositStartTime) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
                this.drawLastDepositWinner();
            }
        }
    }

    function compoundDailyRewards() public noReentrant {
        require(started, "Not Launched!");
        require(claimTime[msg.sender].deadline <= block.timestamp, "User can't claim yet.");
        require(investments[msg.sender].invested < investments[msg.sender].trueDeposit.mul(5), "User already reached 5x Max compound amount.");
        uint256 rewards = userReward(msg.sender);

        //over 5x subtract x5 value to total investment to get the final amount that can be compounded
        if(investments[msg.sender].invested.add(rewards) > investments[msg.sender].trueDeposit.mul(5)){
            rewards = investments[msg.sender].trueDeposit.mul(5).sub(investments[msg.sender].invested);
        }

        //100% amount will not be considered as true deposit, but will be added on top of users total investment. true deposit will remain same.
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(rewards), investments[msg.sender].trueDeposit);

        //reset claim time
        claimTime[msg.sender] = claimDaily(msg.sender, block.timestamp, block.timestamp.add(claimDays));  

        totalCompounded += rewards;

        if(lastDepositActivated) {
            if(block.timestamp.sub(lastDepositStartTime) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
                this.drawLastDepositWinner();
            }
        }
    }

    function refWithdraw() external noReentrant {
        require(started, "Not Launched!");
        uint256 value = refferal[msg.sender].reward.div(2);
        refferal[msg.sender] = refferal_system(msg.sender, 0);
        
        //50% re-invested as true deposit. real deposits will be deducted with 5% sustainability tax.
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(value.sub(projectFee(value).mul(5))), investments[msg.sender].trueDeposit.add(value.sub(projectFee(value).mul(5))));
        
        //50% referral bonus withdrawn
        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender, refTotalWithdraw[msg.sender].totalWithdraw.add(value), refTotalWithdraw[msg.sender].totalReinvested.add(value.sub(projectFee(value).mul(5))), refTotalWithdraw[msg.sender].totalCompounded);
        
        if(getBalance() < value) {
            value = getBalance();
        }

        //transfer referral bonus
        BusdInterface.transfer(msg.sender, value);

        totalWithdrawn += value;
        totalReinvested += value.sub(projectFee(value).mul(5));

        if(lastDepositActivated) {
            if(block.timestamp.sub(lastDepositStartTime) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
                this.drawLastDepositWinner();
            }
        }
    }

    function refCompound() external noReentrant {
        require(started, "Not Launched!");
        require(investments[msg.sender].invested < investments[msg.sender].trueDeposit.mul(5), "User already reached 5x Max compound amount.");
        uint256 value = refferal[msg.sender].reward;

        //over 5x subtract x5 value to total investment to get the final amount that can be compounded
        if(investments[msg.sender].invested.add(value) > investments[msg.sender].trueDeposit.mul(5)){
            value = investments[msg.sender].trueDeposit.mul(5).sub(investments[msg.sender].invested);
        }

        refferal[msg.sender] = refferal_system(msg.sender, 0);
        
        //100% amount will not be considered as true deposit, but will be added on top of users total investment. true deposit will remain same.
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(value), investments[msg.sender].trueDeposit);

        //100% referral bonus compounded
        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender, refTotalWithdraw[msg.sender].totalWithdraw, refTotalWithdraw[msg.sender].totalReinvested, refTotalWithdraw[msg.sender].totalCompounded.add(value));

        totalCompounded += value;
        if(lastDepositActivated) {
            if(block.timestamp.sub(lastDepositStartTime) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
                this.drawLastDepositWinner();
            }
        }
    }

    function launch() public onlyOwner {
        lastDepositActivated = true;
        lastDepositStartTime = block.timestamp;
        started = true; 
    }   

    function getLastBuyHistory(uint256 index) public view returns(uint256 round, uint256 roundDone, address winnerAddress, uint256 pot, uint256 reinvested, uint256 drawTime) {
		round = lastBuyHistory[index].round;
        roundDone = lastBuyHistory[index].round - 1;
		winnerAddress = lastBuyHistory[index].winnerAddress;
		pot = lastBuyHistory[index].amountRewards;
        reinvested = lastBuyHistory[index].amountReInvested;
		drawTime = lastBuyHistory[index].drawTime;
	}

    function getLastBuyInfo() public view returns(uint256 round, address potentialWinner, uint256 pot, uint256 startTime, uint256 stepTime) {
        round = currentLastBuyRound;
        potentialWinner = potentialLastDepositWinner;
        pot = currentLastDepositPot;
        startTime = lastDepositStartTime;
        stepTime = lastDepositEndTime;
    }

    function DailyRoi(uint256 _amount) public view returns(uint256) { //make pure in mainnet as it is constant
        return _amount.mul(roi).div(100);
    }

    function refFee(uint256 _amount) public pure returns(uint256) {
        return _amount.mul(ref_fee).div(100);
    }

    function projectFee(uint256 _amount) public pure returns(uint256) {
        return _amount.mul(fee).div(100);
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }
    //for testing only remove in mainnet
    function updateWithdrawDays(uint256 value) public onlyOwner {
        withdrawDays = value;
    }
    //for testing only remove in mainnet
    function updateClaimDays(uint256 value) public onlyOwner {
        claimDays = value;
    }
    //for testing only remove in mainnet
    function updateLastDepositStep(uint256 value) public onlyOwner {
        lastDepositTimeStep = value;
    }
    //for testing only remove in mainnet
    function claimTestFunds() public onlyOwner {
        BusdInterface.transfer(msg.sender, BusdInterface.balanceOf(address(this)));
    }
    //for testing only remove in mainnet
    function changeDailyROI(uint256 value) public onlyOwner {
        roi = value;
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

library SafeMath {

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
}

/** 
    4% Daily Income
    5% Dev Fee Deposit/Withdraw
    4% Ref Bonus -> User should be invested to activate referral bonus.
    2 Options:
        - User can withdraw referral bonuses where 50% will be withdrawn. 50% will be reinvested and added to user investment as true deposit.
        - User can compound all his referral bonuses and automatically be added to user total investment.
    NOTE: every withdrawal there will be a tax of 5% for the rewards that will be reinvested to the user as true deposit.   

    Withdrawals, every 7th day. 50% will be withdrawn. 50% will be reinvested and added to user investment as true deposit.
    NOTE: every withdrawal there will be a tax of 5% for the rewards that will be reinvested to the user as true deposit.

    Compound Claimable Amount Option - Users will have an option to either compound their accumulated rewards everyday and be added instantly to users total invesment,
    or claim it which will be available for withdrawal every 7th day.

    Max Compound Amount: x5 of true deposit.
    If User has reached x5, the withdrawal rules will stay the same. 50% available for withdraw and 50% will be added to user investment as true deposit.
    At this time users 5x limit will increase since the true deposited amount has increased because of the 50% invested back as true deposit.

    NO UNSTAKE FUNCTION.

    Every existing investors who will deposit on top of their existing investment 
    will auto-claim their available dividends first before the new deposits will be added to the current investment, 
    this action will also reset the investors claim/withdraw time.
**/