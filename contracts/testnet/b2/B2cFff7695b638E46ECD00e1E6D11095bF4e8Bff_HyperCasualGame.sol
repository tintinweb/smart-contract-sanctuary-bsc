// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library CeilDiv {
  // calculates ceil(x/y)
  function ceildiv(uint256 x, uint256 y) internal pure returns (uint256) {
    if (x > 0) return ((x - 1) / y) + 1;
    return x / y;
  }
}

/// @title Game Contract Factory
contract HyperCasualGame is Ownable {

  using SafeMath for uint256;
  using CeilDiv for uint256;

  uint256 gameIndex; // the number of games that have been created
  IERC20 public token; // token used for betting in the game
  address keeper; // receiver of users tokens
  uint256 public entryFee; // required entry fee to start a new game
  uint256 public waitingTime; // the number of day(s) a game creator must wait to cancel the game
  uint256[] gameIDs; // all IDs of the games that have been created
  mapping(uint256 => Game) games; // all games' information

  enum Outcome {
    decided,
    draw
  }

  enum GameState {
    open,
    joined,
    cancelled,
    decided
  }

  // ------ Enum End ------
  
  struct Game {
    address creator;
    address challenger;
    uint256 entryFee;
    bytes32[] requests;
    uint256[] scores;
    uint256 requestDate;
    uint256 matchedDate;
    GameState state;
  }

  // ------ Structures End ------

   modifier mustBeCreator(uint256 gameId) {
    Game memory gameInfo = games[gameId];
    require(msg.sender != address(0), "Invalid address");
    require(msg.sender == gameInfo.creator, "Sender not the game creator");
    _;
  }

  modifier mustBeOpened(uint256 gameId) {
    Game memory gameInfo = games[gameId];
    require(gameInfo.state == GameState.open, "Game is no longer open for match");
    _;
  }

  modifier mustHaveExpiredWaitingTime(uint256 gameId) {
    Game memory gameInfo = games[gameId];
    require(now >= gameInfo.requestDate + (waitingTime * 1 days), "Game is still within the waiting time");
    _;
  }

  event EntryFeeChanged(uint256 newEntryFee);
  event WaitingTimeChanged(uint256 numOfDays);
  event MatchRequested(address player, uint256 gameId, uint256 entryFee);
  event MatchJoined(uint256 gameId, address player, uint256 entryFee);
  event MatchCreated(uint256 gameId, uint256 entryFee, address player1, address player2, bytes32 player1Request, bytes32 player2Request, uint256 player1Score, uint256 player2Score);
  event KeeperChanged(address newKeeper);
  event GameCancelled(uint256 gameId);
  // event GameApproved(address player, uint256 entryFeeTokens);
  // ------ Events End ------


  /// @dev Constructor that is run once during the contract deployment
  constructor(IERC20 _token, uint256 _entryFee, uint256 _waitingTime, address _keeper) public {
    token = _token;
    entryFee = _entryFee.mul(10 ** 18);
    waitingTime = _waitingTime; // * 1 days;
    gameIndex = 0;
    keeper = _keeper;

    emit EntryFeeChanged(_entryFee);
    emit WaitingTimeChanged(_waitingTime);
  }

  /**
     *
     * NOTE: changeEntryFee enables an administraor to increase/reduce the entry fee
     * the admin must the deployer of the smart contract
     */
  function changeEntryFee(uint256 newEntryFee) external onlyOwner() {
    require(msg.sender != address(0), "Invalid address");
    entryFee = newEntryFee.mul(10 ** 18);

    emit EntryFeeChanged(newEntryFee);
  }

  /**
     *
     * NOTE: changeEntryFee enables an administraor to increase/reduce the entry fee
     * the admin must the deployer of the smart contract
     */
  function changeWaitingTime(uint256 newWaitingTime) external onlyOwner() {
    require(msg.sender != address(0), "Invalid address");
    waitingTime = newWaitingTime;

    emit WaitingTimeChanged(newWaitingTime);
  }

  /**
     *
     * NOTE: changeEntryFee enables an administraor to increase/reduce the entry fee
     * the admin must the deployer of the smart contract
     */
  function changeKeeper(address payable newKeeper) external onlyOwner() {
    require(msg.sender != address(0), "Invalid address");
    keeper = newKeeper;

    emit KeeperChanged(newKeeper);
  }

  /**
     * @dev Returns gameId.
     *
     * NOTE: requestMatch enables a new user to request a match
     * the user must have approved this contract
     */
  function requestMatch() external returns (uint256) {
    uint256 gameId = gameIndex;
    gameIDs.push(gameId);

    Game storage game = games[gameId];

    game.creator = msg.sender;
    game.entryFee = entryFee;
    game.state = GameState.open;
    game.requestDate = now;

    uint256 approvedAllowance = token.allowance(msg.sender, address(this));
    require(msg.sender != address(0), "Invalid address");
    require(approvedAllowance >= entryFee, "Not enough token allowance");
    token.transferFrom(msg.sender, address(this), entryFee);

    emit MatchRequested(msg.sender, gameId, entryFee);

    gameIndex = gameIndex.add(1);
    return gameId;
  }

    /**
     * @dev Returns gameId.
     *
     * NOTE: joinMatch enables a new user to join a match already created
     * the user must have approved this contract
     */
  function joinMatch(uint256 gameId) external {

    Game storage game = games[gameId];

    require(game.state == GameState.open, "Game no longer available to be joined");

    game.challenger = msg.sender;
    game.state = GameState.joined;

    uint256 approvedAllowance = token.allowance(msg.sender, address(this));
    require(msg.sender != address(0), "Invalid address");
    require(approvedAllowance >= game.entryFee, "Not enough token allowance");
    token.transferFrom(msg.sender, address(this), game.entryFee);

    emit MatchJoined(gameId, msg.sender, game.entryFee);
  }

  /**
     * @dev Returns gameId.
     *
     * NOTE: startNewGame enables a new user to initiate a new game
     * the user must have enough tokens and must not be have been blacklisted.
     * TODO: use oracles to check if the deposit transaction is valid
     * TODO: remove unsecure access/tokenHash
     */
  function createMatch(uint256 gameId, bytes32 player1Request, bytes32 player2Request, uint256 player1Score, uint256 player2Score) external onlyOwner() returns (uint256) {

    Game storage game = games[gameId];

    // game.creator = player1;
    // game.challenger = player2;
    // game.entryFee = entryFee;
    game.requests.push(player1Request);
    game.requests.push(player2Request);
    game.scores.push(player1Score);
    game.scores.push(player2Score);
    game.matchedDate = now;

    (uint256 winnerBonus, uint256 adminBonus) = getBonuses(entryFee);
    if (player1Score == player2Score) {
      // game.state = Outcome.draw;
    } else {
      game.state = GameState.decided;
      if (player1Score > player2Score) {
        token.transfer(game.creator, winnerBonus);
        token.transfer(keeper, adminBonus);
      } else {
        token.transfer(game.challenger, winnerBonus);
        token.transfer(keeper, adminBonus);
      }
    }

    emit MatchCreated(gameId, entryFee, game.creator, game.challenger, player1Request, player2Request, player1Score, player2Score);
  }

  /**
     * @dev Cancel an opened game if the checks are successful.
     *
     * NOTE: cancelGame enables a user (creator) to cancel her game
     * provided that the game is still opened.
     * provided that it is opened for not less than 48 hours (waitingTime)
     * TODO - RETURN THE DEPOSIT IF THE CANCEL IS SUCCESSFUL (FRONT-END)
     * TODO - OR KEEPER CAN APPROVE THE CONTRACT TO DO TRANSFER FROM
     */
  function cancelGame(uint256 gameId) external mustBeCreator(gameId) mustBeOpened(gameId) mustHaveExpiredWaitingTime(gameId) {
    Game storage game = games[gameId];

    game.state = GameState.cancelled;

    token.transfer(msg.sender, game.entryFee);

    emit GameCancelled(gameId);
    
  }

  /**
     * @dev return a specific game data.
     *
     */
  function getGameDetails(uint256 gameId) external view returns (address, address, uint256, bytes32[] memory, uint256[] memory, GameState) {
    Game memory theGame = games[gameId];
    
    return (
      theGame.creator,
      theGame.challenger,
      theGame.entryFee,
      theGame.requests,
      theGame.scores,
      theGame.state
    );
  }

  /**
     * @dev return all games IDs.
     *
     */
  function getAllGames() external view returns (uint256[] memory) {
    return gameIDs;
  }

  /**
     * @dev return game outcome.
     *
     */
  function getScores(uint256 gameId) external view returns (uint256[] memory) {
    Game storage theGame = games[gameId];
    return theGame.scores;
  }

  /**
     * @dev return the winner for a game.
     *
     */
  function getBonuses(uint256 fee) public pure returns (uint256, uint256) {
    uint256 adminBonus = CeilDiv.ceildiv(fee, 2);
    uint256 winnerBonus = fee.add(adminBonus);

    return (winnerBonus, adminBonus);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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