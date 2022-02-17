//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrbMarket is Ownable, ReentrancyGuard {
    /*
     struct
    */
    struct SellOrder {
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        IERC20 tokenFunAddress;
    }

    struct BuyOrder {
        address buyer;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        IERC20 tokenFunAddress;
    }

    /*
        event
    */
    event ChangeMarketFee(uint256 indexed newMarketFee);

    event ChangeEggAddress(address indexed newEggAddress);

    event ChangeReceiveFunAddress(address indexed newReceiveFunAddres);

    event OrderList(
        uint256 indexed orderId,
        address indexed seller,
        uint256 indexed eggId,
        address tokenFunAddress,
        uint256 amount,
        uint256 price
    );
    event OrderUnlist(uint256 indexed orderId);
    event OrderOffer(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 indexed eggId,
        address tokenFunAddress,
        uint256 amount,
        uint256 price
    );
    event OrderCancelOffer(uint256 indexed orderId);
    event OrderMatching(
        uint256 indexed orderId,
        address indexed seller,
        address indexed buyer,
        uint256 eggId,
        address tokenFunAddress,
        uint256 amount,
        uint256 price
    );
    event OrderUpdate(uint256 indexed orderId, uint256 indexed amount);

    using Counters for Counters.Counter;

    /*
    variable
    */
    Counters.Counter public orderCounter;

    uint256 public constant BPS = 10000;

    uint256 public marketFeeInBps = 50;

    IERC1155 public egg;
    address public receiveFun;

    mapping(uint256 => SellOrder) public eggForSale;

    mapping(uint256 => BuyOrder) public eggForBuy;

    /**
     * @dev Initializes the contract by setting a `summonersArenaHeroes` to marketplace.
     */
    constructor(IERC1155 _egg) {
        egg = _egg;
        receiveFun = msg.sender;
        orderCounter.increment();
    }

    /*
        modifier function 

    */

    /*
    *****
     external function

    *****

    */

    function setMarketFeeInBps(uint256 _marketFeeInBps) external onlyOwner {
        marketFeeInBps = _marketFeeInBps;
        emit ChangeMarketFee(_marketFeeInBps);
    }

    function setEggAddress(IERC1155 _eggAddress) external onlyOwner {
        egg = _eggAddress;

        emit ChangeEggAddress(address(_eggAddress));
    }

    function setReceiveFunAddress(address _address) external onlyOwner {
        receiveFun = _address;
        emit ChangeReceiveFunAddress(_address);
    }

    function listForSale(
        uint256 eggId,
        uint256 amount,
        address tokenAddress,
        uint256 price
    ) external nonReentrant {
        //check approved egg
        require(
            egg.isApprovedForAll(msg.sender, address(this)),
            "ORB: require approve"
        );

        //check balance >= number listing
        require(
            egg.balanceOf(msg.sender, eggId) >= amount,
            "ORB: not enough amount"
        );
        egg.safeTransferFrom(msg.sender, address(this), eggId, amount, "");
        uint256 orderId = orderCounter.current();
        eggForSale[orderId] = SellOrder(
            msg.sender,
            eggId,
            amount,
            price,
            IERC20(tokenAddress)
        );
        orderCounter.increment();
        emit OrderList(orderId, msg.sender, eggId, tokenAddress, amount, price);
    }

    function unList(uint256 orderId, uint256 _amount) external nonReentrant {
        //get order from orderId
        SellOrder storage sellOrder = eggForSale[orderId];
        //check order exist
        require(sellOrder.amount > 0, "ORB: order not exist");
        require(sellOrder.seller == msg.sender, "ORB: is not owner of oder");
        require(sellOrder.amount >= _amount, "ORB: amount invalid");

        sellOrder.amount -= _amount;
        if (sellOrder.amount == 0) {
            emit OrderUnlist(orderId);
            delete eggForSale[orderId];
        }
        //return nft to user
        egg.safeTransferFrom(
            address(this),
            msg.sender,
            sellOrder.tokenId,
            _amount,
            ""
        );
        emit OrderUpdate(orderId, sellOrder.amount);
    }

    function buy(uint256 orderId, uint256 _amount) external nonReentrant {
        require(_amount > 0, "Orb: invalid amount");
        SellOrder storage sellOrder = eggForSale[orderId];
        require(_amount <= sellOrder.amount, "ORB: amount not enough");
        uint256 price = sellOrder.price;
        uint256 marketFee = (_amount * price * marketFeeInBps) / BPS;
        sellOrder.tokenFunAddress.transferFrom(
            msg.sender,
            sellOrder.seller,
            _amount * price - marketFee
        );
        sellOrder.tokenFunAddress.transferFrom(
            msg.sender,
            receiveFun,
            marketFee
        );
        egg.safeTransferFrom(
            address(this),
            msg.sender,
            sellOrder.tokenId,
            _amount,
            ""
        );
        emit OrderMatching(
            orderId,
            sellOrder.seller,
            msg.sender,
            sellOrder.tokenId,
            address(sellOrder.tokenFunAddress),
            _amount,
            price
        );
        eggForSale[orderId].amount -= _amount;
        if (eggForSale[orderId].amount == 0) {
            delete eggForSale[orderId];
        }
        emit OrderUpdate(orderId, eggForSale[orderId].amount);
    }

    function makeOffer(
        uint256 eggId,
        uint256 amount,
        address tokenAddress,
        uint256 price
    ) external nonReentrant {
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >=
                price * amount,
            "ORB: not approve"
        );
        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount * price
        );
        uint256 orderId = orderCounter.current();
        eggForBuy[orderId] = BuyOrder(
            msg.sender,
            eggId,
            amount,
            price,
            IERC20(tokenAddress)
        );
        orderCounter.increment();
        emit OrderOffer(
            orderId,
            msg.sender,
            eggId,
            tokenAddress,
            amount,
            price
        );
    }

    function cancelOffer(uint256 orderId, uint256 _amount)
        external
        nonReentrant
    {
        require(_amount > 0, "Orb: invalid amount");
        BuyOrder storage buyOrder = eggForBuy[orderId];
        require(buyOrder.amount >= _amount, "ORb: invalid order");
        require(buyOrder.buyer == msg.sender, "ORB: not order owner");
        buyOrder.amount -= _amount;
        buyOrder.tokenFunAddress.transfer(msg.sender, buyOrder.price * _amount);
        if (buyOrder.amount == 0) {
            emit OrderCancelOffer(orderId);
            delete eggForBuy[orderId];
        }
        emit OrderUpdate(orderId, buyOrder.amount);
    }

    function takeOffer(uint256 orderId, uint256 _amount) external nonReentrant {
        require(
            egg.isApprovedForAll(msg.sender, address(this)),
            "ORB: require approve"
        );
        require(_amount > 0, "Orb: invalid amount");
        BuyOrder storage buyOrder = eggForBuy[orderId];
        require(buyOrder.amount >= _amount, "Orb: order invalid");
        require(
            egg.balanceOf(msg.sender, buyOrder.tokenId) >= _amount,
            "ORB: balance not enough"
        );
        egg.safeTransferFrom(
            msg.sender,
            buyOrder.buyer,
            buyOrder.tokenId,
            _amount,
            ""
        );
        uint256 marketFee = buyOrder.price * _amount;
        buyOrder.tokenFunAddress.transfer(
            msg.sender,
            _amount * buyOrder.price - marketFee
        );
        buyOrder.tokenFunAddress.transfer(receiveFun, marketFee);
        emit OrderMatching(
            orderId,
            msg.sender,
            buyOrder.buyer,
            buyOrder.tokenId,
            address(buyOrder.tokenFunAddress),
            _amount,
            buyOrder.price
        );
        buyOrder.amount -= _amount;
        if (buyOrder.amount == 0) {
            delete eggForBuy[orderId];
        }
        emit OrderUpdate(orderId, buyOrder.amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Counters.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address sender,
        address recipient,
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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

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