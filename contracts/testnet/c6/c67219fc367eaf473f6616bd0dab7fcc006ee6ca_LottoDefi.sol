pragma solidity >=0.6.0 <0.9.0;

//SPDX-License-Identifier: LGPL-3.0-or-later

import "./Manageable.sol";
import "./Math.sol";

contract LottoDefi is Manageable, LMath{

    uint public minimumStake;
    uint public maximumStake;
    uint public maxTotalStake;
    uint private startTime;
    uint public Day;
    address payable[] public contracts;
    uint public totalInLot = 1;
    uint public totalStaked = 1;

    enum STAKE_STATE{
        OPEN,
        CLOSED
    }

    STAKE_STATE public stakeState;

    mapping(address => uint) public staked;
    mapping(address => uint) public stakedDay;
    mapping(address => uint) public unStakedDay;
    mapping(address => bool) public unStaked;
    mapping(uint => int) public profit;
    mapping(uint => mapping(address => bool)) public stakerClaimed;

    event LogStaked (address staker, uint amount);
    event LogUnStaked (address staker, uint amount);
    event LogProfitClaim (uint day, address staker, uint amount);


    constructor()  {
        stakeState = STAKE_STATE.CLOSED;
    }

    function depositAmount(uint _amount)internal{
        if (totalInLot < totalStaked){
            uint totalStake = totalStaked;
            uint totalIn = totalInLot;
            uint amount = sub(totalStake, totalIn);
            totalInLot += amount;
            uint remAmount = sub(_amount, amount);
            profit[today()] = int(remAmount);
        } else{
            profit[today()] = int(_amount);
        }
    }

    receive() external payable{
        depositAmount(msg.value);
    }

    function startDefi(uint _minimumStake, uint _maximumStake, uint _maxTotalStake, uint _startTime) public onlyManager{
        minimumStake = _minimumStake;
        maximumStake = _maximumStake;
        maxTotalStake = _maxTotalStake;
        startTime = _startTime;
        Day = dayFor(time());
        stakeState = STAKE_STATE.OPEN;
    }
    
    function time() internal returns (uint){
        return block.timestamp;
    }

    function today() internal returns (uint){
        return dayFor(time());
    }

    function dayFor(uint timeStamp) internal returns (uint){
        return timeStamp < startTime ? 0 : (timeStamp - startTime) / 24 hours + 1;
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
                totalInLot -= _amount;
                profit[today()] -= int(_amount);
            } else {
                return;
            }
        }
    }

    function stake() public payable{
        require(msg.value >= minimumStake && msg.value <= maximumStake, "Wrong amount");
        require(totalStaked <= maxTotalStake, "The maximum stake is reached");
        require(stakeState == STAKE_STATE.OPEN, "The staking is not open yet");
        staked[msg.sender] += msg.value;
        totalStaked += msg.value;
        totalInLot += msg.value;
        emit LogStaked(msg.sender, msg.value);
        stakedDay[msg.sender] = today();
    }
    
    function unStake() payable public{
        require(today() > (stakedDay[msg.sender] + 7), "The minimum staking period is 7 days");
        uint amount = staked[msg.sender];
        address payable user = payable(msg.sender);
        user.transfer(amount);
        staked[msg.sender] -= amount;
        totalStaked -= msg.value;
        totalInLot -= amount;
        unStakedDay[msg.sender] = today();
        unStaked[msg.sender] = true;
        emit LogUnStaked(msg.sender, amount);
    }

    function claimProfit(uint _day) internal{
        require(_day >= stakedDay[msg.sender], "choose between stake and unstake day");
        require(_day < today() - 7,"you can't claim your reward before 7 days of today");

        uint stakerTotal = cast(staked[msg.sender]);
        uint totalStake = cast(totalStaked);
        uint price = wdiv(cast(uint(profit[_day])), cast(totalStake));
        uint reward = wmul(cast(price), cast(stakerTotal));
        address payable staker = payable(msg.sender);
        
        if (reward <= 0 || stakerClaimed[_day][msg.sender] == true){
            return;
        }
        else if(reward > 0){
            staker.transfer(reward);
            emit LogProfitClaim(_day, msg.sender, reward);
            stakerClaimed[_day][msg.sender] = true;
       }
    }

    function claimAllProfits() public{

        if (unStaked[msg.sender] == true){
            for (uint i = stakedDay[msg.sender]; i < unStakedDay[msg.sender]; i++){
                claimProfit(i);
            }
        }
        for (uint i = stakedDay[msg.sender]; i < today(); i++){
            claimProfit(i);            
        }
    }
}