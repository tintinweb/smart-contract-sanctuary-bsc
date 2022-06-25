// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "Ownable.sol";
import "ReentrancyGuard.sol";
import "Counters.sol";

contract Lottery is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private id;
    mapping(uint256 => Lottery) private lotteries;

    struct Lottery {
        address payable[] players;
        address firstPlaceAddress;
        address secondPlaceAddress;
        address thirdPlaceAddress;
        uint256 firstPrize;
        uint256 secondPrize;
        uint256 thirdPrize;
        uint256 firstPrizePercetange;
        uint256 secondPrizePercetange;
        uint256 thirdPrizePercetange;
        uint256 minPriceEntry;
        address creator;
        LOTTERY_STATE lotteryState;
        uint256 pot;
        uint256 maxNumberOfPlayers;
    }
    address payable private admin;
    uint256 private creationFee = 0.01 ether;
    uint256 private entranceFeePercentage = 2;
    bool private initialized;

    // events
    event enteredLottery(address user, uint256 value);
    event lotteryStarted(address user);
    event lotteryEnded(address firstPlaceAddress, address secondPlaceAddress, address thirdPlaceAddress, uint256 firstPrize, uint256 secondPrize, uint256 thirdPrize);
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    function initialize() public {
        require(!initialized, "The Contract already built.");
        initialized = true;
        admin = payable(msg.sender);
    }

    function createLottery(
        uint128 _maxNumberOfPlayers,
        uint256 _firstPrizePercetange,
        uint256 _secondPrizePercetange,
        uint256 _thirdPrizePercetange,
        uint256 _minPriceEntry
        ) nonReentrant payable public returns(uint256) {
            require(msg.value >= creationFee, "Not enough money to create lottery.");
            require(_firstPrizePercetange + _secondPrizePercetange + _thirdPrizePercetange == 100, "The prize winners percentage is wrong, sum must be 100");
            address payable[] memory players;
            Lottery memory lottery = Lottery(
                players,
                address(0),
                address(0),
                address(0),
                0,
                0,
                0,
                _firstPrizePercetange,
                _secondPrizePercetange,
                _thirdPrizePercetange,
                _minPriceEntry,
                msg.sender,
                LOTTERY_STATE.CLOSED,
                0,
                _maxNumberOfPlayers
            );
            lotteries[id.current()] = lottery;
            startLottery(id.current());
            id.increment();
            //admin.transfer(msg.value);
            uint256 z = id.current() - 1;
            return z;
    }

    function enter(uint256 id) nonReentrant public payable {
        Lottery storage lottery = lotteries[id];
        require(lottery.lotteryState == LOTTERY_STATE.OPEN, "This lottery is closed/Calculating the winner Now. Please check for another one.");
        require(lottery.maxNumberOfPlayers > lottery.players.length, "This lottery is closed/Calculating the winner Now. Please check for another one.");
        require(msg.value >= lottery.minPriceEntry, "Not Enough Money");

        uint256 adminFee = (msg.value * entranceFeePercentage)/100;
        admin.transfer(adminFee);
        lottery.pot += (msg.value * (100 - entranceFeePercentage))/100;
        lottery.players.push(payable(msg.sender));
        emit enteredLottery(msg.sender, msg.value);
        if (lottery.maxNumberOfPlayers == lottery.players.length) {
            endLottery(id);
        } 
    }

    function startLottery(uint256 id) private {
        Lottery storage lottery = lotteries[id];
        require(lottery.lotteryState == LOTTERY_STATE.CLOSED, "This is an active lottery you cannot start it again.");
        lottery.lotteryState = LOTTERY_STATE.OPEN;
        emit lotteryStarted(lottery.creator);
    }

    function endLottery(uint256 id) private {
        Lottery storage lottery = lotteries[id];
        lottery.lotteryState = LOTTERY_STATE.CALCULATING_WINNER;

        uint256 indexOfFirstPlace = random(lottery.players.length);

        uint256 firstPlaceReward = (lottery.pot * lottery.firstPrizePercetange)/100;
        uint256 secondPlaceReward = (lottery.pot * lottery.secondPrizePercetange)/100;
        uint256 thirdlaceReward = (lottery.pot * lottery.thirdPrizePercetange)/100;

        lottery.players[indexOfFirstPlace].transfer(firstPlaceReward);
        lottery.firstPrize = firstPlaceReward;
        lottery.firstPlaceAddress = lottery.players[indexOfFirstPlace];
        remove(id, indexOfFirstPlace);

        uint256 indexOfSecondPlace = random(lottery.players.length);
        lottery.players[indexOfSecondPlace].transfer(secondPlaceReward);
        lottery.secondPrize = secondPlaceReward;
        lottery.secondPlaceAddress = lottery.players[indexOfSecondPlace];
        remove(id, indexOfSecondPlace);

        uint256 indexOfThirdPlace = random(lottery.players.length);
        lottery.thirdPlaceAddress = lottery.players[indexOfThirdPlace];
        lottery.players[indexOfThirdPlace].transfer(thirdlaceReward);

        emit lotteryEnded(lottery.firstPlaceAddress, lottery.secondPlaceAddress, lottery.thirdPlaceAddress, lottery.firstPrize, lottery.secondPrize, lottery.thirdPrize);
        // The End...
        lottery.lotteryState = LOTTERY_STATE.CLOSED;
    }

    function random(uint number) private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

    function remove(uint256 id, uint index) private {
        Lottery storage lottery = lotteries[id];
        lottery.players[index] = lottery.players[lottery.players.length - 1];
        lottery.players.pop();
    }

    function setEntranceFeePercentage(uint256 _entranceFeePercentage) nonReentrant public {
        require(msg.sender == admin, "Only admin can run this function");
        entranceFeePercentage = _entranceFeePercentage;
    }

    function setCreatingFee(uint256 _creationFee) nonReentrant public {
        require(msg.sender == admin, "Only admin can run this function");
        creationFee = _creationFee;
    }

    function withdrawRemainingBalance() nonReentrant payable public {
        require(msg.sender == admin, "Only admin can run this function");
        admin.transfer(address(this).balance);
    }


    // API Function
    function getPlayers(uint256 id) public view returns (address payable[] memory) {
        Lottery memory lottery = lotteries[id];
        return lottery.players;
    }

    function getLottery(uint256 id) public view returns(Lottery memory) {
        return lotteries[id];
    }

    function getLotteries() public view returns(Lottery[] memory) {
        Lottery[] memory lotteriesFiltered = new Lottery[](id.current());
        for (uint256 i = 0; i < id.current(); i++) {
            Lottery storage lot = lotteries[i];
            lotteriesFiltered[i] = lot;
        }
        return lotteriesFiltered;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}