pragma solidity ^0.8.4;
import "./Counters.sol";
import "./ERC721.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./IMilkToken.sol";

contract Market is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold;

    IMilkToken tokenMilk;

    address private ownerAddr;

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address seller;
        address buyer;
        uint256 price;
        uint256 listedTime;
        bool isSold;
    }

    uint8 public feePercent;

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 listedTime,
        bool isSold
    );

    constructor(IMilkToken _tokenMilk, address _ownerAddr) {
        tokenMilk = _tokenMilk;
        feePercent = 10;
        ownerAddr = _ownerAddr;
    }

    function setFeePercent(uint8 _feePercent) public onlyOwner {
        require(
            _feePercent <= 30 && _feePercent > 0,
            "Percent of Fee must be less than 30% or can't be zero"
        );
        feePercent = _feePercent;
    }

    function setOwnerAddr(address _ownerAddr) public onlyOwner {
        require(
            _ownerAddr != address(0),
            "Zero Address can't be the owner address"
        );
        ownerAddr = _ownerAddr;
    }

    function getOwnerAddr() public view onlyOwner returns (address) {
        return ownerAddr;
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public nonReentrant {
        require(price > 0, "Price can't be zero");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            block.timestamp,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            block.timestamp,
            false
        );
    }

    function unlistMarketItem(address nftContract, uint256 itemId)
        public
        nonReentrant
    {
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        require(itemId != 0, "Item Id can't not be zero!");

        require(
            msg.sender == idToMarketItem[itemId].seller,
            "This account is not seller of market item!"
        );

        require(
            nftContract == idToMarketItem[itemId].nftContract,
            "This NFT is not assigned with Market"
        );

        require(
            idToMarketItem[itemId].isSold != true &&
                idToMarketItem[itemId].buyer == address(0),
            "This item was sold already!"
        );

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].buyer = msg.sender;
        idToMarketItem[itemId].isSold = true;
        _itemSold.increment();
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        require(
            tokenMilk.balanceOf(msg.sender) >= price,
            "Balance of buyer is less than price"
        );

        require(
            msg.sender != idToMarketItem[itemId].seller,
            "User can't buy his NFT!"
        );

        tokenMilk.transferFrom(
            msg.sender,
            idToMarketItem[itemId].seller,
            (price * (100 - feePercent)) / 100
        );

        tokenMilk.transferFrom(
            msg.sender,
            ownerAddr,
            (price * feePercent) / 100
        );

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].buyer = msg.sender;
        idToMarketItem[itemId].isSold = true;
        _itemSold.increment();
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].buyer == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].buyer == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].buyer == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchSellerOfMarketItem(uint256 _marketId)
        public
        view
        returns (address)
    {
        return idToMarketItem[_marketId].seller;
    }

    function fetchPriceOfMarketItem(uint256 _marketId)
        public
        view
        returns (uint256)
    {
        return idToMarketItem[_marketId].price;
    }

    function fetchBuyerOfMarketItem(uint256 _marketId)
        public
        view
        returns (address)
    {
        require(idToMarketItem[_marketId].isSold, "This Item is not sold yet");

        return idToMarketItem[_marketId].buyer;
    }
}