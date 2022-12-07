// File: @chainlink/contracts-0.0.10/src/v0.5/interfaces/AggregatorInterface.sol

pragma solidity >=0.5.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// File: @chainlink/contracts-0.0.10/src/v0.5/interfaces/AggregatorV3Interface.sol

pragma solidity >=0.5.0;

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

// File: @chainlink/contracts-0.0.10/src/v0.5/interfaces/AggregatorV2V3Interface.sol

pragma solidity >=0.5.0;



/**
 * @title The V2 & V3 Aggregator Interface
 * @notice Solidity V0.5 does not allow interfaces to inherit from other
 * interfaces so this contract is a combination of v0.5 AggregatorInterface.sol
 * and v0.5 AggregatorV3Interface.sol.
 */
interface AggregatorV2V3Interface {
  //
  // V2 Interface:
  //
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);

  //
  // V3 Interface:
  //
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

// File: openzeppelin-solidity/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/hznAggregator.sol

pragma solidity ^0.5.16;

contract HznAggregatorV2V3 is AggregatorV2V3Interface {
    using SafeMath for uint;
    // using SafeDecimalMath for uint;

    uint public roundID = 0;
    uint public keyDecimals = 0;
    //here we simplify the window size as how many rounds we use to calculate th TWAP
    uint public windowSize = 0;
    string public description;
    

    struct Entry {
        uint roundID;
        uint answer;
        uint originAnswer;
        uint startedAt;
        uint updatedAt;
        uint answeredInRound;
        uint priceCumulative;
    }

    mapping(uint => Entry) public entries;
    address owner;
    address operator;

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    // event AnswerUpdated(uint256 indexed answer, uint256 timestamp);

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    modifier onlyOperator {
        _onlyOperator();
        _;
    }

    function _onlyOperator() private view {
        require(msg.sender == operator, "Only the contract owner may perform this action");
    }

    constructor(address _owner,
                uint _decimals,
                uint _windowSize,
                address _operator,
                string memory _description) public {
        owner = _owner;
        keyDecimals = _decimals;
        windowSize = _windowSize;
        operator = _operator;
        description = _description;
    }

    //========  setters ================//
    function setDecimals(uint _decimals) external onlyOwner {
        keyDecimals = _decimals;
    }

    function setWindowSize(uint _windowSize)external onlyOwner  {
        windowSize = _windowSize;
    }

    function setLatestAnswer(uint answer) external onlyOperator {
        if (roundID > 0){
            roundID++;
        }
        entries[roundID] = calculateTWAP(roundID,answer,now);
        emit AnswerUpdated(int(answer), answer,now);
    }

    //====================interface ==================================
    function latestAnswer() external view returns (int256) {
        Entry memory entry = entries[roundID];
        return int256(entry.answer);
    }

    function latestTimestamp() external view returns (uint256){
        Entry memory entry = entries[roundID];
        return entry.updatedAt;
    }



    function latestRoundData()
        external
        view
        returns (
           uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        return getRoundData(uint80(latestRound()));
    }

    function latestRound() public view returns (uint256) {
        return roundID;
    }

    function decimals() external view returns (uint8) {
        return uint8(keyDecimals);
    }

    function version() external view returns (uint256){
        return 1;
    }

    function getAnswer(uint256 _roundId) external view returns (int256) {
        Entry memory entry = entries[_roundId];
        return int256(entry.answer);
    }

    function getTimestamp(uint256 _roundId) external view returns (uint256) {
        Entry memory entry = entries[_roundId];
        return entry.updatedAt;
    }

    function getRoundData(uint80 _roundId)
        public
        view
        returns (
           uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        Entry memory entry = entries[_roundId];
        // Emulate a Chainlink aggregator
        require(entry.updatedAt > 0, "No data present");
        return (uint80(entry.roundID), int256(entry.answer), entry.startedAt, entry.updatedAt, uint80(entry.answeredInRound));
    }


    function calculateTWAP(uint currentRoundId,uint answer,uint timestamp) internal view returns(Entry memory) {
        if (currentRoundId == 0 ){
            return  Entry({
                roundID: currentRoundId,
                answer: answer,
                originAnswer: answer,
                startedAt: timestamp,
                updatedAt: timestamp,
                answeredInRound: currentRoundId,
                priceCumulative: 0
            });
        }
        uint firstIdx = 0;
        if (windowSize >= currentRoundId) {
            firstIdx = 0;
        }else{
            firstIdx = currentRoundId - windowSize + 1;
        }
        Entry memory first = entries[firstIdx];
        Entry memory last = entries[currentRoundId - 1];

        if (first.roundID == last.roundID){
            return  Entry({
                roundID: currentRoundId,
                answer: answer,
                originAnswer: answer,
                startedAt: timestamp,
                updatedAt: timestamp,
                answeredInRound: currentRoundId,
                priceCumulative: last.priceCumulative.add(answer.mul(timestamp.sub(first.updatedAt)))
            });
        }

        uint current_priceCumulative = last.priceCumulative.add(answer.mul(timestamp.sub(last.updatedAt)));
        uint current_answer = (current_priceCumulative.sub(first.priceCumulative)).div(timestamp.sub(first.updatedAt));
        return Entry({
            roundID: currentRoundId,
            answer: current_answer,
            originAnswer: answer,
            startedAt: timestamp,
            updatedAt: timestamp,
            answeredInRound: currentRoundId,
            priceCumulative: current_priceCumulative
        });

    }
}