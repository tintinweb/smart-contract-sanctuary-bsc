/**
 *Submitted for verification at BscScan.com on 2022-12-14
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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


contract GemsMarket is Ownable, ERC721Holder, ReentrancyGuard {

    uint256 private _tokenIds;
    uint256 private _itemSold;

    uint256 public listingPrice = 0.02 ether;

    struct MarketItem {
        address token;
        uint256 tokenId;
        address payable seller;
        ListingStatus status;   //1 for Active and 0 for not Active
        uint256 price;
    }
    mapping (uint => MarketItem) private Listings;

    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }

    event ItemListed (
        address indexed token,
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

    // >

    function listItem(address _token,uint _tokenId,uint _price) external {
        address account = msg.sender;
        // IERC721(_token).transferFrom(account,address(this),_tokenId);
        MarketItem memory _newList =  MarketItem(
            _token,
            _tokenId,
            payable(account),
            ListingStatus.Active,
            _price
        );
        _tokenIds++;
        Listings[_tokenIds] = _newList;
        emit ItemListed(_token,_tokenId,account,_price);
    }

    function buyToken(uint _listingId) external payable {
        address account = msg.sender;
        MarketItem storage listing = Listings[_listingId];
        require(listing.status == ListingStatus.Active,"Error: Lisitng is not Active yet!");
        require(account != listing.seller,"Error: Seller can't buy!");
        uint256 value = msg.value;
        uint totalprice =  listing.price + listingPrice;
        require(value >= totalprice,"Error: Invalid Price!");
        // IERC721(listing.token).transferFrom(address(this),account,listing.tokenId);
        (listing.seller).transfer(listing.price);
        payable(owner()).transfer(listingPrice);
        listing.status = ListingStatus.Sold;
        _itemSold++;
        emit ItemSold(listing.token,listing.tokenId,listing.seller,account,listing.price);
    }

    function cancelListing(uint _listingId) external {
        address account = msg.sender;
        MarketItem storage listing = Listings[_listingId];
        require(listing.status == ListingStatus.Active,"Error: Lisitng is not Active yet!");
        require(account == listing.seller,"Caller must be seller!");
        IERC721(listing.token).transferFrom(address(this),account,listing.tokenId);
        listing.status = ListingStatus.Cancelled;
    }

    function fetchListing(uint _listingId) external view returns (MarketItem memory) {
        MarketItem memory listing = Listings[_listingId];
        return listing;
    }

    function itemSold() external view returns (uint256) {
        return _itemSold;   
    }

    function itemsListed() external view returns (uint256) {
        return _tokenIds;   
    }

    function rescueFunds() external onlyOwner {
        (bool os,) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function rescueTokens(address _token) external onlyOwner {
        uint balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner(),balance);
    }

    function rescueNfts(address _token,uint _tokenId) external onlyOwner {
        IERC721(_token).transferFrom(address(this),msg.sender,_tokenId);
    }

    function updateListingPrice(uint _newPrice) external onlyOwner {
        listingPrice = _newPrice;
    }

    receive() external payable {}

}