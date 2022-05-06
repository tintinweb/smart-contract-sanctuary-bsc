/**
 * Submitted for verification at BscScan.com on 2022-04-09
 */

// File: contracts/Auction.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./interfaces/IOERC721.sol";

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

// NichoNFT interface
interface INichoNFT {
    function commissionFee() external view returns (uint256);
    function denominator() external view returns (uint256);
    function _feeAddress() external view returns (address payable);
    function whitelist(address wallet) external view returns (bool);
    function blackList(address tokenAddress, uint256 tokenId) external view returns (bool);
}

contract NichoAuction is Ownable{
    INichoNFT public NichoNFT;

    struct Buyer {
        address owner;
        uint256 bidPrice;
    }

    // Auction Item
    struct Item {
        address creator; //address of creator
        address tokenAddress; // token address
        uint256 tokenId; // token id
        string uri; //IPFS URL
        uint256 highPrice;
        uint256 deadline;
        uint256 createdTs;
        bool exists;
        Buyer[] buyers;
    }
    // Param for auction creation
    struct ItemParam {
        address tokenAddress; 
        uint256 tokenId; 
        uint256 desiredMinPrice;
        uint256 deadline;
    }

    // OfferItem
    struct OfferItem {
        address creator;
        uint256 price;
        uint256 expireTs;
        uint256 createdAt;
        bool isCancel;
    }

    // Auction ID counter
    uint256 public auctionCounter = 0;
    // Auction ID => Auction Item
    mapping(uint256 => Item) public items;
    // Token Address => TokenId => Auction ID
    mapping(address => mapping(uint256 => uint256)) public tokenIdToAuctionId;

    // Offer List
    // Token address => Token id => creator => offer item
    mapping(address => mapping(uint256 => mapping(address => OfferItem))) public offerItems;

    modifier notBlackList(address tokenAddress, uint256 _tokenId) {
        require(NichoNFT.blackList(tokenAddress, _tokenId) == false, "TokenId is in blackList");
        _;
    }

    modifier tokenOwner(address tokenAddress, uint256 tokenId) {
        IOERC721 token = IOERC721(tokenAddress);

        require(msg.sender == token.ownerOf(tokenId), "You are not a token owner");
        _;
    }
    
    modifier auctionOwner(uint256 auctionId) {
        Item memory item = items[auctionId];
        IOERC721 token = IOERC721(item.tokenAddress);
        require(token.ownerOf(item.tokenId) == msg.sender, "Only AuctionOwner");
        _;
    }

    modifier onlyTokenOwner(address tokenAddress, uint256 tokenId) {
        IOERC721 token = IOERC721(tokenAddress);
        require(token.ownerOf(tokenId) == msg.sender, "Only token owner");
        _;
    }

    modifier auctionNotExist(address tokenAddress, uint256 tokenId) {
        uint256 auctionId = tokenIdToAuctionId[tokenAddress][tokenId];
        Item memory item = items[auctionId];
        require(item.exists != true, "Auction Exists");
        _;
    }

    modifier auctionStarted(uint256 auctionId) {
        Item memory item = items[auctionId];
        require(block.timestamp > item.createdTs, "Auction not started");
        _;
    }

    modifier auctionNotEnded(uint256 auctionId) {
        Item memory item = items[auctionId];
        require(block.timestamp <= item.deadline, "Auction ended");
        _;
    }

    modifier auctionEnded(uint256 auctionId) {
        Item memory item = items[auctionId];
        require(block.timestamp > item.deadline, "Auction not ended");
        _;
    }

    modifier auctionExist(uint256 auctionId) {
        Item memory item = items[auctionId];
        require(item.exists, "Auction does not exist");
        _;
    }

    // Auction event
    event AddItem(uint256 auctionId, address tokenAddress, uint256 tokenId, string uri, uint256 price, address creator, uint256 deadline);
    event ItemCancel(uint256 auctionId);
    event PlacedBid(uint256 auctionId, address bider, uint256 bidPrice);
    event SoldOut(uint256 auctionId, uint256 soldPrice, address seller, address winner);
    event CancelBid(uint256 auctionId, address bidCreator);

    // Offer event
    event OfferCreated(address tokenAddress, uint256 tokenId, address creator, uint256 offerPrice, string uri, uint256 deadline);
    event OfferSoldOut(address tokenAddress, uint256 tokenId, address seller, address buyer, uint256 offerPrice);
    event OfferCancel(address tokenAddress, uint256 tokenId, address creator);
    
    constructor(address _nichoNFT) {
        NichoNFT = INichoNFT(_nichoNFT);
    }

    receive() external payable {}

    function addAuctionItem(ItemParam memory itemParam) 
        tokenOwner(itemParam.tokenAddress, itemParam.tokenId)
        auctionNotExist(itemParam.tokenAddress, itemParam.tokenId)
        external {
            uint256 itemDeadLine = itemParam.deadline;
            uint256 itemPrice = itemParam.desiredMinPrice;

            require(itemDeadLine > block.timestamp, "Invalid deadline");

            IOERC721 tokenObject = IOERC721(itemParam.tokenAddress);
            // require(tokenObject.getApproved(tokenId) == address(this), "Token should be approved");

            string memory uri = tokenObject.tokenURI(itemParam.tokenId);

            auctionCounter++;
            uint256 auctionId = auctionCounter;
            {
                Item storage item = items[auctionId];
                item.creator = msg.sender;
                item.tokenAddress = itemParam.tokenAddress;
                item.tokenId = itemParam.tokenId;
                item.uri = uri;
                item.highPrice = itemPrice;
                item.deadline = itemDeadLine;
                item.createdTs = block.timestamp;
                item.exists = true;
            }
            
            tokenIdToAuctionId[itemParam.tokenAddress][itemParam.tokenId] = auctionCounter;

            emit AddItem(auctionId, itemParam.tokenAddress, itemParam.tokenId, uri, itemPrice, msg.sender, itemDeadLine);
    }

    function cancelAuctionItem(uint256 auctionId)
        auctionOwner(auctionId)
        auctionExist(auctionId)
        external {
            Item memory item = items[auctionId];
            item.exists = false;
            emit ItemCancel(auctionId);
    }

    function placeBid(uint256 auctionId)
        auctionExist(auctionId)
        auctionStarted(auctionId)
        auctionNotEnded(auctionId)
        external payable {
            Item storage item = items[auctionId];
            IOERC721 nftToken = IOERC721(item.tokenAddress);
            require(nftToken.ownerOf(item.tokenId) != msg.sender, "Creator not able to place bid");
            require(msg.value > item.highPrice, "Price need to be higher than highest bid price");

            item.highPrice = msg.value;
            Buyer memory buyer = Buyer(msg.sender, msg.value);
            item.buyers.push(buyer);

            emit PlacedBid(auctionId, msg.sender, msg.value);
        }

    function acceptBid(uint256 auctionId, uint256 bidderId)
        auctionOwner(auctionId)
        auctionExist(auctionId)
        auctionEnded(auctionId)
        external {
            Item storage item = items[auctionId];
            require(item.buyers.length >= bidderId + 1, "Bidder does not exist");
            item.exists = false;
            Buyer storage buyer = item.buyers[bidderId];
            
            if (IOERC721(item.tokenAddress).getApproved(item.tokenId) == address(this)) {
                IOERC721(item.tokenAddress).safeTransferFrom(msg.sender, buyer.owner, item.tokenId);

                bool isInWhiteList = NichoNFT.whitelist(msg.sender) || NichoNFT.whitelist(buyer.owner);
                // commission cut
                uint _commissionValue = buyer.bidPrice * NichoNFT.commissionFee() / NichoNFT.denominator() / 100 ;
                if (isInWhiteList) _commissionValue = 0;
                uint _sellerValue = buyer.bidPrice - _commissionValue;
                if (_commissionValue > 0) {
                    NichoNFT._feeAddress().transfer(_commissionValue);
                }

                payable(msg.sender).transfer(_sellerValue);
                emit SoldOut(auctionId, buyer.bidPrice, msg.sender, buyer.owner);

                buyer.bidPrice = 0;
            } else {
                revert("Approve NFT");
            }
        }

    
    function cancelBid(uint256 auctionId)
        auctionEnded(auctionId)
        external {
            Item storage item = items[auctionId];
            uint256 totalBidAmount = 0;

            for(uint256 i = 0; i < item.buyers.length; i++) {
                Buyer memory buyer = item.buyers[i];
                if (buyer.owner == msg.sender && buyer.bidPrice > 0) {
                    totalBidAmount += buyer.bidPrice;
                    buyer.bidPrice = 0;
                }
            }

            require(totalBidAmount > 0, "Cancel: Already withdrawed");
            
            payable(msg.sender).transfer(totalBidAmount);
            emit CancelBid(auctionId, msg.sender);
        }

    
    function getBidsByBidder(uint256 auctionId)
        external view returns(Buyer[] memory){
            Item memory item = items[auctionId];

            Buyer[] memory buyers;
            uint256 index = 0;
            for(uint256 i = 0; i < item.buyers.length; i++) {
                Buyer memory buyer = item.buyers[i];
                if (buyer.owner == msg.sender && buyer.bidPrice > 0) {
                    buyers[index] = buyer;
                    index++;
                }
            }

            return buyers;
        }

    function isNFTListedToAuction(address tokenAddress, uint256 tokenId)
        external view returns(bool) {
            // IOERC721 token = IOERC721(tokenAddress);
            uint256 auctionId = tokenIdToAuctionId[tokenAddress][tokenId];
            Item memory item = items[auctionId];
            return item.exists;
        }

    function createOffer(address tokenAddress, uint256 tokenId, uint256 deadline) 
        external payable {
            require(msg.value > 0, "Invalid amount");
            require(deadline >= block.timestamp, "Invalid deadline");
            
            OfferItem storage item = offerItems[tokenAddress][tokenId][msg.sender];
            require(item.price == 0 || item.isCancel, "You already created offer");

            item.creator = msg.sender;
            item.price = msg.value;
            item.expireTs = deadline;
            item.isCancel = false;
            item.createdAt = block.timestamp;

            IOERC721 tokenObject = IOERC721(tokenAddress);
            string memory uri = tokenObject.tokenURI(tokenId);

            emit OfferCreated(tokenAddress, tokenId, msg.sender, msg.value, uri, deadline);
        }

    function acceptOffer(address tokenAddress, uint256 tokenId, address offerCreator) 
        onlyTokenOwner(tokenAddress, tokenId)
        external {
            OfferItem storage item = offerItems[tokenAddress][tokenId][offerCreator];
            require(item.isCancel == false, "Offer creator withdrawed");
            require(item.expireTs >= block.timestamp, "Offer already expired");
            if (IOERC721(tokenAddress).getApproved(tokenId) == address(this)) {
                IOERC721(tokenAddress).safeTransferFrom(msg.sender, item.creator, tokenId);

                bool isInWhiteList = NichoNFT.whitelist(msg.sender) || NichoNFT.whitelist(IOERC721(tokenAddress).ownerOf(tokenId));
                // commission cut
                uint _commissionValue = item.price * NichoNFT.commissionFee() / NichoNFT.denominator() / 100 ;
                if (isInWhiteList) _commissionValue = 0;
                uint _sellerValue = item.price - _commissionValue;
                if (_commissionValue > 0) {
                    NichoNFT._feeAddress().transfer(_commissionValue);
                }
                payable(msg.sender).transfer(_sellerValue);
                item.isCancel = true;
            } else {
                revert("Approve NFT");
            }

            emit OfferSoldOut(tokenAddress, tokenId, msg.sender, item.creator, item.price);
        }

    function cancelOffer(address tokenAddress, uint256 tokenId)
        external {
            OfferItem storage item = offerItems[tokenAddress][tokenId][msg.sender];
            require(item.isCancel == false, "Already cancel");
            item.isCancel = true;

            payable(msg.sender).transfer(item.price);
            emit OfferCancel(tokenAddress, tokenId, msg.sender);
        }

    function withdrawETH(uint256 amount) external onlyOwner {
        uint256 ethAmount = address(this).balance;
        require(ethAmount >= amount, "Insufficient amount");
        payable(msg.sender).transfer(amount);
    }

    // Withdraw ERC20 tokens
    // For unusual case, if customers sent their any ERC20 tokens into marketplace, we need to send it back to them
    function withdrawTokens(address _token, uint256 _amount) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "Wrong amount");

        IERC20(_token).transfer(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// This is for other NFT contract
interface IOERC721{
    function tokenURI(uint256 tokenId) external view returns (string memory);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);
}