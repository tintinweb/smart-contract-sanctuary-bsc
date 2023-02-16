/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrdinaryAi {
    string public name = "OrdinaryAi";
    string public symbol = "OAI";
    uint256 public totalSupply = 10_000_000 * 10**18;
    uint8 public decimals = 18;
    address public contractOwner;
    address public burnAddress = address(0);
    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        contractOwner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid recipient address");
        require(_value > 0 && _value <= balanceOf[msg.sender], "Invalid amount to transfer");
        
        uint256 tax = calculateTax(_value);
        uint256 tokensToTransfer = _value - tax;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += tokensToTransfer;
        balanceOf[burnAddress] += tax;

        emit Transfer(msg.sender, _to, tokensToTransfer);
        emit Burn(msg.sender, tax);

        return true;
    }

    function calculateTax(uint256 _value) private pure returns (uint256) {
        return _value * 5 / 100;
    }

    function renounceOwnership() public {
        require(msg.sender == contractOwner, "Only contract owner can renounce ownership");
        emit Transfer(contractOwner, address(0), balanceOf[contractOwner]);
        balanceOf[address(0)] += balanceOf[contractOwner];
        contractOwner = address(0);
    }
}