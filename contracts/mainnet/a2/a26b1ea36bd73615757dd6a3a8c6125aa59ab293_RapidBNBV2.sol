/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier:MIT

//------------------------------------------------------------------
//------------------------------------------------------------------
// --------------------- RAPIDBNB.IO V2 ----------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//--- 🛡️ secured with ReentrancyGuard,SafeMath --------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//-----------------------------------------------by.bitfrog®--------
//------------------------------------------------------------------

pragma solidity ^0.8.11;

abstract contract ReentrancyGuard 
{
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    // Protecting contract funds from hacker attacks.
    modifier NonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: Reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

library SafeMath 
{

    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

contract RapidBNBV2 is ReentrancyGuard {
    
    using SafeMath for uint256;

    struct Investment 
    {
        uint256 planId;
        uint256 amount;
        uint256 startTime;
        uint256 timeStep;
        uint256 earningBase;
        uint256 earningStep;
        uint256 earningsDaily;
        uint256 earningsTotal;
    }

    struct Withdrawal 
    {
        uint256 section;
        uint256 amount;
        uint256 time;
    }


    struct User 
    {
        mapping(uint256 => Investment) investments;
        mapping(uint256 => Withdrawal) withdrawals;
        uint256 investmentCount;
        uint256 withdrawalCount;
        uint256 totalInvested;
        uint256 totalWithdrawn;
        uint256 lastWithdrawTime;
        address upline;
        uint256 referralEarningsAvailable;
        uint256 referralEarningsTotal;
        uint256[5] referrals;
    }

    // USERS
    mapping(address => User) public Users;

    // CONSTANTS
    address payable private OwnerWallet;
    uint256 public constant divider = 1000;
    uint256[5]  public ReferralPercentages;
    uint256[174] public InvestmentPlans;

    // VARIABLES
    uint256 private commissionRate;
    uint256 public minDepositAmount;
    uint256 public maxDepositAmount;
    uint256 public minWithdrawalAmount;
    uint256 public minInvestmentDuration;
    uint256 public maxInvestmentDuration;

    // INVESTMENT DEFAULTS
    uint256 public timeStep;
    uint256 public earningBase;
    uint256 public earningStep;

    // TOTALS
    uint256 public TotalUsers;
    uint256 public TotalDeposited;
    uint256 public TotalWithdrawn;

    // EVENTS
    event InvestEvent(address indexed userAddress, uint256 amount);
    event WithdrawEvent(address indexed userAddress, uint256 amount);
    event ReferralEarningsReInvestEvent(address indexed userAddress, uint256 amount);
    event ReferralEarningsWithdrawEvent(address indexed userAddress, uint256 amount);
    event NewUserEvent(address indexed userAddress);
    event AddReferralEarningEvent(address indexed userAddress, address indexed from, uint256 amount);
    event CommissionRateChangedEvent(uint256 commissionRate);
    event DepositRangeChangedEvent(uint256 minDepositAmount, uint256 maxDepositAmount);
    event RatesChangedEvent(uint256 earningBase, uint256 earningStep);
    event MinWithdrawalAmountChangedEvent(uint256 minWithdrawalAmount);
    event InvestmentDurationsChangedEvent(uint256 minInvestmentDuration, uint256 maxInvestmentDuration);
    event ReferralPercentagesChanged(uint256 level1, uint256 level2, uint256 level3, uint256 level4, uint256 level5);

    receive() external payable {}

    // MODIFIERS
    modifier OnlyOwner() {
        require(msg.sender == _owner(), "Ownable: caller is not the owner wallet");
        _;
    }

    function _owner() private view returns (address) {
        return OwnerWallet;
    }

    modifier NotContract() 
    {
        require(!_isContract(msg.sender), "Contracts not allowed*");
        require(msg.sender == tx.origin, "Contracts not allowed**");
        _;
    }

    function _isContract(address addr) internal view returns (bool) 
    {
        // Protecting contract funds from bad smart contracts.
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    constructor(address payable _ownerWallet) 
    {

        OwnerWallet = _ownerWallet;
        ReferralPercentages = [50, 30, 20, 10, 5];

        commissionRate = 100; // 10%
        minDepositAmount = 0.1 ether;
        maxDepositAmount = 1000 ether;
        minWithdrawalAmount = 0.01 ether;
        maxInvestmentDuration = 24; 

        earningBase = 1500;
        earningStep = 72;
        timeStep = 1 days;

        // Investment Plans
        uint256 currentPlanId;
        for (uint256 i = 0; i < (180 + 1); i++) 
        {
            if (i >= 7)
            {
                InvestmentPlans[currentPlanId] = i;
                currentPlanId++;
            }
        }

    }

    /*
        OWNER CALLS
    */

    function OwnerSetDepositRange(uint256 _minDepositAmount, uint256 _maxDepositAmount) external OnlyOwner 
    {
        minDepositAmount = _minDepositAmount;
        maxDepositAmount = _maxDepositAmount;
        emit DepositRangeChangedEvent(minDepositAmount, maxDepositAmount);
    }

    function OwnerSetRates(uint256 _earningBase, uint256 _earningStep) external OnlyOwner 
    {
        earningBase = _earningBase;
        earningStep = _earningStep;
        emit RatesChangedEvent(earningBase, earningStep);
    }

    function OwnerSetMinWithdrawalAmount(uint256 _minWithdrawalAmount) external OnlyOwner 
    {
        minWithdrawalAmount = _minWithdrawalAmount;
        emit MinWithdrawalAmountChangedEvent(minWithdrawalAmount);
    }

    function OwnerSetMaxInvestmentDuration(uint256 _minInvestmentDuration, uint256 _maxInvestmentDuration) external OnlyOwner 
    {
        minInvestmentDuration = _minInvestmentDuration;
        maxInvestmentDuration = _maxInvestmentDuration;
        emit InvestmentDurationsChangedEvent(minInvestmentDuration, maxInvestmentDuration);
    }

    function OwnerSetCommissionRate(uint256 _commissionRate) external OnlyOwner 
    {
        commissionRate = _commissionRate;
        emit CommissionRateChangedEvent(commissionRate);
    }

    function OwnerReferralPercentages(uint256 level1, uint256 level2, uint256 level3, uint256 level4, uint256 level5) external OnlyOwner 
    {
        ReferralPercentages = [level1, level2, level3, level4, level5];
        emit ReferralPercentagesChanged(level1, level2, level3, level4, level5);
    }

    /*
        USER CALLS
    */

  
    function Invest(address referrer, uint256 planId) external payable NonReentrant NotContract {
    
        require(msg.value >= minDepositAmount && msg.value <= maxDepositAmount, "Deposited amount must be within min and max");
        require(planId >= minInvestmentDuration && planId < maxInvestmentDuration, "Invalid ivestment plan");

        _invest(msg.sender, msg.value, referrer, planId);

    }


    function _invest(address userAddress, uint256 amount, address referrer, uint256 planId) private
    {
        User storage user = Users[userAddress];

        // New User
	    if (user.investmentCount <= 0) 
        {
			user.lastWithdrawTime = block.timestamp;
            //Stats
            TotalUsers++;
            //Event
            emit NewUserEvent(userAddress);
		}

        uint256 investmentId = user.investmentCount;
        uint256 earningPercentage = earningBase.add(earningStep.mul(planId));

        user.investments[investmentId].planId = planId;
        user.investments[investmentId].amount = amount;
        user.investments[investmentId].timeStep = timeStep;
        user.investments[investmentId].earningBase = earningBase;
        user.investments[investmentId].earningStep = earningStep;
        user.investments[investmentId].earningsTotal = amount.mul(earningPercentage).div(divider);
        user.investments[investmentId].earningsDaily = user.investments[investmentId].earningsTotal.div(InvestmentPlans[planId]);
        user.investments[investmentId].startTime = block.timestamp;
        user.totalInvested = user.totalInvested.add(amount);
        user.investmentCount++;


        // Referral Addressing
		if (user.upline == address(0)) 
		{
			if (Users[referrer].investmentCount > 0 && referrer != msg.sender) 
            {
				user.upline = referrer;
			}

			address upline = user.upline;
			for (uint256 i = 0; i < ReferralPercentages.length; i++) 
            {
                if (upline != address(0)) 
                {
                    Users[upline].referrals[i] += 1;
					upline = Users[upline].upline;
                }
                else
                {
                    break;
                }
			}
			
		}

        // Referral Distribution
        if (user.upline != address(0)) 
        {
            address upline = user.upline;

            for (uint256 i = 0; i < ReferralPercentages.length; i++) 
            {
                if (upline != address(0)) 
                {
                   
                    uint256 referralEarning = amount.mul(ReferralPercentages[i]).div(divider);
                    Users[upline].referralEarningsAvailable = Users[upline].referralEarningsAvailable.add(referralEarning);
                    Users[upline].referralEarningsTotal = Users[upline].referralEarningsTotal.add(referralEarning);
                    emit AddReferralEarningEvent(Users[userAddress].upline, userAddress, referralEarning);
                    
                    upline = Users[upline].upline;
                 }
                 else
                 {
                     break;
                 }
            }
        }

        // Stats
        TotalDeposited = TotalDeposited.add(amount);

        // Commission Deduction
        OwnerWallet.transfer(amount.mul(commissionRate).div(divider));
     
        emit InvestEvent(userAddress, amount);

    }

    function Withdraw() external NonReentrant NotContract
    {
      
        require(Users[msg.sender].investmentCount > 0, "Withdraw: You did not made any investment yet");
       
        uint256 totalWithdrawableAmount  = getUserDividends(msg.sender);

        require(totalWithdrawableAmount >= minWithdrawalAmount, "Withdraw: Insufficient min withdrawal amount");
     
        _withdraw(msg.sender, totalWithdrawableAmount);

    }

    function _withdraw(address userAddress, uint256 amount) private
    {
        User storage user = Users[userAddress];

        //Record
        uint256 withdrawalId = user.withdrawalCount;
        user.withdrawals[withdrawalId].section = 0;
        user.withdrawals[withdrawalId].time = block.timestamp;
        user.withdrawals[withdrawalId].amount = amount;
        user.withdrawalCount++;

        // Reduce
        user.lastWithdrawTime = block.timestamp;
        user.totalWithdrawn = user.totalWithdrawn.add(amount);
        
        // Stats
        TotalWithdrawn = TotalWithdrawn.add(amount);
        // Withdraw
        payable(userAddress).transfer(amount);

        emit WithdrawEvent(userAddress, amount);

    }


    function ReferralEarningsReInvest(uint256 planId) external NonReentrant NotContract
    {
        User storage user = Users[msg.sender];
        require(user.referralEarningsAvailable > 0, "ReInvestReferralsEarnings: Insufficient balance");
        require(user.referralEarningsAvailable >= minDepositAmount && user.referralEarningsAvailable <= maxDepositAmount, "ReInvestReferralsEarnings: Invalid amount");

        uint256 availableReferralEarnings = user.referralEarningsAvailable;
   
        user.referralEarningsAvailable = 0;
        _invest(msg.sender, availableReferralEarnings, user.upline, planId);

        emit ReferralEarningsReInvestEvent(msg.sender, availableReferralEarnings);

    }

    function ReferralEarningsWithdraw() external NonReentrant NotContract
    {
        User storage user = Users[msg.sender];

        require(user.referralEarningsAvailable > 0, "WithdrawReferralsEarnings: Insufficient balance");
        require(user.referralEarningsAvailable >= minWithdrawalAmount, "WithdrawReferralsEarnings: Insufficient min withdrawal amount");

        uint256 availableReferralEarnings = user.referralEarningsAvailable;
     
        //Record
        uint256 withdrawalId = user.withdrawalCount;
        user.withdrawals[withdrawalId].section = 1;
        user.withdrawals[withdrawalId].time = block.timestamp;
        user.withdrawals[withdrawalId].amount = availableReferralEarnings;
        user.withdrawalCount++;
        // Stats
        TotalWithdrawn = TotalWithdrawn.add(availableReferralEarnings);

        user.referralEarningsAvailable = 0;
        payable(msg.sender).transfer(availableReferralEarnings);

        emit ReferralEarningsWithdrawEvent(msg.sender, availableReferralEarnings);

    }


    /*
        PUBLIC CALLS
    */

   function getUserDividends(address userAddress) public view returns (uint256)
    {
        User storage user = Users[userAddress];
  
        uint256 dividendsTotal;

        for (uint256 i = 0; i < user.investmentCount; i++) 
        {

            uint256 investmentPlanId = user.investments[i].planId;
            uint256 investmentStartTime = user.investments[i].startTime;
            uint256 investmentAmount = user.investments[i].amount;
            uint256 investmentTimeStep = user.investments[i].timeStep;
            uint256 investmentEarningBase = user.investments[i].earningBase;
            uint256 investmentEarningStep = user.investments[i].earningStep;
          
          	uint256 planEndDate = investmentStartTime.add(InvestmentPlans[investmentPlanId].mul(investmentTimeStep));

            if (user.lastWithdrawTime < planEndDate)
            {
                uint256 percentage = investmentEarningBase.add(investmentEarningStep.mul(investmentPlanId));
                uint256 total = investmentAmount.mul(percentage).div(divider);
                uint256 daily = total.div(InvestmentPlans[investmentPlanId]);
                uint256 from = investmentStartTime > user.lastWithdrawTime ? investmentStartTime : user.lastWithdrawTime;
               	uint256 to = planEndDate < block.timestamp ? planEndDate : block.timestamp;   

	            if (from < to) 
                {
					dividendsTotal = dividendsTotal.add(daily.mul(to.sub(from)).div(investmentTimeStep));
				}
            }

        }

        return dividendsTotal;

    }

    function getUserInvestmentsTotalAmount(address userAddress) public view returns (uint256)
    {
        User storage user = Users[userAddress];
  
        uint256 totalAmount;

        for (uint256 i = 0; i < user.investmentCount; i++) 
        {
            totalAmount = totalAmount.add(user.investments[i].amount);
        }

        return totalAmount;

    }

    function getUserInvestmentsTotalProfit(address userAddress) public view returns (uint256)
    {
        User storage user = Users[userAddress];
  
        uint256 totalProfit;

        for (uint256 i = 0; i < user.investmentCount; i++) 
        {

            uint256 investmentEarningBase = user.investments[i].earningBase;
            uint256 investmentEarningStep = user.investments[i].earningStep;
          
            uint256 percentage = investmentEarningBase.add(investmentEarningStep.mul(user.investments[i].planId));
            totalProfit = totalProfit.add(user.investments[i].amount.mul(percentage).div(divider));

        }

        return totalProfit;

    }

    function getUserInvestment(address userAddress, uint256 investmentId) external view returns (Investment memory)
    {
        return Users[userAddress].investments[investmentId];
    }

    function getUserInvestments(address userAddress, uint256 cursor, uint256 size) external view returns (Investment[] memory, uint256)
    {
        uint256 height;
        uint256[] memory investmentIDS = new uint256[](size);
        
        for (uint256 i = 0; i < size; i++) 
        {
            if (Users[userAddress].investments[cursor + i].startTime > 0)
            {
                investmentIDS[i] = cursor + i;
                height++;
            }
        }

        Investment[] memory invesments = new Investment[](height);

        for (uint256 i = 0; i < height; i++) 
        {
           invesments[i] = Users[userAddress].investments[investmentIDS[i]];
        }

        return (invesments, height);

    }

    function getUserWithdrawal(address userAddress, uint256 withdrawalId) external view returns (Withdrawal memory)
    {
        return Users[userAddress].withdrawals[withdrawalId];
    }


    function getUserWithdrawals(address userAddress, uint256 cursor, uint256 size) external view returns (Withdrawal[] memory, uint256)
    {
        uint256 height;
        uint256[] memory withdrawalsIDS = new uint256[](size);
        
        for (uint256 i = 0; i < size; i++) 
        {
            if (Users[userAddress].withdrawals[cursor + i].time > 0)
            {
                withdrawalsIDS[i] = cursor + i;
                height++;
            }
        }

        Withdrawal[] memory withdrawals = new Withdrawal[](height);

        for (uint256 i = 0; i < height; i++) 
        {
           withdrawals[i] = Users[userAddress].withdrawals[withdrawalsIDS[i]];
        }

        return (withdrawals, height);

    }

    function getUserTotals(address userAddress) external view returns (uint256 TotalInvestedAmount, uint256 TotalWithdrawnAmount, uint256 ReferralEarningsAvailable, uint256 ReferralEarningsTotal)
    {
        return (Users[userAddress].totalInvested, Users[userAddress].totalWithdrawn, Users[userAddress].referralEarningsAvailable, Users[userAddress].referralEarningsTotal);
    }

    function getUserReferrals(address userAddress) external view returns (uint256 Level1, uint256 Level2, uint256 Level3, uint256 Level4, uint256 Level5)
    {
        return (Users[userAddress].referrals[0], Users[userAddress].referrals[1], Users[userAddress].referrals[2], Users[userAddress].referrals[3], Users[userAddress].referrals[4]);
    }

    function getContractTotals() external view returns ( uint256 _TotalUsers, uint256 _TotalDeposited, uint256 _TotalWithdrawn)
    {
        return (TotalUsers, TotalDeposited, TotalWithdrawn);
    }

    function getInvestmentPlanInfo(uint256 amount, uint256 planIndex) external view returns (uint256 EarningPercentage, uint256 DailyEarning, uint256 TotalEarning)
    {
        EarningPercentage = earningBase.add(earningStep.mul(planIndex));
        TotalEarning = amount.mul(EarningPercentage).div(divider);
        DailyEarning = TotalEarning.div(InvestmentPlans[planIndex]);
    }

    function getContractBalance() public view returns (uint256) 
    {
        return (address(this).balance);
    }


}