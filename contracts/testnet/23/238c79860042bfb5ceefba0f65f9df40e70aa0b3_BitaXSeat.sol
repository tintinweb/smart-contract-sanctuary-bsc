/**
 *Submitted for verification at BscScan.com on 2022-12-06
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

contract BitaXSeat {
    using SafeMath for uint256;

    BEP20 public bitax = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);  // BitaX 
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);  // BUSD
    
    address payable liquidator;
    uint8 [5] public referral = [5,3,2,1,1];
    uint8 public dividend = 5;
    uint256 public fixedAmt = 10e18;
    uint256 public price = 5;
    uint256 public tokenSold;
    uint256 public currentSupply = 5000;
    uint256 public timeStep = 10 minutes; // 1 months
    uint16 public maxReturns = 10;
    uint16 public totalReturns = 150;
    uint16 public topInvestors;
    uint16 public tokenLimit = 100;
    struct User{
        address refer;
        bool isActive;
        bool isTopInvestor;
        uint256 tokens;
        uint256 stakedTokens;
        uint256 released;
        mapping(uint256 => uint256) commission;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) dividend;
        uint256 lastUnlocked;

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

    struct Unlock{
        uint256 token;
        uint256 unlocktime;
    }

    mapping (address => User) public users;
    mapping (address => Deposit []) public deposits;
    mapping (address => Withdraw []) public withdraws;
    mapping (address => Unlock []) public unlocks;
  

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
            contractTokenBalance = bitax.balanceOf(address(this)),
            contractTokenSold = tokenSold,
            contractBusdBalance = busd.balanceOf(address(this))
        );
    }

    constructor() public {
        liquidator = msg.sender;
        users[liquidator].isActive = true;
    }

    function register(address _refer) public security{
        require(users[msg.sender].isActive==false,"You are already registered.");
        require(users[_refer].isActive==true && _refer!=msg.sender,"Invalid Referer!");
        _register(msg.sender, _refer);
    }

    function _register(address buyer, address _refer) internal {
        busd.transferFrom(msg.sender,address(this),fixedAmt);
        uint256 scaledAmount = fixedAmt.mul(price).div(10);
        require(currentSupply >= scaledAmount.div(1e18));
        users[msg.sender].isActive = true;
        tokenSold += scaledAmount.div(1e18);
        if(buyer!=liquidator){
            if(users[buyer].refer==address(0x0)){
                setReferral(buyer,_refer);
            }
            distributeReferral(buyer, scaledAmount, true);
        }
        deposits[buyer].push(Deposit(
            fixedAmt,
            scaledAmount,
            block.timestamp
        ));

        if(topInvestors<=50){
            if(users[msg.sender].isTopInvestor == false){
                users[msg.sender].isTopInvestor = true;
            }
            topInvestors++;
        }
        emit Register(buyer, _refer);
        emit Sold(buyer, fixedAmt, scaledAmount);
        
    }

    function setReferral(address direct, address refer) internal{
        users[direct].refer = refer;
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].levelTeam[i]++;
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function distributeReferral(address direct, uint256 _bitax, bool isReg) internal{
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].commission[i]+=_bitax.mul(referral[i]).div(100);
            if(isReg==true){
                if(i == 0 && users[users[direct].refer].levelTeam[0] >= 5){ // Minimum 10 directs
                    users[users[direct].refer].dividend[0]+=_bitax.mul(users[users[direct].refer].levelTeam[0]).mul(dividend).div(100);
                }
                else if(i == 1 && users[users[direct].refer].levelTeam[1] >= 8){ // Minimum 50 members at level 2
                    users[users[direct].refer].dividend[1]+=_bitax.mul(users[users[direct].refer].levelTeam[1]).mul(dividend).div(100);
                }
                else if(i == 2 && users[users[direct].refer].levelTeam[2] >= 15){ // Minimum 200 members at level 3
                    users[users[direct].refer].dividend[2]+=_bitax.mul(users[users[direct].refer].levelTeam[2]).mul(dividend).div(100);
                }
                else if(i == 3 && users[users[direct].refer].levelTeam[3] >= 20){ // Minimum 500 members at level 4
                    users[users[direct].refer].dividend[3]+=_bitax.mul(users[users[direct].refer].levelTeam[3]).mul(dividend).div(100);
                }
                else if(i == 4 && users[users[direct].refer].levelTeam[4] >= 25){ // Minimum 1000 members at level 5
                    users[users[direct].refer].dividend[4]+=_bitax.mul(users[users[direct].refer].levelTeam[4]).mul(dividend).div(100);
                }
            }
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function buy() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"Please register first!");
        require(user.levelTeam[0]>=5,"Minimum 10 directs needed.");
        require(user.isTopInvestor==true,"Sorry! you can't buy.");
        _buy(msg.sender, 200e18);
    }

    function _buy(address buyer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(price).div(10);
        require(currentSupply >= scaledAmount.div(1e18));
        tokenSold += scaledAmount.div(1e18);
        if(buyer!=liquidator){
            distributeReferral(buyer, scaledAmount, false);
        }
        deposits[buyer].push(Deposit(
            _busd,
            scaledAmount,
            block.timestamp
        ));
        users[msg.sender].stakedTokens+=scaledAmount.div(1e18);
        users[msg.sender].tokens+=scaledAmount.mul(totalReturns).div(100);
        emit Sold(buyer, _busd, scaledAmount);
        
    }
    

    function userDetails(address user)public view returns(uint256 [5] memory members, uint256 [5] memory commission, uint256 [5] memory dividends, uint256 deposit, uint256 payout, uint256 unlock){
        for(uint8 i = 0; i < referral.length; i++){
            members[i] = users[user].levelTeam[i];
            commission[i] = users[user].commission[i];
            dividends[i] = users[user].dividend[i];
        }
        deposit = deposits[user].length;
        payout = withdraws[user].length;
        unlock = withdraws[user].length;
        return (members, commission, dividends, deposit, payout, unlock);
    }

    function earnings(address buyer) public view returns(uint256 income){
        User storage user = users[buyer];
        for(uint8 i = 0; i < referral.length; i++){
            income+=user.dividend[i].add(user.commission[i]);
        }
        return income;
    }

    function getReturnsInfo(address buyer) public view returns(uint256 roi, bool status){
        bool isLocked = false;
        uint256 amount = users[buyer].tokens.sub(users[buyer].released);
        if(users[buyer].lastUnlocked+timeStep>block.timestamp){
            isLocked = true;
        }
        return (amount.mul(maxReturns).div(100), isLocked);
    }

    function unlock() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"You are not activated.");
        require(user.lastUnlocked+timeStep<=block.timestamp,"Unlocking is not prepared.");
        uint256 amount = user.tokens.sub(user.released);
        uint256 payout = amount.mul(maxReturns).div(100);
        bitax.transfer(msg.sender,payout);
        user.released+=payout;
        user.lastUnlocked = block.timestamp;
        unlocks[msg.sender].push(Unlock(
            payout,
            block.timestamp
        ));
    }

    function withdraw() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"You are not activated.");
        uint256 total = earnings(msg.sender);
        bitax.transfer(msg.sender,total);
        for(uint8 i = 0; i < referral.length; i++){
            user.dividend[i] = 0;
            user.commission[i] = 0;
        }
        withdraws[msg.sender].push(Withdraw(
            total,
            block.timestamp
        ));
    }

    function releaseLiquidityFund(address _liquidator, uint _amount) external onlyLiquidator{
        busd.transfer(_liquidator,_amount);
    }
   
    function releaseTokenAndCloseICO(address _liquidator,uint _amount) external onlyLiquidator{
        bitax.transfer(_liquidator,_amount);
        tokenSold += _amount.div(1e18);
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