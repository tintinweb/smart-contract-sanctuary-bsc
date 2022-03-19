// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Counters.sol";

import "./IERC20.sol";
import "./IERC721.sol";
import "./IEliteNFT.sol";
import "./IERC721Receiver.sol";

import "./WoolToken.sol";

import "./Whitelist.sol";
import "./ReentrancyGuard.sol";

interface IDegenNFT {
    function mint(address player) external returns (uint256);
}

contract WoolFactory is IERC721Receiver, Whitelist, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using Counters for Counters.Counter;

    /////////////
    // STRUCTS //
    /////////////

    struct DegenPlayer {
        uint256 claimed;  // How many tokens claimed?
        uint256 xClaimed; // How many claims total?

        uint256 lastClaimTime; // When was the last claim time?

        uint256 level1Items;
        uint256 level2Items;
        uint256 level3Items;
        uint256 level4Items;
        uint256 level5Items;
        uint256 level6Items;
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 markupLevel;
        bool sold;
    }

    struct Tier {
        mapping(uint256 => MarketItem) queue;
        uint256 queueFront;
        uint256 queueBack;

        uint256 totalMinted;
        uint256 totalListed;
        uint256 totalItems;
    }

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20    public payableToken;  // SH33P token
    WoolToken public rewardsToken;   // WOOL token

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    MarketItem[] public marketitems;

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    address public WOOLAddress;
    address public SHEEPAddress;
    address public reserveAddress;

    address public nft1;
    address public nft2;
    address public nft3;
    address public nft4;
    address public nft5;
    address public nft6;

    uint256 public totalTiers;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(uint256 => Tier) internal _itemTier;

    mapping(address => bool) internal _isDegenNFT;

    mapping(address => DegenPlayer) internal _degen;

    mapping(uint256 => MarketItem) private idToMarketItem;

    mapping(address => bool) internal royaltyFree; // If true, address does NOT pay royalties

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onBuyItem(
        address sender, 
        address recipient, 
        uint256 tierId, 
        uint256 _timestamp
    );

    event onPurchaseItem(
        address sender, 
        address recipient, 
        uint256 tier, 
        uint256 purchasedItemId, 
        uint256 _timestamp
    );

    event onClaimTokens(
        address sender, 
        uint256 _lastClaim, 
        uint256 _timeDiff, 
        uint256 _wps, 
        uint256 _toMint, 
        uint256 timestamp
    );

    event MarketItemCreated(
        uint256 indexed itemId, 
        address indexed nftContract, 
        uint256 indexed tokenId, 
        address seller, 
        address owner, 
        uint256 price, 
        uint256 markupLevel, 
        bool sold
    );

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor (
        address _SHEEP, address _WOOL, address _reserveAddress,
        address _nft1, address _nft2, address _nft3, address _nft4, address _nft5, address _nft6
    ) {
        nft1 = _nft1;
        nft2 = _nft2;
        nft3 = _nft3;
        nft4 = _nft4;
        nft5 = _nft5;
        nft6 = _nft6;

        _isDegenNFT[_nft1] = true;
        _isDegenNFT[_nft2] = true;
        _isDegenNFT[_nft3] = true;
        _isDegenNFT[_nft4] = true;
        _isDegenNFT[_nft5] = true;
        _isDegenNFT[_nft6] = true;

        _itemTier[1].totalItems = 83500;
        _itemTier[2].totalItems = 41750;
        _itemTier[3].totalItems = 20875;
        _itemTier[4].totalItems = 10043;
        _itemTier[5].totalItems = 5021;
        _itemTier[6].totalItems = 2600;

        totalTiers = 6;

        WOOLAddress = _WOOL;
        SHEEPAddress = _SHEEP;

        payableToken = IERC20(SHEEPAddress);
        rewardsToken = WoolToken(WOOLAddress);

        reserveAddress = _reserveAddress;
    }

    receive() external payable {

    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Buy an NFT from the Wool Factory.
    function buyItem(address _recipient, uint256 _tier) nonReentrant() public returns (uint256) {
        return _buyItem(_recipient, _tier);
    }

    //////////////////////////////////////////////////////////////
    
    /* Places an item for sale on the marketplace */
    function listItem(address nftContract, uint256 tokenId, uint8 _markupLevel) public nonReentrant {
        _listItem(nftContract, tokenId, _markupLevel);
    }

    // Mint WOOL tokens, pro-rata of seconds since last claim
    // This contract must be whitelisted to mint the token
    function claimWool() nonReentrant() public returns (uint256) {
        
        uint256 _claimTotal = _claimWool();
        
        _updateUserNFTs(msg.sender);

        return _claimTotal;
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function recordedItemsOf(address _user) public view returns (uint256) {
        uint256 _tier1 = _degen[_user].level1Items;
        uint256 _tier2 = _degen[_user].level2Items;
        uint256 _tier3 = _degen[_user].level3Items;
        uint256 _tier4 = _degen[_user].level4Items;
        uint256 _tier5 = _degen[_user].level5Items;
        uint256 _tier6 = _degen[_user].level6Items;

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Items of user as of right now (live balance check)
    function realtimeItemsOf(address _user) public view returns (uint256) {
        uint256 _tier1 = IERC721(nft1).balanceOf(_user);
        uint256 _tier2 = IERC721(nft2).balanceOf(_user);
        uint256 _tier3 = IERC721(nft3).balanceOf(_user);
        uint256 _tier4 = IERC721(nft4).balanceOf(_user);
        uint256 _tier5 = IERC721(nft5).balanceOf(_user);
        uint256 _tier6 = IERC721(nft6).balanceOf(_user);

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Find how many NFTs of a tier have been minted
    function mintedOfTier(uint256 _tier) public view returns (uint256) {
        return (_itemTier[_tier].totalMinted);
    }

    // Find how many NFTs of a tier are available
    function totalAvailableOfTier(uint256 _tier) public view returns (uint256) {
        uint256 _minted = mintedOfTier(_tier);
        uint256 _total = totalItemsOfTier(_tier);

        return (_total.sub(_minted));
    }

    // Find how many NFTs of a tier there are in total
    function totalItemsOfTier(uint256 _tier) public view returns (uint256) {
        return (_itemTier[_tier].totalItems);
    }

    // How much WOOL is available for the user to mint
    function availableWoolOf(address _user) public view returns (uint256) {

        // Get the last time of action, calculate the difference between then and now.
        uint256 _lastClaim = lastClaimTimeOf(_user);
        uint256 _timeDiff = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _wps = woolPerSecondOf(_user);
        uint256 _toMint = ((_wps).mul(_timeDiff));

        return _toMint;
    }

    // Get tier of a contract address
    function getTierOf(address _contract) public view returns (uint256 _id) {
        if (_contract == nft1) {_id = 1;}
        if (_contract == nft2) {_id = 2;}
        if (_contract == nft3) {_id = 3;}
        if (_contract == nft4) {_id = 4;}
        if (_contract == nft5) {_id = 5;}
        if (_contract == nft6) {_id = 6;}
    }

    // Get contract address of one of the NFTs (by Tier ID)
    function getContractOf(uint256 _tier) public view returns (address) {
        if (_tier == 1) {return nft1;}
        if (_tier == 2) {return nft2;}
        if (_tier == 3) {return nft3;}
        if (_tier == 4) {return nft4;}
        if (_tier == 5) {return nft5;}
        if (_tier == 6) {return nft6;}

        return address(0);
    }

    // Get the price of one of the NFTs (by Tier ID)
    function getPriceOf(uint256 _tier) public pure returns (uint256) {
        if (_tier == 1) {return 2e18;}
        if (_tier == 2) {return 4e18;}
        if (_tier == 3) {return 8e18;}
        if (_tier == 4) {return 16e18;}
        if (_tier == 5) {return 32e18;}
        if (_tier == 6) {return 64e18;}

        return 0;
    }

    // WOOL per Second of an address
    function woolPerSecondOf(address _user) public view returns (uint256) {
        uint256 _tier1 = _degen[_user].level1Items;
        uint256 _tier2 = _degen[_user].level2Items;
        uint256 _tier3 = _degen[_user].level3Items;
        uint256 _tier4 = _degen[_user].level4Items;
        uint256 _tier5 = _degen[_user].level5Items;
        uint256 _tier6 = _degen[_user].level6Items;

        uint256 _tokens = (
            (_tier1 * getPriceOf(1)) + 
            (_tier2 * getPriceOf(2)) + 
            (_tier3 * getPriceOf(3)) + 
            (_tier4 * getPriceOf(4)) + 
            (_tier5 * getPriceOf(5)) + 
            (_tier6 * getPriceOf(6))
        );

        uint256 _perDay = (_tokens.div(365));
        uint256 _perSec = (_perDay.div(86400));

        return (_perSec);
    }

    // Last Claim Time of an address
    function lastClaimTimeOf(address _user) public view returns (uint256) {

        // If the user has not claimed even once, their first claim time is yet untracked
        // For this, we keep their timestamp at the latest one of the block.
        if (_degen[_user].xClaimed == 0) {
            return block.timestamp;
        }
        return (_degen[_user].lastClaimTime);
    }

    // Find claimed amount of WOOL by an address
    function claimedOf(address _user) public view returns (uint256) {
        return (_degen[_user].claimed);
    }

    // Find how many claims total an address has made
    function claimsOf(address _user) public view returns (uint256) {
        return (_degen[_user].xClaimed);
    }

    // Get the item at a specific position of the queue
    function queueItem(uint256 _tier, uint256 _position) public view returns (
        uint256, address, uint256, address, address, uint256, uint256, bool
    ) {
        uint256 _listingId = _itemTier[_tier].queue[_position].itemId;

        // Define the marketitem object
        MarketItem memory marketitem = marketitems[_listingId];

        return (
            marketitem.itemId,
            marketitem.nftContract,
            marketitem.tokenId,
            marketitem.seller,
            marketitem.owner,
            marketitem.price,
            marketitem.markupLevel,
            marketitem.sold
        );
    }

    // Get the front position of the queue
    function queueFront(uint256 _tier) public view returns (uint256 _front) {
        return (_itemTier[_tier].queueFront);
    }

    // Get the back position of the queue
    function queueBack(uint256 _tier) public view returns (uint256 _back) {
        return (_itemTier[_tier].queueBack);
    }

    // Next item for sale, of a tier
    function nextItemOf(uint256 _tier) public view returns (address _contract, uint256 _tokenId, uint256 _listingId) {
        
        // Find the next listing ID in the tier's mapping
        _listingId = _itemTier[_tier].queueFront;

        // Define the marketitem object
        MarketItem memory marketitem = marketitems[_listingId];

        // Get the tokenId of the next item
        _tokenId = marketitem.tokenId;

        // Return the contract of the tier, the token id and the listing ID
        return (getContractOf(_tier), _tokenId, _listingId);
    }

    //////////////////////
    // MARKET FUNCTIONS //
    //////////////////////

    // Mintable items remaining of a single tier
    function canMint(address _nft) public view returns (bool) {
        uint256 _available = IEliteNFT(_nft).mintableRemaining();
        return (_available > 0);
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Set the NFT Reward Reserve Address
    function setReserve(address _newReserve) public onlyOwner() {
        reserveAddress = _newReserve;
    }

    // Set the Payment Token Address
    function setPaymentToken(address _newToken) public onlyOwner() {
        SHEEPAddress = _newToken;
        payableToken = IERC20(SHEEPAddress);
    }

    // Set the Rewards Token Address
    function setRewardsToken(address _newToken) public onlyOwner() {
        WOOLAddress = _newToken;
        rewardsToken = WoolToken(WOOLAddress);
    }

    // Set the Royalty Free permission of an address
    function setFreeUser(address _address, bool _selection) public onlyOwner() {
        royaltyFree[_address] = _selection;
    }

    ////////////////////////////////////
    // INTERNAL AND PRIVATE FUNCTIONS //
    ////////////////////////////////////

    // Mint an NFT item
    function _mintItem(uint256 _tierId, address _recipient) internal returns (uint256) {
        address _contract = getContractOf(_tierId);
        return IDegenNFT(_contract).mint(_recipient);
    }

    // Buy an NFT, specifying recipient and tier.
    // Caller must approve this contract to spend their SH33P
    function _mintPurchasedItem(uint256 _tierId, address _recipient) internal returns (uint256) {
        require(_tierId >= 0 && _tierId < (totalTiers + 1), "INVALID_RANGE");

        uint256 _mintPrice = getPriceOf(_tierId);

        // Collect Mint Payment if not 'royaltyFree'
        if(royaltyFree[msg.sender] == false){
            require(_collectFee(msg.sender, _mintPrice), 'Must pay minting fee');
        }

        // Mint Item
        uint256 _newItemID = _mintItem(_tierId, _recipient);

        // Tell the network, successful function!
        emit onBuyItem(msg.sender, _recipient, _tierId, block.timestamp);
        return _newItemID;
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function _buyItemFromMarket(uint256 _tier, uint256 itemId) internal returns (uint256) {

        // Get NFT contract address
        address nftContract = getContractOf(_tier);
        uint256 price = getPriceOf(_tier);

        // Prepare details for purchase/sale of item
        address seller = idToMarketItem[itemId].seller;
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        // Transfer tokens from buyer to seller
        require(IERC20(SHEEPAddress).transferFrom(msg.sender, seller, price), "MUST_PAY_ASKING_PRICE");

        // Give item from Factory's custody, to buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        // Update stats
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();

        // Return sold item ID
        return tokenId;
    }

    // Collect the mint fee
    function _collectFee(address _payer, uint256 _amount) internal returns(bool) {

        IERC20(SHEEPAddress).transferFrom(_payer, reserveAddress, _amount);

        return true;
    }

    // Give the purchased item to the _recipient
    function _movePurchasedItem(uint256 _listingId, address _recipient) internal {

        MarketItem memory marketitem = marketitems[_listingId];
        
        uint256 _cost = marketitem.price;

        // Collect Payment if not a 'free participant'
        if(!royaltyFree[msg.sender]){
            require(_collectFee(msg.sender, _cost), 'Must pay minting fee');
        }

        IERC721(marketitem.nftContract).transferFrom(address(this), _recipient, marketitem.tokenId);
    }

    // Buy Item (internal function, for ease of calling)
    function _buyItem(address _recipient, uint256 _tier) internal returns (uint256) {

        // Find how many NFTs of a tier are available
        uint256 _mintableItemCount = totalAvailableOfTier(_tier);

        // Find how many NFTs are listed for purchase, on the same tier
        uint256 _listedItemCount = (_itemTier[_tier].queueBack.sub(_itemTier[_tier].queueFront));

        // Require that there be at least something to buy
        require(_mintableItemCount > 0 || _listedItemCount > 0, "NO_MINTABLE_OR_BUYABLE_ITEMS");

        // Initialise the purchased item id number
        uint256 _purchasedTokenId;

        // If there's mintables, do that first
        if (_mintableItemCount > 0) {

            // the purchased item ID calls to mint the item to the buyer
            _purchasedTokenId = _mintPurchasedItem(_tier, _recipient);

            // Increment the 'totalMinted' count for the tier, so we don't overmint each tier's supply
            _itemTier[_tier].totalMinted += 1;

        // If there's no mintables on the tier,
        } else {

            // get the contract address and the 'listing ID' of the next item on the tier
            (address _contract, uint256 _tokenId, uint256 _listingId) = nextItemOf(_tier);

            // purchased item ID is the listing number
            _purchasedTokenId = _tokenId;

            // Pop the 'itemsForSale' tier queue
            pop(getTierOf(_contract));

            // Move the purchased item to the user
            _movePurchasedItem(_listingId, _recipient);
        }

        // Tell the network, successful function
        emit onPurchaseItem(msg.sender, _recipient, _tier, _purchasedTokenId, block.timestamp);
        return _purchasedTokenId;
    }

    // Claim Wool - call before anything which changes calculation parameters
    function _claimWool() internal returns (uint256) {
        uint256 _lastClaim = lastClaimTimeOf(msg.sender);
        uint256 _timeDiff = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _wps = woolPerSecondOf(msg.sender);

        uint256 _toMint = availableWoolOf(msg.sender);

        if (_toMint > 0) {
            // Mint the appropriate tokens
            rewardsToken.mint(msg.sender, _toMint);
        }

        // Update stats
        _degen[msg.sender].lastClaimTime = block.timestamp;
        _degen[msg.sender].claimed += _toMint;
        _degen[msg.sender].xClaimed += 1;

        // Tell the network, successful function
        emit onClaimTokens(msg.sender, _lastClaim, _timeDiff, _wps, _toMint, block.timestamp);
        return _toMint;
    }

    // List Item for sale (internal function for ease of calling)
    function _listItem(address nftContract, uint256 tokenId, uint8 markupLevel) internal {

        // Require the markup level of the listing to be 1 to 5 inclusive
        require(markupLevel >= 0 || markupLevel < 5);

        // Get the item information
        uint256 _tier = getTierOf(nftContract);
        uint256 price = getPriceOf(_tier);

        // Create a sale ID for the item, then increment
        _itemIds.increment();
        uint256 listingId = _itemIds.current();
    
        // Add item to the index, then move the NFT to this contract
        idToMarketItem[listingId] =  MarketItem(
            listingId, 
            nftContract, 
            tokenId, 
            payable(msg.sender), 
            payable(address(0)), 
            price, 
            markupLevel, 
            false
        );

        // Add this market item to the array for sale tier items
        addItemToQueue(_tier, listingId);

        // Claim WOOL token earnings
        _claimWool();

        // Update NFT count, so user doesn't earn from a listed NFT
        _updateUserNFTs(msg.sender);
        
        // Move the NFT Item to this contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Emit event
        emit MarketItemCreated(listingId, nftContract, tokenId, msg.sender, address(0), price, markupLevel, false);
    }

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function _updateUserNFTs(address _user) internal {
        _degen[_user].level1Items = IERC721(nft1).balanceOf(_user);
        _degen[_user].level2Items = IERC721(nft2).balanceOf(_user);
        _degen[_user].level3Items = IERC721(nft3).balanceOf(_user);
        _degen[_user].level4Items = IERC721(nft4).balanceOf(_user);
        _degen[_user].level5Items = IERC721(nft5).balanceOf(_user);
        _degen[_user].level6Items = IERC721(nft6).balanceOf(_user);
    }

    // ERC-721 Receiver function
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // QUEUE FUNCTIONS

    // Add item to sale queue (of tier)
    function addItemToQueue(uint256 _tier, uint256 _marketItemId) internal {

        // Add _marketItemId to the queue
        _itemTier[_tier].queueBack = _marketItemId;

        // Will overflow automatically and reset itself
        _itemTier[_tier].queueBack++;
    }

    // Pop the tier queue (to "bring forward" the next item in the list)
    function pop(uint256 _tier) internal {

        // Sanity checks
        require(_itemTier[_tier].queueFront != _itemTier[_tier].queueBack);

        // Clean-up previous entry
        _itemTier[_tier].queueFront = 0x0;
        
        // Will overflow automatically and reset itself
        _itemTier[_tier].queueFront++;
    }
}