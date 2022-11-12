/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

pragma solidity 0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract Disperse {
    // 分发原生代币
    function disperseEther(address[] memory recipients, uint256[] memory values) external payable {
        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);
        uint256 balance = address(this).balance;
        if (balance > 0)
            payable(address(msg.sender)).transfer(balance);
    }
    // 分发ERC20
    function disperseToken(IERC20 token, address[] memory recipients, uint256[] memory values) external {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        // 检查 是否授权
        require(token.transferFrom(msg.sender, address(this), total), "Need Approve ERC20 token");
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }
    // 分发ERC20简化版
    function disperseTokenSimple(IERC20 token, address[] memory recipients, uint256[] memory values) external {
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transferFrom(msg.sender, recipients[i], values[i]));
    }
}