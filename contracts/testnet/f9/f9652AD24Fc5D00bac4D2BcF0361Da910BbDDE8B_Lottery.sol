pragma solidity 0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    uint256 start_timestamp;
    uint256 start_price;
    uint256 finish_price;
    uint256 finish_timestamp;
    
    mapping(address => uint) bet_amount;
    mapping(address => bool) bet_info;
    address [] bets;

    uint fee = 30;
    
    uint bet_up_total;
    uint bet_down_total;
    address admin = 0x449713a131320f7685f9Afac321655cbC0193a2d;
    bool round_status;

    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    }    

    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

    function getLatestPrice() public view returns (uint256) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

   function start() external onlyOwner {
       require(round_status == false, "another betting is already started");

        round_status = true;
        start_price = getLatestPrice();
        start_timestamp = block.timestamp;
    }

    function finish() external onlyOwner {
        require(round_status == true, "betting not started");
        require(start_timestamp + 10 minutes < block.timestamp, "Not 10min yet");
        // if(start_timestamp + 11 >= now()){
        //     round_status = status.cancaled;
        //     return;
        // }
        finish_price = getLatestPrice();
        finish_timestamp = block.timestamp;
        round_status = false;

        claim();
    }
    function bet_up() payable external {
        require(bet_amount[msg.sender] == 0, "already commited!!");
        bet_amount[msg.sender] = msg.value;
        bet_info[msg.sender] = true;
        bets.push(msg.sender);
        bet_up_total += msg.value;
    }
    function bet_down() payable external {
        require(bet_amount[msg.sender] == 0, "already commited!!");
        bet_amount[msg.sender] = msg.value;
        bet_info[msg.sender] = false;
        bets.push(msg.sender);
        bet_down_total += msg.value;
    }
    function claim() internal {
        require(round_status == false, "betting not finished!!!");
        // if(bet_info[] != start_price){
        //     amount = bet_amount[msg.sendar];
        // }
        // if(bet_info[msg.sender] == true){
        //     revwrd(amount / bet_up_total) * (bet_up_info + bet_down_total) * (1 - fee);
        // } else BNB.transfer(address msg.sender, uint reward)

        for (uint256 i = 0; i < bets.length; i++) {
            // bets[i], bet_amount[bets[i]], bet_info[bets[i]]
            address recipient = bets[i];
            uint256 amount = bet_amount[recipient];
            uint256 reward;

            if ( bet_info[bets[i]] ) {  // up
                reward = (amount / bet_up_total) * (bet_up_total + bet_down_total) * (100 - fee) / 100;
            } else {    // down
                reward = (amount / bet_down_total) * (bet_up_total + bet_down_total) * (100 - fee) / 100;
            }

            payable(recipient).transfer(reward);
        }
    }
}

// SPDX-License-Identifier: MIT
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