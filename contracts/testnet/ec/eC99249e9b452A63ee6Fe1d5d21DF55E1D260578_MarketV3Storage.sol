// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketV3Storage is Ownable {
    struct Item {
        address owner;
        address currency;
        uint256 price;
        uint256 listingTime;
        uint256 openTime;
    }
    mapping(address => mapping(uint256 => Item)) items;
    // mapping(uint256 => Item) public items;

    address public market;

    modifier onlyMarket() {
        require(market == _msgSender(), "Storage: only market");
        _;
    }

    function setMarket(address _market) external onlyOwner {
        require(_market != address(0), "Error: address(0)");
        market = _market;
    }

    function addItem(
        address _nft,
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price,
        uint256 _listingTime,
        uint256 _openTime
    ) public onlyMarket {
        items[_nft][_nftId] = Item(
            _owner,
            _currency,
            _price,
            _listingTime,
            _openTime
        );
    }

    function addItems(
        address[] memory _nfts,
        uint256[] memory _nftIds,
        address[] memory _owners,
        address[] memory _currencies,
        uint256[] memory _prices,
        uint256[] memory _listingTimes,
        uint256[] memory _openTimes
    ) external onlyMarket {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            addItem(
                _nfts[i],
                _nftIds[i],
                _owners[i],
                _currencies[i],
                _prices[i],
                _listingTimes[i],
                _openTimes[i]
            );
        }
    }

    function deleteItem(address _nft,uint256 _nftId) public onlyMarket {
        delete items[_nft][_nftId];
    }

    function deleteItems(address[] memory _nfts,uint256[] memory _nftIds) external onlyMarket {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            deleteItem(_nfts[i], _nftIds[i]);
        }
    }

    function updateItem(
        address _nft,
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price,
        uint256 _listingTime,
        uint256 _openTime
    ) external onlyMarket {
        items[_nft][_nftId] = Item(
            _owner,
            _currency,
            _price,
            _listingTime,
            _openTime
        );
    }

    function getItem(address _nft, uint256 _nftId)
        external
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            items[_nft][_nftId].owner,
            items[_nft][_nftId].currency,
            items[_nft][_nftId].price,
            items[_nft][_nftId].listingTime,
            items[_nft][_nftId].openTime
        );
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