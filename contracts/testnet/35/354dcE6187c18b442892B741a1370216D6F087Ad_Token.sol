/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// File: contracts/RewardsToken.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "PIXEL";
    string public symbol = "PXL";
    uint public decimals = 18;
    bool private existbool = false;
    uint truebalance = 0;
    address[] holders;
    address owner;
    uint txfee = 2;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    
    function ChangeTxFee(uint _txfee)public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        txfee = _txfee;

        return true;
    }
    
    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
    function TransferToOwner(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
       
        
        emit Transfer(msg.sender, to, value);
       

    }
    
    function transfer(address to, uint value) public returns(bool) {
    
        require(balanceOf(msg.sender) >= value, 'balance too low');
        uint truetxfee = value / 100 * txfee;
        uint truevalue = (value - truetxfee);
        balances[to] += truevalue; 
        balances[msg.sender] -= value;
        TransferToOwner(owner, truetxfee);
        emit Transfer(msg.sender, to, value);
       
        return true;
    }

     constructor() {
         owner = msg.sender;
         balances[owner] = totalSupply;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        uint truetxfee = value / 100 * txfee;
        uint truevalue = (value + truetxfee);
        balances[to] += value;
        balances[from] -= truevalue;
        TransferToOwner(owner, truetxfee);
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function burn (uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
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

        balances[_from] -= _value;
        totalSupply -= _value;
        emit Transfer (_from, address(0), _value);
        return true;
    }

    function _mint(address account, uint256 value) public {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to mint");
        require(account != address(0));
        value = value * 10 ** 18;
        totalSupply += value;
        balances[account] += value;
        
        emit Transfer(address(0), account, value);
    }
   
}