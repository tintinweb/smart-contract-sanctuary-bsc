/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// File: RichCatsToken.sol


pragma solidity ^0.8;

abstract contract RichCatsToken {
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    
    function balanceOf(address owner) public virtual view returns (uint);

    function approve(address spender, uint value) public virtual returns (bool);
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

// File: rcnBiddingWar.sol


pragma solidity ^0.8.13;





contract RCNauction is Ownable{
    event Start();
    event Bid(address indexed sender, uint amount);
    event Cancelbid(address indexed bidder, uint amount);
    event End(address winner, uint amount);


    mapping(address => uint) public bids;

    mapping (uint => Listing) public listings;
    uint public auctionCount;
    
    mapping (uint => mapping(uint => Bidder)) public bidders;
    mapping (uint => uint) public bidCount;
    
    uint public auctionTimer = 10 minutes;
    

    address constant RCNT_ADDRESS = 0x2370f1c27da5048038724843C258168f452A7e4a;

    struct Listing {
        uint256 highestBid;
        address highestBidder;
        address seller;
        bool started;
        uint256 endAt;
        address nftContract;
        uint256 tokenId;
    }
    struct Bidder{
        uint id;
        address bidderAddr;
        uint bidValue;
    }


    function setAuctionTimer (uint _timervalue) public onlyOwner {
        auctionTimer = _timervalue;
    }

    function addListing(address contractAddr, uint256 tokenId) public onlyOwner{
        listings[auctionCount] = Listing(0,address(0),msg.sender,false,0,contractAddr,tokenId);
        auctionCount++;

    }

    function start(uint _auctionCount) public onlyOwner {
        Listing memory item = listings[_auctionCount];
        require(item.started != true, "started");
        require(msg.sender == item.seller, "not seller");
        
        uint auction_timer = block.timestamp + auctionTimer;
        listings[_auctionCount] = Listing(0,address(0),msg.sender,true,auction_timer,item.nftContract,item.tokenId);
        IERC721(item.nftContract).transferFrom(msg.sender,address(this),item.tokenId);
        
        emit Start();
    }

    function end(uint _auctionCount)  public onlyOwner {
        Listing memory item = listings[_auctionCount];
        require(item.started == true, "not started");
        require(block.timestamp >= item.endAt, "not ended yet");
        require(msg.sender == item.seller, "not seller");
   
        if (item.highestBidder != address(0)) {
            
            IERC721(item.nftContract).safeTransferFrom(address(this), item.highestBidder,item.tokenId);
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),item.highestBid));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),item.seller,item.highestBid);
        } else {
            IERC721(item.nftContract).safeTransferFrom(address(this), item.seller,item.tokenId);
        }

        emit End(item.highestBidder, item.highestBid);
    }



    function bid(uint256 bidvalue, uint _auctionCount) public payable {
        Listing memory item = listings[_auctionCount];
        require(item.started == true, "auction not yet started");
        require(block.timestamp < item.endAt, "ended");
        require(RichCatsToken(RCNT_ADDRESS).balanceOf(msg.sender) > item.highestBid, "Balance of RCNT not sufficient.");
        require(bidvalue > (item.highestBid/100)*110, "your bidbvalue is too low! offer >10%+");

        //refund last highestbidder
        if (item.highestBidder != address(0)) {
            require(RichCatsToken(RCNT_ADDRESS).approve(address(this),item.highestBid));
            RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),item.highestBidder,item.highestBid);
        }
        
        //update record new highestbidder & send rcnt
        listings[_auctionCount] = Listing(bidvalue,msg.sender,item.seller,item.started,item.endAt,item.nftContract,item.tokenId);
        bids[msg.sender] += bidvalue;

        bidders[_auctionCount][bidCount[_auctionCount]] = Bidder(block.timestamp,msg.sender,bidvalue);
        bidCount[_auctionCount]++;

        require(RichCatsToken(RCNT_ADDRESS).approve(msg.sender,bidvalue));
        RichCatsToken(RCNT_ADDRESS).transferFrom(msg.sender,address(this),bidvalue);

        emit Bid(msg.sender, bidvalue);
    }

    function cancelbid(uint _auctionCount) public payable {
        Listing memory item = listings[_auctionCount];
        require(item.started == true, "auction not yet started");
        require(block.timestamp < item.endAt, "ended");
        require(item.highestBidder == msg.sender, "not the highest bidder!");
        
        require(RichCatsToken(RCNT_ADDRESS).approve(address(this),item.highestBid));
        RichCatsToken(RCNT_ADDRESS).transferFrom(address(this),msg.sender,item.highestBid);

        emit Cancelbid(item.highestBidder, item.highestBid);

        bidders[_auctionCount][bidCount[_auctionCount]-1] = Bidder(block.timestamp,address(0),0);
        bidCount[_auctionCount]--;
        
        listings[_auctionCount] = Listing(0,address(0),item.seller,item.started,item.endAt,item.nftContract,item.tokenId);
        bids[msg.sender] = 0;

    }




    
//return Array of structure Value
  function getBidder(uint _auctioncount) public view returns (uint[] memory, address[] memory,uint[] memory){
      uint[]    memory id = new uint[](bidCount[_auctioncount]);
      address[]  memory bidderAddr = new address[](bidCount[_auctioncount]);
      uint[]    memory bidValue = new uint[](bidCount[_auctioncount]);
      for (uint i = 0; i < bidCount[_auctioncount]; i++) {
          Bidder storage bidder = bidders[_auctioncount][i];
          id[i] = bidder.id;
          bidderAddr[i] = bidder.bidderAddr;
          bidValue[i] = bidder.bidValue;
      }

      return (id, bidderAddr,bidValue);

  }



  //return Single structure
  function get(uint _auctionCount) public view returns(Listing memory) {
    return listings[_auctionCount];
  }




  //return Array of structure Value
  function getAuction() public view returns (uint[] memory, address[] memory,uint[] memory){
      uint[]    memory highestBid = new uint[](auctionCount);
      address[]  memory nftContract = new address[](auctionCount);
      uint[]    memory tokenId = new uint[](auctionCount);
      for (uint i = 0; i < auctionCount; i++) {
          Listing storage auction = listings[i];
          highestBid[i] = auction.highestBid;
          nftContract[i] = auction.nftContract;
          tokenId[i] = auction.tokenId;
          
      }

      return (highestBid, nftContract,tokenId);

  }
  //return Array of structure
  function getauctions() public view returns (Listing[] memory){
      Listing[]    memory id = new Listing[](auctionCount);
      for (uint i = 0; i < auctionCount; i++) {
          Listing storage auction = listings[i];
          id[i] = auction;
      }
      return id;
  }



}