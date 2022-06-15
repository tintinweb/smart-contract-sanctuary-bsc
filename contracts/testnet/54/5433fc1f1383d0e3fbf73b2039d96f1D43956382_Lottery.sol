// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "Ownable.sol";

contract Lottery is Ownable {

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
    uint256 private creationFee = 0.005 ether;
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
        uint256 id,
        uint128 _maxNumberOfPlayers,
        uint256 _firstPrizePercetange,
        uint256 _secondPrizePercetange,
        uint256 _thirdPrizePercetange,
        uint256 _minPriceEntry
        ) payable public {
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
            lotteries[id] = lottery;
            startLottery(id);
    }

    function enter(uint256 id) public payable {
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

    function getPlayers(uint256 id) public view returns (address payable[] memory) {
        Lottery memory lottery = lotteries[id];
        return lottery.players;
    }

    function getLottery(uint256 id) public view returns(Lottery memory) {
        return lotteries[id];
    }

    function startLottery(uint256 id) public {
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

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

    function remove(uint256 id, uint index) private {
        Lottery storage lottery = lotteries[id];
        lottery.players[index] = lottery.players[lottery.players.length - 1];
        lottery.players.pop();
    }

    function setEntranceFeePercentage(uint256 _entranceFeePercentage) public {
        require(msg.sender == admin, "Only admin can run this function");
        entranceFeePercentage = _entranceFeePercentage;
    }

    function setCreatingFee(uint256 _creationFee) public {
        require(msg.sender == admin, "Only admin can run this function");
        creationFee = _creationFee;
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