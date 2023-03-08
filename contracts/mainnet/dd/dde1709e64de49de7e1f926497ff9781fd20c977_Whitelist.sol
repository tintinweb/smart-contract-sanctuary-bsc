/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

// Join the Soap Whitelist.
// This will allow you to potentially earn Airdrops or Win Giveaways.
// Welcome to the Soap Ecosystem.

/*


Without Prejudice
Without Dishonor
Without Recourse

SOAP COPYRIGHT (C) 2023 

*/

pragma solidity ^0.8.19;

contract Whitelist {
    mapping(address => bool) private _whitelist;
    address private _owner;
    uint256 private _whitelistedCount;
    
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);
    
    constructor() {
        _owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the contract owner can perform this action");
        _;
    }
    
    function addToWhitelist(address account) external onlyOwner {
        require(!_whitelist[account], "Account is already whitelisted");
        _whitelist[account] = true;
        _whitelistedCount++;
        emit AddedToWhitelist(account);
    }
    
    function removeFromWhitelist(address account) external onlyOwner {
        require(_whitelist[account], "Account is not whitelisted");
        _whitelist[account] = false;
        _whitelistedCount--;
        emit RemovedFromWhitelist(account);
    }
    
    function whitelistFunc(address account) external view returns (bool) {
        return _whitelist[account];
    }
    
    function totalWhitelisted() external view returns (uint256) {
        return _whitelistedCount;
    }
}