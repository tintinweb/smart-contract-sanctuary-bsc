// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Exchange is Ownable, Pausable, ReentrancyGuard {
    uint public constant FEE_PERCENT_DIVISOR = 100;

    // Tokens
    IERC20 public solx;
    IERC20 public busd;

    // Fees
    uint public saleFeePercent = 5;     // 5%
    uint public saleFeeFixed = 5 * 1e18;// 5 SOLX
    uint public buyFeePercent = 5;      // 5%
    uint public buyFeeFixed = 5 * 1e18; // 5 BUSD
    address public feeOwner;

    // Listings
    struct Listing {
        address seller;
        uint solxQuantity;
        uint totalPrice;
        uint createdAt;
        bytes32 key;
    }
    Listing[] public listings;
    mapping(bytes32 => uint16) public listingsKeyToIndex;
    uint public minSolxPrice = 1e18;
    uint public minSolxQuantity = 1e18;

    // Stats
    uint public completedSales;
    uint public totalSalesSolx;
    uint public totalSalesBusd;
    uint public totalSolxFee;
    uint public totalBusdFee;

    event SaleFeeUpdated(uint previous, uint current);
    event SaleFeeFixedUpdated(uint previous, uint current);
    event BuyFeeUpdated(uint previous, uint current);
    event BuyFeeFixedUpdated(uint previous, uint current);
    event FeeOwnerUpdated(address indexed previous, address indexed current);
    event MinPriceUpdated(uint previous, uint current);
    event MinQuantityUpdated(uint previous, uint current);

    event ListingAdded(address indexed seller, uint qty, uint totalPrice, uint fee);
    event ListingRemoved(address indexed seller, uint qty, uint totalPrice);
    event Purchase(address indexed buyer, address seller, uint qty, uint totalPrice, uint fee);

    constructor(address _newOwner, address solxAddr, address busdAddr) {
        require(_newOwner != address(0), "Zero address not allowed for owner");
        transferOwnership(_newOwner);
        feeOwner = _newOwner;

        solx = IERC20(solxAddr);
        busd = IERC20(busdAddr);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function getListingsByRange(uint start, uint stop) public view returns (Listing[] memory) {
        require(stop >= start, "start cannot be higher than stop");

        if (stop > listings.length) {
            stop = listings.length;
        }

        uint256 _count = stop - start;
        Listing[] memory result = new Listing[](_count);
        for (uint i = 0; i < _count; i++) {
            result[i] = listings[start + i];
        }
        return result;
    }

    function listingsCount() external view returns (uint) {
        return listings.length;
    }

    // Create a new listing
    function createListing(uint qty, uint totalPrice) external whenNotPaused {
        require(qty > 0 && qty >= minSolxQuantity, "SOLX quantity less than minimum");
        require(totalPrice >= qty * minSolxPrice / 1e18, "Price below minimum");

        address seller = _msgSender();
        uint saleFee = calculateFee(qty, saleFeePercent, saleFeeFixed);
        uint totalQty = qty + saleFee;
        totalSolxFee += saleFee;

        // Create listing
        bytes32 key = keccak256(abi.encodePacked(seller, qty, totalPrice, listings.length));
        listingsKeyToIndex[key] = uint16(listings.length);
        listings.push(Listing(seller, qty, totalPrice, block.timestamp, key));

        emit ListingAdded(seller, qty, totalPrice, saleFee);

        // Transfer SOLX to contract
        bool solxReceived = solx.transferFrom(seller, address(this), totalQty);
        require(solxReceived, "Failed to get SOLX");

        // Apply listing commission
        if (saleFee > 0) {
            bool feeTaken = solx.transfer(feeOwner, saleFee);
            require(feeTaken, "Failed to get SOLX for fee");
        }
    }

    function removeListing(bytes32 listingKey) external {
        Listing memory listing = listingByKey(listingKey);
        require(_msgSender() == listing.seller);
        _remove(listing);

        bool solxToSeller = solx.transfer(listing.seller, listing.solxQuantity);
        require(solxToSeller, "Failed to send SOLX back to seller");
    }

    // Buy a listing
    function buy(bytes32 listingKey) external whenNotPaused nonReentrant {
        Listing memory listing = listingByKey(listingKey);
        address buyer = _msgSender();
        require(buyer != listing.seller, "Can't buy own listing");

        completedSales += 1;
        totalSalesSolx += listing.solxQuantity;
        totalSalesBusd += listing.totalPrice;
        _remove(listing);

        uint buyFee = calculateFee(listing.totalPrice, buyFeePercent, buyFeeFixed);
        emit Purchase(buyer, listing.seller, listing.solxQuantity, listing.totalPrice, buyFee);

        // Apply commission
        if (buyFee > 0) {
            totalBusdFee += buyFee;
            bool feeTaken = busd.transferFrom(buyer, feeOwner, buyFee);
            require(feeTaken, "Failed to get BUSD for fee");
        }

        // Exchange tokens between buyer and seller
        bool busdToSeller = busd.transferFrom(buyer, listing.seller, listing.totalPrice);
        require(busdToSeller, "Failed to pay seller");

        bool solxToBuyer = solx.transfer(buyer, listing.solxQuantity);
        require(solxToBuyer, "Failed to send SOLX to buyer");
    }

    // Update sale fee percent (taken on listing)
    function setSaleFeePercent(uint n) external onlyOwner {
        require(n <= FEE_PERCENT_DIVISOR, "Sale fee too big");

        uint oldFee = saleFeePercent;
        saleFeePercent = n;

        emit SaleFeeUpdated(oldFee, saleFeePercent);
    }

    // Update fixed sale fee percent (taken on listing)
    function setSaleFeeFixed(uint n) external onlyOwner {
        uint oldFee = saleFeeFixed;
        saleFeeFixed = n;

        emit SaleFeeFixedUpdated(oldFee, saleFeeFixed);
    }

    // Update buy fee percent (taken on buy)
    function setBuyFeePercent(uint n) external onlyOwner {
        require(n <= FEE_PERCENT_DIVISOR, "Buy fee too big");

        uint oldFee = buyFeePercent;
        buyFeePercent = n;

        emit BuyFeeUpdated(oldFee, buyFeePercent);
    }

    // Update buy fee percent (taken on buy)
    function setBuyFeeFixed(uint n) external onlyOwner {
        uint oldFee = buyFeeFixed;
        buyFeeFixed = n;

        emit BuyFeeFixedUpdated(oldFee, buyFeeFixed);
    }

    // Update minimum price accepted per SOLX when listing a package
    function setMinSolxPrice(uint p) external onlyOwner {
        require(p > 0, "Min price can't be zero");

        uint oldMinSolxPrice = minSolxPrice;
        minSolxPrice = p;

        emit MinPriceUpdated(oldMinSolxPrice, minSolxPrice);
    }

    // Update minimum quantity accepted per package listed
    function setMinSolxQuantity(uint n) external onlyOwner {
        require(n > 0, "Min quantity can't be zero");

        uint oldMinSolxQuantity = minSolxQuantity;
        minSolxQuantity = n;

        emit MinQuantityUpdated(oldMinSolxQuantity, minSolxQuantity);
    }

    function setFeeOwner(address addr) external {
        require(_msgSender() == feeOwner, "Not feeOwner");
        require(addr != address(0), "Zero address not allowed for feeOwner");

        address oldFeeOwner = feeOwner;
        feeOwner = addr;

        emit FeeOwnerUpdated(oldFeeOwner, feeOwner);
    }

    function calculateFee(uint n, uint feePercent, uint feeFixed) public pure returns (uint) {
        uint variableFee = n * feePercent / FEE_PERCENT_DIVISOR;
        return variableFee > feeFixed ? variableFee : feeFixed;
    }

    function listingByKey(bytes32 listingKey) public view returns (Listing memory) {
        uint i = listingsKeyToIndex[listingKey];
        require(i < listings.length, "Listing index outside of range");

        Listing memory listing = listings[i];
        require(listing.key == listingKey, "Listing not found");

        return listing;
    }

    // Remove a listing
    function _remove(Listing memory listing) internal {
        // Move last listing in place of the one removed
        uint16 i = listingsKeyToIndex[listing.key];
        Listing storage lastListing = listings[listings.length - 1];
        listings[i] = lastListing;
        listingsKeyToIndex[lastListing.key] = i;

        // Shorten array and reset index for the one removed
        listings.pop();
        listingsKeyToIndex[listing.key] = 0;

        emit ListingRemoved(listing.seller, listing.solxQuantity, listing.totalPrice);
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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