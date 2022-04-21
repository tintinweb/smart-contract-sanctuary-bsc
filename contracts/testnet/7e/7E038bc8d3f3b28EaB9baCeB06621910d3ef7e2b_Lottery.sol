// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IDoublePrize {
    function updatePlayers(address payable _sender, uint _amount) external payable;
}

interface IAffiliate{
    function pay(address payable _addruser, uint _levels, uint _percent_level, address payable _addrinviter) external payable;
}

contract Lottery is Ownable{

    address private _owner;

    using SafeMath for uint;

    // manager address
    address public manager;

    // draw participants
    struct PlayerStructure {
        address payable _user;
        uint _datetime;
        uint _amount;
    }
    mapping(address => PlayerStructure) public listPlayers;
    address[] public  players;

    // draw winners
    struct Winners {
        address payable _user;
        uint _totalDraw;
        uint _datetime;
        uint _draw_edition;
    }
    mapping(address => Winners) public mapwinners;
    address[] public  winners;

    uint public draw_edition = 0; //Each open draw adds one edition

    // total tickets to complete the draw
    uint public target_amount_default = 10;
    uint public target_amount = target_amount_default;
    uint public max_buy_player = 100;

    // price of ticket = 0.02 BNB
    uint public ticket_price = 0.02 * 10 ** 18;

    uint public amount_draw; // total accumulated for open draw prizes
    uint public amount_team; // Total accumulated to withdraw from the team
    address payable address_team;

    //Allocations
    uint percent_draw = 20; //allocation percentage for the prize
    uint percent_doubleprize = 50; //allocation percentage for the prize
    uint percent_affiliate = 5; //percent affiliate commission
    uint percent_company = 25; //allocation percentage for the prize

    address payable address_doubleprize;
    address address_affiliate;
    uint levels_affiliate = 1;


    // check if game finished
    bool public isGameEnded = true;
    bool public isReadyPickWinner = false;
    uint public startedTime = 0;

    //chainlink vars
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    // add event
    event NewWinner(address indexed winner, uint balance);
    event NewPlayer(address indexed player, uint tickets);

    // constructor
    constructor(address payable address_contract_doubleprize, address address_contract_affiliate)
    {
        address_doubleprize = address_contract_doubleprize;
        address_affiliate = address_contract_affiliate;

        // define administrator with deployer
        manager = msg.sender;
        isGameEnded = true;
        initialize();
    }

    // middleware to check if game is on or off
    modifier onGame() {
        require(!isGameEnded && !isReadyPickWinner, "Game has not started yet.");
        _;
    }

    // Get Balance of pool
    function balanceInPool()public view returns(uint){
        return amount_draw;
    }

    // buy ticket and participate
    function MegaLottoTicket(address payable _addrinviter) public payable onGame{

        uint total_ticket = msg.value.div(ticket_price);
        require(total_ticket >= 1,"you need to buy 1 or more of a ticket"); //Checks if total ticket is >= 1
        require(total_ticket <= max_buy_player,"the maximum number of tickets per purchase has been exceeded"); //Checks if total ticket is >= 1

        uint _ticketPlay = 1;
        while (_ticketPlay <= total_ticket){
            players.push(msg.sender);
            target_amount = target_amount - 1;
            _ticketPlay++;
        }
        listPlayers[msg.sender] = PlayerStructure(payable(msg.sender), block.timestamp, total_ticket);

        //update the amount funds
        amount_draw += msg.value.mul(percent_draw).div(100);
        amount_team += msg.value.mul(percent_company).div(100);
        uint value_affiliate_pay = msg.value.mul(percent_affiliate).div(100); //calc amount destination to affiliate program
        uint value_super_prize = msg.value.mul(percent_doubleprize).div(100); //50%

        //send value and the player to doubleprize participate
        IDoublePrize(address_doubleprize).updatePlayers{value: value_super_prize}(payable(msg.sender), msg.value);

        //send value the affiliate contract
        IAffiliate(address_affiliate).pay{value: value_affiliate_pay}(payable(msg.sender), 1, 100, _addrinviter);

        //send team funds
        address_team.transfer(amount_team);

        emit NewPlayer(msg.sender, total_ticket);

        //if the number of tickets is exhausted, then draw the winner.
        if(target_amount == 0) {
            isReadyPickWinner = true;
            pickWinner();
        }

    }

    // initialize the game
    function initialize() private {
        require(isGameEnded, "Game is running now.");
        startedTime = block.timestamp;
        target_amount = target_amount_default;
        isGameEnded = false;
        isReadyPickWinner = false;
        draw_edition += 1;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players)));
    }

    function pickWinner() private {

        require(isReadyPickWinner, "Game is running now."); // Check if the draw is ready for the draw

        uint index = random() % players.length; // Searching for an address at random from the raffle participant list
        address payable winner = payable(players[index]); // setting the winner's address
        players = new address[](0); // resetting the list of attendees and tickets to zero

        winner.transfer(amount_draw);// sent super prize to winner

        //        bool sent = winner.send(amount_draw);
        //        require(sent, "Failed to send Super Prize");

        isGameEnded = true;
        mapwinners[winner] = Winners(payable(winner), amount_draw, block.timestamp, draw_edition);
        winners.push(winner);

        emit NewWinner(winner, amount_draw);

        amount_draw = 0;

        initialize(); //start new draw
    }

    function updateTargetAmount(uint _amount) public onlyOwner {
        // Dedicated to the manager increasing the amount of tickets available to increase the prize draw
        target_amount = _amount;
    }

    function updateTeamAddress(address payable _address) public onlyOwner {
        address_team = _address;
    }

    function updateMaxPlayer(uint _amount) public onlyOwner {
        // Dedicated to the manager increasing or decreasing the maximum ticket purchase amount per player
        max_buy_player = _amount;
    }

    function getPlayers()public view returns(address[] memory){
        return players;
    }

    function getWinners()public view returns(address[] memory){
        return winners;
    }

    function getWinnersNumber() public view returns(uint) {
        return winners.length;
    }

    function getPlayerNumber() public view returns(uint) {
        return players.length;
    }

    function getDrawPrizeBalance() public view returns(uint) {
        return amount_draw;
    }

    function getStartedTime() public view returns(uint) {
        return block.timestamp - startedTime;
    }

    function getPercent() public view returns(uint) {
        if(isGameEnded) return 0;
        if(isReadyPickWinner) return 100;
        return getPlayerNumber() * 100 / (target_amount + getPlayerNumber());
    }

    function withdraw(address payable _to, uint _amount) public onlyOwner {
        require(_amount <= amount_team, 'It is only possible to withdraw from the total available to the development team');
        _to.transfer(_amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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