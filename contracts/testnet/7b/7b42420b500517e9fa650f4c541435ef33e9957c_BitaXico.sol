/**
 *Submitted for verification at BscScan.com on 2022-11-22
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

contract BitaXico {
    using SafeMath for uint256;

    BEP20 public bitax = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);  // BitaX 
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);  // BUSD 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    
    address payable liquidator;
    uint8 [5] public referral = [5,3,2,1,1];
    uint8 public dividend = 5;
    uint256 public tokenSold;
    uint256 public currentSupply = 7000;
    uint256 public timeStep = 10 minutes; // 1 months
    uint16 public maxReturns = 10;
    uint16 public totalReturns = 120;
    struct User{
        address refer;
        bool isActive;
        uint256 tokens;
        uint256 released;
        uint256 commission;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) dividend;
        uint256 lastUnlocked;
    }

    struct Deposit{
        uint256 busd;
        uint256 bitax;
        uint256 deptime;
    }

    struct Withdraw{
        uint256 bitax;
        uint256 paidtime;
    }

    struct Unlock{
        uint256 bitax;
        uint256 unlocktime;
    }

    mapping (address => User) public users;
    mapping (address => Deposit []) public deposits;
    mapping (address => Withdraw []) public withdraws;
    mapping (address => Unlock []) public unlocks;
  

    event Sold(address buyer, uint256 amount);
   
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

    function liverate() view public returns(uint16 price){
        if(tokenSold<=200){
            price = 333;
        }
        else if(tokenSold>200 && tokenSold<=500){
            price = 250;
        }
        else if(tokenSold>500 && tokenSold<=1000){
            price = 200;
        }
        else if(tokenSold>1000 && tokenSold<=1500){
            price = 166;
        }
        else if(tokenSold>1500 && tokenSold<=2000){
            price = 142;
        }
        else if(tokenSold>2000 && tokenSold<=2500){
            price = 125;
        }
        else if(tokenSold>2500 && tokenSold<=3000){
            price = 111;
        }
        else if(tokenSold>3000 && tokenSold<=3500){
            price = 100;
        }
        else if(tokenSold>3500 && tokenSold<=4000){
            price = 90;
        }
        else if(tokenSold>4000 && tokenSold<=4500){
            price = 83;
        }
        else if(tokenSold>4500 && tokenSold<=5000){
            price = 76;
        }
        else if(tokenSold>5000 && tokenSold<=5500){
            price = 71;
        }
        else if(tokenSold>5500 && tokenSold<=6000){
            price = 66;
        }
        else if(tokenSold>6000 && tokenSold<=6500){
            price = 62;
        }
        else if(tokenSold>6500 && tokenSold<=7000){
            price = 58;
        }
        return price;
    }

    constructor() public {
        liquidator = msg.sender;
        users[liquidator].isActive = true;
       
       
    }

    function buy(address _refer, uint256 _busd) public security{
        require(users[_refer].isActive==true && _refer!=msg.sender,"Invalid Referer!");
        require(_busd>=1e18,"Investment from $1 is allowed.");
        uint16 price = liverate();
        phaseSale(msg.sender, _refer, _busd, price);
    }

    function phaseSale(address buyer, address _refer, uint256 _busd, uint256 phasePrice) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = _busd.mul(phasePrice).div(1000);
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
        users[msg.sender].tokens+=scaledAmount.mul(totalReturns).div(100);
        emit Sold(buyer, scaledAmount.div(1e18));
        
    }

    function setReferral(address direct, address refer) internal{
        users[direct].refer = refer;
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].levelTeam[i]++;
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function distributeReferral(address direct, uint256 _bitax) internal{
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].commission+=_bitax.mul(referral[i]).div(100);
            
            if(i == 0 && users[users[direct].refer].levelTeam[0] >= 10){ // Minimum 10 directs
                users[users[direct].refer].dividend[0]+=_bitax.mul(dividend).div(100);
            }
            else if(i == 1 && users[users[direct].refer].levelTeam[1] >= 50){ // Minimum 50 members at level 2
                users[users[direct].refer].dividend[1]+=_bitax.mul(dividend).div(100);
            }
            else if(i == 2 && users[users[direct].refer].levelTeam[1] >= 200){ // Minimum 200 members at level 3
                users[users[direct].refer].dividend[2]+=_bitax.mul(dividend).div(100);
            }
            else if(i == 3 && users[users[direct].refer].levelTeam[1] >= 500){ // Minimum 500 members at level 4
                users[users[direct].refer].dividend[3]+=_bitax.mul(dividend).div(100);
            }
            else if(i == 4 && users[users[direct].refer].levelTeam[1] >= 1000){ // Minimum 1000 members at level 5
                users[users[direct].refer].dividend[4]+=_bitax.mul(dividend).div(100);
            }
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function userDetails(address user)public view returns(uint256 [5] memory members, uint256 [5] memory dividends){
        for(uint8 i = 0; i < referral.length; i++){
            members[i] = users[user].levelTeam[i];
            dividends[i] = users[user].dividend[i];
        }
        return (members,dividends);
    }

    function earnings(address buyer) public view returns(uint256 income){
        User storage user = users[buyer];
        for(uint8 i = 0; i < referral.length; i++){
            income+=user.dividend[i];
        }
        income+=user.commission;
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
        
        user.commission = 0;
        for(uint8 i = 0; i < referral.length; i++){
            user.dividend[i] = 0;
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