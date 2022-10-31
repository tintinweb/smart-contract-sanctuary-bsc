/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

pragma solidity ^0.4.25;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract MetaformRewardDistributor {
    function distributeRewardEther(address[] recipients, uint256[] values) external payable {
        require(recipients.length == values.length, "input lengths incompatible");
        for (uint256 i = 0; i < recipients.length; i++)
            recipients[i].transfer(values[i]);
        uint256 balance = address(this).balance;
        if (balance > 0)
            msg.sender.transfer(balance);
    }

    function distributeRewardToken(IERC20 token, address[] recipients, uint256[] values) external {
        require(recipients.length == values.length, "input lengths incompatible");
        require(token != address(0), "token cannot be zero address");
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    function distributeRewardTokenSimple(IERC20 token, address[] recipients, uint256[] values) external {
        require(recipients.length == values.length, "input lengths incompatible");
        require(token != address(0), "token cannot be zero address");
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transferFrom(msg.sender, recipients[i], values[i]));
    }
}