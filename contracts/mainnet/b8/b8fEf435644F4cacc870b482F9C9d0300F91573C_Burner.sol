/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


interface BEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Burner {
    address public owner;
    address public burnAddress;
    mapping(address => uint) public balances;

    constructor() {
        owner = msg.sender;
    }
    
    function setBurnAddress(address _burnAddress) public {
        require(msg.sender == owner, "Only owner can set the burn address");
        burnAddress = _burnAddress;
    }

    function transfer(address _to, uint256 _value) public {
        require(_to == address(this), "Transfer must be to the contract address");
        require(_value > 0, "Must transfer a positive amount");
        require(BEP20(_to).transferFrom(msg.sender, _to, _value), "Transfer failed");
        burn(_value);
    }

   function burn(uint256 _value) public {
    require(burnAddress != address(0), "Burn address not set");
    require(balances[msg.sender] >= _value && _value > 0, "Not enough balance.");
    uint256 burnValue = _value;
    uint256 burnRate = burnValue / 24; // Burn token at a rate of 1/24th of total value per hour
    for (uint i = 0; i < 24; i++) {
        require(burnValue > 0, "Token burn complete");
        require(burnValue >= burnRate, "Not enough token to burn at this rate");
        burnValue -= burnRate;
        BEP20(burnAddress).transfer(burnAddress, burnRate);
    }
}


    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}