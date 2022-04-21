/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

library SafeMath {

    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    /* Modulus */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

}

contract MaticpadStaking {

    IERC20 public stakingToken;

    mapping(address => uint256) public rewards;

    address public primaryAdmin;

    uint private _totalSupply;

    mapping(address => uint) public _totalstakingbalances;

    uint256 constant public perDistribution = 100;

    uint256 public totalNumberofStakers;
	uint256 public totalStakesMATICPAD;

    uint256[5] public tierFromSlab = [0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[5] public tierToSlab = [0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[5] public tierAPY = [0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[5] public tierMaxAllocation = [0 ether,0 ether,0 ether,0 ether,0 ether];

    uint[20] public stakePenaltySlab = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint[20] public stakePenaltyPer = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];

    struct User {
        uint256 totalStakedAvailable;
        uint256 totalStaked;
        uint256 totalUnStaked;
        uint256 totalReward;
		uint256 totalRewardWithdrawal;
		uint256 totalRewardStaked;
        uint256 maxAllocation;
        uint256 penaltyCollected;
        uint lastStakedUpdateTime;
        uint lastUnStakedUpdateTime;
        uint lastUpdateTime;
	}

    mapping (address => User) public users;

    constructor() {
        primaryAdmin = 0x4336cd6FdA6014B1216D9745FCD724F93Ef136A7;
        stakingToken = IERC20(0x10eBf554d49cb6C2Ed4207Acf50ac0ea6bA54765);
    }

    function rewardPerDayToken(address account) public view returns (uint256 perdayinterest) {
        uint256 _perdayinterest=0;
        if (_totalstakingbalances[account] <= 0) {
            return _perdayinterest;
        }
        else{
            uint256 StakingToken=_totalstakingbalances[account];
            uint256 APYPer=tierAPY[getTierSlab(account)];
            uint256 perDayPer=((APYPer*1e18)/(365*1e18));
            _perdayinterest=((StakingToken*perDayPer)/perDistribution)/1e18;
            return _perdayinterest;
        }
    }

    function earned(address account) public view returns (uint256 totalearnedinterest) {
        User storage user = users[account];
        uint noofDays=view_GetNoofDaysBetweenTwoDate(user.lastUpdateTime,block.timestamp);
        uint256 _perdayinterest=rewardPerDayToken(account);
        return((_perdayinterest * noofDays)+rewards[account]);
    }

    modifier updateReward(address account) {
        User storage user = users[account];
        user.lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        _;
    }

    function _Stake(uint _amount) external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        //Manage Stake Holder & Staked Maticpad
        if(_totalstakingbalances[msg.sender]==0){
            totalNumberofStakers += 1;
        }
        totalStakesMATICPAD +=_amount;
        //Update Supply & Balance of User
        _totalSupply += _amount;
        _totalstakingbalances[msg.sender] += _amount;
        //Update Stake Section
        user.totalStaked +=_amount;
        user.totalStakedAvailable +=_amount;
        user.lastStakedUpdateTime =block.timestamp;
        user.maxAllocation = tierMaxAllocation[getTierSlab(msg.sender)];
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _UnStake(uint _amount) external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        require(_amount <= _totalstakingbalances[msg.sender],'Insufficient Unstake MATICPAD');
        _totalstakingbalances[msg.sender] -= _amount;
        //Get Penalty Percentage
        uint penaltyPer=getUnStakePenaltyPer(user.lastStakedUpdateTime,block.timestamp);
        //Get Penalty Amount
        uint256 penalty=_amount * penaltyPer / 100;
        //Update Penalty Collected
        user.penaltyCollected +=penalty;
        //Update Unstake Section
        user.totalUnStaked +=_amount;
        user.totalStakedAvailable -=_amount;
        user.lastUnStakedUpdateTime=block.timestamp;
        user.maxAllocation = tierMaxAllocation[getTierSlab(msg.sender)];
        //Get Net Receivable Unstake Amount
        uint256 _payableamount=_amount-penalty;
        //Update Supply & Balance of User
        _totalSupply -= _payableamount;
         if(_totalstakingbalances[msg.sender]==0){
            totalNumberofStakers = totalNumberofStakers-1;
         }
         totalStakesMATICPAD -=_amount;
         stakingToken.transfer(msg.sender, _payableamount);
    }

    function _RewardStake() external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        uint256 reward = rewards[msg.sender];
        // Set Reward 0
        rewards[msg.sender] = 0;
        // Stake Section
        totalStakesMATICPAD +=reward;
        _totalstakingbalances[msg.sender] += reward;
        user.totalStaked +=reward;
        user.totalStakedAvailable +=reward;
        user.lastStakedUpdateTime =block.timestamp;
        user.maxAllocation = tierMaxAllocation[getTierSlab(msg.sender)];
        // Reward Stake Section
        user.totalRewardStaked +=reward;
    }

    function _RewardWithdrawal() external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        uint256 reward = rewards[msg.sender];
        // Set Reward 0
        rewards[msg.sender] = 0;
        // Reward Withdrawal Section
        user.maxAllocation = tierMaxAllocation[getTierSlab(msg.sender)];
        user.totalRewardWithdrawal +=reward;
        stakingToken.transfer(msg.sender, reward);
    }

    // Verify Staking By Admin In Case If Needed
    function _VerifyStake(uint _amount) external {
        require(primaryAdmin==msg.sender, 'Admin what?');
        _totalSupply += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

     // Verify Un Staking By Admin In Case If Needed
    function _VerifyUnStake(uint _amount) external updateReward(msg.sender) {
        require(primaryAdmin==msg.sender, 'Admin what?');
        require(_amount >= _totalSupply,'Insufficient MATICPAD For Collect');
        _totalSupply -= _amount;
        stakingToken.transfer(primaryAdmin, _amount);
    }

    //Get Tier Slab According To Staking Maticpad
    function getTierSlab(address account) public view returns(uint tierindex){
        uint _tierindex=0;
        uint256 StakingToken=_totalstakingbalances[account];
        if(StakingToken >=tierFromSlab[0] && StakingToken <= tierToSlab[0]){
          _tierindex=0;
        }
        else if(StakingToken >=tierFromSlab[1] && StakingToken <= tierToSlab[1]){
          _tierindex=1;
        }
        else if(StakingToken >=tierFromSlab[2] && StakingToken <= tierToSlab[2]){
          _tierindex=2;
        }
        else if(StakingToken >=tierFromSlab[3] && StakingToken <= tierToSlab[3]){
          _tierindex=3;
        }
        else if(StakingToken > tierToSlab[3]){
         _tierindex=3;
        }
        else{
          _tierindex=4;
        } 
        return (_tierindex);
    }

    //Get Un Staking Penalty Percentage According To Time
    function getUnStakePenaltyPer(uint _startDate,uint _endDate) public view returns(uint penalty){
        uint _weeks=view_GetNoofWeekBetweenTwoDate(_startDate,_endDate);
        uint _penalty=0;
        if(_weeks <= stakePenaltySlab[0]) {
           _penalty=stakePenaltyPer[0];
        }
        else if(_weeks <= stakePenaltySlab[1]) {
           _penalty=stakePenaltyPer[1];
        }
        else if(_weeks <= stakePenaltySlab[2]) {
           _penalty=stakePenaltyPer[2];
        }
        else if(_weeks <= stakePenaltySlab[3]) {
           _penalty=stakePenaltyPer[3];
        }
        else if(_weeks <= stakePenaltySlab[4]) {
           _penalty=stakePenaltyPer[4];
        }
        else if(_weeks <= stakePenaltySlab[5]) { 
           _penalty=stakePenaltyPer[5];
        }
        else if(_weeks <= stakePenaltySlab[6]) {
           _penalty=stakePenaltyPer[6];
        }
        else if(_weeks <= stakePenaltySlab[7]) {
           _penalty=stakePenaltyPer[7];
        }
        else if(_weeks <= stakePenaltySlab[8]) {
           _penalty=stakePenaltyPer[8];
        }
        else if(_weeks <= stakePenaltySlab[9]) {
           _penalty=stakePenaltyPer[9];
        }
        else if(_weeks <= stakePenaltySlab[10]) {
           _penalty=stakePenaltyPer[10];
        }
         else if(_weeks <= stakePenaltySlab[11]) {
           _penalty=stakePenaltyPer[11];
        }
         else if(_weeks <= stakePenaltySlab[12]) {
           _penalty=stakePenaltyPer[12];
        }
         else if(_weeks <= stakePenaltySlab[13]) {
           _penalty=stakePenaltyPer[13];
        }
         else if(_weeks <= stakePenaltySlab[14]) {
           _penalty=stakePenaltyPer[14];
        }
        else if(_weeks <= stakePenaltySlab[15]) {
           _penalty=stakePenaltyPer[15];
        }
        else if(_weeks <= stakePenaltySlab[16]) {
           _penalty=stakePenaltyPer[16];
        }
        else if(_weeks <= stakePenaltySlab[17]) {
           _penalty=stakePenaltyPer[17];
        }
        else if(_weeks <= stakePenaltySlab[18]) {
           _penalty=stakePenaltyPer[18];
        }
        else if(_weeks <= stakePenaltySlab[19]) {
           _penalty=stakePenaltyPer[19];
        }
        return (_penalty);
    }

   function getUserPenaltyDetails(address account) public view returns (uint256 _penaltyPer,uint _stakedDay,uint _stakedWeek,uint _nooftotalSecond,uint _stakedHour,uint _stakedMinute,uint _stakedSecond) {
        User storage user = users[account];
        uint penaltyPer=getUnStakePenaltyPer(user.lastStakedUpdateTime,block.timestamp);
        uint stakedDay=view_GetNoofDaysBetweenTwoDate(user.lastStakedUpdateTime,block.timestamp);
        uint stakedWeek=view_GetNoofWeekBetweenTwoDate(user.lastStakedUpdateTime,block.timestamp);
        uint noofTotalSecond=view_GetNoofSecondBetweenTwoDate(user.lastStakedUpdateTime,block.timestamp);
        uint stakedHour=noofTotalSecond/60/60;
        uint stakedMinute=(noofTotalSecond/60)-(stakedHour*60);
        uint stakedSecond=(noofTotalSecond)-((stakedHour*3600)+(stakedMinute*60));
        return(penaltyPer,stakedDay,stakedWeek,noofTotalSecond,stakedHour,stakedMinute,stakedSecond);
   }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }

   //View No Second Between Two Date & Time
    function view_GetNoofSecondBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _second){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate);
        return (datediff);
    }

    //View No Of Days Between Two Date & Time
    function view_GetNoofDaysBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60 / 24;
        return (datediff);
    }

    //View No Of Week Between Two Date & Time
    function view_GetNoofWeekBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _weeks){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint weekdiff = (datediff) / 7 ;
        return (weekdiff);
    }

    //View No Of Month Between Two Date & Time
    function view_GetNoofMonthBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _months){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint monthdiff = (datediff) / 30 ;
        return (monthdiff);
    }

    //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public view returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }

    // Update Bronze Tier Slab
    function update_TierBronze(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint256 _tierMaxAllocation) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[0]=_fromSlab;
      tierToSlab[0]=_toSlab;
      tierAPY[0]=_tierAPY;
      tierMaxAllocation[0]=_tierMaxAllocation;
    }

    //View Bronze Tier Slab
    function view_TierBronze()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint256 _tierMaxAllocation){
       return (tierFromSlab[0],tierToSlab[0],tierAPY[0],tierMaxAllocation[0]);
    }

    // Update Silver Tier Slab
    function update_TierSilver(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint256 _tierMaxAllocation) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[1]=_fromSlab;
      tierToSlab[1]=_toSlab;
      tierAPY[1]=_tierAPY;
      tierMaxAllocation[1]=_tierMaxAllocation;
    }

    //View Silver Tier Slab
    function view_TierSilver()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint256 _tierMaxAllocation){
       return (tierFromSlab[1],tierToSlab[1],tierAPY[1],tierMaxAllocation[1]);
    }

    // Update Gold Tier Slab
    function update_TierGold(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint256 _tierMaxAllocation) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[2]=_fromSlab;
      tierToSlab[2]=_toSlab;
      tierAPY[2]=_tierAPY;
      tierMaxAllocation[2]=_tierMaxAllocation;
    }

    //View Gold Tier Slab
    function view_TierGold()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint256 _tierMaxAllocation){
       return (tierFromSlab[2],tierToSlab[2],tierAPY[2],tierMaxAllocation[2]);
    }

    //Update Diamond Tier Slab
    function update_TierDiamond(uint256 _fromSlab,uint256 _toSlab,uint256 _tierAPY,uint256 _tierMaxAllocation) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      tierFromSlab[3]=_fromSlab;
      tierToSlab[3]=_toSlab;
      tierAPY[3]=_tierAPY;
      tierMaxAllocation[3]=_tierMaxAllocation;
    }

    //View Diamond Tier Slab
    function view_TierDiamond()external view returns(uint256 _fromSlab, uint256 _toSlab, uint256 _tierAPY,uint256 _tierMaxAllocation){
       return (tierFromSlab[3],tierToSlab[3],tierAPY[3],tierMaxAllocation[3]);
    }

    //Update Stake Penalty Slab
    function update_stakePenaltySlab(uint _index,uint _week,uint _penalty) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      stakePenaltySlab[_index]=_week;
      stakePenaltyPer[_index]=_penalty;
    }

    //View Stake Penalty Slab
    function view_stakePenaltySlab(uint _index)external view returns(uint _week, uint _penalty){
       return (stakePenaltySlab[_index],stakePenaltyPer[_index]);
    }

    //Update No Of Stakers
    function verify_NumberofStakers(uint256 _amount) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      totalNumberofStakers+=_amount;
    }

    //Update Stakes Maticpad
    function verify_StakesMATICPAD(uint256 _amount) external {
      require(primaryAdmin==msg.sender, 'Admin what?');
      totalStakesMATICPAD+=_amount;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
    
}