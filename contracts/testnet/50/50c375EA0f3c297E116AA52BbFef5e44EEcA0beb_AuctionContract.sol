// SPDX-License-Identifier: MIT


pragma solidity ^0.8.4;

import "./Xverse721.sol";



contract AuctionContract{

    //current auction number
    uint256 public auctionCounter;
   // uint256 public temp;
    


    //mapping each token with Auction
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => Auction_new) public auctions2;
    //mapping auction-id with minbid
   // mapping(uint256 => minimumbid) public minbid;
    mapping(uint256 => uint256) public minbids;



    

    //maping each auction id with mapping of pending returns;
    mapping(uint256 => mapping(address => uint256)) public pendingReturns;
    mapping(uint256 => mapping(address => uint256)) public pendingReturns_new;




    //mapping each auction id with highest bidder
    mapping(uint256 => Bidder) public highestBidder;
    mapping(uint256 => Bidder) public highestBidder_new;



    //mapping each auction id with winners
    mapping(uint256 => address) public winners;


    uint256 public adminFeesCollected;


    uint256 public adminFeePercentage;


    address  public adminAccount;
   


    struct Bidder{
        address currentHighestBidder;
        uint256 currentHighestBid;
    }
    
    struct Auction{
        uint256 auctionId;
        address beneficiary;
        bool ended;
        uint256 auctionEndTime;
    }
    struct Auction_new{
        uint256 auctionId;
        address beneficiary;
        bool ended;
        uint256 auctionStarttime;
        uint256 auctionEndTime;
        
    }



    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    event HighestBidIncrease_new(address bidder, uint amount);
    event AuctionEnded_new(address winner, uint amount);

    constructor(uint256 _adminFeePercentage){
        auctionCounter = 1;
        adminAccount = msg.sender;
        adminFeePercentage = _adminFeePercentage;
    }


    function transferAdminAccount(address _newAdmin) public {
        require(msg.sender == adminAccount, "Access denied");
        adminAccount = _newAdmin;
    }

    function setAdminFee (uint256 _newAdminFeePercentage) public {
        require(msg.sender == adminAccount, "Access denied");
        adminFeePercentage = _newAdminFeePercentage;
        
    }
    function createNewAuction(uint256 _starttime, uint256 _tokenId2, address cAddress, uint256 _endtime, uint256 _minbid) public 
    { 
         ERC721 token = ERC721(cAddress);
        require(token.ownerOf(_tokenId2) == msg.sender, "Only token owner can create auctions");
        require(token.getApproved(_tokenId2) == address(this), "contract must be approved");
        auctions2[_tokenId2] = Auction_new(auctionCounter,msg.sender,false,block.timestamp + _starttime, block.timestamp + _endtime);
        auctionCounter += 1; 
       // minbid=_minbid;
       minbids[_tokenId2]= _minbid;
        
        
    
    }
    
    function createAuction(uint256 _biddingTime, uint256 _tokenId, address contractAddress ) public{
        ERC721 token = ERC721(contractAddress);
        require(token.ownerOf(_tokenId) == msg.sender, "Only token owner can create auctions");
        require(token.getApproved(_tokenId) == address(this), "contract must be approved");
        auctions[_tokenId] = Auction(auctionCounter,msg.sender,false,block.timestamp + _biddingTime);
        auctionCounter += 1;
    }


    function cancelAuction(uint256 _tokenId, address contractAddress) public {
        ERC721 token = ERC721(contractAddress);
        require(token.ownerOf(_tokenId) == msg.sender, "Only token owner can cancel auctions");
        auctions[_tokenId].ended = true;
    }




    function bid(uint256 _tokenId) public payable
   
    {

  
        Auction memory _auction = auctions[_tokenId];
 
        require(auctions[_tokenId].ended != true , "auction has ended already");

        

        if(block.timestamp > _auction.auctionEndTime){
            revert("The auction has already ended");
        }
   
        pendingReturns[_auction.auctionId][msg.sender] = msg.value;
        highestBidder[_auction.auctionId] = Bidder(msg.sender,msg.value);
        emit HighestBidIncrease(msg.sender,msg.value);

    }
    function bid_new(uint256 _tokenId) public payable
   
    {

  
        Auction_new memory _auction = auctions2[_tokenId];
 
        require(auctions2[_tokenId].ended != true , "auction has ended already");
        
        if(block.timestamp <= _auction.auctionStarttime )
        {
            revert("The auction hasnt started");
        }

        if( block.timestamp >= _auction.auctionEndTime)
        {
            revert("The auction has already ended");
        }
        uint256 temp = minbids[_tokenId] + minbids[_tokenId]* 1/100;
        
         require (msg.value <= temp, "place a high bid");
        pendingReturns_new[_auction.auctionId][msg.sender] = msg.value;
        highestBidder_new[_auction.auctionId] = Bidder(msg.sender,msg.value);
        emit HighestBidIncrease_new(msg.sender,msg.value);
        minbids[_tokenId]= msg.value;

    }

    function withdraw(uint256 _tokenId) public returns(bool){
        Auction memory _auction = auctions[_tokenId];
        uint256 amount = pendingReturns[_auction.auctionId][msg.sender];
        require(amount > 0 , "No pending returns");

        if(amount > 0){
            
             if(payable(msg.sender).send(amount)){
                  pendingReturns[_auction.auctionId][msg.sender] = 0;

                  return true;
             }
        }
        return false;
    }
        function withdraw_new(uint256 _tokenId) public returns(bool){
        Auction_new memory _auction = auctions2[_tokenId];
        uint256 amount = pendingReturns_new[_auction.auctionId][msg.sender];
        require(amount > 0 , "No pending returns");

        if(amount > 0){
            
             if(payable(msg.sender).send(amount)){
                  pendingReturns_new[_auction.auctionId][msg.sender] = 0;

                  return true;
             }
        }
        return false;
    }


    function auctionEnd(uint256 _tokenId, address contractAddress) public payable {
        Auction memory _auction = auctions[_tokenId];
        ERC721 token = ERC721(contractAddress);
        require(token.ownerOf(_tokenId) == msg.sender, "Only token owner can end auctions");
        require(token.getApproved(_tokenId) == address(this), "contract must be approved");

        if(_auction.ended){
            revert("The fucntion auctionEnded has already been called");
        }

        address payable seller = payable(_auction.beneficiary); 
        address payable admin = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        uint256 _highestBid = highestBidder[_auction.auctionId].currentHighestBid;
        address _highestBidder =  highestBidder[_auction.auctionId].currentHighestBidder;


        
        uint256 adminFee = (_highestBid * adminFeePercentage/100);
        adminFeesCollected += adminFee;
        address tokenCreator = token.getCreator(_tokenId);
        address tokenOwner = token.ownerOf(_tokenId);
        uint256 royalty = token.royaltyFee(_tokenId); 
        if(tokenOwner != tokenCreator){

            //transfer with royalty       
            uint256 royaltyFee = (_highestBid  * royalty/100);             
            payable(tokenCreator).transfer(royaltyFee);
            admin.transfer(adminFee);
            seller.transfer(_highestBid  - (adminFee)- (royaltyFee));            
        }
        else
        {           
            //transfer without royalty
            admin.transfer(adminFee);
            seller.transfer(_highestBid  - (adminFee));           
        }

        pendingReturns[_tokenId][_highestBidder] = 0;    
        token.transferFrom(seller,_highestBidder,_tokenId);
        auctions[_tokenId] = Auction(_auction.auctionId,msg.sender,true,block.timestamp);
  
    }
    function auctionEnd_new(uint256 _tokenId, address contractAddress) public payable {
        Auction_new memory _auction = auctions2[_tokenId];
        ERC721 token = ERC721(contractAddress);
        require(token.ownerOf(_tokenId) == msg.sender, "Only token owner can end auctions");
        require(token.getApproved(_tokenId) == address(this), "contract must be approved");

        if(_auction.ended){
            revert("The fucntion auctionEnded has already been called");
        }

        address payable seller = payable(_auction.beneficiary); 
        address payable admin = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        uint256 _highestBid = highestBidder_new[_auction.auctionId].currentHighestBid;
        address _highestBidder =  highestBidder_new[_auction.auctionId].currentHighestBidder;


        
        uint256 adminFee = (_highestBid * adminFeePercentage/100);
        adminFeesCollected += adminFee;
        address tokenCreator = token.getCreator(_tokenId);
        address tokenOwner = token.ownerOf(_tokenId);
        uint256 royalty = token.royaltyFee(_tokenId); 
        if(tokenOwner != tokenCreator){

            //transfer with royalty       
            uint256 royaltyFee = (_highestBid  * royalty/100);             
            payable(tokenCreator).transfer(royaltyFee);
            admin.transfer(adminFee);
            seller.transfer(_highestBid  - (adminFee)- (royaltyFee));            
        }
        else
        {           
            //transfer without royalty
            admin.transfer(adminFee);
            seller.transfer(_highestBid  - (adminFee));           
        }

        pendingReturns_new[_tokenId][_highestBidder] = 0;    
        token.transferFrom(seller,_highestBidder,_tokenId);
        auctions2[_tokenId] = Auction_new(_auction.auctionId,msg.sender,true,block.timestamp,block.timestamp );
  
    }
  


}