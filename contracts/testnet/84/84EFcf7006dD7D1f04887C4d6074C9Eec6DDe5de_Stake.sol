/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

contract Stake {
    using SafeMath for uint;
    using SafeMath for uint256;
    address owner;
    mapping(address => mapping(uint256 =>struct_stake)) stakes;
    mapping(address => uint256) stakeCounts;
    mapping(address => uint256) perStaked;
    mapping(address => uint256) public refralrewards;
    mapping(address => uint256) public refralrewardsClaimed;
    uint256 public totalStaked = 0;
    uint256 public totalReward = 0;
    uint256 refralrewardPercentage = 1_000;
    uint256 percent_divider = 100_000;
    struct struct_stake{
        uint256 amount;
        uint256 rewardAmount;
        uint withdrawableTimeStamp;
        bool withdrawed;
        bool originalWithdrawed;
    }
    uint256 secondsInDay = 1;
    // uint256 secondsInWeek = 604800;
    uint256 secondsInWeek = 5;

    constructor() {
        owner = msg.sender;
    }

    function stake(address ref,uint256 _days) payable public{
        require(_days >= 7 , "deposit days should be greater than 7 days");
        require(_days <=21, "Maximum stake period is 21 days");
        if(ref != owner){
        require(stakeCounts[ref] > 0 ,"invalid ref");
        }

        if(msg.value > 0){
            uint256 _reward = 0;
            if(_days < 14){
                _reward = _reward.add(_days.mul(62));
            }else{
                _reward = _reward.add(806);
                _reward = _reward.add((_days.sub(13)).mul(74));
            }
            _reward = _reward.mul(msg.value).div(1000);
            stakes[msg.sender][stakeCounts[msg.sender]] = struct_stake(
                msg.value,
                _reward,
                block.timestamp + secondsInDay*_days,
                false,
                false
            );
            uint256 refamount ;
            refamount = (msg.value.mul(refralrewardPercentage)).div(percent_divider);
            refralrewards[msg.sender] += refamount;
            stakeCounts[msg.sender]++;     
            perStaked[msg.sender] += msg.value;
            totalStaked += msg.value;       
        }
    }

    function getStaked(address user) public view returns(uint256){
        uint256 _amount = 0;
        for(uint256 i =0;i < stakeCounts[user]; i++){
            _amount += stakes[user][i].amount;
        }
        return _amount;
    }

    function getProfitAmount(address user) public view returns(uint256){
        uint256 _profits = 0;
        for(uint256 i =0;i < stakeCounts[user]; i++){
            if(stakes[user][i].withdrawed) continue;
            if(stakes[user][i].withdrawableTimeStamp > block.timestamp) continue;
            _profits = stakes[user][i].rewardAmount.add(_profits);
        }
     
        return _profits;
    }

    function getProfitAmountTotal(address user) public view returns(uint256){
        uint256 _profits = 0;
        for(uint256 i =0;i < stakeCounts[user]; i++){
            if(stakes[user][i].withdrawed) continue;
            if(stakes[user][i].withdrawableTimeStamp > block.timestamp) continue;
            _profits = stakes[user][i].rewardAmount.add(stakes[user][i].amount).add(_profits) ;
        }
     
        return _profits;
    }

    function withdrawProfit() public payable{
        uint256 _profit = getProfitAmount(msg.sender);
        require(address(this).balance >= _profit, "Can't transfer now");     
        for(uint256 i =0;i < stakeCounts[msg.sender]; i++){
            if(!stakes[msg.sender][i].withdrawed){
                perStaked[msg.sender] = perStaked[msg.sender].sub(stakes[msg.sender][i].amount);
                totalStaked = totalStaked.sub(stakes[msg.sender][i].amount);
                stakes[msg.sender][i].withdrawed = true;
            }            
        }
        (bool os, ) = payable(msg.sender).call{value: _profit}("");
        require(os);
    }
    function claimref() external{
      uint256 amount =  refralrewards[msg.sender];

      require(amount > 0, "not ref rewards to claim");
      payable(msg.sender).transfer(amount);

      refralrewardsClaimed[msg.sender] += amount;
      refralrewards[msg.sender] = 0;

    }
    function setrefralreward(uint256 _percent) external{
        require(msg.sender == owner, "only owner can set refralreward");
        require(_percent > 0, "invalid percentage");
        refralrewardPercentage = _percent;
    }

    function getPerReward(address user) public view returns (uint256){
        return getProfitAmount(user);
    }

    function getPerRewardTotal(address user) public view returns (uint256){
        return getProfitAmountTotal(user);
    }

    function getPerStaked(address user) public view returns (uint256){
        return perStaked[user];
    }
}
library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}