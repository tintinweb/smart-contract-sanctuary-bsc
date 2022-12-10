// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryManager is Ownable {
    SantaLottery[] public lotteries;

    function createLottery(
        string memory _lotteryName,
        uint256 _ticketPrice,
        uint256 _ticketAmount,
        uint256 _expiredDate,
        uint256 _reward
    ) onlyOwner public {
        SantaLottery newLottery = new SantaLottery(address(this), _lotteryName, _ticketPrice, _ticketAmount, _expiredDate, _reward);
        lotteries.push(newLottery);

        // event
        LotteryCreated(newLottery);
    }

    function getLotteries() public view returns(SantaLottery[] memory) {
        return lotteries;
    }
    
    function withdrawFunds(uint256 amount) onlyOwner public {
        bool sent = payable(owner()).send(amount);
        require(sent, "Failed to send BNB");
    }

    // Events
    event LotteryCreated(
        SantaLottery lottery
    );
}

contract SantaLottery is Ownable {    
    address treasury;

    string public lotteryName;
    uint256 public ticketPrice;
    uint256 public ticketAmount;
    uint256 public expiredDate;
    uint256 public reward;
    bool public isLotteryOpen;

    address [] public winners;
    address [] public participants;
    uint256 [] private guesses;

    event ticketBought(address indexed player);
    event winnerPicked();

    constructor(
        address _treasury,
        string memory _lotteryName,
        uint256 _ticketPrice,
        uint256 _ticketAmount,
        uint256 _expiredDate,
        uint256 _reward
    ) {
        treasury = _treasury;
        lotteryName = _lotteryName;
        ticketPrice = _ticketPrice;
        ticketAmount = _ticketAmount;
        expiredDate = _expiredDate;
        reward = _reward;
        isLotteryOpen = true;
    }

    function buyTicket() public payable {
        require(isLotteryOpen == true, "Lottery is closed.");
        participants.push(msg.sender);
        treasury.call{value: msg.value}("");
        emit ticketBought(msg.sender);
    }

    function pickRandomWinners() public {
        uint8 luckyNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 100);
        for (uint i = 0; i < participants.length; i++) {
            if (luckyNumber == guesses[i]) {
                winners.push(participants[i]);
            }
        }
        isLotteryOpen = false;
        emit winnerPicked();
    }

    function rewardWinners() public {
        for (uint i = 0; i < winners.length; i++) {
            winners[i].call{value: reward}("");
        }
    }

    function getWinners() public view returns (address[] memory) {
        return winners;
    }

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

    function withdrawFunds(uint256 amount) onlyOwner public {
        bool sent = payable(owner()).send(amount);
        require(sent, "Failed to send BNB");
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