// SPDX-License-Identifier: Multiverse Expert
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
contract RSUMarketplace is ReentrancyGuard, Pausable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter public _orderIds; // unique
    Counters.Counter public _offerIds;
    address public _recipientWallet;
    uint256 public _feeRate = 2;
    uint256 public _refundPrice = 0.0001 ether;
    // --------------------- Struct Process --------------------- //
    enum MarketType {
        Marketplace,
        Auction
    }
    struct Order {
        address nftContract;
        address tokenAddress; // buy with token
        address seller;
        address buyer;
        uint256 orderId;
        uint256 tokenId;
        uint256 startPrice; // in case auction it's mean teminate price
        uint256 currentPrice;
        uint256 terminatePrice;
        uint256 expiration; // use only auction
        uint256 acceptTime; // use only auction
        uint256 refundPrice; // stake price before bidding
        bool isActive;
        MarketType marketType;
    }
    struct Bid {
        address bidder;
        uint256 bidPrice;
        uint256 bidTime;
        uint256 bidId;
        bool isAccept;
        bool isActive;
    }
    struct Refund {
        bool isBid;
        bool isRefund;
    }
    struct Offer {
        address offerer;
        address tokenAddress;
        address nftContract;
        uint256 offerPrice;
        uint256 tokenId;
        uint256 offerId;
        bool isAccept;
        bool isActive;
    }
    Order[] orders;
    mapping(uint256 => Bid[]) public bids;
    mapping(uint256 => mapping(address => Refund)) public refunds;
    mapping(address => Offer[]) public offers;
    constructor(address _recipt){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _recipientWallet = _recipt;
    }
    // ------------ Update Config Contract ---------- //
    function setIsPause(bool status) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if(status){
            _pause();
        } else {
            _unpause();
        }
    }
    function updateFeeRate(uint256 feeRate) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(feeRate <= 50); // rate percent
        _feeRate = feeRate;
    }
    function updateRecipientWallet(address newWallet)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newWallet != address(0), "Wallet must not be address 0");
        _recipientWallet = newWallet;
    }
    function updateRefundPrice(uint256 refundPrice)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(refundPrice > 0, "Refund price is incorrect");
        _refundPrice = refundPrice;
    }
    // ---------- Event Process ---------- //
    event CreateOrderEvent  (
        address indexed nftContract,
        uint256 indexed orderId,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        address tokenAddress,
        MarketType marketType,
        bool isActive
    );
    event CancelOrderEvent (
        address indexed nftContract,
        uint256 indexed orderId,
        bool isActive,
        MarketType marketType
    );
    event BoughEvent (
        address indexed nftContract,
        address indexed buyer,
        uint256 indexed orderId,
        uint256 price,
        uint256 fee,
        MarketType marketType
    );
    event CreateOfferEvent (
        address indexed offerer,
        address indexed nftOwner,
        address nftContrat,
        uint256 offerPrice,
        uint256 tokenId,
        uint256 offerId,
        bool isActive
    );
    event CancelOfferEvent (
        address indexed offerer,
        address indexed nftOwner,
        address nftContract,
        uint256 offerPrice,
        uint256 tokenId,
        uint256 offerId,
        uint256 fee,
        bool isActive
    );
    event AcceptOfferEvent (
        address indexed offerer,
        address indexed nftOwner,
        uint256 offerPrice,
        address nftContract,
        uint256 tokenId,
        uint256 offerId,
        uint256 fee,
        bool isAccept,
        bool isActive
    );
    event BiddingEvent (
        address indexed nftContract,
        uint256 indexed orderId,
        uint256 indexed tokenId,
        uint256 bidPrice
    );
    event WinnerAcceptBidEvent (
        address indexed nftContract,
        uint256 indexed orderId,
        uint256 indexed tokenId,
        uint256 fee,
        uint256 acceptAtPrice
    );
    event CloseBidEvent (
        address indexed nftContract,
        uint256 indexed orderId,
        uint256 latestBidPrice
    );
    event CancelBidEvent (
        address indexed nftContract,
        uint256 indexed orderId,
        uint256 fee,
        uint256 bidId
    );
    event DepositCashForBidEvent (
        address indexed nftContract,
        uint256 indexed orderId,
        uint256 depositPrice,
        address bidder
    );
    event RefundBidEvent (
        address indexed nftContract,
        uint256 indexed orderId,
        uint256 refundPrice,
        address bidder
    );
    // ---------- Funtional Process ------ //
    function createOrder (
        address nftContract,
        address tokenAddress,
        uint256 tokenId,
        uint256 startPrice,
        uint256 expiration, // use only auciton
        uint256 terminatePrice, // use only auction
        MarketType marketType
    ) public nonReentrant {
        uint256 orderId = _orderIds.current();
        _orderIds.increment();
        require(startPrice > 0, "Invaild Price");
        require(nftContract != address(0) && tokenAddress != address(0), "Invalid address");
        require(
            IERC721(nftContract).ownerOf(tokenId) == msg.sender,
            "You don't own the NFT"
        );
        require(orders[orderId].isActive == false, "Order is already active");
        if(marketType == MarketType.Auction){
            require(expiration + 1 days >= block.timestamp, "Expiration time is incorrect");
            bids[orderId].push(Bid(
                msg.sender,
                startPrice,
                block.timestamp,
                0, // bidId
                false,
                true
            ));
        }
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        orders[orderId] = Order (
            nftContract,
            tokenAddress,
            msg.sender,
            address(0), // buyer
            orderId,
            tokenId,
            startPrice,
            startPrice,
            terminatePrice,
            expiration,
            expiration + 1 days,
            _refundPrice,
            true,
            marketType
        );
        emit CreateOrderEvent(nftContract, orderId, tokenId, msg.sender, startPrice, tokenAddress, marketType, true);
    }
    function cancelOrder(
        uint256 orderId
    ) public nonReentrant{
        Order memory orderData = orders[orderId];
        require(orderData.seller == msg.sender, "You don't own this order");
        require(orderData.isActive, "Already unactive");
        orders[orderId].isActive = false;
        address nftContract =orderData.nftContract;
        uint256 tokenId = orderData.tokenId;
        IERC721(nftContract).setApprovalForAll(msg.sender, true);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        emit CancelOrderEvent(nftContract, orderId, false, orderData.marketType);
    }
    function buyOrder( // terminate buy when it's auction
        uint256 orderId
    ) public nonReentrant {
        Order memory orderData = orders[orderId];
        require(orderData.isActive, "Order isn't active");
        uint256 price = (orderData.marketType == MarketType.Auction) ? orderData.terminatePrice : orderData.startPrice;
        uint256 balance = IERC20(orderData.tokenAddress).balanceOf(msg.sender);
        uint256 fee = price * _feeRate / 100;
        require(
            balance >= price + fee,
            "Your balance isn't enough for price + fee"
        );
        orders[orderId].isActive = false;
        orders[orderId].buyer = msg.sender;
        IERC20(orderData.tokenAddress).transferFrom(
            msg.sender,
            _recipientWallet,
            fee
        );
        IERC20(orderData.tokenAddress).transferFrom(msg.sender, orderData.seller, price);
        IERC721(orderData.nftContract).setApprovalForAll(msg.sender, true);
        IERC721(orderData.nftContract).transferFrom(address(this), msg.sender, orderData.tokenId);
        emit BoughEvent(orderData.nftContract, msg.sender, orderId, price, fee, orderData.marketType);
    }
    function bidAuction (
        uint256 orderId,
        uint256 bidPrice
    ) public nonReentrant {
        Order memory orderData = orders[orderId];
        Refund memory refundData = refunds[orderId][msg.sender];
        require(orderData.isActive, "Order isn't active");
        require(orderData.marketType == MarketType.Auction, "Only Auction process");
        require(bidPrice >= orderData.currentPrice, "BidPrice isn't enough");
        require(orderData.expiration >= block.timestamp, "Order is expired");
        require(refundData.isBid && refundData.isRefund == false, "Deposit to bidding first");
        require(orderData.seller != msg.sender, "Owner can't bidding");
        orders[orderId].currentPrice = bidPrice;
        bids[orderId].push(
            Bid(
                msg.sender,
                bidPrice,
                block.timestamp,
                bids[orderId].length,
                false,
                true
            )
        );
        emit BiddingEvent(orderData.nftContract, orderId, orderData.tokenId, bidPrice);
    }
    function closeBid(uint256 orderId) public nonReentrant{
        Order memory orderData = orders[orderId];
        require(orderData.seller == msg.sender, "You're not owned this order");
        require(orderData.isActive, "Order isn't active");
        require(orderData.expiration >= block.timestamp, "Already closed");
        require(orderData.marketType == MarketType.Auction, "Only Auction process");
        Bid memory bidWinner = getLatestBidder(orderId);
        if(bidWinner.bidder == msg.sender) {
            // creater is winner
            orders[orderId].isActive = false;
            IERC721(orderData.nftContract).setApprovalForAll(orderData.seller, true);
            IERC721(orderData.nftContract).transferFrom(address(this), orderData.seller, orders[orderId].tokenId);
        }
        orders[orderId].expiration = block.timestamp;
        emit CloseBidEvent(orderData.nftContract, orderId, bidWinner.bidPrice);
    }
    function winnerAcceptBid(uint256 orderId) public nonReentrant {
        Order memory orderData = orders[orderId];
        uint256 fee = orders[orderId].currentPrice * _feeRate / 100;
        uint256 balance = IERC20(orders[orderId].tokenAddress).balanceOf(msg.sender);
        require(orderData.isActive, "Order isn't active");
        require(orderData.seller != msg.sender, "Owner can't accept");
        require(orderData.marketType == MarketType.Auction, "Only Auction process");
        require(
            orderData.acceptTime <= block.timestamp &&
            orderData.expiration >= block.timestamp
        , "Out of time to accept");
        require(balance >= fee + orderData.currentPrice, "Balance isn't enough (price + fee)");
        orders[orderId].isActive = false;
        orders[orderId].buyer = msg.sender;
        IERC20(orderData.tokenAddress).transferFrom(msg.sender, orders[orderId].seller, orderData.currentPrice);
        IERC20(orderData.tokenAddress).transferFrom(msg.sender, _recipientWallet, fee);
        IERC721(orderData.nftContract).setApprovalForAll(msg.sender, true);
        IERC721(orderData.nftContract).transferFrom(address(this), msg.sender, orders[orderId].tokenId);
        emit WinnerAcceptBidEvent(orderData.nftContract, orderId, orderData.tokenId, fee, orderData.currentPrice);
    }
    function cancelBid (uint256 orderId, uint256 bidId) public nonReentrant {
        Order memory orderData = orders[orderId];
        Bid[] memory bidList = bids[orderId];
        require(orderData.marketType == MarketType.Auction, "Only Auction process");
        require(orderData.isActive, "Order isn't active");
        require(orderData.expiration >= block.timestamp, "Out of time to cancel");
        require(bidList[bidId].isActive && bidId >= 1, "Already unactive");
        uint256 fee = bids[orderId][bidId].bidPrice * _feeRate / 100;
        IERC20(orderData.tokenAddress).transferFrom(msg.sender, _recipientWallet, fee);
        if(orderData.currentPrice <= bids[orderId][bidId].bidPrice){
            // when bidPrice is greatest price
            for (uint256 i = bids[orderId].length - 1; i >= 0; i--){
                if(bids[orderId][i].isActive){
                    orders[orderId].currentPrice = bids[orderId][i].bidPrice;
                    break;
                }
            }
        }
        bids[orderId][bidId].isActive = false;
        emit CancelBidEvent(orderData.nftContract, orderId, fee, bidId);
    }
    function depositCashForBid (uint256 orderId) public nonReentrant {
        Refund memory refundData = refunds[orderId][msg.sender];
        Order memory orderData = orders[orderId];
        require(refundData.isBid == false && refundData.isRefund == false, "Already refund or bidding");
        require(orderData.expiration >= block.timestamp, "Out out bidding time");
        require(orderData.isActive, "Order isn't active");
        IERC20(orderData.tokenAddress).transferFrom(msg.sender, address(this), orderData.refundPrice);
        refunds[orderId][msg.sender].isBid = true;
        emit DepositCashForBidEvent(orderData.nftContract, orderId, orderData.refundPrice, msg.sender);
    }
    function withdrawCashFromContract(address token, address to) public nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).approve(to, balance);
        IERC20(token).transfer(to, balance);
    }
    function refundBidding(uint256 orderId) public nonReentrant {
        Order memory orderData = orders[orderId];
        Refund memory refundData = refunds[orderId][msg.sender];
        require(refundData.isBid && refundData.isRefund == false, "Not ready for refund");
        require(orderData.expiration <= block.timestamp, "Not time for refund");
        Bid memory winner = getLatestBidder(orderId);
        if(winner.bidder == msg.sender){
            require(winner.isAccept, "Winner accept bid first");
        }
        refunds[orderId][msg.sender].isRefund = true;
        IERC20(orders[orderId].tokenAddress).approve(msg.sender, orders[orderId].refundPrice);
        IERC20(orders[orderId].tokenAddress).transfer(msg.sender, orders[orderId].refundPrice);
        emit RefundBidEvent(orderData.nftContract, orderId, orderData.refundPrice, msg.sender);
    }
    function makeOffer(uint256 offerPrice, address tokenAddress, address nftOwner, uint256 tokenId, address nftContract) public nonReentrant {
        uint256 balance = IERC20(tokenAddress).balanceOf(msg.sender);
        uint256 allowanceAmount = IERC20(tokenAddress).allowance(msg.sender, address(this));
        require(offerPrice > 0, "Incorrect offer price");
        require(balance >= offerPrice, "Balance isn't enough");
        require(IERC721(nftContract).ownerOf(tokenId) == nftOwner, "Invalid owner");
        require(allowanceAmount >= offerPrice + (offerPrice * _feeRate / 100), "Allowance isn't enough");
        uint256 offerId = _offerIds.current();
        _offerIds.increment();
        offers[nftOwner].push(
            Offer(
                msg.sender,
                tokenAddress,
                nftContract,
                offerPrice,
                tokenId,
                offerId,
                false,
                true
            )
        );
        emit CreateOfferEvent(msg.sender, nftOwner, nftContract, offerPrice, tokenId, offerId, true);
    }
    function cancelOffer(address nftOwner, uint256 offerId) public nonReentrant {
        Offer memory offerData = offers[nftOwner][offerId];
        require(offerData.offerer == msg.sender, "You're not offerer");
        require(offerData.isActive, "Already unactive");
        uint256 fee = offerData.offerPrice * _feeRate / 100;
        IERC20(offerData.tokenAddress).transferFrom(msg.sender, _recipientWallet, fee);
        offers[nftOwner][offerId].isActive = false;
        emit CancelOfferEvent(msg.sender, nftOwner, offerData.nftContract, offerData.offerPrice, offerData.tokenId, offerId, fee, false);
    }
    function acceptOffer(uint256 offerId) public nonReentrant {
        Offer memory offerData = offers[msg.sender][offerId];
        uint256 fee = offerData.offerPrice * _feeRate / 100;
        require(offerData.isActive, "Offer is unactive");
        IERC20(offerData.tokenAddress).transferFrom(offerData.offerer, msg.sender, offerData.offerPrice);
        IERC20(offerData.tokenAddress).transferFrom(_recipientWallet, msg.sender, fee);
        IERC721(offerData.nftContract).transferFrom(msg.sender, offerData.offerer, offerData.tokenId);
        offerData.isAccept = true;
        offerData.isActive = false;
        emit AcceptOfferEvent(offerData.offerer, msg.sender, offerData.offerPrice, offerData.nftContract, offerData.tokenId, offerId, fee, true, false);
    }
    // ------------------ Getter Function ---------------- //
    function getLatestBidder (
        uint256 orderId
    ) public view returns(Bid memory) {
        require(bids[orderId].length >= 1, "Order isn't created");
        for (uint256 i = bids[orderId].length - 1; i >= 0; i--) {
            if (bids[orderId][i].isActive) return bids[orderId][i];
        }
        return Bid(address(0), 0, 0, 0, false, false);
    }
    function getOrderList (
    ) public view returns(Order[] memory) {
        return orders;
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}