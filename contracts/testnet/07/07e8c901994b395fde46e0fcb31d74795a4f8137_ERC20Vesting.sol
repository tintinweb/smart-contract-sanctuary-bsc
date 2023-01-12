/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: unlicensed
contract ERC20Vesting {
    // Token information
    string public name = "EMILIO";
    string public symbol = "CLEM";
    uint256 public totalSupply = 50000;

    // Vesting information
    uint256 public vestingDuration = 12 * 30 * 24 * 60 * 60;
    uint256 public vestingStart;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public vested;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Release(address indexed to, uint256 value);

    // Private constructor
    constructor() {
        vestingStart = block.timestamp;
        balanceOf[msg.sender] = totalSupply;
        vested[msg.sender] = true;
    }

    // Transfer token
    function transfer(address to, uint256 value) public {
        require(vested[msg.sender], "You must be fully vested to transfer tokens.");
        require(balanceOf[msg.sender] >= value, "You do not have enough tokens to transfer.");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
    }

    // Release vested tokens
    function release() public {
        require(!vested[msg.sender], "You have already been fully vested.");

        // Calculate the number of months since the start of the vesting period
        uint256 vestingMonths = (block.timestamp - vestingStart) / (30 *24 *60 *60);

        // Check if the user is still within the vesting period
        require(vestingMonths < vestingDuration, "The vesting period has ended.");

        // Calculate the percentage of tokens that can be released
        uint256 percentage;
        if (vestingMonths < 6) {
            percentage = 10;
        } else if (vestingMonths < 11) {
            percentage = 5;
        } else {
            percentage = 10;
        }

        // Calculate the number of tokens to be released
        uint256 tokensToRelease = (percentage * balanceOf[msg.sender]) / 100;

        // Release the tokens
        balanceOf[msg.sender] -= tokensToRelease;
        emit Release(msg.sender, tokensToRelease);

        // Check if the user is fully vested
        if (vestingMonths >= vestingDuration) {
            vested[msg.sender] = true;
        }
    }
}