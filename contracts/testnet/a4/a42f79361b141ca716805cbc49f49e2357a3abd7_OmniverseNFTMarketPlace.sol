// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "./PausableUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./IERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";

import "./Initializable.sol";
import "./IERC721Upgradeable.sol";
 
import "./IERC721ReceiverUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";
import "./CountersUpgradeable.sol";
import "./SaleTypeInterface.sol";
import "./IERC2981Upgradeable.sol";
import "./IERC165Upgradeable.sol";
 

/*
* ERROR 
* Fees not set - Fees not set
* Nft contract is zero - Nft contract is zero
* Payment token not allowed - Payment token not allowed
* Invalid item for sale - Invalid item for sale
* Not existing item - Not existing item
* Item already sold - Item already sold
* Already cancelled item - Already cancelled item
* Not allowed to buy an auction item - Not allowed to buy an auction item
* Not the expected buyer for escrow - Not the expected buyer for escrow
* Token amount allowance is not enough to buy - Token amount allowance is not enough to buy
* Price is not enough for royalty - Price is not enough for royalty
* Not enough BNB to buy NFT - Not enough BNB to buy NFT
* Failed to transfer BNB to seller - Failed to transfer BNB to seller
* Failed to transfer BNB fee to receiver - Failed to transfer BNB fee to receiver
* Failed to transfer BNB royalty to artist - Failed to transfer BNB royalty to artist
* Not owner of the item - Not owner of the item
* Not expired escrow - Not expired escrow
* Expired auction - Expired auction
* Not allowed to bid - Not allowed to bid 
* token allowance error - token allowance error
* Invalid auction - Invalid auction
* Not last bidder - Not last bidder
*/
contract OmniverseNFTMarketPlace is Initializable, IERC721ReceiverUpgradeable, PausableUpgradeable, OwnableUpgradeable,   ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    /* Total number of items ever created */
    CountersUpgradeable.Counter private _itemIds; 

    /* Total number of items sold */
    CountersUpgradeable.Counter private _itemsSold; 

    /* Total number of items cancelled */
    CountersUpgradeable.Counter private _itemsCancelled;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    /* name of the market place */
    string public name;

    struct MarketItem {
        /* Market item id */
        uint itemId;
        /* NFT contract of the item */
        address nftContract;
        /* NFT contract of the item */
        uint256 tokenId;
        /* Person selling the nft */
        address payable seller;
        /* Person owns the nft the nft */
        address payable owner;
        /* Token used to pay for the order, or the zero-address as a sentinel value for Ether. */
        address paymentToken;
        /* Base price of the order (in paymentTokens). */
        uint256 basePrice;
        /* Auction extra parameter - minimum bid increment for English auctions, starting/ending price difference. */
        uint256 extra;
        /* Mark an item sold */
        bool sold;
        /* Listing timestamp. */
        uint256 listingTime;
        /* Expiration timestamp - 0 for no expiry. */
        uint256 expirationTime;
        /* feeRate */
        uint256 feeRate;
        /* saleType */
        SaleTypeInterface.SaleType saleType;
        /* fee denominator */
        uint256 denominator;
    }

    /* A way to access values of the MarketItem struct above by passing an integer ID*/
    mapping(uint256 => MarketItem) private idMarketItem;
    mapping(uint256 => bool) private idMarketItemCancelled;

    /* Log message (when Item is created) */
    event MarketItemCreated (
        uint indexed itemId,
        MarketItem item
    );

    /* Log message (when Item is sold) */
    event MarketItemSold (
        uint indexed itemId,
        MarketItem item
    );

    /* Log message (when Item is cancelled) */
    event MarketItemCancelled (
        uint indexed itemId,
        MarketItem item 
    );

    /* 1% of the selling price or final price (FOR OCA$H) */
    uint256 public feeRate; 
    uint256 public feeDenominator;

    /* 2.5% of the selling price or final price (FOR bnb or other token) */
    uint256 public otherTokenCoinFeeRate; 
    uint256 public otherTokenCoinFeeRateDenominator;

    /* payment token allowed */
    mapping(address=>bool) private _paymentTokenAllowed;

    address payable private feeReceiverAddress;

    address private oca$hAddress;

    event BidCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address bidder,
        address paymentToken,
        uint256 basePrice,
        uint256 extra,   
        uint256 feeRate,
        SaleTypeInterface.SaleType saleType,
        uint256 denominator,
        uint256 amountBid
    );

    struct AuctionItemBid {
      /* to identify what item */
      uint256 itemId; 
      /* the last user who bid and the expected user will receive the item after the time of auction ends */
      address currentBidder;
      /* user amount bid */
      uint256 amountBid;

      /* current amount bid satisfies by the amount bid */
      uint256 currentAmount;
      /* next amount need to satisfies by the next bidder */
      uint256 nextAmount;
    }

    mapping(uint256 => AuctionItemBid) private idAuctionItemBid;

    event ClaimedAuctionItem (
        uint indexed itemId,
        MarketItem item,
        AuctionItemBid auctionItem
    );

    bytes4 private  _INTERFACE_ID_ERC2981;

    mapping(address=>bool) excludeForSell;
    
    mapping(address=>address) _whitelisted;

    function initialize(address ocashAddress_, address feeReceiver_, address[] calldata otherPaymentTokensAllowed) public initializer {
        __Pausable_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        name = "Omniverse NFT Market Place";

        feeRate = 5; // 0.5% = 0.005
        feeDenominator = 1000;

        otherTokenCoinFeeRate = 25;  // 2.5% = 0.025 
        otherTokenCoinFeeRateDenominator = 1000;

        oca$hAddress = ocashAddress_; // 0xb340F67E9Cc3927eBeEB04c2e03f74bd0543F4fc;
        feeReceiverAddress  = payable(feeReceiver_); //payable(0xc60C2C76D00ed595d8584cEfEc26db5AC246a1A1);

        _paymentTokenAllowed[address(0)] = true;
        _paymentTokenAllowed[oca$hAddress] = true;
        
        for(uint256 i = 0;i < otherPaymentTokensAllowed.length;i++){
            _paymentTokenAllowed[otherPaymentTokensAllowed[i]] = true;
        }

        _INTERFACE_ID_ERC2981 = 0x2a55205a;
    }

    // check if the nft contract supports royalties
    function checkRoyalties(address _contract) internal view returns (bool) {
        (bool success) = IERC165Upgradeable(_contract).supportsInterface(_INTERFACE_ID_ERC2981);
        return success;
    }

    function ocashAddress() external view returns (address) {
        return oca$hAddress;
    }

    function feeAddress() external view returns (address) {
        return feeReceiverAddress;
    }

    function setFeeAddress(address feeReceiver) external onlyOwner {
        feeReceiverAddress = payable(feeReceiver);
    }

    function setPaymentTokenAllowed(address _paymentToken, bool isAllowed) external onlyOwner {
        _paymentTokenAllowed[_paymentToken] = isAllowed;
    }
    function isPaymentTokenAllowed(address _paymentToken) external view returns (bool) {
        return _paymentTokenAllowed[_paymentToken];
    }

     /**
     * @dev Change the fee percentage for ocash (owner only)
     * @param newFee New fee
     */
     function changeFee(uint newFee, uint256 feeDenominator_)
     public
     onlyOwner
    {
        feeRate = newFee;
        feeDenominator = feeDenominator_;
    }

     /**
     * @dev Change the fee percentage for bnb or other token (owner only)
     * @param newOtherTokenCoinFee New fee to set in basis points
     */
     function changeOtherTokenCoinFee(uint newOtherTokenCoinFee, uint256 otherTokenCoinFeeRateDenominator_)
     public
     onlyOwner
    {
        otherTokenCoinFeeRate = newOtherTokenCoinFee;
        otherTokenCoinFeeRateDenominator = otherTokenCoinFeeRateDenominator_;
    }
    function validateItemForSale(
        address nftContract, // address of nft contract
        address paymentToken, //token to be used as payment (0 means using BNB)
        uint256 price, // price in token or BNB
        uint256 duration, // in seconds
        uint256 extra_, // extra price that will be add for auction
        SaleTypeInterface.SaleType saleType_, // 0 - fixed price, 1 - auction, 2 - escrow
        address newOwner // for the case of escrow
    ) private {
        require(duration>=0,"Invalid duration");
        uint256 expirationTime_;
        if(duration > 0){
            expirationTime_ = block.timestamp + duration;
        }
        require(feeRate > 0 && otherTokenCoinFeeRate>0,"Fees not set");
        require(nftContract != address(0), "Nft contract is zero");        
        require(price > 0, "Price must be above zero");
        require(_paymentTokenAllowed[paymentToken] == true,"Payment token not allowed");
        bool validItemForSale = SaleTypeInterface.validateParameters(saleType_, expirationTime_, newOwner, extra_);
        require(validItemForSale,"Invalid item for sale");
    }
    function createItemForSale(
            address nftContract, // address of nft contract
            uint256 tokenId, // token id for this nft contract
            address paymentToken, //token to be used as payment (0 means using BNB)
            uint256 price, // price in token or BNB
            uint256 duration, // in seconds
            uint256 extra_, // extra price that will be add for auction
            SaleTypeInterface.SaleType saleType_, // 0 - fixed price, 1 - auction, 2 - escrow
            address newOwner // for the case of escrow
        ) public payable nonReentrant whenNotPaused {

        // nft contract exclude for sell should be false OR the sender is whitelisted to operate the contract
        require(excludeForSell[nftContract]==false || _whitelisted[nftContract] == _msgSender(), "Not allowed to sell");
       
        validateItemForSale(nftContract, paymentToken, price, duration, extra_, saleType_, newOwner);
        
        /* transfer ownership of the nft to the contract itself */
        IERC721Upgradeable(nftContract).safeTransferFrom(_msgSender(), address(this), tokenId);

        _createItemForSale( _msgSender(), nftContract, tokenId, paymentToken, price, duration, extra_, saleType_, newOwner);
    }
    function createItemForSaleFromUser(
            address user,
            address nftContract, // address of nft contract
            uint256 tokenId, // token id for this nft contract
            address paymentToken, //token to be used as payment (0 means using BNB)
            uint256 price, // price in token or BNB
            uint256 duration, // in seconds
            uint256 extra_, // extra price that will be add for auction
            SaleTypeInterface.SaleType saleType_, // 0 - fixed price, 1 - auction, 2 - escrow
            address newOwner // for the case of escrow
        ) public payable nonReentrant whenNotPaused {

        address contractAddress = _msgSender();
        require(_whitelisted[nftContract] == contractAddress, "Not allowed to sell");
       
        validateItemForSale(nftContract, paymentToken, price, duration, extra_, saleType_, newOwner);

        /* transfer ownership of the nft to the contract itself */
        IERC721Upgradeable(nftContract).safeTransferFrom(contractAddress, address(this), tokenId);

        _createItemForSale(user, nftContract, tokenId, paymentToken, price, duration, extra_, saleType_, newOwner);
    }

    function _createItemForSale(
        address user,
        address nftContract, // address of nft contract
        uint256 tokenId, // token id for this nft contract
        address paymentToken, //token to be used as payment (0 means using BNB)
        uint256 price, // price in token or BNB
        uint256 duration, // in seconds
        uint256 extra_, // extra price that will be add for auction
        SaleTypeInterface.SaleType saleType_, // 0 - fixed price, 1 - auction, 2 - escrow
        address newOwner // for the case of escrow
    ) 
    private {
        /* add 1 to the total number of items ever created */
        _itemIds.increment(); 
        
        uint256 itemId = _itemIds.current();

        uint256 _listingTime = block.timestamp;
        
        /* get the actual fee will be used based on payment token */
        uint256 _actualFee = paymentToken == oca$hAddress ? feeRate : otherTokenCoinFeeRate;
        uint256 _actualFeeDenominator = paymentToken == oca$hAddress ? feeDenominator : otherTokenCoinFeeRateDenominator;

        address payable expectedOwner =  payable(address(0)); //no owner yet (set owner to empty address)        

        // if escrow the expected new owner should be set (already validated that has to be expected owner)
        if(saleType_ == SaleTypeInterface.SaleType.Escrow){
            expectedOwner = payable(newOwner);
        }

        // uint256 expirationTime_;
        // if(duration > 0){
        //     expirationTime_ = _listingTime + duration;
        // }

        idMarketItem[itemId] = MarketItem(
            itemId, nftContract, tokenId, payable(user), expectedOwner, 
            paymentToken,
            price,
            extra_,
            false,
            _listingTime,
            duration > 0 ? _listingTime + duration : 0 ,
            _actualFee,
            saleType_,
            _actualFeeDenominator
        );
         
        /* log this transaction */
        logCreationOfSale(itemId);
    }

    function logCreationOfSale(uint256 itemId) private {
        MarketItem storage item =  idMarketItem[itemId];
        emit MarketItemCreated(
            item.itemId,
            item
        );
    }
 
    function buyItem(
        uint256 itemId
        ) public payable nonReentrant whenNotPaused  {
        require(idMarketItem[itemId].itemId > 0,"Not existing item");
        require(idMarketItem[itemId].sold == false,"Item already sold");
        require(idMarketItemCancelled[itemId] == false,"Already cancelled item");
        // allow to buy escrow or fixed price 
        require(idMarketItem[itemId].saleType == SaleTypeInterface.SaleType.Escrow || 
        idMarketItem[itemId].saleType == SaleTypeInterface.SaleType.FixedPrice
        ,"Not allowed to buy an auction item");
      
        uint256 tokenId = idMarketItem[itemId].tokenId;
        address nftContract = idMarketItem[itemId].nftContract;
        address buyer = _msgSender();

        // if escrow validate that the buyer is the address specified 
        if(SaleTypeInterface.SaleType.Escrow == idMarketItem[itemId].saleType){
           require(buyer == idMarketItem[itemId].owner,"Not the expected buyer for escrow");
        }

        // set the flag before that this item has been sold and owner
        // before sending of payments
        idMarketItem[itemId].owner = payable(buyer); //mark buyer as new owner
        idMarketItem[itemId].sold = true; //mark that it has been sold

        handlePayment(itemId, false);
        
        // //transfer ownership of the nft from the contract itself to the buyer
        IERC721Upgradeable(nftContract).safeTransferFrom(address(this), buyer,  tokenId);
        
        
        _itemsSold.increment(); //increment the total number of Items sold by 1
      
        /* log this transaction */
        logBuy(itemId);
    }

    /**
    * itemId - market item id
    * isClaim - flag if payment amount from contract for the case of the auction
     */
    function handlePayment(uint256 itemId, bool isClaim) private {
        address buyer = _msgSender();
        address seller = idMarketItem[itemId].seller;
        // Fixed Price and Escrow is based on basePrice
        uint256 price = idMarketItem[itemId].basePrice;

        // if is claim and the sale type is auction, override the price since the price is base on the current bid amount
        if(isClaim && idMarketItem[itemId].saleType == SaleTypeInterface.SaleType.Auction){
            
            price = getActualPrice(itemId);
        }
        address paymentToken = idMarketItem[itemId].paymentToken;
        uint256 tokenId = idMarketItem[itemId].tokenId;
        address nftContract = idMarketItem[itemId].nftContract;

        ( uint256 actualPrice, uint256 fee  ) = calculatePriceAndFee(itemId);
        
        /* the message value should be zero when there are preferred payment token */
        if (paymentToken != address(0)) {

            // AUCTION - if NOT claim then validate the amount
            if(!isClaim){
                require(msg.value == 0,"Not allowed send BNB");

                // check if the approve amount is enough
                require(IERC20Upgradeable(paymentToken).allowance(buyer , address(this))>=price,"Token amount allowance is not enough to buy");
            }
        }

        // check for royalty supported
        bool isRoyaltySupported = checkRoyalties(nftContract);
        address artist = address(0);
        uint256 royaltyAmount = 0;
        if(isRoyaltySupported){

            (artist, royaltyAmount) = IERC2981Upgradeable(nftContract).royaltyInfo(tokenId, price);
            require(actualPrice>royaltyAmount,"Price is not enough for royalty");
            
            if(royaltyAmount > 0){
                actualPrice = actualPrice.sub(royaltyAmount);
            }
        }

        // if using payment is a token
        if (paymentToken != address(0)) {

            address from = buyer;

            // AUCTION - if claim then payment will come from contract since the last bidder already paid the amount
            if(isClaim){
                from = address(this);
                uint256 contractBalance = IERC20Upgradeable(paymentToken).balanceOf(from);
                require(contractBalance>=price,"Contract has not enough TOKEN balance");

                /* transfer the actual price in token to the seller */
                transferTokensFromContract(paymentToken, seller, actualPrice);
                /* transfer the fee tokens to the fee receiver */
                transferTokensFromContract(paymentToken, feeReceiverAddress, fee);
                /* transfer the royalty tokens to the artists */
                if(royaltyAmount>0){
                    transferTokensFromContract(paymentToken, artist, royaltyAmount);
                }
            } else {
                /* transfer the actual price in token to the seller */
                transferTokens(paymentToken, from , seller, actualPrice);
                /* transfer the fee tokens to the fee receiver */
                transferTokens(paymentToken, from , feeReceiverAddress, fee);
                /* transfer the royalty tokens to the artists */
                if(royaltyAmount > 0){
                    transferTokens(paymentToken, from , artist, royaltyAmount);
                }
            }
            
        }

        /* Amount that will be received by seller less fee (for BNB). */
        uint receiveAmount = actualPrice;

        /* Amount that must be sent by buyer (for BNB). */
        uint requiredAmount = price;

        // if using payment is a BNB
        if (paymentToken == address(0)) {
            
            // required checking if NOT claim
            if(!isClaim){
                require(msg.value >= requiredAmount,"Not enough BNB to buy NFT");
            } else {
                // AUCTION - claim
                uint256 contractBalance = address(this).balance;
                require(contractBalance>=requiredAmount,"Contract has not enough BNB balance");
            }
            
            /* transfer the amount less fee to the seller  */
            (bool success, ) =  seller.call{value: receiveAmount}("");
            require(success, "Failed to transfer BNB to seller");

            /* transfer the fee to the fee receiver */
            (bool successFee, ) = feeReceiverAddress.call{value: fee}("");
            require(successFee, "Failed to transfer BNB fee to receiver");

            /* transfer the royalty to the artists */
            if(royaltyAmount > 0){
                (bool successRoyalty, ) = artist.call{value: royaltyAmount}("");
                require(successRoyalty, "Failed to transfer BNB royalty to artist");
            }
        }
    }

     

    function logBuy(uint256 itemId) private {
        MarketItem storage currentItem = idMarketItem[itemId];
        emit MarketItemSold(
            currentItem.itemId,
            currentItem
        );
    }
    function cancelItem(
        uint256 itemId
        ) public payable nonReentrant whenNotPaused {
        MarketItem storage currentItem = idMarketItem[itemId];

        require(currentItem.itemId > 0,"Not existing item");
        require(currentItem.sold == false,"Item already sold");
        require(currentItem.seller == _msgSender(),"Not owner of the item");
        require(idMarketItemCancelled[itemId] == false,"Already cancelled item");

        // if escrow validate that the expiration time already passed
        if(currentItem.saleType == SaleTypeInterface.SaleType.Escrow){
          require(block.timestamp >= currentItem.expirationTime,"Not expired escrow");
        }

        // if auction , allow to cancel auction if already expired and no user bid
        if(currentItem.saleType == SaleTypeInterface.SaleType.Auction){

            require(block.timestamp >= currentItem.expirationTime,"Not expired auction");

            require(idAuctionItemBid[itemId].itemId == 0,"Not allowed to cancel auction has already bid");               
        }

        idMarketItemCancelled[itemId] = true;
        
        uint256 tokenId = currentItem.tokenId;
        address nftContract = currentItem.nftContract;

        /* return to the seller the nft */
        IERC721Upgradeable(nftContract).safeTransferFrom(address(this), _msgSender(), tokenId);

        /* increment the total number of items cancelled */
        _itemsCancelled.increment();

        logCancel(itemId);
    }

    function logCancel(uint256 itemId) private {
        MarketItem storage currentItem = idMarketItem[itemId];
        /* emit an event that the item was cancelled */
        emit MarketItemCancelled(
            currentItem.itemId,
            currentItem
        );
    }

    function bid(uint256 itemId) public payable nonReentrant whenNotPaused {
        require(idMarketItem[itemId].itemId > 0,"Not existing item");
        require(idMarketItem[itemId].sold == false,"Item already sold");
        require(idMarketItemCancelled[itemId] == false,"Already cancelled item");
        require(block.timestamp < idMarketItem[itemId].expirationTime,"Expired auction");
        
        // allow only to bid for sale type auction
        require(idMarketItem[itemId].saleType == SaleTypeInterface.SaleType.Auction,"Not allowed to bid");
        
        address bidder = _msgSender();
        // bid price required
        uint256 price_ = getBidPrice(itemId); 

        validateBidPayment(idMarketItem[itemId].paymentToken, msg.value, price_, bidder, address(this));

        bool newBid = false;
        uint256 oldAmount;
        address oldBidder;
        AuctionItemBid memory currentBid = idAuctionItemBid[itemId];
        if(currentBid.itemId == 0){
            currentBid.itemId = itemId;
            newBid = true;
        } else {
            oldAmount = currentBid.currentAmount;
            oldBidder = currentBid.currentBidder;
        }
        currentBid.currentBidder = bidder;
        currentBid.amountBid = price_;
        currentBid.currentAmount = price_;
        currentBid.nextAmount = price_.add(idMarketItem[itemId].extra);
        idAuctionItemBid[itemId] = currentBid;

        // transfer bid amount when using a payment token
        if(idMarketItem[itemId].paymentToken != address(0)){
            transferBidAmount(bidder, address(this), itemId, price_);
        }

        // transfer the old amount to the old user
        if(!newBid){
           transferBidAmount(address(this),  oldBidder, itemId, oldAmount);
        } 

        logBid(itemId, price_, bidder);
    }

    function getCurrentAuctionItem(uint256 itemId) external view returns (AuctionItemBid memory) {
        return idAuctionItemBid[itemId];
    }

    function validateBidPayment(address paymentToken, uint256 amount, uint256 price, address bidder, address contractAddr) internal view {
        //  /* payment is using BNB the value should be greater than or equal to price */
        // if (idMarketItem[itemId].paymentToken == address(0)) {
        //     require(msg.value >= price_);
        // /* payment is using TOKEN the value should be zero */
        // } else {
        //     require(msg.value == 0);
        //     // check if the approve amount is enough
        //     require(IERC20Upgradeable(idMarketItem[itemId].paymentToken).allowance(bidder , address(this))>=price_,"token allowance error");
        // }
        /* payment is using BNB the value should be greater than or equal to price */
        if (paymentToken == address(0)) {
            require(amount >= price,"bnb amount is not enough");
        /* payment is using TOKEN the value should be zero */
        } else {
            require(amount == 0,"bnb amount should be zero if payment is using token");
            // check if the approve amount is enough
            require(IERC20Upgradeable(paymentToken).allowance(bidder ,contractAddr )>=price,"token allowance error");
        }
    }
    function logBid(uint256 itemId, uint256 price_, address bidder) private {
        MarketItem storage currentItem = idMarketItem[itemId];
        
        emit BidCreated(
            itemId, 
            currentItem.nftContract, 
            currentItem.tokenId, 
            currentItem.seller, 
            bidder, 
            currentItem.paymentToken, 
            currentItem.basePrice, 
            currentItem.extra, 
            currentItem.feeRate, 
            currentItem.saleType, 
            currentItem.denominator, 
            price_
        );
    }

    function claimAuctionItem(uint256 itemId) public payable nonReentrant whenNotPaused {
        require(idMarketItem[itemId].itemId > 0,"Not existing item");
        require(idMarketItem[itemId].sold == false,"Item already sold");
        require(idMarketItemCancelled[itemId] == false,"Already cancelled item");
        // allow to claim if sale type is auction
        require(idMarketItem[itemId].saleType == SaleTypeInterface.SaleType.Auction,"Not allowed to claim not auction item");

        require(block.timestamp>=idMarketItem[itemId].expirationTime,"Invalid auction");
        address claimer = _msgSender();

        // to prevent claiming of zero address 
        require(idAuctionItemBid[itemId].currentBidder != address(0),"Invalid zero address bidder");
        
        require(msg.value == 0,"Not allowed send bnb");

        require(claimer == idAuctionItemBid[itemId].currentBidder,"Not last bidder");
        
        idMarketItem[itemId].owner = payable(idAuctionItemBid[itemId].currentBidder); //mark buyer as new owner
        idMarketItem[itemId].sold = true; //mark has sold

        // payment should from this contract since the user already bid and paid the amount
        handlePayment(itemId, true);

        uint256 tokenId = idMarketItem[itemId].tokenId;
        address nftContract = idMarketItem[itemId].nftContract;
        // //transfer ownership of the nft from the contract itself to the buyer
        IERC721Upgradeable(nftContract).safeTransferFrom(address(this), claimer,  tokenId);
        
        _itemsSold.increment(); //increment the total number of Items sold by 1
      
        /* log this transaction */
        AuctionItemBid storage auctionItem = idAuctionItemBid[itemId];
        MarketItem storage currentItem = idMarketItem[itemId];
        emit ClaimedAuctionItem(
            currentItem.itemId,
            currentItem,
            auctionItem
        );
    }

    function transferBidAmount(address from , address to, uint256 itemId, uint256 price_) private {
         if(idMarketItem[itemId].paymentToken == address(0)){
            (bool success, ) =  to.call{value: price_}("");
            require(success, "Failed to transfer bid BNB to `to`");
        }
        else {

            if(from == address(this)){
                transferTokensFromContract(idMarketItem[itemId].paymentToken, to, price_);
            } else {
                transferTokens(idMarketItem[itemId].paymentToken, from, to, price_);
            }
        }
    }
   
    function getBidPrice(uint256 itemId) private view returns (uint256) {
        AuctionItemBid memory currentBid = idAuctionItemBid[itemId];
        if(currentBid.itemId==0){
            return idMarketItem[itemId].basePrice;
        } else {
            return currentBid.nextAmount;
        }
    }

    function getActualPrice(uint256 itemId) private view returns (uint256) {
        if(idMarketItem[itemId].saleType == SaleTypeInterface.SaleType.Auction){
            return idAuctionItemBid[itemId].currentAmount;
        }
        return idMarketItem[itemId].basePrice;
    }

    function getFee(uint256 price_, uint256 itemId) private view returns (uint256) {
        uint256 feeRate_ = idMarketItem[itemId].feeRate;
        uint256 fee_ = price_.mul(feeRate_).div(idMarketItem[itemId].denominator);
        return fee_;
    }

    function calculatePriceAndFee(uint256 itemId) private view returns (uint256, uint256) {
        uint256 price_ = getActualPrice(itemId);
        uint256 fee_ = getFee(price_, itemId);

        // subtract the fee from the price
        uint256 resultPrice_ = price_.sub(fee_);
        return (resultPrice_, fee_);
    }

    function getExpectedFee(uint256 itemId) external view returns (uint256) {
        uint256 price_ = getActualPrice(itemId);
        return getFee(price_, itemId);
    }

    /**
     * @dev Transfer tokens
     * @param token Token to transfer
     * @param from Address to charge fees
     * @param to Address to receive fees
     * @param amount Amount of protocol tokens to charge
     */
     function transferTokens(address token, address from, address to, uint amount) private {
        if (amount > 0) {
            IERC20Upgradeable(token).safeTransferFrom(from, to, amount);
        }
    }
    function transferTokensFromContract(address token,  address to, uint256 amount) private {
        if (amount > 0) {
            IERC20Upgradeable(token).safeTransfer(to, amount);
        }
    }

    function fetchMarketItems(uint256 start , uint256 count) public view returns (MarketItem[] memory){
        // 0 - based 
        require(start>=0,"Invalid start");
        // 1 - based
        require(count>=1,"Invalid count");
        uint itemCount = _itemIds.current(); //total number of items ever created

        require(start + ( count - 1 ) < itemCount,"Invalid start and count");

        //total number of items that are unsold = total items ever created - total items ever sold
        //uint unsoldItemCount = _itemIds.current() - _itemsSold.current() - _itemsCancelled.current();
        uint unsoldItemCount = count;
        uint currentIndex = 0;

        MarketItem[] memory items =  new MarketItem[](unsoldItemCount);

        //loop through all items ever created
        //for(uint i = start; i < itemCount; i++){
        uint256 i = start;
        do{
            
            // retrieve all items
            // - retrieve all items not cancelled
            // - retrieve all items not sold            
            if(
                idMarketItemCancelled[i+1]==false
                && idMarketItem[i+1].sold == false){

                if(currentIndex+1>count){
                    break;
                }
                //yes, this item has never been sold
                uint currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;

                if(items[currentIndex].saleType == SaleTypeInterface.SaleType.Auction){
                    items[currentIndex].basePrice = getBidPrice(items[currentIndex].itemId);
                }
                currentIndex += 1;
            }
            i++;
        }while(i<itemCount);
        //}
        return items; //return array of all unsold items
    }

    function totalUnsoldItems() public view returns (uint256) {
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current() - _itemsCancelled.current();
        return unsoldItemCount;
    }

    
    function fetchMyNFTs() public view returns (MarketItem[] memory){
        //get total number of items ever created
        uint totalItemCount = _itemIds.current();
        address userAddress = _msgSender();
        uint itemCount = 0;
        uint currentIndex = 0;


        for(uint i = 0; i < totalItemCount; i++){
            //get only the items that this user has bought/is the owner
            if(idMarketItem[i+1].owner == userAddress && idMarketItemCancelled[i+1]==false){
                itemCount += 1; //total length
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for(uint i = 0; i < totalItemCount; i++){
           if(idMarketItem[i+1].owner == userAddress && idMarketItemCancelled[i+1]==false){
               uint currentId = idMarketItem[i+1].itemId;
               MarketItem storage currentItem = idMarketItem[currentId];
               items[currentIndex] = currentItem;
               currentIndex += 1;
           }
        }
        return items;
    }

    function getItemInfo(uint256 itemId) external view returns (MarketItem memory) {
        return idMarketItem[itemId];
    }

    /// @notice fetch list of NFTS owned/bought by this user
    function fetchItemsCreated() public view returns (MarketItem[] memory){
        //get total number of items ever created
        uint totalItemCount = _itemIds.current();
        address userAddress = _msgSender();

        uint itemCount = 0;
        uint currentIndex = 0;


        for(uint i = 0; i < totalItemCount; i++){
            //get only the items that this user has bought/is the owner
            if(idMarketItem[i+1].seller == userAddress && idMarketItemCancelled[i+1]==false && idMarketItem[i+1].sold == false){
                itemCount += 1; //total length
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for(uint i = 0; i < totalItemCount; i++){
           if(idMarketItem[i+1].seller == userAddress && idMarketItemCancelled[i+1]==false && idMarketItem[i+1].sold == false){
               uint currentId = idMarketItem[i+1].itemId;
               MarketItem storage currentItem = idMarketItem[currentId];
               items[currentIndex] = currentItem;
               currentIndex += 1;
           }
        }
        return items;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view returns (bytes4){
        require(operator!=address(0),"Operator is address 0");
        require(tokenId>=0,"Invalid token id");
        require(data.length>=0,"Invalid data");
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function setExcludeForSell(address nftContract, bool val) external onlyOwner {
        excludeForSell[nftContract] = val;
    }
    function isExcludeForSell(address nftContract) external view returns (bool){
        return excludeForSell[nftContract];
    }
    function whitelist(address nftContract, address whitelisted) external onlyOwner {
        require(_whitelisted[nftContract]==address(0),"already whitelisted");
        _whitelisted[nftContract] = whitelisted;
    }
    function getWhitelisted(address nftContract) external view returns (address) {
        return _whitelisted[nftContract];
    }
}