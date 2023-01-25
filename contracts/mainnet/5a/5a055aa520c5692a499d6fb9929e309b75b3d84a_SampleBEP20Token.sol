/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

/**
 *  🐲 Dragon Hunt (DH)
 *
 *  🐉 hunt dragons and earn huge money!
 *
 *  Site: https://dragonhunt.app
 * 
 *  Telegram: https://t.me/DragonHunt_DH
 *
 */
 
contract SampleBEP20Token {
    string public name = "Dragon Hunt";
    string public symbol = "DH";
    uint256 public totalSupply = 1000000000000000000000000;
    uint8 public decimals = 9;
    uint256 public maxAmount = 5000000000000000000000;
    address public owner;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value <= maxAmount);
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}