// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Contract is Ownable {
    mapping(address => address) private parentHash;
    mapping(address => uint64) public levelHash;

    mapping(address => uint256) public sendAmountHash;
    mapping(address => uint256) public receiveAmountHash;

    mapping(address => address[]) private children;

    uint256 constant _levelAmount = 1 ether / 100;

    constructor() {
        parentHash[_msgSender()] = address(this);
        levelHash[_msgSender()] = 99999;
    }

    function join(address parent) external payable {
        require(msg.value >= _levelAmount, "Amount not enough");
        require(parentHash[parent] != address(0), "Address is wrong.");
        parentHash[_msgSender()] = parent;
        levelHash[_msgSender()] = 1;
        children[parent].push(_msgSender());
        returnValue(_msgSender(), parent, msg.value);
    }

    function levelUp() external payable {
        require(parentHash[_msgSender()] != address(0), "Amount not enough");
        uint64 level = levelHash[_msgSender()] + 1;
        uint256 amount = level * _levelAmount;
        require(msg.value >= amount, "Amount not enough");
        address parent = _msgSender();
        levelHash[_msgSender()] = level;
        for (uint64 i = level; i > 0; i--) {
            parent = getParent(parent);
            if (parent == address(this) || parent == address(0)) {
                break;
            }
        }
        if (levelHash[parent] < level) {
            parent = address(this);
        }
        returnValue(_msgSender(), parent, amount);
    }

    function returnValue(
        address self,
        address parent,
        uint256 amount
    ) private {
        if (parent != address(0) && parent != address(this) && parent != owner()) {
            payable(parent).transfer(amount);
            receiveAmountHash[parent] = receiveAmountHash[parent] + amount;
        }
        sendAmountHash[self] = sendAmountHash[self] + amount;
    }

    function getParent(address add) public view returns (address) {
        return parentHash[add];
    }

    function getChildren(address add) public view returns (address[] memory) {
        return children[add];
    }

    function withdrawETH(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
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