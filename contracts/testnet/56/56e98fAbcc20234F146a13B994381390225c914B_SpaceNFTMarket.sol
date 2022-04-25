/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
        _setOwner(_msgSender());
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
         require(_msgSender() == _owner, "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


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


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}


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


    event URI(string value, uint256 indexed id);


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



    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }


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


interface ISpaceNFT {
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
}


interface IERC1155Supply {
    function totalSupply(uint256 id) external view returns (uint256);
}


// Order Type: 0 - buy order, 1 - sell order
// item is nft

contract SpaceNFTMarket is ReentrancyGuard, Ownable, ERC1155Holder {

    // Mapping from token Id to (from buy order creator address in market to buy orders)
    mapping(uint => mapping(address => MarketOrder)) private _buyOrders;
    // Mapping from token Id to (from sell order creator address in market to sell orders)
    mapping(uint => mapping(address => MarketOrder)) private _sellOrders;

    // Mapping from token Id to array with buyers addresses
    mapping(uint => address[]) private _buyers;
    // Mapping from token Id to array with sellers addresses
    mapping(uint => address[]) private _sellers;

    // Mapping from user address to count of his buy orders
    mapping(address => uint) private _myBuyOrdersCount;
    // Mapping from user address to count of his sell orders
    mapping(address => uint) private _mySellOrdersCount;

    uint public maxTokenId; // Max token id in erc1155 _spacenft contract

    address payable public feeReceiver;
    // Owner of this contract must be the same as owner of the nft contract
    address public spacenft;

    constructor(address _feeReceiver, address _spacenft) {
        feeReceiver = payable(_feeReceiver);
        spacenft = payable(_spacenft);
    }

    enum ActiveStatus {
        Banned,
		Active,
		Sold,
		Cancelled
	}

    struct MarketOrder {
        ActiveStatus status;
        address itemOwner; // order id
        address nftContract;
        uint tokenId;
        uint tokenAmount;
        uint price;
    }


    // ---------------------- EVENTS ----------------------


    event ItemCreated(
        address itemOwner,
        address indexed nftContract,
        uint indexed tokenId,
        uint indexed tokenAmount
    );

    event SellOrderListed(
        address itemSeller, // order id
        address indexed nftContract,
        uint indexed tokenId,
        uint indexed tokenAmount,
        uint price
    );

    event BuyOrderListed(
        address itemBuyer, // order id
        address indexed nftContract,
        uint indexed tokenId,
        uint indexed tokenAmount,
        uint offeredPrice
    );

	event ItemSold(
		address oldItemOwner, // order id
		address newItemOwner,
		address indexed nftContract,
		uint indexed tokenId,
        uint indexed tokenAmount,
		uint price
	);

	event Canceled(
		address orderCreator, // order id
        uint orderType // 0 - buy order, 1 - sell order
	);

    event FeeReceiverOwnershipTransferred(
        address payable indexed previousReceiver,
        address payable indexed newReceiver
    );


    // ---------------------- MODIFIERS ----------------------


    modifier tokenIdExists(uint tokenId) {
        require(tokenId <= maxTokenId, "Market: Non-existent token Id");
        _;
    }

    modifier tokenAmountIsNotZero(uint tokenAmount) {
        require(tokenAmount > 0, "Market: Token amount is zero");
        _;
    }


    // ---------------------- WRITE FUNCTIONS ----------------------


    // mint nft with main nft contract
    // tokenId must go up: 0, 1, 2, 3, 4, etc.
    function createMarketItem(
        uint tokenId,
        uint tokenAmount
    )
        public onlyOwner
        tokenAmountIsNotZero(tokenAmount)
    {
        ISpaceNFT(spacenft).mint(owner(), tokenId, tokenAmount, "");

        if(tokenId > maxTokenId) {
            maxTokenId = tokenId;
        }

        emit ItemCreated(
            owner(),
            spacenft,
            tokenId,
            tokenAmount
        );
    }

    /**
    * @param offeredPrice must be in wei, for example, 0.01 bnb:
    *  offeredPrice = 0.01 * 10 ** 18 == 10000000000000000
    */
    function listBuyOrder(
        uint tokenId,
        uint tokenAmount,
        uint offeredPrice //price per one nft
    )
        public payable nonReentrant
        tokenIdExists(tokenId)
        tokenAmountIsNotZero(tokenAmount)
    {
        address buyOrderCreator = _msgSender();

        require(
            _buyOrders[tokenId][buyOrderCreator].status != ActiveStatus.Active,
            "Market: ListBuyOrder: Buy order from this buyer already exists"
        );
        require(offeredPrice > 0, "Market: ListBuyOrder: Offered price must be at least 1 wei");

        uint totalPrice = offeredPrice * tokenAmount;
        require(
            msg.value >= totalPrice,
            "Market: ListBuyOrder: msg.value must be equal to or greater then offered price * amount"
        );

        uint totalSupply = IERC1155Supply(spacenft).totalSupply(tokenId);
        require(tokenAmount <= totalSupply, "Market: ListBuyOrder: Token amount exceeds possible");

        _buyers[tokenId].push(buyOrderCreator);
        _myBuyOrdersCount[buyOrderCreator] += 1;

        _buyOrders[tokenId][buyOrderCreator] = MarketOrder(
            ActiveStatus.Active,
            buyOrderCreator, // future item owner
            spacenft,
            tokenId,
            tokenAmount,
            offeredPrice
        );

        emit BuyOrderListed(
            buyOrderCreator,
            spacenft,
            tokenId,
            tokenAmount,
            offeredPrice
        );
    }

    /**
    * @param price must be in wei, for example, 0.01 bnb:
    *  price = 0.01 * 10 ** 18 == 10000000000000000
    *
    *  first must be call setApprovalForAll(address operator, bool approved) from msg.sender (user account)
    *  in erc1155 contract
    */
    function listSellOrder(
        uint tokenId,
        uint tokenAmount,
        uint price
    )
        public nonReentrant
        tokenIdExists(tokenId)
        tokenAmountIsNotZero(tokenAmount)
    {
        address sellOrderCreator = _msgSender();

        require(
            _sellOrders[tokenId][sellOrderCreator].status != ActiveStatus.Active,
            "Market: ListSellOrder: Sell order from this seller already exists"
        );
        require(
            IERC1155(spacenft).balanceOf(sellOrderCreator, tokenId) >= tokenAmount,
            "Market: ListSellOrder: Token amount must be equal balance"
        );
        require(price > 0, "Market: ListSellOrder: Price must be at least 1 wei");

        IERC1155(spacenft)
            .safeTransferFrom(sellOrderCreator, address(this), tokenId, tokenAmount, "");

        _sellers[tokenId].push(sellOrderCreator);
        _mySellOrdersCount[sellOrderCreator] += 1;

        _sellOrders[tokenId][sellOrderCreator] = MarketOrder(
            ActiveStatus.Active,
            sellOrderCreator,
            spacenft,
            tokenId,
            tokenAmount,
            price
        );

        emit SellOrderListed(
            sellOrderCreator,
            spacenft,
            tokenId,
            tokenAmount,
            price
        );
    }

    /*
    * @@param msg.value must be in wei, for example, 0.01 bnb:
    *   msg.value = 0.01 * 10 ** 18 == 10000000000000000
    */
    function buyMarketItem(
        uint tokenId,
        address sellOrderCreator,
        uint tokenAmount
    )
        public payable nonReentrant
        tokenIdExists(tokenId)
        tokenAmountIsNotZero(tokenAmount)
    {
		MarketOrder storage sellOrder = _sellOrders[tokenId][sellOrderCreator];

        address buyer = _msgSender();

		require(buyer != sellOrder.itemOwner, "Market: BuyMarketItem: Buyer cannot be seller");
		require(sellOrder.status == ActiveStatus.Active, "Market: BuyMarketItem: Sell Order is not active");

		require(tokenAmount <= sellOrder.tokenAmount, "Market: BuyMarketItem: Token amount exceeds possible");

        uint totalPrice = sellOrder.price * tokenAmount;
		require(msg.value >= totalPrice, "Market: BuyMarketItem: Insufficient payment");

        uint fee = totalPrice * 1/100; // 1% for tx in BNB

        payable(feeReceiver).transfer(fee);
		payable(sellOrder.itemOwner).transfer(totalPrice - fee);

		IERC1155(spacenft) // (sellOrder.nftAddress)
            .safeTransferFrom(address(this), buyer, sellOrder.tokenId, tokenAmount, "");

        sellOrder.tokenAmount -= tokenAmount;

		emit ItemSold(
            sellOrder.itemOwner,
			buyer,
			spacenft,
			sellOrder.tokenId,
            tokenAmount,
			sellOrder.price
		);

        if (sellOrder.tokenAmount == 0) {
            _mySellOrdersCount[sellOrder.itemOwner] -= 1;

		    sellOrder.status = ActiveStatus.Sold;
            sellOrder.itemOwner = address(0);
            sellOrder.nftContract = address(0);
            sellOrder.tokenId = 0;
            sellOrder.tokenAmount = 0;
            sellOrder.price = 0;
        }

	}

    function sellMarketItem(
        uint tokenId,
        address buyOrderCreator,
        uint tokenAmount
    )
        public nonReentrant
        tokenIdExists(tokenId)
        tokenAmountIsNotZero(tokenAmount)
    {
		MarketOrder storage buyOrder = _buyOrders[tokenId][buyOrderCreator];

        address seller = _msgSender();

        require(
            IERC1155(spacenft).balanceOf(seller, tokenId) >= tokenAmount,
            "Market: SellMarketItem: Seller balance is less than the specified number of tokens"
        );
		require(seller != buyOrder.itemOwner, "Market: SellMarketItem: Seller cannot be buyer");
		require(buyOrder.status == ActiveStatus.Active, "Market: SellMarketItem: Sell Order is not active");

		require(tokenAmount <= buyOrder.tokenAmount, "Market: SellMarketItem: Token amount exceeds possible");

        uint totalPrice = buyOrder.price * tokenAmount;
        uint fee = totalPrice * 1/100; // 1% for tx in BNB

        (bool success, ) = payable(seller).call{value: totalPrice - fee}("");
        require(success, "Market: SellMarketItem: Failed to send BNB to Seller");
        (bool successs, ) = feeReceiver.call{value: fee}("");
        require(successs, "Market: SellMarketItem: Failed to send fee (BNB)");

        IERC1155(spacenft) // (buyOrder.nftAddress)
            .safeTransferFrom(seller, buyOrder.itemOwner, buyOrder.tokenId, tokenAmount, "");

        buyOrder.tokenAmount -= tokenAmount;

        emit ItemSold(
            seller,
            buyOrder.itemOwner,
			spacenft,
			buyOrder.tokenId,
            tokenAmount,
			buyOrder.price
		);

        if (buyOrder.tokenAmount == 0) {
            _myBuyOrdersCount[buyOrder.itemOwner] -= 1;

		    buyOrder.status = ActiveStatus.Sold;
            buyOrder.itemOwner = address(0);
            buyOrder.nftContract = address(0);
            buyOrder.tokenId = 0;
            buyOrder.tokenAmount = 0;
            buyOrder.price = 0;
        }

	}

    // Cancel orders
	function cancelBuyOrder(
        uint tokenId
    )
        public nonReentrant
        tokenIdExists(tokenId)
    {
        address buyOrderCreator = _msgSender();
        MarketOrder storage buyOrder = _buyOrders[tokenId][buyOrderCreator];

		require(_msgSender() == buyOrder.itemOwner, "Market: CancelBuyOrder: Only item owner can cancel order");
		require(buyOrder.status == ActiveStatus.Active, "Market: CancelBuyOrder: Order is not active");

        (bool successs, ) = payable(buyOrder.itemOwner).call{value: buyOrder.tokenAmount * buyOrder.price}("");
        require(successs, "Market: CancelBuyOrder: Failed to send BNB to order creator");

        _myBuyOrdersCount[buyOrder.itemOwner] -= 1;

        buyOrder.status = ActiveStatus.Cancelled;
        buyOrder.itemOwner = address(0);
        buyOrder.nftContract = address(0);
        buyOrder.tokenId = 0;
        buyOrder.tokenAmount = 0;
        buyOrder.price = 0;

		emit Canceled(buyOrderCreator, 0); // order type: 0 - buy, 1 - sell
	}

    function cancelSellOrder(
        uint tokenId
    )
        public nonReentrant
        tokenIdExists(tokenId)
    {
        address sellOrderCreator = _msgSender();
        MarketOrder storage sellOrder = _sellOrders[tokenId][sellOrderCreator];

		require(_msgSender() == sellOrder.itemOwner, "Market: CancelSellOrdere: Only item owner can cancel order");
		require(sellOrder.status == ActiveStatus.Active, "Market: CancelSellOrdere: Order is not active");

        IERC1155(spacenft)
            .safeTransferFrom(address(this), sellOrder.itemOwner, sellOrder.tokenId, sellOrder.tokenAmount, "");

        _mySellOrdersCount[sellOrder.itemOwner] -= 1;

        sellOrder.status = ActiveStatus.Cancelled;
        sellOrder.itemOwner = address(0);
        sellOrder.nftContract = address(0);
        sellOrder.tokenId = 0;
        sellOrder.tokenAmount = 0;
        sellOrder.price = 0;

		emit Canceled(sellOrderCreator, 1); // order type: 0 - buy, 1 - sell
	}

    function editPriceForMySellOrder(
        uint newPrice,
        uint tokenId
    )
        public onlyOwner nonReentrant
        tokenIdExists(tokenId)
        returns (uint)
    {
        address sellOrderCreator = _msgSender();
        MarketOrder storage sellOrder = _sellOrders[tokenId][sellOrderCreator];
        require(sellOrder.status == ActiveStatus.Active, "Market: EditPrice: Sell order is not active");

        return sellOrder.price = newPrice;
    }

    function editTokenAmountForMySellOrder(
        uint newTokenAmount,
        uint tokenId
    )
        public onlyOwner nonReentrant
        tokenIdExists(tokenId)
        tokenAmountIsNotZero(newTokenAmount)
        returns (uint)
    {
        address sellOrderCreator = _msgSender();
        MarketOrder storage sellOrder = _sellOrders[tokenId][sellOrderCreator];
        require(sellOrder.status == ActiveStatus.Active, "Market: EditPrice: Sell order is not active");

        uint oldTokenAmount = sellOrder.tokenAmount;
        require(newTokenAmount != oldTokenAmount, "Market: EditTokenAmount: New amount is old amount");

        if (newTokenAmount > oldTokenAmount) {
            uint shortfall = newTokenAmount - oldTokenAmount;
            IERC1155(spacenft)
                .safeTransferFrom(sellOrderCreator, address(this), tokenId, shortfall, "");
        } else if (newTokenAmount < oldTokenAmount) {
            uint rest = oldTokenAmount - newTokenAmount;
            IERC1155(spacenft)
                .safeTransferFrom(address(this), sellOrderCreator, tokenId, rest, "");
        }

        return sellOrder.tokenAmount = newTokenAmount;
    }


    // change feeReceiver address
    function changeFeeReceiver(address payable newFeeReceiver) public onlyOwner {
        require(newFeeReceiver != address(0), "Market: ChangeFeeReceiver: New receiver is the zero address");

        address payable oldReceiver = feeReceiver;
        feeReceiver = newFeeReceiver;

        emit FeeReceiverOwnershipTransferred(oldReceiver, newFeeReceiver);
    }


    // ---------------------- VIEW FUNCTIONS ----------------------


    function fetchAllBuyOrdersByTokenId(
        uint tokenId
    )
        public view
        tokenIdExists(tokenId)
        returns (MarketOrder[] memory)
    {
        MarketOrder[] memory buyOrdersArray = new MarketOrder[](_buyers[tokenId].length);
        for (uint i=0; i<_buyers[tokenId].length; i++) {
            if (_buyOrders[tokenId][_buyers[tokenId][i]].status == ActiveStatus.Active) {
                buyOrdersArray[i] = _buyOrders[tokenId][_buyers[tokenId][i]];
            }
        }

        return buyOrdersArray;
    }

    function fetchAllSellOrdersByTokenId(
        uint tokenId
    )
        public view
        tokenIdExists(tokenId)
        returns (MarketOrder[] memory)
    {
        MarketOrder[] memory sellOrdersArray = new MarketOrder[](_sellers[tokenId].length);
        for (uint i=0; i<_sellers[tokenId].length; i++) {
            if (_sellOrders[tokenId][_sellers[tokenId][i]].status == ActiveStatus.Active) {
                sellOrdersArray[i] = _sellOrders[tokenId][_sellers[tokenId][i]];
            }
        }

        return sellOrdersArray;
    }

    function fetchMyBuyOrders() public view returns (MarketOrder[] memory) {
        address sender = _msgSender(); // must call by user address
        uint total = _myBuyOrdersCount[sender];

        MarketOrder[] memory myBuyOrdersArray = new MarketOrder[](total);

        for (uint id=0; id<total; id++) {
            for (uint i=0; i<_buyers[id].length; i++) {
                if (_buyOrders[id][_buyers[id][i]].itemOwner == sender) {
                    myBuyOrdersArray[id] = _buyOrders[id][_buyers[id][i]];
                }
            }
        }

        return myBuyOrdersArray;
    }

    function fetchMySellOrders() public view returns (MarketOrder[] memory) {
        address sender = _msgSender(); // must call by user address
        uint total = _mySellOrdersCount[sender];

        MarketOrder[] memory mySellOrdersArray = new MarketOrder[](total);

        for (uint id=0; id<total; id++) {
            for (uint i=0; i<_sellers[id].length; i++) {
                if (_sellOrders[id][_sellers[id][i]].itemOwner == sender) {
                    mySellOrdersArray[id] = _sellOrders[id][_sellers[id][i]];
                }
            }
        }

        return mySellOrdersArray;
    }

    // Token amount by token Id
    function userBalance(uint tokenId) public view returns (uint) {
        address user = _msgSender();
        uint balance = IERC1155(spacenft).balanceOf(user, tokenId);
        uint orderbalance = _sellOrders[tokenId][user].tokenAmount;

        return balance + orderbalance;
    }

    function totalSupplyByTokenId(uint tokenId) public view returns (uint) {
        uint totalSupply = IERC1155Supply(spacenft).totalSupply(tokenId);
        return totalSupply;
    }

    function verify(address nftContract) public view returns (bool) {
        return spacenft == nftContract;
    }

    function fetchOrderItemByOrderCreator(
        address orderCreator,
        uint tokenId,
        uint orderType // 0 - buy order, 1 - sell order
    )
        public view
        tokenIdExists(tokenId)
        returns (MarketOrder memory item)
    {
        if (orderType == 0) {
            return _buyOrders[tokenId][orderCreator];
        } else if (orderType == 1) {
            return _sellOrders[tokenId][orderCreator];
        }
    }

    // -- // -- // -------------------------------------------

    // not works... need pay for transaction :(
    // function bestSalePrice(uint tokenId) public view returns (uint) {
    //     if (_sellers[tokenId].length == 0) return 0;

    //     uint bestSalePrice;

    //     for (uint i=0; i<=_sellers[tokenId].length; i++) {
    //         uint p = _sellOrders[tokenId][_sellers[tokenId][i]].price;
    //         if (p > bestSalePrice) {
    //             bestSalePrice = p;
    //         }
    //     }

    //     return bestSalePrice;
    // }

}