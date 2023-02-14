// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../dependencies/openzeppelin/contracts/IERC20Detailed.sol";
import "../dependencies/openzeppelin/contracts/IERC20.sol";
import "../dependencies/openzeppelin/upgradeability/Initializable.sol";
import "../dependencies/openzeppelin/upgradeability/OwnableUpgradeable.sol";
import "../misc/interfaces/IAaveOracle.sol";
import "../dependencies/openzeppelin/contracts/SafeMath.sol";
import "../interfaces/IChainlinkAggregator.sol";
import {IMiddleFeeDistribution, IMultiFeeDistribution} from '../interfaces/IMultiFeeDistribution.sol';

contract MFDstats is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;

    address private _aaveOracle;

    struct MFDTransfer {
        uint256 timestamp;
        uint256 usdValue;
        uint256 lpUsdValue;
    }

    struct AssetAddresses {
        uint256 count;
        mapping(uint256 => address) assetAddress;
        mapping(uint256 => string) assetSymbol;
        mapping(address => uint256) indexOfAddress;
    }

    struct TrackPerAsset {
        address assetAddress;
        string assetSymbol;
        uint256 usdValue;
        uint256 lpUsdValue;
    }

    struct AddTransferParam {
        address asset;
        uint256 amount;
        address treasury;
    }

    AssetAddresses private allAddresses;

    mapping(address => uint256) private _totalPerAsset;
    mapping(address => uint256) private _lpTotalPerAsset;
    mapping(address => MFDTransfer[]) private mfdTransfersPerAsset;

    uint256 public constant DAY_SECONDS = 86400;
    uint8 public constant DECIMALS = 18;
    uint256 public constant RATIO_DIVISOR = 10000;

    event NewTransferAdded(address asset, uint256 usdValue, uint256 lpUsdValue);

    function initialize(
        address aaveOracle
    ) public initializer {
        _aaveOracle = aaveOracle;
        __Ownable_init();
    }

    function getPriceDecimal (address assetAddress) external view returns (uint8) {
        address sourceOfAsset = IAaveOracle(_aaveOracle).getSourceOfAsset(
            assetAddress
        );
        uint8 priceDecimal = IChainlinkAggregator(sourceOfAsset).decimals();
        return priceDecimal;
    }

    function addTransfer(AddTransferParam memory param) external {
        uint256 lpLockingRewardRatio = IMiddleFeeDistribution(param.treasury).lpLockingRewardRatio();
        uint256 operationExpenseRatio = IMiddleFeeDistribution(param.treasury).operationExpenseRatio();
        address operationExpenses = IMiddleFeeDistribution(param.treasury).operationExpenses();
        uint256 assetPrice = IAaveOracle(_aaveOracle).getAssetPrice(
            param.asset
        );
        address sourceOfAsset = IAaveOracle(_aaveOracle).getSourceOfAsset(
            param.asset
        );
        if (operationExpenses != address(0) && operationExpenseRatio > 0) {
            uint256 opExAmount = param.amount.mul(operationExpenseRatio).div(RATIO_DIVISOR);
            param.amount = param.amount.sub(opExAmount);
        }
        uint8 priceDecimal = IChainlinkAggregator(sourceOfAsset).decimals();
        uint8 assetDecimals = IERC20Detailed(param.asset).decimals();
        uint256 usdValue = assetPrice
            .mul(param.amount)
            .mul(10**DECIMALS)
            .div(10**priceDecimal)
            .div(10**assetDecimals);
        uint256 lpUsdValue = usdValue.mul(lpLockingRewardRatio).div(RATIO_DIVISOR);
        usdValue = usdValue.sub(lpUsdValue);

        uint256 index;

        if (allAddresses.indexOfAddress[param.asset] == 0) {
            allAddresses.count++;
            allAddresses.assetAddress[allAddresses.count] = param.asset;
            allAddresses.assetSymbol[allAddresses.count] = IERC20Detailed(
                param.asset
            ).symbol();
            allAddresses.indexOfAddress[param.asset] = allAddresses.count;
        }
        _totalPerAsset[param.asset] = _totalPerAsset[param.asset].add(usdValue);
        _lpTotalPerAsset[param.asset] = _lpTotalPerAsset[param.asset].add(
            lpUsdValue
        );

        for (uint256 i = 0; i < mfdTransfersPerAsset[param.asset].length; i++) {
            if (
                block.timestamp.sub(
                    mfdTransfersPerAsset[param.asset][i].timestamp
                ) <= DAY_SECONDS
            ) {
                index = i;
                break;
            }
        }

        for (
            uint256 i = index;
            i < mfdTransfersPerAsset[param.asset].length;
            i++
        ) {
            mfdTransfersPerAsset[param.asset][i - index] = mfdTransfersPerAsset[
                param.asset
            ][i];
        }

        for (uint256 i = 0; i < index; i++) {
            mfdTransfersPerAsset[param.asset].pop();
        }

        mfdTransfersPerAsset[param.asset].push(
            MFDTransfer(block.timestamp, usdValue, lpUsdValue)
        );

        emit NewTransferAdded(param.asset, usdValue, lpUsdValue);
    }

    function getTotal() external view returns (TrackPerAsset[] memory) {
        TrackPerAsset[] memory totalPerAsset = new TrackPerAsset[](
            allAddresses.count + 1
        );
        uint256 total;
        uint256 lpTotal;
        for (uint256 i = 1; i <= allAddresses.count; i++) {
            total = total.add(_totalPerAsset[allAddresses.assetAddress[i]]);
            lpTotal = lpTotal.add(
                _lpTotalPerAsset[allAddresses.assetAddress[i]]
            );

            totalPerAsset[i] = TrackPerAsset(
                allAddresses.assetAddress[i],
                allAddresses.assetSymbol[i],
                _totalPerAsset[allAddresses.assetAddress[i]],
                _lpTotalPerAsset[allAddresses.assetAddress[i]]
            );
        }
        totalPerAsset[0] = TrackPerAsset(address(0), "", total, lpTotal);
        return totalPerAsset;
    }

    function getLastDayTotal() external view returns (TrackPerAsset[] memory) {
        TrackPerAsset[] memory lastDayTotalPerAsset = new TrackPerAsset[](
            allAddresses.count + 1
        );
        uint256 lastdayTotal;
        uint256 lpLastDayTotal;

        for (uint256 i = 1; i <= allAddresses.count; i++) {
            uint256 assetLastDayTotal;
            uint256 lpAssetLastDayTotal;

            assert(mfdTransfersPerAsset[allAddresses.assetAddress[i]].length > 0);
            for (
                uint256 j = mfdTransfersPerAsset[
                    allAddresses.assetAddress[i]
                ].length.sub(1);
                ;
                j--
            ) {
                if (
                    block.timestamp.sub(
                        mfdTransfersPerAsset[allAddresses.assetAddress[i]][
                            j
                        ].timestamp
                    ) <= DAY_SECONDS
                ) {
                    assetLastDayTotal = assetLastDayTotal.add(
                        mfdTransfersPerAsset[allAddresses.assetAddress[i]][
                            j
                        ].usdValue
                    );
                    lpAssetLastDayTotal = lpAssetLastDayTotal.add(
                        mfdTransfersPerAsset[allAddresses.assetAddress[i]][
                            j
                        ].lpUsdValue
                    );
                } else {
                    break;
                }
                if (j == 0) break;
            }

            lastdayTotal = lastdayTotal.add(assetLastDayTotal);
            lpLastDayTotal = lpLastDayTotal.add(lpAssetLastDayTotal);
            lastDayTotalPerAsset[i] = TrackPerAsset(
                allAddresses.assetAddress[i],
                allAddresses.assetSymbol[i],
                assetLastDayTotal,
                lpAssetLastDayTotal
            );
        }

        lastDayTotalPerAsset[0] = TrackPerAsset(
            address(0),
            "",
            lastdayTotal,
            lpLastDayTotal
        );

        return lastDayTotalPerAsset;
    }

    function getCirculatingSupply(IMiddleFeeDistribution _middleFeeDistribution) external view returns (uint256) {
        address _multiFeeDistribution = IMiddleFeeDistribution(_middleFeeDistribution).getMultiFeeDistributionAddress();
        address _rdntToken = IMiddleFeeDistribution(_middleFeeDistribution).getRdntTokenAddress();
        address _lpFeeDistribution = IMiddleFeeDistribution(_middleFeeDistribution).getLPFeeDistributionAddress();

        address daoTreasuryAddress = IMultiFeeDistribution(_multiFeeDistribution).daoTreasury();
        // dao balance
        uint256 daoBalance = IERC20(_rdntToken).balanceOf(daoTreasuryAddress);
        // mfd balance
        uint256 mfdLockedBalance = IERC20(_rdntToken).balanceOf(_multiFeeDistribution);
        // lp fee distribution balance
        address lpTokenAddress = IMultiFeeDistribution(_lpFeeDistribution).getStakingTokenAddress();
        uint256 lockedLPAmount = IERC20(lpTokenAddress).balanceOf(_lpFeeDistribution);
        uint256 lpTotalSupply = IERC20(lpTokenAddress).totalSupply();
        uint256 lpfdLockedBalance;

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(lpTokenAddress).getReserves();
        if (IUniswapV2Pair(lpTokenAddress).token0() == _rdntToken) {
            lpfdLockedBalance = reserve0 * lockedLPAmount / lpTotalSupply;
        } else {
            lpfdLockedBalance = reserve1 * lockedLPAmount / lpTotalSupply;
        }
        //total supply
        uint256 totalSupply = IERC20(_rdntToken).totalSupply();
        return totalSupply - daoBalance - mfdLockedBalance - lpfdLockedBalance;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "./LockedBalance.sol";

interface IFeeDistribution {
    function addReward(address rewardsToken) external;
    function mint(address user, uint256 amount, bool withPenalty) external;
    function lockedBalances(address user) external view returns (uint256, uint256, uint256, uint256, LockedBalance[] memory);
}

interface IMultiFeeDistribution is IFeeDistribution {
    
    struct RewardData {
        address token;
        uint256 amount;
    }

    
    function exit(bool claimRewards) external;
    function stake(uint256 amount, address onBehalfOf, uint256 typeIndex) external;
    function lockInfo(address user) external view returns (LockedBalance[] memory);
    function getDefaultRelockTypeIndex(address _user) external view returns (uint256);
    function hasAutoRelockDisabled(address user) external view returns (bool);
    function totalBalance(address user) external view returns (uint256);
    function getMFDstatsAddress () external view returns (address);
    function zapVestingToLp (address _address) external returns (uint256);
    function getUsers(uint256 page, uint256 limit) external view returns (address[] memory);
    function lockersCount() external view returns (uint256);
    function withdrawExpiredLocksFor(address _address) external returns (uint256);
    function getLastClaimTime(address _user) external view returns (uint256);
    function disqualifyUser(address _user, address hunter) external returns (IMultiFeeDistribution.RewardData[] memory bounties);
    function claimFromConverter(address) external;
    function bountyForUser(address _user) external view returns (IMultiFeeDistribution.RewardData[] memory bounties);
    function claimableRewards(address account) external view returns (IMultiFeeDistribution.RewardData[] memory rewards);
    function setAutocompound(bool _newVal) external;
    function getAutocompoundEnabled(address _user) external view returns(bool);
    function autocompound(address _user) external;
    function setDefaultRelockTypeIndex(uint256 _index) external;
    function daoTreasury() external view returns (address);
    function getStakingTokenAddress() external view returns (address);
}

interface IMiddleFeeDistribution is IFeeDistribution {
    function forwardReward(address[] memory _rewardTokens) external;
    function getMFDstatsAddress () external view returns (address);
    function lpLockingRewardRatio () external view returns (uint256);
    function getRdntTokenAddress () external view returns (address);
    function getLPFeeDistributionAddress () external view returns (address);
    function getMultiFeeDistributionAddress () external view returns (address);
    function operationExpenseRatio () external view returns (uint256);
    function operationExpenses () external view returns (address);
}

// SPDX-License-Identifier: MIT
// Code from https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

pragma solidity 0.7.6;

import './AggregatorInterface.sol';
import './AggregatorV3Interface.sol';

interface IChainlinkAggregator is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

/**
 * @title IAaveOracle interface
 * @notice Interface for the Aave oracle.
 **/

interface IAaveOracle {
  function BASE_CURRENCY() external view returns (address); // if usd returns 0x0, if eth returns weth address
  function BASE_CURRENCY_UNIT() external view returns (uint256);

  /***********
    @dev returns the asset price in ETH
     */
  function getAssetPrice(address asset) external view returns (uint256);
  function getSourceOfAsset(address asset) external view returns (address);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

import {IERC20} from './IERC20.sol';

interface IERC20Detailed is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

struct LockedBalance {
    uint256 amount;
    uint256 unlockTime;
    uint256 multiplier;
    uint256 duration;
}

struct EarnedBalance {
    uint256 amount;
    uint256 unlockTime;
    uint256 penalty;
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