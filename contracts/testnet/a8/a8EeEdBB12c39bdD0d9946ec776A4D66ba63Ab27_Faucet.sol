// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC20.sol";

contract Faucet is Ownable {

    uint256 private constant max_amount = 100;
    uint private constant time_limit = 7200;

    mapping(address => mapping(address => uint)) mapFaucetTime;

    event fauceted(address account, uint256 amount);

    constructor(address _auth) Ownable(_auth) {}

    function getFaucet(address token, uint256 amount) external {
        require(block.timestamp > mapFaucetTime[msg.sender][token] + time_limit, "too frequently");
        require(amount <= max_amount*10**ERC20(token).decimals(), "greedy");
        require(ERC20(token).balanceOf(address(this)) >= amount, "insufficient balance");
        require(ERC20(token).transfer(msg.sender, amount), "faucet error");
        mapFaucetTime[msg.sender][token] = block.timestamp;
        emit fauceted(msg.sender, amount);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        require(ERC20(token).balanceOf(address(this)) >= amount, "insufficient balance");
        require(ERC20(token).transfer(msg.sender, amount), "faucet error");
    }

    function lastFaucetTime(address account, address token) external view returns (bool res, uint time) {
        time = mapFaucetTime[account][token];
        res = time > 0;
    }
}