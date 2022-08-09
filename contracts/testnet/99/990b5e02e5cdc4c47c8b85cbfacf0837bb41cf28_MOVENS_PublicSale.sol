/**
 *Submitted for verification at BscScan.com on 2022-08-09
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

contract MOVENS_PublicSale {
    
    address public owner;
    uint public minLimit;
    uint public maxLimit;
    uint public maxCollectionLimit;
    uint public totalDeposit;
    uint public time;
	uint buyPrice;
	uint buyPriceDecimal;
	 
	
    struct Deposit {
        uint[] amounts;
        uint[] times;
    }
    
    struct Claim {
        uint[] claimAmounts;
        uint[] claimTimes;
    }
    
    BEP20 token1; 
    address token2; 
    
    
    mapping(address => Deposit) private dep;
    mapping(address => Claim) claim;
    
    event OwnershipTransferred(address to);
    event Received(address, uint);
    
    constructor(uint ADD_T, BEP20 ADD_T1, address ADD_T2) {
        owner = msg.sender;
        time = ADD_T;
        token1 = ADD_T1;
        token2 = ADD_T2;
        minLimit = 20 * 10**18;
        maxLimit = 1000 * 10**18;
        maxCollectionLimit = 467500 * 10**18;
        buyPrice = 55;
        buyPriceDecimal = 10000;
            
    }
    
    function deposit(uint amount) public {
        require(amount >= minLimit && amount <= maxLimit, "Min Max Limit Found");
        require(token1.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(totalDeposit < maxCollectionLimit , "Max Deposit Limit Reached");
        address sender = msg.sender;
        token1.transferFrom(sender, address(this), amount);
        dep[sender].amounts.push(amount);
        dep[sender].times.push(block.timestamp);
        totalDeposit += amount;
        
        uint tokens = amount / buyPrice * buyPriceDecimal;
        uint claimAmount = tokens * 20 / 100;
        uint claimAmount1 = tokens * 20 / 100;
        
        
        claim[sender].claimAmounts.push(claimAmount);
        claim[sender].claimAmounts.push(claimAmount1);
        claim[sender].claimAmounts.push(claimAmount1);
        claim[sender].claimAmounts.push(claimAmount1);
        claim[sender].claimAmounts.push(claimAmount1);


        claim[sender].claimTimes.push(time);
        claim[sender].claimTimes.push(time + 30 days);
        claim[sender].claimTimes.push(time + 60 days);
        claim[sender].claimTimes.push(time + 90 days);
        claim[sender].claimTimes.push(time + 120 days);
    
    }
    

    function setBuyPrice(uint _price,uint _price_decimal) public {
        require(msg.sender == owner, "Only owner");
        buyPrice = _price;
        buyPriceDecimal = _price_decimal;
    }
    

    function ownershipTransfer(address to) public {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Zero address error");
        owner = to;
        emit OwnershipTransferred(to);
    }
    

    function ownerTokenWithdraw(address tokenAddr, uint amount) public {
        require(msg.sender == owner, "Only owner");
        BEP20 _token = BEP20(tokenAddr);
        require(amount != 0, "Zero withdrawal");
        _token.transfer(msg.sender, amount);
    }
    

    function ownerBnbWithdraw(uint amount) public {
        require(msg.sender == owner, "Only owner");
        require(amount != 0, "Zero withdrawal");
        address payable to = payable(msg.sender);
        to.transfer(amount);
    }
    

    function updateMaxLimit(uint maxLimitAmt) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        maxLimit = maxLimitAmt * 10**18;
        return true;
    }
    

    function updateMinLimit(uint minLimitAmt) public returns(bool){
        require(msg.sender == owner, "Only owner");
        minLimit = minLimitAmt * 10**18;
        return true;
    }
    

    function updateMaxCollectionLimit(uint maxCollectionLimitAmt) public returns(bool){
        require(msg.sender == owner, "Only owner");
        maxCollectionLimit = maxCollectionLimitAmt * 10**18;
        return true;
    }


    
    function viewDeposits(address addr) public view returns(uint[] memory amt, uint[] memory at) {
        uint len = dep[addr].amounts.length;
        amt = new uint[](len);
        at = new uint[](len);
        for(uint i = 0; i < len; i++){
            amt[i] = dep[addr].amounts[i];
            at[i] = dep[addr].times[i];
        }
        return (amt,at);
    }
    

    function setFirstClaimTime(uint _time) public {
        require(msg.sender == owner, "Only owner");
        time = _time;
    }

    function claimTokens(uint index) public returns (bool) {
        require(token2 != address(0), "Claim token address not set");
        BEP20 token = BEP20(token2);
        Claim storage _claim = claim[msg.sender];
        uint amount = _claim.claimAmounts[index];
        require(block.timestamp > _claim.claimTimes[index], "Claim time not reached");
        require(_claim.claimAmounts[index] != 0, "Already claimed");
        token.transfer(msg.sender, amount);
        delete _claim.claimAmounts[index];
        return true;
    }    
    
    
    function claimDetails(address addr) public view returns(uint[] memory amounts, uint[] memory times){
        uint len = claim[addr].claimAmounts.length;
        amounts = new uint[](len);
        times = new uint[](len);
        for(uint i = 0; i < len; i++){
            amounts[i] = claim[addr].claimAmounts[i];
            times[i] = claim[addr].claimTimes[i];
        }
        return (amounts, times);
    }
    
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }    
}