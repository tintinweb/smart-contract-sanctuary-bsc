/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.9.6 https://hardhat.org

// File @openzeppelin/contracts/security/[email protected]

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

// File @openzeppelin/contracts/utils/introspection/[email protected]

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

// File @openzeppelin/contracts/token/ERC721/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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

// File contracts/ERC721OA/IERC721OA.sol
pragma solidity ^0.8.4;

interface IERC721OA is IERC721 {
  function createToken(string memory tokenURI) external returns (uint256);

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
    external
    view
    returns (address receiver, uint256 royaltyAmount);
}

// File @openzeppelin/contracts/token/ERC20/[email protected]

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

// File contracts/NFTMarketOA/StorageOA/IStorageOA.sol
pragma solidity ^0.8.4;

interface IStorageOA {
  // Structur of items stored
  struct StorageItem {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address payable owner;
    uint256 price;
    bool onAuction;
    bool onSale;
    uint256 endTime;
    address highestBidder;
    uint256 highestBid;
    address currency;
    bool isActive;
    address stored;
    bool firstSold;
  }

  // Method to get all actives items
  function getItems() external view returns (StorageItem[] memory);

  // Method to get actives items by collection
  function getItemsByCollection(address collectionAddress) external view returns (StorageItem[] memory);

  // Method to get items by owner
  function getItemsByOwner(address addressOwner) external view returns (StorageItem[] memory);

  // Method to get disabled items by owner
  function getDisabledItemsByOwner(address addressOwner) external view returns (StorageItem[] memory);

  function getItem(uint256 itemId) external view returns (StorageItem memory);

  /* Allows other contract to send this contract's nft */
  function transferItem(uint256 itemId, address to) external;

  function setItem(uint256 itemId, StorageItem memory item) external;

  function setItemAuction(
    uint256 itemId,
    address highestBidder,
    uint256 highestBid
  ) external;

  function createItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    address ownerItem,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price,
    bool firstSold
  ) external;

  function setActiveItem(uint256 itemId, bool isActive) external;
}

// File contracts/utils/ApprovalsGuard.sol
pragma solidity ^0.8.4;

abstract contract ApprovalsGuard {
  // Mapping of approved address to write storage
  mapping(address => bool) private _approvals;
  address internal owner;

  constructor() {
    owner = msg.sender;
  }

  // Modifier to allow only approvals to execute methods
  modifier onlyApprovals() {
    require(_approvals[msg.sender], "You are not allowed to execute this method");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not allowed to execute this method");
    _;
  }

  modifier onlyApprovalsOrOwner() {
    require((msg.sender == owner || _approvals[msg.sender]), "You are not allowed to execute this method");
    _;
  }

  function setApproval(address approveAddress, bool approved) public onlyOwner {
    require(msg.sender == owner, "You are not allowed to execute this function");
    _approvals[approveAddress] = approved;
  }
}

// File contracts/NFTMarketOA/Events/IEvents.sol
pragma solidity ^0.8.4;

interface IEvents {
  event MakeOffer(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    uint256 endTime,
    uint256 date
  );

  event ListItem(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    uint256 date
  );

  event SaleItem(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    uint256 date
  );

  event Cancel(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 date
  );
}

// File contracts/NFTMarketOA/SalesOA/SalesOA.sol
pragma solidity ^0.8.4;

contract SalesOA is ReentrancyGuard, ApprovalsGuard, IEvents {
  address private _addressStorage;
  uint256 private _listingPrice;

  constructor(uint256 listingPrice, address addressStorage) {
    _listingPrice = listingPrice;
    _addressStorage = addressStorage;
  }

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return _listingPrice;
  }

  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketSale(uint256 itemId, address buyer) external payable onlyApprovals nonReentrant {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(item.onSale, "This Item is not on sale.");
    require(item.owner != buyer, "You are the owner of this nft");
    require(item.currency != address(0) || msg.value == item.price, "The value sent must be equals to nft's price");

    uint256 price = item.price;

    address royaltiesReceiver;
    uint256 royaltiesAmount;

    if (item.firstSold) {
      try IERC721OA(item.nftContract).royaltyInfo(item.itemId, item.price) returns (
        address receiver,
        uint256 royaltyAmount
      ) {
        royaltiesReceiver = receiver;
        royaltiesAmount = royaltyAmount;
      } catch {}
    }

    if (item.currency != address(0)) {
      IERC20 erc20 = IERC20(item.currency);

      require(erc20.transferFrom(buyer, address(this), price), "Transaction failed at pay item.");
      if (royaltiesAmount > 0) {
        require(erc20.transfer(royaltiesReceiver, royaltiesAmount), "Transaction failed");
      }
      require(
        erc20.transfer(item.owner, (price - ((price * _listingPrice) / 100) - royaltiesAmount)) &&
          erc20.transfer(owner, ((price * _listingPrice) / 100)),
        "Transaction failed at pay item"
      );
    } else {
      if (royaltiesAmount > 0) {
        payable(royaltiesReceiver).transfer(royaltiesAmount);
      }
      payable(item.owner).transfer((price - ((price * _listingPrice) / 100) - royaltiesAmount));
      payable(owner).transfer(((price * _listingPrice) / 100));
    }
    emit SaleItem(item.owner, buyer, itemId, item.nftContract, item.tokenId, price, block.timestamp);
    iStorage.transferItem(itemId, buyer);
  }

  /* Change listing price in hundredths*/
  function setListingPrice(uint256 percent) public onlyOwner {
    _listingPrice = percent;
  }

  /* Put on sale */
  function activateSale(
    uint256 itemId,
    uint256 price,
    address currency,
    address seller
  ) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(seller == item.owner, "You are not owner of this nft");
    require(!item.onSale, "This item is on sale already");
    require(!item.onAuction, "This item is currently on auction");
    IERC721(item.nftContract).transferFrom(item.owner, _addressStorage, item.tokenId);
    item.owner = payable(seller);
    item.price = price;
    item.onSale = true;
    item.endTime = 0;
    item.currency = currency;
    item.stored = _addressStorage;
    iStorage.setItem(itemId, item);
    emit ListItem(seller, address(0), itemId, item.nftContract, item.tokenId, price, block.timestamp);
  }

  /* Remove from sale */
  function deactivateSale(uint256 itemId, address seller) public onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(seller == item.owner, "You are not owner of this nft");
    iStorage.transferItem(itemId, seller);
    emit Cancel(seller, address(0), itemId, item.nftContract, item.tokenId, block.timestamp);
  }

  /* Set storage address */
  function setStorageAddress(address addressStorage) public onlyOwner {
    _addressStorage = addressStorage;
  }
}