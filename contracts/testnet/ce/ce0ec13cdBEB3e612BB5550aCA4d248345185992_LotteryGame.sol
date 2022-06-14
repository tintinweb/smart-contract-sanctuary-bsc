// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./SafeMath.sol";
import "./IERC20.sol";

contract LotteryGame {
  using SafeMath for uint256;

  // address payable private token;
  IERC20 private token;
  address payable public dealer;
  uint8 public maxPlayer;
  mapping(uint => Game) public games;
  mapping(uint => mapping(address => Bet)) public bets;
  mapping(uint => address payable[]) public winners;
  uint public gameId;

  enum State {
    EMPTY,
    CREATED,
    PLAYING,
    CLOSED
  }

  struct Game {
    uint id;
    uint bet;
    State state;
    uint counter;
    address payable[] players;
  }

  struct Bet {
    bytes32 hash;
    uint value;
  }

  event WinnerTransfer(
      address indexed winner,
      uint256 value
  );

  event DealerTransfer(
      address indexed dealer,
      uint256 value
  );

  event StopGame(
    uint id,
    uint result
  );

  constructor(address payable _token, uint8 _maxPlayer) {
    maxPlayer = _maxPlayer;
    token = IERC20(_token);
    dealer = payable(msg.sender);
  }

  function getBalance() view public returns(uint){
    return token.balanceOf(address(this));
      // return address(this).balance;
  }

  function getGame(uint _gameId) 
    external 
    view 
    returns(uint, uint, address[] memory, State) {
      Game storage game = games[_gameId];
      require(game.state != State.EMPTY, 'game has not created yet!');
      address[] memory players = new address[](game.counter);
      for (uint i = 0; i < game.counter; i++) {
        players[i] = game.players[i];
      }
      return (
        game.id,
        game.bet,
        players,
        game.state
      );
    }

  function createGame(uint _bet) 
    external 
    onlyDealer() {
    uint _gameId = gameId >= 1 ? gameId -1 : 0;
    if (games[_gameId].state != State.EMPTY) {
      require(games[_gameId].state == State.CLOSED, 'current game must be closed.');
    }
    require(_bet > 0, 'Bet cost must be higer than 0');
    address payable[] memory players = new address payable[](0);
    Game memory _game = Game(
      gameId,
      _bet,
      State.CREATED, 
      0,
      players
    );
    games[gameId] = _game;
    gameId++;
  }


  function bet(uint _gameId, uint8 value, uint8 salt) 
    validatedGameId(_gameId)
    gameOnReady(_gameId) 
    payable
    external {
    Game storage game = games[_gameId];
    // require not dealer
    require(msg.sender != dealer, 'dealer cannot play the game');
    // Approval and balance > game.bet
    require(token.allowance(msg.sender, address(this)) >= game.bet, "Amount of token is not approved");
    // Not enough token sent for betting
    require(token.balanceOf(msg.sender) >= game.bet, 'Balance insuficient funds');
    // require betting value from 00 -> 99
    require(value <= 99, 'Betting number must from 0 to 99');
    // require bet one time.
    require(bets[_gameId][msg.sender].hash == 0, 'bet already made');
    // require max < 100
    require(game.counter < maxPlayer, 'max players');
    
    game.counter++;
    game.players.push(payable(msg.sender));
    if (game.state == State.CREATED){
      game.state = State.PLAYING;
    }
    bets[_gameId][msg.sender] = Bet(keccak256(abi.encodePacked(value, salt)), value);

    // Transfer money
    token.transferFrom(msg.sender, address(this), game.bet);
  }

  // stop the game
  function stopGame(uint _gameId) 
    validatedGameId(_gameId)
    gameOnReady(_gameId) 
    onlyDealer() 
    payable
    external {
    Game storage game = games[_gameId];
    
    // Close state
    game.state = State.CLOSED;
    // Get two character last in blockNumber
    uint result = block.number % 100;
    uint totalPrice = game.counter.mul(game.bet);
    // Find who pick the block number
    for(uint i = 0; i < game.players.length; i++) {
        address payable player = game.players[i];
        if(bets[_gameId][player].value == result) {
          winners[_gameId].push(player);
        }
      }

    emit StopGame(_gameId, result);
    if (totalPrice > 0) {
      _releaseMoney(_gameId, totalPrice);
    }
  }

  function _releaseMoney(uint _gameId, uint totalPrice) private {
    // Transfer money
    if (winners[_gameId].length == 0) {
      token.transfer(dealer, totalPrice);
      emit DealerTransfer(dealer, totalPrice);
    } 
    else {
      uint dealerProfit = totalPrice.div(10);
      uint winnerProfit = totalPrice.sub(dealerProfit);
      uint profitPerWinner = winnerProfit.div(winners[_gameId].length);

      token.transfer(dealer, dealerProfit);
      emit DealerTransfer(dealer, dealerProfit);
      for (uint i = 0; i < winners[_gameId].length; i++) {
        token.transfer(winners[_gameId][i], profitPerWinner);
        emit WinnerTransfer(winners[_gameId][i], profitPerWinner);
      }
    }
  }

  modifier validatedGameId(uint _gameId) {
    require(games[_gameId].state != State.EMPTY, 'This game have not created!');
    _;
  }

  modifier gameOnReady(uint _gameId) {
    State state = games[_gameId].state;
    require(state == State.CREATED || state == State.PLAYING, 'This game has closed!');
    _;
  }

  modifier onlyDealer() {
    require(msg.sender == dealer, 'only dealer authorized');
    _;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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