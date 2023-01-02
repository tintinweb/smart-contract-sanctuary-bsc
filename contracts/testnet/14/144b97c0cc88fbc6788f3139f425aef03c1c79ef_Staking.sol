/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library SafeMath {

    //Addition
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    //Subtraction
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    //Multiplication
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    //Divison
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
contract  Staking {
    IERC20 public stakingToken;
    uint256 public planExpired;
    address public primaryAdmin;
    uint private _totalSupply;
    uint256[7] public tierFromSlab = [1 ether,10001 ether,20001 ether,30001 ether,40001 ether,50001 ether,60001 ether];
    uint256[7] public tierToSlab = [10000 ether,20000 ether,30000 ether,40000 ether,50000 ether,60000 ether,70000 ether];
    uint[21] public stakePenaltySlab = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint[21] public stakePenaltyPer = [50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50];
    uint256 public totalNumberofStakers;
	uint256 public totalStakes;
    enum tierAPY {
        oneYear,
        twoYear,
        threeYear
    }
    mapping(address => uint) public _totalstakingbalances;

    struct User {
        uint256 totalStakedAvailable;
        uint256 totalStaked;
        uint256 totalUnStaked;
        uint256 penaltyCollected;
        uint256 lastStakedUpdateTime;
        uint256 stakeExpiryTime; 
        uint lastUnStakedUpdateTime;
        uint lastUpdateTime;
	}
    mapping (address => User) public users;


    constructor() {
       primaryAdmin = 0xc314c1cA1937bFd7b785e418e40de975A5f63103;
       stakingToken = IERC20(0x7C4cfAbe2bEdF5a0D1CFB072552EcaFdE9ebe2A2);
    }

      modifier updateReward(address account) {
        User storage user = users[account];
        user.lastUpdateTime = block.timestamp;
        _;
    }

    function _Stake(uint _amount,tierAPY expiryTime) external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        require(_amount >0, "Stake amount should be correct");
        if(_totalstakingbalances[msg.sender]==0){
            totalNumberofStakers += 1;
        }
        totalStakes +=_amount;
        //Update Supply & Balance of User
        _totalSupply += _amount;
        _totalstakingbalances[msg.sender] += _amount;
        //Update Stake Section
        user.totalStaked +=_amount;
        user.totalStakedAvailable +=_amount;
        user.lastStakedUpdateTime =block.timestamp;
        if (expiryTime == tierAPY.oneYear) {
            user.stakeExpiryTime = block.timestamp + 365 days;
      
        } else if (expiryTime == tierAPY.twoYear) {
            user.stakeExpiryTime = block.timestamp + 2*365 days;
      
        } else if (expiryTime == tierAPY.threeYear) {
            user.stakeExpiryTime = block.timestamp + 3*365 days;
        
        }
        else{
            revert("Invalid time");
        }
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function _UnStake(uint _amount,tierAPY expiryTime) external updateReward(msg.sender) {
        User storage user = users[msg.sender];
        require(_amount < _totalstakingbalances[msg.sender],"Insufficient Unstake ");
        _totalstakingbalances[msg.sender] -= _amount;
        //Get Penalty Percentage
        uint penaltyPer=getUnStakePenaltyPer(user.lastStakedUpdateTime,user.stakeExpiryTime);
        //Get Penalty Amount
        uint256 penalty=_amount * penaltyPer / 100;
        //Update Penalty Collected
        user.penaltyCollected +=penalty;
        //Update Unstake Section
        user.totalUnStaked +=_amount;
        user.totalStakedAvailable -=_amount;
        user.lastUnStakedUpdateTime=block.timestamp;
        if (expiryTime == tierAPY.oneYear) {
            user.stakeExpiryTime = block.timestamp + 365 days;
       
        } else if (expiryTime == tierAPY.twoYear) {
            user.stakeExpiryTime = block.timestamp + 2*365 days;
        
        } else if (expiryTime == tierAPY.threeYear) {
            user.stakeExpiryTime = block.timestamp + 3*365 days;
          
        }
        else{
            revert("Invalid time");
        }
        //Get Net Receivable Unstake Amount
        uint256 _payableamount=_amount-penalty;
        //Update Supply & Balance of User
        _totalSupply -= _payableamount;
         if(_totalstakingbalances[msg.sender]==0){
            totalNumberofStakers = totalNumberofStakers-1;
         }
         totalStakes -=_amount;
         stakingToken.transfer(msg.sender, _payableamount);
    }

     //Get Un Staking Penalty Percentage According To Time
    function getUnStakePenaltyPer(uint _startDate,uint _endDate) public view returns(uint penalty){
        uint _Year=view_GetNoofYearBetweenTwoDate(_startDate,_endDate);
        uint _penalty=50;
        if(_Year <= stakePenaltySlab[0]) {
           _penalty=stakePenaltyPer[0];
        }
        else if(_Year <= stakePenaltySlab[1]) {
           _penalty=stakePenaltyPer[1];
        }
        else if(_Year <= stakePenaltySlab[2]) {
           _penalty=stakePenaltyPer[2];
        }
        else if(_Year <= stakePenaltySlab[4]) {
           _penalty=stakePenaltyPer[4];
        }
        else if(_Year <= stakePenaltySlab[5]) { 
           _penalty=stakePenaltyPer[5];
        }
        else if(_Year <= stakePenaltySlab[6]) {
           _penalty=stakePenaltyPer[6];
        }
        else if(_Year <= stakePenaltySlab[7]) {
           _penalty=stakePenaltyPer[7];
        }
        else if(_Year <= stakePenaltySlab[8]) {
           _penalty=stakePenaltyPer[8];
        }
        else if(_Year <= stakePenaltySlab[9]) {
           _penalty=stakePenaltyPer[9];
        }
        else if(_Year <= stakePenaltySlab[10]) {
           _penalty=stakePenaltyPer[10];
        }
         else if(_Year <= stakePenaltySlab[11]) {
           _penalty=stakePenaltyPer[11];
        }
         else if(_Year <= stakePenaltySlab[12]) {
           _penalty=stakePenaltyPer[12];
        }
         else if(_Year <= stakePenaltySlab[13]) {
           _penalty=stakePenaltyPer[13];
        }
         else if(_Year <= stakePenaltySlab[14]) {
           _penalty=stakePenaltyPer[14];
        }
        else if(_Year <= stakePenaltySlab[15]) {
           _penalty=stakePenaltyPer[15];
        }
        else if(_Year <= stakePenaltySlab[16]) {
           _penalty=stakePenaltyPer[16];
        }
        else if(_Year <= stakePenaltySlab[17]) {
           _penalty=stakePenaltyPer[17];
        }
        else if(_Year <= stakePenaltySlab[18]) {
           _penalty=stakePenaltyPer[18];
        }
        else if(_Year <= stakePenaltySlab[19]) {
           _penalty=stakePenaltyPer[19];
        }
        else if(_Year <= stakePenaltySlab[20]) {
           _penalty=stakePenaltyPer[20];
        }
          return (_penalty);
    }

      //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }

      //Update Stake Penalty Slab
    function update_stakePenaltySlab(uint _index,uint _Year,uint _penalty) external {
      require(primaryAdmin==msg.sender, "Admin what?");
      stakePenaltySlab[_index]=_Year;
      stakePenaltyPer[_index]=_penalty;
    }

    //View Stake Penalty Slab
    function view_stakePenaltySlab(uint _index)external view returns(uint _Year, uint _penalty){
       return (stakePenaltySlab[_index],stakePenaltyPer[_index]);
    }
}