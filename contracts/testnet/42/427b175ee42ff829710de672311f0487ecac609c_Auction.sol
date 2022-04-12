/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC721{
    function transfer(address, uint) external; //It takes a specific address on to which we need to transfer an NFT, and the NFT_ID.
    function transferFrom(address, address, uint) external; //sender, receiver, NFT_ID
}

contract Auction {
    //STATE VARIABLES.
    address payable public seller;
    uint public finalBid;
    address public finalBidder;
    mapping(address => uint) public bids;

    IERC721 public nft; //Defining the NFT that we're auctioning.
    uint public nftId;    

    constructor () 
    {
        seller = payable(msg.sender);
    }
    
    //EVENTS.
    event Withdraw(address indexed bidder, uint amount);
    
    
    
    //FUNCTIONS.

    //This start() takes as input, the contract address of the NFT, the NFT_ID and the starting bid.
    function start(IERC721 _nft, uint _nftId, uint BidAmount) external 
    {
        require(msg.sender == seller, "You did not start the auction!");
        finalBid = BidAmount;

        nft = _nft;
        nftId = _nftId;
        
        nft.transferFrom(msg.sender, address(this), nftId); //we're transfering nft from msg.sender to  this auction contract.

        
    }

    
    function withdraw() external payable 
    {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        
        (bool sent, bytes memory data) = payable(msg.sender).call{value: bal}("");
        require(sent, "Could not withdraw");
        
        emit Withdraw(msg.sender, bal);
    }

    
}