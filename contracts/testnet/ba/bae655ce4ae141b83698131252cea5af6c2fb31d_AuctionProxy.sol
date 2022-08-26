/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-14
*/

pragma solidity ^0.5.10;

interface ERC20Interface {
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function transfer(address _to, uint256 _value) external;
  function approve(address _spender, uint256 _value) external returns (bool);
  function symbol() external view returns (string memory);
}

interface ERC721Interface {
  function transferFrom(address _from, address _to, uint256 _tokenId) external ;
  function ownerOf(uint256 _tokenId) external view returns (address);
  function approve(address _to, uint256 _tokenId) external;
}

contract Ownable {
  address payable public owner;

  constructor () public{
    owner = msg.sender;
  }

  modifier onlyOwner()  {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {

    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

contract AuctionProxy is Ownable {
    //Take 100 as the unit, 10/100
    uint public fee = 10;
    
    uint256 public auctionAmount;

    struct Auction {
        address nftAddress;
        uint256 tokenId;
        address payable holder;
        address payCoinAddress;
        uint256 startPrice;
        uint256 miniIncreasePrice;
        uint256 maxPrice;   //Buy at this price, the transaction will be done directly
        uint256 dealPrice; 
        uint    expireDate;
        address payable bidAddress;
        uint256 bidValue;   
        string  bidFrom;
        uint    status;     //0-in auction 1-completed 2-overdue 3-canceled
    }

    //Auction map list
    mapping (uint256 => Auction) public auctions;
    
    event NewAuction(
        uint256 indexed _auctionId,
        address indexed _nftAddress,
        uint256 indexed _tokenId,
        address _holder,
        address _payCoinAddress,
        uint256 _startPrice, 
        uint256 _miniIncreasePrice, 
        uint256 _maxPrice,
        uint _expireDate,
        string _from
    );
    
    event Bid(
        uint256 indexed _auctionId,
        address indexed _bidAddress,
        uint256 _value,
        uint _expireDate,
        string _from
    );
    
    event AuctionSold(
        uint256 indexed _auctionId
    );
    
    event AuctionOverdue(
        uint256 indexed _auctionId
    );
    
    event CancelAuction(
        uint256 indexed _auctionId
    );

    constructor() public{

    }
    
    function modifyFee(uint _fee) public onlyOwner returns(bool){
        require(_fee >= 0 && _fee < 100);

        fee = _fee;
        return true;
    }

    function createBidAuction (address nftAddress,uint256 tokenId,address payCoinAddress, uint256 startPrice, uint256 miniIncreasePrice, uint256 maxPrice,uint expireDate,string memory createFrom)  public payable returns(bool){
        
        require(startPrice >= 0);
        require(miniIncreasePrice > 0,"auction miniIncreasePrice cannot be 0");
        require(maxPrice >= startPrice,"auction maxPrice must >= startPrice");
        require(expireDate >= 1 * 24 * 60 * 60,"Your auction must last at least one day");

        address holder = ERC721Interface(nftAddress).ownerOf(tokenId); 
        address payable nftHolder = address(uint160(holder));

        uint blockExpireDate = now + expireDate * 1 seconds;
        
        ERC721Interface(nftAddress).transferFrom(holder,address(this),tokenId);
      
        Auction storage auction = auctions[auctionAmount];

        auction.nftAddress = nftAddress;
        auction.tokenId = tokenId;
        auction.holder = nftHolder;
        auction.payCoinAddress = payCoinAddress;
        auction.startPrice = startPrice;
        auction.miniIncreasePrice = miniIncreasePrice;
        auction.maxPrice = maxPrice;
        auction.dealPrice = 0;
        auction.expireDate = blockExpireDate;
        auction.bidAddress = address(0);
        auction.bidValue = 0;
        auction.bidFrom = "";
        auction.status = 0;

        emit NewAuction(auctionAmount,nftAddress,tokenId,nftHolder,payCoinAddress,startPrice, miniIncreasePrice, maxPrice,auction.expireDate,createFrom);

        auctionAmount ++;

        return true;
    }

    
    function createFixedAuction (address nftAddress,uint256 tokenId,address payCoinAddress,uint256 maxPrice,uint expireDate,string memory createFrom)  public payable returns(bool){
        
        require(maxPrice >= 0);
        require(expireDate >= 1 * 24 * 60 * 60,"Your auction must last at least one day");

        address holder = ERC721Interface(nftAddress).ownerOf(tokenId); 
        address payable nftHolder = address(uint160(holder));

        uint blockExpireDate = now + expireDate * 1 seconds;
        
        ERC721Interface(nftAddress).transferFrom(holder,address(this),tokenId);
      
        Auction storage auction = auctions[auctionAmount];
        
        auction.nftAddress = nftAddress;
        auction.tokenId = tokenId;
        auction.holder = nftHolder;
        auction.payCoinAddress = payCoinAddress;
        auction.startPrice = maxPrice;
        auction.miniIncreasePrice = 0;
        auction.maxPrice = maxPrice;
        auction.dealPrice = 0;
        auction.expireDate = blockExpireDate;
        auction.bidAddress = address(0);
        auction.bidValue = 0;
        auction.bidFrom = "";
        auction.status = 0;

        emit NewAuction(auctionAmount,nftAddress,tokenId,nftHolder,payCoinAddress,maxPrice, 0, maxPrice,auction.expireDate,createFrom);

        auctionAmount ++;

        return true;
    }

    function bid(uint256 auctionId,uint256 value,string memory bidFrom) public payable returns (bool){
        Auction memory auction = auctions[auctionId];
        
        require(auction.nftAddress != address(0));
        require(auction.status == 0,"auction must be on sale");
        
        if(auction.payCoinAddress == address(0)){
            require(msg.value == value);
        }
        
        uint date = bidForOnSalePriceAuction(auctionId,value,bidFrom);    

        emit Bid(auctionId,msg.sender,value,date,bidFrom);

        return true;
    }

    function bidForOnSalePriceAuction(uint256 auctionId,uint256 value,string memory bidFrom) internal returns(uint) {
        Auction storage auction = auctions[auctionId];
        
        if(auction.bidAddress == address(0)){
            require(value>=auction.startPrice);
        }else{
            require(value >= auction.bidValue + auction.miniIncreasePrice);
            //Return the bid of the previous person
            if(auction.payCoinAddress == address(0)){
                //Return bnb
                auction.bidAddress.transfer(auction.bidValue);
            }else{
                //Return token
                ERC20Interface(auction.payCoinAddress).transfer(auction.bidAddress,auction.bidValue);
            }
        }
        
        if(auction.payCoinAddress != address(0)){
            ERC20Interface(auction.payCoinAddress).transferFrom(msg.sender,address(this),value);
        }
        
        auction.bidAddress = msg.sender;
        auction.bidValue = value;
        auction.bidFrom = bidFrom;
        
        if(auction.expireDate - now <= 30 minutes){
            auction.expireDate = now + 30 minutes;
        }
        
        //Expected price deal
        if(value >= auction.maxPrice){
            _sold(auctionId);
        }
        
        return auction.expireDate;
    }

    function handleOverdueAuction(uint256 auctionId) public onlyOwner returns(bool){
      
        Auction storage auction = auctions[auctionId];
        require(auction.status == 0 ,"auction must be on sale");
        require(auction.expireDate < now, "Overdue time not reached");
        
        if(auction.bidAddress != address(0)){
            
             //Transfer nft and distribute according to handling fee
            ERC721Interface(auction.nftAddress).transferFrom(address(this),auction.bidAddress,auction.tokenId);

            uint256 feeValue = auction.bidValue * fee / 100;
            uint256 getValue = auction.bidValue - feeValue;

            if(auction.payCoinAddress == address(0)){
                owner.transfer(feeValue);
                auction.holder.transfer(getValue);
            }else{
                ERC20Interface(auction.payCoinAddress).transfer(owner,feeValue);
                ERC20Interface(auction.payCoinAddress).transfer(auction.holder,getValue);
            }
            
            auction.dealPrice = auction.bidValue;
            auction.status = 1;

            emit AuctionSold(auctionId);
        }else{

            //return nft
            ERC721Interface(auction.nftAddress).transferFrom(address(this),auction.holder,auction.tokenId);
            
            emit AuctionOverdue(auctionId);
            auction.status = 3;
        }

        return true;
    }
    
    
    function acceptPrice(uint256 auctionId)  public returns(bool){
        Auction memory auction = auctions[auctionId];
        require(msg.sender == auction.holder,"only auction holder can accept bid");
        require(auction.bidValue != 0,"auction bidValue can not be 0");
        require(auction.status == 0,"auction must be on sale");
        
        return _sold(auctionId);
    }
    
    function cancelAuction(uint256 auctionId)  public returns(bool){
        
        Auction storage auction = auctions[auctionId];
        require(msg.sender == auction.holder,"only auction holder can cancel auction");
        require(auction.status == 0,"auction must be on sale");
        
        if(auction.bidAddress != address(0)){
             //give back the bid of the previous person
            if(auction.payCoinAddress == address(0)){
                //give back bnb
                auction.bidAddress.transfer(auction.bidValue);
            }else{
                //give back token
                ERC20Interface(auction.payCoinAddress).transfer(auction.bidAddress,auction.bidValue);
            }
        }
        
        emit CancelAuction(auctionId);
        
        //return nft
        ERC721Interface(auction.nftAddress).transferFrom(address(this),auction.holder,auction.tokenId);
        
        auction.status = 3;
        
        return true;
    }

    function _sold (uint256 auctionId) internal returns (bool) {
        Auction storage auction = auctions[auctionId];
        
        //Transfer nft and distribute according to handling fee
        ERC721Interface(auction.nftAddress).transferFrom(address(this),auction.bidAddress,auction.tokenId);

        uint256 feeValue = auction.bidValue * fee / 100;
        uint256 getValue = auction.bidValue - feeValue;

        if(auction.payCoinAddress == address(0)){
            owner.transfer(feeValue);
            auction.holder.transfer(getValue);
        }else{
            ERC20Interface(auction.payCoinAddress).transfer(owner,feeValue);
            ERC20Interface(auction.payCoinAddress).transfer(auction.holder,getValue);
        }
        
        emit AuctionSold(auctionId);
    
        //Change auction status
        auction.status = 1;
        auction.dealPrice = auction.bidValue;
        
        return true;
    }
}