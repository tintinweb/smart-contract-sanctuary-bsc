/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract WorldCupContract {
  address owner;
  uint256 public ticketPrice;
  mapping(address => uint256) players;
  address[] wallets;

  constructor() {
    owner = msg.sender;
    ticketPrice = 5800000000000000;

    players[msg.sender] = ticketPrice;
    wallets.push(msg.sender);

  }

  function buyTicket() public payable {
    require(msg.value == ticketPrice);
    require(players[msg.sender] == 0);

    players[msg.sender] = msg.value;
    wallets.push(msg.sender);

    payable(owner).transfer((msg.value / 100) * 10);
    
  }

  function activeUser(address _wallet) public view returns(bool) {
    return (players[_wallet] != 0);
  }

  function setTicketPrice(uint256 _price) public restricted {
    ticketPrice = _price;
  }

  function payRewards(address[] memory _wallets, uint256 ammount) public restricted {
    for (uint256 i = 0; i < _wallets.length; i++) {
      payable(_wallets[i]).transfer(ammount);
    }
  }

  function getWallets() public view restricted returns(address[] memory) {
    return wallets;
  }

  function totalPlayers() public view returns(uint256) {
    return wallets.length;
  }

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }
}