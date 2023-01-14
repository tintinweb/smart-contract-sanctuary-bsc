/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface Aggregator {
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

contract tester{
       uint256 tokenInOneUsdt=50;
       Aggregator internal aggregatorInterface;
       constructor(){
            aggregatorInterface = Aggregator(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
       }

           function usdtToBNB(uint256 _usdt) public view returns(uint256){
           uint256 usdt=_usdt*10**18;
          uint256 amountInBNB=usdt / getLatestPrice();
          return amountInBNB;
    }

    function usdtToToken(uint256 _usdt) public view returns(uint256){
        
                uint256 amountOfToken=(_usdt * tokenInOneUsdt);
                amountOfToken=amountOfToken * 10**12;
                return amountOfToken;
    }
        /**
     * @dev To get latest BNB price in 10**8 format
     */
    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = aggregatorInterface.latestRoundData();
        return uint256(price);
    }
}