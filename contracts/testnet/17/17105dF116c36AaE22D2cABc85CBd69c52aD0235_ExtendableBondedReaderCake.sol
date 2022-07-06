// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@private/shared/libs/Adminable.sol";
import "@private/shared/3rd/pancake/IPancakePair.sol";
import "@private/shared/3rd/pancake/ICakePool.sol";
import "@private/shared/mocks/pancake/MasterChefV2.sol";

import "@private/shared/interfaces/ebcake/IExtendableBond.sol";
import "@private/shared/interfaces/ebcake/underlyings/pancake/IExtendableBondedCake.sol";
import "@private/shared/interfaces/ebcake/underlyings/pancake/IBondLPPancakeFarmingPool.sol";

import "./ExtendableBondReader.sol";
import "./ExtendableBondRegistry.sol";


contract ExtendableBondedReaderCake is ExtendableBondReader, Initializable, Adminable {
    using Math for uint256;

    uint constant WEI_PER_EHTER = 1e18;
    uint constant PANCAKE_BOOST_WEIGHT = 2e13;
    uint constant PANCAKE_DURATION_FACTOR = 365 * 24 * 60 * 60;
    uint constant PANCAKE_PRECISION_FACTOR = 1e12;
    uint constant PANCAKE_CAKE_POOL_ID = 0;

    struct ExtendableBondGroupInfo {
        uint256 allEbStacked;
        uint256 ebCommonPriceAsUsd;
        uint256 duetSideAPR;
        uint256 underlyingSideAPR;
    }

    struct AddressBook {
      address underlyingToken;
      address bondToken;
      address lpToken;
      address bondFarmingPool;
      address bondLpFarmingPool;
      uint256 bondFarmingPoolId;
      uint256 bondLpFarmingPoolId;
      address pancakePool;
    }

    ExtendableBondRegistry public registry;
    ICakePool public pancakePool;
    MasterChefV2 public pancakeMasterChef;
    IPancakePair public pairTokenAddress__CAKE_BUSD;
    IPancakePair public pairTokenAddress__DUET_anyUSD;

    function initialize(
      address admin_,
      address registry_,
      address pancakePool_,
      address pancakeMasterChef_,
      address pairTokenAddress__CAKE_BUSD_,
      address pairTokenAddress__DUET_anyUSD_
    ) public initializer {
      require(admin_ != address(0), "Cant set admin to zero address");
      _setAdmin(admin_);
      updateReferences(registry_, pancakePool_, pancakeMasterChef_, pairTokenAddress__CAKE_BUSD_, pairTokenAddress__DUET_anyUSD_);
    }

    function updateReferences(
      address registry_,
      address pancakePool_,
      address pancakeMasterChef_,
      address pairTokenAddress__CAKE_BUSD_,
      address pairTokenAddress__DUET_anyUSD_
    ) public onlyAdmin {
      require(registry_ != address(0), "Cant set Registry to zero address");
      registry = ExtendableBondRegistry(registry_);
      require(pancakePool_ != address(0), "Cant set PancakePool to zero address");
      pancakePool = ICakePool(pancakePool_);
      require(pancakeMasterChef_ != address(0), "Cant set PancakeMasterChef to zero address");
      pancakeMasterChef = MasterChefV2(pancakeMasterChef_);
      require(pairTokenAddress__CAKE_BUSD_ != address(0), "Cant set PairTokenAddress__CAKE_BUSD to zero address");
      pairTokenAddress__CAKE_BUSD = IPancakePair(pairTokenAddress__CAKE_BUSD_);
      require(pairTokenAddress__DUET_anyUSD_ != address(0), "Cant set pairTokenAddress__DUET_anyUSD to zero address");
      pairTokenAddress__DUET_anyUSD = IPancakePair(pairTokenAddress__DUET_anyUSD_);
    }


    function addressBook(IExtendableBondedCake eb_) view external returns (AddressBook memory book) {
      IBondFarmingPool bondFarmingPool = IBondFarmingPool(eb_.bondFarmingPool());
      IBondLPPancakeFarmingPool bondLpFarmingPool = IBondLPPancakeFarmingPool(eb_.bondLPFarmingPool());

      book.underlyingToken = eb_.underlyingToken();
      book.bondToken = eb_.bondToken();
      book.lpToken = bondLpFarmingPool.lpToken();
      book.bondFarmingPool = eb_.bondFarmingPool();
      book.bondLpFarmingPool = eb_.bondLPFarmingPool();
      book.bondFarmingPoolId = bondFarmingPool.masterChefPid();
      book.bondLpFarmingPoolId = bondLpFarmingPool.masterChefPid();
      book.pancakePool = eb_.cakePool();
    }

    // -------------

    function extendableBondGroupInfo(string calldata groupName_) view external returns (ExtendableBondGroupInfo memory) {
        uint256 allEbStacked;
        uint256 sumCakePrices;
        address[] memory addresses = registry.groupedAddresses(groupName_);
        uint256 maxDuetSideAPR;
        for (uint256 i; i < addresses.length; i++) {
            address ebAddress = addresses[i];
            IExtendableBond eb = IExtendableBond(ebAddress);
            allEbStacked += eb.totalUnderlyingAmount();
            sumCakePrices += _unsafely_getUnderlyingPriceAsUsd(eb);
            uint256 underlyingAPY = _getUnderlyingAPY(eb);
            uint256 extraMaxSideAPR = _getSingleStake_bDuetAPR(eb).max(_getLpStake_bDuetAPR(eb));
            maxDuetSideAPR = maxDuetSideAPR.max(underlyingAPY + extraMaxSideAPR);
        }
        uint256 cakeCommonPrice = addresses.length > 0 ? sumCakePrices / addresses.length : 0;
        uint256 underlyingSideAPR = _getPancakeSyrupAPR();

        ExtendableBondGroupInfo memory ebGroupInfo = ExtendableBondGroupInfo({
            allEbStacked: allEbStacked,
            ebCommonPriceAsUsd: cakeCommonPrice,
            duetSideAPR: maxDuetSideAPR,
            underlyingSideAPR: underlyingSideAPR
        });
        return ebGroupInfo;
    }

    // -------------

    /**
     * Estimates token price by multi-fetching data from DEX.
     * There are some issues like time-lag and precision problems.
     * It's OK to do estimation but not for trading basis.
     */
    function _unsafely_getDuetPriceAsUsd(IExtendableBond eb_) view internal override returns (uint256) {
        IBondLPPancakeFarmingPool pool = IBondLPPancakeFarmingPool(eb_.bondLPFarmingPool());
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(pool.lpToken());

        uint256 ebCakeLpTotalSupply = cakeWithEbCakeLpPairToken.totalSupply();
        if (ebCakeLpTotalSupply == 0) return 0;

        ( uint256 duetReserve, uint256 usdReserve, ) = pairTokenAddress__DUET_anyUSD.getReserves();
        if (usdReserve == 0 ) return 0;
        return duetReserve / usdReserve * ebCakeLpTotalSupply;
    }

    /**
     * Estimates token price by multi-fetching data from DEX.
     * There are some issues like time-lag and precision problems.
     * It's OK to do estimation but not for trading basis.
     */
    function _unsafely_getUnderlyingPriceAsUsd(IExtendableBond eb_) view internal override returns (uint256) {
        IBondLPPancakeFarmingPool pool = IBondLPPancakeFarmingPool(eb_.bondLPFarmingPool());
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(pool.lpToken());

        uint256 ebCakeLpTotalSupply = cakeWithEbCakeLpPairToken.totalSupply();
        if (ebCakeLpTotalSupply == 0) return 0;
        ( uint256 cakeReserve, uint256 busdReserve, ) = pairTokenAddress__CAKE_BUSD.getReserves();
        if (busdReserve == 0 ) return 0;
        return cakeReserve / busdReserve * ebCakeLpTotalSupply;
    }

    function _getBondPriceAsUnderlying(IExtendableBond eb_) view internal override returns (uint256) {
        IBondLPPancakeFarmingPool pool = IBondLPPancakeFarmingPool(eb_.bondLPFarmingPool());
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(pool.lpToken());

        ( uint256 cakeReserve, uint256 ebCakeReserve, ) = cakeWithEbCakeLpPairToken.getReserves();
        if (ebCakeReserve == 0) return 0;
        return cakeReserve / ebCakeReserve;
    }

    function _getLpStackedReserves(IExtendableBond eb_) view internal override returns (uint256 cakeReserve, uint256 ebCakeReserve) {
        IBondLPPancakeFarmingPool pool = IBondLPPancakeFarmingPool(eb_.bondLPFarmingPool());
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(pool.lpToken());

        ( cakeReserve, ebCakeReserve, ) = cakeWithEbCakeLpPairToken.getReserves();
    }

    function _getLpStackedTotalSupply(IExtendableBond eb_) view internal override returns (uint256) {
        IBondLPPancakeFarmingPool pool = IBondLPPancakeFarmingPool(eb_.bondLPFarmingPool());
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(pool.lpToken());

        return cakeWithEbCakeLpPairToken.totalSupply();
    }

    function _getEbFarmingPoolId(IExtendableBond eb_) view internal override returns (uint256) {
        IBondLPPancakeFarmingPool pool = IBondLPPancakeFarmingPool(eb_.bondLPFarmingPool());
        return pool.masterChefPid();
    }

    function _getUnderlyingAPY(IExtendableBond eb_) view internal override returns (uint256) {
        IExtendableBondedCake eb = IExtendableBondedCake(address(eb_));
        ICakePool pool = ICakePool(eb.cakePool());
        ICakePool.UserInfo memory pui = pool.userInfo(eb.bondToken());

        uint specialFarmsPerBlock = pancakeMasterChef.cakePerBlock(false);
        ( , , uint allocPoint, , ) = pancakeMasterChef.poolInfo(PANCAKE_CAKE_POOL_ID);

        uint totalSpecialAllocPoint = pancakeMasterChef.totalSpecialAllocPoint();
        if (totalSpecialAllocPoint == 0) return 0;

        uint cakePoolSharesInSpecialFarms = allocPoint / totalSpecialAllocPoint;
        uint totalCakePoolEmissionPerYear = specialFarmsPerBlock * BLOCKS_PER_YEAR * cakePoolSharesInSpecialFarms;

        uint pricePerFullShareAsEther = pancakePool.getPricePerFullShare();
        uint totalSharesAsEther = pancakePool.totalShares();

        uint flexibleApy = totalCakePoolEmissionPerYear * WEI_PER_EHTER / pricePerFullShareAsEther / totalSharesAsEther * 100;

        uint256 duration = pui.lockEndTime - pui.lockStartTime;
        uint boostFactor = PANCAKE_BOOST_WEIGHT * duration.max(0) / PANCAKE_DURATION_FACTOR / PANCAKE_PRECISION_FACTOR;

        uint lockedAPY = flexibleApy * (boostFactor + 1);
        return lockedAPY;
    }

    // function _getLpStake_extraAPR(IExtendableBond eb_) view internal override returns (uint256) {
    //     ( , , uint allocPoint, , bool isRegular ) = pancakeMasterChef.poolInfo(PANCAKE_CAKE_POOL_ID);

    //     uint totalAllocPoint = isRegular ? pancakeMasterChef.totalRegularAllocPoint() : pancakeMasterChef.totalSpecialAllocPoint();
    //      if (totalAllocPoint == 0) return 0;

    //     uint poolWeight = allocPoint / totalAllocPoint;
    //     uint cakePerYear = pancakeMasterChef.cakePerBlock(isRegular) * BLOCKS_PER_YEAR;

    //     uint yearlyCakeRewardAllocation = poolWeight * cakePerYear;
    //     uint cakePrice = _unsafely_getUnderlyingPriceAsUsd(eb_);


    //     IPancakePair cakeWithBusdLpPairToken = IPancakePair(pairTokenAddress__CAKE_BUSD);
    //     uint lpShareRatio = cakeWithBusdLpPairToken.balanceOf(address(eb_.cakePool())) / cakeWithBusdLpPairToken.totalSupply();

    //     uint liquidityUSD = farm.reserveUSD; <x>


    //     uint poolLiquidityUsd = lpShareRatio * liquidityUSD;
    //     return yearlyCakeRewardAllocation * cakePrice / WEI_PER_EHTER / poolLiquidityUsd * 100;
    // }


    // -------------

    function _getPancakeSyrupAPR() view internal returns (uint256) {
        ( , , uint allocPoint, , bool isRegular ) = pancakeMasterChef.poolInfo(PANCAKE_CAKE_POOL_ID);

        uint totalAllocPoint = (isRegular ? pancakeMasterChef.totalRegularAllocPoint() : pancakeMasterChef.totalSpecialAllocPoint());
        if (totalAllocPoint == 0) return 0;

        uint poolWeight = allocPoint / totalAllocPoint;
        uint farmsPerBlock = poolWeight * pancakeMasterChef.cakePerBlock(isRegular);

        uint totalCakePoolEmissionPerYear = farmsPerBlock * BLOCKS_PER_YEAR * farmsPerBlock;

        uint pricePerFullShare = pancakePool.getPricePerFullShare();
        uint totalShares = pancakePool.totalShares();
        uint sharesRatio = pricePerFullShare * totalShares / 100;
        if (sharesRatio == 0) return 0;

        uint flexibleAPY = totalCakePoolEmissionPerYear * WEI_PER_EHTER / sharesRatio;

        uint performanceFeeAsDecimal = 2;
        uint rewardPercentageNoFee = 1 - performanceFeeAsDecimal / 100;
        return flexibleAPY * rewardPercentageNoFee;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

abstract contract Adminable {
    event AdminUpdated(address indexed user, address indexed newAdmin);

    address public admin;

    modifier onlyAdmin() virtual {
        require(msg.sender == admin, "UNAUTHORIZED");

        _;
    }

    function setAdmin(address newAdmin) public virtual onlyAdmin {
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) internal {
        require(newAdmin != address(0), "Can not set admin to zero address");
        admin = newAdmin;

        emit AdminUpdated(msg.sender, newAdmin);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

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
pragma solidity 0.8.9;

interface ICakePool {
    function totalShares() external view returns (uint256);

    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256 cakeAtLastUserAction; // keep track of cake deposited at the last user action.
        uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
    }

    function withdrawFeePeriod() external view returns (uint256);

    function freeWithdrawFeeUsers(address user_) external view returns (bool);

    function MAX_LOCK_DURATION() external view returns (uint256);

    function userInfo(address user_) external view returns (UserInfo memory);

    function deposit(uint256 _amount, uint256 _lockDuration) external;

    function withdrawByAmount(uint256 _amount) external;

    /**
     * @notice Calculate Performance fee.
     * @param _user: User address
     * @return Returns Performance fee.
     */
    function calculatePerformanceFee(address _user) external view returns (uint256);

    function calculateWithdrawFee(address _user, uint256 _shares) external view returns (uint256);

    function calculateOverdueFee(address _user) external view returns (uint256);

    /**
     * @notice Withdraw funds from the Cake Pool.
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares) external;

    function withdrawAll() external;

    function getPricePerFullShare() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// copy from https://bscscan.com/address/0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652#code#F1#L1

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../libs/SafeBEP20.sol";
import "../../libs/IBEP20.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

/// @notice The (older) MasterChef contract gives out a constant number of CAKE tokens per block.
/// It is the only address with minting rights for CAKE.
/// The idea for this MasterChef V2 (MCV2) contract is therefore to be the owner of a dummy token
/// that is deposited into the MasterChef V1 (MCV1) contract.
/// The allocation point for this pool on MCV1 is the total allocation point for all pools that receive incentives.
contract MasterChefV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    /// @notice Info of each MCV2 user.
    /// `amount` LP token amount the user has provided.
    /// `rewardDebt` Used to calculate the correct amount of rewards. See explanation below.
    ///
    /// We do some fancy math here. Basically, any point in time, the amount of CAKEs
    /// entitled to a user but is pending to be distributed is:
    ///
    ///   pending reward = (user share * pool.accCakePerShare) - user.rewardDebt
    ///
    ///   Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
    ///   1. The pool's `accCakePerShare` (and `lastRewardBlock`) gets updated.
    ///   2. User receives the pending reward sent to his/her address.
    ///   3. User's `amount` gets updated. Pool's `totalBoostedShare` gets updated.
    ///   4. User's `rewardDebt` gets updated.
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 boostMultiplier;
    }

    /// @notice Info of each MCV2 pool.
    /// `allocPoint` The amount of allocation points assigned to the pool.
    ///     Also known as the amount of "multipliers". Combined with `totalXAllocPoint`, it defines the % of
    ///     CAKE rewards each pool gets.
    /// `accCakePerShare` Accumulated CAKEs per share, times 1e12.
    /// `lastRewardBlock` Last block number that pool update action is executed.
    /// `isRegular` The flag to set pool is regular or special. See below:
    ///     In MasterChef V2 farms are "regular pools". "special pools", which use a different sets of
    ///     `allocPoint` and their own `totalSpecialAllocPoint` are designed to handle the distribution of
    ///     the CAKE rewards to all the PancakeSwap products.
    /// `totalBoostedShare` The total amount of user shares in each pool. After considering the share boosts.
    struct PoolInfo {
        uint256 accCakePerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
        uint256 totalBoostedShare;
        bool isRegular;
    }

    /// @notice Address of MCV1 contract.
    IMasterChef public immutable MASTER_CHEF;
    /// @notice Address of CAKE contract.
    IBEP20 public immutable CAKE;

    /// @notice The only address can withdraw all the burn CAKE.
    address public burnAdmin;
    /// @notice The contract handles the share boosts.
    address public boostContract;

    /// @notice Info of each MCV2 pool.
    PoolInfo[] public poolInfo;
    /// @notice Address of the LP token for each MCV2 pool.
    IBEP20[] public lpToken;

    /// @notice Info of each pool user.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    /// @notice The whitelist of addresses allowed to deposit in special pools.
    mapping(address => bool) public whiteList;

    /// @notice The pool id of the MCV2 mock token pool in MCV1.
    uint256 public immutable MASTER_PID;
    /// @notice Total regular allocation points. Must be the sum of all regular pools' allocation points.
    uint256 public totalRegularAllocPoint;
    /// @notice Total special allocation points. Must be the sum of all special pools' allocation points.
    uint256 public totalSpecialAllocPoint;
    ///  @notice 40 cakes per block in MCV1
    uint256 public constant MASTERCHEF_CAKE_PER_BLOCK = 40 * 1e18;
    uint256 public constant ACC_CAKE_PRECISION = 1e18;

    /// @notice Basic boost factor, none boosted user's boost factor
    uint256 public constant BOOST_PRECISION = 100 * 1e10;
    /// @notice Hard limit for maxmium boost factor, it must greater than BOOST_PRECISION
    uint256 public constant MAX_BOOST_PRECISION = 200 * 1e10;
    /// @notice total cake rate = toBurn + toRegular + toSpecial
    uint256 public constant CAKE_RATE_TOTAL_PRECISION = 1e12;
    /// @notice The last block number of CAKE burn action being executed.
    /// @notice CAKE distribute % for burn
    uint256 public cakeRateToBurn = 643750000000;
    /// @notice CAKE distribute % for regular farm pool
    uint256 public cakeRateToRegularFarm = 62847222222;
    /// @notice CAKE distribute % for special pools
    uint256 public cakeRateToSpecialFarm = 293402777778;

    uint256 public lastBurnedBlock;

    event Init();
    event AddPool(uint256 indexed pid, uint256 allocPoint, IBEP20 indexed lpToken, bool isRegular);
    event SetPool(uint256 indexed pid, uint256 allocPoint);
    event UpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accCakePerShare);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event UpdateCakeRate(uint256 burnRate, uint256 regularFarmRate, uint256 specialFarmRate);
    event UpdateBurnAdmin(address indexed oldAdmin, address indexed newAdmin);
    event UpdateWhiteList(address indexed user, bool isValid);
    event UpdateBoostContract(address indexed boostContract);
    event UpdateBoostMultiplier(address indexed user, uint256 pid, uint256 oldMultiplier, uint256 newMultiplier);

    /// @param _MASTER_CHEF The PancakeSwap MCV1 contract address.
    /// @param _CAKE The CAKE token contract address.
    /// @param _MASTER_PID The pool id of the dummy pool on the MCV1.
    /// @param _burnAdmin The address of burn admin.
    constructor(
        IMasterChef _MASTER_CHEF,
        IBEP20 _CAKE,
        uint256 _MASTER_PID,
        address _burnAdmin
    ) {
        MASTER_CHEF = _MASTER_CHEF;
        CAKE = _CAKE;
        MASTER_PID = _MASTER_PID;
        burnAdmin = _burnAdmin;
    }

    /**
     * @dev Throws if caller is not the boost contract.
     */
    modifier onlyBoostContract() {
        require(boostContract == msg.sender, "Ownable: caller is not the boost contract");
        _;
    }

    /// @notice Deposits a dummy token to `MASTER_CHEF` MCV1. This is required because MCV1 holds the minting permission of CAKE.
    /// It will transfer all the `dummyToken` in the tx sender address.
    /// The allocation point for the dummy pool on MCV1 should be equal to the total amount of allocPoint.
    /// @param dummyToken The address of the BEP-20 token to be deposited into MCV1.
    function init(IBEP20 dummyToken) external onlyOwner {
        uint256 balance = dummyToken.balanceOf(msg.sender);
        require(balance != 0, "MasterChefV2: Balance must exceed 0");
        dummyToken.safeTransferFrom(msg.sender, address(this), balance);
        dummyToken.approve(address(MASTER_CHEF), balance);
        MASTER_CHEF.deposit(MASTER_PID, balance);
        // MCV2 start to earn CAKE reward from current block in MCV1 pool
        lastBurnedBlock = block.number;
        emit Init();
    }

    /// @notice Returns the number of MCV2 pools.
    function poolLength() public view returns (uint256 pools) {
        pools = poolInfo.length;
    }

    /// @notice Add a new pool. Can only be called by the owner.
    /// DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    /// @param _allocPoint Number of allocation points for the new pool.
    /// @param _lpToken Address of the LP BEP-20 token.
    /// @param _isRegular Whether the pool is regular or special. LP farms are always "regular". "Special" pools are
    /// @param _withUpdate Whether call "massUpdatePools" operation.
    /// only for CAKE distributions within PancakeSwap products.
    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        bool _isRegular,
        bool _withUpdate
    ) external onlyOwner {
        require(_lpToken.balanceOf(address(this)) >= 0, "None BEP20 tokens");
        // stake CAKE token will cause staked token and reward token mixed up,
        // may cause staked tokens withdraw as reward token,never do it.
        require(_lpToken != CAKE, "CAKE token can't be added to farm pools");

        if (_withUpdate) {
            massUpdatePools();
        }

        if (_isRegular) {
            totalRegularAllocPoint = totalRegularAllocPoint.add(_allocPoint);
        } else {
            totalSpecialAllocPoint = totalSpecialAllocPoint.add(_allocPoint);
        }
        lpToken.push(_lpToken);

        poolInfo.push(
            PoolInfo({
                allocPoint: _allocPoint,
                lastRewardBlock: block.number,
                accCakePerShare: 0,
                isRegular: _isRegular,
                totalBoostedShare: 0
            })
        );
        emit AddPool(lpToken.length.sub(1), _allocPoint, _lpToken, _isRegular);
    }

    /// @notice Update the given pool's CAKE allocation point. Can only be called by the owner.
    /// @param _pid The id of the pool. See `poolInfo`.
    /// @param _allocPoint New number of allocation points for the pool.
    /// @param _withUpdate Whether call "massUpdatePools" operation.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external onlyOwner {
        // No matter _withUpdate is true or false, we need to execute updatePool once before set the pool parameters.
        updatePool(_pid);

        if (_withUpdate) {
            massUpdatePools();
        }

        if (poolInfo[_pid].isRegular) {
            totalRegularAllocPoint = totalRegularAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        } else {
            totalSpecialAllocPoint = totalSpecialAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        }
        poolInfo[_pid].allocPoint = _allocPoint;
        emit SetPool(_pid, _allocPoint);
    }

    /// @notice View function for checking pending CAKE rewards.
    /// @param _pid The id of the pool. See `poolInfo`.
    /// @param _user Address of the user.
    function pendingCake(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = pool.totalBoostedShare;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);

            uint256 cakeReward = multiplier.mul(cakePerBlock(pool.isRegular)).mul(pool.allocPoint).div(
                (pool.isRegular ? totalRegularAllocPoint : totalSpecialAllocPoint)
            );
            accCakePerShare = accCakePerShare.add(cakeReward.mul(ACC_CAKE_PRECISION).div(lpSupply));
        }

        uint256 boostedAmount = user.amount.mul(getBoostMultiplier(_user, _pid)).div(BOOST_PRECISION);
        return boostedAmount.mul(accCakePerShare).div(ACC_CAKE_PRECISION).sub(user.rewardDebt);
    }

    /// @notice Update cake reward for all the active pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo memory pool = poolInfo[pid];
            if (pool.allocPoint != 0) {
                updatePool(pid);
            }
        }
    }

    /// @notice Calculates and returns the `amount` of CAKE per block.
    /// @param _isRegular If the pool belongs to regular or special.
    function cakePerBlock(bool _isRegular) public view returns (uint256 amount) {
        if (_isRegular) {
            amount = MASTERCHEF_CAKE_PER_BLOCK.mul(cakeRateToRegularFarm).div(CAKE_RATE_TOTAL_PRECISION);
        } else {
            amount = MASTERCHEF_CAKE_PER_BLOCK.mul(cakeRateToSpecialFarm).div(CAKE_RATE_TOTAL_PRECISION);
        }
    }

    /// @notice Calculates and returns the `amount` of CAKE per block to burn.
    function cakePerBlockToBurn() public view returns (uint256 amount) {
        amount = MASTERCHEF_CAKE_PER_BLOCK.mul(cakeRateToBurn).div(CAKE_RATE_TOTAL_PRECISION);
    }

    /// @notice Update reward variables for the given pool.
    /// @param _pid The id of the pool. See `poolInfo`.
    /// @return pool Returns the pool that was updated.
    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[_pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.totalBoostedShare;
            uint256 totalAllocPoint = (pool.isRegular ? totalRegularAllocPoint : totalSpecialAllocPoint);

            if (lpSupply > 0 && totalAllocPoint > 0) {
                uint256 multiplier = block.number.sub(pool.lastRewardBlock);
                uint256 cakeReward = multiplier.mul(cakePerBlock(pool.isRegular)).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
                pool.accCakePerShare = pool.accCakePerShare.add((cakeReward.mul(ACC_CAKE_PRECISION).div(lpSupply)));
            }
            pool.lastRewardBlock = block.number;
            poolInfo[_pid] = pool;
            emit UpdatePool(_pid, pool.lastRewardBlock, lpSupply, pool.accCakePerShare);
        }
    }

    /// @notice Deposit LP tokens to pool.
    /// @param _pid The id of the pool. See `poolInfo`.
    /// @param _amount Amount of LP tokens to deposit.
    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(
            pool.isRegular || whiteList[msg.sender],
            "MasterChefV2: The address is not available to deposit in this pool"
        );

        uint256 multiplier = getBoostMultiplier(msg.sender, _pid);

        if (user.amount > 0) {
            settlePendingCake(msg.sender, _pid, multiplier);
        }

        if (_amount > 0) {
            uint256 before = lpToken[_pid].balanceOf(address(this));
            lpToken[_pid].safeTransferFrom(msg.sender, address(this), _amount);
            _amount = lpToken[_pid].balanceOf(address(this)).sub(before);
            user.amount = user.amount.add(_amount);

            // Update total boosted share.
            pool.totalBoostedShare = pool.totalBoostedShare.add(_amount.mul(multiplier).div(BOOST_PRECISION));
        }

        user.rewardDebt = user.amount.mul(multiplier).div(BOOST_PRECISION).mul(pool.accCakePerShare).div(
            ACC_CAKE_PRECISION
        );
        poolInfo[_pid] = pool;

        emit Deposit(msg.sender, _pid, _amount);
    }

    /// @notice Withdraw LP tokens from pool.
    /// @param _pid The id of the pool. See `poolInfo`.
    /// @param _amount Amount of LP tokens to withdraw.
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: Insufficient");

        uint256 multiplier = getBoostMultiplier(msg.sender, _pid);

        settlePendingCake(msg.sender, _pid, multiplier);

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            lpToken[_pid].safeTransfer(msg.sender, _amount);
        }

        user.rewardDebt = user.amount.mul(multiplier).div(BOOST_PRECISION).mul(pool.accCakePerShare).div(
            ACC_CAKE_PRECISION
        );
        poolInfo[_pid].totalBoostedShare = poolInfo[_pid].totalBoostedShare.sub(
            _amount.mul(multiplier).div(BOOST_PRECISION)
        );

        emit Withdraw(msg.sender, _pid, _amount);
    }

    /// @notice Harvests CAKE from `MASTER_CHEF` MCV1 and pool `MASTER_PID` to MCV2.
    function harvestFromMasterChef() public {
        MASTER_CHEF.deposit(MASTER_PID, 0);
    }

    /// @notice Withdraw without caring about the rewards. EMERGENCY ONLY.
    /// @param _pid The id of the pool. See `poolInfo`.
    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        uint256 boostedAmount = amount.mul(getBoostMultiplier(msg.sender, _pid)).div(BOOST_PRECISION);
        pool.totalBoostedShare = pool.totalBoostedShare > boostedAmount ? pool.totalBoostedShare.sub(boostedAmount) : 0;

        // Note: transfer can fail or succeed if `amount` is zero.
        lpToken[_pid].safeTransfer(msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    /// @notice Send CAKE pending for burn to `burnAdmin`.
    /// @param _withUpdate Whether call "massUpdatePools" operation.
    function burnCake(bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 multiplier = block.number.sub(lastBurnedBlock);
        uint256 pendingCakeToBurn = multiplier.mul(cakePerBlockToBurn());

        // SafeTransfer CAKE
        _safeTransfer(burnAdmin, pendingCakeToBurn);
        lastBurnedBlock = block.number;
    }

    /// @notice Update the % of CAKE distributions for burn, regular pools and special pools.
    /// @param _burnRate The % of CAKE to burn each block.
    /// @param _regularFarmRate The % of CAKE to regular pools each block.
    /// @param _specialFarmRate The % of CAKE to special pools each block.
    /// @param _withUpdate Whether call "massUpdatePools" operation.
    function updateCakeRate(
        uint256 _burnRate,
        uint256 _regularFarmRate,
        uint256 _specialFarmRate,
        bool _withUpdate
    ) external onlyOwner {
        require(
            _burnRate > 0 && _regularFarmRate > 0 && _specialFarmRate > 0,
            "MasterChefV2: Cake rate must be greater than 0"
        );
        require(
            _burnRate.add(_regularFarmRate).add(_specialFarmRate) == CAKE_RATE_TOTAL_PRECISION,
            "MasterChefV2: Total rate must be 1e12"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        // burn cake base on old burn cake rate
        burnCake(false);

        cakeRateToBurn = _burnRate;
        cakeRateToRegularFarm = _regularFarmRate;
        cakeRateToSpecialFarm = _specialFarmRate;

        emit UpdateCakeRate(_burnRate, _regularFarmRate, _specialFarmRate);
    }

    /// @notice Update burn admin address.
    /// @param _newAdmin The new burn admin address.
    function updateBurnAdmin(address _newAdmin) external onlyOwner {
        require(_newAdmin != address(0), "MasterChefV2: Burn admin address must be valid");
        require(_newAdmin != burnAdmin, "MasterChefV2: Burn admin address is the same with current address");
        address _oldAdmin = burnAdmin;
        burnAdmin = _newAdmin;
        emit UpdateBurnAdmin(_oldAdmin, _newAdmin);
    }

    /// @notice Update whitelisted addresses for special pools.
    /// @param _user The address to be updated.
    /// @param _isValid The flag for valid or invalid.
    function updateWhiteList(address _user, bool _isValid) external onlyOwner {
        require(_user != address(0), "MasterChefV2: The white list address must be valid");

        whiteList[_user] = _isValid;
        emit UpdateWhiteList(_user, _isValid);
    }

    /// @notice Update boost contract address and max boost factor.
    /// @param _newBoostContract The new address for handling all the share boosts.
    function updateBoostContract(address _newBoostContract) external onlyOwner {
        require(
            _newBoostContract != address(0) && _newBoostContract != boostContract,
            "MasterChefV2: New boost contract address must be valid"
        );

        boostContract = _newBoostContract;
        emit UpdateBoostContract(_newBoostContract);
    }

    /// @notice Update user boost factor.
    /// @param _user The user address for boost factor updates.
    /// @param _pid The pool id for the boost factor updates.
    /// @param _newMultiplier New boost multiplier.
    function updateBoostMultiplier(
        address _user,
        uint256 _pid,
        uint256 _newMultiplier
    ) external onlyBoostContract nonReentrant {
        require(_user != address(0), "MasterChefV2: The user address must be valid");
        require(poolInfo[_pid].isRegular, "MasterChefV2: Only regular farm could be boosted");
        require(
            _newMultiplier >= BOOST_PRECISION && _newMultiplier <= MAX_BOOST_PRECISION,
            "MasterChefV2: Invalid new boost multiplier"
        );

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][_user];

        uint256 prevMultiplier = getBoostMultiplier(_user, _pid);
        settlePendingCake(_user, _pid, prevMultiplier);






        user.rewardDebt = user.amount.mul(_newMultiplier).div(BOOST_PRECISION).mul(pool.accCakePerShare).div(
            ACC_CAKE_PRECISION
        );
        pool.totalBoostedShare = pool.totalBoostedShare.sub(user.amount.mul(prevMultiplier).div(BOOST_PRECISION)).add(
            user.amount.mul(_newMultiplier).div(BOOST_PRECISION)
        );
        poolInfo[_pid] = pool;
        userInfo[_pid][_user].boostMultiplier = _newMultiplier;

        emit UpdateBoostMultiplier(_user, _pid, prevMultiplier, _newMultiplier);
    }

    /// @notice Get user boost multiplier for specific pool id.
    /// @param _user The user address.
    /// @param _pid The pool id.
    function getBoostMultiplier(address _user, uint256 _pid) public view returns (uint256) {
        uint256 multiplier = userInfo[_pid][_user].boostMultiplier;
        return multiplier > BOOST_PRECISION ? multiplier : BOOST_PRECISION;
    }

    /// @notice Settles, distribute the pending CAKE rewards for given user.
    /// @param _user The user address for settling rewards.
    /// @param _pid The pool id.
    /// @param _boostMultiplier The user boost multiplier in specific pool id.
    function settlePendingCake(
        address _user,
        uint256 _pid,
        uint256 _boostMultiplier
    ) internal {
        UserInfo memory user = userInfo[_pid][_user];

        uint256 boostedAmount = user.amount.mul(_boostMultiplier).div(BOOST_PRECISION);
        uint256 accCake = boostedAmount.mul(poolInfo[_pid].accCakePerShare).div(ACC_CAKE_PRECISION);
        uint256 pending = accCake.sub(user.rewardDebt);
        // SafeTransfer CAKE
        _safeTransfer(_user, pending);
    }

    /// @notice Safe Transfer CAKE.
    /// @param _to The CAKE receiver address.
    /// @param _amount transfer CAKE amounts.
    function _safeTransfer(address _to, uint256 _amount) internal {
        if (_amount > 0) {
            // Check whether MCV2 has enough CAKE. If not, harvest from MCV1.
            if (CAKE.balanceOf(address(this)) < _amount) {
                harvestFromMasterChef();
            }
            uint256 balance = CAKE.balanceOf(address(this));
            if (balance < _amount) {
                _amount = balance;
            }
            CAKE.safeTransfer(_to, _amount);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IExtendableBond {
  struct FeeSpec { string desc; uint16 rate; address receiver; }
  struct CheckPoints { bool convertable; uint256 convertableFrom; uint256 convertableEnd; bool redeemable; uint256 redeemableFrom; uint256 redeemableEnd; uint256 maturity; }
  function PERCENTAGE_FACTOR (  ) external view returns ( uint16  );
  function addFeeSpec ( FeeSpec calldata feeSpec_ ) external;
  function admin (  ) external view returns ( address  );
  function bondFarmingPool (  ) external view returns ( address  );
  function bondLPFarmingPool (  ) external view returns ( address  );
  function bondToken (  ) external view returns ( address  );
  function burnBondToken ( uint256 amount_ ) external;
  function calculateFeeAmount ( uint256 amount_ ) external view returns ( uint256  );
  function checkPoints (  ) external view returns ( bool convertable, uint256 convertableFrom, uint256 convertableEnd, bool redeemable, uint256 redeemableFrom, uint256 redeemableEnd, uint256 maturity );
  function convert ( uint256 amount_ ) external;
  function convertAndStake ( uint256 amount_ ) external;
  function depositAllToRemote (  ) external;
  function depositToRemote ( uint256 amount_ ) external;
  function emergencyTransferUnderlyingTokens ( address to_ ) external;
  function feeSpecs ( uint256  ) external view returns ( string calldata desc, uint16 rate, address receiver );
  function feeSpecsLength (  ) external view returns ( uint256  );
  function initialize ( address bondToken_, address underlyingToken_, address admin_ ) external;
  function keeper (  ) external view returns ( address  );
  function mintBondTokenForRewards ( address to_, uint256 amount_ ) external returns ( uint256 totalFeeAmount );
  function pause (  ) external;
  function paused (  ) external view returns ( bool  );
  function redeem ( uint256 amount_ ) external;
  function redeemAll (  ) external;
  function remoteUnderlyingAmount (  ) external view returns ( uint256  );
  function removeFeeSpec ( uint256 feeSpecIndex_ ) external;
  function setAdmin ( address newAdmin ) external;
  function setConvertable ( bool convertable_ ) external;
  function setFarmingPools ( address bondPool_, address lpPool_ ) external;
  function setFeeSpec ( uint256 feeId_, FeeSpec calldata feeSpec_ ) external;
  function setKeeper ( address newKeeper ) external;
  function setRedeemable ( bool redeemable_ ) external;
  function totalBondTokenAmount (  ) external view returns ( uint256  );
  function totalPendingRewards (  ) external view returns ( uint256  );
  function totalUnderlyingAmount (  ) external view returns ( uint256  );
  function underlyingAmount (  ) external view returns ( uint256  );
  function underlyingToken (  ) external view returns ( address  );
  function unpause (  ) external;
  function updateCheckPoints ( CheckPoints calldata checkPoints_ ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IExtendableBondedCake {
  struct FeeSpec { string desc; uint16 rate; address receiver; }
  struct UserInfo { uint256 shares; uint256 lastDepositedTime; uint256 cakeAtLastUserAction; uint256 lastUserActionTime; uint256 lockStartTime; uint256 lockEndTime; uint256 userBoostedShare; bool locked; uint256 lockedAmount; }
  struct CheckPoints { bool convertable; uint256 convertableFrom; uint256 convertableEnd; bool redeemable; uint256 redeemableFrom; uint256 redeemableEnd; uint256 maturity; }
  function PERCENTAGE_FACTOR (  ) external view returns ( uint16  );
  function addFeeSpec ( FeeSpec calldata feeSpec_ ) external;
  function admin (  ) external view returns ( address  );
  function bondFarmingPool (  ) external view returns ( address  );
  function bondLPFarmingPool (  ) external view returns ( address  );
  function bondToken (  ) external view returns ( address  );
  function burnBondToken ( uint256 amount_ ) external;
  function cakePool (  ) external view returns ( address  );
  function calculateFeeAmount ( uint256 amount_ ) external view returns ( uint256  );
  function checkPoints (  ) external view returns ( bool convertable, uint256 convertableFrom, uint256 convertableEnd, bool redeemable, uint256 redeemableFrom, uint256 redeemableEnd, uint256 maturity );
  function convert ( uint256 amount_ ) external;
  function convertAndStake ( uint256 amount_ ) external;
  function depositAllToRemote (  ) external;
  function depositToRemote ( uint256 amount_ ) external;
  function emergencyTransferUnderlyingTokens ( address to_ ) external;
  function extendPancakeLockDuration ( bool force_ ) external;
  function feeSpecs ( uint256  ) external view returns ( string calldata desc, uint16 rate, address receiver );
  function feeSpecsLength (  ) external view returns ( uint256  );
  function initialize ( address bondToken_, address underlyingToken_, address admin_ ) external;
  function keeper (  ) external view returns ( address  );
  function mintBondTokenForRewards ( address to_, uint256 amount_ ) external returns ( uint256 totalFeeAmount );
  function pancakeUserInfo (  ) external view returns ( UserInfo memory  );
  function pause (  ) external;
  function paused (  ) external view returns ( bool  );
  function redeem ( uint256 amount_ ) external;
  function redeemAll (  ) external;
  function remoteUnderlyingAmount (  ) external view returns ( uint256  );
  function removeFeeSpec ( uint256 feeSpecIndex_ ) external;
  function secondsToPancakeLockExtend ( bool deposit_ ) external view returns ( uint256 secondsToExtend );
  function setAdmin ( address newAdmin ) external;
  function setCakePool ( address cakePool_ ) external;
  function setConvertable ( bool convertable_ ) external;
  function setFarmingPools ( address bondPool_, address lpPool_ ) external;
  function setFeeSpec ( uint256 feeId_, FeeSpec calldata feeSpec_ ) external;
  function setKeeper ( address newKeeper ) external;
  function setRedeemable ( bool redeemable_ ) external;
  function totalBondTokenAmount (  ) external view returns ( uint256  );
  function totalPendingRewards (  ) external view returns ( uint256  );
  function totalUnderlyingAmount (  ) external view returns ( uint256  );
  function underlyingAmount (  ) external view returns ( uint256  );
  function underlyingToken (  ) external view returns ( address  );
  function unpause (  ) external;
  function updateCheckPoints ( CheckPoints calldata checkPoints_ ) external;
  function withdrawAllCakesFromPancake ( bool makeRedeemable_ ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IBondLPPancakeFarmingPool {
  function ACC_REWARDS_PRECISION (  ) external view returns ( uint256  );
  function accPancakeRewardsPerShares (  ) external view returns ( uint256  );
  function accRewardPerShare (  ) external view returns ( uint256  );
  function admin (  ) external view returns ( address  );
  function bond (  ) external view returns ( address  );
  function bondRewardsSuspended (  ) external view returns ( bool  );
  function bondToken (  ) external view returns ( address  );
  function cakeToken (  ) external view returns ( address  );
  function claimBonuses (  ) external;
  function getUserPendingRewards ( address user_ ) external view returns ( uint256  );
  function initPancake ( address cakeToken_, address pancakeMasterChef_, uint256 pancakeMasterChefPid_ ) external;
  function initialize ( address bondToken_, address bond_, address admin_ ) external;
  function lastUpdatedPoolAt (  ) external view returns ( uint256  );
  function lpToken (  ) external view returns ( address  );
  function masterChef (  ) external view returns ( address  );
  function masterChefPid (  ) external view returns ( uint256  );
  function pancakeMasterChef (  ) external view returns ( address  );
  function pancakeMasterChefPid (  ) external view returns ( uint256  );
  function pancakeUsersInfo ( address  ) external view returns ( uint256 rewardDebt, uint256 pendingRewards, uint256 claimedRewards );
  function paused (  ) external view returns ( bool  );
  function remoteEnable (  ) external;
  function remoteEnabled (  ) external view returns ( bool  );
  function setAdmin ( address newAdmin ) external;
  function setBondRewardsSuspended ( bool suspended_ ) external;
  function setLpToken ( address lpToken_ ) external;
  function setMasterChef ( address masterChef_, uint256 masterChefPid_ ) external;
  function setSiblingPool ( address siblingPool_ ) external;
  function siblingPool (  ) external view returns ( address  );
  function stake ( uint256 amount_ ) external;
  function stakeForUser ( address user_, uint256 amount_ ) external;
  function totalLpAmount (  ) external view returns ( uint256  );
  function totalPendingRewards (  ) external view returns ( uint256  );
  function unstake ( uint256 amount_ ) external;
  function unstakeAll (  ) external;
  function updatePool (  ) external;
  function usersInfo ( address  ) external view returns ( uint256 lpAmount, uint256 rewardDebt, uint256 pendingRewards, uint256 claimedRewards );
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@private/shared/interfaces/ebcake/IBondToken.sol";
import "@private/shared/interfaces/ebcake/IExtendableBond.sol";
import "@private/shared/interfaces/ebcake/IMultiRewardsMasterChef.sol";
import "@private/shared/interfaces/ebcake/IBondFarmingPool.sol";
import "@private/shared/interfaces/ebcake/IBondLPFarmingPool.sol";


abstract contract ExtendableBondReader {

    uint constant BLOCKS_PER_YEAR = (60 / 3) * 60 * 24 * 365;

    struct ExtendableBondPackagePublicInfo {
        string name;
        string symbol;
        uint8 decimals;

        uint256 underlyingUsdPrice;
        uint256 bondUnderlyingPrice;

        bool convertable;
        uint256 convertableFrom;
        uint256 convertableEnd;
        bool redeemable;
        uint256 redeemableFrom;
        uint256 redeemableEnd;
        uint256 maturity;

        uint256 underlyingAPY;
        uint256 singleStake_totalStaked;
        uint256 singleStake_bDuetAPR;
        uint256 lpStake_totalStaked;
        uint256 lpStake_bDuetAPR;
        // uint256 lpStake_extraAPY;
    }

    struct ExtendableBondSingleStakePackageUserInfo {
        int256 singleStake_staked;
        int256 singleStake_ebEarnedToDate;
        uint256 singleStake_bDuetPendingRewards;
        uint256 singleStake_bDuetClaimedRewards;
    }

    struct ExtendableBondLpStakePackageUserInfo {
        uint256 lpStake_underlyingStaked;
        uint256 lpStake_bondStaked;
        uint256 lpStake_lpStaked;
        uint256 lpStake_ebPendingRewards;
        uint256 lpStake_lpClaimedRewards;
        uint256 lpStake_bDuetPendingRewards;
        uint256 lpStake_bDuetClaimedRewards;
    }

    // -------------


    function extendableBondPackagePublicInfo(IExtendableBond eb_) view external returns (ExtendableBondPackagePublicInfo memory) {
        IBondFarmingPool bondFarmingPool = IBondFarmingPool(eb_.bondFarmingPool());
        IBondLPFarmingPool bondLPFarmingPool = IBondLPFarmingPool(eb_.bondLPFarmingPool());
        (
            bool convertable,
            uint256 convertableFrom,
            uint256 convertableEnd,
            bool redeemable,
            uint256 redeemableFrom,
            uint256 redeemableEnd,
            uint256 maturity
        ) = eb_.checkPoints();
        ERC20 token = ERC20(eb_.bondToken());

        ExtendableBondPackagePublicInfo memory packageInfo = ExtendableBondPackagePublicInfo({
            name: token.name(),
            symbol: token.symbol(),
            decimals: token.decimals(),

            underlyingUsdPrice: _unsafely_getUnderlyingPriceAsUsd(eb_),
            bondUnderlyingPrice: _getBondPriceAsUnderlying(eb_),

            convertable: convertable,
            convertableFrom: convertableFrom,
            convertableEnd: convertableEnd,
            redeemable: redeemable,
            redeemableFrom: redeemableFrom,
            redeemableEnd: redeemableEnd,
            maturity: maturity,

            underlyingAPY: _getUnderlyingAPY(eb_),
            singleStake_totalStaked: bondFarmingPool.underlyingAmount(false),
            singleStake_bDuetAPR: _getSingleStake_bDuetAPR(eb_),
            lpStake_totalStaked: bondLPFarmingPool.totalLpAmount(),
            lpStake_bDuetAPR: _getLpStake_bDuetAPR(eb_)
            // // lpStake_extraAPY: _getLpStake_extraAPR(eb_) ??
        });
        return packageInfo;
    }

    function extendableBondSingleStakePackageUserInfo(IExtendableBond eb_) view external returns (ExtendableBondSingleStakePackageUserInfo memory) {
        address user = msg.sender;
        require(user != address(0), "Invalid sender address");

        IBondFarmingPool bondFarmingPool = IBondFarmingPool(eb_.bondFarmingPool());

        ( uint256 bondFarmingUsershares, ) = bondFarmingPool.usersInfo(user);

        uint256 singleStake_bDuetPendingRewards = _getPendingRewardsAmount(eb_, bondFarmingPool.masterChefPid(), user);
        uint256 claimedRewardsAmount = _getUserClaimedRewardsAmount(eb_, bondFarmingPool.masterChefPid(), user);

        ExtendableBondSingleStakePackageUserInfo memory packageInfo = ExtendableBondSingleStakePackageUserInfo({
            singleStake_staked: int256(bondFarmingPool.sharesToBondAmount(bondFarmingUsershares)),
            singleStake_ebEarnedToDate: bondFarmingPool.earnedToDate(user),
            singleStake_bDuetPendingRewards: singleStake_bDuetPendingRewards,
            singleStake_bDuetClaimedRewards: claimedRewardsAmount
        });
        return packageInfo;
    }

    function extendableBondLpStakePackageUserInfo(IExtendableBond eb_) view external returns (ExtendableBondLpStakePackageUserInfo memory) {
        address user = msg.sender;
        require(user != address(0), "Invalid sender address");

        IBondLPFarmingPool bondLPFarmingPool = IBondLPFarmingPool(eb_.bondLPFarmingPool());
        ( uint256 lpStake_lpStaked, , , uint256 lpClaimedRewards )
            = bondLPFarmingPool.usersInfo(user);
        ( uint256 lpStake_underlyingStaked, uint256 lpStake_bondStaked )
            = _getLpStakeDetail(eb_, lpStake_lpStaked);

        uint256 lpStake_bDuetPendingRewards = _getPendingRewardsAmount(eb_, _getEbFarmingPoolId(eb_), user);
        uint256 lpStake_ebPendingRewards = bondLPFarmingPool.getUserPendingRewards(user);

        uint256 bDuetClaimedRewardsAmount = _getUserClaimedRewardsAmount(eb_, _getEbFarmingPoolId(eb_), user);

        ExtendableBondLpStakePackageUserInfo memory packageInfo = ExtendableBondLpStakePackageUserInfo({
            lpStake_underlyingStaked: lpStake_underlyingStaked,
            lpStake_bondStaked: lpStake_bondStaked,
            lpStake_lpStaked: lpStake_lpStaked,
            lpStake_ebPendingRewards: lpStake_ebPendingRewards,
            lpStake_lpClaimedRewards: lpClaimedRewards,
            lpStake_bDuetPendingRewards: lpStake_bDuetPendingRewards,
            lpStake_bDuetClaimedRewards: bDuetClaimedRewardsAmount
        });
        return packageInfo;
    }

    // -------------

    function _unsafely_getDuetPriceAsUsd(IExtendableBond eb_) view internal virtual returns (uint256) {}

    function _unsafely_getUnderlyingPriceAsUsd(IExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getBondPriceAsUnderlying(IExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getLpStackedReserves(IExtendableBond eb_) view internal virtual returns (uint256, uint256) {}

    function _getLpStackedTotalSupply(IExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getEbFarmingPoolId(IExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getUnderlyingAPY(IExtendableBond eb_) view internal virtual returns (uint256) {}

    // function _getLpStake_extraAPR(IExtendableBond eb_) view internal virtual returns (uint256) {}

    // -------------

    function _getSingleStake_bDuetAPR(IExtendableBond eb_) view internal returns (uint256) {
        IBondFarmingPool bondFarmingPool = IBondFarmingPool(eb_.bondFarmingPool());
        return _getBDuetAPR(eb_, bondFarmingPool.masterChefPid());
    }

    function _getLpStake_bDuetAPR(IExtendableBond eb_) view internal returns (uint256) {
        return _getBDuetAPR(eb_, _getEbFarmingPoolId(eb_));
    }

    // @TODO: extract as utils
    function _getBDuetAPR(IExtendableBond eb_, uint256 pid_) view internal returns (uint256 apr) {
        uint256 bondTokenBalance = IBondToken(eb_.bondToken()).totalSupply();
        if (bondTokenBalance == 0) return apr;

        IBondFarmingPool bondFarmingPool = IBondFarmingPool(eb_.bondFarmingPool());
        IMultiRewardsMasterChef mMasterChef = IMultiRewardsMasterChef(bondFarmingPool.masterChef());

        uint256 totalAllocPoint = mMasterChef.totalAllocPoint();
        if (totalAllocPoint == 0) return apr;

        uint256 unsafe_duetPriceAsUsd = _unsafely_getDuetPriceAsUsd(eb_);
        uint256 underlyingPriceAsUsd = _unsafely_getUnderlyingPriceAsUsd(eb_);
        if (underlyingPriceAsUsd == 0) return apr;

        ( , uint256 allocPoint, , , ) = mMasterChef.poolInfo(pid_);
        for (uint256 rewardId; rewardId < mMasterChef.getRewardSpecsLength(); rewardId++) {
            ( , uint256 rewardPerBlock, , , ) = mMasterChef.rewardSpecs(rewardId);
            apr += rewardPerBlock * 1e4 * allocPoint
                    / totalAllocPoint
                    * BLOCKS_PER_YEAR
                    * unsafe_duetPriceAsUsd
                    / (bondTokenBalance * underlyingPriceAsUsd);
        }
    }

    function _getUserClaimedRewardsAmount(IExtendableBond eb_, uint pid_, address user_) view internal returns (uint256 amount) {
        IBondFarmingPool bondFarmingPool = IBondFarmingPool(eb_.bondFarmingPool());
        IMultiRewardsMasterChef mMasterChef = IMultiRewardsMasterChef(bondFarmingPool.masterChef());

        for (uint256 rewardId; rewardId < mMasterChef.getRewardSpecsLength(); rewardId++) {
            amount += mMasterChef.getUserClaimedRewards(pid_, user_, rewardId);
        }
    }

    function _getPendingRewardsAmount(IExtendableBond eb_, uint pid_, address user_) view internal returns (uint256 amount) {
        IBondFarmingPool bondFarmingPool = IBondFarmingPool(eb_.bondFarmingPool());
        IMultiRewardsMasterChef mMasterChef = IMultiRewardsMasterChef(bondFarmingPool.masterChef());

        IMultiRewardsMasterChef.RewardInfo[] memory rewardInfos = mMasterChef.pendingRewards(pid_, user_);
        for (uint256 rewardId; rewardId < mMasterChef.getRewardSpecsLength(); rewardId++) {
            amount += rewardInfos[rewardId].amount;
        }
    }

     function _getLpStakeDetail(IExtendableBond eb_, uint256 lpStaked) view internal returns (
        uint256 lpStake_underlyingStaked, uint256 lpStake_bondStaked
    ) {
        uint256 lpStackTotalSupply = _getLpStackedTotalSupply(eb_);

        ( uint256 lpStake_underlyingReserve, uint256 lpStake_bondReserve ) = _getLpStackedReserves(eb_);
        lpStake_underlyingStaked = lpStake_underlyingReserve * lpStaked / lpStackTotalSupply;
        lpStake_bondStaked = lpStake_bondReserve * lpStaked / lpStackTotalSupply;
    }

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma abicoder v2;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@private/shared/libs/Adminable.sol";


contract ExtendableBondRegistry is Initializable, Adminable {

    string[] private groups;
    mapping(string => address[]) private groupedExtendableBonds;

    event GroupCreated(string indexed groupTopic);
    event GroupDestroyed(string indexed groupTopic);
    event GroupItemAppended(string indexed groupTopic, address item);
    event GroupItemRemoved(string indexed groupTopic, address item);

    // --------------

    function initialize(address admin_) public initializer {
        require(admin_ != address(0), "Cant set admin to zero address");
        _setAdmin(admin_);
    }

    function groupNames() view external returns (string[] memory) {
        return groups;
    }

    function groupedAddresses(string calldata groupName_) view external returns (address[] memory) {
        return groupedExtendableBonds[groupName_];
    }

    // --------------


    function createGroup(
        string calldata groupName_
    ) external onlyAdmin {
        for (uint256 i; i< groups.length; i++) {
            if (keccak256(abi.encodePacked(groups[i])) == keccak256(abi.encodePacked(groupName_))) {
                revert('Duplicate group name');
            }
        }
        address[] memory newList;
        groupedExtendableBonds[groupName_] = newList;
        groups.push(groupName_);
        emit GroupCreated(groupName_);
    }

    function destroyGroup(
        string calldata groupName_
    ) external onlyAdmin {
        int256 indexOf = -1;
        for (uint256 i; i< groups.length; i++) {
            if (keccak256(abi.encodePacked(groups[i])) == keccak256(abi.encodePacked(groupName_))) {
                indexOf = int256(i);
                break;
            }
        }
        if (indexOf < 0) revert('Unregistred group name');
        groups[uint256(indexOf)] = groups[groups.length - 1];
        groups.pop();
        delete groupedExtendableBonds[groupName_];
        emit GroupDestroyed(groupName_);
    }

    function appendGroupItem(
        string calldata groupName_,
        address itemAddress_
    ) external onlyAdmin onlyGroupNameRegistered(groupName_) {
        address[] storage group = groupedExtendableBonds[groupName_];
        for (uint256 i; i < group.length; i++) {
            if (group[i] == itemAddress_) revert('Duplicate address in group');
        }
        group.push(itemAddress_);
        emit GroupItemAppended(groupName_, itemAddress_);
    }


    function removeGroupItem(
        string calldata groupName_,
        address itemAddress_
    ) external onlyAdmin onlyGroupNameRegistered(groupName_) {
        address[] storage group = groupedExtendableBonds[groupName_];
        if (group.length == 0) return;
        for (uint256 i = group.length - 1; i >= 0; i--) {
            if (group[i] != itemAddress_) continue;
            group[i] = group[group.length - 1];
            group.pop();
            emit GroupItemRemoved(groupName_, itemAddress_);
            break;
        }
    }

    // --------------


    modifier onlyGroupNameRegistered(string calldata groupName_) virtual {
        bool found;
        for (uint256 i; i< groups.length; i++) {
            if (keccak256(abi.encodePacked(groups[i])) == keccak256(abi.encodePacked(groupName_))) {
                found = true;
                break;
            }
        }
        require(found, 'Unregistred group name');

        _;
    }

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
pragma solidity 0.8.9;

import "./IBEP20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IBondToken {
  function allowance ( address owner, address spender ) external view returns ( uint256  );
  function approve ( address spender, uint256 amount ) external returns ( bool  );
  function balanceOf ( address account ) external view returns ( uint256  );
  function burnFrom ( address account_, uint256 amount_ ) external;
  function decimals (  ) external view returns ( uint8  );
  function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool  );
  function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool  );
  function mint ( address to_, uint256 amount_ ) external;
  function minter (  ) external view returns ( address  );
  function name (  ) external view returns ( string calldata  );
  function owner (  ) external view returns ( address  );
  function renounceOwnership (  ) external;
  function setMinter ( address minter_ ) external;
  function symbol (  ) external view returns ( string calldata  );
  function totalSupply (  ) external view returns ( uint256  );
  function transfer ( address to, uint256 amount ) external returns ( bool  );
  function transferFrom ( address from, address to, uint256 amount ) external returns ( bool  );
  function transferOwnership ( address newOwner ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IMultiRewardsMasterChef {
  struct RewardInfo { address token; uint256 amount; }
  function add ( uint256 _allocPoint, address _lpToken, address _proxyFarmer, bool _withUpdate ) external returns ( uint256 pid );
  function addRewardSpec ( address token, uint256 rewardPerBlock, uint256 startedAtBlock, uint256 endedAtBlock ) external returns ( uint256 rewardId );
  function admin (  ) external view returns ( address  );
  function deposit ( uint256 _pid, uint256 _amount ) external;
  function depositForUser ( uint256 _pid, uint256 _amount, address user_ ) external;
  function emergencyWithdraw ( uint256 _pid ) external;
  function getMultiplier ( uint256 _from, uint256 _to, uint256 rewardId ) external view returns ( uint256  );
  function getRewardSpecsLength (  ) external view returns ( uint256  );
  function getUserAmount ( uint256 pid_, address user_ ) external view returns ( uint256  );
  function getUserClaimedRewards ( uint256 pid_, address user_, uint256 rewardId_ ) external view returns ( uint256  );
  function getUserRewardDebt ( uint256 pid_, address user_, uint256 rewardId_ ) external view returns ( uint256  );
  function initialize ( address admin_ ) external;
  function massUpdatePools (  ) external;
  function migrate ( uint256 _pid ) external;
  function migrator (  ) external view returns ( address  );
  function pendingRewards ( uint256 _pid, address _user ) external view returns ( RewardInfo[] memory  );
  function poolInfo ( uint256  ) external view returns ( address lpToken, uint256 allocPoint, uint256 lastRewardBlock, address proxyFarmer, uint256 totalAmount );
  function poolLength (  ) external view returns ( uint256  );
  function poolsRewardsAccRewardsPerShare ( uint256 , uint256  ) external view returns ( uint256  );
  function previewSetRewardSpec ( uint256 rewardId, uint256 rewardPerBlock, uint256 startedAtBlock, uint256 endedAtBlock ) external view returns ( uint256 depositAmount, uint256 refundAmount );
  function rewardSpecs ( uint256  ) external view returns ( address token, uint256 rewardPerBlock, uint256 startedAtBlock, uint256 endedAtBlock, uint256 claimedAmount );
  function set ( uint256 _pid, uint256 _allocPoint, bool _withUpdate ) external;
  function setAdmin ( address admin_ ) external;
  function setMigrator ( address _migrator ) external;
  function setRewardSpec ( uint256 rewardId, uint256 rewardPerBlock, uint256 startedAtBlock, uint256 endedAtBlock ) external;
  function totalAllocPoint (  ) external view returns ( uint256  );
  function updatePool ( uint256 _pid ) external;
  function userInfo ( uint256 , address  ) external view returns ( uint256 amount );
  function withdraw ( uint256 _pid, uint256 _amount ) external;
  function withdrawForUser ( uint256 _pid, uint256 _amount, address user_ ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IBondFarmingPool {
  function admin (  ) external view returns ( address  );
  function amountToShares ( uint256 amount_ ) external view returns ( uint256  );
  function bond (  ) external view returns ( address  );
  function bondToken (  ) external view returns ( address  );
  function claimBonuses (  ) external;
  function earnedToDate ( address user_ ) external view returns ( int256  );
  function initialize ( address bondToken_, address bond_, address admin_ ) external;
  function lastUpdatedPoolAt (  ) external view returns ( uint256  );
  function masterChef (  ) external view returns ( address  );
  function masterChefPid (  ) external view returns ( uint256  );
  function paused (  ) external view returns ( bool  );
  function pendingRewardsByShares ( uint256 shares_ ) external view returns ( uint256  );
  function setAdmin ( address newAdmin ) external;
  function setMasterChef ( address masterChef_, uint256 masterChefPid_ ) external;
  function setSiblingPool ( address siblingPool_ ) external;
  function sharesToBondAmount ( uint256 shares_ ) external view returns ( uint256  );
  function siblingPool (  ) external view returns ( address  );
  function stake ( uint256 amount_ ) external;
  function stakeForUser ( address user_, uint256 amount_ ) external;
  function totalPendingRewards (  ) external view returns ( uint256  );
  function totalShares (  ) external view returns ( uint256  );
  function underlyingAmount ( bool exclusiveFees ) external view returns ( uint256  );
  function unstake ( uint256 shares_ ) external;
  function unstakeAll (  ) external;
  function unstakeByAmount ( uint256 amount_ ) external;
  function updatePool (  ) external;
  function usersInfo ( address  ) external view returns ( uint256 shares, int256 accNetStaked );
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IBondLPFarmingPool {
  function ACC_REWARDS_PRECISION (  ) external view returns ( uint256  );
  function accRewardPerShare (  ) external view returns ( uint256  );
  function admin (  ) external view returns ( address  );
  function bond (  ) external view returns ( address  );
  function bondRewardsSuspended (  ) external view returns ( bool  );
  function bondToken (  ) external view returns ( address  );
  function claimBonuses (  ) external;
  function getUserPendingRewards ( address user_ ) external view returns ( uint256  );
  function initialize ( address bondToken_, address bond_, address admin_ ) external;
  function lastUpdatedPoolAt (  ) external view returns ( uint256  );
  function lpToken (  ) external view returns ( address  );
  function masterChef (  ) external view returns ( address  );
  function masterChefPid (  ) external view returns ( uint256  );
  function paused (  ) external view returns ( bool  );
  function setAdmin ( address newAdmin ) external;
  function setBondRewardsSuspended ( bool suspended_ ) external;
  function setLpToken ( address lpToken_ ) external;
  function setMasterChef ( address masterChef_, uint256 masterChefPid_ ) external;
  function setSiblingPool ( address siblingPool_ ) external;
  function siblingPool (  ) external view returns ( address  );
  function stake ( uint256 amount_ ) external;
  function stakeForUser ( address user_, uint256 amount_ ) external;
  function totalLpAmount (  ) external view returns ( uint256  );
  function totalPendingRewards (  ) external view returns ( uint256  );
  function unstake ( uint256 amount_ ) external;
  function unstakeAll (  ) external;
  function updatePool (  ) external;
  function usersInfo ( address  ) external view returns ( uint256 lpAmount, uint256 rewardDebt, uint256 pendingRewards, uint256 claimedRewards );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}