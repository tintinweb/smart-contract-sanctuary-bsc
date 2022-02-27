// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./access/Ownable.sol";
import "./libraries/Percentages.sol";
import "./utils/ReentrancyGuard.sol";

interface INft {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function owner() external view returns (address);
}

interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IDexRouter {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}

interface IVestedRebatesManager {
    function addUserRebate(address _user, uint _amount) external;
}

interface IDiscount {
    function isApplicable(address _user) external view returns (bool);
}

contract NftMarket is Ownable, ReentrancyGuard {
    using Percentages for uint;

    enum PaymentMethod { BNB, BEP20 }
    enum SaleType { DIRECT, OFFER, BOTH }
    enum SaleState { OPEN, CLOSED }
    
    struct Offer {
        address offeror;
        uint amount;
        uint discount;
        bool claimed;
    }

    struct Listing {
        address owner;
        PaymentMethod paymentMethod;
        address paymentToken;
        SaleType saleType;
        SaleState saleState;
        uint targetPrice;
        uint minimumPrice;
        address nft;
        uint tokenId;
        uint saleEnd;
        uint graceEnd;
        uint closedBlock;        
    }

    struct Collection {
        address owner;
        string name;
        address treasury;
        uint royalties;
        address[] nfts;
    }

    struct NftCollectionInfo {
        uint collectionId;
        uint index;
        bool inCollection;
    }

    struct DiscountInfo {
        uint percentage;
        bool enabled;
        bool created;
    }

    struct Bep20Info {
        uint marketTax;
        bool enabled;
        bool created;
    }

    address payable public                  treasury;               // The treasury address
    IToken                                  public  zombie;                 // The ZMBE token
    IDexRouter                              public  dexRouter;              // The router for DEX operations
    Listing[]                               public  listings;               // The listings
    uint                                    public  marketTaxBnb = 100;     // Base tax rate for open market sales
    uint                                    public  minTax = 25;            // Minimum tax of any sale
    uint                                    public  maxTax = 250;           // Maximum marketTax value
    uint                                    public  maxRoyalties = 1000;    // Maximum marketTax value
    uint                                    public  taxRebate = 5000;       // Percentage of tax that is rebated on BNB purchases
    uint                                    public  gracePeriod = 3600;     // Time after an auction listing is made that it can be cancelled with bids on it
    mapping(address => address)             public  nftModerators;          // Whitelist select collection owners before feature is open to the public
    mapping(address => DiscountInfo)        public  discountInfo;           // Mapping containing details on each discount
    mapping(address => Bep20Info)           public  bep20Info;
    mapping(address => NftCollectionInfo)   public  nftCollectionInfo;      // Mapping that returns the collection id of an nft
    mapping(address => bool)                public  hasTraded;
    Collection[]                            public  collections;
    IVestedRebatesManager                   public  rebatesManager;

    mapping(uint => mapping(address => Offer[])) public offers;

    // Events for notifying about things
    event CreateListing(uint indexed id, address indexed owner, address indexed nft, uint tokenId, uint targetPrice, SaleType _saleType, uint _targetPrice, uint _saleEnd);
    event CancelListing(uint indexed id, address indexed owner);
    event TransferNft(uint id, address recipient);
    event CreateDiscount(address indexed _addr);
    event SetBep20(address indexed _addr, uint marketTax, bool enabled);
    event PopulateCollection(uint indexed id, address indexed owner, string name, address treasury, uint royalties);
    event TransferCollectionOwnership(uint indexed id, address indexed newOwner);
    event AddNftToCollection(uint indexed id, uint index, address nft);
    event RemoveNftFromCollection(uint indexed id, uint index, address nft);
    event SetModerator(address indexed nft, address indexed newModerator);
    event TransferTax(uint indexed listingId, address indexed paymentToken, uint amount, address treasury);
    event TransferPayment(uint indexed listingId, address indexed paymentToken, uint amount, address indexed recipient);
    event CreateOffer(uint indexed listingId, uint indexed offerId, address indexed offeror, uint amount, uint discount);
    event WithdrawOffer(uint indexed listingId, uint offerId, address indexed paymentToken, address indexed offeror);
    event AcceptOffer(uint indexed listingId, uint offerId, address indexed paymentToken, address indexed offeror, uint amount);
    event DirectBuy(uint indexed listingId, address indexed buyer, address indexed paymentToken, uint amount);

    // Constructor for constructing things
    constructor(address _treasury, address _zombie, address _dexRouter, address _rebatesManager) {
        treasury = payable(_treasury);
        zombie = IToken(_zombie);
        dexRouter = IDexRouter(_dexRouter);
        rebatesManager = IVestedRebatesManager(_rebatesManager);
    }

    // Modifier to ensure a listing is valid
    modifier validListing(uint _listing) {
        require(_listing < totalListings(), 'invalid listing ID');
        Listing storage listing = listings[_listing];
        require(listing.saleState == SaleState.OPEN, 'not open');
        require(listing.saleEnd == 0 || block.timestamp <= listing.saleEnd, 'sale ended');
        _;
    }

    /*
       * Marketplace management functions (onlyOwner)
    */

    // Function for setting the treasury address
    function setTreasury(address _treasury) public onlyOwner() { treasury = payable(_treasury); }
    function setDexRouter(address _dexRouter) public onlyOwner() { dexRouter = IDexRouter(_dexRouter); }
    function setTaxRebate(uint _taxRebate) public onlyOwner() { taxRebate = _taxRebate; }
    function setRebatesManager(address _rebatesManager) public onlyOwner() { rebatesManager = IVestedRebatesManager(_rebatesManager); }

    // Function to set the tax rates
    function setMarketTaxBnb(uint _marketTaxBnb) public onlyOwner() {
        require(_marketTaxBnb <= maxTax, 'tax must be <= maxTax.');
        marketTaxBnb = _marketTaxBnb;
    }

    function updateDiscount(address _addr, uint _percentage, bool _enabled) public onlyOwner() {
        DiscountInfo storage info = discountInfo[_addr];
        info.percentage = _percentage;
        info.enabled = _enabled;

        if (!info.created) {
            info.created = true;
            emit CreateDiscount(_addr);
        }
    }

    function setBep20(address _addr, uint _marketTax, bool _enabled) public onlyOwner() {
        require(_marketTax <= maxTax, 'must be <= maxTax');
        Bep20Info storage info = bep20Info[_addr];
        info.marketTax = _marketTax;
        info.enabled = _enabled;

        if (!info.created) info.created = true;
        emit SetBep20(_addr, _marketTax, _enabled);
    }

    /*
       * Collection management functions
    */

    function setModerator(address _nft, address _moderator) public {
        require(INft(_nft).owner() == msg.sender || msg.sender == owner(), 'must be owner');
        nftModerators[_nft] = _moderator;
        emit SetModerator(_nft, _moderator);
    }

    function createCollection(string memory _name, address _treasury, uint _royalties) public {
        require(_royalties <= maxRoyalties, 'must be <= the max');
        address[] memory nfts;
        collections.push(Collection({owner: msg.sender, name: _name, treasury: _treasury, royalties: _royalties, nfts: nfts}));
        emit PopulateCollection(collections.length - 1, msg.sender, _name, _treasury, _royalties);
    }

    function transferCollectionOwnership(uint _id, address _newOwner) public {
        Collection storage info = collections[_id];
        require(info.owner == msg.sender, 'must be owner');
        info.owner = _newOwner;
        emit TransferCollectionOwnership(_id, _newOwner);
    }

    function updateCollection(uint _id, string memory _name, address _treasury, uint _royalties) public {
        Collection storage info = collections[_id];
        require(info.owner == msg.sender, 'must be owner');
        require(_royalties <= maxRoyalties, 'must be <= the max');
        info.name = _name;
        info.treasury = _treasury;
        info.royalties = _royalties;
        emit PopulateCollection(_id, msg.sender, _name, _treasury, _royalties);
    }

    function addNftToCollection(uint _id, address _nft) public {
        Collection storage collection = collections[_id];
        require(collection.owner == msg.sender || nftModerators[_nft] == msg.sender, 'must be owner');
        NftCollectionInfo storage info = nftCollectionInfo[_nft];
        require(!info.inCollection, 'already belongs to a collection');
        collection.nfts.push(_nft);
        info.collectionId = _id;
        info.inCollection = true;
        info.index = collection.nfts.length - 1;
        emit AddNftToCollection(_id, info.index, _nft);
    }

    function removeNftFromCollection(address _nft) public {
        NftCollectionInfo storage info = nftCollectionInfo[_nft];
        require(info.inCollection, 'does not belong to a collection');
        require(collections[nftCollectionInfo[_nft].collectionId].owner == msg.sender, 'must be owner');

        address[] storage nfts = collections[info.collectionId].nfts;
        address lastNft = nfts[nfts.length - 1];
        nfts[info.index] = lastNft;
        nfts.pop();
        nftCollectionInfo[lastNft].index = info.index;

        emit RemoveNftFromCollection(info.collectionId, info.index, _nft);

        info.inCollection = false;
        info.index = 0;
    }

    /*
       * Buyer functions
    */

    // Function to buy a listing with BNB
    function directBuyBnb(uint _listing, address[] memory _discountAddresses) public payable validListing(_listing) nonReentrant() {
        Listing storage listing = listings[_listing];
        require(listing.saleType == SaleType.DIRECT || listing.saleType == SaleType.BOTH, 'incorrect sale type');
        require(listing.paymentMethod == PaymentMethod.BNB, 'incorrect sale type');
        require(listing.targetPrice == msg.value, 'incorrect amount');
        _payBnb(listing.targetPrice, msg.sender, _listing, calculateDiscount(msg.sender, _discountAddresses));
        _sendNft(_listing, msg.sender);
        emit DirectBuy(_listing, msg.sender, address(0), listing.targetPrice);
    }

    // Function to buy a listing with a BEP20
    function directBuyBep20(uint _listing, address[] memory _discountAddresses) public validListing(_listing) nonReentrant() {
        Listing storage listing = listings[_listing];
        require(listing.saleType == SaleType.DIRECT || listing.saleType == SaleType.BOTH, 'incorrect sale type');
        require(listing.paymentMethod == PaymentMethod.BEP20, 'incorrect sale type');

        _payBep20(listing.targetPrice, msg.sender, msg.sender, _listing, calculateDiscount(msg.sender, _discountAddresses));
        _sendNft(_listing, msg.sender);
        emit DirectBuy(_listing, msg.sender, listing.paymentToken, listing.targetPrice);
    }

    function createOffer(uint _listing, uint _amount, address _paymentToken, address[] memory _discountAddresses) public payable validListing(_listing) {
        Listing storage listing = listings[_listing];
        require(listing.saleType == SaleType.OFFER || listing.saleType == SaleType.BOTH, 'incorrect sale type');
        require(listing.owner != msg.sender, 'cannot offer on your own listing');
        Offer[] storage _offers = offers[_listing][_paymentToken];
        require(_amount > _minimumOfferAmount(_listing, _paymentToken), 'must be > last offer');
        
        if(listing.saleType == SaleType.BOTH) require(_amount < listing.targetPrice, 'must be < direct sale price');

        if(listing.saleEnd != 0) {
            require(listing.paymentToken == _paymentToken, 'requires using the sellers chosen token');
            require(_amount >= listing.minimumPrice, 'offer is below minimum price');
        }

        uint _discount = calculateDiscount(msg.sender, _discountAddresses);
        _offers.push(Offer({offeror: msg.sender, amount: _amount, discount: _discount, claimed: false}));

        if(_paymentToken != address(0)) {
            require(msg.value == 0, 'offer does not require BNB');
            require(bep20Info[_paymentToken].enabled, 'token not enabled');

            uint initialBalance = IToken(_paymentToken).balanceOf(address(this));
            IToken(_paymentToken).transferFrom(msg.sender, address(this), _amount);
            require(IToken(_paymentToken).balanceOf(address(this)) == initialBalance + _amount, 'token not enabled');
        } else {
            require(msg.value == _amount, 'incorrect amount');
            require(_amount >= 10000, 'incorrect amount');
        }
        emit CreateOffer(_listing, _offers.length - 1, msg.sender, _amount, _discount);
    }

    function withdrawOffer(uint _listing, uint _offer, address _paymentToken) public nonReentrant() {
        require(_listing < totalListings(), 'invalid listing ID');
        require(_paymentToken == address(0) || bep20Info[_paymentToken].created, 'token not enabled');
        require(_offer < totalOffers(_listing, _paymentToken), 'does not exist');
        Offer storage offer = offers[_listing][_paymentToken][_offer];
        require(!offer.claimed, 'already claimed');
        require(msg.sender == offer.offeror, 'must be owner');

        if(_offer == totalOffers(_listing, _paymentToken) - 1) 
            require(!isAuction(_listing) || listings[_listing].saleState == SaleState.CLOSED, 'highest bid is final');

        if(_paymentToken == address(0)) _safeTransfer(offer.offeror, offer.amount);
        else IToken(_paymentToken).transfer(offer.offeror, offer.amount);

        offer.claimed = true;
        emit WithdrawOffer(_listing, _offer, _paymentToken, msg.sender);
    }

    /*
       * Listing management functions
    */

    function listNft(address _nft, uint _tokenId, PaymentMethod _paymentMethod, address _paymentToken, SaleType _saleType, uint _targetPrice, uint _minimumPrice, uint _saleEnd) public {
        INft(_nft).transferFrom(msg.sender, address(this), _tokenId);
        require(INft(_nft).ownerOf(_tokenId) == address(this), 'transfer failed');

        if(_paymentMethod == PaymentMethod.BNB) {
            require(_paymentToken == address(0), 'must be zero address for BNB listings'); 
            require(_targetPrice >= 10000 || _targetPrice == 0, 'incorrect amount');
            require(_minimumPrice >= 10000 || _minimumPrice == 0, 'incorrect amount');
        }
        else require(bep20Info[_paymentToken].enabled, 'token not enabled');

        listings.push(Listing({
            owner: msg.sender,
            paymentMethod: _paymentMethod,
            paymentToken: _paymentToken,
            saleType: _saleType,
            saleState: SaleState.OPEN,
            targetPrice: _targetPrice,
            minimumPrice: _minimumPrice,
            nft: _nft,
            tokenId: _tokenId,
            saleEnd: _saleEnd,
            graceEnd: block.timestamp + gracePeriod,
            closedBlock: 0
        }));

        emit CreateListing(listings.length - 1, msg.sender, _nft, _tokenId, _targetPrice, _saleType, _targetPrice, _saleEnd);
    }

    function claimAuction(uint _listing, uint _offer, address _paymentToken) public nonReentrant() {
        require(_listing < totalListings(), 'invalid listing ID');
        require(isAuction(_listing), 'incorrect sale type');
        Listing storage listing = listings[_listing];
        require(listing.saleState == SaleState.OPEN, 'not open');
        require(block.timestamp > listing.saleEnd, 'has not ended');
        require(_offer < totalOffers(_listing, _paymentToken), 'does not exist');
        Offer storage offer = offers[_listing][_paymentToken][_offer];

        require(_offer == totalOffers(_listing, _paymentToken) - 1, 'must be the winning bid');

        if(_paymentToken == address(0)) _payBnb(offer.amount, offer.offeror, _listing, offer.discount);
        else _payBep20(offer.amount, offer.offeror, address(this), _listing, offer.discount);

        offer.claimed = true;
        _sendNft(_listing, offer.offeror);
        emit AcceptOffer(_listing, _offer, _paymentToken, offer.offeror, offer.amount);
    }

    function acceptOffer(uint _listing, uint _offer, address _paymentToken) public nonReentrant() {
        require(_listing < totalListings(), 'invalid listing ID');
        Listing storage listing = listings[_listing];
        require(listing.owner == msg.sender, 'must be owner');
        require(listing.saleState == SaleState.OPEN, 'not open');
        require(_paymentToken == address(0) || bep20Info[_paymentToken].created, 'token not enabled');
        require(_offer < totalOffers(_listing, _paymentToken), 'does not exist');
        Offer storage offer = offers[_listing][_paymentToken][_offer];

        if(isAuction(_listing)) {
            require(block.timestamp > listing.saleEnd, 'has not ended');
            require(_offer == totalOffers(_listing, _paymentToken) - 1, 'must accept the final bid');
        }

        if(_paymentToken == address(0)) _payBnb(offer.amount, offer.offeror, _listing, offer.discount);
        else {
            listing.paymentToken = _paymentToken;
            _payBep20(offer.amount, offer.offeror, address(this), _listing, offer.discount);
        }

        offer.claimed = true;
        _sendNft(_listing, offer.offeror);
        emit AcceptOffer(_listing, _offer, _paymentToken, offer.offeror, offer.amount);
    }

    // Function to cancel a listing
    function cancel(uint _listing) public {
        require(_listing < totalListings(), 'invalid listing ID');
        Listing storage listing = listings[_listing];
        require(listing.saleState == SaleState.OPEN, 'not open');
        require(listing.owner == msg.sender, 'must be owner');

        if (isAuction(_listing) && block.timestamp > listing.graceEnd)
            require(offers[_listing][listing.paymentToken].length == 0, 'cannot cancel auction with bidders');

        INft nft = INft(listing.nft);
        nft.transferFrom(address(this), msg.sender, listings[_listing].tokenId);
        require(nft.ownerOf(listing.tokenId) == msg.sender, 'transfer failed');
        listing.saleState = SaleState.CLOSED;
        listing.closedBlock = block.number;
        emit CancelListing(_listing, msg.sender);
    }

    /*
       * View functions
    */

    function calculateDiscount(address user, address[] memory discountAddresses) public view returns (uint) {
        uint _discount = 0;
        for (uint x = 0; x < discountAddresses.length; x++) {
            if (discountInfo[discountAddresses[x]].enabled && IDiscount(discountAddresses[x]).isApplicable(user)) _discount += discountInfo[discountAddresses[x]].percentage;
        }
        return _discount;
    }

    function isAuction(uint _listing) public view returns(bool) {
        return (listings[_listing].saleType == SaleType.OFFER || listings[_listing].saleType == SaleType.BOTH) && listings[_listing].saleEnd != 0;
    }

    // Function to get the count of listings
    function totalListings() public view returns (uint) { return listings.length; }
    function totalOffers(uint _listing, address _paymentToken) public view returns (uint) { return offers[_listing][_paymentToken].length; }
    function totalCollectionNfts(uint _collection) public view returns (uint) { return collections[_collection].nfts.length; }
    function listingNfts(uint _collection) public view returns (address[] memory) { return collections[_collection].nfts; }

    /*
       * Private helpers
    */

    // Returns amount of last non-withdrawn offer
    function _minimumOfferAmount(uint _listing, address _paymentToken) private view returns (uint) {
        Offer[] storage _offers = offers[_listing][_paymentToken];
        if (_offers.length == 0) return 0;
        for(uint i = _offers.length; i > 0; i--) 
            if(!_offers[i - 1].claimed) return _offers[i - 1].amount;
        return 0;
    }

    // Must be called on a valid listing
    function _payBep20(uint _amount, address _buyer, address _tokenLocation, uint _listing, uint _discount) private {
        Listing storage listing = listings[_listing];
        Bep20Info storage paymentInfo = bep20Info[listing.paymentToken];

        if (_tokenLocation == address(this)) IToken(listing.paymentToken).approve(address(this), _amount);

        // cap _discount to prevent subtraction underflow error
        if(_discount > paymentInfo.marketTax) _discount = paymentInfo.marketTax;

        uint taxBP = paymentInfo.marketTax - _discount;
        if (taxBP < minTax) taxBP = minTax;

        uint tax = _amount.calcPortionFromBasisPoints(taxBP);
        uint remaining = _amount - tax;

        // Collection royalties
        NftCollectionInfo storage _nftCollectionInfo = nftCollectionInfo[listing.nft];
        if(_nftCollectionInfo.inCollection) {
            Collection storage collection = collections[_nftCollectionInfo.collectionId];
            uint royalties = _amount.calcPortionFromBasisPoints(collection.royalties);
            IToken(listing.paymentToken).transferFrom(_buyer, collection.treasury, royalties);
            remaining -= royalties;
        }

        IToken(listing.paymentToken).transferFrom(_tokenLocation, treasury, tax);
        emit TransferTax(_listing, listing.paymentToken, tax, treasury);

        IToken(listing.paymentToken).transferFrom(_tokenLocation, listing.owner, remaining);
        emit TransferPayment(_listing, listing.paymentToken, remaining, listing.owner);
    }

    // Must be called on a valid listing
    function _payBnb(uint _amount, address _buyer, uint _listing, uint _discount) private {
        uint remainingTaxBP = marketTaxBnb;
        uint taxRebateBP = marketTaxBnb.calcPortionFromBasisPoints(taxRebate) + _discount;

        // cap taxRebateBP to prevent subtraction overflow
        if(taxRebateBP > marketTaxBnb) taxRebateBP = marketTaxBnb;
        if (marketTaxBnb - taxRebateBP < minTax) taxRebateBP -= minTax;

        require(taxRebateBP >= minTax, 'taxRebate < minTax');
        remainingTaxBP -= taxRebateBP;
        require(remainingTaxBP >= minTax, 'remainingTax < minTax');

        uint tax = _amount.calcPortionFromBasisPoints(remainingTaxBP);
        uint rebate = _amount.calcPortionFromBasisPoints(taxRebateBP);
        uint remaining = _amount - (tax + rebate);

        require(_amount.calcBasisPoints(tax) >= minTax || _amount == 0, 'minTax: Discount Error occurred');
        require(_amount.calcBasisPoints(tax) <= maxTax, 'maxTax: Discount Error occurred');
        require(_amount.calcBasisPoints(tax + rebate) <= marketTaxBnb, 'marketTaxBnb: Discount Error occurred');

        // Collection royalties
        NftCollectionInfo storage _nftCollectionInfo = nftCollectionInfo[listings[_listing].nft];
        if(_nftCollectionInfo.inCollection) {
            Collection storage collection = collections[_nftCollectionInfo.collectionId];
            uint royalties = _amount.calcPortionFromBasisPoints(collection.royalties);
            _safeTransfer(collection.treasury, royalties);
            remaining -= royalties;
        }

        // Transfer tax to treasury
        _safeTransfer(treasury, tax);
        emit TransferTax(_listing, address(0), tax, treasury);

        if (rebate > 0) {
            // Store discount rebate in RebatesManager
            uint initialZombieBalance = IToken(zombie).balanceOf(address(this));
            uint boughtZmbe = _buyBackZmbe(rebate);
            require(IToken(zombie).balanceOf(address(this)) == initialZombieBalance + boughtZmbe, 'Buyback error occurred');
            IToken(zombie).approve(address(rebatesManager), boughtZmbe);
            rebatesManager.addUserRebate(_buyer, boughtZmbe);
            require(IToken(zombie).balanceOf(address(this)) == initialZombieBalance, 'Rebates error occurred');
        }        

        // Transfer remaining BNB to listing owner
        _safeTransfer(listings[_listing].owner, remaining);
        emit TransferPayment(_listing, address(0), remaining, listings[_listing].owner);
    }

    // Function to send the NFT at the end of a sale
    function _sendNft(uint _listing, address _recipient) private {
        INft nft = INft(listings[_listing].nft);
        nft.transferFrom(address(this), _recipient, listings[_listing].tokenId);
        require(nft.ownerOf(listings[_listing].tokenId) == _recipient, 'transfer failed');
        Listing storage listing = listings[_listing];
        listing.saleState = SaleState.CLOSED;
        listing.closedBlock = block.number;
        hasTraded[listing.owner] = true;
        hasTraded[_recipient] = true;
        emit TransferNft(_listing, _recipient);
    }

    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success,) = _recipient.call{value : _amount}("");
        require(_success, "transfer failed");
    }

    function _buyBackZmbe(uint _bnbAmount) private returns (uint) {
        uint256 initialZombieBalance = zombie.balanceOf(address(this));
        _swapBnbForZombie(_bnbAmount);
        return zombie.balanceOf(address(this)) - initialZombieBalance;
    }

    // Function to buy zombie tokens with BNB
    function _swapBnbForZombie(uint256 _bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(zombie);
        dexRouter.swapExactETHForTokens{value : _bnbAmount}(0, path, address(this), block.timestamp);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.4;

library Percentages {
    // Get value of a percent of a number
    function calcPortionFromBasisPoints(uint _amount, uint _basisPoints) public pure returns(uint) {
        if(_basisPoints == 0 || _amount == 0) {
            return 0;
        } else {
            uint _portion = _amount * _basisPoints / 10000;
            return _portion;
        }
    }

    // Get basis points (percentage) of _portion relative to _amount
    function calcBasisPoints(uint _amount, uint  _portion) public pure returns(uint) {
        if(_portion == 0 || _amount == 0) {
            return 0;
        } else {
            uint _basisPoints = (_portion * 10000) / _amount;
            return _basisPoints;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}