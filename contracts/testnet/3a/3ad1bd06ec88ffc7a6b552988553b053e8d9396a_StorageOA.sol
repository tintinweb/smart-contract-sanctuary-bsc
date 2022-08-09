/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.9.6 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

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


// File contracts/NFTMarketOA/NFTMarketOA/INFTMarketOA.sol
pragma solidity ^0.8.4;

interface INFTMarketOA {
  struct MarketItem {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address payable owner;
    uint256 price;
    bool sold;
    bool onAuction;
    bool onSale;
    uint256 endTime;
    address highestBidder;
    uint256 highestBid;
    address currency;
    bool isActive;
  }

  function myallowance(address currency) external view returns (uint256);

  function getListingPrice() external view returns (uint256);

  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    bool isActive
  ) external;

  function createMarketSale(address nftContract, uint256 itemId) external payable;

  function fetchMarketItems() external returns (MarketItem[] memory);

  function fetchCollectionItems(address collectionAddress) external returns (MarketItem[] memory);

  function fetchMyNFTs() external view returns (MarketItem[] memory);

  function fetchMyDisabledNFTs() external view returns (MarketItem[] memory);

  function fetchMyActiveNFTs() external view returns (MarketItem[] memory);

  function fetchItemsCreated() external view returns (MarketItem[] memory);

  function getItem(uint256 itemId) external view returns (MarketItem memory);

  function setListingPrice(uint256 percent) external;

  function activateSale(
    uint256 itemId,
    uint256 price,
    address currency
  ) external;

  function deactivateSale(uint256 itemId) external;

  function activateAuction(
    uint256 itemId,
    uint256 endTime,
    uint256 minBid,
    address currency
  ) external;

  function bid(uint256 itemId, uint256 bidAmount) external;

  function auctionEnd(uint256 itemId) external;

  function collectNFT(address nftContract, uint256 itemId) external;

  function approvalForTransfer(address addressContract) external;

  function transferNFT(
    address nftContract,
    address to,
    uint256 nftId
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


// File contracts/NFTMarketOA/StorageOA/StorageOA.sol
pragma solidity ^0.8.4;




contract StorageOA is ApprovalsGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;

  // Address allowed to create items without owner verification
  address private _trustedAddress;

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

  mapping(uint256 => StorageItem) private storedItems;

  constructor(address addressBackup) {
    if (addressBackup == address(0)) return;
    try INFTMarketOA(addressBackup).fetchMarketItems() returns (INFTMarketOA.MarketItem[] memory oldData) {
      for (uint256 item = 0; item < oldData.length; item++) {
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        storedItems[itemId] = StorageItem(
          itemId,
          oldData[item].nftContract,
          oldData[item].tokenId,
          payable(oldData[item].owner),
          oldData[item].price,
          oldData[item].onAuction,
          oldData[item].onSale,
          oldData[item].endTime,
          oldData[item].highestBidder,
          oldData[item].highestBid,
          oldData[item].currency,
          oldData[item].isActive,
          address(0),
          true
        );
      }
    } catch {
      return;
    }
  }

  event ItemCreated(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address owner);

  // Method to get all actives items
  function getItems() external view returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Method to get actives items by collection
  function getItemsByCollection(address collectionAddress) external view returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].nftContract == collectionAddress && storedItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].nftContract == collectionAddress && storedItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Method to get items by owner
  function getItemsByOwner(address addressOwner) external view returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Method to get disabled items by owner
  function getDisabledItemsByOwner(address addressOwner) external view onlyApprovals returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner && !storedItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner && !storedItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  function getItem(uint256 itemId) public view returns (StorageItem memory) {
    return storedItems[itemId];
  }

  /* Allows other contract to send this contract's nft */
  function transferItem(uint256 itemId, address to) external onlyApprovals {
    address nftContract = storedItems[itemId].nftContract;
    uint256 nftId = storedItems[itemId].tokenId;
    IERC721(nftContract).safeTransferFrom(address(this), to, nftId);
    storedItems[itemId].owner = payable(to);
    storedItems[itemId].onAuction = false;
    storedItems[itemId].onSale = false;
    storedItems[itemId].stored = address(0);
    storedItems[itemId].highestBidder = address(0);
    storedItems[itemId].highestBid = 0;
    if (!storedItems[itemId].firstSold) {
      storedItems[itemId].firstSold = true;
    }
  }

  function setItem(uint256 itemId, StorageItem memory item) external onlyApprovals {
    storedItems[itemId].owner = item.owner;
    storedItems[itemId].price = item.price;
    storedItems[itemId].onAuction = item.onAuction;
    storedItems[itemId].onSale = item.onSale;
    storedItems[itemId].endTime = item.endTime;
    storedItems[itemId].highestBidder = item.highestBidder;
    storedItems[itemId].highestBid = item.highestBid;
    storedItems[itemId].currency = item.currency;
    storedItems[itemId].isActive = item.isActive;
    storedItems[itemId].stored = item.stored;
  }

  function setItemAuction(
    uint256 itemId,
    address highestBidder,
    uint256 highestBid
  ) external onlyApprovals {
    storedItems[itemId].highestBidder = highestBidder;
    storedItems[itemId].highestBid = highestBid;
  }

  function createItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    address ownerItem,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price
  ) external onlyApprovals {
    require(IERC721(nftContract).ownerOf(tokenId) == ownerItem, "You are not owner of this nft.");
    require(((price > 0 && (onAuction || onSale)) || (!onAuction && !onSale)), "Price must be greater than 0");

    _createItem(
      StorageItem(
        0,
        nftContract,
        tokenId,
        payable(ownerItem),
        price,
        onAuction,
        onSale,
        endTime,
        address(0),
        0,
        currency,
        isActive,
        address(0),
        true
      )
    );
  }

  function trustedCreateItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    address ownerItem,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price,
    address highestBidder,
    uint256 highestBid
  ) external {
    require(msg.sender == _trustedAddress, "You can't execute this function");
    require(((price > 0 && (onAuction || onSale)) || (!onAuction && !onSale)), "Price must be greater than 0");
    _createItem(
      StorageItem(
        0,
        nftContract,
        tokenId,
        payable(ownerItem),
        price,
        onAuction,
        onSale,
        endTime,
        highestBidder,
        highestBid,
        currency,
        isActive,
        address(this),
        false
      )
    );
  }

  function _createItem(StorageItem memory item) private {
    _itemIds.increment();
    uint256 itemId = _itemIds.current();
    storedItems[itemId] = StorageItem(
      itemId,
      item.nftContract,
      item.tokenId,
      payable(item.owner),
      item.price,
      item.onAuction,
      item.onSale,
      item.endTime,
      item.highestBidder,
      item.highestBid,
      item.currency,
      item.isActive,
      item.stored,
      item.firstSold
    );

    emit ItemCreated(itemId, item.nftContract, item.tokenId, item.owner);
  }

  function setTrustedAddress(address trustedAddress) external {
    require(msg.sender == owner, "You're not allowed to execute this function");
    _trustedAddress = trustedAddress;
  }

  function setActiveItem(uint256 itemId, bool isActive) external {
    require(
      msg.sender == owner || msg.sender == storedItems[itemId].owner,
      "You are not allowed to modify this element"
    );
    storedItems[itemId].isActive = isActive;
  }
}