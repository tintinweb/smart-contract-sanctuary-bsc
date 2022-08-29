// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/pool-contracts-registry/pool-factory/PublicBeaconProxy.sol";

import "./interfaces/IRegistry.sol";
import "./interfaces/ISystemPoolsRegistry.sol";
import "./interfaces/ISystemPoolsFactory.sol";
import "./interfaces/IBasicPool.sol";

contract SystemPoolsFactory is ISystemPoolsFactory, AbstractDependant {
    IRegistry private registry;
    ISystemPoolsRegistry private systemPoolsRegistry;

    modifier onlySystemPoolsRegistry() {
        require(
            address(systemPoolsRegistry) == msg.sender,
            "SystemPoolsFactory: Caller not a SystemPoolsRegistry."
        );
        _;
    }

    function setDependencies(address _contractsRegistry) external override dependant {
        registry = IRegistry(_contractsRegistry);

        systemPoolsRegistry = ISystemPoolsRegistry(registry.getSystemPoolsRegistryContract());
    }

    function newLiquidityPool(
        address _assetAddr,
        bytes32 _assetKey,
        string calldata _tokenSymbol
    ) external override onlySystemPoolsRegistry returns (address) {
        address _proxyAddr = _createPool(ISystemPoolsRegistry.PoolType.LIQUIDITY_POOL);

        ILiquidityPool(_proxyAddr).liquidityPoolInitialize(_assetAddr, _assetKey, _tokenSymbol);

        return _proxyAddr;
    }

    function newStablePool(address _assetAddr, bytes32 _assetKey)
        external
        override
        onlySystemPoolsRegistry
        returns (address)
    {
        address _proxyAddr = _createPool(ISystemPoolsRegistry.PoolType.STABLE_POOL);

        IStablePool(_proxyAddr).stablePoolInitialize(_assetAddr, _assetKey);

        return _proxyAddr;
    }

    function _createPool(ISystemPoolsRegistry.PoolType _poolType) internal returns (address) {
        ISystemPoolsRegistry _poolsRegistry = systemPoolsRegistry;

        address _proxyAddr = address(
            new PublicBeaconProxy(_poolsRegistry.getPoolsBeacon(_poolType), "")
        );

        AbstractDependant(_proxyAddr).setDependencies(address(registry));
        AbstractDependant(_proxyAddr).setInjector(address(_poolsRegistry));

        return _proxyAddr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 *  @notice The ContractsRegistry module
 *
 *  This is a contract that must be used as dependencies accepter in the dependency injection mechanism.
 *  Upon the injection, the Injector (ContractsRegistry most of the time) will call the `setDependencies()` function.
 *  The dependant contract will have to pull the required addresses from the supplied ContractsRegistry as a parameter.
 *
 *  The AbstractDependant is fully compatible with proxies courtesy of custom storage slot.
 */
abstract contract AbstractDependant {
    /**
     *  @notice The slot where the dependency injector is located.
     *  @dev keccak256(AbstractDependant.setInjector(address)) - 1
     *
     *  Only the injector is allowed to inject dependencies.
     *  The first to call the setDependencies() (with the modifier applied) function becomes an injector
     */
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier dependant() {
        _checkInjector();
        _;
        _setInjector(msg.sender);
    }

    /**
     *  @notice The function that will be called from the ContractsRegistry (or factory) to inject dependencies.
     *  @param contractsRegistry the registry to pull dependencies from
     *
     *  The Dependant must apply dependant() modifier to this function
     */
    function setDependencies(address contractsRegistry) external virtual;

    /**
     *  @notice The function is made external to allow for the factories to set the injector to the ContractsRegistry
     *  @param _injector the new injector
     */
    function setInjector(address _injector) external {
        _checkInjector();
        _setInjector(_injector);
    }

    /**
     *  @notice The function to get the current injector
     *  @return _injector the current injector
     */
    function getInjector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }

    /**
     *  @notice Internal function that checks the injector credentials
     */
    function _checkInjector() internal view {
        address _injector = getInjector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
    }

    /**
     *  @notice Internal function that sets the injector
     */
    function _setInjector(address _injector) internal {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  The helper BeaconProxy that get deployed by the PoolFactory. Note that the external
 *  `implementation()` function is added to the contract to provide compatability with the
 *  Etherscan. This means that the implementation must not have such a function declared.
 */
contract PublicBeaconProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) payable BeaconProxy(beacon, data) {}

    /**
     *  @notice The function that returns implementation contract this proxy points to
     *  @return address the implementation address
     */
    function implementation() external view virtual returns (address) {
        return _implementation();
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is the main register of the system, which stores the addresses of all the necessary contracts of the system.
 * With this contract you can add new contracts, update the implementation of proxy contracts
 */
interface IRegistry {
    /// @notice Function to get the address of the system owner
    /// @return a system owner address
    function getSystemOwner() external view returns (address);

    /// @notice Function to get the address of the DefiCore contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return DefiCore contract address
    function getDefiCoreContract() external view returns (address);

    /// @notice Function to get the address of the SystemParameters contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return SystemParameters contract address
    function getSystemParametersContract() external view returns (address);

    /// @notice Function to get the address of the AssetParameters contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return AssetParameters contract address
    function getAssetParametersContract() external view returns (address);

    /// @notice Function to get the address of the RewardsDistribution contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return RewardsDistribution contract address
    function getRewardsDistributionContract() external view returns (address);

    /// @notice Function to get the address of the UserInfoRegistry contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return UserInfoRegistry contract address
    function getUserInfoRegistryContract() external view returns (address);

    /// @notice Function to get the address of the SystemPoolsRegistry contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return SystemPoolsRegistry contract address
    function getSystemPoolsRegistryContract() external view returns (address);

    /// @notice Function to get the address of the SystemPoolsFactory contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return SystemPoolsFactory contract address
    function getSystemPoolsFactoryContract() external view returns (address);

    /// @notice Function to get the address of the PriceManager contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return PriceManager contract address
    function getPriceManagerContract() external view returns (address);

    /// @notice Function to get the address of the InterestRateLibrary contract
    /// @dev Used in dependency injection mechanism in the system
    /// @return InterestRateLibrary contract address
    function getInterestRateLibraryContract() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./IAssetParameters.sol";

/**
 * This contract is needed to add new pools, store and retrieve information about already created pools
 */
interface ISystemPoolsRegistry {
    /// @notice Enumeration with the types of pools that are available in the system
    /// @param LIQUIDITY_POOL a liquidity pool type
    /// @param STABLE_POOL a stable pool type
    enum PoolType {
        LIQUIDITY_POOL,
        STABLE_POOL
    }

    /// @notice This structure contains system information about the pool
    /// @param poolAddr an address of the pool
    /// @param poolType stored pool type
    struct PoolInfo {
        address poolAddr;
        PoolType poolType;
    }

    /// @notice This structure contains system information a certain type of pool
    /// @param poolBeaconAddr beacon contract address for a certain type of pools
    /// @param supportedAssetKeys storage of keys, which are supported by a certain type of pools
    struct PoolTypeInfo {
        address poolBeaconAddr;
        EnumerableSet.Bytes32Set supportedAssetKeys;
    }

    /// @notice This structure contains basic information about the pool
    /// @param assetKey key of the pool for which the information was obtained
    /// @param assetAddr address of the pool underlying asset
    /// @param borrowAPY annual borrow rate in the current
    /// @param distrBorrowAPY annual distribution rate for users who took credit in the current pool
    /// @param totalBorrowBalance the total number of tokens that have been borrowed in the current pool
    /// @param totalBorrowBalanceInUSD the equivalent of totalBorrowBalance param in dollars
    struct BasePoolInfo {
        bytes32 assetKey;
        address assetAddr;
        uint256 borrowAPY;
        uint256 distrBorrowAPY;
        uint256 totalBorrowBalance;
        uint256 totalBorrowBalanceInUSD;
    }

    /// @notice This structure contains main information about the liquidity pool
    /// @param baseInfo element type BasePoolInfo structure
    /// @param supplyAPY annual supply rate in the current pool
    /// @param distrSupplyAPY annual distribution rate for users who deposited in the current pool
    /// @param marketSize the total number of pool tokens that all users have deposited
    /// @param marketSizeInUSD the equivalent of marketSize param in dollars
    /// @param utilizationRatio the current percentage of how much of the pool was borrowed for liquidity
    /// @param isAvailableAsCollateral can an asset even be a collateral
    struct LiquidityPoolInfo {
        BasePoolInfo baseInfo;
        uint256 supplyAPY;
        uint256 distrSupplyAPY;
        uint256 marketSize;
        uint256 marketSizeInUSD;
        uint256 utilizationRatio;
        bool isAvailableAsCollateral;
    }

    /// @notice This structure contains main information about the liquidity pool
    /// @param baseInfo element type BasePoolInfo structure
    struct StablePoolInfo {
        BasePoolInfo baseInfo;
    }

    /// @notice This structure contains detailed information about the pool
    /// @param poolInfo element type LiquidityPoolInfo structure
    /// @param mainPoolParams element type IAssetParameters.MainPoolParams structure
    /// @param availableLiquidity available liquidity for borrowing
    /// @param availableLiquidityInUSD the equivalent of availableLiquidity param in dollars
    /// @param totalReserve total amount of reserves in the current pool
    /// @param totalReserveInUSD the equivalent of totalReserve param in dollars
    /// @param distrSupplyAPY annual distribution rate for users who deposited in the current pool
    /// @param distrBorrowAPY annual distribution rate for users who took credit in the current pool
    struct DetailedLiquidityPoolInfo {
        LiquidityPoolInfo poolInfo;
        IAssetParameters.MainPoolParams mainPoolParams;
        uint256 availableLiquidity;
        uint256 availableLiquidityInUSD;
        uint256 totalReserve;
        uint256 totalReserveInUSD;
        uint256 distrSupplyAPY;
        uint256 distrBorrowAPY;
    }

    struct DonationInfo {
        uint256 totalDonationInUSD;
        uint256 availableToDonateInUSD;
        address donationAddress;
    }

    /// @notice This event is emitted when a new pool is added
    /// @param _assetKey new pool identification key
    /// @param _assetAddr the pool underlying asset address
    /// @param _poolAddr the added pool address
    /// @param _poolType the type of the added pool
    event PoolAdded(bytes32 _assetKey, address _assetAddr, address _poolAddr, PoolType _poolType);

    /// @notice Function to add a beacon contract for the desired type of pools
    /// @dev Only contract owner can call this function
    /// @param _poolType the type of pool for which the beacon contract will be added
    /// @param _poolImpl the implementation address for the desired pool type
    function addPoolsBeacon(PoolType _poolType, address _poolImpl) external;

    /// @notice The function is needed to add new liquidity pools
    /// @dev Only contract owner can call this function
    /// @param _assetAddr address of the underlying liquidity pool asset
    /// @param _assetKey pool key of the added liquidity pool
    /// @param _chainlinkOracle the address of the chainlink oracle for the passed asset
    /// @param _tokenSymbol symbol of the underlying liquidity pool asset
    /// @param _isCollateral is it possible for the new liquidity pool to be a collateral
    function addLiquidityPool(
        address _assetAddr,
        bytes32 _assetKey,
        address _chainlinkOracle,
        string calldata _tokenSymbol,
        bool _isCollateral
    ) external;

    /// @notice The function is needed to add new stable pools
    /// @dev Only contract owner can call this function
    /// @param _assetAddr address of the underlying stable pool asset
    /// @param _assetKey pool key of the added stable pool
    /// @param _chainlinkOracle the address of the chainlink oracle for the passed asset
    function addStablePool(
        address _assetAddr,
        bytes32 _assetKey,
        address _chainlinkOracle
    ) external;

    /// @notice The function is needed to update the implementation of the pools
    /// @dev Only contract owner can call this function
    /// @param _poolType needed pool type from PoolType enum
    /// @param _newPoolsImpl address of the new pools implementation
    function upgradePoolsImpl(PoolType _poolType, address _newPoolsImpl) external;

    /// @notice The function inject dependencies to existing liquidity pools
    /// @dev Only contract owner can call this function
    function injectDependenciesToExistingPools() external;

    /// @notice The function inject dependencies with pagination
    /// @dev Only contract owner can call this function
    function injectDependencies(uint256 _offset, uint256 _limit) external;

    /// @notice The function returns the native asset key
    /// @return a native asset key
    function nativeAssetKey() external view returns (bytes32);

    /// @notice The function returns the asset key, which will be credited as a reward for distribution
    /// @return a rewards asset key
    function rewardsAssetKey() external view returns (bytes32);

    /// @notice The function returns system information for the desired pool
    /// @param _assetKey pool key for which you want to get information
    /// @return poolAddr an address of the pool
    /// @return poolType a pool type
    function poolsInfo(bytes32 _assetKey)
        external
        view
        returns (address poolAddr, PoolType poolType);

    /// @notice Indicates whether the address is a liquidity pool
    /// @param _poolAddr address of the liquidity pool to check
    /// @return true if the passed address is a liquidity pool, false otherwise
    function existingLiquidityPools(address _poolAddr) external view returns (bool);

    /// @notice A function that returns an array of structures with liquidity pool information
    /// @param _assetKeys an array of pool keys for which you want to get information
    /// @return _poolsInfo an array of LiquidityPoolInfo structures
    function getLiquidityPoolsInfo(bytes32[] calldata _assetKeys)
        external
        view
        returns (LiquidityPoolInfo[] memory _poolsInfo);

    /// @notice A function that returns an array of structures with stable pool information
    /// @param _assetKeys an array of pool keys for which you want to get information
    /// @return _poolsInfo an array of StablePoolInfo structures
    function getStablePoolsInfo(bytes32[] calldata _assetKeys)
        external
        view
        returns (StablePoolInfo[] memory _poolsInfo);

    /// @notice A function that returns a structure with detailed pool information
    /// @param _assetKey pool key for which you want to get information
    /// @return a DetailedLiquidityPoolInfo structure
    function getDetailedLiquidityPoolInfo(bytes32 _assetKey)
        external
        view
        returns (DetailedLiquidityPoolInfo memory);

    function getDonationInfo() external view returns (DonationInfo memory);

    /// @notice Returns the address of the liquidity pool for the rewards token
    /// @return liquidity pool address for the rewards token
    function getRewardsLiquidityPool() external view returns (address);

    /// @notice A system function that returns the address of liquidity pool beacon
    /// @param _poolType needed pool type from PoolType enum
    /// @return a required pool beacon address
    function getPoolsBeacon(PoolType _poolType) external view returns (address);

    /// @notice A function that returns the address of liquidity pools implementation
    /// @param _poolType needed pool type from PoolType enum
    /// @return a required pools implementation address
    function getPoolsImpl(PoolType _poolType) external view returns (address);

    /// @notice Function to check if the pool exists by the passed pool key
    /// @param _assetKey pool identification key
    /// @return true if the liquidity pool for the passed key exists, false otherwise
    function onlyExistingPool(bytes32 _assetKey) external view returns (bool);

    /// @notice The function returns the number of all supported assets in the system
    /// @return an all supported assets count
    function getAllSupportedAssetKeysCount() external view returns (uint256);

    /// @notice The function returns the number of all supported assets in the system by types
    /// @param _poolType type of pools, the number of which you want to get
    /// @return an all supported assets count for passed pool type
    function getSupportedAssetKeysCountByType(PoolType _poolType) external view returns (uint256);

    /// @notice The function returns the keys of all the system pools
    /// @return an array of all system pool keys
    function getAllSupportedAssetKeys() external view returns (bytes32[] memory);

    /// @notice The function returns the keys of all pools by type
    /// @param _poolType the type of pool, the keys for which you want to get
    /// @return an array of all pool keys by passed type
    function getAllSupportedAssetKeysByType(PoolType _poolType)
        external
        view
        returns (bytes32[] memory);

    /// @notice The function returns keys of created pools with pagination
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool keys
    function getSupportedAssetKeys(uint256 _offset, uint256 _limit)
        external
        view
        returns (bytes32[] memory);

    /// @notice The function returns keys of created pools with pagination by pool type
    /// @param _poolType the type of pool, the keys for which you want to get
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool keys by passed type
    function getSupportedAssetKeysByType(
        PoolType _poolType,
        uint256 _offset,
        uint256 _limit
    ) external view returns (bytes32[] memory);

    /// @notice Returns an array of addresses of all created pools
    /// @return an array of all pool addresses
    function getAllPools() external view returns (address[] memory);

    /// @notice The function returns an array of all pools of the desired type
    /// @param _poolType the pool type for which you want to get an array of all pool addresses
    /// @return an array of all pool addresses by passed type
    function getAllPoolsByType(PoolType _poolType) external view returns (address[] memory);

    /// @notice Returns addresses of created pools with pagination
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool addresses
    function getPools(uint256 _offset, uint256 _limit) external view returns (address[] memory);

    /// @notice Returns addresses of created pools with pagination by type
    /// @param _poolType the pool type for which you want to get an array of pool addresses
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @return an array of pool addresses by passed type
    function getPoolsByType(
        PoolType _poolType,
        uint256 _offset,
        uint256 _limit
    ) external view returns (address[] memory);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./ISystemPoolsRegistry.sol";

/**
 * This contract is a factory for deploying new system pools
 */
interface ISystemPoolsFactory {
    /// @notice This function is needed for deploying a new liquidity pool
    /// @dev Only SystemPoolsRegistry contract can call this function
    /// @param _assetAddr address of the underlying pool asset
    /// @param _assetKey pool key of the new liquidity pool
    /// @param _tokenSymbol symbol of the underlying pool asset
    /// @return a new liquidity pool address
    function newLiquidityPool(
        address _assetAddr,
        bytes32 _assetKey,
        string calldata _tokenSymbol
    ) external returns (address);

    /// @notice This function is needed for deploying a new stable pool
    /// @dev Only SystemPoolsRegistry contract can call this function
    /// @param _assetAddr address of the underlying pool asset
    /// @param _assetKey pool key of the new stable pool
    /// @return a new stable pool address
    function newStablePool(address _assetAddr, bytes32 _assetKey) external returns (address);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is the basic abstract loan pool.
 * Needed to inherit from it all the custom pools of the system
 */
interface IBasicPool {
    /// @notice A structure that contains information about user borrows
    /// @param borrowAmount absolute amount of borrow in tokens
    /// @param normalizedAmount normalized user borrow amount
    struct BorrowInfo {
        uint256 borrowAmount;
        uint256 normalizedAmount;
    }

    /// @notice System structure, which is needed to avoid stack overflow and stores the information to repay the borrow
    /// @param repayAmount amount in tokens for repayment
    /// @param currentAbsoluteAmount user debt with interest
    /// @param normalizedAmount normalized user borrow amount
    /// @param currentRate current pool compound rate
    /// @param userAddr address of the user who will repay the debt
    struct RepayBorrowVars {
        uint256 repayAmount;
        uint256 currentAbsoluteAmount;
        uint256 normalizedAmount;
        uint256 currentRate;
        address userAddr;
    }

    /// @notice The function is needed to allow addresses to borrow against your address for the desired amount
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user who makes the approval
    /// @param _approveAmount the amount for which the approval is made
    /// @param _delegateeAddr address who is allowed to borrow the passed amount
    /// @param _currentAllowance allowance before function execution
    function approveToBorrow(
        address _userAddr,
        uint256 _approveAmount,
        address _delegateeAddr,
        uint256 _currentAllowance
    ) external;

    /// @notice The function that allows you to take a borrow and send borrowed tokens to the desired address
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to whom the credit will be taken
    /// @param _recipient the address that will receive the borrowed tokens
    /// @param _amountToBorrow amount to borrow in tokens
    function borrowFor(
        address _userAddr,
        address _recipient,
        uint256 _amountToBorrow
    ) external;

    /// @notice A function by which you can take credit for the address that gave you permission to do so
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to whom the credit will be taken
    /// @param _delegator the address that will receive the borrowed tokens
    /// @param _amountToBorrow amount to borrow in tokens
    function delegateBorrow(
        address _userAddr,
        address _delegator,
        uint256 _amountToBorrow
    ) external;

    /// @notice Function for repayment of a specific user's debt
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user from whom the funds will be deducted to repay the debt
    /// @param _closureAddr address of the user to whom the debt will be repaid
    /// @param _repayAmount the amount to repay the debt
    /// @param _isMaxRepay a flag that shows whether or not to repay the debt by the maximum possible amount
    /// @return repayment amount
    function repayBorrowFor(
        address _userAddr,
        address _closureAddr,
        uint256 _repayAmount,
        bool _isMaxRepay
    ) external payable returns (uint256);

    /// @notice Function for withdrawal of reserve funds from the pool
    /// @dev Only SystemPoolsRegistry contract can call this function. The function takes the amount with 18 decimals
    /// @param _recipientAddr the address of the user who will receive the reserve tokens
    /// @param _amountToWithdraw number of reserve funds for withdrawal
    /// @param _isAllFunds flag that shows whether to withdraw all reserve funds or not
    function withdrawReservedFunds(
        address _recipientAddr,
        uint256 _amountToWithdraw,
        bool _isAllFunds
    ) external returns (uint256);

    /// @notice Function to update the compound rate with or without interval
    /// @param _withInterval flag that shows whether to update the rate with or without interval
    /// @return new compound rate
    function updateCompoundRate(bool _withInterval) external returns (uint256);

    /// @notice Function to get the underlying asset address
    /// @return an address of the underlying asset
    function assetAddr() external view returns (address);

    /// @notice Function to get a pool key
    /// @return a pool key
    function assetKey() external view returns (bytes32);

    /// @notice Function to get the pool total number of tokens borrowed without interest
    /// @return total borrowed amount without interest
    function aggregatedBorrowedAmount() external view returns (uint256);

    /// @notice Function to get the total amount of reserve funds
    /// @return total reserve funds
    function totalReserves() external view returns (uint256);

    /// @notice Function to get information about the user's borrow
    /// @param _userAddr address of the user for whom you want to get information
    /// @return borrowAmount absolute amount of borrow in tokens
    /// @return normalizedAmount normalized user borrow amount
    function borrowInfos(address _userAddr)
        external
        view
        returns (uint256 borrowAmount, uint256 normalizedAmount);

    /// @notice Function to get the total borrowed amount with interest
    /// @return total borrowed amount with interest
    function getTotalBorrowedAmount() external view returns (uint256);

    /// @notice Function to convert the amount in tokens to the amount in dollars
    /// @param _assetAmount amount in asset tokens
    /// @return an amount in dollars
    function getAmountInUSD(uint256 _assetAmount) external view returns (uint256);

    /// @notice Function to convert the amount in dollars to the amount in tokens
    /// @param _usdAmount amount in dollars
    /// @return an amount in asset tokens
    function getAmountFromUSD(uint256 _usdAmount) external view returns (uint256);

    /// @notice Function to get the price of an underlying asset
    /// @return an underlying asset price
    function getAssetPrice() external view returns (uint256);

    /// @notice Function to get the underlying token decimals
    /// @return an underlying token decimals
    function getUnderlyingDecimals() external view returns (uint8);

    /// @notice Function to get the last updated compound rate
    /// @return a last updated compound rate
    function getCurrentRate() external view returns (uint256);

    /// @notice Function to get the current compound rate
    /// @return a current compound rate
    function getNewCompoundRate() external view returns (uint256);

    /// @notice Function to get the current annual interest rate on the borrow
    /// @return a current annual interest rate on the borrow
    function getAnnualBorrowRate() external view returns (uint256);
}

/**
 * Pool contract only for loans with a fixed annual rate
 */
interface IStablePool is IBasicPool {
    /// @notice Function to initialize a new stable pool
    /// @param _assetAddr address of the underlying pool asset
    /// @param _assetKey pool key of the current liquidity pool
    function stablePoolInitialize(address _assetAddr, bytes32 _assetKey) external;
}

/**
 * This is the central contract of the protocol, which is the pool for liquidity.
 * All interaction takes place through the DefiCore contract
 */
interface ILiquidityPool is IBasicPool {
    /// @notice A structure that contains information about user last added liquidity
    /// @param liquidity a total amount of the last liquidity
    /// @param blockNumber block number at the time of the last liquidity entry
    struct UserLastLiquidity {
        uint256 liquidity;
        uint256 blockNumber;
    }

    /// @notice The function that is needed to initialize the pool after it is created
    /// @dev This function can call only once
    /// @param _assetAddr address of the underlying pool asset
    /// @param _assetKey pool key of the current liquidity pool
    /// @param _tokenSymbol symbol of the underlying pool asset
    function liquidityPoolInitialize(
        address _assetAddr,
        bytes32 _assetKey,
        string memory _tokenSymbol
    ) external;

    /// @notice Function for adding liquidity to the pool
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to whom the liquidity will be added
    /// @param _liquidityAmount amount of liquidity to add
    function addLiquidity(address _userAddr, uint256 _liquidityAmount) external payable;

    /// @notice Function for withdraw liquidity from the passed address
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user from which the liquidity will be withdrawn
    /// @param _liquidityAmount amount of liquidity to withdraw
    /// @param _isMaxWithdraw the flag that shows whether to withdraw the maximum available amount or not
    function withdrawLiquidity(
        address _userAddr,
        uint256 _liquidityAmount,
        bool _isMaxWithdraw
    ) external;

    /// @notice Function for writing off the collateral from the address of the person being liquidated during liquidation
    /// @dev Only DefiCore contract can call this function. The function takes the amount with 18 decimals
    /// @param _userAddr address of the user from whom the collateral will be debited
    /// @param _liquidatorAddr address of the liquidator to whom the tokens will be sent
    /// @param _liquidityAmount number of tokens to send
    function liquidate(
        address _userAddr,
        address _liquidatorAddr,
        uint256 _liquidityAmount
    ) external;

    /// @notice Function for getting the liquidity entered by the user in a certain block
    /// @param _userAddr address of the user for whom you want to get information
    /// @return liquidity amount
    function lastLiquidity(address _userAddr) external view returns (uint256, uint256);

    /// @notice Function to get the annual rate on the deposit
    /// @return annual deposit interest rate
    function getAPY() external view returns (uint256);

    /// @notice Function to get the total liquidity in the pool with interest
    /// @return total liquidity in the pool with interest
    function getTotalLiquidity() external view returns (uint256);

    /// @notice Function to get the current amount of liquidity in the pool without reserve funds
    /// @return aggregated liquidity amount without reserve funds
    function getAggregatedLiquidityAmount() external view returns (uint256);

    /// @notice Function to get the current percentage of how many tokens were borrowed
    /// @return an borrow percentage (utilization ratio)
    function getBorrowPercentage() external view returns (uint256);

    /// @notice Function for obtaining available liquidity for credit
    /// @return an available to borrow liquidity
    function getAvailableToBorrowLiquidity() external view returns (uint256);

    /// @notice Function to convert from the amount in the asset to the amount in lp tokens
    /// @param _assetAmount amount in asset tokens
    /// @return an amount in lp tokens
    function convertAssetToLPTokens(uint256 _assetAmount) external view returns (uint256);

    /// @notice Function to convert from the amount amount in lp tokens to the amount in the asset
    /// @param _lpTokensAmount amount in lp tokens
    /// @return an amount in asset tokens
    function convertLPTokensToAsset(uint256 _lpTokensAmount) external view returns (uint256);

    /// @notice Function to get the exchange rate between asset tokens and lp tokens
    /// @return current exchange rate
    function exchangeRate() external view returns (uint256);

    /// @notice Function for getting the last liquidity by current block
    /// @param _userAddr address of the user for whom you want to get information
    /// @return a last liquidity amount (if current block number != last block number returns zero)
    function getCurrentLastLiquidity(address _userAddr) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from an {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializing the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * This is a contract for storage and convenient retrieval of asset parameters
 */
interface IAssetParameters {
    /// @notice This structure contains the main parameters of the pool
    /// @param collateralizationRatio percentage that shows how much collateral will be added from the deposit
    /// @param reserveFactor the percentage of the platform's earnings that will be deducted from the interest on the borrows
    /// @param liquidationDiscount percentage of the discount that the liquidator will receive on the collateral
    /// @param maxUtilizationRatio maximum possible utilization ratio
    struct MainPoolParams {
        uint256 collateralizationRatio;
        uint256 reserveFactor;
        uint256 liquidationDiscount;
        uint256 maxUtilizationRatio;
    }

    /// @notice This structure contains the pool parameters for the borrow percentage curve
    /// @param basePercentage annual rate on the borrow, if utilization ratio is equal to 0%
    /// @param firstSlope annual rate on the borrow, if utilization ratio is equal to utilizationBreakingPoint
    /// @param secondSlope annual rate on the borrow, if utilization ratio is equal to 100%
    /// @param utilizationBreakingPoint percentage at which the graph breaks
    struct InterestRateParams {
        uint256 basePercentage;
        uint256 firstSlope;
        uint256 secondSlope;
        uint256 utilizationBreakingPoint;
    }

    /// @notice This structure contains the pool parameters that are needed to calculate the distribution
    /// @param minSupplyDistrPart percentage, which indicates the minimum part of the reward distribution for users who deposited
    /// @param minBorrowDistrPart percentage, which indicates the minimum part of the reward distribution for users who borrowed
    struct DistributionMinimums {
        uint256 minSupplyDistrPart;
        uint256 minBorrowDistrPart;
    }

    /// @notice This structure contains all the parameters of the pool
    /// @param mainParams element type MainPoolParams structure
    /// @param interestRateParams element type InterestRateParams structure
    /// @param distrMinimums element type DistributionMinimums structure
    struct AllPoolParams {
        MainPoolParams mainParams;
        InterestRateParams interestRateParams;
        DistributionMinimums distrMinimums;
    }

    /// @notice This event is emitted when the pool's main parameters are set
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _colRatio percentage that shows how much collateral will be added from the deposit
    /// @param _reserveFactor the percentage of the platform's earnings that will be deducted from the interest on the borrows
    /// @param _liquidationDiscount percentage of the discount that the liquidator will receive on the collateral
    /// @param _maxUR maximum possible utilization ratio
    event MainParamsUpdated(
        bytes32 _assetKey,
        uint256 _colRatio,
        uint256 _reserveFactor,
        uint256 _liquidationDiscount,
        uint256 _maxUR
    );

    /// @notice This event is emitted when the pool's interest rate parameters are set
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _basePercentage annual rate on the borrow, if utilization ratio is equal to 0%
    /// @param _firstSlope annual rate on the borrow, if utilization ratio is equal to utilizationBreakingPoint
    /// @param _secondSlope annual rate on the borrow, if utilization ratio is equal to 100%
    /// @param _utilizationBreakingPoint percentage at which the graph breaks
    event InterestRateParamsUpdated(
        bytes32 _assetKey,
        uint256 _basePercentage,
        uint256 _firstSlope,
        uint256 _secondSlope,
        uint256 _utilizationBreakingPoint
    );

    /// @notice This event is emitted when the pool's distribution minimums are set
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _supplyDistrPart percentage, which indicates the minimum part of the reward distribution for users who deposited
    /// @param _borrowDistrPart percentage, which indicates the minimum part of the reward distribution for users who borrowed
    event DistributionMinimumsUpdated(
        bytes32 _assetKey,
        uint256 _supplyDistrPart,
        uint256 _borrowDistrPart
    );

    event AnnualBorrowRateUpdated(bytes32 _assetKey, uint256 _newAnnualBorrowRate);

    /// @notice This event is emitted when the pool freeze parameter is set
    /// @param _assetKey the key of the pool for which the parameter is set
    /// @param _newValue new value of the pool freeze parameter
    event FreezeParamUpdated(bytes32 _assetKey, bool _newValue);

    /// @notice This event is emitted when the pool collateral parameter is set
    /// @param _assetKey the key of the pool for which the parameter is set
    /// @param _isCollateral new value of the pool collateral parameter
    event CollateralParamUpdated(bytes32 _assetKey, bool _isCollateral);

    /// @notice System function needed to set parameters during pool creation
    /// @dev Only SystemPoolsRegistry contract can call this function
    /// @param _assetKey the key of the pool for which the parameters are set
    /// @param _isCollateral a flag that indicates whether a pool can even be a collateral
    function setPoolInitParams(bytes32 _assetKey, bool _isCollateral) external;

    /// @notice Function for setting the annual borrow rate of the stable pool
    /// @dev Only contract owner can call this function. Only for stable pools
    /// @param _assetKey pool key for which parameters will be set
    /// @param _newAnnualBorrowRate new annual borrow rate parameter
    function setupAnnualBorrowRate(bytes32 _assetKey, uint256 _newAnnualBorrowRate) external;

    /// @notice Function for setting the main parameters of the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _mainParams structure with the main parameters of the pool
    function setupMainParameters(bytes32 _assetKey, MainPoolParams calldata _mainParams) external;

    /// @notice Function for setting the interest rate parameters of the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _interestParams structure with the interest rate parameters of the pool
    function setupInterestRateModel(bytes32 _assetKey, InterestRateParams calldata _interestParams)
        external;

    /// @notice Function for setting the distribution minimums of the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _distrMinimums structure with the distribution minimums of the pool
    function setupDistributionsMinimums(
        bytes32 _assetKey,
        DistributionMinimums calldata _distrMinimums
    ) external;

    /// @notice Function for setting all pool parameters
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key for which parameters will be set
    /// @param _poolParams structure with all pool parameters
    function setupAllParameters(bytes32 _assetKey, AllPoolParams calldata _poolParams) external;

    /// @notice Function for freezing the pool
    /// @dev Only contract owner can call this function
    /// @param _assetKey pool key to be frozen
    function freeze(bytes32 _assetKey) external;

    /// @notice Function to enable the pool as a collateral
    /// @dev Only contract owner can call this function
    /// @param _assetKey the pool key to be enabled as a collateral
    function enableCollateral(bytes32 _assetKey) external;

    /// @notice Function for getting information about whether the pool is frozen
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return true if the liquidity pool is frozen, false otherwise
    function isPoolFrozen(bytes32 _assetKey) external view returns (bool);

    /// @notice Function for getting information about whether a pool can be a collateral
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return true, if the pool is available as a collateral, false otherwise
    function isAvailableAsCollateral(bytes32 _assetKey) external view returns (bool);

    /// @notice Function for getting annual borrow rate
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return an annual borrow rate
    function getAnnualBorrowRate(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function for getting the main parameters of the pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return a structure with the main parameters of the pool
    function getMainPoolParams(bytes32 _assetKey) external view returns (MainPoolParams memory);

    /// @notice Function for getting the interest rate parameters of the pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return a structure with the interest rate parameters of the pool
    function getInterestRateParams(bytes32 _assetKey)
        external
        view
        returns (InterestRateParams memory);

    /// @notice Function for getting the distribution minimums of the pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return a structure with the distribution minimums of the pool
    function getDistributionMinimums(bytes32 _assetKey)
        external
        view
        returns (DistributionMinimums memory);

    /// @notice Function to get the collateralization ratio for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return current collateralization ratio value
    function getColRatio(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the reserve factor for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return current reserve factor value
    function getReserveFactor(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the liquidation discount for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return current liquidation discount value
    function getLiquidationDiscount(bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the max utilization ratio for the desired pool
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return maximum possible utilization ratio value
    function getMaxUtilizationRatio(bytes32 _assetKey) external view returns (uint256);
}