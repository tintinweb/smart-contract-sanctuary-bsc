// This contract does the following
// Gets funds from users
// set a minimum value in usd
// withdraw funds

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    // constant because it doesn't change. so it will no longer take up storage and is more gas efficient
    uint public constant MINIMUM_USD = 50 * 1e18; // 50 USD
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    // immutable variables are set one time, but outside the line they are declared
    // also not stored in storage, but in the bytecode of the contract
    address public immutable i_owner;
    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress) {
        // in this case, msg.sender is whoever is deploying the contract
        // in other words, the owner of the contract
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // the payable keyword makes the function payable
    // this is because contracts can hold funds too, just like accounts
    function fund() public payable {

        // uses gas that won't be returned even if the require below fails
        // minimumUsd = 40 * 1e18; // this assignment is only for demonstration

        // msg.value, used to get the value (in native blockchain currency ETH, BNB etc) the contract is receiving
        // require that the value received is greater than 1eth
        // 1e18 == 1 * 10 ** 18 == 1000000000000000000
        // require(msg.value > 1e18, "Didn't send enough");
        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "Didn't send enough");
        // a ton of computation; // requires gas that will be returned if require fails
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;

        // what is reverting?
        // undoes any action that happened, and sends the remaining gas back
        // in this case, setting number to 5 will be undone
    }

     function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
         funders = new address[](0);

         // actually withdraw the funds
         // the following three different ways exist
         // send and call has a maximum 2300 gas, call forwards all gas
         // call is the reccommended way to send eth or blockchain native token

         // transfer (returns an error if fails, for example due to too much gas used)
         // send the balance in this contract to who ever is calling the contract (most likely the deployer)
         // msg.sender // type address
         // payable(msg.sender) // type payable address. sending native currency only works with payable addresses
        payable(msg.sender).transfer(address(this).balance); // cast msg.sender to payable type

         // send (returns false (boolean) if transaction fails
         bool sendSuccess = payable(msg.sender).send(address(this).balance);
         require(sendSuccess, "Send failed"); // this way we will still revert if transaction fails

         // call // low level used to call any function
         // empty quotes means we are not calling any function
         // if the function call was successful, callSuccess will be true
         // if the function called returns a value, it will be stored in dateRetured
         // using memory since byte objects are arrays
         // because we are not calling a function, we don't need dataReturned
         // (bool callSuccess, byte memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
         (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
         require(callSuccess, "Call failed");
     }

    // keyword that we create, that we can add to a function
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!"); // execute this and any other code
        // alternative to save gas as we don't have to store and emmit the string "Sender is not owner!"
        // note that the error name is self descriptive
        if (msg.sender != i_owner) { revert NotOwner(); }
        _; // then run the code using the modifier
    }

    // what happens if someone sends this contract eth without calling the fund function?

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "./AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        // Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e

        (,int256 price,,,) = priceFeed.latestRoundData();
        // price is in 8 decimal places as can be confirmed from the decimals() function
        // so we're convertint it to 18 decimals to match msg.value
        // also we're converting it to uint256 to match msg.value
        return uint256(price * 1e10); // 1**10
    }

    // bad practice, hardcoding address
    // function getVersion() internal view returns(uint256) {
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    //     return priceFeed.version();
    // }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {
        uint256 ethPrice = getPrice(priceFeed); // 3000_000000000000000000 = ETH / USD Price
        // dividing by 18 because the multiplication results in 36 zeros
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // 1_000000000000000000 ETH
        return ethAmountInUsd;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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