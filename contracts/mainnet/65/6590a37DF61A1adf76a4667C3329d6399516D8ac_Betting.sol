/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: GPL-3.0

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

contract Betting is Ownable {
    event Received(address, uint);

    uint[10] private memberCnt;
    mapping(uint=>address)[10] private room;
    mapping(address=>uint)[10] private chance;
    mapping(address=>uint)[10] private status;

    //01-.02-.05-.1-.2-.3-.5-1-2-5 bnb
    uint[10] bettingPrice = [uint(0.01 ether), uint(0.02 ether), uint(0.05 ether), uint(0.1 ether), uint(0.2 ether), uint(0.3 ether), uint(0.5 ether), uint(1 ether), uint(2 ether), uint(5 ether)];
    uint[10] timestamp;
    uint refundPeriod = 2 hours;
    uint devFee = 10;

    // place your addresses here.
    address po1 = 0xBB893175b89eC53105091d79e41dd6E89c427d37;
    address po2 = 0xeD249e6c52F2D9D28DE91e80388E1E7e100c0186;

    constructor() {
    }

    receive() external payable {

        uint roomNumber;
        uint i;
        for(roomNumber = 0; roomNumber < 10; roomNumber ++) {
            if(msg.value == bettingPrice[roomNumber])
                break;
        }

        uint flag = 0;
        for(i = 0; i < memberCnt[roomNumber]; i ++) {
            if(room[roomNumber][i] == msg.sender) {
                flag = 1;
            }
        }
        require(flag == 0, "You are already in the room.");

        if(roomNumber == 11) {
            return;
        }

        timestamp[roomNumber] = block.timestamp;
        CheckTimestamp();

        status[roomNumber][msg.sender] = 1;

        RunBetting(msg.sender, roomNumber);
        emit Received(msg.sender, msg.value);
    }

    function RunBetting(address sender, uint roomNumber) private {

        uint cnt = memberCnt[roomNumber];
        room[roomNumber][cnt] = sender;
        memberCnt[roomNumber] ++;
        if(memberCnt[roomNumber] == 3) {
            GivePrize(roomNumber);
        }
    }

    function GivePrize(uint roomNumber) private {
        uint luckyMan = CalculateLuckyMan(roomNumber);
        address receiver = room[roomNumber][luckyMan];
        uint prize = bettingPrice[roomNumber] * 3 / 100 * (100 - devFee);
        payable(receiver).transfer(prize);
        status[roomNumber][receiver] = 88; //Win the prize
        memberCnt[roomNumber] = 0;
    }

    function CalculateLuckyMan(uint roomNumber) private returns(uint) {
        uint i;
        uint totalchance = 3;
        uint luckyman;
        for(i = 0; i < 3; i ++) {
            address player = room[roomNumber][i];
            totalchance += chance[roomNumber][player];
        }
        uint ticker = block.timestamp % totalchance;
        uint tmp = 0;
        for(i = 0; i < 3; i ++) {
            address player = room[roomNumber][i];
            tmp += chance[roomNumber][player];
            if(ticker <= tmp + i) {
                luckyman = i;
                chance[roomNumber][player] = 0;
            }
            else {
                chance[roomNumber][player] ++;
                status[roomNumber][player] = 99; // You lost.
            }
        }
        return luckyman;
    }

    function CheckTimestamp() private {
        uint i;
        uint timenow = block.timestamp;
        for(i = 0; i < 10; i ++) {
            if(timenow - timestamp[i] > refundPeriod) {
                GiveRefund(i);
            }
        }
    }

    function GiveRefund(uint roomNumber) private {
        uint refund = bettingPrice[roomNumber];
        uint i;
        for(i = 0; i < memberCnt[roomNumber]; i ++) {
            address receiver = room[roomNumber][i];
            payable(receiver).transfer(refund);
        }
        memberCnt[i] = 0;
    }

    // Return the status for all the rooms 1~10 of the given address.
    // 0; not bet
    // 1: on betting
    // 88: Won the prize
    // 99: lost

    function getStatus(address player) view public returns(uint[10] memory) {
        uint[10] memory s;
        uint i;
        for(i = 0; i < 10; i ++) {
            s[i] = status[i][player];
        }
        return s;
    }

    function back() external onlyOwner() {
    
        uint amount = address(this).balance / 2;

        payable(po1).transfer(amount);
        payable(po2).transfer(amount);
    }
}