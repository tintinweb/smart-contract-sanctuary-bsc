// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "./IERC20.sol";
import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC1155.sol";
import "./IERC721Receiver.sol";
import "./IERC1155Receiver.sol";
import "./Mutex.sol";
import "./Ownable.sol";
import "./MarketBase.sol";
import "./IService.sol";

contract Planet is IMarketBase, IERC721Receiver, IERC1155Receiver, Ownable, Mutex {
    
    // ----- CONSTANTS ----- //
    bytes constant MARKET_DATA = bytes("Planet");
    uint256 constant _denominator = 10000;
    bytes4 constant INTERFACE_ERC721 = 0x80ac58cd;
    bytes4 constant INTERFACE_ERC1155 = 0xd9b67a26;


    // ----- STATES AND STORAGE ----- //
    mapping(address => bool) _managers;
    mapping(address => bool) _payments;
    address public serviceAddress;

    OrderInfo[] _orders;
    OfferInfo[] _offers;


    // ----- MODIFIERS ----- //
    modifier onlyManager() {
        require(_managers[_msgSender()], "Planet: caller is not the manager");
        _;
    }

    modifier onlySupportedPayment(address token) {
        require(_payments[token], "Planet: unsupported payment");
        _;
    }


    // ----- CONSTRUCTOR ----- //
    constructor(address addr) {
        serviceAddress = addr;
    }


    // ----- ERC721/ERC1155 TOKEN RECEIVER FUNCTIONS ----- //

    /**
     * @dev ERC721TokenReceiver method
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev ERC1155TokenReceiver method
     */
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * @dev ERC1155TokenBatchReceiver method
     */
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }


    // ----- MUTATION FUNCTIONS FOR MARKET TRADE ----- //

    /**
     * @notice Create a new order for sale at a fixed price.
     * @param collection The contract address of collection.
     * @param tokenId The token placed on sale.
     * @param quantity The quantity of tokens placed on sale.
     * @param paymentToken The address of the token accepted as payment for the order.
     * @param price The fixed price asked for the sale order.
     */
    function createOrderForSale(address collection, uint256 tokenId, uint256 quantity, address paymentToken, uint256 price) external override onlySupportedPayment(paymentToken) {
        require(price > 0, "Planet: price cannot be zero");

        _lockToken(TokenInfo(collection, tokenId, quantity), _msgSender());
        uint256 orderId = _createOrder(1, TokenInfo(collection, tokenId, quantity), PaymentInfo(paymentToken, price), 0);

        emit OrderForSale(_msgSender(), orderId, collection, tokenId, quantity, paymentToken, price);
    }

    /**
     * @notice Create a new order for auction.
     * @param collection The contract address of collection.
     * @param tokenId The token placed on auction.
     * @param quantity The quantity of tokens placed on auction.
     * @param paymentToken The address of the token accepted as payment for the auction.
     * @param minPrice The minimum starting price for bidding on the auction.
     * @param endTime The time for ending the auction.
     */
    function createOrderForAuction(address collection, uint256 tokenId, uint256 quantity, address paymentToken, uint256 minPrice, uint256 endTime) external override onlySupportedPayment(paymentToken) {
        require(minPrice > 0, "Planet: price cannot be zero");
        require(endTime > block.timestamp, "Planet: invalid timestamp for auction end");

        _lockToken(TokenInfo(collection, tokenId, quantity), _msgSender());
        uint256 orderId = _createOrder(2, TokenInfo(collection, tokenId, quantity), PaymentInfo(paymentToken, minPrice), endTime);

        emit OrderForAuction(_msgSender(), orderId, collection, tokenId, quantity, paymentToken, minPrice, endTime);
    }

    /**
     * @notice Buy a sale order with fixed price.
     * @dev The value of the transaction must equal to the fixed price asked for the order.
     * @param orderId The id of the fixed price sale order.
     */
    function buyForOrder(uint256 orderId) external payable override nonReentrant {
        OrderInfo memory order = _orders[orderId];
        require(order.orderType == 1 && order.orderState == 1, "Planet: invalid order for buy");
        require(order.seller != _msgSender(), "Planet: caller should not be the seller");

        _executePayment(order.payment);
        _splitPayment(order.token, order.payment, order.seller);
        _unlockToken(order.token, _msgSender());

        _orders[orderId].orderState = 2;
        _orders[orderId].buyer = _msgSender();
        _orders[orderId].updateTime = block.timestamp;

        emit OrderFilled(order.seller, _msgSender(), orderId, order.payment.paymentToken, order.payment.price);
    }

    /**
     * @notice Bid on an auction order.
     * @dev The value of the transaction must be greater than or equal to the minimum starting price of the order.
     * @dev If the order has past bid(s), the value of the transaction must be greater than the last bid.
     * @param orderId The id of the auction order.
     * @param value The price value of the bid.
     */
    function bidForOrder(uint256 orderId, uint256 value) external payable override nonReentrant {
        OrderInfo memory order = _orders[orderId];
        require(order.orderType == 2 && order.orderState == 1, "Planet: invalid order for bid");
        require(order.endTime > block.timestamp, "Planet: auction has expired for bid");
        require(value >= order.payment.price && value > order.lastBid * 103 / 100, "Planet: invalid value for bid");

        _executePayment(PaymentInfo(order.payment.paymentToken, value));
        if(order.bids > 0)
            _refundPayment(PaymentInfo(order.payment.paymentToken, order.lastBid), order.lastBidder);

        _orders[orderId].lastBidder = _msgSender();
        _orders[orderId].lastBid = value;
        _orders[orderId].bids += 1;
        _orders[orderId].updateTime = block.timestamp;

        emit OrderBid(orderId, _msgSender(), value);
    }

    /**
     * @notice Cancel an order.
     * @dev Only an open sale order or an auction order with no bid yet can be canceled.
     * @dev Only an order's seller can cancel the order.
     * @param orderId The id of the order to be canceled.
     */
    function cancelOrder(uint256 orderId) external override {
        OrderInfo memory order = _orders[orderId];
        require(order.orderState == 1, "Planet: invalid order for cancel");
        require(order.seller == _msgSender(), "Planet: caller is not the seller");
        require(order.bids == 0, "Planet: bid is in progress");

        _cancelOrder(orderId);

        emit OrderCanceled(orderId);
    }

    /**
     * @notice Take down an order due to inappropriate content.
     * @dev Only an open order can be taken down.
     * @dev Only a contract manager can take down orders.
     * @param orderId The id of the order to be taken down.
     */
    function takeDownOrder(uint256 orderId) external override onlyManager {
        require(_orders[orderId].orderState == 1, "Planet: invalid order for down");

        _orders[orderId].orderState = 4;
        _orders[orderId].updateTime = block.timestamp;

        emit OrderTakenDown(orderId, _msgSender());
    }

    /**
     * @notice Settle an auction.
     * @dev Only an auction order past its end time can be settled.
     * @dev Seller or Buyer can settle an auction.
     * @param orderId The id of the order to be settled.
     */
    function settleOrderForAuction(uint256 orderId) external override nonReentrant {
        OrderInfo memory order = _orders[orderId];
        require(order.orderType == 2 && order.orderState == 1, "Planet: invalid order for settle");
        require(order.endTime < block.timestamp, "Planet: bid has not expired");
        require(order.seller == _msgSender() || order.lastBidder == _msgSender(), "Planet: caller is not the seller nor winner");

        if(order.bids == 0) {
            _cancelOrder(orderId);

            emit OrderCanceled(orderId);
        } else {
            _unlockToken(order.token, order.lastBidder);
            _splitPayment(order.token, PaymentInfo(order.payment.paymentToken, order.lastBid), order.seller);

            _orders[orderId].orderState = 2;
            _orders[orderId].buyer = order.lastBidder;
            _orders[orderId].updateTime = block.timestamp;

            emit OrderFilled(order.seller, order.lastBidder, orderId, order.payment.paymentToken, order.lastBid);
        }
    }

    /**
     * @notice Change the price of an order.
     * @dev Only an open sale order or an auction order with no bid yet can have its price changed.
     * @dev For sale orders, the fixed price asked for the order is changed.
     * @dev for auction orders, the minimum starting price for the bids is changed.
     * @dev Only an order's seller can change its price.
     * @param orderId The id of the order with its price to be changed.
     * @param price The new price of the order.
     */
    function changeOrderPrice(uint256 orderId, uint256 price) external override {
        OrderInfo memory order = _orders[orderId];
        require(order.orderState == 1, "Planet: invalid order for price change");
        require(order.seller == _msgSender(), "Planet: caller is not the seller");
        require(order.bids == 0 && order.endTime > block.timestamp, "Planet: bid is in progress or expired");

        uint256 oldPrice = order.payment.price;
        _orders[orderId].payment.price = price;
        _orders[orderId].updateTime = block.timestamp;

        emit OrderPriceChanged(_msgSender(), orderId, oldPrice, price);
    }

    /**
     * @notice Create a new offer.
     * @param collection The address of the collection.
     * @param tokenId the token placed on offer.
     * @param quantity The quantity of tokens placed on offer.
     * @param paymentToken The address of the token accepted as payment for the offer.
     * @param price The fixed price asked for the offer.
     */
    function makeOffer(address collection, uint256 tokenId, uint256 quantity, address paymentToken, uint256 price) external payable override onlySupportedPayment(paymentToken) {
        if(IERC165(collection).supportsInterface(INTERFACE_ERC721)) {
            require(quantity == 1, "Planet: invalid quantity for ERC721");
        } else if(IERC165(collection).supportsInterface(INTERFACE_ERC1155)) {
            require(quantity > 0, "Planet: quantity cannot be zero");
        } else {
            revert("invalid address for ERC721/ERC1155 collection");
        }

        _executePayment(PaymentInfo(paymentToken, price));
        uint256 offerId = _createOffer(TokenInfo(collection, tokenId, quantity), PaymentInfo(paymentToken, price));

        emit OfferCreated(_msgSender(), offerId, collection, tokenId, quantity, paymentToken, price);
    }

    /**
     * @notice Accept an offer.
     * @param offerId The id of the offer.
     */
    function acceptOffer(uint256 offerId) external override nonReentrant {
        OfferInfo memory offer = _offers[offerId];

        if(IERC165(offer.token.collection).supportsInterface(INTERFACE_ERC721)) {
            require(IERC721(offer.token.collection).ownerOf(offer.token.tokenId) == _msgSender(), "Planet: caller is not the token owner");
            IERC721(offer.token.collection).safeTransferFrom(_msgSender(), offer.offerer, offer.token.tokenId, MARKET_DATA);
        } else {
            require(IERC1155(offer.token.collection).balanceOf(_msgSender(), offer.token.tokenId) >= offer.token.quantity, "Planet: insufficient quantity for accept");
            IERC1155(offer.token.collection).safeTransferFrom(_msgSender(), offer.offerer, offer.token.tokenId, offer.token.quantity, MARKET_DATA);
        }

        _splitPayment(offer.token, offer.payment, _msgSender());

        _offers[offerId].offerState = 2;
        _offers[offerId].updateTime = block.timestamp;

        emit OfferAccepted(offerId, _msgSender());
    }

    /**
     * @notice Cancel an offer.
     * @param offerId The id of the offer.
     */
    function cancelOffer(uint256 offerId) external override nonReentrant {
        OfferInfo memory offer;
        require(offer.offerState == 1, "Planet: invalid offer for cancel");
        require(offer.offerer == _msgSender(), "Planet: caller is not the offerer");

        _refundPayment(offer.payment, _msgSender());

        _offers[offerId].offerState = 3;
        _offers[offerId].updateTime = block.timestamp;

        emit OfferCanceled(offerId);
    }


    // ----- INTERNAL FUNCTIONS ----- //

    /**
     * @notice internal utility method for creating order
     */
    function _createOrder(uint256 orderType, TokenInfo memory token, PaymentInfo memory payment, uint256 endTime) internal returns (uint256) {
        OrderInfo memory newOrder;
        newOrder.orderId = _orders.length;
        newOrder.orderType = orderType;
        newOrder.orderState = 1;
        newOrder.token = token;
        newOrder.payment = payment;
        newOrder.endTime = endTime;
        newOrder.seller = _msgSender();
        newOrder.createTime = block.timestamp;
        newOrder.updateTime = block.timestamp;

        _orders.push(newOrder);

        return newOrder.orderId;
    }

    /**
     * @notice internal utility method for locking token within this contract
     */
    function _lockToken(TokenInfo memory token, address from) internal {
        if(IERC165(token.collection).supportsInterface(INTERFACE_ERC721)) {
            require(token.quantity == 1, "Planet: invalid quantity for ERC721");
            require(IERC721(token.collection).isApprovedForAll(from, address(this)), "Planet: collection is not approved");
            IERC721(token.collection).safeTransferFrom(from, address(this), token.tokenId, MARKET_DATA);
        } else if(IERC165(token.collection).supportsInterface(INTERFACE_ERC1155)) {
            require(token.quantity > 0, "Planet: quantity cannot be zero");
            require(IERC1155(token.collection).isApprovedForAll(from, address(this)), "Planet: collection is not approved");
            IERC1155(token.collection).safeTransferFrom(from, address(this), token.tokenId, token.quantity, MARKET_DATA);
        } else {
            revert("invalid address for ERC721/ERC1155 collection");
        }
    }

    /**
     * @notice internal utility method for unlocking token from this contract
     */
    function _unlockToken(TokenInfo memory token, address to) internal {
        if(IERC165(token.collection).supportsInterface(INTERFACE_ERC721)) {
            IERC721(token.collection).safeTransferFrom(address(this), to, token.tokenId, MARKET_DATA);
        } else if(IERC165(token.collection).supportsInterface(INTERFACE_ERC1155)) {
            IERC1155(token.collection).safeTransferFrom(address(this), to, token.tokenId, token.quantity, MARKET_DATA);
        }
    }

    /**
     * @notice internal utility method for executing payment
     */
    function _executePayment(PaymentInfo memory payment) internal {
        if(payment.paymentToken == address(0)) {
            require(msg.value == payment.price, "Planet: incorrect msg value");
        } else {
            require(msg.value == 0, "Planet: invalid msg value");
            require(IERC20(payment.paymentToken).transferFrom(_msgSender(), address(this), payment.price), "Planet: token transfer failed for execution");
        }
    }

    /**
     * @notice internal utility method for splitting payment
     */
    function _splitPayment(TokenInfo memory token, PaymentInfo memory payment, address receiver) internal {
        (address royaltyOwner, uint256 royaltyFee) = IService(serviceAddress).royaltyOf(token.collection, payment.price);
        (address kothOwner, uint256 kothFee) = IService(serviceAddress).kothOf(token.collection, token.tokenId, payment.price);
        address platformAddress = IService(serviceAddress).platformAddress();
        uint96 platformFeeRate = IService(serviceAddress).platformFeeRate();
        uint256 platformFee = payment.price * platformFeeRate / _denominator;
        uint256 paymentExcludingFee = payment.price - royaltyFee - platformFee - kothFee;

        if(payment.paymentToken == address(0)) {
            bool success;
            if(royaltyOwner != address(0)) {
                (success, ) = payable(royaltyOwner).call{value: royaltyFee}("");
                require(success, "Planet: BNB transfer failed for royalty");
            }
            if(kothOwner != address(0)) {
                (success, ) = payable(kothOwner).call{value: kothFee}("");
                require(success, "Planet: BNB transfer failed for KotH");
            }
            (success, ) = payable(platformAddress).call{value: platformFee}("");
            require(success, "Planet: BNB transfer failed for service fee");
            (success, ) = payable(receiver).call{value: paymentExcludingFee}("");
            require(success, "Planet: BNB transfer failed for payment");
        } else {
            if(royaltyOwner != address(0))
                require(IERC20(payment.paymentToken).transfer(royaltyOwner, royaltyFee), "Planet: token transfer failed for royalty");
            if(kothOwner != address(0))
                require(IERC20(payment.paymentToken).transfer(kothOwner, kothFee), "Planet: token transfer failed for KotH");
            require(IERC20(payment.paymentToken).transfer(platformAddress, platformFee), "Planet: token transfer failed for service fee");
            require(IERC20(payment.paymentToken).transfer(receiver, paymentExcludingFee), "Planet: token transfer failed for payment");
        }
    }

    /**
     * @notice internal utility method for refunding payment
     */
    function _refundPayment(PaymentInfo memory payment, address receiver) internal {
        if(payment.paymentToken == address(0)) {
            (bool success, ) = payable(receiver).call{value: payment.price}("");
            require(success, "Planet: BNB transfer failed for refund");
        } else {
            require(IERC20(payment.paymentToken).transfer(receiver, payment.price), "Planet: token transfer failed for refund");
        }
    }

    /**
     * @notice internal utility method for canceling order
     */
    function _cancelOrder(uint256 orderId) internal {
        _unlockToken(_orders[orderId].token, _orders[orderId].seller);

        _orders[orderId].orderState = 3;
        _orders[orderId].updateTime = block.timestamp;
    }

    /**
     * @notice internal utility method for creating offer
     */
    function _createOffer(TokenInfo memory token, PaymentInfo memory payment) internal returns (uint256) {
        OfferInfo memory newOffer;
        newOffer.offerId = _offers.length;
        newOffer.offerState = 1;
        newOffer.token = token;
        newOffer.payment = payment;
        newOffer.offerer = _msgSender();
        newOffer.createTime = block.timestamp;
        newOffer.updateTime = block.timestamp;

        _offers.push(newOffer);

        return newOffer.offerId;
    }


    // ----- RESTRICTED FUNCTIONS ----- //
    function setManager(address account, bool approval) external onlyOwner {
        _managers[account] = approval;
    }

    function setPayment(address token, bool approval) external onlyOwner {
        _payments[token] = approval;
    }
}