// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./interfaces/IDecubateMasterChef.sol";
import "./interfaces/IDecubateStaking.sol";
import "./interfaces/IDCBVault.sol";
import "./interfaces/IStaking.sol";

contract DecubateTiers is Initializable, OwnableUpgradeable {
  using SafeMathUpgradeable for uint256;

  /**
   *
   * @dev Tier struct
   *

   * @param {minLimit} Minimum amount of dcb to be staked to join tier
   * @param {maxLimit} Maximum amount of dcb to be staked to join tier
   *
   */
  struct Tier {
    uint256 minLimit;
    uint256 maxLimit;
  }

  Tier[] public tierInfo; //Tier storage

  address public dcbTokenAddress; //DCB token instance

  IDecubateMasterChef public legacyStakingContract; //Legacy staking contract instance
  IDecubateMasterChef public compoundStakingContract; // Compound Staking contract instance
  IDecubateStaking public multiAssetStakingContract; //Multi asset Staking contract instance
  IDCBVault public compounderContract; //Staking contract instance
  IStaking public liquidityLocker;

  /**
   *
   * @dev add new tier, only available for owner
   *
   */
  function addTier(uint256 _minLimit, uint256 _maxLimit) external onlyOwner returns (bool) {
    tierInfo.push(Tier({ minLimit: _minLimit, maxLimit: _maxLimit }));
    return true;
  }

  /**
   *
   * @dev update a given tier
   *
   */
  function setTier(
    uint256 tierId,
    uint256 _minLimit,
    uint256 _maxLimit
  ) external onlyOwner returns (bool) {
    require(tierId < tierInfo.length, "Invalid tier Id");

    tierInfo[tierId].minLimit = _minLimit;
    tierInfo[tierId].maxLimit = _maxLimit;
    return true;
  }

  /**
   *
   * @dev set address of legacy staking contract
   *
   */
  function setLegacyStakingContract(address _stakingContract) external onlyOwner {
    legacyStakingContract = IDecubateMasterChef(_stakingContract);
  }

  /**
   *
   * @dev set address of compound staking contract
   *
   */
  function setCompoundingStakingContract(address _stakingContract) external onlyOwner {
    compoundStakingContract = IDecubateMasterChef(_stakingContract);
  }

  /**
   *
   * @dev set address of compound staking contract
   *
   */
  function setMultiAssetStakingContract(address _stakingContract) external onlyOwner {
    multiAssetStakingContract = IDecubateStaking(_stakingContract);
  }

  /**
   *
   * @dev set address of compounder contract
   *
   */
  function setCompounderContract(address _compounder) external onlyOwner {
    compounderContract = IDCBVault(_compounder);
  }

  /**
   *
   * @dev set address of Liquidity locker contract
   *
   */
  function setLiqLockerContract(address _liqContract) external onlyOwner {
    liquidityLocker = IStaking(_liqContract);
  }

  /**
   *
   * @dev set address of dcb token contract
   *
   */
  function setDCBTokenAddress(address _token) external onlyOwner {
    dcbTokenAddress = _token;
  }

  /**
   *
   * @dev get total number of the tiers
   *
   * @return len length of the pools
   *
   */
  function getTiersLength() external view returns (uint256) {
    return tierInfo.length;
  }

  /**
   *
   * @dev get info of all tiers
   *
   * @return {Tier[]} tier info struct
   *
   */
  function getTiers() external view returns (Tier[] memory) {
    return tierInfo;
  }

  /**
   *
   * @dev Get tier of a user
   * Total deposit should be greater than or equal to minimum limit or
   * less than maximum limit. If equal to max limit, user will be given
   * next tier
   *
   * @param addr Address of the user
   *
   * @return flag Whether user belongs to any bracket or not
   * @return pos To which bracket does the user belong
   *
   */

  function getTierOfUser(address addr)
    external
    view
    returns (
      bool flag,
      uint256 pos,
      uint256 multiplier
    )
  {
    uint256 len = tierInfo.length;
    uint256 totalDeposit = getTotalDeposit(addr);
    multiplier = 1;

    for (uint256 i = 0; i < len; i++) {
      if (totalDeposit >= tierInfo[i].minLimit && totalDeposit < tierInfo[i].maxLimit) {
        pos = i;
        flag = true;
        break;
      }
    }

    // compounding effect for final bracket
    if (!flag && totalDeposit > tierInfo[len - 1].maxLimit) {
      pos = len - 1;
      flag = true;
      // multiplier is the users total deposit divided by the
      // minimum limit in the tier. For example Diamond tier is
      // 80,0000+ DCB. The max limit of the tier should be set
      // 159,999 DCB and when the limit is passed the compounding
      // effect will be used to find the number of tickets e.g 2
      // for 160,000
      multiplier = totalDeposit / (tierInfo[len - 1].minLimit);
    }

    return (flag, pos, multiplier);
  }

  function initialize(
    address _legacyStakingContract,
    address _compoundStakingContract,
    address _multiAssetStakingContract,
    address _vault,
    address _liquidityLocker,
    address _token
  ) public initializer {
    __Ownable_init();

    legacyStakingContract = IDecubateMasterChef(_legacyStakingContract);
    compoundStakingContract = IDecubateMasterChef(_compoundStakingContract);
    multiAssetStakingContract = IDecubateStaking(_multiAssetStakingContract);
    compounderContract = IDCBVault(_vault);
    liquidityLocker = IStaking(_liquidityLocker);
    dcbTokenAddress = _token;
  }

  /**
   *
   * @dev Get total amount of dcb staked by a user
   *
   * @param addr Address of the user
   *
   * @return amount Total amount of dcb staked
   */

  function getTotalDeposit(address addr) public view returns (uint256 amount) {
    uint256 len = legacyStakingContract.poolLength();
    uint256 tempAmt;

    for (uint256 i = 0; i < len; i++) {
      (tempAmt, , , , ) = legacyStakingContract.users(i, addr);
      amount = amount.add(tempAmt);
    }

    len = compoundStakingContract.poolLength();

    for (uint256 i = 0; i < len; i++) {
      (, , , , , , address token) = compoundStakingContract.poolInfo(i);

      if (token == dcbTokenAddress) {
        (, , tempAmt, ) = compounderContract.users(i, addr);
        amount = amount.add(tempAmt);
      }
    }

    len = multiAssetStakingContract.poolLength();
    IDecubateStaking.PoolToken memory inputToken;

    for (uint256 i = 0; i < len; i++) {
      (, , , , , inputToken, , , , , ) = multiAssetStakingContract.poolInfo(i);

      if (inputToken.addr == dcbTokenAddress) {
        (tempAmt, , , , ) = multiAssetStakingContract.users(i, addr);
        amount = amount.add(tempAmt);
      }
    }

    len = liquidityLocker.poolLength();
    address _pair;

    for (uint256 i = 0; i < len; i++) {
      (, , , , , , , , _pair, ) = liquidityLocker.poolInfo(i);
      IUniswapV2Pair pair = IUniswapV2Pair(_pair);

      if (pair.token0() == dcbTokenAddress) {
        (uint256 lpTokens, , , , ) = liquidityLocker.users(i, addr);
        (tempAmt, ) = getTokenAmounts(lpTokens, pair);
        amount = amount.add(tempAmt * 2);
      } else if (pair.token1() == dcbTokenAddress) {
        (uint256 lpTokens, , , , ) = liquidityLocker.users(i, addr);
        (, tempAmt) = getTokenAmounts(lpTokens, pair);
        amount = amount.add(tempAmt * 2);
      }
    }
  }

  function getTokenAmounts(uint256 _amount, IUniswapV2Pair _pair)
    public
    view
    returns (uint256 amount0, uint256 amount1)
  {
    (uint256 reserve0, uint256 reserve1, ) = _pair.getReserves();

    amount0 = _amount.mul(reserve0).div(_pair.totalSupply());
    amount1 = _amount.mul(reserve1).div(_pair.totalSupply());
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IStaking {
  struct NFTMultiplier {
    string name;
    address contractAdd;
    bool active;
    uint16 multiplier;
    uint16 startIdx;
    uint16 endIdx;
  }

  struct User {
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint32 lastPayout;
    uint32 depositTime;
    uint256 totalClaimed;
  }

  struct Pool {
    bool isWithdrawLocked;
    uint32 apy;
    uint16 lockPeriodInDays;
    uint32 totalInvestors;
    uint256 totalInvested;
    uint256 hardCap;
    uint32 startDate;
    uint32 endDate;
    address inputToken;
    address rewardToken;
  }

  event Claim(address indexed addr, uint256 amount, uint256 time);

  function setNFT(
    uint16 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint16 _startIdx,
    uint16 _endIdx
  ) external;

  function add(
    bool _isWithdrawLocked,
    uint32 _apy,
    uint16 _lockPeriodInDays,
    uint32 _endDate,
    uint256 _hardCap,
    address _inputToken,
    address _rewardToken
  ) external;

  function set(
    uint16 _pid,
    bool _isWithdrawLocked,
    uint32 _apy,
    uint16 _lockPeriodInDays,
    uint32 _endDate,
    uint256 _hardCap,
    address _inputToken,
    address _rewardToken
  ) external;

  function claim(uint16 _pid) external returns (bool);

  function claimAll() external returns (bool);

  function canClaim(uint16 _pid, address _addr) external view returns (bool);

  function calcMultiplier(uint16 _pid, address _addr) external view returns (uint16);

  function ownsCorrectNFT(uint16 _pid, address _addr) external view returns (bool);

  function poolLength() external view returns (uint256);

  function payout(uint16 _pid, address _addr) external view returns (uint256 value);

  function users(uint256, address)
    external
    view
    returns (
      uint256 totalInvested,
      uint256 totalWithdrawn,
      uint32 lastPayout,
      uint32 depositTime,
      uint256 totalClaimed
    );

  function poolInfo(uint256 _pid)
    external
    view
    returns (
      bool isWithdrawLocked,
      uint32 apy,
      uint16 lockPeriodInDays,
      uint32 totalInvestors,
      uint256 totalInvested,
      uint256 hardCap,
      uint32 startDate,
      uint32 endDate,
      address inputToken,
      address rewardToken
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IDecubateStaking {
  struct NFTMultiplier {
    bool active;
    string name;
    address contractAdd;
    uint16 multiplier;
    uint16 startIdx;
    uint16 endIdx;
  }

  struct PoolToken {
    address addr;
    address router;
  }

  struct Pool {
    uint256 apy;
    uint256 lockPeriodInDays;
    uint256 totalDeposit;
    uint256 hardCap;
    uint256 endDate;
    PoolToken inputToken;
    PoolToken rewardToken;
    uint256 ratio;
    address tradesAgainst;
    uint32 lastUpdatedTime;
    bool isRewardAboveInput;
  }

  function add(
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    address _tradesAgainst,
    PoolToken memory _inputToken,
    PoolToken memory _rewardToken,
    uint256 _hardCap
  ) external;

  function set(
    uint256 _pid,
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    address _tradesAgainst,
    uint256 _hardCap
  ) external;

  function setTokens(
    uint256 _pid,
    PoolToken memory _inputToken,
    PoolToken memory _rewardToken,
    uint256 _maxTransferInput,
    uint256 _maxTransferReward
  ) external;

  function setNFT(
    uint256 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint16 _startIdx,
    uint16 _endIdx
  ) external;

  function stake(uint256 _pid, uint256 _amount) external returns (bool);

  function unStake(uint256 _pid, uint256 _amount) external returns (bool);

  function updateFeeValues(uint8 _feePercent, address _feeWallet) external;

  function updateTimeGap(uint32 newValue) external;

  function claim(uint256 _pid) external returns (bool);

  function claimAll() external returns (bool);

  function updateRatio(uint256 _pid) external returns (bool);

  function updateRatioAll() external returns (bool);

  function poolInfo(uint256)
    external
    view
    returns (
      uint256 apy,
      uint256 lockPeriodInDays,
      uint256 totalDeposit,
      uint256 hardCap,
      uint256 endDate,
      PoolToken memory inputToken,
      PoolToken memory rewardToken,
      uint256 ratio,
      address tradesAgainst,
      uint32 lastUpdatedTime,
      bool isRewardAboveInput
    );

  function users(uint256, address)
    external
    view
    returns (
      uint256 totalInvested,
      uint256 totalWithdrawn,
      uint256 lastPayout,
      uint256 depositTime,
      uint256 totalClaimed
    );

  function canUnstake(uint256 _pid, address _addr) external view returns (bool);

  function calcMultiplier(uint256 _pid, address _addr) external view returns (uint16 multi);

  function poolLength() external view returns (uint256);

  function payout(uint256 _pid, address _addr) external view returns (uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IDecubateMasterChef {
  struct NFTMultiplier {
    bool active;
    string name;
    address contractAdd;
    uint16 multiplier;
    uint16 startIdx;
    uint16 endIdx;
  }

  /**
   *
   * @dev User reflects the info of each user
   *
   *
   * @param {totalInvested} how many tokens the user staked
   * @param {totalWithdrawn} how many tokens withdrawn so far
   * @param {lastPayout} time at which last claim was done
   * @param {depositTime} Time of last deposit
   * @param {totalClaimed} Total claimed by the user
   *
   */
  struct User {
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint256 lastPayout;
    uint256 depositTime;
    uint256 totalClaimed;
  }

  function add(
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    address token
  ) external;

  function set(
    uint256 _pid,
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    uint256 _maxTransfer,
    address token
  ) external;

  function setNFT(
    uint256 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint16 _startIdx,
    uint16 _endIdx
  ) external;

  function stake(uint256 _pid, uint256 _amount) external returns (bool);

  function claim(uint256 _pid) external returns (bool);

  function reinvest(uint256 _pid) external returns (bool);

  function reinvestAll() external returns (bool);

  function claimAll() external returns (bool);

  function handleNFTMultiplier(
    uint256 _pid,
    address _user,
    uint256 _rewardAmount
  ) external returns (uint256);

  function unStake(uint256 _pid, uint256 _amount) external returns (bool);

  function updateCompounder(address _compounder) external;

  function canClaim(uint256 _pid, address _addr) external view returns (bool);

  function calcMultiplier(uint256 _pid, address _addr) external view returns (uint16);

  function payout(uint256 _pid, address _addr) external view returns (uint256 value);

  function poolInfo(uint256)
    external
    view
    returns (
      uint256 apy,
      uint256 lockPeriodInDays,
      uint256 totalDeposit,
      uint256 startDate,
      uint256 endDate,
      uint256 hardCap,
      address token
    );

  function users(uint256, address)
    external
    view
    returns (
      uint256 totalInvested,
      uint256 totalWithdrawn,
      uint256 lastPayout,
      uint256 depositTime,
      uint256 totalClaimed
    );

  function poolLength() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IDCBVault {
  function deposit(uint256 _pid, uint256 _amount) external;

  function withdrawAll(uint256 _pid) external;

  function harvestAll() external;

  function setCallFee(uint256 _callFee) external;

  function pause() external;

  function unpause() external;

  function transferToken(address _addr, uint256 _amount) external returns (bool);

  function withdraw(uint256 _pid, uint256 _shares) external;

  function harvest(uint256 _pid) external;

  function callFee() external view returns (uint256);

  function masterchef() external view returns (address);

  function owner() external view returns (address);

  function paused() external view returns (bool);

  function pools(uint256) external view returns (uint256 totalShares, uint256 lastHarvestedTime);

  function users(uint256, address)
    external
    view
    returns (
      uint256 shares,
      uint256 lastDepositedTime,
      uint256 totalInvested,
      uint256 totalClaimed
    );

  function calculateTotalPendingRewards(uint256 _pid) external view returns (uint256);

  function calculateHarvestDcbRewards(uint256 _pid) external view returns (uint256);

  function getRewardOfUser(address _user, uint256 _pid) external view returns (uint256);

  function getPricePerFullShare(uint256 _pid) external view returns (uint256);

  function canUnstake(address _user, uint256 _pid) external view returns (bool);

  function available(uint256 _pid) external view returns (uint256);

  function balanceOf(uint256 _pid) external view returns (uint256);
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
library SafeMathUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}