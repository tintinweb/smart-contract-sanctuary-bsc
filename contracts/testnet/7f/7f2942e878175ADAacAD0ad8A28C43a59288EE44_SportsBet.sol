// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract ATM {

    mapping(address => uint) public balances;

    event Deposit(address sender, uint amount);
    event Withdrawal(address receiver, uint amount);
    event Transfer(address sender, address receiver, uint amount);

    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
        balances[msg.sender] += msg.value;
    }

    function depositBro(uint val) public payable {
        emit Deposit(msg.sender, val*1000000000000000000);
        balances[msg.sender] += val*1000000000000000000;
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        emit Withdrawal(msg.sender, amount);
        balances[msg.sender] -= amount;
    }

    function transfer(address receiver, uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        emit Transfer(msg.sender, receiver, amount);
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
    }

    // In a Batch

    function transfer(address[] memory receivers, uint amount) public {
        require(balances[msg.sender] >= receivers.length * amount, "Insufficient funds");
        for (uint i=0; i<receivers.length; i++) {
            emit Transfer(msg.sender, receivers[i], amount);
            balances[msg.sender] -= amount;
            balances[receivers[i]] += amount;
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
abstract contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
  * @return the address of the owner.
  */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
  * @return true if `msg.sender` is the owner of the contract.
  */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
  * @dev Allows the current owner to relinquish control of the contract.
  * @notice Renouncing to ownership will leave the contract without an owner.
  * It will not be possible to call the functions with the `onlyOwner`
  * modifier anymore.
  */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
  * @dev Transfers control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./Ownable.sol";
import "./ATM.sol";

contract SportsBet is ATM, Ownable {

    struct Bet {
        string name;
        address addr;
        uint amount;
        Team teamBet;
    }

    struct Team {
        string name;
        uint totalBetAmount;
    }

    Bet[] public bets;
    Team[] public teams;

    address payable conOwner;
    uint public totalBetMoney = 0;

    mapping (address => uint) public numBetsAddress;

    event NewBet(address addr, uint amount, Team team);

    constructor() payable {
        conOwner = payable(msg.sender); //setting the contract creator
        // teams.push(Team("team1", 0));
        // teams.push(Team("team2", 0));
    }

    //Create Teams for bet
    function createTeam(string memory _name) public {
        teams.push(Team(_name, 0));
    }

    function getTotalBetAmount(uint _teamId) public view returns (uint) {
        return teams[_teamId].totalBetAmount;
    }

    function getTeams() public view returns (Team[] memory) {
        return teams;
    }

    function getBets() public view returns (Bet[] memory) {
        return bets;
    }

    function createBet(string memory _name, uint _teamId) external payable {
        require(msg.sender != conOwner, "Owner can't make a bet");
        require(
            msg.value > 0,
            "minimum amount needed to play the game"
        );
        require (numBetsAddress[msg.sender] == 0, "You have already placed a bet");
        require (msg.value > 0.001 ether, "Bet more");
    
        bets.push(Bet(_name, msg.sender, msg.value, teams[_teamId]));

        if (_teamId == 0) {
            teams[0].totalBetAmount += msg.value;
        } 
        if (_teamId == 1) {
            teams[1].totalBetAmount += msg.value;
        }

        numBetsAddress[msg.sender]++;

        (bool sent, bytes memory data) = conOwner.call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        totalBetMoney += msg.value;

        emit NewBet(msg.sender, msg.value, teams[_teamId]);

    }

    function winDistribution(uint _teamId) public payable onlyOwner() {

        deposit();
        uint div;

        if (_teamId == 0) {
            for (uint i = 0; i < bets.length; i++) {
                if (keccak256(abi.encodePacked((bets[i].teamBet.name))) == keccak256(abi.encodePacked("team1"))) {
                    address payable receiver = payable(bets[i].addr);
                    div = (bets[i].amount * (10000 + (getTotalBetAmount(1) * 10000 / getTotalBetAmount(0)))) / 10000;

                    (bool sent, bytes memory data) = receiver.call{ value: div }("");
                    require(sent, "Failed to send Ether");

                }
            }
        } else {
            for (uint i = 0; i < bets.length; i++) {
                if (keccak256(abi.encodePacked((bets[i].teamBet.name))) == keccak256(abi.encodePacked("team2"))) {
                    address payable receiver = payable(bets[i].addr);
                    div = (bets[i].amount * (10000 + (getTotalBetAmount(0) * 10000 / getTotalBetAmount(1)))) / 10000;

                    (bool sent, bytes memory data) = receiver.call{ value: div }("");
                    require(sent, "Failed to send Ether");
                }
            }
        }

        totalBetMoney = 0;
        teams[0].totalBetAmount = 0;
        teams[1].totalBetAmount = 0;

        for (uint i = 0; i < bets.length; i++) {
            numBetsAddress[bets[i].addr] = 0;
        }
    }
}