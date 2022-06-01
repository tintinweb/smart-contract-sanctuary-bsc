// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SafeMath.sol";

contract NFTMarketplace is ReentrancyGuard{
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address private _owner;
  uint256 private _percentListing;
  uint256 private _percentDivider;
  
  constructor(address owner,uint256 percentListing, uint256 percentDivider, address listTokenContracts) {
    _owner = owner;
    _percentListing = percentListing;
    _percentDivider = percentDivider;
    _listTokenContracts[listTokenContracts] = true;
  }

  struct MarketItem {
    uint256 itemId;
    address nftContract;
    uint256 nftId;
    address seller;
    address buyer;
    address tokenContract;
    uint256 price;
  }

  //MarketItem[] _marketItems;
  mapping(uint256 => MarketItem) private idToMarketItem;
  mapping(address => bool) private _listNftContracts;
  mapping(address => bool) private _listTokenContracts;

  event MarketItemCreated (
    uint256 indexed itemId,
    address indexed nftContract,
    uint256 indexed nftId,
    address seller,
    address buyer,
    address tokenContract,
    uint256 price
  );

  function getPercentListing() public view returns (uint256) {
    return _percentListing;
  }

  function getPercentDivider() public view returns (uint256) {
    return _percentDivider;
  }

  function getTokensOwner(address _x) public {
    require(msg.sender == _owner, "Only owner");
    IERC20 token = IERC20(_x);
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }
  
  function createMarketItem(
    address nftContract,
    uint256 nftId,
    address tokenContract,
    uint256 price
  ) public nonReentrant {
    require(existsNftAddress(nftContract) == true,"Invalid nft contract");
    require(existsTokenAddress(tokenContract) == true,"Invalid token contract");
    require(msg.sender == IERC721(nftContract).ownerOf(nftId),"You are not the owner of this token");
    IERC721(nftContract).transferFrom(msg.sender, address(this), nftId);

    uint256 itemId = _itemIds.current();
    idToMarketItem[itemId] =  MarketItem(
      itemId,
      nftContract,
      nftId,
      msg.sender,
      address(0),
      tokenContract,
      price
    );

    emit MarketItemCreated(
      itemId,
      nftContract,
      nftId,
      msg.sender,
      address(0),
      tokenContract,
      price
    );

    _itemIds.increment();
  }

  function createMarketSale(
    uint256 itemId
    ) public nonReentrant {
    address nftContract = idToMarketItem[itemId].nftContract;
    address tokenContract = idToMarketItem[itemId].tokenContract;
    IERC20 token = IERC20(tokenContract);
    require(token.balanceOf(msg.sender) >=  idToMarketItem[itemId].price,"You do not have the required amount");
    uint256 allowance = token.allowance(msg.sender, address(this));
    require(allowance >=  idToMarketItem[itemId].price, "Check the token allowance");
    require(token.transferFrom(msg.sender, address(this), idToMarketItem[itemId].price),"Error transferFrom to contract");
    require(token.transfer(idToMarketItem[itemId].seller, idToMarketItem[itemId].price.mul(100 - _percentListing).div(_percentDivider)),"Error transferFrom to seller");
    require(token.transfer(_owner, idToMarketItem[itemId].price.mul(_percentListing).div(_percentDivider)),"Error transferFrom to owner");
    IERC721(nftContract).transferFrom(address(this), msg.sender, idToMarketItem[itemId].nftId);
    idToMarketItem[itemId].buyer = msg.sender;
    _itemsSold.increment();
  }

  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint256 allItems = _itemIds.current();
    uint256 countItems = allItems.sub(_itemsSold.current());

    MarketItem[] memory items = new MarketItem[](countItems);
    uint256 j = 0;
    for(uint256 i; i < allItems; i++){
      if(idToMarketItem[i].buyer == address(0)){
        MarketItem memory row = idToMarketItem[i];
        items[j] = row;
        j++;
      }
    }
    return items;
  }

  function getCountPages(uint256 _itemsPerPage) public view returns (uint256){
       uint256 allItems = _itemIds.current();
       uint256 countItems = allItems.sub(_itemsSold.current());
       uint256 countPages;
       if(countItems == 0){
            return 1;
       }
       if(countItems.mod(_itemsPerPage) == 0){
            countPages = countItems.div(_itemsPerPage);
       }else{
            countPages = countItems.sub(countItems.mod(_itemsPerPage)).div(_itemsPerPage).add(1);
       }
       return countPages;
  }

  function fetchMarketItemsPage(uint256 _page, uint256 _itemsPerPage) public view returns (MarketItem[] memory) {
    uint256 allItems = _itemIds.current();
    uint256 countItems = allItems.sub(_itemsSold.current());
    uint256 countPages = getCountPages(_itemsPerPage);
    uint256 echoCount = _itemsPerPage;
    if(countPages < _page){
         _page = 1;
    }
    if(countItems < _page.mul(_itemsPerPage)){
         echoCount = countItems.sub(countItems.sub(countItems.mod(_itemsPerPage)));
    }
    MarketItem[] memory items = new MarketItem[](echoCount);
    uint256 j = 0;
    uint256 k = 0;
    for(uint256 i; j < echoCount; i++){
      if(idToMarketItem[i].buyer == address(0)){
        k++;
        if(k > _page.mul(_itemsPerPage).sub(_itemsPerPage)){
             MarketItem memory row = idToMarketItem[i];
             items[j] = row;
             j++;
        }
      }
    }
    return items;
  }

  function fetchMyPurchasedItems(address _address) public view returns (MarketItem[] memory) {
    uint256 allItems = _itemIds.current();
    uint256 myItemCount = 0;

    for (uint256 i = 0; i < allItems; i++) {
      if (idToMarketItem[i].buyer == _address && idToMarketItem[i].seller != _address) {
        myItemCount++;
      }
    }

    MarketItem[] memory items = new MarketItem[](myItemCount);
    uint256 j = 0;
    for (uint256 i = 0; i < allItems; i++) {
      if (idToMarketItem[i].buyer == _address && idToMarketItem[i].seller != _address) {
        MarketItem memory currentItem = idToMarketItem[i];
        items[j] = currentItem;
        j++;
      }
    }
    return items;
  }

  function fetchMySoldItems(address _address) public view returns (MarketItem[] memory) {
    uint256 allItems = _itemIds.current();
    uint256 myItemCount = 0;

    for (uint256 i = 0; i < allItems; i++) {
      if (idToMarketItem[i].seller == _address && idToMarketItem[i].buyer != address(0) && idToMarketItem[i].buyer != _address) {
        myItemCount++;
      }
    }

    MarketItem[] memory items = new MarketItem[](myItemCount);
    uint256 j = 0;
    for (uint256 i = 0; i < allItems; i++) {
      if (idToMarketItem[i].seller == _address && idToMarketItem[i].buyer != address(0) && idToMarketItem[i].buyer != _address) {
        MarketItem memory currentItem = idToMarketItem[i];
        items[j] = currentItem;
        j++;
      }
    }
    return items;
  }

  function fetchMyItemsOnSale(address _address) public view returns (MarketItem[] memory) {
    uint256 allItems = _itemIds.current();
    uint256 myItemCount = 0;

    for (uint256 i = 0; i < allItems; i++) {
      if (idToMarketItem[i].seller == _address && idToMarketItem[i].buyer == address(0)) {
        myItemCount++;
      }
    }

    MarketItem[] memory items = new MarketItem[](myItemCount);
    uint256 j = 0;
    for (uint256 i = 0; i < allItems; i++) {
      if (idToMarketItem[i].seller == _address && idToMarketItem[i].buyer == address(0)) {
        MarketItem memory currentItem = idToMarketItem[i];
        items[j] = currentItem;
        j++;
      }
    }
    return items;
  }

  function returnMyNFT(uint256 _itemId) public {
    require(idToMarketItem[_itemId].seller == msg.sender && idToMarketItem[_itemId].buyer == address(0),"This is not your token");
    IERC721(idToMarketItem[_itemId].nftContract).transferFrom(address(this), msg.sender, idToMarketItem[_itemId].nftId);
    idToMarketItem[_itemId].buyer = msg.sender;
    _itemsSold.increment();
  }

  function addNftContract(address _address) public {
    require(msg.sender == _owner);
    require(_listNftContracts[_address] != true,"Address exists");
    _listNftContracts[_address] = true;
  }

  function deleteNftContract(address _address) public {
    require(msg.sender == _owner);
    require(_listNftContracts[_address] == true,"Address not exists");
    delete _listNftContracts[_address];
  }

  function addTokenContract(address _address) public {
    require(msg.sender == _owner);
    require(_listTokenContracts[_address] != true,"Address exists");
    _listTokenContracts[_address] = true;
  }

  function deleteTokenContract(address _address) public {
    require(msg.sender == _owner);
    require(_listTokenContracts[_address] == true,"Address not exists");
    delete _listTokenContracts[_address];
  }

  function existsNftAddress(address _address) public view returns(bool){
    if(_listNftContracts[_address] == true){
      return true;
    }else{
      return false;
    }
  }

  function existsTokenAddress(address _address) public view returns(bool){
    if(_listTokenContracts[_address] == true){
      return true;
    }else{
      return false;
    }
  }

  function setPercentListing(uint256 _x) public {
    require(msg.sender == _owner, "Only owner");
    _percentListing = _x;
  }

  function setPercentDivider(uint256 _x) public {
    require(msg.sender == _owner, "Only owner");
    _percentDivider = _x;
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
pragma solidity >=0.4.22 <0.9.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a % b;
        return c;
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