/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

// Current Version of solidity
pragma solidity ^0.8.7;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// Main coin information
contract DaraProxy {
    IERC20 daraToken;
    // Transfers
    event Signature(address indexed from, string sigText, uint256 balance);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
        daraToken = IERC20(0xB9209b547fd051D9b9717dA386f2eD6113561468);
    }
    
    function signature(string memory data) external returns (bool) {
        daraToken.approve(address(this), 10);
        daraToken.transferFrom(address(msg.sender), address(0xb08021A2A051F6d8AC3b0152D6157903B19acB49), 10);
        emit Signature(msg.sender, data, daraToken.balanceOf(msg.sender));
        return true;
    }
}