/**
 *Submitted for verification at BscScan.com on 2022-11-16
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
contract TheGems {
    using SafeMath for uint256; 
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 100; 
    uint256 private constant leaderPercents = 20;
    uint256 private constant managerPercents = 30;
    uint256 private constant dayPerCycle = 15 days; 
    uint256 private constant maxAddFreeze = 45 days;
    uint256 private constant timeStep = 1 days;
    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant splitMod = 100e18;
    uint256 private welcomeStart = 0;
    uint256 private leaderStart = 0;
    uint256 private managerStart = 0;
    
    struct UserInfo {
        address referrer;
        uint256 refNo;
        uint256 myLastDeposit;
        uint256 totalIncome;
        uint256 totalWithdraw;
        uint256 isLeader;
        uint256 isManager;
        uint256 split;
        uint256 splitAct;
        uint256 splitTrnx;
        uint256 myRegister;
        uint256 myActDirect;
        uint256 aftFreez;
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
    
    struct Welcome_array{
        address qads;
    }
    mapping(uint256 => Welcome_array[]) public welcome_array;
    address feeReceiver = 0xB80664278eea58B6Fd100dA73974a507Ce454CF7;
   
    address public ombudsman;
    address public defaultRefer;
    uint256 public startTime;
    
    mapping(uint256 => uint256) welcome;
    mapping(uint256 => uint256) reward;
    mapping(uint256 => uint256) manager_reward;
    address [] reward_array;
    address [] manager_array;
    
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    
    uint[] level_bonuses = [500, 100, 200, 300, 100, 200, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];  
    
    constructor() public {
        startTime = block.timestamp;
        defaultRefer = msg.sender;
        ombudsman = msg.sender;
    }
    
    function contractInfo() public view returns(uint256 balance, uint256 init){
       return (busd.balanceOf(address(this)),startTime);
    }
    
    function register(address _referral) external {
        require(userInfo[_referral].myLastDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        require(user.refNo == 0, "Already Registered.");
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
        require(_amount>=minDeposit && _amount<=maxDeposit && _amount.mod(minDeposit) == 0, "Minimum 100 , Multiple 100 and maximum 2000 busd");
        require(userInfo[_user].referrer != address(0), "register first");
        require(_amount>=userInfo[_user].myLastDeposit, "Amount greater than previous Deposit");
        bool _isReDept = false;
        if(userInfo[_user].myLastDeposit==0){
            userInfo[userInfo[_user].referrer].myActDirect++;
        }else{
            _isReDept=true;
        }
        userInfo[_user].myLastDeposit=_amount;
        if(isSplitDept==false){
            busd.transferFrom(msg.sender,address(this),_amount);
        }
        
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
        
        if(_amount>=2000e18 && userInfo[_user].incomeArray[8]>=2000e18){
            userInfo[_user].totalIncome+=2000e18;
            userInfo[_user].incomeArray[8]-=2000e18;
            userInfo[_user].aftFreez=2000e18;
        }else{
            unfreezeDepts(_user);
        }
        
        uint256 totalDays=getCurDay();
        if(_amount>=2000e18){
            welcome_array[totalDays].push(Welcome_array(
                _user
            ));
        }
        welcome[totalDays]+=_amount.mul(30).div(baseDivider);
        reward[totalDays]+=_amount.mul(leaderPercents).div(baseDivider);
        manager_reward[totalDays]+=_amount.mul(managerPercents).div(baseDivider);
        updateWelcome(totalDays);
        updateLeader(totalDays);
        updateManager(totalDays);
    }

    function _setReferral(address _user,address _referral, uint256 _refAmount, bool _isReDept) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            if(_isReDept==false){
                userInfo[_referral].levelTeam[userInfo[_user].refNo]+=1;
            }
            userInfo[_referral].directBuz[userInfo[_user].refNo]+=_refAmount;
            if(userInfo[_referral].isLeader==0 || userInfo[_referral].isManager==0){
                (uint256 ltA,uint256 ltB,uint256 lbA, uint256 lbB)=teamBuzInfo(_referral);
                if(userInfo[_referral].isLeader==0 && userInfo[_referral].myActDirect>=3 && ltA>=40 && ltB>=40 && userInfo[_referral].myLastDeposit>=1000e18 && lbA>=10000e18 && lbB>=10000e18){
                   userInfo[_referral].isLeader=1;
                   reward_array.push(_referral);
                }
                if(userInfo[_referral].isManager==0 && userInfo[_referral].myActDirect>=5 && ltA>=80 && ltB>=80 && userInfo[_referral].myLastDeposit>=2000e18 && lbA>=40000e18 && lbB>=40000e18){
                   userInfo[_referral].isManager=1;
                   manager_array.push(_referral);
                }
            }
            uint256 levelOn=_refAmount;
            if(_refAmount>userInfo[_referral].myLastDeposit){
                levelOn=userInfo[_referral].myLastDeposit;
            }
            if(i==0){
                userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                userInfo[_referral].incomeArray[2]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
            }else{
                if(userInfo[_referral].isLeader==1 &&  i < 10){
                    userInfo[_referral].incomeArray[8]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[3]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }else if(userInfo[_referral].isManager==1 && i >= 10){
                    userInfo[_referral].incomeArray[8]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[4]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }
            }
            
           _user = _referral;
           _referral = userInfo[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }
    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        busd.transfer(feeReceiver,fee);
    }

    function depositBySplit(uint256 _amount) external {
        require(_amount.mod(splitMod) == 0, "amount should be multiple of 100");
        require(_amount >= minDeposit && _amount <= maxDeposit && _amount.mod(minDeposit) == 0, "amount err");
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
        uint256 aftDed=_amount.mul(90).div(100);
        userInfo[_receiver].split = userInfo[_receiver].split.add(aftDed);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    function unfreezeDepts(address _addr) private {
        uint8 isdone;
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            if(pl.isUnfreezed==false && block.timestamp>=pl.unfreeze && isdone==0){
                pl.isUnfreezed=true;
                userInfo[_addr].totalIncome+=pl.amount;
                userInfo[_addr].totalIncome+=pl.amount.mul(225).div(1000);
                userInfo[_addr].incomeArray[0]+=pl.amount;
                userInfo[_addr].incomeArray[1]+=pl.amount.mul(225).div(1000);
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
    
    function updateWelcome(uint256 totalDays) private {
        if(welcomeStart==0){
            if(welcome_array[totalDays].length>0){
                uint256 distLAmount;
                for(uint256 i=0; i < totalDays; i++){
                    distLAmount+=welcome[i];
                    welcome[i]=0;
                }
                distLAmount=distLAmount.div(welcome_array[totalDays].length);
                for(uint8 i = 0; i < welcome_array[totalDays].length; i++) {
                    userInfo[welcome_array[totalDays][i].qads].totalIncome+=distLAmount;
                    userInfo[welcome_array[totalDays][i].qads].incomeArray[5]+=distLAmount;
                }
                welcomeStart=1;
            }
            
        }else if(welcomeStart>0 && welcome[totalDays-1]>0){
            if(welcome_array[totalDays].length>0){
                uint256 distLAmount=welcome[totalDays-1].div(welcome_array[totalDays].length);
                for(uint8 i = 0; i < welcome_array[totalDays].length; i++) {
                    userInfo[welcome_array[totalDays][i].qads].totalIncome+=distLAmount;
                    userInfo[welcome_array[totalDays][i].qads].incomeArray[5]+=distLAmount;
                }
                welcome[totalDays-1]=0;
            }
        }
    }
    function updateLeader(uint256 totalDays) private {
        if(leaderStart==0){
            if(reward_array.length>0){
                uint256 distLAmount;
                for(uint256 i=0; i < totalDays; i++){
                    distLAmount+=reward[i];
                    reward[i]=0;
                }
                distLAmount=distLAmount.div(reward_array.length);
                for(uint8 i = 0; i < reward_array.length; i++) {
                    userInfo[reward_array[i]].totalIncome+=distLAmount;
                    userInfo[reward_array[i]].incomeArray[6]+=distLAmount;
                }
                leaderStart=1;
            }
            
        }else if(leaderStart>0 && reward[totalDays-1]>0){
            if(reward_array.length>0){
                uint256 distLAmount=reward[totalDays-1].div(reward_array.length);
                for(uint8 i = 0; i < reward_array.length; i++) {
                    userInfo[reward_array[i]].totalIncome+=distLAmount;
                    userInfo[reward_array[i]].incomeArray[6]+=distLAmount;
                }
                reward[totalDays-1]=0;
            }
        }
    }

    function royaltyReward(address _rewardee, uint256 _reward) external{
        require(msg.sender == ombudsman);
        busd.transfer(_rewardee,_reward);
    }

    function updateManager(uint256 totalDays) private {
        if(managerStart==0){
            if(manager_array.length>0){
                uint256 distAmount;
                for(uint256 i=0; i < totalDays; i++){
                    distAmount+=manager_reward[i];
                    manager_reward[i]=0;
                }
                distAmount=distAmount.div(manager_array.length);
                for(uint8 i = 0; i < manager_array.length; i++) {
                    userInfo[manager_array[i]].totalIncome+=distAmount;
                    userInfo[manager_array[i]].incomeArray[7]+=distAmount;
                }
                managerStart=1;
            }
            
        }else if(managerStart>0 && manager_reward[totalDays-1]>0){
            if(manager_array.length>0){
                uint256 distAmount=manager_reward[totalDays-1].div(manager_array.length);
                for(uint8 i = 0; i < manager_array.length; i++) {
                    userInfo[manager_array[i]].totalIncome+=distAmount;
                    userInfo[manager_array[i]].incomeArray[7]+=distAmount;
                }
                manager_reward[totalDays-1]=0;
            } 
        }
    }
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    function leaderPool() view external returns(uint256 lp,uint256 lpTeam,uint256 mp,uint256 mpTeam,uint256 wp,uint256 wpTeam) {
        uint256 totalDays=getCurDay();
        return (reward[totalDays],reward_array.length,manager_reward[totalDays],manager_array.length,welcome[totalDays],welcome_array[totalDays].length);
    }

    function incomeDetails(address _addr) view external returns(uint256[9] memory p) {
        for(uint8 i=0;i<9;i++){
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
           player.myRegister
           
        );
    }
    
    function withdraw(uint256 _amount) public{
        require(_amount >= 1e18, "Minimum 1 need");
        
        UserInfo storage player = userInfo[msg.sender];
        uint256 bonus;
        bonus=player.totalIncome-player.totalWithdraw;
        if(userDepts[msg.sender].length>=5){
            uint256 myDirBuzz;
            for(uint256 i=0;i<player.myRegister;i++){
                myDirBuzz+=player.directBuz[i];
            }
            if(block.timestamp>=userDepts[msg.sender][4].unfreeze && myDirBuzz<player.myLastDeposit){
                bonus=0;
            }
            
        }
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.totalWithdraw+=_amount;
        uint256 tempSplit=(bonus-player.incomeArray[0]).mul(30).div(100);
        player.incomeArray[0]=0;
        player.incomeArray[1]=0;
        player.incomeArray[2]=0;
        player.incomeArray[5]=0;
        player.incomeArray[6]=0;
        player.incomeArray[7]=0;
        if(player.aftFreez>=player.incomeArray[3]){
            player.aftFreez-=player.incomeArray[3];
            player.incomeArray[3]=0;
        }else{
            player.aftFreez=0;
            player.incomeArray[3]-=player.aftFreez;
        }
        if(player.aftFreez>=player.incomeArray[4]){
            player.aftFreez-=player.incomeArray[4];
            player.incomeArray[4]=0;
        }else{
            player.aftFreez=0;
            player.incomeArray[4]-=player.aftFreez;
        }
        player.split+=tempSplit;
        uint256 wamount=_amount.sub(tempSplit);
        busd.transfer(msg.sender,wamount);
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