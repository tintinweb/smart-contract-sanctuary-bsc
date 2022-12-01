// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Percentages {
    // Get value of a percent of a number
    function calcPortionFromBasisPoints(uint _amount, uint _basisPoints) public pure returns(uint) {
        if(_basisPoints == 0 || _amount == 0) {
            return 0;
        } else {
            uint _portion = _amount * _basisPoints / 10000;
            return _portion;
        }
    }

    // Get basis points (percentage) of _portion relative to _amount
    function calcBasisPoints(uint _amount, uint  _portion) public pure returns(uint) {
        if(_portion == 0 || _amount == 0) {
            return 0;
        } else {
            uint _basisPoints = (_portion * 10000) / _amount;
            return _basisPoints;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/*
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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
     * by making the `nonReentrant` function external, and make it call a
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

/*
 *  Oblivion :: NFT Market Interfaces
 *
 *  This contract defines the interfaces that the NFT market contract uses to interface with other contracts.
 *  Some of these are abridged versions of standard interfaces in order to save contract size.
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

import "./NftMarketObjects.sol";

/*
 *  Interface for interacting with an ERC721 NFT
 */
interface INft {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function owner() external view returns (address);
}

/*
 *  Interface for interacting with an ERC1155 NFT
 */
interface INft1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function mint(address _to, uint256 _id, uint256 _amount, bytes memory _data) external;
}

/*
 *  Interface for interacting with a BEP20 token
 */
interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/*
 *  Interface for interacting with a PCS compatible DEX router
 */
interface IDexRouter {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}

/*
 *  Interface for interacting with the rebates contract
 */
interface IRebates {
    function addUserRebate(address _user, uint _amount) external;
}

/*
 *  Interface for interacting with the discounts contract
 */
interface IDiscount {
    function isApplicable(address _user) external view returns (bool);
}

/*
 *  Interface for interacting with the collection contract
 */
interface ICollection {
    function nftInfo(address _nft) external view returns (NftCollectionInfo memory);
    function getCollection(uint _id) external view returns (Collection memory);    
}

/*
 *  Oblivion :: NFT Market Objects
 *
 *  This file contains objects that are used between multiple market contracts.
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

// This struct holds the details of a NFT collection
struct Collection {
    address[] nfts;                 // Array of addressed for the NFTs that belong to this collection
    address owner;                  // The address of the owner of the collection
    address treasury;               // The address that the royalty payments should be sent to
    uint royalties;                 // The percentage of royalties that should be collected
    uint createBlock;               // The block that the collection was created
}

// This struct is used to reference an NFT address to the collection it belongs to
struct NftCollectionInfo {
    uint collectionId;              // The ID of the collection this NFT belongs to
    uint index;                     // The index of the collection array where this NFT is
    bool inCollection;              // Flag tracking if this NFT is part of a collection
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./NftMarketInterfaces.sol";
import "../includes/access/Ownable.sol";
import "../includes/libraries/Percentages.sol";
import "../includes/utils/ReentrancyGuard.sol";
import "../includes/token/BEP20/IBEP20.sol";

contract OblivionMintingService1155 is Ownable, ReentrancyGuard {
    using Percentages for uint256;

    struct MintListing {
        address owner;
        address nft;     
        uint256 tokenId;
        address paymentToken;
        uint256 price;
        uint256 sales;
        uint256 maxSales;
        uint256 endDate;
        uint256 maxQuantity;
        uint256 discount;
        bool whitelisted;
        bool ended;
        address[] treasuryAddresses;
        uint256[] treasuryAllocations;
    }

    address payable treasury;
    uint256 public tax;

    MintListing[] public listings;
    mapping(address => uint256) public discounts;
    mapping(address => address) public nftModerators;
    mapping(address => bool) public paymentTokens;
    mapping(uint256 => mapping(address => bool)) whitelists;
    mapping(address => bool) nftListed;
    mapping(address => uint256) nftListingId;
    mapping(address => uint256[]) userListings;

    event SetNftModerator(address nft, address moderator);
    event SetListingWhitelist(uint256 id, address wallet, bool whitelisted);
    event SetListingWhitelists(uint256 id, uint256 count, bool whitelisted);
    event CreateListing(uint256 id, address nft, address paymentToken, uint256 price, uint256 maxSales, uint256 maxQuantity, bool whitelisted);
    event UpdateListing(uint256 id, address paymentToken, uint256 price, uint256 maxSales, uint256 maxQuantity, bool whitelisted);
    event MultiNftPurchases(uint256 id, address buyer, uint256 quantity);

    constructor (address _treasury, uint256 _tax) {
        treasury = payable(_treasury);
        tax = _tax;
    }

    function totalListings() public view returns (uint256) { return listings.length; }
    function isWhitelisted(uint256 _id, address _wallet) public view returns (bool) { return whitelists[_id][_wallet]; }
    function getUserListings(address _user) public view returns (uint256[] memory) { return userListings[_user]; }
    
    function getTreasuryInfo(uint256 _id) public view returns (address[] memory, uint256[] memory) {
        MintListing memory listing = listings[_id];
        return (listing.treasuryAddresses, listing.treasuryAllocations);
    }
    
    function setTreasury(address _treasury) public onlyOwner() {
        treasury = payable(_treasury);
    }

    function setTax(uint256 _tax) public onlyOwner() {
        tax = _tax;
    }

    function setDiscount(address _user, uint256 _discount) public onlyOwner() {
        discounts[_user] = _discount;
    }

    function setListingDiscount(uint256 _id, uint256 _discount) public onlyOwner() {
        require(_id < totalListings(), 'Invalid listing ID');
        listings[_id].discount = _discount;
    }

    function setAllowedPaymentToken(address _token, bool _allowed) public onlyOwner() {
        paymentTokens[_token] = _allowed;
    }

    function recoverNftOwnership(uint256 _id) public {
        MintListing memory listing = listings[_id];
        require(listing.owner == msg.sender, 'Must be listing owner');
        require(listing.ended, 'Listing is still open');
        INft1155 nft = INft1155(listing.nft);
        nft.transferOwnership(msg.sender);
    }

    function setNftModerator(address _nft, address _moderator) public {
        require(msg.sender == INft1155(_nft).owner() || msg.sender == owner(), 'must be owner');
        nftModerators[_nft] = _moderator;
        emit SetNftModerator(_nft, _moderator);
    }

    function endSale(uint256 _id) public {
        require(_id < listings.length, 'invalid listing');
        MintListing storage listing = listings[_id];
        require(msg.sender == listing.owner, 'must be owner');
        require(!listing.ended, 'already ended');
        listing.ended = true;
        nftListed[listing.nft] = false;
    }

    function createListing(address _nft, uint256 _tokenId, address _paymentToken, uint256 _price, uint256 _maxSales, uint256 _endDate, uint256 _maxQuantity, bool _whitelisted, address[] memory _treasuryAddresses, uint256[] memory _treasuryAllocations) public returns (uint256) {
        require(msg.sender == INft1155(_nft).owner() || msg.sender == nftModerators[_nft], 'must be owner');
        require(_validateAllocations(_treasuryAddresses, _treasuryAllocations), 'invalid allocations');
        require(_paymentToken == address(0) || paymentTokens[_paymentToken], 'invalid payment token');
        require(!nftListed[_nft], 'NFT already listed');

        listings.push(MintListing({
            owner: msg.sender,
            nft: _nft,
            tokenId: _tokenId,
            price: _price,
            paymentToken: _paymentToken,
            sales: 0,
            maxSales: _maxSales,
            endDate: _endDate,
            maxQuantity: _maxQuantity,
            whitelisted: _whitelisted,
            discount: 0,
            ended: false,
            treasuryAddresses: _treasuryAddresses,
            treasuryAllocations: _treasuryAllocations
        }));

        uint256 id = listings.length - 1;

        nftListed[_nft] = true;
        nftListingId[_nft] = id;

        userListings[msg.sender].push(id);

        emit CreateListing(id, _nft, _paymentToken, _price, _maxSales, _maxQuantity, _whitelisted);
        return id;
    }

    function updateListing(uint256 _id, address _paymentToken, uint256 _price, uint256 _maxSales, uint256 _endDate, uint256 _maxQuantity, bool _whitelisted, address[] memory _treasuryAddresses, uint256[] memory _treasuryAllocations) public {
        require(_id < listings.length, 'invalid listing');
        MintListing storage listing = listings[_id];
        require(msg.sender == listing.owner, 'must be owner');
        require(_validateAllocations(_treasuryAddresses, _treasuryAllocations), 'invalid allocations');
        require(_paymentToken == address(0) || paymentTokens[_paymentToken], 'invalid payment token');
        listing.price = _price;
        listing.paymentToken = _paymentToken;
        listing.maxSales = _maxSales;
        listing.treasuryAddresses = _treasuryAddresses;
        listing.treasuryAllocations = _treasuryAllocations;
        listing.endDate = _endDate;
        listing.whitelisted = _whitelisted;
        listing.maxQuantity = _maxQuantity;
        emit UpdateListing(_id, _paymentToken, _price, _maxSales, _maxQuantity, _whitelisted);
    }

    function setWhitelistAddress(uint256 _id, address _wallet, bool _whitelisted) public {
        require(_id < listings.length, 'invalid listing');
        require(msg.sender == listings[_id].owner, 'must be owner');
        whitelists[_id][_wallet] = _whitelisted;
        emit SetListingWhitelist(_id, _wallet, _whitelisted);
    }

    function setWhitelistAddresses(uint256 _id, address[] memory _wallets, bool _whitelisted) public {
        require(_id < listings.length, 'invalid listing');
        require(msg.sender == listings[_id].owner, 'must be owner');
        for (uint256 i = 0; i < _wallets.length; i++) whitelists[_id][_wallets[i]] = _whitelisted;
        emit SetListingWhitelists(_id, _wallets.length, _whitelisted);
    }

    function mintMultiBnb(uint256 _id, uint256 _quantity) public payable nonReentrant() {
        require(_id < listings.length, 'invalid listing');
        _checkListing(_id, true, _quantity);
        MintListing storage listing = listings[_id];
        uint256 total = listing.price * _quantity;

        require(msg.value == total, 'incorrect BNB sent');
        require(listing.maxQuantity == 0 || _quantity <= listing.maxQuantity, 'maximum quantity per sale exceeded');

        uint256 taxes = _getTaxes(_id, total);
        uint256 remaining = total - taxes;
        uint256[] memory allocations = _getAllocations(remaining, listing.treasuryAllocations);

        if (taxes > 0) _safeTransfer(treasury, taxes);
        for (uint256 i = 0; i < listing.treasuryAddresses.length; i++)
            _safeTransfer(listing.treasuryAddresses[i], allocations[i]);

        listing.sales += _quantity;
        INft1155(listing.nft).mint(msg.sender, listing.tokenId, _quantity, "");

        emit MultiNftPurchases(_id, msg.sender, _quantity);
    }

    function mintMultiBep20(uint256 _id, uint256 _quantity) public nonReentrant() {
        require(_id < listings.length, 'invalid listing');
        _checkListing(_id, false, _quantity);
        MintListing storage listing = listings[_id];
        uint256 total = listing.price * _quantity;

        require(listing.maxQuantity == 0 || _quantity <= listing.maxQuantity, 'maximum quantity per sale exceeded');
        uint256 taxes = _getTaxes(_id, total);
        uint256 remaining = total - taxes;
        uint256[] memory allocations = _getAllocations(remaining, listing.treasuryAllocations);

        IBEP20 token = IBEP20(listing.paymentToken);

        if (taxes > 0) token.transferFrom(msg.sender, treasury, taxes);
        for (uint256 i = 0; i < listing.treasuryAddresses.length; i++)
            token.transferFrom(msg.sender, listing.treasuryAddresses[i], allocations[i]);

        listing.sales += _quantity;

        INft1155(listing.nft).mint(msg.sender, listing.tokenId, _quantity, "");

        emit MultiNftPurchases(_id, msg.sender, _quantity);
    }

    function _getTaxes(uint256 _id, uint256 _amount) private view returns (uint256) {
        MintListing memory listing = listings[_id];
        uint256 taxes = _amount.calcPortionFromBasisPoints(tax);
        
        if (discounts[listing.owner] == 0 && listing.discount == 0) return taxes;

        uint256 discount;

        if (listing.discount > 0) discount = listing.discount;
        else discount = discounts[listing.owner];
        
        if (discount >= 10000) taxes = 0;
        else {
            uint256 savings = taxes.calcPortionFromBasisPoints(discount);
            taxes -= savings;
        }

        return taxes;
    }

    function _getAllocations(uint256 _amount, uint256[] memory _allocations) private pure returns (uint256[] memory) {
        uint256 leftOver = _amount;
        uint256[] memory allocations = new uint256[](_allocations.length);

        if (_allocations.length == 1) allocations[0] = _amount;
        else {
            for (uint256 i = 0; i < _allocations.length; i++) {
                if (i == _allocations.length - 1) allocations[i] = leftOver;
                else {
                    allocations[i] = _amount.calcPortionFromBasisPoints(_allocations[i]);                    
                    leftOver -= allocations[i];                    
                }
            }
        }
        return allocations;
    }

    function _checkListing(uint256 _id, bool _isBnb, uint256 _quantity) private view {
        MintListing memory listing = listings[_id];
        require(listing.maxSales == 0 || listing.sales + _quantity <= listing.maxSales, 'maximum sales reached');
        require(_isBnb && listing.paymentToken == address(0) || !_isBnb && listing.paymentToken != address(0), 'incorrect payment type');
        require(!listing.ended && (listing.endDate == 0 || block.timestamp < listing.endDate), 'sale has ended');
        require(!listing.whitelisted || whitelists[_id][msg.sender], 'must be whitelisted');
    }

    function _validateAllocations(address[] memory _addresses, uint256[] memory _allocations) private pure returns (bool) {
        if (_addresses.length != _allocations.length) return false;
        if (_allocations.length == 0) return false;
        uint256 totalAllocations;
        for (uint256 i = 0; i < _allocations.length; i++) totalAllocations += _allocations[i];
        return totalAllocations == 10000;
    }

    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success,) = _recipient.call{value : _amount}("");
        require(_success, "transfer failed");
    }
}