/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
  
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

   
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

 
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


interface IERC165 {
   
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

   
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

   
    function balanceOf(address owner) external view returns (uint256 balance);

   
    function ownerOf(uint256 tokenId) external view returns (address owner);

  
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

   
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

   
    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

library SafeMath {
  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Marketplace {
    using SafeMath for uint256;

    address public owner;
    IERC721 public LandNFT;
    IERC721 public HeroNFT;

    IERC20 public HGB;
    uint public nftId;
    uint auctionId = 0;
    uint percentage;

    // Struct
    struct Auction {
        uint tokenId;
        uint endAt;
        bool started;
        bool ended;
        uint startPrice;
        uint priceStep;
        uint highestBid; //highestPrice
        address bidders;

    }

    // Mapping
    mapping(uint => Auction) auctionHistory;
    mapping(uint => uint) public AuctionByTokenId;
    // TokenID => Auction Id

    // Event
    event NewAuctionCreated(uint dayAfter, uint startPrice);
    event Bid(address indexed sender, uint amount);
    event WithdrawReward(address indexed sender);


    // constructor 
    constructor(
        address _HGB,
        address _LandNFTAddress,
        address _HeroNFTAddress
    )  {
        HGB = IERC20(_HGB);
        LandNFT = IERC721(_LandNFTAddress);
        HeroNFT = IERC721(_HeroNFTAddress);
        owner = msg.sender;
        percentage = 1;
    }

     // modifier 
    modifier onlyOwner(){
        require(msg.sender == owner,"Only Owner can run this function");
        _;
    }


    function createAuction(
        uint _dayAfter,
        uint _startPrice,
        uint TokenID,
        uint _priceStep
         ) public onlyOwner 
        returns(bool) {
            // check if TokenId exist in owner address
            require(LandNFT.ownerOf(TokenID) == owner, "Owner does not have this Token");
            require(AuctionByTokenId[TokenID] == 0, "This token is being auctioned");

            auctionId+=1;
            Auction storage a = auctionHistory[auctionId];
            (
                a.tokenId = TokenID,
                a.endAt=(_dayAfter * 1 days + block.timestamp),
                a.started = true,
                a.ended = false,
                a.startPrice = _startPrice,
                a.priceStep = _priceStep,
                a.highestBid = _startPrice,
                a.bidders = address(0)
            );

            AuctionByTokenId[TokenID]= auctionId;   
            emit NewAuctionCreated(_dayAfter, _startPrice);
            return true;
    }


     function bid(uint amount,uint _auctionId) external {
        Auction storage a = auctionHistory[_auctionId];

        require(msg.sender != owner, "Owner can not bid");
        require(a.started == true , "Auction is not started yet");
        if (block.timestamp > a.endAt) {
            a.ended = true;
        }
        require(block.timestamp < a.endAt, "Auction is already Ended!");
        require(HGB.balanceOf(msg.sender) >= amount, "You must have HGB ");
        require(amount >= a.highestBid + a.priceStep, "please enter amount higher than previous bid");

        if(a.bidders != address(0)) {
            // return HBG to previous bidder
            HGB.transferFrom(owner,a.bidders, a.highestBid);
        }

        a.highestBid = amount;
        a.bidders = msg.sender;
        HGB.transferFrom(msg.sender, owner, amount);
        emit Bid(msg.sender,amount);
    }

    
    function withdrawReward(uint _auctionId) public {
        Auction storage a = auctionHistory[_auctionId];

        require(block.timestamp > a.endAt, "Time is not up yet to claim or withdraw!"); 
        require(a.ended == true, "Auction is Not Ended yet !");
        require(msg.sender == a.bidders, "Not the winner");

        // Sent reward for winner
        LandNFT.transferFrom(owner, msg.sender, a.tokenId );
        emit WithdrawReward(msg.sender);

    }   

    function forceEnd(uint _auctionId) public onlyOwner {
        Auction storage a = auctionHistory[_auctionId];
        a.endAt = block.timestamp;
        a.ended = true;
    }
     


    function getAuctionById(uint _auctionId) public view returns  (Auction memory) {
        return auctionHistory[_auctionId];
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function changePercentage(uint newPer) public onlyOwner {
        percentage = newPer;
    }

    // BUY-SELL LandNFT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

     struct LandAsset{
        uint tokenID;
        uint price;
        bool onSell;
        address owner;
    }

    // TokenId => 
    mapping ( uint => LandAsset ) public LandAssets;

    // Events
    event OnSellLand(uint TokenID, uint price);
    event OnCancelLandSale(uint TokenID);
    event BuyLand(address indexed sender, uint price);


    function sellLand(uint TokenID, uint price) public {
        require(LandNFT.ownerOf(TokenID) == msg.sender, "You do not own this token");
        LandAsset storage l = LandAssets[TokenID];
        (
            l.tokenID = TokenID,
            l.price = price,
            l.onSell = true,
            l.owner = msg.sender
        );
        
        LandNFT.transferFrom(msg.sender, address(this), TokenID);
        emit OnSellLand(TokenID, price);
    }


    function cancelLandSale(uint TokenID) public{
        LandAsset storage l = LandAssets[TokenID];
        require(l.onSell, "Can not cancel - have not on sale yet");
        require(l.owner == msg.sender, "You do not own this token");
        l.price = 0;
        l.onSell = false;
        LandNFT.transferFrom(address(this), msg.sender, TokenID);
        emit OnCancelLandSale(TokenID);
    }


    function buyLand(uint TokenID) public {
        LandAsset storage l = LandAssets[TokenID];

        require(HGB.balanceOf(msg.sender) >= l.price, "Don't have enough HBG");
        require(l.onSell, "Can not buy - Sale is end");

        // Buyer send percentage
        HGB.transferFrom(msg.sender, address(this), getCommissionPrice(l.price));
        // Buyer pay seller the price - percentage
        HGB.transferFrom(msg.sender, l.owner, getAfterCommissionPrice(l.price));

        LandNFT.transferFrom(address(this), msg.sender, TokenID);
        l.onSell = false;
        emit BuyLand(msg.sender, l.price);

    }

    function getCommissionPrice(uint price) public view returns (uint) {
        return price.mul(percentage).div(100);
    }

    function getAfterCommissionPrice(uint price) public view returns (uint) {
        return price.sub(getCommissionPrice(price));
    }


    // BUY-SELL HeroNFT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


     struct HeroAsset{
        uint tokenID;
        uint price;
        bool onSell;
        address owner;
    }

    // TokenId => 
    mapping ( uint => HeroAsset ) public HeroAssets;

    // Events
    event OnSellHero(uint TokenID, uint price);
    event OnCancelHeroSale(uint TokenID);
    event BuyHero(address indexed sender, uint price);


    function sellHero(uint TokenID, uint price) public {
        require(HeroNFT.ownerOf(TokenID) == msg.sender, "You do not own this token");
        HeroAsset storage h = HeroAssets[TokenID];
        (
            h.tokenID = TokenID,
            h.price = price,
            h.onSell = true,
            h.owner = msg.sender
        );
        
        HeroNFT.transferFrom(msg.sender, address(this), TokenID);
        emit OnSellHero(TokenID, price);
    }


    function cancelHeroSale(uint TokenID) public{
        HeroAsset storage h = HeroAssets[TokenID];
        require(h.onSell, "Can not cancel - have not on sale yet");
        require(h.owner == msg.sender, "You do not own this token");
        h.price = 0;
        h.onSell = false;
        HeroNFT.transferFrom(address(this), msg.sender, TokenID);
        emit OnCancelHeroSale(TokenID);
    }


    function buyHero(uint TokenID) public {
        HeroAsset storage h = HeroAssets[TokenID];

        require(HGB.balanceOf(msg.sender) >= h.price, "Don't have enough HBG");
        require(h.onSell, "Can not buy - Sale is end");

        // Buyer send percentage
        HGB.transferFrom(msg.sender, address(this), getCommissionPrice(h.price));
        // Buyer pay seller the price - percentage
        HGB.transferFrom(msg.sender, h.owner, getAfterCommissionPrice(h.price));

        HeroNFT.transferFrom(address(this), msg.sender, TokenID);
        h.onSell = false;
        emit BuyHero(msg.sender, h.price);

    }

    function withdrawAssetFromContract() public onlyOwner {
        HGB.transfer(msg.sender, HGB.balanceOf(address(this)));
    }

    function checkContractBalance() public view returns (uint) {
        return HGB.balanceOf(address(this));
    }

    function getAddressOwner(uint tokenId) public view returns (address) {
        return HeroNFT.ownerOf(tokenId);
    }

}