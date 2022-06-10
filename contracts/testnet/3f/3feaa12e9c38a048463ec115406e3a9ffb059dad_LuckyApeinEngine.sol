/**
 *Submitted for verification at BscScan.com on 2022-06-09
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

// File: contracts/Lottery.sol



pragma solidity ^0.8.14;


contract LuckyApeinEngine {
    AggregatorV3Interface internal priceFeedOne;
    AggregatorV3Interface internal priceFeedTwo;

    address payable public owner;
    address payable[] public players;
    address payable investorRewardPool;

    constructor() {
            priceFeedOne = AggregatorV3Interface(0x0630521aC362bc7A19a4eE44b57cE72Ea34AD01c); // DAI/BNB Pricefeed for BSC Testnet
            priceFeedTwo = AggregatorV3Interface(0x1a602D4928faF0A153A520f58B332f9CAFF320f7); // BTC/ETH Pricefeed for BSC Testnet
            investorRewardPool = payable(0x955992F6C5e844f646727A05fAE1854319ADBa73); // The address of the reward pool contract -- NEEDS TO BE UPDATED
            owner = payable(msg.sender);
        }

    event participantEntry(address participant, uint amount, uint time);
    event rewardTransfer(address to, uint amount, uint time);

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function enter() public payable {
        require(msg.value >= uint(getLatestPriceOne()), "The amount should be at least one dollar");

        if (msg.value >= uint(getLatestPriceOne()) * 2) {
            for (uint i = 0; i < (uint(msg.value) / uint(getLatestPriceOne())); i++) {
                players.push(payable(msg.sender)); // give the participants as many tickets as much money they invested
                emit participantEntry(msg.sender, msg.value, block.timestamp);
            }
        } else {
            players.push(payable(msg.sender)); // give the participant a ticket
            emit participantEntry(msg.sender, msg.value, block.timestamp);
        }
        
    }

    function payWinner() public {
        require(msg.sender == owner, "Only owner can trigger the payout");
        uint index = getRandomNumber() % players.length;

        // transfer the rewards        
        uint prize = ((address(this).balance * 9100) / 10000); // 91% of the total pool
        uint ownerReward = ((address(this).balance * 200) / 10000); // 2% of the total pool
        uint investorReward = (address(this).balance - prize - ownerReward); // 7% of the total pool

        players[index].transfer(prize); // transfer the prize to the winner
        owner.transfer(ownerReward); // transfer owner reward to the owners
        investorRewardPool.transfer(investorReward); // transfer investor reward to the investor pool

        emit rewardTransfer(players[index], prize, block.timestamp);
        emit rewardTransfer(owner, ownerReward, block.timestamp);
        emit rewardTransfer(investorRewardPool, investorReward, block.timestamp);
        
        // reset the state of the contract
        players = new address payable[](0);
    }

    function getRandomNumber() internal view returns (uint) {
        require(msg.sender == owner);
        return uint(keccak256(abi.encodePacked(getLatestPriceTwo(), block.timestamp, players.length)));
    }

    // this function gets the latest price to determine the minimum for joining
    function getLatestPriceOne() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeedOne.latestRoundData();
        return price;
    }

    function getLatestPriceTwo() internal view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeedTwo.latestRoundData();
        return price;
    }
}