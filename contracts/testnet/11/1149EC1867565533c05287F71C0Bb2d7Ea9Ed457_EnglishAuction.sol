// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract EnglishAuction is Auction {
    uint256 public initialPrice;
    uint256 public biddingPeriod;
    uint256 public minimumPriceIncrement;

    // TODO: place your code here
    uint256 public currentHighestBid;
    uint256 public biddingWindow;
    address public currentWinner;
    mapping(address => uint256) public bids;

    // constructor
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        address _timerAddress,
        uint256 _initialPrice,
        uint256 _biddingPeriod,
        uint256 _minimumPriceIncrement
    ) Auction(_sellerAddress, _judgeAddress, _timerAddress) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        // TODO: place your code here
        currentHighestBid = initialPrice;
        biddingWindow = time() + biddingPeriod;
    }

    function bid() public payable {
        require(time() < biddingWindow, "Auction is closed");
        if (currentWinner == address(0))
            require(
                currentHighestBid <= msg.value,
                "Bid must be higher than current highest bid"
            );
        else {
            require(
                (currentHighestBid + minimumPriceIncrement) <= msg.value,
                "Bid must be higher than current highest bid plus increment"
            );
            uint256 refund = bids[currentWinner];
            bids[currentWinner] = 0;
            balances[currentWinner] += refund;
        }
        currentWinner = msg.sender;
        biddingWindow = (time() + biddingPeriod);
        currentHighestBid = msg.value;
        bids[msg.sender] += msg.value;
        winningPrice = currentHighestBid;
    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner) {
        if (biddingWindow <= time()){
            winner = currentWinner;
            return winner;}
        return winnerAddress;
    }
}