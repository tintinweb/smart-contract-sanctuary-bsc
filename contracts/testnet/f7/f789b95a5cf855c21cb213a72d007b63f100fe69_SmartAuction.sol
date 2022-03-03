/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract SmartAuction {
    address public beneficiary;
    uint256 public auctionEnd;

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) pendingReturns;

    bool ended;

    event HighestBidIncreasedEvent(address bidder, uint256 amount);
    event AuctionEndedEvent(address winner, uint256 amount);

    constructor(uint256 _biddingTime) {
        beneficiary = msg.sender;
        auctionEnd = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        require(block.timestamp <= auctionEnd, "Action alreaady over.");
        require(msg.value > highestBid, "There is already a higher bid.");
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit HighestBidIncreasedEvent(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];

        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function end() public {
        require(block.timestamp >= auctionEnd, "Auction not yet ended");
        require(!ended, "auctionEnd was called");

        ended = true;

        payable(beneficiary).transfer(highestBid);
        emit AuctionEndedEvent(highestBidder, highestBid);
    }

    function auctionAlreadyEnded() public view returns (bool) {
        return ended;
    }
}