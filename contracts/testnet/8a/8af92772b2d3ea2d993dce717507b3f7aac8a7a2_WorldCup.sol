/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract WorldCup {
  address public owner = msg.sender;
  address operator;
  uint256 public ticketPrice;
  mapping(address => uint256) players;
  address[] wallets;
  uint256 fee;

  constructor() {
    owner = msg.sender;
    ticketPrice = 15000000000000000;
    fee = 10;
  }

  function buyTicket(address referrer) public payable {
    require(msg.value == ticketPrice);
    require(players[msg.sender] == 0);

    players[msg.sender] = msg.value;
    wallets.push(msg.sender);

    if (referrer != msg.sender && players[referrer] > 0) {
      payable(referrer).transfer((msg.value / 100) * 2);
      payable(msg.sender).transfer((msg.value / 100) * 2);
    }
    
    payable(owner).transfer((msg.value / 100) * fee);

  }

  function activeUser(address _wallet) public view returns(bool) {
    return (players[_wallet] != 0);
  }

  function reset() public restricted {
    for (uint256 i = 0; i < wallets.length; i++) {
      delete players[wallets[i]];
    }
    
    delete wallets;

    payable(owner).transfer(address(this).balance);
  }

  function setTicketPrice(uint256 _price) public restricted {
    ticketPrice = _price;
  }

  function payRewards(address[] memory _wallets, uint256 ammount) public restricted {
    for (uint256 i = 0; i < _wallets.length; i++) {
      payable(_wallets[i]).transfer(ammount);
    }
  }

  function getWallets() public view  returns(address[] memory) {
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