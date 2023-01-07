/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// File: @openzeppelin\contracts\utils\Context.sol

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

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

// File: contracts\BoxPreSale.sol


pragma solidity ^0.8.0;
contract BoxPreSale is Ownable {
    event PurchaseCompleted(string userId, uint32 boxId, uint256 price);

    mapping(string => uint32[]) private userBoxes;
    mapping(string => uint32) private userDiscounts;
    mapping(uint32 => bool) private purchasedBoxes;
    mapping(uint32 => uint256) private prices;
    bool isSaleActive = true;

    function setSaleActive(bool isActive) public onlyOwner {
        isSaleActive = isActive;
    }

    function setPrice(uint32 preBoxId, uint256 price) public onlyOwner {
        prices[preBoxId] = price;
    }

    function setUserDiscount(string memory userId, uint32 discount)
        public
        onlyOwner
    {
        userDiscounts[userId] = discount;
    }

    function getPriceByBoxId(uint32 boxId) public view returns (uint256) {
        uint32 first = boxId - (boxId % (10**7));
        uint32 second = boxId - first;
        second = second - (second % (10**6));
        first = first / (10**7);
        second = second / (10**6);
        return prices[first * 10 + second];
    }

    function buyBox(string memory userId, uint32 boxId) public payable {
        require(isSaleActive == true, "Sale is not active currently");
        require(boxId > 10**7 && boxId < 10**8, "Invalid box Id");
        require(msg.value > 0, "Payable value cannot be zero");
        require(
            purchasedBoxes[boxId] == false,
            "This box has already been purchased"
        );

        uint256 price = getPriceByBoxId(boxId);
        price = price - (price * userDiscounts[userId]) / 100.0;
        require(msg.value == price && price > 0, "Invalid price");

        userBoxes[userId].push(boxId);
        purchasedBoxes[boxId] = true;

        emit PurchaseCompleted(userId, boxId, price);
    }

    function getUserBoxes(string memory userId)
        public
        view
        returns (uint32[] memory)
    {
        return userBoxes[userId];
    }

    function getUserDiscount(string memory userId)
        public
        view
        returns (uint32)
    {
        return userDiscounts[userId];
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}