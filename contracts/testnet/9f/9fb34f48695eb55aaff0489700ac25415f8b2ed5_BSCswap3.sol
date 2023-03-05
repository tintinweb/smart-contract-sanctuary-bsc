/**
 *Submitted for verification at BscScan.com on 2023-03-04
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
contract BSCswap3 {
    using SafeMath for uint256; 
    BEP20 public busd = BEP20(0xDc6cc6d847DF088C3eEDA72404864B59c0cD53B2); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 300; 
    uint256 private constant managerPercents = 20;
    uint256 private constant dayPerCycle = 15 minutes; 
    uint256 private constant maxAddFreeze = 45 minutes;
    uint256 private constant timeStep = 1 minutes;
    uint256 private constant minDeposit = 100e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant splitMod = 100e18;
    uint256 private leaderStart = 0;
    uint256 private managerStart = 0;

    mapping(uint256=>bool) private balStatus;
    bool private freezeStaticReward;
    bool private freezeDynamicReward;
    
    struct UserInfo {
        address referrer;
        uint256 refNo;
        uint256 myLastDeposit;
        uint256 totalIncome;
        uint256 totalWithdraw;
        uint256 isSilver;
        uint256 isGold;
        uint256 isDiamond;
        uint256 isDoubleDiamond;
        uint256 split;
        uint256 myRegister;
        uint256 realeasedROI;
        
        mapping(uint256 => uint256) dailyDirect;
        mapping(uint256 => uint256) myActDirect;
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
    struct Silver_array{
        address qads;
    }
    mapping(uint256 => Silver_array[]) public silver_array;
    
    address feeReceiver = 0x6fB733BbFB38fDaFb12aEdC852E23B9197E27BB9;
    
    address public defaultRefer;
    uint256 public startTime;
    
    mapping(uint256 => uint256) silver;
    mapping(uint256 => uint256) topPool;
    mapping(uint256 => uint256) leader_reward;
    mapping(uint256 => uint256) manager_reward;
    address [] manager_array;
    address [] leader_array;
    mapping(uint256 => mapping(uint256 => uint256)) toppool_buz;
    mapping(uint256 => mapping(uint256 => address)) toppool_list;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    
    uint[] level_bonuses = [500, 200, 100, 200, 100, 200, 100, 100, 100, 100, 50, 50, 50, 50, 50, 25, 25, 25, 25, 25];
    uint256[3] private top_bonus = [50,30,20];
    uint256[8] private balReached = [1000e18, 2000e18, 4000e18, 6000e18, 8000e18, 100000e18, 15000e18, 20000e18];
    uint256[8] private balFreezeStatic = [700e18, 1400e18, 2800e18, 4200e18, 5600e18, 7000e18, 10500e18, 14000e18];
    uint256[8] private balFreezeDynamic = [400e18, 800e18, 1600e18, 2400e18, 3200e18, 4000e18, 6000e18, 8000e18];
    uint256[8] private balRecover = [700e18, 1400e18, 2800e18, 4200e18, 5600e18, 7000e18, 10500e18, 14000e18];

    modifier security {
        uint size;
        address sandbox = msg.sender;
        assembly { size := extcodesize(sandbox) }
        require(size == 0, "Smart contract detected!");
        _;
    }

    constructor() public {
        startTime = block.timestamp;
        defaultRefer = msg.sender;
    }
    
    function contractInfo() public view returns(uint256 balance, uint256 init){
       return (busd.balanceOf(address(this)),startTime);
    }
    
    function register(address _referral) external security{
        require(userInfo[_referral].myLastDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        require(user.refNo == 0, "Already Registered.");
        user.referrer = _referral;
        user.refNo = userInfo[_referral].myRegister;
        userInfo[_referral].myRegister++;
        emit Register(msg.sender, _referral);
    }
    
    function deposit(uint256 _busd) external security{
        _deposit(msg.sender, _busd);
        emit Deposit(msg.sender, _busd);
    }

    function _deposit(address _user, uint256 _amount) private {
        require(_amount>=minDeposit && _amount<=maxDeposit && _amount.mod(minDeposit) == 0, "Minimum 100 , Multiple 100 and maximum 2000 busd");
        require(userInfo[_user].referrer != address(0), "register first");
        require(_amount>=userInfo[_user].myLastDeposit, "Amount greater than previous Deposit");
        bool _isReDept = false;
        if(userInfo[_user].myLastDeposit==0){
            userInfo[userInfo[_user].referrer].myActDirect[0]++;
        }else{
            _isReDept=true;
        }
        userInfo[_user].myLastDeposit=_amount;
        busd.transferFrom(msg.sender,address(this),_amount);
        
        _distributeDeposit(_amount);
        
        uint256 addFreeze = (userDepts[_user].length).mul(timeStep);
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
        userInfo[_user].incomeArray[10]+=_amount;
        _setReferral(_user,userInfo[_user].referrer,_amount,_isReDept);
        
        if(_amount>=2000e18 && userInfo[_user].incomeArray[5]>=2000e18){
            userInfo[_user].totalIncome+=2000e18;
            userInfo[_user].incomeArray[5]-=2000e18;
        }else{
            unfreezeDepts(_user);
        }
        
        uint256 totalDays=getCurDay();
        silver[totalDays]+=_amount.mul(30).div(baseDivider);
        topPool[totalDays]+=_amount.mul(managerPercents).div(baseDivider);
        leader_reward[totalDays]+=_amount.mul(managerPercents).div(baseDivider);
        manager_reward[totalDays]+=_amount.mul(managerPercents).div(baseDivider);
        updateSilver(totalDays);
        updateLeader(totalDays);
        updateManager(totalDays);
        updatetopPool(totalDays);

        address _ref=userInfo[_user].referrer;
        userInfo[_ref].dailyDirect[totalDays]+=_amount;

        _topPoolTeam(_ref,userInfo[_ref].dailyDirect[totalDays],totalDays);

        uint256 bal = busd.balanceOf(address(this));
        _balActived(bal);
        if(freezeStaticReward || freezeDynamicReward){
            _setFreezeReward(bal);
        }
    }
    function _balActived(uint256 _bal) private {
        for(uint256 i = balReached.length; i > 0; i--){
            if(_bal >= balReached[i - 1]){
                balStatus[balReached[i - 1]] = true;
                break;
            }
        }
    }

    function _topPoolTeam(address _ref,uint256 _refBuzz,uint256 nofdays) private {
        for(uint256 k=0;k<3;k++){
            if(_refBuzz>toppool_buz[nofdays][k]){
                if(k==0){
                    toppool_buz[nofdays][2]=toppool_buz[nofdays][1];
                    toppool_list[nofdays][2]=toppool_list[nofdays][1];
                    toppool_buz[nofdays][1]=toppool_buz[nofdays][0];
                    toppool_list[nofdays][1]=toppool_list[nofdays][0];
                    toppool_buz[nofdays][0]=_refBuzz;
                    toppool_list[nofdays][0]=_ref;
                }else if(k==1){
                    toppool_buz[nofdays][2]=toppool_buz[nofdays][1];
                    toppool_list[nofdays][2]=toppool_list[nofdays][1];
                    toppool_buz[nofdays][1]=_refBuzz;
                    toppool_list[nofdays][1]=_ref;
                }else{
                    toppool_buz[nofdays][2]=_refBuzz;
                    toppool_list[nofdays][2]=_ref;
                }
            }
        }
    }
    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balReached.length; i > 0; i--){
            if(balStatus[balReached[i - 1]]){
                if(_bal < balFreezeStatic[i - 1]){
                    freezeStaticReward = true;
                    if(_bal < balFreezeDynamic[i - 1]){
                        freezeDynamicReward = true;
                    }
                }else{
                    if((freezeStaticReward || freezeDynamicReward) && _bal >= balRecover[i - 1]){
                        freezeStaticReward = false;
                        freezeDynamicReward = false;
                    }
                }
                break;
            }
        }
    }
    function _setReferral(address _user,address _referral, uint256 _refAmount, bool _isReDept) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            if(_isReDept==false){
                userInfo[_referral].levelTeam[userInfo[_user].refNo]+=1;
            }
            userInfo[_referral].directBuz[userInfo[_user].refNo]+=_refAmount;
            if(userInfo[_referral].isSilver==0 || userInfo[_referral].isGold==0 || userInfo[_referral].isDiamond==0|| userInfo[_referral].isDoubleDiamond==0){
                (uint256 ltA,uint256 ltB,uint256 lbA, uint256 lbB)=teamBuzInfo(_referral);
                if(userInfo[_referral].isSilver==0 && userInfo[_referral].myActDirect[0]>=2 && userInfo[_referral].myLastDeposit>=100e18 && lbA>=200e18 && lbB>=300e18){
                    userInfo[_referral].isSilver=1;
                    userInfo[userInfo[_referral].referrer].myActDirect[1]++;
                    uint256 totalDays=getCurDay();
                    silver_array[totalDays].push(Silver_array(
                        _referral
                    ));
                }
                if(userInfo[_referral].isGold==0 && userInfo[_referral].myActDirect[1]>=1 && userInfo[_referral].myLastDeposit>=100e18 && (ltA+ltB)>=10 && lbA>=500e18 && lbB>=700e18){
                   userInfo[_referral].isGold=1;
                   userInfo[userInfo[_referral].referrer].myActDirect[2]++;
                }
                if(userInfo[_referral].isDiamond==0 && userInfo[_referral].myActDirect[2]>=1 && userInfo[_referral].myLastDeposit>=200e18 && (ltA+ltB)>=20 && lbA>=800e18 && lbB>=1000e18){
                   userInfo[_referral].isDiamond=1;
                   userInfo[userInfo[_referral].referrer].myActDirect[3]++;
                   leader_array.push(_referral);
                }
                if(userInfo[_referral].isDoubleDiamond==0 && userInfo[_referral].myActDirect[3]>=1 && userInfo[_referral].myLastDeposit>=500e18 && (ltA+ltB)>=30 && lbA>=1000e18 && lbB>=1200e18){
                   userInfo[_referral].isDoubleDiamond=1;
                   userInfo[userInfo[_referral].referrer].myActDirect[4]++;
                   manager_array.push(_referral);
                }
            }
            uint256 isok=0;
            if(_referral==defaultRefer){
                isok=1;
            }else{
                uint256 nofDept = userDepts[_referral].length;
                if(userDepts[_referral][nofDept-1].unfreeze>=block.timestamp){ 
                    isok=1;
                }
            }
            if(isok==1 && (freezeStaticReward==false || _isReDept==false)){
                uint256 levelOn=_refAmount;
                if(_refAmount>userInfo[_referral].myLastDeposit){
                    levelOn=userInfo[_referral].myLastDeposit;
                }
            
                if(i==0){
                    userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[2]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }else{
                    if(userInfo[_referral].isSilver==1 && i>=1 && i < 3){
                        userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                        userInfo[_referral].incomeArray[3]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    }
                    else if(userInfo[_referral].isGold==1 && i>=3 && i < 5){
                        userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                        userInfo[_referral].incomeArray[4]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    }else if(userInfo[_referral].isDiamond==1 && i >= 5 && i < 15){
                        userInfo[_referral].incomeArray[5]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                        userInfo[_referral].incomeArray[11]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    }else if(userInfo[_referral].isDoubleDiamond==1 && i >= 15){
                        userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                        userInfo[_referral].incomeArray[6]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
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
        busd.transfer(feeReceiver,fee);
    }

    function unfreezeDepts(address _addr) private {
        uint8 isdone;
        uint256 totalRevenue=userInfo[_addr].totalIncome;
        for(uint j=0;j<userDepts[_addr].length;j++){
            if(userDepts[_addr][j].isUnfreezed==true){
                totalRevenue-=userDepts[_addr][j].amount;
            }else{
                break;
            }
        }
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            if(pl.isUnfreezed==false && block.timestamp>=pl.unfreeze && isdone==0){
                pl.isUnfreezed=true;
                userInfo[_addr].totalIncome+=pl.amount;
                userInfo[_addr].incomeArray[0]+=pl.amount;
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
    function updateSilver(uint256 totalDays) private {
        totalDays-=1;
        if(silver[totalDays]>0){
            if(silver_array[totalDays].length>0){
                uint256 distLAmount=silver[totalDays].div(silver_array[totalDays].length);
                for(uint8 i = 0; i < silver_array[totalDays].length; i++) {
                    userInfo[silver_array[totalDays][i].qads].totalIncome+=distLAmount;
                    userInfo[silver_array[totalDays][i].qads].incomeArray[9]+=distLAmount;
                }
                silver[totalDays]=0;
            }
        }
    }
    function updateLeader(uint256 totalDays) private {
        if(leaderStart==0){
            if(leader_array.length>0){
                uint256 distAmount;
                for(uint256 i=0; i < totalDays; i++){
                    distAmount+=leader_reward[i];
                    leader_reward[i]=0;
                }
                distAmount=distAmount.div(leader_array.length);
                for(uint8 i = 0; i < leader_array.length; i++) {
                    userInfo[leader_array[i]].totalIncome+=distAmount;
                    userInfo[leader_array[i]].incomeArray[7]+=distAmount;
                }
                leaderStart=1;
            }
            
        }else if(leaderStart>0 && leader_reward[totalDays-1]>0){
            if(leader_array.length>0){
                uint256 distAmount=leader_reward[totalDays-1].div(leader_array.length);
                for(uint8 i = 0; i < leader_array.length; i++) {
                    userInfo[leader_array[i]].totalIncome+=distAmount;
                    userInfo[leader_array[i]].incomeArray[7]+=distAmount;
                }
                leader_reward[totalDays-1]=0;
            } 
        }
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
                    userInfo[manager_array[i]].incomeArray[8]+=distAmount;
                }
                managerStart=1;
            }
            
        }else if(managerStart>0 && manager_reward[totalDays-1]>0){
            if(manager_array.length>0){
                uint256 distAmount=manager_reward[totalDays-1].div(manager_array.length);
                for(uint8 i = 0; i < manager_array.length; i++) {
                    userInfo[manager_array[i]].totalIncome+=distAmount;
                    userInfo[manager_array[i]].incomeArray[8]+=distAmount;
                }
                manager_reward[totalDays-1]=0;
            } 
        }
    }
    function updatetopPool(uint256 nof) private {
        uint256 totalDays=nof-1;
        if(topPool[totalDays]>0){
            for(uint256 i=0; i < 3; i++){
                if(toppool_list[totalDays][i]!=address(0)){
                    userInfo[toppool_list[totalDays][i]].totalIncome+=topPool[totalDays].mul(top_bonus[i]).div(100);
                    userInfo[toppool_list[totalDays][i]].incomeArray[12]+=topPool[totalDays].mul(top_bonus[i]).div(100);
                }
            }
        }
    }
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    function getplDay(uint256 pl) public view returns(uint256) {
        return (block.timestamp.sub(pl)).div(timeStep);
    }
    function leaderPool() view external returns(uint256 mp,uint256 mpTeam,uint256 lp,uint256 lpTeam,uint256 sp,uint256 spTeam) {
        uint256 totalDays=getCurDay();
        return (manager_reward[totalDays],manager_array.length,leader_reward[totalDays],leader_array.length,silver[totalDays],silver_array[totalDays].length);
    }

    function incomeDetails(address _addr) view external returns(uint256[12] memory p) {
        for(uint8 i=0;i<12;i++){
            p[i]=userInfo[_addr].incomeArray[i];
        }
        return (
           p
        );
    }
    function roiDetails(address _addr) view external returns(uint256 tr,uint256 wr,uint256 avl) {
        tr=0;
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            uint256 totalpl=getplDay(pl.depTime);
            totalpl=(totalpl>=15)?15:totalpl;
            tr+=pl.amount.mul(totalpl).div(100);
        }
        return (
            tr,
            userInfo[_addr].realeasedROI,
            tr-userInfo[_addr].realeasedROI
        );
    }
    
    function userDetails(address _addr) view external returns(address ref,uint256 lbA,uint256 lbB,uint256 myreg,uint256 myDirect,uint256 mysl,uint256 mygo,uint256 mydia,uint256 mydd) {
        UserInfo storage player = userInfo[_addr];
        uint256 lbATemp;
        uint256 lb;
        for(uint256 i=0;i<player.myRegister;i++){
            lb+=player.directBuz[i];
            if(lbATemp==0 || player.directBuz[i]>lbATemp){
               lbATemp=player.directBuz[i]; 
            }
        }
        lbB=lb-lbATemp;
        return (
           player.referrer,
           lbATemp,
           lbB,
           player.myRegister,
           player.myActDirect[0],
           player.myActDirect[1],
           player.myActDirect[2],
           player.myActDirect[3],
           player.myActDirect[4]
        );
    }
    function getBalInfos(uint256 _bal) external view returns(bool, bool, bool) {
        return(balStatus[_bal], freezeStaticReward, freezeDynamicReward);
    }
    function withdraw(uint256 _amount) public security{
        require(_amount >= 10e18, "Minimum 10 need");
        
        UserInfo storage player = userInfo[msg.sender];
        uint256 totalROI;
        for(uint i=0;i<userDepts[msg.sender].length;i++){
            UserDept storage pl = userDepts[msg.sender][i];
            uint256 totalpl=getplDay(pl.depTime);
            totalpl=(totalpl>=15)?15:totalpl;
            totalROI+=pl.amount.mul(totalpl).div(100);
        }
        totalROI=totalROI.sub(player.realeasedROI);
        uint256 bonus;
        bonus=player.totalIncome+totalROI-player.totalWithdraw;
        if(userDepts[msg.sender].length>=9){
            uint256 myDirBuzz;
            for(uint256 i=0;i<player.myRegister;i++){
                myDirBuzz+=player.directBuz[i];
            }
            if(block.timestamp>=userDepts[msg.sender][8].unfreeze && myDirBuzz<player.myLastDeposit){
                bonus=0;
            }
        }
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.totalWithdraw+=_amount;
        uint256 tempSplit=(bonus-player.incomeArray[0]).mul(20).div(100);
        player.incomeArray[0]=0;
        player.incomeArray[2]=0;
        player.incomeArray[3]=0;
        player.incomeArray[4]=0;
        player.incomeArray[6]=0;
        player.incomeArray[7]=0;
        player.incomeArray[8]=0;
        player.incomeArray[9]=0;
        player.incomeArray[12]=0;
        
        player.split+=tempSplit;
        player.realeasedROI+=totalROI;
        player.incomeArray[1]+=totalROI;
        uint256 wamount=_amount.sub(tempSplit);
        busd.transfer(msg.sender,wamount);
        busd.transfer(feeReceiver,tempSplit);
        uint256 bal = busd.balanceOf(address(this));
        _setFreezeReward(bal);
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