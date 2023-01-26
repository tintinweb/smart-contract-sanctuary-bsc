/**
 *Submitted for verification at BscScan.com on 2023-01-26
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


pragma solidity ^0.8.0;


interface IERC20 {
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



    contract UBCInternational  {
    using SafeMath for uint256; 
    IERC20 public USDT;
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 200; 
    uint256 private constant minDeposit = 50e18;
     uint256 private constant minDepositActivation =50e18;
    uint256 private constant maxDepositActivation = 2000e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 2500;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 10 days; 
    uint256 private constant dayRewardPercents = 100;
    uint256 private constant maxAddFreeze = 20 days;
     uint256[5] private initialreward = [500, 100,100,100,200];
    uint256 private initialrewardsum = 1000;   // 10 %
    uint256 private constant referDepth = 20;
    uint256 private constant directDepth = 1;
    uint256 private constant directPercents = 2500;
    uint256[4] private crowndirectorPercents = [2000,1500,1000,1000];   // rank - 3
    uint256[5] private diamonddirectorPercents = [500,500,500,500,500];      // rank - 4
    uint256[10] private globaldirectorPercents = [200, 200, 200, 200, 200, 200, 200, 200, 200, 200];  // rank - 5
     uint256 private constant DPoolPercents = 20;
     uint256 private constant CDPoolPercents = 40;
     uint256 private constant DDPoolPercents = 40;
     uint256 private constant GDPoolPercents = 40;
     uint256 private rewardingMultiple = 20000;   // 2x // if level >1 then 3x
     
    uint256[7] private balDown = [10e22, 30e22, 100e22, 500e22, 1000e22,1500e22,2000e22];
    uint256[7] private balDownRate = [5000, 5000, 5000, 5000, 6000,7000,8000]; 
    uint256[7] private balRecover = [10e22, 30e22, 100e22, 500e22, 1000e22,1500e22, 2000e22];
    mapping(uint256=>bool) public balStatus; // bal=>status

    address[1] public feeReceivers;
    address public ContractAddress;
    address public defaultRefer;
    address public receivers;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
     uint256 public lastfreezetime;
     uint256 public directorPool;
      uint256 public CDPool;
      uint256 public DDPool;
      uint256 public GDPool;
     
    mapping(uint256=>address[]) public dayUsers;
    
     address[] public directorUsers;
     address[] public CDUsers;
     address[] public DDUsers;
     address[] public GDUsers;


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
        uint256 totalDepositbeforeclaimed;
        uint256 teamNum;
        uint256 directnum;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalRevenue;
        uint256 totalRevenueFinal;
        bool isactive;   
    }

    struct UserInfoClaim {  
        uint256 acheived;
        uint256 currentdays;
        
    }
 
      struct UserInfoTeamBuss {  
        uint256 totalTeam;
        uint256 maxTeamA;  //a
        uint256 maxTeamB;  //b
        uint256 maxTeamc;  //c
        uint256 maxusernumberA; 
    }

       
     mapping(address=>UserInfo) public userInfo;
     mapping(address=>UserInfoClaim) public userInfoClaim;
     mapping(address=>UserInfoTeamBuss) public userInfoTeamBuss;
   
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    struct RewardInfo{
       
        uint256 statics;
        uint256 directs;
        uint256 crown;
        uint256 diamond;
        uint256 global;          
        uint256 split;
        uint256 splitDebt;
    }

     struct RewardInfoPool{
        uint256 director;
        uint256 CD;
        uint256 DD;
        uint256 GD;
        
    }

    mapping(address=>RewardInfo) public rewardInfo;
    mapping(address=>RewardInfoPool) public rewardInfoPool;
    bool public isFreezeReward;
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositByActivationFund(address user, uint256 amount);
    event TransferByActivation(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);
    event claims(address user, uint256 reward , uint256 amount );
    constructor(address _usdtaddr)   {
        USDT = IERC20(_usdtaddr);
       
          
          feeReceivers[0] = address(0xee7879b951c94691D169e44B1cd1E1d3c0B51510);   //// DEvelopment Fund
         startTime = block.timestamp;
         lastDistribute = block.timestamp;
         defaultRefer = msg.sender;
         receivers = msg.sender;
    }

    function register(address _referral) external {
        require(userInfo[_referral].totalDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.start = block.timestamp;
        totalUser = totalUser.add(1);
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
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
                _updateLevel(upline);
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

     function _updateLevel(address _user) private {
        UserInfo storage user = userInfo[_user];
         updateUserTeamBusscurrent(_user);
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){
            user.level = levelNow;
              if(levelNow == 2){        
                directorUsers.push(_user);
            }
              if(levelNow == 3){        
                CDUsers.push(_user);
            }
             if(levelNow == 4){        
                DDUsers.push(_user);
            }
            if(levelNow == 5){         
                GDUsers.push(_user);
            }
        }
    }

    function _calLevelNow(address _user) private view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.maxDeposit;
        uint256 totaldirectnum  = user.directnum;
         uint256 totaldirectdepositnum  = user.maxDirectDeposit;
        uint256 levelNow;
        
        if(total >= 500e18){
            (uint256 maxTeam, uint256 otherTeam,uint256 othermaxTeam) = checkteamconditions(_user);  // a //c ///b
               
            if(total >= 2000e18 && totaldirectnum>=10 && totaldirectdepositnum>=5000e18   && user.teamNum >= 250 &&   otherTeam  + othermaxTeam + maxTeam >=210000e18       ){
                levelNow = 5;
            }else if(total >= 1000e18 && totaldirectnum>=8 && totaldirectdepositnum>=2000e18 && user.teamNum >= 100 &&  otherTeam  + othermaxTeam + maxTeam >=60000e18    ){
                levelNow = 4;
            }else if(total >= 500e18  && totaldirectnum>=5 && totaldirectdepositnum>=1000e18 && user.teamNum >= 50 &&  otherTeam  + othermaxTeam + maxTeam >=15000e18  ){

                levelNow = 3;
            }
            else if(total >= 250e18 && totaldirectnum>=5  && totaldirectdepositnum>=500e18)
            {
               levelNow = 2;
            }
            else if(totaldirectnum >= 1){
              levelNow = 1;
            }
        }else if(total >= 250e18 && totaldirectnum>=5 && totaldirectdepositnum>=500e18){
            levelNow = 2;
        }else if(totaldirectnum >= 1){
            levelNow = 1;
        }

        return levelNow;
    }

  

      function updateUserTeamBusscurrent(address _user) private {

        UserInfoTeamBuss storage userteaminfo = userInfoTeamBuss[_user];
        uint256 totalTeam;
        uint256 maxTeam;  //a
        uint256 othermaxTeam;  //b
        uint256 otherTeam;  //c
        uint256 maxusernumber; 
       
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
            uint256  userTotalTeam  = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);
            totalTeam = totalTeam.add(userTotalTeam);
            if(userTotalTeam > maxTeam){
                maxTeam = userTotalTeam;
                maxusernumber = i;
            }
          
        }
         for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
             if(i!=maxusernumber){
           uint256   userTotalTeam = userInfo[teamUsers[_user][0][i]].teamTotalDeposit.add(userInfo[teamUsers[_user][0][i]].totalDeposit);       
              if(userTotalTeam > othermaxTeam){
                othermaxTeam = userTotalTeam;
            }
         }
            
           
        }
          otherTeam = totalTeam.sub(maxTeam);
          otherTeam = otherTeam.sub(othermaxTeam);
         userteaminfo.totalTeam = totalTeam;
         userteaminfo.maxTeamA = maxTeam;
         userteaminfo.maxTeamB = othermaxTeam;
         userteaminfo.maxTeamc = otherTeam;
         userteaminfo.maxusernumberA = maxusernumber;
         
      }

    function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256 ){
       
        uint256 maxTeam;  //a
        uint256 othermaxTeam;  //b
        uint256 otherTeam;  //c
        
         maxTeam =  userInfoTeamBuss[_user].maxTeamA;
         othermaxTeam =  userInfoTeamBuss[_user].maxTeamB;
         otherTeam =  userInfoTeamBuss[_user].maxTeamc;
        
          return(maxTeam, otherTeam, othermaxTeam);
    }
   function checkteamconditions(address _user) private view returns(uint256, uint256, uint256 ) {
              
                uint256 maxTeam;  //a
        uint256 othermaxTeam;  //b
        uint256 otherTeam;  //c
       uint256 usercurrentlevel;
          usercurrentlevel = userInfo[_user].level;
          maxTeam =  userInfoTeamBuss[_user].maxTeamA;
          othermaxTeam =  userInfoTeamBuss[_user].maxTeamB;
          otherTeam =  userInfoTeamBuss[_user].maxTeamc;
        
                if(usercurrentlevel==2)
                {
                   if(maxTeam>=5000e18)
                   {
                       maxTeam = 5000e18;
                   }
                   if(othermaxTeam>=5000e18)
                   {
                       othermaxTeam = 5000e18;
                   }
                }
               if(usercurrentlevel==3)
                {if(maxTeam>=20000e18)
                   {
                       maxTeam = 20000e18;
                   }
                   if(othermaxTeam>=20000e18)
                   {
                       othermaxTeam = 20000e18;
                   }            

                }
                if(usercurrentlevel==4)
                {
                    if(maxTeam>=70000e18)
                   {
                       maxTeam = 70000e18;
                   }
                   if(othermaxTeam>=70000e18)
                   {
                       othermaxTeam = 70000e18;
                   }              
                }
          return(maxTeam, otherTeam, othermaxTeam);
              
              
   }

       
    function deposit(uint256 _amount) external {
        USDT.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function _deposit(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        UserInfoClaim storage userclaim = userInfoClaim[_user];
        
        require(user.referrer != address(0), "register first");
        require(_amount >= minDeposit, "less than min");
        require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");
        
        depositors.push(_user); 
        
        user.totalDepositbeforeclaimed = user.totalDepositbeforeclaimed.add(_amount);
        user.isactive = true;
                 
        uint256 currorder=  orderInfos[_user].length;

        if(userclaim.acheived == 0  && currorder ==0)
        {  
            if(user.maxDeposit == 0){
               user.maxDeposit = _amount; 
              _updatedirectNum(_user);
            }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
            }  

           userclaim.acheived = block.timestamp;
           user.totalDeposit = user.totalDeposit.add(user.totalDepositbeforeclaimed);
           user.totalDepositbeforeclaimed = 0;
          
           uint256 addFreeze = (orderInfos[_user].length.div(1)).mul(timeStep);
           if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
           }
           uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
           userclaim.currentdays = unfreezeTime;
           orderInfos[_user].push(OrderInfo(
            _amount, 
            block.timestamp, 
            unfreezeTime,
            false
          ));
            _distributeDeposit(_amount);     
           _updateReferInfo(msg.sender, _amount);
           _updatemaxdirectdepositInfo(msg.sender, _amount);
           _updateLevel(msg.sender);
           updateUserTeamBusscurrent(user.referrer);
          _distributedepositreward(msg.sender, _amount);


        }
         
        if(userclaim.acheived == 0  && currorder>0)
        {  
             if(user.maxDeposit < _amount){
                user.maxDeposit = _amount;
              }  

           userclaim.acheived = block.timestamp;
           user.totalDeposit = user.totalDeposit.add(user.totalDepositbeforeclaimed);
           user.totalDepositbeforeclaimed = 0;
           _updateReferInfo(msg.sender, _amount);
           _updatemaxdirectdepositInfo(msg.sender, _amount);
           _updateLevel(msg.sender);
           updateUserTeamBusscurrent(user.referrer);
           _distributedepositreward(msg.sender, _amount);

        }

         distributePoolRewards();
       
        uint256 bal = USDT.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }
       function checkusermultiplerewardingstage(address _user) private {
              UserInfo storage user = userInfo[_user];  
              UserInfoClaim storage userclaim = userInfoClaim[_user];
                uint256 _rewarding = _calCurRewardingMultiple(_user);
               if(user.totalRevenue >= user.totalDeposit.mul(_rewarding).div(baseDivider)){
                   user.totalRevenueFinal = user.totalRevenueFinal.add(user.totalRevenue);
                   user.isactive = false;
                   user.totalDeposit=0;
                   user.totalRevenue =  0;
                   userclaim.acheived = 0;
               }

       }

       function _calCurRewardingMultiple(address _user) private view returns(uint256) {
        uint256 rewarding = rewardingMultiple;
        if( userInfo[_user].level > 1) {
          rewarding = 30000;    // now 3x capping
        }
        return rewarding;
       }


    function claimReward() public {
          checkusermultiplerewardingstage(msg.sender);  
         UserInfo storage user = userInfo[msg.sender];  
         UserInfoClaim storage userclaim = userInfoClaim[msg.sender];
        
        require(user.isactive == true  , "inActive Account");
        
        uint256 _rewarding = _calCurRewardingMultiple(msg.sender);
        uint256 initialamt ;
       
           
     if(user.totalDeposit>0){

          require(user.totalRevenue < user.totalDeposit.mul(_rewarding).div(baseDivider), "cannot claim more than 3x, update level");
        
        if(block.timestamp > userclaim.currentdays)
        {

           for(uint256 i = 0; i < orderInfos[msg.sender].length; i++){
                 OrderInfo storage order = orderInfos[msg.sender][i];
                     if(block.timestamp > order.unfreeze  && order.isUnfreezed == false ){
                   order.isUnfreezed = true;
       
                  uint256 interest = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);    
                     
         if(interest > 0 && user.isactive) 
          {
            if(user.totalRevenue.add(interest) > user.totalDeposit.mul(_rewarding).div(baseDivider)) 
            {
                interest = (user.totalDeposit.mul(_rewarding).div(baseDivider)).sub(user.totalRevenue);
            } 
                    initialamt = order.amount;  
            
                    if(isFreezeReward){
                         if(user.totalDeposit > user.totalRevenue){
                        uint256 leftCapital = user.totalDeposit.sub(user.totalRevenue);
                        if(interest > leftCapital){
                            interest = leftCapital;
                        }
                       }else{
                        interest = 0;
                       }
                   }
          
              

            uint256 temp = interest;   
            rewardInfo[msg.sender].statics = rewardInfo[msg.sender].statics.add(temp);
            user.totalRevenue = user.totalRevenue.add(temp);
          
             
           uint256 addFreeze = (orderInfos[msg.sender].length.div(1)).mul(timeStep);
           if(addFreeze > maxAddFreeze){
             addFreeze = maxAddFreeze;
           }

           uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
           userclaim.currentdays = unfreezeTime;
          

          uint256 nextamt = user.totalDeposit;
           if(user.totalDepositbeforeclaimed>0){

                if(user.totalDeposit<maxDeposit){
                    uint256 availbal= maxDeposit.sub(user.totalDeposit);
                        if(user.totalDepositbeforeclaimed>=availbal){
                           nextamt = nextamt.add(availbal);
                           user.totalDepositbeforeclaimed = user.totalDepositbeforeclaimed.sub(availbal);
                             _updateReferInfo(msg.sender, availbal);
                             _updatemaxdirectdepositInfo(msg.sender, availbal);
                                _distributedepositreward(msg.sender, availbal);
                        }else{
                                       nextamt = nextamt.add(user.totalDepositbeforeclaimed);                      
                                      _updateReferInfo(msg.sender,user.totalDepositbeforeclaimed);
                                     _updatemaxdirectdepositInfo(msg.sender, user.totalDepositbeforeclaimed);
                                     _distributedepositreward(msg.sender, user.totalDepositbeforeclaimed);
                                      user.totalDepositbeforeclaimed = 0;

                        }
                }
                  
           }

             user.totalDeposit = nextamt;
              _distributeDeposit(nextamt);     
             user.maxDeposit = nextamt;
              if(user.totalDeposit>=maxDeposit){
                   user.maxDeposit = maxDeposit;
              }
                   
            orderInfos[msg.sender].push(OrderInfo(
            nextamt, 
            block.timestamp, 
            unfreezeTime,
            false
          ));
               
              _updateLevel(msg.sender);
              updateUserTeamBusscurrent(user.referrer);
              if(!isFreezeReward){
                   _releaseReward(msg.sender, temp,initialamt);
                   emit claims(msg.sender, temp ,initialamt );
                }
           
            }
 

                     break;
         }
        }  
       
     }
       }
       else{
           user.isactive == false; 
       }
    }
 

 function _releaseReward(address _user, uint256 _amount, uint256 _initialamt) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
          
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){

                bool idstatus = false;
                
                checkusermultiplerewardingstage(upline);
                idstatus = getActiveUpline(upline);

                uint256 newAmount = _amount;
               uint256 newinitialamt = _initialamt;
                if(upline != defaultRefer){       
                    uint256 maxFreezing = getMaxFreezingUpline(upline);
                    if(maxFreezing < newinitialamt){
                         newAmount = maxFreezing.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);  
                    }
                   }
                    RewardInfo storage upRewards = rewardInfo[upline];
                    uint256 reward;
                    uint256 _rewarding = _calCurRewardingMultiple(upline);
       if(userInfo[upline].totalRevenue < userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider) && idstatus==true)
        {
          
                    if(i==0 && idstatus==true){
                     
                        reward = newAmount.mul(directPercents).div(baseDivider);

                       if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) {
                         reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                       }   
                       

                     upRewards.directs = upRewards.directs.add(reward);                       
                     userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);

               }else if(i>0 && i<5 && idstatus==true && userInfo[upline].level > 2){
                   
                      reward = newAmount.mul(crowndirectorPercents[i - 1]).div(baseDivider);
                       if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) {
                         reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                       } 
                        upRewards.crown = upRewards.crown.add(reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                  
                }       
                 else if(userInfo[upline].level > 3 && i>4 && i >10 && idstatus==true){
                            reward = newAmount.mul(diamonddirectorPercents[i - 5]).div(baseDivider);
                             if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) {
                              reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                              } 
                             upRewards.diamond = upRewards.diamond.add(reward);
                             userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        }
                        else if(userInfo[upline].level > 4 && i >=10 && idstatus==true){
                            reward = newAmount.mul(globaldirectorPercents[i - 10]).div(baseDivider);
                             if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) {
                              reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                               } 
                            upRewards.global = upRewards.global.add(reward);
                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                        }
               } 

            

                if(upline == defaultRefer) break;
              
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }


    function depositByActivationFund(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(_amount <= maxDepositActivation , "less before ");     
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient amt");
        USDT.transferFrom(msg.sender, address(this), _amount);
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
      
        _deposit(msg.sender, SafeMath.mul(_amount,2));
        emit DepositByActivationFund(msg.sender, SafeMath.mul(_amount,2));
    }

    function transferByActivation(address _receiver, uint256 _amount) external {
        require(_amount >= minDepositActivation && _amount.mod(minDepositActivation) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferByActivation(msg.sender, _receiver, _amount);
    }

   

    function withdraw() external {
        distributePoolRewards();
        (uint256 staticReward, uint256 staticSplit) = _calCurStaticRewards(msg.sender);
        uint256 splitAmt = staticSplit;
        uint256 withdrawable = staticReward;

        (uint256 dynamicReward, uint256 dynamicSplit) = _calCurDynamicRewards(msg.sender);
        withdrawable = withdrawable.add(dynamicReward);
        splitAmt = splitAmt.add(dynamicSplit);
        
        RewardInfo storage userRewards = rewardInfo[msg.sender];
        RewardInfoPool storage userRewardsf = rewardInfoPool[msg.sender];
        UserInfo storage user = userInfo[msg.sender];

        userRewards.split = userRewards.split.add(splitAmt);
        userRewards.statics = 0;
        userRewards.directs = 0;
        userRewards.crown = 0;
        userRewards.diamond = 0;
        userRewards.global = 0;
        userRewardsf.GD = 0;  
        userRewardsf.CD = 0;
        userRewardsf.DD = 0; 
        userRewardsf.director = 0; 
        withdrawable = withdrawable.add(user.totalDepositbeforeclaimed);
        user.totalDepositbeforeclaimed = 0;
        uint256 bal = USDT.balanceOf(address(this));
        _setFreezeReward(bal);
         
         USDT.transfer(msg.sender, withdrawable);
        emit Withdraw(msg.sender, withdrawable);

    }



    function getMaxFreezingUpline(address _user) public view returns(uint256) {
        uint256 maxFreezing;
        UserInfo storage user = userInfo[_user];
        maxFreezing =   user.maxDeposit;
        return maxFreezing;
    }

     function getActiveUpline(address _user) public view returns(bool) {
        bool currentstatus = false;  
        UserInfo storage user = userInfo[_user];
        if(user.isactive==true){
           UserInfoClaim storage userclaim = userInfoClaim[_user];
          if(block.timestamp < userclaim.currentdays){
             currentstatus =  true;
           }
        }
        
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
        RewardInfoPool storage userRewardsf = rewardInfoPool[_user];
        uint256 totalRewards = userRewards.directs.add(userRewards.crown).add(userRewards.diamond).add(userRewards.global);     
       totalRewards = totalRewards.add(userRewardsf.GD.add(userRewardsf.director).add(userRewardsf.DD).add(userRewardsf.CD));
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
   

   
  function _distributedepositreward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer; 
        uint256 level_sum =  _amount.mul(initialrewardsum).div(baseDivider);     
        for(uint256 i = 0; i < initialreward.length; i++){
            if(upline != address(0)){
                bool idstatus = false;
                checkusermultiplerewardingstage(upline);
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
              

              if(i==0 && idstatus==true && userInfo[upline].directnum >=i+1){
                        
                 uint256 _rewarding = _calCurRewardingMultiple(upline);
                if(userInfo[upline].totalRevenue < userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider))
                {

                 reward = newAmount.mul(initialreward[i]).div(baseDivider);
                     
                if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) {
                  reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                 }  
                     uint256 splitAmt = reward.mul(freezeIncomePercents).div(baseDivider);
                     upRewards.split = upRewards.split.add(splitAmt);                      
                     userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);     
                     USDT.transfer(upline, reward.sub(splitAmt));                                           
                     level_sum = level_sum.sub(reward);
             
                }
            }else if(i>0 && idstatus==true && userInfo[upline].directnum >=i+1){
               
                uint256 _rewarding = _calCurRewardingMultiple(upline);
                 if(userInfo[upline].totalRevenue < userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider))
                     {
                     reward = newAmount.mul(initialreward[i]).div(baseDivider);
                    if(userInfo[upline].totalRevenue.add(reward) > userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)) 
                    {
                    reward = (userInfo[upline].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[upline].totalRevenue);
                    }  


                     uint256 splitAmt = reward.mul(freezeIncomePercents).div(baseDivider);
                     upRewards.split = upRewards.split.add(splitAmt);                      
                     userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);     
                     USDT.transfer(upline, reward.sub(splitAmt));                                           
                     level_sum = level_sum.sub(reward);
                     }           
            }
                if(upline == defaultRefer) break;
              
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
        if(level_sum > 0){
               rewardInfo[defaultRefer].directs = rewardInfo[defaultRefer].directs.add(level_sum);                  
        }
    }
    



    function _balActived(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(_bal >= balDown[i - 1]){
                balStatus[balDown[i - 1]] = true;
                break;
            }
        }
    }
 function _distributeDeposit(uint256 _amount) private {
       
        USDT.transfer(feeReceivers[0], _amount.mul(feePercents).div(baseDivider));
       uint256 director = _amount.mul(DPoolPercents).div(baseDivider);
        directorPool = directorPool.add(director); 
        uint256 cd = _amount.mul(CDPoolPercents).div(baseDivider);
        CDPool = CDPool.add(cd); 
        uint256 dd = _amount.mul(DDPoolPercents).div(baseDivider);
        DDPool = DDPool.add(dd); 
        uint256 gd = _amount.mul(GDPoolPercents).div(baseDivider);
        GDPool = GDPool.add(gd); 
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep)){ 

        if(!isFreezeReward){
           _distributeDirectorPool(); 
           _distributeCDPool(); 
           _distributeDDPool(); 
           _distributeGDPool();
       }
       else{
           directorPool = 0;
           CDPool = 0;
           DDPool = 0;
           GDPool = 0;
       }
          
           
            lastDistribute = block.timestamp;
        }
    }
      function _distributeDirectorPool() private {
        uint256 directorCount;
        for(uint256 i = 0; i < directorUsers.length; i++){
           
            if(userInfo[directorUsers[i]].level == 2 && userInfo[directorUsers[i]].isactive == true){
                directorCount = directorCount.add(1);
            }
        }
        if(directorCount > 0){
            uint256 reward = directorPool.div(directorCount);
            uint256 totalReward;
            for(uint256 i = 0; i < directorUsers.length; i++){
                if(userInfo[directorUsers[i]].level == 2 && userInfo[directorUsers[i]].isactive == true){
                      uint256 _rewarding = _calCurRewardingMultiple(directorUsers[i]);
                     if(userInfo[directorUsers[i]].totalRevenue < userInfo[directorUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                      {
                         if(userInfo[directorUsers[i]].totalRevenue.add(reward) > userInfo[directorUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                               reward = (userInfo[directorUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[directorUsers[i]].totalRevenue);
                           }   
                
                          rewardInfoPool[directorUsers[i]].director = rewardInfoPool[directorUsers[i]].director.add(reward);
                          userInfo[directorUsers[i]].totalRevenue = userInfo[directorUsers[i]].totalRevenue.add(reward);
                          totalReward = totalReward.add(reward);
                      }

                   
                }
            }
            if(directorPool > totalReward){
                directorPool = directorPool.sub(totalReward);
            }else{
                directorPool = 0;
            }
        }
    }



 function _distributeCDPool() private {
        uint256 cdCount;
        for(uint256 i = 0; i < CDUsers.length; i++){
            
            if(userInfo[CDUsers[i]].level == 3 && userInfo[CDUsers[i]].isactive == true){
                cdCount = cdCount.add(1);
            }
        }
        if(cdCount > 0){
            uint256 reward = CDPool.div(cdCount);
            uint256 totalReward;
            for(uint256 i = 0; i < CDUsers.length; i++){
                if(userInfo[CDUsers[i]].level == 3 && userInfo[CDUsers[i]].isactive == true){
                       uint256 _rewarding = _calCurRewardingMultiple(CDUsers[i]);
                       if(userInfo[CDUsers[i]].totalRevenue < userInfo[CDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                        {
                             if(userInfo[CDUsers[i]].totalRevenue.add(reward) > userInfo[CDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                               reward = (userInfo[CDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[CDUsers[i]].totalRevenue);
                           }

                           rewardInfoPool[CDUsers[i]].CD = rewardInfoPool[CDUsers[i]].CD.add(reward);
                           userInfo[CDUsers[i]].totalRevenue = userInfo[CDUsers[i]].totalRevenue.add(reward);
                            totalReward = totalReward.add(reward);
                      }

                  
                }
            }
            if(CDPool > totalReward){
                CDPool = CDPool.sub(totalReward);
            }else{
                CDPool = 0;
            }
        }
    }
       function _distributeDDPool() private {
        uint256 ddCount;
        for(uint256 i = 0; i < DDUsers.length; i++){
           
            if(userInfo[DDUsers[i]].level == 4 && userInfo[DDUsers[i]].isactive == true){
                ddCount = ddCount.add(1);
            }
        }
        if(ddCount > 0){
            uint256 reward = DDPool.div(ddCount);
            uint256 totalReward;
            for(uint256 i = 0; i < DDUsers.length; i++){
                if(userInfo[DDUsers[i]].level == 4 && userInfo[DDUsers[i]].isactive == true){
                      uint256 _rewarding = _calCurRewardingMultiple(DDUsers[i]);
                       if(userInfo[DDUsers[i]].totalRevenue < userInfo[DDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                      {  
                           if(userInfo[DDUsers[i]].totalRevenue.add(reward) > userInfo[DDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                               reward = (userInfo[DDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[DDUsers[i]].totalRevenue);
                           }
                          rewardInfoPool[DDUsers[i]].DD = rewardInfoPool[DDUsers[i]].DD.add(reward);
                         userInfo[DDUsers[i]].totalRevenue = userInfo[DDUsers[i]].totalRevenue.add(reward);
                         totalReward = totalReward.add(reward);
                      }
                  
                }
            }
            if(DDPool > totalReward){
                DDPool = DDPool.sub(totalReward);
            }else{
                DDPool = 0;
            }
        }
    }
 
        function _distributeGDPool() private {
        uint256 gdCount;
        for(uint256 i = 0; i < GDUsers.length; i++){
             
            if(userInfo[GDUsers[i]].level == 5 && userInfo[GDUsers[i]].isactive == true){
                gdCount = gdCount.add(1);
            }
        }
        if(gdCount > 0){
            uint256 reward = GDPool.div(gdCount);
            uint256 totalReward;
            for(uint256 i = 0; i < GDUsers.length; i++){
                if(userInfo[GDUsers[i]].level == 5 && userInfo[GDUsers[i]].isactive == true){

                    uint256 _rewarding = _calCurRewardingMultiple(GDUsers[i]);
                       if(userInfo[GDUsers[i]].totalRevenue < userInfo[GDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider))
                      {  
                           if(userInfo[GDUsers[i]].totalRevenue.add(reward) > userInfo[GDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)) {
                               reward = (userInfo[GDUsers[i]].totalDeposit.mul(_rewarding).div(baseDivider)).sub(userInfo[GDUsers[i]].totalRevenue);
                           }
                                rewardInfoPool[GDUsers[i]].GD = rewardInfoPool[GDUsers[i]].GD.add(reward);
                                userInfo[GDUsers[i]].totalRevenue = userInfo[GDUsers[i]].totalRevenue.add(reward);
                                totalReward = totalReward.add(reward);
                      }
                    
                }
            }
            if(GDPool > totalReward){
                GDPool = GDPool.sub(totalReward);
            }else{
                GDPool = 0;
            }
        }
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

    function getdirectorusersLength() external view returns(uint256) {
        return directorUsers.length;
    }

    function getCDusersLength() external view returns(uint256) {
        return CDUsers.length;
    }

    function getDDusersLength() external view returns(uint256) {
        return DDUsers.length;
    }

   function getGDusersLength() external view returns(uint256) {
        return GDUsers.length;
    }
   
    
    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(balStatus[balDown[i - 1]]){
                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);
                if(_bal < balDown[i - 1].sub(maxDown)){
                    isFreezeReward = true;       
                    ContractAddress=defaultRefer;
                }else if(isFreezeReward && _bal >= balRecover[i - 1]){
                    isFreezeReward = false;
                }
                break;
            }
        }
    }
 
}