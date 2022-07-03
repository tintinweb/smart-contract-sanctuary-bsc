// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ExtendableBondedCake.sol";
import "./BondLPPancakeFarmingPool.sol";
import "../../ExtendableBond.sol";
import "../../ExtendableBondReader.sol";
import "../../ExtendableBondRegistry.sol";
import "../../interfaces/ICakePool.sol";
import "../../interfaces/IPancakePair.sol";
import "../../mocks/CakePool.sol";
import "../../mocks/MasterChefV2.sol";


contract ExtendableBondedCakeReader is Initializable, ExtendableBondReader {
    using Math for uint256;

    uint constant BOOST_WEIGHT = 2e13;
    uint constant DURATION_FACTOR = 365 * 24 * 60 * 60;
    uint constant PRECISION_FACTOR = 1e12;
    uint constant WEI_PER_EHTER = 1e18;
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
    CakePool public pancakePool;
    MasterChefV2 public pancakeMasterChef;
    IPancakePair public pairTokenAddress__CAKE_BUSD;
    IPancakePair public pairTokenAddress__DUET_BUSD;
    IPancakePair public pairTokenAddress__DUET_CAKE;

    function initialize(
      address registry_,
      address pancakePool_,
      address pancakeMasterChef_,
      address pairTokenAddress__CAKE_BUSD_,
      address pairTokenAddress__DUET_BUSD_,  // optional. if so, the next should be required
      address pairTokenAddress__DUET_CAKE_   // optional, if so, the previous should be required
    ) public initializer {
        require(registry_ != address(0), "Cant set Registry to zero address");
        registry = ExtendableBondRegistry(registry_);
        require(pancakePool_ != address(0), "Cant set PancakePool to zero address");
        pancakePool = CakePool(pancakePool_);
        require(pancakeMasterChef_ != address(0), "Cant set PancakeMasterChef to zero address");
        pancakeMasterChef = MasterChefV2(pancakeMasterChef_);
        require(pairTokenAddress__CAKE_BUSD_ != address(0), "Cant set PairTokenAddress__CAKE_BUSD to zero address");
        pairTokenAddress__CAKE_BUSD = IPancakePair(pairTokenAddress__CAKE_BUSD_);

        require(
          pairTokenAddress__DUET_BUSD_ != address(0) || pairTokenAddress__DUET_CAKE_ != address(0),
          "Must set atlease one non-zero address in (PairTokenAddress__DUET_BUSD, PairTokenAddress__DUET_CAKE)"
        );
        pairTokenAddress__DUET_BUSD = IPancakePair(pairTokenAddress__DUET_BUSD_);
        pairTokenAddress__DUET_CAKE = IPancakePair(pairTokenAddress__DUET_CAKE_);
    }

    function addressBook(ExtendableBondedCake eb_) view external returns (AddressBook memory book) {
      BondFarmingPool bondFarmingPool = BondFarmingPool(address(eb_.bondFarmingPool()));
      BondLPPancakeFarmingPool bondLpFarmingPool = BondLPPancakeFarmingPool(address(eb_.bondLPFarmingPool()));

      book.underlyingToken = address(eb_.underlyingToken());
      book.bondToken = address(eb_.bondToken());
      book.lpToken = address(bondLpFarmingPool.lpToken());
      book.bondFarmingPool = address(eb_.bondFarmingPool());
      book.bondLpFarmingPool = address(eb_.bondLPFarmingPool());
      book.bondFarmingPoolId = bondFarmingPool.masterChefPid();
      book.bondLpFarmingPoolId = bondLpFarmingPool.masterChefPid();
      book.pancakePool = address(eb_.cakePool());
    }

    // -------------

    function extendableBondGroupInfo(string calldata groupName_) view external returns (ExtendableBondGroupInfo memory) {
        uint256 allEbStacked;
        uint256 sumCakePrices;
        address[] memory addresses = registry.groupedAddresses(groupName_);
        uint256 maxDuetSideAPR;
        for (uint256 i; i < addresses.length; i++) {
            address ebAddress = addresses[i];
            ExtendableBondedCake eb = ExtendableBondedCake(ebAddress);
            allEbStacked += ExtendableBond(ebAddress).totalUnderlyingAmount();
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
    function _unsafely_getDuetPriceAsUsd(ExtendableBond eb_) view internal override returns (uint256) {
        BondLPPancakeFarmingPool pool = BondLPPancakeFarmingPool(address(eb_.bondLPFarmingPool()));
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(address(pool.lpToken()));

        uint256 ebCakeLpTotalSupply = cakeWithEbCakeLpPairToken.totalSupply();
        if (ebCakeLpTotalSupply == 0) return 0;

        if (address(pairTokenAddress__DUET_BUSD) != address(0)) {
          ( uint256 duetReserve, uint256 busdReserve, ) = pairTokenAddress__DUET_BUSD.getReserves();
          if (busdReserve == 0 ) return 0;
          return duetReserve / busdReserve * ebCakeLpTotalSupply;
        }

        if (address(pairTokenAddress__DUET_CAKE) != address(0)) {
          ( uint256 cakeReserve0, uint256 busdReserve0, ) = pairTokenAddress__CAKE_BUSD.getReserves();
          ( uint256 duetReserve1, uint256 cakeReserve1, ) = pairTokenAddress__DUET_CAKE.getReserves();
          uint256 alignedDuetPoint = duetReserve1 * cakeReserve0;
          uint256 alignedBusdPoint = busdReserve0 * cakeReserve1;
          if (alignedBusdPoint == 0) return 0;
          return alignedDuetPoint / alignedBusdPoint * ebCakeLpTotalSupply;
        }
        return 0;
    }

    /**
     * Estimates token price by multi-fetching data from DEX.
     * There are some issues like time-lag and precision problems.
     * It's OK to do estimation but not for trading basis.
     */
    function _unsafely_getUnderlyingPriceAsUsd(ExtendableBond eb_) view internal override returns (uint256) {
        BondLPPancakeFarmingPool pool = BondLPPancakeFarmingPool(address(eb_.bondLPFarmingPool()));
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(address(pool.lpToken()));

        uint256 ebCakeLpTotalSupply = cakeWithEbCakeLpPairToken.totalSupply();
        if (ebCakeLpTotalSupply == 0) return 0;
        ( uint256 cakeReserve, uint256 busdReserve, ) = pairTokenAddress__CAKE_BUSD.getReserves();
        if (busdReserve == 0 ) return 0;
        return cakeReserve / busdReserve * ebCakeLpTotalSupply;
    }

    function _getBondPriceAsUnderlying(ExtendableBond eb_) view internal override returns (uint256) {
        BondLPPancakeFarmingPool pool = BondLPPancakeFarmingPool(address(eb_.bondLPFarmingPool()));
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(address(pool.lpToken()));

        ( uint256 cakeReserve, uint256 ebCakeReserve, ) = cakeWithEbCakeLpPairToken.getReserves();
        if (ebCakeReserve == 0) return 0;
        return cakeReserve / ebCakeReserve;
    }

    function _getLpStackedReserves(ExtendableBond eb_) view internal override returns (uint256 cakeReserve, uint256 ebCakeReserve) {
        BondLPPancakeFarmingPool pool = BondLPPancakeFarmingPool(address(eb_.bondLPFarmingPool()));
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(address(pool.lpToken()));

        ( cakeReserve, ebCakeReserve, ) = cakeWithEbCakeLpPairToken.getReserves();
    }

    function _getLpStackedTotalSupply(ExtendableBond eb_) view internal override returns (uint256) {
        BondLPPancakeFarmingPool pool = BondLPPancakeFarmingPool(address(eb_.bondLPFarmingPool()));
        IPancakePair cakeWithEbCakeLpPairToken = IPancakePair(address(pool.lpToken()));

        return cakeWithEbCakeLpPairToken.totalSupply();
    }

    function _getEbFarmingPoolId(ExtendableBond eb_) view internal override returns (uint256) {
        BondLPPancakeFarmingPool pool = BondLPPancakeFarmingPool(address(eb_.bondLPFarmingPool()));
        return pool.masterChefPid();
    }

    function _getUnderlyingAPY(ExtendableBond eb_) view internal override returns (uint256) {
        ExtendableBondedCake eb = ExtendableBondedCake(address(eb_));
        ICakePool pool = eb.cakePool();
        ICakePool.UserInfo memory pui = pool.userInfo(address(eb.bondToken()));

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
        uint boostFactor = BOOST_WEIGHT * duration.max(0) / DURATION_FACTOR / PRECISION_FACTOR;

        uint lockedAPY = flexibleApy * (boostFactor + 1);
        return lockedAPY;
    }

    // function _getLpStake_extraAPR(ExtendableBond eb_) view internal override returns (uint256) {
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

import "../../ExtendableBond.sol";
import "../../interfaces/ICakePool.sol";

contract ExtendableBondedCake is ExtendableBond {
    /**
     * CakePool contract
     */
    ICakePool public cakePool;

    function setCakePool(ICakePool cakePool_) external onlyAdmin {
        cakePool = cakePool_;
    }

    /**
     * @dev calculate cake amount from pancake.
     */
    function remoteUnderlyingAmount() public view override returns (uint256) {
        ICakePool.UserInfo memory userInfo = cakePool.userInfo(address(this));
        uint256 pricePerFullShare = cakePool.getPricePerFullShare();
        if (userInfo.shares <= 0) {
            return 0;
        }
        uint256 withdrawFee = 0;
        if (
            ((userInfo.locked ? userInfo.lockEndTime : block.timestamp) <
                userInfo.lastDepositedTime + cakePool.withdrawFeePeriod())
        ) {
            withdrawFee = cakePool.calculateWithdrawFee(address(this), userInfo.shares);
        }
        return (userInfo.shares * pricePerFullShare) / 1e18 - userInfo.userBoostedShare - withdrawFee;
    }

    /**
     * @dev calculate cake amount from pancake.
     */
    function pancakeUserInfo() public view returns (ICakePool.UserInfo memory) {
        return cakePool.userInfo(address(this));
    }

    /**
     * @dev withdraw from pancakeswap
     */
    function _withdrawFromRemote(uint256 amount_) internal override {
        cakePool.withdrawByAmount(amount_);
    }

    /**
     * @dev deposit to pancakeswap
     */
    function _depositRemote(uint256 amount_) internal override {
        uint256 balance = underlyingToken.balanceOf(address(this));
        require(balance > 0 && balance >= amount_, "nothing to deposit");
        underlyingToken.approve(address(cakePool), amount_);
        cakePool.deposit(amount_, secondsToPancakeLockExtend(true));

        _checkLockEndTime();
    }

    function _checkLockEndTime() internal view {
        require(pancakeUserInfo().lockEndTime <= checkPoints.maturity, "The lock-up time exceeds the ebCAKE maturity");
    }

    /**
     * @dev calculate lock extend seconds
     * @param deposit_ whether use as deposit param.
     */
    function secondsToPancakeLockExtend(bool deposit_) public view returns (uint256 secondsToExtend) {
        uint256 currentTime = block.timestamp;
        ICakePool.UserInfo memory cakeInfo = cakePool.userInfo(address(this));

        uint256 cakeMaxLockDuration = cakePool.MAX_LOCK_DURATION();
        // lock expired or cake lockEndTime earlier than maturity, extend lock time required.
        if (
            cakeInfo.lockEndTime < checkPoints.maturity &&
            checkPoints.maturity > block.timestamp &&
            (deposit_ || cakeInfo.lockEndTime - cakeInfo.lockStartTime < cakeMaxLockDuration)
        ) {
            if (cakeInfo.lockEndTime >= block.timestamp) {
                // lockStartTime will be updated to block.timestamp in CakePool every time.
                uint256 totalLockDuration = checkPoints.maturity - block.timestamp;
                return
                    MathUpgradeable.min(totalLockDuration, cakeMaxLockDuration) +
                    block.timestamp -
                    cakeInfo.lockEndTime;
            }

            return MathUpgradeable.min(checkPoints.maturity - block.timestamp, cakeMaxLockDuration);
        }

        return secondsToExtend;
    }

    /**
     * @dev Withdraw cake from cake pool.
     */
    function withdrawAllCakesFromPancake(bool makeRedeemable_) public onlyAdminOrKeeper {
        checkPoints.convertable = false;
        cakePool.withdrawAll();
        if (makeRedeemable_) {
            checkPoints.redeemable = true;
        }
    }

    /**
     * @dev extend pancake lock duration if needs
     * @param force_ force extend even it's unnecessary
     */
    function extendPancakeLockDuration(bool force_) public onlyAdminOrKeeper {
        uint256 secondsToExtend = secondsToPancakeLockExtend(force_);
        if (secondsToExtend > 0) {
            cakePool.deposit(0, secondsToExtend);
            _checkLockEndTime();
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;



import "../../interfaces/IPancakeMasterChefV2.sol";
import "../../BondLPFarmingPool.sol";

contract BondLPPancakeFarmingPool is BondLPFarmingPool {
    IERC20Upgradeable public cakeToken;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IPancakeMasterChefV2 public pancakeMasterChef;

    uint256 public pancakeMasterChefPid;

    /**
     * @dev accumulated cake rewards of each lp token.
     */
    uint256 public accPancakeRewardsPerShares;

    /**
     * @dev whether remote staking enabled (stake to PancakeSwap LP farming pool).
     * @notice It cannot be modified from true to false as this may cause accounting problems.
     */
    bool public remoteEnabled;

    struct PancakeUserInfo {
        /**
         * like sushi rewardDebt
         */
        uint256 rewardDebt;
        /**
         * @dev Rewards credited to rewardDebt but not yet claimed
         */
        uint256 pendingRewards;
        /**
         * @dev claimed rewards. for 'earned to date' calculation.
         */
        uint256 claimedRewards;
    }

    mapping(address => PancakeUserInfo) public pancakeUsersInfo;

    function initPancake(
        IERC20Upgradeable cakeToken_,
        IPancakeMasterChefV2 pancakeMasterChef_,
        uint256 pancakeMasterChefPid_
    ) external onlyAdmin {
        require(
            address(pancakeMasterChef_) != address(0) &&
                pancakeMasterChefPid_ != 0 &&
                address(cakeToken_) != address(0),
            "Invalid inputs"
        );
        require(
            address(pancakeMasterChef) == address(0) && pancakeMasterChefPid == 0,
            "can not modify pancakeMasterChef"
        );
        cakeToken = cakeToken_;
        pancakeMasterChef = pancakeMasterChef_;
        pancakeMasterChefPid = pancakeMasterChefPid_;
    }

    /**
     * @dev enable remote staking (stake to PancakeSwap LP farming pool).
     */
    function remoteEnable() external onlyAdmin {
        require(!remoteEnabled, "Already enabled");
        remoteEnabled = true;
        _stakeBalanceToRemote();
    }

    function _stakeBalanceToRemote() internal {
        _requirePancakeSettled();
        uint256 balance = lpToken.balanceOf(address(this));
        if (balance <= 0) {
            return;
        }
        lpToken.safeApprove(address(pancakeMasterChef), balance);
        pancakeMasterChef.deposit(pancakeMasterChefPid, balance);
    }

    function _requirePancakeSettled() internal view {
        require(
            address(pancakeMasterChef) != address(0) && pancakeMasterChefPid != 0 && address(cakeToken) != address(0),
            "Pancake not settled"
        );
    }

    /**
     * @dev stake to pancakeswap
     * @param user_ user to stake
     * @param amount_ amount to stake
     */
    function _stakeRemote(address user_, uint256 amount_) internal override {
        UserInfo storage userInfo = usersInfo[user_];
        PancakeUserInfo storage pancakeUserInfo = pancakeUsersInfo[user_];

        if (userInfo.lpAmount > 0) {
            uint256 sharesReward = (accPancakeRewardsPerShares * userInfo.lpAmount) / ACC_REWARDS_PRECISION;
            pancakeUserInfo.pendingRewards += sharesReward - pancakeUserInfo.rewardDebt;
            pancakeUserInfo.rewardDebt =
                (accPancakeRewardsPerShares * (userInfo.lpAmount + amount_)) /
                ACC_REWARDS_PRECISION;
        } else {
            pancakeUserInfo.rewardDebt = (accPancakeRewardsPerShares * amount_) / ACC_REWARDS_PRECISION;
        }

        if (amount_ > 0 && remoteEnabled) {
            _requirePancakeSettled();
            lpToken.safeApprove(address(pancakeMasterChef), amount_);
            // deposit to pancake
            pancakeMasterChef.deposit(pancakeMasterChefPid, amount_);
        }
    }

    /**
     * @dev unstake from pancakeswap
     * @param user_ user to unstake
     * @param amount_ amount to unstake
     */
    function _unstakeRemote(address user_, uint256 amount_) internal override {
        UserInfo storage userInfo = usersInfo[user_];
        PancakeUserInfo storage pancakeUserInfo = pancakeUsersInfo[user_];

        uint256 sharesReward = (accPancakeRewardsPerShares * userInfo.lpAmount) / ACC_REWARDS_PRECISION;
        uint256 pendingRewards = sharesReward + pancakeUserInfo.pendingRewards - pancakeUserInfo.rewardDebt;
        pancakeUserInfo.pendingRewards = 0;
        pancakeUserInfo.rewardDebt = sharesReward;

        if (remoteEnabled) {
            _requirePancakeSettled();
            // withdraw from pancake
            pancakeMasterChef.withdraw(pancakeMasterChefPid, amount_);
        }
        if (pendingRewards > 0) {
            uint256 cakeBalance = cakeToken.balanceOf(address(this));
            // send cake rewards
            if (pendingRewards > cakeBalance) {
                cakeToken.safeTransfer(user_, cakeBalance);
                pancakeUserInfo.claimedRewards += cakeBalance;
            } else {
                cakeToken.safeTransfer(user_, pendingRewards);
                pancakeUserInfo.claimedRewards += pendingRewards;
            }
        }
    }

    /**
     * @dev harvest from pancakeswap
     */
    function _harvestRemote() internal override {
        if (!remoteEnabled) {
            return;
        }
        _requirePancakeSettled();

        uint256 previousCakeAmount = cakeToken.balanceOf(address(this));
        pancakeMasterChef.deposit(pancakeMasterChefPid, 0);
        uint256 afterCakeAmount = cakeToken.balanceOf(address(this));
        uint256 newRewards = afterCakeAmount - previousCakeAmount;
        if (newRewards > 0) {
            accPancakeRewardsPerShares += (newRewards * ACC_REWARDS_PRECISION) / totalLpAmount;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./BondToken.sol";
import "./interfaces/IBondFarmingPool.sol";
import "./interfaces/IExtendableBond.sol";
import "./interfaces/IBondTokenUpgradeable.sol";
import "./libs/Adminable.sol";
import "./libs/Keepable.sol";

contract ExtendableBond is IExtendableBond, ReentrancyGuardUpgradeable, PausableUpgradeable, Adminable, Keepable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for IBondTokenUpgradeable;
    /**
     * Bond token contract
     */
    IBondTokenUpgradeable public bondToken;

    /**
     * Bond underlying asset
     */
    IERC20Upgradeable public underlyingToken;

    /**
     * @dev factor for percentage that described in integer. It makes 10000 means 100%, and 20 means 0.2%;
     *      Calculation formula: x * percentage / PERCENTAGE_FACTOR
     */
    uint16 public constant PERCENTAGE_FACTOR = 10000;
    IBondFarmingPool public bondFarmingPool;
    IBondFarmingPool public bondLPFarmingPool;
    /**
     * Emitted when someone convert underlying token to the bond.
     */
    event Converted(uint256 amount, address indexed user);

    event MintedBondTokenForRewards(address indexed to, uint256 amount);

    struct FeeSpec {
        string desc;
        uint16 rate;
        address receiver;
    }

    /**
     * Fee specifications
     */
    FeeSpec[] public feeSpecs;

    struct CheckPoints {
        bool convertable;
        uint256 convertableFrom;
        uint256 convertableEnd;
        bool redeemable;
        uint256 redeemableFrom;
        uint256 redeemableEnd;
        uint256 maturity;
    }

    CheckPoints public checkPoints;
    modifier onlyAdminOrKeeper() virtual {
        require(msg.sender == admin || msg.sender == keeper, "UNAUTHORIZED");

        _;
    }

    function initialize(
        IBondTokenUpgradeable bondToken_,
        IERC20Upgradeable underlyingToken_,
        address admin_
    ) public initializer {
        require(admin_ != address(0), "Cant set admin to zero address");
        __Pausable_init();
        __ReentrancyGuard_init();
        _setAdmin(msg.sender);

        bondToken = bondToken_;
        underlyingToken = underlyingToken_;
    }

    function feeSpecsLength() public view returns (uint256) {
        return feeSpecs.length;
    }

    /**
     * @notice Underlying token amount that hold in current contract.
     */
    function underlyingAmount() public view returns (uint256) {
        return underlyingToken.balanceOf(address(this));
    }

    /**
     * @notice total underlying token amount, including hold in current contract and remote
     */
    function totalUnderlyingAmount() public view returns (uint256) {
        return underlyingAmount() + remoteUnderlyingAmount();
    }

    /**
     * @dev Total pending rewards for bond. May be negative in some unexpected circumstances,
     *      such as remote underlying amount has unexpectedly decreased makes bond token over issued.
     */
    function totalPendingRewards() public view returns (uint256) {
        uint256 underlying = totalUnderlyingAmount();
        uint256 bondAmount = totalBondTokenAmount();
        if (bondAmount >= underlying) {
            return 0;
        }
        return underlying - bondAmount;
    }

    function calculateFeeAmount(uint256 amount_) public view returns (uint256) {
        if (amount_ <= 0) {
            return 0;
        }
        uint256 totalFeeAmount = 0;
        for (uint256 i = 0; i < feeSpecs.length; i++) {
            FeeSpec storage feeSpec = feeSpecs[i];
            uint256 feeAmount = (amount_ * feeSpec.rate) / PERCENTAGE_FACTOR;

            if (feeAmount <= 0) {
                continue;
            }
            totalFeeAmount += feeAmount;
        }
        return totalFeeAmount;
    }

    /**
     * @dev mint bond token for rewards and allocate fees.
     */
    function mintBondTokenForRewards(address to_, uint256 amount_) public returns (uint256 totalFeeAmount) {
        require(
            msg.sender == address(bondFarmingPool) || msg.sender == address(bondLPFarmingPool),
            "only from farming pool"
        );
        require(totalBondTokenAmount() + amount_ <= totalUnderlyingAmount(), "Can not over issue");

        // nothing to happen when reward amount is zero.
        if (amount_ <= 0) {
            return 0;
        }

        uint256 amountToTarget = amount_;
        // allocate fees.
        for (uint256 i = 0; i < feeSpecs.length; i++) {
            FeeSpec storage feeSpec = feeSpecs[i];
            uint256 feeAmount = (amountToTarget * feeSpec.rate) / PERCENTAGE_FACTOR;

            if (feeAmount <= 0) {
                continue;
            }
            amountToTarget -= feeAmount;
            bondToken.mint(feeSpec.receiver, feeAmount);
        }

        if (amountToTarget > 0) {
            bondToken.mint(to_, amountToTarget);
        }

        emit MintedBondTokenForRewards(to_, amount_);
        return amount_ - amountToTarget;
    }

    /**
     * Bond token total amount.
     */
    function totalBondTokenAmount() public view returns (uint256) {
        return bondToken.totalSupply();
    }

    /**
     * calculate remote underlying token amount.
     */
    function remoteUnderlyingAmount() public view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Redeem all my bond tokens to underlying tokens.
     */
    function redeemAll() external whenNotPaused {
        redeem(bondToken.balanceOf(msg.sender));
    }

    /**
     * @dev Redeem specific amount of my bond tokens.
     * @param amount_ amount to redeem
     */
    function redeem(uint256 amount_) public whenNotPaused nonReentrant {
        require(amount_ > 0, "Nothing to redeem");
        require(
            checkPoints.redeemable &&
                block.timestamp >= checkPoints.redeemableFrom &&
                block.timestamp <= checkPoints.redeemableEnd &&
                block.timestamp > checkPoints.convertableEnd,
            "Can not redeem at this time."
        );

        address user = msg.sender;
        uint256 userBondTokenBalance = bondToken.balanceOf(user);
        require(amount_ <= userBondTokenBalance, "Insufficient balance");

        // burn user's bond token
        bondToken.burnFrom(user, amount_);

        uint256 underlyingTokenAmount = underlyingToken.balanceOf(address(this));

        if (underlyingTokenAmount < amount_) {
            _withdrawFromRemote(amount_ - underlyingTokenAmount);
        }
        // for precision issue
        // The underlying asset may be calculated on a share basis, and the amount withdrawn may vary slightly
        if (amount_ > underlyingToken.balanceOf(address(this))) {
            underlyingToken.safeTransfer(user, underlyingToken.balanceOf(address(this)));
        } else {
            underlyingToken.safeTransfer(user, amount_);
        }

    }

    function _withdrawFromRemote(uint256 amount_) internal virtual {}

    /**
     * @dev convert underlying token to bond token to current user
     * @param amount_ amount of underlying token to convert
     */
    function convert(uint256 amount_) external whenNotPaused {
        require(amount_ > 0, "Nothing to convert");

        _convertOperation(amount_, msg.sender);
    }

    function requireConvertable() internal view {
        require(
            checkPoints.convertable &&
                block.timestamp >= checkPoints.convertableFrom &&
                block.timestamp <= checkPoints.convertableEnd &&
                block.timestamp < checkPoints.redeemableFrom,
            "Can not convert at this time."
        );
    }

    /**
     * @dev distribute pending rewards.
     */
    function _updateFarmingPools() internal {
        bondFarmingPool.updatePool();
        bondLPFarmingPool.updatePool();
    }

    function setFarmingPools(IBondFarmingPool bondPool_, IBondFarmingPool lpPool_) public onlyAdmin {
        require(address(bondPool_) != address(0) && address(bondPool_) != address(lpPool_), "invalid farming pools");
        bondFarmingPool = bondPool_;
        bondLPFarmingPool = lpPool_;
    }

    /**
     * @dev convert underlying token to bond token and stake to bondFarmingPool for current user
     */
    function convertAndStake(uint256 amount_) external whenNotPaused nonReentrant {
        require(amount_ > 0, "Nothing to convert");
        requireConvertable();
        // Single bond token farming rewards base on  'bond token mount in pool' / 'total bond token supply' * 'total underlying rewards'  (remaining rewards for LP pools)
        // In order to distribute pending rewards to old shares, bondToken farming pools should be updated when new bondToken converted.
        _updateFarmingPools();

        address user = msg.sender;
        underlyingToken.safeTransferFrom(user, address(this), amount_);
        _depositRemote(amount_);
        // 1:1 mint bond token to current contract
        bondToken.mint(address(this), amount_);
        bondToken.safeApprove(address(bondFarmingPool), amount_);
        // stake to bondFarmingPool
        bondFarmingPool.stakeForUser(user, amount_);
        emit Converted(amount_, user);
    }

    function _depositRemote(uint256 amount_) internal virtual {}

    /**
     * @dev convert underlying token to bond token to specific user
     */
    function _convertOperation(uint256 amount_, address user_) internal nonReentrant {
        requireConvertable();
        // Single bond token farming rewards base on  'bond token mount in pool' / 'total bond token supply' * 'total underlying rewards'   (remaining rewards for LP pools)
        // In order to distribute pending rewards to old shares, bondToken farming pools should be updated when new bondToken converted.
        _updateFarmingPools();

        underlyingToken.safeTransferFrom(user_, address(this), amount_);
        _depositRemote(amount_);
        // 1:1 mint bond token to user
        bondToken.mint(user_, amount_);
        emit Converted(amount_, user_);
    }

    /**
     * @dev update checkPoints
     * @param checkPoints_ new checkpoints
     */
    function updateCheckPoints(CheckPoints calldata checkPoints_) public onlyAdminOrKeeper {
        require(checkPoints_.convertableFrom > 0, "convertableFrom must be greater than 0");
        require(
            checkPoints_.convertableFrom < checkPoints_.convertableEnd,
            "redeemableFrom must be earlier than convertableEnd"
        );
        require(
            checkPoints_.redeemableFrom > checkPoints_.convertableEnd &&
                checkPoints_.redeemableFrom >= checkPoints_.maturity,
            "redeemableFrom must be later than convertableEnd and maturity"
        );
        require(
            checkPoints_.redeemableEnd > checkPoints_.redeemableFrom,
            "redeemableEnd must be later than redeemableFrom"
        );
        checkPoints = checkPoints_;
    }

    function setRedeemable(bool redeemable_) external onlyAdminOrKeeper {
        checkPoints.redeemable = redeemable_;
    }

    function setConvertable(bool convertable_) external onlyAdminOrKeeper {
        checkPoints.convertable = convertable_;
    }

    /**
     * @dev emergency transfer underlying token for security issue or bug encounted.
     */
    function emergencyTransferUnderlyingTokens(address to_) external onlyAdmin {
        checkPoints.convertable = false;
        checkPoints.redeemable = false;
        underlyingToken.safeTransfer(to_, underlyingAmount());
    }

    /**
     * @notice add fee specification
     */
    function addFeeSpec(FeeSpec calldata feeSpec_) external onlyAdmin {
        require(feeSpecs.length < 5, "Too many fee specs");
        require(feeSpec_.rate > 0, "Fee rate is too low");
        feeSpecs.push(feeSpec_);
        uint256 totalFeeRate = 0;
        for (uint256 i = 0; i < feeSpecs.length; i++) {
            totalFeeRate += feeSpecs[i].rate;
        }
        require(totalFeeRate <= PERCENTAGE_FACTOR, "Total fee rate greater than 100%.");
    }

    /**
     * @notice update fee specification
     */
    function setFeeSpec(uint256 feeId_, FeeSpec calldata feeSpec_) external onlyAdmin {
        require(feeSpec_.rate > 0, "Fee rate is too low");
        feeSpecs[feeId_] = feeSpec_;
        uint256 totalFeeRate = 0;
        for (uint256 i = 0; i < feeSpecs.length; i++) {
            totalFeeRate += feeSpecs[i].rate;
        }
        require(totalFeeRate <= PERCENTAGE_FACTOR, "Total fee rate greater than 100%.");
    }

    function removeFeeSpec(uint256 feeSpecIndex_) external onlyAdmin {
        uint256 length = feeSpecs.length;
        require(feeSpecIndex_ >=0 && feeSpecIndex_ < length, "Invalid Index");
        feeSpecs[feeSpecIndex_] = feeSpecs[length - 1];
        feeSpecs.pop();
    }

    function depositToRemote(uint256 amount_) public onlyAdminOrKeeper {
        _depositRemote(amount_);
    }

    function depositAllToRemote() public onlyAdminOrKeeper {
        depositToRemote(underlyingToken.balanceOf(address(this)));
    }

    function setKeeper(address newKeeper) external onlyAdmin {
        _setKeeper(newKeeper);
    }

    /**
     * @notice Trigger stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyAdmin whenNotPaused {
        _pause();
    }

    /**
     * @notice Return to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyAdmin whenPaused {
        _unpause();
    }

    function burnBondToken(uint256 amount_) public onlyAdmin {
        bondToken.burnFrom(msg.sender, amount_);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ExtendableBond.sol";
import "./MultiRewardsMasterChef.sol";
import "./BondFarmingPool.sol";
import "./BondLPFarmingPool.sol";


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


    function extendableBondPackagePublicInfo(ExtendableBond eb_) view external returns (ExtendableBondPackagePublicInfo memory) {
        BondFarmingPool bondFarmingPool = BondFarmingPool(address(eb_.bondFarmingPool()));
        BondLPFarmingPool bondLPFarmingPool = BondLPFarmingPool(address(eb_.bondLPFarmingPool()));
        (
            bool convertable,
            uint256 convertableFrom,
            uint256 convertableEnd,
            bool redeemable,
            uint256 redeemableFrom,
            uint256 redeemableEnd,
            uint256 maturity
        ) = eb_.checkPoints();
        ERC20 token = ERC20(address(eb_.bondToken()));

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

    function extendableBondSingleStakePackageUserInfo(ExtendableBond eb_) view external returns (ExtendableBondSingleStakePackageUserInfo memory) {
        address user = msg.sender;
        require(user != address(0), "Invalid sender address");

        BondFarmingPool bondFarmingPool = BondFarmingPool(address(eb_.bondFarmingPool()));

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

    function extendableBondLpStakePackageUserInfo(ExtendableBond eb_) view external returns (ExtendableBondLpStakePackageUserInfo memory) {
        address user = msg.sender;
        require(user != address(0), "Invalid sender address");

        BondLPFarmingPool bondLPFarmingPool = BondLPFarmingPool(address(eb_.bondLPFarmingPool()));
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

    function _unsafely_getDuetPriceAsUsd(ExtendableBond eb_) view internal virtual returns (uint256) {}

    function _unsafely_getUnderlyingPriceAsUsd(ExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getBondPriceAsUnderlying(ExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getLpStackedReserves(ExtendableBond eb_) view internal virtual returns (uint256, uint256) {}

    function _getLpStackedTotalSupply(ExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getEbFarmingPoolId(ExtendableBond eb_) view internal virtual returns (uint256) {}

    function _getUnderlyingAPY(ExtendableBond eb_) view internal virtual returns (uint256) {}

    // function _getLpStake_extraAPR(ExtendableBond eb_) view internal virtual returns (uint256) {}

    // -------------

    function _getSingleStake_bDuetAPR(ExtendableBond eb_) view internal returns (uint256) {
        BondFarmingPool bondFarmingPool = BondFarmingPool(address(eb_.bondFarmingPool()));
        return _getBDuetAPR(eb_, bondFarmingPool.masterChefPid());
    }

    function _getLpStake_bDuetAPR(ExtendableBond eb_) view internal returns (uint256) {
        return _getBDuetAPR(eb_, _getEbFarmingPoolId(eb_));
    }

    // @TODO: extract as utils
    function _getBDuetAPR(ExtendableBond eb_, uint256 pid_) view internal returns (uint256 apr) {
        uint256 bondTokenBalance = eb_.bondToken().totalSupply();
        if (bondTokenBalance == 0) return apr;

        BondFarmingPool bondFarmingPool = BondFarmingPool(address(eb_.bondFarmingPool()));
        MultiRewardsMasterChef mMasterChef = MultiRewardsMasterChef(address(bondFarmingPool.masterChef()));

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

    function _getUserClaimedRewardsAmount(ExtendableBond eb_, uint pid_, address user_) view internal returns (uint256 amount) {
        BondFarmingPool bondFarmingPool = BondFarmingPool(address(eb_.bondFarmingPool()));
        MultiRewardsMasterChef mMasterChef = MultiRewardsMasterChef(address(bondFarmingPool.masterChef()));

        for (uint256 rewardId; rewardId < mMasterChef.getRewardSpecsLength(); rewardId++) {
            amount += mMasterChef.getUserClaimedRewards(pid_, user_, rewardId);
        }
    }

    function _getPendingRewardsAmount(ExtendableBond eb_, uint pid_, address user_) view internal returns (uint256 amount) {
        BondFarmingPool bondFarmingPool = BondFarmingPool(address(eb_.bondFarmingPool()));
        MultiRewardsMasterChef mMasterChef = MultiRewardsMasterChef(address(bondFarmingPool.masterChef()));

        MultiRewardsMasterChef.RewardInfo[] memory rewardInfos = mMasterChef.pendingRewards(pid_, user_);
        for (uint256 rewardId; rewardId < mMasterChef.getRewardSpecsLength(); rewardId++) {
            amount += rewardInfos[rewardId].amount;
        }
    }

     function _getLpStakeDetail(ExtendableBond eb_, uint256 lpStaked) view internal returns (
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
import "./libs/Adminable.sol";


contract ExtendableBondRegistry is Initializable, Adminable {

    string[] private groups;
    mapping(string => address[]) private groupedExtendableBonds;

    event GroupCreated(string groupName);
    event GroupDestroyed(string groupName);
    event GroupItemAppended(string groupName, address item);
    event GroupItemRemoved(string groupName, address item);

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
pragma solidity 0.8.9;

interface ICakePool {
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
// copy from https://bscscan.com/address/0x45c54210128a065de780C4B0Df3d16664f7f859e#code#F1#L1
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IBoostContract {
    function onCakePoolUpdate(
        address _user,
        uint256 _lockedAmount,
        uint256 _lockedDuration,
        uint256 _totalLockedAmount,
        uint256 _maxLockDuration
    ) external;
}

interface IMasterChefV2 {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

interface IVCake {
    function deposit(
        address _user,
        uint256 _amount,
        uint256 _lockDuration
    ) external;

    function withdraw(address _user) external;
}

contract CakePool is Ownable, Pausable {
    using SafeERC20 for IERC20;

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

    IERC20 public immutable token; // cake token.

    IMasterChefV2 public immutable masterchefV2;

    address public boostContract; // boost contract used in Masterchef.
    address public VCake;

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public freePerformanceFeeUsers; // free performance fee users.
    mapping(address => bool) public freeWithdrawFeeUsers; // free withdraw fee users.
    mapping(address => bool) public freeOverdueFeeUsers; // free overdue fee users.

    uint256 public totalShares;
    address public admin;
    address public treasury;
    address public operator;
    uint256 public cakePoolPID;
    uint256 public totalBoostDebt; // total boost debt.
    uint256 public totalLockedAmount; // total lock amount.

    uint256 public constant MAX_PERFORMANCE_FEE = 2000; // 20%
    uint256 public constant MAX_WITHDRAW_FEE = 500; // 5%
    uint256 public constant MAX_OVERDUE_FEE = 100 * 1e10; // 100%
    uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 1 weeks; // 1 week
    uint256 public constant MIN_LOCK_DURATION = 1 weeks; // 1 week
    uint256 public constant MAX_LOCK_DURATION_LIMIT = 1000 days; // 1000 days
    uint256 public constant BOOST_WEIGHT_LIMIT = 5000 * 1e10; // 5000%
    uint256 public constant PRECISION_FACTOR = 1e12; // precision factor.
    uint256 public constant PRECISION_FACTOR_SHARE = 1e28; // precision factor for share.
    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.00001 ether;
    uint256 public constant MIN_WITHDRAW_AMOUNT = 0.00001 ether;
    uint256 public UNLOCK_FREE_DURATION = 1 weeks; // 1 week
    uint256 public MAX_LOCK_DURATION = 365 days; // 365 days
    uint256 public DURATION_FACTOR = 365 days; // 365 days, in order to calculate user additional boost.
    uint256 public DURATION_FACTOR_OVERDUE = 180 days; // 180 days, in order to calculate overdue fee.
    uint256 public BOOST_WEIGHT = 100 * 1e10; // 100%

    uint256 public performanceFee = 200; // 2%
    uint256 public performanceFeeContract = 200; // 2%
    uint256 public withdrawFee = 10; // 0.1%
    uint256 public withdrawFeeContract = 10; // 0.1%
    uint256 public overdueFee = 100 * 1e10; // 100%
    uint256 public withdrawFeePeriod = 72 hours; // 3 days

    event Deposit(address indexed sender, uint256 amount, uint256 shares, uint256 duration, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event Harvest(address indexed sender, uint256 amount);
    event Pause();
    event Unpause();
    event Init();
    event Lock(
        address indexed sender,
        uint256 lockedAmount,
        uint256 shares,
        uint256 lockedDuration,
        uint256 blockTimestamp
    );
    event Unlock(address indexed sender, uint256 amount, uint256 blockTimestamp);
    event NewAdmin(address admin);
    event NewTreasury(address treasury);
    event NewOperator(address operator);
    event NewBoostContract(address boostContract);
    event NewVCakeContract(address VCake);
    event FreeFeeUser(address indexed user, bool indexed free);
    event NewPerformanceFee(uint256 performanceFee);
    event NewPerformanceFeeContract(uint256 performanceFeeContract);
    event NewWithdrawFee(uint256 withdrawFee);
    event NewOverdueFee(uint256 overdueFee);
    event NewWithdrawFeeContract(uint256 withdrawFeeContract);
    event NewWithdrawFeePeriod(uint256 withdrawFeePeriod);
    event NewMaxLockDuration(uint256 maxLockDuration);
    event NewDurationFactor(uint256 durationFactor);
    event NewDurationFactorOverdue(uint256 durationFactorOverdue);
    event NewUnlockFreeDuration(uint256 unlockFreeDuration);
    event NewBoostWeight(uint256 boostWeight);

    /**
     * @notice Constructor
     * @param _token: Cake token contract
     * @param _masterchefV2: MasterChefV2 contract
     * @param _admin: address of the admin
     * @param _treasury: address of the treasury (collects fees)
     * @param _operator: address of operator
     * @param _pid: cake pool ID in MasterChefV2
     */
    constructor(
        IERC20 _token,
        IMasterChefV2 _masterchefV2,
        address _admin,
        address _treasury,
        address _operator,
        uint256 _pid
    ) {
        token = _token;
        masterchefV2 = _masterchefV2;
        admin = _admin;
        treasury = _treasury;
        operator = _operator;
        cakePoolPID = _pid;
    }

    /**
     * @notice Deposits a dummy token to `MASTER_CHEF` MCV2.
     * It will transfer all the `dummyToken` in the tx sender address.
     * @param dummyToken The address of the token to be deposited into MCV2.
     */
    function init(IERC20 dummyToken) external onlyOwner {
        uint256 balance = dummyToken.balanceOf(msg.sender);
        require(balance != 0, "Balance must exceed 0");
        dummyToken.safeTransferFrom(msg.sender, address(this), balance);
        dummyToken.approve(address(masterchefV2), balance);
        masterchefV2.deposit(cakePoolPID, balance);
        emit Init();
    }

    /**
     * @notice Checks if the msg.sender is the admin address.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "admin: wut?");
        _;
    }

    /**
     * @notice Checks if the msg.sender is either the cake owner address or the operator address.
     */
    modifier onlyOperatorOrCakeOwner(address _user) {
        require(msg.sender == _user || msg.sender == operator, "Not operator or cake owner");
        _;
    }

    /**
     * @notice Update user info in Boost Contract.
     * @param _user: User address
     */
    function updateBoostContractInfo(address _user) internal {
        if (boostContract != address(0)) {
            UserInfo storage user = userInfo[_user];
            uint256 lockDuration = user.lockEndTime - user.lockStartTime;
            IBoostContract(boostContract).onCakePoolUpdate(
                _user,
                user.lockedAmount,
                lockDuration,
                totalLockedAmount,
                DURATION_FACTOR
            );
        }
    }

    /**
     * @notice Update user share When need to unlock or charges a fee.
     * @param _user: User address
     */
    function updateUserShare(address _user) internal {
        UserInfo storage user = userInfo[_user];
        if (user.shares > 0) {
            if (user.locked) {
                // Calculate the user's current token amount and update related parameters.
                uint256 currentAmount = (balanceOf() * (user.shares)) / totalShares - user.userBoostedShare;
                totalBoostDebt -= user.userBoostedShare;
                user.userBoostedShare = 0;
                totalShares -= user.shares;
                //Charge a overdue fee after the free duration has expired.
                if (!freeOverdueFeeUsers[_user] && ((user.lockEndTime + UNLOCK_FREE_DURATION) < block.timestamp)) {
                    uint256 earnAmount = currentAmount - user.lockedAmount;
                    uint256 overdueDuration = block.timestamp - user.lockEndTime - UNLOCK_FREE_DURATION;
                    if (overdueDuration > DURATION_FACTOR_OVERDUE) {
                        overdueDuration = DURATION_FACTOR_OVERDUE;
                    }
                    // Rates are calculated based on the user's overdue duration.
                    uint256 overdueWeight = (overdueDuration * overdueFee) / DURATION_FACTOR_OVERDUE;
                    uint256 currentOverdueFee = (earnAmount * overdueWeight) / PRECISION_FACTOR;
                    token.safeTransfer(treasury, currentOverdueFee);
                    currentAmount -= currentOverdueFee;
                }
                // Recalculate the user's share.
                uint256 pool = balanceOf();
                uint256 currentShares;
                if (totalShares != 0) {
                    currentShares = (currentAmount * totalShares) / (pool - currentAmount);
                } else {
                    currentShares = currentAmount;
                }
                user.shares = currentShares;
                totalShares += currentShares;
                // After the lock duration, update related parameters.
                if (user.lockEndTime < block.timestamp) {
                    user.locked = false;
                    user.lockStartTime = 0;
                    user.lockEndTime = 0;
                    totalLockedAmount -= user.lockedAmount;
                    user.lockedAmount = 0;
                    emit Unlock(_user, currentAmount, block.timestamp);
                }
            } else if (!freePerformanceFeeUsers[_user]) {
                // Calculate Performance fee.
                uint256 totalAmount = (user.shares * balanceOf()) / totalShares;
                totalShares -= user.shares;
                user.shares = 0;
                uint256 earnAmount = totalAmount - user.cakeAtLastUserAction;
                uint256 feeRate = performanceFee;
                if (_isContract(_user)) {
                    feeRate = performanceFeeContract;
                }
                uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
                if (currentPerformanceFee > 0) {
                    token.safeTransfer(treasury, currentPerformanceFee);
                    totalAmount -= currentPerformanceFee;
                }
                // Recalculate the user's share.
                uint256 pool = balanceOf();
                uint256 newShares;
                if (totalShares != 0) {
                    newShares = (totalAmount * totalShares) / (pool - totalAmount);
                } else {
                    newShares = totalAmount;
                }
                user.shares = newShares;
                totalShares += newShares;
            }
        }
    }

    /**
     * @notice Unlock user cake funds.
     * @dev Only possible when contract not paused.
     * @param _user: User address
     */
    function unlock(address _user) external onlyOperatorOrCakeOwner(_user) whenNotPaused {
        UserInfo storage user = userInfo[_user];
        require(user.locked && user.lockEndTime < block.timestamp, "Cannot unlock yet");
        depositOperation(0, 0, _user);
    }

    /**
     * @notice Deposit funds into the Cake Pool.
     * @dev Only possible when contract not paused.
     * @param _amount: number of tokens to deposit (in CAKE)
     * @param _lockDuration: Token lock duration
     */
    function deposit(uint256 _amount, uint256 _lockDuration) external whenNotPaused {
        require(_amount > 0 || _lockDuration > 0, "Nothing to deposit");
        depositOperation(_amount, _lockDuration, msg.sender);
    }

    /**
     * @notice The operation of deposite.
     * @param _amount: number of tokens to deposit (in CAKE)
     * @param _lockDuration: Token lock duration
     * @param _user: User address
     */
    function depositOperation(
        uint256 _amount,
        uint256 _lockDuration,
        address _user
    ) internal {
        UserInfo storage user = userInfo[_user];
        if (user.shares == 0 || _amount > 0) {
            require(_amount > MIN_DEPOSIT_AMOUNT, "Deposit amount must be greater than MIN_DEPOSIT_AMOUNT");
        }
        // Calculate the total lock duration and check whether the lock duration meets the conditions.
        uint256 totalLockDuration = _lockDuration;
        if (user.lockEndTime >= block.timestamp) {
            // Adding funds during the lock duration is equivalent to re-locking the position, needs to update some variables.
            if (_amount > 0) {
                user.lockStartTime = block.timestamp;
                totalLockedAmount -= user.lockedAmount;
                user.lockedAmount = 0;
            }
            totalLockDuration += user.lockEndTime - user.lockStartTime;
        }
        require(_lockDuration == 0 || totalLockDuration >= MIN_LOCK_DURATION, "Minimum lock period is one week");
        require(totalLockDuration <= MAX_LOCK_DURATION, "Maximum lock period exceeded");

        if (VCake != address(0)) {
            IVCake(VCake).deposit(_user, _amount, _lockDuration);
        }

        // Harvest tokens from Masterchef.
        harvest();

        // Handle stock funds.
        if (totalShares == 0) {
            uint256 stockAmount = available();
            token.safeTransfer(treasury, stockAmount);
        }
        // Update user share.
        updateUserShare(_user);

        // Update lock duration.
        if (_lockDuration > 0) {
            if (user.lockEndTime < block.timestamp) {
                user.lockStartTime = block.timestamp;
                user.lockEndTime = block.timestamp + _lockDuration;
            } else {
                user.lockEndTime += _lockDuration;
            }
            user.locked = true;
        }

        uint256 currentShares;
        uint256 currentAmount;
        uint256 userCurrentLockedBalance;
        uint256 pool = balanceOf();
        if (_amount > 0) {
            token.safeTransferFrom(_user, address(this), _amount);
            currentAmount = _amount;
        }

        // Calculate lock funds
        if (user.shares > 0 && user.locked) {
            userCurrentLockedBalance = (pool * user.shares) / totalShares;
            currentAmount += userCurrentLockedBalance;
            totalShares -= user.shares;
            user.shares = 0;

            // Update lock amount
            if (user.lockStartTime == block.timestamp) {
                user.lockedAmount = userCurrentLockedBalance;
                totalLockedAmount += user.lockedAmount;
            }
        }
        if (totalShares != 0) {
            currentShares = (currentAmount * totalShares) / (pool - userCurrentLockedBalance);
        } else {
            currentShares = currentAmount;
        }

        // Calculate the boost weight share.
        if (user.lockEndTime > user.lockStartTime) {
            // Calculate boost share.
            uint256 boostWeight = ((user.lockEndTime - user.lockStartTime) * BOOST_WEIGHT) / DURATION_FACTOR;
            uint256 boostShares = (boostWeight * currentShares) / PRECISION_FACTOR;
            currentShares += boostShares;
            user.shares += currentShares;

            // Calculate boost share , the user only enjoys the reward, so the principal needs to be recorded as a debt.
            uint256 userBoostedShare = (boostWeight * currentAmount) / PRECISION_FACTOR;
            user.userBoostedShare += userBoostedShare;
            totalBoostDebt += userBoostedShare;

            // Update lock amount.
            user.lockedAmount += _amount;
            totalLockedAmount += _amount;

            emit Lock(_user, user.lockedAmount, user.shares, (user.lockEndTime - user.lockStartTime), block.timestamp);
        } else {
            user.shares += currentShares;
        }

        if (_amount > 0 || _lockDuration > 0) {
            user.lastDepositedTime = block.timestamp;
        }
        totalShares += currentShares;

        user.cakeAtLastUserAction = (user.shares * balanceOf()) / totalShares - user.userBoostedShare;
        user.lastUserActionTime = block.timestamp;

        // Update user info in Boost Contract.
        updateBoostContractInfo(_user);

        emit Deposit(_user, _amount, currentShares, _lockDuration, block.timestamp);
    }

    /**
     * @notice Withdraw funds from the Cake Pool.
     * @param _amount: Number of amount to withdraw
     */
    function withdrawByAmount(uint256 _amount) public whenNotPaused {
        require(_amount > MIN_WITHDRAW_AMOUNT, "Withdraw amount must be greater than MIN_WITHDRAW_AMOUNT");
        withdrawOperation(0, _amount);
    }

    /**
     * @notice Withdraw funds from the Cake Pool.
     * @param _shares: Number of shares to withdraw
     */
    function withdraw(uint256 _shares) public whenNotPaused {
        require(_shares > 0, "Nothing to withdraw");
        withdrawOperation(_shares, 0);
    }

    /**
     * @notice The operation of withdraw.
     * @param _shares: Number of shares to withdraw
     * @param _amount: Number of amount to withdraw
     */
    function withdrawOperation(uint256 _shares, uint256 _amount) internal {
        UserInfo storage user = userInfo[msg.sender];
        require(_shares <= user.shares, "Withdraw amount exceeds balance");
        require(user.lockEndTime < block.timestamp, "Still in lock");

        if (VCake != address(0)) {
            IVCake(VCake).withdraw(msg.sender);
        }

        // Calculate the percent of withdraw shares, when unlocking or calculating the Performance fee, the shares will be updated.
        uint256 currentShare = _shares;
        uint256 sharesPercent = (_shares * PRECISION_FACTOR_SHARE) / user.shares;

        // Harvest token from MasterchefV2.
        harvest();

        // Update user share.
        updateUserShare(msg.sender);

        if (_shares == 0 && _amount > 0) {
            uint256 pool = balanceOf();
            currentShare = (_amount * totalShares) / pool;
            // Calculate equivalent shares
            if (currentShare > user.shares) {
                currentShare = user.shares;
            }
        } else {
            currentShare = (sharesPercent * user.shares) / PRECISION_FACTOR_SHARE;
        }
        uint256 currentAmount = (balanceOf() * currentShare) / totalShares;
        user.shares -= currentShare;
        totalShares -= currentShare;

        // Calculate withdraw fee
        if (!freeWithdrawFeeUsers[msg.sender] && (block.timestamp < user.lastDepositedTime + withdrawFeePeriod)) {
            uint256 feeRate = withdrawFee;
            if (_isContract(msg.sender)) {
                feeRate = withdrawFeeContract;
            }
            uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
            token.safeTransfer(treasury, currentWithdrawFee);
            currentAmount -= currentWithdrawFee;
        }

        token.safeTransfer(msg.sender, currentAmount);

        if (user.shares > 0) {
            user.cakeAtLastUserAction = (user.shares * balanceOf()) / totalShares;
        } else {
            user.cakeAtLastUserAction = 0;
        }

        user.lastUserActionTime = block.timestamp;

        // Update user info in Boost Contract.
        updateBoostContractInfo(msg.sender);

        emit Withdraw(msg.sender, currentAmount, currentShare);
    }

    /**
     * @notice Withdraw all funds for a user
     */
    function withdrawAll() external {
        withdraw(userInfo[msg.sender].shares);
    }

    /**
     * @notice Harvest pending CAKE tokens from MasterChef
     */
    function harvest() internal {
        uint256 pendingCake = masterchefV2.pendingCake(cakePoolPID, address(this));
        if (pendingCake > 0) {
            uint256 balBefore = available();
            masterchefV2.withdraw(cakePoolPID, 0);
            uint256 balAfter = available();
            emit Harvest(msg.sender, (balAfter - balBefore));
        }
    }

    /**
     * @notice Set admin address
     * @dev Only callable by the contract owner.
     */
    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Cannot be zero address");
        admin = _admin;
        emit NewAdmin(admin);
    }

    /**
     * @notice Set treasury address
     * @dev Only callable by the contract owner.
     */
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be zero address");
        treasury = _treasury;
        emit NewTreasury(treasury);
    }

    /**
     * @notice Set operator address
     * @dev Callable by the contract owner.
     */
    function setOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Cannot be zero address");
        operator = _operator;
        emit NewOperator(operator);
    }

    /**
     * @notice Set Boost Contract address
     * @dev Callable by the contract admin.
     */
    function setBoostContract(address _boostContract) external onlyAdmin {
        require(_boostContract != address(0), "Cannot be zero address");
        boostContract = _boostContract;
        emit NewBoostContract(boostContract);
    }

    /**
     * @notice Set VCake Contract address
     * @dev Callable by the contract admin.
     */
    function setVCakeContract(address _VCake) external onlyAdmin {
        require(_VCake != address(0), "Cannot be zero address");
        VCake = _VCake;
        emit NewVCakeContract(VCake);
    }

    /**
     * @notice Set free performance fee address
     * @dev Only callable by the contract admin.
     * @param _user: User address
     * @param _free: true:free false:not free
     */
    function setFreePerformanceFeeUser(address _user, bool _free) external onlyAdmin {
        require(_user != address(0), "Cannot be zero address");
        freePerformanceFeeUsers[_user] = _free;
        emit FreeFeeUser(_user, _free);
    }

    /**
     * @notice Set free overdue fee address
     * @dev Only callable by the contract admin.
     * @param _user: User address
     * @param _free: true:free false:not free
     */
    function setOverdueFeeUser(address _user, bool _free) external onlyAdmin {
        require(_user != address(0), "Cannot be zero address");
        freeOverdueFeeUsers[_user] = _free;
        emit FreeFeeUser(_user, _free);
    }

    /**
     * @notice Set free withdraw fee address
     * @dev Only callable by the contract admin.
     * @param _user: User address
     * @param _free: true:free false:not free
     */
    function setWithdrawFeeUser(address _user, bool _free) external onlyAdmin {
        require(_user != address(0), "Cannot be zero address");
        freeWithdrawFeeUsers[_user] = _free;
        emit FreeFeeUser(_user, _free);
    }

    /**
     * @notice Set performance fee
     * @dev Only callable by the contract admin.
     */
    function setPerformanceFee(uint256 _performanceFee) external onlyAdmin {
        require(_performanceFee <= MAX_PERFORMANCE_FEE, "performanceFee cannot be more than MAX_PERFORMANCE_FEE");
        performanceFee = _performanceFee;
        emit NewPerformanceFee(performanceFee);
    }

    /**
     * @notice Set performance fee for contract
     * @dev Only callable by the contract admin.
     */
    function setPerformanceFeeContract(uint256 _performanceFeeContract) external onlyAdmin {
        require(
            _performanceFeeContract <= MAX_PERFORMANCE_FEE,
            "performanceFee cannot be more than MAX_PERFORMANCE_FEE"
        );
        performanceFeeContract = _performanceFeeContract;
        emit NewPerformanceFeeContract(performanceFeeContract);
    }

    /**
     * @notice Set withdraw fee
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFee(uint256 _withdrawFee) external onlyAdmin {
        require(_withdrawFee <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFee = _withdrawFee;
        emit NewWithdrawFee(withdrawFee);
    }

    /**
     * @notice Set overdue fee
     * @dev Only callable by the contract admin.
     */
    function setOverdueFee(uint256 _overdueFee) external onlyAdmin {
        require(_overdueFee <= MAX_OVERDUE_FEE, "overdueFee cannot be more than MAX_OVERDUE_FEE");
        overdueFee = _overdueFee;
        emit NewOverdueFee(_overdueFee);
    }

    /**
     * @notice Set withdraw fee for contract
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFeeContract(uint256 _withdrawFeeContract) external onlyAdmin {
        require(_withdrawFeeContract <= MAX_WITHDRAW_FEE, "withdrawFee cannot be more than MAX_WITHDRAW_FEE");
        withdrawFeeContract = _withdrawFeeContract;
        emit NewWithdrawFeeContract(withdrawFeeContract);
    }

    /**
     * @notice Set withdraw fee period
     * @dev Only callable by the contract admin.
     */
    function setWithdrawFeePeriod(uint256 _withdrawFeePeriod) external onlyAdmin {
        require(
            _withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            "withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
        );
        withdrawFeePeriod = _withdrawFeePeriod;
        emit NewWithdrawFeePeriod(withdrawFeePeriod);
    }

    /**
     * @notice Set MAX_LOCK_DURATION
     * @dev Only callable by the contract admin.
     */
    function setMaxLockDuration(uint256 _maxLockDuration) external onlyAdmin {
        require(
            _maxLockDuration <= MAX_LOCK_DURATION_LIMIT,
            "MAX_LOCK_DURATION cannot be more than MAX_LOCK_DURATION_LIMIT"
        );
        MAX_LOCK_DURATION = _maxLockDuration;
        emit NewMaxLockDuration(_maxLockDuration);
    }

    /**
     * @notice Set DURATION_FACTOR
     * @dev Only callable by the contract admin.
     */
    function setDurationFactor(uint256 _durationFactor) external onlyAdmin {
        require(_durationFactor > 0, "DURATION_FACTOR cannot be zero");
        DURATION_FACTOR = _durationFactor;
        emit NewDurationFactor(_durationFactor);
    }

    /**
     * @notice Set DURATION_FACTOR_OVERDUE
     * @dev Only callable by the contract admin.
     */
    function setDurationFactorOverdue(uint256 _durationFactorOverdue) external onlyAdmin {
        require(_durationFactorOverdue > 0, "DURATION_FACTOR_OVERDUE cannot be zero");
        DURATION_FACTOR_OVERDUE = _durationFactorOverdue;
        emit NewDurationFactorOverdue(_durationFactorOverdue);
    }

    /**
     * @notice Set UNLOCK_FREE_DURATION
     * @dev Only callable by the contract admin.
     */
    function setUnlockFreeDuration(uint256 _unlockFreeDuration) external onlyAdmin {
        require(_unlockFreeDuration > 0, "UNLOCK_FREE_DURATION cannot be zero");
        UNLOCK_FREE_DURATION = _unlockFreeDuration;
        emit NewUnlockFreeDuration(_unlockFreeDuration);
    }

    /**
     * @notice Set BOOST_WEIGHT
     * @dev Only callable by the contract admin.
     */
    function setBoostWeight(uint256 _boostWeight) external onlyAdmin {
        require(_boostWeight <= BOOST_WEIGHT_LIMIT, "BOOST_WEIGHT cannot be more than BOOST_WEIGHT_LIMIT");
        BOOST_WEIGHT = _boostWeight;
        emit NewBoostWeight(_boostWeight);
    }

    /**
     * @notice Withdraw unexpected tokens sent to the Cake Pool
     */
    function inCaseTokensGetStuck(address _token) external onlyAdmin {
        require(_token != address(token), "Token cannot be same as deposit token");

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Trigger stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyAdmin whenNotPaused {
        _pause();
        emit Pause();
    }

    /**
     * @notice Return to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyAdmin whenPaused {
        _unpause();
        emit Unpause();
    }

    /**
     * @notice Calculate Performance fee.
     * @param _user: User address
     * @return Returns Performance fee.
     */
    function calculatePerformanceFee(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (user.shares > 0 && !user.locked && !freePerformanceFeeUsers[_user]) {
            uint256 pool = balanceOf() + calculateTotalPendingCakeRewards();
            uint256 totalAmount = (user.shares * pool) / totalShares;
            uint256 earnAmount = totalAmount - user.cakeAtLastUserAction;
            uint256 feeRate = performanceFee;
            if (_isContract(_user)) {
                feeRate = performanceFeeContract;
            }
            uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
            return currentPerformanceFee;
        }
        return 0;
    }

    /**
     * @notice Calculate overdue fee.
     * @param _user: User address
     * @return Returns Overdue fee.
     */
    function calculateOverdueFee(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (
            user.shares > 0 &&
            user.locked &&
            !freeOverdueFeeUsers[_user] &&
            ((user.lockEndTime + UNLOCK_FREE_DURATION) < block.timestamp)
        ) {
            uint256 pool = balanceOf() + calculateTotalPendingCakeRewards();
            uint256 currentAmount = (pool * (user.shares)) / totalShares - user.userBoostedShare;
            uint256 earnAmount = currentAmount - user.lockedAmount;
            uint256 overdueDuration = block.timestamp - user.lockEndTime - UNLOCK_FREE_DURATION;
            if (overdueDuration > DURATION_FACTOR_OVERDUE) {
                overdueDuration = DURATION_FACTOR_OVERDUE;
            }
            // Rates are calculated based on the user's overdue duration.
            uint256 overdueWeight = (overdueDuration * overdueFee) / DURATION_FACTOR_OVERDUE;
            uint256 currentOverdueFee = (earnAmount * overdueWeight) / PRECISION_FACTOR;
            return currentOverdueFee;
        }
        return 0;
    }

    /**
     * @notice Calculate Performance Fee Or Overdue Fee
     * @param _user: User address
     * @return Returns  Performance Fee Or Overdue Fee.
     */
    function calculatePerformanceFeeOrOverdueFee(address _user) internal view returns (uint256) {
        return calculatePerformanceFee(_user) + calculateOverdueFee(_user);
    }

    /**
     * @notice Calculate withdraw fee.
     * @param _user: User address
     * @param _shares: Number of shares to withdraw
     * @return Returns Withdraw fee.
     */
    function calculateWithdrawFee(address _user, uint256 _shares) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (user.shares < _shares) {
            _shares = user.shares;
        }
        if (!freeWithdrawFeeUsers[msg.sender] && (block.timestamp < user.lastDepositedTime + withdrawFeePeriod)) {
            uint256 pool = balanceOf() + calculateTotalPendingCakeRewards();
            uint256 sharesPercent = (_shares * PRECISION_FACTOR) / user.shares;
            uint256 currentTotalAmount = (pool * (user.shares)) /
                totalShares -
                user.userBoostedShare -
                calculatePerformanceFeeOrOverdueFee(_user);
            uint256 currentAmount = (currentTotalAmount * sharesPercent) / PRECISION_FACTOR;
            uint256 feeRate = withdrawFee;
            if (_isContract(msg.sender)) {
                feeRate = withdrawFeeContract;
            }
            uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
            return currentWithdrawFee;
        }
        return 0;
    }

    /**
     * @notice Calculates the total pending rewards that can be harvested
     * @return Returns total pending cake rewards
     */
    function calculateTotalPendingCakeRewards() public view returns (uint256) {
        uint256 amount = masterchefV2.pendingCake(cakePoolPID, address(this));
        return amount;
    }

    function getPricePerFullShare() external view returns (uint256) {
        return totalShares == 0 ? 1e18 : (((balanceOf() + calculateTotalPendingCakeRewards()) * (1e18)) / totalShares);
    }

    /**
     * @notice Current pool available balance
     * @dev The contract puts 100% of the tokens to work.
     */
    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @notice Calculates the total underlying tokens
     * @dev It includes tokens held by the contract and the boost debt amount.
     */
    function balanceOf() public view returns (uint256) {
        return token.balanceOf(address(this)) + totalBoostDebt;
    }

    /**
     * @notice Checks if address is a contract
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
// copy from https://bscscan.com/address/0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652#code#F1#L1

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./SafeBEP20.sol";
import "./IBEP20.sol";

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BondToken is ERC20, Ownable {
    address public minter;

    modifier onlyMinter() {
        require(minter == msg.sender, "Minter only");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address minter_
    ) ERC20(name_, symbol_) Ownable() {
        minter = minter_;
    }

    function setMinter(address minter_) public onlyOwner {
        require(minter_ != address(0), "Cant set minter to zero address");
        minter = minter_;
    }

    function mint(address to_, uint256 amount_) external onlyMinter {
        require(amount_ > 0, "Nothing to mint");
        _mint(to_, amount_);
    }

    function burnFrom(address account_, uint256 amount_) external onlyMinter {
        require(amount_ > 0, "Nothing to burn");
        _burn(account_, amount_);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IBondFarmingPool {
    function stake(uint256 amount_) external;

    function stakeForUser(address user_, uint256 amount_) external;

    function updatePool() external;

    function totalPendingRewards() external view returns (uint256);

    function lastUpdatedPoolAt() external view returns (uint256);

    function setSiblingPool(IBondFarmingPool siblingPool_) external;

    function siblingPool() external view returns (IBondFarmingPool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IExtendableBond {
    function totalPendingRewards() external view returns (uint256);

    function mintBondTokenForRewards(address to_, uint256 amount_) external returns (uint256);

    function calculateFeeAmount(uint256 amount_) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IBondTokenUpgradeable is IERC20Upgradeable {
    function mint(address to_, uint256 amount_) external;

    function burnFrom(address account_, uint256 amount_) external;
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

abstract contract Keepable {
    event KeeperUpdated(address indexed user, address indexed newKeeper);

    address public keeper;

    modifier onlyKeeper() virtual {
        require(msg.sender == keeper, "UNAUTHORIZED");

        _;
    }

    function _setKeeper(address newKeeper_) internal {
        keeper = newKeeper_;

        emit KeeperUpdated(msg.sender, newKeeper_);
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IPancakeMasterChefV2 {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


import "./ExtendableBond.sol";
import "./libs/DuetMath.sol";
import "./libs/Adminable.sol";
import "./interfaces/IMultiRewardsMasterChef.sol";
import "./interfaces/IBondFarmingPool.sol";
import "./interfaces/IExtendableBond.sol";

contract BondLPFarmingPool is ReentrancyGuardUpgradeable, PausableUpgradeable, Adminable, IBondFarmingPool {
    IERC20Upgradeable public bondToken;
    IERC20Upgradeable public lpToken;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IExtendableBond public bond;

    IBondFarmingPool public siblingPool;
    uint256 public lastUpdatedPoolAt = 0;

    IMultiRewardsMasterChef public masterChef;

    uint256 public masterChefPid;

    /**
     * @dev accumulated bond token rewards of each lp token.
     */
    uint256 public accRewardPerShare;

    uint256 public constant ACC_REWARDS_PRECISION = 1e12;

    uint256 public totalLpAmount;
    /**
     * @notice mark bond reward is suspended. If the LP Token needs to be migrated, such as from pancake to ESP, the bond rewards will be suspended.
     * @notice you can not stake anymore when bond rewards has been suspended.
     * @dev _updatePools() no longer works after bondRewardsSuspended is true.
     */
    bool public bondRewardsSuspended = false;

    struct UserInfo {
        /**
         * @dev lp amount deposited by user.
         */
        uint256 lpAmount;
        /**
         * @dev like sushi rewardDebt
         */
        uint256 rewardDebt;
        /**
         * @dev Rewards credited to rewardDebt but not yet claimed
         */
        uint256 pendingRewards;
        /**
         * @dev claimed rewards. for 'earned to date' calculation.
         */
        uint256 claimedRewards;
    }

    mapping(address => UserInfo) public usersInfo;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event SiblingPoolUpdated(address indexed previousPool, address indexed newPool);

    function initialize(
        IERC20Upgradeable bondToken_,
        IExtendableBond bond_,
        address admin_
    ) public initializer {
        __ReentrancyGuard_init();
        __Pausable_init();
        _setAdmin(admin_);
        bondToken = bondToken_;
        bond = bond_;
    }

    function setLpToken(IERC20Upgradeable lpToken_) public onlyAdmin {
        lpToken = lpToken_;
    }

    function setMasterChef(IMultiRewardsMasterChef masterChef_, uint256 masterChefPid_) public onlyAdmin {
        masterChef = masterChef_;
        masterChefPid = masterChefPid_;
    }

    /**
     * @dev see: _updatePool
     */
    function updatePool() external {
        require(
            msg.sender == address(siblingPool) || msg.sender == address(bond),
            "BondLPFarmingPool: Calling from sibling pool or bond only"
        );
        _updatePool();
    }

    /**
     * @dev allocate pending rewards.
     */
    function _updatePool() internal {
        // Single bond token farming rewards base on  'bond token mount in pool' / 'total bond token supply' * 'total underlying rewards' and remaining rewards for LP pools.
        // So single bond farming pool should be updated before LP's.
        require(
            siblingPool.lastUpdatedPoolAt() > lastUpdatedPoolAt ||
                (siblingPool.lastUpdatedPoolAt() == lastUpdatedPoolAt && lastUpdatedPoolAt == block.number),
            "update bond pool firstly."
        );
        uint256 pendingRewards = totalPendingRewards();
        lastUpdatedPoolAt = block.number;
        _harvestRemote();
        // no rewards will be distributed to the LP Pool when it's empty.
        // In this case, the single bond farming pool still distributes its rewards proportionally,
        // but its rewards will be expanded every time the pools are updated.
        // Because the remaining rewards is not distributed to the LP pool
        // The first user (start with totalLpAmount = 0) to enter the LP pool will receive this part of the undistributed rewards.
        // But this case is very rare and usually doesn't last long.
        if (pendingRewards <= 0 || totalLpAmount <= 0) {
            return;
        }
        uint256 feeAmount = bond.mintBondTokenForRewards(address(this), pendingRewards);
        accRewardPerShare += ((pendingRewards - feeAmount) * ACC_REWARDS_PRECISION) / totalLpAmount;
    }

    /**
     * @dev distribute single bond pool first, then LP pool will get the remaining rewards. see _updatePools
     */
    function totalPendingRewards() public view virtual returns (uint256) {
        if (bondRewardsSuspended) {
            return 0;
        }
        uint256 totalBondPendingRewards = bond.totalPendingRewards();
        if (totalBondPendingRewards <= 0) {
            return 0;
        }
        return totalBondPendingRewards - siblingPool.totalPendingRewards();
    }

    /**
     * @dev get pending rewards by specific user
     */
    function getUserPendingRewards(address user_) public view virtual returns (uint256) {
        UserInfo storage userInfo = usersInfo[user_];
        if (totalLpAmount <= 0 || userInfo.lpAmount <= 0) {
            return 0;
        }
        uint256 totalPendingRewards = totalPendingRewards();
        uint256 latestAccRewardPerShare = ((totalPendingRewards - bond.calculateFeeAmount(totalPendingRewards)) *
            ACC_REWARDS_PRECISION) /
            totalLpAmount +
            accRewardPerShare;
        return
            (latestAccRewardPerShare * userInfo.lpAmount) /
            ACC_REWARDS_PRECISION +
            userInfo.pendingRewards -
            userInfo.rewardDebt;
    }

    function setSiblingPool(IBondFarmingPool siblingPool_) public onlyAdmin {
        require(
            (address(siblingPool_.siblingPool()) == address(0) ||
                address(siblingPool_.siblingPool()) == address(this)) && (address(siblingPool_) != address(this)),
            "Invalid sibling"
        );
        emit SiblingPoolUpdated(address(siblingPool), address(siblingPool_));
        siblingPool = siblingPool_;
    }

    function stake(uint256 amount_) public whenNotPaused {
        require(!bondRewardsSuspended, "Reward suspended. Please follow the project announcement ");
        address user = msg.sender;
        stakeForUser(user, amount_);
    }

    function _updatePools() internal {
        if (bondRewardsSuspended) {
            return;
        }
        siblingPool.updatePool();
        _updatePool();
    }

    function _stakeRemote(address user_, uint256 amount_) internal virtual {}

    function _unstakeRemote(address user_, uint256 amount_) internal virtual {}

    function _harvestRemote() internal virtual {}

    function stakeForUser(address user_, uint256 amount_) public whenNotPaused nonReentrant {
        require(amount_ > 0, "nothing to stake");
        // allocate pending rewards of all sibling pools to correct reward ratio between them.
        _updatePools();
        UserInfo storage userInfo = usersInfo[user_];
        if (userInfo.lpAmount > 0) {
            uint256 sharesReward = (accRewardPerShare * userInfo.lpAmount) / ACC_REWARDS_PRECISION;



            userInfo.pendingRewards += sharesReward - userInfo.rewardDebt;

            userInfo.rewardDebt = (accRewardPerShare * (userInfo.lpAmount + amount_)) / ACC_REWARDS_PRECISION;
        } else {
            userInfo.rewardDebt = (accRewardPerShare * amount_) / ACC_REWARDS_PRECISION;
        }
        lpToken.safeTransferFrom(msg.sender, address(this), amount_);
        _stakeRemote(user_, amount_);
        userInfo.lpAmount += amount_;
        totalLpAmount += amount_;
        masterChef.depositForUser(masterChefPid, amount_, user_);
        emit Staked(user_, amount_);
    }

    /**
     * @notice unstake by shares
     */
    function unstake(uint256 amount_) public whenNotPaused nonReentrant {
        address user = msg.sender;
        UserInfo storage userInfo = usersInfo[user];
        require(userInfo.lpAmount >= amount_ && userInfo.lpAmount > 0, "unstake amount exceeds owned amount");

        // allocate pending rewards of all sibling pools to correct reward ratio between them.
        _updatePools();

        uint256 sharesReward = (accRewardPerShare * userInfo.lpAmount) / ACC_REWARDS_PRECISION;

        uint256 pendingRewards = userInfo.pendingRewards + sharesReward - userInfo.rewardDebt;
        uint256 bondBalance = bondToken.balanceOf(address(this));
        if (pendingRewards > bondBalance) {
            pendingRewards = bondBalance;
        }
        userInfo.rewardDebt = sharesReward;
        userInfo.pendingRewards = 0;


        _unstakeRemote(user, amount_);
        if (amount_ > 0) {
            userInfo.rewardDebt = (accRewardPerShare * (userInfo.lpAmount - amount_)) / ACC_REWARDS_PRECISION;
            userInfo.lpAmount -= amount_;
            totalLpAmount -= amount_;
            // send staked assets
            lpToken.safeTransfer(user, amount_);
        }

        if (pendingRewards > 0) {
            // send rewards
            bondToken.safeTransfer(user, pendingRewards);
        }
        userInfo.claimedRewards += pendingRewards;
        masterChef.withdrawForUser(masterChefPid, amount_, user);

        emit Unstaked(user, amount_);
    }

    function unstakeAll() public {
        require(usersInfo[msg.sender].lpAmount > 0, "nothing to unstake");
        unstake(usersInfo[msg.sender].lpAmount);
    }

    function setBondRewardsSuspended(bool suspended_) public onlyAdmin {
        _updatePools();
        bondRewardsSuspended = suspended_;
    }

    function claimBonuses() public {
        unstake(0);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

library DuetMath {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0;
            // Least significant 256 bits of the product
            uint256 prod1;
            // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                require(denominator > 0);
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = denominator**3;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse;
            // inverse mod 2^8
            inverse *= 2 - denominator * inverse;
            // inverse mod 2^16
            inverse *= 2 - denominator * inverse;
            // inverse mod 2^32
            inverse *= 2 - denominator * inverse;
            // inverse mod 2^64
            inverse *= 2 - denominator * inverse;
            // inverse mod 2^128
            inverse *= 2 - denominator * inverse;
            // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding direction
    ) public pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (direction == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

interface IMultiRewardsMasterChef {
    function depositForUser(
        uint256 _pid,
        uint256 _amount,
        address user_
    ) external;

    function withdrawForUser(
        uint256 _pid,
        uint256 _amount,
        address user_
    ) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/IMultiRewardsMasterChef.sol";

interface IMigratorChef {
    function migrate(IERC20 token) external returns (IERC20);
}

// MasterChef is the master of RewardToken. He can make RewardToken and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once RewardToken is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MultiRewardsMasterChef is ReentrancyGuard, Initializable, IMultiRewardsMasterChef {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public admin;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        /**
         * @dev claimed rewards mapping.  reward id => claimed rewards since to last claimed
         */
        mapping(uint256 => uint256) claimedRewards;
        /**
         * @dev rewardDebt mapping. reward id => reward debt of the reward.
         */
        mapping(uint256 => uint256) rewardDebt; // Reward debt in each reward. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of rewards
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * poolsRewardsAccRewardsPerShare[pid][rewardId]) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accCakePerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. rewards to distribute per block.
        uint256 lastRewardBlock; // Last block number that rewards distribution occurs.
        /**
         * Pool with a proxyFarmer means no lpToken transfer (including withdraw and deposit).
         */
        address proxyFarmer;
        /**
         * total deposited amount.
         */
        uint256 totalAmount;
    }

    struct RewardInfo {
        IERC20 token;
        uint256 amount;
    }

    /**
     * Info of each reward.
     */
    struct RewardSpec {
        IERC20 token;
        uint256 rewardPerBlock;
        uint256 startedAtBlock;
        uint256 endedAtBlock;
        uint256 claimedAmount;
    }

    RewardSpec[] public rewardSpecs;

    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // pool => rewardId => accRewardsPerShare
    mapping(uint256 => mapping(uint256 => uint256)) public poolsRewardsAccRewardsPerShare; // Accumulated rewards per share in each reward spec, times 1e12. See below.
    // pool => userAddress => UserInfo; Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event ClaimRewards(address indexed user, uint256 indexed pid);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    event PoolAdded(uint256 indexed pid, address indexed lpToken, address indexed proxyFarmer, uint256 allocPoint);
    event PoolUpdated(uint256 indexed pid, uint256 allocPoint);
    event RewardSpecAdded(
        uint256 indexed rewardId,
        address indexed rewardToken,
        uint256 rewardPerBlock,
        uint256 startedAtBlock,
        uint256 endedAtBlock
    );
    event RewardSpecUpdated(
        uint256 indexed rewardId,
        uint256 rewardPerBlock,
        uint256 startedAtBlock,
        uint256 endedAtBlock
    );

    /**
     * @notice Checks if the msg.sender is the admin address.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    function initialize(address admin_) public initializer {
        admin = admin_;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do. except as proxied farmer
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        address _proxyFarmer,
        bool _withUpdate
    ) public onlyAdmin returns (uint256 pid) {
        if (_withUpdate) {
            massUpdatePools();
        }
        if (_proxyFarmer != address(0)) {
            require(address(_lpToken) == address(0), "LPToken should be address 0 when proxied farmer.");
        }
        uint256 lastRewardBlock = block.number;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                proxyFarmer: _proxyFarmer,
                totalAmount: 0
            })
        );
        uint256 pid = poolInfo.length - 1;
        emit PoolAdded(pid, address(_lpToken), _proxyFarmer, _allocPoint);
        return pid;
    }

    // Update the given pool's RewardToken allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyAdmin {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }

        emit PoolUpdated(_pid, _allocPoint);
    }

    function addRewardSpec(
        IERC20 token,
        uint256 rewardPerBlock,
        uint256 startedAtBlock,
        uint256 endedAtBlock
    ) public onlyAdmin returns (uint256 rewardId) {
        require(endedAtBlock > startedAtBlock, "endedAtBlock should be greater than startedAtBlock");
        require(rewardPerBlock > 0, "rewardPerBlock should be greater than zero");

        token.safeTransferFrom(msg.sender, address(this), (endedAtBlock - startedAtBlock) * rewardPerBlock);

        rewardSpecs.push(
            RewardSpec({
                token: token,
                rewardPerBlock: rewardPerBlock,
                startedAtBlock: startedAtBlock,
                endedAtBlock: endedAtBlock,
                claimedAmount: 0
            })
        );
        uint256 rewardId = rewardSpecs.length - 1;
        emit RewardSpecAdded(rewardId, address(token), rewardPerBlock, startedAtBlock, endedAtBlock);
        return rewardId;
    }

    function setRewardSpec(
        uint256 rewardId,
        uint256 rewardPerBlock,
        uint256 startedAtBlock,
        uint256 endedAtBlock
    ) public onlyAdmin {
        (uint256 depositAmount, uint256 refundAmount) = previewSetRewardSpec(
            rewardId,
            rewardPerBlock,
            startedAtBlock,
            endedAtBlock
        );
        require(depositAmount == 0 || refundAmount == 0, "One of depositAmount and refundAmount must be 0");
        massUpdatePools();
        RewardSpec storage rewardSpec = rewardSpecs[rewardId];
        if (depositAmount > 0) {
            rewardSpec.token.safeTransferFrom(msg.sender, address(this), depositAmount);
        } else if (refundAmount > 0) {
            rewardSpec.token.safeTransfer(msg.sender, refundAmount);
        }

        rewardSpec.startedAtBlock = startedAtBlock;
        rewardSpec.endedAtBlock = endedAtBlock;
        rewardSpec.rewardPerBlock = rewardPerBlock;

        emit RewardSpecUpdated(rewardId, rewardPerBlock, startedAtBlock, endedAtBlock);
    }

    function previewSetRewardSpec(
        uint256 rewardId,
        uint256 rewardPerBlock,
        uint256 startedAtBlock,
        uint256 endedAtBlock
    ) public view returns (uint256 depositAmount, uint256 refundAmount) {
        RewardSpec storage rewardSpec = rewardSpecs[rewardId];

        if (rewardSpec.startedAtBlock <= block.number) {
            require(
                startedAtBlock == rewardSpec.startedAtBlock,
                "can not modify startedAtBlock after rewards has began allocating"
            );
        }

        require(endedAtBlock > block.number, "can not modify endedAtBlock to a past block number");
        require(endedAtBlock > startedAtBlock, "endedAtBlock should be greater than startedAtBlock");
        uint256 minedAwards = block.number > rewardSpec.startedAtBlock
            ? (block.number - rewardSpec.startedAtBlock) * rewardSpec.rewardPerBlock
            : 0;
        uint256 tokenBalance = rewardSpec.token.balanceOf(address(this));
        int256 amountDebt = int256(minedAwards) - int256(rewardSpec.claimedAmount);
        int256 usableBalance = int256(tokenBalance) - amountDebt;
        uint256 requiredAmount = (endedAtBlock - block.number) * rewardPerBlock;

        if (int256(requiredAmount) > usableBalance) {
            depositAmount = uint256(int256(requiredAmount) - usableBalance);
        } else if (int256(requiredAmount) < usableBalance) {
            refundAmount = uint256(usableBalance - int256(requiredAmount));
        }
        return (depositAmount, refundAmount);
    }

    function getRewardSpecsLength() public view returns (uint256) {
        return rewardSpecs.length;
    }

    function getUserClaimedRewards(
        uint256 pid_,
        address user_,
        uint256 rewardId_
    ) public view returns (uint256) {
        return userInfo[pid_][user_].claimedRewards[rewardId_];
    }

    function getUserAmount(uint256 pid_, address user_) public view returns (uint256) {
        return userInfo[pid_][user_].amount;
    }

    function getUserRewardDebt(
        uint256 pid_,
        address user_,
        uint256 rewardId_
    ) public view returns (uint256) {
        return userInfo[pid_][user_].rewardDebt[rewardId_];
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyAdmin {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract.
    function migrate(uint256 _pid) public onlyAdmin {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(
        uint256 _from,
        uint256 _to,
        uint256 rewardId
    ) public view returns (uint256) {
        RewardSpec storage rewardSpec = rewardSpecs[rewardId];
        if (_to < rewardSpec.startedAtBlock) {
            return 0;
        }
        if (_from < rewardSpec.startedAtBlock) {
            _from = rewardSpec.startedAtBlock;
        }
        if (_to > rewardSpec.endedAtBlock) {
            _to = rewardSpec.endedAtBlock;
        }
        if (_from > _to) {
            return 0;
        }
        return _to.sub(_from);
    }

    // View function to see pending CAKEs on frontend.
    function pendingRewards(uint256 _pid, address _user) external view returns (RewardInfo[] memory) {
        RewardInfo[] memory rewardsInfo = new RewardInfo[](rewardSpecs.length);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        for (uint256 rewardId = 0; rewardId < rewardSpecs.length; rewardId++) {
            RewardSpec storage rewardSpec = rewardSpecs[rewardId];

            if (block.number < rewardSpec.startedAtBlock) {
                rewardsInfo[rewardId] = RewardInfo({ token: rewardSpec.token, amount: 0 });
                continue;
            }

            uint256 accRewardPerShare = poolsRewardsAccRewardsPerShare[_pid][rewardId];

            uint256 lpSupply = pool.totalAmount;

            if (block.number > pool.lastRewardBlock && lpSupply != 0) {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, rewardId);
                uint256 rewardAmount = multiplier.mul(rewardSpec.rewardPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
                accRewardPerShare = accRewardPerShare.add(rewardAmount.mul(1e12).div(lpSupply));
            }
            rewardsInfo[rewardId] = RewardInfo({
                token: rewardSpec.token,
                amount: user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt[rewardId])
            });
        }

        return rewardsInfo;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.totalAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        for (uint256 rewardId; rewardId < rewardSpecs.length; rewardId++) {
            RewardSpec storage rewardSpec = rewardSpecs[rewardId];

            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, rewardId);
            uint256 reward = multiplier.mul(rewardSpec.rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            poolsRewardsAccRewardsPerShare[_pid][rewardId] = poolsRewardsAccRewardsPerShare[_pid][rewardId].add(
                reward.mul(1e12).div(lpSupply)
            );
        }
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        _depositOperation(_pid, _amount, msg.sender);
    }

    function depositForUser(
        uint256 _pid,
        uint256 _amount,
        address user_
    ) public {
        _depositOperation(_pid, _amount, user_);
    }

    // Deposit LP tokens to MasterChef for RewardToken allocation.
    function _depositOperation(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) internal nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.proxyFarmer != address(0)) {
            require(msg.sender == pool.proxyFarmer, "Only proxy farmer");
        } else {
            require(msg.sender == _user, "Can not deposit for others");
        }

        UserInfo storage user = userInfo[_pid][_user];
        updatePool(_pid);
        for (uint256 rewardId = 0; rewardId < rewardSpecs.length; rewardId++) {
            RewardSpec storage rewardSpec = rewardSpecs[rewardId];
            uint256 accRewardPerShare = poolsRewardsAccRewardsPerShare[_pid][rewardId];
            if (user.amount > 0) {
                uint256 pending = user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt[rewardId]);
                if (pending > 0) {
                    rewardSpec.claimedAmount += pending;
                    user.claimedRewards[rewardId] += pending;
                    rewardSpec.token.safeTransfer(_user, pending);
                }
            }

            user.rewardDebt[rewardId] = user.amount.add(_amount).mul(accRewardPerShare).div(1e12);
        }
        if (_amount > 0) {
            if (pool.proxyFarmer == address(0)) {
                pool.lpToken.safeTransferFrom(address(_user), address(this), _amount);
            }
            pool.totalAmount = pool.totalAmount.add(_amount);
            user.amount = user.amount.add(_amount);
        }
        emit Deposit(_user, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        _withdrawOperation(_pid, _amount, msg.sender);
    }

    function withdrawForUser(
        uint256 _pid,
        uint256 _amount,
        address user_
    ) public {
        _withdrawOperation(_pid, _amount, user_);
    }

    // Withdraw LP tokens from MasterChef.
    function _withdrawOperation(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) internal nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        require(user.amount >= _amount, "withdraw: Insufficient balance");
        if (pool.proxyFarmer != address(0)) {
            require(msg.sender == pool.proxyFarmer, "Only proxy farmer");
        } else {
            require(msg.sender == _user, "Can not withdraw for others");
        }
        updatePool(_pid);
        for (uint256 rewardId = 0; rewardId < rewardSpecs.length; rewardId++) {
            RewardSpec storage rewardSpec = rewardSpecs[rewardId];
            uint256 accRewardPerShare = poolsRewardsAccRewardsPerShare[_pid][rewardId];
            if (user.amount > 0) {
                uint256 pending = user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt[rewardId]);
                if (pending > 0) {
                    rewardSpec.claimedAmount += pending;
                    user.claimedRewards[rewardId] += pending;
                    rewardSpec.token.safeTransfer(_user, pending);
                }
                user.rewardDebt[rewardId] = user.amount.mul(accRewardPerShare).div(1e12);
            }

            if (_amount > 0) {
                user.rewardDebt[rewardId] = user.amount.sub(_amount).mul(accRewardPerShare).div(1e12);
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalAmount = pool.totalAmount.sub(_amount);
            if (pool.proxyFarmer == address(0)) {
                pool.lpToken.safeTransfer(address(_user), _amount);
            }
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(pool.proxyFarmer != address(0), "nothing to withdraw");

        pool.totalAmount = pool.totalAmount.sub(user.amount);
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        user.amount = 0;
        for (uint256 rewardId = 0; rewardId < rewardSpecs.length; rewardId++) {
            user.rewardDebt[rewardId] = 0;
        }
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    }

    function setAdmin(address admin_) public onlyAdmin {
        require(admin_ != address(0), "can not be zero address");
        address previousAdmin = admin;
        admin = admin_;

        emit AdminChanged(previousAdmin, admin_);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


import "./ExtendableBond.sol";
import "./libs/DuetMath.sol";
import "./interfaces/IMultiRewardsMasterChef.sol";
import "./libs/Adminable.sol";
import "./interfaces/IBondFarmingPool.sol";
import "./interfaces/IExtendableBond.sol";

contract BondFarmingPool is PausableUpgradeable, ReentrancyGuardUpgradeable, IBondFarmingPool, Adminable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IERC20Upgradeable public bondToken;
    IExtendableBond public bond;
    uint256 public totalShares = 0;
    uint256 public lastUpdatedPoolAt = 0;
    IBondFarmingPool public siblingPool;

    IMultiRewardsMasterChef public masterChef;
    uint256 public masterChefPid;

    struct UserInfo {
        /**
         * @dev described compounded underlying bond token amount, user's shares / total shares * underlying amount = user's amount.
         */
        uint256 shares;
        /**
         * @notice accumulated net staked amount. only for earned to date calculation.
         * @dev formula: accumulatedStakedAmount - accumulatedUnstakedAmount
         */
        int256 accNetStaked;
    }

    mapping(address => UserInfo) public usersInfo;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event SiblingPoolUpdated(address indexed previousPool, address indexed newPool);

    function initialize(
        IERC20Upgradeable bondToken_,
        IExtendableBond bond_,
        address admin_
    ) public initializer {
        __ReentrancyGuard_init();
        __Pausable_init();
        _setAdmin(admin_);
        bondToken = bondToken_;
        bond = bond_;
    }

    function setMasterChef(IMultiRewardsMasterChef masterChef_, uint256 masterChefPid_) public onlyAdmin {
        masterChef = masterChef_;
        masterChefPid = masterChefPid_;
    }

    function setSiblingPool(IBondFarmingPool siblingPool_) public onlyAdmin {
        require(
            (address(siblingPool_.siblingPool()) == address(0) ||
                address(siblingPool_.siblingPool()) == address(this)) && address(siblingPool_) != address(this),
            "Invalid sibling"
        );
        emit SiblingPoolUpdated(address(siblingPool), address(siblingPool_));
        siblingPool = siblingPool_;
    }

    function claimBonuses() public {
        address user = msg.sender;
        UserInfo storage userInfo = usersInfo[user];
        require(userInfo.shares > 0, "Nothing to claim");

        masterChef.withdrawForUser(masterChefPid, 0, user);
    }

    /**
     * @dev see: _updatePool
     */
    function updatePool() external {
        require(
            msg.sender == address(siblingPool) || msg.sender == address(bond),
            "BondLPFarmingPool: Calling from sibling pool or bond only"
        );
        _updatePool();
    }

    /**
     * @dev allocate pending rewards.
     */
    function _updatePool() internal {
        require(address(siblingPool) != address(0), "BondFarmingPool: Contract not ready yet.");
        // Single bond token farming rewards base on  'bond token mount in pool' / 'total bond token supply' * 'total underlying rewards' and remaining rewards for LP pools.
        // So single bond farming pool should be updated before LP's.
        require(
            siblingPool.lastUpdatedPoolAt() < block.number ||
                (siblingPool.lastUpdatedPoolAt() == lastUpdatedPoolAt && lastUpdatedPoolAt == block.number),
            "update bond pool firstly."
        );
        uint256 pendingRewards = totalPendingRewards();

        lastUpdatedPoolAt = block.number;
        if (pendingRewards <= 0) {
            return;
        }
        bond.mintBondTokenForRewards(address(this), pendingRewards);
    }

    /**
     * @dev calculate earned amount to date of specific user.
     */
    function earnedToDate(address user_) public view returns (int256) {
        UserInfo storage userInfo = usersInfo[user_];
        return int256(sharesToBondAmount(userInfo.shares)) - userInfo.accNetStaked;
    }

    function totalPendingRewards() public view virtual returns (uint256) {
        if (lastUpdatedPoolAt == block.number) {
            return 0;
        }
        uint256 remoteTotalPendingRewards = bond.totalPendingRewards();


        if (remoteTotalPendingRewards <= 0) {
            return 0;
        }
        uint256 poolBalance = bondToken.balanceOf(address(this));
        if (poolBalance <= 0) {
            return 0;
        }



        return DuetMath.mulDiv(uint256(remoteTotalPendingRewards), poolBalance, bondToken.totalSupply());
    }

    function pendingRewardsByShares(uint256 shares_) public view returns (uint256) {
        if (shares_ <= 0) {
            return 0;
        }
        uint256 totalPendingRewards = totalPendingRewards();

        return
            DuetMath.mulDiv(totalPendingRewards - bond.calculateFeeAmount(totalPendingRewards), shares_, totalShares);
    }

    function sharesToBondAmount(uint256 shares_) public view returns (uint256) {
        if (shares_ <= 0) {
            return 0;
        }
        return DuetMath.mulDiv(underlyingAmount(true), shares_, totalShares);
    }

    function amountToShares(uint256 amount_) public view returns (uint256) {
        return totalShares > 0 ? DuetMath.mulDiv(amount_, totalShares, underlyingAmount(false)) : amount_;
    }

    function underlyingAmount(bool exclusiveFees) public view returns (uint256) {
        uint256 totalPendingRewards = totalPendingRewards();
        totalPendingRewards -= exclusiveFees ? bond.calculateFeeAmount(totalPendingRewards) : 0;
        return totalPendingRewards + bondToken.balanceOf(address(this));
    }

    function stake(uint256 amount_) public whenNotPaused {
        address user = msg.sender;
        stakeForUser(user, amount_);
    }

    function stakeForUser(address user_, uint256 amount_) public whenNotPaused nonReentrant {
        // distributing pending rewards of all sibling pools to correct reward ratio between them.
        _updatePools();

        uint256 stakeShares = amountToShares(amount_);

        bondToken.safeTransferFrom(msg.sender, address(this), amount_);
        totalShares += stakeShares;
        usersInfo[user_].shares += stakeShares;
        usersInfo[user_].accNetStaked += int256(amount_);
        masterChef.depositForUser(masterChefPid, stakeShares, user_);
        emit Staked(user_, amount_);
    }

    function _updatePools() internal {
        _updatePool();
        siblingPool.updatePool();
    }

    function unstakeAll() public {
        require(usersInfo[msg.sender].shares > 0, "nothing to unstake");
        unstake(usersInfo[msg.sender].shares);
    }

    /**
     * @notice unstake by shares
     */
    function unstake(uint256 shares_) public whenNotPaused nonReentrant {
        address user = msg.sender;
        UserInfo storage userInfo = usersInfo[user];
        require(userInfo.shares >= shares_ && totalShares >= shares_, "unstake shares exceeds owned shares");

        // distribute pending rewards of all sibling pools to correct reward ratio between them.
        _updatePools();

        // including rewards.
        uint256 totalBondAmount = sharesToBondAmount(shares_);
        userInfo.shares -= shares_;
        totalShares -= shares_;




        bondToken.safeTransfer(user, totalBondAmount);
        usersInfo[user].accNetStaked -= int256(totalBondAmount);
        masterChef.withdrawForUser(masterChefPid, shares_, user);
        emit Unstaked(user, totalBondAmount);
    }

    function unstakeByAmount(uint256 amount_) public {
        if (amount_ == 0) {}
        UserInfo storage userInfo = usersInfo[msg.sender];
        uint256 userTotalAmount = sharesToBondAmount(userInfo.shares);

        if (amount_ >= userTotalAmount) {
            unstake(userInfo.shares);
        } else {
            unstake(DuetMath.mulDiv(userInfo.shares, amount_, userTotalAmount));
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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