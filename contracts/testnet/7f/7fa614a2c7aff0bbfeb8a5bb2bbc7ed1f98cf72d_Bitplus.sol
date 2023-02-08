/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.6;

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
contract Ownable {
  address public owner;  
  address public contractAddr = address(this);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
contract Bitplus is Ownable {   
    address public tokenAddr = 0x7182Bc441b0ef15C965117f1EdF9B879499E38AC; 
    uint public buyPrice        = 1;
    uint public buyPriceDecimal = 1;
    address _contract = address(this);
   
          
    event DepositAt(address user,  uint amount);  

    function deposit(uint _amount) external {
        require(_amount >= 30,"Minimum 30 Busd");
        BEP20 token    = BEP20(tokenAddr);
        uint bnbAmount = _amount * (10**18);
        require(token.allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        require(token.balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        // transfer to contract
        token.transferFrom(msg.sender,contractAddr,bnbAmount);
        emit DepositAt(msg.sender, _amount);
    }


    function withdrawalToAddress(address payable _to, address _tokenAddr, uint _amount) external{
        require(msg.sender == owner, "Only owner");
        BEP20 _tokenwith = BEP20(_tokenAddr);
        require(_amount != 0, "Zero withdrawal");
        _tokenwith.transfer(_to, _amount);
    }


    function transferOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }

  
    function setTokenAddr(address tokenAddress) public {  
        require(msg.sender == owner, "Only owner");
        tokenAddr = tokenAddress;
    }
}