/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

pragma solidity 0.4.25;

 interface token {
    function transfer(address receiver, uint amount) external;
}


contract Crowdsale {
    token public tokenReward;
    address public beneficiary = msg.sender; 
    uint public amountRaised; 
    uint public price; 

    mapping(address => uint256) public balance; 


    event GoalReached(address _beneficiary, uint _amountRaised);


    constructor(

        uint TokenCostOfEachether,
        address addressOfTokenUsedAsReward

    )  public {

        price = TokenCostOfEachether ; 
        tokenReward = token(addressOfTokenUsedAsReward); 
    }


  
    function () payable public {

        uint amount = msg.value;
        balance[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount * price);
         
    }

    function safeWithdrawal() public {

        if (beneficiary == msg.sender) { 
            beneficiary.transfer(amountRaised);
        }
    }
}