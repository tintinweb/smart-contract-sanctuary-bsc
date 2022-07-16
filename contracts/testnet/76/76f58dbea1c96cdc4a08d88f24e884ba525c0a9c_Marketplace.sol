/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;
}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);

    function tokenURI(uint tokenId) external view returns (string memory);
}

interface IERC20 {

    function transfer(address recipient, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
}

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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


contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _marketItemIds;
    Counters.Counter private _tokensSold;
    Counters.Counter private _tokensCanceled;

    address base;
    address minter;
    address ve;

    // Challenge: make this price dynamic according to the current currency price
    uint256 private listingFee = 40; // 2.5%

    mapping(uint256 => MarketItem) private marketItemIdToMarketItem;

    struct MarketItem {
        uint256 marketItemId;
        address nftContractAddress;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        bool sold;
        bool canceled;
        bool forSale;
    }

    event MarketItemCreated(
        uint256 indexed marketItemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold,
        bool canceled,
        bool forSale
    );
    event MarketplaceFeeSet(address indexed emergencyDAO, uint256 listingFee);

    constructor(address _minter, address _base, address _ve) {
        minter = _minter;
        base = _base;
        ve = _ve;
    }

    function getListingFee() public view returns (uint256) {
        return listingFee;
    }

    function setListingFee(uint256 _listingFee) public {
        require(msg.sender == IERC721(ve).ownerOf(1), "Emergency DAO privilege: setListingFee");
        require(_listingFee >= 2 && _listingFee <= 1000);
        listingFee = _listingFee;
        emit MarketplaceFeeSet(msg.sender, _listingFee);
    }

    function calculateFee(uint256 price) public view returns (uint256) {
        return price / listingFee;
    }

    /**
     * @dev Creates a market item listing, requiring a listing fee and transfering the NFT token from
     * msg.sender to the marketplace contract.
     */
    function createMarketItem(
        address nftContractAddress,
        uint256 tokenId,
        uint256 price
    ) public nonReentrant returns (uint256) {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.sender == IERC721(nftContractAddress).ownerOf(tokenId), "Not NFT owner");
        require(IERC721(nftContractAddress).isApprovedForAll(msg.sender, address(this)), "Marketplace not approved");
        _marketItemIds.increment();
        uint256 marketItemId = _marketItemIds.current();

        marketItemIdToMarketItem[marketItemId] = MarketItem(
            marketItemId,
            nftContractAddress,
            tokenId,
            msg.sender,
            msg.sender,
            price,
            false,
            false,
            true
        );

        emit MarketItemCreated(
            marketItemId,
            nftContractAddress,
            tokenId,
            msg.sender,
            msg.sender,
            price,
            false,
            false,
            true
        );

        return marketItemId;
    }

    /**
     * @dev Cancel a market item
     */
    function cancelMarketItem(uint256 marketItemId) public nonReentrant {
        uint256 tokenId = marketItemIdToMarketItem[marketItemId].tokenId;
        require(tokenId > 0, "Unexistent market item");

        require(marketItemIdToMarketItem[marketItemId].seller == msg.sender, "Not seller");

        marketItemIdToMarketItem[marketItemId].canceled = true;
        marketItemIdToMarketItem[marketItemId].forSale = false;

        _tokensCanceled.increment();
    }

    /**
     * @dev Get Latest Market Item by the token id
     */
    function getLatestMarketItemByTokenId(uint256 tokenId) public view returns (MarketItem memory, bool) {
        uint256 itemsCount = _marketItemIds.current();

        for (uint256 i = itemsCount; i > 0; i--) {
            MarketItem memory item = marketItemIdToMarketItem[i];
            if (item.tokenId != tokenId) continue;
            return (item, true);
        }

        // What is the best practice for returning a "null" value in solidity?
        // Reverting does't seem to be the best approach as it would throw an error on frontend
        MarketItem memory emptyMarketItem;
        return (emptyMarketItem, false);
    }

    /**
     * @dev Creates a market sale by transfering msg.sender money to the seller and NFT token from the
     * marketplace to the msg.sender. It also sends the listingFee to the marketplace owner.
     */
    function createMarketSale(address nftContractAddress, uint256 marketItemId, uint256 tokenId, uint256 value) public nonReentrant {
        require(IERC721(nftContractAddress).isApprovedForAll(msg.sender, address(this)), "Marketplace not approved");
        address seller = marketItemIdToMarketItem[marketItemId].seller;
        uint256 price = marketItemIdToMarketItem[marketItemId].price;
        require(seller == IERC721(nftContractAddress).ownerOf(tokenId), "Not NFT owner");
        require(value == price, "Price doesn't match");

        uint256 fee = calculateFee(value);
        value -= fee;

        _safeTransferFrom(base, msg.sender, minter, fee);
        _safeTransferFrom(base, msg.sender, seller, value);
        IERC721(nftContractAddress).transferFrom(seller, msg.sender, marketItemIdToMarketItem[marketItemId].tokenId);

        marketItemIdToMarketItem[marketItemId].owner = msg.sender;
        marketItemIdToMarketItem[marketItemId].forSale = false;
        marketItemIdToMarketItem[marketItemId].sold = true;

        _tokensSold.increment();

    }

    /**
     * @dev Fetch non sold and non canceled market items
     */
    function fetchAvailableMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemsCount = _marketItemIds.current();
        uint256 soldItemsCount = _tokensSold.current();
        uint256 canceledItemsCount = _tokensCanceled.current();
        uint256 availableItemsCount = itemsCount - soldItemsCount - canceledItemsCount;
        MarketItem[] memory marketItems = new MarketItem[](availableItemsCount);

        uint256 currentIndex = 0;
        for (uint256 i = 0; i < itemsCount; i++) {
            // Is this refactor better than the original implementation?
            // https://github.com/dabit3/polygon-ethereum-nextjs-marketplace/blob/main/contracts/Market.sol#L111
            // If so, is it better to use memory or storage here?
            MarketItem memory item = marketItemIdToMarketItem[i + 1];
            if (item.forSale == true) continue;
            marketItems[currentIndex] = item;
            currentIndex += 1;
        }

        return marketItems;
    }

    /**
     * @dev This seems to be the best way to compare strings in Solidity
     */
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    /**
     * @dev Since we can't access structs properties dinamically, this function selects the address
     * we're looking for between "owner" and "seller"
     */
    function getMarketItemAddressByProperty(MarketItem memory item, string memory property)
        private
        pure
        returns (address)
    {
        require(
            compareStrings(property, "seller") || compareStrings(property, "owner"),
            "Parameter must be 'seller' or 'owner'"
        );

        return compareStrings(property, "seller") ? item.seller : item.owner;
    }

    /**
     * @dev Fetch market items that are being listed by the msg.sender
     */
    function fetchSellingMarketItems() public view returns (MarketItem[] memory) {
        return fetchMarketItemsByAddressProperty("seller");
    }

    /**
     * @dev Fetch market items that are owned by the msg.sender
     */
    function fetchOwnedMarketItems() public view returns (MarketItem[] memory) {
        return fetchMarketItemsByAddressProperty("owner");
    }

    /**
     * @dev Fetches market items according to the its requested address property that
     * can be "owner" or "seller". The original implementations were two functions that were
     * almost the same, changing only a property access. This refactored version requires an
     * addional auxiliary function, but avoids repeating code.
     * See original: https://github.com/dabit3/polygon-ethereum-nextjs-marketplace/blob/main/contracts/Market.sol#L121
     */
    function fetchMarketItemsByAddressProperty(string memory _addressProperty)
        public
        view
        returns (MarketItem[] memory)
    {
        require(
            compareStrings(_addressProperty, "seller") || compareStrings(_addressProperty, "owner"),
            "Parameter must be 'seller' or 'owner'"
        );
        uint256 totalItemsCount = _marketItemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemsCount; i++) {
            address addressPropertyValue = getMarketItemAddressByProperty(marketItemIdToMarketItem[i + 1], _addressProperty);
            if (addressPropertyValue != msg.sender) continue;
            itemCount += 1;
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 0; i < totalItemsCount; i++) {
            address addressPropertyValue = getMarketItemAddressByProperty(marketItemIdToMarketItem[i + 1], _addressProperty);
            if (addressPropertyValue != msg.sender) continue;
            items[currentIndex] = marketItemIdToMarketItem[i + 1];
            currentIndex += 1;
        }

        return items;
    }

        function _safeTransferFrom(address token, address from, address to, uint256 value) internal {
        require(token.code.length > 0);
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
}