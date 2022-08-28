// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GivetreeNFTMakretplace is Ownable, ReentrancyGuard {
    uint256 public mintPrice;

	address[] public charityList;
	address[] public collections;
	IERC20 public paymentToken;		// Auction payment token address

	struct Collection {
		uint256 index;
		bool isExisted;
	}

	struct Listing {
		uint8 listingType;			// 0: Fixed
									// 1: Auction
		uint256 endAuctionTimestamp;	// For only auction
		uint256 price;					// initialPrice when listingType is 1 (Auction)
		address seller;
		address charity;
		uint8 percent;
	}

	struct BiddingForAuction {
		address bider;
		uint256 bidPrice;
		uint256 bidTimestamp;
	}

	mapping(address => mapping(uint256 => Listing)) private s_listings;
	mapping(address => mapping(uint256 => BiddingForAuction[])) private s_biddings;
	mapping(address => Collection) public collectionItem;

	event UploadedNewCollection(address collection);

	event GivetreeMinted(
		address indexed to,
		uint256 quantity
	);

	event ItemListedForFixed(
		address indexed collection,
		address indexed seller,
		uint256 tokenId,
		uint256 price,
		address indexed charity,
		uint8 percent
	);

	event ItemListedForAuction(
		address indexed collection,
		address indexed seller,
		uint256 tokenId,
		uint256 initialPrice,
		uint256 endTimetamp,
		address indexed charity,
		uint8 percent
	);

	event ItemCanceled(
		address indexed collection,
		address indexed seller,
		uint256 indexed tokenId
	);

	event AuctionEnded(
		address indexed collection,
		address indexed seller,
		uint256 indexed tokenId
	);

	event BiddedForAuction(
		address indexed collection,
		address indexed bidder,
		uint256 indexed tokenId,
		uint256 bidPrice
	);

	event BidCanceled(
		address indexed collection,
		address indexed bidder,
		uint256 indexed tokenId
	);

	event ItemBought(
		address indexed collection,
		address indexed buyer,
		uint256 indexed tokenId,
		uint256 price
	);

	error CustomError(string msg);

	modifier notListed(
		address collection,
		uint256 tokenId,
		address owner
	) {
		Listing memory listing = s_listings[collection][tokenId];
		require(listing.price == 0, "Already listed");
		_;
	}

	modifier isListed(
		address collection,
		uint256 tokenId
	) {
		require(s_listings[collection][tokenId].price > 0, "Not listed");
		_;
	}

	modifier isListedForFixed(
		address collection,
		uint256 tokenId
	) {
		require(s_listings[collection][tokenId].listingType == 0, "This item is listed for auction");
		_;
	}

	modifier isListedForAuction(
		address collection,
		uint256 tokenId
	) {
		require(s_listings[collection][tokenId].listingType > 0, "This item is listed for fixed");
		_;
	}

	modifier isTokenOwner(
		address collection,
		uint256 tokenId
	) {
		require(msg.sender == IERC721(collection).ownerOf(tokenId), "Not owner of token");
		_;
	}

	modifier isValidCharity(
		address charity
	) {
		if (charity != address(0)) {
			bool bValid = false;
			address[] memory _charityList = charityList;
			for (uint256 i = 0; i < _charityList.length; i ++) {
				if (_charityList[i] == charity) {
					bValid = true;
					break;
				}
			}

			require(bValid, "Invalid charity address");
		}
		_;
	}

	modifier isValidPercent(
		uint8 percent
	) {
		require(percent >= 1 && percent <= 100, "Invalid percent");
		_;
	}

	constructor() {
		paymentToken = IERC20(0xC964fFD97d750c843000fCf632BBA01ef4692933);	// set payment token address to WMATIC as default
		// addCharity(address(0x000000000000000000000000000000000000dEaD));
	}

	function setPaymentTokenAddr(address addr) public onlyOwner {
		require(addr != address(0), "Invalid address");
		paymentToken = IERC20(addr);
	}
	
	function listItemForFixed(address _collection, uint256 tokenId, uint256 price, address charity, uint8 percent)
		external 
		notListed(_collection, tokenId, _msgSender())
		isTokenOwner(_collection, tokenId)
		isValidCharity(charity)
		isValidPercent(percent)
	{
		require(price > 0, "Price must be above 0");

		s_listings[_collection][tokenId] = Listing(0, 0, price, _msgSender(), charity, percent);

		emit ItemListedForFixed(_collection, _msgSender(), tokenId, price, charity, percent);
	}

	function listItemForAuction(address _collection, uint256 tokenId, uint256 initialPrice, uint256 endAuctionTimestamp, address charity, uint8 percent)
		external 
		notListed(_collection, tokenId, _msgSender())
		isTokenOwner(_collection, tokenId)
		isValidCharity(charity)
		isValidPercent(percent)
	{
		require(initialPrice > 0, "Price must be above 0");
		require(endAuctionTimestamp > block.timestamp, "Invalid endAuctionTimestamp");

		s_listings[_collection][tokenId] = Listing(1, endAuctionTimestamp, initialPrice, _msgSender(), charity, percent);

		emit ItemListedForAuction(_collection, _msgSender(), tokenId, initialPrice, endAuctionTimestamp, charity, percent);
	}

	function updateListingForFixed(address _collection, uint256 tokenId, uint256 newPrice, address newCharity, uint8 newPercent) 
		external 
		isListed(_collection, tokenId)
		isListedForFixed(_collection, tokenId)
		isTokenOwner(_collection, tokenId)
		isValidCharity(newCharity)
		isValidPercent(newPercent)
		nonReentrant 
	{
		require(newPrice > 0, "Price must be above 0");

		s_listings[_collection][tokenId].price = newPrice;
		s_listings[_collection][tokenId].charity = newCharity;
		s_listings[_collection][tokenId].percent = newPercent;

		emit ItemListedForFixed(_collection, _msgSender(), tokenId, newPrice, newCharity, newPercent);
	}

	/*
	function updateListingForAuction(address _collection, uint256 tokenId, uint256 newInitialPrice, uint256 newEndAuctionTimestamp, address newCharity, uint8 newPercent) 
		external 
		isListed(tokenId)
		isListedForAuction(tokenId)
		isTokenOwner(tokenId, _msgSender())
		isValidCharity(newCharity)
		isValidPercent(newPercent)
		nonReentrant 
	{
		require(newInitialPrice > 0, "Price must be above 0");

		s_listings[tokenId].endAuctionTimestamp = newEndAuctionTimestamp;
		s_listings[tokenId].price = newInitialPrice;
		s_listings[tokenId].charity = newCharity;
		s_listings[tokenId].percent = newPercent;

		emit ItemListedForAuction(_msgSender(), tokenId, newInitialPrice, newEndAuctionTimestamp, newCharity, newPercent);
	}
	*/

	function cancelListing(address _collection, uint256 tokenId) 
		external 
		isTokenOwner(_collection, tokenId)
		isListed(_collection, tokenId)
	{
		if (s_listings[_collection][tokenId].listingType == 1) {
			delete s_biddings[_collection][tokenId];
		}

		delete s_listings[_collection][tokenId];

		emit ItemCanceled(_collection, _msgSender(), tokenId);
	}

	function buyItem(address _collection, uint256 tokenId) 
		external 
		payable 
		isListed(_collection, tokenId)
		isListedForFixed(_collection, tokenId)
		nonReentrant 
	{
		Listing memory listedItem = s_listings[_collection][tokenId];
		require(msg.value == listedItem.price, "Insufficient balance");

		uint256 toCharity = 0;
		bool success;

		if (listedItem.charity != address(0)) {
			toCharity = msg.value * listedItem.percent / 100;
			(success, ) = payable(listedItem.charity).call{ value: toCharity }("");
			require(success, "Transfer failed to charity");
		}

		(success, ) = payable(listedItem.seller).call{ value: msg.value - toCharity }("");
		require(success, "Transfer failed to seller");

		IERC721(_collection).safeTransferFrom(listedItem.seller, _msgSender(), tokenId);
		delete s_listings[_collection][tokenId];

		emit ItemBought(_collection, _msgSender(), tokenId, listedItem.price);
	}

	function bidForAuction(address _collection, uint256 tokenId, uint256 bidPrice)
		external
		isListed(_collection, tokenId)
		isListedForAuction(_collection, tokenId)
		nonReentrant
	{
		Listing memory listedItem = s_listings[_collection][tokenId];
		require(block.timestamp < listedItem.endAuctionTimestamp, "This auction has already finished");
		require(bidPrice > 0, "Insufficient bid price");
		require(paymentToken.allowance(_msgSender(), address(this)) >= bidPrice, "Should approve first on paymentToken");
		require(paymentToken.balanceOf(_msgSender()) >= bidPrice, "Insufficient paymentToken balance");

		BiddingForAuction memory bidding = BiddingForAuction(_msgSender(), bidPrice, block.timestamp);
		BiddingForAuction[] memory _biddings = s_biddings[_collection][tokenId];
		bool bUpdated = false;

		// Replace the last sender's bid with this new one
		for (uint i = 0; i < _biddings.length; i ++) {
			if (_biddings[i].bider == _msgSender()) {
				s_biddings[_collection][tokenId][i] = bidding;
				bUpdated = true;
				break;
			}
		}

		if (!bUpdated) {
			s_biddings[_collection][tokenId].push(bidding);
		}

		emit BiddedForAuction(_collection, _msgSender(), tokenId, bidPrice);
	}

	function cancelBidding(address _collection, uint256 tokenId)
		public
		isListed(_collection, tokenId)
		isListedForAuction(_collection, tokenId)
	{
		BiddingForAuction[] memory _biddings = s_biddings[_collection][tokenId];
		for (uint i = 0; i < _biddings.length; i ++) {
			if (_biddings[i].bider == _msgSender()) {
				s_biddings[_collection][tokenId][i] = _biddings[_biddings.length - 1];
				s_biddings[_collection][tokenId].pop();
				break;
			}
		}

		emit BidCanceled(_collection, _msgSender(), tokenId);
	}

	function finishAuction(address _collection, uint256 tokenId)
		external
		isListed(_collection, tokenId)
		isListedForAuction(_collection, tokenId)
		isTokenOwner(_collection, tokenId)
	{
		require(s_listings[_collection][tokenId].endAuctionTimestamp < block.timestamp, "This auction isn't ended yet");

		BiddingForAuction[] memory _biddings = s_biddings[_collection][tokenId];
		uint256 highestBidIndex = 0;

		if (_biddings.length > 0) {
			for (uint i = 1; i < _biddings.length; i ++) {
				if (_biddings[i].bidPrice > _biddings[highestBidIndex].bidPrice) {
					highestBidIndex = i;
				} else if (_biddings[i].bidPrice == _biddings[highestBidIndex].bidPrice && _biddings[i].bidTimestamp < _biddings[highestBidIndex].bidTimestamp) {
					highestBidIndex = i;
				}
			}

			BiddingForAuction memory highestBid = _biddings[highestBidIndex];
			Listing memory listedItem = s_listings[_collection][tokenId];
			uint256 toCharity = 0;

			require(paymentToken.allowance(highestBid.bider, address(this)) >= highestBid.bidPrice, "Not approved for transferring paymentToken from bider");
			require(paymentToken.balanceOf(_msgSender()) >= highestBid.bidPrice, "Insufficient paymentToken balance");

			if (listedItem.charity != address(0)) {
				toCharity = highestBid.bidPrice * listedItem.percent / 100;
				paymentToken.transferFrom(highestBid.bider, listedItem.charity, toCharity);
			}

			paymentToken.transferFrom(highestBid.bider, listedItem.seller, highestBid.bidPrice - toCharity);

			IERC721(_collection).transferFrom(listedItem.seller, highestBid.bider, tokenId);
			delete s_biddings[_collection][tokenId];
		}

		delete s_listings[_collection][tokenId];

		emit AuctionEnded(_collection, _msgSender(), tokenId);
	}

	function getListing(address _collection, uint256 tokenId) external view returns (Listing memory) {
		return s_listings[_collection][tokenId];
	}

	function getBidForAuction(address _collection, uint256 tokenId) external view returns (BiddingForAuction[] memory) {
		return s_biddings[_collection][tokenId];
	}

	function uploadCollection(address _collection) external {
		require(!collectionItem[_collection].isExisted, "Collection is already existed");
		
		collectionItem[_collection] = Collection(collections.length, true);
		collections.push(_collection);

		emit UploadedNewCollection(_collection);
	}

	function withdraw(address to) external onlyOwner {
		require(to != address(0), "Invalid address");

		if (address(this).balance > 0) {
			payable(to).transfer(address(this).balance);
		}
	}

	receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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