/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

interface IERC20 {
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}

contract Lottery {
  address public manager;
  address[] public players;

  constructor() public {
    manager = msg.sender;
  }

  function enter() public payable {
    IERC20 token = IERC20(address(0xacf2B91d46f3289d93e1230618CBE3D6E1Ee4818)); // Insert the token contract address instead of `0x123`
    require(token.transferFrom(msg.sender, address(this), .01 ether));

    players.push(msg.sender);
}

  function random() private view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
  }

  function pickWinner() public restricted {
    uint index = random() % players.length;

    players[index].transfer(address(this).balance);

    players = new address[](0);
  }

  function getPlayers() public view returns (address[]) {
    return players;
  }

  modifier restricted() {
    require(msg.sender == manager);
    _;
  }
}