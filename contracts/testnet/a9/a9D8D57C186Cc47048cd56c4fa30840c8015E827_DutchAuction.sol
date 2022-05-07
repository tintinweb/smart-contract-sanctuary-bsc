// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;
    
    // TODO: place your code here

    uint public startTime;
    uint public endTime;
    uint public reservedPrice;

    event debug(uint256 currentPrice);
    event debugBig(uint256 bidValue);

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;

        // TODO: place your code here

        startTime = time();
        endTime = time() + biddingPeriod;
        reservedPrice = initialPrice - biddingPeriod * offerPriceDecrement;

    }


    function bid() public payable{
        // TODO: place your code here
        uint currentPrice = initialPrice - (time() - startTime) * offerPriceDecrement;
        require (  msg.value >= reservedPrice
                && msg.value >= currentPrice
                && time() < endTime
                && getWinner() == address(0));

        winnerAddress = msg.sender;
        uint refund = address(this).balance - currentPrice;
        payable(getWinner()).transfer(refund);

    }

}