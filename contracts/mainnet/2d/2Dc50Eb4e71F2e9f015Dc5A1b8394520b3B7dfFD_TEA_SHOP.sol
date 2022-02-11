/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol



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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol



pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol



pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function SET_DISVALUE_PARTNERS(uint256 _nft, uint256 _value, address _token) external returns (bool);
    function SET_POWER_UP(address _user,uint256 _power) external returns (bool);
    function GET_HERITAGE(address _address) external returns(uint256);
}

// File: contracts/TeaShop.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;


library SafeMath {

    uint constant TEN9 = 10**9;
  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  /**
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c;
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }

  function decMul18(uint x, uint y) public pure returns (uint decProd) {
    uint prod_xy = mul(x, y);
    decProd = add(prod_xy, TEN9 / 2) / TEN9;
  }

    function decDiv18(uint x, uint y) public pure returns (uint decQuotient) {
    uint prod_xTEN9 = mul(x, TEN9);
    decQuotient = add(prod_xTEN9, y / 2) / y;
  }
}


contract TEA_SHOP {

  using SafeMath for uint256;

    event bidPlaced(
        address _seller,
        address _bidder,
        uint256 _nft
    );
    event auctionListed(
        address _seller,
        uint256 _nft,
        uint256 _market
    );
    event saleMade(
        address _seller,
        uint256 _nft
    );
    event auctionClosed(

        address _seller,
        address _buyer,
        uint256 _nft
    );
    event royaltyPaid(

        address _creator,
        uint256 _nft
    );
    event bidAccepted(
        address _seller,
        address _buyer,
        uint256 _nft
        );

  mapping(uint256=>mapping(address=>AUCTION)) public nftToHostToAuction;
  mapping(uint256=>SHOP) public idToShop;
  mapping(address=>uint256) public bidderToOwedCredit;
  mapping(address=>SHOP) public ownerToShop;
  mapping(uint256=>address[]) public nftToBidders;
  mapping(address=>mapping(uint256=>mapping(address=>uint256))) public biddersToNFTtoBid;
  mapping(uint256=>address) public shopToOwner;
  mapping(address=>uint256[]) public buyerToNFTsBought;
  mapping(address=>uint256[]) public sellerTONFTsSold;
  mapping(address=>bool) public isAdmin;
  mapping(address=>bool) public BANNED;
  mapping(address=>mapping(uint256=>uint256)) public userToShopToRating;
  mapping(uint256=>uint256[]) public shopToRatings;
  mapping(uint256=>mapping(address=>uint256)) public nftToBidTime;

  uint256 auctionId;
  uint256 shopId;
  uint BIDFEE =2;
  uint  AUCTIONFEE =1;
  address TEATOKEN = 0xb4668238Acf0314A7b4e153368e479fCd2E09831;
  address TEAPOT = 0xd4dE3Aab3F26AF139b03b93CdEc9f688641cDd8f;
  address FEEADDRESS = 0xA495CC4D2C7371E946319b6f02Cbe2Bf69309628;
  address WALLTOKEN = 0x96c42f22078f6c48d419006dC2CC08c94aB4389F;

  struct AUCTION {

    uint256 id;
    uint256 quantity;
    uint256 royalty;
    uint256 auctionEnd;
    uint256 minPrice;
    uint256 buyNowPrice;
    uint256 bidQuantity;
    uint256 highestBid;
    address highestBidder;
    address seller;
    address nftCreator;
    address[] partners;
    uint256[] sips;
    uint32 active;
    address[] taxPartners;
    uint256[] taxSips;
    uint256 nft;
    uint256 market;

  }
  AUCTION[] public auctions;

  struct SHOP{

    uint256 id;
    address owner;
    string name;
    uint32 active;
    uint256 rating;
    address[] taxPartners;
    uint256[] taxSips;

  }

  constructor(){

    auctionId = 0;
    shopId = 0;
    isAdmin[msg.sender] = true;

  }

  receive () external payable {}

  function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

  function SET_ADMIN(address _admin) public{

    require(isAdmin[msg.sender], 'you are not an admin');

    if(isAdmin[_admin]){
      isAdmin[_admin] = false;
    }else{
      isAdmin[_admin] = true;
    }
  }
  function SET_BANNED(address _user) public{
    require(isAdmin[msg.sender], 'you are not an admin');

    if(BANNED[_user]){
      BANNED[_user] = false;
    }else{
      BANNED[_user] = true;
    }
  }
  function SET_WALLTOKEN(address _addy) public{
    require(isAdmin[msg.sender], 'you are not an admin');
    WALLTOKEN = _addy;

  }  function SET_TEAPOT(address _addy) public{
    require(isAdmin[msg.sender], 'you are not an admin');
    TEAPOT = _addy;

  }
  function SET_FEES(uint32 _TEAPOTBidFee, uint32 _auctionFee) public{

    require(isAdmin[msg.sender], 'you are not an admin');
    BIDFEE = _TEAPOTBidFee;
    AUCTIONFEE = _auctionFee;

  }
  function SET_FEEADDRESS(address _addy) public{
    require(isAdmin[msg.sender], 'you are not an admin');
    FEEADDRESS = _addy;
  }
  function SET_TEATOKEN(address _addy) public{
    require(isAdmin[msg.sender], 'you are not an admin');
    TEATOKEN = _addy;

  }
    function GET_BALANCE(address _user, uint256 _nft) public view returns(uint256){

    return IERC1155(TEAPOT).balanceOf(_user,_nft);

  }

  function SET_AUCTION(uint256 _nft,uint256 _buyNowPrice, uint256 _minPrice, address[] memory _partners, uint256[] memory _sips, uint256 _quantity, uint256 _royalty,address[] memory _taxPartners, uint256[] memory _taxSips, address _nftCreator,uint256 _market) public{

    require(IERC1155(TEAPOT).balanceOf(msg.sender,_nft)>=_quantity, 'you do not own than many nfts');

    auctionId = SafeMath.add(auctionId,1);

    AUCTION memory save = AUCTION({

      id:auctionId,
      auctionEnd: block.timestamp + 21 days,
      minPrice: _minPrice,
      buyNowPrice: _buyNowPrice,
      highestBid: _minPrice,
      bidQuantity:0,
      quantity:_quantity,
      highestBidder: msg.sender,
      seller:msg.sender,
      partners: _partners,
      sips: _sips,
      active: 1,
      royalty: _royalty,
      taxPartners: _taxPartners,
      taxSips: _taxSips,
      nftCreator: _nftCreator,
      nft:_nft,
      market:_market

    });

    nftToHostToAuction[_nft][msg.sender] = save;
    auctions.push(save);
    IERC1155(TEAPOT).safeTransferFrom(msg.sender,address(this),_nft,_quantity,'');
    IERC1155Receiver(address(this)).onERC1155Received(TEAPOT,msg.sender,_nft,_quantity,'');
    emit auctionListed(msg.sender,_nft,_market);

  }

  function GET_AUCTION(uint256 _nft,address _host) public view returns(AUCTION memory){

    return nftToHostToAuction[_nft][_host];

  }

  function SET_SHOP(string memory name, address[] memory taxPartners, uint256[] memory taxSips) public{

    require(!BANNED[msg.sender],'you are banned');
    shopId = SafeMath.add(shopId,1);
    SHOP memory save = SHOP({
      id:shopId,
      owner:msg.sender,
      name:name,
      active:1,
      rating:0,
      taxPartners: taxPartners,
      taxSips:taxSips
    });

    shopToOwner[shopId]= msg.sender;
    ownerToShop[msg.sender] = save;
    idToShop[shopId] = save;

  }

  function GET_SHOP(uint256 _shop, address _owner) public view returns(SHOP memory){

    if(_shop>0){

    return idToShop[_shop];

    }else{
        return ownerToShop[_owner];
    }
  }

  function DELETE_SHOP(uint256 _shop) public{

    require(ownerToShop[msg.sender].id==_shop,'You did not on this shop');

    ownerToShop[msg.sender].active = 0;

  }

  function SET_BID(uint256 _nft, address _host, uint256 _value, uint256 _quantity) public{

    uint256 _valueOG = _value;

    require(nftToHostToAuction[_nft][_host].active>0, 'this auction is not active');
    require(nftToHostToAuction[_nft][_host].highestBidder!=msg.sender,'You are already the highest bidder');
    require(msg.sender!=nftToHostToAuction[_nft][_host].seller,'cannot bid on your own auction');
    require(nftToHostToAuction[_nft][_host].minPrice<_value,'bid too low');
    require(nftToHostToAuction[_nft][_host].highestBid<_value, 'bid too low');
    require(nftToHostToAuction[_nft][_host].quantity>0, 'no more left');

    address useThisToken;

    if(nftToHostToAuction[_nft][_host].market==4){

        useThisToken = WALLTOKEN;
    }else{
        useThisToken = TEATOKEN;
    }
    uint256 _fee = _value.mul(BIDFEE).div(100);
    _value = _value.sub(_fee);
    IERC20(useThisToken).transferFrom(msg.sender,address(this), _value);
    IERC20(useThisToken).transferFrom(msg.sender,TEAPOT, _fee);
    require(checkSuccess(), "BID transfer failed");
    IERC1155(TEAPOT).SET_DISVALUE_PARTNERS(_nft,_fee,useThisToken);

    if(_valueOG>=nftToHostToAuction[_nft][_host].buyNowPrice){

      SET_PAYOUT(_nft,_value,_host);
      IERC1155(TEAPOT).safeTransferFrom(address(this),msg.sender,_nft,_quantity,'');
      require(checkSuccess(), "NFT buy now failed");

      if(nftToHostToAuction[_nft][_host].highestBidder!=nftToHostToAuction[_nft][_host].seller){
        //refund previous bidder
        IERC20(useThisToken).transferFrom(address(this),nftToHostToAuction[_nft][_host].highestBidder, nftToHostToAuction[_nft][_host].highestBid);
        require(checkSuccess(), "bid refund transfer failed");
      }

      nftToHostToAuction[_nft][_host].highestBidder = msg.sender;
      nftToHostToAuction[_nft][_host].highestBid = _value;
      biddersToNFTtoBid[msg.sender][_nft][_host] = _value;
      nftToBidders[_nft].push(msg.sender);
      nftToBidTime[_nft][_host] = block.timestamp;
      nftToHostToAuction[_nft][_host].bidQuantity = _quantity;
      nftToHostToAuction[_nft][_host].quantity = nftToHostToAuction[_nft][_host].quantity.sub(_quantity);
      emit saleMade(nftToHostToAuction[_nft][_host].seller,_nft);

    }else{
        //refund previous bidder

        if(nftToHostToAuction[_nft][_host].highestBidder!=nftToHostToAuction[_nft][_host].seller){

            IERC20(useThisToken).transferFrom(address(this),nftToHostToAuction[_nft][_host].highestBidder, nftToHostToAuction[_nft][_host].highestBid);
            require(checkSuccess(), "bid refund transfer failed");
        }
        nftToHostToAuction[_nft][_host].highestBidder = msg.sender;
        nftToHostToAuction[_nft][_host].highestBid = _value;
        nftToBidders[_nft].push(msg.sender);
        biddersToNFTtoBid[msg.sender][_nft][_host] = _value;
        nftToBidTime[_nft][_host] = block.timestamp;
        nftToHostToAuction[_nft][_host].bidQuantity = _quantity;
        nftToHostToAuction[_nft][_host].quantity = nftToHostToAuction[_nft][_host].quantity.sub(_quantity);
        emit bidPlaced(nftToHostToAuction[_nft][_host].seller,msg.sender,_nft);
    }
  }

  function END_AUCTION(uint256 _nft,uint256 _type, address _host) public {

    if(_type==1){

    require(nftToHostToAuction[_nft][_host].seller==msg.sender, 'you are not the auction host');


    if(nftToHostToAuction[_nft][_host].highestBidder!=nftToHostToAuction[_nft][_host].seller){

         SET_PAYOUT(_nft,nftToHostToAuction[_nft][_host].highestBid,_host);
         buyerToNFTsBought[nftToHostToAuction[_nft][_host].highestBidder].push(_nft);
         sellerTONFTsSold[nftToHostToAuction[_nft][_host].seller].push(_nft);
         emit bidAccepted(nftToHostToAuction[_nft][_host].seller,nftToHostToAuction[_nft][_host].highestBidder,_nft);

    }else{

      IERC1155(TEAPOT).safeTransferFrom(address(this),msg.sender,_nft,nftToHostToAuction[_nft][_host].quantity,'');
      require(checkSuccess(), "End auction transfer failed");
      nftToHostToAuction[_nft][_host].active = 0;
      emit auctionClosed(msg.sender,nftToHostToAuction[_nft][_host].highestBidder,_nft);

     }
    }else{

        require(nftToHostToAuction[_nft][_host].highestBidder==msg.sender, 'you are not the highest bidder');
        require(nftToHostToAuction[_nft][_host].auctionEnd<block.timestamp,'Auction is not over');
        SET_PAYOUT(_nft,nftToHostToAuction[_nft][_host].highestBid,_host);
        buyerToNFTsBought[nftToHostToAuction[_nft][_host].highestBidder].push(_nft);
        sellerTONFTsSold[nftToHostToAuction[_nft][_host].seller].push(_nft);
    }

  }

 function UPDATE_AUCTION(uint256 _nft, uint32 _minPrice, uint32 _buyNowPrice) public{

    require(nftToHostToAuction[_nft][msg.sender].seller==msg.sender,'You did not create this auction');
    require(nftToHostToAuction[_nft][msg.sender].highestBidder!=nftToHostToAuction[_nft][msg.sender].seller,'a bid was placed');
    nftToHostToAuction[_nft][msg.sender].minPrice = _minPrice;
    nftToHostToAuction[_nft][msg.sender].buyNowPrice = _buyNowPrice;

  }

  function SET_PAYOUT(uint256 _nft, uint256 _value, address _host) internal returns(bool){

    uint256 auctionFee = _value.mul(AUCTIONFEE).div(100);
    uint256 quantity = nftToHostToAuction[_nft][_host].bidQuantity;
    address useThisToken;

    if(nftToHostToAuction[_nft][_host].market==4){

        useThisToken = WALLTOKEN;
    }else{
        useThisToken = TEATOKEN;
    }
    IERC20(useThisToken).transfer(FEEADDRESS, auctionFee);
    require(checkSuccess(), "auction fee payout failed");

    _value = _value.sub(auctionFee);
    uint royalty;

    ///pay taxes
    for (uint256 i = 0; i<nftToHostToAuction[_nft][_host].taxPartners.length; i++){

      if(nftToHostToAuction[_nft][_host].taxSips[i]>0){

        uint256 tax =  _value.mul(nftToHostToAuction[_nft][_host].taxSips[i]).div(100);
        _value = _value.sub(tax);
        PAY(_nft,nftToHostToAuction[_nft][_host].taxPartners[i],tax,_host);
      }
    }

    if(nftToHostToAuction[_nft][_host].seller==nftToHostToAuction[_nft][_host].nftCreator){

      ///split value among partners
      for (uint256 i = 0; i<nftToHostToAuction[_nft][_host].partners.length; i++){

        if(nftToHostToAuction[_nft][_host].sips[i]>0){
        royalty = _value.mul(nftToHostToAuction[_nft][_host].sips[i]).div(100);
        _value = _value.sub(royalty);
        PAY(_nft,nftToHostToAuction[_nft][_host].partners[i],royalty,_host);
        }
      }

    }else{

      ///pay royalties only
      uint256 royaltyValue = _value.mul(nftToHostToAuction[_nft][_host].royalty).div(100);

      for (uint256 i = 0; i<nftToHostToAuction[_nft][_host].sips.length; i++){
        if(nftToHostToAuction[_nft][_host].sips[i]>0){
            royalty = royaltyValue.mul(nftToHostToAuction[_nft][_host].sips[i]).div(100);
            _value = _value.sub(royalty);
            PAY(_nft,nftToHostToAuction[_nft][_host].partners[i],royalty,_host);
            if(nftToHostToAuction[_nft][_host].sips[i]==0){
                emit royaltyPaid(nftToHostToAuction[_nft][_host].nftCreator,_nft);
            }
        }

      }
      //pay seller
      PAY(_nft,nftToHostToAuction[_nft][_host].seller,_value,_host);

    }

      uint256 powerUp = 1;
      uint256 heritageSeller = IERC1155(TEAPOT).GET_HERITAGE(nftToHostToAuction[_nft][_host].seller);
      uint256 heritageBuyer = IERC1155(TEAPOT).GET_HERITAGE(msg.sender);
      if(heritageBuyer!=heritageSeller){
      powerUp = 3;
      }
      IERC1155(TEAPOT).safeTransferFrom(address(this),nftToHostToAuction[_nft][_host].highestBidder,_nft,quantity,'');
      IERC1155(TEAPOT).SET_POWER_UP(nftToHostToAuction[_nft][_host].highestBidder,powerUp);
      IERC1155(TEAPOT).SET_POWER_UP(nftToHostToAuction[_nft][_host].seller,2);
      if(nftToHostToAuction[_nft][_host].quantity<1){
         nftToHostToAuction[_nft][_host].active = 2;
      }

      nftToHostToAuction[_nft][_host].auctionEnd = block.timestamp;
      emit auctionClosed(msg.sender,nftToHostToAuction[_nft][_host].highestBidder,_nft);
      return true;
  }

  function PAY(uint256 _nft, address payTo, uint256 _value, address _host) internal returns(bool){
    address useThisToken;

    if(nftToHostToAuction[_nft][_host].market==4){

        useThisToken = WALLTOKEN;
    }else{
        useThisToken = TEATOKEN;
    }

    IERC20(useThisToken).transfer(payTo, _value);
    require(checkSuccess(), "PAY failed");
    return true;
  }

  function checkSuccess()
      private pure
      returns (bool)
    {
      uint256 returnValue = 0;

      /* solium-disable-next-line security/no-inline-assembly */
      assembly {
        // check number of bytes returned from last function call
        switch returndatasize()

          // no bytes returned: assume success
          case 0x0 {
            returnValue := 1
          }

          // 32 bytes returned: check if non-zero
          case 0x20 {
            // copy 32 bytes into scratch space
            returndatacopy(0x0, 0x0, 0x20)

            // load those bytes into returnValue
            returnValue := mload(0x0)
          }

          // not sure what was returned: dont mark as success
          default { }

      }

      return returnValue != 0;
    }

}