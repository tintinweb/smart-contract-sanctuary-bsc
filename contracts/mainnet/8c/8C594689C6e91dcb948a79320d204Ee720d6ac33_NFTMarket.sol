// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract NFTMarket is Initializable, OwnableUpgradeable, PausableUpgradeable {
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address offeror;
        address owner;
        uint256 price;
        address currency;
        bool isAuction;
        bool isPublisher;
        uint256 minimumOffer;
        uint256 duration;
        address bidder;
        uint256 lockedBid;
        address invitedBidder;
    }

    struct Plan {
        address owner;
        uint256 price;
        address creator;
        uint256 endDate;
        address currency;
        uint256 timestamp;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    Counters.Counter private _itemsRemoved;

    address public feeAddress;
    event FeeAddressUpdated(address oldAddress, address newAddress);
    uint32 public defaultFee;
    event DefaultFeeUpdated(uint32 oldFee, uint32 newFee);
    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(uint256 => uint256) private tokenIdToItemId;
    mapping(address => Plan[]) private registrations;
    Counters.Counter private _privateItems;
    mapping(uint256 => MarketItem) private idToPrivateMarketItem;
    mapping(uint256 => uint256) private tokenIdToPrivateItemId;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address offeror,
        address owner,
        uint256 price,
        address currency,
        bool isAuction,
        bool isPublisher,
        uint256 minimumOffer,
        uint256 duration
    );
    event MarketItemRemoved(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId
    );
    event MarketItemSold(address owner, address buyer, uint256 tokenId);

    /// @notice A token is offered for sale by owner; or such an offer is revoked
    /// @param  tokenId       which token
    /// @param  offeror       the token owner that is selling
    /// @param  minimumOffer  the amount (in Wei) that is the minimum to accept; or zero to indicate no offer
    /// @param  invitedBidder the exclusive invited buyer for this offer; or the zero address if not exclusive
    event OfferUpdated(
        uint256 indexed tokenId,
        address offeror,
        uint256 minimumOffer,
        address invitedBidder
    );

    /// @notice A new highest bid is committed for a token; or such a bid is revoked
    /// @param  tokenId   which token
    /// @param  bidder    the party that committed Ether to bid
    /// @param  lockedBid the amount (in Wei) that the bidder has committed
    event BidUpdated(
        uint256 indexed tokenId,
        address bidder,
        uint256 lockedBid
    );

    /// @notice A token is traded on the marketplace (this implies any offer for the token is revoked)
    /// @param  tokenId which token
    /// @param  value   the sale price
    /// @param  offeror the party that previously owned the token
    /// @param  bidder  the party that now owns the token
    event Traded(
        uint256 indexed tokenId,
        uint256 value,
        address indexed offeror,
        address indexed bidder
    );

    event Registered(
        address owner,
        uint256 price,
        address creator,
        uint256 endDate,
        address currency
    );

    event Tiped(
        address donator,
        uint256 amount,
        address creator,
        address currency
    );

    function initialize(address _feeAddress, uint32 _defaultFee)
        public
        virtual
        initializer
    {
        __Ownable_init();
        __Pausable_init();

        feeAddress = _feeAddress;
        defaultFee = _defaultFee;
    }

    function getPrivateMarketItem(uint256 tokenId)
        public
        view
        onlyPrivateMarketItem(tokenId)
        returns (MarketItem memory)
    {
        uint256 itemId = tokenIdToPrivateItemId[tokenId];
        return idToPrivateMarketItem[itemId];
    }

    function getMarketItem(uint256 tokenId)
        public
        view
        onlyMarketItem(tokenId)
        returns (MarketItem memory)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        return idToMarketItem[itemId];
    }

    function register(
        uint256 price,
        address creator,
        uint256 endDate,
        address currency
    ) public whenNotPaused {
        require(
            endDate > 0 && endDate > block.timestamp,
            "Registration should have valid end date"
        );
        require(price > 0, "Price should be greater than 0");

        address owner = msg.sender;
        // compute fee amount
        uint256 fee = (price * defaultFee) / 10000;
        //compute owner sale amount
        uint256 amount = price - fee;

        // Transfer the owner amount
        IERC20(currency).transferFrom(owner, creator, amount);
        // Transfer the fee amount
        IERC20(currency).transferFrom(owner, feeAddress, fee);

        registrations[owner].push(
            Plan(owner, price, creator, endDate, currency, 0)
        );
        emit Registered(owner, price, creator, endDate, currency);
    }

    function tip(
        uint256 tipAmount,
        address creator,
        address currency
    ) public whenNotPaused {
        require(tipAmount > 0, "Tip: amount should be greater than 0");

        address donator = msg.sender;
        // compute fee amount
        uint256 fee = (tipAmount * defaultFee) / 10000;
        //compute owner sale amount
        uint256 amount = tipAmount - fee;

        // Transfer the owner amount
        IERC20(currency).transferFrom(donator, creator, amount);
        // Transfer the fee amount
        IERC20(currency).transferFrom(donator, feeAddress, fee);

        emit Tiped(donator, tipAmount, creator, currency);
    }

    function fetchMyRegistrations() public view returns (Plan[] memory) {
        uint256 totalItemCount = registrations[msg.sender].length;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (registrations[msg.sender][i].endDate > block.timestamp) {
                itemCount += 1;
            }
        }

        Plan[] memory items = new Plan[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (registrations[msg.sender][i].endDate > block.timestamp) {
                Plan storage currentItem = registrations[msg.sender][i];
                items[currentIndex] = currentItem;
                items[currentIndex].timestamp = block.timestamp;
                currentIndex += 1;
            }
        }
        return items;
    }

    function createPrivateMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address currency,
        address invitedBidder
    ) external whenNotPaused {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.sender == IERC721(nftContract).ownerOf(tokenId),
            "Only the token owner can offer"
        );

        _privateItems.increment();
        uint256 itemId = _itemIds.current();
        tokenIdToPrivateItemId[tokenId] = itemId;
        idToPrivateMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            currency,
            false,
            false,
            price,
            0,
            address(0),
            0,
            invitedBidder
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            currency,
            false,
            false,
            price,
            0
        );
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address currency,
        bool isAuction,
        bool isPublisher,
        uint256 minimumOffer,
        uint256 duration
    ) external whenNotPaused {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.sender == IERC721(nftContract).ownerOf(tokenId),
            "Only the token owner can offer"
        );
        uint256 itemId = tokenIdToItemId[tokenId];

        if (itemId < 1) {
            _itemIds.increment();
            itemId = _itemIds.current();
            tokenIdToItemId[tokenId] = itemId;
            idToMarketItem[itemId] = MarketItem(
                itemId,
                nftContract,
                tokenId,
                msg.sender,
                address(0),
                price,
                currency,
                isAuction,
                isPublisher,
                minimumOffer,
                duration,
                address(0),
                0,
                address(0)
            );
        } else {
            _itemsRemoved.decrement();
            itemId = tokenIdToItemId[tokenId];
            MarketItem storage marketItem = idToMarketItem[itemId];
            marketItem.nftContract = nftContract;
            marketItem.offeror = msg.sender;
            marketItem.owner = address(0);
            marketItem.price = price;
            marketItem.currency = currency;
            marketItem.isAuction = isAuction;
            marketItem.isPublisher = isPublisher;
            marketItem.minimumOffer = minimumOffer;
            marketItem.duration = duration;
            marketItem.bidder = address(0);
            marketItem.lockedBid = 0;
            marketItem.invitedBidder = address(0);
            idToMarketItem[itemId] = marketItem;
        }

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            currency,
            isAuction,
            isPublisher,
            minimumOffer,
            duration
        );

        if (isAuction) {
            require(
                minimumOffer > 0,
                "createMarketItem: minimum offer must be at least 1 wei"
            );
            emit OfferUpdated(tokenId, msg.sender, minimumOffer, address(0));
        }
    }

    function removeMarketItem(uint256 tokenId, address nftContract)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            idToMarketItem[itemId].offeror == msg.sender,
            "removeMarketItem : you are not the offeror of the NFT"
        );
        require(
            idToMarketItem[itemId].lockedBid <= 0 &&
                idToMarketItem[itemId].bidder == address(0),
            "An auction on this NFT is running and has active bid. Cancel the auction before removing this item from the market"
        );
        idToMarketItem[itemId].owner = msg.sender;
        idToMarketItem[itemId].offeror = address(0);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        _itemsRemoved.increment();
        emit MarketItemRemoved(itemId, nftContract, tokenId);
    }

    function createPrivateMarketSale(uint256 tokenId)
        public
        whenNotPaused
        onlyPrivateMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToPrivateItemId[tokenId];
        uint256 price = idToPrivateMarketItem[itemId].price;
        address offeror = idToPrivateMarketItem[itemId].offeror;
        address currency = idToPrivateMarketItem[itemId].currency;
        address nftContract = idToPrivateMarketItem[itemId].nftContract;
        address buyer = msg.sender;

        // compute fee amount
        uint256 fee = (price * defaultFee) / 10000;
        //compute owner sale amount
        uint256 amount = price - fee;

        // Transfer the owner amount
        IERC20(currency).transferFrom(buyer, offeror, amount);
        // Transfer the fee amount
        IERC20(currency).transferFrom(buyer, feeAddress, fee);

        // transfer the NFT to the buyer
        IERC721(nftContract).transferFrom(address(this), buyer, tokenId);
        idToPrivateMarketItem[itemId].owner = buyer;
        idToPrivateMarketItem[itemId].offeror = address(0);
        idToPrivateMarketItem[itemId].minimumOffer = 0;
        idToPrivateMarketItem[itemId].invitedBidder = address(0);

        emit MarketItemSold(offeror, buyer, tokenId);
    }

    function createMarketSale(uint256 tokenId)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        uint256 price = idToMarketItem[itemId].price;
        address offeror = idToMarketItem[itemId].offeror;
        address currency = idToMarketItem[itemId].currency;
        address nftContract = idToMarketItem[itemId].nftContract;
        address buyer = msg.sender;

        // compute fee amount
        uint256 fee = (price * defaultFee) / 10000;
        //compute owner sale amount
        uint256 amount = price - fee;

        // Transfer the owner amount
        IERC20(currency).transferFrom(buyer, offeror, amount);
        // Transfer the fee amount
        IERC20(currency).transferFrom(buyer, feeAddress, fee);

        // transfer the NFT to the buyer
        IERC721(nftContract).transferFrom(address(this), buyer, tokenId);
        idToMarketItem[itemId].owner = buyer;
        idToMarketItem[itemId].offeror = address(0);
        idToMarketItem[itemId].minimumOffer = 0;
        idToMarketItem[itemId].invitedBidder = address(0);
        _itemsSold.increment();

        emit MarketItemSold(offeror, buyer, tokenId);
    }

    function closeAuction(uint256 tokenId)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp > idToMarketItem[itemId].duration,
            "closeAuction: Auction period is running"
        );
        require(
            msg.sender == idToMarketItem[itemId].offeror,
            "closeAuction: Only offeror can cancel and auction for a token he owns"
        );
        require(
            idToMarketItem[itemId].bidder != address(0),
            "closeAuction: This auction has no bid."
        );
        uint256 highestBid = idToMarketItem[itemId].lockedBid;
        address offeror = idToMarketItem[itemId].offeror;
        address bidder = idToMarketItem[itemId].bidder;

        _doTrade(itemId, highestBid, offeror, bidder);
        _setBid(itemId, address(0), 0);
        _itemsSold.increment();
        emit MarketItemSold(offeror, bidder, tokenId);
    }

    /// @dev Collect fee for owner & offeror and transfer underlying asset. The Traded event emits before the
    ///      ERC721.Transfer event so that somebody observing the events and seeing the latter will recognize the
    ///      context of the former. The bid is NOT cleaned up generally in this function because a circumstance exists
    ///      where an existing bid persists after a trade. See "context 3" above.
    function _doTrade(
        uint256 itemId,
        uint256 value,
        address offeror,
        address bidder
    ) private {
        // Divvy up proceeds
        uint256 feeAmount = (value * defaultFee) / 10000; // reverts on overflow
        uint256 bidderAmount = value - feeAmount;
        IERC20(idToMarketItem[itemId].currency).transfer(feeAddress, feeAmount);
        IERC20(idToMarketItem[itemId].currency).transfer(offeror, bidderAmount);

        emit Traded(idToMarketItem[itemId].tokenId, value, offeror, bidder);
        idToMarketItem[itemId].offeror = address(0);
        idToMarketItem[itemId].minimumOffer = 0;
        idToMarketItem[itemId].invitedBidder = address(0);
        idToMarketItem[itemId].owner = bidder;
        IERC721(idToMarketItem[itemId].nftContract).transferFrom(
            address(this),
            bidder,
            idToMarketItem[itemId].tokenId
        );
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() -
            _itemsSold.current() -
            _itemsRemoved.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyListedNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].offeror == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].offeror == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyPrivateNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = idToPrivateMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToPrivateMarketItem[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyPrivateMarketItems()
        public
        view
        returns (MarketItem[] memory)
    {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].invitedBidder == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPrivateMarketItem[i + 1].invitedBidder == msg.sender) {
                uint256 currentId = idToPrivateMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToPrivateMarketItem[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
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
            if (
                idToMarketItem[i + 1].owner == msg.sender &&
                idToMarketItem[i + 1].invitedBidder == address(0)
            ) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function cancelAuction(uint256 tokenId)
        public
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "cancelAuction: Auction period is over for this NFT"
        );
        require(
            msg.sender == idToMarketItem[itemId].offeror,
            "cancelAuction: Only offeror can cancel and auction for a token he owns"
        );

        address bidder = idToMarketItem[itemId].bidder;
        uint256 lockedBid = idToMarketItem[itemId].lockedBid;
        address currency = idToMarketItem[itemId].currency;

        if (bidder != address(0)) {
            // Refund the current bidder
            IERC20(currency).transfer(bidder, lockedBid);
        }
        _setOffer(itemId, address(0), 0, address(0));
    }

    /// @notice An bidder may revoke their bid
    /// @param  tokenId which token
    function revokeBid(uint256 tokenId)
        external
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "revoke Bid: Auction period is over for this NFT"
        );
        require(
            msg.sender == idToMarketItem[itemId].bidder,
            "revoke Bid: Only the bidder may revoke their bid"
        );
        address currency = idToMarketItem[itemId].currency;
        address existingBidder = idToMarketItem[itemId].bidder;
        uint256 existingLockedBid = idToMarketItem[itemId].lockedBid;
        IERC20(currency).transfer(existingBidder, existingLockedBid);
        _setBid(itemId, address(0), 0);
    }

    /// @notice Anyone may commit more than the existing bid for a token.
    /// @param  tokenId which token
    function bid(uint256 tokenId, uint256 amount)
        external
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        uint256 existingLockedBid = idToMarketItem[itemId].lockedBid;
        uint256 minimumOffer = idToMarketItem[itemId].minimumOffer;
        require(
            idToMarketItem[itemId].isAuction,
            "bid: this NFT is not auctionable"
        );
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "bid: Auction period is over for this NFT"
        );
        require(amount >= minimumOffer, "Bid too low");
        require(amount > existingLockedBid, "Bid lower than the highest bid");
        address existingBidder = idToMarketItem[itemId].bidder;
        address currency = idToMarketItem[itemId].currency;

        IERC20(currency).transferFrom(msg.sender, address(this), amount);
        if (existingBidder != address(0)) {
            IERC20(currency).transfer(existingBidder, existingLockedBid);
        }
        _setBid(itemId, msg.sender, amount);
    }

    /// @notice Anyone may add more value to their existing bid
    /// @param  tokenId which token
    function bidIncrease(uint256 tokenId, uint256 amount)
        external
        whenNotPaused
        onlyMarketItem(tokenId)
    {
        uint256 itemId = tokenIdToItemId[tokenId];
        require(
            block.timestamp <= idToMarketItem[itemId].duration,
            "bid Increase: Auction period is over for this NFT"
        );
        require(amount > 0, "bidIncrease: Must send value to increase bid");
        require(
            msg.sender == idToMarketItem[itemId].bidder,
            "bidIncrease: You are not current bidder"
        );
        uint256 newBidAmount = idToMarketItem[itemId].lockedBid + amount;
        address currency = idToMarketItem[itemId].currency;

        IERC20(currency).transferFrom(msg.sender, address(this), amount);
        idToMarketItem[itemId].lockedBid = newBidAmount;
        _setBid(itemId, msg.sender, newBidAmount);
    }

    /// @notice The owner can set the fee portion
    /// @param  newFeePortion the transaction fee (in basis points) as a portion of the sale price
    function setFeePortion(uint32 newFeePortion) external onlyOwner {
        require(newFeePortion >= 0, "Exceeded maximum fee portion of 10%");
        defaultFee = newFeePortion;
    }

    /// @dev Set and emit new offer
    function _setOffer(
        uint256 itemId,
        address offeror,
        uint256 minimumOffer,
        address invitedBidder
    ) private {
        idToMarketItem[itemId].offeror = offeror;
        idToMarketItem[itemId].minimumOffer = minimumOffer;
        idToMarketItem[itemId].invitedBidder = invitedBidder;
        emit OfferUpdated(
            idToMarketItem[itemId].tokenId,
            offeror,
            minimumOffer,
            invitedBidder
        );
    }

    /// @dev Set and emit new bid
    function _setBid(
        uint256 itemId,
        address bidder,
        uint256 lockedBid
    ) private {
        idToMarketItem[itemId].bidder = bidder;
        idToMarketItem[itemId].lockedBid = lockedBid;
        emit BidUpdated(idToMarketItem[itemId].tokenId, bidder, lockedBid);
    }

    modifier onlyPrivateMarketItem(uint256 tokenId) {
        require(
            tokenIdToPrivateItemId[tokenId] > 0,
            "TokenId not found in the market"
        );
        _;
    }

    modifier onlyMarketItem(uint256 tokenId) {
        require(
            tokenIdToItemId[tokenId] > 0,
            "TokenId not found in the market"
        );
        _;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}