/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

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

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
    constructor() public {
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



interface IForsageLottery {
    function buyTicketFor(address to, uint amount, uint8[] memory levels) external;
    function ticketPrice() external view returns(uint);
    function ticketFee() external view returns(uint);
    function startTime() external view returns(uint);
    function endTime() external view returns(uint);
}

contract ForsageLottery is Ownable, IForsageLottery {

    mapping(uint => uint) public levelTicketAmount;
    mapping(address => bool) public approvedAddresses;
    mapping(address => uint) public userTickets;
    address[] public tickets;

    IERC20 public busd;

    address public feeReceiver;
    uint public override ticketPrice;
    uint public override ticketFee;

    uint public override startTime;
    uint public override endTime;

    address[] public winners;

    event TicketsReceived(address indexed userAddress, uint ticketsReceived, uint[] ticketIndexes, uint totalTickets);
    event LotteryFinished(uint[] winnerTickets, address[] winnerAddresses, uint totalReward);

    constructor(
        address _forsageRouter,
        IERC20 _busd,
        uint _ticketPrice,
        uint _ticketFee,
        address _feeReceiver
    ) public {
        busd = _busd;
        ticketPrice = _ticketPrice;
        ticketFee = _ticketFee;
        feeReceiver = _feeReceiver;

        approvedAddresses[_forsageRouter] = true;

        levelTicketAmount[2] = 2;
        levelTicketAmount[3] = 3;
        levelTicketAmount[4] = 4;
        levelTicketAmount[5] = 5;
        levelTicketAmount[6] = 6;
        levelTicketAmount[7] = 7;
        levelTicketAmount[8] = 8;
        levelTicketAmount[9] = 9;
        levelTicketAmount[10] = 10;
        levelTicketAmount[11] = 11;
        levelTicketAmount[12] = 12;
        levelTicketAmount[13] = 13;
        levelTicketAmount[14] = 14;
        levelTicketAmount[15] = 15;
    }

    function setDates(uint _startTime, uint _endTime) public onlyOwner {
        require(endTime == 0, "already set");

        startTime = _startTime;
        endTime = _endTime;
    }

    function setPrices(uint _ticketPrice, uint _ticketFee) public onlyOwner {
        require(ticketPrice == 0 && ticketFee == 0, "already set");

        ticketPrice = _ticketPrice;
        ticketFee = _ticketFee;
    }

    function buyTicketFor(address to, uint amount, uint8[] memory levels) public override  {
        require(approvedAddresses[msg.sender], "only router");

        if(!(startTime <= block.timestamp && block.timestamp < endTime)) {
            return;
        }

        if(levels.length == 0) {
            busd.transferFrom(msg.sender, address(this), ticketPrice * amount);
            busd.transferFrom(msg.sender, feeReceiver, ticketFee);
            _sendTickets(to, amount);
            return;
        }

        uint ticketsCount;
        for(uint i = 0; i < levels.length; i++) {
            ticketsCount += levelTicketAmount[levels[i]];
        }

        _sendTickets(to, ticketsCount);
    }

    function _sendTickets(address to, uint amount) internal {
        uint[] memory ticketIndexes = new uint[](amount);
        for(uint i = 0; i < amount; i++) {
            ticketIndexes[i] = tickets.length;
            tickets.push(to);
        }
        userTickets[to] += amount;
        emit TicketsReceived(to, amount, ticketIndexes, userTickets[to]);
    }

    function totalTickets() public view returns(uint) {
        return tickets.length;
    }

    function finishLottery() public {
        require(block.timestamp > endTime && endTime != 0, "not a finish time");
        require(winners.length == 0, "already finished");
        uint[] memory winnerTickets = new uint[](100);

        for(uint i = 0; i < 100; i++) {
            uint randomTicket = getRandomNumber(i) % tickets.length;
            winnerTickets[i] = randomTicket;

            address winner = tickets[randomTicket];

            winners.push(winner);
        }

        uint totalReward = busd.balanceOf(address(this));
        payRewards(totalReward);

        LotteryFinished(winnerTickets, winners, totalReward);
    }

    function payRewards(uint totalReward) internal {
        busd.transfer(winners[0], totalReward * 15 / 100);
        busd.transfer(winners[1], totalReward * 10 / 100);
        busd.transfer(winners[2], totalReward * 7 / 100);
        busd.transfer(winners[3], totalReward * 5 / 100);
        busd.transfer(winners[4], totalReward * 4 / 100);
        busd.transfer(winners[5], totalReward * 25 / 1000);
        busd.transfer(winners[6], totalReward * 25 / 1000);
        busd.transfer(winners[7], totalReward * 25 / 1000);
        busd.transfer(winners[8], totalReward * 25 / 1000);
        busd.transfer(winners[9], totalReward * 25 / 1000);
        busd.transfer(winners[10], totalReward * 2 / 100);
        busd.transfer(winners[11], totalReward * 2 / 100);
        busd.transfer(winners[12], totalReward * 2 / 100);
        busd.transfer(winners[13], totalReward * 2 / 100);
        busd.transfer(winners[14], totalReward * 2 / 100);
        busd.transfer(winners[15], totalReward * 15 / 1000);
        busd.transfer(winners[16], totalReward * 15 / 1000);
        busd.transfer(winners[17], totalReward * 15 / 1000);
        busd.transfer(winners[18], totalReward * 15 / 1000);
        busd.transfer(winners[19], totalReward * 15 / 1000);
        busd.transfer(winners[20], totalReward * 15 / 1000);
        busd.transfer(winners[21], totalReward * 15 / 1000);
        busd.transfer(winners[22], totalReward * 15 / 1000);
        busd.transfer(winners[23], totalReward * 1 / 100);
        busd.transfer(winners[24], totalReward * 1 / 100);
        busd.transfer(winners[25], totalReward * 1 / 100);
        busd.transfer(winners[26], totalReward * 1 / 100);
        busd.transfer(winners[27], totalReward * 1 / 100);
        busd.transfer(winners[28], totalReward * 1 / 100);
        busd.transfer(winners[29], totalReward * 1 / 100);
        busd.transfer(winners[30], totalReward * 1 / 100);
        busd.transfer(winners[31], totalReward * 75 / 10000);
        busd.transfer(winners[32], totalReward * 75 / 10000);
        busd.transfer(winners[33], totalReward * 75 / 10000);
        busd.transfer(winners[34], totalReward * 75 / 10000);
        busd.transfer(winners[35], totalReward * 75 / 10000);
        busd.transfer(winners[36], totalReward * 75 / 10000);
        busd.transfer(winners[37], totalReward * 75 / 10000);
        busd.transfer(winners[38], totalReward * 75 / 10000);
        busd.transfer(winners[39], totalReward * 5 / 1000);
        busd.transfer(winners[40], totalReward * 5 / 1000);
        busd.transfer(winners[41], totalReward * 5 / 1000);
        busd.transfer(winners[42], totalReward * 5 / 1000);
        busd.transfer(winners[43], totalReward * 5 / 1000);
        busd.transfer(winners[44], totalReward * 5 / 1000);
        busd.transfer(winners[45], totalReward * 5 / 1000);
        busd.transfer(winners[46], totalReward * 5 / 1000);
        busd.transfer(winners[47], totalReward * 5 / 1000);
        busd.transfer(winners[48], totalReward * 5 / 1000);
        busd.transfer(winners[49], totalReward * 5 / 1000);
        busd.transfer(winners[50], totalReward * 1 / 1000);
        busd.transfer(winners[51], totalReward * 1 / 1000);
        busd.transfer(winners[52], totalReward * 1 / 1000);
        busd.transfer(winners[53], totalReward * 1 / 1000);
        busd.transfer(winners[54], totalReward * 1 / 1000);
        busd.transfer(winners[55], totalReward * 1 / 1000);
        busd.transfer(winners[56], totalReward * 1 / 1000);
        busd.transfer(winners[57], totalReward * 1 / 1000);
        busd.transfer(winners[58], totalReward * 1 / 1000);
        busd.transfer(winners[59], totalReward * 1 / 1000);
        busd.transfer(winners[60], totalReward * 1 / 1000);
        busd.transfer(winners[61], totalReward * 1 / 1000);
        busd.transfer(winners[62], totalReward * 1 / 1000);
        busd.transfer(winners[63], totalReward * 1 / 1000);
        busd.transfer(winners[64], totalReward * 1 / 1000);
        busd.transfer(winners[65], totalReward * 1 / 1000);
        busd.transfer(winners[66], totalReward * 1 / 1000);
        busd.transfer(winners[67], totalReward * 1 / 1000);
        busd.transfer(winners[68], totalReward * 1 / 1000);
        busd.transfer(winners[69], totalReward * 1 / 1000);
        busd.transfer(winners[70], totalReward * 1 / 1000);
        busd.transfer(winners[71], totalReward * 1 / 1000);
        busd.transfer(winners[72], totalReward * 1 / 1000);
        busd.transfer(winners[73], totalReward * 1 / 1000);
        busd.transfer(winners[74], totalReward * 1 / 1000);
        busd.transfer(winners[75], totalReward * 1 / 1000);
        busd.transfer(winners[76], totalReward * 1 / 1000);
        busd.transfer(winners[77], totalReward * 1 / 1000);
        busd.transfer(winners[78], totalReward * 1 / 1000);
        busd.transfer(winners[79], totalReward * 1 / 1000);
        busd.transfer(winners[80], totalReward * 1 / 1000);
        busd.transfer(winners[81], totalReward * 1 / 1000);
        busd.transfer(winners[82], totalReward * 1 / 1000);
        busd.transfer(winners[83], totalReward * 1 / 1000);
        busd.transfer(winners[84], totalReward * 1 / 1000);
        busd.transfer(winners[85], totalReward * 1 / 1000);
        busd.transfer(winners[86], totalReward * 1 / 1000);
        busd.transfer(winners[87], totalReward * 1 / 1000);
        busd.transfer(winners[88], totalReward * 1 / 1000);
        busd.transfer(winners[89], totalReward * 1 / 1000);
        busd.transfer(winners[90], totalReward * 1 / 1000);
        busd.transfer(winners[91], totalReward * 1 / 1000);
        busd.transfer(winners[92], totalReward * 1 / 1000);
        busd.transfer(winners[93], totalReward * 1 / 1000);
        busd.transfer(winners[94], totalReward * 1 / 1000);
        busd.transfer(winners[95], totalReward * 1 / 1000);
        busd.transfer(winners[96], totalReward * 1 / 1000);
        busd.transfer(winners[97], totalReward * 1 / 1000);
        busd.transfer(winners[98], totalReward * 1 / 1000);
        busd.transfer(winners[99], totalReward * 1 / 1000);
    }

    function getRandomNumber(uint seed) public view returns (uint) {
        return uint(keccak256(abi.encodePacked(seed, block.difficulty, block.timestamp)));
    }
}