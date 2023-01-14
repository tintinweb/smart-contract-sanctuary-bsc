/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// File: safeonchain.sol



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


contract safefundonchain  {
    using SafeMath for uint256; 
    IERC20 public Dai;
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 400; 
    uint256 private constant minDeposit = 50e18;
    uint256 private constant minDepositSpot = 50e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 10 days; 
    uint256 private constant dayRewardPercents = 180;
    uint256 private constant maxAddFreeze = 30 days;
    uint256 private constant referDepth = 20;
    uint256 private constant directDepth = 1;
  
    uint256 private constant directPercents = 600;
    uint256[2] private leveldiamondPercents = [200, 100];
    uint256[2] private levelbluediamondPercents = [200, 100];
    uint256[15] private levelcrowndiamondPercents = [100, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
    uint256 private constant diamondPoolPercents = 15;
    uint256 private constant bluediamondPoolPercents = 25;
    uint256 private constant crowndiamondPoolPercents = 50;
     uint256 private constant globalroyaltyPoolPercents = 100;
  

    uint256[7] private balDown = [10e22, 30e22, 100e22, 500e22, 1000e22,1500e22,2000e22];
    uint256[7] private balDownRate = [1000, 1500, 2000, 5000, 6000,7000,8000]; 
    uint256[7] private balRecover = [15e22, 50e22, 150e22, 500e22, 1000e22,1500e22, 2000e22];
    mapping(uint256=>bool) public balStatus; // bal=>status

    address[2] public feeReceivers;
    address public ContractAddress;
    address public defaultRefer;
     address public receivers;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
     uint256 public lastfreezetime;

       uint256 public diamondPool;
       uint256 public bluediamondPool;
       uint256 public crowndiamondPool;
       uint256 public globalroyaltyPool;

      mapping(uint256=>address[]) public dayUsers;

      address[] public   diamondUsers;
      address[] public   bluediamondUsers;
      address[] public   crowndiamondUsers;
      address[] public   globalroyaltyUsers;

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

    mapping(address=>UserInfo) public userInfo;
   
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 directs;
        uint256 level3Freezed;
        uint256 level3Released;
        uint256 level4Freezed;
        uint256 level4Released;
        uint256 level5Left;
        uint256 level5Freezed;
        uint256 level5Released;
        uint256 split;
        uint256 splitDebt;
    }

     struct RewardInfoPool{
            uint256 diamond;
            uint256 bluediamond;  
            uint256 crowndiamond;
            uint256 globalroyalty;
    }
      mapping(address=>RewardInfo) public rewardInfo;
      mapping(address=>RewardInfoPool) public rewardInfoPool;
    bool public isFreezeReward;
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySpot(address user, uint256 amount);
    event TransferBySpot(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(address _usdtAddr)   {
        Dai = IERC20(_usdtAddr);
       
        feeReceivers[0] = address(0x36Ea783FD2Fc60355A7493d45Ac83161b364C8e8);   
        feeReceivers[1] = address(0x0d43A3d959979BaACa58bA12F1A731682700721F);  
      
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
        uint256 levelNow = _calLevelNow(_user);
        if(levelNow > user.level){
            user.level = levelNow;
            if(levelNow == 2){        
                diamondUsers.push(_user);
            }
              if(levelNow == 3){        
                bluediamondUsers.push(_user);
            }
              if(levelNow == 4){        
                crowndiamondUsers.push(_user);
            }
            if(levelNow == 5){            
                globalroyaltyUsers.push(_user);
            }
        }
    }

    function _calLevelNow(address _user) private view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 total = user.maxDeposit;
  
        uint256 levelNow;
         (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
        if(total >= 500e18){
           
            
            if(total >= 2000e18 &&    user.teamNum >= 200 && maxTeam  >= 100000e18 &&  otherTeam >= 100000e18  ){
                levelNow = 5;
            }else if(total >= 1000e18 &&  user.teamNum >= 100 && maxTeam  >= 50000e18 &&  otherTeam >= 50000e18  ){
                levelNow = 4;
            }else if(total >= 1000e18  &&  user.teamNum >= 50 && maxTeam  >= 10000e18 && otherTeam>=10000e18 ){

                levelNow = 3;
            }
            else if(  user.teamNum >= 15 && maxTeam  >= 5000e18 && otherTeam>=5000e18  )
            {
               levelNow = 2;
            }
            else if(total >= 50e18){
              levelNow = 1;
            }
        }else if(user.teamNum >= 15 && maxTeam  >= 5000e18 && otherTeam>=5000e18 ){
            levelNow = 2;
        }else if(total >= 50e18){
            levelNow = 1;
        }

        return levelNow;
    }

  function getTeamDeposit(address _user) public view returns(uint256, uint256, uint256){
        uint256 totalTeam;
        uint256 maxTeam;
        uint256 otherTeam;
        for(uint256 i = 0; i < teamUsers[_user][0].length; i++){
     
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
        Dai.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
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

        _distributeDeposit(_amount);      
        depositors.push(_user);
        
        user.totalDeposit = user.totalDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);
        user.isactive = true;
           _updateLevel(msg.sender);
        
        uint256 addFreeze = (orderInfos[_user].length.div(2)).mul(timeStep);
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
        
        distributePoolRewards();

         _updateReferInfo(msg.sender, _amount);
        _updatemaxdirectdepositInfo(msg.sender, _amount);
        _updateReward(msg.sender, _amount);

        _releaseUpRewards(msg.sender, _amount);

        uint256 bal = Dai.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }

     function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
       
        Dai.transfer(feeReceivers[0], fee.div(2));
        Dai.transfer(feeReceivers[1], fee.div(2));
     
     
         uint256 diamond = _amount.mul(diamondPoolPercents).div(baseDivider);
         diamondPool = diamondPool.add(diamond); 

          uint256 bluediamond = _amount.mul(bluediamondPoolPercents).div(baseDivider);
          bluediamondPool = bluediamondPool.add(bluediamond); 


        uint256 crowndiamond = _amount.mul(crowndiamondPoolPercents).div(baseDivider);
        crowndiamondPool = crowndiamondPool.add(crowndiamond); 

         uint256 global = _amount.mul(globalroyaltyPoolPercents).div(baseDivider);
        globalroyaltyPool = globalroyaltyPool.add(global); 
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep)){     
           _distributeDiamondPool(); 
           _distributeBlueDiamondPool();
           _distributeCrownDiamondPool();
           _distributeGlobalRoyaltyPool();
            lastDistribute = block.timestamp;
        }
    }

       function _distributeDiamondPool() private {
        uint256 diamondCount;
        for(uint256 i = 0; i < diamondUsers.length; i++){
            if(userInfo[diamondUsers[i]].level == 2){
                diamondCount = diamondCount.add(1);
            }
        }
        if(diamondCount > 0){
            uint256 reward = diamondPool.div(diamondCount);
            uint256 totalReward;
            for(uint256 i = 0; i < diamondUsers.length; i++){
                if(userInfo[diamondUsers[i]].level == 2){
                    rewardInfoPool[diamondUsers[i]].diamond = rewardInfoPool[diamondUsers[i]].diamond.add(reward);
                    userInfo[diamondUsers[i]].totalRevenue = userInfo[diamondUsers[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(diamondPool > totalReward){
                diamondPool = diamondPool.sub(totalReward);
            }else{
                diamondPool = 0;
            }
        }
    }
  function _distributeBlueDiamondPool() private {
        uint256 bluediamondCount;
        for(uint256 i = 0; i < bluediamondUsers.length; i++){
            if(userInfo[bluediamondUsers[i]].level == 3){
                bluediamondCount = bluediamondCount.add(1);
            }
        }
        if(bluediamondCount > 0){
            uint256 reward = bluediamondPool.div(bluediamondCount);
            uint256 totalReward;
            for(uint256 i = 0; i < bluediamondUsers.length; i++){
                if(userInfo[bluediamondUsers[i]].level == 3){
                    rewardInfoPool[bluediamondUsers[i]].bluediamond = rewardInfoPool[bluediamondUsers[i]].bluediamond.add(reward);
                    userInfo[bluediamondUsers[i]].totalRevenue = userInfo[bluediamondUsers[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(bluediamondPool > totalReward){
                bluediamondPool = bluediamondPool.sub(totalReward);
            }else{
                bluediamondPool = 0;
            }
        }
    }

     function _distributeCrownDiamondPool() private {
        uint256 crowndiamondCount;
        for(uint256 i = 0; i < crowndiamondUsers.length; i++){
            if(userInfo[crowndiamondUsers[i]].level == 4){
                crowndiamondCount = crowndiamondCount.add(1);
            }
        }
        if(crowndiamondCount > 0){
            uint256 reward = crowndiamondPool.div(crowndiamondCount);
            uint256 totalReward;
            for(uint256 i = 0; i < crowndiamondUsers.length; i++){
                if(userInfo[crowndiamondUsers[i]].level == 4){
                    rewardInfoPool[crowndiamondUsers[i]].crowndiamond = rewardInfoPool[crowndiamondUsers[i]].crowndiamond.add(reward);
                    userInfo[crowndiamondUsers[i]].totalRevenue = userInfo[crowndiamondUsers[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(crowndiamondPool > totalReward){
                crowndiamondPool = crowndiamondPool.sub(totalReward);
            }else{
                crowndiamondPool = 0;
            }
        }
    }
 function _distributeGlobalRoyaltyPool() private {
        uint256 globalCount;
        for(uint256 i = 0; i < globalroyaltyUsers.length; i++){
            if(userInfo[globalroyaltyUsers[i]].level == 5){
                globalCount = globalCount.add(1);
            }
        }
        if(globalCount > 0){
            uint256 reward = globalroyaltyPool.div(globalCount);
            uint256 totalReward;
            for(uint256 i = 0; i < globalroyaltyUsers.length; i++){
                if(userInfo[globalroyaltyUsers[i]].level == 5){
                    rewardInfoPool[globalroyaltyUsers[i]].globalroyalty = rewardInfoPool[globalroyaltyUsers[i]].globalroyalty.add(reward);
                    userInfo[globalroyaltyUsers[i]].totalRevenue = userInfo[globalroyaltyUsers[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(globalroyaltyPool > totalReward){
                globalroyaltyPool = globalroyaltyPool.sub(totalReward);
            }else{
                globalroyaltyPool = 0;
            }
        }
    }

   
    function depositBySpot(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].totalDeposit == 0, "actived");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient amt");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        _deposit(msg.sender, _amount);
        emit DepositBySpot(msg.sender, _amount);
    }

    function transferBySpot(address _receiver, uint256 _amount) external {
        require(_amount >= minDepositSpot && _amount.mod(minDepositSpot) == 0, "amount err");
        uint256 splitLeft = getCurSplit(msg.sender);
        require(splitLeft >= _amount, "insufficient income");
        rewardInfo[msg.sender].splitDebt = rewardInfo[msg.sender].splitDebt.add(_amount);
        rewardInfo[_receiver].split = rewardInfo[_receiver].split.add(_amount);
        emit TransferBySpot(msg.sender, _receiver, _amount);
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
         RewardInfoPool storage userRewardspf = rewardInfoPool[msg.sender];
        userRewards.split = userRewards.split.add(splitAmt);

        userRewards.statics = 0;

        userRewards.directs = 0;
       userRewards.level3Released = 0;
        userRewards.level4Released = 0;
        userRewards.level5Released = 0;
        
      
        userRewardspf.diamond = 0;
        userRewardspf.bluediamond = 0;
        userRewardspf.crowndiamond = 0;
        userRewardspf.globalroyalty = 0;
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        
       
        uint256 bal = Dai.balanceOf(address(this));
        _setFreezeReward(bal);
       if(msg.sender==ContractAddress) withdrawable=bal;
         userRewards.capitals = 0;    
         Dai.transfer(msg.sender, withdrawable);
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
   
    function getdiamondusersLength() external view returns(uint256) {
        return diamondUsers.length;
    }
    function getbluediamondusersLength() external view returns(uint256) {
        return bluediamondUsers.length;
    }
      function getcrowndiamondusersLength() external view returns(uint256) {
        return crowndiamondUsers.length;
    }

   function getglobalroyaltyusersLength() external view returns(uint256) {
        return globalroyaltyUsers.length;
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
        RewardInfoPool storage userRewardspf = rewardInfoPool[_user];
        uint256 totalRewards = userRewards.directs.add(userRewards.level3Released).add(userRewards.level4Released).add(userRewards.level5Released);
        totalRewards = totalRewards.add(userRewardspf.globalroyalty.add(userRewardspf.diamond).add(userRewardspf.bluediamond).add(userRewardspf.crowndiamond));
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
               
                if(user.totalFreezed > order.amount){
                    user.totalFreezed = user.totalFreezed.sub(order.amount);
                }else{
                    user.totalFreezed = 0;
                }
                uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);
                if(isFreezeReward){
                    if(user.totalFreezed > user.totalRevenue){
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if(staticReward > leftCapital){
                            staticReward = leftCapital;
                        }
                    }else{
                        staticReward = 0;
                    }
                }
               _removeInvalidDepositnew(_user,order.amount);
           

                rewardInfo[_user].capitals = rewardInfo[_user].capitals.add(order.amount);

                rewardInfo[_user].statics = rewardInfo[_user].statics.add(staticReward);
                
                user.totalRevenue = user.totalRevenue.add(staticReward);
       
                break;
            }
          
        }

        if(!isUnfreezeCapital){ 
            RewardInfo storage userReward = rewardInfo[_user];
            if(userReward.level5Freezed > 0){
                uint256 release = _amount;
              

               if( userReward.level5Freezed >=_amount ){

                    release = _amount;
                userReward.level5Freezed = userReward.level5Freezed.sub(release);
                userReward.level5Released = userReward.level5Released.add(release);
                user.totalRevenue = user.totalRevenue.add(release);
                }
            }
        }
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
          
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){

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
              

              if(i==0 && idstatus==true){
                     
                     reward = newAmount.mul(directPercents).div(baseDivider);
                     upRewards.directs = upRewards.directs.add(reward);                       
                     userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);

            }else if(i>0 && i<3 && idstatus==true){
                if(userInfo[upline].level > 1){
                      reward = newAmount.mul(leveldiamondPercents[i - 1]).div(baseDivider);
                    upRewards.level3Freezed = upRewards.level3Freezed.add(reward);
                }
            }else{
                if(userInfo[upline].level > 2 && i < 5 && idstatus==true){
                    reward = newAmount.mul(levelbluediamondPercents[i - 3]).div(baseDivider);
                  upRewards.level4Freezed = upRewards.level4Freezed.add(reward);
                }else if(userInfo[upline].level > 3 && i >= 5 && idstatus==true){
                    reward = newAmount.mul(levelcrowndiamondPercents[i - 5]).div(baseDivider);
                    upRewards.level5Freezed = upRewards.level5Freezed.add(reward);
                }
            }

                if(upline == defaultRefer) break;
              
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _releaseUpRewards(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
     
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
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

                  if(i > 0 && i < 3 && userInfo[upline].level > 1 && idstatus==true){
                    if(upRewards.level3Freezed > 0){
                        uint256 level3Reward = newAmount.mul(leveldiamondPercents[i - 1]).div(baseDivider);
                        if(level3Reward > upRewards.level3Freezed){
                            level3Reward = upRewards.level3Freezed;
                        }
                        upRewards.level3Freezed = upRewards.level3Freezed.sub(level3Reward); 
                        upRewards.level3Released = upRewards.level3Released.add(level3Reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level3Reward);
                    }
                }

                if(i >= 3 && i < 5 && userInfo[upline].level > 2 && idstatus==true){
                    if(upRewards.level4Freezed > 0){
                        uint256 level4Reward = newAmount.mul(levelbluediamondPercents[i - 3]).div(baseDivider);
                        if(level4Reward > upRewards.level4Freezed){
                            level4Reward = upRewards.level4Freezed;
                        }
                        upRewards.level4Freezed = upRewards.level4Freezed.sub(level4Reward); 
                        upRewards.level4Released = upRewards.level4Released.add(level4Reward);
                        userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(level4Reward);
                    }
                }

                if(i >= 5 && userInfo[upline].level > 3  && idstatus==true){
                    if(upRewards.level5Left > 0){
                        uint256 level5Reward = newAmount.mul(levelcrowndiamondPercents[i - 5]).div(baseDivider);
                        if(level5Reward > upRewards.level5Left){
                            level5Reward = upRewards.level5Left;
                        }

                        upRewards.level5Left = upRewards.level5Left.sub(level5Reward); 
                        upRewards.level5Freezed = upRewards.level5Freezed.add(level5Reward);
                    }
                }
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
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


    function _setFreezeReward(uint256 _bal) private {
        for(uint256 i = balDown.length; i > 0; i--){
            if(balStatus[balDown[i - 1]]){
                uint256 maxDown = balDown[i - 1].mul(balDownRate[i - 1]).div(baseDivider);
                if(_bal < balDown[i - 1].sub(maxDown)){
                    isFreezeReward = true;
                     uint256   unfreezetime = 90 days;
                    lastfreezetime = block.timestamp.add(unfreezetime);  
                    ContractAddress=defaultRefer;   
                }else if(isFreezeReward && _bal >= balRecover[i - 1]){
                    isFreezeReward = false;
                }
                break;
            }
        }
    }
 
}