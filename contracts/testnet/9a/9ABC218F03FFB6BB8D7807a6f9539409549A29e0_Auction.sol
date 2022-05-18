/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;
interface IERC721 {
    function transfer(address, uint) external;
    function transferFrom(address,address,uint) external;
}

contract Auction{
    event Start();
    event End(address highestBidder, uint highestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    address payable public seller;
    bool public started;
    bool public ended;
    uint public endAt;
    uint public startAt;
    IERC721 public nft;
    uint public nftId;
    uint public highestBid;
    address payable public highestBidder;
    mapping(address => uint) public bids;
    address payable owner;
    constructor () {
        owner = payable(msg.sender);
    }

    function start(IERC721 _nft, uint _nftId, uint startingBid) external {
        require(!started, "Already started!");
        require(msg.sender == seller, "You did not start the auction!");
        highestBid = startingBid;
        nft = _nft;
        nftId = _nftId;
        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = startAt + 2 days;
        emit Start();
    }
    function bid() external payable {
        require(started, "Not started.");
        require(block.timestamp < endAt, "Ended!");
        require(msg.value > highestBid);
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = payable(msg.sender);
        emit Bid(highestBidder, highestBid);
    }
    function withdraw() external payable {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool sent, bytes memory data) = payable(msg.sender).call{value: bal}("");
        require(sent, "Could not withdraw");
        emit Withdraw(msg.sender, bal);
    }
    function end() external {
        require(started, "You need to start first!");
        require(block.timestamp >= endAt, "Auction is still ongoing!");
        require(!ended, "Auction already ended!");
        if (highestBidder != address(0)) {
            nft.transfer(highestBidder, nftId);
            (bool sent, bytes memory data) = seller.call{value: highestBid}("");
            require(sent, "Could not pay seller!");
        } else {
            nft.transfer(seller, nftId);
        }
        ended = true;
        emit End(highestBidder, highestBid);
    }
}