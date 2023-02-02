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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import './interface/IEventRoxul.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract EventRoxul is IEventRoxul, Ownable {
    uint256 public timeCloseBet;
    uint256 public timeStart;
    uint256 public timeLastTransaction;
    uint256 public bet;
    uint256 public balance;
    uint256 public betId = 0;

    bool public status;

    mapping(address => uint256) public userBetTime;
    mapping(address => uint256) public userBetId;
    mapping(uint256 => address) public betIdUser;
    mapping(uint256 => uint256) public betBalance;

    constructor() {}

    function setStatus(bool _status) external onlyOwner {
        status = _status;
        timeLastTransaction = 0;

    }

    function setParam(
        uint256 _timeStart,
        uint256 _timeCloseBet,
        uint256 _bet
    ) external override onlyOwner {
        timeStart = _timeStart;
        timeCloseBet = _timeCloseBet;
        bet = _bet;
        status = true;
        timeLastTransaction = 0;
    }

    function deposit(address userAddress) external payable override onlyOwner {
        require(status, 'Event dont start');
        require(block.timestamp >= timeStart, 'Event dont start');
        require(
            block.timestamp <= timeLastTransaction + timeCloseBet || timeLastTransaction < 1,
            'Event alredy closed'
        );
        require(msg.value >= bet, 'Payment bet is incorrect');

        userBetTime[userAddress] = block.timestamp;
        userBetId[userAddress] = betId;
        betIdUser[betId] = userAddress;
        betBalance[betId] = address(this).balance;
        timeLastTransaction = block.timestamp;
        betId++;
    }

    function claimReward(address userAddress) external override onlyOwner {
        require(betBalance[userBetId[userAddress]] > 0, "You alredy claim");
        require(block.timestamp > timeLastTransaction + timeCloseBet, 'Event don`t stop');
        require(betIdUser[betId - 1] == userAddress, 'You dont winner');

        (bool success, ) = (userAddress).call{value: betBalance[betId - 1]}('');
        betBalance[betId - 1] = 0;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IEventRoxul {
    function setParam(uint256 _timeStart, uint256 _timeCloseBet, uint256 _bet) external;

    function setStatus(bool status) external;

    function deposit(address userAddress) external payable;

    function claimReward(address userAddress) external;
}