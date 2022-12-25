/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// Sources flattened with hardhat v2.11.2 https://hardhat.org
// SPDX-License-Identifier: MIT
// File @openzeppelin/contracts/utils/introspection/[email protected]

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

// File @openzeppelin/contracts/token/ERC721/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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

// File @openzeppelin/contracts/security/[email protected]

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

// File contracts/SGMarketplace.sol

pragma solidity 0.8.14;

error SGMarketplace_PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error SGMarketplace_ItemNotForSale(address nftAddress, uint256 tokenId);
error SGMarketplace_NotListed(address nftAddress, uint256 tokenId);
error SGMarketplace_AlreadyListed(address nftAddress, uint256 tokenId);
error SGMarketplace_NoProceeds();
error SGMarketplace_NotOwner();
error SGMarketplace_OwnerCannotBuyTheListing();
error SGMarketplace_NotApprovedForMarketplace();
error SGMarketplace_PriceMustBeAboveZero();
error SGMarketplace_NotAnAuctionListing();
error SGMarketplace_NoBidsAvailable();
error SGMarketplace_BidMustBeHigher();
error SGMarketplace_BidMustBeHigherThenListedPrice();
error SGMarketplace_WithdrawFailed();
error SGMarketplace_BidCannotBeZero();

contract SGMarketplace is ReentrancyGuard {
    struct Bidder {
        address payable addr;
        uint256 amount;
        uint256 bidAt;
    }

    struct Listing {
        uint256 price;
        address seller;
        bool isAuction;
        address highestBidder;
        uint256 highestBid;
    }

    ///////////////////////////////////////////////////////////
    //              EVENTS
    // ///////////////////////////////////////////////////////

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        bool isAuction
    );

    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);

    event UpdatedItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        bool isAuction
    );

    event ItemBidded(
        address indexed bidder,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 bidAmount
    );

    event ItemBought(
        address indexed buyer,
        address indexed seller,
        bool indexed isAuction,
        address nftAddress,
        uint256 tokenId,
        uint256 price
    );

    ///////////////////////////////////////////////////////////
    //              PROJECT INFO
    // ///////////////////////////////////////////////////////

    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_proceeds;
    mapping(address => mapping(uint256 => Bidder[])) private bidders;

    ///////////////////////////////////////////////////////////
    //              Modifiers
    // ///////////////////////////////////////////////////////

    modifier notListed(
        address nftAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert SGMarketplace_AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert SGMarketplace_NotListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isNotOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender == owner) {
            revert SGMarketplace_OwnerCannotBuyTheListing();
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert SGMarketplace_NotOwner();
        }
        _;
    }

    ///////////////////////////////////////////////////////////
    //              Get Functions
    // ///////////////////////////////////////////////////////

    function getListing(
        address nftAddress,
        uint256 tokenId
    ) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }

    function getBidders(
        address nftAddress,
        uint256 tokenId
    ) external view returns (Bidder[] memory) {
        return bidders[nftAddress][tokenId];
    }

    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    }

    function isAuctionListing(address nftAddress, uint256 tokenId) public view returns (bool) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        return listing.isAuction;
    }

    function checkIfApproved(address nftAddress, uint256 tokenId) internal view returns (bool) {
        IERC721 nft = IERC721(nftAddress);
        return nft.getApproved(tokenId) != address(this);
    }

    ///////////////////////////////////////////////////////////
    //              Update Functions
    // ///////////////////////////////////////////////////////

    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        bool isAuction
    ) external notListed(nftAddress, tokenId, msg.sender) isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) {
            revert SGMarketplace_PriceMustBeAboveZero();
        }
        if (checkIfApproved(nftAddress, tokenId)) {
            revert SGMarketplace_NotApprovedForMarketplace();
        }
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender, isAuction, address(0), 0);
        emit ItemListed(msg.sender, nftAddress, tokenId, price, isAuction);
    }

    function cancelListing(
        address nftAddress,
        uint256 tokenId
    ) external isOwner(nftAddress, tokenId, msg.sender) isListed(nftAddress, tokenId) {
        if (isAuctionListing(nftAddress, tokenId)) {
            transferAllBidAmount(nftAddress, tokenId, false);
            delete (bidders[nftAddress][tokenId]);
        }
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    function buyItem(
        address nftAddress,
        uint256 tokenId
    )
        external
        payable
        isListed(nftAddress, tokenId)
        isNotOwner(nftAddress, tokenId, msg.sender)
        nonReentrant
    {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) {
            revert SGMarketplace_PriceNotMet(nftAddress, tokenId, listedItem.price);
        }
        s_proceeds[listedItem.seller] += msg.value;
        delete (s_listings[nftAddress][tokenId]);
        delete (bidders[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
        emit ItemBought(
            msg.sender,
            listedItem.seller,
            listedItem.isAuction,
            nftAddress,
            tokenId,
            listedItem.price
        );
    }

    function acceptHighestBid(
        address nftAddress,
        uint256 tokenId
    ) external isListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) nonReentrant {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (listedItem.isAuction == false) {
            revert SGMarketplace_NotAnAuctionListing();
        }

        if (bidders[nftAddress][tokenId].length == 0) {
            revert SGMarketplace_NoBidsAvailable();
        }

        s_proceeds[listedItem.seller] += listedItem.highestBid;
        transferAllBidAmount(nftAddress, tokenId, true);
        delete (s_listings[nftAddress][tokenId]);
        delete (bidders[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(msg.sender, listedItem.highestBidder, tokenId);
        emit ItemBought(
            listedItem.highestBidder,
            msg.sender,
            listedItem.isAuction,
            nftAddress,
            tokenId,
            listedItem.highestBid
        );
    }

    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newbid,
        bool _isAuction
    ) external isListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
        if (newbid <= 0) {
            revert SGMarketplace_PriceMustBeAboveZero();
        }
        s_listings[nftAddress][tokenId].price = newbid;
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (!listing.isAuction && _isAuction) {
            listing.isAuction = _isAuction;
            listing.highestBid = 0;
            listing.highestBidder = address(0);
            s_listings[nftAddress][tokenId] = listing;
        }

        if (listing.isAuction && !_isAuction) {
            listing.isAuction = _isAuction;
            listing.highestBid = 0;
            listing.highestBidder = address(0);
            transferAllBidAmount(nftAddress, tokenId, false);
            delete bidders[nftAddress][tokenId];
            s_listings[nftAddress][tokenId] = listing;
        }
        emit UpdatedItemListed(msg.sender, nftAddress, tokenId, newbid, _isAuction);
    }

    function transferAllBidAmount(address nftAddress, uint256 tokenId, bool bidAccepted) internal {
        if (bidAccepted) {
            address highestBidder = s_listings[nftAddress][tokenId].highestBidder;
            for (uint256 i = 0; i < bidders[nftAddress][tokenId].length; i++) {
                address payable bidder = bidders[nftAddress][tokenId][i].addr;
                if (highestBidder != bidder) {
                    uint256 amount = bidders[nftAddress][tokenId][i].amount;
                    bidder.transfer(amount);
                }
            }
        } else {
            for (uint256 i = 0; i < bidders[nftAddress][tokenId].length; i++) {
                address payable bidder = bidders[nftAddress][tokenId][i].addr;
                uint256 amount = bidders[nftAddress][tokenId][i].amount;
                bidder.transfer(amount);
            }
        }
    }

    function placeBid(
        address nftAddress,
        uint256 tokenId
    ) external payable isListed(nftAddress, tokenId) isNotOwner(nftAddress, tokenId, msg.sender) {
        if (msg.value == 0) {
            revert SGMarketplace_BidCannotBeZero();
        }
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (listedItem.isAuction == false) {
            revert SGMarketplace_NotAnAuctionListing();
        }
        if (msg.value <= listedItem.highestBid) {
            revert SGMarketplace_BidMustBeHigher();
        }
        if (msg.value <= listedItem.price) {
            revert SGMarketplace_BidMustBeHigherThenListedPrice();
        }
        updatedBidder(nftAddress, tokenId, msg.sender, msg.value);
        s_listings[nftAddress][tokenId].highestBid = msg.value;
        s_listings[nftAddress][tokenId].highestBidder = msg.sender;
        emit ItemBidded(msg.sender, nftAddress, tokenId, msg.value);
    }

    function updatedBidder(
        address nftAddress,
        uint256 tokenId,
        address bidder,
        uint256 amount
    ) internal {
        for (uint256 i = 0; i < bidders[nftAddress][tokenId].length; i++) {
            if (bidders[nftAddress][tokenId][i].addr == bidder) {
                bidders[nftAddress][tokenId][i].amount += amount;
                break;
            }
        }
        bidders[nftAddress][tokenId].push(Bidder(payable(bidder), amount, block.timestamp));
    }

    ///////////////////////////////////////////////////////////
    //              Withdraw FUNCTIONS
    // ///////////////////////////////////////////////////////

    function withdrawProceeds() external nonReentrant {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert SGMarketplace_NoProceeds();
        }
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        if (!success) {
            revert SGMarketplace_WithdrawFailed();
        } else {
            s_proceeds[msg.sender] = 0;
        }
    }
}