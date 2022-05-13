// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './IERC20.sol';

contract Denial {
  address public partner; // withdrawal partner - pay the gas, split the withdraw
  mapping(address => uint256) public playerBalance; // keep track of partners balances

  IERC20 token;

  function setTokenAddress(address tokenAddress) public {
      token = IERC20(tokenAddress);
  }

  function deposit(uint256 amount) external {
    assert(amount > 0);
    playerBalance[msg.sender] += amount;
    token.transferFrom(msg.sender, address(this), amount);
  }


  function withdraw(uint256 amount) external {
    require(amount <= playerBalance[msg.sender]);
    token.transfer(msg.sender, amount);
    playerBalance[msg.sender] -= amount;
  }

  function getBalance() external view returns (uint256) {
      return playerBalance[msg.sender];
  }

  function buyItemOnShop(uint256 amount ) external returns (bool) {
      require(amount <= playerBalance[msg.sender]);
      playerBalance[msg.sender] -= amount;
      token.transferFrom(msg.sender, address(this), amount);
      return true;
  }

  function buyItemOnMarketplace(address recipient, uint256 amount) external returns (bool) {
      require(amount <= playerBalance[msg.sender], "No enough balance ");
      playerBalance[msg.sender] -= amount;
      playerBalance[recipient] += amount;
      return true;
  }
  
}