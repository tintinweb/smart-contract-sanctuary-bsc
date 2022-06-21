/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// File: nft_marketplace.sol


pragma solidity > 0.8.3;




contract SpurMarketPlace is ERC721Holder, Ownable {

  struct Order {
    uint8 orderType;  //0:Fixed Price, 1:Dutch Auction, 2:English Auction
    address seller;
    IERC721 token;
    uint256 tokenId;
    string uri; //metadata url
    uint256 startPrice;
    uint256 endPrice;
    uint256 startBlock;
    uint256 endBlock;
    uint256 lastBidPrice;
    address lastBidder;
    bool isSold;
  }

  IERC721 public _token;
  mapping (IERC721 => mapping (uint256 => bytes32[])) public orderIdByToken;
  mapping (address => bytes32[]) public orderIdBySeller;
  mapping (bytes32 => Order) public orderInfo;

  address public feeAddress;
  uint16 public feePercent;

  event MakeOrder(IERC721 indexed token, uint256 id, bytes32 indexed hash, address seller);
  event CancelOrder(IERC721 indexed token, uint256 id, bytes32 indexed hash, address seller);
  event Bid(IERC721 indexed token, uint256 id, bytes32 indexed hash, address bidder, uint256 bidPrice);
  event Claim(IERC721 indexed token, uint256 id, bytes32 indexed hash, address seller, address taker, uint256 price);


  constructor(uint16 _feePercent, IERC721 token) {
    require(_feePercent <= 10000, "input value is more than 100%");
    feeAddress = msg.sender;
    feePercent = _feePercent;
    _token = token;
  }


  // view fx
  function getCurrentPrice(bytes32 _order) public view returns (uint256) {
    Order storage o = orderInfo[_order];
    uint8 orderType = o.orderType;
    if (orderType == 0) {
      return o.startPrice;
    } else if (orderType == 2) {
      uint256 lastBidPrice = o.lastBidPrice;
      return lastBidPrice == 0 ? o.startPrice : lastBidPrice;
    } else {
      uint256 _startPrice = o.startPrice;
      uint256 _startBlock = o.startBlock;
      uint256 tickPerBlock = (_startPrice - o.endPrice) / (o.endBlock - _startBlock);
      return _startPrice - ((block.number - _startBlock) * tickPerBlock);
    }
  }

    function getOrderIdByToken( uint256 _id) external view returns (bytes32[] memory) {
    return orderIdByToken[_token][_id];
  }


    function getOrderIdBySeller( address _seller) external view returns (bytes32[] memory) {
    return orderIdBySeller[_seller];
  }

      function getOrderIdInfo( bytes32 _order) external view returns (Order memory) {
    return orderInfo[_order];
  }


  function tokenOrderLength( uint256 _id) external view returns (uint256) {
    return orderIdByToken[_token][_id].length;
  }

  function sellerOrderLength(address _seller) external view returns (uint256) {
    return orderIdBySeller[_seller].length;
  }


  // make order fx
  //0:Fixed Price, 1:Dutch Auction, 2:English Auction
  function dutchAuction(uint256 _id,  string memory _uri, uint256 _startPrice, uint256 _endPrice, uint256 _endBlock) public {
    require(_startPrice > _endPrice, "End price should be lower than start price");
    _makeOrder(1, _id, _uri, _startPrice, _endPrice, _endBlock);
  }  //sp != ep

  function englishAuction(uint256 _id, string memory _uri, uint256 _startPrice, uint256 _endBlock) public {
    _makeOrder(2, _id, _uri, _startPrice, 0, _endBlock);
  } //ep=0. for gas saving.

  function fixedPrice( uint256 _id,  string memory _uri, uint256 _startPrice, uint256 _endBlock) public {
    _makeOrder(0, _id, _uri, _startPrice, 0, _endBlock);
  }  //ep=0. for gas saving.

  function _makeOrder(
    uint8 _orderType,
    uint256 _id,
    string memory _uri,
    uint256 _startPrice,
    uint256 _endPrice,
    uint256 _endBlock
  ) internal {
    require(_endBlock > block.number, "Duration must be more than zero");

    //push
    bytes32 hash = _hash(_id, msg.sender);
    orderInfo[hash] = Order(_orderType, msg.sender, _token, _id, _uri, _startPrice, _endPrice, block.number, _endBlock, 0, address(0), false);
    orderIdByToken[_token][_id].push(hash);
    orderIdBySeller[msg.sender].push(hash);

    //check if seller has a right to transfer the NFT token. safeTransferFrom.
    _token.safeTransferFrom(msg.sender, address(this), _id);

    emit MakeOrder(_token, _id, hash, msg.sender);
  }

  function _hash( uint256 _id, address _seller) internal view returns (bytes32) {
    return keccak256(abi.encodePacked(block.number, _token, _id, _seller));
  }
  
  // take order fx
  //you have to pay only ETH for bidding and buying.

  //In this contract, since send function is used instead of transfer or low-level call function,
  //if a participant is a contract, it must have receive payable function.
  //But if it has some code in either receive or fallback fx, they might not be able to receive their ETH.
  //Even though some contracts can't receive their ETH, the transaction won't be failed.

  //Bids must be at least 5% higher than the previous bid.
  //If someone bids in the last 5 minutes of an auction, the auction will automatically extend by 5 minutes.
  function bid(bytes32 _order) payable external {
    Order storage o = orderInfo[_order];
    uint256 endBlock = o.endBlock;
    uint256 lastBidPrice = o.lastBidPrice;
    address lastBidder = o.lastBidder;

    require(o.orderType == 2, "only for English Auction");
    require(endBlock != 0, "Canceled order");
    require(block.number <= endBlock, "It's over");
    require(o.seller != msg.sender, "Can not bid to your order");

    if (lastBidPrice != 0) {
      require(msg.value >= lastBidPrice + (lastBidPrice / 20), "low price bid");  //5%
    } else {
      require(msg.value >= o.startPrice && msg.value > 0, "low price bid");
    }

    if (block.number > endBlock - 20) {  //20blocks = 5 mins in Etherium.
      o.endBlock = endBlock + 20;
    }

    o.lastBidder = msg.sender;
    o.lastBidPrice = msg.value;

    if (lastBidPrice != 0) {
      payable(lastBidder).transfer(lastBidPrice);
    }
    
    emit Bid(o.token, o.tokenId, _order, msg.sender, msg.value);
  }

  function buyItNow(bytes32 _order) payable external {
    Order storage o = orderInfo[_order];
    uint256 endBlock = o.endBlock;
    require(endBlock != 0, "Canceled order");
    require(endBlock > block.number, "It's over");
    require(o.orderType < 2, "It's a English Auction");
    require(o.isSold == false, "Already sold");

    uint256 currentPrice = getCurrentPrice(_order);
    require(msg.value >= currentPrice, "price error");

    o.isSold = true;    //reentrancy proof

    uint256 fee = currentPrice * feePercent / 10000;
    payable(o.seller).transfer(currentPrice - fee);
    payable(feeAddress).transfer(fee);
    if (msg.value > currentPrice) {
      payable(msg.sender).transfer(msg.value - currentPrice);
    }

    o.token.safeTransferFrom(address(this), msg.sender, o.tokenId);

    emit Claim(o.token, o.tokenId, _order, o.seller, msg.sender, currentPrice);
  }

  //both seller and taker can call this fx in English Auction. Probably the taker(last bidder) might call this fx.
  //In both DA and FP, buyItNow fx include claim fx.
  function claim(bytes32 _order) external {
    Order storage o = orderInfo[_order];
    address seller = o.seller;
    address lastBidder = o.lastBidder;
    require(o.isSold == false, "Already sold");

    require(seller == msg.sender || lastBidder == msg.sender, "Access denied");
    require(o.orderType == 2, "This function is for English Auction");
    require(block.number > o.endBlock, "Not yet");

    IERC721 token = o.token;
    uint256 tokenId = o.tokenId;
    uint256 lastBidPrice = o.lastBidPrice;

    uint256 fee = lastBidPrice * feePercent / 10000;

    o.isSold = true;

    payable(seller).transfer(lastBidPrice - fee);
    payable(feeAddress).transfer(fee);
    token.safeTransferFrom(address(this), lastBidder, tokenId);

    emit Claim(token, tokenId, _order, seller, lastBidder, lastBidPrice);
  }


  function cancelOrder(bytes32 _order) external {
    Order storage o = orderInfo[_order];
    require(o.seller == msg.sender, "Access denied");
    require(o.lastBidPrice == 0, "Bidding exist"); //for EA. but even in DA, FP, seller can withdraw his/her token with this fx.
    require(o.isSold == false, "Already sold");

    IERC721 token = o.token;
    uint256 tokenId = o.tokenId;

    o.endBlock = 0;   //0 endBlock means the order was canceled.

    token.safeTransferFrom(address(this), msg.sender, tokenId);
    emit CancelOrder(token, tokenId, _order, msg.sender);
  }

  //feeAddress must be either an EOA or a contract must have payable receive fx and doesn't have some codes in that fx.
  //If not, it might be that it won't be receive any fee.
  function setFeeAddress(address _feeAddress) external onlyOwner {
    feeAddress = _feeAddress;
  }

  function updateFeePercent(uint16 _percent) external onlyOwner {
    require(_percent <= 10000, "input value is more than 100%");
    feePercent = _percent;
  }



  function setNFTToken(IERC721 token) onlyOwner public {
    _token = token;
  }

}