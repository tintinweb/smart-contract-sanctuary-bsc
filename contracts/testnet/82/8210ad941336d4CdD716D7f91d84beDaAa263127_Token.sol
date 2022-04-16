/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 693000000 * 10 ** 18;
    string public name = "SD17 Blue coin (1 Ton Carbon Coin) ";
    string public symbol = "SD17Blue";
    uint public decimals = 18;
    bool private existbool = false;
    uint truebalance = 0;
    address buyer = 0x5f7A951f4eAf51be91b030EF762D84266e992DdA;
    address[] holders;
    address owner = buyer;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    
    
    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }
    function transferToHolder(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value; 
        balances[msg.sender] -= value;
        exist(to);
        if(existbool  == false && to != owner){
            holders.push(to);
        }

        emit Transfer(msg.sender, to, value);
       
        return true;
    }

     constructor() {
        balances[owner] = totalSupply;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
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
    
    function distributeRewards(uint256 _value) public returns(bool success){
        _value = _value * 10 **18;
        uint  availableSupply = (totalSupply - balanceOf(msg.sender));
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i]) * _value / availableSupply);
            transferToHolder(holders[i], percentageToHolder);

        }
        return true;
    }
    function exist(address holder) private {
        existbool = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == holder) {
                existbool = true;}
        }    
    }
    function _mint(address account, uint256 value) public {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to mint");
        require(account != address(0));
        value = value * 10 ** 18;
        totalSupply += value;
        balances[account] += value;
        exist(account);
        if(existbool  == false && account != owner){
            holders.push(account);
        }
        emit Transfer(address(0), account, value);
    }
   
}