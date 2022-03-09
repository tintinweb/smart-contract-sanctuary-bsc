// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IGovernance.sol";
import "./interfaces/IRandomness.sol";
import "./interfaces/IAirdrop.sol";

contract SesameBnb is Ownable {
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public state;

    AggregatorV3Interface ethUsdPriceFeed;
    IGovernance governance;

    uint256 public round;
    address payable[] public players;
    address payable public recentWinner;

    uint256 public immutable ticketPrice;
    uint256 public immutable ticketPerRound;
    uint256 public immutable feePercent;

    uint256 public currentFees;
    uint256 public currentFund;
    uint256 public totalFeesCollected;
    uint256 public totalFeesEmitted;
    uint256 public totalFundCollected;
    uint256 public totalFundEmitted;
    uint256 private priceFeedDecimal;
    string public version;

    event StartedRound(uint256 round);
    event EndedRound(uint256 round);
    event EnterTicket(address indexed by, uint256 round, uint256 tickets);
    event DeclareWinner(address indexed user, uint256 round, uint256 price);

    constructor(
        address _governance,
        address _priceFeedAddress,
        uint256 _ticketPrice,
        uint256 _ticketPerRound,
        uint256 _feePercent,
        uint256 _priceFeedDecimal,
        string memory _version
    ) {
        state = LOTTERY_STATE.CLOSED;
        governance = IGovernance(_governance);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        ticketPrice = _ticketPrice;
        ticketPerRound = _ticketPerRound;
        feePercent = _feePercent;
        priceFeedDecimal = _priceFeedDecimal;
        version = _version;
    }

    function enter(uint256 tickets) public payable {
        require(state == LOTTERY_STATE.OPEN);
        require(tickets + players.length <= ticketPerRound);

        require(msg.value >= tickets * _netTicketPrice(), "Insufficient");
        require(msg.value <= (tickets + 1) * ticketPrice, "Overpaid");

        for (uint256 i; i < tickets; i++) {
            players.push(payable(_msgSender()));
        }

        currentFund += tickets * ticketPrice;
        currentFees += (msg.value - tickets * ticketPrice);
        emit EnterTicket(_msgSender(), round, tickets);

        if (players.length == ticketPerRound) {
            _endLottery();
        }
    }

    function getPriceFeed() public view returns (uint256) {
        return _getPriceFeed();
    }

    function _getPriceFeed() internal view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        return uint256(price) * 10**(18 - priceFeedDecimal);
    }

    function netTicketPrice() public view returns (uint256) {
        return _netTicketPrice();
    }

    function _netTicketPrice() internal view returns (uint256) {
        return ticketPrice + _feePerTicket();
    }

    function _feePerTicket() internal view returns (uint256) {
        return (ticketPrice * feePercent) / 100;
    }

    function startLottery() public onlyOwner {
        _startLottery();
    }

    function _startLottery() internal {
        require(state == LOTTERY_STATE.CLOSED);
        round++;
        state = LOTTERY_STATE.OPEN;
        emit StartedRound(round);
    }

    function endLottery() public onlyOwner {
        _endLottery();
    }

    function _endLottery() internal {
        state = LOTTERY_STATE.CALCULATING_WINNER;
        IRandomness(governance.randomness()).requestRandomness();
        emit EndedRound(round);
    }

    function pickWinner(uint256 rand) external {
        require(state == LOTTERY_STATE.CALCULATING_WINNER);
        require(_msgSender() == governance.randomness());
        uint256 indexOfWinner = rand % players.length;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(currentFund);
        payable(owner()).transfer(currentFees);
        // TODO: collect and distribute fees
        emit DeclareWinner(recentWinner, round, currentFund);
        _reset();
    }

    function _reset() internal {
        totalFeesEmitted += currentFees;
        totalFundEmitted += currentFund;
        totalFeesCollected += currentFees;
        totalFundCollected += currentFund;
        currentFees = 0;
        currentFund = 0;

        players = new address payable[](0);
        state = LOTTERY_STATE.CLOSED;
        _startLottery();
    }

    function getPlayersCount() public view returns (uint256 count) {
        return players.length;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
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
pragma solidity ^0.8.7;

interface IGovernance {
    function isLottery(address _lottery) external view returns (bool);

    function randomness() external view returns (address);

    function airdrop() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRandomness {
    function requestRandomness() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IAirdrop {
    function enter(address _user, uint256 _amount) external;

    function processAirdrop() external;

    function lastAirdropBlock() external returns (uint256);
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