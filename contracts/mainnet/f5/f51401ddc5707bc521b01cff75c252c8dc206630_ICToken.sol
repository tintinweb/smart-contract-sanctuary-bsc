/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/*
* Author : Mantas 
* Date   : 12/2022
* Objective => ICN/ICT BEP20 Token
*/

interface IICToken{
function balanceOf(address holder)external view returns(uint);
function balanceRounded(address holder)external view returns(uint ICN,uint cent);
function approve(address receiver,uint _amount)external returns(bool);
function transfer(address recipient, uint _amount) external returns (bool);
function transferFrom(address spender, address receiver, uint _amount)external returns(bool);
function totalSupply()external view returns(uint);
function supply()external view returns(uint);
function getOwner()external view returns(address);
function mint(address _to,uint _amount) external returns(uint);
function burn(uint _amount)external;
function setPause()external returns(bool);
function setNoPause()external returns(bool);
function blacklist(address notAllowed,uint period) external returns (address ban, uint time);
function listRemove(address allowed)external returns (bool);

} 


contract SafeExec {

function sub(uint256 a, uint256 b) internal pure returns (bool) {
 if(b <= a){
 return true;
 }
 return false;
 }
function add(uint256 a, uint256 b) internal pure returns (bool) {
 uint256 c = a + b;
if(c >= a){
 return true;
 }
 return false;
 }

function dec(uint256 a) internal pure returns(uint decimal){
uint256 one = (10 ** 18);  // 1 
decimal=a;
if(a>=one){
    uint  ict =  (a / one);
    decimal = a - (ict * one) ;  
}
}

}

contract  ICToken is IICToken,SafeExec{

address owner;
address assistance = 0x9AE25eDb46346838D12c4ac56D16d88a6284569D;

string public name = "ICN";
string public symbol = "ICN";

uint public decimal = 18;
uint circulation;
uint maxSupply = 77000000 * 10 ** decimal;

mapping (address => uint) public banned;
mapping (address => uint) balances;
mapping (address => mapping (address => uint)) allowance;

bool public pause = false;

constructor(){
    circulation = 36000000 * 10 ** decimal;
    owner=msg.sender;
    balances[owner] = circulation;
}

  modifier onlyBy(){
    require(owner==msg.sender,"! Only Owner");
    _;
  }

  modifier andAssistance(){
    require((owner==msg.sender)||(assistance==msg.sender),"! Only Owner or Assistance");
    _;
  }


//              ---=== Events ===---               
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
   
    event Deducted(address indexed owner, uint value);

    event Restricted(address indexed user, uint period);   
    event Allowed(address indexed user);
//              ---=== END ===---
    function blacklist(address notAllowed,uint period) public andAssistance returns (address ban, uint time){
    require(period<30000000000,"! 1 Year most");
    require(owner!=notAllowed,"! Can not Restrict Owner");
    banned[notAllowed] = block.timestamp + period;
    time = banned[notAllowed];
    ban = notAllowed;
    emit Restricted(notAllowed,period);
     }

    function listRemove(address allowed)public andAssistance returns (bool){
    require((banned[allowed]>block.timestamp) && (pause==false)," ! Address Not Restricted");
    banned[allowed] = 0;
    require(banned[allowed] == 0,"! Address Restricted ");
    emit Allowed(allowed);
    return true;
    }


    function assist(uint _amount)public andAssistance{   
     uint amount = (_amount*10**17);
     uint newBal = balances[owner] - amount;
     require(newBal>=amount,"Insuficient Funds");
     require((balances[assistance] + amount)<=newBal,"! Assistance Limit Reached");
     balances[owner] -= amount;                    
     balances[assistance] += amount;
     emit Deducted(owner,amount);
    }


    function mint(address _to,uint _amount) public andAssistance returns(uint){
        uint amount = (_amount*10**17);
        require((circulation + amount) <= maxSupply,"! Amount Exceed Limit");
        balances[_to] += amount;                  // Mint additional ICT tokens
        circulation += amount;
        emit Transfer(_to, owner, amount);
        return balances[owner];
    }

    function burn(uint _amount)public onlyBy{
        uint amount = (_amount*10**decimal);
        require(sub(balances[owner],amount)==true,"Overflow");
        require((circulation - amount)>(30000000 * 10 ** decimal),"! Minimum Limit Reached");
        balances[owner] -= amount;
        circulation -= amount;
        maxSupply -= amount;
        emit Deducted(msg.sender, amount);
    }

    function transfer(address recipient, uint _amount) public returns (bool) { // transfer to
        require((_amount < balances[msg.sender]) && (banned[recipient]<block.timestamp) && (pause==false),"Not Allowed");
        require(add(balances[recipient], _amount) == true,"! Overflow");
        balances[msg.sender] -= _amount;
        balances[recipient] += _amount;
        emit Transfer(msg.sender, recipient, _amount);
        return true;
    }

     function approve(address receiver,uint _amount)public returns(bool){
        require(banned[receiver] <= block.timestamp,"! Address Banned");
        require(balances[msg.sender] >= _amount,"Insufficient Funds");
        allowance[msg.sender][receiver] += _amount;
        return true;
    }

     function transferFrom(address spender, address receiver, uint _amount)public returns(bool){
        require((allowance[spender][receiver] >= _amount),"No Allowance");
        require(pause == false,"! Maintenance");
        require(banned[receiver] <= block.timestamp,"! Address Banned");
        allowance[spender][receiver] -= _amount;
        balances[spender] -= _amount;
        balances[receiver] += _amount;
        emit Transfer(spender, receiver, _amount);
        return true;
    }

      function setPause()public andAssistance returns(bool){
          pause=true;
          require(pause==true,"Pause Not Set");
          return true;
      } 

      function setNoPause()public andAssistance returns(bool){
          pause=false;
          require(pause==false,"Pause still active");
          return true;
      }
      
      function balanceRounded(address holder) public view returns(uint ICN,uint cent){
       ICN = (balances[holder]/10**decimal);
       cent = dec(balances[holder]);
      }       
      
      function balanceOf(address holder)public view returns(uint){
       return balances[holder];
    }

      function totalSupply()public view returns(uint){
        return (maxSupply/10**decimal);
    }

      function supply()public view returns(uint){
        return (circulation/(10**decimal));
    }

      function getOwner()public view returns(address){
          return owner;
      }
}