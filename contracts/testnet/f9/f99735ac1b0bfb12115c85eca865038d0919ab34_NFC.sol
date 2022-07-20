/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFC {

    string private _name;
    string private _symbol;
    uint8 private _decimal;
    uint256 private _totalSupply;
    address private _owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping (address => uint256)) public allowances;
    constructor(){
        _name = "NongFu Spring Coin";
        _symbol = "NFC";
        _decimal = 10;
        _totalSupply = 100000000 *10**10;
        _owner = msg.sender;
        balances[msg.sender] = _totalSupply;
    }
    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    function name() public view returns(string memory){
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
    function owner() public view returns(address){
        return _owner;
    }
    function setOwner(address Newowner) public  onlyOwner{
        require(Newowner != address(0),"address not zero");
        _owner = Newowner;
    }
    function burn(address burnAccount,uint256 value) public  onlyOwner{
        balances[burnAccount] -= value;
        _totalSupply=_totalSupply-value;

    }

    function approve(address sperder,uint256 value) public {
        allowances[msg.sender][sperder] = value;

    }

    function allowance(address owner1,address sperder) public view returns(uint256){
        return allowances[owner1][sperder];
    }
    function transfer(address to,uint256 value) public {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= value,"address not balance");
        balances[msg.sender] -= value;
        balances[to] += value;

    }

    function transferFrom(address from,address  to,uint256 value) public {
        uint256 senderBalance = balances[from];
        require(senderBalance >=value,"address not balance");
        require(allowances[from][msg.sender] >= value,"address not allowance");
        balances[to] += value;
        balances[from] -= value;
        allowances[from][msg.sender];
    }

}