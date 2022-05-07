/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "MoveZ";
    string public symbol = "MOVEZ";
    uint public decimals = 18;
    address owner = 0x5A757662B8EB2a99AF9e59EC4160a61f06aCd26F;
    uint txfee = 10;
    bool txfeeSwitch = true; 

    

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    
    
    function txfeeon(bool trueOrfalse) public {

        require(msg.sender == owner);
        txfeeSwitch = trueOrfalse;
    }


    function txonoff() private {
        if(txfeeSwitch == true) {   // if else statement
         txfee = 10;
      
      } else {
         txfee = 0;
      }       
    }
    
    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
    function TransferToOwner(address to, uint value) private{
        balances[to] += value;
       
        
        emit Transfer(msg.sender, to, value);
       

    }
    
    function transfer(address to, uint value) public returns(bool) {
        
        require(balanceOf(msg.sender) >= value, 'balance too low');
        uint truetxfee = value / 100 * txfee;
       
        uint truevalue = (value - truetxfee );
        balances[to] += truevalue;
        balances[msg.sender] -= value;
        TransferToOwner(owner, truetxfee);
       
        emit Transfer(msg.sender, to, truevalue);
        return true;   
    }

     constructor() {
         
         balances[owner] = totalSupply;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        uint truetxfee = value / 100 * txfee;
    
        uint truevalue = (value - truetxfee);
        balances[to] += truevalue;
        balances[from] -= value;
        TransferToOwner(owner, truetxfee);
        
        emit Transfer(from, to, truevalue);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function burn (uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        _value = _value * 10 ** 18;
        require(balanceOf(msg.sender) >= _value);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }


 
    function burnFrom(address _from, uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        require(balanceOf(_from) >= _value);
        require(_value <= allowance[_from][msg.sender]);
        _value = _value * 10 ** 18;
        balances[_from] -= _value;
        totalSupply -= _value;
        emit Transfer (_from, address(0), _value);
        return true;
    }

   
}