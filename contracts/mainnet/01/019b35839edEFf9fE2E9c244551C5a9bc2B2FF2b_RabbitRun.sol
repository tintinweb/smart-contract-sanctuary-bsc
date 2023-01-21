// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RabbitRun is Ownable {
    constructor() {
        betStartTime = block.timestamp;
        gameStartTime = block.timestamp + 3600 * 24;
        earnInterval = 30;
    }

    uint256 public betStartTime;
    uint256 public gameStartTime;
    uint256 public earnInterval;

    mapping(address => uint256) public betRecord;

    function setEarnInterval(uint256 _earnInterval) public onlyOwner {
        earnInterval = _earnInterval;
    }

    function setBetStartTime(uint256 _betStartTime) public onlyOwner {
        betStartTime = _betStartTime;
    }
    function setGameStartTime(uint256 _gameStartTime) public onlyOwner {
        gameStartTime = _gameStartTime;
    }

    function bet(uint256 _amount) public payable{
        require(block.timestamp >= betStartTime, "bet not start");
        require(block.timestamp < gameStartTime, "game has already started");

        require(msg.value == _amount, "amount is not equal to msg.value");

        betRecord[msg.sender] += _amount;
    }

    function run() public payable {
        require(block.timestamp >= gameStartTime, "game not start");
        require(address(this).balance > 0, "balance is equal to zero");

        uint256 remainBalance = address(this).balance;
        uint256 _step = (block.timestamp - gameStartTime) / earnInterval;
        uint256 earnAmount = _calculateEarings(betRecord[msg.sender], _step);

        if (remainBalance <= earnAmount) {
            earnAmount = remainBalance;
        }
        payable(msg.sender).transfer(earnAmount);
        betRecord[msg.sender] = 0;
    }

    function _calculateEarings(uint256 _balance, uint256 _step) internal pure returns (uint256) {
        if (_step == 1) {
            return _balance * 21 / 20;
        } else {
            return _calculateEarings(_balance, _step - 1) * 21 / 20;
        }
    }

    function withdraw() public payable onlyOwner {
        require(address(this).balance > 0, "balance is not enough");
        payable(msg.sender).transfer(address(this).balance);
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