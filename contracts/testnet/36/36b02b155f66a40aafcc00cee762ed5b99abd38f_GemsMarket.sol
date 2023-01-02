/**
 *Submitted for verification at BscScan.com on 2023-01-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

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
   
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract GemsMarket is ERC721Holder, ReentrancyGuard {

    uint256 private _tokenIds;   //total listed
    uint256 private _itemSold;

    address public owner;

    uint256 public listingPrice = 25;  //2.5%
    uint256 deno = 1000;

    IERC20 public listingCurrency;

    struct MarketItem {
        address collection;
        uint256 tokenId;
        address seller;
        ListingStatus status;   //1 for Active and 0 for not Active
        uint256 price;
    }
    mapping(address => mapping (uint => MarketItem)) private Listings;
    //collection -> items -> details

    mapping(address => uint) private _collectionListed;
    mapping(address => uint) private _collectionSold;
    mapping(address => mapping(uint => uint)) public _collectionPointer; //colllection->tokenid>lisitngid

    mapping (address => bool) private acceptedCollections;
    address[] private _collectionAdded;
    
    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }

    event ItemListed (
        address indexed _collection,
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );

    event ItemSold (
        address indexed token,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        uint256 price
    );

    modifier onlyOwner() {
        require(msg.sender == owner,"Error: Caller must be Ownable!!");
        _;
    }

    constructor(address _ctoken) { 
        listingCurrency = IERC20(_ctoken);
        owner = msg.sender;
    }

    // >

    function listItem(address _collection,uint _tokenId,uint _price) external {
        address account = msg.sender;
        require(acceptedCollections[_collection],"Error: Contact to Admin!");
        IERC721(_collection).transferFrom(account,address(this),_tokenId);
        MarketItem memory _newList =  MarketItem(
            _collection,
            _tokenId,
            account,
            ListingStatus.Active,
            _price
        );
        _tokenIds++;
        _collectionListed[_collection]++;
        uint temp = _collectionListed[_collection];
        _collectionPointer[_collection][_tokenId] = temp;
        Listings[_collection][temp] = _newList;
        emit ItemListed(_collection,_tokenId,account,_price);
    }

    function buyToken(address _collection,uint _listingId,uint _tokenAmount) external {
        address account = msg.sender;
        MarketItem storage listing = Listings[_collection][_listingId];
        require(listing.status == ListingStatus.Active,"Error: Lisitng is not Active yet!");
        require(account != listing.seller,"Error: Seller can't buy!");
        
        uint totalprice =  listing.price;
        require(_tokenAmount >= totalprice,"Error: Invalid Price!");

        uint fee = totalprice*listingPrice/deno;
        uint rem = totalprice - fee;

        listingCurrency.transferFrom(account, owner , fee);
        listingCurrency.transferFrom(account, listing.seller, rem);

        IERC721(listing.collection).transferFrom(address(this),account,listing.tokenId);
        listing.status = ListingStatus.Sold;
        _itemSold++;
        _collectionSold[_collection]++;
        emit ItemSold(listing.collection,listing.tokenId,listing.seller,account,listing.price);
    }

    function cancelListing(address _collection,uint _listingId) external {
        address account = msg.sender;
        MarketItem storage listing = Listings[_collection][_listingId];
        require(listing.status == ListingStatus.Active,"Error: Lisitng is not Active yet!");
        require(account == listing.seller,"Caller must be seller!");
        IERC721(listing.collection).transferFrom(address(this),account,listing.tokenId);
        listing.status = ListingStatus.Cancelled;
    }

    function fetchListing(address _collection,uint _listingId) external view returns (MarketItem memory) {
        MarketItem memory listing = Listings[_collection][_listingId];
        return listing;
    }

    //                   BULK LIST

    function bulkListItem(address _collection,uint[] calldata _tokenId,uint[] calldata _price) external {
        address account = msg.sender;
        require(acceptedCollections[_collection],"Error: Contact to Admin!");
        require(_tokenId.length == _price.length,"Error: Mismatch Error!");
        for(uint i = 0; i < _tokenId.length; i++) {
            IERC721(_collection).transferFrom(account,address(this),_tokenId[i]);
            MarketItem memory _newList =  MarketItem(
                _collection,
                _tokenId[i],
                account,
                ListingStatus.Active,
                _price[i]
            );
            _tokenIds++;
            _collectionListed[_collection]++;
            uint temp = _collectionListed[_collection];
            Listings[_collection][temp] = _newList;
            emit ItemListed(_collection,_tokenId[i],account,_price[i]);
        }
    }

    //

    function itemSold() external view returns (uint256) {
        return _itemSold;   
    }

    function itemsListed() external view returns (uint256) {
        return _tokenIds;   
    }

    function contractItemListed(address _collection) external view returns (uint256) {
        return _collectionListed[_collection];
    }

    function contractItemSold(address _collection) external view returns (uint256) {
        return _collectionSold[_collection];
    }

    function rescueFunds() external onlyOwner {
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os);
    }

    function rescueTokens(address _token) external onlyOwner {
        uint balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender,balance);
    }

    function rescueNfts(address _token,uint _tokenId) external onlyOwner {
        IERC721(_token).transferFrom(address(this),msg.sender,_tokenId);
    }

    function updateListingPrice(uint _newPrice) external onlyOwner {
        listingPrice = _newPrice;
    }

    function setCurrency(address _newToken) external onlyOwner {
        listingCurrency = IERC20(_newToken);
    }

    function allowCollection(address _collection,bool _status) external onlyOwner {
        require(acceptedCollections[_collection] != _status,"Error: State Not Changed!");
        if(_status) {
            acceptedCollections[_collection] = _status;
            _collectionAdded.push(_collection);
        }
        else {
            uint j = _collectionAdded.length;
            for(uint i = 0; i < j; i++) {
                if(_collectionAdded[i] == _collection) {
                    _collectionAdded[i] = _collectionAdded[j - 1];
                    _collectionAdded.pop();
                }   
            }
        }
    }

    function collectionlist() external view returns (address[] memory) {
        return _collectionAdded;
    }

    function collectionlistCount() external view returns (uint) {
        return _collectionAdded.length;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    
    receive() external payable {}

}