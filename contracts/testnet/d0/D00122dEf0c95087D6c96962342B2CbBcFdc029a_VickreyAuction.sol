// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract VickreyAuction is Auction {
    uint256 public minimumPrice;
    uint256 public biddingDeadline;
    uint256 public revealDeadline;
    uint256 public bidDepositAmount;

    // TODO: place your code here
    uint256 public highestBid = 0;
    uint256 public secondHighestBid = 0;
    address public highestBidder;
    mapping(address => bytes32) public commitments;
    mapping(address => uint256) public bids;

    // constructor
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        address _timerAddress,
        uint256 _minimumPrice,
        uint256 _biddingPeriod,
        uint256 _revealPeriod,
        uint256 _bidDepositAmount
    ) Auction(_sellerAddress, _judgeAddress, _timerAddress) {
        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;

        // TODO: place your code here
    }

    // Record the player's bid commitment
    // Make sure exactly bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable {
        require(time() < biddingDeadline, "bidding closed");
        if (commitments[msg.sender] == bytes32(0))
            require(msg.value == bidDepositAmount);
        else require(msg.value == 0, "you already deposited");
        commitments[msg.sender] = bidCommitment;
        bids[msg.sender] += msg.value;
    }

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(bytes32 nonce)
        public
        payable
        returns (bool isHighestBidder)
    {
        require(biddingDeadline < time(), "bidding still active");
        require(time() < revealDeadline, "reavel period expired");
        require(bids[msg.sender] != 0, "can only reveal once");
        require(msg.sender != highestBidder, "can only reveal once");
        require(
            commitments[msg.sender] ==
                keccak256(abi.encodePacked(msg.value, nonce))
        );
        if (highestBid < msg.value) // highest bidder
        {
            uint256 refund = bids[highestBidder];
            if (highestBid == 0) secondHighestBid = refund;
            else secondHighestBid = refund - bidDepositAmount;
            bids[highestBidder] = 0;
            balances[highestBidder] += refund;
            highestBid = msg.value;
            highestBidder = msg.sender;
            bids[msg.sender] += msg.value;
            isHighestBidder = true;
        } else {
            if (secondHighestBid < msg.value) secondHighestBid = msg.value;
            uint256 refund = bids[msg.sender];
            bids[msg.sender] = 0;
            balances[msg.sender] += refund;
            balances[msg.sender] += msg.value;
            isHighestBidder = false;
        }
    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){
        if (time() <= revealDeadline) winner = highestBidder;
        return winner;
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public override {
        // TODO: place your code here
        winnerAddress = highestBidder;
        if (secondHighestBid == 0) winningPrice = minimumPrice;
        else winningPrice = secondHighestBid;
        uint256 refund = bids[highestBidder] - winningPrice;
        bids[highestBidder] = 0;
        balances[highestBidder] += refund;
        // call the general finalize() logic
        super.finalize();
    }
}