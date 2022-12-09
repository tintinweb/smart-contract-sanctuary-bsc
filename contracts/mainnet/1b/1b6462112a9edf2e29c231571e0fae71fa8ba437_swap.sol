// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";

contract swap {
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    function setApprove(address token,address spender) external{
        require(msg.sender == owner,'not owner');
        IERC20(token).approve(spender,1e38);
    }
    function safePull(address token, address recipient, uint amount) external {
        require(msg.sender == owner,'not owner');
        IERC20(token).transfer(recipient, amount);
    }
}