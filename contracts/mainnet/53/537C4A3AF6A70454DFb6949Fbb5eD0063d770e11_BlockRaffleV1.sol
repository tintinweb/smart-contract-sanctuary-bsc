// contracts/BlockRaffleV1.sol
pragma solidity ^0.4.22;

contract BlockRaffleV1 {  
  // max num of available raffle tickets
  uint public maxTickets;
    // max num of available raffle tickets
  uint public ticketsSold;
  // raffle creators address
  address public creator;
  // list of raffle participants addresses
  address[] public participants;
  // winner address
  address public winner;
  // prize text description
  string public prizeDescritpion;

  // keeps track of the number of participents
  event JoinEvent(uint _length, uint _qty);
  // keeps track of the winner
  event DrawEvent(address _winner, string _prizeDescritpion);
  // keeps track of who paid
  event Paid(address _from, uint _value);

  // Raffle - Creates a new raffle
  constructor(uint _maxTickets, string _prizeDescritpion) public payable {
    maxTickets = _maxTickets;
    prizeDescritpion = _prizeDescritpion;
    creator = msg.sender;
  }

  // `fallback` function called when eth is sent to Payable contract
  //  keeps track of who has paid
  function () public payable {
    emit Paid(msg.sender, msg.value);
  }

  // purchase ticket(s) and join the raffle
  function joinraffle(uint _qty) public payable returns(bool) {
    // if not enough eth received to pay for ticket(s) return
    if (msg.value < (0.02 ether * _qty)) {
      return false;
    }

    // if raffle is full return
    if (int(participants.length) > int(maxTickets - _qty)) {
      return false;
    }

    // add address to list of participants once for each
    // number of tickets purchased
    for (uint i = 0; i < _qty; i++) {
      participants.push(msg.sender);
    }

    // store/update the nunmber of participants in the raffle
    emit JoinEvent (participants.length, _qty);
    
    ticketsSold = participants.length;

    // if raffle is full, draw the winners address
    if (participants.length == maxTickets) {
      return draw();
    }
    return true;
  }

  // award prize when all tickets are sold
  function draw() internal returns (bool) {
    uint seed = block.number;
    uint random = uint(keccak256(seed)) % participants.length;
    winner = participants[random];

    emit DrawEvent (address(winner), prizeDescritpion);

    // transfer remaining contract balance to creator
    address(creator).transfer(address(this).balance);
    return true;
  }
}