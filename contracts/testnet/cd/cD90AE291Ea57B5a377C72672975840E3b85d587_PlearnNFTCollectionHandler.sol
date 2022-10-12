// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/ICollectionHandler.sol";

contract PlearnNFTCollectionHandler is ICollectionHandler, Ownable {
    //base divide rate percentage
    uint16 public constant BASE_FREE_RATE = 10000;
    uint16 public constant TOTAL_MAX_FEE = 1000; //(1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05% when divide 10000)

    enum Status {
        Pending,
        Open,
        Close
    }

    struct Collection {
        Status status; // status of the collection
        address creatorAddress; // address of the creator
        uint16 creatorFeeRate; // creator fee (1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05%)
        uint16 tradingFeeRate; // trading fee (1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05%)
        bool auctionEnable;
    }

    mapping(IERC721 => Collection) public collections; // Details about the collections

    event AddCollection(
        IERC721 indexed collection,
        address indexed creator,
        uint16 creatorFeeRate,
        uint16 tradingFeeRate,
        bool auctionEnable
    );
    event UpdateCollection(
        IERC721 indexed collection,
        address indexed creator,
        uint16 creatorFee,
        uint16 tradingFee,
        bool auctionEnable
    );
    event UpdateCollectionStatus(IERC721 indexed collection, Status status);
    event RemoveCollection(IERC721 indexed collection);
    event NewBaseFeeRate(uint16 baseFeeRate);

    modifier whenCollectionListed(IERC721 collection) {
        require(isCollectionListed(collection), "Marketplace: Collection not listed");
        _;
    }

    modifier whenFeeNotExceed(uint16 tradingFeeRate, uint16 creatorFeeRate) {
        require(
            tradingFeeRate + creatorFeeRate <= TOTAL_MAX_FEE,
            "Marketplace: Sum of fee cannot exceed TOTAL_MAX_FEE"
        );
        _;
    }

    //Owner functions

    /**
     * @notice Add a new collection
     * @param collection: collection address
     * @param creator: creator address (must be 0x00 if none)
     * @param tradingFeeRate: trading fee (1000 = 10%, 500 = 5%, 100 = 1%, 5 = 0.05%)
     * @param creatorFeeRate: creator fee (1000 = 10%, 500 = 5%, 100 = 1%, 5 = 0.05%, 0 if creator is 0x00)
     * @dev Callable by admin
     */
    function addCollection(
        IERC721 collection,
        address creator,
        uint16 tradingFeeRate,
        uint16 creatorFeeRate,
        bool auctionEnable
    ) public onlyOwner whenFeeNotExceed(tradingFeeRate, creatorFeeRate) {
        require(collections[collection].status == Status.Pending, "Marketplace: Collection already listed");
        require(collection.supportsInterface(0x80ac58cd), "Marketplace: Not ERC721");
        collections[collection] = Collection({
            status: Status.Open,
            creatorAddress: creator,
            creatorFeeRate: creatorFeeRate,
            tradingFeeRate: tradingFeeRate,
            auctionEnable: auctionEnable
        });
        emit AddCollection(collection, creator, creatorFeeRate, tradingFeeRate, auctionEnable);
    }

    /**
     * @notice Modify collection characteristics
     * @param collection: collection address
     * @param creator: creator address (must be 0x00 if none)
     * @param tradingFeeRate: trading fee (100 = 1%, 500 = 5%, 5 = 0.05%)
     * @param creatorFeeRate: creator fee (100 = 1%, 500 = 5%, 5 = 0.05%, 0 if creator is 0x00)
     * @dev Callable by admin
     */
    function updateCollection(
        IERC721 collection,
        address creator,
        uint16 tradingFeeRate,
        uint16 creatorFeeRate,
        bool auctionEnable
    ) public onlyOwner whenCollectionListed(collection) whenFeeNotExceed(tradingFeeRate, creatorFeeRate) {
        Collection storage _collection = collections[collection];
        _collection.creatorAddress = creator;
        _collection.creatorFeeRate = creatorFeeRate;
        _collection.tradingFeeRate = tradingFeeRate;
        _collection.auctionEnable = auctionEnable;
        emit UpdateCollection(collection, creator, creatorFeeRate, tradingFeeRate, auctionEnable);
    }

    function updateCollectionStatus(IERC721 collection, Status status)
        public
        onlyOwner
        whenCollectionListed(collection)
    {
        collections[collection].status = status;
        emit UpdateCollectionStatus(collection, status);
    }

    /**
     * @notice Remove a collection from maketplace
     * @param collection: collection address
     * @dev Callable by admin
     */
    function removeCollection(IERC721 collection) public onlyOwner whenCollectionListed(collection) {
        //TODO("Befire delete collection may be check and close trading in collection")
        delete collections[collection];
        emit RemoveCollection(collection);
    }

    //Public functions

    function isAuctionEnabled(IERC721 collection) public view override returns (bool) {
        return collections[collection].auctionEnable;
    }

    function isCollectionListed(IERC721 collection) public view override returns (bool) {
        return collections[collection].status != Status.Pending;
    }

    function isCollectionOpen(IERC721 collection) public view override returns (bool) {
        return collections[collection].status != Status.Pending && collections[collection].status == Status.Open;
    }

    /**
     * @notice Calculate price and associated fees for a collection
     * @param collection: address of the collection
     * @param price: listed price
     */
    function calculatePriceAndFee(IERC721 collection, uint256 price)
        public
        view
        override
        whenCollectionListed(collection)
        returns (
            uint256 netPrice,
            uint256 tradingFee,
            address creatorAddress,
            uint256 creatorFee
        )
    {
        tradingFee = (price * collections[collection].tradingFeeRate) / BASE_FREE_RATE;
        creatorFee = (price * collections[collection].creatorFeeRate) / BASE_FREE_RATE;
        netPrice = price - tradingFee - creatorFee;
        creatorAddress = collections[collection].creatorAddress;
    }
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICollectionHandler {
    function calculatePriceAndFee(IERC721 collection, uint256 price)
        external
        view
        returns (
            uint256 netPrice,
            uint256 tradingFee,
            address creatorAddress,
            uint256 creatorFee
        );

    function isCollectionListed(IERC721 collection) external view returns (bool);

    function isCollectionOpen(IERC721 collection) external view returns (bool);

    function isAuctionEnabled(IERC721 collection) external view returns (bool);
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