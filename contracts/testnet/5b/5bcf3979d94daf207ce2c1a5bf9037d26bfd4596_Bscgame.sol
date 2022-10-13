/**
 *Submitted for verification at BscScan.com on 2022-10-12
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
contract Bscgame {
    using SafeMath for uint256; 
    BEP20 public busd = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 200; 
    uint256 private constant starPercents = 20;
    uint256 private constant managerPercents = 30;
    uint256 private constant dayPerCycle = 20 minutes; 
    uint256 private constant maxAddFreeze = 60 minutes;
    uint256 private constant timeStep = 2 minutes;
    uint256 private constant minDeposit = 50e18;
    uint256 private leaderStart = 0;
    uint256 private managerStart = 0;
    
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

    struct SingleLoop{
        uint256 ind;
    }
    struct SingleIndex{
        address ads;
    }
    
    
    mapping(uint => SingleIndex) public singleIndex;
    mapping(address => SingleLoop) public singleAds;
    mapping(address => UserDept[]) public userDepts;
    uint256 allIndex=1;
    
    address payable feeReceivers = 0xDAF52c017b91DD0868D376CD8351bb2f186be2dd;
    address public defaultRefer;
    address public aggregator;
    uint256 public startTime;
    
    mapping(uint256 => uint256) reward;
    mapping(uint256 => uint256) manager_reward;
    address [] reward_array;
    address [] manager_array;
    
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    
    uint[] level_bonuses = [500, 100, 200, 300, 100, 200, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];  
    uint[] single_bonuses = [200, 100, 100, 50, 50, 100, 100, 50, 50, 50, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50];  
    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized.");
        _;
    }
    constructor() public {
        startTime = block.timestamp;
        defaultRefer = msg.sender;
        singleIndex[0].ads=msg.sender;
        singleAds[msg.sender].ind=0;
        aggregator = msg.sender;
    }
    
    function contractInfo() public view returns(uint256 balance, uint256 init){
       return (busd.balanceOf(address(this)),startTime);
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
        _deposit(msg.sender, _busd,0);
        emit Deposit(msg.sender, _busd);
    }

    function _deposit(address _user, uint256 _amount, uint8 _isReDept) private {
        require(_amount>=minDeposit && _amount.mod(minDeposit) == 0, "Minimum 50 And Multiple 50");
        require(userInfo[_user].referrer != address(0), "register first");
        require(_amount>=userInfo[_user].myLastDeposit, "Amount greater than previous Deposit");
        userInfo[_user].myLastDeposit=_amount;
        busd.transferFrom(msg.sender,address(this),_amount);
        _distributeDeposit(_amount);
        
        uint256 addFreeze = userDepts[_user].length.mul(timeStep);
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
        if(singleAds[msg.sender].ind==0){
            singleIndex[allIndex].ads=msg.sender;
            singleAds[msg.sender].ind=allIndex;
            allIndex++;
        }
        _setReferral(_user,userInfo[_user].referrer,_amount,_isReDept);
        _setSingle(_user,userInfo[_user].referrer,_amount);
        
        if(_amount>=2000e18 && userInfo[_user].incomeArray[9]>=2000e18){
            userInfo[_user].totalIncome+=2000e18;
            userInfo[_user].incomeArray[9]-=2000e18;
        }else{
            unfreezeDepts(_user);
        }
        
        uint256 totalDays=getCurDay();
        reward[totalDays]+=_amount.mul(starPercents).div(baseDivider);
        manager_reward[totalDays]+=_amount.mul(managerPercents).div(baseDivider);
        updateLeader(totalDays);
        updateManager(totalDays);
    }

    function _setReferral(address _user,address _referral, uint256 _refAmount, uint8 _isReDept) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            if(_isReDept==0){
                userInfo[_referral].levelTeam[userInfo[_user].refNo]+=1;
            }
            userInfo[_referral].directBuz[userInfo[_user].refNo]+=_refAmount;
            if(userInfo[_referral].isStar==0 || userInfo[_referral].isLeader==0 || userInfo[_referral].isManager==0){
                (uint256 ltA,uint256 ltB,uint256 lbA, uint256 lbB)=teamBuzInfo(_referral);
                if(userInfo[_referral].isStar==0 && ltA>=5 && ltB>=15 && userInfo[_referral].myLastDeposit>=500e18 && lbA>=5000e18 && lbB>=5000e18){
                   userInfo[_referral].isStar=1;
                }
                if(userInfo[_referral].isLeader==0 && ltA>=10 && ltB>=30 && userInfo[_referral].myLastDeposit>=1000e18 && lbA>=10000e18 && lbB>=10000e18){
                   userInfo[_referral].isLeader=1;
                   reward_array.push(_referral);
                }
                if(userInfo[_referral].isManager==0 && ltA>=30 && ltB>=90 && userInfo[_referral].myLastDeposit>=2000e18 && lbA>=30000e18 && lbB>=30000e18){
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
                if(userInfo[_referral].isStar==1 && i < 5){
                    userInfo[_referral].incomeArray[9]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[3]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }else if(userInfo[_referral].isLeader==1 && i >= 5 && i < 10){
                    userInfo[_referral].incomeArray[9]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[4]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }else if(userInfo[_referral].isManager==1 && i >= 10){
                    userInfo[_referral].incomeArray[9]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[5]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }
            }
            
           _user = _referral;
           _referral = userInfo[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }

    function _setSingle(address _myAds, address _referral, uint256 _refAmount) private {
        uint256 selfIndex=singleAds[_myAds].ind-1;
        uint256 selfLimit=(selfIndex>19)?selfIndex-19:0;
        uint256 s=0;
        for(uint256 k = selfIndex; k >=selfLimit; k--) {
            uint256 levelSelf=_refAmount;
            address selfads=singleIndex[k].ads;
            if(s<5 || (s>=5 && s<10 && userInfo[selfads].myLastDeposit>=500e18) || (s>=10 && userInfo[selfads].myLastDeposit>=1000e18)){
                if(_refAmount>userInfo[selfads].myLastDeposit){
                    levelSelf=userInfo[selfads].myLastDeposit;
                }
                userInfo[selfads].incomeArray[9]+=levelSelf.mul(single_bonuses[s]).div(baseDivider);
                userInfo[selfads].incomeArray[8]+=levelSelf.mul(single_bonuses[s]).div(baseDivider);
            }    
            s++;
            
            if(k<1) break;
        }
        uint256 myIndex=singleAds[_referral].ind-1;
        uint256 myLimit=(myIndex>19)?myIndex-19:0;
        uint256 j=0;
        for(uint256 i = myIndex; i >=myLimit; i--) {
            uint256 levelOn=_refAmount;
            address myads=singleIndex[i].ads;
            if(j<5 || (j>=5 && j<10 && userInfo[myads].myLastDeposit>=500e18) || (j>=10 && userInfo[myads].myLastDeposit>=1000e18)){
                if(_refAmount>userInfo[myads].myLastDeposit){
                    levelOn=userInfo[myads].myLastDeposit;
                }
                userInfo[myads].incomeArray[9]+=levelOn.mul(single_bonuses[j]).div(baseDivider);
                userInfo[myads].incomeArray[8]+=levelOn.mul(single_bonuses[j]).div(baseDivider);
            }   
            j++;
            if(i<1) break;
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        busd.transfer(feeReceivers,fee);
    }

    function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].myLastDeposit == 0, "actived");
        uint256 splitLeft = userInfo[msg.sender].split.sub(userInfo[msg.sender].splitAct).sub(userInfo[msg.sender].splitTrnx);
        require(splitLeft >= _amount, "insufficient split");
        userInfo[msg.sender].splitAct = userInfo[msg.sender].splitAct.add(_amount);
        _deposit(msg.sender, _amount,1);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(uint256 _amount,address _receiver) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        uint256 splitLeft = userInfo[msg.sender].split.sub(userInfo[msg.sender].splitAct).sub(userInfo[msg.sender].splitTrnx);
        require(splitLeft >= _amount, "insufficient income");
        userInfo[msg.sender].splitTrnx = userInfo[msg.sender].splitTrnx.add(_amount);
        userInfo[_receiver].split = userInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }

    function unfreezeDepts(address _addr) private {
        uint8 isdone;
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            if(pl.isUnfreezed==false && block.timestamp>=pl.unfreeze && isdone==0){
                pl.isUnfreezed=true;
                userInfo[_addr].totalIncome+=pl.amount;
                userInfo[_addr].totalIncome+=pl.amount.mul(150).div(1000);
                userInfo[_addr].incomeArray[0]+=pl.amount;
                userInfo[_addr].incomeArray[1]+=pl.amount.mul(150).div(1000);
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

    function leaderPool() view external returns(uint256 lp,uint256 lr,uint256 lpTeam,uint256 mp,uint256 mr,uint256 mpTeam) {
        uint256 totalDays=getCurDay();
        if(reward_array.length==0){
            for(uint256 i=0; i <= totalDays; i++){
                lp+=reward[i];
            }
            lr=lp-reward[totalDays-1];
        }else{
            lp=reward[totalDays];
            lr=reward[totalDays-1];
        }
        if(manager_array.length==0){
            for(uint256 i=0; i <= totalDays; i++){
                mp+=manager_reward[i];
            }
            mr=mp-manager_reward[totalDays-1];
        }else{
            mp=manager_reward[totalDays];
            mr=manager_reward[totalDays-1];
        }
        return (lp,lr,reward_array.length,mp,mr,manager_array.length);
    }

    function incomeDetails(address _addr) view external returns(uint256[10] memory p) {
        for(uint8 i=0;i<=9;i++){
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
        require(_amount >= 10e18, "Minimum 10 need");
        
        UserInfo storage player = userInfo[msg.sender];
        uint256 bonus;
        bonus=player.totalIncome-player.totalWithdraw;
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.totalWithdraw+=_amount;
        uint256 tempSplit=(bonus-player.incomeArray[0]).mul(30).div(100);
        player.incomeArray[0]=0;
        player.split+=tempSplit;
        uint256 wamount=_amount.sub(tempSplit);
        busd.transfer(msg.sender,wamount);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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