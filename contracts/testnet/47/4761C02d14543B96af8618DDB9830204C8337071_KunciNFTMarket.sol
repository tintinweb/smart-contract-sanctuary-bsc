// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @author Hermanto Tan
 * @author Riyan Firdaus Amerta
 * @notice Smart contract to handle secondary market of kunciNFT
 */
contract KunciNFTMarket is Ownable, ReentrancyGuard, Pausable, ERC1155Holder {

    struct Market {
        address seller;
        uint48 endTime;
        address lastBidder;
        bool isAvailable;
        ListingType listingType; //1=single, 2=bundle
        SaleType saleType; //1=fixed price, 2=timed auction
        uint256 price;
        uint256[] nftIds;
    }

    enum ListingType{
        NONE,
        SINGLE,
        BUNDLE
    }

    enum SaleType {
        NONE,
        FIXED,
        AUCTION
    }
    

    IERC20 public immutable kunciToken;
    IERC1155 public immutable collection;
    
    string public collectionName;
    uint256 public collectionId;
    
    address public platformFeeAddress;
    address public artist;

    uint256 public platformFee; //10000 = 100%
    uint256 public artistCommission; //10000 = 100%

    uint256 public listingIndex;

    mapping(uint256 => Market) public markets;

    event FeeUpdated(
        uint256 platformFee_, 
        uint256 artistCommission_, 
        address indexed platformFeeAddress_, 
        address indexed artist_
    );

    event Purchase(
        address indexed previousOwner, 
        address indexed newOwner, 
        uint256 price, 
        uint256 listingID
    );

    event Bid(
        address indexed previousBidder, 
        address indexed newOwner, 
        uint256 price, 
        uint256 listingID
    );

    event PriceUpdate(
        address indexed owner, 
        uint256 oldPrice, 
        uint256 newPrice, 
        uint256 listingID
    );

    event Listing(
        address indexed owner, 
        uint256 indexed listingID
    );

    event CancelListing(
        address indexed owner, 
        uint256 indexed listingID
    );

    constructor(
        uint256 _collectionId, 
        string memory _collectionName, 
        address _collectionAddress,
        address _kunciAddress,
        address _artist,
        address _platform,
        uint256 _platFee,
        uint256 _artistFee
    ) 
    {
        collectionId = _collectionId;
        collectionName = _collectionName;
        collection = IERC1155(_collectionAddress);
        kunciToken = IERC20(_kunciAddress);
        setFeeDetails(
            _platFee,
            _artistFee,
            _platform,
            _artist
        );
    }

// OWNER FUNCTIONS
    function setFeeDetails(
        uint256 _platformFee, 
        uint256 _artistCommission, 
        address _platformFeeAddress, 
        address _artist
    ) public onlyOwner {
        require(_platformFee + _artistCommission <  10_000, "Invalid fee amount");

        platformFee = _platformFee;
        artistCommission = _artistCommission;

        platformFeeAddress = _platformFeeAddress;
        artist = _artist;

        emit FeeUpdated(_platformFee, _artistCommission, _platformFeeAddress, _artist);
    }

    function settleBid(uint256 _listingId) external onlyOwner {
        Market storage mar = markets[_listingId];

        require(mar.saleType == SaleType.AUCTION, "Listing is not auction");
        require(mar.endTime < block.timestamp, "Auction isn't ended");

        delete mar.isAvailable;

        //send nft to buyer
        sendNFT(_listingId);
        //send fund to seller
        sendFund(_listingId);
    }

    /// @notice in case of funds stuck
    function withdrawKunci() external onlyOwner {
        kunciToken.transfer(msg.sender, kunciToken.balanceOf(address(this)));
    }

    //in case of kunci stuck
    function accessCollection() public onlyOwner {
        collection.setApprovalForAll(msg.sender, true);
    }

// PUBLIC FUNCTIONS

    /// @notice Buy NFT with fixed price
    function buy(uint256 _listingId) external nonReentrant whenNotPaused {
        Market storage mar = markets[_listingId];

        require(mar.isAvailable, "Listing is unavailable");
        require(mar.saleType == SaleType.FIXED, "Listing doesn't support direct buy");
        
        uint256 _amount = mar.price;

        uint256 _artistCommissionAmount = _amount * artistCommission / 10_000;
        uint256 _platformFeeAmount = _amount * platformFee / 10_000;
        uint256 _userAmount = _amount - _artistCommissionAmount - _platformFeeAmount;

        address _seller = mar.seller;
        delete mar.isAvailable;

        kunciToken.transferFrom(msg.sender, artist, _artistCommissionAmount);
        kunciToken.transferFrom(msg.sender, platformFeeAddress, _platformFeeAmount);
        kunciToken.transferFrom(msg.sender, _seller, _userAmount);

        //send nft to buyer
        for (uint256 i; i < mar.nftIds.length;) {
            collection.safeTransferFrom(address(this), msg.sender, mar.nftIds[i], 1, '');

            unchecked{++i;}
        }

        emit Purchase(_seller, msg.sender, _amount, _listingId);
    }

    function bid(uint256 _listingId, uint256 _amount) external nonReentrant whenNotPaused {
        Market storage mar = markets[_listingId];

        require(mar.isAvailable, "Listing is no longer available");
        require(mar.saleType == SaleType.AUCTION, "Listing doesn't support bid");
        require(mar.endTime > block.timestamp, "Sale has ended");
        require(_amount > mar.price, "Wrong amount");

        mar.price = _amount;
        address _previousBidder = mar.lastBidder;
        mar.lastBidder = msg.sender;

        emit Bid(_previousBidder, msg.sender, _amount, _listingId);
    }

    /// @notice Close auction early by seller
    function acceptBid(uint256 _listingId) external nonReentrant {
        Market storage mar = markets[_listingId];

        require(mar.isAvailable, "Listing is no longer available");
        require(mar.saleType == SaleType.AUCTION, "Listing doesn't support bid");
        require(mar.seller == msg.sender, "Not seller");
        

        delete mar.isAvailable;

        sendNFT(_listingId);

        sendFund(_listingId);

    }

    /// @notice claim the NFT by the winner
    function claimBidNft(uint256 _listingId) external nonReentrant {
        Market storage mar = markets[_listingId];

        require(mar.saleType == SaleType.AUCTION, "Listing doesn't support bid");
        require(mar.lastBidder == msg.sender, "You are not the winner");
        require(mar.endTime > block.timestamp, "Sale has ended");

        delete mar.isAvailable;

        //send nft to buyer
        address _winner = mar.lastBidder;
        for (uint256 i; i < mar.nftIds.length;) {
            collection.safeTransferFrom(address(this), _winner, mar.nftIds[i], 1, '');

            unchecked{++i;}
        }

    }

    function claimBidFund(uint256 _listingId) external nonReentrant {
        Market storage mar = markets[_listingId];

        require(mar.saleType == SaleType.AUCTION, "Listing doesn't support bid");
        require(msg.sender == mar.seller, "You are not owner");

        delete mar.isAvailable;

        //send fund to seller
        sendFund(_listingId);

    }

    /// @notice Send kunci from this contract
    function sendFund(uint256 _listingId) private {
        Market storage mar = markets[_listingId];

        uint256 _amount = mar.price;

        uint256 _artistCommissionAmount = _amount * artistCommission / 10_000;
        uint256 _platformFeeAmount = _amount * platformFee / 10_000;
        uint256 _userAmount = _amount - _artistCommissionAmount - _platformFeeAmount;

        kunciToken.transfer(artist, _artistCommissionAmount);
        kunciToken.transfer(platformFeeAddress, _platformFeeAmount);
        kunciToken.transfer(mar.seller, _userAmount);
    }

    function sendNFT(uint256 _listingId) private {
        Market storage mar = markets[_listingId];

        address _winner = mar.lastBidder;
        require(_winner != address(0), "No bidder");

        for (uint256 i; i < mar.nftIds.length;) {
            collection.safeTransferFrom(address(this), _winner, mar.nftIds[i], 1, '');

            unchecked{++i;}
        }

    }

    function updatePrice(uint256 _listingId, uint256 _price) external {
        Market storage mar = markets[_listingId];

        require(mar.lastBidder == address(0), "NFT sold or in auction");
        uint256 _oldPrice = mar.price;
        require(msg.sender == mar.seller, "You aren't the owner");
        mar.price = _price;

        emit PriceUpdate(msg.sender, _oldPrice, _price, _listingId);
    }

    function list (
        uint256 _price,
        ListingType _listingType,
        SaleType _saleType,
        uint48 _endTime,
        uint256[] calldata _nftIds
    ) external nonReentrant whenNotPaused {
        require(_nftIds.length <= 5, "Bundle can't include more than 5 nft");
        require(_saleType != SaleType.NONE , "Invalid sale type");
        require(_endTime > block.timestamp, "End time cannot be a time in the past");

        if (_listingType == ListingType.SINGLE)
            require(_nftIds.length == 1, "Single listing can only list 1 item");

        else if (_listingType == ListingType.BUNDLE)
            require(_nftIds.length > 1, "Bundle listing must have more than 1 item");

        else {
            revert( "Invalid listing type");
        }

        uint256[] memory _nftQuantities = new uint256[](_nftIds.length);
        for (uint256 i; i < _nftIds.length; i++) {
            _nftQuantities[i] = 1;
        }

        collection.safeBatchTransferFrom(msg.sender, address(this), _nftIds, _nftQuantities, '');

        uint256 _currentIndex = ++listingIndex;

        Market storage mar = markets[_currentIndex];

        mar.seller = msg.sender;
        mar.endTime = _endTime;
        mar.isAvailable = true;
        mar.listingType = _listingType;
        mar.saleType = _saleType;
        mar.price = _price;
        mar.nftIds = _nftIds;
        
        emit Listing(msg.sender, _currentIndex);
    }

    function cancelList(uint256 _listingId) external nonReentrant {
        Market storage mar = markets[_listingId];

        require(msg.sender == mar.seller, "Not the owner of this listing");
        require(mar.lastBidder == address(0), "Listing already has bidder");

        delete mar.isAvailable;

        uint256 _length = mar.nftIds.length;
        for (uint256 i; i < _length;) {
            collection.safeTransferFrom(address(this), msg.sender, mar.nftIds[i], 1, '');

            unchecked{++i;}
        }

        emit CancelListing(msg.sender, _listingId);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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