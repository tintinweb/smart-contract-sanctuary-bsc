/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

//SPDX-License-Identifier: UNLICENSED

//DEVELOPMENT TEAM: SnipeFinance.com 
//contact: t.me/SnipeFinance
pragma solidity >=0.7.0 <0.9.0;

contract USDT {
    address public minter;
    mapping(address => uint) public balances;
    string name;
    string symbol;
    uint supply;

    event sent(address from, address to, uint amount);

    constructor() {
        minter = msg.sender;
        name = 'USDT';
        symbol = 'USDT';
        supply = 1000000000;
    }

    //functions
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
        supply += amount;
    }

    //send any amount of coins
    //to an existing address
    //cannot send above balance
    
    error insufficientBalance(uint requested, uint available);

    function send(address receiver, uint amount) public {
        if(amount > balances[msg.sender])
           revert insufficientBalance({
               requested: amount,
               available: balances[msg.sender]
           }); 

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit sent(msg.sender, receiver, amount);
    }
    
    //show total supply minted by minter

    function totalSupply() public view returns(uint) {
        return supply;
    }

    //show token name

    function tokenName() public view returns(string memory) {
        return name;
    }

    //show token symbol

    function tokenSymbol() public view returns(string memory) {
        return symbol;
    }

    //token burn
    
    function burn(address receiver, uint amount) public {
        
        if(amount > balances[receiver])
           revert insufficientBalance({
               requested: amount,
               available: balances[msg.sender]
           });

        supply -= amount;   
        require(msg.sender == minter);
        balances[receiver] -= amount;
        emit sent(msg.sender, receiver, amount);
    } 
}