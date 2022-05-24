// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./IMarketCurrencyManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketCurrencyManager is IMarketCurrencyManager, Ownable {
    bool currencyPublicAll;
    uint256 commisionDefault; //2 decinal
    uint256 minAmountDefault;

    mapping(address => bool) whilelists;

    struct Currency {
        uint256 commission; //2 decinal
        uint256 minAmount;
        bool valid;
    }
    mapping(address => mapping(address => Currency)) currencies; // nft=>currency
    // mapping( address => Currency) currencies;
    event UpdateCurrency(
        address currency,
        uint256 commision,
        uint256 minAmount,
        bool valid,
        uint256 time
    );

    constructor(
        bool _currencyPublicAll,
        uint256 _commisionDefault,
        uint256 _minAmountDefault
    ) {
        currencyPublicAll = _currencyPublicAll;
        commisionDefault = _commisionDefault;
        minAmountDefault = _minAmountDefault;
    }

    modifier onlyWhilelist() {
        require(
            whilelists[_msgSender()],
            "Error: only whilelist can set currency"
        );
        _;
    }

    function setWhilelist(address _user, bool _isWhilelist) external onlyOwner {
        whilelists[_user] = _isWhilelist;
    }

    function setCurrencyPublicAll(bool _currencyPublicAll) external onlyOwner {
        currencyPublicAll = _currencyPublicAll;
    }

    function setCommisionDefault(uint256 _commisionDefault) external onlyOwner {
        commisionDefault = _commisionDefault;
    }

    function setMinAmountDefault(uint256 _minAmountDefault) external onlyOwner {
        minAmountDefault = _minAmountDefault;
    }

    function setCurrencies(
        address[] memory _nfts,
        address[] memory _currencies,
        uint256[] memory _commisions,
        uint256[] memory _minAmounts,
        bool[] memory _valids
    ) external override onlyWhilelist {
        require(
            _nfts.length == _currencies.length,
            "Error: invalid input"
        );
        require(
            _currencies.length == _commisions.length,
            "Error: invalid input"
        );
        require(
            _currencies.length == _minAmounts.length,
            "Error: invalid input"
        );
        require(_currencies.length == _valids.length, "Error: invalid input");

        for (uint16 i = 0; i < _currencies.length; i++) {
            currencies[_nfts[i]][_currencies[i]] = Currency(
                _commisions[i],
                _minAmounts[i],
                _valids[i]
            );
            emit UpdateCurrency(
                _currencies[i],
                _commisions[i],
                _minAmounts[i],
                _valids[i],
                block.timestamp
            );
        }
    }

    function getCurrency(address _nft, address _currency)
        external
        view
        override
        returns (
            uint256,
            uint256,
            bool
        )
    {
        if (currencies[_nft][_currency].valid)
            return (
                currencies[_nft][_currency].commission,
                currencies[_nft][_currency].minAmount,
                currencies[_nft][_currency].valid
            );

        if (currencyPublicAll) {
            return (commisionDefault, minAmountDefault, true);
        } else return (0, 0, false);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IMarketCurrencyManager {
    function setCurrencies(
        address[] memory _nfts,
        address[] memory _currencies,
        uint256[] memory _commisions,
        uint256[] memory _minAmounts,
        bool[] memory _valids
    ) external;

    function getCurrency(address _nft, address _currency)
        external
        view
        returns (
            uint256,
            uint256,
            bool
        );
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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