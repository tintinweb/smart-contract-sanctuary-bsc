/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-19
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// contracts/Faucet.sol
// SPDX-License-Indentifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
function transfer(address to , uint256 amount) external returns (bool);
function balanceOf(address account) external view returns (uint256);
event Transfer(address indexed from, address indexed to, uint256 value);
 }

contract Faucet 
{
address payable owner;
IERC20 public token;
   struct UserInfo {
        uint256 lastUserActionTime; // keeps track of the last user action time
                uint256 shares; // keeps track of the last user action time
        uint256 lastDepositedTime; // keeps track of the last user action time
        uint256 pendingReward; // keeps track of the last user action time

    }
uint256 public withdrawalAmount = 50 * (10**18) ;
uint256 public lockTime = 24 hours;
uint256 public lastHarvestedTime;
uint256 public minToken = 10000 * (10**18);
event Deposit(address indexed from ,uint256 indexed amount);
event Withdrawal(address indexed from, uint256 indexed amount);
mapping(address => UserInfo) public userInfo;
mapping(address => uint256) public lastUserActionTime;
mapping(address => uint256) public pendingReward;
mapping(address => uint256) public balanceOf;
mapping(address => uint256) public shares;
mapping(address => uint256) public lastDepositedTime;

constructor(address tokenAddress) payable {
token = IERC20(tokenAddress);
owner = payable(msg.sender);
}
function harvest() public {
require(msg.sender != address(0), "Request must not originate from a zero account");
require(token.balanceOf(address(this)) >= withdrawalAmount, "Insufficient balance in faucet");
require(block.timestamp >= lastUserActionTime[msg.sender], "it's not possible yet");
require(token.balanceOf(msg.sender) >= minToken);
lastUserActionTime[msg.sender] = block.timestamp + lockTime;

        UserInfo storage user = userInfo[msg.sender];
        user.shares = block.timestamp + lockTime;
        user.lastDepositedTime = block.timestamp + lockTime;
        user.lastUserActionTime = block.timestamp + lockTime;
token.transfer(msg.sender, withdrawalAmount);
lastHarvestedTime = block.timestamp;
}

receive() external payable {
emit Deposit(msg.sender, msg.value);
}
function getBalance() external view returns (uint256) {
return token.balanceOf(address(this));
}
function setWithdrawalAmount(uint256 amount) public onlyOwner {
withdrawalAmount = amount * (10**18);
}
function setminToken(uint256 amount) public onlyOwner {
minToken = amount * (10**18);
}
function setLockTime(uint256 amount) public onlyOwner {
lockTime = amount * 24 hours;
}
function kill() external onlyOwner {
emit Withdrawal(msg.sender, token.balanceOf(address(this)));
token.transfer(msg.sender, token.balanceOf(address(this)));
}
    
modifier onlyOwner() {
require(msg.sender == owner,"Only the contract owner can call this function");
_;
}
}