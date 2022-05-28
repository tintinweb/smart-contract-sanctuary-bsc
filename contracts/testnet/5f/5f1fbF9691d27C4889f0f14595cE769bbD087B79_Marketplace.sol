/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function mint(
        address to,
        uint256 tokenId,
        string memory uri
    ) external;
    function burn(uint256 tokenId) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
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
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
contract Marketplace is ReentrancyGuard, Ownable, IERC721Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _totalAmount;
    // Added an additional counter, since _tokenIds can be reduced by burning.
    // And intranal because the marketplace contract will display the total amount.
    Counters.Counter private _itemsSold;
    IERC721 private NFT;
    IERC20 private ERC20Token;
    uint256 private _mintPrice;
    uint256 private _auctionDuration;
    uint256 private _auctionMinimalBidAmount;
    constructor(
        uint256 newPrice,
        uint256 newAuctionDuration,
        uint256 newAuctionMinimalBidAmount
    ) {
        upgradeMintPrice(newPrice);
        setAuctionDuration(newAuctionDuration);
        setAuctionMinimalBidAmount(newAuctionMinimalBidAmount);
    }
    event NFTAddressChanged(address oldAddress, address newAddress);
    event ERC20AddressChanged(address oldAddress, address newAddress);
    event MintPriceUpgraded(uint256 oldPrice, uint256 newPrice, uint256 time);
    event Burned(uint256 indexed tokenId, address sender, uint256 currentTime);
    event EventCanceled(uint256 indexed tokenId, address indexed seller);
    event AuctionMinimalBidAmountUpgraded(
        uint256 newAuctionMinimalBidAmount,
        uint256 time
    );

    event AuctionDurationUpgraded(
        uint256 newAuctionDuration,
        uint256 currentTime
    );

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed owner,
        uint256 timeOfCreation
    );

    event ListedForSale(
        uint256 indexed itemId,
        uint256 price,
        uint256 listedTime,
        address indexed owner,
        address indexed seller
    );

    event Sold(
        uint256 indexed itemId,
        uint256 price,
        uint256 soldTime,
        address indexed seller,
        address indexed buyer
    );

    event StartAuction(
        uint256 indexed itemId,
        uint256 startPrice,
        address seller,
        uint256 listedTime
    );

    event BidIsMade(
        uint256 indexed tokenId,
        uint256 price,
        uint256 numberOfBid,
        address indexed bidder
    );

    event PositiveEndAuction(
        uint256 indexed itemId,
        uint256 endPrice,
        uint256 bidAmount,
        uint256 endTime,
        address indexed seller,
        address indexed winner
    );

    event NegativeEndAuction(
        uint256 indexed itemId,
        uint256 bidAmount,
        uint256 endTime
    );

    event NFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        bytes data
    );

    enum TokenStatus {
        DEFAULT,
        ACTIVE,
        ONSELL,
        ONAUCTION,
        BURNED
    }

    enum SaleStatus {
        DEFAULT,
        ACTIVE,
        SOLD,
        CANCELLED
    }

    enum AuctionStatus {
        DEFAULT,
        ACTIVE,
        SUCCESSFUL_ENDED,
        UNSUCCESSFULLY_ENDED
    }

    struct SaleOrder {
        address seller;
        address owner;
        uint256 price;
        SaleStatus status;
    }

    struct AuctionOrder {
        uint256 startPrice;
        uint256 startTime;
        uint256 currentPrice;
        uint256 bidAmount;
        address owner;
        address seller;
        address lastBidder;
        AuctionStatus status;
    }

    mapping(uint256 => TokenStatus) private _idToItemStatus;
    mapping(uint256 => SaleOrder) private _idToOrder;
    mapping(uint256 => AuctionOrder) private _idToAuctionOrder;

    modifier isActive(uint256 tokenId) {
        require(
            _idToItemStatus[tokenId] == TokenStatus.ACTIVE,
            "This NFT has already been put up for sale or auction!"
        );
        _;
    }

    modifier AuctionIsActive(uint256 tokenId) {
        require(
            _idToAuctionOrder[tokenId].status == AuctionStatus.ACTIVE,
            "Auction already ended!"
        );
        _;
    }

    function createItem(string memory tokenURI, address owner) external {
        ERC20Token.transferFrom(msg.sender, address(this), _mintPrice);

        _totalAmount.increment();
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        NFT.mint(owner, tokenId, tokenURI);

        _idToItemStatus[tokenId] = TokenStatus.ACTIVE;
        emit MarketItemCreated(tokenId, owner, block.timestamp);
    }

    function listItem(uint256 tokenId, uint256 price)
        external
        isActive(tokenId)
    {
        address owner = NFT.ownerOf(tokenId);
        NFT.safeTransferFrom(owner, address(this), tokenId);

        _idToItemStatus[tokenId] = TokenStatus.ONSELL;

        _idToOrder[tokenId] = SaleOrder(
            msg.sender,
            owner,
            price,
            SaleStatus.ACTIVE
        );

        emit ListedForSale(tokenId, price, block.timestamp, owner, msg.sender);
    }

    function buyItem(uint256 tokenId) external nonReentrant {
        SaleOrder storage order = _idToOrder[tokenId];
        require(order.status == SaleStatus.ACTIVE, "The token isn't on sale");

        order.status = SaleStatus.SOLD;
        ERC20Token.transferFrom(msg.sender, order.seller, order.price);

        NFT.safeTransferFrom(address(this), msg.sender, tokenId);
        _idToItemStatus[tokenId] = TokenStatus.ACTIVE;

        _itemsSold.increment();

        emit Sold(
            tokenId,
            order.price,
            block.timestamp,
            order.seller,
            msg.sender
        );
    }

    function cancel(uint256 tokenId) external nonReentrant {
        SaleOrder storage order = _idToOrder[tokenId];

        require(
            msg.sender == order.owner || msg.sender == order.seller,
            "You don't have the authority to cancel the sale of this token!"
        );
        require(
            _idToOrder[tokenId].status == SaleStatus.ACTIVE,
            "The token wasn't on sale"
        );

        NFT.safeTransferFrom(address(this), order.owner, tokenId);

        order.status = SaleStatus.CANCELLED;
        _idToItemStatus[tokenId] = TokenStatus.ACTIVE;

        emit EventCanceled(tokenId, msg.sender);
    }

    function listItemOnAuction(uint256 tokenId, uint256 minPeice)
        external
        isActive(tokenId)
    {
        address owner = NFT.ownerOf(tokenId);
        NFT.safeTransferFrom(owner, address(this), tokenId);

        _idToItemStatus[tokenId] = TokenStatus.ONAUCTION;

        _idToAuctionOrder[tokenId] = AuctionOrder(
            minPeice,
            block.timestamp,
            0,
            0,
            owner,
            msg.sender,
            address(0),
            AuctionStatus.ACTIVE
        );

        emit StartAuction(tokenId, minPeice, msg.sender, block.timestamp);
    }

    function makeBid(uint256 tokenId, uint256 price)
        external
        AuctionIsActive(tokenId)
    {
        AuctionOrder storage order = _idToAuctionOrder[tokenId];

        require(
            price > order.currentPrice && price >= order.startPrice,
            "Your bid less or equal to current bid!"
        );

        if (order.currentPrice != 0) {
            ERC20Token.transfer(order.lastBidder, order.currentPrice);
        }

        ERC20Token.transferFrom(msg.sender, address(this), price);

        order.currentPrice = price;
        order.lastBidder = msg.sender;
        order.bidAmount += 1;

        emit BidIsMade(tokenId, price, order.bidAmount, order.lastBidder);
    }

    function finishAuction(uint256 tokenId)
        external
        AuctionIsActive(tokenId)
        nonReentrant
    {
        AuctionOrder storage order = _idToAuctionOrder[tokenId];

        require(
            order.startTime + _auctionDuration < block.timestamp,
            "Auction duration not complited!"
        );

        if (order.bidAmount < _auctionMinimalBidAmount) {
            _cancelAuction(tokenId);
            emit NegativeEndAuction(tokenId, order.bidAmount, block.timestamp);
            return;
        }

        NFT.safeTransferFrom(address(this), order.lastBidder, tokenId);
        ERC20Token.transfer(order.seller, order.currentPrice);

        order.status = AuctionStatus.SUCCESSFUL_ENDED;
        _idToItemStatus[tokenId] = TokenStatus.ACTIVE;

        _itemsSold.increment();
        emit PositiveEndAuction(
            tokenId,
            order.currentPrice,
            order.bidAmount,
            block.timestamp,
            order.seller,
            order.lastBidder
        );
    }

    function cancelAuction(uint256 tokenId) external nonReentrant {
        require(
            msg.sender == _idToAuctionOrder[tokenId].owner ||
                msg.sender == _idToAuctionOrder[tokenId].seller,
            "You don't have the authority to cancel the sale of this token!"
        );
        require(
            _idToAuctionOrder[tokenId].bidAmount == 0,
            "You can't cancel the auction which already has a bidder!"
        );
        _cancelAuction(tokenId);
        emit EventCanceled(tokenId, _idToAuctionOrder[tokenId].seller);
    }

    function _cancelAuction(uint256 tokenId) private {
        _idToAuctionOrder[tokenId].status = AuctionStatus.UNSUCCESSFULLY_ENDED;

        NFT.safeTransferFrom(
            address(this),
            _idToAuctionOrder[tokenId].owner,
            tokenId
        );
        _idToItemStatus[tokenId] = TokenStatus.ACTIVE;

        if (_idToAuctionOrder[tokenId].bidAmount != 0) {
            ERC20Token.transfer(
                _idToAuctionOrder[tokenId].lastBidder,
                _idToAuctionOrder[tokenId].currentPrice
            );
        }
    }

    function burn(uint256 tokenId) external isActive(tokenId) {
        address owner = NFT.ownerOf(tokenId);
        require(owner == msg.sender, "Only owner can burn a token!");

        NFT.burn(tokenId);

        _totalAmount.decrement();
        _idToItemStatus[tokenId] = TokenStatus.BURNED;
        emit Burned(tokenId, msg.sender, block.timestamp);
    }

    function withdrawTokens(address receiver, uint256 amount)
        external
        onlyOwner
    {
        ERC20Token.transfer(receiver, amount);
    }

    function setNFTAddress(address newNFTAddress) external onlyOwner {
        emit NFTAddressChanged(address(NFT), newNFTAddress);
        NFT = IERC721(newNFTAddress);
    }

    function setERC20Token(address newToken) external onlyOwner {
        emit ERC20AddressChanged(address(ERC20Token), newToken);
        ERC20Token = IERC20(newToken);
    }

    function upgradeMintPrice(uint256 _newPrice) public onlyOwner {
        uint256 newPrice = _newPrice;
        emit MintPriceUpgraded(_mintPrice, newPrice, block.timestamp);
        _mintPrice = newPrice;
    }

    function setAuctionDuration(uint256 newAuctionDuration) public onlyOwner {
        _auctionDuration = newAuctionDuration;
        emit AuctionDurationUpgraded(newAuctionDuration, block.timestamp);
    }

    function setAuctionMinimalBidAmount(uint256 newAuctionMinimalBidAmount)
        public
        onlyOwner
    {
        _auctionMinimalBidAmount = newAuctionMinimalBidAmount;
        emit AuctionMinimalBidAmountUpgraded(
            newAuctionMinimalBidAmount,
            block.timestamp
        );
    }

    function getERC20Token() external view returns (address) {
        return address(ERC20Token);
    }

    function getNFT() external view returns (address) {
        return address(NFT);
    }

    function getTokenStatus(uint256 tokenId)
        external
        view
        returns (TokenStatus)
    {
        return _idToItemStatus[tokenId];
    }

    function getSaleOrder(uint256 tokenId)
        external
        view
        returns (SaleOrder memory)
    {
        return _idToOrder[tokenId];
    }

    function getAuctionOrder(uint256 tokenId)
        external
        view
        returns (AuctionOrder memory)
    {
        return _idToAuctionOrder[tokenId];
    }

    function getTotalAmount() public view returns (uint256) {
        return _totalAmount.current();
    }

    function getItemsSold() public view returns (uint256) {
        return _itemsSold.current();
    }

    function getMintPrice() external view returns (uint256) {
        return _mintPrice;
    }

    function getAuctionMinimalBidAmount() external view returns (uint256) {
        return _auctionMinimalBidAmount;
    }

    function getAuctionDuration() external view returns (uint256) {
        return _auctionDuration;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit NFTReceived(operator, from, tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }
}