pragma solidity ^0.4.24;

import "./utils/SafeMath.sol";
import './RefereeOnly.sol';

contract BetList is RefereeOnly {
  using SafeMath for uint256;

  struct Bet {
    uint id;
    address challenger;
    address accepter;
    string name; // matchID
    string conditions; // local, away
    string status; // open, both, paid, lock, rollback, draft
    uint expiration; // timestamp
    uint256 price;
    uint commission; // commision to use when is paid
  }

  mapping (uint => Bet) public bets;
  uint betCounter;
  uint refereeCommision = 3;


  event LogPublishBet(
    uint indexed _id,
    address indexed _challenger,
    string _name,
    uint256 _price
  );

  event LogAcceptBet(
    uint indexed _id,
    address indexed _challenger,
    address indexed _accepter,
    string _name,
    uint256 _price
  );

  event LogResolveBet(
    uint indexed _id,
    address indexed _challenger,
    address indexed _accepter,
    string _name,
    uint256 _prize
  );


  // Publish a new bet
  function publishBet(string _name, string _conditions, uint256 _price, uint _timestamp) payable public {
    // The challenger must deposit his bet
    require(_price > 0 && msg.value == _price);

    // A new bet
    betCounter++;

    // Store this bet into the contract
    bets[betCounter] = Bet(
      betCounter,
      msg.sender,
      0x0,
      _name,
      _conditions,
      "open",
      _timestamp,
      _price,
      refereeCommision
    );

    // Trigger a log event
    emit LogPublishBet(betCounter, msg.sender, _name, _price);
  }


  // Fetch the total number of bets in the contract
  function getNumberOfBets() public view returns (uint) {
    return betCounter;
  }

  // Set commission
  function setCommision(uint _newCommision) refereeOnly public returns (uint) {
    refereeCommision = _newCommision;
  }


  // Fetch and return all bet IDs for bets that are still available
  function getAvailableBets() public view returns (uint[]) {
    uint[] memory betIds = new uint[](betCounter);
    uint numberOfAvailableBets = 0;

    // Iterate over all bets
    for(uint i = 1; i <= betCounter; i++) {
      // Keep the ID if the bet is still available
      if(bets[i].accepter == 0x0) {
        betIds[numberOfAvailableBets] = bets[i].id;
        numberOfAvailableBets++;
      }
    }

    uint[] memory availableBets = new uint[](numberOfAvailableBets);

    // Copy the betIds array into a smaller availableBets array to get rid of empty indexes
    for(uint j = 0; j < numberOfAvailableBets; j++) {
      availableBets[j] = betIds[j];
    }

    return availableBets;
  }

  // Fetch and return all bet IDs for one name given
  function getBetsByMatchId(string _matchId) public view returns (uint[]) {
    uint[] memory betIds = new uint[](betCounter);
    uint numberOfAvailableBets = 0;

    // Iterate over all bets
    for(uint i = 1; i <= betCounter; i++) {
      // Keep the ID if the bet is still available
      
      if(keccak256(bytes(bets[i].name)) == keccak256(bytes(_matchId))) {
        betIds[numberOfAvailableBets] = bets[i].id;
        numberOfAvailableBets++;
      }
    }

    uint[] memory availableBets = new uint[](numberOfAvailableBets);

    // Copy the betIds array into a smaller availableBets array to get rid of empty indexes
    for(uint j = 0; j < numberOfAvailableBets; j++) {
      availableBets[j] = betIds[j];
    }

    return availableBets;
  }

  // Fetch and return all bet IDs for one status given
  function getBetsByStatus(string _status) public view returns (uint[]) {
    uint[] memory betIds = new uint[](betCounter);
    uint numberOfAvailableBets = 0;

    // Iterate over all bets
    for(uint i = 1; i <= betCounter; i++) {
      // Keep the ID if the bet is still available
      
      if(keccak256(bytes(bets[i].status)) == keccak256(bytes(_status))) {
        betIds[numberOfAvailableBets] = bets[i].id;
        numberOfAvailableBets++;
      }
    }

    uint[] memory availableBets = new uint[](numberOfAvailableBets);

    // Copy the betIds array into a smaller availableBets array to get rid of empty indexes
    for(uint j = 0; j < numberOfAvailableBets; j++) {
      availableBets[j] = betIds[j];
    }

    return availableBets;
  }


  // Accept a bet
  function acceptBet(uint _id) payable public {
    // Check whether there is a bet published
    require(betCounter > 0);

    // Check that the bet exists
    require(_id > 0 && _id <= betCounter);

    // Retrieve the bet
    Bet storage bet = bets[_id];

    // Check that the bet has not been accepted yet
    require(bet.accepter == 0x0, "Bet is already accepted by other");

    // Check that the bet has not been accepted yet
    require(bet.expiration > block.timestamp, "Bet is expired");

    // Don't allow the challenger to accept his own bet
    require(msg.sender != bet.challenger, "You can't challenge yourself");

    // The accepter must deposit his bet
    require(msg.value >= bet.price, "Send same amount of bet price");

    bet.accepter = msg.sender;
    bet.status = 'both';

    // Trigger a log event
    emit LogAcceptBet(_id, bet.challenger, bet.accepter, bet.name, bet.price);

  }


  // Only the referee can resolve bets
  function resolveBet(uint _id, bool challengerWins) refereeOnly public {
    // Retrieve the bet
    Bet storage bet = bets[_id];

    // The bet must not be open
    require(bet.accepter != 0x0, "Bet has to get accepter");

    // The bet must not have been paid out yet
    require(bet.price > 0, "Bet has to get price");

    uint256 prize = bet.price.mul((100 - bet.commission)).div(100);
    // Execute payout
    if (challengerWins) { // challenger wins
      bet.challenger.transfer(bet.price.add(prize));
    } else { // accepter wins
      bet.accepter.transfer(bet.price.add(prize));
    }

    uint256 comission = bet.price.mul(bet.commission).div(100);
    
    referee.transfer(comission);
    // Set the bet status as paid out (price = 0)
    bet.price = 0;
    bet.status = 'paid';

    // Trigger a log event
    emit LogResolveBet(_id, bet.challenger, bet.accepter, bet.name, prize);
  }

  // Only the referee can resolve draft bets
  function draftBet(uint _id) refereeOnly public {
    // Retrieve the bet
    Bet storage bet = bets[_id];

    // The bet must not be open
    require(bet.accepter != 0x0);

    // The bet must not be open
    require(bet.expiration > block.timestamp);

    // The bet must not have been paid out yet
    require(bet.price > 0);

    uint256 comission = bet.price.mul(bet.commission).div(100);
    uint256 betReturn = bet.price.sub(comission.div(2));
    // Execute payout
    bet.challenger.transfer(betReturn);
    bet.accepter.transfer(betReturn);

    
    referee.transfer(comission);
    // Set the bet status as paid out (price = 0)
    bet.price = 0;
    bet.status = 'draft';

    // Trigger a log event
    emit LogResolveBet(_id, bet.challenger, bet.accepter, bet.name, betReturn);
  }

  // Only the referee can resolve bets
  function forceRollbackBet(uint _id) refereeOnly public {
    // Retrieve the bet
    Bet storage bet = bets[_id];

    // The bet must not have been paid out yet
    require(bet.price > 0);

    // Execute payout
    if (bet.challenger != 0x0) {
      bet.challenger.transfer(bet.price);
    }

    if (bet.accepter != 0x0) {
      bet.accepter.transfer(bet.price);
    }

    // Set the bet status as paid out (price = 0)
    bet.price = 0;
    bet.status = 'rollbackForce';
  }

  // User can roll back bets if match starts and dont have accepter
  function rollbackBet(uint _id) public {
    // Retrieve the bet
    Bet storage bet = bets[_id];

    // The bet must be open
    require(bet.accepter == 0x0, "The bet must be open");

    // Rollback only can be done for challenger
    require(bet.challenger == msg.sender, "Rollback only can be done for challenger");

    bet.challenger.transfer(bet.price);

    // Set the bet status as paid out (price = 0)
    bet.price = 0;
    bet.status = 'rollback';
  }


  // Only the referee can terminate this contract
  function terminate() refereeOnly public {

    // Cancel all open bets and return the deposits
    for(uint i = 1; i <= betCounter; i++) {
      if(bets[i].price > 0) { // The bet has not yet been paid out
        if(bets[i].accepter == 0x0) { // The bet has only a challenger. Return ether to him.
          bets[i].challenger.transfer(bets[i].price);
        } else {
          // bet has both a challenger and an accepter, but is not yet resolved. Cancel the bet and return deposits to both.
          bets[i].challenger.transfer(bets[i].price);
          bets[i].accepter.transfer(bets[i].price);
        }
      }
    }

    referee.transfer(address(this).balance);
    selfdestruct(referee);
  }

}

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}

pragma solidity ^0.4.24;

contract RefereeOnly {

  address referee;

  modifier refereeOnly() {
    require(msg.sender == referee, "You are not referee");
    _;
  }

  constructor() public {
    referee = msg.sender;
  }
}