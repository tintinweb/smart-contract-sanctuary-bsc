/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract Skoohii {
    event MultiTransferredToken(IERC20 indexed token, address[] recipients, uint256[] values, uint256 total);
    event TransferredToken(IERC20 indexed token, address recipient, uint256 value);

    // ERC721 or ERC20
    function multiTransferToken(
        address tokenAddress, 
        address[] calldata recipients, 
        uint256[] calldata values) external payable {

        require(recipients.length == values.length, "multiTransferToken: recipients and values length mismatch");
        require(values.length > 0, "multiTransferToken: no recipients");

        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        
        require(total > 0, "multiTransferToken: must have values");

        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), total));

        
        for (uint256 i = 0; i < recipients.length; i++)
            require(IERC20(tokenAddress).transferFrom(msg.sender, recipients[i], values[i]));

        emit MultiTransferredToken(IERC20(tokenAddress), recipients, values, total);
    }

    function transferToken(
        address tokenAddress, 
        address recipient, 
        uint256 value) external payable {

        require(value > 0, "transferToken: must have value");

        require(IERC20(tokenAddress).transferFrom(msg.sender, recipient, value));

        emit TransferredToken(IERC20(tokenAddress), recipient, value);
    }
}