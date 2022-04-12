/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

pragma solidity >=0.4.22 <0.7.0;

interface token {
    function transfer(address receiver, uint256 amount) external ;
}

contract KAVAB {
    address  public beneficiary;
    uint256 public fundingGoal;
    uint256 public amountRaised;

    uint256 public deadline;
    uint256 public price=500000;
    token public tokenReward;


    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);


  
    constructor (
        uint256 fundingGoalInEthers,
        uint256 durationInHours,
         address addresOfToken
        
        
        
    ) public {
        beneficiary = msg.sender;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInHours *72 hours;
       
        tokenReward = token(addresOfToken);
        
    }


    function () external payable {
        require(!crowdsaleClosed);

        uint256 amount = msg.value;  
        balanceOf[msg.sender] += amount;

        amountRaised += amount;

        tokenReward.transfer(msg.sender, price * amount);

        emit FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() {
        if (now >= deadline) {
            _;
        }
    }


    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal) {
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }


    function safeWithdrawal() public afterDeadline {

        if (amountRaised < fundingGoal) {
            uint256 amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                msg.sender.transfer(amount);
                emit FundTransfer(msg.sender, amount, false);
            }
        }

        if (fundingGoal <= amountRaised && beneficiary == msg.sender) {
            beneficiary.transfer(amountRaised);
            emit FundTransfer(beneficiary, amountRaised, false);
        }
    }
}