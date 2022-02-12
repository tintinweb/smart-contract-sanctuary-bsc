// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../token/ERC721/BitHotelRoomCollectionUpgradeable.sol";

contract BithotelMarketplaceUpgradeable is Initializable, AccessControlUpgradeable, ERC721HolderUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Enum representing collection category
    // None  - 0
    // Character  - 1
    // Room  - 2
    // Furniture - 3
    // Wearable - 4
    // Badge - 5
    // Consumable - 6
    // Background - 7
    enum Category { 
        None,
        Character,
        Room,
        Furniture,
        Wearable,
        Badge,
        Consumable, 
        Background
    }

    // Enum representing listing status
    // Cancelled - 0
    // Added - 1
    // Executed - 2
    // Removed - 3
    enum Status {
        Cancelled,
        Added,
        Executed,
        Removed
    }

    struct ERC721Listing {
        uint256 listingId;
        address seller;
        address erc721TokenAddress;
        uint256 erc721TokenId;
        Category category;
        uint256 priceInWei;
        uint256 timeCreated;
        uint256 timePurchased;
        Status status;
    }

    struct ListingListItem {
        uint256 parentListingId;
        uint256 listingId;
        uint256 childListingId;
    }

    struct MarketplaceCategory {
        address erc721TokenAddress;
        Category category;
    }

    address private _sTimelockController;
    bool public initializerRan;
    bool private _isListingFeeEnabled;
    uint256 private _listingFeeInWei;
    IERC20Upgradeable private _token;
    address private _tokenAddress;
    IERC20Upgradeable private _bth;
    address private _bthAddress;
    address private _wallet;
    address private _burnAddress;
    address private _thisAddress;

    address[] private _includedErc721TokenAddresses;
    uint256 private _sListingFeeInWei;

    CountersUpgradeable.Counter private _sNextERC721ListingId;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant COLLECTIONS = keccak256("COLLECTIONS");

    address[] private _includedCollections;
    uint256[] private _listingIds;
    mapping(address => uint256) private _includedCollectionsIndex;
    mapping(uint256 => uint256) private _listingIdIndex;

    mapping(uint256 => ListingListItem) private _erc721ListingListItem;
    mapping(uint256 => ListingListItem) private _erc721OwnerListingListItem;
    mapping(uint256 => address) private _categoryToTokenAddress;
    mapping(uint256 => mapping(string => uint256)) private _erc721ListingHead;
    mapping(address => Category) private _erc721Categories;
    mapping(address => mapping(uint256 => mapping(string => uint256))) private _erc721OwnerListingHead;
    mapping(address => mapping(uint256 => mapping(address => uint256))) private _erc721TokenToListingId;

    mapping(address => uint256) private _includedCollectionIndex;
    mapping(uint256 => ERC721Listing) private _erc721Listings;

    modifier onlyTimelock(address mTimelockController) {
        // solhint-disable-next-line reason-string
        require(mTimelockController == timelockController(), "BithotelMarketplace: not an timelock controller addres");
        _;
    }

    event TimelockChanged(address newAddress);
    event TokenChanged(address newToken);
    event BthChanged(address newBth);
    event BthBurned(address from, address to, uint256 amount);
    event StatusChanged(uint256 listingId, Status status);
    event IncludedErc721TokenAddressesAdded(address[] addresses);
    event IncludedErc721TokenAddressesRemoved(address[] addresses);

    event ERC721ListingAdd(
        uint256 indexed listingId,
        address indexed seller,
        address erc721TokenAddress,
        uint256 erc721TokenId,
        Category indexed category,
        uint256 time
    );

    event ERC721ExecutedListing(
        uint256 indexed listingId,
        address indexed seller,
        address buyer,
        address erc721TokenAddress,
        uint256 erc721TokenId,
        uint256 indexed category,
        uint256 priceInWei,
        uint256 time
    );
    event ERC721ListingCancelled(uint256 indexed listingId, uint256 category, uint256 time);
    event ERC721ListingRemoved(uint256 indexed listingId, uint256 category, uint256 time);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    function initialize(
        address mBth,
        address mToken,
        address mOwner,
        address mWallet,
        address mTimelockController
    ) public initializer {
        __AccessControl_init();
        __ERC721Holder_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __BithotelMarketplace_init_unchained(mBth, mToken, mOwner, mWallet, mTimelockController);
    }

     // solhint-disable-next-line func-name-mixedcase
    function __BithotelMarketplace_init_unchained(
        address mBth,
        address mToken,
        address mOwner,
        address mWallet,
        address mTimelockController
    ) internal onlyInitializing {
        // solhint-disable-next-line reason-string
        require(mBth != address(0), "BithotelMarketplace: bth token is the zero address");
        // solhint-disable-next-line reason-string
        require(mToken != address(0), "BithotelMarketplace: token is the zero address");
        // solhint-disable-next-line reason-string
        require(mOwner != address(0), "BithotelMarketplace: owner is the zero address");
        // solhint-disable-next-line reason-string
        require(mWallet != address(0), "BithotelMarketplace: wallet is the zero address");
        // solhint-disable-next-line reason-string
        require(mTimelockController != address(0), "BithotelMarketplace: timelock controller is the zero address");

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, mOwner);
        _grantRole(UPGRADER_ROLE, _msgSender());

        _bthAddress = mBth;
        _bth = IERC20Upgradeable(mBth);
        _tokenAddress = mToken;
        _token = IERC20Upgradeable(mToken);
        _wallet = mWallet;
        _sTimelockController = mTimelockController;
        _burnAddress = address(0x000000000000000000000000000000000000dEaD);
        _thisAddress = address(this);
        _isListingFeeEnabled = true;
        _listingFeeInWei = 1 ether / 4; // 0,25 BTH for each listing
        initializerRan = true;
    }

    function version() external pure virtual returns (string memory) {
        return "1.0";
    }

     function getChainId() external view virtual returns (uint256) {
        return block.chainid;
    }

    ///@notice Get a room listing details through an identifier
    ///@dev Will throw if the listing does not exist
    ///@param mListingId The identifier of the listing to query
    function getRoomListing(uint256 mListingId) external view virtual returns (ERC721Listing memory listing_, uint256 number, string memory floorId, string memory roomTypeId) {
        listing_ = _erc721Listings[mListingId];
        // solhint-disable-next-line reason-string
        require(listing_.timeCreated != 0, "BithotelMarketplace: ERC721 listing does not exist");
        BitHotelRoomCollectionUpgradeable collection = BitHotelRoomCollectionUpgradeable(listing_.erc721TokenAddress);
        // solhint-disable-next-line reason-string
        require(collection.exists(listing_.erc721TokenId), "BithotelMarketplace: BitHotelRoomCollection does not exist");
        (number, floorId, roomTypeId) = collection.getRoomInfos(listing_.erc721TokenId);
    }

    ///@notice Get an ERC721 listing details through an identifier
    ///@dev Will throw if the listing does not exist
    ///@param mListingId The identifier of the ERC721 listing to query
    ///@return listing_ A struct containing certain details about the ERC721 listing like timeCreated etc

    function getERC721Listing(uint256 mListingId) external view virtual returns (ERC721Listing memory listing_) {
        listing_ = _erc721Listings[mListingId];
        // solhint-disable-next-line reason-string
        require(listing_.timeCreated != 0, "BithotelMarketplace: ERC721 listing does not exist");
    }

    function bulkAddIncludedCollections(address[] memory erc721TokenAddresses) external virtual nonReentrant onlyTimelock(_msgSender()) {
        // solhint-disable-next-line reason-string
        require(erc721TokenAddresses.length > 0, "BithotelMarketplace: empty addresses");
        for (uint256 i = 0; i < erc721TokenAddresses.length; i++) {
            address included = erc721TokenAddresses[i];
            _addIncludedCollection(included);
        }
        emit IncludedErc721TokenAddressesAdded(erc721TokenAddresses);
    }

    function bulkRemoveIncludedCollections(address[] memory erc721TokenAddresses) external virtual nonReentrant onlyTimelock(_msgSender()) {
        // solhint-disable-next-line reason-string
        require(erc721TokenAddresses.length > 0, "BithotelMarketplace: empty addresses");
        for (uint256 i = 0; i < erc721TokenAddresses.length; i++) {
            address excluded = erc721TokenAddresses[i];
            _removeIncludedCollection(excluded);
        }
        emit IncludedErc721TokenAddressesRemoved(erc721TokenAddresses);
    }

    function setListingFeeEnabled(bool value) external onlyRole(DEFAULT_ADMIN_ROLE) {
         // solhint-disable-next-line reason-string
        require(_isListingFeeEnabled != value, "BithotelMarketplace: listingFeeEnabled already set");
        _isListingFeeEnabled = value;
    }

    function changeListingFeeInWei(uint256 newListingFeeInWei) external onlyRole(DEFAULT_ADMIN_ROLE) {
         // solhint-disable-next-line reason-string
        require(newListingFeeInWei != _listingFeeInWei, "BithotelMarketplace: _listingFeeInWei already set");
        _listingFeeInWei = newListingFeeInWei;
    }


    function changeBth(address mBth) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        // solhint-disable-next-line reason-string
        require(mBth != address(0), "BithotelMarketplace: bth is the zero address");
        // solhint-disable-next-line reason-string
        require(_bthAddress != mBth, "BithotelMarketplace: bth already set");
        _bthAddress = mBth;
        _bth = IERC20Upgradeable(mBth);
        emit BthChanged(mBth);
    }

    function changeToken(address mToken) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        // solhint-disable-next-line reason-string
        require(mToken != address(0), "BithotelMarketplace: token is the zero address");
        // solhint-disable-next-line reason-string
        require(_tokenAddress != mToken, "BithotelMarketplace: token already set");
        _token = IERC20Upgradeable(mToken);
        _tokenAddress = mToken;
        emit TokenChanged(mToken);
    }

    ///@notice Allow the aavegotchi diamond owner or DAO to set the category details for different types of ERC721 NFTs
    ///@param categories An array of structs where each struct contains details about each ERC721 category //erc721TokenAddress and category
    function setERC721Categories(Category[] memory categories) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // for (uint256 i; i < categories.length; i++) {
        //     Category category = categories[i].category;
        //     address tokenAddress = categories[i].erc721TokenAddress;

        //     //Categories should be above 6 to prevent interference
        //     require(category > 6, "BithotelMarketplace: Added category should be above 6");

        //     if (tokenAddress != _thisAddress) {
        //         require(_categoryToTokenAddress[category] == address(0), "BithotelMarketplace: Category has already been set");
        //     }
        //     //TODO
        //     _erc721Categories[tokenAddress] = category;
        //     _categoryToTokenAddress[category] = tokenAddress;
        // }
    }

    // Collections external functions
    function setCollectionController(address erc721TokenAddress, address newController) external virtual nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        // solhint-disable-next-line reason-string
        require(erc721TokenAddress != address(0), "BithotelMarketplace: ERC721 is the zero address");
        // solhint-disable-next-line reason-string
        require(newController != address(0), "BithotelMarketplace: controller is the zero address");
        
        BitHotelRoomCollectionUpgradeable collection = BitHotelRoomCollectionUpgradeable(erc721TokenAddress);
        // solhint-disable-next-line reason-string
        require(collection.controller() == _thisAddress, "BithotelMarketplace: marketplace doesn't control BitHotelRoomCollection");
        // solhint-disable-next-line reason-string
        require(newController != collection.controller(), "BithotelMarketplace: controller already updated");
        collection.setController(newController);
    }

    ///@notice Allow an ERC721 owner to list his NFT for sale
    ///@dev If the NFT has been listed before,it cancels it and replaces it with the new one
    ///@dev NFTs that are listed are immediately locked
    ///@param erc721TokenAddress The contract address of the NFT to be listed
    ///@param erc721TokenId The identifier of the NFT to be listed
    ///@param priceInWei The cost price of the NFT in $GHST

    /// #if_succeeds {:msg "only owner can add admins"} admins[msg.sender];
    function addERC721Listing(
        address erc721TokenAddress,
        uint256 erc721TokenId,
        uint256 priceInWei
    ) external virtual nonReentrant {
        address owner = _msgSender();
        _beforeAddERC721Listing(erc721TokenAddress, erc721TokenId, priceInWei, owner);
        _sNextERC721ListingId.increment();
        uint256 listingId = _sNextERC721ListingId.current();

        uint256 oldListingId = _erc721TokenToListingId[erc721TokenAddress][erc721TokenId][owner];
        if (oldListingId != 0) {
            _cancelERC721Listing(oldListingId, owner);
        }
        _erc721TokenToListingId[erc721TokenAddress][erc721TokenId][owner] = listingId;
        Category category = getERC721Category(erc721TokenAddress, erc721TokenId);
        _erc721Listings[listingId] = ERC721Listing({
            listingId: listingId,
            seller: owner,
            erc721TokenAddress: erc721TokenAddress,
            erc721TokenId: erc721TokenId,
            category: category,
            priceInWei: priceInWei,
            timeCreated: block.timestamp,
            timePurchased: 0,
            status: Status.Added
        });
        _addERC721ListingItem(owner, category, "listed", listingId);
        if (category == Category.Room ) {
            BitHotelRoomCollectionUpgradeable collection = BitHotelRoomCollectionUpgradeable(erc721TokenAddress);

            bool exist = collection.exists(erc721TokenId);
            bool locked = collection.locked(erc721TokenId);
            if (exist && !locked) {
                _lockTokenId(erc721TokenAddress, erc721TokenId);
            } else {
                _receiveERC721(erc721TokenAddress,owner, _thisAddress, erc721TokenId);
            }
        } else {
            _receiveERC721(erc721TokenAddress, owner, _thisAddress, erc721TokenId);
        }
        if (isListingFeeEnabled() && listingFeeInWei() > 0) {
            _receiveTokens(bth(), owner, burnAddress(), listingFeeInWei());
            emit BthBurned(address(0), burnAddress(), listingFeeInWei());
        }
        emit ERC721ListingAdd(listingId, owner, erc721TokenAddress, erc721TokenId, category, priceInWei);
        _afterAddERC721Listing(erc721TokenAddress, erc721TokenId, priceInWei);
    }

    ///@notice Allow an ERC721 owner to cancel his NFT listing by providing the NFT contract address and identifier
    ///@param mErc721TokenAddress The contract address of the NFT to be delisted
    ///@param mErc721TokenId The identifier of the NFT to be delisted
    function cancelERC721ListingByToken(address mErc721TokenAddress, uint256 mErc721TokenId) external virtual nonReentrant {
        _cancelERC721Listing(mErc721TokenAddress, mErc721TokenId, _msgSender());
    }

     ///@notice Allow an ERC721 owner to cancel his NFT listing through the listingID
    ///@param mListingId The identifier of the listing to be cancelled
    function cancelERC721Listing(uint256 mListingId) external virtual nonReentrant {
        _cancelERC721Listing(mListingId, _msgSender());
    }

     ///@notice Allow a buyer to execute an open listing i.e buy the NFT
    ///@dev Will throw if the NFT has been sold or if the listing has been cancelled already
    ///@param mListingId The identifier of the listing to execute
    function executeERC721Listing(uint256 mListingId) external nonReentrant {
        ERC721Listing storage listing = _erc721Listings[mListingId];
        require(listing.timePurchased == 0, "BithotelMarketplace: listing already sold");
        require(listing.status == Status.Added, "BithotelMarketplace: listing not added yet");
        require(listing.timeCreated != 0, "BithotelMarketplace: listing not found");
        uint256 priceInWei = listing.priceInWei;
        address buyer = _msgSender();
        address seller = listing.seller;
        require(seller != buyer, "BithotelMarketplace: buyer can't be seller");
        require(IERC20Upgradeable(token()).balanceOf(buyer) >= priceInWei, "BithotelMarketplace: not enough token balance");

        listing.timePurchased = block.timestamp;
        _removeERC721ListingItem(mListingId, seller);
        _addERC721ListingItem(seller, listing.category, "purchased", mListingId);
        //TODO marketplace tax
        // uint256 daoShare = priceInWei / 100;
        // uint256 pixelCraftShare = (priceInWei * 2) / 100;
        // //AGIP6 adds on 0.5%
        // uint256 playerRewardsShare = priceInWei / 200;

        // uint256 transferAmount = priceInWei - (daoShare + pixelCraftShare + playerRewardsShare);
        // LibERC20.transferFrom(s.ghstContract, buyer, s.pixelCraft, pixelCraftShare);
        // LibERC20.transferFrom(s.ghstContract, buyer, s.daoTreasury, daoShare);
        // LibERC20.transferFrom(s.ghstContract, buyer, seller, transferAmount);
        // //AGIP6 adds on 0.5%
        // LibERC20.transferFrom((s.ghstContract), buyer, s.rarityFarming, playerRewardsShare);

        // if (listing.erc721TokenAddress == _thisAddress) {
        //     //s.aavegotchis[listing.erc721TokenId].locked = false;
        //    // LibAavegotchi.transfer(seller, buyer, listing.erc721TokenId);
        // } else {
        //     // External contracts
        //     IERC721(listing.erc721TokenAddress).safeTransferFrom(seller, buyer, listing.erc721TokenId);
        // }

        // emit ERC721ExecutedListing(
        //     mListingId,
        //     seller,
        //     buyer,
        //     listing.erc721TokenAddress,
        //     listing.erc721TokenId,
        //     listing.category,
        //     listing.priceInWei,
        //     block.timestamp
        // );
    }

    ///@notice Update the ERC721 listing of an address
    ///@param mErc721TokenAddress Contract address of the ERC721 token
    ///@param mErc721TokenId Identifier of the ERC721 token
    ///@param mOwner Owner of the ERC721 token
    function updateERC721Listing(
        address mErc721TokenAddress,
        uint256 mErc721TokenId,
        address mOwner
    ) external nonReentrant {
        _updateERC721Listing(mErc721TokenAddress, mErc721TokenId, mOwner);
    }

    ///@notice Allow an ERC721 owner to cancel his NFT listings through the listingIDs
    ///@param mListingIds An array containing the identifiers of the listings to be cancelled
    function cancelERC721Listings(uint256[] memory mListingIds) 
        external 
        onlyTimelock(_msgSender())
        nonReentrant 
    {
        for (uint256 i; i < mListingIds.length; i++) {
            uint256 listingId = mListingIds[i];
            ListingListItem storage listingItem = _erc721ListingListItem[listingId];
            require(listingItem.listingId != 0, "BithotelMarketplace: listingId does not exist");
            ERC721Listing storage listing = _erc721Listings[listingId];
            listing.status = Status.Cancelled;
            _removeERC721ListingItem(listingId, listing.seller);
            // emit ERC721ListingCancelled(listingId, listing.category, block.number);
        }
    }

    function getAllIncludedCollections() public view virtual returns (address[] memory) {
        return _includedCollections;
    }

    function totalIncludedCollections() public view virtual returns (uint256) {
        return _includedCollections.length;
    }

    function getIncludedCollectionIndex(address erc721TokenAddress) public view virtual returns (uint256) {
        return _includedCollectionsIndex[erc721TokenAddress];
    }

    function isListingFeeEnabled() public view returns(bool) {
        return _isListingFeeEnabled;
    }

    function listingFeeInWei() public view returns(uint256) {
        return _listingFeeInWei;
    }

    function listingIds() public view virtual returns(uint256[] memory) {
        return _listingIds;
    }

    function totalListingIds() public view virtual returns(uint256) {
        return _listingIds.length;
    }

    //return the index of listingId
    function listingIdIndex(uint256 mListingId) public view virtual returns(uint256) {
        return _listingIdIndex[mListingId];
    }

    function getERC721ListingListItem(uint256 mListingId) public view virtual returns (ListingListItem memory) {
        return _erc721ListingListItem[mListingId];
    }

    function getErc721ListingHead(uint256 mCategory, string memory mSort) public view virtual returns (uint256) {
        return _erc721ListingHead[mCategory][mSort];
    }

    function getErc721Categories(address erc721TokenAddress) public view virtual returns (Category) {
        return _erc721Categories[erc721TokenAddress];
    }

    function getErc721OwnerListingHead(address mOwner, uint256 mCategory, string memory mSort) public view virtual returns (uint256) {
        return _erc721OwnerListingHead[mOwner][mCategory][mSort];
    }

    function getErc721TokenToListingId(address erc721TokenAddress, uint256 erc721TokenId, address mOwner) public view virtual returns (uint256) {
        return _erc721TokenToListingId[erc721TokenAddress][erc721TokenId][mOwner];
    }

    ///@notice Query the category of an NFT
    ///@param erc721TokenAddress The contract address of the NFT to query
    ///@param erc721TokenId The identifier of the NFT to query
    ///@return category_ Category of the NFT // 0 == portal, 1 == vrf pending, 2 == open portal, 3 == Aavegotchi 4 == Realm.
    function getERC721Category(address erc721TokenAddress, uint256 erc721TokenId) public view returns (Category) {
        // TODO require
        return _erc721Categories[erc721TokenAddress];   
    }

    function timelockController() public view virtual returns (address) {
        return _sTimelockController;
    }

    function token() public view returns(address) {
        return _tokenAddress;
    }

    function bth() public view returns(address) {
        return _bthAddress;
    }

    function wallet() public view returns(address) {
        return _wallet;
    }

    function burnAddress() public view virtual returns(address) {
        return _burnAddress;
    }

    function pause() public virtual {
        _beforePause();
        _pause();
    }

    function unpause() public virtual {
        _beforeUnpause();
        _unpause();
    }

    function _changeListingStatus(uint256 mListingId, Status status) internal virtual {
        ERC721Listing storage listing = _erc721Listings[mListingId];
        listing.status = status;
        emit StatusChanged(mListingId, status);
    }

    function _addIncludedCollection(address erc721TokenAddress) internal virtual {
        uint256 index = totalIncludedCollections() + 1; // mapping index starts with 1
        _includedCollections.push(erc721TokenAddress);
        _includedCollectionIndex[erc721TokenAddress] = index;
        _grantRole(COLLECTIONS, erc721TokenAddress);
        //TODO emit
    }

    function _removeIncludedCollection(address erc721TokenAddress) internal virtual {
        // uint256 index = getIncludedCollectionIndex(erc721TokenAddress);
        // uint256 arrayIndex = index - 1;
        // require(arrayIndex >= 0, "Marketplace: array out-of-bounds");
        // if(arrayIndex != totalIncludedCollections() - 1) {
        //     _includedCollections[arrayIndex] = _includedCollections[totalIncludedCollections() - 1];
        //     _includedCollectionIndex[_includedCollections[arrayIndex]] = index;
        // }
        // _includedCollections.pop();
        // delete _includedCollectionIndex[erc721TokenAddress];
        _revokeRole(COLLECTIONS, erc721TokenAddress);
        //TODO emit
    }

    /**
     * @dev Hook that is called before addERC721Listing.
     */
    function _beforeAddERC721Listing(
        address erc721TokenAddress,
        uint256 erc721TokenId,
        uint256 priceInWei,
        address mOwner
    ) 
        internal
        virtual
    {
        require(erc721TokenAddress != address(0), "BithotelMarketplace: ERC721 address is the zero address");
        require(hasRole(COLLECTIONS, erc721TokenAddress), "BithotelMarketplace, can't add given ERC721 addres");
        IERC721Upgradeable erc721Token = IERC721Upgradeable(erc721TokenAddress);
        //require(erc721Token.exists(erc721TokenId), "BithotelMarketplace: add ERC721 listing for nonexistent tokenId");
        require(priceInWei != 0, "BithotelMarketplace: priceInWei is the zero value");
        require(erc721Token.ownerOf(erc721TokenId) == mOwner, "BithotelMarketplace: not owner of ERC721 token");
        require(
            erc721Token.isApprovedForAll(mOwner, _thisAddress) ||
            erc721Token.getApproved(erc721TokenId) == _thisAddress,
            "BithotelMarketplace: not approved for transfer"
        );
        require(priceInWei >= 1e18, "BithotelMarketplace: listing price should be 1 or larger");
        if (isListingFeeEnabled()) {
            require(_bth.balanceOf(mOwner) >=  listingFeeInWei(), "BithotelMarketplace: need BTH balance to list ERC721");
            require(_bth.allowance(mOwner, _thisAddress) >= listingFeeInWei(), "BithotelMarketplace: approve BTH for listing");
        }
    }

    /**
     * @dev Hook that is called after addERC721Listing.
     */
    function _afterAddERC721Listing(
        address erc721TokenAddress,
        uint256 erc721TokenId,
        uint256 priceInWei
    ) internal virtual
    {}


    function _lockTokenId(address erc721TokenAddress, uint256 tokenId) internal {
        // solhint-disable-next-line reason-string
        require(erc721TokenAddress != address(0), "BithotelMarketplace: ERC721 is the zero address");
        // solhint-disable-next-line reason-string
        require(tokenId != 0, "BithotelMarketplace: tokenId is the zero value");

        BitHotelRoomCollectionUpgradeable collection = BitHotelRoomCollectionUpgradeable(erc721TokenAddress);
        
        // solhint-disable-next-line reason-string
        require(collection.exists(tokenId), "BithotelMarketplace: change for nonexistent token");
        // solhint-disable-next-line reason-string
        //require(collection.locked() == false, "BithotelMarketplace: tokenId already locked");

        // solhint-disable-next-line reason-string
        require(collection.controller() == _thisAddress, "BithotelMarketplace: marketplace doesn't control BitHotelRoomCollectionUpgradeable");

        collection.lockTokenId(tokenId);
    }

    function _releaseLockedTokenId(address erc721TokenAddress, uint256 tokenId) internal {
        // solhint-disable-next-line reason-string
        require(erc721TokenAddress != address(0), "BithotelMarketplace: ERC721 is the zero address");
        // solhint-disable-next-line reason-string
        require(tokenId != 0, "BithotelMarketplace: tokenId is the zero value");

        BitHotelRoomCollectionUpgradeable collection = BitHotelRoomCollectionUpgradeable(erc721TokenAddress);

        // solhint-disable-next-line reason-string
        require(collection.exists(tokenId), "BithotelMarketplace: change for nonexistent token");
        // solhint-disable-next-line reason-string
        //require(collection.locked() == true, "BithotelMarketplace: tokenId not locked");
        // solhint-disable-next-line reason-string
        require(collection.controller() == _thisAddress, "BithotelMarketplace: marketplace doesn't control BitHotelRoomCollectionUpgradeable");

        collection.releaseLockedTokenId(tokenId);
    }

    /**
    * @dev SafeTransferFrom beneficiary. Override this method to modify the way in which the sale ultimately gets and sends
    * its tokens.
    * @param mToken Address of the token being received
    * @param beneficiary Address performing the listing
    * @param to Address the tokenAmount sent to
    * @param tokenAmount Number of tokens to be emitted
    */
    function _receiveTokens(address mToken, address beneficiary, address to, uint256 tokenAmount) internal virtual {
        IERC20Upgradeable(mToken).safeTransferFrom(beneficiary, to, tokenAmount);
    }

    /**
    * @dev SafeTransferFrom beneficiary. Override this method to modify the way in which the sale ultimately gets and sends
    * its tokens.
    * @param erc721TokenAddress Address performing the token purchase
    * @param beneficiary Address performing the token purchase
    * @param tokenId Number of tokens to be emitted
    */
    function _receiveERC721(address erc721TokenAddress, address beneficiary, address to, uint256 tokenId) internal virtual {
        IERC721Upgradeable erc721Token = IERC721Upgradeable(erc721TokenAddress);
        require(
            erc721Token.isApprovedForAll(beneficiary, to) ||
            erc721Token.getApproved(tokenId) == to,
            "BithotelMarketplace: not approved for transfer"
        );
        erc721Token.safeTransferFrom(beneficiary, to, tokenId);
    }

    function _addERC721ListingItem(
        address mOwner,
        Category mCategory,
        string memory mSort,
        uint256 mListingId
    ) internal virtual {
        // uint256 headListingId = _erc721OwnerListingHead[mOwner][mCategory][mSort];
        // if (headListingId != 0) {
        //     ListingListItem storage headListingItem = _erc721OwnerListingListItem[headListingId];
        //     headListingItem.parentListingId = mListingId;
        // }
        // ListingListItem storage listingItem = _erc721OwnerListingListItem[mListingId];
        // listingItem.childListingId = headListingId;
        // _erc721OwnerListingHead[mOwner][mCategory][mSort] = mListingId;
        // listingItem.listingId = mListingId;

        // headListingId = _erc721ListingHead[mCategory][mSort];
        // if (headListingId != 0) {
        //     ListingListItem storage headListingItem = _erc721ListingListItem[headListingId];
        //     headListingItem.parentListingId = mListingId;
        // }
        // listingItem = _erc721ListingListItem[mListingId];
        // listingItem.childListingId = headListingId;
        // // _erc721ListingHead[mCategory][mSort] = mListingId;
        // listingItem.listingId = mListingId;

        _changeListingStatus(mListingId, Status.Added);

        uint256 index = totalListingIds() + 1; // mapping index starts with 1
        _listingIds.push(mListingId);
        _listingIdIndex[mListingId] = index;
    }

    function _cancelERC721Listing(uint256 mListingId, address mOwner) internal virtual {
        ListingListItem storage listingItem = _erc721ListingListItem[mListingId];
        if (listingItem.listingId == 0) {
            return;
        }
        ERC721Listing storage listing = _erc721Listings[mListingId];
        if (listing.status != Status.Cancelled || listing.timePurchased != 0) {
            return;
        }
        require(listing.seller == mOwner, "Marketplace: owner not seller");
        _changeListingStatus(mListingId, Status.Cancelled);

        // emit ERC721ListingCancelled(mListingId, listing.category, block.number);
        _removeERC721ListingItem(mListingId, mOwner);
    }

    function _cancelERC721Listing(
        address mErc721TokenAddress,
        uint256 mErc721TokenId,
        address mOwner
    ) internal virtual {
        uint256 listingId = _erc721TokenToListingId[mErc721TokenAddress][mErc721TokenId][mOwner];
        if (listingId == 0) {
            return;
        }
        _cancelERC721Listing(listingId, mOwner);
    }

    function _removeERC721ListingItem(uint256 mListingId, address mOwner) internal virtual {
        ListingListItem storage listingItem = _erc721ListingListItem[mListingId];
        if (listingItem.listingId == 0) {
            return;
        }
        uint256 parentListingId = listingItem.parentListingId;
        if (parentListingId != 0) {
            ListingListItem storage parentListingItem = _erc721ListingListItem[parentListingId];
            parentListingItem.childListingId = listingItem.childListingId;
        }
        uint256 childListingId = listingItem.childListingId;
        if (childListingId != 0) {
            ListingListItem storage childListingItem = _erc721ListingListItem[childListingId];
            childListingItem.parentListingId = listingItem.parentListingId;
        }
        ERC721Listing storage listing = _erc721Listings[mListingId];
        // if (_erc721ListingHead[listing.category]["listed"] == mListingId) {
        //     _erc721ListingHead[listing.category]["listed"] = listingItem.childListingId;
        // }
        listingItem.listingId = 0;
        listingItem.parentListingId = 0;
        listingItem.childListingId = 0;

        listingItem = _erc721OwnerListingListItem[mListingId];

        parentListingId = listingItem.parentListingId;
        if (parentListingId != 0) {
            ListingListItem storage parentListingItem = _erc721OwnerListingListItem[parentListingId];
            parentListingItem.childListingId = listingItem.childListingId;
        }
        childListingId = listingItem.childListingId;
        if (childListingId != 0) {
            ListingListItem storage childListingItem = _erc721OwnerListingListItem[childListingId];
            childListingItem.parentListingId = listingItem.parentListingId;
        }
        listing = _erc721Listings[mListingId];
        // if (_erc721OwnerListingHead[mOwner][listing.category]["listed"] == mListingId) {
        //     _erc721OwnerListingHead[mOwner][listing.category]["listed"] = listingItem.childListingId;
        // }
        listingItem.listingId = 0;
        listingItem.parentListingId = 0;
        listingItem.childListingId = 0;

        _changeListingStatus(mListingId, Status.Removed);

        uint256 index = listingIdIndex(mListingId);
        // solhint-disable-next-line reason-string
        require(index > 0, "Marketplace: no whitelist index found in mapping");

        uint256 arrayIndex = index - 1;
        // solhint-disable-next-line reason-string
        require(arrayIndex >= 0, "Marketplace: array out-of-bounds");
        if(arrayIndex != totalListingIds() - 1) {
            _listingIds[arrayIndex] = _listingIds[totalListingIds() - 1];
            _listingIdIndex[_listingIds[arrayIndex]] = index;
        }
        _listingIds.pop();
        delete _listingIdIndex[mListingId];

        //emit ERC721ListingRemoved(mListingId, listing.category, block.timestamp);
    }

    function _updateERC721Listing(
        address mErc721TokenAddress,
        uint256 mErc721TokenId,
        address mOwner
    ) internal virtual {
        uint256 listingId = _erc721TokenToListingId[mErc721TokenAddress][mErc721TokenId][mOwner];
        if (listingId == 0) {
            return;
        }
        ERC721Listing storage listing = _erc721Listings[listingId];
        // if (listing.timePurchased != 0 || listing.status == 0) {
        //     return;
        // }
        address owner = IERC721Upgradeable(listing.erc721TokenAddress).ownerOf(listing.erc721TokenId);
        if (owner != listing.seller) {
            _cancelERC721Listing(listingId, listing.seller);
        }
    }

    /**
     * @dev Hook that is called before pause.
     */
    function _beforePause()
        internal
        virtual
        onlyTimelock(_msgSender())
        // solhint-disable-next-line no-empty-blocks
    {}

    /**
     * @dev Hook that is called before unpause.
     */
    function _beforeUnpause()
        internal
        virtual
        onlyTimelock(_msgSender())
        // solhint-disable-next-line no-empty-blocks
    {}

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyRole(UPGRADER_ROLE)
    {
        // solhint-disable-next-line no-empty-blocks
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BitHotelRoomCollectionUpgradeable is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721RoyaltyUpgradeable, ERC721URIStorageUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    struct Room {
        uint256 number;
        string floorId;
        string roomTypeId;
        bool locked;
        Dimensions dimensions;
    }

    struct Dimensions {
        uint8 x;
        uint8 y;
        uint256 width;
        uint256 height;
    }

    mapping(uint256 => Room) private _rooms;
    mapping(uint256 => address[]) private _ownersHistory;

    address[] private _owners;
    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    string private _baseTokenURI;
    address private _controller;
    uint256 private _replicas;

    modifier onlyController(address controller_) {
        // solhint-disable-next-line reason-string
        require(controller() == controller_, "BitHotelRoomCollection: not a controller address.");
        _;
    }

    modifier notLocked(uint256 tokenId) {
        if (_rooms[tokenId].locked) {
            revert TokenLocked(tokenId);
        }
        _;
    }

    error TokenLocked(uint256 tokenId);

    /**
     * @dev Emitted when `Room` is added.
     * @param tokenId the token identification of the nft
     * @param number the room number of the nft
     * @param floorId the floorId of the nft
     * @param roomTypeId the roomTypeId of the nft
     * @param locked true or false whether the nft is locked for trading
     */
    event RoomInfoAdded(uint256 tokenId, uint256 number, string floorId, string roomTypeId, bool locked);
  
    /**
     * @dev Emitted when `Dimensions` nft is added.
     */
    event DimensionsAdded(uint8 x, uint8 y, uint256 width, uint256 height);

    /**
     * @dev Emitted when `tokenId` nft is minted to `to`.
    */
    event TokenMint(uint256 tokenId, address to);

    /**
     * @dev Emitted when `setBaseURI` is change to `newBaseTokenURI`.
    */
    event BaseUriChanged(string oldBaseTokenURI, string newBaseTokenURI);

    /**
     * @dev Emitted when `setContoller` is change to `newAddress`.
    */
    event ControllerChanged(address newAddress);

    /**
     * @dev Emitted when `locked` of `tokenId` is change to true.
    */
    event TokenIdLocked(uint256 tokenId, bool locked);

    /**
     * @dev Emitted when `locked` of `tokenId` is change to false.
    */
    event TokenIdReleased(uint256 tokenId, bool locked);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address controller_,
        uint256 replicas_,
        address owner_
    ) initializer public {
        __ERC2981_init();
        __ERC721_init(name_, symbol_);
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __BitHotelRoomCollectionUpgradeable_init_unchained(name_, symbol_, controller_, replicas_, owner_);
    }

    // solhint-disable-next-line func-name-mixedcase
    function __BitHotelRoomCollectionUpgradeable_init_unchained(
        string memory,
        string memory,
        address controller_,
        uint256 replicas_,
        address owner_
    ) internal onlyInitializing
    {
        _controller = controller_;
        _replicas = replicas_;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, owner_);
    }

    function version() external pure virtual returns (string memory) {
        return "1.0";
    }

    /**
     * @dev See {IBitHotelRoomCollection-tokenIds}.
     */
    function tokenIds() external view virtual returns (uint256[] memory) {
        return _allTokens;
    }

    /**
     * @dev See {IBitHotelRoomCollection-ownersHistory}.
     */
    function ownersHistory(uint256 tokenId) external view virtual returns (address[] memory) {
        return _ownersHistory[tokenId];
    }

    /**
     * @dev See {IBitHotelRoomCollection-getRoomInfos}.
     * @param tokenId the nft identification
     */
    function getRoomInfos(uint256 tokenId) external view virtual returns (uint256, string memory, string memory) {
        uint256 number = _rooms[tokenId].number;
        string memory floorId = _rooms[tokenId].floorId;
        string memory roomTypeId = _rooms[tokenId].roomTypeId;
        return(number, floorId, roomTypeId);
    }

    /**
     * @dev See {IBitHotelRoomCollection-getRoomDimensions}.
     */
    function getRoomDimensions(uint256 tokenId) external view virtual returns (uint8, uint8, uint256, uint256) {
        uint8 x = _rooms[tokenId].dimensions.x;
        uint8 y = _rooms[tokenId].dimensions.y;
        uint256 width = _rooms[tokenId].dimensions.width;
        uint256 height = _rooms[tokenId].dimensions.height;
        return (x, y, width, height);
    }

    /**
     * @dev See {IBitHotelRoomCollection-locked}.
     */
    function locked(uint256 tokenId) external view virtual returns (bool) {
        return _rooms[tokenId].locked;
    }

    /**
     * @dev See {IBitHotelRoomCollection-setRoomInfos}.
     */
    function setRoomInfos(
        uint256 tokenId,
        uint256 number,
        string memory floorId,
        string memory roomTypeId,
        bool locked_,
        uint8 x,
        uint8 y,
        uint256 width,
        uint256 height
    ) external virtual {
        _beforeSetRoomInfos(
            tokenId,
            number,
            floorId,
            roomTypeId,
            locked_,
            x,
            y,
            width,
            height
        );
        Room storage room = _rooms[tokenId];
        room.number = number;
        room.floorId = floorId;
        room.roomTypeId = roomTypeId; 
        room.locked = locked_; 
        room.dimensions.x = x; 
        room.dimensions.y = y;
        room.dimensions.width = width; 
        room.dimensions.height = height; 
        emit RoomInfoAdded(tokenId, number, floorId, roomTypeId, locked_);
        emit DimensionsAdded(x, y, width, height);
    }

    /**
     * @dev See {IBitHotelRoomCollection-setController}.
     */
    function setController(address controller_) external virtual {
        _beforeSetController(controller_);
        _controller = controller_;
        emit ControllerChanged(controller_);
    }

    /**
     * @dev See {IBitHotelRoomCollection-lockTokenId}.
     */
    function lockTokenId(uint256 tokenId) external virtual {
        _beforeLockTokenId(tokenId);
        _rooms[tokenId].locked = true;
        emit TokenIdLocked(tokenId, true);
    }

    /**
     * @dev See {IBitHotelRoomCollection-releaseLockedTokenId}.
     */
    function releaseLockedTokenId(uint256 tokenId) external virtual {
        _beforeLockTokenId(tokenId);
        _beforeReleaseLockedTokenId(tokenId);
        _rooms[tokenId].locked = false;
        emit TokenIdReleased(tokenId, false);
    }

    /**
     * @dev See {IBitHotelRoomCollection-controller}.
     */
    function controller() public view virtual returns (address) {
        return _controller;
    }

    /**
     * @dev See {IBitHotelRoomCollection-replicas}.
     */
    function replicas() public view virtual returns (uint256) {
        return _replicas;
    }

    /**
     * @dev See {IBitHotelRoomCollection-baseURI}.
     */
    function baseURI() public view virtual returns (string memory) {
        return _baseURI();
    }

    /**
     * @dev See {IBitHotelRoomCollection-exists}.
     */
    function exists(uint256 tokenId) public virtual view returns (bool) {
        return _exists(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721RoyaltyUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IBitHotelRoomCollection.setBaseURI}.
     */
    function setBaseURI(string memory newBaseTokenURI) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        string memory oldBaseTokenURI = baseURI();
        _baseTokenURI = newBaseTokenURI;
        emit BaseUriChanged(oldBaseTokenURI, newBaseTokenURI);
    }
    

    /**
     * @dev See {IBitHotelRoomCollection.setTokenURI}.
     */
    function setTokenURI(uint256 tokenId, string memory tokenURI_) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        // solhint-disable-next-line reason-string
        require(_exists(tokenId), "BitHotelRoomCollection: change uri for nonexistent token");
        _setTokenURI(tokenId, tokenURI_);
    }

    /**
     * @dev See {IBitHotelRoomCollection-mint}.
     * WARNING: Usage of this method is discouraged, use {safeMint} whenever possible
    */
    function mint(
        address to,
        uint256 tokenId,
        string memory uri,
        address royaltyRecipient,
        uint96 royaltyValue
    ) public  virtual {
        _beforeMint(to, tokenId, uri, royaltyRecipient, royaltyValue);

        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        if (royaltyValue > 0) {
            _setTokenRoyalty(tokenId, royaltyRecipient, royaltyValue);
        }
        _allTokens.push(tokenId);
        emit TokenMint(tokenId, to);
        _afterMint(to, tokenId, uri, royaltyRecipient, royaltyValue);
    }

    /**
     * @dev See {IBitHotelRoomCollection-safeMint}.
    */
    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri,
        address royaltyRecipient,
        uint96 royaltyValue,
        bytes memory data_ 
    ) public virtual {
        _beforeMint(to, tokenId, uri, royaltyRecipient, royaltyValue);
        super._safeMint(to, tokenId, data_);
        _setTokenURI(tokenId, uri);
        if (royaltyValue > 0) {
            _setTokenRoyalty(tokenId, royaltyRecipient, royaltyValue);
        }
        _allTokens.push(tokenId);
        emit TokenMint(tokenId, to);
        _afterMint(to, tokenId, uri, royaltyRecipient, royaltyValue);
    }

    /**
     * @dev Hook that is called before setRoomInfos.
     */
    function _beforeSetRoomInfos(
        uint256 tokenId,
        uint256 number,
        string memory floorId,
        string memory roomTypeId,
        bool locked_,
        uint8 x,
        uint8 y,
        uint256 width,
        uint256 height
    ) internal virtual onlyController(_msgSender())  {
        // solhint-disable-next-line reason-string
        require(tokenId != 0, "BitHotelRoomCollection: tokenId is the zero value");
    }

    /**
     * @dev Hook that is called before setController.
     */
    function _beforeSetController(address controller_) internal virtual onlyController(_msgSender()) {
        // solhint-disable-next-line reason-string
        require(controller_ != address(0), "BitHotelRoomCollection: controller is the zero address");
        // solhint-disable-next-line reason-string
        require(controller_ != controller(), "BitHotelRoomCollection: controller already updated");
    }

    /**
     * @dev Hook that is called before lockTokenId.
     */
    function _beforeLockTokenId(uint256 tokenId) internal virtual onlyController(_msgSender()) {
        // solhint-disable-next-line reason-string
        require(_exists(tokenId), "BitHotelRoomCollection: change for nonexistent token");
    }

    /**
     * @dev Hook that is called before lockTokenId.
     */
    function _beforeReleaseLockedTokenId(uint256 tokenId) internal virtual onlyController(_msgSender()) {
        // solhint-disable-next-line reason-string
        require(_rooms[tokenId].locked == true, "BitHotelRoomCollection: tokenId not locked");
    }

    /**
     * @dev Hook that is called before mint or safeMint.
     */
    function _beforeMint(
        address to,
        uint256 tokenId,
        string memory uri,
        address royaltyRecipient,
        uint256 royaltyValue
    ) internal virtual onlyController(_msgSender()) 
    {
        // solhint-disable-next-line reason-string
        require(totalSupply() < replicas(),"BitHotelRoomCollection: all tokens already minted.");
    }

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterMint(
        address to,
        uint256 tokenId,
        string memory uri,
        address royaltyRecipient,
        uint256 royaltyValue
        // solhint-disable-next-line no-empty-blocks
    ) internal virtual {}

    // The following functions are overrides required by Solidity.

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) 
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        notLocked(tokenId)
    {
        super._beforeTokenTransfer(from, to, tokenId);
        // add owner to _ownersHistory
        _ownersHistory[tokenId].push(to);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyRole(UPGRADER_ROLE)
    {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721Upgradeable, ERC721RoyaltyUpgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/ERC721Royalty.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "../../common/ERC2981Upgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of ERC721 with the ERC2981 NFT Royalty Standard, a standardized way to retrieve royalty payment
 * information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC721RoyaltyUpgradeable is Initializable, ERC2981Upgradeable, ERC721Upgradeable {
    function __ERC721Royalty_init() internal onlyInitializing {
    }

    function __ERC721Royalty_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC2981Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally clears the royalty information for the token.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
    }

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {
    }
    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981Upgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981Upgradeable is Initializable, IERC2981Upgradeable, ERC165Upgradeable {
    function __ERC2981_init() internal onlyInitializing {
    }

    function __ERC2981_init_unchained() internal onlyInitializing {
    }
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC2981Upgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981Upgradeable
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        virtual
        override
        returns (address, uint256)
    {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `tokenId` must be already minted.
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981Upgradeable is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be payed in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165Upgradeable.sol";