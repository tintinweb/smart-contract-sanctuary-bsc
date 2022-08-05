// SPDX-License-Identifier: MIT
// COPIED and MODIFIED from:
// - DeFiRunners (url: https://github.com/DeFi-Runners/auctions)
// - Pancakeswap (url: https://github.com/pancakeswap/pancake-smart-contracts)

pragma solidity >=0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./abstractions/AbstractAuction.sol";
import "./abstractions/CollectionManagement.sol";
import "./abstractions/MultiAssetAuction.sol";
import "./abstractions/SendValueWithFallbackWithdraw.sol";
import "./abstractions/TaxAuction.sol";
import "./abstractions/TokenAcceptanceCheck.sol";
import "./interfaces/IReserveAuction.sol";
import "./interfaces/ITaxAuction.sol";

/**
 * @title ReserveAuction
 */
contract ReserveAuctionERC721V1 is
	IReserveAuction,
	AbstractAuction,
	CollectionManagement,
	MultiAssetAuction,
	TaxAuction,
	ERC721Holder,
	SendValueWithFallbackWithdraw,
	TokenAcceptanceCheck
{
	uint256 internal _index;

	mapping(uint256 => Auction) public auctions;
	mapping(address => uint256[]) public userAuctions;

	event AuctionCreated(uint256 indexed auctionId, uint256 tokenType);
	event AuctionStarted(uint256 indexed auctionId, uint256 timestamp);
	event AuctionEnded(
		uint256 indexed auctionId,
		address winner,
		uint256 highestBid
	);
	event AuctionClosed(
		uint256 indexed auctionId,
		address winner,
		uint256 highestBid
	);
	event AuctionCanceled(uint256 indexed auctionId);
	event BidPlaced(
		uint256 indexed auctionId,
		address indexed token,
		uint256 id,
		address bidder,
		uint256 bidPrice
	);
	event Received(address from, uint256 amount);

	receive() external payable {
		revert("Auction: don't accept direct ether bid");
	}

	fallback() external payable {
		if (msg.value != 0) {
			emit Received(_msgSender(), msg.value);
		}
	}

	/**
	 * @dev Creates new auction, and sets out
     * the details of the deal, like a {_token}, {_tokenId},
     * {_initialPrice} and {_initialDate}
     */
	function create(
		IERC721 _token,
		uint256 _tokenId,
		uint256 _initialPrice,
		uint256 _initialDate,
		Asset _paidIn,
		address _assetAddress,
		uint256 _timeframeId
	)
		external
		override
		onlyEnabledAsset(_assetAddress)
		returns (uint256 auctionId)
	{
		require(
			_collections[address(_token)].status == CollectionStatus.Open,
			"Collection: Not for trading"
		);
		require(_initialPrice != 0, "Auction: Initial price zero?");
		require(
			_initialPrice >= DEFAULT_FEE_DECIMAL,
			"Auction: Very low initial price DEFAULT_FEE_DECIMAL"
		);

		// check if seller can get back his ntf
		TokenAcceptanceCheck._checkOnERC721Received(
			address(this),
			_msgSender(),
			_tokenId,
			""
		);

		_token.safeTransferFrom(_msgSender(), address(this), _tokenId);

		_index++;
		auctionId = _index;

		Auction memory a;

		a.token.tokenType = TokenType.ERC721;
		a.token.addr = address(_token);
		a.token.id = _tokenId;
		a.initialPrice = _initialPrice;
		a.highest.bid = _initialPrice;
		a.timeframe = TIMEFRAMES[_timeframeId];

		if (_initialDate != 0) {
			if (_initialDate <= block.timestamp) {
				_initialDate = block.timestamp;
			}
		} else {
			_initialDate = block.timestamp;
		}

		a.initialDate = _initialDate;
		a.seller = _msgSender();
		a.paidIn = _paidIn;
		a.assetAddress = _assetAddress;

		auctions[auctionId] = a;

		userAuctions[_msgSender()].push(auctionId);

		emit AuctionCreated(auctionId, uint256(TokenType.ERC721));
	}

	function update(
		uint256 _auctionId,
		uint256 _initialPrice,
		uint256 _initialDate,
		AbstractAuction.Asset _paidIn,
		address _assetAddress,
		uint256 _timeframeId
	)
		external
		onlyEnabledAsset(_assetAddress)
	{
		require(getStatus(_auctionId) <= Status.INITIATED, "Auction: update forbidden");

		Auction memory a = auctions[_auctionId];

		require(a.seller == msg.sender, "Auction: no permission");
		require(_initialPrice != 0, "Auction: Initial price zero?");
		require(
			_initialPrice >= DEFAULT_FEE_DECIMAL,
			"Auction: Very low initial price DEFAULT_FEE_DECIMAL"
		);

		a.initialPrice = _initialPrice;
		a.initialDate = _initialDate;
		a.paidIn = _paidIn;
		a.assetAddress = _assetAddress;
		a.timeframe = TIMEFRAMES[_timeframeId];

		auctions[_auctionId] = a;
	}

	function totalBids(uint256 _auctionId)
		external
		view
		override
		returns (uint256)
	{
		return auctions[_auctionId].bids;
	}

	function totalAuctions()
		external
		view
		override
		returns (uint256 index)
	{
		index = _index;
	}

	function userOpenedAuctionsLength(address _user)
		external
		view
		override
		returns (uint256 index)
	{
		index = userAuctions[_user].length;
	}

	/**
	 * @dev Returns bidding end date. If zero, auction is not started.
     */
	function closedAt(uint256 auctionId)
		external
		view
		override
		returns (uint256 timestamp)
	{
		Auction memory auction = auctions[auctionId];
		if (auction.biddingStart == 0) {
			timestamp = 0;
		} else {
			timestamp = auction.biddingStart + auction.timeframe;
		}
	}

	/**
	 * @dev Returns current auction status.
     */
	function getStatus(uint256 auctionId)
		public
		view
		override
		returns (Status status)
	{
		require(
			auctionId <= _index && auctionId != 0,
			"Auction: auction not exist"
		);

		Auction memory a = auctions[auctionId];

		if (block.timestamp < a.initialDate) {
			return Status.AWAITING;
		}

		if (a.bids == 0) {
			if (a.state.canceled) {
				status = Status.CANCELLED;
			} else {
				status = Status.INITIATED;
			}
		} else {
			if (block.timestamp > ((a.biddingStart == 0) ? 0 : a.biddingStart + a.timeframe)) {
				if (a.state.ended) {
					status = Status.CLOSED;
				} else {
					status = Status.ENDED;
				}
			} else {
				status = Status.IN_PROGRESS;
			}
		}
	}

	/**
	 * @dev Make bid {msg.value} to contract.
     */
	function placeBid(uint256 auctionId)
		external
		payable
		override
		nonReentrant
	{
		Status status = getStatus(auctionId);

		require(
			status == Status.IN_PROGRESS || status == Status.INITIATED,
			"Auction: bet not available"
		);

		Auction storage a = auctions[auctionId];

		require(
			_msgSender() != a.highest.bidder,
			"Auction: attempt to outbid your bet"
		);
		require(
			msg.value >= a.initialPrice,
			"Auction: lower then initial price bid"
		);

		if (a.highest.bid != a.initialPrice) {
			require(msg.value > a.highest.bid, "Auction: not enough to outbid");
		}

		if (a.bids == 0) {
			a.biddingStart = block.timestamp;
			emit AuctionStarted(auctionId, a.biddingStart);
		}

		a.previous.bid = a.highest.bid;
		a.previous.bidder = a.highest.bidder;

		// update bid
		a.highest.bid = msg.value;
		a.highest.bidder = _msgSender();

		a.bids += 1;

		if (a.previous.bidder != address(0)) {
			_withdrawAsset(
				a.assetAddress,
				a.previous.bidder,
				a.previous.bid,
				a.paidIn
			);
		}

		emit BidPlaced(
			auctionId,
			a.token.addr,
			a.token.id,
			_msgSender(),
			msg.value
		);
	}

	/**
	 * @dev Make bid in token {amount} to contract.
     */
	function placeBidInToken(uint256 auctionId, uint256 amount)
		external
		override
		nonReentrant
	{
		Status status = getStatus(auctionId);

		require(
			status == Status.IN_PROGRESS || status == Status.INITIATED,
			"Auction: bet not available"
		);

		Auction storage a = auctions[auctionId];

		require(
			_msgSender() != a.highest.bidder,
			"Auction: attempt to outbid your bet"
		);
		require(
			amount >= a.initialPrice,
			"Auction: lower then initial price bid"
		);

		if (a.highest.bid != a.initialPrice) {
			require(amount > a.highest.bid, "Auction: not enough to outbid");
		}

		require(
			IERC20(a.assetAddress).allowance(_msgSender(), address(this)) >=
			amount,
			"Auction: not allowed ERC20 token balance"
		);

		IERC20(a.assetAddress).transferFrom(
			_msgSender(),
			address(this),
			amount
		);

		if (a.bids == 0) {
			a.biddingStart = block.timestamp;
			emit AuctionStarted(auctionId, a.biddingStart);
		}

		a.previous.bid = a.highest.bid;
		a.previous.bidder = a.highest.bidder;

		// update bid
		a.highest.bid = amount;
		a.highest.bidder = _msgSender();

		a.bids += 1;

		if (a.previous.bidder != address(0)) {
			_withdrawAsset(
				a.assetAddress,
				a.previous.bidder,
				a.previous.bid,
				a.paidIn
			);
		}

		emit BidPlaced(
			auctionId,
			a.token.addr,
			a.token.id,
			_msgSender(),
			amount
		);
	}

	/**
	 * @dev End the auction and send the highest bid
     * to the beneficiary.
     */
	function close(uint256 auctionId) external nonReentrant {
		require(
			getStatus(auctionId) == Status.ENDED,
			"Auction: close impossible"
		);

		Auction storage a = auctions[auctionId];
		a.state.ended = true;

		// Calculate the net price (collected by seller), trading fee (collected by treasury), creator fee (collected by creator)
		(uint256 netPrice, uint256 tradingFee, uint256 creatorFee) = _calculatePriceAndFeesForCollection(
			a.token.addr,
			a.highest.bid
		);

		// Update pending revenues for treasury/creator (if any!)
		if (creatorFee != 0) {
			if (a.paidIn == Asset.COIN) {
				pendingWithdrawals[_collections[a.token.addr].creatorAddress] += creatorFee;
			} else {
				pendingTokenWithdrawals[_collections[a.token.addr].creatorAddress][a.assetAddress] += creatorFee;
			}
		}

		// Update trading fee if not equal to 0
		if (tradingFee != 0) {
			if (a.paidIn == Asset.COIN) {
				pendingWithdrawals[treasury] += tradingFee;
			} else {
				pendingTokenWithdrawals[treasury][a.assetAddress] += tradingFee;
			}
		}

		// seller reward
		_withdrawAsset(a.assetAddress, a.seller, netPrice, a.paidIn);

		// buyer reward
		_withdrawNFT721(a.token.addr, a.highest.bidder, a.token.id);

		emit AuctionEnded(auctionId, a.highest.bidder, a.highest.bid);
	}

	/**
	 * @dev Cancel current auction, at any time before {Status.IN_PROGRESS}.
     */
	function cancel(uint256 auctionId) external override {
		require(
			getStatus(auctionId) <= Status.INITIATED,
			"Auction: cancel impossible"
		);

		Auction storage a = auctions[auctionId];

		require(_msgSender() == a.seller, "Auction: not seller");

		a.state.canceled = true;

		// return NFT back to beneficiary
		_withdrawNFT721(a.token.addr, a.seller, a.token.id);

		emit AuctionCanceled(auctionId);
	}

	/**
	 * @dev Helps to count next minimum bid price by {auctionId}.
     */
	function countNextMinBidPrice(uint256 auctionId)
		external
		view
		returns (uint256 price)
	{
		Auction memory a = auctions[auctionId];
		if (a.highest.bid == a.initialPrice && a.highest.bidder != address(0)) {
			price = a.initialPrice;
		} else {
			price = a.highest.bid + 1;
		}
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
		if (_collections[collection].status != CollectionStatus.Open) {
			return (0, 0, 0);
		}

		return (_calculatePriceAndFeesForCollection(collection, price));
	}

	/**
	 * @dev Withdraw {_amount} ETH to {_beneficiary}.
     */
	function _withdrawAsset(
		address _token,
		address _beneficiary,
		uint256 _amount,
		Asset _paidIn
	) internal {
		if (_paidIn == Asset.COIN) {
			require(
				address(this).balance >= _amount,
				"Auction: not enough balance"
			);

			_sendValueWithFallbackWithdraw(payable(_beneficiary), _amount);
		} else {
			require(
				IERC20(_token).balanceOf(address(this)) >= _amount,
				"Auction: not enough token balance"
			);

			IERC20(_token).transferFrom(address(this), _beneficiary, _amount);
		}
	}

	/**
	 * @dev Withdraw NFT {_token} to {_beneficiary}.
     */
	function _withdrawNFT721(
		address _token,
		address _beneficiary,
		uint256 _tokenId
	) internal {
		IERC721(_token).safeTransferFrom(address(this), _beneficiary, _tokenId);
	}

	/**
     * @notice Calculate price and associated fees for a collection
     * @param _collection: address of the collection
     * @param _askPrice: listed price
     */
	function _calculatePriceAndFeesForCollection(address _collection, uint256 _askPrice)
		internal
		view
		returns (
			uint256 netPrice,
			uint256 tradingFee,
			uint256 creatorFee
		)
	{
		Collection memory collection = _collections[_collection];

		tradingFee = (_askPrice * collection.tradingFee) / 100_000;
		creatorFee = (_askPrice * collection.creatorFee) / 100_000;

		netPrice = _askPrice - tradingFee - creatorFee;

		return (netPrice, tradingFee, creatorFee);
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

pragma solidity >=0.8.0 <1.0.0;

abstract contract AbstractAuction {
    enum Asset {
        COIN,
        ERC20
    }

    enum Status {
        AWAITING,
        INITIATED,
        IN_PROGRESS, // after first bid
        ENDED, // after 24h
        CLOSED, // after withdraw
        CANCELLED
    }

    enum TokenType {
        ERC721,
        ERC1155
    }

    // NFT details
    struct Token {
        TokenType tokenType;
        address addr;
        uint256 id;
        uint256 amount;
    }

    struct AuctionState {
        bool canceled;
        bool ended;
    }

    struct Bid {
        address bidder;
        uint256 bid;
    }

    struct Auction {
        // auction initial data
        uint256 initialDate;
        uint256 biddingStart;
        uint256 initialPrice;
        address seller;
        AuctionState state;
        Bid highest;
        Bid previous;
        uint256 bids;
        Token token;
        Asset paidIn;
        address assetAddress;
        uint256 timeframe;
    }

    uint256 constant DEFAULT_FEE_DECIMAL = 10_000;
    uint256[4] TIMEFRAMES;

    constructor() {
        // [6 hours, 12 hours, 1 days, 2 days];
        TIMEFRAMES[0] = 6 hours;
        TIMEFRAMES[1] = 12 hours;
        TIMEFRAMES[2] = 1 days;
        TIMEFRAMES[3] = 2 days;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

abstract contract CollectionManagement is Ownable {
	using EnumerableSet for EnumerableSet.AddressSet;

	enum Standard {
		ERC721,
		ERC1155
	}

	enum CollectionStatus {
		Close,
		Open
	}

	struct Collection {
		CollectionStatus status; // status of the collection
		address creatorAddress; // address of the creator
		uint256 tradingFee; // trading fee (100 = 1%, 500 = 5%, 5 = 0.05%)
		uint256 creatorFee; // creator fee (100 = 1%, 500 = 5%, 5 = 0.05%)
	}

	uint256 constant TOTAL_MAX_FEE = 50_000; // 50%

	EnumerableSet.AddressSet internal _collectionAddressSet;
	mapping(address => Collection) internal _collections; // Details about the collections

	// New collection is added
	event CollectionNew(
		address indexed collection,
		address indexed creator,
		uint256 tradingFee,
		uint256 creatorFee
	);

	// Existing collection is updated
	event CollectionUpdate(
		address indexed collection,
		address indexed creator,
		uint256 tradingFee,
		uint256 creatorFee
	);

	// Collection is closed for trading and new listings
	event CollectionClose(address indexed collection);

	function addCollection(
		address _collection,
		Standard _standard,
		address _creator,
		uint256 _tradingFee,
		uint256 _creatorFee
	) external onlyOwner {
		require(!_collectionAddressSet.contains(_collection), "Operations: Collection already listed");

		if (_standard == Standard.ERC721) {
			require(IERC721(_collection).supportsInterface(type(IERC721).interfaceId), "Operations: Not ERC721");
		} else {
			require(IERC721(_collection).supportsInterface(type(IERC1155).interfaceId), "Operations: Not ERC1155");
		}

		require(
			(_creatorFee == 0 && _creator == address(0)) ||
			(_creatorFee != 0 && _creator != address(0)),
			"Operations: Creator parameters incorrect"
		);

		require(_tradingFee + _creatorFee <= TOTAL_MAX_FEE, "Operations: Sum of fee must inferior to TOTAL_MAX_FEE");

		_collectionAddressSet.add(_collection);

		_collections[_collection] = Collection({
			status: CollectionStatus.Open,
			creatorAddress: _creator,
			tradingFee: _tradingFee,
			creatorFee: _creatorFee
		});

		emit CollectionNew(_collection, _creator, _tradingFee, _creatorFee);
	}

	function closeCollectionForTradingAndListing(address _collection) external onlyOwner {
		require(_collectionAddressSet.contains(_collection), "Operations: Collection not listed");

		_collections[_collection].status = CollectionStatus.Close;
		_collectionAddressSet.remove(_collection);

		emit CollectionClose(_collection);
	}

	function modifyCollection(
		address _collection,
		address _creator,
		uint256 _tradingFee,
		uint256 _creatorFee
	) external onlyOwner {
		require(_collectionAddressSet.contains(_collection), "Operations: Collection not listed");

		require(
			(_creatorFee == 0 && _creator == address(0)) || (_creatorFee != 0 && _creator != address(0)),
			"Operations: Creator parameters incorrect"
		);

		require(_tradingFee + _creatorFee <= TOTAL_MAX_FEE, "Operations: Sum of fee must inferior to TOTAL_MAX_FEE");

		_collections[_collection] = Collection({
			status: CollectionStatus.Open,
			creatorAddress: _creator,
			tradingFee: _tradingFee,
			creatorFee: _creatorFee
		});

		emit CollectionUpdate(_collection, _creator, _tradingFee, _creatorFee);
	}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./AbstractAuction.sol";

abstract contract MultiAssetAuction is Ownable {
    struct AssetRegistry {
        AbstractAuction.Asset assetType;
        bool enabled;
    }

    mapping(address => AssetRegistry) public assetRegistry;

    event AssetEnabled(address assetAddress, AbstractAuction.Asset assetType);
    event AssetDisabled(address assetAddress, AbstractAuction.Asset assetType);

    constructor() {
        _enableAsset(address(0), AbstractAuction.Asset.COIN, true);
    }

    function enableAsset(
        address _addr,
        AbstractAuction.Asset _type,
        bool _enable
    ) external onlyOwner {
        _enableAsset(_addr, _type, _enable);
    }

    function assetStatus(address _addr) public view returns (bool enabled) {
        enabled = assetRegistry[_addr].enabled;
    }

    function _enableAsset(
        address _addr,
        AbstractAuction.Asset _type,
        bool _enable
    ) private {
        assetRegistry[_addr].assetType = _type;
        assetRegistry[_addr].enabled = _enable;
        if (_enable) {
            emit AssetEnabled(_addr, _type);
        } else {
            emit AssetDisabled(_addr, _type);
        }
    }

    modifier onlyEnabledAsset(address _addr) {
        require(assetStatus(_addr), "MultiAsset: asset disabled");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @notice Attempt to send ETH and if the transfer fails or runs out of gas, store the balance
 * for future withdrawal instead.
 */
abstract contract SendValueWithFallbackWithdraw is ReentrancyGuard {
    using Address for address payable;
    using SafeMath for uint256;

    mapping(address => uint256) internal pendingWithdrawals;

    // account -> token -> amount
    mapping(address => mapping(address => uint256)) internal pendingTokenWithdrawals;

    event Withdrawal(address indexed user, uint256 indexed amount);
    event WithdrawalToken(address indexed user, address indexed token, uint256 indexed amount);
    event WithdrawPending(address indexed user, uint256 indexed amount);

    /**
     * @notice Returns how much funds are available for manual withdraw due to failed transfers.
     */
    function getPendingWithdrawal(address user) public view returns (uint256) {
        return pendingWithdrawals[user];
    }

    /**
     * @notice Returns how much funds are available for manual withdraw due to failed transfers.
     */
    function getPendingTokenWithdrawal(address user, address token) public view returns (uint256) {
        return pendingTokenWithdrawals[user][token];
    }

    /**
     * @notice Allows a user to manually withdraw funds which originally failed to transfer.
     */
    function withdraw() public nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds are pending withdrawal");
        pendingWithdrawals[msg.sender] = 0;
        (bool success, ) = msg.sender.call{ value: amount, gas: 21000 }("");
        require(success, "Ether withdraw failed");
        emit Withdrawal(msg.sender, amount);
    }

    /**
     * @notice Allows a user to manually withdraw funds which originally failed to transfer.
     */
    function withdrawTo(address _to) public nonReentrant {
        uint256 balance = pendingWithdrawals[msg.sender];
        require(balance > 0, "No funds are pending withdrawal");
        pendingWithdrawals[msg.sender] -= balance;
        (bool success, ) = _to.call{ value: balance, gas: 21000 }("");
        require(success, "Ether withdraw failed");
        emit Withdrawal(_to, balance);
    }

    /**
     * @notice Allows a user to manually withdraw funds which originally failed to transfer.
     */
    function withdrawTokensTo(address[] calldata _tokens, address _to) external {
        for (uint i = 0; i < _tokens.length; i++) {
            uint balance = pendingTokenWithdrawals[msg.sender][_tokens[i]];
            if (balance > 0) {
                pendingTokenWithdrawals[msg.sender][_tokens[i]] -= balance;
                SafeERC20.safeTransfer(IERC20(_tokens[i]), _to, balance);
                emit WithdrawalToken(_to, _tokens[i], balance);
            }
        }
    }

    function _sendValueWithFallbackWithdraw(
        address payable user,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }

        // Cap the gas to prevent consuming all available gas to block a tx from completing successfully
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = user.call{ value: amount, gas: 21000 }("");

        if (!success) {
            // Record failed sends for a withdrawal later
            // Transfers could fail if sent to a multisig with non-trivial receiver logic
            pendingWithdrawals[user] += amount;

            emit WithdrawPending(user, amount);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ITaxAuction.sol";

abstract contract TaxAuction is ITaxAuction, Ownable {
    address public override treasury;

    event FeeToSet(address dest);

    function setFeeTo(address _dest) external override onlyOwner {
        require(_dest != address(0), "Not fee to zero");
        treasury = _dest;
        emit FeeToSet(_dest);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

abstract contract TokenAcceptanceCheck is Context {
    /**
     * @dev Copied {ERC721._checkOnERC721Received}
     * from "openzeppelin/contracts/token/ERC721/ERC721.sol";
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        if (Address.isContract(to)) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 response) {
                if (response != IERC721Receiver(to).onERC721Received.selector) {
                    revert("ERC721: ERC721Receiver rejected tokens");
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * @dev Copied {ERC1155._doSafeTransferAcceptanceCheck}
     * from "openzeppelin/contracts/token/ERC1155/ERC1155.sol";
     */
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        if (Address.isContract(to)) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver(to).onERC1155Received.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../abstractions/AbstractAuction.sol";

interface IReserveAuction {
    // @dev Create new auction with ERC721
    // `_token` - erc721 token address
    // `_tokenId` - erc721 token id
    // `_initialPrice` - initial bid price
    // `_initialDate` - auction active from date
    // `_paidIn` - Pain in, if 0-COIN, 1-ERC20 token
    // `_assetAddress` - if `_paidIn` == 0 => address(0),
    //                   if `_paidIn` == 1 => address of ERC20 token
    function create(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _initialDate,
        AbstractAuction.Asset _paidIn,
        address _assetAddress,
        uint256 _timeframeId
    ) external returns (uint256 auctionId);

    // @dev Update price and initial date, assets
    function update(
        uint256 _auctionId,
        uint256 _initialPrice,
        uint256 _initialDate,
        AbstractAuction.Asset _paidIn,
        address _assetAddress,
        uint256 _timeframeId
    ) external;

    // @dev Cancel auction.
    function cancel(uint256 auctionId) external;

    // @dev Close ended sale, and get all rewards.
    function close(uint256 auctionId) external;

    // @dev Place bid for COIN accept auctions
    // `auctionId` - auction id
    function placeBid(uint256 auctionId) external payable;

    // @dev Place bid for ERC20 tokens accept auctions
    // `auctionId` - auction id
    // `amount` - tokens amount
    function placeBidInToken(uint256 auctionId, uint256 amount) external;

    // @dev Get auction status
    // `auctionId` - auction id
    //
    // Returns `status`, where
    // 0 - AWAITING,
    // 1 - INITIATED,
    // 2 - IN_PROGRESS, // after first bid
    // 3 - ENDED, // after 24h
    // 4 - CLOSED, // after withdraw
    // 5 - CANCELLED
    function getStatus(uint256 auctionId)
        external
        view
        returns (AbstractAuction.Status status);

    // @dev Get auction end timestamp
    function closedAt(uint256 auctionId) external view returns (uint256 timestamp);

    // @dev Get amount auctions issued by `account` address
    function userOpenedAuctionsLength(address account) external view returns (uint256 index);

    // @dev Get amount `bids` by `auctionId`
    function totalBids(uint256 auctionId) external view returns (uint256 bids);

    // @dev Returns last auction id
    function totalAuctions() external view returns (uint256 index);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <1.0.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ITaxAuction {
    function treasury() external view returns (address);

    // dest should not be zero address. if dest is contract, it should implement IERC165
    function setFeeTo(address dest) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}