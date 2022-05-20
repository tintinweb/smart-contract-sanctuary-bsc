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

    struct PlayerStructure {
        address payable _user;
        uint _datetime;
        uint _ticketprice;
        uint _ticketnumber;
        uint _edition;
    }

    // draw winners
    struct Winners {
        address payable _user;
        uint _totalDraw;
        uint _datetime;
        uint _draw_edition;
        uint _ticketnumber;
        uint _prizetype; //1 = Super Draw  or 2 = Draw Express
    }
    mapping(address => Winners[]) public mapwinners;


    struct DrawStructure {
        uint _start;
        uint _close;
        uint _edition;
        uint _prize;
        uint _tickets;
    }

    //********SUPER DRAW SETTINGS*********
    uint public draw_edition = 0; //Each open draw adds one edition
    mapping(uint => DrawStructure) public history_superdraw;
    uint public percent_draw = 10; //allocation percentage for the super draw
    uint public target_amount_default = 300000; //300.000 tickets default to super draw
    uint public target_amount = target_amount_default; //total ticket to complete the super draw
    uint public amount_draw; // total accumulated for super draw prize
    bool public isGameEnded = true;
    bool public isReadyPickWinner = false;
    uint public draw_periods = 180 days;
    address[] public  players;
    address[] public  winners;
    mapping(address => PlayerStructure[]) public purchase;
    //********END SUPER DRAW SETTINGS*********

    //********DRAW EXPRESS SETTINGS*********
    uint public express_draw_edition = 0; //Each open draw adds one edition
    mapping(uint => DrawStructure) public history_expressdraw;
    uint public express_percent_draw = 10; //allocation percentage for the super draw
    uint public express_target_amount_default = 600;
    uint public express_target_amount = target_amount_default; //total ticket to complete the super draw
    uint public express_amount_draw; // total accumulated for super draw prize
    bool public express_isGameEnded = true;
    bool public express_isReadyPickWinner = false;
    uint public express_draw_periods = 5 days;
    address[] public  players_express;
    address[] public  express_winners;
    mapping(address => PlayerStructure[]) public express_purchase;
    //********END DRAW EXPRESS SETTINGS*********

    // price of ticket = 0.02 BNB
    uint public ticket_price = 0.02 * 10 ** 18;

    address payable public team_address;
    uint public max_buy_player = 1000; //max per purchase

    //Allocations
    uint public percent_doubleprize = 50; //allocation percentage for the prize
    uint public percent_affiliate = 10; //percent affiliate commission
    uint public percent_company = 20; //allocation percentage for the prize

    address payable address_doubleprize;
    address address_affiliate;
    uint levels_affiliate = 2;

    // add event
    event PickWinner(address indexed winner, uint amount, uint date, uint draw_edition, uint number_ticket );
    event NewPlayer(address indexed player, uint tickets);

    // constructor
    constructor(address payable address_contract_doubleprize, address address_contract_affiliate)
    {
        address_doubleprize = address_contract_doubleprize;
        address_affiliate = address_contract_affiliate;

        // define administrator with deployer
        manager = msg.sender;
        team_address = payable(msg.sender);

        isGameEnded = true;
        initialize(); //initialize super draw
        express_initialize(); //initialize express draw

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
    function MegaLottoTicket(address payable _addrinviter, address payable _addrplayer) public payable onGame{

        uint total_ticket = msg.value.div(ticket_price);
        require(total_ticket >= 1,"you need to buy 1 or more of a ticket"); //Checks if total ticket is >= 1
        require(total_ticket <= max_buy_player,"the maximum number of tickets per purchase has been exceeded"); //Checks if total ticket is >= 1

        //*******ADD PLAYER TO LIST
        uint _ticketPlay = 1;
        while (_ticketPlay <= total_ticket){
            //******LIST SUPWER DRAW
            uint totalPlayers = players.length;
            players.push(_addrplayer);
            purchase[_addrplayer].push(PlayerStructure(payable(_addrplayer), block.timestamp, ticket_price, totalPlayers, draw_edition));
            target_amount -= 1;
            //*******END SUPER DRAW

            //******LIST SUPWER DRAW
            uint totalPlayersExpress = players_express.length;
            players_express.push(_addrplayer);
            express_purchase[_addrplayer].push(PlayerStructure(payable(_addrplayer), block.timestamp, ticket_price, totalPlayersExpress, express_draw_edition));
            express_target_amount -= 1;
            //*******END SUPER DRAW

            _ticketPlay++;
        }
        //*******END PLAYER TO LIST

        team_address.transfer(msg.value.mul(percent_company).div(100)); //SENT COMPANY FUNDS

        amount_draw += msg.value.mul(percent_draw).div(100); //UPDATE SUPER DRAW PRIZE
        express_amount_draw += msg.value.mul(express_percent_draw).div(100); //UPDATE DRAW EXPRESS PRIZE

        //**** START DOUBLE PRIZE
        uint value_double_prize = msg.value.mul(percent_doubleprize).div(100); //CALC AMOUNT TO DOUBLE PRIZE CONTRACT
        IDoublePrize(address_doubleprize).updatePlayers{value: value_double_prize}(payable(_addrplayer), msg.value);
        //**** END DOUBLE PRIZE

        //**** START AFFILIATE PROGRAM
        uint value_affiliate_pay = msg.value.mul(percent_affiliate).div(100); //calc amount destination to affiliate program
        IAffiliate(address_affiliate).pay{value: value_affiliate_pay}(payable(_addrplayer), 1, 100, _addrinviter);
        //**** END AFFILIATE PROGRAM

        emit NewPlayer(_addrplayer, total_ticket);

        //**** CHECK WINNERS
        uint end_draw = history_superdraw[draw_edition]._close;
        uint end_draw_express = history_expressdraw[express_draw_edition]._close;

        if(target_amount <= 0 || block.timestamp >= end_draw) {
            if (amount_draw > 0 && players.length > 0){
                isReadyPickWinner = true;
                pickWinner();
            }

        }

        if(express_target_amount <= 0 || block.timestamp >= end_draw_express) {
            if (express_amount_draw > 0 && players_express.length > 0){
                express_isReadyPickWinner = true;
                pickWinnerExpress();
            }
        }

        //**** END CHECK WINNERS

    }

    // initialize the game
    function initialize() private {
        require(isGameEnded, "Game is running now.");
        target_amount = target_amount_default;
        isGameEnded = false;
        isReadyPickWinner = false;
        draw_edition += 1;
        uint ticket_percent_target = target_amount.mul(percent_draw).div(100);
        uint total_draw = ticket_percent_target * ticket_price;

        history_superdraw[draw_edition] = DrawStructure(block.timestamp, block.timestamp + draw_periods, draw_edition, total_draw, target_amount);
    }

    function express_initialize() private {
        require(express_isGameEnded, "Game is running now.");
        express_target_amount = express_target_amount_default;
        express_isGameEnded = false;
        express_isReadyPickWinner = false;
        express_draw_edition += 1;
        uint ticket_percent_target = express_target_amount.mul(express_percent_draw).div(100);
        uint express_total_draw = ticket_percent_target * ticket_price;

        history_expressdraw[express_draw_edition] = DrawStructure(block.timestamp, block.timestamp + express_draw_periods, express_draw_edition, express_total_draw, express_target_amount);
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players)));
    }

    function pickWinner() private {

        require(isReadyPickWinner, "Game is running now."); // Check if the draw is ready for the draw

        uint rd = random();
        uint index = rd % players.length; // Searching for an address at random from the raffle participant list
        address payable winner = payable(players[index]); // setting the winner's address
        players = new address[](0); // resetting the list of attendees and tickets to zero

        winner.transfer(amount_draw);// sent super prize to winner

        isGameEnded = true;
        mapwinners[winner].push(Winners(payable(winner), amount_draw, block.timestamp, draw_edition, index, 1));
        winners.push(winner);

        emit PickWinner(winner, amount_draw, block.timestamp, index, rd);

        amount_draw = 0;

        initialize(); //start new super draw
    }

    function pickWinnerExpress() private {
        require(express_isReadyPickWinner, "Express Draw is running."); // Check if the draw is ready for the draw

        uint rd = random();
        uint index = rd % players_express.length; // Searching for an address at random from the raffle participant list
        address payable winner = payable(players_express[index]); // setting the winner's address
        players_express = new address[](0); // resetting the list of attendees and tickets to zero

        winner.transfer(express_amount_draw);// sent super prize to winner

        express_isGameEnded = true;
        mapwinners[winner].push(Winners(payable(winner), express_amount_draw, block.timestamp, express_draw_edition, index, 2));
        express_winners.push(winner);

        emit PickWinner(winner, express_amount_draw, block.timestamp, index, rd);

        express_amount_draw = 0;

        express_initialize(); //start new super draw
    }

    function updateTargetAmount(uint _amount) public onlyOwner {
        // Dedicated to the manager increasing the amount of tickets available to increase the prize draw
        target_amount = _amount;
    }

    function updateTargetAmountExpress(uint _amount) public onlyOwner {
        // Dedicated to the manager increasing the amount of tickets available to increase the prize draw
        express_target_amount = _amount;
    }

    function updateTeamAddress(address payable _address) public onlyOwner {
        // Dedicated to the manager increasing the amount of tickets available to increase the prize draw
        team_address = payable(_address);
    }

    function updateMaxPlayer(uint _amount) public onlyOwner {
        // Dedicated to the manager increasing or decreasing the maximum ticket purchase amount per player
        max_buy_player = _amount;
    }

    function getPlayers()public view returns(address[] memory){
        return players;
    }
    function getPlayersExpress()public view returns(address[] memory){
        return players_express;
    }

    function getWinners()public view returns(address[] memory){
        return winners;
    }

    function getWinnersExpress()public view returns(address[] memory){
        return express_winners;
    }

    function getWinnersList() public view returns (Winners[] memory){
        Winners[] memory w = new Winners[](getWinnersNumber());

        for (uint i = 0; i < getWinnersNumber(); i++) {
            uint totalprizes =  mapwinners[winners[i]].length;
            for (uint j = 0; j < totalprizes; j++) {
                Winners storage wr = mapwinners[winners[i]][j];
                w[i] = wr;
            }
        }
        return w;
    }

    function getMyPrizeList(address _address) public view returns (Winners[] memory){
        Winners[] memory w = new Winners[](getMyPrizesLength(_address));
        for (uint i = 0; i < getMyPrizesLength(_address); i++) {
            Winners storage wr = mapwinners[_address][i];
            w[i] = wr;
        }
        return w;
    }

    function getMyPrizeTotal(address _address) public view returns (uint){
        uint _total = 0;
        for (uint i = 0; i < getMyPrizesLength(_address); i++) {
        _total += mapwinners[_address][i]._totalDraw;
        }
        return _total;
    }

    function getPurchases(address _address) public view returns (PlayerStructure[] memory){
        PlayerStructure[] memory p = new PlayerStructure[](getTicketsByUserLength(_address));
        for (uint i = 0; i < getTicketsByUserLength(_address); i++) {
            PlayerStructure storage pr = purchase[_address][i];
            p[i] = pr;
        }
        return p;
    }

    function getPurchasesExpress(address _address) public view returns (PlayerStructure[] memory){
        PlayerStructure[] memory p = new PlayerStructure[](getTicketsByUserLength(_address));
        for (uint i = 0; i < getTicketsByUserLengthExpress(_address); i++) {
            PlayerStructure storage pr = express_purchase[_address][i];
            p[i] = pr;
        }
        return p;
    }

    function getWinnersNumber() public view returns(uint) {
        return winners.length;
    }

    function getWinnersNumberExpress() public view returns(uint) {
        return express_winners.length;
    }

    function getPlayerNumber() public view returns(uint) {
        return players.length;
    }

    function getPlayerNumberExpress() public view returns(uint) {
        return players_express.length;
    }

    function getDrawPrizeBalance() public view returns(uint) {
        return amount_draw;
    }

    function getDrawPrizeBalanceExpress() public view returns(uint) {
        return express_amount_draw;
    }

    function getTicketsByUserLength(address _addr) public view returns(uint) {
        return purchase[_addr].length;
    }

    function getTicketsByUserLengthExpress(address _addr) public view returns(uint) {
        return express_purchase[_addr].length;
    }

    function getMyPrizesLength(address _addr) public view returns(uint) {
        return mapwinners[_addr].length;
    }

    function getPercent() public view returns(uint) {
        if(isGameEnded) return 0;
        if(isReadyPickWinner) return 100;
        return getPlayerNumber() * 100 / (target_amount + getPlayerNumber());
    }

    function getPercentExpress() public view returns(uint) {
        if(express_isGameEnded) return 0;
        if(express_isReadyPickWinner) return 100;
        return getPlayerNumberExpress() * 100 / (express_target_amount + getPlayerNumberExpress());
    }

    function withdraw(address payable _to, uint _amount) public onlyOwner {
        require(_amount <= 1, 'It is only possible to withdraw from the total available to the development team');
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