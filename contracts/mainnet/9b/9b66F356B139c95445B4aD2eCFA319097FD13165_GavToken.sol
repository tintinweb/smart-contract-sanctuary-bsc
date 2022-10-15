/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract GavToken {

    string public constant name = "SavageMavin";
    string public constant symbol = "GAVIN";
    uint8 public constant decimals = 18;

    uint256 public totalSupply = 1 * 10**6 * 10**18;
    
    mapping ( address => uint256 ) private _balances;
    mapping ( address => mapping ( address => uint256 )) public allowance;

    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    
    constructor() {
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }


    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(
            allowance[from][msg.sender] >= amount,
            'Insufficient Allowance'
        );
        
        
        // decrement allowance
        allowance[from][msg.sender] -= amount;

        // transfer
        return _transfer(from, to, amount);
    }

    function approve(address account, uint256 amount) external returns (bool) {
        allowance[msg.sender][account] = amount;
        emit Approval(msg.sender, account, amount);
        return true;
    }


    function _transfer(address from, address to, uint amount) internal returns (bool) {
        require(
            _balances[from] >= amount,
            'Insufficient Balance'
        );
        require(
            amount > 0,
            'Zero Amount'
        );
        
        // swap balances
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}