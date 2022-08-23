/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract LiquidityAccount {

    address private _owner;
    address private _admin;

    mapping(address => bool) _list;

    constructor () {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setAdmin(address __admin) external onlyOwner
    {
        _admin = __admin;
    }

    modifier onlyAdmin() {
        require(_admin == msg.sender || _owner == msg.sender, "Ownable: caller is not the administrator");
        _;
    }

    function push(address __sender) external onlyOwner
    {
        _list[__sender] = true;
    }

    function remove(address __sender) external onlyOwner
    {
        if (_list[__sender] == true)
        {
            delete _list[__sender];
        }
    }

    function isLiquidityAccount(address __sender) external view returns (bool)
    {
        return _list[__sender];
    }
}