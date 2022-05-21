/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract BlindAuction{
    struct Bid{
        bytes32 blindedBid;
        uint deposit;
    }

    bool public ended;
    uint public biddingEnd;
    uint public revealEnd;
    
    uint public highestBid;
    address public highestBidder;
    address payable public beneficiary;
    
    mapping(address => Bid[]) public bids;
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner,uint highestBid);

    error TooEarly(uint time);
    error TooLate(uint time);
    error AuctionEndAlreadyCalled();

    modifier onlyBefore(uint time){
        if(block.timestamp >= time) revert TooLate(time);
        _;
    }
    modifier onlyAfter(uint time){
        if(block.timestamp <= time) revert TooEarly(time);
        _;
    }

    constructor(
        uint biddingTime,
        uint revealTime,
        address payable beneficiaryAddress
    ){
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealTime;
    }

    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd){
        bids[msg.sender].push(Bid({
            blindedBid : blindedBid,
            deposit: msg.value
        }));
    }

    function reveal(
        uint[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    ) external onlyAfter(biddingEnd) onlyBefore(revealEnd){
        uint length = bids[msg.sender].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        uint refund;
        for(uint i = 0;i < length;i++){
            
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint value,bool fake,bytes32 secret) = (values[i],fakes[i],secrets[i]);
            if(bidToCheck.blindedBid != keccak256(abi.encodePacked(value,fake,secret))){
                continue;
            }

            refund += bidToCheck.deposit;
            if(!fake && bidToCheck.deposit >= value){
                if(placeBid(msg.sender,value)){
                    refund -= value;
                }
            }
            bidToCheck.blindedBid = bytes32(0);
        }
        payable(msg.sender).transfer(refund);
    }

    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            payable(msg.sender).transfer(amount);
        }
    }

    function auctionEnd() external onlyAfter(revealEnd){
        if(ended)
            revert AuctionEndAlreadyCalled();
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

    function placeBid(address bidder,uint value) internal returns (bool success){
        if(value <= highestBid){
            return false;
        }
        if(highestBidder != address(0)){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    function calculate(
        uint value,
        bool fake,
        bytes32 secret
    ) external pure returns (bytes32){
        return keccak256(abi.encodePacked(value,fake,secret));
    }
}