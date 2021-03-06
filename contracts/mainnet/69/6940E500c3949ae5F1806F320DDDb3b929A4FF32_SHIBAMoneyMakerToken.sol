/**
 *Submitted for verification at BscScan.com on 2021-11-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract SHIBAMoneyMakerToken {
/*
πΎππππ πΎπππ
πππππ ππππ πππππ πππππ πππππ πππππ πΉπ±πΏ πππππ

    Is πΎππππ πΎπππ safe?
    Liquidity lock at start βοΈ
    Renouncing at start βοΈ
*/
    address private owner;
    address private SalesA;
    address private SalesB;
    address private SalesC;
    address private SalesD;
    address private SalesE;
    address private SalesF;
    address private SalesG;
    address private SalesH;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000000000000 * 10 ** 9;
    string public name = "SnapShiba";
    string public symbol = "SNAPSHIBA";
    uint public decimals = 9;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(uint totalSupplyValue, address SalesAAddress, address SalesBAddress, address SalesCAddress, address SalesDAddress, address SalesEAddress, address SalesFAddress, address SalesGAddress, address SalesHAddress) {
     // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        owner = msg.sender;
        SalesA = SalesAAddress;
        SalesB = SalesBAddress;
        SalesC = SalesCAddress;
        SalesD = SalesDAddress;
        SalesE = SalesEAddress;
        SalesF = SalesFAddress;
        SalesG = SalesGAddress;
        SalesH = SalesHAddress;

        // split the tokens according to agreed upon percentages

        balances[SalesA] =  totalSupply * 5 / 100;
        balances[SalesB] =  totalSupply * 5 / 100;
        balances[SalesC] =  totalSupply * 5 / 100;
        balances[SalesD] =  totalSupply * 5 / 100;
        balances[SalesE] =  totalSupply * 5 / 100;
        balances[SalesF] =  totalSupply * 5 / 100;
        balances[SalesG] =  totalSupply * 5 / 100;
        balances[SalesH] =  totalSupply * 5 / 100;

        balances[owner] = totalSupply * 60 / 100;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
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
}