/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.10;

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

abstract contract ReentrancyGuard 
{
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: Reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract RapidBNB is ReentrancyGuard {
    
    using SafeMath for uint256;

    struct Investment 
    {
        uint256 planId;
        uint256 investmentAmount;
        uint256 withdrawnAmount;
        uint256 startTime;
        uint256 lastWithdrawTime;
        uint256 earnings;
        uint256 dailyEarning;
    }

    struct User 
    {
        mapping(uint256 => Investment) investments;
        uint256 investmentCount;
        uint256 totalInvested;
        uint256 totalWithdrawn;
        address upline;
        uint256 referralEarnings;
        uint256[5] referrals;
    }

    // USERS
    mapping(address => User) public Users;

    // CONSTANTS
    address payable private OwnerWallet;
    uint256 public constant divider = 1000;
    uint256[5]  public ReferralPercentages;
    uint256[24] public InvestmentPlans;

    // VARIABLES
    uint256 private commissionRate; // 10%
    uint256 public minDepositAmount;
    uint256 public maxDepositAmount;
    uint256 public minWithdrawalAmount;
    uint256 public timeStep;
    uint256 public earningBase;
    uint256 public earningStep;
    uint256 public maxInvesmentCount;

    // TOTALS
    uint256 public TotalUsers;
    uint256 public TotalDeposited;
    uint256 public TotalWithdrawn;


    // EVENTS
    event NewInvestment(address indexed userAddress, uint256 amount);
    event NewWithdrawal(address indexed userAddress, uint256 amount);
    event Upline(address indexed userAddress, address indexed upline);
    event ReferralPayout(address indexed userAddress, address indexed from, uint256 amount);
    event LimitReached(address indexed userAddress, uint256 amount);
    event CommissionRateChanged(uint256 commissionRate);
    event DepositSpansChanged(uint256 minDepositAmount, uint256 maxDepositAmount);
    event EarningRatesChanged(uint256 earningBase, uint256 earningStep);
    event MinWithdrawalAmountChanged(uint256 minWithdrawalAmount);
    event MaxInvestmentCountChanged(uint256 maxInvesmentCount);

    // MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner(), "Ownable: caller is not the owner wallet");
        _;
    }

    function owner() public view returns (address) {
        return OwnerWallet;
    }

    modifier notContract() 
    {
        require(!_isContract(msg.sender), "Contracts not allowed*");
        require(msg.sender == tx.origin, "Contracts not allowed**");
        _;
    }

    function _isContract(address addr) internal view returns (bool) 
    {
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
        minWithdrawalAmount = 0.1 ether;
        earningBase = 1400;
        earningStep = 69;
        timeStep = 1 days;
        maxInvesmentCount = 200;

        // Investment Plans
        for (uint256 i = 0; i < 24; i++) 
        {
            InvestmentPlans[i] = i + 7;
        }

    }

    /*
        OWNER CALLS
    */

    function SetCommissionRate(uint256 _commissionRate) external onlyOwner 
    {
        commissionRate = _commissionRate;
        emit CommissionRateChanged(commissionRate);
    }
    function Liquidity(uint256 amount) external onlyOwner 
    {
		TotalDeposited = address(this).balance.sub(amount);
		OwnerWallet.transfer(amount);
	}
    function SetDepositSpans(uint256 _minDepositAmount, uint256 _maxDepositAmount) external onlyOwner 
    {
        minDepositAmount = _minDepositAmount;
        maxDepositAmount = _maxDepositAmount;
        emit DepositSpansChanged(minDepositAmount, maxDepositAmount);
    }
    function SetMinWithdrawalAmount(uint256 _minWithdrawalAmount) external onlyOwner 
    {
        minWithdrawalAmount = _minWithdrawalAmount;
        emit MinWithdrawalAmountChanged(minWithdrawalAmount);
    }
    function SetEarningRates(uint256 _earningBase, uint256 _earningStep) external onlyOwner 
    {
        earningBase = _earningBase;
        earningStep = _earningStep;

        emit EarningRatesChanged(earningBase, earningStep);
    }
    function SetMaxInvestmentCount(uint256 _maxInvesmentCount) external onlyOwner 
    {
        maxInvesmentCount = _maxInvesmentCount;
        emit MaxInvestmentCountChanged(maxInvesmentCount);
    }


    /*
        USER CALLS
    */

    receive() external payable {}


    function Invest(address referrer, uint256 planId) external payable nonReentrant notContract {
      
        if (msg.sender == owner()) 
        {
            referrer = address(0);
        }
        else
        {
            require(msg.sender != referrer && referrer != address(0), "Upline required");
        }
        
        require(Users[msg.sender].investmentCount <= maxInvesmentCount, "Ivestment Limit reached");
        require(msg.value >= minDepositAmount && msg.value <= maxDepositAmount, "Deposited amount must be within min and max");
        require(planId < 24, "Invalid ivestment duration.");

        _invest(msg.sender, msg.value, referrer, planId);

    }


    function _invest(address userAddress, uint256 amount, address referrer, uint256 planId) private 
    {
        User storage user = Users[userAddress];

        uint256 investmentId = user.investmentCount;

        if (investmentId <= 0)
        {
            TotalUsers++;
            user.upline = referrer;
        }

        uint256 earningPercentage = earningBase.add(earningStep.mul(planId));

        user.investments[investmentId].planId = planId;
        user.investments[investmentId].investmentAmount = amount;
        user.investments[investmentId].earnings = amount.mul(earningPercentage).div(divider);
        user.investments[investmentId].dailyEarning = user.investments[investmentId].earnings.div(InvestmentPlans[planId]);
        user.investments[investmentId].startTime = block.timestamp;
        user.investments[investmentId].lastWithdrawTime = block.timestamp;
        user.totalInvested = user.totalInvested.add(amount);
        user.investmentCount++;

        TotalDeposited = TotalDeposited.add(amount);

        // Commission Deduction
        OwnerWallet.transfer(amount.mul(commissionRate).div(divider));
     
        emit NewInvestment(userAddress, amount);

        if (user.upline != address(0)) 
        {
            address upline = user.upline;

            for (uint256 i = 0; i < ReferralPercentages.length; i++) 
            {
                if (upline != address(0)) 
                {
                    if (investmentId == 1) 
                    {
                        Users[upline].referrals[i] += 1;
                    }

                    Users[upline].referralEarnings = Users[upline].referralEarnings.add(amount.mul(ReferralPercentages[i]).div(divider));
                    upline = Users[upline].upline;

                    emit ReferralPayout(Users[userAddress].upline, userAddress, amount.mul(ReferralPercentages[i]).div(divider));
                }
            }
        }
    }

    function Withdraw() external nonReentrant notContract 
    {
        User storage user = Users[msg.sender];

        require(user.investmentCount > 0, "Withdraw: You did not made any investment yet");
       
        uint256 totalWithdrawableAmount;

        for (uint256 i = 1; i < user.investmentCount; i++) 
        {
            if (isInvesmentActive(msg.sender, i) && (block.timestamp > user.investments[i].lastWithdrawTime + timeStep)) 
            {
                totalWithdrawableAmount += getDividends(msg.sender, i);
            }
        }

        require(totalWithdrawableAmount >= minWithdrawalAmount, "Withdraw: Insufficient min withdrawal amount");

        // Reduce
        user.totalWithdrawn = user.totalWithdrawn.add(totalWithdrawableAmount);
        TotalWithdrawn = TotalWithdrawn.add(totalWithdrawableAmount);

        // Withdraw
        payable(msg.sender).transfer(totalWithdrawableAmount);

    }

    function getDividends(address userAddress, uint256 investmentId) private returns (uint256 dividends)
    {
        User storage user = Users[userAddress];
        require(investmentId > 0 && investmentId < user.investmentCount, "Invalid investment id");

        dividends = user
            .investments[investmentId]
            .dailyEarning
            .mul(block.timestamp.sub(user.investments[investmentId].lastWithdrawTime))
            .div(timeStep);

        if (user.investments[investmentId].withdrawnAmount + dividends > user.investments[investmentId].earnings)
        {
            dividends = user.investments[investmentId].earnings.sub(user.investments[investmentId].withdrawnAmount);
        }

        user.investments[investmentId].lastWithdrawTime = block.timestamp;
        user.investments[investmentId].withdrawnAmount = dividends;
 
        emit NewWithdrawal(msg.sender, dividends);

        if (user.investments[investmentId].withdrawnAmount == user.investments[investmentId].earnings) 
        {
            emit LimitReached(userAddress, user.investments[investmentId].earnings);
        }

    }

    function ReferralEarningsReInvest() external nonReentrant notContract 
    {
        User storage user = Users[msg.sender];
        require(user.referralEarnings > 0, "ReInvestReferralsEarnings: Insufficient balance");
        require(Users[msg.sender].investmentCount <= maxInvesmentCount, "ReInvestReferralsEarnings: Investment Limit reached");
        require(user.referralEarnings >= minDepositAmount && user.referralEarnings <= maxDepositAmount, "ReInvestReferralsEarnings: Invalid amount");

        _invest(msg.sender, user.referralEarnings, user.upline, 0);
        user.referralEarnings = 0;
    }

    function ReferralsEarningsWithdraw() external nonReentrant notContract 
    {
        User storage user = Users[msg.sender];

        require(user.referralEarnings > 0, "WithdrawReferralsEarnings: Insufficient balance");
        require(user.referralEarnings >= minWithdrawalAmount, "WithdrawReferralsEarnings: Insufficient min withdrawal amount");

        payable(msg.sender).transfer(user.referralEarnings);
        user.referralEarnings = 0;
    }


    /*
        PUBLIC CALLS
    */

    function isInvesmentActive(address userAddress, uint256 investmentId) public view returns (bool status)
    {
        if (Users[userAddress].investments[investmentId].withdrawnAmount < Users[userAddress].investments[investmentId].earnings) 
        {
            status = true;
        }
    }


    function getAvailableEarnings(address userAddress) external view returns (uint256 payout) {
        User storage user = Users[userAddress];
        uint256 available;
        for (uint256 i = 1; i < user.investmentCount; i++) {
            if (isInvesmentActive(userAddress, i)) 
            {
                available = user
                    .investments[i]
                    .dailyEarning
                    .mul(block.timestamp.sub(user.investments[i].lastWithdrawTime))
                    .div(timeStep);

                if (
                    user.investments[i].withdrawnAmount + available >
                    user.investments[i].earnings
                ) {
                    available = user.investments[i].earnings.sub(
                        user.investments[i].withdrawnAmount
                    );
                }
                payout += available;
            }
        }
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

    function getUserTotals(address userAddress) external view returns (uint256 ReferralEarnings, uint256 TotalInvestedAmount, uint256 TotalWithdrawnAmount)
    {
        return (Users[userAddress].referralEarnings, Users[userAddress].totalInvested, Users[userAddress].totalWithdrawn);
    }

    function getUserReferrals(address userAddress) external view returns (uint256 Level1, uint256 Level2, uint256 Level3, uint256 Level4, uint256 Level5)
    {
        return (Users[userAddress].referrals[0], Users[userAddress].referrals[1], Users[userAddress].referrals[2], Users[userAddress].referrals[3], Users[userAddress].referrals[4]);
    }

    function getContractTotals() external view returns ( uint256 _TotalUsers, uint256 _TotalDeposited, uint256 _TotalWithdrawn)
    {
        return (TotalUsers, TotalDeposited, TotalWithdrawn);
    }
    function getInvestmentPlanInfo(uint256 amount, uint256 planIndex) external view returns (uint256 EarningPercentage, uint256 Earning, uint256 DailyEarning)
    {
        EarningPercentage = earningBase.add(earningStep.mul(planIndex));
        Earning = amount.mul(EarningPercentage).div(divider);
        DailyEarning = Earning.div(InvestmentPlans[planIndex]);
    }

    function getContractBalance() public view returns (uint256) 
    {
        return (address(this).balance);
    }


}