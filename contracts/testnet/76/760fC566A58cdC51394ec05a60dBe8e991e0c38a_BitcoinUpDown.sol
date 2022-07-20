// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "AggregatorV3Interface.sol";
import "Ownable.sol";

contract BitcoinUpDown is Ownable {
    address private house;
    address payable[] public players;
    address payable[] public bulls;
    address payable[] public bears;

    struct Players {
        uint256 bet;
        bool isExist;
    }
    mapping(address => Players) public players_bet_up;
    mapping(address => Players) public players_bet_down;
    mapping(address => Players) public players_bet;
    AggregatorV3Interface internal btcUsdPriceFeed;
    enum BETTING_STATE {
        OPEN,
        CLOSED
    }
    enum UP_DOWN {
        UP,
        DOWN
    }
    BETTING_STATE public betting_state;
    int256 public price_open;
    int256 public price_close;
    uint256 public prize_pool;
    uint256 public prize_pool_up;
    uint256 public prize_pool_down;
    uint256 public total_winners;
    uint256 public percent;
    uint256 public ts_start;

    event eventBet(address indexed _from, uint256 amount, UP_DOWN up_down);

    constructor(address _priceFeedAddress) {
        house = msg.sender;
        btcUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        betting_state = BETTING_STATE.CLOSED;
    }

    function getPrice() public view returns (int256) {
        (, int256 price, , , ) = btcUsdPriceFeed.latestRoundData();
        return price / (10**8);
    }

    function getPlayersCount() public view returns (uint256) {
        return players.length;
    }

    function getBullsCount() public view returns (uint256) {
        return bulls.length;
    }

    function getBearsCount() public view returns (uint256) {
        return bears.length;
    }

    function reset() private {
        // reset variables for new round
        for (uint256 i = 0; i < bears.length; i++) {
            players_bet_down[bears[i]].bet = 0;
            players_bet_down[bears[i]].isExist = false;
        }
        for (uint256 i = 0; i < bulls.length; i++) {
            players_bet_up[bulls[i]].bet = 0;
            players_bet_up[bulls[i]].isExist = false;
        }

        players = new address payable[](0);
        bulls = new address payable[](0);
        bears = new address payable[](0);
        prize_pool = 0;
        prize_pool_up = 0;
        prize_pool_down = 0;
        price_open = 0;
        ts_start = 0;
    }

    function startBet() public onlyOwner {
        require(betting_state == BETTING_STATE.CLOSED, "Betting aleardy open");
        price_open = getPrice();
        ts_start = block.timestamp;
        betting_state = BETTING_STATE.OPEN;
    }

    function bet(UP_DOWN _up_down) public payable {
        require(betting_state == BETTING_STATE.OPEN, "Betting closed");
        require(msg.value >= 0.001 ether, "Minimum bet = 0.001 ~0.265$");
        require(block.timestamp - ts_start <= 3600, "Max 1 hour after start");

        players_bet[msg.sender].bet += msg.value; // keep history of all player bets / never reseted
        if (players_bet[msg.sender].isExist == false) {
            players.push(payable(msg.sender));
            players_bet[msg.sender].isExist = true;
            players_bet[msg.sender].bet += msg.value;
        }

        // player bet up or down / reseted every round
        if (_up_down == UP_DOWN.UP) {
            players_bet_up[msg.sender].bet += msg.value;
            if (players_bet_up[msg.sender].isExist == false) {
                bulls.push(payable(msg.sender));
                players_bet_up[msg.sender].isExist = true;
            }
            prize_pool_up += msg.value;
        } else if (_up_down == UP_DOWN.DOWN) {
            players_bet_down[msg.sender].bet += msg.value;
            if (players_bet_down[msg.sender].isExist == false) {
                bears.push(payable(msg.sender));
                players_bet_down[msg.sender].isExist = true;
            }
            prize_pool_down += msg.value;
        }
        prize_pool += msg.value;
        emit eventBet(msg.sender, msg.value, _up_down);
    }

    function endBet() public onlyOwner {
        require(betting_state == BETTING_STATE.OPEN, "Betting aleardy closed");
        //require(block.timestamp - ts_start >= 3600, "Min 1 hour after start");
        betting_state = BETTING_STATE.CLOSED;
    }

    function payHouse() public onlyOwner {
        payable(house).transfer(address(this).balance);
    }

    function addGas() public payable {
        require(msg.value > 0);
    }

    function declareWinners() public onlyOwner {
        require(betting_state == BETTING_STATE.CLOSED, "Betting still open");
        //require(block.timestamp - ts_start >= 1 days, "Min 1 day after start");
        price_close = getPrice();
        uint256 fee = (2 * prize_pool) / 100; // 2% fee for gas and escorts
        prize_pool -= fee;

        if (price_close >= price_open) {
            for (uint256 i = 0; i < bulls.length; i++) {
                percent = (players_bet_up[bulls[i]].bet * 100) / prize_pool_up;
                players_bet_up[bulls[i]].bet = 0; // avoid re-entrancy and reset
                bulls[i].transfer((percent * prize_pool) / 100);
            }
        } else if (price_close < price_open) {
            for (uint256 i = 0; i < bears.length; i++) {
                percent =
                    (players_bet_down[bears[i]].bet * 100) /
                    prize_pool_up;
                players_bet_down[bears[i]].bet = 0; // avoid re-entrancy and reset
                bears[i].transfer((percent * prize_pool) / 100);
            }
        }

        reset(); // reset varialbes for new round
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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