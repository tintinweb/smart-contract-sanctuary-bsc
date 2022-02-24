/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.8.7;


contract FlokiRushTest1 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;
    address payable public owner;
    mapping(address => uint) public balanceOf;
    int private values=0;
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply;  // Update total supply with the decimal amount
        owner=msg.sender;
        name = tokenName; // Set the name for display purposes
        symbol = tokenSymbol; // Set the symbol for display purposes
        values=1;
    }

    // require(msg.value != 0);
    function send(uint256 _value) public payable {
        require(msg.value != 0);
        // _receiver.call.value(msg.value);
        owner.transfer(msg.value);
        balanceOf[owner] += msg.value;
        totalSupply += _value;
    }
    
    function earnCoin(uint256 _value) public payable {
        balanceOf[msg.sender] += _value;
    }
}