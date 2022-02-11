/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)




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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)



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

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function getnftIdOftokenId(uint256 _nftId) external view returns(uint256);
  }

  interface TokenContract {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract NFTMarketplace is ReentrancyGuard, Ownable {
    uint256 private _totalItems;
    uint256 private _totalItemsSold;

    IERC721 private nftContract;


    struct NftItem {
      uint256 itemId;
      uint256 nftTokenId;
      address payable seller;
      address payable buyer;
      uint256 price;
      bool sold;
    }

    mapping(uint256 => NftItem) private NftItemsOfid;

    event NftPutOnSell(
      uint256 indexed itemId,
      uint256 indexed nftTokenId,
      address payable seller,
      address payable buyer,
      uint256 price,
      bool sold
    );

    event NftBrought(
      uint256 indexed itemId,
      uint256 indexed nftTokenId,
      address payable seller,
      address payable buyer,
      uint256 price,
      bool sold
    );

    address private tokenAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    TokenContract private tokenContract = TokenContract(tokenAddress);

  constructor(IERC721 _nftCon) {
    nftContract = _nftCon;
  }


  /* Put an NFt item for sale on the marketplace */
  function PutNftOnSell(
    uint256 nftId,
    uint256 price
  ) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");

    uint256 itemId = _totalItems;
    _totalItems ++;
  
    nftContract.transferFrom(msg.sender, address(this), nftId);

    NftItemsOfid[itemId] =  NftItem(
      itemId,
      nftId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false
    );

    emit NftPutOnSell(
      itemId,
      nftId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false
    );
  }

  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function BuyNftItem(
    uint256 itemId
    ) public payable nonReentrant {
    require(itemId < _totalItems,"this item doesnot exist");

    NftItem memory _nft = NftItemsOfid[itemId];
    require(!_nft.sold,"this nft item is already sold");

    require(tokenContract.allowance(msg.sender,address(this)) >= _nft.price,"Allow tokens to spend");
    require(tokenContract.transferFrom(msg.sender,_nft.seller, _nft.price),"Please pay full fee");

    nftContract.transferFrom(address(this), msg.sender, _nft.nftTokenId);

    NftItemsOfid[itemId].buyer = payable(msg.sender);
    NftItemsOfid[itemId].sold = true;
    _totalItemsSold++;

    emit NftBrought(
      itemId,
       _nft.nftTokenId,
      payable(_nft.seller),
      payable(msg.sender),
      _nft.price,
      false
    );
  }

  /* Returns all unsold market items */
  function loadAllUnSoldNfts() public view returns (NftItem[] memory) {
    uint256 unsoldItemCount = _totalItems - _totalItemsSold;
    uint256 currentIndex = 0;

    NftItem[] memory items = new NftItem[](unsoldItemCount);
    for (uint256 i = 0; i < _totalItems; i++) {
      if (NftItemsOfid[i].sold == false) {
        NftItem storage currentItem = NftItemsOfid[i];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns unsold market items with specific charcter ids*/
  function loadAllUnSoldNfts(uint256 _nftId) public view returns (NftItem[] memory) {
    uint256 unsoldItemCount = _totalItems - _totalItemsSold;
    uint256 currentIndex = 0;

    NftItem[] memory items = new NftItem[](unsoldItemCount);
    for (uint256 i = 0; i < _totalItems; i++) {
      if (NftItemsOfid[i].sold == false && nftContract.getnftIdOftokenId(NftItemsOfid[i].nftTokenId) == _nftId) {
        NftItem storage currentItem = NftItemsOfid[i];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns all sold market items */
  function loadAllSoldNfts() public view returns (NftItem[] memory) {
    uint256 currentIndex = 0;

    NftItem[] memory items = new NftItem[](_totalItemsSold);
    for (uint256 i = 0; i < _totalItems; i++) {
      if (NftItemsOfid[i].sold == true) {
        NftItem storage currentItem = NftItemsOfid[i];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only items that a user has purchased */
  function loadAllBroughtNft() public view returns (NftItem[] memory) {
    uint256 totalNftsCount = _totalItems;
    uint256 _totalUserNft = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalNftsCount; i++) {
      if (NftItemsOfid[i].buyer == msg.sender) {
        _totalUserNft += 1;
      }
    }

    NftItem[] memory userNfts = new NftItem[](_totalUserNft);
    for (uint256 i = 0; i < totalNftsCount; i++) {
      if (NftItemsOfid[i].buyer == msg.sender) {
        userNfts[currentIndex] = NftItemsOfid[i];
        currentIndex += 1;
      }
    }
    return userNfts;
  }

  /* Returns only items a user is selling */
  function loadAllSoldNft() public view returns (NftItem[] memory) {
    uint256 totalNftsCount = _totalItems;
    uint256 _totalUserNft = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalNftsCount; i++) {
      if (NftItemsOfid[i].seller == msg.sender) {
        _totalUserNft += 1;
      }
    }

    NftItem[] memory userNfts = new NftItem[](_totalUserNft);
    for (uint256 i = 0; i < totalNftsCount; i++) {
      if (NftItemsOfid[i].seller == msg.sender) {
        userNfts[currentIndex] = NftItemsOfid[i];
        currentIndex += 1;
      }
    }
    return userNfts;
  }

  function changeNftAddress(address _new) public onlyOwner{
      nftContract = IERC721(_new);
  }
  function changeTokenAddress(address _new) public onlyOwner{
      tokenContract = TokenContract(_new);
  }

  function withdrawBalance(address _to) public onlyOwner {
        (bool os, ) = payable(_to).call{value: address(this).balance}("");
        require(os);
  }

  function withdrawBalanceToken(address _to) public onlyOwner {
    require(tokenContract.transfer(_to,tokenContract.balanceOf(address(this))),"Not Able to Send");
  }
  
  function adminBalance() public view onlyOwner returns(uint256) {
    return  address(this).balance;
  }
  
}