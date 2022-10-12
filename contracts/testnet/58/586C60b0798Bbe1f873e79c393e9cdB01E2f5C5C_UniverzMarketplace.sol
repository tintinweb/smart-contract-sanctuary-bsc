// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract UniverzMarketplace is ERC721Holder, ReentrancyGuard {
    enum MarketItemStatus {
        UNEXISTED,
        ADDED,
        BOUGHT,
        CANCELED
    }

    enum AuctionItemStatus {
        UNEXISTED,
        STARTED,
        ENDED,
        CANCELED
    }

    struct AuctionItem {
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        address seller;
        address owner;
        uint256 nftId;
        address tokenAddress;
        AuctionItemStatus auctionItemsStatus;
    }

    struct MarketItem {
        address tokenAddress;
        uint256 nftId;
        uint256 price;
        address seller;
        address owner;
        MarketItemStatus marketItemStatus;
    }

    event AddMarketItem(
        address indexed _tokenAddress,
        uint256 _id,
        bytes32 indexed _itemId,
        uint256 _price,
        address indexed seller,
        MarketItemStatus marketItemStatus
    );

    event MarketItemPriceChanged(
        address indexed tokenAddress,
        uint256 nftId,
        bytes32 indexed itemId,
        address indexed seller,
        uint256 oldPrice,
        uint256 newPrice
    );

    event BuyMarketItem(
        address indexed _tokenAddress,
        uint256 _id,
        bytes32 indexed _itemId,
        address indexed buyer,
        MarketItemStatus marketItemStatus
    );

    event CancleMarketItem(
        address indexed _tokenAddress,
        uint256 _id,
        bytes32 indexed _itemId,
        uint256 _price,
        address indexed seller,
        MarketItemStatus marketItemStatus
    );

    event CreateAuctionItem(
        address indexed _tokenAddress,
        uint256 _nftId,
        bytes32 indexed _auctionItemId,
        uint256 _initialBid,
        address indexed seller,
        uint256 _startTime,
        uint256 _endTime,
        AuctionItemStatus auctionItemStatus
    );

    event Bid(address indexed bidder, uint256 bid, bytes32 indexed _auctionId, uint256 bidTime, uint256 endTime);

    event AuctionEnd(
        address indexed seller,
        address buyer,
        uint256 lastBid,
        address indexed nftAddress,
        bytes32 indexed auctionId,
        uint256 nftId,
        uint256 endTime
    );

    event AuctionCanceled(
        address indexed seller,
        address highestBidder,
        uint256 highestBid,
        bytes32 indexed auctionItemId,
        address indexed tokenAddress,
        uint256 nftId,
        uint256 cancelTime,
        uint256 endTime
    );

    mapping(address => uint256) public itemsCount;

    mapping(bytes32 => MarketItem) public items;
    mapping(bytes32 => AuctionItem) public auctionItems;

    function encode(address owner, uint256 itemCount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner, itemCount));
    }

    function addToSell(
        address _tokenAddress,
        uint256 _id,
        uint256 _priceInWei
    ) external {
        require(_priceInWei > 0, "You can't sell with 0 price");

        bytes32 itemId = encode(msg.sender, itemsCount[msg.sender]);

        items[itemId] = MarketItem(
            _tokenAddress,
            _id,
            _priceInWei,
            msg.sender,
            IERC721(_tokenAddress).ownerOf(_id),
            MarketItemStatus.ADDED
        );

        itemsCount[msg.sender] += 1;

        IERC721(_tokenAddress).safeTransferFrom(msg.sender, address(this), _id);

        emit AddMarketItem(_tokenAddress, _id, itemId, _priceInWei, msg.sender, MarketItemStatus.ADDED);
    }

    function changeItemPrice(bytes32 itemId, uint256 newPrice) external {
        require(newPrice > 0, "Price must be greater than 0");
        require(msg.sender == items[itemId].seller, "Only seller can change price");
        require(items[itemId].marketItemStatus == MarketItemStatus.ADDED, "The item is not for sale at the moment");

        uint256 oldPrice = items[itemId].price;

        items[itemId].price = newPrice;

        emit MarketItemPriceChanged(
            items[itemId].tokenAddress,
            items[itemId].nftId,
            itemId,
            msg.sender,
            oldPrice,
            newPrice
        );
    }

    function buyItem(bytes32 itemId) external payable nonReentrant {
        require(msg.value >= items[itemId].price, "You need more BNB");
        require(items[itemId].marketItemStatus == MarketItemStatus.ADDED, "The item is not for sale at the moment");
        items[itemId].marketItemStatus = MarketItemStatus.BOUGHT;

        IERC721(items[itemId].tokenAddress).safeTransferFrom(address(this), msg.sender, items[itemId].nftId);

        payable(items[itemId].seller).transfer(msg.value);
        emit BuyMarketItem(
            items[itemId].tokenAddress,
            items[itemId].nftId,
            itemId,
            msg.sender,
            MarketItemStatus.BOUGHT
        );
    }

    function cancel(bytes32 _itemId) external {
        require(items[_itemId].seller == msg.sender, "Only seller can cancel item");

        emit CancleMarketItem(
            items[_itemId].tokenAddress,
            items[_itemId].nftId,
            _itemId,
            items[_itemId].price,
            items[_itemId].seller,
            MarketItemStatus.CANCELED
        );

        IERC721(items[_itemId].tokenAddress).safeTransferFrom(
            address(this),
            items[_itemId].seller,
            items[_itemId].nftId
        );

        delete items[_itemId];
    }

    // =====================
    // = Auction functions =
    // =====================

    function createAuctionItem(
        uint256 _nftId,
        address _nftAddress,
        uint256 _endTime,
        uint256 _initialBid
    ) external {
        require(_nftAddress != address(0), "NFT doesn't exists");
        bytes32 auctionItemId = encode(msg.sender, itemsCount[msg.sender]);
        require(auctionItems[auctionItemId].auctionItemsStatus == AuctionItemStatus.UNEXISTED, "Item already exists");
        require(_initialBid > 0, "You can't start at 0");
        require(_endTime > block.timestamp, "Wrong end time");

        auctionItems[auctionItemId] = AuctionItem(
            _endTime,
            msg.sender,
            _initialBid,
            msg.sender,
            IERC721(_nftAddress).ownerOf(_nftId),
            _nftId,
            _nftAddress,
            AuctionItemStatus.STARTED
        );

        itemsCount[msg.sender] += 1;

        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _nftId);

        emit CreateAuctionItem(
            _nftAddress,
            _nftId,
            auctionItemId,
            _initialBid,
            msg.sender,
            block.timestamp,
            _endTime,
            AuctionItemStatus.STARTED
        );
    }

    function bid(bytes32 _auctionId) external payable nonReentrant {
        require(auctionItems[_auctionId].auctionItemsStatus == AuctionItemStatus.STARTED, "Auction not Started");
        require(auctionItems[_auctionId].endTime > block.timestamp, "Auction ended");
        require(msg.value > auctionItems[_auctionId].highestBid, "Bid must be greater than last");
        require(msg.sender != auctionItems[_auctionId].seller, "Seller can't bid");

        address lastBidder = auctionItems[_auctionId].highestBidder;
        uint256 lastBid = auctionItems[_auctionId].highestBid;

        if (auctionItems[_auctionId].highestBidder != auctionItems[_auctionId].seller) {
            payable(lastBidder).transfer(lastBid);
        }

        auctionItems[_auctionId].highestBidder = msg.sender;
        auctionItems[_auctionId].highestBid = msg.value;

        emit Bid(msg.sender, msg.value, _auctionId, block.timestamp, auctionItems[_auctionId].endTime);
    }

    function auctionEnd(bytes32 _auctionId) external nonReentrant {
        require(
            auctionItems[_auctionId].auctionItemsStatus == AuctionItemStatus.STARTED,
            "You can't end ended auction"
        );
        require(block.timestamp >= auctionItems[_auctionId].endTime, "Auction not ended yet");

        uint256 lastBid = auctionItems[_auctionId].highestBid;
        address lastBidder = auctionItems[_auctionId].highestBidder;
        uint256 nftId = auctionItems[_auctionId].nftId;
        address nftAddress = auctionItems[_auctionId].tokenAddress;
        address seller = auctionItems[_auctionId].seller;

        emit AuctionEnd(
            auctionItems[_auctionId].seller,
            auctionItems[_auctionId].highestBidder,
            auctionItems[_auctionId].highestBid,
            auctionItems[_auctionId].tokenAddress,
            _auctionId,
            auctionItems[_auctionId].nftId,
            auctionItems[_auctionId].endTime
        );

        payable(seller).transfer(lastBid);
        IERC721(nftAddress).safeTransferFrom(address(this), lastBidder, nftId);

        delete auctionItems[_auctionId];
    }

    function cancelAuction(bytes32 _auctionId) external nonReentrant {
        require(
            auctionItems[_auctionId].auctionItemsStatus == AuctionItemStatus.STARTED,
            "Only started auction can be canceled"
        );
        require(msg.sender == auctionItems[_auctionId].seller, "Only seller can cancel auction");

        if (auctionItems[_auctionId].highestBidder != auctionItems[_auctionId].seller) {
            payable(auctionItems[_auctionId].highestBidder).transfer(auctionItems[_auctionId].highestBid);
        }

        IERC721(auctionItems[_auctionId].tokenAddress).safeTransferFrom(
            address(this),
            auctionItems[_auctionId].seller,
            auctionItems[_auctionId].nftId
        );

        emit AuctionCanceled(
            msg.sender,
            auctionItems[_auctionId].highestBidder,
            auctionItems[_auctionId].highestBid,
            _auctionId,
            auctionItems[_auctionId].tokenAddress,
            auctionItems[_auctionId].nftId,
            block.timestamp,
            auctionItems[_auctionId].endTime
        );

        delete auctionItems[_auctionId];
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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