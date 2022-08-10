// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../interfaces/IETFBurner.sol";
import "../interfaces/IDexShareRewardPool.sol";
import "../interfaces/IDexStrategy.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IPancakeRouter.sol";
import "../interfaces/IDexPersonalStrategy.sol";
import "../interfaces/IDexPersonalStrategyFactory.sol";

contract DexPersonalStrategyFactory is Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Clones for address;

    /* Constructor Parameters Structs */
    struct ConstructorAddresses {
        address router;
        address usdex;
        address usdc;
        address dao;
        address treasury;
        address etfBurner;
        address strategy;
        address zapper;
    }

    struct ConstructorETFBurnConfiguration {
        address etf;
        uint256[] minAmountsOut;
        address[] intermediaries;
    }

    struct ConstructorFarm {
        IDexShareRewardPool pool;
        uint256 id;
        bool isStakingTokenLP;
    }

    struct ConstructorFee {
        address depositFeeOutput;
        uint256 depositFee;
        uint256 harvestFee;
        uint256 withdrawFeeMax;
        uint256 withdrawFeeMin;
        uint256 withdrawFeePeriod;
    }

    /* Constant variables */
    uint256 constant public FEE_DIVIDER = 10000;

    /* Public variables */
    address public dao;
    address public treasury;
    address public depositFeeOutput;
    uint256 public depositFee;
    uint256 public harvestFee;
    uint256 public withdrawFeeMax;
    uint256 public withdrawFeeMin;
    uint256 public withdrawFeePeriod;
    address public native;
    address public usdex;
    address public usdc;
    address public strategyImplementation;
    IPancakeRouter public router;
    IETFBurner public etfBurner;
    mapping(address => IDexPersonalStrategyFactory.TokenInfo) public tokenInformation;
    mapping(address => mapping(uint256 => IDexPersonalStrategyFactory.Farm)) public farms;
    mapping(address => address[]) userStrategies;

    /* Private variables */
    EnumerableSet.AddressSet private _zappers;
    mapping(address => IDexPersonalStrategyFactory.ETFBurnConfiguration) private _etfBurnConfiguration;


    /* External view methods */
    function userStrategiesCount(address user) external view returns (uint256) {
        return userStrategies[user].length;
    }

    function userStrategiesWithPagination(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory strategies) {
        address[] storage userStrats = userStrategies[user];
        uint256 strategiesLength = userStrats.length;
        if (offset >= strategiesLength) return strategies;
        uint256 to = offset + limit;
        if (strategiesLength < to) to = strategiesLength;
        strategies = new address[](to - offset);
        for (uint256 i = 0; i < strategies.length; i++) strategies[i] = userStrats[offset + i];
    }

    function zappersCount() external view returns (uint256) {
        return _zappers.length();
    }

    function zapper(uint256 index) external view returns (address) {
        return _zappers.at(index);
    }

    function zapperContains(address zapper_) external view returns (bool) {
        return _zappers.contains(zapper_);
    }

    function etfBurnConfiguration(
        address etf
    ) external view returns (IDexPersonalStrategyFactory.ETFBurnConfiguration memory) {
        return _etfBurnConfiguration[etf];
    }

    /* Events */
    event DaoUpdated(address dao);
    event ETFBurnConfigurationUpdated(
        address indexed etf,
        uint256[] minAmountsOut,
        address[] intermediaries
    );
    event ETFBurnerUpdated(address burner);
    event FarmUpdated(ConstructorFarm[] farms);
    event FeeUpdated(
        address depositFeeOutput,
        uint256 depositFee,
        uint256 harvestFee,
        uint256 withdrawFeeMax,
        uint256 withdrawFeeMin,
        uint256 withdrawFeePeriod
    );
    event StrategyCreated(address indexed creator, address strategy);
    event StrategyImplementationUpdated(address strategy);
    event TreasuryUpdated(address treasury);
    event ZapperAdded(address zapper);
    event ZapperRemoved(address zapper);

    constructor(
        ConstructorAddresses memory addresses_,
        ConstructorFee memory fee_,
        ConstructorFarm[] memory farms_,
        ConstructorETFBurnConfiguration[] memory etfConfigs_
    ) {
        address zero = address(0);
        require(addresses_.router != zero, "DexPersonalStrategyFactory: Router is zero address");
        require(addresses_.usdex != zero, "DexPersonalStrategyFactory: USDEX is zero address");
        require(addresses_.usdc != zero, "DexPersonalStrategyFactory: USDC is zero address");
        require(addresses_.dao != zero, "DexPersonalStrategyFactory: Dao is zero address");
        require(addresses_.treasury != zero, "DexPersonalStrategyFactory: Treasury is zero address");
        require(addresses_.etfBurner != zero, "DexPersonalStrategyFactory: Burner is zero address");
        require(addresses_.strategy != zero, "DexPersonalStrategyFactory: Strategy is zero address");
        require(addresses_.zapper != zero, "DexPersonalStrategyFactory: Zapper is zero address");
        require(fee_.depositFeeOutput != zero, "DexPersonalStrategyFactory: Fee Output is zero address");
        require(fee_.depositFee < FEE_DIVIDER, "DexPersonalStrategyFactory: Deposit fee overflow");
        require(fee_.harvestFee < FEE_DIVIDER, "DexPersonalStrategyFactory: Harvest fee overflow");
        require(fee_.withdrawFeeMax < FEE_DIVIDER, "DexPersonalStrategyFactory: Withdraw fee max overflow");
        require(fee_.withdrawFeeMin <= fee_.withdrawFeeMax, "DexPersonalStrategyFactory: Withdraw fee min overflow");
        router = IPancakeRouter(addresses_.router);
        native = router.WETH();
        usdex = addresses_.usdex;
        usdc = addresses_.usdc;
        dao = addresses_.dao;
        treasury = addresses_.treasury;
        etfBurner = IETFBurner(addresses_.etfBurner);
        strategyImplementation = addresses_.strategy;
        _zappers.add(addresses_.zapper);
        depositFeeOutput = fee_.depositFeeOutput;
        depositFee = fee_.depositFee;
        harvestFee = fee_.harvestFee;
        withdrawFeeMax = fee_.withdrawFeeMax;
        withdrawFeeMin = fee_.withdrawFeeMin;
        withdrawFeePeriod = fee_.withdrawFeePeriod;
        for (uint256 i = 0; i < farms_.length; i++) {
            ConstructorFarm memory farm_ = farms_[i];
            IDexShareRewardPool.PoolInfo memory info_ = farm_.pool.poolInfo(farm_.id);
            require(info_.allocPoint > 0, "DexPersonalStrategyFactory: Pool allocPoint is zero");
            IDexPersonalStrategyFactory.Farm storage farm = farms[address(farm_.pool)][farm_.id];
            farm.pool = farm_.pool;
            farm.id = farm_.id;
            farm.stakingToken = address(info_.token);
            if (farm_.isStakingTokenLP) {
                farm.isStakingTokenLP = farm_.isStakingTokenLP;
                IPancakePair pair_ = IPancakePair(farm.stakingToken);
                farm.token0 = pair_.token0();
                farm.token1 = pair_.token1();
                tokenInformation[farm.stakingToken] = IDexPersonalStrategyFactory.TokenInfo(
                    true,
                    false,
                    farm.token0,
                    farm.token1
                );
            }
            try farm_.pool.dexshare() returns (IERC20 rewardToken) {
                farm.rewardToken = address(rewardToken);
            } catch {
                farm.rewardToken = address(farm_.pool.rewardToken());
            }
        }
        for (uint256 i = 0; i < etfConfigs_.length; i++) {
            ConstructorETFBurnConfiguration memory config_ = etfConfigs_[i];
            tokenInformation[config_.etf] = IDexPersonalStrategyFactory.TokenInfo(false, true, zero, zero);
            _etfBurnConfiguration[config_.etf] = IDexPersonalStrategyFactory.ETFBurnConfiguration(
                config_.minAmountsOut,
                config_.intermediaries
            );
        }

    }

    /* External functions: Personal Strategy creation */
    function createStrategy(
        string memory name_,
        string memory symbol_,
        uint256 profit_,
        IDexPersonalStrategy.InitializeFarm[] memory farms_
    ) external returns (address strategy) {
        address caller = msg.sender;
        strategy = strategyImplementation.clone();
        require(
            IDexPersonalStrategy(strategy).initialize(name_, symbol_, caller, profit_, farms_),
            "DexPersonalStrategyFactory: Strategy initialization fail"
        );
        userStrategies[caller].push(strategy);
        emit StrategyCreated(caller, strategy);
    }

    /* External Functions: Owner - Updaters */
    function updateDao(address dao_) external onlyOwner returns (bool) {
        require(dao_ != address(0), "DexPersonalStrategyFactory: Dao is zero address");
        dao = dao_;
        emit DaoUpdated(dao_);
        return true;
    }

    function updateETFBurnConfiguration(
        address etf,
        uint256[] memory minAmountsOut,
        address[] memory intermediaries
    ) external onlyOwner returns (bool) {
        tokenInformation[etf] = IDexPersonalStrategyFactory.TokenInfo(false, true, address(0), address(0));
        _etfBurnConfiguration[etf] = IDexPersonalStrategyFactory.ETFBurnConfiguration(minAmountsOut, intermediaries);
        emit ETFBurnConfigurationUpdated(etf, minAmountsOut, intermediaries);
        return true;
    }

    function updateETFBurner(address burner_) external onlyOwner returns (bool) {
        require(burner_ != address(0), "DexPersonalStrategyFactory: Burner is zero address");
        etfBurner = IETFBurner(burner_);
        emit ETFBurnerUpdated(burner_);
        return true;
    }

    function updateFarms(ConstructorFarm[] memory farms_) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < farms_.length; i++) {
            ConstructorFarm memory farm_ = farms_[i];
            IDexShareRewardPool.PoolInfo memory info_ = farm_.pool.poolInfo(farm_.id);
            require(info_.allocPoint > 0, "DexPersonalStrategyFactory: Pool allocPoint is zero");
            IDexPersonalStrategyFactory.Farm storage farm = farms[address(farm_.pool)][farm_.id];
            farm.pool = farm_.pool;
            farm.id = farm_.id;
            farm.stakingToken = address(info_.token);
            if (farm_.isStakingTokenLP) {
                farm.isStakingTokenLP = farm_.isStakingTokenLP;
                IPancakePair pair_ = IPancakePair(farm.stakingToken);
                farm.token0 = pair_.token0();
                farm.token1 = pair_.token1();
                tokenInformation[farm.stakingToken] = IDexPersonalStrategyFactory.TokenInfo(
                    true,
                    false,
                    farm.token0,
                    farm.token1
                );
            }
            try farm_.pool.dexshare() returns (IERC20 rewardToken) {
                farm.rewardToken = address(rewardToken);
            } catch {
                farm.rewardToken = address(farm_.pool.rewardToken());
            }
        }
        emit FarmUpdated(farms_);
        return true;
    }

    function updateFee(
        address depositFeeOutput_,
        uint256 depositFee_,
        uint256 harvestFee_,
        uint256 withdrawFeeMax_,
        uint256 withdrawFeeMin_,
        uint256 withdrawFeePeriod_
    ) external onlyOwner returns (bool) {
        require(depositFeeOutput_ != address(0), "DexPersonalStrategyFactory: Deposit Output is zero address");
        require(depositFee_ < FEE_DIVIDER, "DexPersonalStrategyFactory: Deposit fee overflow");
        require(harvestFee_ < FEE_DIVIDER, "DexPersonalStrategyFactory: Harvest fee overflow");
        require(withdrawFeeMax_ < FEE_DIVIDER, "DexPersonalStrategyFactory: Withdraw fee max overflow");
        require(withdrawFeeMin_ <= withdrawFeeMax_, "DexPersonalStrategyFactory: Withdraw fee min overflow");
        depositFeeOutput = depositFeeOutput_;
        depositFee = depositFee_;
        harvestFee = harvestFee_;
        withdrawFeeMax = withdrawFeeMax_;
        withdrawFeeMin = withdrawFeeMin_;
        withdrawFeePeriod = withdrawFeePeriod_;
        emit FeeUpdated(
            depositFeeOutput_,
            depositFee_,
            harvestFee_,
            withdrawFeeMax_,
            withdrawFeeMin_,
            withdrawFeePeriod_
        );
        return true;
    }

    function updateStrategyImplementation(address strategy_) external onlyOwner returns (bool) {
        require(strategy_ != address(0), "DexPersonalStrategyFactory: Strategy is zero address");
        strategyImplementation = strategy_;
        emit StrategyImplementationUpdated(strategy_);
        return true;
    }

    function updateTreasury(address treasury_) external onlyOwner returns (bool) {
        require(treasury_ != address(0), "DexPersonalStrategyFactory: Treasury is zero address");
        treasury = treasury_;
        emit TreasuryUpdated(treasury_);
        return true;
    }

    function addZapper(address zapper_) external onlyOwner returns (bool success) {
        require(zapper_ != address(0), "DexPersonalStrategyFactory: Zapper is zero address");
        success = _zappers.add(zapper_);
        if (success) emit ZapperAdded(zapper_);
    }

    function removeZapper(address zapper_) external onlyOwner returns (bool success) {
        success = _zappers.remove(zapper_);
        if (success) emit ZapperRemoved(zapper_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IPancakeRouterPart {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter is IPancakeRouterPart {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IPancakePair {
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
pragma solidity 0.8.16;

interface IETFBurner {
    function burnForAllTokensAndSwapForTokens(
        address indexPool,
        uint256[] memory minAmountsOut,
        address[] memory intermediaries,
        uint256 poolAmountIn,
        address tokenOut,
        uint256 minAmountOut
    ) external returns (uint256 amountOutTotal);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IDexStrategy {
    function deposit(uint256 amount) external returns (uint256 mintAmount);
    function harvest() external returns (uint256 nativeAmount);
    function withdraw(uint256 amount) external returns (uint256 nativeOutput);
    function zapperDeposit(uint256 amount, address to) external returns (uint256 mintAmount);
    function zapperWithdraw(uint256 amount, address from) external returns (uint256 nativeOutput);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDexShareRewardPool {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 token;
        uint256 allocPoint;
        uint256 lastRewardTime;
        uint256 accRewardPerShare;
        bool isStarted;
    }

    /* View methods */
    function dexshare() external view returns (IERC20); // dexShare pool
    function rewardToken() external view returns (IERC20); // regulation pool
    function poolInfo(uint256 id) external view returns (PoolInfo memory);
    function userInfo(uint256 id, address account) external view returns (UserInfo memory);

    /* Non-view methods */
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IETFBurner.sol";
import "./IDexShareRewardPool.sol";
import "./IPancakeRouter.sol";

interface IDexPersonalStrategyFactory {
    /* Core Structs */
    struct ETFBurnConfiguration {
        uint256[] minAmountsOut;
        address[] intermediaries;
    }

    struct TokenInfo {
        bool isLP;
        bool isETF;
        address token0;
        address token1;
    }

    struct Farm {
        IDexShareRewardPool pool;
        uint256 id;
        bool isStakingTokenLP;
        address stakingToken;
        address rewardToken;
        address token0;
        address token1;
    }

    /* View methods */
    function native() external view returns (address);
    function usdex() external view returns (address);
    function usdc() external view returns (address);
    function router() external view returns (IPancakeRouter);
    function dao() external view returns (address);
    function treasury() external view returns (address);
    function depositFeeOutput() external view returns (address);
    function depositFee() external view returns (uint256);
    function harvestFee() external view returns (uint256);
    function withdrawFeeMax() external view returns (uint256);
    function withdrawFeeMin() external view returns (uint256);
    function withdrawFeePeriod() external view returns (uint256);
    function etfBurner() external view returns (IETFBurner);
    function tokenInformation(address) external view returns (TokenInfo memory);
    function farms(address, uint256) external view returns (Farm memory);
    function zappersCount() external view returns (uint256);
    function zapper(uint256 index) external view returns (address);
    function zapperContains(address zapper_) external view returns (bool);
    function etfBurnConfiguration(address etf) external view returns (ETFBurnConfiguration memory);

    /* Non-view methods */
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./IDexShareRewardPool.sol";
import "./IPancakeRouter.sol";

interface IDexPersonalStrategy {
    /* Initialize structs */
    struct InitializeFarm {
        IDexShareRewardPool pool;
        uint256 id;
        uint256 percent;
    }

    /* Core Structs */
    struct Farm {
        IDexShareRewardPool pool;
        uint256 id;
        uint256 percent;
        bool isStakingTokenLP;
        address stakingToken;
        address rewardToken;
        address token0;
        address token1;
    }

    /* Non-view methods */
    function initialize(
        string memory name_,
        string memory symbol_,
        address owner_,
        uint256 profit_,
        InitializeFarm[] memory farms_
    ) external returns (bool);
    function deposit(uint256 amount, address to) external returns (uint256 mintAmount);
    function harvest() external returns (uint256 nativeAmount);
    function withdraw(uint256 amount, address from) external returns (uint256 nativeOutput);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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