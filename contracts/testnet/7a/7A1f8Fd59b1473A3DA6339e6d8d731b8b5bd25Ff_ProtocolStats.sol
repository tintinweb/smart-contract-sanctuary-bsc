pragma solidity ^0.6.0;
import "../Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

pragma solidity >=0.4.24 <0.7.0;


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
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

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
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

pragma solidity ^0.6.0;

import "../GSN/Context.sol";
import "../Initializable.sol";
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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
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

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IBoardroom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _member) external view returns (uint256);

    function share() external view returns (address);

    function earned(address _member) external view returns (uint256);

    function canClaimReward() external view returns (bool);

    function canWithdraw(address _member) external view returns (bool);

    function epoch() external view returns (uint256);

    function nextEpochPoint() external view returns (uint256);

    function getV3sPrice() external view returns (uint256);

    function setOperator(address _operator) external;

    function setLockUp(uint256 _withdrawLockupEpochs) external;

    function stake(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function exit() external;

    function claimReward() external;

    function allocateSeigniorage(uint256 _amount) external;

    function governanceRecoverUnsupported(address _token, uint256 _amount, address _to) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IEpoch {
    function epoch() external view returns (uint256);

    function nextEpochPoint() external view returns (uint256);

    function nextEpochLength() external view returns (uint256);

    function getPegPrice() external view returns (int256);

    function getPegPriceUpdated() external view returns (int256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IPriceChecker {
    function getTokenPriceToUsd(address token) external view returns (uint256);

    function getLpPriceToUsd(address lp) external view returns (uint256);

    function getVvsPriceToUsd() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IRewardPool {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function withdrawAll(uint256 _pid) external;

    function harvestAllRewards() external;

    function pendingReward(uint256 _pid, address _user) external view returns (uint256);

    function pendingAllRewards(address _user) external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function poolLength() external view returns (uint256);

    function getPoolInfo(uint256 _pid) external view returns (address _lp, uint256 _allocPoint);

    function getRewardPerSecond() external view returns (uint256);

    function updateRewardRate(uint256 _newRate) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IEpoch.sol";

interface ITreasury is IEpoch {
    function getV3sPrice() external view returns (uint256);

    function getV3sUpdatedPrice() external view returns (uint256);

    function getNextExpansionRate() external view returns (uint256);

    function getNextExpansionAmount() external view returns (uint256);

    function previousEpochV3sPrice() external view returns (uint256);

    function boardroom() external view returns (address);

    function boardroomSharedPercent() external view returns (uint256);

    function daoFund() external view returns (address);

    function daoFundSharedPercent() external view returns (uint256);

    function marketingFund() external view returns (address);

    function marketingFundSharedPercent() external view returns (uint256);

    function insuranceFund() external view returns (address);

    function insuranceFundSharedPercent() external view returns (uint256);

    function getBondDiscountRate() external view returns (uint256);

    function getBondPremiumRate() external view returns (uint256);

    function buyBonds(uint256 amount, uint256 targetPrice) external;

    function redeemBonds(uint256 amount, uint256 targetPrice) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IUniswapV2Pair {
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

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";

import "../interfaces/ITreasury.sol";
import "../interfaces/IPriceChecker.sol";
import "../interfaces/IBoardroom.sol";
import "../interfaces/IRewardPool.sol";
import "../interfaces/IUniswapV2Pair.sol";

contract ProtocolStats is OwnableUpgradeSafe {
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    address public v3s;
    address public vshare;
    address public vbond;
    address public wcro;
    address public vvs;
    address public pairV3sVvs;
    address public pairVshareWcro;

    address public v3sPool;
    address public vsharePool;

    address public treasury;
    address public priceChecker;

    /* =================== Added variables (need to keep orders for proxy to work) =================== */
    // ...

    /* =================== Events =================== */

    /* =================== Modifier =================== */

    /* ========== VIEW FUNCTIONS ========== */

    function getTokenPriceToUsd(address token) public view returns (uint256) {
        return IPriceChecker(priceChecker).getTokenPriceToUsd(token);
    }

    function getLpPriceToUsd(address lp) external view returns (uint256) {
        return IPriceChecker(priceChecker).getLpPriceToUsd(lp);
    }

    function getV3sPriceToUsd() public view returns (uint256) {
        return IPriceChecker(priceChecker).getTokenPriceToUsd(v3s);
    }

    function getVvsPriceToUsd() public view returns (uint256) {
        return IPriceChecker(priceChecker).getVvsPriceToUsd();
    }

    function getWcroPriceToUsd() external view returns (uint256) {
        return IPriceChecker(priceChecker).getTokenPriceToUsd(wcro);
    }

    function insuranceTotalDollarValue() public view returns (uint256) {
        address _insuranceAddress = ITreasury(treasury).insuranceFund();
        IPriceChecker _priceChecker = IPriceChecker(priceChecker);
        uint256 _v3sBalance = IERC20(v3s).balanceOf(_insuranceAddress);
        uint256 _vshareBalance = IERC20(vshare).balanceOf(_insuranceAddress);
        uint256 _wcroBalance = IERC20(wcro).balanceOf(_insuranceAddress);
        uint256 _vvsBalance = IERC20(vvs).balanceOf(_insuranceAddress);
        uint256 _v3sUsdValue = _priceChecker.getTokenPriceToUsd(v3s).mul(_v3sBalance).div(1e18);
        uint256 _vshareUsdValue = _priceChecker.getTokenPriceToUsd(vshare).mul(_vshareBalance).div(1e18);
        uint256 _wcroUsdValue = _priceChecker.getTokenPriceToUsd(wcro).mul(_wcroBalance).div(1e18);
        uint256 _vvsUsdValue = _priceChecker.getTokenPriceToUsd(vvs).mul(_vvsBalance).div(1e18);
        return _v3sUsdValue.add(_vshareUsdValue).add(_wcroUsdValue).add(_vvsUsdValue);
    }

    function addresses() external view returns (
        address v3sAddress, address vshareAddress, address vbondAddress, address wcroAddress, address pairV3sVvsAddress, address pairVshareWcroAddress,
        address v3sPoolAddress, address vsharePoolAddress,
        address treasuryAddress, address boardroomAddress, address daoAddress, address insuranceAddress) {

        v3sAddress = v3s;
        vshareAddress = vshare;
        vbondAddress = vbond;
        wcroAddress = wcro;

        pairV3sVvsAddress = pairV3sVvs;
        pairVshareWcroAddress = pairVshareWcro;

        v3sPoolAddress = v3sPool;
        vsharePoolAddress = vsharePool;

        ITreasury _treasury = ITreasury(treasury);
        treasuryAddress = treasury;
        boardroomAddress = _treasury.boardroom();
        daoAddress = _treasury.daoFund();
        insuranceAddress = _treasury.insuranceFund();
    }

    function tokenStats() external view returns (
        uint256 v3sPrice, uint256 vsharePrice, uint256 vbondPrice, uint256 vvsPrice, uint256 v3sVvsLpPrice, uint256 vshareWcroLpPrice,
        uint256 v3sSafePrice, uint256 v3sCirculation, uint256 vshareCirculation, uint256[] memory tokenSupplies
    ) {
        tokenSupplies = new uint256[](3);
        {
            tokenSupplies[0] = IERC20(v3s).totalSupply();
            tokenSupplies[1] = IERC20(vshare).totalSupply();
            tokenSupplies[2] = IERC20(vbond).totalSupply();
            v3sCirculation = tokenSupplies[0].sub(IERC20(v3s).balanceOf(v3sPool));
            vshareCirculation = tokenSupplies[1].sub(IERC20(vshare).balanceOf(vsharePool));
        }
        {
            IPriceChecker _priceChecker = IPriceChecker(priceChecker);
            v3sPrice = getV3sPriceToUsd();
            vsharePrice = _priceChecker.getTokenPriceToUsd(vshare);
            vvsPrice = getVvsPriceToUsd();
            v3sVvsLpPrice = _priceChecker.getLpPriceToUsd(pairV3sVvs);
            vshareWcroLpPrice = _priceChecker.getLpPriceToUsd(pairVshareWcro);
        }
        uint256 _vbondPremiumRate;
        {
            ITreasury _treasury = ITreasury(treasury);
            _vbondPremiumRate = _treasury.getBondPremiumRate();
            v3sSafePrice = insuranceTotalDollarValue().mul(1e18).div(v3sCirculation);
        }
        vbondPrice = v3sPrice;
        if (_vbondPremiumRate > 1e18) {
            vbondPrice = v3sPrice.mul(_vbondPremiumRate).div(1e18);
        }}

    function _calculateTotalEarnedPerYear(address _pool, address _share) internal view returns (uint256 _totalEarned, uint256 _sharePrice) {
        _sharePrice = IPriceChecker(priceChecker).getTokenPriceToUsd(_share);
        _totalEarned = IRewardPool(_pool).getRewardPerSecond().mul(365 days).mul(_sharePrice).div(1e18);
    }

    function poolStats(address _pool) public view returns (uint256 poolLength, uint256 totalTvl, address reward, uint256 rewardPrice,
        address[] memory lps, uint256[] memory allocPoints, uint256[] memory tvls, uint256[] memory aprs, uint256[] memory lpPrices) {
        poolLength = IRewardPool(_pool).poolLength();
        lps = new address[](poolLength);
        allocPoints = new uint256[](poolLength);
        tvls = new uint256[](poolLength);
        aprs = new uint256[](poolLength);
        lpPrices = new uint256[](poolLength);
        uint256 _totalAllocPoint = IRewardPool(_pool).totalAllocPoint();
        for (uint i = 0; i < poolLength; i++) {
            (lps[i], allocPoints[i]) = IRewardPool(_pool).getPoolInfo(i);
            {
                uint256 _poolBal = IERC20(lps[i]).balanceOf(_pool);
                lpPrices[i] = IPriceChecker(priceChecker).getLpPriceToUsd(lps[i]);
                tvls[i] = _poolBal.mul(lpPrices[i]).div(1e18);
            }
            {
                reward = (_pool == v3sPool) ? v3s : vshare;
                uint256 _totalEarnedPerYear;
                (_totalEarnedPerYear, rewardPrice) = _calculateTotalEarnedPerYear(_pool, reward);
                uint256 _poolEarnedPerYear = _totalEarnedPerYear.mul(allocPoints[i]).div(_totalAllocPoint);
                aprs[i] = _poolEarnedPerYear.mul(1e18).div(tvls[i]);
            }
            totalTvl = totalTvl.add(tvls[i]);
        }
    }

    function v3sPoolStats() public view returns (uint256 poolLength, uint256 totalTvl, address reward, uint256 rewardPrice,
        address[] memory lps, uint256[] memory allocPoints, uint256[] memory tvls, uint256[] memory aprs, uint256[] memory lpPrices) {
        return poolStats(v3sPool);
    }

    function vsharePoolStats() public view returns (uint256 poolLength, uint256 totalTvl, address reward, uint256 rewardPrice,
        address[] memory lps, uint256[] memory allocPoints, uint256[] memory tvls, uint256[] memory aprs, uint256[] memory lpPrices) {
        return poolStats(vsharePool);
    }

    function boardroomStat() external view returns (
        uint256 epoch, uint256 nextEpochPoint, uint256 twap,
        address share, uint256 sharePrice, uint256 totalShare, uint256 tvl, uint256 nextExpansionRate, uint256 nextExpansionAmount, uint256 v3sEarnPerShare, uint256 apr) {
        ITreasury _treasury = ITreasury(treasury);
        IPriceChecker _priceChecker = IPriceChecker(priceChecker);
        epoch = _treasury.epoch();
        nextEpochPoint = _treasury.nextEpochPoint();
        twap = _treasury.getV3sUpdatedPrice();
        uint256 _treasurySharedPercent = _treasury.boardroomSharedPercent();
        if (_treasurySharedPercent > 0) {
            address _boardroom = _treasury.boardroom();
            share = IBoardroom(_boardroom).share();
            sharePrice = _priceChecker.getTokenPriceToUsd(share);
            totalShare = IBoardroom(_boardroom).totalSupply();
            tvl = totalShare.mul(sharePrice).div(1e18);
            nextExpansionRate = _treasury.getNextExpansionRate();
            nextExpansionAmount = _treasury.getNextExpansionAmount().mul(_treasurySharedPercent).div(10000);
            if (totalShare > 0) {
                v3sEarnPerShare = nextExpansionAmount.mul(1e18).div(totalShare);
                if (sharePrice > 0) {
                    // = (v3sEarnPerShare * totalShare * v3sPrice) / TVL
                    // = (v3sEarnPerShare * v3sPrice * 1460) / sharePrice
                    apr = v3sEarnPerShare.mul(1460).mul(_priceChecker.getTokenPriceToUsd(v3s)).div(sharePrice);
                }
            }
        }
    }

    function tvls() external view returns (uint256 v3sPoolTvl, uint256 vsharePoolTvl, uint256 boardroomTvl, uint256 totalTvl) {
        ITreasury _treasury = ITreasury(treasury);
        IPriceChecker _priceChecker = IPriceChecker(priceChecker);

        (, v3sPoolTvl, , , , , , ,) = v3sPoolStats();
        (, vsharePoolTvl, , , , , , ,) = vsharePoolStats();

        uint256 _sharePrice = _priceChecker.getTokenPriceToUsd(vshare);
        uint256 _totalShare = IBoardroom(_treasury.boardroom()).totalSupply();
        boardroomTvl = _totalShare.mul(_sharePrice).div(1e18);

        totalTvl = v3sPoolTvl.add(vsharePoolTvl).add(boardroomTvl);
    }

    /* ========== GOVERNANCE ========== */

    function initialize(
        address _v3s,
        address _vshare,
        address _vbond,
        address _wcro,
        address _vvs,
        address _pairV3sVvs,
        address _pairVshareWcro,
        address _v3sPool,
        address _vsharePool,
        address _treasury,
        address _priceChecker
    ) external initializer {
        OwnableUpgradeSafe.__Ownable_init();

        v3s = _v3s;
        vshare = _vshare;
        vbond = _vbond;
        wcro = _wcro;
        vvs = _vvs;

        pairV3sVvs = _pairV3sVvs;
        pairVshareWcro = _pairVshareWcro;

        v3sPool = _v3sPool;
        vsharePool = _vsharePool;

        treasury = _treasury;
        priceChecker = _priceChecker;
    }

    function setPriceChecker(address _priceChecker) external onlyOwner {
        priceChecker = _priceChecker;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    /* ========== EMERGENCY ========== */

    function rescueStuckErc20(IERC20 _token) external onlyOwner {
        _token.transfer(owner(), _token.balanceOf(address(this)));
    }
}