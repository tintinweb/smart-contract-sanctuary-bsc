// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/ICollectionHandler.sol";

contract PlearnNFTCollectionHandler is ICollectionHandler, Ownable {
    uint256 public constant TOTAL_MAX_FEE = 1000; //(1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05% when divide 10000)

    enum Status {
        Pending,
        Open,
        Close
    }

    struct Collection {
        Status status; // status of the collection
        address creatorAddress; // address of the creator
        uint256 creatorFee; // creator fee (1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05%)
        uint256 tradingFee; // trading fee (1000 = 10%, 100 = 1%, 500 = 5%, 5 = 0.05%)
        bool auctionEnable;
    }

    //Collection (ERC721)
    mapping(IERC721 => Collection) public collections; // Details about the collections

    event AddOrUpdateCollection(
        IERC721 indexed collection,
        address indexed creator,
        uint256 creatorFee,
        uint256 tradingFee,
        bool auctionEnable
    );
    event UpdateCollectionStatus(IERC721 indexed collection, Status status);
    event RemoveCollection(IERC721 indexed collection);
    event AddNFTTokens(IERC721 indexed collection, uint256[] tokenIds);

    modifier collectionListed(IERC721 collection) {
        require(
            _collectionIsListed(collection),
            "Marketplace: Collection not listed"
        );
        _;
    }

    //Owner functions

    /**
     * @notice Add a new collection
     * @param collection: collection address
     * @param creator: creator address (must be 0x00 if none)
     * @param creatorFee: creator fee (1000 = 10%, 500 = 5%, 100 = 1%, 5 = 0.05%, 0 if creator is 0x00)
     * @param tradingFee: trading fee (1000 = 10%, 500 = 5%, 100 = 1%, 5 = 0.05%)
     * @dev Callable by admin
     */
    function addCollection(
        IERC721 collection,
        address creator,
        uint256 creatorFee,
        uint256 tradingFee,
        bool auctionEnable
    ) external onlyOwner {
        require(
            collections[collection].status == Status.Pending,
            "Marketplace: Collection already listed"
        );
        require(
            IERC721(collection).supportsInterface(0x80ac58cd),
            "Marketplace: Not ERC721"
        );
        require(
            (creatorFee == 0 && creator == address(0)) ||
                (creatorFee != 0 && creator != address(0)),
            "Marketplace: Creator parameters incorrect"
        );
        require(
            tradingFee + creatorFee <= TOTAL_MAX_FEE,
            "Marketplace: Sum of fee must inferior to TOTAL_MAX_FEE"
        );

        collections[collection] = Collection({
            status: Status.Open,
            creatorAddress: creator,
            creatorFee: creatorFee,
            tradingFee: tradingFee,
            auctionEnable: auctionEnable
        });
        emit AddOrUpdateCollection(
            collection,
            creator,
            creatorFee,
            tradingFee,
            auctionEnable
        );
    }

    /**
     * @notice Modify collection characteristics
     * @param collection: collection address
     * @param creator: creator address (must be 0x00 if none)
     * @param creatorFee: creator fee (100 = 1%, 500 = 5%, 5 = 0.05%, 0 if creator is 0x00)
     * @param tradingFee: trading fee (100 = 1%, 500 = 5%, 5 = 0.05%)
     * @dev Callable by admin
     */
    function updateCollection(
        IERC721 collection,
        address creator,
        uint256 creatorFee,
        uint256 tradingFee,
        bool auctionEnable
    ) external onlyOwner collectionListed(collection) {
        require(
            (creatorFee == 0 && creator == address(0)) ||
                (creatorFee != 0 && creator != address(0)),
            "Marketplace: Creator parameters incorrect"
        );
        require(
            tradingFee + creatorFee <= TOTAL_MAX_FEE,
            "Marketplace: Sum of fee must inferior to TOTAL_MAX_FEE"
        );

        collections[collection] = Collection({
            status: Status.Open,
            creatorAddress: creator,
            creatorFee: creatorFee,
            tradingFee: tradingFee,
            auctionEnable: auctionEnable
        });
        emit AddOrUpdateCollection(
            collection,
            creator,
            creatorFee,
            tradingFee,
            auctionEnable
        );
    }

    function updateCollectionStatus(IERC721 collection, Status status)
        external
        onlyOwner
        collectionListed(collection)
    {
        collections[collection].status = status;
        emit UpdateCollectionStatus(collection, status);
    }

    /**
     * @notice Remove a collection from maketplace
     * @param collection: collection address
     * @dev Callable by admin
     */
    function removeCollection(IERC721 collection)
        external
        onlyOwner
        collectionListed(collection)
    {
        //TODO("Befire delete collection may be check and close trading in collection")
        delete collections[collection];
        emit RemoveCollection(collection);
    }

    function addNFTTokens(IERC721 collection, uint256[] memory tokenIds)
        external
        onlyOwner
        collectionListed(collection)
    {
        emit AddNFTTokens(collection, tokenIds);
    }

    //Public functions

    function auctionEnabled(IERC721 collection)
        external
        view
        override
        collectionListed(collection)
        returns (bool)
    {
        return collections[collection].auctionEnable;
    }

    function collectionIsListed(IERC721 collection)
        external
        view
        override
        collectionListed(collection)
        returns (bool)
    {
        return true;
    }

    function collectionIsOpened(IERC721 collection)
        external
        view
        override
        collectionListed(collection)
        returns (bool)
    {
        require(
            _collectionIsOpened(collection),
            "Marketplace: Collection not opened"
        );
        return true;
    }

    function getCollectionFee(IERC721 collection)
        external
        view
        override
        collectionListed(collection)
        returns (uint256 tradingFee, uint256 creatorFee)
    {
        return (
            collections[collection].tradingFee,
            collections[collection].creatorFee
        );
    }

    function getCreatorAddress(IERC721 collection)
        external
        view
        override
        collectionListed(collection)
        returns (address)
    {
        return collections[collection].creatorAddress;
    }

    //Internal functions

    function _collectionIsListed(IERC721 collection)
        internal
        view
        returns (bool)
    {
        return collections[collection].status != Status.Pending;
    }

    function _collectionIsOpened(IERC721 collection)
        internal
        view
        returns (bool)
    {
        return collections[collection].status == Status.Open;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICollectionHandler {
    function collectionIsListed(IERC721 collection)
        external
        view
        returns (bool);

    function collectionIsOpened(IERC721 collection)
        external
        view
        returns (bool);

    function getCollectionFee(IERC721 collection)
        external
        view
        returns (uint256 tradingFee, uint256 creatorFee);

    function getCreatorAddress(IERC721 collection)
        external
        view
        returns (address);

    function auctionEnabled(IERC721 collection) external view returns (bool);
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