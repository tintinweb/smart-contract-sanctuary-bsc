// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BasePresale.sol";
import "./DataFeed.sol";
import "./IToken.sol";

contract NativePresale is BasePresale {
  using DataFeedClient for AggregatorV3Interface;

  // ========================================
  // State variables
  // ========================================

  uint256 internal constant USD_LIMIT = 15000 * 10 ** 8;
  AggregatorV3Interface internal immutable dataFeed;

  // ========================================
  // Constructor
  // ========================================

  constructor(
    IToken _token,
    AggregatorV3Interface _dataFeed,
    address _aggregatorAddr,
    uint64 _limit,
    uint64 _rate
  ) BasePresale(_token, _aggregatorAddr, _limit, _rate
  ) {
    dataFeed = _dataFeed;
  }

  // ========================================
  // Entrypoints
  // ========================================

  // Buy with method call
  function buy() external payable {
    _buy(msg.sender, msg.value);
  }

  // Buy via sending ETH to contract address
  receive() external payable {
    _buy(msg.sender, msg.value);
  }

  // ========================================
  // Internals
  // ========================================

  function _calculateInputValue(uint256 input) internal view override returns (uint256) {
    // Get latest native token price from chainlink
    uint256 nativeTokenPrice = dataFeed.getData();

    // Transaction value has to be lower or equal to 15K USD
    uint256 usdValue = _toUsd(input, nativeTokenPrice);
    require(usdValue <= USD_LIMIT, "PS: usd value too high");

    // Each token is worth 0.1 USD
    uint256 tokenValue = _getTokenValue(input, nativeTokenPrice);
    require(tokenValue != 0, "PS: token value is zero");

    return tokenValue;
  }

  function _getTokenValue(
    uint256 value,
    uint256 nativeTokenPrice
  ) internal view returns (uint256) {
    return value * nativeTokenPrice * 10 ** token.decimals() / _saleData.rate / 1 ether;
  }

  function _toUsd(
    uint256 value,
    uint256 nativeTokenPrice
  ) internal pure returns (uint256) {
    return value * nativeTokenPrice / 1 ether;
  }

  // ========================================
  // Helper views
  // ========================================

  function getNativeTokenPrice() external view returns (uint256) {
    return dataFeed.getData();
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./OwnerUtils.sol";
import "./IPresale.sol";
import "./IToken.sol";

contract BasePresale is OwnerUtils, IPresale {
  using SafeCast for uint256;

  event Buy(address indexed user, uint256 value);
  event Claim(address indexed user, uint256 value);

  IToken internal immutable token;
  address internal immutable _aggregator;

  // ========================================
  // State variables
  // ========================================

  PresaleData internal _saleData;
  mapping(address => UserData) public userData;

  // ========================================
  // Constructor
  // ========================================

  constructor(
    IToken _token,
    address _aggregatorAddr,
    uint64 _limit,
    uint64 _rate
  ) {
    token = _token;
    _aggregator = _aggregatorAddr;
    _saleData = PresaleData(0, _rate, _limit, Status.sale, 0);
  }

  // ========================================
  // Entrypoints
  // ========================================

  // Default claim method
  function claim() external {
    _claim(msg.sender);
  }

  // Claiming via aggregator
  function aggregatorClaim(address sender) external onlyAggregator {
    _claim(sender);
  }

  // ========================================
  // Internals
  // ========================================

  // Main function for buying tokens
  function _buy(address sender, uint256 input) internal whenSaleStage {
    require(input != 0, "PS: tx value is zero");

    uint256 tokenValue = _calculateInputValue(input);

    // Only allow to sell tokens if maximal limit is not exceeded
    uint256 available = _getAvailableTokens();
    require(available >= tokenValue, "PS: no available tokens");

    // Update contract state
    UserData memory data = userData[sender];
    _updateStorageAfterBuy(tokenValue, data, sender);

    emit Buy(sender, tokenValue);
  }

  // Main function for claiming tokens
  function _claim(address sender) internal whenVestingStage {
    // Retrieve user data from contract state
    UserData memory data = userData[sender];

    // User should have locked tokens
    require(data.balance != 0, "PS: zero balance");

    // Allow to claim set percent of tokens
    uint256 value = _tokensToClaim(_saleData.unlockedPercent, data.balance, data.maxBalance);
    require(value != 0, "PS: nothing to claim");

    // Update contract state
    _updateStorageAfterClaim(value, data, sender);

    // Transfer tokens from aggregator contract
    // The contract will fail if no allowance is set
    token.transferFrom(_aggregator, sender, value);

    emit Claim(sender, value);
  }

  // Override this in child contract
  function _calculateInputValue(uint256) internal view virtual returns (uint256) {
    return 0;
  }

  // Balances are saved as uint64. Total supply of token should be lower or equal to 10**19
  function _updateStorageAfterClaim(uint256 value, UserData memory data, address user) internal {
    uint64 downCasted = value.toUint64();

    data.balance -= downCasted;
    _saleData.locked -= downCasted;

    userData[user] = data;
  }

  // Balances are saved as uint64. Total supply of token should be lower or equal to 10**19
  function _updateStorageAfterBuy(uint256 value, UserData memory data, address user) internal {
    uint64 downCasted = value.toUint64();

    data.balance += downCasted;
    data.maxBalance += downCasted;
    _saleData.locked += downCasted;

    userData[user] = data;
  }

  function _getAvailableTokens() internal view returns (uint256) {
    PresaleData memory data = _saleData;

    return uint256(data.limit - data.locked);
  }

  function _tokensToClaim(
    uint8 percent,
    uint256 balance,
    uint256 maxBalance
  ) internal pure returns (uint256) {
    if (percent == 0) return 0;
    if (percent >= 100) return balance;

    uint256 maxTotal = (maxBalance * percent) / 100;
    return maxTotal - (maxBalance - balance);
  }

  // ========================================
  // Owner utilities
  // ========================================

  // IMPORTANT
  // Contract logic might break when changed from sale to vesting and changed back to sale
  // Calculating value of available tokens might break
  function setStatus(Status _status) external onlyAuthorized {
    _saleData.status = _status;
  }

  function setUnlockedPercent(uint8 _unlocked) external onlyAuthorized {
    require(_unlocked >= _saleData.unlockedPercent, "PS: percent too low");

    _saleData.unlockedPercent = _unlocked;
  }

  function setRate(uint64 _rate) external onlyAuthorized {
    _saleData.rate = _rate;
  }

  function setLimit(uint64 _limit) external onlyAuthorized {
    require (_limit >= _saleData.locked, "PS: limit too low");

    _saleData.limit = _limit;
  }

  // ========================================
  // Helper views
  // ========================================

  function availableToClaim(address user) external view returns (uint256) {
    if (_saleData.status != Status.vesting) return 0;

    UserData memory data = userData[user];

    if (data.balance == 0) return 0;

    return _tokensToClaim(_saleData.unlockedPercent, data.balance, data.maxBalance);
  }

  function availableTokens() external view returns (uint256) {
    return _getAvailableTokens();
  }

  function saleData() external view returns (PresaleData memory) {
    return _saleData;
  }

  function aggregator() external view returns (address) {
    return _aggregator;
  }

  // ========================================
  // Modifiers
  // ========================================

  modifier whenSaleStage() {
    require(_saleData.status == Status.sale, "PS: stage is not sale");
    _;
  }

  modifier whenVestingStage() {
    require(_saleData.status == Status.vesting, "PS: stage is not vesting");
    _;
  }

  modifier onlyAuthorized() {
    require (msg.sender == owner() || msg.sender == _aggregator, "PS: caller is not authorized");
    _;
  }

  modifier onlyAggregator() {
    require (msg.sender == _aggregator, "PS: caller is not aggregator");
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable not-rely-on-time

import "@openzeppelin/contracts/access/Ownable.sol";

interface AggregatorV3Interface {
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

library DataFeedClient {
  int256 internal constant MIN_VALUE = 10 ** 7; // 0.1 USD
  int256 internal constant MAX_VALUE = 1000000 * 10 ** 8; // 1,000,000 USD
  uint256 internal constant MAX_DELAY = 2592000; // 1 month

  function getData(AggregatorV3Interface dataFeed)
    internal
    view
    returns (uint256)
  {
    (, int256 answer, , uint256 updatedAt, ) = dataFeed.latestRoundData();
    uint256 value = uint256(answer);

    require(answer >= MIN_VALUE, "DF: value too low");
    require(answer <= MAX_VALUE, "DF: value too high");
    require(updatedAt <= block.timestamp, "DF: future timestamp");
    require(updatedAt >= block.timestamp - MAX_DELAY, "DF: timestamp too old");

    return value;
  }
}

contract StaticDataFeed is AggregatorV3Interface, Ownable {
  int256 internal answer;
  int256 internal diff;

  constructor(int256 _answer, int256 _diff) {
    answer = _answer;
    diff = _diff;
  }

  function setValues(int256 _answer, int256 _diff) external onlyOwner {
    answer = _answer;
    diff = _diff;
  }

  function latestRoundData()
    external
    view
    override
    returns (
      uint80,
      int256,
      uint256,
      uint256,
      uint80
    )
  {
    uint256 updatedAt = uint256(int256(block.timestamp) + diff);
    return (0, answer, 0, updatedAt, 0);
  }
}

contract TestDataFeedClient {
  using DataFeedClient for AggregatorV3Interface;

  function getData(AggregatorV3Interface dataFeed)
    external
    view
    returns (uint256)
  {
    return dataFeed.getData();
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IToken is IERC20Metadata {
  function increaseAllowance(address spender, uint256 addedValue) external;
  function decreaseAllowance(address spender, uint256 addedValue) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract OwnerUtils is Ownable {
  using SafeERC20 for IERC20;

  function transfer(address to, uint256 value) external virtual onlyOwner {
    // https://consensys.github.io/smart-contract-best-practices/recommendations/#dont-use-transfer-or-send
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, ) = payable(to).call{value: value}("");
    require(success, "OwnerUtils: transfer failed");
  }

  function transferToken(IERC20 _token, address to, uint256 value) external virtual onlyOwner {
    _token.safeTransfer(to, value);
  }

  // solhint-disable-next-line no-empty-blocks
  function fund() external payable virtual onlyOwner {}

  function increaseAllowance(IERC20 _token, address spender, uint256 value) external virtual onlyOwner {
    _token.safeIncreaseAllowance(spender, value);
  }

  function decreaseAllowance(IERC20 _token, address spender, uint256 value) external virtual onlyOwner {
    _token.safeDecreaseAllowance(spender, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

enum Status {
  paused,
  sale,
  vesting
}

struct PresaleData {
  uint64 locked;
  uint64 rate;
  uint64 limit;
  Status status;
  uint8 unlockedPercent;
}

struct UserData {
  uint64 balance;
  uint64 maxBalance;
}

interface IPresale {
  function aggregatorClaim(address) external;
  function availableToClaim(address) external view returns (uint256);
  function aggregator() external view returns (address);

  function saleData() external view returns (PresaleData memory);

  function setUnlockedPercent(uint8) external;
  function setStatus(Status) external;
  function setLimit(uint64) external;
  function setRate(uint64) external;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}