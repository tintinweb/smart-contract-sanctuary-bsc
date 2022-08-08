// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Include.sol";

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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


contract PriceAndRate is Configurable {

    mapping(address => address) public priceFeeds; //token => Aggregrator  (token  => EACAggregatorProxy)
    mapping(bytes32 => uint) public rates;   //currency => rate  
    mapping(address => bool)  public dataUsers; //feedData

    function __PriceAndRate_init(address governor_) public initializer {
        __Governable_init_unchained(governor_);
        
        __PriceAndRate_init_unchained();
    }

    function __PriceAndRate_init_unchained() internal governance initializer{
        //eth-usd  0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c => 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e
        //busd-usd 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 => 0xcBb98864Ef56E9042e7d2efef76141f15731B82f
        //usdt-usd 0x55d398326f99059fF775485246999027B3197955 => 0xB97Ad0E74fa7d920791E90258A6E2085088b4320
        //usdc-usd 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d => 0x51597f405303C4377E36123cBc172b13269EA163
        priceFeeds[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e;
        priceFeeds[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = 0xcBb98864Ef56E9042e7d2efef76141f15731B82f;
        priceFeeds[0x55d398326f99059fF775485246999027B3197955] = 0xB97Ad0E74fa7d920791E90258A6E2085088b4320;
        priceFeeds[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = 0x51597f405303C4377E36123cBc172b13269EA163;
    }



    function setDataUser(address[] calldata users,bool[] calldata isDataUsers) public governance {
        require(users.length == isDataUsers.length,"len unequal");
        for(uint i=0;i<users.length;i++){
            dataUsers[users[i]] = isDataUsers[i];
        }
        emit SetDataUser(msg.sender,users,isDataUsers);
    }
    event SetDataUser(address setAccount,address[] users,bool[] isDataUsers);

    function setAggregrator(address[] calldata token_,address[] calldata aggrs) public {
        require(dataUsers[msg.sender],"Not data user");
        require(token_.length == aggrs.length,"len unequal");
        for(uint i=0;i<token_.length;i++){
            priceFeeds[token_[i]] = aggrs[i];
        }
        emit SetAggregrator(msg.sender,token_,aggrs);
    }

    event SetAggregrator(address setAccount,address[] token_,address[] aggrs);

    function setRates(bytes32[] calldata currencys,uint[] calldata rates_) public {
        require(dataUsers[msg.sender],"Not data user");
        require(currencys.length == rates_.length,"len unequal");
        for (uint i=0;i<currencys.length;i++){
            rates[currencys[i]] = rates_[i];
        }
        emit SetRates(msg.sender,currencys,rates_);
    }
    event SetRates(address setAccount,bytes32[]  currencys,uint[]  rates_);

    function getPrice(address token) public view returns (uint price,uint8 decimals) {
        address aggr = priceFeeds[token];
        if (aggr == address(0))
            return (0,0);
        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggr);
        (
            /*uint80 roundID*/,
            int price1,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        price = uint(price1);
        decimals = priceFeed.decimals();
    }

    function getRate(bytes32 currency) public view returns (uint rate){
        return rates[currency];

    }

    function getPriceAndRate(address token,bytes32 currency) public view returns (uint price,uint8 decimals,uint rate){
        (price,decimals) = getPrice(token);
        rate = getRate(currency);
    }

}