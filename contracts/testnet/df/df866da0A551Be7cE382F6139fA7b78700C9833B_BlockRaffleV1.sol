// contracts/BlockRaffleV1.sol
pragma solidity ^0.4.22;

/*
  Requirements:
    The creator sets the number of tickets and ticket price
    The creator must purchase the first ticket on creation
    Participants can buy as many tickets as are available
    The prize is awarded to a random participant once all tickets are sold
*/

contract BlockRaffleV1 {  
  // max num of available raffle tickets
  uint public maxTickets;
  // price for one raffle ticket in eth
  uint public pricePerTicket;
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
  event DrawEvent(address _winner, uint _prizeValue, string _prizeDescritpion);
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
    //  20000000000000000
    if (msg.value < (0.01 ether * _qty)) {
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

    emit DrawEvent (address(winner), 0, prizeDescritpion);

    // transfer remaining contract balance to creator
    address(creator).transfer(address(this).balance);
    return true;
  }
}