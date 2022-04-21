// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenLocker {

    address public constant RECEVIER = 0x696C35Fd9f8A70EF0c644B1962F1F3F35021a276;
    IERC20 public constant TOKEN = IERC20(0x0fEd5EE9F34dbC08C6C4ce666c4bCfDD9697EE9e);
    uint256 public constant UNLOCKTIME = 98931;

    function release() external {
        require(block.timestamp > UNLOCKTIME, "not time");
        uint256 balance = TOKEN.balanceOf(address(this));
        TOKEN.transfer(RECEVIER, balance);
    }
}