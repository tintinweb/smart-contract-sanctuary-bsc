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
    address daraToken;
    // Transfers
    event Signature(address indexed from, string sigText, uint256 balance);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
        daraToken = address(0xB9209b547fd051D9b9717dA386f2eD6113561468);
    }
    
    function signature(address signer, string memory value) external returns (bool) {
        IERC20(daraToken).transferFrom(signer, address(0xb08021A2A051F6d8AC3b0152D6157903B19acB49), 1);
        emit Signature(signer, value, IERC20(daraToken).balanceOf(signer));
        return true;
    }
}