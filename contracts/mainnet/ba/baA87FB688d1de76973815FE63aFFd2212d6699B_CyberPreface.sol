//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPreface.sol";

contract CyberPreface is IPreface, Ownable {
    uint256 public constant CHARACTER_PRICE = 0.15 ether;
    uint256 public immutable MAX_CHARACTERS = 10;
    uint256 public immutable REACH_CHARACTERS = 1000;
    uint256 public immutable REWARD_ACCOUNTS = 50;
    uint256 public immutable REWARD_AMOUNT = 2;

    uint256 public immutable ENTER_TIMESTAMP = 1648792800; // 2022-04-01
    uint256 public immutable EXIT_TIMESTAMP = 1650520800; // 2022-04-21

    mapping(address => uint256) public charactersEntered;
    uint256 public totalCharacters;

    mapping(address => bool) public rewardAccounts;
    mapping(address => bool) public accountsEntered;
    uint256 public totalAddresses;

    function enter(uint256 amount)
        external
        payable 
    {
        require(block.timestamp >= ENTER_TIMESTAMP && block.timestamp < EXIT_TIMESTAMP, "Please waiting");
        require(charactersEntered[_msgSender()] + amount <= MAX_CHARACTERS && amount > 0, "Exceeds amount");
        require(amount * CHARACTER_PRICE == msg.value, "Invalid payment amount");

        if (!accountsEntered[_msgSender()]) {
            accountsEntered[_msgSender()] = true;
            totalAddresses ++;
            if (totalAddresses <= REWARD_ACCOUNTS) {
                rewardAccounts[_msgSender()] = true;
            }
        }

        totalCharacters += amount;
        charactersEntered[_msgSender()] += amount;
    }

    function exit()
        external
        payable 
    {
        require (!this.launch(), "War is launching, No one can stay out of it");
        require(block.timestamp >= EXIT_TIMESTAMP, "Can't exit right now");
        require(charactersEntered[_msgSender()] > 0, "Not entered");

        uint256 amount = charactersEntered[_msgSender()];

        totalCharacters -= amount;
        charactersEntered[_msgSender()] -= amount;

        payable(_msgSender()).transfer(amount * CHARACTER_PRICE);
    }

    function characters(address account) external override view returns (uint256) {
        return charactersEntered[account] + (rewardAccounts[_msgSender()] ? REWARD_AMOUNT : 0);
    }

    function launch() external override view returns (bool) {
        return totalCharacters >= REACH_CHARACTERS;
    }

    function withdraw() external onlyOwner {
        require(block.timestamp >= EXIT_TIMESTAMP + 5 days, "Can't withdraw");

        payable(owner()).transfer(address(this).balance);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

interface IPreface {
    function characters(address account) external view returns (uint256);

    function launch() external view returns(bool);
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