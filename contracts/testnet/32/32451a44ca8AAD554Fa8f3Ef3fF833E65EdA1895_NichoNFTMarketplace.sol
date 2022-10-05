/**
 * Submitted for verification at BscScan.com on 2022-09-29
 */

// File: contracts/NichoNFTMarketplace.sol
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

// Openzeppelin libraries
import "@openzeppelin/contracts/access/Ownable.sol";

import "./MarketplaceHelper.sol";
import "./interfaces/INichoNFTAuction.sol";
import "./interfaces/INichoNFTRewards.sol";

// NichoNFT marketplace
contract NichoNFTMarketplace is Ownable, MarketplaceHelper {
    // Interface for nichonft auction
    INichoNFTAuction public nichonftAuctionContract;
    // Interface from the reward contract
    INichoNFTRewards public nichonftRewardsContract;

    // Enable if nichonftauction exists
    bool public auctionEnabled = false;
    // Trade rewards enable
    bool public tradeRewardsEnable = false;
    // Factory address
    address public factory;

    // Offer Item
    struct OfferItem {
        uint256 price;
        uint256 expireTs;
        bool isLive;
    }

    // Marketplace Listed Item
    // token address => tokenId => item
    mapping(address => mapping(uint256 => Item)) private items;

    // Offer Item
    // token address => token id => creator => offer item
    mapping(address => mapping(uint256 => mapping(address => OfferItem))) private offerItems;

    // NichoNFT and other created owned-collections need to list it while minting.
    // nft contract address => tokenId => item
    mapping(address => bool) public directListable;

    /**
     * @dev Emitted when `token owner` list/mint/auction NFT on marketplace
     * - expire_at: in case of auction sale
     * - auction_id: in case of auction sale
     */
    event ListedNFT(
        address token_address,
        uint token_id,
        address indexed creator,
        uint price,
        uint expire_at, 
        uint80 auction_id,
        string collection_id
    );

    /**
     * @dev Emitted when `token owner` cancel NFT from marketplace
     */
    event ListCancel(
        address token_address,
        uint token_id,
        address indexed owner,
        bool is_listed
    );

    /**
     * @dev Emitted when create offer for NFT on marketplace
     */
    event Offers(
        address token_address,
        uint token_id,
        address indexed creator,
        uint price,
        uint expire_at
    );

    /**
     * @dev Emitted when `Offer creator` cancel offer of NFT on marketplace
     */
    event OfferCancels(
        address token_address,
        uint token_id,
        address indexed creator
    );

    /**
     * @dev Emitted when `token owner` list NFT on marketplace
     */
    event TradeActivity(
        address token_address,
        uint token_id,
        address indexed previous_owner,
        address indexed new_owner,
        uint price
    );

    // Initialize configurations
    constructor(
        address _blacklist,
        address _nichonft
    ) MarketplaceHelper(_blacklist) {
        directListable[_nichonft] = true;
    }

    /**
     * @dev set Factory address for owned collection
     */
    function setFactoryAddress(address _factory) external onlyOwner {
        require(_factory != address(0x0), "Invalid address");
        require(_factory != factory, "Same Factory Address");
        factory = _factory;
    }

    /**
     * @dev set direct listable contract
     */
    function setDirectListable(address _target) external {
        require(
            msg.sender == factory || msg.sender == owner(),
            "You have no right to call setDirectListable"
        );
        directListable[_target] = true;
    }
    /**
     * @dev If you need auction sales, you can enable auction contract
     */
    function enableNichoNFTAuction(INichoNFTAuction _nichonftAuctionContract) external onlyOwner {
        nichonftAuctionContract = _nichonftAuctionContract;
        auctionEnabled = true;
    }

    function disableAuction() external onlyOwner {
        auctionEnabled = false;
    }

    /**
     * @dev trade to reward contract
     */
    function setRewardsContract(
        INichoNFTRewards _nichonftRewardsContract
    ) external onlyOwner {
        require(nichonftRewardsContract != _nichonftRewardsContract, "Rewards: has been already configured");
        nichonftRewardsContract = _nichonftRewardsContract;
    }

    function setTradeRewardsEnable(bool _tradeRewardsEnable) external onlyOwner {
        require(tradeRewardsEnable != _tradeRewardsEnable, "Already set enabled");
        tradeRewardsEnable = _tradeRewardsEnable;
    }

    // Middleware to check if NFT is already listed on not.
    modifier onlyListed(address tokenAddress, uint256 tokenId) {
        Item memory item = items[tokenAddress][tokenId];
        require(item.isListed == true, "Token: not listed on marketplace");

        address tokenOwner = IERC721(tokenAddress).ownerOf(tokenId);
        require(item.creator == tokenOwner, "You are not creator");
        _;
    }

    // Middleware to check if NFT is already listed on not.
    modifier onlyListableContract() {
        require(
            directListable[msg.sender] == true,
            "Listable: not allowed to list"
        );
        _;
    }

    // List NFTs on marketplace as same price with fixed price sale
    function batchListItemToMarket(
        address[] calldata tokenAddress,
        uint256[] calldata tokenId,
        uint256 askingPrice
    ) external notPaused {
        require(
            tokenAddress.length == tokenId.length,
            "Array size does not match"
        );

        for (uint idx = 0; idx < tokenAddress.length; idx++) {
            address _tokenAddress = tokenAddress[idx];
            uint _tokenId = tokenId[idx];

            // List
            listItemToMarket(_tokenAddress, _tokenId, askingPrice);
        }
    }

    // List an NFT on marketplace as same price with fixed price sale
    function listItemToMarket(
        address tokenAddress,
        uint256 tokenId,
        uint256 askingPrice
    )
        public
        notBlackList(tokenAddress, tokenId)
        onlyTokenOwner(tokenAddress, tokenId)
        notPaused
    {
        address _tokenAddress = tokenAddress;
        uint256 _tokenId = tokenId;

        // Token owner need to approve NFT on Token Contract first so that Listing works.
        require(checkApproval(_tokenAddress, _tokenId), "First, Approve NFT");

        Item storage item = items[_tokenAddress][_tokenId];
        item.price = askingPrice;
        item.isListed = true;
        // creator
        item.creator = msg.sender;

        // cancel auction
        if (auctionEnabled) {
            nichonftAuctionContract.cancelAuctionFromFixedSaleCreation(_tokenAddress, _tokenId);
        }

        emit ListedNFT(_tokenAddress, _tokenId, msg.sender, askingPrice, 0, 0, "");
    }

    // List an NFT/NFTs on marketplace as same price with fixed price sale
    function listItemToMarketFromMint(
        address tokenAddress,
        uint256 tokenId,
        uint256 askingPrice,
        address _creator,
        string memory cId
    ) external onlyListableContract {
        Item storage item = items[tokenAddress][tokenId];
        item.price = askingPrice;
        item.isListed = true;

        // creator
        item.creator = _creator;

        emit ListedNFT(tokenAddress, tokenId, _creator, askingPrice, 0, 0, cId);
    }

    // Cancel nft listing
    function cancelListing(
        address tokenAddress,
        uint tokenId
    )   external
        onlyTokenOwner(tokenAddress, tokenId)
    {
        // scope for _token{Id, Address}, price, avoids stack too deep errors
        uint _tokenId = tokenId;
        address _tokenAddress = tokenAddress;

        if (items[_tokenAddress][_tokenId].isListed) {
            Item storage item = items[_tokenAddress][_tokenId];
            item.isListed = false;
            item.price = 0;
        }

        if (auctionEnabled) {
            if (nichonftAuctionContract.getAuctionStatus(_tokenAddress, _tokenId) == true) {            
                // cancel auction
                nichonftAuctionContract.cancelAuctionFromFixedSaleCreation(_tokenAddress, _tokenId);
            }
        }

        emit ListCancel(_tokenAddress, _tokenId, msg.sender, false);
    }

    /**
     * @dev Purchase the listed NFT with BNB.
     */
    function buy(address tokenAddress, uint tokenId)
        external
        payable
        notBlackList(tokenAddress, tokenId)
        onlyListed(tokenAddress, tokenId)        
    {
        _validate(tokenAddress, tokenId, msg.value);

        IERC721 tokenContract = IERC721(tokenAddress);
        address _previousOwner = tokenContract.ownerOf(tokenId);
        address _newOwner = msg.sender;

        _trade(tokenAddress, tokenId, msg.value);

        setTradeRewards(tokenAddress, tokenId, _newOwner, block.timestamp);

        emit TradeActivity(
            tokenAddress,
            tokenId,
            _previousOwner,
            _newOwner,
            msg.value
        );
    }

    /**
     * @dev Check validation for Trading conditions
     *
     * Requirement:
     *
     * - `amount` is token amount, should be greater than equal seller price
     */
    function _validate(
        address tokenAddress,
        uint tokenId,
        uint256 amount
    ) private view {
        require(
            checkApproval(tokenAddress, tokenId),
            "Not approved from owner."
        );

        IERC721 tokenContract = IERC721(tokenAddress);
        require(
            tokenContract.ownerOf(tokenId) != msg.sender,
            "Token owner can not buy your NFTs."
        );

        Item memory item = items[tokenAddress][tokenId];
        require(amount >= item.price, "Error, the amount is lower than price");
    }

    /**
     * @dev Execute Trading once condition meets.
     *
     * Requirement:
     *
     * - `amount` is token amount, should be greater than equal seller price
     */
    function _trade(
        address tokenAddress,
        uint tokenId,
        uint amount
    ) internal notPaused {
        IERC721 tokenContract = IERC721(tokenAddress);

        address payable _buyer = payable(msg.sender);
        address _seller = tokenContract.ownerOf(tokenId);

        Item storage item = items[tokenAddress][tokenId];
        uint price = item.price;
        uint remainAmount = amount - price;

        // From marketplace contract to seller
        payable(_seller).transfer(price);

        // If buyer sent more than price, we send them back their rest of funds
        if (remainAmount > 0) {
            _buyer.transfer(remainAmount);
        }

        // Transfer NFT from seller to buyer
        tokenContract.safeTransferFrom(_seller, msg.sender, tokenId);

        // Update Item
        item.isListed = false;
        item.price = 0;
    }

    // Create offer with BNB
    function createOffer(
        address tokenAddress,
        uint256 tokenId,
        uint256 deadline // count in seconds
    ) external payable {
        _createOffer(
            tokenAddress,
            tokenId,
            deadline, // count in seconds
            msg.value
        );
    }

    // Create offer logic
    function _createOffer(
        address tokenAddress,
        uint256 tokenId,
        uint256 deadline,
        uint256 amount
    ) private notPaused {
        require(amount > 0, "Invalid amount");
        // 30 seconds
        require(deadline >= 5, "Invalid deadline");
        IERC721 nft = IERC721(tokenAddress);
        require(
            nft.ownerOf(tokenId) != msg.sender,
            "Owner cannot create offer"
        );

        OfferItem storage item = offerItems[tokenAddress][tokenId][msg.sender];
        require(
            item.price == 0 || item.isLive == false,
            "You've already created offer"
        );

        uint expireAt = block.timestamp + deadline;

        item.price = amount;
        item.expireTs = expireAt;
        item.isLive = true;

        emit Offers(
            tokenAddress,
            tokenId,
            msg.sender,
            amount,
            expireAt
        );
    }

    /**
     * @dev NFT owner accept the offer created by buyer
     * Requirement:
     * - offerCreator: creator address that have created offer.
     */
    function acceptOffer(
        address tokenAddress,
        uint256 tokenId,
        address offerCreator
    )
        external
        notBlackList(tokenAddress, tokenId)
        onlyTokenOwner(tokenAddress, tokenId)
    {
        OfferItem memory item = offerItems[tokenAddress][tokenId][offerCreator];
        require(item.isLive, "Offer creator withdrawed");
        require(item.expireTs >= block.timestamp, "Offer already expired");
        require(checkApproval(tokenAddress, tokenId), "First, approve NFT");

        IERC721(tokenAddress).safeTransferFrom(
            msg.sender,
            offerCreator,
            tokenId
        );

        uint oldPrice = item.price;
        OfferItem memory itemStorage = offerItems[tokenAddress][tokenId][
            offerCreator
        ];

        itemStorage.isLive = false;
        itemStorage.price = 0;

        payable(msg.sender).transfer(item.price);

        Item storage marketItem = items[tokenAddress][tokenId];

        // Update Item
        marketItem.isListed = false;
        marketItem.price = 0;
        // emit OfferSoldOut(tokenAddress, tokenId, msg.sender, item.creator, item.price);

        setTradeRewards(tokenAddress, tokenId, msg.sender, block.timestamp);


        emit TradeActivity(
            tokenAddress,
            tokenId,
            offerCreator,
            msg.sender,
            oldPrice
        );
    }

    /**
     * @dev Offer creator cancel offer
     */
    function cancelOffer(address tokenAddress, uint256 tokenId) external {
        require(
            offerItems[tokenAddress][tokenId][msg.sender].isLive,
            "Already withdrawed"
        );
        OfferItem storage item = offerItems[tokenAddress][tokenId][msg.sender];

        uint oldPrice = item.price;
        item.isLive = false;
        item.price = 0;

        payable(msg.sender).transfer(oldPrice);

        emit OfferCancels(tokenAddress, tokenId, msg.sender);
    }

    //----------- Calls from auction contract ------------
    /**
     * @dev when auction is created, cancel fixed sale
     */
    function cancelListFromAuctionCreation(
        address tokenAddress, uint256 tokenId
    ) external {
        require(msg.sender == address(nichonftAuctionContract), "Invalid nichonft contract");
        Item storage item = items[tokenAddress][tokenId];
        item.isListed = false;
        item.price = 0;
    }

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
    ) external {
        require(
            msg.sender == address(nichonftAuctionContract), 
            "Invalid nichonft contract"
        );
        
        emit ListedNFT(
            _tokenAddress, 
            _tokenId, 
            _creator,
            _startPrice, 
            _expireTs, 
            _nextAuctionId,
            ""
        );
    }

    /**
     * @dev when auction is created, cancel fixed sale
     */
    function emitTradeActivityFromAuctionContract(
        address _tokenAddress, 
        uint256 _tokenId, 
        address _prevOwner, 
        address _newOwner, 
        uint256 _price
    ) external {
        require(
            msg.sender == address(nichonftAuctionContract), 
            "Invalid nichonft contract"
        );

        emit TradeActivity(
            _tokenAddress,
            _tokenId, 
            _prevOwner, 
            _newOwner, 
            _price
        );
        
    }

    /**
     * @dev Get offer created based on NFT (address, id)
     */
    function getOfferItemInfo(
        address tokenAddress,
        uint tokenId,
        address sender
    ) external view returns (OfferItem memory item) {
        item = offerItems[tokenAddress][tokenId][sender];
    }

    // get ItemInfo listed on marketplace
    function getItemInfo(address tokenAddress, uint tokenId)
        external
        view
        returns (Item memory item)
    {
        item = items[tokenAddress][tokenId];
    }

    /**
     * @dev pause market
     */
    function pause(bool _pause) external onlyOwner {
        isPaused = _pause;
    }
    
    // For unusual/emergency case,
    function withdrawETH(uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Wrong amount");

        payable(msg.sender).transfer(_amount);
    }

    function setTradeRewards(address tokenAddress, uint256 tokenId, address userAddress, uint256 timestamp) private returns (bool) {
        if (tradeRewardsEnable) {
            return nichonftRewardsContract.tradeRewards(tokenAddress, tokenId, userAddress, timestamp);
        }
        return false;
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

// Interface for NichoNFTAuction
interface INichoNFTAuction {
    function cancelAuctionFromFixedSaleCreation(
        address tokenAddress, 
        uint tokenId
    ) external;

    function getAuctionStatus(address tokenAddress, uint tokenId)
        external
        view
        returns (bool);
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface INichoNFTRewards {
    
    function mintRewards(address tokenAddress, string memory tokenURI, uint256 tokenId, address userAddress, uint256 price, uint256 timestamp) external returns (bool);

    function tradeRewards(address tokenAddress, uint256 tokenId, address userAddress, uint256 timestamp) external returns (bool);

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