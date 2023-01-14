/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Multiplexer {

    address constant owner = 0x20abbc5376f3465ff44922216e39f57B75222222;

    function sendEth(address[] calldata recipients, uint256[] calldata values) payable external{
        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);
        uint256 balance = address(this).balance;
        if (balance > 0)
            payable(msg.sender).transfer(balance);
    }

    function sendErc20(IERC20 token, address[] calldata recipients, uint256[] calldata values) external {
        uint256 total = 0;
        uint256 i;
        for (i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    function claim(address _token) external {
        if (_token == address(0x0)) {
            payable(owner).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
    }

}