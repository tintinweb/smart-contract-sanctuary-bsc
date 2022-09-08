// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma abicoder v2;

import "../interfaces/IStaking.sol";
import "../interfaces/IStakeUIHelper.sol";
import "../interfaces/IERC20WithNonce.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

/// @title StakeUIHelper contract
/// @notice The contract for get user's info about tokens
contract StakeUIHelper is IStakeUIHelper {
    using SafeMath for uint256;
    using SafeMath for uint128;

    /// @notice Address of the OceanDrive token
    /// @notice The address of the OceanDrive token
    address public immutable OCDR;
    /// @notice Address of the OcdrStaking contract
    /// @notice The address of the OcdrStaking contract
    IStaking public immutable STAKED_OCDR;

    /// @notice Address of the pair for OCDR + BUSD 
    /// @notice The address of the pair for OCDR + BUSD 
    address public immutable LP;
    /// @notice Address of the LPStaking contract
    /// @notice The address of the LPStaking contract
    IStaking public immutable STAKED_LP;

    /// @dev Value of the year in seconds
    /// @dev The value of the year in seconds
    uint256 internal constant SECONDS_PER_YEAR = 365 days;
    /// @dev The value of the precision: 10 000 - 100%
    /// @dev Value of the apy's precision
    uint256 internal constant PRECISION = 10_000;
    /// @dev Value of the max percentage, ex: 10000 - 100%
    uint256 internal constant MAX_PERCENTAGE = 10000;
    /// @dev Value of the 1 ether
    /// @dev The value of the 1 ether
    uint256 internal constant ONE_ETHER = 1 ether;
    /// @dev Value of the usd
    /// @dev The value of the usd
    uint256 internal constant USD_BASE = 1e26;
    
    /// @dev Constructor: initialize contract
    /// @param ocdr The address of the OceanDrive token
    /// @param stkOcdr The address of the OcdrStaking contract
    /// @param lp The address of the pair for OCDR + BUSD
    /// @param stkLp The address of the LPStaking contract
    constructor(
        address ocdr,
        address stkOcdr,
        address lp,
        address stkLp
    ) {
        require(ocdr != address(0), "INVALID_OCDR_ADDRESS");
        require(stkOcdr != address(0), "INVALID_OCDRStaking_ADDRESS");
        require(lp != address(0), "INVALID_LP_ADDRESS");
        require(stkLp != address(0), "INVALID_LPStaking_ADDRESS");
        
        OCDR = ocdr;
        STAKED_OCDR = IStaking(stkOcdr);
        
        LP = lp;
        STAKED_LP = IStaking(stkLp);
    }

    /// @dev Gets all user's info about tokens: OCDR and LP
    /// @param user The address of the user for get user's data
    /// @return User's data about values of the tokens and USD_BASE 
    function getUserUIData(address user)
        external
        view
        override
        returns (
            AssetUIData memory,
            AssetUIData memory,
            uint256
        )
    {
        return (getStkOcdrData(user), getStkLPData(user), USD_BASE);
    }

    /// @dev Gets all user's info about staked OCDR tokens
    /// @param user The address of the user for get user's data
    /// @return User's data about values of the staked OCDR tokens
    function getStkOcdrData(address user)
        public
        view
        override
        returns (AssetUIData memory)
    {
        AssetUIData memory data = _getStakedAssetData(
            STAKED_OCDR,
            OCDR,
            user,
            true
        );

        data.stakeTokenPrice = data.rewardTokenPrice;
        data.stakeApy = _calculateApy(
            data.distributionPerSecond,
            data.stakeTokenTotalSupply
        );
        return data;
    }

    /// @dev Gets all user's info about staked LP tokens
    /// @param user The address of the user for get user's data
    /// @return User's data about values of the staked LP tokens
    function getStkLPData(address user)
        public
        view
        override
        returns (AssetUIData memory)
    {
        AssetUIData memory data = _getStakedAssetData(
            STAKED_LP,
            LP,
            user,
            false
        );
        data.stakeTokenPrice = _getTokenPriceLP();

        data.stakeApy = _calculateApy(
            (data.distributionPerSecond).mul(data.rewardTokenPrice),
            (data.stakeTokenTotalSupply).mul(data.stakeTokenPrice)
        );

        return data;
    }

    /// @dev Gets all user's staked asset data
    /// @param stakeToken The address of the staking contract
    /// @param underlyingToken The address of the token: OCDR or LP
    /// @param user The address of the user for get user's data
    /// @param isNonceAvailable The boolean value about nonce (if permit)
    /// @return User's data about values of the staked tokens and time frame
    function _getStakedAssetData(
        IStaking stakeToken,
        address underlyingToken,
        address user,
        bool isNonceAvailable
    ) internal view returns (AssetUIData memory) {
        AssetUIData memory data;

        data.stakeTokenTotalSupply = stakeToken.totalSupply();
        data.stakeCooldownSeconds = stakeToken.COOLDOWN_SECONDS();
        data.stakeUnstakeWindow = stakeToken.UNSTAKE_WINDOW();
        data.rewardTokenPrice = _getTokenPriceOCDR();
        data.distributionEnd = stakeToken.DISTRIBUTION_END();
        if (block.timestamp < data.distributionEnd) {
            data.distributionPerSecond = stakeToken
                .assets(address(stakeToken))
                .emissionPerSecond;
        }

        if (user != address(0)) {
            data.underlyingTokenUserBalance = IERC20(underlyingToken).balanceOf(
                user
            );
            data.stakeTokenUserBalance = stakeToken.balanceOf(user);
            data.userIncentivesToClaim = stakeToken.getTotalRewardsBalance(
                user
            );
            data.userCooldown = stakeToken.stakersCooldowns(user);
            data.percentSanctions = _getUserSanctions(data.stakeCooldownSeconds, data.userCooldown);
            data.userPermitNonce = isNonceAvailable
                ? IERC20WithNonce(underlyingToken)._nonces(user)
                : 0;
        }
        return data;
    }

    /// @dev Gets OCDR token price from PancakeSwap through pair LP
    /// @return The price for the token OCDR    
    function _getTokenPriceOCDR() internal view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(LP)
            .getReserves();

        require(reserve0 > 0 && reserve1 > 0, "ERROR_RESERVES_IS_ZERO");

        return
            IUniswapV2Pair(LP).token0() == OCDR
                ? reserve1.mul(ONE_ETHER).div(reserve0)
                : reserve0.mul(ONE_ETHER).div(reserve1);
    }

    /// @dev Gets LP token price from PancakeSwap through pair LP
    /// @return The price for the token LP    
    function _getTokenPriceLP() internal view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(LP)
            .getReserves();

        require(reserve0 > 0 && reserve1 > 0, "ERROR_RESERVES_IS_ZERO");

        uint256 value1 = IUniswapV2Pair(LP).token0() == OCDR
            ? reserve1.mul(2)
            : reserve0.mul(2);

        uint256 supplyShifted = IERC20(LP).totalSupply();

        return value1.mul(ONE_ETHER).div(supplyShifted);
    }

    /// @dev Gets user's info about sanction's percent
    /// @param cooldownSeconds The general cooldown duration in seconds
    /// @param cooldownStartTimestamp The user's cooldown seconds
    /// @return The value of the sanction's percent
    function _getUserSanctions(uint256 cooldownSeconds, uint256 cooldownStartTimestamp)
        internal
        view
        returns (uint256)
    {
        if(block.timestamp < cooldownStartTimestamp.add(cooldownSeconds))
            return PRECISION.sub((block.timestamp.sub(cooldownStartTimestamp))
                .mul(PRECISION).div(cooldownSeconds));
        else
            return 0;
    }

    /// @dev Gets result from calculation APY
    /// @param distributionPerSecond The value of the distribution tokens per seconds
    /// @param stakeTokenTotalSupply The value of the token's total supply
    /// @return The calculated APY
    function _calculateApy(
        uint256 distributionPerSecond,
        uint256 stakeTokenTotalSupply
    ) internal pure returns (uint256) {
        return
            (distributionPerSecond.mul(SECONDS_PER_YEAR).mul(PRECISION))
                .div(stakeTokenTotalSupply);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

interface IStaking {
  /// @notice Structure which describe asset data
  /// @dev It is used for saving data about asset config
  /// @param emissionPerSecond The value of the emissions per second
  /// @param lastUpdateTimestamp The last moment distribution was updated
  /// @param index The current index of the distribution
  struct AssetData {
    uint128 emissionPerSecond;
    uint128 lastUpdateTimestamp;
    uint256 index;
  }

  /// @dev Shows value of the total supply in the contract
  /// @return The value of the total supply
  function totalSupply() external view returns (uint256);

  /// @dev Shows general cooldown period to redeem
  /// @return The value of the available seconds to redeem
  function COOLDOWN_SECONDS() external view returns (uint256);

  /// @dev Shows the available seconds to redeem once the cooldown period is fullfilled
  /// @return The value of the available seconds
  function UNSTAKE_WINDOW() external view returns (uint256);

  /// @dev Shows value of the distribution end in the staking contract
  /// @return The value of the distribution end
  function DISTRIBUTION_END() external view returns (uint256);

  /// @dev Shows data about asset
  /// @param asset The address of the asset for gets data
  /// @return The structure with asset's data
  function assets(address asset) external view returns (AssetData memory);

  /// @dev Shows balance of the user
  /// @param user The address of the user for gets data about available balance
  /// @return The amount of the user's balance
  function balanceOf(address user) external view returns (uint256);

  /// @dev Shows available reward's amount for the user
  /// @param user The address of the user for gets data about available rewards
  /// @return The amount of the rewards
  function getTotalRewardsBalance(address user) external view returns (uint256);

  /// @dev Shows available cooldown seconds to redeem for the user
  /// @param user The address of the user for gets data about cooldown seconds
  /// @return The value of the available cooldown period for the user's address
  function stakersCooldowns(address user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma abicoder v2;

interface IStakeUIHelper {
  /// @notice Structure which describe general and user's data for UI
  /// @dev It is used for saving general and user's data for UI
  /// @param stakeTokenTotalSupply The total supply from staking contract
  /// @param stakeCooldownSeconds The value of cooldown seconds from staking
  /// @param stakeUnstakeWindow The value of unstake window from staking
  /// @param stakeTokenPrice The calculated token's price for stakes
  /// @param rewardTokenPrice The calculated token's price for rewards
  /// @param stakeApy The value of the calculated APY
  /// @param distributionPerSecond The value of the distribution per second
  /// @param distributionEnd The value of the end distribution from staking
  /// @param stakeTokenUserBalance The user's balance on the staking contract
  /// @param underlyingTokenUserBalance The user's balance on the token contract
  /// @param userCooldown The value of cooldown seconds for user
  /// @param userIncentivesToClaim The value of user's rewards for claim
  /// @param userPermitNonce The value of the nonce for user from token contract
  /// @param percentSanctions The percent of the sanctions if redeem before end cooldown
  struct AssetUIData {
    uint256 stakeTokenTotalSupply;
    uint256 stakeCooldownSeconds;
    uint256 stakeUnstakeWindow;
    uint256 stakeTokenPrice;
    uint256 rewardTokenPrice;
    uint256 stakeApy;
    uint128 distributionPerSecond;
    uint256 distributionEnd;
    uint256 stakeTokenUserBalance;
    uint256 underlyingTokenUserBalance;
    uint256 userCooldown;
    uint256 userIncentivesToClaim;
    uint256 userPermitNonce;
    uint256 percentSanctions;
  }

  /// @dev Shows all user's info about staked OCDR tokens
  /// @param user Address of the user for get user's data
  /// @return User's data about values of the staked OCDR tokens
  function getStkOcdrData(address user) external view returns (AssetUIData memory);

  /// @dev Shows all user's info about staked LP tokens
  /// @param user Address of the user for get user's data
  /// @return User's data about values of the staked LP tokens
  function getStkLPData(address user) external view returns (AssetUIData memory);

  /// @dev Shows all user's info about tokens: OCDR and LP
  /// @param user Address of the user for get user's data
  /// @return User's data about values of the tokens and USD_BASE
  function getUserUIData(address user)
    external
    view
    returns (
      AssetUIData memory,
      AssetUIData memory,
      uint256
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20WithNonce is IERC20 {
  /// @dev Shows nonces for user from token contract
  /// @param user The user's address for gets nonces
  /// @return The value of the nonces
  function _nonces(address user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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