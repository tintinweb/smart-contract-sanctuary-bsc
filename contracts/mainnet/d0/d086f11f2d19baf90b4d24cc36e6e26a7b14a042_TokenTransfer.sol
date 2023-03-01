/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
}

contract TokenTransfer {
    function transferWithGas(address tokenAddress, address to, uint256 value, uint256 gasLimit) public {
        ERC20 token = ERC20(tokenAddress);
        uint256 gasPrice = tx.gasprice;
        uint256 gasCost = gasLimit * gasPrice;
        require(token.transferFrom(msg.sender, address(this), value), "Transfer failed");
        require(token.approve(msg.sender, value), "Approval failed");
        (bool success, ) = to.call{value: gasCost, gas: gasLimit}("");
        require(success, "Transfer failed");
    }
}