/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: ABC

pragma solidity 0.8.11;

contract Token010 {

    uint public constant MAX = type(uint256).max;

    string public name = "Token 010";
    string public symbol = "T010";
    uint public decimals = 18;
    uint public totalSupplyAtLaunch = 1_000_000 * ( 10 ** decimals );
    uint public totalSupply = totalSupplyAtLaunch;

    uint8 public taxDev;
    uint8 public taxMarketing;
    uint8 public taxReward;
    uint8 public taxTransfer;
    
    bool public isTradingEnabled;
    uint public tradingEnabledTime; 

    address payable public token;
    address payable public deployer;      
    address payable public owner;

    mapping(address => uint) public balance;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) private blacklist;
    mapping(address => bool) private exempt;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    
    receive() external payable {}

    constructor() {
        owner = payable(msg.sender);
        balance[owner] = totalSupply;
    }
        
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function balanceOf(address holder) public view returns(uint) {
        return balance[holder];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        balance[msg.sender] -= value;
        balance[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        balance[from] -= value;        
        balance[to] += value;
        emit Transfer(from, to, value);
        return true;   
    }
    
}