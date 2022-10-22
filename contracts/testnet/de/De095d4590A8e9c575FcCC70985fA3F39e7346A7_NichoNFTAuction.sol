/**
 * Submitted for verification at BscScan.com on 2022-09-29
 */

// File: contracts/NichoNFTAuction.sol
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MarketplaceHelper.sol";
import "./interfaces/INichoNFTMarketplace.sol";
import "./interfaces/ICreatorNFT.sol";
import "./interfaces/IFactory.sol";

contract NichoNFTAuction is Ownable, MarketplaceHelper{
    INichoNFTMarketplace nichonftmarketplaceContract;
    /**
     * @dev Emitted when `buyer` place bid on auction on marketplace
     */
    event AuctionBids(
        address token_address,
        uint token_id,
        address indexed creator,
        uint price,
        uint80 auction_id
    );

    /**
     * @dev Cancel the placed bid
     */
    event BidCancels(
        address token_address,
        uint token_id, 
        address indexed creator,
        uint80 auction_id
    );
    
    // Auction Item
    // token address => token id => auction item
    mapping(address => mapping(uint256 => AuctionItem)) private auctionItems;

    // Bid Item
    // token address => token id => bidder => bid_info
    mapping(address => mapping(uint256 => mapping(address => BidItem))) private bidItems;

    // factory address
    IFactory public factory;
    // Initialize configurations
    constructor(
        address _blacklist,
        INichoNFTMarketplace _nichonftmarketplaceContract,
        IFactory _factory
    ) MarketplaceHelper(_blacklist) {
        nichonftmarketplaceContract = _nichonftmarketplaceContract;
        factory = _factory;
    }

    function setMarketplaceContract(
        INichoNFTMarketplace _nichonftMarketplace
    ) onlyOwner external{
        require(nichonftmarketplaceContract != _nichonftMarketplace, "Marketplace: has been already configured");
        nichonftmarketplaceContract = _nichonftMarketplace;
    }

    /**
     * @dev set Factory address for owned collection
     */
    function setFactoryAddress(IFactory _factory) external onlyOwner {
        require(address(_factory) != address(0x0), "Invalid address");
        require(_factory != factory, "Same Factory Address");
        factory = _factory;
    }

    /**
     * Create auction
     */
    function createAuction(
        address tokenAddress,
        uint256 tokenId,
        uint256 startPrice,
        uint256 duration
    ) external notPaused onlyTokenOwner(tokenAddress, tokenId) notBlackList(tokenAddress, tokenId) {

        address _tokenAddress = tokenAddress;
        uint256 _tokenId = tokenId;
        uint256 _startPrice = startPrice;

        require(duration >= 5, "Auction: too short period");
        require(checkApproval(_tokenAddress, _tokenId), "First, Approve NFT");

        AuctionItem storage auctionItem = auctionItems[_tokenAddress][_tokenId];
        require(
            msg.sender != auctionItem.creator || 
            auctionItem.isLive == false ||
            auctionItem.expireTs <= block.timestamp,
            "Auction: exist"
        );

        uint256 _expireTs = block.timestamp + duration;
        uint80 currentAuctionId = auctionItem.id;
        uint80 nextAuctionId = currentAuctionId + 1;

        auctionItem.id = nextAuctionId;
        auctionItem.highPrice = _startPrice;
        auctionItem.expireTs = _expireTs;
        auctionItem.isLive = true;
        auctionItem.creator = msg.sender;

        // unlist from fixed sale
        nichonftmarketplaceContract.cancelListFromAuctionCreation(
            _tokenAddress, 
            _tokenId
        );
        // emit whenever token owner created auction
         
        nichonftmarketplaceContract.emitListedNFTFromAuctionContract(
            _tokenAddress, 
            _tokenId, 
            msg.sender, 
            _startPrice, 
            _expireTs, 
            nextAuctionId
        );
    }

    /**
     * @dev Place bid on auctions with bnb
     */
    function placeBid(
        address tokenAddress,
        uint256 tokenId
    ) external notPaused payable {
        _placeBid(
            tokenAddress,
            tokenId,
            msg.value
        );
    }

    // Place bid logic
    function _placeBid(
        address tokenAddress,
        uint256 tokenId,
        uint256 price
    ) private notBlackList(tokenAddress, tokenId) {
        address _tokenAddress = tokenAddress;
        uint256 _tokenId = tokenId;
        uint256 _price = price;

        AuctionItem memory auctionItem = auctionItems[_tokenAddress][_tokenId];
        BidItem memory bidItem = bidItems[_tokenAddress][_tokenId][msg.sender];
        

        require(auctionItem.isLive, "PlaceBid: auction does not exist");
        require(msg.sender != IERC721(tokenAddress).ownerOf(tokenId), "Token owner cannot place bid");

        require(bidItem.price == 0, "PlaceBid: cancel previous one");
        require(auctionItem.expireTs >= block.timestamp, "PlaceBid: auction ended");
        require(auctionItem.highPrice < price, "PlaceBid: should be higher price");

        AuctionItem storage _auctionItem = auctionItems[_tokenAddress][_tokenId];
        _auctionItem.highPrice = _price;

        BidItem storage _bidItem = bidItems[_tokenAddress][_tokenId][msg.sender];
        _bidItem.auctionId = auctionItem.id;
        _bidItem.price = _price;

        emit AuctionBids(_tokenAddress, _tokenId, msg.sender, _price, auctionItem.id);
    }

    /**
     * @dev Cancel the placed bid
     */
    function cancelBid(
        address tokenAddress,
        uint256 tokenId
    ) external  {
        address _tokenAddress = tokenAddress;
        uint256 _tokenId = tokenId;
        BidItem memory bidItem = bidItems[_tokenAddress][_tokenId][msg.sender];
        uint256 _price = bidItem.price;
        require(_price > 0, "PlaceBid: not placed yet");

        AuctionItem memory auctionItem = auctionItems[_tokenAddress][_tokenId];
        require(
            auctionItem.id == bidItem.auctionId && auctionItem.expireTs < block.timestamp, 
            "Not able to cancel before ends"
        );

        BidItem storage _bidItem = bidItems[_tokenAddress][_tokenId][msg.sender];
        _bidItem.price = 0;

        payable(msg.sender).transfer(_price);

        emit BidCancels(_tokenAddress, _tokenId, msg.sender, _bidItem.auctionId);
    }


    /**
     * @dev Accept the placed bid
     */
    function acceptBid(
        address tokenAddress,
        uint256 tokenId,
        address bidder
    ) external 
        onlyTokenOwner(tokenAddress, tokenId) 
        notBlackList(tokenAddress, tokenId) 
    {
        address _tokenAddress = tokenAddress;
        uint256 _tokenId = tokenId;
        address _bidder = bidder;

        BidItem memory bidItem = bidItems[_tokenAddress][_tokenId][_bidder];
        require(bidItem.price > 0, "AcceptBid: not placed yet");

        AuctionItem memory auctionItem = auctionItems[_tokenAddress][_tokenId];
        require(auctionItem.isLive, "AcceptBid: auction does not exist");
        require(auctionItem.id == bidItem.auctionId, "AcceptBid: too old bid");
        require(auctionItem.expireTs >= block.timestamp, "PlaceBid: auction ended");


        AuctionItem storage _auctionItem = auctionItems[_tokenAddress][_tokenId];
        _auctionItem.isLive = false;
        
        BidItem storage _bidItem = bidItems[_tokenAddress][_tokenId][_bidder];
        uint _price = _bidItem.price;
        _bidItem.price = 0;

        IERC721(_tokenAddress).transferFrom(msg.sender, _bidder, _tokenId);

        IFactory factoryContract = IFactory(factory);
        if (factoryContract.checkRoyaltyFeeContract(_tokenAddress) == true) {
            uint256 fee = ICreatorNFT(_tokenAddress).getRoyaltyFeePercentage();
            uint256 feeAmount = _price * fee / 1000;
            uint256 transferAmount = _price - feeAmount;
            payable(msg.sender).transfer(transferAmount);
            payable(owner()).transfer(feeAmount);
        } else {
            payable(msg.sender).transfer(_price);
        }

        // when accept auction bid, need to emit TradeActivity
        nichonftmarketplaceContract.emitTradeActivityFromAuctionContract(
            _tokenAddress, _tokenId, msg.sender, _bidder, _price
        );
    }

    // get auction ItemInfo
    function getAuctionItemInfo(address tokenAddress, uint tokenId)
        external
        view
        returns (AuctionItem memory item)
    {
        item = auctionItems[tokenAddress][tokenId];
    }


    function getAuctionStatus(address tokenAddress, uint tokenId)
        external
        view
        returns (bool)
    {
        return auctionItems[tokenAddress][tokenId].isLive;
    }

    // get auction ItemInfo
    function getBidItemInfo(address tokenAddress, uint tokenId, address bidder)
        external
        view
        returns (BidItem memory item)
    {
        item = bidItems[tokenAddress][tokenId][bidder];
    }

    function cancelAuctionFromFixedSaleCreation(
        address tokenAddress, 
        uint tokenId
    ) external {
        require(msg.sender == address(nichonftmarketplaceContract), "Invalid nichonft marketplace contract");
        AuctionItem storage item = auctionItems[tokenAddress][tokenId];
        item.isLive = false;
    }

    // Withdraw ERC20 tokens
    // For unusual case, if customers sent their any ERC20 tokens into marketplace, we need to send it back to them
    function withdrawTokens(address _token, uint256 _amount)
        external
        onlyOwner
    {
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount,
            "Wrong amount"
        );

        IERC20(_token).transfer(msg.sender, _amount);
    }

    // For unusual/emergency case,
    function withdrawETH(uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Wrong amount");

        payable(msg.sender).transfer(_amount);
    }
}

/**
 * Submitted for verification at BscScan.com on 2022-09-28
 */

// File: contracts/MarketplaceHelper.sol
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

// Own interfaces
import "./interfaces/INFTBlackList.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

abstract contract MarketplaceHelper {
    /// NFT marketplace paused or not
    bool public isPaused;

    //-- Interfaces --//
    // Blacklist
    INFTBlackList public blacklistContract;

    // Listed item on marketplace (Fixed sale)
    struct Item {
        address creator;
        bool isListed;
        uint256 price;
    }

    // Auction Item
    struct AuctionItem {
        uint80 id;          // auction id
        address creator;
        uint256 highPrice;  // high price
        uint256 expireTs;
        bool isLive;
    }

    // Bid Item
    struct BidItem {
        uint80 auctionId;
        uint256 price;
    }

    constructor(
        address _blacklist
    ) {
        blacklistContract = INFTBlackList(_blacklist);

        isPaused = false;        
    }

    receive() external payable {}

    modifier notPaused {
        require(isPaused == false, "Paused");
        _;
    }

    // Middleware to check if NFT is in blacklist
    modifier notBlackList(address tokenAddress, uint256 tokenId) {
        require(
            blacklistContract.checkBlackList(tokenAddress, tokenId) == false,
            "This NFT is in blackList"
        );
        _;
    }
    
    // Middleware to check if msg.sender is token owner
    modifier onlyTokenOwner(address tokenAddress, uint256 tokenId) {
        address tokenOwner = IERC721(tokenAddress).ownerOf(tokenId);

        require(
            tokenOwner == msg.sender,
            "Token Owner: you are not a token owner"
        );
        _;
    }

    function setPause(bool _value) external  {
        isPaused = _value;
    }

    function checkApproval(address _tokenAddress, uint _tokenId)
        internal
        view
        returns (bool)
    {
        IERC721 tokenContract = IERC721(_tokenAddress);
        return
            tokenContract.getApproved(_tokenId) == address(this) ||
            tokenContract.isApprovedForAll(
                tokenContract.ownerOf(_tokenId),
                address(this)
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// Interface for ICreatorNFT
interface ICreatorNFT {
    function getRoyaltyFeePercentage() external view returns (uint royalty);
    function owner() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// This is interface for NichoNFT Marketplace contract
interface INichoNFTMarketplace {
    // List an NFT/NFTs on marketplace as same price with fixed price sale
    function listItemToMarketFromMint(
        address tokenAddress, 
        uint256 tokenId, 
        uint256 askingPrice,
        address _creator,
        string memory _id
    ) external;

    /**
     * @dev when auction is created, cancel fixed sale
     */
    function cancelListFromAuctionCreation(
        address tokenAddress, uint256 tokenId
    ) external;

    /**
     * @dev emit whenever token owner created auction
     */
    function emitListedNFTFromAuctionContract(
        address _tokenAddress, 
        uint256 _tokenId, 
        address _creator, 
        uint256 _startPrice,
        uint256 _expireTs, 
        uint80  _nextAuctionId
    ) external;

    /**
     * @dev when accept auction bid, need to emit TradeActivity
     */
    function emitTradeActivityFromAuctionContract(
        address _tokenAddress, 
        uint256 _tokenId, 
        address _prevOwner, 
        address _newOwner, 
        uint256 _price
    ) external;

    /**
     * @dev set direct listable contract
     */
    function setDirectListable(address _target) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// Interface for IFactory
interface IFactory {
    function checkRoyaltyFeeContract(address _contractAddress) external view returns(bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// Interface for NFTBlackList
interface INFTBlackList {
    function checkBlackList(address tokenAddress, uint256 tokenId) external view returns(bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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