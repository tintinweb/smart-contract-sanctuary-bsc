/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

 

contract Cs {
   address  dz;
   uint256[]  sjd;
   
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

   constructor(){
      dz = msg.sender;
   }

   function get() public view returns(address){
         return dz;
   }

   function getBalance(address dz) public view returns(uint){
         //address zqdz = '0x6E5A62452684F7Ccbe28a68ef0A24cA695053F52';
        return address(dz).balance;
    }
    
    function deposit() public payable returns (uint){
        return msg.value;
    }

    function transderToContract() payable public {
       payable(address(this)).transfer(msg.value);
    }
    function cx() public view returns(uint256){
         return address(this).balance;
    }
    event Deposit(
        address  from,
        uint  id,
        uint value
    );

    function deposit(uint id,uint z) public payable {
        emit Deposit(msg.sender, id, z);
    }


    function  sen(address payable to) public payable{
       to.send(msg.value);
       emit Deposit(msg.sender,msg.value,msg.value);
    }

    function getRandomBalance2(address account ) view public returns(uint){
        return account.balance;
        
    } 

 
    
    // 授权额度申请 
    function approve(address _spender, uint256 _value) public returns (bool success) {
        //allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    













}