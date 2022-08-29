// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "AggregatorV3Interface.sol";
import "Ownable.sol";

contract BitcoinUpDown is Ownable {
    enum UP_DOWN {
        UP,
        DOWN
    }
    struct Players {
        uint256 bet;
        UP_DOWN up_down;
        uint256 round;
        bool isExist;
    }
    mapping(address => Players) public players_bet;
    AggregatorV3Interface internal btcUsdPriceFeed;
    uint256 public round;
    UP_DOWN[] public roundWinner;
    int256 public price_open;
    int256 public price_close;
    uint256[] public prize_pool;
    uint256[] public prize_pool_up;
    uint256[] public prize_pool_down;
    uint256 public ts_start;
    uint256 private fee;
    address private dev;

    event eventStartRound(
        uint256 indexed round,
        uint256 indexed ts_start,
        int256 price_open
    );
    event eventBet(
        uint256 indexed round,
        address indexed from,
        uint256 amount,
        UP_DOWN up_down
    );
    event eventDeclareWinners(
        uint256 indexed round,
        uint256 indexed ts_close,
        int256 price_close,
        uint256 prize_pool,
        uint256 prize_pool_up,
        uint256 prize_pool_down
    );

    constructor(address _priceFeedAddress) {
        dev = msg.sender;
        btcUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        _startRound();
    }

    function getPrice() public view returns (int256) {
        (, int256 price, , , ) = btcUsdPriceFeed.latestRoundData();
        return price / (10**8);
    }

    function getPendingWithdraw(address _addr) public view returns (uint256) {
        if (players_bet[_addr].isExist == false) {
            return 0;
        }
        if (players_bet[_addr].round == round) {
            return 0; // Round still going
        }

        uint256 bet_round = players_bet[_addr].round;
        if (players_bet[_addr].up_down != roundWinner[bet_round]) {
            return 0; // Loser
        }

        // calculate the amount depending of player bet ratio to prizepool
        uint256 amount;
        if (players_bet[_addr].up_down == UP_DOWN.UP) {
            amount =
                (((players_bet[_addr].bet * 100) /
                    prize_pool_up[players_bet[msg.sender].round]) *
                    prize_pool[players_bet[msg.sender].round]) /
                100;
        } else {
            amount =
                (((players_bet[_addr].bet * 100) /
                    prize_pool_down[players_bet[_addr].round]) *
                    prize_pool[players_bet[_addr].round]) /
                100;
        }

        return amount;
    }

    function _startRound() private {
        prize_pool.push(0);
        prize_pool_up.push(0);
        prize_pool_down.push(0);
        price_open = getPrice();
        ts_start = block.timestamp;
        emit eventStartRound(round, ts_start, price_open);
    }

    function bet(UP_DOWN _up_down) public payable {
        require(msg.value >= 0, "Minimum bet = 1 wei");
        require(block.timestamp - ts_start <= 3600, "Max 1 hour after start");

        if (players_bet[msg.sender].isExist == true) {
            if (players_bet[msg.sender].round == round) {
                // Player have aleardy bet this round
                revert("Only 1 bet by round");
            } else if (
                players_bet[msg.sender].up_down ==
                roundWinner[players_bet[msg.sender].round]
            ) {
                // Player have pending withdrawal
                revert("Pending withdrawal");
            }
        }

        // if player doesn't exist yet we add the player
        players_bet[msg.sender].bet = msg.value;
        players_bet[msg.sender].up_down = _up_down;
        players_bet[msg.sender].round = round;
        players_bet[msg.sender].isExist = true;

        // add the amount to the prizpool
        if (_up_down == UP_DOWN.UP) {
            prize_pool_up[round] += msg.value;
        } else if (_up_down == UP_DOWN.DOWN) {
            prize_pool_down[round] += msg.value;
        }
        prize_pool[round] += msg.value;
        emit eventBet(round, msg.sender, msg.value, _up_down);
    }

    function withdraw() public {
        require(
            players_bet[msg.sender].isExist == true,
            "Player doesn't exist"
        );
        require(players_bet[msg.sender].round < round, "Round still going");
        require(
            players_bet[msg.sender].up_down ==
                roundWinner[players_bet[msg.sender].round],
            "Loser"
        );
        players_bet[msg.sender].isExist = false;
        // prize_pool up or down
        uint256 amount;
        if (players_bet[msg.sender].up_down == UP_DOWN.UP) {
            amount =
                (((players_bet[msg.sender].bet * 100) /
                    prize_pool_up[players_bet[msg.sender].round]) *
                    prize_pool[players_bet[msg.sender].round]) /
                100;
        } else {
            amount =
                (((players_bet[msg.sender].bet * 100) /
                    prize_pool_down[players_bet[msg.sender].round]) *
                    prize_pool[players_bet[msg.sender].round]) /
                100;
        }
        (bool sent, bytes memory data) = msg.sender.call{value: amount}("");
        require(sent, "Withdraw failed"); // dev:withdraw failed
    }

    function withdrawFee() public {
        (bool sent, bytes memory data) = dev.call{value: fee}("");
        require(sent); // dev:withdraw fee failed
    }

    function declareWinners() public {
        //require(block.timestamp - ts_start >= 1 days, "Min 1 day after start");
        UP_DOWN up_down;
        price_close = getPrice();
        prize_pool[round] -= ((1 * prize_pool[round]) / 100); // 1% gas tax

        if (price_close >= price_open) {
            up_down = UP_DOWN.UP;
            roundWinner.push(up_down);
        } else if (price_close < price_open) {
            up_down = UP_DOWN.DOWN;
            roundWinner.push(up_down);
        }

        fee += ((1 * prize_pool[round]) / 100);

        emit eventDeclareWinners(
            round,
            block.timestamp,
            price_close,
            prize_pool[round],
            prize_pool_up[round],
            prize_pool_down[round]
        );

        // Reset variables for new round
        round += 1;
        _startRound(); // New round
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