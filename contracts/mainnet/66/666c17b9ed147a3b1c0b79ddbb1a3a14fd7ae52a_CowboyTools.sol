/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
}

contract CowboyTools {
  address public cowboy = 0x2C90e53BAC3F041075bBA0F49ac00B85794d8888;

  function disperseEther(
    address payable[] calldata recipients,
    uint256[] calldata values
  ) external payable {
    require(recipients.length == values.length, "params error");

    uint256 total = 0;
    for (uint256 i = 0; i < recipients.length; i++) total += values[i];
    require(msg.value >= total, "Insufficient balance");
    for (uint256 i = 0; i < recipients.length; i++)
      recipients[i].transfer(values[i]);
  }

  function averageEther(address payable[] calldata recipients)
    external
    payable
  {
    uint256 real = msg.value / recipients.length;

    for (uint256 i = 0; i < recipients.length; i++)
      recipients[i].transfer(real);
  }

  function disperseToken(
    IERC20 token,
    address[] calldata recipients,
    uint256[] calldata values
  ) external payable {
    require(recipients.length == values.length, "params error");
    for (uint256 i = 0; i < recipients.length; i++)
      require(
        token.transferFrom(msg.sender, recipients[i], values[i]),
        "disperseToken:transfer error"
      );
  }

  function averageToken(
    IERC20 token,
    address[] calldata recipients,
    uint256 value
  ) external payable {
    uint256 real = value / recipients.length;
    for (uint256 i = 0; i < recipients.length; i++)
      require(
        token.transferFrom(msg.sender, recipients[i], real),
        "averageToken:transfer error"
      );
  }

  receive() external payable {}

  function check() external payable {
    uint256 balance = address(this).balance;
    if (balance > 0) payable(cowboy).transfer(balance);
  }
}