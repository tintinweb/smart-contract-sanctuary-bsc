// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.26;


import "./Owner.sol";

interface token{
    function transfer(address _to, uint amount)external;
}

contract Ico is owned{
    uint public fundingGoal;
    uint public deadline;
    uint public price;
    uint public fundAmount;
    uint public tokenSellAmount;
    uint public tokenRemainingAmount;
    token public tokenReward;
    address public beneficiary;//合约受益人

    mapping(address => uint)public balanceOf;

    event FundTransfer(address backer, uint amount );
    event GoalReached(bool success);


//0xb32dFc9B2fab9e39B55579605114b0E71a50C45F
    constructor(uint fundingGoalInBNB,
        uint durationInMinutes,
        uint BNBCostofEachToken,
        address addressOfToken){
            beneficiary = msg.sender;//创建合约的人
            fundingGoal = fundingGoalInBNB * 1 ether;
            deadline =  now + durationInMinutes * 1 minutes;
            price = BNBCostofEachToken ;
            tokenReward = token(addressOfToken);
        
    }
    function setPrice(uint BNBCostofEachToken) public onlyOwner{
        price = BNBCostofEachToken;
    }
    function setDeadline(uint durationInMinutes) public onlyOwner{
        deadline =  now + durationInMinutes * 1 minutes;
    }
    function setFundingGoal(uint fundingGoalInBNB) public onlyOwner{
        fundingGoal = fundingGoalInBNB * 1 ether;
    }

    function () public payable {
        require(now < deadline);

        uint amount = msg.value;  //wei
        balanceOf[msg.sender] += amount;
        fundAmount += amount;
        uint tokenAmount = amount / price;
        tokenSellAmount += tokenAmount;
        tokenRemainingAmount = 20000000 - tokenSellAmount;
        tokenReward.transfer(msg.sender, tokenAmount);
        emit FundTransfer(msg.sender,amount);

    }

    modifier afterDeadline(){
        require(now >= deadline);
        _;
    }
    function checkGoalReached() public afterDeadline{
        if (fundAmount >= fundingGoal){
            emit GoalReached(true);
        }
    }
    function withDrawal()public afterDeadline{
        
        if( beneficiary == msg.sender){
            beneficiary.transfer(fundAmount);
            tokenReward.transfer(msg.sender, tokenRemainingAmount);

        }
            

        /*else{
            uint amount = balanceOf[msg.sender];
            if (amount > 0){
                msg.sender.transfer(amount);
                balanceOf[msg.sender] = 0;

            }         
        }*/
    }
}