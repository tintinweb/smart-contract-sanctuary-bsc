// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract PlearnNFTMarketplace is IERC721Receiver, Ownable, ReentrancyGuard, Pausable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    //base divide rate percentage
    uint256 public constant RATE_BASE = 10000;
    uint256 public constant TOTAL_MAX_FEE = 1000; //(1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05% when divide 10000)

    enum Status {
        Pending,
        Open,
        Close,
        Accepted,
        Cancelled,
        Finished
    }

    struct Collection {
        Status status; // status of the collection
        address creatorAddress; // address of the creator
        uint256 creatorFee; // creator fee (1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05%)
        uint256 tradingFee; // trading fee (1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05%)
    }

    enum Side {
        Sell,
        Buy
    }

    struct Offer {
        address collection;
        uint256 tokenId;
        address dealToken;
        uint256 price;
        address user; //who make a offer
        address acceptUser;
        Status status;
        Side side;
    }

    struct Auction {
        address collection;
        uint256 tokenId;
        address seller;
        address bidder;
        address dealToken;
        uint256 askPrice;
        uint256 bidPrice;
        uint256 netBidPrice;
        uint256 startBlock;
        uint256 endTimestamp;
        Status status;
    }

    //Collection (ERC721)
    mapping(address => Collection) private _collections; // Details about the collections

    address public treasuryAddress;

    Counters.Counter private _offerId;
    mapping(uint256 => Offer) public offers;

    Counters.Counter private _auctionId;
    //Auction[] public auctions;
    mapping(uint256 => Auction) private auctions;
    uint256 public extendEndTimestamp; // in seconds
    uint256 public minAuctionDuration; // in seconds

    uint256 public bidderIncentiveRate;
    uint256 public bidIncrRate;

    EnumerableSet.AddressSet private _dealTokensWhitelist;

    mapping(address => mapping(uint256 => uint256)) private _tokenSellOffers; // collection => tokenId => id
    mapping(address => mapping(address => mapping(uint256 => uint256))) private _userBuyOffers; //user => collection => nft => tokenId => id

    mapping(address => mapping(uint256 => uint256)) private _auctionNftIndex; // collection -> tokenId -> id

    event CollectionNew(address indexed collection, address indexed creator, uint256 creatorFee, uint256 tradingFee);
    event CollectionUpdate(address indexed collection, address indexed creator, uint256 creatorFee, uint256 tradingFee);
    event CollectionUpdateStatus(address indexed collection, Status status);
    event CollectionDelete(address indexed collection);

    event DealTokensNew(address[] token);
    event DealTokensDelete(address[] token);
    event NewTreasuryAddress(address _treasuryAddress);

    event NewOffer(
        uint256 indexed id,
        address user,
        address collection,
        uint256 tokenId,
        address dealToken,
        uint256 price,
        Side side
    );

    event CancelOffer(uint256 indexed id);
    event AcceptOffer(uint256 indexed id, address indexed user, uint256 price);

    event NewAuction(
        uint256 indexed id,
        address indexed seller,
        address collection,
        uint256 tokenId,
        address dealToken,
        uint256 askPrice,
        uint256 endTimestamp
    );
    event NewBid(uint256 indexed id, address indexed bidder, uint256 price, uint256 netPrice, uint256 endTimestamp);
    event AuctionCancelled(uint256 indexed id);
    event AuctionFinished(uint256 indexed id, address indexed winner);

    event NonFungibleTokenRecovery(address indexed token, uint256 tokenId);
    event TokenRecovery(address indexed token, uint256 amount);

    constructor() {
        extendEndTimestamp = 600; //10 minutes
        minAuctionDuration = 900; //15 minutes

        bidderIncentiveRate = 500; //5%
        bidIncrRate = 1000; //10%
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
        //TODO("Wait for auction")
        return this.onERC721Received.selector;
    }

    //Owner Functions

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice Add a new collection
     * @param collection: collection address
     * @param creator: creator address (must be 0x00 if none)
     * @param creatorFee: creator fee (1000 = 10%, 500 = 5%, 100 = 1%, 5 = 0.05%, 0 if creator is 0x00)
     * @param tradingFee: trading fee (1000 = 10%, 500 = 5%, 100 = 1%, 5 = 0.05%)
     * @dev Callable by admin
     */
    function addCollection(
        address collection,
        address creator,
        uint256 creatorFee,
        uint256 tradingFee
    ) external onlyOwner {
        require(_collections[collection].status == Status.Pending, "Marketplace: Collection already listed");
        require(IERC721(collection).supportsInterface(0x80ac58cd), "Marketplace: Not ERC721");
        require(
            (creatorFee == 0 && creator == address(0)) || (creatorFee != 0 && creator != address(0)),
            "Marketplace: Creator parameters incorrect"
        );
        require(tradingFee + creatorFee <= TOTAL_MAX_FEE, "Marketplace: Sum of fee must inferior to TOTAL_MAX_FEE");

        _collections[collection] = Collection({
            status: Status.Open,
            creatorAddress: creator,
            creatorFee: creatorFee,
            tradingFee: tradingFee
        });

        emit CollectionNew(collection, creator, creatorFee, tradingFee);
    }

    /**
     * @notice Allows the admin to close collection for trading and new listing
     * @param collection: collection address
     * @dev Callable by admin
     */
    function closeCollection(address collection) external collectionExists(collection) onlyOwner {
        _collections[collection].status = Status.Close;

        emit CollectionUpdateStatus(collection, Status.Close);
    }

    /**
     * @notice Allows the admin to open collection for trading and new listing
     * @param collection: collection address
     * @dev Callable by admin
     */
    function openCollection(address collection) external collectionExists(collection) onlyOwner {
        _collections[collection].status = Status.Open;

        emit CollectionUpdateStatus(collection, Status.Open);
    }

    /**
     * @notice Modify collection characteristics
     * @param collection: collection address
     * @param creator: creator address (must be 0x00 if none)
     * @param creatorFee: creator fee (100 = 1%, 500 = 5%, 5 = 0.05%, 0 if creator is 0x00)
     * @param tradingFee: trading fee (100 = 1%, 500 = 5%, 5 = 0.05%)
     * @dev Callable by admin
     */
    function updateCollection(
        address collection,
        address creator,
        uint256 creatorFee,
        uint256 tradingFee
    ) external collectionExists(collection) onlyOwner {
        require(
            (creatorFee == 0 && creator == address(0)) || (creatorFee != 0 && creator != address(0)),
            "Marketplace: Creator parameters incorrect"
        );
        require(tradingFee + creatorFee <= TOTAL_MAX_FEE, "Marketplace: Sum of fee must inferior to TOTAL_MAX_FEE");

        _collections[collection] = Collection({
            status: Status.Open,
            creatorAddress: creator,
            creatorFee: creatorFee,
            tradingFee: tradingFee
        });

        emit CollectionUpdate(collection, creator, creatorFee, tradingFee);
    }

    /**
     * @notice Delete a collection from maketplace
     * @param collection: collection address
     * @dev Callable by admin
     */
    function deleteCollection(address collection) external collectionExists(collection) onlyOwner {
        //TODO("Befire delete collection may be check and close trading in collection")

        delete _collections[collection];

        emit CollectionDelete(collection);
    }

    function addWhiteListDealTokens(address[] calldata tokens) external onlyOwner {
        require(tokens.length > 0, "Marketplace: tokeens empty");

        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            require(token != address(0), "Marketplace: Address cant be 0");
            require(!EnumerableSet.contains(_dealTokensWhitelist, token), "Marketplace: Token already exists");
            EnumerableSet.add(_dealTokensWhitelist, token);
        }

        emit DealTokensNew(tokens);
    }

    function deleteWhiteListDealTokens(address[] calldata tokens) external onlyOwner {
        require(tokens.length > 0, "Marketplace: tokeens empty");

        for (uint256 i = 0; i < tokens.length; i++) {
            EnumerableSet.remove(_dealTokensWhitelist, tokens[i]);
        }

        emit DealTokensDelete(tokens);
    }

    function setTreasuryAddress(address treasuryAddress_) public onlyOwner {
        require(treasuryAddress_ != address(0), "Marketplace: Address cant be zero");
        treasuryAddress = treasuryAddress_;
        emit NewTreasuryAddress(treasuryAddress_);
    }

    function updateSettings(
        uint256 extendEndTimestamp_,
        uint256 minAuctionDuration_,
        uint256 bidderIncentiveRate_,
        uint256 bidIncrRate_
    ) public onlyOwner {
        extendEndTimestamp = extendEndTimestamp_;
        minAuctionDuration = minAuctionDuration_;
        bidderIncentiveRate = bidderIncentiveRate_;
        bidIncrRate = bidIncrRate_;
    }

    /**
     * @notice Allows the owner to recover non-fungible tokens sent to the contract by mistake
     * @param token: NFT token address
     * @param tokenId: tokenId
     * @dev Callable by owner
     */
    function recoverNonFungibleToken(address token, uint256 tokenId) external onlyOwner {
        IERC721(token).transferFrom(address(this), address(msg.sender), tokenId);

        emit NonFungibleTokenRecovery(token, tokenId);
    }

    /**
     * @notice Allows the owner to recover tokens sent to the contract by mistake
     * @param token: token address
     * @dev Callable by owner
     */
    function recoverToken(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance != 0, "Plearn NFT: Cannot recover zero balance");

        IERC20(token).safeTransfer(address(msg.sender), balance);

        emit TokenRecovery(token, balance);
    }

    //Public Functions

    function getCollection(address collection) public view returns (Collection memory) {
        return _collections[collection];
    }

    /**
     * @notice Calculate price and associated fees for a collection
     * @param collection: address of the collection
     * @param price: listed price
     */
    function calculatePriceAndFeesForCollection(address collection, uint256 price)
        external
        view
        returns (
            uint256 netPrice,
            uint256 tradingFee,
            uint256 creatorFee
        )
    {
        if (_collections[collection].status != Status.Open) {
            return (0, 0, 0);
        }

        return (_calculatePriceAndFeesForCollection(collection, price));
    }

    function dealTokensWhitelist() public view returns (address[] memory) {
        address[] memory tokens = new address[](EnumerableSet.length(_dealTokensWhitelist));

        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i] = EnumerableSet.at(_dealTokensWhitelist, i);
        }

        return tokens;
    }

    // Offer Functions

    function offer(
        Side side,
        address collection,
        uint256 tokenId,
        address dealToken,
        uint256 price
    )
        public
        notContract
        nonReentrant
        whenNotPaused
        collectionOpen(collection)
        tokenExists(collection, tokenId)
        validDealToken(dealToken)
    {
        if (side == Side.Buy) {
            _offerBuy(collection, tokenId, dealToken, price);
        } else if (side == Side.Sell) {
            _offerSell(collection, tokenId, dealToken, price);
        } else {
            revert("Marketplace: Not supported");
        }
    }

    function _offerBuy(
        address collection,
        uint256 tokenId,
        address dealToken,
        uint256 price
    ) internal {
        require(price > 0, "Marketplace: Buyer should pay");

        // Transfer deal token to maketplace
        IERC20(dealToken).safeTransferFrom(msg.sender, address(this), price);

        _offerId.increment();
        uint256 newOfferId = _offerId.current();

        offers[newOfferId] = Offer({
            collection: collection,
            tokenId: tokenId,
            dealToken: dealToken,
            price: price,
            user: msg.sender,
            acceptUser: address(0),
            status: Status.Open,
            side: Side.Buy
        });

        // Cancel previous buy offer of buyer
        _cancelBuyOffer(_userBuyOffers[msg.sender][collection][tokenId]);
        // Update new offer id for for buyer
        _userBuyOffers[msg.sender][collection][tokenId] = newOfferId;

        emit NewOffer(newOfferId, msg.sender, collection, tokenId, dealToken, price, Side.Buy);
    }

    function _offerSell(
        address collection,
        uint256 tokenId,
        address dealToken,
        uint256 price
    ) internal {
        require(msg.value == 0, "Marketplace: Seller should not pay");
        require(price > 0, "Marketplace: Price must > 0");

        require(_getTokenOwner(collection, tokenId) == msg.sender, "Marketplace: Only owner can call");
        require(_isTokenApproved(collection, tokenId, msg.sender), "Marketplace: Token is not approved");

        _offerId.increment();
        uint256 newOfferId = _offerId.current();

        offers[newOfferId] = Offer({
            collection: collection,
            tokenId: tokenId,
            dealToken: dealToken,
            price: price,
            user: msg.sender,
            acceptUser: address(0),
            status: Status.Open,
            side: Side.Sell
        });

        //Cancel previous sell offer of seller
        _cancelSellOffer(_tokenSellOffers[collection][tokenId]);
        //Update new offer id for for seller
        _tokenSellOffers[collection][tokenId] = newOfferId;

        emit NewOffer(newOfferId, msg.sender, collection, tokenId, dealToken, price, Side.Sell);
    }

    function getTokenOfferSell(address collection, uint256 tokenId)
        public
        view
        collectionOpen(collection)
        tokenExists(collection, tokenId)
        returns (Offer memory)
    {
        return offers[_tokenSellOffers[collection][tokenId]];
    }

    function getUserOfferBuy(
        address user,
        address collection,
        uint256 tokenId
    ) public view collectionOpen(collection) tokenExists(collection, tokenId) returns (Offer memory) {
        return offers[_userBuyOffers[user][collection][tokenId]];
    }

    function acceptOffer(uint256 id)
        public
        notContract
        nonReentrant
        whenNotPaused
        collectionOpen(offers[id].collection)
        offerExists(id)
        offerOpen(id)
    {
        if (offers[id].side == Side.Buy) {
            _acceptOfferBuy(id);
        } else {
            _acceptOfferSell(id);
        }
    }

    /**
     * @notice Caller is seller
     */
    function _acceptOfferBuy(uint256 id) internal {
        require(msg.value == 0, "Marketplace: Seller should not pay");

        Offer storage _offer = offers[id];

        require(_getTokenOwner(_offer.collection, _offer.tokenId) == msg.sender, "Marketplace: Only owner can call");
        require(_isTokenApproved(_offer.collection, _offer.tokenId, msg.sender), "Marketplace: Token is not approved");

        _offer.status = Status.Accepted;
        _offer.acceptUser = msg.sender; //Seller
        _unlinkBuyOffer(_offer);
        _unlinkSellOffer(_offer);

        // Calculate net price, trading fee and transfers to recipients
        _distributePayment(msg.sender, _offer.collection, _offer.dealToken, _offer.price);

        // Transfer nft to buyer
        IERC721(_offer.collection).safeTransferFrom(msg.sender, _offer.user, _offer.tokenId);

        emit AcceptOffer(id, msg.sender, _offer.price);
    }

    /**
     * @notice Caller is buyer
     */
    function _acceptOfferSell(uint256 id) internal {
        Offer storage _offer = offers[id];

        if (
            _getTokenOwner(_offer.collection, _offer.tokenId) != _offer.user ||
            !_isTokenApproved(_offer.collection, _offer.tokenId, _offer.user)
        ) {
            _cancelSellOffer(id);
            revert("Marketplace: Not supported (Token owner not is seller or token does not approve)");
        }

        // Transfer deal token to marketplace
        IERC20(_offer.dealToken).safeTransferFrom(msg.sender, address(this), _offer.price);

        _offer.status = Status.Accepted;
        _offer.acceptUser = msg.sender; //Buyer
        _unlinkBuyOffer(_offer);
        _unlinkSellOffer(_offer);

        // Calculate net price, trading fee and transfers to recipients
        _distributePayment(_offer.user, _offer.collection, _offer.dealToken, _offer.price);

        // Transfer nft to buyer
        IERC721(_offer.collection).safeTransferFrom(_offer.user, msg.sender, _offer.tokenId);

        emit AcceptOffer(id, msg.sender, _offer.price);
    }

    function cancelOffer(uint256 id)
        public
        notContract
        nonReentrant
        whenNotPaused
        offerExists(id)
        offerOpen(id)
        offerOwner(id)
    {
        if (offers[id].side == Side.Buy) {
            _cancelBuyOffer(id);
        } else {
            _cancelSellOffer(id);
        }
    }

    // function multiCancelOffer(uint256[] calldata offerIds_) public notContract {
    //     for (uint256 i = 0; i < offerIds_.length; i++) {
    //         cancelOffer(offerIds_[i]);
    //     }
    // }

    function _cancelBuyOffer(uint256 id) internal {
        if (id == 0 || id > _offerId.current()) return;

        Offer storage _offer = offers[id];
        if (_offer.status == Status.Open && _offer.side == Side.Buy) {
            _offer.status = Status.Cancelled;
            _transferERC20(_offer.dealToken, _offer.user, _offer.price);
            _unlinkBuyOffer(_offer);
            emit CancelOffer(id);
        }
    }

    function _unlinkBuyOffer(Offer memory offer_) internal {
        _userBuyOffers[offer_.user][offer_.collection][offer_.tokenId] = 0;
    }

    function _cancelSellOffer(uint256 id) internal {
        if (id == 0 || id > _offerId.current()) return;

        Offer storage _offer = offers[id];
        if (_offer.status == Status.Open && _offer.side == Side.Sell) {
            _offer.status = Status.Cancelled;
            _unlinkSellOffer(_offer);
            emit CancelOffer(id);
        }
    }

    function _unlinkSellOffer(Offer memory offer_) internal {
        _tokenSellOffers[offer_.collection][offer_.tokenId] = 0;
    }

    //Auction Functions

    function startAuction(
        address collection,
        uint256 tokenId,
        address dealToken,
        uint256 askPrice,
        uint256 endTimestamp
    )
        public
        notContract
        nonReentrant
        whenNotPaused
        collectionOpen(collection)
        tokenExists(collection, tokenId)
        validDealToken(dealToken)
    {
        require(_getTokenOwner(collection, tokenId) == msg.sender, "Marketplace: Only owner can call");
        require(_isTokenApproved(collection, tokenId, msg.sender), "Marketplace: Token is not approved");

        require(askPrice > 0, "Marketplace: Price must > 0");
        require(endTimestamp >= block.timestamp + minAuctionDuration, "Marketplace: Auction duration not long enough");

        //Cancel previous sell offer of seller
        _cancelSellOffer(_tokenSellOffers[collection][tokenId]);

        //Transfer nft to market place
        IERC721(collection).safeTransferFrom(msg.sender, address(this), tokenId);

        _auctionId.increment();
        uint256 newAuctionId = _auctionId.current();

        auctions[newAuctionId] = Auction({
            collection: collection,
            tokenId: tokenId,
            seller: msg.sender,
            bidder: address(0),
            dealToken: dealToken,
            askPrice: askPrice,
            bidPrice: 0,
            netBidPrice: 0,
            startBlock: block.number,
            endTimestamp: endTimestamp,
            status: Status.Open
        });

        _auctionNftIndex[collection][tokenId] = newAuctionId;

        emit NewAuction(newAuctionId, msg.sender, collection, tokenId, dealToken, askPrice, endTimestamp);
    }

    function getTokenAuction(address collection, uint256 tokenId)
        public
        view
        collectionOpen(collection)
        tokenExists(collection, tokenId)
        returns (Auction memory)
    {
        return auctions[_auctionNftIndex[collection][tokenId]];
    }

    function bid(uint256 id, uint256 offer_)
        public
        notContract
        nonReentrant
        whenNotPaused
        collectionOpen(auctions[id].collection)
        auctionExists(id)
        auctionOpen(id)
    {
        Auction storage auction = auctions[id];
        require(block.timestamp < auction.endTimestamp, "Marketplace: Auction finished");

        // Check minimum increment offer
        require(offer_ >= getMinBidPrice(id), "Marketplace: offer not enough");

        IERC20(auction.dealToken).safeTransferFrom(msg.sender, address(this), offer_);

        // Transfer some to previous bidder
        uint256 incentive = 0;
        if (auction.netBidPrice > 0 && auction.bidder != address(0)) {
            incentive = (offer_ * bidderIncentiveRate) / RATE_BASE;
            _transferERC20(auction.dealToken, auction.bidder, auction.netBidPrice + incentive);
        }

        // Update auction
        auction.bidPrice = offer_;
        auction.netBidPrice = offer_ - incentive;
        auction.bidder = msg.sender;

        // Update end time of auction if have bid in almost out of time
        if (block.timestamp + extendEndTimestamp >= auction.endTimestamp) {
            auction.endTimestamp += extendEndTimestamp;
        }

        emit NewBid(id, msg.sender, offer_, auction.netBidPrice, auction.endTimestamp);
    }

    function cancelAuction(uint256 id)
        public
        notContract
        nonReentrant
        whenNotPaused
        collectionOpen(auctions[id].collection)
        auctionExists(id)
        auctionOpen(id)
        isSeller(id)
    {
        Auction memory auction = auctions[id];
        require(auction.bidder == address(0), "Marketplace: Has bidder");
        _cancelAuction(id);
    }

    function _cancelAuction(uint256 id) internal {
        Auction storage auction = auctions[id];

        auction.status = Status.Cancelled;
        // Transfer nft back to seller
        IERC721(auction.collection).safeTransferFrom(address(this), auction.seller, auction.tokenId);

        delete _auctionNftIndex[auction.collection][auction.tokenId];
        emit AuctionCancelled(id);
    }

    // Anyone can collect any auction, as long as it's finished
    function collect(uint256[] calldata ids) public nonReentrant whenNotPaused {
        for (uint256 i = 0; i < ids.length; i++) {
            _collectOrCancel(ids[i]);
        }
    }

    function _collectOrCancel(uint256 id) internal auctionExists(id) auctionOpen(id) {
        Auction storage auction = auctions[id];
        require(block.timestamp >= auction.endTimestamp, "Marketplace: Auction not done yet");
        if (auction.bidder == address(0)) {
            _cancelAuction(id);
        } else {
            _collectAuction(id);
        }
    }

    function _collectAuction(uint256 id) internal {
        Auction storage auction = auctions[id];
        auction.status = Status.Finished;

        // Calculate net price, trading fee and transfers to recipients
        _distributePayment(auction.seller, auction.collection, auction.dealToken, auction.netBidPrice);

        // Transfer nft to win bidder
        IERC721(auction.collection).safeTransferFrom(address(this), auction.bidder, auction.tokenId);

        emit AuctionFinished(id, auction.bidder);
    }

    function getMinBidPrice(uint256 id) public view returns (uint256) {
        Auction memory auction = auctions[id];

        // minimum increment
        if (auction.bidPrice == 0) {
            return auction.askPrice;
        } else {
            return auction.bidPrice + (auction.bidPrice * bidIncrRate) / RATE_BASE;
        }
    }

    //Internal Functions

    function _isTokenApproved(
        address collection,
        uint256 tokenId,
        address owner
    ) internal view returns (bool) {
        return
            IERC721(collection).getApproved(tokenId) == address(this) ||
            IERC721(collection).isApprovedForAll(owner, address(this));
    }

    function _getTokenOwner(address collection, uint256 tokenId) internal view returns (address) {
        return IERC721(collection).ownerOf(tokenId);
    }

    /**
     * @notice Calculate price and associated fees for a collection
     * @param collection: address of the collection
     * @param price: listed price
     */
    function _calculatePriceAndFeesForCollection(address collection, uint256 price)
        internal
        view
        returns (
            uint256 netPrice,
            uint256 tradingFee,
            uint256 creatorFee
        )
    {
        tradingFee = (price * _collections[collection].tradingFee) / RATE_BASE;
        creatorFee = (price * _collections[collection].creatorFee) / RATE_BASE;

        netPrice = price - tradingFee - creatorFee;

        return (netPrice, tradingFee, creatorFee);
    }

    function _distributePayment(
        address seller,
        address collection,
        address dealToken,
        uint256 price
    ) internal {
        // Calculate the net price (collected by seller), trading fee (collected by treasury), creator fee (collected by creator)
        (uint256 netPrice, uint256 tradingFee, uint256 creatorFee) = _calculatePriceAndFeesForCollection(
            collection,
            price
        );

        // Transfer dealToken to seller
        _transferERC20(dealToken, seller, netPrice);

        // Tranfer trading fee to treasury
        if (tradingFee != 0) {
            _transferERC20(dealToken, treasuryAddress, tradingFee);
        }

        // Tranfer creator fee
        if (creatorFee != 0) {
            _transferERC20(dealToken, _collections[collection].creatorAddress, creatorFee);
        }
    }

    function _transferERC20(
        address token,
        address to,
        uint256 amount
    ) internal {
        require(amount > 0 && to != address(0), "Marketplace: Wrong amount or dest on transfer");
        IERC20(token).safeTransfer(to, amount);
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    // Modifiers
    modifier collectionExists(address collection) {
        require(_collections[collection].status != Status.Pending, "Marketplace: Collection not listed");
        _;
    }

    modifier collectionOpen(address collection) {
        require(_collections[collection].status == Status.Open, "Marketplace: Collection not listed or opened");
        _;
    }

    modifier tokenExists(address collection, uint256 tokenId) {
        require(IERC721(collection).ownerOf(tokenId) != address(0), "Marketplace: Token does not exist");
        _;
    }

    modifier validDealToken(address token) {
        require(EnumerableSet.contains(_dealTokensWhitelist, token), "Marketplace: Deal token not available");
        _;
    }

    modifier offerExists(uint256 id) {
        require(offers[id].status != Status.Pending, "Marketplace: Offer does not exist");
        _;
    }

    modifier offerOpen(uint256 id) {
        require(offers[id].status == Status.Open, "Marketplace: Offer should be open");
        _;
    }

    modifier offerOwner(uint256 id) {
        require(offers[id].user == msg.sender, "Marketplace: Caller should own the offer");
        _;
    }

    modifier auctionExists(uint256 id) {
        require(auctions[id].status != Status.Pending, "Marketplace: Auction does not exist");
        _;
    }

    modifier auctionOpen(uint256 id) {
        require(auctions[id].status == Status.Open, "Marketplace: Auction finished or cancelled");
        _;
    }

    modifier isSeller(uint256 id) {
        require(auctions[id].seller == msg.sender, "Marketplace: Caller is not seller");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Marketplace: Contract not allowed");
        require(msg.sender == tx.origin, "Marketplace: Proxy contract not allowed");
        _;
    }

    modifier tokenOwner(address collection, uint256 tokenId) {
        require(IERC721(collection).ownerOf(tokenId) == msg.sender, "Marketplace: Sender should own the token");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
library Counters {
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

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
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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