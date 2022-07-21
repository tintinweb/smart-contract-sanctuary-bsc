/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TheEosDao {

    string _name = "TheEosDao";
    string _symbol = "TED";
    uint8 _decimal = 10;
    uint256 _totalSupply = 0;
    address _owner;
    mapping(address => uint256) public balances;
    mapping(address =>mapping(address => uint256)) private allowances;

    constructor(){
        _owner = msg.sender;
    }
    modifier onlyOwner{
        require(_owner == msg.sender,"not owner");
        _;
    }
    function setOwner(address newOwner) public onlyOwner{
        require(newOwner != address(0),"not zero");
        _owner = newOwner;
    }

    function mint(address to,uint256 amount) public onlyOwner{
        require(amount > 0,"not zero");
        _totalSupply = _totalSupply + amount;
        balances[to] = balances[to] + amount;
    }
    function burn(address burnAccount,uint256 value) public {
        require(balances[burnAccount] >= value,"not balances");
        require(burnAccount == msg.sender,"not owner");
        transfer(address(0),value);

    }

    function owner() public view returns(address){
        return _owner;
    }
    function name()public view returns(string memory){
        return _name;
    }
    function symbol() public view returns(string memory){
        return _symbol;
    }
    function decimal() public view returns(uint8 ){
        return _decimal;
    }
    function totalSupply() public view returns(uint256 ){
        return _totalSupply;
    }
    function balanceOf(address account) public view returns(uint256){
        return balances[account];
    }
    function allowance(address from,address to) public view returns(uint256){
        return allowances[from][to];
    }
    function approve(address to,uint256 amount) public{
        allowances[msg.sender][to] = amount;
    }
    function allowance(address from,address to,uint256) public view returns(uint256){
        return allowances[from][to];
    }
    function transfer(address to,uint256 amount) public {
        require(amount > 0,"amount not zero");
        require(balances[msg.sender] >= amount,"not balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;

    }
    function transferFrom(address from,address to,uint256 amount) public {
        require(amount > 0,"amount not zero");
        require(balances[from] >= amount && allowances[from][msg.sender] >= amount,"not balance");
        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

    }


}