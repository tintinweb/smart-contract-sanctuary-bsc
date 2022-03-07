/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.4;

interface BEP20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract LunapadINO {
    
    address public owner;
    uint public planOneCount=0;
    uint public planTwoCount=0;
    uint public planThreeCount=0;
    uint public planFourCount=0;
    uint public planFiveCount=0;

    uint public planOneMaxCount=50;
    uint public planTwoMaxCount=20;
    uint public planThreeMaxCount=10;
    uint public planFourMaxCount=5;
    uint public planFiveMaxCount=2;    

    uint public planOneTotal=0;
    uint public planTwoTotal=0;
    uint public planThreeTotal=0;
    uint public planFourTotal=0;
    uint public planFiveTotal=0;

    struct Deposit {
        uint[] amounts;
        uint[] plans;
        uint[] times;
        bool[] bnbs;
    }
    
    
    //BEP20 busd = BEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD address testnet
    BEP20 busd = BEP20(0x7182Bc441b0ef15C965117f1EdF9B879499E38AC); // BUSD address mainnet
    
    mapping(address => Deposit) private dep;
    
    event DepositAt(address user, uint amount, uint plan);
    event OwnershipTransferred(address to);
    event Received(address sender, uint amount);
    
    constructor() {
        owner = msg.sender;
    }


    function depositBnb(uint plan) external payable {
        uint cutime= block.timestamp;
        address sender = msg.sender;
        require(plan < 5,"Invalid Plan");
        uint amount = msg.value;
        if(plan==0){
            require(amount==271000000000000000,"invalid amount");
            require(planOneCount < planOneMaxCount,"Limit Exceed");
            
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(0);
            dep[sender].bnbs.push(true);
            planOneCount++;
            planOneTotal+=amount;
        }
        else if(plan==1){
            require(amount==1082000000000000000,"invalid amount");
            require(planTwoCount < planTwoMaxCount,"Limit Exceed");
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(1);
            dep[sender].bnbs.push(true);
            planTwoCount++;
            planTwoTotal+=amount;
        }
        else if(plan==2){
            require(amount==2703000000000000000,"invalid amount");
            require(planThreeCount < planThreeMaxCount,"Limit Exceed");
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(2);
            dep[sender].bnbs.push(true);
            planThreeCount++;
            planThreeTotal+=amount;
        }
        else if(plan==3){
            require(amount==5406000000000000000,"invalid amount");
            require(planFourCount < planFourMaxCount,"Limit Exceed");
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(3);
            dep[sender].bnbs.push(true);
            planFourCount++;
            planFourTotal+=amount;
        }
        else{
            require(amount==13514000000000000000,"invalid amount");
            require(planFiveCount < planFiveMaxCount,"Limit Exceed");
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(4);
            dep[sender].bnbs.push(true);
            planFiveCount++;
            planFiveTotal+=amount;
        }
        emit DepositAt(sender,amount,plan);
    }
    
    function deposit(uint plan, uint amount) external {
        uint cutime= block.timestamp;
        address sender = msg.sender;
        require(plan < 5,"Invalid Plan");
        
        if(plan==0){
            require(amount==100,"invalid amount");
            require(planOneCount < planOneMaxCount,"Limit Exceed");
            busd.transferFrom(sender, address(this), amount);
            amount = amount*(10**18);
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(0);
            dep[sender].bnbs.push(false);
            planOneCount++;
            planOneTotal+=amount;
        }
        else if(plan==1){
            require(amount==400,"invalid amount");
            require(planTwoCount < planTwoMaxCount,"Limit Exceed");
            amount = amount*(10**18);
            busd.transferFrom(sender, address(this), amount);
            
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(1);
            dep[sender].bnbs.push(false);
            planTwoCount++;
            planTwoTotal+=amount;
        }
        else if(plan==2){
            require(amount==1000,"invalid amount");
            require(planThreeCount < planThreeMaxCount,"Limit Exceed");
            amount = amount*(10**18);
            busd.transferFrom(sender, address(this), amount);
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(2);
            dep[sender].bnbs.push(false);
            planThreeCount++;
            planThreeTotal+=amount;
        }
        else if(plan==3){
            require(amount==2000,"invalid amount");
            require(planFourCount < planFourMaxCount,"Limit Exceed");
            amount = amount*(10**18);
            busd.transferFrom(sender, address(this), amount);
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(3);
            dep[sender].bnbs.push(false);
            planFourCount++;
            planFourTotal+=amount;
        }
        else{
            require(amount==5000,"invalid amount");
            require(planFiveCount < planFiveMaxCount,"Limit Exceed");
            amount = amount*(10**18);
            busd.transferFrom(sender, address(this), amount);
            dep[sender].amounts.push(amount);
            dep[sender].times.push(cutime);
            dep[sender].plans.push(4);
            dep[sender].bnbs.push(false);
            planFiveCount++;
            planFiveTotal+=amount;
        }
        emit DepositAt(sender,amount,plan);
    }
    
   
    
    // Transfer ownership 
    // Only owner can do that
    function ownershipTransfer(address to) public {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Zero address error");
        owner = to;
        emit OwnershipTransferred(to);
    }


    // Transfer ownership 
    // Only owner can do that
    function updateTotalCount(uint _planOneMaxCount, uint _planTwoMaxCount,uint _planThreeMaxCount,uint _planFourMaxCount,uint _planFiveMaxCount) external {
        require(msg.sender == owner, "Only owner");
        planOneMaxCount = _planOneMaxCount;
        planTwoMaxCount = _planTwoMaxCount;
        planThreeMaxCount = _planThreeMaxCount;
        planFourMaxCount = _planFourMaxCount;
        planFiveMaxCount = _planFiveMaxCount;
    }
    
    // Owner token withdraw 
    function ownerTokenWithdraw(address tokenAddr, uint amount) public {
        require(msg.sender == owner, "Only owner");
        BEP20 _token = BEP20(tokenAddr);
        require(amount != 0, "Zero withdrawal");
        _token.transfer(msg.sender, amount);
    }
    
    // Owner BNB withdrawal
    function ownerBnbWithdraw(uint amount) public {
        require(msg.sender == owner, "Only owner");
        require(amount != 0, "Zero withdrawal");
        address payable to = payable(msg.sender);
        to.transfer(amount);
    }
    
    

    
    function viewDeposits(address addr) public view returns(uint[] memory amt, uint[] memory at, uint[] memory plan, bool[] memory isBnb) {
        uint len = dep[addr].amounts.length;
        amt = new uint[](len);
        at = new uint[](len);
        plan = new uint[](len);
        isBnb = new bool[](len);
        for(uint i = 0; i < len; i++){
            amt[i] = dep[addr].amounts[i];
            at[i] = dep[addr].times[i];
            plan[i] = dep[addr].plans[i];
            isBnb[i] = dep[addr].bnbs[i];
        }
        return (amt,at,plan,isBnb);
    }
   
    
    
    // Fallback
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}