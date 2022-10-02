// SPDX-License-Identifier: SEE LICENSE IN LICENSE
import "@openzeppelin/contracts/interfaces/IERC721.sol";
pragma solidity ^0.8.7;

error Marketplace_PriceIsToLow();
error Marketplace_ApprovalIsMissing();
error Marketplace__OnlyForOwner();
error Marketplace__AlreadyListed(address nftAddress, uint256 tokenId);
error Marketplace__ThereIsNoTokenWithThisTokenId(
    uint256 tokenId,
    address nftContract
);
error Marketplace__PriceIsNotEnough(uint256 priceNeeded);
error Marketplace__OnlyOwnerCanCancel(address owner);
error Marketplace__WrongAmount();
error Marketplace__TransferFailed();

contract Marketplace {
    constructor() {}

    event NewItemListed(
        uint256 indexed tokenId,
        uint256 price,
        address indexed nftContract,
        address indexed seller
    );
    event ItemBought(
        uint256 indexed tokenId,
        address indexed nftContract,
        address indexed buyer,
        uint256 price
    );
    event ItemCanceled(
        address indexed owner,
        address indexed nftContract,
        uint256 indexed tokenId
    );
    event ItemUpdated(
        address indexed owner,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 price
    );

    struct Listing {
        uint256 price;
        address seller;
    }

    //NFT contract address -> NFT TokenID -> Listing

    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_sellerToEarnings;

    modifier notListed(uint256 tokenId, address nftContract) {
        Listing memory listing = s_listings[nftContract][tokenId];
        if (listing.price > 0) {
            revert Marketplace__AlreadyListed(nftContract, tokenId);
        }
        _;
    }
    modifier onlyForOwner(
        uint256 tokenId,
        address nftContract,
        address sender
    ) {
        Listing memory listing = s_listings[nftContract][tokenId];
        if (listing.seller != sender) {
            revert Marketplace__OnlyForOwner();
        }
        _;
    }

    // Main functions
    // listItem
    // buyItem
    // cancelItem
    // updateListing
    // withdrawProceeds

    function listItem(
        uint256 price,
        uint256 tokenId,
        address nftContract
    ) external notListed(tokenId, nftContract) {
        if (price <= 0) {
            revert Marketplace_PriceIsToLow();
        }
        // Users hold Nft and give marketplace only approval
        if (IERC721(nftContract).getApproved(tokenId) != address(this)) {
            revert Marketplace_ApprovalIsMissing();
        }

        if (IERC721(nftContract).ownerOf(tokenId) != msg.sender) {
            revert Marketplace__OnlyForOwner();
        }

        s_listings[nftContract][tokenId] = Listing(price, msg.sender);

        emit NewItemListed(tokenId, price, nftContract, msg.sender);
    }

    function buyItem(uint256 tokenId, address nftContract) external payable {
        Listing memory listing = s_listings[nftContract][tokenId];
        if (listing.price <= 0) {
            revert Marketplace__ThereIsNoTokenWithThisTokenId(
                tokenId,
                nftContract
            );
        }
        if (msg.value <= listing.price) {
            revert Marketplace__PriceIsNotEnough(listing.price);
        }
        s_sellerToEarnings[listing.seller] = listing.price;
        delete (s_listings[nftContract][tokenId]);
        // Cначала меняем весь state , потом делаем transfer nft. Это защита от reentrancy attack
        IERC721(nftContract).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );
        emit ItemBought(tokenId, nftContract, msg.sender, listing.price);
    }

    function cancelListing(address nftContract, uint256 tokenId)
        external
        onlyForOwner(tokenId, nftContract, msg.sender)
    {
        Listing memory listing = s_listings[nftContract][tokenId];
        delete (s_listings[nftContract][tokenId]);
        emit ItemCanceled(msg.sender, nftContract, tokenId);
    }

    function updateListing(
        address nftContract,
        uint256 tokenId,
        uint256 newPrice
    ) external onlyForOwner(tokenId, nftContract, msg.sender) {
        s_listings[nftContract][tokenId].price = newPrice;
        emit ItemUpdated(msg.sender, nftContract, tokenId, newPrice);
    }

    function withdrawProceeds() external {
        if (s_sellerToEarnings[msg.sender] <= 0) {
            revert Marketplace__WrongAmount();
        }
        s_sellerToEarnings[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{
            value: s_sellerToEarnings[msg.sender]
        }("");
        if (!success) {
            revert Marketplace__TransferFailed();
        }
    }

    // Getter functions TODO:
    function getListing(address addr, uint256 tokenId)
        public
        view
        returns (Listing memory)
    {
        return s_listings[addr][tokenId];
    }

    function getSellerEarnings(address addr) public view returns (uint256) {
        return s_sellerToEarnings[addr];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

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