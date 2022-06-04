// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is Ownable, ReentrancyGuard {
    struct Order {
        uint256 id;
        address collection;
        uint256 tokenId;
        address payable maker;
        uint256 price;
        address currency;
        bool isActive;
    }

    struct Offer {
        uint256 id;
        address collection;
        uint256 tokenId;
        address payable[] maker;
        uint256[] price;
        address[] currency;
        string[] offerTime;
        bool isActive;
    }

    Order[] public orders;
    Offer[] public offers;

    uint256 public fee = 10;
    address public treasury = 0x2C0b73164AF92a89d30Af163912B38F45b7f7b65;

    uint256 public activeOrderCount;
    uint256 public activeOfferCount;
    mapping(address => mapping(uint256 => uint256)) public onOrders;
    mapping(address => mapping(uint256 => uint256)) public onOffers;
    mapping(address => bool) public acceptableCollections;

    event OrderCreated(uint256 id);
    event OrderDone(uint256 id);
    event OrderCanceled(uint256 id);

    event OfferCreated(uint256 id);
    event OfferAccepted(uint256 id, uint256 index);
    event OfferCanceled(uint256 id);

    modifier onlyItemOwner(address collection, uint256 tokenId) {
        require(
            IERC721(collection).ownerOf(tokenId) == msg.sender,
            "Sender does not own this item"
        );
        _;
    }

    function setAcceptableCollection(address collection, bool isAcceptable)
        external
        onlyOwner
    {
        acceptableCollections[collection] = isAcceptable;
    }

    function _getActiveOrders() internal view returns (Order[] memory) {
        Order[] memory activeOrders = new Order[](activeOrderCount);
        uint256 index = 0;
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].isActive) {
                activeOrders[index] = orders[i];
                index += 1;
            }
        }
        return activeOrders;
    }

    function getActiveOrders() external view returns (Order[] memory) {
        return _getActiveOrders();
    }

    function getActiveOrder(address _collection, uint256 _tokenId)
        external
        view
        returns (Order memory result)
    {
        if (onOrders[_collection][_tokenId] != 0)
            result = orders[onOrders[_collection][_tokenId] - 1];
    }

    function _createOrder(
        address collection,
        uint256 tokenId,
        uint256 price,
        address currency
    ) internal onlyItemOwner(collection, tokenId) nonReentrant {
        require(acceptableCollections[collection], "Not acceptable collection");
        require(
            onOrders[collection][tokenId] == 0,
            "item is already on order list"
        );
        require(
            IERC721(collection).getApproved(tokenId) == address(this),
            "item not approved"
        );

        uint256 id = orders.length;
        orders.push(
            Order(
                id,
                collection,
                tokenId,
                payable(msg.sender),
                price,
                currency,
                true
            )
        );
        IERC721(collection).transferFrom(msg.sender, address(this), tokenId);
        onOrders[collection][tokenId] = id + 1;
        activeOrderCount++;
        emit OrderCreated(id);
    }

    function createOrder(
        address collection,
        uint256 tokenId,
        uint256 price,
        address currency
    ) external {
        _createOrder(collection, tokenId, price, currency);
    }

    function createOrders(
        address[] memory collections,
        uint256[] memory tokenIds,
        uint256[] memory prices,
        address[] memory currencys
    ) external {
        require(
            (collections.length == tokenIds.length) &&
                (collections.length == prices.length) &&
                (collections.length == currencys.length),
            "Invalid Params"
        );

        for (uint256 i = 0; i < collections.length; i++)
            _createOrder(collections[i], tokenIds[i], prices[i], currencys[i]);
    }

    function _cancelOrder(uint256 id) internal nonReentrant {
        Order storage currentOrder = orders[id];
        require(currentOrder.maker == msg.sender, "invaild permission");
        IERC721(currentOrder.collection).transferFrom(
            address(this),
            msg.sender,
            currentOrder.tokenId
        );
        currentOrder.isActive = false;
        onOrders[currentOrder.collection][currentOrder.tokenId] = 0;
        activeOrderCount--;
        emit OrderCanceled(id);
    }

    function cancelOrder(uint256 id) external {
        _cancelOrder(id);
    }

    function cancelOrders(uint256[] memory ids) external {
        for (uint256 i = 0; i < ids.length; i++) _cancelOrder(ids[i]);
    }

    function buyOrder(uint256 id) external payable nonReentrant {
        Order storage order = orders[id];

        if (order.currency == address(0)) {
            require(msg.value >= order.price, "insufficient fund");
            (order.maker).transfer((msg.value * (1000 - fee)) / 1000);
            payable(treasury).transfer((msg.value * fee) / 1000);
        } else {
            require(
                IERC20(order.currency).allowance(msg.sender, address(this)) >=
                    order.price,
                "insufficient fund"
            );
            IERC20(order.currency).transferFrom(
                msg.sender,
                order.maker,
                (order.price * (1000 - fee)) / 1000
            );
            IERC20(order.currency).transferFrom(
                msg.sender,
                treasury,
                (order.price * fee) / 1000
            );
        }

        IERC721(order.collection).transferFrom(
            address(this),
            msg.sender,
            order.tokenId
        );

        order.isActive = false;
        onOrders[order.collection][order.tokenId] = 0;
        activeOrderCount--;
        emit OrderDone(id);
    }

    function freezeAllOrders() external onlyOwner nonReentrant {
        for (uint256 i = 0; i < orders.length; i++) {
            Order storage currentOrder = orders[i];
            if (currentOrder.isActive) {
                IERC721(currentOrder.collection).transferFrom(
                    address(this),
                    currentOrder.maker,
                    currentOrder.tokenId
                );
                currentOrder.isActive = false;
                onOrders[currentOrder.collection][currentOrder.tokenId] = 0;
            }
        }

        activeOrderCount = 0;
    }

    function getActiveOffers() external view returns (Offer[] memory) {
        Offer[] memory activeOffers = new Offer[](activeOfferCount);
        uint256 index = 0;
        for (uint256 i = 0; i < offers.length; i++) {
            if (offers[i].isActive) {
                activeOffers[index] = offers[i];
                index += 1;
            }
        }
        return activeOffers;
    }

    function getActiveOffer(address _collection, uint256 _tokenId)
        external
        view
        returns (Offer memory result)
    {
        if (onOffers[_collection][_tokenId] != 0)
            result = offers[onOffers[_collection][_tokenId] - 1];
    }

    function createOffer(
        address collection,
        uint256 tokenId,
        uint256 price,
        address currency,
        string memory offerTime
    ) external payable nonReentrant {
        require(price > 0, "must be bigger than zero!");
        require(acceptableCollections[collection], "Not acceptable collection");
        if (currency == address(0)) {
            require(msg.value == price, "Invalid Param");
            (payable(address(this))).transfer(msg.value);
        } else {
            require(IERC20(currency).allowance(msg.sender, address(this)) >= price, "Token Not Approved!");
            IERC20(currency).transferFrom(msg.sender, address(this), price);
        }
        if (onOffers[collection][tokenId] == 0) {
            address payable[] memory maker_arr = new address payable[](1);
            uint256[] memory price_arr = new uint256[](1);
            address[] memory currency_arr = new address[](1);
            string[] memory offerTime_arr = new string[](1);
            maker_arr[0] = payable(msg.sender);
            price_arr[0] = price;
            currency_arr[0] = currency;
            offerTime_arr[0] = offerTime;
            uint256 id = offers.length;
            offers.push(
                Offer(
                    id,
                    collection,
                    tokenId,
                    maker_arr,
                    price_arr,
                    currency_arr,
                    offerTime_arr,
                    true
                )
            );
            emit OfferCreated(id);
            onOffers[collection][tokenId] = id + 1;
            activeOfferCount++;
        } else {
            Offer storage currentOffer = offers[
                onOffers[collection][tokenId] - 1
            ];
            currentOffer.maker.push(payable(msg.sender));
            currentOffer.price.push(price);
            currentOffer.currency.push(currency);
            currentOffer.offerTime.push(offerTime);
        }
    }

    function cancelOffer(uint256 id, uint256 index)
        external
        payable
        nonReentrant
    {
        Offer storage currentOffer = offers[id];
        if (currentOffer.currency[index] == address(0)) {
            payable(msg.sender).transfer(currentOffer.price[index]);
        } else {
            IERC20(currentOffer.currency[index]).transfer(
                msg.sender,
                currentOffer.price[index]
            );
        }
        delete currentOffer.maker[index];
        delete currentOffer.price[index];
        delete currentOffer.currency[index];
        delete currentOffer.offerTime[index];

        uint256 InvaidCount = 0;
        for (uint256 i = 0; i < currentOffer.maker.length; i++) {
            if (currentOffer.maker[i] == address(0)) InvaidCount++;
        }
        if (InvaidCount == currentOffer.maker.length) {
            currentOffer.isActive = false;
            activeOfferCount--;
            onOffers[currentOffer.collection][currentOffer.tokenId] = 0;
        }
        emit OfferCanceled(id);
    }

    function acceptOffer(uint256 id, uint256 index) external nonReentrant {
        Offer storage currentOffer = offers[id];
        if (
            IERC721(currentOffer.collection).ownerOf(currentOffer.tokenId) !=
            address(this)
        ) {
            require(
                IERC721(currentOffer.collection).getApproved(
                    currentOffer.tokenId
                ) == address(this),
                "NFT not approved"
            );

            IERC721(currentOffer.collection).transferFrom(
                msg.sender,
                currentOffer.maker[index],
                currentOffer.tokenId
            );
        } else {
            Order storage currentOrder = orders[
                onOrders[currentOffer.collection][currentOffer.tokenId] - 1
            ];
            require(currentOrder.maker == msg.sender, "invaild permission");
            currentOrder.isActive = false;
            onOrders[currentOrder.collection][currentOrder.tokenId] = 0;
            activeOrderCount--;

            IERC721(currentOffer.collection).transferFrom(
                address(this),
                currentOffer.maker[index],
                currentOffer.tokenId
            );
        }

        for (uint256 i = 0; i < currentOffer.maker.length; i++) {
            if (i == index) {
                if (currentOffer.currency[index] == address(0)) {
                    payable(msg.sender).transfer(
                        (currentOffer.price[index] * (1000 - fee)) / 1000
                    );
                    payable(treasury).transfer(
                        (currentOffer.price[index] * fee) / 1000
                    );
                } else {
                    IERC20(currentOffer.currency[index]).transfer(
                        msg.sender,
                        (currentOffer.price[index] * (1000 - fee)) / 1000
                    );
                    IERC20(currentOffer.currency[index]).transfer(
                        treasury,
                        (currentOffer.price[index] * (fee)) / 1000
                    );
                }
            } else {
                if (currentOffer.currency[i] == address(0)) {
                    (currentOffer.maker[i]).transfer(currentOffer.price[i]);
                } else {
                    IERC20(currentOffer.currency[i]).transfer(
                        currentOffer.maker[i],
                        currentOffer.price[i]
                    );
                }
            }
        }
        if (
            IERC721(currentOffer.collection).ownerOf(currentOffer.tokenId) ==
            address(this)
        ) {
            for (uint256 i = 0; i < orders.length; i++) {
                if (
                    (orders[i].collection == currentOffer.collection) &&
                    (orders[i].tokenId == currentOffer.tokenId) &&
                    (orders[i].isActive)
                ) {
                    Order storage currentOrder = orders[i];
                    currentOrder.isActive = false;
                    onOrders[currentOrder.collection][currentOrder.tokenId] = 0;
                    activeOrderCount--;
                }
            }
        }

        emit OfferAccepted(id, index);
        currentOffer.isActive = false;
        onOffers[currentOffer.collection][currentOffer.tokenId] = 0;
        activeOfferCount--;
    }

    function freezeAllOffers() external onlyOwner nonReentrant {
        for (uint256 i = 0; i < offers.length; i++) {
            Offer storage currentOffer = offers[i];
            if (currentOffer.isActive) {
                for (uint256 j = 0; j < currentOffer.maker.length; j++) {
                    if (currentOffer.currency[j] == address(0))
                        payable(currentOffer.maker[j]).transfer(
                            currentOffer.price[j]
                        );
                    else
                        IERC20(currentOffer.currency[j]).transfer(
                            currentOffer.maker[j],
                            currentOffer.price[j]
                        );
                }
                currentOffer.isActive = false;
                onOffers[currentOffer.collection][currentOffer.tokenId] = 0;
            }
        }
        activeOfferCount = 0;
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setTreasuryWallet(address _wallet) external onlyOwner {
        treasury = _wallet;
    }

    receive() external payable {}
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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