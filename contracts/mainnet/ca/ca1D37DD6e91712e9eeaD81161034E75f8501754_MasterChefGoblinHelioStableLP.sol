/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// File: openzeppelin-solidity-2.3.0/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity-2.3.0/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

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

// File: @uniswap/v2-core/contracts/libraries/Math.sol

pragma solidity =0.5.16;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: contracts/libs/Initializable.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.24 <0.7.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
contract Initializable {
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
    require(
      _initializing || _isConstructor() || !_initialized,
      'Initializable: contract is already initialized'
    );

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

  /// @dev Returns true if and only if the function is running in the constructor
  function _isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint cs;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      cs := extcodesize(self)
    }
    return cs == 0;
  }
}

// File: contracts/libs/ContextUpgradeable.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.5.16;


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
contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// File: contracts/libs/OwnableUpgradeable.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.5.16;



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
contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// File: contracts/libs/ReentrancyGuardUpgradeSafe.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.5.16;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuardUpgradeSafe is Initializable {
  // counter to allow mutex lock with only one SSTORE operation
  uint private _guardCounter;

  function __ReentrancyGuardUpgradeSafe__init() internal initializer {
    // The counter starts at one to prevent changing it from zero to a non-zero
    // value, which is a more expensive operation.
    _guardCounter = 1;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter, 'ReentrancyGuard: reentrant call');
  }

  uint[50] private ______gap;
}

// File: contracts/Strategy.sol

pragma solidity 0.5.16;

interface Strategy {
    /// @dev Execute worker strategy. Take LP tokens + ETH. Return LP tokens + ETH.
    /// @param user The original user that is interacting with the operator.
    /// @param debt The user's total debt, for better decision making context.
    /// @param data Extra calldata information passed along to this strategy.
    function execute(address user, uint256 debt, bytes calldata data) external payable;
}

// File: contracts/SafeToken.sol

pragma solidity 0.5.16;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

// File: contracts/Goblin.sol

pragma solidity 0.5.16;

interface Goblin {
    /// @dev Work on a (potentially new) position. Optionally send ETH back to Bank.
    function work(uint256 id, address user, uint256 debt, bytes calldata data) external payable;

    /// @dev Re-invest whatever the goblin is working on.
    function reinvest() external;

    /// @dev Return the amount of ETH wei to get back if we are to liquidate the position.
    function health(uint256 id) external view returns (uint256);

    /// @dev Liquidate the given position to ETH. Send all ETH back to Bank.
    function liquidate(uint256 id) external;
}

// File: contracts/helio/IFarming.sol

pragma solidity 0.5.16;

contract IFarming {
  // Info of each user.
  struct UserInfo {
    uint256 shares;
    uint256 rewardDebt;
    uint256 claimable;
  }

  mapping(uint256 => mapping(address => UserInfo)) public userInfo;

  function rewardToken() external view returns (address);

  function poolLength() external view returns (uint256);

  function addPool(
    address _token,
    address _strategy,
    bool _withUpdate
  ) external returns (uint256);

  function setClaimReceiver(address _receiver) external;

  function setBlockThirdPartyActions(bool _block) external;

  function stakedWantTokens(uint256 _pid, address _user) external view returns (uint256);

  function massUpdatePools() external;

  function updatePool(uint256 _pid) external returns (uint256 accRewardPerShare);

  function claimableReward(address _user, uint256[] calldata _pids) external view returns (uint256[] memory);

  function deposit(
    uint256 _pid,
    uint256 _wantAmt,
    bool _claimRewards,
    address _userAddress
  ) external returns (uint256);

  function withdraw(
    uint256 _pid,
    uint256 _wantAmt,
    bool _claimRewards
  ) external returns (uint256);

  function withdrawAll(uint256 _pid, bool _claimRewards) external returns (uint256);

  function claim(address _user, uint256[] calldata _pids) external returns (uint256);

  function inCaseTokensGetStuck(address _token, uint256 _amount) external;

  function emergencyWithdraw(uint256 _pid) external;
}

// File: contracts/interfaces/IPancakeStableFactory.sol

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

contract IPancakeStableFactory {
    struct StableSwapPairInfo {
        address swapContract;
        address token0;
        address token1;
        address LPContract;
    }
    function N_COINS() external returns (uint256);
    function getPairInfo(address _tokenA, address _tokenB) external view returns (StableSwapPairInfo memory info);
}

// File: contracts/interfaces/IPancakeStableRouter.sol

pragma solidity 0.5.16;

contract IPancakeStableRouter {
    function N_COINS() external returns (uint256);
    function coins(uint256) external returns (uint256);
    function balances(uint256) external returns (uint256);
    function STABLESWAP_FACTORY() external returns (address);
    function token() external returns (address);
    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external;
    function add_liquidity(uint256[] calldata amounts, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 _amount, uint256[] calldata min_amounts) external;
    function remove_liquidity_one_coin(
        uint256 _token_amount,
        uint256 i,
        uint256 min_amount
    ) external;
    function calc_withdraw_one_coin(uint256 _token_amount, uint256 i) external view returns (uint256);
    function get_virtual_price() external view returns (uint256);
}

// File: contracts/MasterChefGoblinHelioStableLP.sol

pragma solidity 0.5.16;














contract MasterChefGoblinHelioStableLP is Initializable, ReentrancyGuardUpgradeSafe, OwnableUpgradeable, Goblin {
    /// @notice Libraries
    using SafeToken for address;
    using SafeMath for uint256;

    /// @notice Events
    event Reinvest(address indexed caller, uint256 reward, uint256 bounty);
    event AddShare(uint256 indexed id, uint256 share);
    event RemoveShare(uint256 indexed id, uint256 share);
    event Liquidate(uint256 indexed id, uint256 wad);

    /// @notice Immutable variables
    IPancakeStableFactory public factory;
    IPancakeStableRouter public router;
    IUniswapV2Pair public lpToken;
    IFarming public farming;
    address public constant baseToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public fToken;
    address public rewardToken;
    address public constant operator = 0xef5C873494902Ce586beD6D515129492Cc65e8ae;
    uint256 public farmingPid;

    /// @notice Mutable state variables
    mapping(uint256 => uint256) public shares;
    mapping(address => bool) public okStrats;
    uint256 public totalShare;
    Strategy public addStrat;
    Strategy public liqStrat;
    uint256 public reinvestBountyBps;
    bool public reinvestToTreasury;
    address public treasuryAddr;

    function initialize (
        IPancakeStableFactory _factory,
        IPancakeStableRouter _router,      
        Strategy _addStrat,
        Strategy _liqStrat,
        uint256 _reinvestBountyBps,
        bool _reinvestToTreasury,
        address _treasuryAddr,
        IFarming _farming,
        uint256 _farmingPid,
        address _token0,
        address _token1
    ) public initializer {
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeSafe.__ReentrancyGuardUpgradeSafe__init();
        factory = _factory;
        router = _router;
        farming = _farming;
        // Get lpToken and fToken from MasterChef pool
        farmingPid = _farmingPid;
        fToken = _token0 == baseToken ? _token1 : _token0;
        IPancakeStableFactory.StableSwapPairInfo memory pairInfo = factory.getPairInfo(fToken, baseToken);
        lpToken = IUniswapV2Pair(pairInfo.LPContract);
        rewardToken = address(farming.rewardToken());
        addStrat = _addStrat;
        liqStrat = _liqStrat;
        okStrats[address(addStrat)] = true;
        okStrats[address(liqStrat)] = true;
        reinvestBountyBps = _reinvestBountyBps;
        reinvestToTreasury = _reinvestToTreasury;
        treasuryAddr = _treasuryAddr;
        lpToken.approve(address(farming), uint256(-1)); // 100% trust in the farming
        lpToken.approve(address(router), uint256(-1)); // 100% trust in the router
        fToken.safeApprove(address(router), uint256(-1)); // 100% trust in the router
        rewardToken.safeApprove(address(router), uint256(-1)); // 100% trust in the router
    }

    /// @dev Require that the caller must be an EOA account to avoid flash loans.
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "not eoa");
        _;
    }

    /// @dev Require that the caller must be the operator (the bank).
    modifier onlyOperator() {
        require(msg.sender == operator, "not operator");
        _;
    }

    /// @dev Return the entitied LP token balance for the given shares.
    /// @param share The number of shares to be converted to LP balance.
    function shareToBalance(uint256 share) public view returns (uint256) {
        if (totalShare == 0) return share; // When there's no share, 1 share = 1 balance.
        (uint256 totalBalance, , ) = farming.userInfo(farmingPid, address(this));
        return share.mul(totalBalance).div(totalShare);
    }

    /// @dev Return the number of shares to receive if staking the given LP tokens.
    /// @param balance the number of LP tokens to be converted to shares.
    function balanceToShare(uint256 balance) public view returns (uint256) {
        if (totalShare == 0) return balance; // When there's no share, 1 share = 1 balance.
        (uint256 totalBalance, , ) = farming.userInfo(farmingPid, address(this));
        return balance.mul(totalShare).div(totalBalance);
    }

    /// @dev Re-invest whatever this worker has earned back to staked LP tokens.
    function reinvest() public onlyEOA nonReentrant {
        // 1. Withdraw all the rewards.
        uint256[] memory pool = new uint256[](1);
        pool[0] = farmingPid;
        farming.claim(address(this), pool);
        uint256 reward = rewardToken.balanceOf(address(this));
        if (reward == 0) return;
        // 2. Send the reward bounty to the caller or Owner.
        uint256 bounty = reward.mul(reinvestBountyBps) / 10000;
        address rewardTo = reinvestToTreasury == true ? treasuryAddr : msg.sender;
        rewardToken.safeTransfer(rewardTo, bounty);
        // 3. Convert all the remaining rewards to ETH.
        router.exchange(0, 1, reward.sub(bounty), 0);
        // 4. Use add ETH strategy to convert all ETH to LP tokens.
        baseToken.safeTransfer(address(addStrat), baseToken.myBalance());
        addStrat.execute(address(0), 0, abi.encode(baseToken, fToken, 0));
        // 5. Mint more LP tokens and stake them for more rewards.
        farming.deposit(farmingPid, lpToken.balanceOf(address(this)), false, address(this));
        emit Reinvest(msg.sender, reward, bounty);
    }

    /// @dev Work on the given position. Must be called by the operator.
    /// @param id The position ID to work on.
    /// @param user The original user that is interacting with the operator.
    /// @param debt The amount of user debt to help the strategy make decisions.
    /// @param data The encoded data, consisting of strategy address and calldata.
    function work(uint256 id, address user, uint256 debt, bytes calldata data) 
        external payable 
        onlyOperator nonReentrant 
    {
        // 1. Convert this position back to LP tokens.
        _removeShare(id);
        // 2. Perform the worker strategy; sending LP tokens + ETH; expecting LP tokens + ETH.
        (address strat, bytes memory ext) = abi.decode(data, (address, bytes));
        require(okStrats[strat], "unapproved work strategy");
        lpToken.transfer(strat, lpToken.balanceOf(address(this)));
        baseToken.safeTransfer(strat, baseToken.myBalance());
        Strategy(strat).execute.value(msg.value)(user, debt, ext);
        // 3. Add LP tokens back to the farming pool.
        _addShare(id);
        // 4. Return any remaining ETH back to the operator.
        baseToken.safeTransfer(msg.sender, baseToken.myBalance());
    }

    /// @dev Return the amount of BaseToken to receive if we are to liquidate the given position.
    /// @param id The position ID to perform health check.
    function health(uint256 id) external view returns (uint256) {
        uint256 lpBalance = shareToBalance(shares[id]);
        uint256 amount = router.calc_withdraw_one_coin(lpBalance, 1);
        return amount;
    }

    /// @dev Liquidate the given position by converting it to ETH and return back to caller.
    /// @param id The position ID to perform liquidation
    function liquidate(uint256 id) external onlyOperator nonReentrant {
        // 1. Convert the position back to LP tokens and use liquidate strategy.
        _removeShare(id);
        lpToken.transfer(address(liqStrat), lpToken.balanceOf(address(this)));
        liqStrat.execute(address(0), 0, abi.encode(baseToken, fToken, 0));
        // 2. Return all available ETH back to the operator.
        uint256 wad = baseToken.myBalance();
        baseToken.safeTransfer(msg.sender, wad);
        emit Liquidate(id, wad);
    }

    /// @dev Internal function to stake all outstanding LP tokens to the given position ID.
    function _addShare(uint256 id) internal {
        uint256 balance = lpToken.balanceOf(address(this));
        if (balance > 0) {
            uint256 share = balanceToShare(balance);
            farming.deposit(farmingPid, balance, false, address(this));
            shares[id] = shares[id].add(share);
            totalShare = totalShare.add(share);
            emit AddShare(id, share);
        }
    }

    /// @dev Internal function to remove shares of the ID and convert to outstanding LP tokens.
    function _removeShare(uint256 id) internal {
        uint256 share = shares[id];
        if (share > 0) {
            uint256 balance = shareToBalance(share);
            farming.withdraw(farmingPid, balance, true);
            totalShare = totalShare.sub(share);
            shares[id] = 0;
            emit RemoveShare(id, share);
        }
    }

    /// @dev Recover ERC20 tokens that were accidentally sent to this smart contract.
    /// @param token The token contract. Can be anything. This contract should not hold ERC20 tokens.
    /// @param to The address to send the tokens to.
    /// @param value The number of tokens to transfer to `to`.
    function recover(address token, address to, uint256 value) external onlyOwner nonReentrant {
        SafeToken.safeTransfer(token, to, value);
    }

    /// @dev Set the reward bounty for calling reinvest operations.
    /// @param _reinvestBountyBps The bounty value to update.
    function setReinvestBountyBps(uint256 _reinvestBountyBps) external onlyOwner {
        reinvestBountyBps = _reinvestBountyBps;
    }

    /// @dev Set the given strategies' approval status.
    /// @param strats The strategy addresses.
    /// @param isOk Whether to approve or unapprove the given strategies.
    function setStrategyOk(address[] calldata strats, bool isOk) external onlyOwner {
        uint256 len = strats.length;
        for (uint256 idx = 0; idx < len; idx++) {
            okStrats[strats[idx]] = isOk;
        }
    }

    /// @dev Set Reward Reinvest Reward to owner or msg,sender
    /// @param toTreasury bool set to treasury or not
    function setReinvestToTreasury (bool toTreasury) external onlyOwner {
        reinvestToTreasury = toTreasury;
    }


    /// @dev Set Treasury Address
    /// @param _treasuryAddr treasury address 
    function setTreasuryAddress (address _treasuryAddr) external onlyOwner {
        treasuryAddr = _treasuryAddr;
    }

    /// @dev Update critical strategy smart contracts. EMERGENCY ONLY. Bad strategies can steal funds.
    /// @param _addStrat The new add strategy contract.
    /// @param _liqStrat The new liquidate strategy contract.
    function setCriticalStrategies(Strategy _addStrat, Strategy _liqStrat) external onlyOwner {
        addStrat = _addStrat;
        liqStrat = _liqStrat;
    }

    function() external payable {}
}