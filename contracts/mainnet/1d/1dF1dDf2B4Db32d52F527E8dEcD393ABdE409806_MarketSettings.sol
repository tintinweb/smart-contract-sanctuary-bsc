// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMarketSettings.sol";

contract MarketSettings is IMarketSettings, Ownable {
    constructor(
        address royaltyRegsitry_,
        address paymentTokenRegistry_,
        address wrappedEther_
    ) {
        _royaltyRegsitry = royaltyRegsitry_;
        _paymentTokenRegistry = paymentTokenRegistry_;
        _wrappedEther = wrappedEther_;
        _serviceFeeReceiver = msg.sender;
    }

    address private _royaltyRegsitry;
    address private _paymentTokenRegistry;

    address private immutable _wrappedEther;

    bool private _isTradingEnabled = true;
    uint256 public constant FEE_DENOMINATOR = 10000;
    address private _serviceFeeReceiver;
    uint256 private _serviceFeeFraction = 200;
    uint256 private _actionTimeOutRangeMin = 300; // 5 mins
    uint256 private _actionTimeOutRangeMax = 15552000; // 180 days

    mapping(address => bool) private _marketDisabled;

    /**
     * @dev See {IMarketSettings-wrappedEther}.
     */
    function wrappedEther() external view returns (address) {
        return _wrappedEther;
    }

    /**
     * @dev See {IMarketSettings-royaltyRegsitry}.
     */
    function royaltyRegsitry() external view returns (address) {
        return _royaltyRegsitry;
    }

    /**
     * @dev See {IMarketSettings-paymentTokenRegistry}.
     */
    function paymentTokenRegistry() external view returns (address) {
        return _paymentTokenRegistry;
    }

    /**
     * @dev See {IMarketSettings-updateRoyaltyRegistry}.
     */
    function updateRoyaltyRegistry(address newRoyaltyRegistry)
        external
        onlyOwner
    {
        address oldRoyaltyRegistry = _royaltyRegsitry;
        _royaltyRegsitry = newRoyaltyRegistry;

        emit RoyaltyRegistryChanged(oldRoyaltyRegistry, newRoyaltyRegistry);
    }

    /**
     * @dev See {IMarketSettings-updatePaymentTokenRegistry}.
     */
    function updatePaymentTokenRegistry(address newPaymentTokenRegistry)
        external
        onlyOwner
    {
        address oldPaymentTokenRegistry = _paymentTokenRegistry;
        _paymentTokenRegistry = newPaymentTokenRegistry;

        emit PaymentTokenRegistryChanged(
            oldPaymentTokenRegistry,
            newPaymentTokenRegistry
        );
    }

    /**
     * @dev See {IMarketSettings-isTradingEnabled}.
     */
    function isTradingEnabled() external view returns (bool) {
        return _isTradingEnabled;
    }

    /**
     * @dev See {IMarketSettings-isCollectionTradingEnabled}.
     */
    function isCollectionTradingEnabled(address collectionAddress)
        external
        view
        returns (bool)
    {
        return _isTradingEnabled && !_marketDisabled[collectionAddress];
    }

    /**
     * @dev enable or disable trading of the whole marketplace
     */
    function changeMarketplaceStatus(bool enabled) external onlyOwner {
        _isTradingEnabled = enabled;
    }

    /**
     * @dev enable or disable trading of collection
     */
    function changeCollectionStatus(address collectionAddress, bool enabled)
        external
        onlyOwner
    {
        if (enabled) {
            delete _marketDisabled[collectionAddress];
        } else {
            _marketDisabled[collectionAddress] = true;
        }
    }

    /**
     * @dev See {IMarketSettings-actionTimeOutRangeMin}.
     */
    function actionTimeOutRangeMin() external view returns (uint256) {
        return _actionTimeOutRangeMin;
    }

    /**
     * @dev See {IMarketSettings-actionTimeOutRangeMax}.
     */
    function actionTimeOutRangeMax() external view returns (uint256) {
        return _actionTimeOutRangeMax;
    }

    /**
     * @dev Change minimum expire time range
     */
    function changeMinActionTimeLimit(uint256 timeInSec) external onlyOwner {
        _actionTimeOutRangeMin = timeInSec;
    }

    /**
     * @dev Change maximum expire time range
     */
    function changeMaxActionTimeLimit(uint256 timeInSec) external onlyOwner {
        _actionTimeOutRangeMax = timeInSec;
    }

    /**
     * @dev See {IMarketSettings-serviceFeeReceiver}.
     */
    function serviceFeeReceiver() external view returns (address) {
        return _serviceFeeReceiver;
    }

    /**
     * @dev See {MarketSettings-serviceFeeFraction}.
     */
    function serviceFeeFraction() external view returns (uint256) {
        return _serviceFeeFraction;
    }

    /**
     * @dev See {IMarketSettings-serviceFeeInfo}.
     */
    function serviceFeeInfo(uint256 salePrice)
        external
        view
        returns (address receiver, uint256 amount)
    {
        receiver = _serviceFeeReceiver;
        amount = (salePrice * _serviceFeeFraction) / FEE_DENOMINATOR;
    }

    /**
     * @dev Change service fee receiver
     */
    function changeSeriveFeeReceiver(address newReceiver) external onlyOwner {
        _serviceFeeReceiver = newReceiver;
    }

    /**
     * @dev Change service fee percentage.
     */
    function changeSeriveFee(uint256 newServiceFeeFraction) external onlyOwner {
        require(
            newServiceFeeFraction <= 10000 / 20,
            "MarketSettings: attempt to set percentage above 5%"
        );

        _serviceFeeFraction = newServiceFeeFraction;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

interface IMarketSettings {
    event RoyaltyRegistryChanged(
        address previousRoyaltyRegistry,
        address newRoyaltyRegistry
    );

    event PaymentTokenRegistryChanged(
        address previousPaymentTokenRegistry,
        address newPaymentTokenRegistry
    );

    /**
     * @dev fee denominator for service fee
     */
    function FEE_DENOMINATOR() external view returns (uint256);

    /**
     * @dev address to wrapped coin of the chain
     * e.g.: WETH, WBNB, WFTM, WAVAX, etc.
     */
    function wrappedEther() external view returns (address);

    /**
     * @dev address of royalty registry contract
     */
    function royaltyRegsitry() external view returns (address);

    /**
     * @dev address of payment token registry
     */
    function paymentTokenRegistry() external view returns (address);

    /**
     * @dev Show if trading is enabled
     */
    function isTradingEnabled() external view returns (bool);

    /**
     * @dev Show if trading is enabled
     */
    function isCollectionTradingEnabled(address collectionAddress)
        external
        view
        returns (bool);

    /**
     * @dev Surface minimum trading time range
     */
    function actionTimeOutRangeMin() external view returns (uint256);

    /**
     * @dev Surface maximum trading time range
     */
    function actionTimeOutRangeMax() external view returns (uint256);

    /**
     * @dev Service fee receiver
     */
    function serviceFeeReceiver() external view returns (address);

    /**
     * @dev Service fee fraction
     * @return fee fraction based on denominator
     */
    function serviceFeeFraction() external view returns (uint256);

    /**
     * @dev Service fee receiver and amount
     * @param salePrice price of token
     */
    function serviceFeeInfo(uint256 salePrice)
        external
        view
        returns (address, uint256);
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