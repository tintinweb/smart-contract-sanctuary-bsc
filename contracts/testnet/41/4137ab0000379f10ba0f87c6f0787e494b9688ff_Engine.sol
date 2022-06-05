/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: contracts/Combined.sol



pragma solidity ^0.8.14;


contract Engine {
    AggregatorV3Interface internal priceFeed;

    address payable public owner;
    address payable[] public players;
    uint public roundId;
    mapping (uint => address payable) public roundHistory;

    constructor() {
            priceFeed = AggregatorV3Interface(0x0630521aC362bc7A19a4eE44b57cE72Ea34AD01c); // DAI/BNB Pricefeed for BSC Testnet
            owner = payable(msg.sender);
            roundId = 1;
        }

    event participantEntry(address participant, uint amount, uint time);
    event prizeTransfer(address winner, uint amount, uint time);
    event remainingContractFuel(uint remainingFuel);

    function getWinnerByRound(uint round) public view returns (address payable) {
        return roundHistory[round];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function enter() public payable {
        require(msg.value >= uint(getLatestPrice()), "the amount should be one dollar");
        require(msg.value < uint(2 * getLatestPrice()), "no more than one dollar");

        players.push(payable(msg.sender)); // record the participant
        
        emit participantEntry(msg.sender, msg.value, block.timestamp);
    }

    function payWinner() public {
        require(msg.sender == owner);
        uint index = getRandomNumber() % players.length;

        // transfer the winner the prize and the owner the fee
        uint prize = ((address(this).balance * 9600) / 10000); // 96% of the reward
        uint fee = address(this).balance - prize; // 4% of the reward basis

        players[index].transfer(prize); // transfer the reward to the winner
        owner.transfer(fee); // transfer the fee to the owner

        emit prizeTransfer(players[index], prize, block.timestamp);
        
        roundHistory[roundId] = players[index];
        roundId += 1;
        
        // reset the state of the contract
        players = new address payable[](0);
    }

    function getRandomNumber() public view returns (uint) {
        require(msg.sender == owner);
        return uint(keccak256(abi.encodePacked(owner, block.timestamp, players.length)));
    }

    // this function gets the latest price to determine the minimum for joining
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}