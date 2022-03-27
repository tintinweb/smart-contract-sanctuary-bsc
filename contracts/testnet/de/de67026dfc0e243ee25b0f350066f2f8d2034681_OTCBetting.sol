/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: GPL-3.0

/**
    Author: Kent Oyama
    Date:   2022-3-26
**/

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

pragma solidity >=0.7.0 <0.9.0;

contract OTCBetting is Ownable {

    // Events
    event Received(address, uint);
    event NewHistory(address, uint , uint, uint); //Triggered when a new action is fired.

    //Structures
    struct History {    //  History of Betting
        address player; //address of player
        uint amount;    //amount of action
        uint timestamp; //time of action
        uint action;    //action of History 1:Bet, 2:Win, 3:Lose, 4:Refund
    }
    struct Room {           //  Status of Betting rooms
        address[3] players; //Players
        uint cntPlayer;     //player count
        uint timestamp;     //time of last member entered
    }
    struct Status {
        uint[10] chance;    //chance of the room
        uint[10] timestamp; //time of last action
        uint[10] status;    //status. 1:Pending, 2:Won, 3:Lost, 4:Refunded
    }

    //BettingHistory
    mapping(uint => History) history;
    uint cntHistory = 0;

    //Status of players
    mapping(address => Status) status;

    //Amounts of Betting.
    uint[10] bettingAmounts = [uint(0.01 ether), uint(0.02 ether), uint(0.05 ether), uint(0.1 ether), uint(0.2 ether), uint(0.3 ether), uint(0.5 ether), uint(1 ether), uint(2 ether), uint(5 ether)];

    //Status of Rooms
    Room[10] rooms;

    // Fee % for every betting.
    uint fee = 10;

    //The period of Refund
    uint refundPeriod = 2 hours;

    //Developer wallets
    address devWallet1;
    address devWallet2;
    uint revenue;


    // Methods
    constructor() {}

    receive() external payable {
        bet();
    }

    function addNewHistory(address player, uint amount, uint action) internal {
        History memory newHistory;

        newHistory.player = player;
        newHistory.amount = amount;
        newHistory.timestamp = block.timestamp;
        newHistory.action = action;
        
        history[cntHistory] = newHistory;
        cntHistory ++;
        
        emit NewHistory(msg.sender, msg.value, block.timestamp, 1);
    }

    function checkRooms() internal {
        uint i;
        for(i = 0; i < 10; i ++) {
            if(block.timestamp - rooms[i].timestamp > refundPeriod) {
                refund(i);
            }
            else if(rooms[i].cntPlayer == 3) {
                givePrize(i);
            }
        }
    }

    function refund(uint roomNumber) internal {
        uint i;
        uint cnt = rooms[roomNumber].cntPlayer;
        uint amount = bettingAmounts[roomNumber];
        for(i = 0; i < cnt; i ++) {
            address receiver = rooms[roomNumber].players[i];
            payable(receiver).transfer(amount);
            addNewHistory(receiver, amount, 4);

            setStatus(receiver, 4, roomNumber);
        }
        rooms[roomNumber].cntPlayer = 0;
    }

    function givePrize(uint roomNumber) internal {
        uint i;
        uint luckyman = calculateLuckyMan(roomNumber);

        for(i = 0; i < 3; i ++) {
            address receiver = rooms[roomNumber].players[i];
            uint amount;
            uint action;
            if(i == luckyman) {
                amount = bettingAmounts[roomNumber] * 3 * (100 - fee) / 100;
                payable(receiver).transfer(amount);
                action = 2;
            }
            else {
                amount = bettingAmounts[roomNumber];
                action = 3;
            }
            setStatus(receiver, action, roomNumber);
            addNewHistory(receiver, amount, action);
        }

        rooms[roomNumber].cntPlayer = 0;

        revenue = revenue + bettingAmounts[roomNumber] * fee / 100 * 3;
    }

    function setStatus(address player, uint action, uint roomNumber) internal {
        status[player].timestamp[roomNumber] = block.timestamp;
        status[player].status[roomNumber] = action;

        if(action == 2) {
            status[player].chance[roomNumber] = 0;
        }
        else if(action == 3) {
            status[player].chance[roomNumber] ++;
        }
    }

    function calculateLuckyMan(uint roomNumber) internal view returns(uint) {
        uint i;
        uint totalchance = 3;
        uint luckyman;
        for(i = 0; i < 3; i ++) {
            address player = rooms[roomNumber].players[i];
            totalchance += status[player].chance[roomNumber];
        }
        uint ticker = block.timestamp % totalchance;
        for(i = 0; i < 3; i ++) {
            address player = rooms[roomNumber].players[i];
            uint chance = status[player].chance[roomNumber];
            if(ticker <= chance + i + 1) {
                luckyman = i;
                break;
            }
        }
        return luckyman;
    }

    // Views

    function getStatus(address player, uint roomNumber) view public returns(uint, uint) {
        return (status[player].status[roomNumber], 
                status[player].timestamp[roomNumber]);
    }

    function getHistory(uint cnt) view public returns(History[] memory) {
        History[] memory h = new History[](cnt);
        uint i;
        for(i = 0; i < cnt; i ++) {
            h[i] = history[i + cntHistory - cnt];
        }
        return h;
    }

    function bet() payable public {
        uint roomNumber;
        uint i;

        for(roomNumber = 0; roomNumber < 10; roomNumber ++) {
            if(msg.value == bettingAmounts[roomNumber])
                break;
        }
        require(roomNumber < 10, "Please bet the right amount.");

        for(i = 0; i < rooms[roomNumber].cntPlayer; i ++) {
            require(msg.sender != rooms[roomNumber].players[i], "You are already in betting.");
        }

        rooms[roomNumber].timestamp = block.timestamp;
        rooms[roomNumber].players[rooms[roomNumber].cntPlayer] = msg.sender;
        rooms[roomNumber].cntPlayer ++;

        setStatus(msg.sender, 1, roomNumber);

        addNewHistory(msg.sender, msg.value, 1);

        checkRooms();
    }

    function withdraw() public onlyOwner() {

        payable(devWallet1).transfer(revenue / 2);
        payable(devWallet2).transfer(revenue / 2);
    }

}