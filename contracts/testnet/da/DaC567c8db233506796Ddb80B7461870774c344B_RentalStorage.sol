// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../utils/Ownable.sol";

contract RentalStorage is Ownable {
    mapping(uint256 => Item) private _items;

    mapping(uint256 => uint256) private _fees;

    mapping(address => bool) private _whileLists;

    address private _feeOwner;

    uint256 private _commission;

    uint256 private _maxFee;

    uint256 private _maxNumRentFee;

    struct Item {
        uint256 childId;
        address owner;
        address renter;
        address currency;
        uint256 price;
        uint256 timeAllowedRent;
        uint256 totalTimeRent;
        uint256 startTimeRent;
        uint256 startTimeListing;
    }

    constructor() {
        _feeOwner = owner();
        _commission = 10000;
        _maxFee = 5000;
        _maxNumRentFee = 5;
    }

    modifier onlyWhileList() {
        require(_whileLists[_msgSender()], "RentalStorage: only while list");
        _;
    }

    function setWhileList(address _user, bool _isWhileList) external onlyOwner {
        _whileLists[_user] = _isWhileList;
    }

    function setFeeOwner(address feeOwner) external onlyOwner {
        require(
            address(feeOwner) != address(0),
            "RentalStorage: setFeeOwner query for the zero address"
        );
        _feeOwner = feeOwner;
    }

    function setMaxFee(uint256 fee, uint256 maxNumRentFee) external onlyOwner {
        _maxFee = fee;
        _maxNumRentFee = maxNumRentFee;
    }

    function setCommission(uint256 commission) external onlyOwner {
        require(commission != 0, "RentalStorage: setCommission mismatch");
        _commission = commission;
    }

    function setFeeMarket(uint256[] memory numRents, uint256[] memory fees)
        external
        onlyOwner
    {
        require(
            numRents.length == fees.length,
            "RentalStorage: numRents and fees length mismatch"
        );
        for (uint256 i = 0; i < numRents.length; i++) {
            _fees[numRents[i]] = fees[i];
        }
    }

    function getFeeMarket(uint256 numRent)
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        if (numRent >= _maxNumRentFee) {
            return (_maxFee, _commission, _feeOwner);
        }
        return (_fees[numRent], _commission, _feeOwner);
    }

    function addItem(
        uint256 tokenId,
        address owner,
        address currency,
        uint256 price,
        uint256 timeAllowedRent
    ) external onlyWhileList {
        _items[tokenId] = Item(
            0,
            owner,
            address(0),
            currency,
            price,
            timeAllowedRent,
            0,
            0,
            block.timestamp
        );
    }

    function updateItem(
        uint256 tokenId,
        address owner,
        address currency,
        uint256 price,
        uint256 timeAllowedRent
    ) external onlyWhileList {
        _items[tokenId] = Item(
            0,
            owner,
            address(0),
            currency,
            price,
            timeAllowedRent,
            0,
            0,
            block.timestamp
        );
    }

    function deleteItem(uint256 tokenId) external onlyWhileList {
        delete _items[tokenId];
    }

    function deleteItems(uint256[] memory tokenIds) external onlyWhileList {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            delete _items[tokenIds[i]];
        }
    }

    function getItem(uint256 tokenId)
        public
        view
        returns (
            uint256,
            address,
            address,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Item memory item = _items[tokenId];
        return (
            item.childId,
            item.owner,
            item.renter,
            item.currency,
            item.price,
            item.timeAllowedRent,
            item.totalTimeRent,
            item.startTimeRent,
            item.startTimeListing
        );
    }

    function existed(uint256 tokenId) public view returns (bool) {
        return _items[tokenId].owner != address(0);
    }

    function rented(uint256 tokenId) public view returns (bool) {
        return _items[tokenId].renter != address(0);
    }

    function renterOf(uint256 tokenId) public view returns (address) {
        return _items[tokenId].renter;
    }

    function childTokenOf(uint256 tokenId) public view returns (uint256) {
        return _items[tokenId].childId;
    }

    function updateRentItem(
        uint256 tokenId,
        uint256 childId,
        address renter,
        uint256 timeRent
    ) external onlyWhileList {
        Item memory item = _items[tokenId];
        _items[tokenId] = Item(
            childId,
            item.owner,
            renter,
            item.currency,
            item.price,
            item.timeAllowedRent,
            timeRent,
            block.timestamp,
            item.startTimeListing
        );
    }

    function updateReturnItem(uint256 tokenId) external onlyWhileList {
        Item memory item = _items[tokenId];
        _items[tokenId] = Item(
            0,
            item.owner,
            address(0),
            item.currency,
            item.price,
            item.timeAllowedRent,
            0,
            0,
            item.startTimeListing
        );
    }

    function updateTotalTimeRent(uint256 tokenId, uint256 timeRent)
        external
        onlyWhileList
    {
        Item memory item = _items[tokenId];
        _items[tokenId] = Item(
            item.childId,
            item.owner,
            item.renter,
            item.currency,
            item.price,
            item.timeAllowedRent,
            item.totalTimeRent + timeRent,
            item.startTimeRent,
            item.startTimeListing
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Context.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
pragma solidity 0.8.9;

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