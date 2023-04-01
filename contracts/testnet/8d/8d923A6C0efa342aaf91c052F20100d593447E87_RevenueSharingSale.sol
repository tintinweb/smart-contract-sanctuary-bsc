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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Recoverable
 * @author Leo
 * @notice Recovers stucked BNB or ERC20 tokens
 * @dev You can inhertit from this contract to support recovering stucked tokens or BNB
 */
contract Recoverable is Ownable {
  /**
   * @notice Recovers stucked BNB in the contract
   */
  function recoverBNB(uint256 amount) external onlyOwner {
    require(address(this).balance >= amount, "Recoverable::recoverBNB: invalid input amount");
    (bool success, ) = payable(owner()).call{ value: amount }("");
    require(success, "Recoverable::recoverBNB: recover failed");
  }

  /**
   * @notice Recovers stucked ERC20 token in the contract
   * @param token An ERC20 token address
   */
  function recoverERC20(address token, uint256 amount) external onlyOwner {
    IERC20 erc20 = IERC20(token);
    require(erc20.balanceOf(address(this)) >= amount, "Recoverable::recoverERC20: invalid input amount");

    erc20.transfer(owner(), amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "../common/Recoverable.sol";

interface IRevenueSharingNft {
  function totalSupply() external view returns (uint256);

  function mint(address user) external returns (uint256);
}

enum PriceType {
  BNB,
  ERC20
}

enum BuyType {
  SINGLE,
  BUNDLE
}

/**
 * @title RevenueSharingSale
 * @dev RevenueSharingSale contract
 * @author Leo
 */
contract RevenueSharingSale is Ownable, Recoverable, ReentrancyGuard, Pausable {
  IERC20 private _token;
  IRevenueSharingNft private _nft;

  uint private _itemSinglePrice;
  uint private _itemBundlePrice;
  uint private _mintLimit;
  uint private _bundleSize;

  PriceType private _priceType;

  /**
   * @dev Emitted when `user` buys `size` of items with `price`.
   */
  event ItemBought(address indexed user, BuyType buyType, uint size, uint price);

  /**
   * @dev Emitted when `priceType` is updated.
   */
  event PriceTypeUpdated(PriceType priceType);

  /**
   * @dev Emitted when `itemSinglePrice` is updated.
   */
  event SinglePriceUpdated(uint itemSinglePrice);

  /**
   * @dev Emitted when `itemBundlePrice` is updated.
   */
  event BundlePriceUpdated(uint itemBundlePrice);

  /**
   * @dev Emitted when `mintLimit` is updated.
   */
  event MintLimitUpdated(uint mintLimit);

  /**
   * @dev Emitted when `token` is updated.
   */
  event TokenUpdated(IERC20 token);

  /**
   * @dev Emitted when `bundleSize` is updated.
   */
  event BundleSizeUpdated(uint bundleSize);

  /**
   * @dev Emitted when `nft` is updated.
   */
  event NftUpdated(IRevenueSharingNft nft);

  /**
   * @dev constructor of RevenueSharingSale
   * @param token the token to be used for payment
   * @param nft the nft to be sold
   * @param priceType the price type of the sale
   * @param itemSinglePrice the price of a single item
   * @param itemBundlePrice the price of a bundle of items
   * @param mintLimit the limit of items to be sold
   */
  constructor(IERC20 token, IRevenueSharingNft nft, PriceType priceType, uint itemSinglePrice, uint itemBundlePrice, uint mintLimit, uint bundleSize) {
    _token = token;
    _nft = nft;
    _priceType = priceType;
    _itemSinglePrice = itemSinglePrice;
    _itemBundlePrice = itemBundlePrice;
    _mintLimit = mintLimit;
    _bundleSize = bundleSize;
  }

  /**
   * @dev returns the number of available items
   */
  function availableItems() public view returns (uint256) {
    return _mintLimit - _nft.totalSupply();
  }

  /**
   * @dev returns the price type of the sale
   * @return the price type of the sale
   */
  function getPriceType() external view returns (PriceType) {
    return _priceType;
  }

  /**
   * @dev returns the price of a single item
   * @return the price of a single item
   */
  function getItemSinglePrice() external view returns (uint) {
    return _itemSinglePrice;
  }

  /**
   * @dev returns the price of a bundle of items
   * @return the price of a bundle of items
   */
  function getItemBundlePrice() external view returns (uint) {
    return _itemBundlePrice;
  }

  /**
   * @dev returns the mint limit of the sale
   * @return the mint limit of the sale
   */
  function getMintLimit() external view returns (uint) {
    return _mintLimit;
  }

  /**
   * @dev returns the token of the sale
   * @return the token of the sale
   */
  function getToken() external view returns (IERC20) {
    return _token;
  }

  /**
   * @dev returns the nft of the sale
   * @return the nft of the sale
   */
  function getNft() external view returns (IRevenueSharingNft) {
    return _nft;
  }

  /**
   * @dev returns the bundle size of the sale
   * @return the bundle size of the sale
   */
  function getBundleSize() external view returns (uint) {
    return _bundleSize;
  }

  /**
   * @dev buys a single or a bundle of items
   * @param buyType the type of the buy either single or bundle
   */
  function buyItem(BuyType buyType) external payable nonReentrant whenNotPaused {
    require(availableItems() > 0, "RevenueSharingSale::buyItem: mint limit reached");

    uint size = buyType == BuyType.SINGLE ? 1 : _bundleSize;
    uint price = buyType == BuyType.SINGLE ? _itemSinglePrice : _itemBundlePrice;

    require(size <= availableItems(), "RevenueSharingSale::buyItem: not enough items available");

    if (_priceType == PriceType.BNB) {
      require(msg.value == price, "RevenueSharingSale::buyItem: bnb value is not correct");
    } else if (_priceType == PriceType.ERC20) {
      require(msg.value == 0, "RevenueSharingSale::buyItem: bnb value is not 0");
    }

    for (uint256 i = 0; i < size; i++) {
      _nft.mint(msg.sender);
    }

    if (_priceType == PriceType.ERC20) {
      _token.transferFrom(msg.sender, address(this), price);
    }

    emit ItemBought(msg.sender, buyType, size, price);
  }

  /**
   * @dev updates the price type of the sale
   * @param priceType the new price type of the sale
   */
  function updatePriceType(PriceType priceType) external onlyOwner {
    _priceType = priceType;

    emit PriceTypeUpdated(priceType);
  }

  /**
   * @dev updates the price of a single item
   * @param itemSinglePrice the new price of a single item
   */
  function updateSinglePrice(uint itemSinglePrice) external onlyOwner {
    _itemSinglePrice = itemSinglePrice;

    emit SinglePriceUpdated(itemSinglePrice);
  }

  /**
   * @dev updates the price of a bundle of items
   * @param itemBundlePrice the new price of a bundle of items
   */
  function updateBundlePrice(uint itemBundlePrice) external onlyOwner {
    _itemBundlePrice = itemBundlePrice;

    emit BundlePriceUpdated(itemBundlePrice);
  }

  /**
   * @dev updates the mint limit of the sale
   * @param mintLimit the new mint limit of the sale
   */
  function updateMintLimit(uint48 mintLimit) external onlyOwner {
    require(mintLimit >= _nft.totalSupply(), "RevenueSharingSale::updateMintLimit: mint limit is lower than total supply");

    _mintLimit = mintLimit;

    emit MintLimitUpdated(mintLimit);
  }

  /**
   * @dev updates the token of the sale
   * @param token the new token of the sale
   */
  function updateToken(IERC20 token) external onlyOwner {
    _token = token;

    emit TokenUpdated(token);
  }

  /**
   * @dev updates the nft of the sale
   * @param nft the new nft of the sale
   */
  function updateNft(IRevenueSharingNft nft) external onlyOwner {
    _nft = nft;

    emit NftUpdated(nft);
  }

  /**
   * @dev updates the bundle size of the sale
   * @param bundleSize the new bundle size of the sale
   */
  function updateBundleSize(uint48 bundleSize) external onlyOwner {
    _bundleSize = bundleSize;

    emit BundleSizeUpdated(bundleSize);
  }

  /**
   * @dev pauses the sale
   */
  function pause() external onlyOwner {
    _pause();

    emit Paused(msg.sender);
  }

  /**
   * @dev unpauses the sale
   */
  function unpause() external onlyOwner {
    _unpause();

    emit Unpaused(msg.sender);
  }

  /**
   * @dev returns the minimum of two numbers
   * @param a the first number
   * @param b the second number
   * @return the minimum of the two numbers
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}