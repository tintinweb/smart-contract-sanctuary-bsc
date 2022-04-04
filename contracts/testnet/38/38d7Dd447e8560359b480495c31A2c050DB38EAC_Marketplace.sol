// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Counters.sol";

import "./IERC20.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";

import "./IEliteNFT.sol";
import "./IWoolFactory.sol";

import "./ERC721URIStorage.sol";
import "./ERC721.sol";

import "./ReentrancyGuard.sol";

interface IDegenNFT {
    function mint(address player) external returns (uint256);
}

contract Marketplace is IERC721Receiver, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using Counters for Counters.Counter;

    struct ItemTier {
        mapping(uint256 => MarketItem) itemListing;

        Counters.Counter _listingIds;
        Counters.Counter _itemsSold;

        uint256 queueFront;
        uint256 queueBack;

        uint256 totalMinted;
        uint256 totalListed;
        uint256 totalItems;
    }

    struct MarketItem {
        uint listingId;
        address _contract;
        uint256 _tokenId;
        address _seller;
        uint256 _price;
        bool forSale;
    }

    address public paymentToken;
    address public feeRecipient;

    uint8 public totalTiers;

    mapping(uint256 => ItemTier) tierData;

    mapping(uint256 => address) degenNFT;
    mapping(address => bool) isDegenNFT;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event MarketItemCreated(
        uint listingId, 
        address _contract, 
        uint256 _tokenId, 
        address _seller, 
        uint256 _price,
        bool _forSale
    );

    event onBuyItem(
        address indexed _caller, 
        address indexed _recipient, 
        uint256 _tierId, 
        uint256 _timestamp
    );

    constructor (
        address _nft1Address, 
        address _nft2Address, 
        address _nft3Address, 
        address _nft4Address, 
        address _nft5Address, 
        address _nft6Address, 
        address _paymentToken, 
        address _reserveAddress
    ) {
        degenNFT[1] = _nft1Address;
        degenNFT[2] = _nft2Address;
        degenNFT[3] = _nft3Address;
        degenNFT[4] = _nft4Address;
        degenNFT[5] = _nft5Address;
        degenNFT[6] = _nft6Address;

        // tierData[1].totalItems = 83500;
        // tierData[2].totalItems = 41750;
        // tierData[3].totalItems = 20875;
        // tierData[4].totalItems = 10043;
        // tierData[5].totalItems = 5021;
        // tierData[6].totalItems = 2600;

        tierData[1].totalItems = 5;
        tierData[2].totalItems = 5;
        tierData[3].totalItems = 5;
        tierData[4].totalItems = 5;
        tierData[5].totalItems = 5;
        tierData[6].totalItems = 5;

        isDegenNFT[_nft1Address] = true;
        isDegenNFT[_nft2Address] = true;
        isDegenNFT[_nft3Address] = true;
        isDegenNFT[_nft4Address] = true;
        isDegenNFT[_nft5Address] = true;
        isDegenNFT[_nft6Address] = true;

        paymentToken = _paymentToken;
        feeRecipient = _reserveAddress;

        totalTiers = 6;
    }

    ///////////////////////////
    // PUBLIC VIEW FUNCTIONS //
    ///////////////////////////

    // Mintable items remaining of a single tier
    function canMint(address _nft) public view returns (bool) {
        uint256 _available = IEliteNFT(_nft).mintableRemaining();
        return (_available > 0);
    }

    // Find how many NFTs of a tier are listed
    function buyableOf(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].totalListed);
    }

    // Find how many NFTs of a tier have been minted
    function mintableOf(uint256 _tier) public view returns (uint256) {
        
        uint256 _total = tierData[_tier].totalItems;
        uint256 _minted = tierData[_tier].totalMinted;

        return (_total.sub(_minted));
    }

    // Find how many NFTs of a tier have been minted
    function mintedOfTier(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].totalMinted);
    }

    // Find how many NFTs of a tier can be totally minted
    function totalItemsOf(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].totalItems);
    }

    // Find how many NFTs of a tier are available
    function totalAvailableOfTier(uint256 _tier) public view returns (uint256) {
        uint256 _minted = mintedOfTier(_tier);
        uint256 _total = totalItemsOf(_tier);

        return (_total.sub(_minted));
    }

    // Get contract address of one of the NFTs (by Tier ID)
    function getContractOf(uint256 _tier) public view returns (address) {
        if (_tier == 1) {return degenNFT[1];}
        if (_tier == 2) {return degenNFT[2];}
        if (_tier == 3) {return degenNFT[3];}
        if (_tier == 4) {return degenNFT[4];}
        if (_tier == 5) {return degenNFT[5];}
        if (_tier == 6) {return degenNFT[6];}

        return address(0);
    }

    // Get the price of one of the NFTs (by Tier ID)
    function getMintPriceOf(uint256 _tier) public pure returns (uint256) {

        if (_tier == 1) {return 2e18;}
        if (_tier == 2) {return 4e18;}
        if (_tier == 3) {return 8e18;}
        if (_tier == 4) {return 16e18;}
        if (_tier == 5) {return 32e18;}
        if (_tier == 6) {return 64e18;}

        return 0;
    }

    // Get tier of a contract address
    function getTierOf(address _contract) public view returns (uint256 _id) {
        if (_contract == degenNFT[1]) {_id = 1;}
        if (_contract == degenNFT[2]) {_id = 2;}
        if (_contract == degenNFT[3]) {_id = 3;}
        if (_contract == degenNFT[4]) {_id = 4;}
        if (_contract == degenNFT[5]) {_id = 5;}
        if (_contract == degenNFT[6]) {_id = 6;}
    }

    ////////////////////////////////////////////

    // Fetch a market item by tier, then listing ID
    function fetchMarketItem(uint256 _tier, uint listingId) public view returns (MarketItem memory, uint256 _marketItemId) {
        MarketItem memory item = tierData[_tier].itemListing[listingId];
        return (item, item.listingId);
    }

    // Returns all market items that are still for sale.
    function fetchMarketItems(uint256 _tier) public view returns (MarketItem[] memory) {
        uint itemCount = tierData[_tier]._listingIds.current();
        uint unsoldItemCount = tierData[_tier]._listingIds.current() - tierData[_tier]._itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint i = 0; i < itemCount; i++) {
            if (tierData[_tier].itemListing[i + 1].forSale == true) {
                uint currentId = tierData[_tier].itemListing[i + 1].listingId;
                MarketItem storage currentItem = tierData[_tier].itemListing[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
    
        return items;
    }

    // Fetch the front of the queue, of a tier
    function fetchQueueFront(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].queueFront);
    }

    // Fetch the back of the queue, of a tier
    function fetchQueueBack(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].queueBack);
    }

    ////////////////////////////////////////////

    // Create the market item and transfer the item to this contract
    function listItem(address _contract, uint256 _tokenId, uint256 _markup) public nonReentrant {
        require(_markup > 0 && _markup < 6, "INVALID_RANGE");

        address _seller = address(msg.sender);
        uint256 _tier = getTierOf(_contract);

        tierData[_tier]._listingIds.increment();
        uint256 listingId = tierData[_tier]._listingIds.current();

        uint256 _mintPrice = getMintPriceOf(_tier);
        uint256 _markupFactor = (_markup.mul(5));
        uint256 _actualMarkup = (_mintPrice.mul(_markupFactor).div(100));

        uint256 _price = (_mintPrice + _actualMarkup);
    
        tierData[_tier].itemListing[listingId] = MarketItem(
            listingId, _contract, _tokenId, _seller, _price, true
        );

        tierData[_tier].totalListed += 1;

        addItemToQueue(_tier, listingId);

        IERC721(_contract).transferFrom(_seller, address(this), _tokenId);

        emit MarketItemCreated(listingId, _contract, _tokenId, _seller, _price, true);
    }

    // Buy an NFT - mints first, sells listed items second
    // Sells listed items in a FIFO-style queue

    function buyItem(address _contract) public nonReentrant returns (uint256) {

        // Get the tier of the contract
        uint256 _tier = getTierOf(_contract);

        // Empty uint for token ID
        uint256 _tokenId;

        // Find the mintable and buyable counts of the tier
        uint256 _mintable = mintableOf(_tier);
        uint256 _buyable  = buyableOf(_tier);

        // Require there to be at least something to facilitate the buy
        require(_mintable > 0 || _buyable > 0, "NO_ITEMS_AVAILABLE");

        // If there's mintables,
        if (_mintable > 0) {

            // Mint a new NFT Item to the caller
            _tokenId = buyItemFreshMint(_tier, msg.sender);

        // Otherwise, if there's no mintable and there's some buyable...
        } else if (_mintable == 0 && _buyable > 0) {

            // Sell the caller the next NFT in line
            _tokenId = buyItemFromMarket(_tier, msg.sender);
        }

        // Tell the network, successful function
        emit onBuyItem(msg.sender, msg.sender, _tier, block.timestamp);
        return (_tokenId);
    }

    // Buy listed item (by contract address)
    // - Translates to ItemID by contract
    // - Finds first item in sales list for that tier
    // - that item becomes the item being purchased

    function buyItemFromMarket(uint256 _tierId, address _recipient) internal returns (uint256) {
        
        // Find the contract of the desired tier
        address _contract = getContractOf(_tierId);

        // Find the listing ID of the next item in the queue
        (MarketItem memory listingData, uint256 _listingId) = fetchMarketItem(_tierId, fetchQueueFront(_tierId));

        // Get details of the listed item
        uint256 price  = listingData._price;
        uint256 token  = listingData._tokenId;
        address seller = listingData._seller;

        // Collect Payment for listed item
        require(IERC20(paymentToken).transferFrom(_recipient, seller, price), 'Must pay item price');

        // Then give the recipient their item
        IERC721(_contract).transferFrom(address(this), _recipient, token);
        
        // Set the item listing to false
        tierData[_tierId].itemListing[_listingId].forSale = false;
        
        // Decrease total listing count for the tier
        tierData[_tierId].totalListed -= 1;

        // Pop the queue for the tier
        pop(_tierId);

        // Increment the number of items sold
        tierData[_tierId]._itemsSold.increment();

        // Return the token Id of the item sold
        return token;
    }

    // Buy an NFT, specifying recipient and tier.
    // Caller must approve this contract to spend their SH33P

    function buyItemFreshMint(uint256 _tierId, address _recipient) internal returns (uint256 _newItemID) {

        // Get contract and mint price
        address _contract = getContractOf(_tierId);
        uint256 _mintPrice = getMintPriceOf(_tierId);

        tierData[_tierId].totalMinted += 1;

        // Collect Mint Payment
        require(IERC20(paymentToken).transferFrom(_recipient, feeRecipient, _mintPrice), 'Must pay minting fee');

        return IDegenNFT(_contract).mint(_recipient);
    }

    // ERC-721 Receiver function
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    ////////////////////////////////////
    // INTERNAL AND PRIVATE FUNCTIONS //
    ////////////////////////////////////

    // QUEUE FUNCTIONS

    // Add item to sale queue (of tier)
    function addItemToQueue(uint256 _tier, uint256 _marketItemId) internal {

        // Add _marketItemId to the queue
        tierData[_tier].queueBack = _marketItemId;

        // Will overflow automatically and reset itself
        tierData[_tier].queueBack++;
    }

    // Pop the tier queue (to "bring forward" the next item in the list)
    function pop(uint256 _tier) internal {

        // Sanity checks
        require(tierData[_tier].queueFront != tierData[_tier].queueBack);

        // Clean-up previous entry
        tierData[_tier].queueFront = 0x0;
        
        // Will overflow automatically and reset itself
        tierData[_tier].queueFront++;
    }
}