// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import {IStakedToken} from "../interfaces/IStakedToken.sol";
import {StakeUIHelperI} from "../interfaces/StakeUIHelperI.sol";
import {IERC20WithNonce} from "../interfaces/IERC20WithNonce.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IUniswapV2Pair} from "../interfaces/IUniswapV2Pair.sol";
import {SafeMath} from '../open-zeppelin/SafeMath.sol';

/**
 * @title StakeUIHelper contract
 * @notice Contract for get user's info about tokens
 **/
contract StakeUIHelper is StakeUIHelperI {
    using SafeMath for uint256;
    using SafeMath for uint128;

    /// @notice Address of the OceanDrive token
    address public immutable OCDR;
    /// @notice Address of the StakedOcdr contract
    IStakedToken public immutable STAKED_OCDR;

    /// @notice Address of the pair for OCDR + BUSD 
    address public immutable LP;
    /// @notice Address of the LPStaking contract
    IStakedToken public immutable STAKED_LP;

    /// @dev Value of the year in seconds
    uint256 constant SECONDS_PER_YEAR = 365 * 24 * 60 * 60;
    /// @dev Value of the apy's precision
    uint256 constant APY_PRECISION = 10000;
    /// @dev Value of the 1 ether
    uint256 constant ONE_ETHER = 1 ether;
    /// @dev Value of the usd
    uint256 internal constant USD_BASE = 1e26;
    
    /**
     * @dev Constructor: initialize contract
     * @param ocdr Address of the OceanDrive token
     * @param stkOcdr Address of the StakedOcdr contract
     * @param lp Address of the pair for OCDR + BUSD
     * @param stkLp Address of the LPStaking contract
     */
    constructor(
        address ocdr,
        IStakedToken stkOcdr,
        address lp,
        IStakedToken stkLp
    ) {
        OCDR = ocdr;
        STAKED_OCDR = stkOcdr;

        LP = lp;
        STAKED_LP = stkLp;
    }

    /**
     * @dev get all user's info about tokens: OCDR and LP
     * @param user Address of the user for get user's data
     * @return User's data about values of the tokens and USD_BASE 
     */
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

    /**
     * @dev get all user's info about staked OCDR tokens
     * @param user Address of the user for get user's data
     * @return User's data about values of the staked OCDR tokens
     */
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

    /**
     * @dev get all user's info about staked LP tokens
     * @param user Address of the user for get user's data
     * @return User's data about values of the staked LP tokens
     */
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

    /**
     * @dev get all user's staked asset data
     * @param stakeToken Address of the staking contract
     * @param underlyingToken Address of the token: OCDR or LP
     * @param user Address of the user for get user's data
     * @param isNonceAvailable Boolean value about nonce (if permit)
     * @return User's data about values of the staked tokens and time frame
     */
    function _getStakedAssetData(
        IStakedToken stakeToken,
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
            data.userPermitNonce = isNonceAvailable
                ? IERC20WithNonce(underlyingToken)._nonces(user)
                : 0;
        }
        return data;
    }

    /**
     * @dev get OCDR token price from PancakeSwap through pair LP
     * @return Price for the token OCDR    
     */
    function _getTokenPriceOCDR() internal view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(LP)
            .getReserves();

        require(reserve0 > 0 && reserve1 > 0, "ERROR_RESERVES_IS_ZERO");

        return
            IUniswapV2Pair(LP).token0() == OCDR
                ? reserve1.mul(ONE_ETHER).div(reserve0)
                : reserve0.mul(ONE_ETHER).div(reserve1);
    }

    /**
     * @dev get LP token price from PancakeSwap through pair LP
     * @return Price for the token LP    
     */
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

    /**
     * @dev get result from calculation APY
     * @param distributionPerSecond Value of the distribution tokens per seconds
     * @param stakeTokenTotalSupply Value of the token's total supply
     * @return Calculated APY  
     */
    function _calculateApy(
        uint256 distributionPerSecond,
        uint256 stakeTokenTotalSupply
    ) internal pure returns (uint256) {
        return
            (distributionPerSecond.mul(SECONDS_PER_YEAR).mul(APY_PRECISION))
                .div(stakeTokenTotalSupply);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

interface IStakedToken {
  
  struct AssetData {
    uint128 emissionPerSecond;
    uint128 lastUpdateTimestamp;
    uint256 index;
  }

  function totalSupply() external view returns (uint256);

  function COOLDOWN_SECONDS() external view returns (uint256);

  function UNSTAKE_WINDOW() external view returns (uint256);

  function DISTRIBUTION_END() external view returns (uint256);

  function assets(address asset) external view returns (AssetData memory);

  function balanceOf(address user) external view returns (uint256);

  function getTotalRewardsBalance(address user) external view returns (uint256);

  function stakersCooldowns(address user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

interface StakeUIHelperI {
    
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
  }

  function getStkOcdrData(address user) external view returns (AssetUIData memory);

  function getStkLPData(address user) external view returns (AssetUIData memory);

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

import {IERC20} from './IERC20.sol';

interface IERC20WithNonce is IERC20 {
  function _nonces(address user) external view returns (uint256);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function totalSupplyAt(uint256 blockNumber) external view returns (uint256);

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

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}