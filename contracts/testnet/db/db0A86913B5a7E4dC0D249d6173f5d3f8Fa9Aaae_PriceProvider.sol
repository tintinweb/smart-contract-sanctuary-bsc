// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "../interfaces/IChainlinkAggregator.sol";
import "../interfaces/IPoolHelper.sol";
import "../interfaces/IRewardEligibleDataProvider.sol";
import "../dependencies/openzeppelin/contracts/SafeMath.sol";
import "../dependencies/openzeppelin/upgradeability/Initializable.sol";
import "../dependencies/openzeppelin/upgradeability/OwnableUpgradeable.sol";

contract PriceProvider is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;

    IChainlinkAggregator public baseTokenPriceInUsdProxyAggregator;
    IPoolHelper public poolHelper;
    IRewardEligibleDataProvider public eligibilityProvider;

    uint256 public lastPrice;
    uint256 public lastLpPrice;
    uint256 public lastPriceBlock;

    function initialize(
        IChainlinkAggregator _baseTokenPriceInUsdProxyAggregator,
        IPoolHelper _poolHelper
    ) public initializer {
        require(address(_baseTokenPriceInUsdProxyAggregator) != (address(0)), "Not a valid address");
        require(address(_poolHelper) != (address(0)), "Not a valid address");
        __Ownable_init();

        poolHelper = _poolHelper;
        baseTokenPriceInUsdProxyAggregator = _baseTokenPriceInUsdProxyAggregator;
        lastPriceBlock = 0;
        lastPrice = 0;
        lastLpPrice = 0;
    }

    function setRewardEligibilityProvider(IRewardEligibleDataProvider _eligibilityProvider)
        external
        onlyOwner
    {
        eligibilityProvider = _eligibilityProvider;
        update();
    }

    /**
    * @dev Update delayed prices when at least 1 block past previous reading.
    **/
    function update() public {
        if (block.number > lastPriceBlock) {
            lastPriceBlock =  block.number;
            lastPrice = poolHelper.getPrice();
            lastLpPrice = poolHelper.getLpPrice();
        }
    }

    function getLpTokenAddress() public view returns (address) {
        return poolHelper.lpTokenAddr();
    }

    function getTokenPrice(bool _useDelay) public view returns (uint256) {
        if(_useDelay) {
            return lastPrice;
        } else {
            return poolHelper.getPrice();
        }
    }

    function getLpTokenPrice(bool _useDelay) public view returns (uint256 priceInEth) {
        if(_useDelay) {
            return lastLpPrice;
        } else {
            return poolHelper.getLpPrice();
        }
    }

    function getTokenPriceUsd(bool _useDelay) external view returns (uint256) {
        uint256 ethPrice = uint256(
            baseTokenPriceInUsdProxyAggregator.latestAnswer()
        );
        // uint256 priceDecimals = baseTokenPriceInUsdProxyAggregator.decimals(); // 8 in most cases
        uint256 decis = decimals();

        uint256 rdntPriceInEth = getTokenPrice(_useDelay);
        uint256 rdntPriceInUsd = rdntPriceInEth.mul(ethPrice).div(decis);
        return rdntPriceInUsd;
    }

    function getLpTokenPriceUsd(bool _useDelay) external view returns (uint256) {
        uint256 ethPrice = uint256(
            baseTokenPriceInUsdProxyAggregator.latestAnswer()
        );
        // uint256 priceDecimals = baseTokenPriceInUsdProxyAggregator.decimals(); // 8 in most cases
        uint256 decis = decimals();

        uint256 lpPrice = getLpTokenPrice(_useDelay);
        uint256 lpPriceUsd = lpPrice.mul(ethPrice).div(decis);
        return lpPriceUsd;
    }

    function decimals() public pure returns (uint256) {
        return 10**8;
    }
}

// SPDX-License-Identifier: MIT
// Code from https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

pragma solidity 0.7.6;

import './AggregatorInterface.sol';
import './AggregatorV3Interface.sol';

interface IChainlinkAggregator is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import {IERC20} from "../dependencies/openzeppelin/contracts/IERC20.sol";

interface IPoolHelper {
    function lpTokenAddr() external view returns (address);
    function initializePool() external;
    function zapWETH(uint256 amount) external returns (uint256);
    function zapTokens(uint256 _wethAmt, uint256 _rdntAmt) external returns (uint256);
    function quoteFromToken(uint256 tokenAmount) external view returns (uint256 optimalWETHAmount);
    function getPrice() external view returns (uint256 priceInEth);
    function getLpPrice() external view returns (uint256 priceInEth);
}

interface ITestPoolHelper is IPoolHelper {
    function sell(uint256 _amount) external returns (uint256 amountOut);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface IRewardEligibleDataProvider {
    function refresh(address user) external;

    function updatePrice() external;

    function requiredEthValue(address user)
        external
        view
        returns (uint256 required);

    function isEligibleForRewards(address _user)
        external
        view
        returns (bool isEligible);

    function lastEligibleTime(address user)
        external
        view
        returns (uint256 lastEligibleTimestamp);

    function lockedUsdValue(address user)
        external
        view
        returns (uint256);

    function requiredUsdValue(address user)
        external
        view
        returns (uint256 required);

    function lastEligibleStatus(address user)
        external
        view
        returns (bool);

    function isMarketDisqualified(address user)
        external
        view
        returns (bool);

    function rewardEligibleAmount(address token)
        external
        view
        returns (uint256);

    function setDqTime(address _user, uint256 _time) external;
    function getDqTime(address _user) external view returns (uint256);
    function autoprune() external returns (uint256 processed);
    function requiredDepositRatio() external view returns (uint256);
    function RATIO_DIVISOR() external view returns (uint256);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        uint256 cs;
        //solium-disable-next-line
        assembly {
            cs := extcodesize(address())
        }
        return cs == 0;
    }

    modifier onlyInitializing() {
        require(initializing, "Initializable: contract is not initializing");
        _;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

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
    require(c >= a, 'SafeMath: addition overflow');

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
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    require(c / a == b, 'SafeMath: multiplication overflow');

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
    return div(a, b, 'SafeMath: division by zero');
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
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    return mod(a, b, 'SafeMath: modulo by zero');
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
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }

  function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

import "./Initializable.sol";
import "./ContextUpgradeable.sol";

contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

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
pragma solidity ^0.7.0;

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

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

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
  function transferFrom(
    address sender,
    address recipient,
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

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

import "./Initializable.sol";

contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

    uint256[50] private __gap;
}