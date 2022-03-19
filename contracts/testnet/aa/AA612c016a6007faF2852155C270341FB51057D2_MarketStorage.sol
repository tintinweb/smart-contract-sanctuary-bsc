// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "../utils/Ownable.sol";

contract MarketStorage is Ownable {
    uint256 private _fee;
    address private _feeOwner;
    uint256 private _commission;
    struct Item {
        address owner;
        address currency;
        uint256 price;
    }

    mapping(uint256 => Item) private _items;
    mapping(address => bool) private _whileLists;

    constructor() {
        _feeOwner = owner();
        _commission = 10000;
        _fee = 1000;
    }

    modifier onlyWhileList() {
        require(_whileLists[_msgSender()], "MarketStorage: only while list");
        _;
    }

    function setWhileList(address _user, bool _isWhileList) external onlyOwner {
        _whileLists[_user] = _isWhileList;
    }

    function setFeeMarket(
        uint256 fee,
        uint256 commission,
        address feeOwner
    ) external onlyOwner {
        require(
            address(feeOwner) != address(0),
            "MarketStorage: setFeeMarket query for the zero address"
        );
        _fee = fee;
        _feeOwner = feeOwner;
        _commission = commission;
    }

    function getFeeMarket()
        public
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        return (_fee, _commission, _feeOwner);
    }

    function addItem(
        uint256 _tokenId,
        address _owner,
        address _currency,
        uint256 _price
    ) public onlyWhileList {
        _items[_tokenId] = Item(_owner, _currency, _price);
    }

    function addItems(
        uint256[] memory _tokenIds,
        address[] memory _owners,
        address[] memory _currencies,
        uint256[] memory _prices
    ) external onlyWhileList {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            addItem(_tokenIds[i], _owners[i], _currencies[i], _prices[i]);
        }
    }

    function deleteItem(uint256 _tokenId) public onlyWhileList {
        delete _items[_tokenId];
    }

    function deleteItems(uint256[] memory _tokenIds) external onlyWhileList {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            deleteItem(_tokenIds[i]);
        }
    }

    function updateItem(
        uint256 _tokenId,
        address _owner,
        address _currency,
        uint256 _price
    ) external onlyWhileList {
        _items[_tokenId] = Item(_owner, _currency, _price);
    }

    function getItem(uint256 _tokenId)
        public
        view
        returns (
            address,
            address,
            uint256
        )
    {
        return (
            _items[_tokenId].owner,
            _items[_tokenId].currency,
            _items[_tokenId].price
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