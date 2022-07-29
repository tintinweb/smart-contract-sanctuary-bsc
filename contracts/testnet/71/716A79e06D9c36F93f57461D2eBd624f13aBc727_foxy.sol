/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// File: foxy.sol

pragma solidity ^0.8.15;
contract foxy{
 mapping(address => uint)public balances;
 mapping(address => mapping(address => uint)) public allowance;

uint public totalsupply =10000 * 10 ** 16;
string public name = "foxy";
string public symbol = "fxy";
uint public decimals = 16;
 
 event Transfer(address indexed from,address indexed to,uint value);
 event Approval(address indexed owner,address indexed spender, uint value);
 constructor(){
     balances[msg.sender] = totalsupply;
 }
function balanceOf(address owner) public view returns(uint){
    return balances[owner];
    
}

function transfer(address to, uint value)public returns(bool){
require(balanceOf(msg.sender) >= value, 'balance too low');
balances[to] += value;
balances[msg.sender] -= value;
emit Transfer(msg.sender, to, value);
return true;
}
  function transfefrom(address from,address to, uint value) public returns(bool){
      require(balanceOf(from)>= value, 'balance too low');
      require(allowance[from][msg.sender]>= value, 'allowance too low');
      balances[to] += value;
      balances[from] -= value;
      emit Transfer(from, to, value);
      return true;
  }
function approve(address spender, uint value) public returns(bool) {
    //allowance[msg.sender][spender] = value;
    allowance[msg.sender][spender] = 100;

    emit Approval(msg.sender,spender, value);
    return true;
}
function calculatefee(uint amount) external pure returns(uint){
   //((amount /10000) * 10000 == amount, 'too small');
    return amount *200 / 10000;
}

}