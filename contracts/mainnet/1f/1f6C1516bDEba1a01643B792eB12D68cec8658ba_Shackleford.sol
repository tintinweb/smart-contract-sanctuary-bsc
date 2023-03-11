/**
 *Submitted for verification at BscScan.com on 2023-03-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Shackleford {
    string public name = "Shackleford";
    string public symbol = "SHACK";
    uint256 public totalSupply = 1000000000000000000000000; // 1 billion tokens with 18 decimal places
    uint8 public decimals = 18;
    uint256 public feePercentage = 3;
    address[4] public developers = [        0x57d4a89B207E0e014e76c54be9b72346907B6Fe7,        0xa3379528baa13F84FF3965Df394Be1C5C3a1FA52,        0x000000000000000000000000000000000000dEaD    ];

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 fee = (_value * feePercentage) / 100;
        uint256 newAmount = _value - fee;
        uint256 developerFee = fee / developers.length;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += newAmount;
        for (uint256 i = 0; i < developers.length; i++) {
            balanceOf[developers[i]] += developerFee;
            emit Transfer(msg.sender, developers[i], developerFee);
        }

        emit Transfer(msg.sender, _to, newAmount);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 fee = (_value * feePercentage) / 100;
        uint256 newAmount = _value - fee;
        uint256 developerFee = fee / developers.length;

        balanceOf[_from] -= _value;
        balanceOf[_to] += newAmount;
        for (uint256 i = 0; i < developers.length; i++) {
            balanceOf[developers[i]] += developerFee;
            emit Transfer(_from, developers[i], developerFee);
        }
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, newAmount);

        return true;
    }
}