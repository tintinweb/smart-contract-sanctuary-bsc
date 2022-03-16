// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IAccountant.sol";
import "./interfaces/IGovernance.sol";
import "./interfaces/IProduct.sol";
import "./interfaces/IRandomNumberGenerator.sol";
import "./interfaces/IWBNB.sol";

contract SesameNativeAsync is IProduct {
    enum STATE {
        CLOSED,
        OPEN,
        CALCULATING
    }
    mapping(uint256=>STATE) public state;

    IGovernance public immutable governance;
    AggregatorV3Interface public immutable priceFeed;
    IWBNB public immutable token;

    uint256 public round;
    mapping(uint256=>address[]) public tickets;
    mapping(uint256 => mapping(address => uint256)) public ticketMap;
    mapping(uint256 => address) public winner;

    uint256 public immutable ticketPrice;
    uint256 public immutable ticketPerRound;
    uint256 public immutable feePercent;

    uint256 public currentFees;
    uint256 public currentFund;
    uint256 public totalFeesCollected;
    uint256 public totalFeesEmitted;
    uint256 public totalFundCollected;
    uint256 public totalFundEmitted;
    string public version;

    event StartedRound(uint256 indexed round);
    event EndedRound(uint256 indexed round);
    event EnterTicket(
        address indexed by,
        uint256 indexed round,
        uint256 tickets
    );
    event DeclareWinner(
        address indexed winner,
        uint256 indexed round,
        uint256 price
    );

    constructor(
        address _governance,
        address _token,
        address _priceFeed,
        uint256 _ticketPrice,
        uint256 _ticketPerRound,
        uint256 _feePercent,
        string memory _version
    ) {
        governance = IGovernance(_governance);
        token = IWBNB(_token);
        priceFeed = AggregatorV3Interface(_priceFeed);
        ticketPrice = _ticketPrice;
        ticketPerRound = _ticketPerRound;
        feePercent = _feePercent;
        version = _version;
    }

    /**
     * @notice Players enters the current round and pays
     * for the number of tickets in native currency
     * @param ticket Number of tickets to enter
     */
    function enter(uint256 ticket) public payable {
        require(state[round] == STATE.OPEN, "Not open");
        require(ticket + tickets[round].length <= ticketPerRound, "Too many ticket");
        require(msg.value == ticket * netTicketPrice(), "Incorrect amount");

        for (uint256 i; i < ticket; i++) {
            tickets[round].push(msg.sender);
        }

        currentFund += ticket * ticketPrice;
        currentFees += ticket * feePerTicket();
        totalFundCollected += ticket * ticketPrice;
        totalFeesCollected += ticket * feePerTicket();

        ticketMap[round][msg.sender] += ticket;

        IAccountant accountant = IAccountant(governance.accountant());
        uint256 credit = getCredit(ticket * netTicketPrice());
        accountant.credit(msg.sender, credit, round, ticket);
        emit EnterTicket(msg.sender, round, ticket);
        if (tickets[round].length == ticketPerRound) {
            _endRound();
        }
    }

    /** @notice Convert players' deposit to USD at market price */
    function getCredit(uint256 amount) public view returns (uint256) {
        return (amount * getPriceFeed()) / 1 ether;
    }

    /** @notice Get token price quote in USD (18 decimals) */
    function getPriceFeed() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10**10;
    }

    /** @notice Price and fee for each ticket */
    function netTicketPrice() public view returns (uint256) {
        return ticketPrice + feePerTicket();
    }

    /** @notice Fee for each ticket */
    function feePerTicket() public view returns (uint256) {
        return (ticketPrice * feePercent) / 100;
    }

    /** @notice Activate product, only callable from governance */
    function activate() external override {
        require(msg.sender == address(governance), "Unauthorized");
        _startRound();
    }

    /** @notice Emergency: deactivate product, only callable from governance */
    function deactivate() external override {
        require(msg.sender == address(governance), "Unauthorized");
        _refund(round);
        _closeRound(round);

        // retrieve any remaining balance to avoid being trapped
        token.transfer(governance.feeCollector(), token.balanceOf(address(this)));
        payable(governance.feeCollector()).transfer(address(this).balance);
    }

    /** @notice Refund players of current round */
    function _refund(uint256 _round) internal {
        for (uint256 i; i < tickets[_round].length; i++) {
            address player = tickets[_round][i];
            uint256 amount = ticketMap[_round][player] * netTicketPrice();
            if (amount > 0) {
                payable(player).transfer(amount);
                ticketMap[_round][player] = 0;
            }
        }
        totalFeesCollected -= currentFees;
        totalFundCollected -= currentFund;
        currentFees = 0;
        currentFund = 0;
    }

    /** @notice Start a new round */
    function _startRound() internal {
        round++;
        state[round] = STATE.OPEN;
        emit StartedRound(round);
    }

    /**
     * @notice Reached current round limit. Stop accepting
     * more ticket. Request random number.
     */
    function _endRound() internal {
        state[round] = STATE.CALCULATING;
        IRandomNumberGenerator(governance.randomNumberGenerator())
            .requestRandomNumber(round);
        _startRound();
    }

    /**
     * @notice Callback for the random number generator
     * @param _rand Arary of random numbers
     */
    function pickWinner(uint256[] memory _rand, uint256 _round) external override {
        require(state[_round] == STATE.CALCULATING);
        require(msg.sender == governance.randomNumberGenerator());
        uint256 indexOfWinner = _rand[0] % ticketPerRound;
        address _winner = tickets[_round][indexOfWinner];
        winner[_round] = _winner;

        uint256 toWinner = currentFund;
        currentFund = 0;
        totalFundEmitted += toWinner;
        payable(_winner).transfer(toWinner);

        // Convert to reward token before transmit
        uint256 toShare = currentFees;
        currentFees = 0;
        totalFeesEmitted += toShare;
        token.deposit{value: toShare}();
        token.transfer(governance.feeCollector(), toShare);

        emit DeclareWinner(_winner, _round, currentFund);
        emit EndedRound(_round);

        _closeRound(_round);
    }

    /** @notice Update state params and mark current round closed */
    function _closeRound(uint256 _round) internal {
        state[_round] = STATE.CLOSED;
    }

    /** @notice Number of tickets in current round */
    function getTicketCount() public view returns (uint256 count) {
        return tickets[round].length;
    }

    /** @notice Number of tickets bought by player at given round */
    function getUserTicketCount(uint256 _round, address _player)
        public
        view
        returns (uint256 count)
    {
        return ticketMap[_round][_player];
    }

    function recentWinner() public view returns (address) {
        return winner[round - 1];
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

interface IAccountant {
    function credit(
        address player,
        uint256 point,
        uint256 round,
        uint256 ticket
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IGovernance {
    function isVoter(address _voter) external view returns (bool);

    function isProduct(address _product) external view returns (bool);

    function accountant() external view returns (address);

    function feeCollector() external view returns (address);

    function randomNumberGenerator() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IProduct {
    function pickWinner(uint256[] memory _rand, uint256 _round) external;

    function activate() external;

    function deactivate() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRandomNumberGenerator {
    function setGovernance(address _governance) external;

    function requestRandomNumber(uint256 _round) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);
}