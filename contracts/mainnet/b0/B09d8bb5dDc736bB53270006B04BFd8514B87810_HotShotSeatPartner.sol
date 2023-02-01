/**
 *Submitted for verification at BscScan.com on 2023-02-01
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

contract HotShotSeatPartner {
    using SafeMath for uint256;

    BEP20 public hst = BEP20(0x78c06056AA7e087690F30A158914ef6F1b6862E1);  // hotshot 
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  // BUSD
    
    address liquidator;
    address feereceiver = 0x1C62daf74Fd19Ac7eD8b013bD95c02933dA0B7C8;
    address feereceiver2 = 0x7c05Df3d053172A85B15C0b25d790079b32771C9;
    address feereceiver3 = 0x556f6a8f00EAAaF55390c03A36deE15b37472969;
    uint256 public tokenSold;
    uint256 public currentSupply = 50000;
    uint256 public timeStep = 30 days; 
    uint16 public maxReturns = 5;
    uint16 public totalReturns = 100;
    

    struct User{
        address refer;
        bool isActive;
        bool prequal;
        uint256 tokens;
        uint256 stakedTokens;
        uint256 released;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) business;
        uint256 lastUnlocked;
    }

    struct Deposit{
        uint256 busd;
        uint256 token;
        uint256 nof;
        uint256 deptime;
    }

    struct Unstake{
        uint256 token;
        uint256 paidtime;
    }

    mapping (address => User) public users;
    mapping (address => Deposit []) public deposits;
    mapping (address => Unstake []) public unstakes;
    
    event Register(address user, address refer);
    event Buy(address buyer, uint256 busd, uint256 token);
    event Payout(address buyer, uint256 token);
    event Staked(address buyer, uint256 busd, uint256 token);
   
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
            contractTokenBalance = hst.balanceOf(address(this)),
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
        busd.transferFrom(msg.sender,address(this),12e18);
        _register(msg.sender, _refer, 12e18);
        _distributeFee(12e18);
    }

    function _register(address buyer, address _refer, uint256 amt) internal {
        uint256 scaledAmount = 3e18;
        require(currentSupply >= scaledAmount.div(1e18));
        users[msg.sender].isActive = true;
        tokenSold += scaledAmount.div(1e18);
        if(buyer!=liquidator){
            if(users[buyer].refer==address(0x0)){
                setReferral(buyer,_refer);
            }
            setBusiness(buyer,_refer,amt);
        }
        deposits[buyer].push(Deposit(
            amt,
            scaledAmount,
            0,
            block.timestamp
        ));
        hst.transfer(buyer,scaledAmount);
        emit Register(buyer, _refer);
    }

    function setReferral(address direct, address refer) internal{
        users[direct].refer = refer;
        for(uint8 i=0; i<10; i++){
            users[users[direct].refer].levelTeam[i]++;
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function setBusiness(address direct, address refer, uint256 _busd) internal{
        users[direct].refer = refer;
        for(uint8 i=0; i<10; i++){
            users[users[direct].refer].business[i]+=_busd;
            direct = users[direct].refer;
            if(users[direct].refer==address(0x0)) break;
        }
    }

    function _distributeFee(uint256 _busd) internal{
        busd.transfer(feereceiver,_busd.mul(1).div(100));
        busd.transfer(feereceiver2,_busd.mul(1).div(100));
        busd.transfer(feereceiver3,_busd.mul(1).div(100));
    }

    function buy() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"Please register first!");
        require(deposits[msg.sender].length<2,"Sorry! your buy limit is over.");
        _buy(msg.sender, 60e18);
        _distributeFee(60e18);
    }

    function _buy(address buyer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = 20e18;
        require(currentSupply >= scaledAmount.div(1e18));
        tokenSold += scaledAmount.div(1e18);
        deposits[buyer].push(Deposit(
            _busd,
            scaledAmount,
            10,
            block.timestamp
        ));
        users[msg.sender].stakedTokens+=scaledAmount.div(1e18);
        users[msg.sender].tokens+=scaledAmount.mul(totalReturns).div(100);
        hst.transfer(buyer,scaledAmount.mul(maxReturns).div(100));
        setBusiness(buyer,users[msg.sender].refer,_busd);
        emit Buy(buyer, _busd, scaledAmount);
    }

    function stake() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"Please register first!");
        if(user.prequal==false){
            require(user.levelTeam[0]>=10,"Minimum 10 directs needed.");
        }
        require(deposits[msg.sender].length<3,"Sorry! your buy limit is over.");
        _stake(msg.sender, 500e18);
        _distributeFee(500e18);
    }

    function _stake(address buyer, uint256 _busd) internal {
        busd.transferFrom(msg.sender,address(this),_busd);
        uint256 scaledAmount = 250e18;
        require(currentSupply >= scaledAmount.div(1e18));
        tokenSold += scaledAmount.div(1e18);
        deposits[buyer].push(Deposit(
            _busd,
            scaledAmount,
            125,
            block.timestamp
        ));
        users[msg.sender].stakedTokens+=scaledAmount.div(1e18);
        users[msg.sender].tokens+=scaledAmount.mul(totalReturns).div(100);
        hst.transfer(buyer,scaledAmount.mul(maxReturns).div(100));
        setBusiness(buyer,users[msg.sender].refer,_busd);
        emit Staked(buyer, _busd, scaledAmount);
    }

    function recursion(address qual)external onlyLiquidator security{
        users[qual].prequal = true;
    }
    
    function userDetails(address user)public view returns(uint256 [10] memory members, uint256 [10] memory business, uint256 deposit, uint256 payout){
        for(uint8 i = 0; i < 10; i++){
            members[i] = users[user].levelTeam[i];
            business[i] = users[user].business[i];
        }
        deposit = deposits[user].length;
        payout = unstakes[user].length;
        return (members, business, deposit, payout);
    }

    function getRoiInfo(address buyer) public view returns(uint256 roi){
        uint256 myRoi;
        for(uint i=0;i<deposits[buyer].length;i++){
            Deposit storage pl = deposits[buyer][i];
            if(block.timestamp>pl.deptime){
                uint256 totalDays=getCurDay(pl.deptime);
                if(totalDays>=19){totalDays=19;}
                myRoi+=pl.nof.mul(totalDays).div(10);
            }
        }
        return (myRoi);
    }

    function unstake() public security{
        User storage user = users[msg.sender];
        require(user.isActive==true,"You are not activated.");
        uint256 myRoi;
        for(uint i=0;i<deposits[msg.sender].length;i++){
            Deposit storage pl = deposits[msg.sender][i];
            if(block.timestamp>pl.deptime){
                uint256 totalDays=getCurDay(pl.deptime);
                if(totalDays>=19){totalDays=19;}
                myRoi+=pl.nof.mul(totalDays).div(10);
            }
        }
        uint256 amount = myRoi.mul(1e18).sub(user.released);
        require(amount>=1e18,"Minimum 1 token withdraw.");
        hst.transfer(msg.sender,amount);
        user.released+=amount;
        user.lastUnlocked = block.timestamp;
        unstakes[msg.sender].push(Unstake(
            amount,
            block.timestamp
        ));
    }

    function releaseLiquidityFund(address _liquidator, uint _amount) external onlyLiquidator security{
        busd.transfer(_liquidator,_amount);
    }
   
    function releaseTokenAndCloseICO(address _liquidator,uint _amount) external onlyLiquidator security{
        hst.transfer(_liquidator,_amount);
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