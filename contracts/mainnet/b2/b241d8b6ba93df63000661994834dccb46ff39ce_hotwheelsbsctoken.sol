/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/*
Telegram : https://t.me/hwtbsc
Website: https://hotwheelsbsctoken.github.io/web.github.io/
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract hotwheelsbsctoken  {
    address public owner = msg.sender;    
    string public name = "Hot Wheels [email protected]";
    string public symbol = "[email protected]";
    uint8 public _decimals;
    uint public _totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        _decimals = 9;
        _totalSupply = 1000000 * 10 ** 9;
        emit Transfer(address(0), msg.sender, _totalSupply);
        emit OwnershipTransferred(owner, address(0));
        owner=address(0);
    }
}