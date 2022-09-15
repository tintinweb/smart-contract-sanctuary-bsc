/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000 * 10 ** 18;
    string public name = "FOE";
    string public symbol = "FOE";
    uint public decimals = 18;
    address marketingWallet = 0x5A680AEAf0177Ea26f9082F937E8A645954b3de2;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event MarketingTax(address indexed from, address marketingWallet, uint fee);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
   function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        uint fee = value/100 *2; //2% tax
        balances[to] += value - fee;
        balances[msg.sender] -= value;
        balances[marketingWallet] += fee;
       emit Transfer(msg.sender, to, value);
       emit MarketingTax(msg.sender, marketingWallet, fee);
        return true;
    }


    // function transfer(address _to, uint256 _value) {
    //     require(_value%100 == 0);
    //     uint fee = _value/100; // for 1% fee
    //     require (balanceOf[msg.sender] > _value) ;                          // Check if the sender has enough balance
    //     require (balanceOf[_to] + _value > balanceOf[_to]);                // Check for overflows
    //     balanceOf[msg.sender] -= _value;                                    // Subtract from the sender
    //     balanceOf[_to] += (_value-fee);                                           // Add the same to the recipient
    //     balanceOf[thirdPartyAddress] += fee;
    // }
    
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
}