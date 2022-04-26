// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    uint256 public auctionCounter;

    struct AuctionInfo {
        uint256 start;
        uint256 currentMaxBet;
        address winner;
    }

    struct Bet {
        uint256 bet;
        uint256 time;
    }

    // AuctionId => Better => Bet
    mapping(uint256 => mapping(address => Bet)) public bets;
    // AuctionId => AuctionInfo
    mapping(uint256 => AuctionInfo) public auctions;

    event logBidStatus(bool status, uint256 timestamp, address better, uint256 bet);

    /**
     * @notice Sets the initial value of auction counter and auction start time
     * @dev Initial index of auctions is 1
     */
    constructor() {
        auctionCounter = 1;
        auctions[auctionCounter].start = block.timestamp;
    }

    /**
     * @notice Placing a new bet for current auction
     * @dev The new bet must be greater than the current maximum bet value
     * @param better Address of better
     * @param bet Bet value
     */
    function placeBet(address better, uint256 bet) external {
        if (auctions[auctionCounter].currentMaxBet < bet) {
            bets[auctionCounter][better].bet = bet;
            bets[auctionCounter][better].time = block.timestamp;
            auctions[auctionCounter].currentMaxBet = bet;
            auctions[auctionCounter].winner = better;
            emit logBidStatus(true, block.timestamp, better, bet);
        }
        else {
            emit logBidStatus(false, block.timestamp, better, bet);
        }
    }

    /**
     * @notice Viewing the current winner of the auction
     * @return time Timestamp of making a bet
     * @return better Better address
     * @return bet Bet value
     */
    function getWinner() external view returns (uint256 time, address better, uint256 bet) {
        address winner = auctions[auctionCounter].winner;
        return (bets[auctionCounter][winner].time, winner, bets[auctionCounter][winner].bet);
    }

    /**
     * @notice Viewing the current maximum bet value
     * @return maxBet Current maximum bet value
     */
    function getMaxBet() external view returns (uint256 maxBet) {
        return (auctions[auctionCounter].currentMaxBet);
    }

    /**
     * @notice Starting a new auction
     * @dev Increments the value of the auction counter and sets the auction start time
     */
    function startNewAuction() external {
        auctionCounter++;
        auctions[auctionCounter].start = block.timestamp;
    }
}