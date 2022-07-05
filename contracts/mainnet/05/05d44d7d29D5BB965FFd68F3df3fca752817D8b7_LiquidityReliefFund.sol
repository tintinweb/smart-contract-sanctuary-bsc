// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IGuilderFi.sol";
import "./interfaces/ILiquidityReliefFund.sol";
import "./interfaces/IDexPair.sol";
import "./interfaces/IDexRouter.sol";

contract LiquidityReliefFund is ILiquidityReliefFund {
  using SafeMath for uint256;

  // GuilderFi token contract address
  IGuilderFi internal _token;

  uint256 public constant ACCURACY_FACTOR = 10**18;
  uint256 public constant PERCENTAGE_ACCURACY_FACTOR = 10**4;

  uint256 public constant ACTIVATION_TARGET = 10000; // 100.00%
  uint256 public constant MIDPOINT = 10000; // 100.00%
  uint256 public constant LOW_CAP = 8500; // 85.00%
  uint256 public constant HIGH_CAP = 11500; // 115.00%

  bool internal _hasReachedActivationTarget = false;

  bool private _inSwap = false;

  address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

  modifier onlyToken() {
    require(msg.sender == address(_token), "Sender is not token contract");
    _;
  }

  modifier onlyTokenOwner() {
    require(msg.sender == address(_token.getOwner()), "Sender is not token owner");
    _;
  }

  modifier onlyTokenOrTokenOwner() {
    require(msg.sender == address(_token.getOwner()) || msg.sender == address(_token), "Sender is not contract or owner");
    _;
  }

  constructor(address tokenAddress) {
    _token = IGuilderFi(tokenAddress);
  }

  // External execute function
  function executeLiquidityReliefFund() external override onlyTokenOrTokenOwner {
    
    // check if the backed liquidity > 100% for the first time
    if (!_hasReachedActivationTarget) {
      uint256 backedLiquidityRatio = getBackedLiquidityRatio();

      // turn on the LRF
      if (backedLiquidityRatio >= ACTIVATION_TARGET) {
        _hasReachedActivationTarget = true;
      }
    }

    if (shouldExecute()) {
      _execute();
    }
  }

  function forceExecute() external override onlyTokenOwner {
    _execute();
  }

  function shouldExecute() internal view returns (bool) {
    uint256 backedLiquidityRatio = getBackedLiquidityRatio();

    return _hasReachedActivationTarget
      && backedLiquidityRatio <= HIGH_CAP
      && backedLiquidityRatio >= LOW_CAP;
  }

  function _execute() internal {
    uint256 backedLiquidityRatio = getBackedLiquidityRatio();

    if (backedLiquidityRatio == 0) {
      return;
    }

    if (backedLiquidityRatio > MIDPOINT) {
      buyTokens();
    } else if (backedLiquidityRatio < MIDPOINT) {
      sellTokens();
    }
  }

  function buyTokens() internal {
    if (address(this).balance == 0) {
      return;
    }

    IDexRouter router = getRouter();
    uint256 totalTreasuryAssetValue = getTotalTreasuryAssetValue();
    (uint256 liquidityPoolEth, ) = getLiquidityPoolReserves();
    uint256 ethToBuy = (totalTreasuryAssetValue.sub(liquidityPoolEth)).div(2);

    if (ethToBuy > address(this).balance) {
      ethToBuy = address(this).balance;
    }

    address[] memory path = new address[](2);
    path[0] = router.WETH();
    path[1] = address(_token);

    _inSwap = true;
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethToBuy}(
      0,
      path,
      address(this),
      block.timestamp
    );
    _inSwap = false;
  }

  function sellTokens() internal {
    uint256 tokenBalance = _token.balanceOf(address(this));
    if (tokenBalance == 0) {
      return;
    }

    IDexRouter router = getRouter();
    uint256 totalTreasuryAssetValue = getTotalTreasuryAssetValue();
    (uint256 liquidityPoolEth, uint256 liquidityPoolTokens) = getLiquidityPoolReserves();

    uint256 valueDiff = ACCURACY_FACTOR.mul(liquidityPoolEth.sub(totalTreasuryAssetValue));
    uint256 tokenPrice = ACCURACY_FACTOR.mul(liquidityPoolEth).div(liquidityPoolTokens);
    uint256 tokensToSell = valueDiff.div(tokenPrice.mul(2));

    if (tokensToSell > tokenBalance) {
      tokensToSell = tokenBalance;
    }

    address[] memory path = new address[](2);
    path[0] = address(_token);
    path[1] = router.WETH();

    _inSwap = true;
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokensToSell,
        0,
        path,
        address(this),
        block.timestamp
    );
    _inSwap = false;
  }

  function getBackedLiquidityRatio() public view returns (uint256) {
    (uint256 liquidityPoolEth, ) = getLiquidityPoolReserves();
    if (liquidityPoolEth == 0) {
      return 0;
    }

    uint256 totalTreasuryAssetValue = getTotalTreasuryAssetValue();
    uint256 ratio = PERCENTAGE_ACCURACY_FACTOR.mul(totalTreasuryAssetValue).div(liquidityPoolEth);
    return ratio;
  }

  function getTotalTreasuryAssetValue() internal view returns (uint256) {
    uint256 treasuryEthBalance = address(_token.getTreasuryAddress()).balance;
    return treasuryEthBalance.add(address(this).balance);
  }

  function getLiquidityPoolReserves() internal view returns (uint256, uint256) {
    IDexPair pair = getPair();

    if (address(pair) == address(0)) {
      return (0, 0);
    }

    address token0Address = pair.token0();
    (uint256 token0Reserves, uint256 token1Reserves, ) = pair.getReserves();

    // returns eth reserves, token reserves
    return token0Address == address(_token)
      ? (token1Reserves, token0Reserves)
      : (token0Reserves, token1Reserves);
  }

  function inSwap() public view override returns (bool) {
    return _inSwap;
  }

  function getRouter() internal view returns (IDexRouter) {
    return IDexRouter(_token.getRouter());
  }

  function getPair() internal view returns (IDexPair) {
    return IDexPair(_token.getPair());
  }

  function withdraw(uint256 amount) external override onlyTokenOwner {
    payable(msg.sender).transfer(amount);
  }

  function withdrawTokens(address token, uint256 amount) external override onlyTokenOwner {
    IERC20(token).transfer(msg.sender, amount);
  }

  function burn(uint256 amount) external override onlyTokenOwner {
    _token.transfer(DEAD, amount);
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IGuilderFi {
  // Events
  event LogRebase(uint256 indexed epoch, uint256 totalSupply, uint256 pendingRebases);

  // Fee struct
  struct Fee {
    uint256 treasuryFee;
    uint256 lrfFee;
    uint256 liquidityFee;
    uint256 safeExitFee;
    uint256 burnFee;
    uint256 totalFee;
  }

  // Rebase functions
  function rebase() external;
  function getRebaseRate() external view returns (uint256);
  function maxRebaseBatchSize() external view returns (uint256);

  // Transfer
  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  // Allowance
  function allowance(address owner_, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);

  // Launch token
  function launchToken() external;

  // Set on/off flags
  function setAutoSwap(bool _flag) external;
  function setAutoLiquidity(bool _flag) external;
  function setAutoLrf(bool _flag) external;
  function setAutoSafeExit(bool _flag) external;
  function setAutoRebase(bool _flag) external;

  // Set frequencies
  function setAutoLiquidityFrequency(uint256 _frequency) external;
  function setLrfFrequency(uint256 _frequency) external;
  function setSwapFrequency(uint256 _frequency) external;

  // Address settings
  function setFeeExempt(address _address, bool _flag) external;
  function setBlacklist(address _address, bool _flag) external;

  // Read only functions
  function hasLaunched() external view returns (bool);

  // Addresses
  function getOwner() external view returns (address);
  function getTreasuryAddress() external view returns (address);
  function getSwapEngineAddress() external view returns (address);
  function getLrfAddress() external view returns (address);
  function getAutoLiquidityAddress() external view returns (address);
  function getSafeExitFundAddress() external view returns (address);
  function getPreSaleAddress() external view returns (address);

  // Setup functions
  function setSwapEngine(address _address) external;
  function setLrf(address _address) external;
  function setLiquidityEngine(address _address) external;
  function setSafeExitFund(address _address) external;
  function setPreSaleEngine(address _address) external;
  function setTreasury(address _address) external;
  function setDex(address routerAddress) external;

  // Setup fees
  function setFees(
    bool _isSellFee,
    uint256 _treasuryFee,
    uint256 _lrfFee,
    uint256 _liquidityFee,
    uint256 _safeExitFee,
    uint256 _burnFee
  ) external;

  // Getters - setting flags
  function isAutoSwapEnabled() external view returns (bool);
  function isAutoRebaseEnabled() external view returns (bool);
  function isAutoLiquidityEnabled() external view returns (bool);
  function isAutoLrfEnabled() external view returns (bool);
  function isAutoSafeExitEnabled() external view returns (bool);

  // Getters - frequencies
  function autoSwapFrequency() external view returns (uint256);
  function autoLiquidityFrequency() external view returns (uint256);
  function autoLrfFrequency() external view returns (uint256);

  // Date/time stamps
  function initRebaseStartTime() external view returns (uint256);
  function lastRebaseTime() external view returns (uint256);
  function lastAddLiquidityTime() external view returns (uint256);
  function lastLrfExecutionTime() external view returns (uint256);
  function lastSwapTime() external view returns (uint256);
  function lastEpoch() external view returns (uint256);

  // Dex addresses
  function getRouter() external view returns (address);
  function getPair() external view returns (address);

  // Standard ERC20 functions
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external pure returns (uint8);
  function manualSync() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface ILiquidityReliefFund {
  function executeLiquidityReliefFund() external;
  function forceExecute() external;
  function inSwap() external view returns (bool);
  function withdraw(uint256 amount) external;
  function withdrawTokens(address token, uint256 amount) external;
  function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexPair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
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

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
  event Sync(uint112 reserve0, uint112 reserve1);

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
  function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

pragma solidity ^0.8.4;

interface IDexRouter {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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