pragma solidity >=0.6.0 <0.9.0;

//SPDX-License-Identifier: LGPL-3.0-or-later

import "./Manageable.sol";
import "./Math.sol";

contract LottoDefi is Manageable, LMath{

    uint public minimumStake;
    uint public maximumStake;
    uint public maxTotalStake;
    uint private startTime;
    address payable[] public contracts;
    uint public totalStaked;

    enum STAKE_STATE{
        OPEN,
        CLOSED
    }

    STAKE_STATE public stakeState;

    address payable[] public stakers;
    address[] public unStakers;

    mapping(address => uint) public staked;
    mapping(address => uint) public stakedDay;
    mapping(address => uint) public unStakedDay;
    mapping(address => bool) public unStaked;

    event LogStaked (address staker, uint amount);
    event LogUnStaked (address staker, uint amount);
    event LogRewards (address staker, uint amount);

    constructor()  {
        stakeState = STAKE_STATE.CLOSED;
    }

    function avgRewardPer() public view returns(int){
        int profit = int(address(this).balance) - int(totalStaked);
        int avgReward = profit / int(stakers.length);
        return avgReward;
    }

    function totalInLot() public view returns(uint){
        return address(this).balance;
    }

    receive() external payable{}

    function startDefi(uint _minimumStake, uint _maximumStake, uint _maxTotalStake, uint _startTime) public onlyManager{
        minimumStake = _minimumStake;
        maximumStake = _maximumStake;
        maxTotalStake = _maxTotalStake;
        startTime = _startTime;
        stakeState = STAKE_STATE.OPEN;
    }
    
    function time() internal returns (uint){
        return block.timestamp;
    }

    function today() internal returns (uint){
        return dayFor(time());
    }

    function dayFor(uint timeStamp) internal returns (uint){
        return timeStamp < startTime ? 0 : (timeStamp - startTime) / 5 minutes + 1;
    }

    function addContract(address _contract) public onlyManager{
        contracts.push(payable(_contract));
    }

    function removeContracts() public onlyManager{
        delete contracts;
    }

    function sendGameBalance(uint _amount, address _contract) external{
        for (uint i = 0; i < contracts.length; i++){
            if (_contract == contracts[i]){
                contracts[i].transfer(_amount);
            } else {
                return;
            }
        }
    }

    function stake() public payable{
        require(msg.value >= minimumStake && msg.value <= maximumStake, "Wrong amount");
        require(totalStaked <= maxTotalStake, "The maximum stake is reached");
        require(stakeState == STAKE_STATE.OPEN, "The staking is not open yet");
        stakers.push(payable(msg.sender));
        staked[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit LogStaked(msg.sender, msg.value);
        stakedDay[msg.sender] = today();
    }
    
    function unStake() public{
        require(today() > (stakedDay[msg.sender] + 7), "The minimum staking period is 7 days");
        uint amount = staked[msg.sender];
        address payable user = payable(msg.sender);
        user.transfer(amount);
        staked[msg.sender] -= amount;
        totalStaked -= amount;
        unStakedDay[msg.sender] = today();
        unStaked[msg.sender] = true;
        unStakers.push(msg.sender);
        emit LogUnStaked(msg.sender, amount);
    }

    function sendRewards() public{
        require(staked[msg.sender] > 0 && unStaked[msg.sender] == false, "You didn't staked or you unstaked");
        if (address(this).balance < totalStaked){
            revert("Rewards is not available");
        } else{
            uint128 currentProfit = wsub(cast(address(this).balance), cast(totalStaked));
            uint128 avg = wdiv(currentProfit, cast(totalStaked));
            for(uint i = 0; i < stakers.length; i++){
                if (unStaked[stakers[i]] == false && msg.sender == stakers[i]){
                    address payable addr = stakers[i];
                    uint128 stakedAmount = cast(staked[addr]);
                    uint128 reward = wmul(avg, stakedAmount);
                    addr.transfer(uint256(reward) * 2);
                    emit LogRewards(stakers[i], reward);
                } else if(unStaked[stakers[i]] == false){
                    address payable addr = stakers[i];
                    uint128 stakedAmount = cast(staked[addr]);
                    uint128 reward = wmul(avg, stakedAmount);
                    addr.transfer(uint256(reward));
                    emit LogRewards(stakers[i], reward);
                }   
            }
        }
    }

}