/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// File: contracts/CyberTiger/Marketplace/Marketplace.sol

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


pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

library StructLib { 
  enum activeStatus {
        HUMAN,
        GOBLIN,
        DEVIL,
        ANGEL
    }

    struct ingameItems { 
        uint256 id;
        address owner;
        string itemId;
        string externalId;
        bool ingame;
    }

    struct usersStatus { 
        activeStatus status;
    }
}

pragma solidity ^0.8.0;

contract MarketplaceStorage {

    bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

    // From ERC721 registry assetId to Item (to avoid asset collision)
    // mapping(address => mapping(uint256 => MarketItem)) public items;

    IERC20 public mainToken;
    IERC20 public BUSDToken;
    IERC721 public mainNFTs;

    uint8 public bnbFeePercent;
    uint8 public antaFeePercent;

    event DelistItemSuccessful(
        uint256 id,
        uint256 indexed assetId,
        address indexed delistBy,
        uint256 createdAt
    );
    
    event MarketItemCreated (
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        string currency
    );

    event BuyItemSuccessful(
        uint256 itemId,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price,
        address indexed buyer,
        string currency,
        uint256 createdAt
    );
    event SellItemSuccessful(
        address nftAddress,
        bytes32 id,
        uint256 indexed assetId,
        uint256 price,
        address indexed seller,
        string currency,
        uint256 createdAt
    );
}

pragma solidity ^0.8.2;


contract NFTMarket is ReentrancyGuard,MarketplaceStorage, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

    struct MarketItem {
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 currency;
    }
   
    struct Seller {
        uint256[] tokenIds;
        mapping (uint256 => uint256) tokenIndex;
    }

  mapping(uint256 => uint256) public idTokenToItem;
  mapping(uint256 => MarketItem) private idToMarketItem;
  mapping(address => Seller) private sellers ;
  
  constructor(address _mainToken, address _mainNFT ) {
      mainToken = IERC20(_mainToken);
      mainNFTs = IERC721(_mainNFT);
  }
    function setBUSDToken(address BUSDAddress) public onlyOwner { 
        BUSDToken = IERC20(BUSDAddress);
    } 

    function getMarketItem() public view returns(MarketItem[] memory) { 
            uint totalItemCount = _itemIds.current();
            uint currentIndex = 0;           
            MarketItem[] memory items = new MarketItem[](totalItemCount);
            for (uint i = 0; i < totalItemCount; i++) {
                MarketItem storage currentItem = idToMarketItem[i];
                items[currentIndex] = currentItem;
                currentIndex += 1;
        }
        return items;
    }

    function getDetailSelling(uint256 tokenId) public view returns(MarketItem memory) { 
            uint256 itemId = idTokenToItem[tokenId];
            return idToMarketItem[itemId];

    } 

    function getSellingToken(
        address _user
    )
        external
        view
        returns (uint256[] memory tokenIds)
    {
        return sellers[_user].tokenIds;
    }

    function setMainToken(address _address) external onlyOwner {
        mainToken = IERC20(_address);
    }
    function setMainNFT(address _address) external onlyOwner {
        mainNFTs = IERC721(_address);
    }


  function createMarketItem(
    uint256 tokenId,
    uint256 price,
    uint256 currency
  ) public {
    require(price > 0, "Price must be at least 1 wei");
    uint256 itemId = _itemIds.current();
    _safeTransferToMarket(tokenId);
    idToMarketItem[itemId] =  MarketItem(
      tokenId,
      msg.sender,
      address(this),
      price,
      currency
    );
    idTokenToItem[tokenId] = itemId;
    _itemIds.increment();
    emit MarketItemCreated(
      itemId,
      tokenId,
      msg.sender,
      address(this),
      price,
      currency == 0 ? "MEAT" : "BUSD"
    );
  }

  function createMarketSale(uint256 itemId) public {
    MarketItem storage item = idToMarketItem[itemId];
    uint price = item.price;
    uint tokenId = item.tokenId;
    address _user =  item.seller;
    uint256 currency = item.currency;
    _safeBuyItem(itemId,price,tokenId,currency);
    delete idToMarketItem[itemId];
    delete idTokenToItem[tokenId];
    _itemsSold.increment();
    Seller storage seller = sellers[_user];
    uint256 lastIndex = seller.tokenIds.length - 1;
    uint256 lastIndexKey = seller.tokenIds[lastIndex];
    seller.tokenIndex[lastIndexKey] = seller.tokenIndex[tokenId];
        seller.tokenIds[seller.tokenIndex[lastIndexKey]] = lastIndexKey;
        seller.tokenIndex[tokenId] = lastIndex;
        seller.tokenIds[lastIndex] = tokenId;

        if (seller.tokenIds.length > 0) {
            delete seller.tokenIds[lastIndex];
            delete seller.tokenIndex[tokenId];
            seller.tokenIds.pop();
        }
        if (seller.tokenIds.length == 0) {
            delete sellers[_user];
        }
    emit BuyItemSuccessful(
        itemId,
        tokenId,
        _user,
        price,
        address(msg.sender),
        currency == 0 ? "MEAT" : "BUSD",
        block.timestamp
    );
  }
   function delistItem(uint256 itemId) public {
        address deleteBy = msg.sender;
        MarketItem memory item = idToMarketItem[itemId];
        uint256 tokenId = item.tokenId;
        address _user = item.seller;
        require(
            _user == msg.sender,
            "Only seller can delist"
        );
        mainNFTs.safeTransferFrom(address(this), _user, tokenId);
        delete idToMarketItem[itemId];
        delete idTokenToItem[tokenId];
        delete item;
         Seller storage seller = sellers[_user];
        uint256 lastIndex = seller.tokenIds.length - 1;
        uint256 lastIndexKey = seller.tokenIds[lastIndex];
        seller.tokenIndex[lastIndexKey] = seller.tokenIndex[tokenId];
        seller.tokenIds[seller.tokenIndex[lastIndexKey]] = lastIndexKey;
        seller.tokenIndex[tokenId] = lastIndex;
        seller.tokenIds[lastIndex] = tokenId;

        if (seller.tokenIds.length > 0) {
            delete seller.tokenIds[lastIndex];
            delete seller.tokenIndex[tokenId];
            seller.tokenIds.pop();
        }
        if (seller.tokenIds.length == 0) {
            delete sellers[_user];
        }
        emit DelistItemSuccessful(
            itemId,
            tokenId,
            deleteBy,
            block.timestamp
        );
    }
        
    function _safeTransferToMarket(uint256 tokenId) private {
            // factory.setOwnerIngameItem(payable(address(msg.sender)),address(this), tokenId);
            Seller storage seller = sellers[msg.sender];
            seller.tokenIds.push(tokenId);
            seller.tokenIndex[tokenId] = seller.tokenIds.length - 1;
            mainNFTs.transferFrom(msg.sender, address(this), tokenId);
            
    } 

    function _safeBuyItem(uint256 itemId,uint256 amount, uint256 tokenId,uint256 currency ) private { 
        if(currency == 0) { 
            mainToken.transferFrom(address(msg.sender), address(idToMarketItem[itemId].seller), amount);
        }else { 
            BUSDToken.transferFrom(address(msg.sender), address(idToMarketItem[itemId].seller), amount);
        }
        mainNFTs.transferFrom(address(this), address(msg.sender), tokenId);
    }

    function _requireERC721(address nftAddress) internal view {
        require(
            isContract(nftAddress),
            "The NFT Address should be a contract"
        );

        IERC721 nftRegistry = IERC721(nftAddress);
        require(
            nftRegistry.supportsInterface(ERC721_Interface),
            "The NFT contract has an invalid ERC721 implementation"
        );
    }

    function isContract(address _addr) private view returns (bool){
    uint32 size;
    assembly {
    size := extcodesize(_addr)
    }
    return (size > 0);
}

}