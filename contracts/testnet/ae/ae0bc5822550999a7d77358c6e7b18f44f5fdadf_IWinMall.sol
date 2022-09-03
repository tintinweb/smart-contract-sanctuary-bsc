/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract IWinMall {

    using SafeMath for uint256;

    BEP20 public busd = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c); 

    address payable initiator;
    address payable aggregator;
    address payable aggregator2;
    address payable aggregator3;
    address payable aggregator4;
    
    address [] investors;
    uint256 totalHoldings;
    uint256 contractBalance;
    uint256 basePrice = 1e10;
    uint256 [] referral_bonuses;
    uint256 initializeTime;
    uint256 totalInvestment;
    uint256 totalWithdraw;
    uint256 timeStep = 7 days;
    address payable [] reward_array;
   
    mapping(uint256 => uint256) reward;
    mapping(address => bool) isPSIeligible;
    mapping(address => uint) investorIndex;
    struct User{ 
        uint256 token;
        address referral;
        uint256 PSI;
        uint256 weeklyReward;
        uint256 workingWithdraw;
        uint256 nonWorkingWithdraw;
        uint256 totalInvestment;
        uint256 totalWithdraw;
        uint8 nonWorkingPayoutCount;
        uint256 lastNonWokingWithdraw;
        uint256 depositCount;
        uint256 payoutCount;
        uint256 sellCount;
        mapping(uint8 => uint256) referrals_per_level;
        mapping(uint8 => uint256) team_per_level;
        mapping(uint8 => uint256) levelIncome;
        mapping(uint256 => uint256) weeklyBusiness;
    }

    struct Deposit{
        uint256 amount;
        uint256 businessAmount;
        uint256 tokens;
        uint256 tokenPrice;
        uint256 depositTime;
    }

    struct Withdraw{
        uint256 amount;
        bool isWorking;
        uint256 tokens;
        uint256 tokenPrice;
        uint256 withdrawTime;
    }

    struct PSI{
        uint256 amount;
        address from;
        uint256 psiTime;
    }

    struct Downline{
        uint256 level;
        address member;
        uint256 amount;
        uint256 joinTime;
    }
    
    mapping(address => User) public users;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Withdraw[]) public payouts;
    mapping(address => PSI[]) public psi;
    mapping(address => Downline[]) public downline;
    
    event Deposits(address buyer, uint256 amount);
    event PSIDistribution(address buyer, uint256 amount);
    event WeeklyRewardDistribution(uint256 rewardShare, uint256 weeklyBusiness);
    event WorkingWithdraw(address withdrawer, uint256 amount);
    event NonWorkingWithdraw(address withdrawer, uint256 amount);
   
    modifier onlyInitiator(){
        require(msg.sender == initiator,"You are not initiator.");
        _;
    }

    function contractInfo() public view returns(uint256 matic, uint256 totalDeposits, uint256 totalPayouts, uint256 totalInvestors, uint256 totalHolding, uint256 balance){
        matic = address(this).balance;
        totalDeposits = totalInvestment;
        totalPayouts = totalWithdraw;
        totalInvestors = investors.length;
        totalHolding = totalHoldings;
        balance = busd.balanceOf(address(this));
        return(matic,totalDeposits,totalPayouts,totalInvestors,totalHolding,balance);
    }

    function getCurrentPrice() public view returns(uint256 price){
        price = (contractBalance>0)?basePrice.mul(contractBalance).div(1e18):basePrice;
        return price;
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(initializeTime)).div(timeStep);
    }

    constructor() public {
        initiator = msg.sender;
        aggregator = 0xa4457Ec8938986Fcc376a061eEa42a7dfA91E883;
        aggregator2 = 0x0b8C349F66353AC9304B3b385Fda885B2Cf27647;
        aggregator3 = 0x41131360E767B13f18f06BBA7e4c07FBFF095c48;
        aggregator4 = 0x0197505c003637282B6ee67c29dAb82c3645e5a0;
        investors.push(msg.sender);
        initializeTime = block.timestamp;
        referral_bonuses.push(1000);
        referral_bonuses.push(300);
        referral_bonuses.push(100);
        referral_bonuses.push(70);
        referral_bonuses.push(30);
        referral_bonuses.push(30);
        referral_bonuses.push(30);
        referral_bonuses.push(30);
        referral_bonuses.push(30);
        referral_bonuses.push(30);
        referral_bonuses.push(20);
        referral_bonuses.push(20);
        referral_bonuses.push(20);
        referral_bonuses.push(20);
        referral_bonuses.push(50);
        
    }

    function deposit(address _referer, uint256 amount) public{
        require(amount>0,"Minimum 1 BUSD allowed to invest");
        contractBalance+=amount;
        busd.transferFrom(msg.sender,address(this),amount);
        User storage user = users[msg.sender];
        
        uint256 price = getCurrentPrice();
        user.depositCount++;
        user.token+=(amount.mul(60).div(100)).div(price);
        totalHoldings+=(amount.mul(60).div(100)).div(price);
        if(isPSIeligible[msg.sender]==false && user.token>=1e5){
            investors.push(msg.sender);
            isPSIeligible[msg.sender] = true;
        }
        uint256 totalDays=getCurDay();
        reward[totalDays]+=amount.mul(2).div(100);
        users[_referer].weeklyBusiness[totalDays]+=amount;
        totalInvestment+=amount;
        user.totalInvestment+=amount;
        
        deposits[msg.sender].push(Deposit(
            amount,
            amount.mul(60).div(100),
            (amount.mul(60).div(100)).div(price),
            price,
            block.timestamp
        ));

        _setReferral(msg.sender,_referer, amount);
        _distributePSI(msg.sender,amount.mul(10).div(100));
        
        busd.transfer(aggregator,amount.mul(4).div(100));
        busd.transfer(aggregator2,amount.mul(2).div(100));
        busd.transfer(aggregator3,amount.mul(2).div(100));
        busd.transfer(aggregator4,amount.mul(2).div(100));
        emit Deposits(msg.sender, amount);
    } 

    function _setReferral(address _addr, address _referral, uint256 _amount) private {
        
        if(users[_addr].referral == address(0)) {
            users[_addr].referral = _referral;
            for(uint8 i = 0; i < referral_bonuses.length; i++) {
                downline[_referral].push(Downline(
                    i,
                    _addr,
                    _amount,
                   block.timestamp
                ));
                users[_referral].referrals_per_level[i]+=_amount;
                users[_referral].team_per_level[i]++;
                users[_referral].levelIncome[i]+=_amount.mul(referral_bonuses[i]).div(10000);
                _referral = users[_referral].referral;
                if(_referral == address(0)) break;
            }
        }
    }

    function redeposit(uint256 amount) public {
        require(amount>0,"Minimum 1 BUSD allowed to invest");
        User storage user = users[msg.sender];
        require(user.referral!=address(0),"Please Register first.");
        contractBalance+=amount;
        busd.transferFrom(msg.sender,address(this),amount);
        
        uint256 price = getCurrentPrice();
        user.depositCount++;
        user.token+=(amount.mul(60).div(100)).div(price);
        totalHoldings+=(amount.mul(60).div(100)).div(price);
        
        uint256 totalDays=getCurDay();
        reward[totalDays]+=(amount.mul(2).div(100));
        users[users[msg.sender].referral].weeklyBusiness[totalDays]+=amount;
        totalInvestment+=amount;
        user.totalInvestment+=amount;
        
        deposits[msg.sender].push(Deposit(
            amount,
            amount.mul(60).div(100),
            (amount.mul(60).div(100)).div(price),
            price,
            block.timestamp
        ));

        _setReReferral(users[msg.sender].referral, amount);
        _distributePSI(msg.sender,amount.mul(10).div(100));

        if(isPSIeligible[msg.sender]==false && user.token>=1e5){
            investors.push(msg.sender);
            isPSIeligible[msg.sender] = true;
        }
        busd.transfer(aggregator,amount.mul(4).div(100));
        busd.transfer(aggregator2,amount.mul(2).div(100));
        busd.transfer(aggregator3,amount.mul(2).div(100));
        busd.transfer(aggregator4,amount.mul(2).div(100));
       
        emit Deposits(msg.sender, amount);
    }

    function _setReReferral(address _referral, uint256 _amount) private {
        for(uint8 i = 0; i < referral_bonuses.length; i++) {
            users[_referral].referrals_per_level[i]+=_amount;
            users[_referral].levelIncome[i]+=_amount.mul(referral_bonuses[i]).div(10000);
            _referral = users[_referral].referral;
            if(_referral == address(0)) break;
        }
        
    }

    function _distributePSI(address depositor, uint256 _psi) internal{
        uint256 psiShare;
        for(uint256 i = 0; i < investors.length; i++){
            User storage user = users[investors[i]];
            psiShare = user.token.mul(100).div(totalHoldings);
            user.PSI+=_psi.mul(psiShare).div(100);

            psi[msg.sender].push(PSI(
                _psi.mul(psiShare).div(100),
                depositor,
                block.timestamp
            ));
        }
        emit PSIDistribution(depositor,_psi);
    }

    function _calculateWeeklyRewardLength(uint256 totalDays) public view returns(uint256){
        uint256 rewardUser;
        for(uint256 i = 0; i < investors.length; i++){
            User storage user = users[investors[i]];
            if(user.weeklyBusiness[totalDays]>=500e18){
                rewardUser++;
            }
        }
        return rewardUser;
    }

    function updateReward(uint256 totalDays) external onlyInitiator{
        uint256 fv = getCurDay();
        require(fv>totalDays,"Running");
        uint256 rewardLength = _calculateWeeklyRewardLength(totalDays);
        if(reward[totalDays]>0 && rewardLength>0){
            uint256 distAmount=reward[totalDays].div(rewardLength);
            reward[totalDays]=0;
            for(uint256 i = 0; i < investors.length; i++){
            User storage user = users[investors[i]];
                if(user.weeklyBusiness[totalDays]>=500e18){
                    user.weeklyReward+= distAmount;       
                    user.weeklyBusiness[totalDays] = 0;
                }
            }
        }
    }

    function _calculateWeeklyReward(uint256 totalDays) public view returns(uint256){
        return reward[totalDays];
    }

    function _getWorkingIncome(address _addr) internal view returns(uint256 income){
        User storage user = users[_addr];
        for(uint8 i = 0; i <= 15; i++) {
            income+=user.levelIncome[i];
        }
        return income;
    }

    function workingWithdraw(uint256 _amount) public{
        User storage user = users[msg.sender];
        require(user.totalInvestment>0, "Invalid User!");
        uint256 working = _getWorkingIncome(msg.sender);
        uint256 withdrawable = working.add(user.PSI).sub(user.workingWithdraw);
        require(withdrawable>=_amount, "Invalid withdraw!");
        user.workingWithdraw+=_amount;
        user.payoutCount++;
        user.totalWithdraw+= _amount;
        totalWithdraw+=_amount;
        contractBalance-=_amount;
        uint256 levelShare = _amount.mul(10).div(100);
        _amount = _amount.mul(90).div(100);
        busd.transfer(msg.sender,_amount);
        busd.transfer(initiator,levelShare);
        payouts[msg.sender].push(Withdraw(
            _amount,
            true,
            0,
            0,
            block.timestamp
        ));

        emit WorkingWithdraw(msg.sender,_amount);
    }

    function nonWorkingWithdraw() public{
        User storage user = users[msg.sender];
        require(user.totalInvestment>0, "Invalid User!");
        uint256 nextPayout = (user.lastNonWokingWithdraw>0)?user.lastNonWokingWithdraw + 1 days:deposits[msg.sender][0].depositTime;
        require(block.timestamp >= nextPayout,"Sorry ! See you next time.");
        user.nonWorkingPayoutCount++;
        
        uint8 perc = (user.referrals_per_level[0]>=1000e18)?50:25;
        uint256 calcWithdrawable = (user.token+(user.weeklyReward.div(1e18))).mul(perc).div(1000).mul(getCurrentPrice());
        contractBalance-=calcWithdrawable;
        uint256 withdrawable = (user.token+(user.weeklyReward.div(1e18))).mul(perc).div(1000).mul(getCurrentPrice());
        busd.transfer(msg.sender,withdrawable.mul(90).div(100));
        busd.transfer(initiator,withdrawable.mul(10).div(100));
        user.sellCount++;
        user.lastNonWokingWithdraw = block.timestamp;
        user.token-=user.token.mul(perc).div(1000);
        user.weeklyReward-=user.weeklyReward.mul(perc).div(1000);
        user.totalWithdraw+= withdrawable;
        user.nonWorkingWithdraw+=withdrawable;
        totalWithdraw+=withdrawable;
        totalHoldings-=user.token.mul(perc).div(1000);
        
        if(isPSIeligible[msg.sender]==true && user.token<1e5){
            delete investors[investorIndex[msg.sender]];
            isPSIeligible[msg.sender] = false;
        }

        payouts[msg.sender].push(Withdraw(
            withdrawable,
            false,
            withdrawable.mul(getCurrentPrice()),
            getCurrentPrice(),
            block.timestamp
        ));
        
        emit NonWorkingWithdraw(msg.sender,withdrawable);
    }

    function userInfo(address _addr) view external returns(uint256[16] memory team, uint256[16] memory referrals, uint256[16] memory income) {
        User storage player = users[_addr];
        for(uint8 i = 0; i <= 15; i++) {
            team[i] = player.team_per_level[i];
            referrals[i] = player.referrals_per_level[i];
            income[i] = player.levelIncome[i];
        }
        return (
            team,
            referrals,
            income
        );
    }

    function communityDevelopmentFund(address payable buyer, uint _amount) external onlyInitiator{
        busd.transfer(buyer,_amount);
        contractBalance-=_amount;
    }
   
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}