pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./ToppyMasterSetting.sol";
import "./IToppyMint.sol";
import "./TransferHelper.sol";
import "./ToppySupportPayment.sol";


contract ToppyMarketPlace is Ownable{

    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct Offer {
        bytes32 key;
        uint offerPrice; // wei
        address buyer;
        address tokenPayment;
        PriceType priceType;
        uint bidAt; // time
    }

    struct ListingParams {
        address nftContract;
        uint tokenId;
        ListingType listingType;
        uint listingPrice;
        uint endingPrice;
        uint duration;
        PriceType priceType;
        address tokenPayment;
    }  
   

    struct Listing {
        bytes32 key;
        ListingType listingType;
        uint id;
        address seller;
        uint tokenId;
        uint listingPrice; // wei
        uint endingPrice; // wei
        uint duration; // seconds
        uint startedAt; // block number
        address tokenPayment;
        PriceType priceType;
        address nftContract;
    }
  
    address public toppyMint;
    ToppySupportPayment public supportPayment;// = SupportedPayment(address(0xFb0D4DC54231a4D9A1780a8D85100347E6B6C41c));
    ToppyMaster public masterSetting;// = MasterSetting(address(0xFb0D4DC54231a4D9A1780a8D85100347E6B6C41c));
    address public adminExecutor;  //admin executor for accepting the english auction offer     
    uint public listingId = 0; // max is 18446744073709551615
    uint private interBlockTime = 3; // average time between blocks (3s for BSC)

    mapping (bytes32 => Offer) public highestOffer;
    mapping (bytes32 => Listing) internal tokenIdToListing;
    mapping (address => EnumerableSet.Bytes32Set) private nftsForSaleByAddress;
    mapping (address => EnumerableSet.Bytes32Set) private nftsForSaleIds;
    mapping (address => Offer[]) private pendingWithdrawals;

    enum PriceType {
        ETHER,
        TOKEN
    }
    enum ListingType {
        Fix,
        Dutch,
        English
    }

    modifier onlyAdminExecutor() {
        require(msg.sender == adminExecutor);
        _;
    }

    event ListingCreated(bytes32 key, address from, uint listingId, address nftContract, uint tokenId, ListingType listingType, uint256 startingPrice, uint256 endingPrice, uint256 duration, address tokenPayment);
    event ListingCancelled(bytes32 key, address from, uint listingId, address nftContract, uint tokenId, address tokenPayment);
    event ListingSuccessful(bytes32 key, uint listingId, address nftContract, uint tokenId, uint256 totalPrice, address owner, address buyer, address tokenPayment);
    event AuctionOffer(bytes32 key, uint listingId, address nftContract, uint256 tokenId, uint256 totalPrice, address owner, address offeror, address previousBidder, address tokenPayment);

    constructor(
        address _supportPayment,
        address _masterSetting,
        address _toppyMint,
        address _adminExecutor
        ) {
        supportPayment = ToppySupportPayment(_supportPayment);
        masterSetting = ToppyMaster(_masterSetting);
        toppyMint = _toppyMint;
        adminExecutor = _adminExecutor;
    }

    function updateProperties(
        address _supportPayment,
        address _masterSetting,
        address _toppyMint,
        address _adminExecutor
        ) public onlyOwner {
        supportPayment = ToppySupportPayment(_supportPayment);
        masterSetting = ToppyMaster(_masterSetting);
        toppyMint = _toppyMint;
        adminExecutor = _adminExecutor;
    }

    function totalListed() public view returns (uint) {
        return nftsForSaleIds[address(this)].length();
    }

    function totalListedByOwner(address owner) public view returns (uint) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return nftsForSaleByAddress[owner].length();
    }

    function _getId(address _contract, uint _tokenId) internal pure returns(bytes32) {
        bytes32 bAddress = bytes32(uint256(uint160(_contract)));
        bytes32 bTokenId = bytes32(_tokenId);
        return keccak256(abi.encodePacked(bAddress, bTokenId));
    }

    // allow owner to extend the auction without cancelling it and relist it again
    function extendBulkListing( bytes32 [] memory _keys) public {
        for (uint i = 0; i < _keys.length; i++) {  
            _extendListing(_keys[i]);
        }
    }

    // allow owner to extend the auction without cancelling it and relist it again
    function extendListing(bytes32 _key) public {            
        _extendListing(_key);
    }

    function _extendListing(bytes32 _key) internal {
            
        Listing memory listing_ = tokenIdToListing[_key];
        Offer memory highestOff = highestOffer[listing_.key];
        
        require(nftsForSaleIds[address(this)].contains(listing_.key), "Trying to extend listing which is not listed yet!");        
        require(IERC721(listing_.nftContract).ownerOf(listing_.tokenId) == msg.sender, "you are not owner of nft");
        require(_isAuctionExpired(listing_.startedAt, listing_.duration), "cannot extend before it expires");
        require(highestOff.buyer == address(0), "cannot extend if there is bidder");

        tokenIdToListing[_key].startedAt = uint(block.number);      
        
        emit ListingCreated(
            listing_.key, 
            msg.sender, 
            listing_.id, 
            listing_.nftContract, 
            listing_.tokenId, 
            listing_.listingType, 
            listing_.listingPrice, 
            listing_.endingPrice, 
            listing_.duration,
            listing_.tokenPayment
            );
    }

    function createBulkListing(
        ListingParams memory _listingParams,
        uint [] memory tokenIds) public {
    
        // check storage requirements
        require(_listingParams.listingPrice > 0 && _listingParams.listingPrice < type(uint128).max, "invalid listing price"); // 128 bits
        require(_listingParams.endingPrice < type(uint128).max, "invalid endingPrice"); // 128 bits
        require(_listingParams.duration <= type(uint64).max, "invalid duration"); // 64 bits
        require(supportPayment.isEligibleToken(_listingParams.tokenPayment), "currency not support");
        if(_listingParams.listingType != ListingType.Fix) require(_listingParams.duration >= 1 minutes);
        if(_listingParams.listingType == ListingType.Dutch) require(_listingParams.endingPrice < _listingParams.listingPrice, "ending price should less than starting price");

        for (uint i = 0; i < tokenIds.length; i++) {
            require(IERC721(_listingParams.nftContract).ownerOf(tokenIds[i]) == msg.sender, "you are not owner of nft");
            _createListing(_listingParams, tokenIds[i]);
        } 
    }

    function createListing(ListingParams memory _listingParams) public {
        
        require(_listingParams.listingPrice > 0 && _listingParams.listingPrice < type(uint128).max, "invalid listing price"); // 128 bits
        require(_listingParams.endingPrice < type(uint128).max, "invalid endingPrice"); // 128 bits
        require(_listingParams.duration <= type(uint64).max, "invalid duration"); // 64 bits
        require(supportPayment.isEligibleToken(_listingParams.tokenPayment), "currency not support");
        require(IERC721(_listingParams.nftContract).ownerOf(_listingParams.tokenId) == msg.sender, "you are not owner of nft");
        if (_listingParams.priceType == PriceType.TOKEN) {
            require(_listingParams.tokenPayment != address(0), "Cannot create listing where token address is 0");
        }
    
        if(_listingParams.listingType != ListingType.Fix) require(_listingParams.duration >= 1 minutes);
        if(_listingParams.listingType == ListingType.Dutch) require(_listingParams.endingPrice < _listingParams.listingPrice, "ending price should less than starting price");

        _createListing(_listingParams, _listingParams.tokenId);
    }

    function _createListing(ListingParams memory _listingParams, uint _tokenId) internal {

        bytes32 key = _getId(_listingParams.nftContract, _tokenId);
        Listing memory listingCheck = tokenIdToListing[key];
        require(listingCheck.startedAt == 0, "This NFT already has a listing, cannot overwrite existing listing");

        Listing memory listing = Listing(
            key,
            _listingParams.listingType,
            uint(listingId),
            msg.sender,
            _tokenId,
            uint(_listingParams.listingPrice),
            uint(_listingParams.endingPrice),
            uint(_listingParams.duration),
            uint(block.number),
            _listingParams.tokenPayment,
            _listingParams.priceType,
            _listingParams.nftContract
        );

        tokenIdToListing[key] = listing;
        nftsForSaleIds[address(this)].add(key);
        nftsForSaleByAddress[msg.sender].add(key);
        nftsForSaleByAddress[_listingParams.nftContract].add(key);
            
        emit ListingCreated(
            key, 
            msg.sender, 
            listingId, 
            _listingParams.nftContract, 
            _tokenId, 
            _listingParams.listingType, 
            _listingParams.listingPrice, 
            _listingParams.endingPrice, 
            _listingParams.duration,
            _listingParams.tokenPayment
            );
  
        listingId++;
    }

    function updateBulkListing(
        ListingParams memory _listingParams,
        bytes32 [] memory _keys
        ) public {
    
        require(_listingParams.listingPrice > 0 && _listingParams.listingPrice < type(uint128).max , "invalid listing price"); // 128 bits
        
        for (uint i = 0; i < _keys.length; i++) {  
            _updateListing(_keys[i], _listingParams);
        } 
    }

    function updateListing(ListingParams memory _listingParams, bytes32 _key) public {
        
        require(_listingParams.listingPrice > 0 && _listingParams.listingPrice < type(uint128).max, "invalid listing price"); // 128 bits
        _updateListing(_key, _listingParams);
    }

    function _updateListing(bytes32 _key, ListingParams memory _listingParams) internal {

        require(nftsForSaleIds[address(this)].contains(_key), "Trying to update a listing which is not listed yet!");
        Listing memory listing_ = tokenIdToListing[_key];
        require(IERC721(listing_.nftContract).ownerOf(listing_.tokenId) == msg.sender, "you are not owner of nft");
        require(supportPayment.isEligibleToken(_listingParams.tokenPayment), "currency not support");
        if (_listingParams.priceType == PriceType.TOKEN) {
            require(_listingParams.tokenPayment != address(0), "Cannot update TOKEN payment with address 0");
        }
        if(listing_.listingType == ListingType.English){
            require(highestOffer[_key].buyer == address(0), "not allow to update if there is existing bidder");
        }
        listing_.listingPrice = _listingParams.listingPrice;
        listing_.tokenPayment = _listingParams.tokenPayment;
        listing_.priceType = _listingParams.priceType;
        listing_.endingPrice = _listingParams.endingPrice;
        listing_.duration = _listingParams.duration;
        tokenIdToListing[_key] = listing_;
        emit ListingCreated(
            _key, 
            msg.sender, 
            listing_.id, 
            listing_.nftContract, 
            listing_.tokenId, 
            listing_.listingType, 
            _listingParams.listingPrice, 
            _listingParams.endingPrice, 
            _listingParams.duration,
            _listingParams.tokenPayment
            );
    }

    function getListings(uint startIndex, uint endIndex) public view returns (Listing[] memory _listings) {        
        require(startIndex < endIndex, "Invalid indexes supplied!");
        uint len = endIndex - startIndex;
        require(len <= totalListed(), "Invalid length!");

        _listings = new Listing[](len);
        for (uint i = startIndex; i < endIndex; i++) {
            uint listIndex = i - startIndex;
            // bytes32 key = nftsForSaleIds.at(i);
            bytes32 key = nftsForSaleIds[address(this)].at(i);
            Listing memory listing_ = tokenIdToListing[key];
            _listings[listIndex] = listing_;
        }
        return _listings;
    }
  
    function getListingsBySeller(address seller, uint startIndex, uint endIndex) public view returns (Listing[] memory _listings) {
        require(startIndex < endIndex, "Invalid indexes supplied!");
        uint len = endIndex - startIndex;
        require(len <= totalListedByOwner(seller), "Invalid length!");

        _listings = new Listing[](len);
        for (uint i = startIndex; i < endIndex; i++) {
            uint listIndex = i - startIndex;
            bytes32 key = nftsForSaleByAddress[seller].at(i);
            Listing memory listing_ = tokenIdToListing[key];
            _listings[listIndex] = listing_;
        }
        return _listings;
    }

    function getListingByNFTKey(bytes32 _key) public view returns (Listing memory listing) {
        Listing memory listing_ = tokenIdToListing[_key];
        require(listing_.startedAt > 0, "This key does not have a Listing");
        return listing_;
    }

    function cancelListingByAdmin(bytes32 _key) public onlyAdminExecutor {
        Listing memory listing_ = tokenIdToListing[_key];
        require(listing_.startedAt > 0);
        require(nftsForSaleIds[address(this)].contains(listing_.key), "Trying to unlist an NFT which is not listed yet!");
        _cancelListing(listing_);
    }

    function cancelListingByKey(bytes32 _key) public {
      
        Listing memory listing_ = tokenIdToListing[_key];
        require(listing_.startedAt > 0);
        require(nftsForSaleIds[address(this)].contains(listing_.key), "Trying to unlist an NFT which is not listed yet!");
        require(IERC721(listing_.nftContract).ownerOf(listing_.tokenId) == msg.sender, "you are not the seller of this listing");
        if (listing_.listingType == ListingType.English) require(highestOffer[listing_.key].offerPrice == 0, "cannot cancel english auction with offers");
        _cancelListing(listing_);
    }

    function _cancelListing(Listing memory listing_) internal {
        delete tokenIdToListing[listing_.key];
        nftsForSaleIds[address(this)].remove(listing_.key);
        nftsForSaleByAddress[listing_.seller].remove(listing_.key);
        nftsForSaleByAddress[listing_.nftContract].remove(listing_.key);
        _cancelEnglishOffer(listing_);
        emit ListingCancelled(listing_.key, listing_.seller, listing_.id, listing_.nftContract, listing_.tokenId, listing_.tokenPayment);
    }

    function _cancelEnglishOffer(Listing memory _listing) internal {
        if(_listing.listingType == ListingType.English){
            Offer memory highestOff = highestOffer[_listing.key];
            pendingWithdrawals[highestOff.buyer].push(highestOff);
            delete highestOffer[_listing.key];
        }      
    }

    function acceptOfferByAdmin(bytes32 _key) public payable onlyAdminExecutor {
        Listing memory listing_ = tokenIdToListing[_key];
        require(listing_.startedAt > 0);
        _acceptOffer(_key);
    }

    function acceptOffer(bytes32 _key) public payable {
        Listing memory listing_ = tokenIdToListing[_key];
        require(listing_.startedAt > 0);
        Offer memory highestOffer_ = highestOffer[_key];
        require((IERC721(listing_.nftContract).ownerOf(listing_.tokenId) == msg.sender) || (highestOffer_.buyer == msg.sender), "you are not the seller or winning bidder");
        _acceptOffer(_key);
    }

    function _acceptOffer(bytes32 _key) internal {
      
        Listing memory listing_ = tokenIdToListing[_key];
        require(_isAuctionExpired(listing_.startedAt, listing_.duration), "wait until it expires");
        require(listing_.listingType == ListingType.English, "accept offer only for English type listing");

        Offer memory highestOff = highestOffer[listing_.key];
        require(highestOff.offerPrice >= listing_.listingPrice, "no valid offer to accept");
        address ownerNFT = IERC721(listing_.nftContract).ownerOf(listing_.tokenId);
        _handlePayment(listing_, highestOff.offerPrice, ownerNFT);

        IERC721(listing_.nftContract).transferFrom(ownerNFT, highestOff.buyer, listing_.tokenId);
        delete tokenIdToListing[listing_.key];
        delete highestOffer[listing_.key];
        nftsForSaleIds[address(this)].remove(listing_.key);
        nftsForSaleByAddress[listing_.seller].remove(listing_.key);
        nftsForSaleByAddress[listing_.nftContract].remove(listing_.key);
        emit ListingSuccessful(listing_.key, listing_.id, listing_.nftContract, listing_.tokenId, highestOff.offerPrice, ownerNFT, highestOff.buyer, listing_.tokenPayment);
    }

    function offer(bytes32 _key, uint256 _amount) public payable {
        Listing memory listing_ = tokenIdToListing[_key];
        require(listing_.startedAt > 0);
        require(IERC721(listing_.nftContract).ownerOf(listing_.tokenId) != msg.sender, "Owner cannot make offer to own nft");
        require(listing_.listingType == ListingType.English, "Offer function can only be used on English auctions");
        // check if expired
        require(!_isAuctionExpired(listing_.startedAt, listing_.duration), "Expired. no more offer");
        uint secondsPassed = (block.number - listing_.startedAt) * interBlockTime;

        Offer memory prevOffer = highestOffer[_key];
        require(_amount > prevOffer.offerPrice, "Offer less than highest offer");
        require(_amount > listing_.listingPrice, "Offer less than starting price");

        if (listing_.priceType == PriceType.TOKEN) {
            TransferHelper.safeTransferFrom(listing_.tokenPayment, msg.sender, address(this), _amount);
        }
        else { 
            require(msg.value >= _amount, "Not enough balance");
        }

        Offer memory newHighest;
        newHighest.offerPrice = _amount;
        newHighest.buyer = msg.sender;
        newHighest.key = listing_.key;
        newHighest.priceType = listing_.priceType;
        newHighest.tokenPayment = listing_.tokenPayment;
        newHighest.bidAt = uint(block.timestamp);

        highestOffer[_key] = newHighest;

        // set up pending withdraw for refund
        if (prevOffer.offerPrice > 0) {
            pendingWithdrawals[prevOffer.buyer].push(prevOffer);
        }

        // extend bidding period for another 10 minutes if remaining time less than 10 mins
        uint remainingTiming = (listing_.duration - secondsPassed);
        if (remainingTiming < masterSetting.durationExtension()) {
            tokenIdToListing[_key].duration = listing_.duration + masterSetting.durationExtension() - remainingTiming;
        }

        emit AuctionOffer(listing_.key, listing_.id, listing_.nftContract, listing_.tokenId, _amount, listing_.seller, msg.sender, prevOffer.buyer, listing_.tokenPayment);
    }

    /// Used by Fix price and Auction price Buy/Bid
    function bid(bytes32 _key) public payable {

        Listing memory listing_ = tokenIdToListing[_key];
        require(listing_.startedAt > 0);
        require(listing_.listingType != ListingType.English, "Only Fix and Dutch auction can directly buy NFTs");
        uint256 price = getCurrentPrice(listing_);
        require(price > 0, "no price");
        address ownerNFT = IERC721(listing_.nftContract).ownerOf(listing_.tokenId);
        require(ownerNFT != msg.sender, "do not buy own nft");
        if (listing_.listingType == ListingType.Dutch) {
            require(!_isAuctionExpired(listing_.startedAt, listing_.duration), "Cannot purchase expired auction");
        }
        
        if(listing_.priceType == PriceType.ETHER) require(msg.value >= price, "not enough balance");  
        else TransferHelper.safeTransferFrom(listing_.tokenPayment, msg.sender, address(this), price);

        uint auctionId_temp = listing_.id;
        
        _handlePayment(listing_, price, ownerNFT);

        IERC721(listing_.nftContract).transferFrom(ownerNFT, msg.sender, listing_.tokenId);
        delete tokenIdToListing[listing_.key];
        nftsForSaleIds[address(this)].remove(listing_.key);
        nftsForSaleByAddress[listing_.seller].remove(listing_.key);
        nftsForSaleByAddress[listing_.nftContract].remove(listing_.key);
        emit ListingSuccessful(
            listing_.key, 
            auctionId_temp, 
            listing_.nftContract, 
            listing_.tokenId, 
            price, 
            ownerNFT, 
            msg.sender, 
            listing_.tokenPayment);
    }

    function _handlePayment(Listing memory listing_, uint _price, address ownerNFT) internal {

        address creatorOwnerAddress = address(0);
        bool isElig = IToppyMint(toppyMint).isElegible(listing_.nftContract);
        if(isElig) creatorOwnerAddress = IToppyMint(toppyMint).getCreator(listing_.key);
        (uint creatorFee, uint fee, uint amountAfterFee) = masterSetting.getCalcFeeInfo(creatorOwnerAddress, _price);

        if (listing_.priceType == PriceType.ETHER) {
            
            if(creatorOwnerAddress != address(0)) TransferHelper.safeTransferBNB(creatorOwnerAddress, creatorFee);
            TransferHelper.safeTransferBNB(masterSetting.platformOwner(), fee);
            TransferHelper.safeTransferBNB(ownerNFT, amountAfterFee);
            
        }else{
            
            if(creatorOwnerAddress != address(0)) TransferHelper.safeTransfer(listing_.tokenPayment, creatorOwnerAddress, creatorFee);
            TransferHelper.safeTransfer(listing_.tokenPayment, masterSetting.platformOwner(), fee);
            TransferHelper.safeTransfer(listing_.tokenPayment, ownerNFT, amountAfterFee);
        }
    }

    function getCurrentPriceByKey(bytes32 _key) public view returns (uint) {
        Listing memory listing_ = tokenIdToListing[_key];
        return getCurrentPrice(listing_);
    }
  
    function getCurrentPrice(Listing memory listing_) internal view returns (uint) {
        if(listing_.listingType == ListingType.Fix){
            return listing_.listingPrice;
        }
        if(listing_.listingType == ListingType.Dutch){
            return _getDutchCurrentPrice(listing_);
        }
        if(listing_.listingType == ListingType.English){
            return _getEnglishCurrentPrice(listing_);
        }
        return 0;
    }

    function _getEnglishCurrentPrice(Listing memory listing_) internal view returns (uint) {
        Offer memory highestOff = highestOffer[listing_.key];
        return highestOff.offerPrice == 0 ? listing_.listingPrice : highestOff.offerPrice;
    }

    function _getDutchCurrentPrice(Listing memory listing_) internal view returns (uint) {
        require(listing_.startedAt > 0);
        uint256 secondsPassed = 0;

        secondsPassed = (block.number - listing_.startedAt) * interBlockTime;

        if (secondsPassed >= listing_.duration) {
            return listing_.endingPrice;
        } else {
            int256 totalPriceChange = int256(listing_.endingPrice) - int256(listing_.listingPrice);

            int256 currentPriceChange = totalPriceChange * int256(secondsPassed) / int256(listing_.duration);

            int256 currentPrice = int256(listing_.listingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    function isAuctionExpired(bytes32 _key) public view returns (bool) {
        Listing memory listing_ = tokenIdToListing[_key];
        if(!nftsForSaleIds[address(this)].contains(listing_.key)) return false;
        return _isAuctionExpired(listing_.startedAt, listing_.duration);
    }

    function _isAuctionExpired(uint _startedAt, uint _duration) internal view returns (bool) {     
        uint secondsPassed = (block.number - _startedAt) * interBlockTime;
        return secondsPassed > _duration;
    }

    function getPendingWithdraws(address _user) public view returns (Offer[] memory) {
        return pendingWithdrawals[_user];
    }

    function withdrawRefunds() public {
        Offer[] memory pending = pendingWithdrawals[msg.sender];
        delete pendingWithdrawals[msg.sender];
        for (uint256 i; i < pending.length; i++) {
            if (pending[i].priceType == PriceType.ETHER) {
                TransferHelper.safeTransferBNB(msg.sender, pending[i].offerPrice);
            } else {
                TransferHelper.safeTransfer(pending[i].tokenPayment, msg.sender, pending[i].offerPrice);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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

pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0-or-later

import "@openzeppelin/contracts/access/Ownable.sol";

contract ToppyMaster is Ownable{

    struct creatorRoyalty {
        uint fee;
        address owner;
    }
    
    uint public durationExtension = 600;
    uint public mintFee = 5000000000000000;
    address public platformOwner = address(0x62691eF999C7F07BC1653416df0eC4f3CDDBb0c7);
    uint public platformComm = 500;
    mapping (address => creatorRoyalty) public creatorRoyalties;
    
    // ---------------- owner modifier functions ------------------------
    function setMintFee(uint _mintFee) public onlyOwner {
        mintFee = _mintFee;
    }
    function setPlatform(uint _platformComm, address _platformOwner) public onlyOwner {
        require(_platformComm <= 1000, "max platform comm 10%");
        platformComm = _platformComm;
        platformOwner = _platformOwner;
    }
    function setDurationExtension(uint _durationExtension) public onlyOwner {
        require(_durationExtension <= 86400, "max duration extension 24hours");
        durationExtension = _durationExtension;
    }
    function updateMyRoyalty(uint _fee) public {
        
        require(_fee <= 1000, "cannot set more than 10%");
        creatorRoyalty storage creator = creatorRoyalties[msg.sender];
        creator.owner = msg.sender;
        creator.fee = _fee;
    }
    
    function getCalcFeeInfo(address _creatorOwnerAddress, uint baseAmount) public view returns (uint creatorFee, uint platformFee, uint amountAfterFee) {
        
        creatorRoyalty memory creator = creatorRoyalties[_creatorOwnerAddress];
        creatorFee = (baseAmount * creator.fee) / 10000;
        platformFee = (baseAmount * platformComm) / 10000;
        amountAfterFee = baseAmount - platformFee - creatorFee;
        return (creatorFee, platformFee, amountAfterFee);
    }
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

interface IToppyMint {

    event Reveal(bytes32 key, uint256 tokenId, address nftContract, address owner);
  
    event Minted(bytes32 key, address from, address nftContract, uint tokenId, string cid);

    event ListingSuccessful(bytes32 key, uint listingId, address nftContract, uint tokenId, uint256 totalPrice, address owner, address buyer, address tokenPayment);
    
    function mintNative(address _contract, string memory cid) external payable;

    function mintMysteryBox(address _contract, address _to, uint256 _mintAmount) external payable;
    
    function isElegible(address _contract) external view returns(bool);

    function getCreator(bytes32 _hash) external view returns(address);

    function reveal(address _contract, uint tokenId) external payable;

    function revealAll(address _contract, uint[] calldata tokenIds) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }
}

pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0-or-later

import "@openzeppelin/contracts/access/Ownable.sol";

contract ToppySupportPayment is Ownable{

    mapping (address => bool) public eligibleTokens;
  
    constructor() {}

    function isEligibleToken(address _token) public view returns (bool){
        return eligibleTokens[_token];
    }
    
    function addSupportedPayments(address[] calldata _paymentAddress, bool[] calldata _eligible) public onlyOwner {
        
        for (uint i = 0; i < _paymentAddress.length; i++) {
            eligibleTokens[_paymentAddress[i]] = _eligible[i];
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
interface IERC165 {
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