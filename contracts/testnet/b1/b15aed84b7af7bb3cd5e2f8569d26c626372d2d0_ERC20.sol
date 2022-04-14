/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ERC20{
   event Transfer(address indexed _from,address indexed  _to,uint _value);
   event Approval(address indexed _owner,address indexed _spender,uint _value);

   uint public totalSupply=10;
   mapping(address=>uint) public balanceOf; 
   //Nested Mapping
   mapping(address=>mapping(address=>uint)) public allowance;
   string public name;
   string public symbol;
   uint8 public decimals= 18;
   address owner;

   address payable wallet=payable(0x9FC3349845de14A26125FC145a921C9C69b2C194); 

   constructor(string memory _name,string memory _symbol){
   balanceOf[msg.sender]=totalSupply;
   name=_name;
   symbol=_symbol;
   owner=msg.sender;
   }

   function transfer(address _to,uint _value) public returns(bool success)
   {
       //If balanceOf[msg.sender]=>Totalsupply is less than equal to value(demand-token) then it will tranfer
       //It will check is the number of token avaliable or not
       require(balanceOf[msg.sender]>=_value);
       balanceOf[msg.sender]-=_value;
       balanceOf[_to]+=_value;
       emit Transfer(msg.sender,_to,_value);
       return true;
   }

   function approve(address _spender,uint _value)public returns(bool success)
   {
       allowance[msg.sender][_spender]=_value;
       emit Approval(msg.sender,_spender,_value);
       return true;

   }


   function transferFrom(address _from,address _to,uint _value) public returns(bool success)
   {   require(allowance[_from][msg.sender]>=_value, "Error 1");
       require(balanceOf[_from]>=_value, "Error 2");
       balanceOf[_from]-=_value;
       balanceOf[_to]+=_value;
       allowance[_from][msg.sender]-=_value;
       emit Approval(_from,_to,_value);
       return true;
   }


// only owner
//    function mint(uint _value) public returns(bool success)
//    {
//     require(msg.sender==owner);    
//     balanceOf[msg.sender]+=_value;
//     totalSupply+=_value;
//     emit Transfer(address(0),msg.sender,_value);
//    return true;
//    }


   function mint() public payable returns(bool success)
   {
    require(msg.value>0,"invalid balance it must be some value");
    uint prev;
    uint tok;
    tok=2*msg.value;      
    prev=balanceOf[msg.sender];    
    balanceOf[msg.sender]+=tok;
    totalSupply+=tok;
    emit Transfer(address(0),msg.sender,tok);
    require(balanceOf[msg.sender]-prev==tok, "Not minted");
    wallet.transfer(msg.value);
    return true;
   }


//only owner
//    function burn(uint _value)public returns(bool success)
//    {
//        require(msg.sender==owner);
//        require(balanceOf[msg.sender]>=_value);
//        balanceOf[msg.sender]-=_value;
//        totalSupply-=_value;
//        emit Transfer(msg.sender,address(0),_value); 
//        return true;      
//    }

   function burn(uint _value)public returns(bool success)
   {
       
       require(balanceOf[msg.sender]>=_value);
       balanceOf[msg.sender]-=_value;
       totalSupply-=_value;
       emit Transfer(msg.sender,address(0),_value); 
       return true;      
   }

   function buy( )external payable 
   {
       require(balanceOf[owner]>=2*msg.value);
       balanceOf[msg.sender]+=2*msg.value;
       balanceOf[owner]-=2*msg.value;
       emit Transfer(owner,msg.sender,2*msg.value);
       wallet.transfer(msg.value);
   } 


}