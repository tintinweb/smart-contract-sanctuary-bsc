/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract GTR {
    // Variables
    uint256 public totalSupply = 100000000000 * 10 ** 18;
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public blacklist;
    string public name = "gatherRug";
    string public symbol = "GTR";
    uint8 public decimals = 18;
    uint256 public taxFee = 5;
    address public owner;
    address public taxAddress = address(0x0000000000000000000000000000000000000000);
    bool public frozen = false;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    // Constructor
    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    // Functions
    function transfer(address _to, uint256 _value) public {
        require(!frozen, "Contract is frozen");
        require(balanceOf[msg.sender] >= _value && _value > 0, "Not enough balance");
        require(!blacklist[msg.sender], "Sender address is blacklisted");
        require(!blacklist[_to], "Receiver address is blacklisted");
        uint256 tax = _value * taxFee / 100;
        require(balanceOf[msg.sender] >= _value + tax, "Not enough balance to cover tax fee");
        balanceOf[msg.sender] -= _value + tax;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        balanceOf[taxAddress] += tax;
    }

    function blacklistAddress(address _addr) public {
        require(msg.sender == owner, "Only the contract owner can call this function");
        blacklist[_addr] = true;
    }

    function unblacklistAddress(address _addr) public {
        require(msg.sender == owner, "Only the contract owner can call this function");
        blacklist[_addr] = false;
    }

    function freeze() public {
        require(msg.sender == owner, "Only the contract owner can call this function");
        frozen = true;
    }

    function unfreeze() public {
        require(msg.sender == owner, "Only the contract owner can call this function");
        frozen = false;
    }
}