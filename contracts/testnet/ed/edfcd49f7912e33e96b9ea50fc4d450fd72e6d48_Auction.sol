/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// File: Auction.sol


pragma solidity ^0.8.9;




contract Auction{
    uint public auctionEndTime;
    uint public auctionStartTime;
    uint public s_minBid;
    uint public s_bidIncr;
    uint public highestBid;
     address payable public highestBidder;
     address payable owner;
    uint public tokenId;
    address public thisAdress = address(this);

   mapping(address => uint) public bids;
    struct AuctionDetails {
        uint highestBid;
        address highestBidder;
        uint bidEnd;
    }

    AuctionDetails[] public auctionDetails;
    INftContract nftContract;

    constructor() {
        
        owner = payable(msg.sender);
    }
  modifier onlyDuringBidding() {
        require(block.timestamp >= auctionStartTime && block.timestamp <= auctionEndTime, "Bidding is not currently open");
        _;
    }

modifier onlyAfterBidding() {
    require(block.timestamp > auctionEndTime, "Auction: Bidding is still open");
    _;
}

 
 

 function getOwner(uint _nftTokenId) public view returns(address) {
    return nftContract.ownerOf(_nftTokenId);
 }

 function _getApproved(uint _tokenId) public view returns(address)  {
    return  nftContract.getApproved(_tokenId);
 }

 function _setApprovalForAll (address AuctionContract, bool approved) public {
    return nftContract.setApprovalForAll(AuctionContract, approved);
 }

function _approve (address _auctionContract, uint _tokenId) public {
    nftContract.approve(_auctionContract, _tokenId);
}


    function createAuction(uint _nftTokenId, uint _minBid, uint _end, uint _start, address nftContractAddress) public {
    nftContract = INftContract(nftContractAddress);
    require(nftContract.ownerOf(_nftTokenId) == msg.sender, "Auction: Not Owner of Nft");
    // nftContract.approve(thisAdress, _nftTokenId);s
    s_minBid = _minBid;
    highestBid =_minBid;
    auctionStartTime = block.timestamp + _start;
    auctionEndTime = block.timestamp + _end;
    tokenId = _nftTokenId;
    }

    function placeBid() payable public {
        require(msg.value >= highestBid, "Auction: Bid must be greater than highest bid");
        require(auctionEndTime > block.timestamp, "Auction: Auction over");
        require(msg.sender != owner, "Auction: Owner can't bid on this NFT");
        if(highestBidder != address(0)) {
            bool sent = highestBidder.send(highestBid);
            require(sent, "Failed to send Eth");
            // payable(highestBidder).transfer(highestBid);
        }
        highestBid = msg.value;
        highestBidder = payable(msg.sender);
        bids[msg.sender] = msg.value;
    } 

    function claim() onlyAfterBidding public {
        nftContract.transferFrom(owner, highestBidder, tokenId);
        (bool sent, bytes memory data) = owner.call{value: highestBid}("");
        require(sent, "Failed to send Ether");    
    }

    function withdraw() public {
         owner.transfer(highestBid);
    }

receive() external payable {}

  
}

interface INftContract {
      /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

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
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

      function getApproved(uint256 tokenId) external view returns (address operator);
    
       function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}