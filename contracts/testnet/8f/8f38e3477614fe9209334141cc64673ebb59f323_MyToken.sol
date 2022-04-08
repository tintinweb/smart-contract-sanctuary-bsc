/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract MyToken {

    string _name = "MyToken";
    string _symbol = "MYT";
    uint256 _totalSupply = 10**12; // 1 Trillion   1 000 000 000 000
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    address _team = 0x2c8515A4Fae647243772A77127C6BBD1D777b8Dc;
    address _marketing = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

    constructor() {
        balanceOf[_team] = _totalSupply * 22 / 100;
        balanceOf[_marketing] = _totalSupply * 19 / 100;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

    }
}