// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Counters.sol";

import "./IERC20.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IWoolFactory.sol";

import "./IDegenNFT.sol";

import "./ERC721URIStorage.sol";
import "./ERC721.sol";

import "./Pausable.sol";
import "./Whitelist.sol";
import "./ReentrancyGuard.sol";

contract Marketplace is IERC721Receiver, Pausable, Whitelist, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using Counters for Counters.Counter;

    /////////////
    // STRUCTS //
    /////////////

    struct ItemTier {
        mapping(uint256 => MarketItem) itemListing;

        Counters.Counter _listingIds;
        Counters.Counter _itemsSold;

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

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20    public payableToken;  // SH33P token

    IWoolFactory public woolMinter; // The external

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    address public SHEEPAddress;
    address public reserveAddress;

    address public mintFeeSplitter;

    bool public tradingEnabled;

    uint8 public totalTiers;

    // Extra metrics
    uint256 public totalMinted;
    uint256 public totalListed;
    uint256 public totalResold;
    uint256 public totalProfits;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(uint256 => ItemTier) tierData;

    mapping(uint256 => address) degenNFT;
    mapping(address => bool) isDegenNFT;

    modifier ifTradingActive() {
        require(tradingEnabled == true, "MARKET_DISABLED");
        _;
    }

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onListItemForSale(
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

    event onSetMintFeeSplitter(
        address _caller, 
        address _old, 
        address _new, 
        uint256 _timestamp
    );

    event onToggleTrading(
        address _caller, 
        bool _option, 
        uint256 _timestamp
    );

    event onClaimTokens(
        address sender, 
        uint256 _toMint, 
        uint256 timestamp
    );

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor (
        address _nft1Address, 
        address _nft2Address, 
        address _nft3Address, 
        address _nft4Address, 
        address _nft5Address, 
        address _nft6Address, 
        address _SHEEP, 
        address _mintFeeSplitter,
        address _woolFactory
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

        tierData[1].totalItems = 25;
        tierData[2].totalItems = 25;
        tierData[3].totalItems = 25;
        tierData[4].totalItems = 25;
        tierData[5].totalItems = 25;
        tierData[6].totalItems = 25;

        isDegenNFT[_nft1Address] = true;
        isDegenNFT[_nft2Address] = true;
        isDegenNFT[_nft3Address] = true;
        isDegenNFT[_nft4Address] = true;
        isDegenNFT[_nft5Address] = true;
        isDegenNFT[_nft6Address] = true;

        SHEEPAddress = _SHEEP;

        payableToken = IERC20(SHEEPAddress);

        woolMinter = IWoolFactory(_woolFactory);
        mintFeeSplitter = _mintFeeSplitter;

        totalTiers = 6;
    }

    ///////////////////////////
    // PUBLIC VIEW FUNCTIONS //
    ///////////////////////////

    // Mintable items remaining of a single tier
    function canMint(address _nft) public view returns (bool) {
        uint256 _available = IDegenNFT(_nft).mintableRemaining();
        return (_available > 0);
    }

    // Current listing ID for tier queue
    function listIndex(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier]._listingIds.current());
    }

    // Next item to sell from tier queue
    function sellIndex(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier]._itemsSold.current().add(1));
    }

    // Find how many NFTs of a tier have been minted
    function mintableOf(uint256 _tier) public view returns (uint256) {
        
        uint256 _total = tierData[_tier].totalItems;
        uint256 _minted = tierData[_tier].totalMinted;

        return (_total.sub(_minted));
    }

    function buyableOf(uint256 _tier) public view returns (uint256) {
        uint256 _listed = tierData[_tier].totalListed;
        uint256 _sold = tierData[_tier]._itemsSold.current();

        return (_listed.sub(_sold));
    }

    // Find how many NFTs of a tier have been minted
    function mintedOfTier(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].totalMinted);
    }

    // Find how many NFTs of a tier can be totally minted
    function totalItemsOfTier(uint256 _tier) public view returns (uint256) {
        return (tierData[_tier].totalItems);
    }

    // Find how many NFTs of a tier are available
    function totalAvailableOfTier(uint256 _tier) public view returns (uint256) {
        uint256 _minted = mintedOfTier(_tier);
        uint256 _total = totalItemsOfTier(_tier);

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

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Get item count for all tiers, for one _user
    function getItems(address _user, bool _realtime) external view returns (
        uint256 _tier1Items, uint256 _tier2Items, uint256 _tier3Items, uint256 _tier4Items, uint256 _tier5Items, uint256 _tier6Items
    ) {
        if (_realtime == true) {
            return (
                getUserBalanceOfTier(_user, 1), 
                getUserBalanceOfTier(_user, 2), 
                getUserBalanceOfTier(_user, 3), 
                getUserBalanceOfTier(_user, 4), 
                getUserBalanceOfTier(_user, 5), 
                getUserBalanceOfTier(_user, 6)
            );
        } else {
            return (
                woolMinter.totalUserItemsOfTier(_user, 1), 
                woolMinter.totalUserItemsOfTier(_user, 2), 
                woolMinter.totalUserItemsOfTier(_user, 3), 
                woolMinter.totalUserItemsOfTier(_user, 4), 
                woolMinter.totalUserItemsOfTier(_user, 5), 
                woolMinter.totalUserItemsOfTier(_user, 6)
            );
        }
    }

    // Get count of all items across all tiers for one _user
    function getUserTotalItems(address _user) external view returns (uint256) {
        return (
            woolMinter.totalUserItemsOfTier(_user, 1) + woolMinter.totalUserItemsOfTier(_user, 2) + woolMinter.totalUserItemsOfTier(_user, 3) + 
            woolMinter.totalUserItemsOfTier(_user, 4) + woolMinter.totalUserItemsOfTier(_user, 5) + woolMinter.totalUserItemsOfTier(_user, 6)
        );
    }

    // Items of user as of right now (live balance check)
    function realtimeItemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = IERC721(degenNFT[1]).balanceOf(_user);
        uint256 _tier2 = IERC721(degenNFT[2]).balanceOf(_user);
        uint256 _tier3 = IERC721(degenNFT[3]).balanceOf(_user);
        uint256 _tier4 = IERC721(degenNFT[4]).balanceOf(_user);
        uint256 _tier5 = IERC721(degenNFT[5]).balanceOf(_user);
        uint256 _tier6 = IERC721(degenNFT[6]).balanceOf(_user);

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
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

    // Get live balance of items, for one _user
    function getUserBalanceOfTier(address _user, uint256 _tierId) public view returns (uint256) {
        address _nft = getContractOf(_tierId);
        return (IERC721(_nft).balanceOf(_user));
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

    //////////////////////////////////////
    // WRITE FUNCTIONS - THESE COST GAS //
    //////////////////////////////////////

    // Create the market item and transfer the item to this contract
    function listItem(address _contract, uint256 _tokenId, uint256 _markup) ifTradingActive() public nonReentrant {
        require(_markup < 6, "INVALID_RANGE");

        address _seller = address(msg.sender);
        uint256 _tier = getTierOf(_contract);

        tierData[_tier]._listingIds.increment();
        uint256 listingId = tierData[_tier]._listingIds.current();

        uint256 _mintPrice = woolMinter.getMintPriceOf(_tier);
        uint256 _markupFactor = (_markup.mul(5));
        uint256 _actualMarkup = (_mintPrice.mul(_markupFactor).div(100));

        uint256 _price = (_mintPrice + _actualMarkup);
    
        tierData[_tier].itemListing[listingId] = MarketItem(
            listingId, _contract, _tokenId, _seller, _price, true
        );

        tierData[_tier].totalListed += 1;

        IERC721(_contract).transferFrom(_seller, address(this), _tokenId);

        uint256 _claimTotal = woolMinter.claimTokens(msg.sender);
        woolMinter.updateItems(msg.sender);

        // Add 1 to total listed
        totalListed += 1;

        emit onClaimTokens(msg.sender, _claimTotal, block.timestamp);
        emit onListItemForSale(listingId, _contract, _tokenId, _seller, _price, true);
    }

    // Buy an NFT - mints first, sells listed items second
    // Sells listed items in a FIFO-style queue

    function buyItem(address _contract) ifTradingActive() public nonReentrant returns (uint256) {

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
            _tokenId = buyItemFromMint(_tier, msg.sender);

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
        uint256 _listingId = tierData[_tierId]._itemsSold.current().add(1);

        // Get details of the listed item
        uint256 price  = tierData[_tierId].itemListing[_listingId]._price;
        uint256 token  = tierData[_tierId].itemListing[_listingId]._tokenId;
        address seller = tierData[_tierId].itemListing[_listingId]._seller;

        // Collect Payment for listed item
        require(IERC20(SHEEPAddress).transferFrom(_recipient, address(this), price), 'Must pay item price');
        
        // Pay the seller for the item
        IERC20(SHEEPAddress).transfer(seller, price);

        // Then give the recipient their item
        IERC721(_contract).transferFrom(address(this), _recipient, token);
        
        // Reset listing data to empty values
        tierData[_tierId].itemListing[_listingId]._contract = address(0);
        tierData[_tierId].itemListing[_listingId]._tokenId = 0;
        tierData[_tierId].itemListing[_listingId]._seller = address(0);
        tierData[_tierId].itemListing[_listingId].forSale = false;

        // Increment the number of items sold
        tierData[_tierId]._itemsSold.increment();

        // Add 1 to total resold
        totalResold += 1;

        // Add to total profits
        totalProfits += price;

        // Return the token Id of the item sold
        return token;
    }

    // Buy an NFT, specifying recipient and tier.
    // Caller must approve this contract to spend their SH33P

    function buyItemFromMint(uint256 _tierId, address _recipient) internal returns (uint256 _newItemID) {

        // Get contract and mint price
        address _contract = getContractOf(_tierId);
        uint256 _mintPrice = woolMinter.getMintPriceOf(_tierId);

        tierData[_tierId].totalMinted += 1;

        // Collect Mint Payment
        require(IERC20(SHEEPAddress).transferFrom(_recipient, mintFeeSplitter, _mintPrice), 'Must pay minting fee');

        totalMinted += 1;
        totalProfits += _mintPrice;

        return IDegenNFT(_contract).mint(_recipient);
    }

    // Mint tokens, pro-rata of seconds since last claim
    // This contract must be whitelisted to mint the token
    function claimTokens() whenNotPaused() nonReentrant() public returns (uint256) {
        
        uint256 _claimTotal = woolMinter.claimTokens(msg.sender);
        woolMinter.updateItems(msg.sender);

        emit onClaimTokens(msg.sender, _claimTotal, block.timestamp);
        return _claimTotal;
    }

    ////////////////////////////////////////////////////////

    // ERC-721 Receiver function
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    ////////////////////////////////////////////
    // DEV FUNCTIONS - MAINTENANCE & UPGRADES //
    ////////////////////////////////////////////

    // Set the Mint Fee Splitter Address
    function setMintFeeSplitter(address _address) onlyOwner() public returns (bool _success) {
        require(Address.isContract(_address), "INVALID_ADDRESS");
        require(tradingEnabled == false, "MARKET_OPEN");
        
        address _current = mintFeeSplitter;
        mintFeeSplitter = _address;

        emit onSetMintFeeSplitter(msg.sender, _current, mintFeeSplitter, block.timestamp);
        return true;
    }

    // Pause buying and listing of NFT Items
    function toggleMarket(bool _enabled) onlyOwner() public returns (bool _success) {
        
        tradingEnabled = _enabled;

        emit onToggleTrading(msg.sender, _enabled, block.timestamp);
        return true;
    }

    // Pause the claims from the WoolFactory
    // NOTE: If the system is started, balances can still build up
    // NOTE: This stops initial build-up before WoolShed is ready.
    function pauseClaims() onlyOwner() public returns (bool _success) {
        _pause();
    }

    // Unpause the claims from the WoolFactory
    // NOTE: Do this only when WoolFactory launches
    function unpauseClaims() onlyOwner() public returns (bool _success) {
        _unpause();
    }
}