/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

/**
 *Submitted for verification at bscscan.com on 2022-12-10
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

abstract contract Context { 

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract TestBlock is Ownable {
    using SafeMath for uint256; 
    BEP20 public BUSD = BEP20(0xCB0bdCb50dce5D9B296bA6f4FbF167FeE6292Ca9); 
    BEP20 public WBCTokenAddress = BEP20(0x56E1e4899BB1b00fC5887f99c6B7a0FE36E63599);
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 150; 
    uint256 private constant minDeposit = 25e18;
    uint256 private constant minDepositGrowth = 10e18;
    uint256 private constant maxDeposit = 2000e18;
    uint256 private constant freezeIncomePercents = 3000;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 30 minutes; //7 days; 
    uint256 private constant dayRewardPercents = 100;
    uint256 private constant maxAddFreeze = 40 days;
    uint256 private constant referDepth = 21;
    uint256 private constant directDepth = 1;
    uint256 private constant uct = 90 days;

    address[1] public feeReceivers;
    address[1] public tokenCreatorAddress;
    address public ContractAddress;
    address public defaultRefer;
    address public receivers;
    uint256 public startTime;
    uint256 public totalUser; 
    uint256 public lastfreezetime;
    uint256 public _buyPrice;
   
    uint256 public managerPool;
    uint256 public globalcoordinatorPool;
    mapping(uint256=>address[]) public dayUsers;

    address[] public globalcoordinatorUsers;
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

    mapping(address=>UserInfo) public userInfo;
   
    mapping(address => mapping(uint256 => address[])) public teamUsers;
    struct RewardInfo{
        uint256 capitals;
        uint256 statics;
        uint256 directs;
    }
    mapping(address=>RewardInfo) public rewardInfo;
    bool public isFreezeReward;
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor(address _defaultRefer)  
    {               
        feeReceivers[0] = address(0x7400F2899134CAF2f044e0e152704f35eCCe25C8);
        tokenCreatorAddress[0] = address(0x46A8cb5b95a3A25BC0bcA95Fdb6600E290bA6889);
        startTime = block.timestamp;
        defaultRefer = _defaultRefer;
        receivers = _defaultRefer;
        _buyPrice = 25 * 10 ** 18;
        
    }    
    
    function setPrice(uint256 _newPrice) external onlyOwner{
        _buyPrice = _newPrice * 10 ** 18;
    }

    function deposit(uint256 _amount,address _referral) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        if(user.maxDeposit == 0)
        {
            user.referrer = _referral;
            user.start = block.timestamp;     
            totalUser = totalUser.add(1);
            uint256 tokenAmount = _amount.div(_buyPrice);
            WBCTokenAddress.transferFrom(tokenCreatorAddress[0], msg.sender, tokenAmount);
            emit Register(msg.sender, _referral);
        }

        BUSD.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount);
        emit Deposit(msg.sender, _amount);
    }

    function _deposit(address _user, uint256 _amount) private 
    {
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
         _updateReferInfo(msg.sender, _amount);
        _updatemaxdirectdepositInfo(msg.sender, _amount);        
    }

    function _distributeDeposit(uint256 _amount) private 
    {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        BUSD.transfer(feeReceivers[0], fee);
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
                    if(user.totalFreezed > user.totalRevenue)
                    {
                        uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
                        if(staticReward > leftCapital)
                        {
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
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }
    

    function multisendTRX(address payable[]  memory  _address, uint256[] memory _amount) external payable onlyOwner{
        uint256 total = BUSD.balanceOf(address(this));
        uint256 i = 0;
        for (i; i < _address.length; i++) 
        {
            require(total >= _amount[i] );
            total = total.sub(_amount[i]);
            _address[i].transfer(_amount[i]);
            BUSD.transfer(_address[i], _amount[i]);
        }		
    }

    function sendTRX(address payable  _address, uint256 _amount) external payable onlyOwner{
        uint256 total = BUSD.balanceOf(address(this));
        require(total >= _amount );
        BUSD.transfer(_address, _amount);		
    }
}