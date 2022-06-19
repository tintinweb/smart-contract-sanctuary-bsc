// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "Counters.sol";
import "ReentrancyGuard.sol";
import "ERC721.sol";
import "Ownable.sol";
import "CardinalNFT.sol";
import "CardinalToken.sol";

/**
 * @title Cardinal House NFT Marketplace Contract
 * @dev NFT marketplace contract that users will interact with on the Cardinal House website
 */
contract CardinalHouseMarketplace is ReentrancyGuard, Ownable {
  using Counters for Counters.Counter;

  // Counter to give each marketplace item a unique ID.
  Counters.Counter public _itemIds;

  // Counter to keep track of how many items have been sold on the Cardinal House marketplace.
  Counters.Counter public _itemsSold;

  // The default listing fee for any users that want to resell their Cardinal NFTs.
  uint256 defaultListingPrice = 0 ether;

  // Properties of a Cardinal NFT on the marketplace.
  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
    string tokenURI;
    uint256 listingPrice;
  }

  // Maps each NFT's marketplace item ID to all of the properties for the NFT on the marketplace.
  mapping(uint256 => MarketItem) public idToMarketItem;

  // If the NFT contract address ever changes, this mapping keeps track of past NFT contract addresses
  // so that users can still sell NFTs minted with the old contract on the marketplace. If a user tries
  // to sell an NFT from a contract that isn't true in this mapping, it will be rejected.
  mapping (address => bool) public addressToPreviousNFTAddress;

  // Blacklist mapping for listing and purchasing Cardinal NFTs.
  // If this mapping is true for an address then they can't use the marketplace.
  mapping (address => bool) public blacklist;

  // Event emitted whenever a Cardinal NFT is put up for sale on the Cardinal House marketplace.
  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold,
    string tokenURI,
    uint256 listingPrice
  );

  // References the deployed Cardinal Token.
  CardinalToken public cardinalToken;

  // References the deployed Cardinal NFT contract.
  CardinalNFT public cardinalNFT;

  constructor(address payable CardinalTokenAddress) {
    cardinalToken = CardinalToken(CardinalTokenAddress);
  }

  /**
  * @dev Gets the listing price for listing an NFT on the marketplace
  * @return the current listing price
  */
  function getDefaultListingPrice() public view returns (uint256) {
    return defaultListingPrice;
  }

  /**
  * @dev Only owner function to set the listing price
  * @param newDefaultListingPrice the new default listing price
  */
  function setDefaultListingPrice(uint256 newDefaultListingPrice) public onlyOwner {
      defaultListingPrice = newDefaultListingPrice;
  }

  /**
  * @dev Only owner function to set the reference to the Cardinal Token (CRNL)
  * @param CardinalTokenAddress the contract address for the Cardinal Token
  */
  function setCardinalToken(address payable CardinalTokenAddress) public onlyOwner {
      cardinalToken = CardinalToken(CardinalTokenAddress);
  }

  /**
  * @dev Only owner function to set the reference to the Cardinal NFT contract
  * @param CardinalNFTAddress the address for the Cardinal NFT contract
  */
  function setCardinalNFT(address payable CardinalNFTAddress) public onlyOwner {
      cardinalNFT = CardinalNFT(CardinalNFTAddress);
      addressToPreviousNFTAddress[CardinalNFTAddress] = true;
  }
  
  /**
  * @dev Function to list a Cardinal NFT on the marketplace
  * @param nftContract contract that the NFT was minted on. Only accepts Cardinal NFT contract addresses
  * @param tokenId the token ID of the NFT on the NFT contract
  * @param price the price of the token in Cardinal Tokens (CRNL)
  */
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price
  ) public payable nonReentrant {
    require(addressToPreviousNFTAddress[nftContract], "This isn't a valid Cardinal NFT contract.");
    require(!blacklist[msg.sender], "You have been blacklisted from the Cardinal House NFT marketplace. If you think this is an error, please contact the Cardinal House team.");
    require(price > 0, "The NFT price must be at least 1 wei.");

    uint256 nftListingPrice = cardinalNFT.tokenIdToListingFee(tokenId);
    if (nftListingPrice == 0) {
      nftListingPrice = defaultListingPrice;
    }

    if (msg.sender != owner() && nftListingPrice > 0) {
        require(msg.value == nftListingPrice, "Not enough or too much Matic was sent to pay the NFT listing fee.");
    }
    else if (nftListingPrice > 0) {
      payable(owner()).transfer(msg.value);
    }

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
  
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false,
      IERC721Metadata(nftContract).tokenURI(tokenId),
      nftListingPrice
    );

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(
      itemId,
      nftContract,
      tokenId,
      msg.sender,
      address(0),
      price,
      false,
      IERC721Metadata(nftContract).tokenURI(tokenId),
      nftListingPrice
    );
  }

  /**
  * @dev Creates the sale of a marketplace item. Transfers ownership of the NFT and sends funds to the seller
  * @param nftContract contract that the NFT was minted on. Only accepts Cardinal NFT contract addresses
  * @param itemId the item ID of the NFT on the marketplace
  * @param amountIn the amount of Cardinal Token the user is supplying to purchase the NFT
  */
  function createMarketSale(
    address nftContract,
    uint256 itemId,
    uint256 amountIn
    ) public nonReentrant {
    require(addressToPreviousNFTAddress[nftContract], "This isn't a valid Cardinal NFT contract.");
    require(!blacklist[msg.sender], "You have been blacklisted from the Cardinal House NFT marketplace. If you think this is an error, please contact the Cardinal House team.");
    require(!idToMarketItem[itemId].sold, "This marketplace item has already been sold.");

    uint tokenId = idToMarketItem[itemId].tokenId;
    if (cardinalNFT.tokenIdToWhitelistAddress(tokenId) != address(0) && idToMarketItem[itemId].seller == owner()) {
      require(msg.sender == cardinalNFT.tokenIdToWhitelistAddress(tokenId), "This NFT has been assigned to someone through a Whitelist spot. Only they can purchase this NFT.");
    }

    uint price = idToMarketItem[itemId].price;
    require(amountIn == price, "Please submit the asking price in order to complete the purchase.");

    cardinalToken.transferFrom(msg.sender, idToMarketItem[itemId].seller, amountIn);

    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    idToMarketItem[itemId].owner = payable(msg.sender);
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();

    if (idToMarketItem[itemId].seller != owner() && idToMarketItem[itemId].listingPrice > 0) {
      payable(owner()).transfer(idToMarketItem[itemId].listingPrice);
    }
  }

  /**
  * @dev Cancels an NFT listing on the marketplace and returns the listing fee to the seller
  * @param nftContract contract that the NFT was minted on. Only accepts Cardinal NFT contract addresses
  * @param itemId the item ID of the NFT on the marketplace
  */
  function cancelMarketSale(
    address nftContract,
    uint256 itemId
    ) public nonReentrant {
    require(addressToPreviousNFTAddress[nftContract], "This isn't a valid Cardinal NFT contract.");
    require(!blacklist[msg.sender], "You have been blacklisted from the Cardinal House NFT marketplace. If you think this is an error, please contact the Cardinal House team.");
    uint tokenId = idToMarketItem[itemId].tokenId;
    address itemSeller = idToMarketItem[itemId].seller;
    bool itemSold = idToMarketItem[itemId].sold;
    require(itemSeller == msg.sender || msg.sender == owner(), "You can only cancel your own NFT listings.");
    require(!itemSold, "This NFT has already been sold.");

    IERC721(nftContract).transferFrom(address(this), idToMarketItem[itemId].seller, tokenId);
    idToMarketItem[itemId].owner = payable(idToMarketItem[itemId].seller);
    idToMarketItem[itemId].sold = true;
    _itemsSold.increment();
    if (idToMarketItem[itemId].seller != owner() && idToMarketItem[itemId].listingPrice > 0) {
        payable(idToMarketItem[itemId].seller).transfer(idToMarketItem[itemId].listingPrice);
    }
  }

  /**
  * @dev Returns all unsold market items
  * @return the list of market items that haven't been sold
  */
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0)) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /**
  * @dev Returns only items that a user has purchased
  * @param user the user to fetch the NFTs for
  * @return the list of market items the user owners
  */
  function fetchMyNFTs(address user) public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == user) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == user) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /**
  * @dev Returns only items a user has created
  * @param user the user to fetch the items created for
  * @return the list of market items the user has put on the market
  */
  function fetchItemsCreated(address user) public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == user) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == user) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /**
  * @dev Returns only items a user has created that are currently for sale
  * @param user the user to fetch the unsold market items for
  * @return the list of market items the user has put on the market that are currently for sale
  */
  function fetchUnsoldItemsCreated(address user) public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == user && !idToMarketItem[i + 1].sold) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == user && !idToMarketItem[i + 1].sold) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /**
  * @dev Updates the blacklist mapping for a given address
  * @param user the address that is being added or removed from the blacklist
  * @param blacklisted a boolean that determines if the given address is being added or removed from the blacklist
  */
  function updateBlackList(address user, bool blacklisted) public onlyOwner {
    blacklist[user] = blacklisted;
  }

}

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "IERC721.sol";
import "IERC721Receiver.sol";
import "IERC721Metadata.sol";
import "Address.sol";
import "Context.sol";
import "Strings.sol";
import "ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "IERC165.sol";

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "IERC165.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
pragma solidity >=0.8.0 <0.9.0;

import "Counters.sol";
import "ERC721URIStorage.sol";
import "ERC721.sol";
import "Ownable.sol";
import "CardinalToken.sol";

/**
 * @title Cardinal House NFT Contract
 * @dev NFT contract that will be used with the marketplace contract
 */
contract CardinalNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    // Counter to give each NFT a unique ID.
    Counters.Counter public _tokenIds;

    // Address of the Cardinal NFT marketplace.
    address public marketplaceAddress;

    // Contract for the Cardinal Token (CRNL).
    CardinalToken public cardinalToken;

    // Each NFT will be associated with an ID that determines the type of NFT it is
    // This makes it easy to identify sets of NFTs like Original Cardinal NFTs, membership NFTs, and service NFTs
    mapping(uint256 => uint256) public tokenIdToTypeId;

    // Each NFT will have a unique listing fee that is kept track of in this mapping.
    mapping(uint256 => uint256) public tokenIdToListingFee;
    
    // Mapping of token ID to address for whitelist spots.
    mapping(uint256 => address) public tokenIdToWhitelistAddress;

    // Mapping to determine if an address has a membership (either Original Cardinal NFT or membership NFT)
    mapping(address => bool) public addressIsMember;

    // Mapping to determine the number of membership NFTs an address has (especially if they have Original Cardinal NFT and membership NFT)
    mapping(address => uint256) public addressToMemberNFTCount;

    // Maps each membership NFT ID to the last block timestamp that the membership was paid for.
    mapping(uint256 => uint256) public membershipNFTToLastPaid;

    // The type ID for the Original Cardinal NFTs.
    uint256 public originalCardinalTypeId = 1;

    // The type ID for the membership NFTs.
    uint256 public membershipTypeId = 2;

    // The type ID for the service NFTs.
    uint256 public serviceTypeId = 3;

    // Array of the Original Cardinal token IDs.
    uint256[] public originalCardinalTokenIds;

    // Array of the membership token IDs.
    uint256[] public membershipTokenIds;

    // The token URI for all membership NFTs
    string public membershipTokenURI;

    // The current price of the membership NFT in Cardinal Tokens
    uint256 public membershipPriceInCardinalTokens;

    constructor(address _marketplaceAddress, address payable _cardinalTokenAddress) ERC721("CardinalHouseNFT", "CRNLNFT") {
        marketplaceAddress = _marketplaceAddress;
        cardinalToken = CardinalToken(_cardinalTokenAddress);
    }

    /**
    * @dev Only owner function to burn a membership NFT
    * @param tokenId the tokenId of the membership NFT to burn
     */
    function burnMembershipNFT(uint256 tokenId) private {
        for (uint i = 0; i < membershipTokenIds.length; i++) {
            if (membershipTokenIds[i] == tokenId) {
                address NFTOwner = ownerOf(membershipTokenIds[i]);
                _transfer(NFTOwner, address(this), membershipTokenIds[i]);

                membershipTokenIds[i] = membershipTokenIds[membershipTokenIds.length-1];
                membershipTokenIds.pop();
            }
        }
    }

    /**
    * @dev Only owner function to burn a membership NFT
    * @param tokenId the tokenId of the membership NFT to burn
     */
    function burnMembershiptNFTManually(uint256 tokenId) public onlyOwner {
        burnMembershipNFT(tokenId);
    }

    /**
     * @dev After a token transfer, update the addressToMember mapping if the NFT is an Original Cardinal or membership NFT
     * @param from the sender's address
     * @param to the recipient's address
     * @param tokenId the tokenId that was transferred
     */
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        if (tokenIdToTypeId[tokenId] == membershipTypeId || tokenIdToTypeId[tokenId] == originalCardinalTypeId) {
            if (from != owner() && from != marketplaceAddress && from != address(0)) {
                if (addressToMemberNFTCount[from] > 0) {
                    addressToMemberNFTCount[from] = addressToMemberNFTCount[from] - 1;
                    if (addressToMemberNFTCount[from] == 0) {
                        addressIsMember[from] = false;
                    }
                }
                else {
                    addressIsMember[from] = false;
                }
            }
            addressIsMember[to] = true;
            addressToMemberNFTCount[to] = addressToMemberNFTCount[to] + 1;
        }

        super._afterTokenTransfer(from, to, tokenId);
    }

    /**
    * @dev Allows someone to mint a membership NFT by paying Cardinal Tokens
    * @return the ID of the newly minted membership NFT
     */
    function mintMembershipNFT() public returns (uint) {
        require(cardinalToken.balanceOf(msg.sender) >= membershipPriceInCardinalTokens, "You don't have enough Cardinal Tokens to pay for the membership NFT.");
        require(cardinalToken.allowance(msg.sender, address(this)) >= membershipPriceInCardinalTokens, "You haven't approved this contract to spend enough of your Cardinal Tokens to pay for the membership NFT.");
        
        cardinalToken.transferFrom(msg.sender, address(this), membershipPriceInCardinalTokens);

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        tokenIdToTypeId[newItemId] = membershipTypeId;
        tokenIdToListingFee[newItemId] = 0;
        _mint(msg.sender, newItemId);
        membershipNFTToLastPaid[newItemId] = block.timestamp;
        _setTokenURI(newItemId, membershipTokenURI);
        approve(address(this), newItemId);
        setApprovalForAll(marketplaceAddress, true);

        membershipTokenIds.push(newItemId);

        return newItemId;
    }

    /**
    * @dev Only owner function to update the timestamp for a membership NFT after it has been paid for for a month.
    * @param tokenId the ID of the membership NFT to have the timestamp updated for
    * @param lastPaidTimestamp the timestamp to update the membership NFT to for when it was last paid for
     */
    function updateMembershipNFTLastPaid(uint256 tokenId, uint256 lastPaidTimestamp) public onlyOwner {
        membershipNFTToLastPaid[tokenId] = lastPaidTimestamp;
    }

    /**
    * @dev Only owner function to take funds from an address to pay for the next month of a membership
    * @param member the address of the member that is being charged for the next month of a membership
    * @param tokenId the token ID that the member is being charged 
    * @return 0 for success, 1 for failure and NFT burn
     */
    function chargeMemberForMembership(address member, uint256 tokenId) public onlyOwner returns (uint) {
        require(ownerOf(tokenId) == member, "This address doesn't own the NFT specified.");
        require(ownerOf(tokenId) != owner() && ownerOf(tokenId) != marketplaceAddress, "Can't charge the owner or marketplace for the membership.");

        if (cardinalToken.balanceOf(member) < membershipPriceInCardinalTokens || cardinalToken.allowance(member, address(this)) < membershipPriceInCardinalTokens) {
            burnMembershipNFT(tokenId);
            return 1;
        }
        cardinalToken.transferFrom(member, address(this), membershipPriceInCardinalTokens);
        membershipNFTToLastPaid[tokenId] = block.timestamp;
        return 0;
    }

    /**
    * @dev Only owner function to withdraw the Cardinal Tokens that are paid to this contract for the Membership NFTs.
     */
    function withdrawMembershipNFTFunds() public onlyOwner {
        cardinalToken.transfer(owner(), cardinalToken.balanceOf(address(this)));
    }

    /**
    * @dev Only owner function to mint a new NFT.
    * @param tokenURI the token URI on IPFS for the NFT metadata
    * @param typeId the type ID of the NFT to distinguish what type of NFT it is (Original Cardinal, membership, service)
    * @param listingFee the fee the user pays when putting the NFT for sale on the marketplace
    * @return the ID of the newly minted NFT
     */
    function createToken(string memory tokenURI, uint256 typeId, uint256 listingFee) public onlyOwner returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        tokenIdToTypeId[newItemId] = typeId;
        tokenIdToListingFee[newItemId] = listingFee;
        _setTokenURI(newItemId, tokenURI);
        approve(address(this), newItemId);
        setApprovalForAll(marketplaceAddress, true);

        if (typeId == originalCardinalTypeId) {
            originalCardinalTokenIds.push(newItemId);
        }
        else if (typeId == membershipTypeId) {
            membershipTokenIds.push(newItemId);
            membershipNFTToLastPaid[newItemId] = block.timestamp;
        }

        return newItemId;
    }

    /**
    * @dev Setter function for the token URI of an NFT.
    * @param tokenId the ID of the NFT to update the token URI of
    * @param newTokenURI the token URI to update the NFT with
     */
    function setTokenURI(uint256 tokenId, string memory newTokenURI) public onlyOwner {
        _setTokenURI(tokenId, newTokenURI);
    }

    /**
    * @dev Function to get all token URIs for tokens that a given user owns.
    * @param userAddress the user's address to get token URIs of
    * @return list of token URIs for a user's NFTs
     */
    function getUserTokenURIs(address userAddress) public view returns (string[] memory) {
        uint NFTCount = _tokenIds.current();
        uint userNFTCount = 0;
        uint currentIndex = 0;

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress) {
                userNFTCount += 1;
            }
        }

        string[] memory userNFTTokenURIs = new string[](userNFTCount);

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress) {
                string memory currentNFT = tokenURI(id);
                userNFTTokenURIs[currentIndex] = currentNFT;
                currentIndex += 1;
            }
        }
        
        return userNFTTokenURIs;
    }

    /**
    * @dev Function to get all token URIs for Original Cardinal NFTs that a given user owns.
    * @param userAddress the user's address to get token URIs of
    * @return list of token URIs for a user's Original Cardinal NFTs
     */
    function getUserOriginalCardinalTokenURIs(address userAddress) public view returns (string[] memory) {
        uint NFTCount = _tokenIds.current();
        uint userNFTCount = 0;
        uint currentIndex = 0;

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress && tokenIdToTypeId[id] == originalCardinalTypeId) {
                userNFTCount += 1;
            }
        }

        string[] memory userNFTTokenURIs = new string[](userNFTCount);

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress && tokenIdToTypeId[id] == originalCardinalTypeId) {
                string memory currentNFT = tokenURI(id);
                userNFTTokenURIs[currentIndex] = currentNFT;
                currentIndex += 1;
            }
        }
        
        return userNFTTokenURIs;
    }

    /**
    * @dev Function to get all token URIs for membership NFTs that a given user owns.
    * @param userAddress the user's address to get token URIs of
    * @return list of token URIs for a user's membership NFTs
     */
    function getUserMembershipTokenURIs(address userAddress) public view returns (string[] memory) {
        uint NFTCount = _tokenIds.current();
        uint userNFTCount = 0;
        uint currentIndex = 0;

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress && (tokenIdToTypeId[id] == originalCardinalTypeId || tokenIdToTypeId[id] == membershipTypeId)) {
                userNFTCount += 1;
            }
        }

        string[] memory userNFTTokenURIs = new string[](userNFTCount);

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress && (tokenIdToTypeId[id] == originalCardinalTypeId || tokenIdToTypeId[id] == membershipTypeId)) {
                string memory currentNFT = tokenURI(id);
                userNFTTokenURIs[currentIndex] = currentNFT;
                currentIndex += 1;
            }
        }
        
        return userNFTTokenURIs;
    }

    /**
    * @dev Function to get all token URIs for service NFTs that a given user owns.
    * @param userAddress the user's address to get token URIs of
    * @return list of token URIs for a user's service NFTs
     */
    function getUserServiceTokenURIs(address userAddress) public view returns (string[] memory) {
        uint NFTCount = _tokenIds.current();
        uint userNFTCount = 0;
        uint currentIndex = 0;

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress && tokenIdToTypeId[id] == serviceTypeId) {
                userNFTCount += 1;
            }
        }

        string[] memory userNFTTokenURIs = new string[](userNFTCount);

        for (uint id = 1; id <= NFTCount; id++) {
            if (ownerOf(id) == userAddress && tokenIdToTypeId[id] == serviceTypeId) {
                string memory currentNFT = tokenURI(id);
                userNFTTokenURIs[currentIndex] = currentNFT;
                currentIndex += 1;
            }
        }
        
        return userNFTTokenURIs;
    }

    /**
    * @dev Function to get a list of all the Original Cardinal NFT IDs.
    * @return list of the Original Cardinal NFT IDs
     */
    function getOriginalCardinalTokenIds() public view returns (uint256[] memory) {
        return originalCardinalTokenIds;
    }

    /**
    * @dev Function to get a list of all the membership NFT IDs.
    * @return list of the membership NFT IDs
     */
    function getMembershipTokenIds() public view returns (uint256[] memory) {
        return membershipTokenIds;
    }

    /**
    * @dev Function to assign an NFT to a whitelist spot so only one address can purchase the NFT.
    * @param whiteListAddress the address of the user who will be able to purchase the NFT
    * @param tokenId the ID of the NFT that the whitelist spot is for
     */
    function addWhiteListToToken(address whiteListAddress, uint256 tokenId) public onlyOwner {
        tokenIdToWhitelistAddress[tokenId] = whiteListAddress;
    }

    /**
    * @dev updates the listing fee of an NFT.
    * @param tokenId the ID of the NFT to update the listing fee of
    * @param newListingFee the listing fee value for the NFT
     */
    function updateTokenListingFee(uint256 tokenId, uint256 newListingFee) public onlyOwner {
        tokenIdToListingFee[tokenId] = newListingFee;
    }

    /**
    * @dev updates the type ID of an NFT.
    * @param tokenId the ID of the NFT to update the type ID of
    * @param newTypeId the type ID value for the NFT
     */
    function updateTokenTypeId(uint256 tokenId, uint256 newTypeId) public onlyOwner {
        tokenIdToTypeId[tokenId] = newTypeId;
    }

    /**
    * @dev updates the type ID that represents the Original Cardinal NFTs
    * @param newOriginalCardinalTypeId the new type ID of the Original Cardinal NFTs
     */
    function updateOriginalCardinalTypeId(uint256 newOriginalCardinalTypeId) public onlyOwner {
        originalCardinalTypeId = newOriginalCardinalTypeId;
    }

    /**
    * @dev updates the type ID that represents the membership NFTs
    * @param newMembershipTypeId the new type ID of the membership NFTs
     */
    function updateMembershipTypeId(uint256 newMembershipTypeId) public onlyOwner {
        membershipTypeId = newMembershipTypeId;
    }

    /**
    * @dev updates the type ID that represents the service NFTs
    * @param newServiceTypeId the new type ID of the service NFTs
     */
    function updateServiceTypeId(uint256 newServiceTypeId) public onlyOwner {
        serviceTypeId = newServiceTypeId;
    }

    /**
    * @dev updates the membership NFT token URI
    * @param newMembershipTokenURI the new type ID of the service NFTs
     */
    function updateMembershipTokenURI(string memory newMembershipTokenURI) public onlyOwner {
        membershipTokenURI = newMembershipTokenURI;
    }

    /**
    * @dev sets the price of the membership NFTs in Cardinal Tokens
    * @param newMembershipPrice the new price of the membership NFTs in Cardinal Tokens
     */
    function updateMembershipPrice(uint256 newMembershipPrice) public onlyOwner {
        membershipPriceInCardinalTokens = newMembershipPrice;
    }

    /**
    * @dev Only owner function to set the reference to the Cardinal Token contract
    * @param cardinalTokenAddress the address for the Cardinal Token contract
    */
    function setCardinalToken(address payable cardinalTokenAddress) public onlyOwner {
        cardinalToken = CardinalToken(cardinalTokenAddress);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT
 
pragma solidity >=0.8.0 <0.9.0;
 
import "ERC20.sol";
import "Ownable.sol";
import "Uniswap.sol";

/**
 * @title Cardinal House Token
 * @dev Token contract for the Cardinal House ecosystem currency
 */
contract CardinalToken is ERC20, Ownable {

    // Mapping to exclude some contracts from fees. Transfers are excluded from fees if address in this mapping is recipient or sender.
    mapping (address => bool) public excludedFromFees;

    // Blacklist mapping to prevent addresses from trading if necessary (i.e. flagged for malicious activity).
    mapping (address => bool) public blacklist;

    // Mapping to determine which addresses can mint Cardinal Tokens for bridging.
    mapping (address => bool) public minters;

    // Address of the contract for burning Cardinal Tokens.
    address public burnWalletAddress;

    // Liquidity wallet address used to hold 30% of the Cardinal Tokens for the liquidity pool.
    // After these tokens are moved to the DEX, this address will no longer be used.
    address public liquidityWalletAddress;

    // Address of the Cardinal Token presale contract.
    address public preSaleAddress;

    // Wallet address used for the Cardinal Token member giveaways.
    address payable public memberGiveawayWalletAddress;

    // Marketing wallet address used for funding marketing.
    address payable public marketingWalletAddress;

    // Developer wallet address used for funding the team.
    address payable public developerWalletAddress;

    // The DEX router address for swapping Cardinal Tokens for Matic.
    address public uniswapRouterAddress;

    // Member giveaway transaction fee - deployed at 2%.
    uint256 public memberGiveawayFeePercent = 2;

    // Marketing transaction fee - deployed at 2%.
    uint256 public marketingFeePercent = 2;

    // Developer team transaction fee - deployed at 1%.
    uint256 public developerFeePercent = 1;

    // DEX router interface.
    IUniswapV2Router02 private uniswapRouter;

    // Address of the Matic to Cardinal Token pair on the DEX.
    address public uniswapPair;

    // Determines how many Cardinal Tokens this contract needs before it swaps for Matic to pay fee wallets.
    uint256 public contractTokenDivisor = 1000;

    // Events to emit when the transaction fees are updated
    event memberGiveawayTransactionFeeUpdated(uint256 indexed transactionFeeAmount);
    event marketingTransactionFeeUpdated(uint256 indexed transactionFeeAmount);
    event developerTransactionFeeUpdated(uint256 indexed transactionFeeAmount);

    // Initial token distribution:
    // 35% - Pre-sale
    // 35% - Liquidity pool (6 month lockup period)
    // 10% - Marketing
    // 20% - Developer coins (6 month lockup period)
    constructor(
        uint256 initialSupply,
        address _preSaleAddress, 
        address _burnWalletAddress,
        address _liquidityWalletAddress,
        address payable _memberGiveawayWalletAddress,
        address payable _marketingWalletAddress,
        address payable _developerWalletAddress,
        address _uniswapRouterAddress) ERC20("CardinalToken", "CRNL") {
            preSaleAddress = _preSaleAddress;
            memberGiveawayWalletAddress = _memberGiveawayWalletAddress;
            burnWalletAddress = _burnWalletAddress;
            liquidityWalletAddress = _liquidityWalletAddress;
            marketingWalletAddress = _marketingWalletAddress;
            developerWalletAddress = _developerWalletAddress;
            uniswapRouterAddress = _uniswapRouterAddress;

            excludedFromFees[memberGiveawayWalletAddress] = true;
            excludedFromFees[developerWalletAddress] = true;
            excludedFromFees[marketingWalletAddress] = true;
            excludedFromFees[liquidityWalletAddress] = true;
            excludedFromFees[preSaleAddress] = true;

            _mint(preSaleAddress, ((initialSupply) * 35 / 100));
            _mint(liquidityWalletAddress, ((initialSupply) * 35 / 100));
            _mint(marketingWalletAddress, initialSupply / 10);
            _mint(developerWalletAddress, initialSupply / 5);

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouterAddress);
            uniswapRouter = _uniswapV2Router;
            _approve(address(this), address(uniswapRouter), initialSupply);
            uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
            IERC20(uniswapPair).approve(address(uniswapRouter), type(uint256).max);
    }

    /**
     * @dev Returns the contract address
     * @return contract address
     */
    function getContractAddress() public view returns (address){
        return address(this);
    }

    /**
    * @dev Adds a user to be excluded from fees.
    * @param user address of the user to be excluded from fees.
     */
    function excludeUserFromFees(address user) public onlyOwner {
        excludedFromFees[user] = true;
    }

    /**
    * @dev Gets the current timestamp, used for testing + verification
    * @return the the timestamp of the current block
     */
    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    /**
    * @dev Removes a user from the fee exclusion.
    * @param user address of the user than will now have to pay transaction fees.
     */
    function includeUsersInFees(address user) public onlyOwner {
        excludedFromFees[user] = false;
    }

    /**
     * @dev Overrides the BEP20 transfer function to include transaction fees.
     * @param recipient the recipient of the transfer
     * @param amount the amount to be transfered
     * @return bool representing if the transfer was successful
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Ensure the sender isn't blacklisted.
        require(!blacklist[_msgSender()], "You have been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");
        // Ensure the recipient isn't blacklisted.
        require(!blacklist[recipient], "The address you are trying to send Cardinal Tokens to has been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");

        // Stops investors from owning more than 2% of the total supply from purchasing Cardinal Tokens from the DEX.
        if (_msgSender() == uniswapPair && !excludedFromFees[_msgSender()] && !excludedFromFees[recipient]) {
            require((balanceOf(recipient) + amount) < (totalSupply() / 166), "You can't have more than 2% of the total Cardinal Token supply after a DEX swap.");
        }

        // If the sender or recipient is excluded from fees, perform the default transfer.
        if (excludedFromFees[_msgSender()] || excludedFromFees[recipient]) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        // Member giveaway transaction fee.
        uint256 memberGiveawayFee = (amount * memberGiveawayFeePercent) / 100;
        // Marketing team transaction fee.
        uint256 marketingFee = (amount * marketingFeePercent) / 100;
        // Developer team transaction fee.
        uint256 developerFee = (amount * developerFeePercent) / 100;

        // The total fee to send to the contract address (marketing + development).
        uint256 contractFee = marketingFee + developerFee;
 
        // Sends the transaction fees to the giveaway wallet and contract address
        _transfer(_msgSender(), memberGiveawayWalletAddress, memberGiveawayFee);
        _transfer(_msgSender(), address(this), contractFee);

        uint256 contractCardinalTokenBalance = balanceOf(address(this));

        if (_msgSender() != uniswapPair) {
            if (contractCardinalTokenBalance > balanceOf(uniswapPair) / contractTokenDivisor) {
                swapCardinalTokensForMatic(contractCardinalTokenBalance);
            }
                
            uint256 contractMaticBalance = address(this).balance;
            if (contractMaticBalance > 0) {
                sendFeesToWallets(address(this).balance);
            }
        }
 
        // Sends [initial amount] - [fees] to the recipient
        uint256 valueAfterFees = amount - contractFee - memberGiveawayFee;
        _transfer(_msgSender(), recipient, valueAfterFees);
        return true;
    }

    /**
     * @dev Overrides the BEP20 transferFrom function to include transaction fees.
     * @param from the address from where the tokens are coming from
     * @param to the recipient of the transfer
     * @param amount the amount to be transfered
     * @return bool representing if the transfer was successful
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        // Ensure the sender isn't blacklisted.
        require(!blacklist[_msgSender()], "You have been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");
        // Ensure the address where the tokens are coming from isn't blacklisted.
        require(!blacklist[from], "The address you're trying to spend the Cardinal Tokens from has been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");
        // Ensure the recipient isn't blacklisted.
        require(!blacklist[to], "The address you are trying to send Cardinal Tokens to has been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");

        // If the from address or to address is excluded from fees, perform the default transferFrom.
        if (excludedFromFees[from] || excludedFromFees[to] || excludedFromFees[_msgSender()]) {
            _spendAllowance(from, _msgSender(), amount);
            _transfer(from, to, amount);
            return true;
        }

        // Member giveaway transaction fee.
        uint256 memberGiveawayFee = (amount * memberGiveawayFeePercent) / 100;
        // Marketing team transaction fee.
        uint256 marketingFee = (amount * marketingFeePercent) / 100;
        // Developer team transaction fee.
        uint256 developerFee = (amount * developerFeePercent) / 100;

        // The total fee to send to the contract address (marketing + development).
        uint256 contractFee = marketingFee + developerFee;
 
        // Sends the transaction fees to the giveaway wallet and contract address
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, memberGiveawayWalletAddress, memberGiveawayFee);
        _transfer(from, address(this), contractFee);

        uint256 contractCardinalTokenBalance = balanceOf(address(this));

        if (_msgSender() != uniswapPair) {
            if (contractCardinalTokenBalance > balanceOf(uniswapPair) / contractTokenDivisor) {
                swapCardinalTokensForMatic(contractCardinalTokenBalance);
            }
                
            uint256 contractMaticBalance = address(this).balance;
            if (contractMaticBalance > 0) {
                sendFeesToWallets(address(this).balance);
            }
        }
 
        // Sends [initial amount] - [fees] to the recipient
        uint256 valueAfterFees = amount - contractFee - memberGiveawayFee;
        _transfer(from, to, valueAfterFees);
        return true;
    }

    /**
     * @dev Swaps Cardinal Tokens from transaction fees to Matic.
     * @param amount the amount of Cardinal Tokens to swap
     */
    function swapCardinalTokensForMatic(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), amount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Sends Matic to transaction fee wallets after Cardinal Token swaps.
     * @param amount the amount to be transfered
     */
    function sendFeesToWallets(uint256 amount) private {
        uint256 totalFee = marketingFeePercent + developerFeePercent;
        marketingWalletAddress.transfer((amount * marketingFeePercent) / totalFee);
        developerWalletAddress.transfer((amount * developerFeePercent) / totalFee);
    }

    /**
     * @dev Sends Matic to transaction fee wallets manually as opposed to happening automatically after a certain level of volume
     */
    function disperseFeesManually() public onlyOwner {
        uint256 contractMaticBalance = address(this).balance;
        sendFeesToWallets(contractMaticBalance);
    }

    /**
     * @dev Swaps all Cardinal Tokens in the contract for Matic and then disperses those funds to the transaction fee wallets.
     * @param amount the amount of Cardinal Tokens in the contract to swap for Matic
     * @param useAmount boolean to determine if the amount sent in is swapped for Matic or if the entire contract balance is swapped.
     */
    function swapCardinalTokensForMaticManually(uint256 amount, bool useAmount) public onlyOwner {
        if (useAmount) {
            swapCardinalTokensForMatic(amount);
        }
        else {
            uint256 contractCardinalTokenBalance = balanceOf(address(this));
            swapCardinalTokensForMatic(contractCardinalTokenBalance);
        }

        uint256 contractMaticBalance = address(this).balance;
        sendFeesToWallets(contractMaticBalance);
    }

    receive() external payable {}

    /**
     * @dev Sets the value that determines how many Cardinal Tokens need to be in the contract before it's swapped for Matic.
     * @param newDivisor the new divisor value to determine the swap threshold
     */
    function setContractTokenDivisor(uint256 newDivisor) public onlyOwner {
        contractTokenDivisor = newDivisor;
    }

    /**
    * @dev Updates the blacklist mapping for a given address
    * @param user the address that is being added or removed from the blacklist
    * @param blacklisted a boolean that determines if the given address is being added or removed from the blacklist
    */
    function updateBlackList(address user, bool blacklisted) public onlyOwner {
        blacklist[user] = blacklisted;
    }

    /**
    * @dev Function to update the member giveaway transaction fee - can't be more than 5 percent
    * @param newMemberGiveawayTransactionFee the new member giveaway transaction fee
    */
    function updateMemberGiveawayTransactionFee(uint256 newMemberGiveawayTransactionFee) public onlyOwner {
        require(newMemberGiveawayTransactionFee <= 5, "The member giveaway transaction fee can't be more than 5%.");
        memberGiveawayFeePercent = newMemberGiveawayTransactionFee;
        emit memberGiveawayTransactionFeeUpdated(newMemberGiveawayTransactionFee);
    }

    /**
    * @dev Function to update the marketing transaction fee - can't be more than 5 percent
    * @param newMarketingTransactionFee the new marketing transaction fee
    */
    function updateMarketingTransactionFee(uint256 newMarketingTransactionFee) public onlyOwner {
        require(newMarketingTransactionFee <= 5, "The marketing transaction fee can't be more than 5%.");
        marketingFeePercent = newMarketingTransactionFee;
        emit marketingTransactionFeeUpdated(newMarketingTransactionFee);
    }

    /**
    * @dev Function to update the developer transaction fee - can't be more than 5 percent
    * @param newDeveloperTransactionFee the new developer transaction fee
    */
    function updateDeveloperTransactionFee(uint256 newDeveloperTransactionFee) public onlyOwner {
        require(newDeveloperTransactionFee <= 5, "The developer transaction fee can't be more than 5%.");
        developerFeePercent = newDeveloperTransactionFee;
        emit developerTransactionFeeUpdated(newDeveloperTransactionFee);
    }

    /**
    * @dev Function to add or remove a Cardinal Token minter
    * @param user the address that will be added or removed as a minter
    * @param isMinter boolean representing if the address provided will be added or removed as a minter
    */
    function updateMinter(address user, bool isMinter) public onlyOwner {
        minters[user] = isMinter;
    }

    /**
    * @dev Minter only function to mint new Cardinal Tokens for bridging
    * @param user the address that the tokens will be minted to
    * @param amount the amount of tokens to be minted to the user
    */
    function mint(address user, uint256 amount) public {
        require(minters[_msgSender()], "You are not authorized to mint Cardinal Tokens.");
        _mint(user, amount);
    }

    /**
    * @dev Minter only function to burn Cardinal Tokens for bridging and deflation upon service purchases with the Cardinal Token
    * @param user the address to burn the tokens from
    * @param amount the amount of tokens to be burned
    */
    function burn(address user, uint256 amount) public {
        require(minters[_msgSender()], "You are not authorized to burn Cardinal Tokens.");
        _burn(user, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}