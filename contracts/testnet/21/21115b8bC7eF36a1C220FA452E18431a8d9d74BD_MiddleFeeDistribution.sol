// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import "../interfaces/IMultiFeeDistribution.sol";
import "../interfaces/IMintableToken.sol";

import "../dependencies/openzeppelin/contracts/IERC20.sol";
import "../dependencies/openzeppelin/contracts/IERC20Detailed.sol";
import "../dependencies/openzeppelin/contracts/SafeERC20.sol";
import "../dependencies/openzeppelin/contracts/SafeMath.sol";
import "../dependencies/openzeppelin/upgradeability/Initializable.sol";
import "../dependencies/openzeppelin/upgradeability/OwnableUpgradeable.sol";

/// @title Fee distributor inside 
/// @author Radiant
/// @dev All function calls are currently implemented without side effects
contract MiddleFeeDistribution is IMiddleFeeDistribution, Initializable, OwnableUpgradeable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /// @notice RDNT token
    IMintableToken public rdntToken;

    /// @notice Fee distributor contract for lp locking
    IMultiFeeDistribution public lpFeeDistribution;

    /// @notice Fee distributor contract for earnings and RDNT lockings
    IMultiFeeDistribution public multiFeeDistribution;

    /// @notice Reward ratio for lp locking in bips
    uint256 public override lpLockingRewardRatio;

    /// @notice Reward ratio for operation expenses
    uint256 public override operationExpenseRatio;

    uint256 public constant RATIO_DIVISOR = 10000;

    /// @notice Minters list
    mapping(address => bool) public minters;

    /// @notice Set minters immutable
    bool public mintersAreSet;

    /// @notice Operation Expense account
    address public override operationExpenses;

    /// @notice Admin address
    address public admin;

    // MFDStats address
    address internal _mfdStats;

    /********************** Events ***********************/

    /// @notice Emitted when ERC20 token is recovered
    event Recovered(address token, uint256 amount);

    /// @notice Emitted when reward token is forwarded
    event ForwardReward(address token, uint256 amount);

    /// @notice Emitted when OpEx info is updated
    event SetOperationExpenses(address opEx, uint256 ratio);

    /// @notice Emitted when minters is set
    event MintersUpdated(address[] _minters);

    /// @notice Emitted when LP locking reward ratio is set 
    event LpLockingRewardRatioUpdated(uint256 _lpLockingRewardRatio);

    /// @notice Emitted when lp fee distribution is set
    event LPFeeDistributionUpdated(IMultiFeeDistribution _lpFeeDistribution);

    /// @notice Emitted when operation expenses is set
    event OperationExpensesUpdated(address _operationExpenses, uint256 _operationExpenseRatio);

    /**
    * @dev Throws if called by any account other than the admin or owner.
    */
    modifier onlyAdminOrOwner() {
        require(admin == _msgSender() || owner() == _msgSender(), 'caller is not the admin or owner');
        _;
    }

    function initialize(
        address _rdntToken,
        address mfdStats,
        IMultiFeeDistribution _lpFeeDistribution,
        IMultiFeeDistribution _multiFeeDistribution
    ) public initializer {
        __Ownable_init();

        rdntToken = IMintableToken(_rdntToken);
        _mfdStats = mfdStats;
        lpFeeDistribution = _lpFeeDistribution;
        multiFeeDistribution = _multiFeeDistribution;

        lpLockingRewardRatio = 10000;
        admin = msg.sender;

        IMintableToken(_rdntToken).setMinter(address(this));
    }

    function getMFDstatsAddress () external view override returns (address) {
        return _mfdStats;
    }

    function getRdntTokenAddress () external view override returns (address) {
        return address(rdntToken);
    }

    function getLPFeeDistributionAddress () external view override returns (address) {
        return address(lpFeeDistribution);
    }

    function getMultiFeeDistributionAddress () external view override returns (address) {
        return address(multiFeeDistribution);
    }

    /**
     * @notice Returns lock information of a user.
     * @dev It currently returns just MFD infos.
     */
    function lockedBalances(
        address user
    ) view external override returns (
        uint256 total,
        uint256 unlockable,
        uint256 locked,
        uint256 lockedWithMultiplier,
        LockedBalance[] memory lockData
    ) {
        return multiFeeDistribution.lockedBalances(user);
    }

    /**
     * @notice Set minters who can call notify rewards to locking contracts
     */
    function setMinters(address[] memory _minters) external onlyAdminOrOwner {
        require(!mintersAreSet, "minters already set");
        for (uint i; i < _minters.length; i++) {
            minters[_minters[i]] = true;
        }
        mintersAreSet = true;

        emit MintersUpdated(_minters);
    }
    
    /**
     * @notice Set reward ratio for lp token locking
     */
    function setLpLockingRewardRatio(uint256 _lpLockingRewardRatio) external onlyAdminOrOwner {
        require(_lpLockingRewardRatio <= RATIO_DIVISOR, "Invalid ratio");
        lpLockingRewardRatio = _lpLockingRewardRatio;
        emit LpLockingRewardRatioUpdated(_lpLockingRewardRatio);
    }
    
    /**
     * @notice Set lp fee distribution contract
     */
    function setLPFeeDistribution(IMultiFeeDistribution _lpFeeDistribution) external onlyAdminOrOwner {
        lpFeeDistribution = _lpFeeDistribution;
        emit LPFeeDistributionUpdated(_lpFeeDistribution);
    }
    
    /**
     * @notice Set operation expenses account
     */
    function setOperationExpenses(address _operationExpenses, uint256 _operationExpenseRatio) external onlyAdminOrOwner {
        require(_operationExpenseRatio <= RATIO_DIVISOR, "Invalid ratio");
        operationExpenses = _operationExpenses;
        operationExpenseRatio = _operationExpenseRatio;
        emit OperationExpensesUpdated(_operationExpenses, _operationExpenseRatio);
    }

    /**
     * @notice Add a new reward token to be distributed to stakers
     */
    function addReward(address _rewardsToken) external override onlyAdminOrOwner {
        multiFeeDistribution.addReward(_rewardsToken);
        lpFeeDistribution.addReward(_rewardsToken);
    }

    /**
     * @notice Mint new tokens
     * 
     * Minted tokens receive rewards normally but incur a 50% penalty when
     * withdrawn before LOCK_DURATION has passed.
     * 
     * @dev Rewards are splitted when it's reward notification, not earnings
     */
    function mint(address user, uint256 amount, bool withPenalty) external override {
        require(minters[msg.sender], "!authorized to mint");
        if (amount == 0) return;
        uint256 lpReward = amount.mul(lpLockingRewardRatio).div(RATIO_DIVISOR);
        if (lpReward != 0) {
            rdntToken.mint(address(lpFeeDistribution), lpReward);
        }
        rdntToken.mint(address(multiFeeDistribution), amount.sub(lpReward));
        if (user == address(this)) {
            if (lpReward != 0) {
                lpFeeDistribution.mint(address(lpFeeDistribution), lpReward, withPenalty);
            }
            multiFeeDistribution.mint(address(multiFeeDistribution), amount.sub(lpReward), withPenalty);
        } else {
            if (lpReward != 0) {
                lpFeeDistribution.mint(user, lpReward, withPenalty);
            }
            multiFeeDistribution.mint(user, amount.sub(lpReward), withPenalty);
        }
    }

    /**
     * @notice Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
     */
    function forwardReward(address[] memory _rewardTokens) external override {
        for (uint256 i = 0; i < _rewardTokens.length; i += 1) {
            uint256 total = IERC20(_rewardTokens[i]).balanceOf(address(this));
            
            if (operationExpenses != address(0) && operationExpenseRatio != 0) {
                uint256 opExAmount = total.mul(operationExpenseRatio).div(RATIO_DIVISOR);
                if (opExAmount != 0) {
                    IERC20(_rewardTokens[i]).safeTransfer(operationExpenses, opExAmount);
                }
                total = total.sub(opExAmount);
            }
            total = IERC20(_rewardTokens[i]).balanceOf(address(this));
            uint256 lpReward = total.mul(lpLockingRewardRatio).div(RATIO_DIVISOR);
            if (lpReward != 0) {
                IERC20(_rewardTokens[i]).safeTransfer(address(lpFeeDistribution), lpReward);
            }
            uint256 rdntReward = IERC20(_rewardTokens[i]).balanceOf(address(this));
            if (rdntReward != 0) {
                IERC20(_rewardTokens[i]).safeTransfer(address(multiFeeDistribution), rdntReward);
            }
        }
    }

    /**
     * @notice Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
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

// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.7.6;

import "../dependencies/openzeppelin/contracts/IERC20.sol";

interface IMintableToken is IERC20 {
    function mint(address _receiver, uint256 _amount) external returns (bool);
    function burn(uint256 _amount) external returns (bool);
    function setMinter(address _minter) external returns (bool);
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

import {IERC20} from './IERC20.sol';

interface IERC20Detailed is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
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

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {Address} from './Address.sol';

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
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
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

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.6;

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
   */
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
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
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
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