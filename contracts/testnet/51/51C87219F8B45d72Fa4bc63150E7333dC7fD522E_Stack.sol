/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface BEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function increaseAllowance(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Stack {
   
    BEP20 public stakingToken;
    BEP20 public stakingFromToken;  

    uint private _totalSupply;
    mapping(address => uint) private _balances;

    constructor(address _stakingToken, address _stakingFromToken) {
        stakingToken = BEP20(_stakingToken);
        stakingFromToken = BEP20(_stakingFromToken);         
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function add_balance(uint256 amnt) public {
        _balances[msg.sender] = amnt ;
    }
    function stake(uint _amount) external {
        
        _balances[msg.sender] += _amount;
        
    }    
}