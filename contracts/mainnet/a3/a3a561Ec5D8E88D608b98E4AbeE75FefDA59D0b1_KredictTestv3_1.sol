/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
contract KredictTestv3_1 {
    address public owner;
    uint minBidAmount;
    uint maxBidAmount;
    uint rewardClaimWaitPeriod;
    enum BidResult {
        Win,
        Lose
    }
    enum Position {
        Up,
        Down
    }
    struct Round {
        uint roundID;
        address player;
        uint bidAmount;
        uint lockedPrice;
        uint closedPrice;
        uint rewardAmount;
        bool rewardClaimed;
        bool claimable;
        uint resultTime;
        BidResult bidResult;
        Position bidPosition; 
        uint bidTimestamp;
    }
    mapping(address => Round[]) public players;
    event BidUp (address addr, uint bidAmount, Position position);
    event BidDown (address addr, uint bidAmount, Position position);
    event Claimed (address addr, uint claimedAmount);
    constructor() {
        owner = payable(msg.sender);
        minBidAmount = 1000000000000000; // 0.01 BNB
        maxBidAmount = 200000000000000000; // 0.2 BNB
        rewardClaimWaitPeriod = 3600; // 3600 seconds = 1 hour
    }
    receive() payable external{
        }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    function balanceOf() public view returns(uint){
        return address(this).balance;
    }
    function bidUp(uint _roundID, uint _lockedPrice) external payable {
        require(msg.value >= minBidAmount, "Bid Amount is less than minBidAmount");
        require(msg.value <= maxBidAmount, "Bid Amount is more than maxBidAmount");
        Round memory round;
        round.roundID = _roundID;
        round.player = msg.sender;
        round.bidAmount = msg.value;
        round.bidPosition = Position.Up;
        round.lockedPrice = _lockedPrice;
        round.rewardAmount = 0;
        round.rewardClaimed = false;
        round.claimable = false;
        round.bidTimestamp = block.timestamp;
        players[msg.sender].push(round);
        emit BidUp(msg.sender, msg.value, Position.Up);
    }
    function bidDown(uint _roundID, uint _lockedPrice) external payable {
        require(msg.value >= minBidAmount, "Bid Amount is less than minBidAmount");
        require(msg.value <= maxBidAmount, "Bid Amount is more than maxBidAmount");
        Round memory round;
        round.roundID = _roundID;
        round.player = msg.sender;
        round.bidAmount = msg.value;
        round.bidPosition = Position.Down;
        round.lockedPrice = _lockedPrice;
        round.rewardAmount = 0;
        round.rewardClaimed = false;
        round.claimable = false;
        round.bidTimestamp = block.timestamp;
        players[msg.sender].push(round);
        emit BidDown(msg.sender, msg.value, Position.Down);
    }
    function result(uint _roundID, uint _closedPrice) external returns(bool) {
        for(uint i = 0; i<players[msg.sender].length; i++){
            if (players[msg.sender][i].roundID == _roundID) {
                require(players[msg.sender][i].rewardClaimed == false);
                players[msg.sender][i].closedPrice = _closedPrice;
                players[msg.sender][i].resultTime = block.timestamp;
                if (players[msg.sender][i].bidPosition == Position.Up) {
                    if (players[msg.sender][i].closedPrice > (players[msg.sender][i].lockedPrice + (0.1 * 100))) {
                        players[msg.sender][i].bidResult = BidResult.Win;
                        players[msg.sender][i].rewardAmount = players[msg.sender][i].bidAmount * 2;
                        players[msg.sender][i].claimable = true;
                        return true;
                    }
                    else {
                        players[msg.sender][i].bidResult = BidResult.Lose;
                        players[msg.sender][i].rewardAmount = 0;
                        players[msg.sender][i].claimable = false;
                        return false;
                    }
                }
                else if(players[msg.sender][i].bidPosition == Position.Down) {
                    if (players[msg.sender][i].closedPrice < (players[msg.sender][i].lockedPrice - (0.1 * 100))) {
                        players[msg.sender][i].bidResult = BidResult.Win;
                        players[msg.sender][i].rewardAmount = players[msg.sender][i].bidAmount * 2;
                        players[msg.sender][i].claimable = true;
                        return true;
                    }
                    else {
                        players[msg.sender][i].bidResult = BidResult.Lose;
                        players[msg.sender][i].rewardAmount = 0;
                        players[msg.sender][i].claimable = false;
                        return false;
                    }
                }
            }
        }
        return false;
    }
    function claim() external {
        uint totalReward = 0;
        for(uint i = 0; i<players[msg.sender].length; i++){
            if (players[msg.sender][i].rewardAmount > 0 && players[msg.sender][i].rewardClaimed == false) {
                uint timeDiffer;
                if (players[msg.sender][i].resultTime > players[msg.sender][i].bidTimestamp){
                    timeDiffer = players[msg.sender][i].resultTime - players[msg.sender][i].bidTimestamp;
                }
                else {
                    timeDiffer = players[msg.sender][i].bidTimestamp - players[msg.sender][i].resultTime;
                }
                if(timeDiffer < rewardClaimWaitPeriod){
                    totalReward += players[msg.sender][i].rewardAmount;
                }
                players[msg.sender][i].rewardAmount = 0;
            }
        }
        require(totalReward > 0);
        require(totalReward < address(this).balance);
        (bool success,) = msg.sender.call{value: totalReward}("");
        require(success, "Claim Failed!");
        emit Claimed(msg.sender, totalReward);
    }
    function collectOwnableAmount() external onlyOwner{
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Collection Failed");
    }
}