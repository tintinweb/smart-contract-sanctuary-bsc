// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(string concert);
error ItemNotExists(string concert, uint256 tokenId);
error AlreadyListed(string concert, uint256 tokenId);
error ConcertNotExists(string concert);
error ConcertAlreadyExists(string concert);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();
error StartDateMustLowerThanEndDate();
error TicketSaleNotStartYet();
error TicketSaleEnded();
error TicketsAreSelling();

contract Marketplace is ReentrancyGuard, Ownable {
    struct Concert {
        uint256 start_date;
        uint256 end_date;
        uint256 price;
        uint256[] tokenIds;
    }

    string[] listConcerts;

    // State Variables
    mapping(string => Concert) private s_concerts;
    mapping(string => uint256) private s_counts;
    mapping(string => uint256) private s_totals;
    mapping(address => uint256) private s_proceeds;

    // List modifiers
    modifier notListed(string memory concert, uint256[] memory tokenIds) {
        Concert memory _concert = s_concerts[concert];
        if (_concert.price > 0 && _concert.end_date > block.timestamp) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenId = tokenIds[i];
                for (uint256 j = 0; i < _concert.tokenIds.length; j++) {
                    if (_concert.tokenIds[j] == tokenId) {
                        revert AlreadyListed(concert, tokenId);
                    }
                }
            }
        }
        _;
    }

    modifier isListed(string memory concert) {
        Concert memory _concert = s_concerts[concert];
        if (_concert.price == 0) {
            revert NotListed(concert);
        }
        if (_concert.end_date < block.timestamp) {
            revert NotListed(concert);
        }
        _;
    }

    modifier isItemExists(string memory concert, uint256 tokenId) {
        Concert memory _concert = s_concerts[concert];
        for (uint256 i = 0; i < _concert.tokenIds.length; i++) {
            if (_concert.tokenIds[i] == tokenId) {
                _;
            }
        }

        revert ItemNotExists(concert, tokenId);
    }

    // List Events
    event ItemListed(
        string indexed concert,
        address indexed nftAddress,
        uint256 price
    );

    event ItemCanceled(string indexed concert, address indexed nftAddress);

    event ItemBought(string concert, uint256 tokenId, uint256 price);

    // List functions
    function listItem(
        address nftAddress,
        uint256[] memory tokenIds,
        uint256 price,
        string memory concert,
        uint256 start_date,
        uint256 end_date
    ) external notListed(concert, tokenIds) onlyOwner {
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }
        if (start_date > end_date) {
            revert StartDateMustLowerThanEndDate();
        }
        IERC721 nft = IERC721(nftAddress);
        address owner = owner();
        if (nft.isApprovedForAll(owner, address(this)) == false) {
            revert NotApprovedForMarketplace();
        }
        s_totals[concert] += tokenIds.length;
        s_counts[concert] += tokenIds.length;
        s_concerts[concert] = Concert(start_date, end_date, price, tokenIds);
        listConcerts.push(concert);
        emit ItemListed(concert, nftAddress, price);
    }

    function cancelListingConcert(address nftAddress, string memory concert)
        external
        isListed(concert)
        onlyOwner
    {
        Concert memory _concert = s_concerts[concert];
        // check if ticket are selling or not
        if (block.timestamp > _concert.start_date) {
            revert TicketsAreSelling();
        }

        delete s_concerts[concert];
        delete s_counts[concert];
        delete s_totals[concert];

        for (uint256 i = 0; i < listConcerts.length; i++) {
            if (
                keccak256(abi.encodePacked((listConcerts[i]))) ==
                keccak256(abi.encodePacked((concert)))
            ) {
                listConcerts[i] = listConcerts[listConcerts.length - 1];
                listConcerts.pop();
            }
        }

        emit ItemCanceled(concert, nftAddress);
    }

    function removeTokenId(uint256 index, string memory concert) private {
        if (index >= s_concerts[concert].tokenIds.length) return;

        for (
            uint256 i = index;
            i < s_concerts[concert].tokenIds.length - 1;
            i++
        ) {
            s_concerts[concert].tokenIds[i] = s_concerts[concert].tokenIds[
                i + 1
            ];
        }
        s_concerts[concert].tokenIds.pop();
    }

    function buyItem(
        address nftAddress,
        uint256 tokenId,
        address admin,
        string memory concert
    ) external payable isItemExists(concert, tokenId) nonReentrant {
        Concert memory _concert = s_concerts[concert];
        require(
            block.timestamp >= _concert.start_date,
            "Ticket Not For Sale Yet"
        );
        require(block.timestamp <= _concert.end_date, "Ticket Sale Are Ended");
        require(msg.value >= _concert.price, "Price Not Met");
        s_proceeds[admin] += msg.value;
        //s_counts[concert] = s_counts[concert] - 1;

        IERC721(nftAddress).safeTransferFrom(admin, msg.sender, tokenId);
        emit ItemBought(concert, tokenId, msg.value);
    }

    function updatePrice(
        address nftAddress,
        uint256 newPrice,
        string memory concert
    ) external isListed(concert) nonReentrant onlyOwner {
        if (newPrice == 0) {
            revert PriceMustBeAboveZero();
        }

        s_concerts[concert].price = newPrice;
        emit ItemListed(concert, nftAddress, newPrice);
    }

    function withdrawProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        s_proceeds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    function getConeptByCid(string memory concert)
        external
        view
        returns (Concert memory)
    {
        return s_concerts[concert];
    }

    function getProceeds(address _owner) external view returns (uint256) {
        return s_proceeds[_owner];
    }

    function getTotal(string memory concert) external view returns (uint256) {
        return s_totals[concert];
    }

    function getCount(string memory concert) external view returns (uint256) {
        return s_counts[concert];
    }

    function getAllConcerts() external view returns (string[] memory) {
        return listConcerts;
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