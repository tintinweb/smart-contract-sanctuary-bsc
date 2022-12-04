// contracts/GetdoneMultiSend.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract GetdoneMultiSend {
    receive()
        external
        payable
    {}

    function sendEther(address[] memory recipients, uint256[] memory values) external payable {
        uint256 i = 0;
        for (i = 0; i < recipients.length; i++) {
            recipients[i].call{value: values[i]}("");
        }
    }

    function safeSendToken(IERC20 token, address[] memory recipients, uint256[] memory values) external {
        uint256 total = 0;
        uint256 i = 0;
        for (i = 0; i < recipients.length; i++) {
            total += values[i];
        }
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], values[i]));
        }
    }

    function sendToken(IERC20 token, address[] memory recipients, uint256[] memory values) external {
        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transferFrom(msg.sender, recipients[i], values[i]));
        }
    }
}