/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC20 {
    function balanceOf(address) external view returns(uint256);
    function transferFrom(address, address, uint256) external;
}

contract MultiPay {
    struct PayInfo {
        address payee;
        uint256 amount;
    }

    function pay(IERC20 token, PayInfo[] memory data) external {
        require(address(token) != address(0), "Invalid token");
        uint256 sum;
        for (uint8 i=0; i < data.length; i++) {
            require(data[i].payee != address(0), "0x0");
            require(data[i].amount > 0, "!0");
            sum += data[i].amount;
        }
        require(token.balanceOf(msg.sender) >= sum, "low balance");
        
        for (uint8 i=0; i < data.length; i++) {
            token.transferFrom(msg.sender, data[i].payee, data[i].amount);
        }
    }
}