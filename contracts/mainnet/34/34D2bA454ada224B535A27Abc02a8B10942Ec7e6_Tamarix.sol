/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

}

// Tamarix
//
// Tamarix was created to accelerate transactions in online retail and has a mission to 
// reduce overhead costs in O-Retail. Tamarix project designed a model of 
// direct exchange between producer and consumer.
//
// https://tamarix.io
// [email protected]

contract Tamarix is IBEP20 {

    using SafeMath for uint256;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => uint256) private lockedAmounts;
    mapping (address => uint256) private registerDates;

    address public contractOwner;
    address public operatorAccount;
    address public feesAccount;
    uint256 public endDate;
    uint256 public totalSupply_;
    uint256 public transferFee;
    uint256 public taxFee;
    uint256 public transactionThreshold;
    uint8 public decimals;
    string public symbol;
    string public name;
    
    constructor() {
        
        contractOwner = msg.sender;
        name = "Tamarix";
        symbol = "TAMARIX";
        decimals = 8;
        totalSupply_ = 10000000000000000; // 100,000,000
        balances[msg.sender] = totalSupply_;
        endDate = 1726950600;

        emit Transfer(address(0), msg.sender, totalSupply_);
  }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Access Denied.");
        _;
    }
    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address receiver, uint256 amount) public returns (bool){
        require(amount <= balances[msg.sender],"Insufficient Funds.");
        require(receiver != address(0), "Transfer to the zero address.");
        require(
            (amount <= balances[msg.sender].subZero(lockedAmounts[msg.sender])
            || 
            (registerDates[msg.sender] < block.timestamp.sub(730 days)))
            ||
            (receiver == contractOwner) || (receiver == operatorAccount)
             ,"Insufficient Unlocked Funds.");

        if(receiver != contractOwner && receiver != operatorAccount && receiver != feesAccount &&
          feesAccount != address(0) && transactionThreshold != 0 && amount >= transferFee &&
          msg.sender != contractOwner && msg.sender != operatorAccount && msg.sender != feesAccount){

          uint256 cost;
          if(amount < transactionThreshold){
            cost = transferFee;
          }else{
            cost = amount.mul(taxFee).div(10000000000);
          }

          balances[receiver] = balances[receiver].add(amount).sub(cost);
          balances[feesAccount] = balances[feesAccount].add(cost);
          emit Transfer(msg.sender, feesAccount, cost);
          emit Transfer(msg.sender, receiver, amount.sub(cost));
        }else{
          balances[receiver] = balances[receiver].add(amount);
          emit Transfer(msg.sender, receiver, amount);
        }
        
        balances[msg.sender] = balances[msg.sender].sub(amount);

        if((receiver == contractOwner || receiver == operatorAccount) && (msg.sender != contractOwner || msg.sender != operatorAccount)){
          if(lockedAmounts[msg.sender].subZero(amount)>0){
            lockedAmounts[msg.sender] = lockedAmounts[msg.sender].sub(amount);
          }else{
            lockedAmounts[msg.sender] = 0;
          }
        }

        if(msg.sender == contractOwner || msg.sender == operatorAccount){
            if(block.timestamp < endDate){
               lockedAmounts[receiver] = lockedAmounts[receiver] + amount;
               registerDates[receiver] = block.timestamp;
            }
        }
       
        return true;
    }

    function approve(address delegate, uint256 amount) public returns (bool){
        allowances[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
        return true;
    }

    function increaseAllowance(address delegate, uint256 addedValue) public returns (bool) {
        approve(delegate, allowances[msg.sender][delegate].add(addedValue));
        return true;
    }

    function decreaseAllowance(address delegate, uint256 subtractedValue) public returns (bool) {
        approve(delegate, allowances[msg.sender][delegate].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256){
        return allowances[owner][delegate];
    }

    function transferFrom(address owner, address receiver, uint256 amount) public returns (bool){
        require(owner != address(0), "Transfer from the zero address.");
        require(receiver != address(0), "Transfer to the zero address.");
        require(amount <= balances[owner],"Insufficient Funds.");
        require(amount <= allowances[owner][msg.sender]);
        require(
            (amount <= balances[owner].subZero(lockedAmounts[owner])
            || 
            (registerDates[owner] < block.timestamp.sub(730 days)))
            ||
            (receiver == contractOwner) || (receiver == operatorAccount)
             ,"Insufficient Unlocked Funds.");

        if(receiver != contractOwner && receiver != operatorAccount && receiver != feesAccount &&
          feesAccount != address(0) && transactionThreshold != 0 && amount >= transferFee &&
          owner != contractOwner && owner != operatorAccount && owner != feesAccount){

          uint256 cost;
          if(amount < transactionThreshold){
            cost = transferFee;
          }else{
            cost = amount.mul(taxFee).div(10000000000);
          }

          balances[receiver] = balances[receiver].add(amount).sub(cost);
          balances[feesAccount] = balances[feesAccount].add(cost);
          emit Transfer(owner, feesAccount, cost);
          emit Transfer(owner, receiver, amount.sub(cost));
        }else{
          balances[receiver] = balances[receiver].add(amount);
          emit Transfer(owner, receiver, amount);
        }

        balances[owner] = balances[owner].sub(amount);
        allowances[owner][msg.sender] = allowances[owner][msg.sender].sub(amount);

        if((receiver == contractOwner || receiver == operatorAccount) && (owner != contractOwner || owner != operatorAccount)){
          if(lockedAmounts[owner].subZero(amount)>0){
            lockedAmounts[owner] = lockedAmounts[owner].sub(amount);
          }else{
            lockedAmounts[owner] = 0;
          }
        }

        if(owner == contractOwner || owner == operatorAccount){
            if(block.timestamp < endDate){
               lockedAmounts[receiver] = lockedAmounts[receiver] + amount;
               registerDates[receiver] = block.timestamp;
            }
        }
        
        return true;

    }

   function transferWithoutLock(address receiver, uint256 amount) public onlyOwner returns (bool){
        require(amount <= balances[msg.sender],"Insufficient Funds.");
        require(receiver != address(0), "Transfer to the zero address.");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function updateEndDate(uint256 newDate) public onlyOwner returns (bool){
            endDate = newDate;
            return true;
    }

    function updateOperatorAccount(address newAddress) public onlyOwner returns (bool){
            operatorAccount = newAddress;
            return true;
    }

    function updateFeesAccount(address newAddress) public onlyOwner returns (bool){
            feesAccount = newAddress;
            return true;
    }

    function updateFee(uint256 newFee, uint256 newTax, uint256 newThreshold) public onlyOwner returns (bool){
            // By adding this condition you can be sure that transfer fee can never be more than 1 token.
            if(newFee > 100000000){transferFee = 100000000;}else{transferFee = newFee;}
            // By adding this condition you can be sure that tax fee can never be more than 1 percent.
            if(newTax > 100000000){taxFee = 100000000;}else{taxFee = newTax;}
            transactionThreshold = newThreshold;
            return true;
    }

    function burn(uint256 amount) public onlyOwner returns (bool){
        require(balances[msg.sender] >= amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);

        emit Transfer(msg.sender, address(0), amount);

        return true;
    }

    function getLockedAmount(address user) public onlyOwner view returns (uint256){
      return lockedAmounts[user];
    }

    function getRegisterDate(address user) public onlyOwner view returns (uint256){
      return registerDates[user];
    }

}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function subZero(uint256 a, uint256 b) internal pure returns (uint256){
    uint256 c;
    if(b > a){
      c = 0;
    }else{
      c = a - b;
    }
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
      return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      require(b > 0, errorMessage);
      uint256 c = a / b;

      return c;
  }

}

//TB