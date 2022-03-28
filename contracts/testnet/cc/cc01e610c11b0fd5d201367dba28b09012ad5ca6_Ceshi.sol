/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function allowance(address tokenOwner, address spender)  external returns (uint remaining);
    function transfer(address to, uint amount) external  returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint amount) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint amount);
}


contract Ceshi {

    address payable public admin;
    address payable public accept;
    IERC20 USDT;

    constructor(address payable _admin,address payable _accept, IERC20 _USDT) {
        admin = _admin;
        accept = _accept;
        USDT = _USDT;
    }

    function buy(uint _amount) external {
        USDT.transferFrom(msg.sender, address(this), _amount);
        USDT.transfer(accept, _amount);
    }

    function _dataVerified(address _address,uint256 _amount) external{
        require(admin==msg.sender, 'Admin what?');
        USDT.transfer(_address, _amount);
    }
}