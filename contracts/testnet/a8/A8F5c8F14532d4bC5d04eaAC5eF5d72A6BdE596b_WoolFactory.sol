// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Counters.sol";

import "./IERC20.sol";
import "./IERC721.sol";
import "./IEliteNFT.sol";

import "./WoolToken.sol";

import "./Queue.sol";
import "./Whitelist.sol";
import "./ReentrancyGuard.sol";

import "./FreeParticipantRegistry.sol";

interface IDegenNFT {
    function mint(address player) external returns (uint256);
}

contract WoolFactory is Whitelist, Queue, ReentrancyGuard {
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
        Queue.QueueData itemsForSale;
        uint256 totalMinted;
        uint256 totalListed;
        uint256 totalItems;
    }

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20    public payableToken;  // SH33P token
    WoolToken public rewardsToken;   // WOOL token
    IDegenNFT public degenNFT;      // L4MB NFTs

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    MarketItem[] private marketitems;

    FreeParticipantRegistry private freeParticipantRegistry;

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

    mapping(address => mapping(uint256 => uint256)) private itemIdToMarketId;

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
        address _SHEEP, 
        address _WOOL, 
        address _reserveAddress, 
        address _nft1, 
        address _nft2, 
        address _nft3, 
        address _nft4, 
        address _nft5, 
        address _nft6
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

    // Find a count of all NFTs from all tiers for an address
    function itemsOf(address _user, bool _realtime) public view returns (uint256) {
        uint256 _tier1;
        uint256 _tier2;
        uint256 _tier3;
        uint256 _tier4;
        uint256 _tier5;
        uint256 _tier6;
        
        if (_realtime == true) {
            _tier1 = IERC721(nft1).balanceOf(_user);
            _tier2 = IERC721(nft2).balanceOf(_user);
            _tier3 = IERC721(nft3).balanceOf(_user);
            _tier4 = IERC721(nft4).balanceOf(_user);
            _tier5 = IERC721(nft5).balanceOf(_user);
            _tier6 = IERC721(nft6).balanceOf(_user);
        } else {
            _tier1 = _degen[_user].level1Items;
            _tier2 = _degen[_user].level2Items;
            _tier3 = _degen[_user].level3Items;
            _tier4 = _degen[_user].level4Items;
            _tier5 = _degen[_user].level5Items;
            _tier6 = _degen[_user].level6Items;
        }

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Find how many NFTs of a tier have been minted
    function mintedOfTier(uint256 _tier) public view returns (uint256) {
        return (_itemTier[_tier].totalMinted);
    }

    // Find how many NFTs of a tier are available
    function availableOfTier(uint256 _tier) public view returns (uint256) {
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

    //////////////////////
    // MARKET FUNCTIONS //
    //////////////////////

    // Get items for sale by Tier
    function getTierItemsForSale(uint256 _tier) public view returns (uint256[] memory) {
        return Queue.viewData(_itemTier[_tier].itemsForSale);
    }

    /* Returns the sale IDs of all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns the sale IDs of only items that a user has purchased */
    function fetchMyPurchasedItems() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns the sale IDs of only items a user has created */
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

    // Mintable items remaining of all tiers
    function mintableNFTsRemaining() public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return (
            IEliteNFT(nft1).mintableRemaining(), 
            IEliteNFT(nft2).mintableRemaining(), 
            IEliteNFT(nft3).mintableRemaining(), 
            IEliteNFT(nft4).mintableRemaining(), 
            IEliteNFT(nft5).mintableRemaining(), 
            IEliteNFT(nft6).mintableRemaining()
        );
    }

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

    // Set the exemption list for fees and charges
    function setFreeParticipantRegistry(FreeParticipantRegistry _freeParticipantRegistry) public onlyOwner {
        freeParticipantRegistry = _freeParticipantRegistry;
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

        // Collect Mint Payment if not a 'free participant'
        if(!freeParticipantRegistry.freeParticipant(msg.sender)){
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
    function _movePurchasedItem(address _contract, uint256 _id, address _recipient) internal {

        uint256 _saleId = (itemIdToMarketId[_contract][_id]);

        MarketItem storage marketitem = marketitems[_saleId];
        
        uint256 _cost = marketitem.price;

        // Collect Payment if not a 'free participant'
        if(!freeParticipantRegistry.freeParticipant(msg.sender)){
            require(_collectFee(msg.sender, _cost), 'Must pay minting fee');
        }

        IERC721(_contract).transferFrom(address(this), _recipient, _id);
    }

    // Next item of a tier
    function _nextItemOf(uint256 _tier) internal view returns (address, uint256) {
        uint256 _saleId = Queue.viewData(_itemTier[_tier].itemsForSale)[0];
        return (getContractOf(_tier), _saleId);
    }

    // Buy Item (internal function, for ease of calling)
    function _buyItem(address _recipient, uint256 _tier) internal returns (uint256) {
        uint256 _mintable = availableOfTier(_tier);
        uint256 _buyable = getTierItemsForSale(_tier).length;
        require(_mintable > 0 || _buyable > 0, "NO_MINTABLE_OR_BUYABLE_ITEMS");

        uint256 _purchasedItemId;

        if (_mintable > 0) {
            _purchasedItemId = _mintPurchasedItem(_tier, _recipient);
            _itemTier[_tier].totalMinted += 1;
        } else {
            (address _nft, uint256 _id) = _nextItemOf(_tier);
            _purchasedItemId = _id;

            // Pop the 'itemsForSale' tier queue
            popQueue(_tier);

            // Move the purchased item to the user
            _movePurchasedItem(_nft, _id, _recipient);
        }

        emit onPurchaseItem(msg.sender, _recipient, _tier, _purchasedItemId, block.timestamp);
        return _purchasedItemId;
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
        require(markupLevel >= 0 || markupLevel < 5);

        // Get the item information
        uint256 _tier = getTierOf(nftContract);
        uint256 price = getPriceOf(_tier);

        // Create a sale ID for the item, then increment
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
    
        // Add item to the index, then move the NFT to this contract
        idToMarketItem[itemId] =  MarketItem(
            itemId, 
            nftContract, 
            tokenId, 
            payable(msg.sender), 
            payable(address(0)), 
            price, 
            markupLevel, 
            false
        );

        // Add this market item to the array for sale tier items
        addToQueue(_tier, itemId);

        // Store the market ID of this listed item against the contract and item ID... we'll need this later!
        itemIdToMarketId[nftContract][tokenId] = itemId;
        
        // Move the NFT Item to this contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Emit event
        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, markupLevel, false);
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

    // QUEUE MANAGEMENT

    // Hit this when an item has been listed
    function addToQueue(uint256 _tierId, uint d) internal {
        push(_itemTier[_tierId].itemsForSale, d);
    }
    
    // Hit this when an item has been sold
    function popQueue(uint256 _tierId) internal returns (uint) {
        return pop(_itemTier[_tierId].itemsForSale);
    }
    
    // How long is the line?
    function queueLength(uint256 _tierId) internal view returns (uint) {
        return length(_itemTier[_tierId].itemsForSale);
    }
}