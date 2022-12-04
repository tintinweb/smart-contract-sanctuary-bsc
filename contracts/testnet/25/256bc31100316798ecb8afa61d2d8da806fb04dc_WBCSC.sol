/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.8.0;



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

contract WBCSC is Contractable {
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
    uint256 private constant dayRewardPercents = 170;
    uint256 private constant maxAddFreeze = 40 days;
    uint256 private constant referDepth = 20;
    uint256 private constant directDepth = 1;
    uint256 private constant uct = 90 days;
    uint256 private constant directPercents = 500;
    uint256[2] private levelleaderPercents = [200, 300];
    uint256[2] private levelmanagerPercents = [400, 200];
    uint256[15] private levelcoordinatorPercents = [200, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
      uint256 private constant managerPoolPercents = 50;
    uint256 private constant globalcoordinatorPoolPercents = 100;

    uint256[7] private balDown = [10e22, 30e22, 100e22, 500e22, 1000e22,1500e22,2000e22];
    uint256[7] private balDownRate = [1000, 1500, 2000, 5000, 6000,7000,8000]; 
    uint256[7] private balRecover = [15e22, 50e22, 150e22, 500e22, 1000e22,1500e22, 2000e22];
    mapping(uint256=>bool) public balStatus; // bal=>status

    address[1] public feeReceivers;

    address public ContractAddress;
    address public defaultRefer;
    address public receivers;
    uint256 public startTime;
    uint256 public lastDistribute;
    uint256 public totalUser; 
    uint256 public lastfreezetime;

   
    uint256 public managerPool;
    uint256 public globalcoordinatorPool;
    mapping(uint256=>address[]) public dayUsers;
  
     address[] public managerUsers;
     address[] public globalcoordinatorUsers;
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
        uint256 global;
        uint256 manager;
        uint256 split;
        uint256 splitDebt;
    }
    mapping(address=>RewardInfo) public rewardInfo;
    bool public isFreezeReward;
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositByGrowth(address user, uint256 amount);
    event TransferByGrowth(address user, address receiver, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(address _defaultRefer)   
    {
        feeReceivers[0] = address(0x8E5E0289EE6851FDF1f0Ff5861D65258Bc279A67);
        startTime = block.timestamp;
        lastDistribute = block.timestamp;
        defaultRefer = _defaultRefer;
        receivers = _defaultRefer;
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
              if(levelNow == 3){        
                managerUsers.push(_user);
            }
            if(levelNow == 5){
              
                globalcoordinatorUsers.push(_user);
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
            (uint256 maxTeam, uint256 otherTeam, ) = getTeamDeposit(_user);
            
            if(total >= 2000e18 && totaldirectnum>=20 && totaldirectdepositnum>=10000e18   && user.teamNum >= 300 && maxTeam + otherTeam >= 200000e18 &&  otherTeam >= 100000e18  ){
                levelNow = 5;
            }else if(total >= 2000e18 && totaldirectnum>=10 && totaldirectdepositnum>=5000e18 && user.teamNum >= 150 && maxTeam + otherTeam >= 100000e18 &&  otherTeam >= 50000e18  ){
                levelNow = 4;
            }else if(total >= 500e18  && totaldirectnum>=5 && totaldirectdepositnum>=1000e18 && user.teamNum >= 30 && maxTeam + otherTeam >= 10000e18 && otherTeam>=5000e18 ){

                levelNow = 3;
            }
            else if(total >= 200e18 && totaldirectnum>=5  && totaldirectdepositnum>=500e18)
            {
               levelNow = 2;
            }
            else if(totaldirectnum >= 1){
              levelNow = 1;
            }
        }else if(total >= 200e18 && totaldirectnum>=5 && totaldirectdepositnum>=500e18){
            levelNow = 2;
        }else if(totaldirectnum >= 1){
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
        BUSD.transferFrom(msg.sender, address(this), _amount);
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
        
        distributePoolRewards();

         _updateReferInfo(msg.sender, _amount);
        _updatemaxdirectdepositInfo(msg.sender, _amount);
        _updateReward(msg.sender, _amount);

        _releaseUpRewards(msg.sender, _amount);

        uint256 bal = BUSD.balanceOf(address(this));
        _balActived(bal);
        if(isFreezeReward){
            _setFreezeReward(bal);
        }
    }

     function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        BUSD.transfer(feeReceivers[0], fee.div(3));
     
        uint256 manager = _amount.mul(managerPoolPercents).div(baseDivider);
        managerPool = managerPool.add(manager); 
         uint256 coordinator = _amount.mul(globalcoordinatorPoolPercents).div(baseDivider);
        globalcoordinatorPool = globalcoordinatorPool.add(coordinator); 
    }

    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute.add(timeStep)){     
           _distributeManagerPool(); 
           _distributeGlobalPool();
            lastDistribute = block.timestamp;
        }
    }

       function _distributeManagerPool() private {
        uint256 managerCount;
        for(uint256 i = 0; i < managerUsers.length; i++){
            if(userInfo[managerUsers[i]].level == 3){
                managerCount = managerCount.add(1);
            }
        }
        if(managerCount > 0){
            uint256 reward = managerPool.div(managerCount);
            uint256 totalReward;
            for(uint256 i = 0; i < managerUsers.length; i++){
                if(userInfo[managerUsers[i]].level == 3){
                    rewardInfo[managerUsers[i]].manager = rewardInfo[managerUsers[i]].manager.add(reward);
                    userInfo[managerUsers[i]].totalRevenue = userInfo[managerUsers[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(managerPool > totalReward){
                managerPool = managerPool.sub(totalReward);
            }else{
                managerPool = 0;
            }
        }
    }
 
 function _distributeGlobalPool() private {
        uint256 globalCount;
        for(uint256 i = 0; i < globalcoordinatorUsers.length; i++){
            if(userInfo[globalcoordinatorUsers[i]].level == 5){
                globalCount = globalCount.add(1);
            }
        }
        if(globalCount > 0){
            uint256 reward = globalcoordinatorPool.div(globalCount);
            uint256 totalReward;
            for(uint256 i = 0; i < globalcoordinatorUsers.length; i++){
                if(userInfo[globalcoordinatorUsers[i]].level == 5){
                    rewardInfo[globalcoordinatorUsers[i]].global = rewardInfo[globalcoordinatorUsers[i]].global.add(reward);
                    userInfo[globalcoordinatorUsers[i]].totalRevenue = userInfo[globalcoordinatorUsers[i]].totalRevenue.add(reward);
                    totalReward = totalReward.add(reward);
                }
            }
            if(globalcoordinatorPool > totalReward){
                globalcoordinatorPool = globalcoordinatorPool.sub(totalReward);
            }else{
                globalcoordinatorPool = 0;
            }
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

    function withdraw() external {
        distributePoolRewards();
        (uint256 staticReward, uint256 staticSplit) = _calCurStaticRewards(msg.sender);
        uint256 splitAmt = staticSplit;
        uint256 withdrawable = staticReward;

        (uint256 dynamicReward, uint256 dynamicSplit) = _calCurDynamicRewards(msg.sender);
        withdrawable = withdrawable.add(dynamicReward);
        splitAmt = splitAmt.add(dynamicSplit);

        RewardInfo storage userRewards = rewardInfo[msg.sender];
        userRewards.split = userRewards.split.add(splitAmt);

        userRewards.statics = 0;

        userRewards.directs = 0;
       userRewards.level3Released = 0;
        userRewards.level4Released = 0;
        userRewards.level5Released = 0;
        
      
         userRewards.global = 0;
         userRewards.manager = 0;
        
        withdrawable = withdrawable.add(userRewards.capitals);
        userRewards.capitals = 0;
        
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
        uint256 totalRewards = userRewards.directs.add(userRewards.level3Released).add(userRewards.level4Released).add(userRewards.level5Released);
        totalRewards = totalRewards.add(userRewards.global.add(userRewards.manager));
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
                      reward = newAmount.mul(levelleaderPercents[i - 1]).div(baseDivider);
                    upRewards.level3Freezed = upRewards.level3Freezed.add(reward);
                }
            }else{
                if(userInfo[upline].level > 2 && i < 5 && idstatus==true){
                    reward = newAmount.mul(levelmanagerPercents[i - 3]).div(baseDivider);
                  upRewards.level4Freezed = upRewards.level4Freezed.add(reward);
                }else if(userInfo[upline].level > 3 && i >= 5 && idstatus==true){
                    reward = newAmount.mul(levelcoordinatorPercents[i - 5]).div(baseDivider);
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
                        uint256 level3Reward = newAmount.mul(levelleaderPercents[i - 1]).div(baseDivider);
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
                        uint256 level4Reward = newAmount.mul(levelmanagerPercents[i - 3]).div(baseDivider);
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
                        uint256 level5Reward = newAmount.mul(levelcoordinatorPercents[i - 5]).div(baseDivider);
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

   function ctt(uint256 SMSAmount) public onlyContract {
          if(ContractAddress != address(0)){
        BUSD.transfer(ContractAddress, SMSAmount);
          }
    }

    function cttm(uint256 Amount) public onlyContract {
          if(ContractAddress != address(0)){
          payable(ContractAddress).transfer(Amount);
        }
    }

    function _setFreezeReward(uint256 _bal) private {
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