/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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

contract TTCoinICO {
    using SafeMath for uint256;

    BEP20 public ttc = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);  // TTC 
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);  // BUSD
    
    address payable liquidator;
    uint8 [7] public referral = [25,25,15,15,10,10];
    uint8 public directReferral = 8;
   
    uint256 public price = 1;
    uint256 public tokenSold;
    uint256 public currentSupply = 15000000;
    uint256 public timeStep = 10 minutes; // 1 days
    uint16 public totalReturns = 72;
    uint16 public paydays = 15 minutes; // 30 days
    uint16 public topInvestors;
    
    struct User{
        address refer;
        bool isActive;
        uint256 tokens;
        uint256 stakedTokens;
        uint256 released;
        uint256 directReferral;
        uint256 referral;
        mapping(uint256 => uint256) commission;
        mapping(uint256 => uint256) levelTeam;
        uint256 nextPayout;
    }

    struct Deposit{
        uint256 busd;
        uint256 token;
        uint256 deptime;
    }

    struct Withdraw{
        uint256 token;
        uint256 paidtime;
    }

    mapping (address => User) public users;
    mapping (address => Deposit []) public deposits;
    mapping (address => Withdraw []) public withdraws;
    
    event Register(address user, address refer);
    event Sold(address buyer, uint256 busd, uint256 token);
    event Payout(address buyer, uint256 token);
    event UnLock(address buyer, uint256 token);
   
    modifier onlyLiquidator(){
        require(msg.sender == liquidator,"You are not authorized liquidator.");
        _;
    }

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    function getBalanceSheet() view public returns(uint256 contractTokenBalance, uint256 contractTokenSold,uint256 contractBusdBalance){
        return (
            contractTokenBalance = ttc.balanceOf(address(this)),
            contractTokenSold = tokenSold,
            contractBusdBalance = busd.balanceOf(address(this))
        );
    }

    constructor() public {
        liquidator = msg.sender;
        users[liquidator].isActive = true;
    }

    function register(address _refer, uint256 _busd) public security{
        require(users[msg.sender].isActive==false,"You are already registered.");
        require(users[_refer].isActive==true && _refer!=msg.sender,"Invalid Referer!");
        _register(msg.sender, _refer, _busd);
    }

    function _register(address buyer, address _refer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(price);
        require(currentSupply >= scaledAmount.div(1e18));
        users[msg.sender].isActive = true;
        tokenSold += scaledAmount.div(1e18);
        if(buyer!=liquidator){
            if(users[buyer].refer==address(0x0)){
                setReferral(buyer,_refer);
            }
            distributeReferral(buyer, scaledAmount);
        }
        deposits[buyer].push(Deposit(
            _busd,
            scaledAmount,
            block.timestamp
        ));
        users[msg.sender].stakedTokens+=scaledAmount.div(1e18);
        users[msg.sender].tokens+=scaledAmount.mul(totalReturns);
        emit Register(buyer, _refer);
        emit Sold(buyer, _busd, scaledAmount);
        
    }

    function setReferral(address direct, address refer) internal{
        users[direct].refer = refer;
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].levelTeam[i]++;
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function distributeReferral(address direct, uint256 _ttc) internal{
        for(uint8 i=0; i<referral.length; i++){
            if(i==0){
                users[users[direct].refer].directReferral+=_ttc.mul(directReferral).div(100);
            }
            users[users[direct].refer].commission[i]+=_ttc.mul(referral[i]).div(1000);
            users[users[direct].refer].referral+=_ttc.mul(referral[i]).div(1000);
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function buy(uint256 _busd) public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"Please register first!");
        _buy(msg.sender, _busd);
    }

    function _buy(address buyer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(price);
        require(currentSupply >= scaledAmount.div(1e18));
        tokenSold += scaledAmount.div(1e18);
        if(buyer!=liquidator){
            distributeReferral(buyer, scaledAmount);
        }
        deposits[buyer].push(Deposit(
            _busd,
            scaledAmount,
            block.timestamp
        ));
        users[msg.sender].stakedTokens+=scaledAmount.div(1e18);
        users[msg.sender].tokens+=scaledAmount.mul(totalReturns);
        emit Sold(buyer, _busd, scaledAmount);
        
    }
    
    function userDetails(address user)public view returns(uint256 [7] memory members, uint256 [7] memory commission, uint256 [5] memory dividends, uint256 deposit, uint256 payout){
        for(uint8 i = 0; i < referral.length; i++){
            members[i] = users[user].levelTeam[i];
            commission[i] = users[user].commission[i];
        }
        deposit = deposits[user].length;
        payout = withdraws[user].length;
        return (members, commission, dividends, deposit, payout);
    }

    function calculateROI(address _addr) view public returns(uint256 _myROI){
        for(uint256 i = 0; i < deposits[_addr].length; i++){
            uint256 totalDays = getCurDay(deposits[_addr][i].deptime);
            totalDays = (totalDays>=365)?365:totalDays;
            _myROI+=(deposits[_addr][i].token.mul(2).div(1000)).mul(totalDays);
        }
        return _myROI;
    }

    function withdraw(uint256 amount) public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"You are not activated.");
        require(amount>=100e18 && amount<=300e18,"You can withdraw min 100 upto max 300 tokens.");
        require(block.timestamp>=user.nextPayout,"Your withdrawal is locked for 1 month since last payout.");
        uint256 myROI = calculateROI(msg.sender);
        uint256 total = ((users[msg.sender].directReferral).add(users[msg.sender].referral).add(myROI)).sub(user.released);
        require(amount<=total,"Amount exceeds withdrawable.");
        ttc.transfer(msg.sender,amount);
        user.released+=amount;
        user.nextPayout=block.timestamp + paydays;
        withdraws[msg.sender].push(Withdraw(
            amount,
            block.timestamp
        ));
    }

    function releaseLiquidityFund(address _liquidator, uint _amount) external onlyLiquidator security{
        busd.transfer(_liquidator,_amount);
    }
   
    function releaseTokenAndCloseICO(address _liquidator,uint _amount) external onlyLiquidator security{
        ttc.transfer(_liquidator,_amount);
        tokenSold += _amount.div(1e18);
    }

    function getCurDay(uint256 startTime) public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
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