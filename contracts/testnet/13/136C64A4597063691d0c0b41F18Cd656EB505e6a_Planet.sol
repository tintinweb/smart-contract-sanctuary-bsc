/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// File: MarketBase.sol



pragma solidity >=0.8.4 <0.9.0;

interface IMarketBase {
    // ----- Data and Events for Market ----- //

    /**
     * @dev Token info data structure
     * @param collection  The ERC721/ERC1155 collection address
     * @param tokenId  The token ID placed in the collection
     * @param quantity  The quantity of tokens (only meaningful for ERC1155 token)
     */
    struct TokenInfo {
        address collection;
        uint256 tokenId;
        uint256 quantity;
    }

    /**
     * @dev Payment info data structure
     * @param paymentToken  The address of the token accepted as payment for the order
     * @param price  The amount of payment token(considering decimals)
     */
    struct PaymentInfo {
        address paymentToken;
        uint256 price;
    }

    /**
     * @dev Order info data structure
     * @param orderId  The identifier of the order, incrementing uint256 starting from 0
     * @param orderType  The type of the order, 1 is sale order, 2 is auction order
     * @param orderState  The state of the order, 1 is open, 2 is filled, 3 is cancelled, 4 is taken down by manager
     * @param token  The token info placed in the order
     * @param payment  The payment info accepted as payment for the order
     * @param endTime  The end time of the auction (only meaningful for auction order)
     * @param seller  The address of the seller that created the order
     * @param buyer  The address of the buyer of the order
     * @param bids  The number of bids placed on the order (only meaningful for auction orders)
     * @param lastBidder  The address of the last bidder that bids on the order (only meaningful for auction orders)
     * @param lastBid  The last bid price on the order (only meaningful for auction orders)
     * @param createTime  The timestamp of the order creation
     * @param updateTime  The timestamp of last order info update
     */
    struct OrderInfo {
        uint256 orderId;
        uint256 orderType;
        uint256 orderState;
        TokenInfo token;
        PaymentInfo payment;
        uint256 endTime;
        address seller;
        address buyer;
        uint256 bids;
        address lastBidder;
        uint256 lastBid;
        uint256 createTime;
        uint256 updateTime;
    }

    /**
     * @dev Offer info data structure
     * @param offerId  The identifier of the offer, incrementing uint256 starting from 0
     * @param offerState  The state of the offer, 1 is open, 2 is accepted, 3 is cancelled
     * @param token  The token info placed in the offer
     * @param payment  The payment info accepted as payment for the offer
     * @param offerer  The address of the offerer that created the offer
     * @param acceptor  The address of the acceptor that accepted the offer
     * @param createTime  The timestamp of the offer creation
     * @param updateTime  The timestamp of last offer info update
     */
    struct OfferInfo {
        uint256 offerId;
        uint256 offerState;
        TokenInfo token;
        PaymentInfo payment;
        address offerer;
        address acceptor;
        uint256 createTime;
        uint256 updateTime;
    }

    /**
     * @dev MUST emit when a new sale order is created in Market.
     * The `seller` argument MUST be the address of the seller who created the order.
     * The `orderId` argument MUST be the id of the order created.
     * The `collection` argument MUST be the address of the collection.
     * The `tokenId` argument MUST be the token type placed on sale.
     * The `quantity` argument MUST be the quantity of tokens placed on sale.
     * The `paymentToken` argument MUST be the address of the token accepted as payment for the order.
     * The `price` argument MUST be the fixed price asked for the sale order.
     */
    event OrderForSale(address seller, uint256 indexed orderId, address indexed collection, uint256 indexed tokenId, uint256 quantity, address paymentToken, uint256 price);

    /**
     * @dev MUST emit when a new auction order is created in Market.
     * The `seller` argument MUST be the address of the seller who created the order.
     * The `orderId` argument MUST be the id of the order created.
     * The `collection` argument MUST be the address of the collection.
     * The `tokenId` argument MUST be the token type placed on auction.
     * The `quantity` argument MUST be the quantity of tokens placed on auction.
     * The `paymentToken` argument MUST be the address of the token accepted as payment for the auction.
     * The `minPrice` argument MUST be the minimum starting price for the auction bids.
     * The `endTime` argument MUST be the time for ending the auction.
     */
    event OrderForAuction(address seller, uint256 indexed orderId, address indexed collection, uint256 indexed tokenId, uint256 quantity, address paymentToken, uint256 minPrice, uint256 endTime);

    /**
     * @dev MUST emit when a bid is placed on an auction order.
     * The `orderId` argument MUST be the id of the order been bid on.
     * The `bidder` argument MUST be the address of the bidder who made the bid.
     * The `price` argument MUST be the price of the bid.
     */
    event OrderBid(uint256 indexed orderId, address indexed bidder, uint256 price);

    /**
     * @dev MUST emit when an order is filled.
     * The `seller` argument MUST be the address of the seller who created the order.
     * The `buyer` argument MUST be the address of the buyer in the fulfilled order.
     * The `orderId` argument MUST be the id of the order fulfilled.
     * The `paymentToken` argument MUST be the address of the token used as payment for the fulfilled order.
     * The `price` argument MUST be the price of the fulfilled order.
     */
    event OrderFilled(address seller, address indexed buyer, uint256 indexed orderId, address indexed paymentToken, uint256 price);

    /**
     * @dev MUST emit when an order is canceled.
     * @dev Only an open sale order or an auction order with no bid yet can be canceled
     * The `orderId` argument MUST be the id of the order canceled.
     */
    event OrderCanceled(uint256 indexed orderId);

    /**
     * @dev MUST emit when an order is taken down by manager due to inappropriate content.
     * @dev Only an open order can be taken down.
     * The `orderId` argument MUST be the id of the order taken down.
     * The `manager` argument MUST be the address of the manager who took down the order.
     */
    event OrderTakenDown(uint256 indexed orderId, address indexed manager);

    /**
     * @dev MUST emit when an order has its price changed.
     * @dev Only an open sale order or an auction order with no bid yet can have its price changed.
     * @dev For sale orders, the fixed price asked for the order is changed.
     * @dev for auction orders, the minimum starting price for the bids is changed.
     * The `seller` argument MUST be the address of the seller who created the order.
     * The `orderId` argument MUST be the id of the order with the price change.
     * The `oldPrice` argument MUST be the original price of the order before the price change.
     * The `newPrice` argument MUST be the new price of the order after the price change.
     */
    event OrderPriceChanged(address indexed seller, uint256 indexed orderId, uint256 oldPrice, uint256 newPrice);

    /**
     * @dev MUST emit when a new offer is created in Market.
     * The `offerer` argument MUST be the address of the offerer who created the offer.
     * The `offerId` argument MUST be the id of the offer created.
     * The `collection` argument MUST be the address of the collection.
     * The `tokenId` argument MUST be the token type placed on offer.
     * The `quantity` argument MUST be the quantity of tokens placed on offer.
     * The `paymentToken` argument MUST be the address of the token accepted as payment for the offer.
     * The `price` argument MUST be the fixed price asked for the offer.
     */
    event OfferCreated(address indexed offerer, uint256 indexed offerId, address collection, uint256 tokenId, uint256 quantity, address paymentToken, uint256 price);

    /**
     * @dev MUST emit when the offer is accepted in Market.
     * The `offerId` argument MUST be the id of the offer accepted.
     * The `orderId` argument MUST be the id of the order that involves the token used in the offer.
     * The `acceptor` argument MUST be the address of the acceptor who accepted the offer.
     */
    event OfferAccepted(uint256 indexed offerId, uint256 indexed orderId, address indexed acceptor);

    /**
     * @dev MUST emit when the offer is canceled in Market.
     * The `offerId` argument MUST be the id of the offer canceled.
     */
    event OfferCanceled(uint256 indexed offerId);


    // ----- Trading orders in Market ----- //

    /**
     * @notice Create a new order for sale at a fixed price.
     * @param collection The contract address of collection.
     * @param tokenId The token placed on sale.
     * @param quantity The quantity of tokens placed on sale.
     * @param paymentToken The address of the token accepted as payment for the order.
     * @param price The fixed price asked for the sale order.
     */
    function createOrderForSale(address collection, uint256 tokenId, uint256 quantity, address paymentToken, uint256 price) external;

    /**
     * @notice Create a new order for auction.
     * @param collection The contract address of collection.
     * @param tokenId The token placed on auction.
     * @param quantity The quantity of tokens placed on auction.
     * @param paymentToken The address of the token accepted as payment for the auction.
     * @param minPrice The minimum starting price for bidding on the auction.
     * @param endTime The time for ending the auction.
     */
    function createOrderForAuction(address collection, uint256 tokenId, uint256 quantity, address paymentToken, uint256 minPrice, uint256 endTime) external;

    /**
     * @notice Buy a sale order with fixed price.
     * @dev The value of the transaction must equal to the fixed price asked for the order.
     * @param orderId The id of the fixed price sale order.
     */
    function buyForOrder(uint256 orderId) external payable;

    /**
     * @notice Bid on an auction order.
     * @dev The value of the transaction must be greater than or equal to the minimum starting price of the order.
     * @dev If the order has past bid(s), the value of the transaction must be greater than the last bid.
     * @param orderId The id of the auction order.
     * @param value The price value of the bid.
     */
    function bidForOrder(uint256 orderId, uint256 value) external payable;

    /**
     * @notice Cancel an order.
     * @dev Only an open sale order or an auction order with no bid yet can be canceled.
     * @dev Only an order's seller can cancel the order.
     * @param orderId The id of the order to be canceled.
     */
    function cancelOrder(uint256 orderId) external;

    /**
     * @notice Take down an order due to inappropriate content.
     * @dev Only an open order can be taken down.
     * @dev Only a contract manager can take down orders.
     * @param orderId The id of the order to be taken down.
     */
    function takeDownOrder(uint256 orderId) external;

    /**
     * @notice Settle an auction.
     * @dev Only an auction order past its end time can be settled.
     * @dev Anyone can settle an auction.
     * @param orderId The id of the order to be settled.
     */
    function settleOrderForAuction(uint256 orderId) external;

    /**
     * @notice Change the price of an order.
     * @dev Only an open sale order or an auction order with no bid yet can have its price changed.
     * @dev For sale orders, the fixed price asked for the order is changed.
     * @dev for auction orders, the minimum starting price for the bids is changed.
     * @dev Only an order's seller can change its price.
     * @param orderId The id of the order with its price to be changed.
     * @param price The new price of the order.
     */
    function changeOrderPrice(uint256 orderId, uint256 price) external;

    /**
     * @notice Create a new offer.
     * @param collection The address of the collection.
     * @param tokenId The token placed on offer.
     * @param quantity The quantity of tokens placed on offer.
     * @param paymentToken The address of the token accepted as payment for the offer.
     * @param price The fixed price asked for the offer.
     */
    function makeOffer(address collection, uint256 tokenId, uint256 quantity, address paymentToken, uint256 price) external payable;

    /**
     * @notice Accept an offer.
     * @param offerId The id of the offer.
     * @param orderId The id of the order that involves the token used in the offer.
     */
    function acceptOffer(uint256 offerId, uint256 orderId) external;

    /**
     * @notice Cancel an offer.
     * @param offerId The id of the offer.
     */
    function cancelOffer(uint256 offerId) external;
}

// File: Context.sol



pragma solidity >=0.8.4 <0.9.0;

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

// File: Ownable.sol



pragma solidity >=0.8.4 <0.9.0;


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
contract Ownable is Context {
    address _owner;

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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: Mutex.sol



pragma solidity >=0.8.4 <0.9.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `Mutex` will make the {nonReentrant} modifier
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

contract Mutex {
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
    uint256 constant _NOT_ENTERED = 1;
    uint256 constant _ENTERED = 2;

    uint256 _status;

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
        require(_status != _ENTERED, "Mutex: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: Address.sol



pragma solidity >=0.8.4 <0.9.0;

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

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

// File: IERC1155Receiver.sol



pragma solidity >=0.8.4 <0.9.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver {
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
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns (bytes4);

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
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external returns (bytes4);
}

// File: IERC721Receiver.sol



pragma solidity >=0.8.4 <0.9.0;

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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// File: IERC165.sol



pragma solidity >=0.8.4 <0.9.0;

/**
 * @dev Interface of the ERC165 standard as defined in the EIP.
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     * @return `true` if the contract implements `interfaceID` and
     * `interfaceId` is not 0xffffffff, `false` otherwise
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: IERC2981.sol



pragma solidity >=0.8.4 <0.9.0;


/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);
}

// File: IERC1155.sol



pragma solidity >=0.8.4 <0.9.0;


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
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

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
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// File: IERC721.sol



pragma solidity >=0.8.4 <0.9.0;


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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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

// File: IERC20.sol



pragma solidity >=0.8.4 <0.9.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: Planet.sol



pragma solidity >=0.8.4 <0.9.0;












contract Planet is IMarketBase, IERC721Receiver, IERC1155Receiver, Ownable, Mutex {
    using Address for address;

    // ----- CONSTANTS ----- //
    bytes constant MARKET_DATA = bytes("Planet");
    uint256 constant _denominator = 10000;
    bytes4 constant INTERFACE_ERC721 = 0x80ac58cd;
    bytes4 constant INTERFACE_ERC1155 = 0xd9b67a26;


    // ----- STATES AND STORAGE ----- //
    address _platformAddress;
    uint256 _platformFeeRate;
    mapping(address => bool) _managers;
    mapping(address => bool) _payments;

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
    constructor() {
        _platformAddress = _msgSender();
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
    function takeDownOrder(uint256 orderId) external override nonReentrant onlyManager {
        require(_orders[orderId].orderState == 1, "Planet: invalid order for down");

        _orders[orderId].orderState = 4;
        _orders[orderId].updateTime = block.timestamp;

        emit OrderTakenDown(orderId, _msgSender());
    }

    /**
     * @notice Settle an auction.
     * @dev Only an auction order past its end time can be settled.
     * @dev Anyone can settle an auction.
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
     * @param orderId The id of the order that involves the token used in the offer.
     */
    function acceptOffer(uint256 offerId, uint256 orderId) external override nonReentrant {
        OfferInfo memory offer = _offers[offerId];

        if(IERC165(offer.token.collection).supportsInterface(INTERFACE_ERC721)) {
            if(orderId == type(uint256).max) {
                require(IERC721(offer.token.collection).ownerOf(offer.token.tokenId) == _msgSender(), "Planet: caller is not the token owner");
                IERC721(offer.token.collection).safeTransferFrom(_msgSender(), offer.offerer, offer.token.tokenId, MARKET_DATA);
            } else {
                OrderInfo memory order = _orders[orderId];
                require(order.orderType == 1 && order.orderState == 1, "Planet: invalid order for accept");
                require(order.seller == _msgSender(), "Planet: caller is not the seller");
                require(order.token.collection == offer.token.collection && order.token.tokenId == offer.token.tokenId, "Planet: incorrect token");

                _unlockToken(order.token, offer.offerer);

                _orders[orderId].orderState = 2;
                _orders[orderId].buyer = offer.offerer;
                _orders[orderId].updateTime = block.timestamp;

                emit OrderFilled(order.seller, offer.offerer, orderId, offer.payment.paymentToken, offer.payment.price);
            }
        } else {
            require(IERC1155(offer.token.collection).balanceOf(_msgSender(), offer.token.tokenId) >= offer.token.quantity, "Planet: insufficient quantity for accept");
            IERC1155(offer.token.collection).safeTransferFrom(_msgSender(), offer.offerer, offer.token.tokenId, offer.token.quantity, MARKET_DATA);
        }

        _splitPayment(offer.token, offer.payment, _msgSender());

        _offers[offerId].offerState = 2;
        _offers[offerId].updateTime = block.timestamp;

        emit OfferAccepted(offerId, orderId, _msgSender());
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
        (address royaltyOwner, uint256 royaltyFee) = IERC2981(token.collection).royaltyInfo(token.tokenId, payment.price);
        uint256 platformFee = payment.price * _platformFeeRate / _denominator;
        uint256 paymentExcludingFee = payment.price - royaltyFee - platformFee;

        if(payment.paymentToken == address(0)) {
            bool success;
            (success, ) = payable(royaltyOwner).call{value: royaltyFee}("");
            require(success, "Planet: BNB transfer failed for royalty");
            (success, ) = payable(_platformAddress).call{value: platformFee}("");
            require(success, "Planet: BNB transfer failed for service fee");
            (success, ) = payable(receiver).call{value: paymentExcludingFee}("");
            require(success, "Planet: BNB transfer failed for payment");
        } else {
            require(IERC20(payment.paymentToken).transfer(royaltyOwner, royaltyFee), "Planet: token transfer failed for royalty");
            require(IERC20(payment.paymentToken).transfer(_platformAddress, platformFee), "Planet: token transfer failed for service fee");
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