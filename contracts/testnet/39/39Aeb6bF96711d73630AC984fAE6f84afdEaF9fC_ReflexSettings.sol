// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/*
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "contracts/interfaces/uniswap/IUniswapV2Router02.sol";

contract ReflexSettings is Initializable, OwnableUpgradeable {
  using SafeMathUpgradeable for uint256;

  /************************ Sale Settings  ***********************/

  /// @notice The flat fee in BNB (1e18 = 1 BNB)
  uint256 public listingFee;

  /// @notice  The percentage fee for raised funds in the raised token (only applicable for successful sales) (100 = 1%)
  uint256 public launchingFeeInTokenB;

  /// @notice  The percentage fee for raised funds in the partner token (only applicable for successful sales) (100 = 1%)
  uint256 public launchingFeeInTokenA;

  /// @notice  The minimum liquidity percentage (5000 = 50%)
  uint256 public minLiquidityPercentage;

  /// @notice  The ratio of soft cap to hard cap, i.e. 50% means soft cap must be at least 50% of the hard cap
  uint256 public minCapRatio;

  // /// @notice  The minimum amount of time in seconds before liquidity can be unlocked
  // uint256 public minUnlockTimeSeconds;

  /// @notice  The minimum amount of time in seconds a sale has to run for
  uint256 public minSaleTime;

  /// @notice  If set, the maximum amount of time a sale has to run for
  uint256 public maxSaleTime;

  // The early withdraw penalty for users wishing to reclaim deposited BNB/tokens (2 dp precision)
  uint256 public earlyWithdrawPenalty;

  /************************ Stats  ***********************/

  /// @notice Total amount of BNB raised
  uint256 public totalRaised;

  /// @notice Total amount of launched projects
  uint256 public totalProjects;

  /// @notice Total amount of people partcipating
  uint256 public totalParticipants;

  /// @notice List of sales launch status
  mapping(address => bool) public launched;

  /// @notice Reflex Router address
  address public reflexRouter;

  /// @notice The address of the router; this can be pancake or uniswap depending on the network
  IUniswapV2Router02 public exchangeRouter;

  /// @notice Reflex Sale Implementation
  address public saleImpl;

  /// @notice Whitelist Implementation
  address public whitelistImpl;

  /// @notice Proxy admin
  address public proxyAdmin;

  /// @notice Treasury address
  address public treasury;

  /// @notice Sale Update Approver list
  address[] public saleUpdateApprovers;

  /// @notice Approver -> Bool
  mapping(address => bool) public isValidSaleUpdateApprover;

  /**
   * @notice The constructor for the router
   */
  function initialize(
    IUniswapV2Router02 _exchangeRouter,
    address _proxyAdmin,
    address _saleImpl,
    address _whitelistImpl,
    address _treasury
  ) external initializer {
    __Ownable_init();

    exchangeRouter = _exchangeRouter;
    saleImpl = _saleImpl;
    whitelistImpl = _whitelistImpl;
    proxyAdmin = _proxyAdmin;
    treasury = _treasury;

    listingFee = 1e18; // 1 BNB
    launchingFeeInTokenB = 2_50; // 2.5% BNB
    launchingFeeInTokenA = 1_50; // 1.5% Token
    minLiquidityPercentage = 50_00; // 50%
    minCapRatio = 50_00; // 50%
    // minUnlockTimeSeconds = 0;
    minSaleTime = 0 hours;
    maxSaleTime = 0;
    earlyWithdrawPenalty = 10_00; // 10%
  }

  /**
   * @notice Validates the parameters against the data contract
   */
  function validate(
    uint256 soft,
    uint256 hard,
    uint256 liquidity,
    uint256 start,
    uint256 end // uint256 unlockTime
  ) external view {
    require(liquidity >= minLiquidityPercentage, "Liquidity percentage below minimum");
    require(soft.mul(1e5).div(hard).div(10) >= minCapRatio, "Soft cap too low compared to hard cap");
    require(start > block.timestamp, "Sale time cant start in the past!");
    require(end > start, "Sale end has to be in the future from sale start");
    require(maxSaleTime == 0 || end.sub(start) < maxSaleTime, "Sale time too long");
    require(end.sub(start).add(1) >= minSaleTime, "Sale time too short");
    // require(unlockTime >= minUnlockTimeSeconds, "Minimum unlock time is too low");
  }

  /**
   * @notice SETTERS
   */
  function setExchangeRouter(IUniswapV2Router02 _exchangeRouter) external onlyOwner {
    exchangeRouter = _exchangeRouter;
  }

  function setSaleImpl(address _saleImpl) external onlyOwner {
    saleImpl = _saleImpl;
  }

  function setWhitelistImpl(address _whitelistImpl) external onlyOwner {
    whitelistImpl = _whitelistImpl;
  }

  function setReflexRouter(address _reflexRouter) external onlyOwner {
    reflexRouter = _reflexRouter;
  }

  function setProxyAdmin(address _proxyAdmin) external onlyOwner {
    proxyAdmin = _proxyAdmin;
  }

  function setTreasury(address _treasury) external onlyOwner {
    treasury = _treasury;
  }

  function setListingFee(uint256 _listingFee) external onlyOwner {
    listingFee = _listingFee;
  }

  function setLaunchingFeeInTokenB(uint256 _launchingFee) external onlyOwner {
    launchingFeeInTokenB = _launchingFee;
  }

  function setLaunchingFeeInTokenA(uint256 _launchingFee) external onlyOwner {
    launchingFeeInTokenA = _launchingFee;
  }

  function setMinimumLiquidityPercentage(uint256 _liquidityPercentage) external onlyOwner {
    minLiquidityPercentage = _liquidityPercentage;
  }

  function setMinimumCapRatio(uint256 _minimumCapRatio) external onlyOwner {
    minCapRatio = _minimumCapRatio;
  }

  // function setMinimumUnlockTime(uint256 _minimumLiquidityUnlockTime) external onlyOwner {
  //   minUnlockTimeSeconds = _minimumLiquidityUnlockTime;
  // }

  function setMinimumSaleTime(uint256 _minSaleTime) external onlyOwner {
    minSaleTime = _minSaleTime;
  }

  function setMaximumSaleTime(uint256 _maxSaleTime) external onlyOwner {
    maxSaleTime = _maxSaleTime;
  }

  function setTotalRaised(uint256 _amount) external onlyOwner {
    totalRaised = _amount;
  }

  function setTotalProjects(uint256 _amount) external onlyOwner {
    totalProjects = _amount;
  }

  function setTotalParticipants(uint256 _amount) external onlyOwner {
    totalParticipants = _amount;
  }

  /**
   * @notice Reflect launch status
   */
  function launch(
    address sale,
    uint256 raised,
    uint256 participants
  ) external {
    require(_msgSender() == reflexRouter, "Can only be called by the router");
    require(!launched[sale], "You've already called this!");
    launched[sale] = true;

    totalProjects = totalProjects.add(1);
    totalRaised = totalRaised.add(raised);
    totalParticipants = totalParticipants.add(participants);
  }

  function setSaleUpdateApprover(address _approver, bool _allowance) external onlyOwner {
    if (_allowance) {
      bool isNewApprover = true;
      for (uint256 i; i < saleUpdateApprovers.length; i++) {
        if (saleUpdateApprovers[i] == _approver) {
          isNewApprover = false;
          break;
        }
      }

      if (isNewApprover) {
        saleUpdateApprovers.push(_approver);
      }
    }

    isValidSaleUpdateApprover[_approver] = _allowance;
  }
}

// solhint-disable-next-line
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
}

// solhint-disable-next-line
pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
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