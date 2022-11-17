// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "@binance-oracle/binance-oracle-starter/contracts/interfaces/FeedRegistryInterface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./AtlantisPriceOracleProxy.sol";
import "./AtlantisPriceOracleStorage.sol";

interface IAToken {
    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function underlying() external view returns (address);
}

interface IERC20 {
    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AtlantisPriceOracle is AtlantisPriceOracleStorage {
    using SafeMath for uint256;

    event PricePosted(address asset, uint256 previousPriceMantissa, uint256 requestedPriceMantissa, uint256 newPriceMantissa);

    event FeedSet(address feed, string symbol);

    FeedRegistryInterface internal feedRegistry;

    constructor() {}

    function getUnderlyingPrice(address _aToken) external view returns (uint256 answer) {
        IAToken aToken = IAToken(_aToken);

        if (compareStrings(aToken.symbol(), "aBNB")) {
            return getLatestAnswer("BNB");
        } else {
            return getPrice(aToken);
        }
    }

    function getPrice(IAToken aToken) internal view returns (uint256 price) {
        if (prices[address(aToken)] != 0) {
            price = prices[address(aToken)];
        } else {
            price = getLatestAnswer(IERC20(aToken.underlying()).symbol());
        }

        uint256 decimalDelta = uint256(18).sub(uint256(IERC20(aToken.underlying()).decimals()));
        // Ensure that we don't multiply the result by 0
        if (decimalDelta > 0) {
            return price.mul(10**decimalDelta);
        } else {
            return price;
        }
    }

    function getLatestAnswer(string memory symbol) public view returns (uint256 answer) {
        AggregatorV2V3Interface feedAdapter = getFeed(symbol);
        require(address(feedAdapter) != address(0), "Feed not found");

        // Oracle USD-denominated feeds store answers at 8 decimals
        uint decimalDelta = uint(18).sub(feedAdapter.decimals());

        // Ensure that we don't multiply the result by 0
        if (decimalDelta > 0) {
            return uint256(feedAdapter.latestAnswer()).mul(10**decimalDelta);
        } else {
            return uint256(feedAdapter.latestAnswer());
        }
    }

    function decimals(address base, address quote) external view returns (uint8) {
        return feedRegistry.decimals(base, quote);
    }

    function getFeed(string memory symbol) public view returns (AggregatorV2V3Interface) {
        return feeds[keccak256(abi.encodePacked(symbol))];
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin may call");
        _;
    }

    /*** Admin Functions ***/

    function setFeed(string calldata symbol, address feed) external onlyAdmin {
        require(feed != address(0) && feed != address(this), "invalid feed address");

        feeds[keccak256(abi.encodePacked(symbol))] = AggregatorV2V3Interface(feed);
        emit FeedSet(feed, symbol);
    }

    // This method is currently not used
    function setDirectPrice(address asset, uint256 price) external onlyAdmin {
        prices[asset] = price;
        emit PricePosted(asset, prices[asset], price, price);
    }

    function _become(AtlantisPriceOracleProxy atlantisPriceOracleProxy) external {
        require(msg.sender == atlantisPriceOracleProxy.admin(), "only proxy admin can change brains");
        atlantisPriceOracleProxy._acceptImplementation();
    }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "@binance-oracle/binance-oracle-starter/contracts/interfaces/AggregatorV2V3Interface.sol";

contract AtlantisPriceOracleAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of Atlantis Binance Oracle
    */
    address public implementation;

    /**
    * @notice Pending brains of Atlantis Binance Oracle
    */
    address public pendingAtlantisPriceOracleImplementation;
}

contract AtlantisPriceOracleStorage is AtlantisPriceOracleAdminStorage {
    mapping(bytes32 => AggregatorV2V3Interface) internal feeds;
    mapping(address => uint) internal prices;
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./AtlantisPriceOracleStorage.sol";

contract AtlantisPriceOracleProxy is AtlantisPriceOracleAdminStorage {
    /**
     * @notice Emitted when pendingAtlantisPriceOracleImplementation is changed
     */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
     * @notice Emitted when pendingAtlantisPriceOracleImplementation is accepted, which means Community Vault implementation is updated
     */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * @notice Emitted when pendingAdmin is changed
     */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
     * @notice Emitted when pendingAdmin is accepted, which means admin is updated
     */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() {
        // Set admin to caller
        admin = msg.sender;
    }

    /*** Admin Functions ***/
    function _setPendingImplementation(address newPendingImplementation) external {
        // Reverts if the caller is not admin
        require(msg.sender == admin, "only admin");

        address oldPendingImplementation = pendingAtlantisPriceOracleImplementation;
        pendingAtlantisPriceOracleImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingAtlantisPriceOracleImplementation);
    }

    /**
     * @notice Accepts new implementation of AtlantisPriceOracle. msg.sender must be pendingImplementation
     * @dev Admin function for new implementation to accept it's role as implementation
     */
    function _acceptImplementation() external {
        // Reverts if the caller is not pending atlantis price oracle implementation
        require(msg.sender == pendingAtlantisPriceOracleImplementation, "only pending implementation");

        // Save current values for inclusion in log
        address oldImplementation = implementation;
        address oldPendingImplementation = pendingAtlantisPriceOracleImplementation;

        implementation = pendingAtlantisPriceOracleImplementation;
        pendingAtlantisPriceOracleImplementation = address(0);

        emit NewImplementation(oldImplementation, implementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingAtlantisPriceOracleImplementation);
    }

    /**
     * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
     * @param newPendingAdmin New pending admin.
     */
    function _setPendingAdmin(address newPendingAdmin) external {
        // Reverts if the caller is not admin
        require(msg.sender == admin, "only admin");

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    /**
     * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
     * @dev Admin function for pending admin to accept role and update admin
     */
    function _acceptAdmin() external {
        // Reverts if the caller is not pending admin
        require(msg.sender == pendingAdmin, "only pending admin");

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback() external payable {
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize())
            }
            default {
                return(free_mem_ptr, returndatasize())
            }
        }
    }

    receive() external payable {
        // custom function code
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorV2V3Interface.sol";
import "./DenominationsInterface.sol";

/**
 * @dev Feed registry must expose AggregatorV2V3Interface to be able to serve FeedAdapters for backward compatibility
 */
interface FeedRegistryInterface is DenominationsInterface {
  struct Phase {
    uint16 phaseId;
    uint80 startingAggregatorRoundId;
    uint80 endingAggregatorRoundId;
  }
  struct RoundData {
    uint80 roundId;
    int256 answer;
    uint256 startedAt;
    uint256 updatedAt;
    uint80 answeredInRound;
  }
  event FeedProposed(
    address indexed asset,
    address indexed denomination,
    address indexed proposedAggregator,
    address currentAggregator,
    address sender
  );
  event FeedConfirmed(
    address indexed asset,
    address indexed denomination,
    address indexed latestAggregator,
    address previousAggregator,
    uint16 nextPhaseId,
    address sender
  );

  //Latest interface to query prices through FeedRegistry
  function decimalsByName(string memory base, string memory quote) external view returns (uint8);

  function descriptionByName(string memory base, string memory quote) external view returns (string memory);

  function versionByName(string memory base, string memory quote) external view returns (uint256);

  function latestRoundDataByName(string memory base, string memory quote)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestAnswerByName(string memory base, string memory quote) external view returns (int256 answer);

  function getMultipleLatestRoundData(string[] memory bases, string[] memory quotes)
    external
    view
    returns (RoundData[] memory);

  // V3 AggregatorInterface
  function decimals(address base, address quote) external view returns (uint8);

  function description(address base, address quote) external view returns (string memory);

  function version(address base, address quote) external view returns (uint256);

  function latestRoundData(address base, address quote)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function getRoundData(
    address base,
    address quote,
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

  // V2 AggregatorInterface

  function latestAnswer(address base, address quote) external view returns (int256 answer);

  function latestTimestamp(address base, address quote) external view returns (uint256 timestamp);

  function latestRound(address base, address quote) external view returns (uint256 roundId);

  function getAnswer(
    address base,
    address quote,
    uint256 roundId
  ) external view returns (int256 answer);

  function getTimestamp(
    address base,
    address quote,
    uint256 roundId
  ) external view returns (uint256 timestamp);

  // Registry getters

  function getFeed(address base, address quote) external view returns (AggregatorV2V3Interface aggregator);

  function getPhaseFeed(
    address base,
    address quote,
    uint16 phaseId
  ) external view returns (AggregatorV2V3Interface aggregator);

  function isFeedEnabled(address aggregator) external view returns (bool);

  function getPhase(
    address base,
    address quote,
    uint16 phaseId
  ) external view returns (Phase memory phase);

  // Round helpers

  function getRoundFeed(
    address base,
    address quote,
    uint80 roundId
  ) external view returns (AggregatorV2V3Interface aggregator);

  function getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  ) external view returns (uint80 startingRoundId, uint80 endingRoundId);

  function getPreviousRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external view returns (uint80 previousRoundId);

  function getNextRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external view returns (uint80 nextRoundId);

  // Feed management

  function proposeFeed(
    address base,
    address quote,
    address aggregator
  ) external;

  function confirmFeed(
    address base,
    address quote,
    address aggregator
  ) external;

  // Proposed aggregator

  function getProposedFeed(address base, address quote)
    external
    view
    returns (AggregatorV2V3Interface proposedAggregator);

  function proposedGetRoundData(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function proposedLatestRoundData(address base, address quote)
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  // Phases
  function getCurrentPhaseId(address base, address quote) external view returns (uint16 currentPhaseId);
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
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../library/EnumerableTradingPairMap.sol";

interface DenominationsInterface {
  function totalPairsAvailable() external view returns (uint256);

  function getAllPairs() external view returns (EnumerableTradingPairMap.Pair[] memory);

  function getTradingPairDetails(string calldata base, string calldata quote)
    external
    view
    returns (
      address,
      address,
      address
    );

  function insertPair(
    string calldata base,
    string calldata quote,
    address baseAssetAddress,
    address quoteAssetAddress,
    address feedAdapterAddress
  ) external;

  function removePair(string calldata base, string calldata quote) external;

  function exists(string calldata base, string calldata quote) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *  @notice Library providing database functionality for trading pairs
 *  @author Sri Krishna Mannem
 */
library EnumerableTradingPairMap {
  struct TradingPairDetails {
    address baseAssetAddress;
    address quoteAssetAddress;
    address feedAddress;
  }
  struct Pair {
    string baseAsset;
    string quoteAsset;
  }

  struct EnumerableMap {
    Pair[] keyList;
    mapping(bytes32 => mapping(bytes32 => uint256)) keyPointers;
    mapping(bytes32 => mapping(bytes32 => TradingPairDetails)) values;
  }

  /**
   * @notice insert a key.
   * @dev duplicate keys are not permitted.
   * @param self storage space for pairs
   * @param base base asset to insert
   * @param quote quote asset to insert
   * @param value details of the pair to insert
   */
  function insert(
    EnumerableMap storage self,
    string memory base,
    string memory quote,
    TradingPairDetails memory value
  ) internal {
    require(!exists(self, base, quote), "Insert: Key already exists in the mapping");
    self.keyList.push(Pair(base, quote));
    self.keyPointers[toBytes32(base)][toBytes32(quote)] = self.keyList.length - 1;
    self.values[toBytes32(base)][toBytes32(quote)] = value;
  }

  /**
   * @notice remove a key
   * @dev key to remove must exist.
   * @param self storage space for pairs
   * @param base base asset to insert
   * @param quote quote asset to insert
   */
  function remove(
    EnumerableMap storage self,
    string memory base,
    string memory quote
  ) internal {
    require(exists(self, base, quote), "Remove: Key does not exist in the mapping");
    uint256 last = count(self) - 1;
    uint256 indexToReplace = self.keyPointers[toBytes32(base)][toBytes32(quote)];
    if (indexToReplace != last) {
      Pair memory keyToMove = self.keyList[last];
      self.keyPointers[toBytes32(keyToMove.baseAsset)][toBytes32(keyToMove.quoteAsset)] = indexToReplace;
      self.keyList[indexToReplace] = keyToMove;
    }
    delete self.keyPointers[toBytes32(base)][toBytes32(quote)];
    self.keyList.pop(); //Purge last element
    delete self.values[toBytes32(base)][toBytes32(quote)];
  }

  /**
   * @notice Get trading pair details
   * @param self storage space for pairs
   * @param base base asset of pair
   * @param quote quote asset of pair
   * @return trading pair details (base address, quote address, feedAdapter address)
   */
  function getTradingPair(
    EnumerableMap storage self,
    string memory base,
    string memory quote
  ) external view returns (TradingPairDetails memory) {
    require(exists(self, base, quote), "Get trading pair: Key does not exist in the mapping");
    return self.values[toBytes32(base)][toBytes32(quote)];
  }

  /*
   * @param self storage space for pairs
   * @return all the pairs in memory (base address, quote address)
   */
  function getAllPairs(EnumerableMap storage self) external view returns (Pair[] memory) {
    return self.keyList;
  }

  /*
   * @param self storage space for pairs
   * @return total number of available pairs
   */
  function count(EnumerableMap storage self) internal view returns (uint256) {
    return (self.keyList.length);
  }

  /**
   * @notice check if a key is in the Set.
   * @param self storage space for pairs
   * @param base base asset to insert
   * @param quote quote asset to insert
   * @return bool true if a pair exists
   */
  function exists(
    EnumerableMap storage self,
    string memory base,
    string memory quote
  ) internal view returns (bool) {
    if (self.keyList.length == 0) return false;
    return
      pairToBytes32(self.keyList[self.keyPointers[toBytes32(base)][toBytes32(quote)]]) ==
      pairToBytes32(Pair(base, quote));
  }

  /**
   * @dev Compute the hash of an asset string
   */
  function toBytes32(string memory s) private pure returns (bytes32) {
    return (keccak256(bytes(s)));
  }

  /**
   * @dev Compute the hash of a trading pair
   */
  function pairToBytes32(Pair memory p) private pure returns (bytes32) {
    return keccak256(abi.encode(p.baseAsset, "/", p.quoteAsset));
  }
}